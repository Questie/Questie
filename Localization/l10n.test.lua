dofile("setupTests.lua")

dofile("Database/itemDB.lua")
dofile("Database/npcDB.lua")
dofile("Database/objectDB.lua")
dofile("Database/questDB.lua")

describe("l10n", function()

    ---@type QuestieDB
    local QuestieDB
    ---@type l10n
    local l10n

    local originalGetLocale

    local expansions = {"Classic", "TBC", "Wotlk", "Cata", "MoP"}
    local locales = {"deDE", "esES", "esMX", "frFR", "koKR", "ptBR", "ruRU", "zhCN", "zhTW"}

    -- These sentinel IDs are stable across supported expansions and verify lookup data flows into QuestieDB.
    local classicExpected = {
        deDE = {
            item = "Zähes Wolfsfleisch",
            npc = "Morgaine die Verschlagene",
            object = "GESUCHT: Gath’Ilzogg",
            quest = "Zinges Lieferung",
        },
        esES = {
            item = "Carne de lobo dura",
            npc = "Morgaine el Astuto",
            object = "Se busca: Gath'Ilzogg",
            quest = "Una entrega de Zinge",
        },
        esMX = {
            item = "Carne de lobo dura",
            npc = "Morgaine el Astuto",
            object = "Se busca: Gath'Ilzogg",
            quest = "Una entrega de Zinge",
        },
        frFR = {
            item = "Viande de loup coriace",
            npc = "Morgaine la rusée",
            object = "Recherché : Gath'Ilzogg",
            quest = "Une livraison pour Zinge",
        },
        koKR = {
            item = "질긴 늑대 고기",
            npc = "교활한 도적 몰게니",
            object = "현상수배: 가스일조그",
            quest = "진게의 소포",
        },
        ptBR = {
            item = "Carne Dura de Lobo",
            npc = "Morgana, a Dissimulada",
            object = "Procura-se: Gath'Ilzogg",
            quest = "Entrega para Zilda",
        },
        ruRU = {
            item = "Жесткое волчье мясо",
            npc = "Моргана Лукавая",
            object = "Разыскивается: Гат'Илзогг",
            quest = "Посылка для Зинг",
        },
        zhCN = {
            item = "硬狼肉",
            npc = "狡猾的莫加尼",
            object = "通缉：加塞尔佐格",
            quest = "给金格的货物",
        },
        zhTW = {
            item = "硬狼肉",
            npc = "狡猾的莫加尼",
            object = "懸賞:加塞爾佐格",
            quest = "給金格的貨物",
        },
    }

    -- Known expansion-specific differences for the sentinel records above.
    local tbcOverrides = {
        deDE = {object = "GESUCHT: Gath'Ilzogg"},
        esES = {npc = "Morgaine la Astuta"},
        frFR = {object = "Avis de recherche : Gath'Ilzogg"},
        koKR = {object = "현상 수배: 가스일조그"},
        ruRU = {object = "Розыск: Гат'Илзогг"},
    }

    local wotlkAndLaterOverrides = {
        esMX = {npc = "Morgaine la Astuta"},
    }

    local function _SetupEnglishData()
        QuestieDB.itemData = {[750] = {[QuestieDB.itemKeys.name] = "Tough Wolf Meat"}}
        QuestieDB.npcData = {[99] = {[QuestieDB.npcKeys.name] = "Morgaine the Sly"}}
        QuestieDB.objectData = {[60] = {[QuestieDB.objectKeys.name] = "WANTED: Gath'Ilzogg"}}
        QuestieDB.questData = {[1359] = {[QuestieDB.questKeys.name] = "Zinge's Delivery"}}
        l10n.itemLookup = {}
        l10n.questLookup = {}
        l10n.npcNameLookup = {}
        l10n.objectLookup = {}
        l10n.questLookupOverrides = nil
    end

    local function _CopyExpected(expected)
        return {
            item = expected.item,
            npc = expected.npc,
            object = expected.object,
            quest = expected.quest,
        }
    end

    local function _ApplyOverrides(expected, overrides)
        if overrides then
            for key, value in pairs(overrides) do
                expected[key] = value
            end
        end
    end

    local function _GetExpected(expansion, locale)
        local expected = _CopyExpected(classicExpected[locale])

        if expansion ~= "Classic" then
            _ApplyOverrides(expected, tbcOverrides[locale])
        end

        if expansion == "Wotlk" or expansion == "Cata" or expansion == "MoP" then
            _ApplyOverrides(expected, wotlkAndLaterOverrides[locale])
        end

        return expected
    end

    local function _LoadExpansionLookups(expansion, locale)
        dofile("Localization/lookups/" .. expansion .. "/lookupItems/" .. locale .. ".lua")
        dofile("Localization/lookups/" .. expansion .. "/lookupNpcs/" .. locale .. ".lua")
        dofile("Localization/lookups/" .. expansion .. "/lookupObjects/" .. locale .. ".lua")
        dofile("Localization/lookups/" .. expansion .. "/lookupQuests/" .. locale .. ".lua")
    end

    local function _LookupPath(expansion, lookupType, locale)
        return "Localization/lookups/" .. expansion .. "/" .. lookupType .. "/" .. locale .. ".lua"
    end

    local function _AssertLocalizedNames(expansion, locale, expected)
        assert.are_same(
            expected.item,
            QuestieDB.itemData[750][QuestieDB.itemKeys.name],
            "There is an error in " .. _LookupPath(expansion, "lookupItems", locale)
        )
        assert.are_same(
            expected.npc,
            QuestieDB.npcData[99][QuestieDB.npcKeys.name],
            "There is an error in " .. _LookupPath(expansion, "lookupNpcs", locale)
        )
        assert.are_same(
            expected.object,
            QuestieDB.objectData[60][QuestieDB.objectKeys.name],
            "There is an error in " .. _LookupPath(expansion, "lookupObjects", locale)
        )
        assert.are_same(
            expected.quest,
            QuestieDB.questData[1359][QuestieDB.questKeys.name],
            "There is an error in " .. _LookupPath(expansion, "lookupQuests", locale)
        )
    end

    before_each(function()
        originalGetLocale = _G.GetLocale
        l10n = require("Localization.l10n")
        QuestieDB = require("Database.QuestieDB")
        _SetupEnglishData()
    end)

    after_each(function()
        _G.GetLocale = originalGetLocale
    end)

    it("should keep enUS names without lookup", function()
        _G.GetLocale = function() return "enUS" end

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Tough Wolf Meat", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine the Sly", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("WANTED: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Zinge's Delivery", QuestieDB.questData[1359][QuestieDB.questKeys.name])
    end)

    for _, expansion in ipairs(expansions) do
        describe(expansion .. " lookups", function()
            for _, locale in ipairs(locales) do
                it("should load " .. locale .. " lookups", function()
                    local expected = _GetExpected(expansion, locale)
                    _G.GetLocale = function() return locale end

                    _LoadExpansionLookups(expansion, locale)
                    l10n.InitializeUILocale()
                    l10n:Initialize()

                    _AssertLocalizedNames(expansion, locale, expected)
                end)
            end
        end)
    end
end)
