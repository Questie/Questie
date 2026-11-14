dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("tracker automatic tracking option", function()
    local isAddOnLoadedMock
    local originals
    local options, tracker, compat, visibility

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
        local utils = QuestieLoader:ImportModule("QuestieOptionsUtils")
        utils.Spacer = function() return {} end
        utils.HorizontalSpacer = function() return {} end
        options = QuestieLoader:ImportModule("QuestieOptions")
        options.tabs = {}
        tracker = QuestieLoader:ImportModule("QuestieTracker")
        tracker.Update = spy.new(function() end)
        compat = QuestieLoader:ImportModule("QuestieCompat")
        isAddOnLoadedMock = stub(compat, "IsAddOnLoaded", function() return false end)
        compat.QuestLog_Update = spy.new(function() end)
        visibility = QuestieLoader:ImportModule("CommsVisibility")
        visibility.ScheduleSnapshot = spy.new(function() end)
        dofile("Modules/Options/TrackerTab/QuestieOptionsTracker.lua")
    end)

    after_each(function()
        isAddOnLoadedMock:revert()
        _G.LibStub = originals.LibStub
        _G.QuestLogExFrame = originals.QuestLogExFrame
        _G.ClassicQuestLog = originals.ClassicQuestLog
        _G.QuestLogFrame = originals.QuestLogFrame
        _G.QuestMapFrame = originals.QuestMapFrame
    end)

    it("shows TomTom integration options only when the addon is loaded", function()
        local settings = options.tabs.tracker:Initialize()
        local tomTom = settings.args.group_tracker.args.setTomTom

        assert.is_true(tomTom.hidden())
        isAddOnLoadedMock.returns(true)
        assert.is_false(tomTom.hidden())
        assert.spy(isAddOnLoadedMock).was.called_with("TomTom")
    end)

    it("should show the sticky VoiceOver frame option only when VoiceOver is used", function()
        local trackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        local isVoiceOverLoadedStub = stub(trackerUtils, "IsVoiceOverLoaded", function() return false end)
        local settings = options.tabs.tracker:Initialize()
        local stickyVoiceOverFrame = settings.args.group_tracker.args.stickyVoiceOverFrame

        assert.is_true(stickyVoiceOverFrame.hidden())
        isVoiceOverLoadedStub.returns(true)
        assert.is_false(stickyVoiceOverFrame.hidden())
        isVoiceOverLoadedStub:revert()
    end)

    it("should show the play buttons option only when VoiceOver or Spoken is used", function()
        local trackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        local isVoiceOverLoadedStub = stub(trackerUtils, "IsVoiceOverLoaded", function() return false end)
        local isSpokenLoadedStub = stub(trackerUtils, "IsSpokenLoaded", function() return false end)
        local settings = options.tabs.tracker:Initialize()
        local showPlayButtons = settings.args.group_tracker.args.showPlayButtons

        assert.is_true(showPlayButtons.hidden())
        isSpokenLoadedStub.returns(true)
        assert.is_false(showPlayButtons.hidden())
        isVoiceOverLoadedStub:revert()
        isSpokenLoadedStub:revert()
    end)

    it("should change the play buttons setting and update the tracker", function()
        Questie.db.profile.trackerShowPlayButtons = true
        local settings = options.tabs.tracker:Initialize()
        local showPlayButtons = settings.args.group_tracker.args.showPlayButtons

        showPlayButtons.set(nil, false)

        assert.is_false(showPlayButtons.get())
        assert.is_false(Questie.db.profile.trackerShowPlayButtons)
        assert.spy(tracker.Update).was.called_with(tracker)
    end)

    it("should show the follow super tracking option only when super tracking is supported", function()
        local supported = false
        compat.IsSuperTrackingSupported = function() return supported end
        local settings = options.tabs.tracker:Initialize()
        local followSuperTracking = settings.args.group_quests.args.followSuperTracking

        assert.is_true(followSuperTracking.hidden())
        supported = true
        assert.is_false(followSuperTracking.hidden())
    end)

    it("should change the follow super tracking setting", function()
        Questie.db.profile.trackerFollowSuperTracking = false
        local settings = options.tabs.tracker:Initialize()
        local followSuperTracking = settings.args.group_quests.args.followSuperTracking

        followSuperTracking.set(nil, true)

        assert.is_true(followSuperTracking.get())
        assert.is_true(Questie.db.profile.trackerFollowSuperTracking)
    end)

    it("updates the tracker and publishes visibility when only the modern log exists", function()
        local settings = options.tabs.tracker:Initialize()
        settings.args.group_quests.args.autoTrackQuests.set(nil, true)
        assert.is_true(Questie.db.profile.autoTrackQuests)
        assert.are.same({}, Questie.db.char.TrackedQuests)
        assert.spy(tracker.Update).was.called_with(tracker)
        assert.spy(visibility.ScheduleSnapshot).was.called_with(visibility, "AUTO_TRACK_QUESTS")
        assert.spy(compat.QuestLog_Update).was.not_called()
    end)

    -- Quest-log checks skip unchanged quests, so this setting must request the quest lines itself.
    it("lays out the tracker when always showing it expands a minimized tracker", function()
        tracker.UpdateFormatting = spy.new(function() end)
        Questie.db.char.isTrackerExpanded = false
        local settings = options.tabs.tracker:Initialize()

        settings.args.group_tracker.args.group_header.args.alwaysShowTracker.set(nil, true)

        assert.is_true(Questie.db.char.isTrackerExpanded)
        assert.spy(tracker.Update).was.called_with(tracker)
    end)
end)
