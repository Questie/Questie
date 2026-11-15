---Arranges settings controls on a canvas.
---
---Rows are filled left to right until the next control does not fit. A finished row is then aligned, because the
---tallest control is only known once wrapped text, including longer translations, has been measured.
---@class QuestieOptionsLayout
local QuestieOptionsLayout = QuestieLoader:CreateModule("QuestieOptionsLayout")

---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local HORIZONTAL_GAP = 10
local VERTICAL_GAP = 10

local NAMED_WIDTHS = {
    half = 0.5,
    full = 1.0,
    third = 0.32,
    quarter = 0.25,
}

---@param value string|table|nil A string, or a table of l10n format arguments
---@return string?
local function _Translate(value)
    if value == nil or value == "" then
        return value
    end
    if type(value) == "table" then
        return l10n(unpack(value))
    end
    return l10n(value)
end

---@param itemsTable table<string, table>
---@return table[] items Sorted by their order field
local function _GetSortedItems(itemsTable)
    local sorted = {}
    for _, data in pairs(itemsTable) do
        table.insert(sorted, data)
    end
    table.sort(sorted, function(a, b)
        return (a.order or 999) < (b.order or 999)
    end)
    return sorted
end

---Applies defaults and translations, so controls never have to handle missing fields.
---@param rawItem table An entry of a tab's items table
---@return table item
local function _NormalizeItem(rawItem)
    local item = {
        order = rawItem.order or 0,                                -- the index used to sort control and tab hierarchy, required for all items
        type = rawItem.type or "",                                 -- see the list of control types in QuestieOptionsEngine
        title = _Translate(rawItem.title),                         -- user-readable text label
        description = _Translate(rawItem.description),             -- description of the control, appears below the label in small white text
        tooltip = _Translate(rawItem.tooltip),                     -- text shown in tooltip when hovering over control (longer description)
        get = rawItem.get,                                         -- function used to determine what state the control should show (get value of variable)
        set = rawItem.set,                                         -- function used to set the target variable when the control is used
        value = rawItem.value,                                     -- radio button value for this control
        width = rawItem.width or 0.5,                              -- screen width this control occupies where 1 = 100%; also accepts the names in NAMED_WIDTHS
        newline = rawItem.newline or false,                        -- if true, force this element to be at the start of a new line
        visible = rawItem.visible == nil or rawItem.visible,       -- whether this control is shown; only checked when the tab is defined, mainly to filter options by client expansion level
        enabled = rawItem.enabled == nil or rawItem.enabled,       -- whether this control is enabled or disabled; this is re-evaluated upon any settings change
        min = rawItem.min or 0,                                    -- the minimum value for a slider (left)
        max = rawItem.max or 10,                                   -- the maximum value for a slider (right)
        step = rawItem.step or 0.1,                                -- the size of the 'steps' along a slider
        showValue = rawItem.showValue == nil or rawItem.showValue, -- whether or not to show the raw value beneath a slider
        isPercent = rawItem.isPercent or false,                    -- if true, displays slider values as a percentage (1.0 -> 100%)
        minLabel = _Translate(rawItem.minLabel),                   -- label shown on the left side of a slider; if nil, show min value
        maxLabel = _Translate(rawItem.maxLabel),                   -- label shown on the right side of a slider; if nil, show max value
        options = rawItem.options,                                 -- a list of entries within a dropdown
        sortOrder = rawItem.sortOrder,                             -- a sorted table of keys matching item.options that can be used as a sort order
        items = rawItem.items,                                     -- a nested table of controls within a container
        titleAlign = rawItem.titleAlign,                           -- title text alignment
        titleSize = rawItem.titleSize,                             -- title text font size
        titleFormat = rawItem.titleFormat,                         -- function used to format title text (for instance, to colorize after translating raw string)
        descriptionAlign = rawItem.descriptionAlign or "LEFT",     -- description text alignment
        descriptionSize = rawItem.descriptionSize,                 -- description text font size
        func = rawItem.func,                                       -- function called when control is pressed (buttons only)
        align = rawItem.align or "LEFT",                           -- control alignment within its spacer/wrapper (only noticeable with buttons)
        btnLabel = _Translate(rawItem.btnLabel),                   -- text label placed on a button (may differ from title used in tooltips)
        fonts = rawItem.fonts,                                     -- list of fonts to select from
        hasOpacity = rawItem.hasOpacity or false,                  -- whether a colorPicker should show an alpha selector alongside RGB
        textBoxCharLimit = rawItem.textBoxCharLimit,               -- max number of characters for a text box
    }

    if item.titleAlign == nil then
        item.titleAlign = item.type == "divider" and "CENTER" or "LEFT"
    end

    item.width = NAMED_WIDTHS[item.width] or item.width
    if item.type == "container" or item.type == "divider" then
        item.width = 1.0
    end

    return item
