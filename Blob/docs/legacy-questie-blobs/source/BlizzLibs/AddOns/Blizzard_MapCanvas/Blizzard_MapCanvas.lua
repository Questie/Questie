---@class MapCanvasMixin : CallbackRegistryBaseMixin
MapCanvasMixin = CallbackRegistryBaseMixin; -- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...

function MapCanvasMixin:OnLoad()
	CallbackRegistryBaseMixin.OnLoad(self);
	self.detailLayerPool = CreateFramePool("FRAME", self:GetCanvas(), "MapCanvasDetailLayerTemplate");
	self.dataProviders = {};
	self.dataProviderEventsCount = {};
	self.pinPools = {};
	self.pinTemplateTypes = {};
	self.activeAreaTriggers = {};
	self.lockReasons = {};
	self.pinsToNudge = {};
	self.pinFrameLevelsManager = MapCanvasPinFrameLevelsManagerMixin;-- removed CreateFromMixin(VAR), We do this for the type because mixin is strange...
	self.pinFrameLevelsManager:Initialize();
	self.mouseClickHandlers = {};

	self:EvaluateLockReasons();

	self.debugAreaTriggers = false;
end

function MapCanvasMixin:OnUpdate()
	self:UpdatePinNudging();
end

function MapCanvasMixin:SetMapID(mapID)
	local mapArtID = C_Map.GetMapArtID(mapID) -- phased map art may be different for the same mapID
	if self.mapID ~= mapID or self.mapArtID ~= mapArtID then
		self.areDetailLayersDirty = true;
		self.mapID = mapID; 
		self.mapArtID = mapArtID;
		self.expandedMapInsetsByMapID = {};
		self.ScrollContainer:SetMapID(mapID);
		if self:IsShown() then
			self:RefreshDetailLayers();
		end
		self:OnMapChanged();
	end
end

function MapCanvasMixin:OnFrameSizeChanged()
	self.ScrollContainer:OnCanvasSizeChanged();
end

function MapCanvasMixin:GetMapID()
	return self.mapID;
end

function MapCanvasMixin:SetMapInsetPool(mapInsetPool)
	self.mapInsetPool = mapInsetPool;
end

function MapCanvasMixin:GetMapInsetPool()
	return self.mapInsetPool;
end

function MapCanvasMixin:OnShow()
	local FROM_ON_SHOW = true;
	self:RefreshAll(FROM_ON_SHOW);

	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnShow();
	end
end

function MapCanvasMixin:OnHide()
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnHide();
	end
end

function MapCanvasMixin:OnEvent(event, ...)
	-- Data provider event
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:SignalEvent(event, ...);
	end
end

function MapCanvasMixin:AddDataProvider(dataProvider)
	self.dataProviders[dataProvider] = true;
	dataProvider:OnAdded(self);
end

function MapCanvasMixin:RemoveDataProvider(dataProvider)
	dataProvider:RemoveAllData();
	self.dataProviders[dataProvider] = nil;
	dataProvider:OnRemoved(self);
end

function MapCanvasMixin:AddDataProviderEvent(event)
	self.dataProviderEventsCount[event] = (self.dataProviderEventsCount[event] or 0) + 1;
	self:RegisterEvent(event);
end

function MapCanvasMixin:RemoveDataProviderEvent(event)
	if self.dataProviderEventsCount[event] then
		self.dataProviderEventsCount[event] = self.dataProviderEventsCount[event] - 1;
		if self.dataProviderEventsCount[event] == 0 then
			self.dataProviderEventsCount[event] = nil;
			self:UnregisterEvent(event);
		end
	end
end

function MapCanvasMixin:SetPinNudgingDirty(dirty)
	self.pinNudgingDirty = dirty;
end

