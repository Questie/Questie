---@meta _
C_Secrets = {}

---Queries the base secrecy for a power type.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.GetPowerTypeSecrecy)
---@param powerType Enum.PowerType
---@return Enum.SecrecyLevel secrecy
function C_Secrets.GetPowerTypeSecrecy(powerType) end

---Queries the base secrecy for a spell if queried as an aura.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.GetSpellAuraSecrecy)
---@param spellIdentifier SpellIdentifier
---@return Enum.SecrecyLevel secrecy
function C_Secrets.GetSpellAuraSecrecy(spellIdentifier) end

---Queries the base secrecy for a spell if queried as a cast.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.GetSpellCastSecrecy)
---@param spellIdentifier SpellIdentifier
---@return Enum.SecrecyLevel secrecy
function C_Secrets.GetSpellCastSecrecy(spellIdentifier) end

---Queries the base secrecy for a spell if queried as a cooldown.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.GetSpellCooldownSecrecy)
---@param spellIdentifier SpellIdentifier
---@return Enum.SecrecyLevel secrecy
function C_Secrets.GetSpellCooldownSecrecy(spellIdentifier) end

---Returns true if this client build has secret value restrictions enabled. If false, all APIs that are tagged as potentially returning secrets will never do so.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.HasSecretRestrictions)
---@return boolean hasSecretRestrictions
function C_Secrets.HasSecretRestrictions() end

---Returns true if a given action bar slot ID will produce secret values for cooldowns if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldActionCooldownBeSecret)
---@param actionID number
---@return boolean isCooldownSecret
function C_Secrets.ShouldActionCooldownBeSecret(actionID) end

---Returns true if queries for aura data will generally produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldAurasBeSecret)
---@return boolean hasSecretAuras
function C_Secrets.ShouldAurasBeSecret() end

---Returns true if queries for cooldown data will generally produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldCooldownsBeSecret)
---@return boolean hasSecretCooldowns
function C_Secrets.ShouldCooldownsBeSecret() end

---Returns true if a given spell identifier would, if applied as an aura, produce secret values when queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldSpellAuraBeSecret)
---@param spellIdentifier SpellIdentifier
---@return boolean isAuraSecret
function C_Secrets.ShouldSpellAuraBeSecret(spellIdentifier) end

---Returns true if a given spellbook item will produce secret values for cooldowns if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldSpellBookItemCooldownBeSecret)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return boolean isCooldownSecret
function C_Secrets.ShouldSpellBookItemCooldownBeSecret(spellBookItemSlotIndex, spellBookItemSpellBank) end

---Returns true if a given spell identifier will produce secret values for cooldowns if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldSpellCooldownBeSecret)
---@param spellIdentifier SpellIdentifier
---@return boolean isCooldownSecret
function C_Secrets.ShouldSpellCooldownBeSecret(spellIdentifier) end

---Returns true if information about a totem slot will produce secret values if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldTotemSlotBeSecret)
---@param slot number
---@return boolean isTotemSecret
function C_Secrets.ShouldTotemSlotBeSecret(slot) end

---Returns true if information about a spell when associated with a totem slot will produce secret values if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldTotemSpellBeSecret)
---@param spellID number
---@return boolean isTotemSecret
function C_Secrets.ShouldTotemSpellBeSecret(spellID) end

---Returns true if a given aura index will produce secret values if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitAuraIndexBeSecret)
---@param unit UnitToken
---@param index number
---@param filter? AuraFilters
---@return boolean isAuraSecret
function C_Secrets.ShouldUnitAuraIndexBeSecret(unit, index, filter) end

---Returns true if a given aura instance ID will produce secret values if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitAuraInstanceBeSecret)
---@param unit UnitToken
---@param auraInstanceID number
---@return boolean isAuraSecret
function C_Secrets.ShouldUnitAuraInstanceBeSecret(unit, auraInstanceID) end

---Returns true if a given aura slot ID will produce secret values if queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitAuraSlotBeSecret)
---@param unit UnitToken
---@param slot number
---@return boolean isAuraSecret
function C_Secrets.ShouldUnitAuraSlotBeSecret(unit, slot) end

---Returns true if queries that compare units will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitComparisonBeSecret)
---@param unit1 UnitToken
---@param unit2 UnitToken
---@return boolean isUnitComparisonSecret
function C_Secrets.ShouldUnitComparisonBeSecret(unit1, unit2) end

---Returns true if queries for maximum unit health will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitHealthMaxBeSecret)
---@param unit UnitToken
---@return boolean isUnitHealthMaxSecret
function C_Secrets.ShouldUnitHealthMaxBeSecret(unit) end

---Returns true if queries for unit identity (such as name or GUID) will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitIdentityBeSecret)
---@param unit UnitToken
---@return boolean isUnitIdentitySecret
function C_Secrets.ShouldUnitIdentityBeSecret(unit) end

---Returns true if queries for unit power will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitPowerBeSecret)
---@param unit UnitToken
---@param powerType? Enum.PowerType
---@return boolean isUnitPowerSecret
function C_Secrets.ShouldUnitPowerBeSecret(unit, powerType) end

---Returns true if queries for maximum unit power will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitPowerMaxBeSecret)
---@param unit UnitToken
---@param powerType? Enum.PowerType
---@return boolean isUnitPowerMaxSecret
function C_Secrets.ShouldUnitPowerMaxBeSecret(unit, powerType) end

---Returns true if queries for spell casting information for a unit would produce secret values when queried.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitSpellCastBeSecret)
---@param unit UnitToken
---@param spellIdentifier SpellIdentifier
---@return boolean isSpellCastSecret
function C_Secrets.ShouldUnitSpellCastBeSecret(unit, spellIdentifier) end

---Returns true if queries for spell casting information for a specific unit will generally produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitSpellCastingBeSecret)
---@param unit UnitToken
---@return boolean isSpellCastingSecret
function C_Secrets.ShouldUnitSpellCastingBeSecret(unit) end

---Returns true if queries for unit threat status will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitThreatStateBeSecret)
---@param unit UnitToken
---@param mobUnit? UnitToken
---@return boolean isUnitThreatSecret
function C_Secrets.ShouldUnitThreatStateBeSecret(unit, mobUnit) end

---Returns true if queries for unit threat values will produce secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Secrets.ShouldUnitThreatValuesBeSecret)
---@param unit UnitToken
---@param mobUnit UnitToken
---@return boolean isUnitThreatSecret
function C_Secrets.ShouldUnitThreatValuesBeSecret(unit, mobUnit) end
