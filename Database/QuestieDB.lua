---@class QuestieDB : QuestieModule
local QuestieDB = QuestieLoader:CreateModule("QuestieDB")
---@class QuestieDBPrivate
local _QuestieDB = QuestieDB.private

-------------------------
--Import modules.
-------------------------
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type DropDB
local DropDB = QuestieLoader:ImportModule("DropDB")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")

---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieQuestPrivate
local _QuestieQuest = QuestieQuest.private

--- A list of quests that will never be available, used to quickly skip quests.
---@alias AutoBlacklistString "rep"|"skill"|"race"|"class"|"rank"
---@type table<number, AutoBlacklistString>
QuestieDB.autoBlacklist = {}

local tinsert, tremove, next = table.insert, table.remove, next
local bitband = bit.band

-- questFlags https://github.com/cmangos/issues/wiki/Quest_template#questflags
local QUEST_FLAGS_DAILY = 4096
local QUEST_FLAGS_WEEKLY = 32768
local QUEST_FLAGS_MONTHLY = 65536
-- Pre calculated 2 * QUEST_FLAGS, for testing a bit flag
local QUEST_FLAGS_DAILY_X2 = 2 * QUEST_FLAGS_DAILY
local QUEST_FLAGS_WEEKLY_X2 = 2 * QUEST_FLAGS_WEEKLY
local QUEST_FLAGS_MONTHLY_X2 = 2 * QUEST_FLAGS_MONTHLY
local playerFaction = UnitFactionGroup("Player")
local serverName = GetRealmName()

---@enum QuestTagIds
QuestieDB.questTagIds = {
    ELITE = 1,
    CLASS = 21,
    PVP = 41,
    RAID = 62,
    DUNGEON = 81,
    WORLD_EVENT = 82,
    LEGENDARY = 83,
    ESCORT = 84,
    HEROIC = 85,
    RAID_10 = 88,
    RAID_25 = 89,
    SCENARIO = 98,
    ACCOUNT = 102,
    CELESTIAL = 294,
}
---@enum DoableStates
QuestieDB.DoableStates = {
    AVAILABLE = 0,
    COMPLETED = 1,
    QUEST_LOG = 2,
    BLACKLISTED = 3,
    EXCEED_REPUTATION = 4,
    PARENT_ACTIVE = 5,
    WRONG_RACE = 6,
    NO_PREQUESTSINGLE = 7,
    WRONG_CLASS = 8,
    MISSING_REPUTATION = 9,
    PROFESSION_SKILL = 10,
    NO_PREQUESTGROUP = 11,
    PARENT_INACTIVE = 12,
    NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED = 13,
    EXCLUSIVE_COMPLETED = 14,
    EXCLUSIVE_IN_QUEST_LOG = 15,
    MISSING_DAILY = 16,
    PROFESSION_SPECIALIZATION = 17,
    SPELL_MISSING = 18,
    SPELL_KNOWN = 19,
    MISSING_ACHIEVEMENT = 20,
    BREADCRUMB_FOLLOWUP = 21,
    EVENT_INACTIVE = 22,
    BREADCRUMB_ACTIVE = 23,
    INACTIVE_DAILY = 24,
    LEVEL_TOO_HIGH = 25,
    LEVEL_TOO_LOW = 26,
    DISABLING_QUEST_COMPLETED = 27,
    ENABLING_QUEST_MISSING = 28,
    PROFESSION_MISSING = 29,
    PROFESSION_RANK = 30,
    DISABLED_BY = 31,
    ARENA_RATING = 32,
}

-- * race bitmask data, for easy access
-- ? The PlayableRaceBit can be found in ChrRaces.dbc
-- ? https://wago.tools/db2/ChrRaces?build=5.5.0.60802&filter[PlayableRaceBit]=>-1
-- ? The values below are calculated by 2^PlayableRaceBit
---@class RaceKeys
QuestieDB.raceKeys = {
    -- Allow all alliance races
    ALL_ALLIANCE = (function()
        if Questie.IsClassic then
            return 77
        elseif Questie.IsTBC or Questie.IsWotlk then
            return 1101
        elseif Questie.IsCata then
            return 2098253
        elseif Questie.IsMoP then
            return 18875469
        else
            print("Unknown expansion for ALL_ALLIANCE")
            return 77
        end
    end)(),
    -- Allow all horde races
    ALL_HORDE = (function()
        if Questie.IsClassic then
            return 178
        elseif Questie.IsTBC or Questie.IsWotlk then
            return 690
        elseif Questie.IsCata then
            return 946
        elseif Questie.IsMoP then
            return 33555378
        else
            print("Unknown expansion for ALL_HORDE")
            return 178
        end
    end)(),
    -- Allow all races (No limit on allowed races)
    NONE = 0,

    --[[PlayableRaceBit]]
    --[[ 0]] HUMAN = 1,
    --[[ 1]] ORC  = 2,
    --[[ 2]] DWARF = 4,
    --[[ 3]] NIGHT_ELF = 8,
    --[[ 4]] UNDEAD = 16,
    --[[ 5]] TAUREN = 32,
    --[[ 6]] GNOME = 64,
    --[[ 7]] TROLL = 128,
    --[[ 8]] GOBLIN = 256,                  -- Cata
    --[[ 9]] BLOOD_ELF = 512,               -- TBC
    --[[10]] DRAENEI = 1024,                -- TBC
    --[[21]] WORGEN = 2097152,              -- Cata
    --[[23]] PANDAREN = 8388608,            -- MoP
    --[[24]] PANDAREN_ALLIANCE = 16777216,  -- MoP
    --[[25]] PANDAREN_HORDE = 33554432,     -- MoP
}

-- Combining these with "and" makes the order matter
-- 1 and 2 ~= 2 and 1
QuestieDB.classKeys = {
    -- Allow all classes
    ALL_CLASSES = (function()
        if Questie.IsClassic then
            -- alliance 1439, horde 1501, all 1503
            return 1503
        elseif Questie.IsTBC then
            return 1503
        elseif Questie.IsWotlk or Questie.IsCata then
            return 1535
        elseif Questie.IsMoP then
            return 2047
        else
            print("Unknown expansion for ALL_CLASSES")
            return 1503
        end
    end)(),

    NONE = 0,
    WARRIOR = 1,
    PALADIN = 2,
    HUNTER = 4,
    ROGUE = 8,
    PRIEST = 16,
    DEATH_KNIGHT = 32,
    SHAMAN = 64,
    MAGE = 128,
    WARLOCK = 256,
    MONK = 512,
    DRUID = 1024
}

-- Questie-owned semantic constants retained independently of provider schema metadata.
QuestieDB.factionIDs = {
    BOOTY_BAY = 21,
    IRONFORGE = 47,
    GNOMEREGAN_EXILES = 54,
    THORIUM_BROTHERHOOD = 59,
    HORDE = 67,
    UNDERCITY = 68,
    DARNASSUS = 69,
    SYNDICATE = 70,
    STORMWIND = 72,
    ORGRIMMAR = 76,
    THUNDER_BLUFF = 81,
    BLOODSAIL_BUCCANEERS = 87,
    GELKIS_CLAN_CENTAUR = 92,
    MAGRAM_CLAN_CENTAUR = 93,
    STEAMWHEEDLE_CARTEL = 169,
    ZANDALAR_TRIBE = 270,
    RAVENHOLDT = 349,
    GADGETZAN = 369,
    ALLIANCE = 469,
    RATCHET = 470,
    THE_LEAGUE_OF_ARATHOR = 509,
    THE_DEFILERS = 510,
    ARGENT_DAWN = 529,
    DARKSPEAR_TROLLS = 530,
    TIMBERMAW_HOLD = 576,
    EVERLOOK = 577,
    WINTERSABER_TRAINERS = 589,
    CENARION_CIRCLE = 609,
    FROSTWOLF_CLAN = 729,
    STORMPIKE_GUARD = 730,
    HYDRAXIAN_WATERLORDS = 749,
    SHEN_DRALAR = 809,
    WARSONG_OUTRIDERS = 889,
    SILVERWING_SENTINELS = 890,
    ALLIANCE_FORCES = 891,
    HORDE_FORCES = 892,
    DARKMOON_FAIRE = 909,
    BROOD_OF_NOZDORMU = 910,
    SILVERMOON_CITY = 911,
    TRANQUILLIEN = 922,
    EXODAR = 930,
    THE_ALDOR = 932,
    THE_CONSORTIUM = 933,
    THE_SCRYERS = 934,
    THE_SHATAR = 935,
    SHATTRATH_CITY = 936,
    THE_MAGHAR = 941,
    CENARION_EXPEDITION = 942,
    HONOR_HOLD = 946,
    THRALLMAR = 947,
    THE_VIOLET_EYE = 967,
    SPOREGGAR = 970,
    KURENAI = 978,
    THE_BURNING_CRUSADE = 980,
    KEEPERS_OF_TIME = 989,
    THE_SCALE_OF_THE_SANDS = 990,
    LOWER_CITY = 1011,
    ASHTONGUE_DEATHSWORN = 1012,
    NETHERWING = 1015,
    SHATARI_SKYGUARD = 1031,
    ALLIANCE_VANGUARD = 1037,
    OGRILA = 1038,
    VALIANCE_EXPEDITION = 1050,
    HORDE_EXPEDITION = 1052,
    THE_TAUNKA = 1064,
    THE_HAND_OF_VENGEANCE = 1067,
    EXPLORERS_LEAGUE = 1068,
    THE_KALUAK = 1073,
    SHATTERED_SUN_OFFENSIVE = 1077,
    WARSONG_OFFENSIVE = 1085,
    KIRIN_TOR = 1090,
    THE_WYRMREST_ACCORD = 1091,
    THE_SILVER_COVENANT = 1094,
    WRATH_OF_THE_LICH_KING = 1097,
    KNIGHTS_OF_THE_EBON_BLADE = 1098,
    FRENZYHEART_TRIBE = 1104,
    THE_ORACLES = 1105,
    ARGENT_CRUSADE = 1106,
    SHOLAZAR_BASIN = 1117,
    THE_SONS_OF_HODIR = 1119,
    THE_SUNREAVERS = 1124,
    THE_FROSTBORN = 1126,
    BILGEWATER_CARTEL = 1133,
    GILNEAS = 1134,
    THE_EARTHEN_RING = 1135,
    THE_ASHEN_VERDICT = 1156,
    GUARDIANS_OF_HYJAL = 1158,
    THERAZANE = 1171,
    DRAGONMAW_CLAN = 1172,
    RAMKAHEN = 1173,
    WILDHAMMER_CLAN = 1174,
    BARADINS_WARDENS = 1177,
    HELLSCREAMS_REACH = 1178,
    AVENGERS_OF_HYJAL = 1204,
    SHANG_XIS_ACADEMY = 1216,
    FOREST_HOZEN = 1228,
    PEARLFIN_JINYU = 1242,
    GOLDEN_LOTUS = 1269,
    SHADO_PAN = 1270,
    ORDER_OF_THE_CLOUD_SERPENT = 1271,
    THE_TILLERS = 1272,
    JOGU_THE_DRUNK = 1273,
    ELLA = 1275,
    OLD_HILLPAW = 1276,
    CHEE_CHEE = 1277,
    SHO = 1278,
    HAOHAN_MUDCLAW = 1279,
    TINA_MUDCLAW = 1280,
    GINA_MUDCLAW = 1281,
    FISH_FELLREED = 1282,
    FARMER_FUNG = 1283,
    THE_ANGLERS = 1302,
    THE_KLAXXI = 1337,
    THE_AUGUST_CELESTIALS = 1341,
    THE_LOREWALKERS = 1345,
    THE_BREWMASTERS = 1351,
    HUOJIN_PANDAREN = 1352,
    TUSHUI_PANDAREN = 1353,
    NOMI = 1357, -- hidden faction
    NAT_PAGLE = 1358,
    THE_BLACK_PRINCE = 1359,
    BRAWLGAR_ARENA_SEASON_1 = 1374,
    DOMINANCE_OFFENSIVE = 1375,
    OPERATION_SHIELDWALL = 1376,
    KIRIN_TOR_OFFENSIVE = 1387,
    SUNREAVER_ONSLAUGHT = 1388,
    AKAMAS_TRUST = 1416,
    BIZMOS_BRAWLPUB_SEASON_1 = 1419,
    SHADO_PAN_ASSAULT = 1435,
    DARKSPEAR_REBELLION = 1440,
}


