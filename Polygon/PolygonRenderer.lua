-- luacheck: globals DrawLine UPPER_LEFT_VERTEX LOWER_LEFT_VERTEX UPPER_RIGHT_VERTEX LOWER_RIGHT_VERTEX
---@class PolygonRenderer
local PolygonRenderer = QuestieLoader:CreateModule("PolygonRenderer")

---@class PolygonShape
---@field points table[] Ordered convex outline in zone percentages, with named x/y fields.
---@field color number[] RGB plus optional fill alpha; border opacity is independent.
---@field borderAlpha number? Border opacity in [0, 1], default 0.75; callers can apply marker fade.
---@field highlighted boolean? Highlight this outline through its associated marker, independent of native motion support.

---@class PolygonCanvasRenderer
---@field canvas Frame
---@field activeFrames Frame[]
---@field freeFrames Frame[]
---@field freeFills Texture[]
---@field freeBorders Texture[]
---@field hoverInput PolygonHoverInput?
---@field hoverFrames table<Frame, boolean> Only motion-capable frames in the current draw.
---@field hoveredFrames table<Frame, boolean> All containing polygons in the current native focus stack.
---@field highlightedFrames table<Frame, boolean> Union of geometric hover and caller-requested marker highlights.
---@field hoverDriver Frame? One shared update driver, retained across draws.

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
---clipping and zoom/pan; Draw receives its full logical extent, not a visible viewport size.
---@param canvas Frame
---@param hoverInput PolygonHoverInput? Omit to keep drawing fully noninteractive.
---@return PolygonCanvasRenderer
function PolygonRenderer.New(canvas, hoverInput)
    return setmetatable({canvas = canvas, activeFrames = {}, freeFrames = {}, freeFills = {}, freeBorders = {},
        hoverInput = hoverInput, hoverFrames = {}, hoveredFrames = {}, highlightedFrames = {}}, Renderer)
end

-- Border geometry is retained so hover changes neither fills nor pooled ownership.
-- RGB brightening keeps the caller's faded opacity intact, including a transparent border.
local function _RestyleBorders(frame, selected)
    local color = frame.polygonColor
    local brightness = selected and 1.25 or 1
    for _, line in ipairs(frame.borders) do
        DrawLine(line, frame, line.polygonStartX, line.polygonStartY, line.polygonEndX, line.polygonEndY,
            selected and 1.8 or 1.5, 1, "TOPLEFT")
        line:SetVertexColor(math.min(color[1] * brightness, 1), math.min(color[2] * brightness, 1),
            math.min(color[3] * brightness, 1), frame.polygonBorderAlpha)
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

