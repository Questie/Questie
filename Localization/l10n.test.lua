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

    before_each(function()
        l10n = require("Localization.l10n")
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.itemData = {[750] = {[QuestieDB.itemKeys.name] = "Tough Wolf Meat"}}
        QuestieDB.npcData = {[99] = {[QuestieDB.npcKeys.name] = "Morgaine the Sly"}}
        QuestieDB.objectData = {[60] = {[QuestieDB.objectKeys.name] = "WANTED: Gath’Ilzogg"}}
        QuestieDB.questData = {[1499] = {[QuestieDB.questKeys.name] = "Vile Familiars"}}
    end)

    it("should keep enUS names without lookup", function()
        _G.GetLocale = function() return "enUS" end

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Tough Wolf Meat", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine the Sly", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("WANTED: Gath’Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Vile Familiars", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load deDE lookups", function()
        _G.GetLocale = function() return "deDE" end
        dofile("Localization/lookups/Classic/lookupItems/deDE.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/deDE.lua")
        dofile("Localization/lookups/Classic/lookupObjects/deDE.lua")
        dofile("Localization/lookups/Classic/lookupQuests/deDE.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Zähes Wolfsfleisch", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine die Verschlagene", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("GESUCHT: Gath’Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Üble Familiare", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load esES lookups", function()
        _G.GetLocale = function() return "esES" end
        dofile("Localization/lookups/Classic/lookupItems/esES.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/esES.lua")
        dofile("Localization/lookups/Classic/lookupObjects/esES.lua")
        dofile("Localization/lookups/Classic/lookupQuests/esES.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne de lobo dura", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine el Astuto", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("Se busca: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Familiares viles", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load esMX lookups", function()
        _G.GetLocale = function() return "esMX" end
        dofile("Localization/lookups/Classic/lookupItems/esMX.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/esMX.lua")
        dofile("Localization/lookups/Classic/lookupObjects/esMX.lua")
        dofile("Localization/lookups/Classic/lookupQuests/esMX.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne de lobo dura", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine el Astuto", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("Se busca: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Familiares viles", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load frFR lookups", function()
        _G.GetLocale = function() return "frFR" end
        dofile("Localization/lookups/Classic/lookupItems/frFR.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/frFR.lua")
        dofile("Localization/lookups/Classic/lookupObjects/frFR.lua")
        dofile("Localization/lookups/Classic/lookupQuests/frFR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Viande de loup coriace", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine la rusée", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("Recherché : Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Les vils quasits", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load koKR lookups", function()
        _G.GetLocale = function() return "koKR" end
        dofile("Localization/lookups/Classic/lookupItems/koKR.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/koKR.lua")
        dofile("Localization/lookups/Classic/lookupObjects/koKR.lua")
        dofile("Localization/lookups/Classic/lookupQuests/koKR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("질긴 늑대 고기", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("교활한 도적 몰게니", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("현상수배: 가스일조그", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("악마의 하수인", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load ptBR lookups", function()
        _G.GetLocale = function() return "ptBR" end
        dofile("Localization/lookups/Classic/lookupItems/ptBR.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/ptBR.lua")
        dofile("Localization/lookups/Classic/lookupObjects/ptBR.lua")
        dofile("Localization/lookups/Classic/lookupQuests/ptBR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne Dura de Lobo", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgana, a Dissimulada", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("Procura-se: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Familiares torpes", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load ruRU lookups", function()
        _G.GetLocale = function() return "ruRU" end
        dofile("Localization/lookups/Classic/lookupItems/ruRU.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/ruRU.lua")
        dofile("Localization/lookups/Classic/lookupObjects/ruRU.lua")
        dofile("Localization/lookups/Classic/lookupQuests/ruRU.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Жесткое волчье мясо", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Моргана Лукавая", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("Разыскивается: Гат'Илзогг", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Злобные фамильяры", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load zhCN lookups", function()
        _G.GetLocale = function() return "zhCN" end
        dofile("Localization/lookups/Classic/lookupItems/zhCN.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/zhCN.lua")
        dofile("Localization/lookups/Classic/lookupObjects/zhCN.lua")
        dofile("Localization/lookups/Classic/lookupQuests/zhCN.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("硬狼肉", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("狡猾的莫加尼", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("通缉：加塞尔佐格", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("邪灵劣魔", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)

    it("should load zhTW lookups", function()
        _G.GetLocale = function() return "zhTW" end
        dofile("Localization/lookups/Classic/lookupItems/zhTW.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/zhTW.lua")
        dofile("Localization/lookups/Classic/lookupObjects/zhTW.lua")
        dofile("Localization/lookups/Classic/lookupQuests/zhTW.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("硬狼肉", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("狡猾的莫加尼", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("懸賞:加塞爾佐格", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("邪靈劣魔", QuestieDB.questData[1499][QuestieDB.questKeys.name])
    end)
end)
