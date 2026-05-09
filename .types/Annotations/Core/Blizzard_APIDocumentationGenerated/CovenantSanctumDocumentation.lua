---@meta _
C_CovenantSanctumUI = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.CanAccessReservoir)
---@return boolean canAccess
function C_CovenantSanctumUI.CanAccessReservoir() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.CanDepositAnima)
---@return boolean canDeposit
function C_CovenantSanctumUI.CanDepositAnima() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.DepositAnima)
function C_CovenantSanctumUI.DepositAnima() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.EndInteraction)
function C_CovenantSanctumUI.EndInteraction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetAnimaInfo)
---@return number currencyID
---@return number maxDisplayableValue
function C_CovenantSanctumUI.GetAnimaInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetCurrentTalentTreeID)
---@return number? currentTalentTreeID
function C_CovenantSanctumUI.GetCurrentTalentTreeID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetFeatures)
---@return CovenantSanctumFeatureInfo[] features
function C_CovenantSanctumUI.GetFeatures() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetRenownLevel)
---@return number level
function C_CovenantSanctumUI.GetRenownLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetRenownLevels)
---@param covenantID number
---@return CovenantSanctumRenownLevelInfo[] levels
function C_CovenantSanctumUI.GetRenownLevels(covenantID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetRenownRewardsForLevel)
---@param covenantID number
---@param renownLevel number
---@return CovenantSanctumRenownRewardInfo[] rewards
function C_CovenantSanctumUI.GetRenownRewardsForLevel(covenantID, renownLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetSanctumType)
---@return Enum.GarrTalentFeatureSubtype? sanctumType
function C_CovenantSanctumUI.GetSanctumType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.GetSoulCurrencies)
---@return number[] currencyIDs
function C_CovenantSanctumUI.GetSoulCurrencies() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.HasMaximumRenown)
---@return boolean hasMaxRenown
function C_CovenantSanctumUI.HasMaximumRenown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.IsPlayerInRenownCatchUpMode)
---@return boolean isInCatchUpMode
function C_CovenantSanctumUI.IsPlayerInRenownCatchUpMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.IsWeeklyRenownCapped)
---@return boolean isWeeklyCapped
function C_CovenantSanctumUI.IsWeeklyRenownCapped() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantSanctumUI.RequestCatchUpState)
function C_CovenantSanctumUI.RequestCatchUpState() end

---@class CovenantSanctumFeatureInfo
---@field garrTalentTreeID number
---@field featureType number
---@field uiOrder number

---@class CovenantSanctumRenownLevelInfo
---@field level number
---@field locked boolean
---@field isMilestone boolean
---@field isCapstone boolean

---@class CovenantSanctumRenownRewardInfo
---@field uiOrder number
---@field itemID number?
---@field spellID number?
---@field mountID number?
---@field transmogID number?
---@field transmogSetID number?
---@field titleMaskID number?
---@field garrFollowerID number?
---@field transmogIllusionSourceID number?
---@field icon fileID?
---@field name string?
---@field description string?
---@field toastDescription string?
