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
---@type AutoQuesting
local AutoQuesting = QuestieLoader:ImportModule("AutoQuesting")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type AutoCompleteFrame
local AutoCompleteFrame = QuestieLoader:ImportModule("AutoCompleteFrame")
---@type WatchFrameHook
local WatchFrameHook = QuestieLoader:ImportModule("WatchFrameHook")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local GetItemInfo = C_Item.GetItemInfo or GetItemInfo
local tableRemove = table.remove

local QUEST_LOG_STATES = {
    QUEST_ACCEPTED = "QUEST_ACCEPTED",
    QUEST_TURNED_IN = "QUEST_TURNED_IN",
    QUEST_REMOVED = "QUEST_REMOVED",
    QUEST_ABANDONED = "QUEST_ABANDONED"
}

local questLog = {}
local questLogUpdateQueueSize = 1
local skipNextUQLCEvent = false
local doFullQuestLogScan = false
local deletedQuestItem = false

function QuestEventHandler:Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] Initialize")

    -- StaticPopup dialog hooks. Deleting Quest items do not always trigger a Quest Log Update.
    hooksecurefunc("StaticPopup_Show", function(...)
        -- Hook StaticPopup_Show. If we find the "DELETE_ITEM" dialog, check for Quest Items and notify the player.
        local which, text_arg1 = ...
        if which == "DELETE_ITEM" then
            local quest
            local questName
            local foundQuestItem = false

            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] StaticPopup_Show: Item Name: ", text_arg1)

            if deletedQuestItem == true then
                deletedQuestItem = false
            end

            for questLogIndex = 1, 75 do
                local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)

                if (not title) then
                    break
                end

                if (not isHeader) then
                    quest = QuestieDB.GetQuest(questId)

                    if quest then
                        local info = StaticPopupDialogs[which]
                        local sourceItemId, soureItemName, sourceItemType, soureClassID
                        local reqSourceItemId, reqSoureItemName, reqSourceItemType, reqSoureClassID

                        if quest.sourceItemId then
                            sourceItemId = quest.sourceItemId

                            if sourceItemId then
                                soureItemName, _, _, _, _, sourceItemType, _, _, _, _, _, soureClassID = GetItemInfo(sourceItemId)
                            end
                        end

                        if quest.requiredSourceItems then
                            reqSourceItemId = quest.requiredSourceItems[1]

                            if reqSourceItemId then
                                reqSoureItemName, _, _, _, _, reqSourceItemType, _, _, _, _, _, reqSoureClassID = GetItemInfo(reqSourceItemId)
                            end
                        end

                        if sourceItemId and soureItemName and sourceItemType and soureClassID and (sourceItemType == "Quest" or soureClassID == 12) and QuestieDB.QueryItemSingle(sourceItemId, "class") == 12 and text_arg1 == soureItemName then
                            questName = quest.name
                            foundQuestItem = true
                            break
                        elseif reqSourceItemId and reqSoureItemName and reqSourceItemType and reqSoureClassID and (reqSourceItemType == "Quest" or reqSoureClassID == 12) and QuestieDB.QueryItemSingle(reqSourceItemId, "class") == 12 and text_arg1 == reqSoureItemName then
                            questName = quest.name
                            foundQuestItem = true
                            break
                        else
                            if quest.Objectives and #quest.Objectives > 0 then
                                for _, objective in pairs(quest.Objectives) do
                                    if text_arg1 == objective.Description then
                                        questName = quest.name
                                        foundQuestItem = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if foundQuestItem and quest and questName then
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
                    text:SetFormattedText(updateText, text_arg1, questName)
                    text.text_arg1 = updateText

                    StaticPopup_Resize(frame, which)
                    deletedQuestItem = true

                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] StaticPopup_Show: Quest Item Detected. Updating Static Popup.")
                end
            end
        end
    end)

    hooksecurefunc("DeleteCursorItem", function()
        -- Hook DeleteCursorItem so we know when the player clicks the Accept button
        if deletedQuestItem then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] DeleteCursorItem: Quest Item deleted. Update all quests.")

            _QuestEventHandler:UpdateAllQuests(true)
            deletedQuestItem = false
        end
    end)
end

--- On Login mark all quests in the quest log with QUEST_ACCEPTED state
function QuestEventHandler.InitQuestLogStates(changes)
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
function QuestEventHandler.QuestAccepted(questLogIndex, questId)
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

    QuestieLib:CacheItemNames(questId)
    _QuestEventHandler:HandleQuestAccepted(questId, false)

    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_ACCEPTED - skipNextUQLCEvent - ", skipNextUQLCEvent)
end

---@param questId number
function _QuestEventHandler:HandleQuestAccepted(questId, isRetry)
    -- We first check the quest objectives and retry in the next QLU event if they are not correct yet
    local cacheMiss, _ = QuestLogCache.CheckForChanges({ [questId] = true })
    if cacheMiss then
        -- if cacheMiss, no need to check changes as only 1 questId
        Questie:Debug(Questie.DEBUG_INFO, "Objectives are not cached yet")
        if (not isRetry) then
            C_Timer.After(0.5, function()
                _QuestEventHandler:HandleQuestAccepted(questId, true)
            end)
        end
        return
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

        if Questie.db.profile.autoAccept.enabled and (not AutoQuesting.IsModifierHeld()) and ImmersionFrame and ImmersionFrame:IsShown() then
            ImmersionFrame:Hide()
        end
    end
end

