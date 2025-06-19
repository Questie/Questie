---@meta _
---@class AceLocale-3.0
local AceLocale = {}

---@param application string Unique name of addon / module
---@param silent? boolean If true, the locale is optional, silently return nil if it's not found (defaults to false, optional)
---@return table<string, string> locale The locale table for the current language.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-locale-3-0#title-1)
function AceLocale:GetLocale(application, silent) end

---@paramsig application, locale[, isDefault[, silent]]
---@param application string Unique name of addon / module
---@param locale AceLocale.LocaleCode Name of the locale to register, e.g. "enUS", "deDE", etc.
---@param isDefault? boolean If this is the default locale being registered. Your addon is written in this language, generally enUS, set this to true (defaults to false)
---@param silent? boolean If true, the locale will not issue warnings for missing keys. Must be `true` on the first locale registered. If set to "raw", nils will be returned for unknown keys (no metatable used).
---@return table<string, boolean|string>? locale Locale Table to add localizations to, or nil if the current locale is not required.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-locale-3-0#title-2)
function AceLocale:NewLocale(application, locale, isDefault, silent) end

---@alias AceLocale.LocaleCode
---|"deDE": German (Germany)
---|"enGB": English (Great Britain)
---|"enUS": English (America)
---|"esES": Spanish (Spain)
---|"esMX": Spanish (Mexico)
---|"frFR" French (France)
---|"itIT": Italian (Italy)
---|"koKR": Korean (Korea)
---|"ptBR": Portuguese (Brazil)
---|"ruRU": Russian (Russia)
---|"zhCN": Simplified Chinese (China)
---|"zhTW": Traditional Chinese (Taiwan)
