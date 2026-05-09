---@meta _
C_QuestLine = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.GetAvailableQuestLines)
---@param uiMapID number
---@return QuestLineInfo[] questLines
function C_QuestLine.GetAvailableQuestLines(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.GetForceVisibleQuests)
---@param uiMapID number
---@return number[] questIDs
function C_QuestLine.GetForceVisibleQuests(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.GetQuestLineInfo)
---@param questID number
---@param uiMapID? number
---@param displayableOnly? boolean Default = false
---@return QuestLineInfo? questLineInfo
function C_QuestLine.GetQuestLineInfo(questID, uiMapID, displayableOnly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.GetQuestLineQuests)
---@param questLineID number
---@return number[] questIDs
function C_QuestLine.GetQuestLineQuests(questLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.IsComplete)
---@param questLineID number
---@return boolean isComplete
function C_QuestLine.IsComplete(questLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.QuestLineIgnoresAccountCompletedFiltering)
---@param uiMapID number
---@param questLineID number
---@return boolean questLineIgnoresAccountCompletedFiltering
function C_QuestLine.QuestLineIgnoresAccountCompletedFiltering(uiMapID, questLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_QuestLine.RequestQuestLinesForMap)
---@param uiMapID number
function C_QuestLine.RequestQuestLinesForMap(uiMapID) end

---@class QuestLineInfo
---@field questLineName string
---@field questName string
---@field questLineID number
---@field questID number
---@field x number
---@field y number
---@field isHidden boolean
---@field isLegendary boolean
---@field isLocalStory boolean
---@field isDaily boolean
---@field isCampaign boolean
---@field isImportant boolean
---@field isAccountCompleted boolean
---@field isCombatAllyQuest boolean
---@field isMeta boolean
---@field inProgress boolean
---@field isQuestStart boolean
---@field floorLocation Enum.QuestLineFloorLocation
---@field startMapID number
