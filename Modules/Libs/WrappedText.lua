---@class WrappedText
local WrappedText = QuestieLoader:CreateModule("WrappedText")

-------------------------
--Import modules.
-------------------------
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")
---@type FontMeasure
local FontMeasure = QuestieLoader:ImportModule("FontMeasure")

local math_max = math.max
local tinsert = table.insert

-- The original frame which we use to fetch the data required
--                           Classic                          Wotlk Classic
local textWrapFrameObject = _G["QuestLogObjectivesText"] or _G["QuestInfoObjectivesText"]

-------------------------
-- Measurement device.
-------------------------

---@type FontMeasurer?
local measurer

---Returns the lazily-created measurer that emulates the quest log objective FontString.
---@return FontMeasurer measurer
local function _GetMeasurer()
    if (not measurer) then
        measurer = FontMeasure.Create({
            name = "questieObjectiveTextString",
            template = "QuestFont",
            wordWrap = true,
            defaultFontSource = textWrapFrameObject, --Chinese? "Fonts\\ARKai_T.ttf"
            onCreate = function(fontString)
                fontString:SetWidth((textWrapFrameObject and textWrapFrameObject:GetWidth()) or 275) --QuestLogObjectivesText default width = 275
                fontString:SetHeight(0)
                fontString:SetPoint("LEFT")
                fontString:SetJustifyH("LEFT")
                fontString:SetVertexColor(1, 1, 1, 1) -- Keep the measuring FontString non-transparent for accurate rendering metrics.
            end,
        })
    end

    return measurer
end

-------------------------
-- Numeric token policy (pure).
-------------------------

---@type table<string, boolean>
local FULLWIDTH_DIGITS = {
    ["０"] = true,
    ["１"] = true,
    ["２"] = true,
    ["３"] = true,
    ["４"] = true,
    ["５"] = true,
    ["６"] = true,
    ["７"] = true,
    ["８"] = true,
    ["９"] = true,
}

---@type table<string, boolean>
local NUMERIC_SEPARATORS = {
    [","] = true,
    ["."] = true,
    ["，"] = true,
    ["．"] = true,
}

---@param character string? Single UTF-8 character.
---@return boolean isDigit True for ASCII or full-width decimal digits.
local function _IsNumericCharacter(character)
    return character ~= nil and (string.match(character, "^%d$") ~= nil or FULLWIDTH_DIGITS[character] == true)
end

---Returns true for digits and numeric separators only when they are part of one number.
---@param line string UTF-8 text being wrapped.
---@param index number UTF-8 character index to inspect.
---@param lineLength number UTF-8 character length of `line`.
---@return boolean isNumericTokenCharacter
local function _IsNumericTokenCharacter(line, index, lineLength)
    if (index < 1 or index > lineLength) then
        return false
    end

    local character = utf8.sub(line, index, index)
    if (_IsNumericCharacter(character)) then
        return true
    elseif (character == "%" or character == "％") then
        return _IsNumericCharacter(utf8.sub(line, index - 1, index - 1))
    elseif (NUMERIC_SEPARATORS[character]) then
        return _IsNumericCharacter(utf8.sub(line, index - 1, index - 1)) and _IsNumericCharacter(utf8.sub(line, index + 1, index + 1))
    end

    return false
end

---Extends a break so numeric tokens stay on one line.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@param breakIndex number Proposed current-line end index.
---@param nextStartIndex number Proposed next-line start index.
---@return number breakIndex Updated end index.
---@return number nextStartIndex Updated next-line start index.
local function _ExtendBreakOverNumber(line, lineLength, breakIndex, nextStartIndex)
    if (breakIndex < 1 or nextStartIndex > lineLength or not _IsNumericTokenCharacter(line, breakIndex, lineLength)) then
        return breakIndex, nextStartIndex
    end

    while (nextStartIndex <= lineLength and _IsNumericTokenCharacter(line, nextStartIndex, lineLength)) do
        breakIndex = nextStartIndex
        nextStartIndex = nextStartIndex + 1
    end

    return breakIndex, nextStartIndex
end

-------------------------
-- Break finding.
-------------------------

---@param line string UTF-8 text segment.
---@return boolean hasSpace True when `line` contains an ASCII space.
local function _HasSpace(line)
    return string.find(line, " ", 1, true) ~= nil
