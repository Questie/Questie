---@class TrackerEscapeHandler
local TrackerEscapeHandler = QuestieLoader:CreateModule("TrackerEscapeHandler")

---@class TrackHeaderFrame
local TrackerHeaderFrame = QuestieLoader:ImportModule("TrackerHeaderFrame")

local escHandlerFrame

function TrackerEscapeHandler.Initialize(frame)
    escHandlerFrame = frame.trackedQuests
end

function TrackerEscapeHandler.SetEscHandlerFrame(frame)
    escHandlerFrame = frame
end

function TrackerEscapeHandler.SetEscapeBinding()
    SetOverrideBindingClick(escHandlerFrame, false, "ESCAPE", "ToggleHandler")
end

function TrackerEscapeHandler.ClearEscapeBinding()
    ClearOverrideBindings(escHandlerFrame)
end

return TrackerEscapeHandler
