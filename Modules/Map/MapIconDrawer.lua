---@class MapIconDrawer
local MapIconDrawer = QuestieLoader:CreateModule("MapIconDrawer")

-------------------------
--Import modules.
-------------------------
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

local tinsert = table.insert
local coYield = coroutine.yield

-- this variable defines how many operations to run (batched at a time) before yielding for a frame.
-- 1 would mean yielding every operation (so lower = slower but less lag)
-- this variable is not a hard limit when invoked, but rather a guideline;
-- each code block may put a modifier on it, for instance 10x  if the loop is lightweight
local TICKS_PER_YIELD = 60

if Questie.IsHardcore then
    -- The addon timing restrictions from the Blizzard watchdog are much higher for HC servers.
    -- Therefore we need a quite low tick rate to make sure we don't get bitten on less performant machines.
    TICKS_PER_YIELD = 30
end

--- Tracks per-quest draw state to make draw/unload ordering deterministic.
--- "UNLOADING" means an unload has been requested; pending draws for that quest must be suppressed.
--- nil means no active state (quest can be drawn freely).
---@type table<QuestId, "UNLOADING">
local _questState = {}

---@param icons table  keyed by distance (number), value is array of drawIcon entries
---@return number iconCount
---@return table  orderedList
local function _GetIconsSortedByDistance(icons)
    local iconCount = 0
    local orderedList = {}
    local distances = {}

    local i = 0
    for distance in pairs(icons) do
        i = i + 1
        distances[i] = distance
    end

    table.sort(distances)

    for distIndex = 1, #distances do
        local iconsAtDistance = icons[distances[distIndex]]
        for iconIndex = 1, #iconsAtDistance do
            iconCount = iconCount + 1
            orderedList[iconCount] = iconsAtDistance[iconIndex]
        end
    end

    return iconCount, orderedList
end

---@param coords table  {x, y} in zone-local coordinates
---@param placed table  array of {x, y} coords already placed in this zone
---@return boolean
local function _HasProperDistanceToAlreadyPlacedObjectives(coords, placed)
    local minDist = Questie.db.profile.objectiveFilterDistance
    if minDist == 0 then
        return true
    end
    for _, placedCoords in ipairs(placed) do
        if QuestieLib.GetSpawnDistance(coords, placedCoords) < minDist then
            return false
        end
    end
    return true
end

--- Unloads all map and minimap frames for an objective and resets AlreadySpawned.
---@param objective QuestObjective
function MapIconDrawer:UnloadObjective(objective)
    if (not next(objective.spawnList)) then
        return
    end

    for id, _ in pairs(objective.spawnList) do
        local spawn = objective.AlreadySpawned[id]
        if spawn then
            for _, mapIcon in pairs(spawn.mapRefs) do
                QuestieFramePool:UnloadFrame(mapIcon)
            end
            for _, minimapIcon in pairs(spawn.minimapRefs) do
                QuestieFramePool:UnloadFrame(minimapIcon)
            end
            spawn.mapRefs = {}
            spawn.minimapRefs = {}
        end
    end

    objective.AlreadySpawned = {}
end

--- Requests an unload of ALL map frames for a quest (objectives, starter, finisher, waypoints, etc).
--- Sets the UNLOADING guard to block any stale objective draws during the unload window.
--- Safe to call outside a coroutine.
---@param questId QuestId
---@param onComplete function? Optional callback invoked after the unload coroutine finishes.
function MapIconDrawer:UnloadQuest(questId, onComplete)
    Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:UnloadQuest] Unloading all frames for:", questId)

    _questState[questId] = "UNLOADING"

    ThreadLib.ThreadCallbackInstant(function()
        QuestieMap:UnloadAllQuestFrames(questId)
    end, function()
        _questState[questId] = nil
        if onComplete then
            onComplete()
        end
    end)
end

