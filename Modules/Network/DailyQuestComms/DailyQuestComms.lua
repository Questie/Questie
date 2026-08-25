---@class DailyQuestComms
local DailyQuestComms = QuestieLoader:CreateModule("DailyQuestComms")

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type CommsEncoding
local CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
---@type DailyQuestCommsBlacklist
local DailyQuestCommsBlacklist = QuestieLoader:ImportModule("DailyQuestCommsBlacklist")

---@class HideDailyQuestsEvent
---@field eventName "HideDailyQuests"
---@field data { npcId: NpcId, questIds: QuestId[] }

---@class RequestUnavailableDailyQuestsEvent
---@field eventName "RequestUnavailableDailyQuests"
---@field data table<NpcId, QuestId[]>

---@alias CommEvent HideDailyQuestsEvent|RequestUnavailableDailyQuestsEvent

local COMM_PREFIX = "QuestieDailiesV2"

local playerName
local realmName

--- A pending timer handle for responding to a RequestUnavailableDailyQuests event.
--- Cancelled if we see a peer already responding with HideDailyQuests.
---@type Ticker|nil
local pendingResponseTimer

--- The distribution the pending response was requested on, so the answer only goes back to that channel.
---@type string?
local pendingResponseDistribution

--- Tracks quest IDs already broadcast in response to the current RequestUnavailableDailyQuests.
--- Used to determine if our local data has additional quests not yet covered by peers.
--- Reset when a new request arrives.
---@type table<QuestId, boolean>
local broadcastedQuestIds = {}

function DailyQuestComms.Initialize()
    if (not CommsEncoding.hasCodecSupport) then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms] Codec support unavailable, not registering QuestieDailies")
        return
    end

    -- TODO: Re-enable once we fixed the daily quest comms problems
    -- Questie:RegisterComm(COMM_PREFIX, DailyQuestComms.OnCommReceived)

    playerName = UnitName("player")
    realmName = GetRealmName()
end

--- Checks if our local unavailable quest data contains any quests not yet broadcast to the requester.
---@return boolean True if we know of additional quests beyond what peers have broadcast.
local function _HasUncoveredQuests()
    local unavailableQuests = AvailableQuests.GetUnavailableDailyQuests()
    for _, questIds in pairs(unavailableQuests) do
        for _, questId in ipairs(questIds) do
            if (not broadcastedQuestIds[questId]) then
                return true
            end
        end
    end
    return false
end

--- Checks if our local unavailable quest data includes any NPCs not in sender's knowledge.
--- We only need to check NPCs, because NPCs can't have different quests active for different players (
---@param senderData table<NpcId, QuestId[]> The sender's unavailable quest data from the request event.
---@return boolean True if we have additional NPCs the sender doesn't know about.
local function _HasNewNpcData(senderData)
    local localData = AvailableQuests.GetUnavailableDailyQuests()
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

    if event.eventName == "HideDailyQuests" and event.data and type(event.data) == "table" then
        -- A peer is broadcasting unavailable quests.
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
            pendingResponseDistribution = nil
        end

        -- Only process NPC data once, like RequestUnavailableDailyQuests
        local localData = AvailableQuests.GetUnavailableDailyQuests()
        if (not localData[npcId]) then
            AvailableQuests.RemoveQuestsForToday(npcId, filteredQuestIds)
        end
    elseif event.eventName == "RequestUnavailableDailyQuests" then
        -- A peer just logged in and is asking for unavailable daily quests.
        -- Only respond if we have NPC data they don't know about.

        local eventData = event.data
        if (not eventData) or type(eventData) ~= "table" then
            return
        end

        -- Integrate sender's NPC data for NPCs the receiver doesn't already know about
        local localData = AvailableQuests.GetUnavailableDailyQuests()
        for npcId, questIds in pairs(eventData) do
            if (not localData[npcId]) and type(questIds) == "table" then
                -- User with an outdated version might send incorrect data, so we filter according to our version
                local filteredQuestIds = DailyQuestCommsBlacklist.FilterQuestIds(questIds)
                if #filteredQuestIds > 0 then
                    AvailableQuests.RemoveQuestsForToday(npcId, filteredQuestIds)
                end
            end
        end

        -- Reset tracked broadcasts for this new request
        wipe(broadcastedQuestIds)

        if pendingResponseTimer then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.OnCommReceived] Cancelling pending response timer")
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
            pendingResponseDistribution = nil
        end

        -- Only schedule a response if we have NPCs the sender doesn't know about
        if _HasNewNpcData(event.data) then
            -- We will answer somewhere between 0 and 8 seconds, unless we see another peer respond first.
            -- The answer goes only back to the channel the request arrived on.
            pendingResponseDistribution = distribution
            pendingResponseTimer = C_Timer.NewTimer(math.random() * 8, function()
                pendingResponseTimer = nil

                local unavailableQuests = AvailableQuests.GetUnavailableDailyQuests()
                for npcId, questIds in pairs(unavailableQuests) do
                    DailyQuestComms.AnswerUnavailableDailyQuests(npcId, questIds, pendingResponseDistribution)
                end
                pendingResponseDistribution = nil
            end)
        end
    end
