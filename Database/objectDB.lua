---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local contractSupported, contractError = LibQuestieDB.RequireContract(1)
if not contractSupported then
    error(contractError, 0)
end

---@class DatabaseObjectKeys
QuestieDB.objectKeys = LibQuestieDB.Meta.ObjectMeta.objectKeys

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
