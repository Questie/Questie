-- luacheck: globals DrawLine UPPER_LEFT_VERTEX LOWER_LEFT_VERTEX UPPER_RIGHT_VERTEX LOWER_RIGHT_VERTEX
---Draws patrol paths as outlined lines onto a canvas: the world map's, or the minimap layer's
---container. Each path is one view frame with one pooled texture per segment, plus two fills at
---each sharp turn and a cap at each sharp turn, turn back and open end.
---@class WaypointRenderer
local WaypointRenderer = QuestieLoader:CreateModule("WaypointRenderer")

---@type WaypointGeometry
local WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---How a drawn path looks. Units are the canvas's own, before its scale.
---@class WaypointStyle
---@field thickness number Line width; a quarter of it is black outline on each side, with a soft fade beyond.
---@field color number[] {r, g, b, a}, tinting only the line's core.
---@field alpha number? Whole-path opacity, such as an icon's fade. Default 1.
---@field frameLevel number
---@field hoverRadius number? Debugging: draws the hover area beneath the line.

---One drawn path. Owned by its renderer; show and hide it like any frame. The waypointThickness,
---Radius, Color and FrameLevel fields hold the style it was last drawn with, so Restyle redraws only
---what changed; nil redraws that part.
---@class WaypointView : Frame
---@field lines Texture[] One per drawn segment.
---@field fills Texture[] Two per sharp turn: the triangles completing its segments at the turn.
---@field caps Texture[] One per sharp turn, turn back or open end: the round outside.
---@field bands Texture[] Debug hover area: one per segment.
---@field dots Texture[] Debug hover area: one per point.
---@field waypointRuns table[][] Polylines in canvas units with y down, each at least two points.
---@field waypointThickness number?
---@field waypointRadius number?
---@field waypointColor number[]?
---@field waypointFrameLevel number?

---@class WaypointCanvasRenderer
---@field canvas Frame
---@field maskTextures MaskTexture[]
---@field owned table<WaypointView, true>
---@field freeViews WaypointView[]
---@field free table<string, Texture[]> Pooled textures by kind.
local Renderer = {}
Renderer.__index = Renderer

-- Every renderer, so a new smoothing setting can redraw what they show.
---@type table<WaypointCanvasRenderer, true>
local renderers = setmetatable({}, {__mode = "k"})

-- One texture outlines a line. Across it, this 16x16 image has 12 rows of line, a quarter black on
-- each side of a white core, so the vertex color tints only the core. Two rows on each side fade
-- the outline out to transparent, so its outer edges stay smooth as lines move by fractions of a
-- pixel. Each segment stretches it over a quad whose long edges run parallel to the segment, so the
-- rows follow both edges and meet at mitered joins.
local LINE_TEXTURE = QuestieLib.AddonPath .. "Icons\\waypoints\\waypoint-line-aa.png"
-- Quads are wider than the line by the fade, so the line keeps its thickness.
local QUAD_SCALE = 16 / 12
-- A fill's start corners take the line texture's left and right edges, and its end corners, both
-- at the turn's point, the center row between them. ulX, ulY, llX, llY, urX, urY, lrX, lrY.
local FILL_TEX_COORDS = {0, 0, 0, 1, 1, 0.5, 1, 0.5}
-- The line's rows turned into rings: this 32x32 image's disc has the line's profile from its center,
-- at the line's texel density, and is transparent black around it.
local CAP_TEXTURE = QuestieLib.AddonPath .. "Icons\\waypoints\\waypoint-cap-aa.png"
-- The disc's radius, 8 texels, as a fraction of the image. It matches a quad's half width.
local CAP_RADIUS = 8 / 32
-- The line texture has about as many rows as a line has pixels, so bilinear filtering blends rows
-- smoothly without mipmaps. Nearest-neighbor picks one row per pixel, and the bands flicker as
-- lines move.
local FILTER = "LINEAR"
-- Smoothed lines are then trimmed of points within this many half line widths of the line kept
-- around them: under a fifth of a unit on the default 3-unit line, too little to see. Zoomed out,
-- most curves are that small.
WaypointRenderer.TRIMMING = 1 / 8

-- Debug hover area
local WHITE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"
local CIRCLE_TEXTURE = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local DEBUG_COLOR = {0.2, 0.8, 1, 0.25}

