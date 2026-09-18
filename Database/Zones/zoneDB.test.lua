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
        _G["Questie"] = {db = {profile = {}}}
        _G.Questie.Debug = function() end
        _G.C_Map = {
            GetMapInfo = function() return nil end,
            GetAreaInfo = function() return nil end,
        }

        dofile("Database/Zones/zoneDB.lua")
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.Initialize()
    end)

    describe("Forever zone overlay", function()
        local originalAreaOverlay
        local originalSubZoneOverlay

        before_each(function()
            originalAreaOverlay = ZoneDB.private.clientAreaIdToUiMapId
            originalSubZoneOverlay = ZoneDB.private.clientSubZoneToParentZone
            dofile("Database/Zones/data/Forever/zoneData.lua")
            ZoneDB.Initialize()
        end)

        after_each(function()
            ZoneDB.private.clientAreaIdToUiMapId = originalAreaOverlay
            ZoneDB.private.clientSubZoneToParentZone = originalSubZoneOverlay
        end)

        it("resolves all five reviewed maps in both directions", function()
            local mappings = {{616, 2482}, {16591, 2548}, {16593, 2521}, {16606, 2524}, {16651, 2652}}
            for _, mapping in ipairs(mappings) do
                assert.are.equal(mapping[2], ZoneDB:GetUiMapIdByAreaId(mapping[1]))
                assert.are.equal(mapping[1], ZoneDB:GetAreaIdByUiMapId(mapping[2]))
            end
        end)

        it("adds new subzones without dropping authored navigation mappings", function()
            assert.are.equal(16593, ZoneDB:GetParentZoneId(16622))
            assert.are.equal(16651, ZoneDB:GetParentZoneId(2657))
            assert.are.equal(16591, ZoneDB:GetParentZoneId(17809))
            assert.are.equal(10073, ZoneDB:GetAreaIdByUiMapId(1414))
            assert.are.equal(10000, ZoneDB:GetAreaIdByUiMapId(281))
            assert.are.same({{357, 59.2, 45.1}}, ZoneDB:GetDungeonLocation(2557))
        end)
    end)

    it("retains shared mappings when the Camelot-only overlay is not loaded", function()
        assert.are.equal(198, ZoneDB:GetUiMapIdByAreaId(616))
        assert.is_nil(ZoneDB:GetUiMapIdByAreaId(16593))
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
            local testDungeons = ZoneDB:GetDungeons()
            testDungeons[99991] = {"Test Dungeon", {99992, 99993}, 1, {{1, 10.0, 20.0}}}
            ZoneDB.Initialize()

            assert.are_same({{1, 10.0, 20.0}}, ZoneDB:GetDungeonLocation(99991))
            assert.are_same({{1, 10.0, 20.0}}, ZoneDB:GetDungeonLocation(99992))
            assert.are_same({{1, 10.0, 20.0}}, ZoneDB:GetDungeonLocation(99993))
        end)
    end)
end)
