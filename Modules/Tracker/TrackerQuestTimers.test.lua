dofile("setupTests.lua")

describe("TrackerQuestTimers", function()

    ---@type TrackerQuestTimers
    local TrackerQuestTimers
    local savedGlobals
    local globalNames = {
        "C_QuestLog", "GetQuestLogIndexByID", "GetQuestTimers", "GetQuestLogSelection",
        "SelectQuestLogEntry", "GetQuestLogTimeLeft", "SecondsToTime",
    }

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        _G.C_QuestLog = {}
        dofile("Modules/Tracker/TrackerQuestTimers.lua")
        TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
    end)

    describe("GetRemainingTimeByQuestId", function()
        it("matches modern timer records by quest ID without changing quest-log selection", function()
            C_QuestLog.GetQuestTimers = function()
                return {{questID = 999, questTimer = 12}, {questID = 33, questTimer = 81}}
            end
            _G.SecondsToTime = spy.new(function() return "1 Min 21 Sec" end)
            _G.SelectQuestLogEntry = spy.new(function() end)

            local text, seconds = TrackerQuestTimers:GetRemainingTimeByQuestId(33)

            assert.are.equal("1 Min 21 Sec", text)
            assert.are.equal(81, seconds)
            assert.spy(SecondsToTime).was.called_with(81, false, false)
            assert.spy(SelectQuestLogEntry).was.not_called()
            assert.is_nil(TrackerQuestTimers:GetRemainingTimeByQuestId(783))
        end)

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
            local selection = 2
            local selectionAtRead
            _G.GetQuestLogSelection = function() return selection end
            _G.SelectQuestLogEntry = function(index) selection = index end
            _G.GetQuestLogTimeLeft = function()
                selectionAtRead = selection
                return nil
            end

            local result = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_nil(result)
            assert.are.equal(1, selectionAtRead)
            assert.are.equal(2, selection)
        end)

        it("should return timeRemainingString and timeRemaining", function()
            _G.GetQuestLogIndexByID = function()
                return 123
            end
            _G.GetQuestTimers = function()
                return 1
            end
            local selection = 456
            local selectionAtRead
            _G.GetQuestLogSelection = function() return selection end
            _G.SelectQuestLogEntry = spy.new(function(index) selection = index end)
            _G.GetQuestLogTimeLeft = function()
                selectionAtRead = selection
                return 81
            end
            _G.SecondsToTime = function()
                return "2 |4Min:Mins; 21 |4Sec:Secs;"
            end

            local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_equal("2 |4Min:Mins; 21 |4Sec:Secs;", timeRemainingString)
            assert.is_equal(81, timeRemaining)

            assert.are.equal(123, selectionAtRead)
            assert.are.equal(456, selection)
        end)
    end)
end)