---@enum NpcFlags
QuestieDB.npcFlags = {
    NONE = 0,
    GOSSIP = 1,
    QUEST_GIVER = 2,
    VENDOR = Questie.IsClassic and 4 or 128,
    FLIGHT_MASTER = Questie.IsClassic and 8 or 8192,
    TRAINER = 16,
    SPIRIT_HEALER = Questie.IsClassic and 32 or 16384,
    SPIRIT_GUIDE = Questie.IsClassic and 64 or 32768,
    INNKEEPER = Questie.IsClassic and 128 or 65536,
    BANKER = Questie.IsClassic and 256 or 131072,
    PETITIONER = Questie.IsClassic and 512 or 262144,
    TABARD_DESIGNER = Questie.IsClassic and 1024 or 524288,
    BATTLEMASTER = Questie.IsClassic and 2048 or 1048576,
    AUCTIONEER = Questie.IsClassic and 4096 or 2097152,
    STABLEMASTER = Questie.IsClassic and 8192 or 4194304,
    REPAIR = Questie.IsClassic and 16384 or 4096,
    BARBER = (Expansions.Current >= Expansions.Wotlk) and 33554432 or nil,
    ARCANE_REFORGER = Expansions.Current >= Expansions.Cata and 134217728 or nil,
    TRANSMOGRIFIER = Expansions.Current >= Expansions.Cata and 268435456 or nil,
}

QuestieDB.itemClasses = {
    QUEST = 12,
}


_QuestieDB.questCache = {}; -- stores quest objects so they dont need to be regenerated
_QuestieDB.itemCache = {};
_QuestieDB.npcCache = {};
_QuestieDB.objectCache = {};
_QuestieDB.zoneCache = {};

---A Memoized table for function Quest:CheckRace
---
---Usage: checkRace[requiredRaces]
---@type table<number, boolean>
local checkRace
---A Memoized table for function Quest:CheckClass
---
---Usage: checkRace[requiredClasses]
---@type table<number, boolean>
local checkClass

---QuestieCorrections.hiddenQuests
local QuestieCorrectionshiddenQuests
---Questie.db.char.hidden
local Questiedbcharhidden

QuestieDB.activeChildQuests = {}

---@type table<QuestId, table<string, table>> Creature levels per Quest, rebuilt from composed NPC reads.
QuestieDB._CreatureLevelCache = {}

-- QuestieTDB owns Objective Order. `Initialize` rebinds these to `LibQuestieDB.ObjectiveFirst`
-- before any rich Quest projection runs; the empty tables only cover reads before Login Initialization.
QuestieDB.killCreditObjectiveFirst = {}
QuestieDB.objectObjectiveFirst = {}
QuestieDB.itemObjectiveFirst = {}
QuestieDB.eventObjectiveFirst = {}
QuestieDB.spellObjectiveFirst = {}

---True once query bindings, ID maps, Objective Order, and caches are ready. Correction applies
---after this point refresh through `RefreshAfterCorrectionApply`; the initial apply needs no
---refresh because `Initialize` binds the composed view that exists at that moment.
QuestieDB.IsInitialized = false

---Rebinds the composed ID maps. QuestieTDB replaces these shared read-only maps on every
---Correction apply, so a retained reference can hide an added entity or keep a withdrawn one.
---@return nil
local function _BindEntityIdMaps()
    QuestieDB.QuestPointers = LibQuestieDB.Quest.GetAllIds(true)
    QuestieDB.NPCPointers = LibQuestieDB.Npc.GetAllIds(true)
    QuestieDB.ItemPointers = LibQuestieDB.Item.GetAllIds(true)
    QuestieDB.ObjectPointers = LibQuestieDB.Object.GetAllIds(true)
end

---Drops the Questie-owned projection caches fed by composed NPC, Item, and Object rows. QuestieTDB
---invalidates its own read caches but cannot see these.
---
---Quest objects are deliberately kept. The quest lifecycle stores the object `GetQuest` returned in
---`QuestiePlayer.currentQuestlog`, the tracker, and map icons, and updates it in place, so handing
---out a replacement object would split that state. No post-initialization apply changes Quest rows
---today; a future Quest-row setter must invalidate specific quest IDs through the lifecycle.
---@return nil
local function _ClearEntityCaches()
    _QuestieDB.itemCache = {}
    _QuestieDB.npcCache = {}
    _QuestieDB.objectCache = {}
    _QuestieDB.zoneCache = {}
    QuestieDB._CreatureLevelCache = {}
end

---Binds QuestieDB to LibQuestieDB during Login Initialization. It runs after the provider locale
---is forwarded and after Questie's initial Policy Correction apply, so the first bound view is
---already composed.
---@return nil
function QuestieDB.Initialize()
    QuestieDB.IsInitialized = false
    _QuestieDB.InitializeQuestTagInfoCorrections()

    -- Query bindings keep the provider's plain-function (dot-call) shape.
    QuestieDB.QueryQuestSingle = LibQuestieDB.Quest.Get
    QuestieDB.QueryNPCSingle = LibQuestieDB.Npc.Get
    QuestieDB.QueryItemSingle = LibQuestieDB.Item.Get
    QuestieDB.QueryObjectSingle = LibQuestieDB.Object.Get
    QuestieDB.QueryQuest = LibQuestieDB.Quest.GetAll
    QuestieDB.QueryNPC = LibQuestieDB.Npc.GetAll
    QuestieDB.QueryItem = LibQuestieDB.Item.GetAll
    QuestieDB.QueryObject = LibQuestieDB.Object.GetAll

    -- Objective Order hints are provider tables that consumers must not mutate.
    QuestieDB.killCreditObjectiveFirst = LibQuestieDB.ObjectiveFirst.killCreditObjectiveFirst
    QuestieDB.objectObjectiveFirst = LibQuestieDB.ObjectiveFirst.objectObjectiveFirst
    QuestieDB.itemObjectiveFirst = LibQuestieDB.ObjectiveFirst.itemObjectiveFirst
    QuestieDB.eventObjectiveFirst = LibQuestieDB.ObjectiveFirst.eventObjectiveFirst
    QuestieDB.spellObjectiveFirst = LibQuestieDB.ObjectiveFirst.spellObjectiveFirst

    _BindEntityIdMaps()
    -- Anything that reached the API before Login Initialization saw an uncorrected view. No quest
    -- lifecycle state exists yet, so quest objects are dropped along with the entity caches.
    _QuestieDB.questCache = {}
    _ClearEntityCaches()

    checkRace = QuestieLib:TableMemoizeFunction(QuestiePlayer.HasRequiredRace)
    checkClass = QuestieLib:TableMemoizeFunction(QuestiePlayer.HasRequiredClass)
    QuestieCorrectionshiddenQuests = QuestieCorrections.hiddenQuests
    Questiedbcharhidden = Questie.db.char.hidden

    QuestieDB.IsInitialized = true
end

---Refreshes Questie's view after a post-initialization Correction apply: rebinds the four ID
---maps and clears the entity caches while keeping quest objects. `QuestieCorrections` calls this
---from its shared apply path.
---@return nil
function QuestieDB.RefreshAfterCorrectionApply()
    _BindEntityIdMaps()
    _ClearEntityCaches()
end

---@param objectId ObjectId
---@return Object|nil
function QuestieDB:GetObject(objectId)
    if not objectId then
        return nil
    end
    if _QuestieDB.objectCache[objectId] then
        return _QuestieDB.objectCache[objectId];
    end

    local rawdata = QuestieDB.QueryObject(objectId, QuestieDB._objectAdapterQueryOrder)

    if not rawdata then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetObject] rawdata is nil for objectID:", objectId)
        return nil
    end

    local obj = {
        id = objectId,
        type = "object"
    }

    for stringKey, intKey in pairs(QuestieDB.objectKeys) do
        obj[stringKey] = rawdata[intKey]
    end
    --_QuestieDB.objectCache[objectId] = obj;
    return obj;
end

