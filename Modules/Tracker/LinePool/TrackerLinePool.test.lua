dofile("setupTests.lua")

describe("TrackerLinePool", function()

    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type QuestieLib
    local QuestieLib

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        QuestieLib = require("Modules.Libs.QuestieLib")
        TrackerLinePool = require("Modules.Tracker.LinePool.TrackerLinePool")
    end)

    describe("UpdateQuestLines", function()
        it("should set new objectives text", function()
            QuestieLib.GetRGBForObjective = function() return "|cFFEEEEEE" end
            local firstLine = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 0,
                    Needed = 1,
                    Description = "Test Objective",
                    Update = spy.new(function() end)
                }
            }
            local secondLine = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 5,
                    Needed = 10,
                    Description = "Another Test Objective",
                    Update = spy.new(function() end)
                }
            }

            TrackerLinePool.AddQuestLine(123, firstLine)
            TrackerLinePool.AddQuestLine(123, secondLine)

            TrackerLinePool.UpdateQuestLines(123)

            assert.spy(firstLine.Objective.Update).was.called()
            assert.spy(firstLine.label.SetText).was.called_with(_, "|cFFEEEEEETest Objective: 0/1")
            assert.spy(secondLine.Objective.Update).was.called()
            assert.spy(secondLine.label.SetText).was.called_with(_, "|cFFEEEEEEAnother Test Objective: 5/10")
        end)

        it("should do nothing when questId was not added", function()
            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 0,
                    Needed = 1,
                    Description = "Test Objective",
                    Update = spy.new(function() end)
                }
            }

            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(456)

            assert.spy(line.Objective.Update).was_not_called()
            assert.spy(line.label.SetText).was_not_called()
        end)
    end)
end)
