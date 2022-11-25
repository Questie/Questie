---@class WaypointMapProvider : MapCanvasDataProvider
local WaypointMapProvider = QuestieLoader:CreateModule("WaypointMapProvider")

-- Event Bus --
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader("SystemEventBus")

---@type PinTemplates
local PinTemplates = QuestieLoader:ImportModule("PinTemplates")


--? The WaypointMapProvider is added at the bottom of the file

---@class WaypointMapProvider
WaypointMapProvider = Mixin(WaypointMapProvider, MapCanvasDataProviderMixin)

-- This is just a localized reference to self:GetMap()
local Map = nil


local isDrawn = false
local lastDrawnMapId = nil

local function RemoveAllPins()
    Map:RemoveAllPinsByTemplate(PinTemplates.WaypointPinTemplate)
    isDrawn = false
    lastDrawnMapId = nil
end

local function DrawAllPins()
    local mapId = Map:GetMapID()
    if not isDrawn and lastDrawnMapId ~= mapId then
        MapEventBus:Fire(MapEventBus.events.DRAW_WAYPOINTS_UIMAPID[mapId])
        isDrawn = true
        lastDrawnMapId = mapId
    end
end

local function Initialize()
    -- Create framelevels for this provider
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelBelow("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS", "PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
    MapEventBus:RegisterRepeating(MapEventBus.events.REDRAW_ALL_RELATIONS, function()
        if WaypointMapProvider and WorldMapFrame:IsVisible() then
            RemoveAllPins()
            DrawAllPins()
        end
    end)
end

SystemEventBus:RegisterOnce(SystemEventBus.events.INITIALIZE_DONE, Initialize)

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
    -- print("WaypointMapProvider RemoveAllData")
    RemoveAllPins()
end

function WaypointMapProvider:RefreshAllData(fromOnShow)
    -- print("WaypointMapProvider RefreshAllData", fromOnShow)
    DrawAllPins()
end

function WaypointMapProvider:OnShow()
    -- print("OnShow")
    -- Override in your mixin, called when the map canvas is shown
end

function WaypointMapProvider:OnHide()
    -- print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    RemoveAllPins()
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
    -- print("WaypointMapProvider OnMapChanged")
    --  Optionally override in your mixin, called when map ID changes
    RemoveAllPins()
    DrawAllPins()
end

WorldMapFrame:AddDataProvider(WaypointMapProvider)
