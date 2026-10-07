---@class QuestieConditions
local QuestieConditions = QuestieLoader:CreateModule("QuestieConditions")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

-- Quest Conditions are availability expressions owned by QuestieDB (provider ADR 0017).
-- QuestieDB evaluates them with client APIs alone. Questie publishes the functions where its
-- own state gives a better answer, so every consumer sees the availability Questie shows.

-- A condition is unknown while the client hides a value it reads, such as auras behind secret
-- values. That can happen in combat, in instances, or for other reasons, so unknown quests are
-- re-checked on their own until they resolve, rather than on a guessed event.
local lastKnown = {} -- questId -> last determinate result
local pending = {} -- questId -> answer shown while its condition is unknown

local FAST_RECHECKS, FAST_DELAY, SLOW_DELAY = 30, 1, 5 -- Seconds; slow down during long secret states.
local recheckScheduled = false
local recheckCount = 0

---Publish Questie's condition functions. Call once Questie's quest-log and completed-quest
---state is loaded: other addons evaluate against these functions too.
function QuestieConditions.Initialize()
    LibQuestieDB.Conditions.SetFunctions("Questie", {
        QuestRewarded = function(questId)
            return Questie.db.char.complete[questId] == true
        end,
        QuestInLog = function(questId)
            return QuestiePlayer.currentQuestlog[questId] ~= nil
        end,
        QuestComplete = function(questId)
            return QuestiePlayer.currentQuestlog[questId] ~= nil and QuestieDB.IsComplete(questId) == 1
        end,
        -- Whether the player could accept the quest now. Manual hiding is a display choice, so a
        -- hidden quest still counts; Questie's display level range is likewise not applied.
        QuestAvailable = function(questId)
            if QuestiePlayer.currentQuestlog[questId] then return false end
            local playerLevel = QuestiePlayer.GetPlayerLevel()
            local requiredMaxLevel = QuestieDB.QueryQuestSingle(questId, "requiredMaxLevel") or 0
            if playerLevel < (QuestieDB.QueryQuestSingle(questId, "requiredLevel") or 0) or
                (requiredMaxLevel > 0 and playerLevel > requiredMaxLevel) then
                return false
            end
            return QuestieDB.IsDoable(questId, false, true)
        end,
        -- The client identifies skill lines by localized name; QuestieProfessions maps them to IDs.
        HasSkill = function(skillId, minLevel)
            local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel({skillId, minLevel or 1})
            return hasProfession and hasSkillLevel
        end,
    })
end

local ScheduleRecheck

---Whether a quest's condition allows it right now.
---An unknown result keeps the last determinate answer, or allows the quest if there is none,
---and keeps re-checking the quest until its condition can be read.
---@param questId QuestId
---@return boolean
function QuestieConditions.IsFulfilled(questId)
    local result = LibQuestieDB.Conditions.EvaluateQuest(questId)
    if result == nil then
        local shown = lastKnown[questId] ~= false
        pending[questId] = shown
        ScheduleRecheck()
        return shown
    end
    lastKnown[questId] = result
    pending[questId] = nil
    return result
end

---Re-evaluate quests whose condition was unknown. If any now differs from the answer shown,
---recalculate available quests once. Events that often end a secret state call this directly.
function QuestieConditions.RecheckNow()
    local changed = false
    for questId, shown in pairs(pending) do
        local result = LibQuestieDB.Conditions.EvaluateQuest(questId)
        if result ~= nil then
            lastKnown[questId] = result
            pending[questId] = nil
            changed = changed or result ~= shown
        end
    end
    if changed then
        AvailableQuests.CalculateAndDrawAll()
    end
    if next(pending) then
        ScheduleRecheck()
    else
        recheckCount = 0
    end
end

ScheduleRecheck = function()
    if recheckScheduled then return end
    recheckScheduled = true
    recheckCount = recheckCount + 1
    C_Timer.After(recheckCount <= FAST_RECHECKS and FAST_DELAY or SLOW_DELAY, function()
        recheckScheduled = false
        QuestieConditions.RecheckNow()
    end)
end

return QuestieConditions
