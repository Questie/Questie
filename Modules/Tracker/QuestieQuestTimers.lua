---@class QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:CreateModule("QuestieQuestTimers")
local _QuestieQuestTimers = {}

local blizzardTimerLocation = {}
local timer

function QuestieQuestTimers:Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieQuestTimers:Initialize")
    if Questie.IsWotlk then
        -- For now we assume there are no timed quests in Wotlk
        return
    end

    if not QuestTimerFrame_Update then
        Questie:Debug(Questie.DEBUG_CRITICAL, "No QuestTimerFrame_Update. Retrying to hooksecurefunc in 5 seconds.")
        C_Timer.After(5, function()
            if not QuestTimerFrame_Update then
                Questie:Debug(Questie.DEBUG_CRITICAL, "Still no QuestTimerFrame_Update. Something is strange.")
                return
            end
            hooksecurefunc("QuestTimerFrame_Update", _QuestieQuestTimers.UpdateTimerFrame)
        end)
    else
        hooksecurefunc("QuestTimerFrame_Update", _QuestieQuestTimers.UpdateTimerFrame)
    end

    QuestTimerFrame:HookScript("OnShow", function()
        blizzardTimerLocation = {QuestTimerFrame:GetPoint()}
        if Questie.db.global.trackerEnabled and not Questie.db.global.showBlizzardQuestTimer then
            QuestieQuestTimers:HideBlizzardTimer()
        else
            QuestieQuestTimers:ShowBlizzardTimer()
        end
    end)
end

function QuestieQuestTimers:HideBlizzardTimer()
    if Questie.IsWotlk then
        -- For now we assume there are no timed quests in Wotlk
        return
    end
    QuestTimerFrame:ClearAllPoints()
    QuestTimerFrame:SetPoint("TOP", -10000, -10000)
end

function QuestieQuestTimers:ShowBlizzardTimer()
    if blizzardTimerLocation[1] then
        QuestTimerFrame:ClearAllPoints()
        QuestTimerFrame:SetPoint(unpack(blizzardTimerLocation))
    end
end

function QuestieQuestTimers:GetRemainingTime(questId, frame, clear)
    if Questie.IsWotlk then
        -- For now we assume there are no timed quests in Wotlk
        return nil
    end
    local remainingSeconds = _QuestieQuestTimers:GetRemainingTime(questId)

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

function _QuestieQuestTimers:GetRemainingTime(questId)
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
            return SecondsToTime(seconds)
        else
            return nil
        end
    else
        Questie:Error("The return value of GetQuestTimers is not number, something is off. Please report this!")
    end

    return nil
end

function _QuestieQuestTimers:UpdateTimerFrame()
    if InCombatLockdown() then
        return
    end

    if timer then
        local seconds = _QuestieQuestTimers:GetRemainingTime(timer.questId)
        if (not seconds) then
            return
        end
        timer.frame.label:SetText(Questie:Colorize(seconds, "blue"))
        timer.frame:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
    end
end
