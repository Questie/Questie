dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

-- Two quests of which a player can only do one
local UNNERVING_SILENCE, A_SACRIFICE_IN_VAIN = 94484, 94493
local FOLLOW_UP = 1 -- Requires A Sacrifice in Vain
local ORDINARY_QUEST = 2 -- Requires nothing
local FACTION_ID = 1

-- The category for each reason why a quest can't be done, or can: available, completed, missing a requirement, or unobtainable
local CATEGORIES = {
    AVAILABLE = "a", QUEST_LOG = "a",
    COMPLETED = "c",
    NO_PREQUESTSINGLE = "p", NO_PREQUESTGROUP = "p", PARENT_INACTIVE = "p", ENABLING_QUEST_MISSING = "p", BREADCRUMB_ACTIVE = "p",
    MISSING_REPUTATION = "p", EXCEED_REPUTATION = "p", PROFESSION_SKILL = "p", PROFESSION_RANK = "p", SPELL_MISSING = "p",
    MISSING_ACHIEVEMENT = "p", LEVEL_TOO_LOW = "p", ARENA_RATING = "p",
    EXCLUSIVE_COMPLETED = "u", EXCLUSIVE_IN_QUEST_LOG = "u", NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED = "u", BREADCRUMB_FOLLOWUP = "u",
    DISABLING_QUEST_COMPLETED = "u", DISABLED_BY = "u", MISSING_DAILY = "u", INACTIVE_DAILY = "u", EVENT_INACTIVE = "u",
    PROFESSION_SPECIALIZATION = "u", PROFESSION_MISSING = "u", SPELL_KNOWN = "u", LEVEL_TOO_HIGH = "u",
    -- Not listed at all
    BLACKLISTED = false, WRONG_RACE = false, WRONG_CLASS = false,
    PARENT_ACTIVE = "a", -- As long as nothing else prevents it, see below
}

-- Both tabs sort quests into the same categories, so they share these tests.
---@type table<string, fun(): fun(quests: table<QuestId, boolean>): table> Load the tab and return its categorization
local TABS = {
    QuestsByZone = function()
        local _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
        _QuestieJourney.questsByZone = {}
        dofile("Modules/Journey/tabs/QuestsByZone/QuestsByZone.lua")

        return function(quests)
            return _QuestieJourney.questsByZone:CategorizeQuests(quests)
        end
    end,
    QuestsByFaction = function()
        local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieLoader:ImportModule("QuestieJourneyFactions").BuildFactionIntroductionOrder = function() return {} end
        QuestieLoader:ImportModule("QuestieReputation").GetReputationReward = function() end
        dofile("Modules/Journey/tabs/QuestsByFaction/QuestsByFactions.lua")

        return function(quests)
            QuestieJourney.factionMap = {[FACTION_ID] = quests}
            return QuestieJourney.private.questsByFaction:CollectFactionQuests(FACTION_ID)
        end
    end,
}

