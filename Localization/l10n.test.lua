dofile("setupTests.lua")

describe("l10n", function()
    ---@type l10n
    local l10n

    local originalGetLocale

    before_each(function()
        originalGetLocale = _G.GetLocale
        _G.QUESTIE_LOCALES_OVERRIDE = nil
        Questie.db.global.questieLocaleDiff = false
        Questie.db.global.questieLocale = nil

        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")
    end)

    after_each(function()
        _G.GetLocale = originalGetLocale
        _G.QUESTIE_LOCALES_OVERRIDE = nil
    end)

    it("returns fallback UI locales without changing the active UI locale", function()
        l10n:SetUILocale("deDE")

        assert.are_same("enUS", l10n:GetFallbackLocale("unsupported"))
        assert.are_same("deDE", l10n:GetUILocale())
    end)

    it("uses the configured Questie UI locale", function()
        Questie.db.global.questieLocaleDiff = true
        Questie.db.global.questieLocale = "frFR"

        l10n.InitializeUILocale()

        assert.are_same("frFR", l10n:GetUILocale())
    end)

    it("keeps the configured UI locale while registering external UI translations", function()
        Questie.db.global.questieLocaleDiff = true
        Questie.db.global.questieLocale = "frFR"
        l10n.translations["Questie string"] = {
            enUS = true,
            frFR = "Configured string",
        }
        _G.QUESTIE_LOCALES_OVERRIDE = {
            locale = "zzZZ",
            translations = {
                ["Questie string"] = "External string",
            },
        }

        l10n.InitializeUILocale()

        assert.are_same("frFR", l10n:GetUILocale())
        assert.are_same("Configured string", l10n("Questie string"))
        assert.are_same("External string", l10n.translations["Questie string"].zzZZ)
    end)

    it("uses the client locale when Questie has no locale override", function()
        _G.GetLocale = function() return "deDE" end

        l10n.InitializeUILocale()

        assert.are_same("deDE", l10n:GetUILocale())
    end)

    it("registers external UI translations under the external locale", function()
        l10n.translations["Questie string"] = {enUS = true}
        _G.QUESTIE_LOCALES_OVERRIDE = {
            locale = "zzZZ",
            translations = {
                ["Questie string"] = "External string",
            },
        }

        l10n.InitializeUILocale()

        assert.are_same("zzZZ", l10n:GetUILocale())
        assert.are_same("External string", l10n("Questie string"))
    end)

    it("falls back to the English key when a UI translation is unavailable", function()
        l10n:SetUILocale("deDE")

        assert.are_same("Missing 7", l10n("Missing %d", 7))
    end)
end)
