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

    local function _NewFontStringMock(characterWidth)
        local fontString = {
            text = nil,
            width = nil,
            height = nil,
            hidden = false,
            points = {},
        }
        characterWidth = characterWidth or 10

        fontString.SetText = spy.new(function(self, text)
            self.text = text
        end)
        fontString.GetText = function(self)
            return self.text
        end
        fontString.SetWidth = spy.new(function(self, width)
            self.width = width
        end)
        fontString.GetWidth = function(self)
            return self.width
        end
        fontString.SetHeight = spy.new(function(self, height)
            self.height = height
        end)
        fontString.GetHeight = function(self)
            return self.height
        end
        fontString.GetStringHeight = function(self)
            local _, count = tostring(self.text or ""):gsub("\n", "")
            return (count + 1) * 10
        end
        fontString.GetFont = function()
            return nil, 10
        end
        fontString.GetNumLines = function(self)
            local _, count = tostring(self.text or ""):gsub("\n", "")
            return count + 1
        end
        fontString.GetUnboundedStringWidth = function(self)
            local text = tostring(self.text or ""):gsub("|c%x%x%x%x%x%x%x%x", "")
            return string.len(text) * characterWidth
        end
        fontString.GetWrappedWidth = function(self)
            return self.width or self:GetUnboundedStringWidth()
        end
        fontString.ClearAllPoints = spy.new(function(self)
            self.points = {}
        end)
        fontString.SetPoint = spy.new(function(self, ...)
            self.points = {...}
        end)
        fontString.Hide = spy.new(function(self)
            self.hidden = true
        end)
        fontString.Show = spy.new(function(self)
            self.hidden = false
        end)

        return fontString
    end

    local function _NewLineMock(characterWidth)
        return {
            label = _NewFontStringMock(characterWidth),
            progressLabel = _NewFontStringMock(characterWidth),
            height = nil,
            SetHeight = spy.new(function(self, height)
                self.height = height
            end),
        }
    end

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
        it("should set new objectives text with colored progress in the right column", function()
            QuestieLib.GetRGBForObjective = function() return "|cFFEEEEEE" end
            local firstLine = _NewLineMock()
            firstLine.Objective = {
                Collected = 0,
                Needed = 1,
                Description = "Test Objective",
            }
            local secondLine = _NewLineMock()
            secondLine.Objective = {
                Collected = 5,
                Needed = 10,
                Description = "Another Test Objective",
            }

            TrackerLinePool.AddQuestLine(1001, firstLine)
            TrackerLinePool.AddQuestLine(1001, secondLine)

            TrackerLinePool.UpdateQuestLines(1001)

            assert.spy(firstLine.label.SetText).was.called_with(_, "|cFFEEEEEETest Objective: 0/1")
            assert.spy(firstLine.progressLabel.Hide).was.called()
            assert.spy(secondLine.label.SetText).was.called_with(_, "|cFFEEEEEEAnother Test Objective: 5/10")
            assert.spy(secondLine.progressLabel.Hide).was.called()

            WrappedText.TextWrap = function(_, text)
                return {text}
            end
            TrackerLinePool.SetWrappedObjectiveText(firstLine, "|cFFEEEEEE", "Test Objective", "0/1", 200)
            assert.are.same("|cFFEEEEEETest Objective:", firstLine.label.text)
            assert.are.same("|cFFEEEEEE0/1", firstLine.progressLabel.text)
            assert.are.same({"TOPRIGHT", firstLine, "TOPRIGHT", 0, 0}, firstLine.progressLabel.points)
        end)

        it("should preserve full wrapped objective width on progress updates", function()
            QuestieLib.GetRGBForObjective = function() return "|cFFEEEEEE" end
            WrappedText.TextWrap = spy.new(function(_, text)
                assert.are.same("Long Test Objective:", text)
                return {"Long Test", "Objective:"}
            end)

            local line = _NewLineMock()
            line.Objective = {
                Collected = 5,
                Needed = 10,
                Description = "Long Test Objective",
            }

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Long Test Objective", "4/10", 200)
            local leftColumnWidth = line.label.width
            TrackerLinePool.AddQuestLine(1002, line)

            TrackerLinePool.UpdateQuestLines(1002)

            assert.spy(WrappedText.TextWrap).was_called()
            assert.are.same("|cFFEEEEEELong Test\nObjective:", line.label.text)
            assert.are.same("|cFFEEEEEE5/10", line.progressLabel.text)
            assert.are.same(200, line.wrappedObjectiveText.lastTargetWidth)
            assert.are_not.same(200, leftColumnWidth)
            assert.are.same(leftColumnWidth, line.label.width)
        end)

        it("should expand line height when GetStringHeight only reports one line", function()
            Questie.db.profile.trackerQuestPadding = 5
            WrappedText.TextWrap = function()
                return {"Long Test", "Objective"}
            end

            local label = {
                SetText = function() end,
                SetWidth = function() end,
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

        it("should use full width and hide the progress column when there is no progress", function()
            WrappedText.TextWrap = function()
                return {"Long objective"}
            end

            local line = _NewLineMock()

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Long objective", nil, 120)

            assert.are.same("|cFFEEEEEELong objective", line.label.text)
            assert.are.same(120, line.label.width)
            assert.are.same("", line.progressLabel.text)
            assert.spy(line.progressLabel.Hide).was.called()
        end)

        it("should fall back to one column when progress label is incomplete", function()
            local label = _NewFontStringMock()
            local progressLabel = {
                Hide = spy.new(function() end),
            }
            local line = {
                label = label,
                progressLabel = progressLabel,
                SetHeight = spy.new(function() end),
            }

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Long objective", "1/2", 120)

            assert.are.same("|cFFEEEEEELong objective: 1/2", label.text)
            assert.are.same(120, label.width)
            assert.spy(progressLabel.Hide).was.called()
        end)

        it("should split WrappedText lines again when the tracker label still cannot render them", function()
            WrappedText.TextWrap = function()
                return {"Mindless Zombie:"}
            end

            local line = _NewLineMock()

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Mindless Zombie", "8/8", 120)

            assert.are.same("|cFFEEEEEEMindless\nZombie:", line.label.text)
            assert.are.same("|cFFEEEEEE8/8", line.progressLabel.text)
        end)

        it("should trim trailing whitespace returned by WrappedText", function()
            WrappedText.TextWrap = function()
                return {"Wretched ", "Zombie:"}
            end

            local line = _NewLineMock()

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Wretched Zombie", "3/8", 150)

            assert.are.same("|cFFEEEEEEWretched\nZombie:", line.label.text)
            assert.are.same("|cFFEEEEEE3/8", line.progressLabel.text)
        end)

        it("should ellipsize a long ASCII token that cannot fit the left column", function()
            WrappedText.TextWrap = function(_, text)
                return {text}
            end

            local line = _NewLineMock()

            TrackerLinePool.SetWrappedObjectiveText(line, "|cFFEEEEEE", "Supercalifragilistic", "1/1", 100)

            assert.are.same("|cFFEEEEEESup...", line.label.text)
            assert.are.same("|cFFEEEEEE1/1", line.progressLabel.text)
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

            TrackerLinePool.AddQuestLine(1003, line)

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
