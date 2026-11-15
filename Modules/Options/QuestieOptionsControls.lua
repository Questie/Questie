---Draws settings controls on a canvas and keeps them showing the current settings.
---
---Each control type below pairs a Create function with the Refresh that updates it, and is registered
---in CONTROL_TYPES at the bottom of this file. Adding a control type only touches this file.
---@class QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:CreateModule("QuestieOptionsControls")

---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

---@class QuestieOptionsControl: Button
---@field itemData table Normalized item definition, see QuestieOptionsLayout
---@field widget table? The frame the user interacts with
---@field titleFrame FontString?
---@field descriptionFrame FontString?
---@field contentArea Frame? Where a container's children are placed

---Base left and right padding of a canvas. Containers one level deep use half of it, deeper ones none.
QuestieOptionsControls.ROOT_INDENT = 20

local DEFAULT_LABEL_COLOR = {1, 0.82, 0, 1}
local DEFAULT_TEXT_COLOR = {1, 1, 1, 1}
local DISABLED_LABEL_COLOR = {0.65, 0.65, 0.65, 1}
local DISABLED_TEXT_COLOR = {0.55, 0.55, 0.55, 1}

local ENABLED_ART_COLOR = {1, 1, 1, 1}
local DISABLED_ART_COLOR = {0.7, 0.7, 0.7, 1}

-- Rows with a checkbox, radio button or color swatch have their labels to the right of it
local WIDGET_LABEL_INDENT = 38
local WIDGET_LABEL_WIDTH_INSET = 40

-------------------------
-- Shared by control types
-------------------------

---A function returning nil counts as enabled, so an option does not grey out on a setting that was never stored.
---@param item table
---@return boolean
local function _IsItemEnabled(item)
    local enabled = item.enabled
    if type(enabled) == "function" then
        enabled = enabled()
    end
    return enabled == nil or (enabled and true or false)
end

---@param widget table Frame that shows the tooltip while hovered
---@param item table
---@param attachPoint string
---@param x number
---@param y number
---@param childWidget table? Second frame that also shows the tooltip while hovered
local function _ApplyTooltip(widget, item, attachPoint, x, y, childWidget)
    if not item.tooltip then
        return
    end

    local function ShowTooltip()
        -- A tooltip always draws on top, so it could cover the entries of an open dropdown menu.
        -- That includes the one Blizzard's dropdown just showed, for text that doesn't fit.
        if Menu.GetManager():GetOpenMenu() then
            GameTooltip:Hide()
            return
        end

        GameTooltip:SetOwner(widget, attachPoint, x, y)
        GameTooltip:SetText(item.title, nil, nil, nil)
        GameTooltip:AddLine(item.tooltip, 1, 1, 1, true)
        GameTooltip:Show()
    end

    -- IsMouseOver only compares positions, so it is also true for a row hidden under the mouse. That runs OnLeave too.
    local function IsHovered(frame)
        return frame:IsVisible() and frame:IsMouseOver()
    end

    local function HideTooltip()
        if not IsHovered(widget) and not (childWidget and IsHovered(childWidget)) then
            GameTooltip:Hide()
        end
    end

    widget:HookScript("OnEnter", ShowTooltip)
    widget:HookScript("OnLeave", HideTooltip)
    QuestieOptionsUtils.HideTooltipOnHide(widget)

    if childWidget then
        childWidget:HookScript("OnEnter", ShowTooltip)
        childWidget:HookScript("OnLeave", HideTooltip)
    end
end

---@param control QuestieOptionsControl
---@param parent Frame
---@param width number
---@param height number
---@return Frame wrapper Holds a row's widget and labels, anchored to the control
local function _CreateRowWrapper(control, parent, width, height)
    local wrapper = CreateFrame("Frame", nil, parent)
    wrapper:SetPoint("LEFT", control, "LEFT", 0, 0)
    wrapper:SetSize(width, height)
    return wrapper
end

---Clicking anywhere on a row acts on its widget, and hovering the widget counts as hovering the row.
---@param control QuestieOptionsControl
---@param widget table
---@param item table
local function _ForwardRowInputToWidget(control, widget, item)
    control:RegisterForClicks("LeftButtonUp")
    control:SetScript("OnClick", function()
        if _IsItemEnabled(item) then
            widget:Click()
        end
    end)

    widget:SetScript("OnEnter", function()
        local onEnter = control:GetScript("OnEnter")
        if onEnter then onEnter(control) end
    end)
    widget:SetScript("OnLeave", function()
        local onLeave = control:GetScript("OnLeave")
        if onLeave then onLeave(control) end
    end)
end

---Adds a row's title and optional description, growing the control when wrapped text needs more height.
---@param control QuestieOptionsControl
---@param wrapper Frame
---@param item table
---@param titleText string?
---@param indent number Horizontal offset of the labels from the left of the row
---@param labelWidth number
---@param titleAlign string
---@param descriptionAlign string
local function _AddRowLabels(control, wrapper, item, titleText, indent, labelWidth, titleAlign, descriptionAlign)
    local titleFrame = wrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
    titleFrame:SetText(titleText)
    titleFrame:SetWordWrap(true)
    titleFrame:SetJustifyH(titleAlign)
    titleFrame:SetWidth(labelWidth)
    if item.titleSize then
        titleFrame:SetFontHeight(item.titleSize)
    end
    control.titleFrame = titleFrame

    -- Without a description the title sits in line with the widget
    if not item.description then
        titleFrame:SetPoint("LEFT", wrapper, "LEFT", indent, 0)
        local titleHeight = titleFrame:GetStringHeight()
        if titleHeight > wrapper:GetHeight() then
            wrapper:SetHeight(titleHeight)
            control:SetHeight(titleHeight)
        end
        return
    end

    titleFrame:SetPoint("LEFT", wrapper, "LEFT", indent, 6)

    local descriptionFrame = wrapper:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    descriptionFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, -2)
    descriptionFrame:SetText(item.description)
    descriptionFrame:SetWordWrap(true)
    descriptionFrame:SetJustifyH(descriptionAlign)
    descriptionFrame:SetWidth(labelWidth)
    if item.descriptionSize then
        descriptionFrame:SetFontHeight(item.descriptionSize)
    end
    control.descriptionFrame = descriptionFrame

    -- The description is offset 2 units below the title
    local labelsHeight = titleFrame:GetStringHeight() + descriptionFrame:GetStringHeight() + 2
    if labelsHeight > wrapper:GetHeight() then
        control:SetHeight(labelsHeight)
        titleFrame:SetPoint("TOPLEFT", control, "TOPLEFT", indent, 0)
    end
