---@class QuestEventBus : MessageHandler
local QuestEventBus = QuestieLoader:CreateModule("QuestEventBus")

local MessageHandlerFactory = QuestieLoader:ImportModule("MessageHandlerFactory")

QuestEventBus = Mixin(QuestEventBus, MessageHandlerFactory.New("QuestEventBus")) --[[@as QuestEventBus]]


QuestEventBus.events = {
    QUEST_ACCEPTED = "QUEST-ACCEPTED",
    QUEST_ABANDONED = "QUEST-ABANDONED",
    QUEST_COMPLETED = "QUEST-COMPLETED",

    CALCULATED_AVAILABLE_QUESTS = "CALCULATED-AVAILABLE-QUESTS",
    CALCULATED_COMPLETED_QUESTS = "CALCULATED-COMPLETED-QUESTS",
}
--QuestEventBus:Fire("QUEST-GET-AVAILABLE-NPCS")
QuestEventBus.quickFire = {
    ---comment
    ---@param questId QuestId
    QUEST_ACCEPTED = function(questId) QuestEventBus:Fire(QuestEventBus.events.QUEST_ACCEPTED, questId) end,
    ---comment
    ---@param questId QuestId
    QUEST_ABANDONED = function(questId) QuestEventBus:Fire(QuestEventBus.events.QUEST_ABANDONED, questId) end,
    ---comment
    ---@param questId QuestId
    QUEST_COMPLETED = function(questId) QuestEventBus:Fire(QuestEventBus.events.QUEST_COMPLETED, questId) end,
    ---comment
    ---@param ShowData Show
    CALCULATED_AVAILABLE_QUESTS = function(ShowData) QuestEventBus:Fire(QuestEventBus.events.CALCULATED_AVAILABLE_QUESTS, ShowData) end,
    ---@param ShowData Show
    CALCULATED_COMPLETED_QUESTS = function(ShowData) QuestEventBus:Fire(QuestEventBus.events.CALCULATED_COMPLETED_QUESTS, ShowData) end,
    -- MAP = {
    --     DRAW_RELATION_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_RELATION_UIMAPID_%d", UiMapId) end,
    --     REMOVE_QUEST = "MAP-REMOVE_QUEST", --Return questId, catch-all remove pins


    --     DRAW_WAYPOINTS_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_WAYPOINTS_UIMAPID%d", UiMapId) end,
    --     REMOVE_ALL_WAYPOINTS_AVAILABLE = "MAP-REMOVE_ALL_WAYPOINTS_AVAILABLE",
    --     AVAILABLE_WAYPOINTS_DRAWN = "MAP-AVAILABLE_WAYPOINTS_DRAWN",

    --     --Available Events
    --     REMOVE_ALL_AVAILABLE = "MAP-REMOVE_ALL_AVAILABLE",
    --     AVAILABLE_QUESTS_DRAWN = "MAP-AVAILABLE_QUESTS_DRAWN",
    -- }
}
