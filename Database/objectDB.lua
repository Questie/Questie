---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

QuestieDB.objectKeys = {
    ['name'] = 1, -- string
    ['questStarts'] = 2, -- table {questID(int),...}
    ['questEnds'] = 3, -- table {questID(int),...}
    ['spawns'] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 5, -- guess as to where this object is most common
    ['factionID'] = 6, -- faction restriction mask (same as spawndb factionid)
    ['waypoints'] = 7, -- waypoints for objects on ships/zeppelins/etc
}

QuestieDB.objectKeysReversed = {}
for key, id in pairs(QuestieDB.objectKeys) do
    QuestieDB.objectKeysReversed[id] = key
end

QuestieDB.objectCompilerTypes = {
    ['name'] = "u8string",
    ['spawns'] = "spawnlist",
    ['zoneID'] = "u16",
    ['questStarts'] = "u8u24array",
    ['questEnds'] = "u8u24array",
    ['factionID'] = "u16",
    ['waypoints'] = "waypointlist",
}

QuestieDB.objectCompilerOrder = { -- order easily skipable data first for efficiency
    --static size
    'zoneID', 'factionID',

    -- variable size
    'name', 'spawns', 'questStarts', 'questEnds', 'waypoints'
}

-- temporary, until we remove the old db funcitons
QuestieDB._objectAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.objectKeys) do
    QuestieDB._objectAdapterQueryOrder[id] = key
end
