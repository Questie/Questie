---Objective colors: one per objective, picked on first use so it stays visible in the zone where the player works
---on the objective and stands apart from the other objectives there, then saved for good. docs/objective-colors.md
---explains the problem, how colors are measured and the decisions behind the pick.
---@class ObjectiveColors
local ObjectiveColors = QuestieLoader:CreateModule("ObjectiveColors")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")

---@class ObjectiveColorRecord
---@field color string Palette color name.
---@field zone UiMapId? Primary zone the color was picked for; nil when the objective had none.
---@field real ObjectiveIndex? For a special objective tied to a real one: that objective, whose finishing hides it.

---@class ObjectiveColorBanData
---@field tocs string[] The TOCs that load this data; ObjectiveColors.test.lua checks them.
---@field measuredOpacity number[] Blob fill and border opacity when measured, checked against today's by the test.
---@field measuredColors table<string, integer[]> Each color's sRGB when measured, checked against the palette.
---@field byUiMapId table<UiMapId, string[]> Names of the colors too faint as blobs in that zone.

-- Palette
-- Colors are saved and banned by name, so this order only sets the rotation, and retiring (commenting out) or
-- adding an entry recolors no other color's objectives; those saved with a retired color get a new one.
-- Commented-out entries are retired: as blobs they are too faint to see on the
-- map or minimap in most zones, as measured by ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast. Names are the
-- legacy QuestieDev-Master ones; renaming one drops the saved colors and bans that use it.
local PALETTE = {
    {80, 113, 255, "Blizzard Polygon-blue"},
    -- {128, 120, 217, "Medium Purple"},
    {149, 229, 14, "Inch Worm"},
    -- {117, 218, 200, "Downy"},
    -- {255, 144, 160, "Salmon Pink"},
    {0, 166, 152, "Persian Green"},
    {0, 250, 140, "Spring Green"},
    {181, 28, 122, "Medium Violet Red"},
    {149, 55, 255, "Light Slate Blue"},
    -- {185, 94, 0, "Alloy Orange"},
    {218, 55, 147, "Deep Cerise"},
    -- {223, 224, 145, "Primrose"},
    -- {255, 167, 0, "Orange"},
    -- {208, 182, 255, "Mauve"},
    -- {0, 65, 151, "Smalt"},
    {255, 64, 255, "Pink Flamingo"},
    {254, 251, 0, "Yellow"},
    {255, 255, 255, "White"},
    {41, 167, 0, "Slimy Green"},
    {0, 169, 255, "Deep Sky Blue"},
    {0, 150, 0, "Vine Green"},
    {1, 74, 255, "Navy Blue"},
    {0, 249, 0, "Lime"},
    {0, 252, 255, "Aqua"},
    {255, 38, 0, "Scarlet"},
}

---@type Color[]
local colors = {}
---@type string[]
local names = {}
---@type table<string, integer>
local indexOf = {}
for index, entry in ipairs(PALETTE) do
    colors[index] = {entry[1] / 255, entry[2] / 255, entry[3] / 255}
    names[index] = entry[4]
    indexOf[entry[4]] = index
end

-- QuestieQuest numbers special objectives from 64 + their index, after the real objectives.
local SPECIAL_OBJECTIVE_OFFSET = 64

-- Perceived distance between palette colors: OKLab, the space the contrast tool measures in, taken as the smallest
-- of normal vision, deuteranopia and protanopia (Machado 2009 simulations at full severity, in linear RGB), so colors
-- kept apart stay apart for colorblind players too.
local VISIONS = {
    {{1, 0, 0}, {0, 1, 0}, {0, 0, 1}},
    {{0.367322, 0.860646, -0.227968}, {0.280085, 0.672501, 0.047413}, {-0.011820, 0.042940, 0.968881}},
    {{0.152286, 1.052583, -0.204868}, {0.114503, 0.786281, 0.099216}, {-0.003882, -0.048116, 1.051998}},
}

local function _Linear(channel)
    if channel <= 0.04045 then
        return channel / 12.92
    end
    return ((channel + 0.055) / 1.055) ^ 2.4
end

