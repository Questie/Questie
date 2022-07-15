---@class QuestieWotlkItemFixes
local QuestieWotlkItemFixes = QuestieLoader:CreateModule("QuestieWotlkItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieWotlkItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [34623] = {
            [itemKeys.npcDrops] = {25226},
        },
    }
end