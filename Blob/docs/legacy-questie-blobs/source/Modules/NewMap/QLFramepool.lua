-- Contains library functions that do not have a logical place.
---@type Map
---@param utils table
---@param FramePool table
---@param PinMixin table
local Map = QuestieLoader:ImportModule("Map")

---@class MapFramePool
Map.FramePool = CreateFramePool("BUTTON")

Map.worldPinTemplate = "QLMapWorldmapTemplate"

-- register pin pool with the world map
WorldMapFrame.pinPools[Map.worldPinTemplate] = Map.FramePool

local count = 0
local name = "QuestieMapFrame"

-- setup pin pool
Map.FramePool.parent = WorldMapFrame:GetCanvas()
Map.FramePool.creationFunc = function(framePool)
    --Questie:Debug(DEBUG_DEVELOP, "Map.FramePool.creationFunc")
    ---@class MapIconFrame
    local frame = CreateFrame(framePool.frameType, name..count, framePool.parent)

    frame:SetParent(framePool.parent)
    frame.parent = framePool.parent;
    count = count + 1;
    frame = Mixin(frame, Map.PinMixin)
    --frame:SetIgnoreGlobalPinScale(true)
    return frame
end
Map.FramePool.resetterFunc = function(pinPool, pin)
    --Questie:Debug(DEBUG_DEVELOP, "Map.FramePool.resetterFunc")
    FramePool_HideAndClearAnchors(pinPool, pin)
    pin:OnReleased()

    --if(pin.PinMixin) then
    --    pin.PinMixin:UnInitialize();
    --end

    for _, texture in pairs(pin.textures or {}) do
        Map.TexturePool:Release(texture);
    end
    pin.textures = {}

    pin.pinTemplate = nil
    pin.owningMap = nil
    pin.data = nil --Not used?
    pin.object = nil
    pin.subNotes = nil

    --pin:SetScalingLimits(1, 1.0, 0.8) Set at draw instead

    --Frame setup
    pin:ClearAllPoints()
    pin:SetParent(Map.FramePool.parent)
    pin:SetPoint("CENTER")
    pin:Hide();
end

-- Regular Textures

local textureCount = 0;

local function textureReset(self, tex)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.TexturePool.resetterFunc")
    
    --tex:ClearAllPoints()
    --tex:SetTexCoord(0,1,0,1)
    tex:Hide();
end

local function textureCreate(texturePool)
    textureCount = textureCount + 1;
    local tex = texturePool.parent:CreateTexture("IconTexture"..textureCount, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer);
    --tex:SetSnapToPixelGrid(false)
    --tex:SetTexelSnappingBias(0)
    tex:SetSnapToPixelGrid(false)
    tex:SetTexelSnappingBias(0)
    return tex
end

Map.TexturePool = CreateTexturePool(WorldMapFrame:GetCanvas(), "OVERLAY", 0, nil, textureReset)
Map.TexturePool.creationFunc = textureCreate;