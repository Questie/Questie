---The factions the Journey lists quests for, grouped by the expansion that introduced them, and the quests of each.
---@class QuestieJourneyFactions
local QuestieJourneyFactions = QuestieLoader:CreateModule("QuestieJourneyFactions")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local factionIDs = LibQuestieDB.Enum.factionIDs

---The factions each expansion introduced. A faction missing here counts as one of the last expansion.
---@type table<string, FactionId[]>
QuestieJourneyFactions.expansionFactionCandidates = {
    classic = {
        factionIDs.BOOTY_BAY,
        factionIDs.IRONFORGE,
        factionIDs.GNOMEREGAN_EXILES,
        factionIDs.THORIUM_BROTHERHOOD,
        factionIDs.HORDE,
        factionIDs.UNDERCITY,
        factionIDs.DARNASSUS,
        factionIDs.SYNDICATE,
        factionIDs.STORMWIND,
        factionIDs.ORGRIMMAR,
        factionIDs.THUNDER_BLUFF,
        factionIDs.BLOODSAIL_BUCCANEERS,
        factionIDs.GELKIS_CLAN_CENTAUR,
        factionIDs.MAGRAM_CLAN_CENTAUR,
        factionIDs.STEAMWHEEDLE_CARTEL,
        factionIDs.ZANDALAR_TRIBE,
        factionIDs.RAVENHOLDT,
        factionIDs.GADGETZAN,
        factionIDs.ALLIANCE,
        factionIDs.RATCHET,
        factionIDs.THE_LEAGUE_OF_ARATHOR,
        factionIDs.THE_DEFILERS,
        factionIDs.ARGENT_DAWN,
        factionIDs.DARKSPEAR_TROLLS,
        factionIDs.TIMBERMAW_HOLD,
        factionIDs.EVERLOOK,
        factionIDs.WINTERSABER_TRAINERS,
        factionIDs.CENARION_CIRCLE,
        factionIDs.FROSTWOLF_CLAN,
        factionIDs.STORMPIKE_GUARD,
        factionIDs.HYDRAXIAN_WATERLORDS,
        factionIDs.SHEN_DRALAR,
        factionIDs.WARSONG_OUTRIDERS,
        factionIDs.SILVERWING_SENTINELS,
        factionIDs.ALLIANCE_FORCES,
        factionIDs.HORDE_FORCES,
        factionIDs.DARKMOON_FAIRE,
        factionIDs.BROOD_OF_NOZDORMU,
        -- only visible in Forever
        factionIDs.AZEROTH_COMMERCE_AUTHORITY,
        factionIDs.DUROTAR_SUPPLY_AND_LOGISTICS,
        factionIDs.CENARION_SCOUTS,
        factionIDs.KIRIN_TOR_FOREVER,
        factionIDs.BARKSKIN_BURROW,
        factionIDs.NIGHTCLAW_DRUIDS,
        factionIDs.GUARDIANS_OF_HYJAL_FOREVER,
        factionIDs.WINDSHAPERS,
        factionIDs.HIGH_ORDER,
        factionIDs.BOLDEROK_CLAN,
        factionIDs.EARTHEN_RING_FOREVER,
        factionIDs.THE_WATCHERS,
        factionIDs.BROTHERHOOD_OF_THE_HORSE,
        factionIDs.POWDERFUSE,
    },
    tbc = {
        factionIDs.SILVERMOON_CITY,
        factionIDs.TRANQUILLIEN,
        factionIDs.EXODAR,
        factionIDs.THE_ALDOR,
        factionIDs.THE_CONSORTIUM,
        factionIDs.THE_SCRYERS,
        factionIDs.THE_SHATAR,
        factionIDs.SHATTRATH_CITY,
        factionIDs.THE_MAGHAR,
        factionIDs.CENARION_EXPEDITION,
        factionIDs.HONOR_HOLD,
        factionIDs.THRALLMAR,
        factionIDs.THE_VIOLET_EYE,
        factionIDs.SPOREGGAR,
        factionIDs.KURENAI,
        factionIDs.THE_BURNING_CRUSADE,
        factionIDs.KEEPERS_OF_TIME,
        factionIDs.THE_SCALE_OF_THE_SANDS,
        factionIDs.LOWER_CITY,
        factionIDs.ASHTONGUE_DEATHSWORN,
        factionIDs.NETHERWING,
        factionIDs.SHATARI_SKYGUARD,
        factionIDs.OGRILA,
        factionIDs.SHATTERED_SUN_OFFENSIVE,
    },
    wotlk = {
        factionIDs.ALLIANCE_VANGUARD,
        factionIDs.VALIANCE_EXPEDITION,
        factionIDs.HORDE_EXPEDITION,
        factionIDs.THE_TAUNKA,
        factionIDs.THE_HAND_OF_VENGEANCE,
        factionIDs.EXPLORERS_LEAGUE,
        factionIDs.THE_KALUAK,
        factionIDs.WARSONG_OFFENSIVE,
        factionIDs.KIRIN_TOR,
        factionIDs.THE_WYRMREST_ACCORD,
        factionIDs.THE_SILVER_COVENANT,
        factionIDs.WRATH_OF_THE_LICH_KING,
        factionIDs.KNIGHTS_OF_THE_EBON_BLADE,
        factionIDs.FRENZYHEART_TRIBE,
        factionIDs.THE_ORACLES,
        factionIDs.ARGENT_CRUSADE,
        factionIDs.SHOLAZAR_BASIN,
        factionIDs.THE_SONS_OF_HODIR,
        factionIDs.THE_SUNREAVERS,
        factionIDs.THE_FROSTBORN,
        factionIDs.THE_ASHEN_VERDICT,
    },
    cata = {
        factionIDs.BILGEWATER_CARTEL,
        factionIDs.GILNEAS,
        factionIDs.THE_EARTHEN_RING,
        factionIDs.GUARDIANS_OF_HYJAL,
        factionIDs.THERAZANE,
        factionIDs.DRAGONMAW_CLAN,
        factionIDs.RAMKAHEN,
        factionIDs.WILDHAMMER_CLAN,
        factionIDs.BARADINS_WARDENS,
        factionIDs.HELLSCREAMS_REACH,
        factionIDs.AVENGERS_OF_HYJAL,
    },
    mop = {
        factionIDs.SHANG_XIS_ACADEMY,
        factionIDs.FOREST_HOZEN,
        factionIDs.PEARLFIN_JINYU,
        factionIDs.GOLDEN_LOTUS,
        factionIDs.SHADO_PAN,
        factionIDs.ORDER_OF_THE_CLOUD_SERPENT,
        factionIDs.THE_TILLERS,
        factionIDs.JOGU_THE_DRUNK,
        factionIDs.ELLA,
        factionIDs.OLD_HILLPAW,
        factionIDs.CHEE_CHEE,
        factionIDs.SHO,
        factionIDs.HAOHAN_MUDCLAW,
        factionIDs.TINA_MUDCLAW,
        factionIDs.GINA_MUDCLAW,
        factionIDs.FISH_FELLREED,
        factionIDs.FARMER_FUNG,
        factionIDs.THE_ANGLERS,
        factionIDs.THE_KLAXXI,
        factionIDs.THE_AUGUST_CELESTIALS,
        factionIDs.THE_LOREWALKERS,
        factionIDs.THE_BREWMASTERS,
        factionIDs.HUOJIN_PANDAREN,
        factionIDs.TUSHUI_PANDAREN,
        factionIDs.NOMI,
        factionIDs.NAT_PAGLE,
        factionIDs.THE_BLACK_PRINCE,
        factionIDs.BRAWLGAR_ARENA_SEASON_1,
        factionIDs.DOMINANCE_OFFENSIVE,
        factionIDs.OPERATION_SHIELDWALL,
        factionIDs.KIRIN_TOR_OFFENSIVE,
        factionIDs.SUNREAVER_ONSLAUGHT,
        factionIDs.AKAMAS_TRUST,
        factionIDs.BIZMOS_BRAWLPUB_SEASON_1,
        factionIDs.SHADO_PAN_ASSAULT,
        factionIDs.DARKSPEAR_REBELLION,
    },
}

