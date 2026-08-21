---@meta _
---@class UnitDamageAbsorbInfo
---@field amount number
---@field clamped boolean

---@class UnitHealAbsorbInfo
---@field amount number
---@field clamped boolean

---@class UnitHealPredictionValues
---@field health number? Default = 0
---@field healthMax number? Default = 0
---@field totalIncomingHeals number? Default = 0
---@field totalIncomingHealsFromHealer number? Default = 0
---@field totalDamageAbsorbs number? Default = 0
---@field totalHealAbsorbs number? Default = 0

---@class UnitIncomingHealInfo
---@field amount number
---@field amountFromHealer number
---@field amountFromOthers number
---@field clamped boolean
