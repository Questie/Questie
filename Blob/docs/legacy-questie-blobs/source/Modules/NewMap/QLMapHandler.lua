---@class QLMapHandler
---@field RegisterCallback fun(self:table|string, eventName:string, method:fun(), args:...)
---@field UnregisterCallback fun(self:table|string, eventName:string)
---@field UnregisterAllCallbacks fun(self:table|string) @Maybe self:any works...
local MapHandler = QuestieLoader:CreateModule("MapHandler")

---@type Callbacks
-----@field Fire fun(eventName:string, args:...)
MapHandler.callback = LibStub("CallbackHandler-1.0"):New(MapHandler)

function MapHandler.callback:OnUsed(target, eventname) 
    --print("MapHandler registered "..eventname)
end

function MapHandler.callback:OnUnused(target, eventname)
     --print("MapHandler unregistered "..eventname)
end

MapHandler.events = {
    MAP = {
        DRAW_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_UIMAPID_%d", UiMapId) end,
        REMOVE_QUEST = "MAP-REMOVE_QUEST", --Return questId, catch-all remove pins


        DRAW_WAYPOINTS_UIMAPID = function(UiMapId) return string.format("MAP-DRAW_WAYPOINTS_UIMAPID%d", UiMapId) end,
        REMOVE_ALL_WAYPOINTS_AVAILABLE = "MAP-REMOVE_ALL_WAYPOINTS_AVAILABLE",
        AVAILABLE_WAYPOINTS_DRAWN = "MAP-AVAILABLE_WAYPOINTS_DRAWN",

        --Available Events
        REMOVE_ALL_AVAILABLE = "MAP-REMOVE_ALL_AVAILABLE",
        AVAILABLE_QUESTS_DRAWN = "MAP-AVAILABLE_QUESTS_DRAWN",
    }
}