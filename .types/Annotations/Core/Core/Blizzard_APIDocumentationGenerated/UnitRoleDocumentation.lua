---@meta _
---If true, UnitGetAvailableRoles results should be treated as suggested role, not hard limits on what role the current player can display as.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_AreClassRolesSoftSuggestions)
---@return boolean result
function AreClassRolesSoftSuggestions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanShowSetRoleButton)
---@return boolean result
function CanShowSetRoleButton() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_InitiateRolePoll)
---@return boolean result
function InitiateRolePoll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGetAvailableRoles)
---@param unit UnitToken
---@return boolean tank
---@return boolean healer
---@return boolean dps
function UnitGetAvailableRoles(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSetRole)
---@param unit UnitToken
---@param roleStr? string
---@return boolean result
function UnitSetRole(unit, roleStr) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSetRoleEnum)
---@param unit UnitToken
---@param role? Enum.LFGRole
---@return boolean result
function UnitSetRoleEnum(unit, role) end
