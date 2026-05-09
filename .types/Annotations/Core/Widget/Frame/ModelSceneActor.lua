---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ModelSceneActor)
---@class ModelSceneActor : ModelSceneFrameActorBase
local ModelSceneActor = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_AttachToMount)
---@param rider ModelSceneFrameActor
---@param animation AnimationDataEnum
---@param spellKitVisualID? number
---@return boolean success
function ModelSceneActor:AttachToMount(rider, animation, spellKitVisualID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_CalculateMountScale)
---@param rider ModelSceneFrameActor
---@return number scale
function ModelSceneActor:CalculateMountScale(rider) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_Dress)
function ModelSceneActor:Dress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_DressPlayerSlot)
---@param invSlot number
function ModelSceneActor:DressPlayerSlot(invSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetAutoDress)
---@return boolean autoDress
function ModelSceneActor:GetAutoDress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetItemTransmogInfo)
---@param inventorySlots number
---@return ItemTransmogInfo? itemTransmogInfo
function ModelSceneActor:GetItemTransmogInfo(inventorySlots) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetItemTransmogInfoList)
---@return ItemTransmogInfo[] infoList
function ModelSceneActor:GetItemTransmogInfoList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetObeyHideInTransmogFlag)
---@return boolean obey
function ModelSceneActor:GetObeyHideInTransmogFlag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetPaused)
---@return boolean paused
---@return boolean globalPaused
function ModelSceneActor:GetPaused() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetSheathed)
---@return boolean sheathed
function ModelSceneActor:GetSheathed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetUseTransmogChoices)
---@return boolean use
function ModelSceneActor:GetUseTransmogChoices() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_GetUseTransmogSkin)
---@return boolean use
function ModelSceneActor:GetUseTransmogSkin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_IsGeoReady)
---@return boolean isReady
function ModelSceneActor:IsGeoReady() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_IsSlotAllowed)
---@param inventorySlots number
---@return boolean allowed
function ModelSceneActor:IsSlotAllowed(inventorySlots) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_IsSlotVisible)
---@param inventorySlots number
---@return boolean visible
function ModelSceneActor:IsSlotVisible(inventorySlots) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_ReleaseFrontEndCharacterDisplays)
---@return boolean success
function ModelSceneActor:ReleaseFrontEndCharacterDisplays() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_ResetNextHandSlot)
function ModelSceneActor:ResetNextHandSlot() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetAutoDress)
---@param autoDress boolean
function ModelSceneActor:SetAutoDress(autoDress) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetFrontEndLobbyModelFromDefaultCharacterDisplay)
---@param characterIndex number
---@return boolean success
function ModelSceneActor:SetFrontEndLobbyModelFromDefaultCharacterDisplay(characterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetItemTransmogInfo)
---@param transmogInfo ItemTransmogInfo
---@param inventorySlots? number
---@param ignoreChildItems? boolean Default = false
---@return Enum.ItemTryOnReason result
function ModelSceneActor:SetItemTransmogInfo(transmogInfo, inventorySlots, ignoreChildItems) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetModelByHyperlink)
---@param link string
---@return boolean success
function ModelSceneActor:SetModelByHyperlink(link) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetObeyHideInTransmogFlag)
---@param obey boolean
function ModelSceneActor:SetObeyHideInTransmogFlag(obey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetPaused)
---@param paused boolean
---@param affectsGlobalPause? boolean Default = true
function ModelSceneActor:SetPaused(paused, affectsGlobalPause) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetPlayerModelFromGlues)
---@param sheatheWeapons? boolean Default = false
---@param autoDress? boolean Default = true
---@param hideWeapons? boolean Default = false
---@param usePlayerNativeForm? boolean Default = true
---@return boolean success
function ModelSceneActor:SetPlayerModelFromGlues(sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetSheathed)
---@param sheathed boolean
---@param hidden? boolean Default = false
function ModelSceneActor:SetSheathed(sheathed, hidden) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetUseTransmogChoices)
---@param use boolean
function ModelSceneActor:SetUseTransmogChoices(use) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_SetUseTransmogSkin)
---@param use boolean
function ModelSceneActor:SetUseTransmogSkin(use) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_TryOn)
---@param itemLinkOrItemModifiedAppearanceID string
---@param handSlotName? string
---@param spellEnchantmentID? number Default = 0
---@return Enum.ItemTryOnReason? reason
function ModelSceneActor:TryOn(itemLinkOrItemModifiedAppearanceID, handSlotName, spellEnchantmentID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_Undress)
---@param includeWeapons? boolean Default = true
function ModelSceneActor:Undress(includeWeapons) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActor_UndressSlot)
---@param inventorySlots number
function ModelSceneActor:UndressSlot(inventorySlots) end
