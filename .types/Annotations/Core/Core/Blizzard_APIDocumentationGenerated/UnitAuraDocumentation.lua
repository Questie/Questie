---@meta _
C_UnitAuras = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.AddPrivateAuraAnchor)
---@param args AddPrivateAuraAnchorArgs
---@return number? anchorID
function C_UnitAuras.AddPrivateAuraAnchor(args) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.AddPrivateAuraAppliedSound)
---@param sound UnitPrivateAuraAppliedSoundInfo
---@return number? privateAuraSoundID
function C_UnitAuras.AddPrivateAuraAppliedSound(sound) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.AuraIsBigDefensive)
---@param spellID number
---@return boolean isBigDefensive
function C_UnitAuras.AuraIsBigDefensive(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.AuraIsPrivate)
---@param spellID number
---@return boolean isPrivate
function C_UnitAuras.AuraIsPrivate(spellID) end

---Returns true if an aura instance will expire after a certain amount of time.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.DoesAuraHaveExpirationTime)
---@param auraInstanceUnit UnitToken
---@param auraInstanceID number
---@return boolean hasExpirationTime
function C_UnitAuras.DoesAuraHaveExpirationTime(auraInstanceUnit, auraInstanceID) end

---Formats a string for displaying the number of applications an aura has present.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraApplicationDisplayCount)
---@param auraInstanceUnit UnitToken
---@param auraInstanceID number
---@param minDisplayCount? number Default = 2
---@param maxDisplayCount? number
---@return string count
function C_UnitAuras.GetAuraApplicationDisplayCount(auraInstanceUnit, auraInstanceID, minDisplayCount, maxDisplayCount) end

---Returns the base duration of the given spell (or aura). Takes an optional spellID to use as the new duration if that cannot be derived from the aura, if that value isn't supplied the aura's spellID will be used
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraBaseDuration)
---@param auraInstanceUnit UnitToken
---@param auraInstanceID number
---@param spellID? number
---@return number? newDuration
function C_UnitAuras.GetAuraBaseDuration(auraInstanceUnit, auraInstanceID, spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataByAuraInstanceID)
---@param unit UnitTokenRestrictedForAddOns
---@param auraInstanceID number
---@return AuraData? aura
function C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataByIndex)
---@param unit UnitTokenRestrictedForAddOns
---@param index number
---@param filter? AuraFilters
---@return AuraData? aura
function C_UnitAuras.GetAuraDataByIndex(unit, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataBySlot)
---@param unit UnitTokenRestrictedForAddOns
---@param slot number
---@return AuraData? aura
function C_UnitAuras.GetAuraDataBySlot(unit, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataBySpellName)
---@param unit UnitTokenRestrictedForAddOns
---@param spellName string
---@param filter? AuraFilters
---@return AuraData? aura
function C_UnitAuras.GetAuraDataBySpellName(unit, spellName, filter) end

---Queries the dispel type associated with an aura instance and remaps it to a color via a curve, with the dispel type ID used as the 'x' value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDispelTypeColor)
---@param auraInstanceUnit UnitToken
---@param auraInstanceID number
---@param curve LuaColorCurveObject
---@return colorRGBA dispelTypeColor
function C_UnitAuras.GetAuraDispelTypeColor(auraInstanceUnit, auraInstanceID, curve) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDuration)
---@param auraInstanceUnit UnitToken
---@param auraInstanceID number
---@return LuaDurationObject duration
function C_UnitAuras.GetAuraDuration(auraInstanceUnit, auraInstanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraSlots)
---@param unit UnitTokenRestrictedForAddOns
---@param filter? AuraFilters
---@param maxSlots? number
---@param continuationToken? number
---@return number? outContinuationToken
---@return number ... slots
function C_UnitAuras.GetAuraSlots(unit, filter, maxSlots, continuationToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetBuffDataByIndex)
---@param unit UnitTokenRestrictedForAddOns
---@param index number
---@param filter? AuraFilters
---@return AuraData? aura
function C_UnitAuras.GetBuffDataByIndex(unit, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetCooldownAuraBySpellID)
---@param spellID number
---@return number? cooldownSpellID
function C_UnitAuras.GetCooldownAuraBySpellID(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetDebuffDataByIndex)
---@param unit UnitTokenRestrictedForAddOns
---@param index number
---@param filter? AuraFilters
---@return AuraData? aura
function C_UnitAuras.GetDebuffDataByIndex(unit, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetPlayerAuraBySpellID)
---@param spellID number
---@return AuraData? aura
function C_UnitAuras.GetPlayerAuraBySpellID(spellID) end

---Returns the client-predicted new duration of this aura if it were cast again right now. Takes an optional spellID to use as the new duration if that cannot be derived from the aura, if that value isn't supplied the aura's spellID will be used
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetRefreshExtendedDuration)
---@param auraInstanceUnit UnitToken
---@param auraInstanceID number
---@param spellID? number
---@return number? newDuration
function C_UnitAuras.GetRefreshExtendedDuration(auraInstanceUnit, auraInstanceID, spellID) end

---Returns the first instance of an aura on a unit matching a given spell ID. Returns nil if no such aura is found. Additionally can return nil if querying a unit that is not visible (eg. party members on other maps).
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetUnitAuraBySpellID)
---@param unit UnitTokenRestrictedForAddOns
---@param spellID number
---@return AuraData? aura
function C_UnitAuras.GetUnitAuraBySpellID(unit, spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetUnitAuraInstanceIDs)
---@param unit UnitTokenRestrictedForAddOns
---@param filter AuraFilters
---@param maxCount? number
---@param sortRule? Enum.UnitAuraSortRule Default = Unsorted
---@param sortDirection? Enum.UnitAuraSortDirection Default = Normal
---@return number[] auraInstanceIDs
function C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, maxCount, sortRule, sortDirection) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetUnitAuras)
---@param unit UnitTokenRestrictedForAddOns
---@param filter AuraFilters
---@param maxCount? number
---@param sortRule? Enum.UnitAuraSortRule Default = Unsorted
---@param sortDirection? Enum.UnitAuraSortDirection Default = Normal
---@return AuraData[] auras
function C_UnitAuras.GetUnitAuras(unit, filter, maxCount, sortRule, sortDirection) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.IsAuraFilteredOutByInstanceID)
---@param unit UnitTokenRestrictedForAddOns
---@param auraInstanceID number
---@param filter AuraFilters
---@return boolean isFiltered
function C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraInstanceID, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.RemovePrivateAuraAnchor)
---@param anchorID number
function C_UnitAuras.RemovePrivateAuraAnchor(anchorID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.RemovePrivateAuraAppliedSound)
---@param privateAuraSoundID number
function C_UnitAuras.RemovePrivateAuraAppliedSound(privateAuraSoundID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.SetPrivateWarningTextAnchor)
---@param parent SimpleFrame
---@param anchor? AnchorBinding
function C_UnitAuras.SetPrivateWarningTextAnchor(parent, anchor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.TriggerPrivateAuraShowDispelType)
---@param show boolean
function C_UnitAuras.TriggerPrivateAuraShowDispelType(show) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.WantsAlteredForm)
---@param unit UnitToken
---@return boolean wantsAlteredForm
function C_UnitAuras.WantsAlteredForm(unit) end