---OKLab of a color as one kind of vision sees it.
local function _OkLab(color, vision)
    local linear = {_Linear(color[1]), _Linear(color[2]), _Linear(color[3])}
    local seen = {}
    for row = 1, 3 do
        local weights = vision[row]
        seen[row] = math.max(0, math.min(1, weights[1] * linear[1] + weights[2] * linear[2] + weights[3] * linear[3]))
    end
    local r, g, b = seen[1], seen[2], seen[3]
    local l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ^ (1 / 3)
    local m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ^ (1 / 3)
    local s = (0.0883024619 * r + 0.2817104295 * g + 0.6299870776 * b) ^ (1 / 3)
    return {0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
        1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
        0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s}
end

---@type table<integer, table<integer, number>>
local distance = {}
do
    local seen = {} -- seen[vision][palette index] = OKLab
    for v, vision in ipairs(VISIONS) do
        seen[v] = {}
        for index, color in ipairs(colors) do
            seen[v][index] = _OkLab(color, vision)
        end
    end
    for i in ipairs(colors) do
        distance[i] = {}
        for j in ipairs(colors) do
            local nearest = math.huge
            for v in ipairs(VISIONS) do
                local a, b = seen[v][i], seen[v][j]
                nearest = math.min(nearest, math.sqrt((a[1] - b[1]) ^ 2 + (a[2] - b[2]) ^ 2 + (a[3] - b[3]) ^ 2))
            end
            distance[i][j] = nearest
        end
    end
end

-- Like the legacy cursor, this restarts each session; saved colors never move.
local cursor = 1

---The palette in assignment order, for color previews.
---@return Color[] colors Shared entries; do not modify them.
---@return string[] names
function ObjectiveColors.GetPalette()
    return colors, names
end

-- Bans

---@type table<UiMapId, table<integer, true>>
local bansByUiMapId = {}

