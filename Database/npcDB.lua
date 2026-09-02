---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Addon Load gate: schema metadata is read below, before Login Initialization re-checks the Contract.
local contractSupported, contractError = LibQuestieDB.RequireContract(1)
if not contractSupported then
    error(contractError, 0)
end

---NPC Database Key Enum owned by QuestieTDB. Values index provider rows and Correction rows.
---@class DatabaseNpcKeys
---@field name integer string
---@field minLevelHealth integer int, deprecated placeholder
---@field maxLevelHealth integer int, deprecated placeholder
---@field minLevel integer int
---@field maxLevel integer int
---@field rank integer int
---@field spawns integer table {[zoneID] = {coordPair, ...}, ...}
---@field waypoints integer table {[zoneID] = {coordPair, ...}, ...}
---@field zoneID integer int, most common zone
---@field questStarts integer table {QuestId, ...}
---@field questEnds integer table {QuestId, ...}
---@field factionID integer int
---@field friendlyToFaction integer string, "A", "H", "AH", or nil when hostile to both
---@field subName integer string
---@field npcFlags integer bitmask, see QuestieDB.npcFlags
QuestieDB.npcKeys = LibQuestieDB.Meta.NpcMeta.npcKeys

-- Field names in Database Key Enum order. Rich projections request every field through
-- `QueryNPC(id, QuestieDB._npcAdapterQueryOrder)`, so the packed result lines up with `npcKeys`.
---@type string[]
QuestieDB._npcAdapterQueryOrder = {}
for key, index in pairs(QuestieDB.npcKeys) do
    QuestieDB._npcAdapterQueryOrder[index] = key
end
