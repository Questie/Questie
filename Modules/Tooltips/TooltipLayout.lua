---@class TooltipLayout
local TooltipLayout = QuestieLoader:CreateModule("TooltipLayout")

-------------------------
--Import modules.
-------------------------
---@type WrappedText
local WrappedText = QuestieLoader:ImportModule("WrappedText")
---@type FontMeasure
local FontMeasure = QuestieLoader:ImportModule("FontMeasure")

local tinsert = table.insert
local math_max = math.max

local MIN_TOOLTIP_TEXT_WIDTH = 375
local DEFAULT_DOUBLE_LINE_GAP = 38.4

-------------------------
-- Row model.
-------------------------

---@alias TooltipLayoutRowKind "line"|"doubleLine"|"description"

---@class TooltipLayoutPackedArgs
---@field n number Number of packed arguments; needed because colors may contain nil in future calls.

---@class TooltipLayoutLineRow
---@field kind "line"
---@field text string
---@field args TooltipLayoutPackedArgs

---@class TooltipLayoutDoubleLineRow
---@field kind "doubleLine"
---@field leftText string
---@field rightText string
---@field args TooltipLayoutPackedArgs

---@class TooltipLayoutDescriptionRow
---@field kind "description"
---@field text string
---@field prefix string
---@field combineTrailing boolean
---@field args TooltipLayoutPackedArgs

---@alias TooltipLayoutRow TooltipLayoutLineRow|TooltipLayoutDoubleLineRow|TooltipLayoutDescriptionRow

---@class TooltipLayoutRowBuilder
---@field rows TooltipLayoutRow[] Accumulated rows, consumed by TooltipLayout:Render.
---@field AddLine fun(self: TooltipLayoutRowBuilder, text: string, ...: any): nil
---@field AddDoubleLine fun(self: TooltipLayoutRowBuilder, leftText: string, rightText: string, ...: any): nil
---@field AddDescription fun(self: TooltipLayoutRowBuilder, text: string, prefix: string, ...: any): nil

---Packs tooltip varargs without losing trailing nil values.
---@param ... any Tooltip AddLine/AddDoubleLine arguments.
---@return TooltipLayoutPackedArgs args Packed argument table.
local function _PackTooltipArgs(...)
    return {n = select("#", ...), ...}
end

---@param rows TooltipLayoutRow[] Mutable row model.
---@param text string Left text rendered by GameTooltip:AddLine.
---@param args TooltipLayoutPackedArgs Packed AddLine arguments.
---@return nil
local function _AppendTooltipLine(rows, text, args)
    tinsert(rows, {kind = "line", text = text, args = args})
end

---@param rows TooltipLayoutRow[] Mutable row model.
---@param leftText string Left text rendered by GameTooltip:AddDoubleLine.
---@param rightText string Right text rendered by GameTooltip:AddDoubleLine.
---@param args TooltipLayoutPackedArgs Packed AddDoubleLine arguments.
---@return nil
local function _AppendTooltipDoubleLine(rows, leftText, rightText, args)
    tinsert(rows, {kind = "doubleLine", leftText = leftText, rightText = rightText, args = args})
end

---@param rows TooltipLayoutRow[] Mutable row model.
---@param text string Raw description text to wrap after final tooltip width is known.
---@param prefix string Prefix added to each wrapped line.
---@param combineTrailing boolean Whether to pull orphan trailing words/glyphs up.
---@param args TooltipLayoutPackedArgs Packed AddLine arguments for rendered wrapped lines.
---@return nil
local function _AppendTooltipDescription(rows, text, prefix, combineTrailing, args)
    tinsert(rows, {kind = "description", text = text, prefix = prefix, combineTrailing = combineTrailing, args = args})
end

