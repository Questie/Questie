---@meta _
C_CombatLogSecure = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.AddEventFilter)
function C_CombatLogSecure.AddEventFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.ClearEventFilters)
function C_CombatLogSecure.ClearEventFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.CreateCombatLogMessage)
---@param message string
---@param colorR number
---@param colorG number
---@param colorB number
---@param order Enum.CombatLogMessageOrder
function C_CombatLogSecure.CreateCombatLogMessage(message, colorR, colorG, colorB, order) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.GetCurrentEntryInfo)
function C_CombatLogSecure.GetCurrentEntryInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.GetCurrentEventInfo)
function C_CombatLogSecure.GetCurrentEventInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.GetEntryCount)
---@param ignoreFilter? boolean Default = false
---@return number count
function C_CombatLogSecure.GetEntryCount(ignoreFilter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.SeekToNewestEntry)
---@param ignoreFilter? boolean Default = false
---@return boolean isValidEntry
function C_CombatLogSecure.SeekToNewestEntry(ignoreFilter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.SeekToPreviousEntry)
---@param ignoreFilter? boolean Default = false
---@return boolean isValidEntry
function C_CombatLogSecure.SeekToPreviousEntry(ignoreFilter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLogSecure.ShouldShowCurrentEntry)
---@return boolean shouldShow
function C_CombatLogSecure.ShouldShowCurrentEntry() end
