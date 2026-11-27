---The art and frames of Questie's own windows, for the settings and My Journey, and of their side tabs.
---Which tab is shown and what it contains belongs to QuestieOptionsEngine and JourneyWindow.
---@class QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:CreateModule("QuestieOptionsWindow")

---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Space left of the page title, which the portrait reaches into. The search box is on one line with the page title, and
-- as far from the right edge of the page.
QuestieOptionsWindow.HEADER_INSET = 52
local HEADER_CENTER_Y = -17
local FIRST_SIDE_TAB_Y = -35
-- The frames of a window reach up to level 510, where its template has the close button
local POPUP_LEVEL = 600
-- Classic's tab art has empty space below it, which the next tab reaches into
local CLASSIC_SIDE_TAB_OVERLAP = 10

---Lets the window be resized from its bottom right corner.
---@param window Frame
---@param minWidth number
---@param minHeight number
---@param onResized fun(width: number, height: number)?
local function _AddResizeGrip(window, minWidth, minHeight, onResized)
    window:SetResizable(true)

    -- Every supported client has this grip, and keeps the minimum size while it is dragged. Checked in Blizzard's source
    -- (see AGENTS.md).
    local grip = CreateFrame("Button", nil, window, "PanelResizeButtonTemplate")
    grip:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -3, 3)
    grip:SetFrameLevel(window:GetFrameLevel() + 10) -- Above the pages, which reach into the corner
    grip:Init(window, minWidth, minHeight)
    window.resizeGrip = grip
    -- Every supported client calls it when the grip is released, also by the code below. Checked in Blizzard's source.
    if onResized then
        grip:SetOnResizeStoppedCallback(function() onResized(window:GetWidth(), window:GetHeight()) end)
    end

    -- The mouse-up never arrives when the window hides while it is being resized
    window:HookScript("OnHide", function()
        if grip:IsActive() then
            grip:OnMouseUp()
        end
    end)
end

---@class QuestieWindowSettings
---@field name string Global name of the window, which also lets the Escape key close it
---@field title string
---@field strata string
---@field isPopup boolean? Above other windows in the same strata
---@field width number
---@field height number
---@field minWidth number? Together with minHeight. Without them the window keeps its size.
---@field minHeight number?
---@field onResized fun(width: number, height: number)? After the user resized the window

---Creates the hidden window. Tab canvases go in its canvasContainer.
---@param settings QuestieWindowSettings
---@return Frame window
function QuestieOptionsWindow.Create(settings)
    local window = CreateFrame("Frame", settings.name, UIParent, "PortraitFrameTemplate")
    window:SetSize(settings.width, settings.height)
    window:SetPoint("CENTER")
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetFrameStrata(settings.strata)
    if settings.isPopup then
        window:SetFrameLevel(POPUP_LEVEL)
    end
    window:Hide()
    window:SetTitle(settings.title)
    window:EnableMouse(true)

    local closeButton = window.CloseButton
    local textures = {
        closeButton:GetNormalTexture(), closeButton:GetPushedTexture(), closeButton:GetHighlightTexture(), closeButton:GetDisabledTexture(),
        window.PortraitFrame, window.TopRightCorner, window.TopLeftCorner, window.TopBorder, window.TopTileStreaks,
        window.BotLeftCorner, window.BotRightCorner, window.BottomBorder, window.LeftBorder, window.RightBorder,
    }
    for _, texture in pairs(textures) do
        QuestieOptionsUtils.DisableSnapping(texture)
    end

    -- Dragging works along the top of the window, between the portrait and the close button
    local dragBar = CreateFrame("Frame", nil, window)
    dragBar:SetPoint("TOPLEFT", window, "TOPLEFT", 55, 0)
    dragBar:SetPoint("TOPRIGHT", window, "TOPRIGHT", -30, 0)
    dragBar:SetHeight(28)
    dragBar:EnableMouse(true)
    window.dragBar = dragBar

    dragBar:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" and not window.isMoving then
            window:StartMoving()
            window.isMoving = true
        end
    end)

    dragBar:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and window.isMoving then
            window:StopMovingOrSizing()
            window.isMoving = false
        end
    end)

    -- The mouse-up never arrives when the window hides during a drag
    window:HookScript("OnHide", function()
        if window.isMoving then
            window:StopMovingOrSizing()
            window.isMoving = false
        end
    end)

    window:SetPortraitTextureRaw("Interface\\AddOns\\Questie\\Icons\\questie_portrait.png", nil, nil, "TRILINEAR")
    local portrait = window.PortraitContainer.portrait
    if Questie.IsForever then
        if portrait then portrait:SetTexCoord(0.16, 0.86, 0.17, 0.87) end
        if window.Bg then window.Bg:SetColorTexture(30 / 255, 23 / 255, 18 / 255, 0.96) end
    else
        if portrait then portrait:SetTexCoord(0.21, 0.815, 0.21, 0.815) end
        if window.Bg then window.Bg:SetColorTexture(0.16, 0.145, 0.133, 0.96) end
    end
    QuestieOptionsUtils.DisableSnapping(portrait)

    window.canvasContainer = CreateFrame("Frame", nil, window)
    window.canvasContainer:SetPoint("TOPLEFT", window, "TOPLEFT", 10, -30)
    window.canvasContainer:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -10, 10)

    if settings.minWidth then
        _AddResizeGrip(window, settings.minWidth, settings.minHeight, settings.onResized)
    end

    -- Lets the Escape key close the window
    tinsert(UISpecialFrames, settings.name)

    return window
