dofile("setupTests.lua")

describe("ObjectiveIconProvider", function()
    ---@type ObjectiveIconProvider
    local ObjectiveIconProvider
    ---@type QuestieDB
    local QuestieDB
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieLib
    local QuestieLib
    ---@type Phasing
    local Phasing

    local function makeQuest(overrides)
        local q = {Id = 1, Color = {1, 1, 1, 1}, Starts = {}}
        for k, v in pairs(overrides or {}) do q[k] = v end
        return q
    end

    local function makeObjective(overrides)
        local o = {
            Id = 10,
            Index = 1,
            Type = "monster",
            Description = "Kill things",
            Completed = false,
            spawnList = {},
            AlreadySpawned = {},
        }
        for k, v in pairs(overrides or {}) do o[k] = v end
        return o
    end

    before_each(function()
        Questie.db.profile = {
            monsterScale = 1,
            objectScale = 1,
            eventScale = 1.35,
            lootScale = 1,
            enableObjectives = true,
        }
        Questie.ICON_TYPE_SLAY = "slay"
        Questie.ICON_TYPE_OBJECT = "object"
        Questie.ICON_TYPE_EVENT = "event"
        Questie.ICON_TYPE_LOOT = "loot"

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryNPCSingle = function() return nil end
        QuestieDB.QueryObjectSingle = function() return nil end
        QuestieDB.GetItem = function() return nil end

        local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.questNPCBlacklist = {}

        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetUiMapIdByAreaId = function(id) return id end

        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.Euclid = function(x1, y1, x2, y2)
            return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        end

        Phasing = QuestieLoader:ImportModule("Phasing")
        Phasing.IsSpawnVisible = function() return true end

        _G.LibStub = {GetLibrary = function() return {} end}
        setmetatable(_G.LibStub, {
            __call = function()
                return {
                    GetWorldCoordinatesFromZone = function(_, x, y, _) return x * 100, y * 100, true end,
                    Fetch = function() return "Font" end,
                }
            end
        })

        _G.DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
        _G.DistanceUtils.GetNearestFinisherOrStarter = function() return {x = 0, y = 0} end

        dofile("Modules/Quest/SpawnListBuilders.lua")
        dofile("Modules/Quest/ObjectiveIconProvider.lua")
        ObjectiveIconProvider = QuestieLoader:ImportModule("ObjectiveIconProvider")
    end)

    -- -------------------------------------------------------------------------
    -- BuildSpawnList
    -- -------------------------------------------------------------------------
    describe("BuildSpawnList", function()
        it("should build a monster spawn list when the builder exists for the type", function()
            QuestieDB.QueryNPCSingle = function(_, key)
                if key == "name" then return "TestMob" end
                if key == "spawns" then return {[100] = {{50, 50}}} end
                return nil
            end

            local objective = makeObjective({Id = 42, Type = "monster"})
            ObjectiveIconProvider:BuildSpawnList(objective, {Type = "monster"})

            assert.is_not_nil(objective.spawnList[42])
            assert.are_equal("TestMob", objective.spawnList[42].Name)
        end)

        it("should not overwrite an already-populated spawnList", function()
            local existingSpawnList = {[99] = {Name = "Existing"}}
            local objective = makeObjective({Id = 42, Type = "monster", spawnList = existingSpawnList})

            ObjectiveIconProvider:BuildSpawnList(objective, {Type = "monster"})

            assert.are_equal("Existing", objective.spawnList[99].Name)
        end)

        it("should do nothing when no builder exists for the objective type", function()
            local objective = makeObjective({Type = "unknown_type"})

            ObjectiveIconProvider:BuildSpawnList(objective, {Type = "unknown_type"})

            assert.are_same({}, objective.spawnList)
        end)
    end)

    -- -------------------------------------------------------------------------
    -- BuildIconsToDraw
    -- -------------------------------------------------------------------------
    describe("BuildIconsToDraw", function()
        local function makeSpawnList()
            return {
                [1] = {
                    Id = 1, Name = "Mob", Icon = "slay",
                    GetIconScale = function() return 1 end,
                    Spawns = {[100] = {{50, 60}}},
                }
            }
        end

        it("should return iconsToDraw keyed by distance for each visible spawn", function()
            local objective = makeObjective({spawnList = makeSpawnList()})

            local iconsToDraw = ObjectiveIconProvider:BuildIconsToDraw(makeQuest(), objective, 1, {x = 0, y = 0})

            local count = 0
            for _ in pairs(iconsToDraw) do count = count + 1 end
            assert.is_true(count > 0)
        end)

        it("should skip spawns where Phasing.IsSpawnVisible returns false", function()
            Phasing.IsSpawnVisible = function() return false end
            local objective = makeObjective({spawnList = makeSpawnList()})

            local iconsToDraw = ObjectiveIconProvider:BuildIconsToDraw(makeQuest(), objective, 1, {x = 0, y = 0})

            assert.are_same({}, iconsToDraw)
        end)

        it("should skip spawns when enableObjectives is false", function()
            Questie.db.profile.enableObjectives = false
            local objective = makeObjective({spawnList = makeSpawnList()})

            local iconsToDraw = ObjectiveIconProvider:BuildIconsToDraw(makeQuest(), objective, 1, {x = 0, y = 0})

            assert.are_same({}, iconsToDraw)
        end)

        it("should set up AlreadySpawned slots for each new spawn", function()
            local objective = makeObjective({spawnList = makeSpawnList()})

            ObjectiveIconProvider:BuildIconsToDraw(makeQuest(), objective, 1, {x = 0, y = 0})

            assert.is_not_nil(objective.AlreadySpawned[1])
            assert.are_same({}, objective.AlreadySpawned[1].mapRefs)
            assert.are_same({}, objective.AlreadySpawned[1].minimapRefs)
        end)

        it("should not re-add AlreadySpawned entries that already exist", function()
            local existingEntry = {mapRefs = {"existing"}, minimapRefs = {}}
            local objective = makeObjective({
                spawnList = makeSpawnList(),
                AlreadySpawned = {[1] = existingEntry},
            })

            ObjectiveIconProvider:BuildIconsToDraw(makeQuest(), objective, 1, {x = 0, y = 0})

            assert.are_equal(existingEntry, objective.AlreadySpawned[1])
        end)
    end)

    -- -------------------------------------------------------------------------
    -- GetObjectiveCenter
    -- -------------------------------------------------------------------------
    describe("GetObjectiveCenter", function()
        it("should return zone-center coords when the objective spans exactly one zone", function()
            local objective = makeObjective({
                spawnList = {[1] = {Spawns = {[100] = {{10, 10}}}}}
            })

            local center = ObjectiveIconProvider:GetObjectiveCenter(makeQuest(), objective)

            assert.is_not_nil(center.x)
            assert.is_not_nil(center.y)
        end)

        it("should fall back to nearest finisher/starter when objective spans multiple zones", function()
            local nearestCalled = false
            _G.DistanceUtils.GetNearestFinisherOrStarter = function()
                nearestCalled = true
                return {x = 5, y = 10}
            end

            local objective = makeObjective({
                spawnList = {[1] = {Spawns = {[100] = {{10, 10}}, [200] = {{20, 20}}}}}
            })

            local center = ObjectiveIconProvider:GetObjectiveCenter(makeQuest(), objective)

            assert.is_true(nearestCalled)
            assert.are_equal(5, center.x)
        end)

        it("should return {x=0, y=0} when no valid center can be determined", function()
            _G.DistanceUtils.GetNearestFinisherOrStarter = function() return nil end
            setmetatable(_G.LibStub, {
                __call = function()
                    return {
                        GetWorldCoordinatesFromZone = function() return nil, nil, false end,
                        Fetch = function() return "Font" end,
                    }
                end
            })
            dofile("Modules/Quest/SpawnListBuilders.lua")
            dofile("Modules/Quest/ObjectiveIconProvider.lua")
            ObjectiveIconProvider = QuestieLoader:ImportModule("ObjectiveIconProvider")

            local objective = makeObjective({
                spawnList = {[1] = {Spawns = {[100] = {{10, 10}}}}}
            })

            local center = ObjectiveIconProvider:GetObjectiveCenter(makeQuest(), objective)

            assert.are_equal(0, center.x)
            assert.are_equal(0, center.y)
        end)
    end)
end)