end

---Prefers a space boundary over a mid-word cut. Spaces stay the strongest break for Latin text.
---@param lastSpaceIndex number? Last UTF-8 space index before overflow.
---@param fallbackBreakIndex number Last fitting UTF-8 character index when no space exists.
---@return number breakIndex Chosen line-end index (inclusive).
---@return number nextStartIndex Chosen next-line start index.
---@return boolean brokeAtSpace True when the break landed on a space boundary.
local function _PreferSpaceBreak(lastSpaceIndex, fallbackBreakIndex)
    if (lastSpaceIndex) then
        return lastSpaceIndex, lastSpaceIndex + 1, true
    end

    return fallbackBreakIndex, fallbackBreakIndex + 1, false
end

---Finds a break by measuring substring width.
---Used for CJK/no-space strings when WoW's row-span API is unavailable or unreliable.
---@param textMeasurer FontMeasurer Measurer with `line` already set.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@return number breakIndex UTF-8 index where the current line should end.
---@return number nextStartIndex UTF-8 index where the next line should start.
---@return boolean brokeAtSpace True when the break landed on a space boundary.
local function _FindBreakByWidth(textMeasurer, line, lineLength)
    local lastSpaceIndex

    for endIndex = 1, lineLength do
        if (utf8.sub(line, endIndex, endIndex) == " ") then
            lastSpaceIndex = endIndex
        end

        textMeasurer:SetText(utf8.sub(line, 1, endIndex))
        if (textMeasurer:Overflows()) then
            return _PreferSpaceBreak(lastSpaceIndex, math_max(endIndex - 1, 1))
        end
    end

    return lineLength, lineLength + 1, false
end

---Runs the width-based break, then restores `line` as the measurer's text.
---Downstream trailing-line checks read row spans of the full segment, so the text must be intact.
---@param textMeasurer FontMeasurer Measurer with `line` set.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@return number breakIndex
---@return number nextStartIndex
---@return boolean brokeAtSpace
local function _FindBreakByWidthRestoring(textMeasurer, line, lineLength)
    local breakIndex, nextStartIndex, brokeAtSpace = _FindBreakByWidth(textMeasurer, line, lineLength)
    textMeasurer:SetText(line)
    return breakIndex, nextStartIndex, brokeAtSpace
end

