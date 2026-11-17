---@class QuestieGUI
local QuestieGUI = QuestieLoader:CreateModule("QuestieGUI")

local PATH_SEPARATOR = "\001"
local DEFAULT_WIDTH = 180
local DEFAULT_HEIGHT = 24
local FLOW_GAP = 3

local function CreateBackdropFrame(frameType, parent, template)
    local ok, frame = pcall(CreateFrame, frameType, nil, parent, template or "BackdropTemplate")
    if ok and frame then
        return frame
    end
    return CreateFrame(frameType, nil, parent)
end

local function SetBackdrop(frame, color, border)
    if not frame or not frame.SetBackdrop then
        return
    end
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    if color and frame.SetBackdropColor then
        frame:SetBackdropColor(unpack(color))
    end
    if border and frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(unpack(border))
    end
end

local function SetFrameSize(frame, width, height)
    if width then frame:SetWidth(width) end
    if height then frame:SetHeight(height) end
end

local function Fire(widget, event, ...)
    local callback = widget.callbacks and widget.callbacks[event]
    if callback then
        callback(widget, event, ...)
    end
end

local function SetFrameShown(frame, shown)
    if shown then frame:Show() else frame:Hide() end
end

local function GetWidgetHeight(widget)
    local height = widget.frame and widget.frame:GetHeight()
    return height and height > 0 and height or DEFAULT_HEIGHT
end

local function GetWidgetWidth(widget)
    local width = widget.frame and widget.frame:GetWidth()
    return width and width > 0 and width or DEFAULT_WIDTH
end

local function LayoutChildren(widget)
    local content = widget.content
    if not content then return end

    local layout = string.lower(widget.layout or "flow")
    local children = widget.children or {}
    local y = 0
    local x = 0
    local rowHeight = 0
    local hasFullHeightChild = false
    local contentWidth = content:GetWidth() or 0

    for index, child in ipairs(children) do
        local frame = child.frame
        if frame then
            frame:ClearAllPoints()
            if layout == "fill" and index == 1 then
                frame:SetPoint("TOPLEFT", content, "TOPLEFT")
                frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT")
            elseif layout == "table" then
                local width = child.relativeWidth and content:GetWidth() * child.relativeWidth or content:GetWidth()
                frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                frame:SetWidth(width)
                y = y + GetWidgetHeight(child)
            else
                local childWidth = child.relativeWidth and contentWidth * child.relativeWidth or GetWidgetWidth(child)
                local childHeight = GetWidgetHeight(child)
                local startsNewRow = x == 0
                    or child.fullWidth
                    or (contentWidth > 0 and x + childWidth > contentWidth)

                if startsNewRow then
                    if x > 0 then y = y + rowHeight + FLOW_GAP end
                    x = 0
                    rowHeight = 0
                end

                frame:SetPoint("TOPLEFT", content, "TOPLEFT", x, -y)
                if child.fullWidth or (contentWidth > 0 and childWidth >= contentWidth) then
                    frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
                else
                    frame:SetWidth(childWidth)
                end
                if child.fullHeight then
                    frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT")
                    hasFullHeightChild = true
                else
                    frame:SetHeight(childHeight)
                end
                rowHeight = math.max(rowHeight, childHeight)
                x = x + childWidth + FLOW_GAP
            end
            frame:Show()
        end
    end

    if layout ~= "fill" and widget.autoHeight and not hasFullHeightChild then
        content:SetHeight(math.max(y + rowHeight, 1))
    end
end

local function AddChild(widget, child)
    widget.children = widget.children or {}
    widget.children[#widget.children + 1] = child
    child.parent = widget
    local parent = widget.content or widget.frame
    if child.frame and parent then
        child.frame:SetParent(parent)
    end
    LayoutChildren(widget)
end

local function ReleaseChildren(widget)
    for _, child in ipairs(widget.children or {}) do
        if child.frame then
            child.frame:Hide()
            child.frame:SetParent(nil)
        end
        Fire(child, "OnRelease")
    end
    widget.children = {}
end

local function SetText(widget, text)
    widget.value = text
    if widget.text and widget.text.SetText then
        widget.text:SetText(text or "")
    end
    if widget.label and widget.label.SetText then
        widget.label:SetText(text or "")
    end
    if widget.frame and widget.frame.SetText then
        widget.frame:SetText(text or "")
    end
end

local function SetLabel(widget, text)
    if not widget.label then
        widget.label = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        widget.label:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -2)
        widget.label:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -2)
        widget.label:SetJustifyH("LEFT")
    end
    widget.label:SetText(text or "")
    widget.label:Show()
    widget.hasLabel = text ~= nil and text ~= ""
    if widget.nativeControl then
        widget.nativeControl:ClearAllPoints()
        widget.nativeControl:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 0, widget.hasLabel and -18 or 0)
        widget.nativeControl:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", 0, widget.hasLabel and -18 or 0)
    end
