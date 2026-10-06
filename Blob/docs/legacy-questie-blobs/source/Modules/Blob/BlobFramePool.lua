-------------------------
--Import modules.
-------------------------
---@type Blob
local Blob = QuestieLoader:ImportModule("Blob");

---@class BlobFramePool
Blob.FramePool = CreateFramePool("BUTTON")

Blob.worldPinTemplate = "BlobWorldmapTemplateQuestie"

local count = 0
local name = "BlobFrame"

-- setup pin pool
Blob.FramePool.parent = WorldMapFrame:GetCanvas()
Blob.FramePool.creationFunc = function(framePool)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.FramePool.creationFunc")
    ---@class BlobIconFrame
    local frame = CreateFrame(framePool.frameType, name..count, framePool.parent)

    --IMPROVE HERE!
    --local width, height = Blob.FramePool.parent:GetSize();
    --frame:SetSize(100, 100)
    --frame:SetPoint("TOPLEFT")
    frame:SetParent(framePool.parent)
    frame.parent = framePool.parent;
    --frame.width = width;
    --frame.height = height;
    frame.textures = {}
    frame.lines = {}
    frame.polygon = true
    count = count + 1;
    return Mixin(frame, BlobMapPin)
end
Blob.FramePool.resetterFunc = function(pinPool, pin)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.FramePool.resetterFunc")
    --FramePool_HideAndClearAnchors(pinPool, pin)

    pin.pinTemplate = nil
    pin.owningMap = nil
    pin.points = nil
    pin.hull = nil
    pin.splineHull = nil
    pin.polygon = true
    
    pin.drawData = nil
    pin.UiMapID = nil
    pin.overrideFunctions = nil

    --Release all textures back to the pool
    for _, texture in pairs(pin.textures or {}) do
        Blob.TexturePool:Release(texture);
    end
    --We reset pin.textures not to get any "ghosting" textures.
    pin.textures = {}

    --Release all lines back to the pool
    for _, line in pairs(pin.lines or {}) do
        Blob.LinePool:Release(line);
    end

    --We reset pin.lines not to get any "ghosting" lines.
    pin.lines = {}

    --Frame setup
    pin:SetParent(Blob.FramePool.parent)
    --These two things are the same thing.
    --pin:Hide();
    --pin:ClearAllPoints()
    FramePool_HideAndClearAnchors(pinPool, pin)
end

-- register pin pool with the world map
WorldMapFrame.pinPools[Blob.worldPinTemplate] = Blob.FramePool

---@class BlobMinimapFramePool
Blob.MinimapFramePool = CreateFramePool("FRAME")

Blob.minimapPinTemplate = "BlobMinimapTemplateQuestie"

local minimapCount = 0
local minimapName = "BlobMinimapFrame"

-- setup pin pool
Blob.MinimapFramePool.parent = Minimap
Blob.MinimapFramePool.creationFunc = function(framePool)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.MinimapFramePool.creationFunc")
    ---@class BlobMinimapIconFrame
    local frame = CreateFrame(framePool.frameType, minimapName..minimapCount, framePool.parent)

    --IMPROVE HERE!
    --local width, height = Blob.MinimapFramePool.parent:GetSize();
    --frame:SetSize(100, 100)
    --frame:SetPoint("TOPLEFT")
    frame:SetParent(framePool.parent)
    frame.parent = framePool.parent;
    --frame.width = width;
    --frame.height = height;
    frame.textures = {}
    frame.lines = {}
    --frame = Mixin(frame, BlobMapPin) -- Not needed!
    --A function to redraw all the lines when zooming on the minimap
    frame.redrawAllLines = function(self, zoomScale)
        for _, line in pairs(self.lines or {}) do
            line.redraw(line, zoomScale)
        end
    end
    frame:SetPoint("CENTER")

    minimapCount = minimapCount + 1;
    return Mixin(frame, BlobMapPin)
end
Blob.MinimapFramePool.resetterFunc = function(pinPool, pin)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.MinimapFramePool.resetterFunc")
    --FramePool_HideAndClearAnchors(pinPool, pin)

    pin.pinTemplate = nil
    pin.owningMap = nil
    pin.points = nil
    pin.hull = nil
    pin.splineHull = nil
    pin.polygon = true

    pin.drawData = nil
    pin.UiMapID = nil
    pin.overrideFunctions = nil

    --Release all textures back to the pool
    for _, texture in pairs(pin.textures or {}) do
        Blob.TexturePool:Release(texture);
    end
    --We reset pin.textures not to get any "ghosting" textures.
    pin.textures = {}

    --Release all lines back to the pool
    for _, line in pairs(pin.lines or {}) do
        Blob.LinePool:Release(line);
    end
    --We reset pin.lines not to get any "ghosting" lines.
    pin.lines = {}

    --Frame setup
    pin:ClearAllPoints()
    --pin:SetParent(Blob.MinimapFramePool.parent)
    pin:Hide();
end