---@class QuestEventBus : MessageHandler
local QuestEventBus = QuestieLoader:CreateModule("QuestEventBus")

local MessageHandlerFactory = QuestieLoader:ImportModule("MessageHandlerFactory")

QuestEventBus = Mixin(QuestEventBus, MessageHandlerFactory.New("QuestEventBus")) --[[@as QuestEventBus]]

----------- Event Definition -----------

---* Contains all events in their string format
---@class QuestEventBusEvents : QuestEventBusFormatEvents, QuestEventBusParameterEvents, QuestEventBusSimpleEvents
local events = {}

---@class QuestEventBusSimpleEvents
local simpleEvents = {}

-- Events that require some kind of parameter to execute
-- It is up to the fire and use functions to validate the parameters
---@class QuestEventBusParameterEvents
local parameterEvents = {
    ---@type ParameterEvent|fun(questId: QuestId)
    QUEST_ACCEPTED = "QUEST-ACCEPTED",
    ---@type ParameterEvent|fun(questId: QuestId)
    QUEST_ABANDONED = "QUEST-ABANDONED",
    ---@type ParameterEvent|fun(questId: QuestId)
    QUEST_COMPLETED = "QUEST-COMPLETED",

    ---@type ParameterEvent|fun(questId: QuestId, changes: table)
    QUEST_UPDATED = "QUEST-UPDATE",

    ---@type ParameterEvent|fun(ShowData: Show)
    CALCULATE_AVAILABLE_QUESTS_DONE = "CALCULATE_AVAILABLE_QUESTS_DONE",
    ---@type ParameterEvent|fun(ShowData: Show)
    CALCULATE_COMPLETED_QUESTS_DONE = "CALCULATE_COMPLETED_QUESTS_DONE",
}

---@class QuestEventBusFormatEvents
local formatEvents = {
    --* Below is are examples on how to tag the different variants
    -- ---@type FormatEvent|table<UiMapId, string>
    -- DRAW_WAYPOINTS_UIMAPID = QuestEventBus.CreateFormaterEvent("DRAW_RELATION_UIMAPID", "DRAW_WAYPOINTS_UIMAPID_%d", { "UiMapId" }),

    -- ---@type FormatEvent|fun(UiMapId: number, param2: any): string
    -- DRAW_WAYPOINTS_UIMAPID = createParameterizedEvent("DRAW_RELATION_UIMAPID", "DRAW_WAYPOINTS_UIMAPID_%d", {"UiMapId"}),
}

--! Use this table to override the default fire functions (or if you use a FormatEvent)
--* All events/attributes are functions even though they might look like other types (table, string, etc.)
--* Add functions manually here to have more type safety and descriptive functions
--? Fire event is slower than calling :Fire directly in calling area
--? However some events are only called sparingly so usability is more important
---@class QuestEventBusFireEvent : QuestEventBusEvents
QuestEventBus.FireEvent = {}

----------- Event Registration -----------

events = Mixin({}, formatEvents, parameterEvents, simpleEvents) --[[@as QuestEventBusEvents]]

---* This can be used either as a simple event or as a parameterized event
---* If it only got one parameter the event has to be used as a table
---* If there is more than one parameter the event has to be called like a function
QuestEventBus.events = events


--? Populate the FireEvent table with the simple events.
for eventNameKey, eventNameValue in pairs(simpleEvents) do
    -- Only add the event if it is not already added
    if not QuestEventBus.FireEvent[eventNameKey] then
        QuestEventBus.FireEvent[eventNameKey] = function()
            QuestEventBus:Fire(eventNameValue)
        end
    end
end

--? Populate the FireEvent table with the parameterEvents.
for eventNameKey, eventNameValue in pairs(parameterEvents) do
    -- Only add the event if it is not already added
    if not QuestEventBus.FireEvent[eventNameKey] then
        QuestEventBus.FireEvent[eventNameKey] = function(firstParam, ...)
            if not firstParam then error("Error in event " .. eventNameKey .. " - firstParam is nil, this event requires parameters", 2) end
            QuestEventBus:Fire(eventNameValue, firstParam, ...)
        end
    end
end
