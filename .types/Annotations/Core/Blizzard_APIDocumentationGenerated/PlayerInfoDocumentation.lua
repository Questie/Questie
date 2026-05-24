---@meta _
C_PlayerInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.CanPlayerEnterChromieTime)
---@return boolean canEnter
function C_PlayerInfo.CanPlayerEnterChromieTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.CanPlayerUseAreaLoot)
---@return boolean canUseAreaLoot
function C_PlayerInfo.CanPlayerUseAreaLoot() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.CanPlayerUseEventScheduler)
---@return boolean canUseEventScheduler
function C_PlayerInfo.CanPlayerUseEventScheduler() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.CanPlayerUseMountEquipment)
---@return boolean canUseMountEquipment
---@return string failureReason
function C_PlayerInfo.CanPlayerUseMountEquipment() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.CanUseItem)
---@param itemID number
---@return boolean isUseable
function C_PlayerInfo.CanUseItem(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetAlternateFormInfo)
---@return boolean hasAlternateForm
---@return boolean inAlternateForm
function C_PlayerInfo.GetAlternateFormInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetContentDifficultyCreatureForPlayer)
---@param unitToken UnitToken
---@return Enum.RelativeContentDifficulty difficulty
function C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetContentDifficultyQuestForPlayer)
---@param questID number
---@return Enum.RelativeContentDifficulty difficulty
function C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetDisplayID)
---@return number displayID
function C_PlayerInfo.GetDisplayID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetGlidingInfo)
---@return boolean isGliding
---@return boolean canGlide
---@return number forwardSpeed
function C_PlayerInfo.GetGlidingInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetInstancesUnlockedAtLevel)
---@param level number
---@param isRaid boolean
---@return number[] dungeonID
function C_PlayerInfo.GetInstancesUnlockedAtLevel(level, isRaid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetNativeDisplayID)
---@return number nativeDisplayID
function C_PlayerInfo.GetNativeDisplayID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetPetStableCreatureDisplayInfoID)
---@param index number
---@return number creatureDisplayInfoID
function C_PlayerInfo.GetPetStableCreatureDisplayInfoID(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetPlayerCharacterData)
---@return PlayerInfoCharacterData characterData
function C_PlayerInfo.GetPlayerCharacterData() end

---Returns the players mythic+ rating summary which includes the runs they've completed as well as their current season m+ rating
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetPlayerMythicPlusRatingSummary)
---@param playerToken UnitToken
---@return MythicPlusRatingSummary ratingSummary
function C_PlayerInfo.GetPlayerMythicPlusRatingSummary(playerToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.HasAccountInventoryLock)
---@return boolean hasAccountInventoryLock
function C_PlayerInfo.HasAccountInventoryLock() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.HasVisibleInvSlot)
---@param slot number
---@return boolean isVisible
function C_PlayerInfo.HasVisibleInvSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsAccountBankEnabled)
---@return boolean isAccountBankEnabled
function C_PlayerInfo.IsAccountBankEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsCharacterBankEnabled)
---@return boolean isCharacterBankEnabled
function C_PlayerInfo.IsCharacterBankEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsDisplayRaceNative)
---@return boolean isDisplayRaceNative
function C_PlayerInfo.IsDisplayRaceNative() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer)
---@param expansionID number
---@return boolean isUnlocked
function C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(expansionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsMirrorImage)
---@return boolean isMirrorImage
function C_PlayerInfo.IsMirrorImage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsPlayerEligibleForNPE)
---@return boolean isEligible
---@return string failureReason
function C_PlayerInfo.IsPlayerEligibleForNPE() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsPlayerEligibleForNPEv2)
---@return boolean isEligible
---@return string failureReason
function C_PlayerInfo.IsPlayerEligibleForNPEv2() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsPlayerInChromieTime)
---@return boolean inChromieTime
function C_PlayerInfo.IsPlayerInChromieTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsPlayerNPERestricted)
---@return boolean isRestricted
function C_PlayerInfo.IsPlayerNPERestricted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsSelfFoundActive)
---@return boolean active
function C_PlayerInfo.IsSelfFoundActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsTradingPostAvailable)
---@return boolean isAvailable
function C_PlayerInfo.IsTradingPostAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsTravelersLogAvailable)
---@return boolean isAvailable
function C_PlayerInfo.IsTravelersLogAvailable() end

---@class MythicPlusRatingMapSummary
---@field challengeModeID number
---@field mapScore number
---@field bestRunLevel number
---@field bestRunDurationMS number
---@field finishedSuccess boolean

---@class MythicPlusRatingSummary
---@field currentSeasonScore number
---@field runs MythicPlusRatingMapSummary[]
