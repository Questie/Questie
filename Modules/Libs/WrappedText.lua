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

---@class WrappedTextColorEvent
---@field kind "open"|"reset" Whether this event opens a color or resets the current color.
---@field value string Original `|c...` or `|r` escape sequence.

---Builds the visible text used for measurement and records zero-width color controls.
---Escaped `||` stays visible and is rebuilt as `||` when color-aware rebuilding is needed.
---@param line string Source text that may contain WoW color escapes.
---@return string visibleLine Text with color escapes removed for width measurement.
---@return table<number, string> rawCharactersByVisibleIndex Raw visible characters, preserving escaped literal pipes.
---@return table<number, WrappedTextColorEvent[]> colorEventsByVisibleIndex Color events keyed by the next visible character index.
---@return boolean hasRealColorEscapes True when a real `|c...` or `|r` escape was found.
local function _ParseColorEscapes(line)
    local colorEventsByVisibleIndex = {}
    local visibleCharacters = {}
    local rawCharactersByVisibleIndex = {}
    local byteIndex = 1
    local hasRealColorEscapes = false

    while (byteIndex <= string.len(line)) do
        local escapedPipe = string.match(line, "^||", byteIndex)
        local colorOpen = string.match(line, "^|[cC]%x%x%x%x%x%x%x%x", byteIndex)
        local colorReset = string.match(line, "^|[rR]", byteIndex)
        if (escapedPipe) then
            tinsert(visibleCharacters, "|")
            tinsert(rawCharactersByVisibleIndex, escapedPipe)
            byteIndex = byteIndex + string.len(escapedPipe)
        elseif (colorOpen) then
            local visibleIndex = #visibleCharacters + 1
            colorEventsByVisibleIndex[visibleIndex] = colorEventsByVisibleIndex[visibleIndex] or {}
            tinsert(colorEventsByVisibleIndex[visibleIndex], {kind = "open", value = colorOpen})
            byteIndex = byteIndex + string.len(colorOpen)
            hasRealColorEscapes = true
        elseif (colorReset) then
            local visibleIndex = #visibleCharacters + 1
            colorEventsByVisibleIndex[visibleIndex] = colorEventsByVisibleIndex[visibleIndex] or {}
            tinsert(colorEventsByVisibleIndex[visibleIndex], {kind = "reset", value = colorReset})
            byteIndex = byteIndex + string.len(colorReset)
            hasRealColorEscapes = true
        else
            local character = utf8.sub(string.sub(line, byteIndex), 1, 1)
            tinsert(visibleCharacters, character)
            tinsert(rawCharactersByVisibleIndex, character)
            byteIndex = byteIndex + string.len(character)
        end
    end

    return table.concat(visibleCharacters), rawCharactersByVisibleIndex, colorEventsByVisibleIndex, hasRealColorEscapes
end

---Returns the color that is active before a visible character index is emitted.
---@param colorEventsByVisibleIndex table<number, WrappedTextColorEvent[]>
---@param visibleIndex number Visible character index in the measured text.
---@return string? activeColor Active `|c...` escape, if any.
local function _GetActiveColorBefore(colorEventsByVisibleIndex, visibleIndex)
    local activeColor

    for index = 1, visibleIndex - 1 do
        local colorEvents = colorEventsByVisibleIndex[index]
        if (colorEvents) then
            for _, colorEvent in ipairs(colorEvents) do
                if (colorEvent.kind == "open") then
                    activeColor = colorEvent.value
                else
                    activeColor = nil
                end
            end
        end
    end

    return activeColor
end

---Returns true when the current active color is bounded by a future reset before another color opens.
---@param colorEventsByVisibleIndex table<number, WrappedTextColorEvent[]>
---@param visibleStartIndex number Visible character index where the future scan starts.
---@return boolean hasFutureReset True when this wrapped segment needs a synthetic `|r`.
local function _HasFutureResetBeforeNextColorOpen(colorEventsByVisibleIndex, visibleStartIndex)
    local maxIndex = 0
    for index in pairs(colorEventsByVisibleIndex) do
        if (index > maxIndex) then
            maxIndex = index
        end
    end

    for index = visibleStartIndex, maxIndex do
        local colorEvents = colorEventsByVisibleIndex[index]
        if (colorEvents) then
            for _, colorEvent in ipairs(colorEvents) do
                if (colorEvent.kind == "reset") then
                    return true
                elseif (colorEvent.kind == "open") then
                    return false
                end
            end
        end
    end

    return false
end

