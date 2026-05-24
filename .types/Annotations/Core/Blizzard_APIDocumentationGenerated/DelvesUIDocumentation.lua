---@meta _
C_DelvesUI = {}

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
---@param spellID number
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

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetModelSceneForCompanion)
---@param companionID? number
---@return number modelSceneID
function C_DelvesUI.GetModelSceneForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetRoleNodeForCompanion)
---@param companionID? number
---@return number nodeID
function C_DelvesUI.GetRoleNodeForCompanion(companionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.GetRoleSubtreeForCompanion)
---@param roleType Enum.CompanionRoleType
---@param companionID? number
---@return number subTreeID
function C_DelvesUI.GetRoleSubtreeForCompanion(roleType, companionID) end

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
---@param mapID? number
---@return boolean result
function C_DelvesUI.HasActiveDelve(mapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.IsEligibleForActiveDelveRewards)
---@param unit UnitToken
---@return boolean result
function C_DelvesUI.IsEligibleForActiveDelveRewards(unit) end

---Queries private party members to see what level they have unlocked for the Delve. Ineligible members are added to the tooltip of dropdown entries.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.RequestPartyEligibilityForDelveTiers)
---@param gossipOption number
function C_DelvesUI.RequestPartyEligibilityForDelveTiers(gossipOption) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DelvesUI.SaveSeenCuriosBySlotType)
---@param slotType Enum.CompanionConfigSlotTypes
---@param ownedCurioNodeIDs number[]
function C_DelvesUI.SaveSeenCuriosBySlotType(slotType, ownedCurioNodeIDs) end
