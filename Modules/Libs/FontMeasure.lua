---@class FontMeasure
local FontMeasure = QuestieLoader:CreateModule("FontMeasure")

-------------------------
--Import modules.
-------------------------

-- Shared measuring device built around a hidden FontString. It wraps the WoW text-metric
-- API (font matching, unbounded/wrapped width, row spans) so wrapping and tooltip layout can
-- measure rendered text without each duplicating the FontString bookkeeping.

---@param value any
---@return boolean isFontStringLike True for a table/userdata exposing a GetFont method.
local function _IsFontStringLike(value)
    if (value == nil) then
        return false
    end

    local valueType = type(value)
    return (valueType == "table" or valueType == "userdata") and type(value.GetFont) == "function"
end

---@class FontMeasurer
---@field MatchFont fun(self: FontMeasurer, fontSource: FontString?): FontMeasurer
---@field SetWidth fun(self: FontMeasurer, width: number): FontMeasurer
---@field SetText fun(self: FontMeasurer, text: string?): FontMeasurer
---@field UnboundedWidth fun(self: FontMeasurer): number
---@field WrappedWidth fun(self: FontMeasurer): number
---@field Overflows fun(self: FontMeasurer): boolean
---@field RowSpan fun(self: FontMeasurer, startIndex: number, endIndex: number): table[]?
---@field MeasureWidth fun(self: FontMeasurer, text: string?, fontSource: FontString?): number
---@field Show fun(self: FontMeasurer): FontMeasurer
---@field Hide fun(self: FontMeasurer): FontMeasurer
---@field IsShown fun(self: FontMeasurer): boolean

---@class FontMeasureConfig
---@field name string Global name for the hidden FontString.
---@field template string FontString template (e.g. "QuestFont", "GameTooltipText").
---@field wordWrap boolean? Whether the FontString wraps text; defaults to false (ruler mode).
---@field defaultFontSource FontString? Preferred fallback font; when absent the template font is used.
---@field onCreate fun(fontString: FontString)? Extra one-time FontString setup (size, anchors, color).

---Creates a hidden FontString and returns a measurer bound to it.
---@param config FontMeasureConfig
---@return FontMeasurer measurer
function FontMeasure.Create(config)
    local fontString = UIParent:CreateFontString(config.name, "ARTWORK", config.template)
    ---@diagnostic disable-next-line: redundant-parameter
    fontString:SetWordWrap(config.wordWrap and true or false)

    -- Capture the fallback font once, preferring an explicit source (e.g. the quest log font).
    local defaultFont, defaultSize, defaultFlags
    if (_IsFontStringLike(config.defaultFontSource)) then
        defaultFont, defaultSize, defaultFlags = config.defaultFontSource:GetFont()
    end
    if (not (defaultFont and defaultSize)) then
        defaultFont, defaultSize, defaultFlags = fontString:GetFont()
    end

    if (config.onCreate) then
        config.onCreate(fontString)
    end
    fontString:Hide()

    ---@type FontMeasurer
    local measurer = {}

    ---Copies a render font onto the measuring FontString, falling back to the captured default.
    function measurer:MatchFont(fontSource)
        if (_IsFontStringLike(fontSource)) then
            local font, size, flags = fontSource:GetFont()
            if (font and size) then
                fontString:SetFont(font, size, flags)
                return self
            end
        end

        if (defaultFont and defaultSize) then
            fontString:SetFont(defaultFont, defaultSize, defaultFlags)
        end
        return self
    end

    function measurer:SetWidth(width)
        fontString:SetWidth(width)
        return self
    end

    function measurer:SetText(text)
        fontString:SetText(text or "")
        return self
    end

    function measurer:UnboundedWidth()
        return fontString:GetUnboundedStringWidth() or 0
    end

    function measurer:WrappedWidth()
        return fontString:GetWrappedWidth() or 0
    end

    ---True when the current text is wider than the wrapping width, i.e. it would wrap.
    function measurer:Overflows()
        return self:UnboundedWidth() > self:WrappedWidth()
    end

    ---Returns WoW's per-row screen areas for a character span of the current text, or nil.
    function measurer:RowSpan(startIndex, endIndex)
        return fontString:CalculateScreenAreaFromCharacterSpan(startIndex, endIndex)
    end

    ---Ruler convenience: match font, set text, return the unbounded width.
    function measurer:MeasureWidth(text, fontSource)
        self:MatchFont(fontSource)
        self:SetText(text)
        return self:UnboundedWidth()
    end

    function measurer:Show()
        fontString:Show()
        return self
    end

    function measurer:Hide()
        fontString:Hide()
        return self
    end

    function measurer:IsShown()
        return fontString:IsVisible()
    end

    return measurer
end

return FontMeasure