end

---Adds a search box, which stays in place whichever tab is shown.
---@param window Frame
---@param onSearchChanged fun(text: string)
---@param width number?
---@param placeholder string?
function QuestieOptionsWindow.AddSearchBox(window, onSearchChanged, width, placeholder)
    local searchBox = CreateFrame("EditBox", nil, window, "SearchBoxTemplate")
    searchBox:SetSize(width or 180, 20)
    searchBox:SetPoint("RIGHT", window.canvasContainer, "TOPRIGHT", -QuestieOptionsWindow.HEADER_INSET, HEADER_CENTER_Y)
    searchBox:SetFrameLevel(window:GetFrameLevel() + 10) -- Above the canvases, which cover the header
    searchBox.Instructions:SetText(placeholder or l10n("Search"))
    -- Hooked, because the template shows and hides its placeholder and clear button from this
    searchBox:HookScript("OnTextChanged", function(self)
        onSearchChanged(self:GetText() or "")
    end)
    window.searchBox = searchBox
end

---Creates the text at the top of a page that says which page it is.
---@param parent Frame Holds the text
---@param page Frame
---@param leftInset number
---@return FontString pageTitle
function QuestieOptionsWindow.CreatePageTitle(parent, page, leftInset)
    local pageTitle = parent:CreateFontString(nil, "OVERLAY", "Game13Font")
    pageTitle:SetPoint("TOPLEFT", page, "TOPLEFT", leftInset, -10)
    pageTitle:SetTextColor(0.9, 0.9, 0.9, 1.0)
    return pageTitle
end

---@param icon Texture
---@param tabData table Its iconCrop is the part of the icon that is cut off on each side, to zoom in on the rest
local function _SetTabIcon(icon, tabData)
    local crop = tabData.iconCrop or 0
    icon:SetTexture(tabData.icon or 134400)
    icon:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
end

---Makes a tab react to the mouse: the press animation, the tooltip, and the click.
---@param button Button
---@param icon Texture
---@param tabKey string
---@param tabData table
---@param tooltipAnchor string Opens the tooltip away from the window
---@param onClick fun()
local function _AddTabInput(button, icon, tabKey, tabData, tooltipAnchor, onClick)
    -- Pressing nudges the icon down and right by a pixel, without moving the mask or the other art
    local iconPoint, iconRelativeTo, iconRelativePoint, iconX, iconY = icon:GetPoint(1)
    iconX = iconX or 0
    iconY = iconY or 0
    local isPressed = false

    local function ResetIconPosition()
        if isPressed then
            isPressed = false
            button:SetScript("OnUpdate", nil)
            icon:SetPoint(iconPoint, iconRelativeTo, iconRelativePoint, iconX, iconY)
        end
    end

    button:HookScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" and not isPressed then
            isPressed = true
            icon:SetPoint(iconPoint, iconRelativeTo, iconRelativePoint, iconX + 1, iconY - 1)

            -- The mouse-up does not arrive when the button is released away from the tab
            self:SetScript("OnUpdate", function()
                if not IsMouseButtonDown("LeftButton") then
                    ResetIconPosition()
                end
            end)
        end
    end)

    button:HookScript("OnMouseUp", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            ResetIconPosition()
        end
    end)

    button:HookScript("OnHide", ResetIconPosition)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, tooltipAnchor)
        GameTooltip:SetText(l10n(tabData.title) or tabKey, 1, 1, 1)
        if tabData.subtitle then
            GameTooltip:AddLine(l10n(tabData.subtitle), 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    QuestieOptionsUtils.HideTooltipOnHide(button)

    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        onClick()
    end)
