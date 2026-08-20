dofile("setupTests.lua")

describe("ThreadLib", function()
    ---@type ThreadLib
    local ThreadLib

    local tickerFn

    before_each(function()
        -- Stub C_Timer.NewTicker so we can drive the ticker synchronously in tests.
        _G.C_Timer = {
            NewTicker = function(_, fn)
                tickerFn = fn
                return {Cancel = function() tickerFn = nil end}
            end
        }
        _G.debugstack = function() return "" end

        dofile("Modules/Libs/ThreadLib.lua")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
    end)

    local function tick()
        if tickerFn then
            tickerFn()
        end
    end

    describe("Thread", function()
        it("should call callbackFunction when the coroutine finishes", function()
            local callback = spy.new(function() end)

            ThreadLib.Thread(function() end, 0, nil, callback)

            tick() -- coroutine runs to completion -> status "dead" -> callback
            tick() -- second tick fires the "dead" branch

            assert.spy(callback).was.called()
        end)

        it("should call errorCallback when the coroutine errors", function()
            local errorCallback = spy.new(function() end)

            Questie.Error = function() end -- suppress output

            ThreadLib.Thread(function() error("boom") end, 0, nil, nil, errorCallback)

            tick() -- coroutine resumes and errors -> errorCallback fires

            assert.spy(errorCallback).was.called()
        end)

        it("should not call callbackFunction when the coroutine errors", function()
            local callback = spy.new(function() end)

            Questie.Error = function() end

            ThreadLib.Thread(function() error("boom") end, 0, nil, callback, function() end)

            tick()

            assert.spy(callback).was.not_called()
        end)

        it("should not call errorCallback when the coroutine finishes successfully", function()
            local errorCallback = spy.new(function() end)

            ThreadLib.Thread(function() end, 0, nil, nil, errorCallback)

            tick()
            tick()

            assert.spy(errorCallback).was.not_called()
        end)

        it("should error when errorCallback is not a function", function()
            assert.has_error(function()
                ThreadLib.Thread(function() end, 0, nil, nil, "not a function")
            end)
        end)
    end)
end)