---Creates an explicit tooltip row builder. Rows are buffered so descriptions can be wrapped after
---the fixed rows fix the tooltip width, avoiding a width feedback loop.
---@return TooltipLayoutRowBuilder builder Row builder passed to tooltip content modules.
function TooltipLayout:CreateRows()
    ---@type TooltipLayoutRowBuilder
    local builder = {rows = {}}

    function builder:AddLine(text, ...)
        _AppendTooltipLine(self.rows, text, _PackTooltipArgs(...))
    end

    function builder:AddDoubleLine(leftText, rightText, ...)
        _AppendTooltipDoubleLine(self.rows, leftText, rightText, _PackTooltipArgs(...))
    end

    function builder:AddDescription(text, prefix, ...)
        -- Keep combineTrailing disabled here. Combining can increase wrapped line width after measurement,
        -- which would require recursive tooltip reflow to calculate a stable width.
        _AppendTooltipDescription(self.rows, text, prefix, false, _PackTooltipArgs(...))
    end

    return builder
end

-------------------------
-- Measurement.
-------------------------

---@type FontMeasurer?
local ruler

---Returns the lazily-created ruler used to measure rendered tooltip text width.
---@return FontMeasurer ruler
local function _GetRuler()
    if (not ruler) then
        ruler = FontMeasure.Create({
            name = "questieTooltipLayoutMeasureString",
            template = "GameTooltipText",
            wordWrap = false,
        })
    end

    return ruler
end

---Measures text using WoW's renderer so color and texture escape widths match runtime rendering.
---@param text string? Text to measure; nil is treated as empty.
---@param fontSource FontString? Render font source.
---@return number width Unbounded rendered width in UI units.
local function _MeasureTooltipText(text, fontSource)
    return _GetRuler():MeasureWidth(text, fontSource)
end

---Finds the FontString Blizzard will use for a tooltip row.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param lineIndex number 1-based rendered row index.
---@param side "left"|"right" Tooltip side to measure.
---@return FontString? fontString Render FontString, if the template has created one.
local function _GetTooltipFontString(tooltip, lineIndex, side)
    local tooltipName = tooltip:GetName()
    if not tooltipName then
        return nil
    end

    -- Get the FontString of the given line and side.
    -- fallback to line 2 and 1 in case the tooltip template does not have enough lines.
    local textSide = side == "right" and "TextRight" or "TextLeft"
    local fontString = _G[tooltipName .. textSide .. lineIndex]
        or _G[tooltipName .. textSide .. "2"]
        or _G[tooltipName .. textSide .. "1"]

    -- If the right side is missing, fallback to the left side.
    if (not fontString and side == "right") then
        fontString = _G[tooltipName .. "TextLeft" .. lineIndex]
            or _G[tooltipName .. "TextLeft2"]
            or _G[tooltipName .. "TextLeft1"]
    end

    return fontString
end

---@type number?
local tooltipDoubleLineGapAvg
---@type GameTooltip?
local tooltipDoubleLineGapTooltip

---Measures Blizzard's minimum AddDoubleLine gap using a hidden GameTooltip.
---@return number gap Minimum space between left and right double-line text.
local function _GetTooltipDoubleLineGap()
    if tooltipDoubleLineGapAvg then
        return tooltipDoubleLineGapAvg
    end

    local tooltipName = "QuestieTooltipLayoutGapMeasureTooltip"
    tooltipDoubleLineGapTooltip = tooltipDoubleLineGapTooltip or CreateFrame("GameTooltip", tooltipName, UIParent, "GameTooltipTemplate")
    tooltipDoubleLineGapTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltipDoubleLineGapTooltip:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -10000, 10000)
    tooltipDoubleLineGapTooltip:SetAlpha(0)
    tooltipDoubleLineGapTooltip:ClearLines()
    tooltipDoubleLineGapTooltip:AddDoubleLine("L", "R", 1, 1, 1, 1, 1, 1)
    tooltipDoubleLineGapTooltip:AddDoubleLine("L", "R", 1, 1, 1, 1, 1, 1)
    tooltipDoubleLineGapTooltip:Show()

    -- On a normal GameTooltip the first row has a different font than the second row, so we measure both and average them to get a more accurate gap estimate.
    local gap1 = DEFAULT_DOUBLE_LINE_GAP
    local leftText = _G[tooltipName .. "TextLeft1"]
    local rightText = _G[tooltipName .. "TextRight1"]
    if (leftText and rightText and leftText:GetRight() and rightText:GetLeft()) then
        gap1 = rightText:GetLeft() - leftText:GetRight()
    end

    local gap2 = DEFAULT_DOUBLE_LINE_GAP
    leftText = _G[tooltipName .. "TextLeft2"]
    rightText = _G[tooltipName .. "TextRight2"]
    if (leftText and rightText and leftText:GetRight() and rightText:GetLeft()) then
        gap2 = rightText:GetLeft() - leftText:GetRight()
    end

    tooltipDoubleLineGapTooltip:Hide()
    tooltipDoubleLineGapTooltip:ClearLines()

    tooltipDoubleLineGapAvg = (gap1 + gap2) / 2
    return tooltipDoubleLineGapAvg or DEFAULT_DOUBLE_LINE_GAP
