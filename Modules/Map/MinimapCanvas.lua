-- luacheck: read globals GetMinimapShape GetPlayerFacing GetCursorPosition issecretvalue
---One masked drawing surface over the minimap, shared by Questie's minimap layers: objective areas
---and patrol paths. Each frame it samples the player and the minimap view once for every layer,
---projects world yards the way HereBeDragons-Pins places minimap icons, and moves each layer's
---container under the player. It offers the cursor to the layers top down, as WorldMapLayers does on
---the world map: a layer drawn above another wins the cursor over it, and everything with mouse focus
---above the minimap wins over every layer. Nothing here takes mouse input or calls protected API.
---@class MinimapCanvas
local MinimapCanvas = QuestieLoader:CreateModule("MinimapCanvas")

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

---@alias MinimapLayerName "areas"|"paths"

-- The layers, bottom to top. Each layer's container sits one level above the one before it, so paths
-- cross areas, and the cursor is offered top down in the same order: draw order and hover order both
-- come from this table, as in WorldMapLayers. A new drawing feature adds one name. Questie's minimap
-- icons stay far above at 2016+ (QuestieMap.utils.SetDrawOrder).
---@type MinimapLayerName[]
local LAYER_ORDER = {"areas", "paths"}
-- Everything visible lies within √2 view radii of the player: a square minimap's corners. Drawings
-- within REACH radii of the origin cover that view while the player stays within DRIFT radii of it
-- (√2 + 0.5 < 2); past that, everything is projected again.
local REACH, DRIFT = 2, 0.5
-- Drawings leave a soft hole over the player arrow so they never hide it.
local PLAYER_MASK = QuestieLib.AddonPath .. "Icons\\minimap-player-mask.tga"
local PLAYER_MASK_SIZE = 38
local ROUND_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local SQUARE_MASK = "Interface\\BUTTONS\\WHITE8X8"
-- Forever's own round minimap mask (Blizzard_Minimap/Camelot/Skin.lua).
local FOREVER_MASK_ATLAS = "ui-hud-minimap-frame-generic-mask"

---Where world yards show on the minimap: x right and y down, in the minimap's own units. Read only.
---@class MinimapProjection
---@field originX number World yards drawings are placed relative to.
---@field originY number
---@field instanceId number
---@field radius number Yards from the minimap's center to its edge (HBDPins:GetMinimapView).
---@field reach number Yards around the origin that drawings must cover until the next projection.
---@field halfWidth number Minimap half-extents in its own units.
---@field halfHeight number
---@field facing number? Player facing in radians while the minimap rotates; nil keeps north up.
---@field scaleX number Derived: minimap units per yard, and the facing's rotation.
---@field scaleY number
---@field sin number
---@field cos number

---One kind of drawing on the canvas, at its place in LAYER_ORDER. The canvas calls these only from
---its own update, as plain functions. An error in one is reported once, the layer is cleared, and it
---stays off until its next Invalidate, while the other layers keep drawing and hovering.
---@class MinimapLayer
---@field Collect fun(): boolean After an Invalidate: gathers what should show, wherever it lies, and releases drawings of what no longer should. True while anything should show. Draws nothing.
---@field Draw fun(projection: MinimapProjection?) Shows what lies within projection.reach of its origin and hides the rest. nil hides everything until the next call with a projection.
---@field Clear fun() Releases every drawing and ends any hover.
---@field Hover? fun(x: number?, y: number?): boolean Hovers what lies under the cursor and returns whether anything does: the layer claims the cursor, and the layers beneath get nil. x and y are projected units relative to the projection origin. nil ends the layer's hover; it comes once, when the layer stops getting the cursor. A layer without Hover never claims.

---@class MinimapLayerState
---@field name MinimapLayerName
---@field layer MinimapLayer
---@field container Frame
---@field dirty boolean Invalidated: Collect runs on the next update.
---@field active boolean Its last Collect found something to show.
---@field drawn boolean It drew with the current projection since it last collected.
---@field offered boolean It had the cursor at the last offer, so it gets nil once when it stops having it.
---@field reported boolean Its first failure was reported; later ones stay quiet.