end

---@param control QuestieOptionsControl
---@param wrapper Frame
---@param item table
---@param width number
local function _AddWidgetLabels(control, wrapper, item, width)
    _AddRowLabels(control, wrapper, item, item.title, WIDGET_LABEL_INDENT, width - WIDGET_LABEL_WIDTH_INSET, "LEFT", "LEFT")
end

---@param frame table
---@param disable boolean
local function _DesaturateNineSlice(frame, disable)
    local nineSlice = frame.NineSlice or frame
    if nineSlice and nineSlice.GetRegions then
        for _, region in ipairs({nineSlice:GetRegions()}) do
            if region:IsObjectType("Texture") then
                region:SetDesaturated(disable)
                region:SetVertexColor(unpack(disable and DISABLED_ART_COLOR or ENABLED_ART_COLOR))
            end
        end
    end
end

-------------------------
-- Checkbox
-------------------------

local function _CreateCheckbox(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, 30)

    local checkbox = CreateFrame("CheckButton", nil, wrapper, "SettingsCheckboxTemplate")
    checkbox:SetPoint("LEFT", wrapper, "LEFT", 0, 0)

    -- Layer the art: the box at the bottom, the hover highlight above it, and the checkmark on top
    local disabledTexture = checkbox:CreateTexture(nil, "BACKGROUND", nil, 0)
    disabledTexture:SetAtlas("checkbox-minimal", nil, "TRILINEAR")
    disabledTexture:SetDesaturated(true)
    disabledTexture:SetVertexColor(unpack(DISABLED_ART_COLOR))
    checkbox:SetDisabledTexture(disabledTexture)

    local normalTexture = checkbox:GetNormalTexture()
    if normalTexture then
        normalTexture:SetDrawLayer("BACKGROUND", 0)
    end

    local hoverTexture = checkbox:CreateTexture(nil, "ARTWORK", nil, 1)
    hoverTexture:SetAllPoints(checkbox, true)
    hoverTexture:SetTexture("Interface\\Addons\\Questie\\Icons\\checkbox-minimal-highlight.png")
    hoverTexture:SetBlendMode("ADD")
    hoverTexture:SetAlpha(0.5)
    hoverTexture:Hide()
    checkbox.HoverTex = hoverTexture

    local checkedTexture = checkbox:GetCheckedTexture()
    if checkedTexture then
        checkedTexture:SetDrawLayer("OVERLAY", 1)
    end

    local disabledCheckedTexture = checkbox:GetDisabledCheckedTexture()
    if disabledCheckedTexture then
        disabledCheckedTexture:SetDrawLayer("OVERLAY", 1)
    end

    _ForwardRowInputToWidget(control, checkbox, item)
    _AddWidgetLabels(control, wrapper, item, width)

    checkbox:SetScript("OnClick", function(self)
        if item.set then item.set(self, self:GetChecked()) end
        QuestieOptionsEngine:RefreshStates()
    end)

    -- IsMouseOver only compares positions and stays true for a row hidden under the mouse, so like the tooltip, check visibility
    local function UpdateHover()
        local isOver = control:IsVisible() and (control:IsMouseOver() or checkbox:IsMouseOver())
        hoverTexture:SetShown(isOver and checkbox:IsEnabled())
    end

    control:HookScript("OnEnter", UpdateHover)
    control:HookScript("OnLeave", UpdateHover)
    checkbox:HookScript("OnEnter", UpdateHover)
    checkbox:HookScript("OnLeave", UpdateHover)
    -- In case closing the settings under the mouse runs OnLeave while the row still counts as visible, or not at all
    control:HookScript("OnHide", function()
        hoverTexture:Hide()
    end)

    control.widget = checkbox

    _ApplyTooltip(control, item, "ANCHOR_TOPLEFT", 2, 0)
end

local function _RefreshCheckbox(control, item, isEnabled)
    local currentValue = item.get and item.get()
    control.widget:SetChecked(currentValue == true or currentValue == 1)
    if not isEnabled then
        control.widget.HoverTex:Hide()
    end
end

-------------------------
-- Radio button
-------------------------

-- Texture coordinates in the Classic dropdown art, which has no atlas entries for these
local RADIO_SLOT_COORDS = {285 / 512, 329 / 512, 121 / 512, 165 / 512}
local RADIO_TICK_COORDS = {465 / 512, 509 / 512, 1 / 512, 45 / 512}

---@param radio table
---@param foreverAtlas string
---@param classicCoords number[]
---@param desaturated boolean?
---@return Texture
local function _NewRadioTexture(radio, foreverAtlas, classicCoords, desaturated)
    local texture = radio:CreateTexture(nil, "ARTWORK")
    if Questie.IsForever then
        texture:SetAtlas(foreverAtlas, nil, "TRILINEAR")
    else
        texture:SetTexture("interface\\common\\commondropdownclassic2x", nil, nil, "TRILINEAR")
        texture:SetTexCoord(unpack(classicCoords))
    end
    if desaturated then
        texture:SetDesaturated(true)
    end
    return texture
end