for tabName, LoadTab in pairs(TABS) do
    describe(tabName, function()
        ---@type QuestieDB
        local QuestieDB
        ---@type ActiveQuests
        local ActiveQuests
        ---@type QuestieDBMock
        local mock
        local CategorizeQuests
        local originals

        ---@param questId QuestId
        ---@param fields table<string, unknown> Values by questKeys name
        local function _SetQuest(questId, fields)
            local row = {}
            for field, value in pairs(fields) do
                row[QuestieDB.questKeys[field]] = value
            end
            mock.SetBaseRow("Quest", questId, row)
        end

        ---@param ... QuestId The quests to categorize
        ---@return table<string, QuestId[]> questsByCategory Quest IDs by the tree's category letter
        ---@return table<string, string> headers Header texts by the tree's category letter
        local function _Categorize(...)
            local quests = {}
            for _, questId in ipairs({...}) do
                quests[questId] = true
            end

            local questsByCategory, headers = {}, {}
            for _, category in ipairs(CategorizeQuests(quests)) do
                headers[category.value] = category.text
                for _, entry in ipairs(category.children) do
                    questsByCategory[category.value] = questsByCategory[category.value] or {}
                    table.insert(questsByCategory[category.value], entry.value)
                end
            end
            return questsByCategory, headers
        end

        before_each(function()
            originals = {
                Questie = _G.Questie,
                LibQuestieDB = _G.LibQuestieDB,
                tinsert = _G.tinsert,
                UnitLevel = _G.UnitLevel,
                IsOnQuest = _G.C_QuestLog.IsOnQuest,
            }
            _G.Questie = {db = {char = {complete = {}, hidden = {}}, profile = {}}, icons = {}}
            _G.tinsert = table.insert
            _G.UnitLevel = function() return 11 end

            dofile("Localization/l10n.lua")
            dofile("Modules/Quest/ActiveQuests.lua")
            ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
            _G.C_QuestLog.IsOnQuest = function(questId) return ActiveQuests.Get(questId) ~= nil end

            QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end
            QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = {}
            local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
            QuestieQuestBlacklist.AQWarEffortQuests = {}
            QuestieQuestBlacklist.InvasionQuests = {}
            QuestieLoader:ImportModule("ContentPhases").IsInvasionActive = {}
            QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function() return false end
            local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
            QuestiePlayer.HasRequiredRace = function() return true end
            QuestiePlayer.HasRequiredClass = function() return true end

            local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
            QuestieLib.GetColoredQuestName = function() return "Quest" end
            QuestieLib.TableMemoizeFunction = function(_, func)
                return setmetatable({}, {__index = function(_, key) return func(key) end})
            end
            QuestieLib.SortQuestIDsByLevel = function(_, quests)
                local sorted = {}
                for questId in pairs(quests) do
                    table.insert(sorted, {11, questId})
                end
                return sorted
            end

            -- The real QuestieDB decides what blocks a quest
            mock = LoadQuestieDBMock()
            QuestieLoader:ImportModule("SupportValidation").ValidateFactionTemplates = function() return true end
            dofile("Database/QuestieDB.lua")
            dofile("Database/Corrections/titanReforgedQuestTags.lua")
            dofile("Database/Corrections/questTagInfoCorrections.lua")
            QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            QuestieDB.IsComplete = function() return 0 end
            _SetQuest(UNNERVING_SILENCE, {exclusiveTo = {A_SACRIFICE_IN_VAIN}})
            _SetQuest(A_SACRIFICE_IN_VAIN, {exclusiveTo = {UNNERVING_SILENCE}})
            _SetQuest(FOLLOW_UP, {preQuestSingle = {A_SACRIFICE_IN_VAIN}})
            _SetQuest(ORDINARY_QUEST, {})
            QuestieDB.Initialize()

            CategorizeQuests = LoadTab()
        end)

        after_each(function()
            _G.Questie, _G.LibQuestieDB = originals.Questie, originals.LibQuestieDB
            _G.tinsert, _G.UnitLevel = originals.tinsert, originals.UnitLevel
            _G.C_QuestLog.IsOnQuest = originals.IsOnQuest
        end)

        describe("a quest", function()
            ---@param state string
            local function _SetState(state)
                QuestieDB.IsDoableVerbose = function() return "", true, QuestieDB.DoableStates[state] end
            end

            it("should have a category in this test for every reason there is", function()
                for state in pairs(QuestieDB.DoableStates) do
                    assert.is_not_nil(CATEGORIES[state], state)
                end
            end)

            for state, category in pairs(CATEGORIES) do
                it("should be in category " .. tostring(category) .. " when it is " .. state, function()
                    _SetState(state)

                    assert.are_same(category and {[category] = {ORDINARY_QUEST}} or {}, (_Categorize(ORDINARY_QUEST)))
                end)
            end

            it("should be unobtainable when it was only available before another reputation", function()
                _SetState("EXCEED_REPUTATION")
                QuestieDB.questsOnlyAvailableUntilReputationValue = {[ORDINARY_QUEST] = true}

                assert.are_same({u = {ORDINARY_QUEST}}, (_Categorize(ORDINARY_QUEST)))
            end)

            it("should be unobtainable when its parent is completed", function()
                _SetState("PARENT_INACTIVE")
                _SetQuest(ORDINARY_QUEST, {parentQuest = UNNERVING_SILENCE})
                Questie.db.char.complete[UNNERVING_SILENCE] = true

                local quests, headers = _Categorize(ORDINARY_QUEST)

                assert.are_same({u = {ORDINARY_QUEST}}, quests)
                assert.are_equal("Unobtainable Quests [ 1 ]", headers.u)
            end)

            it("should be among the repeatable ones when it can be done again", function()
                QuestieDB.IsRepeatable = function() return true end

                for _, state in ipairs({"AVAILABLE", "QUEST_LOG", "PARENT_ACTIVE"}) do
                    _SetState(state)
                    assert.are_same({r = {ORDINARY_QUEST}}, (_Categorize(ORDINARY_QUEST)))
                end
            end)

            it("should also be among the hidden ones when the user hid it", function()
                _SetState("AVAILABLE")
                Questie.db.char.hidden[ORDINARY_QUEST] = true

                local quests, headers = _Categorize(ORDINARY_QUEST)

                assert.are_same({a = {ORDINARY_QUEST}, h = {ORDINARY_QUEST}}, quests)
                assert.are_equal("Hidden Quests [ 1 ]", headers.h)
            end)

            it("should also be among the breadcrumbs when it is one", function()
                _SetState("COMPLETED")
                _SetQuest(ORDINARY_QUEST, {breadcrumbForQuestId = UNNERVING_SILENCE})

                assert.are_same({b = {ORDINARY_QUEST}, c = {ORDINARY_QUEST}}, (_Categorize(ORDINARY_QUEST)))
            end)
        end)

        describe("exclusive quests", function()
            it("should be unobtainable when the other one is completed", function()
                Questie.db.char.complete[UNNERVING_SILENCE] = true

                local quests, headers = _Categorize(UNNERVING_SILENCE, A_SACRIFICE_IN_VAIN)

                assert.are_same({c = {UNNERVING_SILENCE}, u = {A_SACRIFICE_IN_VAIN}}, quests)
                assert.are_equal("Completed Quests [ 1/1 ]", headers.c)
                assert.are_equal("Unobtainable Quests [ 1 ]", headers.u)
            end)

            it("should be unobtainable while the other one is in the quest log", function()
                ActiveQuests.Add(UNNERVING_SILENCE, {})

                local quests, headers = _Categorize(UNNERVING_SILENCE, A_SACRIFICE_IN_VAIN)

                assert.are_same({a = {UNNERVING_SILENCE}, u = {A_SACRIFICE_IN_VAIN}}, quests)
                assert.are_equal("Available Quests [ 1/1 ]", headers.a)
                assert.are_equal("Unobtainable Quests [ 1 ]", headers.u)
            end)

            it("should be completed when both are, because the game completed them together", function()
                Questie.db.char.complete[UNNERVING_SILENCE] = true
                Questie.db.char.complete[A_SACRIFICE_IN_VAIN] = true

                local quests, headers = _Categorize(A_SACRIFICE_IN_VAIN)

                assert.are_same({c = {A_SACRIFICE_IN_VAIN}}, quests)
                assert.are_equal("Completed Quests [ 1/1 ]", headers.c)
            end)

            it("should make their follow-ups unobtainable when they can't be done any more", function()
                Questie.db.char.complete[UNNERVING_SILENCE] = true

                local quests, headers = _Categorize(FOLLOW_UP)

                assert.are_same({u = {FOLLOW_UP}}, quests)
                assert.are_equal("Unobtainable Quests [ 1 ]", headers.u)
            end)
        end)

        describe("child quests of an active parent", function()
            before_each(function()
                QuestieDB.activeChildQuests[A_SACRIFICE_IN_VAIN] = true
            end)

            it("should be unobtainable when an exclusive quest is completed", function()
                Questie.db.char.complete[UNNERVING_SILENCE] = true

                local quests, headers = _Categorize(A_SACRIFICE_IN_VAIN)

                assert.are_same({u = {A_SACRIFICE_IN_VAIN}}, quests)
                assert.are_equal("Unobtainable Quests [ 1 ]", headers.u)
                assert.are_equal("Completed Quests [ 0/0 ]", headers.c)
            end)

            it("should be unobtainable while an exclusive quest is in the quest log", function()
                ActiveQuests.Add(UNNERVING_SILENCE, {})

                assert.are_same({u = {A_SACRIFICE_IN_VAIN}}, (_Categorize(A_SACRIFICE_IN_VAIN)))
            end)

            it("should be listed once when several exclusive quests block them", function()
                _SetQuest(A_SACRIFICE_IN_VAIN, {exclusiveTo = {UNNERVING_SILENCE, FOLLOW_UP}})
                Questie.db.char.complete[UNNERVING_SILENCE] = true
                Questie.db.char.complete[FOLLOW_UP] = true

                assert.are_same({u = {A_SACRIFICE_IN_VAIN}}, (_Categorize(A_SACRIFICE_IN_VAIN)))
            end)

            it("should be available when no exclusive quest blocks them", function()
                assert.are_same({a = {A_SACRIFICE_IN_VAIN}}, (_Categorize(A_SACRIFICE_IN_VAIN)))
            end)
        end)
    end)
end