end

---Creates a tab button on the outside right edge of the window.
---@param window Frame
---@param tabKey string
---@param tabData table
---@param previousSideTab Frame? The tab above this one. Nil for the first tab.
---@param onSelect fun(tabKey: string)
---@return Frame sideTab
function QuestieOptionsWindow.CreateSideTab(window, tabKey, tabData, previousSideTab, onSelect)
    local sideTab = CreateFrame("Frame", "$parent_Tab_" .. tabKey, window)

    -- Window art differs between clients, so the tabs need different alignment and art
    local isForever = Questie.IsForever

    if not previousSideTab then
        sideTab:SetPoint("TOPLEFT", window, "TOPRIGHT", isForever and -1 or -2, FIRST_SIDE_TAB_Y)
    else
        sideTab:SetPoint("TOPLEFT", previousSideTab, "BOTTOMLEFT", 0, isForever and 0 or CLASSIC_SIDE_TAB_OVERLAP)
    end

    local background = sideTab:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 0, 0)
    if isForever then
        background:SetAtlas("common-sidetab", true)
        sideTab:SetSize(background:GetSize())
    else
        background:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
        sideTab:SetSize(64, 64)
    end
    sideTab.Background = background

    -- Not parented to the background, so it can move on its own when the button is pressed
    local icon = sideTab:CreateTexture(nil, "ARTWORK")
    if isForever then
        icon:SetPoint("CENTER", sideTab, "CENTER", -1, 0)
        icon:SetSize(62, 62)
    else
        icon:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 1, -9)
        icon:SetSize(36, 36)
    end
    _SetTabIcon(icon, tabData)
    sideTab.Icon = icon

    local mask = sideTab:CreateMaskTexture(nil, "ARTWORK")
    if isForever then
        mask:SetAtlas("common-sidetab-mask", true)
        mask:SetPoint("CENTER", sideTab, "CENTER", -2, 0)
        mask:SetSize(62, 62)
    else
        mask:SetTexture("interface\\hud\\uicooldownmanagermask")
        mask:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 1, -9)
        mask:SetSize(36, 36)
    end
    icon:AddMaskTexture(mask)
    sideTab.Mask = mask

    local button = CreateFrame("Button", "$parent_Button", sideTab)
    if isForever then
        button:SetSize(50, 50)
        button:SetPoint("CENTER", sideTab, "CENTER", -2, -1)
    else
        button:SetSize(36, 36)
        button:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 1, -9)
    end
    sideTab.button = button

    local selected = sideTab:CreateTexture(nil, "OVERLAY")
    if isForever then
        selected:SetAtlas("common-sidetab-selected", true)
        selected:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 0, 0)
    else
        selected:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        selected:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 1, -9)
        selected:SetSize(36, 36)
        selected:SetBlendMode("ADD")
    end
    selected:Hide()
    sideTab.Selected = selected

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    if isForever then
        highlight:SetAtlas("common-sidetab-hover", true)
        highlight:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 0, 0)
    else
        highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        highlight:SetPoint("TOPLEFT", sideTab, "TOPLEFT", 1, -9)
        highlight:SetSize(36, 36)
    end
    highlight:SetBlendMode("ADD")
    sideTab.Highlight = highlight

    QuestieOptionsUtils.DisableSnapping(background)
    QuestieOptionsUtils.DisableSnapping(icon)
    QuestieOptionsUtils.DisableSnapping(mask)
    QuestieOptionsUtils.DisableSnapping(selected)
    QuestieOptionsUtils.DisableSnapping(highlight)

    _AddTabInput(button, icon, tabKey, tabData, "ANCHOR_RIGHT", function() onSelect(tabKey) end)

    return sideTab
