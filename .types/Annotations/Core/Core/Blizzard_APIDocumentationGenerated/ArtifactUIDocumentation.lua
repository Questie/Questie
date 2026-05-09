---@meta _
C_ArtifactUI = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.AddPower)
---@param powerID number
---@return boolean success
function C_ArtifactUI.AddPower(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.ApplyCursorRelicToSlot)
---@param relicSlotIndex number
function C_ArtifactUI.ApplyCursorRelicToSlot(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.CanApplyArtifactRelic)
---@param relicItemID number
---@param onlyUnlocked boolean
---@return boolean canApply
function C_ArtifactUI.CanApplyArtifactRelic(relicItemID, onlyUnlocked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.CanApplyCursorRelicToSlot)
---@param relicSlotIndex number
---@return boolean canApply
function C_ArtifactUI.CanApplyCursorRelicToSlot(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.CanApplyRelicItemIDToEquippedArtifactSlot)
---@param relicItemID number
---@param relicSlotIndex number
---@return boolean canApply
function C_ArtifactUI.CanApplyRelicItemIDToEquippedArtifactSlot(relicItemID, relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.CanApplyRelicItemIDToSlot)
---@param relicItemID number
---@param relicSlotIndex number
---@return boolean canApply
function C_ArtifactUI.CanApplyRelicItemIDToSlot(relicItemID, relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.CheckRespecNPC)
---@return boolean canRespec
function C_ArtifactUI.CheckRespecNPC() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.Clear)
function C_ArtifactUI.Clear() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.ClearForgeCamera)
function C_ArtifactUI.ClearForgeCamera() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.ConfirmRespec)
function C_ArtifactUI.ConfirmRespec() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.DoesEquippedArtifactHaveAnyRelicsSlotted)
---@return boolean hasAnyRelicsSlotted
function C_ArtifactUI.DoesEquippedArtifactHaveAnyRelicsSlotted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetAppearanceInfo)
---@param appearanceSetIndex number
---@param appearanceIndex number
---@return number artifactAppearanceID
---@return string appearanceName
---@return number displayIndex
---@return boolean unlocked
---@return string? failureDescription
---@return number uiCameraID
---@return number? altHandCameraID
---@return number swatchColorR
---@return number swatchColorG
---@return number swatchColorB
---@return number modelOpacity
---@return number modelSaturation
---@return boolean obtainable
function C_ArtifactUI.GetAppearanceInfo(appearanceSetIndex, appearanceIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetAppearanceInfoByID)
---@param artifactAppearanceID number
---@return number artifactAppearanceSetID
---@return number artifactAppearanceID
---@return string appearanceName
---@return number displayIndex
---@return boolean unlocked
---@return string? failureDescription
---@return number uiCameraID
---@return number? altHandCameraID
---@return number swatchColorR
---@return number swatchColorG
---@return number swatchColorB
---@return number modelOpacity
---@return number modelSaturation
---@return boolean obtainable
function C_ArtifactUI.GetAppearanceInfoByID(artifactAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetAppearanceSetInfo)
---@param appearanceSetIndex number
---@return number artifactAppearanceSetID
---@return string appearanceSetName
---@return string appearanceSetDescription
---@return number numAppearances
function C_ArtifactUI.GetAppearanceSetInfo(appearanceSetIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetArtifactArtInfo)
---@return ArtifactArtInfo artifactArtInfo
function C_ArtifactUI.GetArtifactArtInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetArtifactInfo)
---@return number itemID
---@return number? altItemID
---@return string name
---@return fileID icon
---@return number xp
---@return number pointsSpent
---@return number quality
---@return number artifactAppearanceID
---@return number appearanceModID
---@return number? itemAppearanceID
---@return number? altItemAppearanceID
---@return boolean altOnTop
---@return ArtifactTiers tier
function C_ArtifactUI.GetArtifactInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetArtifactItemID)
---@return number itemID
function C_ArtifactUI.GetArtifactItemID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetArtifactTier)
---@return ArtifactTiers? tier
function C_ArtifactUI.GetArtifactTier() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetArtifactXPRewardTargetInfo)
---@param artifactCategoryID number
---@return string name
---@return fileID icon
function C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetCostForPointAtRank)
---@param rank number
---@param tier ArtifactTiers
---@return number cost
function C_ArtifactUI.GetCostForPointAtRank(rank, tier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetEquippedArtifactArtInfo)
---@return ArtifactArtInfo artifactArtInfo
function C_ArtifactUI.GetEquippedArtifactArtInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetEquippedArtifactInfo)
---@return number itemID
---@return number? altItemID
---@return string name
---@return fileID icon
---@return number xp
---@return number pointsSpent
---@return number quality
---@return number artifactAppearanceID
---@return number appearanceModID
---@return number? itemAppearanceID
---@return number? altItemAppearanceID
---@return boolean altOnTop
---@return ArtifactTiers tier
function C_ArtifactUI.GetEquippedArtifactInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetEquippedArtifactItemID)
---@return number itemID
function C_ArtifactUI.GetEquippedArtifactItemID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetEquippedArtifactNumRelicSlots)
---@param onlyUnlocked? boolean Default = false
---@return number numRelicSlots
function C_ArtifactUI.GetEquippedArtifactNumRelicSlots(onlyUnlocked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetEquippedArtifactRelicInfo)
---@param relicSlotIndex number
---@return string name
---@return fileID icon
---@return string slotTypeName
---@return string link
function C_ArtifactUI.GetEquippedArtifactRelicInfo(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetEquippedRelicLockedReason)
---@param relicSlotIndex number
---@return string? lockedReason
function C_ArtifactUI.GetEquippedRelicLockedReason(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetForgeRotation)
---@return number forgeRotationX
---@return number forgeRotationY
---@return number forgeRotationZ
function C_ArtifactUI.GetForgeRotation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetItemLevelIncreaseProvidedByRelic)
---@param itemLinkOrID ItemInfo
---@return number itemIevelIncrease
function C_ArtifactUI.GetItemLevelIncreaseProvidedByRelic(itemLinkOrID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetMetaPowerInfo)
---@return number ... spellID
---@return number ... powerCost
---@return number ... currentRank
function C_ArtifactUI.GetMetaPowerInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetNumAppearanceSets)
---@return number numAppearanceSets
function C_ArtifactUI.GetNumAppearanceSets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetNumObtainedArtifacts)
---@return number numObtainedArtifacts
function C_ArtifactUI.GetNumObtainedArtifacts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetNumRelicSlots)
---@param onlyUnlocked? boolean Default = false
---@return number numRelicSlots
function C_ArtifactUI.GetNumRelicSlots(onlyUnlocked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPointsRemaining)
---@return number pointsRemaining
function C_ArtifactUI.GetPointsRemaining() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPowerHyperlink)
---@param powerID number
---@return string link
function C_ArtifactUI.GetPowerHyperlink(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPowerInfo)
---@param powerID number
---@return ArtifactPowerInfo powerInfo
function C_ArtifactUI.GetPowerInfo(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPowerLinks)
---@param powerID number
---@return number[] linkingPowerID
function C_ArtifactUI.GetPowerLinks(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPowers)
---@return number[] powerID
function C_ArtifactUI.GetPowers() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPowersAffectedByRelic)
---@param relicSlotIndex number
---@return number ... powerIDs
function C_ArtifactUI.GetPowersAffectedByRelic(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPowersAffectedByRelicItemLink)
---@param relicItemInfo ItemInfo
---@return number ... powerIDs
function C_ArtifactUI.GetPowersAffectedByRelicItemLink(relicItemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetPreviewAppearance)
---@return number? artifactAppearanceID
function C_ArtifactUI.GetPreviewAppearance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRelicInfo)
---@param relicSlotIndex number
---@return string name
---@return fileID icon
---@return string slotTypeName
---@return string link
function C_ArtifactUI.GetRelicInfo(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRelicInfoByItemID)
---@param itemID number
---@return string name
---@return fileID icon
---@return string slotTypeName
---@return string link
function C_ArtifactUI.GetRelicInfoByItemID(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRelicLockedReason)
---@param relicSlotIndex number
---@return string? lockedReason
function C_ArtifactUI.GetRelicLockedReason(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRelicSlotType)
---@param relicSlotIndex number
---@return string slotTypeName
function C_ArtifactUI.GetRelicSlotType(relicSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRespecArtifactArtInfo)
---@return ArtifactArtInfo artifactArtInfo
function C_ArtifactUI.GetRespecArtifactArtInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRespecArtifactInfo)
---@return number itemID
---@return number? altItemID
---@return string name
---@return fileID icon
---@return number xp
---@return number pointsSpent
---@return number quality
---@return number artifactAppearanceID
---@return number appearanceModID
---@return number? itemAppearanceID
---@return number? altItemAppearanceID
---@return boolean altOnTop
---@return ArtifactTiers tier
function C_ArtifactUI.GetRespecArtifactInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetRespecCost)
---@return number cost
function C_ArtifactUI.GetRespecCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetTotalPowerCost)
---@param startingTrait number
---@param numTraits number
---@param artifactTier ArtifactTiers
---@return number totalArtifactPowerCost
function C_ArtifactUI.GetTotalPowerCost(startingTrait, numTraits, artifactTier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.GetTotalPurchasedRanks)
---@return number totalPurchasedRanks
function C_ArtifactUI.GetTotalPurchasedRanks() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsArtifactDisabled)
---@return boolean artifactDisabled
function C_ArtifactUI.IsArtifactDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsArtifactItem)
---@param itemLocation ItemLocation
---@return boolean isArtifact
function C_ArtifactUI.IsArtifactItem(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsAtForge)
---@return boolean isAtForge
function C_ArtifactUI.IsAtForge() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsEquippedArtifactDisabled)
---@return boolean artifactDisabled
function C_ArtifactUI.IsEquippedArtifactDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsEquippedArtifactMaxed)
---@return boolean artifactMaxed
function C_ArtifactUI.IsEquippedArtifactMaxed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsMaxedByRulesOrEffect)
---@return boolean isEffectivelyMaxed
function C_ArtifactUI.IsMaxedByRulesOrEffect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsPowerKnown)
---@param powerID number
---@return boolean known
function C_ArtifactUI.IsPowerKnown(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.IsViewedArtifactEquipped)
---@return boolean isViewedArtifactEquipped
function C_ArtifactUI.IsViewedArtifactEquipped() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.SetAppearance)
---@param artifactAppearanceID number
function C_ArtifactUI.SetAppearance(artifactAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.SetForgeCamera)
function C_ArtifactUI.SetForgeCamera() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.SetForgeRotation)
---@param forgeRotationX number
---@param forgeRotationY number
---@param forgeRotationZ number
function C_ArtifactUI.SetForgeRotation(forgeRotationX, forgeRotationY, forgeRotationZ) end

