dofile("setupTests.lua")

describe("WaypointMap", function()
    ---@type WaypointMap
    local WaypointMap
    local QuestieWaypoints
    local saved
    local driver, renderer
    local mapId, scale, cursor, focus, tooltipOwner, mapTypes, conversions

    local ZONE, CONTINENT = Enum.UIMapType.Zone, Enum.UIMapType.Continent

    local function NewView()
        local view = {shown = false}
        function view:Show() self.shown = true end
        function view:Hide() self.shown = false end
        return view
    end

    local function Owner(data)
        return {
            data = data,
            IsVisible = function() return true end,
            scripts = {OnEnter = spy.new(function() end), OnLeave = spy.new(function() end)},
            GetScript = function(self, name) return self.scripts[name] end,
        }
    end

    -- A horizontal patrol across map 1 at 50% height; maps are 1000x1000 yards on instance 0.
    local function Path(uiMapId)
        local data = {}
        local path = {uiMapId = uiMapId or 1, instanceId = 0, points = {{x = 10, y = 50}, {x = 90, y = 50}},
            world = {{x = 100, y = 500}, {x = 900, y = 500}}, worldBounds = {100, 500, 900, 500}, projections = {},
            data = data, owner = Owner(data), color = {1, 0.72, 0, 0.5}, alpha = 1}
        QuestieWaypoints.paths[path] = true
        return path
    end

    local function Update()
        driver.scripts.OnUpdate()
    end

    before_each(function()
        saved = {LibStub = _G.LibStub, WorldMapFrame = _G.WorldMapFrame, C_Map = _G.C_Map, CreateFrame = _G.CreateFrame,
            GameTooltip = _G.GameTooltip}
        mapId, scale, cursor, focus, tooltipOwner, conversions = 1, 1, nil, nil, nil, 0
        mapTypes = {[1] = ZONE, [2] = CONTINENT, [3] = ZONE, [4] = Enum.UIMapType.Dungeon, [1453] = ZONE}
        local canvas = {GetWidth = function() return 1000 end, GetHeight = function() return 500 end,
            IsMouseOver = function() return cursor ~= nil end}
        local scrollContainer = {
            GetCanvasScale = function() return scale end,
            GetNormalizedCursorPosition = function() return cursor[1], cursor[2] end,
        }
        _G.WorldMapFrame = {GetMapID = function() return mapId end, GetCanvas = function() return canvas end,
            ScrollContainer = scrollContainer}
        _G.C_Map = {GetMapInfo = function(id) return mapTypes[id] and {mapType = mapTypes[id]} end}
        _G.CreateFrame = function()
            driver = {scripts = {}}
            function driver:SetScript(name, script) self.scripts[name] = script end
            return driver
        end
        _G.GameTooltip = {GetOwner = function() return tooltipOwner end, Hide = spy.new(function() end)}
        -- Map 3 lies 500 yards east of map 1; dungeon floor 4 and Stormwind (1453) overlap map 1 exactly.
        local offsets = {[1] = 0, [3] = 500, [4] = 0, [1453] = 0}
        _G.LibStub = function()
            return {
                GetWorldCoordinatesFromZone = function(_, x, y, id) return x * 1000 + offsets[id], y * 1000, 0 end,
                GetZoneCoordinatesFromWorld = function(_, x, y, id)
                    conversions = conversions + 1
                    return (x - offsets[id]) / 1000, y / 1000
                end,
            }
        end
        QuestieLoader:ImportModule("QuestieCompat").GetMouseFocus = function() return focus end

        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.paths = {}
        QuestieWaypoints.WorldMapAlpha = function(path) return path.alpha end
        QuestieWaypoints.Color = function(path) return path.color end
        QuestieWaypoints.SetHighlighted = spy.new(function() end)

        renderer = {
            Draw = spy.new(function(_, view) return view or NewView() end),
            Restyle = spy.new(function() end),
            Release = spy.new(function(_, view) view:Hide() end),
        }
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/Waypoints/WaypointRenderer.lua")
        QuestieLoader:ImportModule("WaypointRenderer").New = function() return renderer end

        dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
        dofile("Modules/Map/Waypoints/WaypointMap.lua")
        WaypointMap = QuestieLoader:ImportModule("WaypointMap")
        focus = _G.WorldMapFrame.ScrollContainer
    end)

    after_each(function()
        for name, value in pairs(saved) do _G[name] = value end
    end)

    describe("drawing", function()
        it("draws visible paths in canvas units on detailed maps and releases them on continents", function()
            Path()
            WaypointMap.Invalidate()
            Update()

            assert.spy(renderer.Draw).was.called(1)
            local points, style = renderer.Draw.calls[1].vals[3], renderer.Draw.calls[1].vals[4]
            assert.are_same({{x = 100, y = 250}, {x = 900, y = 250}}, points)
            assert.are.equal(4, style.thickness)
            assert.are.equal(2015, style.frameLevel)

            mapId = 2
            Update()
            assert.spy(renderer.Release).was.called(1)
        end)

        it("skips paths whose icons are hidden", function()
            Path().alpha = nil
            WaypointMap.Invalidate()
            Update()

            assert.spy(renderer.Draw).was.not_called()
        end)

        it("keeps lines the same width on screen once a zoom settles", function()
            Path()
            WaypointMap.Invalidate()
            Update()

            -- Mid-zoom, a small change lets the lines scale with the canvas.
            scale = 1.1
            Update()
            assert.spy(renderer.Restyle).was.not_called()

            -- The same scale on the next frame means the zoom settled.
            Update()
            assert.spy(renderer.Draw).was.called(1)
            assert.are.near(4 / 1.1, renderer.Restyle.calls[1].vals[3].thickness, 1e-9)
        end)

        it("redraws mid-zoom once lines drift far from their width", function()
            Path()
            WaypointMap.Invalidate()
            Update()

            scale = 2
            Update()

            assert.are.equal(2, renderer.Restyle.calls[1].vals[3].thickness)
        end)
    end)

    describe("PointsOnMap", function()
        it("projects a path onto a neighbouring map once", function()
            local path = Path()

            assert.are_same({{x = -40, y = 50}, {x = 40, y = 50}}, WaypointMap.PointsOnMap(path, 3))
            WaypointMap.PointsOnMap(path, 3)
            assert.are.equal(2, conversions)
        end)

        it("projects between zones only, never onto dungeon floors", function()
            assert.is_nil(WaypointMap.PointsOnMap(Path(), 4))
            assert.is_nil(WaypointMap.PointsOnMap(Path(4), 1))
        end)

        it("keeps capitals and other instances apart", function()
            assert.is_nil(WaypointMap.PointsOnMap(Path(), 1453))
            assert.is_nil(WaypointMap.PointsOnMap(Path(1453), 1))
            local otherInstance = Path()
            otherInstance.instanceId = 1
            assert.is_nil(WaypointMap.PointsOnMap(otherInstance, 3))
        end)
    end)

    describe("hover", function()
        local path
        before_each(function()
            path = Path()
            WaypointMap.Invalidate()
            Update()
        end)

        it("opens the owner's tooltip near the line, and closes it on leaving", function()
            -- 2.5 canvas units below the line, inside the 6-unit hover reach.
            cursor = {0.5, 0.505}
            Update()
            assert.spy(path.owner.scripts.OnEnter).was.called_with(path.owner)

            tooltipOwner = path.owner
            cursor = {0.5, 0.6}
            Update()
            assert.spy(path.owner.scripts.OnLeave).was.called_with(path.owner)
        end)

        it("leaves the hover to whatever covers the map", function()
            focus = {}
            cursor = {0.5, 0.505}
            Update()

            assert.spy(path.owner.scripts.OnEnter).was.not_called()
        end)

        it("hands the hover to the icon when the cursor moves onto it", function()
            cursor = {0.5, 0.505}
            Update()

            tooltipOwner, focus = path.owner, path.owner
            cursor = {0.5, 0.5}
            Update()

            assert.spy(path.owner.scripts.OnLeave).was.not_called()
            assert.spy(QuestieWaypoints.SetHighlighted).was.not_called()
        end)

        it("lets the path's icon restore its tooltip changes before another icon's tooltip opens", function()
            cursor = {0.5, 0.505}
            Update()
            tooltipOwner = path.owner

            WaypointMap.EndHover(path.owner)
            assert.spy(path.owner.scripts.OnLeave).was.not_called()

            WaypointMap.EndHover(Owner({}))
            assert.spy(path.owner.scripts.OnLeave).was.called_with(path.owner)
        end)

        it("keeps the tooltip when moving to another patrol of the same NPC", function()
            local other = Path()
            other.data, other.owner = path.data, path.owner
            other.points = {{x = 10, y = 60}, {x = 90, y = 60}}
            WaypointMap.Invalidate()
            Update()

            cursor = {0.5, 0.505}
            Update()
            cursor = {0.5, 0.605}
            Update()

            assert.spy(path.owner.scripts.OnEnter).was.called(1)
            assert.spy(path.owner.scripts.OnLeave).was.not_called()
        end)

        it("only highlights a path whose icon is not on this map", function()
            path.owner.IsVisible = function() return false end
            cursor = {0.5, 0.505}
            Update()

            assert.spy(path.owner.scripts.OnEnter).was.not_called()
            assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(path.data, true)

            cursor = nil
            Update()
            assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(path.data, false)
        end)
    end)
end)
