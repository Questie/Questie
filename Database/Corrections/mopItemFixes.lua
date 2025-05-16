---@class MopItemFixes
local MopItemFixes = QuestieLoader:CreateModule("MopItemFixes")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys

    return {
    }
end
