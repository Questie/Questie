dofile("setupTests.lua")

describe("SourceModeStatus", function()
    local SourceModeStatus, QuestieStatus, Expansions, QuestieCompat
    local savedGlobals, originalExpansion, originalMetadata
    local globalNames = {
        "Questie", "LibQuestieDB", "GetBuildInfo", "GetCurrentRegion", "GetLocale", "C_Seasons", "Enum",
        "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC", "WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
        "WOW_PROJECT_WRATH_CLASSIC", "WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
    }

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do savedGlobals[name] = _G[name] end
        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        Expansions.Current = Expansions.Era
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        originalMetadata = QuestieCompat.GetAddOnMetadata
        QuestieCompat.GetAddOnMetadata = function(addon, key)
            if addon == "QuestieDB" and key == "Version" then return "1.0.4" end
            if addon == "Questie" and key == "X-QuestieDB-Contract" then return "3" end
        end
        _G.Questie = {
            IsForever = true, IsClassic = true, IsEra = true,
            IsTBC = false, IsWotlk = false, IsCata = false, IsMoP = false,
            IsSoM = false, IsSoD = false, IsTitanReforged = false, IsAnniversaryEra = false,
            IsAnniversaryTBC = false, IsAnniversaryHardcore = false, IsHardcore = false,
            IsChinaRegion = false, IsEURegion = true,
        }
        _G.GetBuildInfo = function() return "1.60.1", "70205", "Sep 29 2026", 16001 end
        _G.GetCurrentRegion = function() return 3 end
        _G.GetLocale = function() return "enUS" end
        _G.WOW_PROJECT_ID, _G.WOW_PROJECT_MAINLINE, _G.WOW_PROJECT_CLASSIC = 1, 1, 2
        _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC, _G.WOW_PROJECT_WRATH_CLASSIC = 5, 11
        _G.WOW_PROJECT_CATACLYSM_CLASSIC, _G.WOW_PROJECT_MISTS_CLASSIC = 14, 19
        _G.C_Seasons = {GetActiveSeason = function() return 0 end, HasActiveSeason = function() return false end}
        _G.Enum = {SeasonID = {SeasonOfMastery = 1, SeasonOfDiscovery = 2, Fresh = 11}}
        _G.LibQuestieDB = {
            readMode = "source", contractVersion = 3, minSupportedContract = 1,
            ModeIndicator = {GetStatus = function() return {mode = "source", expansion = "Forever", contractVersion = 3} end},
        }
        dofile("Modules/QuestieStatus.lua")
        QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")
        dofile("Modules/SourceModeStatus.lua")
        SourceModeStatus = QuestieLoader:ImportModule("SourceModeStatus")
    end)

    after_each(function()
        Expansions.Current = originalExpansion
        QuestieCompat.GetAddOnMetadata = originalMetadata
        for _, name in ipairs(globalNames) do _G[name] = savedGlobals[name] end
    end)

    it("distinguishes Forever's raw project, Questie content expansion, and provider data expansion", function()
        assert.is_true(SourceModeStatus.Update())

        local issues = QuestieStatus.GetIssues()
        assert.are_same("questiedb.source-mode", issues[1].id)
        assert.are_same({
            {message = "Client: %s (build %s, %s)", args = {"1.60.1", "70205", "Sep 29 2026"}},
            {message = "Interface: %s", args = {"16001"}},
            {message = "Project: %s (%s)", args = {"WOW_PROJECT_MAINLINE", "1"}},
            {message = "Questie expansion: %s (%s)", args = {"Era", "1"}},
            {message = "Season: %s (%s), active: %s", args = {"None", "0", "false"}},
            {message = "Region: %s (%s), locale: %s", args = {"EU", "3", "enUS"}},
            {message = "Client flags: %s", args = {
                "IsForever=true, IsClassic=true, IsEra=true, IsTBC=false, IsWotlk=false, IsCata=false, IsMoP=false",
            }},
            {message = "Realm flags: %s", args = {
                "IsSoM=false, IsSoD=false, IsTitanReforged=false, IsAnniversaryEra=false, " ..
                "IsAnniversaryTBC=false, IsAnniversaryHardcore=false, IsHardcore=false",
            }},
            {message = "Region flags: %s", args = {"IsChinaRegion=false, IsEURegion=true"}},
        }, issues[1].details)
        assert.are_same("questiedb.source-load", issues[2].id)
        assert.are_same({
            {message = "Provider version: %s", args = {"1.0.4"}},
            {message = "Data expansion: %s", args = {"Forever"}},
            {message = "Read mode: %s", args = {"source"}},
            {message = "Provider contracts: %s to %s; Questie requires %s", args = {"1", "3", "3"}},
        }, issues[2].details)
        assert.are_same("Interface\\AddOns\\Questie\\Icons\\green_plus.png", QuestieStatus.GetBadgeIssue().icon.texture)
        assert.are_same(issues[1].icon, issues[2].icon)
    end)

    it("reports Classic seasonal identity without using the season as the content expansion", function()
        _G.WOW_PROJECT_ID = 2
        Questie.IsForever, Questie.IsEra, Questie.IsSoD = false, false, true
        _G.GetBuildInfo = function() return "1.15.9", "70003", "Sep 2026", 11509 end
        C_Seasons.GetActiveSeason = function() return 2 end
        C_Seasons.HasActiveSeason = function() return true end
        LibQuestieDB.ModeIndicator.GetStatus = function() return {expansion = "Classic"} end

        SourceModeStatus.Update()

        local issues = QuestieStatus.GetIssues()
        assert.are_same({"WOW_PROJECT_CLASSIC", "2"}, issues[1].details[3].args)
        assert.are_same({"Era", "1"}, issues[1].details[4].args)
        assert.are_same({"SeasonOfDiscovery", "2", "true"}, issues[1].details[5].args)
        assert.are_same({"Classic"}, issues[2].details[2].args)
    end)

    it("names Titan's explicit season ID even when Blizzard has no enum entry", function()
        _G.WOW_PROJECT_ID = 11
        Expansions.Current = Expansions.Wotlk
        C_Seasons.GetActiveSeason = function() return 109 end
        C_Seasons.HasActiveSeason = function() return true end

        SourceModeStatus.Update()

        local details = QuestieStatus.GetIssues()[1].details
        assert.are_same({"WOW_PROJECT_WRATH_CLASSIC", "11"}, details[3].args)
        assert.are_same({"Wotlk", "3"}, details[4].args)
        assert.are_same({"TitanReforged", "109", "true"}, details[5].args)
    end)

    it("preserves unknown IDs and marks missing diagnostics instead of guessing a flavor", function()
        _G.WOW_PROJECT_ID = 999
        Expansions.Current = nil
        C_Seasons.GetActiveSeason = function() return 777 end
        LibQuestieDB.ModeIndicator = nil
        LibQuestieDB.minSupportedContract = nil
        QuestieCompat.GetAddOnMetadata = function() return nil end

        SourceModeStatus.Update()

        local issues = QuestieStatus.GetIssues()
        assert.are_same({"unknown", "999"}, issues[1].details[3].args)
        assert.are_same({"unavailable", "unavailable"}, issues[1].details[4].args)
        assert.are_same({"unknown", "777", "false"}, issues[1].details[5].args)
        assert.are_same({"unavailable"}, issues[2].details[1].args)
        assert.are_same({"unavailable"}, issues[2].details[2].args)
        assert.are_same({"unavailable", "3", "unavailable"}, issues[2].details[4].args)
    end)

    it("records an optional provider diagnostics failure without aborting startup reporting", function()
        LibQuestieDB.ModeIndicator.GetStatus = function() error("diagnostic failure", 0) end

        assert.is_true(SourceModeStatus.Update())

        local details = QuestieStatus.GetIssues()[2].details
        assert.are_same({message = "Provider diagnostics unavailable: %s", args = {"diagnostic failure"}}, details[5])
        assert.are_same({"source"}, details[3].args)
    end)

    it("updates its two notices in place and clears only those notices outside Source mode", function()
        SourceModeStatus.Update()
        LibQuestieDB.contractVersion = 4
        SourceModeStatus.Update()
        assert.are_same(2, #QuestieStatus.GetIssues())
        assert.are_same({"1", "4", "3"}, QuestieStatus.GetIssues()[2].details[4].args)
        QuestieStatus.Set("startup", {severity = QuestieStatus.Severity.Error, message = "Startup failed"})
        LibQuestieDB.readMode = "baked"

        assert.is_false(SourceModeStatus.Update())

        assert.are_same({{id = "startup", severity = QuestieStatus.Severity.Error, message = "Startup failed"}}, QuestieStatus.GetIssues())
    end)
end)
