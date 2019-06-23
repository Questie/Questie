-- HereBeDragons-Pins is a library to show pins/icons on the world map and minimap

-- HereBeDragons-Pins-1.0 is not supported on WoW 8.0
if select(4, GetBuildInfo()) >= 80000 or true then
	return
end


local MAJOR, MINOR = "HereBeDragons-Pins-1.0", 16
assert(LibStub, MAJOR .. " requires LibStub")

local pins, oldversion = LibStub:NewLibrary(MAJOR, MINOR)
if not pins then return end

local HBD = LibStub("HereBeDragons-1.0")

pins.updateFrame          = pins.updateFrame or CreateFrame("Frame")

-- storage for minimap pins
pins.minimapPins          = pins.minimapPins or {}
pins.activeMinimapPins    = pins.activeMinimapPins or {}
pins.minimapPinRegistry   = pins.minimapPinRegistry or {}

-- and worldmap pins
pins.worldmapPins         = pins.worldmapPins or {}
pins.worldmapPinRegistry  = pins.worldmapPinRegistry or {}

-- store a reference to the active minimap object
pins.Minimap = pins.Minimap or Minimap

-- upvalue lua api
local cos, sin, max = math.cos, math.sin, math.max
local type, pairs = type, pairs

-- upvalue wow api
local GetPlayerFacing = GetPlayerFacing

-- upvalue data tables
local minimapPins         = pins.minimapPins
local activeMinimapPins   = pins.activeMinimapPins
local minimapPinRegistry  = pins.minimapPinRegistry

local worldmapPins        = pins.worldmapPins
local worldmapPinRegistry = pins.worldmapPinRegistry

local minimap_size = {
    indoor = {
        [0] = 300, -- scale
        [1] = 240, -- 1.25
        [2] = 180, -- 5/3
        [3] = 120, -- 2.5
        [4] = 80,  -- 3.75
        [5] = 50,  -- 6
    },
    outdoor = {
        [0] = 466 + 2/3, -- scale
        [1] = 400,       -- 7/6
        [2] = 333 + 1/3, -- 1.4
        [3] = 266 + 2/6, -- 1.75
        [4] = 200,       -- 7/3
        [5] = 133 + 1/3, -- 3.5
    },
}

