---@class QuestieHardcoreRiskEngine
local QuestieHardcoreRiskEngine = QuestieLoader:CreateModule("QuestieHardcoreRiskEngine")

local floor = math.floor
local max = math.max

local function _Clamp(value, low, high)
    if value < low then
        return low
    end
    if value > high then
        return high
    end
    return value
end

local function _LevelRisk(delta)
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

local function _Severity(score)
    if score < 20 then
        return "TRÈS FAIBLE"
    elseif score < 40 then
        return "FAIBLE"
    elseif score < 60 then
        return "MODÉRÉ"
    elseif score < 80 then
        return "ÉLEVÉ"
    end

    return "TRÈS ÉLEVÉ"
end

local function _Confidence(data)
    if data.questLevel and data.creatureMax then
        return "ÉLEVÉE"
    elseif data.questLevel or data.creatureMax then
        return "MOYENNE"
    end

    return "FAIBLE"
end

local function _QuestTypeRisk(data)
    local score = 0
    local modifier = 0
    local factors = {}

    if data.group then
        score = max(score, 45)
        modifier = modifier + 15
        factors[#factors + 1] = "Quête de groupe"
    end

    if data.dungeon then
        score = max(score, 55)
        modifier = modifier + 12
        factors[#factors + 1] = "Quête de donjon"
    end

    if data.raid then
        score = max(score, 90)
        modifier = modifier + 25
        factors[#factors + 1] = "Quête de raid"
    end

    if data.pvp then
        score = max(score, 40)
        modifier = modifier + 8
        factors[#factors + 1] = "Quête JcJ"
    end

    return score, modifier, factors
end

---@param data table
---@return table
function QuestieHardcoreRiskEngine:Analyze(data)
    local playerLevel = data.playerLevel or 1

    local levelRisk = nil
    if data.questLevel then
        levelRisk = _LevelRisk(data.questLevel - playerLevel)
    end

    local objectiveRisk = nil
    if data.creatureMax then
        objectiveRisk = _LevelRisk(data.creatureMax - playerLevel)
    end

    local questTypeRisk, typeModifier, typeFactors = _QuestTypeRisk(data)

    local baseRisk = max(levelRisk or 0, objectiveRisk or 0)
    local score = _Clamp(baseRisk + typeModifier, 0, 100)

    local factors = {}

    if data.questLevel then
        local delta = data.questLevel - playerLevel
        if delta > 0 then
            factors[#factors + 1] = "Quête +" .. delta .. " niveau" .. (delta > 1 and "x" or "")
        elseif delta == 0 then
            factors[#factors + 1] = "Quête au niveau du joueur"
        else
            factors[#factors + 1] = "Quête " .. delta .. " niveaux"
        end
    end

    if data.creatureMax then
        local delta = data.creatureMax - playerLevel
        if delta > 0 then
            factors[#factors + 1] = "Mobs associés jusqu'à +" .. delta
        elseif delta == 0 then
            factors[#factors + 1] = "Mobs associés au niveau du joueur"
        else
            factors[#factors + 1] = "Mobs associés sous le niveau du joueur"
        end
    end

    for _, factor in ipairs(typeFactors) do
        factors[#factors + 1] = factor
    end

    return {
        score = floor(score + 0.5),
        severity = _Severity(score),
        confidence = _Confidence(data),
        components = {
            level = levelRisk,
            objectives = objectiveRisk,
            questType = questTypeRisk,
            environment = nil,
        },
        factors = factors,
    }
end

return QuestieHardcoreRiskEngine
