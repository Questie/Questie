dofile("setupTests.lua")

describe("TrackerQuestTimers", function()

    ---@type TrackerQuestTimers
    local TrackerQuestTimers

    before_each(function()
        TrackerQuestTimers = require("Modules.Tracker.TrackerQuestTimers")
    end)

    describe("GetRemainingTimeByQuestId", function()
        it("should return nil if questLogIndex is nil", function()
            _G.GetQuestLogIndexByID = function()
                return nil
            end

            local result = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_nil(result)
        end)

        it("should return nil if questTimers is nil", function()
            _G.GetQuestLogIndexByID = function()
                return 1
            end
            _G.GetQuestTimers = function()
                return nil
            end

            local result = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_nil(result)
        end)

        it("should return nil if GetQuestLogTimeLeft returns nil", function()
            _G.GetQuestLogIndexByID = function()
                return 1
            end
            _G.GetQuestTimers = function()
                return 1
            end
            _G.GetQuestLogSelection = function()
                return 2
            end
            _G.SelectQuestLogEntry = function()end
            _G.GetQuestLogTimeLeft = function()
                return nil
            end

            local result = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_nil(result)
        end)

        it("should return timeRemainingString and timeRemaining", function()
            _G.GetQuestLogIndexByID = function()
                return 123
            end
            _G.GetQuestTimers = function()
                return 1
            end
            _G.GetQuestLogSelection = function()
                return 456
            end
            _G.SelectQuestLogEntry = spy.new(function() end)
            _G.GetQuestLogTimeLeft = function()
                return 81
            end
            _G.SecondsToTime = function()
                return "1 |4Minute:Minutes; 21 |4Second:Seconds;"
            end

            local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_equal("1 |4Minute:Minutes; 21 |4Second:Seconds;", timeRemainingString)
            assert.is_equal(81, timeRemaining)

            assert.spy(_G.SelectQuestLogEntry).was.called_with(123)
            assert.spy(_G.SelectQuestLogEntry).was.called_with(456)
        end)
    end)
end)
