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

        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, 123)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_not_called()
        assert.spy(QuestieJourney.AcceptQuest).was_not_called()
        assert.spy(QuestieAnnounce.AcceptedQuest).was_not_called()
        assert.spy(QuestieQuest.AcceptQuest).was_not_called()
        assert.spy(QuestieTracker.Update).was_not_called()

        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)

        TestUtils.triggerMockEvent("QUEST_LOG_UPDATE")

        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, 123)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, 123)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, 123)
        assert.spy(QuestieTracker.Update).was_called()
    end)
end)
