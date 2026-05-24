---@meta _
C_QuestInfoSystem = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.GetQuestClassification)
---@param questID? number
---@return Enum.QuestClassification classification
function C_QuestInfoSystem.GetQuestClassification(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.GetQuestRewardCurrencies)
---@param questID? number
---@return QuestRewardCurrencyInfo[] questRewardCurrencyInfo
function C_QuestInfoSystem.GetQuestRewardCurrencies(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.GetQuestRewardSpellInfo)
---@param questID? number
---@param spellID number
---@return QuestRewardSpellInfo? info
function C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.GetQuestRewardSpells)
---@param questID? number
---@return number[] spellIDs
function C_QuestInfoSystem.GetQuestRewardSpells(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.GetQuestShouldToastCompletion)
---@param questID? number
---@return boolean shouldToast
function C_QuestInfoSystem.GetQuestShouldToastCompletion(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.HasQuestRewardCurrencies)
---@param questID? number
---@return boolean hasQuestRewardCurrencies
function C_QuestInfoSystem.HasQuestRewardCurrencies(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestInfoSystem.HasQuestRewardSpells)
---@param questID? number
---@return boolean hasRewardSpells
function C_QuestInfoSystem.HasQuestRewardSpells(questID) end
