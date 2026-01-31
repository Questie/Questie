---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");


---@class DatabaseQuestKeys
QuestieDB.questKeys = {
    ['name'] = 1, -- string
    ['startedBy'] = 2, -- table
        --['creatureStart'] = 1, -- table {creature(int),...}
        --['objectStart'] = 2, -- table {object(int),...}
        --['itemStart'] = 3, -- table {item(int),...}
    ['finishedBy'] = 3, -- table
        --['creatureEnd'] = 1, -- table {creature(int),...}
        --['objectEnd'] = 2, -- table {object(int),...}
    ['requiredLevel'] = 4, -- int
    ['questLevel'] = 5, -- int
    ['requiredRaces'] = 6, -- bitmask
    ['requiredClasses'] = 7, -- bitmask
    ['objectivesText'] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
    ['triggerEnd'] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
    ['objectives'] = 10, -- table
        --['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
        --['objectObjective'] = 2, -- table {{object(int), text(string)},...}
        --['itemObjective'] = 3, -- table {{item(int), text(string)},...}
        --['reputationObjective'] = 4, -- table: {faction(int), value(int)}
        --['killCreditObjective'] = 5, -- table: {{creature(int), ...}, baseCreatureID, baseCreatureText}
        --['spellObjective'] = 6, -- table: {{spell(int), text(string), item(int)},...}
    ['sourceItemId'] = 11, -- int, item provided by quest starter
    ['preQuestGroup'] = 12, -- table: {quest(int)}
    ['preQuestSingle'] = 13, -- table: {quest(int)}
    ['childQuests'] = 14, -- table: {quest(int)}
    ['inGroupWith'] = 15, -- table: {quest(int)}
    ['exclusiveTo'] = 16, -- table: {quest(int)}
    ['zoneOrSort'] = 17, -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
    ['requiredSkill'] = 18, -- table: {skill(int), value(int)}
    ['requiredMinRep'] = 19, -- table: {faction(int), value(int)}
    ['requiredMaxRep'] = 20, -- table: {faction(int), value(int)}
    ['requiredSourceItems'] = 21, -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
    ['nextQuestInChain'] = 22, -- int: if this quest is active/finished, the current quest is not available anymore
    ['questFlags'] = 23, -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ['specialFlags'] = 24, -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ['parentQuest'] = 25, -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
    ['reputationReward'] = 26, -- table: {{FACTION,VALUE}, ...}, A list of reputation reward for factions
    ['breadcrumbForQuestId'] = 27, -- int: quest ID for the quest this optional breadcrumb quest leads to
    ['breadcrumbs'] = 28, -- table: {questID(int), ...} quest IDs of the breadcrumbs that lead to this quest
    ['extraObjectives'] = 29, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
    ['requiredSpell'] = 30, -- int: quest is only available if character has this spellID
    ['requiredSpecialization'] = 31, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
    ['requiredMaxLevel'] = 32, -- int: quest is only available up to a certain level
}

QuestieDB.questKeysReversed = {}
for key, id in pairs(QuestieDB.questKeys) do
    QuestieDB.questKeysReversed[id] = key
end

QuestieDB.questCompilerTypes = {
    ['name'] = "u8string", -- string
    ['startedBy'] = "questgivers", -- table
    ['finishedBy'] = "questgivers", -- table
    ['requiredLevel'] = "u8", -- int
    ['questLevel'] = "s16", -- int
    ['requiredRaces'] = "u32", -- bitmask
    ['requiredClasses'] = "u16", -- bitmask
    ['objectivesText'] = "u8u16stringarray", -- table: {string,...}, Description of the quest. Auto-complete if nil.
    ['triggerEnd'] = "trigger", -- table: {text, {[zoneID] = {coordPair,...},...}}
    ['objectives'] = "objectives", -- table
    ['sourceItemId'] = "u24", -- int, item provided by quest starter
    ['preQuestGroup'] = "u8s24array", -- table: {quest(int)}
    ['preQuestSingle'] = "u8u24array", -- table: {quest(int)}
    ['childQuests'] = "u8u24array", -- table: {quest(int)}
    ['inGroupWith'] = "u8u24array", -- table: {quest(int)}
    ['exclusiveTo'] = "u8u24array", -- table: {quest(int)}
    ['zoneOrSort'] = "s16", -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
    ['requiredSkill'] = "u12pair", -- table: {skill(int), value(int)}
    ['requiredMinRep'] = "s24pair", -- table: {faction(int), value(int)}
    ['requiredMaxRep'] = "s24pair", -- table: {faction(int), value(int)}
    ['requiredSourceItems'] = "u8u24array", -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
    ['nextQuestInChain'] = "u24", -- int: if this quest is active/finished, the current quest is not available anymore
    ['questFlags'] = "u24", -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ['specialFlags'] = "u16", -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ['parentQuest'] = "u24", -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
    ['reputationReward'] = "u8s24pairs",
    ['breadcrumbForQuestId'] = "u24",
    ['breadcrumbs'] = "u8u24array",
    ['extraObjectives'] = "extraobjectives",
    ['requiredSpell'] = "s24",
    ['requiredSpecialization'] = "u24",
    ['requiredMaxLevel'] = "u8",
}

QuestieDB.questCompilerOrder = { -- order easily skipable data first for efficiency
    --static size
    'requiredLevel', 'questLevel', 'requiredRaces', 'requiredClasses', 'sourceItemId', 'zoneOrSort', 'requiredSkill',
    'requiredMinRep', 'requiredMaxRep', 'nextQuestInChain', 'questFlags', 'specialFlags', 'parentQuest', 'requiredSpell',
    'requiredSpecialization', 'requiredMaxLevel', 'breadcrumbForQuestId',

    -- variable size
    'name', 'preQuestGroup', 'preQuestSingle', 'childQuests', 'inGroupWith', 'exclusiveTo', 'requiredSourceItems',
    'objectivesText', 'triggerEnd', 'startedBy', 'finishedBy', 'breadcrumbs', 'objectives', 'reputationReward', 'extraObjectives'
}

QuestieDB.questFlags = {
    NONE = 0,
    STAY_ALIVE = 1,
    PARTY_ACCEPT = 2,
    EXPLORATION = 4,
    SHARABLE = 8,
    UNUSED1 = 16,
    EPIC = 32,
    RAID = 64,
    UNUSED2 = 128,
    UNKNOWN = 256,
    HIDDEN_REWARDS = 512,
    AUTO_REWARDED = 1024,
    DAILY = 4096,
    WEEKLY = 32768,
}

QuestieDB.factionIDs = {
    BOOTY_BAY = 21,
    IRONFORGE = 47,
    GNOMEREGAN = 54,
    THORIUM_BROTHERHOOD = 59,
    HORDE = 67,
    UNDERCITY = 68,
    DARNASSUS = 69,
    SYNDICATE = 70,
    STORMWIND = 72,
    ORGRIMMAR = 76,
    THUNDER_BLUFF = 81,
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
    THE_SHA_TAR = 935,
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
    SHA_TARI_SKYGUARD = 1031,
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

-- temporary, until we remove the old db functions
QuestieDB._questAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.questKeys) do
    QuestieDB._questAdapterQueryOrder[id] = key
end
