---@class WatchFrameHook
local WatchFrameHook = QuestieLoader:CreateModule("WatchFrameHook")

local WatchFrame, QuestTimerFrame = WatchFrame, QuestTimerFrame

function WatchFrameHook.Hide()
    if (Questie.IsWotlk or Questie.IsCata) and QuestTimerFrame then
        QuestTimerFrame:Hide()
    end

    WatchFrame:Hide()
end
