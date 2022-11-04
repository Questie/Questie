---@type QuestieNS
local Questie = select(2, ...)

-- Contains library functions that do not have a logical place.
---@class FramePoolWaypoint
local FramePoolWaypoint = QuestieLoader:CreateModule("FramePoolWaypoint")

---@type WaypointPinMixin
local WaypointPinMixin = QuestieLoader:ImportModule("WaypointPinMixin")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

FramePoolWaypoint.waypointPinTemplate = "WaypointMapWorldmapTemplate"

---@class WaypointMapFramePool
local FramePool = CreateFramePool("BUTTON")

FramePoolWaypoint.FramePool = FramePool

-- register pin pool with the world map
WorldMapFrame.pinPools[FramePoolWaypoint.waypointPinTemplate] = FramePool


local count = 0
local name = "QuestieWaypointMapFrame"

--- WORLD MAP
-- setup pin pool
FramePool.parent = WorldMapFrame:GetCanvas()
FramePool.creationFunc = function(framePool)
    --Questie:Debug(DEBUG_DEVELOP, "FramePool.creationFunc")
    ---@class WaypointMapIconFrame
    local frame = CreateFrame(framePool.frameType, name..count, framePool.parent)

    frame:SetParent(framePool.parent)
    frame.parent = framePool.parent;
    count = count + 1;
    frame = Mixin(frame, Questie.BasePinMixin)
    frame = MixinPin(frame, WaypointPinMixin)
    frame.lineTexture = {}
    --frame:SetIgnoreGlobalPinScale(true)
    return frame
end
FramePool.resetterFunc = function(pinPool, pin)
    --Questie:Debug(DEBUG_DEVELOP, "FramePool.resetterFunc")
    FramePool_HideAndClearAnchors(pinPool, pin)
    pin:OnReleased()

    if(pin.lineTexture) then
        FramePoolWaypoint.LinePool:Release(pin.lineTexture);
    end
    pin.lineTexture = nil

    --Frame setup
    pin:ClearAllPoints()
    pin:SetParent(FramePool.parent)
    pin:SetPoint("CENTER")
    pin:Hide();
end
-- MINIMAP

-- local function updateMaskTexture()
--     print("updateMaskTexture ran")
--     WaypointMap.minimapMask:ClearAllPoints();
--     WaypointMap.minimapMask:SetAllPoints(Minimap)
--     WaypointMap.minimapMask:SetTexture(MinimapMaskTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
-- end

-- WaypointMap.minimapMask = Minimap:CreateMaskTexture()
-- WaypointMap.playerMask = Minimap:CreateMaskTexture()
-- local timer;
-- local count = 0;
-- timer = C_Timer.NewTicker(0.5, function()
--     if(count > 10) then --60 seconds
--         MinimapMaskTexture = QuestieLib.AddonPath.."Icons\\circlemask";
--     end
--     if(MinimapMaskTexture) then
--         updateMaskTexture()
--         WaypointMap.playerMask:SetTexture(QuestieLib.AddonPath.."Icons\\playermask", "CLAMP", "CLAMP", "NEAREST")
--         WaypointMap.playerMask:SetParent(Minimap)
--         WaypointMap.playerMask:SetPoint("CENTER", 0, 0)
--         WaypointMap.playerMask:SetSize(38,38)
--         timer:Cancel();
--         timer = nil
--     end
--     count = count + 1
-- end)

-- WaypointMap.MinimapFramePool = CreateFramePool("BUTTON")
-- WaypointMap.minimapPinTemplate = "QuestieMinimapWaypointMapFrame"

-- --for i = 1, 835 do _G["QuestieMinimapWaypointMapFrame"..i]:Show() end
-- --for i = 1, 835 do _G["QuestieMinimapWaypointMapFrame"..i].lineTexture:Show() end

-- local minimapCount = 0
-- local minimapName = "QuestieMinimapWaypointMapFrame"
-- -- setup pin pool
-- WaypointMap.MinimapFramePool.parent = Minimap
-- WaypointMap.MinimapFramePool.creationFunc = function(framePool)
--     --Questie:Debug(DEBUG_DEVELOP, "WaypointMap.MinimapFramePool.creationFunc")
--     local frame = CreateFrame(framePool.frameType, minimapName..minimapCount, framePool.parent)
--     --print("FrameC:", minimapCount)
--     frame:SetParent(framePool.parent)
--     frame.parent = framePool.parent;
--     minimapCount = minimapCount + 1;
--     frame = Mixin(frame, WaypointMap.PinMixin)
--     frame.minimapPin = true
--     --frame:SetIgnoreGlobalPinScale(true)
--     return frame
-- end
-- WaypointMap.MinimapFramePool.resetterFunc = function(pinPool, pin)
--     --Questie:Debug(DEBUG_DEVELOP, "WaypointMap.MinimapFramePool.resetterFunc")
--     FramePool_HideAndClearAnchors(pinPool, pin)
--     --pin:OnReleased()

--     if(pin.lineTexture) then
--         FramePoolWaypoint.LinePool:Release(pin.lineTexture);
--     end
--     pin.lineTexture = nil

--     pin.minimapPin = true

--     --Frame setup
--     --pin:ClearAllPoints()
--     --pin:SetParent(WaypointMap.MinimapFramePool.parent)
--     --pin:SetPoint("CENTER")
--     --pin:Hide();
-- end

-- Regular lines

local lineCount = 0;

local function lineReset(self, line)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.linePool.resetterFunc")

    --line.color = nil;
    --line.startX = nil
    --line.startY = nil
    --line.endX = nil
    --line.endY = nil
    --line.thickness = nil
    --line.defaultThickness = nil

    --Remove all mask textures
    for _, maskTexture in pairs(line.maskTextures or {}) do
        line:RemoveMaskTexture(maskTexture);
    end
    wipe(line.maskTextures)

    --line:SetParent(UIParent)
    --line:ClearAllPoints()
    --line:SetTexCoord(0,1,0,1)
    --line:Hide();
end

local function redraw(self, zoomScale)
    self:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
    self.drawlinefunction(self, self:GetParent(), self.startX, self.startY, self.endX, self.endY, self.thickness / (zoomScale or 1), 1, "TOPLEFT");
end

local function lineCreate(linePool)
    --print("Line:", lineCount)
    lineCount = lineCount + 1;
    local line = linePool.parent:CreateTexture("LineTexture"..lineCount, linePool.layer, linePool.textureTemplate, linePool.subLayer);
    line = Mixin(line, LineMixin)
    line.drawlinefunction = DrawLine
    line.redraw = redraw
    --line:SetSnapToPixelGrid(false)
    --line:SetTexelSnappingBias(0)
    line:SetTexture(QuestieLib.AddonPath.."Icons\\WHITE32X32BLACKLINES", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    line:SetSnapToPixelGrid(false)
    line:SetTexelSnappingBias(0)
    line.maskTextures = {}
    return line
end

FramePoolWaypoint.LinePool = CreateTexturePool(Minimap, "OVERLAY", 0, nil, lineReset)
FramePoolWaypoint.LinePool.creationFunc = lineCreate;
