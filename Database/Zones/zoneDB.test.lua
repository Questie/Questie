dofile("Modules/Libs/QuestieLoader.lua")
_G["Questie"] = {}
dofile("Database/Zones/zoneTables.lua")

describe("ZoneDB", function()
    ---@type ZoneDB
    local ZoneDB

    before_each(function()
        ZoneDB = require("Database.Zones.zoneDB")
    end)

    describe("GetAreaIdByUiMapId", function()
        it("should correctly handle map ID for Kalimdor and EK", function()
            local areaId = ZoneDB:GetAreaIdByUiMapId(1414)
            assert.are.equal(0, areaId)

            areaId = ZoneDB:GetAreaIdByUiMapId(1415)
            assert.are.equal(0, areaId)
        end)
    end)
end)
