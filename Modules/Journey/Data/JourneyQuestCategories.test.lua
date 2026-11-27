dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

-- Two quests of which a player can only do one
local UNNERVING_SILENCE, A_SACRIFICE_IN_VAIN = 94484, 94493
local FOLLOW_UP = 1 -- Requires A Sacrifice in Vain
local ORDINARY_QUEST = 2 -- Requires nothing
local WOLVES, KOBOLDS = 3, 4

-- The category for each reason why a quest can be done, or can't
local CATEGORIES = {
    AVAILABLE = "available", PARENT_ACTIVE = "available", -- As long as nothing else prevents it, see below
    QUEST_LOG = "log",
    COMPLETED = "completed",
    NO_PREQUESTSINGLE = "later", NO_PREQUESTGROUP = "later", PARENT_INACTIVE = "later", ENABLING_QUEST_MISSING = "later",
    BREADCRUMB_ACTIVE = "later", MISSING_REPUTATION = "later", EXCEED_REPUTATION = "later", PROFESSION_SKILL = "later",
    PROFESSION_RANK = "later", SPELL_MISSING = "later", MISSING_ACHIEVEMENT = "later", LEVEL_TOO_LOW = "later", ARENA_RATING = "later",
    EXCLUSIVE_COMPLETED = "unobtainable", EXCLUSIVE_IN_QUEST_LOG = "unobtainable", NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED = "unobtainable",
    BREADCRUMB_FOLLOWUP = "unobtainable", DISABLING_QUEST_COMPLETED = "unobtainable", DISABLED_BY = "unobtainable",
    MISSING_DAILY = "unobtainable", INACTIVE_DAILY = "unobtainable", EVENT_INACTIVE = "unobtainable",
    PROFESSION_SPECIALIZATION = "unobtainable", PROFESSION_MISSING = "unobtainable", SPELL_KNOWN = "unobtainable",
    LEVEL_TOO_HIGH = "unobtainable",
    -- Not listed at all
    BLACKLISTED = false, WRONG_RACE = false, WRONG_CLASS = false,
}