---Call without an argument to clear the preview.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.SetPreviewAppearance)
---@param artifactAppearanceID? number Default = 0
function C_ArtifactUI.SetPreviewAppearance(artifactAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArtifactUI.ShouldSuppressForgeRotation)
---@return boolean shouldSuppressForgeRotation
function C_ArtifactUI.ShouldSuppressForgeRotation() end

---@class ArtifactAppearanceInfo
---@field artifactAppearanceID number
---@field appearanceName string
---@field displayIndex number
---@field unlocked boolean
---@field failureDescription string?
---@field uiCameraID number
---@field altHandCameraID number?
---@field swatchColor colorRGB
---@field modelOpacity number
---@field modelSaturation number
---@field obtainable boolean

---@class ArtifactAppearanceSetInfo
---@field artifactAppearanceSetID number
---@field appearanceSetName string
---@field appearanceSetDescription string
---@field numAppearances number

---@class ArtifactArtInfo
---@field textureKit textureKit
---@field titleName string
---@field titleColor colorRGB
---@field barConnectedColor colorRGB
---@field barDisconnectedColor colorRGB
---@field uiModelSceneID number
---@field spellVisualKitID number

---@class ArtifactInfo
---@field itemID number
---@field altItemID number?
---@field name string
---@field icon fileID
---@field xp number
---@field pointsSpent number
---@field quality number
---@field artifactAppearanceID number
---@field appearanceModID number
---@field itemAppearanceID number?
---@field altItemAppearanceID number?
---@field altOnTop boolean
---@field tier ArtifactTiers

---@class ArtifactMetaPowerInfo
---@field spellID number
---@field powerCost number
---@field currentRank number

---@class ArtifactPowerInfo
---@field spellID number
---@field cost number
---@field currentRank number
---@field maxRank number
---@field bonusRanks number
---@field numMaxRankBonusFromTier number
---@field prereqsMet boolean
---@field isStart boolean
---@field isGoldMedal boolean
---@field isFinal boolean
---@field tier number
---@field position vector2
---@field offset vector2?
---@field linearIndex number?

---@class ArtifactRelicInfo
---@field name string
---@field icon fileID
---@field slotTypeName string
---@field link string
