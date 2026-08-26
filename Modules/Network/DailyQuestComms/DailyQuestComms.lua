---@class DailyQuestComms
local DailyQuestComms = QuestieLoader:CreateModule("DailyQuestComms")

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type CommsEncoding
local CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
---@type DailyQuestCommsBlacklist
local DailyQuestCommsBlacklist = QuestieLoader:ImportModule("DailyQuestCommsBlacklist")

---@class AvailableDailyQuestsEvent
---@field eventName "AvailableDailyQuests"
---@field data { npcId: NpcId, questIds: QuestId[] }

---@class RequestAvailableDailyQuestsEvent
---@field eventName "RequestAvailableDailyQuests"
---@field data table<NpcId, QuestId[]>

---@alias CommEvent AvailableDailyQuestsEvent|RequestAvailableDailyQuestsEvent

local COMM_PREFIX = "QuestieDailiesV3"

local playerName
local realmName

--- A pending timer handle for responding to a RequestAvailableDailyQuests event.
--- Cancelled if we see a peer already responding with AvailableDailyQuests.
---@type Ticker|nil
local pendingResponseTimer

--- Tracks quest IDs already broadcast in response to the current RequestAvailableDailyQuests.
--- Used to determine if our local data has additional quests not yet covered by peers.
--- Reset when a new request arrives.
---@type table<QuestId, boolean>
local broadcastedQuestIds = {}

function DailyQuestComms.Initialize()
    if (not CommsEncoding.hasCodecSupport) then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms] Codec support unavailable, not registering QuestieDailies")
        return
    end

    Questie:RegisterComm(COMM_PREFIX, DailyQuestComms.OnCommReceived)

    playerName = UnitName("player")
    realmName = GetRealmName()
end

--- Checks if our local available quest data contains any quests not yet broadcast to the requester.
---@return boolean True if we know of additional quests beyond what peers have broadcast.
local function _HasUncoveredQuests()
    local availableQuests = AvailableQuests.GetAvailableDailyQuests()
    for _, questIds in pairs(availableQuests) do
        for _, questId in ipairs(questIds) do
            if (not broadcastedQuestIds[questId]) then
                return true
            end
        end
    end
    return false
end

--- Checks if our local available quest data includes any NPCs not in sender's knowledge.
--- We only need to check NPCs, because NPCs can't have different quests active for different players (
---@param senderData table<NpcId, QuestId[]> The sender's available quest data from the request event.
---@return boolean True if we have additional NPCs the sender doesn't know about.
local function _HasNewNpcData(senderData)
    local localData = AvailableQuests.GetAvailableDailyQuests()
    for npcId in pairs(localData) do
        if (not senderData[npcId]) then
            return true
        end
    end
    return false
end