do
	local function OnPinReleased(pinPool, pin)
		FramePool_HideAndClearAnchors(pinPool, pin);
		pin:OnReleased();

		pin.pinTemplate = nil;
		pin.owningMap = nil;
	end

	local function OnPinMouseUp(pin, button, upInside)
		pin:OnMouseUp(button);
		if upInside then
			pin:OnClick(button);
		end
	end

	function MapCanvasMixin:AcquirePin(pinTemplate, ...)
		if not self.pinPools[pinTemplate] then
			local pinTemplateType = self.pinTemplateTypes[pinTemplate] or "FRAME";
			self.pinPools[pinTemplate] = CreateFramePool(pinTemplateType, self:GetCanvas(), pinTemplate, OnPinReleased);
		end

		local pin, newPin = self.pinPools[pinTemplate]:Acquire();

		if newPin then
			local isMouseClickEnabled = pin:IsMouseClickEnabled();
			local isMouseMotionEnabled = pin:IsMouseMotionEnabled();

			if isMouseClickEnabled then
				pin:SetScript("OnMouseUp", OnPinMouseUp);
				pin:SetScript("OnMouseDown", pin.OnMouseDown);
			end

			if isMouseMotionEnabled then
				if newPin then
					-- These will never be called, just define a OnMouseEnter and OnMouseLeave on the pin mixin and it'll be called when appropriate
					assert(pin:GetScript("OnEnter") == nil);
					assert(pin:GetScript("OnLeave") == nil);
				end
				pin:SetScript("OnEnter", pin.OnMouseEnter);
				pin:SetScript("OnLeave", pin.OnMouseLeave);
			end

			pin:SetMouseClickEnabled(isMouseClickEnabled);
			pin:SetMouseMotionEnabled(isMouseMotionEnabled);
		end

		pin.pinTemplate = pinTemplate;
		pin.owningMap = self;

		if newPin then
			pin:OnLoad();
		end

		self.ScrollContainer:MarkCanvasDirty();
		pin:Show();
		pin:OnAcquired(...);
		
		return pin;
	end
end

function MapCanvasMixin:SetPinTemplateType(pinTemplate, pinTemplateType)
	self.pinTemplateTypes[pinTemplate] = pinTemplateType;
end

function MapCanvasMixin:RemoveAllPinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		self.pinPools[pinTemplate]:ReleaseAll();
		self.ScrollContainer:MarkCanvasDirty();
	end
end

function MapCanvasMixin:RemovePin(pin)
	if pin:GetNudgeSourceRadius() > 0 then
		self.pinNudgingDirty = true;
	end
	
	self.pinPools[pin.pinTemplate]:Release(pin);
	self.ScrollContainer:MarkCanvasDirty();
end

function MapCanvasMixin:EnumeratePinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		return self.pinPools[pinTemplate]:EnumerateActive();
	end
	return nop;
end

function MapCanvasMixin:GetNumActivePinsByTemplate(pinTemplate)
	if self.pinPools[pinTemplate] then
		return self.pinPools[pinTemplate]:GetNumActive();
	end
	return 0;
end

function MapCanvasMixin:EnumerateAllPins()
	local currentPoolKey, currentPool = next(self.pinPools, nil);
	local currentPin = nil;
	return function()
		if currentPool then
			currentPin = currentPool:GetNextActive(currentPin);
			while not currentPin do
				currentPoolKey, currentPool = next(self.pinPools, currentPoolKey);
				if currentPool then
					currentPin = currentPool:GetNextActive();
				else
					break;
				end
			end
		end

		return currentPin;
	end, nil;
end

function MapCanvasMixin:AcquireAreaTrigger(namespace)
	if not self.activeAreaTriggers[namespace] then
		self.activeAreaTriggers[namespace] = {};
	end
	local areaTrigger = CreateRectangle();
	areaTrigger.enclosed = false;
	areaTrigger.intersects = false;

	areaTrigger.intersectCallback = nil;
	areaTrigger.enclosedCallback = nil;
	areaTrigger.triggerPredicate = nil;

	self.activeAreaTriggers[namespace][areaTrigger] = true;
	self.ScrollContainer:MarkAreaTriggersDirty();
	return areaTrigger;
end

