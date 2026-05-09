---@meta _
C_CooldownViewer = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetCooldownViewerCategorySet)
---@param category Enum.CooldownViewerCategory
---@return number[] cooldownIDs
function C_CooldownViewer.GetCooldownViewerCategorySet(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.GetCooldownViewerCooldownInfo)
---@param cooldownID number
---@return CooldownViewerCooldown cooldownInfo
function C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CooldownViewer.IsCooldownViewerAvailable)
---@return boolean isAvailable
---@return string failureReason
function C_CooldownViewer.IsCooldownViewerAvailable() end

---@class CooldownViewerCooldown
---@field spellID number
---@field overrideSpellID number?
---@field linkedSpellIDs number[]
---@field selfAura boolean
---@field hasAura boolean
---@field charges boolean
---@field flags Enum.CooldownSetSpellFlags
