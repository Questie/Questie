dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("l10n", function()
    ---@type l10n
    local l10n
    ---@type QuestieTDBMock
    local mock

    local originalGetLocale

    before_each(function()
        mock = LoadQuestieTDBMock()
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

    describe("external entity names", function()
        local itemKeys, questKeys, npcKeys, objectKeys

        before_each(function()
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            itemKeys, questKeys, npcKeys, objectKeys = QuestieDB.itemKeys, QuestieDB.questKeys, QuestieDB.npcKeys, QuestieDB.objectKeys
            mock.SetBaseRow("Item", 5, {[itemKeys.name] = "Sharptalon's Claw"})
            mock.SetBaseRow("Quest", 2, {[questKeys.name] = "Sharptalon's Claw", [questKeys.objectivesText] = {"Bring the claw."}})
            mock.SetBaseRow("Quest", 3, {[questKeys.name] = "Webwood Venom"})
            mock.SetBaseRow("Npc", 30, {[npcKeys.name] = "Forest Spider"})
            mock.SetBaseRow("Object", 31, {[objectKeys.name] = "Old Lion Statue"})
        end)

        it("forwards the four lookups to the provider under their own owner", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = function() return {[5] = "Klaue von Scharfkralle"} end,
                questLookup = {[2] = {"Klaue von Scharfkralle", {"Bringt die Klaue."}}},
                npcNameLookup = function() return {[30] = {"Waldspinne", "Spinne"}} end,
                objectLookup = {[31] = "Alte Löwenstatue"},
            }

            l10n.InitializeUILocale()

            assert.are_same("Klaue von Scharfkralle", LibQuestieDB.Item.Get(5, "name"))
            assert.are_same("Klaue von Scharfkralle", LibQuestieDB.Quest.Get(2, "name"))
            assert.are_same({"Bringt die Klaue."}, LibQuestieDB.Quest.Get(2, "objectivesText"))
            assert.are_same("Waldspinne", LibQuestieDB.Npc.Get(30, "name"))
            assert.are_same("Spinne", LibQuestieDB.Npc.Get(30, "subName"))
            assert.are_same("Alte Löwenstatue", LibQuestieDB.Object.Get(31, "name"))
            assert.are_same("QuestieLocalesOverride", LibQuestieDB.GetProvenance("Item", 5, "name"))
        end)

        it("publishes nothing when the player configured another UI locale", function()
            Questie.db.global.questieLocaleDiff = true
            Questie.db.global.questieLocale = "frFR"
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = {[5] = "Klaue von Scharfkralle"},
            }

            l10n.InitializeUILocale()

            assert.are_same("Sharptalon's Claw", LibQuestieDB.Item.Get(5, "name"))
            assert.are_same({"QuestieTDB"}, LibQuestieDB.GetOwners())
        end)

        it("drops unknown IDs, empty strings, and empty objective tables", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = {[5] = "", [6] = "Unbekannt"},
                questLookup = {[2] = {"", {}}, [4] = {"Unbekannt"}},
                npcNameLookup = {[30] = {"", ""}, [99] = "Unbekannt"},
                objectLookup = {[31] = "", [32] = "Unbekannt"},
            }

            l10n.InitializeUILocale()

            assert.are_same("Sharptalon's Claw", LibQuestieDB.Item.Get(5, "name"))
            assert.are_same("Sharptalon's Claw", LibQuestieDB.Quest.Get(2, "name"))
            assert.are_same({"Bring the claw."}, LibQuestieDB.Quest.Get(2, "objectivesText"))
            assert.are_same("Forest Spider", LibQuestieDB.Npc.Get(30, "name"))
            assert.are_same("Old Lion Statue", LibQuestieDB.Object.Get(31, "name"))
            assert.is_false(LibQuestieDB.Item.Exists(6))
            assert.is_false(LibQuestieDB.Quest.Exists(4))
            assert.is_false(LibQuestieDB.Npc.Exists(99))
            assert.is_false(LibQuestieDB.Object.Exists(32))
            assert.are_same({"QuestieTDB"}, LibQuestieDB.GetOwners())
        end)

        it("reads objectives from the third element of the older three-element quest shape", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                questLookup = {
                    [2] = {"Klaue", {"Beschreibung."}, {"Bringt die Klaue."}},
                    [3] = {nil, {"Nur Ziele."}},
                },
            }

            l10n.InitializeUILocale()

            assert.are_same({"Bringt die Klaue."}, LibQuestieDB.Quest.Get(2, "objectivesText"))
            assert.are_same("Webwood Venom", LibQuestieDB.Quest.Get(3, "name"))
            assert.are_same({"Nur Ziele."}, LibQuestieDB.Quest.Get(3, "objectivesText"))
        end)
    end)
end)
