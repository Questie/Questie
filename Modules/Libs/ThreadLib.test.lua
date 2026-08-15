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
