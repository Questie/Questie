-------------------------
--Import modules.
-------------------------
---@type Blob
local Blob = QuestieLoader:ImportModule("Blob");

---@class BlobMap
Blob.Map = {}
Blob.Map.WorldMapPins = {}

---@type MapCanvasDataProviderMixin
BlobMapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)

function BlobMapProvider:RemoveAllData()
    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:RemoveAllData")
    -- Override in your mixin, this method should remove everything that has been added to the map
    self:GetMap():RemoveAllPinsByTemplate(Blob.worldPinTemplate)
end

function BlobMapProvider:OnMapChanged()
    --  Optionally override in your mixin, called when map ID changes
    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:OnMapChanged:", self:GetMap():GetMapID())
    self:GetMap():RemoveAllPinsByTemplate(Blob.worldPinTemplate)
    self:RefreshAllData(false);
end


--module function to be able to use the profiler properly
function Blob.Map:RefreshAllData(self, fromOnShow)
    --if(Blob.Areas[self:GetMap():GetMapID()]) then
    --    for QuestId, ObjectiveList in pairs(Blob.Areas[self:GetMap():GetMapID()]) do
    --        for ObjectiveIndex, hotzones in pairs(ObjectiveList) do
    --            for index, hotzone in pairs(hotzones or {}) do
    --                if(table.getn(hotzone) > 4) then
    --                    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:Color:",hotzone[1].IconColor)
    --                    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:Quest: ID:", QuestId, "ObjIndex:", ObjectiveIndex)
    --                    local color = hotzone[1].IconColor
    --                    Blob:DrawPointList(hotzone, color[1], color[2], color[3])
    --                end
    --            end
    --        end
    --    end
    --end

    for _, drawData in pairs(Blob.DrawData[self:GetMap():GetMapID()] or {}) do
        local frame = BlobMapProvider:GetMap():AcquirePin(drawData.pinTemplate)
        Blob:DrawPointList(frame, drawData)
    end
end

function BlobMapProvider:RefreshAllData(fromOnShow)
	-- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:RefreshAllData", fromOnShow)
    --On show we want to clear the map first, not to have any old stuff left!
    if(fromOnShow == true) then
        self:GetMap():RemoveAllPinsByTemplate(Blob.worldPinTemplate)
    end
    Blob.Map:RefreshAllData(self, fromOnShow);
end

function BlobMapProvider:OnShow()
    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:OnShow")
	-- Override in your mixin, called when the map canvas is shown
end

function BlobMapProvider:OnHide()
    Questie:Debug(DEBUG_DEVELOP, "BlobMapProvider:OnHide")
    self:GetMap():RemoveAllPinsByTemplate(Blob.worldPinTemplate)
	-- Override in your mixin, called when the map canvas is closed
end

--[[Unused
function BlobMapProvider:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function BlobMapProvider:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function BlobMapProvider:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function BlobMapProvider:OnCanvasScaleChanged()
	-- Optionally override in your mixin, called when the canvas scale changes
end

function BlobMapProvider:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function BlobMapProvider:OnCanvasSizeChanged()
	-- Optionally override in your mixin, called when the canvas size changes
end

function BlobMapProvider:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

function BlobMapProvider:OnGlobalAlphaChanged()
	-- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end
]]--


------ PIN

---@type MapCanvasPinMixin
BlobMapPin  = CreateFromMixins(MapCanvasPinMixin)

--- OVERRIDE FUNCTIONS, You can override these but might have to implement some of the features yourself 
-- i.e click through, pan etc