local minimap_shapes = {
    -- { upper-left, lower-left, upper-right, lower-right }
    ["SQUARE"]                = { false, false, false, false },
    ["CORNER-TOPLEFT"]        = { true,  false, false, false },
    ["CORNER-TOPRIGHT"]       = { false, false, true,  false },
    ["CORNER-BOTTOMLEFT"]     = { false, true,  false, false },
    ["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
    ["SIDE-LEFT"]             = { true,  true,  false, false },
    ["SIDE-RIGHT"]            = { false, false, true,  true },
    ["SIDE-TOP"]              = { true,  false, true,  false },
    ["SIDE-BOTTOM"]           = { false, true,  false, true },
    ["TRICORNER-TOPLEFT"]     = { true,  true,  true,  false },
    ["TRICORNER-TOPRIGHT"]    = { true,  false, true,  true },
    ["TRICORNER-BOTTOMLEFT"]  = { true,  true,  false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { false, true,  true,  true },
}

local tableCache = setmetatable({}, {__mode='k'})

local function newCachedTable()
    local t = next(tableCache)
    if t then
        tableCache[t] = nil
    else
        t = {}
    end
    return t
end

local function recycle(t)
    tableCache[t] = true
end

-- minimap rotation
local rotateMinimap = GetCVar("rotateMinimap") == "1"

-- is the minimap indoors or outdoors
local indoors = GetCVar("minimapZoom")+0 == pins.Minimap:GetZoom() and "outdoor" or "indoor"

local minimapPinCount, queueFullUpdate = 0, false
local minimapScale, minimapShape, mapRadius, minimapWidth, minimapHeight, mapSin, mapCos
local lastZoom, lastFacing, lastXY, lastYY

local worldmapWidth, worldmapHeight = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()

local function drawMinimapPin(pin, data)
    local xDist, yDist = lastXY - data.x, lastYY - data.y

    -- handle rotation
    if rotateMinimap then
        local dx, dy = xDist, yDist
        xDist = dx*mapCos - dy*mapSin
        yDist = dx*mapSin + dy*mapCos
    end

    -- adapt delta position to the map radius
    local diffX = xDist / mapRadius
    local diffY = yDist / mapRadius

    -- different minimap shapes
    local isRound = true
    if minimapShape and not (xDist == 0 or yDist == 0) then
        isRound = (xDist < 0) and 1 or 3
        if yDist < 0 then
            isRound = minimapShape[isRound]
        else
            isRound = minimapShape[isRound + 1]
        end
    end

    -- calculate distance from the center of the map
    local dist
    if isRound then
        dist = (diffX*diffX + diffY*diffY) / 0.9^2
    else
        dist = max(diffX*diffX, diffY*diffY) / 0.9^2
    end

    -- if distance > 1, then adapt node position to slide on the border
    if dist > 1 and data.floatOnEdge then
        dist = dist^0.5
        diffX = diffX/dist
        diffY = diffY/dist
    end

    if dist <= 1 or data.floatOnEdge then
        pin:Show()
        pin:ClearAllPoints()
        pin:SetPoint("CENTER", pins.Minimap, "CENTER", diffX * minimapWidth, -diffY * minimapHeight)
        data.onEdge = (dist > 1)
    else
        pin:Hide()
        data.onEdge = nil
        pin.keep = nil
    end
end

local function UpdateMinimapPins(force)
    -- get the current player position
    local x, y, instanceID = HBD:GetPlayerWorldPosition()
    local mapID, mapFloor = HBD:GetPlayerZone()

    -- get data from the API for calculations
    local zoom = pins.Minimap:GetZoom()
    local diffZoom = zoom ~= lastZoom

    -- for rotating minimap support
    local facing
    if rotateMinimap then
        facing = GetPlayerFacing()
    else
        facing = lastFacing
    end

    -- check for all values to be available (starting with 7.1.0, instances don't report coordinates)
    if not x or not y or (rotateMinimap and not facing) then
        minimapPinCount = 0
        for pin, data in pairs(activeMinimapPins) do
            pin:Hide()
            activeMinimapPins[pin] = nil
        end
        return
    end

    local newScale = pins.Minimap:GetScale()
    if minimapScale ~= newScale then
        minimapScale = newScale
        force = true
    end

    if x ~= lastXY or y ~= lastYY or diffZoom or facing ~= lastFacing or force then
        -- minimap information
        minimapShape = GetMinimapShape and minimap_shapes[GetMinimapShape() or "ROUND"]
        mapRadius = minimap_size[indoors][zoom] / 2
        minimapWidth = pins.Minimap:GetWidth() / 2
        minimapHeight = pins.Minimap:GetHeight() / 2

        -- update upvalues for icon placement
        lastZoom = zoom
        lastFacing = facing
        lastXY, lastYY = x, y

        if rotateMinimap then
            mapSin = sin(facing)
            mapCos = cos(facing)
        end

        for pin, data in pairs(minimapPins) do
            if data.instanceID == instanceID and (not data.floor or (data.floor == mapFloor and (data.floor == 0 or data.mapID == mapID))) then
                activeMinimapPins[pin] = data
                data.keep = true
                -- draw the pin (this may reset data.keep if outside of the map)
                drawMinimapPin(pin, data)
            end
        end

        minimapPinCount = 0
        for pin, data in pairs(activeMinimapPins) do
            if not data.keep then
                pin:Hide()
                activeMinimapPins[pin] = nil
            else
                minimapPinCount = minimapPinCount + 1
                data.keep = nil
            end
        end
    end
end

local function UpdateMinimapIconPosition()

    -- get the current map  zoom
    local zoom = pins.Minimap:GetZoom()
    local diffZoom = zoom ~= lastZoom
    -- if the map zoom changed, run a full update sweep
    if diffZoom then
        UpdateMinimapPins()
        return
    end

    -- we have no active minimap pins, just return early
    if minimapPinCount == 0 then return end

    local x, y = HBD:GetPlayerWorldPosition()

    -- for rotating minimap support
    local facing
    if rotateMinimap then
        facing = GetPlayerFacing()
    else
        facing = lastFacing
    end

    -- check for all values to be available (starting with 7.1.0, instances don't report coordinates)
    if not x or not y or (rotateMinimap and not facing) then
        UpdateMinimapPins()
        return
    end

    local refresh
    local newScale = pins.Minimap:GetScale()
    if minimapScale ~= newScale then
        minimapScale = newScale
        refresh = true
    end

    if x ~= lastXY or y ~= lastYY or facing ~= lastFacing or refresh then
        -- update radius of the map
        mapRadius = minimap_size[indoors][zoom] / 2
        -- update upvalues for icon placement
        lastXY, lastYY = x, y
        lastFacing = facing

        if rotateMinimap then
            mapSin = sin(facing)
            mapCos = cos(facing)
        end

        -- iterate all nodes and check if they are still in range of our minimap display
        for pin, data in pairs(activeMinimapPins) do
            -- update the position of the node
            drawMinimapPin(pin, data)
        end
    end
end

local function UpdateMinimapZoom()
    local zoom = pins.Minimap:GetZoom()
    if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
        pins.Minimap:SetZoom(zoom < 2 and zoom + 1 or zoom - 1)
    end
    indoors = GetCVar("minimapZoom")+0 == pins.Minimap:GetZoom() and "outdoor" or "indoor"
    pins.Minimap:SetZoom(zoom)
end

local function PositionWorldMapIcon(icon, data, currentMapID, currentMapFloor)
    -- special handling for the azeroth world map
    -- translating coordinates to the azeroth map requires passing the instance ID
    -- of the origin continent, so the appropriate coordinates can be calculated
    if currentMapID == WORLDMAP_AZEROTH_ID then
        currentMapFloor = data.instanceID
    end

    local x, y = HBD:GetZoneCoordinatesFromWorld(data.x, data.y, currentMapID, currentMapFloor)
    if x and y then
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x * worldmapWidth, -y * worldmapHeight)
        icon:Show()
    else
        icon:Hide()
    end
end

local function GetWorldMapLocation()
    local mapID, mapFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()

    -- override the mapID for the azeroth world map
    if mapID == -1 and GetCurrentMapContinent() == 0 and GetCurrentMapZone() == 0 then
        mapID = WORLDMAP_AZEROTH_ID
        mapFloor = 0
    end

    return mapID, mapFloor
end

local function UpdateWorldMap()
    if not WorldMapButton:IsVisible() then return end

    local mapID, mapFloor = GetWorldMapLocation()

    -- not viewing a valid map
    if not mapID or mapID == -1 then
        for icon in pairs(worldmapPins) do
            icon:Hide()
        end
        return
    end

    local instanceID = HBD.mapData[mapID] and HBD.mapData[mapID].instance or -1

    worldmapWidth  = WorldMapButton:GetWidth()
    worldmapHeight = WorldMapButton:GetHeight()

    for icon, data in pairs(worldmapPins) do
        if (instanceID == data.instanceID or mapID == WORLDMAP_AZEROTH_ID) and (not data.floor or (data.floor == mapFloor and (data.floor == 0 or data.mapID == mapID))) then
            PositionWorldMapIcon(icon, data, mapID, mapFloor)
        else
            icon:Hide()
        end
    end
end

local function UpdateMaps()
    UpdateMinimapZoom()
    UpdateMinimapPins()
    UpdateWorldMap()
end

local last_update = 0
local function OnUpdateHandler(frame, elapsed)
    last_update = last_update + elapsed
    if last_update > 1 or queueFullUpdate then
        UpdateMinimapPins(queueFullUpdate)
        last_update = 0
        queueFullUpdate = false
    else
        UpdateMinimapIconPosition()
    end
end
pins.updateFrame:SetScript("OnUpdate", OnUpdateHandler)

local function OnEventHandler(frame, event, ...)
    if event == "CVAR_UPDATE" then
        local cvar, value = ...
        if cvar == "ROTATE_MINIMAP" then
            rotateMinimap = (value == "1")
            queueFullUpdate = true
        end
    elseif event == "MINIMAP_UPDATE_ZOOM" then
        UpdateMinimapZoom()
        UpdateMinimapPins()
    elseif event == "PLAYER_LOGIN" then
        -- recheck cvars after login
        rotateMinimap = GetCVar("rotateMinimap") == "1"
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateMaps()
    elseif event == "WORLD_MAP_UPDATE" then
        UpdateWorldMap()
    end
end

pins.updateFrame:SetScript("OnEvent", OnEventHandler)
pins.updateFrame:UnregisterAllEvents()
pins.updateFrame:RegisterEvent("CVAR_UPDATE")
pins.updateFrame:RegisterEvent("MINIMAP_UPDATE_ZOOM")
pins.updateFrame:RegisterEvent("PLAYER_LOGIN")
pins.updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pins.updateFrame:RegisterEvent("WORLD_MAP_UPDATE")

HBD.RegisterCallback(pins, "PlayerZoneChanged", UpdateMaps)


--- Add a icon to the minimap (x/y world coordinate version)
-- Note: This API does not let you specify a floor, as floors are map-specific, not instance/world wide. Use the Map/Floor API to specify a floor.
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
-- @param icon Icon Frame
-- @param instanceID Instance ID of the map to add the icon to
-- @param x X position in world coordinates
-- @param y Y position in world coordinates
-- @param floatOnEdge flag if the icon should float on the edge of the minimap when going out of range, or hide immediately (default false)
function pins:AddMinimapIconWorld(ref, icon, instanceID, x, y, floatOnEdge)
    if not ref then
        error(MAJOR..": AddMinimapIconWorld: 'ref' must not be nil")
    end
    if type(icon) ~= "table" or not icon.SetPoint then
        error(MAJOR..": AddMinimapIconWorld: 'icon' must be a frame", 2)
    end
    if type(instanceID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error(MAJOR..": AddMinimapIconWorld: 'instanceID', 'x' and 'y' must be numbers", 2)
    end

    if not minimapPinRegistry[ref] then
        minimapPinRegistry[ref] = {}
    end

    minimapPinRegistry[ref][icon] = true

    local t = minimapPins[icon] or newCachedTable()
    t.instanceID = instanceID
    t.x = x
    t.y = y
    t.floatOnEdge = floatOnEdge
    t.mapID = nil
    t.floor = nil

    minimapPins[icon] = t
    queueFullUpdate = true

    icon:SetParent(pins.Minimap)
end

--- Add a icon to the minimap (mapid/floor coordinate version)
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
-- @param icon Icon Frame
-- @param mapID Map ID of the map to place the icon on
-- @param mapFloor Floor to place the icon on (or nil for all floors)
-- @param x X position in local/point coordinates (0-1), relative to the zone
-- @param y Y position in local/point coordinates (0-1), relative to the zone
-- @param floatOnEdge flag if the icon should float on the edge of the minimap when going out of range, or hide immediately (default false)
function pins:AddMinimapIconMF(ref, icon, mapID, mapFloor, x, y, floatOnEdge)
    if not ref then
        error(MAJOR..": AddMinimapIconMF: 'ref' must not be nil")
    end
    if type(icon) ~= "table" or not icon.SetPoint then
        error(MAJOR..": AddMinimapIconMF: 'icon' must be a frame")
    end
    if type(mapID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error(MAJOR..": AddMinimapIconMF: 'mapID', 'x' and 'y' must be numbers")
    end

    -- convert to world coordinates and use our known adding function
    local xCoord, yCoord, instanceID = HBD:GetWorldCoordinatesFromZone(x, y, mapID, mapFloor)
    if not xCoord then return end

    self:AddMinimapIconWorld(ref, icon, instanceID, xCoord, yCoord, floatOnEdge)

    -- store extra information
    minimapPins[icon].mapID = mapID
    minimapPins[icon].floor = mapFloor
end

--- Check if a floating minimap icon is on the edge of the map
-- @param icon the minimap icon
function pins:IsMinimapIconOnEdge(icon)
    if not icon then return false end
    local data = minimapPins[icon]
    if not data then return nil end

    return data.onEdge
end

--- Remove a minimap icon
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
-- @param icon Icon Frame
function pins:RemoveMinimapIcon(ref, icon)
    if not ref or not icon or not minimapPinRegistry[ref] then return end
    minimapPinRegistry[ref][icon] = nil
    if minimapPins[icon] then
        recycle(minimapPins[icon])
        minimapPins[icon] = nil
        activeMinimapPins[icon] = nil
    end
    icon:Hide()
end

--- Remove all minimap icons belonging to your addon (as tracked by "ref")
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
function pins:RemoveAllMinimapIcons(ref)
    if not ref or not minimapPinRegistry[ref] then return end
    for icon in pairs(minimapPinRegistry[ref]) do
        recycle(minimapPins[icon])
        minimapPins[icon] = nil
        activeMinimapPins[icon] = nil
        icon:Hide()
    end
    wipe(minimapPinRegistry[ref])
end

--- Set the minimap object to position the pins on. Needs to support the usual functions a Minimap-type object exposes.
-- @param minimapObject The new minimap object, or nil to restore the default
function pins:SetMinimapObject(minimapObject)
    pins.Minimap = minimapObject or Minimap
    for pin in pairs(minimapPins) do
        pin:SetParent(pins.Minimap)
    end
    UpdateMinimapPins(true)
end

--- Add a icon to the world map (x/y world coordinate version)
-- Note: This API does not let you specify a floor, as floors are map-specific, not instance/world wide. Use the Map/Floor API to specify a floor.
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
-- @param icon Icon Frame
-- @param instanceID Instance ID of the map to add the icon to
-- @param x X position in world coordinates
-- @param y Y position in world coordinates
function pins:AddWorldMapIconWorld(ref, icon, instanceID, x, y)
    if not ref then
        error(MAJOR..": AddWorldMapIconWorld: 'ref' must not be nil")
    end
    if type(icon) ~= "table" or not icon.SetPoint then
        error(MAJOR..": AddWorldMapIconWorld: 'icon' must be a frame", 2)
    end
    if type(instanceID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error(MAJOR..": AddWorldMapIconWorld: 'instanceID', 'x' and 'y' must be numbers", 2)
    end

    if not worldmapPinRegistry[ref] then
        worldmapPinRegistry[ref] = {}
    end

    worldmapPinRegistry[ref][icon] = true

    local t = worldmapPins[icon] or newCachedTable()
    t.instanceID = instanceID
    t.x = x
    t.y = y
    t.mapID = nil
    t.floor = nil

    worldmapPins[icon] = t

    if WorldMapButton:IsVisible() then
        local currentMapID, currentMapFloor = GetWorldMapLocation()
        if currentMapID and HBD.mapData[currentMapID] and (HBD.mapData[currentMapID].instance == instanceID or currentMapID == WORLDMAP_AZEROTH_ID) then
            PositionWorldMapIcon(icon, t, currentMapID, currentMapFloor)
        else
            icon:Hide()
        end
    end
end

--- Add a icon to the world map (mapid/floor coordinate version)
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
-- @param icon Icon Frame
-- @param mapID Map ID of the map to place the icon on
-- @param mapFloor Floor to place the icon on (or nil for all floors)
-- @param x X position in local/point coordinates (0-1), relative to the zone
-- @param y Y position in local/point coordinates (0-1), relative to the zone
function pins:AddWorldMapIconMF(ref, icon, mapID, mapFloor, x, y)
    if not ref then
        error(MAJOR..": AddWorldMapIconMF: 'ref' must not be nil")
    end
    if type(icon) ~= "table" or not icon.SetPoint then
        error(MAJOR..": AddWorldMapIconMF: 'icon' must be a frame")
    end
    if type(mapID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error(MAJOR..": AddWorldMapIconMF: 'mapID', 'x' and 'y' must be numbers")
    end

    -- convert to world coordinates
    local xCoord, yCoord, instanceID = HBD:GetWorldCoordinatesFromZone(x, y, mapID, mapFloor)
    if not xCoord then return end

    if not worldmapPinRegistry[ref] then
        worldmapPinRegistry[ref] = {}
    end

    worldmapPinRegistry[ref][icon] = true

    local t = worldmapPins[icon] or newCachedTable()
    t.instanceID = instanceID
    t.x = xCoord
    t.y = yCoord
    t.mapID = mapID
    t.floor = mapFloor

    worldmapPins[icon] = t

    if WorldMapButton:IsVisible() then
        local currentMapID, currentMapFloor = GetWorldMapLocation()
        if currentMapID and HBD.mapData[currentMapID] and (HBD.mapData[currentMapID].instance == instanceID or currentMapID == WORLDMAP_AZEROTH_ID)
           and (not mapFloor or (currentMapFloor == mapFloor and (mapFloor == 0 or currentMapID == mapID))) then
            PositionWorldMapIcon(icon, t, currentMapID, currentMapFloor)
        else
            icon:Hide()
        end
    end
end

--- Remove a worldmap icon
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
-- @param icon Icon Frame
function pins:RemoveWorldMapIcon(ref, icon)
    if not ref or not icon or not worldmapPinRegistry[ref] then return end
    worldmapPinRegistry[ref][icon] = nil
    if worldmapPins[icon] then
        recycle(worldmapPins[icon])
        worldmapPins[icon] = nil
    end
    icon:Hide()
end

--- Remove all worldmap icons belonging to your addon (as tracked by "ref")
-- @param ref Reference to your addon to track the icon under (ie. your "self" or string identifier)
function pins:RemoveAllWorldMapIcons(ref)
    if not ref or not worldmapPinRegistry[ref] then return end
    for icon in pairs(worldmapPinRegistry[ref]) do
        recycle(worldmapPins[icon])
        worldmapPins[icon] = nil
        icon:Hide()
    end
    wipe(worldmapPinRegistry[ref])
end

--- Return the angle and distance from the player to the specified pin
-- @param icon icon object (minimap or worldmap)
-- @return angle, distance where angle is in radians and distance in yards
function pins:GetVectorToIcon(icon)
    if not icon then return nil, nil end
    local data = minimapPins[icon] or worldmapPins[icon]
    if not data then return nil, nil end

    local x, y, instance = HBD:GetPlayerWorldPosition()
    if not x or not y or instance ~= data.instanceID then return nil end

    return HBD:GetWorldVector(instance, x, y, data.x, data.y)
end
