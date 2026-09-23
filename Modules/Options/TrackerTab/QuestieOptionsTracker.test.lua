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

    it("updates the tracker and publishes visibility when only the modern log exists", function()
        local settings = options.tabs.tracker:Initialize()
        settings.args.group_quests.args.autoTrackQuests.set(nil, true)
        assert.is_true(Questie.db.profile.autoTrackQuests)
        assert.are.same({}, Questie.db.char.TrackedQuests)
        assert.spy(tracker.Update).was.called_with(tracker)
        assert.spy(visibility.ScheduleSnapshot).was.called_with(visibility, "AUTO_TRACK_QUESTS")
        assert.spy(compat.QuestLog_Update).was.not_called()
    end)
end)
