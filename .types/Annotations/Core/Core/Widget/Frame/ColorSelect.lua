---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ColorSelect)
---@class ColorSelect : Frame
local ColorSelect = {}
---@class colorselect : ColorSelect
---@class COLORSELECT : ColorSelect

---@param scriptType ScriptColorSelect
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function ColorSelect:GetScript(scriptType, bindingType) end

---@param scriptType ScriptColorSelect
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function ColorSelect:HasScript(scriptType) end

---@param scriptType ScriptColorSelect
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function ColorSelect:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptColorSelect
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function ColorSelect:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_ClearColorWheelTexture)
function ColorSelect:ClearColorWheelTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorAlpha)
---@return number alpha
function ColorSelect:GetColorAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorAlphaTexture)
---@return SimpleTexture texture
function ColorSelect:GetColorAlphaTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorAlphaThumbTexture)
---@return SimpleTexture texture
function ColorSelect:GetColorAlphaThumbTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorHSV)
---@return number hsvX
---@return number hsvY
---@return number hsvZ
function ColorSelect:GetColorHSV() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorRGB)
---@return number rgbR
---@return number rgbG
---@return number rgbB
function ColorSelect:GetColorRGB() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorValueTexture)
---@return SimpleTexture texture
function ColorSelect:GetColorValueTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorValueThumbTexture)
---@return SimpleTexture texture
function ColorSelect:GetColorValueThumbTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorWheelTexture)
---@return SimpleTexture texture
function ColorSelect:GetColorWheelTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_GetColorWheelThumbTexture)
---@return SimpleTexture texture
function ColorSelect:GetColorWheelThumbTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorAlpha)
---@param alpha number
function ColorSelect:SetColorAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorAlphaTexture)
---@param texture SimpleTexture
function ColorSelect:SetColorAlphaTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorAlphaThumbTexture)
---@param texture TextureAsset
function ColorSelect:SetColorAlphaThumbTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorHSV)
---@param hsvX number
---@param hsvY number
---@param hsvZ number
function ColorSelect:SetColorHSV(hsvX, hsvY, hsvZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorRGB)
---@param rgbR number
---@param rgbG number
---@param rgbB number
function ColorSelect:SetColorRGB(rgbR, rgbG, rgbB) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorValueTexture)
---@param texture SimpleTexture
function ColorSelect:SetColorValueTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorValueThumbTexture)
---@param texture TextureAsset
function ColorSelect:SetColorValueThumbTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorWheelTexture)
---@param texture SimpleTexture
function ColorSelect:SetColorWheelTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorSelect_SetColorWheelThumbTexture)
---@param texture TextureAsset
function ColorSelect:SetColorWheelThumbTexture(texture) end
