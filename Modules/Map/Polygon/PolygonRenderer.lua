-- luacheck: globals DrawLine UPPER_LEFT_VERTEX LOWER_LEFT_VERTEX UPPER_RIGHT_VERTEX LOWER_RIGHT_VERTEX
---@class PolygonRenderer
local PolygonRenderer = QuestieLoader:CreateModule("PolygonRenderer")

-- Diagnostic tints are chosen on acquisition, not refresh. Set false for newly
-- acquired primitives to use objective colors; retained primitives keep their tints.
PolygonRenderer.debugRandomColors = false

---@class PolygonShape
---@field points table[] Immutable ordered convex outline in destination-map percentages, with named x/y fields.
---@field color number[] RGB plus optional fill alpha; border opacity is independent.
---@field borderAlpha number? Border opacity in [0, 1], default 0.75; callers can apply marker fade.
---@field highlighted boolean? Highlight this outline through its associated marker, independent of cursor hover.

---@class PolygonCanvasRenderer
---@field canvas Frame
---@field activeFrames Frame[] Current visible views only.
---@field visibleFrames table<Frame, boolean> Membership index for activeFrames; not the ownership registry.
---@field ownedFrames table<Frame, boolean> Includes hidden views and partial allocations awaiting cleanup.
---@field freeFrames Frame[]
---@field freeFills Texture[]
---@field freeBorders Texture[]
---@field hoverInput PolygonHoverInput?
---@field maskTextures MaskTexture[] Applied once to every texture this renderer creates.
---@field hoveredFrames table<Frame, boolean> Visible polygons whose outlines contain the cursor.
---@field highlightedFrames table<Frame, boolean> Union of geometric hover and caller-requested marker highlights.
---@field hoverDriver Frame? One shared frame, retained across visible-set changes: hiding the canvas ends hover and highlights, showing it restores them.
---@field cursorX number? The cursor WorldMapLayers last offered, in canvas percent; nil while it offers none.
---@field cursorY number?

---Polygon frames never take mouse input, so they cannot block map clicks or dragging and
---need no protected input setup. Hover is computed from the offered cursor and the outlines instead.
---@class PolygonHoverInput
---@field onHover fun(shapes: PolygonShape[], changed: boolean, x: number?, y: number?)? Hears every hover check, with the hovered shapes as last styled; changed when the hovered set differs; x and y the cursor checked, nil once the hover ended.

local Renderer = {}
Renderer.__index = Renderer

local WHITE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

local function _IsFinite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

---Creates a renderer with no registration or map-global side effects. The canvas owns
---clipping and zoom/pan; configuration uses its full logical extent, not the viewport size.
---@param canvas Frame
---@param hoverInput PolygonHoverInput? Omit for marker highlighting only, without cursor hover.
---@param maskTextures MaskTexture[]? Clip every fill and border, for canvases that do not clip, such as the minimap.
---@return PolygonCanvasRenderer
function PolygonRenderer.New(canvas, hoverInput, maskTextures)
    return setmetatable({canvas = canvas, activeFrames = {}, freeFrames = {}, freeFills = {}, freeBorders = {},
        ownedFrames = {}, visibleFrames = {}, hoverInput = hoverInput, maskTextures = maskTextures or {},
        hoveredFrames = {}, highlightedFrames = {}}, Renderer)
end

-- Hover selection and border styling
-- Border geometry is retained so hover changes neither fills nor pooled ownership.
-- RGB brightening keeps the caller's faded opacity intact, including a transparent border.
local function _RestyleBorders(frame, selected)
    local brightness = selected and 1.25 or 1
    local thickness = selected and 1.8 or 1.5
    for _, line in ipairs(frame.borders) do
        -- An allocation/configuration failure may leave an owned border without
        -- endpoints. Cleanup must not try to redraw that unfinished primitive.
        if line.polygonStartX ~= nil then
            local color = line.polygonDebugColor or frame.polygonColor
            if line.polygonThickness ~= thickness then
                DrawLine(line, frame, line.polygonStartX, line.polygonStartY, line.polygonEndX, line.polygonEndY,
                    thickness, 1, "TOPLEFT")
                line.polygonThickness = thickness
            end
            line:SetVertexColor(math.min(color[1] * brightness, 1), math.min(color[2] * brightness, 1),
                math.min(color[3] * brightness, 1), frame.polygonBorderAlpha)
        end
    end
