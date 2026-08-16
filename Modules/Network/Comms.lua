---@class Comms
local Comms = QuestieLoader:CreateModule("Comms")

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type CommsEncoding
local CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")

---@class HideDailyQuestsEvent
---@field eventName "HideDailyQuests"
---@field data { npcId: NpcId, questIds: QuestId[] }

---@class RequestUnavailableDailyQuestsEvent
---@field eventName "RequestUnavailableDailyQuests"
---@field data table<NpcId, QuestId[]>

---@alias CommEvent HideDailyQuestsEvent|RequestUnavailableDailyQuestsEvent

local COMM_PREFIX = "QuestieDailies"

local playerName
local realmName

--- A pending timer handle for responding to a RequestUnavailableDailyQuests event.
--- Cancelled if we see a peer already responding with HideDailyQuests.
---@type Ticker|nil
local pendingResponseTimer

--- Tracks quest IDs already broadcast in response to the current RequestUnavailableDailyQuests.
--- Used to determine if our local data has additional quests not yet covered by peers.
--- Reset when a new request arrives.
---@type table<QuestId, boolean>
local broadcastedQuestIds = {}

function Comms.Initialize()
    if (not CommsEncoding.hasCodecSupport) then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[Comms] Codec support unavailable, not registering QuestieDailies")
        return
    end

    Questie:RegisterComm(COMM_PREFIX, Comms.OnCommReceived)

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
function Comms.OnCommReceived(prefix, message, distribution, sender)
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

    Questie.Debug(Questie.DEBUG_DEVELOP, "[Comms.OnCommReceived] Received", event.eventName, "from", sender)

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

        -- Track the quest IDs this peer is broadcasting
        for _, questId in ipairs(questIds) do
            broadcastedQuestIds[questId] = true
        end

        -- Cancel our pending response only if we don't know of any additional quests
        if pendingResponseTimer and (not _HasUncoveredQuests()) then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[Comms.OnCommReceived] Nothing new to broadcast")
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
        end

        AvailableQuests.RemoveQuestsForToday(npcId, questIds)
    elseif event.eventName == "RequestUnavailableDailyQuests" then
        -- A peer just logged in and is asking for unavailable daily quests.
        -- Only respond if we have NPC data they don't know about.

        local eventData = event.data
        if (not eventData) or type(eventData) ~= "table" then
            return
        end

        -- Integrate sender's NPC data for NPCs the receiver doesn't already know about
        local localData = AvailableQuests.GetUnavailableDailyQuests()
        for npcId, questIds in pairs(event.data) do
            if (not localData[npcId]) then
                AvailableQuests.RemoveQuestsForToday(npcId, questIds)
            end
        end

        -- Reset tracked broadcasts for this new request
        wipe(broadcastedQuestIds)

        if pendingResponseTimer then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[Comms.OnCommReceived] Cancelling pending response timer")
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
        end

        -- Only schedule a response if we have NPCs the sender doesn't know about
        if _HasNewNpcData(event.data) then
            -- We will answer somewhere between 0 and 8 seconds, unless we see another peer respond first.
            pendingResponseTimer = C_Timer.NewTimer(math.random() * 8, function()
                pendingResponseTimer = nil

                local unavailableQuests = AvailableQuests.GetUnavailableDailyQuests()
                for npcId, questIds in pairs(unavailableQuests) do
                    Comms.BroadcastUnavailableDailyQuests(npcId, questIds)
                end
            end)
        end
    end
end

--- Sends a request to guild/group members asking them to share which daily quests are unavailable today.
--- The event includes the quests the sender already knows, so receivers can decide if they have additional data.
--- Called once on login and when joining a group. A peer with known data will respond with HideDailyQuests messages.
---@param askGuild boolean @True asks guild members too, false only asks the current party/raid.
function Comms.RequestUnavailableDailyQuests(askGuild)
    local event = {
        eventName = "RequestUnavailableDailyQuests",
        data = AvailableQuests.GetUnavailableDailyQuests(),
    }
    local serializedEvent = CommsEncoding:EncodePayload(event)
    if (not serializedEvent) then
        return
    end

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
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
function Comms.BroadcastUnavailableDailyQuests(npcId, questIds)
    ---@type CommEvent
    local event = {
        eventName = "HideDailyQuests",
        data = {
            npcId = npcId,
            questIds = questIds
        }
    }

    Questie.Debug(Questie.DEBUG_DEVELOP, "[Comms.BroadcastUnavailableDailyQuests] Sending for NPC", npcId, "Quest IDs:", table.concat(questIds, ", "))

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