end

local function CreateBaseWidget(widgetType, parent)
    local widget = {
        type = widgetType,
        callbacks = {},
        userData = {},
        children = {},
        layout = "flow",
        autoHeight = true,
    }
    widget.frame = CreateBackdropFrame("Frame", parent)
    widget.frame:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    widget.frame:HookScript("OnSizeChanged", function()
        LayoutChildren(widget)
    end)

    function widget:SetCallback(event, callback)
        self.callbacks[event] = callback
    end
    function widget:Fire(event, ...)
        Fire(self, event, ...)
    end
    function widget:SetUserData(key, value)
        self.userData[key] = value
    end
    function widget:GetUserData(key)
        return self.userData[key]
    end
    function widget:SetLayout(layout)
        self.layout = layout or "flow"
        LayoutChildren(self)
    end
    function widget:SetFullWidth(full)
        self.fullWidth = full
        LayoutChildren(self)
    end
    function widget:SetFullHeight(full)
        self.fullHeight = full
        LayoutChildren(self)
    end
    function widget:SetRelativeWidth(width)
        self.relativeWidth = width
        if self.parent then LayoutChildren(self.parent) end
    end
    function widget:SetWidth(width)
        self.frame:SetWidth(width)
        LayoutChildren(self)
    end
    function widget:SetHeight(height)
        self.frame:SetHeight(height)
        LayoutChildren(self)
    end
    function widget:SetPoint(...)
        self.frame:SetPoint(...)
    end
    function widget:SetAllPoints(...)
        self.frame:SetAllPoints(...)
    end
    function widget:SetParent(parentFrame)
        self.frame:SetParent(parentFrame)
    end
    function widget:Show()
        self.frame:Show()
    end
    function widget:Hide()
        self.frame:Hide()
    end
    function widget:SetShown(shown)
        SetFrameShown(self.frame, shown)
    end
    function widget:IsShown()
        return self.frame:IsShown()
    end
    function widget:IsVisible()
        return self.frame:IsVisible()
    end
    function widget:AddChild(child)
        AddChild(self, child)
    end
    function widget:ReleaseChildren()
        ReleaseChildren(self)
    end
    function widget:SetText(text)
        SetText(self, text)
    end
    function widget:GetText()
        return self.editbox and self.editbox:GetText() or self.value
    end
    function widget:SetLabel(text)
        SetLabel(self, text)
    end
    function widget:SetTitle(text)
        SetText(self, text)
    end
    function widget:SetDisabled(disabled)
        self.disabled = disabled and true or false
        if self.nativeControl and self.nativeControl.SetEnabled then
            self.nativeControl:SetEnabled(not self.disabled)
        end
        if self.frame.SetAlpha then self.frame:SetAlpha(self.disabled and 0.55 or 1) end
    end
    function widget:IsEnabled()
        return not self.disabled
    end
    function widget:SetAutoAdjustHeight(autoHeight)
        self.autoHeight = autoHeight
    end

    return widget
end

local function CreateContainer(widgetType, parent, inset, color)
    local widget = CreateBaseWidget(widgetType, parent)
    widget.content = CreateBackdropFrame("Frame", widget.frame)
    widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", inset or 6, -(inset or 6))
    widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -(inset or 6), inset or 6)
    widget.border = widget.frame
    SetBackdrop(widget.border, color or {0.08, 0.055, 0.03, 0.96}, {0.35, 0.25, 0.1, 1})
    widget.frame:SetHeight(40)
    widget.frame:HookScript("OnSizeChanged", function()
        widget.content:ClearAllPoints()
        widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", inset or 6, -(inset or 6))
        widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -(inset or 6), inset or 6)
        LayoutChildren(widget)
    end)
    return widget
