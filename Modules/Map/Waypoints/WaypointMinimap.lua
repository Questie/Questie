-- luacheck: read globals GetMinimapShape GetPlayerFacing issecretvalue
---@class WaypointMinimap
local WaypointMinimap = QuestieLoader:CreateModule("WaypointMinimap")

---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type WaypointRenderer
local WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- Line width in minimap units.
local LINE_THICKNESS = 4
-- Everything visible lies within √2 view radii of the player: a square minimap's corners. Segments
-- within CULL_MARGIN radii of the projection origin are drawn, which covers that view while the
-- player stays within REPROJECT_DRIFT radii of the origin; beyond it the paths are projected again.
local CULL_MARGIN = 2
local REPROJECT_DRIFT = 0.5
-- Paths leave a soft hole over the player arrow so they never hide it.
local PLAYER_MASK = QuestieLib.AddonPath .. "Icons\\minimap-player-mask.tga"
local PLAYER_MASK_SIZE = 38
local ROUND_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local SQUARE_MASK = "Interface\\BUTTONS\\WHITE8X8"
-- Forever's own round minimap mask (Blizzard_Minimap/Camelot/Skin.lua).
local FOREVER_MASK_ATLAS = "ui-hud-minimap-frame-generic-mask"

---@class WaypointMinimapProjection
---@field originX number World yards the projected paths are relative to.
---@field originY number
---@field instanceId number
---@field radius number Yards from the minimap's center to its edge.
---@field halfWidth number Minimap half-extent in its own units.
---@field halfHeight number
---@field facing number? Player facing in radians while the minimap rotates; nil keeps north up.

---@class WaypointMinimapEntry
---@field view WaypointView? nil while no segment is within reach of the projection.
---@field projection WaypointMinimapProjection Projection the view was drawn with.
---@field alpha number

-- Projection
-- HereBeDragons-Pins' minimap icon arithmetic, so paths and icons line up: the world offset turns
-- with the facing, then scales by the view radius. x is right and y is down.
local function _ProjectPoint(x, y, originX, originY, scaleX, scaleY, sin, cos)
    local dx, dy = originX - x, originY - y
    return (dx * cos - dy * sin) * scaleX, (dx * sin + dy * cos) * scaleY
end

---@param view WaypointMinimapProjection
---@return number scaleX, number scaleY, number sin, number cos
local function _Transform(view)
    local facing = view.facing or 0
    return view.halfWidth / view.radius, view.halfHeight / view.radius, math.sin(facing), math.cos(facing)
end

