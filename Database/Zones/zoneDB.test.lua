dofile("setupTests.lua")

dofile("Database/Zones/data/dungeons.lua")
dofile("Database/Zones/data/zoneIds.lua")
dofile("Database/Zones/data/areaIdToUiMapId.lua")
dofile("Database/Zones/data/uiMapIdToAreaId.lua")
dofile("Database/Zones/data/subZoneToParentZone.lua")


describe("ZoneDB", function()
    ---@type ZoneDB
    local ZoneDB

    before_each(function()
        _G["Questie"] = {db={profile={}}}
        _G.Questie.Debug = function() end
        _G.C_Map = {
            GetMapInfo = function() return nil end,
            GetAreaInfo = function() return nil end,
        }

        dofile("Database/Zones/zoneDB.lua")
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.Initialize()
    end)

    describe("GetAreaIdByUiMapId", function()
        it("should correctly handle map ID for Kalimdor and EK", function()
            local areaId = ZoneDB:GetAreaIdByUiMapId(1414)
            assert.is_equal(10073, areaId)

            areaId = ZoneDB:GetAreaIdByUiMapId(1415)
            assert.is_equal(10074, areaId)
        end)

        it("should return 0 for continent-suppressed map IDs", function()
            -- uiMapIdToAreaId contains entries mapped to 0 (e.g. Northrend, Outland)
            -- to suppress icons when the player is on a continent map
            local areaId = ZoneDB:GetAreaIdByUiMapId(113) -- Northrend
            assert.is_equal(0, areaId)

            areaId = ZoneDB:GetAreaIdByUiMapId(1945) -- Outland
            assert.is_equal(0, areaId)
        end)

        it("should fall back to name-based matching when uiMapId is not in the table", function()
            _G.C_Map = {
                GetMapInfo = function(uiMapId)
                    if uiMapId == 99999 then
                        return { name = "Dun Morogh" }
                    end
                end,
                GetAreaInfo = function(areaId)
                    if areaId == ZoneDB.zoneIDs.DUN_MOROGH then
                        return "Dun Morogh"
                    end
                end,
            }

            local areaId = ZoneDB:GetAreaIdByUiMapId(99999)
            assert.is_equal(ZoneDB.zoneIDs.DUN_MOROGH, areaId)
        end)

        it("should error when uiMapId cannot be resolved", function()
            _G.C_Map = {
                GetMapInfo = function(_uiMapId)
                    return { name = "Unknown Zone" }
                end,
                GetAreaInfo = function(_areaId)
                    return "Something Else"
                end,
            }

            assert.has_error(function()
                ZoneDB:GetAreaIdByUiMapId(99999)
            end)
        end)
    end)

    describe("GetDungeonLocation", function()
        it("should return correct values for Dire Maul", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(ZoneDB.zoneIDs.DIRE_MAUL)
            assert.are_same({{ZoneDB.zoneIDs.FERALAS, 59.2, 45.1}}, dungeonLocation)
        end)

        it("should return correct values for alternative BRD ID", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(1585)
            assert.are_same({{ZoneDB.zoneIDs.SEARING_GORGE, 34.8, 85.3},{ZoneDB.zoneIDs.BURNING_STEPPES, 29.4, 38.3}}, dungeonLocation)
        end)

        it("should return nil for non-dungeon areaId", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(ZoneDB.zoneIDs.DUN_MOROGH)
            assert.is_nil(dungeonLocation)
        end)
    end)
end)
