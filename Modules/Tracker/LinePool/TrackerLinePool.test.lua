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
    local originalScenarioInfo

    before_each(function()
        require("Modules.Libs.utf8")
        QuestieLib = require("Modules.Libs.QuestieLib")
        WrappedText = require("Modules.Libs.WrappedText")
        originalTextWrap = WrappedText.TextWrap
        originalScenarioInfo = _G.C_ScenarioInfo
        TrackerLinePool = require("Modules.Tracker.LinePool.TrackerLinePool")
    end)

    after_each(function()
        if WrappedText then
            WrappedText.TextWrap = originalTextWrap
        end
        _G.C_ScenarioInfo = originalScenarioInfo
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
            assert.are.same("|cFFEEEEEELong Test\nObjective\n> 5/10", label.text)
        end)

        it("should expand line height when GetStringHeight only reports one line", function()
            Questie.db.profile.trackerQuestPadding = 5
            WrappedText.TextWrap = function()
                return {"Long Test", "Objective"}
            end

            local label = {
                SetText = function() end,
                SetHeight = spy.new(function() end),
                GetStringHeight = function() return 10 end,
                GetFont = function() return nil, 12 end,
                GetNumLines = function() return 2 end,
            }
            local line = {
                label = label,
                SetHeight = spy.new(function() end),
            }

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Long Test Objective", nil, 100)

            assert.spy(label.SetHeight).was.called_with(_, 25)
            assert.spy(line.SetHeight).was.called_with(_, 32)
        end)

        it("should split WrappedText lines again when the tracker label still cannot render them", function()
            WrappedText.TextWrap = function()
                return {"Mindless Zombie"}
            end

            local label = {
                text = nil,
                SetText = function(self, text)
                    self.text = text
                end,
                GetUnboundedStringWidth = function(self)
                    return string.len(self.text or "") * 10
                end,
            }
            local line = {
                label = label,
            }

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Mindless Zombie", "8/8", 80)

            assert.are.same("|cFFEEEEEEMindless\nZombie\n> 8/8", label.text)
        end)

        it("should trim trailing whitespace returned by WrappedText", function()
            WrappedText.TextWrap = function()
                return {"Wretched ", "Zombie"}
            end

            local label = {
                text = nil,
                SetText = function(self, text)
                    self.text = text
                end,
                GetUnboundedStringWidth = function(self)
                    return string.len(self.text or "") * 10
                end,
            }
            local line = {
                label = label,
            }

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Wretched Zombie", "3/8", 120)

            assert.are.same("|cFFEEEEEEWretched\nZombie: 3/8", label.text)
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

    describe("UpdateScenarioLines", function()
        it("should ignore stale scenario mappings", function()
            _G.C_ScenarioInfo = {
                GetCriteriaInfo = spy.new(function()
                    return {
                        quantity = 1,
                        totalQuantity = 3,
                    }
                end),
            }

            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Id = 123,
                    Index = 1,
                    Description = "Test Scenario Objective",
                },
            }

            TrackerLinePool.AddScenarioLine(456, line)
            TrackerLinePool.UpdateScenarioLines(456)

            assert.spy(_G.C_ScenarioInfo.GetCriteriaInfo).was_not_called()
            assert.spy(line.label.SetText).was_not_called()
        end)
    end)
end)
