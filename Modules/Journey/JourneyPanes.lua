---The two boxes of a Journey Tab, a list and the details of what is selected in it, with a divider between them
---that can be dragged. They are as wide as each other until then, and a double-click on it puts it back there.
---@class JourneyPanes
local JourneyPanes = QuestieLoader:CreateModule("JourneyPanes")

---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

-- Of the width, until the divider is dragged
local DEFAULT_LIST_SHARE = 0.5
local MIN_LIST_WIDTH = 200
local MIN_DETAILS_WIDTH = 240
local DIVIDER_WIDTH = 2
-- Wider than the gap between the boxes, so that it is easy to grab
local DIVIDER_GRAB_WIDTH = 10
-- Space for the title of a box, which is drawn above it
local TITLE_HEIGHT = 22

---Where the divider was dragged to, saved for the character
---@class JourneyPanes.Sizes
---@field listShare number? Of the width, which the list takes as far as there is room for the details. Nil until it is dragged.

---@class JourneyPanes.Instance
---@field list Frame
---@field details Frame
---@field sizes JourneyPanes.Sizes

---@param canvas Frame
---@param title string
---@return Frame box
local function _CreateBox(canvas, title)
    local box = QuestieOptionsControls.Create(canvas, {type = "container", title = title}, MIN_LIST_WIDTH, 3)
    box:EnableMouse(false)
    return box
end

---@param canvas Frame
---@return number width Of the list and the details together
local function _GetSpace(canvas)
    return canvas:GetWidth() - DIVIDER_WIDTH
end

---@param panes JourneyPanes.Instance
---@param canvas Frame
---@param width number What the list should get, which it only does when both of them still have room
local function _SetListWidth(panes, canvas, width)
    panes.list:SetWidth(math.max(MIN_LIST_WIDTH, math.min(width, _GetSpace(canvas) - MIN_DETAILS_WIDTH)))
end

---@param panes JourneyPanes.Instance
---@param canvas Frame
local function _PlaceDivider(panes, canvas)
    _SetListWidth(panes, canvas, _GetSpace(canvas) * (panes.sizes.listShare or DEFAULT_LIST_SHARE))
end

---@param panes JourneyPanes.Instance
---@param canvas Frame
local function _CreateDivider(panes, canvas)
    local divider = CreateFrame("Button", nil, canvas)
    divider:SetPoint("TOP", panes.list, "TOPRIGHT", DIVIDER_WIDTH / 2, 0)
    divider:SetPoint("BOTTOM", panes.list, "BOTTOMRIGHT", DIVIDER_WIDTH / 2, 0)
    divider:SetWidth(DIVIDER_GRAB_WIDTH)
    divider:SetFrameLevel(canvas:GetFrameLevel() + 10)

    local line = divider:CreateTexture(nil, "HIGHLIGHT")
    line:SetPoint("TOP", divider, "TOP", 0, -2)
    line:SetPoint("BOTTOM", divider, "BOTTOM", 0, 2)
    line:SetWidth(2)
    line:SetColorTexture(1, 0.82, 0, 0.4)

    local function GetCursorX()
        return (GetCursorPosition()) / divider:GetEffectiveScale()
    end

    local function StopDragging()
        divider:SetScript("OnUpdate", nil)
    end

    divider:SetScript("OnMouseDown", function()
        local startX, startWidth = GetCursorX(), panes.list:GetWidth()
        divider:SetScript("OnUpdate", function()
            -- The mouse-up doesn't arrive when the button is released somewhere else
            if not IsMouseButtonDown("LeftButton") then
                StopDragging()
                return
            end
            _SetListWidth(panes, canvas, startWidth + GetCursorX() - startX)
            panes.sizes.listShare = panes.list:GetWidth() / _GetSpace(canvas)
        end)
    end)
    divider:SetScript("OnMouseUp", StopDragging)
    divider:SetScript("OnHide", StopDragging)
    divider:SetScript("OnDoubleClick", function()
        StopDragging()
        panes.sizes.listShare = nil
        _PlaceDivider(panes, canvas)
    end)
    divider:SetScript("OnEnter", function() SetCursor("UI_RESIZE_CURSOR") end)
    divider:SetScript("OnLeave", function() SetCursor(nil) end)
end

---@param canvas Frame
---@param listTitle string Shown above the list
---@param topInset number Space above the boxes and their titles
---@param sizes JourneyPanes.Sizes Where the divider was dragged to before. It is changed when it is dragged again.
---@return JourneyPanes.Instance
function JourneyPanes.Create(canvas, listTitle, topInset, sizes)
    ---@type JourneyPanes.Instance
    local panes = {sizes = sizes}

    local top = -topInset - (listTitle ~= "" and TITLE_HEIGHT or 0)
    -- At the sides, like the boxes in the settings. Their border is drawn a bit outside of them.
    local list = _CreateBox(canvas, listTitle)
    list:SetPoint("TOPLEFT", canvas, "TOPLEFT", 0, top)
    list:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", 0, 12)
    panes.list = list

    local details = _CreateBox(canvas, "")
    details:SetPoint("TOPLEFT", list, "TOPRIGHT", DIVIDER_WIDTH, 0)
    details:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", 0, 12)
    panes.details = details

    _CreateDivider(panes, canvas)
    canvas:HookScript("OnSizeChanged", function()
        _PlaceDivider(panes, canvas)
    end)
    _PlaceDivider(panes, canvas)

    return panes
end

return JourneyPanes
