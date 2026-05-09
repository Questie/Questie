---@meta _
C_GameRules = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.AutoConnectToGameModeRealm)
---@param gameModeRecordID number
function C_GameRules.AutoConnectToGameModeRealm(gameModeRecordID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.DoesGameModeHavePromo)
---@param gameModeRecordID number
---@return boolean hasPromo
function C_GameRules.DoesGameModeHavePromo(gameModeRecordID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetActiveGameMode)
---@return Enum.GameMode gameMode
function C_GameRules.GetActiveGameMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetCurrentEventRealmQueues)
---@return Enum.EventRealmQueues eventRealmQueues
function C_GameRules.GetCurrentEventRealmQueues() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetCurrentGameModeDisplayInfo)
---@return GameModeDisplayInfo? info
function C_GameRules.GetCurrentGameModeDisplayInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetCurrentGameModeRecordID)
---@return number gameModeRecordID
function C_GameRules.GetCurrentGameModeRecordID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetDisplayedGameModeRecordIDAtIndex)
---@param displayIndex number
---@return number gameModeRecordID
function C_GameRules.GetDisplayedGameModeRecordIDAtIndex(displayIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetGameModeDisplayInfoByRecordID)
---@param gameModeRecordID number
---@return GameModeDisplayInfo? info
function C_GameRules.GetGameModeDisplayInfoByRecordID(gameModeRecordID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetGameModeGlueScreenName)
---@return string screenName
function C_GameRules.GetGameModeGlueScreenName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetGameModePromoGlobalString)
---@param gameModeRecordID number
---@return string promoGlobalString
function C_GameRules.GetGameModePromoGlobalString(gameModeRecordID) end

---Returns the numeric value specified in the Game Rule, multiplied by 0.1 for every decimal place requested
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetGameRuleAsFloat)
---@param gameRule Enum.GameRule
---@param decimalPlaces? number Default = 0
---@return number value
function C_GameRules.GetGameRuleAsFloat(gameRule, decimalPlaces) end

---Returns the value specified in the Game Rule converted to a frame strata
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetGameRuleAsFrameStrata)
---@param gameRule Enum.GameRule
---@return string frameStrata
function C_GameRules.GetGameRuleAsFrameStrata(gameRule) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.GetNumDisplayedGameModes)
---@return number numDisplayedGameModes
function C_GameRules.GetNumDisplayedGameModes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.IsCharacterlessLoginActive)
---@return boolean active
function C_GameRules.IsCharacterlessLoginActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GameRules.IsGameRuleActive)
---@param gameRule Enum.GameRule
---@return boolean isActive
function C_GameRules.IsGameRuleActive(gameRule) end

---@class GameModeDisplayInfo
---@field logo fileID
---@field logoHeight number
---@field logoVerticalOffset number
---@field logoShrunkenHeight number
---@field logoUsesDarkBackdrop boolean
---@field characterCreateExtraHeight number
---@field characterCreateOuterBorder fileID
