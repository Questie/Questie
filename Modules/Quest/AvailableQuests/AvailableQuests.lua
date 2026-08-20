---@class AvailableQuests
local AvailableQuests = QuestieLoader:CreateModule("AvailableQuests")

---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type DailyQuestComms
local DailyQuestComms = QuestieLoader:ImportModule("DailyQuestComms")
---@type DailyQuestCommsBlacklist
local DailyQuestCommsBlacklist = QuestieLoader:ImportModule("DailyQuestCommsBlacklist")

local GetQuestGreenRange = GetQuestGreenRange
local yield = coroutine.yield
local tinsert = table.insert

local QUESTS_PER_YIELD = 24

--- When CalculateAndDrawAll is called while a pass is already running, we queue a follow-up
--- pass instead of cancelling the running one. This prevents a burst of concurrent callers
--- (turn-in event + reputation event etc.) from repeatedly cancelling each other mid-pass
--- so that a draw pass always runs to completion.
--- true = another pass must start once the current one finishes.
local passQueued = false

--- true while a ThreadLib pass coroutine is alive.
local passRunning = false

--- Callbacks accumulated from callers that arrived while a pass was in flight.
--- They are all invoked after the next completed pass.
---@type function[]
local pendingCallbacks = {}

-- Keep track of all available quests to unload undoable when abandoning a quest
---@type table<QuestId, boolean>
local availableQuests = {}
AvailableQuests.__availableQuests = availableQuests

---@type table<NpcId, table<QuestId, boolean>>
local availableQuestsByNpc = {}
AvailableQuests.__availableQuestsByNpc = availableQuestsByNpc

--- Quests that were hidden after talking to an NPC
---@type table<QuestId, boolean>
local unavailableQuestsDeterminedByTalking

--- Unavailable daily/weekly quests grouped by NPC, used to answer requests from guild/party members
---@type table<NpcId, table<QuestId, boolean>>
local unavailableDailyQuestsByNpc

local dungeons
local playerFaction
local QIsComplete, IsLevelRequirementsFulfilled, IsDoable = QuestieDB.IsComplete, AvailableQuests.IsLevelRequirementsFulfilled, QuestieDB.IsDoable

local _CalculateAndDrawAvailableQuests, _DrawAvailableQuest, _DrawChildQuests, _AddStarter
local _GetIconScaleForAvailable, _HasProperDistanceToAlreadyAddedSpawns
local _ScheduleDailyResetTimer, _MarkQuestAsUnavailableFromNPC, _CanNpcOfferQuestToPlayer

-- Exposed for testing only
AvailableQuests.__getPassState = function()
    return passRunning, passQueued
end

function AvailableQuests.Initialize()
    Questie.Debug(Questie.DEBUG_DEVELOP, "AvailableQuests: Initialize")
    dungeons = ZoneDB:GetDungeons()
    playerFaction = UnitFactionGroup("player")

    local realmName = GetRealmName()
    if (not Questie.db.global.unavailableQuestsDeterminedByTalking[realmName]) or QuestieLib.DidDailyResetHappenSinceLastLogin() then
        Questie.db.global.unavailableQuestsDeterminedByTalking[realmName] = {}
    end
    unavailableQuestsDeterminedByTalking = Questie.db.global.unavailableQuestsDeterminedByTalking[realmName]
    AvailableQuests.__unavailableQuestsDeterminedByTalking = unavailableQuestsDeterminedByTalking

    if (not Questie.db.global.unavailableDailyQuestsByNpc[realmName]) or QuestieLib.DidDailyResetHappenSinceLastLogin() then
        Questie.db.global.unavailableDailyQuestsByNpc[realmName] = {}
    end
    unavailableDailyQuestsByNpc = Questie.db.global.unavailableDailyQuestsByNpc[realmName]
    AvailableQuests.__unavailableDailyQuestsByNpc = unavailableDailyQuestsByNpc

    if (not Questie.IsClassic) then
        _ScheduleDailyResetTimer()
    end
end

--- Clears both unavailable quest tables for the current realm (triggered by daily reset).
function AvailableQuests.ClearUnavailableDailyQuests()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[AvailableQuests.ClearUnavailableDailyQuests]")

    local realmName = GetRealmName()
    Questie.db.global.unavailableQuestsDeterminedByTalking[realmName] = {}
    Questie.db.global.unavailableDailyQuestsByNpc[realmName] = {}
    unavailableQuestsDeterminedByTalking = Questie.db.global.unavailableQuestsDeterminedByTalking[realmName]
    unavailableDailyQuestsByNpc = Questie.db.global.unavailableDailyQuestsByNpc[realmName]