function MapCanvasMixin:SetAreaTriggerEnclosedCallback(areaTrigger, enclosedCallback)
	areaTrigger.enclosedCallback = enclosedCallback;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:SetAreaTriggerIntersectsCallback(areaTrigger, intersectCallback)
	areaTrigger.intersectCallback = intersectCallback;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:SetAreaTriggerPredicate(areaTrigger, triggerPredicate)
	areaTrigger.triggerPredicate = triggerPredicate;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:ReleaseAreaTriggers(namespace)
	self.activeAreaTriggers[namespace] = nil;
	self:TryRefreshingDebugAreaTriggers();
end

function MapCanvasMixin:ReleaseAreaTrigger(namespace, areaTrigger)
	if self.activeAreaTriggers[namespace] then
		self.activeAreaTriggers[namespace][areaTrigger] = nil;
		self:TryRefreshingDebugAreaTriggers();
	end
end

function MapCanvasMixin:UpdateAreaTriggers(scrollRect)
	for namespace, areaTriggers in pairs(self.activeAreaTriggers) do
		for areaTrigger in pairs(areaTriggers) do
			if areaTrigger.intersectCallback then
				local intersects = (not areaTrigger.triggerPredicate or areaTrigger.triggerPredicate(areaTrigger)) and scrollRect:IntersectsRect(areaTrigger);
				if areaTrigger.intersects ~= intersects then
					areaTrigger.intersects = intersects;
					areaTrigger.intersectCallback(areaTrigger, intersects);
				end
			end

			if areaTrigger.enclosedCallback then
				local enclosed = (not areaTrigger.triggerPredicate or areaTrigger.triggerPredicate(areaTrigger)) and scrollRect:EnclosesRect(areaTrigger);

				if areaTrigger.enclosed ~= enclosed then
					areaTrigger.enclosed = enclosed;
					areaTrigger.enclosedCallback(areaTrigger, enclosed);
				end
			end
		end
	end

	self:TryRefreshingDebugAreaTriggers();
end

function SquaredDistanceBetweenPoints(firstX, firstY, secondX, secondY)
	local xDiff = firstX - secondX;
	local yDiff = firstY - secondY;
	
	return xDiff * xDiff + yDiff * yDiff;
end

function MapCanvasMixin:CalculatePinNudging(targetPin)
	targetPin:SetNudgeVector(nil, nil, nil, nil);
	if not targetPin:IgnoresNudging() and targetPin:GetNudgeTargetFactor() > 0 then
		local normalizedX, normalizedY = targetPin:GetPosition();
		for sourcePin in self:EnumerateAllPins() do
			if targetPin ~= sourcePin and not sourcePin:IgnoresNudging() and sourcePin:GetNudgeSourceRadius() > 0 then
				local otherNormalizedX, otherNormalizedY = sourcePin:GetPosition();
				local distanceSquared = SquaredDistanceBetweenPoints(normalizedX, normalizedY, otherNormalizedX, otherNormalizedY);
				
				local nudgeFactor = targetPin:GetNudgeTargetFactor() * sourcePin:GetNudgeSourceRadius();
				if distanceSquared < nudgeFactor * nudgeFactor then
					local distance = math.sqrt(distanceSquared);
					
					-- Avoid divide by zero: just push it right.
					if distanceSquared == 0 then
						targetPin:SetNudgeVector(sourcePin:GetNudgeSourceZoomedOutMagnitude(), sourcePin:GetNudgeSourceZoomedInMagnitude(), 1, 0);
					else
						targetPin:SetNudgeVector(sourcePin:GetNudgeSourceZoomedOutMagnitude(), sourcePin:GetNudgeSourceZoomedInMagnitude(), (normalizedX - otherNormalizedX) / distance, (normalizedY - otherNormalizedY) / distance);
					end
					
					targetPin:SetNudgeFactor(1 - (distance / nudgeFactor));
					break; -- This is non-exact: each target pin only gets pushed by one source pin.
				end
			end
		end
	end
end

function MapCanvasMixin:UpdatePinNudging()
	if not self.pinNudgingDirty and #self.pinsToNudge == 0 then
		return;
	end
	
	if self.pinNudgingDirty then
		for targetPin in self:EnumerateAllPins() do
			self:CalculatePinNudging(targetPin);
		end
	else
		for _, targetPin in ipairs(self.pinsToNudge) do
			self:CalculatePinNudging(targetPin);
		end
	end
	
	self.pinNudgingDirty = false;
	self.pinsToNudge = {};
