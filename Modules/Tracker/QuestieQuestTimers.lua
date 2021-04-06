---@class QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:CreateModule("QuestieQuestTimers")
local _QuestieQuestTimers = {}

local blizzardTimerLocation = {}
local timers = {}

function QuestieQuestTimers:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "QuestieQuestTimers:Initialize")

    if QuestTimerFrame_Update == nil then
        Questie:Debug(DEBUG_CRITICAL, "QuestTimerFrame_Update is nil. Retrying to hooksecurefunc in 5 seconds.")
        C_Timer.After(5, function()
            if QuestTimerFrame_Update == nil then
                Questie:Debug(DEBUG_CRITICAL, "QuestTimerFrame_Update is still nil. Something is strange.")
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
    QuestTimerFrame:ClearAllPoints()
    QuestTimerFrame:SetPoint("TOP", -10000, -10000)
end

function QuestieQuestTimers:ShowBlizzardTimer()
    if blizzardTimerLocation[1] then
        QuestTimerFrame:ClearAllPoints()
        QuestTimerFrame:SetPoint(unpack(blizzardTimerLocation))
    end
end

function QuestieQuestTimers:GetQuestTimerByQuestId(questId, frame, clear)
    local questLogIndex = GetQuestLogIndexByID(questId)
    if questLogIndex then
        local questTimers = GetQuestTimers()
        if questTimers then
            local numTimers = select("#", questTimers)
            for i=1, numTimers do
                local timerIndex = GetQuestIndexForTimer(i)
                if timerIndex == questLogIndex then
                    local seconds = select(i, questTimers)
                    if clear then
                        timers[i] = nil
                    elseif frame then
                        timers[i] = frame
                        return SecondsToTime(seconds)
                    end
                end
            end
        end
    end
    return nil
end

function _QuestieQuestTimers:UpdateTimerFrame()
    if InCombatLockdown() then
        return
    end

    local questTimers = GetQuestTimers()
    if questTimers then
        for i, timer in pairs(timers) do
            if timers[i] == nil then
                timer.label:SetText(" ")
            else
                local seconds = select(i, questTimers)
                timer.label:SetText(SecondsToTime(seconds))
                timer:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
            end
        end
    else
        timers = {}
    end
end
