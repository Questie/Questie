---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Model)
---@class Model : Frame
local Model = {}
---@class model : Model
---@class MODEL : Model

---@param scriptType ScriptModel
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function Model:GetScript(scriptType, bindingType) end

---@param scriptType ScriptModel
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function Model:HasScript(scriptType) end

---@param scriptType ScriptModel
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function Model:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptModel
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function Model:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_AdvanceTime)
function Model:AdvanceTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_ClearFog)
function Model:ClearFog() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_ClearModel)
function Model:ClearModel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_ClearTransform)
function Model:ClearTransform() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetCameraDistance)
---@return number distance
function Model:GetCameraDistance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetCameraFacing)
---@return number radians
function Model:GetCameraFacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetCameraPosition)
---@return number positionX
---@return number positionY
---@return number positionZ
function Model:GetCameraPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetCameraRoll)
---@return number radians
function Model:GetCameraRoll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetCameraTarget)
---@return number targetX
---@return number targetY
---@return number targetZ
function Model:GetCameraTarget() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetDesaturation)
---@return number strength
function Model:GetDesaturation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetFacing)
---@return number facing
function Model:GetFacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetFogColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function Model:GetFogColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetFogFar)
---@return number fogFar
function Model:GetFogFar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetFogNear)
---@return number fogNear
function Model:GetFogNear() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetLight)
---@return boolean enabled
---@return ModelLight light
function Model:GetLight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetModelAlpha)
---@return number alpha
function Model:GetModelAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetModelDrawLayer)
---@return DrawLayer layer
---@return number sublayer
function Model:GetModelDrawLayer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetModelFileID)
---@return fileID modelFileID
function Model:GetModelFileID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetModelScale)
---@return number scale
function Model:GetModelScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetPaused)
---@return boolean paused
function Model:GetPaused() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetPitch)
---@return number pitch
function Model:GetPitch() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetPosition)
---@return number positionX
---@return number positionY
---@return number positionZ
function Model:GetPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetRoll)
---@return number roll
function Model:GetRoll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetShadowEffect)
---@return number strength
function Model:GetShadowEffect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetViewInsets)
---@return uiUnit left
---@return uiUnit right
---@return uiUnit top
---@return uiUnit bottom
function Model:GetViewInsets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetViewTranslation)
---@return uiUnit x
---@return uiUnit y
function Model:GetViewTranslation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_GetWorldScale)
---@return number worldScale
function Model:GetWorldScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_HasAttachmentPoints)
---@return boolean hasAttachmentPoints
function Model:HasAttachmentPoints() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_HasCustomCamera)
---@return boolean hasCustomCamera
function Model:HasCustomCamera() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_IsUsingModelCenterToTransform)
---@return boolean useCenter
function Model:IsUsingModelCenterToTransform() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_MakeCurrentCameraCustom)
function Model:MakeCurrentCameraCustom() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_ReplaceIconTexture)
---@param asset FileAsset
function Model:ReplaceIconTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCamera)
---@param cameraIndex number
function Model:SetCamera(cameraIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCameraDistance)
---@param distance number
function Model:SetCameraDistance(distance) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCameraFacing)
---@param radians number
function Model:SetCameraFacing(radians) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCameraPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function Model:SetCameraPosition(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCameraRoll)
---@param radians number
function Model:SetCameraRoll(radians) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCameraTarget)
---@param targetX number
---@param targetY number
---@param targetZ number
function Model:SetCameraTarget(targetX, targetY, targetZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetCustomCamera)
---@param cameraIndex number
function Model:SetCustomCamera(cameraIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetDesaturation)
---@param strength number
function Model:SetDesaturation(strength) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetFacing)
---@param facing number
function Model:SetFacing(facing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetFogColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function Model:SetFogColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetFogFar)
---@param fogFar number
function Model:SetFogFar(fogFar) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetFogNear)
---@param fogNear number
function Model:SetFogNear(fogNear) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetGlow)
---@param glow number
function Model:SetGlow(glow) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetLight)
---@param enabled boolean
---@param light ModelLight
function Model:SetLight(enabled, light) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetModel)
---@param asset ModelAsset
---@param noMip? boolean Default = false
function Model:SetModel(asset, noMip) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetModelAlpha)
---@param alpha number
function Model:SetModelAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetModelDrawLayer)
---@param layer DrawLayer
function Model:SetModelDrawLayer(layer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetModelScale)
---@param scale number
function Model:SetModelScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetParticlesEnabled)
---@param enabled boolean
function Model:SetParticlesEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetPaused)
---@param paused boolean
function Model:SetPaused(paused) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetPitch)
---@param pitch number
function Model:SetPitch(pitch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function Model:SetPosition(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetRoll)
---@param roll number
function Model:SetRoll(roll) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetSequence)
---@param sequence number
function Model:SetSequence(sequence) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetSequenceTime)
---@param sequence number
---@param timeOffset number
function Model:SetSequenceTime(sequence, timeOffset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetShadowEffect)
---@param strength number
function Model:SetShadowEffect(strength) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetTransform)
---@param translation? vector3
---@param rotation? vector3
---@param scale? number
function Model:SetTransform(translation, rotation, scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetViewInsets)
---@param left uiUnit
---@param right uiUnit
---@param top uiUnit
---@param bottom uiUnit
function Model:SetViewInsets(left, right, top, bottom) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_SetViewTranslation)
---@param x uiUnit
---@param y uiUnit
function Model:SetViewTranslation(x, y) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_TransformCameraSpaceToModelSpace)
---@param cameraPosition vector3
---@return vector3 modelPosition
function Model:TransformCameraSpaceToModelSpace(cameraPosition) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Model_UseModelCenterToTransform)
---@param useCenter boolean
function Model:UseModelCenterToTransform(useCenter) end