--- Requests an unload of all objective map frames for a quest.
--- Sets the UNLOADING guard synchronously so any in-flight objective draw coroutines that
--- resume afterwards are suppressed (e.g. on abandon, when a stale draw must not re-add
--- objective icons for a quest the player no longer has).
--- Safe to call outside a coroutine.
---@param questId QuestId
---@param onComplete function? Optional callback invoked after the unload coroutine finishes.
function MapIconDrawer:UnloadObjectives(questId, onComplete)
    Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:UnloadObjectives] Unloading objectives for:", questId)

    _questState[questId] = "UNLOADING"

    ThreadLib.ThreadCallbackInstant(function()
        QuestieMap:UnloadObjectiveFrames(questId)
    end, function()
        _questState[questId] = nil
        if onComplete then
            onComplete()
        end
    end)
end

--- Requests an unload of the available-starter and finisher map frames for a quest.
--- Does not set the UNLOADING guard: objective draw coroutines for this quest must still
--- be able to draw (e.g. the accept flow removes the starter and then draws objectives).
--- Safe to call outside a coroutine.
---@param questId QuestId
---@param onComplete function? Optional callback invoked after the unload coroutine finishes.
function MapIconDrawer:UnloadStarterOrFinisher(questId, onComplete)
    Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:UnloadStarterOrFinisher] Unloading starter/finisher for:", questId)

    ThreadLib.ThreadCallbackInstant(function()
        QuestieMap:UnloadStarterOrFinisherFrames(questId)
    end, function()
        if onComplete then
            onComplete()
        end
    end)
end

