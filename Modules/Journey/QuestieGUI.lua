---@class QuestieGUI
local QuestieGUI = QuestieLoader:CreateModule("QuestieGUI")

local PATH_SEPARATOR = "\001"
local DEFAULT_WIDTH = 180
local DEFAULT_HEIGHT = 24
local FLOW_GAP = 3
local SCROLL_CONTENT_INSET = 16

local function CreateBackdropFrame(frameType, parent, template)
    local ok, frame = pcall(CreateFrame, frameType, nil, parent, template or "BackdropTemplate")
    if ok and frame then
        return frame
    end
    return CreateFrame(frameType, nil, parent)
end

local function CreateJourneyScrollBar(parent)
    if ScrollUtil and type(CreateFrame) == "function" then
        local ok, nativeScrollBar = pcall(CreateFrame, "EventFrame", nil, parent, "MinimalScrollBar")
        if ok and nativeScrollBar and nativeScrollBar.SetScrollPercentage
            and nativeScrollBar.RegisterCallback and nativeScrollBar.SetHideIfUnscrollable then
            nativeScrollBar.questieNativeMinimalScrollBar = true
            return nativeScrollBar
        end
    end

    return CreateFrame("Slider", nil, parent, "UIPanelScrollBarTemplate")
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

local function GetWidgetTitleHeight(widget)
    local title = widget and (widget.modernInfoTitle or widget.titletext)
    if title and title.IsShown and title:IsShown() then
        return 20
    end
    return 0
end

local function LayoutChildren(widget)
    if widget.layoutInProgress or (widget.layoutSuspended and widget.layoutSuspended > 0) then
        return
    end

    local content = widget.content
    if not content then return end

    widget.layoutInProgress = true
    local layout = string.lower(widget.layout or "flow")
    local children = widget.children or {}
    local y = 0
    local x = 0
    local rowHeight = 0
    local hasFullHeightChild = false
    local contentWidth = content:GetWidth() or 0
    local contentInset = widget.type == "ScrollFrame" and SCROLL_CONTENT_INSET or 0
    local layoutWidth = math.max(contentWidth - (contentInset * 2), 0)
    local rowGap = layout == "list" and 0 or FLOW_GAP

    for index, child in ipairs(children) do
        local frame = child.frame
        if frame then
            frame:ClearAllPoints()
            if layout == "fill" and index == 1 then
                frame:SetPoint("TOPLEFT", content, "TOPLEFT", contentInset, -contentInset)
                frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -contentInset, contentInset)
            elseif layout == "table" then
                local width = child.relativeWidth and layoutWidth * child.relativeWidth or layoutWidth
                local titleHeight = GetWidgetTitleHeight(child)
                frame:SetPoint("TOPLEFT", content, "TOPLEFT", contentInset, -(contentInset + y + titleHeight))
                frame:SetWidth(width)
                y = y + GetWidgetHeight(child) + titleHeight
            else
                local childWidth = child.fullWidth and (layoutWidth > 0 and layoutWidth or GetWidgetWidth(child))
                    or (child.relativeWidth and layoutWidth * child.relativeWidth or GetWidgetWidth(child))
                local titleHeight = GetWidgetTitleHeight(child)
                -- The title is anchored above the child frame. It occupies
                -- layout space, but it is not part of the child frame's own
                -- height. Including it here makes the parent repeatedly grow
                -- the panel while the panel's layout shrinks itself back.
                local childHeight = GetWidgetHeight(child)
                if layout == "list" and child.text and child.text.SetWordWrap then
                    child.text:SetWordWrap(false)
                    if child.text.SetMaxLines then child.text:SetMaxLines(1) end
                    childHeight = 20
                    if not child.fullHeight then child.frame:SetHeight(childHeight) end
                end
                local occupiedHeight = childHeight + titleHeight
                local startsNewRow = x == 0
                    or child.fullWidth
                    or (layoutWidth > 0 and x + childWidth > layoutWidth)

                if startsNewRow then
                    if x > 0 then y = y + rowHeight + rowGap end
                    x = 0
                    rowHeight = 0
                end

                frame:SetPoint("TOPLEFT", content, "TOPLEFT", contentInset + x, -(contentInset + y + titleHeight))
                if child.fullWidth or (layoutWidth > 0 and childWidth >= layoutWidth) then
                    frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", -contentInset, -(contentInset + y))
                else
                    frame:SetWidth(childWidth)
                end
                if child.fullHeight then
                    frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -contentInset, contentInset)
                    hasFullHeightChild = true
                else
                    frame:SetHeight(childHeight)
                end
                rowHeight = math.max(rowHeight, occupiedHeight)
                if child.fullWidth then
                    x = layoutWidth + rowGap
                else
                    x = x + childWidth + rowGap
                end
            end
            frame:Show()
        end
    end

    if layout ~= "fill" and widget.autoHeight and not widget.fullHeight and not hasFullHeightChild then
        local desiredContentHeight = math.max(y + rowHeight + (contentInset * 2), 1)
        content:SetHeight(desiredContentHeight)
        if #children > 0 then
            local inset = widget.inset or 0
            local desiredFrameHeight = math.max(
                desiredContentHeight + inset * 2,
                widget.explicitHeight or 0,
                widget.minHeight or 0
            )
            if math.abs((widget.frame:GetHeight() or 0) - desiredFrameHeight) > 0.5 then
                widget.frame:SetHeight(desiredFrameHeight)
            end
        end
    end

    widget.layoutInProgress = false
