dofile("setupTests.lua")

describe("Client content detection", function()
    local globalNames = {
        "Questie", "QuestieLoader", "LibStub", "GetBuildInfo", "C_Seasons", "Enum", "C_GameRules",
        "WOW_PROJECT_ID", "WOW_PROJECT_CLASSIC", "WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
        "WOW_PROJECT_WRATH_CLASSIC", "WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
    }
    local savedGlobals

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        _G.Questie = nil
        dofile("Modules/Libs/QuestieLoader.lua")
        _G.LibStub = function()
            return {NewAddon = function() return {} end}
        end
        _G.WOW_PROJECT_ID = 2
        _G.WOW_PROJECT_CLASSIC = 2
        _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
        _G.WOW_PROJECT_WRATH_CLASSIC = 11
        _G.WOW_PROJECT_CATACLYSM_CLASSIC = 14
        _G.WOW_PROJECT_MISTS_CLASSIC = 19
        _G.GetBuildInfo = function() return "1.15.9", "test", "test", 11509 end
        _G.C_GameRules = nil
        _G.C_Seasons = {
            HasActiveSeason = function() return false end,
            GetActiveSeason = function() return 0 end,
        }
        _G.Enum = {
            SeasonID = {SeasonOfMastery = 1, SeasonOfDiscovery = 2, Fresh = 11, FreshHardcore = 12},
        }
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
    end)

    ---Replays TOC ordering; loadfile supplies the addon-name argument that dofile cannot pass.
    ---@return Expansions
    local function LoadClient()
        assert(loadfile("Modules/VersionCheck.lua"))("Questie", {})
        dofile("Modules/Expansions.lua")
        return QuestieLoader:ImportModule("Expansions")
    end

    it("maps Forever's Retail project ID to Classic content using its interface version", function()
        _G.WOW_PROJECT_ID = 1
        _G.GetBuildInfo = function() return "1.60.1", "69893", "Sep 16 2026", 16001 end

        local expansions = LoadClient()

        assert.is_true(Questie.IsForever)
        assert.is_true(Questie.IsClassic)
        assert.is_true(Questie.IsEra)
        assert.is_false(Questie.IsSoD)
        assert.is_false(Questie.IsTBC)
        assert.are.equal(expansions.Era, expansions.Current)
    end)

    it("does not map actual Retail to Classic content", function()
        _G.WOW_PROJECT_ID = 1
        _G.GetBuildInfo = function() return "12.0.7", "test", "test", 120007 end

        local expansions = LoadClient()

        assert.is_false(Questie.IsForever)
        assert.is_false(Questie.IsClassic)
        assert.is_false(Questie.IsEra)
        assert.is_nil(expansions.Current)
    end)

    it("keeps Classic Era detection unchanged", function()
        local expansions = LoadClient()

        assert.is_false(Questie.IsForever)
        assert.is_true(Questie.IsClassic)
        assert.is_true(Questie.IsEra)
        assert.are.equal(expansions.Era, expansions.Current)
    end)

    it("keeps Season of Discovery distinct from non-seasonal Classic", function()
        _G.C_Seasons.HasActiveSeason = function() return true end
        _G.C_Seasons.GetActiveSeason = function() return 2 end

        local expansions = LoadClient()

        assert.is_false(Questie.IsForever)
        assert.is_true(Questie.IsClassic)
        assert.is_false(Questie.IsEra)
        assert.is_true(Questie.IsSoD)
        assert.are.equal(expansions.Era, expansions.Current)
    end)

    local otherClients = {
        {name = "TBC", projectID = 5, interfaceVersion = 20505, flag = "IsTBC", expansion = 2},
        {name = "Wrath", projectID = 11, interfaceVersion = 30403, flag = "IsWotlk", expansion = 3},
        {name = "Cata", projectID = 14, interfaceVersion = 40402, flag = "IsCata", expansion = 4},
        {name = "MoP", projectID = 19, interfaceVersion = 50503, flag = "IsMoP", expansion = 5},
    }
    for _, client in ipairs(otherClients) do
        it("keeps " .. client.name .. " content detection unchanged", function()
            _G.WOW_PROJECT_ID = client.projectID
            _G.GetBuildInfo = function() return "test", "test", "test", client.interfaceVersion end

            local expansions = LoadClient()

            assert.is_false(Questie.IsForever)
            assert.is_false(Questie.IsClassic)
            assert.is_true(Questie[client.flag])
            assert.are.equal(client.expansion, expansions.Current)
        end)
    end

    it("does not treat an unrelated project as Classic", function()
        _G.WOW_PROJECT_ID = 999

        local expansions = LoadClient()

        assert.is_false(Questie.IsForever)
        assert.is_false(Questie.IsClassic)
        assert.is_nil(expansions.Current)
    end)
end)
