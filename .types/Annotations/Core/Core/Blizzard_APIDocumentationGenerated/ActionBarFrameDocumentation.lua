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

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionAutocast)
---@param actionID number
---@return boolean autocastAllowed
---@return boolean autocastEnabled
function C_ActionBar.GetActionAutocast(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionBarPage)
---@return number currentPage
function C_ActionBar.GetActionBarPage() end

---Returns a duration object describing the active recharge time for an action.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionChargeDuration)
---@param actionID number
---@return LuaDurationObject duration
function C_ActionBar.GetActionChargeDuration(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionCharges)
---@param actionID number
---@return ActionBarChargeInfo chargeInfo
function C_ActionBar.GetActionCharges(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionCooldown)
---@param actionID number
---@return ActionBarCooldownInfo cooldownInfo
function C_ActionBar.GetActionCooldown(actionID) end

---Returns a duration object describing the active cooldown duration for an action.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionCooldownDuration)
---@param actionID number
---@return LuaDurationObject duration
function C_ActionBar.GetActionCooldownDuration(actionID) end

---Depending on the action type, return a string that is either the use count or number of charges. If value is beyond the display count parameter, returns the replacementString (defaults to '*').
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionDisplayCount)
---@param actionID number
---@param maxDisplayCount? number Default = 9999
---@param replacementString? string Default = *
---@return string displayCount
function C_ActionBar.GetActionDisplayCount(actionID, maxDisplayCount, replacementString) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionLossOfControlCooldown)
---@param actionID number
---@return number startTime
---@return number duration
function C_ActionBar.GetActionLossOfControlCooldown(actionID) end

---Returns a duration object describing the active loss of control cooldown duration for an action.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionLossOfControlCooldownDuration)
---@param actionID number
---@return LuaDurationObject duration
function C_ActionBar.GetActionLossOfControlCooldownDuration(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionText)
---@param actionID number
---@return string text
function C_ActionBar.GetActionText(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionTexture)
---@param actionID number
---@return fileID textureFileID
function C_ActionBar.GetActionTexture(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetActionUseCount)
---@param actionID number
---@return number count
function C_ActionBar.GetActionUseCount(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetBonusBarIndex)
---@return number bonusBarIndex
function C_ActionBar.GetBonusBarIndex() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetBonusBarIndexForSlot)
---@param slotID number
---@return number? bonusBarIndex
function C_ActionBar.GetBonusBarIndexForSlot(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetBonusBarOffset)
---@return number bonusBarOffset
function C_ActionBar.GetBonusBarOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetExtraBarIndex)
---@return number extraBarIndex
function C_ActionBar.GetExtraBarIndex() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetItemActionOnEquipSpellID)
---@param actionID number
---@return number? onEquipSpellID
function C_ActionBar.GetItemActionOnEquipSpellID(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetMultiCastBarIndex)
---@return number multiCastBarIndex
function C_ActionBar.GetMultiCastBarIndex() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetOverrideBarIndex)
---@return number overrideBarIndex
function C_ActionBar.GetOverrideBarIndex() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetOverrideBarSkin)
---@return fileID? textureFileID
function C_ActionBar.GetOverrideBarSkin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetPetActionPetBarIndices)
---@param petActionID number
---@return number[] slots
function C_ActionBar.GetPetActionPetBarIndices(petActionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetProfessionQuality)
---@param actionID number
---@return number? quality
function C_ActionBar.GetProfessionQuality(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetProfessionQualityInfo)
---@param actionID number
---@return CraftingQualityInfo? info
function C_ActionBar.GetProfessionQualityInfo(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetSpell)
---@param actionID number
---@return number spellID
function C_ActionBar.GetSpell(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetTempShapeshiftBarIndex)
---@return number tempShapeshiftBarIndex
function C_ActionBar.GetTempShapeshiftBarIndex() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.GetVehicleBarIndex)
---@return number vehicleBarIndex
function C_ActionBar.GetVehicleBarIndex() end

