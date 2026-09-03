---@class MapDrawQueue
local MapDrawQueue = QuestieLoader:CreateModule("MapDrawQueue")

-- Icons are published to HereBeDragons a batch at a time rather than all at once, so a large redraw does not
-- land in a single frame. This file owns the two queues that hold the pending work and the policy that decides
-- how much of it one cycle may do. What a published icon actually *is* stays in QuestieMap: this knows only
-- that entries go in, come out in order, and that a cycle has a budget.
--
-- Keeping it to that is the point. There is nothing here but two tables and a clock, so the policy below can
-- be tested for what it does at a deadline, at a floor and at a ceiling without standing up HereBeDragons, a
-- frame pool, or a saved-variable profile first.

local getTimePreciseSec = GetTimePreciseSec

-------------------------
-- Queue mechanics
-------------------------
-- O(1) FIFO. `table.remove(queue, 1)` shifts every remaining entry down one slot, so draining N icons costs
-- O(N^2): measured on a real redraw of 877 queued pairs, the shifting alone was 0.83 ms per cycle and 46 ms
-- across the drain, which was most of what the cycle spent. A head index costs one read and one nil write per
-- pop no matter how deep the queue is.
--
-- `head > tail` means empty. Both rewind to 1/0 when the queue drains, so the indices cannot climb forever and
-- the entries array never keeps a growing hole at the front.
---@class QuestieDrawQueue
---@field entries table<integer, table>
---@field head integer @Next entry to pop
---@field tail integer @Last entry pushed
local worldQueue = {entries = {}, head = 1, tail = 0}
local minimapQueue = {entries = {}, head = 1, tail = 0}

---@param queue QuestieDrawQueue
---@param drawCall table
local function Push(queue, drawCall)
    local tail = queue.tail + 1
    queue.tail = tail
    queue.entries[tail] = drawCall
end

---@param queue QuestieDrawQueue
---@return table? drawCall
local function Pop(queue)
    local head = queue.head
    if head > queue.tail then
        return nil
    end

    local entries = queue.entries
    local drawCall = entries[head]
    entries[head] = nil
    if head == queue.tail then
        queue.head = 1
        queue.tail = 0
    else
        queue.head = head + 1
    end
    return drawCall
end

---@param queue QuestieDrawQueue
---@return integer
local function Depth(queue)
    return queue.tail - queue.head + 1
end

---@param drawCall table @Arguments for HBDPins:AddWorldMapIconMap
function MapDrawQueue.PushWorld(drawCall)
    Push(worldQueue, drawCall)
end

---@param drawCall table @Arguments for HBDPins:AddMinimapIconMap
function MapDrawQueue.PushMinimap(drawCall)
    Push(minimapQueue, drawCall)
end

---Both queues are empty. Callers wait on this rather than on a length, because a head index leaves the entries
---array with a moving start and `#` cannot describe it.
---@return boolean
function MapDrawQueue.IsEmpty()
    return worldQueue.head > worldQueue.tail and minimapQueue.head > minimapQueue.tail
end

---@return integer worldDepth
---@return integer minimapDepth
function MapDrawQueue.Depth()
    return Depth(worldQueue), Depth(minimapQueue)
end

-------------------------
-- Cycle policy
-------------------------
-- The floor is what a cycle publishes even when the clock says stop, so it is the one number here that is a
-- cost rather than a limit: a cycle can never be cheaper than the floor, however slow the machine. 24 is what
-- this addon has always published per cycle, so leaving it there is what makes the budget safe on hardware
-- unlike the machine it was tuned on. A slower machine fits fewer iterations into the same time, so the
-- adaptive part contributes less and less until it contributes nothing, at which point a cycle is exactly what
-- it always was. The budget can only add work where there is room for it.
MapDrawQueue.MIN_DRAWS_PER_CYCLE = 24

-- Insurance against a clock that stops advancing, not a throughput control: with a working clock the budget
-- always binds first. Measured on Era, the largest cycle any sane budget produced was 223 iterations at 16 ms,
-- so this leaves room above every budget below while still bounding the pathological cycle.
MapDrawQueue.MAX_DRAWS_PER_CYCLE = 250

-- Measured on Era against a 952-deep queue: 4 ms drains it in 5.4 s with a 4.7 ms worst cycle, 8 ms in 1.8 s
-- with 8.1 ms, and the old fixed 24 took 8.2 s at 3.4 ms. Anything at or below 2 ms is indistinguishable from
-- no budget at all, because one floor cycle already costs more than that - a budget under the floor's own cost
-- cannot do anything.
MapDrawQueue.QUEUE_TIME_BUDGET = 0.008

