---@class Comms
local Comms = QuestieLoader:CreateModule("Comms")

---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

---@param npcId NpcId @The ID of the NPC associated with the daily quests.
---@param questIds QuestId[] @An array of quest IDs that need to be hidden.
function Comms.OnHideDailyQuests(npcId, questIds)
    AvailableQuests.RemoveQuestsForToday(npcId, questIds)
end

return Comms
