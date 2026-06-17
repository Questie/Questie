---@class WrappedText
local WrappedText = QuestieLoader:CreateModule("WrappedText")

-------------------------
--Import modules.
-------------------------
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

local math_max = math.max
local tinsert = table.insert

-- The original frame which we use to fetch the data required
--                           Classic                          Wotlk Classic
local textWrapFrameObject = _G["QuestLogObjectivesText"] or _G["QuestInfoObjectivesText"]

--Part of the GameTooltipWrapDescription function
---@type FontString?
local textWrapObjectiveFontString

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

---@param character string Single UTF-8 character.
---@return boolean isDigit True for ASCII or full-width decimal digits.
local function _IsNumericCharacter(character)
    return string.match(character, "^%d$") ~= nil or FULLWIDTH_DIGITS[character] == true
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

---Copies a caller-provided render font onto the measurement FontString, with quest-log font fallback.
---@param textWrapFontString FontString Hidden FontString used for measuring.
---@param fontSource FontString? Optional render FontString to match.
---@return nil
local function _SetTextWrapFont(textWrapFontString, fontSource)
    local fontSourceType = type(fontSource)
    if (fontSource and (fontSourceType == "table" or fontSourceType == "userdata") and type(fontSource.GetFont) == "function") then
        local font, size, flags = fontSource:GetFont()
        if (font and size) then
            textWrapFontString:SetFont(font, size, flags)
            return
        end
    end

    local font, size, flags = textWrapFrameObject:GetFont()
    textWrapFontString:SetFont(font, size, flags)
end

---Chooses the best break before an overflow boundary.
---Spaces remain the strongest boundary for Latin text.
---@param lastSpaceIndex number? Last UTF-8 space index before overflow.
---@param lineEndIndex number Last fitting UTF-8 character index.
---@return number lineEndIndex Chosen line end index.
---@return number nextStartIndex Chosen next-line start index.
---@return boolean brokeAtSpace True when break was a space boundary.
local function _GetPreferredWrapIndex(lastSpaceIndex, lineEndIndex)
    if (lastSpaceIndex) then
        return lastSpaceIndex, lastSpaceIndex + 1, true
    end

    return lineEndIndex, lineEndIndex + 1, false
end

---Finds a wrap break by measuring substring width.
---Used for CJK/no-space strings when WoW's row-span API is unavailable or unreliable.
---@param textWrapFontString FontString Hidden FontString used for measuring.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@return number lineEndIndex UTF-8 character index where current line should end.
---@return number nextStartIndex UTF-8 character index where next line should start.
---@return boolean brokeAtSpace True when break was a space boundary.
local function _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
    local lastSpaceIndex

    for endIndex = 1, lineLength do
        local character = utf8.sub(line, endIndex, endIndex)
        -- Track the last ASCII space so Latin text can break at word boundaries.
        if (character == " ") then
            lastSpaceIndex = endIndex
        end

        textWrapFontString:SetText(utf8.sub(line, 1, endIndex))

        if (textWrapFontString:GetUnboundedStringWidth() > textWrapFontString:GetWrappedWidth()) then
            local lineEndIndex = math_max(endIndex - 1, 1)
            return _GetPreferredWrapIndex(lastSpaceIndex, lineEndIndex)
        end
    end

    return lineLength, lineLength + 1, false
end

