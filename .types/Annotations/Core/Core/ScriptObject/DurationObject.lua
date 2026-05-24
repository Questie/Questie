---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject)
---@class DurationObject
local DurationObject = {}

---Copies another duration object and assigns it to this one.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_Assign)
---@param other DurationObject
function DurationObject:Assign(other) end

---Returns a copy of this duration object.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_Copy)
---@return DurationObject copy
function DurationObject:Copy() end

---Calculates the elapsed duration in seconds and evaluates it against a supplied curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_EvaluateElapsedDuration)
---@param curve CurveObjectBase
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return LuaCurveEvaluatedResult result
function DurationObject:EvaluateElapsedDuration(curve, modifier) end

---Calculates the elapsed duration as a percentage value and evaluates it against a supplied curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_EvaluateElapsedPercent)
---@param curve CurveObjectBase
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return LuaCurveEvaluatedResult result
function DurationObject:EvaluateElapsedPercent(curve, modifier) end

---Calculates the remaining duration in seconds and evaluates it against a supplied curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_EvaluateRemainingDuration)
---@param curve CurveObjectBase
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return LuaCurveEvaluatedResult result
function DurationObject:EvaluateRemainingDuration(curve, modifier) end

---Calculates the remaining duration as a percentage value and evaluates it against a supplied curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_EvaluateRemainingPercent)
---@param curve CurveObjectBase
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return LuaCurveEvaluatedResult result
function DurationObject:EvaluateRemainingPercent(curve, modifier) end

---Returns the current time of the clock source used by this object.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetClockTime)
---@return FrameTime clockTime
function DurationObject:GetClockTime() end

---Calculates the elapsed duration of the stored time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetElapsedDuration)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return DurationSeconds elapsedDuration
function DurationObject:GetElapsedDuration(modifier) end

---Calculates the elapsed duration as a percentage value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetElapsedPercent)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return number elapsedPercent
function DurationObject:GetElapsedPercent(modifier) end

---Calculates the end time of the stored time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetEndTime)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return FrameTime endTime
function DurationObject:GetEndTime(modifier) end

---Returns the divisor used to convert a duration from real time to base time.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetModRate)
---@return number modRate
function DurationObject:GetModRate() end

---Calculates the remaining duration of the stored time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetRemainingDuration)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return DurationSeconds remainingDuration
function DurationObject:GetRemainingDuration(modifier) end

---Calculates the remaining duration as a percentage value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetRemainingPercent)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return number remainingPercent
function DurationObject:GetRemainingPercent(modifier) end

---Calculates the start time of the stored time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetStartTime)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return FrameTime startTime
function DurationObject:GetStartTime(modifier) end

---Calculates the total duration of the stored time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_GetTotalDuration)
---@param modifier? Enum.DurationTimeModifier Default = RealTime
---@return DurationSeconds totalDuration
function DurationObject:GetTotalDuration(modifier) end

---Returns true if the duration has been configured with any secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_HasSecretValues)
---@return boolean hasSecretValues
function DurationObject:HasSecretValues() end

---Returns true if the duration object is measuring a zero duration time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_IsZero)
---@return boolean isZero
function DurationObject:IsZero() end

---Resets the duration object to represent a zero duration time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_Reset)
function DurationObject:Reset() end

---Configures the duration object to represent an end time and a duration.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_SetTimeFromEnd)
---@param endTime FrameTime
---@param duration DurationSeconds
---@param modRate? number Default = 1
function DurationObject:SetTimeFromEnd(endTime, duration, modRate) end

---Configures the duration object to represent a start time and a duration.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_SetTimeFromStart)
---@param startTime FrameTime
---@param duration DurationSeconds
---@param modRate? number Default = 1
function DurationObject:SetTimeFromStart(startTime, duration, modRate) end

---Configures the duration object to represent a fixed start and end time span. If the end time is earlier than the start time, the duration will clamp to zero.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_SetTimeSpan)
---@param startTime FrameTime
---@param endTime FrameTime
function DurationObject:SetTimeSpan(startTime, endTime) end

---Resets all state on the duration, and clears the secret values flag.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_DurationObject_SetToDefaults)
function DurationObject:SetToDefaults() end
