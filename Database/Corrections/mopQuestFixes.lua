---@class MopQuestFixes
local MopQuestFixes = QuestieLoader:CreateModule("MopQuestFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopQuestFixes.Load()
    local questKeys = QuestieDB.questKeys

    return {
    }
end