end

---Creates a tab on the outside left edge of the window, which leads somewhere else instead of showing a page.
---@param window Frame
---@param tabKey string
---@param tabData table
---@param onClick fun()
---@return Frame linkTab
function QuestieOptionsWindow.CreateLinkTab(window, tabKey, tabData, onClick)
    local linkTab = CreateFrame("Frame", "$parent_Tab_" .. tabKey, window)

    -- Window art differs between clients, so the tab needs different alignment and art
    local isForever = Questie.IsForever

    -- The art is made for the right edge, so it is mirrored
    local background = linkTab:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPRIGHT", linkTab, "TOPRIGHT", 0, 0)
    if isForever then
        background:SetAtlas("common-sidetab", true)
        linkTab:SetSize(background:GetSize())
    else
        background:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
        linkTab:SetSize(64, 64)
    end
    background:SetTexCoord(1, 0, 0, 1)
    linkTab.Background = background

    -- Level with the second side tab, because the portrait reaches over the left edge next to the first
    local secondSideTabY = FIRST_SIDE_TAB_Y - linkTab:GetHeight() + (isForever and 0 or CLASSIC_SIDE_TAB_OVERLAP)
    -- On Classic, the metal of the window's left edge lies on both sides of this point and must not be covered
    linkTab:SetPoint("TOPRIGHT", window, "TOPLEFT", isForever and 1 or 0, secondSideTabY)

    local icon = linkTab:CreateTexture(nil, "ARTWORK")
    -- Anchored on its own, so it stays in place when the icon is pressed. Forever's mask for side tabs is made for the
    -- right edge and masks can't be mirrored, so both clients use the symmetric one here.
    local mask = linkTab:CreateMaskTexture(nil, "ARTWORK")
    mask:SetTexture("interface\\hud\\uicooldownmanagermask")
    local button = CreateFrame("Button", "$parent_Button", linkTab)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    if isForever then
        icon:SetPoint("CENTER", linkTab, "CENTER", 3, 0)
        icon:SetSize(48, 48)
        mask:SetPoint("CENTER", linkTab, "CENTER", 3, 0)
        mask:SetSize(48, 48)
        button:SetPoint("CENTER", linkTab, "CENTER", 2, -1)
        button:SetSize(50, 50)
        highlight:SetAtlas("common-sidetab-hover", true)
        highlight:SetPoint("TOPRIGHT", linkTab, "TOPRIGHT", 0, 0)
        highlight:SetTexCoord(1, 0, 0, 1)
    else
        icon:SetPoint("TOPRIGHT", linkTab, "TOPRIGHT", -1, -9)
        icon:SetSize(36, 36)
        mask:SetPoint("TOPRIGHT", linkTab, "TOPRIGHT", -1, -9)
        mask:SetSize(36, 36)
        button:SetPoint("TOPRIGHT", linkTab, "TOPRIGHT", -1, -9)
        button:SetSize(36, 36)
        highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        highlight:SetPoint("TOPRIGHT", linkTab, "TOPRIGHT", -1, -9)
        highlight:SetSize(36, 36)
    end
    _SetTabIcon(icon, tabData)
    icon:AddMaskTexture(mask)
    highlight:SetBlendMode("ADD")
    linkTab.Icon = icon
    linkTab.Mask = mask
    linkTab.Highlight = highlight
    linkTab.button = button

    QuestieOptionsUtils.DisableSnapping(background)
    QuestieOptionsUtils.DisableSnapping(icon)
    QuestieOptionsUtils.DisableSnapping(mask)
    QuestieOptionsUtils.DisableSnapping(highlight)

    _AddTabInput(button, icon, tabKey, tabData, "ANCHOR_LEFT", onClick)

    return linkTab
end

---@param sideTab Frame
---@param isSelected boolean
function QuestieOptionsWindow.SetSideTabSelected(sideTab, isSelected)
    sideTab.Selected:SetShown(isSelected)
    sideTab.Icon:SetAlpha(isSelected and 1.0 or 0.65) -- Darkens the icons of inactive tabs
end

return QuestieOptionsWindow