end

local function CreateLabel(widgetType, parent)
    local widget = CreateBaseWidget(widgetType, parent)
    widget.frame:SetHeight(20)
    widget.text = widget.frame:CreateFontString(nil, "OVERLAY", widgetType == "Heading" and "GameFontNormal" or "GameFontHighlightSmall")
    widget.text:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -2)
    widget.text:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -2)
    widget.text:SetJustifyH("LEFT")
    widget.text:SetWordWrap(true)
    function widget:SetColor(r, g, b)
        self.text:SetTextColor(r, g, b)
    end
    function widget:SetFontObject(font)
        self.text:SetFontObject(font)
    end
    function widget:SetJustifyH(justify)
        self.text:SetJustifyH(justify)
    end
    function widget:SetWordWrap(wrap)
        self.text:SetWordWrap(wrap)
    end
    function widget:SetImage(texture)
        self.image = self.image or self.frame:CreateTexture(nil, "ARTWORK")
        self.image:SetTexture(texture)
        self.image:SetPoint("LEFT", self.frame, "LEFT", 2, 0)
        self.image:SetSize(24, 24)
        self.text:ClearAllPoints()
        self.text:SetPoint("LEFT", self.image, "RIGHT", 5, 0)
        self.text:SetPoint("RIGHT", self.frame, "RIGHT", -4, 0)
    end
    function widget:SetImageSize(width, height)
        if self.image then self.image:SetSize(width, height) end
    end
    return widget
end

local function CreateButton(parent)
    local widget = CreateBaseWidget("Button", parent)
    widget.frame = CreateBackdropFrame("Button", parent, "UIPanelButtonTemplate")
    widget.text = widget.frame:GetFontString() or widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widget.frame:SetScript("OnClick", function(_, button)
        if not widget.disabled then Fire(widget, "OnClick", button) end
    end)
    function widget:SetText(text)
        self.value = text
        if self.frame.SetText then self.frame:SetText(text or "") end
        if self.text and self.text.SetText then self.text:SetText(text or "") end
    end
    function widget:SetDisabled(disabled)
        self.disabled = disabled and true or false
        if self.disabled then self.frame:Disable() else self.frame:Enable() end
    end
    return widget
end

local function CreateCheckBox(parent)
    local widget = CreateBaseWidget("CheckBox", parent)
    widget.frame = CreateBackdropFrame("CheckButton", parent, "UICheckButtonTemplate")
    widget.text = widget.frame.text or widget.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widget.frame:SetScript("OnClick", function(frame)
        widget.value = frame:GetChecked()
        Fire(widget, "OnValueChanged", widget.value)
    end)
    function widget:SetValue(value)
        self.value = value and true or false
        self.frame:SetChecked(self.value)
    end
    function widget:SetChecked(value)
        self:SetValue(value)
    end
    function widget:GetValue()
        return self.frame:GetChecked()
    end
    function widget:GetChecked()
        return self.frame:GetChecked()
    end
    return widget
end

