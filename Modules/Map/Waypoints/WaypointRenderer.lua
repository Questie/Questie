-- luacheck: globals DrawLine
---@class WaypointRenderer
local WaypointRenderer = QuestieLoader:CreateModule("WaypointRenderer")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---How a drawn polyline looks. Units are the canvas's own, before its scale.
---@class WaypointStyle
---@field thickness number Line width; a quarter of it is black outline on each side.
---@field color number[] {r, g, b, a}, tinting only the line's core.
---@field alpha number? Whole-polyline opacity, such as an icon's fade. Default 1.
---@field frameLevel number
---@field hoverRadius number? Debugging: draws the hover area beneath the line.

---One drawn path. Owned by its renderer; show and hide it like any frame.
---@class WaypointView : Frame
---@field lines Texture[]
---@field bands Texture[]
---@field caps Texture[]
---@field waypointSegments table[] Segment endpoints as pairs: segment i runs from [2i - 1] to [2i].
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

-- One texture outlines a line: rows 0-7 and 24-31 of this 32x32 image are black and the middle is
-- white, so the vertex color tints only the core. Clamping to black keeps DrawLine's bounding
-- quad transparent outside the strip.
local LINE_TEXTURE = QuestieLib.AddonPath .. "Icons\\waypoint-line.blp"
local WHITE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"
local CIRCLE_TEXTURE = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local DEBUG_COLOR = {0.2, 0.8, 1, 0.25}

-- Lines draw above the debug hover area of their own polyline.
local KINDS = {
    lines = {asset = LINE_TEXTURE, layer = "ARTWORK"},
    bands = {asset = WHITE_TEXTURE, layer = "BACKGROUND"},
    caps = {asset = CIRCLE_TEXTURE, layer = "BACKGROUND"},
}

---Creates a renderer drawing onto canvas. Views take no mouse input.
---@param canvas Frame
---@param maskTextures MaskTexture[]? Applied once to every texture, for canvases that do not clip, such as the minimap.
---@return WaypointCanvasRenderer
function WaypointRenderer.New(canvas, maskTextures)
    return setmetatable({canvas = canvas, maskTextures = maskTextures or {}, owned = {}, freeViews = {},
        free = {lines = {}, bands = {}, caps = {}}}, Renderer)
end

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
        texture = view:CreateTexture(nil, KINDS[kind].layer)
        -- Pooled textures never leave this renderer, so they keep these settings and masks.
        texture:SetSnapToPixelGrid(false)
        texture:SetTexelSnappingBias(0)
        texture:SetTexture(KINDS[kind].asset, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
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

-- Points are canvas units with y down; DrawLine anchors to the view's top left with y up.
---@param texture Texture
---@param view WaypointView
---@param a table
---@param b table
---@param thickness number
local function _DrawSegment(texture, view, a, b, thickness)
    DrawLine(texture, view, a.x, -a.y, b.x, -b.y, thickness, 1, "TOPLEFT")
end

---@param self WaypointCanvasRenderer
---@param view WaypointView
---@return boolean acquired Some line is new to the view and needs its color.
local function _DrawLines(self, view)
    local segments, thickness = view.waypointSegments, view.waypointThickness
    local acquired = false
    for i = 1, #segments / 2 do
        local line, new = _Acquire(self, view, "lines", i)
        acquired = acquired or new
        _DrawSegment(line, view, segments[2 * i - 1], segments[2 * i], thickness)
    end
    _ReleaseBeyond(self, view, "lines", #segments / 2)
    return acquired
end

-- The hover area is every segment fattened by the radius: a band per segment and a disc on each
-- end. Drawn only while debugging hover.
---@param self WaypointCanvasRenderer
---@param view WaypointView
local function _DrawHoverArea(self, view)
    local segments, radius = view.waypointSegments, view.waypointRadius
    if not radius then
        _ReleaseBeyond(self, view, "bands", 0)
        _ReleaseBeyond(self, view, "caps", 0)
        return
    end
    for i = 1, #segments / 2 do
        local band = _Acquire(self, view, "bands", i)
        _DrawSegment(band, view, segments[2 * i - 1], segments[2 * i], radius * 2)
        band:SetVertexColor(DEBUG_COLOR[1], DEBUG_COLOR[2], DEBUG_COLOR[3], DEBUG_COLOR[4])
    end
    for i, point in ipairs(segments) do
        local cap = _Acquire(self, view, "caps", i)
        cap:ClearAllPoints()
        cap:SetPoint("CENTER", view, "TOPLEFT", point.x, -point.y)
        cap:SetSize(radius * 2, radius * 2)
        cap:SetVertexColor(DEBUG_COLOR[1], DEBUG_COLOR[2], DEBUG_COLOR[3], DEBUG_COLOR[4])
    end
    _ReleaseBeyond(self, view, "bands", #segments / 2)
    _ReleaseBeyond(self, view, "caps", #segments)
end

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
        for _, line in ipairs(view.lines) do
            line:SetVertexColor(color[1], color[2], color[3], color[4])
        end
    end
    view:SetAlpha(style.alpha or 1)
    if view.waypointFrameLevel ~= style.frameLevel then
        view.waypointFrameLevel = style.frameLevel
        view:SetFrameLevel(style.frameLevel)
    end
end

---Endpoint pairs of a polyline's segments, as Draw takes them.
---@param points table[]
---@return table[] segments
function WaypointRenderer.Segments(points)
    local segments = {}
    for i = 2, #points do
        segments[#segments + 1] = points[i - 1]
        segments[#segments + 1] = points[i]
    end
    return segments
end

---Draws a path's segments, reusing view when given. The view starts hidden when new.
---@param view WaypointView? A view of this renderer to redraw, or nil for a new one.
---@param segments table[] Endpoint pairs in canvas units with y down, at least one segment.
---@param style WaypointStyle
---@return WaypointView
function Renderer:Draw(view, segments, style)
    assert(#segments >= 2 and #segments % 2 == 0, "Waypoint paths need whole segments")
    if not view then
        view = table.remove(self.freeViews)
        if not view then
            view = CreateFrame("Frame", nil, self.canvas)
            view:SetPoint("TOPLEFT", self.canvas, "TOPLEFT")
            view:SetSize(1, 1)
            view.lines, view.bands, view.caps = {}, {}, {}
        end
        view:Hide()
        self.owned[view] = true
    end
    assert(self.owned[view], "Waypoint view is not owned by this renderer")
    view.waypointSegments = segments
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
    view.waypointSegments, view.waypointThickness, view.waypointRadius, view.waypointColor = nil, nil, nil, nil
    self.owned[view] = nil
    self.freeViews[#self.freeViews + 1] = view
end

---Releases every view.
function Renderer:Clear()
    for view in pairs(self.owned) do self:Release(view) end
end
