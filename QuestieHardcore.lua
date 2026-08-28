---@class QuestieHardcore
local QuestieHardcore = QuestieLoader:CreateModule("QuestieHardcore")
local _QuestieHardcore = QuestieHardcore.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")

local function _Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function _GetQuestRisk(questId)
    local quest = QuestieDB.GetQuest(questId)
    if not quest then return nil end

    local playerLevel = UnitLevel("player") or 1
    local questLevel = quest.level or quest.questLevel or 0
    if questLevel == 0 then return nil end

    -- V0.1 uses only high-confidence data already present in Questie.
    local score = 10
    local reasons = {}
    local levelDelta = questLevel - playerLevel

    if levelDelta >= 4 then
        score = score + 30
        reasons[#reasons + 1] = string.format("quête +%d niveaux", levelDelta)
    elseif levelDelta == 3 then
        score = score + 20
        reasons[#reasons + 1] = "quête +3 niveaux"
    elseif levelDelta == 2 then
        score = score + 10
        reasons[#reasons + 1] = "quête +2 niveaux"
    elseif levelDelta <= -5 then
        score = score - 5
    end

    local function addTagRisk(isRisky, amount, text)
        if isRisky then
            score = score + amount
            reasons[#reasons + 1] = text
        end
    end

    addTagRisk(QuestieDB.IsGroupQuest(questId), 30, "quête élite/groupe")
    addTagRisk(QuestieDB.IsDungeonQuest(questId), 25, "quête de donjon")
    addTagRisk(QuestieDB.IsRaidQuest(questId), 35, "quête de raid")
    local tagId = QuestieDB.GetQuestTagInfo(questId)
    addTagRisk(tagId == QuestieDB.questTagIds.ESCORT, 25, "quête d'escorte")
    addTagRisk(QuestieDB.IsPvPQuest(questId), 15, "quête JcJ")

    local creatureLevels = QuestieDB:GetCreatureLevels(quest)
    local highestCreatureLevel = 0
    local hasEliteCreature = false

    for _, data in pairs(creatureLevels or {}) do
        local minLevel, maxLevel, rank = data[1], data[2], data[3]
        highestCreatureLevel = math.max(highestCreatureLevel, maxLevel or minLevel or 0)
        if rank and rank > 0 then hasEliteCreature = true end
    end

    if highestCreatureLevel > 0 then
        local creatureDelta = highestCreatureLevel - playerLevel
        if creatureDelta >= 4 then
            score = score + 25
            reasons[#reasons + 1] = string.format("objectif jusqu'au niveau %d", highestCreatureLevel)
        elseif creatureDelta == 3 then
            score = score + 15
            reasons[#reasons + 1] = string.format("objectif jusqu'au niveau %d", highestCreatureLevel)
        elseif creatureDelta == 2 then
            score = score + 8
            reasons[#reasons + 1] = string.format("objectif jusqu'au niveau %d", highestCreatureLevel)
        end
    end

    if hasEliteCreature and not QuestieDB.IsGroupQuest(questId) then
        score = score + 20
        reasons[#reasons + 1] = "élite détecté dans les objectifs"
    end

    score = _Clamp(score, 0, 100)

    local color, label
    if score >= 85 then color, label = "ff3333", "CRITIQUE"
    elseif score >= 70 then color, label = "ff7a33", "TRÈS ÉLEVÉ"
    elseif score >= 50 then color, label = "ffcc33", "ÉLEVÉ"
    elseif score >= 30 then color, label = "ffff66", "MODÉRÉ"
    else color, label = "66ff66", "FAIBLE" end

    return {
        score = score, color = color, label = label, reasons = reasons,
        playerLevel = playerLevel, questLevel = questLevel,
        highestCreatureLevel = highestCreatureLevel,
    }
end

function QuestieHardcore:GetQuestRisk(questId)
    if not Questie.IsHardcore then return nil end
    return _GetQuestRisk(questId)
end

local function _AppendAnalysis(tooltipLines, questIds)
    if not tooltipLines or not questIds then return tooltipLines end

    local added, seen = 0, {}
    for _, questId in pairs(questIds) do
        if not seen[questId] and added < 3 then
            seen[questId] = true
            local analysis = _GetQuestRisk(questId)
            if analysis then
                tooltipLines[#tooltipLines + 1] = "|cFF808080──────── Hardcore ────────|r"
                tooltipLines[#tooltipLines + 1] = string.format(
                    "|cFF%s|r Risque Hardcore : |cFF%s%d/100|r",
                    analysis.color, analysis.color, analysis.score
                )
                tooltipLines[#tooltipLines + 1] = string.format(
                    "Niveau : %d  •  Joueur : %d  •  %s",
                    analysis.questLevel, analysis.playerLevel, analysis.label
                )
                if analysis.highestCreatureLevel > 0 then
                    tooltipLines[#tooltipLines + 1] = string.format(
                        "Objectifs : jusqu'au niveau %d", analysis.highestCreatureLevel
                    )
                end
                if #analysis.reasons > 0 then
                    tooltipLines[#tooltipLines + 1] = "|cFFBBBBBB" .. table.concat(analysis.reasons, " • ") .. "|r"
                else
                    tooltipLines[#tooltipLines + 1] = "|cFFBBBBBBDonnées de risque limitées dans V0.1|r"
                end
                added = added + 1
            end
        end
    end
    return tooltipLines
end

local function _WrapQuestieTooltip()
    if _QuestieHardcore.tooltipWrapped then return end

    local originalGetTooltip = QuestieTooltips.GetTooltip
    if type(originalGetTooltip) ~= "function" then return end

    QuestieTooltips.GetTooltip = function(key, playerZone)
        local tooltipLines = originalGetTooltip(key, playerZone)
        if not Questie.IsHardcore or not tooltipLines or not QuestieTooltips.lookupByKey[key] then
            return tooltipLines
        end

        local questIds = {}
        for _, tooltipData in pairs(QuestieTooltips.lookupByKey[key]) do
            if tooltipData and tooltipData.questId then
                questIds[#questIds + 1] = tooltipData.questId
            end
        end
        return _AppendAnalysis(tooltipLines, questIds)
    end

    _QuestieHardcore.tooltipWrapped = true
end

function QuestieHardcore:Initialize()
    if not Questie.IsHardcore then return end
    C_Timer.After(0, _WrapQuestieTooltip)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Questie" then
        QuestieHardcore:Initialize()
    end
end)

return QuestieHardcore
