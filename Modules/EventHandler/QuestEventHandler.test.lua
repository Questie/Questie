dofile("setupTests.lua")
local stub = require("luassert.stub")
dofile("Localization/l10n.lua")

_G.GetQuestTimers = function() return nil end

local QUEST_ID = 123
local match = require("luassert.match")

describe("QuestEventHandler", function()
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestLifecycle
    local QuestLifecycle
    ---@type QuestieJourney
    local QuestieJourney
    ---@type AutoQuesting
    local AutoQuesting
    ---@type QuestieAnnounce
    local QuestieAnnounce
    ---@type QuestiePlayer
    local QuestiePlayer
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
    ---@type QuestieAPI
    local QuestieAPI
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives
    ---@type AvailableQuests
    local AvailableQuests
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestEventHandler
    local QuestEventHandler
    ---@type BreadcrumbQuests
    local BreadcrumbQuests
    local originalTimer, originalTime, newTimerMock, retryTimers

    before_each(function()
        originalTimer, originalTime = _G.C_Timer, _G.GetTime
        retryTimers = {}
        newTimerMock = spy.new(function(delay, callback)
            local timer = {delay = delay, callback = callback, Cancel = spy.new(function() end)}
            retryTimers[#retryTimers + 1] = timer
            return timer
        end)
        _G.C_Timer = {NewTimer = newTimerMock}
        Questie.db.profile.autoAccept = {enabled = false}
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end
        BreadcrumbQuests = QuestieLoader:ImportModule("BreadcrumbQuests")
        BreadcrumbQuests.CheckQuestBreadcrumbs = spy.new(function() end)
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestLifecycle = QuestieLoader:ImportModule("QuestLifecycle")
        AutoQuesting = QuestieLoader:ImportModule("AutoQuesting")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.Update = spy.new(function() end)
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
        WatchFrameHook = QuestieLoader:ImportModule("WatchFrameHook")
        AutoCompleteFrame = QuestieLoader:ImportModule("AutoCompleteFrame")
        dofile("Public/Enums.lua")
        QuestieAPI = QuestieLoader:ImportModule("QuestieAPI")
        QuestieAPI.PropagateQuestUpdate = spy.new(function() end)
        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.ResetLastNpcGuid = spy.new(function() end)
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.RepairMissingItemNames = spy.new(function() end)

        dofile("Modules/EventHandler/QuestEventHandler.lua")
        QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
        QuestEventHandler.InitQuestLogStates({[QUEST_ID] = true})
    end)

    after_each(function()
        _G.C_Timer, _G.GetTime = originalTimer, originalTime
    end)

    describe("quest item deletion warning", function()
        local getItemInfoMock, getQuestLogTitleMock, getQuestMock, queryItemMock
        local showPopupMock, hookMock, forEachDialogMock, resizeMock
        local hooks, dialog

        before_each(function()
            local compat = QuestieLoader:ImportModule("QuestieCompat")
            getItemInfoMock = stub(compat, "GetItemInfo", function() return "A Letter" end)
            getQuestLogTitleMock = stub(compat, "GetQuestLogTitle", function(index)
                if index == 1 then
                    return "Deliver the Letter", nil, nil, false, nil, nil, nil, QUEST_ID
                end
            end)
            getQuestMock = stub(QuestieDB, "GetQuest", function()
                return {name = "Deliver the Letter", sourceItemId = 456}
            end)
            queryItemMock = stub(QuestieDB, "QueryItemSingle", function() return 12 end)
            hooks = {}
            showPopupMock = stub(_G, "StaticPopup_Show")
            hookMock = stub(_G, "hooksecurefunc", function(name, callback) hooks[name] = callback end)
            dialog = {Text = {text_arg1 = "A Letter", SetFormattedText = spy.new(function() end)}}
            forEachDialogMock = stub(_G, "StaticPopup_ForEachShownDialog", function(callback) callback(dialog) end)
            resizeMock = stub(_G, "StaticPopup_ResizeShownDialogs")
            dofile("Modules/EventHandler/QuestEventHandler.lua")
            QuestEventHandler:Initialize()
        end)

        after_each(function()
            getItemInfoMock:revert()
            getQuestLogTitleMock:revert()
            getQuestMock:revert()
            queryItemMock:revert()
            showPopupMock:revert()
            hookMock:revert()
            forEachDialogMock:revert()
            resizeMock:revert()
        end)

        it("matches a cached source item name to the deletion dialog", function()
            hooks.StaticPopup_Show("DELETE_ITEM", "A Letter")

            assert.spy(getItemInfoMock).was.called_with(456)
            assert.spy(dialog.Text.SetFormattedText).was.called_with(match._,
                "Quest Item %s might be needed for the quest %s. \n\nAre you sure you want to delete this?",
                "A Letter", "Deliver the Letter")
            assert.spy(resizeMock).was.called(1)
        end)

        it("matches an item objective by its ID when display wording has a trailing space", function()
            getQuestMock.returns({name = "Collect Cloth", Objectives = {
                {Type = "item", Id = 789, Description = "Étoffe de laine "},
            }})
            getItemInfoMock.returns("Étoffe de laine")
            dialog.Text.text_arg1 = "Étoffe de laine"

            hooks.StaticPopup_Show("DELETE_ITEM", "Étoffe de laine")

            assert.spy(getItemInfoMock).was.called_with(789)
            assert.spy(dialog.Text.SetFormattedText).was.called_with(match._,
                "Quest Item %s might be needed for the quest %s. \n\nAre you sure you want to delete this?",
                "Étoffe de laine", "Collect Cloth")
            assert.spy(resizeMock).was.called(1)
        end)

        it("does not mistake another objective type's description for an item name", function()
            getQuestMock.returns({name = "Deliver the Letter", Objectives = {
                {Type = "monster", Id = 789, Description = "A Letter"},
            }})

            hooks.StaticPopup_Show("DELETE_ITEM", "A Letter")

            assert.spy(getItemInfoMock).was.not_called()
            assert.spy(dialog.Text.SetFormattedText).was.not_called()
        end)

        it("does not fall back to display wording when the objective item name is unavailable", function()
            getQuestMock.returns({name = "Deliver the Letter", Objectives = {
                {Type = "item", Id = 789, Description = "A Letter"},
            }})
            getItemInfoMock.returns(nil)

            hooks.StaticPopup_Show("DELETE_ITEM", "A Letter")

            assert.spy(getItemInfoMock).was.called_with(789)
            assert.spy(dialog.Text.SetFormattedText).was.not_called()
        end)

        it("leaves the dialog unchanged when the source item name is not cached", function()
            getItemInfoMock.returns(nil)

            hooks.StaticPopup_Show("DELETE_ITEM", "A Letter")

            assert.spy(getItemInfoMock).was.called_with(456)
            assert.spy(dialog.Text.SetFormattedText).was.not_called()
            assert.spy(resizeMock).was.not_called()
        end)
    end)

    it("should request missing Item names for every quest already in the quest log at login", function()
        QuestieLib.RepairMissingItemNames:clear()

        QuestEventHandler.InitQuestLogStates({[QUEST_ID] = true, [456] = true})

        assert.spy(QuestieLib.RepairMissingItemNames).was.called(2)
        assert.spy(QuestieLib.RepairMissingItemNames).was.called_with(QUEST_ID)
        assert.spy(QuestieLib.RepairMissingItemNames).was.called_with(456)
    end)

    it("should handle quest accept", function()
        QuestieLib.RepairMissingItemNames:clear()
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.AcceptQuest = spy.new(function(_, questId)
            QuestiePlayer.currentQuestlog[questId] = {} -- Mimic the important part of QuestLifecycle:AcceptQuest
        end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)

        QuestEventHandler.QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AcceptQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestLifecycle.AcceptQuest).was.called_with(QuestLifecycle, QUEST_ID)
        assert.spy(BreadcrumbQuests.CheckQuestBreadcrumbs).was.called(1)
        assert.spy(BreadcrumbQuests.CheckQuestBreadcrumbs).was.called_with(QUEST_ID)
        assert.spy(QuestieLib.RepairMissingItemNames).was.called(1)
        assert.spy(QuestieLib.RepairMissingItemNames).was.called_with(QUEST_ID)
    end)

    it("should handle accept on QLU when quest is initially missing in game cache", function()
        local callbacks = {}
        _G.C_Timer = {After = function(_, callback) table.insert(callbacks, callback) end, NewTimer = newTimerMock}
        QuestLogCache.CheckForChanges = spy.new(function() return true, nil end)
        QuestieAPI.PropagateQuestUpdate = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.AcceptQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)

        _G.GetTime = function() return 1000 end
        QuestEventHandler.QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieAPI.PropagateQuestUpdate).was.not_called()
        assert.spy(QuestieQuest.SetObjectivesDirty).was.not_called()
        assert.spy(QuestieJourney.AcceptQuest).was.not_called()
        assert.spy(QuestieAnnounce.AcceptedQuest).was.not_called()
        assert.spy(QuestLifecycle.AcceptQuest).was.not_called()
        assert.spy(QuestieTracker.Update).was.called(1)

        QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
        callbacks[1]()

        _G.GetTime = function() return 1010 end
        QuestEventHandler.QuestLogUpdate()

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieAPI.PropagateQuestUpdate).was.called_with(QUEST_ID, {}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_ACCEPTED)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieJourney.AcceptQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestLifecycle.AcceptQuest).was.called_with(QuestLifecycle, QUEST_ID)
        assert.spy(QuestieTracker.Update).was.called()
    end)

    it("should hide Immersion frame when quest was auto accepted and modifier is not held", function()
        Questie.db.profile.autoAccept.enabled = true
        AutoQuesting.IsModifierHeld = function() return false end
        local ImmersionFrameHideMock = spy.new(function() end)
        _G.ImmersionFrame = {IsShown = function() return true end, Hide = ImmersionFrameHideMock}
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.AcceptQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)

        QuestEventHandler.QuestAccepted(2, QUEST_ID)

        assert.spy(ImmersionFrameHideMock).was.called()
    end)

    it("should not hide Immersion frame when quest was auto accepted and modifier is held", function()
        Questie.db.profile.autoAccept.enabled = true
        AutoQuesting.IsModifierHeld = function() return true end
        local ImmersionFrameHideMock = spy.new(function() end)
        _G.ImmersionFrame = {IsShown = function() return true end, Hide = ImmersionFrameHideMock}
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.AcceptQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)

        QuestEventHandler.QuestAccepted(2, QUEST_ID)

        assert.spy(ImmersionFrameHideMock).was.not_called()
    end)

    it("should mark quest as abandoned on quest accept after QUEST_REMOVED", function()
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestLogCache.CheckForChanges = spy.new(function() return false, nil end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.AcceptQuest = spy.new(function() end)
        QuestLifecycle.AbandonQuest = spy.new(function() end)
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieJourney.AbandonQuest = spy.new(function() end)
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)
        QuestieAnnounce.AbandonedQuest = spy.new(function() end)
        _G.C_Timer = {NewTicker = function() return {Cancel = function() end} end} -- This ignores the ticker set on QUEST_REMOVED

        QuestEventHandler.QuestRemoved(QUEST_ID)

        _G.C_Timer = {
            NewTicker = function(_, callback)
                callback()
                return {}
            end
        }
        QuestEventHandler.QuestAccepted(2, QUEST_ID)

        assert.spy(QuestLogCache.RemoveQuest).was.called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestLifecycle.AbandonQuest).was.called_with(QuestLifecycle, QUEST_ID)
        assert.spy(QuestieJourney.AbandonQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AbandonedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(AvailableQuests.ResetLastNpcGuid).was.called()

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called(2)
        assert.spy(QuestieJourney.AcceptQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AcceptedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(QuestLifecycle.AcceptQuest).was.called_with(QuestLifecycle, QUEST_ID)
    end)

    it("should mark quest as abandoned on QUEST_REMOVED without preceding QUEST_TURNED_IN", function()
        Questie.SendMessage = spy.new(function() end)
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.AbandonQuest = spy.new(function() end)
        QuestieJourney.AbandonQuest = spy.new(function() end)
        QuestieAnnounce.AbandonedQuest = spy.new(function() end)
        local callbacks = {}
        _G.C_Timer = {
            NewTicker = function(_, callback)
                table.insert(callbacks, callback)
                return {}
            end
        }

        QuestEventHandler.QuestRemoved(QUEST_ID)
        callbacks[1]()

        assert.spy(Questie.SendMessage).was.called_with(Questie, "QC_ID_BROADCAST_QUEST_REMOVE", QUEST_ID)
        assert.spy(QuestLogCache.RemoveQuest).was.called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestLifecycle.AbandonQuest).was.called_with(QuestLifecycle, QUEST_ID)
        assert.spy(QuestieJourney.AbandonQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.AbandonedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
        assert.spy(AvailableQuests.ResetLastNpcGuid).was.called()
    end)

    it("should handle quest turn in", function()
        local cancelSpy = spy.new(function() end)
        _G.C_Timer = {NewTicker = function() return {Cancel = cancelSpy} end}

        QuestEventHandler.QuestRemoved(QUEST_ID)

        _G.GetNumQuestLogRewards = function() return 1 end
        _G.GetQuestLogRewardInfo = function() return nil, nil, nil, 0, nil, 5 end
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.CompleteQuest = spy.new(function() end)
        QuestieJourney.CompleteQuest = spy.new(function() end)
        QuestieAnnounce.CompletedQuest = spy.new(function() end)
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)

        QuestEventHandler.QuestTurnedIn(QUEST_ID, 1000, 2000)

        assert.spy(cancelSpy).was.called()
        assert.spy(QuestLogCache.RemoveQuest).was.called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestLifecycle.CompleteQuest).was.called_with(QuestLifecycle, QUEST_ID)
        assert.spy(QuestieJourney.CompleteQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.CompletedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
    end)

    it("should handle quest turn in of quests which are not in the quest log", function()
        _G.GetNumQuestLogRewards = function() return 1 end
        _G.GetQuestLogRewardInfo = function() return nil, nil, nil, 0, nil, 5 end
        QuestLogCache.RemoveQuest = spy.new(function() end)
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestLifecycle.CompleteQuest = spy.new(function() end)
        QuestieJourney.CompleteQuest = spy.new(function() end)
        QuestieAnnounce.CompletedQuest = spy.new(function() end)
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)

        QuestEventHandler.QuestTurnedIn(QUEST_ID, 1000, 2000)

        assert.spy(QuestLogCache.RemoveQuest).was.called_with(QUEST_ID)
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestLifecycle.CompleteQuest).was.called_with(QuestLifecycle, QUEST_ID)
        assert.spy(QuestieJourney.CompleteQuest).was.called_with(QuestieJourney, QUEST_ID)
        assert.spy(QuestieAnnounce.CompletedQuest).was.called_with(QuestieAnnounce, QUEST_ID)
    end)

    it("should do full quest log scan after QUEST_WATCH_UPDATE", function()
        _G.C_Timer = {After = function(_, callback) callback() end}
        QuestLogCache.CheckForChanges = spy.new(function() return false, {[QUEST_ID] = {}} end)
        QuestieAPI.PropagateQuestUpdate = spy.new(function() end)
        QuestiePlayer.currentQuestlog[QUEST_ID] = {}
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieNameplate.UpdateNameplate = spy.new(function() end)
        QuestieQuest.UpdateQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)
        QuestieTracker.UpdateQuestLines = spy.new(function() end)
        QuestieTracker.UpdateQuestLines = spy.new()

        QuestEventHandler.QuestWatchUpdate(QUEST_ID)
        QuestEventHandler.QuestLogUpdate()

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieAPI.PropagateQuestUpdate).was.called_with(QUEST_ID, {}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)
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

        QuestEventHandler.QuestAutoComplete(QUEST_ID)

        assert.spy(WatchFrameHook.Hide).was.called()
        assert.spy(AutoCompleteFrame.ShowAutoComplete).was.called_with(QUEST_ID)
    end)

    it("should update all quests on PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function()
        _G.C_Timer = {After = function(_, callback) callback() end}
        QuestLogCache.CheckForChanges = spy.new(function() return false, {[QUEST_ID] = {}} end)
        QuestiePlayer.currentQuestlog[QUEST_ID] = {}
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieNameplate.UpdateNameplate = spy.new(function() end)
        QuestieQuest.UpdateQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)
        QuestieTracker.UpdateQuestLines = spy.new(function() end)
        local bankframeClosedEvent = 8

        QuestEventHandler.PlayerInteractionManagerFrameHide(bankframeClosedEvent)

        assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
        assert.spy(QuestieQuest.SetObjectivesDirty).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieNameplate.UpdateNameplate).was.called()
        assert.spy(QuestieQuest.UpdateQuest).was.called_with(QuestieQuest, QUEST_ID)
        assert.spy(QuestieTracker.UpdateQuestLines).was.called_with(QUEST_ID)
        assert.spy(QuestieTracker.Update).was.called()
    end)

    describe("quest cache recovery integration", function()
        local OTHER_QUEST_ID = 456
        local savedGlobals, savedRegistration, callbacks, timers, now, questObjectives, unavailable, Sounds
        local globalNames = {"HaveQuestData", "GetQuestLogTitle", "C_QuestLog", "ERR_QUEST_ACCEPTED_S", "ERR_QUEST_COMPLETE_S",
            "QUEST_ITEMS_NEEDED", "QUEST_MONSTERS_KILLED"}

        ---Schedule callbacks rather than running them inline, including cancellation of recovery timers.
        ---@param delay number
        ---@param callback function
        ---@param isRetry boolean
        ---@return table timer
        local function _ScheduleTimer(delay, callback, isRetry)
            local timer = {deadline = now + delay, callback = callback, isRetry = isRetry, cancelled = false}
            timer.Cancel = function() timer.cancelled = true end
            timers[#timers + 1] = timer
            return timer
        end

        ---Deliver due callbacks in deadline order, including callbacks scheduled by a retry.
        ---@param seconds number
        ---@return nil
        local function _AdvanceTime(seconds)
            local target = now + seconds
            while true do
                local nextTimer
                for _, timer in ipairs(timers) do
                    if not timer.cancelled and timer.deadline <= target
                        and (not nextTimer or timer.deadline < nextTimer.deadline) then
                        nextTimer = timer
                    end
                end
                if not nextTimer then break end
                now = nextTimer.deadline
                nextTimer.cancelled = true
                nextTimer.callback()
            end
            now = target
        end

        ---@return number
        local function _PendingRetries()
            local count = 0
            for _, timer in ipairs(timers) do
                if timer.isRetry and not timer.cancelled then count = count + 1 end
            end
            return count
        end

        ---Mirror QuestieInit's initial cache fill and registration of existing quests.
        ---@return nil
        local function _InitializeQuestLog()
            local cacheMiss, _, checked = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            QuestEventHandler.InitQuestLogStates(checked)
            callbacks.QUEST_LOG_UPDATE("QUEST_LOG_UPDATE")
            assert.are.equal(0, _PendingRetries())
        end

        before_each(function()
            savedGlobals = {}
            for _, name in ipairs(globalNames) do savedGlobals[name] = _G[name] end
            savedRegistration = {Questie.RegisterEvent, Questie.RegisterBucketEvent}
            callbacks, timers, now, unavailable = {}, {}, 100, {}
            Questie.RegisterEvent = function(_, event, callback) callbacks[event] = callback end
            Questie.RegisterBucketEvent = function() end
            _G.ERR_QUEST_ACCEPTED_S = "Quest accepted: %s"
            _G.ERR_QUEST_COMPLETE_S = "Quest completed: %s"
            _G.GetTime = function() return now end
            _G.C_Timer = {
                NewTimer = function(delay, callback) return _ScheduleTimer(delay, callback, true) end,
                After = function(delay, callback) _ScheduleTimer(delay, callback, false) end,
            }
            _G.HaveQuestData = function(questId) return not unavailable[questId] end
            local titles = {
                {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
                {"Collect Other Items", 60, nil, false, false, nil, nil, OTHER_QUEST_ID},
            }
            _G.GetQuestLogTitle = function(index)
                if titles[index] then return unpack(titles[index]) end
            end
            questObjectives = {
                [QUEST_ID] = {
                    {text = "Item: 5/10", type = "item", numFulfilled = 5, numRequired = 10, finished = false},
                    {text = "Second Item: 2/10", type = "item", numFulfilled = 2, numRequired = 10, finished = false},
                },
                [OTHER_QUEST_ID] = {
                    {text = "Other Item: 2/10", type = "item", numFulfilled = 2, numRequired = 10, finished = false},
                },
            }
            _G.C_QuestLog = {GetQuestObjectives = function(questId) return questObjectives[questId] end}

            -- Keep objective parsing real; database name repair and rendering are outside this seam.
            local repairMissingItemNames = QuestieLib.RepairMissingItemNames
            dofile("Modules/Libs/QuestieLib.lua")
            QuestieLib.RepairMissingItemNames = repairMissingItemNames
            Sounds = QuestieLoader:ImportModule("Sounds")
            Sounds.PlayObjectiveProgress = spy.new(function() end)
            Sounds.PlayObjectiveComplete = spy.new(function() end)
            Sounds.PlayQuestComplete = spy.new(function() end)
            dofile("Modules/Quest/QuestLogCache.lua")
            dofile("Modules/EventHandler/QuestEventHandler.lua")
            QuestieQuest.SetObjectivesDirty = spy.new(function() end)
            QuestieQuest.UpdateQuest = spy.new(function() end)
            QuestieNameplate.UpdateNameplate = spy.new(function() end)
            QuestieTracker.UpdateQuestLines = spy.new(function() end)
            QuestiePlayer.currentQuestlog = {[QUEST_ID] = {}, [OTHER_QUEST_ID] = {}}
            QuestieLoader:ImportModule("QuestgiverFrame").RecheckGreeting = function() end
            QuestieLoader:ImportModule("QuestgiverFrame").RecheckGossip = function() end
            dofile("Modules/EventHandler/EventHandler.lua")
            QuestieLoader:ImportModule("EventHandler"):RegisterLateEvents()
        end)

        after_each(function()
            for _, name in ipairs(globalNames) do _G[name] = savedGlobals[name] end
            Questie.RegisterEvent, Questie.RegisterBucketEvent = unpack(savedRegistration)
        end)

        it("publishes banked item decreases while another quest still needs recovery", function()
            _InitializeQuestLog()
            callbacks.LOADING_SCREEN_ENABLED("LOADING_SCREEN_ENABLED")
            unavailable[OTHER_QUEST_ID] = true
            callbacks.UNIT_QUEST_LOG_CHANGED("UNIT_QUEST_LOG_CHANGED", "player")
            callbacks.QUEST_LOG_UPDATE("QUEST_LOG_UPDATE")
            assert.are.equal(1, _PendingRetries())

            _AdvanceTime(1)
            questObjectives[QUEST_ID][1].text = "Item: 4/10"
            questObjectives[QUEST_ID][1].numFulfilled = 4
            callbacks.PLAYER_INTERACTION_MANAGER_FRAME_HIDE("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", 8)

            assert.are.equal(4, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
            assert.spy(QuestieTracker.UpdateQuestLines).was.called_with(QUEST_ID)
            assert.spy(QuestieAPI.PropagateQuestUpdate).was.called_with(
                QUEST_ID, {1}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)
            assert.are.equal(1, _PendingRetries())

            -- A retry must retain B's recovery without publishing A's decrease again.
            _AdvanceTime(20)
            assert.are.equal(1, _PendingRetries())
            unavailable[OTHER_QUEST_ID] = nil
            _AdvanceTime(20)
            assert.are.equal(0, _PendingRetries())
            _AdvanceTime(20)
            assert.are.equal(0, _PendingRetries())
            assert.spy(QuestieAPI.PropagateQuestUpdate).was.called(1)
            assert.spy(QuestieTracker.UpdateQuestLines).was.called(1)
            assert.spy(QuestieQuest.UpdateQuest).was.called_with(QuestieQuest, QUEST_ID)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        local clientCases = {
            {name = "Classic item", itemFormat = "%s: %d/%d", monsterFormat = "%s slain: %d/%d",
                firstFormat = "item: %d/8", secondFormat = "Other Item: %d/8", type = "item", missing = " : 0/8"},
            {name = "Forever item", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                firstFormat = "%d/8 item", secondFormat = "%d/8 Other Item", type = "item", missing = "0/8  "},
            {name = "Forever monster", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                firstFormat = "%d/8 item", secondFormat = "%d/8 Wolf slain", type = "monster", missing = "0/8   slain"},
        }
        for _, case in ipairs(clientCases) do
            it("retries a missing " .. case.name .. " name before allowing a later banked item decrease", function()
                _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED = case.itemFormat, case.monsterFormat
                local repairMissingItemNames = QuestieLib.RepairMissingItemNames
                dofile("Modules/Libs/QuestieLib.lua")
                QuestieLib.RepairMissingItemNames = repairMissingItemNames
                local validObjectives = {
                    {text = string.format(case.firstFormat, 5), type = "item", numFulfilled = 5, numRequired = 8, finished = false},
                    {text = string.format(case.secondFormat, 2), type = case.type, numFulfilled = 2, numRequired = 8, finished = false},
                }
                questObjectives[QUEST_ID] = validObjectives
                questObjectives[OTHER_QUEST_ID] = {
                    {text = string.format(case.firstFormat, 2), type = "item", numFulfilled = 2, numRequired = 8, finished = false},
                }
                _InitializeQuestLog()
                callbacks.LOADING_SCREEN_ENABLED("LOADING_SCREEN_ENABLED")
                questObjectives[QUEST_ID] = {
                    validObjectives[1],
                    -- Missing entity names are one space; keep the literal client response intact.
                    {text = case.missing, type = case.type, numFulfilled = 0, numRequired = 8, finished = false},
                }
                callbacks.UNIT_QUEST_LOG_CHANGED("UNIT_QUEST_LOG_CHANGED", "player")
                callbacks.QUEST_LOG_UPDATE("QUEST_LOG_UPDATE")
                assert.are.equal(1, _PendingRetries())

                questObjectives[QUEST_ID] = {
                    {text = string.format(case.firstFormat, 0), type = "item", numFulfilled = 0, numRequired = 8, finished = false},
                    {text = string.format(case.secondFormat, 0), type = case.type, numFulfilled = 0, numRequired = 8, finished = false},
                }
                _AdvanceTime(20)
                local cached = QuestLogCache.GetQuest(QUEST_ID)
                assert.are.equal(5, cached.objectives[1].numFulfilled)
                assert.are.equal(2, cached.objectives[2].numFulfilled)
                assert.are.equal(1, _PendingRetries())
                assert.spy(QuestieAPI.PropagateQuestUpdate).was.not_called()
                assert.spy(QuestieTracker.UpdateQuestLines).was.not_called()

                questObjectives[QUEST_ID] = validObjectives
                _AdvanceTime(20)
                assert.are.equal(0, _PendingRetries())
                assert.spy(QuestieAPI.PropagateQuestUpdate).was.not_called()
                assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
                assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
                assert.spy(Sounds.PlayQuestComplete).was.not_called()

                questObjectives[QUEST_ID][1].text = string.format(case.firstFormat, 4)
                questObjectives[QUEST_ID][1].numFulfilled = 4
                callbacks.PLAYER_INTERACTION_MANAGER_FRAME_HIDE("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", 8)
                assert.are.equal(4, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
                assert.spy(QuestieAPI.PropagateQuestUpdate).was.called_with(
                    QUEST_ID, {1}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)
                assert.spy(QuestieAPI.PropagateQuestUpdate).was.called(1)
                assert.spy(QuestieTracker.UpdateQuestLines).was.called_with(QUEST_ID)
                assert.are.equal(0, _PendingRetries())
            end)
        end
    end)

    describe("pending objective loading", function()
        local callbacks, now, indexMock

        before_each(function()
            callbacks, now = {}, 100
            _G.GetTime = function() return now end
            _G.C_Timer = {
                After = function(_, callback) callbacks[#callbacks + 1] = callback end,
                NewTicker = function() return {Cancel = function() end} end,
                NewTimer = newTimerMock,
            }
            indexMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetQuestLogIndexByID", function() return 2 end)
            QuestLogCache.CheckForChanges = spy.new(function() return true, {} end)
            QuestLifecycle.AcceptQuest = spy.new(function() end)
            QuestieJourney.AcceptQuest = spy.new(function() end)
            QuestieAnnounce.AcceptedQuest = spy.new(function() end)
            QuestieQuest.SetObjectivesDirty = spy.new(function() end)
            QuestieQuest.UpdateQuest = spy.new(function() end)
            QuestieNameplate.UpdateNameplate = spy.new(function() end)
            QuestieTracker.UpdateQuestLines = spy.new(function() end)
            QuestieTracker.Update = spy.new(function() end)
        end)

        after_each(function()
            indexMock:revert()
        end)

        it("finishes a pending accept when the fallback fires without another event", function()
            QuestEventHandler.QuestAccepted(2, QUEST_ID)
            callbacks[1]()
            assert.spy(QuestLifecycle.AcceptQuest).was.not_called()
            assert.is_false(QuestEventHandler.IsQuestAccepted(QUEST_ID))

            assert.are.equal(1, #retryTimers)
            assert.are.equal(20, retryTimers[1].delay)
            now = 130
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
            retryTimers[1].callback()
            callbacks[1]() -- The earlier acceptance callback cannot accept it twice.

            assert.spy(QuestLifecycle.AcceptQuest).was.called(1)
            assert.spy(QuestieJourney.AcceptQuest).was.called(1)
            assert.spy(QuestieAnnounce.AcceptedQuest).was.called(1)
            assert.is_true(QuestEventHandler.IsQuestAccepted(QUEST_ID))
        end)

        it("retries a cache miss through the normal notification and tracker update path", function()
            QuestEventHandler.QuestLogUpdate()
            assert.spy(retryTimers[1].Cancel).was.called(1)
            assert.are.equal(2, #retryTimers)
            QuestiePlayer.currentQuestlog[QUEST_ID] = {}
            QuestLogCache.CheckForChanges = spy.new(function() return false, {[QUEST_ID] = {1}} end)
            now = 130

            retryTimers[2].callback()

            assert.spy(QuestLogCache.CheckForChanges).was.called_with({[QUEST_ID] = true})
            assert.spy(QuestieTracker.UpdateQuestLines).was.called_with(QUEST_ID)
            assert.spy(QuestieAPI.PropagateQuestUpdate).was.called_with(
                QUEST_ID, {1}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)
            assert.are.equal(2, #retryTimers) -- Success leaves no retry scheduled.
        end)

        it("cancels the fallback when a natural event completes the scan", function()
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)

            QuestEventHandler.QuestLogUpdate()

            assert.spy(retryTimers[1].Cancel).was.called(1)
            assert.are.equal(1, #retryTimers)
        end)

        it("keeps a fallback for a pending accept even when the accepted-quest scan succeeds", function()
            QuestLogCache.CheckForChanges = spy.new(function(ids) return ids[QUEST_ID] == true, {} end)
            QuestEventHandler.QuestAccepted(2, QUEST_ID)
            callbacks[1]()
            assert.are.equal(1, #retryTimers)

            now = 130
            retryTimers[1].callback()

            assert.spy(QuestLifecycle.AcceptQuest).was.not_called()
            assert.spy(QuestLogCache.CheckForChanges).was.called_with({})
            assert.are.equal(2, #retryTimers)
            assert.are.equal(20, retryTimers[2].delay)

            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
            now = 160
            retryTimers[2].callback()
            assert.spy(QuestLifecycle.AcceptQuest).was.called(1)
            assert.are.equal(2, #retryTimers)
        end)

        it("does not cancel the fallback when an event skips the scan", function()
            QuestEventHandler.QuestWatchUpdate(QUEST_ID)
            now = 130
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)

            QuestEventHandler.QuestLogUpdate()

            assert.spy(QuestLogCache.CheckForChanges).was.not_called()
            assert.spy(retryTimers[1].Cancel).was.not_called()
            retryTimers[1].callback()
            assert.spy(QuestLogCache.CheckForChanges).was.called(1)
            assert.are.equal(1, #retryTimers)
        end)

        it("ignores the delayed read after an event already completed acceptance", function()
            QuestEventHandler.QuestAccepted(2, QUEST_ID)
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
            QuestEventHandler.QuestLogUpdate()
            callbacks[1]()

            assert.spy(QuestLifecycle.AcceptQuest).was.called(1)
            assert.spy(QuestieJourney.AcceptQuest).was.called(1)
        end)

        it("does not resurrect an abandoned pending quest", function()
            QuestEventHandler.QuestAccepted(2, QUEST_ID)
            QuestEventHandler.QuestRemoved(QUEST_ID)
            indexMock.returns(0)
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
            callbacks[1]()
            now = 130
            retryTimers[1].callback()

            assert.are.equal(1, #retryTimers)
            assert.spy(QuestLifecycle.AcceptQuest).was.not_called()
            assert.spy(QuestieJourney.AcceptQuest).was.not_called()
            assert.are.equal("QUEST_REMOVED", QuestEventHandler.GetQuestLogStates()[QUEST_ID].state)
        end)

        it("refreshes tracker membership even outside the objective-scan marker window", function()
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
            QuestEventHandler.QuestLogUpdate() -- Finish the initial cache retry before letting the marker expire.
            QuestLogCache.CheckForChanges:clear()
            QuestieTracker.Update:clear()
            now = 130

            QuestEventHandler.QuestLogUpdate()

            assert.spy(QuestLogCache.CheckForChanges).was.not_called()
            assert.spy(QuestieTracker.Update).was.called(1)
        end)

        it("keeps one tracker update queued while the combat queue is paused", function()
            local queued = {}
            QuestieCombatQueue.Queue = function(_, callback) queued[#queued + 1] = callback end
            QuestLogCache.CheckForChanges = spy.new(function() return false, {} end)
            QuestieTracker.Update:clear()

            QuestEventHandler.QuestLogUpdate()
            QuestEventHandler.QuestLogUpdate()
            QuestEventHandler.QuestAccepted(2, QUEST_ID + 1)

            assert.are.equal(1, #queued)
            queued[1]()
            assert.spy(QuestieTracker.Update).was.called(1)

            QuestEventHandler.QuestLogUpdate()
            assert.are.equal(2, #queued)
        end)
    end)

end)