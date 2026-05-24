---@meta _
C_TooltipInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetAchievementByID)
---@param achievementID number
---@return TooltipData data
function C_TooltipInfo.GetAchievementByID(achievementID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetAction)
---@param actionID number
---@return TooltipData data
function C_TooltipInfo.GetAction(actionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetArtifactItem)
---@return TooltipData data
function C_TooltipInfo.GetArtifactItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetArtifactPowerByID)
---@param powerID number
---@return TooltipData data
function C_TooltipInfo.GetArtifactPowerByID(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetAzeriteEssence)
---@param essenceID number
---@param rank? number
---@return TooltipData data
function C_TooltipInfo.GetAzeriteEssence(essenceID, rank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetAzeriteEssenceSlot)
---@param slot Enum.AzeriteEssenceSlot
---@return TooltipData data
function C_TooltipInfo.GetAzeriteEssenceSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetAzeritePower)
---@param itemID number
---@param itemLevel number
---@param powerID number
---@param owningItemLink? string
---@return TooltipData data
function C_TooltipInfo.GetAzeritePower(itemID, itemLevel, powerID, owningItemLink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetBackpackToken)
---@param index number
---@return TooltipData data
function C_TooltipInfo.GetBackpackToken(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetBagItem)
---@param bagIndex Enum.BagIndex
---@param slotIndex number
---@return TooltipData data
function C_TooltipInfo.GetBagItem(bagIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetBagItemChild)
---@param bagIndex Enum.BagIndex
---@param slotIndex number
---@param equipSlotIndex number
---@return TooltipData data
function C_TooltipInfo.GetBagItemChild(bagIndex, slotIndex, equipSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetBuybackItem)
---@param index number
---@return TooltipData data
function C_TooltipInfo.GetBuybackItem(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetCompanionPet)
---@param petGUID WOWGUID
---@return TooltipData data
function C_TooltipInfo.GetCompanionPet(petGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetConduit)
---@param conduitID number
---@param conduitRank number
---@return TooltipData data
function C_TooltipInfo.GetConduit(conduitID, conduitRank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetCurrencyByID)
---@param currencyID number
---@param amount? number
---@return TooltipData data
function C_TooltipInfo.GetCurrencyByID(currencyID, amount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetCurrencyToken)
---@param tokenIndex number
---@return TooltipData data
function C_TooltipInfo.GetCurrencyToken(tokenIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetEnhancedConduit)
---@param conduitID number
---@param rank number
---@return TooltipData data
function C_TooltipInfo.GetEnhancedConduit(conduitID, rank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetEquipmentSet)
---@param setID number
---@return TooltipData data
function C_TooltipInfo.GetEquipmentSet(setID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetExistingSocketGem)
---@param index number
---@param toDestroy? boolean
---@return TooltipData data
function C_TooltipInfo.GetExistingSocketGem(index, toDestroy) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetGuildBankItem)
---@param tab number
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetGuildBankItem(tab, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetHeirloomByItemID)
---@param itemID number
---@return TooltipData data
function C_TooltipInfo.GetHeirloomByItemID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetHyperlink)
---@param hyperlink string
---@param optionalArg1? number
---@param optionalArg2? number
---@param hideVendorPrice? boolean
---@return TooltipData data
function C_TooltipInfo.GetHyperlink(hyperlink, optionalArg1, optionalArg2, hideVendorPrice) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetInboxItem)
---@param messageIndex number
---@param attachmentIndex? number
---@return TooltipData data
function C_TooltipInfo.GetInboxItem(messageIndex, attachmentIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetInstanceLockEncountersComplete)
---@param index number
---@return TooltipData data
function C_TooltipInfo.GetInstanceLockEncountersComplete(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetInventoryItem)
---@param unit UnitToken
---@param slot number
---@param hideUselessStats? boolean
---@return TooltipData data
function C_TooltipInfo.GetInventoryItem(unit, slot, hideUselessStats) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetInventoryItemByID)
---@param itemID number
---@return TooltipData data
function C_TooltipInfo.GetInventoryItemByID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetItemByGUID)
---@param guid WOWGUID
---@return TooltipData data
function C_TooltipInfo.GetItemByGUID(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetItemByID)
---@param itemID number
---@param quality? number
---@return TooltipData data
function C_TooltipInfo.GetItemByID(itemID, quality) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetItemByItemModifiedAppearanceID)
---@param itemModifiedAppearanceID number
---@return TooltipData data
function C_TooltipInfo.GetItemByItemModifiedAppearanceID(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetItemInteractionItem)
---@return TooltipData data
function C_TooltipInfo.GetItemInteractionItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetItemKey)
---@param itemID number
---@param itemLevel number
---@param itemSuffix number
---@param requiredLevel? number
---@return TooltipData data
function C_TooltipInfo.GetItemKey(itemID, itemLevel, itemSuffix, requiredLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetLFGDungeonReward)
---@param dungeonID number
---@param lootIndex number
---@return TooltipData data
function C_TooltipInfo.GetLFGDungeonReward(dungeonID, lootIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetLFGDungeonShortageReward)
---@param dungeonID number
---@param shortageSeverity number
---@param lootIndex number
---@return TooltipData data
function C_TooltipInfo.GetLFGDungeonShortageReward(dungeonID, shortageSeverity, lootIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetLootCurrency)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetLootCurrency(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetLootItem)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetLootItem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetLootRollItem)
---@param id number
---@return TooltipData data
function C_TooltipInfo.GetLootRollItem(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetMerchantCostItem)
---@param slot number
---@param costIndex number
---@return TooltipData data
function C_TooltipInfo.GetMerchantCostItem(slot, costIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetMerchantItem)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetMerchantItem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetMinimapMouseover)
---@return TooltipData data
function C_TooltipInfo.GetMinimapMouseover() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetMountBySpellID)
---@param spellID number
---@param checkIndoors? boolean
---@return TooltipData data
function C_TooltipInfo.GetMountBySpellID(spellID, checkIndoors) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetOutfit)
---@param outfitID number
---@return TooltipData data
function C_TooltipInfo.GetOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetOwnedItemByID)
---@param itemID number
---@return TooltipData data
function C_TooltipInfo.GetOwnedItemByID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetPetAction)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetPetAction(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetPossession)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetPossession(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetPvpBrawl)
---@param isSpecial? boolean
---@return TooltipData data
function C_TooltipInfo.GetPvpBrawl(isSpecial) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetPvpTalent)
---@param talentID number
---@param isInspect? boolean
---@param groupIndex? number
---@param talentIndex? number
---@return TooltipData data
function C_TooltipInfo.GetPvpTalent(talentID, isInspect, groupIndex, talentIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetQuestCurrency)
---@param type string
---@param currencyIndex number
---@return TooltipData data
function C_TooltipInfo.GetQuestCurrency(type, currencyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetQuestItem)
---@param type string
---@param itemIndex number
---@param allowCollectionText? boolean
---@return TooltipData data
function C_TooltipInfo.GetQuestItem(type, itemIndex, allowCollectionText) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetQuestLogCurrency)
---@param type string
---@param currencyIndex number
---@param questID? number
---@return TooltipData data
function C_TooltipInfo.GetQuestLogCurrency(type, currencyIndex, questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetQuestLogItem)
---@param type string
---@param itemIndex number
---@param questID? number
---@param allowCollectionText? boolean
---@return TooltipData data
function C_TooltipInfo.GetQuestLogItem(type, itemIndex, questID, allowCollectionText) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetQuestLogSpecialItem)
---@param questIndex number
---@return TooltipData data
function C_TooltipInfo.GetQuestLogSpecialItem(questIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetQuestPartyProgress)
---@param questID number
---@param omitTitle? boolean
---@param ignoreActivePlayer? boolean
---@return TooltipData data
function C_TooltipInfo.GetQuestPartyProgress(questID, omitTitle, ignoreActivePlayer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetRecipeRankInfo)
---@param recipeID number
---@param rank number
---@return TooltipData data
function C_TooltipInfo.GetRecipeRankInfo(recipeID, rank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetRecipeReagentItem)
---@param recipeSpellID number
---@param dataSlotIndex number
---@return TooltipData data
function C_TooltipInfo.GetRecipeReagentItem(recipeSpellID, dataSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetRecipeResultItem)
---@param recipeID number
---@param reagentInfos? CraftingReagentInfo[]
---@param recraftItemGUID? WOWGUID
---@param recipeLevel? number
---@param overrideQualityID? number
---@return TooltipData data
function C_TooltipInfo.GetRecipeResultItem(recipeID, reagentInfos, recraftItemGUID, recipeLevel, overrideQualityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetRecipeResultItemForOrder)
---@param recipeID number
---@param reagentInfos? CraftingReagentInfo[]
---@param orderID? BigUInteger
---@param recipeLevel? number
---@param overrideQualityID? number
---@return TooltipData data
function C_TooltipInfo.GetRecipeResultItemForOrder(recipeID, reagentInfos, orderID, recipeLevel, overrideQualityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetRuneforgeResultItem)
---@param itemGUID WOWGUID
---@param itemLevel number
---@param powerID? number
---@param modifiers? number[]
---@return TooltipData data
function C_TooltipInfo.GetRuneforgeResultItem(itemGUID, itemLevel, powerID, modifiers) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSendMailItem)
---@param attachmentIndex? number
---@return TooltipData data
function C_TooltipInfo.GetSendMailItem(attachmentIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetShapeshift)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetShapeshift(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSlottedKeystone)
---@return TooltipData data
function C_TooltipInfo.GetSlottedKeystone() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSocketGem)
---@param index number
---@return TooltipData data
function C_TooltipInfo.GetSocketGem(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSocketedItem)
---@return TooltipData data
function C_TooltipInfo.GetSocketedItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSocketedRelic)
---@param slotIndex number
---@return TooltipData data
function C_TooltipInfo.GetSocketedRelic(slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSpellBookItem)
---@param spellBookItemSlotIndex number
---@param spellBookItemSpellBank Enum.SpellBookSpellBank
---@return TooltipData data
function C_TooltipInfo.GetSpellBookItem(spellBookItemSlotIndex, spellBookItemSpellBank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetSpellByID)
---@param spellID number
---@param isPet? boolean
---@param showSubtext? boolean
---@param dontOverride? boolean
---@param difficultyID? number
---@param isLink? boolean
---@return TooltipData data
function C_TooltipInfo.GetSpellByID(spellID, isPet, showSubtext, dontOverride, difficultyID, isLink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetTalent)
---@param talentID number
---@param isInspect? boolean
---@param groupIndex? number
---@return TooltipData data
function C_TooltipInfo.GetTalent(talentID, isInspect, groupIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetTotem)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetTotem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetToyByItemID)
---@param itemID number
---@return TooltipData data
function C_TooltipInfo.GetToyByItemID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetTradePlayerItem)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetTradePlayerItem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetTradeTargetItem)
---@param slot number
---@return TooltipData data
function C_TooltipInfo.GetTradeTargetItem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetTrainerService)
---@param serviceIndex number
---@return TooltipData data
function C_TooltipInfo.GetTrainerService(serviceIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetTraitEntry)
---@param entryID number
---@param rank? number
---@return TooltipData data
function C_TooltipInfo.GetTraitEntry(entryID, rank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnit)
---@param unit UnitTokenPvPRestrictedForAddOns
---@param hideStatus? boolean
---@return TooltipData data
function C_TooltipInfo.GetUnit(unit, hideStatus) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnitAura)
---@param unitToken UnitTokenRestrictedForAddOns
---@param index number
---@param filter? AuraFilters
---@return TooltipData data
function C_TooltipInfo.GetUnitAura(unitToken, index, filter) end

