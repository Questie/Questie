---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_EditBox)
---@class EditBox : Frame
local EditBox = {}
---@class editbox : EditBox
---@class EDITBOX : EditBox

---@param scriptType ScriptEditBox
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function EditBox:GetScript(scriptType, bindingType) end

---@param scriptType ScriptEditBox
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function EditBox:HasScript(scriptType) end

---@param scriptType ScriptEditBox
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function EditBox:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptEditBox
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function EditBox:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_AddHistoryLine)
---@param text string
function EditBox:AddHistoryLine(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_ClearFocus)
function EditBox:ClearFocus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_ClearHighlightText)
function EditBox:ClearHighlightText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_ClearHistory)
function EditBox:ClearHistory() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_Disable)
function EditBox:Disable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_Enable)
function EditBox:Enable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetAltArrowKeyMode)
---@return boolean altMode
function EditBox:GetAltArrowKeyMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetBlinkSpeed)
---@return number cursorBlinkSpeedSec
function EditBox:GetBlinkSpeed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetCursorPosition)
---@return number cursorPosition
function EditBox:GetCursorPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetDisplayText)
---@return string displayText
function EditBox:GetDisplayText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetFont)
---@return string name
---@return uiUnit fontHeight
---@return TBFFlags flags
function EditBox:GetFont() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetFontObject)
---@return SimpleFont font
function EditBox:GetFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetHighlightColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function EditBox:GetHighlightColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetHistoryLines)
---@return number numHistoryLines
function EditBox:GetHistoryLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetIndentedWordWrap)
---@return boolean isIndented
function EditBox:GetIndentedWordWrap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetInputLanguage)
---@return string language
function EditBox:GetInputLanguage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetJustifyH)
---@return JustifyHorizontal justifyH
function EditBox:GetJustifyH() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetJustifyV)
---@return JustifyVertical justifyV
function EditBox:GetJustifyV() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetMaxBytes)
---@return number maxBytes
function EditBox:GetMaxBytes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetMaxLetters)
---@return number maxLetters
function EditBox:GetMaxLetters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetNumLetters)
---@return number numLetters
function EditBox:GetNumLetters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetNumLines)
---@return number lines
function EditBox:GetNumLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetNumber)
---@return number? number
function EditBox:GetNumber() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetShadowColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function EditBox:GetShadowColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetShadowOffset)
---@return number offsetX
---@return number offsetY
function EditBox:GetShadowOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetSpacing)
---@return uiUnit fontHeight
function EditBox:GetSpacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetText)
---@return string text
function EditBox:GetText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetTextColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function EditBox:GetTextColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetTextInsets)
---@return uiUnit left
---@return uiUnit right
---@return uiUnit top
---@return uiUnit bottom
function EditBox:GetTextInsets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetUTF8CursorPosition)
---@return number cursorPosition
function EditBox:GetUTF8CursorPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_GetVisibleTextByteLimit)
---@return number maxVisibleBytes
function EditBox:GetVisibleTextByteLimit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_HasFocus)
---@return boolean hasFocus
function EditBox:HasFocus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_HasText)
---@return boolean hasText
function EditBox:HasText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_HighlightText)
---@param start? number Default = 0
---@param stop? number Default = -1
function EditBox:HighlightText(start, stop) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_Insert)
---@param text string
function EditBox:Insert(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsAlphabeticOnly)
---@return boolean enabled
function EditBox:IsAlphabeticOnly() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsAutoFocus)
---@return boolean autoFocus
function EditBox:IsAutoFocus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsCountInvisibleLetters)
---@return boolean countInvisibleLetters
function EditBox:IsCountInvisibleLetters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsEnabled)
---@return boolean isEnabled
function EditBox:IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsInIMECompositionMode)
---@return boolean isInIMECompositionMode
function EditBox:IsInIMECompositionMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsMultiLine)
---@return boolean multiline
function EditBox:IsMultiLine() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsNumeric)
---@return boolean isNumeric
function EditBox:IsNumeric() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsNumericFullRange)
---@return boolean isNumeric
function EditBox:IsNumericFullRange() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsPassword)
---@return boolean isPassword
function EditBox:IsPassword() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_IsSecureText)
---@return boolean isSecure
function EditBox:IsSecureText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_ResetInputMode)
function EditBox:ResetInputMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetAlphabeticOnly)
---@param enabled? boolean Default = false
function EditBox:SetAlphabeticOnly(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetAltArrowKeyMode)
---@param altMode? boolean Default = false
function EditBox:SetAltArrowKeyMode(altMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetAutoFocus)
---@param autoFocus? boolean Default = false
function EditBox:SetAutoFocus(autoFocus) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetBlinkSpeed)
---@param cursorBlinkSpeedSec number
function EditBox:SetBlinkSpeed(cursorBlinkSpeedSec) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetCountInvisibleLetters)
---@param countInvisibleLetters? boolean Default = false
function EditBox:SetCountInvisibleLetters(countInvisibleLetters) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetCursorPosition)
---@param cursorPosition number
function EditBox:SetCursorPosition(cursorPosition) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetEnabled)
---@param enabled? boolean Default = false
function EditBox:SetEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetFocus)
function EditBox:SetFocus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetFont)
---@param fontFile FontFile
---@param height uiFontHeight
---@param flags TBFFlags
---@return boolean success
function EditBox:SetFont(fontFile, height, flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetFontObject)
---@param font FontObject|nil
function EditBox:SetFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetHighlightColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function EditBox:SetHighlightColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetHistoryLines)
---@param numHistoryLines number
function EditBox:SetHistoryLines(numHistoryLines) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetIndentedWordWrap)
---@param isIndented? boolean Default = false
function EditBox:SetIndentedWordWrap(isIndented) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetJustifyH)
---@param justifyH JustifyHorizontal
function EditBox:SetJustifyH(justifyH) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetJustifyV)
---@param justifyV JustifyVertical
function EditBox:SetJustifyV(justifyV) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetMaxBytes)
---@param maxBytes number
function EditBox:SetMaxBytes(maxBytes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetMaxLetters)
---@param maxLetters number
function EditBox:SetMaxLetters(maxLetters) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetMultiLine)
---@param multiline? boolean Default = false
function EditBox:SetMultiLine(multiline) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetNumber)
---@param number number
function EditBox:SetNumber(number) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetNumeric)
---@param isNumeric? boolean Default = false
function EditBox:SetNumeric(isNumeric) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetNumericFullRange)
---@param isNumeric? boolean Default = false
function EditBox:SetNumericFullRange(isNumeric) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetPassword)
---@param isPassword? boolean Default = false
function EditBox:SetPassword(isPassword) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetSecureText)
---@param isSecure? boolean Default = false
function EditBox:SetSecureText(isSecure) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetSecurityDisablePaste)
function EditBox:SetSecurityDisablePaste() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetSecurityDisableSetText)
function EditBox:SetSecurityDisableSetText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetShadowColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function EditBox:SetShadowColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetShadowOffset)
---@param offsetX number
---@param offsetY number
function EditBox:SetShadowOffset(offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetSpacing)
---@param fontHeight uiUnit
function EditBox:SetSpacing(fontHeight) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetText)
---@param text string
function EditBox:SetText(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetTextColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function EditBox:SetTextColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetTextInsets)
---@param left uiUnit
---@param right uiUnit
---@param top uiUnit
---@param bottom uiUnit
function EditBox:SetTextInsets(left, right, top, bottom) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_SetVisibleTextByteLimit)
---@param maxVisibleBytes number
function EditBox:SetVisibleTextByteLimit(maxVisibleBytes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EditBox_ToggleInputLanguage)
function EditBox:ToggleInputLanguage() end
