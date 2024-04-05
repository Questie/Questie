---@class CataItemFixes
local CataItemFixes = QuestieLoader:CreateModule("CataItemFixes")


function CataItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [60382] = { -- Mylra\'s Knife
            [itemKeys.class] = itemClasses.QUEST,
        },
    }
end
