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

            assert.spy(line.label.SetText).was.called_with(line.label, "|cFFEEEEEERead the book.")
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

    describe("PinLines", function()
        local questFrame
        local originalQuestLog

        ---@return table line A fake line that remembers its parent and its single anchor
        local function _NewLine(_, parent, previousLine)
            local line = {}
            line.SetParent = function(self, newParent) self.parent = newParent end
            line.ClearAllPoints = function(self) self.anchor = nil end
            line.SetPoint = function(self, point, relativeTo, relativePoint, x, y)
                self.anchor = {point, relativeTo, relativePoint, x, y}
            end
            line:SetParent(parent)
            if previousLine then
                line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, 0)
            else
                line:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, 0)
            end
            return line
        end

        before_each(function()
            originalQuestLog = _G.C_QuestLog
            _G.C_QuestLog = {GetMaxNumQuestsCanAccept = function() return 0 end}
            local trackerLine = QuestieLoader:ImportModule("TrackerLine")
            trackerLine.New = _NewLine
            trackerLine.MARGIN_LEFT = 10

            questFrame = {ScrollChildFrame = {name = "scroll"}, PinnedFrame = {name = "pinned"}}
            local initialized, err = coroutine.resume(coroutine.create(function()
                TrackerLinePool.Initialize(questFrame)
            end))
            assert.is_true(initialized, err)
        end)

        after_each(function()
            _G.C_QuestLog = originalQuestLog
        end)

        it("moves the first lines into the pinned frame and starts the scrolling lines at the top", function()
            TrackerLinePool.PinLines(2)

            local first, second, third, fourth = TrackerLinePool.GetLine(1), TrackerLinePool.GetLine(2), TrackerLinePool.GetLine(3), TrackerLinePool.GetLine(4)
            assert.are.equal(questFrame.PinnedFrame, first.parent)
            assert.are_same({"TOPLEFT", questFrame.PinnedFrame, "TOPLEFT", 10, 0}, first.anchor)
            assert.are.equal(questFrame.PinnedFrame, second.parent)
            assert.are_same({"TOPLEFT", first, "BOTTOMLEFT", 0, 0}, second.anchor)
            assert.are.equal(questFrame.ScrollChildFrame, third.parent)
            assert.are_same({"TOPLEFT", questFrame.ScrollChildFrame, "TOPLEFT", 10, 0}, third.anchor)
            assert.are_same({"TOPLEFT", third, "BOTTOMLEFT", 0, 0}, fourth.anchor)
            assert.are.equal(2, TrackerLinePool.GetPinnedLineCount())
        end)

        it("puts all lines back into the scrolling frame", function()
            TrackerLinePool.PinLines(2)
            TrackerLinePool.PinLines(0)

            local first, second, third = TrackerLinePool.GetLine(1), TrackerLinePool.GetLine(2), TrackerLinePool.GetLine(3)
            assert.are.equal(questFrame.ScrollChildFrame, first.parent)
            assert.are_same({"TOPLEFT", questFrame.ScrollChildFrame, "TOPLEFT", 10, 0}, first.anchor)
            assert.are.equal(questFrame.ScrollChildFrame, second.parent)
            assert.are_same({"TOPLEFT", first, "BOTTOMLEFT", 0, 0}, second.anchor)
            assert.are_same({"TOPLEFT", second, "BOTTOMLEFT", 0, 0}, third.anchor)
            assert.are.equal(0, TrackerLinePool.GetPinnedLineCount())
        end)

        it("chains the lines again when fewer lines are pinned", function()
            TrackerLinePool.PinLines(3)
            TrackerLinePool.PinLines(1)

            local first, second, third, fourth = TrackerLinePool.GetLine(1), TrackerLinePool.GetLine(2), TrackerLinePool.GetLine(3), TrackerLinePool.GetLine(4)
            assert.are.equal(questFrame.PinnedFrame, first.parent)
            assert.are.equal(questFrame.ScrollChildFrame, second.parent)
            assert.are_same({"TOPLEFT", questFrame.ScrollChildFrame, "TOPLEFT", 10, 0}, second.anchor)
            assert.are.equal(questFrame.ScrollChildFrame, third.parent)
            assert.are_same({"TOPLEFT", second, "BOTTOMLEFT", 0, 0}, third.anchor)
            assert.are.equal(questFrame.ScrollChildFrame, fourth.parent)
            assert.are_same({"TOPLEFT", third, "BOTTOMLEFT", 0, 0}, fourth.anchor)
        end)
    end)
end)