describe("ThreadLib profiling callbacks", function()
    ---@type ThreadLib
    local ThreadLib
    local tickerCallbacks
    local cancelledTickers
    local originalTimerAPI = _G.C_Timer
    local originalQuestieError = _G.Questie.Error
    local originalDebugStack = _G.debugstack

    before_each(function()
        tickerCallbacks = {}
        cancelledTickers = {}
        _G.C_Timer = {
            NewTicker = function(_, callback)
                local ticker = {
                    Cancel = function(self)
                        self.cancelled = true
                    end,
                }
                table.insert(tickerCallbacks, callback)
                table.insert(cancelledTickers, ticker)
                return ticker
            end,
        }
        _G.Questie.Error = function() end
        _G.debugstack = function() return "test stack" end

        dofile("Modules/Libs/ThreadLib.lua")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
    end)

    after_each(function()
        _G.C_Timer = originalTimerAPI
        _G.Questie.Error = originalQuestieError
        _G.debugstack = originalDebugStack
    end)

    it("surrounds every yielded and completing resume with one callback registration", function()
        local events = {}
        local owner = {}
        ThreadLib.SetProfilingCallbacks(owner, {
            OnThreadCreated = function(thread, submittedFunction, callSiteStack, threadName)
                table.insert(events, {"created", thread, submittedFunction, callSiteStack, threadName})
            end,
            BeforeResume = function(thread)
                table.insert(events, {"before", thread})
            end,
            AfterResume = function(thread, success, status)
                table.insert(events, {"after", thread, success, status})
            end,
        })

        local function submittedFunction()
            coroutine.yield("paused")
            return "done"
        end
        local completionCalls = 0
        local _, thread = ThreadLib.ThreadCallback(submittedFunction, 0, function()
            completionCalls = completionCalls + 1
        end)

        tickerCallbacks[1]()
        tickerCallbacks[1]()
        tickerCallbacks[1]()

        assert.are_same("created", events[1][1])
        assert.are_equal(thread, events[1][2])
        assert.are_equal(submittedFunction, events[1][3])
        assert.are_same("test stack", events[1][4])
        assert.is_nil(events[1][5])
        assert.are_same({"before", thread}, events[2])
        assert.are_same({"after", thread, true, "suspended"}, events[3])
        assert.are_same({"before", thread}, events[4])
        assert.are_same({"after", thread, true, "dead"}, events[5])
        assert.are_same(5, #events)
        assert.are_same(1, completionCalls)
        assert.is_true(cancelledTickers[1].cancelled)
    end)

    it("reports failed resumes without changing scheduler error handling", function()
        local afterSuccess
        local afterStatus
        local reportedError
        _G.Questie.Error = function(prefix, message)
            reportedError = {prefix, message}
        end
        ThreadLib.SetProfilingCallbacks({}, {
            AfterResume = function(_, success, status)
                afterSuccess = success
                afterStatus = status
            end,
        })

        ThreadLib.ThreadError(function()
            error("expected failure")
        end, 0, "Thread failed")
        tickerCallbacks[1]()

        assert.is_false(afterSuccess)
        assert.are_same("dead", afterStatus)
        assert.are_same("Thread failed", reportedError[1])
        assert.is_truthy(string.find(reportedError[2], "expected failure", 1, true))
        assert.is_true(cancelledTickers[1].cancelled)
    end)

    it("isolates throwing profiling callbacks from scheduler completion", function()
        local callbackErrors = {}
        _G.Questie.Error = function(message, callbackName, callbackError)
            table.insert(callbackErrors, {message, callbackName, callbackError})
        end
        ThreadLib.SetProfilingCallbacks({}, {
            OnThreadCreated = function()
                error("created observer failed")
            end,
            BeforeResume = function()
                error("before observer failed")
            end,
            AfterResume = function()
                error("after observer failed")
            end,
        })

        local jobCalls = 0
        local completionCalls = 0
        ThreadLib.ThreadCallback(function()
            jobCalls = jobCalls + 1
        end, 0, function()
            completionCalls = completionCalls + 1
        end)
        tickerCallbacks[1]()
        tickerCallbacks[1]()

        assert.are_same(1, jobCalls)
        assert.are_same(1, completionCalls)
        assert.is_true(cancelledTickers[1].cancelled)
        assert.are_same(3, #callbackErrors)
        assert.are_same("ThreadLib profiling callback failed", callbackErrors[1][1])
        assert.are_same("OnThreadCreated", callbackErrors[1][2])
        assert.is_truthy(string.find(callbackErrors[1][3], "created observer failed", 1, true))
        assert.are_same("BeforeResume", callbackErrors[2][2])
        assert.is_truthy(string.find(callbackErrors[2][3], "before observer failed", 1, true))
        assert.are_same("AfterResume", callbackErrors[3][2])
        assert.is_truthy(string.find(callbackErrors[3][3], "after observer failed", 1, true))
    end)

    it("uses the same callbacks after a resumed job changes the registration", function()
        local firstOwner = {}
        local events = {}
        ThreadLib.SetProfilingCallbacks(firstOwner, {
            BeforeResume = function()
                table.insert(events, "first before")
            end,
            AfterResume = function()
                table.insert(events, "first after")
            end,
        })

        ThreadLib.ThreadSimple(function()
            ThreadLib.SetProfilingCallbacks(firstOwner, {
                AfterResume = function()
                    table.insert(events, "second after")
                end,
            })
        end, 0)
        tickerCallbacks[1]()

        assert.are_same({"first before", "first after"}, events)
    end)

    it("passes explicit job names without collecting a call-site stack", function()
        local debugStackArguments
        local receivedStack
        local receivedThreadName
        _G.debugstack = function(...)
            debugStackArguments = {...}
            return "first frame\nsecond frame"
        end
        ThreadLib.SetProfilingCallbacks({}, {
            OnThreadCreated = function(_, _, callSiteStack, threadName)
                receivedStack = callSiteStack
                receivedThreadName = threadName
            end,
        })

        ThreadLib.Thread(function() end, 0, nil, nil, nil, "Explicit job")

        -- An explicit name is the job's whole identity, so a collected stack would never be read.
        assert.is_nil(debugStackArguments)
        assert.is_nil(receivedStack)
        assert.are_same("Explicit job", receivedThreadName)
    end)

    it("collects a bounded call-site stack for unnamed jobs", function()
        local debugStackArguments
        local receivedStack
        _G.debugstack = function(...)
            debugStackArguments = {...}
            return "first frame\nsecond frame"
        end
        ThreadLib.SetProfilingCallbacks({}, {
            OnThreadCreated = function(_, _, callSiteStack)
                receivedStack = callSiteStack
            end,
        })

        ThreadLib.Thread(function() end, 0)

        assert.are_same({2, 12, 0}, debugStackArguments)
        assert.are_same("first frame\nsecond frame", receivedStack)
    end)

    it("rejects a non-string explicit job name", function()
        assert.has_error(function()
            ThreadLib.Thread(function() end, 0, nil, nil, nil, 123)
        end, "ThreadLib:Thread: threadName is not a string")
    end)

    it("does not add explicit job names to convenience API forwarding", function()
        local forwardedCalls = {}
        local threadFunction = function() end
        local callbackFunction = function() end
        ThreadLib.Thread = function(...)
            table.insert(forwardedCalls, {n = select("#", ...), ...})
        end

        ThreadLib.ThreadCallback(threadFunction, 1, callbackFunction, "ignored")
        ThreadLib.ThreadError(threadFunction, 2, "error", "ignored")
        ThreadLib.ThreadSimple(threadFunction, 3, "ignored")

        assert.are_same({n = 4, threadFunction, 1, nil, callbackFunction}, forwardedCalls[1])
        assert.are_same({n = 3, threadFunction, 2, "error"}, forwardedCalls[2])
        assert.are_same({n = 2, threadFunction, 3}, forwardedCalls[3])
    end)

    it("creates and resumes profiled jobs when debugstack is unavailable", function()
        local createdCalls = 0
        local resumeCalls = 0
        -- Captured here and asserted below: the callback runs inside CallProfilingCallback's pcall with
        -- Questie.Error stubbed out, so an assertion failing in it would be swallowed and the test would pass.
        local receivedStack
        local receivedThreadName
        ThreadLib.SetProfilingCallbacks({}, {
            OnThreadCreated = function(_, _, callSiteStack, threadName)
                createdCalls = createdCalls + 1
                receivedStack = callSiteStack
                receivedThreadName = threadName
            end,
            BeforeResume = function()
                resumeCalls = resumeCalls + 1
            end,
        })
        _G.debugstack = nil

        local success, timer = pcall(ThreadLib.ThreadSimple, function() end, 0)
        assert.is_true(success)
        tickerCallbacks[1]()

        assert.is_truthy(timer)
        assert.are_same(1, createdCalls)
        assert.are_same(1, resumeCalls)
        assert.is_nil(receivedStack)
        assert.is_nil(receivedThreadName)
    end)

    it("does not let a foreign owner clear callbacks", function()
        local owner = {}
        local beforeCount = 0
        ThreadLib.SetProfilingCallbacks(owner, {
            BeforeResume = function()
                beforeCount = beforeCount + 1
            end,
        })
        ThreadLib.ClearProfilingCallbacks({})
        local foreignRegistrationAccepted = ThreadLib.SetProfilingCallbacks({}, {})

        ThreadLib.ThreadSimple(function() end, 0)
        tickerCallbacks[1]()
        assert.is_false(foreignRegistrationAccepted)
        assert.are_same(1, beforeCount)

        ThreadLib.ClearProfilingCallbacks(owner)
        ThreadLib.ThreadSimple(function() end, 0)
        tickerCallbacks[2]()
        assert.are_same(1, beforeCount)
    end)
end)
