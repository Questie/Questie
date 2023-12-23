---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");


QuestieDB.itemKeys = {
    ['name'] = 1, -- string
    ['npcDrops'] = 2, -- table or nil, NPC IDs
    ['objectDrops'] = 3, -- table or nil, object IDs
    ['itemDrops'] = 4, -- table or nil, item IDs
    ['startQuest'] = 5, -- int or nil, ID of the quest started by this item
    ['questRewards'] = 6, -- table or nil, quest IDs
    ['flags'] = 7, -- int or nil, see: https://github.com/cmangos/issues/wiki/Item_template#flags
    ['foodType'] = 8, -- int or nil, see https://github.com/cmangos/issues/wiki/Item_template#foodtype
    ['itemLevel'] = 9, -- int, the level of this item
    ['requiredLevel'] = 10, -- int, the level required to equip/use this item
    ['ammoType'] = 11, -- int,
    ['class'] = 12, -- int,
    ['subClass'] = 13, -- int,
    ['vendors'] = 14, -- table or nil, NPC IDs
    ['relatedQuests'] = 15, -- table or nil, IDs of quests that are related to this item
    ['teachesSpell'] = 16, -- int, spellID taught by this item upon use
}

QuestieDB.itemKeysReversed = {}
for key, id in pairs(QuestieDB.itemKeys) do
    QuestieDB.itemKeysReversed[id] = key
end

-- item class/subClass combinations

--class subClass
-- 0         0     Consumable
-- 1         0     Container, Bag
-- 1         1     Container, Soul bag
-- 1         2     Container, Herb bag
-- 1         3     Container, Enchanting bag
-- 1         4     Container, Engineering bag
-- 2         0     Weapon, Axe 1H
-- 2         1     Weapon, Axe 2H
-- 2         2     Weapon, Bow
-- 2         3     Weapon, Gun
-- 2         4     Weapon, Mace 1H
-- 2         5     Weapon, Mace 2H
-- 2         6     Weapon, Polearm
-- 2         7     Weapon, Sword 1H
-- 2         8     Weapon, Sword 2H
-- 2         10     Weapon, Staff
-- 2         13     Weapon, Fist weapon
-- 2         14     Weapon, Miscellaneous
-- 2         15     Weapon, Dagger
-- 2         16     Weapon, Thrown
-- 2         17     Weapon, Spear
-- 2         18     Weapon, Crossbow
-- 2         19     Weapon, Wand
-- 2         20     Weapon, Fishing pole
-- 4         0     Armor, Miscellaneous
-- 4         1     Armor, Cloth
-- 4         2     Armor, Leather
-- 4         3     Armor, Mail
-- 4         4     Armor, Plate
-- 4         6     Armor, Shield
-- 4         7     Armor, Libram
-- 4         8     Armor, Idol
-- 4         9     Armor, Totem
-- 5         0     Reagent
-- 6         2     Projectile, Arrow
-- 6         3     Projectile, Bullet
-- 7         0     Trade goods, Trade goods
-- 7         1     Trade goods, Parts
-- 7         2     Trade goods, Explosives
-- 7         3     Trade goods, Devices
-- 9         0     Recipe, Book
-- 9         1     Recipe, Leatherworking
-- 9         2     Recipe, Tailoring
-- 9         3     Recipe, Engineering
-- 9         4     Recipe, Blacksmithing
-- 9         5     Recipe, Cooking
-- 9         6     Recipe, Alchemy
-- 9         7     Recipe, First aid
-- 9         8     Recipe, Enchanting
-- 9         9     Recipe, Fishing
-- 11        2     Quiver
-- 11        3     Ammo pouch
-- 12        0     Quest
-- 13        0     Key
-- 13        1     Lockpick
-- 15        0     Miscellaneous, Junk

QuestieDB.itemClasses = {
    QUEST = 12,
}

QuestieDB.itemCompilerTypes = {
    ["foodType"] = "u8",
    ["itemLevel"] = "u16",
    ["flags"] = "u32",
    ["startQuest"] = "u24",
    ["requiredLevel"] = "u8",
    ["ammoType"] = "u8",
    ["class"] = "u8",
    ["subClass"] = "u8",
    ["npcDrops"] = "u16u24array",
    ["objectDrops"] = "u8u24array",
    ["itemDrops"] = "u8u24array",
    ["vendors"] = "u8u24array",
    ["relatedQuests"] = "u8u24array",
    ["questRewards"] = "u8u24array",
    ["name"] = "u8string",
    ["teachesSpell"] = "u24",
}

QuestieDB.itemCompilerOrder = { -- order easily skipable data first for efficiency
    --static size
    "flags", "startQuest", "itemLevel", "requiredLevel", "foodType", "ammoType", "class", "subClass", "teachesSpell",

    -- variable size
    "name", "relatedQuests", "questRewards", "npcDrops", "objectDrops", "vendors", "itemDrops"
}

-- temporary, until we remove the old db funcitons
QuestieDB._itemAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.itemKeys) do
    QuestieDB._itemAdapterQueryOrder[id] = key
end
