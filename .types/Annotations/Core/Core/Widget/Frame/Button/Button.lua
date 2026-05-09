---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Button)
---@class Button : Frame
local Button = {}
---@class button : Button
---@class BUTTON : Button

---@param scriptType ScriptButton
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function Button:GetScript(scriptType, bindingType) end

---@param scriptType ScriptButton
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function Button:HasScript(scriptType) end

---@param scriptType ScriptButton
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function Button:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptButton
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function Button:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_ClearDisabledTexture)
function Button:ClearDisabledTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_ClearHighlightTexture)
function Button:ClearHighlightTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_ClearNormalTexture)
function Button:ClearNormalTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_ClearPushedTexture)
function Button:ClearPushedTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_Click)
---@param button? string Default = LeftButton
---@param isDown? boolean Default = false
function Button:Click(button, isDown) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_Disable)
function Button:Disable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_Enable)
function Button:Enable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetButtonState)
---@return SimpleButtonStateToken buttonState
function Button:GetButtonState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetDisabledFontObject)
---@return SimpleFont font
function Button:GetDisabledFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetDisabledTexture)
---@return SimpleTexture texture
function Button:GetDisabledTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetFontString)
---@return SimpleFontString fontString
function Button:GetFontString() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetHighlightFontObject)
---@return SimpleFont font
function Button:GetHighlightFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetHighlightTexture)
---@return SimpleTexture texture
function Button:GetHighlightTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetMotionScriptsWhileDisabled)
---@return boolean motionScriptsWhileDisabled
function Button:GetMotionScriptsWhileDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetNormalFontObject)
---@return SimpleFont font
function Button:GetNormalFontObject() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetNormalTexture)
---@return SimpleTexture texture
function Button:GetNormalTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetPushedTextOffset)
---@return uiUnit offsetX
---@return uiUnit offsetY
function Button:GetPushedTextOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetPushedTexture)
---@return SimpleTexture texture
function Button:GetPushedTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetText)
---@return string text
function Button:GetText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetTextHeight)
---@return uiUnit height
function Button:GetTextHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_GetTextWidth)
---@return uiUnit width
function Button:GetTextWidth() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_IsEnabled)
---@return boolean isEnabled
function Button:IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_RegisterForClicks)
---@param ... ClickButton buttons
function Button:RegisterForClicks(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_RegisterForMouse)
---@param ... ClickButton buttons
function Button:RegisterForMouse(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetButtonState)
---@param buttonState SimpleButtonStateToken
---@param lock? boolean Default = false
function Button:SetButtonState(buttonState, lock) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetDisabledAtlas)
---@param atlas textureAtlas
function Button:SetDisabledAtlas(atlas) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetDisabledFontObject)
---@param font SimpleFont|FontObject
function Button:SetDisabledFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetDisabledTexture)
---@param asset TextureAsset
function Button:SetDisabledTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetEnabled)
---@param enabled? boolean Default = false
function Button:SetEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetFontString)
---@param fontString SimpleFontString
function Button:SetFontString(fontString) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetFormattedText)
---@param text string
---@param ... string|number
function Button:SetFormattedText(text, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetHighlightAtlas)
---@param atlas textureAtlas
---@param blendMode? BlendMode
function Button:SetHighlightAtlas(atlas, blendMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetHighlightFontObject)
---@param font SimpleFont|FontObject
function Button:SetHighlightFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetHighlightTexture)
---@param asset TextureAsset
---@param blendMode? BlendMode
function Button:SetHighlightTexture(asset, blendMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetMotionScriptsWhileDisabled)
---@param motionScriptsWhileDisabled boolean
function Button:SetMotionScriptsWhileDisabled(motionScriptsWhileDisabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetNormalAtlas)
---@param atlas textureAtlas
function Button:SetNormalAtlas(atlas) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetNormalFontObject)
---@param font SimpleFont|FontObject
function Button:SetNormalFontObject(font) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetNormalTexture)
---@param asset TextureAsset
function Button:SetNormalTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetPushedAtlas)
---@param atlas textureAtlas
function Button:SetPushedAtlas(atlas) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetPushedTextOffset)
---@param offsetX uiUnit
---@param offsetY uiUnit
function Button:SetPushedTextOffset(offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetPushedTexture)
---@param asset TextureAsset
function Button:SetPushedTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Button_SetText)
---@param text? string Default = 
function Button:SetText(text) end
