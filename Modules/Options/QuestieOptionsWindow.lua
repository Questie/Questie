---The art and frames of Questie's own settings window and its side tabs.
---Which tab is shown and what it contains belongs to QuestieOptionsEngine.
---@class QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:CreateModule("QuestieOptionsWindow")

---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WINDOW_NAME = "QuestieStandaloneSettings"
local WINDOW_WIDTH = 675
local RESIZER_SIZE = 16
local RESIZER_UP = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"
local RESIZER_DOWN = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"
local RESIZER_HIGHLIGHT = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight"

local function ApplyResizeBounds(window, settings)
    local minWidth = settings.minWidth or 700
    local minHeight = settings.minHeight or 400
    local maxWidth = settings.maxWidth or math.floor((UIParent:GetWidth() or 1920) * 0.95)
    local maxHeight = settings.maxHeight or math.floor((UIParent:GetHeight() or 1080) * 0.95)

    if window.SetResizeBounds then
        window:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    else
        window:SetMinResize(minWidth, minHeight)
        window:SetMaxResize(maxWidth, maxHeight)
    end
end

local function PinTopLeft(window)
    local left, top = window:GetLeft(), window:GetTop()
    if not left or not top then
        return
    end

    window:ClearAllPoints()
    window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end

local function AddResizeGrip(window, settings)
    if not settings.resizable or not window.SetResizable then
        return
    end

    window:SetResizable(true)
    ApplyResizeBounds(window, settings)

    local resizer = CreateFrame("Button", nil, window)
    resizer:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -2, 2)
    resizer:SetSize(RESIZER_SIZE, RESIZER_SIZE)
    resizer:SetNormalTexture(RESIZER_UP)
    resizer:SetPushedTexture(RESIZER_DOWN)
    resizer:SetHighlightTexture(RESIZER_HIGHLIGHT)
    resizer:SetFrameLevel(window:GetFrameLevel() + 5)
    resizer:SetScript("OnEnter", function()
        if SetCursor then SetCursor("Interface\\Cursor\\UI-Cursor-SizeRight") end
    end)
    resizer:SetScript("OnLeave", function()
        if SetCursor then SetCursor(nil) end
    end)
    resizer:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then
            return
        end

        local highlight = resizer:GetHighlightTexture()
        if highlight then highlight:Hide() end
        PinTopLeft(window)
        window.isResizing = true
        window:StartSizing("BOTTOMRIGHT")
    end)
    resizer:SetScript("OnMouseUp", function()
        local highlight = resizer:GetHighlightTexture()
        if highlight then highlight:Show() end
        window:StopMovingOrSizing()
        window.isResizing = false
        if SetCursor then SetCursor(nil) end
    end)

    window.ResizeGrip = resizer
end

---Creates the hidden window. Tab canvases go in its canvasContainer.
---@param settings table? Optional window settings for other Questie panels.
---@return Frame window
function QuestieOptionsWindow.Create(settings)
    settings = settings or {}
    local windowName = settings.name or WINDOW_NAME
    local window = CreateFrame("Frame", windowName, UIParent, "PortraitFrameTemplate")
    window:SetSize(settings.width or WINDOW_WIDTH, settings.height or math.floor(GetScreenHeight() * 0.7))
    window:SetPoint("CENTER")
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetFrameStrata("HIGH")
    window:Hide()
    window:SetTitle(settings.title or "Questie")
    window:EnableMouse(true)
    AddResizeGrip(window, settings)

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
        if window.isResizing then
            window:StopMovingOrSizing()
            window.isResizing = false
            if SetCursor then SetCursor(nil) end
        end
    end)

    window:SetPortraitTextureRaw(settings.portrait or "Interface\\AddOns\\Questie\\Icons\\questie_portrait.png", nil, nil, "TRILINEAR")
    local portrait = window.PortraitContainer.portrait
    if Questie.IsForever then
        if portrait then portrait:SetTexCoord(0.16, 0.86, 0.17, 0.87) end
        if window.Bg then window.Bg:SetColorTexture(30 / 255, 23 / 255, 18 / 255, 0.85) end
    else
        if portrait then portrait:SetTexCoord(0.21, 0.815, 0.21, 0.815) end
        if window.Bg then window.Bg:SetColorTexture(0.16, 0.145, 0.133, 0.85) end
    end
    QuestieOptionsUtils.DisableSnapping(portrait)

    window.canvasContainer = CreateFrame("Frame", nil, window)
    window.canvasContainer:SetPoint("TOPLEFT", window, "TOPLEFT", 10, -30)
    window.canvasContainer:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -10, 10)

    -- Lets the Escape key close the window
    tinsert(UISpecialFrames, windowName)

    return window
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
        sideTab:SetPoint("TOPLEFT", window, "TOPRIGHT", isForever and -1 or -2, -35)
    else
        sideTab:SetPoint("TOPLEFT", previousSideTab, "BOTTOMLEFT", 0, isForever and 0 or 10)
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
    icon:SetTexture(tabData.icon or 134400)
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

    local button = CreateFrame("Button", "$tabButton_" .. tabKey, sideTab)
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
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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
        onSelect(tabKey)
    end)

    return sideTab
end

---@param sideTab Frame
---@param isSelected boolean
function QuestieOptionsWindow.SetSideTabSelected(sideTab, isSelected)
    sideTab.Selected:SetShown(isSelected)
    sideTab.Icon:SetAlpha(isSelected and 1.0 or 0.65) -- Darkens the icons of inactive tabs
end

return QuestieOptionsWindow
