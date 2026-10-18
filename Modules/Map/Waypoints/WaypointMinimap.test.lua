dofile("setupTests.lua")

describe("WaypointMinimap", function()
    ---@type WaypointMinimap
    local WaypointMinimap
    local QuestieWaypoints
    local saved, savedCompat
    local renderer, views
    local player, radius, rotating, facing
    local cursor, focus
    local root, layer, claims
    local WaypointHover
    local HOVER_COLOR = {0.93, 0.46, 0.13, 0.8}

    local function NewFrame(parent)
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
        function frame:GetEffectiveScale() return 1 end
        function frame:IsMouseOver() return cursor ~= nil end
        function frame:CreateMaskTexture()
            return {SetAllPoints = function() end, SetPoint = function() end, SetSize = function() end,
                SetTexture = function(self, asset) self.asset = asset end,
                SetAtlas = function(self, atlas) self.asset = atlas end}
        end
        -- The canvas's root is the first frame created on the minimap.
        if parent ~= nil and parent == _G.Minimap and not root then root = frame end
        return frame
    end

    local function NewView()
        local view = {shown = false}
        function view:Show() self.shown = true end
        function view:Hide() self.shown = false end
        function view:IsShown() return self.shown end
        views[#views + 1] = view
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

    ---Starts the paths layer on the canvas, as the first path's Invalidate does.
    local function Start()
        WaypointMinimap.Invalidate()
    end

    ---One canvas update.
    local function Update()
        root.scripts.OnUpdate(root)
    end

    -- Where HereBeDragons-Pins' drawMinimapPin puts an icon for a world point, from the minimap's center.
    local function PinPosition(point)
        local xDist, yDist = player[1] - point.x, player[2] - point.y
        if rotating then
            xDist, yDist = xDist * math.cos(facing) - yDist * math.sin(facing), xDist * math.sin(facing) + yDist * math.cos(facing)
        end
        return xDist / radius * 70, -yDist / radius * 70
    end

    local function LastRuns()
        return renderer.Draw.calls[#renderer.Draw.calls].vals[3]
    end

    before_each(function()
        saved = {LibStub = _G.LibStub, CreateFrame = _G.CreateFrame, Minimap = _G.Minimap,
            GetPlayerFacing = _G.GetPlayerFacing, GetMinimapShape = _G.GetMinimapShape,
            hooksecurefunc = _G.hooksecurefunc, C_Texture = _G.C_Texture, GetCursorPosition = _G.GetCursorPosition}
        _G.hooksecurefunc = function() end
        _G.C_Texture = nil
        player, radius, rotating, facing = {1000, 1000, 0}, 100, false, 0
        cursor, focus, root, views, claims = nil, nil, nil, {}, {}
        _G.GetCursorPosition = function() return cursor[1], cursor[2] end
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        savedCompat = {GetMouseFocus = QuestieCompat.GetMouseFocus, IsGamepadUIEnabled = QuestieCompat.IsGamepadUIEnabled}
        QuestieCompat.GetMouseFocus = function() return focus end
        QuestieCompat.IsGamepadUIEnabled = function() return false end
        WaypointHover = QuestieLoader:ImportModule("WaypointHover")
        WaypointHover.Radius = function() return 3 end
        WaypointHover.Set = spy.new(function() end)
        Questie.db.profile = {waypointWidth = 4}
        _G.CreateFrame = function(_, _, parent) return NewFrame(parent) end
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
            Clear = spy.new(function() end),
        }
        QuestieLoader:ImportModule("WaypointRenderer").New = function() return renderer end
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
        dofile("Modules/Map/MinimapCanvas.lua")
        -- The layer the paths add to the canvas, recording whether each hover claims the cursor.
        local MinimapCanvas = QuestieLoader:ImportModule("MinimapCanvas")
        local addLayer = MinimapCanvas.AddLayer
        MinimapCanvas.AddLayer = function(name, added)
            layer = added
            local hover = added.Hover
            added.Hover = function(...)
                local claimed = hover(...)
                claims[#claims + 1] = claimed
                return claimed
            end
            return addLayer(name, added)
        end
        dofile("Modules/Map/Waypoints/WaypointMinimap.lua")
        WaypointMinimap = QuestieLoader:ImportModule("WaypointMinimap")
    end)

    after_each(function()
        for name, value in pairs(saved) do _G[name] = value end
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetMouseFocus, QuestieCompat.IsGamepadUIEnabled = savedCompat.GetMouseFocus, savedCompat.IsGamepadUIEnabled
    end)

    it("draws only the segments within reach of the player", function()
        -- The first segment lies 2000 yards away; only the last two are near.
        Path({{x = 3000, y = 1000}, {x = 3010, y = 1000}, {x = 1050, y = 1000}, {x = 1060, y = 1000}})
        Path({{x = 1000, y = 1000}, {x = 1010, y = 1000}}).instanceId = 1
        Path({{x = 1000, y = 1000}, {x = 1010, y = 1000}}).minimapAlpha = nil
        Start()

        Update()

        assert.spy(renderer.Draw).was.called(1)
        -- The segments from 3010 onwards reach the player and stay joined as one run.
        assert.are.equal(1, #LastRuns())
        assert.are.equal(3, #LastRuns()[1])
        assert.are.near(-2010 * 0.7, LastRuns()[1][1].x, 1e-9)
        assert.are.equal(4, renderer.Draw.calls[1].vals[4].thickness)
        assert.is_true(views[1].shown)
    end)


    it("keeps a closed patrol joined where it returns to its start when reach cuts it elsewhere", function()
        -- The far side, 600 yards away, is out of reach.
        Path({{x = 1000, y = 1000}, {x = 1050, y = 1000}, {x = 1050, y = 1600}, {x = 1000, y = 1600}, {x = 1000, y = 1000}})
        Start()

        Update()

        -- One run from the far side's corner, through the start, to the other corner.
        assert.are.equal(1, #LastRuns())
        assert.are.equal(4, #LastRuns()[1])
        assert.are_same({x = 0, y = 0}, LastRuns()[1][2])
    end)


    it("joins runs only where a closed patrol returns to its start", function()
        -- Closed, but its first segment is out of reach: its first run starts elsewhere.
        Path({{x = 1000, y = 1600}, {x = 1500, y = 1600}, {x = 1050, y = 1000}, {x = 1100, y = 1600},
            {x = 1300, y = 1600}, {x = 1000, y = 1050}, {x = 1000, y = 1600}})
        Start()
        Update()
        assert.are.equal(2, #LastRuns())

        -- Starts and ends in reach, but open.
        QuestieWaypoints.paths = {}
        Path({{x = 1000, y = 1000}, {x = 1010, y = 1000}, {x = 1010, y = 1600}, {x = 1020, y = 1600}, {x = 1020, y = 1000}})
        WaypointMinimap.Invalidate()
        Update()
        assert.are.equal(2, #LastRuns())
    end)


    it("draws a route once however many icons own it, as its most visible copy", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route").minimapAlpha = 0.3
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        Start()

        Update()

        assert.spy(renderer.Draw).was.called(1)
        assert.are.equal(1, renderer.Draw.calls[1].vals[4].alpha)
    end)


    it("draws a route as its highlighted copy, then as its most visible one again", function()
        local visible = Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        local faded = Path({{x = 950, y = 1000}, {x = 950, y = 1010}}, "route")
        faded.minimapAlpha = 0.3
        Start()
        Update()

        -- QuestieWaypoints.SetHighlighted invalidates the layer, which collects the routes again.
        faded.highlighted = true
        WaypointMinimap.Invalidate()
        Update()
        local style = renderer.Restyle.calls[1].vals[3]
        assert.are_same(HOVER_COLOR, style.color)
        assert.are.equal(0.3, style.alpha)

        faded.highlighted = nil
        WaypointMinimap.Invalidate()
        Update()
        style = renderer.Restyle.calls[2].vals[3]
        assert.are_same(visible.color, style.color)
        assert.are.equal(1, style.alpha)
        -- Restyled in place, never projected again.
        assert.spy(renderer.Draw).was.called(1)
    end)


    it("restyles drawn routes for a new width setting without projecting them again", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}})
        Start()
        Update()

        -- QuestieWaypoints.Refresh invalidates the layer, which collects the routes again.
        Questie.db.profile.waypointWidth = 6
        WaypointMinimap.Invalidate()
        Update()

        assert.are.equal(6, renderer.Restyle.calls[1].vals[3].thickness)
        assert.spy(renderer.Draw).was.called(1)
    end)

    it("lets the canvas idle while no route shows", function()
        Start()
        Update()
        assert.is_false(root.shown)
    end)

    it("hides its routes while there is no position to draw around, and shows them again after", function()
        Path({{x = 950, y = 1000}, {x = 950, y = 1010}})
        Start()
        Update()
        assert.is_true(views[1].shown)

        -- Inside instances, there is no player position.
        player = {nil, nil, 0}
        Update()
        assert.is_false(views[1].shown)

        player = {1000, 1000, 0}
        Update()
        assert.is_true(views[1].shown)
    end)

    it("releases every drawing and ends its hover when the canvas clears it after an error", function()
        Start()
        layer.Clear()

        assert.spy(renderer.Clear).was.called(1)
        assert.spy(WaypointHover.Set).was.called_with("minimap", nil)
    end)

    it("releases its drawings even when ending its hover fails", function()
        Start()
        WaypointHover.Set = function() error("tooltip failed") end

        assert.has_error(function() layer.Clear() end)
        assert.spy(renderer.Clear).was.called(1)
    end)

    describe("hover", function()
        -- The cursor where HereBeDragons would draw an icon for the world point, moved right by dx
        -- minimap units. The minimap's center is at 500, 500.
        local function CursorAt(point, dx)
            local x, y = PinPosition(point)
            cursor = {500 + x + dx, 500 + y}
        end

        -- A patrol running north-south 50 yards from the player, 35 units off the minimap's center.
        local path, onLine
        before_each(function()
            onLine = {x = 950, y = 1000}
            path = Path({{x = 950, y = 990}, {x = 950, y = 1010}})
            focus = _G.Minimap
        end)

        it("hovers the route under the cursor as its NPC's minimap icon, and ends past the hover reach", function()
            Start()
            CursorAt(onLine, 2)
            Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", path, path.owner.minimapTwin)

            CursorAt(onLine, 4)
            Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", nil, nil)
            -- The path claims the cursor on the line, and not past the reach, so a layer beneath may have it.
            assert.are.same({true, false}, claims)
        end)

        it("hovers a shared route as the copy that shows, also once another copy is highlighted", function()
            local highlighted = Path({{x = 950, y = 990}, {x = 950, y = 1010}}, "route")
            path.route, highlighted.minimapAlpha = "route", 0.3
            Start()
            CursorAt(onLine, 2)
            Update()
            assert.spy(WaypointHover.Set).was.called_with("minimap", path, path.owner.minimapTwin)

            -- QuestieWaypoints.SetHighlighted invalidates the layer, which collects the routes again.
            highlighted.highlighted = true
            WaypointMinimap.Invalidate()
            Update()

            assert.spy(WaypointHover.Set).was.called_with("minimap", highlighted, highlighted.owner.minimapTwin)
        end)

    end)
end)
