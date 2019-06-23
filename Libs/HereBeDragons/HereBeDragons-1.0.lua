-- HereBeDragons is a data API for the World of Warcraft mapping system

-- HereBeDragons-1.0 is not supported on WoW 8.0
if select(4, GetBuildInfo()) >= 80000 or true then
	return
end

local MAJOR, MINOR = "HereBeDragons-1.0", 33
assert(LibStub, MAJOR .. " requires LibStub")

local HereBeDragons, oldversion = LibStub:NewLibrary(MAJOR, MINOR)
if not HereBeDragons then return end

local CBH = LibStub("CallbackHandler-1.0")

HereBeDragons.eventFrame       = HereBeDragons.eventFrame or CreateFrame("Frame")

HereBeDragons.mapData          = HereBeDragons.mapData or {}
HereBeDragons.continentZoneMap = HereBeDragons.continentZoneMap or { [-1] = { [0] = WORLDMAP_COSMIC_ID }, [0] = { [0] = WORLDMAP_AZEROTH_ID }}
HereBeDragons.mapToID          = HereBeDragons.mapToID or { Cosmic = WORLDMAP_COSMIC_ID, World = WORLDMAP_AZEROTH_ID }
HereBeDragons.microDungeons    = HereBeDragons.microDungeons or {}
HereBeDragons.transforms       = HereBeDragons.transforms or {}

HereBeDragons.callbacks        = HereBeDragons.callbacks or CBH:New(HereBeDragons, nil, nil, false)

-- constants
local TERRAIN_MATCH = "_terrain%d+$"

-- Lua upvalues
local PI2 = math.pi * 2
local atan2 = math.atan2
local pairs, ipairs = pairs, ipairs
local type = type
local band = bit.band

-- WoW API upvalues
local UnitPosition = UnitPosition

-- data table upvalues
local mapData          = HereBeDragons.mapData -- table { width, height, left, top }
local continentZoneMap = HereBeDragons.continentZoneMap
local mapToID          = HereBeDragons.mapToID
local microDungeons    = HereBeDragons.microDungeons
local transforms       = HereBeDragons.transforms

local currentPlayerZoneMapID, currentPlayerLevel, currentMapFile, currentMapIsMicroDungeon

