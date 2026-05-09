---@meta _
C_AssistedCombat = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.GetActionSpell)
---@return number? spellID
function C_AssistedCombat.GetActionSpell() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.GetNextCastSpell)
---@param checkForVisibleButton? boolean Default = false
---@return number? spellID
function C_AssistedCombat.GetNextCastSpell(checkForVisibleButton) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.GetRotationSpells)
---@return number[] spellIDs
function C_AssistedCombat.GetRotationSpells() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AssistedCombat.IsAvailable)
---@return boolean isAvailable
---@return string failureReason
function C_AssistedCombat.IsAvailable() end
