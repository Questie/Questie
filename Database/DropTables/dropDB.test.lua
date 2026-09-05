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

    before_each(function()
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
end)
