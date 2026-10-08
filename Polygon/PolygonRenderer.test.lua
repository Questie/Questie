dofile("setupTests.lua")

describe("PolygonRenderer", function()
    local PolygonRenderer
    local originals
    local frames, textures, failTexture
    local cursorX, cursorY, onMap
    local canvas = {}

    -- Fresh-view setup for the primitive/hover contract tests. Retention tests below
    -- call Create/Configure/Style/SetVisibleFrames directly without wholesale cleanup.
    local function _Draw(renderer, shapes, width, height, level)
        renderer:Clear()
        local counts = {regions = #shapes, fills = 0, borders = 0}
        local ok, err = pcall(function()
            local views = {}
            for _, shape in ipairs(shapes) do
                local view = renderer:Create(shape, width, height, level)
                views[#views + 1] = view
                counts.fills, counts.borders = counts.fills + #view.fills, counts.borders + #view.borders
            end
            renderer:SetVisibleFrames(views)
        end)
        if not ok then
            renderer:Clear()
            return nil, tostring(err)
        end
        return counts
    end

    local function _NewHoverRenderer()
        return PolygonRenderer.New(canvas, {
            getCursorPosition = function() return cursorX, cursorY end,
            isCursorOnMap = function() return onMap end,
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
        cursorX, cursorY, onMap = nil, nil, true
        originals = {
            CreateFrame = _G.CreateFrame, DrawLine = _G.DrawLine, issecretvalue = _G.issecretvalue, random = math.random,
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
        PolygonRenderer.debugRandomColors = false
    end)

    after_each(function()
        PolygonRenderer.debugRandomColors = false
        math.random = originals.random
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
        assert.are_same({frames[1], 0, 0, 200, 0, 1.5, 1, "TOPLEFT"}, textures[3].line)
        assert.are_same({frames[1], 0, -150, 0, 0, 1.5, 1, "TOPLEFT"}, textures[6].line)
        assert.are_equal("Interface\\BUTTONS\\WHITE8X8", textures[1].path)
        assert.is_false(textures[1].snap)
        assert.are_equal(0, textures[1].bias)
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

        cursorX, cursorY = 0.15, 0.1
        renderer:UpdateHover()
        assert.are_same({0.546875, 0.625, 0.703125, 0.1875}, frames[1].borders[1].color)
        assert.are_equal(1.8, frames[1].borders[1].line[6])
        cursorX, cursorY = 0.9, 0.9
        renderer:UpdateHover()
        assert.are_same({0.4375, 0.5, 0.5625, 0.1875}, frames[1].borders[1].color)
        assert.are_equal(1.5, frames[1].borders[1].line[6])
        assert.are_equal(15, randomCalls)

        PolygonRenderer.debugRandomColors = false
        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
        assert.is_nil(frames[1].borders[1].polygonDebugColor)
        assert.are_equal(15, randomCalls)
    end)

    it("closes an odd fan with a degenerate quad rather than an extra outer edge", function()
        local renderer = PolygonRenderer.New(canvas)
        local counts = _Draw(renderer, {{
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
        local counts = _Draw(renderer, {
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
        _Draw(renderer, shapes, 100, 100, 8)
        shapes[1].color = {0, 1, 0, 0.4}
        local counts = _Draw(renderer, shapes, 200, 300, 10)

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

        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
        assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)
        assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)

        shapes[1].borderAlpha = nil
        assert.is_table(_Draw(renderer, shapes, 100, 100, 8))
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
        assert.are_equal(3, #renderer.freeBorders)
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
        assert.are_equal(5, #textures)
        assert.is_true(frames[1].shown)
    end)

    describe("retained views", function()
        local triangle

        before_each(function()
            triangle = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.2, 0.4, 0.6, 0.25}}
        end)

        it("creates a hidden owned view and shows it without configuring its primitives again", function()
            local renderer = PolygonRenderer.New(canvas)
            local view = renderer:Create(triangle, 100, 100, 8)
            assert.is_false(view:IsShown())
            assert.is_true(renderer.ownedFrames[view])
            local offsets, line = view.fills[1].offsets, view.borders[1].line
            local configure = spy.on(view.fills[1], "SetVertexOffset")
            local uv = spy.on(view.fills[1], "SetTexCoord")
            renderer:SetVisibleFrames({view})
            renderer:SetVisibleFrames({view})
            assert.is_true(view:IsShown())
            assert.are.equal(offsets, view.fills[1].offsets)
            assert.are.equal(line, view.borders[1].line)
            assert.spy(configure).was.not_called()
            assert.spy(uv).was.not_called()
            assert.are.equal(1, #frames)
            assert.are.equal(5, #textures)
        end)

        it("retains hidden views and excludes them from hover until shown again", function()
            local renderer = _NewHoverRenderer()
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            cursorX, cursorY = 0.1, 0.1
            renderer:UpdateHover()
            assert.is_true(renderer.highlightedFrames[view])
            local offsets = view.fills[1].offsets
            renderer:SetVisibleFrames({})
            assert.is_false(view:IsShown())
            assert.is_true(renderer.ownedFrames[view])
            assert.are.same({}, renderer.highlightedFrames)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are.equal(0, #renderer.freeFrames)
            renderer:UpdateHover() -- The cursor is still inside the outline, but the view is not visible.
            assert.are.same({}, renderer.highlightedFrames)
            renderer:SetVisibleFrames({view})
            assert.is_true(view:IsShown())
            assert.is_true(renderer.highlightedFrames[view])
            assert.are.equal(offsets, view.fills[1].offsets)
            assert.are.equal(2, #frames) -- View plus one shared driver.
        end)

        it("changes a marker highlight without touching fills or restarting the hover driver", function()
            local renderer = _NewHoverRenderer()
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            local driver = renderer.hoverDriver
            local updateCallback = driver.scripts.OnUpdate
            local vertices = spy.on(view.fills[1], "SetVertexOffset")
            local fills = spy.on(view.fills[1], "SetVertexColor")
            local anchors = spy.on(view, "SetPoint")
            local oldLine = view.borders[1].line
            triangle.highlighted = true
            renderer:Style(view, triangle, 8)
            renderer:SetVisibleFrames({view})
            assert.are.equal(1.8, view.borders[1].line[6])
            assert.are_not.equal(oldLine, view.borders[1].line)
            assert.spy(vertices).was.not_called()
            assert.spy(fills).was.not_called()
            assert.spy(anchors).was.not_called()
            assert.are.equal(updateCallback, driver.scripts.OnUpdate)

            local selectedLine = view.borders[1].line
            renderer:Style(view, triangle, 8)
            renderer:SetVisibleFrames({view})
            assert.are.equal(selectedLine, view.borders[1].line)
            assert.are.equal(updateCallback, driver.scripts.OnUpdate)
        end)

        it("checks hover only when the cursor's canvas position changes", function()
            local renderer = _NewHoverRenderer()
            local view = renderer:Create(triangle, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer:SetVisibleFrames({view})
            assert.is_true(renderer.hoveredFrames[view])
            local isCursorOnMap = spy.on(renderer.hoverInput, "isCursorOnMap")
            local driver = renderer.hoverDriver
            driver.scripts.OnUpdate(driver, 0.016)
            assert.spy(isCursorOnMap).was.not_called()

            -- Panning or zooming under a still cursor also changes its canvas position.
            cursorX = 0.5
            driver.scripts.OnUpdate(driver, 0.016)
            assert.spy(isCursorOnMap).was.called(1)
            assert.are.same({}, renderer.hoveredFrames)
        end)

        it("updates color, faded opacity, and frame level without repeating border geometry", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            local line, offsets = view.borders[1].line, view.fills[1].offsets
            triangle.color, triangle.borderAlpha = {0.4, 0.2, 0.1, 0.05}, 0.1875
            renderer:Style(view, triangle, 12)
            renderer:SetVisibleFrames({view})
            assert.are.same({0.4, 0.2, 0.1, 0.05}, view.fills[1].color)
            assert.are.same({0.5, 0.25, 0.125, 0.1875}, view.borders[1].color)
            assert.are.equal(line, view.borders[1].line)
            assert.are.equal(offsets, view.fills[1].offsets)
            assert.are.equal(12, view.level)
        end)

        it("keeps direct hover highlighted after the marker highlight is withdrawn", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            cursorX, cursorY = 0.1, 0.1
            renderer:UpdateHover()
            local line = view.borders[1].line
            triangle.highlighted = false
            renderer:Style(view, triangle, 8)
            renderer:SetVisibleFrames({view})
            assert.is_true(renderer.hoveredFrames[view])
            assert.is_true(renderer.highlightedFrames[view])
            assert.are.equal(line, view.borders[1].line)
        end)

        it("reconfigures canvas size using the same frames, primitives, and diagnostic colors", function()
            PolygonRenderer.debugRandomColors = true
            local renderer = PolygonRenderer.New(canvas)
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            local fill, border = view.fills[1], view.borders[1]
            local fillTint, borderTint = fill.polygonDebugColor, border.polygonDebugColor
            math.random = function() error("retained primitives must not choose a new color") end
            renderer:Configure(view, triangle, 200, 300, 8)
            renderer:SetVisibleFrames({view})
            assert.are.equal(fill, view.fills[1])
            assert.are.equal(border, view.borders[1])
            assert.are.equal(fillTint, fill.polygonDebugColor)
            assert.are.equal(borderTint, border.polygonDebugColor)
            assert.are.equal(80, view.width)
            assert.are.equal(120, view.height)
            assert.are.equal(1, #frames)
            assert.are.equal(5, #textures)
        end)

        it("retains diagnostic colors through appearance updates and hide/show", function()
            PolygonRenderer.debugRandomColors = true
            local renderer = PolygonRenderer.New(canvas)
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            local tint = view.fills[1].polygonDebugColor
            math.random = function() error("style/show must not choose new colors") end
            triangle.color = {1, 0, 0, 0.1}
            renderer:Style(view, triangle, 8)
            renderer:SetVisibleFrames({})
            renderer:SetVisibleFrames({view})
            assert.are.equal(tint, view.fills[1].polygonDebugColor)
            assert.are.same({tint[1], tint[2], tint[3], 0.1}, view.fills[1].color)
        end)

        it("releases one retained view without disturbing the other and pools it only once", function()
            local renderer = _NewHoverRenderer()
            local first = renderer:Create(triangle, 100, 100, 8)
            local second = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({first, second})
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
            assert.are.equal(3, #renderer.freeBorders)
            local replacement = renderer:Create(triangle, 100, 100, 8)
            assert.are.equal(first, replacement)
            assert.are.equal(3, #frames) -- Two views and one driver, no extra view allocation.
        end)

        it("clears visible and hidden owned views and reuses their pools", function()
            local renderer = PolygonRenderer.New(canvas)
            local first = renderer:Create(triangle, 100, 100, 8)
            local second = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({first})
            renderer:Clear()
            renderer:Clear()
            assert.is_nil(first.polygonOutline)
            assert.is_nil(second.polygonOutline)
            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(2, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeFills)
            assert.are.equal(6, #renderer.freeBorders)
            renderer:Create(triangle, 100, 100, 8)
            assert.are.equal(2, #frames)
            assert.are.equal(10, #textures)
        end)

        it("releases excess primitives when a configured view becomes smaller", function()
            local renderer = PolygonRenderer.New(canvas)
            local square = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 40, y = 40}, {x = 0, y = 40}}, color = {1, 0, 0}}
            local view = renderer:Create(square, 100, 100, 8)
            local border = view.borders[4]
            renderer:Configure(view, triangle, 100, 100, 8)
            assert.are.equal(3, #view.borders)
            assert.are.equal(1, #renderer.freeBorders)
            assert.is_false(border.shown)
            assert.is_nil(border.polygonStartX)
            assert.is_nil(border.polygonDebugColor)
        end)

        it("can clear ownership after a native style call keeps failing", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            view.borders[1].SetVertexColor = function() error("native color failure") end
            triangle.color = {1, 0, 0, 0.25}
            assert.has_error(function() renderer:Style(view, triangle, 8) end, "native color failure")

            renderer:Clear()
            renderer:Clear()

            assert.are.same({}, renderer.ownedFrames)
            assert.are.same({}, renderer.highlightedFrames)
            assert.are.equal(1, #renderer.freeFrames)
            assert.are.equal(3, #renderer.freeBorders)
            assert.is_false(view:IsShown())
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
        end)

        it("keeps a failed creation owned while clearing other views, then retries cleanup without double-pooling", function()
            local renderer = _NewHoverRenderer()
            local first = renderer:Create(triangle, 100, 100, 8)
            local second = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({first, second})
            local nativeCreateFrame = _G.CreateFrame
            _G.CreateFrame = function(...)
                local frame = nativeCreateFrame(...)
                frame.ClearAllPoints = function() error("native anchor failure") end
                return frame
            end

            assert.has_error(function() renderer:Create(triangle, 100, 100, 8) end, "native anchor failure")
            local failed = frames[#frames]
            assert.is_true(renderer.ownedFrames[failed])
            assert.has_error(function() renderer:Clear() end, "native anchor failure")

            assert.are.same({[failed] = true}, renderer.ownedFrames)
            assert.are.same({}, renderer.activeFrames)
            assert.are.same({}, renderer.highlightedFrames)
            assert.is_false(first:IsShown())
            assert.is_false(second:IsShown())
            assert.is_false(failed:IsShown())
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are.equal(2, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeFills)
            assert.are.equal(6, #renderer.freeBorders)
            renderer:UpdateHover()
            assert.are.same({}, renderer.hoveredFrames)

            failed.ClearAllPoints = function(self) self.anchor = nil end
            renderer:Clear()
            renderer:Clear()

            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(3, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeFills)
            assert.are.equal(6, #renderer.freeBorders)
        end)

        it("keeps a failed visible release hidden and out of hover until cleanup succeeds", function()
            local renderer = _NewHoverRenderer()
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            cursorX, cursorY = 0.1, 0.1
            view.ClearAllPoints = function() error("native anchor failure") end

            assert.has_error(function() renderer:Release(view) end, "native anchor failure")

            assert.is_false(view:IsShown())
            assert.is_true(renderer.ownedFrames[view])
            assert.are.equal(0, #renderer.freeFrames)
            assert.are.same({}, renderer.activeFrames)
            assert.are.same({}, renderer.highlightedFrames)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
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
            triangle.highlighted = true
            local view = renderer:Create(triangle, 100, 100, 8)
            renderer:SetVisibleFrames({view})
            failTexture = 6 -- The extra border acquired when growing from triangle to square.
            local square = {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 40, y = 40}, {x = 0, y = 40}}, color = {1, 0, 0}}
            assert.has_error(function() renderer:Configure(view, square, 100, 100, 8) end, "texture configuration failed")
            local unfinished = view.borders[4]
            local redrawn = {}
            _G.DrawLine = function(texture, _, startX, startY, endX, endY)
                redrawn[#redrawn + 1] = {texture = texture, startX = startX, startY = startY, endX = endX, endY = endY}
            end
            renderer:Clear()
            renderer:Clear()
            -- Assert outside the renderer's protected cleanup, which catches native errors.
            assert.are.equal(3, #redrawn)
            for _, line in ipairs(redrawn) do
                assert.are_not.equal(unfinished, line.texture)
                assert.is_number(line.startX)
                assert.is_number(line.startY)
                assert.is_number(line.endX)
                assert.is_number(line.endY)
            end
            assert.are.same({}, renderer.ownedFrames)
            assert.are.equal(1, #renderer.freeFrames)
            assert.are.equal(4, #renderer.freeBorders)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
        end)
    end)

    describe("direct polygon hover", function()
        it("follows the cursor with one shared driver and no per-polygon scripts", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 30, y = 0}, {x = 0, y = 30}}, color = {0.2, 0.4, 0.6}},
                {points = {{x = 40, y = 40}, {x = 70, y = 40}, {x = 40, y = 70}}, color = {0.2, 0.4, 0.6}},
            }, 100, 100, 8)

            assert.are_equal(3, #frames)
            assert.is_function(renderer.hoverDriver.scripts.OnUpdate)
            assert.is_nil(frames[1].scripts)
            assert.is_nil(frames[2].scripts)
        end)

        it("highlights every containing polygon and restores only the shape the cursor leaves", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 50, y = 0}, {x = 50, y = 50}, {x = 0, y = 50}}, color = {0.2, 0.4, 0.6}},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
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

        it("does not highlight a polygon while other UI covers the map under the cursor", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            onMap = false -- Covered, despite the outline containing the cursor.
            cursorX = 0.11
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
        end)

        it("follows the outline rather than the frame's rectangle, without enter or leave scripts", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            local driver = renderer.hoverDriver
            driver.scripts.OnUpdate(driver, 0.016)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            cursorX, cursorY = 0.3, 0.3 -- Still in the same rectangle, but no longer in its triangle.
            driver.scripts.OnUpdate(driver, 0.016)
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("includes exact edges and vertices in the polygon", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.2, 0.2
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            cursorX, cursorY = 0, 0
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            cursorX, cursorY = 0.4, 0 -- On the outline's bounding-box edge as well.
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
        end)

        it("brightens a hovered border without overriding marker fade, then restores it", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0.1875}}, 100, 100, 8)
            local fill, border = frames[1].fills[1], frames[1].borders[1]
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({0.25, 0.5, 0.75, 0.1875}, border.color)
            assert.are_equal(1.8, border.line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.05}, fill.color)
            assert.are_equal(5, #textures)

            cursorX, cursorY = 0.9, 0.9
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, border.color)
            assert.are_equal(1.5, border.line[6])
            assert.are_equal(5, #textures)
        end)

        it("keeps a transparent border invisible through selection and restoration", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6, 0.05}, borderAlpha = 0}}, 100, 100, 8)
            local border = frames[1].borders[1]
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
            assert.are_same({0.25, 0.5, 0.75, 0}, border.color)
            assert.are_equal(1.8, border.line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.05}, frames[1].fills[1].color)

            cursorX, cursorY = 0.9, 0.9
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
                _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                    color = {0.2, 0.4, 0.6}, borderAlpha = 0.1875}}, 100, 100, 8)
                cursorX, cursorY = 0.1, 0.1
                renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
                assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

                local isCursorOnMap = spy.on(renderer.hoverInput, "isCursorOnMap")
                cursorX, cursorY = case.x, case.y
                renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

                assert.spy(isCursorOnMap).was.not_called()
                assert.are_same({}, renderer.hoveredFrames)
                assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
                assert.are_equal(1.5, frames[1].borders[1].line[6])
            end)
        end

        it("clears selection without reading geometry when a numeric cursor value is secret", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, borderAlpha = 0.1875}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)

            local isCursorOnMap = spy.on(renderer.hoverInput, "isCursorOnMap")
            cursorY = 0.2
            _G.issecretvalue = function(value) return value == 0.2 end
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)

            assert.spy(isCursorOnMap).was.not_called()
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
        end)

        it("clears the hover when cursor coordinates become unavailable", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            cursorX, cursorY = nil, nil
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("rechecks a stationary cursor against replacement outlines on reused frames", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
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
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            local highlightedLine = frames[1].borders[1].line

            cursorX, cursorY = 0.15, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_equal(highlightedLine, frames[1].borders[1].line)
            cursorX, cursorY = 0.9, 0.9
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            local restoredLine = frames[1].borders[1].line
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_not.equal(highlightedLine, restoredLine)
            assert.are_equal(restoredLine, frames[1].borders[1].line)
        end)

        it("combines direct overlap hits with the separate marker highlight", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                    color = {0.2, 0.4, 0.6}, highlighted = true, borderAlpha = 0.1875},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            local markerLine = frames[1].borders[1].line
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.highlightedFrames)
            assert.are_same({[frames[1]] = true, [frames[2]] = true}, renderer.hoveredFrames)
            assert.are_equal(markerLine, frames[1].borders[1].line)

            cursorX, cursorY = 0.9, 0.9
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

        it("keeps marker-associated highlighting available without a hover input", function()
            local renderer = PolygonRenderer.New(canvas)
            local shapes = {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true, borderAlpha = 0.1875}}
            _Draw(renderer, shapes, 100, 100, 8)
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
            _Draw(renderer, shapes, 100, 100, 8)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(frames[1].polygonHighlighted)
            assert.are_equal(1.5, frames[1].borders[1].line[6])
            assert.are_same({0.2, 0.4, 0.6, 0.1875}, frames[1].borders[1].color)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are_equal(2, #frames)
        end)

        it("stops on inherited hide and resumes while the driver's own shown flag remains set", function()
            local parent = {visible = true, IsVisible = function(self) return self.visible end}
            local renderer = PolygonRenderer.New(parent, {
                getCursorPosition = function() return cursorX, cursorY end,
                isCursorOnMap = function() return onMap end,
            })
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            local driver = renderer.hoverDriver
            driver.scripts.OnUpdate(driver, 0.08)

            -- Native inherited visibility fires scripts without changing IsShown().
            parent.visible = false
            driver.scripts.OnHide(driver)
            assert.is_true(driver:IsShown())
            assert.is_false(driver:IsVisible())
            assert.is_nil(driver.scripts.OnUpdate)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_equal(1.5, frames[1].borders[1].line[6])

            parent.visible = true
            driver.scripts.OnShow(driver)
            assert.is_true(driver:IsShown())
            assert.is_true(driver:IsVisible())
            assert.is_function(driver.scripts.OnUpdate)
            assert.are_same({[frames[1]] = true}, renderer.hoveredFrames)
        end)

        it("clears highlights, references, and the driver before pooling", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.2, 0.4, 0.6}, highlighted = true},
                {points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {0.6, 0.4, 0.2}},
            }, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            local markerBorder, geometricBorder = frames[1].borders[1], frames[2].borders[1]
            renderer:Clear()
            renderer:Clear()

            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_nil(frames[1].polygonOutline)
            assert.is_nil(frames[1].polygonBounds)
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
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {0.2, 0.4, 0.6}, highlighted = true}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            failTexture = 2
            local counts, err = _Draw(renderer, {{
                points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0},
            }}, 100, 100, 8)

            assert.is_nil(counts)
            assert.matches("texture configuration failed", err)
            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_nil(frames[1].polygonHighlighted)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are_equal(0, #renderer.activeFrames)
        end)

        it("stops the shared driver when a draw has no shapes", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
            _Draw(renderer, {}, 100, 100, 8)

            assert.are_same({}, renderer.hoveredFrames)
            assert.are_same({}, renderer.highlightedFrames)
            assert.is_false(renderer.hoverDriver.shown)
            assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
            assert.are_equal(0, #renderer.activeFrames)
        end)

        it("does not read the cursor without visible polygons", function()
            -- Blizzard's normalization divides by the canvas width, zero before the map's first layout.
            local renderer = PolygonRenderer.New(canvas, {
                getCursorPosition = function() error("Division by zero") end,
                isCursorOnMap = function() return onMap end,
            })
            renderer:SetVisibleFrames({})
            renderer:UpdateHover()
            local view = renderer:Create({points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}},
                color = {1, 0, 0}}, 100, 100, 8)
            renderer:SetVisibleFrames({})
            renderer:Release(view)
            renderer:Clear()
            assert.are_same({}, renderer.hoveredFrames)
        end)

        it("ignores hidden or pooled frames under the cursor", function()
            local renderer = _NewHoverRenderer()
            _Draw(renderer, {{points = {{x = 0, y = 0}, {x = 40, y = 0}, {x = 0, y = 40}}, color = {1, 0, 0}}}, 100, 100, 8)
            cursorX, cursorY = 0.1, 0.1
            frames[1]:Hide()
            renderer.hoverDriver.scripts.OnUpdate(renderer.hoverDriver, 0.08)
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