end

---Measures non-description rows to choose the tooltip text width before wrapping descriptions.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param rows TooltipLayoutRow[] Row model before description expansion.
---@return number width Inner text width in UI units.
local function _MeasureTooltipRows(tooltip, rows)
    local width = 0
    local lineIndex = 1

    for _, row in ipairs(rows) do
        if (row.kind == "line") then
            width = math_max(width, _MeasureTooltipText(row.text, _GetTooltipFontString(tooltip, lineIndex, "left")))
        elseif (row.kind == "doubleLine") then
            local leftWidth = _MeasureTooltipText(row.leftText, _GetTooltipFontString(tooltip, lineIndex, "left"))
            local rightWidth = _MeasureTooltipText(row.rightText, _GetTooltipFontString(tooltip, lineIndex, "right"))
            width = math_max(width, leftWidth + rightWidth + _GetTooltipDoubleLineGap())
        end
        lineIndex = lineIndex + 1
    end

    return math_max(width, 1)
end

-------------------------
-- Expansion & rendering.
-------------------------

---Wraps description rows once the stable tooltip text width is known.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param rows TooltipLayoutRow[] Row model before description expansion.
---@param textWidth number Inner text width descriptions must wrap within.
---@return TooltipLayoutRow[] expandedRows Row model containing only renderable line/doubleLine rows.
local function _ExpandDescriptionRows(tooltip, rows, textWidth)
    local expandedRows = {}
    local descriptionFontString = _GetTooltipFontString(tooltip, 2, "left") or _GetTooltipFontString(tooltip, 1, "left")

    for _, row in ipairs(rows) do
        if (row.kind == "description") then
            local prefixWidth = _MeasureTooltipText(row.prefix, descriptionFontString)
            local wrapWidth = math_max(textWidth - prefixWidth, 1)
            local lines = WrappedText:TextWrap(row.text, row.prefix, row.combineTrailing, wrapWidth, descriptionFontString)

            for _, line in ipairs(lines) do
                _AppendTooltipLine(expandedRows, line, row.args)
            end
        else
            tinsert(expandedRows, row)
        end
    end

    return expandedRows
end

---Renders the completed row model into the GameTooltip exactly once.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param rows TooltipLayoutRow[] Row model after description expansion.
---@return nil
local function _RenderTooltipRows(tooltip, rows)
    for _, row in ipairs(rows) do
        if (row.kind == "line") then
            tooltip:AddLine(row.text, unpack(row.args, 1, row.args.n))
        elseif (row.kind == "doubleLine") then
            tooltip:AddDoubleLine(row.leftText, row.rightText, unpack(row.args, 1, row.args.n))
        end
    end
end

---Measures rows, expands descriptions to the resulting width, then renders exactly once.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param rowBuilder TooltipLayoutRowBuilder Row builder produced by TooltipLayout:CreateRows.
---@return nil
function TooltipLayout:Render(tooltip, rowBuilder)
    local rows = rowBuilder.rows
    local textWidth = math_max(MIN_TOOLTIP_TEXT_WIDTH, _MeasureTooltipRows(tooltip, rows))
    _RenderTooltipRows(tooltip, _ExpandDescriptionRows(tooltip, rows, textWidth))
end

return TooltipLayout
