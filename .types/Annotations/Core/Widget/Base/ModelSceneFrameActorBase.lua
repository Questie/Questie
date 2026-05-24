---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ModelSceneFrameActorBase)
---@class ModelSceneFrameActorBase : Object
local ModelSceneFrameActorBase = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_ClearModel)
function ModelSceneFrameActorBase:ClearModel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetActiveBoundingBox)
---@return vector3 boxBottom
---@return vector3 boxTop
function ModelSceneFrameActorBase:GetActiveBoundingBox() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetAlpha)
---@return number alpha
function ModelSceneFrameActorBase:GetAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetAnimation)
---@return AnimationDataEnum animation
function ModelSceneFrameActorBase:GetAnimation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetAnimationBlendOperation)
---@return Enum.ModelBlendOperation blendOp
function ModelSceneFrameActorBase:GetAnimationBlendOperation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetAnimationVariation)
---@return number variation
function ModelSceneFrameActorBase:GetAnimationVariation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetDesaturation)
---@return number strength
function ModelSceneFrameActorBase:GetDesaturation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetMaxBoundingBox)
---@return vector3 boxBottom
---@return vector3 boxTop
function ModelSceneFrameActorBase:GetMaxBoundingBox() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetModelFileID)
---@return fileID file
function ModelSceneFrameActorBase:GetModelFileID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetModelPath)
---@return string path
function ModelSceneFrameActorBase:GetModelPath() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetModelUnitGUID)
---@return WOWGUID guid
function ModelSceneFrameActorBase:GetModelUnitGUID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetParticleOverrideScale)
---@return number? scale
function ModelSceneFrameActorBase:GetParticleOverrideScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetPitch)
---@return number pitch
function ModelSceneFrameActorBase:GetPitch() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetPosition)
---@return number positionX
---@return number positionY
---@return number positionZ
function ModelSceneFrameActorBase:GetPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetRoll)
---@return number roll
function ModelSceneFrameActorBase:GetRoll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetScale)
---@return number scale
function ModelSceneFrameActorBase:GetScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetSpellVisualKit)
---@return number spellVisualKitID
function ModelSceneFrameActorBase:GetSpellVisualKit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_GetYaw)
---@return number yaw
function ModelSceneFrameActorBase:GetYaw() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_Hide)
function ModelSceneFrameActorBase:Hide() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_IsLoaded)
---@return boolean isLoaded
function ModelSceneFrameActorBase:IsLoaded() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_IsShown)
---@return boolean isShown
function ModelSceneFrameActorBase:IsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_IsUsingCenterForOrigin)
---@return boolean x
---@return boolean y
---@return boolean z
function ModelSceneFrameActorBase:IsUsingCenterForOrigin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_IsVisible)
---@return boolean isVisible
function ModelSceneFrameActorBase:IsVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_PlayAnimationKit)
---@param animationKit number
---@param isLooping? boolean Default = false
function ModelSceneFrameActorBase:PlayAnimationKit(animationKit, isLooping) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetAlpha)
---@param alpha number
function ModelSceneFrameActorBase:SetAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetAnimation)
---@param animation AnimationDataEnum
---@param variation? number
---@param animSpeed? number Default = 1
---@param animOffsetSeconds? number Default = 0
function ModelSceneFrameActorBase:SetAnimation(animation, variation, animSpeed, animOffsetSeconds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetAnimationBlendOperation)
---@param blendOp number|Enum.ModelBlendOperation
function ModelSceneFrameActorBase:SetAnimationBlendOperation(blendOp) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetDesaturation)
---@param strength number
function ModelSceneFrameActorBase:SetDesaturation(strength) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetModelByCreatureDisplayID)
---@param creatureDisplayID number
---@param useActivePlayerCustomizations? boolean Default = false
---@return boolean success
function ModelSceneFrameActorBase:SetModelByCreatureDisplayID(creatureDisplayID, useActivePlayerCustomizations) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetModelByFileID)
---@param asset FileAsset
---@param useMips? boolean Default = false
---@return boolean success
function ModelSceneFrameActorBase:SetModelByFileID(asset, useMips) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetModelByPath)
---@param asset FileAsset
---@param useMips? boolean Default = false
---@return boolean success
function ModelSceneFrameActorBase:SetModelByPath(asset, useMips) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetModelByUnit)
---@param unit UnitToken
---@param sheatheWeapons? boolean Default = false
---@param autoDress? boolean Default = true
---@param hideWeapons? boolean Default = false
---@param usePlayerNativeForm? boolean Default = true
---@param holdBowString? boolean Default = false
---@return boolean success
function ModelSceneFrameActorBase:SetModelByUnit(unit, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm, holdBowString) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetParticleOverrideScale)
---@param scale? number
function ModelSceneFrameActorBase:SetParticleOverrideScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetPitch)
---@param pitch number
function ModelSceneFrameActorBase:SetPitch(pitch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetPlayerModelFromGlues)
---@param characterIndex? number
---@param sheatheWeapons? boolean Default = false
---@param autoDress? boolean Default = true
---@param hideWeapons? boolean Default = false
---@param usePlayerNativeForm? boolean Default = true
---@return boolean success
function ModelSceneFrameActorBase:SetPlayerModelFromGlues(characterIndex, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function ModelSceneFrameActorBase:SetPosition(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetRoll)
---@param roll number
function ModelSceneFrameActorBase:SetRoll(roll) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetScale)
---@param scale number
function ModelSceneFrameActorBase:SetScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetShown)
---@param show? boolean Default = false
function ModelSceneFrameActorBase:SetShown(show) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetSpellVisualKit)
---@param spellVisualKitID? number Default = 0
---@param oneShot? boolean Default = false
function ModelSceneFrameActorBase:SetSpellVisualKit(spellVisualKitID, oneShot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetUseCenterForOrigin)
---@param x? boolean Default = false
---@param y? boolean Default = false
---@param z? boolean Default = false
function ModelSceneFrameActorBase:SetUseCenterForOrigin(x, y, z) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_SetYaw)
---@param yaw number
function ModelSceneFrameActorBase:SetYaw(yaw) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_Show)
function ModelSceneFrameActorBase:Show() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneFrameActorBase_StopAnimationKit)
function ModelSceneFrameActorBase:StopAnimationKit() end
