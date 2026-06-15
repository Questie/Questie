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
local tconcat = table.concat

local DEFAULT_WIDTH = 275 -- QuestLogObjectivesText default width

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
                fontString:SetWidth((textWrapFrameObject and textWrapFrameObject:GetWidth()) or DEFAULT_WIDTH)
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
-- Character helpers (pure).
-------------------------

---@param chars string[] Decoded UTF-8 characters.
---@param from number Inclusive start index.
---@param to number Inclusive end index.
---@return string text Joined substring; empty when the range is empty.
local function _Slice(chars, from, to)
    return tconcat(chars, "", from, to)
end

---@param chars string[] Decoded UTF-8 characters.
---@param from number Inclusive start index.
---@param to number Inclusive end index.
---@return boolean hasSpace True when an ASCII space exists in the range.
local function _HasSpaceIn(chars, from, to)
    for index = from, to do
        if (chars[index] == " ") then
            return true
        end
    end

    return false
end

---@param chars string[] Decoded UTF-8 characters.
---@param from number Inclusive start index.
---@param to number Inclusive end index.
---@return number? lastSpaceIndex Index of the last ASCII space in the range, or nil.
local function _LastSpaceIn(chars, from, to)
    for index = to, from, -1 do
        if (chars[index] == " ") then
            return index
        end
    end

    return nil
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

---Returns true for digits and numeric separators, but only when part of one number.
---Look-behind/ahead is clamped to the current segment [from, to] so a number can never
---be reconstructed across a break that already happened.
---@param chars string[] Decoded UTF-8 characters.
---@param index number Character index to inspect.
---@param from number Inclusive segment start.
---@param to number Inclusive segment end.
---@return boolean isNumericTokenCharacter
local function _IsNumericTokenCharacter(chars, index, from, to)
    if (index < from or index > to) then
        return false
    end

    local character = chars[index]
    if (_IsNumericCharacter(character)) then
        return true
    elseif (character == "%" or character == "％") then
        return index - 1 >= from and _IsNumericCharacter(chars[index - 1])
    elseif (NUMERIC_SEPARATORS[character]) then
        return index - 1 >= from and index + 1 <= to
            and _IsNumericCharacter(chars[index - 1]) and _IsNumericCharacter(chars[index + 1])
    end

    return false
end

---Extends a break so numeric tokens stay on one line.
---@param chars string[] Decoded UTF-8 characters.
---@param from number Inclusive segment start.
---@param to number Inclusive segment end.
---@param breakIndex number Proposed current-line end index.
---@param nextStartIndex number Proposed next-line start index.
---@return number breakIndex Updated end index.
---@return number nextStartIndex Updated next-line start index.
local function _ExtendBreakOverNumber(chars, from, to, breakIndex, nextStartIndex)
    if (breakIndex < from or nextStartIndex > to or not _IsNumericTokenCharacter(chars, breakIndex, from, to)) then
        return breakIndex, nextStartIndex
    end

    while (nextStartIndex <= to and _IsNumericTokenCharacter(chars, nextStartIndex, from, to)) do
        breakIndex = nextStartIndex
        nextStartIndex = nextStartIndex + 1
    end

    return breakIndex, nextStartIndex
end

-------------------------
-- Break finding.
-------------------------

