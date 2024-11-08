---@class TaskQueue
local TaskQueue = QuestieLoader:CreateModule("TaskQueue")
local _TaskQueue = TaskQueue.private

local isRunning = false

_TaskQueue.queue = {}
function TaskQueue:OnUpdate()
    if isRunning then
        -- We want tasks to be ran sequentially, not multiple at once to avoid race conditions
        return
    end
    local val = table.remove(_TaskQueue.queue, 1)
    if val then
        isRunning = true
        val()
        isRunning = false
    end
end

function TaskQueue:Queue(...)
    for _,val in pairs({...}) do
        table.insert(_TaskQueue.queue, val)
    end
end

local taskQueueEventFrame = CreateFrame("Frame", "QuestieTaskQueueEventFrame", UIParent)
taskQueueEventFrame:SetScript("OnUpdate", TaskQueue.OnUpdate)
taskQueueEventFrame:Show()
