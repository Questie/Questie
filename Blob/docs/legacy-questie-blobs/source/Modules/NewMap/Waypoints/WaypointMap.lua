-- Contains library functions that do not have a logical place.
---@class WaypointMap
---@param utils table
---@param FramePool table
---@param PinMixin table
---@param MapProvider table
local WaypointMap = QuestieLoader:CreateModule("WaypointMap")

---@type QLMapHandler
local MapHandler = QuestieLoader:ImportModule("MapHandler")

---@type MapCanvasDataProviderMixin
WaypointMap.MapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)

WorldMapFrame:AddDataProvider(WaypointMap.MapProvider)

MapHandler.RegisterCallback(WaypointMap.MapProvider, MapHandler.events.MAP.AVAILABLE_WAYPOINTS_DRAWN, function()
    WaypointMap.MapProvider:RefreshAllData(true)
end)

function WaypointMap.MapProvider:OnAdded(owningMap)
	-- Optionally override in your mixin, called when this provider is added to a map canvas
	self.owningMap = owningMap;
end

function WaypointMap.MapProvider:OnRemoved(owningMap)
	-- Optionally override in your mixin, called when this provider is removed from a map canvas
	assert(owningMap == self.owningMap);
	self.owningMap = nil;

	if self.registeredEvents then
		for event in pairs(self.registeredEvents) do
			owningMap:UnregisterEvent(event);
		end
		self.registeredEvents = nil;
	end
end

function WaypointMap.MapProvider:RemoveAllData()
    -- Override in your mixin, this method should remove everything that has been added to the map
    print("MapProvider RemoveAllData")
    self:GetMap():RemoveAllPinsByTemplate(WaypointMap.waypointPinTemplate)
end

function WaypointMap.MapProvider:RefreshAllData(fromOnShow)
    --print("RefreshAllData", fromOnShow)
    -- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
    if(fromOnShow == true) then
        self:GetMap():RemoveAllPinsByTemplate(WaypointMap.waypointPinTemplate)
        --for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
        --    pin:Hide()
        --end
    end

    MapHandler.callback:Fire(MapHandler.events.MAP.DRAW_WAYPOINTS_UIMAPID(self:GetMap():GetMapID()))
end

function WaypointMap.MapProvider:OnShow()
    --print("OnShow")
	-- Override in your mixin, called when the map canvas is shown
end

function WaypointMap.MapProvider:OnHide()
    --print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    --pinFuncRoutine = nil
end

function WaypointMap.MapProvider:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function WaypointMap.MapProvider:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function WaypointMap.MapProvider:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function WaypointMap.MapProvider:OnCanvasScaleChanged()
    -- Optionally override in your mixin, called when the canvas scale changes
    --print(self:GetMap():GetCanvasScale())
    --print(self:GetMap():GetCanvasZoomPercent())
    --print("OnCanvasScaleChanged")
    for pin, bool in self:GetMap():EnumeratePinsByTemplate(WaypointMap.waypointPinTemplate) do
        if(pin.lineTexture) then
            --GetCanvasZoomPercent()
            --GetCanvasScale()
            pin.lineTexture:redraw(self:GetMap():GetCanvasScale())
        end
    end
end

function WaypointMap.MapProvider:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
    --print("OnCanvasPanChanged")
end

function WaypointMap.MapProvider:OnCanvasSizeChanged()
	-- Optionally override in your mixin, called when the canvas size changes
    --print("OnCanvasSizeChanged")
end

function WaypointMap.MapProvider:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

function WaypointMap.MapProvider:OnGlobalAlphaChanged()
	-- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function WaypointMap.MapProvider:GetMap()
	return self.owningMap;
end

function WaypointMap.MapProvider:OnMapChanged()
    --print("OnMapChanged")
    --  Optionally override in your mixin, called when map ID changes

    self:GetMap():RemoveAllPinsByTemplate(WaypointMap.waypointPinTemplate)
    self:RefreshAllData(false);
end