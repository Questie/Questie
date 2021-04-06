---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

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
        [24573] = {
            [itemKeys.npcDrops] = {18197},
        },
        [25852] = {
            [itemKeys.objectDrops] = {184842},
        },
    }
end