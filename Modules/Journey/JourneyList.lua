---A list of rows that can be clicked. They look like the category list in Blizzard's settings.
---
---A row only gets its content when it is on screen, so the list can have tens of thousands of them.
---@class JourneyList
local JourneyList = QuestieLoader:CreateModule("JourneyList")

---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyScrollBox
local JourneyScrollBox = QuestieLoader:ImportModule("JourneyScrollBox")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

local ROW_HEIGHT = 20
local TOGGLE_SIZE = 18
local ICON_CENTER = 11
local INDENT = 14
local NOTE_INSET, NOTE_GAP = 8, 10
-- Takes up the same space on every row, so the text of rows with and without an icon or toggle lines up
local GUTTER_WIDTH = 22

-- The same on every supported client. Checked in Blizzard's source (see AGENTS.md).
local SELECTED_ATLAS = "Options_List_Active"
local HOVER_ATLAS = "Options_List_Hover"
-- Those of Blizzard's settings, which only Forever has (checked in UiTextureAtlasMember of every client's build)
local EXPANDED_ATLAS, COLLAPSED_ATLAS = "common-button-dropdown-open", "common-button-dropdown-closed"
-- Those of the tracker, which every supported client has (checked in the files of each build)
local EXPANDED_TEXTURE = "Interface\\Buttons\\UI-MinusButton-Up"
local COLLAPSED_TEXTURE = "Interface\\Buttons\\UI-PlusButton-Up"

---@class JourneyList.Content
---@field text string|number
---@field icon JourneyIcon.Icon?
---@field isSelected boolean
---@field isCollapsed boolean? Nil for a row that can't be collapsed
---@field depth number? How far the row is indented
---@field note string? At the right edge, while the whole text fits next to it

---@param row Button
local function _UpdateBackground(row)
    row.Background:SetShown(row.isSelected or row.isHovered)
    row.Background:SetAtlas(row.isSelected and SELECTED_ATLAS or HOVER_ATLAS)
end

---@param row Button
---@param onClick fun(index: number)
local function _CreateRow(row, onClick)
    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    row.Background = background

    local toggle = row:CreateTexture(nil, "ARTWORK")
    toggle:SetSize(TOGGLE_SIZE, TOGGLE_SIZE)
    row.Toggle = toggle

    row.Icon = JourneyIcon.Create(row)

    local note = row:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    note:SetPoint("RIGHT", row, "RIGHT", -NOTE_INSET, 0)
    note:SetJustifyH("RIGHT")
    note:SetWordWrap(false)
    row.Note = note

    local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    row.Label = label

    row:SetScript("OnClick", function()
        onClick(row:GetElementData())
    end)
    -- Otherwise the second click of a double-click collapses what the first one expanded
    row:SetScript("OnDoubleClick", function() end)
    row:SetScript("OnEnter", function()
        row.isHovered = true
        _UpdateBackground(row)
        if label:IsTruncated() or row.isNoteHidden then
            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetText(label:GetText(), 1, 1, 1, 1, true)
            if note:GetText() then
                GameTooltip:AddLine(note:GetText(), 0.7, 0.7, 0.7, true)
            end
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function()
        row.isHovered = false
        _UpdateBackground(row)
        GameTooltip:Hide()
    end)
    QuestieOptionsUtils.HideTooltipOnHide(row)
end

---@param toggle Texture
---@param isCollapsed boolean
local function _SetToggle(toggle, isCollapsed)
    if C_Texture.GetAtlasInfo(EXPANDED_ATLAS) then
        toggle:SetAtlas(isCollapsed and COLLAPSED_ATLAS or EXPANDED_ATLAS)
    else
        toggle:SetTexture(isCollapsed and COLLAPSED_TEXTURE or EXPANDED_TEXTURE)
    end
end

---@param row Button It may have shown something else before
---@param content JourneyList.Content
---@param width number Of the row
local function _UpdateRow(row, content, width)
    local canBeCollapsed = content.isCollapsed ~= nil
    local depth = content.depth or 0
    -- What isn't a header is indented like the one it belongs to, so its icon is below the toggle
    local indent = (canBeCollapsed and depth or math.max(depth - 1, 0)) * INDENT

    row.Toggle:SetPoint("LEFT", row, "LEFT", indent + 1, 0)
    row.Toggle:SetShown(canBeCollapsed)
    _SetToggle(row.Toggle, content.isCollapsed == true)

    row.Icon:SetPoint("CENTER", row, "LEFT", indent + ICON_CENTER, 0)
    JourneyIcon.Set(row.Icon, content.icon)

    row.Label:SetFontObject(canBeCollapsed and "GameFontNormal" or "GameFontHighlight")
    row.Label:SetText(content.text)
    row.Note:SetFontObject(canBeCollapsed and "GameFontNormalSmall" or "GameFontDisableSmall")
    row.Note:SetText(content.note)

    -- The name comes first. The note is only shown while all of the name fits next to it, and is in the tooltip otherwise.
    local labelX = indent + GUTTER_WIDTH
    local noteSpace = content.note and row.Note:GetUnboundedStringWidth() + NOTE_GAP or 0
    local showsNote = noteSpace > 0 and row.Label:GetUnboundedStringWidth() + noteSpace <= width - labelX - NOTE_INSET
    row.Note:SetShown(showsNote)
    row.isNoteHidden = content.note ~= nil and not showsNote
    row.Label:SetPoint("LEFT", row, "LEFT", labelX, 0)
    row.Label:SetPoint("RIGHT", row, "RIGHT", -NOTE_INSET - (showsNote and noteSpace or 0), 0)

    row.isSelected = content.isSelected
    row.isHovered = row:IsMouseMotionFocus() -- Unlike IsMouseOver not when something covers the row
    _UpdateBackground(row)
end

---@param parent Frame The list fills it
---@param getContent fun(index: number): JourneyList.Content
---@param onClick fun(index: number)
---@return Frame list
function JourneyList.Create(parent, getContent, onClick)
    local scrollBox
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(ROW_HEIGHT)
    view:SetElementInitializer("Button", function(row, index)
        if not row.Label then
            _CreateRow(row, onClick)
        end
        _UpdateRow(row, getContent(index), scrollBox:GetWidth())
    end)
    scrollBox = JourneyScrollBox.Create(parent, view, true)

    -- Whether the notes fit next to the names depends on the width
    local shownWidth = scrollBox:GetWidth()
    scrollBox:HookScript("OnSizeChanged", function(_, width)
        if width ~= shownWidth then
            shownWidth = width
            scrollBox:ReinitializeFrames()
        end
    end)
    return scrollBox
end

---Shows other rows.
---@param list Frame
---@param count number
---@param keepsScrollPosition boolean
function JourneyList.SetCount(list, count, keepsScrollPosition)
    list:SetDataProvider(
        CreateIndexRangeDataProvider(count),
        keepsScrollPosition and ScrollBoxConstants.RetainScrollPosition or ScrollBoxConstants.DiscardScrollPosition
    )
end

---Brings the same rows up to date.
---@param list Frame
function JourneyList.Update(list)
    list:ReinitializeFrames()
end

---@param list Frame
---@param index number
function JourneyList.ScrollTo(list, index)
    list:ScrollToElementDataIndex(index, ScrollBoxConstants.AlignNearest)
end

return JourneyList
