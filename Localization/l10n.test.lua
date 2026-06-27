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
    local originalQuestieDBState
    local originalL10nState

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

    local function _SaveModuleState()
        originalQuestieDBState = {
            itemData = QuestieDB.itemData,
            npcData = QuestieDB.npcData,
            objectData = QuestieDB.objectData,
            questData = QuestieDB.questData,
        }
        originalL10nState = {
            itemLookup = l10n.itemLookup,
            questLookup = l10n.questLookup,
            npcNameLookup = l10n.npcNameLookup,
            objectLookup = l10n.objectLookup,
            questLookupOverrides = l10n.questLookupOverrides,
        }
    end

    local function _RestoreModuleState()
        QuestieDB.itemData = originalQuestieDBState.itemData
        QuestieDB.npcData = originalQuestieDBState.npcData
        QuestieDB.objectData = originalQuestieDBState.objectData
        QuestieDB.questData = originalQuestieDBState.questData
        l10n.itemLookup = originalL10nState.itemLookup
        l10n.questLookup = originalL10nState.questLookup
        l10n.npcNameLookup = originalL10nState.npcNameLookup
        l10n.objectLookup = originalL10nState.objectLookup
        l10n.questLookupOverrides = originalL10nState.questLookupOverrides
    end

    local function _InitializeLocale(locale)
        _G.GetLocale = function() return locale end

        l10n.InitializeUILocale()
        l10n:Initialize()
    end

    before_each(function()
        originalGetLocale = _G.GetLocale
        dofile("Database/QuestieDB.lua")
        dofile("Localization/l10n.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        l10n = QuestieLoader:ImportModule("l10n")
        _SaveModuleState()
        _SetupEnglishData()
    end)

    after_each(function()
        _G.GetLocale = originalGetLocale
        _RestoreModuleState()
    end)

    it("should keep enUS names without lookup", function()
        _InitializeLocale("enUS")

        assert.are_same("Tough Wolf Meat", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
        assert.are_same("Morgaine the Sly", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("WANTED: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
        assert.are_same("Zinge's Delivery", QuestieDB.questData[1359][QuestieDB.questKeys.name])
    end)

    -- Generated lookup files are validated under Localization/lookups; these behavior tests only need one non-English locale.
    it("should localize item names", function()
        l10n.itemLookup["deDE"] = function()
            return {[750] = "Zähes Wolfsfleisch"}
        end

        _InitializeLocale("deDE")

        assert.are_same("Zähes Wolfsfleisch", QuestieDB.itemData[750][QuestieDB.itemKeys.name])
    end)

    it("should localize NPC names from string lookup values", function()
        l10n.npcNameLookup["deDE"] = function()
            return {[99] = "Morgaine die Verschlagene"}
        end

        _InitializeLocale("deDE")

        assert.are_same("Morgaine die Verschlagene", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
    end)

    it("should localize NPC names and subnames from table lookup values", function()
        l10n.npcNameLookup["deDE"] = function()
            return {[99] = {"Morgaine die Verschlagene", "Seltene Gegnerin"}}
        end

        _InitializeLocale("deDE")

        assert.are_same("Morgaine die Verschlagene", QuestieDB.npcData[99][QuestieDB.npcKeys.name])
        assert.are_same("Seltene Gegnerin", QuestieDB.npcData[99][QuestieDB.npcKeys.subName])
    end)

    it("should localize object names", function()
        l10n.objectLookup["deDE"] = function()
            return {[60] = "GESUCHT: Gath'Ilzogg"}
        end

        _InitializeLocale("deDE")

        assert.are_same("GESUCHT: Gath'Ilzogg", QuestieDB.objectData[60][QuestieDB.objectKeys.name])
    end)

    it("should localize quest names", function()
        l10n.questLookup["deDE"] = function()
            return {[1359] = {"Zinges Lieferung"}}
        end

        _InitializeLocale("deDE")

        assert.are_same("Zinges Lieferung", QuestieDB.questData[1359][QuestieDB.questKeys.name])
    end)

    it("should apply current quest lookup rows as title and objective lines", function()
        l10n.questLookup["deDE"] = function()
            return {[1359] = {"Zinges Lieferung", {"Bringt die Lieferung zu Zinge."}}}
        end

        _InitializeLocale("deDE")

        assert.are_same("Zinges Lieferung", QuestieDB.questData[1359][QuestieDB.questKeys.name])
        assert.are_same({"Bringt die Lieferung zu Zinge."}, QuestieDB.questData[1359][QuestieDB.questKeys.objectivesText])
    end)

    it("should preserve quest objective tables", function()
        l10n.questLookup["deDE"] = function()
            return {[1359] = {"Zinges Lieferung", {"Erster Schritt.", "", "Zweiter Schritt."}}}
        end

        _InitializeLocale("deDE")

        assert.are_same({"Erster Schritt.", "", "Zweiter Schritt."}, QuestieDB.questData[1359][QuestieDB.questKeys.objectivesText])
    end)

    it("should let quest lookup overrides replace normal quest lookup data", function()
        l10n.questLookup["deDE"] = function()
            return {[1359] = {"Normale Lieferung", {"Normales Ziel."}}}
        end
        l10n.questLookupOverrides = function()
            return {[1359] = {"Überschriebene Lieferung", {"Überschriebenes Ziel."}}}
        end

        _InitializeLocale("deDE")

        assert.are_same("Überschriebene Lieferung", QuestieDB.questData[1359][QuestieDB.questKeys.name])
        assert.are_same({"Überschriebenes Ziel."}, QuestieDB.questData[1359][QuestieDB.questKeys.objectivesText])
    end)

    it("should ignore lookup rows for IDs missing from QuestieDB", function()
        l10n.itemLookup["deDE"] = function()
            return {[999001] = "Missing Item"}
        end
        l10n.npcNameLookup["deDE"] = function()
            return {[999002] = "Missing NPC"}
        end
        l10n.objectLookup["deDE"] = function()
            return {[999003] = "Missing Object"}
        end
        l10n.questLookup["deDE"] = function()
            return {[999004] = {"Missing Quest", {"Missing objective."}}}
        end

        _InitializeLocale("deDE")

        assert.is_nil(QuestieDB.itemData[999001])
        assert.is_nil(QuestieDB.npcData[999002])
        assert.is_nil(QuestieDB.objectData[999003])
        assert.is_nil(QuestieDB.questData[999004])
    end)
end)
