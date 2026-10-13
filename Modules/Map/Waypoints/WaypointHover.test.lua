dofile("setupTests.lua")

describe("WaypointHover", function()
    ---@type WaypointHover
    local WaypointHover
    local QuestieWaypoints, MapIconTooltip, QuestieFrame
    local saved
    local tooltipOwner, minimapTooltip

    local function Icon(data)
        return {
            data = data,
            IsVisible = function() return true end,
            scripts = {OnEnter = spy.new(function() end), OnLeave = spy.new(function() end)},
            GetScript = function(self, name) return self.scripts[name] end,
        }
    end

    before_each(function()
        saved = {GameTooltip = _G.GameTooltip, CreateFrame = _G.CreateFrame, Minimap = _G.Minimap}
        _G.Minimap = {}
        tooltipOwner = nil
        _G.GameTooltip = {GetOwner = function() return tooltipOwner end, Hide = spy.new(function() end)}
        minimapTooltip = {Hide = spy.new(function() end)}
        _G.CreateFrame = function() return minimapTooltip end
        QuestieLoader:ImportModule("QuestieCompat").GetMouseFocus = function() return nil end
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.SetHighlighted = spy.new(function() end)
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        MapIconTooltip.ShowOnTooltip = spy.new(function() end)
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
        assert.spy(MapIconTooltip.ShowOnTooltip).was.called_with(icon, minimapTooltip, _G.Minimap)
        assert.spy(icon.scripts.OnEnter).was.not_called()

        WaypointHover.Set("minimap", nil)
        assert.spy(minimapTooltip.Hide).was.called(1)
        assert.spy(QuestieFrame.ResetHoverHighlights).was.called_with({data = data})
    end)

    it("shows the tooltip of a minimap icon HereBeDragons hides out of range", function()
        local data = {}
        local icon = Icon(data)
        icon.IsVisible = function() return false end

        WaypointHover.Set("minimap", {data = data}, icon)

        assert.spy(MapIconTooltip.ShowOnTooltip).was.called_with(icon, minimapTooltip, _G.Minimap)
    end)

    it("ends a minimap hover once the NPC's minimap icon opens its own tooltip", function()
        local data = {}
        local icon = Icon(data)
        WaypointHover.Set("minimap", {data = data}, icon)

        WaypointHover.End(icon)

        assert.spy(minimapTooltip.Hide).was.called(1)
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

    it("moves an NPC's hover from one map to the other with its tooltip", function()
        local data = {}
        local mapIcon, minimapIcon = Icon(data), Icon(data)
        WaypointHover.Set("map", {data = data}, mapIcon)
        tooltipOwner = mapIcon

        WaypointHover.Set("minimap", {data = data}, minimapIcon)

        assert.spy(mapIcon.scripts.OnLeave).was.called_with(mapIcon)
        assert.spy(MapIconTooltip.ShowOnTooltip).was.called_with(minimapIcon, minimapTooltip, _G.Minimap)
    end)

    it("undoes the NPC's tooltip changes when another frame takes the tooltip", function()
        local data = {}
        local icon = Icon(data)
        WaypointHover.Set("map", {data = data}, icon)
        tooltipOwner = {}
        GameTooltip._Rebuild, GameTooltip.ShownAsMapIcon = function() end, true

        WaypointHover.Set("map", nil)

        assert.spy(icon.scripts.OnLeave).was.not_called()
        assert.spy(QuestieFrame.ResetHoverHighlights).was.called_with({data = data})
        assert.is_nil(GameTooltip._Rebuild)
        assert.is_false(GameTooltip.ShownAsMapIcon)
    end)

    it("only highlights the paths without an icon to open a tooltip", function()
        local path = {data = {}}

        WaypointHover.Set("minimap", path, nil)

        assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(path.data, true)
    end)
end)