---Projects the segments of a path that come within reach of the projection's origin, as endpoint
---pairs in minimap units relative to it.
---@param world WaypointWorldPoint[]
---@param projection WaypointMinimapProjection
---@return table[] segments
local function _Segments(world, projection)
    local reach = projection.radius * CULL_MARGIN
    local originX, originY = projection.originX, projection.originY
    local scaleX, scaleY, sin, cos = _Transform(projection)
    local segments = {}
    local previous, previousProjected
    for _, point in ipairs(world) do
        if previous and math.max(previous.x, point.x) >= originX - reach and math.min(previous.x, point.x) <= originX + reach
            and math.max(previous.y, point.y) >= originY - reach and math.min(previous.y, point.y) <= originY + reach then
            if not previousProjected then
                local x, y = _ProjectPoint(previous.x, previous.y, originX, originY, scaleX, scaleY, sin, cos)
                previousProjected = {x = x, y = y}
            end
            local x, y = _ProjectPoint(point.x, point.y, originX, originY, scaleX, scaleY, sin, cos)
            local projected = {x = x, y = y}
            segments[#segments + 1] = previousProjected
            segments[#segments + 1] = projected
            previousProjected = projected
        else
            previousProjected = nil
        end
        previous = point
    end
    return segments
end

-- Minimap shape
-- Blizzard has no getter for the minimap's mask, so the last asset passed to
-- Minimap:SetMaskTexture since Questie loaded is the only exact source. nil until a call.
local hookedMaskAsset
---@type MaskTexture?
local shapeMask

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
function WaypointMinimap.ShapeMask()
    if hookedMaskAsset then return hookedMaskAsset, _IsAtlas(hookedMaskAsset) end
    local shape = type(GetMinimapShape) == "function" and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" or (type(shape) == "string" and shape:find("^CORNER%-")) then return SQUARE_MASK, false end
    if _IsAtlas(FOREVER_MASK_ATLAS) then return FOREVER_MASK_ATLAS, true end
    return ROUND_MASK, false
end

-- Clamping to black keeps everything outside the minimap's rectangle masked out.
---@param mask MaskTexture
local function _ApplyShapeMask(mask)
    local asset, isAtlas = WaypointMinimap.ShapeMask()
    if isAtlas then
        mask:SetAtlas(asset, false, nil, nil, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    else
        mask:SetTexture(asset, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end
end

-- Installed at load so minimap addons loading after Questie are seen. A post-hook only observes the
-- call; Blizzard's method runs unchanged. Neither installing nor running it may break the caller
-- or this file, so failures fall back to GetMinimapShape and are reported once the layer exists.
local maskHookError
if Minimap then
    local hooked, err = pcall(hooksecurefunc, Minimap, "SetMaskTexture", function(_, asset)
        hookedMaskAsset = asset
        if shapeMask then
            local applied, applyErr = pcall(_ApplyShapeMask, shapeMask)
            if not applied then maskHookError = applyErr end
        end
    end)
    if not hooked then maskHookError = err end
end

-- Minimap layer
-- Paths are projected relative to a fixed origin into a container frame. Walking only moves the
-- container; paths are projected again when the zoom, minimap size, instance, or facing of a
-- rotating minimap changes. Nothing here takes mouse input or calls protected API.

---@class WaypointMinimapLayer
---@field minimap Frame
---@field root Frame Covers the minimap; owns the masks and runs the updates.
---@field container Frame Moves with the player; the renderer's canvas.
---@field renderer WaypointCanvasRenderer
---@field entries table<WaypointPath, WaypointMinimapEntry> Drawn paths, including those out of view.
---@field paths {path: WaypointPath, alpha: number}[] Paths that should show, wherever they are.
---@field dirty boolean The collected paths are stale.
---@field projection WaypointMinimapProjection?
---@field stale boolean The shown views must be chosen again: new paths or a new projection.
---@field shown WaypointView[] Views shown by the last publication.
---@field playerX number? Position at the last placement; nil forces the next one.
---@field playerY number?
local Layer = {}
Layer.__index = Layer

local function _IsSecret(...)
    if not issecretvalue then return false end
    for i = 1, select("#", ...) do
        if issecretvalue((select(i, ...))) then return true end
    end
    return false
end

---@param layer WaypointMinimapLayer
---@param views WaypointView[]
local function _Publish(layer, views)
    local show = {}
    for _, view in ipairs(views) do show[view] = true end
    for _, view in ipairs(layer.shown) do
        if not show[view] then view:Hide() end
    end
    for _, view in ipairs(views) do
        if not view:IsShown() then view:Show() end
    end
    layer.shown = views
end

---Collects the paths that should show and releases the views of the others.
---@param layer WaypointMinimapLayer
local function _Collect(layer)
    layer.stale = true
    local paths = {}
    for path in pairs(QuestieWaypoints.paths) do
        local alpha = QuestieWaypoints.MinimapAlpha(path)
        if alpha then paths[#paths + 1] = {path = path, alpha = alpha} end
    end
    layer.paths = paths
    local current = {}
    for _, item in ipairs(paths) do current[item.path] = true end
    for path, entry in pairs(layer.entries) do
        if not current[path] then
            layer.entries[path] = nil
            if entry.view then layer.renderer:Release(entry.view) end
        end
    end
end

---Returns the path's view, drawn for the current projection; nil while no segment is in reach.
---@param layer WaypointMinimapLayer
---@param path WaypointPath
---@param alpha number
---@param projection WaypointMinimapProjection
---@return WaypointView?
local function _View(layer, path, alpha, projection)
    local entry = layer.entries[path]
    local style = {thickness = LINE_THICKNESS, color = path.color, alpha = alpha, frameLevel = layer.container:GetFrameLevel()}
    if entry and entry.projection == projection then
        if entry.view and entry.alpha ~= alpha then
            layer.renderer:Restyle(entry.view, style)
        end
        entry.alpha = alpha
        return entry.view
    end
    local segments = _Segments(path.world, projection)
    local view = entry and entry.view
    if segments[1] then
        view = layer.renderer:Draw(view, segments, style)
    elseif view then
        layer.renderer:Release(view)
        view = nil
    end
    layer.entries[path] = {view = view, projection = projection, alpha = alpha}
    return view
end

---Hides every view until the player has a position to draw around again.
---@param layer WaypointMinimapLayer
local function _HideAll(layer)
    _Publish(layer, {})
    layer.stale = true
    layer.playerX, layer.playerY = nil, nil
end

function Layer:Update()
    if self.dirty then
        self.dirty = false
        _Collect(self)
        if #self.paths == 0 then
            _HideAll(self)
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
        _HideAll(self)
        return
    end

    local halfWidth, halfHeight = self.minimap:GetWidth() / 2, self.minimap:GetHeight() / 2
    -- A minimap without a size yet has no extent to project into.
    if not (halfWidth > 0 and halfHeight > 0) then
        _HideAll(self)
        return
    end
    local projection = self.projection
    if not projection or projection.instanceId ~= instanceId or projection.radius ~= radius or projection.facing ~= facing
        or projection.halfWidth ~= halfWidth or projection.halfHeight ~= halfHeight
        or math.max(math.abs(x - projection.originX), math.abs(y - projection.originY)) > radius * REPROJECT_DRIFT then
        projection = {originX = x, originY = y, instanceId = instanceId, radius = radius, facing = facing,
            halfWidth = halfWidth, halfHeight = halfHeight}
        self.projection = projection
        self.stale = true
    end

    -- Walking within the drift only moves the container; the drawn segments already cover the view.
    if self.stale then
        self.stale = false
        local views = {}
        local reach = radius * CULL_MARGIN
        local originX, originY = projection.originX, projection.originY
        for _, item in ipairs(self.paths) do
            local path, bounds = item.path, item.path.worldBounds
            -- The bounds reject paths out of reach before any segment is projected.
            if path.instanceId == instanceId and bounds[1] <= originX + reach and bounds[3] >= originX - reach
                and bounds[2] <= originY + reach and bounds[4] >= originY - reach then
                views[#views + 1] = _View(self, path, item.alpha, projection)
            end
        end
        _Publish(self, views)
        self.playerX = nil
    end
    if x == self.playerX and y == self.playerY then return end
    self.playerX, self.playerY = x, y

    -- The origin projected around the player is the container's offset from the minimap's center.
    local scaleX, scaleY, sin, cos = _Transform(projection)
    local offsetX, offsetY = _ProjectPoint(projection.originX, projection.originY, x, y, scaleX, scaleY, sin, cos)
    self.container:ClearAllPoints()
    self.container:SetPoint("TOPLEFT", self.minimap, "CENTER", offsetX, -offsetY)
end

---Releases every drawing; views and textures stay pooled.
function Layer:Clear()
    self.entries, self.paths, self.shown, self.projection = {}, {}, {}, nil
    self.playerX, self.playerY = nil, nil
    self.dirty, self.stale = true, true
    self.renderer:Clear()
end

---Creates the layer over the minimap. Drawing starts on the first Invalidate.
---@param minimap Frame
---@return WaypointMinimapLayer
function WaypointMinimap.New(minimap)
    if maskHookError then Questie.Error("Waypoint minimap shape tracking failed:", maskHookError) end
    -- Clipping crops paths to the minimap's rectangle, which the masks then shape, and skips
    -- drawing what lies beyond it.
    local root = CreateFrame("Frame", nil, minimap)
    root:SetAllPoints(minimap)
    root:SetClipsChildren(true)
    root:Hide()
    -- The lowest level above the map itself keeps paths beneath Questie's minimap icons, the
    -- minimap's bezel and buttons, and other addons' pins wherever levels decide.
    root:SetFrameLevel(minimap:GetFrameLevel() + 1)
    local container = CreateFrame("Frame", nil, root)
    container:SetSize(1, 1)
    container:SetFrameLevel(root:GetFrameLevel())

    local mask = root:CreateMaskTexture()
    mask:SetAllPoints(minimap)
    _ApplyShapeMask(mask)
    shapeMask = mask
    -- Opaque except a soft hole in its middle; clamped edges keep everything around it opaque.
    local playerMask = root:CreateMaskTexture()
    playerMask:SetTexture(PLAYER_MASK, "CLAMP", "CLAMP")
    playerMask:SetPoint("CENTER", minimap, "CENTER")
    playerMask:SetSize(PLAYER_MASK_SIZE, PLAYER_MASK_SIZE)

    local layer = setmetatable({minimap = minimap, root = root, container = container,
        renderer = WaypointRenderer.New(container, {mask, playerMask}),
        entries = {}, paths = {}, shown = {}, dirty = true, stale = true}, Layer)
    -- A failure stops drawing until the next change rather than repeating every frame.
    root:SetScript("OnUpdate", function()
        local updated, err = pcall(layer.Update, layer)
        if not updated then
            root:Hide()
            Questie.Error("Waypoint minimap drawing failed:", err)
            local cleared, clearErr = pcall(layer.Clear, layer)
            if not cleared then Questie.Error("Waypoint minimap cleanup failed:", clearErr) end
        end
    end)
    return layer
end

---@type WaypointMinimapLayer?
local layer
local setupFailed = false

---Collects the paths again on the next update, after paths or their visibility changed. The
---minimap is optional: a failed setup is reported once and world map drawing continues.
function WaypointMinimap.Invalidate()
    if not layer then
        if setupFailed or not Minimap then return end
        local created, result = pcall(WaypointMinimap.New, Minimap)
        if not created then
            setupFailed = true
            Questie.Error("Waypoint minimap setup failed:", result)
            return
        end
        layer = result
    end
    layer.dirty = true
    layer.root:Show()
end
