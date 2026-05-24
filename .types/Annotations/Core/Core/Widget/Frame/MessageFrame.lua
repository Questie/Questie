---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_MessageFrame)
---@class MessageFrame : Frame
local MessageFrame  = {}
---@class messageframe : MessageFrame
---@class MESSAGEFRAME : MessageFrame

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_AddMessage)
---@param text string
---@param colorR? number
---@param colorG? number
---@param colorB? number
---@param a? SingleColorValue
---@param messageID? number
function MessageFrame:AddMessage(text, colorR, colorG, colorB, a, messageID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_Clear)
function MessageFrame:Clear() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetFadeDuration)
---@return number fadeDurationSeconds
function MessageFrame:GetFadeDuration() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetFadePower)
---@return number fadePower
function MessageFrame:GetFadePower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetFading)
---@return boolean isFading
function MessageFrame:GetFading() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetFont)
---@return string fontFile
---@return uiFontHeight height
---@return TBFFlags flags
function MessageFrame:GetFont() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetFontObject)
---@return SimpleFont font
function MessageFrame:GetFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetFontStringByID)
---@param messageID number
---@return SimpleFontString fontString
function MessageFrame:GetFontStringByID(messageID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetIndentedWordWrap)
---@return boolean wordWrap
function MessageFrame:GetIndentedWordWrap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetInsertMode)
---@return InsertMode mode
function MessageFrame:GetInsertMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetJustifyH)
---@return JustifyHorizontal justifyH
function MessageFrame:GetJustifyH() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetJustifyV)
---@return JustifyVertical justifyV
function MessageFrame:GetJustifyV() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetShadowColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function MessageFrame:GetShadowColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetShadowOffset)
---@return number offsetX
---@return number offsetY
function MessageFrame:GetShadowOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetSpacing)
---@return uiUnit spacing
function MessageFrame:GetSpacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetTextColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function MessageFrame:GetTextColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_GetTimeVisible)
---@return number timeVisibleSeconds
function MessageFrame:GetTimeVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_HasMessageByID)
---@param messageID number
---@return boolean hasMessage
function MessageFrame:HasMessageByID(messageID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_ResetMessageFadeByID)
---@param messageID number
function MessageFrame:ResetMessageFadeByID(messageID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetFadeDuration)
---@param fadeDurationSeconds number
function MessageFrame:SetFadeDuration(fadeDurationSeconds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetFadePower)
---@param fadePower number
function MessageFrame:SetFadePower(fadePower) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetFading)
---@param fading boolean
function MessageFrame:SetFading(fading) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetFont)
---@param fontFile FontFile
---@param height uiFontHeight
---@param flags TBFFlags
function MessageFrame:SetFont(fontFile, height, flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetFontObject)
---@param font FontObject|nil
function MessageFrame:SetFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetIndentedWordWrap)
---@param wordWrap boolean
function MessageFrame:SetIndentedWordWrap(wordWrap) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetInsertMode)
---@param mode InsertMode
function MessageFrame:SetInsertMode(mode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetJustifyH)
---@param justifyH JustifyHorizontal
function MessageFrame:SetJustifyH(justifyH) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetJustifyV)
---@param justifyV JustifyVertical
function MessageFrame:SetJustifyV(justifyV) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetShadowColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function MessageFrame:SetShadowColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetShadowOffset)
---@param offsetX number
---@param offsetY number
function MessageFrame:SetShadowOffset(offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetSpacing)
---@param spacing uiUnit
function MessageFrame:SetSpacing(spacing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetTextColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function MessageFrame:SetTextColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MessageFrame_SetTimeVisible)
---@param timeVisibleSeconds number
function MessageFrame:SetTimeVisible(timeVisibleSeconds) end