end

--- Schedules a one-shot timer to fire at the next daily reset time, then reschedules itself for the next reset.
_ScheduleDailyResetTimer = function()
    local realmName = GetRealmName()
    local lastKnownReset = Questie.db.global.lastKnownDailyReset[realmName]
    local now = GetServerTime()
    local delay

    if lastKnownReset then
        delay = lastKnownReset - now + 5 -- +5 seconds safety margin
    else
        -- First login, calculate delay to next reset from current time
        delay = GetQuestResetTime() + 5
    end

    if delay < 0 then
        -- Reset already happened; clear and reschedule immediately
        delay = 1
    end

    C_Timer.After(delay, function()
        AvailableQuests.ClearUnavailableDailyQuests()
        QuestieLib.UpdateLastKnownDailyReset()
        _ScheduleDailyResetTimer() -- Reschedule for the next reset

        if QuestieDB.QuestPointers then
            -- We don't want to do this while the database is compiling. This happens after updating Questie on the first login of the day
            AvailableQuests.CalculateAndDrawAll()
        end
    end)
end

---Returns all unavailable daily/weekly quests grouped by NPC, for broadcasting to guild/party members.
---@return table<NpcId, QuestId[]>
function AvailableQuests.GetUnavailableDailyQuests()
    local result = {}
    for npcId, questIds in pairs(unavailableDailyQuestsByNpc) do
        local list = {}
        for questId in pairs(questIds) do
            list[#list + 1] = questId
        end
        if #list > 0 then
            result[npcId] = list
        end
    end
    return result
end

--- Starts a fresh draw pass, draining any accumulated pending callbacks as the
--- ThreadLib completion callback so they fire once the new pass finishes.
local function _StartPass()
    passQueued = false
    passRunning = true
    local callbacks = pendingCallbacks
    pendingCallbacks = {}
    ThreadLib.Thread(_CalculateAndDrawAvailableQuests, 0, "Error in AvailableQuests.CalculateAndDrawAll", function()
        passRunning = false

        for i = 1, #callbacks do
            local success, err = pcall(callbacks[i])
            if (not success) then
                Questie.Error("Error in AvailableQuests.CalculateAndDrawAll callback", err)
            end
        end
        -- If another CalculateAndDrawAll arrived while this pass was running, start it now.
        if passQueued then
            _StartPass()
        end
    end, function()
        -- The coroutine errored: reset state and start any queued pass.
        -- Callbacks are intentionally skipped — the draw was incomplete.
        passRunning = false
        if passQueued then
            _StartPass()
        end
    end, "AvailableQuests.CalculateAndDrawAll")
end

---@param callback function | nil
function AvailableQuests.CalculateAndDrawAll(callback)
    Questie.Debug(Questie.DEBUG_INFO, "[AvailableQuests.CalculateAndDrawAll]")

    if callback then
        pendingCallbacks[#pendingCallbacks + 1] = callback
    end

    if passRunning then
        -- A pass is already running. Queue a follow-up so the running pass is not
        -- cancelled mid-flight; it will start once the current pass completes.
        passQueued = true
        return
    end

    _StartPass()
end

--Draw a single available quest, it is used by the CalculateAndDrawAll function.
---@param quest Quest
function AvailableQuests.DrawAvailableQuest(quest) -- prevent recursion
    --? Some quests can be started by both an NPC and a GameObject

    local added = 0
    local limit = Questie.db.profile.availableIconLimit
    if quest.Starts.Item then
        local items = quest.Starts.Item
        for i = 1, #items do
            local item = QuestieDB:GetItem(quest.Starts.Item[i])

            if (not item) then
                -- TODO: This check can be removed once the DB is fixed
                Questie.Error("Item not found for quest", quest.Id, "Item ID:", items[i], "- Please report this on Github or Discord!")
                return
            end

            if item.npcDrops then
                for _, npc in ipairs(item.npcDrops) do
                    local no = QuestieDB:GetNPC(npc)
                    if limit == 0 or added < limit then
                        added = added + _AddStarter(no, quest, "im_" .. npc, (limit == 0 and 0) or (limit - added))
                    else
                        QuestieTooltips:RegisterQuestStartTooltip(quest.Id, no.name, npc, "m_" .. npc, "itemFromMonster")
                    end
                end
            end
            if item.objectDrops then
                for _, obj in ipairs(item.objectDrops) do
                    local oo = QuestieDB:GetObject(obj)
                    if limit == 0 or added < limit then
                        added = added + _AddStarter(oo, quest, "io_" .. obj, (limit == 0 and 0) or (limit - added))
                    else
                        QuestieTooltips:RegisterQuestStartTooltip(quest.Id, oo.name, obj, "o_" .. obj, "itemFromObject")
                    end
                end
            end
        end
    end
    if quest.Starts.GameObject then
        local gameObjects = quest.Starts.GameObject
        for i = 1, #gameObjects do
            local obj = QuestieDB:GetObject(gameObjects[i])

            if (not obj) then
                -- TODO: This check can be removed once the DB is fixed
                Questie.Error("Object not found for quest", quest.Id, "Object ID:", gameObjects[i], "- Please report this on Github or Discord!")
                return
            end

            if limit == 0 or added < limit then
                added = added + _AddStarter(obj, quest, "o_" .. obj.id, (limit == 0 and 0) or (limit - added))
            else
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, obj.name, obj.id, "o_" .. obj.id, "Object")
            end
        end
    end
    if (quest.Starts.NPC) then
        local npcs = quest.Starts.NPC
        for i = 1, #npcs do
            local npc = QuestieDB:GetNPC(npcs[i])

            if (not npc) then
                -- TODO: This check can be removed once the DB is fixed
                Questie.Error("NPC not found for quest", quest.Id, "NPC ID:", npcs[i], "- Please report this on Github or Discord!")
                return
            end

            if (not availableQuestsByNpc[npc.id]) then
                availableQuestsByNpc[npc.id] = {}
            end
            availableQuestsByNpc[npc.id][quest.Id] = true

            if limit == 0 or added < limit then
                added = added + _AddStarter(npc, quest, "m_" .. npc.id, (limit == 0 and 0) or (limit - added))
            else
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, npc.name, npc.id, "m_" .. npc.id, "NPC")
            end
        end
    end
