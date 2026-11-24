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

        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyLinks.lua")
        dofile("Modules/Journey/ManualNotes.lua")
        dofile("Modules/Journey/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/QuestieSearch.lua")
        dofile("Modules/Journey/JourneyRawData.lua")
        dofile("Modules/Journey/JourneyEntityDetails.lua")
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
            assert.are_same({
                "heading: Young Wolf",
                "entity: NPC ID: 299\nLevel: 1 - 2\nHealth: 42\nFriendly to: Horde",
                "link: |T137195:14|t Elwynn Forest   X: 48.92 || Y: 41.60",
                "button: Show on Map",
                "title: Starts the following quests",
                "link: Quest 7",
                "title: Ends the following quests",
                "link: Quest 8",
            }, Describe(GetRows("npc", 299)))
            assert.are.equal(299, GetRows("npc", 299)[2].npcId)
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
            assert.is_nil(Find(rows, "Show on Map"))
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

            assert.is_not_nil(Find(GetRows("npc", 299), "Elwynn Forest   X: 48.92"))
        end)

        it("should only name a zone that has no places", function()
            QuestieDB:GetNPC(299).spawns = {[ELWYNN] = {}}

            assert.are.equal("|T137195:14|t Elwynn Forest", GetRows("npc", 299)[3].text)
        end)

        it("should only name the instance it is in, where it has no coordinates", function()
            QuestieDB:GetNPC(299).spawns = {[1581] = {{-1, -1}}}

            assert.are.equal("|T137195:14|t The Deadmines", GetRows("npc", 299)[3].text)
        end)

        it("should not lead to a map that doesn't exist", function()
            QuestieDB:GetNPC(299).spawns = {[ZONE_WITHOUT_MAP] = {{1, 2}}}

            local row = Find(GetRows("npc", 299), "Nowhere")

            assert.are_same({"text", "Nowhere   X: 1.00 || Y: 2.00"}, {row.type, row.text})
        end)

        it("should explain in a tooltip what its place leads to", function()
            Find(GetRows("npc", 299), "Elwynn Forest").showTooltip()

            assert.are_same({"Show on Map"}, GameTooltip.lines)
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

        it("should be shown on the map and removed again", function()
            Find(GetRows("npc", 299), "Show on Map").onClick()
            assert.are_same({[299] = {}}, notes)
            assert.are.equal(1, changes)

            Find(GetRows("npc", 299), "Remove from Map").onClick()
            assert.are_same({}, notes)
            assert.are.equal(2, changes)
        end)

        it("should open the map at its place, instead of the window that would cover it", function()
            Find(GetRows("npc", 299), "Elwynn Forest").onClick()

            assert.are_same({1012}, openedMaps)
            assert.are_same({[299] = {}}, notes)
            assert.is_true(windowHidden)
        end)

        it("should leave the window open when the map can't be opened", function()
            canOpenMap = false

            Find(GetRows("npc", 299), "Elwynn Forest").onClick()

            assert.is_false(windowHidden)
        end)

        it("should offer TomTom only with the addon", function()
            assert.is_nil(Find(GetRows("npc", 299), "TomTom"))

            _G.TomTom = {AddWaypoint = function() end}
            Find(GetRows("npc", 299), "TomTom").onClick()
            assert.are_same({{"Young Wolf", ELWYNN, 48.92, 41.6}}, tomTomTargets)

            QuestieDB:GetNPC(299).spawns = {[1581] = {{-1, -1}}}
            assert.is_nil(Find(GetRows("npc", 299), "TomTom"))
        end)
    end)

    it("should not show a level, health or portrait of an object", function()
        local rows = GetRows("object", 55)

        assert.are_same({
            "heading: Half-eaten body",
            "entity: Object ID: 55",
            "link: |T137195:14|t Elwynn Forest   X: 72.60 || Y: 60.30",
            "button: Show on Map",
        }, Describe(rows))
        assert.is_nil(rows[2].npcId)

        rows[4].onClick()
        assert.are_same({[-55] = {}}, notes)
    end)

    describe("of an item", function()
        before_each(function()
            -- The wolf sells the paw as well, to everyone
            QuestieDB:GetNPC(299).friendlyToFaction = "AH"
        end)

        it("should show its tooltip and where it comes from", function()
            assert.are_same({
                "heading: Gnoll Paw",
                "entity: Item ID: 725",
                "itemTooltip: 725",
                "heading: NPCs",
                "text: 1 NPCs drop this item",
                "button: Show on Map",
                "link: [2] Young Wolf (299)",
                "heading: Objects",
                "text: 1 Objects drop this item",
                "button: Show on Map",
                "link: Half-eaten body (55)",
                "heading: Vendors",
                "text: 1 Vendors sell this item",
                "button: Show on Map",
                "link: [2] Young Wolf (299)",
            }, Describe(GetRows("item", 725)))
            assert.are.equal("icon of 725", GetRows("item", 725)[2].icon)
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

                GetRows("item", 725)[2].onClick()

                assert.are_same({"[Gnoll Paw]"}, {inserted, openedChat, dressedUp})
            end)

            it("should open the chat with its link", function()
                _G.IsShiftKeyDown = function() return true end

                GetRows("item", 725)[2].onClick()

                assert.is_nil(inserted)
                assert.are.equal("[Gnoll Paw]", openedChat)
            end)

            it("should try it on", function()
                _G.IsControlKeyDown = function() return true end

                GetRows("item", 725)[2].onClick()

                assert.are.equal("[Gnoll Paw]", dressedUp)
            end)

            it("should do nothing with an item the client doesn't know yet", function()
                QuestieLoader:ImportModule("QuestieCompat").GetItemInfo = function() end
                _G.IsShiftKeyDown = function() return true end

                GetRows("item", 725)[2].onClick()

                assert.is_nil(inserted)
                assert.is_nil(openedChat)
                assert.is_nil(dressedUp)
            end)

            it("should do nothing without a key", function()
                GetRows("item", 725)[2].onClick()

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
