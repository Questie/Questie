---@class FramePoolMap
---@field private frameType string
---@field private parent Region
local FramePool = Mixin(QuestieLoader:CreateModule("FramePoolMap"), CreateFramePool("BUTTON", WorldMapFrame:GetCanvas()))

---@type PinTemplates
local PinTemplates = QuestieLoader:ImportModule("PinTemplates")

---@type BasePinMixin
local BasePinMixin = QuestieLoader:ImportModule("BasePinMixin")

---@class TexturePool
---@field Release fun(self: TexturePool, texture: Texture): boolean
---@field private inactiveObjects Texture[]
---@field private activeObjects table<Texture, boolean>
---@field private disallowResetIfNew boolean
---@field private parent Frame @The parent where all the textures are created
TexturePool = CreateTexturePool(WorldMapFrame:GetCanvas(), "OVERLAY", 0, nil)
TexturePool.disallowResetIfNew = true



--* Up values
local wipe = wipe

-- register pin pool with the world map
WorldMapFrame.pinPools[PinTemplates.MapPinTemplate] = FramePool

-- setup pin pool
do
    -- A raw BasePin used to revert to the default pin template
    local basePin

    local count = 0
    local name = "QuestieMapFrame"

    -- This function creates the pin itself
    ---@param framePool FramePoolMap
    ---@return MapIconFrame
    FramePool.creationFunc = function(framePool)
        --Questie:Debug(DEBUG_DEVELOP, "FramePool.creationFunc")
        count = count + 1
        ---@class MapIconFrame : Button, BasePinMixin
        local frame = CreateFrame(framePool.frameType, name .. count, framePool.parent)
        frame.highlightTexture = frame:CreateTexture(nil, "HIGHLIGHT")
        frame = Mixin(frame, BasePinMixin) --[[@as MapIconFrame]]
        frame.dirty = false
        frame.textures = {}
        frame:SetHighlightTexture(frame.highlightTexture)
        frame.highlightTexture:ClearAllPoints()
        frame.highlightTexture:SetPoint("CENTER")
        frame.highlightTexture:SetSize(16, 16)
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
                    TexturePool:Release(pin.textures[textureIndex])
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
            pin = Mixin(pin, BasePinMixin)

            --Frame setup

            -- Reset highlight texture
            --? nil is allowed
            ---@diagnostic disable-next-line: param-type-mismatch
            pin.highlightTexture:SetTexture(nil)

            --? It is reset so the pin is not dirty
            pin.dirty = false
        end
    end

    basePin = FramePool.creationFunc(FramePool)
end

-- Regular Textures
do
    local textureCount = 0

    ---@param self TexturePool
    ---@return Texture
    ---@return boolean
    TexturePool.Acquire = function(self)
        --? This code is 99% from blizzard, only Questie Specific taged things are changed.
        local numInactiveObjects = #self.inactiveObjects
        if numInactiveObjects > 0 then
            local obj = self.inactiveObjects[numInactiveObjects]
            self.activeObjects[obj] = true
            self.numActiveObjects = self.numActiveObjects + 1
            self.inactiveObjects[numInactiveObjects] = nil

            --* Questie Specific
            obj.dirty = true

            return obj, false
        end

        local newObj = self.creationFunc(self)
        if self.resetterFunc and not self.disallowResetIfNew then
            self.resetterFunc(self, newObj)
        end
        self.activeObjects[newObj] = true
        self.numActiveObjects = self.numActiveObjects + 1

        --* Questie Specific
        newObj.dirty = true

        return newObj, true
    end

    --- The function is called internally in the TexturePool, use TexturePool:Acquire
    ---@param texturePool TexturePool
    ---@return MapIconTexture
    TexturePool.creationFunc = function(texturePool)
        textureCount = textureCount + 1
        ---@class MapIconTexture : Texture
        local tex = texturePool.parent:CreateTexture("IconTexture" .. textureCount)
        --tex:SetSnapToPixelGrid(false)
        --tex:SetTexelSnappingBias(0)
        tex:SetSize(16, 16)
        tex:SetSnapToPixelGrid(false)
        tex:SetTexelSnappingBias(0)
        tex.dirty = false
        return tex
    end

    ---Resets the texture to the default state
    ---@param self TexturePool
    ---@param tex MapIconTexture
    TexturePool.resetterFunc = function(self, tex)
        --Questie:Debug(DEBUG_DEVELOP, "Blob.TexturePool.resetterFunc")
        --print("Reseting texture", tex:GetName())

        if tex.dirty then
            tex:SetSize(16, 16)
            tex:SetAlpha(1)
            tex:SetDesaturated(false)
            tex:Hide()
            tex.dirty = false
        end
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
--- If the table above is missing a function or if the value is false, it will be overwritten
function MixinPin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
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

    return object
end

--- Not in use, the idea behind it was to be able to remove the mixin from the pin
function MixoutPin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = nil
        end
    end

    return object
end