if Questie.IsHardcore then
    -- Blizzard's addon watchdog is far stricter on HC realms, and the same reasoning as QuestieMap's
    -- TICKS_PER_YIELD applies: give up drain speed rather than risk a less performant machine tripping it.
    --
    -- 4 ms rather than 2 because 2 buys nothing measurable - one floor cycle already costs more than that, so
    -- the deadline is behind us by the time the floor releases. Measured back to back on Era: the fixed 24
    -- drained in 4.15 s at 24 icons per cycle, 4 ms drained in 2.6 s at 40, for 0.7 ms on a typical cycle.
    MapDrawQueue.QUEUE_TIME_BUDGET = 0.004

    -- Halving the floor costs nothing on a machine with headroom and halves the guaranteed cost on one
    -- without. Measured on Era at this budget, 12 and 24 were indistinguishable - 2.6-3.1 s to drain and
    -- 35-38 icons per cycle either way - because the budget lets ~37 through and the floor never binds.
    --
    -- It only starts to matter about 1.6x slower than that, and by 3.2x slower a cycle is the floor and
    -- nothing else: 12 icons for roughly 4 ms where 24 would have cost 8. Those clients draw their icons at
    -- half the rate, which is the trade being made on purpose. Note this halves the exposure rather than
    -- capping it - the floor is a count, not a duration, so a bad enough client can still overrun.
    MapDrawQueue.MIN_DRAWS_PER_CYCLE = 12
end

---@alias MapDrawQueueDrawer fun(drawCall: table, context: any)

---Draws one batch, pairing a world icon with a minimap icon per iteration the way the queues are filled.
---
---GetTimePreciseSec rather than debugprofilestop: any addon can reset the latter to zero, and a reset landing
---mid-cycle would make the deadline unreachable and run the cycle out to its absolute maximum. A client with
---no clock at all stops at the floor, which is the fixed behaviour this replaced.
---@param drawWorldIcon MapDrawQueueDrawer
---@param drawMinimapIcon MapDrawQueueDrawer
---@param context any @Passed to both callbacks; the caller's per-cycle state, not the queue's business
---@return integer processed @Iterations run, which is at most one publication of each kind
function MapDrawQueue.RunCycle(drawWorldIcon, drawMinimapIcon, context)
    local minimumDraws = MapDrawQueue.MIN_DRAWS_PER_CYCLE
    local maximumDraws = MapDrawQueue.MAX_DRAWS_PER_CYCLE
    local deadline = getTimePreciseSec and (getTimePreciseSec() + MapDrawQueue.QUEUE_TIME_BUDGET) or nil

    local processed = 0
    while (not MapDrawQueue.IsEmpty())
        and processed < maximumDraws
        and (processed < minimumDraws or (deadline ~= nil and getTimePreciseSec() < deadline)) do
        processed = processed + 1

        local worldCall = Pop(worldQueue)
        if worldCall then
            drawWorldIcon(worldCall, context)
        end

        local minimapCall = Pop(minimapQueue)
        if minimapCall then
            drawMinimapIcon(minimapCall, context)
        end
    end

    return processed
end

-------------------------
-- Scheduling
-------------------------
-- The ticker lives here rather than in QuestieMap because the tick rate and the cycle budget are one policy:
-- how much drawing happens per unit of time. Splitting them across two files meant reading both to answer that.
local drawTimer
local drawQueueTickRate

---Starts draining the queue on a timer. Safe to call repeatedly; the timer is created once.
---@param drawWorldIcon MapDrawQueueDrawer
---@param drawMinimapIcon MapDrawQueueDrawer
---@param getContext fun(): any @Evaluated once per cycle and handed to both callbacks
function MapDrawQueue.Start(drawWorldIcon, drawMinimapIcon, getContext)
    local isInInstance, instanceType = IsInInstance()
    -- Raids run the cycle half as often, having plenty else to do with the frame.
    drawQueueTickRate = (isInInstance and instanceType == "raid") and 0.4 or 0.2

    if drawTimer then
        -- Behaviour preserved from before this was its own file: the rate above is recomputed on every
        -- loading screen but an existing ticker keeps the interval it was created with, so entering a raid
        -- mid-session does not actually slow the cycle down. Changing that is a behaviour change, not a move.
        return
    end

    drawTimer = C_Timer.NewTicker(drawQueueTickRate, function()
        if MapDrawQueue.IsEmpty() then
            return
        end
        MapDrawQueue.RunCycle(drawWorldIcon, drawMinimapIcon, getContext())
    end)
end

---@return number? tickRate @Seconds between cycles; nil before Start
function MapDrawQueue.GetTickRate()
    return drawQueueTickRate
end
