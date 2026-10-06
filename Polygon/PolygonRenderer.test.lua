dofile("setupTests.lua")

describe("PolygonRenderer", function()
    local PolygonRenderer
    local originals
    local frames, textures, failTexture
    local cursorX, cursorY, foci
    local canvas = {}

    local function _NewHoverRenderer()
        return PolygonRenderer.New(canvas, {
            getCursorPosition = function() return cursorX, cursorY end,
            getMouseFoci = function() return foci end,
        })
    end

    local function _CreateTexture(frame)
        local texture = {parent = frame, offsets = {}, id = #textures + 1}
        textures[#textures + 1] = texture
        function texture:SetParent(parent) self.parent = parent end
        function texture:SetSnapToPixelGrid(value) self.snap = value end
        function texture:SetTexelSnappingBias(value) self.bias = value end
        function texture:SetTexture(path)
            if self.id == failTexture then error("texture configuration failed") end
            self.path = path
        end
        function texture:SetAllPoints(parent) self.allPoints = parent end
        function texture:SetVertexOffset(vertex, x, y) self.offsets[vertex] = {x, y} end
        function texture:SetTexCoord(...) self.uv = {...} end
        function texture:SetVertexColor(...) self.color = {...} end
        function texture:Show() self.shown = true end
        function texture:Hide() self.shown = false end
        function texture:ClearAllPoints() self.allPoints = nil end
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
        function frame:SetScript(name, callback)
            self.scripts = self.scripts or {}
            self.scripts[name] = callback
        end
        function frame:EnableMouse(value) self.mouse = value end
        function frame:EnableMouseMotion(value) self.motion = value end
        function frame:SetPropagateMouseMotion(value) self.propagate = value end
        function frame:SetFrameLevel(value) self.level = value end
        function frame:SetPoint(...) self.anchor = {...} end
        function frame:SetSize(width, height) self.width, self.height = width, height end
        function frame:ClearAllPoints() self.anchor = nil end
        frame.CreateTexture = _CreateTexture
        return frame
    end

    before_each(function()
        frames, textures, failTexture = {}, {}, nil
        cursorX, cursorY, foci = nil, nil, {}
        originals = {
            CreateFrame = _G.CreateFrame, DrawLine = _G.DrawLine, issecretvalue = _G.issecretvalue,
            UPPER_LEFT_VERTEX = _G.UPPER_LEFT_VERTEX, UPPER_RIGHT_VERTEX = _G.UPPER_RIGHT_VERTEX,
            LOWER_LEFT_VERTEX = _G.LOWER_LEFT_VERTEX, LOWER_RIGHT_VERTEX = _G.LOWER_RIGHT_VERTEX,
        }
        _G.CreateFrame = _CreateFrame
        _G.issecretvalue = nil
        _G.DrawLine = function(texture, parent, startX, startY, endX, endY, thickness, scale, anchor)
            texture.line = {parent, startX, startY, endX, endY, thickness, scale, anchor}
        end
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX = "UL", "UR"
        _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = "LL", "LR"
        dofile("Polygon/PolygonRenderer.lua")
        PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
    end)

    after_each(function()
        _G.CreateFrame, _G.DrawLine = originals.CreateFrame, originals.DrawLine
        _G.issecretvalue = originals.issecretvalue
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
        local counts = renderer:Draw({{
            points = {{x = 10, y = 20}, {x = 30, y = 20}, {x = 30, y = 50}, {x = 10, y = 50}},
            color = {0.2, 0.4, 0.6, 0.25},
        }}, 1000, 500, 12)

        assert.are_same({regions = 1, fills = 2, borders = 4}, counts)
        assert.are_equal(canvas, frames[1].parent)
        assert.are_same({"TOPLEFT", canvas, "TOPLEFT", 100, -100}, frames[1].anchor)
        assert.are_equal(200, frames[1].width)
        assert.are_equal(150, frames[1].height)
        assert.are_equal(12, frames[1].level)
        assert.is_false(frames[1].mouse)
        assert.is_false(frames[1].motion)
        assert.is_true(frames[1].shown)
        assert.are_same({UL = {200, -150}, LL = {100, 75}, UR = {0, 0}, LR = {-200, 150}}, textures[1].offsets)
        assert.are_same({UL = {0, 0}, LL = {100, 75}, UR = {-200, -150}, LR = {0, 0}}, textures[2].offsets)
        assert.are_same({0, 0, 0, 1, 1, 0, 1, 1}, textures[1].uv)
        assert.are_same({0.2, 0.4, 0.6, 0.25}, textures[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.75}, textures[3].color)
        assert.are_same({frames[1], 0, 0, 200, 0, 1.5, 1, "TOPLEFT"}, textures[3].line)
        assert.are_same({frames[1], 0, -150, 0, 0, 1.5, 1, "TOPLEFT"}, textures[6].line)
        assert.are_equal("Interface\\BUTTONS\\WHITE8X8", textures[1].path)
        assert.is_false(textures[1].snap)
        assert.are_equal(0, textures[1].bias)
    end)

    it("closes an odd fan with a degenerate quad rather than an extra outer edge", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts = renderer:Draw({{
            points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
            color = {1, 0, 0},
        }}, 100, 100, 8)

        assert.are_same({regions = 1, fills = 2, borders = 3}, counts)
        assert.are_same({UL = {0, 0}, LL = {15, 20}, UR = {-15, -30}, LR = {-15, 20}}, textures[2].offsets)
        assert.are_same({1, 0, 0, 0.3}, textures[2].color)
        assert.are_equal(5, #textures)
    end)

    it("keeps disconnected outlines in separate noninteractive frames", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts = renderer:Draw({
            {points = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 10}}, color = {1, 0, 0}},
            {points = {{x = 40, y = 40}, {x = 50, y = 40}, {x = 40, y = 50}}, color = {0, 1, 0}},
        }, 100, 100, 8)

        assert.are_same({regions = 2, fills = 4, borders = 6}, counts)
        assert.are_equal(2, #frames)
        assert.are_equal(frames[1], textures[1].parent)
        assert.are_equal(frames[2], textures[6].parent)
        assert.are_same({"TOPLEFT", canvas, "TOPLEFT", 40, -40}, frames[2].anchor)
    end)

    it("reuses frames and both texture pools without retaining an old color or extent", function()
        local renderer = PolygonRenderer.New(canvas)
        local shapes = {{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0, 0.2}}}
        renderer:Draw(shapes, 100, 100, 8)
        shapes[1].color = {0, 1, 0, 0.4}
        local counts = renderer:Draw(shapes, 200, 300, 10)

        assert.are_same({regions = 1, fills = 2, borders = 3}, counts)
        assert.are_equal(1, #frames)
        assert.are_equal(5, #textures)
        assert.are_equal(60, frames[1].width)
        assert.are_equal(90, frames[1].height)
        assert.are_equal(10, frames[1].level)
        assert.are_same({0, 1, 0, 0.4}, frames[1].fills[1].color)
        assert.are_same({0, 1, 0, 0.75}, frames[1].borders[1].color)
    end)

    it("uses caller-supplied border opacity independently of fill opacity and resets it on reuse", function()
        local renderer = PolygonRenderer.New(canvas)
        local shapes = {{
            points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}},
            color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0.1875,
        }}

        assert.is_table(renderer:Draw(shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)

        shapes[1].borderAlpha = nil
        assert.is_table(renderer:Draw(shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.75}, frames[1].borders[1].color)
        assert.are_equal(1, #frames)
        assert.are_equal(5, #textures)
    end)

    local validBorderAlpha = {
        {name = "fully transparent", alpha = 0},
        {name = "fully opaque", alpha = 1},
    }
    for _, case in ipairs(validBorderAlpha) do
        it("accepts a " .. case.name .. " border", function()
            local renderer = PolygonRenderer.New(canvas)
            local counts = renderer:Draw({{
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
            local counts, err = renderer:Draw({{
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
        local counts, err = renderer:Draw({{
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
        renderer:Draw({{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0}}}, 100, 100, 8)
        renderer:Clear()
        renderer:Clear()
        renderer:Draw({}, 100, 100, 8)

        assert.is_false(frames[1].shown)
        assert.is_nil(frames[1].anchor)
        assert.is_false(textures[1].shown)
        assert.is_nil(textures[1].allPoints)
        assert.are_equal(1, #renderer.freeFrames)
        assert.are_equal(2, #renderer.freeFills)
        assert.are_equal(3, #renderer.freeBorders)
        assert.are_equal(0, #renderer.activeFrames)
    end)

    it("owns partially configured textures so failure cleanup cannot leak or double-pool them", function()
        local renderer = PolygonRenderer.New(canvas)
        local shapes = {{points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 15, y = 30}}, color = {1, 0, 0}}}
        failTexture = 2
        local counts, err = renderer:Draw(shapes, 100, 100, 8)

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
        assert.is_table(renderer:Draw(shapes, 100, 100, 8))
        assert.are_equal(1, #frames)
        assert.are_equal(5, #textures)
        assert.is_true(frames[1].shown)
    end)

    describe("direct polygon hover", function()
        it("enables propagated motion only, with one shared update driver", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({
                {points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 0, y = 30}}, color = {0.2, 0.4, 0.6}},
                {points = {{x = 40, y = 40}, {x = 70, y = 40}, {x = 40, y = 70}}, color = {0.2, 0.4, 0.6}},
            }, 100, 100, 8)

            assert.is_false(frames[1].mouse)
            assert.is_true(frames[1].motion)
            assert.is_true(frames[1].propagate)
            assert.is_false(frames[2].mouse)
            assert.is_true(frames[2].motion)
            assert.is_true(frames[2].propagate)
            assert.are_equal(3, #frames)
            assert.is_false(renderer.hoverDriver.mouse)
            assert.is_function(renderer.hoverDriver.scripts.OnUpdate)
            assert.is_nil(frames[1].scripts)
            assert.is_nil(frames[2].scripts)
        end)

        it("highlights every containing polygon and restores only the shape the cursor leaves", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({
                {points = {{x = 0, y = 0}, {x = 50, y = 0}, {x = 50, y = 50}, {x = 0, y = 50}}, color = {0.2, 0.4, 0.6}},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            foci = {frames[2], frames[1]}
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.highlightedFrames)
            assert.are_equal(1.8, frames[1].borders[1].line[6])
            assert.are_equal(1.8, frames[2].borders[1].line[6])

            local retainedLine = frames[1].borders[1].line
            cursorX, cursorY = 0.3, 0.3 -- In both rectangles, but no longer in the triangle.
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are_equal(retainedLine, frames[1].borders[1].line)
            assert.are_equal(1.8, frames[1].borders[1].line[6])
            assert.are_equal(1.5, frames[2].borders[1].line[6])
        end)

        it("does not highlight an obscured polygon absent from the native propagation stack", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            foci = {{}} -- A nonpropagating UI region excludes the polygon, despite its geometry containing the cursor.
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
        end)

        it("selects a participating polygon beneath a propagating nonpolygon region", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.2, 0.4, 0.6}}}, 100, 100, 8)
            local overlay = {} -- Its propagation is represented by both regions participating in the native focus stack.
            cursorX, cursorY, foci = 0.1, 0.1, {overlay, frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
            assert.are_equal(1.8, frames[1].borders[1].line[6])
        end)

        it("updates movement within one frame without enter or leave scripts, throttled to 80 ms", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            local driver = renderer.hoverDriver
            driver.scripts.OnUpdate(driver, 0.04)
            assert.are_same({}, renderer.hoveredFrames)
            driver.scripts.OnUpdate(driver, 0.04)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            cursorX, cursorY = 0.3, 0.3 -- Still in the same rectangle, but no longer in its triangle.
            driver.scripts.OnUpdate(driver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("includes exact edges and vertices in the polygon", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.2, 0.2, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            cursorX, cursorY = 0, 0
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
        end)

        it("brightens a hovered border without overriding marker fade, then restores it", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0.1875}}, 100, 100, 8)
            local fill, border = frames[1].fills[1], frames[1].borders[1]
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, border.color)
            assert.are_equal(1.8, border.line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.05}, fill.color)
            assert.are_equal(5, #textures)

            foci = {}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, border.color)
            assert.are_equal(1.5, border.line[6])
            assert.are_equal(5, #textures)
        end)

        it("keeps a transparent border invisible through selection and restoration", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0}}, 100, 100, 8)
            local border = frames[1].borders[1]
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
            assert.are_same({0.25, 0.5, 0.75, 0}, border.color)
            assert.are_equal(1.8, border.line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)

            foci = {}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({0.2, 0.4, 0.6, 0}, border.color)
            assert.are_equal(1.5, border.line[6])
        end)

        local invalidCursorCoordinates = {
            {name = "a nonnumeric X coordinate", x = false, y = 0.1},
            {name = "an infinite X coordinate", x = math.huge, y = 0.1},
            {name = "a negative infinite Y coordinate", x = 0.1, y = -math.huge},
            {name = "a NaN Y coordinate", x = 0.1, y = 0 / 0},
        }
        for _, case in ipairs(invalidCursorCoordinates) do
            it("clears selection without reading geometry for " .. case.name, function()
                local renderer = _NewHoverRenderer()
                renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                    color = {0.2, 0.4, 0.6}, borderAlpha = 0.1875}}, 100, 100, 8)
                cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
                renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
                assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

                local readMouseFoci = spy.new(function() return foci end)
                renderer.hoverInput.getMouseFoci = readMouseFoci
                cursorX, cursorY = case.x, case.y
                renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

                assert.spy(readMouseFoci).was.not_called()
                assert.are_same({}, renderer.hoveredFrames)
                assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
                assert.are_equal(1.5, frames[1].borders[1].line[6])
            end)
        end

        it("clears selection without reading geometry when a numeric cursor value is secret", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, borderAlpha = 0.1875}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            local readMouseFoci = spy.new(function() return foci end)
            renderer.hoverInput.getMouseFoci = readMouseFoci
            cursorY = 0.2
            _G.issecretvalue = function(value) return value == 0.2 end
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

            assert.spy(readMouseFoci).was.not_called()
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
        end)

        it("clears the hover when cursor coordinates become unavailable", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            cursorX, cursorY = nil, nil
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("rechecks a stationary cursor against replacement outlines on reused frames", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0, 1, 0}}}, 100, 100, 8)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames) -- Immediate recheck, without any cursor motion.
            renderer:Draw({{points = {{x = 60, y = 60}, {x = 90, y = 60}, {x = 60, y = 90}}, color = {0, 0, 1}}}, 100, 100, 8)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_equal(2, #frames) -- One reused bounding frame and the shared driver.
        end)

        it("does not redraw borders while the geometric selection stays unchanged", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            local highlightedLine = frames[1].borders[1].line

            cursorX, cursorY = 0.15, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_equal(highlightedLine, frames[1].borders[1].line)
            foci = {}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            local restoredLine = frames[1].borders[1].line
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_not.equal(highlightedLine, restoredLine)
            assert.are_equal(restoredLine, frames[1].borders[1].line)
        end)

        it("combines direct overlap hits with the separate marker highlight", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                    color = {0.2, 0.4, 0.6}, highlighted = true, borderAlpha = 0.1875},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            local markerLine = frames[1].borders[1].line
            cursorX, cursorY, foci = 0.1, 0.1, {frames[2], frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.highlightedFrames)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.hoveredFrames)
            assert.are_equal(markerLine, frames[1].borders[1].line)

            foci = {}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are_equal(markerLine, frames[1].borders[1].line)

            cursorX, cursorY = nil, nil
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are_equal(markerLine, frames[1].borders[1].line)
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, frames[1].borders[1].color)
            assert.are_equal(1.5, frames[2].borders[1].line[6])
        end)

        it("keeps marker-associated highlighting available without native hover readers", function()
            local renderer = PolygonRenderer.New(canvas)
            local shapes = {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true, borderAlpha = 0.1875}}
            renderer:Draw(shapes, 100, 100, 8)
            assert.is_false(frames[1].mouse)
            assert.is_false(frames[1].motion)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are_equal(1.8, frames[1].borders[1].line[6])
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, frames[1].borders[1].color)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)

            renderer.hoverDriver:Hide()
            assert.are_same({}, renderer.highlightedFrames)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
            renderer.hoverDriver:Show()
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are_equal(1.8, frames[1].borders[1].line[6])

            shapes[1].highlighted = false
            renderer:Draw(shapes, 100, 100, 8)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(frames[1].polygonHighlighted)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are_equal(2, #frames)
        end)

        it("keeps marker highlights without enabling unavailable motion propagation", function()
            local nativeCreateFrame = _G.CreateFrame
            _G.CreateFrame = function(...)
                local frame = nativeCreateFrame(...)
                frame.SetPropagateMouseMotion = nil
                return frame
            end
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true}}, 100, 100, 8)
            assert.is_false(frames[1].mouse)
            assert.is_false(frames[1].motion)
            assert.are_same({[frames[1]] = true}, renderer.highlightedFrames)
            assert.are_same({}, renderer.hoveredFrames)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
        end)

        it("stops on hide and resumes with an immediate check when its canvas shows again", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            local driver = renderer.hoverDriver
            driver.scripts.OnUpdate(driver, 0.08)
            driver:Hide() -- Model the inherited hide of the canvas child driver.
            assert.is_nil(driver.scripts.OnUpdate)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_equal(1.5, frames[1].borders[1].line[6])

            driver:Show()
            assert.is_function(driver.scripts.OnUpdate)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
        end)

        it("clears all highlights, input flags, references, and the driver before pooling", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.2, 0.4, 0.6}, highlighted = true},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[2], frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            local markerBorder, geometricBorder = frames[1].borders[1], frames[2].borders[1]
            renderer:Clear()
            renderer:Clear()

            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.are_same({}, renderer.hoverFrames)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_false(frames[1].mouse)
            assert.is_false(frames[1].motion)
            assert.is_false(frames[1].propagate)
            assert.is_nil(frames[1].polygonOutline)
            assert.is_nil(frames[1].polygonColor)
            assert.is_nil(frames[1].polygonHighlighted)
            assert.is_nil(frames[2].polygonHighlighted)
            assert.are_equal(1.5, markerBorder.line[6])
            assert.are_equal(1.5, geometricBorder.line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.75}, markerBorder.color)
            assert.are_equal(2, #renderer.freeFrames)
            assert.are_equal(6, #renderer.freeBorders)
        end)

        it("leaves no hover driver or marker highlight after a replacement draw fails", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            failTexture = 2
            local counts, err = renderer:Draw({{
                points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0},
            }}, 100, 100, 8)

            assert.is_nil(counts)
            assert.matches("texture configuration failed", err)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_nil(frames[1].polygonHighlighted)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are_equal(0, #renderer.activeFrames)
            assert.are_same({}, renderer.hoverFrames)
        end)

        it("stops the shared driver when a draw has no shapes", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            renderer:Draw({}, 100, 100, 8)

            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are_same({}, renderer.hoverFrames)
            assert.are_equal(0, #renderer.activeFrames)
        end)

        it("ignores hidden or previously pooled frames left in a stale focus list", function()
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY, foci = 0.1, 0.1, {frames[1]}
            frames[1]:Hide()
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)

            renderer:Clear()
            renderer:UpdateHover()
            assert.are_same({}, renderer.hoveredFrames)
            assert.is_nil(frames[1].polygonOutline)
        end)

        it("keeps frames inert when the focus-stack reader is unavailable", function()
            local renderer = PolygonRenderer.New(canvas, {getCursorPosition = function() return 0.1, 0.1 end})
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            assert.is_false(frames[1].mouse)
            assert.is_false(frames[1].motion)
            assert.is_nil(renderer.hoverDriver)
        end)

        it("keeps frames inert when motion propagation is unavailable", function()
            local nativeCreateFrame = _G.CreateFrame
            _G.CreateFrame = function(...)
                local frame = nativeCreateFrame(...)
                frame.SetPropagateMouseMotion = nil
                return frame
            end
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            assert.is_false(frames[1].mouse)
            assert.is_false(frames[1].motion)
            assert.is_nil(renderer.hoverDriver)
        end)

        it("keeps frames inert when separate mouse-motion control is unavailable", function()
            local nativeCreateFrame = _G.CreateFrame
            _G.CreateFrame = function(...)
                local frame = nativeCreateFrame(...)
                frame.EnableMouseMotion = nil
                return frame
            end
            local renderer = _NewHoverRenderer()
            renderer:Draw({{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            assert.is_false(frames[1].mouse)
            assert.is_nil(renderer.hoverDriver)
        end)
    end)

    it("rejects degenerate bounds before allocating rendering objects", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts, err = renderer:Draw({{
            points = {{x = 1, y = 1}, {x = 1, y = 2}, {x = 1, y = 3}}, color = {1, 0, 0},
        }}, 100, 100, 8)

        assert.is_nil(counts)
        assert.matches("empty bounds", err)
        assert.are_equal(0, #frames)
        assert.are_equal(0, #textures)
    end)
end)
