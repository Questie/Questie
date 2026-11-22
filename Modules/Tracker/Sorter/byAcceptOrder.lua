---@class Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@param questIdA QuestId
---@param questLevelA number
---@param questIdB QuestId
---@param questLevelB number
---@return boolean
local function _CompareByQuestLevelAndType(questIdA, questLevelA, questIdB, questLevelB)
    if questLevelA == questLevelB then
        local suffixPrioA = QuestieLib.GetQuestTypeSuffixPriority(questIdA)
        local suffixPrioB = QuestieLib.GetQuestTypeSuffixPriority(questIdB)
        if suffixPrioA == suffixPrioB then
            return questIdA < questIdB
        end
        return suffixPrioA < suffixPrioB
    end
    return questLevelA < questLevelB
end

--- Sorts the given questIds in place by when they were accepted, with the most recently accepted quests first.
--- Quests with an unknown accept order count as the oldest.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byLatest(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local acceptOrderA = questDetails[questIdA].acceptOrder
        local acceptOrderB = questDetails[questIdB].acceptOrder

        if acceptOrderA == acceptOrderB then
            local questA = questDetails[questIdA].quest
            local questB = questDetails[questIdB].quest
            return _CompareByQuestLevelAndType(questIdA, questA.level, questIdB, questB.level)
        end

        return acceptOrderA > acceptOrderB
    end)
end

--- Sorts the given questIds in place by when they were accepted, with the earliest accepted quests first.
--- Quests with an unknown accept order count as the oldest.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byLatestReverse(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local acceptOrderA = questDetails[questIdA].acceptOrder
        local acceptOrderB = questDetails[questIdB].acceptOrder

        if acceptOrderA == acceptOrderB then
            local questA = questDetails[questIdA].quest
            local questB = questDetails[questIdB].quest
            return _CompareByQuestLevelAndType(questIdA, questA.level, questIdB, questB.level)
        end

        return acceptOrderA < acceptOrderB
    end)
end
