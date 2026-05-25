---@class Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@param questIdA QuestId
---@param questIdB QuestId
---@return boolean
local function _CompareBySuffix(questIdA, questIdB)
    local suffixPrioA = QuestieLib.GetQuestTypeSuffixPriority(questIdA)
    local suffixPrioB = QuestieLib.GetQuestTypeSuffixPriority(questIdB)
    if suffixPrioA == suffixPrioB then
        return questIdA < questIdB
    end
    return suffixPrioA < suffixPrioB
end

--- Sorts the given questIds in place by their level, with lower level quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byLevel(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local questA = questDetails[questIdA].quest
        local questB = questDetails[questIdB].quest

        if questA.level == questB.level then
            return _CompareBySuffix(questIdA, questIdB)
        end

        return questA.level < questB.level
    end)
end

--- Sorts the given questIds in place by their level, with higher level quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byLevelReverse(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local questA = questDetails[questIdA].quest
        local questB = questDetails[questIdB].quest

        if questA.level == questB.level then
            return _CompareBySuffix(questIdA, questIdB)
        end

        return questA.level > questB.level
    end)
end