-- There is no good radio button template to base this on, so it is built from a checkbox with its own art
local function _CreateRadioButton(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, 20)

    local radio = CreateFrame("CheckButton", nil, wrapper, "SettingsCheckboxTemplate")
    if Questie.IsForever then
        radio:SetPoint("LEFT", wrapper, "LEFT", 0, 0)
    else
        radio:SetPoint("LEFT", wrapper, "LEFT", 4, 0)
        radio:SetSize(22, 22)
    end

    local slotAtlas = "gamepad-flyout-circular-slot-normal"
    local tickAtlas = "common-dropdown-icon-radialtick-yellow"
    radio:SetNormalTexture(_NewRadioTexture(radio, slotAtlas, RADIO_SLOT_COORDS))
    radio:SetPushedTexture(_NewRadioTexture(radio, slotAtlas, RADIO_SLOT_COORDS))
    -- Forever has dedicated disabled art for the slot, Classic greys out the normal art
    radio:SetDisabledTexture(_NewRadioTexture(radio, "gamepad-flyout-circular-slot-disabled", RADIO_SLOT_COORDS, not Questie.IsForever))
    radio:SetCheckedTexture(_NewRadioTexture(radio, tickAtlas, RADIO_TICK_COORDS))
    radio:SetDisabledCheckedTexture(_NewRadioTexture(radio, tickAtlas, RADIO_TICK_COORDS, true))

    _ForwardRowInputToWidget(control, radio, item)
    _AddWidgetLabels(control, wrapper, item, width)

    radio:SetScript("OnClick", function()
        if item.set then item.set(item.value) end
        QuestieOptionsEngine:RefreshStates()
    end)

    control.widget = radio

    _ApplyTooltip(control, item, "ANCHOR_TOPLEFT", 2, 0)
end

local function _RefreshRadioButton(control, item)
    control.widget:SetChecked(item.get and item.get(item.value))
end

-------------------------
-- Slider
-------------------------

---@param item table
---@param value number
---@return string
local function _FormatSliderValue(item, value)
    if item.isPercent then
        return string.format("%d%%", math.floor((value * 100) + 0.5))
    end
    return string.format("%g", value)
end

