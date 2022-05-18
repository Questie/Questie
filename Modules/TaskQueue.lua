---@class TaskQueue
local TaskQueue = QuestieLoader:CreateModule("TaskQueue")
local _TaskQueue = TaskQueue.private

_TaskQueue.queue = {}
function TaskQueue:OnUpdate()
    local val = table.remove(_TaskQueue.queue, 1)
    if val then val() end
end

function TaskQueue:Queue(...)
    for _,val in pairs({...}) do
        table.insert(_TaskQueue.queue, val)
    end
end

local taskQueueEventFrame = CreateFrame("Frame", "QuestieTaskQueueEventFrame", UIParent)
taskQueueEventFrame:SetScript("OnUpdate", TaskQueue.OnUpdate)
taskQueueEventFrame:Show()