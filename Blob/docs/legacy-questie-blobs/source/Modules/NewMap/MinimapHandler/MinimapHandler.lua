-- Contains library functions that do not have a logical place.
---@class MinimapHandler
---@field RegisterCallback fun(self:table|string, eventName:string, method:fun(), args:...)
---@field UnregisterCallback fun(self:table|string, eventName:string)
---@field UnregisterAllCallbacks fun(self:table|string) @Maybe self:any works...
local MinimapHandler = QuestieLoader:CreateModule("MinimapHandler")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---@type Callbacks
-----@field Fire fun(eventName:string, args:...)
MinimapHandler.callback = LibStub("CallbackHandler-1.0"):New(MinimapHandler)

MinimapHandler.events = {
    MINIMAP = {
        SPAWN_UIMAPID = function(UiMapId) return string.format("MINIMAP-SPAWN_UIMAPID_%d", UiMapId) end,
        DESPAWN_UIMAPID = function(UiMapId) return string.format("MINIMAP-DESPAWN_UIMAPID_%d", UiMapId) end,
        RESPAWN_ALL = "MINIMAP-RESPAWN_ALL"
  }
}

local activeIcons = setmetatable({}, {__mode="k"})

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local updateFrame = CreateFrame("Frame")

local WoW90 = select(4, GetBuildInfo()) >= 90000

-- store a reference to the active minimap object
local Minimap = Minimap

local minimapPins = {}

-- Data Constants
local WORLD_MAP_ID = 947

-- upvalue lua api
local cos, sin, max = math.cos, math.sin, math.max
local type, pairs = type, pairs

-- upvalue wow api
local GetPlayerFacing = GetPlayerFacing

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