local function CreateEditBox(widgetType, parent)
    local widget = CreateBaseWidget(widgetType, parent)
    widget.frame:SetHeight(widgetType == "MultiLineEditBox" and 180 or 42)
    widget.editbox = CreateFrame("EditBox", nil, widget.frame, "InputBoxTemplate")
    widget.editbox:SetAutoFocus(false)
    if widgetType == "MultiLineEditBox" and widget.editbox.SetMultiLine then
        widget.editbox:SetMultiLine(true)
    end
    widget.editbox:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -20)
    widget.editbox:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -20)
    widget.editbox:SetHeight(widgetType == "MultiLineEditBox" and 150 or 22)
    widget.editbox:SetScript("OnEnterPressed", function()
        Fire(widget, "OnEnterPressed", widget.editbox:GetText())
    end)
    widget.editbox:SetScript("OnTextChanged", function()
        widget.value = widget.editbox:GetText()
        Fire(widget, "OnTextChanged", widget.value)
    end)
    widget.button = CreateFrame("Button", nil, widget.frame)
    widget.button:Hide()
    widget.disablebutton = false
    widget.scrollBG = widget.editbox
    widget.scrollBar = CreateFrame("Slider", nil, widget.frame, "UIPanelScrollBarTemplate")
    widget.scrollBar:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -2, -22)
    widget.scrollBar:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -2, 4)
    if widgetType ~= "MultiLineEditBox" then widget.scrollBar:Hide() end
    function widget:SetText(text)
        self.value = text or ""
        self.editbox:SetText(self.value)
    end
    function widget:GetText()
        return self.editbox:GetText() or ""
    end
    function widget:SetFocus()
        self.editbox:SetFocus()
    end
    function widget:ClearFocus()
        self.editbox:ClearFocus()
    end
    function widget:HasFocus()
        return self.editbox:HasFocus()
    end
    function widget:SetNumLines(lines)
        self.numLines = lines
        self.frame:SetHeight(math.max(42, lines * 16 + 28))
        self.editbox:SetHeight(lines * 16)
    end
    function widget:SetMaxLetters(maxLetters)
        self.editbox:SetMaxLetters(maxLetters)
    end
    function widget:SetAutoFocus(autoFocus)
        self.editbox:SetAutoFocus(autoFocus)
    end
    function widget:SetTextInsets(...)
        self.editbox:SetTextInsets(...)
    end
    function widget:DisableButton(disabled)
        self.buttonDisabled = disabled
    end
    return widget
end