end

---@type string|nil
local lastNpcGuid

---This re-enables available quest validation when re-talking to the same NPC. A common case is, when a user talks to an NPC to accept
---a daily quest while still having the one from yesterday in the quest log. Abandoning yesterdays quest will then re-calculate the
---unavailable quests when directly talking to the same NPC again.
function AvailableQuests.ResetLastNpcGuid()
    lastNpcGuid = nil
end

---@param questId QuestId
---@param onComplete function? Optional callback invoked after the starter/finisher frames are unloaded.
function AvailableQuests.RemoveQuest(questId, onComplete)
    availableQuests[questId] = nil
    ThreadLib.ThreadCallbackInstant(function()
        QuestieMap:UnloadQuestFrames(questId)
    end, function()
        if onComplete then
            onComplete()
        end
    end)
    QuestieTooltips:RemoveQuest(questId)
end

---@param quest Quest
function AvailableQuests.RecreateFailedQuest(quest)
    local questId = quest.Id
    availableQuests[questId] = nil
    lastNpcGuid = nil

    ThreadLib.ThreadCallbackInstant(function()
        QuestieMap:UnloadQuestFrames(questId)
    end, function()
        QuestieTooltips:RemoveQuest(questId)
        AvailableQuests.DrawAvailableQuest(quest)
        Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questId)
    end)
end

---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
function AvailableQuests.RemoveQuestsForToday(npcId, questIds)
    for _, questId in pairs(questIds) do
        if availableQuestsByNpc[npcId] then
            AvailableQuests.RemoveQuest(questId)
            availableQuestsByNpc[npcId][questId] = nil
        end
        unavailableQuestsDeterminedByTalking[questId] = true

        if (not unavailableDailyQuestsByNpc[npcId]) then
            unavailableDailyQuestsByNpc[npcId] = {}
        end
        unavailableDailyQuestsByNpc[npcId][questId] = true
    end
end

