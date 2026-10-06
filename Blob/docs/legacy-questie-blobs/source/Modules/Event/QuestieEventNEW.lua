--- GLOBAL ---
---@class QuestieEventNEW
local QuestieEventNEW = QuestieLoader:CreateModule("QuestieEventNEW")

print("QUESITEEVENTNEW")
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieHash
local QuestieHash = QuestieLoader:ImportModule("QuestieHash")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")
---@type Cleanup
local QuestieCleanup = QuestieLoader:ImportModule("Cleanup")
---@type DBCompiler
local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

---@type QuestiePolygon
local QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")
---@type MessageHandler
local MessageHandler = QuestieLoader:ImportModule("MessageHandler")

---@type QuestieCompare
local QuestieCompare = QuestieLoader:ImportModule("QuestieCompare");

---@type QuestieProfiler
local QuestieProfiler = QuestieLoader:ImportModule("Profiler")

--- LOCAL ---
--False -> true -> nil
local didPlayerEnterWorld = false
local hasFirstQLU = false
local shouldRunQLU = false

-- forward declaration
local _PLAYER_LOGIN, _PLAYER_LEVEL_UP, _PLAYER_REGEN_DISABLED, _PLAYER_REGEN_ENABLED
local _QUEST_ACCEPTED, _QUEST_TURNED_IN, _UNIT_QUEST_LOG_CHANGED, _QUEST_REMOVED, _QUEST_LOG_UPDATE, _QUEST_FINISHED
local _MAP_EXPLORATION_UPDATED, _MODIFIER_STATE_CHANGED, _CHAT_MSG_SKILL, _CHAT_MSG_COMBAT_FACTION_CHANGE
local _GROUP_ROSTER_UPDATE, _GROUP_JOINED, _GROUP_LEFT
local _CompleteQuest

_QuestEvent = {}

local function pre_fetch()
    local numEntries, _ = GetNumQuestLogEntries();
    if(numEntries ~= 0) then
        local timer
        timer = C_Timer.NewTicker(0.1, function()
            local AllCorrect = true;
            local count = 0
            for _, _ in pairs(QuestiePlayer.currentQuestlog or {}) do
                count = count + 1
            end
            if(QuestiePlayer.currentQuestlog == nil or count == 0) then
                QuestieQuest:GetOnlyQuestIds()
            else
                for questId, _ in pairs(QuestiePlayer.currentQuestlog) do
                    local correct = QuestieLib:IsResponseCorrect(questId)
                    if(not correct) then
                        print("QID:", questId, "C:", correct)
                        AllCorrect = false
                    end
                end
                if(AllCorrect) then
                    print("All objectives correct!")
                    timer:Cancel()
                    MessageHandler.callback:Fire(MessageHandler.events.BOOT.START)
                else
                    print("Some objectives where not correct, retrying!")
                end
            end
        end)
    else
        print("No quests, no need to pre_fetch")
        MessageHandler.callback:Fire(MessageHandler.events.BOOT.START)
    end
end

