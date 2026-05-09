---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_PlayerModel)
---@class CharacterModelBase : Model
local CharacterModelBase = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_ApplySpellVisualKit)
---@param spellVisualKitID number
---@param oneShot? boolean Default = false
function CharacterModelBase:ApplySpellVisualKit(spellVisualKitID, oneShot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_CanSetUnit)
---@param unit UnitToken
function CharacterModelBase:CanSetUnit(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_FreezeAnimation)
---@param anim AnimationDataEnum
---@param variation number
---@param frame number
function CharacterModelBase:FreezeAnimation(anim, variation, frame) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_GetDisplayInfo)
---@return number displayID
function CharacterModelBase:GetDisplayInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_GetDoBlend)
---@return boolean doBlend
function CharacterModelBase:GetDoBlend() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_GetKeepModelOnHide)
---@return boolean keepModelOnHide
function CharacterModelBase:GetKeepModelOnHide() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_HasAnimation)
---@param anim AnimationDataEnum
---@return boolean hasAnimation
function CharacterModelBase:HasAnimation(anim) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_PlayAnimKit)
---@param animKit number
---@param loop? boolean Default = false
function CharacterModelBase:PlayAnimKit(animKit, loop) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_RefreshCamera)
function CharacterModelBase:RefreshCamera() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_RefreshUnit)
function CharacterModelBase:RefreshUnit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetAnimation)
---@param anim AnimationDataEnum
---@param variation? number
function CharacterModelBase:SetAnimation(anim, variation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetBarberShopAlternateForm)
function CharacterModelBase:SetBarberShopAlternateForm() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetCamDistanceScale)
---@param scale number
function CharacterModelBase:SetCamDistanceScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetCreature)
---@param creatureID number
---@param displayID? number Default = 0
function CharacterModelBase:SetCreature(creatureID, displayID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetDisplayInfo)
---@param displayID number
---@param mountDisplayID? number
function CharacterModelBase:SetDisplayInfo(displayID, mountDisplayID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetDoBlend)
---@param doBlend? boolean Default = false
function CharacterModelBase:SetDoBlend(doBlend) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetItem)
---@param itemID number
---@param appearanceModID? number
---@param itemVisualID? number
function CharacterModelBase:SetItem(itemID, appearanceModID, itemVisualID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetItemAppearance)
---@param itemAppearanceID number
---@param itemVisualID? number
---@param itemSubclass? number|Enum.ItemWeaponSubclass
function CharacterModelBase:SetItemAppearance(itemAppearanceID, itemVisualID, itemSubclass) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetKeepModelOnHide)
---@param keepModelOnHide boolean
function CharacterModelBase:SetKeepModelOnHide(keepModelOnHide) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetPortraitZoom)
---@param zoom number
function CharacterModelBase:SetPortraitZoom(zoom) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetRotation)
---@param radians number
---@param animate? boolean Default = true
function CharacterModelBase:SetRotation(radians, animate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_SetUnit)
---@param unit UnitToken
---@param blend? boolean Default = true
---@param useNativeForm? boolean
---@return boolean success
function CharacterModelBase:SetUnit(unit, blend, useNativeForm) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_StopAnimKit)
function CharacterModelBase:StopAnimKit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CharacterModelBase_ZeroCachedCenterXY)
function CharacterModelBase:ZeroCachedCenterXY() end
