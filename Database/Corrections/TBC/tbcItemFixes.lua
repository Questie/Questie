---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieTBCItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [23614] = {
            [itemKeys.objectDrops] = {181616},
        },
        [24573] = {
            [itemKeys.npcDrops] = {18197},
        },
    }
end