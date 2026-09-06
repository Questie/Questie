dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("ZoneDB", function()
    ---@type ZoneDB
    local ZoneDB
    local zoneData

    local originalLoadstring

    after_each(function()
        _G.loadstring = originalLoadstring
    end)

    before_each(function()
        originalLoadstring = _G.loadstring
        dofile("Database/SupportValidation.lua")
        QuestieLoader:ImportModule("SupportValidation").ValidateZones = function() return true end
        _G["Questie"] = {db = {profile = {}}}
        _G.Questie.Debug = function() end
        _G.C_Map = {
            GetMapInfo = function() return nil end,
            GetAreaInfo = function() return nil end,
        }

        local mock = LoadQuestieTDBMock()
        zoneData = {private = {}}
        -- Execute legacy fixtures into an isolated stand-in, never the bound wrapper.
        local fixtureLoader = {ImportModule = function(_, name)
            if name == "ZoneDB" then return zoneData end
            return QuestieLoader:ImportModule(name)
        end}
        for _, file in ipairs({"dungeons", "zoneIds", "instanceIdToAreaId", "areaIdToUiMapId", "uiMapIdToAreaId", "subZoneToParentZone"}) do
            local chunk = assert(loadfile("Database/Zones/data/" .. file .. ".lua"))
            setfenv(chunk, setmetatable({QuestieLoader = fixtureLoader}, {__index = _G}))
            chunk()
        end
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
    it("validates actual decoded and overridden maps with debug disabled before dungeon indexing", function()
        Questie.db.profile.debugEnabled = false
        -- A rejected old scalar row must never reach ipairs in the index builder.
        ZoneDB.private.dungeons = {[206] = {"Utgarde Keep", 10057}}
        local validator = spy.new(function(zones, expansion)
            assert.are_equal(QuestieLoader:ImportModule("Expansions").Current, expansion)
            assert.are_equal(ZoneDB.zoneIDs, zones.zoneIDs)
            assert.are_equal(ZoneDB.instanceIdToAreaId, zones.instanceIdToAreaId)
            assert.are_equal(ZoneDB.private.dungeons, zones.dungeons)
            assert.are_equal(1414, zones.areaIdToUiMapId[10073])
            assert.are_equal(1414, zones.areaIdToUiMapIdOverride[10073])
            assert.are_equal(0, zones.uiMapIdToAreaId[113])
            assert.are_equal(0, zones.uiMapIdToAreaIdOverride[113])
            assert.are_equal(1, zones.subZoneToParentZone[133])
            assert.are_equal(1, zones.subZoneToParentZoneOverride[133])
            return false, "zone report"
        end)
        QuestieLoader:ImportModule("SupportValidation").ValidateZones = validator
        _G.loadstring = spy.new(originalLoadstring)
        local valid, report = ZoneDB.Initialize()
        assert.spy(_G.loadstring).was.called(6)
        assert.is_false(valid)
        assert.are_equal("zone report", report)
        assert.spy(validator).was.called(1)
    end)

    for _, field in ipairs({"areaIdToUiMapId", "areaIdToUiMapIdOverride", "uiMapIdToAreaId",
        "uiMapIdToAreaIdOverride", "subZoneToParentZone", "subZoneToParentZoneOverride"}) do
        for _, value in ipairs({"false", "nil", "42"}) do
            it("reports decoded " .. value .. " in " .. field .. " before merging", function()
                dofile("Database/SupportValidation.lua")
                ZoneDB.private[field] = "return " .. value
                _G.loadstring = spy.new(originalLoadstring)
                local valid, report = ZoneDB.Initialize()
                assert.is_false(valid)
                local expectedType = ({["false"] = "boolean", ["nil"] = "nil", ["42"] = "number"})[value]
                assert.matches(field .. ": expected table, actual " .. expectedType, report, 1, true)
                assert.matches("Dataset: Zones", report, 1, true)
                assert.spy(_G.loadstring).was.called(6)
            end)
        end
    end

    it("aggregates malformed merge inputs before writing any overrides", function()
        ZoneDB.private.areaIdToUiMapId = "return false"
        ZoneDB.private.uiMapIdToAreaIdOverride = "return nil"
        local valid, report = ZoneDB.Initialize()
        assert.is_false(valid)
        assert.matches("areaIdToUiMapId: expected table, actual boolean", report, 1, true)
        assert.matches("uiMapIdToAreaIdOverride: expected table, actual nil", report, 1, true)
    end)

end)
