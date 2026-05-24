---@meta _
C_ModelInfo = {}

---This function does nothing in public clients
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.AddActiveModelScene)
---@param modelSceneFrame ModelSceneFrame
---@param modelSceneID number
function C_ModelInfo.AddActiveModelScene(modelSceneFrame, modelSceneID) end

---This function does nothing in public clients
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.AddActiveModelSceneActor)
---@param modelSceneFrameActor ModelSceneFrameActor
---@param modelSceneActorID number
function C_ModelInfo.AddActiveModelSceneActor(modelSceneFrameActor, modelSceneActorID) end

---This function does nothing in public clients
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.ClearActiveModelScene)
---@param modelSceneFrame ModelSceneFrame
function C_ModelInfo.ClearActiveModelScene(modelSceneFrame) end

---This function does nothing in public clients
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.ClearActiveModelSceneActor)
---@param modelSceneFrameActor ModelSceneFrameActor
function C_ModelInfo.ClearActiveModelSceneActor(modelSceneFrameActor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.GetModelSceneActorDisplayInfoByID)
---@param modelActorDisplayID number
---@return UIModelSceneActorDisplayInfo actorDisplayInfo
function C_ModelInfo.GetModelSceneActorDisplayInfoByID(modelActorDisplayID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.GetModelSceneActorInfoByID)
---@param modelActorID number
---@return UIModelSceneActorInfo actorInfo
function C_ModelInfo.GetModelSceneActorInfoByID(modelActorID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.GetModelSceneCameraInfoByID)
---@param modelSceneCameraID number
---@return UIModelSceneCameraInfo modelSceneCameraInfo
function C_ModelInfo.GetModelSceneCameraInfoByID(modelSceneCameraID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModelInfo.GetModelSceneInfoByID)
---@param modelSceneID number
---@return Enum.ModelSceneType modelSceneType
---@return number[] modelCameraIDs
---@return number[] modelActorsIDs
---@return number flags
function C_ModelInfo.GetModelSceneInfoByID(modelSceneID) end

---@class UIModelSceneActorDisplayInfo
---@field animation number
---@field animationVariation number
---@field animSpeed number
---@field animationKitID number?
---@field spellVisualKitID number?
---@field alpha number
---@field scale number

---@class UIModelSceneActorInfo
---@field modelActorID number
---@field scriptTag string
---@field position vector3
---@field yaw number
---@field pitch number
---@field roll number
---@field normalizeScaleAggressiveness number?
---@field useCenterForOriginX boolean
---@field useCenterForOriginY boolean
---@field useCenterForOriginZ boolean
---@field modelActorDisplayID number?

---@class UIModelSceneCameraInfo
---@field modelSceneCameraID number
---@field scriptTag string
---@field cameraType string
---@field target vector3
---@field yaw number
---@field pitch number
---@field roll number
---@field zoomDistance number
---@field minZoomDistance number
---@field maxZoomDistance number
---@field zoomedTargetOffset vector3
---@field zoomedYawOffset number
---@field zoomedPitchOffset number
---@field zoomedRollOffset number
---@field flags Enum.ModelSceneSetting
