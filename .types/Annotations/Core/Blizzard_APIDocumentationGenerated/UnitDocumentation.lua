---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CanEjectPassengerFromSeat)
---@param virtualSeatIndex number
---@return boolean result
function CanEjectPassengerFromSeat(virtualSeatIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanSwitchVehicleSeat)
---@return boolean result
function CanSwitchVehicleSeat() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClosestGameObjectPosition)
---@param gameObjectID number
---@return number xPos
---@return number yPos
---@return number distance
function ClosestGameObjectPosition(gameObjectID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClosestUnitPosition)
---@param creatureID number
---@return number xPos
---@return number yPos
---@return number distance
function ClosestUnitPosition(creatureID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EjectPassengerFromSeat)
---@param virtualSeatIndex number
function EjectPassengerFromSeat(virtualSeatIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetComboPoints)
---@param unit UnitToken
---@param target UnitToken
---@return number result
function GetComboPoints(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNegativeCorruptionEffectInfo)
---@return CorruptionEffectInfo[] corruptionEffects
function GetNegativeCorruptionEffectInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitChargedPowerPoints)
---@param unit UnitToken
---@return number[] pointIndices
function GetUnitChargedPowerPoints(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitEmpowerHoldAtMaxTime)
---@param unit UnitToken
---@return number holdAtMaxTime
function GetUnitEmpowerHoldAtMaxTime(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitEmpowerMinHoldTime)
---@param unit UnitToken
---@return number minHoldTime
function GetUnitEmpowerMinHoldTime(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitEmpowerStageDuration)
---@param unit UnitToken
---@param index number
---@return number duration
function GetUnitEmpowerStageDuration(unit, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitHealthModifier)
---@param unit UnitToken
---@return number result
function GetUnitHealthModifier(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitMaxHealthModifier)
---@param unit UnitToken
---@return number result
function GetUnitMaxHealthModifier(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarInfo)
---@param unitToken UnitToken
---@return UnitPowerBarInfo info
function GetUnitPowerBarInfo(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarInfoByID)
---@param barID number
---@return UnitPowerBarInfo info
function GetUnitPowerBarInfoByID(barID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarStrings)
---@param unitToken UnitToken
---@return string? name
---@return string? tooltip
---@return string? cost
function GetUnitPowerBarStrings(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarStringsByID)
---@param barID number
---@return string? name
---@return string? tooltip
---@return string? cost
function GetUnitPowerBarStringsByID(barID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarTextureInfo)
---@param unitToken UnitToken
---@param textureIndex number
---@param timerIndex? number
---@return fileID texture
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function GetUnitPowerBarTextureInfo(unitToken, textureIndex, timerIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerBarTextureInfoByID)
---@param barID number
---@param textureIndex number
---@return fileID texture
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function GetUnitPowerBarTextureInfoByID(barID, textureIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitPowerModifier)
---@param unit UnitToken
---@return number result
function GetUnitPowerModifier(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitSpeed)
---@param unit UnitToken
---@return number currentSpeed
---@return number runSpeed
---@return number flightSpeed
---@return number swimSpeed
function GetUnitSpeed(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetUnitTotalModifiedMaxHealthPercent)
---@param unit UnitToken
---@return number result
function GetUnitTotalModifiedMaxHealthPercent(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetVehicleUIIndicator)
---@param vehicleIndicatorID number
---@return fileID backgroundTextureID
---@return number numSeatIndicators
function GetVehicleUIIndicator(vehicleIndicatorID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetVehicleUIIndicatorSeat)
---@param vehicleIndicatorID number
---@param indicatorSeatIndex number
---@return number virtualSeatIndex
---@return number xPos
---@return number yPos
function GetVehicleUIIndicatorSeat(vehicleIndicatorID, indicatorSeatIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsFalling)
---@param unit? UnitToken
---@return boolean result
function IsFalling(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsFlying)
---@param unit? UnitToken
---@return boolean result
function IsFlying(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsPlayerInGuildFromGUID)
---@param playerGUID WOWGUID
---@return boolean IsInGuild
function IsPlayerInGuildFromGUID(playerGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsSubmerged)
---@param unit? UnitToken
---@return boolean result
function IsSubmerged(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsSwimming)
---@param unit? UnitToken
---@return boolean result
function IsSwimming(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsUnitModelReadyForUI)
---@param unitToken UnitToken
---@return boolean isReady
function IsUnitModelReadyForUI(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerIsPVPInactive)
---@param unit UnitToken
---@return boolean result
function PlayerIsPVPInactive(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PlayerVehicleHasComboPoints)
---@return boolean vehicleHasComboPoints
function PlayerVehicleHasComboPoints() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ReportPlayerIsPVPAFK)
---@param unit UnitToken
function ReportPlayerIsPVPAFK(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResistancePercent)
---@param resistance number
---@param casterLevel number
---@return number result
function ResistancePercent(resistance, casterLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetPortraitTexture)
---@param textureObject SimpleTexture
---@param unitToken UnitToken
---@param disableMasking? boolean Default = false
function SetPortraitTexture(textureObject, unitToken, disableMasking) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetPortraitTextureFromCreatureDisplayID)
---@param textureObject SimpleTexture
---@param creatureDisplayID number
function SetPortraitTextureFromCreatureDisplayID(textureObject, creatureDisplayID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetUnitCursorTexture)
---@param textureObject SimpleTexture
---@param unit UnitToken
---@param style? Enum.CursorStyle
---@param includeLowPriority? boolean
---@return boolean hasCursor
function SetUnitCursorTexture(textureObject, unit, style, includeLowPriority) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitAffectingCombat)
---@param unit UnitToken
---@return boolean result
function UnitAffectingCombat(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitAlliedRaceInfo)
---@param unit UnitToken
---@return boolean isAlliedRace
---@return boolean hasHeritageArmorUnlocked
function UnitAlliedRaceInfo(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitArmor)
---@param unit UnitToken
---@return number base
---@return number effective
---@return number real
---@return number bonus
function UnitArmor(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitAttackPower)
---@param unit UnitToken
---@return number attackPower
---@return number posBuff
---@return number negBuff
function UnitAttackPower(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitAttackSpeed)
---@param unit UnitToken
---@return number attackSpeed
---@return number? offhandAttackSpeed
function UnitAttackSpeed(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitBattlePetLevel)
---@param unit UnitToken
---@return number? result
function UnitBattlePetLevel(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitBattlePetSpeciesID)
---@param unit UnitToken
---@return number? result
function UnitBattlePetSpeciesID(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitBattlePetType)
---@param unit UnitToken
---@return number? result
function UnitBattlePetType(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCanAssist)
---@param unit UnitToken
---@param target UnitToken
---@return boolean result
function UnitCanAssist(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCanAttack)
---@param unit UnitToken
---@param target UnitToken
---@return boolean result
function UnitCanAttack(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCanCooperate)
---@param unit UnitToken
---@param target UnitToken
---@return boolean result
function UnitCanCooperate(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCanPetBattle)
---@param unit UnitToken
---@param target UnitToken
---@return boolean result
function UnitCanPetBattle(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCastingInfo)
---@param unit UnitToken
---@return string name
---@return string displayName
---@return fileID textureID
---@return number startTimeMs
---@return number endTimeMs
---@return boolean isTradeskill
---@return WOWGUID castID
---@return boolean notInterruptible
---@return number castingSpellID
function UnitCastingInfo(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitChannelInfo)
---@param unitToken string
---@return string name
---@return string displayName
---@return fileID textureID
---@return number startTimeMs
---@return number endTimeMs
---@return boolean isTradeskill
---@return boolean notInterruptible
---@return number spellID
---@return boolean isEmpowered
---@return number numEmpowerStages
function UnitChannelInfo(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitChromieTimeID)
---@param unit UnitToken
---@return number ID
function UnitChromieTimeID(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitClass)
---@param unit UnitToken
---@return string className
---@return string classFilename
---@return number classID
function UnitClass(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitClassBase)
---@param unit UnitToken
---@return string classFilename
---@return number classID
function UnitClassBase(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitClassification)
---@param unit UnitToken
---@return string result
function UnitClassification(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitControllingVehicle)
---@param unit UnitToken
---@return boolean result
function UnitControllingVehicle(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCreatureFamily)
---@param unit UnitToken
---@return string name
---@return number id
function UnitCreatureFamily(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitCreatureType)
---@param unit UnitToken
---@return string name
---@return number id
function UnitCreatureType(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitDamage)
---@param unit UnitToken
---@return number minDamage
---@return number maxDamage
---@return number offhandMinDamage
---@return number offhandMaxDamage
---@return number posBuff
---@return number negBuff
---@return number percent
function UnitDamage(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitDetailedThreatSituation)
---@param unit UnitToken
---@param mobGUID UnitToken
---@return boolean isTanking
---@return number status
---@return number scaledPercentage
---@return number rawPercentage
---@return number rawThreat
function UnitDetailedThreatSituation(unit, mobGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitDistanceSquared)
---@param unit UnitToken
---@return number distance
---@return boolean checkedDistance
function UnitDistanceSquared(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitEffectiveLevel)
---@param name string
---@return number result
function UnitEffectiveLevel(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitExists)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitExists(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitFactionGroup)
---@param unitName string
---@param checkDisplayRace? boolean Default = false
---@return string factionGroupTag
---@return string localized
function UnitFactionGroup(unitName, checkDisplayRace) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitFullName)
---@param unit string
---@return string unitName
---@return string unitServer
function UnitFullName(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGUID)
---@param unit UnitToken
---@return WOWGUID? result
function UnitGUID(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGetIncomingHeals)
---@param unit UnitToken
---@param healerGUID? UnitToken
---@return number? result
function UnitGetIncomingHeals(unit, healerGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGetTotalAbsorbs)
---@param unit UnitToken
---@return number result
function UnitGetTotalAbsorbs(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGetTotalHealAbsorbs)
---@param unit UnitToken
---@return number result
function UnitGetTotalHealAbsorbs(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGroupRolesAssigned)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return string result
function UnitGroupRolesAssigned(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitGroupRolesAssignedEnum)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return number result
function UnitGroupRolesAssignedEnum(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHPPerStamina)
---@param unit UnitToken
---@return number result
function UnitHPPerStamina(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHasRelicSlot)
---@param unit UnitToken
---@return boolean result
function UnitHasRelicSlot(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHasVehiclePlayerFrameUI)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitHasVehiclePlayerFrameUI(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHasVehicleUI)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitHasVehicleUI(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealthMax)
---@param unit UnitToken
---@return number result
function UnitHealthMax(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHealth)
---@param unit UnitToken
---@param usePredicted? boolean Default = true
---@return number result
function UnitHealth(unit, usePredicted) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHonor)
---@param unit UnitToken
---@return number result
function UnitHonor(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHonorLevel)
---@param unit UnitToken
---@return number result
function UnitHonorLevel(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitHonorMax)
---@param unit UnitToken
---@return number result
function UnitHonorMax(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInAnyGroup)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return boolean result
function UnitInAnyGroup(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInBattleground)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return number? result
function UnitInBattleground(unit, partyIndex) end

