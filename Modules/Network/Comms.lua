---@class Comms
local Comms = QuestieLoader:CreateModule("Comms")

---@class CommEvent
---@field eventName "HideDailyQuests"
---@field data { npcId: NpcId, questIds: QuestId[] }

local COMM_PREFIX = "Questie"

local playerName
local realmName

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

function Comms.Initialize()
    Questie:RegisterComm(COMM_PREFIX, Comms.OnCommReceived)

    playerName = UnitName("player")
    realmName = GetRealmName()
end

---@param prefix string @The prefix of the received message.
---@param message string @The content of the received message.
---@param distribution string @The distribution method of the message.
---@param sender string @The sender of the message.
function Comms.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX then
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
        local npcId = event.data.npcId
        if (not npcId) then
            return
        end

        local questIds = event.data.questIds
        if (not questIds) or type(questIds) ~= "table" then
            return
        end

        AvailableQuests.RemoveQuestsForToday(npcId, questIds)
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

return Comms
