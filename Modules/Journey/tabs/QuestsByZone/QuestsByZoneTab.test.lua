dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("Quests by Zone", function()
    local questsByZone
    local ui
    local originalQuestie, originalUnitClassBase
    local QuestiePlayer, QuestieJourney
    local canvas

    local EASTERN_KINGDOMS, KALIMDOR, OUTLAND, ZEPHRAS_ISLE, DUNGEONS, CLASS, PET_BATTLES = 1, 2, 3, 8, 9, 11, 14
    local ELWYNN, WESTFALL, DUROTAR, HELLFIRE, ZEPHRAS, DEADMINES, MAGE, PET_BATTLE = 12, 40, 14, 3483, 9500, 1581, -161, -1000
    local NORTHREND, PANDARIA, DRAGONBLIGHT, JADE_FOREST = 4, 7, 65, 5785
    local NORTHSHIRE = 9001 -- Only a part of Elwynn Forest

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalUnitClassBase = _G.Questie, _G.UnitClassBase
        _G.Questie = {db = {profile = {}, char = {complete = {}, hidden = {}}}, icons = {}, IsForever = false, Error = function(_, message) error(message) end}
        _G.UnitClassBase = function() return "MAGE" end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieLoader:ImportModule("l10n").zoneLookup = {[DEADMINES] = {}}
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetCurrentContinentId = function() return 0 end
        QuestiePlayer.GetCurrentZoneId = function() return ELWYNN end
        QuestieLoader:ImportModule("ZoneDB").private.subZoneToParentZoneOverride = "return {[" .. NORTHSHIRE .. "] = " .. ELWYNN .. "}"
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.sortKeys = {PET_BATTLE = PET_BATTLE}
        QuestieDB.GetZoneOrSortForClass = function(_, class) return class == "MAGE" and MAGE or nil end
        QuestieDB.GetQuest = function(id) return {Id = id} end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            return {{type = "text", text = "Details of quest " .. quest.Id}}
        end
        QuestieLoader:ImportModule("ActiveQuests").Get = function() end
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function() end

        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieJourney.questCategoryKeys = {
            EASTERN_KINGDOMS = EASTERN_KINGDOMS, KALIMDOR = KALIMDOR, OUTLAND = OUTLAND, NORTHREND = NORTHREND, PANDARIA = PANDARIA,
            ZEPHRAS_ISLE = ZEPHRAS_ISLE, DUNGEONS = DUNGEONS, BATTLEGROUNDS = 10, CLASS = CLASS, PROFESSIONS = 12, EVENTS = 13,
            PET_BATTLES = PET_BATTLES, SCENARIOS = 15,
        }
        QuestieJourney.continents = {
            [EASTERN_KINGDOMS] = "Eastern Kingdoms", [KALIMDOR] = "Kalimdor", [OUTLAND] = "Outland", [ZEPHRAS_ISLE] = "Zephras Isle",
            [DUNGEONS] = "Dungeons", [CLASS] = "Mage", [PET_BATTLES] = "Pet Battles",
        }
        QuestieJourney.zones = {
            [EASTERN_KINGDOMS] = {[ELWYNN] = "Elwynn Forest", [WESTFALL] = "Westfall"},
            [KALIMDOR] = {[DUROTAR] = "Durotar"},
            [OUTLAND] = {[HELLFIRE] = "Hellfire Peninsula"},
            [ZEPHRAS_ISLE] = {[ZEPHRAS] = "Zephras"},
            [DUNGEONS] = {[DEADMINES] = "The Deadmines"},
            [NORTHREND] = {[DRAGONBLIGHT] = "Dragonblight"}, -- Not offered on this expansion
            [PANDARIA] = {[JADE_FOREST] = "The Jade Forest"},
            [10] = {}, [12] = {}, [13] = {}, [15] = {},
        }
        QuestieJourney.zoneMap = {
            [ELWYNN] = {[54] = true}, [WESTFALL] = {[12] = true}, [DUROTAR] = {[4402] = true}, [HELLFIRE] = {[10120] = true},
            [ZEPHRAS] = {[93000] = true}, [DEADMINES] = {[166] = true}, [MAGE] = {[1861] = true}, [PET_BATTLE] = {[31000] = true},
            [DRAGONBLIGHT] = {[11000] = true}, [JADE_FOREST] = {[29547] = true},
        }
        -- Where the quests of a zone come from has its own tests
        local private = QuestieJourney.private
        private.questsByZone = {
            CollectZoneQuests = function(_, zoneId)
                local quests = QuestieJourney.zoneMap[zoneId]
                return quests and private.questsByZone:CategorizeQuests(quests)
            end,
            CategorizeQuests = function(_, quests)
                local nodes = {}
                for id in pairs(quests) do table.insert(nodes, {value = id, text = "Quest " .. id}) end
                table.sort(nodes, function(a, b) return a.value < b.value end)
                return {{value = "a", text = "Available", children = nodes}}
            end,
        }
        questsByZone = private.questsByZone
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyPanes.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyQuestList.lua")
        dofile("Modules/Journey/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/tabs/QuestsByZone/QuestsByZoneTab.lua")
        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)
        questsByZone.Build(canvas)
    end)

    after_each(function()
        _G.Questie, _G.UnitClassBase = originalQuestie, originalUnitClassBase
        ui.Restore()
    end)

    local function Refresh()
        questsByZone.Refresh()
        ui.RunUntilIdle()
    end

    -- Opens the tab, like JourneyWindow does
    local function Open()
        questsByZone.OnSelected()
        Refresh()
    end

    ---@param questId number
    local function OpenQuest(questId)
        questsByZone.OpenQuest(questId)
        ui.RunUntilIdle()
    end

    ---@param index number
    ---@return table dropdown
    local function Dropdown(index)
        return ui.FindByTemplate(canvas, "WowStyle1DropdownTemplate")[index]
    end

    ---@param index number
    ---@param text string
    local function Choose(index, text)
        local dropdown = Dropdown(index)
        dropdown:OpenMenu()
        for _, entry in ipairs(dropdown.menuEntries) do
            if entry.text == text then
                dropdown:Pick(entry)
                ui.RunUntilIdle()
                return
            end
        end
        error("There is no choice " .. text)
    end

    ---@param index number
    ---@return string[] texts
    local function Choices(index)
        local dropdown = Dropdown(index)
        dropdown:OpenMenu()
        local texts = {}
        for _, entry in ipairs(dropdown.menuEntries) do
            table.insert(texts, entry.isDivider and "---" or entry.text)
        end
        dropdown:CloseMenu()
        return texts
    end

    ---@return string[] texts Of the quests, which are all in one category
    local function ListTexts()
        local rows = ui.Rows(canvas, 1)
        if #rows == 1 then
            rows[1]:Click() -- Expands the category
        end
        local texts = ui.RowTexts(canvas, 1)
        table.remove(texts, 1)
        return texts
    end

    ---@return boolean
    local function SaysThereAreNone()
        return #ui.FindAll(canvas, function(frame) return frame.text == "No Quests found" and frame:IsVisible() end) == 1
    end

    ---@return string? text
    local function Details()
        local row = ui.Rows(canvas, 2)[1]
        return row and row.elementData.text
    end

    for _, place in ipairs({
        {continent = 0, zone = ELWYNN, texts = {"Eastern Kingdoms", "Elwynn Forest"}, quest = "Quest 54"},
        {continent = 0, zone = NORTHSHIRE, texts = {"Eastern Kingdoms", "Elwynn Forest"}, quest = "Quest 54"},
        {continent = 1, zone = DUROTAR, texts = {"Kalimdor", "Durotar"}, quest = "Quest 4402"},
        {continent = 530, zone = HELLFIRE, texts = {"Outland", "Hellfire Peninsula"}, quest = "Quest 10120"},
        {continent = 571, zone = DRAGONBLIGHT, texts = {"Northrend", "Dragonblight"}, quest = "Quest 11000", category = NORTHREND},
        {continent = 870, zone = JADE_FOREST, texts = {"Pandaria", "The Jade Forest"}, quest = "Quest 29547", category = PANDARIA},
        {continent = DEADMINES, zone = DEADMINES, texts = {"Dungeons", "The Deadmines"}, quest = "Quest 166"},
        {continent = 947, zone = ZEPHRAS, texts = {"Zephras Isle", "Zephras"}, quest = "Quest 93000", isForever = true},
    }) do
        it("should start with the zone the player is in, like " .. place.texts[2] .. " (" .. place.zone .. ")", function()
            Questie.IsForever = place.isForever == true
            if place.category then
                QuestieJourney.continents[place.category] = place.texts[1] -- Only offered on later expansions
            end
            QuestiePlayer.GetCurrentContinentId = function() return place.continent end
            QuestiePlayer.GetCurrentZoneId = function() return place.zone end

            Open()

            assert.are_same(place.texts, {Dropdown(1).text, Dropdown(2).text})
            assert.are_same({place.quest}, ListTexts())
        end)
    end

    it("should follow the player as long as nothing was chosen", function()
        Open()
        QuestiePlayer.GetCurrentContinentId = function() return 1 end
        QuestiePlayer.GetCurrentZoneId = function() return DUROTAR end

        Open()

        assert.are_same({"Kalimdor", "Durotar"}, {Dropdown(1).text, Dropdown(2).text})
        assert.are_same({"Quest 4402"}, ListTexts())
    end)

    it("should not go anywhere else while it is open, whatever about quests changes", function()
        Open()
        OpenQuest(54)
        QuestiePlayer.GetCurrentContinentId = function() return 1 end
        QuestiePlayer.GetCurrentZoneId = function() return DUROTAR end

        Refresh()

        assert.are_same({"Eastern Kingdoms", "Elwynn Forest"}, {Dropdown(1).text, Dropdown(2).text})
        assert.are_same({"Quest 54"}, ListTexts())
        assert.are.equal("Details of quest 54", Details())
    end)

    it("should stay where the user chose, wherever the player goes", function()
        Open()
        Choose(2, "Westfall")
        QuestiePlayer.GetCurrentContinentId = function() return 1 end
        QuestiePlayer.GetCurrentZoneId = function() return DUROTAR end

        Open()

        assert.are_same({"Eastern Kingdoms", "Westfall"}, {Dropdown(1).text, Dropdown(2).text})
        assert.are_same({"Quest 12"}, ListTexts())
    end)

    it("should offer all quests first, and then the categories in order", function()
        Open()

        assert.are_same(
            {"All Quests", "---", "Eastern Kingdoms", "Kalimdor", "Outland", "Zephras Isle", "Dungeons", "Mage", "Pet Battles"},
            Choices(1)
        )
    end)

    it("should offer the zones sorted by name", function()
        Open()
        QuestieJourney.zones[EASTERN_KINGDOMS][3] = "Badlands"

        assert.are_same({"Badlands", "Elwynn Forest", "Westfall"}, Choices(2))
    end)

    it("should list nothing until a zone of another category is chosen", function()
        Open()

        Choose(1, "Kalimdor")
        assert.are_same({}, ListTexts())
        assert.is_false(SaysThereAreNone())
        assert.are.equal("Select Zone", Dropdown(2).text)

        Choose(2, "Durotar")
        assert.are_same({"Quest 4402"}, ListTexts())
    end)

    for category, placeholder in pairs({
        [DUNGEONS] = "Select Dungeon", [10] = "Select Battleground", [12] = "Select Profession", [13] = "Select Event",
        [15] = "Select Scenario",
    }) do
        it("should say " .. placeholder .. " instead of Select Zone", function()
            QuestieJourney.continents[category] = "Others"
            Open()

            Choose(1, "Others")

            assert.are.equal(placeholder, Dropdown(2).text)
        end)
    end

    it("should list all quests once", function()
        QuestieJourney.zoneMap[WESTFALL][54] = true
        Open()

        Choose(1, "All Quests")

        assert.are_same({
            "Quest 12", "Quest 54", "Quest 166", "Quest 1861", "Quest 4402", "Quest 10120", "Quest 11000", "Quest 29547", "Quest 31000",
            "Quest 93000",
        }, ListTexts())
        assert.is_false(Dropdown(2):IsVisible())
    end)

    for name, quest in pairs({["Mage"] = "Quest 1861", ["Pet Battles"] = "Quest 31000"}) do
        it("should list the quests of " .. name .. ", which has no zones", function()
            Open()

            Choose(1, name)

            assert.are_same({quest}, ListTexts())
            assert.is_false(Dropdown(2):IsVisible())
        end)
    end

    it("should list nothing for a zone without quests", function()
        Open()
        QuestieJourney.zoneMap[WESTFALL] = nil

        Choose(2, "Westfall")

        assert.are_same({}, ListTexts())
        assert.is_true(SaysThereAreNone())
    end)

    it("should offer the zones again after a category without any", function()
        Open()
        Choose(1, "Mage")

        Choose(1, "Dungeons")

        assert.is_true(Dropdown(2):IsVisible())
        Choose(2, "The Deadmines")
        assert.are_same({"Quest 166"}, ListTexts())
    end)

    it("should close the details when another zone is chosen", function()
        Open()
        OpenQuest(54)
        assert.are.equal("Details of quest 54", Details())

        Choose(2, "Westfall")

        assert.is_nil(Details())
    end)

    it("should close the details when another category is chosen, also when neither has zones", function()
        Open()
        Choose(1, "All Quests")
        OpenQuest(1861)

        Choose(1, "Mage")

        assert.is_nil(Details())
    end)

    describe("opening a quest", function()
        before_each(Open)

        it("should select a quest that is listed already", function()
            OpenQuest(54)

            assert.are.equal("Details of quest 54", Details())
            assert.are_same({"Quest 54"}, ui.SelectedRowTexts(canvas, 1))
        end)

        it("should go to the zone of a quest", function()
            OpenQuest(4402)

            assert.are.equal("Details of quest 4402", Details())
            assert.are_same({"Quest 4402"}, ui.SelectedRowTexts(canvas, 1))
            assert.are_same({"Kalimdor", "Durotar"}, {Dropdown(1).text, Dropdown(2).text})
        end)

        it("should go to the quests of the player's class", function()
            OpenQuest(1861)

            assert.are_same({"Quest 1861"}, ui.SelectedRowTexts(canvas, 1))
            assert.are.equal("Mage", Dropdown(1).text)
        end)

        for name, questId in pairs({["isn't in any zone"] = 99999, ["is in a zone that isn't offered"] = 11000}) do
            it("should show a quest that " .. name .. ", and stay in this one", function()
                OpenQuest(questId)

                assert.are.equal("Details of quest " .. questId, Details())
                assert.are_same({"Quest 54"}, ListTexts())
                assert.are_same({}, ui.SelectedRowTexts(canvas, 1))
                assert.are.equal("Elwynn Forest", Dropdown(2).text)
            end)
        end
    end)
end)
