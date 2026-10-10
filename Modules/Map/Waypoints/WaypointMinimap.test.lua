dofile("setupTests.lua")

describe("WaypointMinimap", function()
    ---@type WaypointMinimap
    local WaypointMinimap
    local QuestieWaypoints
    local saved
    local renderer
    local player, radius, rotating, facing

    local function NewFrame()
        local frame = {shown = true, scripts = {}, level = 5}
        function frame:SetAllPoints() end
        function frame:SetClipsChildren() end
        function frame:SetSize() end
        function frame:SetFrameLevel(level) self.level = level end
        function frame:GetFrameLevel() return self.level end
        function frame:Show() self.shown = true end
        function frame:Hide() self.shown = false end
        function frame:IsShown() return self.shown end
        function frame:ClearAllPoints() end
        function frame:SetPoint(...) self.point = {...} end
        function frame:SetScript(name, script) self.scripts[name] = script end
        function frame:GetWidth() return 140 end
        function frame:GetHeight() return 140 end
        function frame:CreateMaskTexture()
            return {SetAllPoints = function() end, SetPoint = function() end, SetSize = function() end,
                SetTexture = function() end, SetAtlas = function() end}
        end
        return frame
    end

    local function NewView()
        local view = {shown = false}
        function view:Show() self.shown = true end
        function view:Hide() self.shown = false end
        function view:IsShown() return self.shown end
        return view
    end

    -- Each path is its own route unless given one: copies of a patrol drawn by several icons share it.
    local function Path(world, route)
        local bounds = {math.huge, math.huge, -math.huge, -math.huge}
        for _, point in ipairs(world) do
            bounds = {math.min(bounds[1], point.x), math.min(bounds[2], point.y),
                math.max(bounds[3], point.x), math.max(bounds[4], point.y)}
        end
        local path = {instanceId = 0, world = world, worldBounds = bounds, color = {1, 0.72, 0, 0.5}, minimapAlpha = 1}
        path.route = route or tostring(path)
        QuestieWaypoints.paths[path] = true
        return path
    end

    local function Layer()
        local layer = WaypointMinimap.New(_G.Minimap)
        layer.root:Show()
        return layer
    end

    -- Where HereBeDragons-Pins' drawMinimapPin puts an icon for a world point, from the minimap's center.
    local function PinPosition(point)
        local xDist, yDist = player[1] - point.x, player[2] - point.y
        if rotating then
            xDist, yDist = xDist * math.cos(facing) - yDist * math.sin(facing), xDist * math.sin(facing) + yDist * math.cos(facing)
        end
        return xDist / radius * 70, -yDist / radius * 70
    end

    -- Where the layer draws a projected vertex, from the minimap's center: the container's offset plus
    -- the vertex's position in it, y down.
    local function DrawnPosition(layer, vertex)
        local point = layer.container.point
        return point[4] + vertex.x, point[5] - vertex.y
    end

    local function LastRuns()
        return renderer.Draw.calls[#renderer.Draw.calls].vals[3]
    end

    before_each(function()
        saved = {LibStub = _G.LibStub, CreateFrame = _G.CreateFrame, Minimap = _G.Minimap,
            GetPlayerFacing = _G.GetPlayerFacing, GetMinimapShape = _G.GetMinimapShape}
        player, radius, rotating, facing = {1000, 1000, 0}, 100, false, 0
        _G.CreateFrame = function() return NewFrame() end
        _G.Minimap = NewFrame()
        _G.GetPlayerFacing = function() return facing end
        _G.GetMinimapShape = nil
        _G.LibStub = function()
            return {
                GetPlayerWorldPosition = function() return player[1], player[2], player[3] end,
                GetMinimapView = function() return radius, rotating end,
            }
        end
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.paths = {}
        QuestieWaypoints.MinimapAlpha = function(path) return path.minimapAlpha end
        renderer = {
            Draw = spy.new(function(_, view) return view or NewView() end),
            Restyle = spy.new(function() end),
            Release = spy.new(function(_, view) view:Hide() end),
            Clear = function() end,
        }
        QuestieLoader:ImportModule("WaypointRenderer").New = function() return renderer end
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/Waypoints/WaypointMinimap.lua")
        WaypointMinimap = QuestieLoader:ImportModule("WaypointMinimap")
    end)

    after_each(function()
        for name, value in pairs(saved) do _G[name] = value end
    end)

    it("lines up with HereBeDragons' minimap icons while walking on a rotating minimap", function()
        local point = {x = 950, y = 1030}
        Path({point, {x = 960, y = 1030}})
        rotating, facing = true, 0.7
        local layer = Layer()
        layer:Update()

        player = {1010, 990, 0}
        layer:Update()

        local x, y = DrawnPosition(layer, LastRuns()[1][1])
        local expectedX, expectedY = PinPosition(point)
        assert.are.near(expectedX, x, 1e-9)
        assert.are.near(expectedY, y, 1e-9)
    end)

    it("draws only the segments within reach of the player", function()
        -- The first segment lies 2000 yards away; only the last two are near.
        local path = Path({{x = 3000, y = 1000}, {x = 3010, y = 1000}, {x = 1050, y = 1000}, {x = 1060, y = 1000}})
        Path({{x = 1000, y = 1000}, {x = 1010, y = 1000}}).instanceId = 1
        Path({{x = 1000, y = 1000}, {x = 1010, y = 1000}}).minimapAlpha = nil
        local layer = Layer()

        layer:Update()

        assert.spy(renderer.Draw).was.called(1)
        -- The segments from 3010 onwards reach the player and stay joined as one run.
        assert.are.equal(1, #LastRuns())
        assert.are.equal(3, #LastRuns()[1])
        assert.are.near(-2010 * 0.7, LastRuns()[1][1].x, 1e-9)
        assert.are.equal(4, renderer.Draw.calls[1].vals[4].thickness)
        assert.is_true(layer.entries[path.route].view.shown)
    end)

    it("draws a route once however many icons own it, as its most visible copy", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route").minimapAlpha = 0.3
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        local layer = Layer()

        layer:Update()

        assert.spy(renderer.Draw).was.called(1)
        assert.are.equal(1, renderer.Draw.calls[1].vals[4].alpha)
    end)

    it("only moves the container while walking, until the player drifts from where paths were projected", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}})
        local layer = Layer()
        layer:Update()

        player = {1010, 1000, 0}
        layer:Update()
        assert.spy(renderer.Draw).was.called(1)
        -- The projection's origin is 10 yards on the side HereBeDragons draws to the right.
        assert.are_same({"TOPLEFT", _G.Minimap, "CENTER", 7, -0}, layer.container.point)

        player = {1060, 1000, 0}
        layer:Update()
        assert.spy(renderer.Draw).was.called(2)
    end)

    it("draws again when a rotating minimap turns", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}})
        rotating = true
        local layer = Layer()
        layer:Update()

        facing = 1
        layer:Update()

        assert.spy(renderer.Draw).was.called(2)
    end)

    it("stops updating without paths until invalidated", function()
        local layer = Layer()

        layer:Update()

        assert.is_false(layer.root.shown)
        assert.spy(renderer.Draw).was.not_called()
    end)

    it("masks with the minimap's shape, square for square minimaps", function()
        assert.are.equal("Interface\\CharacterFrame\\TempPortraitAlphaMask", (WaypointMinimap.ShapeMask()))
        _G.GetMinimapShape = function() return "SQUARE" end
        assert.are.equal("Interface\\BUTTONS\\WHITE8X8", (WaypointMinimap.ShapeMask()))
    end)
end)