--- Fires when a quest is turned in
---@param questId number
---@param xpReward number
---@param moneyReward number
function QuestEventHandler.QuestTurnedIn(questId, xpReward, moneyReward)
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

    if itemID ~= nil and quality == Enum.ItemQuality.Standard then
        Questie:Debug(Questie.DEBUG_DEVELOP, "Quest:", questId, "Received a possible Quest Item - do a full Quest Log check")
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
function QuestEventHandler.QuestRemoved(questId)
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
function QuestEventHandler.QuestLogUpdate()
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
        _QuestEventHandler:UpdateAllQuests(true)
    else
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end
end

--- Fires whenever a quest objective progressed
---@param questId number
function QuestEventHandler.QuestWatchUpdate(questId)
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

---Some Quests are not turned in at an NPC or object. QUEST_AUTOCOMPLETE is fired for these quests.
---Good quest to test this: https://www.wowhead.com/quest=24502/necessary-roughness
---@param questId number
function QuestEventHandler.QuestAutoComplete(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_AUTOCOMPLETE", questId)

    if Questie.db.profile.trackerEnabled then
        QuestieCombatQueue:Queue(WatchFrameHook.Hide)
        AutoCompleteFrame.ShowAutoComplete(questId)
    end
end

--- Fires when an objective changed in the quest log of the unitTarget. The required data is not available yet though
---@param unitTarget string
function QuestEventHandler.UnitQuestLogChanged(unitTarget)
    if unitTarget ~= "player" then
        return
    end

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
---@param doRetryWithoutChanges boolean @If true, the function will be called again at next QUEST_LOG_UPDATE even if there were no changes
function _QuestEventHandler:UpdateAllQuests(doRetryWithoutChanges)
    Questie:Debug(Questie.DEBUG_INFO, "Running full questlog check")
    local questIdsToCheck = {}

    -- TODO replace with a ready table so no need to generate at each call
    for questId, data in pairs(questLog) do
        if data.state == QUEST_LOG_STATES.QUEST_ACCEPTED then
            questIdsToCheck[questId] = true

            if (not QuestiePlayer.currentQuestlog[questId]) and QuestieDB.QuestPointers[questId] then
                Questie:Error("Please report this error on Discord or GitHub. questLog of QuestEventHandler contains an accepted quest that is not in the players quest log.", questId)
            end
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
            QuestieTracker.UpdateQuestLines(questId)
        end
        QuestieCombatQueue:Queue(function()
            C_Timer.After(1.0, function()
                QuestieTracker:Update()
            end)
        end)
    else
        Questie:Debug(Questie.DEBUG_INFO, "Nothing to update")
        doFullQuestLogScan = doRetryWithoutChanges -- There haven't been any changes, even though we called UpdateAllQuests. We need to check again at next QUEST_LOG_UPDATE
    end

    -- Do UpdateAllQuests() again at next QUEST_LOG_UPDATE if there was "cacheMiss" (game's cache and addon's cache didn't have all required data yet)
    doFullQuestLogScan = doFullQuestLogScan or cacheMiss
end

local lastTimeQuestRelatedFrameClosedEvent = -1
--- Blizzard does not fire any event when quest items are received or retrieved from sources other than looting.
--- So we hook events which fires once or twice after closing certain frames and do a full quest log check.
function _QuestEventHandler:QuestRelatedFrameClosed(event)
    local now = GetTime()
    -- Don't do update if event fired twice
    if lastTimeQuestRelatedFrameClosedEvent ~= now then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event]", event)

        lastTimeQuestRelatedFrameClosedEvent = now
        _QuestEventHandler:UpdateAllQuests(false)
        QuestieTracker:Update()
    end
end

function QuestEventHandler.ReputationChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] CHAT_MSG_COMBAT_FACTION_CHANGE")

    -- Reputational quest progression doesn't fire UNIT_QUEST_LOG_CHANGED event, only QUEST_LOG_UPDATE event.
    doFullQuestLogScan = true
end

-- Spell objectives; Runes in SoD count as recipes because "Engraving" is a profession?
function QuestEventHandler.NewRecipeLearned()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] NEW_RECIPE_LEARNED (QuestEventHandler)")

    doFullQuestLogScan = true -- If this event is related to a spell objective, a QUEST_LOG_UPDATE will be fired afterwards
end

function QuestEventHandler.CurrencyDisplayUpdate()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CURRENCY_DISPLAY_UPDATE (QuestEventHandler)")

    -- We want to make sure we are doing a full quest log scan, when the currency changed. There are quests which reward a currency and this
    -- currency is also a quest objective. When just setting doFullQuestLogScan to true, the QUEST_REMOVED event will revert it and therefore
    -- the next QLU event will not do a full scan.
    _QuestLogUpdateQueue:Insert(function()
        doFullQuestLogScan = true
    end)
end

function QuestEventHandler.PlayerInteractionManagerFrameHide(eventType)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] PLAYER_INTERACTION_MANAGER_FRAME_HIDE", eventType)

    local eventName
    if eventType == 1 then
        eventName = "TRADE_CLOSED"
    elseif eventType == 5 then
        eventName = "MERCHANT_CLOSED"
    elseif eventType == 8 then
        eventName = "BANKFRAME_CLOSED"
    elseif eventType == 10 then
        eventName = "GUILDBANKFRAME_CLOSED"
    elseif eventType == 12 then
        eventName = "VENDOR_CLOSED"
    elseif eventType == 17 then
        eventName = "MAIL_CLOSED"
    elseif eventType == 21 then
        eventName = "AUCTION_HOUSE_CLOSED"
    else
        -- Unknown events are simply ignored
        return
    end

    _QuestEventHandler:QuestRelatedFrameClosed(eventName)
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

return QuestEventHandler
