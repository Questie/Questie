---@class TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:CreateModule("TrackerQuestTimers")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

local LSM30 = LibStub("LibSharedMedia-3.0")

local WatchFrame = QuestTimerFrame or WatchFrame
local blizzardTimerLocation = {}
local timer

-- Save the default location of the Blizzard QuestTimerFrame
if not Questie.IsWotlk then
    blizzardTimerLocation = {QuestTimerFrame:GetPoint()}
end

function TrackerQuestTimers:Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "TrackerQuestTimers:Initialize")

    if QuestieTracker.started or (not Questie.db.global.trackerEnabled) then
        return
    end

    -- All Classic expansions
    WatchFrame:HookScript("OnShow", function()
        if Questie.db.global.showBlizzardQuestTimer then
            TrackerQuestTimers:ShowBlizzardTimer()
        else
            TrackerQuestTimers:HideBlizzardTimer()
        end
    end)

    -- Pre-Classic WotLK
    if not Questie.IsWotlk then
        local timeElapsed = 0

        WatchFrame:HookScript("OnUpdate", function(_, elapsed)
            timeElapsed = timeElapsed + elapsed
            if timeElapsed > 1 then
                TrackerQuestTimers:UpdateTimerFrame()
                timeElapsed = 0
            end
        end)
    end
end

function TrackerQuestTimers:HideBlizzardTimer()
    if Questie.IsWotlk then
        -- Classic WotLK
        WatchFrame:Hide()
    else
        -- Classic WoW: This move the QuestTimerFrame off screen. A faux Hide().
        -- Otherwise, if the frame is hidden then the OnUpdate doesn't work.
        WatchFrame:ClearAllPoints()
        WatchFrame:SetPoint("TOP", -10000, -10000)
    end
end

function TrackerQuestTimers:ShowBlizzardTimer()
    if Questie.IsWotlk then
        -- Classic WotLK
        WatchFrame:Show()
    else
        -- Classic WoW: This moves the QuestTimerFrame
        -- back its default location. A faux Show()
        if blizzardTimerLocation[1] then
            WatchFrame:ClearAllPoints()
            WatchFrame:SetPoint(unpack(blizzardTimerLocation))
        end
    end
end

---@param questId number
---@param frame frame
---@param clear boolean
---@return string timeRemainingString, number timeRemaining, nil
function TrackerQuestTimers:GetRemainingTime(questId, frame, clear)
    local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(questId)

    if (timeRemainingString == nil) then
        return nil
    end

    if clear then
        timer = nil

    elseif frame then
        timer = {
            frame = frame,
            questId = questId
        }
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

    if type(questTimers) == "number" then
        local currentQuestLogSelection = GetQuestLogSelection()
        SelectQuestLogEntry(questLogIndex)
        -- We can't use GetQuestTimers because we don't know for which quest the timer is.
        -- GetQuestLogTimeLeft returns the correct value though.
        local timeRemaining = GetQuestLogTimeLeft(questLogIndex)
        SelectQuestLogEntry(currentQuestLogSelection)

        if timeRemaining ~= nil then
            local timeRemainingString = SecondsToTime(timeRemaining, false, true)

            if not strfind(timeRemainingString, "Seconds?") then
                timeRemainingString = timeRemainingString.." 0 Seconds"
            end
            return timeRemainingString, timeRemaining

        else
            return nil
        end
    else
        Questie:Error("The return value of GetQuestTimers is not number, something is off. Please report this!")
    end

    return nil
end

function TrackerQuestTimers:UpdateTimerFrame()
    if timer and (Questie.db.global.trackerEnabled and Questie.db.char.isTrackerExpanded and (QuestieTracker.disableHooks ~= true)) then
        local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(timer.questId)
        if timeRemainingString ~= nil then
            Questie:Debug(Questie.DEBUG_SPAM, "TrackerQuestTimers:UpdateTimerFrame - ", timeRemainingString)
            timer.frame.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeObjective, TrackerLinePool.GetOutline)
            timer.frame.label:SetText(Questie:Colorize(timeRemainingString, "blue"))
        else
            return
        end
    end
end