-- Override instance ids for phased content
local instanceIDOverrides = {
    -- Draenor
    [1152] = 1116, -- Horde Garrison 1
    [1330] = 1116, -- Horde Garrison 2
    [1153] = 1116, -- Horde Garrison 3
    [1154] = 1116, -- Horde Garrison 4 (unused)
    [1158] = 1116, -- Alliance Garrison 1
    [1331] = 1116, -- Alliance Garrison 2
    [1159] = 1116, -- Alliance Garrison 3
    [1160] = 1116, -- Alliance Garrison 4 (unused)
    [1191] = 1116, -- Ashran PvP Zone
    [1203] = 1116, -- Frostfire Finale Scenario
    [1207] = 1116, -- Talador Finale Scenario
    [1277] = 1116, -- Defense of Karabor Scenario (SMV)
    [1402] = 1116, -- Gorgrond Finale Scenario
    [1464] = 1116, -- Tanaan
    [1465] = 1116, -- Tanaan
    -- Legion
    [1478] = 1220, -- Temple of Elune Scenario (Val'Sharah)
    [1495] = 1220, -- Protection Paladin Artifact Scenario (Stormheim)
    [1498] = 1220, -- Havoc Demon Hunter Artifact Scenario (Suramar)
    [1502] = 1220, -- Dalaran Underbelly
    [1533] = 0,    -- Karazhan Artifact Scenario
    [1612] = 1220, -- Feral Druid Artifact Scenario (Suramar)
    [1626] = 1220, -- Suramar Withered Scenario
    [1662] = 1220, -- Suramar Invasion Scenario
}

-- unregister and store all WORLD_MAP_UPDATE registrants, to avoid excess processing when
-- retrieving info from stateful map APIs
local wmuRegistry
local function UnregisterWMU()
    wmuRegistry = {GetFramesRegisteredForEvent("WORLD_MAP_UPDATE")}
    for _, frame in ipairs(wmuRegistry) do
        frame:UnregisterEvent("WORLD_MAP_UPDATE")
    end
end

-- restore WORLD_MAP_UPDATE to all frames in the registry
local function RestoreWMU()
    assert(wmuRegistry)
    for _, frame in ipairs(wmuRegistry) do
        frame:RegisterEvent("WORLD_MAP_UPDATE")
    end
    wmuRegistry = nil
end

-- gather map info, but only if this isn't an upgrade (or the upgrade version forces a re-map)
if not oldversion or oldversion < 33 then
    -- wipe old data, if required, otherwise the upgrade path isn't triggered
    if oldversion then
        wipe(mapData)
        wipe(microDungeons)
    end

    local MAPS_TO_REMAP = {
         -- alliance garrison
        [973] = 971,
        [974] = 971,
        [975] = 971,
        [991] = 971,
        -- horde garrison
        [980] = 976,
        [981] = 976,
        [982] = 976,
        [990] = 976,
    }

    -- some zones will remap initially, but have a fixup later
    local REMAP_FIXUP_EXEMPT = {
        -- main draenor garrison maps
        [971] = true,
        [976] = true,

        -- legion class halls
        [1072] = { Z = 10, mapFile = "TrueshotLodge" }, -- true shot lodge
        [1077] = { Z = 7,  mapFile = "TheDreamgrove" }, -- dreamgrove
    }

    local function processTransforms()
        wipe(transforms)
        for _, tID in ipairs(GetWorldMapTransforms()) do
            local terrainMapID, newTerrainMapID, _, _, transformMinY, transformMaxY, transformMinX, transformMaxX, offsetY, offsetX, flags = GetWorldMapTransformInfo(tID)
            -- flag 4 indicates the transform is only for the flight map
            if band(flags, 4) ~= 4 and (offsetY ~= 0 or offsetX ~= 0) then
                local transform = {
                    instanceID = terrainMapID,
                    newInstanceID = newTerrainMapID,
                    minY = transformMinY,
                    maxY = transformMaxY,
                    minX = transformMinX,
                    maxX = transformMaxX,
                    offsetY = offsetY,
                    offsetX = offsetX
                }
                table.insert(transforms, transform)
            end
        end
    end

    local function applyMapTransforms(instanceID, left, right, top, bottom)
        for _, transformData in ipairs(transforms) do
            if transformData.instanceID == instanceID then
                if left < transformData.maxX and right > transformData.minX and top < transformData.maxY and bottom > transformData.minY then
                    instanceID = transformData.newInstanceID
                    left   = left   + transformData.offsetX
                    right  = right  + transformData.offsetX
                    top    = top    + transformData.offsetY
                    bottom = bottom + transformData.offsetY
                    break
                end
            end
        end
        return instanceID, left, right, top, bottom
    end

    -- gather the data of one zone (by mapID)
    local function processZone(id)
        if not id or mapData[id] then return end

        -- set the map and verify it could be set
        local success = SetMapByID(id)
        if not success then
            return
        elseif id ~= GetCurrentMapAreaID() and not REMAP_FIXUP_EXEMPT[id] then
            -- this is an alias zone (phasing terrain changes), just skip it and remap it later
            if not MAPS_TO_REMAP[id] then
                MAPS_TO_REMAP[id] = GetCurrentMapAreaID()
            end
            return
        end

        -- dimensions of the map
        local originalInstanceID, _, _, left, right, top, bottom = GetAreaMapInfo(id)
        local instanceID = originalInstanceID
        if (left and top and right and bottom and (left ~= 0 or top ~= 0 or right ~= 0 or bottom ~= 0)) then
            instanceID, left, right, top, bottom = applyMapTransforms(originalInstanceID, left, right, top, bottom)
            mapData[id] = { left - right, top - bottom, left, top }
        else
            mapData[id] = { 0, 0, 0, 0 }
        end

        mapData[id].instance = instanceID
        mapData[id].name = GetMapNameByID(id)

        -- store the original instance id (ie. not remapped for map transforms) for micro dungeons
        mapData[id].originalInstance = originalInstanceID

        local mapFile = type(REMAP_FIXUP_EXEMPT[id]) == "table" and REMAP_FIXUP_EXEMPT[id].mapFile or GetMapInfo()
        if mapFile then
            -- remove phased terrain from the map names
            mapFile = mapFile:gsub(TERRAIN_MATCH, "")

            if not mapToID[mapFile] then mapToID[mapFile] = id end
            mapData[id].mapFile = mapFile
        end

        local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()

        -- maps that remap generally have wrong C/Z info, so allow the fixup table to override it
        if type(REMAP_FIXUP_EXEMPT[id]) == "table" then
            C = REMAP_FIXUP_EXEMPT[id].C or C
            Z = REMAP_FIXUP_EXEMPT[id].Z or Z
        end

        mapData[id].C = C or -100
        mapData[id].Z = Z or -100

        if mapData[id].C > 0 and mapData[id].Z >= 0 then
            -- store C/Z lookup table
            if not continentZoneMap[C] then
                continentZoneMap[C] = {}
            end
            if not continentZoneMap[C][Z] then
                continentZoneMap[C][Z] = id
            end
        end

        -- retrieve floors
        local floors = { GetNumDungeonMapLevels() }

        -- offset floors for terrain map
        if DungeonUsesTerrainMap() then
            for i = 1, #floors do
                floors[i] = floors[i] + 1
            end
        end

        -- check for fake floors
        if #floors == 0 and GetCurrentMapDungeonLevel() > 0 then
            floors[1] = GetCurrentMapDungeonLevel()
            mapData[id].fakefloor = GetCurrentMapDungeonLevel()
        end

        mapData[id].floors = {}
        mapData[id].numFloors = #floors
        for i = 1, mapData[id].numFloors do
            local f = floors[i]
            SetDungeonMapLevel(f)
            local _, right, bottom, left, top = GetCurrentMapDungeonLevel()
            if left and top and right and bottom then
                instanceID, left, right, top, bottom = applyMapTransforms(originalInstanceID, left, right, top, bottom)
                mapData[id].floors[f] = { left - right, top - bottom, left, top }
                mapData[id].floors[f].instance = mapData[id].instance
            elseif f == 1 and DungeonUsesTerrainMap() then
                mapData[id].floors[f] = { mapData[id][1], mapData[id][2], mapData[id][3], mapData[id][4] }
                mapData[id].floors[f].instance = mapData[id].instance
            end
        end

        -- setup microdungeon storage if the its a zone map or has no floors of its own
        if (mapData[id].C > 0 and mapData[id].Z > 0) or mapData[id].numFloors == 0 then
            if not microDungeons[originalInstanceID] then
                microDungeons[originalInstanceID] = { global = {} }
            end
        end
    end

    local function processMicroDungeons()
        for _, dID in ipairs(GetDungeonMaps()) do
            local floorIndex, minX, maxX, minY, maxY, terrainMapID, parentWorldMapID, flags = GetDungeonMapInfo(dID)

            -- apply transform
            local originalTerrainMapID = terrainMapID
            terrainMapID, maxX, minX, maxY, minY = applyMapTransforms(terrainMapID, maxX, minX, maxY, minY)

            -- check if this zone can have microdungeons
            if microDungeons[originalTerrainMapID] then
                -- store per-zone info
                if not microDungeons[originalTerrainMapID][parentWorldMapID] then
                    microDungeons[originalTerrainMapID][parentWorldMapID] = {}
                end

                microDungeons[originalTerrainMapID][parentWorldMapID][floorIndex] = { maxX - minX, maxY - minY, maxX, maxY }
                microDungeons[originalTerrainMapID][parentWorldMapID][floorIndex].instance = terrainMapID

                -- store global info, as some microdungeon are associated to the wrong zone when phasing is involved (garrison, and more)
                -- but only store the first, since there can be overlap on the same continent otherwise
                if not microDungeons[originalTerrainMapID].global[floorIndex] then
                    microDungeons[originalTerrainMapID].global[floorIndex] = microDungeons[originalTerrainMapID][parentWorldMapID][floorIndex]
                end
            end
        end
    end

    local function fixupZones()
        -- fake cosmic map
        mapData[WORLDMAP_COSMIC_ID] = {0, 0, 0, 0}
        mapData[WORLDMAP_COSMIC_ID].instance = -1
        mapData[WORLDMAP_COSMIC_ID].mapFile = "Cosmic"
        mapData[WORLDMAP_COSMIC_ID].floors = {}
        mapData[WORLDMAP_COSMIC_ID].C = -1
        mapData[WORLDMAP_COSMIC_ID].Z = 0
        mapData[WORLDMAP_COSMIC_ID].name = WORLD_MAP

        -- fake azeroth world map
        -- the world map has one "floor" per continent it contains, which allows
        -- using these floors to translate coordinates from and to the world map.
        -- note: due to artistic differences in the drawn azeroth maps, the values
        -- used for the continents are estimates and not perfectly accurate
        mapData[WORLDMAP_AZEROTH_ID] = { 63570, 42382, 53730, 19600 } -- Eastern Kingdoms, or floor 0
        mapData[WORLDMAP_AZEROTH_ID].floors = {
            -- Kalimdor
            [1] =    { 65700, 43795, 11900, 23760, instance = 1    },
            -- Northrend
            [571] =  { 65700, 43795, 33440, 11960, instance = 571  },
            -- Pandaria
            [870] =  { 58520, 39015, 29070, 34410, instance = 870  },
            -- Broken Isles
            [1220] = { 96710, 64476, 63100, 29960, instance = 1220 },
        }
        mapData[WORLDMAP_AZEROTH_ID].instance = 0
        mapData[WORLDMAP_AZEROTH_ID].mapFile = "World"
        mapData[WORLDMAP_AZEROTH_ID].C = 0
        mapData[WORLDMAP_AZEROTH_ID].Z = 0
        mapData[WORLDMAP_AZEROTH_ID].name = WORLD_MAP

        -- alliance draenor garrison
        if mapData[971] then
            mapData[971].Z = 5

            mapToID["garrisonsmvalliance_tier1"] = 971
            mapToID["garrisonsmvalliance_tier2"] = 971
            mapToID["garrisonsmvalliance_tier3"] = 971
        end

        -- horde draenor garrison
        if mapData[976] then
            mapData[976].Z = 3

            mapToID["garrisonffhorde_tier1"] = 976
            mapToID["garrisonffhorde_tier2"] = 976
            mapToID["garrisonffhorde_tier3"] = 976
        end

        -- remap zones with alias IDs
        for remapID, validMapID in pairs(MAPS_TO_REMAP) do
            if mapData[validMapID] then
                mapData[remapID] = mapData[validMapID]
            end
        end
    end

    local function gatherMapData()
        -- unregister WMU to reduce the processing burden
        UnregisterWMU()

        -- load transforms
        processTransforms()

        -- load the main zones
        -- these should be processed first so they take precedence in the mapFile lookup table
        local continents = {GetMapContinents()}
        for i = 1, #continents, 2 do
            processZone(continents[i])
            local zones = {GetMapZones((i + 1) / 2)}
            for z = 1, #zones, 2 do
                processZone(zones[z])
            end
        end

        -- process all other zones, this includes dungeons and more
        local areas = GetAreaMaps()
        for idx, zoneID in pairs(areas) do
            processZone(zoneID)
        end

        -- fix a few zones with data lookup problems
        fixupZones()

        -- and finally, the microdungeons
        processMicroDungeons()

        -- restore WMU
        RestoreWMU()
    end

    gatherMapData()
end

-- Transform a set of coordinates based on the defined map transformations
local function applyCoordinateTransforms(x, y, instanceID)
    for _, transformData in ipairs(transforms) do
        if transformData.instanceID == instanceID then
            if transformData.minX <= x and transformData.maxX >= x and transformData.minY <= y and transformData.maxY >= y then
                instanceID = transformData.newInstanceID
                x = x + transformData.offsetX
                y = y + transformData.offsetY
                break
            end
        end
    end
    if instanceIDOverrides[instanceID] then
        instanceID = instanceIDOverrides[instanceID]
    end
    return x, y, instanceID
end

-- get the data table for a map and its level (floor)
local function getMapDataTable(mapID, level)
    if not mapID then return nil end
    if type(mapID) == "string" then
        mapID = mapID:gsub(TERRAIN_MATCH, "")
        mapID = mapToID[mapID]
    end
    local data = mapData[mapID]
    if not data then return nil end

    if (type(level) ~= "number" or level == 0) and data.fakefloor then
        level = data.fakefloor
    end

    if type(level) == "number" and level > 0 then
        if data.floors[level] then
            return data.floors[level]
        elseif data.originalInstance and microDungeons[data.originalInstance] then
            if microDungeons[data.originalInstance][mapID] and microDungeons[data.originalInstance][mapID][level] then
                return microDungeons[data.originalInstance][mapID][level]
            elseif microDungeons[data.originalInstance].global[level] then
                return microDungeons[data.originalInstance].global[level]
            end
        end
    else
        return data
    end
end

local StartUpdateTimer
local function UpdateCurrentPosition()
    UnregisterWMU()

    -- save active map and level
    local prevContinent
    local prevMapID, prevLevel = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()

    -- handle continent maps (751 is the maelstrom continent, which fails with SetMapByID)
    if not prevMapID or prevMapID < 0 or prevMapID == 751 then
        prevContinent = GetCurrentMapContinent()
    end

    -- set current map
    SetMapToCurrentZone()

    -- retrieve active values
    local newMapID, newLevel = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
    local mapFile, _, _, isMicroDungeon, microFile = GetMapInfo()

    -- we want to ignore any terrain phasings
    if mapFile then
        mapFile = mapFile:gsub(TERRAIN_MATCH, "")
    end

    -- hack to update the mapfile for the garrison map (as it changes when the player updates his garrison)
    -- its not ideal to only update it when the player is in the garrison, but updates should only really happen then
    if (newMapID == 971 or newMapID == 976) and mapData[newMapID] and mapFile ~= mapData[newMapID].mapFile then
        mapData[newMapID].mapFile = mapFile
    end

    -- restore previous map
    if prevContinent then
        SetMapZoom(prevContinent)
    else
        -- reset map if it changed, or we need to go back to level 0
        if prevMapID and (prevMapID ~= newMapID or (prevLevel ~= newLevel and prevLevel == 0)) then
            SetMapByID(prevMapID)
        end
        if prevLevel and prevLevel > 0 then
            SetDungeonMapLevel(prevLevel)
        end
    end

    RestoreWMU()

    if newMapID ~= currentPlayerZoneMapID or newLevel ~= currentPlayerLevel then
        -- store micro dungeon map lookup, if available
        if microFile and not mapToID[microFile] then mapToID[microFile] = newMapID end

        -- update upvalues and signal callback
        currentPlayerZoneMapID, currentPlayerLevel, currentMapFile, currentMapIsMicroDungeon = newMapID, newLevel, microFile or mapFile, isMicroDungeon
        HereBeDragons.callbacks:Fire("PlayerZoneChanged", currentPlayerZoneMapID, currentPlayerLevel, currentMapFile, currentMapIsMicroDungeon)
    end

    -- start a timer to update in micro dungeons since multi-level micro dungeons do not reliably fire events
    if isMicroDungeon then
        StartUpdateTimer()
    end
end

-- upgradeable timer callback, don't want to keep calling the old function if the library is upgraded
HereBeDragons.UpdateCurrentPosition = UpdateCurrentPosition
local function UpdateTimerCallback()
    -- signal that the timer ran
    HereBeDragons.updateTimerActive = nil

    -- run update now
    HereBeDragons.UpdateCurrentPosition()
end

function StartUpdateTimer()
    if not HereBeDragons.updateTimerActive then
        -- prevent running multiple timers
        HereBeDragons.updateTimerActive = true

        -- and queue an update
        C_Timer.After(1, UpdateTimerCallback)
    end
end

local function OnEvent(frame, event, ...)
    UpdateCurrentPosition()
end

HereBeDragons.eventFrame:SetScript("OnEvent", OnEvent)
HereBeDragons.eventFrame:UnregisterAllEvents()
HereBeDragons.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
HereBeDragons.eventFrame:RegisterEvent("ZONE_CHANGED")
HereBeDragons.eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
HereBeDragons.eventFrame:RegisterEvent("NEW_WMO_CHUNK")
HereBeDragons.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- if we're loading after entering the world (ie. on demand), update position now
if IsLoggedIn() then
    UpdateCurrentPosition()
end

--- Return the localized zone name for a given mapID or mapFile
-- @param mapID numeric mapID or mapFile
function HereBeDragons:GetLocalizedMap(mapID)
    if type(mapID) == "string" then
        mapID = mapID:gsub(TERRAIN_MATCH, "")
        mapID = mapToID[mapID]
    end
    return mapData[mapID] and mapData[mapID].name or nil
end

--- Return the map id to a mapFile
-- @param mapFile Map File
function HereBeDragons:GetMapIDFromFile(mapFile)
    if mapFile then
        mapFile = mapFile:gsub(TERRAIN_MATCH, "")
        return mapToID[mapFile]
    end
    return nil
end

--- Return the mapFile to a map ID
-- @param mapID Map ID
function HereBeDragons:GetMapFileFromID(mapID)
    return mapData[mapID] and mapData[mapID].mapFile or nil
end

--- Lookup the map ID for a Continent / Zone index combination
-- @param C continent index from GetCurrentMapContinent
-- @param Z zone index from GetCurrentMapZone
function HereBeDragons:GetMapIDFromCZ(C, Z)
    if C and continentZoneMap[C] then
        return Z and continentZoneMap[C][Z]
    end
    return nil
end

--- Lookup the C/Z values for map
-- @param mapID the MapID
function HereBeDragons:GetCZFromMapID(mapID)
    if mapData[mapID] then
        return mapData[mapID].C, mapData[mapID].Z
    end
    return nil, nil
end

--- Get the size of the zone
-- @param mapID Map ID or MapFile of the zone
-- @param level Optional map level
-- @return width, height of the zone, in yards
function HereBeDragons:GetZoneSize(mapID, level)
    local data = getMapDataTable(mapID, level)
    if not data then return 0, 0 end

    return data[1], data[2]
end

--- Get the number of floors for a map
-- @param mapID map ID or mapFile of the zone
function HereBeDragons:GetNumFloors(mapID)
    if not mapID then return 0 end
    if type(mapID) == "string" then
        mapID = mapID:gsub(TERRAIN_MATCH, "")
        mapID = mapToID[mapID]
    end

    if not mapData[mapID] or not mapData[mapID].numFloors then return 0 end

    return mapData[mapID].numFloors
end

--- Get a list of all map IDs
-- @return array-style table with all known/valid map IDs
function HereBeDragons:GetAllMapIDs()
    local t = {}
    for id in pairs(mapData) do
        table.insert(t, id)
    end
    return t
end

--- Convert local/point coordinates to world coordinates in yards
-- @param x X position in 0-1 point coordinates
-- @param y Y position in 0-1 point coordinates
-- @param zone MapID or MapFile of the zone
-- @param level Optional level of the zone
function HereBeDragons:GetWorldCoordinatesFromZone(x, y, zone, level)
	
    local data = getMapDataTable(zone, level)
    if not data or data[1] == 0 or data[2] == 0 then return nil, nil, nil end
    if not x or not y then return nil, nil, nil end

    local width, height, left, top = data[1], data[2], data[3], data[4]
    x, y = left - width * x, top - height * y

    return x, y, data.instance
end

--- Convert world coordinates to local/point zone coordinates
-- @param x Global X position
-- @param y Global Y position
-- @param zone MapID or MapFile of the zone
-- @param level Optional level of the zone
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
function HereBeDragons:GetZoneCoordinatesFromWorld(x, y, zone, level, allowOutOfBounds)
    local data = getMapDataTable(zone, level)
    if not data or data[1] == 0 or data[2] == 0 then return nil, nil end
    if not x or not y then return nil, nil end

    local width, height, left, top = data[1], data[2], data[3], data[4]
    x, y = (left - x) / width, (top - y) / height

    -- verify the coordinates fall into the zone
    if not allowOutOfBounds and (x < 0 or x > 1 or y < 0 or y > 1) then return nil, nil end

    return x, y
end

--- Translate zone coordinates from one zone to another
-- @param x X position in 0-1 point coordinates, relative to the origin zone
-- @param y Y position in 0-1 point coordinates, relative to the origin zone
-- @param oZone Origin Zone, mapID or mapFile
-- @param oLevel Origin Zone Level
-- @param dZone Destination Zone, mapID or mapFile
-- @param dLevel Destination Zone Level
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
function HereBeDragons:TranslateZoneCoordinates(x, y, oZone, oLevel, dZone, dLevel, allowOutOfBounds)
    local xCoord, yCoord, instance = self:GetWorldCoordinatesFromZone(x, y, oZone, oLevel)
    if not xCoord then return nil, nil end

    local data = getMapDataTable(dZone, dLevel)
    if not data or data.instance ~= instance then return nil, nil end

    return self:GetZoneCoordinatesFromWorld(xCoord, yCoord, dZone, dLevel, allowOutOfBounds)
end

--- Return the distance from an origin position to a destination position in the same instance/continent.
-- @param instanceID instance ID
-- @param oX origin X
-- @param oY origin Y
-- @param dX destination X
-- @param dY destination Y
-- @return distance, deltaX, deltaY
function HereBeDragons:GetWorldDistance(instanceID, oX, oY, dX, dY)
    if not oX or not oY or not dX or not dY then return nil, nil, nil end
    local deltaX, deltaY = dX - oX, dY - oY
    return (deltaX * deltaX + deltaY * deltaY)^0.5, deltaX, deltaY
end

--- Return the distance between two points on the same continent
-- @param oZone origin zone map id or mapfile
-- @param oLevel optional origin zone level (floor)
-- @param oX origin X, in local zone/point coordinates
-- @param oY origin Y, in local zone/point coordinates
-- @param dZone destination zone map id or mapfile
-- @param dLevel optional destination zone level (floor)
-- @param dX destination X, in local zone/point coordinates
-- @param dY destination Y, in local zone/point coordinates
-- @return distance, deltaX, deltaY in yards
function HereBeDragons:GetZoneDistance(oZone, oLevel, oX, oY, dZone, dLevel, dX, dY)
    local oX, oY, oInstance = self:GetWorldCoordinatesFromZone(oX, oY, oZone, oLevel)
    if not oX then return nil, nil, nil end

    -- translate dX, dY to the origin zone
    local dX, dY, dInstance = self:GetWorldCoordinatesFromZone(dX, dY, dZone, dLevel)
    if not dX then return nil, nil, nil end

    if oInstance ~= dInstance then return nil, nil, nil end

    return self:GetWorldDistance(oInstance, oX, oY, dX, dY)
end

--- Return the angle and distance from an origin position to a destination position in the same instance/continent.
-- @param instanceID instance ID
-- @param oX origin X
-- @param oY origin Y
-- @param dX destination X
-- @param dY destination Y
-- @return angle, distance where angle is in radians and distance in yards
function HereBeDragons:GetWorldVector(instanceID, oX, oY, dX, dY)
    local distance, deltaX, deltaY = self:GetWorldDistance(instanceID, oX, oY, dX, dY)
    if not distance then return nil, nil end

    -- calculate the angle from deltaY and deltaX
    local angle = atan2(-deltaX, deltaY)

    -- normalize the angle
    if angle > 0 then
        angle = PI2 - angle
    else
        angle = -angle
    end

    return angle, distance
end

--- Get the current world position of the specified unit
-- The position is transformed to the current continent, if applicable
-- NOTE: The same restrictions as for the UnitPosition() API apply,
-- which means a very limited set of unit ids will actually work.
-- @param unitId Unit Id
-- @return x, y, instanceID
function HereBeDragons:GetUnitWorldPosition(unitId)
    -- get the current position
    local y, x, z, instanceID = UnitPosition(unitId)
    if not x or not y then return nil, nil, instanceIDOverrides[instanceID] or instanceID end

    -- return transformed coordinates
    return applyCoordinateTransforms(x, y, instanceID)
end

--- Get the current world position of the player
-- The position is transformed to the current continent, if applicable
-- @return x, y, instanceID
function HereBeDragons:GetPlayerWorldPosition()
    -- get the current position
    local y, x, z, instanceID = UnitPosition("player")
    if not x or not y then return nil, nil, instanceIDOverrides[instanceID] or instanceID end

    -- return transformed coordinates
    return applyCoordinateTransforms(x, y, instanceID)
end

--- Get the current zone and level of the player
-- The returned mapFile can represent a micro dungeon, if the player currently is inside one.
-- @return mapID, level, mapFile, isMicroDungeon
function HereBeDragons:GetPlayerZone()
    return currentPlayerZoneMapID, currentPlayerLevel, currentMapFile, currentMapIsMicroDungeon
end

--- Get the current position of the player on a zone level
-- The returned values are local point coordinates, 0-1. The mapFile can represent a micro dungeon.
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
-- @return x, y, mapID, level, mapFile, isMicroDungeon
function HereBeDragons:GetPlayerZonePosition(allowOutOfBounds)
    if not currentPlayerZoneMapID then return nil, nil, nil, nil end
    local x, y, instanceID = self:GetPlayerWorldPosition()
    if not x or not y then return nil, nil, nil, nil end

    x, y = self:GetZoneCoordinatesFromWorld(x, y, currentPlayerZoneMapID, currentPlayerLevel, allowOutOfBounds)
    if x and y then
        return x, y, currentPlayerZoneMapID, currentPlayerLevel, currentMapFile, currentMapIsMicroDungeon
    end
    return nil, nil, nil, nil
end
