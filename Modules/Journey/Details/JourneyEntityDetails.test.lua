dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyEntityDetails", function()
    ---@type JourneyEntityDetails
    local JourneyEntityDetails
    local ui
    local originalQuestie, originalTomTom, originalReady
    local QuestieDB
    local npcs, categories, completion
    local notes, openedMaps, canOpenMap, windowHidden, changes, tomTomTargets, openedLinks

    local ELWYNN, WESTFALL, STORMWIND, DEADMINES, ZONE_WITHOUT_MAP = 12, 40, 1519, 1581, 9999
    local GOLD_DRAGON = "|A:nameplates-icon-elite-gold:14:14:0:0|a"

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalTomTom = _G.Questie, _G.TomTom
        originalReady = _G.QUEST_WATCH_QUEST_READY
        _G.Questie = {
            db = {profile = {}},
            icons = {complete = "complete", available = "available", incomplete = "incomplete", object = "object"},
            Colorize = function(_, text) return text end,
            Print = function() end,
            Debug = function() end,
        }
        _G.TomTom = nil
        _G.QUEST_WATCH_QUEST_READY = "Ready for turn-in"
        notes, openedMaps, canOpenMap, windowHidden, changes, tomTomTargets, openedLinks = {}, {}, true, false, 0, {}, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        -- Health is no longer in the database, which gives these instead
        npcs = {
            [299] = {
                id = 299, name = "Young Wolf", minLevel = 1, maxLevel = 2, minLevelHealth = 0, maxLevelHealth = 1, rank = 0,
                friendlyToFaction = "H", spawns = {[ELWYNN] = {{48.92, 41.6}}}, questStarts = {7}, questEnds = {8},
            },
            [448] = {
                id = 448, name = "Hogger", minLevel = 11, maxLevel = 11, minLevelHealth = 0, maxLevelHealth = 1, rank = 1,
                spawns = {[ELWYNN] = {{26.9, 86.9}, {25.1, 92.5}}},
            },
            [6740] = {
                id = 6740, name = "Innkeeper Allison", minLevel = 30, maxLevel = 30, minLevelHealth = 0, maxLevelHealth = 1, rank = 0,
                subName = "Innkeeper", friendlyToFaction = "A", spawns = {[STORMWIND] = {{52.62, 65.7}}},
            },
            [300] = {id = 300, name = "Boss", minLevel = 60, maxLevel = 60, minLevelHealth = 0, maxLevelHealth = 1, rank = 3},
        }
        local objects = {[55] = {id = 55, name = "Half-eaten body", spawns = {[ELWYNN] = {{72.6, 60.3}}}}}
        QuestieDB.GetNPC = function(_, id) return npcs[id] end
        QuestieDB.GetObject = function(_, id) return objects[id] end
        -- How far the quests in the log are, by quest
        completion = {}

        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLoader:ImportModule("QuestieLib").GetColoredQuestName = function(_, id) return "Quest " .. id end

        local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.manualFrames = {any = notes}
        QuestieMap.ShowNPC = function(_, id) notes[id] = {} end
        QuestieMap.ShowObject = function(_, id) notes[-id] = {} end
        QuestieMap.UnloadManualFrames = function(_, id) notes[id] = nil end
        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeonLocation = function() end
        ZoneDB.GetUiMapIdByAreaId = function(_, zoneId) return zoneId ~= ZONE_WITHOUT_MAP and 1000 + zoneId or nil end
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.OpenWorldMap = function(uiMapId)
            table.insert(openedMaps, uiMapId)
            return canOpenMap
        end
        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.zoneLookup = {[0] = {
            [ELWYNN] = "Elwynn Forest", [WESTFALL] = "Westfall", [STORMWIND] = "Stormwind City", [ZONE_WITHOUT_MAP] = "Nowhere",
        }}
        l10n.zoneCategoryLookup = {[9] = {[DEADMINES] = "The Deadmines"}}
        QuestieLoader:ImportModule("TrackerUtils").SetTomTomTarget = function(_, ...) table.insert(tomTomTargets, {...}) end
        local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
        JourneyWindow.Hide = function() windowHidden = true end
        JourneyWindow.OpenLink = function(kind, id) table.insert(openedLinks, {kind, id}) end

        dofile("Modules/Journey/Data/JourneyThread.lua")
        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Details/JourneyDetails.lua")
        dofile("Modules/Journey/Details/JourneyLinks.lua")
        dofile("Modules/Journey/Details/ManualNotes.lua")
        dofile("Modules/Journey/Details/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/Data/QuestieSearch.lua")
        dofile("Modules/Journey/Details/JourneyRawData.lua")
        -- The colors of names are tested with JourneyNameColors
        local JourneyNameColors = QuestieLoader:ImportModule("JourneyNameColors")
        JourneyNameColors.Npc = function(_, name) return name end
        JourneyNameColors.Object = function(name) return name end
        -- Which quests are listed, in what order and with what note, and their icons, are tested with JourneyQuestCategories
        categories = {[7] = {"available", "100 xp"}, [8] = {"completed", "Nov 7"}}
        local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyQuestCategories.Arrange = function(questIds)
            local entries = {}
            for _, questId in ipairs(questIds) do
                if categories[questId] then
                    table.insert(entries, {questId = questId, category = categories[questId][1], note = categories[questId][2]})
                end
            end
            return entries
        end
        JourneyQuestCategories.GetIcon = function(_, category) return "icon of " .. category end
        JourneyQuestCategories.GetLogState = function(questId) return completion[questId] or "active" end
        dofile("Modules/Journey/Details/JourneyEntityDetails.lua")
        JourneyEntityDetails = QuestieLoader:ImportModule("JourneyEntityDetails")
    end)

    after_each(function()
        _G.Questie, _G.TomTom = originalQuestie, originalTomTom
        _G.QUEST_WATCH_QUEST_READY = originalReady
        ui.Restore()
    end)

    ---@param kind ManualNoteKind
    ---@param id number
    ---@return JourneyDetails.Row[]
    local function GetRows(kind, id)
        return JourneyEntityDetails.GetRows(kind, id, function() changes = changes + 1 end)
    end

    ---@param rows JourneyDetails.Row[]
    ---@return string[] texts One per row, starting with its type, and its tag if it has one
    local function Describe(rows)
        local texts = {}
        for index, row in ipairs(rows) do
            local text = row.text or row.buttons and row.buttons[1].text
            texts[index] = row.type .. ": " .. tostring(text) .. (row.tag and " | " .. row.tag or "")
        end
        return texts
    end

    ---@param rows JourneyDetails.Row[]
    ---@param text string A part of it
    ---@return JourneyDetails.Row?
    local function Find(rows, text)
        for _, row in ipairs(rows) do
            if row.text and row.text:find(text, 1, true) then
                return row
            end
        end
    end

    ---@param rows JourneyDetails.Row[]
    ---@param rowType string
    ---@return JourneyDetails.Row?
    local function FindType(rows, rowType)
        for _, row in ipairs(rows) do
            if row.type == rowType then return row end
        end
    end

    ---@param rows JourneyDetails.Row[]
    ---@param caption string
    ---@return JourneyDetails.Row[] steps Below the caption
    local function Section(rows, caption)
        local steps, isInSection = {}, false
        for _, row in ipairs(rows) do
            if row.type == "caption" then
                isInSection = row.text == caption
            elseif row.type ~= "step" then
                isInSection = false
            elseif isInSection then
                table.insert(steps, row)
            end
        end
        return steps
    end

    ---@param id number
    ---@return string text Of the card with its picture
    local function Card(id)
        return FindType(GetRows("npc", id), "entity").text
    end

    describe("of an NPC", function()
        it("should show what it is, where it is and its quests", function()
            local rows = GetRows("npc", 299)

            assert.are_same({
                "page: Young Wolf | NPC ID: 299",
                "gap: nil",
                "entity: Level: 1 - 2\nFriendly to: Horde\nElwynn Forest  48.9, 41.6",
                "gap: nil",
                "status: |Tavailable:14|t Available: 1",
                "caption: Starts the following quests",
                "step: Quest 7 | 100 xp",
                "caption: Ends the following quests",
                "step: Quest 8 | Nov 7",
                "footer: Show on Map",
            }, Describe(rows))
            assert.are.equal(299, rows[3].npcId)
        end)

        it("should show its title below its name and the dragon of its rank behind its level, like the game", function()
            assert.are.equal("<Innkeeper>\nLevel: 30\nFriendly to: Alliance\nStormwind City  52.6, 65.7", Card(6740))
            assert.are.equal("Level: 11 " .. GOLD_DRAGON .. "\nFriendly to: no faction\nElwynn Forest", Card(448))
        end)

        for faction, text in pairs({AH = "both factions", A = "Alliance", none = "no faction"}) do
            it("should say that it is friendly to " .. text, function()
                npcs[299].friendlyToFaction = faction ~= "none" and faction or nil

                assert.is_not_nil(Find(GetRows("npc", 299), "Friendly to: " .. text))
            end)
        end

        describe("status", function()
            ---@return string?
            local function Status()
                local status = FindType(GetRows("npc", 299), "status")
                return status and status.text
            end

            it("should say what the player can hand in, take and still has to do there", function()
                npcs[299].questStarts, npcs[299].questEnds = {7, 9, 10}, {11, 12, 13}
                categories = {
                    [7] = {"available"}, [9] = {"repeatable"}, [10] = {"later", "Level 5"},
                    [11] = {"log"}, [12] = {"log"}, [13] = {"log"},
                }
                completion = {[11] = "ready", [12] = "active", [13] = "failed"}

                assert.are.equal("|Tcomplete:14|t Ready for turn-in: 1     |Tavailable:14|t Available: 2     |Tincomplete:14|t Active: 1", Status())
            end)

            it("should only count the quests in the log that end there, and those that start there", function()
                npcs[299].questStarts, npcs[299].questEnds = {11}, {7}
                categories = {[7] = {"available"}, [11] = {"log"}}

                assert.is_nil(Status())
            end)

            it("should not be there when there is nothing to do there", function()
                categories = {[7] = {"completed"}, [8] = {"completed"}}

                assert.is_nil(Status())
            end)
        end)

        it("should list its quests like the list of quests does, each leading to it", function()
            npcs[299].questStarts = {7, 404, 9}
            categories[9] = {"later", "Level 5"}

            local starts = Section(GetRows("npc", 299), "Starts the following quests")

            assert.are_same({"step: Quest 7 | 100 xp", "step: Quest 9 | Level 5"}, Describe(starts))
            assert.are_same({"icon of available", "icon of later"}, {starts[1].trailingIcon, starts[2].trailingIcon})
            starts[2].onClick()
            assert.are_same({{"quest", 9}}, openedLinks)
        end)

        describe("place", function()
            it("should name its zone in the language of the client", function()
                QuestieLoader:ImportModule("l10n").translations["Elwynn Forest"] = {["deDE"] = "Wald von Elwynn"}
                QuestieLoader:ImportModule("l10n"):SetUILocale("deDE")

                assert.is_not_nil(Find(GetRows("npc", 299), "Wald von Elwynn"))
            end)

            it("should prefer a place with coordinates, also over one with more spawns, and lead TomTom there", function()
                npcs[299].spawns = {[DEADMINES] = {{-1, -1}, {-1, -1}}, [ELWYNN] = {{48.92, 41.6}}}
                _G.TomTom = {AddWaypoint = function() end}

                local rows = GetRows("npc", 299)
                FindType(rows, "footer").buttons[2].onClick()

                assert.are.equal("Level: 1 - 2\nFriendly to: Horde\nElwynn Forest", rows[3].text)
                assert.are_same({{"Young Wolf", ELWYNN, 48.92, 41.6}}, tomTomTargets)
            end)

            it("should only give coordinates where they lead to its only spawn, but lead TomTom to the first spawn anyway", function()
                npcs[299].spawns = {[ELWYNN] = {{48.92, 41.6}, {50, 50}}, [WESTFALL] = {{1, 1}}}
                _G.TomTom = {AddWaypoint = function() end}

                local rows = GetRows("npc", 299)
                FindType(rows, "footer").buttons[2].onClick()

                assert.are.equal("Level: 1 - 2\nFriendly to: Horde\nElwynn Forest", rows[3].text)
                assert.are_same({{"Young Wolf", ELWYNN, 48.92, 41.6}}, tomTomTargets)
            end)

            it("should name the zone with the most spawns, and list all zones with how many spawns each has", function()
                npcs[299].spawns = {[ELWYNN] = {{1, 1}}, [WESTFALL] = {{2, 2}, {3, 3}, {4, 4}}, [ZONE_WITHOUT_MAP] = {{5, 5}, {6, 6}}}

                local rows = GetRows("npc", 299)

                assert.are.equal("Level: 1 - 2\nFriendly to: Horde\nWestfall", rows[3].text)
                assert.are_same({"step: Westfall | 3", "step: Nowhere | 2", "step: Elwynn Forest"}, Describe(Section(rows, "Where")))
            end)

            it("should open the map of a zone it spawns in, unless there is none", function()
                npcs[299].spawns = {[ELWYNN] = {{1, 1}}, [ZONE_WITHOUT_MAP] = {{5, 5}, {6, 6}}}

                local where = Section(GetRows("npc", 299), "Where")
                assert.are_same({"Nowhere", "Elwynn Forest"}, {where[1].text, where[2].text})
                assert.is_nil(where[1].onClick)

                where[2].showTooltip()
                assert.are_same({"Show on Map"}, GameTooltip.lines)
                where[2].onClick()

                assert.are_same({1000 + ELWYNN}, openedMaps)
                assert.are_same({[299] = {}}, notes)
                assert.is_true(windowHidden)
                -- Also when the map can't be opened in combat, the page shows that it is on the map
                assert.are.equal(1, changes)
            end)

            it("should not list the zone when there is only one", function()
                npcs[299].spawns = {[ELWYNN] = {{1, 1}, {2, 2}}}

                assert.are_same({}, Section(GetRows("npc", 299), "Where"))
            end)

            it("should only name a zone that has no places", function()
                npcs[299].spawns = {[ELWYNN] = {}}

                assert.are.equal("Level: 1 - 2\nFriendly to: Horde\nElwynn Forest", Card(299))
            end)

            it("should only name the instance it is in, where it has no coordinates", function()
                npcs[299].spawns = {[DEADMINES] = {{-1, -1}}}

                assert.are.equal("Level: 1 - 2\nFriendly to: Horde\nThe Deadmines", Card(299))
            end)

            it("should not lead to a map that doesn't exist", function()
                npcs[299].spawns = {[ZONE_WITHOUT_MAP] = {{1, 2}}}

                local rows = GetRows("npc", 299)

                assert.is_not_nil(Find(rows, "Nowhere    1.0,   2.0"))
                assert.is_nil(rows[3].onShowMap)
            end)
        end)

        it("should open the map at its place, instead of the window that would cover it", function()
            GetRows("npc", 299)[3].onShowMap()

            assert.are_same({1000 + ELWYNN}, openedMaps)
            assert.are_same({[299] = {}}, notes)
            assert.is_true(windowHidden)
        end)

        it("should leave the window open when the map can't be opened, and show that it is on the map", function()
            canOpenMap = false

            GetRows("npc", 299)[3].onShowMap()

            assert.is_false(windowHidden)
            assert.are.equal(1, changes)
            assert.are.equal("Remove from Map", FindType(GetRows("npc", 299), "footer").buttons[1].text)
        end)

        it("should be put on the map without opening it, and removed again", function()
            FindType(GetRows("npc", 299), "footer").buttons[1].onClick()
            assert.are_same({[299] = {}}, notes)
            assert.is_false(windowHidden)

            local button = FindType(GetRows("npc", 299), "footer").buttons[1]
            assert.are.equal("Remove from Map", button.text)
            button.onClick()

            assert.are_same({}, notes)
            assert.are.equal(2, changes)
        end)

        it("should offer TomTom only with the addon, and only where there are coordinates", function()
            assert.are.equal(1, #FindType(GetRows("npc", 299), "footer").buttons)

            _G.TomTom = {AddWaypoint = function() end}
            local footer = FindType(GetRows("npc", 299), "footer")
            assert.are.equal("TomTom", footer.buttons[2].text)
            footer.buttons[2].onClick()
            assert.are_same({{"Young Wolf", ELWYNN, 48.92, 41.6}}, tomTomTargets)

            npcs[299].spawns = {[DEADMINES] = {{-1, -1}}}
            assert.are.equal(1, #FindType(GetRows("npc", 299), "footer").buttons)
        end)

        it("should say so when it isn't known where it is, and offer nothing for the map", function()
            local rows = GetRows("npc", 300)

            assert.is_not_nil(Find(rows, "No spawn data available."))
            assert.is_nil(rows[3].onShowMap)
            assert.is_nil(FindType(rows, "footer"))
        end)

        it("should show its raw data while debugging", function()
            Questie.db.profile.debugEnabled = true
            QuestieDB.npcKeys, QuestieDB.objectKeys = {minLevel = 1}, {questEnds = 1}

            assert.is_not_nil(Find(GetRows("npc", 299), "minLevel: 1"))
            assert.is_not_nil(Find(GetRows("object", 55), "questEnds: nil"))
        end)

        it("should show nothing when it isn't in the database", function()
            assert.are_same({}, GetRows("npc", 404))
        end)
    end)

    it("should show an object with the icon of objectives instead of a face, and without a level", function()
        local rows = GetRows("object", 55)

        assert.are_same({
            "page: Half-eaten body | Object ID: 55",
            "gap: nil",
            "entity: Elwynn Forest  72.6, 60.3",
            "footer: Show on Map",
        }, Describe(rows))
        assert.are_same({"object"}, {rows[3].icon, rows[3].npcId})

        rows[3].onShowMap()
        assert.are_same({[-55] = {}}, notes)
    end)

    it("should say what can be handed in at an object", function()
        QuestieDB:GetObject(55).questEnds = {11}
        categories[11] = {"log"}
        completion[11] = "ready"

        local status = FindType(GetRows("object", 55), "status")

        assert.are.equal("|Tcomplete:14|t Ready for turn-in: 1", status.text)
    end)

    describe("GetMapAction", function()
        it("should put something on the map, and remove it again", function()
            local action, state = JourneyEntityDetails.GetMapAction("object", 55, function() changes = changes + 1 end)
            assert.are_same({false, "Show on Map", "not shown"}, {action.isOn, action.tooltip, state})

            action.onClick()
            assert.are_same({[-55] = {}}, notes)
            action, state = JourneyEntityDetails.GetMapAction("object", 55, function() changes = changes + 1 end)
            assert.are_same({true, "Remove from Map", "shown"}, {action.isOn, action.tooltip, state})

            action.onClick()
            assert.are_same({}, notes)
            assert.are.equal(2, changes)
        end)

        it("should remove what was put on the map elsewhere after it was made", function()
            local action = JourneyEntityDetails.GetMapAction("npc", 299, function() end)
            notes[299] = {}

            action.onClick()

            assert.are_same({}, notes)
        end)
    end)
end)
