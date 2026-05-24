---@class Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

--- Sorts the given questIds in place by their level, with lower level quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byLevel(questIds, questDetails)
    table.sort(questIds, function(a, b)
        local qA = questDetails[a].quest
        local qB = questDetails[b].quest

        if qA.level == qB.level then
            local suffixPrioA = QuestieLib.GetQuestTypeSuffixPriority(qA.Id)
            local suffixPrioB = QuestieLib.GetQuestTypeSuffixPriority(qB.Id)
            if suffixPrioA == suffixPrioB then
                return qA.Id < qB.Id
            end
            return suffixPrioA < suffixPrioB
        end

        return qA.level < qB.level
    end)
end

--- Sorts the given questIds in place by their level, with higher level quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byLevelReverse(questIds, questDetails)
    table.sort(questIds, function(a, b)
        local qA = questDetails[a].quest
        local qB = questDetails[b].quest

        if qA.level == qB.level then
            local suffixPrioA = QuestieLib.GetQuestTypeSuffixPriority(qA.Id)
            local suffixPrioB = QuestieLib.GetQuestTypeSuffixPriority(qB.Id)
            if suffixPrioA == suffixPrioB then
                return qA.Id < qB.Id
            end
            return suffixPrioA < suffixPrioB
        end

        return qA.level > qB.level
    end)
end
