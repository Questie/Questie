---@class WaypointPinMixin : BasePinMixin
local WaypointPinMixin = QuestieLoader:CreateModule("WaypointPinMixin")

----- System Imports -----
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")
---@type MapCoordinates
local MapCoordinates = QuestieLoader:ImportModule("MapCoordinates")

---@type FramePoolWaypoint
local FramePoolWaypoint = QuestieLoader:ImportModule("FramePoolWaypoint")

----- Imports -----
local QuestieQuest = QuestieLoader:ImportModule("QQuest")
local MapTooltip = QuestieLoader:ImportModule("MapTooltip")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local l10n = QuestieLoader:ImportModule("l10n")
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
local QuestieEVent = QuestieLoader:ImportModule("QuestieEvent")


--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip

function WaypointPinMixin:GetType()
    return "WaypointPin"
end

function WaypointPinMixin:OnAcquired() -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
    -- local uiMapId = self.data and self.data.uiMapId and self.data.uiMapId or nil
    -- local normalScale = (self:GetIconScale(uiMapId) or 1)
    -- local zoomedScale = (normalScale * 1.2)

    -- self:SetScalingLimits(1, normalScale, zoomedScale)
end

---Get the IconScale for the pin, use UiMapId to get the scale for a specific map
---@param uiMapId UiMapId?
---@return number
function WaypointPinMixin:GetIconScale(uiMapId)
    -- It should always be 1
    return 1
end

function WaypointPinMixin:DrawLine(UiMapID, sX, sY, eX, eY, Linedata, maskTextures)
    -- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
    local lineData = Linedata or {}
    local dx,dy = eX - sX, eY - sY;
    -- Normalize direction if necessary
    if (dx < 0) then
        dx,dy = -dx,-dy;
    end
    local cx,cy = (sX + eX) / 2, (sY + eY) / 2;
    local width, height = WorldMapFrame:GetCanvas():GetSize();
    width = width
    height = height
    local minX = math.min(sX, eX);
    local minY = math.min(sY, eY);
    local framePosX, framePosY = minX*width, minY*height
    self:ClearAllPoints()
    --self:SetParent(WorldMapFrame:GetCanvas())
    --self:SetPosition(minX+(windowX/2), minY+(windowY/2))
    --self:SetPosition(cx, cy)
    if(not self.minimapPin) then
        --pcall(self.SetPosition, self, cx, cy);
        self:SetPosition(cx, cy)
    end

    self:SetSize(dx*width, dy*height)

    self.lineTexture = self.lineTexture or FramePoolWaypoint.LinePool:Acquire();
    self.lineTexture:ClearAllPoints()
    self.lineTexture:SetParent(self)
    local startX = sX * width
    local startY = sY * height -- We do by / -100 due to using the top left point
    local endX = eX * width
    local endY = eY * height

    --Due to thickness being used in linemixin we instead just use defaultThickness
    self.lineTexture.defaultThickness = lineData.thickness or 5;
    self.lineTexture.color = {r=lineData.r or 1, g=lineData.g or 1, b=lineData.b or 1, a=lineData.a or 0.6}
    if(maskTextures) then
        for _, maskTexture in pairs(maskTextures) do
            self.lineTexture:AddMaskTexture(maskTexture)
        end
        self.lineTexture.maskTextures = maskTextures
    end
    self.lineTexture:SetVertexColor(self.lineTexture.color.r, self.lineTexture.color.g, self.lineTexture.color.b, self.lineTexture.color.a)
    self.lineTexture:SetStartPoint(startX-framePosX, -(startY-framePosY))
    self.lineTexture:SetEndPoint(endX-framePosX, -(endY-framePosY))
    self.lineTexture:SetThickness(self.lineTexture.defaultThickness);
    self.lineTexture:SetPoint("CENTER", endX-framePosX, -(endY-framePosY))

    --? Minimap Stuff
    -- local fWidth, fHeight = self:GetSize();

    -- local x1, y1= HBD:GetWorldCoordinatesFromZone(0, 0, UiMapID)
    -- local x2, y2 = HBD:GetWorldCoordinatesFromZone(1, 1, UiMapID)
    -- local mapWidth = x1 - x2;


    -- local mSizeX, mSizeY = Minimap:GetSize()
    -- self.minimapScale = {}

    -- local worldWidth = dx * mapWidth
    -- local numberOfMinimaps = worldWidth/(466 + 2/3)
    -- local frameWidth = numberOfMinimaps*mSizeX
    -- self.minimapScale["outdoor"] =  frameWidth/fWidth

    -- numberOfMinimaps = worldWidth/300
    -- frameWidth = numberOfMinimaps*mSizeX
    -- self.minimapScale["indoor"] =  frameWidth/fWidth
    --? end Minimap stuff

    --self.self.lineTexture = self.lineTexture

    self.lineTexture:redraw()
    self.lineTexture:Show();
end

--! There are some fucky wucky going on with the Mouse clicking if zoomed out, but fixing when required
function WaypointPinMixin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
end

function WaypointPinMixin:OnMouseUp()
end

--! End fucky wucky, read above

function WaypointPinMixin:OnTooltip()
end


function WaypointPinMixin:OnMouseEnter()
end

function WaypointPinMixin:OnMouseLeave()
    -- Override in your mixin, called when the mouse leaves this pin
end
