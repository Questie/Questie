---@meta _
C_ActionBar = {}

---Used in conjunction with ActionRangeCheckUpdate to inform the UI when an action goes in or out of range with its current target.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.EnableActionRangeCheck)
---@param actionID number
---@param enable boolean
function C_ActionBar.EnableActionRangeCheck(actionID, enable) end

---Returns the list of action bar slots that contain the Assisted Combat action spell.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindAssistedCombatActionButtons)
---@return number[] slots
function C_ActionBar.FindAssistedCombatActionButtons() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindFlyoutActionButtons)
---@param flyoutID number
---@return number[] slots
function C_ActionBar.FindFlyoutActionButtons(flyoutID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindPetActionButtons)
---@param petActionID number
---@return number[] slots
function C_ActionBar.FindPetActionButtons(petActionID) end

---Returns the list of action bar slots that contain a specified spell.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.FindSpellActionButtons)
---@param spellID number
---@return number[] slots
function C_ActionBar.FindSpellActionButtons(spellID) end

---Force updates some internals for an action button slot.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ForceUpdateAction)
---@param slotID number
function C_ActionBar.ForceUpdateAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetBonusBarIndexForSlot)
---@param slotID number
---@return number? bonusBarIndex
function C_ActionBar.GetBonusBarIndexForSlot(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetItemActionOnEquipSpellID)
---@param actionID number
---@return number? onEquipSpellID
function C_ActionBar.GetItemActionOnEquipSpellID(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetPetActionPetBarIndices)
---@param petActionID number
---@return number[] slots
function C_ActionBar.GetPetActionPetBarIndices(petActionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetProfessionQuality)
---@param actionID number
---@return number? quality
function C_ActionBar.GetProfessionQuality(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetSpell)
---@param actionID number
---@return number spellID
function C_ActionBar.GetSpell(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasAssistedCombatActionButtons)
---@return boolean hasButtons
function C_ActionBar.HasAssistedCombatActionButtons() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasFlyoutActionButtons)
---@param flyoutID number
---@return boolean hasFlyoutActionButtons
function C_ActionBar.HasFlyoutActionButtons(flyoutID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasPetActionButtons)
---@param petActionID number
---@return boolean hasPetActionButtons
function C_ActionBar.HasPetActionButtons(petActionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasPetActionPetBarIndices)
---@param petActionID number
---@return boolean hasPetActionPetBarIndices
function C_ActionBar.HasPetActionPetBarIndices(petActionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasSpellActionButtons)
---@param spellID number
---@return boolean hasSpellActionButtons
function C_ActionBar.HasSpellActionButtons(spellID) end

---Returns whether the given action button contains the Assisted Combat action spell.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAssistedCombatAction)
---@param slotID number
---@return boolean isAssistedCombatAction
function C_ActionBar.IsAssistedCombatAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAutoCastPetAction)
---@param slotID number
---@return boolean isAutoCastPetAction
function C_ActionBar.IsAutoCastPetAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsEnabledAutoCastPetAction)
---@param slotID number
---@return boolean isEnabledAutoCastPetAction
function C_ActionBar.IsEnabledAutoCastPetAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsHarmfulAction)
---@param actionID number
---@param useNeutral boolean
---@return boolean isHarmful
function C_ActionBar.IsHarmfulAction(actionID, useNeutral) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsHelpfulAction)
---@param actionID number
---@param useNeutral boolean
---@return boolean isHelpful
function C_ActionBar.IsHelpfulAction(actionID, useNeutral) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsOnBarOrSpecialBar)
---@param spellID number
---@return boolean isOnBarOrSpecialBar
function C_ActionBar.IsOnBarOrSpecialBar(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.PutActionInSlot)
---@param slotID number
function C_ActionBar.PutActionInSlot(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ShouldOverrideBarShowHealthBar)
---@return boolean showHealthBar
function C_ActionBar.ShouldOverrideBarShowHealthBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ShouldOverrideBarShowManaBar)
---@return boolean showManaBar
function C_ActionBar.ShouldOverrideBarShowManaBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ToggleAutoCastPetAction)
---@param slotID number
function C_ActionBar.ToggleAutoCastPetAction(slotID) end

---@class ActionUsableState
---@field slot number
---@field usable boolean
---@field noMana boolean