end

local function AddChild(widget, child)
    widget.children = widget.children or {}
    if child.parent and child.parent ~= widget and child.parent.children then
        for index, previousChild in ipairs(child.parent.children) do
            if previousChild == child then
                table.remove(child.parent.children, index)
                break
            end
        end
    end
    widget.children[#widget.children + 1] = child
    child.parent = widget
    local parent = widget.content or widget.frame
    if child.frame and parent then
        child.frame:SetParent(parent)
        child.layoutParentHooks = child.layoutParentHooks or {}
        if not child.layoutParentHooks[widget] then
            child.frame:HookScript("OnSizeChanged", function()
                -- A cached Journey tree can be reparented when its tab is
                -- rebuilt. Ignore resize notifications from an old parent.
                if child.parent ~= widget then
                    return
                end
                LayoutChildren(widget)
                if widget.UpdateScrollMetrics and (not widget.layoutSuspended or widget.layoutSuspended == 0) then
                    widget:UpdateScrollMetrics()
                end
            end)
            child.layoutParentHooks[widget] = true
        end
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

local function CreateBaseWidget(widgetType, parent, frame)
    local widget = {
        type = widgetType,
        callbacks = {},
        userData = {},
        children = {},
        layout = "flow",
        autoHeight = true,
    }
    widget.frame = frame or CreateBackdropFrame("Frame", parent)
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
        self.explicitHeight = height
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
    function widget:BeginUpdate()
        self.layoutSuspended = (self.layoutSuspended or 0) + 1
    end
    function widget:EndUpdate()
        self.layoutSuspended = math.max((self.layoutSuspended or 1) - 1, 0)
        if self.layoutSuspended == 0 then
            LayoutChildren(self)
            if self.UpdateScrollMetrics then self:UpdateScrollMetrics() end
        end
    end
    function widget:RefreshLayout()
        LayoutChildren(self)
        if self.UpdateScrollMetrics then self:UpdateScrollMetrics() end
    end

    return widget
end

local function CreateContainer(widgetType, parent, inset, color)
    local widget = CreateBaseWidget(widgetType, parent)
    widget.inset = inset or 6
    widget.content = CreateBackdropFrame("Frame", widget.frame)
    widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", inset or 6, -(inset or 6))
    widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -(inset or 6), inset or 6)
    widget.border = widget.frame
    if color then
        SetBackdrop(widget.border, color, {0.35, 0.25, 0.1, 1})
    else
        SetBackdrop(widget.border, {0, 0, 0, 0}, {0, 0, 0, 0})
    end

    -- AceGUI's InlineGroup rendered its title for us. Keep that behavior with
    -- the native replacement so linked sections do not become blank bordered
    -- boxes when callers use SetTitle().
    widget.titletext = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widget.titletext:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT", 14, 4)
    widget.titletext:SetPoint("BOTTOMRIGHT", widget.frame, "TOPRIGHT", -14, 4)
    widget.titletext:SetJustifyH("LEFT")
    widget.titletext:SetTextColor(1, 0.82, 0)
    widget.titletext:SetShadowColor(0, 0, 0, 1)
    widget.titletext:SetShadowOffset(1, -1)
    widget.titletext:SetHeight(18)
    widget.titletext:Hide()
    function widget:SetTitle(text)
        self.value = text or ""
        self.titletext:SetText(self.value)
        self.titletext:SetShown(self.value ~= "")
    end
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
    local function UpdateLabelHeight()
        local width = math.max((widget.frame:GetWidth() or DEFAULT_WIDTH) - 8, 1)
        widget.text:SetWidth(width)
        local textHeight = widget.text:GetStringHeight() or 0
        local height = math.max(20, textHeight + 4)
        if math.abs((widget.frame:GetHeight() or 0) - height) > 0.5 then
            widget.frame:SetHeight(height)
        end
    end
    widget.frame:HookScript("OnSizeChanged", UpdateLabelHeight)
    function widget:SetText(text)
        self.value = text
        self.text:SetText(text or "")
        UpdateLabelHeight()
    end
    function widget:SetColor(r, g, b)
        self.text:SetTextColor(r, g, b)
    end
    function widget:SetFontObject(font)
        self.text:SetFontObject(font)
        UpdateLabelHeight()
    end
    function widget:SetJustifyH(justify)
        self.text:SetJustifyH(justify)
    end
    function widget:SetWordWrap(wrap)
        self.text:SetWordWrap(wrap)
        UpdateLabelHeight()
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
    widget.frame = CreateFrame("CheckButton", nil, parent)
    widget.frame:SetSize(24, 24)
    widget.checkbg = widget.frame:CreateTexture(nil, "ARTWORK")
    widget.checkbg:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
    widget.checkbg:SetSize(24, 24)
    widget.checkbg:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    widget.check = widget.frame:CreateTexture(nil, "OVERLAY")
    widget.check:SetAllPoints(widget.checkbg)
    widget.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    widget.highlight = widget.frame:CreateTexture(nil, "HIGHLIGHT")
    widget.highlight:SetAllPoints(widget.checkbg)
    widget.highlight:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    widget.text = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widget.text:SetPoint("LEFT", widget.checkbg, "RIGHT", 4, 0)
    widget.text:SetPoint("RIGHT", widget.frame, "RIGHT", -4, 0)
    widget.text:SetJustifyH("LEFT")
    widget.nativeControl = widget.frame
    widget.frame:SetScript("OnClick", function(frame)
        widget.value = frame:GetChecked()
        Fire(widget, "OnValueChanged", widget.value)
    end)
    widget.frame:SetScript("OnEnter", function() Fire(widget, "OnEnter") end)
    widget.frame:SetScript("OnLeave", function() Fire(widget, "OnLeave") end)
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
    function widget:SetLabel(text)
        self.label = self.text
        self.text:SetText(text or "")
    end
    function widget:SetDisabled(disabled)
        self.disabled = disabled and true or false
        if self.disabled then self.frame:Disable() else self.frame:Enable() end
        self.frame:SetAlpha(self.disabled and 0.55 or 1)
    end
    return widget