---Finds a wrap break using WoW row spans, falling back to measured width for CJK edge cases.
---@param textWrapFontString FontString Hidden FontString used for measuring.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@return number lineEndIndex UTF-8 character index where current line should end.
---@return number nextStartIndex UTF-8 character index where next line should start.
---@return boolean brokeAtSpace True when break was a space boundary.
local function _GetTextWrapBreak(textWrapFontString, line, lineLength)
    if (not string.find(line, " ", 1, true) and textWrapFontString:GetUnboundedStringWidth() > textWrapFontString:GetWrappedWidth()) then
        local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
        textWrapFontString:SetText(line)
        return lineEndIndex, nextStartIndex, brokeAtSpace
    end

    local endIndex = 1
    local lastSpaceIndex

    -- Walk until this span would wrap to a second visual row.
    while (endIndex <= lineLength) do
        local character = utf8.sub(line, endIndex, endIndex)
        -- Track the last ASCII space so Latin text can break at word boundaries.
        if (character == " ") then
            lastSpaceIndex = endIndex
        end

        local indexes = textWrapFontString:CalculateScreenAreaFromCharacterSpan(1, endIndex)
        if (not indexes) then
            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
            textWrapFontString:SetText(line)
            return lineEndIndex, nextStartIndex, brokeAtSpace
        elseif (#indexes > 1) then
            break
        end

        endIndex = endIndex + 1
    end

    if (endIndex > lineLength) then
        -- Some clients/fonts do not wrap Chinese text without spaces, so the FontString reports one visual row.
        -- In that case split by measured width instead.
        if (textWrapFontString:GetUnboundedStringWidth() > textWrapFontString:GetWrappedWidth()) then
            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreakByWidth(textWrapFontString, line, lineLength)
            textWrapFontString:SetText(line)
            return lineEndIndex, nextStartIndex, brokeAtSpace
        end

        return lineLength, lineLength + 1, false
    end

    -- No space exists on this row, so split at the last fitting UTF-8 character.
    local lineEndIndex = math_max(endIndex - 1, 1)

    return _GetPreferredWrapIndex(lastSpaceIndex, lineEndIndex)
end

---Extends a break so numeric tokens stay on one line.
---@param line string UTF-8 text segment to wrap.
---@param lineLength number UTF-8 character length of `line`.
---@param lineEndIndex number Proposed current-line end index.
---@param nextStartIndex number Proposed next-line start index.
---@return number lineEndIndex Updated end index.
---@return number nextStartIndex Updated next-line start index.
local function _MoveNumberToPreviousLine(line, lineLength, lineEndIndex, nextStartIndex)
    if (lineEndIndex < 1 or nextStartIndex > lineLength or not _IsNumericTokenCharacter(line, lineEndIndex, lineLength)) then
        return lineEndIndex, nextStartIndex
    end

    while (nextStartIndex <= lineLength and _IsNumericTokenCharacter(line, nextStartIndex, lineLength)) do
        lineEndIndex = nextStartIndex
        nextStartIndex = nextStartIndex + 1
    end

    return lineEndIndex, nextStartIndex
end

---Counts how many visual rows remain after a candidate break.
---@param textWrapFontString FontString Hidden FontString used for measuring.
---@param remainingLine string Current remaining text segment.
---@param lastLine string Candidate trailing line text.
---@param nextStartIndex number UTF-8 index where trailing text starts.
---@param remainingLineLength number UTF-8 character length of `remainingLine`.
---@return number remainingRows Visual row count, approximated by width if row-span data is unavailable.
local function _GetRemainingRows(textWrapFontString, remainingLine, lastLine, nextStartIndex, remainingLineLength)
    local remainingIndexes = textWrapFontString:CalculateScreenAreaFromCharacterSpan(nextStartIndex, remainingLineLength)
    if remainingIndexes then
        return #remainingIndexes
    end

    textWrapFontString:SetText(lastLine)
    local remainingRows = textWrapFontString:GetUnboundedStringWidth() <= textWrapFontString:GetWrappedWidth() and 1 or 2
    textWrapFontString:SetText(remainingLine)

    return remainingRows
end

---Determines whether an orphan word or CJK glyph should be pulled into the previous line.
---@param textWrapFontString FontString Hidden FontString used for measuring.
---@param remainingLine string Current remaining text segment.
---@param nextStartIndex number UTF-8 index where trailing text starts.
---@param remainingLineLength number UTF-8 character length of `remainingLine`.
---@param brokeAtSpace boolean Whether the candidate break is a space boundary.
---@return boolean shouldCombine True when combining improves trailing-line readability.
local function _ShouldCombineTrailingLine(textWrapFontString, remainingLine, nextStartIndex, remainingLineLength, brokeAtSpace)
    if (nextStartIndex > remainingLineLength) then
        return false
    end

    local lastLine = utf8.sub(remainingLine, nextStartIndex, remainingLineLength)
    if (_GetRemainingRows(textWrapFontString, remainingLine, lastLine, nextStartIndex, remainingLineLength) ~= 1) then
        return false
    end

    return (brokeAtSpace and not string.find(lastLine, " ")) or (utf8.strlen(lastLine) == 1 and string.len(lastLine) > 1)
end

---Emulates the wrapping of a quest description
---@param line string @The line to wrap
---@param prefix string @The prefix to add to the line
---@param combineTrailing boolean? @If the last line is only one word/glyph, combine it with previous? TRUE=COMBINE, FALSE=NOT COMBINE, default: false
---@param desiredWidth number? @Set the desired width to wrap, default: 275
---@param fontSource FontString? @Optional FontString to copy the measuring font from
---@return string[] lines @Wrapped lines with `prefix` already applied
function WrappedText:TextWrap(line, prefix, combineTrailing, desiredWidth, fontSource)
    if not textWrapObjectiveFontString then
        textWrapObjectiveFontString = UIParent:CreateFontString("questieObjectiveTextString", "ARTWORK", "QuestFont")
        textWrapObjectiveFontString:SetWidth(textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
        textWrapObjectiveFontString:SetHeight(0);
        textWrapObjectiveFontString:SetPoint("LEFT");
        textWrapObjectiveFontString:SetJustifyH("LEFT");
        ---@diagnostic disable-next-line: redundant-parameter
        textWrapObjectiveFontString:SetWordWrap(true)
        textWrapObjectiveFontString:SetVertexColor(1, 1, 1, 1) -- Keep the hidden measurement FontString non-transparent for accurate rendering metrics.
        --Chinese? "Fonts\\ARKai_T.ttf"
        _SetTextWrapFont(textWrapObjectiveFontString)
        textWrapObjectiveFontString:Hide()
    end

    if (textWrapObjectiveFontString:IsVisible()) then Questie:Error("TextWrap already running... Please report this on GitHub or Discord.") end

    --Set Defaults
    if (combineTrailing == nil) then
        combineTrailing = false
    end
    --We show the fontstring and set the text to start the process
    --We have to show it or else the functions won't work... But we set the opacity to 0 on creation
    _SetTextWrapFont(textWrapObjectiveFontString, fontSource)
    textWrapObjectiveFontString:SetWidth(desiredWidth or textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
    textWrapObjectiveFontString:Show()

    local useLine = line
    local lineLength = utf8.strlen(useLine)

    -- Fast path: unwrapped text can be returned without token policy checks.
    textWrapObjectiveFontString:SetText(useLine)
    if (textWrapObjectiveFontString:GetUnboundedStringWidth() > textWrapObjectiveFontString:GetWrappedWidth()) then
        local lines = {}
        local startIndex = 1

        while (startIndex <= lineLength) do
            local remainingLine = utf8.sub(useLine, startIndex, lineLength)
            local remainingLineLength = utf8.strlen(remainingLine)

            -- Recalculate each remaining line. Moving breaks over numeric tokens changes row geometry.
            textWrapObjectiveFontString:SetText(remainingLine)
            if (textWrapObjectiveFontString:GetUnboundedStringWidth() <= textWrapObjectiveFontString:GetWrappedWidth()) then
                tinsert(lines, prefix .. remainingLine)
                break
            end

            -- Apply number-token post-processing after the raw break is found.
            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreak(textWrapObjectiveFontString, remainingLine, remainingLineLength)
            lineEndIndex, nextStartIndex = _MoveNumberToPreviousLine(remainingLine, remainingLineLength, lineEndIndex, nextStartIndex)

            local newLine = utf8.sub(remainingLine, 1, lineEndIndex)

            --This combines a trailing word or glyph to the previous line if it would be alone on the last line.
            if (combineTrailing and _ShouldCombineTrailingLine(textWrapObjectiveFontString, remainingLine, nextStartIndex, remainingLineLength, brokeAtSpace)) then
                newLine = remainingLine
                tinsert(lines, prefix .. newLine)
                break
            end

            tinsert(lines, prefix .. newLine)
            startIndex = startIndex + nextStartIndex - 1
        end
        textWrapObjectiveFontString:Hide()
        return lines
    else
        textWrapObjectiveFontString:Hide()
        useLine = prefix .. line
        return {useLine}
    end
end


return WrappedText
