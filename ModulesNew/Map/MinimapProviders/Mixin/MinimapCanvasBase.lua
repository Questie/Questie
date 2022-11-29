---@class MinimapCanvasMixin
local MinimapCanvasMixin = Mixin(QuestieLoader:CreateModule("MinimapCanvasMixin"), CallbackRegistryMixin);

---@type MapCoordinates
local MapCoordinates = QuestieLoader("MapCoordinates");

-- Up value
local Minimap = Minimap

--? Here we calculate the minimap size in coords
-- TODO: Fix this to work with all minimap sizes and world maps (outlands)
local function GetMinimapWidthFromYards(mapId, yards)
    -- Create a point at the center of any map
    local baseX, baseY = MapCoordinates.Maps[mapId]:ToWorldCoordinate(50, 50)
    -- Get the world position of said map
    local continentId, pos = C_Map.GetWorldPosFromMapPos(mapId, CreateVector2D(0.5, 0.5));
    -- Add the yards you want to measure to the center of the map
    pos:Add(CreateVector2D(yards, yards));
    -- Get the new world position
    local _, mapPosition = C_Map.GetMapPosFromWorldPos(continentId, pos, mapId)
    local xx, yy = mapPosition:GetXY()
    -- Convert the new world position to a coordinate
    local targetX, targetY = MapCoordinates.Maps[mapId]:ToWorldCoordinate((xx * 100), (yy * 100))
    -- Calculate the distance between the center and the new position
    return math.abs(baseX - targetX), math.abs(baseY - targetY)
end

--! Currently only Azeroth
-- local minimap_size = {
--     indoor = {
--         [0] = { GetMinimapWidthFromYards(1413, 300) }, -- scale
--         [1] = { GetMinimapWidthFromYards(1413, 240) }, -- 1.25
--         [2] = { GetMinimapWidthFromYards(1413, 180) }, -- 5/3
--         [3] = { GetMinimapWidthFromYards(1413, 120) }, -- 2.5
--         [4] = { GetMinimapWidthFromYards(1413, 80) }, -- 3.75
--         [5] = { GetMinimapWidthFromYards(1413, 50) }, -- 6
--     },
--     outdoor = {
--         [0] = { GetMinimapWidthFromYards(1413, 466 + 2 / 3) }, -- scale
--         [1] = { GetMinimapWidthFromYards(1413, 400) }, -- 7/6
--         [2] = { GetMinimapWidthFromYards(1413, 333 + 1 / 3) }, -- 1.4
--         [3] = { GetMinimapWidthFromYards(1413, 266 + 2 / 6) }, -- 1.75
--         [4] = { GetMinimapWidthFromYards(1413, 200) }, -- 7/3
--         [5] = { GetMinimapWidthFromYards(1413, 133 + 1 / 3) }, -- 3.5
--     },
-- }

---@type {[1]: number, [2]: number}
local outdoorZoom0 = { GetMinimapWidthFromYards(1413, 466 + 2 / 3) }
---@type {[1]: number, [2]: number}
local indoorZoom0 = { GetMinimapWidthFromYards(1413, 300) }

local minimap_scale = {
    indoor = {
        [0] = 1, -- scale
        [1] = 1.25, -- 1.25
        [2] = 5 / 3, -- 5/3
        [3] = 2.5, -- 2.5
        [4] = 3.75, -- 3.75
        [5] = 6, -- 6
    },
    outdoor = {
        [0] = 1, -- scale
        [1] = 7 / 6, -- 7/6
        [2] = 1.4, -- 1.4
        [3] = 1.75, -- 1.75
        [4] = 7 / 3, -- 7/3
        [5] = 3.5, -- 3.5
    },
}

---@class MinimapShapes
local minimap_shapes = {
    -- { upper-left, lower-left, upper-right, lower-right }
    ["SQUARE"]                = { false, false, false, false },
    ["CORNER-TOPLEFT"]        = { true, false, false, false },
    ["CORNER-TOPRIGHT"]       = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"]     = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
    ["SIDE-LEFT"]             = { true, true, false, false },
    ["SIDE-RIGHT"]            = { false, false, true, true },
    ["SIDE-TOP"]              = { true, false, true, false },
    ["SIDE-BOTTOM"]           = { false, true, false, true },
    ["TRICORNER-TOPLEFT"]     = { true, true, true, false },
    ["TRICORNER-TOPRIGHT"]    = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"]  = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { false, true, true, true },
}