local function CreateDropdown(parent)
    local widget = CreateBaseWidget("Dropdown", parent)
    widget.frame:SetHeight(48)
    widget.dropdown = CreateFrame("Button", nil, widget.frame, "UIPanelButtonTemplate")
    widget.nativeControl = widget.dropdown
    widget.button = widget.dropdown
    widget.button_cover = widget.dropdown
    widget.text = widget.dropdown:GetFontString() or widget.dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widget.list = {}
    widget.order = {}
    widget.dropdown:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 0, 0)
    widget.dropdown:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", 0, 0)
    widget.dropdown:SetHeight(30)
    widget.dropdown:SetScript("OnClick", function()
        if widget.disabled then return end
        if widget.menu then widget.menu:Hide() end
        widget.menu = CreateBackdropFrame("Frame", UIParent)
        widget.menu:SetFrameStrata("DIALOG")
        widget.menu:SetPoint("TOPLEFT", widget.dropdown, "BOTTOMLEFT")
        widget.menu:SetWidth(widget.dropdown:GetWidth())
        widget.menu:SetHeight(math.max(30, #widget.order * 26 + 6))
        SetBackdrop(widget.menu, {0.05, 0.035, 0.02, 0.98}, {0.45, 0.32, 0.1, 1})
        local y = -3
        for _, key in ipairs(widget.order) do
            if key ~= "_SEPARATOR" then
                local option = CreateFrame("Button", nil, widget.menu)
                option:SetPoint("TOPLEFT", widget.menu, "TOPLEFT", 3, y)
                option:SetPoint("TOPRIGHT", widget.menu, "TOPRIGHT", -3, y)
                option:SetHeight(24)
                option:SetText(widget.list[key] or tostring(key))
                option:SetScript("OnClick", function()
                    widget:SetValue(key)
                    widget.menu:Hide()
                    Fire(widget, "OnValueChanged", key)
                end)
                y = y - 26
            end
        end
        widget.menu:Show()
    end)
    function widget:SetList(list, order)
        self.list = list or {}
        self.order = order or {}
        if not order then
            for key in pairs(self.list) do self.order[#self.order + 1] = key end
            table.sort(self.order, function(a, b) return tostring(a) < tostring(b) end)
        end
    end
    function widget:SetValue(value)
        self.value = value
        self.dropdown:SetText(self.list[value] or tostring(value or ""))
    end
    function widget:SetText(text)
        self.value = text
        self.dropdown:SetText(text or "")
    end
    function widget:SetDisabled(disabled)
        self.disabled = disabled and true or false
        if self.disabled then self.dropdown:Disable() else self.dropdown:Enable() end
    end
    return widget
end

local function CreateScrollFrame(parent)
    local widget = CreateContainer("ScrollFrame", parent, 0, {0.08, 0.055, 0.03, 0.96})
    widget.frame = CreateFrame("ScrollFrame", nil, parent)
    widget.border = widget.frame
    widget.content = CreateBackdropFrame("Frame", widget.frame)
    widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
    widget.content:SetWidth(1)
    widget.content:SetHeight(1)
    widget.frame:SetScrollChild(widget.content)
    widget.frame:EnableMouseWheel(true)
    widget.scrollbar = CreateFrame("Slider", nil, widget.frame, "UIPanelScrollBarTemplate")
    widget.scrollbar:SetScript("OnValueChanged", function(_, value)
        widget.frame:SetVerticalScroll(value)
    end)
    widget.frame:HookScript("OnSizeChanged", function()
        widget.content:SetWidth(math.max(widget.frame:GetWidth() or 1, 1))
    end)
    widget.scrollbar:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -2, -2)
    widget.scrollbar:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -2, 2)
    widget.scrollbar:SetMinMaxValues(0, 0)
    widget.scrollbar:SetValueStep(1)
    widget.frame:HookScript("OnMouseWheel", function(_, delta)
        local minimum, maximum = widget.scrollbar:GetMinMaxValues()
        local value = widget.scrollbar:GetValue() - delta * 40
        widget.scrollbar:SetValue(math.max(minimum, math.min(maximum, value)))
    end)
    function widget:SetHeight(height)
        self.frame:SetHeight(height)
        self.content:SetHeight(math.max(height, self.content:GetHeight() or 0))
    end
    function widget:AddChild(child)
        AddChild(self, child)
        local height = 0
        for _, item in ipairs(self.children) do height = height + GetWidgetHeight(item) end
        self.content:SetHeight(math.max(height, self.frame:GetHeight() or 1))
        local maximum = math.max(0, height - (self.frame:GetHeight() or 0))
        self.scrollbar:SetMinMaxValues(0, maximum)
        self.scrollbar:SetShown(maximum > 0)
    end
    return widget
end

local function CreateFrameWidget(parent)
    local widget = CreateContainer("Frame", UIParent, 10, {0.07, 0.05, 0.03, 0.98})
    widget.frame:SetFrameStrata("DIALOG")
    widget.frame:SetPoint("CENTER")
    widget.frame:SetSize(420, 260)
    widget.title = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    widget.title:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 14, -14)
    widget.title:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -42, -14)
    widget.title:SetJustifyH("LEFT")
    widget.closeButton = CreateFrame("Button", nil, widget.frame, "UIPanelCloseButton")
    widget.closeButton:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -3, -3)
    widget.closeButton:SetScript("OnClick", function()
        Fire(widget, "OnClose")
        widget:Hide()
    end)
    widget.content:ClearAllPoints()
    widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 10, -42)
    widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -10, 10)
    widget.frame:HookScript("OnSizeChanged", function()
        widget.content:ClearAllPoints()
        widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 10, -42)
        widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -10, 10)
    end)
    function widget:SetTitle(text)
        self.title:SetText(text or "")
    end
    function widget:EnableResize(enabled)
        self.resizable = enabled
    end
    function widget:Raise()
        self.frame:Raise()
    end
    function widget:SetFrameStrata(strata)
        self.frame:SetFrameStrata(strata)
    end
    function widget:HookScript(script, callback)
        self.frame:HookScript(script, callback)
    end
    function widget:IsShown()
        return self.frame:IsShown()
    end
    function widget:Show()
        self.frame:Show()
    end
    function widget:Hide()
        self.frame:Hide()
    end
    return widget
end

