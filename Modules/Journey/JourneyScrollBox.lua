---A list of rows that can be scrolled. Only the rows on screen have frames, and they are reused.
---@class JourneyScrollBox
local JourneyScrollBox = QuestieLoader:CreateModule("JourneyScrollBox")

local SCROLL_BAR_WIDTH = 22

---@param parent Frame The list fills it
---@param view table Creates the rows
---@return Frame scrollBox
function JourneyScrollBox.Create(parent, view)
    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -8)
    scrollBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 4)

    local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4)
    scrollBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -SCROLL_BAR_WIDTH, 4)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar) -- Hides the bar when everything fits
    return scrollBox
end

return JourneyScrollBox
