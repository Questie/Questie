---@meta _
C_KeyBindings = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.ActivateBindingContext)
---@param newContext Enum.BindingContext
function C_KeyBindings.ActivateBindingContext(newContext) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.DeactivateBindingContext)
---@param context Enum.BindingContext
function C_KeyBindings.DeactivateBindingContext(context) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetBindingByKey)
---@param action string
---@param context? Enum.BindingContext
---@return string binding
function C_KeyBindings.GetBindingByKey(action, context) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetBindingContextForAction)
---@param action string
---@return Enum.BindingContext? context
function C_KeyBindings.GetBindingContextForAction(action) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetBindingIndex)
---@param action string
---@return number? bindingIndex
function C_KeyBindings.GetBindingIndex(action) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetCustomBindingType)
---@param bindingIndex number
---@return Enum.CustomBindingType? customBindingType
function C_KeyBindings.GetCustomBindingType(bindingIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetSearchTagsForAction)
---@param action string
---@return string[]? searchTags
function C_KeyBindings.GetSearchTagsForAction(action) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetTurnStrafeStyle)
---@return Enum.TurnStrafeStyle style
function C_KeyBindings.GetTurnStrafeStyle() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.IsBindingContextActive)
---@param context Enum.BindingContext
---@return boolean isActive
function C_KeyBindings.IsBindingContextActive(context) end

---Can only set to Modern or Legacy.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.SetTurnStrafeStyle)
---@param style Enum.TurnStrafeStyle
function C_KeyBindings.SetTurnStrafeStyle(style) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.UpdateTurnStrafeBindingsForCharacter)
function C_KeyBindings.UpdateTurnStrafeBindingsForCharacter() end

---@alias InputCommandCallback FunctionContainer|fun(keystate: string)
