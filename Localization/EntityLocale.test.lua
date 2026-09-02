dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("EntityLocale", function()
    ---@type EntityLocale
    local EntityLocale
    ---@type QuestieTDBMock
    local mock
    local LibQuestieDB
    local itemKeys, questKeys, npcKeys, objectKeys

    before_each(function()
        mock = LoadQuestieTDBMock()
        LibQuestieDB = mock.lib
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        itemKeys, questKeys, npcKeys, objectKeys = QuestieDB.itemKeys, QuestieDB.questKeys, QuestieDB.npcKeys, QuestieDB.objectKeys
        _G.QUESTIE_LOCALES_OVERRIDE = nil

        dofile("Localization/EntityLocale.lua")
        EntityLocale = QuestieLoader:ImportModule("EntityLocale")

        mock.SetBaseRow("Item", 5, {[itemKeys.name] = "Sharptalon's Claw"})
        mock.SetBaseRow("Quest", 2, {[questKeys.name] = "Sharptalon's Claw"})
        mock.SetBaseRow("Quest", 3, {[questKeys.name] = "Webwood Venom"})
        mock.SetBaseRow("Npc", 30, {[npcKeys.name] = "Forest Spider"})
        mock.SetBaseRow("Object", 31, {[objectKeys.name] = "Old Lion Statue"})
    end)

    after_each(function()
        _G.QUESTIE_LOCALES_OVERRIDE = nil
    end)

    describe("ApplyExternalLocaleCorrections", function()
        ---@type {datatype: string, name: string, rows: table}[]
        local setCorrectionCalls

        before_each(function()
            setCorrectionCalls = {}
            local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
            QuestieCorrections.SetCorrection = function(datatype, name, rows)
                table.insert(setCorrectionCalls, {datatype = datatype, name = name, rows = rows})
            end
        end)

        it("publishes all four external locale slots with the built rows", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = function() return {[5] = "Klaue von Scharfkralle"} end,
            }

            EntityLocale.ApplyExternalLocaleCorrections("zzZZ")

            assert.are_same({
                {datatype = "Item", name = "ExternalLocaleItem", rows = {[5] = {[itemKeys.name] = "Klaue von Scharfkralle"}}},
                {datatype = "Quest", name = "ExternalLocaleQuest", rows = {}},
                {datatype = "Npc", name = "ExternalLocaleNpc", rows = {}},
                {datatype = "Object", name = "ExternalLocaleObject", rows = {}},
            }, setCorrectionCalls)
        end)

        it("publishes empty rows when no external addon is loaded, which SetCorrection treats as withdrawals", function()
            EntityLocale.ApplyExternalLocaleCorrections("enUS")

            assert.are_same(4, #setCorrectionCalls)
            for _, call in ipairs(setCorrectionCalls) do
                assert.are_same({}, call.rows)
            end
        end)
    end)

    describe("BuildExternalLocaleCorrections", function()
        local EMPTY = {Item = {}, Quest = {}, Npc = {}, Object = {}}

        it("returns four empty tables when no external locale addon is loaded", function()
            assert.are_same(EMPTY, EntityLocale.BuildExternalLocaleCorrections("enUS"))
        end)

        it("returns four empty tables when the external addon supplies another locale than the effective one", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = function() return {[5] = "Klaue von Scharfkralle"} end,
            }

            assert.are_same(EMPTY, EntityLocale.BuildExternalLocaleCorrections("enUS"))
        end)

        it("builds Item, Quest, NPC, and Object rows with Database Key Enums for existing entities", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = function() return {[5] = "Klaue von Scharfkralle"} end,
                questLookup = function() return {[2] = {"Klaue von Scharfkralle", {"Bringt die Klaue."}}} end,
                npcNameLookup = function() return {[30] = {"Waldspinne", "Spinne"}} end,
                objectLookup = function() return {[31] = "Alte Löwenstatue"} end,
            }

            local rows = EntityLocale.BuildExternalLocaleCorrections("zzZZ")

            assert.are_same({[5] = {[itemKeys.name] = "Klaue von Scharfkralle"}}, rows.Item)
            assert.are_same({[2] = {
                [questKeys.name] = "Klaue von Scharfkralle",
                [questKeys.objectivesText] = {"Bringt die Klaue."},
            }}, rows.Quest)
            assert.are_same({[30] = {[npcKeys.name] = "Waldspinne", [npcKeys.subName] = "Spinne"}}, rows.Npc)
            assert.are_same({[31] = {[objectKeys.name] = "Alte Löwenstatue"}}, rows.Object)
        end)

        it("drops rows whose ID does not exist in the composed database", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = function() return {[5] = "Vorhanden", [6] = "Unbekannt"} end,
                questLookup = function() return {[4] = {"Unbekannt"}} end,
                npcNameLookup = function() return {[99] = "Unbekannt"} end,
                objectLookup = function() return {[32] = "Unbekannt"} end,
            }

            local rows = EntityLocale.BuildExternalLocaleCorrections("zzZZ")

            assert.are_same({[5] = {[itemKeys.name] = "Vorhanden"}}, rows.Item)
            assert.are_same({}, rows.Quest)
            assert.are_same({}, rows.Npc)
            assert.are_same({}, rows.Object)
        end)

        it("accepts entities another Correction owner added, such as provider season entities", function()
            local season = LibQuestieDB.GetRegistrar("QuestieTDB-Season")
            season.RegisterRuntimeCorrection("Npc", "season", function()
                return {[91000] = {[npcKeys.name] = "Rune Broker"}}
            end, 1)
            season.Apply()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                npcNameLookup = function() return {[91000] = "Runenhändler"} end,
            }

            local rows = EntityLocale.BuildExternalLocaleCorrections("zzZZ")

            assert.are_same({[91000] = {[npcKeys.name] = "Runenhändler"}}, rows.Npc)
        end)

        it("keeps quest name-only and objectives-only rows and plain string NPC names", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                questLookup = function()
                    return {
                        [2] = {"Nur Name"},
                        [3] = {nil, {"Nur Ziele."}},
                    }
                end,
                npcNameLookup = function() return {[30] = "Waldspinne"} end,
            }

            local rows = EntityLocale.BuildExternalLocaleCorrections("zzZZ")

            assert.are_same({
                [2] = {[questKeys.name] = "Nur Name"},
                [3] = {[questKeys.objectivesText] = {"Nur Ziele."}},
            }, rows.Quest)
            assert.are_same({[30] = {[npcKeys.name] = "Waldspinne"}}, rows.Npc)
        end)

        it("skips empty strings and empty objective tables instead of blanking or clearing composed fields", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = function() return {[5] = ""} end,
                questLookup = function() return {[2] = {"", {}}, [3] = {"Webwood-Gift", {}}} end,
                npcNameLookup = function() return {[30] = {"", ""}} end,
                objectLookup = function() return {[31] = ""} end,
            }

            local rows = EntityLocale.BuildExternalLocaleCorrections("zzZZ")

            assert.are_same({}, rows.Item)
            assert.are_same({[3] = {[questKeys.name] = "Webwood-Gift"}}, rows.Quest)
            assert.are_same({}, rows.Npc)
            assert.are_same({}, rows.Object)
        end)

        it("accepts lookup tables as well as lookup functions and skips rows without values", function()
            _G.QUESTIE_LOCALES_OVERRIDE = {
                locale = "zzZZ",
                translations = {},
                itemLookup = {[5] = "Klaue von Scharfkralle"},
                questLookup = {[2] = {}},
                npcNameLookup = {[30] = {}},
                objectLookup = {[31] = false},
            }

            local rows = EntityLocale.BuildExternalLocaleCorrections("zzZZ")

            assert.are_same({[5] = {[itemKeys.name] = "Klaue von Scharfkralle"}}, rows.Item)
            assert.are_same({}, rows.Quest)
            assert.are_same({}, rows.Npc)
            assert.are_same({}, rows.Object)
        end)
    end)
end)
