---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_UnitHealPredictionCalculator)
---@class UnitHealPredictionCalculator
local UnitHealPredictionCalculator = {}

---Calculates the percentage of current unit health and evaluates it against the supplied curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_EvaluateCurrentHealthPercent)
---@param curve LuaCurveObjectBase
---@return LuaCurveEvaluatedResult result
function UnitHealPredictionCalculator:EvaluateCurrentHealthPercent(curve) end

---Calculates the percentage of missing unit health and evaluates it against the supplied curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_EvaluateMissingHealthPercent)
---@param curve LuaCurveObjectBase
---@return LuaCurveEvaluatedResult result
function UnitHealPredictionCalculator:EvaluateMissingHealthPercent(curve) end

---Returns the base amount of unit health.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetCurrentHealth)
---@return number currentHealth
function UnitHealPredictionCalculator:GetCurrentHealth() end

---Returns the percentage of current unit health.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetCurrentHealthPercent)
---@return number currentHealthPercent
function UnitHealPredictionCalculator:GetCurrentHealthPercent() end

---Returns the configured damage absorb clamping mode.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetDamageAbsorbClampMode)
---@return Enum.UnitDamageAbsorbClampMode damageAbsorbClampMode
function UnitHealPredictionCalculator:GetDamageAbsorbClampMode() end

---Calculates damage absorb values and clamping according to the configured options.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetDamageAbsorbs)
---@return number amount
---@return boolean clamped
function UnitHealPredictionCalculator:GetDamageAbsorbs() end

---Returns the configured heal absorb clamping mode.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetHealAbsorbClampMode)
---@return Enum.UnitHealAbsorbClampMode healAbsorbClampMode
function UnitHealPredictionCalculator:GetHealAbsorbClampMode() end

---Returns the configured heal absorb processing mode.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetHealAbsorbMode)
---@return Enum.UnitHealAbsorbMode healAbsorbMode
function UnitHealPredictionCalculator:GetHealAbsorbMode() end

---Calculates heal absorb values and clamping according to the configured options.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetHealAbsorbs)
---@return number amount
---@return boolean clamped
function UnitHealPredictionCalculator:GetHealAbsorbs() end

---Returns the configured incoming heal clamping mode.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetIncomingHealClampMode)
---@return Enum.UnitIncomingHealClampMode incomingHealClampMode
function UnitHealPredictionCalculator:GetIncomingHealClampMode() end

---Returns the configured incoming heal maximum overflow percentage.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetIncomingHealOverflowPercent)
---@return number incomingHealOverflowPercent
function UnitHealPredictionCalculator:GetIncomingHealOverflowPercent() end

---Calculates incoming heal values and clamping according to the configured options.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetIncomingHeals)
---@return number amount
---@return number amountFromHealer
---@return number amountFromOthers
---@return boolean clamped
function UnitHealPredictionCalculator:GetIncomingHeals() end

---Returns the maximum clamping amount for damage absorbs.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMaximumDamageAbsorbs)
---@return number maximumDamageAbsorbs
function UnitHealPredictionCalculator:GetMaximumDamageAbsorbs() end

---Returns the maximum clamping amount for heal absorbs.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMaximumHealAbsorbs)
---@return number maximumHealAbsorbs
function UnitHealPredictionCalculator:GetMaximumHealAbsorbs() end

---Returns the base amount of maximum unit health.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMaximumHealth)
---@return number maximumHealth
function UnitHealPredictionCalculator:GetMaximumHealth() end

---Returns the configured maximum health mode.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMaximumHealthMode)
---@return Enum.UnitMaximumHealthMode maximumHealthMode
function UnitHealPredictionCalculator:GetMaximumHealthMode() end

---Returns the maximum clamping amount for incoming heals.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMaximumIncomingHeals)
---@return number maximumIncomingHeals
function UnitHealPredictionCalculator:GetMaximumIncomingHeals() end

