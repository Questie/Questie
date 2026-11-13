dofile("setupTests.lua")

describe("PolygonRenderer", function()
    local PolygonRenderer
    local originals
    local frames, textures, failTexture
    local canvas = {}

    -- Fresh-view setup for the primitive/hover contract tests. Retention tests below
    -- call Create/Configure/Style/SetVisibleFrames directly without wholesale cleanup.
    local function _Draw(renderer, shapes, width, height, level)
        renderer:Clear()
        local counts = {regions = #shapes, fills = 0, borders = 0}
        local ok, err = pcall(function()
            local views = {}
            for _, shape in ipairs(shapes) do
                local view = renderer:Create(shape, width, height)
                views[#views + 1] = view
                counts.fills, counts.borders = counts.fills + #view.fills, counts.borders + #view.borders
            end
            renderer:SetVisibleFrames(views, level, level)
        end)
        if not ok then
            renderer:Clear()
            return nil, tostring(err)
        end
        return counts
    end

    local function _NewHoverRenderer()
        return PolygonRenderer.New(canvas, {})
    end

    -- Border pieces: one per edge, plus two fills and a cap at each corner of 60 degrees or less,
    -- where MapGeometry.MITER_LIMIT stops mitering. The {0, 0}, {30, 0}, {15, 30} triangle has one
    -- such corner, its 53-degree apex, so 6 pieces; a right triangle has two 45-degree corners, so 9.
    local function _AssertNear(expected, actual)
        assert.are.equal(#expected, #actual)
        for i, value in ipairs(expected) do assert.are.near(value, actual[i], 1e-9) end
    end

    -- A border piece's corners in frame units with y down, read back from its vertex offsets, which
    -- have y up and start at the frame's own corners: start left, start right, end left, end right.
    local function _Corners(texture)
        local frame, offsets = texture.parent, texture.offsets
        return {offsets.UL[1], -offsets.UL[2], offsets.LL[1], frame.height - offsets.LL[2],
            offsets.UR[1] + frame.width, -offsets.UR[2], offsets.LR[1] + frame.width, frame.height - offsets.LR[2]}
    end

    -- The border texture's line fills the middle 12 of its 16 rows, and a fade the rest
    -- (Icons/originals/blobs/build.py), so a piece is 16/12 as wide as its line.
    local LINE_SHARE = 12 / 16

    -- How thick a border edge's line is drawn: its piece's width, the distance between the piece's
    -- left and right sides, times LINE_SHARE. Both left corners lie on the left side, which runs
    -- along the edge.
    local function _Thickness(texture)
        local corners = _Corners(texture)
        local dx, dy = corners[5] - corners[1], corners[6] - corners[2]
        local width = math.abs(dx * (corners[4] - corners[2]) - dy * (corners[3] - corners[1])) / math.sqrt(dx * dx + dy * dy)
        return width * LINE_SHARE
    end

    local function _CreateTexture(frame)
        local texture = {parent = frame, offsets = {}, id = #textures + 1}
        textures[#textures + 1] = texture
        function texture:SetParent(parent) self.parent = parent end
        function texture:SetSnapToPixelGrid(value) self.snap = value end
        function texture:SetTexelSnappingBias(value) self.bias = value end
        function texture:SetTexture(path, wrapHorizontal, wrapVertical, filter)
            if self.id == failTexture then error("texture configuration failed") end
            self.path, self.wrap, self.filter = path, {wrapHorizontal, wrapVertical}, filter
        end
        function texture:SetAllPoints(parent) self.allPoints = parent end
        function texture:SetVertexOffset(vertex, x, y) self.offsets[vertex] = {x, y} end
        function texture:SetTexCoord(...) self.uv = {...} end
        function texture:SetVertexColor(...) self.color = {...} end
        function texture:Show() self.shown = true end
        function texture:Hide() self.shown = false end
        function texture:ClearAllPoints() self.allPoints = nil end
        function texture:AddMaskTexture(mask)
            self.masks = self.masks or {}
            self.masks[#self.masks + 1] = mask
        end
        return texture
    end

    local function _CreateFrame(_kind, _name, parent)
        local frame = {parent = parent}
        frames[#frames + 1] = frame
        function frame:Hide()
            local wasShown = self.shown
            self.shown = false
            if wasShown and self.scripts and self.scripts.OnHide then self.scripts.OnHide(self) end
        end
        function frame:Show()
            local wasShown = self.shown
            self.shown = true
            if not wasShown and self.scripts and self.scripts.OnShow then self.scripts.OnShow(self) end
        end
        function frame:IsShown() return self.shown end
        function frame:IsVisible()
            return self.shown and (not self.parent.IsVisible or self.parent:IsVisible())
        end
        function frame:SetScript(name, callback)
            self.scripts = self.scripts or {}
            self.scripts[name] = callback
        end
        function frame:RegisterEvent(event)
            self.events = self.events or {}
            self.events[event] = true
        end
        function frame:UnregisterEvent(event)
            if self.events then self.events[event] = nil end
        end
        function frame:EnableMouse(value) self.mouse = value end
        function frame:SetFrameLevel(value) self.level = value end
        function frame:SetPoint(...) self.anchor = {...} end
        function frame:SetSize(width, height) self.width, self.height = width, height end
        function frame:ClearAllPoints() self.anchor = nil end
        frame.CreateTexture = _CreateTexture
        return frame
    end

    before_each(function()
        frames, textures, failTexture = {}, {}, nil
        originals = {
            CreateFrame = _G.CreateFrame, random = math.random,
            UPPER_LEFT_VERTEX = _G.UPPER_LEFT_VERTEX, UPPER_RIGHT_VERTEX = _G.UPPER_RIGHT_VERTEX,
            LOWER_LEFT_VERTEX = _G.LOWER_LEFT_VERTEX, LOWER_RIGHT_VERTEX = _G.LOWER_RIGHT_VERTEX,
        }
        _G.CreateFrame = _CreateFrame
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX = "UL", "UR"
        _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = "LL", "LR"
        dofile("Modules/Map/MapGeometry.lua")
        dofile("Modules/Map/Polygon/PolygonStacking.lua")
        dofile("Modules/Map/Polygon/PolygonRenderer.lua")
        PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
        PolygonRenderer.debugRandomColors = false
    end)

    after_each(function()
        PolygonRenderer.debugRandomColors = false
        math.random = originals.random
        _G.CreateFrame = originals.CreateFrame
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX = originals.UPPER_LEFT_VERTEX, originals.UPPER_RIGHT_VERTEX
        _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = originals.LOWER_LEFT_VERTEX, originals.LOWER_RIGHT_VERTEX
    end)

    it("creates no native objects until drawing", function()
        PolygonRenderer.New(canvas)
        assert.are_same({}, frames)
        assert.are_same({}, textures)
    end)

    it("draws an even fan in percentage coordinates relative to its canvas bounds", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts = _Draw(renderer, {{
            points = {{x = 10, y = 20}, {x = 30, y = 20}, {x = 30, y = 50}, {x = 10, y = 50}},
            color = {0.2, 0.4, 0.6, 0.25},
        }}, 1000, 500, 12)

        assert.are_same({regions = 1, fills = 2, borders = 4}, counts)
        assert.are_equal(canvas, frames[1].parent)
        assert.are_same({"TOPLEFT", canvas, "TOPLEFT", 100, -100}, frames[1].anchor)
        assert.are_equal(200, frames[1].width)
        assert.are_equal(150, frames[1].height)
        assert.are_equal(12, frames[1].level)
        assert.is_true(frames[1].shown)
        assert.are_same({UL = {200, -150}, LL = {100, 75}, UR = {0, 0}, LR = {-200, 150}}, textures[1].offsets)
        assert.are_same({UL = {0, 0}, LL = {100, 75}, UR = {-200, -150}, LR = {0, 0}}, textures[2].offsets)
        assert.are_same({0, 0, 0, 1, 1, 0, 1, 1}, textures[1].uv)
        assert.are_same({0.2, 0.4, 0.6, 0.25}, textures[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.75}, textures[3].color)
        -- Borders are 1.5 wide, centered on the outline, and their pieces 1.5 * 16 / 12 = 2 wide, so
        -- the texture's fade lies outside the line. A rectangle's miters lie on its corners' diagonals,
        -- 1 along each axis: inside on the left of this clockwise outline, outside on the right. The
        -- first edge runs along the top, (0, 0) to (200, 0) in the 200x150 frame.
        _AssertNear({1, -1}, textures[3].offsets.UL)
        _AssertNear({-1, 151}, textures[3].offsets.LL)
        _AssertNear({-1, -1}, textures[3].offsets.UR)
        _AssertNear({1, 151}, textures[3].offsets.LR)
        -- The last edge, up the left side, ends on the very corners the first starts on.
        _AssertNear({1, 149, -1, 151, 1, 1, -1, -1}, _Corners(textures[6]))
        assert.are_equal("Interface\\BUTTONS\\WHITE8X8", textures[1].path)
        -- Each edge stretches the whole line texture over its piece: rows across it, the same all along.
        for i = 3, 6 do
            assert.are_equal("Interface\\Addons\\Questie\\Icons\\blobs\\blob-line-aa.png", textures[i].path)
            assert.are_same({0, 0, 0, 1, 1, 0, 1, 1}, textures[i].uv)
        end
        -- Bilinear filtering keeps the fade smooth; the clamp keeps a cap's corners past the image on
        -- its transparent outer texels.
        assert.are_same({"CLAMP", "CLAMP"}, textures[3].wrap)
        assert.are_equal("LINEAR", textures[3].filter)
        assert.is_false(textures[1].snap)
        assert.are_equal(0, textures[1].bias)
    end)

    describe("sharp corners", function()
        local LINE = "Interface\\Addons\\Questie\\Icons\\blobs\\blob-line-aa.png"
        local CAP = "Interface\\Addons\\Questie\\Icons\\blobs\\blob-cap-aa.png"
        -- The {0, 0}, {30, 0}, {15, 30} triangle in a 100x100 canvas, so frame units equal percent: its
        -- apex is its one corner sharp enough for fills and a cap.
        local TRIANGLE = {points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0}}

        it("fades the fills from the point and rounds the cap with the line's rows", function()
            local renderer = PolygonRenderer.New(canvas)
            _Draw(renderer, {TRIANGLE}, 100, 100, 8)
            local borders = frames[1].borders

            assert.are_equal(6, #borders)
            -- A fill runs from a segment's end corners, on its two sides, to the point at the centre row.
            for i = 4, 5 do
                assert.are_equal(LINE, borders[i].path)
                assert.are_same({0, 0, 0, 1, 1, 0.5, 1, 0.5}, borders[i].uv)
            end
            -- The cap's kite reaches sqrt(2) half widths from the apex (15, 30): along the outward normals
            -- of the edges meeting there, (2, 1) / sqrt(5) to the right and (-2, 1) / sqrt(5) to the left,
            -- and straight down, away from the triangle. Pieces' half width is 1.5 / 2 * 16 / 12 = 1. The
            -- cap image's disc radius, 8 of its 32 texels, spans one half width.
            local function Kite(centerX, centerY, reach)
                local across, down = reach * 2 / math.sqrt(5), reach / math.sqrt(5)
                return {centerX, centerY, centerX + across, centerY + down, centerX - across, centerY + down,
                    centerX, centerY + reach}
            end
            assert.are_equal(CAP, borders[6].path)
            _AssertNear(Kite(15, 30, math.sqrt(2)), _Corners(borders[6]))
            _AssertNear(Kite(0.5, 0.5, math.sqrt(2) / 4), borders[6].uv)
        end)

        it("gives a reused texture the image of the piece it draws now", function()
            local renderer = PolygonRenderer.New(canvas)
            _Draw(renderer, {TRIANGLE}, 100, 100, 8)
            local view = frames[1]
            local cap = view.borders[6]
            assert.are_equal(CAP, cap.path)

            -- A hexagon has six edges and no sharp corner, so its sixth piece is an edge.
            renderer:Configure(view, {points = {{x = 20, y = 10}, {x = 40, y = 10}, {x = 50, y = 30}, {x = 40, y = 50},
                {x = 20, y = 50}, {x = 10, y = 30}}, color = {1, 0, 0}}, 100, 100)

            assert.are_equal(cap, view.borders[6])
            assert.are_equal(LINE, cap.path)
            assert.are_same({0, 0, 0, 1, 1, 0, 1, 1}, cap.uv)
        end)
    end)

    it("keeps independent debug tints through hover while preserving fill and border opacity", function()
        PolygonRenderer.debugRandomColors = true
        local randomCalls = 0
        math.random = function()
            randomCalls = randomCalls + 1
            return randomCalls / 16
        end
        local renderer = _NewHoverRenderer()
        local shapes = {{
            points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
            color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0.1875,
        }}
        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_same({0.0625, 0.125, 0.1875, 0.05}, frames[1].fills[1].color)
        assert.are_same({0.25, 0.3125, 0.375, 0.05}, frames[1].fills[2].color)
        assert.are_same({0.4375, 0.5, 0.5625, 0.1875}, frames[1].borders[1].color)
        assert.are_same({0.625, 0.6875, 0.75, 0.1875}, frames[1].borders[2].color)
        assert.are_same({0.8125, 0.875, 0.9375, 0.1875}, frames[1].borders[3].color)

        renderer:Hover(15, 10)
        assert.are_same({0.546875, 0.625, 0.703125, 0.1875}, frames[1].borders[1].color)
        assert.are.near(2.25, _Thickness(frames[1].borders[1]), 1e-9)
        renderer:Hover(90, 90)
        assert.are_same({0.4375, 0.5, 0.5625, 0.1875}, frames[1].borders[1].color)
        assert.are.near(1.5, _Thickness(frames[1].borders[1]), 1e-9)
        -- Three per texture: two fills and six border pieces.
        assert.are_equal(24, randomCalls)

        PolygonRenderer.debugRandomColors = false
        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
        assert.is_nil(frames[1].borders[1].polygonDebugColor)
        assert.are_equal(24, randomCalls)
    end)

    it("closes an odd fan with a degenerate quad rather than an extra outer edge", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts = _Draw(renderer, {{
            points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
            color = {1, 0, 0},
        }}, 100, 100, 8)

        assert.are_same({regions = 1, fills = 2, borders = 6}, counts)
        assert.are_same({UL = {0, 0}, LL = {15, 20}, UR = {-15, -30}, LR = {-15, 20}}, textures[2].offsets)
        assert.are_same({1, 0, 0, 0.3}, textures[2].color)
        assert.are_equal(8, #textures)
    end)

    it("keeps disconnected outlines in separate noninteractive frames", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts = _Draw(renderer, {
            {points = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 10}}, color = {1, 0, 0}},
            {points = {{x = 40, y = 40}, {x = 50, y = 40}, {x = 40, y = 50}}, color = {0, 1, 0}},
        }, 100, 100, 8)

        assert.are_same({regions = 2, fills = 4, borders = 18}, counts)
        assert.are_equal(2, #frames)
        assert.are_equal(frames[1], textures[1].parent)
        -- The first of the second outline's, after the first's two fills and nine border pieces.
        assert.are_equal(frames[2], textures[12].parent)
        assert.are_same({"TOPLEFT", canvas, "TOPLEFT", 40, -40}, frames[2].anchor)
    end)

    it("reuses frames and both texture pools without retaining an old color or extent", function()
        local renderer = PolygonRenderer.New(canvas)
        local shapes = {{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0, 0.2}}}
        _Draw(renderer, shapes, 100, 100, 8)
        shapes[1].color = {0, 1, 0, 0.4}
        local counts = _Draw(renderer, shapes, 200, 300, 10)

        assert.are_same({regions = 1, fills = 2, borders = 6}, counts)
        assert.are_equal(1, #frames)
        assert.are_equal(8, #textures)
        assert.are_equal(60, frames[1].width)
        assert.are_equal(90, frames[1].height)
        assert.are_equal(10, frames[1].level)
        assert.are_same({0, 1, 0, 0.4}, frames[1].fills[1].color)
        assert.are_same({0, 1, 0, 0.75}, frames[1].borders[1].color)
    end)

    it("masks every fill and border once, including pooled textures it reuses", function()
        local shapeMask, playerMask = {}, {}
        local renderer = PolygonRenderer.New(canvas, nil, {shapeMask, playerMask})
        local shapes = {{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0, 0.2}}}
        _Draw(renderer, shapes, 100, 100, 8)
        _Draw(renderer, shapes, 100, 100, 8)

        assert.are_equal(8, #textures)
        for _, texture in ipairs(textures) do
            assert.are_same({shapeMask, playerMask}, texture.masks)
        end
        _Draw(PolygonRenderer.New(canvas), shapes, 100, 100, 8)
        assert.is_nil(textures[9].masks)
    end)

    it("uses caller-supplied border opacity independently of fill opacity and resets it on reuse", function()
        local renderer = PolygonRenderer.New(canvas)
        local shapes = {{
            points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
            color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0.1875,
        }}

        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)

        shapes[1].borderAlpha = nil
        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.75}, frames[1].borders[1].color)
        assert.are_equal(1, #frames)
        assert.are_equal(8, #textures)
    end)

    local validBorderAlpha = {
        {name = "fully transparent", alpha = 0},
        {name = "fully opaque", alpha = 1},
    }
    for _, case in ipairs(validBorderAlpha) do
        it("accepts a " .. case.name .. " border", function()
            local renderer = PolygonRenderer.New(canvas)
            local counts = _Draw(renderer, {{
                points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
                color = {1, 0, 0}, borderAlpha = case.alpha,
            }}, 100, 100, 8)

            assert.is_table(counts)
            assert.are_same({1, 0, 0, case.alpha}, frames[1].borders[1].color)
        end)
    end

    local invalidBorderAlpha = {
        {name = "non-number", alpha = false},
        {name = "infinite", alpha = math.huge},
        {name = "NaN", alpha = 0 / 0},
        {name = "negative", alpha = -0.1},
        {name = "greater than one", alpha = 1.1},
    }
    for _, case in ipairs(invalidBorderAlpha) do
        it("rejects a " .. case.name .. " border alpha before allocating primitives", function()
            local renderer = PolygonRenderer.New(canvas)
            local counts, err = _Draw(renderer, {{
                points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
                color = {1, 0, 0}, borderAlpha = case.alpha,
            }}, 100, 100, 8)

            assert.is_nil(counts)
            assert.matches("Invalid polygon border alpha", err)
            assert.are_equal(0, #frames)
            assert.are_equal(0, #textures)
        end)
    end

    it("rejects a nonboolean marker-highlight request before allocating primitives", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts, err = _Draw(renderer, {{
            points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0}, highlighted = "yes",
        }}, 100, 100, 8)

        assert.is_nil(counts)
        assert.matches("Invalid polygon highlight flag", err)
        assert.are_equal(0, #frames)
        assert.are_equal(0, #textures)
        assert.are_same({}, renderer.highlightedFrames)
    end)

    it("clears idempotently and replaces a previous draw with an empty view", function()
        local renderer = PolygonRenderer.New(canvas)
        _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0}}}, 100, 100, 8)
        renderer:Clear()
        renderer:Clear()
        _Draw(renderer, {}, 100, 100, 8)

        assert.is_false(frames[1].shown)
        assert.is_nil(frames[1].anchor)
        assert.is_false(textures[1].shown)
        assert.is_nil(textures[1].allPoints)
        assert.are_equal(1, #renderer.freeFrames)
        assert.are_equal(2, #renderer.freeFills)
        assert.are_equal(6, #renderer.freeBorders)
        assert.are_equal(0, #renderer.activeFrames)
    end)

    it("owns partially configured textures so failure cleanup cannot leak or double-pool them", function()
        local renderer = PolygonRenderer.New(canvas)
        local shapes = {{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0}}}
        failTexture = 2
        local counts, err = _Draw(renderer, shapes, 100, 100, 8)

        assert.is_nil(counts)
        assert.matches("texture configuration failed", err)
        assert.is_false(frames[1].shown)
        assert.is_false(textures[1].shown)
        assert.is_false(textures[2].shown)
        assert.are_equal(0, #renderer.activeFrames)
        assert.are_equal(2, #renderer.freeFills)
        renderer:Clear()
        assert.are_equal(2, #renderer.freeFills)

        failTexture = nil
        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_equal(1, #frames)
        assert.are_equal(8, #textures)
        assert.is_true(frames[1].shown)
    end)

    describe("stacking", function()
        local renderer

        local function Square(minX, minY, maxX, maxY)
            return {points = {{x = minX, y = minY}, {x = maxX, y = minY}, {x = maxX, y = maxY}, {x = minX, y = maxY}},
                color = {1, 0, 0}}
        end

        before_each(function()
            renderer = PolygonRenderer.New(canvas)
        end)

        it("publishes each outline at its level from PolygonStacking, as last configured", function()
            local big, small = renderer:Create(Square(0, 0, 60, 60), 100, 100), renderer:Create(Square(10, 10, 20, 20), 100, 100)
            renderer:SetVisibleFrames({big, small}, 10, 16)
            assert.are.same({10, 11}, {big.level, small.level})
            assert.is_true(big.shown and small.shown)

            renderer:Configure(small, Square(70, 70, 80, 80), 100, 100)
            renderer:SetVisibleFrames({big, small}, 10, 16)

            assert.are.same({10, 10}, {big.level, small.level})
        end)

        it("needs levels to publish outlines", function()
            local view = renderer:Create(Square(0, 0, 60, 60), 100, 100)

            assert.has_error(function() renderer:SetVisibleFrames({view}) end, "Invalid polygon frame levels")
            renderer:SetVisibleFrames({})
        end)
    end)

    describe("retained views", function()
        local triangle

        before_each(function()
            triangle = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.2, 0.4, 0.6, 0.25}}
        end)

        it("creates a hidden owned view and shows it without configuring its primitives again", function()
            local renderer = PolygonRenderer.New(canvas)
            local view = renderer:Create(triangle, 100, 100)
            assert.is_false(view:IsShown())
            assert.is_true(renderer.ownedFrames[view])
            local offsets = view.fills[1].offsets
            local configure = spy.on(view.fills[1], "SetVertexOffset")
            local uv = spy.on(view.fills[1], "SetTexCoord")
            local border = spy.on(view.borders[1], "SetVertexOffset")
            renderer:SetVisibleFrames({view}, 8, 8)
            renderer:SetVisibleFrames({view}, 8, 8)
            assert.is_true(view:IsShown())
            assert.are.equal(offsets, view.fills[1].offsets)
            assert.spy(configure).was.not_called()
            assert.spy(uv).was.not_called()
            assert.spy(border).was.not_called()
            assert.are.equal(1, #frames)
            assert.are.equal(11, #textures)
        end)

        it("finds the visible outlines at a point without hovering, and tells hover listeners the cursor", function()
            local heard = {}
            local renderer = PolygonRenderer.New(canvas, {onHover = function(shapes, x, y)
                heard[#heard + 1] = {#shapes, x, y}
            end})
            local square = {points = {{x = 0, y = 0}, {x = 20, y = 0}, {x = 20, y = 20}, {x = 0, y = 20}}, color = {1, 0, 0}}
            local view, other = renderer:Create(triangle, 100, 100), renderer:Create(square, 100, 100)
            renderer:Create(square, 100, 100) -- Hidden: never published.
            renderer:SetVisibleFrames({view, other}, 8, 8)
            heard = {}

            local found = renderer:ShapesAt(10, 10)
            assert.are.equal(2, #found)
            assert.are.equal(triangle, found[1])
            assert.are.equal(square, found[2])
            found = renderer:ShapesAt(30, 5)
            assert.are.equal(1, #found)
            assert.are.equal(triangle, found[1])
            assert.are.same({}, renderer:ShapesAt(90, 90))
            assert.are.same({}, renderer.hoveredFrames)
            assert.are.same({}, heard)

            renderer:Hover(10, 10)
            renderer:Hover(nil, nil)
            assert.are.same({{2, 10, 10}, {0}}, heard)
        end)

        it("retains hidden views and excludes them from hover until shown again", function()
            local renderer = _NewHoverRenderer()
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            renderer:Hover(10, 10)
            assert.is_true(renderer.highlightedFrames[view])
            local offsets = view.fills[1].offsets
            renderer:SetVisibleFrames({})
            assert.is_false(view:IsShown())
            assert.is_true(renderer.ownedFrames[view])
            assert.are.same({}, renderer.highlightedFrames)
            assert.are.equal(0, #renderer.freeFrames)
            renderer:UpdateHover() -- The cursor is still inside the outline, but the view is not visible.
            assert.are.same({}, renderer.highlightedFrames)
            renderer:SetVisibleFrames({view}, 8, 8)
            assert.is_true(view:IsShown())
            assert.is_true(renderer.highlightedFrames[view])
            assert.are.equal(offsets, view.fills[1].offsets)
            assert.are.equal(2, #frames) -- View plus one shared driver.
        end)

        it("changes a marker highlight without touching fills or anchors", function()
            local renderer = _NewHoverRenderer()
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            local vertices = spy.on(view.fills[1], "SetVertexOffset")
            local fills = spy.on(view.fills[1], "SetVertexColor")
            local anchors = spy.on(view, "SetPoint")
            triangle.highlighted = true
            renderer:Style(view, triangle)
            renderer:SetVisibleFrames({view}, 8, 8)
            -- Redrawn at the new thickness on the textures it already had; the next case checks every piece.
            assert.are.equal(9, #view.borders)
            assert.are.near(2.25, _Thickness(view.borders[1]), 1e-9)
            assert.are.near(2.25, _Thickness(view.borders[3]), 1e-9)
            assert.spy(vertices).was.not_called()
            assert.spy(fills).was.not_called()
            assert.spy(anchors).was.not_called()

            local redraws = spy.on(view.borders[1], "SetVertexOffset")
            renderer:Style(view, triangle)
            renderer:SetVisibleFrames({view}, 8, 8)
            assert.spy(redraws).was.not_called()
        end)

        it("redraws every border piece for a highlight as configuring the view highlighted draws it", function()
            local renderer = _NewHoverRenderer()
            -- Wider than tall, so a redraw cannot swap the frame's width and height unnoticed. At 100x50
            -- the triangle's corners are 90, 27 and 63 degrees: one sharp corner, so 6 pieces.
            local view = renderer:Create(triangle, 100, 50)
            renderer:SetVisibleFrames({view}, 8, 8)
            triangle.highlighted = true
            renderer:Style(view, triangle)
            renderer:SetVisibleFrames({view}, 8, 8)

            -- Configured again while highlighted, the reference is drawn at the highlight's thickness
            -- from the start rather than redrawn.
            local reference = renderer:Create(triangle, 100, 50)
            renderer:SetVisibleFrames({view, reference}, 8, 8)
            renderer:Configure(reference, triangle, 100, 50)
            assert.are.equal(6, #view.borders)
            assert.are.near(2.25, _Thickness(reference.borders[1]), 1e-9)
            for i, border in ipairs(view.borders) do
                for _, vertex in ipairs({"UL", "LL", "UR", "LR"}) do
                    _AssertNear(reference.borders[i].offsets[vertex], border.offsets[vertex])
                end
            end
        end)

        it("updates color, faded opacity, and frame level without repeating border geometry", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            local offsets = view.fills[1].offsets
            local redraws = spy.on(view.borders[1], "SetVertexOffset")
            triangle.color, triangle.borderAlpha = {0.4, 0.2, 0.1, 0.05}, 0.1875
            renderer:Style(view, triangle)
            renderer:SetVisibleFrames({view}, 12, 12)
            assert.are.same({0.4, 0.2, 0.1, 0.05}, view.fills[1].color)
            assert.are.same({0.5, 0.25, 0.125, 0.1875}, view.borders[1].color)
            assert.spy(redraws).was.not_called()
            assert.are.equal(offsets, view.fills[1].offsets)
            assert.are.equal(12, view.level)
        end)

        it("keeps direct hover highlighted after the marker highlight is withdrawn", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            renderer:Hover(10, 10)
            local redraws = spy.on(view.borders[1], "SetVertexOffset")
            triangle.highlighted = false
            renderer:Style(view, triangle)
            renderer:SetVisibleFrames({view}, 8, 8)
            assert.is_true(renderer.hoveredFrames[view])
            assert.is_true(renderer.highlightedFrames[view])
            assert.spy(redraws).was.not_called()
        end)

        it("reconfigures canvas size using the same frames, primitives, and diagnostic colors", function()
            PolygonRenderer.debugRandomColors = true
            local renderer = PolygonRenderer.New(canvas)
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            local fill, border = view.fills[1], view.borders[1]
            local fillTint, borderTint = fill.polygonDebugColor, border.polygonDebugColor
            math.random = function() error("retained primitives must not choose a new color") end
            renderer:Configure(view, triangle, 200, 300)
            renderer:SetVisibleFrames({view}, 8, 8)
            assert.are.equal(fill, view.fills[1])
            assert.are.equal(border, view.borders[1])
            assert.are.equal(fillTint, fill.polygonDebugColor)
            assert.are.equal(borderTint, border.polygonDebugColor)
            assert.are.equal(80, view.width)
            assert.are.equal(120, view.height)
            assert.are.equal(1, #frames)
            assert.are.equal(11, #textures)
        end)

        it("retains diagnostic colors through appearance updates and hide/show", function()
            PolygonRenderer.debugRandomColors = true
            local renderer = PolygonRenderer.New(canvas)
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            local tint = view.fills[1].polygonDebugColor
            math.random = function() error("style/show must not choose new colors") end
            triangle.color = {1, 0, 0, 0.1}
            renderer:Style(view, triangle)
            renderer:SetVisibleFrames({})
            renderer:SetVisibleFrames({view}, 8, 8)
            assert.are.equal(tint, view.fills[1].polygonDebugColor)
            assert.are.same({tint[1], tint[2], tint[3], 0.1}, view.fills[1].color)
        end)

        it("releases one retained view without disturbing the other and pools it only once", function()
            local renderer = _NewHoverRenderer()
            local first = renderer:Create(triangle, 100, 100)
            local second = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({first, second}, 8, 8)
            renderer:Release(first)
            renderer:Release(first)
            assert.is_false(first:IsShown())
            assert.is_nil(first.polygonOutline)
            assert.is_nil(renderer.ownedFrames[first])
            assert.is_true(second:IsShown())
            assert.is_true(renderer.ownedFrames[second])
            assert.are.same({second}, renderer.activeFrames)
            assert.are.equal(1, #renderer.freeFrames)
            assert.are.equal(2, #renderer.freeFills)
            assert.are.equal(9, #renderer.freeBorders)
            local replacement = renderer:Create(triangle, 100, 100)
            assert.are.equal(first, replacement)
            assert.are.equal(3, #frames) -- Two views and one driver, no extra view allocation.
        end)

        it("clears visible and hidden owned views and reuses their pools", function()
            local renderer = PolygonRenderer.New(canvas)
            local first = renderer:Create(triangle, 100, 100)
            local second = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({first}, 8, 8)
            renderer:Clear()
            renderer:Clear()
            assert.is_nil(first.polygonOutline)
            assert.is_nil(second.polygonOutline)
            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(2, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeFills)
            assert.are.equal(18, #renderer.freeBorders)
            renderer:Create(triangle, 100, 100)
            assert.are.equal(2, #frames)
            assert.are.equal(22, #textures)
        end)

        it("releases excess primitives when a configured view becomes smaller", function()
            local renderer = PolygonRenderer.New(canvas)
            local square = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 40, y = 40}, {x = 0, y = 40}}, color = {1, 0, 0}}
            -- The triangle's two sharp corners need more border pieces than the square's four edges.
            local view = renderer:Create(triangle, 100, 100)
            local border = view.borders[9]
            renderer:Configure(view, square, 100, 100)
            assert.are.equal(4, #view.borders)
            assert.are.equal(5, #renderer.freeBorders)
            assert.is_false(border.shown)
            assert.is_nil(border.polygonDebugColor)
        end)

        it("can clear ownership after a native style call keeps failing", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            view.borders[1].SetVertexColor = function() error("native color failure") end
            triangle.color = {1, 0, 0, 0.25}
            assert.has_error(function() renderer:Style(view, triangle) end, "native color failure")

            renderer:Clear()
            renderer:Clear()

            assert.are.same({}, renderer.ownedFrames)
            assert.are.same({}, renderer.highlightedFrames)
            assert.are.equal(1, #renderer.freeFrames)
            assert.are.equal(9, #renderer.freeBorders)
            assert.is_false(view:IsShown())
        end)

        it("keeps a failed creation owned while clearing other views, then retries cleanup without double-pooling", function()
            local renderer = _NewHoverRenderer()
            local first = renderer:Create(triangle, 100, 100)
            local second = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({first, second}, 8, 8)
            local nativeCreateFrame = _G.CreateFrame
            _G.CreateFrame = function(...)
                local frame = nativeCreateFrame(...)
                frame.ClearAllPoints = function() error("native anchor failure") end
                return frame
            end

            assert.has_error(function() renderer:Create(triangle, 100, 100) end, "native anchor failure")
            local failed = frames[#frames]
            assert.is_true(renderer.ownedFrames[failed])
            assert.has_error(function() renderer:Clear() end, "native anchor failure")

            assert.are.same({[failed] = true}, renderer.ownedFrames)
            assert.are.same({}, renderer.activeFrames)
            assert.are.same({}, renderer.highlightedFrames)
            assert.is_false(first:IsShown())
            assert.is_false(second:IsShown())
            assert.is_false(failed:IsShown())
            assert.are.equal(2, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeFills)
            assert.are.equal(18, #renderer.freeBorders)
            renderer:UpdateHover()
            assert.are.same({}, renderer.hoveredFrames)

            failed.ClearAllPoints = function(self) self.anchor = nil end
            renderer:Clear()
            renderer:Clear()

            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(3, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeFills)
            assert.are.equal(18, #renderer.freeBorders)
        end)

        it("keeps a failed visible release hidden and out of hover until cleanup succeeds", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            renderer:Hover(10, 10)
            view.ClearAllPoints = function() error("native anchor failure") end

            assert.has_error(function() renderer:Release(view) end, "native anchor failure")

            assert.is_false(view:IsShown())
            assert.is_true(renderer.ownedFrames[view])
            assert.are.equal(0, #renderer.freeFrames)
            assert.are.same({}, renderer.activeFrames)
            assert.are.same({}, renderer.highlightedFrames)
            renderer:UpdateHover()
            assert.are.same({}, renderer.hoveredFrames)

            view.ClearAllPoints = function(self) self.anchor = nil end
            renderer:Release(view)
            renderer:Release(view)
            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(1, #renderer.freeFrames)
        end)

        it("cleans partial geometry growth on a highlighted view without redrawing unfinished borders", function()
            local renderer = _NewHoverRenderer()
            local square = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 40, y = 40}, {x = 0, y = 40}}, color = {1, 0, 0},
                highlighted = true}
            local view = renderer:Create(square, 100, 100)
            renderer:SetVisibleFrames({view}, 8, 8)
            -- Growing from the square's four border pieces to the triangle's nine: the two fills and
            -- four edges are reused, and the fifth border piece is the first new texture.
            failTexture = 7
            assert.has_error(function() renderer:Configure(view, triangle, 100, 100) end, "texture configuration failed")
            assert.are.equal(5, #view.borders)
            local redraws = {}
            for i, border in ipairs(view.borders) do redraws[i] = spy.on(border, "SetVertexOffset") end
            renderer:Clear()
            renderer:Clear()
            -- Assert outside the renderer's protected cleanup, which catches native errors. Restoring
            -- the unhighlighted thickness from the square's stale border would redraw the textures the
            -- failed configuration left half done.
            for _, redraw in ipairs(redraws) do assert.spy(redraw).was.not_called() end
            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(1, #renderer.freeFrames)
            assert.are.equal(5, #renderer.freeBorders)
        end)
    end)

    describe("direct polygon hover", function()
        it("hovers with no per-polygon or per-frame script", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 0, y = 30}}, color = {0.2, 0.4, 0.6}},
                {points = {{x = 40, y = 40}, {x = 70, y = 40}, {x = 40, y = 70}}, color = {0.2, 0.4, 0.6}},
            }, 100, 100, 8)

            assert.are_equal(3, #frames)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.is_nil(frames[1].scripts)
            assert.is_nil(frames[2].scripts)
        end)

        it("highlights every containing polygon and restores only the shape the cursor leaves", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 50, y = 0}, {x = 50, y = 50}, {x = 0, y = 50}}, color = {0.2, 0.4, 0.6}},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            renderer:Hover(10, 10)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.highlightedFrames)
            assert.are.near(2.25, _Thickness(frames[1].borders[1]), 1e-9)
            assert.are.near(2.25, _Thickness(frames[2].borders[1]), 1e-9)

            local redraws = spy.on(frames[1].borders[1], "SetVertexOffset")
            renderer:Hover(30, 30) -- In both rectangles, but no longer in the triangle.
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.spy(redraws).was.not_called()
            assert.are.near(2.25, _Thickness(frames[1].borders[1]), 1e-9)
            assert.are.near(1.5, _Thickness(frames[2].borders[1]), 1e-9)
        end)

        it("tells a hover listener the hovered shapes on every check", function()
            local heard = {}
            local renderer = PolygonRenderer.New(canvas, {
                onHover = function(shapes) heard[#heard + 1] = shapes end,
            })
            local square = {points = {{x = 0, y = 0}, {x = 50, y = 0}, {x = 50, y = 50}, {x = 0, y = 50}}, color = {1, 0, 0}}
            local triangle = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0, 1, 0}}
            _Draw(renderer, {square, triangle}, 100, 100, 8)
            heard = {}

            renderer:Hover(10, 10)
            renderer:Hover(12, 10) -- Still inside both.
            renderer:Hover(45, 45) -- Only the square.
            assert.are.same({{square, triangle}, {square, triangle}, {square}}, heard)

            -- Hiding everything ends the hover.
            heard = {}
            renderer:SetVisibleFrames({})
            for _, shapes in ipairs(heard) do assert.are.same({}, shapes) end
            assert.is_true(#heard > 0)
        end)

        it("follows the outline rather than the frame's rectangle, without enter or leave scripts", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            assert.is_true(renderer:Hover(10, 10))
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            -- Still in the same rectangle, but no longer in its triangle: nothing to claim the cursor.
            assert.is_false(renderer:Hover(30, 30))
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("includes exact edges and vertices in the polygon", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            renderer:Hover(20, 20)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            renderer:Hover(0, 0)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            renderer:Hover(40, 0) -- On the outline's bounding-box edge as well.
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
        end)

        it("brightens a hovered border without overriding marker fade, then restores it", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0.1875}}, 100, 100, 8)
            local fill, border = frames[1].fills[1], frames[1].borders[1]
            renderer:Hover(10, 10)
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, border.color)
            assert.are.near(2.25, _Thickness(border), 1e-9)
            assert.are_same({0.2, 0.4, 0.6, 0.05}, fill.color)
            assert.are_equal(11, #textures)

            renderer:Hover(90, 90)
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, border.color)
            assert.are.near(1.5, _Thickness(border), 1e-9)
            assert.are_equal(11, #textures)
        end)

        it("keeps a transparent border invisible through selection and restoration", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0}}, 100, 100, 8)
            local border = frames[1].borders[1]
            renderer:Hover(10, 10)

            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
            assert.are_same({0.25, 0.5, 0.75, 0}, border.color)
            assert.are.near(2.25, _Thickness(border), 1e-9)
            assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)

            renderer:Hover(90, 90)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({0.2, 0.4, 0.6, 0}, border.color)
            assert.are.near(1.5, _Thickness(border), 1e-9)
        end)

        it("ends the hover when offered no cursor", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            renderer:Hover(10, 10)
            assert.is_false(renderer:Hover(nil, nil))
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("rechecks a stationary cursor against replacement outlines on reused frames", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            renderer:Hover(10, 10)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0, 1, 0}}}, 100, 100, 8)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames) -- Immediate recheck, without any cursor motion.
            _Draw(renderer, {{points = {{x = 60, y = 60}, {x = 90, y = 60}, {x = 60, y = 90}}, color = {0, 0, 1}}}, 100, 100, 8)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_equal(2, #frames) -- One reused bounding frame and the shared driver.
        end)

        it("does not redraw borders while the geometric selection stays unchanged", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}}}, 100, 100, 8)
            renderer:Hover(10, 10)
            local redraws = spy.on(frames[1].borders[1], "SetVertexOffset")

            renderer:Hover(15, 10)
            assert.spy(redraws).was.not_called()
            renderer:Hover(90, 90)
            -- One draw sets a piece's four vertices.
            assert.spy(redraws).was.called(4)
            renderer:Hover(90, 90)
            assert.spy(redraws).was.called(4)
        end)

        it("combines direct overlap hits with the separate marker highlight", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                    color = {0.2, 0.4, 0.6}, highlighted = true, borderAlpha = 0.1875},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            local redraws = spy.on(frames[1].borders[1], "SetVertexOffset")
            renderer:Hover(10, 10)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.highlightedFrames)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.hoveredFrames)
            assert.spy(redraws).was.not_called()

            renderer:Hover(90, 90)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.spy(redraws).was.not_called()

            assert.is_false(renderer:Hover(nil, nil))
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.spy(redraws).was.not_called()
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, frames[1].borders[1].color)
            assert.are.near(1.5, _Thickness(frames[2].borders[1]), 1e-9)
        end)

        it("keeps marker-associated highlighting available without a hover input", function()
            local renderer = PolygonRenderer.New(canvas)
            local shapes = {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true, borderAlpha = 0.1875}}
            _Draw(renderer, shapes, 100, 100, 8)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are.near(2.25, _Thickness(frames[1].borders[1]), 1e-9)
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, frames[1].borders[1].color)

            renderer.hoverDriver:Hide()
            assert.are_same({}, renderer.highlightedFrames)
            assert.are.near(1.5, _Thickness(frames[1].borders[1]), 1e-9)
            renderer.hoverDriver:Show()
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are.near(2.25, _Thickness(frames[1].borders[1]), 1e-9)

            shapes[1].highlighted = false
            _Draw(renderer, shapes, 100, 100, 8)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(frames[1].polygonHighlighted)
            assert.are.near(1.5, _Thickness(frames[1].borders[1]), 1e-9)
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
            assert.is_false(renderer.hoverDriver.shown)
            assert.are_equal(2, #frames)
        end)

        it("stops on inherited hide and resumes while the driver's own shown flag remains set", function()
            local parent = {visible = true, IsVisible = function(self) return self.visible end}
            local renderer = PolygonRenderer.New(parent, {})
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            renderer:Hover(10, 10)
            local driver = renderer.hoverDriver

            -- Native inherited visibility fires scripts without changing IsShown().
            parent.visible = false
            driver.scripts.OnHide(driver)
            assert.is_true(driver:IsShown())
            assert.is_false(driver:IsVisible())
            assert.are_same({}, renderer.hoveredFrames)
            assert.are.near(1.5, _Thickness(frames[1].borders[1]), 1e-9)

            parent.visible = true
            driver.scripts.OnShow(driver)
            assert.is_true(driver:IsShown())
            assert.is_true(driver:IsVisible())
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
        end)

        it("clears highlights, references, and the driver before pooling", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.2, 0.4, 0.6}, highlighted = true},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            renderer:Hover(10, 10)
            local markerBorder, geometricBorder = frames[1].borders[1], frames[2].borders[1]
            renderer:Clear()
            renderer:Clear()

            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_nil(frames[1].polygonOutline)
            assert.is_nil(frames[1].polygonBounds)
            assert.is_nil(frames[1].polygonColor)
            assert.is_nil(frames[1].polygonHighlighted)
            assert.is_nil(frames[2].polygonHighlighted)
            assert.are.near(1.5, _Thickness(markerBorder), 1e-9)
            assert.are.near(1.5, _Thickness(geometricBorder), 1e-9)
            assert.are_same({0.2, 0.4, 0.6, 0.75}, markerBorder.color)
            assert.are_equal(2, #renderer.freeFrames)
            assert.are_equal(18, #renderer.freeBorders)
        end)

        it("leaves no hover driver or marker highlight after a replacement draw fails", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true}}, 100, 100, 8)
            renderer:Hover(10, 10)
            failTexture = 2
            local counts, err = _Draw(renderer, {{
                points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0},
            }}, 100, 100, 8)

            assert.is_nil(counts)
            assert.matches("texture configuration failed", err)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_nil(frames[1].polygonHighlighted)
            assert.are_equal(0, #renderer.activeFrames)
        end)

        it("stops the shared driver when a draw has no shapes", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            renderer:Hover(10, 10)
            _Draw(renderer, {}, 100, 100, 8)

            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(renderer.hoverDriver.shown)
            assert.are_equal(0, #renderer.activeFrames)
        end)

        it("ignores hidden or pooled frames under the cursor", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            frames[1]:Hide()
            renderer:Hover(10, 10)
            assert.are_same({}, renderer.hoveredFrames)

            renderer:Clear()
            renderer:UpdateHover()
            assert.are_same({}, renderer.hoveredFrames)
            assert.is_nil(frames[1].polygonOutline)
        end)

    end)

    it("rejects degenerate bounds before allocating rendering objects", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts, err = _Draw(renderer, {{
            points = {{x = 1, y = 1}, {x = 1, y = 2}, {x = 1, y = 3}}, color = {1, 0, 0},
        }}, 100, 100, 8)

        assert.is_nil(counts)
        assert.matches("empty bounds", err)
        assert.are_equal(0, #frames)
        assert.are_equal(0, #textures)
    end)
end)
