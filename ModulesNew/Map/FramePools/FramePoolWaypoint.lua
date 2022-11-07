---@type QuestieNS
local Questie = select(2, ...)

-- Contains library functions that do not have a logical place.
---@class FramePoolWaypoint
local FramePoolWaypoint = QuestieLoader:CreateModule("FramePoolWaypoint")

---@type WaypointPinMixin
local WaypointPinMixin = QuestieLoader:ImportModule("WaypointPinMixin")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

FramePoolWaypoint.waypointPinTemplate = "WaypointMapWorldmapTemplate"

---@class WaypointMapFramePool
local FramePool = CreateFramePool("BUTTON")

FramePoolWaypoint.FramePool = FramePool

local WaypointTexture = QuestieLib.AddonPath .. "Icons\\WHITE32X32BLACKLINES"

-- register pin pool with the world map
WorldMapFrame.pinPools[FramePoolWaypoint.waypointPinTemplate] = FramePool


local count = 0
local name = "QuestieWaypointMapFrame"


-- local frame = CreateFrame("Frame", "ShitHideMeFrame", UIParent)
-- frame:ClearAllPoints()
-- -- frame:SetParent(FramePool.parent)
-- frame:SetPoint("CENTER")
-- frame:SetSize(50,50)
-- frame:SetFrameStrata("TOOLTIP")
-- frame:SetFrameLevel(10000)

--- WORLD MAP
-- setup pin pool
FramePool.parent = WorldMapFrame:GetCanvas()
FramePool.creationFunc = function(framePool)
    --Questie:Debug(DEBUG_DEVELOP, "FramePool.creationFunc")
    -- print("FramePool.creationFunc", name .. count)
    ---@class WaypointMapIconFrame
    local frame = CreateFrame(framePool.frameType, name .. count, framePool.parent)

    frame:SetParent(framePool.parent)
    frame.parent = framePool.parent;
    count = count + 1;
    frame = Mixin(frame, Questie.BasePinMixin)
    frame = MixinPin(frame, WaypointPinMixin)
    frame.lineTextures = {}
    frame:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS")
    --frame:SetIgnoreGlobalPinScale(true)
    return frame
end
FramePool.resetterFunc = function(pinPool, pin)
    -- if(pin.lineTexture) then
    --     print("Releasing lineTexture", pin.lineTexture:GetName())
    --     local released = FramePoolWaypoint.LinePool:Release(pin.lineTexture);
    --     -- print("Released? : ", released)
    --     FramePoolWaypoint.LinePool:resetterFunc(pin.lineTexture);
    --     pin.lineTexture = nil
    -- end

    -- for i, lineTexture in pairs(pin.lineTextures) do
    --     print("Releasing lineTexture", lineTexture:GetName())
    --     local released = FramePoolWaypoint.LinePool:Release(lineTexture);
    --     FramePoolWaypoint.LinePool:resetterFunc(lineTexture);
    -- end
    -- wipe(pin.lineTextures)

    -- if (pin.lineTexture) then
    --     -- print("Hiding lineTexture", pin.lineTexture:GetName())
    --     local released = FramePoolWaypoint.LinePool:Release(pin.lineTexture);
    --     pin.lineTexture = nil
    -- end

    -- FramePool_HideAndClearAnchors(pinPool, pin)
    -- -- pin:OnReleased()

    -- -- --Frame setup
    -- pin:ClearAllPoints()
    -- pin:SetParent(FramePool.parent)
    -- pin:SetPoint("CENTER")
    -- pin:Hide();

    -- FramePool_HideAndClearAnchors(pinPool, pin)
    -- pin:OnReleased()

    if(pin.lineTexture) then
        -- pin.lineTexture:SetParent(frame)
        -- pin.lineTexture:Hide()
        FramePoolWaypoint.LinePool:Release(pin.lineTexture);
    end
    pin.lineTexture = nil

    --Frame setup
    -- pin:ClearAllPoints()
    -- pin:SetParent(UIParent)
    -- pin:SetPoint("TOPLEFT")
    -- pin:Hide();
    FramePool_HideAndClearAnchors(pinPool, pin)
    -- pin:Hide();

    -- pin:ClearAllPoints()
    -- pin:SetParent(FramePool.parent)
    -- pin:SetParent(UIParent)
    -- pin:SetPoint("TOPLEFT")
    -- pin:Hide();
end
-- MINIMAP

