---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_BreakUpLargeNumbers)
---@param largeNumber number
---@param natural? boolean Default = false
---@return string result
function BreakUpLargeNumbers(largeNumber, natural) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CaseAccentInsensitiveParse)
---@param name string
---@return string result
function CaseAccentInsensitiveParse(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DeclineName)
---@param name string
---@param gender? Enum.UnitSex
---@param declensionSet number
---@return string ... declinedNames
function DeclineName(name, gender, declensionSet) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumDeclensionSets)
---@param name string
---@param gender? Enum.UnitSex
---@return number numDeclensionSets
function GetNumDeclensionSets(name, gender) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsEuropeanNumbers)
---@return boolean enabled
function IsEuropeanNumbers() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_LocalizedClassList)
---@param isFemale? boolean Default = false
---@return LuaValueVariant result
function LocalizedClassList(isFemale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetEuropeanNumbers)
---@param enabled boolean
function SetEuropeanNumbers(enabled) end