local function CreateTreeGroup(parent)
    local widget = CreateContainer("TreeGroup", parent, 0, {0.06, 0.05, 0.04, 0.96})
    widget.localstatus = {}
    widget.status = widget.localstatus
    widget.frame.obj = widget
    widget.treeframe = CreateBackdropFrame("Frame", widget.frame)
    widget.treeframe:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
    widget.treeframe:SetPoint("BOTTOMLEFT", widget.frame, "BOTTOMLEFT")
    widget.treeframe:SetWidth(220)
    widget.treeframe:EnableMouse(true)
    widget.localstatus.groups = {}
    widget.treeScroll = CreateFrame("ScrollFrame", nil, widget.treeframe)
    widget.treeScroll:SetPoint("TOPLEFT", widget.treeframe, "TOPLEFT", 4, -4)
    widget.treeScroll:SetPoint("BOTTOMRIGHT", widget.treeframe, "BOTTOMRIGHT", -22, 4)
    widget.treeScroll:EnableMouseWheel(true)
    widget.treeContent = CreateFrame("Frame", nil, widget.treeScroll)
    widget.treeContent:SetPoint("TOPLEFT", widget.treeScroll, "TOPLEFT")
    widget.treeContent:SetWidth(1)
    widget.treeContent:SetHeight(1)
    widget.treeScroll:SetScrollChild(widget.treeContent)
    widget.scrollbar = CreateFrame("Slider", nil, widget.treeframe, "UIPanelScrollBarTemplate")
    widget.scrollbar:SetScript("OnValueChanged", function(_, value)
        widget.treeScroll:SetVerticalScroll(value)
    end)
    widget.scrollbar:SetPoint("TOPRIGHT", widget.treeframe, "TOPRIGHT", -2, -2)
    widget.scrollbar:SetPoint("BOTTOMRIGHT", widget.treeframe, "BOTTOMRIGHT", -2, 2)
    widget.scrollbar:SetWidth(16)
    widget.scrollbar:SetMinMaxValues(0, 0)
    widget.scrollbar:SetValueStep(1)
    widget.scrollbar:SetValue(0)
    widget.treeScroll:SetScript("OnMouseWheel", function(_, delta)
        local minimum, maximum = widget.scrollbar:GetMinMaxValues()
        local value = widget.scrollbar:GetValue() - delta * 40
        widget.scrollbar:SetValue(math.max(minimum, math.min(maximum, value)))
    end)
    SetBackdrop(widget.treeframe, {0.08, 0.055, 0.03, 0.96}, {0.35, 0.25, 0.1, 1})
    widget.content:ClearAllPoints()
    widget.content:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 6, 0)
    widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")

    local function FindNode(nodes, parts, index)
        for _, node in ipairs(nodes or {}) do
            if tostring(node.value) == tostring(parts[index]) then
                if index == #parts then return node end
                return FindNode(node.children, parts, index + 1)
            end
        end
    end

    local function RenderTree()
        for _, child in ipairs({widget.treeContent:GetChildren()}) do child:Hide() end
        local y = -4
        local function AddNodes(nodes, path, depth)
            for _, node in ipairs(nodes or {}) do
                local nodePath = path and (path .. PATH_SEPARATOR .. tostring(node.value)) or tostring(node.value)
                local button = CreateFrame("Button", nil, widget.treeContent)
                button.treeValue = nodePath
                button:SetPoint("TOPLEFT", widget.treeContent, "TOPLEFT", depth * 10, y)
                button:SetWidth(math.max(widget.treeContent:GetWidth() or 1, 1) - depth * 10)
                button:SetHeight(22)
                button:SetFrameLevel(widget.treeScroll:GetFrameLevel() + 1)
                button:EnableMouse(true)
                button:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
                button.text = button:CreateFontString(nil, "OVERLAY", node.children and "GameFontNormal" or "GameFontHighlightSmall")
                button.text:SetText(node.text or tostring(node.value))
                button.text:SetJustifyH("LEFT")

                local toggleOffset = node.children and 18 or 0
                if node.children then
                    button.toggle = CreateFrame("Button", nil, button)
                    button.toggle:ClearAllPoints()
                    button.toggle:SetPoint("LEFT", button, "LEFT", depth * 10, 0)
                    button.toggle:SetSize(16, 16)
                    button.toggle.treeGlyph = button.toggle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                    button.toggle.treeGlyph:SetPoint("CENTER")
                    button.toggle.treeGlyph:SetTextColor(1, 0.82, 0)
                    button.toggle.treeGlyph:SetText(widget.localstatus.groups[nodePath] == false and "+" or "−")
                    button.toggle:SetScript("OnClick", function()
                        widget.localstatus.groups[nodePath] = widget.localstatus.groups[nodePath] == false
                        RenderTree()
                    end)
                    button.toggle:Show()
                end

                local iconOffset = depth * 10 + toggleOffset
                if node.icon then
                    button.icon = button:CreateTexture(nil, "OVERLAY")
                    button.icon:SetSize(node.iconSize or 14, node.iconSize or 14)
                    button.icon:SetPoint("LEFT", button, "LEFT", iconOffset, 0)
                    button.icon:SetTexture(node.icon)
                    if node.iconCoords then button.icon:SetTexCoord(unpack(node.iconCoords)) else button.icon:SetTexCoord(0, 1, 0, 1) end
                    iconOffset = iconOffset + (node.iconSize or 14) + 4
                    button.icon:Show()
                elseif button.icon then
                    button.icon:Hide()
                end

                button.text:ClearAllPoints()
                button.text:SetPoint("LEFT", button, "LEFT", iconOffset, 0)
                button.text:SetPoint("RIGHT", button, "RIGHT", -8, 0)
                if button.SetEnabled then button:SetEnabled(not node.disabled) end
                button:SetScript("OnClick", function()
                    Fire(widget, "OnClick", nodePath, widget.localstatus.selected == nodePath)
                    widget:SelectByValue(nodePath)
                end)
                button:SetScript("OnEnter", function()
                    Fire(widget, "OnButtonEnter", nodePath, button)
                    if widget.buttonTooltips then
                        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                        GameTooltip:SetText(node.tooltipText or node.text or tostring(node.value), 1, 0.82, 0, 1, true)
                        GameTooltip:Show()
                    end
                end)
                button:SetScript("OnLeave", function()
                    Fire(widget, "OnButtonLeave", nodePath, button)
                    if widget.buttonTooltips then GameTooltip:Hide() end
                end)
                if widget.localstatus.selected == nodePath then button:LockHighlight() end
                button:Show()
                y = y - 24
                if node.children and widget.localstatus.groups[nodePath] ~= false then
                    AddNodes(node.children, nodePath, depth + 1)
                end
            end
        end
        AddNodes(widget.tree, nil, 0)
        local contentHeight = math.max(1, -y + 4)
        widget.treeContent:SetHeight(contentHeight)
        local viewHeight = widget.treeScroll:GetHeight() or 0
        local maximum = math.max(0, contentHeight - viewHeight)
        widget.scrollbar:SetMinMaxValues(0, maximum)
        widget.scrollbar:SetShown(maximum > 0)
        widget.treeScroll:SetVerticalScroll(math.min(widget.treeScroll:GetVerticalScroll() or 0, maximum))
    end

    local function LayoutTree()
        widget.treeContent:SetWidth(math.max(widget.treeScroll:GetWidth() or 1, 1))
        widget.content:ClearAllPoints()
        widget.content:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 6, 0)
        widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")
        RenderTree()
    end
    widget.frame:HookScript("OnSizeChanged", LayoutTree)
    widget.treeframe:HookScript("OnSizeChanged", LayoutTree)
    widget.treeScroll:HookScript("OnSizeChanged", LayoutTree)

    function widget:SetTree(tree)
        self.tree = tree or {}
        RenderTree()
    end
    function widget:SelectByValue(value)
        self.localstatus.selected = tostring(value)
        for _, button in ipairs({self.treeContent:GetChildren()}) do
            if button.treeValue == self.localstatus.selected then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end
        end
        Fire(self, "OnGroupSelected", self.localstatus.selected)
    end
    function widget:SelectByPath(...)
        local parts = {...}
        local path = table.concat(parts, PATH_SEPARATOR)
        if FindNode(self.tree, parts, 1) then self:SelectByValue(path) end
    end
    function widget:EnableButtonTooltips(enabled)
        self.buttonTooltips = enabled
    end
    return widget