--- This function registeres all required ingame events to the global "Questie"
function QuestieEventNEW:RegisterAllEvents()
    -- Putting it here reduces the size of the QuestieEventHandler, since all the regular
    -- event handlers can be local

    -- Player Events
    Questie:RegisterEvent("PLAYER_LOGIN", _QuestEvent.PLAYER_LOGIN)

    -- since icon updates are disabled in instances, we need to reset on P_E_W
    --Questie:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    --    if Questie.started then
    --        QuestieMap:InitializeQueue()
    --        if not IsInInstance() then
    --            QuestieQuest:SmoothReset()
    --        end
    --    end
    --end)
    --QuestieCompare:Initialize();
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.INITIALIZED, QuestieCompare.Initialize)
    ---@type QLAvailable
    --local Available = QuestieLoader:ImportModule("QLAvailable")
    --Available:Initialize()
    --Questie:RegisterMessage("PRE_COMPILE_DONE", _QuestieComms.BroadcastQuestUpdate);
    --Questie:RegisterMessage("COMPILE_DONE", _QuestieComms.BroadcastQuestRemove);

    if QuestieLib:GetAddonVersionString() ~= QuestieConfig.dbCompiledOnVersion or (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale()) ~= QuestieConfig.dbCompiledLang then
        QuestieConfig.dbIsCompiled = nil -- we need to recompile
    end
    --QuestieConfig.dbIsCompiled = nil
    --MessageHandler.RegisterOnceCallback(MessageHandler.events.PROFILER.SHOW, pre_fetch) If you ever want to run the profiler first.
    MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.PRE, pre_fetch)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, function() Questie.minimapConfigIcon:Show("Questie") end)

    if QuestieConfig.dbIsCompiled then
        if not Questie.db.char.townsfolk then
            -- we havent compiled townsfolk on this character
            MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieCorrections.Initialize);
            MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieCorrections.PopulateTownsfolk);
        else
            MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieCorrections.MinimalInit);
        end
        MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieDB.Initialize);
    else
        -- reset townsfolk on all characters before compile
        for _, char in pairs(QuestieConfig.char) do
            char.townsfolk = nil
        end
        MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieCorrections.Initialize);
        MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieCorrections.PopulateTownsfolk);
        MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieLocale.Initialize);
        MessageHandler.RegisterOnceCallback(MessageHandler.events.BOOT.START, QuestieDB.private.DeleteGatheringNodes);
        MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.CORRECTIONS_INITIALIZED, function()
            print(QuestieLocale:GetUIString("\124cFFAAEEFFQuestie DB has updated!\124r\124cFFFF6F22 Data is being processed, this may take a few moments and cause some lag..."))
            QuestieCorrections:PreCompile()
        end);

        MessageHandler.RegisterOnceCallback(MessageHandler.events.COMPILER.PRE_COMPILE_DONE, QuestieDBCompiler.Compile);

        MessageHandler.RegisterOnceCallback(MessageHandler.events.COMPILER.DB_COMPILE_DONE, QuestieDB.Initialize);
    end

    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestieLocale.PostBoot);
    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestieLib.CacheAllItemNames);
    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestieCleanup.Run);
    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestiePlayer.Initialize)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestieJourney.Initialize)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestieQuest.Initialize)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.DB.DB_INITIALIZED, QuestieCorrections.PopulateTownsfolkPostBoot)

    --These need to happen in this order apperently!
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.INITIALIZED, QuestieQuest.GetAllQuestIdsNoObjectives)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.INITIALIZED, QuestieMenu.OnLogin)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.INITIALIZED, QuestiePolygon.Initialize)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.INITIALIZED, QuestieTracker.Initialize)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.TRACKER.INITIALIZED, function() QuestieCombatQueue:Queue(function() QuestieTracker:ResetLinesForChange() QuestieTracker:Update() end) end)

    if Questie.db.global.debugEnabled then
        MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.INITIALIZED, QuestieLoader.PopulateGlobals)
    end

    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.GET_ALL_QUEST_IDS_NO_OBJECTIVES, QuestieQuest.CalculateAndDrawAvailableQuestsIterative)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.AVAILABLE_QUESTS_DRAWN, QuestieQuest.GetAllQuestIds)

    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.GET_ALL_QUEST_IDS, QuestieMap.InitializeQueue)
    MessageHandler.RegisterOnceCallback(MessageHandler.events.QUEST.GET_ALL_QUEST_IDS, function()
        --Register stuff after everything is done!
        Questie:RegisterEvent("PLAYER_LEVEL_UP", _PLAYER_LEVEL_UP)
        Questie:RegisterEvent("PLAYER_REGEN_DISABLED", _PLAYER_REGEN_DISABLED)
        Questie:RegisterEvent("PLAYER_REGEN_ENABLED", _PLAYER_REGEN_ENABLED)
    
        -- Miscellaneous Events
        Questie:RegisterEvent("MAP_EXPLORATION_UPDATED", _MAP_EXPLORATION_UPDATED)
        Questie:RegisterEvent("MODIFIER_STATE_CHANGED", _MODIFIER_STATE_CHANGED)
        -- Events to update a players professions and reputations
        Questie:RegisterEvent("CHAT_MSG_SKILL", _CHAT_MSG_SKILL)
        Questie:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", _CHAT_MSG_COMBAT_FACTION_CHANGE)
    
        -- Quest Events
        Questie:RegisterEvent("QUEST_ACCEPTED", _QuestEvent.QUEST_ACCEPTED)
        Questie:RegisterEvent("UNIT_QUEST_LOG_CHANGED", _UNIT_QUEST_LOG_CHANGED)
        Questie:RegisterEvent("QUEST_TURNED_IN", _QUEST_TURNED_IN)
        Questie:RegisterEvent("QUEST_REMOVED", _QUEST_REMOVED)
        Questie:RegisterEvent("QUEST_ITEM_UPDATE", function() print("!!! IMPORTANT !!! QUEST_ITEM_UPDATE") end)
    
        -- Use bucket for QUEST_LOG_UPDATE to let information propagate through to the blizzard API
        -- Might be able to change this to 0.5 seconds instead, further testing needed.
        --Questie:RegisterBucketEvent("QUEST_LOG_UPDATE", 1, _QUEST_LOG_UPDATE)
        Questie:RegisterEvent("QUEST_LOG_UPDATE", _QUEST_LOG_UPDATE)
    
        -- Party join event for QuestieComms, Use bucket to hinder this from spamming (Ex someone using a raid invite addon etc)
        Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, _GROUP_ROSTER_UPDATE)
        Questie:RegisterEvent("GROUP_JOINED", _GROUP_JOINED) -- This is not local because QuestieComms needs to call it
        Questie:RegisterEvent("GROUP_LEFT", _GROUP_LEFT)
    
        Questie:RegisterEvent("QUEST_WATCH_UPDATE", _QuestEvent.QUEST_WATCH_UPDATE)
    
        -- Nameplate / Target Frame Objective Events
        Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated)
        Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed)
        Questie:RegisterEvent("PLAYER_TARGET_CHANGED", QuestieNameplate.DrawTargetFrame)
    
        -- dropdown fix
        Questie:RegisterEvent("CURSOR_UPDATE", function() pcall(LQuestie_CloseDropDownMenus) end)
    
        -- quest announce
        Questie:RegisterEvent("CHAT_MSG_LOOT", QuestieAnnounce.ItemLooted)

        _GROUP_JOINED()
        Questie.minimapConfigIcon:Show("Questie")
        Questie.started = true
        print(time())
    end)

    --QuestieMessage:RegisterMessage(MessageHandler.events.BOOT.DONE, QuestieQuest.GetAllQuestIds)
    --QuestieQuest:GetAllQuestIdsNoObjectives()
    --QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    --QuestieNameplate:Initialize()

