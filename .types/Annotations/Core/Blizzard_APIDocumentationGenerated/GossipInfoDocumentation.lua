---@meta _
C_GossipInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.CloseGossip)
function C_GossipInfo.CloseGossip() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.ForceGossip)
---@return boolean forceGossip
function C_GossipInfo.ForceGossip() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetActiveDelveGossip)
---@return GossipOptionUIInfo gossip
function C_GossipInfo.GetActiveDelveGossip() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetActiveQuests)
---@return GossipQuestUIInfo[] info
function C_GossipInfo.GetActiveQuests() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetAvailableQuests)
---@return GossipQuestUIInfo[] info
function C_GossipInfo.GetAvailableQuests() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetCompletedOptionDescriptionString)
---@return string? description
function C_GossipInfo.GetCompletedOptionDescriptionString() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetCustomGossipDescriptionString)
---@return string? description
function C_GossipInfo.GetCustomGossipDescriptionString() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetFriendshipReputation)
---@param friendshipFactionID number
---@return FriendshipReputationInfo reputationInfo
function C_GossipInfo.GetFriendshipReputation(friendshipFactionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetFriendshipReputationRanks)
---@param friendshipFactionID number
---@return FriendshipReputationRankInfo rankInfo
function C_GossipInfo.GetFriendshipReputationRanks(friendshipFactionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetGossipDelveMapID)
---@return number mapID
function C_GossipInfo.GetGossipDelveMapID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetNumActiveQuests)
---@return number numQuests
function C_GossipInfo.GetNumActiveQuests() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetNumAvailableQuests)
---@return number numQuests
function C_GossipInfo.GetNumAvailableQuests() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID)
---@param gossipOptionID number
---@return GossipOptionUIWidgetSetAndType[]? gossipOptionUIWidgetSetsAndTypes
function C_GossipInfo.GetOptionUIWidgetSetsAndTypesByOptionID(gossipOptionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetOptions)
---@return GossipOptionUIInfo[] info
function C_GossipInfo.GetOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetPoiForUiMapID)
---@param uiMapID number
---@return number? gossipPoiID
function C_GossipInfo.GetPoiForUiMapID(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetPoiInfo)
---@param uiMapID number
---@param gossipPoiID number
---@return GossipPoiInfo? gossipPoiInfo
function C_GossipInfo.GetPoiInfo(uiMapID, gossipPoiID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetText)
---@return string gossipText
function C_GossipInfo.GetText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.RefreshOptions)
function C_GossipInfo.RefreshOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectActiveQuest)
---@param optionID number
function C_GossipInfo.SelectActiveQuest(optionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectAvailableQuest)
---@param optionID number
function C_GossipInfo.SelectAvailableQuest(optionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectOption)
---@param optionID number
---@param text? string
---@param confirmed? boolean
function C_GossipInfo.SelectOption(optionID, text, confirmed) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectOptionByIndex)
---@param optionID number
---@param text? string
---@param confirmed? boolean
function C_GossipInfo.SelectOptionByIndex(optionID, text, confirmed) end

---@class FriendshipReputationInfo
---@field friendshipFactionID number
---@field standing number
---@field maxRep number
---@field name string?
---@field text string
---@field texture number
---@field reaction string
---@field reactionThreshold number
---@field nextThreshold number?
---@field reversedColor boolean
---@field overrideColor number?

---@class FriendshipReputationRankInfo
---@field currentLevel number
---@field maxLevel number

---@class GossipOptionRewardInfo
---@field id number
---@field quantity number
---@field rewardType Enum.GossipOptionRewardType
---@field context Enum.ItemCreationContext

---@class GossipOptionUIInfo
---@field gossipOptionID number?
---@field name string
---@field icon fileID
---@field rewards GossipOptionRewardInfo[]
---@field status Enum.GossipOptionStatus
---@field spellID number?
---@field flags number
---@field overrideIconID fileID?
---@field selectOptionWhenOnlyOption boolean
---@field orderIndex number
---@field failureDescription string?

---@class GossipOptionUIWidgetSetAndType
---@field widgetType number
---@field uiWidgetSetID number

---@class GossipPoiInfo
---@field name string
---@field textureIndex number
---@field position vector2
---@field inBattleMap boolean

---@class GossipQuestUIInfo
---@field title string
---@field questLevel number
---@field isTrivial boolean
---@field frequency number?
---@field repeatable boolean?
---@field isComplete boolean?
---@field isLegendary boolean
---@field isIgnored boolean
---@field questID number
---@field isImportant boolean
---@field isMeta boolean