---Adds generated ban data (Modules/Quest/ObjectiveColorBans/*.lua); the TOC decides which apply, and data added
---twice for a zone combines. Bans name their colors, so a palette change cannot make them ban the wrong ones, and
---names no longer in the palette are skipped.
---@param data ObjectiveColorBanData
function ObjectiveColors.AddBans(data)
    for uiMapId, colorNames in pairs(data.byUiMapId) do
        local banned = bansByUiMapId[uiMapId] or {}
        for _, name in ipairs(colorNames) do
            if indexOf[name] then
                banned[indexOf[name]] = true
            end
        end
        bansByUiMapId[uiMapId] = banned
    end
end

-- Primary zone

---Where the player works on an objective: the first of the quest's zone, the nearest quest giver's zone, and the
---zone with the most spawns that holds the objective's spawns. Spawns in Durotar never outweigh Dun Morogh for a
---Dun Morogh quest. An objective without spawns gets the quest's zone, or none for a category quest.
---@param questId QuestId
---@param starts table? quest.Starts, for the quest giver fallback.
---@param spawnList table? objective.spawnList: spawn data with Spawns keyed by AreaId.
---@return UiMapId? primary
---@return UiMapId[] secondary The objective's other spawn zones.
function ObjectiveColors.PrimaryZone(questId, starts, spawnList)
    -- Every zone is normalized like the quest's zone, so sub-zones and alternative dungeon AreaIds count as theirs.
    local function normalized(areaId)
        return ZoneDB:GetParentZoneId(areaId) or areaId
    end

    local spawnsPerZone, hasSpawns = {}, false
    for _, spawnData in pairs(spawnList or {}) do
        for spawnArea, spawns in pairs(spawnData.Spawns or {}) do
            if #spawns > 0 then
                local areaId = normalized(spawnArea)
                spawnsPerZone[areaId] = (spawnsPerZone[areaId] or 0) + #spawns
                hasSpawns = true
            end
        end
    end

    local zoneOrSort = QuestieDB.QueryQuestSingle(questId, "zoneOrSort") or 0
    local questZone = zoneOrSort > 0 and normalized(zoneOrSort) or nil

    local primaryArea
    if not hasSpawns then
        primaryArea = questZone
    elseif questZone and spawnsPerZone[questZone] then
        primaryArea = questZone
    else
        local _, giverZone = DistanceUtils.GetNearestFinisherOrStarter(starts or {})
        giverZone = giverZone and normalized(giverZone)
        if giverZone and spawnsPerZone[giverZone] then
            primaryArea = giverZone
        else
            -- Ties go to the lowest AreaId, so the pick does not depend on table order.
            for areaId, count in pairs(spawnsPerZone) do
                local best = primaryArea and spawnsPerZone[primaryArea]
                if not best or count > best or (count == best and areaId < primaryArea) then
                    primaryArea = areaId
                end
            end
        end
    end

    local primary = primaryArea and ZoneDB:GetUiMapIdByAreaId(primaryArea)
    local secondary, seen = {}, {}
    for areaId in pairs(spawnsPerZone) do
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
        if uiMapId and uiMapId ~= primary and not seen[uiMapId] then
            seen[uiMapId] = true
            secondary[#secondary + 1] = uiMapId
        end
    end
    return primary, secondary
end

-- Picking

---The allowed color farthest from the colors in use. Ties go to the color used least, then to the color fewer
---secondary zones ban, then to the first at or after the cursor. With nothing in use every gap ties, which keeps
---the legacy rotation; with every color in use, colors repeat as rarely as possible.
---@param allowed integer[] Palette indexes the primary zone allows.
---@param used table<integer, integer> Palette index -> neighbors using it.
---@param secondaryBans table<integer, integer> Palette index -> secondary zones banning it.
---@return integer paletteIndex
local function _Pick(allowed, used, secondaryBans)
    local best, bestGap, bestUses, bestBans, bestStep
    for _, index in ipairs(allowed) do
        local gap = math.huge
        for usedIndex in pairs(used) do
            gap = math.min(gap, distance[index][usedIndex])
        end
        local uses, bans, step = used[index] or 0, secondaryBans[index] or 0, (index - cursor) % #colors
        local better = not best or gap > bestGap
            or (gap == bestGap and (uses < bestUses
                or (uses == bestUses and (bans < bestBans or (bans == bestBans and step < bestStep)))))
        if better then
            best, bestGap, bestUses, bestBans, bestStep = index, gap, uses, bans, step
        end
    end
    return best
end

local function _SavedColors()
    local saved = Questie.db.char.objectiveColors
    if not saved then
        saved = {}
        Questie.db.char.objectiveColors = saved
    end
    return saved
end

local function _IsRecord(record)
    return type(record) == "table" and indexOf[record.color] ~= nil
end

-- Saved colors outlive their quest, so an abandoned or repeated quest gets its colors back. A quest done for good
-- never returns, so its colors are dropped, once per session on the first pick. Repeatable, daily, weekly,
-- monthly and holiday quests do return, and a quest in the log keeps its colors whatever its flags say.
local pruned = false
local function _CanReturn(questId)
    return QuestieDB.IsRepeatable(questId) or QuestieDB.IsDailyQuest(questId) or QuestieDB.IsWeeklyQuest(questId)
        or QuestieDB.IsMonthlyQuest(questId) or QuestieEvent.IsEventQuest(questId)
end

local function _PruneFinishedQuests(saved)
    local complete = Questie.db.char.complete or {}
    local log = QuestLogCache.questLog_DO_NOT_MODIFY
    for questId in pairs(saved) do
        if complete[questId] and not log[questId] and not _CanReturn(questId) then
            saved[questId] = nil
        end
    end
end

---Whether a logged quest's objective still shows. Special objectives are not in the cache: one tied to a real
---objective hides once that one finishes, the others show until their quest completes.
local function _IsShowing(logQuest, objectiveIndex, record)
    local cacheIndex = objectiveIndex
    if objectiveIndex > SPECIAL_OBJECTIVE_OFFSET then
        if not record.real then
            return logQuest.isComplete ~= 1
        end
        cacheIndex = record.real
    end
    local logObjective = logQuest.objectives and logQuest.objectives[cacheIndex]
    return logObjective ~= nil and not logObjective.finished
end

---Colors of the objectives the player works on in a zone: saved for that primary zone, their quest in the log, and
---not finished. The log comes from QuestLogCache, which holds every quest before the login pass draws any, so
---objectives drawn later in that pass still count. The objective's own quest always counts: a freshly accepted
---quest may not have reached the cache yet.
---@return table<integer, integer> used Palette index -> neighbors using it.
local function _NeighborColors(zone, questId)
    local used = {}
    if not zone then
        return used
    end
    local saved = _SavedColors()
    local log = QuestLogCache.questLog_DO_NOT_MODIFY

    local function count(logQuestId, logQuest)
        for index, record in pairs(saved[logQuestId] or {}) do
            if type(index) == "number" and _IsRecord(record) and record.zone == zone
                and (not logQuest or _IsShowing(logQuest, index, record)) then
                local colorIndex = indexOf[record.color]
                used[colorIndex] = (used[colorIndex] or 0) + 1
            end
        end
    end

    for logQuestId, logQuest in pairs(log) do
        if logQuestId ~= questId then
            count(logQuestId, logQuest)
        end
    end
    count(questId, log[questId])
    return used
end

-- Colors of party members' objectives, for this session only. Those quests are not in the player's log, so their
-- colors never count as anyone's neighbors; saving one would let the player's later picks collide with it. The
-- player's own pick happens on accepting the quest.
---@type table<QuestId, table<ObjectiveIndex, integer>>
local partyColors = {}

---Returns the objective's color, picking one on first use and saving it per character in
---Questie.db.char.objectiveColors[questId][objectiveIndex]. Saved colors never change, so accepting or abandoning
---quests never recolors the map, and a returning objective gets its color back. Party members' objectives use a
---saved color when there is one, and otherwise keep their pick for the session without saving it.
---@param quest Quest
---@param objective table Its spawnList places it, so build that first.
---@param objectiveIndex ObjectiveIndex Canonical objective.Index; special objectives use their own index, not 0.
---@return Color color Shared palette entry; do not modify it.
function ObjectiveColors.Get(quest, objective, objectiveIndex)
    local saved = _SavedColors()
    if not pruned then
        pruned = true
        _PruneFinishedQuests(saved)
    end
    local questColors = saved[quest.Id]
    local record = questColors and questColors[objectiveIndex]
    if _IsRecord(record) then
        return colors[indexOf[record.color]]
    end
    local isParty = objective.IsPartyObjective == true
    local partyPick = isParty and partyColors[quest.Id] and partyColors[quest.Id][objectiveIndex]
    if partyPick then
        return colors[partyPick]
    end

    -- Missing or invalid entries (retired or renamed colors, other types) get a new pick.
    local primary, secondary = ObjectiveColors.PrimaryZone(quest.Id, quest.Starts, objective.spawnList)
    local banned = primary and bansByUiMapId[primary] or {}
    local allowed = {}
    for index in ipairs(colors) do
        if not banned[index] then
            allowed[#allowed + 1] = index
        end
    end
    if #allowed == 0 then -- a zone banning every color still gets one
        for index in ipairs(colors) do
            allowed[index] = index
        end
    end
    local secondaryBans = {}
    for _, uiMapId in ipairs(secondary) do
        for index in pairs(bansByUiMapId[uiMapId] or {}) do
            secondaryBans[index] = (secondaryBans[index] or 0) + 1
        end
    end

    local index = _Pick(allowed, _NeighborColors(primary, quest.Id), secondaryBans)
    cursor = index % #colors + 1
    if isParty then
        partyColors[quest.Id] = partyColors[quest.Id] or {}
        partyColors[quest.Id][objectiveIndex] = index
        return colors[index]
    end

    -- A special objective follows a real one only when that objective exists, as PopulateQuestLogInfo links them;
    -- most special objectives carry RealObjectiveIndex 0 and show until their quest completes.
    local real = objective.RealObjectiveIndex
    if not (real and quest.Objectives and quest.Objectives[real]) then
        real = nil
    end
    if not questColors then
        questColors = {}
        saved[quest.Id] = questColors
    end
    questColors[objectiveIndex] = {color = names[index], zone = primary, real = real}
    return colors[index]
end
