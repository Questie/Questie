---@meta _
C_Reputation = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.AreLegacyReputationsShown)
---@return boolean areLegacyReputationsShown
function C_Reputation.AreLegacyReputationsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.CollapseAllFactionHeaders)
function C_Reputation.CollapseAllFactionHeaders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.CollapseFactionHeader)
---@param factionSortIndex number
function C_Reputation.CollapseFactionHeader(factionSortIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.ExpandAllFactionHeaders)
function C_Reputation.ExpandAllFactionHeaders() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.ExpandFactionHeader)
---@param factionSortIndex number
function C_Reputation.ExpandFactionHeader(factionSortIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetFactionDataByID)
---@param factionID number
---@return FactionData? factionData
function C_Reputation.GetFactionDataByID(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetFactionDataByIndex)
---@param factionSortIndex number
---@return FactionData? factionData
function C_Reputation.GetFactionDataByIndex(factionSortIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetFactionParagonInfo)
---@param factionID number
---@return number currentValue
---@return number threshold
---@return number rewardQuestID
---@return boolean hasRewardPending
---@return boolean tooLowLevelForParagon
function C_Reputation.GetFactionParagonInfo(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetGuildFactionData)
---@return FactionData? guildFactionData
function C_Reputation.GetGuildFactionData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetGuildRepExpirationTime)
---@return number? expirationTime
function C_Reputation.GetGuildRepExpirationTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetNumFactions)
---@return number numFactions
function C_Reputation.GetNumFactions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetReputationSortType)
---@return Enum.ReputationSortType sortType
function C_Reputation.GetReputationSortType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetSelectedFaction)
---@return number selectedFactionSortIndex
function C_Reputation.GetSelectedFaction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetWatchedFactionData)
---@return FactionData? watchedFactionData
function C_Reputation.GetWatchedFactionData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.IsAccountWideReputation)
---@param factionID number
---@return boolean isAccountWide
function C_Reputation.IsAccountWideReputation(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.IsFactionActive)
---@param factionSortIndex number
---@return boolean isActive
function C_Reputation.IsFactionActive(factionSortIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.IsFactionParagon)
---@param factionID number
---@return boolean hasParagon
function C_Reputation.IsFactionParagon(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.IsMajorFaction)
---@param factionID number
---@return boolean isMajorFaction
function C_Reputation.IsMajorFaction(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.RequestFactionParagonPreloadRewardData)
---@param factionID number
function C_Reputation.RequestFactionParagonPreloadRewardData(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.SetFactionActive)
---@param factionSortIndex number
---@param setActive boolean
function C_Reputation.SetFactionActive(factionSortIndex, setActive) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.SetLegacyReputationsShown)
---@param showLegacyReputations boolean
function C_Reputation.SetLegacyReputationsShown(showLegacyReputations) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.SetReputationSortType)
---@param sortType Enum.ReputationSortType
function C_Reputation.SetReputationSortType(sortType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.SetSelectedFaction)
---@param factionSortIndex number
function C_Reputation.SetSelectedFaction(factionSortIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.SetWatchedFactionByID)
---@param factionID number
function C_Reputation.SetWatchedFactionByID(factionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.SetWatchedFactionByIndex)
---@param factionSortIndex number
function C_Reputation.SetWatchedFactionByIndex(factionSortIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Reputation.ToggleFactionAtWar)
---@param factionSortIndex number
function C_Reputation.ToggleFactionAtWar(factionSortIndex) end

---@class FactionData
---@field factionID number
---@field name string
---@field description string
---@field reaction number
---@field currentReactionThreshold number
---@field nextReactionThreshold number
---@field currentStanding number
---@field atWarWith boolean
---@field canToggleAtWar boolean
---@field isChild boolean
---@field isHeader boolean
---@field isHeaderWithRep boolean
---@field isCollapsed boolean
---@field isWatched boolean
---@field hasBonusRepGain boolean
---@field canSetInactive boolean
---@field isAccountWide boolean
