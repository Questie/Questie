---@meta _

-- ----------------------------------------------------------------------------
-- CallbackHandler-1.0
-- ----------------------------------------------------------------------------
---@class CallbackHandler-1.0
local CallbackHandler = {}

---@param target table target object to embed public APIs in
---@param RegisterName? string name of the callback registration API, default "RegisterCallback"
---@param UnregisterName? string name of the callback unregistration API, default "UnregisterCallback"
---@param UnregisterAllName? string name of the API to unregister all callbacks, default "UnregisterAllCallbacks". false == don't publish this API.
---@return CallbackHandlerRegistry
function CallbackHandler:New(target, RegisterName, UnregisterName, UnregisterAllName) end

-- ----------------------------------------------------------------------------
-- CallbackHandlerRegistry
-- ----------------------------------------------------------------------------
---@class CallbackHandlerRegistry
---@field OnUnused? fun(registry: CallbackHandlerRegistry, target: table, eventName: string) If defined, called when an event stops.
---@field OnUsed? fun(registry: CallbackHandlerRegistry, target: table, eventName: string) If defined, called when an event starts.
local CallbackHandlerRegistry = {}

---fires the given event/message into the registry
---@param eventname string
---@param ... unknown passed to the functions listening to the event.
function CallbackHandlerRegistry:Fire(eventname, ...) end
