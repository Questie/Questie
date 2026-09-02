---@meta _

---@class ItemDB
---@field name fun(id: ItemId): string? Item name.
---@field npcDrops fun(id: ItemId): NpcId[]? NPCs that drop this item.
---@field objectDrops fun(id: ItemId): ObjectId[]? Objects that drop this item.
---@field itemDrops fun(id: ItemId): ItemId[]? Items that contain this item.
---@field startQuest fun(id: ItemId): QuestId? Quest started by this item.
---@field questRewards fun(id: ItemId): QuestId[]? Quests that reward this item.
---@field flags fun(id: ItemId): number? Item flag bitmask.
---@field foodType fun(id: ItemId): number? Food type.
---@field itemLevel fun(id: ItemId): number? Item level.
---@field requiredLevel fun(id: ItemId): number? Required player level.
---@field ammoType fun(id: ItemId): number? Ammo type.
---@field class fun(id: ItemId): number? Item class.
---@field subClass fun(id: ItemId): number? Item subclass.
---@field vendors fun(id: ItemId): NpcId[]? NPCs that sell this item.
---@field relatedQuests fun(id: ItemId): QuestId[]? Related quests.
---@field teachesSpell fun(id: ItemId): number? Spell taught when used.
---@field GetByIndex fun(id: ItemId, fieldIndex: integer): any Read a field by positional index.
---@field Get fun(id: ItemId, key: QuestieTDBItemField|integer): any Read a field by canonical name or index.
---@field GetAll fun(id: ItemId, keys: (QuestieTDBItemField|integer)[]): QuestieTDBPackedValues? Read fields into a packed table, or nil for an unknown ID.
---@field GetRaw fun(id: ItemId, key: QuestieTDBItemField|integer): any Read base data without Corrections or localization.
---@field Exists fun(id: ItemId): boolean Test the composed view.
---@field InvalidateCache fun(id?: ItemId) Drop cached fields for one item or every item.
---@field BuildNameIndex fun() Build the Name index now (a no-op when it exists) instead of on the first IdsByName call; a full pass over every item name.
---@field IdsByName fun(name: string): ItemId[]? Every composed item ID whose current name equals `name` exactly, ascending, or nil; shared and read-only.
ItemDB = {}

---Returns the composed ID list, or a read-only lookup map when `hashmap` is true.
---@param hashmap? false
---@return ItemId[] ids
---@overload fun(hashmap: true): table<ItemId, true>
function ItemDB.GetAllIds(hashmap) end
