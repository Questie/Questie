---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Slider)
---@class Slider : Frame
local Slider = {}
---@class slider : Slider
---@class SLIDER : Slider

---@param scriptType ScriptSlider
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function Slider:GetScript(scriptType, bindingType) end

---@param scriptType ScriptSlider
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function Slider:HasScript(scriptType) end

---@param scriptType ScriptSlider
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function Slider:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptSlider
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function Slider:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_Disable)
function Slider:Disable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_Enable)
function Slider:Enable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetMinMaxValues)
---@return number minValue
---@return number maxValue
function Slider:GetMinMaxValues() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetObeyStepOnDrag)
---@return boolean isObeyStepOnDrag
function Slider:GetObeyStepOnDrag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetOrientation)
---@return Orientation orientation
function Slider:GetOrientation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetStepsPerPage)
---@return number stepsPerPage
function Slider:GetStepsPerPage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetThumbTexture)
---@return SimpleTexture texture
function Slider:GetThumbTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetValue)
---@return number value
function Slider:GetValue() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_GetValueStep)
---@return number valueStep
function Slider:GetValueStep() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_IsDraggingThumb)
---@return boolean isDraggingThumb
function Slider:IsDraggingThumb() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_IsEnabled)
---@return boolean enabled
function Slider:IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetEnabled)
---@param enabled boolean
function Slider:SetEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetMinMaxValues)
---@param minValue number
---@param maxValue number
function Slider:SetMinMaxValues(minValue, maxValue) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetObeyStepOnDrag)
---@param obeyStepOnDrag boolean
function Slider:SetObeyStepOnDrag(obeyStepOnDrag) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetOrientation)
---@param orientation Orientation
function Slider:SetOrientation(orientation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetStepsPerPage)
---@param stepsPerPage number
function Slider:SetStepsPerPage(stepsPerPage) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetThumbTexture)
---@param asset TextureAsset
function Slider:SetThumbTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetValue)
---@param value number
---@param treatAsMouseEvent? boolean Default = false
function Slider:SetValue(value, treatAsMouseEvent) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Slider_SetValueStep)
---@param valueStep number
function Slider:SetValueStep(valueStep) end
