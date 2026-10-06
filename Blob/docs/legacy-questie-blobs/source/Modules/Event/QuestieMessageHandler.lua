---@class QuestieMessage
local QuestieMessage = QuestieLoader:CreateModule("QuestieMessage")

-----@type QuestieMessage
--local QuestieMessage = QuestieLoader:ImportModule("QuestieMessage")
local sformat = string.format
QuestieMessage.MESSAGES = {
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
        QUEST_UPDATED = function(questId, key)
            --Return message for registering
            if(questId and key) then return sformat("COMPARE-QUEST_UPDATED_ID_%d_KEY_%d", questId, key)
            else return "COMPARE-QUEST_UPDATED" end
        end,
        QUEST_ACCEPTED = "COMPARE-QUEST_ACCEPTED", --Return questLogIndex, questId(optional)
        QUEST_REMOVED = "COMPARE-QUEST_REMOVED", --Return questLogIndex, questId(optional)
        ---Becomes a generic catch-all message with no parameters
        ---@param questId QuestId @OPTIONAL: The questid
        ---@return string @Messaging string
        ---SendMessage, return questId
        COMPLETE = function(questId)
            --Return message for registering
            if(questId) then return sformat("COMPARE-QUEST_COMPLETE_%d", questId)
            else return "COMPARE-QUEST_COMPLETE" end
        end,
        QUEST_LOG_UPDATE = "COMPARE-QUEST_LOG_UPDATE",
        QUEST_DATA_FETCHED = "COMPARE-QUEST_DATA_FETCHED",     
    },
    QUEST = {
        --Quest messages
        UPDATED = "QUEST-QUEST_UPDATED", --Return questId
        LOADED = "QUEST-QUEST_LOADED", --Return questId @When a quest is loaded for the first time
        ACCEPTED = "QUEST-QUEST_ACCEPTED", --Return questId, questLogIndex
        COMPLETE = "QUEST-QUEST_COMPLETE", --Return questId
        ABANDONED = "QUEST-QUEST_ABANDONED", --Return questId
        REMOVED = "QUEST-QUEST_REMOVED", --Return questId

        --Available messages
        AVAILABLE_QUESTS_CALCULATED = "QUEST-AVAILABLE_QUESTS_CALCULATED", --Return data from Quest:CalculateAvailableQuests
        AVAILABLE_QUEST_REMOVED = "QUEST-AVAILABLE_QUEST_REMOVED",

        --Meta messages
        INITIALIZED = "QUEST-INITIALIZED",
        GET_ALL_QUEST_IDS = "QUEST-GET_ALL_QUEST_IDS",
        GET_ALL_QUEST_IDS_NO_OBJECTIVES = "QUEST-GET_ALL_QUEST_IDS_NO_OBJECTIVES",
        AVAILABLE_QUESTS_DRAWN = "QUEST-AVAILABLE_QUESTS_DRAWN",
        QUEST_LOG_UPDATE = "QUEST-QUEST_LOG_UPDATE",
        PRE_FETCH_QUEST_DATA = "QUEST-PRE_FETCH_QUEST_DATA"
    },
    MAP = {
        --When the cache is done with the points
        POLYGON_CACHE_DONE_ = "MAP-POLYGON_CACHE_DONE_", --Add QuestId.."_"..ObjectiveId i.e "POLYGON_CACHE_DONE_..questId.."_"..objectiveId", payload: UiMapId
        --When the cache knows the UiMapIds for the Quest and Objective
        POLYGON_CACHE_UIMAPIDS_ = "MAP-POLYGON_CACHE_UIMAPIDS_", --Add QuestId.."_"..ObjectiveId i.e "POLYGON_CACHE_UIMAPIDS_..questId.."_"..objectiveId", payload: {UiMapIds,}
    },
    TRACKER = {
        INITIALIZED = "TRACKER-TRACKER_INITIALIZED",
    },
    HASH = {
        FAILED = "HASH-FAILED",

    },
    PROFILER = {
        SHOW = "PROFILER-SHOW"
    }
}

local QuestieFunctions = {}
local function _registerMessage(eventname, method, ref, once) --, ...
    if not QuestieFunctions[eventname] then
        QuestieFunctions[eventname] = {}
    end
    --Either save it as a function or as a reference (to be able to remove)
    local key = ref or method
    if(not QuestieFunctions[eventname][key]) then
        QuestieFunctions[eventname][key] = {}
        QuestieFunctions[eventname][key].func = method
        QuestieFunctions[eventname][key].once = once
        QuestieFunctions[eventname][key].ref = ref or nil
    else
        print("WARNING FUNCTION + REF IS ALREADY REGISTERED!!!")
        print(eventname, method, ref, once)
    end
end

function QuestieMessage:RegisterRepeatingMessage(eventname, method) --, ...
    print("Registering repeating function:", eventname)
    _registerMessage(eventname, method, nil, false) --, ...
end

---NOT TESTED!!!!!!!!!!!!!!!   A way to register a message using a reference, for unregistering
---@param eventname string @Event message string
---@param ref any @A reference to be able to unregister, Suggestion: An object of some kind
---@param method function
function QuestieMessage:RegisterReferencedRepeatingMessage(eventname, ref, method) --, ...
    print("Registering repeating function:", eventname)
    _registerMessage(eventname, method, ref, false) --, ...
end

function QuestieMessage:RegisterOnceMessage(eventname, method) --, ...
    print("Registering once function:", eventname)
    _registerMessage(eventname, method, nil, true) --, ...
end

---NOT TESTED!!!!!!!!!!!!!!!
---@param eventname string @event message name
---@param ref any @A reference to a registered message, could be a function or table or whatever really...
function QuestieMessage:UnregisterMessage(eventname, ref)
    if(QuestieFunctions[eventname] and QuestieFunctions[eventname][ref]) then
        print("Unregistering ", eventname, " with reference ", ref)
        QuestieFunctions[eventname][ref] = nil;
    end
end

function QuestieMessage:SendMessage(eventname, ...)
    if(QuestieFunctions[eventname]) then
        local args = {...};
        if(select("#", ...) > 0) then
            print("Sending event:", eventname, "packet:", unpack(args))
        else
            print("Sending event:", eventname)
        end
        local repeating = false
        for _, func in pairs(QuestieFunctions[eventname] or {}) do
            --We spawn a timer to allow other stuff to run between
            C_Timer.After(0, function()
                --print(unpack(args))
                func.func(self, unpack(args))
                if(func.once) then
                    --print(QuestieFunctions[eventname][func.func])
                    if(QuestieFunctions[eventname] and QuestieFunctions[eventname][func.func]) then
                        QuestieFunctions[eventname][func.func] = nil;
                    
                        --NOT TESTED!!!!!!!!!!!!!!!!!
                    elseif(func.ref and QuestieFunctions[eventname] and QuestieFunctions[eventname][func.ref]) then
                        QuestieFunctions[eventname][func.ref] = nil;
                    end
                -- print(QuestieFunctions[eventname][func.func])
                end
            end)
            if(not func.once) then
                repeating = true
            end
        end
        --To keep the QuestieFunctions list clean, we remove it if there are no repeating ones left
        --because they should have all fired already
        if(not repeating) then
            QuestieFunctions[eventname] = nil
        end
    end
end