end

function _QuestEvent:PLAYER_LOGIN()

    print(time())
    MessageHandler.callback:Fire(MessageHandler.events.BOOT.PRE)

end


function _QuestEvent:CHAT_MSG_LOOT(...)--message, arg2, arg3, arg4, sender)
    print("CHAT_MSG_LOOT")
    local text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons = ...
    --local text, playerName, languageName, channelName = unpack({...})
    --print(select(2, ...))
    print("t", text) --text 
    print("Pn", playerName2)
    --print(select(2, ...)) --playerName 
    --print(select(4, ...)) --channelName 
    local id, context = GetItemInfoFromHyperlink(text)
    print(id, context)
    local itemName, _, _, _, _, itemType = GetItemInfo(id)
   print(itemName, itemType)

end

--Fires when a quest is accepted in anyway.
--Classic returns QuestLogIndex, QuestID --TBC returns only QuestId
function _QuestEvent:QUEST_ACCEPTED(questLogIndex, questId)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_ACCEPTED", "QLogIndex: "..questLogIndex,  "QuestId: "..questId)
    print("Quest accepted")
    
    --If the questId is nil that means we are in the TBC client.
    if(not questId) then
        questId = questLogIndex
        questLogIndex = C_QuestLog.GetLogIndexForQuestID(questId)
    end
    
    --Try and cache all the potential items required for the quest.
    QuestieLib:CacheItemNames(questId)
    --Unregister the full check, because we know it was because this event
    MessageHandler.UnregisterCallback(QuestieEventNEW, MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE)

    MessageHandler.callback:Fire(MessageHandler.events.BLIZZARD.QUEST_ACCEPTED, questLogIndex, questId)

end

_QuestEvent.questUpdates = {}
function _QuestEvent:QUEST_WATCH_UPDATE(questLogIndex)
    --print("Quest_Watch_Update", questLogIndex)
    --local updateObject = questLogIndex

    --If we already have a registered questUpdate there is no need to do it again!
    if(not _QuestEvent.questUpdates[questLogIndex]) then
        _QuestEvent.questUpdates[questLogIndex] = {}
        MessageHandler.RegisterCallback(_QuestEvent.questUpdates[questLogIndex], MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE,
        function()
            QuestieCompare:LoadQuestIndex(questLogIndex)

            MessageHandler.UnregisterCallback(_QuestEvent.questUpdates[questLogIndex], MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE)
            _QuestEvent.questUpdates[questLogIndex] = nil
        end)
    end
end

