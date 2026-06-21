---@class TooltipLayout
local TooltipLayout = QuestieLoader:CreateModule("TooltipLayout")

-------------------------
--Import modules.
-------------------------
---@type WrappedText
local WrappedText = QuestieLoader:ImportModule("WrappedText")

local tinsert = table.insert

local MIN_TOOLTIP_TEXT_WIDTH = 375
local DEFAULT_DOUBLE_LINE_GAP = 38.4
local INDENT_TEXTURE_PATH = "Interface\\Minimap\\UI-bonusobjectiveblob-inside.blp"

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


---Creates an explicit tooltip row builder.
---@return TooltipLayoutRowBuilder rows Row builder passed to tooltip content modules.
function TooltipLayout:CreateRows()
    local rows = {}

    rows.AddLine = function(self, text, ...)
        _AppendTooltipLine(self, text, _PackTooltipArgs(...))
    end

    rows.AddDoubleLine = function(self, leftText, rightText, ...)
        _AppendTooltipDoubleLine(self, leftText, rightText, _PackTooltipArgs(...))
    end

    rows.AddDescription = function(self, text, prefix, ...)
        -- Keep combineTrailing disabled here. Combining can increase wrapped line width after measurement,
        -- which would require recursive tooltip reflow to calculate a stable width.
        _AppendTooltipDescription(self, text, prefix, false, _PackTooltipArgs(...))
    end

    return rows
end

-------------------------
-- Measurement.
-------------------------


---@type FontString?
local tooltipMeasurementFontString
---@type string?
local tooltipMeasurementDefaultFont
---@type number?
local tooltipMeasurementDefaultSize
---@type string?
local tooltipMeasurementDefaultFlags

---Returns a reusable hidden FontString for measuring rendered tooltip text.
---@return FontString fontString Hidden measurement FontString.
local function _GetTooltipMeasurementFontString()
    if not tooltipMeasurementFontString then
        tooltipMeasurementFontString = UIParent:CreateFontString("questieTooltipLayoutMeasureString", "ARTWORK", "GameTooltipText")
        tooltipMeasurementDefaultFont, tooltipMeasurementDefaultSize, tooltipMeasurementDefaultFlags = tooltipMeasurementFontString:GetFont()
        tooltipMeasurementFontString:SetWordWrap(false)
        tooltipMeasurementFontString:Hide()
    end

    return tooltipMeasurementFontString
end

---Copies the render font into the measurement FontString, with template-font fallback.
---@param fontString FontString Hidden measurement FontString.
---@param fontSource FontString? Tooltip FontString whose font should be matched.
---@return nil
local function _SetMeasurementFont(fontString, fontSource)
    local fontSourceType = type(fontSource)
    if (fontSource and (fontSourceType == "table" or fontSourceType == "userdata") and type(fontSource.GetFont) == "function") then
        local font, size, flags = fontSource:GetFont()
        if (font and size) then
            fontString:SetFont(font, size, flags)
            return
        end
    end

    if (tooltipMeasurementDefaultFont and tooltipMeasurementDefaultSize) then
        fontString:SetFont(tooltipMeasurementDefaultFont, tooltipMeasurementDefaultSize, tooltipMeasurementDefaultFlags)
    end
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

---Measures text using WoW's renderer so color and texture escape widths match runtime rendering.
---@param text string? Text to measure; nil is treated as empty.
---@param fontSource FontString? Render font source.
---@return number width Unbounded rendered width in UI units.
local function _MeasureTooltipText(text, fontSource)
    local fontString = _GetTooltipMeasurementFontString()
    _SetMeasurementFont(fontString, fontSource)
    fontString:SetText(text or "")

    return fontString:GetUnboundedStringWidth() or 0
end

---Creates a transparent texture prefix used for indentation in measured tooltip rows.
---@param width number Texture width in UI units.
---@return string prefix Transparent texture escape sequence.
---@return number width Texture width in UI units.
function TooltipLayout.CreateIndentUI(width)
    return "|T" .. INDENT_TEXTURE_PATH .. ":1:" .. width .. "|t", width
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
    return tooltipDoubleLineGapAvg
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
            width = math.max(width, _MeasureTooltipText(row.text, _GetTooltipFontString(tooltip, lineIndex, "left")))
        elseif (row.kind == "doubleLine") then
            local leftWidth = _MeasureTooltipText(row.leftText, _GetTooltipFontString(tooltip, lineIndex, "left"))
            local rightWidth = _MeasureTooltipText(row.rightText, _GetTooltipFontString(tooltip, lineIndex, "right"))
            width = math.max(width, leftWidth + rightWidth + _GetTooltipDoubleLineGap())
        end
        lineIndex = lineIndex + 1
    end

    return math.max(width, 1)
end

---Wraps description rows after stable tooltip width is known.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param rows TooltipLayoutRow[] Row model before description expansion.
---@return TooltipLayoutRow[] expandedRows Row model containing only renderable line/doubleLine rows.
local function _ExpandTooltipDescriptionRows(tooltip, rows)
    local expandedRows = {}
    local tooltipWidth = math.max(MIN_TOOLTIP_TEXT_WIDTH, _MeasureTooltipRows(tooltip, rows))
    local descriptionFontString = _GetTooltipFontString(tooltip, 2, "left") or _GetTooltipFontString(tooltip, 1, "left")

    for _, row in ipairs(rows) do
        if (row.kind == "description") then
            local prefixWidth = _MeasureTooltipText(row.prefix, descriptionFontString)
            local wrapWidth = math.max(tooltipWidth - prefixWidth, 1)
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

-------------------------
-- Rendering.
-------------------------

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

---Measures, expands, and renders tooltip rows exactly once.
---@param tooltip GameTooltip Tooltip being rebuilt.
---@param rows TooltipLayoutRow[] Row model before description expansion.
---@return nil
function TooltipLayout:Render(tooltip, rows)
    -- Skip measurement and description expansion for common tooltips that only contain fixed rows.
    for _, row in ipairs(rows) do
        if (row.kind == "description") then
            _RenderTooltipRows(tooltip, _ExpandTooltipDescriptionRows(tooltip, rows))
            return
        end
    end

    -- No rows require expansion, so render directly without measuring.
    _RenderTooltipRows(tooltip, rows)
end

return TooltipLayout
