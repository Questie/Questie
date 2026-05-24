---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_FlashClientIcon)
---@param briefly? boolean Default = false
function FlashClientIcon(briefly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetBillingTimeRested)
---@return number billingTimeRested
function GetBillingTimeRested() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFileIDFromPath)
---@param filePath string
---@return fileID fileID
function GetFileIDFromPath(filePath) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFramerate)
---@return number framerate
function GetFramerate() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsCpuBound)
---@return boolean? isCpuBound
function IsCpuBound() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ReportBug)
---@param description string
function ReportBug(description) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ReportSuggestion)
---@param description string
function ReportSuggestion(description) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RestartGx)
function RestartGx() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Screenshot)
function Screenshot() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UpdateWindow)
function UpdateWindow() end
