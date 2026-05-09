---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_DressUpModel)
---@class DressUpModel : PlayerModel
local DressUpModel = {}
---@class dressupmodel : DressUpModel
---@class DRESSUPMODEL : DressUpModel

---@param scriptType ScriptDressUpModel
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function DressUpModel:GetScript(scriptType, bindingType) end

---@param scriptType ScriptDressUpModel
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function DressUpModel:HasScript(scriptType) end

---@param scriptType ScriptDressUpModel
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function DressUpModel:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptDressUpModel
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function DressUpModel:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_Dress)
function DressUpModel:Dress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetAutoDress)
---@return boolean enabled
function DressUpModel:GetAutoDress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetItemTransmogInfo)
---@param inventorySlot number
---@return ItemTransmogInfo itemTransmogInfo
function DressUpModel:GetItemTransmogInfo(inventorySlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetItemTransmogInfoList)
---@return ItemTransmogInfo[] infoList
function DressUpModel:GetItemTransmogInfoList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetObeyHideInTransmogFlag)
---@return boolean enabled
function DressUpModel:GetObeyHideInTransmogFlag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetSheathed)
---@return boolean sheathed
function DressUpModel:GetSheathed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetUseTransmogChoices)
---@return boolean enabled
function DressUpModel:GetUseTransmogChoices() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_GetUseTransmogSkin)
---@return boolean enabled
function DressUpModel:GetUseTransmogSkin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_IsGeoReady)
---@return boolean ready
function DressUpModel:IsGeoReady() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_IsSlotAllowed)
---@param slot number
---@return boolean allowed
function DressUpModel:IsSlotAllowed(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_IsSlotVisible)
---@param slot number
---@return boolean visible
function DressUpModel:IsSlotVisible(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_SetAutoDress)
---@param enabled? boolean Default = false
function DressUpModel:SetAutoDress(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_SetItemTransmogInfo)
---@param itemTransmogInfo ItemTransmogInfo
---@param inventorySlot? number
---@param ignoreChildItems? boolean Default = false
---@return Enum.ItemTryOnReason result
function DressUpModel:SetItemTransmogInfo(itemTransmogInfo, inventorySlot, ignoreChildItems) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_SetObeyHideInTransmogFlag)
---@param enabled? boolean Default = false
function DressUpModel:SetObeyHideInTransmogFlag(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_SetSheathed)
---@param sheathed? boolean Default = false
---@param hideWeapons? boolean Default = false
function DressUpModel:SetSheathed(sheathed, hideWeapons) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_SetUseTransmogChoices)
---@param enabled? boolean Default = false
function DressUpModel:SetUseTransmogChoices(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_SetUseTransmogSkin)
---@param enabled? boolean Default = false
function DressUpModel:SetUseTransmogSkin(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_TryOn)
---@param linkOrItemModifiedAppearanceID IDOrLink
---@param handSlotName? string
---@param spellEnchantID? number
---@return Enum.ItemTryOnReason? result
function DressUpModel:TryOn(linkOrItemModifiedAppearanceID, handSlotName, spellEnchantID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_Undress)
function DressUpModel:Undress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DressUpModel_UndressSlot)
---@param inventorySlot number
function DressUpModel:UndressSlot(inventorySlot) end
