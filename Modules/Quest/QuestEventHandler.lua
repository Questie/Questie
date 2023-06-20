---@class QuestEventHandler
local QuestEventHandler = QuestieLoader:CreateModule("QuestEventHandler")
---@class QuestEventHandlerPrivate
local _QuestEventHandler = QuestEventHandler.private

local _QuestLogUpdateQueue = {} -- Helper module
local questLogUpdateQueue = {}  -- The actual queue

---@type QuestEventHandlerPrivate
QuestEventHandler.private = QuestEventHandler.private or {}
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local tableRemove = table.remove

local QUEST_LOG_STATES = {
    QUEST_ACCEPTED = "QUEST_ACCEPTED",
    QUEST_TURNED_IN = "QUEST_TURNED_IN",
    QUEST_REMOVED = "QUEST_REMOVED",
    QUEST_ABANDONED = "QUEST_ABANDONED"
}

local eventFrame = CreateFrame("Frame", "QuestieQuestEventFrame")
local questLog = {}
local questLogUpdateQueueSize = 1
local skipNextUQLCEvent = false
local doFullQuestLogScan = false
local deletedQuestItem = false

--- Registers all events that are required for questing (accepting, removing, objective updates, ...)
function QuestEventHandler:RegisterEvents()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] RegisterEvents")
    eventFrame:RegisterEvent("QUEST_ACCEPTED")
    eventFrame:RegisterEvent("QUEST_TURNED_IN")
    eventFrame:RegisterEvent("QUEST_REMOVED")
    eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    eventFrame:RegisterEvent("QUEST_WATCH_UPDATE")
    eventFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    if Questie.IsWotlk then
        -- Quest Related Frames - Wrath Only
        eventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
    else
        -- Quest Related Frames - Era Only
        eventFrame:RegisterEvent("TRADE_CLOSED")
        eventFrame:RegisterEvent("MERCHANT_CLOSED")
        eventFrame:RegisterEvent("BANKFRAME_CLOSED")
        eventFrame:RegisterEvent("MAIL_CLOSED")
    end

    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    eventFrame:SetScript("OnEvent", _QuestEventHandler.OnEvent)

    -- StaticPopup dialog hooks. Deleteing Quest items do not always trigger a Quest Log Update.
    hooksecurefunc("StaticPopup_Show", function(...)
        -- Hook StaticPopup_Show. If we find the "DELETE_ITEM" dialog, check for Quest Items and notify the player.
        local which, text_arg1 = ...
        if which == "DELETE_ITEM" then
            if deletedQuestItem == true then
                deletedQuestItem = false
            end

            for questLogIndex = 1, 75 do
                local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)

                if (not title) then
                    break
                end

                if (not isHeader) then
                    local quest = QuestieDB:GetQuest(questId)

                    if quest then
                        local foundQuestItem = false
                        local info = StaticPopupDialogs[which]
                        local itemId = quest.sourceItemId
                        local itemName, _, _, _, _, itemType, _, _, _, _, _, classID = GetItemInfo(itemId)

                        if itemId and (itemType == "Quest" or classID == 12 or QuestieDB.QueryItemSingle(itemId, "class") == 12) then
                            if text_arg1 == itemName then
                                foundQuestItem = true
                            end
                        else
                            for _, objective in pairs(quest.Objectives) do
                                if text_arg1 == objective.Description then
                                    foundQuestItem = true
                                end
                            end
                        end

                        if foundQuestItem then
                            local frame, text

                            for i = 1, STATICPOPUP_NUMDIALOGS do
                                frame = _G["StaticPopup" .. i]
                                if (frame:IsShown()) and frame.text.text_arg1 == text_arg1 then
                                    text = _G[frame:GetName() .. "Text"]
                                    break
                                end
                            end

                            if frame ~= nil and text ~= nil then
                                local updateText = l10n("Quest Item %%s might be needed for the quest %%s. \n\nAre you sure you want to delete this?")
                                text:SetFormattedText(updateText, text_arg1, quest.name)
                                text.text_arg1 = updateText

                                StaticPopup_Resize(frame, which)
                                deletedQuestItem = true

                                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] StaticPopup_Show: Quest Item Detected. Updating Static Popup.")
                            end
                        end
                    end
                end
            end
        end
    end)

    hooksecurefunc("DeleteCursorItem", function()
        -- Hook DeleteCursorItem so we know when the player clicks the Accept button
        if deletedQuestItem then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] DeleteCursorItem: Quest Item deleted. Update all quests.")

            _QuestEventHandler:UpdateAllQuests()
            deletedQuestItem = false
        end
    end)

    _QuestEventHandler:InitQuestLog()
