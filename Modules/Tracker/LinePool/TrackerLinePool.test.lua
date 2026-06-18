dofile("setupTests.lua")

describe("TrackerLinePool", function()

    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type QuestieLib
    local QuestieLib
    ---@type WrappedText
    local WrappedText

    local match = require("luassert.match")
    local _ = match._ -- any match
    local originalTextWrap

    before_each(function()
        QuestieLib = require("Modules.Libs.QuestieLib")
        WrappedText = require("Modules.Libs.WrappedText")
        originalTextWrap = WrappedText.TextWrap
        TrackerLinePool = require("Modules.Tracker.LinePool.TrackerLinePool")
    end)

    after_each(function()
        if WrappedText then
            WrappedText.TextWrap = originalTextWrap
        end
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
                }
            }
            local secondLine = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 5,
                    Needed = 10,
                    Description = "Another Test Objective",
                }
            }

            TrackerLinePool.AddQuestLine(123, firstLine)
            TrackerLinePool.AddQuestLine(123, secondLine)

            TrackerLinePool.UpdateQuestLines(123)

            assert.spy(firstLine.label.SetText).was.called_with(_, "|cFFEEEEEETest Objective: 0/1")
            assert.spy(secondLine.label.SetText).was.called_with(_, "|cFFEEEEEEAnother Test Objective: 5/10")
        end)

        it("should preserve wrapped objective text on progress updates", function()
            QuestieLib.GetRGBForObjective = function() return "|cFFEEEEEE" end
            WrappedText.TextWrap = spy.new(function(_, text)
                assert.are.same("Long Test Objective", text)
                return {"Long Test", "Objective"}
            end)

            local label = {
                text = nil,
                SetText = spy.new(function(self, text)
                    self.text = text
                end),
                GetWidth = function()
                    return 100
                end,
                GetUnboundedStringWidth = function(self)
                    return string.len(self.text or "") * 10
                end,
            }
            local line = {
                label = label,
                Objective = {
                    Collected = 5,
                    Needed = 10,
                    Description = "Long Test Objective",
                }
            }

            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(123)

            assert.spy(WrappedText.TextWrap).was_called()
            assert.are.same("|cFFEEEEEELong Test\nObjective\n    > 5/10", label.text)
        end)

        it("should do nothing when questId was not added", function()
            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 0,
                    Needed = 1,
                    Description = "Test Objective",
                }
            }

            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(456)

            assert.spy(line.label.SetText).was_not_called()
        end)
    end)
end)
