---@class ObjectiveOrderCorrections
local ObjectiveOrderCorrections = QuestieLoader:CreateModule("ObjectiveOrderCorrections")

-------------------------
--Import modules.
-------------------------
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local tinsert, next = table.insert, next

---@param objective Objective
---@return number|nil
local function _GetObjectiveOrderMoveId(objective)
    if objective.Type == "killcredit" then
        return objective.RootId
    end

    return objective.Id
end

---@param objective Objective|nil
---@param move ObjectiveOrderMove
---@return boolean
local function _ObjectiveMatchesOrderMove(objective, move)
    if (not objective) or objective.Type ~= move.Type then
        return false
    end

    if move.Type == "event" then
        return true
    end

    return move.Id ~= nil and _GetObjectiveOrderMoveId(objective) == move.Id
end

---@param questId QuestId
---@param reason string
local function _LogInvalidObjectiveOrderMove(questId, reason)
    Questie:Error("[ObjectiveOrderCorrections] Invalid objectiveOrderMoves for quest", questId, reason)
end

---@param questId QuestId
---@param objectiveData Objective[]
---@return Objective[] objectiveData
---@return boolean appliedMoveCorrection
local function _ApplyObjectiveOrderMoves(questId, objectiveData)
    local moves = QuestieCorrections.objectiveOrderMoves[questId]
    if not moves then
        return objectiveData, false
    end
    if type(moves) ~= "table" then
        _LogInvalidObjectiveOrderMove(questId, "moves must be a table")
        return objectiveData, false
    end
    if not next(moves) then
        return objectiveData, false
    end

    local movedFrom = {}
    local usedTo = {}
    for _, move in pairs(moves) do
        if type(move) ~= "table" then
            _LogInvalidObjectiveOrderMove(questId, "move must be a table")
            return objectiveData, false
        end
        if type(move.From) ~= "number" or type(move.To) ~= "number" then
            _LogInvalidObjectiveOrderMove(questId, "From and To must be numbers")
            return objectiveData, false
        end
        if move.From ~= math.floor(move.From) or move.To ~= math.floor(move.To) then
            _LogInvalidObjectiveOrderMove(questId, "From and To must be integers")
            return objectiveData, false
        end
        if move.From < 1 or move.From > #objectiveData or move.To < 1 or move.To > #objectiveData then
            _LogInvalidObjectiveOrderMove(questId, "From or To is outside objective range")
            return objectiveData, false
        end
        if movedFrom[move.From] then
            _LogInvalidObjectiveOrderMove(questId, "duplicate From")
            return objectiveData, false
        end
        if usedTo[move.To] then
            _LogInvalidObjectiveOrderMove(questId, "duplicate To")
            return objectiveData, false
        end
        if not _ObjectiveMatchesOrderMove(objectiveData[move.From], move) then
            _LogInvalidObjectiveOrderMove(questId, "objective at From does not match")
            return objectiveData, false
        end

        movedFrom[move.From] = true
        usedTo[move.To] = true
    end

    local result = {}
    for _, move in pairs(moves) do
        result[move.To] = objectiveData[move.From]
    end

    local fillIndex = 1
    for index = 1, #objectiveData do
        if not movedFrom[index] then
            while result[fillIndex] do
                fillIndex = fillIndex + 1
            end
            result[fillIndex] = objectiveData[index]
        end
    end

    return result, true
end

---@param questId QuestId
---@param objective Objective
---@return boolean
local function _IsLegacyObjectiveFirst(questId, objective)
    if objective.Type == "object" then
        return QuestieCorrections.objectObjectiveFirst[questId]
    elseif objective.Type == "item" then
        return QuestieCorrections.itemObjectiveFirst[questId]
    elseif objective.Type == "killcredit" then
        return QuestieCorrections.killCreditObjectiveFirst[questId]
    elseif objective.Type == "spell" then
        return QuestieCorrections.spellObjectiveFirst[questId]
    elseif objective.Type == "event" then
        return QuestieCorrections.eventObjectiveFirst[questId]
    end

    return false
end

---@param questId QuestId
---@param objectiveData Objective[]
---@return Objective[]
local function _ApplyLegacyObjectiveFirstCorrections(questId, objectiveData)
    local result = {}
    --? There are quest(s) which have specific objective types first so we need to switch them
    for index = 1, #objectiveData do
        local objective = objectiveData[index]
        if _IsLegacyObjectiveFirst(questId, objective) then
            tinsert(result, 1, objective)
        else
            result[#result+1] = objective
        end
    end

    return result
end

---@param questId QuestId
---@param objectiveData Objective[]
---@return Objective[]
function ObjectiveOrderCorrections:Apply(questId, objectiveData)
    local movedObjectiveData, appliedMoveCorrection = _ApplyObjectiveOrderMoves(questId, objectiveData)
    if appliedMoveCorrection then
        return movedObjectiveData
    end

    return _ApplyLegacyObjectiveFirstCorrections(questId, objectiveData)
end

return ObjectiveOrderCorrections
