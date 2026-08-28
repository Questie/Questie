---@class QuestieHardcore
local QuestieHardcore = QuestieLoader:CreateModule("QuestieHardcore")
local _QuestieHardcore = QuestieHardcore.private

--- Hardcore analysis engine. Intentionally conservative and bounded to 0..100.

local function Clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function AddFactor(result, text, points)
    result.score = result.score + points
    result.factors[#result.factors + 1] = text
end

local function Severity(score)
    if score < 20 then return "VERY_LOW", "Très faible", 0.20, 1.00, 0.20 end
    if score < 40 then return "LOW", "Faible", 0.45, 1.00, 0.35 end
    if score < 60 then return "MODERATE", "Modéré", 1.00, 0.82, 0.15 end
    if score < 75 then return "HIGH", "Élevé", 1.00, 0.55, 0.10 end
    if score < 90 then return "VERY_HIGH", "Très élevé", 1.00, 0.20, 0.10 end
    return "CRITICAL", "Critique", 1.00, 0.12, 0.12
end

function QuestieHardcore:GetPlayerLevel()
    return UnitLevel("player") or 1
end

function QuestieHardcore:AnalyzeQuest(questId)
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
    local quest = QuestieDB.GetQuest(questId)
    if not quest then return nil end

    local playerLevel = self:GetPlayerLevel()
    local questLevel = quest.level or 0
    local result = {
        questId = questId,
        questLevel = questLevel,
        playerLevel = playerLevel,
        score = 0,
        factors = {},
        positives = {},
    }

    -- The quest level is the first signal, but it is deliberately capped.
    local delta = questLevel - playerLevel
    if delta <= -4 then
        result.score = result.score + 0
        result.positives[#result.positives + 1] = "Quête nettement sous le niveau du joueur"
    elseif delta <= -2 then
        result.score = result.score + 4
    elseif delta <= 0 then
        result.score = result.score + 10
    elseif delta == 1 then
        AddFactor(result, "Quête +1 niveau", 18)
    elseif delta == 2 then
        AddFactor(result, "Quête +2 niveaux", 30)
    elseif delta == 3 then
        AddFactor(result, "Quête +3 niveaux", 44)
    elseif delta == 4 then
        AddFactor(result, "Quête +4 niveaux", 58)
    else
        AddFactor(result, "Quête +5 niveaux ou plus", 72)
    end

    -- Creature level information is available in QuestieDB and is more useful
    -- than guessing from the quest level alone.
    local ok, creatureLevels = pcall(function()
        return QuestieDB:GetCreatureLevels(quest)
    end)
    if ok and creatureLevels then
        local minLevel = creatureLevels.min or creatureLevels[1]
        local maxLevel = creatureLevels.max or creatureLevels[2]
        if type(minLevel) == "number" and type(maxLevel) == "number" then
            result.creatureMinLevel = minLevel
            result.creatureMaxLevel = maxLevel
            local mobDelta = maxLevel - playerLevel
            if mobDelta >= 5 then
                AddFactor(result, "Mobs jusqu'à +5 niveaux ou plus", 28)
            elseif mobDelta == 4 then
                AddFactor(result, "Mobs jusqu'à +4 niveaux", 22)
            elseif mobDelta == 3 then
                AddFactor(result, "Mobs jusqu'à +3 niveaux", 15)
            elseif mobDelta == 2 then
                AddFactor(result, "Mobs jusqu'à +2 niveaux", 8)
            elseif mobDelta <= -2 then
                result.positives[#result.positives + 1] = "Mobs globalement sous le niveau du joueur"
            end
        end
    end

    -- Dungeon / raid / PvP are not intrinsically deaths, but they are useful
    -- warnings for a solo Hardcore character.
    local isDungeon = pcall(function() return QuestieDB.IsDungeonQuest(questId) end) and QuestieDB.IsDungeonQuest(questId)
    local isRaid = pcall(function() return QuestieDB.IsRaidQuest(questId) end) and QuestieDB.IsRaidQuest(questId)
    if isRaid then
        AddFactor(result, "Quête de raid", 35)
    elseif isDungeon then
        AddFactor(result, "Quête de donjon", 18)
    end

    local isPvP = pcall(function() return QuestieDB.IsPvPQuest(questId) end) and QuestieDB.IsPvPQuest(questId)
    if isPvP then
        AddFactor(result, "Composante JcJ", 18)
    end

    -- Special objectives are a useful generic danger signal without claiming
    -- that every special objective is an elite/escort.
    local specialCount = 0
    if quest.SpecialObjectives then
        for _ in pairs(quest.SpecialObjectives) do specialCount = specialCount + 1 end
    end
    if specialCount > 0 then
        AddFactor(result, "Objectif spécial", math.min(12, specialCount * 6))
    end

    -- Very old quests should not be made artificially dangerous by missing DB data.
    if not result.creatureMaxLevel and delta <= 0 and not isDungeon and not isRaid then
        result.positives[#result.positives + 1] = "Aucune donnée de niveau de mob disponible"
    end

    result.score = math.floor(Clamp(result.score, 0, 100) + 0.5)
    result.severity, result.severityText, result.colorR, result.colorG, result.colorB = Severity(result.score)
    result.isHardcore = Questie and Questie.IsHardcore == true

    -- Difficulty is kept for future consumers, but never feeds the score twice.
    if QuestieLib and QuestieLib.GetEffectiveQuestLevel then
        local okLevel, effective = pcall(QuestieLib.GetEffectiveQuestLevel, questId)
        if okLevel and effective then result.effectiveQuestLevel = effective end
    end
    return result
end

function QuestieHardcore:AnalyzeQuestList(questIds)
    local out = {}
    local seen = {}
    for _, questId in ipairs(questIds or {}) do
        if not seen[questId] then
            local analysis = self:AnalyzeQuest(questId)
            if analysis then out[#out + 1] = analysis end
            seen[questId] = true
        end
    end
    return out
end

function QuestieHardcore:GetRecommendation(result)
    if not result then return "" end
    if result.score >= 90 then return "Déconseillée en Hardcore : risque critique." end
    if result.score >= 75 then return "Très prudente : envisage une alternative si disponible." end
    if result.score >= 60 then return "Prudence : contrôle les pulls et garde une voie de retraite." end
    if result.score >= 40 then return "Jouable avec prudence." end
    return "Risque limité avec les données disponibles."
end
