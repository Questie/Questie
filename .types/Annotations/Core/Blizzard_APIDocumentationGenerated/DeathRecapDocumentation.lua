---@meta _
C_DeathRecap = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathRecap.GetRecapEvents)
---@param recapID? number
---@return DeathRecapEventInfo[] events
function C_DeathRecap.GetRecapEvents(recapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathRecap.GetRecapLink)
---@param recapID? number
---@return string link
function C_DeathRecap.GetRecapLink(recapID) end

---Returns the max health for the unit that died in the provided death recap.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathRecap.GetRecapMaxHealth)
---@param recapID? number
---@return number maxHealth
function C_DeathRecap.GetRecapMaxHealth(recapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathRecap.HasRecapEvents)
---@param recapID? number
---@return boolean hasEvents
function C_DeathRecap.HasRecapEvents(recapID) end

---@class DeathRecapEventInfo