---@param prefix string @The prefix of the received message.
---@param message string @The content of the received message.
---@param distribution string @The distribution method of the message.
---@param sender string @The sender of the message.
function DailyQuestComms.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX then
        return
    end

    if distribution ~= "GUILD" and distribution ~= "RAID" and distribution ~= "PARTY" then
        return
    end

    if sender == playerName or sender == (playerName .. "-" .. realmName) then
        return
    end

    local event = CommsEncoding:DecodePayload(message)
    if (not event) or (type(event) ~= "table") then
        return
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.OnCommReceived] Received", event.eventName, "from", sender)

    if event.eventName == "AvailableDailyQuests" and event.data and type(event.data) == "table" then
        -- A peer is broadcasting available quests.
        local npcId = event.data.npcId
        if (not npcId) then
            return
        end

        local questIds = event.data.questIds
        if (not questIds) or type(questIds) ~= "table" then
            return
        end

        -- User with an outdated version might send incorrect data, so we filter according to our version
        local filteredQuestIds = DailyQuestCommsBlacklist.FilterQuestIds(questIds)

        if #filteredQuestIds == 0 then
            return
        end

        -- Track the quest IDs this peer is broadcasting
        for _, questId in ipairs(filteredQuestIds) do
            broadcastedQuestIds[questId] = true
        end

        -- Cancel our pending response only if we don't know of any additional quests
        if pendingResponseTimer and (not _HasUncoveredQuests()) then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.OnCommReceived] Nothing new to broadcast")
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
        end

        -- Show the received available quests and hide exclusiveTo
        AvailableQuests.MarkQuestsAsAvailable(npcId, filteredQuestIds)
    elseif event.eventName == "RequestAvailableDailyQuests" then
        -- A peer just logged in and is asking for available daily quests.
        -- The event data contains the quests the sender knows are available.
        -- For NPCs we don't know about yet, we accept their available quests.

        local eventData = event.data
        if (not eventData) or type(eventData) ~= "table" then
            return
        end

        -- Get our local available daily quests
        local localAvailableData = AvailableQuests.GetAvailableDailyQuests()

        -- Check the sender's NPC data for NPCs the receiver doesn't already know about.
        -- We want to show the data received and hide exclusiveTo quests.
        for npcId, senderAvailableQuestIds in pairs(eventData) do
            -- Check if we already have this NPC in our available quests
            if (not localAvailableData[npcId]) and type(senderAvailableQuestIds) == "table" then
                -- We don't know this NPC yet, so we accept the sender's available quests
                -- User with an outdated version might send incorrect data, so we filter according to our version
                local filteredQuestIds = DailyQuestCommsBlacklist.FilterQuestIds(senderAvailableQuestIds)
                if #filteredQuestIds > 0 then
                    -- Mark these quests as available for this NPC
                    AvailableQuests.MarkQuestsAsAvailable(npcId, filteredQuestIds)
                end
            end
        end

        -- Reset tracked broadcasts for this new request
        wipe(broadcastedQuestIds)

        if pendingResponseTimer then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.OnCommReceived] Cancelling pending response timer")
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
        end

        -- Only schedule a response if we have NPCs the sender doesn't know about
        if _HasNewNpcData(event.data) then
            -- We will answer somewhere between 0 and 8 seconds, unless we see another peer respond first.
            -- The answer goes only back to the channel the request arrived on.
            -- Capture distribution in a local variable to avoid stale reads if a new request arrives before timer fires.
            local pendingResponseDistribution = distribution
            pendingResponseTimer = C_Timer.NewTimer(math.random() * 8, function()
                pendingResponseTimer = nil

                local availableQuests = AvailableQuests.GetAvailableDailyQuests()
                for npcId, questIds in pairs(availableQuests) do
                    DailyQuestComms.AnswerAvailableDailyQuests(npcId, questIds, pendingResponseDistribution)
                end
            end)
        end
    end
end

--- Sends a request to guild/group members asking them to share which daily quests are available today.
--- The event includes the quests the sender already knows, so receivers can decide if they have additional data.
--- Called once on login and when joining a group. A peer with known data will respond with AvailableDailyQuests messages.
---@param askGuild boolean @True asks guild members too, false only asks the current party/raid.
function DailyQuestComms.RequestAvailableDailyQuests(askGuild)
    local event = {
        eventName = "RequestAvailableDailyQuests",
        data = AvailableQuests.GetAvailableDailyQuests(),
    }
    local serializedEvent = CommsEncoding:EncodePayload(event)
    if (not serializedEvent) then
        return
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.RequestAvailableDailyQuests] askGuild", askGuild)

    if askGuild and IsInGuild() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "GUILD")
    end

    if IsInRaid() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "RAID")
    elseif IsInGroup() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "PARTY")
    end
end

---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that are available.
function DailyQuestComms.BroadcastAvailableDailyQuests(npcId, questIds)
    ---@type CommEvent
    local event = {
        eventName = "AvailableDailyQuests",
        data = {
            npcId = npcId,
            questIds = questIds
        }
    }

    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.BroadcastAvailableDailyQuests] Sending for NPC", npcId, "Quest IDs:", table.concat(questIds, ", "))

    local serializedEvent = CommsEncoding:EncodePayload(event)
    if (not serializedEvent) then
        return
    end

    if IsInGuild() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "GUILD")
    end

    if IsInRaid() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "RAID")
    elseif IsInGroup() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "PARTY")
    end
end

--- Sends a AvailableDailyQuests answer back only on the distribution the request arrived on.
---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that are available.
---@param distribution string @The distribution the request was received on.
function DailyQuestComms.AnswerAvailableDailyQuests(npcId, questIds, distribution)
    ---@type CommEvent
    local event = {
        eventName = "AvailableDailyQuests",
        data = {
            npcId = npcId,
            questIds = questIds
        }
    }

    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.AnswerAvailableDailyQuests] Sending for NPC", npcId, "Quest IDs:", table.concat(questIds, ", "))

    local serializedEvent = CommsEncoding:EncodePayload(event)
    if (not serializedEvent) then
        return
    end

    Questie:SendCommMessage(COMM_PREFIX, serializedEvent, distribution)
end
