---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:CreateModule("TrackerQuestTimers")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local LSM30 = LibStub("LibSharedMedia-3.0")

-- Originally there was no timer frame. WatchFrame was introduced in WotLK and got replaced with QuestTimerFrame in Cataclysm.
-- Today all client version seem to use QuestTimerFrame.
local QuestTimerFrame = QuestTimerFrame or WatchFrame
-- The tracker lines showing the remaining time of each timed quest. A quest can be listed more than once.
---@type table<number, LineFrame[]>
local timerLines = {}

function TrackerQuestTimers:Initialize()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerQuestTimers:Initialize]")

    if QuestieTracker.started or (not Questie.db.profile.trackerEnabled) then
        return
    end

    if QuestTimerFrame then
        QuestTimerFrame:HookScript("OnShow", function()
            if Questie.db.profile.showBlizzardQuestTimer then
                TrackerQuestTimers:ShowBlizzardTimer()
            else
                TrackerQuestTimers:HideBlizzardTimer()
            end
        end)
    end

    -- Pre-Classic WotLK
    if Expansions.Current <= Expansions.Tbc then
        C_Timer.NewTicker(1, function()
            TrackerQuestTimers:UpdateTimerFrame()
        end)
    end
end

function TrackerQuestTimers:HideBlizzardTimer()
    if QuestTimerFrame then
        QuestTimerFrame:Hide()
    end
end

function TrackerQuestTimers:ShowBlizzardTimer()
    if QuestTimerFrame and next(timerLines) then
        QuestTimerFrame:Show()
    end
end

---Forgets the timer lines of the previous tracker layout. The tracker calls it before it lays out the quests again.
function TrackerQuestTimers.ResetTimerLines()
    timerLines = {}
end

---@param quest table
---@param frame LineFrame? A tracker line that shows the remaining time of the quest from now on
---@return string? timeRemainingString
---@return number? timeRemaining
function TrackerQuestTimers:UpdateAndGetRemainingTime(quest, frame)
    local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(quest.Id)

    if (timeRemainingString == nil) then
        quest.timedBlizzardQuest = nil
        quest.trackTimedQuest = false
        return nil
    end

    if frame then
        timerLines[quest.Id] = timerLines[quest.Id] or {}
        table.insert(timerLines[quest.Id], frame)
    end

    if timeRemaining then
        if Questie.db.profile.showBlizzardQuestTimer then
            TrackerQuestTimers:ShowBlizzardTimer()
            quest.timedBlizzardQuest = true
            quest.trackTimedQuest = false
        else
            TrackerQuestTimers:HideBlizzardTimer()
            quest.timedBlizzardQuest = false
            quest.trackTimedQuest = true
        end
    end

    return timeRemainingString, timeRemaining
end

---@param questId number
---@return string? timeRemainingString @Format is "4 Mins 45 Secs"
---@return number? timeRemaining
function TrackerQuestTimers:GetRemainingTimeByQuestId(questId)
    if C_QuestLog.GetQuestTimers then
        -- Modern timers carry their quest ID, so there is no need to change quest-log selection.
        for _, questTimer in ipairs(C_QuestLog.GetQuestTimers()) do
            if questTimer.questID == questId then
                return SecondsToTime(questTimer.questTimer, false, false), questTimer.questTimer
            end
        end
        return nil
    end

    local questLogIndex = QuestieCompat.GetQuestLogIndexByID(questId)
    if (not questLogIndex) then
        return nil
    end

    local questTimers = QuestieCompat.GetQuestTimers(questId)
    if (not questTimers) then
        return nil
    end

    local currentQuestLogSelection = QuestieCompat.GetQuestLogSelection()
    QuestieCompat.SelectQuestLogEntry(questLogIndex)
    -- We can't use GetQuestTimers because we don't know for which quest the timer is.
    -- GetQuestLogTimeLeft returns the correct value though.
    local timeRemaining = GetQuestLogTimeLeft(questLogIndex)
    QuestieCompat.SelectQuestLogEntry(currentQuestLogSelection)

    if timeRemaining ~= nil then
        local timeRemainingString = SecondsToTime(timeRemaining, false, false)

        return timeRemainingString, timeRemaining
    else
        return nil, nil
    end
end

function TrackerQuestTimers:UpdateTimerFrame()
    if (not next(timerLines)) or not (Questie.db.profile.trackerEnabled and Questie.db.char.isTrackerExpanded and (QuestieTracker.disableHooks ~= true)) then
        return
    end

    local font = LSM30:Fetch("font", Questie.db.profile.trackerFontObjective)
    for questId, frames in pairs(timerLines) do
        local timeRemainingString = TrackerQuestTimers:GetRemainingTimeByQuestId(questId)
        if timeRemainingString ~= nil then
            Questie.Debug(Questie.DEBUG_SPAM, "[TrackerQuestTimers:UpdateTimerFrame] - ", timeRemainingString)

            for _, frame in ipairs(frames) do
                frame.label:SetFont(font, Questie.db.profile.trackerFontSizeObjective, Questie.db.profile.trackerFontOutline)
                frame.label:SetText(Questie:Colorize(timeRemainingString, "lightBlue"))
            end
        else
            Questie.Debug(Questie.DEBUG_SPAM, "[TrackerQuestTimers] Quest Timer Expired!")
        end
    end
end