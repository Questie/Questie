---@class QuestieWotlkItemFixes
local QuestieWotlkItemFixes = QuestieLoader:CreateModule("QuestieWotlkItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieWotlkItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [33628] = {
            [itemKeys.objectDrops] = {186659,186660,186661},
        },
        [34623] = {
            [itemKeys.npcDrops] = {25226},
        },
        [35803] = {
            [itemKeys.npcDrops] = {26503},
        },
        [36852] = {
            [itemKeys.npcDrops] = nil,
        },
    }
end