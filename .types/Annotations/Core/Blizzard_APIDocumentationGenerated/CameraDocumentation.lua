---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCameraFOVDefaults)
---@return number fieldOfViewDegreesDefault
---@return number fieldOfViewDegreesPlayerMin
---@return number fieldOfViewDegreesPlayerMax
function GetCameraFOVDefaults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUICameraInfo)
---@param uiCameraID number
---@return number posX
---@return number posY
---@return number posZ
---@return number lookAtX
---@return number lookAtY
---@return number lookAtZ
---@return number animID
---@return number animVariation
---@return number animFrame
---@return boolean useModelCenter
function GetUICameraInfo(uiCameraID) end