--- Called on GOSSIP_SHOW to hide all quests that are not available from the NPC.
function AvailableQuests.ValidateAvailableQuestsFromGossipShow()
    local npcGuid = UnitGUID("target")
    if (not npcGuid) then
        return
    end

    local _, _, _, _, _, npcIDStr = strsplit("-", npcGuid)
    if (not npcIDStr) then
        return
    end

    ---@type NpcId
    local npcId = tonumber(npcIDStr)
    if lastNpcGuid == npcGuid then
        return
    end

    lastNpcGuid = npcGuid

    local availableQuestsInGossip = QuestieCompat.GetAvailableQuests()

    -- validate no quest is incorrectly hidden
    for _, gossipQuest in pairs(availableQuestsInGossip) do
        local questId = gossipQuest.questID
        if unavailableQuestsDeterminedByTalking[questId] then
            unavailableQuestsDeterminedByTalking[questId] = nil
            if unavailableDailyQuestsByNpc[npcId] then
                unavailableDailyQuestsByNpc[npcId][questId] = nil
            end
            local quest = QuestieDB.GetQuest(questId)
            if quest then
                availableQuests[questId] = true
                AvailableQuests.DrawAvailableQuest(quest)
            end
        end
    end

    -- Active quests are relevant, because the API can fire GOSSIP_SHOW before QUEST_ACCEPTED.
    -- So we need to check active quests to not hide them incorrectly for the day.
    local activeQuests = QuestieCompat.GetActiveQuests()
    local unavailableQuestsToBroadcast = {}
    for questId in pairs(availableQuestsByNpc[npcId] or {}) do
        local isAvailableInGossip = false
        for _, gossipQuest in pairs(availableQuestsInGossip) do
            if gossipQuest.questID == questId then
                isAvailableInGossip = true
                break
            end
        end
        for _, gossipQuest in pairs(activeQuests) do
            if gossipQuest.questID == questId then
                isAvailableInGossip = true
                break
            end
        end

        if (not isAvailableInGossip) and (not DailyQuestCommsBlacklist.IsBlacklisted(questId)) and (QuestieDB.IsDailyQuest(questId) or QuestieDB.IsWeeklyQuest(questId)) and _CanNpcOfferQuestToPlayer(questId) then -- no monthly quests here, those are personal
            AvailableQuests.RemoveQuest(questId)
            _MarkQuestAsUnavailableFromNPC(questId, npcId)
            table.insert(unavailableQuestsToBroadcast, questId)
        end
    end

    if next(unavailableQuestsToBroadcast) then
        DailyQuestComms.BroadcastUnavailableDailyQuests(npcId, unavailableQuestsToBroadcast)
    end
end

--- Called on QUEST_DETAIL to hide all quests that are not available from the NPC.
--- This is relevant on NPCs which offer random quests each day and especially a different number of quests.
function AvailableQuests.ValidateAvailableQuestsFromQuestDetail()
    local npcGuid = UnitGUID("target")
    if (not npcGuid) then
        return
    end

    local _, _, _, _, _, npcIDStr = strsplit("-", npcGuid)
    if (not npcIDStr) then
        return
    end

    ---@type NpcId
    local npcId = tonumber(npcIDStr)
    if lastNpcGuid == npcGuid then
        return
    end

    lastNpcGuid = npcGuid

    -- Hide all quests but the current one
    local availableQuestId = GetQuestID()
    if availableQuestId == 0 then
        -- GetQuestID returns 0 when the dialog is closed. Nothing left to do for us
        return
    end

    -- validate quest is not incorrectly hidden
    if unavailableQuestsDeterminedByTalking[availableQuestId] then
        unavailableQuestsDeterminedByTalking[availableQuestId] = nil
        if unavailableDailyQuestsByNpc[npcId] then
            unavailableDailyQuestsByNpc[npcId][availableQuestId] = nil
        end
        local quest = QuestieDB.GetQuest(availableQuestId)
        if quest then
            availableQuests[availableQuestId] = true
            AvailableQuests.DrawAvailableQuest(quest)
        end
    end

    local unavailableQuestsToBroadcast = {}
    for questId in pairs(availableQuestsByNpc[npcId] or {}) do
        if questId ~= availableQuestId and (not DailyQuestCommsBlacklist.IsBlacklisted(questId)) and (QuestieDB.IsDailyQuest(questId) or QuestieDB.IsWeeklyQuest(questId)) and _CanNpcOfferQuestToPlayer(questId) then -- no monthly quests here, those are personal
            AvailableQuests.RemoveQuest(questId)
            _MarkQuestAsUnavailableFromNPC(questId, npcId)
            table.insert(unavailableQuestsToBroadcast, questId)
        end
    end

    if next(unavailableQuestsToBroadcast) then
        DailyQuestComms.BroadcastUnavailableDailyQuests(npcId, unavailableQuestsToBroadcast)
    end
