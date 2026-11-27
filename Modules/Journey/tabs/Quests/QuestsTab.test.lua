dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

-- The Quests tab, opened through the real window, with its real tabs, pages and lists. What is listed and the overview are
-- stubbed, as they have tests of their own.
describe("The Quests tab", function()
    ---@type JourneyWindow
    local JourneyWindow
    ---@type QuestieJourney
    local QuestieJourney
    local ui
    local originals
    local playerZone, barWidth, focusedSearches, factions, cursor, loads
    local keys, places

    local ELWYNN, WESTFALL, STORMWIND_CITY, DEADMINES, WARSONG = 12, 40, 1519, 1581, 3277
    local STORMWIND = 72
    local WOLVES, KOBOLDS, BOARS, DEFIAS, VANCLEEF = 7, 8, 9, 10, 11
    local NAMES = {[WOLVES] = "Wolves", [KOBOLDS] = "Kobolds", [BOARS] = "Boars", [DEFIAS] = "Defias", [VANCLEEF] = "VanCleef"}
    local GLOBALS = {
        "Questie", "GetUnitName", "GetCursorInfo", "ClearCursor",
        "HISTORY", "OVERVIEW", "ZONE", "FACTION", "LFG_TYPE_DUNGEON", "BATTLEGROUND",
    }

    ---@param questIds table<QuestId, string> The category of each quest
    ---@return JourneyTreeNode[] nodes
    ---@return number completed
    ---@return number total
    local function Collect(questIds)
        local nodes, byKey = {}, {}
        for index, category in ipairs({{"log", "Quest Log"}, {"available", "Available Quests"}, {"completed", "Completed Quests"}}) do
            nodes[index] = {value = category[1], text = category[2], children = {}}
            byKey[category[1]] = nodes[index]
        end
        local ids = {}
        for id in pairs(questIds) do table.insert(ids, id) end
        table.sort(ids)
        for _, id in ipairs(ids) do
            table.insert(byKey[questIds[id]].children, {value = id, text = NAMES[id]})
        end
        local completed = #byKey.completed.children
        return nodes, completed, completed + #byKey.available.children + #byKey.log.children
    end

    ---What the overview shows of a category, in its details: two zones it leads to.
    ---@param page JourneyPage.Instance
    ---@param selection JourneyPage.Selection
    ---@return JourneyDetails.Row[]?
    local function GetOverviewRows(page, selection)
        if selection.kind ~= "category" then
            return nil
        elseif selection.id == "search" then
            return {}
        end
        return {
            {type = "text", text = "Category " .. selection.id},
            {type = "step", text = "Westfall", onClick = function() page.onOpenSource("zone:" .. WESTFALL) end},
            {type = "step", text = "The Deadmines", onClick = function() page.onOpenSource("zone:" .. DEADMINES) end},
        }
    end

    local function StubWhatIsListed()
        -- Every quest sort the tab asks for has an ID of its own, as in the database
        local sortIds = 1000
        QuestieLoader:ImportModule("QuestieDB").sortKeys = setmetatable({}, {__index = function(sortKeys, name)
            sortIds = sortIds + 1
            rawset(sortKeys, name, -sortIds)
            return -sortIds
        end})
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return {Id = id} end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest) return {{type = "text", text = "Quest " .. quest.Id}} end
        QuestieLoader:ImportModule("JourneyEntityDetails").GetRows = function(kind, id) return {{type = "text", text = kind .. " " .. id}} end
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function() end
        QuestieLoader:ImportModule("JourneyQuestCategories").Collect = Collect
        local JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
        JourneyFactions.Arrange = function() return {} end
        JourneyFactions.GetRows = function(factionId) return {{type = "text", text = "Reputation with " .. factionId}} end

        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.ExpandFactionHeader = function() end
        QuestieCompat.GetNumFactions = function() return #factions end
        QuestieCompat.GetFactionInfo = function(index)
            local faction = factions[index]
            return faction.name, "", 4, 0, 3000, 0, false, false, faction.isHeader, false, false, faction.isWatched, false, faction.id
        end

        local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
        JourneyPlaces.Split = function(source)
            local kind, id = source:match("^(%a+):(%-?%d+)$")
            return kind or source, tonumber(id)
        end
        JourneyPlaces.GetName = function(source) return places[source].name end
        JourneyPlaces.GetGroupOf = function(zoneId) return places["zone:" .. zoneId].group end
        JourneyPlaces.IsContinent = function(groupId) return groupId == keys.EASTERN_KINGDOMS end
        JourneyPlaces.GetGroupName = function(groupId) return ({[keys.CLASS] = "Class", [keys.PROFESSIONS] = "Professions"})[groupId] end
        JourneyPlaces.GetPlayerZone = function() return playerZone end
        JourneyPlaces.GetQuestIds = function(source)
            loads[source] = (loads[source] or 0) + 1
            return places[source].quests or {}
        end
    end

    local function StubTheOverview()
        local JourneyOverviewPage = QuestieLoader:ImportModule("JourneyOverviewPage")
        JourneyOverviewPage.SEARCH, JourneyOverviewPage.GOOD, JourneyOverviewPage.FACTIONS = "search", "good", "factions"
        JourneyOverviewPage.FACTIONS_PICTURE, JourneyOverviewPage.ALL_PICTURE = "reputation.png", 133741
        JourneyOverviewPage.GetClassPicture = function(classFile) return {atlas = "classicon-" .. classFile:lower()} end
        JourneyOverviewPage.GetGroupPicture = function(groupId) return "picture of group " .. groupId end
        JourneyOverviewPage.Load = function(page)
            page.selection = page.selection or {kind = "category", id = "good"}
        end
        JourneyOverviewPage.GetRows = GetOverviewRows
        JourneyOverviewPage.IsSearchShown = function(page)
            return page.selection ~= nil and (page.selection.kind ~= "category" or page.selection.id == "search")
        end
        JourneyOverviewPage.FocusSearch = function(_, text) table.insert(focusedSearches, text or "") end
    end

    before_each(function()
        ui = FakeUI.Install()
        originals = {}
        for _, name in ipairs(GLOBALS) do
            originals[name] = {value = _G[name]}
        end
        _G.HISTORY, _G.OVERVIEW, _G.ZONE, _G.FACTION = "History", "Overview", "Zone", "Faction"
        _G.LFG_TYPE_DUNGEON, _G.BATTLEGROUND = "Dungeon", "Battleground"
        _G.GetUnitName = function() return "Thrall" end
        cursor = nil
        _G.GetCursorInfo = function()
            if cursor then return cursor.type, cursor.id, cursor.link end
        end
        _G.ClearCursor = function() cursor = nil end
        _G.Questie = {
            started = true,
            IsForever = true,
            db = {char = {journeyWindow = {quests = {}, history = {}}}, profile = {}},
            Error = function(prefix, message) error(tostring(prefix) .. " " .. tostring(message)) end,
            Colorize = function(_, text) return text end,
        }
        playerZone, barWidth, focusedSearches, factions, loads = ELWYNN, 1500, {}, {}, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        StubWhatIsListed()
        StubTheOverview()
        QuestieLoader:ImportModule("QuestieOptionsEngine").ShowFrame = function() end
        local _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
        _QuestieJourney.myJourney = {Build = function() end, Refresh = function() end}
        for _, path in ipairs({
            "Libs/ThreadLib", "Options/QuestieOptionsUtils", "Options/QuestieOptionsControls", "Options/QuestieOptionsWindow",
            "Journey/QuestieJourney", "Journey/Data/JourneyThread", "Journey/Window/JourneyWindow", "Journey/Window/JourneyPanes", "Journey/Window/JourneyScrollBox",
            "Journey/Window/JourneyIcon", "Journey/Window/JourneyList", "Journey/Window/JourneyTree", "Journey/Details/JourneyDetails", "Journey/tabs/Quests/JourneyPage",
            "Journey/tabs/Quests/JourneyQuestsPage", "Journey/tabs/Quests/JourneyOverviewRows", "Journey/tabs/Quests/JourneyTabBar", "Journey/tabs/Quests/QuestsTab",
        }) do
            dofile("Modules/" .. path .. ".lua")
        end
        JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        keys = QuestieJourney.questCategoryKeys
        QuestieJourney.factionMap = {[STORMWIND] = {}}

        local sorts = QuestieLoader:ImportModule("QuestieDB").sortKeys
        places = {
            ["zone:" .. ELWYNN] = {name = "Elwynn Forest", group = keys.EASTERN_KINGDOMS,
                quests = {[WOLVES] = "available", [KOBOLDS] = "available", [BOARS] = "completed"}},
            ["zone:" .. WESTFALL] = {name = "Westfall", group = keys.EASTERN_KINGDOMS, quests = {[DEFIAS] = "available"}},
            ["zone:" .. STORMWIND_CITY] = {name = "Stormwind City", group = keys.EASTERN_KINGDOMS},
            ["zone:" .. DEADMINES] = {name = "The Deadmines", group = keys.DUNGEONS, quests = {[VANCLEEF] = "available"}},
            ["zone:" .. WARSONG] = {name = "Warsong Gulch", group = keys.BATTLEGROUNDS},
            ["zone:" .. sorts.MAGE] = {name = "Mage", group = keys.CLASS},
            ["zone:" .. sorts.ALCHEMY] = {name = "Alchemy", group = keys.PROFESSIONS},
            ["faction:" .. STORMWIND] = {name = "Stormwind", quests = {[WOLVES] = "available"}},
        }
    end)

    after_each(function()
        for name, original in pairs(originals) do
            _G[name] = original.value
        end
        ui.Restore()
    end)

    ---@return table window
    local function Window()
        return ui.FindByTemplate(UIParent, "PortraitFrameTemplate")[1]
    end

    ---@return table bar
    local function Bar()
        return ui.FindAll(Window(), function(frame) return frame.findTab ~= nil end)[1]
    end

    ---Opens the window, like the key binding does.
    ---@param request string? What JourneyWindow.Show is asked for
    local function Open(request)
        JourneyWindow.Show(request)
        -- The bar is as wide as the space next to the title, once the tab was shown. The fake UI doesn't lay out frames.
        local bar = Bar()
        if bar then
            bar:SetWidth(barWidth)
        end
        ui.RunUntilIdle()
    end

    ---Like the button on the world map does.
    ---@param source string
    local function OpenSource(source)
        QuestieJourney.OpenSource(source)
        ui.RunUntilIdle()
    end

    ---@return table[] buttons Of the tabs, from left to right
    local function TabButtons()
        local buttons = {}
        for _, frame in ipairs(ui.FindAll(Bar(), function(frame) return frame.Label ~= nil end)) do
            if frame:IsShown() then table.insert(buttons, frame) end
        end
        return buttons
    end

    ---@return string[]
    local function TabNames()
        local names = {}
        for _, button in ipairs(TabButtons()) do table.insert(names, button.Text.text) end
        return names
    end

    ---@param name string
    ---@return table button
    local function TabButton(name)
        for _, button in ipairs(TabButtons()) do
            if button.Text.text == name then return button end
        end
        error("There is no tab " .. name)
    end

    ---@return string? name Of the tab that looks selected
    local function SelectedTab()
        for _, button in ipairs(TabButtons()) do
            if button.Left.atlas == "Options_Tab_Active_Left" then return button.Text.text end
        end
    end

    ---@return string? shown "search" or "overview" while the find tab is lit up for either
    local function ShownFind()
        local findTab = Bar().findTab
        return findTab.Search.Icon.alpha == 1 and "search" or findTab.Plus.Icon.alpha == 1 and "overview" or nil
    end

    ---@param name string
    local function ClickTab(name)
        TabButton(name):Click()
        ui.RunUntilIdle()
    end

    ---@return table[] rows On screen, of the lists that are shown. Those of the details have their row as data.
    local function VisibleRows(isDetails)
        local rows = {}
        for _, list in ipairs(ui.FindByTemplate(Window(), "WowScrollBoxList")) do
            if list:IsVisible() then
                for _, row in ipairs(list.rowFrames) do
                    if (type(row.elementData) == "table") == isDetails then table.insert(rows, row) end
                end
            end
        end
        return rows
    end

    ---@return string[]
    local function ListTexts()
        local texts = {}
        for _, row in ipairs(VisibleRows(false)) do table.insert(texts, row.Label.text) end
        return texts
    end

    ---@return string[]
    local function SelectedTexts()
        local texts = {}
        for _, row in ipairs(VisibleRows(false)) do
            if row.Background:IsShown() and row.Background.atlas == "Options_List_Active" then table.insert(texts, row.Label.text) end
        end
        return texts
    end

    ---@param text string
    local function ClickRow(text)
        for _, row in ipairs(VisibleRows(false)) do
            if row.Label.text == text then
                row:Click()
                return ui.RunUntilIdle()
            end
        end
        error("There is no row " .. text)
    end

    ---@return string[]
    local function Details()
        local texts = {}
        for _, row in ipairs(VisibleRows(true)) do table.insert(texts, row.elementData.text) end
        return texts
    end

    ---@param text string
    local function ClickDetails(text)
        for _, row in ipairs(VisibleRows(true)) do
            if row.elementData.text == text then
                row.elementData.onClick()
                return ui.RunUntilIdle()
            end
        end
        error("There are no details " .. text)
    end

    ---@param direction string "PrevPage" or "NextPage", the arrows of the spellbook
    ---@return table button
    local function HistoryButton(direction)
        local path = "Interface\\Buttons\\UI-SpellbookIcon-" .. direction .. "-Up"
        return ui.FindAll(Window(), function(frame) return frame.normalTexture == path end)[1]
    end

    local function Back()
        HistoryButton("PrevPage"):Click()
        ui.RunUntilIdle()
    end

    local function Forward()
        HistoryButton("NextPage"):Click()
        ui.RunUntilIdle()
    end

    ---@return boolean canGoBack
    ---@return boolean canGoForward
    local function History()
        return HistoryButton("PrevPage"):IsEnabled(), HistoryButton("NextPage"):IsEnabled()
    end

    ---@return table bar Of the progress
    local function ProgressBar()
        return ui.FindAll(Window(), function(frame) return frame.frameType == "StatusBar" end)[1]
    end

    describe("opening", function()
        it("should show the zone the player is in, in a tab that can't be closed", function()
            Open()

            assert.are_same({"Elwynn Forest"}, TabNames())
            local here = TabButton("Elwynn Forest")
            assert.are_same({"Current Zone", true, false}, {here.Label.text, here.Here:IsShown(), here.Close:IsShown()})
            assert.are_same({"Available Quests", "Wolves", "Kobolds", "Completed Quests"}, ListTexts())
            assert.are_same({"Wolves"}, SelectedTexts())
            assert.are_same({"Quest 7"}, Details())
        end)

        it("should show how many quests of the shown tab were completed", function()
            Open()
            local bar = ProgressBar()
            assert.are_same({"1 of 3 completed", 1 / 3, true}, {bar.Text.text, bar.value, bar.Background:IsShown()})

            OpenSource("zone:" .. WARSONG)

            assert.are_same({"", 0, false}, {bar.Text.text, bar.value, bar.Background:IsShown()})
        end)
    end)

    describe("a place that is opened", function()
        before_each(function()
            Open()
        end)

        it("should get a tab of its own behind the others, which is shown", function()
            OpenSource("zone:" .. WESTFALL)

            assert.are_same({"Elwynn Forest", "Westfall"}, TabNames())
            assert.are.equal("Westfall", SelectedTab())
            assert.is_true(TabButton("Westfall").Close:IsShown())
            assert.are_same({"Available Quests", "Defias"}, ListTexts())
        end)

        it("should be shown in the tab it has already", function()
            OpenSource("zone:" .. WESTFALL)
            OpenSource("zone:" .. DEADMINES)

            OpenSource("zone:" .. WESTFALL)

            assert.are_same({"Elwynn Forest", "Westfall", "The Deadmines"}, TabNames())
            assert.are.equal("Westfall", SelectedTab())
        end)

        it("should be shown in the last tab when there is no room for another, instead of what that showed", function()
            local JourneyTabBar = QuestieLoader:ImportModule("JourneyTabBar")
            local sorts = QuestieLoader:ImportModule("QuestieDB").sortKeys
            local sources = {}
            for _, zoneId in ipairs({WESTFALL, STORMWIND_CITY, WARSONG, sorts.MAGE, sorts.ALCHEMY}) do
                table.insert(sources, "zone:" .. zoneId)
            end
            Bar():SetWidth(600)
            local openedCount = 0
            while JourneyTabBar.HasRoom(Bar()) do
                openedCount = openedCount + 1
                OpenSource(sources[openedCount])
            end
            local names = TabNames()
            assert.is_true(#names > 2, "the last one isn't the only one that can be closed")

            OpenSource("zone:" .. DEADMINES)

            names[#names] = "The Deadmines"
            assert.are_same(names, TabNames())
            assert.are_same({"Available Quests", "VanCleef"}, ListTexts())
        end)

        for _, case in ipairs({
            {place = "a zone", source = "zone:" .. WESTFALL, label = "Zone", picture = "picture of group 1"},
            {place = "a capital city", source = "zone:" .. STORMWIND_CITY, label = "Zone", picture = 135763}, -- Its teleport
            {place = "a dungeon", source = "zone:" .. DEADMINES, label = "Dungeon", picture = "picture of group 9"},
            {place = "a battleground", source = "zone:" .. WARSONG, label = "Battleground", picture = "picture of group 10"},
            {place = "a class", sort = "MAGE", label = "Class", picture = "classicon-mage"},
            {place = "a profession", sort = "ALCHEMY", label = "Professions", picture = 136240}, -- Trade_Alchemy
            {place = "a faction", source = "faction:" .. STORMWIND, label = "Faction", picture = "reputation.png"},
        }) do
            it("should show what kind of place it is, with a picture of it: " .. case.place, function()
                local source = case.source or "zone:" .. QuestieLoader:ImportModule("QuestieDB").sortKeys[case.sort]

                OpenSource(source)

                local button = TabButton(places[source].name)
                assert.are_same({case.label, case.picture}, {button.Label.text, button.Picture.atlas or button.Picture.texture})
                assert.is_false(button.Here:IsShown())
            end)
        end
    end)

    describe("closing a tab", function()
        before_each(function()
            Open()
            OpenSource("zone:" .. WESTFALL)
            OpenSource("zone:" .. DEADMINES)
            OpenSource("zone:" .. WARSONG)
        end)

        it("should show the tab behind it, or the one before it when it was the last one", function()
            ClickTab("Westfall")

            TabButton("Westfall").Close:Click()
            assert.are_same({"Elwynn Forest", "The Deadmines", "Warsong Gulch"}, TabNames())
            assert.are.equal("The Deadmines", SelectedTab())
            assert.are_same({"Available Quests", "VanCleef"}, ListTexts())

            ClickTab("Warsong Gulch")
            TabButton("Warsong Gulch").Close:Click()
            assert.are.equal("The Deadmines", SelectedTab())
        end)

        it("should leave the tab that is shown alone when another one is closed", function()
            TabButton("Westfall").Close:Click()

            assert.are_same({"Elwynn Forest", "The Deadmines", "Warsong Gulch"}, TabNames())
            assert.are.equal("Warsong Gulch", SelectedTab())
        end)

        it("should leave nothing of it to the next tab", function()
            ClickTab("Westfall")
            JourneyWindow.OpenLink("npc", 299)
            TabButton("Westfall").Close:Click()

            OpenSource("zone:" .. WESTFALL)

            assert.are_same({"Defias"}, SelectedTexts())
            assert.are_same({"Quest 10"}, Details())
            assert.are_same({false, false}, {History()})
        end)

        -- Some places have thousands of quests
        it("should stop what its list was being filled with", function()
            QuestieJourney.OpenSource("zone:" .. STORMWIND_CITY)

            TabButton("Stormwind City").Close:Click()
            ui.RunUntilIdle()

            assert.is_nil(loads["zone:" .. STORMWIND_CITY])
        end)

        it("should create nothing for the next tab", function()
            TabButton("Westfall").Close:Click()
            local frameCount = #ui.frames

            TabButton("The Deadmines").Close:Click()
            OpenSource("zone:" .. WESTFALL)
            OpenSource("zone:" .. DEADMINES)

            assert.are.equal(frameCount, #ui.frames)
        end)
    end)

    describe("the zone the player is in", function()
        it("should be the one the player went to when the window is opened again", function()
            Open()
            playerZone = WESTFALL
            JourneyWindow.Hide()

            Open()

            assert.are_same({"Westfall"}, TabNames())
            assert.are.equal("Current Zone", TabButton("Westfall").Label.text)
            assert.are_same({"Available Quests", "Defias"}, ListTexts())
        end)

        -- The window is refreshed whenever a quest changes, while the player is using the list
        it("should stay the same while the window is open", function()
            Open()
            playerZone = WESTFALL

            JourneyWindow.Refresh()
            ui.RunUntilIdle()

            assert.are_same({"Elwynn Forest"}, TabNames())
            assert.are_same({"Available Quests", "Wolves", "Kobolds", "Completed Quests"}, ListTexts())
        end)

        it("should be shown when the zone is asked for", function()
            Open()
            OpenSource("zone:" .. WESTFALL)

            Open("zone")

            assert.are.equal("Elwynn Forest", SelectedTab())
            assert.are_same({"Available Quests", "Wolves", "Kobolds", "Completed Quests"}, ListTexts())
        end)
    end)

    describe("back and forward", function()
        it("should go through what was shown in the tab", function()
            Open()
            ClickRow("Kobolds")
            assert.are_same({true, false}, {History()})

            Back()
            assert.are_same({"Quest 7"}, Details())
            assert.are_same({"Wolves"}, SelectedTexts())
            assert.are_same({false, true}, {History()})

            Forward()
            assert.are_same({"Quest 8"}, Details())
        end)

        it("should be about the tab that is shown", function()
            Open()
            ClickRow("Kobolds")

            OpenSource("zone:" .. WESTFALL)

            assert.are_same({false, false}, {History()})
        end)

        it("should go back from a link, which is opened in the tab that is shown", function()
            Open()
            OpenSource("zone:" .. WESTFALL)

            JourneyWindow.OpenLink("npc", 299)
            assert.are.equal("Westfall", SelectedTab())
            assert.are_same({"npc 299"}, Details())
            assert.are_same({}, SelectedTexts())

            Back()
            assert.are_same({"Quest 10"}, Details())
        end)

        it("should show a link of the history in the quests", function()
            Open("journey")

            JourneyWindow.OpenLink("quest", KOBOLDS)
            ui.RunUntilIdle()

            assert.are_same({"Quest 8"}, Details())
            assert.are_same({"Kobolds"}, SelectedTexts())
        end)
    end)

    describe("a tab the overview opened", function()
        before_each(function()
            Open()
            Bar().findTab.Plus:Click()
            ui.RunUntilIdle()
        end)

        it("should lead back to the overview, and be closed then, like it was never opened", function()
            ClickDetails("Westfall")
            assert.are_same({"Elwynn Forest", "Westfall"}, TabNames())
            assert.are_same({true, false}, {History()})

            Back()

            assert.are_same({"Elwynn Forest"}, TabNames())
            assert.are.equal("overview", ShownFind())
            assert.are_same({"Category good", "Westfall", "The Deadmines"}, Details())
        end)

        it("should go back through what it showed before it leads back to the overview", function()
            ClickDetails("Westfall")
            JourneyWindow.OpenLink("npc", 299)

            Back()
            assert.are_same({"Quest 10"}, Details())
            assert.are_same({"Elwynn Forest", "Westfall"}, TabNames())

            Back()
            assert.are_same({"Elwynn Forest"}, TabNames())
        end)

        it("should only be shown when it was open already, so it doesn't lead back to the overview", function()
            ClickDetails("Westfall")
            Back()
            OpenSource("zone:" .. WESTFALL)
            Bar().findTab.Plus:Click()
            ui.RunUntilIdle()

            ClickDetails("Westfall")

            assert.are.equal("Westfall", SelectedTab())
            assert.are_same({false, false}, {History()})
        end)
    end)

    it("should lead back to the part of the overview that opened the tab", function()
        Open("faction") -- No faction is watched
        assert.are_same({"Category factions", "Westfall", "The Deadmines"}, Details())
        ClickDetails("Westfall")

        Back()

        assert.are_same({"Category factions", "Westfall", "The Deadmines"}, Details())
    end)

    describe("the find tab", function()
        before_each(function()
            Open()
        end)

        it("should open the search with its magnifier, with the cursor in it", function()
            Bar().findTab.Search:Click()
            ui.RunUntilIdle()

            assert.are.equal("search", ShownFind())
            assert.is_nil(SelectedTab())
            assert.are_same({""}, focusedSearches)
            assert.are_same({}, ListTexts())
        end)

        it("should open the search when it is asked for", function()
            Open("search")

            assert.are.equal("search", ShownFind())
            assert.are_same({""}, focusedSearches)
        end)

        it("should search for an item that is dropped on the magnifier", function()
            cursor = {type = "item", id = 2589, link = "[Linen Cloth]"}

            Bar().findTab.Search.scripts.OnReceiveDrag(Bar().findTab.Search)

            assert.are.equal("search", ShownFind())
            assert.are_same({"[Linen Cloth]"}, focusedSearches)
        end)

        it("should open the overview with its plus", function()
            Bar().findTab.Plus:Click()
            ui.RunUntilIdle()

            assert.are.equal("overview", ShownFind())
            assert.is_nil(SelectedTab())
            assert.are_same({"Category good", "Westfall", "The Deadmines"}, Details())
        end)

        it("should start the overview anew with its plus, like a new tab of a browser", function()
            Bar().findTab.Search:Click()
            JourneyWindow.OpenLink("npc", 299)
            assert.are_same({"npc 299"}, Details())

            Bar().findTab.Plus:Click()
            ui.RunUntilIdle()

            assert.are_same({"Category good", "Westfall", "The Deadmines"}, Details())
            assert.are_same({false, false}, {History()})
        end)

        it("should leave the overview for a tab that is clicked", function()
            Bar().findTab.Plus:Click()
            ui.RunUntilIdle()

            ClickTab("Elwynn Forest")

            assert.is_nil(ShownFind())
            assert.are.equal("Elwynn Forest", SelectedTab())
            assert.are_same({"Quest 7"}, Details())
        end)
    end)

    describe("the faction that is asked for", function()
        it("should be the one the player watches", function()
            factions = {
                {name = "Alliance", isHeader = true, id = 469},
                {name = "Stormwind", isWatched = true, id = STORMWIND},
            }

            Open("faction")

            assert.are_same({"Elwynn Forest", "Stormwind"}, TabNames())
            assert.are.equal("Stormwind", SelectedTab())
            assert.are_same({"Overview"}, SelectedTexts())
            assert.are_same({"Reputation with 72"}, Details())
        end)

        it("should be chosen in the overview when the watched one has no quests", function()
            factions = {{name = "Booty Bay", isWatched = true, id = 21}}

            Open("faction")

            assert.are_same({"Elwynn Forest"}, TabNames())
            assert.are.equal("overview", ShownFind())
            assert.are_same({"Category factions", "Westfall", "The Deadmines"}, Details())
        end)
    end)
end)