describe("JourneyQuestCategories", function()
    ---@type JourneyQuestCategories
    local JourneyQuestCategories
    ---@type JourneyIcon
    local JourneyIcon
    ---@type QuestieDB
    local QuestieDB
    ---@type ActiveQuests
    local ActiveQuests
    ---@type QuestieDBMock
    local mock
    local GLOBALS = {
        "Questie", "LibQuestieDB", "UnitLevel", "QUEST_LOG", "CALENDAR_FULLDATE_MONTH_NAMES", "BreakUpLargeNumbers",
        "QUEST_WATCH_QUEST_READY", "QUEST_TOOLTIP_ACTIVE", "ITEM_MIN_LEVEL",
    }
    local originals, originalIsOnQuest
    local hiddenQuests, eventQuests, levels, xp, questLog, objectives
    -- What QuestieDB says a quest is, for its icon
    local pvpQuests, repeatableQuests, activeEventQuests

    ---@param questId QuestId
    ---@param fields table<string, unknown> Values by questKeys name
    local function SetQuest(questId, fields)
        local row = {}
        for field, value in pairs(fields) do
            row[QuestieDB.questKeys[field]] = value
        end
        mock.SetBaseRow("Quest", questId, row)
    end

    ---@param state string What QuestieDB says about every quest, instead of finding out
    ---@param text string?
    local function SetState(state, text)
        QuestieDB.IsDoableVerbose = function() return text or "", true, QuestieDB.DoableStates[state] end
    end

    ---@param states table<QuestId, string> What QuestieDB says about each quest, instead of finding out
    local function SetStates(states)
        QuestieDB.IsDoableVerbose = function(questId)
            return "Unavailable: " .. states[questId], true, QuestieDB.DoableStates[states[questId]]
        end
    end

    ---@param month number
    ---@param day number
    ---@return number timestamp At noon, so it is the same day in every time zone
    local function Day(month, day)
        return os.time({year = 2026, month = month, day = day, hour = 12})
    end

    ---@param ... QuestId The quests to sort
    ---@return table<JourneyQuestCategory, QuestId[]> questsByCategory Only the categories with quests
    ---@return table<JourneyQuestCategory, JourneyTreeNode> nodes By category
    local function Collect(...)
        local quests = {}
        for _, questId in ipairs({...}) do
            quests[questId] = true
        end

        local questsByCategory, nodes = {}, {}
        for _, category in ipairs((JourneyQuestCategories.Collect(quests))) do
            nodes[category.value] = category
            for _, quest in ipairs(category.children) do
                questsByCategory[category.value] = questsByCategory[category.value] or {}
                table.insert(questsByCategory[category.value], quest.value)
            end
        end
        return questsByCategory, nodes
    end

    before_each(function()
        originals = {}
        for _, name in ipairs(GLOBALS) do originals[name] = _G[name] end
        originalIsOnQuest = _G.C_QuestLog.IsOnQuest

        _G.Questie = {
            db = {
                char = {complete = {}, hidden = {}, journey = {}},
                profile = {},
                global = {unavailableQuestsDeterminedByTalking = {[GetRealmName()] = {}}},
            },
            -- Every icon is its name
            icons = setmetatable({}, {__index = function(_, name) return name end}),
            Colorize = function(_, text, color) return text .. " in " .. color end,
        }
        _G.UnitLevel = function() return 11 end
        _G.QUEST_LOG = "Quest Log"
        _G.QUEST_WATCH_QUEST_READY, _G.QUEST_TOOLTIP_ACTIVE = "Ready for turn-in", "You are on this quest"
        _G.ITEM_MIN_LEVEL = "Requires Level %d"
        _G.CALENDAR_FULLDATE_MONTH_NAMES = {
            "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
        }
        -- Like Blizzard's, with the separator of English clients
        _G.BreakUpLargeNumbers = function(number)
            return (tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
        end

        dofile("Localization/l10n.lua")
        dofile("Modules/Quest/ActiveQuests.lua")
        ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
        _G.C_QuestLog.IsOnQuest = function(questId) return ActiveQuests.Get(questId) ~= nil end

        hiddenQuests, eventQuests, levels, xp, questLog, objectives = {}, {}, {}, {}, {}, {}
        pvpQuests, repeatableQuests, activeEventQuests = {}, {}, {}
        QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end
        QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = hiddenQuests
        local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
        QuestieQuestBlacklist.HIDE_ON_MAP = "HIDE_ON_MAP" -- As in QuestieQuestBlacklist
        QuestieQuestBlacklist.AQWarEffortQuests = {}
        QuestieQuestBlacklist.InvasionQuests = {}
        QuestieLoader:ImportModule("ContentPhases").IsInvasionActive = {}
        QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function(questId) return eventQuests[questId] == true end
        QuestieLoader:ImportModule("DailyQuests").ShouldBeHidden = function() return false end
        local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end
        QuestieLoader:ImportModule("QuestXP").GetQuestLogRewardXP = function(_, questId) return xp[questId] or 0 end

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function(_, questId) return "Quest " .. questId end
        QuestieLib.GetEffectiveQuestLevel = function(questId) return levels[questId] or 11 end
        QuestieLib.TableMemoizeFunction = function(_, func)
            return setmetatable({}, {__index = function(_, key) return func(key) end})
        end
        QuestieLib.SortQuestIDsByLevel = function(_, quests)
            local sorted = {}
            for questId in pairs(quests) do
                table.insert(sorted, {levels[questId] or 11, questId})
            end
            table.sort(sorted, function(a, b) return a[1] < b[1] or a[1] == b[1] and a[2] < b[2] end)
            return sorted
        end

        -- The real QuestieDB decides what blocks a quest
        mock = LoadQuestieDBMock()
        QuestieLoader:ImportModule("SupportValidation").ValidateFactionTemplates = function() return true end
        dofile("Database/QuestieDB.lua")
        dofile("Database/Corrections/titanReforgedQuestTags.lua")
        dofile("Database/Corrections/questTagInfoCorrections.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsComplete = function(questId) return questLog[questId] or 0 end
        QuestieDB.GetQuest = function(questId) return {Id = questId, Objectives = objectives[questId] or {}} end
        QuestieDB.IsPvPQuest = function(questId) return pvpQuests[questId] == true end
        QuestieDB.IsRepeatable = function(questId) return repeatableQuests[questId] == true end
        QuestieDB.IsActiveEventQuest = function(questId) return activeEventQuests[questId] == true end
        QuestieDB.IsTrivial = function(level) return level < 6 end -- Too low for the player at 11
        SetQuest(UNNERVING_SILENCE, {name = "Unnerving Silence", exclusiveTo = {A_SACRIFICE_IN_VAIN}})
        SetQuest(A_SACRIFICE_IN_VAIN, {name = "A Sacrifice in Vain", exclusiveTo = {UNNERVING_SILENCE}})
        SetQuest(FOLLOW_UP, {name = "Follow-up", preQuestSingle = {A_SACRIFICE_IN_VAIN}})
        SetQuest(ORDINARY_QUEST, {name = "Ordinary Quest"})
        SetQuest(WOLVES, {name = "Wolves", objectivesText = {"Kill wolves."}})
        SetQuest(KOBOLDS, {name = "Kobolds", objectivesText = {"Kill kobolds."}})
        QuestieDB.Initialize()

        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Data/JourneyPrerequisites.lua")
        dofile("Modules/Libs/utf8.lua")
        dofile("Modules/Journey/Data/JourneyQuestCategories.lua")
        JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
    end)

    after_each(function()
        for _, name in ipairs(GLOBALS) do _G[name] = originals[name] end
        _G.C_QuestLog.IsOnQuest = originalIsOnQuest
    end)

    describe("Get", function()
        it("should have a category in this test for every reason there is", function()
            for state in pairs(QuestieDB.DoableStates) do
                assert.is_not_nil(CATEGORIES[state], state)
            end
        end)

        for state, category in pairs(CATEGORIES) do
            it("should put a quest that is " .. state .. " " .. (category and "among the " .. category .. " ones" or "nowhere"), function()
                SetState(state)

                local actualCategory, _, stateName = JourneyQuestCategories.Get(ORDINARY_QUEST)

                assert.are.equal(category or nil, actualCategory)
                assert.are.equal(state, stateName)
            end)
        end

        it("should be unobtainable when it was only available before another reputation", function()
            SetState("EXCEED_REPUTATION")
            QuestieDB.questsOnlyAvailableUntilReputationValue = {[ORDINARY_QUEST] = true}

            assert.are.equal("unobtainable", (JourneyQuestCategories.Get(ORDINARY_QUEST)))
        end)

        it("should be unobtainable when its parent is completed, and missing a requirement until the parent is accepted", function()
            SetQuest(ORDINARY_QUEST, {parentQuest = WOLVES})
            QuestieDB.Initialize()

            assert.are.equal("later", (JourneyQuestCategories.Get(ORDINARY_QUEST)))

            Questie.db.char.complete[WOLVES] = true
            assert.are.equal("unobtainable", (JourneyQuestCategories.Get(ORDINARY_QUEST)))
        end)

        it("should be among the repeatable ones when it can be done again", function()
            repeatableQuests[ORDINARY_QUEST] = true

            for _, state in ipairs({"AVAILABLE", "PARENT_ACTIVE"}) do
                SetState(state)
                assert.are.equal("repeatable", (JourneyQuestCategories.Get(ORDINARY_QUEST)), state)
            end
        end)

        it("should keep a repeatable quest in the quest log while it is accepted", function()
            repeatableQuests[ORDINARY_QUEST] = true
            SetState("QUEST_LOG")

            assert.are.equal("log", (JourneyQuestCategories.Get(ORDINARY_QUEST)))
        end)

        describe("reason", function()
            it("should be what QuestieDB says without its Unavailable", function()
                SetState("SPELL_MISSING", "Unavailable: Spell not yet learned")
                assert.are.equal("Spell not yet learned", select(2, JourneyQuestCategories.Get(ORDINARY_QUEST)))

                SetState("MISSING_DAILY", "Daily quest not active")
                assert.are.equal("Daily quest not active", select(2, JourneyQuestCategories.Get(ORDINARY_QUEST)))
            end)

            it("should be missing for a quest that can be done, or was", function()
                for _, state in ipairs({"AVAILABLE", "QUEST_LOG", "COMPLETED"}) do
                    SetState(state, "Unavailable: Already complete")
                    assert.is_nil(select(2, JourneyQuestCategories.Get(ORDINARY_QUEST)), state)
                end
            end)

            it("should name the quest that has to be done first", function()
                assert.are.equal("after A Sacrifice in Vain", select(2, JourneyQuestCategories.Get(FOLLOW_UP)))
            end)

            it("should name the first quest of a group that isn't done yet", function()
                SetQuest(ORDINARY_QUEST, {preQuestGroup = {WOLVES, KOBOLDS}})
                QuestieDB.Initialize()
                Questie.db.char.complete[WOLVES] = true

                local category, reason, stateName = JourneyQuestCategories.Get(ORDINARY_QUEST)

                assert.are_same({"later", "after Kobolds", "NO_PREQUESTGROUP"}, {category, reason, stateName})
            end)

            it("should skip a quest of the group that is done by doing its exclusive one", function()
                -- The game counts A Sacrifice in Vain as done, when its exclusive quest was done instead
                SetQuest(ORDINARY_QUEST, {preQuestGroup = {A_SACRIFICE_IN_VAIN, KOBOLDS}})
                QuestieDB.Initialize()
                Questie.db.char.complete[UNNERVING_SILENCE] = true

                local category, reason, stateName = JourneyQuestCategories.Get(ORDINARY_QUEST)

                assert.are_same({"later", "after Kobolds", "NO_PREQUESTGROUP"}, {category, reason, stateName})
            end)

            it("should be the level a quest needs when the player is too low", function()
                SetQuest(ORDINARY_QUEST, {requiredLevel = 14})
                QuestieDB.Initialize()

                local category, reason, stateName = JourneyQuestCategories.Get(ORDINARY_QUEST)

                assert.are_same({"later", "Level 14", "LEVEL_TOO_LOW"}, {category, reason, stateName})
            end)
        end)
    end)

    describe("exclusive quests", function()
        it("should be unobtainable when the other one is completed", function()
            Questie.db.char.complete[UNNERVING_SILENCE] = true

            local quests, nodes = Collect(UNNERVING_SILENCE, A_SACRIFICE_IN_VAIN)

            assert.are_same({completed = {UNNERVING_SILENCE}, unobtainable = {A_SACRIFICE_IN_VAIN}}, quests)
            assert.are.equal("Exclusive quest completed", nodes.unobtainable.children[1].note)
        end)

        it("should be unobtainable while the other one is in the quest log", function()
            ActiveQuests.Add(UNNERVING_SILENCE, {})

            local quests = Collect(UNNERVING_SILENCE, A_SACRIFICE_IN_VAIN)

            assert.are_same({log = {UNNERVING_SILENCE}, unobtainable = {A_SACRIFICE_IN_VAIN}}, quests)
        end)

        it("should be completed when both are, because the game completed them together", function()
            Questie.db.char.complete[UNNERVING_SILENCE] = true
            Questie.db.char.complete[A_SACRIFICE_IN_VAIN] = true

            assert.are_same({completed = {A_SACRIFICE_IN_VAIN}}, (Collect(A_SACRIFICE_IN_VAIN)))
        end)

        it("should make their follow-ups unobtainable when they can't be done any more", function()
            assert.are_same({later = {FOLLOW_UP}}, (Collect(FOLLOW_UP)))

            Questie.db.char.complete[UNNERVING_SILENCE] = true

            assert.are_same({unobtainable = {FOLLOW_UP}}, (Collect(FOLLOW_UP)))
        end)
    end)

    describe("child quests of an active parent", function()
        before_each(function()
            QuestieDB.activeChildQuests[A_SACRIFICE_IN_VAIN] = true
        end)

        it("should be unobtainable when an exclusive quest is completed", function()
            Questie.db.char.complete[UNNERVING_SILENCE] = true

            assert.are_same({unobtainable = {A_SACRIFICE_IN_VAIN}}, (Collect(A_SACRIFICE_IN_VAIN)))
        end)

        it("should be unobtainable while an exclusive quest is in the quest log", function()
            ActiveQuests.Add(UNNERVING_SILENCE, {})

            assert.are_same({unobtainable = {A_SACRIFICE_IN_VAIN}}, (Collect(A_SACRIFICE_IN_VAIN)))
        end)

        it("should be listed once when several exclusive quests block them", function()
            SetQuest(A_SACRIFICE_IN_VAIN, {exclusiveTo = {UNNERVING_SILENCE, FOLLOW_UP}})
            QuestieDB.Initialize()
            Questie.db.char.complete[UNNERVING_SILENCE] = true
            Questie.db.char.complete[FOLLOW_UP] = true

            assert.are_same({unobtainable = {A_SACRIFICE_IN_VAIN}}, (Collect(A_SACRIFICE_IN_VAIN)))
        end)

        it("should be available when no exclusive quest blocks them", function()
            assert.are_same({available = {A_SACRIFICE_IN_VAIN}}, (Collect(A_SACRIFICE_IN_VAIN)))
        end)
    end)

    describe("Collect", function()
        it("should list every category in its order, with how many quests it has", function()
            SetStates({[WOLVES] = "QUEST_LOG", [KOBOLDS] = "AVAILABLE", [ORDINARY_QUEST] = "AVAILABLE", [FOLLOW_UP] = "COMPLETED"})

            local categories = {}
            local nodes = JourneyQuestCategories.Collect({[WOLVES] = 1, [KOBOLDS] = 1, [ORDINARY_QUEST] = 1, [FOLLOW_UP] = 1})
            for _, category in ipairs(nodes) do
                table.insert(categories, category.text .. " " .. category.note)
            end

            assert.are_same({
                "Quest Log 1", "Available Quests 2", "Repeatable Quests 0", "Missing Requirement 0", "Completed Quests 1",
                "Unobtainable Quests 0", "Hidden Quests 0",
            }, categories)
        end)

        it("should list the quests of a category by their names, from the lowest level to the highest", function()
            SetState("AVAILABLE")
            levels[WOLVES], levels[KOBOLDS] = 20, 5

            local _, nodes = Collect(WOLVES, KOBOLDS)

            assert.are_same({"Quest " .. KOBOLDS, "Quest " .. WOLVES}, {nodes.available.children[1].text, nodes.available.children[2].text})
        end)

        it("should also list a quest the player hid among the hidden ones, with the crossed-out eye", function()
            SetState("AVAILABLE")
            Questie.db.char.hidden[WOLVES] = true

            local quests, nodes = Collect(WOLVES, KOBOLDS)

            assert.are_same({available = {WOLVES, KOBOLDS}, hidden = {WOLVES}}, quests)
            assert.are.equal(JourneyIcon.HIDDEN, nodes.hidden.children[1].icon)
            assert.are.equal(JourneyIcon.HIDDEN, nodes.available.children[1].icon)
            assert.are.equal("1", nodes.hidden.note)
        end)

        it("should leave out quests that aren't in the database and those Questie hides, but not those only hidden on the map", function()
            local NOT_IN_DATABASE, EVENT_QUEST = 1000, ORDINARY_QUEST
            SetState("AVAILABLE")
            hiddenQuests[WOLVES], hiddenQuests[KOBOLDS] = true, "HIDE_ON_MAP"
            -- Event quests are hidden until their event
            hiddenQuests[EVENT_QUEST], eventQuests[EVENT_QUEST] = true, true

            assert.are_same({available = {EVENT_QUEST, KOBOLDS}}, (Collect(NOT_IN_DATABASE, WOLVES, KOBOLDS, EVENT_QUEST)))
        end)

        it("should count the completed quests, and all those that can be done once", function()
            SetStates({
                [WOLVES] = "QUEST_LOG", [KOBOLDS] = "AVAILABLE", [ORDINARY_QUEST] = "SPELL_MISSING", [FOLLOW_UP] = "COMPLETED",
                [UNNERVING_SILENCE] = "EXCLUSIVE_COMPLETED", [A_SACRIFICE_IN_VAIN] = "AVAILABLE",
            })
            repeatableQuests[A_SACRIFICE_IN_VAIN] = true
            -- Counted once, though it is listed twice
            Questie.db.char.hidden[KOBOLDS] = true

            local _, completed, total = JourneyQuestCategories.Collect({
                [WOLVES] = 1, [KOBOLDS] = 1, [ORDINARY_QUEST] = 1, [FOLLOW_UP] = 1, [UNNERVING_SILENCE] = 1, [A_SACRIFICE_IN_VAIN] = 1,
            })

            assert.are_same({1, 4}, {completed, total})
        end)

        describe("note", function()
            it("should be how far a quest in the log is", function()
                SetState("QUEST_LOG")
                objectives[WOLVES] = {{Collected = 2, Needed = 5}, {Collected = 1, Needed = 3}}

                local _, nodes = Collect(WOLVES)

                assert.are.equal("3/8", nodes.log.children[1].note)
            end)

            it("should be when a quest was completed the last time, as far as the journey knows", function()
                SetState("COMPLETED")
                Questie.db.char.journey = {
                    {Event = "Quest", SubType = "Complete", Quest = WOLVES, Timestamp = Day(5, 1)},
                    {Event = "Quest", SubType = "Complete", Quest = WOLVES, Timestamp = Day(11, 7)},
                    {Event = "Quest", SubType = "Abandon", Quest = WOLVES, Timestamp = Day(11, 9)},
                }

                local _, nodes = Collect(WOLVES, KOBOLDS)

                assert.are_same({"Nov 7"}, {nodes.completed.children[1].note, nodes.completed.children[2].note})
            end)

            it("should be the experience a quest gives, when it gives any", function()
                SetStates({[WOLVES] = "AVAILABLE", [KOBOLDS] = "AVAILABLE", [ORDINARY_QUEST] = "AVAILABLE"})
                repeatableQuests[ORDINARY_QUEST] = true
                xp[WOLVES], xp[ORDINARY_QUEST] = 1250, 90

                local _, nodes = Collect(WOLVES, KOBOLDS, ORDINARY_QUEST)

                assert.are_same({"1,250 xp"}, {nodes.available.children[1].note, nodes.available.children[2].note})
                assert.are.equal("90 xp", nodes.repeatable.children[1].note)
            end)

            it("should be why a quest can't be done", function()
                SetStates({[WOLVES] = "SPELL_MISSING", [KOBOLDS] = "SPELL_KNOWN"})

                local _, nodes = Collect(WOLVES, KOBOLDS)

                assert.are.equal("SPELL_MISSING", nodes.later.children[1].note)
                assert.are.equal("SPELL_KNOWN", nodes.unobtainable.children[1].note)
            end)
        end)
    end)

    describe("Arrange", function()
        ---@param questIds QuestId[]
        ---@return string[] entries Each as its quest, category and note
        local function Arrange(questIds)
            local entries = {}
            for _, entry in ipairs(JourneyQuestCategories.Arrange(questIds)) do
                table.insert(entries, entry.questId .. " " .. entry.category .. " " .. tostring(entry.note))
            end
            return entries
        end

        it("should give the quests in the order of the list: by category, and by level in each", function()
            SetStates({[WOLVES] = "AVAILABLE", [KOBOLDS] = "QUEST_LOG", [ORDINARY_QUEST] = "AVAILABLE", [FOLLOW_UP] = "COMPLETED"})
            levels[WOLVES], levels[ORDINARY_QUEST] = 20, 5

            assert.are_same({
                KOBOLDS .. " log nil", ORDINARY_QUEST .. " available nil", WOLVES .. " available nil", FOLLOW_UP .. " completed nil",
            }, Arrange({FOLLOW_UP, WOLVES, KOBOLDS, ORDINARY_QUEST}))
        end)

        it("should leave out what the list leaves out", function()
            local NOT_IN_DATABASE = 1000
            SetStates({[WOLVES] = "AVAILABLE", [KOBOLDS] = "WRONG_RACE", [ORDINARY_QUEST] = "AVAILABLE"})
            hiddenQuests[ORDINARY_QUEST] = true

            assert.are_same({WOLVES .. " available nil"}, Arrange({NOT_IN_DATABASE, WOLVES, KOBOLDS, ORDINARY_QUEST}))
        end)

        it("should say at the right edge what the list says", function()
            SetStates({[WOLVES] = "AVAILABLE", [KOBOLDS] = "QUEST_LOG", [ORDINARY_QUEST] = "SPELL_MISSING"})
            xp[WOLVES] = 1250
            objectives[KOBOLDS] = {{Collected = 2, Needed = 5}}

            assert.are_same({KOBOLDS .. " log 2/5", WOLVES .. " available 1,250 xp", ORDINARY_QUEST .. " later SPELL_MISSING"},
                Arrange({WOLVES, KOBOLDS, ORDINARY_QUEST}))
        end)

        it("should give nothing without quests", function()
            assert.are_same({}, Arrange({}))
        end)
    end)

    describe("GetStatus", function()
        for situation, case in pairs({
            ["in the quest log"] = {state = "QUEST_LOG", text = "You are on this quest in lightBlue"},
            ["ready to turn in"] = {state = "QUEST_LOG", isComplete = 1, text = "|Tcomplete:14|t Ready for turn-in in green"},
            ["failed"] = {state = "QUEST_LOG", isComplete = -1, text = "|Tcross:14|t Failed in red"},
            ["available"] = {state = "AVAILABLE", text = "|Tavailable:14|t Available in gold"},
            ["repeatable"] = {state = "AVAILABLE", repeatable = true, text = "|Trepeatable:14|t Available in gold"},
            ["completed"] = {state = "COMPLETED", text = "|Tcheckmark:14|t Completed"},
            ["too low a level for"] = {state = "LEVEL_TOO_LOW", text = "|Tcross:14|t Unavailable:  in redRequires Level 5"},
            ["after another quest"] = {state = "NO_PREQUESTSINGLE", text = "|Tcross:14|t Unavailable:  in redIncomplete pre-quest"},
            ["after other quests"] = {state = "NO_PREQUESTGROUP", text = "|Tcross:14|t Unavailable:  in redIncomplete pre-quest group"},
            ["for another reason"] = {
                state = "MISSING_REPUTATION", reason = "Unavailable: Requires Honored with Stormwind",
                text = "|Tcross:14|t Unavailable:  in redRequires Honored with Stormwind",
            },
            ["no longer obtainable"] = {
                state = "EXCLUSIVE_COMPLETED", reason = "Unavailable: Exclusive quest completed",
                text = "|Tcross:14|t Unavailable:  in redExclusive quest completed",
            },
            -- Then why the game says it can't be done
            ["not listed"] = {state = "WRONG_RACE", reason = "Unavailable: Wrong race", text = "|Tcross:14|t Unavailable: Wrong race"},
        }) do
            it("should say what the player can do with a quest that is " .. situation, function()
                SetQuest(WOLVES, {name = "Wolves", objectivesText = {"Kill wolves."}, requiredLevel = 5})
                SetState(case.state, case.reason)
                questLog[WOLVES] = case.isComplete
                repeatableQuests[WOLVES] = case.repeatable

                assert.are.equal(case.text, JourneyQuestCategories.GetStatus(WOLVES))
            end)
        end
    end)

    describe("GetLogState", function()
        it("should say whether a quest in the log is ready to be turned in, failed, or still to be done", function()
            questLog[WOLVES], questLog[KOBOLDS] = 1, -1

            assert.are_same({"ready", "failed", "active"}, {
                JourneyQuestCategories.GetLogState(WOLVES), JourneyQuestCategories.GetLogState(KOBOLDS),
                JourneyQuestCategories.GetLogState(ORDINARY_QUEST),
            })
        end)
    end)

    describe("GetProgress", function()
        it("should show nothing to count for a quest with one thing to do, or none", function()
            objectives[WOLVES] = {{Collected = 0, Needed = 1}}

            assert.is_nil(JourneyQuestCategories.GetProgress(WOLVES))
            assert.is_nil(JourneyQuestCategories.GetProgress(KOBOLDS))
        end)

        it("should say that a quest is complete, in green, or failed, in red", function()
            objectives[WOLVES] = {{Collected = 5, Needed = 5}}
            questLog[WOLVES] = 1
            assert.are.equal("complete in green", JourneyQuestCategories.GetProgress(WOLVES))

            questLog[WOLVES] = -1
            assert.are.equal("failed in red", JourneyQuestCategories.GetProgress(WOLVES))
        end)
    end)

    describe("GetShortDate", function()
        it("should have the first letters of the month and the day without a leading zero", function()
            assert.are.equal("Nov 7", JourneyQuestCategories.GetShortDate(Day(11, 7)))
            assert.are.equal("Feb 21", JourneyQuestCategories.GetShortDate(Day(2, 21)))
        end)

        it("should cut the month after three characters, not bytes, which some languages have several of each", function()
            CALENDAR_FULLDATE_MONTH_NAMES[11] = "ноябрь" -- Two bytes each
            assert.are.equal("ноя 7", JourneyQuestCategories.GetShortDate(Day(11, 7)))

            CALENDAR_FULLDATE_MONTH_NAMES[11] = "十一月" -- Three bytes each
            assert.are.equal("十一月 7", JourneyQuestCategories.GetShortDate(Day(11, 7)))
        end)
    end)

    describe("icons", function()
        it("should show what kind of quest it is, in the order of the map", function()
            repeatableQuests[WOLVES], repeatableQuests[KOBOLDS] = true, true
            pvpQuests[KOBOLDS], pvpQuests[ORDINARY_QUEST] = true, true
            activeEventQuests[ORDINARY_QUEST] = true

            assert.are_same({"repeatable", "pvpquest", "eventquest", "available"}, {
                JourneyQuestCategories.GetKindIcon(WOLVES), JourneyQuestCategories.GetKindIcon(KOBOLDS),
                JourneyQuestCategories.GetKindIcon(ORDINARY_QUEST), JourneyQuestCategories.GetKindIcon(FOLLOW_UP),
            })
        end)

        it("should show a repeatable quest that is only handed in like one that is ready for it", function()
            repeatableQuests[ORDINARY_QUEST] = true -- It has nothing to do

            assert.are.equal("repeatable_complete", JourneyQuestCategories.GetKindIcon(ORDINARY_QUEST))
        end)

        it("should show the rune of a Season of Discovery quest before anything else", function()
            Questie.IsSoD = true
            QuestieDB.IsSoDRuneQuest = function(questId) return questId == WOLVES end
            pvpQuests[WOLVES] = true

            assert.are.equal("sod_rune", JourneyQuestCategories.GetKindIcon(WOLVES))
        end)

        it("should show the kind of a quest that is too low level darker, but not where it starts", function()
            pvpQuests[WOLVES] = true
            levels[WOLVES] = 3

            local icon = JourneyQuestCategories.GetKindIcon(WOLVES)

            assert.are.equal("pvpquest", icon.name)
            assert.is_true(icon.brightness < 1)
            assert.are.equal("pvpquest", JourneyQuestCategories.GetStartIcon(WOLVES))
        end)

        it("should show the turn-in of a quest like the map", function()
            -- Also when its event isn't active
            eventQuests[WOLVES], pvpQuests[WOLVES] = true, true
            pvpQuests[KOBOLDS], repeatableQuests[KOBOLDS] = true, true
            repeatableQuests[ORDINARY_QUEST] = true

            assert.are_same({"eventquest_complete", "pvpquest_complete", "repeatable_complete", "complete"}, {
                JourneyQuestCategories.GetCompleteIcon(WOLVES), JourneyQuestCategories.GetCompleteIcon(KOBOLDS),
                JourneyQuestCategories.GetCompleteIcon(ORDINARY_QUEST), JourneyQuestCategories.GetCompleteIcon(FOLLOW_UP),
            })
        end)

        it("should show the crossed-out eye for a quest the player hid, whatever it is", function()
            Questie.db.char.hidden[WOLVES] = true

            for _, category in ipairs({"log", "available", "repeatable", "later", "completed", "unobtainable"}) do
                assert.are.equal(JourneyIcon.HIDDEN, JourneyQuestCategories.GetIcon(WOLVES, category), category)
            end
        end)

        it("should show whether a quest in the log is ready for its turn-in, or failed", function()
            pvpQuests[WOLVES] = true
            assert.are.equal("incomplete", JourneyQuestCategories.GetIcon(WOLVES, "log"))

            questLog[WOLVES] = 1
            assert.are.equal("pvpquest_complete", JourneyQuestCategories.GetIcon(WOLVES, "log"))

            questLog[WOLVES] = -1
            assert.are.equal("cross", JourneyQuestCategories.GetIcon(WOLVES, "log"))
        end)

        it("should show what kind of quest can be done, and what kind misses a requirement when it is a special one", function()
            pvpQuests[WOLVES] = true

            assert.are.equal("pvpquest", JourneyQuestCategories.GetIcon(WOLVES, "available"))
            assert.are.equal("pvpquest", JourneyQuestCategories.GetIcon(WOLVES, "later"))
            assert.are.equal("available", JourneyQuestCategories.GetIcon(KOBOLDS, "available"))
        end)

        it("should show a checkmark for a completed quest, and a cross for one that can't be done any more", function()
            assert.are.equal("checkmark", JourneyQuestCategories.GetIcon(WOLVES, "completed"))
            assert.are.equal("cross", JourneyQuestCategories.GetIcon(WOLVES, "unobtainable"))
        end)
    end)
end)
