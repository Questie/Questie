---@meta _
C_RecruitAFriend = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.CanSummonFriend)
---@param guid WOWGUID
---@return boolean result
function C_RecruitAFriend.CanSummonFriend(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.ClaimActivityReward)
---@param activityID number
---@param acceptanceID RecruitAcceptanceID
---@return boolean success
function C_RecruitAFriend.ClaimActivityReward(activityID, acceptanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.ClaimNextReward)
---@param rafVersion? Enum.RecruitAFriendRewardsVersion
---@return boolean success
function C_RecruitAFriend.ClaimNextReward(rafVersion) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.GenerateRecruitmentLink)
---@return boolean success
function C_RecruitAFriend.GenerateRecruitmentLink() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.GetRAFInfo)
---@return RafInfo info
function C_RecruitAFriend.GetRAFInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.GetRAFSystemInfo)
---@return RafSystemInfo systemInfo
function C_RecruitAFriend.GetRAFSystemInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.GetRecruitActivityRequirementsText)
---@param activityID number
---@param acceptanceID RecruitAcceptanceID
---@return string[] requirementsText
function C_RecruitAFriend.GetRecruitActivityRequirementsText(activityID, acceptanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.GetRecruitInfo)
---@return boolean active
---@return number faction
function C_RecruitAFriend.GetRecruitInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.GetSummonFriendCooldown)
---@return number startTimeSeconds
---@return number durationSeconds
---@return boolean enableCooldownTimer
function C_RecruitAFriend.GetSummonFriendCooldown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.IsEnabled)
---@return boolean enabled
function C_RecruitAFriend.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.IsRecruitAFriendLinked)
---@param guid WOWGUID
---@return boolean result
function C_RecruitAFriend.IsRecruitAFriendLinked(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.IsRecruitingEnabled)
---@return boolean enabled
function C_RecruitAFriend.IsRecruitingEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.RemoveRAFRecruit)
---@param wowAccountGUID WOWGUID
---@return boolean success
function C_RecruitAFriend.RemoveRAFRecruit(wowAccountGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.RequestUpdatedRecruitmentInfo)
---@return boolean success
function C_RecruitAFriend.RequestUpdatedRecruitmentInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecruitAFriend.SummonFriend)
---@param target WOWGUID
---@param name string
function C_RecruitAFriend.SummonFriend(target, name) end

---@class RafAppearanceInfo
---@field appearanceID number

---@class RafAppearanceSetInfo
---@field setID number
---@field setName string
---@field appearanceIDs number[]

---@class RafIllusionInfo
---@field spellItemEnchantmentID number

---@class RafInfo
---@field versions RafVersionInfo[]
---@field recruitmentInfo RafRecruitmentinfo?
---@field recruits RafRecruit[]
---@field claimInProgress boolean

---@class RafMonthCount
---@field lifetimeMonths number
---@field spentMonths number
---@field availableMonths number

---@class RafMountInfo
---@field spellID number
---@field mountID number

---@class RafPetInfo
---@field creatureID number
---@field speciesID number
---@field displayID number
---@field speciesName string
---@field description string

---@class RafRecruit
---@field bnetAccountID number
---@field wowAccountGUID WOWGUID
---@field battleTag string
---@field monthsRemaining number
---@field subStatus Enum.RafRecruitSubStatus
---@field acceptanceID RecruitAcceptanceID
---@field versionRecruited Enum.RecruitAFriendRewardsVersion
---@field activities RafRecruitActivity[]

---@class RafRecruitActivity
---@field activityID number
---@field rewardQuestID number
---@field state Enum.RafRecruitActivityState

---@class RafRecruitmentinfo
---@field recruitmentCode string
---@field recruitmentURL string
---@field expireTime number
---@field remainingTimeSeconds number
---@field totalUses number
---@field remainingUses number
---@field sourceRealm string
---@field sourceFaction string

---@class RafReward
---@field rewardID number
---@field rafVersion Enum.RecruitAFriendRewardsVersion
---@field itemID number
---@field rewardType Enum.RafRewardType
---@field petInfo RafPetInfo?
---@field mountInfo RafMountInfo?
---@field appearanceInfo RafAppearanceInfo?
---@field titleInfo RafTitleInfo?
---@field appearanceSetInfo RafAppearanceSetInfo?
---@field illusionInfo RafIllusionInfo?
---@field canClaim boolean
---@field claimed boolean
---@field canAfford boolean
---@field repeatable boolean
---@field repeatableClaimCount number
---@field monthsRequired number
---@field monthCost number
---@field availableInMonths number
---@field iconID fileID

---@class RafSystemInfo
---@field maxRecruits number
---@field maxRecruitMonths number
---@field maxRecruitmentUses number
---@field daysInCycle number

---@class RafTitleInfo
---@field titleMaskID number

---@class RafVersionInfo
---@field rafVersion Enum.RecruitAFriendRewardsVersion
---@field monthCount RafMonthCount
---@field rewards RafReward[]
---@field nextReward RafReward?
---@field numAffordableRewards number
---@field numRecruits number
