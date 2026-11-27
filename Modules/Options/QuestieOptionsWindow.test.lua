dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("QuestieOptionsWindow", function()
    ---@type QuestieOptionsWindow
    local QuestieOptionsWindow
    local ui, originalIsForever

    local function FindChildWithScript(frame, scriptName)
        for _, child in ipairs(frame.children) do
            if child.scripts[scriptName] then
                return child
            end
        end
    end

    ---@param settings table? Replaces some of the settings
    ---@return Frame window
    local function CreateWindow(settings)
        local windowSettings = {name = "TestWindow", title = "Test", strata = "HIGH", width = 600, height = 500}
        for key, value in pairs(settings or {}) do
            windowSettings[key] = value
        end
        return QuestieOptionsWindow.Create(windowSettings)
    end

    before_each(function()
        ui = FakeUI.Install()
        originalIsForever = Questie.IsForever
        Questie.IsForever = true

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsWindow.lua")
        QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
    end)

    after_each(function()
        Questie.IsForever = originalIsForever
        ui.Restore()
    end)

    describe("AddSearchBox", function()
        it("should forward search text changes", function()
            local searchText
            local window = CreateWindow()
            QuestieOptionsWindow.AddSearchBox(window, function(text) searchText = text end)

            window.searchBox:SetText("tracker")
            window.searchBox.scripts.OnTextChanged(window.searchBox, true)

            assert.are.equal("tracker", searchText)
        end)

        -- The placeholder would stay behind the typed text if the window replaced the template's own handling
        it("should show the search box's placeholder only while it is empty", function()
            local window = CreateWindow()
            QuestieOptionsWindow.AddSearchBox(window, function() end)
            assert.are.equal("Search", window.searchBox.Instructions.text)

            window.searchBox:SetText("tracker")
            window.searchBox.scripts.OnTextChanged(window.searchBox, true)
            assert.is_false(window.searchBox.Instructions:IsShown())

            window.searchBox:SetText("")
            window.searchBox.scripts.OnTextChanged(window.searchBox, true)
            assert.is_true(window.searchBox.Instructions:IsShown())
        end)

    end)

    describe("Create", function()
        it("should start hidden and close with the Escape key", function()
            local window = CreateWindow({name = "SomeWindow"})

            assert.is_false(window:IsShown())
            assert.are.equal("SomeWindow", window:GetName())
            assert.are_same({"SomeWindow"}, UISpecialFrames)
        end)

        it("should have the given size, and nothing to change it with", function()
            local window = CreateWindow({width = 600, height = 500})

            assert.are_same({600, 500}, {window:GetSize()})
            assert.are_same({}, ui.FindByTemplate(window, "PanelResizeButtonTemplate"))
        end)

        describe("with a minimum size", function()
            local window, grip

            before_each(function()
                window = CreateWindow({minWidth = 300, minHeight = 200})
                grip = ui.FindByTemplate(window, "PanelResizeButtonTemplate")[1]
            end)

            it("should be resized down to it with the grip", function()
                assert.are.equal(window, grip.target)
                assert.are_same({300, 200}, {grip.minWidth, grip.minHeight})
            end)

            it("should stop resizing when the window hides, because the mouse-up never arrives", function()
                window:Show()
                grip:OnMouseDown()
                assert.is_true(window.isSizing)

                window:Hide()

                assert.is_false(window.isSizing)
                assert.is_false(grip:IsActive())
            end)

            it("should tell the size it was resized to when the grip is released, also when the window hides then", function()
                local sizes = {}
                window = CreateWindow({minWidth = 300, minHeight = 200, onResized = function(width, height)
                    table.insert(sizes, {width, height})
                end})
                grip = ui.FindByTemplate(window, "PanelResizeButtonTemplate")[1]
                window:Show()

                grip:OnMouseDown()
                window:SetSize(700, 450)
                assert.are_same({}, sizes)
                grip:OnMouseUp()
                assert.are_same({{700, 450}}, sizes)

                grip:OnMouseDown()
                window:SetSize(650, 420)
                window:Hide()
                assert.are_same({{700, 450}, {650, 420}}, sizes)
            end)

            it("should leave the window alone when it hides while it isn't being resized", function()
                local stops = 0
                window.StopMovingOrSizing = function() stops = stops + 1 end
                window:Show()

                window:Hide()

                assert.are.equal(0, stops)
            end)
        end)

        describe("dragging", function()
            local window, dragBar, moving

            before_each(function()
                window = CreateWindow()
                dragBar = FindChildWithScript(window, "OnMouseDown")
                moving = false
                window.StartMoving = function() moving = true end
                window.StopMovingOrSizing = function() moving = false end
            end)

            it("should follow the left mouse button", function()
                dragBar.scripts.OnMouseDown(dragBar, "LeftButton")
                assert.is_true(moving)

                dragBar.scripts.OnMouseUp(dragBar, "LeftButton")
                assert.is_false(moving)
            end)

            it("should ignore other mouse buttons", function()
                dragBar.scripts.OnMouseDown(dragBar, "RightButton")

                assert.is_false(moving)
            end)

            it("should stop when the window hides mid-drag, because the mouse-up never arrives", function()
                window:Show()
                dragBar.scripts.OnMouseDown(dragBar, "LeftButton")

                window:Hide()

                assert.is_false(moving)
            end)
        end)
    end)

    for _, client in ipairs({{name = "Forever", isForever = true}, {name = "Classic", isForever = false}}) do
        describe("CreateLinkTab with the " .. client.name .. " art", function()
            local window, linkTab, clicks

            before_each(function()
                Questie.IsForever = client.isForever
                clicks = 0
                window = CreateWindow()
                linkTab = QuestieOptionsWindow.CreateLinkTab(
                    window, "journey", {title = "My Journey", icon = 136797, iconCrop = 0.1875}, function() clicks = clicks + 1 end
                )
            end)

            it("should be on the left edge of the window, where the side tabs are not", function()
                local sideTab = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "A"}, nil, function() end)

                local linkPoint, sidePoint = linkTab.points[1], sideTab.points[1]
                assert.are_same({"TOPRIGHT", "TOPLEFT"}, {linkPoint[1], linkPoint[3]})
                assert.are_same({"TOPLEFT", "TOPRIGHT"}, {sidePoint[1], sidePoint[3]})
                assert.are.equal(window, linkPoint[2])
            end)

            it("should leave the metal of the window's edge visible", function()
                -- It is 2 px wide on Classic, with its center on the window's left edge
                assert.is_true(linkTab.points[1][4] <= (client.isForever and 1 or 0))
            end)

            it("should be level with the second side tab", function()
                local first = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "A"}, nil, function() end)
                local second = QuestieOptionsWindow.CreateSideTab(window, "b", {title = "B"}, first, function() end)
                local secondY = first.points[1][5] - first:GetHeight() + second.points[1][5]

                assert.are.equal(secondY, linkTab.points[1][5])
            end)

            it("should only act when it is clicked", function()
                assert.are.equal(0, clicks)

                linkTab.button.scripts.OnClick(linkTab.button)

                assert.are.equal(1, clicks)
            end)

            it("should say where it leads while hovered", function()
                linkTab.button.scripts.OnEnter(linkTab.button)

                assert.are.equal("My Journey", GameTooltip.text)
                assert.is_nil(GameTooltip.lines)
            end)

            it("should nudge its icon while pressed", function()
                local point = linkTab.Icon.points[#linkTab.Icon.points]
                local startX, startY = point[4], point[5]

                linkTab.button.scripts.OnMouseDown(linkTab.button, "LeftButton")
                point = linkTab.Icon.points[#linkTab.Icon.points]
                assert.are_same({startX + 1, startY - 1}, {point[4], point[5]})

                linkTab.button.scripts.OnMouseUp(linkTab.button, "LeftButton")
                point = linkTab.Icon.points[#linkTab.Icon.points]
                assert.are_same({startX, startY}, {point[4], point[5]})
            end)
        end)
    end

    describe("CreateSideTab", function()
        local window

        before_each(function()
            window = CreateWindow()
        end)

        it("should tell which tab was selected", function()
            local selectedKey
            local sideTab = QuestieOptionsWindow.CreateSideTab(window, "map", {title = "Map"}, nil, function(key) selectedKey = key end)

            sideTab.button.scripts.OnClick(sideTab.button)

            assert.are.equal("map", selectedKey)
        end)

        it("should stack tabs below each other, starting at the window's edge", function()
            local first = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "A"}, nil, function() end)
            local second = QuestieOptionsWindow.CreateSideTab(window, "b", {title = "B"}, first, function() end)

            assert.are.equal(window, first.points[1][2])
            assert.are.equal(first, second.points[1][2])
        end)

        it("should show the selected state, and dim the icon otherwise", function()
            local sideTab = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "A"}, nil, function() end)

            QuestieOptionsWindow.SetSideTabSelected(sideTab, true)
            assert.is_true(sideTab.Selected:IsShown())
            local selectedAlpha = sideTab.Icon.alpha

            QuestieOptionsWindow.SetSideTabSelected(sideTab, false)
            assert.is_false(sideTab.Selected:IsShown())
            assert.is_true(sideTab.Icon.alpha < selectedAlpha)
        end)

        it("should describe the tab while hovered", function()
            local sideTab = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "Title", subtitle = "Subtitle"}, nil, function() end)

            sideTab.button.scripts.OnEnter(sideTab.button)

            assert.are.equal("Title", GameTooltip.text)
            assert.are_same({"Subtitle"}, GameTooltip.lines)
        end)

        it("should hide its tooltip when the window closes under the mouse", function()
            local sideTab = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "A"}, nil, function() end)
            window:Show()
            sideTab.button.scripts.OnEnter(sideTab.button)
            assert.is_true(GameTooltip:IsShown())

            window:Hide()

            assert.is_false(GameTooltip:IsShown())
        end)

        describe("pressing", function()
            local sideTab, button, icon

            local function IconOffset()
                local point = icon.points[#icon.points]
                return point[4], point[5]
            end

            before_each(function()
                sideTab = QuestieOptionsWindow.CreateSideTab(window, "a", {title = "A"}, nil, function() end)
                button = sideTab.button
                icon = sideTab.Icon
            end)

            it("should nudge the icon and put it back on release", function()
                local startX, startY = IconOffset()

                button.scripts.OnMouseDown(button, "LeftButton")
                local pressedX, pressedY = IconOffset()
                assert.are.equal(startX + 1, pressedX)
                assert.are.equal(startY - 1, pressedY)

                button.scripts.OnMouseUp(button, "LeftButton")
                local releasedX, releasedY = IconOffset()
                assert.are.equal(startX, releasedX)
                assert.are.equal(startY, releasedY)
            end)

            it("should put the icon back when the button is released away from the tab", function()
                local startX = IconOffset()
                button.scripts.OnMouseDown(button, "LeftButton")

                button.scripts.OnUpdate(button)

                assert.are.equal(startX, (IconOffset()))
                assert.is_nil(button.scripts.OnUpdate)
            end)

            it("should keep the icon pressed while the button is still held", function()
                _G.IsMouseButtonDown = function() return true end
                local startX = IconOffset()
                button.scripts.OnMouseDown(button, "LeftButton")

                button.scripts.OnUpdate(button)

                assert.are.equal(startX + 1, (IconOffset()))
            end)

            it("should put the icon back when the window closes while pressed", function()
                local startX = IconOffset()
                window:Show()
                button.scripts.OnMouseDown(button, "LeftButton")

                window:Hide()

                assert.are.equal(startX, (IconOffset()))
            end)
        end)
    end)
end)
