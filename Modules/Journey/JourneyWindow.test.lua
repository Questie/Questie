dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyWindow", function()
    ---@type JourneyWindow
    local JourneyWindow
    local ui
    local originalQuestie, originalGetUnitName, originalPlaySound
    local tabs, sounds, settingsOpened, focusCleared, opened

    ---What the window needs of a tab. Counts how often it is refreshed and selected.
    ---@param key string
    ---@param canShowQuests boolean
    local function CreateTab(key, canShowQuests)
        local tab = {refreshes = 0, selections = 0}
        tab.Build = function(canvas)
            assert(not tab.canvas, "the tab was built twice")
            tab.canvas = canvas
        end
        tab.Refresh = function()
            assert(tab.canvas:IsVisible(), "a tab that isn't visible was refreshed")
            tab.refreshes = tab.refreshes + 1
        end
        tab.OnSelected = function() tab.selections = tab.selections + 1 end
        if canShowQuests then
            tab.OpenQuest = function(questId) table.insert(opened, {key, questId}) end
        end
        tabs[key] = tab
        return tab
    end

    ---@return string[] tabKeys Of the canvases that are visible
    local function ShownTabs()
        local keys = {}
        for key, tab in pairs(tabs) do
            if tab.canvas and tab.canvas:IsVisible() then
                table.insert(keys, key)
            end
        end
        return keys
    end

    ---@return number
    local function CountBuiltTabs()
        local count = 0
        for _, tab in pairs(tabs) do
            if tab.canvas then count = count + 1 end
        end
        return count
    end

    ---@return Frame window
    local function FindWindow()
        return ui.FindByTemplate(UIParent, "PortraitFrameTemplate")[1]
    end

    ---@param tabKey string
    local function ClickTab(tabKey)
        local tab = ui.FindAll(FindWindow(), function(frame) return frame.name == "$parent_Tab_" .. tabKey end)[1]
        tab.button.scripts.OnClick(tab.button)
    end

    ---@return string[] tabKeys
    local function TabsMarkedAsSelected()
        local marked = {}
        for _, tab in ipairs(ui.FindAll(FindWindow(), function(frame) return frame.Selected ~= nil end)) do
            if tab.Selected:IsShown() then
                table.insert(marked, (tab.name:gsub("$parent_Tab_", "")))
            end
        end
        return marked
    end

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalGetUnitName, originalPlaySound = _G.Questie, _G.GetUnitName, _G.PlaySound
        _G.Questie = setmetatable({IsForever = true, db = {profile = {}}}, {__index = originalQuestie})
        _G.GetUnitName = function() return "Thrall" end
        sounds = 0
        _G.PlaySound = function() sounds = sounds + 1 end
        tabs, opened, settingsOpened, focusCleared = {}, {}, 0, 0

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsWindow.lua")

        local _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
        _QuestieJourney.myJourney = CreateTab("journey", false)
        _QuestieJourney.questsByZone = CreateTab("zone", true)
        _QuestieJourney.questsByFaction = CreateTab("faction", true)
        _QuestieJourney.search = CreateTab("search", false)
        _QuestieJourney.search.Open = function(kind, id) table.insert(opened, {kind, id}) end
        _QuestieJourney.search.ClearFocus = function() focusCleared = focusCleared + 1 end
        QuestieLoader:ImportModule("QuestieOptionsEngine").ShowFrame = function() settingsOpened = settingsOpened + 1 end

        dofile("Modules/Journey/JourneyWindow.lua")
        JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
    end)

    after_each(function()
        _G.Questie, _G.GetUnitName, _G.PlaySound = originalQuestie, originalGetUnitName, originalPlaySound
        ui.Restore()
    end)

    describe("before it is opened", function()
        it("should not exist", function()
            assert.is_nil(FindWindow())
            assert.are.equal(0, CountBuiltTabs())
            assert.is_false(JourneyWindow.IsShown())
        end)

        it("should not be created by hiding it", function()
            JourneyWindow.Hide()

            assert.is_nil(FindWindow())
        end)
    end)

    describe("opening", function()
        it("should show My Journey the first time", function()
            JourneyWindow.Show()

            assert.is_true(JourneyWindow.IsShown())
            assert.are_same({"journey"}, ShownTabs())
            assert.are.equal(1, tabs.journey.refreshes)
        end)

        it("should show the requested tab", function()
            JourneyWindow.Show("search")

            assert.are_same({"search"}, ShownTabs())
        end)

        it("should show the tab that was shown last", function()
            JourneyWindow.Show("zone")
            JourneyWindow.Hide()

            JourneyWindow.Show()

            assert.are_same({"zone"}, ShownTabs())
        end)

        it("should create nothing the second time", function()
            JourneyWindow.Show()
            local frameCount = #ui.frames
            JourneyWindow.Hide()

            JourneyWindow.Show()

            assert.are.equal(frameCount, #ui.frames)
        end)

        it("should keep the canvas of a tab instead of building it again", function()
            JourneyWindow.Show("zone")
            ClickTab("search")
            local frameCount = #ui.frames

            ClickTab("zone")
            ClickTab("search")

            assert.are.equal(frameCount, #ui.frames)
        end)

        it("should not create more and more when a tab can't be built", function()
            tabs.zone.Build = function() error("no such template") end
            pcall(JourneyWindow.Show, "zone")
            local frameCount = #ui.frames

            pcall(JourneyWindow.Show, "zone")

            assert.are.equal(frameCount, #ui.frames)
        end)

        it("should not build tabs that weren't shown yet", function()
            JourneyWindow.Show("zone")

            assert.are.equal(1, CountBuiltTabs())
        end)

        it("should refresh the tab, because its data can have changed", function()
            JourneyWindow.Show()
            JourneyWindow.Hide()

            JourneyWindow.Show()

            assert.are_same({"journey"}, ShownTabs())
            assert.are.equal(2, tabs.journey.refreshes)
        end)

        it("should keep the canvas inside the window, below the header", function()
            JourneyWindow.Show()

            local points = {}
            for index = 1, 2 do
                local point, relativeTo, _, x, y = tabs.journey.canvas:GetPoint(index)
                points[point] = {x = x, y = y}
                assert.are.equal(FindWindow().canvasContainer, relativeTo)
            end
            assert.is_true(points.TOPLEFT.x >= 0 and points.TOPLEFT.y < -20)
            assert.is_true(points.BOTTOMRIGHT.x <= 0 and points.BOTTOMRIGHT.y >= 0)
        end)

        -- The map is in the FULLSCREEN strata while it is maximized
        it("should be above the maximized map", function()
            JourneyWindow.Show()

            assert.are.equal("FULLSCREEN_DIALOG", FindWindow().frameStrata)
        end)

        it("should be resizable, but not too small for what is in it", function()
            JourneyWindow.Show()

            local grip = ui.FindByTemplate(FindWindow(), "PanelResizeButtonTemplate")[1]
            local width, height = FindWindow():GetSize()
            assert.is_true(grip.minWidth > 400 and grip.minWidth < width)
            assert.is_true(grip.minHeight > 300 and grip.minHeight < height)
        end)

        it("should leave room for its side tabs on a narrow screen", function()
            ui.screenWidth = 960

            JourneyWindow.Show()

            assert.are.equal(840, FindWindow():GetWidth())
        end)

        it("should only play a sound when it wasn't open", function()
            JourneyWindow.Show()
            JourneyWindow.Show("zone")
            assert.are.equal(1, sounds)

            JourneyWindow.Hide()
            JourneyWindow.Show()
            assert.are.equal(2, sounds)
        end)
    end)

    describe("closing", function()
        it("should be noticed when the window is hidden by something else, like the Escape key", function()
            JourneyWindow.Show()
            assert.are_same({"QuestieJourneyFrame"}, UISpecialFrames)

            FindWindow():Hide()
            assert.is_false(JourneyWindow.IsShown())

            JourneyWindow.Show()
            assert.is_true(JourneyWindow.IsShown())
        end)
    end)

    -- Otherwise movement keys keep being typed into the search box
    for name, find in pairs({
        ["the window"] = function(window) return window end,
        ["the title bar"] = function(window) return window.dragBar end,
        ["the resize grip"] = function(window) return window.resizeGrip end,
    }) do
        it("should end typing in the search when " .. name .. " is clicked", function()
            JourneyWindow.Show()
            local frame = find(FindWindow())

            frame.scripts.OnMouseDown(frame, "LeftButton")

            assert.are.equal(1, focusCleared)
        end)
    end

    describe("the side tabs", function()
        for _, tab in ipairs({
            {key = "journey", title = "My Journey"},
            {key = "zone", title = "Quests by Zone"},
            {key = "faction", title = "Quests by Faction"},
            {key = "search", title = "Advanced Search"},
        }) do
            it("should show " .. tab.title .. " instead of the tab before it", function()
                JourneyWindow.Show(tab.key == "zone" and "search" or "zone")

                ClickTab(tab.key)

                assert.are_same({tab.key}, ShownTabs())
                assert.are_same({tab.key}, TabsMarkedAsSelected())
                local pageTitles = ui.FindAll(FindWindow().canvasContainer, function(frame) return frame.frameType == "FontString" end)
                assert.are_same({tab.title}, {pageTitles[1].text})
            end)
        end

        it("should say so when the user switched to it or opened the window on it, but not when it is only refreshed", function()
            JourneyWindow.Show("search")
            assert.are.equal(1, tabs.search.selections)

            JourneyWindow.Refresh()
            assert.are.equal(1, tabs.search.selections)

            ClickTab("zone")
            ClickTab("search")
            assert.are.equal(2, tabs.search.selections)

            JourneyWindow.Hide()
            JourneyWindow.Show()
            assert.are.equal(3, tabs.search.selections)
        end)

        it("should know that it was selected before it is refreshed, so it can show something else then", function()
            local refreshesWhenSelected
            tabs.zone.OnSelected = function() refreshesWhenSelected = tabs.zone.refreshes end

            JourneyWindow.Show("zone")

            assert.are_same({0, 1}, {refreshesWhenSelected, tabs.zone.refreshes})
        end)

        it("should leave the shown tab alone when it is clicked again", function()
            JourneyWindow.Show("zone")

            ClickTab("zone")

            assert.are.equal(1, tabs.zone.refreshes)
        end)

        it("should lead to the settings", function()
            JourneyWindow.Show()

            ClickTab("settings")

            assert.is_false(JourneyWindow.IsShown())
            assert.are.equal(1, settingsOpened)
        end)
    end)

    describe("opening it again", function()
        it("should show what was shown before, up to date, but not as if the user had gone there", function()
            JourneyWindow.Show("search")
            JourneyWindow.Hide()

            JourneyWindow.ShowAgain()

            assert.is_true(JourneyWindow.IsShown())
            assert.are_same({"search"}, ShownTabs())
            assert.are_same({2, 1}, {tabs.search.refreshes, tabs.search.selections})
        end)

        it("should do nothing when the user did that already", function()
            JourneyWindow.Show("search")

            JourneyWindow.ShowAgain()

            assert.are.equal(1, tabs.search.refreshes)
        end)

        it("should not create a window that never existed", function()
            JourneyWindow.ShowAgain()

            assert.is_nil(FindWindow())
        end)
    end)

    describe("refreshing", function()
        it("should only refresh the tab that is shown", function()
            JourneyWindow.Show("zone")
            ClickTab("journey")

            JourneyWindow.Refresh()

            assert.are_same({1, 2}, {tabs.zone.refreshes, tabs.journey.refreshes})
        end)

        it("should do nothing while the window is closed, or doesn't exist", function()
            JourneyWindow.Refresh()
            assert.is_nil(FindWindow())

            JourneyWindow.Show()
            JourneyWindow.Hide()
            JourneyWindow.Refresh()
            assert.are.equal(1, tabs.journey.refreshes)
        end)
    end)

    describe("a link", function()
        for _, key in ipairs({"zone", "faction"}) do
            it("should show a quest in the tab the link is in, " .. key, function()
                JourneyWindow.Show(key)

                JourneyWindow.OpenLink("quest", 54)

                assert.are_same({{key, 54}}, opened)
                assert.are_same({key}, ShownTabs())
                assert.are.equal(1, tabs[key].refreshes)
            end)
        end

        it("should show a quest in the search from a tab that can't show any", function()
            JourneyWindow.Show("journey")

            JourneyWindow.OpenLink("quest", 54)

            assert.are_same({{"quest", 54}}, opened)
            assert.are_same({"search"}, ShownTabs())
        end)

        for _, kind in ipairs({"npc", "object", "item"}) do
            it("should show an " .. kind .. " in the search", function()
                JourneyWindow.Show("zone")

                JourneyWindow.OpenLink(kind, 299)

                assert.are_same({{kind, 299}}, opened)
                assert.are_same({"search"}, ShownTabs())
                assert.are_same({"search"}, TabsMarkedAsSelected())
            end)
        end

        it("should leave the search alone when the link is in it", function()
            JourneyWindow.Show("search")

            JourneyWindow.OpenLink("npc", 299)

            assert.are_same({{"npc", 299}}, opened)
            assert.are_same({1, 1}, {tabs.search.refreshes, tabs.search.selections})
        end)
    end)
end)
