dofile("setupTests.lua")

describe("MapDrawQueue", function()
    ---@type MapDrawQueue
    local MapDrawQueue
    local originalGetTimePreciseSec
    local clockSeconds
    local publishedWorld
    local publishedMinimap

    ---The clock only moves when a test says so, so a cycle's stopping point is decided rather than raced.
    ---@param seconds number
    local function AdvanceClock(seconds)
        clockSeconds = clockSeconds + seconds
    end

    ---A publisher that records what it was handed and optionally bills the clock for the work.
    ---@param log table
    ---@param secondsPerCall number?
    local function Recorder(log, secondsPerCall)
        return function(drawCall, context)
            log[#log + 1] = {drawCall = drawCall, context = context}
            if secondsPerCall then
                AdvanceClock(secondsPerCall)
            end
        end
    end

    ---@param worldCount integer
    ---@param minimapCount integer
    local function Fill(worldCount, minimapCount)
        for i = 1, worldCount do
            MapDrawQueue.PushWorld({"world", i})
        end
        for i = 1, minimapCount do
            MapDrawQueue.PushMinimap({"minimap", i})
        end
    end

    before_each(function()
        originalGetTimePreciseSec = _G.GetTimePreciseSec
        clockSeconds = 0
        _G.GetTimePreciseSec = function()
            return clockSeconds
        end
        publishedWorld = {}
        publishedMinimap = {}

        -- Loaded with the stub in place: the module captures the clock at file scope.
        dofile("Modules/Map/MapDrawQueue.lua")
        MapDrawQueue = QuestieLoader:ImportModule("MapDrawQueue")
        MapDrawQueue.MIN_DRAWS_PER_CYCLE = 24
        MapDrawQueue.MAX_DRAWS_PER_CYCLE = 250
        MapDrawQueue.QUEUE_TIME_BUDGET = 0.008
    end)

    after_each(function()
        _G.GetTimePreciseSec = originalGetTimePreciseSec
    end)

    describe("queue mechanics", function()
        it("pops in the order entries were pushed", function()
            Fill(3, 0)

            MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))

            assert.are_same({"world", 1}, publishedWorld[1].drawCall)
            assert.are_same({"world", 2}, publishedWorld[2].drawCall)
            assert.are_same({"world", 3}, publishedWorld[3].drawCall)
        end)

        it("reports depth per surface and emptiness across both", function()
            assert.is_true(MapDrawQueue.IsEmpty())

            Fill(2, 5)

            local worldDepth, minimapDepth = MapDrawQueue.Depth()
            assert.are_same(2, worldDepth)
            assert.are_same(5, minimapDepth)
            assert.is_false(MapDrawQueue.IsEmpty())
        end)

        it("is empty again once drained, with the indices rewound", function()
            Fill(3, 3)
            MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))

            assert.is_true(MapDrawQueue.IsEmpty())
            assert.are_same({0, 0}, {MapDrawQueue.Depth()})
        end)

        it("keeps popping correctly when a drained queue is refilled", function()
            Fill(2, 0)
            MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))
            Fill(2, 0)
            MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))

            assert.are_same(4, #publishedWorld)
            assert.are_same({"world", 1}, publishedWorld[3].drawCall)
        end)
    end)

    describe("cycle policy", function()
        it("publishes at least the minimum even when the deadline has already passed", function()
            Fill(100, 100)
            -- Every call overruns the whole budget, so only the floor can be keeping this going.
            MapDrawQueue.RunCycle(Recorder(publishedWorld, 1), Recorder(publishedMinimap, 0))

            assert.are_same(24, #publishedWorld)
        end)

        it("continues past the minimum while time remains", function()
            Fill(100, 100)
            -- 0.0001s per iteration against a 0.008s budget: the deadline is what stops this, not the floor.
            local processed = MapDrawQueue.RunCycle(Recorder(publishedWorld, 0.0001), Recorder(publishedMinimap))

            assert.is_true(processed > 24)
            assert.are_same(processed, #publishedWorld)
        end)

        it("stops at the deadline once the minimum is met", function()
            Fill(100, 100)
            -- 0.001s each: the floor's 24 already overshoot the 0.008s budget, so nothing follows them.
            local processed = MapDrawQueue.RunCycle(Recorder(publishedWorld, 0.001), Recorder(publishedMinimap))

            assert.are_same(24, processed)
        end)

        it("stops at the absolute maximum when the clock never advances", function()
            Fill(1000, 1000)
            -- A frozen clock leaves the deadline permanently in the future; only the cap can end this.
            local processed = MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))

            assert.are_same(250, processed)
            assert.are_same(250, #publishedWorld)
        end)

        it("drains a short queue completely rather than running to the minimum", function()
            Fill(5, 5)

            local processed = MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))

            assert.are_same(5, processed)
            assert.is_true(MapDrawQueue.IsEmpty())
        end)

        it("keeps draining the longer surface when the two are uneven", function()
            Fill(6, 2)

            MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap))

            assert.are_same(6, #publishedWorld)
            assert.are_same(2, #publishedMinimap)
            assert.is_true(MapDrawQueue.IsEmpty())
        end)

        it("hands the caller's context to both publishers", function()
            Fill(1, 1)

            MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap), 0.85)

            assert.are_same(0.85, publishedWorld[1].context)
            assert.are_same(0.85, publishedMinimap[1].context)
        end)

        it("stops at the minimum on a client with no clock at all", function()
            _G.GetTimePreciseSec = nil
            dofile("Modules/Map/MapDrawQueue.lua")
            MapDrawQueue = QuestieLoader:ImportModule("MapDrawQueue")
            MapDrawQueue.MIN_DRAWS_PER_CYCLE = 24
            MapDrawQueue.MAX_DRAWS_PER_CYCLE = 250
            Fill(100, 100)

            -- No deadline can be built, so the cycle is the fixed floor this replaced.
            assert.are_same(24, MapDrawQueue.RunCycle(Recorder(publishedWorld), Recorder(publishedMinimap)))
        end)
    end)

    describe("scheduling", function()
        local tickers
        local originalTimerAPI
        local originalIsInInstance

        before_each(function()
            originalTimerAPI = _G.C_Timer
            originalIsInInstance = _G.IsInInstance
            tickers = {}
            _G.C_Timer = {
                NewTicker = function(interval, callback)
                    tickers[#tickers + 1] = {interval = interval, callback = callback}
                    return {Cancel = function() end}
                end,
            }
            _G.IsInInstance = function() return false, "none" end
            dofile("Modules/Map/MapDrawQueue.lua")
            MapDrawQueue = QuestieLoader:ImportModule("MapDrawQueue")
        end)

        after_each(function()
            _G.C_Timer = originalTimerAPI
            _G.IsInInstance = originalIsInInstance
        end)

        it("ticks every 0.2 seconds outside a raid", function()
            MapDrawQueue.Start(Recorder(publishedWorld), Recorder(publishedMinimap), function() end)

            assert.are_same(0.2, MapDrawQueue.GetTickRate())
            assert.are_same(0.2, tickers[1].interval)
        end)

        it("halves the rate in a raid, which has plenty else to do with the frame", function()
            _G.IsInInstance = function() return true, "raid" end

            MapDrawQueue.Start(Recorder(publishedWorld), Recorder(publishedMinimap), function() end)

            assert.are_same(0.4, MapDrawQueue.GetTickRate())
        end)

        it("creates the ticker once however often it is started", function()
            local start = function()
                MapDrawQueue.Start(Recorder(publishedWorld), Recorder(publishedMinimap), function() end)
            end
            start() start() start()

            assert.are_same(1, #tickers)
        end)

        it("draws a batch when the ticker fires, with the context evaluated per cycle", function()
            local contexts = 0
            MapDrawQueue.Start(Recorder(publishedWorld), Recorder(publishedMinimap), function()
                contexts = contexts + 1
                return contexts
            end)
            Fill(3, 3)

            tickers[1].callback()

            assert.are_same(3, #publishedWorld)
            assert.are_same(1, publishedWorld[1].context)
            -- One evaluation for the whole batch, not one per icon.
            assert.are_same(1, contexts)
        end)

        it("does no work and reads no context when the queue is empty", function()
            local contexts = 0
            MapDrawQueue.Start(Recorder(publishedWorld), Recorder(publishedMinimap), function()
                contexts = contexts + 1
            end)

            tickers[1].callback()

            assert.are_same(0, contexts)
            assert.are_same(0, #publishedWorld)
        end)
    end)
    describe("shipping defaults", function()
        local originalIsHardcore

        before_each(function()
            originalIsHardcore = Questie.IsHardcore
        end)

        after_each(function()
            Questie.IsHardcore = originalIsHardcore
        end)

        ---@param hardcore boolean?
        local function LoadFor(hardcore)
            Questie.IsHardcore = hardcore
            dofile("Modules/Map/MapDrawQueue.lua")
            return QuestieLoader:ImportModule("MapDrawQueue")
        end

        it("publishes 24 per cycle within an 8 ms budget on a normal realm", function()
            local queue = LoadFor(nil)

            assert.are_same(24, queue.MIN_DRAWS_PER_CYCLE)
            assert.are_same(0.008, queue.QUEUE_TIME_BUDGET)
        end)

        it("halves both the floor and the budget on hardcore", function()
            local queue = LoadFor(true)

            -- Deliberate, not incidental: the watchdog is stricter there, so drain speed is given up first.
            assert.are_same(12, queue.MIN_DRAWS_PER_CYCLE)
            assert.are_same(0.004, queue.QUEUE_TIME_BUDGET)
        end)

        it("keeps a budget that outlives its own floor, or it would do nothing", function()
            for _, hardcore in ipairs({false, true}) do
                local queue = LoadFor(hardcore)
                -- One floor cycle measured at ~0.105 ms per icon on the machine this was tuned on. A budget
                -- below that cost is spent before the floor releases, which makes the whole mechanism inert.
                local floorCost = queue.MIN_DRAWS_PER_CYCLE * 0.000105
                assert.is_true(queue.QUEUE_TIME_BUDGET > floorCost,
                    "budget must exceed the floor's own cost, hardcore=" .. tostring(hardcore))
            end
        end)

        it("caps a cycle well above anything the budget can reach", function()
            local queue = LoadFor(nil)

            assert.is_true(queue.MAX_DRAWS_PER_CYCLE > 223)
        end)
    end)
end)
