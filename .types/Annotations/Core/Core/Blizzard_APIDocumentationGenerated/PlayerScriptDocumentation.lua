---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_AcceptAreaSpiritHeal)
function AcceptAreaSpiritHeal() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AcceptGuild)
function AcceptGuild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AcceptResurrect)
function AcceptResurrect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Ambiguate)
---@param fullName string
---@param context string
---@return string result
function Ambiguate(fullName, context) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AutoEquipCursorItem)
function AutoEquipCursorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_BeginTrade)
function BeginTrade() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanDualWield)
---@return boolean result
function CanDualWield() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanInspect)
---@param targetGUID UnitToken
---@return boolean result
function CanInspect(targetGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanLootUnit)
---@param targetUnit WOWGUID
---@return boolean hasLoot
---@return boolean canLoot
function CanLootUnit(targetUnit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CancelAreaSpiritHeal)
function CancelAreaSpiritHeal() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CancelPendingEquip)
---@param index number
function CancelPendingEquip(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CancelTrade)
function CancelTrade() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckInteractDistance)
---@param unitGUID UnitToken
---@param distIndex number
---@return boolean result
function CheckInteractDistance(unitGUID, distIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckTalentMasterDist)
---@return boolean result
function CheckTalentMasterDist() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClearPendingBindConversionItem)
function ClearPendingBindConversionItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConfirmTalentWipe)
function ConfirmTalentWipe() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConvertItemToBindToAccount)
function ConvertItemToBindToAccount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DeclineGuild)
function DeclineGuild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DeclineResurrect)
function DeclineResurrect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Dismount)
function Dismount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EquipPendingItem)
---@param index number
function EquipPendingItem(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FollowUnit)
---@param name? string Default = 0
---@param exactMatch? boolean Default = false
function FollowUnit(name, exactMatch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAllowLowLevelRaid)
---@return boolean result
function GetAllowLowLevelRaid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAllowRecentAlliesSeeLocation)
---@return boolean allowRecentAlliesSeeLocation
function GetAllowRecentAlliesSeeLocation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAreaSpiritHealerTime)
---@return number result
function GetAreaSpiritHealerTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAttackPowerForStat)
---@param stat number
---@param value number
---@return number result
function GetAttackPowerForStat(stat, value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAutoDeclineGuildInvites)
---@return boolean result
function GetAutoDeclineGuildInvites() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAutoDeclineNeighborhoodInvites)
---@return boolean result
function GetAutoDeclineNeighborhoodInvites() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAvoidance)
---@return number result
function GetAvoidance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetBindLocation)
---@return string result
function GetBindLocation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetBlockChance)
---@return number result
function GetBlockChance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCemeteryPreference)
---@return number result
function GetCemeteryPreference() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCollapsingStarCost)
---@return number cost
function GetCollapsingStarCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCombatRating)
---@param ratingIndex number
---@return number? result
function GetCombatRating(ratingIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCombatRatingBonus)
---@param ratingIndex number
---@return number? result
function GetCombatRatingBonus(ratingIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCombatRatingBonusForCombatRatingValue)
---@param ratingIndex number
---@param value number
---@return number? result
function GetCombatRatingBonusForCombatRatingValue(ratingIndex, value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCorpseRecoveryDelay)
---@return number result
function GetCorpseRecoveryDelay() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCorruption)
---@return number result
function GetCorruption() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCorruptionResistance)
---@return number result
function GetCorruptionResistance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCritChance)
---@return number result
function GetCritChance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCritChanceProvidesParryEffect)
---@return boolean result
function GetCritChanceProvidesParryEffect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetDodgeChance)
---@return number result
function GetDodgeChance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetDodgeChanceFromAttribute)
---@return number result
function GetDodgeChanceFromAttribute() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetExpertise)
---@return number mainhandExpertise
---@return number offhandExpertise
---@return number rangedExpertise
function GetExpertise() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetExpertisePercent)
---@return number mainhandExpertisePercent
---@return number offhandExpertisePercent
---@return number rangedExpertisePercent
function GetExpertisePercent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetHaste)
---@return number result
function GetHaste() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetHitModifier)
---@return number result
function GetHitModifier() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetJailersTowerLevel)
---@return number result
function GetJailersTowerLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetLifesteal)
---@return number result
function GetLifesteal() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetLootSpecialization)
---@return number specializationID
function GetLootSpecialization() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetManaRegen)
---@return number baseManaRegen
---@return number castingManaRegen
function GetManaRegen() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMastery)
---@return number result
function GetMastery() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMasteryEffect)
---@return number masteryEffect
---@return number bonusCoefficient
function GetMasteryEffect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMaxCombatRatingBonus)
---@param ratingIndex number
---@return number? result
function GetMaxCombatRatingBonus(ratingIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMaxPlayerLevel)
---@return number maxPlayerLevel
function GetMaxPlayerLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMeleeHaste)
---@return number result
function GetMeleeHaste() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetModResilienceDamageReduction)
---@return number result
function GetModResilienceDamageReduction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMoney)
---@return number result
function GetMoney() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNormalizedRealmName)
---@return string result
function GetNormalizedRealmName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetOverrideAPBySpellPower)
---@return number result
function GetOverrideAPBySpellPower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetOverrideSpellPowerByAP)
---@return number result
function GetOverrideSpellPowerByAP() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPVPDesired)
---@return boolean result
function GetPVPDesired() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPVPGearStatRules)
---@return boolean result
function GetPVPGearStatRules() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPVPLifetimeStats)
---@return number lifetimeHonorableKills
---@return Enum.PvPRanks lifetimeMaxPVPRank
function GetPVPLifetimeStats() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPVPSessionStats)
---@return number honorableKills
---@return number dishonorableKills
function GetPVPSessionStats() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPVPTimer)
---@return number result
function GetPVPTimer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPVPYesterdayStats)
---@return number honorableKills
---@return number dishonorableKills
function GetPVPYesterdayStats() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetParryChance)
---@return number result
function GetParryChance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetParryChanceFromAttribute)
---@return number result
function GetParryChanceFromAttribute() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPetMeleeHaste)
---@return number result
function GetPetMeleeHaste() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPetSpellBonusDamage)
---@return number result
function GetPetSpellBonusDamage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPlayerFacing)
---@return number? result
function GetPlayerFacing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPlayerInfoByGUID)
---@param guid WOWGUID
---@return string localizedClass
---@return string englishClass
---@return string localizedRace
---@return string englishRace
---@return number sex
---@return string name
---@return string realmName
function GetPlayerInfoByGUID(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPowerRegen)
---@return number basePowerRegen
---@return number castingPowerRegen
function GetPowerRegen() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPowerRegenForPowerType)
---@param powerType number
---@return number basePowerRegen
---@return number castingPowerRegen
function GetPowerRegenForPowerType(powerType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPvpPowerDamage)
---@return number result
function GetPvpPowerDamage() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetPvpPowerHealing)
---@return number result
function GetPvpPowerHealing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRangedCritChance)
---@return number result
function GetRangedCritChance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRangedHaste)
---@return number result
function GetRangedHaste() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetReleaseTimeRemaining)
---@return number result
function GetReleaseTimeRemaining() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetResSicknessDuration)
---@return string? result
function GetResSicknessDuration() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRestState)
---@return number exhaustionID
---@return string name
---@return number factor
function GetRestState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRestrictedAccountData)
---@return number maxLevel
---@return WOWMONEY maxMoney
---@return number professionCap
function GetRestrictedAccountData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRuneCooldown)
---@param runeIndex number
---@return number startTime
---@return number duration
---@return boolean isRuneReady
function GetRuneCooldown(runeIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRuneCount)
---@param runeIndex number
---@return number result
function GetRuneCount(runeIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSheathState)
---@return number? result
function GetSheathState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetShieldBlock)
---@return number result
function GetShieldBlock() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpeed)
---@return number result
function GetSpeed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpellBonusDamage)
---@param school number
---@return number? result
function GetSpellBonusDamage(school) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpellBonusHealing)
---@return number result
function GetSpellBonusHealing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpellCritChance)
---@return number result
function GetSpellCritChance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpellHitModifier)
---@return number result
function GetSpellHitModifier() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpellPenetration)
---@return number result
function GetSpellPenetration() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSturdiness)
---@return number result
function GetSturdiness() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetTaxiBenchmarkMode)
---@return boolean result
function GetTaxiBenchmarkMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetVersatilityBonus)
---@param combatRating number
---@return number result
function GetVersatilityBonus(combatRating) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetXPExhaustion)
---@return number? result
function GetXPExhaustion() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasAPEffectsSpellPower)
---@return boolean result
function HasAPEffectsSpellPower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasDualWieldPenalty)
---@return boolean result
function HasDualWieldPenalty() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasFullControl)
---@return boolean result
function HasFullControl() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasIgnoreDualWieldWeapon)
---@return boolean result
function HasIgnoreDualWieldWeapon() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasKey)
---@return boolean hasKey
function HasKey() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasNoReleaseAura)
---@return boolean hasCannotReleaseEffect
---@return number longestDuration
---@return boolean hasUntilCancelledDuration
function HasNoReleaseAura() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasSPEffectsAttackPower)
---@return boolean result
function HasSPEffectsAttackPower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_InitiateTrade)
---@param guid UnitToken
function InitiateTrade(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsAccountSecured)
---@return boolean result
function IsAccountSecured() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsAdvancedFlyableArea)
---@return boolean result
function IsAdvancedFlyableArea() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsCemeterySelectionAvailable)
---@return boolean result
function IsCemeterySelectionAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsCharacterNewlyBoosted)
---@return boolean newlyBoosted
function IsCharacterNewlyBoosted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsDrivableArea)
---@return boolean result
function IsDrivableArea() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsDualWielding)
---@return boolean result
function IsDualWielding() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsFlyableArea)
---@return boolean result
function IsFlyableArea() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsGuildLeader)
---@return boolean result
function IsGuildLeader() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsInGuild)
---@return boolean result
function IsInGuild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsInJailersTower)
---@return boolean result
function IsInJailersTower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsIndoors)
---@return boolean result
function IsIndoors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsInsane)
---@return boolean result
function IsInsane() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsItemPreferredArmorType)
---@param itemLocation ItemLocation
---@return boolean isItemPreferredArmorType
function IsItemPreferredArmorType(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsJailersTowerLayerTimeLocked)
---@param layerLevel number
---@return string result
function IsJailersTowerLayerTimeLocked(layerLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLoggedIn)
---@return boolean result
function IsLoggedIn() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsMounted)
---@return boolean result
function IsMounted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsOnGroundFloorInJailersTower)
---@return boolean result
function IsOnGroundFloorInJailersTower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsOutOfBounds)
---@return boolean result
function IsOutOfBounds() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsOutdoors)
---@return boolean result
function IsOutdoors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsPVPTimerRunning)
---@return boolean result
function IsPVPTimerRunning() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsPlayerInWorld)
---@return boolean result
function IsPlayerInWorld() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsPlayerMoving)
---@return boolean result
function IsPlayerMoving() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRangedWeapon)
---@return boolean result
function IsRangedWeapon() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsResting)
---@return boolean result
function IsResting() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRestrictedAccount)
---@return boolean result
function IsRestrictedAccount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsStealthed)
---@return boolean result
function IsStealthed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsXPUserDisabled)
---@return boolean result
function IsXPUserDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_NoPlayTime)
---@return boolean? result
function NoPlayTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_NotifyInspect)
---@param targetGUID UnitToken
function NotifyInspect(targetGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PartialPlayTime)
---@return boolean? result
function PartialPlayTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerCanTeleport)
---@return boolean result
function PlayerCanTeleport() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerEffectiveAttackPower)
---@return number mainHandAttackPower
---@return number offHandAttackPower
---@return number rangedAttackPower
---@return number baseAttackPower
---@return number baseRangedAttackPower
function PlayerEffectiveAttackPower() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerGetTimerunningSeasonID)
---@return number? timerunningSeasonID
function PlayerGetTimerunningSeasonID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerIsInCombat)
---@return boolean playerIsInCombat
function PlayerIsInCombat() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerIsTimerunning)
---@return boolean playerIsTimerunning
function PlayerIsTimerunning() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PortGraveyard)
function PortGraveyard() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RandomRoll)
---@param min number
---@param max number
function RandomRoll(min, max) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RepopMe)
function RepopMe() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RequestTimePlayed)
function RequestTimePlayed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RespondInstanceLock)
---@param acceptLock boolean
function RespondInstanceLock(acceptLock) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResurrectGetOfferer)
---@return string name
function ResurrectGetOfferer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResurrectHasSickness)
---@return boolean result
function ResurrectHasSickness() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResurrectHasTimer)
---@return boolean result
function ResurrectHasTimer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RetrieveCorpse)
function RetrieveCorpse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetAllowLowLevelRaid)
---@param allow? boolean Default = false
function SetAllowLowLevelRaid(allow) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetAllowRecentAlliesSeeLocation)
---@param allowRecentAlliesSeeLocation boolean
function SetAllowRecentAlliesSeeLocation(allowRecentAlliesSeeLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetAutoDeclineGuildInvites)
---@param allow? boolean Default = false
function SetAutoDeclineGuildInvites(allow) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetAutoDeclineNeighborhoodInvites)
---@param allow? boolean Default = false
function SetAutoDeclineNeighborhoodInvites(allow) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetCemeteryPreference)
---@param cemetaryID number
function SetCemeteryPreference(cemetaryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetLootSpecialization)
---@param specializationID number
function SetLootSpecialization(specializationID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetTaxiBenchmarkMode)
---@param enable? boolean Default = false
function SetTaxiBenchmarkMode(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ShouldShowIslandsWeeklyPOI)
---@return boolean result
function ShouldShowIslandsWeeklyPOI() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ShouldShowSpecialSplashScreen)
---@return boolean result
function ShouldShowSpecialSplashScreen() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ShowCloak)
---@param show boolean
function ShowCloak(show) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ShowHelm)
---@param show boolean
function ShowHelm(show) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ShowingCloak)
---@return boolean result
function ShowingCloak() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ShowingHelm)
---@return boolean result
function ShowingHelm() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SitStandOrDescendStart)
function SitStandOrDescendStart() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SplashFrameCanBeShown)
---@return boolean result
function SplashFrameCanBeShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StartAttack)
---@param name? string Default = 0
---@param exactMatch? boolean Default = false
function StartAttack(name, exactMatch) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_StopAttack)
function StopAttack() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Stuck)
function Stuck() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TimeoutResurrect)
function TimeoutResurrect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ToggleSelfHighlight)
---@return boolean enabled
function ToggleSelfHighlight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ToggleSheath)
function ToggleSheath() end

---@class PlayerAttackPowerInfo
---@field mainHandAttackPower number
---@field offHandAttackPower number
---@field rangedAttackPower number
---@field baseAttackPower number
---@field baseRangedAttackPower number