--- Fires on MAP_EXPLORATION_UPDATED.
_MAP_EXPLORATION_UPDATED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] MAP_EXPLORATION_UPDATED")
    if Questie.db.char.hideUnexploredMapIcons then
        QuestieMap.utils:MapExplorationUpdate()
    end
end

-- Needed to distinguish finished quests from abandoned quests
local questTurnedInEventReveived = false

--- Fires when a quest is removed from the questlog, this includes turning it in
--- and abandoning it.
---@param questId QuestId
_QUEST_REMOVED = function(self, questId)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_REMOVED", questId)

    --Unregister the full check, because we know it was because this event
    MessageHandler.UnregisterCallback(QuestieEventNEW, MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE)

    MessageHandler.callback:Fire(MessageHandler.events.BLIZZARD.QUEST_REMOVED, questId)
    --Comms
    Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questId)
end


--- Fires when a quest is turned in, but before it is remove from the quest log.
--- We need to save the ID of the finished quest to check it in QR event.
---@param questId QuestId
---@param xpReward number
---@param moneyReward number
_QUEST_TURNED_IN = function(self, questId, xpReward, moneyReward)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_TURNED_IN", questId, xpReward, moneyReward)
    MessageHandler.callback:Fire(MessageHandler.events.BLIZZARD.QUEST_TURNED_IN, questId)
    --Comms
    Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questId)
end

--- Fires when the quest log changes. That includes visual changes and
--- client/server communication, so not every event really updates the log data.
_QUEST_LOG_UPDATE = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_LOG_UPDATE")

    --print("QUEST_LOG_UPDATE")
    MessageHandler.callback:Fire(MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE)
    QuestieNameplate:UpdateNameplate()
end


--- Helper function to remove quests correctly
---@param questId QuestId
---@param count number @The amount of calls already made in recursion
_CompleteQuest = function(questId, count)
    if(not count) then
        count = 1
    end
    ---@type Quest
    local quest = QuestieDB:GetQuest(questId)
    if not quest then
        return
    end
    if(IsQuestFlaggedCompleted(questId) or quest.IsRepeatable or count > 50) then
        QuestieQuest:CompleteQuest(quest)
        QuestieJourney:CompleteQuest(questId)
        print("sending complete message");
        --MessageHandler.callback:Fire(QuestieMessage.MESSAGES.QUEST.COMPLETE, questId)
        MessageHandler.callback:Fire(MessageHandler.events.QUEST.COMPLETE, questId)
    else
        Questie:Debug(DEBUG_INFO, "[QuestieEventHandler]", questId, ":Quest not complete starting timer! IsQuestFlaggedCompleted", IsQuestFlaggedCompleted(questId), "Repeatable:", quest.IsRepeatable, "Count:", count)
        C_Timer.After(0.1, function()
            _CompleteQuest(questId, count + 1)
        end)
    end
end

--- Fired before data for quest log changes, including other players.
---@param unitTarget string @The unitTarget, e.g. "player"
_UNIT_QUEST_LOG_CHANGED = function(self, unitTarget)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] UNIT_QUEST_LOG_CHANGED")
    -- If the unitTarget is "player" the changed log is from "our" player and
    -- we need to tell the next QLU event to check the quest log for updated
    -- data.
    if unitTarget == "player" then
        Questie:Debug(DEBUG_DEVELOP, "UNIT_QUEST_LOG_CHANGED: player")

        --print("UNIT_QUEST_LOG_CHANGED")
        --If no quest update is registered we do a generic one, this can be cancelled by Accept and Remove quest
        if(next(_QuestEvent.questUpdates) == nil) then
            MessageHandler.RegisterCallback(QuestieEventNEW, MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE,
            function()
                QuestieCompare:LoadQuestLog()
                MessageHandler.UnregisterCallback(QuestieEventNEW, MessageHandler.events.BLIZZARD.QUEST_LOG_UPDATE)
            end)
        end
    end
end

--- Fires when the player levels up
---@param level number
----@param hitpoints number
----@param manapoints number
----@param talentpoints number
_PLAYER_LEVEL_UP = function(self, level)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_LEVEL_UP", level)

    QuestiePlayer:SetPlayerLevel(level)

    -- deferred update (possible desync fix?)
    C_Timer.After(3, function()
        QuestiePlayer:SetPlayerLevel(level)

        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    end)
    QuestieJourney:PlayerLevelUp(level)
end

