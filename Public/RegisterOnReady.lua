---@class QuestieAPI
local QuestieAPI = QuestieLoader:ImportModule("QuestieAPI")

---@type fun()[]
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

return QuestieAPI
