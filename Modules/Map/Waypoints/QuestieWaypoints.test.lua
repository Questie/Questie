dofile("setupTests.lua")

describe("QuestieWaypoints", function()
    ---@type QuestieWaypoints
    local QuestieWaypoints
    local WaypointMap, WaypointMinimap
    local savedLibStub

    local PATROLS = {{{10, 10}, {20, 10}}, {{30, 30}, {40, 30}}}
    local NORMAL, HOSTILE, HIGHLIGHT = {1, 0.72, 0, 0.5}, {1, 0.2, 0, 0.7}, {0.93, 0.46, 0.13, 0.8}

    local function Icon(data)
        return {data = data}
    end

    local function CountPaths()
        local count = 0
        for _ in pairs(QuestieWaypoints.paths) do count = count + 1 end
        return count
    end

    before_each(function()
        savedLibStub = _G.LibStub
        _G.LibStub = function()
            return {GetWorldCoordinatesFromZone = function(_, x, y) return x * 1000, y * 1000, 0 end}
        end
        Questie.db.profile = {iconFadeLevel = 0.3, waypointMapEnabled = true, waypointMinimapEnabled = true, waypointOpacity = 1,
            waypointColor = NORMAL, waypointHostileColor = HOSTILE, waypointHighlight = true, waypointHighlightColor = HIGHLIGHT}
        QuestieLoader:ImportModule("ZoneDB").GetUiMapIdByAreaId = function(_, areaId) return areaId + 1000 end
        WaypointMap = QuestieLoader:ImportModule("WaypointMap")
        WaypointMap.Invalidate = spy.new(function() end)
        WaypointMinimap = QuestieLoader:ImportModule("WaypointMinimap")
        WaypointMinimap.Invalidate = spy.new(function() end)
        dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
        dofile("Modules/Map/Waypoints/QuestieWaypoints.lua")
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
    end)

    after_each(function()
        _G.LibStub = savedLibStub
    end)

    it("draws each patrol for the icon and shares the paths with its data", function()
        local icon = Icon({})

        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12)

        assert.are.equal(2, CountPaths())
        assert.are.equal(2, #icon.data.waypointPaths)
        local path = icon.data.waypointPaths[1]
        assert.are.equal(icon, path.owner)
        assert.are.equal(1012, path.uiMapId)
        assert.spy(WaypointMap.Invalidate).was.called()
        assert.spy(WaypointMinimap.Invalidate).was.called()
    end)

    it("gives icons drawing the same entity's patrols the same routes, one per part", function()
        local first, second, other = Icon({}), Icon({}), Icon({})

        QuestieWaypoints.Add(first, "m_7", PATROLS, 12)
        QuestieWaypoints.Add(second, "m_7", PATROLS, 12)
        QuestieWaypoints.Add(other, "m_8", PATROLS, 12)

        local firstPaths, secondPaths = first.data.waypointPaths, second.data.waypointPaths
        assert.are.equal(firstPaths[1].route, secondPaths[1].route)
        assert.are.equal(firstPaths[2].route, secondPaths[2].route)
        assert.are_not.equal(firstPaths[1].route, firstPaths[2].route)
        assert.are_not.equal(firstPaths[1].route, other.data.waypointPaths[1].route)
    end)

    it("gives the minimap icons of every copy of a route that shows there, as for each of an NPC's quests", function()
        local first, second, hidden, other = Icon({}), Icon({}), Icon({}), Icon({})
        for _, icon in ipairs({first, second, hidden, other}) do icon.minimapTwin = {data = icon.data} end
        hidden.minimapTwin.hidden = true
        QuestieWaypoints.Add(first, "m_7", PATROLS, 12)
        QuestieWaypoints.Add(second, "m_7", PATROLS, 12)
        QuestieWaypoints.Add(hidden, "m_7", PATROLS, 12)
        QuestieWaypoints.Add(other, "m_8", PATROLS, 12)

        local icons = {}
        for _, icon in ipairs(QuestieWaypoints.MinimapIcons(first.data.waypointPaths[1])) do icons[icon] = true end

        assert.are.same({[first.minimapTwin] = true, [second.minimapTwin] = true}, icons)
    end)

    it("keeps an icon's paths to itself without an entity", function()
        local first, second = Icon({}), Icon({})

        QuestieWaypoints.Add(first, nil, PATROLS, 12)
        QuestieWaypoints.Add(second, nil, PATROLS, 12)

        assert.are_not.equal(first.data.waypointPaths[1].route, second.data.waypointPaths[1].route)
    end)

    it("releases only the unloading icon's paths, also from data other icons share", function()
        local data = {}
        local first, second = Icon(data), Icon(data)
        QuestieWaypoints.Add(first, "m_first", PATROLS, 12)
        QuestieWaypoints.Add(second, "m_second", {{{50, 50}, {60, 60}}}, 12, true)

        QuestieWaypoints.RemoveOwner(first)

        assert.are.equal(1, CountPaths())
        assert.are.equal(1, #data.waypointPaths)
        assert.are.equal(second, data.waypointPaths[1].owner)
    end)

    it("shows a path on the world map while its icon is shown, faded with it", function()
        local icon = Icon({})
        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12)
        local path = icon.data.waypointPaths[1]

        assert.are.equal(1, QuestieWaypoints.WorldMapAlpha(path))
        icon.faded = true
        assert.are.equal(0.3, QuestieWaypoints.WorldMapAlpha(path))
        icon.hidden = true
        assert.is_nil(QuestieWaypoints.WorldMapAlpha(path))
        -- A pooled frame drawn for something else no longer owns the path.
        icon.hidden, icon.data = nil, {}
        assert.is_nil(QuestieWaypoints.WorldMapAlpha(path))
    end)

    it("shows a path on the minimap only with the icon's minimap twin", function()
        local data = {}
        local icon = Icon(data)
        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12)
        local path = data.waypointPaths[1]
        assert.is_nil(QuestieWaypoints.MinimapAlpha(path))

        icon.minimapTwin = {data = data}
        assert.are.equal(1, QuestieWaypoints.MinimapAlpha(path))
        icon.minimapTwin.faded = true
        assert.are.equal(0.3, QuestieWaypoints.MinimapAlpha(path))
        icon.minimapTwin.hidden = true
        assert.is_nil(QuestieWaypoints.MinimapAlpha(path))
        -- Hiding the world map icon alone, such as with map icons disabled, keeps minimap paths.
        icon.minimapTwin.hidden, icon.hidden = nil, true
        assert.are.equal(0.3, QuestieWaypoints.MinimapAlpha(path))
    end)

    it("shows only flashed NPCs' paths on the world map while soloing", function()
        local flashed, other = Icon({}), Icon({})
        other.minimapTwin = {data = other.data}
        QuestieWaypoints.Add(flashed, "m_flashed", PATROLS, 12)
        QuestieWaypoints.Add(other, "m_other", PATROLS, 12)

        QuestieWaypoints.SetSolo({[flashed.data] = true})
        assert.are.equal(1, QuestieWaypoints.WorldMapAlpha(flashed.data.waypointPaths[1]))
        assert.is_nil(QuestieWaypoints.WorldMapAlpha(other.data.waypointPaths[1]))
        assert.are.equal(1, QuestieWaypoints.MinimapAlpha(other.data.waypointPaths[1]))

        QuestieWaypoints.SetSolo(nil)
        assert.are.equal(1, QuestieWaypoints.WorldMapAlpha(other.data.waypointPaths[1]))
    end)

    it("highlights all of an NPC's paths, redrawing both maps once per change", function()
        local icon = Icon({})
        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12)
        local path = icon.data.waypointPaths[1]
        WaypointMap.Invalidate:clear()
        WaypointMinimap.Invalidate:clear()

        QuestieWaypoints.SetHighlighted(icon.data, true)
        QuestieWaypoints.SetHighlighted(icon.data, true)

        assert.are_same(HIGHLIGHT, QuestieWaypoints.Color(path))
        assert.spy(WaypointMap.Invalidate).was.called(1)
        assert.spy(WaypointMinimap.Invalidate).was.called(1)

        QuestieWaypoints.SetHighlighted(icon.data, false)
        assert.are_same(NORMAL, QuestieWaypoints.Color(path))
        assert.spy(WaypointMap.Invalidate).was.called(2)
        assert.spy(WaypointMinimap.Invalidate).was.called(2)
    end)

    it("neither recolors a hovered path nor lets it take its route over while hover highlighting is off", function()
        Questie.db.profile.waypointHighlight = false
        local icon = Icon({})
        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12, true)
        local path = icon.data.waypointPaths[1]

        QuestieWaypoints.SetHighlighted(icon.data, true)

        assert.is_false(QuestieWaypoints.IsHighlighted(path))
        assert.are_same(HOSTILE, QuestieWaypoints.Color(path))
    end)

    it("colors paths from the current settings, by whether their NPC is fought", function()
        local friendly, hostile = Icon({}), Icon({})
        QuestieWaypoints.Add(friendly, "m_friendly", PATROLS, 12)
        QuestieWaypoints.Add(hostile, "m_hostile", PATROLS, 12, true)
        local friendlyPath, hostilePath = friendly.data.waypointPaths[1], hostile.data.waypointPaths[1]

        assert.are_same(NORMAL, QuestieWaypoints.Color(friendlyPath))
        assert.are_same(HOSTILE, QuestieWaypoints.Color(hostilePath))

        Questie.db.profile.waypointHostileColor = {0, 0, 1, 0.6}
        assert.are_same({0, 0, 1, 0.6}, QuestieWaypoints.Color(hostilePath))
    end)

    it("scales each color's opacity by the opacity setting, up to opaque", function()
        local friendly, hostile = Icon({}), Icon({})
        QuestieWaypoints.Add(friendly, "m_friendly", PATROLS, 12)
        QuestieWaypoints.Add(hostile, "m_hostile", PATROLS, 12, true)

        Questie.db.profile.waypointOpacity = 0.5
        assert.are.equal(0.25, QuestieWaypoints.Color(friendly.data.waypointPaths[1])[4])

        Questie.db.profile.waypointOpacity = 2
        assert.are.equal(1, QuestieWaypoints.Color(hostile.data.waypointPaths[1])[4])
    end)

    it("hides world map and minimap paths each with their own setting", function()
        local icon = Icon({})
        icon.minimapTwin = {data = icon.data}
        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12)
        local path = icon.data.waypointPaths[1]

        Questie.db.profile.waypointMinimapEnabled = false
        assert.are.equal(1, QuestieWaypoints.WorldMapAlpha(path))
        assert.is_nil(QuestieWaypoints.MinimapAlpha(path))

        Questie.db.profile.waypointMinimapEnabled, Questie.db.profile.waypointMapEnabled = true, false
        assert.is_nil(QuestieWaypoints.WorldMapAlpha(path))
        assert.are.equal(1, QuestieWaypoints.MinimapAlpha(path))
    end)

    it("redraws for an icon's visibility change only when its NPC has paths", function()
        QuestieWaypoints.OwnerChanged(Icon({}))
        assert.spy(WaypointMap.Invalidate).was.not_called()

        local icon = Icon({})
        QuestieWaypoints.Add(icon, "m_icon", PATROLS, 12)
        QuestieWaypoints.OwnerChanged(icon)
        assert.spy(WaypointMap.Invalidate).was.called(2)
    end)
end)
