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

--- Sorts the given questIds in place by their completion status, with completed quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byComplete(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local percentageA = questDetails[questIdA].questCompletePercent
        local percentageB = questDetails[questIdB].questCompletePercent

        if percentageA == percentageB then
            local questA = questDetails[questIdA].quest
            local questB = questDetails[questIdB].quest
            return _CompareByQuestLevelAndType(questIdA, questA.level, questIdB, questB.level)
        end

        return percentageB < percentageA
    end)
end

--- Sorts the given questIds in place by their completion status, with incomplete quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byCompleteReverse(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local percentageA = questDetails[questIdA].questCompletePercent
        local percentageB = questDetails[questIdB].questCompletePercent

        if percentageA == percentageB then
            local questA = questDetails[questIdA].quest
            local questB = questDetails[questIdB].quest
            return _CompareByQuestLevelAndType(questIdA, questA.level, questIdB, questB.level)
        end

        return percentageB > percentageA
    end)
end