local function _CreateSlider(control, _, item, width)
    local slider = CreateFrame("Slider", nil, control, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", control, "TOPLEFT", 15, -15)
    slider:SetWidth(width - 30)
    slider:SetMinMaxValues(item.min, item.max)
    slider:SetValueStep(item.step)
    slider:SetObeyStepOnDrag(true)
    control.widget = slider

    if slider.Text then
        slider.Text:SetText(item.title)
        slider.Text:SetFontObject("GameFontNormalSmall2")
    end
    if slider.Low then
        slider.Low:SetText(item.minLabel or _FormatSliderValue(item, item.min))
        slider.Low:SetFontObject("GameFontDisableTiny")
    end
    if slider.High then
        slider.High:SetText(item.maxLabel or _FormatSliderValue(item, item.max))
        slider.High:SetFontObject("GameFontDisableTiny")
    end

    local valueDisplay
    if item.showValue then
        valueDisplay = control:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valueDisplay:SetPoint("TOP", slider, "BOTTOM", 0, -1)
        control.valueDisplay = valueDisplay
    end

    slider:SetScript("OnValueChanged", function(self, value, userInput)
        if not control.isShowingStoredValue then
            control.isDragging = userInput or control.isDragging
            if item.set then item.set(self, value, userInput) end
        end
        if valueDisplay then valueDisplay:SetText(_FormatSliderValue(item, value)) end
    end)

    -- Setters run with userInput = true during a drag. This final call without it is how they learn the drag
    -- ended, for example the tracker ratios leaving their sizing mode.
    local function FinishDrag(self)
        if control.isDragging then
            control.isDragging = false
            if item.set then item.set(self, self:GetValue(), false) end
        end
    end

    slider:HookScript("OnMouseUp", function(self)
        FinishDrag(self)
        QuestieOptionsEngine:RefreshStates()
    end)

    -- The mouse-up never arrives when the window closes during a drag, for example with the Escape key
    slider:HookScript("OnHide", FinishDrag)

    -- Hide the default artwork so the minimal track and thumb can be drawn instead
    if slider.NineSlice then
        slider.NineSlice:Hide()
    end

    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetAtlas("Minimal_SliderBar_Button", true)
        thumb:SetSize(16, 16)
        control.thumb = thumb
    end

    local trackLeft = slider:CreateTexture(nil, "BACKGROUND")
    trackLeft:SetAtlas("Minimal_SliderBar_Left", true)
    trackLeft:SetPoint("LEFT", slider, "LEFT", 0, 0)

    local trackRight = slider:CreateTexture(nil, "BACKGROUND")
    trackRight:SetAtlas("Minimal_SliderBar_Right", true)
    trackRight:SetPoint("RIGHT", slider, "RIGHT", 0, 0)

    local trackMiddle = slider:CreateTexture(nil, "BACKGROUND")
    trackMiddle:SetAtlas("_Minimal_SliderBar_Middle", false)
    trackMiddle:SetPoint("LEFT", trackLeft, "RIGHT", 0, 0)
    trackMiddle:SetPoint("RIGHT", trackRight, "LEFT", 0, 0)
    trackMiddle:SetHeight(trackLeft:GetHeight())

    slider.TrackLeft = trackLeft
    slider.TrackRight = trackRight
    slider.TrackMiddle = trackMiddle

    _ApplyTooltip(slider, item, "ANCHOR_TOP", 0, 14)
end

local function _RefreshSlider(control, item, isEnabled, labelColor, textColor)
    local slider = control.widget

    if slider.Text then slider.Text:SetTextColor(unpack(labelColor)) end
    if control.valueDisplay then control.valueDisplay:SetTextColor(unpack(textColor)) end
    if control.thumb then
        control.thumb:SetDesaturated(not isEnabled)
        control.thumb:SetAlpha(isEnabled and 1.0 or 0.5) -- Helps tell the disabled state apart in the grey Dragonflight theme
    end
    slider.TrackLeft:SetDesaturated(not isEnabled)
    slider.TrackMiddle:SetDesaturated(not isEnabled)
    slider.TrackRight:SetDesaturated(not isEnabled)

    -- Moving the thumb fires OnValueChanged. Showing a stored value must not run the setter again:
    -- setters have side effects, like the tracker ratios overwriting the backdrop settings when not dragged.
    local storedValue = item.get and tonumber((item.get())) or item.min
    control.isShowingStoredValue = true
    slider:SetValue(storedValue)
    control.isShowingStoredValue = false

    -- The text shows the setting, not the thumb, which snaps to the steps counted from the minimum: an Icon Limit
    -- of 1500 has its thumb on 1501. It is set here because OnValueChanged doesn't fire when the thumb stays in place.
    if control.valueDisplay then
        control.valueDisplay:SetText(_FormatSliderValue(item, storedValue))
    end
end

-------------------------
-- Dropdowns
-------------------------

---Creates a dropdown with its title above it.
---
---Blizzard generates a dropdown's menu every time it is shown, only to find the text of the selected entry. With many
---long menus on a tab, that is by far the most expensive part of showing it. So a menu only has all of its entries
---while it is open. Until then it only has the selected one, which is all the text needs.
---@param control QuestieOptionsControl
---@param item table
---@param width number
---@param fillMenu fun(rootDescription: table) Adds every entry
---@param addSelectedEntry fun(rootDescription: table) Adds only the entry of the current setting, if there is one
local function _CreateDropdownFrame(control, item, width, fillMenu, addSelectedEntry)
    local dropdown = CreateFrame("DropdownButton", nil, control, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("TOPLEFT", control, "TOPLEFT", 10, -18)
    dropdown:SetWidth(width - 20)
    control.widget = dropdown

    local titleFrame = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleFrame:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 6, 2)
    titleFrame:SetText(item.title)
    control.titleFrame = titleFrame

    -- OpenMenu generates the menu before it counts as open, and clicks reach it through SetMenuOpen. Checked in Blizzard's
    -- source for every supported client (see AGENTS.md), so this sees every open and doesn't need to generate it as well.
    local isOpening = false
    local openMenu = dropdown.OpenMenu
    dropdown.OpenMenu = function(self)
        isOpening = true
        openMenu(self)
        isOpening = false

        -- A long menu can open upward, over the tooltip of its own dropdown
        if self:IsMenuOpen() then
            GameTooltip:Hide()
        end
    end

    -- SetupMenu generates the menu right away, so the first refresh has nothing to catch up on
    control.lastValue = item.get and item.get()
    dropdown:SetupMenu(function(_, rootDescription)
        if isOpening or dropdown:IsMenuOpen() then
            fillMenu(rootDescription)
        else
            addSelectedEntry(rootDescription)
        end
    end)

    _ApplyTooltip(control, item, "ANCHOR_TOPLEFT", 0, 0, dropdown)
    -- Blizzard's tooltip for text that doesn't fit belongs to the dropdown itself
    QuestieOptionsUtils.HideTooltipOnHide(dropdown)
end

---@param rootDescription table
---@param item table
---@param text string
---@param key any Value stored when this entry is picked
---@return table entry
local function _AddMenuChoice(rootDescription, item, text, key)
    local function IsSelected()
        return item.get and item.get() == key
    end

    local function Select()
        if item.set then item.set(key) end
        QuestieOptionsEngine:RefreshStates()
    end

    return rootDescription:CreateRadio(text, IsSelected, Select, key)
end

---@param options table<any, string> Display text by key
---@param sorting any[]? Explicit key order. Keys missing from options are skipped.
---@return any[] orderedKeys Alphabetical by display text when no explicit order is given
local function _GetMenuKeysInOrder(options, sorting)
    local orderedKeys = {}

    if type(sorting) == "table" and #sorting > 0 then
        for _, key in ipairs(sorting) do
            if options[key] ~= nil then
                table.insert(orderedKeys, key)
            end
        end
        return orderedKeys
    end

    for key in pairs(options) do
        table.insert(orderedKeys, key)
    end
    table.sort(orderedKeys, function(a, b)
        return tostring(options[a] or a):lower() < tostring(options[b] or b):lower()
    end)
    return orderedKeys
end

---@param item table
---@return table<any, string> options Display text by key
local function _GetDropdownOptions(item)
    local options = item.options
    if type(options) == "function" then
        options = options()
    end
    return options or {}
end

local function _CreateDropdown(control, _, item, width)
    local function FillMenu(rootDescription)
        local options = _GetDropdownOptions(item)

        local sorting = item.sortOrder
        if type(sorting) == "function" then
            sorting = sorting()
        end

        for _, key in ipairs(_GetMenuKeysInOrder(options, sorting)) do
            _AddMenuChoice(rootDescription, item, options[key], key)
        end
    end

    local function AddSelectedEntry(rootDescription)
        local selectedKey = item.get and item.get()
        local text = selectedKey ~= nil and _GetDropdownOptions(item)[selectedKey]
        if text then
            _AddMenuChoice(rootDescription, item, text, selectedKey)
        end
    end

    _CreateDropdownFrame(control, item, width, FillMenu, AddSelectedEntry)
end

-- CreateFont names are global, so the preview fonts are shared between every font dropdown
local fontPreviewObjects = {}
local fontPreviewCount = 0

---@param fontPath string
---@return Font
local function _GetFontPreviewObject(fontPath)
    if not fontPreviewObjects[fontPath] then
        fontPreviewCount = fontPreviewCount + 1
        local font = CreateFont("QuestieDropdownFont_" .. fontPreviewCount)
        local _, _, flags = GameFontHighlightSmall:GetFont()
        font:SetFont(fontPath, 14, flags or "")
        font:SetTextColor(unpack(DEFAULT_TEXT_COLOR))
        fontPreviewObjects[fontPath] = font
    end
    return fontPreviewObjects[fontPath]
end

local function _CreateFontDropdown(control, _, item, width)
    local fonts = item.fonts or {}

    local function FillMenu(rootDescription)
        rootDescription:SetScrollMode(250)

        local fontNames = {}
        for name in pairs(fonts) do
            table.insert(fontNames, name)
        end
        table.sort(fontNames, function(a, b) return a:lower() < b:lower() end)

        for _, fontName in ipairs(fontNames) do
            local fontPath = fonts[fontName]
            local entry = _AddMenuChoice(rootDescription, item, fontName, fontName)

            -- Render each entry in its own font
            entry:AddInitializer(function(button)
                if button.fontString and fontPath then
                    button.fontString:SetFontObject(_GetFontPreviewObject(fontPath))
                end
            end)
        end
    end

    local function AddSelectedEntry(rootDescription)
        local selectedFont = item.get and item.get()
        if selectedFont ~= nil and fonts[selectedFont] then
            _AddMenuChoice(rootDescription, item, selectedFont, selectedFont)
        end
    end

    _CreateDropdownFrame(control, item, width, FillMenu, AddSelectedEntry)
end

-- Never equal to a setting, so the next refresh always regenerates the menu
local UNKNOWN_DROPDOWN_VALUE = {}

local function _RefreshDropdown(control, item, isEnabled)
    _DesaturateNineSlice(control.widget, not isEnabled)

    -- GenerateMenu updates the text showing the selected entry, so it only runs when that could change
    local currentValue = item.get and item.get()
    if control.lastValue == currentValue then
        return
    end

    if control.widget:IsMenuOpen() then
        -- Picking an entry refreshes from inside its own click, and regenerating would replace the menu being clicked.
        -- A pick updates the text but Escape doesn't, so what it shows after closing is unknown until the next refresh.
        control.lastValue = UNKNOWN_DROPDOWN_VALUE
    else
        control.lastValue = currentValue
        control.widget:GenerateMenu()
    end
end

-------------------------
-- Divider
-------------------------

---@param wrapper Frame
---@param titleFrame FontString
---@param side "LEFT"|"RIGHT" Which side of the title the line is on
---@param texCoordLeft number?
---@param texCoordRight number?
local function _AddDividerLine(wrapper, titleFrame, side, texCoordLeft, texCoordRight)
    local line = wrapper:CreateTexture(nil, "ARTWORK")
    if side == "LEFT" then
        line:SetPoint("LEFT", wrapper, "LEFT", 0, 0)
        line:SetPoint("RIGHT", titleFrame, "LEFT", -6, 0)
    else
        line:SetPoint("RIGHT", wrapper, "RIGHT", 0, 0)
        line:SetPoint("LEFT", titleFrame, "RIGHT", 6, 0)
    end
    line:SetAtlas("Options_HorizontalDivider", true)
    if texCoordLeft then
        line:SetTexCoord(texCoordLeft, texCoordRight, 0, 1)
    end
    QuestieOptionsUtils.DisableSnapping(line)
end

local function _CreateDivider(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, control:GetHeight())

    if item.title == "" then
        local line = wrapper:CreateTexture(nil, "ARTWORK")
        line:SetPoint("CENTER", wrapper, "CENTER", 0, 0)
        line:SetSize(width, 1)
        line:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        return
    end

    local titleFrame = wrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
    titleFrame:SetText(item.title)
    control.titleFrame = titleFrame

    if item.titleAlign == "LEFT" then
        titleFrame:SetPoint("LEFT", wrapper, "LEFT", 0, 0)
        _AddDividerLine(wrapper, titleFrame, "RIGHT")
    elseif item.titleAlign == "RIGHT" then
        titleFrame:SetPoint("RIGHT", wrapper, "RIGHT", 0, 0)
        _AddDividerLine(wrapper, titleFrame, "LEFT", 1, 0)
    else
        titleFrame:SetPoint("CENTER", wrapper, "CENTER", 0, 0)
        _AddDividerLine(wrapper, titleFrame, "LEFT", 1, 0.4)
        _AddDividerLine(wrapper, titleFrame, "RIGHT", 0.4, 1)
    end
end

-------------------------
-- Container
-------------------------

local function _CreateContainer(control, parent, item, _, level)
    -- The border bleeds out over the canvas padding, which shrinks with nesting depth
    local bleed = 0
    if level == 1 then
        bleed = QuestieOptionsControls.ROOT_INDENT
    elseif level == 2 then
        bleed = QuestieOptionsControls.ROOT_INDENT / 2
    end

    local containerFrame = CreateFrame("Frame", nil, control, "NineSlicePanelTemplate")
    containerFrame:SetPoint("TOPLEFT", control, "TOPLEFT", -bleed - 4, 2)
    containerFrame:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", bleed + 1, -6)
    containerFrame:SetAlpha(0.45)
    -- Below the controls next to it. Relative to the parent, because a fixed level can end up behind the
    -- background of Blizzard's settings panel, which this frame may already be inside of.
    containerFrame:SetFrameLevel(parent:GetFrameLevel())
    control.containerFrame = containerFrame

    NineSliceUtil.ApplyLayoutByName(containerFrame, "TooltipGluesLayout")

    local titleFrame = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleFrame:SetPoint("BOTTOMLEFT", control, "TOPLEFT", -bleed + 30, 4)
    titleFrame:SetText(item.title)
    control.titleFrame = titleFrame

    local content = CreateFrame("Frame", nil, control)
    content:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
    content:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", 0, 0)
    control.contentArea = content
end

local function _RefreshContainer(control, _, isEnabled)
    _DesaturateNineSlice(control.containerFrame, not isEnabled)
end

-------------------------
-- Text
-------------------------

local function _CreateText(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, 30)

    local titleText = item.title
    if item.get then
        titleText = item.get()
    end
    if item.titleFormat then
        titleText = item.titleFormat(titleText)
    end

    _AddRowLabels(control, wrapper, item, titleText, 0, width, item.titleAlign, item.descriptionAlign)

    _ApplyTooltip(control, item, "ANCHOR_TOPLEFT", 2, 0)
end

local function _RefreshText(control, item)
    if item.get then
        local titleText = tostring(item.get() or "")
        if item.titleFormat then
            titleText = item.titleFormat(titleText)
        end
        control.titleFrame:SetText(titleText)
    end
end

-------------------------
-- Button
-------------------------

-- Pixel sizes of the red button art
local BUTTON_ART_HEIGHT = 128
local BUTTON_ART_LEFT_WIDTH = 114
local BUTTON_ART_RIGHT_WIDTH = 292

local BUTTON_HEIGHT = 32
local BUTTON_HORIZONTAL_PADDING = 24

---@param buttonHeight number
---@return number leftWidth
---@return number rightWidth
local function _GetButtonEndWidths(buttonHeight)
    local scale = buttonHeight / BUTTON_ART_HEIGHT
    return math.floor(BUTTON_ART_LEFT_WIDTH * scale), math.floor(BUTTON_ART_RIGHT_WIDTH * scale)
end

---Red button art for one state, stretched by moving its left, center and right pieces together.
---@param button Button
---@param atlases {left: string, center: string, right: string}
---@return table slices
local function _CreateButtonSlices(button, atlases)
    local leftWidth, rightWidth = _GetButtonEndWidths(BUTTON_HEIGHT)

    local left = button:CreateTexture(nil, "BACKGROUND")
    left:SetPoint("LEFT", button, "LEFT", 0, 0)
    left:SetSize(leftWidth, BUTTON_HEIGHT)
    left:SetAtlas(atlases.left, false)

    local right = button:CreateTexture(nil, "BACKGROUND")
    right:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    right:SetSize(rightWidth, BUTTON_HEIGHT)
    right:SetAtlas(atlases.right, false)

    local center = button:CreateTexture(nil, "BACKGROUND")
    center:SetPoint("LEFT", left, "RIGHT", 0, 0)
    center:SetPoint("RIGHT", right, "LEFT", 0, 0)
    center:SetHeight(BUTTON_HEIGHT)
    center:SetAtlas(atlases.center, false)
    center:SetHorizTile(true)

    return {
        left = left,
        center = center,
        right = right,
        SetShown = function(self, shown)
            self.left:SetShown(shown)
            self.center:SetShown(shown)
            self.right:SetShown(shown)
        end,
    }
end

local function _CreateButton(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, control:GetHeight())

    local button = CreateFrame("Button", nil, wrapper)

    local text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetFontObject("GameFontHighlight")
    button:SetFontString(text)

    button:SetHeight(BUTTON_HEIGHT)

    local slices = {
        normal = _CreateButtonSlices(button, {left = "128-RedButton-Left", center = "_128-RedButton-Center", right = "128-RedButton-Right"}),
        disabled = _CreateButtonSlices(button, {left = "128-RedButton-Left-Disabled", center = "_128-RedButton-Center-Disabled", right = "128-RedButton-Right-Disabled"}),
        pressed = _CreateButtonSlices(button, {left = "128-RedButton-Left-Pressed", center = "_128-RedButton-Center-Pressed", right = "128-RedButton-Right-Pressed"}),
    }

    local function UpdateVisualState(self)
        local isEnabled = self:IsEnabled()
        local isPushed = self.isPressed and isEnabled

        slices.disabled:SetShown(not isEnabled)
        slices.pressed:SetShown(isPushed)
        slices.normal:SetShown(isEnabled and not isPushed)

        if not isEnabled then
            text:SetTextColor(unpack(DISABLED_TEXT_COLOR))
        elseif self.isHovered then
            text:SetTextColor(unpack(DEFAULT_TEXT_COLOR))
        else
            text:SetTextColor(unpack(DEFAULT_LABEL_COLOR))
        end
    end

    button:SetHighlightAtlas("128-RedButton-Highlight")
    button:HookScript("OnMouseDown", function(self, buttonName)
        if self:IsEnabled() and buttonName == "LeftButton" then
            self.isPressed = true
            UpdateVisualState(self)
        end
    end)
    button:HookScript("OnMouseUp", function(self, buttonName)
        if buttonName == "LeftButton" then
            self.isPressed = false
            UpdateVisualState(self)
        end
    end)
    button:HookScript("OnEnter", function(self)
        if self:IsEnabled() then
            self.isHovered = true
            UpdateVisualState(self)
        end
    end)
    button:HookScript("OnLeave", function(self)
        self.isHovered = false
        UpdateVisualState(self)
    end)
    -- OnLeave and OnMouseUp can't be relied on when the settings close under the mouse, like from My Journey
    button:HookScript("OnHide", function(self)
        self.isHovered = false
        self.isPressed = false
        UpdateVisualState(self)
    end)
    button:HookScript("OnEnable", UpdateVisualState)
    button:HookScript("OnDisable", UpdateVisualState)

    -- Size the button to its label. A label too wide for the row wraps inside a taller button instead.
    local minLeftWidth, minRightWidth = _GetButtonEndWidths(BUTTON_HEIGHT)
    local rawSetText = button.SetText
    button.SetText = function(self, newText)
        text:SetFontObject("GameFontHighlight")
        text:SetWidth(0)
        text:SetHeight(0)
        text:SetWordWrap(false)

        rawSetText(self, newText)

        local targetWidth = math.max(minLeftWidth + minRightWidth, (text:GetStringWidth() or 0) + BUTTON_HORIZONTAL_PADDING)
        local isExpanded = targetWidth > width
        if isExpanded then
            targetWidth = width
        end

        local currentHeight = isExpanded and (BUTTON_HEIGHT * 1.5) or BUTTON_HEIGHT
        local leftWidth, rightWidth = _GetButtonEndWidths(currentHeight)

        self:SetSize(targetWidth, currentHeight)

        for _, stateSlices in pairs(slices) do
            stateSlices.left:SetSize(leftWidth, currentHeight)
            stateSlices.right:SetSize(rightWidth, currentHeight)
            stateSlices.center:SetHeight(currentHeight)
        end

        if isExpanded then
            text:SetWidth(targetWidth - BUTTON_HORIZONTAL_PADDING)
            text:SetHeight(currentHeight - 8)
            text:SetWordWrap(true)
            text:SetJustifyV("MIDDLE")
        end
    end

    UpdateVisualState(button)

    button:SetText(item.btnLabel)
    button:SetPoint(item.align, wrapper, item.align, 0, 0)
    button:SetScript("OnClick", function()
        if item.func then
            item.func()
        end
    end)

    control.widget = button

    _ApplyTooltip(button, item, "ANCHOR_TOPLEFT", 2, 0)
end

-------------------------
-- Sound button
-------------------------

---@param button Button
---@param atlas string
---@param degrees number
---@param flipVertically boolean?
---@param flipHorizontally boolean?
---@return Texture
local function _NewArrowTexture(button, atlas, degrees, flipVertically, flipHorizontally)
    local texture = button:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(button)
    texture:SetAtlas(atlas, nil, "TRILINEAR")

    if flipVertically then
        texture:SetTexCoord(0, 1, 1, 0)
    elseif flipHorizontally then
        texture:SetTexCoord(1, 0, 0, 1)
    end

    texture:SetRotation(math.rad(degrees))
    return texture
end

-- The play symbol is the red button's down arrow, rotated sideways
local function _CreateSoundButton(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, control:GetHeight())

    local button = CreateFrame("Button", nil, wrapper)
    button:SetSize(32, 32)
    button:SetPoint(item.align, wrapper, item.align, 0, 0)

    button:SetNormalTexture(_NewArrowTexture(button, "128-RedButton-ArrowDown", 90, false, true))
    button:SetPushedTexture(_NewArrowTexture(button, "128-RedButton-ArrowDown-Pressed", -90, true))
    button:SetDisabledTexture(_NewArrowTexture(button, "128-RedButton-ArrowDown-Disabled", 90, false, true))
    button:SetHighlightTexture(_NewArrowTexture(button, "128-RedButton-ArrowDown-Highlight", 90))

    button:SetScript("OnClick", function()
        if item.func then
            item.func()
        end
    end)

    control.widget = button

    _ApplyTooltip(button, item, "ANCHOR_TOPLEFT", 2, 0)
end

-------------------------
-- Color picker
-------------------------

---Classic clients report opacity from the color picker inverted, with 0 as opaque and 1 as transparent.
---@param alpha number?
---@return number
local function _ConvertPickerAlpha(alpha)
    if not Questie.IsForever then
        return 1 - (alpha or 1)
    end
    return alpha or 1
end

local function _CreateColorPicker(control, parent, item, width)
    local wrapper = _CreateRowWrapper(control, parent, width, 30)

    local swatchButton = CreateFrame("Button", nil, wrapper)
    swatchButton:SetSize(28, 28)
    swatchButton:SetPoint("LEFT", wrapper, "LEFT", 0, 0)

    local border = swatchButton:CreateTexture(nil, "ARTWORK")
    if Questie.IsForever then
        border:SetAtlas("UI-HUD-Minimap-Frame-Cycle")
        border:SetSize(28, 28)
    else
        border:SetAtlas("Trinket-Frame")
        border:SetSize(34, 34)
    end
    border:SetPoint("CENTER", swatchButton, "CENTER", 0, 0)
    swatchButton.border = border

    local swatch = swatchButton:CreateTexture(nil, "BACKGROUND")
    swatch:SetColorTexture(1, 1, 1, 1)
    swatch:SetSize(18, 18)
    swatch:SetPoint("CENTER", swatchButton, "CENTER", 0, 0)
    swatchButton.swatch = swatch

    -- Mask the swatch to a circle
    local mask = swatchButton:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(swatch)
    swatch:AddMaskTexture(mask)

    _ForwardRowInputToWidget(control, swatchButton, item)
    _AddWidgetLabels(control, wrapper, item, width)

    swatchButton:SetScript("OnClick", function()
        local currentR, currentG, currentB, currentA = 1, 1, 1, 1
        if item.get then
            currentR, currentG, currentB, currentA = item.get()
        end

        -- Runs for every change while the picker is open, so the refresh waits for the end of the frame
        local function OnColorChanged()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = item.hasOpacity and _ConvertPickerAlpha(ColorPickerFrame:GetColorAlpha()) or 1
            if item.set then item.set(r, g, b, a) end
            QuestieOptionsEngine:QueueRefresh()
        end

        -- The Classic picker only moves its opacity slider when it gets shown, and it stays open when clicking elsewhere.
        -- Without this, the color from another swatch would take the opacity that the slider still has.
        ColorPickerFrame:Hide()
        ColorPickerFrame:SetupColorPickerAndShow({
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = function()
                local r, g, b, a = ColorPickerFrame:GetPreviousValues()
                if item.set then item.set(r, g, b, _ConvertPickerAlpha(a)) end
                QuestieOptionsEngine:RefreshStates()
            end,
            r = currentR,
            g = currentG,
            b = currentB,
            opacity = _ConvertPickerAlpha(currentA),
            hasOpacity = item.hasOpacity or false,
            previousValues = {r = currentR, g = currentG, b = currentB, a = currentA},
        })
    end)

    control.widget = swatchButton

    _ApplyTooltip(control, item, "ANCHOR_TOPLEFT", 2, 0)
end

local function _RefreshColorPicker(control, item, isEnabled)
    local border = control.widget.border
    border:SetDesaturated(not isEnabled)
    border:SetVertexColor(unpack(isEnabled and ENABLED_ART_COLOR or DISABLED_ART_COLOR))

    local r, g, b, a
    if item.get then
        r, g, b, a = item.get()
    end
    control.widget.swatch:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
end

-------------------------
-- Text box
-------------------------

local function _CreateTextbox(control, _, item, width)
    local editBox = CreateFrame("EditBox", nil, control, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", control, "TOPLEFT", 16, -18)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    if item.textBoxCharLimit then editBox:SetMaxLetters(item.textBoxCharLimit) end
    control.widget = editBox

    local titleFrame = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleFrame:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", -2, 4)
    titleFrame:SetText(item.title)
    control.titleFrame = titleFrame

    -- Typed text only takes effect through Enter or this button, which shows while there is something to confirm
    local okButton = CreateFrame("Button", nil, control, "UIPanelButtonTemplate")
    okButton:SetSize(60, 22)
    okButton:SetPoint("LEFT", editBox, "RIGHT", 6, 0)
    okButton:SetText(OKAY or "Okay")
    okButton:Hide()
    control.okBtn = okButton

    -- Leave room on the right for the button
    editBox:SetSize(width - 26 - 66, 22)

    local function GetStoredText()
        return item.get and tostring(item.get() or "") or ""
    end

    local function CommitText()
        local text = editBox:GetText()
        editBox:ClearFocus()
        okButton:Hide()
        if item.set then
            item.set(text)
        end
        QuestieOptionsEngine:RefreshStates()
    end

    editBox:SetScript("OnTextChanged", function(self, isUserInput)
        if isUserInput then
            local enteredText = self:GetText()
            okButton:SetShown(enteredText ~= GetStoredText() and strtrim(enteredText) ~= "")
        end
    end)

    editBox:SetScript("OnEnterPressed", CommitText)
    okButton:SetScript("OnClick", CommitText)

    editBox:SetScript("OnEscapePressed", function(self)
        if item.get then
            self:SetText(GetStoredText())
        end
        self:ClearFocus()
        okButton:Hide()
    end)

    editBox:SetScript("OnEditFocusLost", function(self)
        -- Clicking the button also takes the focus away, and has to keep the typed text
        if not okButton:IsMouseOver() then
            if item.get then
                self:SetText(GetStoredText())
            end
            okButton:Hide()
        end
    end)

    -- Raised to clear the title above the box
    _ApplyTooltip(editBox, item, "ANCHOR_TOPLEFT", 0, 18)
end

local function _RefreshTextbox(control, item, isEnabled, _, textColor)
    local editBox = control.widget

    editBox:SetTextColor(unpack(textColor))
    editBox:EnableMouse(isEnabled)
    if not isEnabled and editBox:HasFocus() then
        editBox:ClearFocus()
    end

    control.okBtn:SetEnabled(isEnabled)
    if not isEnabled then
        control.okBtn:Hide()
    end

    for _, region in ipairs({editBox:GetRegions()}) do
        if region:IsObjectType("Texture") then
            region:SetDesaturated(not isEnabled)
            region:SetVertexColor(unpack(isEnabled and ENABLED_ART_COLOR or DISABLED_ART_COLOR))
        end
    end

    -- Leave text the user is still typing alone
    if item.get and not editBox:HasFocus() then
        editBox:SetText(tostring(item.get() or ""))
        control.okBtn:Hide()
    end
end

-------------------------
-- Spacer
-------------------------

local function _CreateSpacer(control)
    control.widget = CreateFrame("Frame", nil, control)
end

-------------------------
-- Public functions
-------------------------

---@class QuestieOptionsControlType
---@field minHeight number Starting height. Controls can grow past it when their text wraps.
---@field Create fun(control: QuestieOptionsControl, parent: Frame, item: table, width: number, level: number)
---@field Refresh fun(control: QuestieOptionsControl, item: table, isEnabled: boolean, labelColor: number[], textColor: number[])?

---@type table<string, QuestieOptionsControlType>
local CONTROL_TYPES = {
    checkbox = {minHeight = 30, Create = _CreateCheckbox, Refresh = _RefreshCheckbox},
    radioButton = {minHeight = 16, Create = _CreateRadioButton, Refresh = _RefreshRadioButton},
    slider = {minHeight = 48, Create = _CreateSlider, Refresh = _RefreshSlider},
    dropdown = {minHeight = 50, Create = _CreateDropdown, Refresh = _RefreshDropdown},
    fontDropdown = {minHeight = 50, Create = _CreateFontDropdown, Refresh = _RefreshDropdown},
    divider = {minHeight = 15, Create = _CreateDivider},
    container = {minHeight = 20, Create = _CreateContainer, Refresh = _RefreshContainer},
    text = {minHeight = 20, Create = _CreateText, Refresh = _RefreshText},
    button = {minHeight = 40, Create = _CreateButton},
    soundButton = {minHeight = 40, Create = _CreateSoundButton},
    colorPicker = {minHeight = 40, Create = _CreateColorPicker, Refresh = _RefreshColorPicker},
    textbox = {minHeight = 50, Create = _CreateTextbox, Refresh = _RefreshTextbox},
    spacer = {minHeight = 16, Create = _CreateSpacer},
}

---Updates a control to show the current setting and whether it can be changed right now.
---@param control QuestieOptionsControl
function QuestieOptionsControls.Refresh(control)
    local item = control.itemData
    local isEnabled = _IsItemEnabled(item)

    if control.widget and control.widget.SetEnabled then
        control.widget:SetEnabled(isEnabled)
    end

    local labelColor = isEnabled and DEFAULT_LABEL_COLOR or DISABLED_LABEL_COLOR
    local textColor = isEnabled and DEFAULT_TEXT_COLOR or DISABLED_TEXT_COLOR

    if control.titleFrame then control.titleFrame:SetTextColor(unpack(labelColor)) end
    if control.descriptionFrame then control.descriptionFrame:SetTextColor(unpack(textColor)) end

    local refreshType = CONTROL_TYPES[item.type].Refresh
    if refreshType then
        refreshType(control, item, isEnabled, labelColor, textColor)
    end
end

---Creates a control already showing the current setting.
---@param parent Frame
---@param item table Normalized item definition, see QuestieOptionsLayout
---@param width number
---@param level number Nesting depth on the canvas, starting at 1
---@return QuestieOptionsControl
function QuestieOptionsControls.Create(parent, item, width, level)
    local controlType = CONTROL_TYPES[item.type]
    if not controlType then
        error("Unknown settings control type: " .. tostring(item.type))
    end

    local control = CreateFrame("Button", nil, parent)
    control:SetSize(width, controlType.minHeight)
    control.itemData = item

    controlType.Create(control, parent, item, width, level)
    QuestieOptionsControls.Refresh(control)

    return control
end

return QuestieOptionsControls
