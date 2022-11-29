---@class FramePoolMinimap : FramePool
---@field private frameType string
---@field private parent Region
local FramePoolMinimap = Mixin(QuestieLoader:CreateModule("FramePoolMinimap"), CreateFramePool("BUTTON", Minimap))
FramePoolMinimap.disallowResetIfNew = true

---@type PinTemplates
local PinTemplates = QuestieLoader("PinTemplates")

---@type MinimapCanvas
local MinimapCanvas = QuestieLoader("MinimapCanvas")

---@class TexturePool
---@field Release fun(self: TexturePool, texture: Texture): boolean
---@field private inactiveObjects Texture[]
---@field private activeObjects table<Texture, boolean>
---@field private disallowResetIfNew boolean
---@field private parent Frame @The parent where all the textures are created
local TexturePool = CreateTexturePool(Minimap, "OVERLAY", 0, nil)
TexturePool.disallowResetIfNew = true
FramePoolMinimap.TexturePool = TexturePool


--* Up values
local wipe = wipe
local setmetatable = setmetatable
local tInsert = table.insert

-- register pin pool with the world map
MinimapCanvas.pinPools[PinTemplates.MinimapPinTemplate] = FramePoolMinimap

-- setup pin pool
do
    -- A raw BasePin used to revert to the default pin template
    local basePin

    local count = 0
    local name = "QuestieMinimapFrame"


    ---@type table<MapIconFrame, table<string, boolean>>
    local dirtyKeys = {}
    -- local metaTable = { __newindex = function (self, key, value)
    --     if not dirtyKeys[self] then
    --         dirtyKeys[self] = {}
    --     end
    --     if not dirtyKeys[self][key] then
    --         dirtyKeys[self][key] = true
    --     end
    --     -- tInsert(dirtyKeys[self], key)
    --     self[key] = value
    --     return self[key]
    -- end }

    -- local __newindex = function (self, key, value)
    --     -- print("Settings new index", key, value)
    --     if not dirtyKeys[self] then
    --         dirtyKeys[self] = {}
    --     end
    --     if not dirtyKeys[self][key] then
    --         dirtyKeys[self][key] = true
    --     end
    --     -- tInsert(dirtyKeys[self], key)
    --     rawset(self, key, value)
    --     return self[key]
    -- end

    -- This function creates the pin itself
    ---@param framePool FramePoolMinimap
    ---@return MapIconFrame
    FramePoolMinimap.creationFunc = function(framePool)
        --Questie:Debug(DEBUG_DEVELOP, "FramePool.creationFunc")
        count = count + 1
        ---@class MapIconFrame : Button -- BasePinMixin
        local frame = CreateFrame(framePool.frameType, name .. count or nil, framePool.parent)

        frame.highlightTexture = frame:CreateTexture(nil, "HIGHLIGHT")
        -- frame = Mixin(frame, BasePinMixin) --[[@as MapIconFrame]]
        frame.dirty = false
        frame.textures = {}
        frame.data = {}
        frame:SetHighlightTexture(frame.highlightTexture)
        frame.highlightTexture:ClearAllPoints()
        frame.highlightTexture:SetPoint("CENTER")
        frame.highlightTexture:SetSize(16, 16)
        -- local metatable = getmetatable(frame)
        -- metatable.__newindex = __newindex
        -- frame = setmetatable(frame, metatable) --[[@as MapIconFrame]]
        --frame:SetIgnoreGlobalPinScale(true)
        return frame
    end

    -- This function is run everytime a pin is acquired from the pool
    ---comment
    ---@param pinPool any
    ---@param pin MapIconFrame|BasePinMixin
    FramePoolMinimap.resetterFunc = function(pinPool, pin)
        if pin.dirty == true then
            if dirtyKeys[pin] then
                DevTools_Dump(dirtyKeys[pin])
            end
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


            pin.owningMinimap = nil
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
            -- pin = Mixin(pin, BasePinMixin)

            --Frame setup

            -- Reset highlight texture
            --? nil is allowed
            ---@diagnostic disable-next-line: param-type-mismatch
            pin.highlightTexture:SetTexture(nil)

            --? It is reset so the pin is not dirty
            pin.dirty = false


        end
    end

    -- basePin = FramePoolMinimap.creationFunc(FramePoolMinimap)
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
