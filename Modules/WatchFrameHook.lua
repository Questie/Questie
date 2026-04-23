---@class WatchFrameHook
local WatchFrameHook = QuestieLoader:CreateModule("WatchFrameHook")

local QuestTimerFrame = QuestTimerFrame

function WatchFrameHook.Hide()
    if QuestTimerFrame then
        QuestTimerFrame:Hide()
    end

    QuestieCompat.HideWatchFrame()
end

return WatchFrameHook