function BlobMapPin:OnMouseDown()
    -- Override in your mixin, called when the mouse is pressed on this pin
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnMouseDown", "LeftButton")
    if(IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseDown("LeftButton")
    end
end

function BlobMapPin:OnMouseUp()
	-- Override in your mixin, called when the mouse is released
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnMouseUp", "LeftButton")
    if(not IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseUp("LeftButton")
    end
end

function BlobMapPin:OnMouseEnterPolygon()
    -- Override in your mixin, called when the mouse enters this pin
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnMouseEnterPolygon")
    if(self.overrideFunctions and self.overrideFunctions.OnMouseEnterPolygon) then
        self.overrideFunctions:OnMouseEnterPolygon(self)
    end
end

function BlobMapPin:OnMouseLeavePolygon()
    -- Override in your mixin, called when the mouse enters this pin
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnMouseLeavePolygon")
    if(self.overrideFunctions and self.overrideFunctions.OnMouseLeavePolygon) then
        self.overrideFunctions:OnMouseLeavePolygon(self)
    end
end

function BlobMapPin:OnClick(button)
	-- Override in your mixin, called when this pin is clicked
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnClick: ", button)

    --Make the polygon click-through
    if self and self.UiMapID and WorldMapFrame and WorldMapFrame:IsShown() then
        if button == "RightButton" then
            local currentMapParent = WorldMapFrame:GetMapID()
            if currentMapParent then
                local mapInfo = C_Map.GetMapInfo(currentMapParent)
                currentMapParent = mapInfo.parentMapID

                if currentMapParent and currentMapParent > 0 then
                    WorldMapFrame:SetMapID(currentMapParent)
                end
            end
        else
            if self.UiMapID ~= WorldMapFrame:GetMapID() then
                WorldMapFrame:SetMapID(self.UiMapID);
            end
        end
    end
end

--- END OVERIDABLE FUNCTIONS ---

--  map pin base API
--On new pins
function BlobMapPin:OnLoad()
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnLoad")
    --self:SetScalingLimits(1, 1.0, 1.2)
end

function BlobMapPin:OnAcquired(frameLevel)
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnAcquired")
    Questie:Debug(DEBUG_DEVELOP, "BlobFrame", self)
    --self:SetFrameLevel(frameLevel)
    self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_BLOB")
    self:ApplyFrameLevel()

    self:Show()
end

function BlobMapPin:OnReleased()
    print("BlobMapPin:OnReleased")
    --Blob.FramePool:Release(self)
end

local function _checkMouse(selfPin)
    if(selfPin.insideFrame == true) then
        local lastValue = selfPin.insidePolygon;
        selfPin.insidePolygon = Blob.util.insidePolygonMouse(selfPin, selfPin.drawData.points);
        if(not lastValue and selfPin.insidePolygon and selfPin.OnMouseEnterPolygon and type(selfPin.OnMouseEnterPolygon) == "function") then
            selfPin:OnMouseEnterPolygon();
        elseif(lastValue and not selfPin.insidePolygon and selfPin.OnMouseLeavePolygon and type(selfPin.OnMouseLeavePolygon) == "function") then
            selfPin:OnMouseLeavePolygon();
        end
    end
end

function BlobMapPin:OnMouseEnter()
    -- Override in your mixin, called when the mouse enters this pin
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnMouseEnter")
    self.insideFrame = true;
    --Starting a timer is kind of an expensive function, but its only on mouse so it should be fiiiine
    if(not self.insideTimer or self.insideTimer:IsCancelled()) then
        self.insideTimer = C_Timer.NewTicker(0.08, function()
            --for pin, _ in WorldMapFrame:EnumeratePinsByTemplate(Blob.worldPinTemplate) do
            _checkMouse(self);
            --end
        end);
    end

end

function BlobMapPin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
    Questie:Debug(DEBUG_DEVELOP, "BlobMapPin:OnMouseLeave")
    self.insideFrame = nil;
    --We left the polygon
    if(self.insidePolygon and self.OnMouseLeavePolygon and type(self.OnMouseLeavePolygon) == "function") then
        self:OnMouseLeavePolygon();
    end
    self.insidePolygon = nil;
    if(self.insideTimer) then
        self.insideTimer:Cancel();
        self.insideTimer = nil;
    end
end

WorldMapFrame:AddDataProvider(BlobMapProvider)