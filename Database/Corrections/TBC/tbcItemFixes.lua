---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

QuestieDB.fakeTbcItemStartId = 40000

function QuestieTBCItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [23442] = {
            [itemKeys.npcDrops] = {16975},
        },
        [23486] = {
            [itemKeys.objectDrops] = {181582},
        },
        [23614] = {
            [itemKeys.objectDrops] = {181616},
        },
        [23688] = {
            [itemKeys.objectDrops] = {181672},
        },
        [23849] = {
            [itemKeys.npcDrops] = {17190,17191,17192,},
        },
        [23984] = {
            [itemKeys.npcDrops] = {17324,17327,17339,17342,17343,17344,17346,17347,17348,17350,17352,17353,17522,17523,17527,17588,17589,17661,17683,17322,17323,17325,17326,17328,17329,17330,17334,17336,17337,17338,17340,17341,17358,17494,17550,17604,17606,17607,17608,17609,17610,17713,17714,17715,},
        },
        [24573] = {
            [itemKeys.npcDrops] = {18197},
        },
        [25852] = {
            [itemKeys.objectDrops] = {184842},
        },
        [30435] = {
            [itemKeys.objectDrops] = {184729},
        },

        -- Below are fake items which can be used to show special quest "objectives" as requiredSourceItem.
        -- For example this is used for quest 10129 to show the NPC you have to talk with to start the flight

        [40000] = {
            [itemKeys.name] = "Speak with Wing Commander Brack",
            [itemKeys.relatedQuests] = {10129,},
            [itemKeys.npcDrops] = {19401},
            [itemKeys.objectDrops] = {},
        },
        [40001] = {
            [itemKeys.name] = "Kill Bristlelimb Furbolgs to lure 'High Chief Bristlelimb'",
            [itemKeys.relatedQuests] = {9667,},
            [itemKeys.npcDrops] = {40002},
            [itemKeys.objectDrops] = {},
        },
    }
end