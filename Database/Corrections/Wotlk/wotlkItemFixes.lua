---@class QuestieWotlkItemFixes
local QuestieWotlkItemFixes = QuestieLoader:CreateModule("QuestieWotlkItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Further information on how to use this can be found at the wiki
-- https://github.com/Questie/Questie/wiki/Corrections

function QuestieWotlkItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [33084] = {
            [itemKeys.npcDrops] = {},
        },
        [33123] = {
            [itemKeys.npcDrops] = {},
        },
        [33628] = {
            [itemKeys.objectDrops] = {186659,186660,186661},
        },
        [34116] = {
            [itemKeys.npcDrops] = {24788},
        },
        [34118] = {
            [itemKeys.objectDrops] = {186944},
        },
        [34123] = {
            [itemKeys.objectDrops] = {186946},
        },
        [34623] = {
            [itemKeys.npcDrops] = {25226},
        },
        [35802] = {
            [itemKeys.npcDrops] = {},
        },
        [35803] = {
            [itemKeys.npcDrops] = {26503},
        },
        [36733] = {
            [itemKeys.objectDrops] = {188539},
        },
        [36852] = {
            [itemKeys.npcDrops] = {},
        },
        [38326] = {
            [itemKeys.npcDrops] = {},
        },
        [38631] = {
            [itemKeys.objectDrops] = {190557,191746,191747,191748,},
        },
        [39160] = {
            [itemKeys.npcDrops] = {},
        },
        [40731] = {
            [itemKeys.npcDrops] = {},
        },
    }
end