-- Projection

---Projects world yards into the projection's minimap units: HereBeDragons-Pins' minimap icon
---arithmetic, so drawings and icons line up. The world offset turns with the facing, then scales by
---the view radius.
---@param projection MinimapProjection
---@param x number
---@param y number
---@return number x
---@return number y
function MinimapCanvas.Project(projection, x, y)
    local dx, dy = projection.originX - x, projection.originY - y
    return (dx * projection.cos - dy * projection.sin) * projection.scaleX,
        (dx * projection.sin + dy * projection.cos) * projection.scaleY
end

---The world yards a point in the projection's minimap units shows, such as the cursor: Project's inverse.
---@param projection MinimapProjection
---@param x number
---@param y number
---@return number x
---@return number y
function MinimapCanvas.Unproject(projection, x, y)
    local u, v = x / projection.scaleX, y / projection.scaleY
    return projection.originX - (u * projection.cos + v * projection.sin),
        projection.originY - (v * projection.cos - u * projection.sin)
end

---Whether world bounds on an instance come within the projection's reach, so their drawing can show
---before the next projection.
---@param projection MinimapProjection
---@param instanceId number
---@param bounds number[] {minX, minY, maxX, maxY} in world yards.
---@return boolean
function MinimapCanvas.InReach(projection, instanceId, bounds)
    local reach, originX, originY = projection.reach, projection.originX, projection.originY
    return instanceId == projection.instanceId and bounds[1] <= originX + reach and bounds[3] >= originX - reach
        and bounds[2] <= originY + reach and bounds[4] >= originY - reach
end

---@return MinimapProjection
local function _NewProjection(x, y, instanceId, radius, facing, halfWidth, halfHeight)
    local angle = facing or 0
    return {originX = x, originY = y, instanceId = instanceId, radius = radius, reach = radius * REACH, facing = facing,
        halfWidth = halfWidth, halfHeight = halfHeight, scaleX = halfWidth / radius, scaleY = halfHeight / radius,
        sin = math.sin(angle), cos = math.cos(angle)}
end

-- Whether any of the values is secret: hidden from addons while restricted, on clients with secret values.
local function _IsSecret(...)
    if not issecretvalue then return false end
    for i = 1, select("#", ...) do
        if issecretvalue((select(i, ...))) then return true end
    end
    return false
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

---The minimap's shape mask. An asset seen through Minimap:SetMaskTexture is exact; minimap addons
---such as SexyMap set their shapes that way, and Forever's own skin on every Rotate Minimap change. A
---mask set before Questie loaded can only be read through GetMinimapShape, a community convention
---Blizzard does not define, which only names the round quarters. Any round quarter uses the round
---mask, so drawings stop short in square corners rather than draw past a round edge. Without
---GetMinimapShape the minimap is round.
---@return string|number asset
---@return boolean isAtlas
function MinimapCanvas.ShapeMask()
    if hookedMaskAsset then return hookedMaskAsset, _IsAtlas(hookedMaskAsset) end
    local shape = type(GetMinimapShape) == "function" and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then return SQUARE_MASK, false end
    if _IsAtlas(FOREVER_MASK_ATLAS) then return FOREVER_MASK_ATLAS, true end
    return ROUND_MASK, false
end

---Whether the minimap is known to be square: by its mask, or by GetMinimapShape, also when a minimap
---addon sets its own square texture.
---@return boolean
local function _IsSquare()
    return MinimapCanvas.ShapeMask() == SQUARE_MASK or (type(GetMinimapShape) == "function" and GetMinimapShape() == "SQUARE")
end

