-- Contains library functions that do not have a logical place.
---@class Map
---@param utils table
---@param FramePool table
---@param PinMixin table
---@param MapProvider table
local Map = QuestieLoader:CreateModule("Map")

---@type QLMapHandler
local MapHandler = QuestieLoader:ImportModule("MapHandler")

---@type MapCanvasDataProviderMixin
Map.MapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)

WorldMapFrame:AddDataProvider(Map.MapProvider)

MapHandler.RegisterCallback(Map.MapProvider, MapHandler.events.MAP.AVAILABLE_QUESTS_DRAWN, function()
    Map.MapProvider:RefreshAllData(true)
end)


function Map.MapProvider:OnAdded(owningMap)
	-- Optionally override in your mixin, called when this provider is added to a map canvas
	self.owningMap = owningMap;
end

function Map.MapProvider:OnRemoved(owningMap)
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

function Map.MapProvider:RemoveAllData()
    -- Override in your mixin, this method should remove everything that has been added to the map
    print("MapProvider RemoveAllData")
    self:GetMap():RemoveAllPinsByTemplate(Map.worldPinTemplate)
end

function Map.MapProvider:RefreshAllData(fromOnShow)
    --print("RefreshAllData", fromOnShow)
    -- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
    if(fromOnShow == true) then
        self:GetMap():RemoveAllPinsByTemplate(Map.worldPinTemplate)
        --for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
        --    pin:Hide()
        --end
    end
    --print("Drawing UiMapId", MapHandler.events.MAP.DRAW_UIMAPID(self:GetMap():GetMapID()))
    --local runner = coroutine.create(function()
    --    MapHandler.callback:Fire(MapHandler.events.MAP.DRAW_UIMAPID(self:GetMap():GetMapID()))
    --end)

    MapHandler.callback:Fire(MapHandler.events.MAP.DRAW_UIMAPID(self:GetMap():GetMapID()))
    --self:pinFunc()
    --local info = C_Map.GetMapInfo(self:GetMap():GetMapID())
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
    --else
    --    for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
    --        pin.subNotes = nil
    --    end
    --end
end

function Map.MapProvider:OnShow()
    --print("OnShow")
	-- Override in your mixin, called when the map canvas is shown
end

function Map.MapProvider:OnHide()
    --print("OnHide")
    -- Override in your mixin, called when the map canvas is closed
    --pinFuncRoutine = nil
end

function Map.MapProvider:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function Map.MapProvider:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function Map.MapProvider:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function Map.MapProvider:OnCanvasScaleChanged()
    -- Optionally override in your mixin, called when the canvas scale changes
    --print("OnCanvasScaleChanged")
    --self:GetMap():SetGlobalPinScale(0.5);
    --for pin in self:GetMap():EnumeratePinsByTemplate(Map.worldPinTemplate) do
    --    print(pin:GetScale(), pin:GetEffectiveScale())
        --pin:SetScale(1);
    --end
    --self:pinFunc()
    --local info = C_Map.GetMapInfo(self:GetMap():GetMapID())
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

function Map.MapProvider:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
    --print("OnCanvasPanChanged")
end

function Map.MapProvider:OnCanvasSizeChanged()
	-- Optionally override in your mixin, called when the canvas size changes
    --print("OnCanvasSizeChanged")
end

function Map.MapProvider:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

function Map.MapProvider:OnGlobalAlphaChanged()
	-- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function Map.MapProvider:GetMap()
	return self.owningMap;
end

function Map.MapProvider:OnMapChanged()
    --print("OnMapChanged")
    --  Optionally override in your mixin, called when map ID changes
    
    --local info = C_Map.GetMapInfo(self:GetMap():GetMapID())
    --print(info.mapID, info.name, info.mapType, info.parentMapID)
    self:GetMap():RemoveAllPinsByTemplate(Map.worldPinTemplate)
    --for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
    --    pin:Hide()
    --end
    self:RefreshAllData(false);
end

