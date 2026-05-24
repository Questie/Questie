---@meta _
C_KeyBindings = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetBindingIndex)
---@param action string
---@return number? bindingIndex
function C_KeyBindings.GetBindingIndex(action) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_KeyBindings.GetCustomBindingType)
---@param bindingIndex number
---@return Enum.CustomBindingType? customBindingType
function C_KeyBindings.GetCustomBindingType(bindingIndex) end

---@alias InputCommandCallback FunctionContainer|fun(keystate: string)
