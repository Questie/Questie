---@class Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@param aQuestId QuestId
---@param aQuestLevel number
---@param bQuestId QuestId
---@param bQuestLevel number
---@return boolean
local function compareByQuestLevelAndType(aQuestId, aQuestLevel, bQuestId, bQuestLevel)
    if aQuestLevel == bQuestLevel then
        local suffixPrioA = QuestieLib.GetQuestTypeSuffixPriority(aQuestId)
        local suffixPrioB = QuestieLib.GetQuestTypeSuffixPriority(bQuestId)
        if suffixPrioA == suffixPrioB then
            return aQuestId < bQuestId
        end
        return suffixPrioA < suffixPrioB
    end
    return aQuestLevel < bQuestLevel
end

--- Sorts the given questIds in place by their completion status, with completed quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byComplete(questIds, questDetails)
    table.sort(questIds, function(a, b)
        local vA, vB = questDetails[a].questCompletePercent, questDetails[b].questCompletePercent
        if vA == vB then
            local aQuest = questDetails[a].quest
            local bQuest = questDetails[b].quest
            return compareByQuestLevelAndType(aQuest.Id, aQuest.level, bQuest.Id, bQuest.level)
        end

        return vB < vA
    end)
end

--- Sorts the given questIds in place by their completion status, with incomplete quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byCompleteReverse(questIds, questDetails)
    table.sort(questIds, function(a, b)
        local vA, vB = questDetails[a].questCompletePercent, questDetails[b].questCompletePercent
        if vA == vB then
            local aQuest = questDetails[a].quest
            local bQuest = questDetails[b].quest
            return compareByQuestLevelAndType(aQuest.Id, aQuest.level, bQuest.Id, bQuest.level)
        end

        return vB > vA
    end)
end
