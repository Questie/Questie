---@meta _
C_ZoneAbility = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ZoneAbility.GetActiveAbilities)
---@return ZoneAbilityInfo[] zoneAbilities
function C_ZoneAbility.GetActiveAbilities() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ZoneAbility.GetZoneAbilityIcon)
---@param zoneAbilitySpellID number
---@return number? zoneAbilityIconID
function C_ZoneAbility.GetZoneAbilityIcon(zoneAbilitySpellID) end

---@class ZoneAbilityInfo
---@field zoneAbilityID number
---@field uiPriority number
---@field spellID number
---@field textureKit textureKit
---@field tutorialText string?
