---@class MessageHandler
---@field RegisterCallback fun(self:any, eventName:string, method:fun(), args:...)
---@field UnregisterCallback fun(self:any, eventName:string)
---@field UnregisterAllCallbacks fun(self:table|string) @Maybe self:any works...
local MessageHandler = QuestieLoader:CreateModule("MessageHandler")

--@type MessageHandler
--local MessageHandler = QuestieLoader:ImportModule("MessageHandler")

---@class Callbacks
---@field Fire fun(eventName:string, args:...)
MessageHandler.callback = LibStub("CallbackHandler-1.0"):New(MessageHandler)

---Once Message, use sparingly
---@param eventname string
---@param method function
function MessageHandler.RegisterOnceCallback(eventname, method)
    print("Registering once message", eventname)
    local msg = {}
    MessageHandler.RegisterCallback(msg, eventname,
    function()
        C_Timer.After(0, function()
            method()
        end)
        MessageHandler.UnregisterCallback(msg, eventname)
    end)
end

function MessageHandler.callback:OnUsed(target, eventname) 
    --print("Someone just registered for "..eventname.."!")
end

function MessageHandler.callback:OnUnused(target, eventname)
    --print("Noone wants "..eventname.." any more")
end

MessageHandler.events = {
    BOOT = {
        PRE = "BOOT-PRE_LOAD",
        START = "BOOT-BOOT_START",
        DONE = "BOOT-BOOT_DONE"
    },
    DB = {
        DB_INITIALIZED = "DB-DB_INITIALIZED",
        CORRECTIONS_INITIALIZED = "DB-CORRECTIONS_INITIALIZED"
    },
    COMPILER = {
        PRE_COMPILE_DONE = "COMPILER-PRE_COMPILE_DONE",
        DB_COMPILE_DONE = "COMPILER-DB_COMPILE_DONE"
    },
    COMPARE = {
        ---Becomes a generic catch-all message with no parameters
        ---@param questId QuestId @OPTIONAL: The questid
        ---@param key string @OPTIONAL: Any key, example ObjectiveIndex, SRcItem
        ---@return string @Messaging string
        ---SendMessage, return questId, key and data
        --QUEST_UPDATED = function(questId, key)
        --    --Return message for registering
        --    if(questId and key) then return sformat("COMPARE-QUEST_UPDATED_ID_%d_KEY_%d", questId, key)
        --    else return "COMPARE-QUEST_UPDATED" end
        --end,
        QUEST_ACCEPTED = "COMPARE-QUEST_ACCEPTED", --Return questLogIndex, questId(optional)
        QUEST_REMOVED = "COMPARE-QUEST_REMOVED", --Return questLogIndex, questId(optional)
        ---Becomes a generic catch-all message with no parameters
        ---@param questId QuestId @OPTIONAL: The questid
        ---@return string @Messaging string
        ---SendMessage, return questId
        --COMPLETE = function(questId)
        --    --Return message for registering
        --    if(questId) then return sformat("COMPARE-QUEST_COMPLETE_%d", questId)
        --    else return "COMPARE-QUEST_COMPLETE" end
        --end,
        QUEST_LOG_UPDATE = "COMPARE-QUEST_LOG_UPDATE",
        QUEST_DATA_FETCHED = "COMPARE-QUEST_DATA_FETCHED",     
    },
    BLIZZARD = {
        QUEST_ACCEPTED = "BLIZZARD-QUEST_ACCEPTED", --Return questLogIndex, questId(optional)
        QUEST_REMOVED = "BLIZZARD-QUEST_REMOVED", --Return questId
        QUEST_TURNED_IN = "BLIZZARD-QUEST_TURNED_IN", --Return questId
        QUEST_LOG_UPDATE = "BLIZZARD-QUEST_LOG_UPDATE",
    },
    QUEST = { --Just subscribe to one of these messages sending is handled in the backend
        --Quest messages
        UPDATED = "QUEST-QUEST_UPDATED", --Return questId, key(ex ObjectiveIndex)
        LOADED = "QUEST-QUEST_LOADED", --Return questId @When a quest is loaded for the first time
        ACCEPTED = "QUEST-QUEST_ACCEPTED", --Return questId, questLogIndex
        COMPLETE = "QUEST-QUEST_COMPLETE", --Return questId
        FAILED = "QUEST-QUEST_FAILED", --Return questId
        TURNED_IN = "QUEST-QUEST_TURNED_IN", --Return questId
        ABANDONED = "QUEST-QUEST_ABANDONED", --Return questId
        REMOVED = "QUEST-QUEST_REMOVED", --Return questId --NYI

        --Available messages
        AVAILABLE_QUESTS_CALCULATED = "QUEST-AVAILABLE_QUESTS_CALCULATED", --Return data from Quest:CalculateAvailableQuests
        AVAILABLE_QUEST_REMOVED = "QUEST-AVAILABLE_QUEST_REMOVED", --return questId

        --Meta messages
        INITIALIZED = "QUEST-INITIALIZED",
        GET_ALL_QUEST_IDS = "QUEST-GET_ALL_QUEST_IDS",
        GET_ALL_QUEST_IDS_NO_OBJECTIVES = "QUEST-GET_ALL_QUEST_IDS_NO_OBJECTIVES",
        AVAILABLE_QUESTS_DRAWN = "QUEST-AVAILABLE_QUESTS_DRAWN",
        QUEST_LOG_UPDATE = "QUEST-QUEST_LOG_UPDATE",
        PRE_FETCH_QUEST_DATA = "QUEST-PRE_FETCH_QUEST_DATA"
    },
    MAP = {
        REMOVE_QUEST = "MAP-REMOVE_QUEST", --Return questId, catch-all remove pins
    },
    TRACKER = {
        INITIALIZED = "TRACKER-TRACKER_INITIALIZED",
    },
}