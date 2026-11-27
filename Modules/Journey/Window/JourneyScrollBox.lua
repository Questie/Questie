---A list of rows that can be scrolled. Only the rows on screen have frames, and they are reused.
---@class JourneyScrollBox
local JourneyScrollBox = QuestieLoader:CreateModule("JourneyScrollBox")

local SCROLL_BAR_WIDTH = 22
-- Leaves a gap between its arrows, which are wider than the bar, and the border
local SCROLL_BAR_INSET = 12
local INSET = 4

---@param parent Frame The list fills it
---@param view table Creates the rows
---@param isWiderWithoutBar boolean? Uses the space of the scroll bar while there is none. Not for text that wraps, because
---narrower text can be taller, and then need the bar that makes it narrower.
---@return Frame scrollBox
function JourneyScrollBox.Create(parent, view, isWiderWithoutBar)
    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -SCROLL_BAR_INSET, -8)
    scrollBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -SCROLL_BAR_INSET, 4)

    local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetPoint("TOPLEFT", parent, "TOPLEFT", INSET, -INSET)
    scrollBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -SCROLL_BAR_WIDTH, INSET)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
    -- Hides the bar when everything fits. Works the same on every supported client. Checked in Blizzard's source (see AGENTS.md).
    if isWiderWithoutBar then
        local topLeft = CreateAnchor("TOPLEFT", parent, "TOPLEFT", INSET, -INSET)
        ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar,
            {topLeft, CreateAnchor("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -SCROLL_BAR_WIDTH, INSET)},
            {topLeft, CreateAnchor("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -INSET, INSET)})
    else
        ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar)
    end
    return scrollBox
end

return JourneyScrollBox