end

--- On Login mark all quests in the quest log with QUEST_ACCEPTED state
function _QuestEventHandler:InitQuestLog()
    -- Fill the QuestLogCache for first time
    local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
    if cacheMiss then
        -- TODO actually can happen in rare edge case if player accepts new quest during questie init. *cough*
        -- or if someone managed to overflow game cache already at this point.
        Questie:Error("Did you accept a quest during InitQuestLog? Please report on Github or Discord. Game's quest log cache is not ok. This shouldn't happen. Questie may malfunction.")
    end

    for questId, _ in pairs(changes) do
        questLog[questId] = {
            state = QUEST_LOG_STATES.QUEST_ACCEPTED
        }
        QuestieLib:CacheItemNames(questId)
    end
end

--- Fires when a quest is accepted in anyway.
---@param questLogIndex number
---@param questId number
function _QuestEventHandler:QuestAccepted(questLogIndex, questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_ACCEPTED", questLogIndex, questId)

    if questLog[questId] and questLog[questId].timer then
        -- We had a QUEST_REMOVED event which started this timer and now it was accepted again.
        -- So the quest was abandoned before, because QUEST_TURNED_IN would have run before QUEST_ACCEPTED.
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
        QuestieCombatQueue:Queue(function()
            _QuestEventHandler:MarkQuestAsAbandoned(questId)
        end)
    end

    questLog[questId] = {}

    -- Timed quests do not need a full Quest Log Update.
    -- TODO: Add achievement timers later.
    local questTimers = GetQuestTimers(questId)
    if type(questTimers) == "number" then
        skipNextUQLCEvent = false
    else
        skipNextUQLCEvent = true
    end

    QuestieCombatQueue:Queue(function()
        QuestieLib:CacheItemNames(questId)
        _QuestEventHandler:HandleQuestAccepted(questId)
    end)

    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_ACCEPTED - skipNextUQLCEvent - ", skipNextUQLCEvent)
end

---@param questId number
---@return boolean true @if the function was successful, false otherwise
function _QuestEventHandler:HandleQuestAccepted(questId)
    -- We first check the quest objectives and retry in the next QLU event if they are not correct yet
    local cacheMiss, changes = QuestLogCache.CheckForChanges({ [questId] = true }) -- if cacheMiss, no need to check changes as only 1 questId
    if cacheMiss then
        Questie:Debug(Questie.DEBUG_INFO, "Objectives are not cached yet")
        _QuestLogUpdateQueue:Insert(function()
            return _QuestEventHandler:HandleQuestAccepted(questId)
        end)

        return false
    end

    Questie:Debug(Questie.DEBUG_INFO, "Objectives are correct. Calling accept logic. quest:", questId)
    questLog[questId].state = QUEST_LOG_STATES.QUEST_ACCEPTED
    QuestieQuest:SetObjectivesDirty(questId)

    QuestieJourney:AcceptQuest(questId)
    QuestieAnnounce:AcceptedQuest(questId)

    local isLastIslePhase = Questie.db.global.isleOfQuelDanasPhase == IsleOfQuelDanas.MAX_ISLE_OF_QUEL_DANAS_PHASES
    if Questie.IsWotlk and (not isLastIslePhase) and IsleOfQuelDanas.CheckForActivePhase(questId) then
        QuestieQuest:SmoothReset()
    else
        QuestieQuest:AcceptQuest(questId)
    end

    return true
end

--- Fires when a quest is turned in
---@param questId number
---@param xpReward number
---@param moneyReward number
function _QuestEventHandler:QuestTurnedIn(questId, xpReward, moneyReward)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_TURNED_IN", xpReward, moneyReward, questId)

    if questLog[questId] and questLog[questId].timer then
        -- Cancel the timer so the quest is not marked as abandoned
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
    end

    Questie:Debug(Questie.DEBUG_INFO, "Quest:", questId, "was turned in and is completed")

    if questLog[questId] then
        -- There are quests which you just turn in so there is no preceding QUEST_ACCEPTED event and questLog[questId]
        -- is empty
        questLog[questId].state = QUEST_LOG_STATES.QUEST_TURNED_IN
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")

    if parentQuest and parentQuest > 0 then
        -- Quests like "The Warsong Reports" have child quests which are just turned in. These child quests only
        -- fire QUEST_TURNED_IN + QUEST_LOG_UPDATE
        Questie:Debug(Questie.DEBUG_DEVELOP, "Quest:", questId, "Has a Parent Quest - do a full Quest Log check")
        doFullQuestLogScan = true
    end

    local _, _, _, quality, _, itemID = GetQuestLogRewardInfo(GetNumQuestLogRewards(questId), questId)

    if itemID ~= nil and quality == 1 then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Quest:", questId, "Recieved a possible Quest Item - do a full Quest Log check")
        doFullQuestLogScan = true
        skipNextUQLCEvent = false
    else
        skipNextUQLCEvent = true
    end

    QuestLogCache.RemoveQuest(questId)
    QuestieQuest:SetObjectivesDirty(questId) -- is this necessary? should whole quest.Objectives be cleared at some point of quest removal?

    QuestieQuest:CompleteQuest(questId)
    QuestieJourney:CompleteQuest(questId)
    QuestieAnnounce:CompletedQuest(questId)
end

--- Fires when a quest is removed from the quest log. This includes turning it in and abandoning it.
---@param questId number
function _QuestEventHandler:QuestRemoved(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_REMOVED", questId)
    doFullQuestLogScan = false

    if (not questLog[questId]) then
        questLog[questId] = {}
    end

    -- The party members don't care whether a quest was turned in or abandoned, so we can just broadcast here
    Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questId)

    -- QUEST_TURNED_IN was called before QUEST_REMOVED --> quest was turned in
    if questLog[questId].state == QUEST_LOG_STATES.QUEST_TURNED_IN then
        Questie:Debug(Questie.DEBUG_INFO, "Quest:", questId, "was turned in before. Nothing do to.")
        questLog[questId] = nil
        return
    end

    -- QUEST_REMOVED can fire before QUEST_TURNED_IN. If QUEST_TURNED_IN is not called after X seconds the quest
    -- was abandoned
    questLog[questId] = {
        state = QUEST_LOG_STATES.QUEST_REMOVED,
        timer = C_Timer.NewTicker(1, function()
            _QuestEventHandler:MarkQuestAsAbandoned(questId)
        end, 1)
    }
    skipNextUQLCEvent = true
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_REMOVED - skipNextUQLCEvent - ", skipNextUQLCEvent)
end

---@param questId number
function _QuestEventHandler:MarkQuestAsAbandoned(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestEventHandler:MarkQuestAsAbandoned")
    if questLog[questId].state == QUEST_LOG_STATES.QUEST_REMOVED then
        Questie:Debug(Questie.DEBUG_INFO, "Quest:", questId, "was abandoned")
        questLog[questId].state = QUEST_LOG_STATES.QUEST_ABANDONED

        QuestLogCache.RemoveQuest(questId)
        QuestieQuest:SetObjectivesDirty(questId) -- is this necessary? should whole quest.Objectives be cleared at some point of quest removal?

        QuestieQuest:AbandonedQuest(questId)
        QuestieJourney:AbandonQuest(questId)
        QuestieAnnounce:AbandonedQuest(questId)
        questLog[questId] = nil
    end
end

---Fires when the quest log changed in any way. This event fires very often!
function _QuestEventHandler:QuestLogUpdate()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_LOG_UPDATE")

    local continueQueuing = true
    -- Some of the other quest event didn't have the required information and ordered to wait for the next QLU.
    -- We are now calling the function which the event added.
    while continueQueuing and next(questLogUpdateQueue) do
        continueQueuing = _QuestLogUpdateQueue:GetFirst()()
    end

    if doFullQuestLogScan then
        doFullQuestLogScan = false
        -- Function call updates doFullQuestLogScan. Order matters.
        _QuestEventHandler:UpdateAllQuests()
    else
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end
end

--- Fires whenever a quest objective progressed
---@param questId number
function _QuestEventHandler:QuestWatchUpdate(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_WATCH_UPDATE", questId)

    -- We do a full scan even though we have the questId because many QUEST_WATCH_UPDATE can fire before
    -- a QUEST_LOG_UPDATE. Also not every QUEST_WATCH_UPDATE gets a single QUEST_LOG_UPDATE and doing a full
    -- scan is less error prone
    doFullQuestLogScan = true
end

local _UnitQuestLogChangedCallback = function()
    -- We also check in here because UNIT_QUEST_LOG_CHANGED is fired before the relevant events
    -- (Accept, removed, ...)
    if (not skipNextUQLCEvent) then
        doFullQuestLogScan = true
    else
        doFullQuestLogScan = false
        skipNextUQLCEvent = false
        Questie:Debug(Questie.DEBUG_INFO, "Skipping UnitQuestLogChanged")
    end
    return true
end

--- Fires when an objective changed in the quest log of the unitTarget. The required data is not available yet though
---@param unitTarget string
function _QuestEventHandler:UnitQuestLogChanged(unitTarget)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] UNIT_QUEST_LOG_CHANGED", unitTarget)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] UNIT_QUEST_LOG_CHANGED - skipNextUQLCEvent - ", skipNextUQLCEvent)

    -- There seem to be quests which don't trigger a QUEST_WATCH_UPDATE.
    -- We don't add a full check to the queue if skipNextUQLCEvent == true (from QUEST_WATCH_UPDATE or QUEST_TURNED_IN)
    if (not skipNextUQLCEvent) then
        doFullQuestLogScan = true
        _QuestLogUpdateQueue:Insert(_UnitQuestLogChangedCallback)
    else
        Questie:Debug(Questie.DEBUG_INFO, "Skipping UnitQuestLogChanged")
    end
    skipNextUQLCEvent = false
end

--- Does a full scan of the quest log and updates every quest that is in the QUEST_ACCEPTED state and which hash changed
--- since the last check
function _QuestEventHandler:UpdateAllQuests()
    Questie:Debug(Questie.DEBUG_INFO, "Running full questlog check")
    local questIdsToCheck = {}

    -- TODO replace with a ready table so no need to generate at each call
    for questId, data in pairs(questLog) do
        if data.state == QUEST_LOG_STATES.QUEST_ACCEPTED then
            questIdsToCheck[questId] = true
        end
    end

    local cacheMiss, changes = QuestLogCache.CheckForChanges(questIdsToCheck)

    if next(changes) then
        for questId, objIds in pairs(changes) do
            --Questie:Debug(Questie.DEBUG_INFO, "Quest:", questId, "objectives:", table.concat(objIds, ","), "will be updated")
            Questie:Debug(Questie.DEBUG_INFO, "Quest:", questId, "will be updated")
            QuestieQuest:SetObjectivesDirty(questId)

            QuestieNameplate:UpdateNameplate()
            QuestieQuest:UpdateQuest(questId)
        end
        QuestieCombatQueue:Queue(function()
            C_Timer.After(1.0, function()
                QuestieTracker:Update()
            end)
        end)
    else
        Questie:Debug(Questie.DEBUG_INFO, "Nothing to update")
    end

    -- Do UpdateAllQuests() again at next QUEST_LOG_UPDATE if there was "cacheMiss" (game's cache and addon's cache didn't have all required data yet)
    doFullQuestLogScan = doFullQuestLogScan or cacheMiss
end

local lastTimeQuestRelatedFrameClosedEvent = -1
--- Blizzard does not fire any event when quest items are received or retrieved from sources other than looting.
--- So we hook events which fires once or twice after closing certain frames and do a full quest log check.
function _QuestEventHandler:QuestRelatedFrameClosed(event)
    if event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        return
    end

    local now = GetTime()
    -- Don't do update if event fired twice
    if lastTimeQuestRelatedFrameClosedEvent ~= now then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event]", event)

        lastTimeQuestRelatedFrameClosedEvent = now
        _QuestEventHandler:UpdateAllQuests()
        QuestieTracker:Update()
    end
end

function _QuestEventHandler:ReputationChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] CHAT_MSG_COMBAT_FACTION_CHANGE")

    -- Reputational quest progression doesn't fire UNIT_QUEST_LOG_CHANGED event, only QUEST_LOG_UPDATE event.
    doFullQuestLogScan = true