end

function MapCanvasMixin:TryRefreshingDebugAreaTriggers()
	if self.debugAreaTriggers then
		self:RefreshDebugAreaTriggers();
	elseif self.debugAreaTriggerPool then
		self.debugAreaTriggerPool:ReleaseAll();
	end
end

function MapCanvasMixin:RefreshDebugAreaTriggers()
	if not self.debugAreaTriggerPool then
		self.debugAreaTriggerPool = CreateTexturePool(self:GetCanvas(), "OVERLAY", 7, "MapCanvasDebugTriggerAreaTemplate");
		self.debugAreaTriggerColors = {};
	end
	
	self.debugAreaTriggerPool:ReleaseAll();

	local canvas = self:GetCanvas();

	for namespace, areaTriggers in pairs(self.activeAreaTriggers) do
		if not self.debugAreaTriggerColors[namespace] then
			self.debugAreaTriggerColors[namespace] = { math.random(), math.random(), math.random(), 0.45 };
		end
		for areaTrigger in pairs(areaTriggers) do
			local debugAreaTexture = self.debugAreaTriggerPool:Acquire();
			debugAreaTexture:SetPoint("TOPLEFT", canvas, "TOPLEFT", canvas:GetWidth() * areaTrigger:GetLeft(), -canvas:GetHeight() * areaTrigger:GetTop());
			debugAreaTexture:SetPoint("BOTTOMRIGHT", canvas, "TOPLEFT", canvas:GetWidth() * areaTrigger:GetRight(), -canvas:GetHeight() * areaTrigger:GetBottom());
			debugAreaTexture:SetColorTexture(unpack(self.debugAreaTriggerColors[namespace]));
			debugAreaTexture:Show();
		end
	end
end

function MapCanvasMixin:SetDebugAreaTriggersEnabled(enabled)
	self.debugAreaTriggers = enabled;
	self.ScrollContainer:MarkAreaTriggersDirty();
end

function MapCanvasMixin:RefreshDetailLayers()
	if not self.areDetailLayersDirty then return end;
	self.detailLayerPool:ReleaseAll();

	local layers = C_Map.GetMapArtLayers(self.mapID);
	for layerIndex, layerInfo in ipairs(layers) do
		local detailLayer = self.detailLayerPool:Acquire();
		detailLayer:SetAllPoints(self:GetCanvas());
		detailLayer:SetMapAndLayer(self.mapID, layerIndex);
		detailLayer:SetGlobalAlpha(self:GetGlobalAlpha());
		detailLayer:Show();
	end

	self:AdjustDetailLayerAlpha();

	self.areDetailLayersDirty = false;
end

function MapCanvasMixin:AreDetailLayersLoaded()
	for detailLayer in self.detailLayerPool:EnumerateActive() do
		if not detailLayer:IsFullyLoaded() then
			return false;
		end
	end
	return true;
end

function MapCanvasMixin:AdjustDetailLayerAlpha()
	self.ScrollContainer:AdjustDetailLayerAlpha(self.detailLayerPool);
end

function MapCanvasMixin:RefreshAllDataProviders(fromOnShow)
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:RefreshAllData(fromOnShow);
	end
end

function MapCanvasMixin:ResetInsets()
	if self.mapInsetPool then
		self.mapInsetPool:ReleaseAll();
		self.mapInsetsByIndex = {};
	end
end

function MapCanvasMixin:RefreshInsets()
	self:ResetInsets();
end

function MapCanvasMixin:AddInset(insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY)
	if self.mapInsetPool then
		local mapInset = self.mapInsetPool:Acquire();
		local expanded = self.expandedMapInsetsByMapID[mapID];
		mapInset:Initialize(self, not expanded, insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY);

		self.mapInsetsByIndex[insetIndex] = mapInset;
	end
end

function MapCanvasMixin:RefreshAll(fromOnShow)
	self:RefreshDetailLayers();
	self:RefreshInsets();
	self:RefreshAllDataProviders(fromOnShow);
