dofile("setupTests.lua")

describe("WaypointRenderer", function()
    ---@type WaypointRenderer
    local WaypointRenderer
    local savedCreateFrame, savedDrawLine
    local createdTextures, drawn

    local function NewTexture(parent, layer)
        local texture = {parent = parent, layer = layer, masks = {}, shown = true}
        function texture:SetSnapToPixelGrid() end
        function texture:SetTexelSnappingBias() end
        function texture:SetTexture(asset, wrapH, wrapV) self.asset, self.wrap = asset, {wrapH, wrapV} end
        function texture:AddMaskTexture(mask) table.insert(self.masks, mask) end
        function texture:SetParent(frame) self.parent = frame end
        function texture:SetVertexColor(r, g, b, a) self.color = {r, g, b, a} end
        function texture:SetPoint() end
        function texture:SetSize() end
        function texture:ClearAllPoints() end
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

    local function Style(thickness, color)
        return {thickness = thickness, color = color or {1, 0.5, 0, 0.5}, frameLevel = 10}
    end

    before_each(function()
        savedCreateFrame, savedDrawLine = _G.CreateFrame, _G.DrawLine
        createdTextures, drawn = {}, {}
        _G.CreateFrame = function() return NewFrame() end
        _G.DrawLine = function(texture, frame, sx, sy, ex, ey, thickness)
            table.insert(drawn, {texture = texture, frame = frame, sx = sx, sy = sy, ex = ex, ey = ey, thickness = thickness})
        end
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/Waypoints/WaypointRenderer.lua")
        WaypointRenderer = QuestieLoader:ImportModule("WaypointRenderer")
    end)

    after_each(function()
        _G.CreateFrame, _G.DrawLine = savedCreateFrame, savedDrawLine
    end)

    it("pairs a polyline's points into segments", function()
        local a, b, c = {x = 0, y = 0}, {x = 1, y = 0}, {x = 2, y = 0}

        assert.are_same({a, b, b, c}, WaypointRenderer.Segments({a, b, c}))
    end)

    it("draws one outlined, clamped texture per segment with y flipped for DrawLine", function()
        local renderer = WaypointRenderer.New(NewFrame())

        local view = renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 10, y = 5}, {x = 20, y = 0}}), Style(4))

        assert.are.equal(2, #view.lines)
        assert.are.equal(2, #drawn)
        assert.are_same({0, 0, 10, -5, 4}, {drawn[1].sx, drawn[1].sy, drawn[1].ex, drawn[1].ey, drawn[1].thickness})
        assert.are.equal(view, drawn[1].frame)
        assert.is_truthy(view.lines[1].asset:find("waypoint%-line%.blp$"))
        assert.are_same({"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"}, view.lines[1].wrap)
        assert.are_same({1, 0.5, 0, 0.5}, view.lines[2].color)
        assert.is_false(view.shown)
    end)

    it("redraws for a new thickness but only tints for a new color", function()
        local renderer = WaypointRenderer.New(NewFrame())
        local view = renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 10, y = 0}}), Style(4))
        drawn = {}

        renderer:Restyle(view, Style(4, {0, 1, 0, 1}))
        assert.are.equal(0, #drawn)
        assert.are_same({0, 1, 0, 1}, view.lines[1].color)

        renderer:Restyle(view, Style(2, {0, 1, 0, 1}))
        assert.are.equal(1, #drawn)
        assert.are.equal(2, drawn[1].thickness)
    end)

    it("pools released textures and masks each texture once", function()
        local mask = {}
        local renderer = WaypointRenderer.New(NewFrame(), {mask})
        local first = renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 10, y = 0}, {x = 20, y = 0}}), Style(4))

        renderer:Draw(first, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 10, y = 0}}), Style(4))
        assert.are.equal(1, #first.lines)
        local spare = createdTextures[2]
        assert.is_false(spare.shown)

        local second = renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 5, y = 5}}), Style(4))
        assert.are.equal(spare, second.lines[1])
        assert.are.equal(second, spare.parent)
        assert.are.equal(2, #createdTextures)
        assert.are_same({mask}, spare.masks)
    end)

    it("draws the hover area beneath the line only while debugging", function()
        local renderer = WaypointRenderer.New(NewFrame())
        local style = Style(4)
        style.hoverRadius = 6

        local view = renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 10, y = 0}}), style)
        assert.are.equal(1, #view.bands)
        assert.are.equal(2, #view.caps)
        assert.are.equal(12, drawn[2].thickness)

        renderer:Restyle(view, Style(4))
        assert.are.equal(0, #view.bands)
        assert.are.equal(0, #view.caps)
    end)

    it("returns a released view and its textures to the pools", function()
        local renderer = WaypointRenderer.New(NewFrame())
        local view = renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 10, y = 0}}), Style(4))
        view:Show()

        renderer:Release(view)

        assert.is_false(view.shown)
        assert.are.equal(0, #view.lines)
        assert.are.equal(view, renderer:Draw(nil, WaypointRenderer.Segments({{x = 0, y = 0}, {x = 1, y = 1}}), Style(4)))
        assert.are.equal(1, #createdTextures)
    end)
end)
