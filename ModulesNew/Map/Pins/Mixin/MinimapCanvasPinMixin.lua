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

function MinimapCanvasPinMixin:GetMap()
	return self.owningMinimap;
end

function MinimapCanvasPinMixin:SetPosition(normalizedX, normalizedY, insetIndex)
	self.normalizedX = normalizedX;
	self.normalizedY = normalizedY;
	self.insetIndex = insetIndex;
	self:GetMap():SetPinPosition(self, normalizedX, normalizedY, insetIndex);
end

-- Returns the global position if not part of an inset, otherwise returns local coordinates of that inset
function MinimapCanvasPinMixin:GetPosition()
	return self.normalizedX, self.normalizedY, self.insetIndex;
end

function MinimapCanvasPinMixin:OnCanvasScaleChanged()
	-- self:ApplyCurrentScale();
	self:ApplyCurrentAlpha();
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
-- 	self:GetMap():ApplyPinPosition(self, self.normalizedX, self.normalizedY, self.insetIndex);
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
