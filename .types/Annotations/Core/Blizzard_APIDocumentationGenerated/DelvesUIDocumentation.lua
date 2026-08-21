---@meta _
C_DelvesUI = {}

---Returns the entrance tier information for the active Delve (via party data). Assumes only Delves use this type for now.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetActiveDelveTier)
---@return TieredEntranceTierInfo tierInfo
function C_DelvesUI.GetActiveDelveTier() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetCompanionInfoForActivePlayer)
---@return number playerCompanionInfoID
function C_DelvesUI.GetCompanionInfoForActivePlayer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetCreatureDisplayInfoForCompanion)
---@param companionID? number
---@return number creatureDisplayInfoID
function C_DelvesUI.GetCreatureDisplayInfoForCompanion(companionID) end

---Given the spell ID for an owned curio and its rarity, return a spell link style hyperlink for the curio spell, since they aren't items when learned
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetCurioLink)
---@param spellID SpellIdentifier
---@param rarity Enum.CurioRarity
---@return string curioLink
function C_DelvesUI.GetCurioLink(spellID, rarity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetCurioNodeForCompanion)
---@param curioType Enum.CurioType
---@param companionID? number
---@return number nodeID
function C_DelvesUI.GetCurioNodeForCompanion(curioType, companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetCurioRarityByTraitCondAccountElementID)
---@param traitCondAccountElementID number
---@return Enum.CurioRarity rarity
function C_DelvesUI.GetCurioRarityByTraitCondAccountElementID(traitCondAccountElementID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetCurrentDelvesSeasonNumber)
---@return number seasonNumber
function C_DelvesUI.GetCurrentDelvesSeasonNumber() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelveEntranceBackgroundWidgetSetID)
---@return number backgroundWidgetSetID
function C_DelvesUI.GetDelveEntranceBackgroundWidgetSetID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelveEntranceDescriptionString)
---@return string? description
function C_DelvesUI.GetDelveEntranceDescriptionString() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelveEntranceHeaderString)
---@return string? header
function C_DelvesUI.GetDelveEntranceHeaderString() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelveEntranceMapID)
---@return number mapID
function C_DelvesUI.GetDelveEntranceMapID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelveEntranceTiers)
---@return TieredEntranceTierInfo[] levelInfo
function C_DelvesUI.GetDelveEntranceTiers() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelvesAffixSpellsForSeason)
---@return number[] affixSpellIDs
function C_DelvesUI.GetDelvesAffixSpellsForSeason() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelvesFactionForSeason)
---@return number factionID
function C_DelvesUI.GetDelvesFactionForSeason() end

---Players must be at or above the min level + offset to enter Delves. This function returns that min level.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetDelvesMinRequiredLevel)
---@return number? minRequiredLevel
function C_DelvesUI.GetDelvesMinRequiredLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetFactionForCompanion)
---@param companionID? number
---@return number factionID
function C_DelvesUI.GetFactionForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetLockedTextForCompanion)
---@param companionID? number
---@return string text
function C_DelvesUI.GetLockedTextForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetModelSceneForCompanion)
---@param companionID? number
---@return number modelSceneID
function C_DelvesUI.GetModelSceneForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetPlayerCompanionPDEID)
---@param companionID? number
---@return number pdeID
function C_DelvesUI.GetPlayerCompanionPDEID(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetRoleNodeForCompanion)
---@param companionID? number
---@return number nodeID
function C_DelvesUI.GetRoleNodeForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetRoleSubtreeForCompanion)
---@param roleType Enum.CompanionRoleType
---@param companionID? number
---@return number subTreeID
function C_DelvesUI.GetRoleSubtreeForCompanion(roleType, companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetTieredEntranceOptionalAffixTraitTreeID)
---@return number? treeID
function C_DelvesUI.GetTieredEntranceOptionalAffixTraitTreeID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetTieredEntrancePDEID)
---@return number pdeID
function C_DelvesUI.GetTieredEntrancePDEID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetTieredEntranceType)
---@return number entranceType
function C_DelvesUI.GetTieredEntranceType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetTraitTreeForCompanion)
---@param companionID? number
---@return number treeID
function C_DelvesUI.GetTraitTreeForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetUnseenCuriosBySlotType)
---@param slotType Enum.CompanionConfigSlotTypes
---@param ownedCurioNodeIDs number[]
---@return number[] unseenCurioNodeIDs
function C_DelvesUI.GetUnseenCuriosBySlotType(slotType, ownedCurioNodeIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.HasActiveDelve)
---@return boolean result
function C_DelvesUI.HasActiveDelve() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.IsDelveEntranceTierEnabled)
---@param tier number
---@return boolean isEnabled
---@return string? failureReason
function C_DelvesUI.IsDelveEntranceTierEnabled(tier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.IsEligibleForActiveDelveRewards)
---@param unit UnitToken
---@return boolean result
function C_DelvesUI.IsEligibleForActiveDelveRewards(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.IsTraitTreeForCompanion)
---@param traitTreeID number
---@return boolean isForCompanion
function C_DelvesUI.IsTraitTreeForCompanion(traitTreeID) end

---Queries private party members to see what level they have unlocked for the Delve. Ineligible members are added to the tooltip of dropdown entries.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.RequestPartyEligibilityForDelveTiers)
---@param mapID number
function C_DelvesUI.RequestPartyEligibilityForDelveTiers(mapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.SaveSeenCuriosBySlotType)
---@param slotType Enum.CompanionConfigSlotTypes
---@param ownedCurioNodeIDs number[]
function C_DelvesUI.SaveSeenCuriosBySlotType(slotType, ownedCurioNodeIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.SelectDelveEntranceTier)
---@param tier number
function C_DelvesUI.SelectDelveEntranceTier(tier) end

---@class TieredEntranceRewardInfo
---@field id number
---@field quantity number
---@field rewardType Enum.TieredEntranceRewardType
---@field context Enum.ItemCreationContext

---@class TieredEntranceTierInfo
---@field tier number
---@field suggestedILvl number
---@field unlocked boolean
---@field tierDescription string
---@field rewards TieredEntranceRewardInfo[]
---@field modifierUIWidgetSetID number
---@field lockedReason string?
