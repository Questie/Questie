---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAvailableLocaleInfo)
---@param ignoreLocaleRestrictions? boolean Default = false
---@return LocaleInfo[] localeInfos
function GetAvailableLocaleInfo(ignoreLocaleRestrictions) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAvailableLocales)
---@param ignoreLocaleRestrictions? boolean Default = false
---@return string ... localeName
function GetAvailableLocales(ignoreLocaleRestrictions) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCurrentRegion)
---@return number region
function GetCurrentRegion() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetLocale)
---@return string localeName
function GetLocale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetOSLocale)
---@return string localeName
function GetOSLocale() end

---@class LocaleInfo
---@field localeId number
---@field localeName string
