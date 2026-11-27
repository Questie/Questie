dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyItemDetails", function()
    ---@type JourneyItemDetails
    local JourneyItemDetails
    local ui
    local originalQuestie
    local originals
    local QuestieDB, QuestieCorrections
    local items, npcs, dropRates
    local notes, changes, openedLinks

    local ELWYNN, WESTFALL = 12, 40

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie = _G.Questie
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
        notes, changes, openedLinks = {}, 0, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.questItemBlacklist = {}
        QuestieDB.QuestPointers = {[7] = true, [8] = true}

        -- The player is of the Alliance
        npcs = {
            [299] = {name = "Young Wolf", friendlyToFaction = "AH", spawns = {[ELWYNN] = {{48.9, 41.6}}}, zoneID = ELWYNN},
            [300] = {name = "Gnoll Runt", spawns = {[WESTFALL] = {{50, 50}}}, zoneID = WESTFALL},
            [301] = {name = "Riverpaw Gnoll", spawns = {[WESTFALL] = {{51, 51}}}, zoneID = WESTFALL},
            [302] = {name = "Ghost", zoneID = ELWYNN}, -- Without spawns
            [303] = {name = "Horde vendor", friendlyToFaction = "H", spawns = {[ELWYNN] = {{1, 2}}}, zoneID = ELWYNN},
        }
        local objects = {[55] = {name = "Half-eaten body", spawns = {[ELWYNN] = {{72.6, 60.3}}}, zoneID = ELWYNN}}
        items = {
            [725] = {name = "Gnoll Paw", npcDrops = {299, 300, 301, 302}, objectDrops = {55}, vendors = {299, 303}},
            [2589] = {name = "Linen Cloth"},
            [5] = {name = "Nothing"},
        }
        dropRates = {[300] = 4.5, [301] = 32.25}
        QuestieDB.QueryNPCSingle = function(id, field) return npcs[id] and npcs[id][field] end
        QuestieDB.QueryObjectSingle = function(id, field) return objects[id] and objects[id][field] end
        QuestieDB.QueryItemSingle = function(id, field) return items[id] and items[id][field] end
        QuestieDB.GetItem = function(_, id) return items[id] end
        QuestieDB.GetItemDroprate = function(itemId, npcId)
            return itemId == 725 and dropRates[npcId] and {dropRates[npcId], "wowhead"} or nil
        end
        -- Like the real one for an Alliance player: an NPC without a faction is friendly to everyone
        QuestieDB.IsFriendlyToPlayer = function(faction) return not faction or faction == "AH" or faction == "A" end

        local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.manualFrames = {any = notes}
        QuestieMap.ShowNPC = function(_, id) notes[id] = {} end
        QuestieMap.ShowObject = function(_, id) notes[-id] = {} end
        QuestieMap.UnloadManualFrames = function(_, id) notes[id] = nil end
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetItemIcon = function(id) return "icon of " .. id end
        QuestieCompat.GetItemInfo = function(id) return items[id] and items[id].name, items[id] and "[" .. items[id].name .. "]" end
        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.zoneLookup = {[0] = {[ELWYNN] = "Elwynn Forest", [WESTFALL] = "Westfall"}}
        l10n.zoneCategoryLookup = {[9] = {}}
        QuestieLoader:ImportModule("JourneyWindow").OpenLink = function(kind, id) table.insert(openedLinks, {kind, id}) end

        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLoader:ImportModule("QuestieLib").GetColoredQuestName = function(_, id) return "Quest " .. id end
        dofile("Modules/Journey/Data/JourneyThread.lua")
        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Details/JourneyDetails.lua")
        dofile("Modules/Journey/Details/JourneyLinks.lua")
        dofile("Modules/Journey/Details/ManualNotes.lua")
        dofile("Modules/Journey/Details/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/Data/QuestieSearch.lua")
        dofile("Modules/Journey/Details/JourneyRawData.lua")
        dofile("Modules/Journey/Details/JourneyEntityDetails.lua")
        -- The colors of names are tested with JourneyNameColors
        local JourneyNameColors = QuestieLoader:ImportModule("JourneyNameColors")
        JourneyNameColors.Npc = function(_, name) return name end
        JourneyNameColors.Object = function(name) return name end
        JourneyNameColors.Item = function(_, name) return name end
        -- Which quests are listed, in what order and with what note, and their icons, are tested with JourneyQuestCategories
        local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyQuestCategories.Arrange = function(questIds)
            local entries = {}
            for _, questId in ipairs(questIds) do
                if QuestieDB.QuestPointers[questId] then
                    table.insert(entries, {questId = questId, category = "available"})
                end
            end
            return entries
        end
        JourneyQuestCategories.GetIcon = function(_, category) return "icon of " .. category end
        dofile("Modules/Journey/Details/JourneyItemDetails.lua")
        JourneyItemDetails = QuestieLoader:ImportModule("JourneyItemDetails")
    end)

    after_each(function()
        _G.Questie = originalQuestie
        for name, original in pairs(originals) do
            _G[name] = original
        end
        ui.Restore()
    end)

    ---@param id ItemId
    ---@return JourneyDetails.Row[]
    local function GetRows(id)
        return JourneyItemDetails.GetRows(id, function() changes = changes + 1 end)
    end

    ---@param rows JourneyDetails.Row[]
    ---@return string[] texts One per row, starting with its type, and its tag if it has one
    local function Describe(rows)
        local texts = {}
        for index, row in ipairs(rows) do
            local text = row.text or row.itemId or row.buttons and row.buttons[1].text
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
    ---@return JourneyDetails.Row? footer
    local function Footer(rows)
        for _, row in ipairs(rows) do
            if row.type == "footer" then return row end
        end
    end

    ---@param rows JourneyDetails.Row[]
    ---@param caption string The start of it
    ---@return string[] texts Of the steps below the caption
    local function Section(rows, caption)
        local texts, isInSection = {}, false
        for _, row in ipairs(rows) do
            if row.type == "caption" then
                isInSection = row.text:sub(1, #caption) == caption
            elseif row.type ~= "step" then
                isInSection = false
            elseif isInSection then
                table.insert(texts, row.text .. (row.tag and " | " .. row.tag or ""))
            end
        end
        return texts
    end

    it("should show its tooltip and where to get it, the likeliest drop first", function()
        assert.are_same({
            "page: Gnoll Paw | Item ID: 725",
            "gap: nil",
            "itemTooltip: 725",
            "caption: NPCs   3",
            "step: Riverpaw Gnoll | Westfall   32%",
            "step: Gnoll Runt | Westfall   4.5%",
            "step: Young Wolf | Elwynn Forest",
            "caption: Objects   1",
            "step: Half-eaten body | Elwynn Forest",
            "caption: Vendors   1",
            "step: Young Wolf | Elwynn Forest",
            "footer: Show on Map",
        }, Describe(GetRows(725)))
    end)

    it("should list NPCs of the other faction that drop it, but not those that sell it", function()
        items[725].npcDrops = {303}

        local rows = GetRows(725)

        assert.are_same({"Horde vendor | Elwynn Forest"}, Section(rows, "NPCs"))
        assert.are_same({"Young Wolf | Elwynn Forest"}, Section(rows, "Vendors"))
    end)

    it("should list vendors without a faction, who sell to everyone", function()
        items[725].vendors = {300}

        assert.are_same({"Gnoll Runt | Westfall"}, Section(GetRows(725), "Vendors"))
    end)

    it("should list those without a drop rate by name", function()
        npcs[304] = {name = "Abe", friendlyToFaction = "A", spawns = {[ELWYNN] = {{3, 4}}}}
        npcs[305] = {name = "Zed", friendlyToFaction = "A", spawns = {[ELWYNN] = {{5, 6}}}}
        items[725].vendors = {305, 299, 304}

        assert.are_same({"Abe | Elwynn Forest", "Young Wolf | Elwynn Forest", "Zed | Elwynn Forest"}, Section(GetRows(725), "Vendors"))
    end)

    it("should name the zone of each the way its own page does: where it spawns the most", function()
        npcs[300].zoneID = ELWYNN
        npcs[300].spawns = {[ELWYNN] = {{1, 1}}, [WESTFALL] = {{2, 2}, {3, 3}}}

        assert.are.equal("Gnoll Runt | Westfall   4.5%", Section(GetRows(725), "NPCs")[2])
    end)

    it("should say so when none of those it comes from is known to spawn anywhere", function()
        items[5].npcDrops = {302}

        local rows = GetRows(5)

        assert.is_not_nil(Find(rows, "No spawn data available."))
        assert.are_same({}, Section(rows, "NPCs"))
    end)

    it("should not say so when it only comes from NPCs of the other faction", function()
        items[5].vendors = {303}

        assert.is_nil(Find(GetRows(5), "No spawn data available."))
    end)

    it("should only say how likely NPCs drop it, not how likely an object has it or a vendor sells it", function()
        dropRates[299], dropRates[55] = 10, 50

        local rows = GetRows(725)

        assert.are.equal("Young Wolf | Elwynn Forest   10%", Section(rows, "NPCs")[2])
        assert.are_same({"Half-eaten body | Elwynn Forest"}, Section(rows, "Objects"))
        assert.are_same({"Young Wolf | Elwynn Forest"}, Section(rows, "Vendors"))
    end)

    it("should leave out what it has nothing for", function()
        assert.are_same({"page: Nothing | Item ID: 5", "gap: nil", "itemTooltip: 5"}, Describe(GetRows(5)))
    end)

    it("should lead to the quest it starts, the quests it is a reward of and what it can be found in", function()
        items[5].startQuest, items[5].questRewards, items[5].itemDrops = 7, {8, 404}, {2589}

        local rows = GetRows(5)

        assert.are_same({
            "page: Nothing | Item ID: 5",
            "gap: nil",
            "itemTooltip: 5",
            "caption: Starts this quest",
            "step: Quest 7",
            "caption: Contained in",
            "step: Linen Cloth",
            "caption: Reward from",
            "step: Quest 8",
        }, Describe(rows))
        assert.are.equal("icon of 2589", rows[7].trailingIcon)
        rows[5].onClick()
        rows[7].onClick()
        assert.are_same({{"quest", 7}, {"item", 2589}}, openedLinks)
    end)

    it("should lead to the NPCs and objects it comes from", function()
        local rows = GetRows(725)

        Find(rows, "Riverpaw Gnoll").onClick()
        Find(rows, "Half-eaten body").onClick()

        assert.are_same({{"npc", 301}, {"object", 55}}, openedLinks)
    end)

    it("should not list the sources of one with too many, but still its quests", function()
        QuestieCorrections.questItemBlacklist[725] = true
        items[725].questRewards = {8}

        local rows = GetRows(725)

        assert.is_not_nil(Find(rows, "This item is blacklisted because it has too many sources"))
        assert.is_nil(Find(rows, "Young Wolf"))
        assert.is_nil(Footer(rows))
        assert.is_not_nil(Find(rows, "Quest 8"))
    end)

    it("should be empty for an item that isn't in the database", function()
        assert.are_same({}, GetRows(404))
    end)

    it("should show its raw data while debugging", function()
        Questie.db.profile.debugEnabled = true
        QuestieDB.itemKeys = {name = 1}

        assert.is_not_nil(Find(GetRows(725), "name: Gnoll Paw"))
    end)

    describe("on the map", function()
        it("should show each source with its small map", function()
            local runt = Find(GetRows(725), "Gnoll Runt")
            assert.is_false(runt.action.isOn)

            runt.action.onClick()

            assert.are_same({[300] = {}}, notes)
            assert.is_true(Find(GetRows(725), "Gnoll Runt").action.isOn)
            assert.is_false(Find(GetRows(725), "Riverpaw Gnoll").action.isOn)
        end)

        it("should show all sources that are listed together, and remove them again", function()
            Footer(GetRows(725)).buttons[1].onClick()
            -- At once, so that its button says what a second click does
            assert.are.equal(1, changes)
            assert.are.equal("Remove from Map", Footer(GetRows(725)).buttons[1].text)
            ui.RunUntilIdle()

            assert.are_same({[299] = {}, [300] = {}, [301] = {}, [-55] = {}}, notes)
            local rows = GetRows(725)
            assert.are.equal("Remove from Map", Footer(rows).buttons[1].text)
            assert.is_true(Find(rows, "Half-eaten body").action.isOn)

            Footer(rows).buttons[1].onClick()
            ui.RunUntilIdle()
            assert.are_same({}, notes)
            assert.are.equal("Show on Map", Footer(GetRows(725)).buttons[1].text)
        end)

        it("should tell the page once all of them are there, so that their small maps are right", function()
            local notesWhenChanged = {}
            local rows = JourneyItemDetails.GetRows(725, function()
                local count = 0
                for _ in pairs(notes) do count = count + 1 end
                table.insert(notesWhenChanged, count)
            end)

            Footer(rows).buttons[1].onClick()
            ui.RunUntilIdle()
            assert.are.equal(4, notesWhenChanged[#notesWhenChanged])
        end)

        it("should tell the page once all of them are gone again", function()
            Footer(GetRows(725)).buttons[1].onClick()
            ui.RunUntilIdle()
            local notesWhenChanged = {}

            Footer(JourneyItemDetails.GetRows(725, function()
                local count = 0
                for _ in pairs(notes) do count = count + 1 end
                table.insert(notesWhenChanged, count)
            end)).buttons[1].onClick()
            ui.RunUntilIdle()

            assert.are.equal(0, notesWhenChanged[#notesWhenChanged])
            assert.is_true(#notesWhenChanged > 1, "Only told at once, not when all were gone")
        end)
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

        ---@return JourneyDetails.Row
        local function Icon()
            local row = GetRows(725)[3]
            assert.are.equal("icon of 725", row.icon)
            return row
        end

        it("should put its link into the chat that is typed in", function()
            _G.IsShiftKeyDown = function() return true end
            _G.ChatEdit_GetActiveWindow = function() return {} end

            Icon().onClick()

            assert.are_same({"[Gnoll Paw]"}, {inserted, openedChat, dressedUp})
        end)

        it("should open the chat with its link", function()
            _G.IsShiftKeyDown = function() return true end

            Icon().onClick()

            assert.is_nil(inserted)
            assert.are.equal("[Gnoll Paw]", openedChat)
        end)

        it("should try it on", function()
            _G.IsControlKeyDown = function() return true end

            Icon().onClick()

            assert.are.equal("[Gnoll Paw]", dressedUp)
        end)

        it("should do nothing with an item the client doesn't know yet", function()
            QuestieLoader:ImportModule("QuestieCompat").GetItemInfo = function() end
            _G.IsShiftKeyDown = function() return true end

            Icon().onClick()

            assert.are_same({}, {inserted, openedChat, dressedUp})
        end)

        it("should do nothing without a key", function()
            Icon().onClick()

            assert.are_same({}, {inserted, openedChat, dressedUp})
        end)
    end)
end)
