dofile("setupTests.lua")

describe("QuestiePolygon world-map adapter", function()
    local Polygon, Geometry, QuestieMap, Player, FramePool, renderer, map, quest, objective, frames, timers, savedGlobals

    local function Update(index)
        local icon, zones, work
        local thread = coroutine.create(function()
            icon, zones, work = Polygon.UpdateObjective(quest, objective, index or 1)
        end)
        while coroutine.status(thread) ~= "dead" do
            local ok, err = coroutine.resume(thread)
            assert.is_true(ok, err)
        end
        return icon, zones, work
    end

    local function FlushRefresh()
        local pending = timers
        timers = {}
        for _, callback in ipairs(pending) do callback() end
    end

    before_each(function()
        savedGlobals = {LibStub = _G.LibStub, WorldMapFrame = _G.WorldMapFrame, C_Timer = _G.C_Timer,
            CreateFromMixins = _G.CreateFromMixins, MapCanvasDataProviderMixin = _G.MapCanvasDataProviderMixin,
            GetMouseFoci = _G.GetMouseFoci}
        _G.GetMouseFoci = nil
        _G.LibStub = function()
            return {GetWorldCoordinatesFromZone = function(_, x, y, uiMapId) return x * 1000, y * 1000, uiMapId end}
        end
        _G.MapCanvasDataProviderMixin = {}
        _G.CreateFromMixins = function(base, methods)
            local result = {}
            for k, v in pairs(base) do result[k] = v end
            for k, v in pairs(methods) do result[k] = v end
            return result
        end
        frames, timers = {}, {}
        _G.C_Timer = {After = function(_, callback) timers[#timers + 1] = callback end}
        map = {mapId = 10, shown = true,
            GetCanvas = function() return {GetWidth = function() return 1000 end, GetHeight = function() return 500 end} end,
            GetMapID = function(self) return self.mapId end, IsShown = function(self) return self.shown end,
            GetPinFrameLevelsManager = function() return {GetValidFrameLevel = function() return 10 end} end,
            AddDataProvider = function(self, provider) self.provider = provider; provider:OnAdded(self) end,
            RemoveDataProvider = function(self, provider) provider:OnRemoved(); self.provider = nil end}
        _G.WorldMapFrame = map
        Questie.db.profile = {enableQuestiePolygons = true, enableObjectives = true, enabled = true}
        Questie.usedIcons = {[1] = "icon"}
        renderer = {Clear = spy.new(function() end), Draw = spy.new(function() end)}
        QuestieLoader:ImportModule("PolygonRenderer").New = spy.new(function() return renderer end)
        Geometry = QuestieLoader:ImportModule("PolygonGeometry")
        Geometry.Build = spy.new(function(points)
            if #points == 0 then return {} end
            local point = points[1]
            return {{uiMapId = point.uiMapId, x = point.x, y = point.y, representative = point,
                outline = {{x = 10, y = 10}, {x = 20, y = 10}, {x = 10, y = 20}}}}
        end)
        local zones = QuestieLoader:ImportModule("ZoneDB")
        zones.GetUiMapIdByAreaId = function(_, areaId) return areaId * 10 end
        zones.GetDungeonLocation = function() return {{1, 5, 6}, {2, 7, 8}} end
        QuestieLoader:ImportModule("Phasing").IsSpawnVisible = function(phase) return phase ~= 2 end
        FramePool = QuestieLoader:ImportModule("QuestieFramePool")
        FramePool.UnloadFrame = spy.new(function(_, frame) frame.data = nil end)
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.GetScaleValue = function() return 1 end
        QuestieMap.utils = {RescaleIcon = function() end}
        QuestieMap.DrawWorldIcon = spy.new(function(_, data, areaId, x, y, _phase, _showFlag, destination)
            assert.are.equal("map", destination)
            local frame = {data = data, AreaID = areaId, UiMapID = areaId * 10, x = x, y = y,
                texture = {r = 1, g = 1, b = 1, a = 1, SetVertexColor = function(self, r, g, b, a)
                    self.r, self.g, self.b, self.a = r, g, b, a
                end}, ShouldBeHidden = function(self) return self.policyHidden end,
                UpdateTexture = function(self) self.texture.a = 1 end}
            frames[#frames + 1] = frame
            return frame
        end)
        objective = {Index = 1, Type = "monster", Color = {0.2, 0.5, 1}, spawnList = {
            [123] = {Id = 123, Name = "Wolf", Icon = 1, GetIconScale = function() return 1 end,
                Spawns = {[1] = {{10, 20}, {15, 25, 2}}}},
        }}
        quest = {Id = 42, Color = {1, 1, 1}, Objectives = {objective}}
        Player = QuestieLoader:ImportModule("QuestiePlayer")
        Player.currentQuestlog = {[42] = quest}
        dofile("Polygon/QuestiePolygon.lua")
        Polygon = QuestieLoader:ImportModule("QuestiePolygon")
    end)

    after_each(function()
        Polygon.Reset()
        for name, value in pairs(savedGlobals) do _G[name] = value end
        -- Nil values do not appear in pairs(savedGlobals).
        _G.WorldMapFrame = savedGlobals.WorldMapFrame
        _G.C_Timer = savedGlobals.C_Timer
        _G.CreateFromMixins = savedGlobals.CreateFromMixins
        _G.MapCanvasDataProviderMixin = savedGlobals.MapCanvasDataProviderMixin
        _G.GetMouseFoci = savedGlobals.GetMouseFoci
    end)

    it("supplies normalized canvas cursor and participating mouse-focus readers for direct hover", function()
        local foci = {"participating regions"}
        _G.GetMouseFoci = function() return foci end
        map.ScrollContainer = {GetNormalizedCursorPosition = function() return 0.25, 0.75 end}
        Update()
        local input = QuestieLoader:ImportModule("PolygonRenderer").New.calls[1].vals[2]

        assert.are.same({0.25, 0.75}, {input.getCursorPosition()})
        assert.are.equal(foci, input.getMouseFoci())
        map.ScrollContainer.GetNormalizedCursorPosition = function() return 0.4, 0.6 end
        assert.are.same({0.4, 0.6}, {input.getCursorPosition()})
    end)

    it("omits direct hover when the native focus stack is unavailable", function()
        map.ScrollContainer = {GetNormalizedCursorPosition = function() return 0.25, 0.75 end}
        Update()
        assert.is_nil(QuestieLoader:ImportModule("PolygonRenderer").New.calls[1].vals[2])
    end)

    it("omits direct hover when the map cursor reader is unavailable", function()
        _G.GetMouseFoci = function() return {} end
        map.ScrollContainer = {}
        Update()
        assert.is_nil(QuestieLoader:ImportModule("PolygonRenderer").New.calls[1].vals[2])
    end)

    it("uses full phase-filtered spawns even when minimap icons were already populated", function()
        objective.AlreadySpawned = {[123] = {}}
        Update()
        assert.spy(Geometry.Build).was.called(1)
        local point = Geometry.Build.calls[1].vals[1][1]
        assert.are.same({10, 20, 100, 200, 10, 10, 123},
            {point.x, point.y, point.worldX, point.worldY, point.uiMapId, point.instanceId, point.targetKey})
        assert.are.equal(1, #Geometry.Build.calls[1].vals[1])
        assert.are.equal(1, #frames)
    end)

    it("reuses geometry and markers on progress-only updates without duplicating waypoint owners", function()
        local icon, zones = Update()
        assert.are.equal(frames[1], zones[1][1])
        assert.are.equal(123, icon.AlreadySpawnedId)
        objective.Collected = 3
        local cachedIcon, cachedZones = Update()
        assert.is_nil(cachedIcon)
        assert.are.same({}, cachedZones)
        assert.spy(Geometry.Build).was.called(1)
        assert.are.equal(1, #frames)
    end)

    it("retains a marker's fade opacity while refreshing cached objective metadata", function()
        Update()
        frames[1].texture.a = 0.4
        objective.Collected = 3
        objective.spawnList[123].Name = "Updated wolf"
        Update()
        assert.are.equal(0.4, frames[1].texture.a)
        assert.are.equal("Updated wolf", frames[1].data.Name)
        assert.spy(Geometry.Build).was.called(1)
    end)

    describe("cached marker sizing", function()
        before_each(function()
            dofile("Modules/Map/QuestieMapUtils.lua")
            dofile("Modules/FramePool/QuestieFrame.lua")
            Questie.db.profile.globalScale = 1
            Update()
            local frame = frames[1]
            frame.UpdateTexture = QuestieLoader:ImportModule("QuestieFrame").private.UpdateTexture
            frame.SetSize = function(self, width, height) self.width, self.height = width, height end
            frame.SetAlpha = function() end
            frame.GlowUpdate = function() end
            frame.texture.SetTexture = function() end
            frame.overlayTexture = {Hide = function() end, SetTexture = function() end}
            frame.texture.a = 0.4
        end)

        it("retains world-map scale and fade opacity after a progress-only update", function()
            QuestieMap.GetScaleValue = function() return 0.85 end
            frames[1]:SetSize(13.6, 13.6)
            objective.Collected = 3

            Update()

            assert.are_near(13.6, frames[1].width, 0.000001)
            assert.are_near(13.6, frames[1].height, 0.000001)
            assert.are.equal(0.4, frames[1].texture.a)
            assert.spy(Geometry.Build).was.called(1)
            assert.are.equal(1, #frames)
        end)

        it("uses the current continent scale when refreshing a cached marker", function()
            QuestieMap.GetScaleValue = function() return 0.9 end
            frames[1]:SetSize(13.6, 13.6)
            objective.Collected = 3

            Update()

            assert.are_near(14.4, frames[1].width, 0.000001)
            assert.are_near(14.4, frames[1].height, 0.000001)
            assert.are.equal(0.4, frames[1].texture.a)
            assert.spy(Geometry.Build).was.called(1)
        end)
    end)

    it("rebuilds and releases old markers when eligible spawn locations change", function()
        Update()
        objective.spawnList[123].Spawns[1][1] = {30, 40}
        Update()
        assert.spy(Geometry.Build).was.called(2)
        assert.spy(FramePool.UnloadFrame).was.called(1)
        assert.is_nil(frames[1].data)
        assert.is_nil(frames[1].polygonMarker)
        assert.are.equal(30, frames[2].x)
    end)

    it("keeps special objectives with passed index zero separate by their canonical indexes", function()
        objective.Index = 65
        Update(0)
        objective = {Index = 66, Type = "monster", spawnList = objective.spawnList}
        Update(0)
        Polygon.RemoveObjective(42, 65)
        assert.is_nil(frames[1].data)
        assert.is_not_nil(frames[2].data)
        assert.are.equal(66, frames[2].data.ObjectiveIndex)
    end)

    it("does not publish geometry when an objective is removed during a yield", function()
        Geometry.Build = function(points)
            coroutine.yield()
            local point = points[1]
            return {{uiMapId = point.uiMapId, x = 10, y = 20, representative = point}}
        end
        local thread = coroutine.create(function() Polygon.UpdateObjective(quest, objective, 1) end)
        assert.is_true(coroutine.resume(thread))
        Polygon.RemoveQuest(42)
        assert.is_true(coroutine.resume(thread))
        assert.are.equal(0, #frames)
        assert.is_nil(map.provider)
    end)

    it("cancels during bounded marker allocation without leaving a partially pinned area", function()
        Geometry.Build = function(points)
            local clusters = {}
            for i = 1, 31 do
                clusters[i] = {uiMapId = 10, x = 10, y = 20, representative = points[1],
                    outline = {{x = 10, y = 10}, {x = 20, y = 10}, {x = 10, y = 20}}}
            end
            return clusters
        end
        local thread = coroutine.create(function() Polygon.UpdateObjective(quest, objective, 1) end)
        assert.is_true(coroutine.resume(thread))
        assert.are.equal(30, #frames)
        Polygon.ToggleMarker(frames[1])
        Polygon.Refresh()
        assert.are.same({}, renderer.Draw.calls[#renderer.Draw.calls].vals[2])
        Polygon.Reset()
        assert.is_true(coroutine.resume(thread))
        assert.are.equal(30, #frames)
        assert.spy(FramePool.UnloadFrame).was.called(30)
        assert.is_nil(map.provider)
    end)

    it("checks cancellation while collecting a large spawn list before building geometry", function()
        local spawns = {}
        for i = 1, 200 do spawns[i] = {10, 20} end
        objective.spawnList[123].Spawns[1] = spawns
        local thread = coroutine.create(function() Polygon.UpdateObjective(quest, objective, 1) end)
        assert.is_true(coroutine.resume(thread))
        Polygon.RemoveQuest(42)
        assert.is_true(coroutine.resume(thread))
        assert.spy(Geometry.Build).was.not_called()
        assert.are.equal(0, #frames)
    end)

    it("does not publish work after a mode reset during geometry generation", function()
        Geometry.Build = function()
            coroutine.yield()
            return {}
        end
        local thread = coroutine.create(function() Polygon.UpdateObjective(quest, objective, 1) end)
        assert.is_true(coroutine.resume(thread))
        Polygon.Reset()
        Questie.db.profile.enableQuestiePolygons = false
        assert.is_true(coroutine.resume(thread))
        assert.are.equal(0, #frames)
        assert.is_nil(map.provider)
    end)

    it("preserves rare-only and single-location objectives as map markers", function()
        Geometry.Build = function(points)
            return {{uiMapId = 10, x = 10, y = 20, representative = points[1]}}
        end
        Update()
        assert.are.equal(1, #frames)
        Polygon.EnterMarker(frames[1])
        FlushRefresh()
        assert.spy(renderer.Draw).was.called_with(renderer, {}, 1000, 500, 10)
    end)

    it("converts dungeon sentinel spawns to entrance locations instead of invalid hull points", function()
        objective.spawnList[123].Spawns[1] = {{-1, -1}}
        Update()
        local points = Geometry.Build.calls[1].vals[1]
        assert.are.equal(2, #points)
        assert.are.same({5, 6, 7, 8}, {points[1].x, points[1].y, points[2].x, points[2].y})
    end)

    it("shows hover geometry, keeps pinned geometry on leave, and follows logical marker hiding", function()
        Update()
        Polygon.EnterMarker(frames[1])
        FlushRefresh()
        local shapes = renderer.Draw.calls[#renderer.Draw.calls].vals[2]
        assert.are.equal(1, #shapes)
        assert.are.same({0.2, 0.5, 1, 0.25}, shapes[1].color)
        Polygon.ToggleMarker(frames[1])
        Polygon.LeaveMarker(frames[1])
        FlushRefresh()
        assert.are.equal(1, #renderer.Draw.calls[#renderer.Draw.calls].vals[2])
        frames[1].hidden = true
        Polygon.MarkerChanged(frames[1])
        FlushRefresh()
        assert.are.same({}, renderer.Draw.calls[#renderer.Draw.calls].vals[2])
    end)

    it("checks live Questie visibility policy and marker fade alpha before drawing pinned fills", function()
        Update()
        Polygon.ToggleMarker(frames[1])
        frames[1].texture.a = 0.4
        FlushRefresh()
        local shape = renderer.Draw.calls[#renderer.Draw.calls].vals[2][1]
        assert.are.equal(0.1, shape.color[4])
        assert.are_near(0.3, shape.borderAlpha, 0.000001)
        frames[1].policyHidden = true
        Polygon.Refresh()
        assert.are.same({}, renderer.Draw.calls[#renderer.Draw.calls].vals[2])
    end)

    it("reuses cached geometry after changing maps but draws only outlines belonging to the selected map", function()
        Update()
        Polygon.ToggleMarker(frames[1])
        FlushRefresh()
        map.mapId = 20
        map.provider:OnMapChanged()
        assert.are.same({}, renderer.Draw.calls[#renderer.Draw.calls].vals[2])
        map.mapId = 10
        map.provider:OnMapChanged()
        assert.are.equal(1, #renderer.Draw.calls[#renderer.Draw.calls].vals[2])
        assert.spy(Geometry.Build).was.called(1)
    end)

    it("clears rendering and releases provider and markers on disable", function()
        Update()
        Polygon.Reset()
        FlushRefresh()
        assert.is_nil(map.provider)
        assert.is_nil(frames[1].data)
        assert.spy(FramePool.UnloadFrame).was.called(1)
        assert.spy(renderer.Clear).was.called()
    end)

    it("reuses renderer and provider pools after repeated mode resets", function()
        Update()
        local originalProvider = map.provider
        Polygon.ToggleMarker(frames[1])
        FlushRefresh()
        Polygon.Reset()
        assert.is_nil(map.provider)
        Polygon.Refresh() -- Detached provider callbacks are harmless.
        Update()
        assert.are.equal(originalProvider, map.provider)
        Polygon.Reset()
        Update()
        assert.are.equal(originalProvider, map.provider)
        assert.spy(QuestieLoader:ImportModule("PolygonRenderer").New).was.called(1)
    end)

    it("keeps current waypoint work valid on progress updates but invalidates it on replacement", function()
        local _, _, work = Update()
        objective.Collected = 3
        Update()
        assert.is_true(Polygon.IsCurrentObjective(work))
        objective.spawnList[123].Spawns[1][1] = {30, 40}
        Update()
        assert.is_false(Polygon.IsCurrentObjective(work))
    end)

    it("unloads a waypoint marker when removal invalidated its captured generation", function()
        local _, _, work = Update()
        Polygon.RemoveQuest(42)
        local allocatedFrame = {data = {Id = 42}}
        assert.is_false(Polygon.OwnWaypointMarker(allocatedFrame, work))
        assert.spy(FramePool.UnloadFrame).was.called(2) -- Existing marker, then the rejected allocation.
        assert.is_nil(allocatedFrame.data)
        assert.is_nil(allocatedFrame.polygonMarker)
    end)

    it("does not draw pinned areas for markers temporarily hidden by tracker highlighting", function()
        Update()
        Polygon.ToggleMarker(frames[1])
        frames[1]._hidden_by_flash = true
        Polygon.Refresh()
        assert.are.same({}, renderer.Draw.calls[#renderer.Draw.calls].vals[2])
        frames[1]._hidden_by_flash = nil
        Polygon.Refresh()
        assert.are.equal(1, #renderer.Draw.calls[#renderer.Draw.calls].vals[2])
    end)

    it("keeps party-only objective rendering out of the local polygon cache", function()
        objective.IsPartyObjective = true
        Update()
        assert.spy(Geometry.Build).was.not_called()
        assert.are.equal(0, #frames)
    end)
end)
