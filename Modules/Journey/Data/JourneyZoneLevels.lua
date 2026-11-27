---The levels the quests of a zone have.
---
---They are read from the quests, because most clients don't know the levels of zones, and a list of them would have to be kept up
---to date for each.
---@class JourneyZoneLevels
local JourneyZoneLevels = QuestieLoader:CreateModule("JourneyZoneLevels")

---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- A zone's levels are the narrowest ones that this share of its quests have, so a few quests for much higher levels don't count.
-- With it, they are closest to the levels that are known for Classic's zones.
local SHARE = 0.75
local LEVELS_PER_BRACKET = 10

---@class JourneyZoneLevels.Levels
---@field low number
---@field high number

---@type table<AreaId, JourneyZoneLevels.Levels> Nil until they are read
local levelsByZone
local highestLevel = 0

---The quests there are lead through all levels, so they say nothing about where to go.
---@type table<AreaId, boolean>
local cities

---@return table<AreaId, boolean>
local function _GetCities()
    if not cities then
        cities = {}
        for _, name in ipairs({
            "STORMWIND_CITY", "IRONFORGE", "DARNASSUS", "THE_EXODAR", "ORGRIMMAR", "THUNDER_BLUFF", "UNDERCITY", "SILVERMOON_CITY",
            "SHATTRATH_CITY", "DALARAN", "SHRINE_OF_SEVEN_STARS", "SHRINE_OF_TWO_MOONS",
        }) do
            cities[ZoneDB.zoneIDs[name] or 0] = true
        end
    end
    return cities
end

---@param questLevels number[] Is sorted
---@return JourneyZoneLevels.Levels
local function _GetNarrowest(questLevels)
    table.sort(questLevels)
    local count = math.ceil(#questLevels * SHARE)
    local low, high = questLevels[1], questLevels[count]
    for first = 2, #questLevels - count + 1 do
        local last = first + count - 1
        if questLevels[last] - questLevels[first] < high - low then
            low, high = questLevels[first], questLevels[last]
        end
    end
    return {low = low, high = high}
end

---Goes through all quests, the first time it is called. Yields, so it runs in a thread.
---@async
function JourneyZoneLevels.Read()
    if levelsByZone then
        return
    end
    local questLevels = {}
    for questId in pairs(QuestieDB.QuestPointers) do
        JourneyThread.YieldIfNeeded()
        local zoneId = QuestieDB.QueryQuestSingle(questId, "zoneOrSort") or 0
        local level = QuestieDB.QueryQuestSingle(questId, "questLevel") or 0
        if zoneId > 0 and level > 0 and JourneyQuestCategories.IsListed(questId) then
            zoneId = ZoneDB:GetParentZoneId(zoneId) or zoneId
            questLevels[zoneId] = questLevels[zoneId] or {}
            table.insert(questLevels[zoneId], level)
        end
    end

    local levels = {}
    for zoneId, levelsOfZone in pairs(questLevels) do
        if not _GetCities()[zoneId] then
            levels[zoneId] = _GetNarrowest(levelsOfZone)
            highestLevel = math.max(highestLevel, levels[zoneId].high)
        end
    end
    levelsByZone = levels
end

---@param zoneId number
---@return JourneyZoneLevels.Levels? levels Nil for a city, for what isn't a zone, and until they are read
function JourneyZoneLevels.Get(zoneId)
    return levelsByZone and levelsByZone[zoneId]
end

---@param zoneId number
---@return boolean
function JourneyZoneLevels.IsCity(zoneId)
    return _GetCities()[zoneId] == true
end

---@param levels JourneyZoneLevels.Levels
---@return string
function JourneyZoneLevels.GetText(levels)
    return levels.low == levels.high and tostring(levels.low) or levels.low .. " - " .. levels.high
end

---@param levels JourneyZoneLevels.Levels
---@return boolean isOutgrown All of its quests are too low level to be worth it
function JourneyZoneLevels.IsOutgrown(levels)
    return UnitLevel("player") > levels.high and QuestieDB.IsTrivial(levels.high)
end

---How hard a zone is for the player, in the colors of quests: yellow within its levels, orange and red for higher ones, green for
---lower ones, and gray when it is outgrown.
---@param levels JourneyZoneLevels.Levels
---@return {r: number, g: number, b: number} color
function JourneyZoneLevels.GetColor(levels)
    local playerLevel = UnitLevel("player")
    local missing = levels.low - playerLevel
    local difficulty
    if missing > 0 then
        difficulty = missing >= 5 and "impossible" or missing >= 3 and "verydifficult" or "difficult"
    elseif playerLevel <= levels.high then
        difficulty = "difficult"
    else
        difficulty = JourneyZoneLevels.IsOutgrown(levels) and "trivial" or "standard"
    end
    return QuestDifficultyColors[difficulty]
end

---Zones are put together in steps of ten levels.
---@param levels JourneyZoneLevels.Levels
---@return JourneyZoneLevels.Levels bracket
function JourneyZoneLevels.GetBracket(levels)
    local index = math.min(math.floor(levels.low / LEVELS_PER_BRACKET), math.floor((highestLevel - 1) / LEVELS_PER_BRACKET))
    return {
        low = math.max(1, index * LEVELS_PER_BRACKET),
        high = math.min(highestLevel, (index + 1) * LEVELS_PER_BRACKET),
    }
end

---@param bracket JourneyZoneLevels.Levels
---@return string
function JourneyZoneLevels.GetBracketTitle(bracket)
    return l10n("Level %s", JourneyZoneLevels.GetText(bracket))
end

return JourneyZoneLevels
