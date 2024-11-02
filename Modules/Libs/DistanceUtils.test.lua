dofile("setupTests.lua")

describe("DistanceUtils", function()
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieDB
    local QuestieDB

    ---@type DistanceUtils
    local DistanceUtils

    local HBDMock = {}

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        HBDMock.GetPlayerWorldPosition = function() end
        HBDMock.GetWorldCoordinatesFromZone = function() end
        HBDMock.GetWorldDistance = function() end
        setmetatable(_G.LibStub, {
            __call = function() return HBDMock end
        })

        ZoneDB = require("Database.Zones.zoneDB")
        QuestieDB = require("Database.QuestieDB")
        DistanceUtils = require("Modules.Libs.DistanceUtils")
    end)

    describe("GetNearestSpawn", function()
        it("should return the nearest spawn", function()
            HBDMock.GetPlayerWorldPosition = spy.new(function()
                return 50, 50, 1
            end)
            HBDMock.GetWorldCoordinatesFromZone = spy.new(function(_, _, _, uiMapId)
                if uiMapId == 200 then
                    return 123, 456, 1
                end
                return 0, 0, 2
            end)
            HBDMock.GetWorldDistance = spy.new(function(_, instanceId)
                return instanceId == 1 and 0 or 100
            end)
            ZoneDB.GetUiMapIdByAreaId = spy.new(function(_, zoneId)
                return zoneId == 1 and 200 or 300
            end)
            local spawns = {
                [1] = {{50,50}},
                [2] = {{60,60}},
            }

            local bestSpawn, bestSpawnZone, bestDistance = DistanceUtils.GetNearestSpawn(spawns)

            assert.same({50,50}, bestSpawn)
            assert.equals(1, bestSpawnZone)
            assert.equals(0, bestDistance)

            assert.spy(HBDMock.GetPlayerWorldPosition).was_called()
            assert.spy(ZoneDB.GetUiMapIdByAreaId).was_called_with(_, 1)
            assert.spy(HBDMock.GetWorldCoordinatesFromZone).was_called_with(HBDMock, 0.5, 0.5, 200)
            assert.spy(HBDMock.GetWorldDistance).was_called_with(HBDMock, 1, 50, 50, 123, 456)
        end)
    end)

    describe("GetNearestObjective", function()
        it("should return the nearest objective", function()
            HBDMock.GetPlayerWorldPosition = spy.new(function()
                return 60, 60, 2
            end)
            ZoneDB.GetUiMapIdByAreaId = spy.new(function(_, zoneId)
                return zoneId == 1 and 200 or 300
            end)
            HBDMock.GetWorldCoordinatesFromZone = spy.new(function(_, _, _, uiMapId)
                if uiMapId == 300 then
                    return 123, 456, 2
                end
                return 0, 0, 1
            end)
            HBDMock.GetWorldDistance = spy.new(function(_, instanceId)
                return instanceId == 2 and 0 or 100
            end)
            local objectiveSpawnList = {{
                Name = "Objective 1",
                Spawns = {
                    [1] = {{50,50}},
                }
            }, {
                Name = "Objective 2",
                Spawns = {
                    [2] = {{60,60}},
                }
            }}

            local bestSpawn, bestSpawnZone, bestSpawnName, bestDistance = DistanceUtils.GetNearestObjective(objectiveSpawnList)

            assert.same({60,60}, bestSpawn)
            assert.equals(2, bestSpawnZone)
            assert.equals("Objective 2", bestSpawnName)
            assert.equals(0, bestDistance)
        end)
    end)

    describe("GetNearestFinisher", function()
        it("should return the nearest NPC finisher", function()
            QuestieDB.GetNPC = spy.new(function(_, id)
                if id == 123 then
                    return { id = 123, name = "Finisher 1", spawns = {[1]={{50,50}}} }
                else
                    return { id = 456, name = "Finisher 2", spawns = {[2]={{60,60}}} }
                end
            end)
            HBDMock.GetPlayerWorldPosition = spy.new(function()
                return 60, 60, 2
            end)
            ZoneDB.GetUiMapIdByAreaId = spy.new(function(_, zoneId)
                return zoneId == 1 and 200 or 300
            end)
            HBDMock.GetWorldCoordinatesFromZone = spy.new(function(_, _, _, uiMapId)
                if uiMapId == 300 then
                    return 123, 456, 2
                end
                return 0, 0, 1
            end)
            HBDMock.GetWorldDistance = spy.new(function(_, instanceId)
                return instanceId == 2 and 0 or 100
            end)
            local finisher = {NPC = {123,456}}

            local bestSpawn, bestSpawnZone, bestSpawnName, bestDistance = DistanceUtils.GetNearestFinisher(finisher)

            assert.same({60,60}, bestSpawn)
            assert.equals(2, bestSpawnZone)
            assert.equals("Finisher 2", bestSpawnName)
            assert.equals(0, bestDistance)
        end)
    end)
end)
