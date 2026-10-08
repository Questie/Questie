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
---@field highlighted boolean? Highlight this outline through its associated marker, independent of native motion support.

---@class PolygonCanvasRenderer
---@field canvas Frame
---@field activeFrames Frame[] Current visible views only.
---@field visibleFrames table<Frame, boolean> Membership index for activeFrames; not the ownership registry.
---@field ownedFrames table<Frame, boolean> Includes hidden views and partial allocations awaiting cleanup.
---@field freeFrames Frame[]
---@field freeFills Texture[]
---@field freeBorders Texture[]
---@field hoverInput PolygonHoverInput?
---@field hoverFrames table<Frame, boolean> Only visible motion-capable frames.
---@field hoveredFrames table<Frame, boolean> All containing polygons in the current native focus stack.
---@field highlightedFrames table<Frame, boolean> Union of geometric hover and caller-requested marker highlights.
---@field hoverDriver Frame? One shared update driver, retained across visible-set changes.
---@field hoverPolling boolean? Whether the driver currently has its motion-polling callback installed.
---@field combatDriver Frame? Event-only driver for deferred input setup; no polling.
---@field combatPending boolean? A combat-end reconciliation is registered.

---@class PolygonHoverInput
---@field getCursorPosition fun(): number?, number? Normalized coordinates against the full canvas extent.
---@field getMouseFoci fun(): ScriptRegion[] Participating regions in top-to-bottom propagation order.

local Renderer = {}
Renderer.__index = Renderer

local WHITE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

local function _IsFinite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

---Creates a renderer with no registration or map-global side effects. The canvas owns
---clipping and zoom/pan; configuration uses its full logical extent, not the viewport size.
---@param canvas Frame
---@param hoverInput PolygonHoverInput? Omit to keep drawing fully noninteractive.
---@return PolygonCanvasRenderer
function PolygonRenderer.New(canvas, hoverInput)
    return setmetatable({canvas = canvas, activeFrames = {}, freeFrames = {}, freeFills = {}, freeBorders = {},
        ownedFrames = {}, visibleFrames = {}, hoverInput = hoverInput, hoverFrames = {}, hoveredFrames = {}, highlightedFrames = {}}, Renderer)
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

---Reconciles native focus hits and marker requests for the published visible set.
---Only changed effective highlights restyle borders; hidden retained views are excluded.
function Renderer:UpdateHover()
    local hovered, selected = {}, {}
    if next(self.hoverFrames) then
        local input = self.hoverInput
        local x, y = input.getCursorPosition()
        -- Restricted/off-screen cursor data cannot safely participate in geometry comparisons.
        local secretCursor = issecretvalue and (issecretvalue(x) or issecretvalue(y))
        if not secretCursor and _IsFinite(x) and _IsFinite(y) and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
            -- Highlight every containing polygon in the native participation stack.
            -- An opaque UI region excludes obscured frames; rectangular overlap alone is insufficient.
            for _, region in ipairs(input.getMouseFoci()) do
                if self.hoverFrames[region] and region:IsShown() and _ContainsPoint(region.polygonOutline, x * 100, y * 100) then
                    hovered[region], selected[region] = true, true
                end
            end
        end
    end
    -- Marker association remains independent of motion propagation and geometric hover.
    -- Leaving a polygon cannot erase the outline highlight requested by its hovered marker.
    for _, frame in ipairs(self.activeFrames) do
        if frame.polygonHighlighted and frame:IsShown() then selected[frame] = true end
    end
    self.hoveredFrames = hovered
    _SetHighlightedFrames(self, selected)
end