end

function MapCanvasMixin:SetPinPosition(pin, normalizedX, normalizedY, insetIndex)
	self:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex);
	if not pin:IgnoresNudging() then
		if pin:GetNudgeSourceRadius() > 0 then
			-- If we nudge other things we need to recalculate all nudging.
			self.pinNudgingDirty = true;
		else
			self.pinsToNudge[#self.pinsToNudge + 1] = pin;
		end
	end
end

function MapCanvasMixin:ApplyPinPosition(pin, normalizedX, normalizedY, insetIndex)
	if insetIndex then
		if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
			self.mapInsetsByIndex[insetIndex]:SetLocalPinPosition(pin, normalizedX, normalizedY);
			pin:ApplyFrameLevel();
		end
	else
		pin:ClearAllPoints();
		if normalizedX and normalizedY then
			local x = normalizedX;
			local y = normalizedY;
			
			local nudgeVectorX, nudgeVectorY = pin:GetNudgeVector();
			if nudgeVectorX and nudgeVectorY then
				local finalNudgeFactor = pin:GetNudgeFactor() * pin:GetNudgeTargetFactor() * pin:GetNudgeZoomFactor();
				x = normalizedX + nudgeVectorX * finalNudgeFactor;
				y = normalizedY + nudgeVectorY * finalNudgeFactor;
			end
			
			local canvas = self:GetCanvas();
			local scale = pin:GetScale();
			pin:SetParent(canvas);
			pin:ApplyFrameLevel();
			pin:SetPoint("CENTER", canvas, "TOPLEFT", (canvas:GetWidth() * x) / scale, -(canvas:GetHeight() * y) / scale);
		end
	end
end

function MapCanvasMixin:GetGlobalPosition(normalizedX, normalizedY, insetIndex)
	if self.mapInsetsByIndex and self.mapInsetsByIndex[insetIndex] then
		return self.mapInsetsByIndex[insetIndex]:GetGlobalPosition(normalizedX, normalizedY);
	end
	return normalizedX, normalizedY;
end

function MapCanvasMixin:GetCanvas()
	return self.ScrollContainer.Child;
end

function MapCanvasMixin:GetCanvasContainer()
	return self.ScrollContainer;
end

function MapCanvasMixin:CallMethodOnPinsAndDataProviders(methodName, ...)
	for dataProvider in pairs(self.dataProviders) do
		dataProvider[methodName](dataProvider, ...);
	end

	for pin in self:EnumerateAllPins() do
		pin[methodName](pin, ...);
	end
end

function MapCanvasMixin:OnMapInsetSizeChanged(mapID, mapInsetIndex, expanded)
	self.expandedMapInsetsByMapID[mapID] = expanded;
	self:CallMethodOnPinsAndDataProviders("OnMapInsetSizeChanged", mapInsetIndex, expanded);
end

function MapCanvasMixin:OnMapInsetMouseEnter(mapInsetIndex)
	self:CallMethodOnPinsAndDataProviders("OnMapInsetMouseEnter", mapInsetIndex);
end

function MapCanvasMixin:OnMapInsetMouseLeave(mapInsetIndex)
	self:CallMethodOnPinsAndDataProviders("OnMapInsetMouseLeave", mapInsetIndex);
end

function MapCanvasMixin:OnMapChanged()
	for dataProvider in pairs(self.dataProviders) do
		dataProvider:OnMapChanged();
	end
end

function MapCanvasMixin:OnCanvasScaleChanged()
	self:AdjustDetailLayerAlpha();

	if self.mapInsetsByIndex then
		for insetIndex, mapInset in pairs(self.mapInsetsByIndex) do
			mapInset:OnCanvasScaleChanged();
		end
	end

	self:CallMethodOnPinsAndDataProviders("OnCanvasScaleChanged");
end

function MapCanvasMixin:OnCanvasPanChanged()
	self:CallMethodOnPinsAndDataProviders("OnCanvasPanChanged");
end

function MapCanvasMixin:OnCanvasSizeChanged()
	self:CallMethodOnPinsAndDataProviders("OnCanvasSizeChanged");
end

function MapCanvasMixin:GetCanvasScale()
	return self.ScrollContainer:GetCanvasScale();
end

function MapCanvasMixin:GetCanvasZoomPercent()
	return self.ScrollContainer:GetCanvasZoomPercent();
end

function MapCanvasMixin:IsZoomingIn()
	return self.ScrollContainer:IsZoomingIn();
end

function MapCanvasMixin:IsZoomingOut()
	return self.ScrollContainer:IsZoomingOut();
end

function MapCanvasMixin:ZoomIn()
	self.ScrollContainer:ZoomIn();
end

function MapCanvasMixin:ZoomOut()
	self.ScrollContainer:ZoomOut();
end

function MapCanvasMixin:ResetZoom()
	self.ScrollContainer:ResetZoom();
end

function MapCanvasMixin:IsAtMaxZoom()
	return self.ScrollContainer:IsAtMaxZoom();
end

function MapCanvasMixin:IsAtMinZoom()
	return self.ScrollContainer:IsAtMinZoom();
end

function MapCanvasMixin:PanTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY);
end

