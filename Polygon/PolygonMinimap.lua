-- luacheck: read globals GetMinimapShape GetPlayerFacing
---@class PolygonMinimap
local PolygonMinimap = QuestieLoader:CreateModule("PolygonMinimap")

---@type PolygonRenderer
local PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

---@class PolygonMinimapArea
---@field key table Stable identity of one drawn area, such as its marker record.
---@field cluster PolygonCluster Source geometry; the outline is in cluster.uiMapId percentages.
---@field color number[] Area RGB.
---@field alpha number Marker fade in (0, 1], scaling fill and border opacity.
---@field highlighted boolean? Previewed from the quest log or tracker; drawn with a highlighted border.

---@class PolygonWorldOutline
---@field points table[] {x, y} in HereBeDragons world yards.
---@field bounds number[] {minX, minY, maxX, maxY}

---@class PolygonMinimapProjection
---@field originX number World yards the projected outlines are relative to.
---@field originY number
---@field instanceId number
---@field radius number Yards from the minimap's center to its edge.
---@field halfWidth number Minimap half-extent in its own units.
---@field halfHeight number
---@field facing number? Player facing in radians while the minimap rotates; nil keeps north up.

---@class PolygonMinimapView
---@field frame Frame
---@field cluster PolygonCluster Geometry the frame was configured from.
---@field projection PolygonMinimapProjection Projection the frame was configured with.
---@field color number[] Area color the frame was styled with.
---@field alpha number Fade the frame was styled with.
---@field highlighted boolean? Highlight the frame was styled with.

-- Same fill and border opacity as the world map's areas at full marker opacity.
local FILL_ALPHA, BORDER_ALPHA = 0.25, 0.75
-- An area counts as in view while its bounds reach this many view radii from the player.
-- A square minimap's corners are √2 radii away.
local VIEW_MARGIN = 1.5
-- Areas leave a soft hole over the player arrow so they never hide it.
local PLAYER_MASK = "Interface\\Addons\\Questie\\Icons\\polygon-minimap-player-mask.tga"
local PLAYER_MASK_SIZE = 38
local ROUND_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local SQUARE_MASK = "Interface\\BUTTONS\\WHITE8X8"
-- Forever's own round minimap mask (Blizzard_Minimap/Camelot/Skin.lua).
local FOREVER_MASK_ATLAS = "ui-hud-minimap-frame-generic-mask"

-- Geometry
-- Clusters are immutable; rebuilt geometry arrives as new clusters, so the cache needs no
-- invalidation. false records a map without world data.
---@type table<PolygonCluster, PolygonWorldOutline|false>
local worldOutlines = setmetatable({}, {__mode = "k"})

---Converts a cluster's outline from its map's percentages to world yards. Each axis uses the
---zone's own extent in yards, so zones not drawn at exactly the map's 3:2 shape keep their true
---proportions, and the minimap needs only one scale.
---@param cluster PolygonCluster
---@return PolygonWorldOutline?
function PolygonMinimap.WorldOutline(cluster)
    local cached = worldOutlines[cluster]
    if cached ~= nil then return cached or nil end
    local points, minX, minY, maxX, maxY = {}, math.huge, math.huge, -math.huge, -math.huge
    for i, point in ipairs(cluster.outline) do
        local x, y = HBD:GetWorldCoordinatesFromZone(point.x / 100, point.y / 100, cluster.uiMapId)
        if not x or not y then
            worldOutlines[cluster] = false
            return nil
        end
        points[i] = {x = x, y = y}
        minX, minY, maxX, maxY = math.min(minX, x), math.min(minY, y), math.max(maxX, x), math.max(maxY, y)
    end
    cached = {points = points, bounds = {minX, minY, maxX, maxY}}
    worldOutlines[cluster] = cached
    return cached
end

-- HereBeDragons-Pins' minimap icon arithmetic, so areas and icons line up: the world offset
-- turns with the facing, then scales by the view radius. x is right and y is down, the
-- renderer's TOPLEFT convention.
local function _ProjectPoint(x, y, originX, originY, scaleX, scaleY, sin, cos)
    local dx, dy = originX - x, originY - y
    return (dx * cos - dy * sin) * scaleX, (dx * sin + dy * cos) * scaleY
