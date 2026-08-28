---@class QuestieHardcoreTooltip
local QuestieHardcoreTooltip = QuestieLoader:CreateModule("QuestieHardcoreTooltip")
local _QuestieHardcoreTooltip = QuestieHardcoreTooltip.private

local Engine
local hooked = false

local function StripColors(s)
    if not s then return "" end
    s = s:gsub("|c%x%x%x%x%x%x%x%x", "")
    s = s:gsub("|r", "")
    s = s:gsub("|T.-|t", "")
    return s
end

local function GetTooltipText(tooltip)
    local lines = {}
    for i = 1, tooltip:NumLines() do
        local left = _G[tooltip:GetName() .. "TextLeft" .. i]
        if left and left.GetText then
            local text = left:GetText()
            if text then lines[#lines + 1] = StripColors(text) end
        end
    end
    return table.concat(lines, " ")
end

local function AddAnalysis(tooltip, analysis)
    if not analysis then return end
    if tooltip.HCQG_LastQuestId == analysis.questId and tooltip.HCQG_LastScore == analysis.score then return end

    local r, g, b = analysis.colorR, analysis.colorG, analysis.colorB
    tooltip:AddLine(" ")
    tooltip:AddLine("[ HC ] ANALYSE HARDCORE", 1.0, 0.82, 0.10)
    tooltip:AddDoubleLine("Risque", string.format("%d/100  %s", analysis.score, analysis.severityText), 0.95, 0.95, 0.95, r, g, b)
    tooltip:AddDoubleLine("Niveau quête", tostring(analysis.questLevel or "?"), 0.75, 0.75, 0.75, 1, 1, 0.25)
    tooltip:AddDoubleLine("Niveau joueur", tostring(analysis.playerLevel or "?"), 0.75, 0.75, 0.75, 0.8, 0.8, 1.0)
    if analysis.creatureMinLevel and analysis.creatureMaxLevel then
        tooltip:AddDoubleLine("Mobs détectés", tostring(analysis.creatureMinLevel) .. "–" .. tostring(analysis.creatureMaxLevel), 0.75, 0.75, 0.75, 1, 0.65, 0.25)
    end
    if #analysis.factors > 0 then
        tooltip:AddLine("Facteurs", 1.0, 0.82, 0.10)
        for _, factor in ipairs(analysis.factors) do
            tooltip:AddLine("- " .. factor, 0.86, 0.86, 0.86)
        end
    end
    tooltip:AddLine(Engine:GetRecommendation(analysis), r, g, b)
    tooltip.HCQG_LastQuestId = analysis.questId
    tooltip.HCQG_LastScore = analysis.score
end

local function CollectQuestIdsFromMapTooltip(tooltip)
    local ids = {}
    local seen = {}
    if type(tooltip.questOrder) == "table" then
        for questId in pairs(tooltip.questOrder) do
            questId = tonumber(questId)
            if questId and not seen[questId] then
                ids[#ids + 1] = questId
                seen[questId] = true
            end
        end
    end
    if type(tooltip.npcAndObjectOrder) == "table" then
        for _, quests in pairs(tooltip.npcAndObjectOrder) do
            for _, data in pairs(quests) do
                local questId = tonumber(data.questId)
                if questId and not seen[questId] then
                    ids[#ids + 1] = questId
                    seen[questId] = true
                end
            end
        end
    end
    return ids
end

local function CollectQuestIdsFromNpcTooltip(tooltip)
    local ids = {}
    local seen = {}
    local allText = GetTooltipText(tooltip)
    if allText == "" then return ids end

    local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
    if not QuestieTooltips or type(QuestieTooltips.lookupByKey) ~= "table" then return ids end

    for _, entries in pairs(QuestieTooltips.lookupByKey) do
        for _, data in pairs(entries) do
            local questId = tonumber(data.questId)
            if questId and not seen[questId] then
                local quest = QuestieLoader:ImportModule("QuestieDB").GetQuest(questId)
                local title = quest and quest.title
                if title and title ~= "" and string.find(allText, StripColors(title), 1, true) then
                    ids[#ids + 1] = questId
                    seen[questId] = true
                end
            end
        end
    end
    return ids
end

local function Render()
    local tooltip = GameTooltip
    if not tooltip or not tooltip:IsShown() then return end
    if tooltip.HCQG_Rendering then return end
    tooltip.HCQG_Rendering = true

    local ids = CollectQuestIdsFromMapTooltip(tooltip)
    if #ids == 0 then ids = CollectQuestIdsFromNpcTooltip(tooltip) end
    if #ids > 0 then
        local analyses = Engine:AnalyzeQuestList(ids)
        -- Show the most relevant/highest-risk quest first. One analysis per tooltip
        -- keeps the native Questie tooltip readable.
        local best = analyses[1]
        for i = 2, #analyses do
            if analyses[i].score > best.score then best = analyses[i] end
        end
        AddAnalysis(tooltip, best)
        tooltip:Show()
    end
    tooltip.HCQG_Rendering = false
end

function QuestieHardcoreTooltip:Initialize()
    if hooked then return end
    Engine = QuestieLoader:ImportModule("QuestieHardcore")
    if not Engine then return end
    hooked = true

    GameTooltip:HookScript("OnShow", function()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, Render)
        else
            Render()
        end
    end)
    GameTooltip:HookScript("OnHide", function(self)
        self.HCQG_LastQuestId = nil
        self.HCQG_LastScore = nil
        self.HCQG_Rendering = false
    end)
end

QuestieHardcoreTooltip:Initialize()