---Checks whether this unit cannot see your party chat because it is in an instance group
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInOtherParty)
---@param unit UnitToken
---@return boolean inOtherParty
function UnitInOtherParty(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInParty)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return boolean result
function UnitInParty(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInPartyIsAI)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitInPartyIsAI(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInPartyShard)
---@param unit UnitToken
---@return boolean inPartyShard
function UnitInPartyShard(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInRaid)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return number? result
function UnitInRaid(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInRange)
---@param unit UnitToken
---@return boolean inRange
---@return boolean checkedRange
function UnitInRange(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInSubgroup)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return boolean result
function UnitInSubgroup(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInVehicle)
---@param unit UnitToken
---@return boolean result
function UnitInVehicle(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInVehicleControlSeat)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitInVehicleControlSeat(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitInVehicleHidesPetFrame)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitInVehicleHidesPetFrame(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsAFK)
---@param unit UnitToken
---@return boolean result
function UnitIsAFK(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsBattlePet)
---@param unit UnitToken
---@return boolean? result
function UnitIsBattlePet(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsBattlePetCompanion)
---@param unit UnitToken
---@return boolean result
function UnitIsBattlePetCompanion(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsBossMob)
---@param unit UnitToken
---@return boolean result
function UnitIsBossMob(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsCharmed)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsCharmed(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsConnected)
---@param unit UnitToken
---@return boolean isConnected
function UnitIsConnected(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsControlling)
---@param unit UnitToken
---@return boolean result
function UnitIsControlling(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsCorpse)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsCorpse(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsDND)
---@param unit UnitToken
---@return boolean result
function UnitIsDND(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsDead)
---@param unit UnitToken
---@return boolean result
function UnitIsDead(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsDeadOrGhost)
---@param unit UnitToken
---@return boolean result
function UnitIsDeadOrGhost(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsEnemy)
---@param unit UnitToken
---@param target UnitToken
---@return boolean result
function UnitIsEnemy(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsFeignDeath)
---@param unit UnitToken
---@return boolean result
function UnitIsFeignDeath(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsFriend)
---@param unit UnitToken
---@param target UnitToken
---@return boolean result
function UnitIsFriend(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsGameObject)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsGameObject(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsGhost)
---@param unit UnitToken
---@return boolean result
function UnitIsGhost(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsGroupAssistant)
---@param unit UnitToken
---@return boolean isAssistant
function UnitIsGroupAssistant(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsGroupLeader)
---@param unit UnitToken
---@param partyCategory? number
---@return boolean isLeader
function UnitIsGroupLeader(unit, partyCategory) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsInMyGuild)
---@param unit string
---@return boolean result
function UnitIsInMyGuild(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsInteractable)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsInteractable(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsMercenary)
---@param name string
---@return boolean result
function UnitIsMercenary(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsOtherPlayersBattlePet)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsOtherPlayersBattlePet(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsOtherPlayersPet)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsOtherPlayersPet(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsOwnerOrControllerOfUnit)
---@param controllingUnit UnitToken
---@param controlledUnit UnitToken
---@return boolean unitIsOwnerOrControllerOfUnit
function UnitIsOwnerOrControllerOfUnit(controllingUnit, controlledUnit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsPVP)
---@param unit UnitToken
---@return boolean result
function UnitIsPVP(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsPVPFreeForAll)
---@param unit UnitToken
---@return boolean result
function UnitIsPVPFreeForAll(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsPVPSanctuary)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsPVPSanctuary(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsPlayer)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return boolean result
function UnitIsPlayer(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsPossessed)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsPossessed(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsQuestBoss)
---@param unit UnitToken
---@return boolean result
function UnitIsQuestBoss(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsRaidOfficer)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsRaidOfficer(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsSameServer)
---@param unitName string
---@return boolean result
function UnitIsSameServer(unitName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsTapDenied)
---@param unit UnitToken
---@return boolean result
function UnitIsTapDenied(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsTrivial)
---@param unit UnitToken
---@return boolean result
function UnitIsTrivial(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsUnconscious)
---@param unit UnitToken
---@return boolean result
function UnitIsUnconscious(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsUnit)
---@param unitName1 string
---@param unitName2 string
---@return boolean result
function UnitIsUnit(unitName1, unitName2) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsVisible)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitIsVisible(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitIsWildBattlePet)
---@param unit UnitToken
---@return boolean result
function UnitIsWildBattlePet(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitLeadsAnyGroup)
---@param unit UnitToken
---@return boolean isLeader
function UnitLeadsAnyGroup(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitLevel)
---@param name string
---@return number result
function UnitLevel(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitName)
---@param unit string
---@return string unitName
---@return string unitServer
function UnitName(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitNameUnmodified)
---@param unit string
---@return string unitName
---@return string unitServer
function UnitNameUnmodified(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitNameplateShowsWidgetsOnly)
---@param unit UnitToken
---@return boolean nameplateShowsWidgetsOnly
function UnitNameplateShowsWidgetsOnly(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitNumPowerBarTimers)
---@param unit UnitToken
---@return number result
function UnitNumPowerBarTimers(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitOnTaxi)
---@param unit UnitToken
---@return boolean result
function UnitOnTaxi(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitOwnerGUID)
---@param unit UnitToken
---@return WOWGUID ownerGUID
function UnitOwnerGUID(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPVPName)
---@param unit UnitToken
---@return string result
function UnitPVPName(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPartialPower)
---@param unitToken UnitToken
---@param powerType? Enum.PowerType
---@param unmodified? boolean Default = false
---@return number partialPower
function UnitPartialPower(unitToken, powerType, unmodified) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPercentHealthFromGUID)
---@param unitGUID WOWGUID
---@return number? percentHealth
function UnitPercentHealthFromGUID(unitGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPhaseReason)
---@param unit UnitToken
---@return Enum.PhaseReason? reason
function UnitPhaseReason(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPlayerControlled)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitPlayerControlled(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPlayerOrPetInParty)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return boolean result
function UnitPlayerOrPetInParty(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPlayerOrPetInRaid)
---@param unit? UnitToken Default = WOWGUID_NULL
---@param partyIndex? number
---@return boolean result
function UnitPlayerOrPetInRaid(unit, partyIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPosition)
---@param unit UnitToken
---@return number positionX
---@return number positionY
---@return number positionZ
---@return number mapID
function UnitPosition(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPower)
---@param unitToken UnitToken
---@param powerType? Enum.PowerType
---@param unmodified? boolean Default = false
---@return number power
function UnitPower(unitToken, powerType, unmodified) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPowerBarID)
---@param unitToken UnitToken
---@return number barID
function UnitPowerBarID(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPowerBarTimerInfo)
---@param unit UnitToken
---@param index? number Default = 0
---@return number duration
---@return number expiration
---@return number barID
---@return number auraID
function UnitPowerBarTimerInfo(unit, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPowerDisplayMod)
---@param powerType Enum.PowerType
---@return number displayMod
function UnitPowerDisplayMod(powerType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPowerMax)
---@param unitToken UnitToken
---@param powerType? Enum.PowerType
---@param unmodified? boolean Default = false
---@return number maxPower
function UnitPowerMax(unitToken, powerType, unmodified) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPowerType)
---@param unit UnitToken
---@param index? number Default = 0
---@return Enum.PowerType powerType
---@return string powerTypeToken
---@return number rgbX
---@return number rgbY
---@return number rgbZ
function UnitPowerType(unit, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPvpClassification)
---@param unit UnitToken
---@return Enum.PvPUnitClassification? classification
function UnitPvpClassification(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitQuestTrivialLevelRange)
---@param unit UnitToken
---@return number levelRange
function UnitQuestTrivialLevelRange(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitQuestTrivialLevelRangeScaling)
---@param unit UnitToken
---@return number levelRange
function UnitQuestTrivialLevelRangeScaling(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitRace)
---@param name string
---@return string localizedRaceName
---@return string englishRaceName
---@return number raceID
function UnitRace(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitRangedAttackPower)
---@param unit UnitToken
---@return number attackPower
---@return number posBuff
---@return number negBuff
function UnitRangedAttackPower(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitRangedDamage)
---@param unit UnitToken
---@return number speed
---@return number minDamage
---@return number maxDamage
---@return number posBuff
---@return number negBuff
---@return number percent
function UnitRangedDamage(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitReaction)
---@param unit UnitToken
---@param target UnitToken
---@return number? result
function UnitReaction(unit, target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitRealmRelationship)
---@param unit UnitToken
---@return number? realmRelationship
function UnitRealmRelationship(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSelectionColor)
---@param unit UnitToken
---@param useExtendedColors? boolean Default = false
---@return number resultR
---@return number resultG
---@return number resultB
---@return number resultA
function UnitSelectionColor(unit, useExtendedColors) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSelectionType)
---@param unit UnitToken
---@param useExtendedColors? boolean Default = false
---@return number result
function UnitSelectionType(unit, useExtendedColors) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSex)
---@param unit UnitToken
---@return number? sex
function UnitSex(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitShouldDisplayName)
---@param unit UnitToken
---@return boolean result
function UnitShouldDisplayName(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSpellHaste)
---@param unit UnitToken
---@return number result
function UnitSpellHaste(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitStagger)
---@param unit UnitToken
---@return number result
function UnitStagger(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitStat)
---@param unit UnitToken
---@param index number
---@return number currentStat
---@return number effectiveStat
---@return number statPositiveBuff
---@return number statNegativeBuff
function UnitStat(unit, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitSwitchToVehicleSeat)
---@param unit UnitToken
---@param virtualSeatIndex number
function UnitSwitchToVehicleSeat(unit, virtualSeatIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitTargetsVehicleInRaidUI)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function UnitTargetsVehicleInRaidUI(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitThreatPercentageOfLead)
---@param unit UnitToken
---@param mobGUID UnitToken
---@return number? result
function UnitThreatPercentageOfLead(unit, mobGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitThreatSituation)
---@param unit UnitToken
---@param mobGUID? UnitToken
---@return number? result
function UnitThreatSituation(unit, mobGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitTokenFromGUID)
---@param unitGUID WOWGUID
---@return string? unitToken
function UnitTokenFromGUID(unitGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitTreatAsPlayerForDisplay)
---@param unit UnitToken
---@return boolean treatAsPlayer
function UnitTreatAsPlayerForDisplay(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitTrialBankedLevels)
---@param unit UnitToken
---@return number bankedLevels
---@return number xpIntoCurrentLevel
---@return number xpForNextLevel
function UnitTrialBankedLevels(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitTrialXP)
---@param unit UnitToken
---@return number result
function UnitTrialXP(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitUsingVehicle)
---@param unit UnitToken
---@return boolean result
function UnitUsingVehicle(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitVehicleSeatCount)
---@param unit UnitToken
---@return number result
function UnitVehicleSeatCount(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitVehicleSeatInfo)
---@param unit UnitToken
---@param virtualSeatIndex number
---@return string controlType
---@return string occupantName
---@return string serverName
---@return boolean ejectable
---@return boolean canSwitchSeats
function UnitVehicleSeatInfo(unit, virtualSeatIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitVehicleSkin)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return fileID result
function UnitVehicleSkin(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitWeaponAttackPower)
---@param unit UnitToken
---@return number mainHandWeaponAttackPower
---@return number offHandWeaponAttackPower
---@return number rangedWeaponAttackPower
function UnitWeaponAttackPower(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitWidgetSet)
---@param unit UnitToken
---@return number uiWidgetSet
function UnitWidgetSet(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitXP)
---@param unit UnitToken
---@return number result
function UnitXP(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitXPMax)
---@param unit UnitToken
---@return number result
function UnitXPMax(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_WorldLootObjectExists)
---@param unit? UnitToken Default = WOWGUID_NULL
---@return boolean result
function WorldLootObjectExists(unit) end

