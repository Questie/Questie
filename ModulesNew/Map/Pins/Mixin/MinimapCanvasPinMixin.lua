-- Provides a basic interface for something that is visible on the map canvas, like icons, blobs or text
---@class MinimapCanvasPinMixin : Button
---@field owningMinimap MinimapCanvas
---@field pinTemplate string
local MinimapCanvasPinMixin = QuestieLoader:CreateModule("MinimapCanvasPinMixin")

function MinimapCanvasPinMixin:OnLoad()
	-- Override in your mixin, called when this pin is created
end

function MinimapCanvasPinMixin:OnAcquired(...) -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
	-- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
end

function MinimapCanvasPinMixin:OnReleased()
	-- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
end

function MinimapCanvasPinMixin:OnClick(button)
	-- Override in your mixin, called when this pin is clicked
end

function MinimapCanvasPinMixin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
end

function MinimapCanvasPinMixin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
end

function MinimapCanvasPinMixin:OnMouseDown()
	-- Override in your mixin, called when the mouse is pressed on this pin
end

function MinimapCanvasPinMixin:OnMouseUp()
	-- Override in your mixin, called when the mouse is released
end

function MinimapCanvasPinMixin:GetMinimap()
	return self.owningMinimap;
end

-- This distance is number of "minimaps" 1 = the edge of the minimap, 2 = double the edge and so on
-- If the alpha ever becomes 0 the pin is hidden automatically
---@param minAlphaDistance number
---@param maxAlphaDistance number
function MinimapCanvasPinMixin:SetAlphaDistance(minAlphaDistance, maxAlphaDistance)
    if not minAlphaDistance or type(minAlphaDistance) ~= "number" then
        error("MinAlphaDistance must be a number", 2)
    end
    if not maxAlphaDistance or type(maxAlphaDistance) ~= "number" then
        error("MaxAlphaDistance must be a number", 2)
    end
    self.minAlphaDistance = minAlphaDistance;
    self.maxAlphaDistance = maxAlphaDistance;
end

-- This distance is number of "minimaps" 1 = the edge of the minimap, 2 = double the edge and so on
-- If the scale ever becomes 0 the pin is hidden automatically
---@param minScaleDistance number
---@param maxScaleDistance number
function MinimapCanvasPinMixin:SetScaleDistance(minScaleDistance, maxScaleDistance)
    if not minScaleDistance or type(minScaleDistance) ~= "number" then
        error("MinScaleDistance must be a number", 2)
    end
    if not maxScaleDistance or type(maxScaleDistance) ~= "number" then
        error("MaxScaleDistance must be a number", 2)
    end
    self.minScaleDistance = minScaleDistance;
    self.maxScaleDistance = maxScaleDistance;
end

--- Sets the max distance in world coordinates that this pin will be evaluated
--- Note that this distance and SetAlphaDistance are not related or the same
---@param maxDistance number
function MinimapCanvasPinMixin:SetMaxCalulationDistance(maxDistance)
    if not maxDistance or type(maxDistance) ~= "number" then
        error("MaxDistance must be a number", 2)
    end
    self.maxDistance = maxDistance
end

---comment
---@param x any
---@param y any
function MinimapCanvasPinMixin:SetPosition(x, y)
	self.x = x;
	self.y = y;
	-- self:GetMap():SetPinPosition(self, x, y, insetIndex);
end

-- Returns the global position if not part of an inset, otherwise returns local coordinates of that inset
function MinimapCanvasPinMixin:GetPosition()
	return self.x, self.y;
end

function MinimapCanvasPinMixin:SetScalingLimits(scaleFactor, startScale, endScale)
	self.scaleFactor = scaleFactor;
	self.startScale = startScale and math.max(startScale, .01) or nil;
	self.endScale = endScale and math.max(endScale, .01) or nil;
end

function MinimapCanvasPinMixin:SetAlphaLimits(alphaFactor, startAlpha, endAlpha)
	self.alphaFactor = alphaFactor;
	self.startAlpha = startAlpha;
	self.endAlpha = endAlpha;
end

-- function MinimapCanvasPinMixin:ApplyCurrentPosition()
-- 	self:GetMap():ApplyPinPosition(self, self.x, self.y, self.insetIndex);
-- end

-- function MinimapCanvasPinMixin:ApplyCurrentScale()
-- 	local scale;
-- 	if self.startScale and self.startScale and self.endScale then
-- 		local parentScaleFactor = 1.0 / self:GetMap():GetCanvasScale();
-- 		scale = parentScaleFactor * Lerp(self.startScale, self.endScale, Saturate(self.scaleFactor * self:GetMap():GetCanvasZoomPercent()));
-- 	elseif not self:IsIgnoringGlobalPinScale() then
-- 		scale = 1;
-- 	end
-- 	if scale then
-- 		if not self:IsIgnoringGlobalPinScale() then
-- 			scale = scale * self:GetMap():GetGlobalPinScale();
-- 		end
-- 		self:SetScale(scale);
-- 		self:ApplyCurrentPosition();
-- 	end
-- end

function MinimapCanvasPinMixin:ApplyCurrentAlpha()
	-- if self.alphaFactor and self.startAlpha and self.endAlpha then
	-- 	local alpha = Lerp(self.startAlpha, self.endAlpha, Saturate(self.alphaFactor * self:GetMap():GetCanvasZoomPercent()));
	-- 	self:SetAlpha(alpha);
	-- 	self:SetShown(alpha > 0.05);
	-- end
end

function MinimapCanvasPinMixin:UseFrameLevelType(pinFrameLevelType, index)
	self.pinFrameLevelType = pinFrameLevelType;
	self.pinFrameLevelIndex = index;
end

function MinimapCanvasPinMixin:GetFrameLevelType(pinFrameLevelType)
	return self.pinFrameLevelType or "PIN_FRAME_LEVEL_DEFAULT";
end

function MinimapCanvasPinMixin:ApplyFrameLevel()
	local frameLevel = self.owningMinimap:GetPinFrameLevelsManager():GetValidFrameLevel(self.pinFrameLevelType, self.pinFrameLevelIndex);
	self:SetFrameLevel(frameLevel);
end
