---@class QuestieHardcore
local QuestieHardcore = QuestieLoader:CreateModule("QuestieHardcore")
local _QuestieHardcore = QuestieHardcore.private

---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")

---@type QuestieHardcoreQuestAnalyzer
local QuestAnalyzer = QuestieLoader:ImportModule("QuestieHardcoreQuestAnalyzer")

---@type QuestieHardcoreRiskEngine
local RiskEngine = QuestieLoader:ImportModule("QuestieHardcoreRiskEngine")

local function _ScoreColor(score)
    if score >= 80 then
        return "|cFFFF5555"
    elseif score >= 60 then
        return "|cFFFFAA33"
    elseif score >= 40 then
        return "|cFFFFFF55"
    end

    return "|cFF66FF66"
end

local function _ComponentText(value)
    if value == nil then
        return "|cFF777777inconnu|r"
    end

    return tostring(value) .. "/100"
end

---@param questId number
---@return table|nil
function QuestieHardcore:GetQuestRisk(questId)
    local questData = QuestAnalyzer:Analyze(questId)
    if not questData then
        return nil
    end

    local result = RiskEngine:Analyze(questData)
    result.questId = questId
    result.playerLevel = questData.playerLevel
    result.questLevel = questData.questLevel
    result.creatureMin = questData.creatureMin
    result.creatureMax = questData.creatureMax

    return result
end

---@param questId number
---@return table|nil
function QuestieHardcore:GetQuestRiskLines(questId)
    local result = self:GetQuestRisk(questId)
    if not result then
        return nil
    end

    local lines = {}
    local scoreColor = _ScoreColor(result.score)

    lines[#lines + 1] = "|TInterface\\AddOns\\Questie\\Icons\\questie_flat.png:14|t |cFF66CCFFHC|r |cFFFFFFFFANALYSE HARDCORE|r"
    lines[#lines + 1] = scoreColor .. "Risque : " .. result.score .. "/100  •  " .. result.severity .. "|r"
    lines[#lines + 1] = "|cFFAAAAAAConfiance :|r " .. result.confidence

    lines[#lines + 1] =
        "|cFFAAAAAADétails :|r niveau " .. _ComponentText(result.components.level) ..
        "  •  objectifs " .. _ComponentText(result.components.objectives) ..
        "  •  type " .. _ComponentText(result.components.questType)

    if result.questLevel then
        lines[#lines + 1] = "|cFFAAAAAANiveau joueur / quête :|r " .. result.playerLevel .. " / " .. result.questLevel
    else
        lines[#lines + 1] = "|cFFAAAAAANiveau joueur :|r " .. result.playerLevel
    end

    if result.creatureMin and result.creatureMax then
        if result.creatureMin == result.creatureMax then
            lines[#lines + 1] = "|cFFAAAAAAMobs associés :|r niveau " .. result.creatureMax
        else
            lines[#lines + 1] = "|cFFAAAAAAMobs associés :|r " .. result.creatureMin .. "-" .. result.creatureMax
        end
    end

    if #result.factors > 0 then
        local maxFactors = math.min(#result.factors, 3)
        for index = 1, maxFactors do
            lines[#lines + 1] = "|cFF777777- |r" .. result.factors[index]
        end
    end

    return lines
end

function QuestieHardcore:HookQuestieTooltipAPI()
    if not QuestieTooltips or not QuestieTooltips.GetTooltip then
        return
    end

    if _QuestieHardcore.originalGetTooltip then
        return
    end

    _QuestieHardcore.originalGetTooltip = QuestieTooltips.GetTooltip

    QuestieTooltips.GetTooltip = function(key, playerZone)
        local tooltipLines = _QuestieHardcore.originalGetTooltip(key, playerZone)

        if type(key) ~= "string" or not QuestieTooltips.lookupByKey then
            return tooltipLines
        end

        local entries = QuestieTooltips.lookupByKey[key]
        if not entries then
            return tooltipLines
        end

        local questIds = {}
        for _, data in pairs(entries) do
            if data and data.questId then
                questIds[data.questId] = true
            end
        end

        if not next(questIds) then
            return tooltipLines
        end

        tooltipLines = tooltipLines or {}

        local selectedQuestId = nil
        local selectedRisk = nil

        for questId in pairs(questIds) do
            local risk = QuestieHardcore:GetQuestRisk(questId)
            if risk and (not selectedRisk or risk.score > selectedRisk.score) then
                selectedQuestId = questId
                selectedRisk = risk
            end
        end

        if selectedQuestId then
            local lines = QuestieHardcore:GetQuestRiskLines(selectedQuestId)
            if lines then
                tooltipLines[#tooltipLines + 1] = " "
                for _, line in ipairs(lines) do
                    tooltipLines[#tooltipLines + 1] = line
                end
            end
        end

        return tooltipLines
    end
end

function QuestieHardcore:Initialize()
    if _QuestieHardcore.initialized then
        return
    end

    if Questie.IsHardcore == false then
        return
    end

    _QuestieHardcore.initialized = true
    self:HookQuestieTooltipAPI()
end

return QuestieHardcore
