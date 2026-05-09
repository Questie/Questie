---@meta _
C_PlayerInteractionManager = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.ClearInteraction)
---@param type? Enum.PlayerInteractionType
function C_PlayerInteractionManager.ClearInteraction(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.ConfirmationInteraction)
---@param type? Enum.PlayerInteractionType
function C_PlayerInteractionManager.ConfirmationInteraction(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.InteractUnit)
---@param unit string
---@param exactMatch? boolean Default = false
---@param looseTargeting? boolean Default = true
---@return boolean success
function C_PlayerInteractionManager.InteractUnit(unit, exactMatch, looseTargeting) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.IsInteractingWithNpcOfType)
---@param type Enum.PlayerInteractionType
---@return boolean interacting
function C_PlayerInteractionManager.IsInteractingWithNpcOfType(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.IsReplacingUnit)
---@return boolean replacing
function C_PlayerInteractionManager.IsReplacingUnit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.IsValidNPCInteraction)
---@param type Enum.PlayerInteractionType
---@return boolean isValidInteraction
function C_PlayerInteractionManager.IsValidNPCInteraction(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInteractionManager.ReopenInteraction)
function C_PlayerInteractionManager.ReopenInteraction() end
