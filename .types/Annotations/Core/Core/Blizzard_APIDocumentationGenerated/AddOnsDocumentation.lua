---@meta _
C_AddOns = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.DisableAddOn)
---@param name uiAddon
---@param character? string Default = 0
function C_AddOns.DisableAddOn(name, character) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.DisableAllAddOns)
---@param character? string
function C_AddOns.DisableAllAddOns(character) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.DoesAddOnExist)
---@param name uiAddon
---@return boolean exists
function C_AddOns.DoesAddOnExist(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.DoesAddOnHaveLoadError)
---@param name uiAddon
---@return boolean hadError
function C_AddOns.DoesAddOnHaveLoadError(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.EnableAddOn)
---@param name uiAddon
---@param character? string Default = 0
function C_AddOns.EnableAddOn(name, character) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.EnableAllAddOns)
---@param character? string
function C_AddOns.EnableAllAddOns(character) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnDependencies)
---@param name uiAddon
---@return string ... deps
function C_AddOns.GetAddOnDependencies(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnEnableState)
---@param name uiAddon
---@param character? string Default = 0
---@return Enum.AddOnEnableState state
function C_AddOns.GetAddOnEnableState(name, character) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnInfo)
---@param name uiAddon
---@return string name
---@return string title
---@return string notes
---@return boolean loadable
---@return string reason
---@return string security
function C_AddOns.GetAddOnInfo(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnInterfaceVersion)
---@param name uiAddon
---@return number interfaceVersion
function C_AddOns.GetAddOnInterfaceVersion(name) end

---Returns the addon table (passed as the second argument of ... to files) for any addon that opts in through setting AllowAddOnTableAccess: 1 in the toc file. Insecure code cannot query addon tables from Blizzard addons.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnLocalTable)
---@param name uiAddon
---@return LuaValueVariant table
function C_AddOns.GetAddOnLocalTable(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnMetadata)
---@param name uiAddon
---@param variable string
---@return string value
function C_AddOns.GetAddOnMetadata(name, variable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnName)
---@param index uiAddon
---@return string name
function C_AddOns.GetAddOnName(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnNotes)
---@param name uiAddon
---@return string notes
function C_AddOns.GetAddOnNotes(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnOptionalDependencies)
---@param name uiAddon
---@return string ... deps
function C_AddOns.GetAddOnOptionalDependencies(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnSecurity)
---@param name uiAddon
---@return Enum.AddOnSecurityStatus security
function C_AddOns.GetAddOnSecurity(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnTitle)
---@param name uiAddon
---@return string title
function C_AddOns.GetAddOnTitle(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetNumAddOns)
---@return number numAddOns
function C_AddOns.GetNumAddOns() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.GetScriptsDisallowedForBeta)
---@return boolean disallowed
function C_AddOns.GetScriptsDisallowedForBeta() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.IsAddOnDefaultEnabled)
---@param name uiAddon
---@return boolean defaultEnabled
function C_AddOns.IsAddOnDefaultEnabled(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.IsAddOnLoadOnDemand)
---@param name uiAddon
---@return boolean loadOnDemand
function C_AddOns.IsAddOnLoadOnDemand(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.IsAddOnLoadable)
---@param name uiAddon
---@param character? string Default = 0
---@param demandLoaded? boolean Default = false
---@return boolean loadable
---@return string reason
function C_AddOns.IsAddOnLoadable(name, character, demandLoaded) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.IsAddOnLoaded)
---@param name uiAddon
---@return boolean loadedOrLoading
---@return boolean loaded
function C_AddOns.IsAddOnLoaded(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.IsAddonVersionCheckEnabled)
---@return boolean isEnabled
function C_AddOns.IsAddonVersionCheckEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.LoadAddOn)
---@param name uiAddon
---@return boolean? loaded
---@return string? value
function C_AddOns.LoadAddOn(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.ResetAddOns)
function C_AddOns.ResetAddOns() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.ResetDisabledAddOns)
function C_AddOns.ResetDisabledAddOns() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.SaveAddOns)
function C_AddOns.SaveAddOns() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOns.SetAddonVersionCheck)
---@param enabled boolean
function C_AddOns.SetAddonVersionCheck(enabled) end

---@class AddOnInfo
---@field name string
---@field title string
---@field notes string
---@field loadable boolean
---@field reason string
---@field security string

---@class AddOnLoadableInfo
---@field loadable boolean
---@field reason string
