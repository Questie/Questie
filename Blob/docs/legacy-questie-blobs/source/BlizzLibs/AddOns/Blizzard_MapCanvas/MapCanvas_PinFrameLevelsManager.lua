---@class MapCanvasPinFrameLevelsManagerMixin
MapCanvasPinFrameLevelsManagerMixin = {};

local MAP_CANVAS_PIN_FRAME_LEVEL_DEFAULT = 2000;
local MAX_FRAME_LEVEL = 9000;
local MIN_FRAME_LEVEL = 0;

function MapCanvasPinFrameLevelsManagerMixin:Initialize()
	if not self.definitions then
		self.definitions = { ["PIN_FRAME_LEVEL_DEFAULT"] = { startLevel = MAP_CANVAS_PIN_FRAME_LEVEL_DEFAULT, range = 1 } };
		self.topMostDefinition = self.definitions["PIN_FRAME_LEVEL_DEFAULT"];
		self.minLevel = MAP_CANVAS_PIN_FRAME_LEVEL_DEFAULT;
		self.maxLevel = MAP_CANVAS_PIN_FRAME_LEVEL_DEFAULT;
	end
end

function MapCanvasPinFrameLevelsManagerMixin:ValidateContiguous()
	local start = self.minLevel;
	while start < self.maxLevel do
		local found = false;
		for frameLevelType, definition in pairs(self.definitions) do
			if definition.startLevel == start then
				found = true;
				start = definition.startLevel + definition.range;
				break;
			end
		end
		if not found then
			return false;
		end
	end
	return true;
end

function MapCanvasPinFrameLevelsManagerMixin:AddDefinition(frameLevelType, range, targetLevel, comparisonMod)
	if targetLevel > self:GetFrameLevelStart("PIN_FRAME_LEVEL_DEFAULT") then
		if self.maxLevel + range > MAX_FRAME_LEVEL then
			return false;
		end

		for frameLevelType, definition in pairs(self.definitions) do
			if definition.startLevel > targetLevel + comparisonMod then
				definition.startLevel = definition.startLevel + range;
			end
		end
		self.maxLevel = self.maxLevel + range;
	else
		if self.minLevel - range < MIN_FRAME_LEVEL then
			return false;
		end

		for frameLevelType, definition in pairs(self.definitions) do
			if definition.startLevel < targetLevel + comparisonMod then
				definition.startLevel = definition.startLevel - range;
			end
		end
		self.minLevel = self.minLevel - range;
	end
	self.definitions[frameLevelType] = { startLevel = targetLevel, range = range };
	if self.topMostDefinition.startLevel < targetLevel then
		self.topMostDefinition = self.definitions[frameLevelType];
	end
	return true;
end

function MapCanvasPinFrameLevelsManagerMixin:AddFrameLevel(frameLevelType, optionalRange)
	if self.definitions[frameLevelType] or frameLevelType == "PIN_FRAME_LEVEL_TOPMOST" then
		return false;
	end

	local range = optionalRange or 1;
	local targetLevel = self.maxLevel + 1;
	local comparisonMod = 0;
	return self:AddDefinition(frameLevelType, range, targetLevel, comparisonMod);
end

function MapCanvasPinFrameLevelsManagerMixin:InsertFrameLevelAbove(frameLevelType, relativeFrameLevelType, optionalRange)
	local relativeDefinition = self.definitions[relativeFrameLevelType];
	if not relativeDefinition or self.definitions[frameLevelType] or frameLevelType == "PIN_FRAME_LEVEL_TOPMOST" then
		return false;
	end

	local range = optionalRange or 1;
	local targetLevel, comparisonMod;
	if relativeDefinition.startLevel < self:GetFrameLevelStart("PIN_FRAME_LEVEL_DEFAULT") then
		targetLevel = relativeDefinition.startLevel + relativeDefinition.range - range;
		comparisonMod = range - relativeDefinition.range + 1;
	else
		targetLevel = relativeDefinition.startLevel + relativeDefinition.range;
		comparisonMod = -1;
	end
	return self:AddDefinition(frameLevelType, range, targetLevel, comparisonMod);
end

function MapCanvasPinFrameLevelsManagerMixin:InsertFrameLevelBelow(frameLevelType, relativeFrameLevelType, optionalRange)
	local relativeDefinition = self.definitions[relativeFrameLevelType];
	if not relativeDefinition or self.definitions[frameLevelType] or frameLevelType == "PIN_FRAME_LEVEL_TOPMOST" then
		return false;
	end

	local range = optionalRange or 1;
	local targetLevel, comparisonMod;
	if relativeDefinition.startLevel <= self:GetFrameLevelStart("PIN_FRAME_LEVEL_DEFAULT") then
		targetLevel = relativeDefinition.startLevel - range;
		comparisonMod = range;
	else
		targetLevel = relativeDefinition.startLevel;
		comparisonMod = -1;
	end
	return self:AddDefinition(frameLevelType, range, targetLevel, comparisonMod);
end

function MapCanvasPinFrameLevelsManagerMixin:SetOverride(frameLevelType, overrideFrameLevelType)
	local definition = self.definitions[frameLevelType];
	if not definition or not self.definitions[overrideFrameLevelType] or definition.overrideType == overrideFrameLevelType then
		return false;
	end
	definition.overrideType = overrideFrameLevelType;
	return true;
end

function MapCanvasPinFrameLevelsManagerMixin:ClearOverride(frameLevelType)
	local definition = self.definitions[frameLevelType];
	if not definition or not definition.overrideType then
		return false;
	end
	definition.overrideType = nil;
	return true;
end

function MapCanvasPinFrameLevelsManagerMixin:GetFrameLevelStart(frameLevelType)
	local definition = self.definitions[frameLevelType] or self.definitions["PIN_FRAME_LEVEL_DEFAULT"];
	if definition.overrideType then
		definition = self.definitions[definition.overrideType];
	end
	return definition.startLevel;
end

function MapCanvasPinFrameLevelsManagerMixin:GetValidFrameLevel(frameLevelType, optionalIndex)
	local definition;
	if frameLevelType == "PIN_FRAME_LEVEL_TOPMOST" then
		definition = self.topMostDefinition;
	else
		definition = self.definitions[frameLevelType] or self.definitions["PIN_FRAME_LEVEL_DEFAULT"];
		if definition.overrideType then
			definition = self.definitions[definition.overrideType];
		end
	end
	local offset = Clamp(optionalIndex or 1, 1, definition.range) - 1;
	return definition.startLevel + offset;
end