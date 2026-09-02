---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Addon Load gate: schema metadata is read below, before Login Initialization re-checks the Contract.
local contractSupported, contractError = LibQuestieDB.RequireContract(1)
if not contractSupported then
    error(contractError, 0)
end

---Game Object Database Key Enum owned by QuestieTDB. Values index provider rows and Correction rows.
---@class DatabaseObjectKeys
---@field name integer string
---@field questStarts integer table {QuestId, ...}
---@field questEnds integer table {QuestId, ...}
---@field spawns integer table {[zoneID] = {coordPair, ...}, ...}
---@field zoneID integer int, most common zone
---@field factionID integer int, faction restriction mask
---@field waypoints integer table, waypoints for objects on ships and zeppelins
QuestieDB.objectKeys = LibQuestieDB.Meta.ObjectMeta.objectKeys

-- Field names in Database Key Enum order. Rich projections request every field through
-- `QueryObject(id, QuestieDB._objectAdapterQueryOrder)`, so the packed result lines up with `objectKeys`.
---@type string[]
QuestieDB._objectAdapterQueryOrder = {}
for key, index in pairs(QuestieDB.objectKeys) do
    QuestieDB._objectAdapterQueryOrder[index] = key
end
