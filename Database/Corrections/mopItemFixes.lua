---@class MopItemFixes
local MopItemFixes = QuestieLoader:CreateModule("MopItemFixes")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [74296] = { -- Stolen Carrot
            [itemKeys.npcDrops] = {55504},
        },
        [74615] = { -- Paint Soaked Brush
            [itemKeys.npcDrops] = {55601},
            [itemKeys.objectDrops] = {},
        },
    }
end
