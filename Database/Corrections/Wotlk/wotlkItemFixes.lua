---@class QuestieWotlkItemFixes
local QuestieWotlkItemFixes = QuestieLoader:CreateModule("QuestieWotlkItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Further information on how to use this can be found at the wiki
-- https://github.com/Questie/Questie/wiki/Corrections

function QuestieWotlkItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [33628] = {
            [itemKeys.objectDrops] = {186659,186660,186661},
        },
        [34116] = {
            [itemKeys.npcDrops] = {24788},
        },
        [34623] = {
            [itemKeys.npcDrops] = {25226},
        },
        [35803] = {
            [itemKeys.npcDrops] = {26503},
        },
        [36852] = {
            [itemKeys.npcDrops] = {},
        },
    }
end