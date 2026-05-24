---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ModelScene)
---@class ModelScene : Frame
local ModelScene = {}
---@class modelscene : ModelScene
---@class MODELSCENE : ModelScene

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_ClearFog)
function ModelScene:ClearFog() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_CreateActor)
---@param name string?
---@param template string?
---@return ModelSceneActor actor
function ModelScene:CreateActor(name, template) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetActorAtIndex)
---@param index number
---@return ModelSceneActor actor
function ModelScene:GetActorAtIndex(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraFarClip)
---@return number farClip
function ModelScene:GetCameraFarClip() end

---Field of view in radians
---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraFieldOfView)
---@return number fov
function ModelScene:GetCameraFieldOfView() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraForward)
---@return number forwardX
---@return number forwardY
---@return number forwardZ
function ModelScene:GetCameraForward() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraNearClip)
---@return number nearClip
function ModelScene:GetCameraNearClip() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraPosition)
---@return number positionX
---@return number positionY
---@return number positionZ
function ModelScene:GetCameraPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraRight)
---@return number rightX
---@return number rightY
---@return number rightZ
function ModelScene:GetCameraRight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetCameraUp)
---@return number upX
---@return number upY
---@return number upZ
function ModelScene:GetCameraUp() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetDrawLayer)
---@return DrawLayer layer
---@return number sublevel
function ModelScene:GetDrawLayer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetFogColor)
---@return number colorR
---@return number colorG
---@return number colorB
function ModelScene:GetFogColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetFogFar)
---@return number far
function ModelScene:GetFogFar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetFogNear)
---@return number near
function ModelScene:GetFogNear() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetLightAmbientColor)
---@return number colorR
---@return number colorG
---@return number colorB
function ModelScene:GetLightAmbientColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetLightDiffuseColor)
---@return number colorR
---@return number colorG
---@return number colorB
function ModelScene:GetLightDiffuseColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetLightDirection)
---@return number directionX
---@return number directionY
---@return number directionZ
function ModelScene:GetLightDirection() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetLightPosition)
---@return number positionX
---@return number positionY
---@return number positionZ
function ModelScene:GetLightPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetLightType)
---@return Enum.ModelLightType? lightType
function ModelScene:GetLightType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetNumActors)
---@return number numActors
function ModelScene:GetNumActors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetViewInsets)
---@return uiUnit left
---@return uiUnit right
---@return uiUnit top
---@return uiUnit bottom
function ModelScene:GetViewInsets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_GetViewTranslation)
---@return number translationX
---@return number translationY
function ModelScene:GetViewTranslation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_IsLightVisible)
---@return boolean isVisible
function ModelScene:IsLightVisible() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_Project3DPointTo2D)
---@param pointX number
---@param pointY number
---@param pointZ number
---@return number point2DX
---@return number point2DY
---@return number depth
function ModelScene:Project3DPointTo2D(pointX, pointY, pointZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraFarClip)
---@param farClip number
function ModelScene:SetCameraFarClip(farClip) end

---Field of view in radians
---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraFieldOfView)
---@param fov number
function ModelScene:SetCameraFieldOfView(fov) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraNearClip)
---@param nearClip number
function ModelScene:SetCameraNearClip(nearClip) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraOrientationByAxisVectors)
---@param forwardX number
---@param forwardY number
---@param forwardZ number
---@param rightX number
---@param rightY number
---@param rightZ number
---@param upX number
---@param upY number
---@param upZ number
function ModelScene:SetCameraOrientationByAxisVectors(forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraOrientationByYawPitchRoll)
---@param yaw number
---@param pitch number
---@param roll number
function ModelScene:SetCameraOrientationByYawPitchRoll(yaw, pitch, roll) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetCameraPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function ModelScene:SetCameraPosition(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetDesaturation)
---@param strength number
function ModelScene:SetDesaturation(strength) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetDrawLayer)
---@param layer DrawLayer
function ModelScene:SetDrawLayer(layer) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetFogColor)
---@param colorR number
---@param colorG number
---@param colorB number
function ModelScene:SetFogColor(colorR, colorG, colorB) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetFogFar)
---@param far number
function ModelScene:SetFogFar(far) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetFogNear)
---@param near number
function ModelScene:SetFogNear(near) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightAmbientColor)
---@param colorR number
---@param colorG number
---@param colorB number
function ModelScene:SetLightAmbientColor(colorR, colorG, colorB) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightDiffuseColor)
---@param colorR number
---@param colorG number
---@param colorB number
function ModelScene:SetLightDiffuseColor(colorR, colorG, colorB) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightDirection)
---@param directionX number
---@param directionY number
---@param directionZ number
function ModelScene:SetLightDirection(directionX, directionY, directionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function ModelScene:SetLightPosition(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightType)
---@param lightType number|Enum.ModelLightType
function ModelScene:SetLightType(lightType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetLightVisible)
---@param visible? boolean Default = false
function ModelScene:SetLightVisible(visible) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetPaused)
---@param paused boolean
---@param affectsGlobalPause? boolean Default = true
function ModelScene:SetPaused(paused, affectsGlobalPause) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetViewInsets)
---@param left uiUnit
---@param right uiUnit
---@param top uiUnit
---@param bottom uiUnit
function ModelScene:SetViewInsets(left, right, top, bottom) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_SetViewTranslation)
---@param translationX number
---@param translationY number
function ModelScene:SetViewTranslation(translationX, translationY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ModelScene_TakeActor)
function ModelScene:TakeActor() end
