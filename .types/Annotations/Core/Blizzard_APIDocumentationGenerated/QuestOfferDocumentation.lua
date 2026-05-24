---@meta _
C_QuestOffer = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestOffer.GetHideRequiredItems)
---@return boolean hideRequiredItems
function C_QuestOffer.GetHideRequiredItems() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestOffer.GetQuestOfferMajorFactionReputationRewards)
---@return QuestRewardReputationInfo[] reputationRewards
function C_QuestOffer.GetQuestOfferMajorFactionReputationRewards() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestOffer.GetQuestRequiredCurrencyInfo)
---@param questRewardIndex number
---@return QuestRequiredCurrencyInfo? questRequiredCurrencyInfo
function C_QuestOffer.GetQuestRequiredCurrencyInfo(questRewardIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestOffer.GetQuestRewardCurrencyInfo)
---@param questInfoType string
---@param questRewardIndex number
---@return QuestRewardCurrencyInfo? questRewardCurrencyInfo
function C_QuestOffer.GetQuestRewardCurrencyInfo(questInfoType, questRewardIndex) end

---@class QuestRequiredCurrencyInfo
---@field texture fileID
---@field name string
---@field currencyID number
---@field quality number
---@field requiredAmount number
