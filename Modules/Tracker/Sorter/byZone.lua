---@class Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@param questIdA QuestId
---@param questLevelA number
---@param questIdB QuestId
---@param questLevelB number
---@return boolean
local function compareByQuestLevelAndType(questIdA, questLevelA, questIdB, questLevelB)
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

--- Sorts the given questIds in place by zone, then by level, then by type suffix, then by ID.
---@param questIds QuestId[]
---@param questDetails table<QuestId, QuestSortDetails>
function Sorter.byZone(questIds, questDetails)
    table.sort(questIds, function(questIdA, questIdB)
        local questA = questDetails[questIdA].quest
        local questB = questDetails[questIdB].quest
        local zoneA = questDetails[questIdA].zoneName
        local zoneB = questDetails[questIdB].zoneName

        if zoneA == zoneB then
            return compareByQuestLevelAndType(questIdA, questA.level, questIdB, questB.level)
        else
            if zoneA ~= nil and zoneB ~= nil then
                return zoneA < zoneB
            else
                return zoneA and zoneB
            end
        end
    end)
end
