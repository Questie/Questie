dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("native tracker options", function()
    local isAddOnLoadedMock
    local originals
    local QuestieOptionsEngine, tracker, compat, visibility, trackerUtils
    local isVoiceOverLoadedStub, isSpokenLoadedStub

    -- Visibility is decided once when the tab is defined, so each case defines the tab after setting up the addons.
    local function LoadTab()
        dofile("Modules/Options/NativeOptions/NativeOptionsTracker.lua")
        return QuestieOptionsEngine.tabs.tracker:Initialize().items
    end

    before_each(function()
        originals = {
            LibStub = _G.LibStub,
            QuestLogExFrame = _G.QuestLogExFrame,
            ClassicQuestLog = _G.ClassicQuestLog,
            QuestLogFrame = _G.QuestLogFrame,
            QuestMapFrame = _G.QuestMapFrame,
        }
        _G.QuestLogExFrame = nil
        _G.ClassicQuestLog = nil
        _G.QuestLogFrame = nil
        _G.QuestMapFrame = {IsShown = function() return true end}
        _G.LibStub = function() return {HashTable = function() return {} end} end
        Questie.db = {profile = {}, char = {}}
        QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        QuestieOptionsEngine.tabs = {}
        tracker = QuestieLoader:ImportModule("QuestieTracker")
        tracker.Update = spy.new(function() end)
        tracker.UpdateFormatting = spy.new(function() end)
        compat = QuestieLoader:ImportModule("QuestieCompat")
        isAddOnLoadedMock = stub(compat, "IsAddOnLoaded", function() return false end)
        compat.QuestLog_Update = spy.new(function() end)
        visibility = QuestieLoader:ImportModule("CommsVisibility")
        visibility.ScheduleSnapshot = spy.new(function() end)
        trackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        trackerUtils.IsVoiceOverLoaded = trackerUtils.IsVoiceOverLoaded or function() end
        trackerUtils.IsSpokenLoaded = trackerUtils.IsSpokenLoaded or function() end
        isVoiceOverLoadedStub = stub(trackerUtils, "IsVoiceOverLoaded", function() return false end)
        isSpokenLoadedStub = stub(trackerUtils, "IsSpokenLoaded", function() return false end)
    end)

    after_each(function()
        isAddOnLoadedMock:revert()
        isVoiceOverLoadedStub:revert()
        isSpokenLoadedStub:revert()
        _G.LibStub = originals.LibStub
        _G.QuestLogExFrame = originals.QuestLogExFrame
        _G.ClassicQuestLog = originals.ClassicQuestLog
        _G.QuestLogFrame = originals.QuestLogFrame
        _G.QuestMapFrame = originals.QuestMapFrame
    end)

    it("shows TomTom integration options only when the addon is loaded", function()
        assert.is_false(LoadTab().group_tracker_window.items.setTomTom.visible)

        isAddOnLoadedMock.returns(true)

        assert.is_true(LoadTab().group_tracker_window.items.setTomTom.visible)
        assert.spy(isAddOnLoadedMock).was.called_with("TomTom")
    end)

    it("should show the sticky VoiceOver frame option only when VoiceOver is used", function()
        assert.is_false(LoadTab().group_tracker_window.items.stickyVoiceOverFrame.visible)

        isVoiceOverLoadedStub.returns(true)

        assert.is_true(LoadTab().group_tracker_window.items.stickyVoiceOverFrame.visible)
    end)

    it("should show the play buttons option only when VoiceOver or Spoken is used", function()
        assert.is_false(LoadTab().group_tracker_window.items.showPlayButtons.visible)

        isSpokenLoadedStub.returns(true)

        assert.is_true(LoadTab().group_tracker_window.items.showPlayButtons.visible)
    end)

    it("should show the play buttons option when only VoiceOver is used", function()
        isVoiceOverLoadedStub.returns(true)

        assert.is_true(LoadTab().group_tracker_window.items.showPlayButtons.visible)
    end)

    it("should change the play buttons setting and update the tracker", function()
        Questie.db.profile.trackerShowPlayButtons = true
        local showPlayButtons = LoadTab().group_tracker_window.items.showPlayButtons

        showPlayButtons.set(nil, false)

        assert.is_false(showPlayButtons.get())
        assert.is_false(Questie.db.profile.trackerShowPlayButtons)
        assert.spy(tracker.Update).was.called_with(tracker)
    end)

    it("updates the tracker and publishes visibility when only the modern log exists", function()
        LoadTab().group_quests.items.autoTrackQuests.set(nil, true)

        assert.is_true(Questie.db.profile.autoTrackQuests)
        assert.are.same({}, Questie.db.char.TrackedQuests)
        assert.spy(tracker.Update).was.called_with(tracker)
        assert.spy(visibility.ScheduleSnapshot).was.called_with(visibility, "AUTO_TRACK_QUESTS")
        assert.spy(compat.QuestLog_Update).was.not_called()
    end)

    -- Quest-log checks skip unchanged quests, so this setting must request the quest lines itself.
    it("lays out the tracker when always showing it expands a minimized tracker", function()
        Questie.db.char.isTrackerExpanded = false

        LoadTab().group_tracker_window.items.group_header.items.alwaysShowTracker.set(nil, true)

        assert.is_true(Questie.db.char.isTrackerExpanded)
        assert.spy(tracker.Update).was.called_with(tracker)
        assert.spy(tracker.UpdateFormatting).was.called_with(tracker)
    end)

    -- The sliders call the setter with userInput during a drag, and without it when the drag ended.
    describe("tracker size ratios", function()
        local TrackerBaseFrame

        before_each(function()
            TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
            Questie.db.profile = {
                TrackerHeight = 0,
                TrackerWidth = 0,
                trackerBackdropEnabled = false,
                currentBackdropEnabled = false,
                trackerBorderEnabled = false,
                currentBorderEnabled = false,
                trackerBackdropFader = true,
                currentBackdropFader = true,
            }
        end)

        for key, profileKey in pairs({trackerHeightRatio = "trackerHeightRatio", trackerWidthRatio = "trackerWidthRatio"}) do
            it("should show the sizing backdrop while dragging " .. key, function()
                LoadTab().group_tracker_window.items[key].set(nil, 50, true)

                assert.are.equal(0.5, Questie.db.profile[profileKey])
                assert.is_true(TrackerBaseFrame.isSizing)
                assert.is_true(Questie.db.profile.trackerBackdropEnabled)
                assert.is_true(Questie.db.profile.trackerBorderEnabled)
                assert.is_false(Questie.db.profile.trackerBackdropFader)
            end)

            it("should restore the user's backdrop when dragging " .. key .. " ended", function()
                local option = LoadTab().group_tracker_window.items[key]
                option.set(nil, 50, true)

                option.set(nil, 50, false)

                assert.is_false(TrackerBaseFrame.isSizing)
                assert.is_false(Questie.db.profile.trackerBackdropEnabled)
                assert.is_false(Questie.db.profile.trackerBorderEnabled)
                assert.is_true(Questie.db.profile.trackerBackdropFader)
            end)
        end
    end)
end)
