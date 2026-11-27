dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyEntityDetails", function()
    ---@type JourneyEntityDetails
    local JourneyEntityDetails
    local ui
    local originalQuestie, originalTomTom
    local originals
    local QuestieDB, QuestieCorrections
    local notes, openedMaps, canOpenMap, windowHidden, changes, tomTomTargets, openedLinks

    local ELWYNN, ZONE_WITHOUT_MAP = 12, 9999

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalTomTom = _G.Questie, _G.TomTom
        originals = {}
        for _, name in ipairs({"ChatEdit_GetActiveWindow", "ChatEdit_InsertLink", "ChatFrame_OpenChat", "IsShiftKeyDown",
            "IsControlKeyDown", "DressUpItemLink"}) do
            originals[name] = _G[name]
        end
        _G.Questie = {
            db = {profile = {}},
            Colorize = function(_, text) return text end,
            Print = function() end,
            Debug = function() end,
        }
        _G.TomTom = nil
        notes, openedMaps, canOpenMap, windowHidden, changes, tomTomTargets, openedLinks = {}, {}, true, false, 0, {}, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.questItemBlacklist = {}
        QuestieDB.QuestPointers = {[7] = true, [8] = true}

        local npcs = {
            [299] = {
                id = 299, name = "Young Wolf", minLevel = 1, maxLevel = 2, minLevelHealth = 42, maxLevelHealth = 42,
                friendlyToFaction = "H", spawns = {[ELWYNN] = {{48.92, 41.6}}}, questStarts = {7}, questEnds = {8},
            },
            [300] = {id = 300, name = "Boss", minLevel = 60, maxLevel = 60, minLevelHealth = 1, maxLevelHealth = 2},
            [301] = {id = 301, name = "Enemy vendor", maxLevel = 5, friendlyToFaction = "H", spawns = {[ELWYNN] = {{1, 2}}}},
        }
        local objects = {[55] = {id = 55, name = "Half-eaten body", spawns = {[ELWYNN] = {{72.6, 60.3}}}}}
        local items = {[725] = "Gnoll Paw", [2589] = "Linen Cloth", [5] = "Nothing"}
        local sources = {[725] = {{299, 300}, {55}, {299, 301}}, [5] = {}, [2589] = {{299}}}
        QuestieDB.GetNPC = function(_, id) return npcs[id] end
        QuestieDB.GetObject = function(_, id) return objects[id] end
        QuestieDB.GetItem = function(_, id) return {name = items[id]} end
        QuestieDB.QueryNPCSingle = function(id, field) return npcs[id] and npcs[id][field] end
        QuestieDB.QueryObjectSingle = function(id, field) return objects[id] and objects[id][field] end
        QuestieDB.QueryItemSingle = function(id) return items[id] end
        QuestieDB.QueryItem = function(id) return sources[id] end
        QuestieDB.IsFriendlyToPlayer = function(faction) return faction ~= "H" end
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
        QuestieCompat.GetItemIcon = function(id) return "icon of " .. id end
        QuestieCompat.GetItemInfo = function(id) return items[id], items[id] and "[" .. items[id] .. "]" end
        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.zoneLookup = {[0] = {[ELWYNN] = "Elwynn Forest", [ZONE_WITHOUT_MAP] = "Nowhere"}}
        l10n.zoneCategoryLookup = {[9] = {[1581] = "The Deadmines"}}
        QuestieLoader:ImportModule("TrackerUtils").SetTomTomTarget = function(_, ...) table.insert(tomTomTargets, {...}) end
        local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
        JourneyWindow.MAP_ICON = 137195
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
        JourneyNameColors.Item = function(_, name) return name end
        -- What the quests are, and their icons, are tested with JourneyQuestCategories
        local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyQuestCategories.Get = function() return "available" end
        JourneyQuestCategories.GetIcon = function(_, category) return "icon of " .. category end
        JourneyQuestCategories.GetProgress = function() return "1/2" end
        dofile("Modules/Journey/Details/JourneyEntityDetails.lua")
        JourneyEntityDetails = QuestieLoader:ImportModule("JourneyEntityDetails")
    end)

    after_each(function()
        _G.Questie, _G.TomTom = originalQuestie, originalTomTom
        for name, original in pairs(originals) do
            _G[name] = original
        end
        ui.Restore()
    end)

    ---@param kind "npc"|"object"|"item"
    ---@param id number
    ---@return JourneyDetails.Row[]
    local function GetRows(kind, id)
        return JourneyEntityDetails.GetRows(kind, id, function() changes = changes + 1 end)
    end

    ---@param rows JourneyDetails.Row[]
    ---@return string[] texts One per row, starting with its type
    local function Describe(rows)
        local texts = {}
        for index, row in ipairs(rows) do
            texts[index] = row.type .. ": " .. tostring(row.text or row.itemId)
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

    describe("of an NPC", function()
        it("should show what it is, where it is and its quests", function()
            local rows = GetRows("npc", 299)

            assert.are_same({
                "page: Young Wolf",
                "gap: nil",
                "entity: Level: 1 - 2\nHealth: 42\nFriendly to: Horde\nElwynn Forest  48.9, 41.6",
                "caption: Starts the following quests",
                "step: Quest 7",
                "caption: Ends the following quests",
                "step: Quest 8",
            }, Describe(rows))
            assert.are.equal("NPC ID: 299", rows[1].tag)
            assert.are.equal(299, rows[3].npcId)
        end)

        it("should say how far along a quest in the log is, and why another can't be done", function()
            local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
            JourneyQuestCategories.Get = function(id) if id == 7 then return "log" end return "later", "Level 5" end

            local rows = GetRows("npc", 299)

            assert.are_same({"1/2", "icon of log"}, {Find(rows, "Quest 7").tag, Find(rows, "Quest 7").trailingIcon})
            assert.are_same({"Level 5", "icon of later"}, {Find(rows, "Quest 8").tag, Find(rows, "Quest 8").trailingIcon})
        end)

        for faction, text in pairs({AH = "both factions", A = "Alliance", none = "no faction"}) do
            it("should say that it is friendly to " .. text, function()
                QuestieDB:GetNPC(299).friendlyToFaction = faction ~= "none" and faction or nil

                assert.is_not_nil(Find(GetRows("npc", 299), "Friendly to: " .. text))
            end)
        end

        it("should say so when it isn't known where it is", function()
            local rows = GetRows("npc", 300)

            assert.is_not_nil(Find(rows, "No spawn data available."))
            assert.is_nil(rows[3].onShowMap)
            assert.is_not_nil(Find(rows, "Health: 1 - 2"))
        end)

        it("should show its title", function()
            QuestieDB:GetNPC(299).subName = "The Hungry"

            assert.is_not_nil(Find(GetRows("npc", 299), "Title: The Hungry"))
        end)

        it("should name its zone in the language of the client", function()
            QuestieLoader:ImportModule("l10n").translations["Elwynn Forest"] = {["deDE"] = "Wald von Elwynn"}
            QuestieLoader:ImportModule("l10n"):SetUILocale("deDE")

            assert.is_not_nil(Find(GetRows("npc", 299), "Wald von Elwynn"))
        end)

        it("should prefer a place with coordinates", function()
            QuestieDB:GetNPC(299).spawns = {[1581] = {{-1, -1}}, [ZONE_WITHOUT_MAP] = {}, [ELWYNN] = {{48.92, 41.6}}}

            assert.is_not_nil(Find(GetRows("npc", 299), "Elwynn Forest  48.9, 41.6"))
        end)

        it("should only name a zone that has no places", function()
            QuestieDB:GetNPC(299).spawns = {[ELWYNN] = {}}

            assert.are.equal("Level: 1 - 2\nHealth: 42\nFriendly to: Horde\nElwynn Forest", GetRows("npc", 299)[3].text)
        end)

        it("should only name the instance it is in, where it has no coordinates", function()
            QuestieDB:GetNPC(299).spawns = {[1581] = {{-1, -1}}}

            assert.are.equal("Level: 1 - 2\nHealth: 42\nFriendly to: Horde\nThe Deadmines", GetRows("npc", 299)[3].text)
        end)

        it("should not lead to a map that doesn't exist", function()
            QuestieDB:GetNPC(299).spawns = {[ZONE_WITHOUT_MAP] = {{1, 2}}}

            local rows = GetRows("npc", 299)

            assert.is_not_nil(Find(rows, "Nowhere    1.0,   2.0"))
            assert.is_nil(rows[3].onShowMap)
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

        it("should open the map at its place, instead of the window that would cover it", function()
            GetRows("npc", 299)[3].onShowMap()

            assert.are_same({1012}, openedMaps)
            assert.are_same({[299] = {}}, notes)
            assert.is_true(windowHidden)
        end)

        it("should leave the window open when the map can't be opened", function()
            canOpenMap = false

            GetRows("npc", 299)[3].onShowMap()

            assert.is_false(windowHidden)
        end)

        it("should be removed from the map again", function()
            local rows = GetRows("npc", 299)
            assert.are_not.equal("footer", rows[#rows].type)
            rows[3].onShowMap()

            rows = GetRows("npc", 299)
            local button = rows[#rows].buttons[1]
            assert.are.equal("Remove from Map", button.text)
            button.onClick()

            assert.are_same({}, notes)
            assert.are.equal(1, changes)
        end)

        it("should offer TomTom only with the addon, and only where there are coordinates", function()
            local rows = GetRows("npc", 299)
            assert.are_not.equal("footer", rows[#rows].type)

            _G.TomTom = {AddWaypoint = function() end}
            rows = GetRows("npc", 299)
            assert.are.equal("TomTom", rows[#rows].buttons[1].text)
            rows[#rows].buttons[1].onClick()
            assert.are_same({{"Young Wolf", ELWYNN, 48.92, 41.6}}, tomTomTargets)

            QuestieDB:GetNPC(299).spawns = {[1581] = {{-1, -1}}}
            rows = GetRows("npc", 299)
            assert.are_not.equal("footer", rows[#rows].type)
        end)
    end)

    it("should not show a level, health or portrait of an object", function()
        local rows = GetRows("object", 55)

        assert.are_same({
            "page: Half-eaten body",
            "gap: nil",
            "entity: Elwynn Forest  72.6, 60.3",
        }, Describe(rows))
        assert.are.equal("Object ID: 55", rows[1].tag)
        assert.is_nil(rows[3].npcId)

        rows[3].onShowMap()
        assert.are_same({[-55] = {}}, notes)
    end)

    describe("of an item", function()
        before_each(function()
            -- The wolf sells the paw as well, to everyone
            QuestieDB:GetNPC(299).friendlyToFaction = "AH"
        end)

        it("should show its tooltip and where it comes from", function()
            local rows = GetRows("item", 725)

            assert.are_same({
                "page: Gnoll Paw",
                "gap: nil",
                "entity:  ",
                "itemTooltip: 725",
                "caption: NPCs",
                "text: 1 NPCs drop this item",
                "button: Show on Map",
                "link: [2] Young Wolf (299)",
                "caption: Objects",
                "text: 1 Objects drop this item",
                "button: Show on Map",
                "link: Half-eaten body (55)",
                "caption: Vendors",
                "text: 1 Vendors sell this item",
                "button: Show on Map",
                "link: [2] Young Wolf (299)",
            }, Describe(rows))
            assert.are.equal("Item ID: 725", rows[1].tag)
            assert.are.equal("icon of 725", rows[3].icon)
        end)

        it("should not list vendors of the other faction", function()
            QuestieDB:GetNPC(299).friendlyToFaction = "H"

            assert.is_not_nil(Find(GetRows("item", 725), "0 Vendors sell this item"))
        end)

        it("should list NPCs of the other faction that drop it", function()
            QuestieDB:GetNPC(299).friendlyToFaction = "H"

            assert.is_not_nil(Find(GetRows("item", 725), "1 NPCs drop this item"))
        end)

        it("should say what it doesn't come from", function()
            local rows = GetRows("item", 5)

            assert.is_not_nil(Find(rows, "No NPC drops this item"))
            assert.is_not_nil(Find(rows, "No Object drops this item"))
            assert.is_not_nil(Find(rows, "No Vendor sells this item"))
        end)

        it("should not list the sources of one with too many", function()
            QuestieCorrections.questItemBlacklist[2589] = true

            local rows = GetRows("item", 2589)

            assert.is_not_nil(Find(rows, "This item is blacklisted because it has too many sources"))
            assert.is_nil(Find(rows, "Young Wolf"))
        end)

        ---@param heading string
        ---@return JourneyDetails.Row button Below the heading
        local function FindNoteButton(heading)
            local isBelowHeading = false
            for _, row in ipairs(GetRows("item", 725)) do
                isBelowHeading = isBelowHeading or row.text == heading
                if isBelowHeading and row.type == "button" then
                    return row
                end
            end
        end

        it("should show all its sources of one kind on the map, and remove them again", function()
            FindNoteButton("Objects").onClick()
            ui.RunUntilIdle()
            assert.are_same({[-55] = {}}, notes)
            assert.are.equal("Remove from Map", FindNoteButton("Objects").text)
            assert.are.equal("Show on Map", FindNoteButton("NPCs").text)

            FindNoteButton("Objects").onClick()
            ui.RunUntilIdle()
            assert.are_same({}, notes)
            assert.are.equal(2, changes)
        end)

        it("should only show those sources on the map that are listed", function()
            FindNoteButton("NPCs").onClick()
            ui.RunUntilIdle()

            assert.are_same({[299] = {}}, notes)
        end)

        it("should show its raw data while debugging", function()
            Questie.db.profile.debugEnabled = true
            QuestieDB.itemKeys = {name = 1}

            assert.is_not_nil(Find(GetRows("item", 725), "name: Gnoll Paw"))
        end)

        describe("clicking its icon", function()
            local inserted, openedChat, dressedUp

            before_each(function()
                inserted, openedChat, dressedUp = nil, nil, nil
                _G.IsShiftKeyDown, _G.IsControlKeyDown = function() return false end, function() return false end
                _G.ChatEdit_GetActiveWindow = function() return nil end
                _G.ChatEdit_InsertLink = function(link) inserted = link or "nothing" end
                _G.ChatFrame_OpenChat = function(text) openedChat = text or "nothing" end
                _G.DressUpItemLink = function(link) dressedUp = link or "nothing" end
            end)

            it("should put its link into the chat that is typed in", function()
                _G.IsShiftKeyDown = function() return true end
                _G.ChatEdit_GetActiveWindow = function() return {} end

                GetRows("item", 725)[3].onClick()

                assert.are_same({"[Gnoll Paw]"}, {inserted, openedChat, dressedUp})
            end)

            it("should open the chat with its link", function()
                _G.IsShiftKeyDown = function() return true end

                GetRows("item", 725)[3].onClick()

                assert.is_nil(inserted)
                assert.are.equal("[Gnoll Paw]", openedChat)
            end)

            it("should try it on", function()
                _G.IsControlKeyDown = function() return true end

                GetRows("item", 725)[3].onClick()

                assert.are.equal("[Gnoll Paw]", dressedUp)
            end)

            it("should do nothing with an item the client doesn't know yet", function()
                QuestieLoader:ImportModule("QuestieCompat").GetItemInfo = function() end
                _G.IsShiftKeyDown = function() return true end

                GetRows("item", 725)[3].onClick()

                assert.is_nil(inserted)
                assert.is_nil(openedChat)
                assert.is_nil(dressedUp)
            end)

            it("should do nothing without a key", function()
                GetRows("item", 725)[3].onClick()

                assert.is_nil(inserted)
                assert.is_nil(openedChat)
                assert.is_nil(dressedUp)
            end)
        end)
    end)

    it("should lead to the search through its links", function()
        Find(GetRows("npc", 299), "Quest 7").onClick()

        assert.are_same({{"quest", 7}}, openedLinks)
    end)
end)
