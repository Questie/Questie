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
    ---@type QuestEventHandler
    local QuestEventHandler

    before_each(function()
        TestUtils.resetEvents()
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieCombatQueue = require("Modules.Libs.QuestieCombatQueue")
        QuestLogCache = require("Modules.Quest.QuestLogCache")
        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieJourney = require("Modules.Journey.QuestieJourney")
        QuestieAnnounce = require("Modules.QuestieAnnounce")
        QuestEventHandler = require("Modules.Quest.QuestEventHandler")
    end)

    it("should handle quest accept", function()
        QuestieLib.CacheItemNames = spy.new(function() end)
        QuestieCombatQueue.Queue = function(_, func)
            func()
        end
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
end)
