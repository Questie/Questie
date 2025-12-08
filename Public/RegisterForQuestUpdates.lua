---@class QuestieAPI
local QuestieAPI = QuestieLoader:ImportModule("QuestieAPI")

---@type fun(questId: number, objectiveIndex: number?, triggerReason: QuestUpdateTriggerReason)[]
local questUpdateCallbacks = {}

--- Registers a callback function that will be called whenever a quest is updated.
--- The callback function should accept three parameters: questId (number), the objective index (number|nil) and the trigger reason (Enum).
---@param callback fun(questId: number, objectiveIndex: number?, triggerReason: QuestUpdateTriggerReason)
function Questie.API.RegisterForQuestUpdates(callback)
    if type(callback) ~= "function" then
        error("Questie.API.RegisterForQuestUpdates: callback must be a function")
    end

    table.insert(questUpdateCallbacks, callback)
end

---@param questId QuestId
---@param objectiveIndices number[]
---@param triggerReason QuestUpdateTriggerReason
function QuestieAPI.PropagateQuestUpdate(questId, objectiveIndices, triggerReason)
    for _, callback in pairs(questUpdateCallbacks) do
        if next(objectiveIndices) then
            for _, objectiveIndex in pairs(objectiveIndices) do
                xpcall(function() callback(questId, objectiveIndex, triggerReason) end, CallErrorHandler)
            end
        else
            xpcall(function() callback(questId, nil, triggerReason) end, CallErrorHandler)
        end
    end
end

return QuestieAPI
