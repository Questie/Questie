---Work that goes through whole databases, like searching for a name or sorting quests into categories.
---@class JourneyThread
local JourneyThread = QuestieLoader:CreateModule("JourneyThread")

---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

local budget = ThreadLib.CreateFrameBudget(0.008)

---Has to be called often enough for the steps in between to be short.
JourneyThread.YieldIfNeeded = budget.YieldIfSpent

---Starts work that can yield. It runs from the next frame on.
---@param name string What the profiler calls it
---@param work fun()
---@return Ticker timer Cancelling it stops the work
function JourneyThread.Start(name, work)
    return (ThreadLib.Thread(work, 0, "Error in " .. name .. ":", nil, nil, name))
end

return JourneyThread