-- local function updateMaskTexture()
--     print("updateMaskTexture ran")
--     WaypointMap.minimapMask:ClearAllPoints();
--     WaypointMap.minimapMask:SetAllPoints(Minimap)
--     WaypointMap.minimapMask:SetTexture(MinimapMaskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
-- end

-- WaypointMap.minimapMask = Minimap:CreateMaskTexture()
-- WaypointMap.playerMask = Minimap:CreateMaskTexture()
-- local timer;
-- local count = 0;
-- timer = C_Timer.NewTicker(0.5, function()
--     if(count > 10) then --60 seconds
--         MinimapMaskTexture = QuestieLib.AddonPath.."Icons\\circlemask";
--     end
--     if(MinimapMaskTexture) then
--         updateMaskTexture()
--         WaypointMap.playerMask:SetTexture(QuestieLib.AddonPath.."Icons\\playermask", "CLAMP", "CLAMP", "NEAREST")
--         WaypointMap.playerMask:SetParent(Minimap)
--         WaypointMap.playerMask:SetPoint("CENTER", 0, 0)
--         WaypointMap.playerMask:SetSize(38,38)
--         timer:Cancel();
--         timer = nil
--     end
--     count = count + 1
-- end)

-- WaypointMap.MinimapFramePool = CreateFramePool("BUTTON")
-- WaypointMap.minimapPinTemplate = "QuestieMinimapWaypointMapFrame"

-- --for i = 1, 835 do _G["QuestieMinimapWaypointMapFrame"..i]:Show() end
-- --for i = 1, 835 do _G["QuestieMinimapWaypointMapFrame"..i].lineTexture:Show() end

-- local minimapCount = 0
-- local minimapName = "QuestieMinimapWaypointMapFrame"
-- -- setup pin pool
-- WaypointMap.MinimapFramePool.parent = Minimap
-- WaypointMap.MinimapFramePool.creationFunc = function(framePool)
--     --Questie:Debug(DEBUG_DEVELOP, "WaypointMap.MinimapFramePool.creationFunc")
--     local frame = CreateFrame(framePool.frameType, minimapName..minimapCount, framePool.parent)
--     --print("FrameC:", minimapCount)
--     frame:SetParent(framePool.parent)
--     frame.parent = framePool.parent;
--     minimapCount = minimapCount + 1;
--     frame = Mixin(frame, WaypointMap.PinMixin)
--     frame.minimapPin = true
--     --frame:SetIgnoreGlobalPinScale(true)
--     return frame
-- end
-- WaypointMap.MinimapFramePool.resetterFunc = function(pinPool, pin)
--     --Questie:Debug(DEBUG_DEVELOP, "WaypointMap.MinimapFramePool.resetterFunc")
--     FramePool_HideAndClearAnchors(pinPool, pin)
--     --pin:OnReleased()

--     if(pin.lineTexture) then
--         FramePoolWaypoint.LinePool:Release(pin.lineTexture);
--     end
--     pin.lineTexture = nil

--     pin.minimapPin = true

--     --Frame setup
--     --pin:ClearAllPoints()
--     --pin:SetParent(WaypointMap.MinimapFramePool.parent)
--     --pin:SetPoint("CENTER")
--     --pin:Hide();
-- end

-- Regular lines

local lineCount = 0;
---comment
---@param self any
---@param line Texture
local function lineReset(self, line)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.linePool.resetterFunc")
    -- print("Reset line ", line:GetName())

    -- line.color = nil
    -- line.startX = nil
    -- line.startY = nil
    -- line.endX = nil
    -- line.endY = nil
    -- line.thickness = nil

    --Remove all mask textures
    for _, maskTexture in pairs(line.maskTextures or {}) do
        line:RemoveMaskTexture(maskTexture);
    end
    line.maskTextures = {}

    -- line:ClearAllPoints()
    -- line:SetParent(Minimap)
    -- line:SetPoint("CENTER")
    -- line:ClearAllPoints()
    -- line:SetSize(100,100)
    -- line:SetTexCoord(0,1,0,1)
    -- line:SetParent(WorldMapFrame:GetCanvas())
    -- line:SetParent(FramePool.parent)
    -- line:ClearAllPoints()
    -- line:SetParent(WorldMapFrame:GetCanvas())
    -- line:SetParent(UIParent)
    -- TexturePool_HideAndClearAnchors(self, line)
    -- line:SetParent(frame)

    TexturePool_HideAndClearAnchors(self, line)
    -- line:SetTexture(nil)

    -- line:SetPoint("CENTER")
end

-- The following function is used with permission from Daniel Stephens
-- texture			- Texture
-- canvasFrame      - Canvas Frame (for anchoring)
-- startX,startY    - Coordinate of start of line
-- endX,endY		- Coordinate of end of line
-- lineWidth        - Width of line
-- relPoint			- Relative point on canvas to interpret coords (Default BOTTOMLEFT)
local function drawLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, lineFactor, relPoint)
	if (not relPoint) then relPoint = "BOTTOMLEFT"; end
	lineFactor = lineFactor * .5;

	-- Determine dimensions and center point of line
	local dx,dy = endX - startX, endY - startY;
	local cx,cy = (startX + endX) / 2, (startY + endY) / 2;

	-- Normalize direction if necessary
	if (dx < 0) then
		dx,dy = -dx,-dy;
	end

	-- Calculate actual length of line
	local lineLength = sqrt((dx * dx) + (dy * dy));

	-- Quick escape if it'sin zero length
	if (lineLength == 0) then
		texture:SetTexCoord(0,0,0,0,0,0,0,0);
		texture:SetPoint("BOTTOMLEFT", canvasFrame, relPoint, cx,cy);
		texture:SetPoint("TOPRIGHT",   canvasFrame, relPoint, cx,cy);
		return;
	end

	-- Sin and Cosine of rotation, and combination (for later)
	local sin, cos = -dy / lineLength, dx / lineLength;
	local sinCos = sin * cos;

	-- Calculate bounding box size and texture coordinates
	local boundingWidth, boundingHeight, bottomLeftX, bottomLeftY, topLeftX, topLeftY, topRightX, topRightY, bottomRightX, bottomRightY;
	if (dy >= 0) then
		boundingWidth = ((lineLength * cos) - (lineWidth * sin)) * lineFactor;
		boundingHeight = ((lineWidth * cos) - (lineLength * sin)) * lineFactor;

		bottomLeftX = (lineWidth / lineLength) * sinCos;
		bottomLeftY = sin * sin;
		bottomRightY = (lineLength / lineWidth) * sinCos;
		bottomRightX = 1 - bottomLeftY;

		topLeftX = bottomLeftY;
		topLeftY = 1 - bottomRightY;
		topRightX = 1 - bottomLeftX;
		topRightY = bottomRightX;
	else
		boundingWidth = ((lineLength * cos) + (lineWidth * sin)) * lineFactor;
		boundingHeight = ((lineWidth * cos) + (lineLength * sin)) * lineFactor;

		bottomLeftX = sin * sin;
		bottomLeftY = -(lineLength / lineWidth) * sinCos;
		bottomRightX = 1 + (lineWidth / lineLength) * sinCos;
		bottomRightY = bottomLeftX;

		topLeftX = 1 - bottomRightX;
		topLeftY = 1 - bottomLeftX;
		topRightY = 1 - bottomLeftY;
		topRightX = topLeftY;
	end

	-- Set texture coordinates and anchors
	texture:ClearAllPoints();
	texture:SetTexCoord(topLeftX, topLeftY, bottomLeftX, bottomLeftY, topRightX, topRightY, bottomRightX, bottomRightY);
    -- These two values below are the bounding box for the line, use for mouseover in the future.
	texture:SetPoint("BOTTOMLEFT", canvasFrame, relPoint, cx - boundingWidth, cy - boundingHeight);
	texture:SetPoint("TOPRIGHT",   canvasFrame, relPoint, cx + boundingWidth, cy + boundingHeight);
