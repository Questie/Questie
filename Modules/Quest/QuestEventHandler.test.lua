---@type TestUtils
local TestUtils = dofile("setupTests.lua")

_G.GetQuestTimers = function() return nil end

describe("QuestEventHandler", function()
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieJourney
    local QuestieJourney
    ---@type QuestieAnnounce
    local QuestieAnnounce
    ---@type QuestieTracker
    local QuestieTracker
    ---@type QuestEventHandler
    local QuestEventHandler

    before_each(function()
        TestUtils.resetEvents()
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieCombatQueue = require("Modules.Libs.QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end
        QuestLogCache = require("Modules.Quest.QuestLogCache")
        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieJourney = require("Modules.Journey.QuestieJourney")
        QuestieAnnounce = require("Modules.QuestieAnnounce")
        QuestieTracker = require("Modules.Tracker.QuestieTracker")
        QuestEventHandler = require("Modules.Quest.QuestEventHandler")
    end)

    it("should handle quest accept", function()
        QuestieLib.CacheItemNames = spy.new(function() end)
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.AcceptQuest = spy.new()
        QuestieJourney.AcceptQuest = spy.new()
        QuestieAnnounce.AcceptedQuest = spy.new()

        QuestEventHandler:RegisterEvents()

        TestUtils.triggerMockEvent("QUEST_ACCEPTED", 2, 123)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[123] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, 123)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, 123)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, 123)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, 123)
    end)

    it("should handle accept on QLU when quest is initially missing in game cache", function()
        QuestieLib.CacheItemNames = spy.new(function() end)
        QuestLogCache.CheckForChanges = spy.new(function() return true, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.AcceptQuest = spy.new()
        QuestieJourney.AcceptQuest = spy.new()
        QuestieAnnounce.AcceptedQuest = spy.new()
        QuestieTracker.Update = spy.new()

        QuestEventHandler:RegisterEvents()

        TestUtils.triggerMockEvent("QUEST_ACCEPTED", 2, 123)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[123] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, 123)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_not_called()
        assert.spy(QuestieJourney.AcceptQuest).was_not_called()
        assert.spy(QuestieAnnounce.AcceptedQuest).was_not_called()
        assert.spy(QuestieQuest.AcceptQuest).was_not_called()
        assert.spy(QuestieTracker.Update).was_not_called()

        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)

        TestUtils.triggerMockEvent("QUEST_LOG_UPDATE")

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[123] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, 123)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, 123)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieTracker.Update).was_called()
    end)

    it("should mark quest as abandoned on quest accept after QUEST_REMOVED", function()
        QuestieLib.CacheItemNames = spy.new(function() end)
        QuestLogCache.RemoveQuest = spy.new()
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.AcceptQuest = spy.new()
        QuestieQuest.AbandonedQuest = spy.new()
        QuestieJourney.AcceptQuest = spy.new()
        QuestieJourney.AbandonQuest = spy.new()
        QuestieAnnounce.AcceptedQuest = spy.new()
        QuestieAnnounce.AbandonedQuest = spy.new()
        _G.C_Timer = {NewTicker = function() return {Cancel = function() end} end} -- This ignores the ticker set on QUEST_REMOVED

        QuestEventHandler:RegisterEvents()

        TestUtils.triggerMockEvent("QUEST_REMOVED", 123)

        _G.C_Timer = {NewTicker = function(_, callback) callback() return {} end}
        TestUtils.triggerMockEvent("QUEST_ACCEPTED", 2, 123)

        assert.spy(QuestLogCache.RemoveQuest).was_called_with(123)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieQuest.AbandonedQuest).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieJourney.AbandonQuest).was_called_with(QuestieJourney, 123)
        assert.spy(QuestieAnnounce.AbandonedQuest).was_called_with(QuestieAnnounce, 123)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[123] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, 123)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called(2)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, 123)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, 123)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, 123)
    end)

    it("should mark quest as abandoned on QUEST_REMOVED without preceding QUEST_TURNED_IN", function()
        Questie.SendMessage = spy.new()
        _G.C_Timer = {NewTicker = function(_, callback) callback() return {} end}

        QuestEventHandler:RegisterEvents()

        TestUtils.triggerMockEvent("QUEST_REMOVED", 123)

        assert.spy(Questie.SendMessage).was_called_with(Questie, "QC_ID_BROADCAST_QUEST_REMOVE", 123)
        assert.spy(QuestLogCache.RemoveQuest).was_called_with(123)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieQuest.AbandonedQuest).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieJourney.AbandonQuest).was_called_with(QuestieJourney, 123)
        assert.spy(QuestieAnnounce.AbandonedQuest).was_called_with(QuestieAnnounce, 123)
    end)
end)
