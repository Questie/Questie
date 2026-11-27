---Counts what there is to do for the quests of a zone, a faction, and so on.
---
---Counting goes through all the quests, so the last count is kept, and is shown while a new one is made.
---@class JourneySummary
local JourneySummary = QuestieLoader:CreateModule("JourneySummary")

---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

-- Quests that are more levels above the player than this are too hard
local MAX_LEVELS_ABOVE = 3

---@class JourneySummary.Summary
---@field log number
---@field complete number Of those in the log
---@field available number
---@field later number
---@field completed number
---@field total number Of those that can be done once
---@field suited number In the log or available, and right for the player's level

---What can be shown until something is counted.
---@type JourneySummary.Summary
JourneySummary.EMPTY = {log = 0, complete = 0, available = 0, later = 0, completed = 0, total = 0, suited = 0}

---@type table<string, JourneySummary.Summary> By source
local summaries = {}

---@param questLevel number
---@return boolean
local function _IsSuited(questLevel)
    return questLevel <= UnitLevel("player") + MAX_LEVELS_ABOVE and not QuestieDB.IsTrivial(questLevel)
end

---@param source string
---@return JourneySummary.Summary? summary Nil when it wasn't counted yet
function JourneySummary.Get(source)
    return summaries[source]
end

---Yields, so it runs in a thread.
---@async
---@param source string
---@param questIds table<QuestId, any>
---@return JourneySummary.Summary
function JourneySummary.Count(source, questIds)
    local summary = {log = 0, complete = 0, available = 0, repeatable = 0, later = 0, completed = 0, unobtainable = 0, suited = 0}
    for questId in pairs(questIds) do
        JourneyThread.YieldIfNeeded()
        local category = JourneyQuestCategories.IsListed(questId) and JourneyQuestCategories.Get(questId)
        if category then
            summary[category] = summary[category] + 1
        end
        if category == "log" and QuestieDB.IsComplete(questId) == 1 then
            summary.complete = summary.complete + 1
        end
        if category == "log" or category == "available" then
            local level = QuestieLib.GetEffectiveQuestLevel(questId)
            if _IsSuited(level) then
                summary.suited = summary.suited + 1
            end
        end
    end
    local total = 0
    for category, count in pairs(summary) do
        if JourneyQuestCategories.IsCounted(category) then
            total = total + count
        end
    end
    summary.total = total
    summaries[source] = summary
    return summary
end

---@param summary JourneySummary.Summary
---@return boolean
function JourneySummary.IsFinished(summary)
    return summary.total > 0 and summary.completed == summary.total
end

return JourneySummary