end

---@param before table<Frame, boolean>
---@param after table<Frame, boolean>
---@return boolean
local function _HoverChanged(before, after)
    for frame in pairs(after) do
        if not before[frame] then return true end
    end
    for frame in pairs(before) do
        if not after[frame] then return true end
    end
    return false
end

---Listeners hear every check, so they can follow cursor moves within the same areas.
local function _NotifyHover(self, changed)
    local onHover = self.hoverInput and self.hoverInput.onHover
    if not onHover then return end
    local shapes = {}
    for _, frame in ipairs(self.activeFrames) do
        if self.hoveredFrames[frame] and frame.polygonShape then shapes[#shapes + 1] = frame.polygonShape end
    end
    onHover(shapes, changed, self.cursorX, self.cursorY)
end

---Ends geometric hover, telling listeners only if something was hovered.
local function _ResetHover(self)
    local hadHover = next(self.hoveredFrames) ~= nil
    self.hoveredFrames = {}
    local onHover = self.hoverInput and self.hoverInput.onHover
    if hadHover and onHover then onHover({}, true) end
end

local function _SetHighlightedFrames(self, selected)
    for frame in pairs(self.highlightedFrames) do
        if not selected[frame] then _RestyleBorders(frame, false) end
    end
    for frame in pairs(selected) do
        if not self.highlightedFrames[frame] then _RestyleBorders(frame, true) end
    end
    self.highlightedFrames = selected
end

-- Inclusive edges avoid flicker at vertices and shared borders. The renderer receives
-- ordered outlines; this odd/even test does not assume rectangular frame bounds are the shape.
local function _ContainsPoint(points, x, y)
    local inside = false
    local previous = points[#points]
    for _, point in ipairs(points) do
        local cross = (x - previous.x) * (point.y - previous.y) - (y - previous.y) * (point.x - previous.x)
        if math.abs(cross) <= 1e-8 and x >= math.min(previous.x, point.x) and x <= math.max(previous.x, point.x)
            and y >= math.min(previous.y, point.y) and y <= math.max(previous.y, point.y) then
            return true
        end
        if (previous.y > y) ~= (point.y > y)
            and x < (point.x - previous.x) * (y - previous.y) / (point.y - previous.y) + previous.x then
            inside = not inside
        end
        previous = point
    end
    return inside
end

-- The outline's bounding box rejects most polygons before the full test.
local function _Contains(frame, x, y)
    local bounds = frame.polygonBounds
    return x >= bounds[1] and x <= bounds[3] and y >= bounds[2] and y <= bounds[4] and frame:IsShown()
        and _ContainsPoint(frame.polygonOutline, x, y)
end

---Reconciles the kept cursor's hits and marker requests for the published visible set. Hover
---selects every visible outline containing the cursor, overlaps included. Only changed effective
---highlights restyle borders.
function Renderer:UpdateHover()
    local hovered, selected = {}, {}
    local x, y = self.cursorX, self.cursorY
    if self.hoverInput and x then
        for _, frame in ipairs(self.activeFrames) do
            if _Contains(frame, x, y) then hovered[frame], selected[frame] = true, true end
        end
    end
    -- Marker association remains independent of geometric hover.
    -- Leaving a polygon cannot erase the outline highlight requested by its hovered marker.
    for _, frame in ipairs(self.activeFrames) do
        if frame.polygonHighlighted and frame:IsShown() then selected[frame] = true end
    end
    local changed = _HoverChanged(self.hoveredFrames, hovered)
    self.hoveredFrames = hovered
    _SetHighlightedFrames(self, selected)
    _NotifyHover(self, changed)
end

---The shapes of the visible outlines containing a point, overlaps included, as last styled. Changes
---no hover.
---@param x number In the outlines' units, such as canvas percent.
---@param y number
---@return PolygonShape[]
function Renderer:ShapesAt(x, y)
    local shapes = {}
    for _, frame in ipairs(self.activeFrames) do
        if frame.polygonShape and _Contains(frame, x, y) then shapes[#shapes + 1] = frame.polygonShape end
    end
    return shapes
end

---Hovers the outlines under the cursor WorldMapLayers offers, or ends the hover for nil. The
---renderer keeps the cursor, so outlines drawn anew under a still cursor hover at once.
---@param x number? Canvas percent.
---@param y number?
---@return boolean hovered Whether any outline contains the cursor.
function Renderer:Hover(x, y)
    self.cursorX, self.cursorY = x, y
    self:UpdateHover()
    return next(self.hoveredFrames) ~= nil
end

-- Visible polygons with a hover input, and marker highlights, need the driver's hide/show
-- lifecycle: a hidden canvas shows neither.
local function _SyncHoverDriver(self)
    local canHover = self.hoverInput ~= nil and #self.activeFrames > 0
    local hasMarkerHighlight = false
    for _, frame in ipairs(self.activeFrames) do
        hasMarkerHighlight = hasMarkerHighlight or frame.polygonHighlighted
    end
    if not canHover and not hasMarkerHighlight then
        if self.hoverDriver then self.hoverDriver:Hide() end
        _ResetHover(self)
        _SetHighlightedFrames(self, {})
        return
    end

    if not self.hoverDriver then
        local driver = CreateFrame("Frame", nil, self.canvas)
        self.hoverDriver = driver
        driver:Hide()
        driver:SetScript("OnHide", function()
            _ResetHover(self)
            _SetHighlightedFrames(self, {})
        end)
        driver:SetScript("OnShow", function()
            _SyncHoverDriver(self)
            self:UpdateHover()
        end)
    end
    if not self.hoverDriver:IsShown() then self.hoverDriver:Show() end
end

-- Geometry configuration and primitive reuse
-- Validate shared appearance inputs before allocating or mutating native regions.
local function _Appearance(shape)
    local color = shape.color
    assert(type(color) == "table" and _IsFinite(color[1]) and _IsFinite(color[2]) and _IsFinite(color[3])
        and (color[4] == nil or _IsFinite(color[4])), "Invalid polygon color")
    local borderAlpha = shape.borderAlpha == nil and 0.75 or shape.borderAlpha
    assert(_IsFinite(borderAlpha) and borderAlpha >= 0 and borderAlpha <= 1, "Invalid polygon border alpha")
    assert(shape.highlighted == nil or type(shape.highlighted) == "boolean", "Invalid polygon highlight flag")
    return color[1], color[2], color[3], color[4] or 0.3, borderAlpha, shape.highlighted == true
end

-- The arithmetic mean is an interior fan anchor for a convex outline, not the
-- area-weighted objective-marker centroid computed by PolygonGeometry.
---@return table center
---@return number[] bounds {minX, minY, maxX, maxY} in map percentages; also the hover hit box.
---@return number frameWidth
---@return number frameHeight
local function _Bounds(points, width, height)
    assert(_IsFinite(width) and width > 0 and _IsFinite(height) and height > 0, "Invalid polygon canvas extent")
    assert(type(points) == "table" and #points >= 3, "Polygon outlines need at least three points")
    local center, minX, minY, maxX, maxY = {x = 0, y = 0}, math.huge, math.huge, -math.huge, -math.huge
    for _, point in ipairs(points) do
        assert(_IsFinite(point.x) and _IsFinite(point.y), "Invalid polygon coordinate")
        center.x, center.y = center.x + point.x, center.y + point.y
        minX, minY = math.min(minX, point.x), math.min(minY, point.y)
        maxX, maxY = math.max(maxX, point.x), math.max(maxY, point.y)
    end
    center.x, center.y = center.x / #points, center.y / #points
    local frameWidth, frameHeight = (maxX - minX) * width / 100, (maxY - minY) * height / 100
    assert(frameWidth > 0 and frameHeight > 0, "Polygon outline has empty bounds")
    return center, {minX, minY, maxX, maxY}, frameWidth, frameHeight
end

local function _AcquireTexture(self, frame, border, index)
    local free = border and self.freeBorders or self.freeFills
    local owned = border and frame.borders or frame.fills
    local texture = owned[index]
    if texture then return texture end
    local recycled = table.remove(free)
    texture = recycled or frame:CreateTexture(nil, "OVERLAY", nil, border and 1 or 0)
    -- Record ownership before native configuration, including partial allocations.
    owned[index] = texture
    -- Pooled textures never leave this renderer, so they already carry its masks.
    if not recycled then
        for _, mask in ipairs(self.maskTextures) do texture:AddMaskTexture(mask) end
    end
    texture:SetParent(frame)
    texture:SetSnapToPixelGrid(false)
    texture:SetTexelSnappingBias(0)
    texture:SetTexture(WHITE_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    texture.polygonDebugColor = PolygonRenderer.debugRandomColors and {math.random(), math.random(), math.random()} or nil
    return texture
end

local function _ReleaseTextures(owned, free, count)
    for index = #owned, count + 1, -1 do
        local texture = owned[index]
        texture:Hide()
        texture:ClearAllPoints()
        texture.polygonDebugColor = nil
        texture.polygonStartX, texture.polygonStartY, texture.polygonEndX, texture.polygonEndY = nil, nil, nil, nil
        texture.polygonThickness = nil
        free[#free + 1], owned[index] = texture, nil
    end
end

-- Two adjacent fan triangles share one distorted texture. Reconfiguration retains
-- its identity/debug tint; hide/show and appearance changes never enter this path.
local function _DrawSquare(texture, frame, a, b, c, center, width, height, minX, minY, frameWidth, frameHeight)
    local cross = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
    if cross < 0 then a, c = c, a end
    texture:SetAllPoints(frame)
    texture:SetVertexOffset(UPPER_LEFT_VERTEX, (a.x - minX) * width / 100, -(a.y - minY) * height / 100)
    texture:SetVertexOffset(LOWER_LEFT_VERTEX, (center.x - minX) * width / 100, frameHeight - (center.y - minY) * height / 100)
    texture:SetVertexOffset(UPPER_RIGHT_VERTEX, (b.x - minX) * width / 100 - frameWidth, -(b.y - minY) * height / 100)
    texture:SetVertexOffset(LOWER_RIGHT_VERTEX, (c.x - minX) * width / 100 - frameWidth, frameHeight - (c.y - minY) * height / 100)
    texture:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
    texture:Show()
end

---Updates appearance without geometry setup, comparing scalar values rather than
---the caller's color-table identity. Finish each batch with SetVisibleFrames to
---combine staged marker-highlight requests with cursor hover.
---@param frame Frame Owned view returned by Create.
---@param shape PolygonShape
---@param frameLevel number
function Renderer:Style(frame, shape, frameLevel)
    assert(self.ownedFrames[frame], "Polygon view is not owned by this renderer")
    local r, g, b, fillAlpha, borderAlpha, highlighted = _Appearance(shape)
    -- Every caller styles each visible view per publication, so this is the shape on screen.
    frame.polygonShape = shape
    local old = frame.polygonColor
    local tintChanged = not old or old[1] ~= r or old[2] ~= g or old[3] ~= b
    local fillChanged = tintChanged or not old or old[4] ~= fillAlpha
    local borderChanged = tintChanged or frame.polygonBorderAlpha ~= borderAlpha
    if fillChanged then
        frame.polygonColor = {r, g, b, fillAlpha}
        for _, texture in ipairs(frame.fills) do
            local tint = texture.polygonDebugColor or frame.polygonColor
            texture:SetVertexColor(tint[1], tint[2], tint[3], fillAlpha)
        end
    end
    frame.polygonBorderAlpha, frame.polygonHighlighted = borderAlpha, highlighted
    if borderChanged then _RestyleBorders(frame, self.highlightedFrames[frame] == true) end
    if frame.polygonFrameLevel ~= frameLevel then
        frame:SetFrameLevel(frameLevel)
        frame.polygonFrameLevel = frameLevel
    end
end

local function _ConfigureFrame(self, frame, shape, width, height, frameLevel, center, bounds, frameWidth, frameHeight)
    local points = shape.points
    local minX, minY = bounds[1], bounds[2]
    frame.polygonOutline, frame.polygonBounds = points, bounds
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", self.canvas, "TOPLEFT", minX * width / 100, -minY * height / 100)
    frame:SetSize(frameWidth, frameHeight)

    -- Preserve the two-edge fan and its odd-vertex degenerate closing quad.
    for i = 1, #points, 2 do
        local a, b, c = points[i], points[i + 1], points[i + 2]
        if i == #points then
            a, b, c = points[1], points[#points], center
        elseif i + 2 > #points then
            a, b, c = points[1], points[#points], points[#points - 1]
        end
        local texture = _AcquireTexture(self, frame, false, (i + 1) / 2)
        _DrawSquare(texture, frame, a, b, c, center, width, height, minX, minY, frameWidth, frameHeight)
    end
    _ReleaseTextures(frame.fills, self.freeFills, math.ceil(#points / 2))

    -- Borders remain independent primitives, including center-aligned edges.
    local thickness = self.highlightedFrames[frame] and 1.8 or 1.5
    for i, a in ipairs(points) do
        local b = points[i % #points + 1]
        local line = _AcquireTexture(self, frame, true, i)
        line.polygonStartX, line.polygonStartY = (a.x - minX) * width / 100, -(a.y - minY) * height / 100
        line.polygonEndX, line.polygonEndY = (b.x - minX) * width / 100, -(b.y - minY) * height / 100
        DrawLine(line, frame, line.polygonStartX, line.polygonStartY, line.polygonEndX, line.polygonEndY, thickness, 1, "TOPLEFT")
        line.polygonThickness = thickness
        line:Show()
    end
    _ReleaseTextures(frame.borders, self.freeBorders, #points)
    -- New/grown primitives need appearance even if the caller's color is unchanged.
    frame.polygonColor, frame.polygonBorderAlpha = nil, nil
    self:Style(frame, shape, frameLevel)
end

---Allocates one initially hidden view. Mutating operations throw on failure; the
---cache catches failures and calls Clear, which owns even partially configured regions.
---@param shape PolygonShape
---@param width number Canvas logical width in UI pixels.
---@param height number Canvas logical height in UI pixels.
---@param frameLevel number Below objective markers.
---@return Frame
function Renderer:Create(shape, width, height, frameLevel)
    _Appearance(shape)
    local center, bounds, frameWidth, frameHeight = _Bounds(shape.points, width, height)
    local frame = table.remove(self.freeFrames)
    if not frame then
        -- New frames take no mouse input, and nothing here ever enables it.
        frame = CreateFrame("Frame", nil, self.canvas)
        frame.fills, frame.borders = {}, {}
    end
    self.ownedFrames[frame] = true
    frame:Hide()
    _ConfigureFrame(self, frame, shape, width, height, frameLevel, center, bounds, frameWidth, frameHeight)
    return frame
end

---Configures supplied map percentages at the new canvas extent; coordinate-space
---translation belongs to the caller. Reused primitives retain their debug colors.
---Replace the outline table rather than mutating points shared with cached views.
---@param frame Frame
---@param shape PolygonShape
---@param width number
---@param height number
---@param frameLevel number
function Renderer:Configure(frame, shape, width, height, frameLevel)
    assert(self.ownedFrames[frame], "Polygon view is not owned by this renderer")
    _Appearance(shape)
    local center, bounds, frameWidth, frameHeight = _Bounds(shape.points, width, height)
    _ConfigureFrame(self, frame, shape, width, height, frameLevel, center, bounds, frameWidth, frameHeight)
end

-- Visibility publication and teardown
---Publishes a complete visible set without releasing absent views. A cached view
---from another map stays hidden/inert, with its primitive configuration intact.
---@param frames Frame[]
function Renderer:SetVisibleFrames(frames)
    local visible = {}
    for _, frame in ipairs(frames) do
        assert(self.ownedFrames[frame], "Polygon view is not owned by this renderer")
        assert(not visible[frame], "Duplicate polygon view in visible set")
        visible[frame] = true
    end
    for _, frame in ipairs(self.activeFrames) do
        if not visible[frame] then frame:Hide() end
    end
    local activeFrames = {}
    for _, frame in ipairs(frames) do
        activeFrames[#activeFrames + 1] = frame
        if not frame:IsShown() then frame:Show() end
    end
    self.visibleFrames, self.activeFrames = visible, activeFrames
    local wasShown = self.hoverDriver and self.hoverDriver:IsShown()
    _SyncHoverDriver(self)
    -- OnShow already evaluates a newly started driver. An unchanged active driver still
    -- needs one immediate check of the kept cursor after geometry/highlight changes.
    if wasShown or not self.hoverDriver or not self.hoverDriver:IsShown() then self:UpdateHover() end
end

---Releases one view; hidden retained views follow the same cleanup as visible ones.
---Native cleanup failure throws, but keeps the unpooled view owned for a later retry.
---Discard the handle after successful release: its native frame can serve another view.
---@param frame Frame
function Renderer:Release(frame)
    if not self.ownedFrames[frame] then return end
    if self.highlightedFrames[frame] then
        -- Cleanup must still release ownership if the native styling call that
        -- failed publication also fails while restoring the unselected border.
        pcall(_RestyleBorders, frame, false)
    end
    self.highlightedFrames[frame], self.hoveredFrames[frame] = nil, nil
    local wasVisible = self.visibleFrames[frame]
    self.visibleFrames[frame] = nil
    for i = #self.activeFrames, 1, -1 do
        if self.activeFrames[i] == frame then table.remove(self.activeFrames, i); break end
    end
    -- Hide first: a failing native cleanup call must not leave a visible stale view.
    -- Ownership stays reachable until every cleanup step succeeds.
    frame:Hide()
    if wasVisible then _SyncHoverDriver(self) end
    frame.polygonOutline, frame.polygonBounds, frame.polygonColor, frame.polygonBorderAlpha = nil, nil, nil, nil
    frame.polygonHighlighted, frame.polygonFrameLevel, frame.polygonShape = nil, nil, nil
    _ReleaseTextures(frame.fills, self.freeFills, 0)
    _ReleaseTextures(frame.borders, self.freeBorders, 0)
    frame:ClearAllPoints()
    self.ownedFrames[frame] = nil
    self.freeFrames[#self.freeFrames + 1] = frame
end

---Attempts every view, including hidden views on other maps. Pools and the driver
---remain reachable for reuse. After all attempts, throws the first cleanup error;
---failed views stay owned and can be retried without double-pooling successful ones.
function Renderer:Clear()
    -- Unlike ordinary Hide publication, error cleanup cannot depend on successful
    -- border styling. Remove selections first so the driver's OnHide is harmless.
    local highlighted = self.highlightedFrames
    self.highlightedFrames = {}
    self.activeFrames, self.visibleFrames = {}, {}
    _ResetHover(self)
    for frame in pairs(highlighted) do pcall(_RestyleBorders, frame, false) end
    local firstError
    if self.hoverDriver then
        local ok, err = pcall(self.hoverDriver.Hide, self.hoverDriver)
        if not ok then firstError = err end
    end
    for frame in pairs(self.ownedFrames) do
        local ok, err = pcall(self.Release, self, frame)
        if not ok and not firstError then firstError = err end
    end
    if firstError then error(firstError, 0) end
end
