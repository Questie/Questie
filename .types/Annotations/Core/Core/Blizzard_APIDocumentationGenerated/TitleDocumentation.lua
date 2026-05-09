---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCurrentTitle)
---@return number result
function GetCurrentTitle() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumTitles)
---@return number result
function GetNumTitles() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetTitleName)
---@param titleMaskID number
---@return string titleString
---@return boolean playerTitle
function GetTitleName(titleMaskID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsTitleKnown)
---@param titleMaskID number
---@return boolean result
function IsTitleKnown(titleMaskID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetCurrentTitle)
---@param titleMaskID number
function SetCurrentTitle(titleMaskID) end
