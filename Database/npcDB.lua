---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions");

local contractSupported, contractError = LibQuestieDB.RequireContract(1)
if not contractSupported then
    error(contractError, 0)
end

---@class DatabaseNpcKeys
QuestieDB.npcKeys = LibQuestieDB.Meta.NpcMeta.npcKeys

QuestieDB.npcKeysReversed = {}
for key, id in pairs(QuestieDB.npcKeys) do
    QuestieDB.npcKeysReversed[id] = key
end


QuestieDB.npcCompilerTypes = {
    ['name'] = "u8string",
    ['minLevelHealth'] = "u32",
    ['maxLevelHealth'] = "u32",
    ['minLevel'] = "u8",
    ['maxLevel'] = "u8",
    ['rank'] = "u8",
    ['spawns'] = "spawnlist",
    ['waypoints'] = "waypointlist",
    ['zoneID'] = "u16",
    ['questStarts'] = "u8u24array",
    ['questEnds'] = "u8u24array",
    ['factionID'] = "u16",
    ['friendlyToFaction'] = "faction",
    ['subName'] = "u8string",
    ['npcFlags'] = "u32",
}

QuestieDB.npcCompilerOrder = { -- order easily skipable data first for efficiency
    --static size
    'minLevelHealth', 'maxLevelHealth', 'minLevel', 'maxLevel', 'rank', 'zoneID', 'factionID', 'friendlyToFaction', 'npcFlags',

    -- variable size
    'name', 'spawns', 'waypoints', 'questStarts', 'questEnds', 'subName'
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
    TRANSMOGRIFIER = Expansions.Current >= Expansions.Cata and 268435456 or nil
}

-- temporary, until we remove the old db funcitons
QuestieDB._npcAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.npcKeys) do
    QuestieDB._npcAdapterQueryOrder[id] = key
end
