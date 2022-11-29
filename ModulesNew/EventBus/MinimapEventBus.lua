---@class MinimapEventBus : EventBus
local MinimapEventBus = QuestieLoader:CreateModule("MinimapEventBus")

local EventBusFactory = QuestieLoader:ImportModule("EventBusFactory")

MinimapEventBus = Mixin(MinimapEventBus, EventBusFactory.New("MinimapEventBus")) --[[@as MinimapEventBus]]

----------- Event Definition -----------

---* Contains all events in their string format
---@class MinimapEventBusEvents : MinimapEventBusFormatEvents, MinimapEventBusParameterEvents, MinimapEventBusSimpleEvents
local events = {}

---@class MinimapEventBusSimpleEvents
local simpleEvents = {
    --* Map Events

    -- Redraw everything on the map
    ---@type SimpleEvent
    REDRAW_ALL = "REDRAW_ALL",

    --* Relation Events
    ---@type SimpleEvent
    REDRAW_ALL_RELATIONS = "REDRAW_ALL_RELATIONS",

    ---@type SimpleEvent
    REMOVE_ALL_AVAILABLE = "REMOVE_ALL_AVAILABLE",
    ---@type SimpleEvent
    REMOVE_ALL_COMPLETED = "REMOVE_ALL_COMPLETED",

    ---@type SimpleEvent
    REMOVE_ALL_RELATIONS = "REMOVE_ALL_RELATIONS",
    ---@type SimpleEvent
    AVAILABLE_QUESTS_DRAWN = "AVAILABLE_QUESTS_DRAWN",

    --* Tooltip Events

    ---@type SimpleEvent
    WRITE_WAYPOINT_TOOLTIP = "WRITE_WAYPOINT_TOOLTIP",
    ---@type SimpleEvent
    RESET_TOOLTIP = "RESET_TOOLTIP",
    ---@type SimpleEvent
    DRAW_TOOLTIP = "DRAW_TOOLTIP",
}

-- Events that require some kind of parameter to execute
-- It is up to the fire and use functions to validate the parameters
---@class MinimapEventBusParameterEvents
local parameterEvents = {
    --* Below is an example on how to tag a parameter event
    -- ---@type ParameterEvent|fun(questId: QuestId)
    -- QUEST_ACCEPTED = "QUEST-ACCEPTED",
}

---@class MinimapEventBusFormatEvents
local formatEvents = {
    --* Map Events
    -- Draws all the waypoints on a specific map
    ---@type FormatEvent|table<UiMapId, string>
    DRAW_RELATION_UIMAPID = MinimapEventBus.CreateFormaterEvent("DRAW_RELATION_UIMAPID", "DRAW_RELATION_UIMAPID_%d", { "UiMapId" }),

    -- Draws all the waypoints on a specific map
    ---@type FormatEvent|table<UiMapId, string>
    DRAW_WAYPOINTS_UIMAPID = MinimapEventBus.CreateFormaterEvent("DRAW_RELATION_UIMAPID", "DRAW_WAYPOINTS_UIMAPID_%d", { "UiMapId" }),

    --* Below is an example on how to tag the function variant
    -- ---@type FormatEvent|fun(UiMapId: number, param2: any): string
    -- DRAW_WAYPOINTS_UIMAPID = createParameterizedEvent("DRAW_RELATION_UIMAPID", "DRAW_WAYPOINTS_UIMAPID_%d", {"UiMapId"}),

    -- Remove all quests by id
    ---@type FormatEvent|table<QuestId, string>
    REMOVE_QUEST = MinimapEventBus.CreateFormaterEvent("REMOVE_QUEST", "REMOVE_QUEST_%d", { "QuestId" }),

    -- Remove all objectives by id
    ---@type FormatEvent|fun(questId: QuestId, objectiveIndex: ObjectiveIndex)
    REMOVE_OBJECTIVE = MinimapEventBus.CreateFormaterEvent("REMOVE_OBJECTIVE", "REMOVE_OBJECTIVE_%d_%d", { "QuestId", "ObjectiveIndex" }),
}

--! Use this table to override the default fire functions (or if you use a FormatEvent)
--* All events/attributes are functions even though they might look like other types (table, string, etc.)
--* Add functions manually here to have more type safety and descriptive functions
--? Fire event is slower than calling :Fire directly in calling area
--? However some events are only called sparingly so usability is more important
---@class MinimapEventBusFireEvent : MinimapEventBusEvents
MinimapEventBus.FireEvent = {
    ---@param UiMapId UiMapId
    DRAW_RELATION_UIMAPID = function(UiMapId)
        if UiMapId == nil then error("Error in event DRAW_RELATION_UIMAPID - UiMapId is nil", 2) end
        MinimapEventBus:Fire(events.DRAW_RELATION_UIMAPID[UiMapId])
    end,
    ---@param UiMapId UiMapId
    DRAW_WAYPOINTS_UIMAPID = function(UiMapId)
        if UiMapId == nil then error("Error in event DRAW_WAYPOINTS_UIMAPID - UiMapId is nil", 2) end
        MinimapEventBus:Fire(events.DRAW_WAYPOINTS_UIMAPID[UiMapId])
    end,
}

----------- Event Registration -----------

events = Mixin({}, formatEvents, parameterEvents, simpleEvents) --[[@as MinimapEventBusEvents]]

---* This can be used either as a simple event or as a parameterized event
---* If it only got one parameter the event has to be used as a table
---* If there is more than one parameter the event has to be called like a function
MinimapEventBus.events = events

--? Populate the FireEvent table with the simple events.
for eventNameKey, eventNameValue in pairs(simpleEvents) do
    -- Only add the event if it is not already added
    if not MinimapEventBus.FireEvent[eventNameKey] then
        MinimapEventBus.FireEvent[eventNameKey] = function()
            MinimapEventBus:Fire(eventNameValue)
        end
    end
end

--? Populate the FireEvent table with the parameterEvents.
for eventNameKey, eventNameValue in pairs(parameterEvents) do
    -- Only add the event if it is not already added
    if not MinimapEventBus.FireEvent[eventNameKey] then
        MinimapEventBus.FireEvent[eventNameKey] = function(firstParam, ...)
            if not firstParam then error("Error in event " .. eventNameKey .. " - firstParam is nil, this event requires parameters", 2) end
            MinimapEventBus:Fire(eventNameValue, firstParam, ...)
        end
    end
end
