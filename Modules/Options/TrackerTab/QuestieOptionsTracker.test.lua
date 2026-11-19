dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("tracker automatic tracking option", function()
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
        compat.QuestLog_Update = spy.new(function() end)
        visibility = QuestieLoader:ImportModule("CommsVisibility")
        visibility.ScheduleSnapshot = spy.new(function() end)
        dofile("Modules/Tracker/TrackerShortcuts.lua")
        dofile("Modules/Options/TrackerTab/QuestieOptionsTracker.lua")
    end)

    after_each(function()
        _G.LibStub = originals.LibStub
        _G.QuestLogExFrame = originals.QuestLogExFrame
        _G.ClassicQuestLog = originals.ClassicQuestLog
        _G.QuestLogFrame = originals.QuestLogFrame
        _G.QuestMapFrame = originals.QuestMapFrame
    end)

    it("shows TomTom integration options only while TomTom is available", function()
        local isTomTomAvailable = false
        QuestieLoader:ImportModule("TrackerUtils").IsTomTomAvailable = function() return isTomTomAvailable end
        local settings = options.tabs.tracker:Initialize()
        local tomTom = settings.args.group_quests.args.group_shortcuts.args.setTomTom

        assert.is_true(tomTom.hidden())
        isTomTomAvailable = true
        assert.is_false(tomTom.hidden())
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

    it("should change the share quest shortcut", function()
        local settings = options.tabs.tracker:Initialize()
        local shareQuest = settings.args.group_quests.args.group_shortcuts.args.shareQuest

        shareQuest.set(nil, "altleft")

        assert.are_same("altleft", shareQuest.get())
        assert.are_same("altleft", Questie.db.profile.trackerbindShareQuest)
    end)

    it("disables the other action when a shortcut dropdown takes its click", function()
        local shortcutDropdowns = {
            openQuestLog = "trackerbindOpenQuestLog",
            untrackQuest = "trackerbindUntrack",
            shareQuest = "trackerbindShareQuest",
            setTomTom = "trackerbindSetTomTom",
        }
        local args = options.tabs.tracker:Initialize().args.group_quests.args.group_shortcuts.args

        for dropdown, setting in pairs(shortcutDropdowns) do
            for _, otherSetting in pairs(shortcutDropdowns) do
                Questie.db.profile[otherSetting] = otherSetting == setting and "disabled" or "altright"
            end

            args[dropdown].set(nil, "altright")

            for _, otherSetting in pairs(shortcutDropdowns) do
                assert.are_same(otherSetting == setting and "altright" or "disabled", Questie.db.profile[otherSetting], dropdown)
            end
        end
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
