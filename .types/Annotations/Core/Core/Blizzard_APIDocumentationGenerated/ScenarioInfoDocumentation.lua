---@meta _
C_ScenarioInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ScenarioInfo.GetCriteriaInfo)
---@param criteriaIndex number
---@return ScenarioCriteriaInfo scenarioCriteriaInfo
function C_ScenarioInfo.GetCriteriaInfo(criteriaIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ScenarioInfo.GetCriteriaInfoByStep)
---@param stepID number
---@param criteriaIndex number
---@return ScenarioCriteriaInfo scenarioCriteriaInfo
function C_ScenarioInfo.GetCriteriaInfoByStep(stepID, criteriaIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ScenarioInfo.GetJailersTowerTypeString)
---@param runType Enum.JailersTowerType
---@return string? typeString
function C_ScenarioInfo.GetJailersTowerTypeString(runType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ScenarioInfo.GetScenarioInfo)
---@return ScenarioInformation scenarioInfo
function C_ScenarioInfo.GetScenarioInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ScenarioInfo.GetScenarioStepInfo)
---@param scenarioStepID? number
---@return ScenarioStepInfo scenarioStepInfo
function C_ScenarioInfo.GetScenarioStepInfo(scenarioStepID) end

---@class ScenarioCriteriaInfo
---@field description string
---@field criteriaType number? Default = 0
---@field completed boolean? Default = false
---@field quantity number? Default = 0
---@field totalQuantity number? Default = 0
---@field flags number? Default = 0
---@field assetID number? Default = 0
---@field criteriaID number
---@field duration number? Default = 0
---@field elapsed number? Default = 0
---@field failed boolean? Default = false
---@field isWeightedProgress boolean? Default = false
---@field isFormatted boolean? Default = false
---@field quantityString string

---@class ScenarioInformation
---@field name string
---@field currentStage number
---@field numStages number
---@field flags number
---@field isComplete boolean
---@field xp number
---@field money number
---@field type number
---@field area string
---@field uiTextureKit textureKit
---@field scenarioID number

---@class ScenarioStepInfo
---@field title string
---@field description string
---@field numCriteria number
---@field stepFailed boolean
---@field isBonusStep boolean
---@field isForCurrentStepOnly boolean
---@field shouldShowBonusObjective boolean
---@field spells ScenarioStepSpellInfo[]
---@field weightedProgress number?
---@field rewardQuestID number
---@field widgetSetID number?
---@field stepID number

---@class ScenarioStepSpellInfo
---@field spellID number
---@field name string
---@field icon number