end

local function CreateTabGroup(parent)
    local widget = CreateContainer("TabGroup", parent, 0, {0.06, 0.05, 0.04, 0.96})
    widget.nativeTabs = true
    widget.localstatus = {}
    widget.status = widget.localstatus
    widget.tabs = {}
    widget.tabBar = CreateFrame("Frame", nil, widget.frame)
    widget.tabBar:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
    widget.tabBar:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT")
    widget.tabBar:SetHeight(32)
    widget.content:ClearAllPoints()
    widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 0, -34)
    widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")
    function widget:SetTabs(tabs)
        self.tabs = tabs or {}
        for _, child in ipairs({self.tabBar:GetChildren()}) do child:Hide() end
        local x = 0
        for _, tab in ipairs(self.tabs) do
            local button = CreateFrame("Button", nil, self.tabBar, "UIPanelButtonTemplate")
            button:SetPoint("TOPLEFT", self.tabBar, "TOPLEFT", x, 0)
            button:SetSize(math.max(90, (tab.text and string.len(tab.text) or 8) * 8 + 24), 28)
            button:SetText(tab.text or tab.value)
            button:SetScript("OnClick", function() self:SelectTab(tab.value) end)
            tab.button = button
            x = x + button:GetWidth() + 4
        end
    end
    function widget:SelectTab(value)
        self.localstatus.selected = value
        Fire(self, "OnGroupSelected", value)
    end
    return widget
