---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetBuildInfo)
---@return string buildVersion
---@return string buildNumber
---@return string buildDate
---@return number interfaceVersion
---@return string localizedVersion
---@return string buildInfo
function GetBuildInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Is64BitClient)
---@return boolean is64Bit
function Is64BitClient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsBetaBuild)
---@return boolean isBetaBuild
function IsBetaBuild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsDebugBuild)
---@return boolean isDebugBuild
function IsDebugBuild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLinuxClient)
---@return boolean isLinux
function IsLinuxClient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsMacClient)
---@return boolean isMac
function IsMacClient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsPublicBuild)
---@return boolean isPublicBuild
function IsPublicBuild() end

---Reflects the state of the OnlyBetaAndPTR TOC directive
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_IsPublicTestClient)
---@return boolean isPublicTestClient
function IsPublicTestClient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsTestBuild)
---@return boolean isTestBuild
function IsTestBuild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsWindowsClient)
---@return boolean isWindows
function IsWindowsClient() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SupportsClipCursor)
---@return boolean supportsClipCursor
function SupportsClipCursor() end
