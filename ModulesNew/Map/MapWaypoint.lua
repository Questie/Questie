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
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelBelow("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS", "PIN_FRAME_LEVEL_AREA_POI")
    MapEventBus:RegisterRepeating(MapEventBus.events.MAP.REDRAW_ALL, function()
        if WaypointMapProvider then
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
    if lastDrawnMapId ~= Map:GetMapID() or fromOnShow == true then
        -- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
        if (fromOnShow == true) then
            Map:RemoveAllPinsByTemplate(FramePoolWaypoint.waypointPinTemplate)
        end
        local wayPointColor = {r=1, g=0.72, b=0, a=0.5}
        local wayPointColorHover = {r=0.93, g=0.46, b=0.13, a=0.8}
        local defaultLineDataMap = {thickness=4}
        Mixin(defaultLineDataMap, wayPointColor)
        -- ThreadLib.ThreadSimple(DrawCall, 0)
        -- MapEventBus:Fire(MapEventBus.events.MAP.DRAW_UIMAPID(Map:GetMapID()))
        local Pin = Map:AcquirePin(FramePoolWaypoint.waypointPinTemplate)
        Pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS")
        Pin:DrawLine(Map:GetMapID(), 0, 0, 1, 1, defaultLineDataMap)
        Pin:Show();

        lastDrawnMapId = Map:GetMapID()
    end


    -- local Pin = Map:AcquirePin(FramePoolWaypoint.waypointPinTemplate)
    -- -- Pin:SetNudgeSourceRadius(1)
    -- -- -- Pin:SetNudgeSourceMagnitude(4, 1);
    -- -- -- Pin:ClearNudgeSettings()
    -- -- Pin:SetNudgeTargetFactor(0.0125);
    -- -- Pin:SetNudgeSourceMagnitude(1,1)
    -- -- Pin:SetNudgeZoomedOutFactor(1.25);
    -- -- Pin:SetNudgeZoomedInFactor(1);
    -- -- Pin:SetPosition(0.5, 0.5)
    -- local iconTexture = TexturePool:Acquire();
    -- iconTexture:ClearAllPoints();
    -- Pin:SetSize(16, 16);
    -- iconTexture:SetParent(Pin)
    -- iconTexture:SetPoint("CENTER");
    -- iconTexture:SetTexture(QuestieLib.AddonPath.."Icons\\available.blp",nil, nil, "LINEAR")
    -- iconTexture:SetSize(16,16)
    -- iconTexture:Show();
    -- table.insert(Pin.textures, iconTexture)
    -- Pin:SetPosition(0.5, 0.5001)
    -- Pin:Show();
    -- Pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_AVAILABLE", Round(0.5*100))
    -- Pin:ApplyFrameLevel()


    -- local Pin2 = Map:AcquirePin(FramePoolWaypoint.waypointPinTemplate)
    -- -- Pin2:SetNudgeSourceRadius(1)
    -- -- -- Pin2:SetNudgeSourceMagnitude(4, 1);
    -- -- Pin2:SetNudgeTargetFactor(0.0125);
    -- -- Pin2:SetNudgeSourceMagnitude(1,1)
    -- -- Pin2:SetNudgeZoomedOutFactor(1.25);
    -- -- Pin2:SetNudgeZoomedInFactor(1);
    -- local iconTexture = TexturePool:Acquire();
    -- iconTexture:ClearAllPoints();
    -- Pin2:SetSize(16, 16);
    -- iconTexture:SetParent(Pin2)
    -- iconTexture:SetPoint("CENTER");
    -- iconTexture:SetTexture(QuestieLib.AddonPath.."Icons\\explore.tga",nil, nil, "TRILINEAR")
    -- iconTexture:SetSize(16,16)
    -- iconTexture:Show();
    -- table.insert(Pin2.textures, iconTexture)
    -- Pin2:SetPosition(0.5005, 0.5)
    -- Pin2:Show();
    -- Pin2:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_AVAILABLE", Round(0.5*100))
    -- Pin2:ApplyFrameLevel()

    -- local Pin3 = Map:AcquirePin(FramePoolWaypoint.waypointPinTemplate)
    -- -- Pin3:SetNudgeSourceRadius(1)
    -- -- -- Pin3:SetNudgeSourceMagnitude(4, 1);
    -- -- Pin3:SetNudgeTargetFactor(0.0125);
    -- -- Pin3:SetNudgeSourceMagnitude(1,1)
    -- -- Pin3:SetNudgeZoomedOutFactor(1.25);
    -- -- Pin3:SetNudgeZoomedInFactor(1);
    -- local iconTexture = TexturePool:Acquire();
    -- iconTexture:ClearAllPoints();
    -- Pin3:SetSize(16, 16);
    -- iconTexture:SetParent(Pin3)
    -- iconTexture:SetPoint("CENTER");
    -- iconTexture:SetTexture(QuestieLib.AddonPath.."Icons\\explore.tga",nil, nil, "TRILINEAR")
    -- iconTexture:SetSize(16,16)
    -- iconTexture:Show();
    -- table.insert(Pin3.textures, iconTexture)
    -- Pin3:SetPosition(0.5, 0.5005)
    -- Pin3:Show();
    -- Pin3:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_AVAILABLE", Round(0.51*100))
    -- Pin3:ApplyFrameLevel()
end

function WaypointMapProvider:OnShow()
    print("OnShow")
    -- Override in your mixin, called when the map canvas is shown
end

function WaypointMapProvider:OnHide()
    print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    Map:RemoveAllPinsByTemplate(FramePoolWaypoint.waypointPinTemplate)
    --When we close the map always hide the QuestieTooltip!
    questieTooltip:Hide()
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
    for pin, bool in self:GetMap():EnumeratePinsByTemplate(FramePoolWaypoint.waypointPinTemplate) do
        if(pin.lineTexture) then
            --GetCanvasZoomPercent()
            --GetCanvasScale()
            pin.lineTexture:redraw(Map:GetCanvasScale())
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
