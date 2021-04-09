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
    }
end