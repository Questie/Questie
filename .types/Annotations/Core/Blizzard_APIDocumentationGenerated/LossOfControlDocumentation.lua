---@meta _
C_LossOfControl = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LossOfControl.GetActiveLossOfControlData)
---@param index number
---@return LossOfControlData? event
function C_LossOfControl.GetActiveLossOfControlData(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LossOfControl.GetActiveLossOfControlDataByUnit)
---@param unitToken UnitToken
---@param index number
---@return LossOfControlData? event
function C_LossOfControl.GetActiveLossOfControlDataByUnit(unitToken, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LossOfControl.GetActiveLossOfControlDataCount)
---@return number count
function C_LossOfControl.GetActiveLossOfControlDataCount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LossOfControl.GetActiveLossOfControlDataCountByUnit)
---@param unitToken UnitToken
---@return number count
function C_LossOfControl.GetActiveLossOfControlDataCountByUnit(unitToken) end

---@class LossOfControlData
---@field locType string
---@field spellID number
---@field displayText string
---@field iconTexture number
---@field startTime number?
---@field timeRemaining number?
---@field duration number?
---@field lockoutSchool number
---@field priority number
---@field displayType number
---@field auraInstanceID number?
