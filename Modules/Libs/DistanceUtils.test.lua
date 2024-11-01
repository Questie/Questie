dofile("setupTests.lua")

describe("DistanceUtils", function()
    ---@type ZoneDB
    local ZoneDB

    ---@type DistanceUtils
    local DistanceUtils

    local HBDMock = {
        GetPlayerWorldPosition = function()
            return 0, 0, 0
        end,
        GetWorldCoordinatesFromZone = function()
            return 0, 0, 0
        end,
        GetWorldDistance = function()
            return 0
        end
    }

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        setmetatable(_G.LibStub, {
            __call = function() return HBDMock end
        })

        ZoneDB = require("Database.Zones.zoneDB")
        DistanceUtils = require("Modules.Libs.DistanceUtils")
    end)

    describe("GetNearestSpawn", function()
        it("should return the nearest spawn", function()
            HBDMock.GetPlayerWorldPosition = spy.new(function()
                return 50, 50, 1
            end)
            HBDMock.GetWorldCoordinatesFromZone = spy.new(function()
                return 123, 456, 1
            end)
            HBDMock.GetWorldDistance = spy.new(function()
                return 0
            end)
            ZoneDB.GetUiMapIdByAreaId = spy.new(function()
                return 200
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
end)