end

local function redraw(self, zoomScale)
    self:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
    self.drawlinefunction(self, self:GetParent(), self.startX, self.startY, self.endX, self.endY, self.thickness / (zoomScale or 1), 1, "TOPLEFT");
end

local function lineCreate(linePool)
    -- print("Line:", lineCount)
    lineCount = lineCount + 1;
    ---@type Texture
    local line = linePool.parent:CreateTexture("LineTexture" .. lineCount, linePool.layer, nil, linePool.subLayer);
    line = Mixin(line, LineMixin)
    line.drawlinefunction = drawLine
    line.redraw = redraw
    --line:SetSnapToPixelGrid(false)
    --line:SetTexelSnappingBias(0)
    line:SetTexture(WaypointTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    line:SetSnapToPixelGrid(false)
    line:SetTexelSnappingBias(0)
    line.maskTextures = {}
    return line
end

--for i = 1, 835 do _G["LineTexture"..i]:SetParent(UIParent) en
--Ifor i = 1, 835 do _G["LineTexture"..i]:SetParent(_G["ShitHideMeFrame"]) end
--for i = 1, 835 do _G["LineTexture"..i]:Hide() end
--for i = 1, 835 do FramePoolWaypoint.LinePool:Release(_G["LineTexture"..i]) end
--for i = 1, 835 do _G["LineTexture"..i]:Show() end
--for i = 1, 835 do _G["QuestieWaypointMapFrame"..i]:Show() end
FramePoolWaypoint.LinePool = CreateTexturePool(Minimap, "ARTWORK", 0, nil, lineReset)
FramePoolWaypoint.LinePool.parent = Minimap
FramePoolWaypoint.LinePool.creationFunc = lineCreate;

FramePoolWaypoint.LinePool.Acquire = function(self)
    -- print("Getting")
	local numInactiveObjects = #self.inactiveObjects;
	if numInactiveObjects > 0 then
		local obj = self.inactiveObjects[numInactiveObjects];
		self.activeObjects[obj] = true;
		self.numActiveObjects = self.numActiveObjects + 1;
		self.inactiveObjects[numInactiveObjects] = nil;
		return obj, false;
	end

	local newObj = self.creationFunc(self);
	if self.resetterFunc and not self.disallowResetIfNew then
		self.resetterFunc(self, newObj);
	end
	self.activeObjects[newObj] = true;
	self.numActiveObjects = self.numActiveObjects + 1;
	return newObj, true;
end
