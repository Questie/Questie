---The two boxes of a Journey Tab, a list and the details of what is selected in it, with a divider between them
---that can be dragged. A double-click on it puts it back.
---@class JourneyPanes
local JourneyPanes = QuestieLoader:CreateModule("JourneyPanes")

---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

local DEFAULT_LIST_WIDTH = 415
local MIN_LIST_WIDTH = 200
local MIN_DETAILS_WIDTH = 240
local DIVIDER_WIDTH = 14
-- Space for the title of a box, which is drawn above it
local TITLE_HEIGHT = 22
-- The border of a box is drawn this far outside of it
local BORDER = 5

---@class JourneyPanes.Instance
---@field list Frame
---@field details Frame
---@field listWidth number What the user wants. The list is narrower while the window is too small for it.

---@param canvas Frame
---@param title string
---@return Frame box
local function _CreateBox(canvas, title)
    local box = QuestieOptionsControls.Create(canvas, {type = "container", title = title}, MIN_LIST_WIDTH, 3)
    box:EnableMouse(false)
    return box
end

---@param panes JourneyPanes.Instance
---@param canvas Frame
local function _PlaceDivider(panes, canvas)
    local maxWidth = canvas:GetWidth() - DIVIDER_WIDTH - MIN_DETAILS_WIDTH
    panes.list:SetWidth(math.max(MIN_LIST_WIDTH, math.min(panes.listWidth, maxWidth)))
end

---@param panes JourneyPanes.Instance
---@param canvas Frame
local function _CreateDivider(panes, canvas)
    local divider = CreateFrame("Button", nil, canvas)
    divider:SetPoint("TOPLEFT", panes.list, "TOPRIGHT", BORDER / 2, 0)
    divider:SetPoint("BOTTOMRIGHT", panes.details, "BOTTOMLEFT", -BORDER / 2, 0)
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
            panes.listWidth = startWidth + GetCursorX() - startX
            _PlaceDivider(panes, canvas)
        end)
    end)
    divider:SetScript("OnMouseUp", StopDragging)
    divider:SetScript("OnHide", StopDragging)
    divider:SetScript("OnDoubleClick", function()
        StopDragging()
        panes.listWidth = DEFAULT_LIST_WIDTH
        _PlaceDivider(panes, canvas)
    end)
    divider:SetScript("OnEnter", function() SetCursor("UI_RESIZE_CURSOR") end)
    divider:SetScript("OnLeave", function() SetCursor(nil) end)
end

---@param canvas Frame
---@param listTitle string Shown above the list
---@param topInset number Space above the boxes and their titles
---@return JourneyPanes.Instance
function JourneyPanes.Create(canvas, listTitle, topInset)
    ---@type JourneyPanes.Instance
    local panes = {listWidth = DEFAULT_LIST_WIDTH}

    local top = -topInset - (listTitle ~= "" and TITLE_HEIGHT or 0)
    local list = _CreateBox(canvas, listTitle)
    list:SetPoint("TOPLEFT", canvas, "TOPLEFT", 12, top)
    list:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", 12, 12)
    panes.list = list

    local details = _CreateBox(canvas, "")
    details:SetPoint("TOPLEFT", list, "TOPRIGHT", DIVIDER_WIDTH, 0)
    details:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -12, 12)
    panes.details = details

    _CreateDivider(panes, canvas)
    canvas:HookScript("OnSizeChanged", function()
        _PlaceDivider(panes, canvas)
    end)
    _PlaceDivider(panes, canvas)

    return panes
end

return JourneyPanes