-- Clamping to black keeps everything outside the minimap's rectangle masked out.
---@param mask MaskTexture
local function _ApplyShapeMask(mask)
    local asset, isAtlas = MinimapCanvas.ShapeMask()
    if isAtlas then
        mask:SetAtlas(asset, false, nil, nil, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    else
        mask:SetTexture(asset, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end
end

-- Installed at load so minimap addons loading after Questie are seen. A post-hook only observes the
-- call; Blizzard's method runs unchanged. Neither installing nor running it may break the caller or
-- this file, so failures fall back to GetMinimapShape and are reported once the canvas exists.
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

-- Canvas
-- Drawings are projected relative to a fixed origin into each layer's container. Walking only moves
-- the containers; everything is projected again when the zoom, minimap size, instance or facing of a
-- rotating minimap changes, or once the player drifted DRIFT radii from the origin.

---@type Frame?
local root
---@type Frame
local minimap
---@type MaskTexture
local playerMask
---@type table<MinimapLayerName, MinimapLayerState>
local states = {}
---@type MinimapProjection?
local projection
-- Position at the last placement; nil forces the next one.
local playerX, playerY
-- The containers' offset from the minimap's center at the last placement, y down.
local offsetX, offsetY = 0, 0
-- Cursor at the last offer, in projected units; nil off the bare minimap.
local cursorX, cursorY
-- A layer drew or stopped since the last offer: what lies under a still cursor may have changed.
local offerStale = false
local canvasReported = false

---Calls one of a layer's functions. An error is reported once per layer; the layer is cleared and
---stays off until its next Invalidate.
---@param state MinimapLayerState
---@param method "Collect"|"Draw"|"Hover"
---@return boolean ok
---@return any result
local function _Call(state, method, ...)
    local ok, result = pcall(state.layer[method], ...)
    if ok then return true, result end
    if not state.reported then
        state.reported = true
        Questie.Error("Minimap " .. state.name .. " drawing failed:", result)
    end
    local cleared, clearErr = pcall(state.layer.Clear)
    if not cleared then Questie.Error("Minimap " .. state.name .. " cleanup failed:", clearErr) end
    -- Last: clearing may invalidate the layer, as ending a hover changes a highlight.
    state.dirty, state.active, state.drawn, state.offered = false, false, false, false
    offerStale = true
    return false
end

---Offers the cursor top down: the first layer that claims it keeps it, and each layer beneath that
---last had it gets nil once. A layer that is off, or has no Hover, takes no part.
---@param x number?
---@param y number?
local function _Offer(x, y)
    local claimed = false
    for i = #LAYER_ORDER, 1, -1 do
        local state = states[LAYER_ORDER[i]]
        if state and state.active and state.layer.Hover then
            if x and not claimed then
                state.offered = true
                local ok, hovered = _Call(state, "Hover", x, y)
                -- A failing layer was cleared, which ended its hover: the layers beneath get the cursor.
                claimed = ok and hovered == true
            elseif state.offered then
                state.offered = false
                _Call(state, "Hover", nil, nil)
            end
        end
    end
end

---Ends a layer that has nothing to show any more.
---@param state MinimapLayerState
local function _Stop(state)
    state.active, state.drawn = false, false
    if state.offered then
        state.offered = false
        if not _Call(state, "Hover", nil, nil) then return end
    end
    _Call(state, "Draw", nil)
    offerStale = true
end

-- Hover
-- Drawings take no mouse input. They count as hovered only over the bare minimap, so Questie's icons,
-- the minimap's buttons and other addons' pins on top win.

---Cursor in projected units, x right and y down from the projection's origin; nil in the gamepad UI,
---off the bare minimap, outside its shape, or while restricted.
---@return number?, number?
local function _ReadCursor()
    -- The gamepad cursor is not the mouse's, and the mouse cursor is hidden while it points.
    if QuestieCompat.IsGamepadUIEnabled() then return nil, nil end
    local over = minimap:IsMouseOver()
    if _IsSecret(over) or not over or QuestieCompat.GetMouseFocus() ~= minimap then return nil, nil end
    local x, y = GetCursorPosition()
    local centerX, centerY = minimap:GetCenter()
    local scale = minimap:GetEffectiveScale()
    if _IsSecret(x, y, centerX, centerY, scale) or not (x and y and centerX and centerY and scale) then return nil, nil end
    local dx, dy = x / scale - centerX, centerY - y / scale
    -- Drawings are masked to the minimap's shape. Anything but a minimap known to be square counts as
    -- round, so a custom shape never hovers what its mask hides.
    if (dx / projection.halfWidth) ^ 2 + (dy / projection.halfHeight) ^ 2 > 1 and not _IsSquare() then
        return nil, nil
    end
    return dx - offsetX, dy - offsetY
end

-- Update
-- Each frame: collect the invalidated layers, sample the player and the view once, project again
-- when needed, draw the layers that must, move the containers under the player, then offer the cursor.

---No position to draw around, as inside instances or while values are restricted: every hover ends
---and every layer hides its drawings until the position returns.
local function _Lose()
    _Offer(nil)
    cursorX, cursorY = nil, nil
    if not projection then return end
    projection, playerX, playerY = nil, nil, nil
    for _, name in ipairs(LAYER_ORDER) do
        local state = states[name]
        if state and state.active then
            state.drawn = false
            _Call(state, "Draw", nil)
        end
    end
end

local function _Update()
    local anyActive, hovering = false, false
    for _, name in ipairs(LAYER_ORDER) do
        local state = states[name]
        if state then
            if state.dirty then
                state.dirty = false
                local ok, found = _Call(state, "Collect")
                if ok and found then
                    state.active, state.drawn = true, false
                elseif ok and state.active then
                    _Stop(state)
                end
            end
            anyActive = anyActive or state.active
            hovering = hovering or (state.active and state.layer.Hover ~= nil)
        end
    end
    -- Invalidate shows the canvas again; until then it costs nothing per frame.
    if not anyActive then
        root:Hide()
        return
    end

    local x, y, instanceId = HBD:GetPlayerWorldPosition()
    local radius, rotating = HBDPins:GetMinimapView()
    local facing = rotating and GetPlayerFacing() or nil
    local width, height = minimap:GetWidth(), minimap:GetHeight()
    if _IsSecret(x, y, radius, facing, width, height) or not (x and y and radius and width and height)
        or radius <= 0 or (rotating and not facing) or not (width > 0 and height > 0) then
        _Lose()
        return
    end
    local halfWidth, halfHeight = width / 2, height / 2

    if not projection or projection.instanceId ~= instanceId or projection.radius ~= radius or projection.facing ~= facing
        or projection.halfWidth ~= halfWidth or projection.halfHeight ~= halfHeight
        or math.max(math.abs(x - projection.originX), math.abs(y - projection.originY)) > radius * DRIFT then
        projection, playerX, playerY = _NewProjection(x, y, instanceId, radius, facing, halfWidth, halfHeight), nil, nil
        for _, state in pairs(states) do state.drawn = false end
    end

    -- Walking within the drift draws nothing: what is drawn already covers the view.
    for _, name in ipairs(LAYER_ORDER) do
        local state = states[name]
        if state and state.active and not state.drawn then
            state.drawn = true
            _Call(state, "Draw", projection)
            offerStale = true
        end
    end

    -- Move the containers under the player: the player's projected position is their offset's opposite.
    if x ~= playerX or y ~= playerY then
        playerX, playerY = x, y
        local px, py = MinimapCanvas.Project(projection, x, y)
        offsetX, offsetY = -px, -py
        for _, state in pairs(states) do
            state.container:ClearAllPoints()
            state.container:SetPoint("TOPLEFT", minimap, "CENTER", offsetX, -offsetY)
        end
    end

    -- The cursor moves against the drawings when it moves itself, when the player walks or turns, and
    -- when a layer draws again or stops.
    if hovering then
        local cx, cy = _ReadCursor()
        if cx ~= cursorX or cy ~= cursorY or offerStale then
            cursorX, cursorY, offerStale = cx, cy, false
            _Offer(cx, cy)
        end
    end
end

local function _OnUpdate()
    local ok, err = pcall(_Update)
    if ok then return end
    if not canvasReported then
        canvasReported = true
        Questie.Error("Minimap drawing failed:", err)
    end
    for _, state in pairs(states) do
        pcall(state.layer.Clear)
        state.dirty, state.active, state.drawn, state.offered = false, false, false, false
    end
    projection, playerX, playerY, cursorX, cursorY = nil, nil, nil, nil, nil
    -- Last: clearing may invalidate a layer, which shows the canvas again.
    root:Hide()
end

-- Hiding the minimap, such as with its keybinding, stops the updates that would end a hover. The
-- drawings stay: the hidden minimap hides them.
local function _OnHide()
    _Offer(nil)
    cursorX, cursorY, offerStale = nil, nil, true
end

local function _CreateRoot()
    if maskHookError then Questie.Error("Minimap shape tracking failed:", maskHookError) end
    minimap = Minimap
    -- Clipping crops drawings to the minimap's rectangle, which the masks then shape, and skips
    -- drawing what lies beyond it.
    local frame = CreateFrame("Frame", nil, minimap)
    frame:SetAllPoints(minimap)
    frame:SetClipsChildren(true)
    frame:Hide()
    -- The lowest level above the map itself; each layer's container sits at its place above it.
    frame:SetFrameLevel(minimap:GetFrameLevel() + 1)
    local mask = frame:CreateMaskTexture()
    mask:SetAllPoints(minimap)
    _ApplyShapeMask(mask)
    -- Opaque except a soft hole in its middle; clamped edges keep everything around it opaque.
    playerMask = frame:CreateMaskTexture()
    playerMask:SetTexture(PLAYER_MASK, "CLAMP", "CLAMP")
    playerMask:SetPoint("CENTER", minimap, "CENTER")
    playerMask:SetSize(PLAYER_MASK_SIZE, PLAYER_MASK_SIZE)
    frame:SetScript("OnUpdate", _OnUpdate)
    frame:SetScript("OnHide", _OnHide)
    shapeMask, root = mask, frame
end

---@param name MinimapLayerName
---@return number index Its place in LAYER_ORDER, from 1 at the bottom.
local function _Index(name)
    for i, ordered in ipairs(LAYER_ORDER) do
        if ordered == name then return i end
    end
    error("MinimapCanvas: unknown layer " .. tostring(name))
end

---Adds a layer, creating the canvas over the minimap on first use. Drawing starts on its first
---Invalidate. Errors when the canvas cannot be created; the minimap is optional, so callers pcall.
---@param name MinimapLayerName
---@param layer MinimapLayer
---@return Frame container The layer's renderer canvas: it moves with the player, so projected units are TOPLEFT offsets. Its frame level comes from LAYER_ORDER, as the hover order does, so it draws above the layers beneath it.
---@return MaskTexture[] masks The minimap's shape and the hole over the player arrow. Add both to every texture.
function MinimapCanvas.AddLayer(name, layer)
    local index = _Index(name)
    if not root then _CreateRoot() end
    local container = CreateFrame("Frame", nil, root)
    container:SetSize(1, 1)
    container:SetFrameLevel(root:GetFrameLevel() + index - 1)
    container:SetPoint("TOPLEFT", minimap, "CENTER", offsetX, -offsetY)
    states[name] = {name = name, layer = layer, container = container, dirty = false, active = false, drawn = false,
        offered = false, reported = false}
    return container, {shapeMask, playerMask}
end

---The layer's Collect runs on the next update, after its data, visibility or settings changed. A layer
---that failed resumes. What it then draws is offered the cursor again.
---@param name MinimapLayerName
function MinimapCanvas.Invalidate(name)
    _Index(name)
    local state = states[name]
    if not state then return end
    state.dirty = true
    root:Show()
end
