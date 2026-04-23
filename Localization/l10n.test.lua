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

    local function _SetupEnglishData()
        QuestieDB.itemData = {[750] = {[QuestieDB.itemKeys.name] = "Tough Wolf Meat"}}
        QuestieDB.npcData = {[99] = {[QuestieDB.npcKeys.name] = "Morgaine the Sly"}}
        QuestieDB.objectData = {[60] = {[QuestieDB.objectKeys.name] = "WANTED: Gath’Ilzogg"}}
        QuestieDB.questData = {[1359] = {[QuestieDB.questKeys.name] = "Zinge's Delivery"}}
        l10n.itemLookup = {}
        l10n.questLookup = {}
        l10n.npcNameLookup = {}
        l10n.objectLookup = {}
    end

    before_each(function()
        l10n = require("Localization.l10n")
        QuestieDB = require("Database.QuestieDB")
        _SetupEnglishData()
    end)

    it("should keep enUS names without lookup", function()
        _G.GetLocale = function() return "enUS" end

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Tough Wolf Meat", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine the Sly", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("WANTED: Gath’Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Zinge's Delivery", QuestieDB.questData[1359][QuestieDB.questKeys.name])
    end)

    it("should load deDE lookups", function()
        _G.GetLocale = function() return "deDE" end
        dofile("Localization/lookups/Classic/lookupItems/deDE.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/deDE.lua")
        dofile("Localization/lookups/Classic/lookupObjects/deDE.lua")
        dofile("Localization/lookups/Classic/lookupQuests/deDE.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Zähes Wolfsfleisch", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/deDE.lua")
        assert.are_same("Morgaine die Verschlagene", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/deDE.lua")
        assert.are_same("GESUCHT: Gath’Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/deDE.lua")
        assert.are_same("Zinges Lieferung", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/deDE.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/deDE.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/deDE.lua")
        dofile("Localization/lookups/Cata/lookupObjects/deDE.lua")
        dofile("Localization/lookups/Cata/lookupQuests/deDE.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Zähes Wolfsfleisch", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/deDE.lua")
        assert.are_same("Morgaine die Verschlagene", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/deDE.lua")
        assert.are_same("GESUCHT: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/deDE.lua")
        assert.are_same("Zinges Lieferung", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/deDE.lua")
    end)

    it("should load esES lookups", function()
        _G.GetLocale = function() return "esES" end
        dofile("Localization/lookups/Classic/lookupItems/esES.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/esES.lua")
        dofile("Localization/lookups/Classic/lookupObjects/esES.lua")
        dofile("Localization/lookups/Classic/lookupQuests/esES.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne de lobo dura", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/esES.lua")
        assert.are_same("Morgaine el Astuto", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/esES.lua")
        assert.are_same("Se busca: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/esES.lua")
        assert.are_same("Una entrega de Zinge", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/esES.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/esES.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/esES.lua")
        dofile("Localization/lookups/Cata/lookupObjects/esES.lua")
        dofile("Localization/lookups/Cata/lookupQuests/esES.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne de lobo dura", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/esES.lua")
        assert.are_same("Morgaine la Astuta", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/esES.lua")
        assert.are_same("Se busca: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/esES.lua")
        assert.are_same("Una entrega de Zinge", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/esES.lua")
    end)

    it("should load esMX lookups", function()
        _G.GetLocale = function() return "esMX" end
        dofile("Localization/lookups/Classic/lookupItems/esMX.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/esMX.lua")
        dofile("Localization/lookups/Classic/lookupObjects/esMX.lua")
        dofile("Localization/lookups/Classic/lookupQuests/esMX.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne de lobo dura", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/esMX.lua")
        assert.are_same("Morgaine el Astuto", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/esMX.lua")
        assert.are_same("Se busca: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/esMX.lua")
        assert.are_same("Una entrega de Zinge", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/esMX.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/esMX.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/esMX.lua")
        dofile("Localization/lookups/Cata/lookupObjects/esMX.lua")
        dofile("Localization/lookups/Cata/lookupQuests/esMX.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne de lobo dura", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/esMX.lua")
        assert.are_same("Morgaine la Astuta", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/esMX.lua")
        assert.are_same("Se busca: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/esMX.lua")
        assert.are_same("Una entrega de Zinge", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/esMX.lua")
    end)

    it("should load frFR lookups", function()
        _G.GetLocale = function() return "frFR" end
        dofile("Localization/lookups/Classic/lookupItems/frFR.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/frFR.lua")
        dofile("Localization/lookups/Classic/lookupObjects/frFR.lua")
        dofile("Localization/lookups/Classic/lookupQuests/frFR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Viande de loup coriace", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/frFR.lua")
        assert.are_same("Morgaine la rusée", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/frFR.lua")
        assert.are_same("Recherché : Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/frFR.lua")
        assert.are_same("Une livraison pour Zinge", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/frFR.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/frFR.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/frFR.lua")
        dofile("Localization/lookups/Cata/lookupObjects/frFR.lua")
        dofile("Localization/lookups/Cata/lookupQuests/frFR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Viande de loup coriace", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/frFR.lua")
        assert.are_same("Morgaine la rusée", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/frFR.lua")
        assert.are_same("Avis de recherche : Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/frFR.lua")
        assert.are_same("Une livraison pour Zinge", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/frFR.lua")
    end)

    it("should load koKR lookups", function()
        _G.GetLocale = function() return "koKR" end
        dofile("Localization/lookups/Classic/lookupItems/koKR.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/koKR.lua")
        dofile("Localization/lookups/Classic/lookupObjects/koKR.lua")
        dofile("Localization/lookups/Classic/lookupQuests/koKR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("질긴 늑대 고기", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/koKR.lua")
        assert.are_same("교활한 도적 몰게니", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/koKR.lua")
        assert.are_same("현상수배: 가스일조그", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/koKR.lua")
        assert.are_same("진게의 소포", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/koKR.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/koKR.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/koKR.lua")
        dofile("Localization/lookups/Cata/lookupObjects/koKR.lua")
        dofile("Localization/lookups/Cata/lookupQuests/koKR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("질긴 늑대 고기", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/koKR.lua")
        assert.are_same("교활한 도적 몰게니", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/koKR.lua")
        assert.are_same("현상 수배: 가스일조그", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/koKR.lua")
        assert.are_same("진게의 소포", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/koKR.lua")
    end)

    it("should load ptBR lookups", function()
        _G.GetLocale = function() return "ptBR" end
        dofile("Localization/lookups/Classic/lookupItems/ptBR.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/ptBR.lua")
        dofile("Localization/lookups/Classic/lookupObjects/ptBR.lua")
        dofile("Localization/lookups/Classic/lookupQuests/ptBR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne Dura de Lobo", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/ptBR.lua")
        assert.are_same("Morgana, a Dissimulada", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/ptBR.lua")
        assert.are_same("Procura-se: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/ptBR.lua")
        assert.are_same("Entrega para Zilda", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/ptBR.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/ptBR.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/ptBR.lua")
        dofile("Localization/lookups/Cata/lookupObjects/ptBR.lua")
        dofile("Localization/lookups/Cata/lookupQuests/ptBR.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Carne Dura de Lobo", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/ptBR.lua")
        assert.are_same("Morgana, a Dissimulada", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/ptBR.lua")
        assert.are_same("Procura-se: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/ptBR.lua")
        assert.are_same("Entrega para Zilda", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/ptBR.lua")
    end)

    it("should load ruRU lookups", function()
        _G.GetLocale = function() return "ruRU" end
        dofile("Localization/lookups/Classic/lookupItems/ruRU.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/ruRU.lua")
        dofile("Localization/lookups/Classic/lookupObjects/ruRU.lua")
        dofile("Localization/lookups/Classic/lookupQuests/ruRU.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Жесткое волчье мясо", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/ruRU.lua")
        assert.are_same("Моргана Лукавая", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/ruRU.lua")
        assert.are_same("Разыскивается: Гат'Илзогг", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/ruRU.lua")
        assert.are_same("Посылка для Зинг", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/ruRU.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/ruRU.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/ruRU.lua")
        dofile("Localization/lookups/Cata/lookupObjects/ruRU.lua")
        dofile("Localization/lookups/Cata/lookupQuests/ruRU.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("Жесткое волчье мясо", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/ruRU.lua")
        assert.are_same("Моргана Лукавая", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/ruRU.lua")
        assert.are_same("Розыск: Гат'Илзогг", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/ruRU.lua")
        assert.are_same("Посылка для Зинг", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/ruRU.lua")
    end)

    it("should load zhCN lookups", function()
        _G.GetLocale = function() return "zhCN" end
        dofile("Localization/lookups/Classic/lookupItems/zhCN.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/zhCN.lua")
        dofile("Localization/lookups/Classic/lookupObjects/zhCN.lua")
        dofile("Localization/lookups/Classic/lookupQuests/zhCN.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("硬狼肉", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/zhCN.lua")
        assert.are_same("狡猾的莫加尼", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/zhCN.lua")
        assert.are_same("通缉：加塞尔佐格", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/zhCN.lua")
        assert.are_same("给金格的货物", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/zhCN.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/zhCN.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/zhCN.lua")
        dofile("Localization/lookups/Cata/lookupObjects/zhCN.lua")
        dofile("Localization/lookups/Cata/lookupQuests/zhCN.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("硬狼肉", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/zhCN.lua")
        assert.are_same("狡猾的莫加尼", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/zhCN.lua")
        assert.are_same("通缉：加塞尔佐格", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/zhCN.lua")
        assert.are_same("给金格的货物", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/zhCN.lua")
    end)

    it("should load zhTW lookups", function()
        _G.GetLocale = function() return "zhTW" end
        dofile("Localization/lookups/Classic/lookupItems/zhTW.lua")
        dofile("Localization/lookups/Classic/lookupNpcs/zhTW.lua")
        dofile("Localization/lookups/Classic/lookupObjects/zhTW.lua")
        dofile("Localization/lookups/Classic/lookupQuests/zhTW.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("硬狼肉", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Classic/lookupItems/zhTW.lua")
        assert.are_same("狡猾的莫加尼", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Classic/lookupNpcs/zhTW.lua")
        assert.are_same("懸賞:加塞爾佐格", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Classic/lookupObjects/zhTW.lua")
        assert.are_same("給金格的貨物", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Classic/lookupQuests/zhTW.lua")

        _SetupEnglishData()
        dofile("Localization/lookups/Cata/lookupItems/zhTW.lua")
        dofile("Localization/lookups/Cata/lookupNpcs/zhTW.lua")
        dofile("Localization/lookups/Cata/lookupObjects/zhTW.lua")
        dofile("Localization/lookups/Cata/lookupQuests/zhTW.lua")

        l10n.InitializeUILocale()
        l10n:Initialize()

        assert.are_same("硬狼肉", QuestieDB.itemData[750][QuestieDB.itemKeys.name], "There is an error in Localization/lookups/Cata/zhTW.lua")
        assert.are_same("狡猾的莫加尼", QuestieDB.npcData[99][QuestieDB.npcKeys.name], "There is an error in Localization/lookups/Cata/zhTW.lua")
        assert.are_same("懸賞:加塞爾佐格", QuestieDB.objectData[60][QuestieDB.objectKeys.name], "There is an error in Localization/lookups/Cata/zhTW.lua")
        assert.are_same("給金格的貨物", QuestieDB.questData[1359][QuestieDB.questKeys.name], "There is an error in Localization/lookups/Cata/zhTW.lua")
    end)
end)
