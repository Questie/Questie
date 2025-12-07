---@class QuestieAPI
local QuestieAPI = QuestieLoader:CreateModule("QuestieAPI")

-- This module is used as official API for other addons to interact with Questie.
-- Everything that is exposed via Questie.API should be considered stable and safe to use.

---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")

QuestieAPI.Enums = {
    ---@enum QuestUpdateTriggerReason
    QuestUpdateTriggerReason = {
        QUEST_ACCEPTED = 1,
        QUEST_UPDATED = 2,
        QUEST_TURNED_IN = 3,
        QUEST_ABANDONED = 4,
    }
}
Questie.API.Enums = QuestieAPI.Enums

---@type table<number, fun()>
local onReadyCallbacks = {}

--- Register a callback to be invoked once Questie.API.isReady becomes true.
--- If already ready, the callback is invoked immediately.
---@param callback fun()
function Questie.API.RegisterOnReady(callback)
    if type(callback) ~= "function" then
        error("Questie.API.RegisterOnReady: callback must be a function")
    end

    if Questie.API.isReady then
        xpcall(callback, CallErrorHandler)
        return
    end

    table.insert(onReadyCallbacks, callback)
end

function QuestieAPI.PropagateOnReady()
    if (not Questie.API.isReady) then
        return
    end

    for _, callback in pairs(onReadyCallbacks) do
        xpcall(callback, CallErrorHandler)
    end
    onReadyCallbacks = {}
end

--- Returns the icon path for the quest objective marker for the given unit GUID.
--- Only NPC GUIDs are valid inputs.
---@param guid string
---@return string | nil -- Path to the icon texture, or nil if no icon is available.
function Questie.API.GetQuestObjectiveIconForUnit(guid)
    if (not Questie.API.isReady) then
        return nil
    end

    return QuestieNameplate.GetIcon(guid)
end

---@type table<number, fun(questId: number, objectiveIndex: number|nil, triggerReason: QuestUpdateTriggerReason)>
local questUpdateCallbacks = {}

--- Registers a callback function that will be called whenever a quest is updated.
--- The callback function should accept three parameters: questId (number), the objective index (number|nil) (if applicable) and the trigger reason (Enum).
---@param callback fun(questId: number, objectiveIndex: number, triggerReason: QuestUpdateTriggerReason)
function Questie.API.RegisterForQuestUpdates(callback)
    if type(callback) ~= "function" then
        error("Questie.API.RegisterForQuestUpdates: callback must be a function")
    end

    table.insert(questUpdateCallbacks, callback)
end

---@param questId QuestId
---@param objectiveIndices table<number|nil>
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