-- Motion participation controls polling. Marker-only highlights still need the
-- driver's hide/show lifecycle, but no OnUpdate. Style batches retain the polling interval.
local function _SyncHoverDriver(self)
    local hasMotion = next(self.hoverFrames) ~= nil
    local hasMarkerHighlight = false
    for _, frame in ipairs(self.activeFrames) do
        hasMarkerHighlight = hasMarkerHighlight or frame.polygonHighlighted
    end
    if not hasMotion and not hasMarkerHighlight then
        if self.hoverDriver then
            self.hoverDriver:SetScript("OnUpdate", nil)
            self.hoverDriver:Hide()
        end
        self.hoverPolling = false
        self.hoveredFrames = {}
        _SetHighlightedFrames(self, {})
        return
    end

    if not self.hoverDriver then
        local driver = CreateFrame("Frame", nil, self.canvas)
        self.hoverDriver = driver
        driver:Hide()
        driver:EnableMouse(false)
        driver:SetScript("OnHide", function(hiddenDriver)
            hiddenDriver:SetScript("OnUpdate", nil)
            self.hoverPolling = false
            self.hoveredFrames = {}
            _SetHighlightedFrames(self, {})
        end)
        driver:SetScript("OnShow", function()
            _SyncHoverDriver(self)
            self:UpdateHover()
        end)
    end
    if hasMotion and not self.hoverPolling then
        local elapsed = 0
        self.hoverDriver:SetScript("OnUpdate", function(_, delta)
            elapsed = elapsed + delta
            if elapsed >= 0.08 then
                elapsed = elapsed % 0.08
                self:UpdateHover()
            end
        end)
        self.hoverPolling = true
    elseif not hasMotion and self.hoverPolling then
        self.hoverDriver:SetScript("OnUpdate", nil)
        self.hoverPolling = false
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
    return center, minX, minY, frameWidth, frameHeight
end

local function _AcquireTexture(self, frame, border, index)
    local free = border and self.freeBorders or self.freeFills
    local owned = border and frame.borders or frame.fills
    local texture = owned[index]
    if texture then return texture end
    texture = table.remove(free) or frame:CreateTexture(nil, "OVERLAY", nil, border and 1 or 0)
    -- Record ownership before native configuration, including partial allocations.
    owned[index] = texture
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
---combine staged marker-highlight requests with native hover.
---@param frame Frame Owned view returned by Create.
---@param shape PolygonShape
---@param frameLevel number
function Renderer:Style(frame, shape, frameLevel)
    assert(self.ownedFrames[frame], "Polygon view is not owned by this renderer")
    local r, g, b, fillAlpha, borderAlpha, highlighted = _Appearance(shape)
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

local function _ConfigureFrame(self, frame, shape, width, height, frameLevel, center, minX, minY, frameWidth, frameHeight)
    local points = shape.points
    frame.polygonOutline = points
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
    local center, minX, minY, frameWidth, frameHeight = _Bounds(shape.points, width, height)
    local frame = table.remove(self.freeFrames)
    if not frame then
        frame = CreateFrame("Frame", nil, self.canvas)
        frame.fills, frame.borders = {}, {}
    end
    self.ownedFrames[frame] = true
    frame:Hide()
    frame:EnableMouse(false)
    if frame.EnableMouseMotion then frame:EnableMouseMotion(false) end
    _ConfigureFrame(self, frame, shape, width, height, frameLevel, center, minX, minY, frameWidth, frameHeight)
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
    local center, minX, minY, frameWidth, frameHeight = _Bounds(shape.points, width, height)
    _ConfigureFrame(self, frame, shape, width, height, frameLevel, center, minX, minY, frameWidth, frameHeight)
end

-- Visibility publication and teardown
local function _EnableMotion(self, frame)
    -- Propagation is a lifetime property of our native frame, not of a cached view.
    -- Hidden/pooled frames disable motion instead of toggling the restricted setter.
    if not frame:CanPropagateMouseMotion() then
        -- Read native state rather than trusting a previous setter call. Until
        -- pass-through is confirmed, the view must not intercept mouse motion.
        frame:EnableMouseMotion(false)
        if InCombatLockdown() then
            if not self.combatDriver then
                local driver = CreateFrame("Frame")
                self.combatDriver = driver
                driver:Hide()
                driver:SetScript("OnEvent", function()
                    if InCombatLockdown() then return end
                    driver:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    self.combatPending = nil
                    -- Never replay captured frames: visibility and ownership may
                    -- have changed, or the map may have closed during combat.
                    self:SetVisibleFrames(self.activeFrames)
                end)
            end
            if not self.combatPending then
                self.combatDriver:RegisterEvent("PLAYER_REGEN_ENABLED")
                self.combatPending = true
            end
            return false
        end
        frame:SetPropagateMouseMotion(true)
        if not frame:CanPropagateMouseMotion() then return false end
    end
    frame:EnableMouseMotion(true)
    return true
