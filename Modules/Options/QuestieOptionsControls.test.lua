dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("QuestieOptionsControls", function()
    ---@type QuestieOptionsControls
    local QuestieOptionsControls
    local QuestieOptionsEngine
    local ui, parent

    ---Normalized the way QuestieOptionsLayout hands items over.
    local function Create(item)
        item.title = item.title or "Title"
        if item.type == "slider" then
            item.min = item.min or 0
            item.max = item.max or 10
            item.step = item.step or 1
            item.showValue = item.showValue == nil or item.showValue
        end
        item.align = item.align or "LEFT"
        item.titleAlign = item.titleAlign or "LEFT"
        item.descriptionAlign = item.descriptionAlign or "LEFT"
        return QuestieOptionsControls.Create(parent, item, 300, 1)
    end

    before_each(function()
        ui = FakeUI.Install()
        parent = CreateFrame("Frame", nil, UIParent)

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        QuestieOptionsEngine.RefreshStates = spy.new(function() end)
        QuestieOptionsEngine.QueueRefresh = spy.new(function() end)
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
    end)

    after_each(function()
        ui.Restore()
    end)

    it("should refuse an unknown control type instead of drawing nothing", function()
        assert.has_error(function()
            QuestieOptionsControls.Create(parent, {type = "toggle"}, 300, 1)
        end, "Unknown settings control type: toggle")
    end)

    describe("enabled state", function()
        it("should treat a function returning nil as enabled, so options don't grey out on unset settings", function()
            local control = Create({type = "checkbox", enabled = function() return nil end})

            assert.is_true(control.widget:IsEnabled())
        end)

        it("should disable the widget and grey out its labels", function()
            local isEnabled = true
            local control = Create({type = "checkbox", description = "Details", enabled = function() return isEnabled end})
            local enabledColor = control.titleFrame.textColor

            isEnabled = false
            QuestieOptionsControls.Refresh(control)

            assert.is_false(control.widget:IsEnabled())
            assert.are_not.same(enabledColor, control.titleFrame.textColor)
            assert.are_same({0.55, 0.55, 0.55, 1}, control.descriptionFrame.textColor)
        end)
    end)

    describe("checkbox", function()
        it("should show the stored value from the moment it exists", function()
            local control = Create({type = "checkbox", get = function() return true end})

            assert.is_true(control.widget:GetChecked())
        end)

        it("should count the legacy stored value 1 as checked", function()
            local control = Create({type = "checkbox", get = function() return 1 end})

            assert.is_true(control.widget:GetChecked())
        end)

        it("should store the new state and refresh the settings when clicked", function()
            local stored
            local control = Create({type = "checkbox", set = function(_, value) stored = value end})

            control.widget:SetChecked(true)
            control.widget:Click()

            assert.is_true(stored)
            assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
        end)

        it("should forward a click on the row to the checkbox while enabled", function()
            local clicks = 0
            local control = Create({type = "checkbox", set = function() clicks = clicks + 1 end})

            control:Click()

            assert.are.equal(1, clicks)
        end)

        it("should ignore a click on the row while disabled", function()
            local clicks = 0
            local control = Create({type = "checkbox", enabled = function() return false end, set = function() clicks = clicks + 1 end})

            control:Click()

            assert.are.equal(0, clicks)
        end)

        it("should drop its hover highlight when it gets disabled under the mouse", function()
            local isEnabled = true
            local control = Create({type = "checkbox", enabled = function() return isEnabled end})
            control.widget.HoverTex:Show()

            isEnabled = false
            QuestieOptionsControls.Refresh(control)

            assert.is_false(control.widget.HoverTex:IsShown())
        end)

        it("should keep its height while the description fits", function()
            ui.stringHeight = 5

            local control = Create({type = "checkbox", description = "Details"})

            assert.are.equal(30, control:GetHeight())
        end)

        it("should grow the row when a wrapped description doesn't fit", function()
            ui.stringHeight = 40

            local control = Create({type = "checkbox", description = "Details"})

            -- Title and description, with 2 units between them
            assert.are.equal(82, control:GetHeight())
        end)

        it("should grow the row when a wrapped title without description doesn't fit", function()
            ui.stringHeight = 40

            local control = Create({type = "checkbox"})

            assert.are.equal(40, control:GetHeight())
        end)
    end)

    describe("radio button", function()
        it("should ask the getter about its own value", function()
            local choice = "second"
            local get = function(value) return choice == value end

            local first = Create({type = "radioButton", value = "first", get = get})
            local second = Create({type = "radioButton", value = "second", get = get})

            assert.is_false(first.widget:GetChecked())
            assert.is_true(second.widget:GetChecked())
        end)

        it("should store its own value when clicked", function()
            local stored
            local control = Create({type = "radioButton", value = "first", set = function(value) stored = value end})

            control.widget:Click()

            assert.are.equal("first", stored)
            assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
        end)
    end)

    describe("slider", function()
        local setterCalls

        -- A plain recorder, because a spy deep-copies its arguments and frames link to the whole UI through their parents
        local function RecordSetterCall(_, value, userInput)
            table.insert(setterCalls, {value = value, userInput = userInput})
        end

        before_each(function()
            setterCalls = {}
        end)

        it("should show the stored value without running the setter", function()
            local control = Create({type = "slider", get = function() return 4 end, set = RecordSetterCall})

            assert.are.equal(4, control.widget:GetValue())
            assert.are.equal("4", control.valueDisplay.text)
            assert.are_same({}, setterCalls)
        end)

        it("should not run the setter when a refresh shows a value changed elsewhere", function()
            local stored = 4
            local control = Create({type = "slider", get = function() return stored end, set = RecordSetterCall})

            stored = 7
            QuestieOptionsControls.Refresh(control)

            assert.are.equal(7, control.widget:GetValue())
            assert.are.equal("7", control.valueDisplay.text)
            assert.are_same({}, setterCalls)
        end)

        describe("dragging", function()
            local control

            -- What the client does while the thumb moves under the mouse
            local function Drag(value)
                control.widget.value = value
                control.widget.scripts.OnValueChanged(control.widget, value, true)
            end

            before_each(function()
                control = Create({type = "slider", get = function() return 4 end, set = RecordSetterCall})
            end)

            it("should run the setter with userInput while being dragged", function()
                Drag(6)

                assert.are_same({{value = 6, userInput = true}}, setterCalls)
                assert.are.equal("6", control.valueDisplay.text)
            end)

            -- The tracker ratios only leave their sizing mode through this call.
            it("should tell the setter when the drag ended", function()
                Drag(6)
                setterCalls = {}

                control.widget.scripts.OnMouseUp(control.widget, "LeftButton")

                assert.are_same({{value = 6, userInput = false}}, setterCalls)
                assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
            end)

            -- Closing the window during a drag means the mouse-up never arrives.
            it("should tell the setter the drag ended when the slider hides during it", function()
                Drag(6)
                setterCalls = {}

                parent:Hide()

                assert.are_same({{value = 6, userInput = false}}, setterCalls)
            end)

            it("should only tell the setter once", function()
                Drag(6)
                control.widget.scripts.OnMouseUp(control.widget, "LeftButton")
                setterCalls = {}

                parent:Hide()

                assert.are_same({}, setterCalls)
            end)

            -- A setter can start a full reset of the map icons, so a click that changed nothing must not run it.
            it("should not run the setter for a click that didn't change the value", function()
                control.widget.scripts.OnMouseUp(control.widget, "RightButton")

                assert.are_same({}, setterCalls)
                assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
            end)

            it("should not treat a value shown by a refresh as a drag", function()
                local stored = 4
                local shown = Create({type = "slider", get = function() return stored end, set = RecordSetterCall})
                stored = 7
                QuestieOptionsControls.Refresh(shown)

                shown.widget.scripts.OnMouseUp(shown.widget, "LeftButton")

                assert.are_same({}, setterCalls)
            end)
        end)

        it("should show the value text even when the stored value is the minimum", function()
            local control = Create({type = "slider", min = 2, get = function() return 2 end})

            assert.are.equal("2", control.valueDisplay.text)
        end)

        -- Found in the real client: Icon Limit stores 1500, with a minimum of 1 and a step of 10.
        it("should show the stored value as text, even when the thumb snaps to a step next to it", function()
            local control = Create({type = "slider", min = 1, max = 5000, step = 10, get = function() return 1500 end})

            assert.are.equal(1501, control.widget:GetValue())
            assert.are.equal("1500", control.valueDisplay.text)
        end)

        it("should move in steps of the item", function()
            local control = Create({type = "slider", step = 0.5})

            assert.are.equal(0.5, control.widget.valueStep)
            assert.is_true(control.widget.obeysStepOnDrag)
        end)

        it("should grey out its track and thumb while disabled", function()
            local isEnabled = false
            local control = Create({type = "slider", enabled = function() return isEnabled end})
            assert.is_true(control.widget.TrackMiddle.isDesaturated)
            assert.is_true(control.thumb.isDesaturated)

            isEnabled = true
            QuestieOptionsControls.Refresh(control)

            assert.is_false(control.widget.TrackMiddle.isDesaturated)
            assert.is_false(control.thumb.isDesaturated)
        end)

        it("should fall back to the minimum when nothing is stored", function()
            local control = Create({type = "slider", min = 2, get = function() return nil end})

            assert.are.equal(2, control.widget:GetValue())
        end)

        it("should format percentages", function()
            local control = Create({type = "slider", min = 0, max = 2, step = 0.05, isPercent = true, get = function() return 1.25 end})

            assert.are.equal("125%", control.valueDisplay.text)
            assert.are.equal("200%", control.widget.High.text)
        end)
    end)

    describe("dropdown", function()
        local function FillMenu(control)
            control.widget:OpenMenu()
            return control.widget.menuEntries
        end

        -- Blizzard generates a menu every time a dropdown is shown, just for the selected entry's text.
        -- A tab with many long dropdowns would otherwise spend most of its time on entries nobody opened.
        describe("while closed", function()
            local stored, sortOrderCalls, control

            before_each(function()
                stored, sortOrderCalls = "b", 0
                control = Create({
                    type = "dropdown",
                    options = {a = "A", b = "B", c = "C"},
                    sortOrder = function()
                        sortOrderCalls = sortOrderCalls + 1
                        return {"a", "b", "c"}
                    end,
                    get = function() return stored end,
                })
            end)

            it("should only generate the selected entry, enough to show its text", function()
                assert.are.equal(1, #control.widget.menuEntries)
                assert.are.equal("B", control.widget:GetText())
                assert.are.equal(0, sortOrderCalls)
            end)

            it("should find a stored value of false, which isn't the same as having no value", function()
                local onOff = Create({
                    type = "dropdown",
                    options = {[true] = "On", [false] = "Off"},
                    get = function() return false end,
                })

                assert.are.equal("Off", onOff.widget:GetText())
            end)

            it("should show no text when the stored value isn't an option, like a full menu", function()
                stored = "not an option"

                QuestieOptionsControls.Refresh(control)

                assert.are.equal(0, #control.widget.menuEntries)
                assert.is_nil(control.widget:GetText())
            end)

            it("should show the text of a value changed elsewhere", function()
                stored = "c"

                QuestieOptionsControls.Refresh(control)

                assert.are.equal("C", control.widget:GetText())
            end)
        end)

        describe("while open", function()
            local stored, control

            before_each(function()
                stored = "b"
                control = Create({
                    type = "dropdown",
                    options = {a = "A", b = "B", c = "C"},
                    get = function() return stored end,
                    set = function(key) stored = key end,
                })
            end)

            it("should have every entry", function()
                control.widget:OpenMenu()

                assert.are.equal(3, #control.widget.menuEntries)
            end)

            it("should keep every entry when the menu is regenerated while open", function()
                control.widget:OpenMenu()

                control.widget:GenerateMenu()

                assert.are.equal(3, #control.widget.menuEntries)
            end)

            it("should store a picked entry and show its text after closing", function()
                control.widget:OpenMenu()

                control.widget:Pick(control.widget.menuEntries[1])

                assert.are.equal("a", stored)
                assert.is_false(control.widget:IsMenuOpen())
                assert.are.equal("A", control.widget:GetText())
            end)

            it("should go back to just the selected entry the next time it is shown", function()
                control.widget:OpenMenu()
                control.widget:CloseMenu()

                parent:Hide()
                parent:Show()

                assert.are.equal(1, #control.widget.menuEntries)
            end)

            it("should keep only the selected entry when being disabled stops it from opening", function()
                local disabled = Create({type = "dropdown", options = {a = "A", b = "B"}, enabled = function() return false end, get = function() return "a" end})

                disabled.widget:OpenMenu()

                assert.are.equal(1, #disabled.widget.menuEntries)
            end)
        end)

        it("should sort entries alphabetically by their display text", function()
            local control = Create({type = "dropdown", options = {a = "Zebra", b = "apple", c = "Mango"}})

            local entries = FillMenu(control)

            assert.are.equal("apple", entries[1].text)
            assert.are.equal("Mango", entries[2].text)
            assert.are.equal("Zebra", entries[3].text)
        end)

        it("should follow an explicit order and skip keys that have no option", function()
            local control = Create({type = "dropdown", options = {a = "A", b = "B"}, sortOrder = {"b", "missing", "a"}})

            local entries = FillMenu(control)

            assert.are.equal(2, #entries)
            assert.are.equal("B", entries[1].text)
            assert.are.equal("A", entries[2].text)
        end)

        it("should resolve options given as a function when the menu opens", function()
            local control = Create({type = "dropdown", options = function() return {a = "From function"} end})

            assert.are.equal("From function", FillMenu(control)[1].text)
        end)

        it("should store the picked key and mark only the stored one as selected", function()
            local stored = "a"
            local control = Create({
                type = "dropdown",
                options = {a = "A", b = "B"},
                get = function() return stored end,
                set = function(key) stored = key end,
            })
            local entries = FillMenu(control)

            entries[2].select()

            assert.are.equal("b", stored)
            assert.is_false(entries[1].isSelected())
            assert.is_true(entries[2].isSelected())
            assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
        end)

        -- Otherwise the text on the closed dropdown stays on the old selection, like after switching profile.
        it("should update its menu when the value changed elsewhere, but not on every refresh", function()
            local stored = "a"
            local control = Create({type = "dropdown", options = {a = "A", b = "B"}, get = function() return stored end})
            local initialMenus = control.widget.generatedMenus

            QuestieOptionsControls.Refresh(control)
            assert.are.equal(initialMenus, control.widget.generatedMenus)

            stored = "b"
            QuestieOptionsControls.Refresh(control)
            assert.are.equal(initialMenus + 1, control.widget.generatedMenus)
        end)

        -- Picking an entry refreshes from inside its own click, and regenerating would replace the menu being clicked.
        it("should not regenerate its menu while it is open", function()
            local stored = "a"
            local control = Create({type = "dropdown", options = {a = "A", b = "B"}, get = function() return stored end})
            control.widget:OpenMenu()
            local menusWhileOpen = control.widget.generatedMenus

            stored = "b"
            QuestieOptionsControls.Refresh(control)

            assert.are.equal(menusWhileOpen, control.widget.generatedMenus)
        end)

        -- Found in the real client: like resetting the setting or switching profile right after picking
        it("should follow a value that goes back to the old one after a pick", function()
            local stored = "a"
            local control = Create({
                type = "dropdown",
                options = {a = "A", b = "B"},
                get = function() return stored end,
                set = function(key) stored = key end,
            })
            -- A pick refreshes every control from inside its click
            QuestieOptionsEngine.RefreshStates = function() QuestieOptionsControls.Refresh(control) end
            control.widget:OpenMenu()
            control.widget:Pick(control.widget.menuEntries[2])
            assert.are.equal("B", control.widget:GetText())

            stored = "a"
            QuestieOptionsControls.Refresh(control)

            assert.are.equal("A", control.widget:GetText())
        end)

        it("should show a value changed while open, after Escape or a click elsewhere closed the menu", function()
            local stored = "a"
            local control = Create({type = "dropdown", options = {a = "A", b = "B"}, get = function() return stored end})
            control.widget:OpenMenu()

            stored = "b"
            QuestieOptionsControls.Refresh(control)
            control.widget:CloseMenuFromOutside()
            QuestieOptionsControls.Refresh(control)

            assert.are.equal("B", control.widget:GetText())
        end)

        it("should grey out its art while disabled", function()
            local isEnabled = true
            local control = Create({type = "dropdown", options = {}, enabled = function() return isEnabled end})
            local region = CreateFrame("Texture")
            control.widget.regions = {region}

            isEnabled = false
            QuestieOptionsControls.Refresh(control)

            assert.is_true(region.isDesaturated)
            assert.are_same({0.7, 0.7, 0.7, 1}, region.vertexColor)
        end)
    end)

    describe("tooltip", function()
        it("should show the title and text while the row is hovered", function()
            local control = Create({type = "checkbox", title = "Option", tooltip = "What it does"})

            control.scripts.OnEnter(control)

            assert.are.equal("Option", GameTooltip.text)
            assert.are_same({"What it does"}, GameTooltip.lines)
        end)

        it("should also show when hovering the checkbox itself", function()
            local control = Create({type = "checkbox", title = "Option", tooltip = "What it does"})

            control.widget.scripts.OnEnter(control.widget)

            assert.are.equal("Option", GameTooltip.text)
        end)

        it("should hide when the mouse leaves", function()
            local control = Create({type = "checkbox", title = "Option", tooltip = "What it does"})
            GameTooltip:Show()

            control.scripts.OnLeave(control)

            assert.is_false(GameTooltip:IsShown())
        end)

        it("should stay while the mouse is still over the dropdown of the same row", function()
            local control = Create({type = "dropdown", title = "Option", tooltip = "What it does", options = {}})
            GameTooltip:Show()
            control.widget.mouseOver = true

            control.scripts.OnLeave(control)

            assert.is_true(GameTooltip:IsShown())
        end)

        -- Measured in the real client: hiding a hovered row runs its OnLeave, while IsMouseOver still returns true
        it("should hide when its row gets hidden under the mouse, like when the settings close", function()
            local control = Create({type = "checkbox", title = "Option", tooltip = "What it does"})
            control.scripts.OnEnter(control)
            control.mouseOver = true

            parent:Hide()
            control.scripts.OnLeave(control)

            assert.is_false(GameTooltip:IsShown())
        end)

        it("should not touch the tooltip for a control without one", function()
            local control = Create({type = "checkbox", title = "Option"})

            control.scripts.OnEnter(control)

            assert.is_nil(GameTooltip.text)
        end)

        -- Found in the real client: a long menu near the bottom opens upward, under the tooltip of its dropdown.
        describe("with an open menu", function()
            local function CreateDropdown()
                return Create({type = "dropdown", title = "Option", tooltip = "What it does", options = {a = "A"}})
            end

            it("should hide when the dropdown's menu opens", function()
                local control = CreateDropdown()
                control.widget.scripts.OnEnter(control.widget)
                assert.is_true(GameTooltip:IsShown())

                control.widget:OpenMenu()

                assert.is_false(GameTooltip:IsShown())
            end)

            it("should stay hidden when moving back onto the dropdown", function()
                local control = CreateDropdown()
                control.widget:OpenMenu()

                control.widget.scripts.OnEnter(control.widget)

                assert.is_false(GameTooltip:IsShown())
            end)

            it("should not show for other controls either, because it could cover the menu", function()
                local control = CreateDropdown()
                local other = Create({type = "checkbox", title = "Other", tooltip = "Other tooltip"})
                control.widget:OpenMenu()

                other.scripts.OnEnter(other)

                assert.is_false(GameTooltip:IsShown())
            end)

            -- Blizzard's dropdown shows its own tooltip when its text doesn't fit, before this one gets its turn
            it("should also hide the tooltip Blizzard just showed for text that doesn't fit", function()
                local control = CreateDropdown()
                control.widget:OpenMenu()
                GameTooltip:Show()

                control.widget.scripts.OnEnter(control.widget)

                assert.is_false(GameTooltip:IsShown())
            end)

            it("should work again after the menu closed", function()
                local control = CreateDropdown()
                control.widget:OpenMenu()
                control.widget:CloseMenu()

                control.widget.scripts.OnEnter(control.widget)

                assert.is_true(GameTooltip:IsShown())
            end)

            it("should stay when a disabled dropdown doesn't open", function()
                local control = Create({type = "dropdown", title = "Option", tooltip = "What it does", options = {}, enabled = function() return false end})
                control.scripts.OnEnter(control)

                control.widget:OpenMenu()

                assert.is_true(GameTooltip:IsShown())
            end)
        end)
    end)

    describe("font dropdown", function()
        local stored, control

        before_each(function()
            stored = "Zeta"
            control = Create({
                type = "fontDropdown",
                fonts = {Zeta = "z.ttf", alpha = "a.ttf", Mid = "m.ttf"},
                get = function() return stored end,
                set = function(key) stored = key end,
            })
        end)

        it("should only generate the selected font while closed, without the scrolling list or previews", function()
            local entries = control.widget.menuEntries

            assert.are.equal(1, #entries)
            assert.is_nil(entries.scrollHeight)
            assert.is_nil(entries[1].initializer)
            assert.are.equal("Zeta", control.widget:GetText())
        end)

        it("should list the fonts alphabetically regardless of case when opened, in a scrolling list", function()
            control.widget:OpenMenu()
            local entries = control.widget.menuEntries

            assert.are.equal("alpha", entries[1].text)
            assert.are.equal("Mid", entries[2].text)
            assert.are.equal("Zeta", entries[3].text)
            assert.are.equal(250, entries.scrollHeight)
        end)

        it("should preview each entry in its own font", function()
            control.widget:OpenMenu()
            local entries = control.widget.menuEntries
            local alphaRow = {fontString = CreateFrame("FontString")}
            local zetaRow = {fontString = CreateFrame("FontString")}

            entries[1].initializer(alphaRow)
            entries[3].initializer(zetaRow)

            assert.are.equal("a.ttf", alphaRow.fontString.fontObject.fontPath)
            assert.are.equal("z.ttf", zetaRow.fontString.fontObject.fontPath)
        end)

        it("should store the picked font name", function()
            control.widget:OpenMenu()

            control.widget:Pick(control.widget.menuEntries[1])

            assert.are.equal("alpha", stored)
            assert.are.equal("alpha", control.widget:GetText())
        end)

        it("should show nothing for a font that is no longer available", function()
            stored = "Removed font"

            QuestieOptionsControls.Refresh(control)

            assert.are.equal(0, #control.widget.menuEntries)
        end)
    end)

    describe("text", function()
        it("should keep showing a static title through refreshes", function()
            local control = Create({type = "text", title = "Static", titleFormat = function(text) return "<" .. text .. ">" end})

            QuestieOptionsControls.Refresh(control)

            assert.are.equal("<Static>", control.titleFrame.text)
        end)

        it("should show the current value of a getter", function()
            local value = "first"
            local control = Create({type = "text", get = function() return value end, titleFormat = function(text) return "<" .. text .. ">" end})
            assert.are.equal("<first>", control.titleFrame.text)

            value = "second"
            QuestieOptionsControls.Refresh(control)

            assert.are.equal("<second>", control.titleFrame.text)
        end)
    end)

    describe("button", function()
        it("should run its function when clicked", function()
            local func = spy.new(function() end)
            local control = Create({type = "button", btnLabel = "Press", func = func})

            control.widget:Click()

            assert.spy(func).was.called(1)
        end)

        it("should fit its label with padding", function()
            ui.stringWidth = 200

            local control = Create({type = "button", btnLabel = "Press"})

            assert.are.equal(224, control.widget:GetWidth())
            assert.are.equal(32, control.widget:GetHeight())
        end)

        it("should wrap a label wider than the row in a taller button", function()
            ui.stringWidth = 1000

            local control = Create({type = "button", btnLabel = "A very long label"})

            assert.are.equal(300, control.widget:GetWidth())
            assert.are.equal(48, control.widget:GetHeight())
        end)
    end)

    describe("sound button", function()
        it("should run its function when clicked", function()
            local func = spy.new(function() end)
            local control = Create({type = "soundButton", func = func})

            control.widget:Click()

            assert.spy(func).was.called(1)
        end)
    end)

    describe("color picker", function()
        local originalIsForever

        before_each(function()
            originalIsForever = Questie.IsForever
            ColorPickerFrame.SetupColorPickerAndShow = function(_, info) ColorPickerFrame.info = info end
            ColorPickerFrame.GetColorRGB = function() return 0.1, 0.2, 0.3 end
            ColorPickerFrame.GetColorAlpha = function() return 0.25 end
            ColorPickerFrame.GetPreviousValues = function() return 0.7, 0.8, 0.9, 0.5 end
        end)

        after_each(function()
            Questie.IsForever = originalIsForever
        end)

        local function CreatePicker(set, hasOpacity)
            return Create({
                type = "colorPicker",
                hasOpacity = hasOpacity,
                get = function() return 1, 0.5, 0, 0.75 end,
                set = set,
            })
        end

        it("should show the stored color on its swatch", function()
            local control = CreatePicker()

            assert.are_same({1, 0.5, 0, 0.75}, control.widget.swatch.vertexColor)
        end)

        it("should store each change immediately and combine the refreshes", function()
            local set = spy.new(function() end)
            local control = CreatePicker(set, true)
            Questie.IsForever = true

            control.widget:Click()
            ColorPickerFrame.info.swatchFunc()

            assert.spy(set).was.called_with(0.1, 0.2, 0.3, 0.25)
            assert.spy(QuestieOptionsEngine.QueueRefresh).was.called(1)
        end)

        it("should store full opacity for a color without an opacity setting", function()
            local set = spy.new(function() end)
            local control = CreatePicker(set, false)

            control.widget:Click()
            ColorPickerFrame.info.swatchFunc()

            assert.spy(set).was.called_with(0.1, 0.2, 0.3, 1)
        end)

        it("should invert the opacity on Classic, which reports it the other way around", function()
            local set = spy.new(function() end)
            local control = CreatePicker(set, true)
            Questie.IsForever = false

            control.widget:Click()
            ColorPickerFrame.info.opacityFunc()

            assert.spy(set).was.called_with(0.1, 0.2, 0.3, 0.75)
            assert.are.equal(0.25, ColorPickerFrame.info.opacity)
        end)

        describe("with the Classic picker", function()
            local sliderValue

            -- Follows Blizzard_FrameXML/Classic/ColorPickerFrame: setting it up reports the color right away,
            -- with whatever the slider still has. Only being shown moves the slider, which reports again.
            before_each(function()
                Questie.IsForever = false
                sliderValue = 0
                ColorPickerFrame:Hide()
                ColorPickerFrame.GetColorAlpha = function() return sliderValue end
                ColorPickerFrame.SetupColorPickerAndShow = function(self, info)
                    self.info = info
                    info.swatchFunc()
                    self:Show()
                end
                ColorPickerFrame:SetScript("OnShow", function(self)
                    sliderValue = self.info.opacity
                    self.info.opacityFunc()
                end)
            end)

            local function CreateStoredPicker(startingOpacity)
                local stored = {opacity = startingOpacity}
                stored.control = Create({
                    type = "colorPicker",
                    hasOpacity = true,
                    get = function() return 1, 1, 1, stored.opacity end,
                    set = function(_, _, _, opacity) stored.opacity = opacity end,
                })
                return stored
            end

            it("should keep the stored opacity when opened, even with another value left on the slider", function()
                local color = CreateStoredPicker(0.7)
                sliderValue = 0.6

                color.control.widget:Click()

                assert.near(0.7, color.opacity, 0.001)
            end)

            -- Found in the real client: this picker stays open when clicking elsewhere, so another swatch can be clicked
            it("should keep the next color's opacity when moving to it while the picker is open", function()
                local first = CreateStoredPicker(0.5)
                local second = CreateStoredPicker(0.7)
                first.control.widget:Click()
                sliderValue = 0.6
                ColorPickerFrame.info.opacityFunc()

                second.control.widget:Click()

                assert.near(0.7, second.opacity, 0.001)
                assert.near(0.3, sliderValue, 0.001)
            end)
        end)

        it("should restore the previous color when cancelled", function()
            local set = spy.new(function() end)
            local control = CreatePicker(set, true)
            Questie.IsForever = true

            control.widget:Click()
            ColorPickerFrame.info.cancelFunc()

            assert.spy(set).was.called_with(0.7, 0.8, 0.9, 0.5)
            assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
        end)
    end)

    describe("text box", function()
        local stored, set, control

        before_each(function()
            stored = "saved"
            set = spy.new(function(text) stored = text end)
            control = Create({type = "textbox", get = function() return stored end, set = set})
        end)

        it("should show the stored text with no confirmation button", function()
            assert.are.equal("saved", control.widget:GetText())
            assert.is_false(control.okBtn:IsShown())
        end)

        it("should only offer confirmation for new text that isn't blank", function()
            control.widget:SetText("new")
            control.widget.scripts.OnTextChanged(control.widget, true)
            assert.is_true(control.okBtn:IsShown())

            control.widget:SetText("   ")
            control.widget.scripts.OnTextChanged(control.widget, true)
            assert.is_false(control.okBtn:IsShown())

            control.widget:SetText("saved")
            control.widget.scripts.OnTextChanged(control.widget, true)
            assert.is_false(control.okBtn:IsShown())
        end)

        it("should store the text when Enter is pressed", function()
            control.widget:SetText("new")

            control.widget.scripts.OnEnterPressed(control.widget)

            assert.spy(set).was.called_with("new")
            assert.spy(QuestieOptionsEngine.RefreshStates).was.called(1)
        end)

        it("should restore the stored text when Escape is pressed", function()
            control.widget:SetText("new")

            control.widget.scripts.OnEscapePressed(control.widget)

            assert.are.equal("saved", control.widget:GetText())
            assert.spy(set).was.not_called()
        end)

        it("should not overwrite text the user is still typing during a refresh", function()
            control.widget.hasFocus = true
            control.widget:SetText("still typing")

            QuestieOptionsControls.Refresh(control)

            assert.are.equal("still typing", control.widget:GetText())
        end)

        it("should drop the focus when it becomes disabled", function()
            local isEnabled = true
            local disableable = Create({type = "textbox", enabled = function() return isEnabled end, get = function() return "x" end})
            disableable.widget.hasFocus = true

            isEnabled = false
            QuestieOptionsControls.Refresh(disableable)

            assert.is_false(disableable.widget:HasFocus())
            assert.is_false(disableable.okBtn:IsEnabled())
        end)

        it("should restore the stored text when the focus is lost", function()
            control.widget:SetText("new")

            control.widget.scripts.OnEditFocusLost(control.widget)

            assert.are.equal("saved", control.widget:GetText())
        end)

        -- Clicking the confirmation button takes the focus away first, so this would lose what is being confirmed.
        it("should keep the typed text when the focus goes to the confirmation button", function()
            control.widget:SetText("new")
            control.okBtn.mouseOver = true

            control.widget.scripts.OnEditFocusLost(control.widget)

            assert.are.equal("new", control.widget:GetText())
        end)

        it("should store the typed text when the confirmation button is clicked", function()
            control.widget:SetText("new")
            control.okBtn.mouseOver = true

            control.okBtn:Click()

            assert.spy(set).was.called_with("new")
        end)

        it("should grey out its art while disabled", function()
            local isEnabled = true
            local disableable = Create({type = "textbox", enabled = function() return isEnabled end})
            local region = CreateFrame("Texture")
            disableable.widget.regions = {region}

            isEnabled = false
            QuestieOptionsControls.Refresh(disableable)

            assert.is_true(region.isDesaturated)
        end)
    end)

    describe("container", function()
        -- A fixed low level can end up behind the background of Blizzard's settings panel.
        it("should draw its art below the controls next to it, relative to its parent", function()
            parent:SetFrameLevel(50)

            local control = Create({type = "container"})

            assert.are.equal(50, control.containerFrame:GetFrameLevel())
            assert.is_true(control.containerFrame:GetFrameLevel() < control:GetFrameLevel())
        end)

        it("should grey out its art while disabled", function()
            local isEnabled = true
            local control = Create({type = "container", enabled = function() return isEnabled end})
            local region = CreateFrame("Texture")
            control.containerFrame.regions = {region}

            isEnabled = false
            QuestieOptionsControls.Refresh(control)

            assert.is_true(region.isDesaturated)
        end)
    end)
end)
