---@class MinimapProvider
local MinimapProvider = Mixin(QuestieLoader:CreateModule("MinimapProvider"), QuestieLoader("MinimapDataProviderMixin"))

---@type MinimapCanvas
local MinimapCanvas = QuestieLoader("MinimapCanvas")

---@type PinTemplates
local PinTemplates = QuestieLoader("PinTemplates")

---@param owningMinimap MinimapCanvas
function MinimapProvider:OnAdded(owningMinimap)
    print("MinimapProvider OnAdded")
    self.owningMinimap = owningMinimap;


    local pin = self.owningMinimap:AcquirePin(PinTemplates.MinimapPinTemplate)
end

function MinimapProvider:RemoveAllData()
    -- Override in your mixin, this method should remove everything that has been added to the map
    print("MinimapProvider RemoveAllData")
end

function MinimapProvider:RefreshAllData(fromOnShow)
    print("RefreshAllData", fromOnShow)
end

-- Are these useful?
-- function MinimapProvider:OnShow()
-- 	-- Override in your mixin, called when the map canvas is shown
-- end

-- function MinimapProvider:OnHide()
-- 	-- Override in your mixin, called when the map canvas is closed
-- end

-- function MinimapProvider:OnEvent(event, ...)
-- 	-- Override in your mixin to accept events register via RegisterEvent
-- end

-- TODO: NYI
function MinimapProvider:OnZoomChanged()
    -- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function MinimapProvider:OnMapChanged()
    --  Optionally override in your mixin, called when map ID changes
    print("OnMapChanged")
end

MinimapCanvas:AddDataProvider(MinimapProvider)
