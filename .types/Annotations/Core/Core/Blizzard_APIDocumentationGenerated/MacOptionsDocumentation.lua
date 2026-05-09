---@meta _
C_MacOptions = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.AreOSShortcutsDisabled)
---@return boolean? osShortcutsDisabledCVar
---@return boolean osShortcutsDisabled
function C_MacOptions.AreOSShortcutsDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.GetGameBundleName)
---@return string result
function C_MacOptions.GetGameBundleName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.HasNewStyleInputMonitoring)
---@return boolean result
function C_MacOptions.HasNewStyleInputMonitoring() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.IsInputMonitoringEnabled)
---@return boolean result
function C_MacOptions.IsInputMonitoringEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.IsMicrophoneEnabled)
---@return boolean result
function C_MacOptions.IsMicrophoneEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.IsUniversalAccessEnabled)
---@return boolean result
function C_MacOptions.IsUniversalAccessEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.OpenInputMonitoring)
function C_MacOptions.OpenInputMonitoring() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.OpenMicrophoneRequestDialogue)
function C_MacOptions.OpenMicrophoneRequestDialogue() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.OpenUniversalAccess)
function C_MacOptions.OpenUniversalAccess() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MacOptions.SetOSShortcutsDisabled)
---@param disable boolean
function C_MacOptions.SetOSShortcutsDisabled(disable) end
