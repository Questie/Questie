dofile("setupTests.lua")

describe("QuestieWaypoints", function()
    ---@type QuestieWaypoints
    local QuestieWaypoints
    local WaypointMap, WaypointMinimap
    local savedLibStub

    local PATROLS = {{{10, 10}, {20, 10}}, {{30, 30}, {40, 30}}}

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
        Questie.db.profile = {iconFadeLevel = 0.3}
        QuestieLoader:ImportModule("ZoneDB").GetUiMapIdByAreaId = function(_, areaId) return areaId + 1000 end
        WaypointMap = QuestieLoader:ImportModule("WaypointMap")
        WaypointMap.Invalidate = spy.new(function() end)
        WaypointMap.Restyle = spy.new(function() end)
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

        QuestieWaypoints.Add(icon, PATROLS, 12)

        assert.are.equal(2, CountPaths())
        assert.are.equal(2, #icon.data.waypointPaths)
        local path = icon.data.waypointPaths[1]
        assert.are.equal(icon, path.owner)
        assert.are.equal(1012, path.uiMapId)
        assert.are.equal(QuestieWaypoints.DEFAULT_COLOR, path.color)
        assert.spy(WaypointMap.Invalidate).was.called()
        assert.spy(WaypointMinimap.Invalidate).was.called()
    end)

    it("releases only the unloading icon's paths, also from data other icons share", function()
        local data = {}
        local first, second = Icon(data), Icon(data)
        QuestieWaypoints.Add(first, PATROLS, 12)
        QuestieWaypoints.Add(second, {{{50, 50}, {60, 60}}}, 12, QuestieWaypoints.HOSTILE_COLOR)

        QuestieWaypoints.RemoveOwner(first)

        assert.are.equal(1, CountPaths())
        assert.are.equal(1, #data.waypointPaths)
        assert.are.equal(second, data.waypointPaths[1].owner)
    end)

    it("shows a path on the world map while its icon is shown, faded with it", function()
        local icon = Icon({})
        QuestieWaypoints.Add(icon, PATROLS, 12)
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
        QuestieWaypoints.Add(icon, PATROLS, 12)
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
        QuestieWaypoints.Add(flashed, PATROLS, 12)
        QuestieWaypoints.Add(other, PATROLS, 12)

        QuestieWaypoints.SetSolo({[flashed.data] = true})
        assert.are.equal(1, QuestieWaypoints.WorldMapAlpha(flashed.data.waypointPaths[1]))
        assert.is_nil(QuestieWaypoints.WorldMapAlpha(other.data.waypointPaths[1]))
        assert.are.equal(1, QuestieWaypoints.MinimapAlpha(other.data.waypointPaths[1]))

        QuestieWaypoints.SetSolo(nil)
        assert.are.equal(1, QuestieWaypoints.WorldMapAlpha(other.data.waypointPaths[1]))
    end)

    it("highlights all of an NPC's paths and restyles each once", function()
        local icon = Icon({})
        QuestieWaypoints.Add(icon, PATROLS, 12)
        local path = icon.data.waypointPaths[1]

        QuestieWaypoints.SetHighlighted(icon.data, true)
        QuestieWaypoints.SetHighlighted(icon.data, true)

        assert.are.equal(QuestieWaypoints.HOVER_COLOR, QuestieWaypoints.Color(path))
        assert.spy(WaypointMap.Restyle).was.called(2)

        QuestieWaypoints.SetHighlighted(icon.data, false)
        assert.are.equal(QuestieWaypoints.DEFAULT_COLOR, QuestieWaypoints.Color(path))
    end)

    it("redraws for an icon's visibility change only when its NPC has paths", function()
        QuestieWaypoints.OwnerChanged(Icon({}))
        assert.spy(WaypointMap.Invalidate).was.not_called()

        local icon = Icon({})
        QuestieWaypoints.Add(icon, PATROLS, 12)
        QuestieWaypoints.OwnerChanged(icon)
        assert.spy(WaypointMap.Invalidate).was.called(2)
    end)
end)
