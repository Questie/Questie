dofile("setupTests.lua")

describe("TrackerLayout", function()
    ---@type TrackerLayout
    local TrackerLayout

    local baseFrame, updateWidth, updateHeight, originalGetScreenWidth, questColumnOffset

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

        baseFrame = {GetWidth = function() return 300 end}
        updateWidth = spy.new(function() end)
        updateHeight = spy.new(function() end)

        dofile("Modules/Tracker/TrackerLayout.lua")
        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        questColumnOffset = 0
        TrackerLayout.Initialize(baseFrame, updateWidth, updateHeight, function() return questColumnOffset end)
        TrackerLayout.ResetLineWidth()
    end)

    after_each(function()
        _G.GetScreenWidth = originalGetScreenWidth
    end)

    describe("GetMargins", function()
        it("should derive the margins from the quest font size", function()
            assert.are_same({left = 14, right = 30, quest = 38, objective = 50, itemButtonSize = 24}, TrackerLayout.GetMargins())
        end)

        it("should add the width of the column in front of the quest titles", function()
            questColumnOffset = 16

            assert.are_same({left = 14, right = 30, quest = 54, objective = 66, itemButtonSize = 24}, TrackerLayout.GetMargins())
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
            assert.are_same(250, line.label.width)
            assert.are_same(270, line.width)
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
