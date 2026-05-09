---@meta _
C_Log = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Log.LogErrorMessage)
---@param message string
function C_Log.LogErrorMessage(message) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Log.LogMessage)
---@param message string
function C_Log.LogMessage(message) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Log.LogMessageWithPriority)
---@param priority Enum.LogPriority
---@param message string
function C_Log.LogMessageWithPriority(priority, message) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Log.LogWarningMessage)
---@param message string
function C_Log.LogWarningMessage(message) end
