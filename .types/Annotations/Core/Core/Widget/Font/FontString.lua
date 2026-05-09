---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_FontString)
---@class FontString : Region
local FontString = {}
---@class fontstring : FontString
---@class FONTSTRING : FontString

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_CalculateScreenAreaFromCharacterSpan)
---@param leftIndex number
---@param rightIndex number
---@return uiBoundsRect[]? areas
function FontString:CalculateScreenAreaFromCharacterSpan(leftIndex, rightIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_CanNonSpaceWrap)
---@return boolean wrap
function FontString:CanNonSpaceWrap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_CanWordWrap)
---@return boolean wrap
function FontString:CanWordWrap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_ClearAlphaGradient)
function FontString:ClearAlphaGradient() end

---Sets text to an empty string and removes the Text secret aspect.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_ClearText)
function FontString:ClearText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_FindCharacterIndexAtCoordinate)
---@param x uiUnit
---@param y uiUnit
---@return number characterIndex
---@return boolean inside
function FontString:FindCharacterIndexAtCoordinate(x, y) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetAlphaGradient)
---@return number start
---@return number length
function FontString:GetAlphaGradient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetFieldSize)
---@return number fieldSize
function FontString:GetFieldSize() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetFont)
---@return string? fontFile
---@return uiUnit fontHeight
---@return TBFFlags flags
function FontString:GetFont() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetFontHeight)
---@param calculated? boolean Default = true
---@return uiUnit height
function FontString:GetFontHeight(calculated) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetFontObject)
---@return SimpleFont font
function FontString:GetFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetIndentedWordWrap)
---@return boolean wrap
function FontString:GetIndentedWordWrap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetJustifyH)
---@return JustifyHorizontal justifyH
function FontString:GetJustifyH() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetJustifyV)
---@return JustifyVertical justifyV
function FontString:GetJustifyV() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetLineHeight)
---@return uiUnit lineHeight
function FontString:GetLineHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetMaxLines)
---@return number maxLines
function FontString:GetMaxLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetNumLines)
---@return number numLines
function FontString:GetNumLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetRotation)
---@return number radians
function FontString:GetRotation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetScaleAnimationMode)
---@return Enum.FontStringScaleAnimationMode scaleAnimationMode
function FontString:GetScaleAnimationMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetShadowColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function FontString:GetShadowColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetShadowOffset)
---@return number offsetX
---@return number offsetY
function FontString:GetShadowOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetSpacing)
---@return uiUnit spacing
function FontString:GetSpacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetStringHeight)
---@return uiUnit height
function FontString:GetStringHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetStringWidth)
---@return uiUnit width
function FontString:GetStringWidth() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetText)
---@return string text
function FontString:GetText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetTextColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function FontString:GetTextColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetTextScale)
---@return number textScale
function FontString:GetTextScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetUnboundedStringWidth)
---@return uiUnit width
function FontString:GetUnboundedStringWidth() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_GetWrappedWidth)
---@return uiUnit width
function FontString:GetWrappedWidth() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_IsTruncated)
---@return boolean isTruncated
function FontString:IsTruncated() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_OnColorsUpdated)
function FontString:OnColorsUpdated() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetAlphaGradient)
---@param start number
---@param length number
---@return boolean isWithinText
function FontString:SetAlphaGradient(start, length) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetFixedColor)
---@param fixedColor boolean
function FontString:SetFixedColor(fixedColor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetFont)
---@param fontFile FontFile
---@param fontHeight uiUnit
---@param flags? TBFFlags
function FontString:SetFont(fontFile, fontHeight, flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetFontHeight)
---@param height uiUnit
function FontString:SetFontHeight(height) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetFontObject)
---@param font FontObject|nil
function FontString:SetFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetFormattedText)
---@param text string
---@param ... string|number
function FontString:SetFormattedText(text, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetIndentedWordWrap)
---@param wrap boolean
function FontString:SetIndentedWordWrap(wrap) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetJustifyH)
---@param justifyH JustifyHorizontal
function FontString:SetJustifyH(justifyH) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetJustifyV)
---@param justifyV JustifyVertical
function FontString:SetJustifyV(justifyV) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetMaxLines)
---@param maxLines number
function FontString:SetMaxLines(maxLines) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetNonSpaceWrap)
---@param wrap boolean
function FontString:SetNonSpaceWrap(wrap) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetRotation)
---@param radians number
function FontString:SetRotation(radians) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetScaleAnimationMode)
---@param scaleAnimationMode Enum.FontStringScaleAnimationMode
function FontString:SetScaleAnimationMode(scaleAnimationMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetShadowColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function FontString:SetShadowColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetShadowOffset)
---@param offsetX number
---@param offsetY number
function FontString:SetShadowOffset(offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetSpacing)
---@param spacing uiUnit
function FontString:SetSpacing(spacing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetText)
---@param text? string Default = 
function FontString:SetText(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetTextColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function FontString:SetTextColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetTextHeight)
---@param height uiUnit
function FontString:SetTextHeight(height) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetTextScale)
---@param textScale number
function FontString:SetTextScale(textScale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetTextToFit)
---@param text? string Default = 
function FontString:SetTextToFit(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FontString_SetWordWrap)
---@param wrap boolean
function FontString:SetWordWrap(wrap) end