--- Draws icons for a set of pre-computed candidates (output of ObjectiveIconProvider).
--- Owns AlreadySpawned map/minimap ref bookkeeping.
--- Must be called from a coroutine.
---@param questId QuestId
---@param iconsToDraw table        keyed by distance; value is array of drawIcon entries
---@param objective QuestObjective
---@param maxPerType number
---@return table? lastIcon         the last drawn icon entry, used by DrawObjectiveWaypoints
---@return table  iconPerZone      zone -> {iconMap, x, y}
function MapIconDrawer:DrawObjectiveIcons(questId, iconsToDraw, objective, maxPerType)
    assert(coroutine.running(), "DrawObjectiveIcons must be called from a coroutine")

    -- Determinism guard: if an unload was requested for this quest after this draw was
    -- scheduled, skip drawing entirely. Mirrors the _needsUnload pattern in QuestieFrame
    -- but lifted to the quest level so late-arriving draw threads produce no frames.
    if _questState[questId] == "UNLOADING" then
        Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:DrawObjectiveIcons] Skipping draw, quest is unloading:", questId)
        return nil, {}
    end

    Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:DrawObjectiveIcons] Adding Icons for quest:", questId)

    local spawnedIconCount = 0
    local lastIcon
    local iconPerZone = {}

    local iconCount, orderedList = _GetIconsSortedByDistance(iconsToDraw)

    local alreadyPlacedByZone = {}
    local function _MarkCoordsAsPlaced(zoneKey, coords)
        if (not zoneKey) then
            return
        end
        if (not alreadyPlacedByZone[zoneKey]) then
            alreadyPlacedByZone[zoneKey] = {}
        end
        tinsert(alreadyPlacedByZone[zoneKey], coords)
    end

    local yieldCount = 0
    for i = 1, iconCount do
        local icon = orderedList[i]
        if spawnedIconCount > maxPerType then
            -- NOTE: pre-existing behaviour — draws up to maxPerType + 1 icons before stopping.
            Questie:Debug(Questie.DEBUG_DEVELOP, "[MapIconDrawer] Too many icons for quest:", questId)
            break
        end

        local zoneKey = icon.UiMapID
        if (not alreadyPlacedByZone[zoneKey]) then
            alreadyPlacedByZone[zoneKey] = {}
        end

        local coords = {icon.x, icon.y}
        if _HasProperDistanceToAlreadyPlacedObjectives(coords, alreadyPlacedByZone[zoneKey]) then
            local spawnsMapRefs = objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs
            local spawnsMinimapRefs = objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs

            local x, y = icon.x, icon.y
            local dungeonLocation = ZoneDB:GetDungeonLocation(icon.zone)

            if dungeonLocation and x == -1 and y == -1 then
                if dungeonLocation[2] then -- more than 1 instance entrance (e.g. Blackrock)
                    local secondDungeonLocation = dungeonLocation[2]
                    icon.zone = secondDungeonLocation[1]
                    icon.UiMapID = ZoneDB:GetUiMapIdByAreaId(icon.zone)
                    zoneKey = icon.UiMapID
                    local dX, dY = secondDungeonLocation[2], secondDungeonLocation[3]

                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, dX, dY)
                    if iconMap and iconMini then
                        iconPerZone[icon.zone] = {iconMap, dX, dY}
                        spawnsMapRefs[#spawnsMapRefs + 1] = iconMap
                        spawnsMinimapRefs[#spawnsMinimapRefs + 1] = iconMini
                    end

                    _MarkCoordsAsPlaced(zoneKey, {dX, dY})
                    spawnedIconCount = spawnedIconCount + 1
                end

                local firstDungeonLocation = dungeonLocation[1]
                icon.zone = firstDungeonLocation[1]
                icon.UiMapID = ZoneDB:GetUiMapIdByAreaId(icon.zone)
                zoneKey = icon.UiMapID
                x = firstDungeonLocation[2]
                y = firstDungeonLocation[3]
                coords = {x, y}
            end

            local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, x, y)
            if iconMap and iconMini then
                iconPerZone[icon.zone] = {iconMap, x, y}
                spawnsMapRefs[#spawnsMapRefs + 1] = iconMap
                spawnsMinimapRefs[#spawnsMinimapRefs + 1] = iconMini
            end

            _MarkCoordsAsPlaced(zoneKey, coords)
            spawnedIconCount = spawnedIconCount + 1
            lastIcon = icon
        end

        yieldCount = yieldCount + 1
        if yieldCount >= (TICKS_PER_YIELD * 2) then
            yieldCount = 0
            coYield()
        end
    end

    return lastIcon, iconPerZone
end

--- Draws waypoints for an objective based on previously drawn icons.
--- Must be called from a coroutine.
---@param questId QuestId
---@param objective QuestObjective
---@param lastIcon table?     the last drawn icon entry returned by DrawObjectiveIcons
---@param iconPerZone table   zone -> {iconMap, x, y}
function MapIconDrawer:DrawObjectiveWaypoints(questId, objective, lastIcon, iconPerZone)
    assert(coroutine.running(), "DrawObjectiveWaypoints must be called from a coroutine")

    if _questState[questId] == "UNLOADING" then
        Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:DrawObjectiveWaypoints] Skipping waypoints, quest is unloading:", questId)
        return
    end

    local yieldCount = 0
    for _, spawnData in pairs(objective.spawnList) do
        if spawnData.Waypoints then
            for zone, waypoints in pairs(spawnData.Waypoints) do
                local firstWaypoint = waypoints[1][1]

                if (not iconPerZone[zone]) and lastIcon and firstWaypoint[1] ~= -1 and firstWaypoint[2] ~= -1 then
                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(lastIcon.data, zone, firstWaypoint[1], firstWaypoint[2])

                    if iconMap and iconMini then
                        iconPerZone[zone] = {iconMap, firstWaypoint[1], firstWaypoint[2]}
                        tinsert(objective.AlreadySpawned[lastIcon.AlreadySpawnedId].mapRefs, iconMap)
                        tinsert(objective.AlreadySpawned[lastIcon.AlreadySpawnedId].minimapRefs, iconMini)
                    end
                end

                local ipz = iconPerZone[zone]
                if ipz then
                    QuestieMap:DrawWaypoints(ipz[1], waypoints, zone, spawnData.Hostile and {1, 0.2, 0, 0.7} or nil)
                end

                yieldCount = yieldCount + 1
                if yieldCount >= TICKS_PER_YIELD then
                    yieldCount = 0
                    coYield()
                end
            end

            Questie:Debug(Questie.DEBUG_INFO, "[MapIconDrawer:DrawObjectiveWaypoints]")
        end
    end
end
