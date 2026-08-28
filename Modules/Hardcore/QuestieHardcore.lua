---@class QuestieHardcore
local QuestieHardcore = QuestieLoader:CreateModule("QuestieHardcore")
local _QuestieHardcore = QuestieHardcore.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")

local floor = math.floor
local min = math.min
local max = math.max

local function Clamp(value, low, high)
    if value < low then return low end
    if value > high then return high end
    return value
end

local function PlayerLevel()
    return UnitLevel("player") or 1
end

local function QuestLevel(questId, quest)
    if quest and quest.level and quest.level > 0 then
        return quest.level
    end

    if QuestieLib and QuestieLib.GetEffectiveQuestLevel then
        local level = QuestieLib.GetEffectiveQuestLevel(questId)
        if level and level > 0 then
            return level
        end
    end

    return nil
end

local function LevelRisk(delta)
    if delta <= -4 then return 0 end
    if delta == -3 then return 2 end
    if delta == -2 then return 5 end
    if delta == -1 then return 10 end
    if delta == 0 then return 16 end
    if delta == 1 then return 30 end
    if delta == 2 then return 48 end
    if delta == 3 then return 67 end
    if delta == 4 then return 83 end
    return 95
end

local function GetCreatureRisk(quest)
    if not quest or not QuestieDB.GetCreatureLevels then
        return nil, nil, nil
    end

    local ok, minLevel, maxLevel = pcall(QuestieDB.GetCreatureLevels, quest)
    if not ok then
        return nil, nil, nil
    end

    -- Questie versions have returned slightly different shapes over time.
    if type(minLevel) == "table" then
        local data = minLevel
        minLevel = data[1] or data.min
        maxLevel = data[2] or data.max
    end

    if not minLevel and maxLevel then
        minLevel = maxLevel
    end
    if not maxLevel and minLevel then
        maxLevel = minLevel
    end

    if type(minLevel) ~= "number" or type(maxLevel) ~= "number" then
        return nil, nil, nil
    end

    local playerLevel = PlayerLevel()
    local delta = maxLevel - playerLevel
    return LevelRisk(delta), minLevel, maxLevel
end

local function GetInstanceModifier(questId)
    local modifier = 0
    local dungeon = false
    local raid = false
    local pvp = false

    if QuestieDB.IsDungeonQuest and QuestieDB.IsDungeonQuest(questId) then
        dungeon = true
        modifier = modifier + 8
    end

    if QuestieDB.IsRaidQuest and QuestieDB.IsRaidQuest(questId) then
        raid = true
        modifier = modifier + 15
    end

    if QuestieDB.IsPvPQuest and QuestieDB.IsPvPQuest(questId) then
        pvp = true
        modifier = modifier + 6
    end

    return modifier, dungeon, raid, pvp
end

-- Public API: returns a normalized 0-100 Hardcore risk score.
function QuestieHardcore:GetQuestRisk(questId)
    local quest = QuestieDB.GetQuest(questId)
    if not quest then
        return nil
    end

    local playerLevel = PlayerLevel()
    local questLevel = QuestLevel(questId, quest)

    local questRisk = nil
    if questLevel then
        questRisk = LevelRisk(questLevel - playerLevel)
    end

    local creatureRisk, creatureMin, creatureMax = GetCreatureRisk(quest)

    -- If both are known, use the more dangerous of the two. This avoids
    -- double-counting quest level and mob level.
    local score = max(questRisk or 0, creatureRisk or 0)

    local modifier, dungeon, raid, pvp = GetInstanceModifier(questId)
    score = Clamp(score + modifier, 0, 100)

    local label
    if score < 20 then
        label = "TRÈS FAIBLE"
    elseif score < 40 then
        label = "FAIBLE"
    elseif score < 60 then
        label = "MODÉRÉ"
    elseif score < 80 then
        label = "ÉLEVÉ"
    else
        label = "TRÈS ÉLEVÉ"
    end

    return {
        score = floor(score + 0.5),
        label = label,
        playerLevel = playerLevel,
        questLevel = questLevel,
        creatureMin = creatureMin,
        creatureMax = creatureMax,
        questRisk = questRisk,
        creatureRisk = creatureRisk,
        dungeon = dungeon,
        raid = raid,
        pvp = pvp,
        modifier = modifier,
    }
end

function QuestieHardcore:GetQuestRiskLines(questId)
    local result = self:GetQuestRisk(questId)
    if not result then
        return nil
    end

    local lines = {}

    local scoreColor = "|cFF66FF66"
    if result.score >= 80 then
        scoreColor = "|cFFFF5555"
    elseif result.score >= 60 then
        scoreColor = "|cFFFFAA33"
    elseif result.score >= 40 then
        scoreColor = "|cFFFFFF55"
    end

    lines[#lines + 1] = "|TInterface\\AddOns\\Questie\\Icons\\questie_flat.png:14|t |cFF66CCFFHC|r |cFFFFFFFFANALYSE HARDCORE|r"
    lines[#lines + 1] = scoreColor .. "Risque : " .. result.score .. "/100  •  " .. result.label .. "|r"
    lines[#lines + 1] = "|cFFAAAAAANiveau joueur :|r " .. result.playerLevel

    if result.questLevel then
        lines[#lines + 1] = "|cFFAAAAAANiveau quête :|r " .. result.questLevel
    end

    if result.creatureMin and result.creatureMax then
        if result.creatureMin == result.creatureMax then
            lines[#lines + 1] = "|cFFAAAAAAMobs associés :|r niveau " .. result.creatureMax
        else
            lines[#lines + 1] = "|cFFAAAAAAMobs associés :|r " .. result.creatureMin .. "–" .. result.creatureMax
        end
    end

    local factors = {}
    if result.questRisk then
        factors[#factors + 1] = "niveau quête"
    end
    if result.creatureRisk then
        factors[#factors + 1] = "niveau des mobs"
    end
    if result.dungeon then
        factors[#factors + 1] = "donjon"
    end
    if result.raid then
        factors[#factors + 1] = "raid"
    end
    if result.pvp then
        factors[#factors + 1] = "JcJ"
    end

    if #factors > 0 then
        lines[#lines + 1] = "|cFF777777Facteurs :|r " .. table.concat(factors, " + ")
    end

    return lines
end

-- Adds the HC block to Questie's existing NPC/object tooltips without
-- replacing or altering Questie's own text.
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

        -- A single object/item can be referenced by several quests. Showing one
        -- complete HC block per quest quickly becomes noisy and can even look
        -- like a duplicate. Keep only the highest-risk relevant analysis.
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
