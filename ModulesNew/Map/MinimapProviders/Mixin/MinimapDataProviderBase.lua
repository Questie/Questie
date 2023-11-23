---@class MinimapDataProviderMixin
local MinimapDataProviderMixin = QuestieLoader:CreateModule("MinimapDataProviderMixin")

function MinimapDataProviderMixin:OnAdded(owningMinimap)
	-- Optionally override in your mixin, called when this provider is added to a map canvas
	self.owningMinimap = owningMinimap;
end

function MinimapDataProviderMixin:OnRemoved(owningMinimap)
	-- Optionally override in your mixin, called when this provider is removed from a map canvas
	assert(owningMinimap == self.owningMinimap);
	self.owningMinimap = nil;

	if self.registeredEvents then
		for event in pairs(self.registeredEvents) do
			owningMinimap:UnregisterEvent(event);
		end
		self.registeredEvents = nil;
	end
end

function MinimapDataProviderMixin:RemoveAllData()
    -- Override in your mixin, this method should remove everything that has been added to the map
    print("MinimapProvider RemoveAllData")
end

function MinimapDataProviderMixin:RefreshAllData(fromOnShow)
    print("RefreshAllData", fromOnShow)
end

-- Are these useful?
-- function MinimapProvider:OnShow()
-- 	-- Override in your mixin, called when the map canvas is shown
-- end

-- function MinimapProvider:OnHide()
-- 	-- Override in your mixin, called when the map canvas is closed
-- end

function MinimapDataProviderMixin:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

-- TODO: NYI
function MinimapDataProviderMixin:OnZoomChanged()
    -- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function MinimapDataProviderMixin:OnMapChanged(lastUiMapId, newUiMapId)
    print("OnMapChanged")
    --  Optionally override in your mixin, called when map ID changes
end

function MinimapDataProviderMixin:RegisterEvent(event)
	-- Since data providers aren't frames this provides a similar method of event registration, but always calls self:OnEvent(event, ...)
	if not self.registeredEvents then
		self.registeredEvents = {}
	end
	if not self.registeredEvents[event] then
		self.registeredEvents[event] = true;
		self.owningMinimap:AddDataProviderEvent(event);
	end
end

function MinimapDataProviderMixin:UnregisterEvent(event)
	if self.registeredEvents and self.registeredEvents[event] then
		self.registeredEvents[event] = nil;
		self.owningMinimap:RemoveDataProviderEvent(event);
	end
end

function MinimapDataProviderMixin:SignalEvent(event, ...)
	if self.registeredEvents and self.registeredEvents[event] then
		self:OnEvent(event, ...);
	end
end
