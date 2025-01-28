---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

QuestieDB.npcKeys = {
    ['name'] = 1, -- string
    ['minLevelHealth'] = 2, -- int
    ['maxLevelHealth'] = 3, -- int
    ['minLevel'] = 4, -- int
    ['maxLevel'] = 5, -- int
    ['rank'] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
    ['spawns'] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['waypoints'] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 9, -- guess as to where this NPC is most common
    ['questStarts'] = 10, -- table {questID(int),...}
    ['questEnds'] = 11, -- table {questID(int),...}
    ['factionID'] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
    ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    ['subName'] = 14, -- string, The title or function of the NPC, e.g. "Weapon Vendor"
    ['npcFlags'] = 15, -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
                       -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
}

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
    BARBER = (Questie.IsWotlk or Questie.IsCata) and 16777216 or nil,
    ARCANE_REFORGER = Questie.IsCata and 134217728 or nil,
    TRANSMOGRIFIER = Questie.IsCata and 268435456 or nil
}

-- temporary, until we remove the old db funcitons
QuestieDB._npcAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.npcKeys) do
    QuestieDB._npcAdapterQueryOrder[id] = key
end