---@param itemId ItemId
---@return Item|nil
function QuestieDB:GetItem(itemId)
    if (not itemId) or (itemId == 0) then
        return nil
    end
    if _QuestieDB.itemCache[itemId] then
        return _QuestieDB.itemCache[itemId];
    end

    local rawdata = QuestieDB.QueryItem(itemId, QuestieDB._itemAdapterQueryOrder)

    if not rawdata then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetItem] rawdata is nil for itemID:", itemId)
        return nil
    end

    local item = {
        Id = itemId,
        Sources = {},
        Hidden = QuestieCorrections.questItemBlacklist[itemId]
    }

    for stringKey, intKey in pairs(QuestieDB.itemKeys) do
        item[stringKey] = rawdata[intKey]
    end

    local sources = item.Sources

    if rawdata[QuestieDB.itemKeys.npcDrops] then
        for _, npcId in pairs(rawdata[QuestieDB.itemKeys.npcDrops]) do
            sources[#sources + 1] = {
                Id = npcId,
                Type = "monster",
            }
        end
    end

    if rawdata[QuestieDB.itemKeys.vendors] then
        for _, npcId in pairs(rawdata[QuestieDB.itemKeys.vendors]) do
            local friendlyToFaction = QuestieDB.QueryNPCSingle(npcId, "friendlyToFaction")
            local isFriendlyToPlayer = QuestieDB.IsFriendlyToPlayer(friendlyToFaction)
            if isFriendlyToPlayer then
                -- We don't want to show vendors from the opposite faction
                sources[#sources + 1] = {
                    Id = npcId,
                    Type = "monster",
                }
            end
        end
    end

    if rawdata[QuestieDB.itemKeys.objectDrops] then
        for _, v in pairs(rawdata[QuestieDB.itemKeys.objectDrops]) do
            sources[#sources + 1] = {
                Id = v,
                Type = "object",
            }
        end
    end

    return item
end

---@param itemId ItemId
---@param npcId NpcId
---@return table<number, string>?
function QuestieDB.GetItemDroprate(itemId, npcId)
     if not DropDB or not DropDB.GetItemDroprate then
         Questie.Debug(Questie.DEBUG_CRITICAL, "ItemDrops: DropDB not available")
         return nil
     end
     return DropDB.GetItemDroprate(itemId, npcId)
end

---@param questId number
---@return boolean
function QuestieDB.IsRepeatable(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "specialFlags")
    return flags and bitband(flags, 1) ~= 0
end

---@param questId number
---@return boolean
function QuestieDB.IsDailyQuest(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "questFlags")
    -- test a bit flag: (value % (2*flag) >= flag)
    return flags and (flags % QUEST_FLAGS_DAILY_X2) >= QUEST_FLAGS_DAILY
end

---@param questId number
---@return boolean
function QuestieDB.IsWeeklyQuest(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "questFlags")
    -- test a bit flag: (value % (2*flag) >= flag)
    return flags and (flags % QUEST_FLAGS_WEEKLY_X2) >= QUEST_FLAGS_WEEKLY
end

---@param questId number
---@return boolean
function QuestieDB.IsMonthlyQuest(questId)
    local flags = QuestieDB.QueryQuestSingle(questId, "questFlags")
    -- test a bit flag: (value % (2*flag) >= flag)
    return flags and (flags % QUEST_FLAGS_MONTHLY_X2) >= QUEST_FLAGS_MONTHLY
end

---@param questId number
---@return boolean
function QuestieDB.IsCelestialQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.CELESTIAL
end

---@param questId number
---@return boolean
function QuestieDB.IsAccountQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.ACCOUNT
end

---@param questId number
---@return boolean
function QuestieDB.IsScenarioQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.SCENARIO
end

---@param questId number
---@return boolean
function QuestieDB.IsHeroicQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.HEROIC
end

---@param questId number
---@return boolean
function QuestieDB.IsLegendaryQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.LEGENDARY
end

---@param questId number
---@return boolean
function QuestieDB.IsDungeonQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.DUNGEON
end

---@param questId number
---@return boolean
function QuestieDB.IsRaidQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.RAID or questTagId == QuestieDB.questTagIds.RAID_10 or questTagId == QuestieDB.questTagIds.RAID_25
end

---@param questId number
---@return boolean
function QuestieDB.IsPvPQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.PVP
end

---@param questId number
---@return boolean
function QuestieDB.IsGroupQuest(questId)
    local questTagId, _ = QuestieDB.GetQuestTagInfo(questId)
    return questTagId == QuestieDB.questTagIds.ELITE
end

--[[ Commented out because not used anywhere
---@param questId number
---@return boolean
function QuestieDB:IsAQWarEffortQuest(questId)
    return QuestieQuestBlacklist.AQWarEffortQuests[questId]
end
]]--

---@param class string
---@return number
function QuestieDB:GetZoneOrSortForClass(class)
    return QuestieDB.sortKeys[class]
end

local questTagInfoCache = {}

--- Wrapper function for the GetQuestTagInfo API to correct
--- quests that are falsely marked by Blizzard and cache the results.
---@param questId number
---@return number|nil questTagId
---@return string|nil questTagName
function QuestieDB.GetQuestTagInfo(questId)
    if questTagInfoCache[questId] then
        return questTagInfoCache[questId][1], questTagInfoCache[questId][2]
    end

    local questTagCorrections = _QuestieDB.questTagCorrections
    local questTagId, questTagName
    if questTagCorrections[questId] then
        questTagId, questTagName = questTagCorrections[questId][1], questTagCorrections[questId][2]
    else
        questTagId, questTagName = GetQuestTagInfo(questId)

        if questTagId == nil and questTagName == nil then
            -- Retry the API call after a short delay, as the API tends to incorrectly return nil on the first call.
            -- Doing it here asserts, we only call the API twice per quest at most.
            C_Timer.After(1, function()
                local retryQuestTagId, retryQuestTagName = GetQuestTagInfo(questId)
                questTagInfoCache[questId] = {retryQuestTagId, retryQuestTagName}
            end)
        end
    end

    -- cache the result to avoid hitting the API throttling limit
    questTagInfoCache[questId] = {questTagId, questTagName}

    return questTagId, questTagName
end

---@param questId number
---@return boolean
function QuestieDB.IsActiveEventQuest(questId)
    --! If you edit the logic here, also edit in AvailableQuests.IsLevelRequirementsFulfilled
    return QuestieEvent.activeQuests[questId] == true
end

---@param exclusiveTo table<number, number>
---@return boolean
function QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)
    if (not exclusiveTo) then
        return false
    end

    for _, exId in pairs(exclusiveTo) do
        if Questie.db.char.complete[exId] or QuestiePlayer.currentQuestlog[exId] then
            return true
        end
    end
    return false
end

---@param preQuestGroup table<number, number>
---@return boolean
function QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
    if (not preQuestGroup) or (not next(preQuestGroup)) then
        return true
    end
    for preQuestIndex=1, #preQuestGroup do
        local preQuestId = preQuestGroup[preQuestIndex]
        if preQuestId < 0 then
            -- Negative entries in preQuestGroup skip the exclusiveTo check
            if (not Questie.db.char.complete[-preQuestId]) then
                return false
            end
        -- If a quest is not complete and no exclusive quest is complete, the requirement is not fulfilled
        elseif not Questie.db.char.complete[preQuestId] then
            local preQuest = QuestieDB.QueryQuestSingle(preQuestId, "exclusiveTo")
            if (not preQuest) then
                return false
            end

            local anyExclusiveFinished = false
            for i=1, #preQuest do
                if Questie.db.char.complete[preQuest[i]] then
                    anyExclusiveFinished = true
                end
            end
            if not anyExclusiveFinished then
                return false
            end
        end
    end
    -- All preQuests are complete
    return true
end

---@param preQuestSingle number[]
---@return boolean
function QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
    if (not preQuestSingle) or (not next(preQuestSingle)) then
        return true
    end
    for preQuestIndex=1, #preQuestSingle do
        -- If a quest is complete the requirement is fulfilled
        if Questie.db.char.complete[preQuestSingle[preQuestIndex]] then
            return true
        end
    end
    -- No preQuest is complete
    return false
end

