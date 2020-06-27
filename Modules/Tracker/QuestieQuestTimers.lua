---@class QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:CreateModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

local _QuestieQuestTimers = QuestieQuestTimers.private
_QuestieQuestTimers.timers = {}
QuestieQuestTimers.defaultBlizzPoint = {}

-- Forward declaration
local _UpdateTimerFrame

function QuestieQuestTimers:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "QuestieQuestTimers:Initialize")

    if QuestTimerFrame_Update == nil then
        Questie:Debug(DEBUG_CRITICAL, "QuestTimerFrame_Update is nil. Retrying to hooksecurefunc in 5 seconds.")
        C_Timer.After(5, function()
            if QuestTimerFrame_Update == nil then
                Questie:Debug(DEBUG_CRITICAL, "QuestTimerFrame_Update is still nil. Something is strange.")
                return
            end
            hooksecurefunc("QuestTimerFrame_Update", _UpdateTimerFrame)
        end)
    else
        hooksecurefunc("QuestTimerFrame_Update", _UpdateTimerFrame)
    end

    QuestTimerFrame:HookScript("OnShow", function()
        QuestieQuestTimers.defaultBlizzPoint = {QuestTimerFrame:GetPoint()}
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
    if QuestieQuestTimers.defaultBlizzPoint[1] then
        QuestTimerFrame:ClearAllPoints()
        QuestTimerFrame:SetPoint(unpack(QuestieQuestTimers.defaultBlizzPoint))
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
                        _QuestieQuestTimers.timers[i] = nil

                    elseif frame then
                        _QuestieQuestTimers.timers[i] = frame

                        return SecondsToTime(seconds)
                    end
                end
            end
        end
    end
    return nil
end

_UpdateTimerFrame = function()
    local questTimers = GetQuestTimers()
    if questTimers then
        for i, timer in pairs(_QuestieQuestTimers.timers) do
            local seconds = select(i, questTimers)
            QuestieCombatQueue:Queue(function()
                timer.label:SetText("    " .. SecondsToTime(seconds))
            end)
        end
    else
        _QuestieQuestTimers.timers = {}
    end
end
