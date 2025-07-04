---@meta _
-- ----------------------------------------------------------------------------
-- Type Aliases
-- ----------------------------------------------------------------------------

--- The AceConfig UI Type
---@alias AceConfigRegistry.UIType
---|"cmd"
---|"dialog"
---|"dropdown"

---@alias AceConfigRegistry.OptionsGenerator fun(uiType: AceConfigRegistry.UIType, uiName: string, appName: string): table
---@alias AceConfigRegistry.OptionsGetter fun(uiType: AceConfigRegistry.UIType, uiName: string, errlvl?: number): table

-- ----------------------------------------------------------------------------
-- AceConfigRegistry-3.0
-- ----------------------------------------------------------------------------

---@class AceConfigRegistry-3.0
local lib = {}

--- Query the registry for a specific options table. 
---
--- If only appName is given, a function is returned which you can call with (uiType,uiName) to get the table.
---
--- If uiType&uiName are given, the table is returned.
---@param appName string The application name as given to `:RegisterOptionsTable()`
---@param uiType? AceConfigRegistry.UIType The type of UI to get the table for
---@param uiName? string The name of the library/addon querying for the table, e.g. "MyLib-1.0"
---@return AceConfigRegistry.OptionsGetter|table|nil
function lib:GetOptionsTable(appName, uiType, uiName) end

--- Returns an iterator of ["appName"]=funcref pairs
---@generic T: table, K: string, V: AceConfigRegistry.OptionsGetter
---@return fun(table: table<K, V>, index?: K):K, V
---@return T
function lib:IterateOptionsTables() end

--- Fires a "ConfigTableChange" callback for those listening in on it, allowing config GUIs to refresh. 
---
--- You should call this function if your options table changed from any outside event, like a game event or a timer.
---@param appName string The application name as given to `:RegisterOptionsTable()`
function lib:NotifyChange(appName) end

--- Register an options table with the config registry.
---@param appName string The application name
---@param options AceConfigRegistry.OptionsGenerator|table The options table, OR a function reference that generates it on demand. 
---@param skipValidation? boolean Skip options table validation (primarily useful for extremely huge options, with a noticeable slowdown)
function lib:RegisterOptionsTable(appName, options, skipValidation) end

--- Validates basic structure and integrity of an options table 
---
--- Does NOT verify that get/set etc actually exist, since they can be defined at any depth
---@param options table The table to be validated
---@param name string The name of the table to be validated (shown in any error message)
---@param errlvl? number Error level offset, default 0 (=errors point to the function calling :ValidateOptionsTable)
function lib:ValidateOptionsTable(options, name, errlvl) end
