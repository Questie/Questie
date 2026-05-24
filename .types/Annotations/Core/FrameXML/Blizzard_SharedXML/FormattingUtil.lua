---@meta _
---[FrameXML](https://www.townlong-yak.com/framexml/go/SplitTextIntoLines)
---@param text string
---@param delimiter string
---@return string[]
function SplitTextIntoLines(text, delimiter) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SplitTextIntoHeaderAndNonHeader)
---@param text string
---@return string? header
---@return string? nonHeader
function SplitTextIntoHeaderAndNonHeader(text) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/FormatValueWithSign)
---@param value number
---@return string
function FormatValueWithSign(value) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/FormatLargeNumber)
---@param amount string|number
---@return string
function FormatLargeNumber(amount) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetMoneyString)
---@param money number
---@param separateThousands? boolean
---@return string
function GetMoneyString(money, separateThousands) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/FormatPercentage)
---@param percentage number
---@param roundToNearestInteger? boolean
---@return string
function FormatPercentage(percentage, roundToNearestInteger) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/FormatFraction)
---@param numerator number
---@param denominator number
---@return string
function FormatFraction(numerator, denominator) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetHighlightedNumberDifferenceString)
---@param baseString string
---@param newString string
---@return string
function GetHighlightedNumberDifferenceString(baseString, newString) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/FormatUnreadMailTooltip)
---@param tooltip GameTooltip
---@param headerText string
---@param senders string[]
function FormatUnreadMailTooltip(tooltip, headerText, senders) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetCurrencyString)
---@param currencyID number
---@param overrideAmount? number
---@param colorCode? string
---@param abbreviate? boolean
---@return string
function GetCurrencyString(currencyID, overrideAmount, colorCode, abbreviate) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetCurrenciesString)
---@param currencies number[] | table[] an array of currencyIDs, or a table with e.g. `{currencyID=x, amount=y} `
---@return string
function GetCurrenciesString(currencies) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ReplaceGenderTokens)
--- This is a very simple parser that will only handle $G/$g tokens
---@param string string
---@param gender string
---@return string
function ReplaceGenderTokens(string, gender) end
