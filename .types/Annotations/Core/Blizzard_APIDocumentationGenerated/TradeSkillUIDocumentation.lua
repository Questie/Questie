---@meta _
C_TradeSkillUI = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CanStoreEnchantInItem)
---@param itemGUID WOWGUID
---@return boolean canStore
function C_TradeSkillUI.CanStoreEnchantInItem(itemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CancelProfessionRespec)
function C_TradeSkillUI.CancelProfessionRespec() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CheckRespecNPC)
---@return boolean canInteract
function C_TradeSkillUI.CheckRespecNPC() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CloseTradeSkill)
function C_TradeSkillUI.CloseTradeSkill() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.ConfirmProfessionRespec)
function C_TradeSkillUI.ConfirmProfessionRespec() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CraftEnchant)
---@param recipeSpellID number
---@param numCasts? number Default = 1
---@param craftingReagents? CraftingReagentInfo[]
---@param itemTarget? ItemLocation
---@param applyConcentration? boolean
function C_TradeSkillUI.CraftEnchant(recipeSpellID, numCasts, craftingReagents, itemTarget, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CraftRecipe)
---@param recipeSpellID number
---@param numCasts? number Default = 1
---@param craftingReagents? CraftingReagentInfo[]
---@param recipeLevel? number
---@param orderID? BigUInteger
---@param applyConcentration? boolean
function C_TradeSkillUI.CraftRecipe(recipeSpellID, numCasts, craftingReagents, recipeLevel, orderID, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.CraftSalvage)
---@param recipeSpellID number
---@param numCasts? number Default = 1
---@param itemTarget ItemLocation
---@param craftingReagents? CraftingReagentInfo[]
---@param applyConcentration? boolean
function C_TradeSkillUI.CraftSalvage(recipeSpellID, numCasts, itemTarget, craftingReagents, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.DoesRecraftingRecipeAcceptItem)
---@param itemLocation ItemLocation
---@param recipeID number
---@return boolean result
function C_TradeSkillUI.DoesRecraftingRecipeAcceptItem(itemLocation, recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetAllProfessionTradeSkillLines)
---@return number[] skillLineID
function C_TradeSkillUI.GetAllProfessionTradeSkillLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetBaseProfessionInfo)
---@return ProfessionInfo info
function C_TradeSkillUI.GetBaseProfessionInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetChildProfessionInfo)
---@return ProfessionInfo info
function C_TradeSkillUI.GetChildProfessionInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetChildProfessionInfos)
---@return ProfessionInfo[] infos
function C_TradeSkillUI.GetChildProfessionInfos() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetConcentrationCurrencyID)
---@param skillLineID number
---@return number currencyType
function C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetCraftableCount)
---@param recipeSpellID number
---@param recipeLevel? number
---@return number numAvailable
function C_TradeSkillUI.GetCraftableCount(recipeSpellID, recipeLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetCraftingOperationInfo)
---@param recipeID number
---@param craftingReagents CraftingReagentInfo[]
---@param allocationItemGUID? WOWGUID
---@param applyConcentration boolean
---@return CraftingOperationInfo? info
function C_TradeSkillUI.GetCraftingOperationInfo(recipeID, craftingReagents, allocationItemGUID, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetCraftingOperationInfoForOrder)
---@param recipeID number
---@param craftingReagents CraftingReagentInfo[]
---@param orderID BigUInteger
---@param applyConcentration boolean
---@return CraftingOperationInfo? info
function C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, craftingReagents, orderID, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetCraftingReagentBonusText)
---@param recipeSpellID number
---@param craftingReagentIndex number
---@param craftingReagents CraftingReagentInfo[]
---@param allocationItemGUID? WOWGUID
---@return string[] bonusText
function C_TradeSkillUI.GetCraftingReagentBonusText(recipeSpellID, craftingReagentIndex, craftingReagents, allocationItemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetCraftingTargetItems)
---@param itemIDs number[]
---@return CraftingTargetItem[] items
function C_TradeSkillUI.GetCraftingTargetItems(itemIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetEnchantItems)
---@param recipeID number
---@return WOWGUID[] items
function C_TradeSkillUI.GetEnchantItems(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetFactionSpecificOutputItem)
---@param recipeSpellID number
---@return number? itemID
function C_TradeSkillUI.GetFactionSpecificOutputItem(recipeSpellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetGatheringOperationInfo)
---@param recipeID number
---@return GatheringOperationInfo? info
function C_TradeSkillUI.GetGatheringOperationInfo(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetHideUnownedFlags)
---@param recipeID number
---@return boolean cannotModifyHideUnowned
---@return boolean alwaysShowUnowned
function C_TradeSkillUI.GetHideUnownedFlags(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetItemCraftedQualityByItemInfo)
---@param itemInfo ItemInfo
---@return number? quality
function C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetItemReagentQualityByItemInfo)
---@param itemInfo ItemInfo
---@return number? quality
function C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetItemSlotModifications)
---@param itemGUID WOWGUID
---@return CraftingItemSlotModification[] slotMods
function C_TradeSkillUI.GetItemSlotModifications(itemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetItemSlotModificationsForOrder)
---@param orderID BigUInteger
---@return CraftingItemSlotModification[] slotMods
function C_TradeSkillUI.GetItemSlotModificationsForOrder(orderID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetOriginalCraftRecipeID)
---@param itemGUID WOWGUID
---@return number? recipeID
---@return number? skillLineAbilityID
function C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionByInventorySlot)
---@param slot number
---@return Enum.Profession? profession
function C_TradeSkillUI.GetProfessionByInventorySlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionChildSkillLineID)
---@return number skillLineID
function C_TradeSkillUI.GetProfessionChildSkillLineID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionForCursorItem)
---@return Enum.Profession? profession
function C_TradeSkillUI.GetProfessionForCursorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionInfoByRecipeID)
---@param recipeID number
---@return ProfessionInfo info
function C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionInfoBySkillLineID)
---@param skillLineID number
---@return ProfessionInfo info
function C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionInventorySlots)
---@return InventorySlots[] invSlots
function C_TradeSkillUI.GetProfessionInventorySlots() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionNameForSkillLineAbility)
---@param skillLineAbilityID number
---@return string professionNmae
function C_TradeSkillUI.GetProfessionNameForSkillLineAbility(skillLineAbilityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionSkillLineID)
---@param profession Enum.Profession
---@return number skillLineID
function C_TradeSkillUI.GetProfessionSkillLineID(profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionSlots)
---@param profession Enum.Profession
---@return number[] slots
function C_TradeSkillUI.GetProfessionSlots(profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetProfessionSpells)
---@param professionID number
---@param skillLineID? number
---@return number[] knownSpells
function C_TradeSkillUI.GetProfessionSpells(professionID, skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetQualitiesForRecipe)
---@param recipeID number
---@return number[]? qualityIDs
function C_TradeSkillUI.GetQualitiesForRecipe(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetReagentDifficultyText)
---@param craftingReagentIndex number
---@param craftingReagents CraftingReagentInfo[]
---@return string bonusText
function C_TradeSkillUI.GetReagentDifficultyText(craftingReagentIndex, craftingReagents) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetReagentRequirementItemIDs)
---@param itemID number
---@return number[] itemIDs
function C_TradeSkillUI.GetReagentRequirementItemIDs(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetReagentSlotStatus)
---@param mcrSlotID number
---@param recipeSpellID number
---@param skillLineAbilityID number
---@return boolean locked
---@return string lockedReason
function C_TradeSkillUI.GetReagentSlotStatus(mcrSlotID, recipeSpellID, skillLineAbilityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeDescription)
---@param recipeID number
---@param craftingReagents CraftingReagentInfo[]
---@param allocationItemGUID? WOWGUID
---@return string description
function C_TradeSkillUI.GetRecipeDescription(recipeID, craftingReagents, allocationItemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeFixedReagentItemLink)
---@param recipeID number
---@param dataSlotIndex number
---@return string link
function C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, dataSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeInfo)
---@param recipeSpellID number
---@param recipeLevel? number
---@return TradeSkillRecipeInfo? recipeInfo
function C_TradeSkillUI.GetRecipeInfo(recipeSpellID, recipeLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeInfoForSkillLineAbility)
---@param skillLineAbilityID number
---@param recipeLevel? number
---@return TradeSkillRecipeInfo? recipeInfo
function C_TradeSkillUI.GetRecipeInfoForSkillLineAbility(skillLineAbilityID, recipeLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeOutputItemData)
---@param recipeSpellID number
---@param reagents? CraftingReagentInfo[]
---@param allocationItemGUID? WOWGUID
---@param overrideQualityID? number
---@param recraftOrderID? BigUInteger
---@return CraftingRecipeOutputInfo outputInfo
function C_TradeSkillUI.GetRecipeOutputItemData(recipeSpellID, reagents, allocationItemGUID, overrideQualityID, recraftOrderID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeQualityItemIDs)
---@param recipeSpellID number
---@return number[]? qualityItemIDs
function C_TradeSkillUI.GetRecipeQualityItemIDs(recipeSpellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeQualityReagentItemLink)
---@param recipeID number
---@param dataSlotIndex number
---@param qualityIndex number
---@return string link
function C_TradeSkillUI.GetRecipeQualityReagentItemLink(recipeID, dataSlotIndex, qualityIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeRequirements)
---@param recipeID number
---@return CraftingRecipeRequirement[] requirements
function C_TradeSkillUI.GetRecipeRequirements(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipeSchematic)
---@param recipeSpellID number
---@param isRecraft boolean
---@param recipeLevel? number
---@return CraftingRecipeSchematic schematic
function C_TradeSkillUI.GetRecipeSchematic(recipeSpellID, isRecraft, recipeLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecipesTracked)
---@param isRecraft boolean
---@return number[] recipeIDs
function C_TradeSkillUI.GetRecipesTracked(isRecraft) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecraftItems)
---@param recipeID? number
---@return WOWGUID[] items
function C_TradeSkillUI.GetRecraftItems(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRecraftRemovalWarnings)
---@param itemGUID WOWGUID
---@param replacedItemIDs number[]
---@return string[] warnings
function C_TradeSkillUI.GetRecraftRemovalWarnings(itemGUID, replacedItemIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetRemainingRecasts)
---@return number remaining
function C_TradeSkillUI.GetRemainingRecasts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetSalvagableItemIDs)
---@param recipeID number
---@return number[] itemIDs
function C_TradeSkillUI.GetSalvagableItemIDs(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetShowLearned)
---@return boolean flag
function C_TradeSkillUI.GetShowLearned() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetShowUnlearned)
---@return boolean flag
function C_TradeSkillUI.GetShowUnlearned() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetSkillLineForGear)
---@param itemInfo ItemInfo
---@return number? skillLineID
function C_TradeSkillUI.GetSkillLineForGear(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetSourceTypeFilter)
---@return number sourceTypeFilter
function C_TradeSkillUI.GetSourceTypeFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.GetTradeSkillDisplayName)
---@param skillLineID number
---@return string professionDisplayName
function C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.HasFavoriteOrderRecipes)
---@return boolean hasFavorites
function C_TradeSkillUI.HasFavoriteOrderRecipes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsEnchantTargetValid)
---@param recipeID number
---@param itemGUID WOWGUID
---@param craftingReagents? CraftingReagentInfo[]
---@return boolean valid
function C_TradeSkillUI.IsEnchantTargetValid(recipeID, itemGUID, craftingReagents) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsGuildTradeSkillsEnabled)
---@return boolean enabled
function C_TradeSkillUI.IsGuildTradeSkillsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsNPCCrafting)
---@return boolean result
function C_TradeSkillUI.IsNPCCrafting() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsNearProfessionSpellFocus)
---@param profession Enum.Profession
---@return boolean nearFocus
function C_TradeSkillUI.IsNearProfessionSpellFocus(profession) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsOriginalCraftRecipeLearned)
---@param itemGUID WOWGUID
---@return boolean learned
function C_TradeSkillUI.IsOriginalCraftRecipeLearned(itemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecipeFirstCraft)
---@param recipeID number
---@return boolean result
function C_TradeSkillUI.IsRecipeFirstCraft(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecipeInBaseSkillLine)
---@param recipeID number
---@return boolean result
function C_TradeSkillUI.IsRecipeInBaseSkillLine(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecipeInSkillLine)
---@param recipeID number
---@param skillLineID number
---@return boolean result
function C_TradeSkillUI.IsRecipeInSkillLine(recipeID, skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecipeProfessionLearned)
---@param recipeID number
---@return boolean recipeProfessionLearned
function C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecipeTracked)
---@param recipeID number
---@param isRecraft boolean
---@return boolean tracked
function C_TradeSkillUI.IsRecipeTracked(recipeID, isRecraft) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecraftItemEquipped)
---@param recraftItemGUID WOWGUID
---@return boolean isEquipped
function C_TradeSkillUI.IsRecraftItemEquipped(recraftItemGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRecraftReagentValid)
---@param itemGUID WOWGUID
---@param itemID number
---@return boolean valid
function C_TradeSkillUI.IsRecraftReagentValid(itemGUID, itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.IsRuneforging)
---@return boolean result
function C_TradeSkillUI.IsRuneforging() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.OpenRecipe)
---@param recipeID number
function C_TradeSkillUI.OpenRecipe(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.OpenTradeSkill)
---@param skillLineID number
---@return boolean opened
function C_TradeSkillUI.OpenTradeSkill(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.RecraftLimitCategoryValid)
---@param reagentItemID number
---@return boolean recraftValid
function C_TradeSkillUI.RecraftLimitCategoryValid(reagentItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.RecraftRecipe)
---@param itemGUID WOWGUID
---@param craftingReagents? CraftingReagentInfo[]
---@param removedModifications? CraftingItemSlotModification[]
---@param applyConcentration? boolean
---@return boolean result
function C_TradeSkillUI.RecraftRecipe(itemGUID, craftingReagents, removedModifications, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.RecraftRecipeForOrder)
---@param orderID BigUInteger
---@param itemGUID WOWGUID
---@param craftingReagents? CraftingReagentInfo[]
---@param removedModifications? CraftingItemSlotModification[]
---@param applyConcentration? boolean
---@return boolean result
function C_TradeSkillUI.RecraftRecipeForOrder(orderID, itemGUID, craftingReagents, removedModifications, applyConcentration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.SetOnlyShowAvailableForOrders)
---@param flag boolean
function C_TradeSkillUI.SetOnlyShowAvailableForOrders(flag) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.SetProfessionChildSkillLineID)
---@param skillLineID number
function C_TradeSkillUI.SetProfessionChildSkillLineID(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.SetRecipeTracked)
---@param recipeID number
---@param tracked boolean
---@param isRecraft boolean
function C_TradeSkillUI.SetRecipeTracked(recipeID, tracked, isRecraft) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.SetShowLearned)
---@param flag boolean
function C_TradeSkillUI.SetShowLearned(flag) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.SetShowUnlearned)
---@param flag boolean
function C_TradeSkillUI.SetShowUnlearned(flag) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeSkillUI.SetSourceTypeFilter)
---@param sourceTypeFilter number
function C_TradeSkillUI.SetSourceTypeFilter(sourceTypeFilter) end
