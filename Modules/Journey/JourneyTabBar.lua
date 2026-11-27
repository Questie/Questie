---Tabs like those of a browser, with a tab behind them to find something new: a magnifier for the search, and a plus for the
---overview. A tab shows a picture of what it is about, and below its name what kind of place that is. When there are more tabs
---than fit, the long names are cut off first.
---@class JourneyTabBar
local JourneyTabBar = QuestieLoader:CreateModule("JourneyTabBar")

---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyOverviewRows
local JourneyOverviewRows = QuestieLoader:ImportModule("JourneyOverviewRows")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

-- Another tab is only added when each of them can be this wide. One with a short name can still be narrower.
local ROOM_PER_TAB = 120
local MAX_TAB_WIDTH = 200
local FIND_TAB_WIDTH = 88
-- Between tabs, so they don't run into each other
local TAB_GAP = 2
-- The selected tab is taller, like in Blizzard's template the art is from
local TAB_HEIGHT, SELECTED_TAB_HEIGHT = 34, 37
local ART_EDGE_WIDTH = 7
local PICTURE_SIZE, PICTURE_X, PICTURE_GAP = 22, 9, 8
local TEXT_X = PICTURE_X + PICTURE_SIZE + PICTURE_GAP
local RIGHT_INSET, CLOSE_WIDTH = 9, 15
-- The name is above the middle and the label under it, this far apart
local LINE_GAP = 3
local SEARCH_SIZE, PLUS_SIZE, CLOSE_SIZE, HERE_SIZE = 20, 16, 11, 14
-- The glass of the magnifier is above the middle of its picture. The plus is as high, so they are on one line.
local GLASS_ABOVE_MIDDLE = 2
-- An icon of the find tab is bright while what it leads to is shown, and dim otherwise
local DIM_ICON_ALPHA = 0.75

-- The same on every supported client. Checked in UiTextureAtlasMember and in Blizzard's source (see AGENTS.md).
local PLUS_ATLAS = "bags-icon-addslots"
local CLOSE_TEXTURE = "Interface\\FriendsFrame\\ClearBroadcastIcon"
-- The gold magnifier of the Who list, common-icon-search, is only in Forever. This white one is in every supported client, so
-- it is colored like that one. Checked in UiTextureAtlasMember of every client's build.
local SEARCH_ATLAS = "common-search-magnifyingglass"
local GOLD = {1, 0.82, 0}

---@class JourneyTabBar.Tab
---@field name string
---@field picture JourneyOverviewRows.Picture
---@field isHere boolean Whether the player is there
---@field label string? What kind of place it is, below the name
---@field isSelected boolean
---@field onSelect fun()
---@field onClose fun()? Nil for a tab that can't be closed

-------------------------
-- Art
-------------------------

---A tab without anything on it. The art is the one of MinimalTabTemplate, but as tall as the tab.
---@param bar Frame
---@return Button
local function _CreateTabFrame(bar)
    local tab = CreateFrame("Button", nil, bar)
    tab.Left = tab:CreateTexture(nil, "BACKGROUND")
    tab.Left:SetPoint("BOTTOMLEFT")
    tab.Right = tab:CreateTexture(nil, "BACKGROUND")
    tab.Right:SetPoint("BOTTOMRIGHT")
    tab.Middle = tab:CreateTexture(nil, "BACKGROUND")
    tab.Middle:SetPoint("TOPLEFT", tab.Left, "TOPRIGHT")
    tab.Middle:SetPoint("BOTTOMRIGHT", tab.Right, "BOTTOMLEFT")
    return tab
end

---@param tab Button
---@param isSelected boolean
---@return number middle How high the middle of what is on the tab is
local function _SetArt(tab, isSelected)
    local prefix = isSelected and "Options_Tab_Active_" or "Options_Tab_"
    local height = isSelected and SELECTED_TAB_HEIGHT or TAB_HEIGHT
    tab:SetHeight(height)
    tab.Left:SetAtlas(prefix .. "Left")
    tab.Left:SetSize(ART_EDGE_WIDTH, height)
    tab.Right:SetAtlas(prefix .. "Right")
    tab.Right:SetSize(ART_EDGE_WIDTH, height)
    tab.Middle:SetAtlas(prefix .. "Middle")
    -- The selected one also moves up what is on it, like the template
    return TAB_HEIGHT / 2 + (isSelected and 2 or 0)
end

-------------------------
-- Tabs
-------------------------

---@param button Button
local function _CreateClose(button)
    local close = CreateFrame("Button", nil, button)
    close:SetSize(CLOSE_SIZE + 4, CLOSE_SIZE + 4)
    local texture = close:CreateTexture(nil, "OVERLAY")
    texture:SetPoint("CENTER")
    texture:SetSize(CLOSE_SIZE, CLOSE_SIZE)
    texture:SetTexture(CLOSE_TEXTURE)
    texture:SetAlpha(0.5)
    close:SetScript("OnEnter", function() texture:SetAlpha(1) end)
    close:SetScript("OnLeave", function() texture:SetAlpha(0.5) end)
    close:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        button.tab.onClose()
    end)
    button.Close = close
