---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAddOnCPUUsage)
---@param name uiAddon
---@return number result
function GetAddOnCPUUsage(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAddOnMemoryUsage)
---@param name uiAddon
---@return number result
function GetAddOnMemoryUsage(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFrameCPUUsage)
---@param frame SimpleFrame
---@param includeChildren? boolean Default = false
---@return number call_time
---@return number call_count
function GetFrameCPUUsage(frame, includeChildren) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResetCPUUsage)
function ResetCPUUsage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UpdateAddOnCPUUsage)
function UpdateAddOnCPUUsage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UpdateAddOnMemoryUsage)
function UpdateAddOnMemoryUsage() end
