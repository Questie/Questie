dofile("Modules/Libs/QuestieLoader.lua")
_G["Questie"] = {}
dofile("Database/Zones/dungeons.lua")
dofile("Database/Zones/zoneTables.lua")

describe("ZoneDB", function()
    ---@type ZoneDB
    local ZoneDB

    before_each(function()
        _G["Questie"] = {db={profile={}}}
        ZoneDB = require("Database.Zones.zoneDB")
        ZoneDB.Initialize()
    end)

    describe("GetAreaIdByUiMapId", function()
        it("should correctly handle map ID for Kalimdor and EK", function()
            local areaId = ZoneDB:GetAreaIdByUiMapId(1414)
            assert.are.equal(0, areaId)

            areaId = ZoneDB:GetAreaIdByUiMapId(1415)
            assert.are.equal(0, areaId)
        end)
    end)

    describe("GetDungeonLocation", function()
        it("should return correct values for Dire Maul", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(ZoneDB.zoneIDs.DIRE_MAUL)
            assert.are.same({{ZoneDB.zoneIDs.FERALAS, 59.2, 45.1}}, dungeonLocation)
        end)

        it("should return correct values for alternative BRD ID", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(1585)
            assert.are.same({{ZoneDB.zoneIDs.SEARING_GORGE, 34.8, 85.3},{ZoneDB.zoneIDs.BURNING_STEPPES, 29.4, 38.3}}, dungeonLocation)
        end)

        it("should return nil for non-dungeon areaId", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(ZoneDB.zoneIDs.DUN_MOROGH)
            assert.is_nil(dungeonLocation)
        end)
    end)
end)