end

---@param button Button
local function _UpdateFont(button)
    button.Text:SetFontObject((button.tab.isSelected or button.isHovered) and "GameFontHighlight" or "GameFontNormal")
end

---@param bar Frame
---@return Button
local function _CreateButton(bar)
    local button = _CreateTabFrame(bar)
    button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp")

    -- Black behind it, like the pictures of the tiles of the overview
    button.Frame = button:CreateTexture(nil, "BORDER")
    button.Frame:SetColorTexture(0, 0, 0, 0.8)
    button.Frame:SetSize(PICTURE_SIZE + 2, PICTURE_SIZE + 2)
    button.Picture = button:CreateTexture(nil, "ARTWORK")
    button.Picture:SetPoint("CENTER", button.Frame, "CENTER")
    button.Here = button:CreateTexture(nil, "OVERLAY")
    button.Here:SetTexture(JourneyIcon.ARROW)
    button.Here:SetTexCoord(9 / 32, 23 / 32, 9 / 32, 23 / 32)
    button.Here:SetSize(HERE_SIZE, HERE_SIZE)
    button.Here:SetPoint("CENTER", button.Frame, "BOTTOMRIGHT", -2, 2)

    button.Text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    button.Text:SetWordWrap(false)
    button.Text:SetJustifyH("LEFT")
    button.Label = button:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    button.Label:SetWordWrap(false)
    button.Label:SetJustifyH("LEFT")
    _CreateClose(button)

    button:SetScript("OnClick", function(_, mouseButton)
        local isClosing = mouseButton == "MiddleButton"
        if isClosing and not button.tab.onClose then
            return
        end
        GameTooltip:Hide()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        if isClosing then
            button.tab.onClose()
        else
            button.tab.onSelect()
        end
    end)
    button:SetScript("OnEnter", function()
        button.isHovered = true
        _UpdateFont(button)
        if button.Text:IsTruncated() then
            GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
            GameTooltip:SetText(button.tab.name, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        button.isHovered = false
        _UpdateFont(button)
        GameTooltip:Hide()
    end)
    QuestieOptionsUtils.HideTooltipOnHide(button)
    return button
end

---@param tab JourneyTabBar.Tab
---@return number width Right of the name
local function _GetRightSpace(tab)
    return RIGHT_INSET + (tab.onClose and CLOSE_WIDTH or 0)
end

---@param tab JourneyTabBar.Tab
---@param button Button
---@return number width For the whole name and label, as far as that is possible
local function _GetWantedWidth(tab, button)
    button.Text:SetWidth(0)
    button.Text:SetText(tab.name)
    button.Label:SetWidth(0)
    button.Label:SetText(tab.label or "")
    local nameWidth = math.ceil(button.Text:GetStringWidth()) + 1 + _GetRightSpace(tab)
    local labelWidth = math.ceil(button.Label:GetStringWidth()) + 1 + RIGHT_INSET
    return math.min(MAX_TAB_WIDTH, TEXT_X + math.max(nameWidth, labelWidth))
end

---@param button Button
---@param tab JourneyTabBar.Tab
---@param width number
local function _ShowTab(button, tab, width)
    local middle = _SetArt(button, tab.isSelected)
    button.Frame:SetPoint("CENTER", button, "BOTTOMLEFT", PICTURE_X + PICTURE_SIZE / 2, middle)
    JourneyOverviewRows.SetPicture(button.Picture, tab.picture, PICTURE_SIZE)
    button.Frame:SetShown(type(tab.picture) ~= "table")
    button.Here:SetShown(tab.isHere)

    -- The name is in the middle when there is no label below it
    local hasLabel = (tab.label or "") ~= ""
    local nameY = hasLabel and middle + LINE_GAP + 4 or middle
    _UpdateFont(button)
    button.Text:ClearAllPoints()
    button.Text:SetPoint("LEFT", button, "BOTTOMLEFT", TEXT_X, nameY)
    button.Text:SetWidth(math.max(1, width - TEXT_X - _GetRightSpace(tab)))
    button.Close:SetShown(tab.onClose ~= nil)
    button.Close:SetPoint("CENTER", button, "BOTTOMRIGHT", -RIGHT_INSET - CLOSE_WIDTH / 2 + 3, nameY)

    button.Label:SetShown(hasLabel)
    button.Label:SetText(tab.label or "")
    button.Label:SetPoint("TOPLEFT", button, "BOTTOMLEFT", TEXT_X, middle - LINE_GAP + 2)
    button.Label:SetWidth(math.max(1, width - TEXT_X - RIGHT_INSET))
end

-------------------------
-- Find tab
-------------------------

---One half of the find tab.
---@param tab Button
---@param point string Of the tab, where the half is
---@param onClick fun()
---@return Button half
local function _CreateHalf(tab, point, onClick)
    local half = CreateFrame("Button", nil, tab)
    half:SetPoint("TOP" .. point, tab, "TOP" .. point, 0, 0)
    half:SetPoint("BOTTOM" .. point, tab, "BOTTOM" .. point, 0, 0)
    half:SetWidth(FIND_TAB_WIDTH / 2)
    half.Icon = half:CreateTexture(nil, "OVERLAY")
    half:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        onClick()
    end)
    return half
