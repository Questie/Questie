---Tabs like those of a browser, with a plus behind them. When there are more than fit, the long names are cut off first.
---@class JourneyTabBar
local JourneyTabBar = QuestieLoader:CreateModule("JourneyTabBar")

---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

-- Another tab is only added when each of them can be this wide. One with a short name can still be narrower.
local ROOM_PER_TAB = 84
local MAX_TAB_WIDTH = 190
local PLUS_TAB_WIDTH = 46
local TEXT_INSET, CLOSE_WIDTH = 14, 13
local PLUS_SIZE, CLOSE_SIZE = 14, 11
-- The text of the template is this far above its lower edge, see MinimalTabMixin:OnSelected
local TEXT_Y, SELECTED_TEXT_Y = 4, 6

-- The same on every supported client. Checked in UiTextureAtlasMember and in Blizzard's source (see AGENTS.md).
local PLUS_ATLAS = "bags-icon-addslots"
local CLOSE_TEXTURE = "Interface\\FriendsFrame\\ClearBroadcastIcon"

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

---@param bar Frame
---@param onAdd fun()
local function _CreatePlus(bar, onAdd)
    local plus = CreateFrame("Button", nil, bar, "MinimalTabTemplate")
    plus:SetWidth(PLUS_TAB_WIDTH)
    plus.Icon = plus:CreateTexture(nil, "OVERLAY")
    plus.Icon:SetSize(PLUS_SIZE, PLUS_SIZE)
    plus.Icon:SetAtlas(PLUS_ATLAS)
    plus:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        onAdd()
    end)
    bar.plus = plus
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

    local hasPlus = bar.isPlusSelected or JourneyTabBar.HasRoom(bar)
    local limit = _GetLimit(wantedWidths, bar:GetWidth() - (hasPlus and PLUS_TAB_WIDTH or 0))
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

    bar.plus:SetSelected(bar.isPlusSelected)
    bar.plus.Icon:SetPoint("BOTTOM", bar.plus, "BOTTOM", 0, bar.isPlusSelected and SELECTED_TEXT_Y - 2 or TEXT_Y - 2)
    bar.plus:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", x, 0)
    bar.plus:SetShown(hasPlus)
end

---@param parent Frame
---@param onAdd fun() The plus was clicked
---@return Frame bar Its tabs stand on its lower edge
function JourneyTabBar.Create(parent, onAdd)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetHeight(1)
    bar.tabs, bar.buttons = {}, {}
    _CreatePlus(bar, onAdd)
    bar:SetScript("OnSizeChanged", function() _Update(bar) end)
    return bar
end

---@param bar Frame
---@return boolean hasRoom For another tab
function JourneyTabBar.HasRoom(bar)
    return (#bar.tabs + 1) * ROOM_PER_TAB + PLUS_TAB_WIDTH <= bar:GetWidth()
end

---@param bar Frame
---@param tabs JourneyTabBar.Tab[]
---@param isPlusSelected boolean
function JourneyTabBar.SetTabs(bar, tabs, isPlusSelected)
    bar.tabs, bar.isPlusSelected = tabs, isPlusSelected
    _Update(bar)
end

return JourneyTabBar
