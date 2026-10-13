dofile("setupTests.lua")

describe("WaypointMinimap", function()
    ---@type WaypointMinimap
    local WaypointMinimap
    local QuestieWaypoints
    local saved
    local renderer
    local player, radius, rotating, facing
    local hooks, masks
    local cursor, focus, uiScale
    local WaypointHover
    local HOVER_COLOR = {0.93, 0.46, 0.13, 0.8}

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
        function frame:GetCenter() return 500, 500 end
        function frame:GetEffectiveScale() return uiScale end
        function frame:IsMouseOver() return cursor ~= nil end
        function frame:CreateMaskTexture()
            return {SetAllPoints = function() end, SetPoint = function() end, SetSize = function() end,
                SetTexture = function(self, asset) self.asset = asset end,
                SetAtlas = function(self, atlas) self.asset = atlas end}
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
        path.owner = {minimapTwin = {}}
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
            GetPlayerFacing = _G.GetPlayerFacing, GetMinimapShape = _G.GetMinimapShape,
            hooksecurefunc = _G.hooksecurefunc, C_Texture = _G.C_Texture, GetCursorPosition = _G.GetCursorPosition}
        hooks = {}
        _G.hooksecurefunc = function(_, method, hook) hooks[method] = hook end
        _G.C_Texture = nil
        player, radius, rotating, facing = {1000, 1000, 0}, 100, false, 0
        cursor, focus, uiScale = nil, nil, 1
        _G.GetCursorPosition = function() return cursor[1], cursor[2] end
        QuestieLoader:ImportModule("QuestieCompat").GetMouseFocus = function() return focus end
        WaypointHover = QuestieLoader:ImportModule("WaypointHover")
        WaypointHover.Radius = function() return 3 end
        WaypointHover.Set = spy.new(function() end)
        Questie.db.profile = {waypointWidth = 4}
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
        QuestieWaypoints.Color = function(path) return path.highlighted and HOVER_COLOR or path.color end
        QuestieWaypoints.IsHighlighted = function(path) return path.highlighted or false end
        renderer = {
            Draw = spy.new(function(_, view) return view or NewView() end),
            Restyle = spy.new(function() end),
            Release = spy.new(function(_, view) view:Hide() end),
            Clear = function() end,
        }
        QuestieLoader:ImportModule("WaypointRenderer").New = function(_, maskTextures)
            masks = maskTextures
            return renderer
        end
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
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

    it("keeps a closed patrol joined where it returns to its start when reach cuts it elsewhere", function()
        -- The far side, 600 yards away, is out of reach.
        Path({{x = 1000, y = 1000}, {x = 1050, y = 1000}, {x = 1050, y = 1600}, {x = 1000, y = 1600}, {x = 1000, y = 1000}})
        local layer = Layer()

        layer:Update()

        -- One run from the far side's corner, through the start, to the other corner.
        assert.are.equal(1, #LastRuns())
        assert.are.equal(4, #LastRuns()[1])
        assert.are_same({x = 0, y = 0}, LastRuns()[1][2])
    end)

    it("joins runs only where a closed patrol returns to its start", function()
        -- Closed, but its first segment is out of reach: its first run starts elsewhere.
        Path({{x = 1000, y = 1600}, {x = 1500, y = 1600}, {x = 1050, y = 1000}, {x = 1100, y = 1600},
            {x = 1300, y = 1600}, {x = 1000, y = 1050}, {x = 1000, y = 1600}})
        local layer = Layer()
        layer:Update()
        assert.are.equal(2, #LastRuns())

        -- Starts and ends in reach, but open.
        QuestieWaypoints.paths = {}
        Path({{x = 1000, y = 1000}, {x = 1010, y = 1000}, {x = 1010, y = 1600}, {x = 1020, y = 1600}, {x = 1020, y = 1000}})
        layer = Layer()
        layer:Update()
        assert.are.equal(2, #LastRuns())
    end)

    it("draws a route once however many icons own it, as its most visible copy", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route").minimapAlpha = 0.3
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        local layer = Layer()

        layer:Update()

        assert.spy(renderer.Draw).was.called(1)
        assert.are.equal(1, renderer.Draw.calls[1].vals[4].alpha)
    end)

    it("draws a route as its highlighted copy, then as its most visible one again", function()
        local visible = Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        local faded = Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        faded.minimapAlpha = 0.3
        local layer = Layer()
        layer:Update()

        -- QuestieWaypoints.SetHighlighted invalidates the layer, which collects the routes again.
        faded.highlighted = true
        layer.dirty = true
        layer:Update()
        local style = renderer.Restyle.calls[1].vals[3]
        assert.are_same(HOVER_COLOR, style.color)
        assert.are.equal(0.3, style.alpha)

        faded.highlighted = nil
        layer.dirty = true
        layer:Update()
        style = renderer.Restyle.calls[2].vals[3]
        assert.are_same(visible.color, style.color)
        assert.are.equal(1, style.alpha)
        -- Restyled in place, never projected again.
        assert.spy(renderer.Draw).was.called(1)
    end)

    it("restyles drawn routes for a new width setting without projecting them again", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}})
        local layer = Layer()
        layer:Update()

        -- QuestieWaypoints.Refresh invalidates the layer, which collects the routes again.
        Questie.db.profile.waypointWidth = 6
        layer.dirty = true
        layer:Update()

        assert.are.equal(6, renderer.Restyle.calls[1].vals[3].thickness)
        assert.spy(renderer.Draw).was.called(1)
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

    describe("hover", function()
        -- The cursor where HereBeDragons would draw an icon for the world point, moved right by dx
        -- minimap units. The minimap's center is at 500, 500; the cursor is in pixels, at the UI scale.
        local function CursorAt(point, dx)
            local x, y = PinPosition(point)
            cursor = {(500 + x + dx) * uiScale, (500 + y) * uiScale}
        end

        -- A patrol running north-south 50 yards from the player, 35 units off the minimap's center.
        local path, onLine
        before_each(function()
            onLine = {x = 950, y = 1000}
            path = Path({{x = 950, y = 990}, {x = 950, y = 1010}})
            focus = _G.Minimap
        end)

        it("hovers the route under the cursor as its NPC's minimap icon, and ends past the hover reach", function()
            local layer = Layer()
            CursorAt(onLine, 2)
            layer:Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", path, path.owner.minimapTwin)

            CursorAt(onLine, 4)
            layer:Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", nil, nil)
        end)

        it("hovers the route once the player walks it under a still cursor", function()
            local layer = Layer()
            -- 7 units short of the route, where it will be drawn once the player has walked.
            CursorAt(onLine, -7)
            layer:Update()
            assert.spy(WaypointHover.Set).was.not_called_with("minimap", path, path.owner.minimapTwin)

            -- 10 yards toward the route, within the drift: only the container moves, by 7 units.
            player = {990, 1000, 0}
            layer:Update()

            assert.spy(WaypointHover.Set).was.called_with("minimap", path, path.owner.minimapTwin)
        end)

        it("leaves the hover to whatever covers the minimap", function()
            local layer = Layer()
            focus = {}
            CursorAt(onLine, 0)

            layer:Update()

            assert.spy(WaypointHover.Set).was.not_called_with("minimap", path, path.owner.minimapTwin)
        end)

        it("hovers a round minimap's corners only once it is square", function()
            -- 60 units right of and above the center: in the corner, outside a round minimap.
            local corner = {x = 1000 - 60 / 0.7, y = 1000 + 60 / 0.7}
            local cornerPath = Path({{x = corner.x, y = corner.y - 10}, {x = corner.x, y = corner.y + 10}})
            local layer = Layer()
            CursorAt(corner, 0)
            layer:Update()
            assert.spy(WaypointHover.Set).was.not_called_with("minimap", cornerPath, cornerPath.owner.minimapTwin)

            _G.GetMinimapShape = function() return "SQUARE" end
            layer:Update()

            assert.spy(WaypointHover.Set).was.called_with("minimap", cornerPath, cornerPath.owner.minimapTwin)
        end)

        it("reads the cursor at the minimap's UI scale", function()
            uiScale = 2
            local layer = Layer()
            CursorAt(onLine, 2)

            layer:Update()

            assert.spy(WaypointHover.Set).was.called_with("minimap", path, path.owner.minimapTwin)
        end)

        it("hovers a shared route as the copy that shows, also once another copy is highlighted", function()
            local highlighted = Path({{x = 950, y = 990}, {x = 950, y = 1010}}, "route")
            path.route, highlighted.minimapAlpha = "route", 0.3
            local layer = Layer()
            CursorAt(onLine, 2)
            layer:Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", path, path.owner.minimapTwin)

            -- QuestieWaypoints.SetHighlighted invalidates the layer, which collects the routes again.
            highlighted.highlighted = true
            layer.dirty = true
            layer:Update()

            assert.spy(WaypointHover.Set).was.called_with("minimap", highlighted, highlighted.owner.minimapTwin)
        end)

        it("ends its hover where paths can't be drawn, and when the minimap hides", function()
            local layer = Layer()
            CursorAt(onLine, 2)
            layer:Update()

            -- Inside instances, there is no player position.
            player = {nil, nil, 0}
            layer:Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", nil)

            player = {1000, 1000, 0}
            layer:Update()
            WaypointHover.Set:clear()
            layer.root.scripts.OnHide()
            assert.spy(WaypointHover.Set).was.called_with("minimap", nil)
        end)

        it("stops after an error while hovering, although ending the hover shows the layer again", function()
            local originalError = Questie.Error
            local reportError = spy.new(function() end)
            Questie.Error = reportError
            local layer = Layer()
            -- The tooltip fails to open. Ending the hover then changes the highlight, which invalidates.
            WaypointHover.Set = function(_, hoveredPath)
                if hoveredPath then error("tooltip failed") end
                layer.root:Show()
            end
            CursorAt(onLine, 2)

            layer.root.scripts.OnUpdate()
            Questie.Error = originalError

            assert.is_false(layer.root.shown)
            assert.spy(reportError).was.called(1)
        end)
    end)

    describe("shape", function()
        local ROUND, SQUARE = "Interface\\CharacterFrame\\TempPortraitAlphaMask", "Interface\\BUTTONS\\WHITE8X8"

        it("masks with the shape a minimap addon sets, also once paths are drawn", function()
            Layer()
            assert.are.equal(ROUND, masks[1].asset)

            hooks.SetMaskTexture(_G.Minimap, "Interface\\AddOns\\SomeMinimap\\diamond")

            assert.are.equal("Interface\\AddOns\\SomeMinimap\\diamond", (WaypointMinimap.ShapeMask()))
            assert.are.equal("Interface\\AddOns\\SomeMinimap\\diamond", masks[1].asset)
        end)

        it("falls back to GetMinimapShape, with the square mask only for a square minimap", function()
            assert.are.equal(ROUND, (WaypointMinimap.ShapeMask()))
            _G.GetMinimapShape = function() return "SQUARE" end
            assert.are.equal(SQUARE, (WaypointMinimap.ShapeMask()))
            -- Square but for one round quarter: the round mask never draws past its edge.
            _G.GetMinimapShape = function() return "CORNER-TOPLEFT" end
            assert.are.equal(ROUND, (WaypointMinimap.ShapeMask()))
        end)

        it("uses Forever's own round mask where the client has it", function()
            _G.C_Texture = {GetAtlasInfo = function(atlas) return atlas == "ui-hud-minimap-frame-generic-mask" and {} or nil end}

            assert.are_same({"ui-hud-minimap-frame-generic-mask", true}, {WaypointMinimap.ShapeMask()})
        end)
    end)
end)