-- This checks if we are indoors or outdoors
-- The logic and solution is made by Nevcairiel and his HereBeDragons library
function MinimapCanvasMixin:UpdateMinimapZoom()
    local zoom = Minimap:GetZoom()
    if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
        Minimap:SetZoom(zoom < 2 and zoom + 1 or zoom - 1)
    end
    self.indoors = GetCVar("minimapZoom") + 0 == Minimap:GetZoom() and "outdoor" or "indoor"
    Minimap:SetZoom(zoom)
    self.lastZoom = zoom
    C_Timer.After(0, function()
        self.updateZoom = false
        -- This acts as a safeguard to prevent an incorrect zoom state
        local doubleCheckZoom = Minimap:GetZoom()
        if self.lastZoom ~= doubleCheckZoom then
            self.lastZoom = doubleCheckZoom
        end
        self.debugText:Print("Zoom", self.lastZoom, self.indoors)
    end)
    -- self.updateZoom = false
end

function MinimapCanvasMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self);
    self:SetUndefinedEventsAllowed(true);

    -- self.detailLayerPool = CreateFramePool("FRAME", self:GetCanvas(), "MapCanvasDetailLayerTemplate");
    self.dataProviders = {};
    self.dataProviderEventsCount = {};
    self.pinPools = {};
    self.pinTemplateTypes = {};
    -- self.activeAreaTriggers = {};
    -- self.lockReasons = {};
    -- self.pinsToNudge = {};
    self.pinFrameLevelsManager = CreateFromMixins(MapCanvasPinFrameLevelsManagerMixin);
    self.pinFrameLevelsManager:Initialize();
    self.mouseClickHandlers = {};

    self.eventFrame = CreateFrame("FRAME");
    self.eventFrame:RegisterEvent("CVAR_UPDATE")
    self.eventFrame:RegisterEvent("MINIMAP_UPDATE_ZOOM")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.eventFrame:SetScript("OnEvent", function(_, ...) self:OnEvent(...) end)

    self.debugText = QuestieLoader("DebugText"):Get("Minimap")

    -- self:EvaluateLockReasons();

    ---@type UiMapId
    self.lastPlayerUiMapId = 0
    self.lastPlayerX = 0
    self.lastPlayerY = 0

    -- This variable is used to know when we are changing the zoom level internally and not by the user
    ---@type boolean
    self.updateZoom = false
    hooksecurefunc(Minimap, "SetZoom", function()
        self.updateZoom = true
    end)

    -- Initialize the zoom
    self:UpdateMinimapZoom()

    -- We want to be able to run at sub 0.05 second intervals so we need to use OnUpdate
    local GetBestMapForUnit = C_Map.GetBestMapForUnit;
    local UnitPosition = UnitPosition;
    local timeElapsed = 0
    -- local lastFacing = 0 -- For rotating
    local ticksSinceLastZoomUpdate = 0
    local baseDistance = 0.5
    local distance = 0.5
    self.eventFrame:SetScript("OnUpdate", function(_, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed >= 0.03125 then -- 30 fps
            timeElapsed = 0 -- Reset the elapsed time
            if self.updateZoom or ticksSinceLastZoomUpdate >= 60 then
                if self.updateZoom or self.lastZoom ~= Minimap:GetZoom() then
                    self:UpdateMinimapZoom()
                    self:UpdateMinimap()
                end
                ticksSinceLastZoomUpdate = 0
                return
            else
                ticksSinceLastZoomUpdate = ticksSinceLastZoomUpdate + 1
            end

            -- What is the distance required to update
            if self.indoors == "outdoor" then
                -- We don't need the faster update rate that zoom 4 would provide
                if self.lastZoom >= 1 then
                    distance = (baseDistance) / minimap_scale.outdoor[self.lastZoom - 1]
                else
                    distance = (baseDistance) / minimap_scale.outdoor[self.lastZoom]
                end
            else
                -- We don't need the faster update rate that zoom 4 would provide
                if self.lastZoom >= 2 then
                    distance = (baseDistance / 2) / minimap_scale.indoor[self.lastZoom - 2]
                else
                    distance = (baseDistance / 2) / minimap_scale.indoor[self.lastZoom]
                end
            end
            self.debugText:Print("MinDistance", distance)


            local playerX, playerY = UnitPosition("player");
            if playerX and playerY then
                local xd = playerX - self.lastPlayerX;
                local yd = playerY - self.lastPlayerY;
                if xd < 0 then xd = -xd end
                if yd < 0 then yd = -yd end
                if (xd * xd + yd * yd) ^ 0.5 > distance then -- ^ 0.5 is sqrt but faster
                    -- if xd * xd + yd * yd > 2*2 then Sqr distance
                    self.lastPlayerX, self.lastPlayerY = playerX, playerY;
                    self.debugText:Print("Distance since lastPos", ((xd * xd + yd * yd) ^ 0.5))
                    self.debugText:Print("WorldPos", GetPlayerWorldPosFast(GetBestMapForUnit("player")))
                    self:UpdateMinimap()
                end
            end
        end
    end)

    -- Debug shit
    -- ---@type FramePoolMinimap
    -- local FramePoolMinimap = QuestieLoader:ImportModule("FramePoolMinimap")
    -- local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
    -- ---@type Button
    -- testFrame = FramePoolMinimap:Acquire()
    -- testFrame:SetFrameStrata("MEDIUM")
    -- testFrame:SetFrameLevel(2000)
    -- testFrame:SetSize(16, 16)
    -- testFrame:SetParent(Minimap)
    -- testFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
    -- testFrame:Show()
    -- local objectTexture = FramePoolMinimap.TexturePool:Acquire();
    -- objectTexture:SetParent(testFrame)
    -- objectTexture:SetPoint("CENTER");
    -- objectTexture:SetTexture(QuestieLib.AddonPath .. "Icons\\available.blp")
    -- objectTexture:SetSize(16, 16)
    -- objectTexture:SetScale(Minimap:GetScale())
    -- objectTexture:Show();
    -- testFrame.textures[#testFrame.textures + 1] = objectTexture

    -- testFrame.x, testFrame.y = GetPlayerWorldPosFast(1413)
end

function MinimapCanvasMixin:UpdateMinimap()
    -- print("MOVED")
    local mapID = C_Map.GetBestMapForUnit("player");
    local x, y = GetPlayerWorldPosFast(mapID)

    local minimapShape = GetMinimapShape and minimap_shapes[GetMinimapShape() or "ROUND"]

    local minimapWidth = Minimap:GetWidth() / 2
    local minimapHeight = Minimap:GetHeight() / 2
    -- local minimapSizeX, minimapSizeY = minimap_size[self.indoors][self.lastZoom][1] / 2, minimap_size[self.indoors][self.lastZoom][2] / 2

    local minimapSizeX, minimapSizeY
    if self.indoors == "outdoor" then
        minimapSizeX, minimapSizeY = outdoorZoom0[1] / minimap_scale.outdoor[self.lastZoom],
            outdoorZoom0[2] / minimap_scale.outdoor[self.lastZoom]
    else
        minimapSizeX, minimapSizeY = indoorZoom0[1] / minimap_scale.indoor[self.lastZoom],
            indoorZoom0[2] / minimap_scale.indoor[self.lastZoom]
    end

    if true then
        return
    end
    -- for rotating minimap support
    -- local facing
    -- if rotateMinimap then
    --     facing = GetPlayerFacing()
    -- else
    --     facing = 0
    -- end


    local xDist, yDist = x - testFrame.x, y - testFrame.y

    -- handle rotation
    -- if rotateMinimap then
    --     local dx, dy = xDist, yDist
    --     local mapSin = sin(facing)
    --     local mapCos = cos(facing)
    --     xDist = dx*mapCos - dy*mapSin
    --     yDist = dx*mapSin + dy*mapCos

    --     print(xDist > 0 and "+" or "-", yDist > 0 and "+" or "-")
    -- end

    -- adapt delta position to the map radius
    local diffX = xDist / (minimapSizeX / 2)
    local diffY = yDist / (minimapSizeY / 2)

    -- different minimap shapes
    ---@type boolean|number
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
        dist = ((diffX * diffX + diffY * diffY) / 0.9 ^ 2)
    else
        dist = (max(diffX * diffX, diffY * diffY) / 0.9 ^ 2)
    end

    -- if distance > 1, then adapt node position to slide on the border
    if dist > 1 then -- float on edge
        dist = dist ^ 0.5
        diffX = diffX / dist
        diffY = diffY / dist
    end

    testFrame:Show()
    testFrame:ClearAllPoints()
    testFrame:SetPoint("CENTER", Minimap, "CENTER", (-diffX * minimapWidth), (diffY * minimapHeight))
end

function MinimapCanvasMixin:OnShow()
    local FROM_ON_SHOW = true;
    self:RefreshAll(FROM_ON_SHOW);

    for dataProvider in pairs(self.dataProviders) do
        dataProvider:OnShow();
    end
end

function MinimapCanvasMixin:OnHide()
    for dataProvider in pairs(self.dataProviders) do
        dataProvider:OnHide();
    end
end

function MinimapCanvasMixin:OnEvent(event, ...)
    print(event, ...)
    if event == "MINIMAP_UPDATE_ZOOM" then -- Player went from outdoors to indoors or vice versa
        self.updateZoom = true
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        ---@type UiMapId
        local playerUiMapId = C_Map.GetBestMapForUnit("player") --[[@as UiMapId]]
        if playerUiMapId ~= self.lastPlayerUiMapId then

            self:OnMapChanged(self.lastPlayerUiMapId, playerUiMapId)
            self.lastPlayerUiMapId = playerUiMapId
        end
    end
    -- Data provider event
    for dataProvider in pairs(self.dataProviders) do
        dataProvider:SignalEvent(event, ...);
    end
end

function MinimapCanvasMixin:AddDataProvider(dataProvider)
    self.dataProviders[dataProvider] = true;
    dataProvider:OnAdded(self);
end

function MinimapCanvasMixin:RemoveDataProvider(dataProvider)
    dataProvider:RemoveAllData();
    self.dataProviders[dataProvider] = nil;
    dataProvider:OnRemoved(self);
end

function MinimapCanvasMixin:AddDataProviderEvent(event)
    self.dataProviderEventsCount[event] = (self.dataProviderEventsCount[event] or 0) + 1;
    self.eventFrame:RegisterEvent(event);
end

function MinimapCanvasMixin:RemoveDataProviderEvent(event)
    if self.dataProviderEventsCount[event] then
        self.dataProviderEventsCount[event] = self.dataProviderEventsCount[event] - 1;
        if self.dataProviderEventsCount[event] == 0 then
            self.dataProviderEventsCount[event] = nil;
            self.eventFrame:UnregisterEvent(event);
        end
    end
end

do
    -- local function OnPinReleased(pinPool, pin)
    --     FramePool_HideAndClearAnchors(pinPool, pin);
    --     pin:OnReleased();

    --     pin.pinTemplate = nil;
    --     pin.owningMap = nil;
    -- end

    local function OnPinMouseUp(pin, button, upInside)
        pin:OnMouseUp(button);
        if upInside then
            pin:OnClick(button);
        end
    end

    function MinimapCanvasMixin:AcquirePin(pinTemplate, ...)
        if not self.pinPools[pinTemplate] then
            -- local pinTemplateType = self.pinTemplateTypes[pinTemplate] or "FRAME";
            -- self.pinPools[pinTemplate] = CreateFramePool(pinTemplateType, self:GetCanvas(), pinTemplate, OnPinReleased);
            error("Pin template not registered: " .. pinTemplate);
        end

        local pin, newPin = self.pinPools[pinTemplate]:Acquire();

        if newPin then
            local isMouseClickEnabled = pin:IsMouseClickEnabled();
            local isMouseMotionEnabled = pin:IsMouseMotionEnabled();

            if isMouseClickEnabled then
                pin:SetScript("OnMouseUp", OnPinMouseUp);
                pin:SetScript("OnMouseDown", pin.OnMouseDown);
            end

            if isMouseMotionEnabled then
                if newPin then
                    -- These will never be called, just define a OnMouseEnter and OnMouseLeave on the pin mixin and it'll be called when appropriate
                    assert(pin:GetScript("OnEnter") == nil);
                    assert(pin:GetScript("OnLeave") == nil);
                end
                pin:SetScript("OnEnter", pin.OnMouseEnter);
                pin:SetScript("OnLeave", pin.OnMouseLeave);
            end

            pin:SetMouseClickEnabled(isMouseClickEnabled);
            pin:SetMouseMotionEnabled(isMouseMotionEnabled);
        end

        pin.pinTemplate = pinTemplate;
        pin.owningMinimap = self;

        if newPin then
            pin:OnLoad();
        end

        -- self.ScrollContainer:MarkCanvasDirty();
        pin:Show();
        pin:OnAcquired(...);

        return pin;
    end
end

function MinimapCanvasMixin:SetPinTemplateType(pinTemplate, pinTemplateType)
    self.pinTemplateTypes[pinTemplate] = pinTemplateType;
end

function MinimapCanvasMixin:RemoveAllPinsByTemplate(pinTemplate)
    if self.pinPools[pinTemplate] then
        self.pinPools[pinTemplate]:ReleaseAll();
        -- self.ScrollContainer:MarkCanvasDirty();
    end
end

function MinimapCanvasMixin:RemovePin(pin)
    if pin:GetNudgeSourceRadius() > 0 then
        self.pinNudgingDirty = true;
    end

    self.pinPools[pin.pinTemplate]:Release(pin);
    -- self.ScrollContainer:MarkCanvasDirty();
end

function MinimapCanvasMixin:EnumeratePinsByTemplate(pinTemplate)
    if self.pinPools[pinTemplate] then
        return self.pinPools[pinTemplate]:EnumerateActive();
    end
    return nop;
end

function MinimapCanvasMixin:GetNumActivePinsByTemplate(pinTemplate)
    if self.pinPools[pinTemplate] then
        return self.pinPools[pinTemplate]:GetNumActive();
    end
    return 0;
end

function MinimapCanvasMixin:EnumerateAllPins()
    local currentPoolKey, currentPool = next(self.pinPools, nil);
    local currentPin = nil;
    return function()
        if currentPool then
            currentPin = currentPool:GetNextActive(currentPin);
            while not currentPin do
                currentPoolKey, currentPool = next(self.pinPools, currentPoolKey);
                if currentPool then
                    currentPin = currentPool:GetNextActive();
                else
                    break;
                end
            end
        end

        return currentPin;
    end, nil;
end

function MinimapCanvasMixin:RefreshAllDataProviders(fromOnShow)
    for dataProvider in pairs(self.dataProviders) do
        dataProvider:RefreshAllData(fromOnShow);
    end
end

function MinimapCanvasMixin:RefreshAll(fromOnShow)
    -- self:RefreshDetailLayers();
    -- self:RefreshInsets();
    self:RefreshAllDataProviders(fromOnShow);
end

function MinimapCanvasMixin:SetPinPosition(pin, normalizedX, normalizedY, insetIndex)
    self:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex);
    if not pin:IgnoresNudging() then
        if pin:GetNudgeSourceRadius() > 0 then
            -- If we nudge other things we need to recalculate all nudging.
            self.pinNudgingDirty = true;
        else
            self.pinsToNudge[#self.pinsToNudge + 1] = pin;
        end
    end
end

function MinimapCanvasMixin:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex)
    if insetIndex then
        if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
            self.mapInsetsByIndex[insetIndex]:SetLocalPinPosition(pin, normalizedX, normalizedY);
            pin:ApplyFrameLevel();
        end
    else
        pin:ClearAllPoints();
        if normalizedX and normalizedY then
            local x = normalizedX;
            local y = normalizedY;

            local nudgeVectorX, nudgeVectorY = pin:GetNudgeVector();
            if nudgeVectorX and nudgeVectorY then
                local finalNudgeFactor = pin:GetNudgeFactor() * pin:GetNudgeTargetFactor() * pin:GetNudgeZoomFactor();
                x = normalizedX + nudgeVectorX * finalNudgeFactor;
                y = normalizedY + nudgeVectorY * finalNudgeFactor;
            end

            local canvas = self:GetCanvas();
            local scale = pin:GetScale();
            pin:SetParent(canvas);
            pin:ApplyFrameLevel();
            pin:SetPoint("CENTER", canvas, "TOPLEFT", (canvas:GetWidth() * x) / scale, -(canvas:GetHeight() * y) / scale);
        end
    end
end

---@param lastUiMapId UiMapId
---@param newUiMapId UiMapId
function MinimapCanvasMixin:OnMapChanged(lastUiMapId, newUiMapId)
    if not lastUiMapId or not newUiMapId then
        error("MinimapCanvas: OnMapChanged called with invalid map IDs");
    end
    for dataProvider in pairs(self.dataProviders) do
        dataProvider:OnMapChanged(lastUiMapId, newUiMapId);
    end
end

function MinimapCanvasMixin:GetPinFrameLevelsManager()
    return self.pinFrameLevelsManager;
end

function MinimapCanvasMixin:ReapplyPinFrameLevels(pinFrameLevelType)
    for pin in self:EnumerateAllPins() do
        if pin:GetFrameLevelType() == pinFrameLevelType then
            pin:ApplyFrameLevel();
        end
    end
end
