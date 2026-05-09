---@meta _
C_Navigation = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Navigation.GetDistance)
---@return number distance
function C_Navigation.GetDistance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Navigation.GetFrame)
---@return ScriptRegion? frame
function C_Navigation.GetFrame() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Navigation.GetNearestPartyMemberToken)
---@return string unitToken
function C_Navigation.GetNearestPartyMemberToken() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Navigation.GetTargetState)
---@return Enum.NavigationState state
function C_Navigation.GetTargetState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Navigation.HasValidScreenPosition)
---@return boolean hasValidScreenPosition
function C_Navigation.HasValidScreenPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Navigation.WasClampedToScreen)
---@return boolean wasClamped
function C_Navigation.WasClampedToScreen() end