--Questie Modification
local minimap_scale = {
    indoor = {
        [0] = 1, -- scale
        [1] = 1.25, -- 1.25
        [2] = 5/3, -- 5/3
        [3] = 2.5, -- 2.5
        [4] = 3.75,  -- 3.75
        [5] = 6,  -- 6
    },
    outdoor = {
        [0] = 1, -- scale
        [1] = 7/6,       -- 7/6
        [2] = 1.4, -- 1.4
        [3] = 1.75, -- 1.75
        [4] = 7/3,       -- 7/3
        [5] = 3.5, -- 3.5
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


-------------------------------------------------------------------------------------------
-- Minimap pin position logic

-- minimap rotation
local rotateMinimap = GetCVar("rotateMinimap") == "1"

-- is the minimap indoors or outdoors
local indoors = GetCVar("minimapZoom")+0 == Minimap:GetZoom() and "outdoor" or "indoor"

local minimapPinCount, queueFullUpdate = 0, false
local minimapScale, minimapShape, mapRadius, minimapWidth, minimapHeight, mapSin, mapCos
local lastZoom, lastFacing, lastXY, lastYY

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

        -- Questie Modification.
    -- data.floatOnEdge is replaced by (data.floatOnEdge and ((pin.texture and pin.texture.a and pin.texture.a ~= 0) or pin.texture == nil))
    -- icons will now only float on edge if they have an opacity which is not 0 or if no texture exist.
    data.distanceFromMinimapCenter = dist
    if(dist <= 6 + lastZoom and pin.minimapScale) then
        pin:Show()
        pin:ClearAllPoints()
        local minimapScale = minimap_scale[indoors][lastZoom] * (pin.minimapScale[indoors])
        pin:SetPoint("CENTER", Minimap, "CENTER", (diffX * minimapWidth)/minimapScale, (-diffY * minimapHeight)/minimapScale)
        --If the zoom is different, rescale the polygons and lines
        if(lastZoom ~= data.lastZoom or indoors ~= data.lastIndoorState) then
            pin:SetScale(minimapScale)
            if(pin.redrawAllLines) then
                pin.redrawAllLines(pin, minimapScale)
            end
            data.lastZoom = lastZoom;
            data.lastIndoorState = indoors;
        end
    elseif dist <= 1 or (data.floatOnEdge and ((pin.texture and pin.texture.a and pin.texture.a ~= 0) or pin.texture == nil)) then
        pin:Show()
        pin:ClearAllPoints()
        pin:SetPoint("CENTER", Minimap, "CENTER", (diffX * minimapWidth), (-diffY * minimapHeight))

        data.onEdge = (dist > 1)
    else
        pin:Hide()
        data.onEdge = nil
        pin.keep = nil
    end

    --if dist <= 1 or data.floatOnEdge then
    --    pin:Show()
    --    pin:ClearAllPoints()
    --    pin:SetPoint("CENTER", Minimap, "CENTER", diffX * minimapWidth, -diffY * minimapHeight)
    --    data.onEdge = (dist > 1)
    --else
    --    pin:Hide()
    --    data.onEdge = nil
    --    pin.keep = nil
    --end
end

--local function IsParentMap(originMapId, toCheckMapId)
--    local parentMapID = HBD.mapData[originMapId].parent
--    while parentMapID and HBD.mapData[parentMapID] do
--        local mapType = HBD.mapData[parentMapID].mapType
--        if mapType ~= Enum.UIMapType.Zone and mapType ~= Enum.UIMapType.Dungeon and mapType ~= Enum.UIMapType.Micro then
--            return false
--        end
--        if parentMapID == toCheckMapId then
--            return true
--        end
--        parentMapID = HBD.mapData[parentMapID].parent
--    end
--    return false
--end

local function UpdateMinimapPins(force)
    -- get the current player position
    local x, y, instanceID = HBD:GetPlayerWorldPosition()
    local mapID = HBD:GetPlayerZone()

    -- get data from the API for calculations
    local zoom = Minimap:GetZoom()
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
        --TODO!!
        --for pin in pairs(activeMinimapPins) do
        --    pin:Hide()
        --    activeMinimapPins[pin] = nil
        --end
        return
    end

    local newScale = Minimap:GetScale()
    if minimapScale ~= newScale then
        minimapScale = newScale
        force = true
    end

    if x ~= lastXY or y ~= lastYY or diffZoom or facing ~= lastFacing or force then
        -- minimap information
        minimapShape = GetMinimapShape and minimap_shapes[GetMinimapShape() or "ROUND"]
        minimapWidth = Minimap:GetWidth() / 2
        minimapHeight = Minimap:GetHeight() / 2
        if WoW90 then
            mapRadius = C_Minimap.GetViewRadius()
        else
            mapRadius = minimap_size[indoors][zoom] / 2
        end

        -- update upvalues for icon placement
        lastZoom = zoom
        lastFacing = facing
        lastXY, lastYY = x, y

        if rotateMinimap then
            mapSin = sin(facing)
            mapCos = cos(facing)
        end

        local minimapWidth, minimapHeight = Minimap:GetSize()
        for pin, data in pairs(minimapPins) do
            if instanceID == data.instanceID and math.abs(x-data.x) + math.abs(y-data.y) < 500 then --if data.instanceID == instanceID and (not data.uiMapID or data.uiMapID == mapID or (data.showInParentZone and IsParentMap(data.uiMapID, mapID))) then
                --activeMinimapPins[pin] = data
                data.visible = true
                -- draw the pin (this may reset data.keep if outside of the map)
                minimapPinCount = minimapPinCount + 1
                drawMinimapPin(pin, data)
            else
                data.visible = false
            end
        end

        --minimapPinCount = 0
        --for pin, data in pairs(activeMinimapPins) do
        --    if not data.keep then
        --        pin:Hide()
        --        activeMinimapPins[pin] = nil
        --    else
        --        minimapPinCount = minimapPinCount + 1
        --        data.keep = nil
        --    end
        --end
    end
end

local function UpdateMinimapIconPosition()
    -- get the current map  zoom
    local zoom = Minimap:GetZoom()
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
    local newScale = Minimap:GetScale()
    if minimapScale ~= newScale then
        minimapScale = newScale
        refresh = true
    end

    if x ~= lastXY or y ~= lastYY or facing ~= lastFacing or refresh then
        -- update radius of the map
        if WoW90 then
            mapRadius = C_Minimap.GetViewRadius()
        else
            mapRadius = minimap_size[indoors][zoom] / 2
        end
        -- update upvalues for icon placement
        lastXY, lastYY = x, y
        lastFacing = facing

        if rotateMinimap then
            mapSin = sin(facing)
            mapCos = cos(facing)
        end

        -- iterate all nodes and check if they are still in range of our minimap display
        for pin, data in pairs(minimapPins) do
            if(data.visible) then
                -- update the position of the node
                drawMinimapPin(pin, data)
            end
        end
    end
end

local function UpdateMinimapZoom()
    if not WoW90 then
        local zoom = Minimap:GetZoom()
        if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
            Minimap:SetZoom(zoom < 2 and zoom + 1 or zoom - 1)
        end
        indoors = GetCVar("minimapZoom")+0 == Minimap:GetZoom() and "outdoor" or "indoor"
        Minimap:SetZoom(zoom)
    end
end

local spawnedUiMapIds = {}
local function diffUiMapIds(currentPlayerUIMapID)
    if(type(currentPlayerUIMapID) ~="number") then
        currentPlayerUIMapID = C_Map.GetBestMapForUnit("player")
    end
    if(currentPlayerUIMapID) then
        for UiMapId, _ in pairs(spawnedUiMapIds) do
            local found = false
            local info = C_Map.GetMapInfo(UiMapId)
            for _, nearbyUiMapId in pairs(NearbyZonesUiMapId[currentPlayerUIMapID] or {}) do
                if(UiMapId == nearbyUiMapId) then
                    found = true
                    spawnedUiMapIds[UiMapId] = true
                    break
                end
            end
            if(not found) then
                spawnedUiMapIds[UiMapId] = false
            end
        end
        
        spawnedUiMapIds[currentPlayerUIMapID] = true
        for _, nearbyUiMapId in pairs(NearbyZonesUiMapId[currentPlayerUIMapID] or {}) do
            local info = C_Map.GetMapInfo(nearbyUiMapId)
            if(info.mapType == 3) then --Zone
                spawnedUiMapIds[nearbyUiMapId] = true
            end
        end

        for UiMapId, active in pairs(spawnedUiMapIds) do
            local info = C_Map.GetMapInfo(UiMapId)
            if(active) then
                print("Spawn", UiMapId, info.name)
                MinimapHandler.callback:Fire(MinimapHandler.events.MINIMAP.SPAWN_UIMAPID(UiMapId));
            else
                print("Despawn", UiMapId, info.name)
                MinimapHandler.callback:Fire(MinimapHandler.events.MINIMAP.DESPAWN_UIMAPID(UiMapId));
                spawnedUiMapIds[UiMapId] = nil
            end
        end
    end
end

-- map event handling
local function UpdateMinimap(event, currentPlayerUIMapID, currentPlayerUIMapType)
    if(currentPlayerUIMapID == nil) then currentPlayerUIMapID = C_Map.GetBestMapForUnit("player") end
    print("UpdateMinimap", currentPlayerUIMapID, currentPlayerUIMapType)
    --Questie Modification
    diffUiMapIds(currentPlayerUIMapID)

    UpdateMinimapZoom()
    UpdateMinimapPins()
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
updateFrame:SetScript("OnUpdate", OnUpdateHandler)

local function OnEventHandler(frame, event, ...)
    if event == "CVAR_UPDATE" then
        local cvar, value = ...
        if cvar == "ROTATE_MINIMAP" then
            rotateMinimap = (value == "1")
            queueFullUpdate = true
        end
    elseif event == "MINIMAP_UPDATE_ZOOM" then
        UpdateMinimap()
    elseif event == "PLAYER_LOGIN" then
        -- recheck cvars after login
        rotateMinimap = GetCVar("rotateMinimap") == "1"
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateMinimap()
    end
end

updateFrame:SetScript("OnEvent", OnEventHandler)
updateFrame:UnregisterAllEvents()
updateFrame:RegisterEvent("CVAR_UPDATE")
updateFrame:RegisterEvent("MINIMAP_UPDATE_ZOOM")
updateFrame:RegisterEvent("PLAYER_LOGIN")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

HBD.RegisterCallback(MinimapHandler, "PlayerZoneChanged", UpdateMinimap)

local function spawnIcon(self)
    self.spawned = true
    activeIcons[self] = true
end

local function despawnIcon(self)
    self.spawned = nil
    activeIcons[self] = nil
end

--- Add a icon to the minimap (x/y world coordinate version)
-- Note: This API does not let you specify a map to limit the pin to, it'll be shown on all maps these coordinates are valid for.
-- @param icon Icon Frame
-- @param instanceID Instance ID of the map to add the icon to
-- @param x X position in world coordinates
-- @param y Y position in world coordinates
-- @param floatOnEdge flag if the icon should float on the edge of the minimap when going out of range, or hide immediately (default false)
function MinimapHandler:AddMinimapIconWorld(icon, instanceID, x, y, floatOnEdge)
    if type(icon) ~= "table" or not icon.SetPoint then
        error("AddMinimapIconWorld: 'icon' must be a frame", 2)
    end
    if type(instanceID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error("AddMinimapIconWorld: 'instanceID', 'x' and 'y' must be numbers", 2)
    end

    local t = {instanceID=instanceID, x=x, y=y, floatOnEdge=floatOnEdge, uiMapId=nil, showInParentZone=nil}
    --t.instanceID = instanceID
    --t.x = x
    --t.y = y
    --t.floatOnEdge = floatOnEdge
    --t.uiMapID = nil
    --t.showInParentZone = nil

    minimapPins[icon] = t
    queueFullUpdate = true
end

--- Add a icon to the minimap (UiMapID zone coordinate version)
-- The pin will only be shown on the map specified, or optionally its parent map if specified
-- @param icon Icon Frame
-- @param uiMapID uiMapID of the map to place the icon on
-- @param x X position in local/point coordinates (0-1), relative to the zone
-- @param y Y position in local/point coordinates (0-1), relative to the zone
-- @param showInParentZone flag if the icon should be shown in its parent zone - ie. an icon in a microdungeon in the outdoor zone itself (default false)
-- @param floatOnEdge flag if the icon should float on the edge of the minimap when going out of range, or hide immediately (default false)
function MinimapHandler:AddMinimapIconMap(icon, UiMapId, x, y, showInParentZone, floatOnEdge)
    if type(icon) ~= "table" or not icon.SetPoint then
        error("AddMinimapIconMap: 'icon' must be a frame", 2)
    end
    if type(UiMapId) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error("AddMinimapIconMap: 'uiMapID', 'x' and 'y' must be numbers", 2)
    end

    -- convert to world coordinates and use our known adding function
    local xCoord, yCoord, instanceID = HBD:GetWorldCoordinatesFromZone(x, y, UiMapId)
    if not xCoord then return end

    self:AddMinimapIconWorld(icon, instanceID, xCoord, yCoord, floatOnEdge)

    --MinimapHandler.RegisterCallback(icon, MinimapHandler.events.MINIMAP.SPAWN_UIMAPID(UiMapId), spawnIcon, icon)

    ---local addedUiMapIds = {}
    ---for _, UiMapIdRelated in pairs(NearbyZonesUiMapId[UiMapId] or {}) do
    ---    if(UiMapIdRelated ~= UiMapId and not addedUiMapIds[UiMapIdRelated]) then -- 3= zone
    ---        addedUiMapIds[UiMapIdRelated] = true
    ---    end
    ---end
    ---local info = C_Map.GetMapInfo(UiMapId)
    ---if(info.parentMapID ~= 0 and not addedUiMapIds[info.parentMapID]) then
    ---    local parentMapInfo = C_Map.GetMapInfo(info.parentMapID)
    ---    if(parentMapInfo.mapType == 2) then --2=Continent
    ---        addedUiMapIds[info.parentMapID] = true
    ---    end
    ---end

    -- store extra information
    minimapPins[icon].UiMapId = UiMapId
    minimapPins[icon].showInParentZone = showInParentZone
end

function MinimapHandler:RemoveIcon(icon)
    icon:Hide()
    icon.lineTexture:Hide()
    minimapPins[icon] = nil
end

MinimapHandler.RegisterCallback(MinimapHandler, MinimapHandler.events.MINIMAP.RESPAWN_ALL, diffUiMapIds)