---@class CataItemFixes
local CataItemFixes = QuestieLoader:CreateModule("CataItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function CataItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [46858] = { -- Personal Riches
            [itemKeys.objectDrops] = {195525},
        },
        [47044] = { -- Shiny Bling
            [itemKeys.vendors] = {35120},
        },
        [47045] = { -- Shiny Bling
            [itemKeys.vendors] = {35126},
        },
        [47046] = { -- Hip New Outfit
            [itemKeys.vendors] = {35128},
        },
        [47047] = { -- Cool Shades
            [itemKeys.vendors] = {35130},
        },
        [60382] = { -- Mylra\'s Knife
            [itemKeys.class] = itemClasses.QUEST,
        },
    }
end
