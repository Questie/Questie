---@meta _
C_AutoComplete = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AutoComplete.GetAutoCompletePresenceID)
---@param name string
---@return number? presenceID
function C_AutoComplete.GetAutoCompletePresenceID(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AutoComplete.GetAutoCompleteRealms)
---@return string[] realms
function C_AutoComplete.GetAutoCompleteRealms() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AutoComplete.GetAutoCompleteResults)
---@param name string
---@param numResults number
---@param cursorPosition number
---@param allowFullMatch boolean
---@param includeFlags number
---@param excludeFlags number
---@return AutoCompleteResult[] results
function C_AutoComplete.GetAutoCompleteResults(name, numResults, cursorPosition, allowFullMatch, includeFlags, excludeFlags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AutoComplete.IsRecognizedName)
---@param name string
---@param includeFlags number
---@param excludeFlags number
---@return boolean isRecognizedName
function C_AutoComplete.IsRecognizedName(name, includeFlags, excludeFlags) end

---@class AutoCompleteResult
---@field name string
---@field priority Enum.AutoCompletePriority
---@field bnetID number
