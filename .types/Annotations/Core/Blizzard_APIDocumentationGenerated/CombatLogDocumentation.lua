---@meta _
C_CombatLog = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.ApplyFilterSettings)
---@param filterSettings LuaValueVariant
function C_CombatLog.ApplyFilterSettings(filterSettings) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.AreFilteredEventsEnabled)
---@return boolean enabled
function C_CombatLog.AreFilteredEventsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.ClearEntries)
function C_CombatLog.ClearEntries() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.DoesObjectMatchFilter)
---@param mask Enum.CombatLogObject
---@param flags Enum.CombatLogObject
---@return boolean matches
function C_CombatLog.DoesObjectMatchFilter(mask, flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.GetEntryRetentionTime)
---@return number retentionTime
function C_CombatLog.GetEntryRetentionTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.GetMessageLimit)
---@return number messageLimit
function C_CombatLog.GetMessageLimit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.IsCombatLogRestricted)
---@return boolean restricted
function C_CombatLog.IsCombatLogRestricted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.RefilterEntries)
function C_CombatLog.RefilterEntries() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.SetEntryRetentionTime)
---@param retentionTime number
function C_CombatLog.SetEntryRetentionTime(retentionTime) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.SetFilteredEventsEnabled)
---@param enabled boolean
function C_CombatLog.SetFilteredEventsEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CombatLog.SetMessageLimit)
---@param messageLimit number
function C_CombatLog.SetMessageLimit(messageLimit) end