end

--- Called on QUEST_GREETING to hide all quests that are not available from the NPC.
--- This is relevant on NPCs which offer random quests each day and especially a different number of quests.
function AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()
    local npcGuid = UnitGUID("target")
    if (not npcGuid) then
        return
    end

    local _, _, _, _, _, npcIDStr = strsplit("-", npcGuid)
    if (not npcIDStr) then
        return
    end

    ---@type NpcId
    local npcId = tonumber(npcIDStr)
    if lastNpcGuid == npcGuid then
        return
    end

    lastNpcGuid = npcGuid

    local availableQuestsInGreeting = {}
    local unresolvedQuestInGreeting = false
    for i = 1, MAX_NUM_QUESTS do
        local titleLine = _G["QuestTitleButton" .. i]
        if (not titleLine) then
            break
        elseif titleLine:IsVisible() then
            local title
            local isActive = titleLine.isActive == 1
            if isActive then
                -- Active quests are relevant, because the API can fire QUEST_GREETING before QUEST_ACCEPTED.
                -- So we need to check active quests to not hide them incorrectly for the day.
                title = GetActiveTitle(titleLine:GetID())
            else
                title = GetAvailableTitle(titleLine:GetID())
            end
            local questId = QuestieDB.GetQuestIDFromName(title, npcGuid, (not isActive))
            if questId > 0 then
                availableQuestsInGreeting[questId] = true
            else
                -- A visible quest in the frame could not be resolved to an ID, so we cannot know which quest it is.
                -- Keep all quests available instead of hiding any, to not hide an available quest that we simply failed
                -- to identify. This is also a problem when users use a different WoW client locale than they set their
                -- Questie to (API names ~= lookup names)
                unresolvedQuestInGreeting = true
            end
        end
    end

    -- validate no quest is incorrectly hidden
    for questId in pairs(availableQuestsInGreeting) do
        if unavailableQuestsDeterminedByTalking[questId] then
            unavailableQuestsDeterminedByTalking[questId] = nil
            if unavailableDailyQuestsByNpc[npcId] then
                unavailableDailyQuestsByNpc[npcId][questId] = nil
            end
            local quest = QuestieDB.GetQuest(questId)
            if quest then
                availableQuests[questId] = true
                AvailableQuests.DrawAvailableQuest(quest)
            end
        end
    end

    if unresolvedQuestInGreeting then
        return
    end

    local unavailableQuestsToBroadcast = {}
    for questId in pairs(availableQuestsByNpc[npcId] or {}) do
        if (not availableQuestsInGreeting[questId]) and (not DailyQuestCommsBlacklist.IsBlacklisted(questId)) and (QuestieDB.IsDailyQuest(questId) or QuestieDB.IsWeeklyQuest(questId)) and _CanNpcOfferQuestToPlayer(questId) then -- no monthly quests here, those are personal
            AvailableQuests.RemoveQuest(questId)
            _MarkQuestAsUnavailableFromNPC(questId, npcId)
            table.insert(unavailableQuestsToBroadcast, questId)
        end
    end

    if next(unavailableQuestsToBroadcast) then
        DailyQuestComms.BroadcastUnavailableDailyQuests(npcId, unavailableQuestsToBroadcast)
    end
end

