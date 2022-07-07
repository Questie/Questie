---@class QuestieWotlkItemFixes
local QuestieWotlkItemFixes = QuestieLoader:CreateModule("QuestieWotlkItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieWotlkItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {}
end