---Returns the base amount of missing unit health.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMissingHealth)
---@return number missingHealth
function UnitHealPredictionCalculator:GetMissingHealth() end

---Returns the percentage of missing unit health.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetMissingHealthPercent)
---@return number missingHealthPercent
function UnitHealPredictionCalculator:GetMissingHealthPercent() end

---Returns the raw total figures used for data calculations.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetPredictedValues)
---@return UnitHealPredictionValues predictedValues
function UnitHealPredictionCalculator:GetPredictedValues() end

---Returns the base total amount of all applied damage absorb shields.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetTotalDamageAbsorbs)
---@return number totalDamageAbsorbs
function UnitHealPredictionCalculator:GetTotalDamageAbsorbs() end

---Returns the base total amount of all applied heal absorption effects.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetTotalHealAbsorbs)
---@return number totalHealAbsorbs
function UnitHealPredictionCalculator:GetTotalHealAbsorbs() end

---Returns the base total amount of all incoming heals.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetTotalIncomingHeals)
---@return number totalIncomingHeals
function UnitHealPredictionCalculator:GetTotalIncomingHeals() end

---Returns the base total amount of all incoming heals from the healer unit, if any.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_GetTotalIncomingHealsFromHealer)
---@return number totalIncomingHealsFromHealer
function UnitHealPredictionCalculator:GetTotalIncomingHealsFromHealer() end

---Returns true if the object has been configured with any secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_HasSecretValues)
---@return boolean hasSecretValues
function UnitHealPredictionCalculator:HasSecretValues() end

---Resets all stored state on the object.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_Reset)
function UnitHealPredictionCalculator:Reset() end

---Resets all stored healing values used for calculations.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_ResetPredictedValues)
function UnitHealPredictionCalculator:ResetPredictedValues() end

---Changes the clamping mode used when calculating damage absorb amounts.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetDamageAbsorbClampMode)
---@param damageAbsorbClampMode Enum.UnitDamageAbsorbClampMode
function UnitHealPredictionCalculator:SetDamageAbsorbClampMode(damageAbsorbClampMode) end

---Changes the clamping mode used when calculating heal absorb amounts.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetHealAbsorbClampMode)
---@param healAbsorbClampMode Enum.UnitHealAbsorbClampMode
function UnitHealPredictionCalculator:SetHealAbsorbClampMode(healAbsorbClampMode) end

---Changes the processing mode used when calculating both heal absorb and incoming heal amounts.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetHealAbsorbMode)
---@param healAbsorbMode Enum.UnitHealAbsorbMode
function UnitHealPredictionCalculator:SetHealAbsorbMode(healAbsorbMode) end

---Changes the clamping mode used when calculating incoming heal amounts.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetIncomingHealClampMode)
---@param incomingHealClampMode Enum.UnitIncomingHealClampMode
function UnitHealPredictionCalculator:SetIncomingHealClampMode(incomingHealClampMode) end

---Changes the maximum overflow percentage for incoming heals. Increasing this to a value over 1.0 will mean that incoming heals can extend beyond maximum health.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetIncomingHealOverflowPercent)
---@param incomingHealOverflowPercent number
function UnitHealPredictionCalculator:SetIncomingHealOverflowPercent(incomingHealOverflowPercent) end

---Changes the calculation mode for maximum health values used for clamping.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetMaximumHealthMode)
---@param maximumHealthMode Enum.UnitMaximumHealthMode
function UnitHealPredictionCalculator:SetMaximumHealthMode(maximumHealthMode) end

---Sets the healing values used for all calculations.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetPredictedValues)
---@param predictedValues UnitHealPredictionValues
function UnitHealPredictionCalculator:SetPredictedValues(predictedValues) end

---Resets all state on the object, and clears the secret values flag.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealPredictionCalculator_SetToDefaults)
function UnitHealPredictionCalculator:SetToDefaults() end
