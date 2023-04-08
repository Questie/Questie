---@class TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:CreateModule("TrackerQuestTimers")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

local LSM30 = LibStub("LibSharedMedia-3.0")

local blizzardTimerLocation = {}
local timer

function TrackerQuestTimers:Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "TrackerQuestTimers:Initialize")
    if Questie.IsWotlk then
        -- QuestTimerFrame_Update doesn't exist in WotLK
        return
    end

    if not QuestTimerFrame_Update then
        Questie:Debug(Questie.DEBUG_CRITICAL, "No QuestTimerFrame_Update. Retrying to hooksecurefunc in 5 seconds.")
        C_Timer.After(5, function()
            if not QuestTimerFrame_Update then
                Questie:Debug(Questie.DEBUG_CRITICAL, "Still no QuestTimerFrame_Update. Something is strange.")
                return
            end
            hooksecurefunc("QuestTimerFrame_Update", TrackerQuestTimers.UpdateTimerFrame)
        end)
    else
        hooksecurefunc("QuestTimerFrame_Update", TrackerQuestTimers.UpdateTimerFrame)
    end

    QuestTimerFrame:HookScript("OnShow", function()
        blizzardTimerLocation = {QuestTimerFrame:GetPoint()}
        if Questie.db.global.trackerEnabled and not Questie.db.global.showBlizzardQuestTimer then
            TrackerQuestTimers:HideBlizzardTimer()
        else
            TrackerQuestTimers:ShowBlizzardTimer()
        end
    end)
end

function TrackerQuestTimers:HideBlizzardTimer()
    -- Classic WotLK
    if Questie.IsWotlk then
        WatchFrame:Hide()
        return
    end

    -- Classic WoW
    QuestTimerFrame:ClearAllPoints()
    QuestTimerFrame:SetPoint("TOP", -10000, -10000)
end

function TrackerQuestTimers:ShowBlizzardTimer()
    -- Classic WotLK
    if Questie.IsWotlk then
        WatchFrame:Show()
        return
    end

    -- Classic WoW
    if blizzardTimerLocation[1] then
        QuestTimerFrame:ClearAllPoints()
        QuestTimerFrame:SetPoint(unpack(blizzardTimerLocation))
    end
end

function TrackerQuestTimers:GetRemainingTime(questId, frame, clear)
    local remainingSeconds = TrackerQuestTimers:GetRemainingTimeByQuestId(questId)

    if (not remainingSeconds) then
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

    return remainingSeconds
end

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
        local seconds = GetQuestLogTimeLeft(questLogIndex)
        SelectQuestLogEntry(currentQuestLogSelection)

        if seconds then
            return SecondsToTime(seconds, false, true), seconds
        else
            return nil
        end
    else
        Questie:Error("The return value of GetQuestTimers is not number, something is off. Please report this!")
    end

    return nil
end

function TrackerQuestTimers:UpdateTimerFrame()
    QuestieCombatQueue:Queue(function()
        if timer then
            local remainingSeconds = TrackerQuestTimers:GetRemainingTimeByQuestId(timer.questId)
            if (not remainingSeconds) then
                return
            end
            timer.frame.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeObjective, TrackerLinePool.GetOutline)
            timer.frame.label:SetText(Questie:Colorize(remainingSeconds, "blue"))
        end
    end)
end
