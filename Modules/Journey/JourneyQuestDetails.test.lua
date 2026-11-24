dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("JourneyQuestDetails", function()
    ---@type JourneyQuestDetails
    local JourneyQuestDetails
    ---@type JourneyIcon
    local JourneyIcon
    local QuestieDB, QuestieCorrections
    local originalQuestie, originalUnitLevel, originalStrtrim
    local questFields, hidden, opened, isDoableShown

    before_each(function()
        originalQuestie, originalUnitLevel, originalStrtrim = _G.Questie, _G.UnitLevel, _G.strtrim
        _G.strtrim = function(text) return (text:gsub("^%s+", ""):gsub("%s+$", "")) end
        _G.UnitLevel = function() return 5 end
        hidden, opened, isDoableShown = {}, {}, false
        _G.Questie = {
            db = {char = {complete = {}, hidden = hidden}, profile = {}},
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
        QuestieDB.IsDoableVerbose = function(_, _, isVerbose, isForPlayer)
            assert(isVerbose and isForPlayer, "asked for something that can't be shown")
            return "Unavailable: Level too low", isDoableShown
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

        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyLinks.lua")
        dofile("Modules/Journey/ManualNotes.lua")
        dofile("Modules/Journey/QuestieSearch.lua")
        dofile("Modules/Journey/JourneyPrerequisites.lua")
        dofile("Modules/Journey/JourneyRawData.lua")
        dofile("Modules/Journey/JourneyEntityDetails.lua")
        dofile("Modules/Journey/JourneyQuestDetails.lua")
        JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
        JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
    end)

    after_each(function()
        _G.Questie, _G.UnitLevel, _G.strtrim = originalQuestie, originalUnitLevel, originalStrtrim
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
    ---@param title string
    ---@return string[]? texts What is in the box with the title
    local function Box(rows, title)
        local texts
        for _, row in ipairs(rows) do
            if row.type == "title" then
                texts = row.text == title and {} or texts
            elseif texts and row.isInBox then
                table.insert(texts, row.title and (row.title .. ", " .. row.text) or row.text)
                if row.isLastInBox then
                    return texts
                end
            end
        end
    end

    it("should show the name and the objective", function()
        local rows = GetRows()

        assert.are_same({"heading", "Infiltrating the Cult"}, {rows[1].type, rows[1].text})
        assert.are_same({"text", "Speak with Sania."}, {rows[2].type, rows[2].text})
    end)

    it("should show facts about the quest", function()
        questFields[93036].requiredRaces = 77
        questFields[93036].requiredClasses = 128

        local rows = GetRows()

        for _, fact in ipairs({"Quest ID: 93036", "Quest Level: 9", "Required Level: 5", "Required Faction: Alliance", "Required Class: Mage"}) do
            assert.is_not_nil(Find(rows, fact), fact)
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

            assert.is_not_nil(Find(GetRows(), "Required Profession: \n  Blacksmithing (Journeyman)\n  Not Mining (Apprentice)"))
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

    it("should show the reputation it rewards", function()
        local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
        QuestieReputation.GetReputationReward = function(id) return id == 93036 and {{72, 50}} or nil end
        QuestieReputation.GetReputationRewardString = function(rewards) return "+" .. rewards[1][2] .. " Stormwind" end

        assert.is_not_nil(Find(GetRows(), "Reputation Reward: +50 Stormwind"))
    end)

    it("should show whether the quest is complete", function()
        assert.are.equal("cross", Find(GetRows(), "Complete: ").trailingIcon)

        Questie.db.char.complete[93036] = true

        assert.are.equal("checkmark", Find(GetRows(), "Complete: ").trailingIcon)
    end)

    describe("a hidden quest", function()
        it("should say so when Questie hides it, also when that is only on the map", function()
            assert.is_nil(Find(GetRows(), "Hidden by Questie: "))

            for _, reason in ipairs({true, "HIDE_ON_MAP"}) do
                QuestieCorrections.hiddenQuests[93036] = reason
                assert.are.equal(JourneyIcon.HIDDEN, Find(GetRows(), "Hidden by Questie: ").trailingIcon)
            end
        end)

        it("should not be said to be hidden by Questie when the user hid it", function()
            hidden[93036] = true

            assert.is_nil(Find(GetRows(), "Hidden by Questie: "))
        end)

        -- Questie doesn't hide it while it is in the quest log, and it may stop doing so
        it("should be able to be hidden by the user and shown again, also when Questie hides it", function()
            for _, isHiddenByQuestie in ipairs({false, true}) do
                QuestieCorrections.hiddenQuests[93036] = isHiddenByQuestie or nil
                local checkbox = Find(GetRows(), "Hide from map")
                assert.is_false(checkbox.get())

                checkbox.set()
                assert.is_true(checkbox.get())

                checkbox.set()
                assert.is_false(checkbox.get())
            end
        end)
    end)

    describe("related quests", function()
        it("should lead to a single prerequisite", function()
            local rows = GetRows({preQuestSingle = {92517}})

            assert.are_same({"Quest 92517"}, Box(rows, "Requires one of these quests to be finished"))
            Find(rows, "Quest 92517").onClick()
            assert.are_same({{"quest", 92517}}, opened)
        end)

        describe("of the other faction", function()
            local originalLibQuestieDB

            before_each(function()
                originalLibQuestieDB = _G.LibQuestieDB
                LoadQuestieDBMock()
                questFields[92517] = {requiredRaces = QuestieDB.raceKeys.ALL_HORDE}
                questFields[94568] = {requiredRaces = QuestieDB.raceKeys.ALL_ALLIANCE}
            end)

            after_each(function()
                _G.LibQuestieDB = originalLibQuestieDB
            end)

            it("should not be shown when only one of them is required", function()
                local rows = GetRows({requiredRaces = QuestieDB.raceKeys.ALL_HORDE, preQuestSingle = {92517, 94568}})

                assert.are_same({"Quest 92517"}, Box(rows, "Requires one of these quests to be finished"))
            end)

            it("should be shown when all of them are required", function()
                local rows = GetRows({requiredRaces = QuestieDB.raceKeys.ALL_HORDE, preQuestGroup = {-92517, 94568}})

                assert.are_same({"Quest 92517", "Quest 94568"}, Box(rows, "Requires all of these quests to be finished"))
            end)
        end)

        it("should lead to each grouped prerequisite, of which some have a negative ID", function()
            local rows = GetRows({preQuestGroup = {-92517, 94568}})

            assert.are_same({"Quest 92517", "Quest 94568"}, Box(rows, "Requires all of these quests to be finished"))
            Find(rows, "Quest 92517").onClick()
            Find(rows, "Quest 94568").onClick()
            assert.are_same({{"quest", 92517}, {"quest", 94568}}, opened)
        end)

        it("should show the whole chain", function()
            questFields[93036].nextQuestInChain = 10
            questFields[10] = {nextQuestInChain = 0, breadcrumbForQuestId = 11}
            questFields[11] = {nextQuestInChain = 0}

            assert.are_same({"Quest 10", "Quest 11"}, Box(GetRows(), "Next in chain"))
        end)

        it("should not follow a chain in circles", function()
            questFields[93036].nextQuestInChain = 10
            questFields[10] = {nextQuestInChain = 11}
            questFields[11] = {nextQuestInChain = 10}

            assert.are_same({"Quest 10", "Quest 11"}, Box(GetRows(), "Next in chain"))
        end)

        it("should end the chain at a hidden quest", function()
            questFields[93036].nextQuestInChain = 10
            questFields[10] = {nextQuestInChain = 11}
            QuestieCorrections.hiddenQuests[11] = true

            assert.are_same({"Quest 10"}, Box(GetRows(), "Next in chain"))
        end)

        it("should not show empty boxes", function()
            for _, row in ipairs(GetRows()) do
                assert.are_not.equal("title", row.type)
            end
        end)
    end)

    it("should show who starts and ends the quest, where they are, and their other quests", function()
        local rows = GetRows({Starts = {NPC = {197, 240}}, Finisher = {NPC = {240}}})

        assert.are_same({
            "Marshal McBride, NPC ID: 197",
            "|T137195:14|t Elwynn Forest   X: 48.92 || Y: 41.60",
            "This NPC Also Starts the following quests:",
            "Quest 7",
        }, Box(rows, "Quest Start NPC Information"))
        assert.are_same({
            "Marshal Dughan, NPC ID: 240",
            "|T137195:14|t Elwynn Forest   X: 42.10 || Y: 65.90",
            "This NPC Also Completes the following quests:",
            "Quest 8",
        }, Box(rows, "Quest Turn-in NPC Information"))
    end)

    it("should show objects and items that start the quest, and objects that end it", function()
        local rows = GetRows({Starts = {GameObject = {55}, Item = {725}}, Finisher = {GameObject = {55}}})

        assert.are_same({
            "Half-eaten body, Object ID: 55",
            "|T137195:14|t Elwynn Forest   X: 72.60 || Y: 60.30",
        }, Box(rows, "Quest Start Object Information"))
        assert.are_same({"Gnoll Paw, Item ID: 725"}, Box(rows, "Quest Start Item Information"))
        assert.are_same({
            "Half-eaten body, Object ID: 55",
            "|T137195:14|t Elwynn Forest   X: 72.60 || Y: 60.30",
            "This Object Also Completes the following quests:",
            "Quest 11",
        }, Box(rows, "Quest Turn-in Object Information"))
    end)

    it("should show everyone who ends the quest, but nobody who isn't in the database", function()
        assert.are_same({
            "Marshal Dughan, NPC ID: 240",
            "|T137195:14|t Elwynn Forest   X: 42.10 || Y: 65.90",
            "This NPC Also Completes the following quests:",
            "Quest 8",
            "Marshal McBride, NPC ID: 197",
            "|T137195:14|t Elwynn Forest   X: 48.92 || Y: 41.60",
            "This NPC Also Completes the following quests:",
            "Quest 9",
        }, Box(GetRows({Finisher = {NPC = {240, 404, 197}}}), "Quest Turn-in NPC Information"))
    end)

    it("should show every object that starts the quest", function()
        local GetObject = QuestieDB.GetObject
        QuestieDB.GetObject = function(self, id) return id == 56 and {id = 56, name = "Grave"} or GetObject(self, id) end

        assert.are_same({
            "Half-eaten body, Object ID: 55",
            "|T137195:14|t Elwynn Forest   X: 72.60 || Y: 60.30",
            "Grave, Object ID: 56",
        }, Box(GetRows({Starts = {GameObject = {55, 56}}}), "Quest Start Object Information"))
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

        Find(GetRows({Starts = {GameObject = {55}}}), "|T137195:14|t Elwynn Forest   X: 72.60 || Y: 60.30").onClick()

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
        assert.are_same({{"npc", 197}, {"object", 55}, {"item", 725}}, opened)
        assert.are_same({197, "none", "icon of 725"}, pictures)
    end)

    it("should show the tooltip of the item that starts it", function()
        local ui = dofile("cli/testData/options/FakeUI.lua").Install()
        for _, row in ipairs(GetRows({Starts = {Item = {725}}})) do
            if row.type == "entity" then row.showTooltip() end
        end
        local itemId = GameTooltip.itemId
        ui.Restore()

        assert.are.equal(725, itemId)
    end)

    it("should offer TomTom for who starts it", function()
        local originalTomTom, targets = _G.TomTom, {}
        _G.TomTom = {AddWaypoint = function() end}
        QuestieLoader:ImportModule("TrackerUtils").SetTomTomTarget = function(_, ...) table.insert(targets, {...}) end

        Find(GetRows({Starts = {NPC = {197}}}), "Set |cFF54e33bTomTom|r Target").onClick()
        _G.TomTom = originalTomTom

        assert.are_same({{"Marshal McBride", 12, 48.92, 41.6}}, targets)
    end)

    it("should not fail for NPCs, objects and items that aren't in the database", function()
        local rows = GetRows({Starts = {NPC = {404}, GameObject = {404}, Item = {404}}, Finisher = {NPC = {404}}})

        assert.is_nil(Box(rows, "Quest Start NPC Information"))
        assert.is_nil(Box(rows, "Quest Start Item Information"))
    end)

    for period, text in pairs({Daily = "Repeatable: Daily", Weekly = "Repeatable: Weekly", Monthly = "Repeatable: Monthly", none = "Repeatable"}) do
        it("should say how often the quest can be repeated: " .. period, function()
            QuestieDB.IsRepeatable = function() return true end
            for _, candidate in ipairs({"Daily", "Weekly", "Monthly"}) do
                QuestieDB["Is" .. candidate .. "Quest"] = function() return candidate == period end
            end

            assert.is_not_nil(Find(GetRows(), text))
        end)
    end

    it("should say why the quest isn't available, unless that is clear already", function()
        assert.is_nil(Find(GetRows(), "Doable: Unavailable: Level too low"))

        isDoableShown = true
        assert.is_not_nil(Find(GetRows(), "Doable: Unavailable: Level too low"))
    end)

    it("should show its raw data while debugging", function()
        Questie.db.profile.debugEnabled = true
        Questie.Debug = function() end
        QuestieDB.questKeys = {name = 1}

        assert.is_not_nil(Find(GetRows(), "name: Infiltrating the Cult"))
    end)
end)