end

--- Helper function to insert a callback to the questLogUpdateQueue and increase the index
function _QuestLogUpdateQueue:Insert(callback)
    questLogUpdateQueue[questLogUpdateQueueSize] = callback
    questLogUpdateQueueSize = questLogUpdateQueueSize + 1
end

--- Helper function to retrieve the first element of questLogUpdateQueue
---@return function @The callback that was inserted first into questLogUpdateQueue
function _QuestLogUpdateQueue:GetFirst()
    questLogUpdateQueueSize = questLogUpdateQueueSize - 1
    return tableRemove(questLogUpdateQueue, 1)
end

local trackerMinimizedByDungeon = false
function _QuestEventHandler:ZoneChangedNewArea()
    -- By my tests it takes a full 6-7 seconds for the world to load. There are a lot of
    -- backend Questie updates that occur when a player zones in/out of an instance. This
    -- is necessary to get everything back into it's "normal" state after all the updates.

    if IsInInstance() then
        C_Timer.After(8, function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ZONE_CHANGED_NEW_AREA")

            QuestieQuest:GetAllQuestIds()

            if Questie.db.global.hideTrackerInDungeons then
                trackerMinimizedByDungeon = true

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Collapse()
                end)
            end
        end)
    elseif (not Questie.db.char.isTrackerExpanded and not UnitIsGhost("player")) and trackerMinimizedByDungeon == true then
        C_Timer.After(8, function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ZONE_CHANGED_NEW_AREA")

            if Questie.db.global.hideTrackerInDungeons then
                trackerMinimizedByDungeon = false

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Expand()
                    QuestieQuest:GetAllQuestIds()
                end)
            end
        end)
    else
        C_Timer.After(8, function()
            QuestieQuest:GetAllQuestIds()
        end)
    end