---@param questId number
---@param debugPrint boolean? -- if true, IsDoable will print conclusions to debug channel
---@return boolean
function QuestieDB.IsDoable(questId, debugPrint)

    --!  Before changing any logic in QuestieDB.IsDoable, make sure
    --!  to mirror the same logic to QuestieDB.IsDoableVerbose!

    -- IsDoable determines if the player is currently eligible for
    -- a quest, and returns that result as true/false in order to
    -- programmatically show/hide quests and determine further logic.

    -- IsDoableVerbose does the same logic, but returns human-readable
    -- explanations as a string for display in the UI.

    -- These functions are maintained separately for performance,
    -- because IsDoable is often called in a loop through every
    -- quest in the DB in order to update icons, while
    -- IsDoableVerbose is only called manually by the user.

    local completedQuests = Questie.db.char.complete
    local currentQuestlog = QuestiePlayer.currentQuestlog

    -- These are localized in the init function
    if completedQuests[questId] then
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is already finished!") end
        return false
    end

    -- Blacklisted quests
    if QuestieCorrectionshiddenQuests[questId] then
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is hidden automatically!") end
        return false
    end

    -- Only present in IsDoable, not IsDoableVerbose
    if Questiedbcharhidden[questId] then
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is hidden manually!") end
        return false
    end

    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")
    if (requiredRaces and not checkRace[requiredRaces]) then
        QuestieDB.autoBlacklist[questId] = "race"
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Race requirement not fulfilled for quest " .. questId) end
        return false
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle then
        local isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
        if not isPreQuestSingleFulfilled then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Pre-quest requirement not fulfilled for quest " .. questId) end
            return false
        end
    end

    local requiredClasses = QuestieDB.QueryQuestSingle(questId, "requiredClasses")
    if (requiredClasses and not checkClass[requiredClasses]) then
        QuestieDB.autoBlacklist[questId] = "class"
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Class requirement not fulfilled for quest " .. questId) end
        return false
    end

    local requiredMinRep = QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    local requiredMaxRep = QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")
    if (requiredMinRep or requiredMaxRep) then
        local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)
        if (not ((aboveMinRep and hasMinFaction) and (belowMaxRep and hasMaxFaction))) then
            --- If we haven't got the faction for min or max we blacklist it
            if not (aboveMinRep and belowMaxRep) then
                QuestieDB.autoBlacklist[questId] = "rep"
            end

            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet reputation requirements for quest " .. questId) end
            return false
        end
    end

    local requiredSkill = QuestieDB.QueryQuestSingle(questId, "requiredSkill")
    if (requiredSkill) then
        local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
        if (not (hasProfession and hasSkillLevel)) then
            --? We haven't got the profession so we blacklist it.
            if(not hasProfession) then
                QuestieDB.autoBlacklist[questId] = "skill"
            end

            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet profession requirements for quest " .. questId) end
            return false
        end
    end

    local requiredRanks = QuestieDB.QueryQuestSingle(questId, "requiredRanks")
    if (requiredRanks) then
        local hasProfession, hasRankLevel, hasNegativeRanks = QuestieProfessions:HasProfessionAndRankLevel(requiredRanks)
        if (not hasNegativeRanks) then
            if (not (hasProfession and hasRankLevel)) then
                --? We haven't got the profession so we blacklist it.
                if (not hasProfession) then
                    QuestieDB.autoBlacklist[questId] = "rank"
                end

                if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not have profession rank for quest " .. questId) end
                return false
            end
        else
            if hasProfession and not hasRankLevel then
                -- We have the exact profession and rank so we blacklist it.
                QuestieDB.autoBlacklist[questId] = "rank"

                if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player has the wrong profession rank for quest " .. questId) end
                return false
            end
        end
    end

    --? preQuestGroup and preQuestSingle are mutualy exclusive to eachother and preQuestSingle is more prevalent
    --? Only try group if single does not exist.
    if not preQuestSingle then
        -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
        local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
        if preQuestGroup then
            local isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
            if not isPreQuestGroupFulfilled then
                if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Group pre-quest requirement not fulfilled for quest " .. questId) end
                return false
            end
        end
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest and parentQuest ~= 0 then
        if not currentQuestlog[parentQuest] then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " has an inactive parent quest") end
            return false
        end
    end

    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    if nextQuestInChain and nextQuestInChain ~= 0 then
        if completedQuests[nextQuestInChain] or currentQuestlog[nextQuestInChain] then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Follow up quests already completed or in the quest log for quest " .. questId) end
            return false
        end
    end

    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    local ExclusiveQuestGroup = QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
    if ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for _, v in pairs(ExclusiveQuestGroup) do
            if completedQuests[v] or currentQuestlog[v] then
                if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player has completed a quest exclusive with quest " .. questId) end
                return false
            end
        end
    end

    local requiredSpecialization = QuestieDB.QueryQuestSingle(questId, "requiredSpecialization")
    if (requiredSpecialization) and (requiredSpecialization > 0) then
        local hasSpecialization = QuestieProfessions.HasSpecialization(requiredSpecialization)
        if (not hasSpecialization) then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet profession specialization requirements for quest " .. questId) end
            return false
        end
    end

    local requiredSpell = QuestieDB.QueryQuestSingle(questId, "requiredSpell")
    if (requiredSpell) and (requiredSpell ~= 0) then
        local hasSpellorProfSpell = QuestieCompat.IsSpellKnown(math.abs(requiredSpell))
        if (requiredSpell > 0) and (not hasSpellorProfSpell) then -- if requiredSpell is positive, we make the quest unavailable if the player does NOT have the spell
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet learned spell requirements for quest " .. questId) end
            return false
        elseif (requiredSpell < 0) and (hasSpellorProfSpell) then -- if requiredSpell is negative, we make the quest unavailable if the player DOES have the spell
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet not learned spell requirements for quest " .. questId) end
            return false
        end
    end

    -- Check and see if the Quest requires an achievement before showing as available
    if _QuestieDB:CheckAchievementRequirements(questId) == false then
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet achievement requirements for quest " .. questId) end
        return false
    end

    -- Check if this quest is a breadcrumb
    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(questId, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
        -- Check the target quest of this breadcrumb
        if completedQuests[breadcrumbForQuestId] or currentQuestlog[breadcrumbForQuestId] then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Target of breadcrumb quest already completed or in the quest log for quest " .. questId) end
            return false
        end
        -- The next case is commented out since it's not a valid check to have. Breadcrumbs to the same quest are not always exclusive to eachother
        --[[ Check if the other breadcrumbs are active
        local otherBreadcrumbs = QuestieDB.QueryQuestSingle(breadcrumbForQuestId, "breadcrumbs")
        for _, breadcrumbId in ipairs(otherBreadcrumbs or {}) do -- TODO: Remove `or {}` when we have a validation for the breadcrumb data
            if breadcrumbId ~= questId and currentQuestlog[breadcrumbId] then
                if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Alternative breadcrumb quest in the quest log for quest " .. questId) end
                return false
            end
        end]]
    end

    -- Check if this quest has active breadcrumbs
    local breadcrumbs = QuestieDB.QueryQuestSingle(questId, "breadcrumbs")
    if breadcrumbs then
        for _, breadcrumbId in ipairs(breadcrumbs) do
            if QuestiePlayer.currentQuestlog[breadcrumbId] then
                if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Breadcrumb quest " .. breadcrumbId .. " in the quest log for quest " .. questId) end
                return false
            end
        end
    end

    -- Check if this quest has a quest that disables it while in quest log
    local disabledByQuest = QuestieDB.QueryQuestSingle(questId, "disabledByQuest")
    if disabledByQuest and disabledByQuest ~= 0 then
        -- Check the disabling quest is active
        if QuestiePlayer.currentQuestlog[disabledByQuest] then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Disabling quest " .. disabledByQuest .. " in the quest log for quest " .. questId) end
            return false
        end
    end

    -- Check if this quest is not detected as active from the NPC/object itself
    if DailyQuests.ShouldBeHidden(questId, completedQuests, currentQuestlog) then
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Daily quest " .. questId .. " is not active") end
        return false
    end

    -- Check if this quest is visible until you turn in a certain quest
    local availableUntilCompleted = QuestieDB.QueryQuestSingle(questId, "availableUntilCompleted")
    if availableUntilCompleted and availableUntilCompleted ~= 0 then
        if completedQuests[availableUntilCompleted] then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is not available because " .. availableUntilCompleted .. " has been turned in!") end
            return false
        end
    end

    -- Check if this quest is visible if you have a certain quest in log or turned in (slightly different to preQuestSingle)
    -- In order to not mess with the existing logic for preQuestSingle, this field must be accompanied by preQuestSingle
    local availableStartingWith = QuestieDB.QueryQuestSingle(questId, "availableStartingWith")
    if availableStartingWith and availableStartingWith ~= 0 then
        if not completedQuests[availableStartingWith] and not currentQuestlog[availableStartingWith] then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Quest " .. questId .. " is not available because " .. availableStartingWith .. " is not active/turned in!") end
            return false
        end
    end

    -- Invasion quests (Naxxramas launch on Era and Wotlk prepatch)
    if not ContentPhases.IsInvasionActive[Expansions.Current] and QuestieQuestBlacklist.InvasionQuests[questId] then
        if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Invasion event quest " .. questId .. " is not active") end
        return false
    end

    -- Check if this is one of those arena rating quests
    -- Quests only present in TBC and only these IDs
    if Expansions.Current == Expansions.Tbc and (questId == 95158 or questId == 95251 or questId == 95252) then
        if not QuestiePlayer.HasArenaRating(questId) then
            if debugPrint then Questie.Debug(Questie.DEBUG_SPAM, "[QuestieDB.IsDoable] Player does not meet arena rating requirements for quest " .. questId) end
            return false
        end
    end

    return true
end

---@param questId number
---@param debugPrint boolean? -- if true, IsDoable will print conclusions to debug channel
---@param returnText boolean? -- if true, IsDoable will return plaintext explanation instead of true/false
---@param returnBrief boolean? -- if true and returnText is true, IsDoable will return a very brief explanation instead of a verbose one
---@return string, boolean, number -- the eligibility text; we use the boolean value to decide if we want to show the "Doable:" label, returns number for reason which we use in QBZ/QBF
function QuestieDB.IsDoableVerbose(questId, debugPrint, returnText, returnBrief)

    --!  Before changing any logic in QuestieDB.IsDoable, make sure
    --!  to mirror the same logic to QuestieDB.IsDoableVerbose!

    -- IsDoable determines if the player is currently eligible for
    -- a quest, and returns that result as true/false in order to
    -- programmatically show/hide quests and determine further logic.

    -- IsDoableVerbose does the same logic, but returns human-readable
    -- explanations as a string for display in the UI.

    -- These functions are maintained separately for performance,
    -- because IsDoable is often called in a loop through every
    -- quest in the DB in order to update icons, while
    -- IsDoableVerbose is only called manually by the user.

    local completedQuests = Questie.db.char.complete
    local currentQuestlog = QuestiePlayer.currentQuestlog
    local DoableStates = QuestieDB.DoableStates
    local HIDE_ON_MAP = QuestieQuestBlacklist.HIDE_ON_MAP

    -- Completed quests
    if completedQuests[questId] then
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Already complete"), false, DoableStates.COMPLETED -- we return false here as we don't want to show it as label when completed in QBZ/QBF
        elseif returnText then
            return "Player has already completed quest " .. questId .. "!", false, DoableStates.COMPLETED
        end
    end

    -- The player has this quest in the quest log
    if C_QuestLog.IsOnQuest(questId) == true then
        local msg = "Quest " .. questId .. " is active"
        if returnText and returnBrief then
            return l10n("Available")..l10n(": ")..l10n("Player is on quest"), false, DoableStates.QUEST_LOG
        elseif returnText and not returnBrief then
            return msg, false, DoableStates.QUEST_LOG
        end
    end

    -- Automatically blacklisted quests by Questie. These are localized in the init function
    if QuestieCorrectionshiddenQuests[questId] and QuestieCorrectionshiddenQuests[questId] ~= HIDE_ON_MAP then
        local msg = "Quest " .. questId .. " is hidden automatically"
        local msgevent = "Quest " .. questId .. " is unavailable because the world event is inactive"
        if QuestieEvent.IsEventQuest(questId) and not QuestieEvent.IsEventActiveForQuest(questId) then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Event inactive"), true, DoableStates.EVENT_INACTIVE
            elseif returnText and not returnBrief then
                return msgevent, true, DoableStates.EVENT_INACTIVE
            end
        end
        if returnText and returnBrief then
            return l10n("Unknown")..l10n(": ")..l10n("Automatically blacklisted"), true, DoableStates.BLACKLISTED
        elseif returnText and not returnBrief then
            return msg, true, DoableStates.BLACKLISTED
        end
    end

    -- AQ War Effort quests (one-time world event that has ended for all realms)
    if (not Questie.IsSoD) and QuestieQuestBlacklist.AQWarEffortQuests[questId] then
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Event inactive"), true, DoableStates.EVENT_INACTIVE
        elseif returnText then
            return "AQ event quest " .. questId .. " is not active", true, DoableStates.EVENT_INACTIVE
        end
    end

    -- Invasion quests (Naxxramas launch on Era and Wotlk prepatch)
    if not ContentPhases.IsInvasionActive[Expansions.Current] and QuestieQuestBlacklist.InvasionQuests[questId] then
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Event inactive"), true, DoableStates.EVENT_INACTIVE
        elseif returnText then
            return "Invasion event quest " .. questId .. " is not active", true, DoableStates.EVENT_INACTIVE
        end
    end

    -- Check character race
    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")
    if (requiredRaces and not checkRace[requiredRaces]) then
        local requirementLabel = "Race requirement"
        if requiredRaces == QuestieDB.raceKeys.ALL_ALLIANCE or requiredRaces == QuestieDB.raceKeys.ALL_HORDE then
            requirementLabel = "Faction requirement"
        end
        local msg = requirementLabel .. " not fulfilled for quest " .. questId
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n(requirementLabel), true, DoableStates.WRONG_RACE
        elseif returnText and not returnBrief then
            return msg, true, DoableStates.WRONG_RACE
        end
    end

    -- Check character class
    local requiredClasses = QuestieDB.QueryQuestSingle(questId, "requiredClasses")
    if (requiredClasses and not checkClass[requiredClasses]) then
        QuestieDB.autoBlacklist[questId] = "class"
        local msg = "Class requirement not fulfilled for quest " .. questId
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Class requirement"), true, DoableStates.WRONG_CLASS
        elseif returnText and not returnBrief then
            return msg, true, DoableStates.WRONG_CLASS
        end
    end

    -- We keep this here, even though it is removed from QuestieDB.IsDoable because AvailableQuests.CalculateAndDrawAll
    -- checks child quests differently and before IsDoable
    if QuestieDB.activeChildQuests[questId] then -- The parent quest is active, so this quest is doable
        local msg = "Quest " .. questId .. " is available because it's a child quest, the parent is active and conditions are met"
        if returnText and returnBrief then
            return l10n("Available")..l10n(": ")..l10n("Parent active"), false, DoableStates.PARENT_ACTIVE
        elseif returnText and not returnBrief then
            return msg, false, DoableStates.PARENT_ACTIVE
        end
    end

    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    local ExclusiveQuestGroup = QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
    if ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for _, v in pairs(ExclusiveQuestGroup) do
            if completedQuests[v] then
                local msg = "Quest " .. questId .. " is unavailable because exclusive quest " .. v .. " is completed"
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("Exclusive quest completed"), true, DoableStates.EXCLUSIVE_COMPLETED
                elseif returnText and not returnBrief then
                    return msg, true, DoableStates.EXCLUSIVE_COMPLETED
                end
            elseif currentQuestlog[v] then
                local msg = "Quest " .. questId .. " is unavailable because exclusive quest " .. v .. " is in the quest log"
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("Exclusive quest in quest log"), true, DoableStates.EXCLUSIVE_IN_QUEST_LOG
                elseif returnText and not returnBrief then
                    return msg, true, DoableStates.EXCLUSIVE_IN_QUEST_LOG
                end
            end
        end
    end

    -- Check profession requirements
    local requiredSkill = QuestieDB.QueryQuestSingle(questId, "requiredSkill")
    local requiredRanks = QuestieDB.QueryQuestSingle(questId, "requiredRanks")
    -- Until then these two should be mutually exclusive
    -- TODO: if we find a quest that has both requiredSkill and requiredRanks we need to be able to return correct message
    if (requiredSkill) then
        local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
        if not hasProfession then
            local msg = "Profession missing for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Profession missing"), true, DoableStates.PROFESSION_MISSING
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.PROFESSION_MISSING
            end
        elseif not hasSkillLevel then
            local msg = "Player does not have required profession skill for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Profession skill"), true, DoableStates.PROFESSION_SKILL
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.PROFESSION_SKILL
            end
        end
    end
    if (requiredRanks) then
        local hasProfession, hasRankLevel, hasNegativeRanks = QuestieProfessions:HasProfessionAndRankLevel(requiredRanks)
        if not hasNegativeRanks then
            if not hasProfession then
                local msg = "Profession missing for quest " .. questId
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("Profession missing"), true, DoableStates.PROFESSION_MISSING
                elseif returnText and not returnBrief then
                    return msg, true, DoableStates.PROFESSION_MISSING
                end
            elseif not hasRankLevel then
                local msg = "Player does not have required profession rank for quest " .. questId
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("Profession rank"), true, DoableStates.PROFESSION_RANK
                elseif returnText and not returnBrief then
                    return msg, true, DoableStates.PROFESSION_RANK
                end
            end
        else
            if hasProfession and not hasRankLevel then
                local msg = "Player has the wrong profession rank for quest " .. questId
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("Profession rank"), true, DoableStates.PROFESSION_RANK
                elseif returnText and not returnBrief then
                    return msg, true, DoableStates.PROFESSION_RANK
                end
            end
        end
    end

    -- Check profession specialization requirements
    local requiredSpecialization = QuestieDB.QueryQuestSingle(questId, "requiredSpecialization")
    if (requiredSpecialization) and (requiredSpecialization > 0) then
        local hasSpecialization = QuestieProfessions.HasSpecialization(requiredSpecialization)
        if (not hasSpecialization) then
            local msg = "Player does not meet profession specialization requirements for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Profession specialization requirement"), true, DoableStates.PROFESSION_SPECIALIZATION
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.PROFESSION_SPECIALIZATION
            end
        end
    end

    -- Check if the character is higher than the quest allows
    local requiredMaxLevel = QuestieDB.QueryQuestSingle(questId, "requiredMaxLevel")
    if (requiredMaxLevel and requiredMaxLevel ~= 0 and (UnitLevel("player") > requiredMaxLevel)) then
        local msg = "Player level is too high for quest " .. questId
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Level too high"), true, DoableStates.LEVEL_TOO_HIGH
        elseif returnText and not returnBrief then
            return msg, true, DoableStates.LEVEL_TOO_HIGH
        end
    end

    -- only present in verbose.
    -- IsDoable has its own logic that varies based on player settings for quest visibility
    local requiredLevel = QuestieDB.QueryQuestSingle(questId, "requiredLevel")
    if (requiredLevel and (UnitLevel("player") < requiredLevel)) then
        local msg = "Player level is too low for quest " .. questId
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Level too low"), true, DoableStates.LEVEL_TOO_LOW
        elseif returnText and not returnBrief then
            return msg, true, DoableStates.LEVEL_TOO_LOW
        end
    end

    -- Check if this quest is a breadcrumb
    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(questId, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
        -- Check the follow up quest of this breadcrumb
        if completedQuests[breadcrumbForQuestId] or currentQuestlog[breadcrumbForQuestId] then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Follow up quest active or completed"), true, DoableStates.BREADCRUMB_FOLLOWUP
            elseif returnText and not returnBrief then
                return "Follow up of breadcrumb quest " .. breadcrumbForQuestId .. " already completed or in the quest log for quest " .. questId, true, DoableStates.BREADCRUMB_FOLLOWUP
            end
        end
        -- The next case is commented out since it's not a valid check to have. Breadcrumbs to the same quest are not always exclusive to eachother
        --[[ Check if the other breadcrumbs are active
        local otherBreadcrumbs = QuestieDB.QueryQuestSingle(breadcrumbForQuestId, "breadcrumbs")
        for _, breadcrumbId in ipairs(otherBreadcrumbs or {}) do
            if breadcrumbId ~= questId and currentQuestlog[breadcrumbId] then
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("Another breadcrumb is active"), true, DoableStates.EXCLUSIVE_BREADCRUMB
                elseif returnText and not returnBrief then
                    return "Alternative breadcrumb quest " .. breadcrumbId .." in the quest log for quest " .. questId, true, DoableStates.EXCLUSIVE_BREADCRUMB
                end
            end
        end]]
    end

    -- Check reputation requirements
    local requiredMinRep = QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    local requiredMaxRep = QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")
    if (requiredMinRep or requiredMaxRep) then
        local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)
        -- Below reputation requirement
        if not (aboveMinRep and hasMinFaction) then

            local msg = "Reputation too low for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Reputation too low"), true, DoableStates.MISSING_REPUTATION
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.MISSING_REPUTATION
            end
        end
        -- Above reputation requirement
        if not (belowMaxRep and hasMaxFaction) then

            local msg = "Reputation too high for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Reputation too high"), true, DoableStates.EXCEED_REPUTATION
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.EXCEED_REPUTATION
            end
        end
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle then
        local isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
        if not isPreQuestSingleFulfilled then
            local msg = "Pre-quest requirement not fulfilled for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Incomplete pre-quest"), true, DoableStates.NO_PREQUESTSINGLE
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.NO_PREQUESTSINGLE
            end
        end
    end

    -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
    local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
    if preQuestGroup then
        local isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
        if not isPreQuestGroupFulfilled then
            local msg = "Group pre-quest requirement not fulfilled for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Incomplete pre-quest group"), true, DoableStates.NO_PREQUESTGROUP
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.NO_PREQUESTGROUP
            end
        end
    end

    -- Check parent quests
    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest and parentQuest ~= 0 then
        if not currentQuestlog[parentQuest] then
            local msg = "Quest " .. questId .. " has an inactive parent quest: " .. parentQuest
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Inactive parent"), true, DoableStates.PARENT_INACTIVE
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.PARENT_INACTIVE
            end
        end
    end

    -- Check if it has nextQuestInChain completed or in quest log
    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    if nextQuestInChain and nextQuestInChain ~= 0 then
        if completedQuests[nextQuestInChain] or currentQuestlog[nextQuestInChain] then
            local msg = "Follow up quest " .. nextQuestInChain .. " already completed or in the quest log for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Later quest completed or active"), true, DoableStates.NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED
            end
        end
    end

    -- Check spell requirements
    local requiredSpell = QuestieDB.QueryQuestSingle(questId, "requiredSpell")
    if (requiredSpell) and (requiredSpell ~= 0) then
        local hasSpellorProfSpell = QuestieCompat.IsSpellKnown(math.abs(requiredSpell))
        if (requiredSpell > 0) and (not hasSpellorProfSpell) then -- if requiredSpell is positive, we make the quest unavailable if the player does NOT have the spell
            local msg = "Player does not know spell ID: " .. math.abs(requiredSpell) .. " for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Spell not yet learned"), true, DoableStates.SPELL_MISSING
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.SPELL_MISSING
            end
        elseif (requiredSpell < 0) and (hasSpellorProfSpell) then -- if requiredSpell is negative, we make the quest unavailable if the player DOES have the spell
            local msg = "Player knows spell ID: " .. math.abs(requiredSpell) .. " for quest " .. questId
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Already learned spell"), true, DoableStates.SPELL_KNOWN
            elseif returnText and not returnBrief then
                return msg, true, DoableStates.SPELL_KNOWN
            end
        end
    end

    -- Check and see if the Quest requires an achievement before showing as available
    if _QuestieDB:CheckAchievementRequirements(questId) == false then
        local msg = "Player does not meet achievement requirements for quest " .. questId
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Achievement requirement"), true, DoableStates.MISSING_ACHIEVEMENT
        elseif returnText and not returnBrief then
            return msg, true, DoableStates.MISSING_ACHIEVEMENT
        end
    end

    -- Check if this quest has active breadcrumbs
    local breadcrumbs = QuestieDB.QueryQuestSingle(questId, "breadcrumbs")
    if breadcrumbs then
        for _, breadcrumbId in ipairs(breadcrumbs) do
            if currentQuestlog[breadcrumbId] then
                if returnText and returnBrief then
                    return l10n("Unavailable")..l10n(": ")..l10n("A breadcrumb is active"), true, DoableStates.BREADCRUMB_ACTIVE
                elseif returnText and not returnBrief then
                    return "A breadcrumb quest " .. breadcrumbId .." is in the quest log for quest " .. questId, true, DoableStates.BREADCRUMB_ACTIVE
                end
            end
        end
    end

    -- Check if this quest has a quest that disables it while in quest log
    local disabledByQuest = QuestieDB.QueryQuestSingle(questId, "disabledByQuest")
    if disabledByQuest and disabledByQuest ~= 0 then
        -- Check the disabling quest is active
        if currentQuestlog[disabledByQuest] then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Disabling quest is active"), true, DoableStates.DISABLED_BY
            elseif returnText and not returnBrief then
                return "Disabling quest " .. disabledByQuest .. " is in the quest log for quest " .. questId, true, DoableStates.DISABLED_BY
            end
        end
    end

    -- Daily quest not active (based on ShouldBeHidden)
    if DailyQuests.ShouldBeHidden(questId, completedQuests, currentQuestlog) then
        if returnText and returnBrief then
            return l10n("Unavailable")..l10n(": ")..l10n("Daily quest not active"), true, DoableStates.INACTIVE_DAILY
        elseif returnText then
            return "Daily quest " .. questId .. " is not active", true, DoableStates.INACTIVE_DAILY
        end
    end

    -- Check if this quest is visible until you turn in a certain quest
    local availableUntilCompleted = QuestieDB.QueryQuestSingle(questId, "availableUntilCompleted")
    if availableUntilCompleted and availableUntilCompleted ~= 0 then
        if completedQuests[availableUntilCompleted] then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Disabling quest already turned in"), true, DoableStates.DISABLING_QUEST_COMPLETED
            elseif returnText and not returnBrief then
                return "Quest " .. questId .. " is not available because " .. availableUntilCompleted .. " has been turned in", true, DoableStates.DISABLING_QUEST_COMPLETED
            end
        end
    end

    -- Check if this quest is visible if you have a certain quest in log or turned in (slightly different to preQuestSingle)
    local availableStartingWith = QuestieDB.QueryQuestSingle(questId, "availableStartingWith")
    if availableStartingWith and availableStartingWith ~= 0 then
        if not completedQuests[availableStartingWith] and not currentQuestlog[availableStartingWith] then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Enabling quest not active nor turned in"), true, DoableStates.ENABLING_QUEST_MISSING
            elseif returnText and not returnBrief then
                return "Quest " .. questId .. " is not available because " .. availableStartingWith .. " is not active/turned in", true, DoableStates.ENABLING_QUEST_MISSING
            end
        end
    end

    local unavailableQuestsDeterminedByTalking = Questie.db.global.unavailableQuestsDeterminedByTalking[serverName]
    for i, _ in pairs(unavailableQuestsDeterminedByTalking) do
        if i == questId then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Daily quest not active"), true, DoableStates.MISSING_DAILY
            elseif returnText then
                return "Daily quest " .. questId .. " is not active", true, DoableStates.MISSING_DAILY
            end
        end
    end

    -- Check if this is one of those arena rating quests
    if Expansions.Current == Expansions.Tbc and (questId == 95158 or questId == 95251 or questId == 95252) then
        if not QuestiePlayer.HasArenaRating(questId) then
            if returnText and returnBrief then
                return l10n("Unavailable")..l10n(": ")..l10n("Missing Arena Rating"), true, DoableStates.ARENA_RATING
            elseif returnText then
                return "Missing Arena Rating for quest " .. questId, true, DoableStates.ARENA_RATING
            end
        end
    end

    -- Available quests
    if returnText and returnBrief then
        return l10n("Available"), false, DoableStates.AVAILABLE
    elseif returnText and not returnBrief then
        return "Quest " .. questId .. " is available", false, DoableStates.AVAILABLE
    else
        return "", false, DoableStates.AVAILABLE
    end