---@class CorruptionEffectInfo
---@field name string
---@field description string
---@field minCorruption number

---@class UnitCastingInfoResult
---@field name string
---@field displayName string
---@field textureID fileID
---@field startTimeMs number
---@field endTimeMs number
---@field isTradeskill boolean
---@field castID WOWGUID
---@field notInterruptible boolean
---@field castingSpellID number

---@class UnitChannelInfoResult
---@field name string
---@field displayName string
---@field textureID fileID
---@field startTimeMs number
---@field endTimeMs number
---@field isTradeskill boolean
---@field notInterruptible boolean
---@field spellID number
---@field isEmpowered boolean
---@field numEmpowerStages number

---@class UnitCreatureFamilyResult
---@field name string
---@field id number

---@class UnitCreatureTypeResult
---@field name string
---@field id number

---@class UnitPowerBarInfo
---@field ID number
---@field barType number
---@field minPower number
---@field startInset number
---@field endInset number
---@field smooth boolean
---@field hideFromOthers boolean
---@field showOnRaid boolean
---@field opaqueSpark boolean
---@field opaqueFlash boolean
---@field anchorTop boolean
---@field forcePercentage boolean
---@field sparkUnderFrame boolean
---@field flashAtMinPower boolean
---@field fractionalCounter boolean
---@field animateNumbers boolean
---@field attachTooltipToBar boolean
