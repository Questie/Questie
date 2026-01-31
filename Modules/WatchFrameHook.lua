---@class WatchFrameHook
local WatchFrameHook = QuestieLoader:CreateModule("WatchFrameHook")

local WatchFrame, QuestTimerFrame = WatchFrame or QuestWatchFrame, QuestTimerFrame

function WatchFrameHook.Hide()
    if QuestTimerFrame then
        QuestTimerFrame:Hide()
    end

    WatchFrame:Hide()
end

return WatchFrameHook
