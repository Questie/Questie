dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("SupportValidation", function()
    local validation, mock
    local originalMetadata, originalAddOns

    before_each(function()
        mock = LoadQuestieTDBMock()
        originalMetadata, originalAddOns = _G.GetAddOnMetadata, _G.C_AddOns
        _G.GetAddOnMetadata = nil
        _G.C_AddOns = nil
        dofile("Database/SupportValidation.lua")
        validation = QuestieLoader:ImportModule("SupportValidation")
    end)

    after_each(function()
        _G.GetAddOnMetadata, _G.C_AddOns = originalMetadata, originalAddOns
    end)

    ---Small independent fixture; no provider exports or legacy data files supply expected values.
    ---@return SupportValidationZones
    local function EraZones()
        return {
            zoneIDs = {ELWYNN_FOREST = 12, STORMWIND_CITY = 1519, DUN_MOROGH = 1},
            instanceIdToAreaId = {[33] = 209},
            areaIdToUiMapId = {[12] = 1429, [10073] = 1414},
            areaIdToUiMapIdOverride = {[10073] = 1414},
            uiMapIdToAreaId = {[1429] = 12, [113] = 0},
            uiMapIdToAreaIdOverride = {[113] = 0},
            subZoneToParentZone = {[2] = 40, [133] = 1},
            subZoneToParentZoneOverride = {[133] = 1},
            dungeons = {[206] = {"Utgarde Keep", {10057, 10058}, 495, {{495, 58.8, 48.3}}}},
        }
    end

    for _, case in ipairs({
        {name = "Era", expansion = 1, map = 1429, continent = 1414, reverseKey = 113, reverseValue = 0},
        {name = "TBC", expansion = 2, map = 1429, continent = 1414, reverseKey = 113, reverseValue = 0},
        {name = "Wotlk", expansion = 3, map = 1429, continent = 1414, reverseKey = 113, reverseValue = 0},
        {name = "Cata", expansion = 4, map = 1429, continent = 1414, reverseKey = 113, reverseValue = 0},
        {name = "MoP", expansion = 5, map = 37, continent = 12, reverseKey = 12, reverseValue = 10073},
    }) do
        it("accepts effective " .. case.name .. " zone maps and overrides", function()
            local zones = EraZones()
            zones.areaIdToUiMapId = {[12] = case.map, [10073] = case.continent}
            zones.areaIdToUiMapIdOverride = {[10073] = case.continent}
            zones.uiMapIdToAreaId = {[case.map] = 12, [case.reverseKey] = case.reverseValue}
            zones.uiMapIdToAreaIdOverride = {[case.reverseKey] = case.reverseValue}
            assert.is_true(validation.ValidateZones(zones, case.expansion))
        end)
    end

    for _, field in ipairs({"zoneIDs", "instanceIdToAreaId", "areaIdToUiMapId", "areaIdToUiMapIdOverride",
        "uiMapIdToAreaId", "uiMapIdToAreaIdOverride", "subZoneToParentZone", "subZoneToParentZoneOverride", "dungeons"}) do
        it("reports the missing zone table " .. field, function()
            local zones = EraZones()
            zones[field] = nil
            local valid, report = validation.ValidateZones(zones, 1)
            assert.is_false(valid)
            assert.matches("Dataset: Zones", report, 1, true)
            assert.matches(field, report, 1, true)
            assert.matches("actual nil", report, 1, true)
        end)
    end

    for _, case in ipairs({
        {name = "wrong Stormwind ID", path = {"zoneIDs", "STORMWIND_CITY"}, control = "zoneIDs.STORMWIND_CITY"},
        {name = "wrong Dun Morogh ID", path = {"zoneIDs", "DUN_MOROGH"}, control = "zoneIDs.DUN_MOROGH"},
        {name = "wrong reverse map", path = {"uiMapIdToAreaId", 1429}, control = "uiMapIdToAreaId[1429]"},
        {name = "wrong area override", path = {"areaIdToUiMapIdOverride", 10073}, control = "areaIdToUiMapIdOverride[10073]"},
        {name = "wrong reverse override", path = {"uiMapIdToAreaIdOverride", 113}, control = "uiMapIdToAreaIdOverride[113]"},
        {name = "wrong parent override", path = {"subZoneToParentZoneOverride", 133}, control = "subZoneToParentZoneOverride[133]"},
        {name = "wrong base parent", path = {"subZoneToParentZone", 2}, control = "subZoneToParentZone[2]"},
        {name = "wrong second alternative", path = {"dungeons", 206, 2, 2}, control = "dungeons[206].alternativeAreas[2]"},
        {name = "extra alternative", path = {"dungeons", 206, 2, 3}, control = "dungeons[206].alternativeAreas[3]"},
        {name = "wrong entrance area", path = {"dungeons", 206, 4, 1, 1}, control = "dungeons[206].entrance.area"},
        {name = "wrong entrance y", path = {"dungeons", 206, 4, 1, 3}, control = "dungeons[206].entrance.y"},
        {name = "wrong zone ID", path = {"zoneIDs", "ELWYNN_FOREST"}, control = "zoneIDs.ELWYNN_FOREST"},
        {name = "wrong instance", path = {"instanceIdToAreaId", 33}, control = "instanceIdToAreaId[33]"},
        {name = "wrong map", path = {"areaIdToUiMapId", 12}, control = "areaIdToUiMapId[12]"},
        {name = "unapplied area override", path = {"areaIdToUiMapId", 10073}, control = "areaIdToUiMapId[10073]"},
        {name = "unapplied reverse override", path = {"uiMapIdToAreaId", 113}, control = "uiMapIdToAreaId[113]"},
        {name = "unapplied parent override", path = {"subZoneToParentZone", 133}, control = "subZoneToParentZone[133]"},
        {name = "old scalar dungeon area", path = {"dungeons", 206, 2}, control = "dungeons[206].alternativeAreas[1]"},
        {name = "missing entrance shape", path = {"dungeons", 206, 4}, control = "dungeons[206].entrance.area"},
        {name = "wrong dungeon name", path = {"dungeons", 206, 1}, control = "dungeons[206].name"},
        {name = "wrong dungeon parent", path = {"dungeons", 206, 3}, control = "dungeons[206].parentArea"},
        {name = "wrong entrance coordinate", path = {"dungeons", 206, 4, 1, 2}, control = "dungeons[206].entrance.x"},
    }) do
        it("rejects " .. case.name, function()
            local zones = EraZones()
            local parent = zones
            for i = 1, #case.path - 1 do parent = parent[case.path[i]] end
            parent[case.path[#case.path]] = 999
            local valid, report = validation.ValidateZones(zones, 1)
            assert.is_false(valid)
            assert.matches(case.control .. ": expected ", report, 1, true)
            assert.matches(", actual ", report, 1, true)
        end)
    end

    for _, case in ipairs({
        {name = "Era", expansion = 1, db = {[2] = {30, 2450}}},
        {name = "TBC", expansion = 2, db = {[2] = {30, 2450}, [10289] = {61, 2400}}},
        {name = "Wotlk", expansion = 3, db = {[2] = {30, 2450}, [13068] = {80, 2200}}},
        {name = "Cata", expansion = 4, db = {[2] = {23, 1850}, [28757] = {3, 500}}},
        {name = "MoP", expansion = 5, db = {[2] = {23, 1850}, [29948] = {87, 129000}}},
    }) do
        it("accepts raw " .. case.name .. " XP and shared faction invariants including zero", function()
            assert.is_true(validation.ValidateQuestXP(case.db, case.expansion))
            assert.is_true(validation.ValidateFactionTemplates({[1] = 12, [2] = 10, [7] = 0}, case.expansion))
        end)
    end

    for _, case in ipairs({
        {name = "Era", expansion = 1, id = 2, level = 30, xp = 2450},
        {name = "TBC", expansion = 2, id = 10289, level = 61, xp = 2400},
        {name = "Wotlk", expansion = 3, id = 13068, level = 80, xp = 2200},
        {name = "Cata", expansion = 4, id = 28757, level = 3, xp = 500},
        {name = "MoP", expansion = 5, id = 29948, level = 87, xp = 129000},
    }) do
        it("requires the named " .. case.name .. " XP control", function()
            local valid, report = validation.ValidateQuestXP({}, case.expansion)
            assert.is_false(valid)
            assert.matches("db[" .. case.id .. "].level: expected " .. case.level .. ", actual nil", report, 1, true)
            assert.matches("db[" .. case.id .. "].xp: expected " .. case.xp .. ", actual nil", report, 1, true)
        end)
    end

    it("aggregates all XP row failures without nil-indexing scalar rows", function()
        local valid, report = validation.ValidateQuestXP({[2] = false, [10289] = {60, 1}}, 2)
        assert.is_false(valid)
        assert.matches("db[2].level: expected 30, actual nil", report, 1, true)
        assert.matches("db[2].xp: expected 2450, actual nil", report, 1, true)
        assert.matches("db[10289].level: expected 61, actual 60", report, 1, true)
        assert.matches("db[10289].xp: expected 2400, actual 1", report, 1, true)
    end)

    it("rejects missing XP and faction tables without throwing", function()
        assert.is_false(validation.ValidateQuestXP(nil, 1))
        assert.is_false(validation.ValidateFactionTemplates(false, 1))
    end)

    it("aggregates faction failures and does not treat missing zero as valid", function()
        local valid, report = validation.ValidateFactionTemplates({[1] = 13, [2] = 11}, 1)
        assert.is_false(valid)
        assert.matches("factionTemplate[1]: expected 12, actual 13", report, 1, true)
        assert.matches("factionTemplate[2]: expected 10, actual 11", report, 1, true)
        assert.matches("factionTemplate[7]: expected 0, actual nil", report, 1, true)
    end)

    for _, case in ipairs({
        {name = "Era", expansion = 1, source = "cmangos", corrections = {[725] = {[98] = -1}}},
        {name = "TBC", expansion = 2, source = "cmangos", corrections = {[725] = {[98] = -1}, [2633] = {[937] = -1}}},
        {name = "Wotlk", expansion = 3, source = "cmangos", corrections = {[725] = {[98] = -1}, [2633] = {[937] = -1}}},
        {name = "Cata", expansion = 4, source = "mangos3", corrections = {[725] = {[98] = -1}, [2633] = {[937] = -1}}},
        {name = "MoP", expansion = 5, source = "mangos3",
            corrections = {[725] = {[98] = -1}, [2633] = {[937] = -1}, [97530] = {[70997] = 100}}},
    }) do
        it("accepts selected " .. case.name .. " drops without fixing a volatile Wowhead rate", function()
            assert.is_true(validation.ValidateDropTables({[981] = {[327] = 71.1}}, {[182] = {[103] = 100}},
                case.corrections, case.source, case.expansion))
        end)
    end

    for _, rate in ipairs({0, -1, 101, "71", false, math.huge, 0/0}) do
        it("rejects unusable Wowhead rate " .. tostring(rate), function()
            local valid, report = validation.ValidateDropTables({[981] = {[327] = rate}}, {[182] = {[103] = 100}},
                {[725] = {[98] = -1}}, "cmangos", 1)
            assert.is_false(valid)
            assert.matches("Wowhead[981][327]: expected number > 0 and <= 100, actual", report, 1, true)
        end)
    end

    it("aggregates absent or malformed drop tables and the wrong selected source", function()
        local valid, report = validation.ValidateDropTables(nil, {[182] = false}, {}, "cmangos", 5)
        assert.is_false(valid)
        assert.matches("sourcePserver: expected mangos3, actual cmangos", report, 1, true)
        assert.matches("Wowhead[981][327]", report, 1, true)
        assert.matches("Pserver[182]: expected table, actual boolean", report, 1, true)
        assert.matches("Wowhead: expected table, actual nil", report, 1, true)
        assert.matches("Corrections[725][98]: expected -1, actual nil", report, 1, true)
        assert.matches("Corrections[2633][937]: expected -1, actual nil", report, 1, true)
        assert.matches("Corrections[97530][70997]: expected 100, actual nil", report, 1, true)
    end)

    it("does not retain a failed pass or mutate input tables", function()
        mock.lib.Support.Get = function() error("Validation must not read provider support") end
        local db = {[2] = {30, 2450}}
        assert.is_false(validation.ValidateQuestXP({}, 1))
        local valid, report = validation.ValidateQuestXP(db, 1)
        assert.is_true(valid)
        assert.is_nil(report)
        assert.are_same({[2] = {30, 2450}}, db)
    end)

    for _, mode in ipairs({"source", "baked"}) do
        it("reports " .. mode .. " with consumer flavor and unknown metadata", function()
            mock.lib.readMode = mode
            local _, report = validation.ValidateQuestXP({}, 5)
            assert.matches("Questie support-data validation failed. Initialization stopped.", report, 1, true)
            assert.matches("Dataset: QuestXP; consumer flavor: MoP; provider readMode: " .. mode, report, 1, true)
            assert.matches("Questie version: unknown; QuestieTDB version: unknown", report, 1, true)
        end)
    end

    it("uses modern addon version metadata when available", function()
        _G.C_AddOns = {GetAddOnMetadata = function(addon, key)
            assert.are_equal("Version", key)
            return ({Questie = "v11", QuestieTDB = "v2"})[addon]
        end}
        local _, report = validation.ValidateQuestXP({}, 1)
        assert.matches("Questie version: v11; QuestieTDB version: v2", report, 1, true)
    end)

    it("uses legacy addon metadata and handles a missing provider version", function()
        _G.GetAddOnMetadata = function(addon)
            return ({Questie = "v11"})[addon]
        end
        local _, report = validation.ValidateQuestXP({}, 1)
        assert.matches("Questie version: v11; QuestieTDB version: unknown", report, 1, true)
    end)
    it("reports malformed drop rows with their actual types", function()
        local valid, report = validation.ValidateDropTables({[981] = false}, {[182] = "bad"}, {[725] = false}, "cmangos", 1)
        assert.is_false(valid)
        assert.matches("Wowhead[981]: expected table, actual boolean", report, 1, true)
        assert.matches("Pserver[182]: expected table, actual string", report, 1, true)
        assert.matches("Corrections[725]: expected table, actual boolean", report, 1, true)
    end)

    it("reports missing parents once each rather than inventing malformed row types", function()
        local valid, report = validation.ValidateDropTables(nil, nil, nil, "cmangos", 1)
        assert.is_false(valid)
        assert.matches("Wowhead: expected table, actual nil", report, 1, true)
        assert.matches("Pserver: expected table, actual nil", report, 1, true)
        assert.matches("Corrections: expected table, actual nil", report, 1, true)
        assert.is_nil(report:find("Wowhead[981]: expected table", 1, true))
    end)

    it("accepts empty merge tables without retaining an earlier shape failure", function()
        local valid, report = validation.ValidateTableShapes({{"base", false}, {"override", nil}}, "Zones", 1)
        assert.is_false(valid)
        assert.matches("base: expected table, actual boolean", report, 1, true)
        assert.matches("override: expected table, actual nil", report, 1, true)
        valid, report = validation.ValidateTableShapes({{"base", {}}, {"override", {}}}, "Zones", 1)
        assert.is_true(valid)
        assert.is_nil(report)
    end)

end)
