dofile("setupTests.lua")

describe("MapIconDrawer", function()
    ---@type MapIconDrawer
    local MapIconDrawer
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieFramePool
    local QuestieFramePool
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieLib
    local QuestieLib

    local function makeObjective(spawnListIds)
        local spawnList = {}
        local alreadySpawned = {}
        for _, id in ipairs(spawnListIds or {}) do
            spawnList[id] = {Name = "spawn_" .. id, Spawns = {}}
            alreadySpawned[id] = {mapRefs = {"mapFrame1"}, minimapRefs = {"minimapFrame1"}}
        end
        return {
            spawnList = spawnList,
            AlreadySpawned = alreadySpawned,
        }
    end

    local function makeIconsToDraw(entries)
        -- entries: list of {dist, id, zone, x, y, data}
        local iconsToDraw = {}
        for _, e in ipairs(entries) do
            local icon = {
                AlreadySpawnedId = e.id or 1,
                data = e.data or {},
                zone = e.zone or 100,
                UiMapID = e.zone or 100,
                x = e.x or 50,
                y = e.y or 50,
            }
            iconsToDraw[e.dist] = iconsToDraw[e.dist] or {}
            table.insert(iconsToDraw[e.dist], icon)
        end
        return iconsToDraw
    end

    before_each(function()
        Questie.db.profile = {objectiveFilterDistance = 0}

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.DrawWorldIcon = spy.new(function() return {}, {} end)
        QuestieMap.DrawWaypoints = spy.new(function() end)

        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
        QuestieFramePool.UnloadFrame = spy.new(function() end)

        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeonLocation = function() return nil end
        ZoneDB.GetUiMapIdByAreaId = function(id) return id end

        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetSpawnDistance = function() return 0 end

        dofile("Modules/Map/MapIconDrawer.lua")
        MapIconDrawer = QuestieLoader:ImportModule("MapIconDrawer")
    end)

    describe("UnloadObjectiveIcons", function()
        it("should unload all map and minimap frames for all spawns and reset AlreadySpawned", function()
            local mapFrame = {}
            local minimapFrame = {}
            local objective = {
                spawnList = {[1] = {}, [2] = {}},
                AlreadySpawned = {
                    [1] = {mapRefs = {mapFrame}, minimapRefs = {minimapFrame}},
                    [2] = {mapRefs = {}, minimapRefs = {}},
                },
            }

            local co = coroutine.create(function()
                MapIconDrawer:UnloadObjectiveIcons(objective)
            end)
            coroutine.resume(co)

            assert.spy(QuestieFramePool.UnloadFrame).was.called_with(QuestieFramePool, mapFrame)
            assert.spy(QuestieFramePool.UnloadFrame).was.called_with(QuestieFramePool, minimapFrame)
            assert.are_same({}, objective.AlreadySpawned)
        end)

        it("should do nothing when spawnList is empty", function()
            local objective = {spawnList = {}, AlreadySpawned = {}}

            local co = coroutine.create(function()
                MapIconDrawer:UnloadObjectiveIcons(objective)
            end)
            coroutine.resume(co)

            assert.spy(QuestieFramePool.UnloadFrame).was_not.called()
        end)

        it("should not error when a spawnList id has no entry in AlreadySpawned", function()
            local objective = {
                spawnList = {[99] = {}},
                AlreadySpawned = {},
            }

            local co = coroutine.create(function()
                MapIconDrawer:UnloadObjectiveIcons(objective)
            end)
            local ok, err = coroutine.resume(co)

            assert.is_true(ok, err)
            assert.spy(QuestieFramePool.UnloadFrame).was_not.called()
        end)

        it("should assert when not running in a coroutine", function()
            local objective = makeObjective({1})
            assert.has_error(function()
                MapIconDrawer:UnloadObjectiveIcons(objective)
            end)
        end)
    end)

    describe("DrawObjectiveIcons", function()
        it("should assert when not called from a coroutine", function()
            assert.has_error(function()
                MapIconDrawer:DrawObjectiveIcons(1, {}, {spawnList = {}, AlreadySpawned = {}}, 100)
            end)
        end)

        it("should call DrawWorldIcon and track refs in AlreadySpawned", function()
            local fakeMapIcon = {}
            local fakeMinimapIcon = {}
            QuestieMap.DrawWorldIcon = spy.new(function() return fakeMapIcon, fakeMinimapIcon end)

            local objective = {
                spawnList = {[1] = {}},
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}},
            }
            local iconsToDraw = makeIconsToDraw({{dist = 1.0, id = 1, zone = 100, x = 50, y = 50}})

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveIcons(1, iconsToDraw, objective, 100)
            end)
            coroutine.resume(co)

            assert.spy(QuestieMap.DrawWorldIcon).was.called()
            assert.are_equal(fakeMapIcon, objective.AlreadySpawned[1].mapRefs[1])
            assert.are_equal(fakeMinimapIcon, objective.AlreadySpawned[1].minimapRefs[1])
        end)

        it("should draw icons in closest-first order", function()
            -- verifies _GetIconsSortedByDistance is applied: icon at dist=1 drawn before dist=100
            local drawnZones = {}
            QuestieMap.DrawWorldIcon = spy.new(function(_, _, zone)
                table.insert(drawnZones, zone)
                return {}, {}
            end)

            local objective = {
                spawnList = {[1] = {}},
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}},
            }
            -- Two icons at different distances in different zones so we can tell them apart
            local iconsToDraw = makeIconsToDraw({
                {dist = 100.0, id = 1, zone = 999},
                {dist = 1.0, id = 1, zone = 111},
            })

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveIcons(1, iconsToDraw, objective, 100)
            end)
            coroutine.resume(co)

            assert.are_equal(111, drawnZones[1])
            assert.are_equal(999, drawnZones[2])
        end)

        it("should return lastIcon and iconPerZone correctly", function()
            local fakeMapIcon = {}
            QuestieMap.DrawWorldIcon = spy.new(function() return fakeMapIcon, {} end)

            local objective = {
                spawnList = {[1] = {}},
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}},
            }
            local iconsToDraw = makeIconsToDraw({{dist = 1.0, id = 1, zone = 100, x = 50, y = 60}})

            local lastIcon, iconPerZone
            local co = coroutine.create(function()
                lastIcon, iconPerZone = MapIconDrawer:DrawObjectiveIcons(1, iconsToDraw, objective, 100)
            end)
            coroutine.resume(co)

            assert.is_not_nil(lastIcon)
            assert.are_equal(50, lastIcon.x)
            assert.are_equal(60, lastIcon.y)
            assert.is_not_nil(iconPerZone[100])
            assert.are_equal(fakeMapIcon, iconPerZone[100][1])
        end)

        it("should stop drawing after maxPerType + 1 icons (pre-existing behaviour)", function()
            -- The loop guard is `> maxPerType`, so it draws one extra before breaking.
            QuestieMap.DrawWorldIcon = spy.new(function()
                return {}, {}
            end)

            local iconsToDraw = {}
            for i = 1, 5 do
                iconsToDraw[i * 1.0] = {{
                    AlreadySpawnedId = 1,
                    data = {},
                    zone = 100,
                    UiMapID = 100,
                    x = i * 10,
                    y = i * 10,
                }}
            end
            local objective = {
                spawnList = {[1] = {}},
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}}
            }

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveIcons(1, iconsToDraw, objective, 2)
            end)
            coroutine.resume(co)

            assert.spy(QuestieMap.DrawWorldIcon).was.called(3)
        end)

        it("should skip icons that are too close to already placed icons in the same zone", function()
            -- objectiveFilterDistance > 0 and GetSpawnDistance returns a small value
            Questie.db.profile.objectiveFilterDistance = 10
            QuestieLib.GetSpawnDistance = function() return 1 end -- always too close

            QuestieMap.DrawWorldIcon = spy.new(function()
                return {}, {}
            end)

            local objective = {
                spawnList = {[1] = {}},
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}},
            }
            -- Two icons in the same zone: first is drawn, second is filtered out
            local iconsToDraw = makeIconsToDraw({
                {dist = 1.0, id = 1, zone = 100, x = 10, y = 10},
                {dist = 2.0, id = 1, zone = 100, x = 11, y = 11},
            })

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveIcons(1, iconsToDraw, objective, 100)
            end)
            coroutine.resume(co)

            -- Only the first icon passes the distance filter; second is skipped
            assert.spy(QuestieMap.DrawWorldIcon).was.called(1)
        end)

        it("should draw two icons for a dungeon zone with dual entrances", function()
            local drawCalls = {}
            QuestieMap.DrawWorldIcon = spy.new(function(_, _, zone, x, y)
                table.insert(drawCalls, {zone = zone, x = x, y = y})
                return {}, {}
            end)
            ZoneDB.GetDungeonLocation = function()
                return {
                    {200, 30, 40},
                    {201, 70, 80},
                }
            end

            local objective = {
                spawnList = {[1] = {}},
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}},
            }
            local iconsToDraw = makeIconsToDraw({{dist = 1.0, id = 1, zone = 100, x = -1, y = -1}})

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveIcons(1, iconsToDraw, objective, 100)
            end)
            coroutine.resume(co)

            assert.are_equal(2, #drawCalls)
        end)
    end)

    describe("DrawObjectiveWaypoints", function()
        it("should assert when not called from a coroutine", function()
            local objective = {spawnList = {}}
            assert.has_error(function()
                MapIconDrawer:DrawObjectiveWaypoints(objective, nil, {})
            end)
        end)

        it("should call DrawWaypoints when iconPerZone has an entry for the zone", function()
            local fakeIconMap = {}
            local objective = {
                spawnList = {
                    [1] = {
                        Waypoints = {[100] = {{{50, 50}}}},
                        Hostile = false,
                    }
                },
                AlreadySpawned = {[1] = {mapRefs = {fakeIconMap}, minimapRefs = {}}}
            }

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveWaypoints(objective, nil, {[100] = {fakeIconMap, 50, 50}})
            end)
            coroutine.resume(co)

            assert.spy(QuestieMap.DrawWaypoints).was.called()
        end)

        it("should not call DrawWaypoints when spawnList has no Waypoints", function()
            local objective = {spawnList = {[1] = {Spawns = {}}}}

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveWaypoints(objective, nil, {})
            end)
            coroutine.resume(co)

            assert.spy(QuestieMap.DrawWaypoints).was_not.called()
        end)

        it("should draw a fallback icon and waypoints when the zone is absent from iconPerZone", function()
            local fakeMapIcon = {}
            local fakeMinimapIcon = {}
            QuestieMap.DrawWorldIcon = spy.new(function() return fakeMapIcon, fakeMinimapIcon end)

            local lastIcon = {data = {Icon = "icon"}, AlreadySpawnedId = 1}
            local objective = {
                spawnList = {
                    [1] = {
                        Waypoints = {[200] = {{{55, 65}}}},
                        Hostile = false,
                    }
                },
                AlreadySpawned = {[1] = {mapRefs = {}, minimapRefs = {}}}
            }
            local iconPerZone = {}

            local co = coroutine.create(function()
                MapIconDrawer:DrawObjectiveWaypoints(objective, lastIcon, iconPerZone)
            end)
            coroutine.resume(co)

            assert.spy(QuestieMap.DrawWorldIcon).was.called()
            assert.spy(QuestieMap.DrawWaypoints).was.called()
            assert.is_not_nil(iconPerZone[200])
        end)
    end)
end)