function MapCanvasMixin:PanAndZoomTo(normalizedX, normalizedY)
	self.ScrollContainer:SetPanTarget(normalizedX, normalizedY);
	self.ScrollContainer:ZoomIn();
end

function MapCanvasMixin:SetMouseWheelZoomMode(zoomMode)
	self.ScrollContainer:SetMouseWheelZoomMode(zoomMode);
end

function MapCanvasMixin:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.ScrollContainer:SetShouldZoomInOnClick(shouldZoomInOnClick);
end

function MapCanvasMixin:ShouldZoomInOnClick()
	return self.ScrollContainer:ShouldZoomInOnClick();
end

function MapCanvasMixin:SetShouldNavigateOnClick(shouldNavigateOnClick)
	self.ScrollContainer:SetShouldNavigateOnClick(shouldNavigateOnClick);
end

function MapCanvasMixin:ShouldNavigateOnClick()
	return self.ScrollContainer:ShouldNavigateOnClick();
end

function MapCanvasMixin:SetShouldPanOnClick(shouldPanOnClick)
	self.ScrollContainer:SetShouldPanOnClick(shouldPanOnClick);
end

function MapCanvasMixin:ShouldPanOnClick()
	return self.ScrollContainer:ShouldPanOnClick();
end

function MapCanvasMixin:SetShouldZoomInstantly(shouldZoomInstantly)
	self.ScrollContainer:SetShouldZoomInstantly(shouldZoomInstantly);
end

function MapCanvasMixin:ShouldZoomInstantly()
	return self.ScrollContainer:ShouldZoomInstantly();
end

function MapCanvasMixin:GetViewRect()
	return self.ScrollContainer:GetViewRect();
end

function MapCanvasMixin:GetMaxZoomViewRect()
	return self.ScrollContainer:GetMaxZoomViewRect();
end

function MapCanvasMixin:GetMinZoomViewRect()
	return self.ScrollContainer:GetMinZoomViewRect();
end

function MapCanvasMixin:GetScaleForMaxZoom()
	return self.ScrollContainer:GetScaleForMaxZoom();
end

function MapCanvasMixin:GetScaleForMinZoom()
	return self.ScrollContainer:GetScaleForMinZoom();
end

function MapCanvasMixin:CalculateZoomScaleAndPositionForAreaInViewRect(...)
	return self.ScrollContainer:CalculateZoomScaleAndPositionForAreaInViewRect(...);
end

function MapCanvasMixin:NormalizeHorizontalSize(size)
	return self.ScrollContainer:NormalizeHorizontalSize(size);
end

function MapCanvasMixin:DenormalizeHorizontalSize(size)
	return self.ScrollContainer:DenormalizeHorizontalSize(size);
end

function MapCanvasMixin:NormalizeVerticalSize(size)
	return self.ScrollContainer:NormalizeVerticalSize(size);
end

function MapCanvasMixin:DenormalizeVerticalSize(size)
	return self.ScrollContainer:DenormalizeVerticalSize(size);
end

