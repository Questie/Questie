-- luacheck: read globals GetMinimapShape GetPlayerFacing GetCursorPosition issecretvalue
---@class WaypointMinimap
local WaypointMinimap = QuestieLoader:CreateModule("WaypointMinimap")

---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
---@type WaypointGeometry
local WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
---@type WaypointRenderer
local WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")
---@type WaypointHover
local WaypointHover = QuestieLoader:ImportModule("WaypointHover")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

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
---@field targets WaypointMinimapTarget[] The view's runs, for hovering.

---A drawn run of a route, in projected units with y down.
---@class WaypointMinimapTarget : WaypointHitTarget
---@field path WaypointPath The copy of the route that shows.

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

---Projects the parts of a path that come within reach of the projection's origin, in minimap
---units relative to it. Consecutive segments in reach form one run, so they join; so do a closed
---path's last and first segments.
---@param world WaypointWorldPoint[]
---@param projection WaypointMinimapProjection
---@return table[][] runs
local function _Runs(world, projection)
    local reach = projection.radius * CULL_MARGIN
    local originX, originY = projection.originX, projection.originY
    local scaleX, scaleY, sin, cos = _Transform(projection)
    local runs = {}
    local previous, run
    local startsAtFirst = false
    for i, point in ipairs(world) do
        if previous and math.max(previous.x, point.x) >= originX - reach and math.min(previous.x, point.x) <= originX + reach
            and math.max(previous.y, point.y) >= originY - reach and math.min(previous.y, point.y) <= originY + reach then
            if not run then
                local x, y = _ProjectPoint(previous.x, previous.y, originX, originY, scaleX, scaleY, sin, cos)
                run = {{x = x, y = y}}
                runs[#runs + 1] = run
                startsAtFirst = startsAtFirst or i == 2
            end
            local x, y = _ProjectPoint(point.x, point.y, originX, originY, scaleX, scaleY, sin, cos)
            run[#run + 1] = {x = x, y = y}
        else
            run = nil
        end
        previous = point
    end
    -- A closed path cut elsewhere would end where it starts and start again there, as two square
    -- ends. The last run continues into the first instead, so its start stays a corner.
    local first, last = world[1], world[#world]
    if run and startsAtFirst and #runs > 1 and first.x == last.x and first.y == last.y then
        local firstRun = runs[1]
        for i = 2, #firstRun do run[#run + 1] = firstRun[i] end
        runs[1], runs[#runs] = run, nil
    end
    return runs
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
---addons such as SexyMap set their shapes that way, and Forever's own skin on every Rotate Minimap
---change. A mask set before Questie loaded can only be read through GetMinimapShape, a community
---convention Blizzard does not define, which only names the round quarters. Any round quarter
---uses the round mask, so paths stop short in square corners rather than draw past a round edge.
---Without GetMinimapShape the minimap is round.
---@return string|number asset
---@return boolean isAtlas
function WaypointMinimap.ShapeMask()
    if hookedMaskAsset then return hookedMaskAsset, _IsAtlas(hookedMaskAsset) end
    local shape = type(GetMinimapShape) == "function" and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then return SQUARE_MASK, false end
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
---@field entries table<string, WaypointMinimapEntry> Drawn routes, including those out of view.
---@field paths {path: WaypointPath, alpha: number}[] One copy of each route that should show, wherever it is.
---@field dirty boolean The collected paths are stale.
---@field projection WaypointMinimapProjection?
---@field stale boolean The shown views must be chosen again: new paths or a new projection.
---@field shown WaypointView[] Views shown by the last publication.
---@field playerX number? Position at the last placement; nil forces the next one.
---@field playerY number?
---@field offsetX number? The container's offset from the minimap's center at the last placement, y down.
---@field offsetY number?
---@field targets WaypointMinimapTarget[] Runs of the shown views, for hovering.
---@field cursorX number? Cursor at the last hover check, in projected units; nil off the minimap.
---@field cursorY number?
---@field hoverStale boolean The targets changed since the last hover check.
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

---Collects the routes that should show and releases the views of the others. Icons sharing a
---patrol, such as an NPC's quests, draw it once, as its highlighted copy, or else its most visible one.
---@param layer WaypointMinimapLayer
local function _Collect(layer)
    layer.stale = true
    local routes = {}
    for path in pairs(QuestieWaypoints.paths) do
        local alpha = QuestieWaypoints.MinimapAlpha(path)
        if alpha then
            -- The highlighted copy first, then the most visible one: alpha is at most 1.
            local rank = alpha + (QuestieWaypoints.IsHighlighted(path) and 2 or 0)
            local best = routes[path.route]
            if not best or rank > best.rank then
                routes[path.route] = {path = path, alpha = alpha, rank = rank}
            end
        end
    end
    local paths = {}
    for _, item in pairs(routes) do paths[#paths + 1] = item end
    layer.paths = paths
    for route, entry in pairs(layer.entries) do
        if not routes[route] then
            layer.entries[route] = nil
            if entry.view then layer.renderer:Release(entry.view) end
        end
    end
end

---Returns the view of the path's route, drawn for the current projection; nil while no segment is in reach.
---@param layer WaypointMinimapLayer
---@param path WaypointPath
---@param alpha number
---@param projection WaypointMinimapProjection
---@return WaypointView?
local function _View(layer, path, alpha, projection)
    local entry = layer.entries[path.route]
    -- Line width is in minimap units.
    local style = {thickness = Questie.db.profile.waypointWidth, color = QuestieWaypoints.Color(path), alpha = alpha,
        frameLevel = layer.container:GetFrameLevel()}
    if entry and entry.projection == projection then
        -- Restyling redraws only what changed: the color of a highlight, or of another copy of the
        -- route such as an NPC hostile in one quest, or the width and colors after a setting changed.
        if entry.view then layer.renderer:Restyle(entry.view, style) end
        return entry.view
    end
    local runs = _Runs(path.world, projection)
    local view = entry and entry.view
    if runs[1] then
        view = layer.renderer:Draw(view, runs, style)
    elseif view then
        layer.renderer:Release(view)
        view = nil
    end
    local targets = {}
    for i, run in ipairs(runs) do
        targets[i] = {points = run, bounds = WaypointGeometry.Bounds(run), path = path}
    end
    layer.entries[path.route] = {view = view, projection = projection, targets = targets}
    return view
end

-- Hover
-- Paths take no mouse input. They count as hovered only over the bare minimap, so Questie's icons,
-- the minimap's buttons and other addons' pins on top win.

---Cursor in projected units, x right and y down from the projection's origin; nil off the bare
---minimap, outside its shape, or while restricted.
---@param layer WaypointMinimapLayer
---@return number?, number?
local function _ReadCursor(layer)
    local minimap = layer.minimap
    if not minimap:IsMouseOver() or QuestieCompat.GetMouseFocus() ~= minimap then return nil, nil end
    local cursorX, cursorY = GetCursorPosition()
    local centerX, centerY = minimap:GetCenter()
    if _IsSecret(cursorX, cursorY, centerX, centerY) or not (cursorX and cursorY and centerX and centerY) then return nil, nil end
    local scale = minimap:GetEffectiveScale()
    local dx, dy = cursorX / scale - centerX, centerY - cursorY / scale
    -- Paths are masked to the minimap's shape. Anything but a square one counts as round, so a
    -- custom shape never hovers paths its mask hides.
    local projection = layer.projection
    if (dx / projection.halfWidth) ^ 2 + (dy / projection.halfHeight) ^ 2 > 1 and WaypointMinimap.ShapeMask() ~= SQUARE_MASK then
        return nil, nil
    end
    return dx - layer.offsetX, dy - layer.offsetY
end

---Rechecks the hovered path, only when the cursor moved against the drawn paths, by moving or by
---the player walking or turning, or when the paths changed.
---@param layer WaypointMinimapLayer
local function _UpdateHover(layer)
    local x, y = _ReadCursor(layer)
    if x == layer.cursorX and y == layer.cursorY and not layer.hoverStale then return end
    layer.cursorX, layer.cursorY, layer.hoverStale = x, y, false
    local nearest = x and WaypointGeometry.Nearest(layer.targets, x, y, WaypointHover.Radius())
    local path = nearest and nearest.path
    WaypointHover.Set("minimap", path, path and path.owner.minimapTwin)
end

---Ends the minimap's hover; the next check starts afresh.
---@param layer WaypointMinimapLayer
local function _EndHover(layer)
    layer.cursorX, layer.cursorY = nil, nil
    WaypointHover.Set("minimap", nil)
end

---Hides every view until the player has a position to draw around again.
---@param layer WaypointMinimapLayer
local function _HideAll(layer)
    _Publish(layer, {})
    layer.targets = {}
    _EndHover(layer)
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

    -- Walking within the drift only moves the container; the drawn runs already cover the view.
    if self.stale then
        self.stale = false
        local views, targets = {}, {}
        local reach = radius * CULL_MARGIN
        local originX, originY = projection.originX, projection.originY
        for _, item in ipairs(self.paths) do
            local path, bounds = item.path, item.path.worldBounds
            -- The bounds reject paths out of reach before any segment is projected.
            if path.instanceId == instanceId and bounds[1] <= originX + reach and bounds[3] >= originX - reach
                and bounds[2] <= originY + reach and bounds[4] >= originY - reach then
                local view = _View(self, path, item.alpha, projection)
                if view then
                    views[#views + 1] = view
                    -- The route's runs, now hovered as the copy that shows.
                    for _, target in ipairs(self.entries[path.route].targets) do
                        target.path = path
                        targets[#targets + 1] = target
                    end
                end
            end
        end
        _Publish(self, views)
        self.targets, self.hoverStale = targets, true
        self.playerX = nil
    end
    if x ~= self.playerX or y ~= self.playerY then
        self.playerX, self.playerY = x, y
        -- The origin projected around the player is the container's offset from the minimap's center.
        local scaleX, scaleY, sin, cos = _Transform(projection)
        self.offsetX, self.offsetY = _ProjectPoint(projection.originX, projection.originY, x, y, scaleX, scaleY, sin, cos)
        self.container:ClearAllPoints()
        self.container:SetPoint("TOPLEFT", self.minimap, "CENTER", self.offsetX, -self.offsetY)
    end
    _UpdateHover(self)
end

---Releases every drawing; views and textures stay pooled.
function Layer:Clear()
    self.entries, self.paths, self.shown, self.targets, self.projection = {}, {}, {}, {}, nil
    self.playerX, self.playerY = nil, nil
    _EndHover(self)
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
        entries = {}, paths = {}, shown = {}, targets = {}, dirty = true, stale = true}, Layer)
    -- A failure stops drawing until the next change rather than repeating every frame.
    root:SetScript("OnUpdate", function()
        local updated, err = pcall(layer.Update, layer)
        if not updated then
            Questie.Error("Waypoint minimap drawing failed:", err)
            local cleared, clearErr = pcall(layer.Clear, layer)
            if not cleared then Questie.Error("Waypoint minimap cleanup failed:", clearErr) end
            -- Last: ending the hover in Clear changes the highlight, which shows the root again.
            root:Hide()
        end
    end)
    -- Hiding the minimap, such as with its keybinding, stops the updates that would end a hover.
    root:SetScript("OnHide", function() _EndHover(layer) end)
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