---Builds a map of factionId -> expansion order index using the provided expansion order lookup.
---@param expansionOrderByKey table<string, number>
---@return table<FactionId, number>
function QuestieJourneyFactions.BuildFactionIntroductionOrder(expansionOrderByKey)
    local orderMap = {}

    for expansionKey, factionList in pairs(QuestieJourneyFactions.expansionFactionCandidates) do
        local order = expansionOrderByKey[expansionKey]
        if order then
            for _, factionId in ipairs(factionList) do
                orderMap[factionId] = order
            end
        end
    end

    return orderMap
end

local EXPANSIONS = {
    {key = "classic", order = Expansions.Era},
    {key = "tbc", order = Expansions.Tbc},
    {key = "wotlk", order = Expansions.Wotlk},
    {key = "cata", order = Expansions.Cata},
    {key = "mop", order = Expansions.MoP},
}

local expansionKeyByOrder, expansionOrderByKey = {}, {}
for _, expansion in ipairs(EXPANSIONS) do
    expansionKeyByOrder[expansion.order] = expansion.key
    expansionOrderByKey[expansion.key] = expansion.order
end

local factionIntroductionOrder = QuestieJourneyFactions.BuildFactionIntroductionOrder(expansionOrderByKey)

---Faction names by faction ID, grouped by the key of the expansion that introduced them. Only factions with quests.
---@type table<string, table<FactionId, string>>
QuestieJourney.factionsByExpansion = {}