---Finds a break using WoW row spans, falling back to measured width for CJK edge cases.
---@param textMeasurer FontMeasurer Measurer with `line` already set.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@return number breakIndex UTF-8 index where the current line should end.
---@return number nextStartIndex UTF-8 index where the next line should start.
---@return boolean brokeAtSpace True when the break landed on a space boundary.
local function _FindBreak(textMeasurer, line, lineLength)
    -- Some clients/fonts do not wrap spaceless CJK text, so row spans report a single row. Measure instead.
    if (not _HasSpace(line) and textMeasurer:Overflows()) then
        return _FindBreakByWidthRestoring(textMeasurer, line, lineLength)
    end

    local lastSpaceIndex

    -- Walk until this span would wrap onto a second visual row.
    for endIndex = 1, lineLength do
        if (utf8.sub(line, endIndex, endIndex) == " ") then
            lastSpaceIndex = endIndex
        end

        local rowSpan = textMeasurer:RowSpan(1, endIndex)
        if (not rowSpan) then
            return _FindBreakByWidthRestoring(textMeasurer, line, lineLength)
        elseif (#rowSpan > 1) then
            return _PreferSpaceBreak(lastSpaceIndex, math_max(endIndex - 1, 1))
        end
    end

    -- The whole segment stayed on one visual row; only break when width still overflows.
    if (textMeasurer:Overflows()) then
        return _FindBreakByWidthRestoring(textMeasurer, line, lineLength)
    end

    return lineLength, lineLength + 1, false
end

-------------------------
-- Trailing-line combining.
-------------------------

---Counts how many visual rows the trailing text occupies after a candidate break.
---@param textMeasurer FontMeasurer Measurer with `line` set.
---@param line string Current remaining text segment.
---@param lastLine string Candidate trailing text.
---@param nextStartIndex number UTF-8 index where the trailing text starts.
---@param lineLength number UTF-8 character length of `line`.
---@return number remainingRows Visual row count, approximated by width when row spans are unavailable.
local function _CountTrailingRows(textMeasurer, line, lastLine, nextStartIndex, lineLength)
    local rowSpan = textMeasurer:RowSpan(nextStartIndex, lineLength)
    if (rowSpan) then
        return #rowSpan
    end

    textMeasurer:SetText(lastLine)
    local remainingRows = textMeasurer:Overflows() and 2 or 1
    textMeasurer:SetText(line)

    return remainingRows
end

---Determines whether an orphan word or CJK glyph should be pulled into the previous line.
---@param textMeasurer FontMeasurer Measurer with `line` set.
---@param line string Current remaining text segment.
---@param nextStartIndex number UTF-8 index where the trailing text starts.
---@param lineLength number UTF-8 character length of `line`.
---@param brokeAtSpace boolean Whether the candidate break landed on a space boundary.
---@return boolean shouldCombine True when combining improves trailing-line readability.
local function _ShouldCombineTrailing(textMeasurer, line, nextStartIndex, lineLength, brokeAtSpace)
    if (nextStartIndex > lineLength) then
        return false
    end

    local lastLine = utf8.sub(line, nextStartIndex, lineLength)
    if (_CountTrailingRows(textMeasurer, line, lastLine, nextStartIndex, lineLength) ~= 1) then
        return false
    end

    local isSingleWord = brokeAtSpace and not _HasSpace(lastLine)
    local isSingleGlyph = utf8.strlen(lastLine) == 1 and string.len(lastLine) > 1
    return isSingleWord or isSingleGlyph
end

-------------------------
-- Public API.
-------------------------

---Emulates the wrapping of a quest description.
---@param line string @The line to wrap
---@param prefix string @The prefix to add to the line
---@param combineTrailing boolean? @If the last line is only one word/glyph, combine it with previous? TRUE=COMBINE, FALSE=NOT COMBINE, default: false
---@param desiredWidth number? @Set the desired width to wrap, default: 275
---@param fontSource FontString? @Optional FontString to copy the measuring font from
---@return string[] lines @Wrapped lines with `prefix` already applied
function WrappedText:TextWrap(line, prefix, combineTrailing, desiredWidth, fontSource)
    local textMeasurer = _GetMeasurer()

    if (textMeasurer:IsShown()) then
        Questie:Error("TextWrap already running... Please report this on GitHub or Discord.")
    end

    --Set Defaults
    if (combineTrailing == nil) then
        combineTrailing = false
    end

    -- We have to show the FontString or the metric functions won't work, but it stays invisible (alpha 0).
    textMeasurer:MatchFont(fontSource)
    textMeasurer:SetWidth(desiredWidth or (textWrapFrameObject and textWrapFrameObject:GetWidth()) or 275) --QuestLogObjectivesText default width = 275
    textMeasurer:Show()

    local lineLength = utf8.strlen(line)

    -- Fast path: text that already fits needs no wrapping or token policy.
    textMeasurer:SetText(line)
    if (not textMeasurer:Overflows()) then
        textMeasurer:Hide()
        return { prefix .. line }
    end

    local lines = {}
    local startIndex = 1
    while (startIndex <= lineLength) do
        local remainingLine = utf8.sub(line, startIndex, lineLength)
        local remainingLength = utf8.strlen(remainingLine)

        -- Recalculate per segment. Moving breaks over numeric tokens changes row geometry.
        textMeasurer:SetText(remainingLine)
        if (not textMeasurer:Overflows()) then
            tinsert(lines, prefix .. remainingLine)
            break
        end

        local breakIndex, nextStartIndex, brokeAtSpace = _FindBreak(textMeasurer, remainingLine, remainingLength)
        breakIndex, nextStartIndex = _ExtendBreakOverNumber(remainingLine, remainingLength, breakIndex, nextStartIndex)

        -- Pull a lone trailing word or glyph up into this line when requested.
        if (combineTrailing and _ShouldCombineTrailing(textMeasurer, remainingLine, nextStartIndex, remainingLength, brokeAtSpace)) then
            tinsert(lines, prefix .. remainingLine)
            break
        end

        tinsert(lines, prefix .. utf8.sub(remainingLine, 1, breakIndex))
        startIndex = startIndex + nextStartIndex - 1
    end

    textMeasurer:Hide()
    return lines
end

return WrappedText