--- Fires when a modifier key changed
_MODIFIER_STATE_CHANGED = function()
    if GameTooltip and GameTooltip:IsShown() and GameTooltip._Rebuild then
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR")
        GameTooltip:_Rebuild() -- rebuild the tooltip
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end
    if Questie.db.global.trackerLocked then
        if QuestieTracker.private.baseFrame ~= nil then
            QuestieCombatQueue:Queue(function()
                QuestieTracker.private.baseFrame:Update()
            end)
        end
    end
end

--- Fires when some chat messages about skills are displayed
_CHAT_MSG_SKILL = function()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_SKILL")
    local isProfUpdate = QuestieProfessions:Update()
    -- This needs to be done to draw new quests that just came available
    if isProfUpdate then
        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    end
end

--- Fires when some chat messages about reputations are displayed
_CHAT_MSG_COMBAT_FACTION_CHANGE = function()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_COMBAT_FACTION_CHANGE")
    local factionChanged = QuestieReputation:Update(false)
    if factionChanged then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)
        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    end
end

local numberOfGroupMembers = -1
_GROUP_ROSTER_UPDATE = function()
    local currentMembers = GetNumGroupMembers()
    -- Only want to do logic when number increases, not decreases.
    if numberOfGroupMembers < currentMembers then
        -- Tell comms to send information to members.
        numberOfGroupMembers = currentMembers
    else
        -- We do however always want the local to be the current number to allow up and down.
        numberOfGroupMembers = currentMembers
    end
end

_GROUP_JOINED = function()
    Questie:Debug(DEBUG_DEVELOP, "GROUP_JOINED")
    local checkTimer
    --We want this to be fairly quick.
    checkTimer = C_Timer.NewTicker(0.1, function()
        local partyPending = UnitInParty("player")
        local isInParty = UnitInParty("party1")
        local isInRaid = UnitInRaid("raid1")
        if partyPending then
            if (isInParty or isInRaid) then
                Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "Player joined party/raid, ask for questlogs")
                --Request other players log.
                Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
                checkTimer:Cancel()
            end
        else
            Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "Player no longer in a party or pending invite. Cancel timer")
            checkTimer:Cancel()
        end
    end)
end

_GROUP_LEFT = function()
    --Resets both QuestieComms.remoteQuestLog and QuestieComms.data
    QuestieComms:ResetAll()
end

local previousTrackerState

_PLAYER_REGEN_DISABLED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_DISABLED")
    if Questie.db.global.hideTrackerInCombat then
        previousTrackerState = Questie.db.char.isTrackerExpanded
        QuestieTracker:Collapse()
    end
    if InCombatLockdown() then
        if QuestieConfigFrame:IsShown() then
            QuestieOptions:HideFrame()
        end
    end
end

_PLAYER_REGEN_ENABLED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_ENABLED")
    if Questie.db.global.hideTrackerInCombat and (previousTrackerState == true) then
        QuestieTracker:Expand()
    end
end

local function _AllQuestWindowsClosed()
    if GossipFrame and (not GossipFrame:IsVisible())
        and GossipFrameGreetingPanel and (not GossipFrameGreetingPanel:IsVisible())
        and QuestFrameGreetingPanel and (not QuestFrameGreetingPanel:IsVisible())
        and QuestFrameDetailPanel and (not QuestFrameDetailPanel:IsVisible())
        and QuestFrameProgressPanel and (not QuestFrameProgressPanel:IsVisible())
        and QuestFrameRewardPanel and (not QuestFrameRewardPanel:IsVisible()) then
        return true
    end
    return false
end

_QUEST_FINISHED = function()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_FINISHED")

    C_Timer.After(0.5, function()
        if _AllQuestWindowsClosed() then
            Questie:Debug(DEBUG_DEVELOP, "All quest windows closed! Resetting shouldRunAuto")
            QuestieAuto:ResetModifier()
        end
    end)

    -- Quests which are just turned in don't trigger QLU.
    -- So shouldRunQLU is still active from QUEST_TURNED_IN
    if shouldRunQLU then
        Questie:Debug(DEBUG_DEVELOP, "shouldRunQLU still active")
        if questTurnedInEventReveived then
            Questie:Debug(DEBUG_DEVELOP, "finishedEventReceived is questId")
            local quest = QuestieDB:GetQuest(questTurnedInEventReveived)
            Questie:Debug(DEBUG_DEVELOP, "Completing automatic completion quest")
            QuestieQuest:CompleteQuest(quest)
        else
            Questie:Debug(DEBUG_DEVELOP, "finishedEventReceived is false. Something is off?")
        end
        shouldRunQLU = false
    end
end
