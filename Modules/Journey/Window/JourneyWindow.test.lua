dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyWindow", function()
    ---@type JourneyWindow
    local JourneyWindow
    local ui
    local originalQuestie, originalGetUnitName, originalPlaySound, originalHistory
    local tabs, sounds, settingsOpened, opened, shownInQuests, sizes

    ---What the window needs of a tab. Counts how often it is refreshed and selected.
    ---@param key string
    local function CreateTab(key)
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
        originalHistory = _G.HISTORY
        _G.HISTORY = "History"
        sizes = {quests = {}, history = {}}
        _G.Questie = setmetatable({IsForever = true, db = {profile = {}, char = {journeyWindow = sizes}}}, {__index = originalQuestie})
        _G.GetUnitName = function() return "Thrall" end
        sounds = 0
        _G.PlaySound = function() sounds = sounds + 1 end
        tabs, opened, settingsOpened, shownInQuests = {}, {}, 0, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsWindow.lua")

        local _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
        _QuestieJourney.myJourney = CreateTab("history")
        _QuestieJourney.quests = CreateTab("quests")
        _QuestieJourney.quests.UseHeader = function() end
        _QuestieJourney.quests.Open = function(kind, id) table.insert(opened, {kind, id}) end
        for name, shown in pairs({ShowCurrentZone = "zone", ShowWatchedFaction = "faction", ShowSearch = "search"}) do
            _QuestieJourney.quests[name] = function()
                assert(tabs.quests.canvas:IsVisible(), "something was shown in the quests while they aren't")
                table.insert(shownInQuests, shown)
            end
        end
        QuestieLoader:ImportModule("QuestieOptionsEngine").ShowFrame = function() settingsOpened = settingsOpened + 1 end

        dofile("Modules/Journey/Window/JourneyWindow.lua")
        JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
    end)

    after_each(function()
        _G.Questie, _G.GetUnitName, _G.PlaySound = originalQuestie, originalGetUnitName, originalPlaySound
        _G.HISTORY = originalHistory
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
        it("should show the quests the first time", function()
            JourneyWindow.Show()

            assert.is_true(JourneyWindow.IsShown())
            assert.are_same({"quests"}, ShownTabs())
            assert.are.equal(1, tabs.quests.refreshes)
        end)

        it("should show the history when the journey is asked for", function()
            JourneyWindow.Show("journey")

            assert.are_same({"history"}, ShownTabs())
        end)

        for request, shown in pairs({zone = "zone", faction = "faction", search = "search"}) do
            it("should show what is asked for in the quests: " .. request, function()
                JourneyWindow.Show("journey")

                JourneyWindow.Show(request)

                assert.are_same({"quests"}, ShownTabs())
                assert.are_same({shown}, shownInQuests)
            end)
        end

        it("should show the tab that was shown last", function()
            JourneyWindow.Show("journey")
            JourneyWindow.Hide()

            JourneyWindow.Show()

            assert.are_same({"history"}, ShownTabs())
            assert.are_same({}, shownInQuests)
        end)

        it("should create nothing the second time", function()
            JourneyWindow.Show()
            local frameCount = #ui.frames
            JourneyWindow.Hide()

            JourneyWindow.Show()

            assert.are.equal(frameCount, #ui.frames)
        end)

        it("should keep the canvas of a tab instead of building it again", function()
            JourneyWindow.Show()
            ClickTab("history")
            local frameCount = #ui.frames

            ClickTab("quests")
            ClickTab("history")

            assert.are.equal(frameCount, #ui.frames)
        end)

        it("should not create more and more when a tab can't be built", function()
            tabs.history.Build = function() error("no such template") end
            pcall(JourneyWindow.Show, "journey")
            local frameCount = #ui.frames

            pcall(JourneyWindow.Show, "journey")

            assert.are.equal(frameCount, #ui.frames)
        end)

        it("should not build tabs that weren't shown yet", function()
            JourneyWindow.Show("journey")

            assert.are.equal(1, CountBuiltTabs())
        end)

        it("should refresh the tab, because its data can have changed", function()
            JourneyWindow.Show()
            JourneyWindow.Hide()

            JourneyWindow.Show()

            assert.are_same({"quests"}, ShownTabs())
            assert.are.equal(2, tabs.quests.refreshes)
        end)

        it("should keep the canvas inside the window, below the header", function()
            JourneyWindow.Show()

            local points = {}
            for index = 1, 2 do
                local point, relativeTo, _, x, y = tabs.quests.canvas:GetPoint(index)
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
            JourneyWindow.Show("journey")
            assert.are.equal(1, sounds)

            JourneyWindow.Hide()
            JourneyWindow.Show()
            assert.are.equal(2, sounds)
        end)
    end)

    describe("its size", function()
        it("should be what the character resized it to", function()
            sizes.width, sizes.height = 700, 500

            JourneyWindow.Show()

            assert.are_same({700, 500}, {FindWindow():GetSize()})
        end)

        it("should be saved for the character when the grip is let go", function()
            JourneyWindow.Show()
            local grip = ui.FindByTemplate(FindWindow(), "PanelResizeButtonTemplate")[1]

            grip:OnMouseDown()
            FindWindow():SetSize(720, 480)
            grip:OnMouseUp()

            assert.are_same({720, 480}, {sizes.width, sizes.height})
        end)

        it("should shrink to the screen, for a size saved at another UI scale, and keep what was saved", function()
            sizes.width, sizes.height = 2000, 1500

            JourneyWindow.Show()

            assert.are_same({ui.screenWidth - 120, 1000}, {FindWindow():GetSize()})
            assert.are_same({2000, 1500}, {sizes.width, sizes.height})
        end)

        it("should go back to the default, and forget the saved one, by double-clicking the grip", function()
            JourneyWindow.Show()
            local defaultWidth, defaultHeight = FindWindow():GetSize()
            sizes.width, sizes.height = 700, 500
            FindWindow():SetSize(700, 500)

            local grip = ui.FindByTemplate(FindWindow(), "PanelResizeButtonTemplate")[1]
            grip.scripts.OnDoubleClick(grip)

            assert.are_same({defaultWidth, defaultHeight}, {FindWindow():GetSize()})
            assert.is_nil(sizes.width)
            assert.is_nil(sizes.height)
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

    -- Otherwise movement keys keep being typed into a search box
    describe("clicking", function()
        local box

        before_each(function()
            JourneyWindow.Show()
            box = CreateFrame("EditBox", nil, tabs.quests.canvas)
            box:SetFocus()
        end)

        for name, find in pairs({
            ["the window"] = function(window) return window end,
            ["the title bar"] = function(window) return window.dragBar end,
            ["the resize grip"] = function(window) return window.resizeGrip end,
        }) do
            it("should end typing in the window when " .. name .. " is clicked", function()
                local frame = find(FindWindow())

                frame.scripts.OnMouseDown(frame, "LeftButton")

                assert.is_false(box:HasFocus())
            end)
        end

        it("should leave typing elsewhere alone", function()
            local chat = CreateFrame("EditBox", nil, UIParent)
            chat:SetFocus()

            FindWindow().scripts.OnMouseDown(FindWindow(), "LeftButton")

            assert.is_true(chat:HasFocus())
        end)
    end)

    describe("the side tabs", function()
        for _, tab in ipairs({{key = "quests", title = "Quests"}, {key = "history", title = "History"}}) do
            it("should show " .. tab.title .. " instead of the tab before it", function()
                JourneyWindow.Show(tab.key == "quests" and "journey" or nil)

                ClickTab(tab.key)

                assert.are_same({tab.key}, ShownTabs())
                assert.are_same({tab.key}, TabsMarkedAsSelected())
                local pageTitles = ui.FindAll(FindWindow().canvasContainer, function(frame) return frame.frameType == "FontString" end)
                assert.are_same({tab.title}, {pageTitles[1].text})
            end)
        end

        it("should say so when the user switched to it or opened the window on it, but not when it is only refreshed", function()
            JourneyWindow.Show()
            assert.are.equal(1, tabs.quests.selections)

            JourneyWindow.Refresh()
            assert.are.equal(1, tabs.quests.selections)

            ClickTab("history")
            ClickTab("quests")
            assert.are.equal(2, tabs.quests.selections)

            JourneyWindow.Hide()
            JourneyWindow.Show()
            assert.are.equal(3, tabs.quests.selections)
        end)

        it("should know that it was selected before it is refreshed, so it can show something else then", function()
            local refreshesWhenSelected
            tabs.history.OnSelected = function() refreshesWhenSelected = tabs.history.refreshes end

            JourneyWindow.Show("journey")

            assert.are_same({0, 1}, {refreshesWhenSelected, tabs.history.refreshes})
        end)

        it("should leave the shown tab alone when it is clicked again", function()
            JourneyWindow.Show("journey")

            ClickTab("history")

            assert.are.equal(1, tabs.history.refreshes)
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
            JourneyWindow.Show("journey")
            JourneyWindow.Hide()

            JourneyWindow.ShowAgain()

            assert.is_true(JourneyWindow.IsShown())
            assert.are_same({"history"}, ShownTabs())
            assert.are_same({2, 1}, {tabs.history.refreshes, tabs.history.selections})
        end)

        it("should do nothing when the user did that already", function()
            JourneyWindow.Show("journey")

            JourneyWindow.ShowAgain()

            assert.are.equal(1, tabs.history.refreshes)
        end)

        it("should not create a window that never existed", function()
            JourneyWindow.ShowAgain()

            assert.is_nil(FindWindow())
        end)
    end)

    describe("refreshing", function()
        it("should only refresh the tab that is shown", function()
            JourneyWindow.Show()
            ClickTab("history")

            JourneyWindow.Refresh()

            assert.are_same({1, 2}, {tabs.quests.refreshes, tabs.history.refreshes})
        end)

        it("should do nothing while the window is closed, or doesn't exist", function()
            JourneyWindow.Refresh()
            assert.is_nil(FindWindow())

            JourneyWindow.Show()
            JourneyWindow.Hide()
            JourneyWindow.Refresh()
            assert.are.equal(1, tabs.quests.refreshes)
        end)
    end)

    describe("a link", function()
        for _, kind in ipairs({"quest", "npc", "object", "item"}) do
            it("should show a " .. kind .. " in the quests, also from the history", function()
                JourneyWindow.Show("journey")

                JourneyWindow.OpenLink(kind, 299)

                assert.are_same({{kind, 299}}, opened)
                assert.are_same({"quests"}, ShownTabs())
                assert.are_same({"quests"}, TabsMarkedAsSelected())
            end)
        end

        it("should leave the quests alone when the link is in them", function()
            JourneyWindow.Show()

            JourneyWindow.OpenLink("npc", 299)

            assert.are_same({{"npc", 299}}, opened)
            assert.are_same({1, 1}, {tabs.quests.refreshes, tabs.quests.selections})
        end)
    end)
end)