end

local function CreateIcon(parent)
    local widget = CreateBaseWidget("Icon", parent)
    widget.frame:SetSize(32, 32)
    widget.image = widget.frame:CreateTexture(nil, "ARTWORK")
    widget.image:SetAllPoints(widget.frame)
    function widget:SetImage(texture)
        self.image:SetTexture(texture)
    end
    function widget:SetImageSize(width, height)
        self.frame:SetSize(width, height)
    end
    function widget:SetColor(r, g, b, a)
        self.image:SetVertexColor(r, g, b, a or 1)
    end
    function widget:SetOwner(owner, anchor, ...)
        self.owner = owner
        self.anchor = anchor
    end
    return widget
end

local function CreateTooltip(parent)
    local tooltipParent = type(parent) == "number" and UIParent or parent
    local widget = CreateBaseWidget("GameTooltipWidget", tooltipParent)
    widget.frame = CreateFrame("GameTooltip", nil, tooltipParent, "GameTooltipTemplate")
    function widget:SetOwner(...)
        self.frame:SetOwner(...)
    end
    function widget:SetItemByID(id) self.frame:SetItemByID(id) end
    function widget:SetHyperlink(link) self.frame:SetHyperlink(link) end
    function widget:SetUnit(unit) self.frame:SetUnit(unit) end
    function widget:SetSpellByID(id) self.frame:SetSpellByID(id) end
    return widget
end

function QuestieGUI:Create(widgetType, parent)
    if widgetType == "SimpleGroup" then return CreateContainer(widgetType, parent, 0, nil)
    elseif widgetType == "InlineGroup" then return CreateContainer(widgetType, parent, 10, {0.08, 0.055, 0.03, 0.96})
    elseif widgetType == "ScrollFrame" then return CreateScrollFrame(parent)
    elseif widgetType == "TreeGroup" then return CreateTreeGroup(parent)
    elseif widgetType == "TabGroup" then return CreateTabGroup(parent)
    elseif widgetType == "Frame" then return CreateFrameWidget(parent)
    elseif widgetType == "Button" then return CreateButton(parent)
    elseif widgetType == "CheckBox" then return CreateCheckBox(parent)
    elseif widgetType == "EditBox" or widgetType == "MultiLineEditBox" then return CreateEditBox(widgetType, parent)
    elseif widgetType == "Dropdown" then return CreateDropdown(parent)
    elseif widgetType == "Icon" then return CreateIcon(parent)
    elseif widgetType == "GameTooltipWidget" then return CreateTooltip(parent)
    elseif widgetType == "Heading" or widgetType == "Label" or widgetType == "InteractiveLabel" then
        local widget = CreateLabel(widgetType, parent)
        if widgetType == "InteractiveLabel" then
            widget.frame:EnableMouse(true)
            widget.frame:SetScript("OnMouseUp", function(_, button)
                Fire(widget, "OnClick", button)
            end)
        end
        return widget
    end
    error("Unknown QuestieGUI widget type: " .. tostring(widgetType))
end

function QuestieGUI:Release(widget)
    if not widget then return end
    ReleaseChildren(widget)
    Fire(widget, "OnRelease")
    if widget.frame then widget.frame:Hide() end
end

function QuestieGUI:SetFocus(widget)
    if widget and widget.SetFocus then widget:SetFocus() end
end

return QuestieGUI