-- Texture settings by kind. Lines, fills and caps draw above the debug hover area of their own path.
-- Debug bands are DrawLine strips, whose texture coordinates run past the image; clamping to black
-- keeps the rest of their box clear. Fills and caps set their texture coordinates on every draw,
-- and SetTexture keeps them, so they pool apart from lines, which keep the whole image.
local KINDS = {
    lines = {asset = LINE_TEXTURE, layer = "ARTWORK", wrap = "CLAMP"},
    fills = {asset = LINE_TEXTURE, layer = "ARTWORK", wrap = "CLAMP"},
    caps = {asset = CAP_TEXTURE, layer = "ARTWORK", wrap = "CLAMP"},
    bands = {asset = WHITE_TEXTURE, layer = "BACKGROUND", wrap = "CLAMPTOBLACKADDITIVE"},
    dots = {asset = CIRCLE_TEXTURE, layer = "BACKGROUND", wrap = "CLAMP"},
}
-- The kinds drawing the line, which the style's color tints.
local LINE_KINDS = {"lines", "fills", "caps"}

---Creates a renderer drawing onto canvas. Views take no mouse input.
---@param canvas Frame
---@param maskTextures MaskTexture[]? Applied once to every texture, for canvases that do not clip, such as the minimap.
---@return WaypointCanvasRenderer
function WaypointRenderer.New(canvas, maskTextures)
    local free = {}
    for kind in pairs(KINDS) do free[kind] = {} end
    local renderer = setmetatable({canvas = canvas, maskTextures = maskTextures or {}, owned = {}, freeViews = {},
        free = free}, Renderer)
    renderers[renderer] = true
    return renderer
end

-- Texture pool

---@param self WaypointCanvasRenderer
---@param view WaypointView
---@param kind string
---@param index number
---@return Texture
---@return boolean acquired The texture is new to the view and has no color yet.
local function _Acquire(self, view, kind, index)
    local owned = view[kind]
    local texture = owned[index]
    if texture then return texture, false end
    texture = table.remove(self.free[kind])
    if texture then
        texture:SetParent(view)
    else
        local settings = KINDS[kind]
        texture = view:CreateTexture(nil, settings.layer)
        -- Pooled textures never leave this renderer, so they keep these settings and masks.
        texture:SetSnapToPixelGrid(false)
        texture:SetTexelSnappingBias(0)
        texture:SetTexture(settings.asset, settings.wrap, settings.wrap, FILTER)
        for _, mask in ipairs(self.maskTextures) do texture:AddMaskTexture(mask) end
    end
    owned[index] = texture
    texture:Show()
    return texture, true
end

