---@type QuestieNS
local Questie = select(2, ...)


---@class MapFramePool
local FramePool = CreateFramePool("BUTTON")

---@class TexturePool
---@field Acquire fun(): Texture
---@field Release fun(self: TexturePool, texture: Texture): boolean
TexturePool = CreateTexturePool(WorldMapFrame:GetCanvas(), "OVERLAY", 0, nil)

worldPinTemplate = "QLMapWorldmapTemplate"

-- register pin pool with the world map
WorldMapFrame.pinPools[worldPinTemplate] = FramePool

-- setup pin pool
do
    -- A raw BasePin used to revert to the default pin template
    local basePin

    local count = 0
    local name = "QuestieMapFrame"
    FramePool.parent = WorldMapFrame:GetCanvas()

    -- This function creates the pin itself
    FramePool.creationFunc = function(framePool)
        --Questie:Debug(DEBUG_DEVELOP, "FramePool.creationFunc")
        ---@class MapIconFrame : Button, BasePinMixin
        local frame = CreateFrame(framePool.frameType, name .. count, framePool.parent)

        frame:SetParent(framePool.parent)
        frame.parent = framePool.parent;
        count = count + 1;
        frame = Mixin(frame, Questie.BasePinMixin)
        frame:SetSize(16, 16);
        frame.dirty = false
        frame.textures = {}
        --frame:SetIgnoreGlobalPinScale(true)
        return frame
    end

    -- This function is run everytime a pin is acquired from the pool
    ---comment
    ---@param pinPool any
    ---@param pin MapIconFrame|BasePinMixin
    FramePool.resetterFunc = function(pinPool, pin)
        if pin.dirty == true then
            -- print("FramePool.resetterFunc")
            -- Release all textures or create the table if it doesn't exist
            if pin.textures then
                for textureIndex = 1, #pin.textures do
                    TexturePool:Release(pin.textures[textureIndex]);
                end
                pin.textures = wipe(pin.textures)
            end

            FramePool_HideAndClearAnchors(pinPool, pin)
            pin:OnReleased()


            pin.owningMap = nil
            pin.pinTemplate = nil
            pin.data = nil --Not used?

            -- Remove any information on the pin that is not part of the base pin
            for key in pairs(pin) do
                if basePin[key] == nil then
                    pin[key] = nil
                end
            end

            -- Reset the functions within the pin, maybe we have to do this smarter for performance
            ---@diagnostic disable-next-line: cast-local-type
            pin = Mixin(pin, Questie.BasePinMixin)

            --Frame setup
            pin:SetParent(FramePool.parent)
            pin:SetPoint("CENTER")
            pin:SetSize(16, 16)

            --? It is reset so the pin is not dirty
            pin.dirty = false
        end
    end

    basePin = FramePool.creationFunc(FramePool)
end

-- Regular Textures
do
    local textureCount = 0;

    TexturePool.creationFunc = function(texturePool)
        textureCount = textureCount + 1;
        local tex = texturePool.parent:CreateTexture("IconTexture" .. textureCount, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer);
        --tex:SetSnapToPixelGrid(false)
        --tex:SetTexelSnappingBias(0)
        tex:SetSize(16, 16)
        tex:SetSnapToPixelGrid(false)
        tex:SetTexelSnappingBias(0)
        return tex
    end

    ---comment
    ---@param self TexturePool
    ---@param tex Texture
    TexturePool.resetterFunc = function(self, tex)
        --Questie:Debug(DEBUG_DEVELOP, "Blob.TexturePool.resetterFunc")
        --print("Reseting texture", tex:GetName())
        --tex:ClearAllPoints()
        --tex:SetParent(FramePool.parent)
        ----tex:SetTexCoord(0,1,0,1)
        tex:SetAlpha(1)
        tex:SetDesaturated(false)
        tex:SetBlendMode("BLEND")
        tex:SetDrawLayer("ARTWORK")
        tex:Hide();
    end
end


local AllowedFunction = {
    -- ["OnLoad"] = true, -- Because of how we mix in the pin after Acquired, this could destroy things
    -- ["OnAcquired"] = true, -- Because of how we mix in the pin after Acquired, this could destroy things
    ["OnReleased"] = true,
    ["OnClick"] = true,
    ["OnMouseEnter"] = true,
    ["OnMouseLeave"] = true,
    ["OnMouseDown"] = true,
    ["OnMouseUp"] = true,
    ["OnMapInsetSizeChanged"] = true,
    ["OnMapInsetMouseEnter"] = true,
    ["OnMapInsetMouseLeave"] = true,
    ["SetNudgeTargetFactor"] = true,
    ["GetNudgeTargetFactor"] = true,
    ["SetNudgeSourceRadius"] = true,
    ["GetNudgeSourceRadius"] = true,
    ["SetNudgeSourceMagnitude"] = true,
    ["GetNudgeSourceZoomedOutMagnitude"] = true,
    ["GetNudgeSourceZoomedInMagnitude"] = true,
    ["SetNudgeZoomedInFactor"] = true,
    ["GetZoomedInNudgeFactor"] = true,
    ["SetNudgeZoomedOutFactor"] = true,
    ["GetZoomedOutNudgeFactor"] = true,
    ["IgnoresNudging"] = true,
    ["GetMap"] = true,
    ["GetNudgeVector"] = true,
    ["GetNudgeSourcePinZoomedOutNudgeFactor"] = true,
    ["GetNudgeSourcePinZoomedInNudgeFactor"] = true,
    ["SetNudgeVector"] = true,
    ["GetNudgeFactor"] = true,
    ["SetNudgeFactor"] = true,
    ["GetNudgeZoomFactor"] = true,
    ["SetPosition"] = true,
    ["GetPosition"] = true,
    ["GetGlobalPosition"] = true,
    ["PanTo"] = true,
    ["PanAndZoomTo"] = true,
    ["OnCanvasScaleChanged"] = true,
    ["OnCanvasPanChanged"] = true,
    ["OnCanvasSizeChanged"] = true,
    ["SetIgnoreGlobalPinScale"] = true,
    ["IsIgnoringGlobalPinScale"] = true,
    ["SetScalingLimits"] = true,
    ["SetScaleStyle"] = true,
    ["SetAlphaLimits"] = true,
    ["SetAlphaStyle"] = true,
    ["ApplyCurrentPosition"] = true,
    ["ApplyCurrentScale"] = true,
    ["ApplyCurrentAlpha"] = true,
    ["UseFrameLevelType"] = true,
    ["GetFrameLevelType"] = true,
    ["ApplyFrameLevel"] = true,
    -- Own added types
    ["GetType"] = false, -- This should always be overwritten not chained.
}

--- This function Mixes in the pin and creates a "call-chain" for functions on the base object
function MixinPin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...);
        for k, v in pairs(mixin) do
            if AllowedFunction[k] and object[k] and type(object[k]) == "function" and type(v) == "function" then
                local func = object[k]
                object[k] = function(self, ...)
                    func(self, ...)
                    v(self, ...)
                end
            else
                object[k] = v
            end
        end
    end

    return object;
end

function MixoutPin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...);
        for k, v in pairs(mixin) do
            object[k] = nil;
        end
    end

    return object;
end
