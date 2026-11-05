dofile("setupTests.lua")
local match = require("luassert.match")

describe("TrackerHeaderFrame", function()
    ---@type TrackerHeaderFrame
    local TrackerHeaderFrame
    local QuestLogCache, TrackerUtils
    local originalCreateFrame, originalQuestLog
    local questCount, baseFrame

    local function _PermissiveFrame()
        local frame = {}
        return setmetatable(frame, {__index = function(_, key)
            if key == "GetUnboundedStringWidth" or key == "GetWidth" then
                return function() return 80 end
            end
            return function() return frame end
        end})
    end

    local function _CreateFrame()
        local frame = _PermissiveFrame()
        frame.CreateFontString = function()
            local label = _PermissiveFrame()
            local text = ""
            label.SetText = spy.new(function(_, value) text = value end)
            label.GetText = function() return text end
            label.GetUnboundedStringWidth = function() return #text * 10 end
            label.SetWidth = spy.new(function() end)
            return label
        end
        frame.CreateTexture = function() return _PermissiveFrame() end
        return frame
    end

    before_each(function()
        originalCreateFrame, originalQuestLog = _G.CreateFrame, _G.C_QuestLog
        _G.CreateFrame = _CreateFrame
        _G.C_QuestLog = {GetMaxNumQuestsCanAccept = function() return 25 end}
        Questie.db.char.isTrackerExpanded = true
        Questie.db.profile.trackerHeaderEnabled = true
        Questie.db.profile.trackerFontSizeHeader = 12

        questCount = 9
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.GetQuestCount = function() return questCount end
        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.HasQuest = function() return true end

        dofile("Localization/l10n.lua")
        dofile("Modules/Tracker/TrackerHeaderFrame.lua")
        TrackerHeaderFrame = QuestieLoader:ImportModule("TrackerHeaderFrame")
        baseFrame = _CreateFrame()
        baseFrame.GetWidth = function() return 300 end
        TrackerHeaderFrame.Initialize(baseFrame, function() end)
    end)

    after_each(function()
        _G.CreateFrame, _G.C_QuestLog = originalCreateFrame, originalQuestLog
    end)

    local function _GetLabel()
        return TrackerHeaderFrame.headerFrame.trackedQuests.label
    end

    describe("UpdateQuestCount", function()
        it("should only set the quest count text", function()
            questCount = 10
            local label = _GetLabel()
            local SetPointSpy = spy.new(function() end)
            label.SetPoint = SetPointSpy

            TrackerHeaderFrame.UpdateQuestCount()

            assert.spy(label.SetText).was.called_with(match._, "Questie Tracker: 10/25")
            assert.spy(label.SetWidth).was.not_called()
            assert.spy(SetPointSpy).was.not_called()
        end)

        it("should set the collapsed text when the tracker is collapsed", function()
            Questie.db.char.isTrackerExpanded = false

            TrackerHeaderFrame.UpdateQuestCount()

            assert.spy(_GetLabel().SetText).was.called_with(match._, "Questie Tracker +")
        end)

        it("should not change the text when the header is hidden", function()
            Questie.db.profile.trackerHeaderEnabled = false

            TrackerHeaderFrame.UpdateQuestCount()

            assert.spy(_GetLabel().SetText).was.not_called()
        end)
    end)

    describe("ExpandLabelWidth", function()
        it("should give the label the full tracker width", function()
            TrackerHeaderFrame.UpdateQuestCount()

            TrackerHeaderFrame.ExpandLabelWidth()

            -- 300 tracker width - (6 icon offset + 12 icon size + 2 gap)
            assert.spy(_GetLabel().SetWidth).was.called_with(match._, 280)
        end)

        it("should make room for the longest quest count when the tracker is narrow", function()
            baseFrame.GetWidth = function() return 100 end
            TrackerHeaderFrame.UpdateQuestCount()

            TrackerHeaderFrame.ExpandLabelWidth()

            -- "Questie Tracker: 25/25" is 22 characters, 10 pixels each in this test
            assert.spy(_GetLabel().SetWidth).was.called_with(match._, 220)
            assert.are_same("Questie Tracker: 9/25", _GetLabel():GetText())
        end)

        it("should not change the width when the header is hidden", function()
            Questie.db.profile.trackerHeaderEnabled = false

            TrackerHeaderFrame.ExpandLabelWidth()

            assert.spy(_GetLabel().SetWidth).was.not_called()
        end)
    end)
end)
