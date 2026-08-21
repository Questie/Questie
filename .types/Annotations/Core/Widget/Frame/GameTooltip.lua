---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_GameTooltip)
---@class GameTooltip : Frame
GameTooltip = {}
---@class gametooltip : GameTooltip
---@class GAMETOOLTIP : GameTooltip

---@param scriptType ScriptGameTooltip
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function GameTooltip:GetScript(scriptType, bindingType) end

---@param scriptType ScriptGameTooltip
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function GameTooltip:HasScript(scriptType) end

---@param scriptType ScriptGameTooltip
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function GameTooltip:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptGameTooltip
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function GameTooltip:SetScript(scriptType, handler) end


---@class TextureInfoTable
---@field width number
---@field height number
---@field anchor Enum.TooltipTextureAnchor
---@field margin TextureInfoTable.margin

---@class TextureInfoTable.margin
---@field left number
---@field right number
---@field top number
---@field bottom number

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AddAtlas)
---@param atlas string
---@param textureInfoTable TextureInfoTable
function GameTooltip:AddAtlas(atlas, textureInfoTable) end

---@param atlas string
---@param minx number
---@param maxx number
---@param miny number
---@param maxy number
function GameTooltip:AddAtlas(atlas, minx, maxx, miny, maxy) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AddDoubleLine)
---@param textL string
---@param textR string?
---@param rL number?
---@param gL number?
---@param bL number?
---@param rR number?
---@param gR number?
---@param bR number?
function GameTooltip:AddDoubleLine(textL, textR, rL, gL, bL, rR, gR, bR) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AddFontStrings)
function GameTooltip:AddFontStrings(leftstring, rightstring) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AddLine)
---@param tooltipText string
---@param r number?
---@param g number?
---@param b number?
---@param wrapText boolean?
function GameTooltip:AddLine(tooltipText, r, g, b, wrapText) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AddTexture)
function GameTooltip:AddTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AppendText)
---@param text string
function GameTooltip:AppendText(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_ClearLines)
function GameTooltip:ClearLines() end

---Set all padding values to 0.0 and remove the Padding SecretAspect.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_ClearPadding)
function GameTooltip:ClearPadding() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_CopyTooltip)
function GameTooltip:CopyTooltip() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_FadeOut)
function GameTooltip:FadeOut() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetAnchorType)
---@return string anchorType
function GameTooltip:GetAnchorType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetCustomLineSpacing)
---@return number spacing
function GameTooltip:GetCustomLineSpacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetLeftLine)
---@param line number
---@return SimpleFontString leftFontString
function GameTooltip:GetLeftLine(line) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetMinimumWidth)
---@return number width
---@return boolean forced
function GameTooltip:GetMinimumWidth() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetOwner)
---@return Frame owner
function GameTooltip:GetOwner() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetPadding)
---@return number right
---@return number bottom
---@return number left
---@return number top
function GameTooltip:GetPadding() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetRightLine)
---@param line number
---@return SimpleFontString rightFontString
function GameTooltip:GetRightLine(line) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_IsOwned)
---@param frame Frame
---@return boolean owned
function GameTooltip:IsOwned(frame) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_NumLines)
---@return number lines
function GameTooltip:NumLines() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAllowShowWithNoLines)
---@param bool boolean
function GameTooltip:SetAllowShowWithNoLines(bool) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAnchorType)
function GameTooltip:SetAnchorType(anchorType, Xoffset, Yoffset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCustomLineSpacing)
function GameTooltip:SetCustomLineSpacing(spacing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCustomWordWrapMinWidth)
function GameTooltip:SetCustomWordWrapMinWidth(width) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetFrameStack)
function GameTooltip:SetFrameStack(showhidden) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetMinimumWidth)
---@param width number
---@param force? boolean Default = false
function GameTooltip:SetMinimumWidth(width, force) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetObjectTooltipPosition)
function GameTooltip:SetObjectTooltipPosition() end

