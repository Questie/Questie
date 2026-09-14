dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("DropDB support data", function()
    local mock, DropDB, Expansions
    local flags = {"IsClassic", "IsTBC", "IsWotlk", "IsCata", "IsMoP"}

    ---@param expansion number
    ---@return nil
    local function SelectExpansion(expansion)
        for index, flag in ipairs(flags) do Questie[flag] = index == expansion end
        Expansions.Current = expansion
    end

    local originalLoadstring

    after_each(function()
        _G.loadstring = originalLoadstring
    end)

    before_each(function()
        originalLoadstring = _G.loadstring
        dofile("Database/SupportValidation.lua")
        QuestieLoader:ImportModule("SupportValidation").ValidateDropTables = function() return true end
        mock = LoadQuestieTDBMock()
        Expansions = QuestieLoader:ImportModule("Expansions")
        SelectExpansion(Expansions.Era)
        mock.supportModules.QuestieItemDropCorrections = {
            Era = {[100] = {[1] = 10, [2] = 15}, [200] = {[1] = 12}},
            Tbc = {[100] = {[1] = 20}},
            Wotlk = {[100] = {[1] = 30}},
            Cata = {[100] = {[1] = 40}},
            MoP = {[100] = {[1] = 50}, [300] = {[1] = 60}},
        }
        dofile("Database/DropTables/dropDB.lua")
        DropDB = QuestieLoader:ImportModule("DropDB")
    end)

    for _, case in ipairs({
        {name = "Classic", expansion = 1, module = "QuestieClassicItemDrops", field = "cmangosData",
            source = "cmangos", correction = 10, otherNpc = {15, "questie"}},
        {name = "TBC", expansion = 2, module = "QuestieTBCItemDrops", field = "cmangosData",
            source = "cmangos", correction = 20},
        {name = "Wotlk", expansion = 3, module = "QuestieWotlkItemDrops", field = "cmangosData",
            source = "cmangos", correction = 30},
        {name = "Cata", expansion = 4, module = "QuestieCataItemDrops", field = "mangos3Data",
            source = "mangos3", correction = 40},
    }) do
        it("decodes only selected " .. case.name .. " sources and applies cumulative corrections", function()
            SelectExpansion(case.expansion)
            mock.supportModules[case.module] = {
                wowheadData = "return {[400] = {[1] = 45}, [500] = {[1] = 55}}",
                [case.field] = "return {[400] = {[1] = 65}}",
            }
            DropDB:Initialize()
            assert.are_same({case.correction, "questie"}, DropDB.GetItemDroprate(100, 1))
            assert.are_same({12, "questie"}, DropDB.GetItemDroprate(200, 1))
            assert.are_same({65, case.source}, DropDB.GetItemDroprate(400, 1))
            assert.are_same({55, "wowhead"}, DropDB.GetItemDroprate(500, 1))
            assert.is_nil(DropDB.GetItemDroprate(999, 1))
            -- Expansion overrides replace an item's whole row, not individual NPC entries.
            assert.are_same(case.otherNpc, DropDB.GetItemDroprate(100, 2))
            assert.are_same({[1] = 10, [2] = 15}, mock.supportModules.QuestieItemDropCorrections.Era[100])
        end)
    end

    it("combines MoP Wowhead with Cata mangos3 and applies MoP corrections", function()
        SelectExpansion(Expansions.MoP)
        mock.supportModules.QuestieMopItemDrops = {
            wowheadData = "return {[400] = {[1] = 45}, [500] = {[1] = 55}}",
            cmangosData = "return {[400] = {[1] = 65}}",
        }
        mock.supportModules.QuestieCataItemDrops = {mangos3Data = "return {[400] = {[1] = 75}}"}
        DropDB:Initialize()
        assert.are_same({50, "questie"}, DropDB.GetItemDroprate(100, 1))
        assert.are_same({12, "questie"}, DropDB.GetItemDroprate(200, 1))
        assert.are_same({60, "questie"}, DropDB.GetItemDroprate(300, 1))
        assert.are_same({75, "mangos3"}, DropDB.GetItemDroprate(400, 1))
        assert.are_same({55, "wowhead"}, DropDB.GetItemDroprate(500, 1))
        assert.is_nil(DropDB.GetItemDroprate(100, 2))
        assert.are_same({[1] = 10, [2] = 15}, mock.supportModules.QuestieItemDropCorrections.Era[100])
    end)

    it("preserves correction sentinels, zero and invalid-reference fallback", function()
        mock.supportModules.QuestieClassicItemDrops = {
            wowheadData = "return {[100] = {[1] = 45, [2] = 46}}",
            cmangosData = "return {[100] = {[1] = 65, [2] = 66, [3] = 67, [4] = 68}}",
        }
        mock.supportModules.QuestieItemDropCorrections.Era[100] = {[1] = -1, [2] = -2, [3] = -1, [4] = 0}
        DropDB:Initialize()
        assert.are_same({45, "wowhead"}, DropDB.GetItemDroprate(100, 1))
        assert.are_same({66, "cmangos"}, DropDB.GetItemDroprate(100, 2))
        assert.are_same({67, "cmangos"}, DropDB.GetItemDroprate(100, 3))
        assert.are_same({0, "questie"}, DropDB.GetItemDroprate(100, 4))
    end)

    it("does not leak later corrections or decoded writes into a subsequent initialization", function()
        mock.supportModules.QuestieMopItemDrops = {wowheadData = "return {}"}
        mock.supportModules.QuestieCataItemDrops = {mangos3Data = "return {}"}
        mock.supportModules.QuestieClassicItemDrops = {
            wowheadData = "return {[400] = {[1] = 45}}", cmangosData = "return {}",
        }
        SelectExpansion(Expansions.MoP)
        DropDB:Initialize()
        assert.are_same({60, "questie"}, DropDB.GetItemDroprate(300, 1))
        SelectExpansion(Expansions.Era)
        DropDB:Initialize()
        assert.are_same({10, "questie"}, DropDB.GetItemDroprate(100, 1))
        assert.is_nil(DropDB.GetItemDroprate(300, 1))
        DropDB.tableWowhead[400][1] = 99
        DropDB:Initialize()
        assert.are_same({45, "wowhead"}, DropDB.GetItemDroprate(400, 1))
        assert.is_nil(mock.supportModules.QuestieItemDropCorrections.Era[300])
        assert.are_not_equal(mock.supportModules.QuestieItemDropCorrections.Era, DropDB.tableCorrections)
    end)
    it("validates only selected decoded tables and effective corrections with debug disabled", function()
        Questie.db.profile.debugEnabled = false
        SelectExpansion(Expansions.MoP)
        mock.supportModules.QuestieMopItemDrops = {
            wowheadData = "return {[400] = {[1] = 45}}",
            cmangosData = "error('Unused MoP cmangos must not be decoded')",
        }
        mock.supportModules.QuestieCataItemDrops = {mangos3Data = "return {[400] = {[1] = 75}}"}
        local validator = spy.new(function(wowhead, pserver, corrections, source, expansion)
            assert.are_equal(DropDB.tableWowhead, wowhead)
            assert.are_equal(DropDB.tablePserver, pserver)
            assert.are_equal(DropDB.tableCorrections, corrections)
            assert.are_same({[400] = {[1] = 45}}, wowhead)
            assert.are_same({[400] = {[1] = 75}}, pserver)
            assert.are_same({[1] = 50}, corrections[100])
            assert.are_equal("mangos3", source)
            assert.are_equal(5, expansion)
            return false, "drop report"
        end)
        QuestieLoader:ImportModule("SupportValidation").ValidateDropTables = validator
        _G.loadstring = spy.new(originalLoadstring)
        local valid, report = DropDB:Initialize()
        assert.spy(_G.loadstring).was.called(2)
        assert.is_false(valid)
        assert.are_equal("drop report", report)
        assert.spy(validator).was.called(1)
        assert.are_same({[1] = 10, [2] = 15}, mock.supportModules.QuestieItemDropCorrections.Era[100])
    end)

    for _, field in ipairs({"wowheadData", "cmangosData"}) do
        for _, value in ipairs({"false", "nil", "42"}) do
            it("reports decoded " .. value .. " in " .. field .. " without throwing", function()
                dofile("Database/SupportValidation.lua")
                mock.supportModules.QuestieClassicItemDrops = {wowheadData = "return {}", cmangosData = "return {}"}
                mock.supportModules.QuestieClassicItemDrops[field] = "return " .. value
                _G.loadstring = spy.new(originalLoadstring)
                local valid, report = DropDB:Initialize()
                assert.is_false(valid)
                local path = field == "wowheadData" and "Wowhead" or "Pserver"
                local expectedType = ({["false"] = "boolean", ["nil"] = "nil", ["42"] = "number"})[value]
                assert.matches(path .. ": expected table, actual " .. expectedType, report, 1, true)
                assert.matches("Dataset: DropTables", report, 1, true)
                assert.spy(_G.loadstring).was.called(2)
            end)
        end
    end

    for _, flavor in ipairs({"Era", "Tbc", "Wotlk", "Cata", "MoP"}) do
        it("reports missing selected " .. flavor .. " corrections before merging", function()
            dofile("Database/SupportValidation.lua")
            SelectExpansion(Expansions.MoP)
            mock.supportModules.QuestieMopItemDrops = {wowheadData = "return {}"}
            mock.supportModules.QuestieCataItemDrops = {mangos3Data = "return {}"}
            mock.supportModules.QuestieItemDropCorrections[flavor] = nil
            local valid, report = DropDB:Initialize()
            assert.is_false(valid)
            assert.matches("QuestieItemDropCorrections." .. flavor .. ": expected table, actual nil", report, 1, true)
            assert.is_nil(DropDB.tableCorrections)
        end)
    end

    it("aggregates invalid decoded maps with a missing correction parent", function()
        dofile("Database/SupportValidation.lua")
        mock.supportModules.QuestieClassicItemDrops = {wowheadData = "return false", cmangosData = "return nil"}
        mock.supportModules.QuestieItemDropCorrections = nil
        local valid, report = DropDB:Initialize()
        assert.is_false(valid)
        assert.matches("Wowhead: expected table, actual boolean", report, 1, true)
        assert.matches("Pserver: expected table, actual nil", report, 1, true)
        assert.matches("QuestieItemDropCorrections: expected table, actual nil", report, 1, true)
    end)

    it("accepts empty Wotlk/Cata corrections and ignores unselected MoP corrections", function()
        dofile("Database/SupportValidation.lua")
        SelectExpansion(Expansions.Cata)
        mock.supportModules.QuestieCataItemDrops = {
            wowheadData = "return {[981] = {[327] = 71}}", mangos3Data = "return {[182] = {[103] = 100}}",
        }
        mock.supportModules.QuestieItemDropCorrections = {
            Era = {[725] = {[98] = -1}}, Tbc = {[2633] = {[937] = -1}}, Wotlk = {}, Cata = {}, MoP = false,
        }
        assert.is_true(DropDB:Initialize())
    end)

    it("aggregates scalar selected correction sources before merging", function()
        dofile("Database/SupportValidation.lua")
        SelectExpansion(Expansions.Tbc)
        mock.supportModules.QuestieTBCItemDrops = {wowheadData = "return {}", cmangosData = "return {}"}
        mock.supportModules.QuestieItemDropCorrections.Era = false
        mock.supportModules.QuestieItemDropCorrections.Tbc = "bad"
        local valid, report = DropDB:Initialize()
        assert.is_false(valid)
        assert.matches("QuestieItemDropCorrections.Era: expected table, actual boolean", report, 1, true)
        assert.matches("QuestieItemDropCorrections.Tbc: expected table, actual string", report, 1, true)
    end)

end)
