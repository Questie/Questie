dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("ZoneDB", function()
    ---@type ZoneDB
    local ZoneDB
    local zoneData

    before_each(function()
        _G["Questie"] = {db = {profile = {}}}
        _G.Questie.Debug = function() end
        _G.C_Map = {
            GetMapInfo = function() return nil end,
            GetAreaInfo = function() return nil end,
        }

        local mock = LoadQuestieTDBMock()
        -- Focused provider-shaped inputs, not a copy of the zone database.
        -- Fresh tables keep dungeon mutations and alternative IDs isolated between tests.
        zoneData = {
            zoneIDs = {
                DUN_MOROGH = 1,
                BURNING_STEPPES = 46,
                SEARING_GORGE = 51,
                FERALAS = 357,
                GNOMEREGAN = 721,
                DIRE_MAUL = 2557,
            },
            instanceIdToAreaId = {},
            private = {
                -- Both named areas must participate in lowest-ID name matching.
                areaIdToUiMapId = "return {[1] = 1426, [721] = 226}",
                areaIdToUiMapIdOverride = "return {[10073] = 1414}",
                uiMapIdToAreaId = "return {[1426] = 1, [226] = 721, [113] = 3979}",
                uiMapIdToAreaIdOverride = "return {[1414] = 10073, [1415] = 10074, [113] = 0, [1945] = 0}",
                subZoneToParentZone = "return {}",
                subZoneToParentZoneOverride = "return {[133] = 1}",
                dungeons = {
                    [2557] = {"Dire Maul", nil, 357, {{357, 59.2, 45.1}}},
                    [1584] = {"Blackrock Depths", {1585}, 51, {{51, 34.8, 85.3}, {46, 29.4, 38.3}}},
                },
            },
        }
        mock.supportModules.ZoneDB = zoneData
        dofile("Database/Zones/zoneDB.lua")
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")

        ZoneDB.Initialize()
    end)

    it("binds static tables without replacing the wrapper or its private functions", function()
        assert.are_not_equal(zoneData, ZoneDB)
        assert.are_not_equal(zoneData.private, ZoneDB.private)
        assert.are_equal(zoneData.zoneIDs, ZoneDB.zoneIDs)
        assert.are_equal(zoneData.instanceIdToAreaId, ZoneDB.instanceIdToAreaId)
        assert.are_equal(zoneData.private.dungeons, ZoneDB:GetDungeons())
        assert.is_function(ZoneDB.private.RunTests)
    end)

    it("decodes maps and applies overrides without changing the provider sources", function()
        zoneData.private.areaIdToUiMapId = "return {[10] = 20}"
        zoneData.private.areaIdToUiMapIdOverride = "return {[10] = 21}"
        zoneData.private.uiMapIdToAreaId = "return {[21] = 9}"
        zoneData.private.uiMapIdToAreaIdOverride = "return {[21] = 10}"
        zoneData.private.subZoneToParentZone = "return {[11] = 9}"
        zoneData.private.subZoneToParentZoneOverride = "return {[11] = 10}"
        dofile("Database/Zones/zoneDB.lua")
        ZoneDB.Initialize()
        assert.are_equal(21, ZoneDB:GetUiMapIdByAreaId(10))
        assert.are_equal(10, ZoneDB:GetAreaIdByUiMapId(21))
        assert.are_equal(10, ZoneDB:GetParentZoneId(11))
        ZoneDB.Initialize()
        assert.are_equal(21, ZoneDB:GetUiMapIdByAreaId(10))
        assert.are_equal("return {[10] = 20}", zoneData.private.areaIdToUiMapId)
        assert.are_equal("return {[21] = 9}", zoneData.private.uiMapIdToAreaId)
        assert.are_equal("return {[11] = 9}", zoneData.private.subZoneToParentZone)
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
                        return {name = "Dun Morogh"}
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
                    return {name = "Unknown Zone"}
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

    describe("GetAreaIdByName", function()
        it("should resolve a localized zone name to its AreaId", function()
            _G.C_Map.GetAreaInfo = function(areaId)
                if areaId == ZoneDB.zoneIDs.DUN_MOROGH then
                    return "Dun Morogh"
                end
            end

            assert.is_equal(ZoneDB.zoneIDs.DUN_MOROGH, ZoneDB:GetAreaIdByName("Dun Morogh"))
            assert.is_nil(ZoneDB:GetAreaIdByName("Nowhere"))
        end)

        it("should prefer the zone over a sub area sharing its name", function()
            _G.C_Map.GetAreaInfo = function(areaId)
                if areaId == ZoneDB.zoneIDs.DUN_MOROGH or areaId == ZoneDB.zoneIDs.GNOMEREGAN then
                    return "Same Name"
                end
            end

            assert.is_equal(ZoneDB.zoneIDs.DUN_MOROGH, ZoneDB:GetAreaIdByName("Same Name"))
        end)
    end)

    describe("IsDungeonZone", function()
        it("should return true for a primary dungeon areaId", function()
            assert.is_true(ZoneDB.IsDungeonZone(ZoneDB.zoneIDs.DIRE_MAUL))
        end)

        it("should return false for a non-dungeon areaId", function()
            assert.is_false(ZoneDB.IsDungeonZone(ZoneDB.zoneIDs.DUN_MOROGH))
        end)

        it("should return true for an alternative dungeon areaId", function()
            -- 1585 is the alternativeAreaId for Blackrock Depths (1584)
            assert.is_true(ZoneDB.IsDungeonZone(1585))
        end)
    end)

    describe("GetDungeonLocation", function()
        it("should return correct values for Dire Maul", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(ZoneDB.zoneIDs.DIRE_MAUL)
            assert.are_same({{ZoneDB.zoneIDs.FERALAS, 59.2, 45.1}}, dungeonLocation)
        end)

        it("should return correct values for alternative BRD ID", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(1585)
            assert.are_same({{ZoneDB.zoneIDs.SEARING_GORGE, 34.8, 85.3}, {ZoneDB.zoneIDs.BURNING_STEPPES, 29.4, 38.3}}, dungeonLocation)
        end)

        it("should return nil for non-dungeon areaId", function()
            local dungeonLocation = ZoneDB:GetDungeonLocation(ZoneDB.zoneIDs.DUN_MOROGH)
            assert.is_nil(dungeonLocation)
        end)

        it("should return correct values for all alternativeAreaIds when multiple are given", function()
            zoneData.private.dungeons = {
                [99991] = {"Test Dungeon", {99992, 99993}, 1, {{1, 10.0, 20.0}}},
            }
            dofile("Database/Zones/zoneDB.lua")
            ZoneDB.Initialize()

            assert.are_same({{1, 10.0, 20.0}}, ZoneDB:GetDungeonLocation(99991))
            assert.are_same({{1, 10.0, 20.0}}, ZoneDB:GetDungeonLocation(99992))
            assert.are_same({{1, 10.0, 20.0}}, ZoneDB:GetDungeonLocation(99993))
        end)
    end)
end)
