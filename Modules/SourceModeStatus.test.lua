dofile("setupTests.lua")

describe("SourceModeStatus", function()
    local GOLD, GREEN, RED, GREY = "|cffffd100", "|cff40ff40", "|cffff8080", "|cff909090"
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
        assert.are_same(QuestieStatus.Severity.Info, issues[1].severity)
        assert.are_same("QuestieDB is running in Source mode.", issues[1].message)
        assert.are_same({
            {message = "Client: %s (build %s, %s)", args = {GOLD .. "1.60.1|r", GOLD .. "70205|r", GOLD .. "Sep 29 2026|r"}},
            {message = "Interface: %s", args = {GOLD .. "16001|r"}},
            {message = "Project: %s (%s)", args = {GOLD .. "WOW_PROJECT_MAINLINE|r", GOLD .. "1|r"}},
            {message = "Questie expansion: %s (%s)", args = {GOLD .. "Era|r", GOLD .. "1|r"}},
            {message = "Season: %s (%s), active: %s", args = {GOLD .. "None|r", GOLD .. "0|r", RED .. "false|r"}},
            {message = "Region: %s (%s), locale: %s", args = {GOLD .. "EU|r", GOLD .. "3|r", GOLD .. "enUS|r"}},
            {message = "Client flags: %s", args = {
                "IsForever: " .. GREEN .. "true|r, IsClassic: " .. GREEN .. "true|r, IsEra: " .. GREEN .. "true|r, " ..
                "IsTBC: " .. RED .. "false|r, IsWotlk: " .. RED .. "false|r, IsCata: " .. RED .. "false|r, IsMoP: " .. RED .. "false|r",
            }},
            {message = "Realm flags: %s", args = {
                "IsSoM: " .. RED .. "false|r, IsSoD: " .. RED .. "false|r, IsTitanReforged: " .. RED .. "false|r, " ..
                "IsAnniversaryEra: " .. RED .. "false|r, IsAnniversaryTBC: " .. RED .. "false|r, " ..
                "IsAnniversaryHardcore: " .. RED .. "false|r, IsHardcore: " .. RED .. "false|r",
            }},
            {message = "Region flags: %s", args = {"IsChinaRegion: " .. RED .. "false|r, IsEURegion: " .. GREEN .. "true|r"}},
        }, issues[1].details)
        assert.are_same("questiedb.source-load", issues[2].id)
        assert.are_same(QuestieStatus.Severity.Info, issues[2].severity)
        assert.are_same("QuestieDB Source load information.", issues[2].message)
        assert.are_same({
            {message = "Provider version: %s", args = {GOLD .. "1.0.4|r"}},
            {message = "Data expansion: %s", args = {GOLD .. "Forever|r"}},
            {message = "Read mode: %s", args = {GOLD .. "source|r"}},
            {message = "Provider contracts: %s to %s; Questie requires %s", args = {GOLD .. "1|r", GOLD .. "3|r", GOLD .. "3|r"}},
        }, issues[2].details)
        assert.are_same("Interface\\AddOns\\Questie\\Icons\\green_plus.png", QuestieStatus.GetBadgeIssue().icon.texture)
        assert.are_same(issues[1].icon, issues[2].icon)
    end)

    it("preserves value colors when detail labels are translated on hover", function()
        Questie.db = {profile = {}}
        dofile("Localization/l10n.lua")
        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.translations["Project: %s (%s)"] = {deDE = "Projekt: %s (%s)"}
        l10n.translations["Client flags: %s"] = {deDE = "Client-Flags: %s"}
        l10n:SetUILocale("deDE")
        SourceModeStatus.Update()
        local details = QuestieStatus.GetIssues()[1].details

        assert.are_same("Projekt: " .. GOLD .. "WOW_PROJECT_MAINLINE|r (" .. GOLD .. "1|r)",
            l10n(details[3].message, unpack(details[3].args)))
        assert.matches("Client-Flags: IsForever: " .. GREEN .. "true|r",
            l10n(details[7].message, unpack(details[7].args)), 1, true)
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
        assert.are_same({GOLD .. "WOW_PROJECT_CLASSIC|r", GOLD .. "2|r"}, issues[1].details[3].args)
        assert.are_same({GOLD .. "Era|r", GOLD .. "1|r"}, issues[1].details[4].args)
        assert.are_same({GOLD .. "SeasonOfDiscovery|r", GOLD .. "2|r", GREEN .. "true|r"}, issues[1].details[5].args)
        assert.are_same({GOLD .. "Classic|r"}, issues[2].details[2].args)
    end)

    it("names Titan's explicit season ID even when Blizzard has no enum entry", function()
        _G.WOW_PROJECT_ID = 11
        Expansions.Current = Expansions.Wotlk
        C_Seasons.GetActiveSeason = function() return 109 end
        C_Seasons.HasActiveSeason = function() return true end

        SourceModeStatus.Update()

        local details = QuestieStatus.GetIssues()[1].details
        assert.are_same({GOLD .. "WOW_PROJECT_WRATH_CLASSIC|r", GOLD .. "11|r"}, details[3].args)
        assert.are_same({GOLD .. "Wotlk|r", GOLD .. "3|r"}, details[4].args)
        assert.are_same({GOLD .. "TitanReforged|r", GOLD .. "109|r", GREEN .. "true|r"}, details[5].args)
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
        assert.are_same({GREY .. "unknown|r", GOLD .. "999|r"}, issues[1].details[3].args)
        assert.are_same({GREY .. "unavailable|r", GREY .. "unavailable|r"}, issues[1].details[4].args)
        assert.are_same({GREY .. "unknown|r", GOLD .. "777|r", RED .. "false|r"}, issues[1].details[5].args)
        assert.are_same({GREY .. "unavailable|r"}, issues[2].details[1].args)
        assert.are_same({GREY .. "unavailable|r"}, issues[2].details[2].args)
        assert.are_same({GREY .. "unavailable|r", GOLD .. "3|r", GREY .. "unavailable|r"}, issues[2].details[4].args)
    end)

    it("records an optional provider diagnostics failure without aborting startup reporting", function()
        LibQuestieDB.ModeIndicator.GetStatus = function() error("diagnostic failure", 0) end

        assert.is_true(SourceModeStatus.Update())

        local details = QuestieStatus.GetIssues()[2].details
        assert.are_same({message = "Provider diagnostics unavailable: %s", args = {"diagnostic failure"}}, details[5])
        assert.are_same({GOLD .. "source|r"}, details[3].args)
    end)

    it("keeps reporting when a client season getter fails even with no active season", function()
        C_Seasons.GetActiveSeason = function() error("season API failed", 0) end

        assert.is_true(SourceModeStatus.Update())

        local issues = QuestieStatus.GetIssues()
        assert.are_same({{message = "Client diagnostics unavailable: %s", args = {"season API failed"}}}, issues[1].details)
        assert.are_same({GOLD .. "Forever|r"}, issues[2].details[2].args)
        assert.are_same(QuestieStatus.Severity.Info, issues[1].severity)
    end)

    it("keeps client diagnostics when provider metadata collection fails", function()
        QuestieCompat.GetAddOnMetadata = function() error("metadata API failed", 0) end

        assert.is_true(SourceModeStatus.Update())

        local issues = QuestieStatus.GetIssues()
        assert.are_same({GOLD .. "16001|r"}, issues[1].details[2].args)
        assert.are_same({{message = "Provider diagnostics unavailable: %s", args = {"metadata API failed"}}}, issues[2].details)
    end)

    it("updates its two notices in place and clears only those notices outside Source mode", function()
        SourceModeStatus.Update()
        LibQuestieDB.contractVersion = 4
        SourceModeStatus.Update()
        assert.are_same(2, #QuestieStatus.GetIssues())
        assert.are_same({GOLD .. "1|r", GOLD .. "4|r", GOLD .. "3|r"}, QuestieStatus.GetIssues()[2].details[4].args)
        QuestieStatus.Set("startup", {severity = QuestieStatus.Severity.Error, message = "Startup failed"})
        LibQuestieDB.readMode = "baked"

        assert.is_false(SourceModeStatus.Update())

        assert.are_same({{id = "startup", severity = QuestieStatus.Severity.Error, message = "Startup failed"}}, QuestieStatus.GetIssues())
    end)
end)