---Releases a view's textures of one kind beyond count.
---@param self WaypointCanvasRenderer
---@param view WaypointView
---@param kind string
---@param count number
local function _ReleaseBeyond(self, view, kind, count)
    local owned, free = view[kind], self.free[kind]
    for index = #owned, count + 1, -1 do
        local texture = owned[index]
        texture:Hide()
        texture:ClearAllPoints()
        free[#free + 1], owned[index] = texture, nil
    end
end

-- Drawing

---Stretches a texture over an outline quad: its box spans the corners, and each of its vertices
---moves from the box's corner onto the quad's. The texture's top edge runs along the quad's left
---side and its left edge across the segment's start. Quads are canvas units with y down; anchors
---and vertex offsets have y up.
---@param texture Texture
---@param view WaypointView
---@param quad number[] Start left, start right, end left, end right corners as x, y pairs.
local function _DrawQuad(texture, view, quad)
    local startLeftX, startLeftY, startRightX, startRightY = quad[1], quad[2], quad[3], quad[4]
    local endLeftX, endLeftY, endRightX, endRightY = quad[5], quad[6], quad[7], quad[8]
    local minX = math.min(startLeftX, startRightX, endLeftX, endRightX)
    local maxX = math.max(startLeftX, startRightX, endLeftX, endRightX)
    local minY = math.min(startLeftY, startRightY, endLeftY, endRightY)
    local maxY = math.max(startLeftY, startRightY, endLeftY, endRightY)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", view, "TOPLEFT", minX, -minY)
    texture:SetPoint("BOTTOMRIGHT", view, "TOPLEFT", maxX, -maxY)
    texture:SetVertexOffset(UPPER_LEFT_VERTEX, startLeftX - minX, minY - startLeftY)
    texture:SetVertexOffset(UPPER_RIGHT_VERTEX, endLeftX - maxX, minY - endLeftY)
    texture:SetVertexOffset(LOWER_LEFT_VERTEX, startRightX - minX, maxY - startRightY)
    texture:SetVertexOffset(LOWER_RIGHT_VERTEX, endRightX - maxX, maxY - endRightY)
end

---Maps a cap's disc onto its kite: the kite's first corner is the disc's center, and the image
---scales so the disc's radius spans halfWidth.
---@param texture Texture
---@param cap number[]
---@param halfWidth number
local function _SetCapTexCoord(texture, cap, halfWidth)
    local scale = CAP_RADIUS / halfWidth
    local centerX, centerY = cap[1], cap[2]
    texture:SetTexCoord(0.5, 0.5,
        0.5 + (cap[3] - centerX) * scale, 0.5 + (cap[4] - centerY) * scale,
        0.5 + (cap[5] - centerX) * scale, 0.5 + (cap[6] - centerY) * scale,
        0.5 + (cap[7] - centerX) * scale, 0.5 + (cap[8] - centerY) * scale)
end

---Draws quads with textures of one kind, after the count already drawn.
---@param self WaypointCanvasRenderer
---@param view WaypointView
---@param kind string
---@param quads number[][]
---@param count number
---@param halfWidth number
---@return number count
---@return boolean acquired Some texture is new to the view and needs its color.
local function _DrawKind(self, view, kind, quads, count, halfWidth)
    local acquired = false
    for _, quad in ipairs(quads) do
        count = count + 1
        local texture, new = _Acquire(self, view, kind, count)
        acquired = acquired or new
        _DrawQuad(texture, view, quad)
        if kind == "fills" then
            texture:SetTexCoord(unpack(FILL_TEX_COORDS))
        elseif kind == "caps" then
            _SetCapTexCoord(texture, quad, halfWidth)
        end
    end
    return count, acquired
end

---@param self WaypointCanvasRenderer
---@param view WaypointView
---@return boolean acquired Some texture is new to the view and needs its color.
local function _DrawLines(self, view)
    local halfWidth = view.waypointThickness / 2
    local quadHalfWidth = halfWidth * QUAD_SCALE
    -- Rounded corners pass a patrol's points at most waypointSmoothing half line widths away, and
    -- trimming adds TRIMMING more. Up to a setting of 0.875, the default 0.75 included, the true path
    -- stays under the line at every zoom, and up to about 1.2 under it or its soft edge.
    local smoothing = Questie.db.profile.waypointSmoothing * halfWidth
    local acquired, lines, fills, caps = false, 0, 0, 0
    for _, run in ipairs(view.waypointRuns) do
        -- Curves are fitted to the quads, fade included, so no two of their pieces overlap.
        local smoothed = WaypointGeometry.Smooth(run, smoothing, quadHalfWidth)
        local points = WaypointGeometry.Trim(smoothed, WaypointRenderer.TRIMMING * halfWidth)
        local lineQuads, fillQuads, capQuads = WaypointGeometry.Quads(points, quadHalfWidth)
        local newLines, newFills, newCaps
        lines, newLines = _DrawKind(self, view, "lines", lineQuads, lines, quadHalfWidth)
        fills, newFills = _DrawKind(self, view, "fills", fillQuads, fills, quadHalfWidth)
        caps, newCaps = _DrawKind(self, view, "caps", capQuads, caps, quadHalfWidth)
        acquired = acquired or newLines or newFills or newCaps
    end
    _ReleaseBeyond(self, view, "lines", lines)
    _ReleaseBeyond(self, view, "fills", fills)
    _ReleaseBeyond(self, view, "caps", caps)
    return acquired
end

---@param view WaypointView
---@param color number[]
local function _Tint(view, color)
    for _, kind in ipairs(LINE_KINDS) do
        for _, texture in ipairs(view[kind]) do
            texture:SetVertexColor(color[1], color[2], color[3], color[4])
        end
    end
end

-- The hover area is every segment fattened by the radius: a band per segment and a disc on each
-- point. Drawn only while debugging hover.
---@param self WaypointCanvasRenderer
---@param view WaypointView
local function _DrawHoverArea(self, view)
    local radius = view.waypointRadius
    local bands, dots = 0, 0
    if radius then
        for _, run in ipairs(view.waypointRuns) do
            for i, point in ipairs(run) do
                if i > 1 then
                    bands = bands + 1
                    local band = _Acquire(self, view, "bands", bands)
                    DrawLine(band, view, run[i - 1].x, -run[i - 1].y, point.x, -point.y, radius * 2, 1, "TOPLEFT")
                    band:SetVertexColor(DEBUG_COLOR[1], DEBUG_COLOR[2], DEBUG_COLOR[3], DEBUG_COLOR[4])
                end
                dots = dots + 1
                local dot = _Acquire(self, view, "dots", dots)
                dot:ClearAllPoints()
                dot:SetPoint("CENTER", view, "TOPLEFT", point.x, -point.y)
                dot:SetSize(radius * 2, radius * 2)
                dot:SetVertexColor(DEBUG_COLOR[1], DEBUG_COLOR[2], DEBUG_COLOR[3], DEBUG_COLOR[4])
            end
        end
    end
    _ReleaseBeyond(self, view, "bands", bands)
    _ReleaseBeyond(self, view, "dots", dots)
end

-- Views

---Applies a style, redrawing only what changed: a new thickness redraws the lines, a new color
---only tints them.
---@param view WaypointView
---@param style WaypointStyle
function Renderer:Restyle(view, style)
    assert(self.owned[view], "Waypoint view is not owned by this renderer")
    local acquired = false
    if view.waypointThickness ~= style.thickness then
        view.waypointThickness = style.thickness
        acquired = _DrawLines(self, view)
    end
    if view.waypointRadius ~= style.hoverRadius then
        view.waypointRadius = style.hoverRadius
        _DrawHoverArea(self, view)
    end
    local color, old = style.color, view.waypointColor
    if acquired or not old or old[1] ~= color[1] or old[2] ~= color[2] or old[3] ~= color[3] or old[4] ~= color[4] then
        view.waypointColor = {color[1], color[2], color[3], color[4]}
        _Tint(view, color)
    end
    view:SetAlpha(style.alpha or 1)
    if view.waypointFrameLevel ~= style.frameLevel then
        view.waypointFrameLevel = style.frameLevel
        view:SetFrameLevel(style.frameLevel)
    end
end

---Draws a path, reusing view when given. The view starts hidden when new.
---@param view WaypointView? A view of this renderer to redraw, or nil for a new one.
---@param runs table[][] Polylines in canvas units with y down, each at least two points. Segments
---join within a run, and its corners draw rounded; a run returning to its first point is closed.
---@param style WaypointStyle
---@return WaypointView
function Renderer:Draw(view, runs, style)
    for _, run in ipairs(runs) do
        assert(#run >= 2, "Waypoint runs need at least two points")
    end
    if not view then
        view = table.remove(self.freeViews)
        if not view then
            view = CreateFrame("Frame", nil, self.canvas)
            view:SetPoint("TOPLEFT", self.canvas, "TOPLEFT")
            view:SetSize(1, 1)
            for kind in pairs(KINDS) do view[kind] = {} end
        end
        view:Hide()
        self.owned[view] = true
    end
    assert(self.owned[view], "Waypoint view is not owned by this renderer")
    view.waypointRuns = runs
    -- New geometry redraws everything the style touches.
    view.waypointThickness, view.waypointRadius = nil, nil
    self:Restyle(view, style)
    return view
end

---Hides a view and returns it and its textures to the pools.
---@param view WaypointView
function Renderer:Release(view)
    if not self.owned[view] then return end
    view:Hide()
    for kind in pairs(KINDS) do _ReleaseBeyond(self, view, kind, 0) end
    view.waypointRuns, view.waypointThickness, view.waypointRadius, view.waypointColor = nil, nil, nil, nil
    self.owned[view] = nil
    self.freeViews[#self.freeViews + 1] = view
end

---Releases every view.
function Renderer:Clear()
    for view in pairs(self.owned) do self:Release(view) end
end

---Redraws every drawn path, after the waypointSmoothing setting changed or the profile switched.
---Restyle redraws lines only for a new thickness, so a new smoothing needs this.
function WaypointRenderer.RedrawAll()
    for renderer in pairs(renderers) do
        for view in pairs(renderer.owned) do
            if _DrawLines(renderer, view) then _Tint(view, view.waypointColor) end
        end
    end
end
