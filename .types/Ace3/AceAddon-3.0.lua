---@meta _

-- ----------------------------------------------------------------------------
-- AceAddon-3.0
-- ----------------------------------------------------------------------------

---@class AceAddon-3.0
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
local lib = {}

---@param name string
---@param silent? boolean
---@return AceAddon
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-15)
function lib:GetAddon(name, silent) end

---@return function iter
---@return table invariant
---@return number init
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-16)
function lib:IterateAddonStatus() end

---@return function iter
---@return table invariant
---@return number init
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-17)
function lib:IterateAddons() end

---@param object table
---@param name string
---@param ...? string List of libraries to embed into the addon
---@return table|AceAddon
---@overload fun(self, name: string, ...: string): table|AceAddon
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-18)
function lib:NewAddon(object, name, ...) end

-- ----------------------------------------------------------------------------
-- AceAddon
-- ----------------------------------------------------------------------------

---@class AceAddon
---@field defaultModuleLibraries table
---@field defaultModuleState boolean
---@field enabledState boolean
---@field modules { [string]: AceModule }
---@field name string
---@field orderedModules AceModule[]
local addon = {}

-- Disables the Addon, if possible.
---@return boolean success
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-2)
function addon:Disable() end

-- Disables the Module, if possible.
---@param name string
---@return boolean success
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-3)
function addon:DisableModule(name) end

-- Enables the Addon, if possible.
---@return boolean success
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-4)
function addon:Enable() end

-- Enables the Module, if possible.
---@param name string
---@return boolean success
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-5)
function addon:EnableModule(name) end

-- Return the specified module from an Addon object.
---@param name string Unique name of the Module
---@param silent? boolean If true, the module is optional. Silently return nil if its not found.
---@return AceModule module
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-6)
function addon:GetModule(name, silent) end

-- Returns the real name of the Addon or Module, without any prefix.
---@return string name
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-7)
function addon:GetName() end

-- Query the enabledState of an Addon.
---@return boolean enabled
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-8)
function addon:IsEnabled() end

-- Returns whether or not the object is a Module.
---@return boolean isModule
function addon:IsModule() end

-- Return an iterator of all modules associated to the addon.
---@return function iter
---@return table invariant
---@return number init
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-9)
function addon:IterateModules() end

-- Create a new module for the addon.
--
-- The new module can have its own embeded libraries and/or use a module prototype to be mixed into the module.
--
-- A module has the same functionality as a real addon, it can have modules of its own, and has the same API as an addon object.
---@param name string
---@param ... string List of libraries to embed into the addon
---@return AceModule
---@overload fun(self, name: string, prototype: table, ...: string)
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-10)
function addon:NewModule(name, ...) end

-- dont define .OnInitialize, .OnEnable, .OnDisable since this would trigger `duplicate-set-field` diagnostic
-- those methods technically only exist when defined by the user

-- Callback function called when your addon is manually being disabled.
-- function addon:OnDisable() end

-- Callback function called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
-- function addon:OnEnable() end

-- Callback function called directly after the addon is fully loaded.
-- function addon:OnInitialize() end

-- Set the default libraries to be mixed into all modules created by this object.
--
-- Note that you can only change the default module libraries before any module is created.
---@param ... string List of libraries to embed into the addon
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-11)
function addon:SetDefaultModuleLibraries(...) end

-- Set the default prototype to use for new modules on creation.
--
-- Note that you can only change the default prototype before any module is created.
---@param prototype table
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-12)
function addon:SetDefaultModulePrototype(prototype) end

-- Set the default state in which new modules are being created.
--
-- Note that you can only change the default state before any module is created.
---@param state boolean
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-13)
function addon:SetDefaultModuleState(state) end

-- Set the state of an addon or module This should only be called before any enabling actually happend, e.g. in/before OnInitialize.
---@param state boolean
--
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0#title-14)
function addon:SetEnabledState(state) end

-- ----------------------------------------------------------------------------
-- AceModule
-- ----------------------------------------------------------------------------

---@class AceModule : AceAddon
---@field moduleName string
local module = {}