---Returns true if an actionbar slot is populated with an action.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasAction)
---@param actionID number
---@return boolean hasAction
function C_ActionBar.HasAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasAssistedCombatActionButtons)
---@return boolean hasButtons
function C_ActionBar.HasAssistedCombatActionButtons() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasBonusActionBar)
---@return boolean hasBonusActionBar
function C_ActionBar.HasBonusActionBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasExtraActionBar)
---@return boolean hasExtraActionBar
function C_ActionBar.HasExtraActionBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasFlyoutActionButtons)
---@param flyoutID number
---@return boolean hasFlyoutActionButtons
function C_ActionBar.HasFlyoutActionButtons(flyoutID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasOverrideActionBar)
---@return boolean hasOverrideActionBar
function C_ActionBar.HasOverrideActionBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasPetActionButtons)
---@param petActionID number
---@return boolean hasPetActionButtons
function C_ActionBar.HasPetActionButtons(petActionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasPetActionPetBarIndices)
---@param petActionID number
---@return boolean hasPetActionPetBarIndices
function C_ActionBar.HasPetActionPetBarIndices(petActionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasRangeRequirements)
---@param actionID number
---@return boolean hasRangeRequirements
function C_ActionBar.HasRangeRequirements(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasSpellActionButtons)
---@param spellID number
---@return boolean hasSpellActionButtons
function C_ActionBar.HasSpellActionButtons(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasTempShapeshiftActionBar)
---@return boolean hasTempShapeshiftActionBar
function C_ActionBar.HasTempShapeshiftActionBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.HasVehicleActionBar)
---@return boolean hasVehicleActionBar
function C_ActionBar.HasVehicleActionBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsActionInRange)
---@param actionID number
---@param target? UnitToken
---@return boolean? isInRange
function C_ActionBar.IsActionInRange(actionID, target) end

---Returns whether the given action button contains the Assisted Combat action spell.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAssistedCombatAction)
---@param slotID number
---@return boolean isAssistedCombatAction
function C_ActionBar.IsAssistedCombatAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAttackAction)
---@param actionID number
---@return boolean isAttackAction
function C_ActionBar.IsAttackAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAutoCastPetAction)
---@param slotID number
---@return boolean isAutoCastPetAction
function C_ActionBar.IsAutoCastPetAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsAutoRepeatAction)
---@param actionID number
---@return boolean isAutoRepeatAction
function C_ActionBar.IsAutoRepeatAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsConsumableAction)
---@param actionID number
---@return boolean isConsumableAction
function C_ActionBar.IsConsumableAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsCurrentAction)
---@param actionID number
---@return boolean isCurrentAction
function C_ActionBar.IsCurrentAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsEnabledAutoCastPetAction)
---@param slotID number
---@return boolean isEnabledAutoCastPetAction
function C_ActionBar.IsEnabledAutoCastPetAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsEquippedAction)
---@param actionID number
---@return boolean isEquippedAction
function C_ActionBar.IsEquippedAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsEquippedGearOutfitAction)
---@param slotID number
---@return boolean isEquippedGearOutfitAction
function C_ActionBar.IsEquippedGearOutfitAction(slotID) end

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

---Returns whether the given action button contains a spell that can interrupt spellcasting.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsInterruptAction)
---@param slotID number
---@return boolean isInterruptAction
function C_ActionBar.IsInterruptAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsItemAction)
---@param actionID number
---@return boolean isItemAction
function C_ActionBar.IsItemAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsOnBarOrSpecialBar)
---@param spellID number
---@return boolean isOnBarOrSpecialBar
function C_ActionBar.IsOnBarOrSpecialBar(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsPossessBarVisible)
---@return boolean isPossessBarVisible
function C_ActionBar.IsPossessBarVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsStackableAction)
---@param actionID number
---@return boolean isStackableAction
function C_ActionBar.IsStackableAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.IsUsableAction)
---@param actionID number
---@return boolean isUsable
---@return boolean isLackingResources
function C_ActionBar.IsUsableAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.PutActionInSlot)
---@param slotID number
function C_ActionBar.PutActionInSlot(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.RegisterActionUIButton)
---@param checkboxFrame SimpleCheckbox
---@param actionID number
---@param cooldownFrame CooldownFrame
function C_ActionBar.RegisterActionUIButton(checkboxFrame, actionID, cooldownFrame) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.SetActionBarPage)
---@param pageIndex number
function C_ActionBar.SetActionBarPage(pageIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ShouldOverrideBarShowHealthBar)
---@return boolean showHealthBar
function C_ActionBar.ShouldOverrideBarShowHealthBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ShouldOverrideBarShowManaBar)
---@return boolean showManaBar
function C_ActionBar.ShouldOverrideBarShowManaBar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.ToggleAutoCastPetAction)
---@param slotID number
function C_ActionBar.ToggleAutoCastPetAction(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ActionBar.UnregisterActionUIButton)
---@param checkboxFrame SimpleCheckbox
function C_ActionBar.UnregisterActionUIButton(checkboxFrame) end
