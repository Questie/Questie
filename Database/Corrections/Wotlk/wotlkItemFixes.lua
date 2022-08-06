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
        [33355] = {
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
        [34713] = {
            [itemKeys.npcDrops] = {},
        },
        [34842] = {
            [itemKeys.npcDrops] = {25342},
        },
        [34909] = {
            [itemKeys.npcDrops] = {},
        },
        [34972] = {
            [itemKeys.npcDrops] = {},
        },
        [35123] = {
            [itemKeys.npcDrops] = {},
        },
        [35126] = {
            [itemKeys.npcDrops] = {25841},
        },
        [35687] = {
            [itemKeys.objectDrops] = {188141},
        },
        [35701] = {
            [itemKeys.npcDrops] = {26219},
        },
        [35802] = {
            [itemKeys.npcDrops] = {},
        },
        [35803] = {
            [itemKeys.npcDrops] = {26503},
        },
        [36727] = {
            [itemKeys.npcDrops] = {},
        },
        [36733] = {
            [itemKeys.objectDrops] = {188539},
        },
        [36852] = {
            [itemKeys.npcDrops] = {},
        },
        [37359] = {
            [itemKeys.npcDrops] = {},
        },
        [37501] = {
            [itemKeys.objectDrops] = {189290},
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