function Renderer:Clear()
    -- Stop reads and remove selection before returning frames or borders to their pools.
    if self.hoverDriver then
        self.hoverDriver:SetScript("OnUpdate", nil)
        self.hoverDriver:Hide()
    end
    self.hoveredFrames = {}
    _SetHighlightedFrames(self, {})
    self.hoverFrames = {}
    for i = #self.activeFrames, 1, -1 do
        local frame = self.activeFrames[i]
        frame:EnableMouse(false)
        if frame.EnableMouseMotion then frame:EnableMouseMotion(false) end
        if frame.SetPropagateMouseMotion then frame:SetPropagateMouseMotion(false) end
        frame.polygonOutline, frame.polygonColor, frame.polygonBorderAlpha, frame.polygonHighlighted = nil, nil, nil, nil
        frame:Hide()
        for j = #frame.fills, 1, -1 do
            local texture = frame.fills[j]
            texture:Hide()
            texture:ClearAllPoints()
            self.freeFills[#self.freeFills + 1], frame.fills[j] = texture, nil
        end
        for j = #frame.borders, 1, -1 do
            local texture = frame.borders[j]
            texture:Hide()
            texture:ClearAllPoints()
            self.freeBorders[#self.freeBorders + 1], frame.borders[j] = texture, nil
        end
        frame:ClearAllPoints()
        self.freeFrames[#self.freeFrames + 1], self.activeFrames[i] = frame, nil
    end
end

local function _AcquireTexture(self, frame, border)
    local free = border and self.freeBorders or self.freeFills
    local owned = border and frame.borders or frame.fills
    local texture = table.remove(free) or frame:CreateTexture(nil, "OVERLAY", nil, border and 1 or 0)
    -- Record ownership before native configuration. A failing draw can release both
    -- new allocations and reused textures without publishing a partial polygon.
    owned[#owned + 1] = texture
    texture:SetParent(frame)
    texture:SetSnapToPixelGrid(false)
    texture:SetTexelSnappingBias(0)
    texture:SetTexture(WHITE_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    return texture
end

-- Adapted from Logon's retained DrawSquare: two adjacent fan triangles share one
-- distorted texture. Vertex offsets are relative to each bounding frame's corners.
local function _DrawSquare(self, frame, a, b, c, center, width, height, minX, minY, frameWidth, frameHeight, color)
    local cross = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
    if cross < 0 then a, c = c, a end
    local texture = _AcquireTexture(self, frame, false)
    texture:SetAllPoints(frame)
    texture:SetVertexOffset(UPPER_LEFT_VERTEX, (a.x - minX) * width / 100, -(a.y - minY) * height / 100)
    texture:SetVertexOffset(LOWER_LEFT_VERTEX, (center.x - minX) * width / 100, frameHeight - (center.y - minY) * height / 100)
    texture:SetVertexOffset(UPPER_RIGHT_VERTEX, (b.x - minX) * width / 100 - frameWidth, -(b.y - minY) * height / 100)
    texture:SetVertexOffset(LOWER_RIGHT_VERTEX, (c.x - minX) * width / 100 - frameWidth, frameHeight - (c.y - minY) * height / 100)
    texture:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
    texture:SetVertexColor(color[1], color[2], color[3], color[4] or 0.3)
    texture:Show()
end

---Replaces the previous draw synchronously. Convex outlines must not repeat their
---first vertex. Failure clears every owned primitive and returns nil plus an error.
---@param shapes PolygonShape[]
---@param width number Canvas logical width in UI pixels.
---@param height number Canvas logical height in UI pixels.
---@param frameLevel number Below the associated objective markers.
---@return table? counts
---@return string? err
function Renderer:Draw(shapes, width, height, frameLevel)
    self:Clear()
    local counts = {regions = #shapes, fills = 0, borders = 0}
    local ok, err = pcall(function()
        assert(_IsFinite(width) and width > 0 and _IsFinite(height) and height > 0, "Invalid polygon canvas extent")
        for _, shape in ipairs(shapes) do
            local points, color = shape.points, shape.color
            assert(type(points) == "table" and #points >= 3, "Polygon outlines need at least three points")
            assert(type(color) == "table" and _IsFinite(color[1]) and _IsFinite(color[2]) and _IsFinite(color[3])
                and (color[4] == nil or _IsFinite(color[4])), "Invalid polygon color")
            local borderAlpha = shape.borderAlpha == nil and 0.75 or shape.borderAlpha
            assert(_IsFinite(borderAlpha) and borderAlpha >= 0 and borderAlpha <= 1, "Invalid polygon border alpha")
            assert(shape.highlighted == nil or type(shape.highlighted) == "boolean", "Invalid polygon highlight flag")
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

            local frame = table.remove(self.freeFrames)
            if not frame then
                frame = CreateFrame("Frame", nil, self.canvas)
                frame.fills, frame.borders = {}, {}
            end
            self.activeFrames[#self.activeFrames + 1] = frame
            frame:Hide()
            frame:EnableMouse(false)
            if frame.EnableMouseMotion then frame:EnableMouseMotion(false) end
            frame.polygonOutline, frame.polygonColor, frame.polygonBorderAlpha = points, color, borderAlpha
            frame.polygonHighlighted = shape.highlighted == true
            frame:SetFrameLevel(frameLevel)
            frame:SetPoint("TOPLEFT", self.canvas, "TOPLEFT", minX * width / 100, -minY * height / 100)
            frame:SetSize(frameWidth, frameHeight)

            -- Preserve the old two-edge fan. Odd vertex counts close with a degenerate
            -- quad (one triangle); even counts close with the last pair of outer edges.
            for i = 1, #points, 2 do
                local a, b, c = points[i], points[i + 1], points[i + 2]
                if i == #points then
                    a, b, c = points[1], points[#points], center
                elseif i + 2 > #points then
                    a, b, c = points[1], points[#points], points[#points - 1]
                end
                _DrawSquare(self, frame, a, b, c, center, width, height, minX, minY, frameWidth, frameHeight, color)
            end
            -- Borders are independent primitives; center-aligned vertices must not
            -- suppress valid edges as the historical coordinate-exclusion test did.
            for i, a in ipairs(points) do
                local b = points[i % #points + 1]
                local line = _AcquireTexture(self, frame, true)
                line.polygonStartX, line.polygonStartY = (a.x - minX) * width / 100, -(a.y - minY) * height / 100
                line.polygonEndX, line.polygonEndY = (b.x - minX) * width / 100, -(b.y - minY) * height / 100
                DrawLine(line, frame, line.polygonStartX, line.polygonStartY, line.polygonEndX, line.polygonEndY, 1.5, 1, "TOPLEFT")
                line:SetVertexColor(color[1], color[2], color[3], borderAlpha)
                line:Show()
            end
            counts.fills, counts.borders = counts.fills + #frame.fills, counts.borders + #frame.borders
        end
        -- Publish visibility only when all shapes configured successfully. Missing
        -- native input capabilities leave the affected frames completely noninteractive.
        local input = self.hoverInput
        local canReadHover = input and type(input.getCursorPosition) == "function" and type(input.getMouseFoci) == "function"
        local hasMarkerHighlight = false
        for _, frame in ipairs(self.activeFrames) do
            if canReadHover and type(frame.EnableMouseMotion) == "function" and type(frame.SetPropagateMouseMotion) == "function" then
                frame:SetPropagateMouseMotion(true)
                frame:EnableMouseMotion(true) -- EnableMouse(false) above keeps clicks disabled.
                self.hoverFrames[frame] = true
            end
            hasMarkerHighlight = hasMarkerHighlight or frame.polygonHighlighted
            frame:Show()
        end
        if next(self.hoverFrames) or hasMarkerHighlight then
            if not self.hoverDriver then
                self.hoverDriver = CreateFrame("Frame", nil, self.canvas)
                self.hoverDriver:Hide()
                self.hoverDriver:EnableMouse(false)
                self.hoverDriver:SetScript("OnHide", function(driver)
                    driver:SetScript("OnUpdate", nil)
                    self.hoveredFrames = {}
                    _SetHighlightedFrames(self, {})
                end)
                self.hoverDriver:SetScript("OnShow", function(driver)
                    if #self.activeFrames == 0 then return end
                    if next(self.hoverFrames) then
                        local elapsed = 0
                        driver:SetScript("OnUpdate", function(_, delta)
                            elapsed = elapsed + delta
                            if elapsed >= 0.08 then
                                elapsed = elapsed % 0.08
                                self:UpdateHover()
                            end
                        end)
                    end
                    self:UpdateHover()
                end)
            end
            self.hoverDriver:Show()
        end
    end)
    if not ok then
        self:Clear()
        return nil, tostring(err)
    end
    return counts
end
