---@class MapProvider : MapCanvasDataProvider
local MapProvider = QuestieLoader:CreateModule("MapProvider")
---@type PinTemplates
local PinTemplates = QuestieLoader("PinTemplates")
---@type MapEventBus
local MapEventBus = QuestieLoader("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader("SystemEventBus")

--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip


--? The MapProvider is added at the bottom of the file

---@class MapProvider
MapProvider = Mixin(MapProvider, MapCanvasDataProviderMixin)

-- This is just a localized reference to self:GetMap()
local Map = nil


local isDrawn = false
local lastDrawnMapId = nil

local function RemoveAllPins()
    Map:RemoveAllPinsByTemplate(PinTemplates.MapPinTemplate)
    isDrawn = false
    lastDrawnMapId = nil
end

local function DrawAllPins()
    local mapId = Map:GetMapID()
    if not isDrawn and lastDrawnMapId ~= mapId then
        MapEventBus:Fire(MapEventBus.events.DRAW_RELATION_UIMAPID[mapId])
        isDrawn = true
        lastDrawnMapId = mapId
    end
end

local function Initialize()
    -- Create framelevels for this provider
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelAbove("PIN_FRAME_LEVEL_AREA_POI_COMPLETE", "PIN_FRAME_LEVEL_AREA_POI", 100)
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelAbove("PIN_FRAME_LEVEL_AREA_POI_AVAILABLE", "PIN_FRAME_LEVEL_AREA_POI", 100)
    MapEventBus:RegisterRepeating(MapEventBus.events.REDRAW_ALL_RELATIONS, function()
        if MapProvider and WorldMapFrame:IsVisible() then
            RemoveAllPins()
            DrawAllPins()
        end
    end)
end


-- Run it the next frame
C_Timer.After(0, Initialize)

function MapProvider:OnAdded(owningMap)
    -- Optionally override in your mixin, called when this provider is added to a map canvas
    self.owningMap = owningMap;
    Map = owningMap
end

function MapProvider:OnRemoved(owningMap)
    -- Optionally override in your mixin, called when this provider is removed from a map canvas
    assert(owningMap == self.owningMap);
    self.owningMap = nil;
    Map = nil
end

function MapProvider:RemoveAllData()
    -- Override in your mixin, this method should remove everything that has been added to the map
    print("MapProvider RemoveAllData")
    RemoveAllPins()
end

function MapProvider:RefreshAllData(fromOnShow)
    print("RefreshAllData", fromOnShow)
    DrawAllPins()
end

function MapProvider:OnShow()
    print("OnShow")
    -- Override in your mixin, called when the map canvas is shown
end

function MapProvider:OnHide()
    print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    RemoveAllPins()
    --When we close the map always hide the QuestieTooltip!
    questieTooltip:Hide()
end

function MapProvider:OnMapInsetSizeChanged(mapInsetIndex, expanded)
    -- Optionally override in your mixin, called when a map inset changes sizes
end

function MapProvider:OnMapInsetMouseEnter(mapInsetIndex)
    -- Optionally override in your mixin, called when a map inset gains mouse focus
end

function MapProvider:OnMapInsetMouseLeave(mapInsetIndex)
    -- Optionally override in your mixin, called when a map inset loses mouse focus
end

function MapProvider:OnCanvasScaleChanged()
    -- Optionally override in your mixin, called when the canvas scale changes
    --print("OnCanvasScaleChanged")
    --Map:SetGlobalPinScale(0.5);
    --for pin in Map:EnumeratePinsByTemplate(PinTemplates.MapPinTemplate) do
    --    print(pin:GetScale(), pin:GetEffectiveScale())
    --pin:SetScale(1);
    --end
    --self:pinFunc()
    --local info = C_GetMapInfo(Map:GetMapID())
    --if(info.mapType == 2 or info.mapType == 1) then-- continent--World
    --    if(pinFuncRoutine) then
    --        pinFuncRoutine = nil
    --    end
    --    pinFuncRoutine = coroutine.create(function()
    --        self:pinFunc()
    --    end)
    --    local timer
    --    timer = C_Timer.NewTicker(0, function()
    --        if(pinFuncRoutine and coroutine.status(pinFuncRoutine) == "suspended") then
    --            coroutine.resume(pinFuncRoutine)
    --        elseif(pinFuncRoutine and coroutine.status(pinFuncRoutine) == "dead") then
    --            --print("Cache done!")
    --            timer:Cancel()
    --        elseif(pinFuncRoutine == nil) then
    --            timer:Cancel()
    --        end
    --    end)
    --end
end

function MapProvider:OnCanvasPanChanged()
    -- Optionally override in your mixin, called when the pan location changes
    --print("OnCanvasPanChanged")
end

function MapProvider:OnCanvasSizeChanged()
    -- Optionally override in your mixin, called when the canvas size changes
    --print("OnCanvasSizeChanged")
end

function MapProvider:OnEvent(event, ...)
    -- Override in your mixin to accept events register via RegisterEvent
end

function MapProvider:OnGlobalAlphaChanged()
    -- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function MapProvider:OnMapChanged()
    print("OnMapChanged")
    --  Optionally override in your mixin, called when map ID changes
    RemoveAllPins()
    DrawAllPins()
end

WorldMapFrame:AddDataProvider(MapProvider)