end

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
    -- Remove input participation before hiding views omitted from this map's set.
    for _, frame in ipairs(self.activeFrames) do
        if not visible[frame] then
            frame:EnableMouse(false)
            if frame.EnableMouseMotion then frame:EnableMouseMotion(false) end
            frame:Hide()
        end
    end

    -- Publish only motion-capable views to hover tracking; clicks stay disabled.
    local input = self.hoverInput
    local canReadHover = input and type(input.getCursorPosition) == "function" and type(input.getMouseFoci) == "function"
    local hoverFrames, activeFrames = {}, {}
    for _, frame in ipairs(frames) do
        activeFrames[#activeFrames + 1] = frame
        local canParticipate = canReadHover and type(frame.EnableMouseMotion) == "function"
            and type(frame.SetPropagateMouseMotion) == "function" and type(frame.CanPropagateMouseMotion) == "function"
        if canParticipate and (not self.hoverFrames[frame] or not frame:CanPropagateMouseMotion()) then
            canParticipate = _EnableMotion(self, frame)
        end
        if canParticipate then hoverFrames[frame] = true end
        if not frame:IsShown() then frame:Show() end
    end
    self.visibleFrames, self.activeFrames, self.hoverFrames = visible, activeFrames, hoverFrames
    local wasShown = self.hoverDriver and self.hoverDriver:IsShown()
    _SyncHoverDriver(self)
    -- OnShow already evaluates a newly started driver. An unchanged active driver
    -- still needs one immediate cursor check after geometry/highlight changes.
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
    self.highlightedFrames[frame], self.hoveredFrames[frame], self.hoverFrames[frame] = nil, nil, nil
    local wasVisible = self.visibleFrames[frame]
    self.visibleFrames[frame] = nil
    for i = #self.activeFrames, 1, -1 do
        if self.activeFrames[i] == frame then table.remove(self.activeFrames, i); break end
    end
    -- Hide before disabling input: a failing native input call must not leave a
    -- visible stale view. Ownership stays reachable until every cleanup step succeeds.
    frame:Hide()
    if wasVisible then _SyncHoverDriver(self) end
    frame:EnableMouse(false)
    if frame.EnableMouseMotion then frame:EnableMouseMotion(false) end
    frame.polygonOutline, frame.polygonColor, frame.polygonBorderAlpha, frame.polygonHighlighted = nil, nil, nil, nil
    frame.polygonFrameLevel = nil
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
    if self.combatDriver then self.combatDriver:UnregisterEvent("PLAYER_REGEN_ENABLED") end
    self.combatPending = nil
    -- Unlike ordinary Hide publication, error cleanup cannot depend on successful
    -- border styling. Remove selections first so the driver's OnHide is harmless.
    local highlighted = self.highlightedFrames
    self.highlightedFrames, self.hoveredFrames, self.hoverFrames = {}, {}, {}
    self.activeFrames, self.visibleFrames = {}, {}
    for frame in pairs(highlighted) do pcall(_RestyleBorders, frame, false) end
    local firstError
    if self.hoverDriver then
        local ok, err = pcall(function()
            self.hoverDriver:SetScript("OnUpdate", nil)
            self.hoverDriver:Hide()
        end)
        if not ok then firstError = err end
    end
    self.hoverPolling = false
    for frame in pairs(self.ownedFrames) do
        local ok, err = pcall(self.Release, self, frame)
        if not ok and not firstError then firstError = err end
    end
    if firstError then error(firstError, 0) end
end
