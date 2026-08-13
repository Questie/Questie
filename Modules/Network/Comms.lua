---@class Comms
local Comms = QuestieLoader:CreateModule("Comms")

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

---@class CommEvent
---@field eventName "HideDailyQuests"|"RequestUnavailableDailyQuests"
---@field data { npcId: NpcId, questIds: QuestId[] }|nil

local COMM_PREFIX = "Questie"

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

    local success, event = Questie:Deserialize(message)
    if (not success) or (type(event) ~= "table") then
        return
    end

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
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
        end

        AvailableQuests.RemoveQuestsForToday(npcId, questIds)
    elseif event.eventName == "RequestUnavailableDailyQuests" then
        -- A peer just logged in and is asking for unavailable daily quests.
        -- Schedule a response with random jitter so only one guild/party member actually replies.

        -- Reset tracked broadcasts for this new request
        wipe(broadcastedQuestIds)

        if pendingResponseTimer then
            pendingResponseTimer:Cancel()
            pendingResponseTimer = nil
        end

        pendingResponseTimer = C_Timer.NewTimer(math.random() * 5, function()
            pendingResponseTimer = nil

            local unavailableQuests = AvailableQuests.GetUnavailableDailyQuests()
            for npcId, questIds in pairs(unavailableQuests) do
                Comms.BroadcastUnavailableDailyQuests(npcId, questIds)
            end
        end)
    end
end

--- Sends a request to guild/group members asking them to share which daily quests are unavailable today.
--- Called once on login. A peer with known data will respond with HideDailyQuests messages.
function Comms.RequestUnavailableDailyQuests()
    local event = {eventName = "RequestUnavailableDailyQuests"}
    local serializedEvent = Questie:Serialize(event)

    if IsInGuild() then
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

    local serializedEvent = Questie:Serialize(event)
    if IsInGuild() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "GUILD")
    end

    if IsInRaid() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "RAID")
    elseif IsInGroup() then
        Questie:SendCommMessage(COMM_PREFIX, serializedEvent, "PARTY")
    end
end
