local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@class MapProvider
local MapProvider = QuestieLoader:CreateModule("MapProvider")

local MapEventBus = QuestieLoader:ImportModule("MapEventBus")

local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip


--? The MapProvider is added at the bottom of the file

---@class MapProvider
MapProvider = Mixin(MapProvider, MapCanvasDataProviderMixin)

-- This is just a localized reference to self:GetMap()
local Map = nil


local lastDrawnMapId = nil

local function Initialize()
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelBelow("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS", "PIN_FRAME_LEVEL_AREA_POI")
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelAbove("PIN_FRAME_LEVEL_AREA_POI_COMPLETE", "PIN_FRAME_LEVEL_AREA_POI", 100)
    WorldMapFrame:GetPinFrameLevelsManager():InsertFrameLevelAbove("PIN_FRAME_LEVEL_AREA_POI_AVAILABLE", "PIN_FRAME_LEVEL_AREA_POI", 100)
    MapEventBus:RegisterRepeating(MapEventBus.events.MAP.REDRAW_ALL, function()
        if MapProvider then
            MapProvider:RefreshAllData(true)
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
    Map:RemoveAllPinsByTemplate(worldPinTemplate)
end

local function DrawCall()
    MapEventBus:FireAsync(MapEventBus.events.MAP.DRAW_UIMAPID(Map:GetMapID()), 50)
end

function MapProvider:RefreshAllData(fromOnShow)
    print("RefreshAllData", fromOnShow)
    if lastDrawnMapId ~= Map:GetMapID() or fromOnShow == true then
        -- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
        if (fromOnShow == true) then
            Map:RemoveAllPinsByTemplate(worldPinTemplate)
        end
        -- ThreadLib.ThreadSimple(DrawCall, 0)
        MapEventBus:Fire(MapEventBus.events.MAP.DRAW_UIMAPID(Map:GetMapID()))

        lastDrawnMapId = Map:GetMapID()
    end


    -- local Pin = Map:AcquirePin(worldPinTemplate)
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


    -- local Pin2 = Map:AcquirePin(worldPinTemplate)
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

    -- local Pin3 = Map:AcquirePin(worldPinTemplate)
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

function MapProvider:OnShow()
    print("OnShow")
    -- Override in your mixin, called when the map canvas is shown
end

function MapProvider:OnHide()
    print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    Map:RemoveAllPinsByTemplate(worldPinTemplate)
    --When we close the map always hide the QuestieTooltip!
    questieTooltip:Hide()
    lastDrawnMapId = nil
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
    --for pin in Map:EnumeratePinsByTemplate(worldPinTemplate) do
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

    --local info = C_GetMapInfo(Map:GetMapID())
    --print(info.mapID, info.name, info.mapType, info.parentMapID)
    --for pin, bool in Map:EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
    --    pin:Hide()
    --end
    if lastDrawnMapId ~= Map:GetMapID() then
        Map:RemoveAllPinsByTemplate(worldPinTemplate)
        self:RefreshAllData(false);
    end
end

WorldMapFrame:AddDataProvider(MapProvider)
