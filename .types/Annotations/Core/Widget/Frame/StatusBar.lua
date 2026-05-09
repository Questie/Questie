---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_StatusBar)
---@class StatusBar : Frame
local StatusBar = {}
---@class statusbar : StatusBar
---@class STATUSBAR : StatusBar

---@param scriptType ScriptStatusBar
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function StatusBar:GetScript(scriptType, bindingType) end

---@param scriptType ScriptStatusBar
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function StatusBar:HasScript(scriptType) end

---@param scriptType ScriptStatusBar
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function StatusBar:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptStatusBar
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function StatusBar:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetFillStyle)
---@return StatusBarFillStyle fillStyle
function StatusBar:GetFillStyle() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetMinMaxValues)
---@return number minValue
---@return number maxValue
function StatusBar:GetMinMaxValues() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetOrientation)
---@return Orientation orientation
function StatusBar:GetOrientation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetReverseFill)
---@return boolean isReverseFill
function StatusBar:GetReverseFill() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetRotatesTexture)
---@return boolean rotatesTexture
function StatusBar:GetRotatesTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetStatusBarColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function StatusBar:GetStatusBarColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetStatusBarDesaturation)
---@return normalizedValue desaturation
function StatusBar:GetStatusBarDesaturation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetStatusBarTexture)
---@return SimpleTexture texture
function StatusBar:GetStatusBarTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_GetValue)
---@return number value
function StatusBar:GetValue() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_IsStatusBarDesaturated)
---@return boolean desaturated
function StatusBar:IsStatusBarDesaturated() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetColorFill)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function StatusBar:SetColorFill(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetFillStyle)
---@param fillStyle StatusBarFillStyle
function StatusBar:SetFillStyle(fillStyle) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetMinMaxValues)
---@param minValue number
---@param maxValue number
function StatusBar:SetMinMaxValues(minValue, maxValue) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetOrientation)
---@param orientation Orientation
function StatusBar:SetOrientation(orientation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetReverseFill)
---@param isReverseFill boolean
function StatusBar:SetReverseFill(isReverseFill) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetRotatesTexture)
---@param rotatesTexture boolean
function StatusBar:SetRotatesTexture(rotatesTexture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetStatusBarColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function StatusBar:SetStatusBarColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetStatusBarDesaturated)
---@param desaturated? boolean Default = false
function StatusBar:SetStatusBarDesaturated(desaturated) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetStatusBarDesaturation)
---@param desaturation normalizedValue
function StatusBar:SetStatusBarDesaturation(desaturation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetStatusBarTexture)
---@param asset TextureAsset
---@return boolean success
function StatusBar:SetStatusBarTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StatusBar_SetValue)
---@param value number
function StatusBar:SetValue(value) end
