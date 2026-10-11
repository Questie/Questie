dofile("setupTests.lua")

describe("WaypointRenderer", function()
    ---@type WaypointRenderer
    local WaypointRenderer
    ---@type WaypointGeometry
    local WaypointGeometry
    local saved
    local createdTextures, bands
    -- The client's vertex indexes (Blizzard_FrameXMLBase Constants.lua).
    local UPPER_LEFT, LOWER_LEFT, UPPER_RIGHT, LOWER_RIGHT = 1, 2, 3, 4

    local function NewTexture(parent, layer)
        local texture = {parent = parent, layer = layer, masks = {}, shown = true, points = {}, offsets = {}}
        function texture:SetSnapToPixelGrid() end
        function texture:SetTexelSnappingBias() end
        function texture:SetTexture(asset, wrapH, wrapV) self.asset, self.wrap = asset, {wrapH, wrapV} end
        function texture:AddMaskTexture(mask) table.insert(self.masks, mask) end
        function texture:SetParent(frame) self.parent = frame end
        function texture:SetVertexColor(r, g, b, a) self.color = {r, g, b, a} end
        function texture:SetPoint(point, _, _, x, y) self.points[point] = {x, y} end
        function texture:SetVertexOffset(vertex, x, y) self.offsets[vertex] = {x, y} end
        function texture:SetSize() end
        function texture:ClearAllPoints() self.points = {} end
        function texture:Show() self.shown = true end
        function texture:Hide() self.shown = false end
        table.insert(createdTextures, texture)
        return texture
    end

    local function NewFrame()
        local frame = {shown = true}
        function frame:SetPoint() end
        function frame:SetSize() end
        function frame:SetAlpha(alpha) self.alpha = alpha end
        function frame:SetFrameLevel(level) self.level = level end
        function frame:Show() self.shown = true end
        function frame:Hide() self.shown = false end
        function frame:CreateTexture(_, layer) return NewTexture(self, layer) end
        return frame
    end

    ---Where a line texture's corners land, from its box anchors and vertex offsets, as a quad in
    ---canvas units with y down: start left, start right, end left, end right.
    local function DrawnQuad(texture)
        local left, top = texture.points.TOPLEFT[1], texture.points.TOPLEFT[2]
        local right, bottom = texture.points.BOTTOMRIGHT[1], texture.points.BOTTOMRIGHT[2]
        local function corner(vertex, x, y)
            local offset = texture.offsets[vertex]
            return x + offset[1], -(y + offset[2])
        end
        local startLeftX, startLeftY = corner(UPPER_LEFT, left, top)
        local startRightX, startRightY = corner(LOWER_LEFT, left, bottom)
        local endLeftX, endLeftY = corner(UPPER_RIGHT, right, top)
        local endRightX, endRightY = corner(LOWER_RIGHT, right, bottom)
        return {startLeftX, startLeftY, startRightX, startRightY, endLeftX, endLeftY, endRightX, endRightY}
    end

    local function Style(thickness, color)
        return {thickness = thickness, color = color or {1, 0.5, 0, 0.5}, frameLevel = 10}
    end

    local TURN = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}
    local BEND = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 10 + 10 * math.cos(math.rad(45)), y = 10 * math.sin(math.rad(45))}}
    -- The line spans 12 of the texture's 16 rows; quads also cover the fade beyond it.
    local QUAD_SCALE = 16 / 12

    before_each(function()
        saved = {CreateFrame = _G.CreateFrame, DrawLine = _G.DrawLine}
        createdTextures, bands = {}, {}
        _G.UPPER_LEFT_VERTEX, _G.LOWER_LEFT_VERTEX = UPPER_LEFT, LOWER_LEFT
        _G.UPPER_RIGHT_VERTEX, _G.LOWER_RIGHT_VERTEX = UPPER_RIGHT, LOWER_RIGHT
        _G.CreateFrame = function() return NewFrame() end
        _G.DrawLine = function(texture, _, _, _, _, _, thickness) table.insert(bands, {texture = texture, thickness = thickness}) end
        Questie.db.profile.waypointSmoothing = 0.5
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
        dofile("Modules/Map/Waypoints/WaypointRenderer.lua")
        WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
        WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")
    end)

    after_each(function()
        for name, value in pairs(saved) do _G[name] = value end
    end)

    it("rounds and trims corners, then stretches the outlined texture over each segment's mitered quad, widened by the fade", function()
        local renderer = WaypointRenderer.New(NewFrame())

        local view = renderer:Draw(nil, {BEND}, Style(4))

        -- The tolerances follow the line's width; the curve fits the quads, fade included.
        local smoothed = WaypointGeometry.Smooth(BEND, Questie.db.profile.waypointSmoothing * 2, 2 * QUAD_SCALE)
        local trimmed = WaypointGeometry.Trim(smoothed, WaypointRenderer.TRIMMING * 2)
        local expected = WaypointGeometry.Quads(trimmed, 2 * QUAD_SCALE)
        assert.is_true(#expected > 2)
        assert.are.equal(#expected, #view.lines)
        for i, line in ipairs(view.lines) do
            local drawn = DrawnQuad(line)
            for k = 1, 8 do assert.are.near(expected[i][k], drawn[k], 1e-9) end
        end
        assert.is_truthy(view.lines[1].asset:find("waypoint%-line%-aa%.png$"))
        assert.are_same({1, 0.5, 0, 0.5}, view.lines[2].color)
        assert.is_false(view.shown)
    end)

    it("draws separate runs without joining them", function()
        local renderer = WaypointRenderer.New(NewFrame())

        local view = renderer:Draw(nil, {{{x = 0, y = 0}, {x = 10, y = 0}}, {{x = 10, y = 0}, {x = 10, y = 10}}}, Style(4))

        -- Unjoined, the first run keeps a square end where the second starts.
        local drawn = DrawnQuad(view.lines[1])
        assert.are.near(10, drawn[5], 1e-9)
        assert.are.near(2 * QUAD_SCALE, drawn[6], 1e-9)
    end)

    it("redraws for a new thickness but only tints for a new color", function()
        local renderer = WaypointRenderer.New(NewFrame())
        local view = renderer:Draw(nil, {TURN}, Style(4))
        local before = DrawnQuad(view.lines[1])

        renderer:Restyle(view, Style(4, {0, 1, 0, 1}))
        assert.are_same(before, DrawnQuad(view.lines[1]))
        assert.are_same({0, 1, 0, 1}, view.lines[1].color)

        renderer:Restyle(view, Style(2, {0, 1, 0, 1}))
        assert.are.near(QUAD_SCALE, DrawnQuad(view.lines[1])[2], 1e-9)
    end)

    it("pools released textures and masks each texture once", function()
        local mask = {}
        local renderer = WaypointRenderer.New(NewFrame(), {mask})
        local first = renderer:Draw(nil, {TURN}, Style(4))

        renderer:Draw(first, {{{x = 0, y = 0}, {x = 10, y = 0}}}, Style(4))
        assert.are.equal(1, #first.lines)
        local spare = createdTextures[2]
        assert.is_false(spare.shown)

        local second = renderer:Draw(nil, {{{x = 0, y = 0}, {x = 5, y = 5}}}, Style(4))
        assert.are.equal(spare, second.lines[1])
        assert.are.equal(second, spare.parent)
        assert.are.equal(2, #createdTextures)
        assert.are_same({mask}, spare.masks)
    end)

    it("draws the hover area beneath the line only while debugging", function()
        local renderer = WaypointRenderer.New(NewFrame())
        local style = Style(4)
        style.hoverRadius = 6

        local view = renderer:Draw(nil, {TURN}, style)
        assert.are.equal(2, #view.bands)
        assert.are.equal(3, #view.caps)
        assert.are.equal(12, bands[1].thickness)

        renderer:Restyle(view, Style(4))
        assert.are.equal(0, #view.bands)
        assert.are.equal(0, #view.caps)
    end)

    it("redraws every drawn path for a new smoothing setting, coloring the new pieces", function()
        Questie.db.profile.waypointSmoothing = 0
        local renderer = WaypointRenderer.New(NewFrame())
        local view = renderer:Draw(nil, {BEND}, Style(4))
        assert.are.equal(2, #view.lines)

        Questie.db.profile.waypointSmoothing = 0.5
        WaypointRenderer.RedrawAll()

        local smoothed = WaypointGeometry.Smooth(BEND, 0.5 * 2, 2 * QUAD_SCALE)
        local expected = WaypointGeometry.Quads(WaypointGeometry.Trim(smoothed, WaypointRenderer.TRIMMING * 2), 2 * QUAD_SCALE)
        assert.is_true(#expected > 2)
        assert.are.equal(#expected, #view.lines)
        for _, line in ipairs(view.lines) do
            assert.are_same({1, 0.5, 0, 0.5}, line.color)
        end
    end)

    it("returns a released view and its textures to the pools", function()
        local renderer = WaypointRenderer.New(NewFrame())
        local view = renderer:Draw(nil, {{{x = 0, y = 0}, {x = 10, y = 0}}}, Style(4))
        view:Show()

        renderer:Release(view)

        assert.is_false(view.shown)
        assert.are.equal(0, #view.lines)
        assert.are.equal(view, renderer:Draw(nil, {{{x = 0, y = 0}, {x = 1, y = 1}}}, Style(4)))
        assert.are.equal(1, #createdTextures)
    end)
end)
