---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Font)
---@class Font : FrameScriptObject
local Font = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_CopyFontObject)
---@param sourceFont SimpleFont|FontObject
function Font:CopyFontObject(sourceFont) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetAlpha)
---@return SingleColorValue alpha
function Font:GetAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetFont)
---@return string fontFile
---@return uiFontHeight height
---@return TBFFlags flags
function Font:GetFont() end

---Return is either in uiUnits or internal height due to fixedHeight.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetFontHeight)
---@return number height
function Font:GetFontHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetFontObject)
---@return SimpleFont font
function Font:GetFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetFontObjectForAlphabet)
---@param alphabet FontAlphabet
---@return SimpleFont font
function Font:GetFontObjectForAlphabet(alphabet) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetIndentedWordWrap)
---@return boolean wordWrap
function Font:GetIndentedWordWrap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetJustifyH)
---@return JustifyHorizontal justifyH
function Font:GetJustifyH() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetJustifyV)
---@return JustifyVertical justifyV
function Font:GetJustifyV() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetShadowColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function Font:GetShadowColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetShadowOffset)
---@return number offsetX
---@return number offsetY
function Font:GetShadowOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetSpacing)
---@return uiUnit spacing
function Font:GetSpacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_GetTextColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function Font:GetTextColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetAlpha)
---@param alpha SingleColorValue
function Font:SetAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetFont)
---@param fontFile FontFile
---@param height uiFontHeight
---@param flags TBFFlags
function Font:SetFont(fontFile, height, flags) end

---Preserves all flags, does correct height conversion due to fixedHeight.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetFontHeight)
---@param height number
function Font:SetFontHeight(height) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetFontObject)
---@param font FontObject|nil
function Font:SetFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetIndentedWordWrap)
---@param wordWrap boolean
function Font:SetIndentedWordWrap(wordWrap) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetJustifyH)
---@param justifyH JustifyHorizontal
function Font:SetJustifyH(justifyH) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetJustifyV)
---@param justifyV JustifyVertical
function Font:SetJustifyV(justifyV) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetShadowColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function Font:SetShadowColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetShadowOffset)
---@param offsetX number
---@param offsetY number
function Font:SetShadowOffset(offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetSpacing)
---@param spacing uiUnit
function Font:SetSpacing(spacing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Font_SetTextColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function Font:SetTextColor(colorR, colorG, colorB, a) end