end

---@param view PolygonMinimapProjection
---@return number scaleX
---@return number scaleY
---@return number sin
---@return number cos
local function _Transform(view)
    local facing = view.facing or 0
    return view.halfWidth / view.radius, view.halfHeight / view.radius, math.sin(facing), math.cos(facing)
end

---Places world points relative to an origin, in the minimap's units.
---@param points table[] World yards.
---@param originX number
---@param originY number
---@param view PolygonMinimapProjection Only radius, halfWidth, halfHeight and facing are read.
---@return table[] projected
function PolygonMinimap.Project(points, originX, originY, view)
    local scaleX, scaleY, sin, cos = _Transform(view)
    local projected = {}
    for i, point in ipairs(points) do
        local x, y = _ProjectPoint(point.x, point.y, originX, originY, scaleX, scaleY, sin, cos)
        projected[i] = {x = x, y = y}
    end
    return projected
end

---@param bounds number[] World bounds {minX, minY, maxX, maxY}.
---@param x number Player world position.
---@param y number
---@param radius number View radius in yards.
---@return boolean
function PolygonMinimap.IsInView(bounds, x, y, radius)
    local reach = radius * VIEW_MARGIN
    return bounds[1] <= x + reach and bounds[3] >= x - reach and bounds[2] <= y + reach and bounds[4] >= y - reach
end

-- Minimap shape
-- Blizzard has no getter for the minimap's mask, so the last asset passed to
-- Minimap:SetMaskTexture since Questie loaded is the only exact source. nil until a call.
local hookedMaskAsset
---@type MaskTexture[]
local shapeMasks = {}

local function _IsAtlas(asset)
    return type(asset) == "string" and C_Texture ~= nil and C_Texture.GetAtlasInfo ~= nil
        and C_Texture.GetAtlasInfo(asset) ~= nil
end

---Chooses the minimap's shape mask. An asset seen through Minimap:SetMaskTexture is exact; minimap
---addons such as SexyMap set their shapes that way. Addons that loaded before Questie can only
---be read through GetMinimapShape, a community convention Blizzard does not define. Without
---it the minimap is round. Shapes that are square except for one rounded corner use the square.
---@return string|number asset
---@return boolean isAtlas
function PolygonMinimap.ShapeMask()
    if hookedMaskAsset then return hookedMaskAsset, _IsAtlas(hookedMaskAsset) end
    local shape = type(GetMinimapShape) == "function" and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" or (type(shape) == "string" and shape:find("^CORNER%-")) then return SQUARE_MASK, false end
    if _IsAtlas(FOREVER_MASK_ATLAS) then return FOREVER_MASK_ATLAS, true end
    return ROUND_MASK, false
end

