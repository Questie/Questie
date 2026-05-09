---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Animation)
---@class Animation : Object
local Animation = {}
---@class animation : Animation
---@class ANIMATION : Animation

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetParent)
---@return AnimationGroup parent
function Animation:GetParent() end


---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetDuration)
---@return number durationSec
function Animation:GetDuration() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetElapsed)
---@return number elapsedSec
function Animation:GetElapsed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetEndDelay)
---@return number delaySec
function Animation:GetEndDelay() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetOrder)
---@return number order
function Animation:GetOrder() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetProgress)
---@return number progress
function Animation:GetProgress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetRegionParent)
---@return CScriptObject region
function Animation:GetRegionParent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetScript)
---@param scriptTypeName ScriptAnimation
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return luaFunction script
function Animation:GetScript(scriptTypeName, bindingType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetSmoothProgress)
---@return number progress
function Animation:GetSmoothProgress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetSmoothing)
---@return SmoothingType weights
function Animation:GetSmoothing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetStartDelay)
---@return number delaySec
function Animation:GetStartDelay() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_GetTarget)
---@return CScriptObject target
function Animation:GetTarget() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_HasScript)
---@param scriptName string
---@return boolean hasScript
function Animation:HasScript(scriptName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_HookScript)
---@param scriptTypeName ScriptAnimation
---@param script luaFunction
---@param bindingType? LE_SCRIPT_BINDING_TYPE
function Animation:HookScript(scriptTypeName, script, bindingType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_IsDelaying)
---@return boolean isDelaying
function Animation:IsDelaying() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_IsDone)
---@return boolean isDone
function Animation:IsDone() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_IsPaused)
---@return boolean isPaused
function Animation:IsPaused() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_IsPlaying)
---@return boolean isPlaying
function Animation:IsPlaying() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_IsStopped)
---@return boolean isStopped
function Animation:IsStopped() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_Pause)
function Animation:Pause() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_Play)
function Animation:Play() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_Restart)
function Animation:Restart() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetChildKey)
---@param childKey string
---@return boolean success
function Animation:SetChildKey(childKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetDuration)
---@param durationSec number
---@param recomputeGroupDuration? boolean Default = true
function Animation:SetDuration(durationSec, recomputeGroupDuration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetEndDelay)
---@param delaySec number
---@param recomputeGroupDuration? boolean Default = true
function Animation:SetEndDelay(delaySec, recomputeGroupDuration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetOrder)
---@param newOrder number
function Animation:SetOrder(newOrder) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetParent)
---@param parent SimpleAnimGroup
---@param order? number
function Animation:SetParent(parent, order) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetPlaying)
---@param play boolean
function Animation:SetPlaying(play) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetScript)
---@param scriptTypeName string
---@param script? luaFunction
function Animation:SetScript(scriptTypeName, script) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetSmoothProgress)
---@param durationSec number
function Animation:SetSmoothProgress(durationSec) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetSmoothing)
---@param weights SmoothingType
function Animation:SetSmoothing(weights) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetStartDelay)
---@param delaySec number
---@param recomputeGroupDuration? boolean Default = true
function Animation:SetStartDelay(delaySec, recomputeGroupDuration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetTarget)
---@param target CScriptObject
---@return boolean success
function Animation:SetTarget(target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetTargetKey)
---@param key string
---@return boolean success
function Animation:SetTargetKey(key) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetTargetName)
---@param name string
---@return boolean success
function Animation:SetTargetName(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_SetTargetParent)
---@return boolean success
function Animation:SetTargetParent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Animation_Stop)
function Animation:Stop() end