---Obtains aura info like other functions with the caveat that the filters will always at least include the typically mutually exclusive HELPFUL|HARMFUL regardless of what the argument value is set to
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnitAuraByAuraInstanceID)
---@param unitToken UnitToken
---@param auraInstanceID number
---@param filter? AuraFilters
---@return TooltipData data
function C_TooltipInfo.GetUnitAuraByAuraInstanceID(unitToken, auraInstanceID, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnitBuff)
---@param unitToken UnitTokenRestrictedForAddOns
---@param index number
---@param filter? AuraFilters
---@return TooltipData data
function C_TooltipInfo.GetUnitBuff(unitToken, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnitBuffByAuraInstanceID)
---@param unitToken UnitToken
---@param auraInstanceID number
---@param filter? AuraFilters
---@return TooltipData data
function C_TooltipInfo.GetUnitBuffByAuraInstanceID(unitToken, auraInstanceID, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnitDebuff)
---@param unitToken UnitTokenRestrictedForAddOns
---@param index number
---@param filter? AuraFilters
---@return TooltipData data
function C_TooltipInfo.GetUnitDebuff(unitToken, index, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUnitDebuffByAuraInstanceID)
---@param unitToken UnitToken
---@param auraInstanceID number
---@param filter? AuraFilters
---@return TooltipData data
function C_TooltipInfo.GetUnitDebuffByAuraInstanceID(unitToken, auraInstanceID, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetUpgradeItem)
---@return TooltipData data
function C_TooltipInfo.GetUpgradeItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetWeeklyReward)
---@param itemDBID WeeklyRewardItemDBID
---@return TooltipData data
function C_TooltipInfo.GetWeeklyReward(itemDBID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetWorldCursor)
---@return TooltipData data
function C_TooltipInfo.GetWorldCursor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipInfo.GetWorldLootObject)
---@param unitTokenString string
---@return TooltipData data
function C_TooltipInfo.GetWorldLootObject(unitTokenString) end
