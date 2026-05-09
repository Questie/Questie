---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_DestroyTotem)
---@param slot number
function DestroyTotem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetTotemCannotDismiss)
---@param slot number
---@return boolean? cannotDismiss
function GetTotemCannotDismiss(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetTotemInfo)
---@param slot number
---@return boolean haveTotem
---@return string totemName
---@return number startTime
---@return number duration
---@return fileID icon
---@return number modRate
---@return number spellID
function GetTotemInfo(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetTotemTimeLeft)
---@param slot number
---@return number? timeLeft
function GetTotemTimeLeft(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TargetTotem)
---@param slot number
function TargetTotem(slot) end

---@class TotemInfoScript
---@field haveTotem boolean
---@field totemName string
---@field startTime number
---@field duration number
---@field icon fileID
---@field modRate number
---@field spellID number
