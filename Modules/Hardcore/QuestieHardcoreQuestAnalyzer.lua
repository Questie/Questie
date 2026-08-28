---@class QuestieHardcoreQuestAnalyzer
local QuestieHardcoreQuestAnalyzer = QuestieLoader:CreateModule("QuestieHardcoreQuestAnalyzer")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local function _PlayerLevel()
    return UnitLevel("player") or 1
end

local function _QuestLevel(questId, quest)
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

local function _CreatureLevels(quest)
    if not quest or not QuestieDB.GetCreatureLevels then
        return nil, nil
    end

    local ok, first, second = pcall(QuestieDB.GetCreatureLevels, quest)
    if not ok then
        return nil, nil
    end

    local minLevel = first
    local maxLevel = second

    if type(first) == "table" then
        minLevel = first[1] or first.min
        maxLevel = first[2] or first.max
    end

    if type(minLevel) ~= "number" and type(maxLevel) == "number" then
        minLevel = maxLevel
    end
    if type(maxLevel) ~= "number" and type(minLevel) == "number" then
        maxLevel = minLevel
    end

    if type(minLevel) ~= "number" or type(maxLevel) ~= "number" then
        return nil, nil
    end

    return minLevel, maxLevel
end

local function _SafeQuestFlag(methodName, questId)
    local method = QuestieDB[methodName]
    if type(method) ~= "function" then
        return false
    end

    local ok, value = pcall(method, questId)
    return ok and value == true
end

---@param questId number
---@return table|nil
function QuestieHardcoreQuestAnalyzer:Analyze(questId)
    local quest = QuestieDB.GetQuest(questId)
    if not quest then
        return nil
    end

    local creatureMin, creatureMax = _CreatureLevels(quest)

    return {
        questId = questId,
        playerLevel = _PlayerLevel(),
        questLevel = _QuestLevel(questId, quest),
        creatureMin = creatureMin,
        creatureMax = creatureMax,

        -- Only high-confidence Questie classifications are used in v0.3.
        -- We deliberately do NOT infer elite status from arbitrary item drop sources.
        group = _SafeQuestFlag("IsGroupQuest", questId),
        dungeon = _SafeQuestFlag("IsDungeonQuest", questId),
        raid = _SafeQuestFlag("IsRaidQuest", questId),
        pvp = _SafeQuestFlag("IsPvPQuest", questId),
    }
end

return QuestieHardcoreQuestAnalyzer
