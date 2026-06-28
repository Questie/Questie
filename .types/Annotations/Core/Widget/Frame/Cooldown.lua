---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Cooldown)
---@class Cooldown : Frame
local Cooldown = {}
---@class cooldown : Cooldown
---@class COOLDOWN : Cooldown

---@param scriptType ScriptCooldown
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function Cooldown:GetScript(scriptType, bindingType) end

---@param scriptType ScriptCooldown
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function Cooldown:HasScript(scriptType) end

---@param scriptType ScriptCooldown
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function Cooldown:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptCooldown
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function Cooldown:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_Clear)
function Cooldown:Clear() end

---The returned duration unit is milliseconds, unaffected by modRate.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetCooldownDisplayDuration)
---@return number duration
function Cooldown:GetCooldownDisplayDuration() end

---The returned duration unit is milliseconds and is multiplied by the modRate.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetCooldownDuration)
---@return number duration
function Cooldown:GetCooldownDuration() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetCooldownTimes)
---@return number start
---@return number duration
function Cooldown:GetCooldownTimes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetCountdownFontString)
---@return SimpleFontString countdownString
function Cooldown:GetCountdownFontString() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetDrawBling)
---@return boolean drawBling
function Cooldown:GetDrawBling() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetDrawEdge)
---@return boolean drawEdge
function Cooldown:GetDrawEdge() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetDrawSwipe)
---@return boolean drawSwipe
function Cooldown:GetDrawSwipe() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetEdgeScale)
---@return number edgeScale
function Cooldown:GetEdgeScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetHideCountdownNumbers)
---@return boolean hideNumbers
function Cooldown:GetHideCountdownNumbers() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetMinimumCountdownDuration)
---@return number milliseconds
function Cooldown:GetMinimumCountdownDuration() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetReverse)
---@return boolean reverse
function Cooldown:GetReverse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetRotation)
---@return number rotationRadians
function Cooldown:GetRotation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_GetUseAuraDisplayTime)
---@return boolean useAuraDisplayTime
function Cooldown:GetUseAuraDisplayTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_IsPaused)
---@return boolean isPaused
function Cooldown:IsPaused() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_Pause)
function Cooldown:Pause() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_Resume)
function Cooldown:Resume() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetBlingTexture)
---@param texture FileAsset
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number
function Cooldown:SetBlingTexture(texture, colorR, colorG, colorB, colorA) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCooldown)
---@param start number
---@param duration number
---@param modRate? number Default = 1
function Cooldown:SetCooldown(start, duration, modRate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCooldownDuration)
---@param duration number
---@param modRate? number Default = 1
function Cooldown:SetCooldownDuration(duration, modRate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCooldownFromDurationObject)
---@param duration LuaDurationObject
---@param clearIfZero? boolean Default = true
function Cooldown:SetCooldownFromDurationObject(duration, clearIfZero) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCooldownFromExpirationTime)
---@param expirationTime DurationSeconds
---@param duration DurationSeconds
---@param modRate? number Default = 1
function Cooldown:SetCooldownFromExpirationTime(expirationTime, duration, modRate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCooldownUNIX)
---@param start number
---@param duration number
---@param modRate? number Default = 1
function Cooldown:SetCooldownUNIX(start, duration, modRate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCountdownAbbrevThreshold)
---@param seconds number
function Cooldown:SetCountdownAbbrevThreshold(seconds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetCountdownFont)
---@param fontName string
function Cooldown:SetCountdownFont(fontName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetDrawBling)
---@param drawBling? boolean Default = false
function Cooldown:SetDrawBling(drawBling) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetDrawEdge)
---@param drawEdge? boolean Default = false
function Cooldown:SetDrawEdge(drawEdge) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetDrawSwipe)
---@param drawSwipe? boolean Default = false
function Cooldown:SetDrawSwipe(drawSwipe) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetEdgeColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function Cooldown:SetEdgeColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetEdgeScale)
---@param scale number
function Cooldown:SetEdgeScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetEdgeTexture)
---@param texture FileAsset
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number
function Cooldown:SetEdgeTexture(texture, colorR, colorG, colorB, colorA) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetHideCountdownNumbers)
---@param hideNumbers? boolean Default = false
function Cooldown:SetHideCountdownNumbers(hideNumbers) end

---Controls the minimum duration above which countdown text will be shown. This is applied based upon the total duration of the cooldown, not the remaining duration as it ticks down.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetMinimumCountdownDuration)
---@param milliseconds number
function Cooldown:SetMinimumCountdownDuration(milliseconds) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetPaused)
---@param paused boolean
function Cooldown:SetPaused(paused) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetReverse)
---@param reverse? boolean Default = false
function Cooldown:SetReverse(reverse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetRotation)
---@param rotationRadians number
function Cooldown:SetRotation(rotationRadians) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetSwipeColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function Cooldown:SetSwipeColor(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetSwipeTexture)
---@param texture FileAsset
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number
function Cooldown:SetSwipeTexture(texture, colorR, colorG, colorB, colorA) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetTexCoordRange)
---@param low vector2
---@param high vector2
function Cooldown:SetTexCoordRange(low, high) end

---Aura durations are displayed slightly differently than cooldown durations. Setting this to true will adjust the display logic to stay in sync with aura timers.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetUseAuraDisplayTime)
---@param useAuraDisplayTime? boolean Default = false
function Cooldown:SetUseAuraDisplayTime(useAuraDisplayTime) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Cooldown_SetUseCircularEdge)
---@param useCircularEdge? boolean Default = false
function Cooldown:SetUseCircularEdge(useCircularEdge) end
