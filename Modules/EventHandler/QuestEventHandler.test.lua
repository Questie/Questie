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
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.AcceptQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)

        QuestEventHandler:QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AcceptQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was_called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestieQuest.AcceptQuest).was_called_with(QuestieQuest, QUEST_ID)
    end)

    it("should handle accept on QLU when quest is initially missing in game cache", function()
        local callbacks = {}
        _G.C_Timer = {After = function(_, callback) table.insert(callbacks, callback) end}
        QuestLogCache.CheckForChanges = spy.new(function() return true, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.AcceptQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)

        QuestEventHandler:QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was_called_with({[QUEST_ID] = true})
        assert.spy(QuestieLib.CacheItemNames).was_called_with(QuestieLib, QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_not_called()
        assert.spy(QuestieJourney.AcceptQuest).was_not_called()
        assert.spy(QuestieAnnounce.AcceptedQuest).was_not_called()
        assert.spy(QuestieQuest.AcceptQuest).was_not_called()
        assert.spy(QuestieTracker.Update).was_not_called()

        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        callbacks[1]()

        QuestEventHandler.QuestLogUpdate()

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AcceptQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestieQuest.AcceptQuest).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.Update).was.called()
    end)

    it("should mark quest as abandoned on quest accept after QUEST_REMOVED", function()
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.AcceptQuest = spy.new(function() end)
        QuestieQuest.AbandonedQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieJourney.AbandonQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)
        QuestieAnnounce.AbandonedQuest = spy.new(function() end)
        _G.C_Timer = {NewTicker = function() return {Cancel = function() end} end} -- This ignores the ticker set on QUEST_REMOVED

        QuestEventHandler:QuestRemoved(QUEST_ID)

        _G.C_Timer = {NewTicker = function(_, callback) callback() return {} end}
        QuestEventHandler:QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.RemoveQuest).was_called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieQuest.AbandonedQuest).was_called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AbandonQuest).was_called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AbandonedQuest).was_called_with(QuestieAnnounce, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieLib.CacheItemNames).was.called_with(QuestieLib, QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called(2)
        assert.spy(QuestieJourney.AcceptQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestieQuest.AcceptQuest).was.called_with(QuestieQuest, QUEST_ID)
    end)

    it("should mark quest as abandoned on QUEST_REMOVED without preceding QUEST_TURNED_IN", function()
        Questie.SendMessage = spy.new(function() end)
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.AbandonedQuest = spy.new(function() end)
        QuestieJourney.AbandonQuest = spy.new(function() end)
        QuestieAnnounce.AbandonedQuest = spy.new(function() end)
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
        local cancelSpy = spy.new(function() end)
        _G.C_Timer = {NewTicker = function() return {Cancel = cancelSpy} end}

        QuestEventHandler:QuestRemoved(QUEST_ID)

        _G.GetNumQuestLogRewards = function() return 1 end
        _G.GetQuestLogRewardInfo = function() return nil, nil, nil, 0, nil, 5 end
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.CompleteQuest = spy.new(function() end)
        QuestieJourney.CompleteQuest = spy.new(function() end)
        QuestieAnnounce.CompletedQuest = spy.new(function() end)
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)

        QuestEventHandler:QuestTurnedIn(QUEST_ID, 1000, 2000)

        assert.spy(cancelSpy).was.called()
        assert.spy(QuestLogCache.RemoveQuest).was.called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieQuest.CompleteQuest).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.CompleteQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.CompletedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
    end)

    it("should handle quest turn in of quests which are not in the quest log", function()
        _G.GetNumQuestLogRewards = function() return 1 end
        _G.GetQuestLogRewardInfo = function() return nil, nil, nil, 0, nil, 5 end
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.CompleteQuest = spy.new(function() end)
        QuestieJourney.CompleteQuest = spy.new(function() end)
        QuestieAnnounce.CompletedQuest = spy.new(function() end)
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
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieNameplate.UpdateNameplate = spy.new(function() end)
        QuestieQuest.UpdateQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)
        QuestieTracker.UpdateQuestLines = spy.new(function() end)
        QuestieTracker.UpdateQuestLines = spy.new()

        QuestEventHandler:QuestWatchUpdate(QUEST_ID)
        QuestEventHandler.QuestLogUpdate()

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieNameplate.UpdateNameplate).was.called()
        assert.spy(QuestieQuest.UpdateQuest).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.UpdateQuestLines).was.called_with(QUEST_ID)
        assert.spy(QuestieTracker.Update).was.called()
    end)

    it("should handle QUEST_AUTOCOMPLETE", function()
        Questie.db.profile.trackerEnabled = true
        WatchFrameHook.Hide = spy.new(function() end)
        AutoCompleteFrame.ShowAutoComplete = spy.new(function() end)

        QuestEventHandler:QuestAutoComplete(QUEST_ID)

        assert.spy(WatchFrameHook.Hide).was.called()
        assert.spy(AutoCompleteFrame.ShowAutoComplete).was.called_with(QUEST_ID)
    end)

    it("should update all quests on PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function()
        _G.C_Timer = {After = function(_, callback) callback() end}
        QuestLogCache.CheckForChanges = spy.new(function() return false, {[QUEST_ID] = {}} end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieNameplate.UpdateNameplate = spy.new(function() end)
        QuestieQuest.UpdateQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)
        QuestieTracker.UpdateQuestLines = spy.new(function() end)
        local bankframeClosedEvent = 8

        QuestEventHandler:PlayerInteractionManagerFrameHide(bankframeClosedEvent)

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieNameplate.UpdateNameplate).was.called()
        assert.spy(QuestieQuest.UpdateQuest).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.UpdateQuestLines).was.called_with(QUEST_ID)
        assert.spy(QuestieTracker.Update).was.called()
    end)
end)
