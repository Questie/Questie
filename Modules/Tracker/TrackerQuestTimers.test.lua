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
                return "2 |4Min:Mins; 21 |4Sec:Secs;"
            end

            local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(1)

            assert.is_equal("2 |4Min:Mins; 21 |4Sec:Secs;", timeRemainingString)
            assert.is_equal(81, timeRemaining)

            assert.spy(_G.SelectQuestLogEntry).was.called_with(123)
            assert.spy(_G.SelectQuestLogEntry).was.called_with(456)
        end)
    end)

    describe("timer lines", function()
        local lines

        ---@return table line A fake tracker line that remembers the text of its label
        local function _NewLine()
            local line = {label = {}}
            line.label.SetFont = function() end
            line.label.SetText = function(self, text) self.text = text end
            return line
        end

        before_each(function()
            Questie.db.profile.trackerEnabled = true
            Questie.db.profile.showBlizzardQuestTimer = false
            Questie.db.char.isTrackerExpanded = true
            Questie.Colorize = function(_, text) return text end
            _G.SecondsToTime = function(seconds) return seconds .. " Secs" end
            C_QuestLog.GetQuestTimers = function() return {{questID = 33, questTimer = 81}, {questID = 44, questTimer = 12}} end
            lines = {_NewLine(), _NewLine()}
            TrackerQuestTimers.ResetTimerLines()
        end)

        it("updates every line of a quest that is listed twice", function()
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[1])
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[2])

            TrackerQuestTimers:UpdateTimerFrame()

            assert.are.equal("81 Secs", lines[1].label.text)
            assert.are.equal("81 Secs", lines[2].label.text)
        end)

        it("updates the lines of every timed quest", function()
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[1])
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 44}, lines[2])

            TrackerQuestTimers:UpdateTimerFrame()

            assert.are.equal("81 Secs", lines[1].label.text)
            assert.are.equal("12 Secs", lines[2].label.text)
        end)

        it("updates both lines of a quest listed twice with another timed quest between them", function()
            local otherLine = _NewLine()
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[1])
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 44}, otherLine)
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[2])

            TrackerQuestTimers:UpdateTimerFrame()

            assert.are.equal("81 Secs", lines[1].label.text)
            assert.are.equal("81 Secs", lines[2].label.text)
            assert.are.equal("12 Secs", otherLine.label.text)
        end)

        it("keeps updating the other quests when the time of one quest ran out", function()
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[1])
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 44}, lines[2])
            C_QuestLog.GetQuestTimers = function() return {{questID = 44, questTimer = 12}} end

            TrackerQuestTimers:UpdateTimerFrame()

            assert.is_nil(lines[1].label.text)
            assert.are.equal("12 Secs", lines[2].label.text)
        end)

        it("forgets the lines of the previous layout", function()
            TrackerQuestTimers:UpdateAndGetRemainingTime({Id = 33}, lines[1])

            TrackerQuestTimers.ResetTimerLines()
            TrackerQuestTimers:UpdateTimerFrame()

            assert.is_nil(lines[1].label.text)
        end)

        it("does not register a line when only refreshing the timer state of a quest", function()
            local quest = {Id = 33}

            TrackerQuestTimers:UpdateAndGetRemainingTime(quest)
            TrackerQuestTimers:UpdateTimerFrame()

            assert.is_true(quest.trackTimedQuest)
            assert.is_nil(lines[1].label.text)
        end)
    end)
end)
