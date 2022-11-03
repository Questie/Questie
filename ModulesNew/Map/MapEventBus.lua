---@class MapEventBus : MessageHandler
local MapEventBus = QuestieLoader:CreateModule("MapEventBus")

local MessageHandlerFactory = QuestieLoader:ImportModule("MessageHandlerFactory")

MapEventBus = Mixin(MapEventBus, MessageHandlerFactory.New("MapEventBus")) --[[@as MapEventBus]]


MapEventBus.events = {
    MAP = {
        DRAW_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_UIMAPID_%d", UiMapId) end,
        REMOVE_QUEST = function(questId) return string.format("MAP-REMOVE_QUEST_%d", questId) end,

        REDRAW_ALL = "MAP-REDRAW_ALL",
        -- REMOVE_QUEST = "MAP-REMOVE_QUEST", --Return questId, catch-all remove pins


        -- DRAW_WAYPOINTS_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_WAYPOINTS_UIMAPID%d", UiMapId) end,
        -- REMOVE_ALL_WAYPOINTS_AVAILABLE = "MAP-REMOVE_ALL_WAYPOINTS_AVAILABLE",
        -- AVAILABLE_WAYPOINTS_DRAWN = "MAP-AVAILABLE_WAYPOINTS_DRAWN",

        --Available Events
        REMOVE_ALL_AVAILABLE = "MAP-REMOVE_ALL_AVAILABLE",
        REMOVE_ALL_COMPLETED = "MAP-REMOVE_ALL_COMPLETED",

        REMOVE_ALL_RELATIONS = "MAP-REMOVE_ALL_RELATIONS",
        AVAILABLE_QUESTS_DRAWN = "MAP-AVAILABLE_QUESTS_DRAWN",
    },
    TOOLTIP = {
        ---comment
        ---@param id NpcId|ObjectId|ItemId
        ---@param type RelationPointType
        ---@return string
        ADD_AVAILABLE_TOOLTIP = function(id, type) return string.format("TOOLTIP-ADD_AVAILABLE_TOOLTIP_%d_%s", id, type) end,
        RESET_TOOLTIP = "TOOLTIP-RESET_TOOLTIP",
        DRAW_TOOLTIP = "TOOLTIP-DRAW_TOOLTIP",
    }
}
--MapEventBus:Fire("QUEST-GET-AVAILABLE-NPCS")
MapEventBus.quickFire = {
    ---comment
    ---@param questId QuestId
    QUEST_ACCEPTED = function(questId) MapEventBus:Fire(MapEventBus.events.QUEST_ACCEPTED, questId) end,
    ---comment
    ---@param questId QuestId
    QUEST_ABANDONED = function(questId) MapEventBus:Fire(MapEventBus.events.QUEST_ABANDONED, questId) end,
    ---comment
    ---@param questId QuestId
    QUEST_COMPLETED = function(questId) MapEventBus:Fire(MapEventBus.events.QUEST_COMPLETED, questId) end,
    -- MAP = {
    --     DRAW_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_UIMAPID_%d", UiMapId) end,
    --     REMOVE_QUEST = "MAP-REMOVE_QUEST", --Return questId, catch-all remove pins


    --     DRAW_WAYPOINTS_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_WAYPOINTS_UIMAPID%d", UiMapId) end,
    --     REMOVE_ALL_WAYPOINTS_AVAILABLE = "MAP-REMOVE_ALL_WAYPOINTS_AVAILABLE",
    --     AVAILABLE_WAYPOINTS_DRAWN = "MAP-AVAILABLE_WAYPOINTS_DRAWN",

    --     --Available Events
    --     REMOVE_ALL_AVAILABLE = "MAP-REMOVE_ALL_AVAILABLE",
    --     AVAILABLE_QUESTS_DRAWN = "MAP-AVAILABLE_QUESTS_DRAWN",
    -- }
}
