---@class Comms
local Comms = QuestieLoader:CreateModule("Comms")

---@class CommEvent
---@field eventName "HideDailyQuests"
---@field data { npcId: NpcId, questIds: QuestId[] }

local playerName = UnitName("player")
local realmName = GetRealmName()

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

function Comms.Initialize()
    Questie:RegisterComm("Questie", Comms.OnCommReceived)
end

---@param prefix string @The prefix of the received message.
---@param message string @The content of the received message.
---@param distribution string @The distribution method of the message.
---@param sender string @The sender of the message.
function Comms.OnCommReceived(prefix, message, distribution, sender)
    if sender == playerName or sender == (playerName .. "-" .. realmName) then
        return
    end

    local event = Questie:Deserialize(message)

    if event.eventName == "HideDailyQuests" then
        local npcId = event.data.npcId
        local questIds = event.data.questIds
        Comms.OnHideDailyQuests(npcId, questIds)
    end
end

---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
function Comms.OnHideDailyQuests(npcId, questIds)
    AvailableQuests.RemoveQuestsForToday(npcId, questIds)
end

---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
function Comms.BroadcastUnavailableDailyQuests(npcId, questIds)

end

return Comms
