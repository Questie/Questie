---@type QuestieLoader
local QuestieLoader = select(2, ...).QuestieLoader

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class WatchFrameHook
local WatchFrameHook = QuestieLoader:CreateModule("WatchFrameHook")

local QuestTimerFrame = QuestTimerFrame

function WatchFrameHook.Hide()
    if QuestTimerFrame then
        QuestTimerFrame:Hide()
    end

    QuestieCompat.HideWatchFrame()
end