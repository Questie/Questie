dofile("setupTests.lua")

describe("TrackerLayout", function()
    ---@type TrackerLayout
    local TrackerLayout

    local baseFrame, baseFrameWidth, updateWidth, updateHeight, originalGetScreenWidth, focusSlotShown, playSlotShown

    local function _CreateLine(unboundedWidth, wrappedWidth)
        local label = {
            width = 0,
            height = 0,
            GetUnboundedStringWidth = function() return unboundedWidth end,
            GetWrappedWidth = function() return wrappedWidth end,
            GetFont = function() return "font", 10 end,
            GetNumLines = function() return 2 end,
        }
        function label:SetWidth(width) self.width = width end
        function label:GetWidth() return self.width end
        function label:SetHeight(height) self.height = height end
        function label:GetHeight() return self.height end

        local line = {label = label, width = 0, height = 0}
        function line:SetWidth(width) self.width = width end
        function line:SetHeight(height) self.height = height end
        return line
    end

    before_each(function()
        Questie.db.profile.trackerFontSizeQuest = 12
        Questie.db.profile.trackerWidthRatio = 0.5
        Questie.db.profile.trackerQuestPadding = 2
        originalGetScreenWidth = _G.GetScreenWidth
        _G.GetScreenWidth = function() return 1000 end

        baseFrameWidth = 300
        baseFrame = {GetWidth = function() return baseFrameWidth end}
        updateWidth = spy.new(function(width) baseFrameWidth = width end)
        updateHeight = spy.new(function() end)

        dofile("Modules/Tracker/TrackerLayout.lua")
        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        focusSlotShown = false
        playSlotShown = false
        TrackerLayout.Initialize(baseFrame, updateWidth, updateHeight, function() return focusSlotShown end, function() return playSlotShown end)
        TrackerLayout.ResetLineWidth()
    end)

    after_each(function()
        _G.GetScreenWidth = originalGetScreenWidth
    end)

    describe("GetMargins", function()
        local function _Margins(values)
            local margins = {left = 14, right = 30, buttonSize = 15, playButtonSize = 17, itemButtonSize = 24}
            for key, value in pairs(values) do
                margins[key] = value
            end
            return margins
        end

        it("should only reserve the quest item column without optional slots", function()
            assert.are_same(_Margins({quest = 26, objective = 38, itemButtonLeft = 0, expandQuestRight = 20, playButtonRight = -2, focusButtonRight = -2}),
                TrackerLayout.GetMargins())
        end)

        it("should only reserve the expand quest button width when no quest item column is shown", function()
            TrackerLayout.SetItemColumnShown(false)

            assert.are_same(_Margins({quest = 17, objective = 29, itemButtonLeft = 0, expandQuestRight = 15, playButtonRight = -2, focusButtonRight = -2}),
                TrackerLayout.GetMargins())
        end)

        it("should add a slot for the quest focus buttons left of the quest item column", function()
            focusSlotShown = true

            assert.are_same(_Margins({quest = 43, objective = 55, itemButtonLeft = 17, expandQuestRight = 37, playButtonRight = 15, focusButtonRight = 15}),
                TrackerLayout.GetMargins())
        end)

        it("should add a slot for the VoiceOver play buttons between the focus slot and the quest item column", function()
            focusSlotShown = true
            playSlotShown = true

            assert.are_same(_Margins({quest = 62, objective = 74, itemButtonLeft = 36, expandQuestRight = 56, playButtonRight = 34, focusButtonRight = 15}),
                TrackerLayout.GetMargins())
        end)

        it("should keep the expand quest button inside the quest item column", function()
            for _, shown in ipairs({true, false}) do
                TrackerLayout.SetItemColumnShown(shown)
                local margins = TrackerLayout.GetMargins()

                assert.is_true(margins.expandQuestRight - margins.buttonSize >= margins.itemButtonLeft)
                assert.is_true(margins.expandQuestRight <= margins.quest - 2)
            end
        end)

        it("should keep the distances of all buttons to the quest title when the focus slot is toggled", function()
            playSlotShown = true
            local without = TrackerLayout.GetMargins()
            focusSlotShown = true
            local with = TrackerLayout.GetMargins()

            for _, key in ipairs({"itemButtonLeft", "expandQuestRight", "playButtonRight"}) do
                assert.are_same(without.quest - without[key], with.quest - with[key])
            end
        end)
    end)

    describe("line width", function()
        it("should keep the widest tracked line width", function()
            TrackerLayout.TrackLineWidth(50)
            TrackerLayout.TrackLineWidth(20)

            assert.are_same(50, TrackerLayout.GetLineWidth())
        end)

        it("should reset the tracked line width", function()
            TrackerLayout.TrackLineWidth(50)

            TrackerLayout.ResetLineWidth()

            assert.are_same(0, TrackerLayout.GetLineWidth())
        end)
    end)

    describe("UpdateWidth and UpdateHeight", function()
        it("should call the resize callbacks", function()
            TrackerLayout.UpdateWidth(123)
            TrackerLayout.UpdateHeight()

            assert.spy(updateWidth).was.called_with(123)
            assert.spy(updateHeight).was.called(1)
        end)

        it("should not resize the tracker for a narrower line in the same layout", function()
            TrackerLayout.UpdateWidth(200)
            TrackerLayout.UpdateWidth(150)
            TrackerLayout.UpdateWidth(200)

            assert.spy(updateWidth).was.called_with(200)
            assert.spy(updateWidth).was.called(1)
        end)

        it("should resize the tracker for the first line even without any width", function()
            TrackerLayout.UpdateWidth(0)

            assert.spy(updateWidth).was.called_with(0)
        end)

        it("should resize the tracker for a wider line in the same layout", function()
            TrackerLayout.UpdateWidth(150)
            TrackerLayout.UpdateWidth(200)

            assert.spy(updateWidth).was.called_with(200)
            assert.spy(updateWidth).was.called(2)
        end)

        it("should resize the tracker to a narrower line after the line width was reset", function()
            TrackerLayout.UpdateWidth(200)
            TrackerLayout.ResetLineWidth()
            TrackerLayout.UpdateWidth(150)

            assert.spy(updateWidth).was.called_with(150)
        end)
    end)

    describe("resizing after the tracker was drawn", function()
        it("should size wrapped lines to a smaller width ratio without a new draw", function()
            -- The draw at the old ratio, then the width ratio slider only runs the formatting
            TrackerLayout.UpdateLineWidth(_CreateLine(600, 400), 20)
            assert.are_same(500, baseFrameWidth)
            Questie.db.profile.trackerWidthRatio = 0.3
            local line = _CreateLine(600, 250)

            TrackerLayout.ResetRequestedWidth()
            TrackerLayout.UpdateLineWidth(line, 20)

            assert.spy(updateWidth).was.called_with(300)
            assert.are_same(300, baseFrameWidth)
            assert.are_same(250, line.label.width)
        end)
    end)

    describe("GetBaseFrame", function()
        it("should return the base frame and its width", function()
            assert.are.equal(baseFrame, TrackerLayout.GetBaseFrame())
            assert.are_same(300, TrackerLayout.GetBaseFrameWidth())
        end)
    end)

    describe("UpdateLineWidth", function()
        it("should size the tracker to a line that fits", function()
            local line = _CreateLine(100, 100)

            TrackerLayout.UpdateLineWidth(line, 20)

            assert.spy(updateWidth).was.called_with(150)
            assert.are_same(100, line.label.width)
            assert.are_same(120, line.width)
            assert.are_same(120, TrackerLayout.GetLineWidth())
        end)

        it("should use the max tracker width and wrap a line that does not fit", function()
            local line = _CreateLine(600, 400)

            TrackerLayout.UpdateLineWidth(line, 20)

            assert.spy(updateWidth).was.called_with(500)
            assert.are_same(23, line.label.height)
            assert.are_same(27, line.height)
            assert.are_same(420, TrackerLayout.GetLineWidth())
        end)
    end)
end)