end

--- Sends a request to guild/group members asking them to share which daily quests are unavailable today.
--- The event includes the quests the sender already knows, so receivers can decide if they have additional data.
--- Called once on login and when joining a group. A peer with known data will respond with HideDailyQuests messages.
---@param askGuild boolean @True asks guild members too, false only asks the current party/raid.
function DailyQuestComms.RequestUnavailableDailyQuests(askGuild)
    -- TODO: Re-enable once we fixed the daily quest comms problems
    --    local event = {
    --        eventName = "RequestUnavailableDailyQuests",
    --        data = AvailableQuests.GetUnavailableDailyQuests(),
    --    }
    --    local serializedEvent = CommsEncoding:EncodePayload(event)
    --    if (not serializedEvent) then
    --        return
    --    end
    --
    --    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.RequestUnavailableDailyQuests] askGuild", askGuild)
    --
    --    if askGuild and IsInGuild() then
    --        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "GUILD")
    --    end
    --
    --    if IsInRaid() then
    --        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "RAID")
    --    elseif IsInGroup() then
    --        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "PARTY")
    --    end
end

---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
function DailyQuestComms.BroadcastUnavailableDailyQuests(npcId, questIds)
    -- TODO: Re-enable once we fixed the daily quest comms problems
    --    ---@type CommEvent
    --    local event = {
    --        eventName = "HideDailyQuests",
    --        data = {
    --            npcId = npcId,
    --            questIds = questIds
    --        }
    --    }
    --
    --    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.BroadcastUnavailableDailyQuests] Sending for NPC", npcId, "Quest IDs:", table.concat(questIds, ", "))
    --
    --    local serializedEvent = CommsEncoding:EncodePayload(event)
    --    if (not serializedEvent) then
    --        return
    --    end
    --
    --    if IsInGuild() then
    --        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "GUILD")
    --    end
    --
    --    if IsInRaid() then
    --        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "RAID")
    --    elseif IsInGroup() then
    --        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "PARTY")
    --    end
end

--- Sends a HideDailyQuests answer back only on the distribution the request arrived on.
--- Unlike BroadcastUnavailableDailyQuests, this never touches the guild unless the request came via GUILD.
---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
---@param distribution string @The distribution the request was received on.
function DailyQuestComms.AnswerUnavailableDailyQuests(npcId, questIds, distribution)
    -- TODO: Re-enable once we fixed the daily quest comms problems
    --    ---@type CommEvent
    --    local event = {
    --        eventName = "HideDailyQuests",
    --        data = {
    --            npcId = npcId,
    --            questIds = questIds
    --        }
    --    }
    --
    --    Questie.Debug(Questie.DEBUG_DEVELOP, "[DailyQuestComms.AnswerUnavailableDailyQuests] Sending for NPC", npcId, "Quest IDs:", table.concat(questIds, ", "))
    --
    --    local serializedEvent = CommsEncoding:EncodePayload(event)
    --    if (not serializedEvent) then
    --        return
    --    end
    --
    --    Questie:SendCommMessage(COMM_PREFIX, serializedEvent, distribution)
end
