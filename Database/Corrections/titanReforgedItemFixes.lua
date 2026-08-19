---@class TitanReforgedItemFixes
local TitanReforgedItemFixes = QuestieLoader:CreateModule("TitanReforgedItemFixes")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---Returns Titan-only item corrections applied before database compilation.
---@return table<ItemId, table>
function TitanReforgedItemFixes.LoadItems()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [264272] = { -- Celestial Missive
            [itemKeys.name] = "Celestial Missive",
            [itemKeys.relatedQuests] = {94376},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [268145] = { -- Punctured Voodoo Doll
            [itemKeys.name] = "Punctured Voodoo Doll",
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.itemLevel] = 1,
            [itemKeys.flags] = 33792,
        },
        [272955] = { -- Eredar Heart
            [itemKeys.name] = "Eredar Heart",
            [itemKeys.npcDrops] = {34780},
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.relatedQuests] = {96211},
            [itemKeys.startQuest] = 96211,
        },
        [274994] = { -- Primal Hakkari Idol
            [itemKeys.name] = "Primal Hakkari Idol",
            [itemKeys.class] = 15,
            [itemKeys.requiredLevel] = 80,
        },
        [279578] = { -- Empowered Zandalari Bijou
            [itemKeys.name] = "Empowered Zandalari Bijou",
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.requiredLevel] = 80,
        },
    }
end

---Returns runtime overrides for items inherited from the WotLK database.
---@return table<ItemId, table>
function TitanReforgedItemFixes.LoadItemOverrides()
    local itemKeys = QuestieDB.itemKeys

    return {
        [22734] = { -- Base of Atiesh
            [itemKeys.npcDrops] = {15172},
        },
    }
end
