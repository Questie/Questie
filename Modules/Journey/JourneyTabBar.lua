---Tabs like those of a browser, with a tab behind them to find something new: a magnifier for the search, and a plus for the
---overview. When there are more tabs than fit, the long names are cut off first.
---@class JourneyTabBar
local JourneyTabBar = QuestieLoader:CreateModule("JourneyTabBar")

---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

-- Another tab is only added when each of them can be this wide. One with a short name can still be narrower.
local ROOM_PER_TAB = 84
local MAX_TAB_WIDTH = 190
local FIND_TAB_WIDTH = 84
local TEXT_INSET, CLOSE_WIDTH = 14, 13
local SEARCH_SIZE, PLUS_SIZE, CLOSE_SIZE = 16, 14, 11
-- The text of the template is this far above its lower edge, see MinimalTabMixin:OnSelected
local TEXT_Y, SELECTED_TEXT_Y = 4, 6
-- The glass of the magnifier is above the middle of its picture. The plus is as high, so they are on one line.
local ICON_MIDDLE_Y = 10
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
---@field isSelected boolean
---@field onSelect fun()
---@field onClose fun()? Nil for a tab that can't be closed

---@param button Button
local function _CreateClose(button)
    local close = CreateFrame("Button", nil, button)
    close:SetSize(CLOSE_SIZE + 4, CLOSE_SIZE + 4)
    close:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -8, 2)
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

---@param bar Frame
---@return Button
local function _CreateButton(bar)
    local button = CreateFrame("Button", nil, bar, "MinimalTabTemplate")
    button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp")
    button.Text:SetWordWrap(false)
    button.Text:SetJustifyH("LEFT")
    _CreateClose(button)
    -- The template's own script would also deselect the tab
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
    button:HookScript("OnEnter", function()
        if button.Text:IsTruncated() then
            GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
            GameTooltip:SetText(button.tab.name, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    button:HookScript("OnLeave", function() GameTooltip:Hide() end)
    QuestieOptionsUtils.HideTooltipOnHide(button)
    return button
end

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
    local tab = CreateFrame("Button", nil, bar, "MinimalTabTemplate")
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
    line:SetSize(1, PLUS_SIZE)
    tab.Line = line
    bar.findTab = tab
end

---@param tab JourneyTabBar.Tab
---@return number width Of what is next to the text
local function _GetSpace(tab)
    return 2 * TEXT_INSET + (tab.onClose and CLOSE_WIDTH or 0)
end

---@param tab JourneyTabBar.Tab
---@param button Button
---@return number width For the whole name, as far as that is possible
local function _GetWantedWidth(tab, button)
    button.Text:SetWidth(0)
    button.Text:SetText(tab.name)
    return math.min(MAX_TAB_WIDTH, math.ceil(button.Text:GetStringWidth()) + 1 + _GetSpace(tab))
end

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
        button:SetSelected(tab.isSelected)
        wantedWidths[index] = _GetWantedWidth(tab, button)
    end

    local limit = _GetLimit(wantedWidths, bar:GetWidth() - FIND_TAB_WIDTH)
    local x = 0
    for index, tab in ipairs(bar.tabs) do
        local button = bar.buttons[index]
        local width = math.min(wantedWidths[index], limit)
        button:SetWidth(width)
        button:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", x, 0)
        button.Text:SetWidth(math.max(1, width - _GetSpace(tab)))
        button.Text:ClearAllPoints() -- The template puts it in the middle
        button.Text:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", TEXT_INSET, tab.isSelected and SELECTED_TEXT_Y or TEXT_Y)
        button.Close:SetShown(tab.onClose ~= nil)
        button:Show()
        x = x + width
    end
    for index = #bar.tabs + 1, #bar.buttons do
        bar.buttons[index]:Hide()
    end

    -- It is always there, as it is the way to the search
    local findTab, shownFind = bar.findTab, bar.shownFind
    findTab:SetSelected(shownFind ~= nil)
    findTab:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", x, 0)
    local middleY = ICON_MIDDLE_Y + (shownFind and SELECTED_TEXT_Y - TEXT_Y or 0)
    findTab.Search.Icon:SetPoint("CENTER", findTab.Search, "BOTTOM", 0, middleY)
    findTab.Plus.Icon:SetPoint("CENTER", findTab.Plus, "BOTTOM", 0, middleY + GLASS_ABOVE_MIDDLE)
    findTab.Line:SetPoint("CENTER", findTab, "BOTTOM", 0, middleY + GLASS_ABOVE_MIDDLE)
    findTab.Search.Icon:SetAlpha(shownFind == "search" and 1 or DIM_ICON_ALPHA)
    findTab.Plus.Icon:SetAlpha(shownFind == "overview" and 1 or DIM_ICON_ALPHA)
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
    return (#bar.tabs + 1) * ROOM_PER_TAB + FIND_TAB_WIDTH <= bar:GetWidth()
end

---@param bar Frame
---@param tabs JourneyTabBar.Tab[]
---@param shownFind "search"|"overview"|nil What the find tab leads to, while it is shown instead of a tab
function JourneyTabBar.SetTabs(bar, tabs, shownFind)
    bar.tabs, bar.shownFind = tabs, shownFind
    _Update(bar)
end

return JourneyTabBar
