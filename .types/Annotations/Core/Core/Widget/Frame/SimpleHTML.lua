---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_SimpleHTML)
---@class SimpleHTML : Frame
local SimpleHTML  = {}
---@class simplehtml : SimpleHTML
---@class SIMPLEHTML : SimpleHTML

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetContentHeight)
---@return uiUnit height
function SimpleHTML:GetContentHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetFont)
---@param textType HTMLTextType
---@return string fontFile
---@return uiFontHeight height
---@return TBFFlags flags
function SimpleHTML:GetFont(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetFontObject)
---@param textType HTMLTextType
---@return SimpleFont font
function SimpleHTML:GetFontObject(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetHyperlinkFormat)
---@return string format
function SimpleHTML:GetHyperlinkFormat() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetIndentedWordWrap)
---@param textType HTMLTextType
---@return boolean wordWrap
function SimpleHTML:GetIndentedWordWrap(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetJustifyH)
---@param textType HTMLTextType
---@return JustifyHorizontal justifyH
function SimpleHTML:GetJustifyH(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetJustifyV)
---@param textType HTMLTextType
---@return JustifyVertical justifyV
function SimpleHTML:GetJustifyV(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetShadowColor)
---@param textType HTMLTextType
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function SimpleHTML:GetShadowColor(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetShadowOffset)
---@param textType HTMLTextType
---@return number offsetX
---@return number offsetY
function SimpleHTML:GetShadowOffset(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetSpacing)
---@param textType HTMLTextType
---@return uiUnit spacing
function SimpleHTML:GetSpacing(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetTextColor)
---@param textType HTMLTextType
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function SimpleHTML:GetTextColor(textType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_GetTextData)
---@return HTMLContentNode[] content
function SimpleHTML:GetTextData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetFont)
---@param textType HTMLTextType
---@param fontFile FontFile
---@param height uiFontHeight
---@param flags TBFFlags
function SimpleHTML:SetFont(textType, fontFile, height, flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetFontObject)
---@param textType HTMLTextType
---@param font FontObject
function SimpleHTML:SetFontObject(textType, font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetHyperlinkFormat)
---@param format string
function SimpleHTML:SetHyperlinkFormat(format) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetIndentedWordWrap)
---@param textType HTMLTextType
---@param wordWrap boolean
function SimpleHTML:SetIndentedWordWrap(textType, wordWrap) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetJustifyH)
---@param textType HTMLTextType
---@param justifyH JustifyHorizontal
function SimpleHTML:SetJustifyH(textType, justifyH) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetJustifyV)
---@param textType HTMLTextType
---@param justifyV JustifyVertical
function SimpleHTML:SetJustifyV(textType, justifyV) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetShadowColor)
---@param textType HTMLTextType
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function SimpleHTML:SetShadowColor(textType, colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetShadowOffset)
---@param textType HTMLTextType
---@param offsetX number
---@param offsetY number
function SimpleHTML:SetShadowOffset(textType, offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetSpacing)
---@param textType HTMLTextType
---@param spacing uiUnit
function SimpleHTML:SetSpacing(textType, spacing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetText)
---@param text string
---@param ignoreMarkup? boolean Default = false
function SimpleHTML:SetText(text, ignoreMarkup) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SimpleHTML_SetTextColor)
---@param textType HTMLTextType
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function SimpleHTML:SetTextColor(textType, colorR, colorG, colorB, a) end
