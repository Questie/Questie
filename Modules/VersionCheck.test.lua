dofile("setupTests.lua")

describe("VersionCheck season bootstrap", function()
    local originalGlobals, originalExpansion, originalPhases, seasonId
    local globals = {
        "Questie", "Enum", "LibStub", "C_Seasons", "C_GameRules", "QuestieCompat", "WOW_PROJECT_ID",
        "WOW_PROJECT_CLASSIC", "WOW_PROJECT_BURNING_CRUSADE_CLASSIC", "WOW_PROJECT_WRATH_CLASSIC",
        "WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
    }

    before_each(function()
        originalGlobals = {}
        for _, name in ipairs(globals) do
            originalGlobals[name] = _G[name]
        end
        originalExpansion = QuestieLoader:ImportModule("Expansions").Current
        originalPhases = QuestieLoader:ImportModule("ContentPhases").activePhases
        _G.Questie = nil
        _G.Enum = {}
        _G.WOW_PROJECT_CLASSIC = 2
        _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
        _G.WOW_PROJECT_WRATH_CLASSIC = 11
        _G.WOW_PROJECT_CATACLYSM_CLASSIC = 14
        _G.WOW_PROJECT_MISTS_CLASSIC = 19
        _G.WOW_PROJECT_ID = 2
        _G.LibStub = function()
            return {NewAddon = function() return {} end}
        end
        seasonId = 0
        _G.C_Seasons = {
            HasActiveSeason = function() return seasonId ~= 0 end,
            GetActiveSeason = function() return seasonId end,
        }
        _G.C_GameRules = {IsHardcoreActive = function() return false end}
        _G.QuestieCompat = {GetCurrentCalendarTime = function()
            return {year = 2026, month = 8, monthDay = 10, hour = 3, minute = 0}
        end}
        QuestieLoader:ImportModule("ContentPhases").activePhases = {Anniversary = 1}
    end)

    after_each(function()
        for _, name in ipairs(globals) do
            _G[name] = originalGlobals[name]
        end
        QuestieLoader:ImportModule("Expansions").Current = originalExpansion
        QuestieLoader:ImportModule("ContentPhases").activePhases = originalPhases
    end)

    ---@return DarkmoonFaire
    local function loadBootstrap()
        -- This non-module bootstrap needs the TOC's addon-name vararg, which dofile cannot supply.
        assert(loadfile("Modules/VersionCheck.lua"))("Questie")
        dofile("Modules/Expansions.lua")
        dofile("Database/Corrections/Holidays/DarkmoonFaire.lua")
        return QuestieLoader:ImportModule("DarkmoonFaire")
    end

    it("fills missing season enums and resolves NoSeason through the Era default", function()
        local DarkmoonFaire = loadBootstrap()

        assert.same({
            SeasonOfMastery = 1, SeasonOfDiscovery = 2, Hardcore = 3,
            Fresh = 11, FreshHardcore = 12, TitanReforged = 109,
        }, Enum.SeasonID)
        assert.is_true(Questie.IsEra)
        assert.same({status = "active", location = "MULGORE"}, DarkmoonFaire.GetCurrentState())
    end)

    it("preserves supplied enums and detects Titan through its named constant", function()
        _G.Enum = {SeasonID = {NoSeason = 0, SeasonOfMastery = 41, Hardcore = 43, TitanReforged = 209}}
        _G.WOW_PROJECT_ID = 11
        seasonId = 209

        local DarkmoonFaire = loadBootstrap()

        assert.same({
            NoSeason = 0, SeasonOfMastery = 41, SeasonOfDiscovery = 2, Hardcore = 43,
            Fresh = 11, FreshHardcore = 12, TitanReforged = 209,
        }, Enum.SeasonID)
        assert.is_true(Questie.IsTitanReforged)
        ---@type Expansions
        local Expansions = QuestieLoader:ImportModule("Expansions")
        assert.equals("calendar", DarkmoonFaire.rules[Expansions.Wotlk].seasons[209].timing.source)
        assert.equals("monthly", DarkmoonFaire.rules[Expansions.Era].seasons[43].timing.source)
    end)

    it("loads explicit Hardcore rules without Anniversary phase gating", function()
        seasonId = 3
        C_GameRules.IsHardcoreActive = function() return true end

        local DarkmoonFaire = loadBootstrap()

        assert.is_true(Questie.IsHardcore)
        ---@type Expansions
        local Expansions = QuestieLoader:ImportModule("Expansions")
        local rule = DarkmoonFaire.rules[Expansions.Era].seasons[Enum.SeasonID.Hardcore]
        assert.same({
            source = "monthly", setupWeekday = 6, startWeekday = 2,
            startHour = 3, startMinute = 0, endDayOffset = 7, endHour = 3, endMinute = 0,
        }, rule.timing)
        assert.same({source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}}, rule.location)
        assert.same({status = "active", location = "MULGORE"}, DarkmoonFaire.GetCurrentState())
    end)
end)
