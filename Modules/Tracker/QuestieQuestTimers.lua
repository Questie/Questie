---@class QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:CreateModule("QuestieQuestTimers")

local _QuestieQuestTimers = QuestieQuestTimers.private
_QuestieQuestTimers.timers = {}
QuestieQuestTimers.defaultBlizzPoint = {}

-- Forward declaration
local _UpdateTimerFrame

function QuestieQuestTimers:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "QuestieQuestTimers:Initialize")

    hooksecurefunc("QuestTimerFrame_Update", _UpdateTimerFrame)

    QuestTimerFrame:HookScript("OnShow", function()
        QuestieQuestTimers.defaultBlizzPoint = {QuestTimerFrame:GetPoint()}
        if Questie.db.global.trackerEnabled then
            QuestieQuestTimers:HideBlizzardTimer()
        end
    end)
end

function QuestieQuestTimers:HideBlizzardTimer()
    QuestTimerFrame:SetPoint("TOP", -10000, -10000)
end

function QuestieQuestTimers:ShowBlizzardTimer()
    if QuestieQuestTimers.defaultBlizzPoint[1] then
        QuestTimerFrame:ClearAllPoints()
        QuestTimerFrame:SetPoint(unpack(QuestieQuestTimers.defaultBlizzPoint))
    end
end

function QuestieQuestTimers:GetQuestTimerByQuestId(questId, frame)
    local questLogIndex = GetQuestLogIndexByID(questId)

    if questLogIndex then
        local questTimers = GetQuestTimers()
        if questTimers then
            local numTimers = select("#", questTimers)
            for i=1, numTimers do
                local timerIndex = GetQuestIndexForTimer(i)
                if timerIndex == questLogIndex then
                    local seconds = select(i, questTimers)
                    _QuestieQuestTimers.timers[i] = frame
                    return SecondsToTime(seconds)
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
            timer.label:SetText("    " .. SecondsToTime(seconds))
        end
    else
        _QuestieQuestTimers.timers = {}
    end
end
