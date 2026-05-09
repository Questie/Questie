---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_CinematicModel)
---@class CinematicModel : PlayerModel
local CinematicModel = {}
---@class cinematicmodel : CinematicModel
---@class CINEMATICMODEL : CinematicModel

---@param scriptType ScriptCinematicModel
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function CinematicModel:GetScript(scriptType, bindingType) end

---@param scriptType ScriptCinematicModel
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function CinematicModel:HasScript(scriptType) end

---@param scriptType ScriptCinematicModel
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function CinematicModel:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptCinematicModel
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function CinematicModel:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_EquipItem)
---@param itemID number
function CinematicModel:EquipItem(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_InitializeCamera)
---@param scaleFactor? number Default = 0
function CinematicModel:InitializeCamera(scaleFactor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_InitializePanCamera)
---@param scaleFactor? number Default = 0
function CinematicModel:InitializePanCamera(scaleFactor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_RefreshCamera)
function CinematicModel:RefreshCamera() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetAnimOffset)
---@param offset number
function CinematicModel:SetAnimOffset(offset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetCameraPosition)
---@param positionX number
---@param positionY number
---@param positionZ number
function CinematicModel:SetCameraPosition(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetCameraTarget)
---@param positionX number
---@param positionY number
---@param positionZ number
function CinematicModel:SetCameraTarget(positionX, positionY, positionZ) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetCreatureData)
---@param creatureID number
function CinematicModel:SetCreatureData(creatureID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetFacingLeft)
---@param isFacingLeft? boolean Default = false
function CinematicModel:SetFacingLeft(isFacingLeft) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetFadeTimes)
---@param fadeInSeconds number
---@param fadeOutSeconds number
function CinematicModel:SetFadeTimes(fadeInSeconds, fadeOutSeconds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetHeightFactor)
---@param factor number
function CinematicModel:SetHeightFactor(factor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetJumpInfo)
---@param jumpLength number
---@param jumpHeight number
function CinematicModel:SetJumpInfo(jumpLength, jumpHeight) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetPanDistance)
---@param scale number
function CinematicModel:SetPanDistance(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetSpellVisualKit)
---@param visualKitID number
function CinematicModel:SetSpellVisualKit(visualKitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_SetTargetDistance)
---@param scale number
function CinematicModel:SetTargetDistance(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_StartPan)
---@param panType number
---@param durationSeconds number
---@param doFade? boolean Default = false
---@param visKitID? number Default = 0
---@param startPositionScale? number Default = 0
---@param speedMultiplier? number Default = 1
function CinematicModel:StartPan(panType, durationSeconds, doFade, visKitID, startPositionScale, speedMultiplier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_StopPan)
function CinematicModel:StopPan() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CinematicModel_UnequipItems)
function CinematicModel:UnequipItems() end
