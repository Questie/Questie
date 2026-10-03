dofile("setupTests.lua")

describe("TrackerLinePool", function()
    local TrackerLinePool
    local TrackerData
    local originalObjectiveColor

    before_each(function()
        originalObjectiveColor = Questie.db.profile.trackerColorObjectives
        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.GetObjectiveText = spy.new(function() return "Updated objective text" end)
        dofile("Modules/Tracker/LinePool/TrackerLinePool.lua")
        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
    end)

    after_each(function()
        Questie.db.profile.trackerColorObjectives = originalObjectiveColor
    end)

    describe("UpdateQuestLines", function()
        it("uses the refreshed objective instead of the row's old snapshot", function()
            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {Index = 1, Collected = 0, Needed = 10},
            }
            local objective = {Index = 1, Collected = 5, Needed = 10}
            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(123, {Objectives = {objective}})

            assert.are.equal(objective, line.Objective)
            assert.spy(TrackerData.GetObjectiveText).was.called_with(objective)
            assert.spy(line.label.SetText).was.called_with(line.label, "Updated objective text")
        end)

        it("keeps unfamiliar objective types text-only during incremental updates", function()
            dofile("Modules/Libs/QuestieLib.lua")
            dofile("Modules/Tracker/TrackerData.lua")
            Questie.db.profile.trackerColorObjectives = "minimal"
            local objective = {
                Index = 1, Type = "future-objective", Description = "Read the book.",
                Collected = 1, Needed = 1, Completed = true,
            }
            local line = {label = {SetText = spy.new(function() end)}, Objective = objective}
            TrackerLinePool.AddQuestLine(91741, line)

            TrackerLinePool.UpdateQuestLines(91741, {Objectives = {objective}})

            assert.spy(line.label.SetText).was.called_with(line.label, "|cFFEEEEEERead the book")
        end)

        it("clears a removed objective's text until the next layout", function()
            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {Index = 2},
            }
            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(123, {Objectives = {}})

            assert.spy(line.label.SetText).was.called_with(line.label, "")
            assert.spy(TrackerData.GetObjectiveText).was.not_called()
        end)

        it("does not change title or timer rows without an objective", function()
            local line = {label = {SetText = spy.new(function() end)}}
            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(123, {Objectives = {}})

            assert.spy(line.label.SetText).was.not_called()
        end)

        it("does nothing when the quest has no rendered rows", function()
            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {Index = 1},
            }
            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(456, {Objectives = {}})

            assert.spy(line.label.SetText).was.not_called()
        end)
    end)
end)
