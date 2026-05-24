---@meta _
C_CooldownViewer = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetCooldownViewerCategorySet)
---@param category Enum.CooldownViewerCategory
---@param allowUnlearned? boolean Default = false
---@return number[] cooldownIDs
function C_CooldownViewer.GetCooldownViewerCategorySet(category, allowUnlearned) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetCooldownViewerCooldownInfo)
---@param cooldownID number
---@return CooldownViewerCooldown cooldownInfo
function C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetLayoutData)
---@return string data
function C_CooldownViewer.GetLayoutData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetValidAlertTypes)
---@param cooldownID number
---@return Enum.CooldownViewerAlertEventType[] validAlertTypes
function C_CooldownViewer.GetValidAlertTypes(cooldownID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.IsCooldownViewerAvailable)
---@return boolean isAvailable
---@return string failureReason
function C_CooldownViewer.IsCooldownViewerAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.SetLayoutData)
---@param data string
function C_CooldownViewer.SetLayoutData(data) end

---@class CooldownViewerCooldown
---@field cooldownID number
---@field spellID number
---@field overrideSpellID number?
---@field overrideTooltipSpellID number?
---@field linkedSpellIDs number[]
---@field selfAura boolean
---@field hasAura boolean
---@field charges boolean
---@field isKnown boolean
---@field flags Enum.CooldownSetSpellFlags
---@field category Enum.CooldownViewerCategory
