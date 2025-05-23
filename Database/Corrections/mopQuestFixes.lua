---@class MopQuestFixes
local MopQuestFixes = QuestieLoader:CreateModule("MopQuestFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopQuestFixes.Load()
    local questKeys = QuestieDB.questKeys

    return {
        [29414] = { -- The Way of the Tushui
            [questKeys.preQuestSingle] = {},
        },
        [29420] = { -- The Spirit's Guardian
            [questKeys.preQuestSingle] = {},
        },
    }
end
