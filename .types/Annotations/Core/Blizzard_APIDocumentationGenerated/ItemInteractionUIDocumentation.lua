---@meta _
C_ItemInteraction = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.ClearPendingItem)
function C_ItemInteraction.ClearPendingItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.CloseUI)
function C_ItemInteraction.CloseUI() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.GetChargeInfo)
---@return ItemInteractionChargeInfo chargeInfo
function C_ItemInteraction.GetChargeInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.GetItemConversionCurrencyCost)
---@param item ItemLocation
---@return ConversionCurrencyCost conversionCost
function C_ItemInteraction.GetItemConversionCurrencyCost(item) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.GetItemInteractionInfo)
---@return ItemInteractionFrameInfo? info
function C_ItemInteraction.GetItemInteractionInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.GetItemInteractionSpellId)
---@return number spellId
function C_ItemInteraction.GetItemInteractionSpellId() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.InitializeFrame)
function C_ItemInteraction.InitializeFrame() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.PerformItemInteraction)
function C_ItemInteraction.PerformItemInteraction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.Reset)
function C_ItemInteraction.Reset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemInteraction.SetPendingItem)
---@param item? ItemLocation
---@return boolean success
function C_ItemInteraction.SetPendingItem(item) end

---@class ConversionCurrencyCost
---@field currencyID number
---@field amount number

---@class ItemInteractionChargeInfo
---@field newChargeAmount number
---@field rechargeRate number
---@field timeToNextCharge number

---@class ItemInteractionFrameInfo
---@field textureKit textureKit
---@field openSoundKitID number
---@field closeSoundKitID number
---@field titleText string
---@field tutorialText string
---@field buttonText string
---@field interactionType Enum.UIItemInteractionType
---@field flags number
---@field description string?
---@field buttonTooltip string?
---@field confirmationDescription string?
---@field slotTooltip string?
---@field cost number?
---@field currencyTypeId number?
---@field dropInSlotSoundKitId number?
