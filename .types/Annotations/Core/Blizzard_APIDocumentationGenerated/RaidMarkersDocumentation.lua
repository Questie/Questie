---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CanBeRaidTarget)
---@param target UnitToken
---@return boolean result
function CanBeRaidTarget(target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClearRaidMarker)
---@param raidMarkerIndex number
function ClearRaidMarker(raidMarkerIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRaidTargetIndex)
---@param target UnitToken
---@return number? result
function GetRaidTargetIndex(target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRaidMarkerActive)
---@param index number
---@return boolean result
function IsRaidMarkerActive(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRaidMarkerSystemEnabled)
---@return boolean enabled
function IsRaidMarkerSystemEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlaceRaidMarker)
---@param index number
---@param token? string
function PlaceRaidMarker(index, token) end

---Removes all assigned raid target markers.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_RemoveRaidTargets)
function RemoveRaidTargets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetRaidTarget)
---@param target UnitToken
---@param userIndex number
function SetRaidTarget(target, userIndex) end
