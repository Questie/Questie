dofile("setupTests.lua")

describe("QuestiePolygon world-map adapter", function()
    local Polygon, Geometry, QuestieMap, Player, FramePool, renderer, renderCache, map, quest, objective, frames, timers, savedGlobals, HBD, drawnShapes

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
            GetMouseFoci = _G.GetMouseFoci, GetCursorPosition = _G.GetCursorPosition, CreateFrame = _G.CreateFrame,
            UIParent = _G.UIParent, hooksecurefunc = _G.hooksecurefunc, GetTimePreciseSec = _G.GetTimePreciseSec}
        _G.CreateFrame = spy.new(function() error("Nudging must not allocate an update driver") end)
        _G.UIParent = {GetEffectiveScale = function() return 1 end}
        dofile("Polygon/PolygonNudging.lua")
        _G.GetCursorPosition = nil
        _G.GetMouseFoci = nil
        HBD = {
            mapData = {[10] = {mapType = Enum.UIMapType.Zone}, [20] = {mapType = Enum.UIMapType.Zone}},
            GetWorldCoordinatesFromZone = function(_, x, y, uiMapId) return x * 1000, y * 1000, uiMapId end,
            TranslateZoneCoordinates = spy.new(function(_, x, y) return x - 0.15, y + 0.3 end),
        }
        _G.LibStub = function() return HBD end
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
        Questie.db.profile = {enableQuestiePolygons = true, enableObjectives = true, enabled = true, globalScale = 1}
        Questie.usedIcons = {[1] = "icon"}
        renderer = {}
        renderCache = {
            Present = spy.new(function(_, _mapId, shapes) drawnShapes = shapes; return true end),
            Hide = spy.new(function() end), Clear = spy.new(function() end), Release = spy.new(function() end),
        }
        QuestieLoader:ImportModule("PolygonRenderCache").New = spy.new(function() return renderCache end)
        QuestieLoader:ImportModule("PolygonRenderer").New = spy.new(function() return renderer end)
        dofile("Polygon/PolygonGeometry.lua") -- Collection uses the real shared work budget.
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
        QuestieMap.RescaleIcons = function() end
        QuestieMap.utils = {RescaleIcon = function() end}
        QuestieMap.DrawWorldIcon = spy.new(function(_, data, areaId, x, y, _phase, _showFlag, destination)
            assert.are.equal("map", destination)
            local frame = {data = data, AreaID = areaId, UiMapID = areaId * 10, x = x, y = y, _loaded = true,
                texture = {r = 1, g = 1, b = 1, a = 1, SetVertexColor = function(self, r, g, b, a)
                    self.r, self.g, self.b, self.a = r, g, b, a
                end}, ShouldBeHidden = function(self) return self.policyHidden end,
                UpdateTexture = function(self) self.texture.a = 1 end,
                IsVisible = function(self) return map.shown and not self.notShown and self.parent and self.parent.shown end,
                GetAlpha = function() return 1 end,
                GetRect = function(self) return self.x * 10, self.y * 5, 16, 16 end,
                GetEffectiveScale = function() return 1 end}
            frame.width, frame.height, frame.effectiveScale = 16, 16, 1
            local parent = {pinTemplate = "HereBeDragonsPinsTemplateQuestie", icon = frame, shown = true,
                centerX = x * 10, centerY = y * 5, effectiveScale = 1,
                GetCenter = function(self) return self.centerX, self.centerY end,
                GetRect = function(self) return self.centerX - 0.5, self.centerY - 0.5, 1, 1 end,
                GetEffectiveScale = function(self) return self.effectiveScale end}
            frame.parent, frame.point = parent, {"CENTER", parent, "CENTER", 0, 0}
            frame.GetParent = function(self) return self.parent end
            frame.GetSize = function(self) return self.width, self.height end
            frame.GetEffectiveScale = function(self) return self.effectiveScale end
            frame.GetPoint = function(self) return unpack(self.point) end
            frame.ClearAllPoints = function() end
            frame.SetPoint = function(self, ...) self.point = {...} end
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
        _G.GetCursorPosition = savedGlobals.GetCursorPosition
        _G.CreateFrame = savedGlobals.CreateFrame
        _G.UIParent = savedGlobals.UIParent
        _G.hooksecurefunc = savedGlobals.hooksecurefunc
        _G.GetTimePreciseSec = savedGlobals.GetTimePreciseSec
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

    describe("retained view ownership", function()
        it("supplies stable objective and marker identities separately from pooled icon frames", function()
            Update()
            local frame = frames[1]
            local marker = frame.polygonMarker
            Polygon.ToggleMarker(frame)
            FlushRefresh()

            local shape = drawnShapes[1]
            assert.are.equal(marker.entry, shape.owner)
            assert.are.equal(marker, shape.key)
            assert.are_not.equal(frame, shape.key)
            assert.are.equal(marker.cluster.outline, shape.source)
            assert.are.equal(marker.cluster.outline, shape.points)
            assert.are.equal(10, shape.sourceMapId)
            assert.spy(QuestieLoader:ImportModule("PolygonRenderCache").New).was.called_with(renderer)

            objective.Collected = 3
            Update()
            FlushRefresh()
            assert.are.equal(shape.owner, drawnShapes[1].owner)
            assert.are.equal(shape.key, drawnShapes[1].key)
            assert.are.equal(shape.source, drawnShapes[1].source)
            assert.spy(renderCache.Release).was.not_called()
            assert.spy(renderCache.Clear).was.not_called()
        end)

        it("keeps source identity while presenting a destination-map projection", function()
            Update()
            local marker = frames[1].polygonMarker
            Polygon.ToggleMarker(frames[1])
            map.mapId = 20
            FlushRefresh()

            assert.spy(renderCache.Present).was.called_with(renderCache, 20, drawnShapes, 1000, 500, 10)
            assert.are.equal(marker.entry, drawnShapes[1].owner)
            assert.are.equal(marker, drawnShapes[1].key)
            assert.are.equal(marker.cluster.outline, drawnShapes[1].source)
            assert.are.equal(10, drawnShapes[1].sourceMapId)
            assert.are_not.equal(drawnShapes[1].source, drawnShapes[1].points)
        end)

        it("releases objective views before replacement marker frames are recycled", function()
            Update()
            local frame, marker = frames[1], frames[1].polygonMarker
            local events, dataAtRelease, markerAtRelease, releasedOwner = {}, nil, nil, nil
            renderCache.Release = spy.new(function(_, owner)
                events[#events + 1] = "release views"
                dataAtRelease, markerAtRelease, releasedOwner = frame.data, frame.polygonMarker, owner
            end)
            FramePool.UnloadFrame = spy.new(function(_, releasedFrame)
                events[#events + 1] = "recycle marker"
                releasedFrame.data = nil
            end)
            objective.spawnList[123].Spawns[1][1] = {30, 40}

            Update()

            assert.are.same({"release views", "recycle marker"}, events)
            assert.is_not_nil(dataAtRelease)
            assert.are.equal(marker, markerAtRelease)
            assert.are.equal(marker.entry, releasedOwner)
            assert.is_nil(frame.polygonMarker)
            assert.are_not.equal(marker, frames[2].polygonMarker)
            assert.spy(renderCache.Release).was.called(1)
        end)

        it("releases objective views before removed marker frames are recycled", function()
            Update()
            local frame, marker = frames[1], frames[1].polygonMarker
            local events, dataAtRelease, markerAtRelease, releasedOwner = {}, nil, nil, nil
            renderCache.Release = spy.new(function(_, owner)
                events[#events + 1] = "release views"
                dataAtRelease, markerAtRelease, releasedOwner = frame.data, frame.polygonMarker, owner
            end)
            FramePool.UnloadFrame = spy.new(function(_, releasedFrame)
                events[#events + 1] = "recycle marker"
                releasedFrame.data = nil
            end)

            Polygon.RemoveObjective(42, 1)

            assert.are.same({"release views", "recycle marker"}, events)
            assert.is_not_nil(dataAtRelease)
            assert.are.equal(marker, markerAtRelease)
            assert.are.equal(marker.entry, releasedOwner)
            assert.spy(renderCache.Release).was.called(1)
            assert.is_nil(frame.data)
            assert.is_nil(frame.polygonMarker)
        end)

        it("releases only the removed marker's views before dropping its ownership", function()
            Update()
            local frame, marker = frames[1], frames[1].polygonMarker
            local markerAtRelease, releasedOwner, releasedKey
            renderCache.Release = spy.new(function(_, owner, key)
                markerAtRelease, releasedOwner, releasedKey = frame.polygonMarker, owner, key
            end)

            Polygon.MarkerRemoved(frame)

            assert.spy(renderCache.Release).was.called(1)
            assert.are.equal(marker.entry, releasedOwner)
            assert.are.equal(marker, releasedKey)
            assert.are.equal(marker, markerAtRelease)
            assert.is_nil(frame.polygonMarker)
            assert.are.same({}, marker.entry.markers)
            assert.spy(FramePool.UnloadFrame).was.not_called()
        end)

        it("retains views through hide and navigation while rechecking live visibility on reopen", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            Polygon.EnterMarker(frames[1])
            FlushRefresh()
            local marker, presentCount = frames[1].polygonMarker, #renderCache.Present.calls
            map.shown = false
            map.provider:OnHide()
            assert.spy(renderCache.Hide).was.called(1)
            assert.is_nil(marker.entry.hovered)
            assert.is_true(marker.entry.pinned)

            map.shown = true
            frames[1].policyHidden = true
            map.provider:OnShow()
            FlushRefresh()
            assert.spy(renderCache.Present).was.called(presentCount + 1)
            assert.are.same({}, drawnShapes)
            frames[1].policyHidden = false
            map.mapId = 20
            map.provider:OnMapChanged()
            assert.spy(renderCache.Hide).was.called(2)
            FlushRefresh()
            assert.are.equal(marker, drawnShapes[1].key)
            assert.spy(renderCache.Clear).was.not_called()
            assert.spy(renderCache.Release).was.not_called()
        end)

        it("clears hidden retained views on reset and rejects old callbacks after reattachment", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            FlushRefresh()
            local marker, originalProvider = frames[1].polygonMarker, map.provider
            map.shown = false
            map.provider:OnHide()
            Polygon.ScheduleRefresh()
            local oldCallbacks = timers
            assert.are.equal(1, #oldCallbacks)
            timers = {}
            local releasedOwner
            renderCache.Release = spy.new(function(_, owner) releasedOwner = owner end)

            Polygon.Reset()

            assert.spy(renderCache.Release).was.called(1)
            assert.are.equal(marker.entry, releasedOwner)
            assert.spy(renderCache.Clear).was.called(1)
            assert.is_nil(map.provider)
            map.shown = true
            Update()
            Polygon.ToggleMarker(frames[2])
            local presentCount, pendingCount = #renderCache.Present.calls, #timers
            for _, callback in ipairs(oldCallbacks) do callback() end
            assert.spy(renderCache.Present).was.called(presentCount)
            Polygon.ScheduleRefresh()
            assert.are.equal(pendingCount, #timers) -- Old callbacks must not clear the new batch's pending flag.
            assert.are.equal(originalProvider, map.provider)
            assert.spy(QuestieLoader:ImportModule("PolygonRenderer").New).was.called(1)
            assert.spy(QuestieLoader:ImportModule("PolygonRenderCache").New).was.called(1)
            FlushRefresh()
            assert.spy(renderCache.Present).was.called(presentCount + 1)
            assert.are.equal(frames[2].polygonMarker, drawnShapes[1].key)
        end)
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
        assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        Polygon.Reset()
        assert.is_true(coroutine.resume(thread))
        assert.are.equal(30, #frames)
        assert.spy(FramePool.UnloadFrame).was.called(30)
        assert.is_nil(map.provider)
    end)

    it("checks cancellation while collecting a large spawn list before building geometry", function()
        local spawns = {}
        for i = 1, 300 do spawns[i] = {10, 20} end
        objective.spawnList[123].Spawns[1] = spawns
        local now = 0
        _G.GetTimePreciseSec = function()
            now = now + 0.003 -- Every budget check finds this frame's slice spent.
            return now
        end
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
        assert.spy(renderCache.Present).was.called_with(renderCache, 10, {}, 1000, 500, 10)
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
        local shapes = renderCache.Present.calls[#renderCache.Present.calls].vals[3]
        assert.are.equal(1, #shapes)
        assert.are.same({0.2, 0.5, 1, 0.25}, shapes[1].color)
        assert.is_true(shapes[1].highlighted)
        Polygon.ToggleMarker(frames[1])
        Polygon.LeaveMarker(frames[1])
        FlushRefresh()
        assert.are.equal(1, #renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        assert.is_false(renderCache.Present.calls[#renderCache.Present.calls].vals[3][1].highlighted)
        frames[1].hidden = true
        Polygon.MarkerChanged(frames[1])
        FlushRefresh()
        assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
    end)

    it("highlights only the hovered marker's cluster while previewing the whole objective", function()
        local firstOutline = {{x = 10, y = 10}, {x = 20, y = 10}, {x = 10, y = 20}}
        local secondOutline = {{x = 70, y = 70}, {x = 80, y = 70}, {x = 70, y = 80}}
        objective.spawnList[123].Spawns[1] = {{10, 20}, {70, 80}}
        Geometry.Build = function(points)
            return {
                {uiMapId = 10, x = 10, y = 20, representative = points[1], outline = firstOutline},
                {uiMapId = 10, x = 70, y = 80, representative = points[2], outline = secondOutline},
            }
        end
        Update()
        Polygon.EnterMarker(frames[1])
        FlushRefresh()
        local shapes = renderCache.Present.calls[#renderCache.Present.calls].vals[3]
        assert.are.equal(2, #shapes)
        assert.are.same(firstOutline, shapes[1].points)
        assert.is_true(shapes[1].highlighted)
        assert.are.same(secondOutline, shapes[2].points)
        assert.is_false(shapes[2].highlighted)
        assert.is_nil(QuestieLoader:ImportModule("PolygonRenderer").New.calls[1].vals[2]) -- No native hover readers.

        Polygon.EnterMarker(frames[2])
        FlushRefresh()
        shapes = renderCache.Present.calls[#renderCache.Present.calls].vals[3]
        assert.is_false(shapes[1].highlighted)
        assert.is_true(shapes[2].highlighted)

        Polygon.ToggleMarker(frames[2])
        Polygon.LeaveMarker(frames[2])
        FlushRefresh()
        shapes = renderCache.Present.calls[#renderCache.Present.calls].vals[3]
        assert.are.equal(2, #shapes)
        assert.is_false(shapes[1].highlighted)
        assert.is_false(shapes[2].highlighted)
        assert.spy(QuestieMap.DrawWorldIcon).was.called(2)
    end)

    it("checks live Questie visibility policy and marker fade alpha before drawing pinned fills", function()
        Update()
        Polygon.ToggleMarker(frames[1])
        frames[1].texture.a = 0.4
        FlushRefresh()
        local shape = renderCache.Present.calls[#renderCache.Present.calls].vals[3][1]
        assert.are.equal(0.1, shape.color[4])
        assert.are_near(0.3, shape.borderAlpha, 0.000001)
        frames[1].policyHidden = true
        Polygon.Refresh()
        assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
    end)

    it("reuses cached geometry after changing maps but clears marker highlighting", function()
        Update()
        Polygon.ToggleMarker(frames[1])
        Polygon.EnterMarker(frames[1])
        FlushRefresh()
        assert.is_true(renderCache.Present.calls[#renderCache.Present.calls].vals[3][1].highlighted)
        map.mapId = 20
        frames[1].parent.shown = false -- HBD did not acquire this marker on the other map.
        map.provider:OnMapChanged()
        assert.is_nil(frames[1].polygonMarker.entry.hovered)
        FlushRefresh()
        assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        map.mapId = 10
        frames[1].parent.shown = true
        map.provider:OnMapChanged()
        FlushRefresh()
        assert.are.equal(1, #renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        assert.is_false(renderCache.Present.calls[#renderCache.Present.calls].vals[3][1].highlighted)
        assert.spy(Geometry.Build).was.called(1)
    end)

    describe("provider refresh coalescing", function()
        before_each(function()
            Update()
            Polygon.ToggleMarker(frames[1])
            Polygon.EnterMarker(frames[1])
            FlushRefresh()
        end)

        it("presents immediately and coalesces later notifications using the latest map and canvas", function()
            local presentCount = #renderCache.Present.calls
            Polygon.ScheduleRefresh() -- Marker OnShow can queue first, before providers run.
            map.provider:RefreshAllData()
            assert.spy(renderCache.Present).was.called(presentCount + 1)
            assert.spy(renderCache.Present).was.called_with(renderCache, 10, drawnShapes, 1000, 500, 10)
            assert.is_true(drawnShapes[1].highlighted)
            map.provider:OnShow()
            map.mapId = 20
            map.provider:OnMapChanged()
            assert.is_nil(frames[1].polygonMarker.entry.hovered)
            map.provider:OnCanvasSizeChanged()
            map.GetCanvas = function()
                return {GetWidth = function() return 800 end, GetHeight = function() return 400 end}
            end
            map.provider:OnCanvasSizeChanged()

            assert.are.equal(1, #timers)
            assert.spy(renderCache.Present).was.called(presentCount + 1)
            assert.spy(HBD.TranslateZoneCoordinates).was.not_called()
            FlushRefresh()

            assert.spy(renderCache.Present).was.called(presentCount + 2)
            assert.spy(renderCache.Present).was.called_with(renderCache, 20, drawnShapes, 800, 400, 10)
            assert.are.equal(1, #drawnShapes)
            assert.is_false(drawnShapes[1].highlighted)
            assert.spy(HBD.TranslateZoneCoordinates).was.called_with(HBD, 0.1, 0.1, 10, 20, true)
            assert.are.equal(0, #timers)
            assert.spy(Geometry.Build).was.called(1)

            map.provider:OnCanvasSizeChanged()
            assert.are.equal(1, #timers)
            FlushRefresh()
            assert.spy(renderCache.Present).was.called(presentCount + 3)
        end)

        it("hides immediately on hide and does not redraw when the pending callback runs", function()
            local presentCount, hideCount = #renderCache.Present.calls, #renderCache.Hide.calls
            map.provider:OnShow()
            map.shown = false
            map.provider:OnHide()

            assert.spy(renderCache.Hide).was.called(hideCount + 1)
            assert.is_nil(frames[1].polygonMarker.entry.hovered)
            assert.is_true(frames[1].polygonMarker.entry.pinned)
            FlushRefresh()
            assert.spy(renderCache.Present).was.called(presentCount)
            assert.spy(renderCache.Clear).was.not_called()
            assert.spy(renderCache.Release).was.not_called()
        end)

        it("hides immediately on removal and leaves pending provider work unable to redraw", function()
            local presentCount, hideCount = #renderCache.Present.calls, #renderCache.Hide.calls
            Polygon.ScheduleRefresh()
            assert.are.equal(1, #timers)
            map:RemoveDataProvider(map.provider)

            assert.spy(renderCache.Hide).was.called(hideCount + 1)
            FlushRefresh()
            Polygon.Refresh() -- A detached callback must only hide retained views.
            assert.spy(renderCache.Present).was.called(presentCount)
            assert.spy(renderCache.Clear).was.not_called()
            assert.spy(renderCache.Release).was.not_called()
        end)
    end)

    describe("polygon projection follows displayed markers", function()
        before_each(function()
            objective.spawnList[123].Spawns[1][1] = {20, 20}
            Geometry.Build = spy.new(function(points)
                local point = points[1]
                -- Keep the marker at this triangle's centroid, including replacement geometry.
                return {{uiMapId = point.uiMapId, x = point.x, y = point.y, representative = point,
                    outline = {{x = point.x - 10, y = point.y - 10}, {x = point.x + 10, y = point.y - 10},
                        {x = point.x, y = point.y + 20}}}}
            end)
        end)

        it("uses the original outline unchanged on its source map", function()
            Update()
            local outline = frames[1].polygonMarker.cluster.outline
            Polygon.ToggleMarker(frames[1])
            FlushRefresh()

            assert.are.equal(outline, drawnShapes[1].points)
            assert.spy(HBD.TranslateZoneCoordinates).was.not_called()
        end)

        it("projects a visible neighboring marker's outline without clamping or moving its source geometry", function()
            Update()
            local frame = frames[1]
            local outline = frame.polygonMarker.cluster.outline
            Polygon.ToggleMarker(frame)
            map.mapId = 20
            Polygon.EnterMarker(frame)
            frame.point = {"CENTER", frame.parent, "CENTER", 30, 0} -- Display nudging is not geographic input.
            local markerX, markerY = HBD:TranslateZoneCoordinates(frame.x / 100, frame.y / 100, frame.UiMapID, map.mapId, false)
            assert.are_near(0.05, markerX, 0.000001)
            assert.are_near(0.5, markerY, 0.000001) -- HBD can acquire this marker inside the destination map.
            Polygon.Refresh()

            local shape = renderCache.Present.calls[#renderCache.Present.calls].vals[3][1]
            assert.is_true(shape.highlighted)
            assert.are_near(-5, shape.points[1].x, 0.000001)
            assert.are_near(40, shape.points[1].y, 0.000001)
            assert.are_near(15, shape.points[2].x, 0.000001)
            assert.are_near(40, shape.points[2].y, 0.000001)
            assert.are_near(5, shape.points[3].x, 0.000001)
            assert.are_near(70, shape.points[3].y, 0.000001)
            assert.are.same({{x = 10, y = 10}, {x = 30, y = 10}, {x = 20, y = 40}}, outline)
            assert.are.same({20, 20, 10}, {frame.x, frame.y, frame.UiMapID})
            assert.spy(HBD.TranslateZoneCoordinates).was.called_with(HBD, 0.1, 0.1, 10, 20, true)
            assert.spy(Geometry.Build).was.called(1)
        end)

        it("reuses each destination projection across refreshes and navigation", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            map.mapId = 20
            Polygon.Refresh()
            local projected = drawnShapes[1].points
            Polygon.Refresh()
            Polygon.EnterMarker(frames[1])
            FlushRefresh()
            assert.are.equal(projected, drawnShapes[1].points)
            map.mapId = 10
            map.provider:OnMapChanged()
            FlushRefresh()
            assert.are.equal(frames[1].polygonMarker.cluster.outline, drawnShapes[1].points)
            map.mapId = 20
            map.provider:OnMapChanged()
            FlushRefresh()

            assert.are.equal(projected, drawnShapes[1].points)
            assert.spy(HBD.TranslateZoneCoordinates).was.called(3)
            assert.spy(Geometry.Build).was.called(1)
        end)

        it("reprojects replacement geometry instead of retaining the old view cache", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            map.mapId = 20
            Polygon.Refresh()
            local originalProjection = drawnShapes[1].points
            objective.spawnList[123].Spawns[1][1] = {30, 40}
            Update()
            Polygon.Refresh()

            assert.is_nil(frames[1].data)
            assert.are_not.equal(originalProjection, drawnShapes[1].points)
            assert.spy(HBD.TranslateZoneCoordinates).was.called(6)
            assert.spy(Geometry.Build).was.called(2)
        end)

        local detailedMaps = {
            {name = "zone", mapType = Enum.UIMapType.Zone},
            {name = "dungeon", mapType = Enum.UIMapType.Dungeon},
            {name = "micro", mapType = Enum.UIMapType.Micro},
        }
        for _, case in ipairs(detailedMaps) do
            it("draws on a detailed " .. case.name .. " map when the owning marker is visible", function()
                HBD.mapData[20].mapType = case.mapType
                Update()
                Polygon.ToggleMarker(frames[1])
                map.mapId = 20
                Polygon.Refresh()
                assert.are.equal(1, #renderCache.Present.calls[#renderCache.Present.calls].vals[3])
            end)
        end

        local overviewMaps = {
            {name = "world", mapType = Enum.UIMapType.World},
            {name = "continent", mapType = Enum.UIMapType.Continent},
            {name = "cosmic", mapType = Enum.UIMapType.Cosmic},
            {name = "orphan", mapType = Enum.UIMapType.Orphan},
        }
        for _, case in ipairs(overviewMaps) do
            it("never draws on a " .. case.name .. " map even when the source marker is visible", function()
                Update()
                Polygon.ToggleMarker(frames[1])
                FlushRefresh()
                HBD.mapData[10].mapType = case.mapType
                Polygon.Refresh()
                assert.spy(renderCache.Hide).was.called()
                assert.is_true(frames[1].polygonMarker.entry.pinned)
                assert.spy(HBD.TranslateZoneCoordinates).was.not_called()
            end)
        end

        it("hides drawing when the displayed map has no known metadata", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            FlushRefresh()
            map.mapId = 999
            Polygon.Refresh()
            assert.spy(renderCache.Hide).was.called()
            assert.spy(HBD.TranslateZoneCoordinates).was.not_called()
        end)

        it("hides pinned geometry when its native marker is hidden, without clearing pinning or projections", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            map.mapId = 20
            Polygon.Refresh()
            local projected = drawnShapes[1].points
            frames[1].notShown = true
            Polygon.Refresh()
            assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
            assert.is_true(frames[1].polygonMarker.entry.pinned)
            frames[1].notShown = false
            Polygon.Refresh()
            assert.are.equal(projected, drawnShapes[1].points)
            assert.spy(HBD.TranslateZoneCoordinates).was.called(3)
        end)

        it("does not draw when the marker's native parent is hidden", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            frames[1].parent.shown = false
            Polygon.Refresh()
            assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        end)

        it("does not draw for a queued marker even if its frame has not yet been hidden", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            frames[1]._loaded = nil
            Polygon.Refresh()
            assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        end)

        it("does not draw for a marker detached from its HBD map wrapper", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            frames[1].parent = {shown = true} -- UIParent can be visible after the map pin is released.
            Polygon.Refresh()
            assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        end)

        it("catches up when HBD shows a marker after the polygon provider has already refreshed", function()
            dofile("Modules/FramePool/QuestieFrame.lua")
            local handlers = QuestieLoader:ImportModule("QuestieFrame").private
            Update()
            local frame, wrapper = frames[1], frames[1].parent
            frame._loaded, frame.parent = nil, {shown = true}
            Polygon.ToggleMarker(frame)
            map.mapId = 20
            map.provider:OnMapChanged()
            FlushRefresh()
            assert.are.same({}, drawnShapes)
            assert.is_true(frame.polygonMarker.entry.pinned)

            frame.parent = wrapper
            handlers.BaseOnShow(frame) -- HBD shows the frame before ProcessQueue marks it loaded.
            frame._loaded = true
            FlushRefresh()
            assert.are.equal(1, #drawnShapes)
            assert.is_true(frame.polygonMarker.entry.pinned)
            assert.are.equal(0, #timers)

            frame.notShown = true
            frame.glowTexture = {Hide = function() end}
            handlers.BaseOnHide(frame)
            FlushRefresh()
            assert.are.same({}, drawnShapes)
            assert.is_true(frame.polygonMarker.entry.pinned)
            assert.are.equal(0, #timers)
        end)

        it("invalidates a destination cache when the source outline identity changes", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            map.mapId = 20
            Polygon.Refresh()
            frames[1].polygonMarker.cluster.outline = {{x = 30, y = 10}, {x = 40, y = 10}, {x = 30, y = 20}}
            Polygon.Refresh()
            assert.are_near(15, drawnShapes[1].points[1].x, 0.000001)
            assert.spy(HBD.TranslateZoneCoordinates).was.called(6)
            assert.spy(Geometry.Build).was.called(1)
        end)

        it("skips the entire outline when a vertex cannot be translated, then retries instead of caching a partial view", function()
            Update()
            Polygon.ToggleMarker(frames[1])
            map.mapId = 20
            HBD.TranslateZoneCoordinates = function(_, x, y)
                if x == 0.2 then return nil end
                return x, y
            end
            Polygon.Refresh()
            assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
            HBD.TranslateZoneCoordinates = spy.new(function(_, x, y) return x, y end)
            Polygon.Refresh()
            assert.are.equal(1, #renderCache.Present.calls[#renderCache.Present.calls].vals[3])
            assert.spy(HBD.TranslateZoneCoordinates).was.called(3)
        end)

        local invalidCoordinates = {
            {name = "nonnumeric", x = "restricted"},
            {name = "infinite", x = math.huge},
            {name = "NaN", x = 0 / 0},
        }
        for _, case in ipairs(invalidCoordinates) do
            it("does not draw a " .. case.name .. " projected coordinate", function()
                Update()
                Polygon.ToggleMarker(frames[1])
                map.mapId = 20
                HBD.TranslateZoneCoordinates = function() return case.x, 0.1 end
                Polygon.Refresh()
                assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
            end)
        end
    end)

    it("clears rendering and releases provider and markers on disable", function()
        Update()
        Polygon.Reset()
        FlushRefresh()
        assert.is_nil(map.provider)
        assert.is_nil(frames[1].data)
        assert.spy(FramePool.UnloadFrame).was.called(1)
        assert.spy(renderCache.Clear).was.called()
        assert.spy(renderCache.Present).was.not_called()
    end)

    describe("render cleanup failures", function()
        local originalError

        before_each(function()
            originalError = Questie.Error
            Questie.Error = spy.new(function() end)
        end)

        after_each(function()
            -- Outer cleanup also calls Reset; do not leave injected failures active.
            renderCache.Clear = function() end
            renderCache.Release = function() end
            renderCache.Hide = function() end
            Questie.Error = originalError
        end)

        it("invalidates waypoint work and completes reset even when native view cleanup fails", function()
            local _, _, work = Update()
            Polygon.ToggleMarker(frames[1])
            FlushRefresh()
            local provider = map.provider
            local presentations = #renderCache.Present.calls
            Polygon.ScheduleRefresh()
            local wasCurrentDuringClear
            renderCache.Clear = function()
                wasCurrentDuringClear = Polygon.IsCurrentObjective(work)
                error("clear failed")
            end
            renderCache.Release = function() error("release failed") end
            renderCache.Hide = function() error("hide failed") end

            assert.has_no.errors(function() Polygon.Reset() end)

            assert.is_false(wasCurrentDuringClear)
            assert.is_false(Polygon.IsCurrentObjective(work))
            assert.is_nil(frames[1].data)
            assert.is_nil(frames[1].polygonMarker)
            assert.is_nil(map.provider)
            assert.is_nil(provider.owningMap)
            assert.spy(Questie.Error).was.called(3)
            FlushRefresh()
            assert.spy(renderCache.Present).was.called(presentations)
        end)

        it("drops removed marker ownership even if its retained view cannot be released yet", function()
            Update()
            local marker = frames[1].polygonMarker
            renderCache.Release = function() error("release failed") end

            assert.has_no.errors(function() Polygon.MarkerRemoved(frames[1]) end)

            assert.is_nil(frames[1].polygonMarker)
            assert.are.same({}, marker.entry.markers)
            assert.spy(Questie.Error).was.called(1)
        end)
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
        assert.spy(QuestieLoader:ImportModule("PolygonRenderCache").New).was.called_with(renderer)
        assert.spy(QuestieLoader:ImportModule("PolygonRenderCache").New).was.called(1)
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
        assert.are.same({}, renderCache.Present.calls[#renderCache.Present.calls].vals[3])
        frames[1]._hidden_by_flash = nil
        Polygon.Refresh()
        assert.are.equal(1, #renderCache.Present.calls[#renderCache.Present.calls].vals[3])
    end)

    describe("fixed horizontal marker stacks", function()
        local meat, ribs, meatObjective

        before_each(function()
            quest.Id = 317
            Player.currentQuestlog = {[317] = quest}
            Update()
            meat, meatObjective = frames[1], objective
            objective = {Index = 1, Type = "item", Color = {1, 0.3, 0.1}, spawnList = meatObjective.spawnList}
            quest = {Id = 384, Color = {1, 1, 1}, Objectives = {objective}}
            Player.currentQuestlog[384] = quest
            Update()
            ribs = frames[2]
            FlushRefresh()
        end)

        it("separates coincident boar markers while preserving geometry and independent pinning", function()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.are_near(5.6, ribs.point[4], 0.000001)
            assert.are.equal(0, meat.point[5])
            assert.are.equal(0, ribs.point[5])
            assert.are.same({10, 20, 10}, {meat.x, meat.y, meat.UiMapID})
            assert.are.same({{x = 10, y = 10}, {x = 20, y = 10}, {x = 10, y = 20}}, meat.polygonMarker.cluster.outline)
            Polygon.ToggleMarker(meat)
            Polygon.ToggleMarker(ribs)
            Polygon.ToggleMarker(meat)
            assert.is_false(meat.polygonMarker.entry.pinned)
            assert.is_true(ribs.polygonMarker.entry.pinned)
            Polygon.EnterMarker(meat)
            Polygon.LeaveMarker(meat)
            FlushRefresh()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.are_near(5.6, ribs.point[4], 0.000001)
            assert.spy(_G.CreateFrame).was.not_called()
        end)

        it("reserves queued markers and reapplies on HBD acquisition without an OnShow or update driver", function()
            local wrapper = ribs.parent
            ribs.parent, ribs.point = {}, {"CENTER", {}, "CENTER", 0, 0}
            Polygon.UpdateNudging()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            ribs.parent, ribs.point = wrapper, {"CENTER", wrapper, "CENTER", 0, 0}
            ribs:OnWorldMapPinUpdated(wrapper)
            assert.are_near(5.6, ribs.point[4], 0.000001)
            assert.spy(_G.CreateFrame).was.not_called()
        end)

        it("keeps hidden, offscreen, transparent and tracker-hidden members' slots stable", function()
            ribs.hidden, ribs.notShown, ribs._hidden_by_flash, ribs.texture.a = true, true, true, 0
            Polygon.MarkerChanged(ribs)
            FlushRefresh()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.are_near(5.6, ribs.point[4], 0.000001)
            ribs.hidden, ribs.notShown, ribs._hidden_by_flash, ribs.texture.a = false, false, nil, 1
            Polygon.MarkerChanged(ribs)
            FlushRefresh()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.are_near(5.6, ribs.point[4], 0.000001)
        end)

        it("partitions original maps and excludes minimap frames rather than merging screen projections", function()
            ribs.UiMapID = 20
            Polygon.UpdateNudging()
            assert.are.equal(0, meat.point[4])
            assert.are.equal(0, ribs.point[4])
            ribs.UiMapID, ribs.miniMapIcon = 10, true
            Polygon.UpdateNudging()
            assert.are.equal(0, meat.point[4])
            assert.are.equal(0, ribs.point[4])
            assert.is_nil(ribs.OnWorldMapPinUpdated)
        end)

        it("restores the same slots on disable and re-enable without a polling callback", function()
            Questie.db.profile.enabled = false
            Polygon.UpdateNudging()
            assert.are.equal(0, meat.point[4])
            assert.are.equal(0, ribs.point[4])
            Questie.db.profile.enabled = true
            objective.Collected = 3
            Update()
            FlushRefresh()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.are_near(5.6, ribs.point[4], 0.000001)
            meat.point = {"CENTER", meat.parent, "CENTER", 0, 0}
            meat:OnWorldMapPinUpdated(meat.parent)
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.spy(_G.CreateFrame).was.not_called()
            assert.spy(Geometry.Build).was.called(2)
        end)

        it("suspends on map hide, keeps slots on map changes, and cancels deferred work on reset", function()
            map.shown = false
            map.provider:OnHide()
            assert.are.equal(0, meat.point[4])
            assert.are.equal(0, ribs.point[4])
            map.shown = true
            map.provider:OnShow()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            map.mapId = 20
            map.provider:OnMapChanged()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            Polygon.ScheduleNudging()
            Polygon.Reset()
            FlushRefresh()
            assert.are.equal(0, meat.point[4])
            assert.are.equal(0, ribs.point[4])
            assert.is_nil(meat.polygonMarker)
            assert.is_nil(meat.OnWorldMapPinUpdated)
            assert.is_nil(ribs.OnWorldMapPinUpdated)
            assert.spy(_G.CreateFrame).was.not_called()
        end)

        it("keeps spacing proportional through HBD zoom notifications and resize without regrouping", function()
            local nudging = QuestieLoader:ImportModule("PolygonNudging")
            local calculate = spy.on(nudging, "Calculate")
            meat.parent.effectiveScale, ribs.parent.effectiveScale = 1.2, 1.2
            meat.effectiveScale, ribs.effectiveScale = 1.2, 1.2
            meat:OnWorldMapPinUpdated(meat.parent)
            ribs:OnWorldMapPinUpdated(ribs.parent)
            local separation = ribs.point[4] * ribs.effectiveScale - meat.point[4] * meat.effectiveScale
            assert.are_near(13.44, separation, 0.000001)
            assert.are_near(19.2, meat.width * meat.effectiveScale, 0.000001)
            assert.are_near(0.7, separation / (meat.width * meat.effectiveScale), 0.000001)

            meat.width, meat.height, ribs.width, ribs.height = 48, 48, 48, 48 -- Tracker flash dimensions are not layout inputs.
            map.provider:OnCanvasSizeChanged()
            assert.are_near(-5.6, meat.point[4], 0.000001)
            assert.are_near(5.6, ribs.point[4], 0.000001)
            assert.are.equal(1, #timers) -- Drawing is deferred; slot reapplication stays immediate.
            FlushRefresh()
            assert.are.equal(0, #timers)
            assert.are.same({10, 20, 10}, {meat.x, meat.y, meat.UiMapID})
            assert.spy(calculate).was.not_called()
            assert.spy(Geometry.Build).was.called(2)
        end)

        it("restores an icon and removes its callback before pooling, then recenters the survivor", function()
            Polygon.RemoveQuest(317)
            assert.are.equal(0, meat.point[4])
            assert.is_nil(meat.polygonMarker)
            assert.is_nil(meat.OnWorldMapPinUpdated)
            FlushRefresh()
            assert.are.equal(0, ribs.point[4])
        end)
    end)

    it("observes configured icon-size changes once and reads the new setting after the setter completes", function()
        local resizeHook
        _G.hooksecurefunc = spy.new(function(owner, name, callback)
            assert.are.equal(QuestieMap, owner)
            assert.are.equal("RescaleIcons", name)
            resizeHook = callback
        end)
        Update()
        local otherQuest = {Id = 384, Objectives = {}, Color = {1, 1, 1}}
        quest.Id = 317
        Player.currentQuestlog = {[317] = quest, [384] = otherQuest}
        Polygon.Reset()
        Update()
        quest = otherQuest
        Update()
        FlushRefresh()
        local meat, ribs = frames[2], frames[3]
        assert.are_near(-5.6, meat.point[4], 0.000001)
        resizeHook() -- RescaleIcons runs before SetProfileValue.
        Questie.db.profile.globalScale = 1.5
        FlushRefresh()
        assert.are_near(-8.4, meat.point[4], 0.000001)
        assert.are_near(8.4, ribs.point[4], 0.000001)
        assert.spy(_G.hooksecurefunc).was.called(1)
    end)

    describe("per-icon setting refresh", function()
        local options, defaults, utils, originalOptions

        before_each(function()
            options = QuestieLoader:ImportModule("QuestieOptions")
            defaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
            utils = QuestieLoader:ImportModule("QuestieOptionsUtils")
            originalOptions = {tabs = options.tabs, SetProfileValue = options.SetProfileValue, Load = defaults.Load,
                SetPfQuestIcons = utils.SetPfQuestIcons, DetermineTheme = utils.DetermineTheme,
                ExecuteTheme = utils.ExecuteTheme, Spacer = utils.Spacer}
            options.tabs = {}
            utils.Spacer = function() return {} end
            defaults.Load = function() return {profile = {}} end
            options.SetProfileValue = function(_, info, value) Questie.db.profile[info[#info]] = value end
            dofile("Localization/l10n.lua")
            dofile("Modules/Options/IconsTab/QuestieOptionsIcons.lua")
        end)

        after_each(function()
            options.tabs, options.SetProfileValue = originalOptions.tabs, originalOptions.SetProfileValue
            defaults.Load = originalOptions.Load
            utils.Spacer = originalOptions.Spacer
            utils.SetPfQuestIcons, utils.DetermineTheme, utils.ExecuteTheme =
                originalOptions.SetPfQuestIcons, originalOptions.DetermineTheme, originalOptions.ExecuteTheme
        end)

        it("reads the new loot scale after the actual option setter finishes, without refreshing cached geometry", function()
            Questie.db.profile.lootScale = 1
            objective.Type = "item"
            objective.spawnList[123].GetIconScale = function() return Questie.db.profile.lootScale end
            QuestieMap.RescaleIcons = spy.new(function()
                assert.are.equal(1, Questie.db.profile.lootScale) -- The setter has not written the new value yet.
            end)
            _G.hooksecurefunc = function(owner, name, callback)
                local original = owner[name]
                owner[name] = function(...)
                    original(...)
                    callback(...)
                end
            end
            quest.Id = 317
            Player.currentQuestlog = {[317] = quest}
            Update()
            quest = {Id = 384, Color = {1, 1, 1}, Objectives = {objective}}
            Player.currentQuestlog[384] = quest
            Update()
            FlushRefresh()
            assert.are_near(-5.6, frames[1].point[4], 0.000001)
            assert.are_near(5.6, frames[2].point[4], 0.000001)

            local iconOptions = options.tabs.icons:Initialize()
            iconOptions.args.icon_scales_group.args.lootScale.set({"lootScale"}, 2)
            assert.are.equal(2, Questie.db.profile.lootScale)
            assert.are.equal(1, frames[1].data.IconScale) -- RescaleIcons/geometry cached the old setting.
            assert.are_near(-5.6, frames[1].point[4], 0.000001) -- Waiting for the scheduled refresh.
            FlushRefresh()

            assert.are_near(-11.2, frames[1].point[4], 0.000001)
            assert.are_near(11.2, frames[2].point[4], 0.000001)
            assert.spy(Geometry.Build).was.called(2)
            assert.are.equal(2, #frames)
        end)
    end)

    it("keeps party-only objective rendering out of the local polygon cache", function()
        objective.IsPartyObjective = true
        Update()
        assert.spy(Geometry.Build).was.not_called()
        assert.are.equal(0, #frames)
    end)
end)
