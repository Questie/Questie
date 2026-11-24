dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("The quests of a zone", function()
    local questsByZone
    local ui
    local originalQuestie, originalUnitLevel, originalTinsert
    local QuestieDB, QuestieCorrections
    local states, levels, repeatable, breadcrumbs, eventQuests

    local STATES = {
        "AVAILABLE", "COMPLETED", "QUEST_LOG", "PARENT_ACTIVE", "NO_PREQUESTSINGLE", "MISSING_REPUTATION", "LEVEL_TOO_HIGH",
        "LEVEL_TOO_LOW", "EXCLUSIVE_COMPLETED", "WRONG_RACE", "SPELL_KNOWN",
    }
    local HIDE_ON_MAP = "HIDE_ON_MAP"

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalUnitLevel, originalTinsert = _G.Questie, _G.UnitLevel, _G.tinsert
        _G.UnitLevel = function() return 10 end
        _G.Questie = {
            db = {char = {complete = {}, hidden = {}}, profile = {}},
            Error = function(_, message) error(message) end,
        }
        states, levels, repeatable, breadcrumbs, eventQuests = {}, {}, {}, {}, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Journey/JourneyThread.lua")

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.DoableStates = {}
        for index, state in ipairs(STATES) do QuestieDB.DoableStates[state] = index end
        QuestieDB.QuestPointers = setmetatable({}, {__index = function(_, id) return id < 1000 or nil end})
        QuestieDB.IsDoableVerbose = function(id) return "", true, QuestieDB.DoableStates[states[id] or "AVAILABLE"] end
        QuestieDB.IsRepeatable = function(id) return repeatable[id] == true end
        QuestieDB.QueryQuest = function(id) return {breadcrumbs[id] or 0} end
        QuestieDB.QueryQuestSingle = function() end
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieLoader:ImportModule("QuestieQuestBlacklist").HIDE_ON_MAP = HIDE_ON_MAP
        QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function(id) return eventQuests[id] == true end
        QuestieLoader:ImportModule("ActiveQuests").Get = function() end
        QuestieLoader:ImportModule("QuestiePlayer").HasRequiredRace = function() return true end
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function(_, id) return "Quest " .. id end
        QuestieLib.SortQuestIDsByLevel = function(_, quests, _, onQuestLookedUp)
            local sorted = {}
            for id in pairs(quests) do
                table.insert(sorted, {levels[id] or 10, id})
                onQuestLookedUp()
            end
            table.sort(sorted, function(a, b) return a[1] < b[1] or a[1] == b[1] and a[2] < b[2] end)
            return sorted
        end

        local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieJourney.zoneMap = {[12] = {[1] = true, [2] = true}}
        QuestieJourney.private.questsByZone = {}
        dofile("Modules/Journey/tabs/QuestsByZone/QuestsByZone.lua")
        questsByZone = QuestieJourney.private.questsByZone
    end)

    after_each(function()
        _G.Questie, _G.UnitLevel, _G.tinsert = originalQuestie, originalUnitLevel, originalTinsert
        ui.Restore()
    end)

    ---@param ... number The quests
    ---@return table<string, number[]> questIdsByCategory Without the empty ones
    ---@return JourneyTreeNode[] nodes
    local function Categorize(...)
        local quests, nodes = {}, nil
        for _, id in ipairs({...}) do quests[id] = true end
        QuestieLoader:ImportModule("JourneyThread").Start("Test", function()
            nodes = questsByZone:CategorizeQuests(quests)
        end)
        ui.RunUntilIdle()

        local idsByCategory = {}
        for _, category in ipairs(nodes) do
            local ids = {}
            for _, quest in ipairs(category.children) do table.insert(ids, quest.value) end
            if #ids > 0 then idsByCategory[category.value] = ids end
        end
        return idsByCategory, nodes
    end

    for state, category in pairs({
        AVAILABLE = "a", QUEST_LOG = "a", COMPLETED = "c", NO_PREQUESTSINGLE = "p", MISSING_REPUTATION = "p", LEVEL_TOO_LOW = "p",
        LEVEL_TOO_HIGH = "u", SPELL_KNOWN = "u", EXCLUSIVE_COMPLETED = "u",
    }) do
        it("should be in category " .. category .. " when they are " .. state, function()
            states[7] = state

            assert.are_same({[category] = {7}}, Categorize(7))
        end)
    end

    it("should leave out what the player's race can't do", function()
        states[7] = "WRONG_RACE"

        assert.are_same({}, Categorize(7))
    end)

    it("should have repeatable ones in their own category", function()
        repeatable[7] = true

        assert.are_same({r = {7}}, Categorize(7))
    end)

    it("should have breadcrumb quests in two categories", function()
        breadcrumbs[7] = 8
        states[7] = "COMPLETED"

        assert.are_same({b = {7}, c = {7}}, Categorize(7))
    end)

    it("should not have hidden ones, except those that are only hidden on the map and those of events", function()
        QuestieCorrections.hiddenQuests = {[7] = true, [8] = HIDE_ON_MAP, [9] = true}
        eventQuests[9] = true

        assert.are_same({a = {8, 9, 10}}, Categorize(7, 8, 9, 10))
    end)

    it("should not have ones that aren't in the database", function()
        assert.are_same({a = {7}}, Categorize(7, 1234))
    end)

    it("should show which ones the user hid in a category of their own", function()
        local _, nodes = Categorize(7)
        assert.are.equal(6, #nodes)

        Questie.db.char.hidden[7] = true
        assert.are_same({a = {7}, h = {7}}, Categorize(7))
    end)

    it("should be sorted by level", function()
        levels[7], levels[8], levels[9] = 20, 5, 12

        assert.are_same({a = {8, 9, 7}}, Categorize(7, 8, 9))
    end)

    it("should show how many there are", function()
        states[8], states[9] = "COMPLETED", "LEVEL_TOO_LOW"
        repeatable[10] = true

        local _, nodes = Categorize(7, 8, 9, 10)

        local texts = {}
        for index, node in ipairs(nodes) do texts[index] = node.text end
        assert.are_same({
            "Breadcrumb Quests [ 0 ]",
            "Available Quests [ 1/3 ]",
            "Repeatable Quests [ 1 ]",
            "Completed Quests [ 1/3 ]",
            "Missing Requirement [ 1/3 ]",
            "Unobtainable Quests [ 0 ]",
        }, texts)
    end)

    describe("when there are many", function()
        local quests, SortQuestIDsByLevel

        before_each(function()
            ui.clockStep = 0.003
            quests = {}
            for id = 1, 100 do quests[id] = true end
            SortQuestIDsByLevel = QuestieLoader:ImportModule("QuestieLib").SortQuestIDsByLevel
        end)

        ---@return number frames
        local function CountFrames()
            QuestieLoader:ImportModule("JourneyThread").Start("Test", function() questsByZone:CategorizeQuests(quests) end)
            return ui.RunUntilIdle()
        end

        it("should be sorted over several frames", function()
            QuestieLoader:ImportModule("QuestieLib").SortQuestIDsByLevel = function(...)
                SortQuestIDsByLevel(...)
                return {}
            end

            assert.is_true(CountFrames() > 20)
        end)

        it("should be put into categories over several frames", function()
            QuestieLoader:ImportModule("QuestieLib").SortQuestIDsByLevel = function(_, unsorted)
                return SortQuestIDsByLevel(_, unsorted, false, function() end)
            end

            assert.is_true(CountFrames() > 20)
        end)
    end)

    it("should come from the zone, if it has any", function()
        local quests = questsByZone:CollectZoneQuests(12)

        assert.are.equal(2, #quests[2].children)
        assert.is_nil(questsByZone:CollectZoneQuests(404))
    end)
end)
