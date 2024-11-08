dofile("setupTests.lua")

_G.GetQuestTimers = function() return nil end

local QUEST_ID = 123

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
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieNameplate
    local QuestieNameplate
    ---@type WatchFrameHook
    local WatchFrameHook
    ---@type AutoCompleteFrame
    local AutoCompleteFrame
    ---@type QuestEventHandler
    local QuestEventHandler

    before_each(function()
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieCombatQueue = require("Modules.Libs.QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end
        QuestLogCache = require("Modules.Quest.QuestLogCache")
        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieJourney = require("Modules.Journey.QuestieJourney")
        QuestieAnnounce = require("Modules.QuestieAnnounce")
        QuestieTracker = require("Modules.Tracker.QuestieTracker")
        QuestieDB = require("Database.QuestieDB")
        QuestieNameplate = require("Modules.QuestieNameplate")
        WatchFrameHook = require("Modules.WatchFrameHook")
        AutoCompleteFrame = require("Modules.Tracker.AutoCompleteFrame")
        QuestEventHandler = require("Modules.EventHandler.QuestEventHandler")

        QuestieLib.CacheItemNames = spy.new(function() end)

        QuestEventHandler.InitQuestLogStates({[QUEST_ID] = true})
    end)

    it("should handle quest accept", function()
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.AcceptQuest = spy.new()
        QuestieJourney.AcceptQuest = spy.new()
        QuestieAnnounce.AcceptedQuest = spy.new()

        QuestEventHandler:QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, QUEST_ID)
    end)

    it("should handle accept on QLU when quest is initially missing in game cache", function()
        QuestLogCache.CheckForChanges = spy.new(function() return true, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.AcceptQuest = spy.new()
        QuestieJourney.AcceptQuest = spy.new()
        QuestieAnnounce.AcceptedQuest = spy.new()
        QuestieTracker.Update = spy.new()

        QuestEventHandler:QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_not_called()
        assert.spy(QuestieJourney.AcceptQuest).was_not_called()
        assert.spy(QuestieAnnounce.AcceptedQuest).was_not_called()
        assert.spy(QuestieQuest.AcceptQuest).was_not_called()
        assert.spy(QuestieTracker.Update).was_not_called()

        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)

        QuestEventHandler.QuestLogUpdate()

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.Update).was_called()
    end)

    it("should mark quest as abandoned on quest accept after QUEST_REMOVED", function()
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

        QuestEventHandler:QuestRemoved(QUEST_ID)

        _G.C_Timer = {NewTicker = function(_, callback) callback() return {} end}
        QuestEventHandler:QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.RemoveQuest).was_called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieQuest.AbandonedQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AbandonQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AbandonedQuest).was_called_with(QuestieAnnounce, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called(2)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, QUEST_ID)
    end)

    it("should mark quest as abandoned on QUEST_REMOVED without preceding QUEST_TURNED_IN", function()
        Questie.SendMessage = spy.new()
        QuestLogCache.RemoveQuest = spy.new()
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.AbandonedQuest = spy.new()
        QuestieJourney.AbandonQuest = spy.new()
        QuestieAnnounce.AbandonedQuest = spy.new()
        local callbacks = {}
        _G.C_Timer = {NewTicker = function(_, callback) table.insert(callbacks, callback) return {} end}

        QuestEventHandler:QuestRemoved(QUEST_ID)
        callbacks[1]()

        assert.spy(Questie.SendMessage).was_called_with(Questie, "QC_ID_BROADCAST_QUEST_REMOVE", QUEST_ID)
        assert.spy(QuestLogCache.RemoveQuest).was_called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieQuest.AbandonedQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AbandonQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AbandonedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
    end)

    it("should handle quest turn in", function()
        local cancelSpy = spy.new()
        _G.C_Timer = {NewTicker = function() return {Cancel = cancelSpy} end}

        QuestEventHandler:QuestRemoved(QUEST_ID)

        _G.GetNumQuestLogRewards = function() return 1 end
        _G.GetQuestLogRewardInfo = function() return nil, nil, nil, 0, nil, 5 end
        QuestLogCache.RemoveQuest = spy.new()
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.CompleteQuest = spy.new()
        QuestieJourney.CompleteQuest = spy.new()
        QuestieAnnounce.CompletedQuest = spy.new()
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)

        QuestEventHandler:QuestTurnedIn(QUEST_ID, 1000, 2000)

        assert.spy(cancelSpy).was_called()
        assert.spy(QuestLogCache.RemoveQuest).was_called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieQuest.CompleteQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.CompleteQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.CompletedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
    end)

    it("should handle quest turn in of quests which are not in the quest log", function()
        _G.GetNumQuestLogRewards = function() return 1 end
        _G.GetQuestLogRewardInfo = function() return nil, nil, nil, 0, nil, 5 end
        QuestLogCache.RemoveQuest = spy.new()
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieQuest.CompleteQuest = spy.new()
        QuestieJourney.CompleteQuest = spy.new()
        QuestieAnnounce.CompletedQuest = spy.new()
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)

        QuestEventHandler:QuestTurnedIn(QUEST_ID, 1000, 2000)

        assert.spy(QuestLogCache.RemoveQuest).was_called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieQuest.CompleteQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.CompleteQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.CompletedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
    end)

    it("should do full quest log scan after QUEST_WATCH_UPDATE", function()
        _G.C_Timer = {After = function(_, callback) callback() end}
        QuestLogCache.CheckForChanges = spy.new(function() return false, {[QUEST_ID] = {}} end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieNameplate.UpdateNameplate = spy.new()
        QuestieQuest.UpdateQuest = spy.new()
        QuestieTracker.Update = spy.new()

        QuestEventHandler:QuestWatchUpdate(QUEST_ID)
        QuestEventHandler.QuestLogUpdate()

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieNameplate.UpdateNameplate).was_called()
        assert.spy(QuestieQuest.UpdateQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.Update).was_called()
    end)

    it("should handle QUEST_AUTOCOMPLETE", function()
        Questie.db.profile.trackerEnabled = true
        WatchFrameHook.Hide = spy.new()
        AutoCompleteFrame.ShowAutoComplete = spy.new()

        QuestEventHandler:QuestAutoComplete(QUEST_ID)

        assert.spy(WatchFrameHook.Hide).was_called()
        assert.spy(AutoCompleteFrame.ShowAutoComplete).was_called_with(QUEST_ID)
    end)

    it("should update all quests on PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function()
        _G.C_Timer = {After = function(_, callback) callback() end}
        QuestLogCache.CheckForChanges = spy.new(function() return false, {[QUEST_ID] = {}} end)
        QuestieQuest.SetObjectivesDirty = spy.new()
        QuestieNameplate.UpdateNameplate = spy.new()
        QuestieQuest.UpdateQuest = spy.new()
        QuestieTracker.Update = spy.new()
        local bankframeClosedEvent = 8

        QuestEventHandler:PlayerInteractionManagerFrameHide(bankframeClosedEvent)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieNameplate.UpdateNameplate).was_called()
        assert.spy(QuestieQuest.UpdateQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.Update).was_called()
    end)
end)