---Finds the first character index where the segment chars[from..#chars] no longer fits one
---visual row. Prefers WoW's own word wrapping (row spans) when the segment has spaces, and falls
---back to character-width measurement for CJK/no-space text or when row spans are unavailable.
---
---This is the only function that touches the measurer's text, and it sets what it needs on every
---call, so callers never depend on the measurer holding a particular string.
---@param textMeasurer FontMeasurer Measuring device.
---@param chars string[] Decoded UTF-8 characters of the full line.
---@param from number Inclusive start index of the segment to inspect.
---@return number? overflowIndex First index that overflows one row, or nil when the segment fits.
local function _FirstOverflowIndex(textMeasurer, chars, from)
    local charCount = #chars
    if (from > charCount) then
        return nil
    end

    textMeasurer:SetText(_Slice(chars, from, charCount))
    if (not textMeasurer:Overflows()) then
        return nil
    end

    -- Prefer the renderer's own word wrapping when spaces and row spans are available.
    -- If row spans are missing, or never report a wrap (some clients do not wrap), fall through to width.
    if (_HasSpaceIn(chars, from, charCount)) then
        for offset = 1, charCount - from + 1 do
            local rowSpan = textMeasurer:RowSpan(1, offset)
            if (not rowSpan) then
                break
            elseif (#rowSpan > 1) then
                return from + offset - 1
            end
        end
    end

    -- Width fallback: first character whose prefix exceeds the wrap width.
    for index = from, charCount do
        textMeasurer:SetText(_Slice(chars, from, index))
        if (textMeasurer:Overflows()) then
            return index
        end
    end

    return charCount
end

---Chooses a line break at or before an overflow boundary, preferring a space.
---@param chars string[] Decoded UTF-8 characters.
---@param from number Inclusive segment start.
---@param overflowIndex number First index that overflows one row.
---@return number breakIndex Chosen line-end index (inclusive).
---@return number nextStartIndex Chosen next-line start index.
---@return boolean brokeAtSpace True when the break landed on a space boundary.
local function _ChooseBreak(chars, from, overflowIndex)
    local lastSpaceIndex = _LastSpaceIn(chars, from, overflowIndex)
    if (lastSpaceIndex) then
        return lastSpaceIndex, lastSpaceIndex + 1, true
    end

    local breakIndex = math_max(overflowIndex - 1, from)
    return breakIndex, breakIndex + 1, false
end

-------------------------
-- Trailing-line combining (pure).
-------------------------

---Determines whether an orphan word or CJK glyph should be pulled into the previous line.
---@param chars string[] Decoded UTF-8 characters.
---@param charCount number Total character count.
---@param nextStartIndex number Index where the trailing text would start.
---@param brokeAtSpace boolean Whether the candidate break landed on a space boundary.
---@param trailingFitsOneRow boolean Whether the trailing text occupies a single visual row.
---@return boolean shouldCombine True when combining improves trailing-line readability.
local function _ShouldCombineTrailing(chars, charCount, nextStartIndex, brokeAtSpace, trailingFitsOneRow)
    if (nextStartIndex > charCount or not trailingFitsOneRow) then
        return false
    end

    local trailingLength = charCount - nextStartIndex + 1
    local isSingleWord = brokeAtSpace and not _HasSpaceIn(chars, nextStartIndex, charCount)
    local isSingleGlyph = trailingLength == 1 and string.len(chars[nextStartIndex]) > 1
    return isSingleWord or isSingleGlyph
end

-------------------------
-- Wrapping.
-------------------------

---Splits a decoded line into character ranges, one per wrapped line.
---@param textMeasurer FontMeasurer Measuring device, already configured (font, width, shown).
---@param chars string[] Decoded UTF-8 characters of the line.
---@param combineTrailing boolean Whether to pull a lone trailing word/glyph up.
---@return number[][] segments List of {fromIndex, toIndex} character ranges.
local function _SplitIntoSegments(textMeasurer, chars, combineTrailing)
    local charCount = #chars
    local segments = {}
    local from = 1

    while (from <= charCount) do
        local overflowIndex = _FirstOverflowIndex(textMeasurer, chars, from)
        if (not overflowIndex) then
            tinsert(segments, {from, charCount})
            break
        end

        local breakIndex, nextStartIndex, brokeAtSpace = _ChooseBreak(chars, from, overflowIndex)
        breakIndex, nextStartIndex = _ExtendBreakOverNumber(chars, from, charCount, breakIndex, nextStartIndex)

        if (combineTrailing) then
            local trailingFitsOneRow = _FirstOverflowIndex(textMeasurer, chars, nextStartIndex) == nil
            if (_ShouldCombineTrailing(chars, charCount, nextStartIndex, brokeAtSpace, trailingFitsOneRow)) then
                tinsert(segments, {from, charCount})
                break
            end
        end

        tinsert(segments, {from, breakIndex})
        from = nextStartIndex
    end

    return segments
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
    textMeasurer:SetWidth(desiredWidth or (textWrapFrameObject and textWrapFrameObject:GetWidth()) or DEFAULT_WIDTH)
    textMeasurer:Show()

    -- Fast path: text that already fits needs no decoding, wrapping, or token policy.
    textMeasurer:SetText(line)
    if (not textMeasurer:Overflows()) then
        textMeasurer:Hide()
        return { prefix .. line }
    end

    local chars = utf8.chars(line)
    local segments = _SplitIntoSegments(textMeasurer, chars, combineTrailing)
    textMeasurer:Hide()

    local lines = {}
    for _, segment in ipairs(segments) do
        tinsert(lines, prefix .. _Slice(chars, segment[1], segment[2]))
    end

    return lines
end

return WrappedText
