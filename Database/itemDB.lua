---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Addon Load gate: schema metadata is read below, before Login Initialization re-checks the Contract.
local contractSupported, contractError = LibQuestieDB.RequireContract(1)
if not contractSupported then
    error(contractError, 0)
end

---Item Database Key Enum owned by QuestieTDB. Values index provider rows and Correction rows.
---@class DatabaseItemKeys
---@field name integer string
---@field npcDrops integer table {NpcId, ...}
---@field objectDrops integer table {ObjectId, ...}
---@field itemDrops integer table {ItemId, ...}
---@field startQuest integer int
---@field questRewards integer table {QuestId, ...}
---@field flags integer int
---@field foodType integer int
---@field itemLevel integer int
---@field requiredLevel integer int
---@field ammoType integer int
---@field class integer int, see QuestieDB.itemClasses
---@field subClass integer int
---@field vendors integer table {NpcId, ...}
---@field relatedQuests integer table {QuestId, ...}
---@field teachesSpell integer int
QuestieDB.itemKeys = LibQuestieDB.Meta.ItemMeta.itemKeys

-- Field names in Database Key Enum order. Rich projections request every field through
-- `QueryItem(id, QuestieDB._itemAdapterQueryOrder)`, so the packed result lines up with `itemKeys`.
---@type string[]
QuestieDB._itemAdapterQueryOrder = {}
for key, index in pairs(QuestieDB.itemKeys) do
    QuestieDB._itemAdapterQueryOrder[index] = key
end
