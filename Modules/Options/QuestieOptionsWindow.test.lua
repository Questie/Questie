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

    describe("Create", function()
        it("should start hidden and close with the Escape key", function()
            local window = QuestieOptionsWindow.Create()

            assert.is_false(window:IsShown())
            assert.are_same({"QuestieStandaloneSettings"}, UISpecialFrames)
        end)

        it("should take its height from the screen", function()
            local window = QuestieOptionsWindow.Create()

            assert.are.equal(700, window:GetHeight())
        end)

        describe("dragging", function()
            local window, dragBar, moving

            before_each(function()
                window = QuestieOptionsWindow.Create()
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

    describe("CreateSideTab", function()
        local window

        before_each(function()
            window = QuestieOptionsWindow.Create()
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
