---@class JourneyPrerequisites
local JourneyPrerequisites = QuestieLoader:CreateModule("JourneyPrerequisites")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

local OTHER_FACTION = {Alliance = "Horde", Horde = "Alliance"}

---@param requiredRaces number @Race mask
---@param factionRaces number @Race mask
---@return boolean
local function _HasAnyRaceOf(requiredRaces, factionRaces)
    for _, raceMask in pairs(LibQuestieDB.Enum.raceMaskById) do
        -- Arithmetic preserves Skyborne bits above the range of 32-bit bitwise operations.
        if (requiredRaces % (2 * raceMask)) >= raceMask and (factionRaces % (2 * raceMask)) >= raceMask then
            return true
        end
    end
    return false
end

---@param requiredRaces number? @Race mask, nil or 0 for all races
---@return string? faction @"Alliance" or "Horde", nil when both or neither of the factions' races are required
local function _GetOnlyFaction(requiredRaces)
    if not requiredRaces then
        return nil
    end

    local isForAlliance = _HasAnyRaceOf(requiredRaces, QuestieDB.raceKeys.ALL_ALLIANCE)
    local isForHorde = _HasAnyRaceOf(requiredRaces, QuestieDB.raceKeys.ALL_HORDE)
    if isForAlliance == isForHorde then
        return nil
    end
    return isForAlliance and "Alliance" or "Horde"
end

---Returns which of the quests to show, of which a quest requires only one. QuestieDB lists every version of a prerequisite,
---so this leaves out those only the other faction has access to. A quest for both factions goes by the player's faction.
---
---Only meant for display: race masks are wrong for some quests. All are returned when the masks would hide every one.
---@param requiredRaces number? @Race mask of the quest that requires them, nil or 0 for all races
---@param preQuestSingle QuestId[]
---@return QuestId[]
function JourneyPrerequisites.GetShown(requiredRaces, preQuestSingle)
    local otherFaction = OTHER_FACTION[_GetOnlyFaction(requiredRaces) or QuestiePlayer.faction]
    if not otherFaction then
        -- Neutral Pandaren can still become either
        return preQuestSingle
    end

    local shown = {}
    for _, preQuestId in ipairs(preQuestSingle) do
        if _GetOnlyFaction(QuestieDB.QueryQuestSingle(preQuestId, "requiredRaces")) ~= otherFaction then
            shown[#shown + 1] = preQuestId
        end
    end

    return next(shown) and shown or preQuestSingle
end

return JourneyPrerequisites