end

---Centers controls shorter than the tallest one of their row.
---@param rowControls QuestieOptionsControl[]
---@param rowHeight number
---@param rowY number
local function _AlignRowVertically(rowControls, rowHeight, rowY)
    if #rowControls < 2 then
        return
    end

    for _, control in ipairs(rowControls) do
        local height = control:GetHeight()
        if height < rowHeight then
            -- Keep the X coordinate so horizontal flow stays intact
            local point, relativeTo, relativePoint, x = control:GetPoint(1)
            control:SetPoint(point, relativeTo, relativePoint, x, rowY - (rowHeight - height) / 2)
        end
    end
end

---Creates and places the visible controls of a canvas or container.
---Must run in a coroutine when onControlCreated yields, which it may do for any control.
---@param parentFrame Frame
---@param rawItems table<string, table> Item definitions by key
---@param maxWidth number
---@param level number Nesting depth, starting at 1 for the canvas itself
---@param onControlCreated fun(control: QuestieOptionsControl)
---@return number height Height used by the placed controls
function QuestieOptionsLayout.Build(parentFrame, rawItems, maxWidth, level, onControlCreated)
    local cursorX = 0
    local cursorY = level > 1 and -10 or 0 -- Containers leave room for their art at the top
    local rowHeight = 0
    local rowControls = {}

    for _, rawItem in ipairs(_GetSortedItems(rawItems)) do
        local item = _NormalizeItem(rawItem)

        if item.visible ~= false then
            local isFullWidth = item.width == 1.0

            -- A control sharing its row leaves room for half of the gap to its neighbor
            local controlWidth = maxWidth * item.width
            if item.width < 1.0 then
                controlWidth = controlWidth - HORIZONTAL_GAP / 2
            end

            local needsNewRow = cursorX + controlWidth > maxWidth
                or item.type == "divider"
                or item.type == "container"
                or item.newline == true
                or (isFullWidth and cursorX > 0)

            if needsNewRow and #rowControls > 0 then
                _AlignRowVertically(rowControls, rowHeight, cursorY)
                wipe(rowControls)
                cursorY = cursorY - rowHeight - VERTICAL_GAP
                cursorX = 0
                rowHeight = 0
            end

            -- Don't overlap the title of a container, which is drawn above it
            if item.type == "container" and item.title then
                cursorY = cursorY - 24
            end

            -- Only the canvas itself is indented, containers are already inside of it
            local x = level == 1 and cursorX + QuestieOptionsControls.ROOT_INDENT or cursorX

            local control = QuestieOptionsControls.Create(parentFrame, item, controlWidth, level)
            control:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, cursorY)
            table.insert(rowControls, control)
            onControlCreated(control)

            if item.type == "container" and item.items then
                local contentHeight = QuestieOptionsLayout.Build(control.contentArea, item.items, maxWidth, level + 1, onControlCreated)
                control:SetHeight(contentHeight + VERTICAL_GAP)
            end

            if control:GetHeight() > rowHeight then
                rowHeight = control:GetHeight()
            end

            -- Full-width controls finish their row right away
            if isFullWidth then
                cursorY = cursorY - rowHeight - VERTICAL_GAP
                cursorX = 0
                rowHeight = 0
                wipe(rowControls)
            else
                cursorX = cursorX + controlWidth + HORIZONTAL_GAP
            end
        end
    end

    _AlignRowVertically(rowControls, rowHeight, cursorY)

    return math.abs(cursorY - rowHeight)
end

return QuestieOptionsLayout
