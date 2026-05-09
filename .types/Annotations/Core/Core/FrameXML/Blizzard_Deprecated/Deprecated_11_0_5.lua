---@meta _

---@deprecated
---Deprecated by [C_TaskQuest.GetQuestsOnMap](https://warcraft.wiki.gg/wiki/API_C_TaskQuest.GetQuestsOnMap)
---@param uiMapID number
---@return QuestPOIMapInfo[] taskPOIs
function C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) end

---@deprecated
---Deprecated by [C_MerchantFrame.GetItemInfo](https://warcraft.wiki.gg/wiki/API_C_MerchantFrame.GetItemInfo)
---@param index number
---@return string name
---@return number texture
---@return number price
---@return number stackCount
---@return number numAvailable
---@return boolean isPurchasable
---@return boolean isUsable
---@return boolean hasExtendedCost
---@return number currencyID
---@return number spellID
function GetMerchantItemInfo(index) end

---@deprecated
---Deprecated by [C_ChallengeMode.GetChallengeCompletionInfo](https://warcraft.wiki.gg/wiki/API_C_ChallengeMode.GetChallengeCompletionInfo)
---@return number mapChallengeModeID
---@return number level
---@return number time
---@return boolean onTime
---@return number keystoneUpgradeLevels
---@return boolean practiceRun
---@return number oldOverallDungeonScore
---@return number newOverallDungeonScore
---@return boolean isAffixRecord
---@return boolean isMapRecord, 0
---@return boolean isEligibleForScore
---@return ChallengeModeCompletionMemberInfo[] members
function C_ChallengeMode.GetCompletionInfo() end

---@deprecated
---@return boolean
function C_MythicPlus.IsWeeklyRewardAvailable() end
