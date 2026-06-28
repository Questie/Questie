---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ScriptRegion)
---@class ScriptRegion : Object
local ScriptRegion = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetParent)
---@return Frame parent
function ScriptRegion:GetParent() end


---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_CanChangeProtectedState)
---@return boolean canChange
function ScriptRegion:CanChangeProtectedState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_CanPropagateMouseClicks)
---@return boolean canPropagate
function ScriptRegion:CanPropagateMouseClicks() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_CanPropagateMouseMotion)
---@return boolean canPropagate
function ScriptRegion:CanPropagateMouseMotion() end

---Remove all script handlers set through Scripts in XML or SetScript in Lua
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_ClearScripts)
function ScriptRegion:ClearScripts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_CollapsesLayout)
---@return boolean collapsesLayout
function ScriptRegion:CollapsesLayout() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_EnableMouse)
---@param enable? boolean Default = false
function ScriptRegion:EnableMouse(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_EnableMouseMotion)
---@param enable? boolean Default = false
function ScriptRegion:EnableMouseMotion(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_EnableMouseWheel)
---@param enable? boolean Default = false
function ScriptRegion:EnableMouseWheel(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetBottom)
---@return uiUnit bottom
function ScriptRegion:GetBottom() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetCenter)
---@return uiUnit x
---@return uiUnit y
function ScriptRegion:GetCenter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetHeight)
---@param ignoreRect? boolean Default = false
---@return uiUnit height
function ScriptRegion:GetHeight(ignoreRect) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetLeft)
---@return uiUnit left
function ScriptRegion:GetLeft() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetRect)
---@return uiUnit left
---@return uiUnit bottom
---@return uiUnit width
---@return uiUnit height
function ScriptRegion:GetRect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetRight)
---@return uiUnit right
function ScriptRegion:GetRight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetScaledRect)
---@return uiUnit left
---@return uiUnit bottom
---@return uiUnit width
---@return uiUnit height
function ScriptRegion:GetScaledRect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetScript)
---@param scriptTypeName ScriptType
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return luaFunction script
function ScriptRegion:GetScript(scriptTypeName, bindingType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetSize)
---@param ignoreRect? boolean Default = false
---@return uiUnit width
---@return uiUnit height
function ScriptRegion:GetSize(ignoreRect) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetSourceLocation)
---@return string location
function ScriptRegion:GetSourceLocation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetTop)
---@return uiUnit top
function ScriptRegion:GetTop() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_GetWidth)
---@param ignoreRect? boolean Default = false
---@return uiUnit width
function ScriptRegion:GetWidth(ignoreRect) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_HasScript)
---@param scriptName ScriptType
---@return boolean hasScript
function ScriptRegion:HasScript(scriptName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_Hide)
function ScriptRegion:Hide() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_HookScript)
---@param scriptTypeName ScriptType
---@param script luaFunction
---@param bindingType? LE_SCRIPT_BINDING_TYPE
function ScriptRegion:HookScript(scriptTypeName, script, bindingType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_Intersects)
---@param region ScriptRegion
---@return boolean intersects
function ScriptRegion:Intersects(region) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsAnchoringRestricted)
---@return boolean isRestricted
function ScriptRegion:IsAnchoringRestricted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsAnchoringSecret)
---@return boolean isSecret
function ScriptRegion:IsAnchoringSecret() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsCollapsed)
---@return boolean isCollapsed
function ScriptRegion:IsCollapsed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsDragging)
---@return boolean isDragging
function ScriptRegion:IsDragging() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsMouseClickEnabled)
---@return boolean enabled
function ScriptRegion:IsMouseClickEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsMouseEnabled)
---@return boolean enabled
function ScriptRegion:IsMouseEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsMouseMotionEnabled)
---@return boolean enabled
function ScriptRegion:IsMouseMotionEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsMouseMotionFocus)
---@return boolean isMouseMotionFocus
function ScriptRegion:IsMouseMotionFocus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsMouseOver)
---@param offsetTop? uiUnit Default = 0
---@param offsetBottom? uiUnit Default = 0
---@param offsetLeft? uiUnit Default = 0
---@param offsetRight? uiUnit Default = 0
---@return boolean isMouseOver
function ScriptRegion:IsMouseOver(offsetTop, offsetBottom, offsetLeft, offsetRight) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsMouseWheelEnabled)
---@return boolean enabled
function ScriptRegion:IsMouseWheelEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsProtected)
---@return boolean isProtected
---@return boolean isProtectedExplicitly
function ScriptRegion:IsProtected() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsRectValid)
---@return boolean isValid
function ScriptRegion:IsRectValid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsShown)
---@return boolean isShown
function ScriptRegion:IsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_IsVisible)
---@return boolean isVisible
function ScriptRegion:IsVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetCollapsesLayout)
---@param collapsesLayout boolean
function ScriptRegion:SetCollapsesLayout(collapsesLayout) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetMouseClickEnabled)
---@param enabled? boolean Default = false
function ScriptRegion:SetMouseClickEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetMouseMotionEnabled)
---@param enabled? boolean Default = false
function ScriptRegion:SetMouseMotionEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetParent)
---@param parent? SimpleFrame
function ScriptRegion:SetParent(parent) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetPassThroughButtons)
---@param ... MouseButton buttons
function ScriptRegion:SetPassThroughButtons(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetPropagateMouseClicks)
---@param propagate boolean
function ScriptRegion:SetPropagateMouseClicks(propagate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetPropagateMouseMotion)
---@param propagate boolean
function ScriptRegion:SetPropagateMouseMotion(propagate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetScript)
---@param scriptTypeName ScriptType
---@param script? luaFunction
function ScriptRegion:SetScript(scriptTypeName, script) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_SetShown)
---@param show? boolean Default = false
function ScriptRegion:SetShown(show) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_ShouldButtonPassThrough)
---@param button MouseButton
---@return boolean shouldPassThrough
function ScriptRegion:ShouldButtonPassThrough(button) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptRegion_Show)
function ScriptRegion:Show() end
