---@class MinimapProvider
local MinimapProvider = Mixin(QuestieLoader:CreateModule("MinimapProvider"), QuestieLoader("MinimapDataProviderMixin"))

---@type MinimapCanvas
local MinimapCanvas = QuestieLoader("MinimapCanvas")

---@type PinTemplates
local PinTemplates = QuestieLoader("PinTemplates")

---@type QuestieLib
local QuestieLib = QuestieLoader("QuestieLib")

---@type FramePoolMinimap
local FramePoolMinimap = QuestieLoader("FramePoolMinimap")

---@type MapCoordinates
local MapCoordinates = QuestieLoader("MapCoordinates")

---@param owningMinimap MinimapCanvas
function MinimapProvider:OnAdded(owningMinimap)
    print("MinimapProvider OnAdded")
    self.owningMinimap = owningMinimap;

    for x = 1, 100, 1 do
        for y = 1, 100, 1 do
            local pin = self.owningMinimap:AcquirePin(PinTemplates.MinimapPinTemplate)
            local objectTexture = FramePoolMinimap.TexturePool:Acquire();
            objectTexture:SetParent(pin)
            objectTexture:SetPoint("CENTER");
            objectTexture:SetTexture(QuestieLib.AddonPath .. "Icons\\available.blp")
            objectTexture:SetSize(16, 16)
            objectTexture:SetScale(Minimap:GetScale())
            objectTexture:Show();
            pin.textures[#pin.textures + 1] = objectTexture
            pin:SetPosition(MapCoordinates.Maps[1413]:ToWorldCoordinate(x, y))
            -- pin:UseFrameLevelType()
            pin:SetSize(8,15)
            pin:SetPoint("CENTER")
            pin:SetAlphaDistance(1, 1.5)
            pin:SetScaleDistance(1.35, 1.45)
            pin:SetMaxCalulationDistance(3)
            pin:Hide()
            pin.hidden = true
        end
    end
    -- local pin = self.owningMinimap:AcquirePin(PinTemplates.MinimapPinTemplate)
    -- local objectTexture = FramePoolMinimap.TexturePool:Acquire();
    -- objectTexture:SetParent(pin)
    -- objectTexture:SetPoint("CENTER");
    -- objectTexture:SetTexture(QuestieLib.AddonPath .. "Icons\\available.blp")
    -- objectTexture:SetSize(16, 16)
    -- objectTexture:SetScale(Minimap:GetScale())
    -- objectTexture:Show();
    -- pin.textures[#pin.textures + 1] = objectTexture
    -- pin:SetPosition(GetPlayerWorldPosFast(1413))
    -- -- pin:UseFrameLevelType()
    -- pin:SetSize(16,16)
    -- pin:SetPoint("CENTER")
    -- pin:Hide()
    -- pin.hidden = true
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
