---@meta _
C_ScriptedAnimations = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ScriptedAnimations.GetAllScriptedAnimationEffects)
---@return ScriptedAnimationEffect[] scriptedAnimationEffects
function C_ScriptedAnimations.GetAllScriptedAnimationEffects() end

---@class ScriptedAnimationEffect
---@field id number
---@field visual fileID
---@field visualScale number
---@field duration number
---@field trajectory Enum.ScriptedAnimationTrajectory
---@field yawRadians number
---@field pitchRadians number
---@field rollRadians number
---@field offsetX number
---@field offsetY number
---@field offsetZ number
---@field animation number
---@field animationSpeed number
---@field alpha number
---@field useTargetAsSource boolean
---@field startBehavior Enum.ScriptedAnimationBehavior?
---@field startSoundKitID number?
---@field finishEffectID number?
---@field finishBehavior Enum.ScriptedAnimationBehavior?
---@field finishSoundKitID number?
---@field startAlphaFade number?
---@field startAlphaFadeDuration number?
---@field endAlphaFade number?
---@field endAlphaFadeDuration number?
---@field animationStartOffset number?
---@field loopingSoundKitID number?
---@field particleOverrideScale number?
