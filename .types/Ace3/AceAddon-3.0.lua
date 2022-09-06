---@meta
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
---@class AceAddon-3.0
local lib = {}

---@param name string
---@param silent? boolean
---@return AceAddon
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-15)
function lib:GetAddon(name, silent) end

---@return function iter
---@return table invariant
---@return number init
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-16)
function lib:IterateAddonStatus() end

---@return function iter
---@return table invariant
---@return number init
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-17)
function lib:IterateAddons() end

---@param object table
---@param name string
---@param ... string List of libraries to embed into the addon
---@return AceAddon
---@overload fun(self, name: string, ...: string)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-18)
function lib:NewAddon(object, name, ...) end

---@class AceAddon
local addon = {}

---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-2)
function addon:Disable() end

---@return boolean
---@param name string
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-3)
function addon:DisableModule(name) end

---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-4)
function addon:Enable() end

---@param name string
---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-5)
function addon:EnableModule(name) end

---@param name string
---@param silent? boolean
---@return table module
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-6)
function addon:GetModule(name, silent) end

---@return string name
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-7)
function addon:GetName() end

---@return boolean enabled
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-8)
function addon:IsEnabled() end

---@return function iter
---@return table invariant
---@return number init
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-9)
function addon:IterateModules() end

---@param name string
---@param ... string List of libraries to embed into the addon
---@overload fun(self, name: string, prototype: table, ...: string)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-10)
function addon:NewModule(name, ...) end

---@param ... string List of libraries to embed into the addon
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-11)
function addon:SetDefaultModuleLibraries(...) end

---@param prototype table
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-12)
function addon:SetDefaultModulePrototype(prototype) end

---@param state boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-13)
function addon:SetDefaultModuleState(state) end

---@param state boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-14)
function addon:SetEnabledState(state) end
