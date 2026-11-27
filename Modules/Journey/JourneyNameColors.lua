---The colors of names in the Journey, like the game shows them: NPCs by how they react to the player, and items by their
---quality. Objects have no faction, so they are gold like other names.
---@class JourneyNameColors
local JourneyNameColors = QuestieLoader:CreateModule("JourneyNameColors")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

-- The faction template of the NPCs that are friendly to everyone. Other NPCs that are friendly to both factions are neutral, like
-- beasts and the goblin towns. Which of those are friendly by the reputation of the player isn't known, so they stay neutral.
local FRIENDLY_TO_ALL = 35

---@param npcId NpcId
---@param name string
---@return string text The name in red, yellow or green
function JourneyNameColors.Npc(npcId, name)
    -- Nil when the NPC is hostile to both factions
    local friendlyTo = QuestieDB.QueryNPCSingle(npcId, "friendlyToFaction") or ""
    local ownFaction = QuestiePlayer.faction == "Horde" and "H" or "A"
    local color
    if not friendlyTo:find(ownFaction, 1, true) then
        color = RED_FONT_COLOR
    elseif friendlyTo == ownFaction or QuestieDB.QueryNPCSingle(npcId, "factionID") == FRIENDLY_TO_ALL then
        color = GREEN_FONT_COLOR
    else
        color = YELLOW_FONT_COLOR
    end
    return color:WrapTextInColorCode(name)
end

---@param name string
---@return string text
function JourneyNameColors.Object(name)
    return NORMAL_FONT_COLOR:WrapTextInColorCode(name)
end

---@param itemId ItemId
---@param name string
---@return string text The name in the color of the quality of the item. As it is while the client doesn't know the item yet.
function JourneyNameColors.Item(itemId, name)
    local _, _, quality = QuestieCompat.GetItemInfo(itemId)
    local qualityColor = quality and ITEM_QUALITY_COLORS[quality]
    return qualityColor and qualityColor.color:WrapTextInColorCode(name) or name
end

return JourneyNameColors