end

---@param questId number
---@return number @Complete = 1, Failed = -1, Incomplete = 0
function QuestieDB.IsComplete(questId)
    local questLogEntry = QuestLogCache.questLog_DO_NOT_MODIFY[questId] -- DO NOT MODIFY THE RETURNED TABLE
    local noQuestItem = not QuestieQuest:CheckQuestSourceItem(questId, false)

    --[[ pseudo:
    if no questLogEntry then return 0
    if has questLogEntry.isComplete then return questLogEntry.isComplete
    if no objectives and an item is needed but not obtained then return 0
    if no objectives then return 1
    return 0
    --]]

    return questLogEntry and (questLogEntry.isComplete or (questLogEntry.objectives[1] and 0) or (#questLogEntry.objectives == 0 and noQuestItem and 0) or 1) or 0
end

---@param self Quest
---@return number @Complete = 1, Failed = -1, Incomplete = 0
local function _IsComplete(self)
    return QuestieDB.IsComplete(self.Id)
end

---@param questLevel number the level of the quest
---@return boolean @Returns true if the quest should be grey, false otherwise
function QuestieDB.IsTrivial(questLevel)
    if questLevel == -1 then
        return false -- Scaling quests are never trivial
    end

    local levelDiff = questLevel - QuestiePlayer.GetPlayerLevel();
    if (levelDiff >= 5) then
        return false -- Red
    elseif (levelDiff >= 3) then
        return false -- Orange
    elseif (levelDiff >= -2) then
        return false -- Yellow
    elseif (-levelDiff <= GetQuestGreenRange("player")) then
        return false -- Green
    else
        return true -- Grey
    end
end

---@return number
local _GetIconScale = function()
    return Questie.db.profile.objectScale or 1
end

---@param questId QuestId
---@return Quest|nil @The quest object or nil if the quest is missing
function QuestieDB.GetQuest(questId) -- /dump QuestieDB.GetQuest(867)
    if not questId then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieDB.GetQuest] No questId.")
        return nil
    end
    if _QuestieDB.questCache[questId] then
        return _QuestieDB.questCache[questId];
    end

    local rawdata = QuestieDB.QueryQuest(questId, QuestieDB._questAdapterQueryOrder)

    if (not rawdata) then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieDB.GetQuest] rawdata is nil for questID:", questId)
        return nil
    end

    ---@class Quest
    ---@field public Id QuestId
    ---@field public name Name
    ---@field public startedBy StartedBy
    ---@field public finishedBy FinishedBy
    ---@field public requiredLevel Level
    ---@field public questLevel Level
    ---@field public requiredRaces number @bitmask
    ---@field public requiredClasses number @bitmask
    ---@field public objectivesText string[]
    ---@field public triggerEnd { [1]: string, [2]: table<AreaId, CoordPair[]>}
    ---@field public objectives RawObjectives
    ---@field public sourceItemId ItemId
    ---@field public preQuestGroup QuestId[]
    ---@field public preQuestSingle QuestId[]
    ---@field public childQuests QuestId[]
    ---@field public inGroupWith QuestId[]
    ---@field public exclusiveTo QuestId[]
    ---@field public zoneOrSort ZoneOrSort
    ---@field public requiredSkill SkillPair
    ---@field public requiredMinRep ReputationPair
    ---@field public requiredMaxRep ReputationPair
    ---@field public requiredSourceItems ItemId[]
    ---@field public nextQuestInChain number
    ---@field public questFlags number @bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ---@field public specialFlags number @bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ---@field public parentQuest QuestId
    ---@field public reputationReward ReputationPair[]
    ---@field public extraObjectives ExtraObjective[]
    ---@field public requiredMaxLevel Level
    ---@field public isComplete boolean
    ---@field public WasComplete boolean?
    ---@field public Color Color
    ---@field public breacrumbForQuestId number
    ---@field public breacrumbs QuestId[]
    ---@field public availableUntilCompleted QuestId
    ---@field public availableStartingWith QuestId
    ---@field public requiredRanks SkillPair[]
    ---@field public disabledByQuest QuestId
    local QO = {
        Id = questId
    }

    -- General filling of the QuestObjective with all database values
    local questKeys = QuestieDB.questKeys
    for stringKey, intKey in pairs(questKeys) do
        QO[stringKey] = rawdata[intKey]
    end

    local questLevel, requiredLevel = QuestieLib.GetEffectiveQuestLevel(questId)
    QO.level = questLevel
    QO.requiredLevel = requiredLevel

    ---@type StartedBy
    local startedBy = QO.startedBy
    ---@type Starters
    QO.Starts = { -- TODO: Rename to Starters
        NPC = startedBy[1],
        GameObject = startedBy[2],
        Item = startedBy[3],
    }
    QO.isHidden = rawdata.hidden or QuestieCorrections.hiddenQuests[questId]
    QO.Description = QO.objectivesText
    if QO.specialFlags then
        QO.IsRepeatable = bitband(QO.specialFlags, 1) ~= 0
    end

    QO.IsComplete = _IsComplete

    ---@type FinishedBy
    local finishedBy = QO.finishedBy
    ---@type Finisher
    QO.Finisher = {
        NPC = finishedBy[1],
        GameObject = finishedBy[2],
    }

    --- to differentiate from the current quest log info.
    --- Quest objectives generated from DB+Corrections.
    --- Data itself is for example for monster type { Type = "monster", Id = 16518, Text = "Nestlewood Owlkin inoculated" }
    ---@type Objective[]
    QO.ObjectiveData = {}

    ---@type RawObjectives
    local objectives = QO.objectives
    if objectives then
        if objectives[1] then
            for _, creatureObjective in pairs(objectives[1]) do
                if creatureObjective then
                    if creatureObjective[3] == 0 then
                        creatureObjective[3] = nil
                    end
                    ---@type NpcObjective
                    QO.ObjectiveData[#QO.ObjectiveData+1] = {
                        Type = "monster",
                        Id = creatureObjective[1],
                        Text = creatureObjective[2],
                        Icon = creatureObjective[3]
                    }
                end
            end
        end
        if objectives[2] then
            for _, objectObjective in pairs(objectives[2]) do
                if objectObjective then
                    if objectObjective[3] == 0 then
                        objectObjective[3] = nil
                    end
                    ---@type ObjectObjective
                    local objectObjectiveData = {
                        Type = "object",
                        Id = objectObjective[1],
                        Text = objectObjective[2],
                        Icon = objectObjective[3]
                    }
                    if QuestieDB.objectObjectiveFirst[questId] then
                        tinsert(QO.ObjectiveData, 1, objectObjectiveData)
                    else
                        QO.ObjectiveData[#QO.ObjectiveData+1] = objectObjectiveData
                    end
                end
            end
        end
        if objectives[3] then
            for _, itemObjective in pairs(objectives[3]) do
                if itemObjective then
                    if itemObjective[3] == 0 then
                        itemObjective[3] = nil
                    end
                    ---@type ItemObjective
                    local itemObjectiveData = {
                        Type = "item",
                        Id = itemObjective[1],
                        Text = itemObjective[2],
                        Icon = itemObjective[3]
                    }
                    if QuestieDB.itemObjectiveFirst[questId] then
                        tinsert(QO.ObjectiveData, 1, itemObjectiveData)
                    else
                        QO.ObjectiveData[#QO.ObjectiveData+1] = itemObjectiveData
                    end
                end
            end
        end
        if objectives[4] then
            ---@type ReputationObjective
            QO.ObjectiveData[#QO.ObjectiveData+1] = {
                Type = "reputation",
                Id = objectives[4][1],
                RequiredRepValue = objectives[4][2]
            }
        end
        if objectives[5] and type(objectives[5]) == "table" and #objectives[5] > 0 then
            for _, creditObjective in pairs(objectives[5]) do
                if creditObjective[4] == 0 then
                    creditObjective[4] = nil
                end
                ---@type KillObjective
                local killCreditObjective = {
                    Type = "killcredit",
                    IdList = creditObjective[1],
                    RootId = creditObjective[2],
                    Text = creditObjective[3],
                    Icon = creditObjective[4]
                }

                --? There are quest(s) which have the killCredit first so we need to switch them
                -- Place the kill credit objective first
                if QuestieDB.killCreditObjectiveFirst[questId] then
                    tinsert(QO.ObjectiveData, 1, killCreditObjective)
                else
                    QO.ObjectiveData[#QO.ObjectiveData+1] = killCreditObjective
                end
            end
        end
        if objectives[6] then
            for _, spellObjective in pairs(objectives[6]) do
                if spellObjective then
                    ---@type SpellObjective
                    local spellObjectiveData = {
                        Type = "spell",
                        Id = spellObjective[1],
                        Text = spellObjective[2],
                        ItemSourceId = spellObjective[3],
                    }
                    QO.SpellItemId = spellObjective[3]

                    --? There are quest(s) which have the spellObjective first so we need to switch them
                    -- Place the spell objective first
                    if QuestieDB.spellObjectiveFirst[questId] then
                        tinsert(QO.ObjectiveData, 1, spellObjectiveData)
                    else
                        QO.ObjectiveData[#QO.ObjectiveData+1] = spellObjectiveData
                    end
                end
            end
        end
    end

    -- Events are usually added at the end of ObjectiveData, unless corrected below.
    local triggerEnd = QO.triggerEnd
    if triggerEnd then
        ---@type TriggerEndObjective
        local triggerEndObjective = {
            Type = "event",
            Text = triggerEnd[1],
            Coordinates = triggerEnd[2]
        }
        if QuestieDB.eventObjectiveFirst[questId] then
            tinsert(QO.ObjectiveData, 1, triggerEndObjective)
        else
            QO.ObjectiveData[#QO.ObjectiveData+1] = triggerEndObjective
        end
    end

    --- Quest objectives generated from quest log in QuestieQuest.lua -> QuestieQuest:PopulateQuestLogInfo(quest)
    --- Includes also icons drawn to maps, and other stuff.
    ---@type table<ObjectiveIndex, QuestObjective>
    QO.Objectives = {}

    QO.SpecialObjectives = {}

    ---@type ItemId[]
    local requiredSourceItems = QO.requiredSourceItems
    if requiredSourceItems then
        for _, itemId in pairs(requiredSourceItems) do
            if itemId then
                -- TODO: This is not required anymore since we validate the database for this case
                -- Make sure requiredSourceItems aren't already an objective
                local itemObjPresent = false
                if objectives and objectives[3] then
                    for _, itemObjective in pairs(objectives[3]) do
                        if itemObjective then
                            if itemId == itemObjective[1] then
                                itemObjPresent = true
                                break
                            end
                        end
                    end
                end

                -- Make an objective for requiredSourceItem
                if not itemObjPresent then
                    QO.SpecialObjectives[itemId] = {
                        Type = "item",
                        Id = itemId,
                        ---@type string @We have to hard-type it here because of the function
                        Description = QuestieDB.QueryItemSingle(itemId, "name")
                    }
                end
            end
        end
    end

    ---@type ExtraObjective[]
    local extraObjectives = QO.extraObjectives
    if extraObjectives then
        for index, o in pairs(extraObjectives) do
            local specialObjective = {
                Icon = o[2],
                Description = o[3],
                RealObjectiveIndex = o[4],
            }
            if o[1] then -- custom spawn
                specialObjective.spawnList = {{
                    Name = o[3],
                    Spawns = o[1],
                    Icon = o[2],
                    GetIconScale = _GetIconScale,
                    IconScale = _GetIconScale(),
                }}
            end
            if o[5] then -- db ref
                specialObjective.Type = o[5][1][1]
                specialObjective.Id = o[5][1][2]
                local spawnList = {}

                for _, ref in pairs(o[5]) do
                    for k, v in pairs(_QuestieQuest.objectiveSpawnListCallTable[ref[1]](ref[2], specialObjective)) do
                        -- we want to be able to override the icon in the corrections (e.g. Questie.ICON_TYPE_OBJECT on objects instead of Questie.ICON_TYPE_LOOT)
                        v.Icon = o[2]
                        spawnList[k] = v
                    end
                end

                specialObjective.spawnList = spawnList
            end
            QO.SpecialObjectives[index] = specialObjective
        end
    end

    _QuestieDB.questCache[questId] = QO
    return QO
end

---@param quest Quest
---@return table<string, table> @List of creature names with their min-max level and rank
function QuestieDB:GetCreatureLevels(quest)
    if quest and QuestieDB._CreatureLevelCache[quest.Id] then
        return QuestieDB._CreatureLevelCache[quest.Id]
    end
    local creatureLevels = {}

    local function _CollectCreatureLevels(npcIds)
        for _, npcId in pairs(npcIds) do
            local npc = QuestieDB:GetNPC(npcId)
            if npc and not creatureLevels[npc.name] then
                creatureLevels[npc.name] = {npc.minLevel, npc.maxLevel, npc.rank}
            end
        end
    end

    if quest.objectives then
        if quest.objectives[1] then -- Killing creatures
            for _, creatureObjective in pairs(quest.objectives[1]) do
                local npcId = creatureObjective[1]
                _CollectCreatureLevels({npcId})
            end
        end
        if quest.objectives[3] then -- Looting items from creatures
            for _, itemObjective in pairs(quest.objectives[3]) do
                local itemId = itemObjective[1]
                local npcIds = QuestieDB.QueryItemSingle(itemId, "npcDrops")
                if npcIds then
                    _CollectCreatureLevels(npcIds)
                end
            end
        end
        if quest.objectives[5] then -- Killcredit creatures
            for _, killCreditId in pairs(quest.objectives[5]) do
                for i = 1,#killCreditId[1] do
                    local npcId = killCreditId[1][i]
                    _CollectCreatureLevels({npcId})
                end
            end
        end
    end
    if quest.requiredSourceItems then
        for _, itemId in pairs(quest.requiredSourceItems) do
            local npcIds = QuestieDB.QueryItemSingle(itemId, "npcDrops")
            if npcIds then
                _CollectCreatureLevels(npcIds)
            end
        end
    end
    if quest.extraObjectives then
        for _, extraObjectiveId in pairs(quest.extraObjectives) do
            if extraObjectiveId[5] then
                for _, extraObjectiveTarget in pairs(extraObjectiveId[5]) do
                    if extraObjectiveTarget[1] == "monster" then
                        local npcId = extraObjectiveTarget[2]
                        _CollectCreatureLevels({npcId})
                    end
                end
            end
        end
    end
    if quest.Id then
        QuestieDB._CreatureLevelCache[quest.Id] = creatureLevels
    end
    return creatureLevels
end

---@param npcId NpcId
---@return NPC|nil
function QuestieDB:GetNPC(npcId)
    if not npcId then
        return nil
    end
    if _QuestieDB.npcCache[npcId] then
        return _QuestieDB.npcCache[npcId]
    end

    local rawdata = QuestieDB.QueryNPC(npcId, QuestieDB._npcAdapterQueryOrder)
    if (not rawdata) then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetNPC] rawdata is nil for npcID:", npcId)
        return nil
    end

    local npcKeys = QuestieDB.npcKeys
    local npc = {
        id = npcId,
        type = "monster",
    }
    for stringKey, intKey in pairs(npcKeys) do
        npc[stringKey] = rawdata[intKey]
    end

    local friendlyToFaction = rawdata[npcKeys.friendlyToFaction]
    npc.friendly = QuestieDB.IsFriendlyToPlayer(friendlyToFaction)

    _QuestieDB.npcCache[npcId] = npc
    return npc
end

---@param friendlyToFaction string --The NPC database field friendlyToFaction - so either nil, "A", "H" or "AH"
---@return boolean
function QuestieDB.IsFriendlyToPlayer(friendlyToFaction)
    if (not friendlyToFaction) or friendlyToFaction == "AH" then
        return true
    end

    if friendlyToFaction == "H" then
        return QuestiePlayer.faction == "Horde"
    elseif friendlyToFaction == "A" then
        return QuestiePlayer.faction == "Alliance"
    end

    return false
end

---------------------------------------------------------------------------------------------------
-- Modifications to questDB

local questsRequiringNewbieAchievement = {
    [31316] = true, -- Julia, The Pet Tamer -- Alliance
    [31812] = true, -- Zunta, The Pet Tamer -- Horde
    [32008] = true, -- Audrey Burnhep -- Alliance
    [32009] = true, -- Varzok -- Horde
}

local questsRequiringTamingKalimdorAchievement = {
    [31818] = true, -- Zunta
    [31819] = true, -- Dagra the Fierce
    [31854] = true, -- Analynn
    [31862] = true, -- Zonya the Sadist
    [31871] = true, -- Traitor Gluk
    [31872] = true, -- Merda Stronghoof
    [31904] = true, -- Cassandra Kaboom
    [31905] = true, -- Grazzle the Great
    [31906] = true, -- Kela Grimtotem
    [31907] = true, -- Zoltan
    [31908] = true, -- Elena Flutterfly
}

local questsRequiringTamingEasternKingdomsAchievement = {
    [31693] = true, -- Julia Stevens
    [31780] = true, -- Old MacDonald
    [31781] = true, -- Lindsay
    [31850] = true, -- Eric Davidson
    [31851] = true, -- Bill Buckler
    [31852] = true, -- Steven Lisbane
    [31910] = true, -- David Kosse
    [31911] = true, -- Deiza Plaguehorn
    [31912] = true, -- Kortas Darkhammer
    [31913] = true, -- Everessa
    [31914] = true, -- Durin Darkhammer
}

local questsRequiringTamingOutlandAchievement = {
    [31922] = true, -- Nicki Tinytech
    [31923] = true, -- Ras'an
    [31924] = true, -- Narrok
    [31925] = true, -- Morulu The Elder
    [31926] = true, -- Grand Master Antari
}

local questsRequiringTamingNorthrendAchievement = {
    [31931] = true, -- Beegle Blastfuse
    [31932] = true, -- Nearly Headless Jacob
    [31933] = true, -- Okrut Dragonwaste
    [31934] = true, -- Gutretch
    [31935] = true, -- Grand Master Payne
}

local questsRequiringTamingCataclysmAchievement = {
    [31971] = true, -- Grand Master Obalis
    [31972] = true, -- Brok
    [31973] = true, -- Bordin Steadyfist
    [31974] = true, -- Goz Banefury
}

local questsRequiringTamingPandariaAchievement = {
    [31953] = true, -- Grand Master Hyuna
    [31954] = true, -- Grand Master Mo'ruk
    [31955] = true, -- Grand Master Nishi
    [31956] = true, -- Grand Master Yon
    [31957] = true, -- Grand Master Shu
    [31958] = true, -- Grand Master Aki
    [31991] = true, -- Grand Master Zusshi
    [33222] = true, -- Little Tommy Newcomer
}

local questsRequiringPandarenSpiritTamerAchievement = {
    [32434] = true, -- Burning Pandaren Spirit
    [32439] = true, -- Flowing Pandaren Spirit
    [32440] = true, -- Whispering Pandaren Spirit
    [32441] = true, -- Thundering Pandaren Spirit
}

local questsRequiringFabledPandarenTamerAchievement = {
    [32604] = true, -- Beasts of Fable Book I
    [32868] = true, -- Beasts of Fable Book II
    [32869] = true, -- Beasts of Fable Book III
}

local questsRequiringFriendsOnTheFarmAchievement = {
    [31312] = true, -- The Old Map
}

local questsRequiringAllGrownsUpAchievement = {
    [32863] = true, -- What We've Been Training For
}

-- Quests where the reputation only goes in one direction (ex. Thorium Brotherhood)
QuestieDB.questsOnlyAvailableUntilReputationValue = {
    -- Thorium Brotherhood
    [7736] = true, -- Restoring Fiery Flux Supplies via Kingsblood
    [7737] = true, -- Gaining Acceptance
    [8241] = true, -- Restoring Fiery Flux Supplies via Iron
    [8242] = true, -- Restoring Fiery Flux Supplies via Heavy Leather

    -- Brood of Nozdormu
    [8302] = true, -- The Hand of the Righteous

    -- Argent Dawn
    [9221] = true, -- Superior Armaments of Battle - Friend of the Dawn
    [9222] = true, -- Epic Armaments of Battle - Friend of the Dawn
    [9223] = true, -- Superior Armaments of Battle - Honored Amongst the Dawn
    [9224] = true, -- Epic Armaments of Battle - Honored Amongst the Dawn
    [9225] = true, -- Epic Armaments of Battle - Revered Amongst the Dawn
    [9226] = true, -- Superior Armaments of Battle - Revered Amongst the Dawn
    [28755] = true, -- Annals of the Silver Hand
    [28756] = true, -- Aberrations of Bone

    -- Consortium
    [9882] = true, -- Stealing from Thieves
    [9883] = true, -- More Crystal Fragments
    [9884] = true, -- Membership Benefits
    [9885] = true, -- Membership Benefits
    [9886] = true, -- Membership Benefits
    [9914] = true, -- A Head Full of Ivory
    [9915] = true, -- More Heads Full of Ivory

    -- Cenarion Expedition
    [9784] = true, -- Identify Plant Parts
    --[9802] = true, -- Plants of Zangarmarsh -- TO DO CHECK THIS
    [9875] = true, -- Uncatalogued Species

    -- Sporregar
    --[9739] = true, -- The Sporelings' Plight -- TO DO CHECK THIS
    [9742] = true, -- More Spore Sacs
    --[9743] = true, -- Natural Enemies -- TO DO CHECK THIS
    [9744] = true, -- More Tendrils!
    --[9808] = true, -- Glowcap Mushrooms -- TO DO CHECK THIS
    [9809] = true, -- More Glowcaps

    -- Lower City
    --[10917] = true, -- The Outcast's Plight -- TO DO CHECK THIS
    [10918] = true, -- More Feathers

    -- Order of the Cloud Serpent
    [31784] = true, -- Onyx To Goodness
}

function _QuestieDB:CheckAchievementRequirements(questId)
    -- So far the only Quests that we know of that requires an earned Achievement are the ones offered by:
    -- https://www.wowhead.com/wotlk/npc=35094/crusader-silverdawn
    -- Get Kraken (14108)
    -- The Fate Of The Fallen (14107)
    -- This NPC requires these earned Achievements baseed on a Players home faction:
    -- https://www.wowhead.com/wotlk/achievement=2817/exalted-argent-champion-of-the-alliance
    -- https://www.wowhead.com/wotlk/achievement=2816/exalted-argent-champion-of-the-horde
    if questId == 14101 or questId == 14102 or questId == 14104 or questId == 14105 or questId == 14107 or questId == 14108 then
        if select(13, GetAchievementInfo(2817)) or select(13, GetAchievementInfo(2816)) then
            return true
        end

        return false
    end

    if questsRequiringNewbieAchievement[questId] then
        return select(13, GetAchievementInfo(7433)) -- Newbie
    end

    if questsRequiringTamingKalimdorAchievement[questId] then
        return select(13, GetAchievementInfo(6602)) -- Taming Kalimdor
    end

    if questsRequiringTamingEasternKingdomsAchievement[questId] then
        return select(13, GetAchievementInfo(6603)) -- Taming Eastern Kingdoms
    end

    if questsRequiringTamingOutlandAchievement[questId] then
        return select(13, GetAchievementInfo(6604)) -- Taming Outland
    end

    if questsRequiringTamingNorthrendAchievement[questId] then
        return select(13, GetAchievementInfo(6605)) -- Taming Northrend
    end

    if questsRequiringTamingCataclysmAchievement[questId] then
        return select(13, GetAchievementInfo(7525)) -- Taming Cataclysm
    end

    if questsRequiringTamingPandariaAchievement[questId] then
        return select(13, GetAchievementInfo(6606)) -- Taming Pandaria
    end

    if questsRequiringPandarenSpiritTamerAchievement[questId] then
        return select(13, GetAchievementInfo(7936)) -- Pandaren Spirit Tamer
    end

    if questsRequiringFabledPandarenTamerAchievement[questId] then
        return select(13, GetAchievementInfo(8080)) -- Beasts of Fable
    end

    if questsRequiringFriendsOnTheFarmAchievement[questId] then
        return select(13, GetAchievementInfo(6552)) -- Friends On The Farm
    end

    if questsRequiringAllGrownsUpAchievement[questId] then
        return select(13, GetAchievementInfo(6570)) -- All Growns Up!
    end
end

-- This function is intended for usage with Gossip and Greeting frames, where there's a list of quests but no QuestIDs are
-- obtainable until entering the specific quest dialog.
-- This is a bruteforce method for obtaining a QuestID with no input other than a quest name, and the ID of the questgiver.
-- It compares the name of the quest entry with the names of every quest that questgiver can either start or end.
---@param name string? @The name of the quest entry
---@param questgiverGUID string? @Should be UnitGUID("questnpc")
---@param questStarter boolean @Should be True if this is an available quest, False if this is an "active" quest (quest ender)
---@return number
function QuestieDB.GetQuestIDFromName(name, questgiverGUID, questStarter)
    local questID = 0 -- worst case, we end up returning an ID of 0 if we can't find a match; any function relying on this one should handle 0 cleanly
    if questgiverGUID then
        local questgiverID = tonumber(questgiverGUID:match("-(%d+)-%x+$"), 10)
        local unit_type = strsplit("-", questgiverGUID)
        local questsStarted
        local questsEnded
        if unit_type == "Creature" then -- if questgiver is an NPC
            questsStarted = QuestieDB.QueryNPCSingle(questgiverID, "questStarts")
            questsEnded = QuestieDB.QueryNPCSingle(questgiverID, "questEnds")
        elseif unit_type == "GameObject" then -- if questgiver is an object (it's rare for an object to have a gossip/greeting frame, but Wanted Boards exist; see object 2713)
            questsStarted = QuestieDB.QueryObjectSingle(questgiverID, "questStarts")
            questsEnded = QuestieDB.QueryObjectSingle(questgiverID, "questEnds")
        else
            return questID; -- If the questgiver is not an NPC or object, bail!
        end
        -- iterate through every questEnds entry in our questgiver's DB, and check if each quest name matches this greeting frame entry
        if questStarter == true then
            if questsStarted then
                for _, id in pairs(questsStarted) do
                    if (name == QuestieDB.QueryQuestSingle(id, "name")) and (QuestieDB.IsDoable(id)) then
                        -- the QuestieDB.IsDoable check is important to filter out identically named quests
                        questID = id
                    end
                end
            else
                Questie.Debug(Questie.DEBUG_ELEVATED, "Database mismatch! No entries found that match quest name. Queststarter is: " .. unit_type .. " " .. questgiverID .. ", quest name is: " .. name)
            end
        else
            if questsEnded then
                for _, id in pairs(questsEnded) do
                    if (name == QuestieDB.QueryQuestSingle(id, "name")) and (QuestieDB.IsDoable(id)) and QuestiePlayer.currentQuestlog[id] then
                        questID = id
                    end
                end
            else
                Questie.Debug(Questie.DEBUG_ELEVATED, "Database mismatch! No entries found that match quest name. Questender is: " .. unit_type .. " " .. questgiverID .. ", quest name is: " .. name)
            end
        end
    end
    return questID;
end