end

---@param bar Frame
---@param onSearch fun(itemLink: string?)
---@param onAdd fun()
local function _CreateFindTab(bar, onSearch, onAdd)
    local tab = _CreateTabFrame(bar)
    tab:SetWidth(FIND_TAB_WIDTH)
    tab:EnableMouse(false) -- Its halves are clicked

    tab.Search = _CreateHalf(tab, "LEFT", function() onSearch() end)
    tab.Search.Icon:SetSize(SEARCH_SIZE, SEARCH_SIZE)
    tab.Search.Icon:SetAtlas(SEARCH_ATLAS)
    tab.Search.Icon:SetVertexColor(GOLD[1], GOLD[2], GOLD[3])
    -- An item dropped on it is searched for
    tab.Search:SetScript("OnReceiveDrag", function()
        local cursorType, _, itemLink = GetCursorInfo()
        if cursorType == "item" then
            ClearCursor()
            onSearch(itemLink)
        end
    end)

    tab.Plus = _CreateHalf(tab, "RIGHT", onAdd)
    tab.Plus.Icon:SetSize(PLUS_SIZE, PLUS_SIZE)
    tab.Plus.Icon:SetAtlas(PLUS_ATLAS)

    local line = tab:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(0.6, 0.5, 0.3, 0.6)
    line:SetSize(1, PLUS_SIZE + 2)
    tab.Line = line
    bar.findTab = tab
end

---@param bar Frame
---@param x number Where it starts
local function _ShowFindTab(bar, x)
    local findTab, shownFind = bar.findTab, bar.shownFind
    local middle = _SetArt(findTab, shownFind ~= nil)
    findTab:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", x, 0)
    findTab.Search.Icon:SetPoint("CENTER", findTab.Search, "BOTTOM", 0, middle)
    findTab.Plus.Icon:SetPoint("CENTER", findTab.Plus, "BOTTOM", 0, middle + GLASS_ABOVE_MIDDLE)
    findTab.Line:SetPoint("CENTER", findTab, "BOTTOM", 0, middle + GLASS_ABOVE_MIDDLE)
    findTab.Search.Icon:SetAlpha(shownFind == "search" and 1 or DIM_ICON_ALPHA)
    findTab.Plus.Icon:SetAlpha(shownFind == "overview" and 1 or DIM_ICON_ALPHA)
end

-------------------------
-- Bar
-------------------------

---@param wantedWidths number[]
---@param available number
---@return number limit The tabs that want to be wider than this are only as wide
local function _GetLimit(wantedWidths, available)
    local sorted = {}
    for index, width in ipairs(wantedWidths) do
        sorted[index] = width
    end
    table.sort(sorted)
    for index, width in ipairs(sorted) do
        local share = available / (#sorted - index + 1)
        if width > share then
            return math.floor(share)
        end
        available = available - width
    end
    return MAX_TAB_WIDTH
end

---@param bar Frame
local function _Update(bar)
    local wantedWidths = {}
    for index, tab in ipairs(bar.tabs) do
        local button = bar.buttons[index] or _CreateButton(bar)
        bar.buttons[index], button.tab = button, tab
        wantedWidths[index] = _GetWantedWidth(tab, button)
    end

    local limit = _GetLimit(wantedWidths, bar:GetWidth() - FIND_TAB_WIDTH - #bar.tabs * TAB_GAP)
    local x = 0
    for index, tab in ipairs(bar.tabs) do
        local button = bar.buttons[index]
        local width = math.min(wantedWidths[index], limit)
        button:SetWidth(width)
        button:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", x, 0)
        _ShowTab(button, tab, width)
        button:Show()
        x = x + width + TAB_GAP
    end
    for index = #bar.tabs + 1, #bar.buttons do
        bar.buttons[index]:Hide()
    end

    -- It is always there, as it is the way to the search
    _ShowFindTab(bar, x)
end

---@param parent Frame
---@param onSearch fun(itemLink: string?) The magnifier was clicked, or an item dropped on it
---@param onAdd fun() The plus was clicked
---@return Frame bar Its tabs stand on its lower edge
function JourneyTabBar.Create(parent, onSearch, onAdd)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetHeight(1)
    bar.tabs, bar.buttons = {}, {}
    _CreateFindTab(bar, onSearch, onAdd)
    bar:SetScript("OnSizeChanged", function() _Update(bar) end)
    return bar
end

---@param bar Frame
---@return boolean hasRoom For another tab
function JourneyTabBar.HasRoom(bar)
    return (#bar.tabs + 1) * (ROOM_PER_TAB + TAB_GAP) + FIND_TAB_WIDTH <= bar:GetWidth()
end

---@param bar Frame
---@param tabs JourneyTabBar.Tab[]
---@param shownFind "search"|"overview"|nil What the find tab leads to, while it is shown instead of a tab
function JourneyTabBar.SetTabs(bar, tabs, shownFind)
    bar.tabs, bar.shownFind = tabs, shownFind
    _Update(bar)
end

return JourneyTabBar