---Rebuilds one wrapped line from visible indexes, reopening carried colors after the prefix.
---Only bounded color spans get synthetic resets; unbounded spans intentionally stay open.
---@param visibleLine string Text used for measurement, with color escapes removed.
---@param rawCharactersByVisibleIndex table<number, string> Raw visible characters, preserving escaped literal pipes.
---@param colorEventsByVisibleIndex table<number, WrappedTextColorEvent[]> Color events keyed by visible index.
---@param prefix string Prefix to add before text and any carried color.
---@param visibleStartIndex number First visible character index for this output line.
---@param visibleEndIndex number Last visible character index for this output line.
---@return string rebuiltLine Wrapped line with color escapes restored.
local function _RebuildColorEscapedLine(
    visibleLine,
    rawCharactersByVisibleIndex,
    colorEventsByVisibleIndex,
    prefix,
    visibleStartIndex,
    visibleEndIndex
)
    local rebuiltLine = {prefix}
    local activeColor = _GetActiveColorBefore(colorEventsByVisibleIndex, visibleStartIndex)
    local startColorEvents = colorEventsByVisibleIndex[visibleStartIndex]

    -- Same-index events happen before the first visible character. This lets empty color spans net out.
    if (startColorEvents) then
        for _, colorEvent in ipairs(startColorEvents) do
            if (colorEvent.kind == "open") then
                activeColor = colorEvent.value
            else
                activeColor = nil
            end
        end
    end

    -- Continuation lines reopen the active color after the prefix so the prefix remains uncolored.
    if (activeColor) then
        tinsert(rebuiltLine, activeColor)
    end

    for index = visibleStartIndex, visibleEndIndex do
        local colorEvents
        if (index ~= visibleStartIndex) then
            colorEvents = colorEventsByVisibleIndex[index]
        end
        if (colorEvents) then
            for _, colorEvent in ipairs(colorEvents) do
                if (colorEvent.kind == "open") then
                    activeColor = colorEvent.value
                else
                    activeColor = nil
                end
                tinsert(rebuiltLine, colorEvent.value)
            end
        end

        tinsert(rebuiltLine, rawCharactersByVisibleIndex[index] or utf8.sub(visibleLine, index, index))
    end

    local trailingColorEvents = colorEventsByVisibleIndex[visibleEndIndex + 1]
    if (trailingColorEvents) then
        for _, colorEvent in ipairs(trailingColorEvents) do
            if (colorEvent.kind == "reset" and activeColor) then
                activeColor = nil
                tinsert(rebuiltLine, colorEvent.value)
            end
        end
    end

    if (activeColor and _HasFutureResetBeforeNextColorOpen(colorEventsByVisibleIndex, visibleEndIndex + 1)) then
        tinsert(rebuiltLine, "|r")
    end

    return table.concat(rebuiltLine)
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

    -- Set defaults.
    if (combineTrailing == nil) then
        combineTrailing = false
    end
    -- The FontString must be shown for row-span APIs to return data.
    _SetTextWrapFont(textWrapObjectiveFontString, fontSource)
    textWrapObjectiveFontString:SetWidth(desiredWidth or textWrapFrameObject:GetWidth() or 275) --QuestLogObjectivesText default width = 275
    textWrapObjectiveFontString:Show()

    local visibleLine, rawCharactersByVisibleIndex, colorEventsByVisibleIndex, hasRealColorEscapes
    -- Most lines have no WoW escapes; avoid parser overhead unless a pipe is present.
    if (string.find(line, "|", 1, true)) then
        visibleLine, rawCharactersByVisibleIndex, colorEventsByVisibleIndex, hasRealColorEscapes = _ParseColorEscapes(line)
    end

    local measuredLine = hasRealColorEscapes and visibleLine or line
    local lineLength = utf8.strlen(measuredLine)

    -- Fast path: unwrapped text can be returned without token policy checks.
    textWrapObjectiveFontString:SetText(measuredLine)
    if (textWrapObjectiveFontString:GetUnboundedStringWidth() > textWrapObjectiveFontString:GetWrappedWidth()) then
        local lines = {}
        local startIndex = 1

        -- Centralizes the color-aware/plain output choice so the wrapping branches stay readable.
        local function _BuildWrappedLine(visibleStartIndex, visibleEndIndex, rawLine)
            if (hasRealColorEscapes) then
                return _RebuildColorEscapedLine(
                    measuredLine,
                    rawCharactersByVisibleIndex,
                    colorEventsByVisibleIndex,
                    prefix,
                    visibleStartIndex,
                    visibleEndIndex
                )
            end

            return prefix .. rawLine
        end

        while (startIndex <= lineLength) do
            local remainingLine = utf8.sub(measuredLine, startIndex, lineLength)
            local remainingLineLength = utf8.strlen(remainingLine)

            -- Recalculate each remaining line. Moving breaks over numeric tokens changes row geometry.
            textWrapObjectiveFontString:SetText(remainingLine)
            if (textWrapObjectiveFontString:GetUnboundedStringWidth() <= textWrapObjectiveFontString:GetWrappedWidth()) then
                tinsert(lines, _BuildWrappedLine(startIndex, lineLength, remainingLine))
                break
            end

            -- Apply number-token post-processing after the raw break is found.
            local lineEndIndex, nextStartIndex, brokeAtSpace = _GetTextWrapBreak(textWrapObjectiveFontString, remainingLine, remainingLineLength)
            lineEndIndex, nextStartIndex = _MoveNumberToPreviousLine(remainingLine, remainingLineLength, lineEndIndex, nextStartIndex)

            local newLine = utf8.sub(remainingLine, 1, lineEndIndex)
            local endIndex = startIndex + lineEndIndex - 1

            -- Combine a trailing word or glyph with the previous line when it would otherwise be alone.
            if (combineTrailing and _ShouldCombineTrailingLine(textWrapObjectiveFontString, remainingLine, nextStartIndex, remainingLineLength, brokeAtSpace)) then
                tinsert(lines, _BuildWrappedLine(startIndex, lineLength, remainingLine))
                break
            end

            tinsert(lines, _BuildWrappedLine(startIndex, endIndex, newLine))
            startIndex = startIndex + nextStartIndex - 1
        end
        textWrapObjectiveFontString:Hide()
        return lines
    else
        textWrapObjectiveFontString:Hide()
        return {prefix .. line}
    end
end


return WrappedText
