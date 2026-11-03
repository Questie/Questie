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

    describe("RefreshHighlight", function()
        local lines, originalTrackerLineNew, originalItemButtonNew, originalQuestLog

        local function _Hoverable(object)
            object.mouseOver = false
            object.visible = true
            function object:IsVisible() return self.visible end
            function object:IsMouseOver() return self.mouseOver end
            return object
        end

        local function _Line()
            local line = _Hoverable({alpha = 1})
            function line:SetAlpha(alpha) self.alpha = alpha end
            line.questFocus = _Hoverable({})
            line.playButton = _Hoverable({})
            line.expandQuest = _Hoverable({})
            -- Only zone headers show their expand zone button
            line.expandZone = _Hoverable({})
            line.expandZone.visible = false
            function line.expandZone:GetParent() return line end
            -- Lines belong to the scroll child, which has no expand zone button
            function line:GetParent() return {} end
            return line
        end

        before_each(function()
            Questie.db.profile.trackerDisableHoverFade = false
            lines = {}
            local TrackerLine = QuestieLoader:ImportModule("TrackerLine")
            local TrackerItemButton = QuestieLoader:ImportModule("TrackerItemButton")
            originalTrackerLineNew, originalItemButtonNew, originalQuestLog = TrackerLine.New, TrackerItemButton.New, _G.C_QuestLog
            TrackerLine.New = function()
                local line = _Line()
                lines[#lines + 1] = line
                return line
            end
            TrackerItemButton.New = function()
                local button = _Hoverable({Hide = function() end})
                function button:GetParent() return self.parent end
                return button
            end
            _G.C_QuestLog = {GetMaxNumQuestsCanAccept = function() return 1 end}

            dofile("Modules/Tracker/LinePool/TrackerLinePool.lua")
            TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
            local co = coroutine.create(TrackerLinePool.Initialize)
            while coroutine.status(co) ~= "dead" do
                assert(coroutine.resume(co, {}))
            end
            for _ = 1, 3 do
                TrackerLinePool.GetNextLine()
            end
        end)

        after_each(function()
            QuestieLoader:ImportModule("TrackerLine").New = originalTrackerLineNew
            QuestieLoader:ImportModule("TrackerItemButton").New = originalItemButtonNew
            _G.C_QuestLog = originalQuestLog
        end)

        it("should highlight the quest of the line now under the mouse after a redraw", function()
            local quest, otherQuest = {Id = 1}, {Id = 2}
            lines[1].Quest, lines[2].Quest, lines[3].Quest = quest, otherQuest, quest
            lines[2].alpha = 1
            lines[3].alpha = 0.5
            lines[3].mouseOver = true

            TrackerLinePool.RefreshHighlight()

            assert.are_same({1, 0.5, 1}, {lines[1].alpha, lines[2].alpha, lines[3].alpha})
        end)

        it("should highlight the quest of a line whose button is hovered outside the line frame", function()
            local quest, otherQuest = {Id = 1}, {Id = 2}
            lines[1].Quest, lines[2].Quest, lines[3].Quest = otherQuest, quest, otherQuest
            lines[2].expandQuest.mouseOver = true

            TrackerLinePool.RefreshHighlight()

            assert.are_same({0.5, 1, 0.5}, {lines[1].alpha, lines[2].alpha, lines[3].alpha})
        end)

        it("should highlight the quest of a line whose quest item button reaches into the next line", function()
            local quest, otherQuest = {Id = 1}, {Id = 2}
            lines[1].Quest, lines[2].Quest, lines[3].Quest = otherQuest, quest, otherQuest
            local button = TrackerLinePool.GetNextItemButton()
            button.parent = lines[2]
            button.mouseOver = true
            lines[3].mouseOver = true

            TrackerLinePool.RefreshHighlight()

            assert.are_same({0.5, 1, 0.5}, {lines[1].alpha, lines[2].alpha, lines[3].alpha})
        end)

        local function _ZoneLines()
            lines[1].expandZone.visible = true
            lines[1].expandZone.zoneId = "Elwynn Forest"
            lines[2].expandZone.zoneId = "Elwynn Forest"
            lines[3].expandZone.zoneId = "Westfall"
        end

        it("should highlight the zone of a hovered zone header after a redraw", function()
            _ZoneLines()
            lines[1].mouseOver = true
            lines[1].expandZone.mouseOver = true

            TrackerLinePool.RefreshHighlight()

            assert.are_same({1, 1, 0.5}, {lines[1].alpha, lines[2].alpha, lines[3].alpha})
        end)

        it("should highlight the zone when only the zone header line below its button is hovered", function()
            _ZoneLines()
            lines[1].mouseOver = true

            TrackerLinePool.RefreshHighlight()

            assert.are_same({1, 1, 0.5}, {lines[1].alpha, lines[2].alpha, lines[3].alpha})
        end)

        it("should remove a stale highlight when the mouse is over no line", function()
            lines[1].alpha, lines[2].alpha, lines[3].alpha = 0.5, 1, 0.5

            TrackerLinePool.RefreshHighlight()

            assert.are_same({1, 1, 1}, {lines[1].alpha, lines[2].alpha, lines[3].alpha})
        end)
    end)
end)
