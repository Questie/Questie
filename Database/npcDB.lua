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

QuestieDB.npcFlags = (Questie.IsTBC or Questie.IsWotlk) and {
    NONE = 0,
    GOSSIP = 1,
    QUEST_GIVER = 2,
    TRAINER = 16,
    VENDOR = 128,
    REPAIR = 4096,
    FLIGHT_MASTER = 8192,
    SPIRIT_HEALER = 16384,
    SPIRIT_GUIDE = 32768,
    INNKEEPER = 65536,
    BANKER = 131072,
    PETITIONER = 262144,
    TABARD_DESIGNER = 524288,
    BATTLEMASTER = 1048576,
    AUCTIONEER = 2097152,
    STABLEMASTER = 4194304,
} or {
    NONE = 0,
    GOSSIP = 1,
    QUEST_GIVER = 2,
    VENDOR = 4,
    FLIGHT_MASTER = 8,
    TRAINER = 16,
    SPIRIT_HEALER = 32,
    SPIRIT_GUIDE = 64,
    INNKEEPER = 128,
    BANKER = 256,
    PETITIONER = 512,
    TABARD_DESIGNER = 1024,
    BATTLEMASTER = 2048,
    AUCTIONEER = 4096,
    STABLEMASTER = 8192,
    REPAIR = 16384
}

-- temporary, until we remove the old db funcitons
QuestieDB._npcAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.npcKeys) do
    QuestieDB._npcAdapterQueryOrder[id] = key
end