function MapCanvasMixin:GetNormalizedCursorPosition()
	return self.ScrollContainer:GetNormalizedCursorPosition()
end

function MapCanvasMixin:IsCanvasMouseFocus()
	return self.ScrollContainer == GetMouseFocus();
end

function MapCanvasMixin:AddLockReason(reason)
	self.lockReasons[reason] = true;
	self:EvaluateLockReasons();
end

function MapCanvasMixin:RemoveLockReason(reason)
	self.lockReasons[reason] = nil;
	self:EvaluateLockReasons();
end

function MapCanvasMixin:EvaluateLockReasons()
	if next(self.lockReasons) then
		self.BorderFrame:EnableMouse(true);
		self.BorderFrame:EnableMouseWheel(true);
		if self.BorderFrame.Underlay then
			self.BorderFrame.Underlay:Show();
		end
	else
		self.BorderFrame:EnableMouse(false);
		self.BorderFrame:EnableMouseWheel(false);
		if self.BorderFrame.Underlay then
			self.BorderFrame.Underlay:Hide();
		end
	end
end

function MapCanvasMixin:GetPinFrameLevelsManager()
	return self.pinFrameLevelsManager;
end

function MapCanvasMixin:ReapplyPinFrameLevels(pinFrameLevelType)
	for pin in self:EnumerateAllPins() do
		if pin:GetFrameLevelType() == pinFrameLevelType then
			pin:ApplyFrameLevel();
		end
	end
end

function MapCanvasMixin:NavigateToParentMap()
	local mapInfo = C_Map.GetMapInfo(self:GetMapID());
	if mapInfo.parentMapID > 0 then
		self:SetMapID(mapInfo.parentMapID);
	end
end

function MapCanvasMixin:NavigateToCursor()
	local normalizedCursorX, normalizedCursorY = self:GetNormalizedCursorPosition();
	local mapInfo = C_Map.GetMapInfoAtPosition(self:GetMapID(), normalizedCursorX, normalizedCursorY);
	if mapInfo then
		self:SetMapID(mapInfo.mapID);
	end
end

-- Add a function that will be checked when the canvas is clicked
-- If the function returns true then handling will stop
-- A priority can optionally be specified, higher priority values will be called first
do
	local function PrioritySorter(left, right)
		return left.priority > right.priority;
	end
	function MapCanvasMixin:AddCanvasClickHandler(handler, priority)
		table.insert(self.mouseClickHandlers, { handler = handler, priority = priority or 0 });
		table.sort(self.mouseClickHandlers, PrioritySorter);
	end
end

function MapCanvasMixin:RemoveCanvasClickHandler(handler, priority)
	for i, handlerInfo in ipairs(self.mouseClickHandlers) do
		if handlerInfo.handler == handler and (not priority or handlerInfo.priority == priority) then
			table.remove(i);
			break;
		end
	end
end

function MapCanvasMixin:ProcessCanvasClickHandlers(button, cursorX, cursorY)
	for i, handlerInfo in ipairs(self.mouseClickHandlers) do
		local success, stopChecking = xpcall(handlerInfo.handler, CallErrorHandler, self, button, cursorX, cursorY);
		if success and stopChecking then
			return true;
		end
	end
	return false;
end

function MapCanvasMixin:GetGlobalPinScale()
	return self.globalPinScale or 1;
end

function MapCanvasMixin:SetGlobalPinScale(scale)
	if self.globalPinScale ~= scale then
		self.globalPinScale = scale;
		for pin in self:EnumerateAllPins() do
			pin:ApplyCurrentScale();
		end
	end
end

function MapCanvasMixin:GetGlobalAlpha()
	return self.globalAlpha or 1;
end

function MapCanvasMixin:SetGlobalAlpha(globalAlpha)
	if self.globalAlpha ~= globalAlpha then
		self.globalAlpha = globalAlpha;
		for detailLayer in self.detailLayerPool:EnumerateActive() do
			detailLayer:SetGlobalAlpha(globalAlpha);
		end
		for dataProvider in pairs(self.dataProviders) do
			dataProvider:OnGlobalAlphaChanged();
		end
	end
end