-- Clamping to black keeps everything outside the minimap's rectangle masked out.
---@param mask MaskTexture
local function _ApplyShapeMask(mask)
    local asset, isAtlas = PolygonMinimap.ShapeMask()
    if isAtlas then
        mask:SetAtlas(asset, false, nil, nil, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    else
        mask:SetTexture(asset, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end
end

-- Installed at load so minimap addons loading after Questie are seen. A post-hook only
-- observes the call; Blizzard's method runs unchanged. Neither installing nor running it may
-- break the caller or this file, so failures fall back to GetMinimapShape and are reported
-- once a layer exists.
local maskHookError
if Minimap then
    local hooked, err = pcall(hooksecurefunc, Minimap, "SetMaskTexture", function(_, asset)
        hookedMaskAsset = asset
        for _, mask in ipairs(shapeMasks) do
            local applied, applyErr = pcall(_ApplyShapeMask, mask)
            if not applied then maskHookError = applyErr end
        end
    end)
    if not hooked then maskHookError = err end
end

-- Minimap layer
-- Areas are projected relative to a fixed origin into a container frame. Walking only moves
-- the container; outlines are projected again when the zoom, minimap size, instance, or
-- facing of a rotating minimap changes. Nothing here takes mouse input or calls protected API.
---@class PolygonMinimapLayer
---@field minimap Frame
---@field collect fun(): PolygonMinimapArea[]
---@field root Frame Covers the minimap; owns the masks and runs the updates.
---@field container Frame Moves with the player; the renderer's canvas.
---@field renderer PolygonCanvasRenderer
---@field views table<table, PolygonMinimapView> By area key, including areas out of view.
---@field areas PolygonMinimapArea[]
---@field dirty boolean The collected areas are stale.
---@field projection PolygonMinimapProjection?
---@field visible Frame[]? Published visible set; nil forces the next publication.
---@field playerX number? Position at the last placement; nil forces the next one.
---@field playerY number?
local Layer = {}
Layer.__index = Layer

---@param layer PolygonMinimapLayer
---@param frames Frame[]
local function _Publish(layer, frames)
    local visible = layer.visible
    if visible and #visible == #frames then
        local same = true
        for i, frame in ipairs(frames) do
            if visible[i] ~= frame then same = false; break end
        end
        if same then return end
    end
    layer.renderer:SetVisibleFrames(frames)
    layer.visible = frames
end

---Returns the area's frame, configured for the current projection and styled in its color.
---@param layer PolygonMinimapLayer
---@param area PolygonMinimapArea
---@param world PolygonWorldOutline
---@param projection PolygonMinimapProjection
---@return Frame
local function _View(layer, area, world, projection)
    local view = layer.views[area.key]
    local color, alpha, highlighted = area.color, area.alpha, area.highlighted == true
    if view and view.cluster == area.cluster and view.projection == projection and view.color == color
        and view.alpha == alpha and view.highlighted == highlighted then
        return view.frame
    end
    local shape = {color = {color[1], color[2], color[3], FILL_ALPHA * alpha}, borderAlpha = BORDER_ALPHA * alpha,
        highlighted = highlighted}
    local level = layer.container:GetFrameLevel()
    if view and view.cluster == area.cluster and view.projection == projection then
        layer.renderer:Style(view.frame, shape, level)
    else
        -- The renderer's percentages over a 100x100 extent are minimap units.
        shape.points = PolygonMinimap.Project(world.points, projection.originX, projection.originY, projection)
        if view then
            layer.renderer:Configure(view.frame, shape, 100, 100, level)
        else
            view = {frame = layer.renderer:Create(shape, 100, 100, level)}
            layer.views[area.key] = view
        end
    end
    view.cluster, view.projection, view.color, view.alpha, view.highlighted = area.cluster, projection, color, alpha,
        highlighted
    return view.frame
end

---Releases views whose areas were not collected again.
---@param layer PolygonMinimapLayer
local function _ReleaseRemoved(layer)
    local current = {}
    for _, area in ipairs(layer.areas) do current[area.key] = true end
    for key, view in pairs(layer.views) do
        if not current[key] then
            layer.views[key] = nil
            layer.renderer:Release(view.frame)
        end
    end
    layer.visible = nil
end

local function _IsSecret(...)
    if not issecretvalue then return false end
    for i = 1, select("#", ...) do
        if issecretvalue((select(i, ...))) then return true end
    end
    return false
end

function Layer:Update()
    if self.dirty then
        self.dirty = false
        self.areas = self.collect()
        _ReleaseRemoved(self)
        self.playerX, self.playerY = nil, nil
        if #self.areas == 0 then
            _Publish(self, {})
            -- Invalidate shows the layer again; until then it costs nothing per frame.
            self.root:Hide()
            return
        end
    end

    -- Inside instances, and while values are restricted, there is no position to draw around.
    local x, y, instanceId = HBD:GetPlayerWorldPosition()
    local radius, rotating = HBDPins:GetMinimapView()
    local facing = rotating and GetPlayerFacing() or nil
    if _IsSecret(x, y, radius, facing) or not x or not y or not radius or radius <= 0 or (rotating and not facing) then
        _Publish(self, {})
        self.playerX, self.playerY = nil, nil
        return
    end

    local halfWidth, halfHeight = self.minimap:GetWidth() / 2, self.minimap:GetHeight() / 2
    -- A minimap without a size yet has no extent to project into.
    if not (halfWidth > 0 and halfHeight > 0) then
        _Publish(self, {})
        self.playerX, self.playerY = nil, nil
        return
    end
    local projection = self.projection
    if not projection or projection.instanceId ~= instanceId or projection.radius ~= radius or projection.facing ~= facing
        or projection.halfWidth ~= halfWidth or projection.halfHeight ~= halfHeight then
        projection = {originX = x, originY = y, instanceId = instanceId, radius = radius, facing = facing,
            halfWidth = halfWidth, halfHeight = halfHeight}
        self.projection = projection
        self.playerX = nil
    end
    if x == self.playerX and y == self.playerY then return end
    self.playerX, self.playerY = x, y

    local frames = {}
    for _, area in ipairs(self.areas) do
        if area.cluster.instanceId == instanceId then
            local world = PolygonMinimap.WorldOutline(area.cluster)
            if world and PolygonMinimap.IsInView(world.bounds, x, y, radius) then
                frames[#frames + 1] = _View(self, area, world, projection)
            end
        end
    end
    _Publish(self, frames)

    -- The origin projected around the player is the container's offset from the minimap's center.
    local scaleX, scaleY, sin, cos = _Transform(projection)
    local offsetX, offsetY = _ProjectPoint(projection.originX, projection.originY, x, y, scaleX, scaleY, sin, cos)
    self.container:ClearAllPoints()
    self.container:SetPoint("TOPLEFT", self.minimap, "CENTER", offsetX, -offsetY)
end

---Collects the areas again on the next update, after quest, visibility, or option changes.
function Layer:Invalidate()
    self.dirty = true
    self.root:Show()
end

---Releases every drawing; frames and textures stay pooled. Areas are collected again once
---the layer is invalidated. Native cleanup failure throws after every view was attempted.
function Layer:Clear()
    self.views, self.areas, self.visible, self.projection = {}, {}, nil, nil
    self.playerX, self.playerY = nil, nil
    self.dirty = true
    self.renderer:Clear()
end

---Creates the layer over the minimap. Drawing starts on the first Invalidate.
---@param minimap Frame
---@param collect fun(): PolygonMinimapArea[] Areas that should show, wherever they are.
---@return PolygonMinimapLayer
function PolygonMinimap.New(minimap, collect)
    if maskHookError then Questie.Error("Polygon minimap shape tracking failed:", maskHookError) end
    -- Clipping crops outlines to the minimap's rectangle, which the masks then shape, and
    -- skips drawing what lies beyond it.
    local root = CreateFrame("Frame", nil, minimap)
    root:SetAllPoints(minimap)
    root:SetClipsChildren(true)
    root:Hide()
    -- Areas use the lowest level above the map itself, so they stay beneath the minimap's
    -- bezel, buttons and other addons' pins wherever levels decide.
    root:SetFrameLevel(minimap:GetFrameLevel() + 1)
    local container = CreateFrame("Frame", nil, root)
    container:SetSize(1, 1)
    container:SetFrameLevel(root:GetFrameLevel())

    local shapeMask = root:CreateMaskTexture()
    shapeMask:SetAllPoints(minimap)
    _ApplyShapeMask(shapeMask)
    shapeMasks[#shapeMasks + 1] = shapeMask
    -- Opaque except a soft hole in its middle; clamped edges keep everything around it opaque.
    local playerMask = root:CreateMaskTexture()
    playerMask:SetTexture(PLAYER_MASK, "CLAMP", "CLAMP")
    playerMask:SetPoint("CENTER", minimap, "CENTER")
    playerMask:SetSize(PLAYER_MASK_SIZE, PLAYER_MASK_SIZE)

    local layer = setmetatable({minimap = minimap, collect = collect, root = root, container = container,
        renderer = PolygonRenderer.New(container, nil, {shapeMask, playerMask}),
        views = {}, areas = {}, dirty = true}, Layer)
    -- A failure stops drawing until the next change rather than repeating every frame.
    root:SetScript("OnUpdate", function()
        local updated, err = pcall(layer.Update, layer)
        if not updated then
            root:Hide()
            Questie.Error("Polygon minimap drawing failed:", err)
            local cleared, clearErr = pcall(layer.Clear, layer)
            if not cleared then Questie.Error("Polygon minimap cleanup failed:", clearErr) end
        end
    end)
    return layer
end
