local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@class WaypointMapProvider
local WaypointMapProvider = QuestieLoader:CreateModule("WaypointMapProvider")
---@type FramePoolWaypoint
local FramePoolWaypoint = QuestieLoader:ImportModule("FramePoolWaypoint")

local MapEventBus = QuestieLoader:ImportModule("MapEventBus")

local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip


--? The WaypointMapProvider is added at the bottom of the file

---@class WaypointMapProvider
WaypointMapProvider = Mixin(WaypointMapProvider, MapCanvasDataProviderMixin)

-- This is just a localized reference to self:GetMap()
local Map = nil


local lastDrawnMapId = nil

local function Initialize()
    --PIN_FRAME_LEVEL_AREA_POI
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelBelow("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS", "PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
    MapEventBus:RegisterRepeating(MapEventBus.events.MAP.REDRAW_ALL, function()
        if WaypointMapProvider and WorldMapFrame:IsVisible() then
            WaypointMapProvider:RefreshAllData(true)
        end
    end)
end

-- Run it the next frame
C_Timer.After(0, Initialize)

function WaypointMapProvider:OnAdded(owningMap)
    -- Optionally override in your mixin, called when this provider is added to a map canvas
    self.owningMap = owningMap;
    Map = owningMap
end

function WaypointMapProvider:OnRemoved(owningMap)
    -- Optionally override in your mixin, called when this provider is removed from a map canvas
    assert(owningMap == self.owningMap);
    self.owningMap = nil;
    Map = nil
end

function WaypointMapProvider:RemoveAllData()
    -- Override in your mixin, this method should remove everything that has been added to the map
    print("WaypointMapProvider RemoveAllData")
    Map:RemoveAllPinsByTemplate(FramePoolWaypoint.waypointPinTemplate)
end

local function DrawCall()
    MapEventBus:FireAsync(MapEventBus.events.MAP.DRAW_UIMAPID(Map:GetMapID()), 50)
end

function WaypointMapProvider:RefreshAllData(fromOnShow)
    print("WaypointMapProvider RefreshAllData", fromOnShow)
    if lastDrawnMapId ~= Map:GetMapID() then
        -- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
        if (fromOnShow == true) then
            Map:RemoveAllPinsByTemplate(FramePoolWaypoint.waypointPinTemplate)
        end
        -- local wayPointColor = {r=1, g=0.72, b=0, a=0.5}
        -- local wayPointColorHover = {r=0.93, g=0.46, b=0.13, a=0.8}
        -- local defaultLineDataMap = {thickness=4}
        -- Mixin(defaultLineDataMap, wayPointColor)
        -- local Pin = Map:AcquirePin(FramePoolWaypoint.waypointPinTemplate)
        -- Pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS")
        -- Pin:DrawLine(Map:GetMapID(), 0, 0, 1, 1, defaultLineDataMap)
        -- Pin:Show();
        -- ThreadLib.ThreadSimple(DrawCall, 0)
        MapEventBus:Fire(MapEventBus.events.MAP.DRAW_WAYPOINTS_UIMAPID(Map:GetMapID()))

        lastDrawnMapId = Map:GetMapID()
    end
end

function WaypointMapProvider:OnShow()
    print("OnShow")
    -- Override in your mixin, called when the map canvas is shown
end

function WaypointMapProvider:OnHide()
    print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    Map:RemoveAllPinsByTemplate(FramePoolWaypoint.waypointPinTemplate)
    lastDrawnMapId = nil
end

function WaypointMapProvider:OnMapInsetSizeChanged(mapInsetIndex, expanded)
    -- Optionally override in your mixin, called when a map inset changes sizes
end

function WaypointMapProvider:OnMapInsetMouseEnter(mapInsetIndex)
    -- Optionally override in your mixin, called when a map inset gains mouse focus
end

function WaypointMapProvider:OnMapInsetMouseLeave(mapInsetIndex)
    -- Optionally override in your mixin, called when a map inset loses mouse focus
end

function WaypointMapProvider:OnCanvasScaleChanged()
    --? Shrinks the width of the line when zooming in
    local canvasScale = Map:GetCanvasScale()
    for pin, bool in self:GetMap():EnumeratePinsByTemplate(FramePoolWaypoint.waypointPinTemplate) do
        if(pin.lineTexture) then
            --GetCanvasZoomPercent()
            --GetCanvasScale()
            pin.lineTexture:redraw(canvasScale)
        end
    end
end

function WaypointMapProvider:OnCanvasPanChanged()
    -- Optionally override in your mixin, called when the pan location changes
    --print("OnCanvasPanChanged")
end

function WaypointMapProvider:OnCanvasSizeChanged()
    -- Optionally override in your mixin, called when the canvas size changes
    --print("OnCanvasSizeChanged")
end

function WaypointMapProvider:OnEvent(event, ...)
    -- Override in your mixin to accept events register via RegisterEvent
end

function WaypointMapProvider:OnGlobalAlphaChanged()
    -- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function WaypointMapProvider:OnMapChanged()
    print("WaypointMapProvider OnMapChanged")
    --  Optionally override in your mixin, called when map ID changes

    --local info = C_GetMapInfo(Map:GetMapID())
    --print(info.mapID, info.name, info.mapType, info.parentMapID)
    --for pin, bool in Map:EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
    --    pin:Hide()
    --end
    if lastDrawnMapId ~= Map:GetMapID() then
        Map:RemoveAllPinsByTemplate(FramePoolWaypoint.waypointPinTemplate)
        self:RefreshAllData(false);
    end
end

WorldMapFrame:AddDataProvider(WaypointMapProvider)
