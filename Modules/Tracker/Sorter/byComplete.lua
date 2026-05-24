---@class Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

--- Sorts the given questIds in place by their completion status, with completed quests first.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byComplete(questIds, questDetails)
    table.sort(questIds, function(a, b)
        local vA, vB = questDetails[a].questCompletePercent, questDetails[b].questCompletePercent
        if vA == vB then
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
        end

        return vB > vA
    end)
end