local QUEST_FIELDS = {"requiredMinRep", "requiredMaxRep", "reputationReward", "requiredRaces", "requiredClasses"}

---@param factionMap table<FactionId, table<QuestId, boolean>>
---@param factionId FactionId?
---@param questId QuestId
local function _AddQuestToFaction(factionMap, factionId, questId)
    if not factionId then
        return
    end
    if not factionMap[factionId] then
        factionMap[factionId] = {}
        local name = QuestieReputation.GetFactionName(factionId)
        local expansionKey = expansionKeyByOrder[factionIntroductionOrder[factionId] or Expansions.MoP]
        if name and name ~= "" and expansionKey then
            QuestieJourney.factionsByExpansion[expansionKey] = QuestieJourney.factionsByExpansion[expansionKey] or {}
            QuestieJourney.factionsByExpansion[expansionKey][factionId] = name
        end
    end
    factionMap[factionId][questId] = true
end

---Finds the quests of every faction: those that need a standing with it, or give reputation with it. Only quests the
---player's race and class can do, and not those Questie hides. Yields, so it runs in a thread.
---@async
function QuestieJourneyFactions.Initialize()
    local HIDE_ON_MAP = QuestieQuestBlacklist.HIDE_ON_MAP
    local hiddenQuests = QuestieCorrections.hiddenQuests
    ---@type table<FactionId, table<QuestId, boolean>>
    local factionMap = {}

    local yieldCounter = 0
    for questId in pairs(QuestieDB.QuestPointers) do
        yieldCounter = yieldCounter + 1
        if yieldCounter >= 1000 then
            yieldCounter = 0
            coroutine.yield()
        end
        -- Indexed one by one: fields the quest doesn't have are holes, which unpack can stop at
        local result = QuestieDB.QueryQuest(questId, QUEST_FIELDS) or {}
        local requiredMinRep, requiredMaxRep, reputationReward = result[1], result[2], result[3]
        local requiredRaces, requiredClasses = result[4], result[5]

        if QuestiePlayer.HasRequiredRace(requiredRaces) and QuestiePlayer.HasRequiredClass(requiredClasses)
            and hiddenQuests and ((not hiddenQuests[questId]) or hiddenQuests[questId] == HIDE_ON_MAP or QuestieEvent.IsEventQuest(questId)) then
            if requiredMinRep then
                _AddQuestToFaction(factionMap, requiredMinRep[1], questId)
            end
            if requiredMaxRep then
                _AddQuestToFaction(factionMap, requiredMaxRep[1], questId)
            end
            for _, reward in pairs(reputationReward or {}) do
                _AddQuestToFaction(factionMap, reward[1], questId)
            end
        end
    end

    ---Quest IDs by faction ID
    ---@type table<FactionId, table<QuestId, boolean>>
    QuestieJourney.factionMap = factionMap
end