_CalculateAndDrawAvailableQuests = function()
    -- Localize the variables for speeeeed
    local debugEnabled = Questie.db.profile.debugEnabled

    local questData = QuestieDB.QuestPointers or QuestieDB.questData

    local playerLevel = QuestiePlayer.GetPlayerLevel()
    local minLevel = playerLevel - GetQuestGreenRange("player")
    local maxLevel = playerLevel

    if Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_RANGE then
        minLevel = Questie.db.profile.minLevelFilter
        maxLevel = Questie.db.profile.maxLevelFilter
    elseif Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_OFFSET then
        minLevel = playerLevel - Questie.db.profile.manualLevelOffset
    end

    local completedQuests = Questie.db.char.complete
    local showRepeatableQuests = Questie.db.profile.showRepeatableQuests
    local showDungeonQuests = Questie.db.profile.showDungeonQuests
    local showRaidQuests = Questie.db.profile.showRaidQuests
    local showPvPQuests = Questie.db.profile.showPvPQuests
    local showAQWarEffortQuests = Questie.db.profile.showAQWarEffortQuests

    local autoBlacklist = QuestieDB.autoBlacklist
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local hidden = Questie.db.char.hidden

    local currentQuestlog = QuestiePlayer.currentQuestlog
    local currentIsleOfQuelDanasQuests = IsleOfQuelDanas.quests[Questie.db.profile.isleOfQuelDanasPhase] or {}
    local aqWarEffortQuests = QuestieQuestBlacklist.AQWarEffortQuests

    QuestieDB.activeChildQuests = {} -- Reset here so we don't need to keep track in the quest event system

    local IsClassic = Questie.IsClassic
    local IsSoD = Questie.IsSoD

    -- We create a local function here to improve readability but use the localized variables above.
    -- The order of checks is important here to bring the speed to a max
    local questsToRemove = {}
    local function _CheckAvailability(questId)
        if currentQuestlog[questId] then
            _DrawChildQuests(questId, currentQuestlog, completedQuests, hiddenQuests)

            if QIsComplete(questId) ~= -1 then -- The quest in the quest log is not failed, so we don't show it as available
                availableQuests[questId] = nil
                return
            end
        end

        if (
                ((not showRepeatableQuests) and QuestieDB.IsRepeatable(questId)) or -- Don't show repeatable quests if option is disabled
                ((not showPvPQuests) and QuestieDB.IsPvPQuest(questId)) or -- Don't show PvP quests if option is disabled
                ((not showDungeonQuests) and QuestieDB.IsDungeonQuest(questId)) or -- Don't show dungeon quests if option is disabled
                ((not showRaidQuests) and QuestieDB.IsRaidQuest(questId)) or -- Don't show raid quests if option is disabled
                ((not showAQWarEffortQuests) and aqWarEffortQuests[questId]) or -- Don't show AQ War Effort quests if the option disabled
                (IsClassic and currentIsleOfQuelDanasQuests[questId]) or -- Don't show Isle of Quel'Danas quests for Era/HC/SoX
                (IsSoD and QuestieDB.IsRuneAndShouldBeHidden(questId)) -- Don't show SoD Rune quests with the option disabled
            ) then
            if availableQuests[questId] then
                questsToRemove[#questsToRemove + 1] = questId
            end
            availableQuests[questId] = nil
            return
        end

        if ((not IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel)) or (not IsDoable(questId, debugEnabled))) then
            --If the quests are not within level range we want to unload them
            --(This is for when people level up or change settings etc)

            if availableQuests[questId] then
                questsToRemove[#questsToRemove + 1] = questId
            end
            availableQuests[questId] = nil
            return
        end

        availableQuests[questId] = true
    end

    for questId in pairs(questData) do
        if (autoBlacklist[questId] or -- Don't show autoBlacklist quests marked as such by IsDoable
                completedQuests[questId] or -- Don't show completed quests
                hiddenQuests[questId] or -- Don't show blacklisted quests
                hidden[questId] or -- Don't show quests hidden by the player
                unavailableQuestsDeterminedByTalking[questId] -- Don't show quests hidden after talking to an NPC
            ) then
            availableQuests[questId] = nil
        else
            _CheckAvailability(questId)
        end
    end

    -- Process removals in a separate yielding loop to avoid a spike when many quests
    -- are unloaded at once (e.g. switching from "show all levels" to default).
    local yieldCount = 0
    for i = 1, #questsToRemove do
        AvailableQuests.RemoveQuest(questsToRemove[i])

        yieldCount = yieldCount + 1
        if yieldCount >= QUESTS_PER_YIELD then
            yieldCount = 0
            yield()
        end
    end

    yieldCount = 0
    for questId in pairs(availableQuests) do
        if QuestieMap.questIdFrames[questId] then
            -- We already drew this quest so we might need to update the icon (config changed/level up)
            QuestieMap.UpdateDrawnIcons(questId)
        else
            _DrawAvailableQuest(questId)
        end

        -- Reset the yieldCount
        yieldCount = yieldCount + 1
        if yieldCount > QUESTS_PER_YIELD then
            yieldCount = 0
            yield()
        end
    end
end

--- Mark all child quests as active when the parent quest is in the quest log
--- Reused this logic in QuestsByZone.lua/QuestsByFaction.lua -- TO DO: copy logic to QBF
--- if this is modified, also make sure the changes are reflected in the other file
---@param questId number
---@param currentQuestlog table<number, boolean>
---@param completedQuests table<number, boolean>
_DrawChildQuests = function(questId, currentQuestlog, completedQuests, hiddenQuests)
    local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
    if (not childQuests) then
        return
    end

    for _, childQuestId in pairs(childQuests) do
        local requiredRaces = QuestieDB.QueryQuestSingle(childQuestId, "requiredRaces")
        if (not completedQuests[childQuestId]) and (not currentQuestlog[childQuestId]) and (not hiddenQuests[childQuestId]) and (QuestiePlayer.HasRequiredRace(requiredRaces)) then
            local childQuestExclusiveTo = QuestieDB.QueryQuestSingle(childQuestId, "exclusiveTo")
            local blockedByExclusiveTo = false
            for _, exclusiveToQuestId in pairs(childQuestExclusiveTo or {}) do
                if QuestiePlayer.currentQuestlog[exclusiveToQuestId] or completedQuests[exclusiveToQuestId] then
                    blockedByExclusiveTo = true
                    break
                end
            end
            if (not blockedByExclusiveTo) then
                local isPreQuestSingleFulfilled = true
                local isPreQuestGroupFulfilled = true

                local preQuestSingle = QuestieDB.QueryQuestSingle(childQuestId, "preQuestSingle")
                if preQuestSingle then
                    isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
                else
                    local preQuestGroup = QuestieDB.QueryQuestSingle(childQuestId, "preQuestGroup")
                    if preQuestGroup then
                        isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
                    end
                end

                if isPreQuestSingleFulfilled and isPreQuestGroupFulfilled then
                    QuestieDB.activeChildQuests[childQuestId] = true
                    availableQuests[childQuestId] = true
                    -- Draw them right away and skip all other irrelevant checks
                    _DrawAvailableQuest(childQuestId)
                end
            end
        end
    end
end

---@param questId number
_DrawAvailableQuest = function(questId)
    ThreadLib.Thread(function()
        local quest = QuestieDB.GetQuest(questId)
        if (not quest.tagInfoWasCached) then
            QuestieDB.GetQuestTagInfo(questId) -- cache to load in the tooltip

            quest.tagInfoWasCached = true
        end

        AvailableQuests.DrawAvailableQuest(quest)
    end, 0, nil, nil, nil, "_DrawAvailableQuest")
end

---@param starter Object|NPC Either an object or an NPC from QuestieDB.
---@param quest Quest A Quest from QuestieDB.
---@param tooltipKey string The tooltip key. For objects it's "o_<ID>", for NPCs it's "m_<ID>", for items it's "im_<ID>" or "io_<ID".
---@param limit number The number of icons left to draw before the limit set in AvailableQuests.DrawAvailableQuest is reached. Zero means no limit.
---@return number added The amount of notes that were added (excluding waypoints)
_AddStarter = function(starter, quest, tooltipKey, limit)
    if (not starter) then
        return 0
    end

    -- Need to know when this quest starts from an item or object, so we save it later
    ---@type string|nil
    local starterType

    if tooltipKey == "m_" .. starter.id then
        -- filter hostile starters
        if playerFaction == "Alliance" and starter.friendlyToFaction == "H" then
            return 0
        elseif playerFaction == "Horde" and starter.friendlyToFaction == "A" then
            return 0
        end
    elseif tooltipKey == "im_" .. starter.id then
        -- We don't filter items by faction, because Questie can not differentiate neutral NPCs from friendly ones.
        -- overwrite tooltipKey, so stuff shows in monster tooltips
        tooltipKey = "m_" .. starter.id
        starterType = "itemFromMonster"
    elseif tooltipKey == "o_" .. starter.id then
        starterType = "Object"
    elseif tooltipKey == "io_" .. starter.id then
        -- overwrite tooltipKey, so stuff shows in object tooltips
        tooltipKey = "o_" .. starter.id
        starterType = "itemFromObject"
    end

    QuestieTooltips:RegisterQuestStartTooltip(quest.Id, starter.name, starter.id, tooltipKey, (starterType or "NPC"))

    local starterIcons = {}
    local starterLocs = {}
    local added = 0
    for zone, spawns in pairs(starter.spawns or {}) do
        local alreadyAddedSpawns = {}
        if (zone and spawns) then
            local coords
            for spawnIndex = 1, #spawns do
                coords = spawns[spawnIndex]
                if (#spawns == 1 or _HasProperDistanceToAlreadyAddedSpawns(coords, alreadyAddedSpawns)) and (limit == 0 or limit - added > 0) then
                    ---@type IconData
                    local data = {
                        Id = quest.Id,
                        Icon = QuestieLib.GetQuestIcon(quest),
                        GetIconScale = _GetIconScaleForAvailable,
                        IconScale = _GetIconScaleForAvailable(),
                        Type = "available",
                        QuestData = quest,
                        Name = starter.name,
                        IsObjectiveNote = false,
                        StarterType = starterType,
                    }

                    if (coords[1] == -1 or coords[2] == -1) then
                        local dungeonLocation = ZoneDB:GetDungeonLocation(zone)
                        if dungeonLocation then
                            for _, value in ipairs(dungeonLocation) do
                                QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                added = added + 1
                            end
                        end
                    else
                        local icon = QuestieMap:DrawWorldIcon(data, zone, coords[1], coords[2], coords[3])
                        if starter.waypoints then
                            -- This is only relevant for waypoint drawing
                            starterIcons[zone] = icon
                            if not starterLocs[zone] then
                                starterLocs[zone] = {coords[1], coords[2]}
                            end
                        end
                        if icon then
                            tinsert(alreadyAddedSpawns, coords)
                            added = added + 1
                        end
                    end
                end
            end
        end
    end

    -- Only for NPCs since objects do not move
    if starter.waypoints then
        for zone, waypoints in pairs(starter.waypoints or {}) do
            if not dungeons[zone] and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then
                if not starterIcons[zone] then
                    ---@type IconData
                    local data = {
                        Id = quest.Id,
                        Icon = QuestieLib.GetQuestIcon(quest),
                        GetIconScale = _GetIconScaleForAvailable,
                        IconScale = _GetIconScaleForAvailable(),
                        Type = "available",
                        QuestData = quest,
                        Name = starter.name,
                        IsObjectiveNote = false,
                        StarterType = starterType,
                    }
                    starterIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                    starterLocs[zone] = {waypoints[1][1][1], waypoints[1][1][2]}
                    added = added + 1
                end
                QuestieMap:DrawWaypoints(starterIcons[zone], waypoints, zone)
            end
        end
    end
    return added
end

_HasProperDistanceToAlreadyAddedSpawns = function(coords, alreadyAddedSpawns)
    for _, alreadyAdded in pairs(alreadyAddedSpawns) do
        local distance = QuestieLib.GetSpawnDistance(alreadyAdded, coords)
        -- 28 seems like a good distance. The NPC Denalan in Teldrassil shows both spawns for the quests
        if distance < Questie.db.profile.spawnFilterDistance then
            return false
        end
    end
    return true
end

_GetIconScaleForAvailable = function()
    return Questie.db.profile.availableScale or 1.3
end

--- Quests outside the player's level capability are never offered by an NPC in the game, so their
--- absence from the gossip/greeting UI is not evidence that they are unavailable today. Such quests
--- must not be hidden or broadcast as unavailable.
--- This scenario can happen though when players use a non-default "Which available quests should be displayed"
--- setting and show quests which are not available yet due to level restrictions.
---@param questId QuestId
---@return boolean
_CanNpcOfferQuestToPlayer = function(questId)
    local playerLevel = QuestiePlayer.GetPlayerLevel()
    local _, requiredLevel, requiredMaxLevel = QuestieLib.GetEffectiveQuestLevel(questId, playerLevel)
    if requiredLevel and requiredLevel > playerLevel then
        return false
    end
    if requiredMaxLevel and requiredMaxLevel ~= 0 and playerLevel > requiredMaxLevel then
        return false
    end
    return true
end

---@param questId QuestId
---@param npcId NpcId
_MarkQuestAsUnavailableFromNPC = function(questId, npcId)
    unavailableQuestsDeterminedByTalking[questId] = true
    availableQuestsByNpc[npcId][questId] = nil

    if (not unavailableDailyQuestsByNpc[npcId]) then
        unavailableDailyQuestsByNpc[npcId] = {}
    end
    unavailableDailyQuestsByNpc[npcId][questId] = true
end
