---@class SystemEventBus : MessageHandler
local SystemEventBus = QuestieLoader:CreateModule("SystemEventBus")

local MessageHandlerFactory = QuestieLoader:ImportModule("MessageHandlerFactory")

SystemEventBus = Mixin(SystemEventBus, MessageHandlerFactory.New("SystemEventBus")) --[[@as SystemEventBus]]


----------- Event Definition -----------

---* Contains all events in their string format
---@class SystemEventBusEvents : SystemEventBusFormatEvents, SystemEventBusParameterEvents, SystemEventBusSimpleEvents
local events = {}

---@class SystemEventBusSimpleEvents
local simpleEvents = {
    -- Ace3 DB is loaded
    ---@type SimpleEvent
    ACE_DB_LOADED = "ACE-DB-LOADED",

    -- Initialization in QuestieInit is done
    ---@type SimpleEvent
    INITIALIZE_DONE = "INITIALIZE-DONE", -- Called when all modules are loaded and initialized (End of QuestieInit)

    ---@type SimpleEvent
    MODIFIER_PRESSED_SHIFT      = "KEY_PRESS-KEY_PRESS_MODIFIER_PRESSED_SHIFT",
    ---@type SimpleEvent
    MODIFIER_RELEASED_SHIFT     = "KEY_PRESS-KEY_PRESS_MODIFIER_RELEASED_SHIFT",
    ---@type SimpleEvent
    MODIFIER_PRESSED_CTRL       = "KEY_PRESS-KEY_PRESS_MODIFIER_PRESSED_CTRL",
    ---@type SimpleEvent
    MODIFIER_RELEASED_CTRL      = "KEY_PRESS-KEY_PRESS_MODIFIER_RELEASED_CTRL",
    ---@type SimpleEvent
    MODIFIER_PRESSED_ALT        = "KEY_PRESS-KEY_PRESS_MODIFIER_PRESSED_ALT",
    ---@type SimpleEvent
    MODIFIER_RELEASED_ALT       = "KEY_PRESS-KEY_PRESS_MODIFIER_RELEASED_ALT",
}

-- Events that require some kind of parameter to execute
-- It is up to the fire and use functions to validate the parameters
---@class SystemEventBusParameterEvents
local parameterEvents = {
    --* Below is an example on how to tag a parameter event
    -- ---@type ParameterEvent|fun(questId: QuestId)
    -- QUEST_ACCEPTED = "QUEST-ACCEPTED",
}

---@class SystemEventBusFormatEvents
local formatEvents = {
    --* Below is are examples on how to tag the different variants
    -- ---@type FormatEvent|table<UiMapId, string>
    -- DRAW_WAYPOINTS_UIMAPID = SystemEventBus.CreateFormaterEvent("DRAW_RELATION_UIMAPID", "DRAW_WAYPOINTS_UIMAPID_%d", { "UiMapId" }),

    -- ---@type FormatEvent|fun(UiMapId: number, param2: any): string
    -- DRAW_WAYPOINTS_UIMAPID = createParameterizedEvent("DRAW_RELATION_UIMAPID", "DRAW_WAYPOINTS_UIMAPID_%d", {"UiMapId"}),
}

--! Use this table to override the default fire functions (or if you use a FormatEvent)
--* All events/attributes are functions even though they might look like other types (table, string, etc.)
--* Add functions manually here to have more type safety and descriptive functions
--? Fire event is slower than calling :Fire directly in calling area
--? However some events are only called sparingly so usability is more important
---@class SystemEventBusFireEvent : SystemEventBusEvents
SystemEventBus.FireEvent = {}

----------- Event Registration -----------

events = Mixin({}, formatEvents, parameterEvents, simpleEvents) --[[@as SystemEventBusEvents]]

---* This can be used either as a simple event or as a parameterized event
---* If it only got one parameter the event has to be used as a table
---* If there is more than one parameter the event has to be called like a function
SystemEventBus.events = events


--? Populate the FireEvent table with the simple events.
for eventNameKey, eventNameValue in pairs(simpleEvents) do
    -- Only add the event if it is not already added
    if not SystemEventBus.FireEvent[eventNameKey] then
        SystemEventBus.FireEvent[eventNameKey] = function()
            SystemEventBus:Fire(eventNameValue)
        end
    end
end

--? Populate the FireEvent table with the parameterEvents.
for eventNameKey, eventNameValue in pairs(parameterEvents) do
    -- Only add the event if it is not already added
    if not SystemEventBus.FireEvent[eventNameKey] then
        SystemEventBus.FireEvent[eventNameKey] = function(firstParam, ...)
            if not firstParam then error("Error in event " .. eventNameKey .. " - firstParam is nil, this event requires parameters", 2) end
            SystemEventBus:Fire(eventNameValue, firstParam, ...)
        end
    end
end
