---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ModelSceneActorBase)
---@class ModelSceneActorBase : Object
local ModelSceneActorBase = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_ClearModel)
function ModelSceneActorBase:ClearModel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetActiveBoundingBox)
---@return vector3 boxBottom
---@return vector3 boxTop
function ModelSceneActorBase:GetActiveBoundingBox() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetAlpha)
---@return number alpha
function ModelSceneActorBase:GetAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetAnimation)
---@return AnimationDataEnum animation
function ModelSceneActorBase:GetAnimation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetAnimationBlendOperation)
---@return Enum.ModelBlendOperation blendOp
function ModelSceneActorBase:GetAnimationBlendOperation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetAnimationVariation)
---@return number variation
function ModelSceneActorBase:GetAnimationVariation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetDesaturation)
---@return number strength
function ModelSceneActorBase:GetDesaturation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetMaxBoundingBox)
---@return vector3 boxBottom
---@return vector3 boxTop
function ModelSceneActorBase:GetMaxBoundingBox() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetModelFileID)
---@return fileID file
function ModelSceneActorBase:GetModelFileID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetModelPath)
---@return string path
function ModelSceneActorBase:GetModelPath() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetModelUnitGUID)
---@return WOWGUID guid
function ModelSceneActorBase:GetModelUnitGUID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetParticleOverrideScale)
---@return number? scale
function ModelSceneActorBase:GetParticleOverrideScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetPitch)
---@return number pitch
function ModelSceneActorBase:GetPitch() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetPosition)
---@return number positionX
---@return number positionY
---@return number positionZ
function ModelSceneActorBase:GetPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetRoll)
---@return number roll
function ModelSceneActorBase:GetRoll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetScale)
---@return number scale
function ModelSceneActorBase:GetScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetSpellVisualKit)
---@return number spellVisualKitID
function ModelSceneActorBase:GetSpellVisualKit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_GetYaw)
---@return number yaw
function ModelSceneActorBase:GetYaw() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_Hide)
function ModelSceneActorBase:Hide() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_IsLoaded)
---@return boolean isLoaded
function ModelSceneActorBase:IsLoaded() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_IsPreferringModelCollisionBounds)
---@return boolean preferringCollisionBounds
function ModelSceneActorBase:IsPreferringModelCollisionBounds() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_IsShown)
---@return boolean isShown
function ModelSceneActorBase:IsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_IsUsingCenterForOrigin)
---@return boolean x
---@return boolean y
---@return boolean z
function ModelSceneActorBase:IsUsingCenterForOrigin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_IsVisible)
---@return boolean isVisible
function ModelSceneActorBase:IsVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_PlayAnimationKit)
---@param animationKit number
---@param isLooping? boolean Default = false
function ModelSceneActorBase:PlayAnimationKit(animationKit, isLooping) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetAlpha)
---@param alpha number
function ModelSceneActorBase:SetAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetAnimation)
---@param animation AnimationDataEnum
---@param variation? number
---@param animSpeed? number Default = 1
---@param animOffsetSeconds? number Default = 0
function ModelSceneActorBase:SetAnimation(animation, variation, animSpeed, animOffsetSeconds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetAnimationBlendOperation)
---@param blendOp number|Enum.ModelBlendOperation
function ModelSceneActorBase:SetAnimationBlendOperation(blendOp) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetDesaturation)
---@param strength number
function ModelSceneActorBase:SetDesaturation(strength) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetGradientMask)
---@param gradientIndex0 number
---@param gradientIndex1 number
---@param gradientIndex2 number
---@param gradientIndex3 number
function ModelSceneActorBase:SetGradientMask(gradientIndex0, gradientIndex1, gradientIndex2, gradientIndex3) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByCreatureDisplayID)
---@param creatureDisplayID number
---@param useActivePlayerCustomizations? boolean Default = false
---@return boolean success
function ModelSceneActorBase:SetModelByCreatureDisplayID(creatureDisplayID, useActivePlayerCustomizations) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByFileID)
---@param asset FileAsset
---@param useMips? boolean Default = false
---@return boolean success
function ModelSceneActorBase:SetModelByFileID(asset, useMips) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByPath)
---@param asset FileAsset
---@param useMips? boolean Default = false
---@return boolean success
function ModelSceneActorBase:SetModelByPath(asset, useMips) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetModelByUnit)
---@param unit UnitToken
---@param sheatheWeapons? boolean Default = false
---@param autoDress? boolean Default = true
---@param hideWeapons? boolean Default = false
---@param usePlayerNativeForm? boolean Default = true
---@param holdBowString? boolean Default = false
---@param customRaceID? number
---@return boolean success
function ModelSceneActorBase:SetModelByUnit(unit, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm, holdBowString, customRaceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetParticleOverrideScale)
---@param scale? number
function ModelSceneActorBase:SetParticleOverrideScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetPitch)
---@param pitch number
function ModelSceneActorBase:SetPitch(pitch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetPlayerModelFromGlues)
---@param characterIndex? number
---@param sheatheWeapons? boolean Default = false
---@param autoDress? boolean Default = true
---@param hideWeapons? boolean Default = false
---@param usePlayerNativeForm? boolean Default = true
---@param customRaceID? number
---@return boolean success
function ModelSceneActorBase:SetPlayerModelFromGlues(characterIndex, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm, customRaceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function ModelSceneActorBase:SetPosition(positionX, positionY, positionZ) end

---If true, will try to use the collision bounds of models for sizing and centering. Will fall back to default model bounds if set to False, or if collision bounds are unavailable.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetPreferModelCollisionBounds)
---@param preferCollisionBounds boolean
function ModelSceneActorBase:SetPreferModelCollisionBounds(preferCollisionBounds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetRoll)
---@param roll number
function ModelSceneActorBase:SetRoll(roll) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetScale)
---@param scale number
function ModelSceneActorBase:SetScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetShown)
---@param show? boolean Default = false
function ModelSceneActorBase:SetShown(show) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetSpellVisualKit)
---@param spellVisualKitID? number Default = 0
---@param oneShot? boolean Default = false
function ModelSceneActorBase:SetSpellVisualKit(spellVisualKitID, oneShot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetUseCenterForOrigin)
---@param x? boolean Default = false
---@param y? boolean Default = false
---@param z? boolean Default = false
function ModelSceneActorBase:SetUseCenterForOrigin(x, y, z) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_SetYaw)
---@param yaw number
function ModelSceneActorBase:SetYaw(yaw) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_Show)
function ModelSceneActorBase:Show() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelSceneActorBase_StopAnimationKit)
function ModelSceneActorBase:StopAnimationKit() end