end

local function CreateEditBox(widgetType, parent)
    local widget = CreateBaseWidget(widgetType, parent)
    widget.frame:SetHeight(widgetType == "MultiLineEditBox" and 180 or 42)
    -- Use one shared skin for both fields. InputBoxTemplate is a one-line
    -- EditBox template and does not stretch cleanly for the travel entry;
    -- keeping the skin separate also lets both controls use the same tint and
    -- border while the real EditBox remains fully interactive.
    -- Both controls use the same visual skin and real EditBox surface. The
    -- title used to take a separate InputBoxTemplate path, which made it
    -- behave differently from the responsive travel entry.
    widget.editSkin = CreateBackdropFrame("Frame", widget.frame)
    SetBackdrop(widget.editSkin, {0.08, 0.055, 0.03, 0.98}, {0.42, 0.29, 0.12, 0.95})
    widget.editSkin:SetFrameLevel(widget.frame:GetFrameLevel() + 1)
    widget.editSkin:EnableMouse(false)
    widget.scrollBG = widget.editSkin

    if widgetType == "MultiLineEditBox" then
        -- The ScrollFrame is the full-size mouse surface for the multiline
        -- field, including its empty area.
        widget.scrollFrame = CreateFrame("ScrollFrame", nil, widget.frame)
        widget.scrollFrame:SetFrameLevel(widget.frame:GetFrameLevel() + 3)
        widget.scrollFrame:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -20)
        widget.scrollFrame:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -20)
        widget.scrollFrame:SetHeight(150)
        widget.scrollFrame:EnableMouse(true)
        widget.editbox = CreateFrame("EditBox", nil, widget.scrollFrame)
    else
        widget.editbox = CreateFrame("EditBox", nil, widget.frame)
    end

    widget.editbox:SetFrameLevel(widget.frame:GetFrameLevel() + 5)
    widget.editbox:SetAutoFocus(false)
    widget.editbox:EnableMouse(true)
    if widget.editbox.SetHitRectInsets then
        widget.editbox:SetHitRectInsets(0, 0, 0, 0)
    end
    if widgetType == "MultiLineEditBox" and widget.editbox.SetMultiLine then
        widget.editbox:SetMultiLine(true)
        if widget.editbox.SetFontObject and ChatFontNormal then
            widget.editbox:SetFontObject(ChatFontNormal)
        end
        if widget.editbox.SetJustifyV then widget.editbox:SetJustifyV("TOP") end
        if widget.editbox.SetTextInsets then widget.editbox:SetTextInsets(6, 22, 6, 6) end
    elseif widget.editbox.SetTextInsets then
        if widget.editbox.SetFontObject and ChatFontNormal then
            widget.editbox:SetFontObject(ChatFontNormal)
        end
        widget.editbox:SetTextInsets(6, 6, 2, 2)
    end
    if widgetType == "MultiLineEditBox" then
        widget.editbox:SetPoint("TOPLEFT", widget.scrollFrame, "TOPLEFT")
        widget.editbox:SetWidth(math.max(widget.scrollFrame:GetWidth() or 1, 1))
        widget.editbox:SetHeight(150)
        widget.scrollFrame:SetScrollChild(widget.editbox)
    else
        widget.editbox:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -20)
        widget.editbox:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -20)
        widget.editbox:SetHeight(22)
    end
    if widget.editSkin then
        widget.editSkin:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -20)
        widget.editSkin:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -20)
        widget.editSkin:SetHeight(widget.editbox:GetHeight())
        widget.editSkin:Show()
    end
    widget.editbox:Show()
    if widget.editbox.SetTextColor then
        widget.editbox:SetTextColor(1, 1, 1, 1)
    end

    local function FocusAtEnd()
        widget.editbox:SetFocus()
        local textLength = widget.editbox.GetNumLetters and widget.editbox:GetNumLetters()
            or #(widget.editbox:GetText() or "")
        widget.editbox:SetCursorPosition(textLength)
    end

    -- If a client does not give the bare EditBox the full hit rectangle, this
    -- lower-level surface still makes empty-area clicks focus it. The EditBox
    -- remains above it, so normal text clicks keep native caret behavior.
    widget.focusSurface = CreateFrame("Button", nil, widget.frame)
    widget.focusSurface:SetFrameLevel(widget.frame:GetFrameLevel() + 2)
    widget.focusSurface:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -20)
    widget.focusSurface:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -20)
    widget.focusSurface:SetHeight(widgetType == "MultiLineEditBox" and 150 or 22)
    widget.focusSurface:EnableMouse(true)
    widget.focusSurface:SetScript("OnMouseDown", FocusAtEnd)
    widget.focusSurface:SetScript("OnMouseUp", FocusAtEnd)

    widget.editbox:SetScript("OnEnterPressed", function()
        Fire(widget, "OnEnterPressed", widget.editbox:GetText())
    end)
    widget.editbox:SetScript("OnTextChanged", function()
        widget.value = widget.editbox:GetText()
        Fire(widget, "OnTextChanged", widget.value)
    end)
    -- Blank portions of the ScrollFrame do not naturally focus the child
    -- EditBox, so explicitly make them focus the editor like Ace's native
    -- widgets do.
    if widgetType == "MultiLineEditBox" then
        widget.scrollFrame:SetScript("OnMouseDown", FocusAtEnd)
        widget.scrollFrame:SetScript("OnMouseUp", FocusAtEnd)
        widget.scrollFrame:HookScript("OnSizeChanged", function(_, width)
            widget.editbox:SetWidth(math.max(width or 1, 1))
        end)
        widget.editbox:SetScript("OnMouseDown", function(self)
            self:SetFocus()
        end)
        widget.editbox:SetScript("OnCursorChanged", function(_, _, y, _, cursorHeight)
            local offset = widget.scrollFrame:GetVerticalScroll() or 0
            local cursorTop = -(y or 0)
            if cursorTop < offset then
                widget.scrollFrame:SetVerticalScroll(cursorTop)
            else
                local cursorBottom = cursorTop + (cursorHeight or 0) - widget.scrollFrame:GetHeight()
                if cursorBottom > offset then
                    widget.scrollFrame:SetVerticalScroll(cursorBottom)
                end
            end
        end)
        widget.frame:HookScript("OnSizeChanged", function()
            local desiredHeight = (widget.numLines or 12) * 16
            widget.scrollFrame:SetHeight(desiredHeight)
            widget.focusSurface:SetHeight(desiredHeight)
            if math.abs((widget.editbox:GetHeight() or 0) - desiredHeight) > 0.5 then
                widget.editbox:SetHeight(desiredHeight)
            end
            if widget.editSkin then
                widget.editSkin:ClearAllPoints()
                widget.editSkin:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 4, -20)
                widget.editSkin:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -4, -20)
                widget.editSkin:SetHeight(desiredHeight)
                widget.editSkin:Show()
            end
            widget.editbox:Show()
        end)
    end
    widget.button = CreateFrame("Button", nil, widget.frame)
    widget.button:Hide()
    widget.disablebutton = false
    widget.scrollBar = CreateFrame("Slider", nil, widget.frame, "UIPanelScrollBarTemplate")
    if widgetType == "MultiLineEditBox" then
        -- Keep the scrollbar above the editable surface and stretch it nearly
        -- from the top to the bottom of the editor.
        widget.scrollBar:SetFrameLevel(widget.editbox:GetFrameLevel() + 1)
        widget.scrollBar.modernScrollbarAnchor = widget.scrollFrame
        widget.scrollBar.modernScrollbarInset = 2
        widget.scrollBar.modernScrollbarRightInset = 3
    end
    local scrollAnchor = widget.scrollFrame or widget.editbox
    widget.scrollBar:SetPoint("TOPRIGHT", scrollAnchor, "TOPRIGHT", -3, 0)
    widget.scrollBar:SetPoint("BOTTOMRIGHT", scrollAnchor, "BOTTOMRIGHT", -3, 0)
    if widgetType == "MultiLineEditBox" then
        widget.scrollBar:SetValueStep(16)
        widget.scrollBar:SetScript("OnValueChanged", function(_, value)
            local current = widget.scrollFrame:GetVerticalScroll() or 0
            if math.abs(current - value) > 0.5 then
                widget.scrollFrame:SetVerticalScroll(value)
            end
        end)
        widget.scrollFrame:HookScript("OnVerticalScroll", function(_, offset)
            local minimum, maximum = widget.scrollBar:GetMinMaxValues()
            widget.scrollBar:SetValue(math.max(minimum, math.min(maximum, offset or 0)))
        end)
        widget.scrollFrame:HookScript("OnScrollRangeChanged", function(_, _, verticalRange)
            widget.scrollBar:SetMinMaxValues(0, math.max(verticalRange or 0, 0))
        end)
    end
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
        if self.scrollFrame then self.scrollFrame:SetHeight(lines * 16) end
        self.editbox:SetHeight(lines * 16)
        if self.editSkin then
            self.editSkin:SetHeight(lines * 16)
            self.editSkin:Show()
        end
        self.editbox:Show()
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
    -- Create the scroll frame first and pass that exact frame to the widget
    -- wrapper. Creating a normal container and replacing widget.frame later
    -- leaves content attached to an orphaned frame; the pane then appears
    -- selected but renders empty depending on which layout path ran first.
    local scrollFrame = CreateBackdropFrame("ScrollFrame", parent)
    local widget = CreateBaseWidget("ScrollFrame", parent, scrollFrame)
    widget.inset = 0
    widget.border = widget.frame
    SetBackdrop(widget.border, {0.08, 0.055, 0.03, 0.96}, {0.35, 0.25, 0.1, 1})
    widget.content = CreateBackdropFrame("Frame", widget.frame)
    widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
    widget.content:SetWidth(1)
    widget.content:SetHeight(1)
    widget.frame:SetScrollChild(widget.content)
    widget.frame:EnableMouseWheel(true)
    widget.scrollbar = CreateJourneyScrollBar(widget.frame)
    if widget.scrollbar.questieNativeMinimalScrollBar then
        widget.scrollbar:SetPoint("RIGHT", widget.frame, "RIGHT", -12, 0)
        widget.scrollbar:SetPoint("BOTTOM", widget.frame, "BOTTOM", 0, 5)
        widget.scrollbar:SetPoint("TOP", widget.frame, "TOP", 0, -5)
        ScrollUtil.InitScrollFrameWithScrollBar(widget.frame, widget.scrollbar)
        widget.scrollbar:SetHideIfUnscrollable(true)
    else
        widget.scrollbar:SetScript("OnValueChanged", function(_, value)
            widget.frame:SetVerticalScroll(value)
        end)
        widget.scrollbar:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -2, -2)
        widget.scrollbar:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -2, 2)
    end
    function widget:UpdateContentWidth()
        local scrollbarWidth = widget.scrollbar.questieNativeMinimalScrollBar and (widget.scrollbar:GetWidth() or 8) or 16
        widget.content:SetWidth(math.max((widget.frame:GetWidth() or 1) - scrollbarWidth, 1))
    end

    widget:UpdateContentWidth()
    widget.frame:HookScript("OnSizeChanged", function()
        widget:UpdateContentWidth()
        LayoutChildren(widget)
        if widget.UpdateScrollMetrics and (not widget.layoutSuspended or widget.layoutSuspended == 0) then
            widget:UpdateScrollMetrics()
        end
    end)
    if not widget.scrollbar.questieNativeMinimalScrollBar then
        widget.scrollbar:SetMinMaxValues(0, 0)
        widget.scrollbar:SetValueStep(1)
    end
    function widget:UpdateScrollMetrics()
        self:UpdateContentWidth()
        local viewHeight = self.frame:GetHeight() or 0
        -- LayoutChildren accounts for title rows, wrapping, and flow/list gaps.
        -- Re-summing only the child frame heights here undercounted nested
        -- Journey panels and let the last panel extend past the viewport.
        LayoutChildren(self)
        local contentHeight = self.content:GetHeight() or 0
        contentHeight = math.max(contentHeight, viewHeight, 1)
        self.content:SetHeight(contentHeight)
        if not self.scrollbar.questieNativeMinimalScrollBar then
            local maximum = math.max(0, contentHeight - viewHeight)
            self.scrollbar:SetMinMaxValues(0, maximum)
            self.scrollbar:SetShown(maximum > 0)
            self.scrollbar:SetValue(math.min(self.scrollbar:GetValue() or 0, maximum))
        end
    end
    if not widget.scrollbar.questieNativeMinimalScrollBar then
        widget.frame:HookScript("OnMouseWheel", function(_, delta)
            local minimum, maximum = widget.scrollbar:GetMinMaxValues()
            local value = widget.scrollbar:GetValue() - delta * 40
            widget.scrollbar:SetValue(math.max(minimum, math.min(maximum, value)))
        end)
    end
    function widget:SetHeight(height)
        self.explicitHeight = height
        self.frame:SetHeight(height)
        self:UpdateContentWidth()
        if not self.layoutSuspended or self.layoutSuspended == 0 then
            self:UpdateScrollMetrics()
        end
    end
    function widget:AddChild(child)
        self:UpdateContentWidth()
        AddChild(self, child)
        if not self.layoutSuspended or self.layoutSuspended == 0 then
            self:UpdateScrollMetrics()
        end
    end
    function widget:RefreshLayout()
        self:UpdateContentWidth()
        LayoutChildren(self)
        if self.UpdateScrollMetrics then self:UpdateScrollMetrics() end
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
    widget.treeScroll:EnableKeyboard(true)
    if widget.treeScroll.SetPropagateKeyboardInput then
        widget.treeScroll:SetPropagateKeyboardInput(true)
    end
    widget.treeContent = CreateFrame("Frame", nil, widget.treeScroll)
    widget.treeContent:SetPoint("TOPLEFT", widget.treeScroll, "TOPLEFT")
    widget.treeContent:SetWidth(1)
    widget.treeContent:SetHeight(1)
    widget.treeScroll:SetScrollChild(widget.treeContent)
    widget.scrollbar = CreateJourneyScrollBar(widget.treeframe)
    if widget.scrollbar.questieNativeMinimalScrollBar then
        widget.scrollbar:SetPoint("RIGHT", widget.treeframe, "RIGHT", -12, 0)
        widget.scrollbar:SetPoint("BOTTOM", widget.treeframe, "BOTTOM", 0, 5)
        widget.scrollbar:SetPoint("TOP", widget.treeframe, "TOP", 0, -5)
        ScrollUtil.InitScrollFrameWithScrollBar(widget.treeScroll, widget.scrollbar)
        widget.scrollbar:SetHideIfUnscrollable(true)
    else
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
    end
    SetBackdrop(widget.treeframe, {0.08, 0.055, 0.03, 0.96}, {0.35, 0.25, 0.1, 1})
    widget.content:ClearAllPoints()
    widget.content:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", -2, 0)
    widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")

    local function FindNode(nodes, parts, index)
        for _, node in ipairs(nodes or {}) do
            if tostring(node.value) == tostring(parts[index]) then
                if index == #parts then return node end
                return FindNode(node.children, parts, index + 1)
            end
        end
    end

    local renderingTree = false
    local layingOutTree = false

    local function FocusTree()
        if widget.treeScroll.SetFocus then
            widget.treeScroll:SetFocus()
        end
    end

    local function GetVisibleSelectableButtons()
        local buttons = {}
        for _, button in ipairs({widget.treeContent:GetChildren()}) do
            if button.treeValue and button.treeOrder and button:IsShown() and button.treeSelectable then
                buttons[#buttons + 1] = button
            end
        end
        table.sort(buttons, function(left, right)
            return left.treeOrder < right.treeOrder
        end)
        return buttons
    end

    local function ScrollButtonIntoView(button)
        if not button or not button.GetTop or not button.GetBottom
            or not widget.treeScroll.GetTop or not widget.treeScroll.GetBottom then
            return
        end

        local top = button:GetTop()
        local bottom = button:GetBottom()
        local viewTop = widget.treeScroll:GetTop()
        local viewBottom = widget.treeScroll:GetBottom()
        if not top or not bottom or not viewTop or not viewBottom then
            return
        end

        local scroll = widget.treeScroll:GetVerticalScroll() or 0
        if top > viewTop then
            widget.treeScroll:SetVerticalScroll(math.max(0, scroll - (top - viewTop)))
        elseif bottom < viewBottom then
            widget.treeScroll:SetVerticalScroll(math.max(0, scroll + (viewBottom - bottom)))
        end
    end

    local function SelectAdjacentEntry(direction)
        local buttons = GetVisibleSelectableButtons()
        if #buttons == 0 then
            return
        end

        local selected = tostring(widget.localstatus.selected or "")
        local selectedIndex
        for index, button in ipairs(buttons) do
            if button.treeValue == selected then
                selectedIndex = index
                break
            end
        end

        local targetIndex
        if selectedIndex then
            targetIndex = selectedIndex + direction
        else
            targetIndex = direction > 0 and 1 or #buttons
        end
        if targetIndex < 1 or targetIndex > #buttons then
            return
        end

        local target = buttons[targetIndex]
        widget:SelectByValue(target.treeValue)
        ScrollButtonIntoView(target)
    end

    widget.treeScroll:SetScript("OnKeyDown", function(_, key)
        local handled = key == "UP" or key == "DOWN"
        if widget.treeScroll.SetPropagateKeyboardInput then
            widget.treeScroll:SetPropagateKeyboardInput(not handled)
        end
        if key == "UP" then
            SelectAdjacentEntry(-1)
        elseif key == "DOWN" then
            SelectAdjacentEntry(1)
        end
    end)

    local function RenderTree()
        if renderingTree then
            return
        end
        renderingTree = true
        for _, child in ipairs({widget.treeContent:GetChildren()}) do child:Hide() end
        local y = -4
        local rowOrder = 0
        local function AddNodes(nodes, path, depth)
            for _, node in ipairs(nodes or {}) do
                local nodePath = path and (path .. PATH_SEPARATOR .. tostring(node.value)) or tostring(node.value)
                local button = CreateFrame("Button", nil, widget.treeContent)
                button.treeValue = nodePath
                rowOrder = rowOrder + 1
                button.treeOrder = rowOrder
                button.treeDisabled = node.disabled
                button.treeSelectable = not node.children and not node.disabled
                button:SetPoint("TOPLEFT", widget.treeContent, "TOPLEFT", depth * 10, y)
                -- Avoid measuring or setting row widths while a parent is
                -- laying itself out. SetWidth here re-entered the native
                -- OnSizeChanged chain for every result in a broad search.
                -- Anchoring to the viewport gives the row the same width
                -- without a synchronous width measurement/update loop.
                button:SetPoint("TOPRIGHT", widget.treeScroll, "TOPRIGHT", -depth * 10, y)
                button:SetHeight(22)
                button:SetFrameLevel(widget.treeScroll:GetFrameLevel() + 1)
                button:EnableMouse(true)
                -- The default listbox highlight is a bright white strip that
                -- clashes with Journey's brown/gold surfaces. Use the same
                -- bronze family as the modern Journey link hover treatment,
                -- with enough opacity to remain visible over the pane.
                local highlight = button:CreateTexture(nil, "BACKGROUND")
                highlight:SetAllPoints(button)
                highlight:SetColorTexture(0.42, 0.27, 0.05, 0.68)
                button:SetHighlightTexture(highlight)
                button.text = button:CreateFontString(nil, "OVERLAY", node.children and "GameFontNormal" or "GameFontHighlightSmall")
                button.text:SetText(node.text or tostring(node.value))
                button.text:SetJustifyH("LEFT")
                button.text:SetWordWrap(false)
                if button.text.SetMaxLines then button.text:SetMaxLines(1) end

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
                    button.toggle:SetScript("OnMouseDown", FocusTree)
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
                    if node.disabled then
                        return
                    end
                    local alreadySelected = widget.localstatus.selected == nodePath
                    Fire(widget, "OnClick", nodePath, alreadySelected)
                    -- A repeated click must be able to restore details after
                    -- a tree rebuild cleared the pane while retaining the
                    -- same selected path.
                    widget:SelectByValue(nodePath, alreadySelected)
                end)
                button:SetScript("OnMouseDown", FocusTree)
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
        if not widget.scrollbar.questieNativeMinimalScrollBar then
            local maximum = math.max(0, contentHeight - viewHeight)
            widget.scrollbar:SetMinMaxValues(0, maximum)
            widget.scrollbar:SetShown(maximum > 0)
            widget.treeScroll:SetVerticalScroll(math.min(widget.treeScroll:GetVerticalScroll() or 0, maximum))
        end
        renderingTree = false
    end

    local function LayoutTree()
        -- Keep this callback limited to the detail-pane anchors. Rebuilding
        -- buttons here causes a recursive OnSizeChanged -> LayoutTree ->
        -- RenderTree cycle on the native WoW frames used by Journey.
        if layingOutTree or renderingTree then
            return
        end
        layingOutTree = true
        widget.content:ClearAllPoints()
        widget.content:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", -2, 0)
        widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")
        layingOutTree = false
    end
    widget.frame:HookScript("OnSizeChanged", LayoutTree)
    widget.treeframe:HookScript("OnSizeChanged", LayoutTree)

    function widget:SetTree(tree)
        self.tree = tree or {}
        RenderTree()
    end
    function widget:CollapseAllGroups()
        local function Collapse(nodes, parentPath)
            for _, node in ipairs(nodes or {}) do
                local nodePath = parentPath and (parentPath .. PATH_SEPARATOR .. tostring(node.value)) or tostring(node.value)
                if node.children then
                    self.localstatus.groups[nodePath] = false
                    Collapse(node.children, nodePath)
                end
            end
        end

        Collapse(self.tree)
        RenderTree()
    end
    function widget:SelectByValue(value, force)
        self.localstatus.selected = tostring(value)
        for _, button in ipairs({self.treeContent:GetChildren()}) do
            if button.treeValue == self.localstatus.selected then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end
        end
        Fire(self, "OnGroupSelected", self.localstatus.selected, force)
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
    widget.tabButtons = {}
    widget.tabBar = CreateFrame("Frame", nil, widget.frame)
    widget.tabBar:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
    widget.tabBar:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT")
    widget.tabBar:SetHeight(32)
    widget.content:SetFrameLevel(widget.frame:GetFrameLevel() + 1)
    -- Content widgets create their own child frames, so a small level offset
    -- is not enough to keep the tabs above the result container.
    widget.tabBar:SetFrameLevel(widget.frame:GetFrameLevel() + 20)
    local function RaiseTabBar()
        -- Result trees are added after the tab strip and can otherwise end up
        -- above it in the native frame stack. Keep the tabs above every
        -- result/detail child; this is especially important when a search
        -- query rebuilds the tree without recreating the TabGroup.
        widget.tabBar:SetFrameLevel(widget.frame:GetFrameLevel() + 100)
        widget.tabBar:Show()
        widget.tabBar:Raise()
        for _, child in ipairs({widget.tabBar:GetChildren()}) do
            -- A tab refresh can leave retired buttons parented to the tab
            -- bar. Re-showing every child here would resurrect those stale
            -- buttons and create the doubled-tab artifact during a hover
            -- preview refresh.
            if child:IsShown() then
                child:SetFrameLevel(widget.tabBar:GetFrameLevel() + 1)
                child:Raise()
            end
        end
    end
    local function LayoutTabGroup()
        -- CreateContainer reanchors content when the parent is resized. Keep
        -- the content below the tab bar after that generic layout pass.
        widget.content:ClearAllPoints()
        widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 0, -34)
        widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")
    end
    LayoutTabGroup()
    widget.frame:HookScript("OnSizeChanged", LayoutTabGroup)
    function widget:SetTabs(tabs)
        self.tabs = tabs or {}
        self.modernHoveredTab = nil
        self.tabBar:Show()
        local activeButtons = {}
        for _, tab in ipairs(self.tabs) do
            local button = self.tabButtons[tab.value]
            if not button then
                local nativeOk
                nativeOk, button = pcall(CreateFrame, "Button", nil, self.tabBar, "MinimalTabTemplate")
                if not nativeOk or not button then
                    button = CreateFrame("Button", nil, self.tabBar, "UIPanelButtonTemplate")
                end
                self.tabButtons[tab.value] = button
            end
            activeButtons[button] = true
            button.questieTabData = tab
            button:SetSize(math.max(90, (tab.text and string.len(tab.text) or 8) * 8 + 24), 28)
            button:SetFrameLevel(self.tabBar:GetFrameLevel() + 1)
            if button.Text then button.Text:SetText(tab.text or tab.value) else button:SetText(tab.text or tab.value) end
            tab.disabled = tab.disabled and true or false
            if tab.disabled then button:Disable() else button:Enable() end
            button:SetScript("OnClick", function(currentButton)
                local currentTab = currentButton.questieTabData
                if currentTab and not currentTab.disabled then
                    self:SelectTab(currentTab.value)
                end
            end)
            if button.SetSelected then
                button:SetSelected(tab.value == self.localstatus.selected)
            end
            tab.button = button
            button:Show()
        end
        for _, button in pairs(self.tabButtons) do
            if not activeButtons[button] then
                button:Hide()
            end
        end
        self:LayoutTabs()
        RaiseTabBar()
    end
    function widget:LayoutTabs()
        local gap = 4
        local tabCount = #self.tabs
        local barWidth = self.tabBar:GetWidth() or 0
        local equalWidth = barWidth > 0 and math.floor((barWidth - gap * math.max(0, tabCount - 1)) / tabCount) or nil
        local x = 0
        for _, tab in ipairs(self.tabs) do
            local button = tab.button
            if button then
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", self.tabBar, "TOPLEFT", x, 0)
                if equalWidth then button:SetWidth(math.max(90, equalWidth)) end
                x = x + button:GetWidth() + gap
            end
        end
        RaiseTabBar()
    end
    function widget:SetTabBarWidth(width)
        self.tabBar:ClearAllPoints()
        self.tabBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT")
        self.tabBar:SetWidth(width)
        self:LayoutTabs()
    end
    function widget:RaiseTabs()
        RaiseTabBar()
    end
    function widget:SelectTab(value)
        self.localstatus.selected = value
        for _, tab in ipairs(self.tabs) do
            local selected = tab.value == value
            tab.selected = selected
            if tab.button.SetSelected then
                tab.button:SetSelected(selected)
            elseif selected then
                tab.button:LockHighlight()
            else
                tab.button:UnlockHighlight()
            end
        end
        Fire(self, "OnGroupSelected", value)
    end
    return widget
end

local function CreateIcon(parent)
    local widget = CreateBaseWidget("Icon", parent)
    widget.frame:SetSize(32, 32)
    widget.frame:EnableMouse(true)
    widget.frame:SetScript("OnEnter", function()
        Fire(widget, "OnEnter")
    end)
    widget.frame:SetScript("OnLeave", function()
        Fire(widget, "OnLeave")
    end)
    widget.frame:SetScript("OnMouseUp", function(_, button)
        Fire(widget, "OnClick", button)
    end)
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
    function widget:ShowTooltip() self.frame:Show() end
    function widget:HideTooltip() self.frame:Hide() end
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
            widget.frame:SetScript("OnEnter", function()
                Fire(widget, "OnEnter")
            end)
            widget.frame:SetScript("OnLeave", function()
                Fire(widget, "OnLeave")
            end)
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
