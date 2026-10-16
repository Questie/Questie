dofile("setupTests.lua")

describe("WaypointHover", function()
    ---@type WaypointHover
    local WaypointHover
    local QuestieWaypoints, MapIconTooltip, QuestieFrame
    local saved
    local tooltipOwner, minimapTooltip, listed

    local function Icon(data)
        return {
            data = data,
            IsVisible = function() return true end,
            scripts = {OnEnter = spy.new(function() end), OnLeave = spy.new(function() end)},
            GetScript = function(self, name) return self.scripts[name] end,
        }
    end

    ---Asserts the one Release call ended the tooltip shown for this owner on this tooltip frame.
    local function AssertReleased(owner, tooltip)
        assert.spy(MapIconTooltip.Release).was.called(1)
        assert.are.equal(owner, MapIconTooltip.Release.calls[1].refs[1])
        assert.are.equal(tooltip, MapIconTooltip.Release.calls[1].refs[2])
    end

    ---Asserts the one minimap tooltip shown listed the hovered route's icons, for the minimap.
    local function AssertListedOnMinimap()
        assert.spy(MapIconTooltip.ShowForIcons).was.called(1)
        local call = MapIconTooltip.ShowForIcons.calls[1]
        assert.are.equal(_G.Minimap, call.refs[1])
        assert.are.equal(listed, call.refs[2])
        assert.are.equal(minimapTooltip, call.refs[3])
    end

    before_each(function()
        saved = {GameTooltip = _G.GameTooltip, CreateFrame = _G.CreateFrame, Minimap = _G.Minimap}
        _G.Minimap = {}
        tooltipOwner = nil
        _G.GameTooltip = {GetOwner = function() return tooltipOwner end, Hide = spy.new(function() end)}
        minimapTooltip = {Hide = spy.new(function() end)}
        QuestieLoader:ImportModule("QuestieCompat").GetMouseFocus = function() return nil end
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.SetHighlighted = spy.new(function() end)
        listed = {{}}
        QuestieWaypoints.MinimapIcons = function() return listed end
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        MapIconTooltip.ShowForIcons = spy.new(function() end)
        MapIconTooltip.Release = spy.new(function() end)
        MapIconTooltip.MinimapTooltip = function() return minimapTooltip end
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrame.ResetHoverHighlights = spy.new(function() end)
        dofile("Modules/Map/Waypoints/WaypointHover.lua")
        WaypointHover = QuestieLoader:ImportModule("WaypointHover")
    end)

    after_each(function()
        for name, value in pairs(saved) do _G[name] = value end
    end)

    it("shows a minimap hover on a tooltip of its own, which Forever's minimap cannot take over", function()
        local data = {}
        local path, icon = {data = data}, Icon(data)

        WaypointHover.Set("minimap", path, icon)
        AssertListedOnMinimap()
        assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(data, true, "path")
        assert.spy(icon.scripts.OnEnter).was.not_called()

        WaypointHover.Set("minimap", nil)
        AssertReleased(_G.Minimap, minimapTooltip)
        -- It started no icon hover, so it ends none: it only highlighted the NPC's paths.
        assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(data, false, "path")
        assert.spy(QuestieFrame.ResetHoverHighlights).was.not_called()
    end)

    it("shows the tooltip of a minimap icon HereBeDragons hides out of range", function()
        local data = {}
        local icon = Icon(data)
        icon.IsVisible = function() return false end

        WaypointHover.Set("minimap", {data = data}, icon)

        AssertListedOnMinimap()
    end)

    it("ends a minimap hover once the NPC's minimap icon opens its own tooltip", function()
        local data = {}
        local icon = Icon(data)
        WaypointHover.Set("minimap", {data = data}, icon)

        WaypointHover.End(icon)

        AssertReleased(_G.Minimap, minimapTooltip)
    end)

    it("keeps one map's hover while the other map hovers nothing", function()
        local data = {}
        local path, icon = {data = data}, Icon(data)
        WaypointHover.Set("map", path, icon)
        tooltipOwner = icon

        WaypointHover.Set("minimap", nil)
        assert.spy(icon.scripts.OnLeave).was.not_called()

        WaypointHover.Set("map", nil)
        assert.spy(icon.scripts.OnLeave).was.called_with(icon)
    end)

    it("moves a path's hover from one map to the other with its tooltip", function()
        -- Both maps hover the same path object, the one registered for the patrol.
        local data = {}
        local path, mapIcon, minimapIcon = {data = data}, Icon(data), Icon(data)
        WaypointHover.Set("map", path, mapIcon)
        tooltipOwner = mapIcon

        WaypointHover.Set("minimap", path, minimapIcon)
        -- The world map may only see the cursor leave after the minimap took the hover.
        WaypointHover.Set("map", nil)

        assert.spy(mapIcon.scripts.OnLeave).was.called_with(mapIcon)
        AssertListedOnMinimap()
        assert.spy(MapIconTooltip.Release).was.not_called()
    end)

    it("undoes the NPC's tooltip changes when another frame takes the tooltip", function()
        local data = {}
        local icon = Icon(data)
        WaypointHover.Set("map", {data = data}, icon)
        tooltipOwner = {}

        WaypointHover.Set("map", nil)

        assert.spy(icon.scripts.OnLeave).was.not_called()
        assert.spy(QuestieFrame.ResetHoverHighlights).was.called_with(icon, data)
        -- That frame keeps the tooltip; Shift must not redraw the NPC's over it.
        AssertReleased(icon, GameTooltip)
        assert.spy(GameTooltip.Hide).was.not_called()
    end)

    it("only highlights the paths without an icon to open a tooltip", function()
        local path = {data = {}}

        WaypointHover.Set("minimap", path, nil)

        assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(path.data, true, "path")
    end)
end)
