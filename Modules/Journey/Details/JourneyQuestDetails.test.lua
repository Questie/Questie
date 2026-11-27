dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("JourneyQuestDetails", function()
    ---@type JourneyQuestDetails
    local JourneyQuestDetails
    ---@type JourneyIcon
    local JourneyIcon
    local QuestieDB, QuestieCorrections
    local originalQuestie, originalUnitLevel, originalStrtrim
    -- Blizzard's texts, in English
    local GLOBAL_STRINGS = {
        COMBAT_XP_GAIN = "Experience", ITEM_MIN_LEVEL = "Requires Level %d", QUEST_TOOLTIP_ACTIVE = "You are on this quest",
        QUEST_WATCH_QUEST_READY = "Ready for turn-in", REWARDS = "Rewards",
    }
    local originalStrings, originalLibQuestieDB = {}, nil
    local questFields, hidden, opened
    ---@type table<QuestId, {category: JourneyQuestCategory, reason: string?, stateName: string?}> What the quests are
    local categories

    before_each(function()
        originalQuestie, originalUnitLevel, originalStrtrim = _G.Questie, _G.UnitLevel, _G.strtrim
        originalLibQuestieDB = _G.LibQuestieDB
        LoadQuestieDBMock()
        for name, text in pairs(GLOBAL_STRINGS) do
            originalStrings[name] = _G[name]
            _G[name] = text
        end
        _G.strtrim = function(text) return (text:gsub("^%s+", ""):gsub("%s+$", "")) end
        _G.UnitLevel = function() return 5 end
        hidden, opened = {}, {}
        _G.Questie = {
            db = {char = {complete = {}, hidden = hidden, journey = {}}, profile = {}},
            icons = {checkmark = "checkmark", cross = "cross"},
            Colorize = function(_, text) return text end,
        }

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieDB.raceKeys = {ALL_ALLIANCE = 77, ALL_HORDE = 178}
        QuestieDB.QuestPointers = {}
        for id = 1, 100 do QuestieDB.QuestPointers[id] = true end
        for _, id in ipairs({92517, 94568, 93036}) do QuestieDB.QuestPointers[id] = true end
        questFields = {[93036] = {requiredLevel = 5, questLevel = 8}}
        QuestieDB.QueryQuestSingle = function(id, field) return questFields[id] and questFields[id][field] end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsDailyQuest = function() return false end
        QuestieDB.IsWeeklyQuest = function() return false end
        QuestieDB.IsDungeonQuest = function() return false end
        QuestieDB.IsRaidQuest = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieDB.IsComplete = function() return 0 end
        QuestieLoader:ImportModule("QuestXP").GetQuestLogRewardXP = function() return 0 end
        QuestieDB.IsDoableVerbose = function(_, _, isVerbose, isForPlayer)
            assert(isVerbose and isForPlayer, "asked for something that can't be shown")
            return "Unavailable: Level too low"
        end
        local npcs = {
            [197] = {id = 197, name = "Marshal McBride", spawns = {[12] = {{48.92, 41.6}}}, questStarts = {93036, 7}, questEnds = {9}},
            [240] = {id = 240, name = "Marshal Dughan", spawns = {[12] = {{42.1, 65.9}}}, questStarts = {10}, questEnds = {93036, 8}},
        }
        QuestieDB.GetNPC = function(_, id) return npcs[id] end
        QuestieDB.GetObject = function(_, id)
            return id == 55 and {id = 55, name = "Half-eaten body", spawns = {[12] = {{72.6, 60.3}}}, questEnds = {11}} or nil
        end
        QuestieDB.GetItem = function(_, id) return id == 725 and {Id = 725, name = "Gnoll Paw"} or nil end
        QuestieLoader:ImportModule("QuestieReputation").GetReputationReward = function() end
        QuestieLoader:ImportModule("QuestieCompat").GetItemIcon = function(id) return "icon of " .. id end

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetEffectiveQuestLevel = function() return 9 end
        QuestieLib.GetRaceString = function(_, races) return ({[77] = "Alliance", [178] = "Horde", [1] = "Human"})[races] or "" end
        QuestieLib.GetClassString = function(_, classes) return classes and "Mage" or "" end
        QuestieLib.GetColoredQuestName = function(_, id) return "Quest " .. id end
        QuestieLoader:ImportModule("QuestieJourneyUtils").CreateObjectiveText = function(description) return description[1] .. "\n" end
        QuestieLoader:ImportModule("QuestieJourneyUtils").GetZoneName = function() return "Elwynn Forest" end
        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeonLocation = function() end
        ZoneDB.GetUiMapIdByAreaId = function() return 1429 end
        local Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Era, Expansions.Tbc, Expansions.Current = 1, 2, 1
        local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        QuestieProfessions.GetProfessionName = function(_, id) return ({[164] = "Blacksmithing", [186] = "Mining"})[id] end
        QuestieProfessions.GetSpecializationName = function(_, id) return id == 9787 and "Weaponsmithing" or nil end
        QuestieProfessions.GetRankName = function(_, rank) return ({"Apprentice", "Journeyman"})[rank] end
        local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.HideQuest = function(_, id) hidden[id] = true end
        QuestieQuest.UnhideQuest = function(_, id) hidden[id] = nil end
        QuestieLoader:ImportModule("JourneyWindow").MAP_ICON = 137195
        QuestieLoader:ImportModule("JourneyWindow").OpenLink = function(kind, id) table.insert(opened, {kind, id}) end

        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Details/JourneyDetails.lua")
        dofile("Modules/Journey/Details/JourneyLinks.lua")
        dofile("Modules/Journey/Details/ManualNotes.lua")
        dofile("Modules/Journey/Data/QuestieSearch.lua")
        dofile("Modules/Journey/Data/JourneyPrerequisites.lua")
        dofile("Modules/Journey/Details/JourneyRawData.lua")
        -- The colors of names are tested with JourneyNameColors
        local JourneyNameColors = QuestieLoader:ImportModule("JourneyNameColors")
        JourneyNameColors.Npc = function(_, name) return name end
        JourneyNameColors.Object = function(name) return name end
        JourneyNameColors.Item = function(_, name) return name end
        -- What the quests are, and their icons, are tested with JourneyQuestCategories
        categories = {}
        local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyQuestCategories.Get = function(id)
            local quest = categories[id] or {category = "later", reason = "Level 5", stateName = "LEVEL_TOO_LOW"}
            return quest.category, quest.reason, quest.stateName
        end
        JourneyQuestCategories.GetIcon = function(_, category) return "icon of " .. category end
        JourneyQuestCategories.GetKindIcon = function() return "available" end
        JourneyQuestCategories.GetStartIcon = function() return "available" end
        JourneyQuestCategories.GetCompleteIcon = function() return "complete" end
        JourneyQuestCategories.GetProgress = function() return "1/2" end
        JourneyQuestCategories.GetShortDate = function() return "Nov 27" end
        dofile("Modules/Journey/Details/JourneyEntityDetails.lua")
        dofile("Modules/Journey/Details/JourneyQuestDetails.lua")
        JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
        JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
    end)

    after_each(function()
        _G.Questie, _G.UnitLevel, _G.strtrim = originalQuestie, originalUnitLevel, originalStrtrim
        _G.LibQuestieDB = originalLibQuestieDB
        for name in pairs(GLOBAL_STRINGS) do
            _G[name] = originalStrings[name]
        end
    end)

    ---@param fields table?
    ---@return JourneyDetails.Row[]
    local function GetRows(fields)
        local quest = {Id = 93036, name = "Infiltrating the Cult", Description = {"Speak with Sania."}}
        for key, value in pairs(fields or {}) do
            quest[key] = value
        end
        return JourneyQuestDetails.GetRows(quest)
    end

    ---@param rows JourneyDetails.Row[]
    ---@param text string The exact text
    ---@return JourneyDetails.Row?
    local function Find(rows, text)
        for _, row in ipairs(rows) do
            if row.text == text then
                return row
            end
        end
    end

    ---@param rows JourneyDetails.Row[]
    ---@param caption string Without what follows it, like the count of a chain
    ---@return string[]? texts Of the rows under the caption, an entity's as "title, text". Nil without the caption.
    local function Section(rows, caption)
        local texts
        for _, row in ipairs(rows) do
            if row.type == "caption" or row.type == "footer" then
                if texts then
                    return texts
                end
                texts = row.type == "caption" and (row.text:match("^(.-)   ") or row.text) == caption and {} or nil
            elseif texts then
                table.insert(texts, row.title and (row.title .. ", " .. row.text) or row.text)
            end
        end
        return texts
    end

    ---@param rows JourneyDetails.Row[]
    ---@return string status Without its icon
    local function Status(rows)
        for _, row in ipairs(rows) do
            if row.type == "status" then
                return (row.text:gsub("|T.-|t ", ""))
            end
        end
    end

    ---@param rows JourneyDetails.Row[]
    ---@return table<string, JourneyDetails.Row> rows Of the entities, by title
    local function Entities(rows)
        local entities = {}
        for _, row in ipairs(rows) do
            if row.type == "entity" then
                entities[row.title] = row
            end
        end
        return entities
    end

    it("should show the name, and the objective under the status", function()
        local rows = GetRows()

        assert.are_same({"page", "Quest 93036"}, {rows[1].type, rows[1].text})
        assert.are.equal("text", Find(rows, "Speak with Sania.").type)
    end)

    describe("the status", function()
        for situation, expected in pairs({
            ["in the quest log"] = {category = "log", text = "You are on this quest"},
            ["ready to turn in"] = {category = "log", isComplete = 1, text = "Ready for turn-in"},
            ["failed"] = {category = "log", isComplete = -1, text = "Failed"},
            ["available"] = {category = "available", text = "Available"},
            ["repeatable"] = {category = "repeatable", text = "Available"},
            ["completed"] = {category = "completed", text = "Completed"},
            ["too high a level"] = {category = "later", stateName = "LEVEL_TOO_LOW", text = "Unavailable: Requires Level 5"},
            ["after another quest"] = {category = "later", stateName = "NO_PREQUESTSINGLE", text = "Unavailable: Incomplete pre-quest"},
            ["after other quests"] = {category = "later", stateName = "NO_PREQUESTGROUP", text = "Unavailable: Incomplete pre-quest group"},
            ["for another reason"] = {category = "later", reason = "Requires Honored with Stormwind", text = "Unavailable: Requires Honored with Stormwind"},
            ["unobtainable"] = {category = "unobtainable", text = "Unavailable: Exclusive quest completed"},
            -- Then why the game says it can't be done
            ["not listed"] = {text = "Unavailable: Level too low"},
        }) do
            it("should say what the player can do with a quest that is " .. situation, function()
                categories[93036] = {category = expected.category, reason = expected.reason, stateName = expected.stateName}
                QuestieDB.IsComplete = function() return expected.isComplete or 0 end

                assert.are.equal(expected.text, Status(GetRows()))
                -- The same where a link to the quest shows it
                assert.are.equal(expected.text, (JourneyQuestDetails.GetStatus(93036):gsub("|T.-|t ", "")))
            end)
        end
    end)

    describe("a quest that can't be done yet", function()
        before_each(function()
            questFields[93036].preQuestSingle = {92517}
            questFields[92517] = {preQuestSingle = {94568}}
        end)

        it("should say which one of its chain to start with", function()
            Questie.db.char.complete[94568] = true

            local step = Find(GetRows(), "Quest 92517")

            assert.are.equal("start with this one", step.tag)
        end)

        it("should not say where to start when it can be done", function()
            categories[93036] = {category = "available"}

            for _, row in ipairs(GetRows()) do
                assert.are_not.equal("start with this one", row.tag)
            end
        end)
    end)

    it("should show facts about the quest", function()
        questFields[93036].requiredRaces = 77
        questFields[93036].requiredClasses = 128

        local facts = Section(GetRows(), "Quest Information")

        for _, fact in ipairs({"Level: 9   Required Level: 5", "Required Faction: Alliance", "Required Class: Mage", "Quest ID: 93036"}) do
            assert.is_truthy(tContains(facts, fact), fact)
        end
    end)

    it("should tell a faction from a single race", function()
        questFields[93036].requiredRaces = 1
        assert.is_not_nil(Find(GetRows(), "Required Race: Human"))

        questFields[93036].requiredRaces = 178
        assert.is_not_nil(Find(GetRows(), "Required Faction: Horde"))
    end)

    describe("the required professions", function()
        it("should be shown with the skill that is needed", function()
            questFields[93036].requiredSkill = {164, 210}

            assert.is_not_nil(Find(GetRows(), "Required Profession: Blacksmithing (210)"))
        end)

        it("should be shown without a skill of 0", function()
            questFields[93036].requiredSkill = {164, 0}

            assert.is_not_nil(Find(GetRows(), "Required Profession: Blacksmithing"))
        end)

        it("should be the specialization when there is one", function()
            questFields[93036].requiredSkill = {164, 210}
            questFields[93036].requiredSpecialization = 9787

            assert.is_not_nil(Find(GetRows(), "Required Profession: Weaponsmithing (210)"))
        end)

        it("should be listed when there are several, also those that aren't allowed", function()
            questFields[93036].requiredRanks = {{164, 2}, {186, -1}}

            assert.is_not_nil(Find(GetRows(), "Required Profession: Blacksmithing (Journeyman), Not Mining (Apprentice)"))
        end)
    end)

    describe("the difficulty", function()
        ---@return string
        local function Difficulty(questLevel, requiredLevel)
            questFields[93036].questLevel, questFields[93036].requiredLevel = questLevel, requiredLevel
            for _, row in ipairs(GetRows()) do
                if row.text and row.text:find("Difficulty Range", 1, true) then
                    return (row.text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
                end
            end
        end

        -- Worked out by hand: red from the required level on, orange 4 below the level of the quest, yellow 2 below, green
        -- 3 above, and gray 11 above at level 55 and 6 above at level 12. Never below the required level.
        it("should be the levels at which the color of the quest changes", function()
            assert.are.equal("Difficulty Range: [45] [51] [53] [58] [66] ", Difficulty(55, 45))
            assert.are.equal("Difficulty Range: [10] [15] [18] ", Difficulty(12, 10))
        end)

        it("should be the range of levels for a quest that has the level of the player", function()
            assert.are.equal("Difficulty Range: [1-5] ", Difficulty(-1, 1))
            assert.are.equal("Difficulty Range: [10] ", Difficulty(-1, 10))
        end)

        it("should be different on later expansions, where quests get gray earlier", function()
            QuestieLoader:ImportModule("Expansions").Current = 2

            assert.are.equal("Difficulty Range: [45] [51] [53] [58] [64] ", Difficulty(55, 45))
        end)
    end)

    it("should show the experience and the reputation it rewards", function()
        QuestieLoader:ImportModule("QuestXP").GetQuestLogRewardXP = function(_, id) return id == 93036 and 1250 or 0 end
        _G.BreakUpLargeNumbers = function(number) return number == 1250 and "1,250" or tostring(number) end
        local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
        QuestieReputation.GetReputationReward = function(id) return id == 93036 and {{72, 50}} or nil end
        QuestieReputation.GetReputationRewardString = function(rewards) return "+" .. rewards[1][2] .. " Stormwind" end

        local rewards = Section(GetRows(), "Rewards")
        _G.BreakUpLargeNumbers = nil

        assert.are_same({"Experience: 1,250", "Reputation Reward: +50 Stormwind"}, rewards)
    end)

    describe("a hidden quest", function()
        it("should say so when Questie hides it, also when that is only on the map", function()
            assert.is_nil(Find(GetRows(), "Hidden by Questie "))

            for _, reason in ipairs({true, "HIDE_ON_MAP"}) do
                QuestieCorrections.hiddenQuests[93036] = reason
                assert.are.equal(JourneyIcon.HIDDEN, Find(GetRows(), "Hidden by Questie ").trailingIcon)
            end
        end)

        it("should say that the user hid it, rather than Questie", function()
            QuestieCorrections.hiddenQuests[93036] = true
            hidden[93036] = true

            local rows = GetRows()

            assert.is_nil(Find(rows, "Hidden by Questie "))
            assert.are.equal(JourneyIcon.HIDDEN, Find(rows, "You hid it from the map ").trailingIcon)
        end)

        -- Questie doesn't hide it while it is in the quest log, and it may stop doing so
        it("should be able to be hidden by the user and shown again, also when Questie hides it", function()
            for _, isHiddenByQuestie in ipairs({false, true}) do
                QuestieCorrections.hiddenQuests[93036] = isHiddenByQuestie or nil
                local button = GetRows()[#GetRows()].buttons[1]
                assert.are.equal("Hide from map", button.text)

                button.onClick()
                assert.is_true(hidden[93036])
                button = GetRows()[#GetRows()].buttons[1]
                assert.are.equal("Show on map again", button.text)

                button.onClick()
                assert.is_nil(hidden[93036])
            end
        end)
    end)

    describe("related quests", function()
        it("should lead to the quest before it in its chain", function()
            questFields[93036].preQuestSingle = {92517}
            local rows = GetRows()

            assert.are_same({"Quest 92517", "Quest 93036"}, Section(rows, "Chain"))
            Find(rows, "Quest 92517").onClick()
            assert.are_same({{"quest", 92517}}, opened)
        end)

        it("should leave the other faction's quest out of the chain, when only one of them is required", function()
            questFields[92517] = {requiredRaces = QuestieDB.raceKeys.ALL_HORDE}
            questFields[94568] = {requiredRaces = QuestieDB.raceKeys.ALL_ALLIANCE}
            questFields[93036].requiredRaces = QuestieDB.raceKeys.ALL_HORDE
            questFields[93036].preQuestSingle = {92517, 94568}

            assert.are_same({"Quest 92517", "Quest 93036"}, Section(GetRows(), "Chain"))
        end)

        it("should lead to each grouped prerequisite, of which some have a negative ID", function()
            local rows = GetRows({preQuestGroup = {-92517, 94568}})

            assert.are_same({"Quest 92517", "Quest 94568"}, Section(rows, "Requires all of these quests to be finished"))
            Find(rows, "Quest 92517").onClick()
            Find(rows, "Quest 94568").onClick()
            assert.are_same({{"quest", 92517}, {"quest", 94568}}, opened)
        end)

        it("should show the whole chain, also a breadcrumb after it", function()
            questFields[93036].nextQuestInChain = 10
            questFields[10] = {nextQuestInChain = 0, breadcrumbForQuestId = 11}
            questFields[11] = {nextQuestInChain = 0}

            assert.are_same({"Quest 93036", "Quest 10", "Quest 11"}, Section(GetRows(), "Chain"))
        end)

        it("should not follow a chain in circles", function()
            questFields[93036].nextQuestInChain = 10
            questFields[10] = {nextQuestInChain = 11}
            questFields[11] = {nextQuestInChain = 10}

            assert.are_same({"Quest 93036", "Quest 10", "Quest 11"}, Section(GetRows(), "Chain"))
        end)

        it("should end the chain at a hidden quest", function()
            questFields[93036].nextQuestInChain = 10
            questFields[10] = {nextQuestInChain = 11}
            QuestieCorrections.hiddenQuests[11] = true

            assert.are_same({"Quest 93036", "Quest 10"}, Section(GetRows(), "Chain"))
        end)

        it("should not show a caption without anything under it", function()
            local rows = GetRows()

            for index, row in ipairs(rows) do
                if row.type == "caption" then
                    assert.is_truthy(rows[index + 1].type ~= "caption" and rows[index + 1].type ~= "footer", row.text)
                end
            end
            assert.is_nil(Section(rows, "Chain"))
            assert.is_nil(Section(rows, "Requires all of these quests to be finished"))
        end)
    end)

    it("should show who starts and ends the quest, where they are, and their other available quests", function()
        categories[7] = {category = "available"}

        local rows = GetRows({Starts = {NPC = {197, 240}}, Finisher = {NPC = {240}}})

        assert.are_same({
            "Marshal McBride, Starts this quest\nElwynn Forest  48.9, 41.6",
            "Also available there",
            "Quest 7",
            "Marshal Dughan, Starts and ends this quest\nElwynn Forest  42.1, 65.9",
        }, Section(rows, "Where"))
    end)

    it("should show objects and items that start the quest, and objects that end it", function()
        local rows = GetRows({Starts = {GameObject = {55}, Item = {725}}, Finisher = {GameObject = {55}}})

        assert.are_same({
            "Gnoll Paw, Starts this quest",
            "Half-eaten body, Starts and ends this quest\nElwynn Forest  72.6, 60.3",
        }, Section(rows, "Where"))
    end)

    it("should show everyone who ends the quest, but nobody who isn't in the database", function()
        assert.are_same({
            "Marshal Dughan, Ends this quest\nElwynn Forest  42.1, 65.9",
            "Marshal McBride, Ends this quest\nElwynn Forest  48.9, 41.6",
        }, Section(GetRows({Finisher = {NPC = {240, 404, 197}}}), "Where"))
    end)

    it("should show every object that starts the quest, also one without a place", function()
        local GetObject = QuestieDB.GetObject
        QuestieDB.GetObject = function(self, id) return id == 56 and {id = 56, name = "Grave"} or GetObject(self, id) end

        assert.are_same({
            "Half-eaten body, Starts this quest\nElwynn Forest  72.6, 60.3",
            "Grave, Starts this quest",
        }, Section(GetRows({Starts = {GameObject = {55, 56}}}), "Where"))
    end)

    it("should open the map at an object, and not at the NPC with the same ID", function()
        local shown, QuestieMap = {}, QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.manualFrames = {}
        QuestieMap.ShowNPC = function(_, id) table.insert(shown, "npc " .. id) end
        QuestieMap.ShowObject = function(_, id) table.insert(shown, "object " .. id) end
        QuestieLoader:ImportModule("QuestieCompat").OpenWorldMap = function(uiMapId)
            table.insert(shown, "map " .. uiMapId)
            return true
        end
        QuestieLoader:ImportModule("JourneyWindow").Hide = function() end

        Entities(GetRows({Starts = {GameObject = {55}}}))["Half-eaten body"].action.onClick()

        assert.are_same({"object 55", "map 1429"}, shown)
    end)

    it("should lead to the NPCs, objects and items, and show what they look like", function()
        local rows = GetRows({Starts = {NPC = {197}, GameObject = {55}, Item = {725}}})

        local pictures = {}
        for _, row in ipairs(rows) do
            if row.type == "entity" then
                row.onClick()
                table.insert(pictures, row.npcId or row.icon or "none")
            end
        end
        assert.are_same({{"item", 725}, {"npc", 197}, {"object", 55}}, opened)
        assert.are_same({"icon of 725", 197, "none"}, pictures)
    end)

    it("should show the tooltip of the item that starts it", function()
        local ui = dofile("cli/testData/options/FakeUI.lua").Install()
        Entities(GetRows({Starts = {Item = {725}}}))["Gnoll Paw"].showTooltip()
        local itemId = GameTooltip.itemId
        ui.Restore()

        assert.are.equal(725, itemId)
    end)

    it("should offer TomTom for where to go", function()
        local originalTomTom, targets = _G.TomTom, {}
        _G.TomTom = {AddWaypoint = function() end}
        QuestieLoader:ImportModule("TrackerUtils").SetTomTomTarget = function(_, ...) table.insert(targets, {...}) end

        local rows = GetRows({Starts = {NPC = {197}}})
        rows[#rows].buttons[2].onClick()
        _G.TomTom = originalTomTom

        assert.are_same({{"Marshal McBride", 12, 48.92, 41.6}}, targets)
    end)

    it("should lead to whoever ends a quest that is in the quest log", function()
        local originalTomTom, targets = _G.TomTom, {}
        _G.TomTom = {AddWaypoint = function() end}
        QuestieLoader:ImportModule("TrackerUtils").SetTomTomTarget = function(_, name) table.insert(targets, name) end
        categories[93036] = {category = "log"}

        local rows = GetRows({Starts = {NPC = {197}}, Finisher = {NPC = {240}}})
        rows[#rows].buttons[2].onClick()
        _G.TomTom = originalTomTom

        assert.are_same({"Marshal Dughan"}, targets)
    end)

    it("should not fail for NPCs, objects and items that aren't in the database", function()
        local rows = GetRows({Starts = {NPC = {404}, GameObject = {404}, Item = {404}}, Finisher = {NPC = {404}}})

        assert.is_nil(Section(rows, "Where"))
    end)

    for period, tag in pairs({Daily = "Daily", Weekly = "Weekly", Monthly = "Repeatable", none = "Repeatable"}) do
        it("should say how often the quest can be repeated: " .. period, function()
            QuestieDB.IsRepeatable = function() return true end
            for _, candidate in ipairs({"Daily", "Weekly", "Monthly"}) do
                QuestieDB["Is" .. candidate .. "Quest"] = function() return candidate == period end
            end

            assert.are.equal(tag, GetRows()[1].tag)
        end)
    end

    it("should say that it is a dungeon, raid or PvP quest, after how often it can be repeated", function()
        QuestieDB.IsDailyQuest = function() return true end
        QuestieDB.IsDungeonQuest = function() return true end
        QuestieDB.IsPvPQuest = function() return true end

        assert.are.equal("Daily, Dungeon, PvP", GetRows()[1].tag)
    end)

    describe("the objectives", function()
        before_each(function()
            QuestieDB.QueryNPCSingle = function(id, field) return id == 197 and field == "name" and "Marshal McBride" or nil end
            QuestieDB.QueryItemSingle = function(id, field) return id == 725 and field == "name" and "Gnoll Paw" or nil end
            QuestieDB.QueryObjectSingle = function() return nil end
            QuestieLoader:ImportModule("QuestieMap").manualFrames = {}
        end)

        local OBJECTIVES = {{Type = "monster", Id = 197}, {Type = "item", Id = 725}, {Type = "object", Id = 404}}

        it("should lead to what is to be killed or collected, and leave out what isn't in the database", function()
            local rows = GetRows({ObjectiveData = OBJECTIVES})

            Find(rows, "Marshal McBride").onClick()
            Find(rows, "Gnoll Paw").onClick()
            assert.are_same({{"npc", 197}, {"item", 725}}, opened)
        end)

        it("should show how far the player is while the quest is in the log", function()
            categories[93036] = {category = "log"}

            local rows = GetRows({ObjectiveData = OBJECTIVES, Objectives = {{Collected = 3, Needed = 8}, {Collected = 0, Needed = 1}}})

            assert.are.equal("3/8", Find(rows, "Marshal McBride").tag)
            assert.are.equal("0/1", Find(rows, "Gnoll Paw").tag)
        end)
    end)

    it("should show the history of the quest, and only of this quest", function()
        Questie.db.char.journey = {
            {Event = "Quest", SubType = "Accept", Quest = 93036, Level = 5, Timestamp = 0},
            {Event = "Quest", SubType = "Accept", Quest = 1, Level = 5, Timestamp = 0},
            {Event = "Level", NewLevel = 6, Timestamp = 0},
            {Event = "Quest", SubType = "Complete", Quest = 93036, Timestamp = 0},
        }

        assert.are_same({"Accepted   Level 5", "Completed"}, Section(GetRows(), "Your history"))
    end)

    it("should show its raw data while debugging", function()
        Questie.db.profile.debugEnabled = true
        Questie.Debug = function() end
        QuestieDB.questKeys = {name = 1}

        assert.is_not_nil(Find(GetRows(), "name: Infiltrating the Cult"))
    end)
end)
