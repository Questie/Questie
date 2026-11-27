dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyTabBar", function()
    ---@type JourneyTabBar
    local JourneyTabBar
    local ui
    local originals
    local bar, searched, added, events, cursor

    local LONG_NAME = "The Ruins of an Old Keep That Has a Very Long Name"

    before_each(function()
        ui = FakeUI.Install()
        originals = {}
        for _, name in ipairs({"GetCursorInfo", "ClearCursor"}) do
            originals[name] = {value = _G[name]}
        end
        cursor = nil
        _G.GetCursorInfo = function()
            if cursor then return cursor.type, cursor.id, cursor.link end
        end
        _G.ClearCursor = function() cursor = nil end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Window/JourneyScrollBox.lua")
        dofile("Modules/Journey/Details/JourneyDetails.lua")
        dofile("Modules/Journey/tabs/Quests/JourneyOverviewRows.lua")
        dofile("Modules/Journey/tabs/Quests/JourneyTabBar.lua")
        JourneyTabBar = QuestieLoader:ImportModule("JourneyTabBar")

        searched, added, events = {}, 0, {}
        bar = JourneyTabBar.Create(CreateFrame("Frame", nil, UIParent), function(itemLink)
            table.insert(searched, itemLink or "nothing")
        end, function() added = added + 1 end)
        bar:SetWidth(1000)
    end)

    after_each(function()
        for name, original in pairs(originals) do
            _G[name] = original.value
        end
        ui.Restore()
    end)

    ---A tab that can be closed. What happens to it is in events.
    ---@param name string
    ---@param fields table? Overrides
    ---@return JourneyTabBar.Tab
    local function Tab(name, fields)
        local tab = {
            name = name,
            picture = 136240,
            isHere = false,
            label = "Zone",
            isSelected = false,
            onSelect = function() table.insert(events, "select " .. name) end,
            onClose = function() table.insert(events, "close " .. name) end,
        }
        for key, value in pairs(fields or {}) do
            tab[key] = value
        end
        return tab
    end

    ---@param name string
    ---@return JourneyTabBar.Tab tab One that can't be closed, like the one of the player's zone
    local function FixedTab(name)
        local tab = Tab(name)
        tab.onClose = nil
        return tab
    end

    ---@return table[] buttons The tabs that are shown, from left to right
    local function Buttons()
        local buttons = {}
        for _, frame in ipairs(ui.FindAll(bar, function(frame) return frame.Label ~= nil end)) do
            if frame:IsShown() then
                table.insert(buttons, frame)
            end
        end
        return buttons
    end

    ---@param name string
    ---@return table button
    local function Button(name)
        for _, button in ipairs(Buttons()) do
            if button.Text.text == name then
                return button
            end
        end
        error("There is no tab " .. name)
    end

    ---@return string[]
    local function ShownNames()
        local names = {}
        for _, button in ipairs(Buttons()) do
            table.insert(names, button.Text.text)
        end
        return names
    end

    ---@param frame table
    ---@return number x Of its left edge in the bar
    local function GetX(frame)
        for index = 1, #frame.points do
            local point, relativeTo, _, x = frame:GetPoint(index)
            if point == "BOTTOMLEFT" and relativeTo == bar then
                return x
            end
        end
        error("It isn't placed in the bar")
    end

    ---@param frame table
    ---@return number x Of its right edge in the bar
    local function GetRight(frame)
        return GetX(frame) + frame:GetWidth()
    end

    describe("a tab", function()
        it("should show the name, a picture, and below the name what kind of place it is", function()
            JourneyTabBar.SetTabs(bar, {Tab("Westfall", {picture = 136240, label = "Zone"})})

            local button = Button("Westfall")
            assert.are.equal(136240, button.Picture.texture)
            assert.is_true(button.Label:IsShown())
            assert.are.equal("Zone", button.Label.text)
        end)

        it("should only show a label when there is one", function()
            JourneyTabBar.SetTabs(bar, {Tab("Westfall", {label = "Zone"})})

            JourneyTabBar.SetTabs(bar, {Tab("All Quests", {label = ""})})

            assert.is_false(Button("All Quests").Label:IsShown())
        end)

        -- Icons have a frame of their own, which is cut off and replaced by the black one
        it("should show an atlas whole, without the black frame behind icons", function()
            JourneyTabBar.SetTabs(bar, {Tab("Westfall"), Tab("Mage", {picture = {atlas = "classicon-mage"}})})

            assert.is_true(Button("Westfall").Frame:IsShown())
            assert.are.equal("classicon-mage", Button("Mage").Picture.atlas)
            assert.is_false(Button("Mage").Frame:IsShown())
        end)

        it("should mark the zone the player is in, and no other", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest", {isHere = true}), Tab("Westfall")})
            assert.are_same({true, false}, {Button("Elwynn Forest").Here:IsShown(), Button("Westfall").Here:IsShown()})

            -- The buttons are reused for other tabs
            JourneyTabBar.SetTabs(bar, {Tab("Westfall"), Tab("Elwynn Forest", {isHere = true})})
            assert.are_same({false, true}, {Button("Westfall").Here:IsShown(), Button("Elwynn Forest").Here:IsShown()})
        end)

        it("should look selected, and stand out above the others, only while it is selected", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall", {isSelected = true})})

            local selected, other = Button("Westfall"), Button("Elwynn Forest")
            assert.are_same({"Options_Tab_Active_Left", "Options_Tab_Left"}, {selected.Left.atlas, other.Left.atlas})
            assert.is_true(selected:GetHeight() > other:GetHeight())
            assert.are_same({"GameFontHighlight", "GameFontNormal"}, {selected.Text.fontObject, other.Text.fontObject})
        end)

        it("should be selected when it is clicked", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall")})

            Button("Westfall"):Click()

            assert.are_same({"select Westfall"}, events)
        end)

        it("should be closed with its X", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall")})

            Button("Westfall").Close:Click()

            assert.are_same({"close Westfall"}, events)
        end)

        it("should be closed with the middle mouse button, like in a browser", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall")})

            Button("Westfall"):Click("MiddleButton")

            assert.are_same({"close Westfall"}, events)
        end)

        it("should have no X when it can't be closed, and not be selected by the middle mouse button either", function()
            JourneyTabBar.SetTabs(bar, {FixedTab("Elwynn Forest"), Tab("Westfall")})

            assert.is_false(Button("Elwynn Forest").Close:IsShown())
            assert.is_true(Button("Westfall").Close:IsShown())
            Button("Elwynn Forest"):Click("MiddleButton")
            assert.are_same({}, events)
        end)

        it("should have an X that fills its button, so it is as big as where it can be clicked", function()
            JourneyTabBar.SetTabs(bar, {Tab("Westfall")})

            local close = Button("Westfall").Close
            local x = ui.FindAll(close, function(frame) return frame.texture == "Interface\\FriendsFrame\\ClearBroadcastIcon" end)[1]
            local points = {}
            for index = 1, #x.points do
                local point, relativeTo, relativePoint, offsetX, offsetY = x:GetPoint(index)
                points[point] = {relativeTo == close, relativePoint, offsetX or 0, offsetY or 0}
            end
            assert.are_same({true, "TOPLEFT", 0, 0}, points.TOPLEFT)
            assert.are_same({true, "BOTTOMRIGHT", 0, 0}, points.BOTTOMRIGHT)
        end)

        it("should show the whole name in a tooltip while it is cut off", function()
            JourneyTabBar.SetTabs(bar, {Tab(LONG_NAME)})
            local button = Button(LONG_NAME)

            button.scripts.OnEnter(button)
            assert.is_false(GameTooltip:IsShown())
            button.scripts.OnLeave(button)

            ui.isTextTruncated = true
            button.scripts.OnEnter(button)
            assert.is_true(GameTooltip:IsShown())
            assert.is_true(GameTooltip:IsOwned(button))
            assert.are.equal(LONG_NAME, GameTooltip.text)
        end)

        it("should be lit up while the mouse is on it", function()
            JourneyTabBar.SetTabs(bar, {Tab("Westfall")})
            local button = Button("Westfall")

            button.scripts.OnEnter(button)
            assert.are.equal("GameFontHighlight", button.Text.fontObject)

            button.scripts.OnLeave(button)
            assert.are.equal("GameFontNormal", button.Text.fontObject)
        end)
    end)

    describe("the tabs", function()
        it("should be shown in their order, and only those that are there now", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall"), Tab("Duskwood")})

            JourneyTabBar.SetTabs(bar, {Tab("Duskwood")})

            assert.are_same({"Duskwood"}, ShownNames())
        end)

        it("should be shown without creating anything again", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall"), Tab("Duskwood")})
            JourneyTabBar.SetTabs(bar, {Tab("Duskwood")})
            local frameCount = #ui.frames

            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall"), Tab("Duskwood")})

            assert.are.equal(frameCount, #ui.frames)
            assert.are_same({"Elwynn Forest", "Westfall", "Duskwood"}, ShownNames())
        end)

        it("should be as wide as their names, up to a limit", function()
            JourneyTabBar.SetTabs(bar, {Tab("Wetlands"), Tab("Westfall Lighthouse"), Tab(LONG_NAME), Tab(LONG_NAME .. " and More")})

            local widths = {}
            for index, button in ipairs(Buttons()) do widths[index] = button:GetWidth() end
            assert.is_true(widths[1] < widths[2], "a longer name gets a wider tab")
            assert.are.equal(widths[3], widths[4])
            assert.is_true(Button(LONG_NAME).Text:GetWidth() < Button(LONG_NAME).Text:GetUnboundedStringWidth(), "the name is cut off")
        end)

        it("should cut off the long names first when there isn't room for all of them, and still fit into the bar", function()
            bar:SetWidth(2000)
            JourneyTabBar.SetTabs(bar, {Tab("Wetlands"), Tab(LONG_NAME), Tab(LONG_NAME .. " and More")})
            local shortWidth, longWidth = Buttons()[1]:GetWidth(), Buttons()[2]:GetWidth()

            bar:SetWidth(480)

            local buttons = Buttons()
            assert.are.equal(shortWidth, buttons[1]:GetWidth())
            assert.is_true(buttons[2]:GetWidth() < longWidth)
            assert.are.equal(buttons[2]:GetWidth(), buttons[3]:GetWidth())
            for index = 2, #buttons do
                assert.is_true(GetX(buttons[index]) >= GetRight(buttons[index - 1]), "the tabs don't overlap")
            end
            assert.is_true(GetX(bar.findTab) >= GetRight(buttons[3]))
            assert.is_true(GetRight(bar.findTab) <= 480)
        end)
    end)

    describe("having room", function()
        -- The spec of JourneyTabBar: another tab is only added when each of them can be this wide
        local ROOM_PER_TAB = 120

        it("should only be there while every tab can still be about as wide as a short name", function()
            local tabs = {}
            while JourneyTabBar.HasRoom(bar) do
                table.insert(tabs, Tab(LONG_NAME .. " " .. #tabs))
                JourneyTabBar.SetTabs(bar, tabs)
            end
            assert.is_true(#tabs > 2)
            for _, button in ipairs(Buttons()) do
                assert.is_true(button:GetWidth() >= ROOM_PER_TAB)
            end

            -- With one more, they would be narrower than that
            table.insert(tabs, Tab(LONG_NAME .. " " .. #tabs))
            JourneyTabBar.SetTabs(bar, tabs)
            assert.is_true(Buttons()[1]:GetWidth() < ROOM_PER_TAB)
        end)
    end)

    describe("the find tab", function()
        it("should open the search with its magnifier", function()
            bar.findTab.Search:Click()

            assert.are_same({"nothing"}, searched)
            assert.are.equal(0, added)
        end)

        it("should open the overview with its plus", function()
            bar.findTab.Plus:Click()

            assert.are_same({}, searched)
            assert.are.equal(1, added)
        end)

        it("should search for an item that is dropped on the magnifier, which leaves the cursor", function()
            cursor = {type = "item", id = 2589, link = "|cffffffff|Hitem:2589::::::::|h[Linen Cloth]|h|r"}

            bar.findTab.Search.scripts.OnReceiveDrag(bar.findTab.Search)

            assert.are_same({"|cffffffff|Hitem:2589::::::::|h[Linen Cloth]|h|r"}, searched)
            assert.is_nil(cursor)
        end)

        it("should leave anything else that is dropped on the magnifier on the cursor", function()
            cursor = {type = "spell", id = 133}

            bar.findTab.Search.scripts.OnReceiveDrag(bar.findTab.Search)

            assert.are_same({}, searched)
            assert.are_same({type = "spell", id = 133}, cursor)
        end)

        it("should stand right behind the last tab, wherever that is", function()
            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest"), Tab("Westfall")})
            local secondRight = GetRight(Buttons()[2])
            assert.is_true(GetX(bar.findTab) >= secondRight)

            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest")})

            assert.is_true(GetX(bar.findTab) >= GetRight(Buttons()[1]))
            assert.is_true(GetX(bar.findTab) < secondRight)
        end)

        it("should light up what is shown, and look selected while either is", function()
            local findTab = bar.findTab
            local function Shown()
                return {findTab.Left.atlas, findTab.Search.Icon.alpha == 1, findTab.Plus.Icon.alpha == 1}
            end

            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest")}, "search")
            assert.are_same({"Options_Tab_Active_Left", true, false}, Shown())

            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest")}, "overview")
            assert.are_same({"Options_Tab_Active_Left", false, true}, Shown())

            JourneyTabBar.SetTabs(bar, {Tab("Elwynn Forest", {isSelected = true})}, nil)
            assert.are_same({"Options_Tab_Left", false, false}, Shown())
        end)
    end)
end)
