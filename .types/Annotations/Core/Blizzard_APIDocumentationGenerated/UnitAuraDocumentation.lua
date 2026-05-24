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

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.AuraIsPrivate)
---@param spellID number
---@return boolean isPrivate
function C_UnitAuras.AuraIsPrivate(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataByAuraInstanceID)
---@param unitToken string
---@param auraInstanceID number
---@return AuraData? aura
function C_UnitAuras.GetAuraDataByAuraInstanceID(unitToken, auraInstanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataByIndex)
---@param unitToken string
---@param index number
---@param filter? string
---@return AuraData? aura
function C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataBySlot)
---@param unitToken string
---@param slot number
---@return AuraData? aura
function C_UnitAuras.GetAuraDataBySlot(unitToken, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraDataBySpellName)
---@param unitToken string
---@param spellName string
---@param filter? string
---@return AuraData? aura
function C_UnitAuras.GetAuraDataBySpellName(unitToken, spellName, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetAuraSlots)
---@param unitToken UnitToken
---@param filter? string
---@param maxSlots? number
---@param continuationToken? number
---@return number? outContinuationToken
---@return number ... slots
function C_UnitAuras.GetAuraSlots(unitToken, filter, maxSlots, continuationToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetBuffDataByIndex)
---@param unitToken string
---@param index number
---@param filter? string
---@return AuraData? aura
function C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetCooldownAuraBySpellID)
---@param spellID number
---@return number? cooldownSpellID
function C_UnitAuras.GetCooldownAuraBySpellID(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetDebuffDataByIndex)
---@param unitToken string
---@param index number
---@param filter? string
---@return AuraData? aura
function C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.GetPlayerAuraBySpellID)
---@param spellID number
---@return AuraData? aura
function C_UnitAuras.GetPlayerAuraBySpellID(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.IsAuraFilteredOutByInstanceID)
---@param unitToken string
---@param auraInstanceID number
---@param filterFlags string
---@return boolean isFiltered
function C_UnitAuras.IsAuraFilteredOutByInstanceID(unitToken, auraInstanceID, filterFlags) end

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

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_UnitAuras.WantsAlteredForm)
---@param unitToken string
---@return boolean wantsAlteredForm
function C_UnitAuras.WantsAlteredForm(unitToken) end