--[[function Map.MapProvider:pinFunc2()
    for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
        local points = {}
        local getEffectiveScale = pin:GetEffectiveScale()

        local bottom = pin:GetBottom()*getEffectiveScale;
        local top = pin:GetTop()*getEffectiveScale;
        local left = pin:GetLeft()*getEffectiveScale;
        local right = pin:GetRight()*getEffectiveScale;
        table.insert(points, {x=left, y=top})
        table.insert(points, {x=left, y=bottom})
        table.insert(points, {x=right, y=top})
        table.insert(points, {x=right, y=bottom})
        for pin2, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
            if(pin ~= pin2) then
                local getEffectiveScale = pin2:GetEffectiveScale()

                local y2 = pin2:GetBottom()*getEffectiveScale;
                local y1 = pin2:GetTop()*getEffectiveScale;
                local x1 = pin2:GetLeft()*getEffectiveScale;
                local x2 = pin2:GetRight()*getEffectiveScale;
                local found = false
                for _, point in pairs(points) do
                    if(point.x > x1 and point.x < x2 and point.y < y1 and point.y > y2) then
                        print("true")
                        pin2.tex:SetVertexColor(1,1,1, 0.5)
                        found = true
                        break
                    end
                end
                if(not found) then 
                    pin2.tex:SetVertexColor(1,1,1, 1)
                end
            end
        end
    end
end
local function euclid(x, y, i, e)
    local xd = math.abs(x - i)
    local yd = math.abs(y - e)
    return math.sqrt(xd * xd + yd * yd)
end
local pinFuncRoutine = nil
function Map.MapProvider:pinFunc()
    local count = 0
    local maxCount = 15--Lerp(10, 20, GetFramerate()*0.3)
    local totalIcons = 0
    local fastIcons = {}
    for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
        pin.subNotes = nil
        totalIcons = totalIcons + 1
        if(not fastIcons[pin.object.UiMapId]) then fastIcons[pin.object.UiMapId] = {} end
        table.insert(fastIcons[pin.object.UiMapId], pin)
    end
    local info = C_Map.GetMapInfo(self:GetMap():GetMapID())
    local visibleIcons = {}
    for pin, bool in self:GetMap():EnumeratePinsByTemplate("QLMapWorldmapTemplate") do
        local points = {}
        local getEffectiveScale = pin:GetEffectiveScale()
        local found = nil;
        local x1, y1 = pin:GetCenter();
        for i = 1, #fastIcons[pin.object.UiMapId] do
        --for _, pin2 in pairs(fastIcons[pin.object.UiMapId]) do
            local pin2 = fastIcons[pin.object.UiMapId][i]
            if(pin ~= pin2 and pin.object.UiMapId == pin2.object.UiMapId and not pin.subNotes) then
                local getEffectiveScale2 = pin2:GetEffectiveScale()
        
                local x2, y2 = pin2:GetCenter();
                local dX = math.abs(x1*getEffectiveScale - x2*getEffectiveScale2)
                local dY = math.abs(y1*getEffectiveScale - y2*getEffectiveScale2)
                --local distance = euclid(x1*getEffectiveScale, y1*getEffectiveScale, x2*getEffectiveScale2, y2*getEffectiveScale2)
                --if(distance < 5) then
                --    found = pin2
                --    break
                --end
                if(dX < 4 and dY < 12) then
                    found = pin2
                    break
                end
            end
        end
        if(found) then
            pin:Hide()
            if(not found.subNotes) then
                found.subNotes = {}
            end
            table.insert(found.subNotes, pin)
            --local x, y = pin:GetPosition()
            --local x2, y2 = found:GetPosition()
            --local nX, nY = (x+x2)/2, (y+y2)/2
            --found:SetPosition(nX, nY)
            --pin.touched = true
        else
            local x, y = pin:GetPosition()
            if(x ~= pin.object.x or y ~= pin.object.y) then
                pin:SetPosition(pin.object.x, pin.object.y)
            end
            pin:Show();
            table.insert(visibleIcons, pin)
        end
        local count = 0
        for _,_ in pairs(pin.object.data.giverIds) do
            count = count + 1
        end
        local normalScale, zoomedScale = 0.8, 1;
        if((pin.subNotes and #pin.subNotes > 1) or count > 1 or (pin.subNotes and #pin.subNotes+count > 1)) then
            normalScale = 1.05
            zoomedScale = 1.25
        end
        if(info.mapType == 2) then-- continent
            normalScale = normalScale * 0.8
            zoomedScale = zoomedScale * 0.8
        elseif(info.mapType == 1) then --World
            normalScale = normalScale * 0.7
            zoomedScale = zoomedScale * 0.7
        end
        pin:SetScalingLimits(1, normalScale, zoomedScale)
        pin:ApplyCurrentScale()

        if(count < maxCount) then
            count = count + 1
        else
            count = 0
            coroutine.yield()
        end
    end
    for _, pin in pairs(visibleIcons) do
        local sX, sY = pin:GetPosition()
        local count = 1
        for _, subNote in pairs(pin.subNotes or {}) do
            local snX, snY = subNote:GetPosition()
            sX = sX + snX
            sY = sY + snY
            count = count + 1
        end

        --local x2, y2 = found:GetPosition()
        local nX, nY = sX/count, sY/count
        pin:SetPosition(nX, nY)
    end
    visibleIcons = nil
end]]--