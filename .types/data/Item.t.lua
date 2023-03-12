
---@alias ItemId number

---@class ItemDropSource
---@field Id NpcId|ObjectId
---@field Type "monster"|"object"

---@class ItemClass
local ItemClass = {
    Consumable = 0,
    Container = 1,
    Weapon = 2,
    Gem = 3,
    Armor = 4,
    Reagent = 5,
    Projectile = 6,
    Trade_Goods = 7,
    Generic_OBSOLETE = 8,
    Recipe = 9,
    Money_OBSOLETE = 10,
    Quiver = 11,
    Quest = 12,
    Key = 13,
    Permanent_OBSOLETE = 14,
    Miscellaneous = 15,
    Glyph = 16,
}

---@class RawItem
---@field name string -- string
---@field npcDrops NpcId[]? -- table or nil, NPC IDs
---@field objectDrops ObjectId[]? -- table or nil, object IDs
---@field itemDrops ItemId[]? -- table or nil, item IDs
---@field startQuest QuestId? -- int or nil, ID of the quest started by this item
---@field questRewards QuestId[]? -- table or nil, quest IDs
---@field flags number? -- int or nil, see: https://github.com/cmangos/issues/wiki/Item_template#flags
---@field foodType number? -- int or nil, see https://github.com/cmangos/issues/wiki/Item_template#foodtype
---@field itemLevel Level -- int, the level of this item
---@field requiredLevel Level -- int, the level required to equip/use this item
---@field ammoType number -- int,
---@field class ItemClass -- int,
---@field subClass number -- int,
---@field vendors NpcId[]? -- table or nil, NPC IDs
---@field relatedQuests QuestId[]? -- table or nil, IDs of quests that are related to this item