---@param owner Frame
---@param anchor TooltipAnchor
---@param x? number
---@param y? number
---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetOwner)
function GameTooltip:SetOwner(owner, anchor, x, y) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetPadding)
---@param right number
---@param bottom number
---@param left? number
---@param top? number
function GameTooltip:SetPadding(right, bottom, left, top) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetShrinkToFitWrapped)
function GameTooltip:SetShrinkToFitWrapped() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetText)
---@param text string
---@param colorR? number
---@param colorG? number
---@param colorB? number
---@param alpha? number
---@param wrap? boolean
function GameTooltip:SetText(text, colorR, colorG, colorB, alpha, wrap) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AddSpellByID)
function GameTooltip:AddSpellByID(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_AdvanceSecondaryCompareItem)
function GameTooltip:AdvanceSecondaryCompareItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetAzeritePowerID)
function GameTooltip:GetAzeritePowerID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetItem)
function GameTooltip:GetItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetSpell)
function GameTooltip:GetSpell() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_GetUnit)
function GameTooltip:GetUnit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_IsEquippedItem)
function GameTooltip:IsEquippedItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_IsUnit)
function GameTooltip:IsUnit(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_ResetSecondaryCompareItem)
function GameTooltip:ResetSecondaryCompareItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAchievementByID)
function GameTooltip:SetAchievementByID(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAction)
function GameTooltip:SetAction(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetArtifactItem)
function GameTooltip:SetArtifactItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetArtifactPowerByID)
function GameTooltip:SetArtifactPowerByID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAzeriteEssence)
function GameTooltip:SetAzeriteEssence(essenceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAzeriteEssenceSlot)
function GameTooltip:SetAzeriteEssenceSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetAzeritePower)
function GameTooltip:SetAzeritePower(itemID, itemLevel, powerID, owningItemLink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetBackpackToken)
function GameTooltip:SetBackpackToken(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetBagItem)
function GameTooltip:SetBagItem(bag, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetBagItemChild)
function GameTooltip:SetBagItemChild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetBuybackItem)
function GameTooltip:SetBuybackItem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCompanionPet)
function GameTooltip:SetCompanionPet() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCompareAzeritePower)
function GameTooltip:SetCompareAzeritePower(itemID, itemLevel, powerID, owningItemLink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCompareItem)
function GameTooltip:SetCompareItem(shoppingTooltipTwo, primaryMouseover) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetConduit)
function GameTooltip:SetConduit(id, rank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCurrencyByID)
function GameTooltip:SetCurrencyByID(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCurrencyToken)
function GameTooltip:SetCurrencyToken(tokenId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetCurrencyTokenByID)
function GameTooltip:SetCurrencyTokenByID(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetEquipmentSet)
function GameTooltip:SetEquipmentSet(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetExistingSocketGem)
function GameTooltip:SetExistingSocketGem(index,toDestroy) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetGuildBankItem)
function GameTooltip:SetGuildBankItem(tab, id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetHeirloomByItemID)
function GameTooltip:SetHeirloomByItemID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetHyperlink)
function GameTooltip:SetHyperlink(itemString_or_itemLink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetInboxItem)
function GameTooltip:SetInboxItem(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetInstanceLockEncountersComplete)
function GameTooltip:SetInstanceLockEncountersComplete(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetInventoryItem)
function GameTooltip:SetInventoryItem(unit, slot, nameOnly, hideUselessStats) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetInventoryItemByID)
function GameTooltip:SetInventoryItemByID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetItemByID)
function GameTooltip:SetItemByID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetItemKey)
function GameTooltip:SetItemKey(itemID, itemLevel, itemSuffix) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetLFGDungeonReward)
function GameTooltip:SetLFGDungeonReward(dungeonID, lootIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetLFGDungeonShortageReward)
function GameTooltip:SetLFGDungeonShortageReward(dungeonID, shortageSeverity, lootIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetLootCurrency)
function GameTooltip:SetLootCurrency(lootSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetLootItem)
function GameTooltip:SetLootItem(lootSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetLootRollItem)
function GameTooltip:SetLootRollItem(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetMerchantCostItem)
function GameTooltip:SetMerchantCostItem(index, item) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetMerchantItem)
function GameTooltip:SetMerchantItem(merchantSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetMountBySpellID)
function GameTooltip:SetMountBySpellID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetOwnedItemByID)
function GameTooltip:SetOwnedItemByID(ID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetPetAction)
function GameTooltip:SetPetAction(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetPossession)
function GameTooltip:SetPossession(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetPvpBrawl)
function GameTooltip:SetPvpBrawl() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetPvpTalent)
function GameTooltip:SetPvpTalent(talentID, talentIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestCurrency)
function GameTooltip:SetQuestCurrency(type, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestItem)
function GameTooltip:SetQuestItem(type, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestLogCurrency)
function GameTooltip:SetQuestLogCurrency(type, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestLogItem)
function GameTooltip:SetQuestLogItem(type, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestLogRewardSpell)
function GameTooltip:SetQuestLogRewardSpell(rewardSpellIndex, questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestLogSpecialItem)
function GameTooltip:SetQuestLogSpecialItem(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestPartyProgress)
function GameTooltip:SetQuestPartyProgress(questID, omitTitle, ignoreActivePlayer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetQuestRewardSpell)
function GameTooltip:SetQuestRewardSpell(rewardSpellIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetRecipeRankInfo)
function GameTooltip:SetRecipeRankInfo(recipeID, learnedRank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetRecipeReagentItem)
function GameTooltip:SetRecipeReagentItem(recipeID, reagentIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetRecipeResultItem)
function GameTooltip:SetRecipeResultItem(recipeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetRuneforgeResultItem)
function GameTooltip:SetRuneforgeResultItem(itemID, itemLevel, powerID, modifiers) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSendMailItem)
function GameTooltip:SetSendMailItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetShapeshift)
function GameTooltip:SetShapeshift(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSocketedItem)
function GameTooltip:SetSocketedItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSocketedRelic)
function GameTooltip:SetSocketedRelic(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSocketGem)
function GameTooltip:SetSocketGem(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSpecialPvpBrawl)
function GameTooltip:SetSpecialPvpBrawl() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSpellBookItem)
function GameTooltip:SetSpellBookItem(spellId, bookType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetSpellByID)
function GameTooltip:SetSpellByID(spellId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetTalent)
function GameTooltip:SetTalent(talentIndex, isInspect, talentGroup, inspectedUnit, classId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetTotem)
function GameTooltip:SetTotem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetToyByItemID)
function GameTooltip:SetToyByItemID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetTradePlayerItem)
function GameTooltip:SetTradePlayerItem(tradeSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetTradeTargetItem)
function GameTooltip:SetTradeTargetItem(tradeSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetTrainerService)
function GameTooltip:SetTrainerService(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetTransmogrifyItem)
function GameTooltip:SetTransmogrifyItem(slotId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnit)
function GameTooltip:SetUnit(unit, hideStatus) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitAura)
function GameTooltip:SetUnitAura(unit, auraIndex, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitBuff)
function GameTooltip:SetUnitBuff(unit, buffIndex, raidFilter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitBuffByAuraInstanceID)
function GameTooltip:SetUnitBuffByAuraInstanceID(unitTokenString, auraInstanceID, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitDebuff)
function GameTooltip:SetUnitDebuff(unit, buffIndex, raidFilter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUnitDebuffByAuraInstanceID)
function GameTooltip:SetUnitDebuffByAuraInstanceID(unitTokenString, auraInstanceID, filter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetUpgradeItem)
function GameTooltip:SetUpgradeItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetVoidDepositItem)
function GameTooltip:SetVoidDepositItem(slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetVoidItem)
function GameTooltip:SetVoidItem(slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetVoidWithdrawalItem)
function GameTooltip:SetVoidWithdrawalItem(slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GameTooltip_SetWeeklyReward)
function GameTooltip:SetWeeklyReward(itemDBID) end
