---@class TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:CreateModule("TrackerQuestTimers")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local LSM30 = LibStub("LibSharedMedia-3.0")

-- QuestTimerFrame is present in Cataclysm, WatchFrame is present in WotLK. Era/SoX does not have a timer frame.
local QuestTimerFrame = QuestTimerFrame or WatchFrame
local timer

function TrackerQuestTimers:Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerQuestTimers:Initialize]")

    if QuestieTracker.started or (not Questie.db.profile.trackerEnabled) then
        return
    end

    if Expansions.Current >= Expansions.Wotlk then
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
    if QuestTimerFrame then
        QuestTimerFrame:Show()
    end
end

---@param quest table
---@param frame LineFrame|nil
---@param clear boolean
---@return string|nil timeRemainingString, number|nil timeRemaining
function TrackerQuestTimers:UpdateAndGetRemainingTime(quest, frame, clear)
    local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(quest.Id)

    if (timeRemainingString == nil) then
        quest.timedBlizzardQuest = nil
        quest.trackTimedQuest = false
        return nil
    end

    if clear then
        timer = nil
    elseif frame then
        timer = {
            frame = frame,
            questId = quest.Id
        }
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
---@return string timeRemainingString, number timeRemaining, nil
function TrackerQuestTimers:GetRemainingTimeByQuestId(questId)
    local questLogIndex = GetQuestLogIndexByID(questId)
    if (not questLogIndex) then
        return nil
    end

    local questTimers = GetQuestTimers(questId)
    if (not questTimers) then
        return nil
    end

    local currentQuestLogSelection = GetQuestLogSelection()
    SelectQuestLogEntry(questLogIndex)
    -- We can't use GetQuestTimers because we don't know for which quest the timer is.
    -- GetQuestLogTimeLeft returns the correct value though.
    local timeRemaining = GetQuestLogTimeLeft(questLogIndex)
    SelectQuestLogEntry(currentQuestLogSelection)

    if timeRemaining ~= nil then
        local timeRemainingString = SecondsToTime(timeRemaining, false, true)

        return timeRemainingString, timeRemaining
    else
        return nil
    end
end

function TrackerQuestTimers:UpdateTimerFrame()
    if timer and (Questie.db.profile.trackerEnabled and Questie.db.char.isTrackerExpanded and (QuestieTracker.disableHooks ~= true)) then
        local timeRemainingString = TrackerQuestTimers:GetRemainingTimeByQuestId(timer.questId)
        if timeRemainingString ~= nil then
            Questie:Debug(Questie.DEBUG_SPAM, "[TrackerQuestTimers:UpdateTimerFrame] - ", timeRemainingString)

            QuestieCombatQueue:Queue(function()
                timer.frame.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontObjective), Questie.db.profile.trackerFontSizeObjective, Questie.db.profile.trackerFontOutline)
                timer.frame.label:SetText(Questie:Colorize(timeRemainingString, "blue"))
                timer.frame:SetWidth(timer.frame.label:GetWidth() + ((34) - (18 - Questie.db.profile.trackerFontSizeQuest)) + Questie.db.profile.trackerFontSizeQuest)
            end)
        else
            Questie:Debug(Questie.DEBUG_SPAM, "[TrackerQuestTimers] Quest Timer Expired!")
            return
        end
    end
end

return TrackerQuestTimers