end

--- Is executed whenever an event is fired and triggers relevant event handling.
---@param event string
function _QuestEventHandler:OnEvent(event, ...)
    if event == "QUEST_ACCEPTED" then
        _QuestEventHandler:QuestAccepted(...)
    elseif event == "QUEST_TURNED_IN" then
        _QuestEventHandler:QuestTurnedIn(...)
    elseif event == "QUEST_REMOVED" then
        _QuestEventHandler:QuestRemoved(...)
    elseif event == "QUEST_LOG_UPDATE" then
        _QuestEventHandler:QuestLogUpdate()
    elseif event == "QUEST_WATCH_UPDATE" then
        _QuestEventHandler:QuestWatchUpdate(...)
    elseif event == "UNIT_QUEST_LOG_CHANGED" and select(1, ...) == "player" then
        _QuestEventHandler:UnitQuestLogChanged(...)
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        _QuestEventHandler:ZoneChangedNewArea()
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        -- PLAYER_INTERACTION_MANAGER_FRAME_HIDE needs to be first because some of the Era events still fire
        local eventType = select(1, ...)
        if eventType == 1 then
            event = "TRADE_CLOSED"
        elseif eventType == 5 then
            event = "MERCHANT_CLOSED"
        elseif eventType == 8 then
            event = "BANKFRAME_CLOSED"
        elseif eventType == 10 then
            event = "GUILDBANKFRAME_CLOSED"
        elseif eventType == 12 then
            event = "VENDOR_CLOSED"
        elseif eventType == 17 then
            event = "MAIL_CLOSED"
        end
        _QuestEventHandler:QuestRelatedFrameClosed(event)

        -- PLAYER_INTERACTION_MANAGER_FRAME_HIDE doesn't exsist in Era so the Wrath stuff won't conflict
    elseif event == "TRADE_CLOSED" or "MERCHANT_CLOSED" or "BANKFRAME_CLOSED" or "MAIL_CLOSED" then
        _QuestEventHandler:QuestRelatedFrameClosed(event)
    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        _QuestEventHandler:ReputationChange()
    end
end
