---@class MessageHandlerFactory
local MessageHandlerFactory = setmetatable(QuestieLoader:CreateModule("MessageHandlerFactory"),
                                           { __call = function(MessageBusName) return self.New(MessageBusName) end })

---@alias EventString string
---@alias Callback fun(...:any):any

-- These are more for readabilty rather than type safety

-- SimpleEvent is a string in bus.events but a function bus.FireEvent
---@alias SimpleEvent EventString
-- ParameterEvent is a string in bus.events but a function bus.FireEvent
---@alias ParameterEvent EventString
-- FormatEvent is a table or function in bus.events but a function bus.FireEvent (has to be manually defined)
---@alias FormatEvent table|function


--- Localize functions
local yield = coroutine.yield
local insert, remove = table.insert, table.remove
local format = string.format
local safePack = SafePack
local wipe = wipe
local debugstack = debugstack

C_Timer.After(0, function()
    SlashCmdList["EVENTTRACE"]()
end)

---comment
---@param event string
---@param displayEvent string
---@param displayMessage string
---@param prePendString string? @optional
---@param ... any
local function LogEvent(event, displayEvent, displayMessage, prePendString, ...)
    -- Prepend string to event
    event = prePendString and "_"..event or event
    if EventTrace and EventTrace:CanLogEvent(event) then
        local elementData = {
            event = event,
            args = safePack(...),
            displayEvent = displayEvent,
            displayMessage = displayMessage,
        }
        EventTrace:LogLine(elementData);
    end
end

---Print to EventTrace
---@param message string
---@param ... any
---@diagnostic disable-next-line: lowercase-global -- We want this to be global and lowercase like print
printE = function(message, ...)
    ---@type string
    local d = debugstack(2, 1, 1) --[[@as string]] -- For some reason the VSCode ext doesn't show that this returns a string

    --? Get the lua filename and code line number
    local fileName, lineNr = d:match('(%w+%.lua)%"%]:(%d+)')
    if not fileName or not lineNr then
        -- The depth was too low
        d = debugstack(1, 1, 1) --[[@as string]]
        fileName, lineNr = d:match('(%w+%.lua)%"%]:(%d+)')
    end
    if fileName and lineNr and type(message) == "string" then
        -- Add a _ to sort better in the EventLog
        LogEvent(fileName, format("%s:%s", fileName, lineNr), format("%s:%s %s", fileName, lineNr, message), "_", ...)
    end
end

--? Used by the CreateFormaterEvent function
--? This metatable is used for events that have parameters
--? __call is used when an event has more than 1 parameter
--? __index is used when an event has only 1 parameter
local eventFormatMetaTable = {
    --? This is used when you have 2 or more parameters that are used in the format string
    ---@param self {event: string, formatEvent: string, parameters: string[]}
    ---@param firstParam any
    ---@param ... any
    ---@return string
    __call = function(self, firstParam, ...)
        if firstParam then
            if #self.parameters > 1 then
                return format(self.formatEvent, ...)
            else
                error("Only one parameter, Instead use it as a table eg. events.DRAW_RELATION_UIMAPID[UiMapId]", 2)
            end
        else
            error("Do not call this function without parameters!", 2)
        end
        -- if firstParam then
        --     --? Only cache when it only requires one paramater
        --     if not self.cache and #self.parameters == 1 then
        --         self.cache = {}
        --     end

        --     --? If the cache is set, use it
        --     if self.cache[firstParam] then
        --         return self.cache[firstParam]
        --     elseif self.cache then
        --         --? Cache exists but the value is missing
        --         self.cache[firstParam] = format(self.formatEvent, firstParam)
        --         return self.cache[firstParam]
        --     else
        --         --? No cache exists
        --         return format(self.formatEvent, firstParam, ...)
        --     end
        -- end
    end,
    --? This is used when you have 1 parameter that is used in the format string
    ---@param self {event: string, formatEvent: string, parameters: string[]}
    ---@param firstParam any
    __index = function(self, firstParam)
        if firstParam and #self.parameters == 1 then
            self[firstParam] = format(self.formatEvent, firstParam)
            return self[firstParam]
        else
            return nil
        end
    end,
}

--- Creates a new MessageHandler
---@param MessageBusName string @The name of the message bus, used in eventtrace
---@return MessageHandler
function MessageHandlerFactory.New(MessageBusName)
    ---@class MessageHandler
    local handler = {}

    --- Contains all the events that are fired repeatably
    ---@type table<EventString,Callback[]>
    local repeatEvents = {}

    --- Contains all the events that are fired once
    ---@type table<EventString,Callback[]>
    local onceEvents = {}

    -- Used when asyncronously calling events
    ---@type table<EventString, boolean>
    local executing = {}

    ---@type table<EventString, table<table, Callback>>
    local objects = {}

    ---A helper function to create the table with meta functions for format events
    ---@param eventName EventString
    ---@param formatEvent string
    ---@param parameters string[]
    ---@return any|table|function -- The return is a little weird to support forcing the type of the return to either a function or a table
    function handler.CreateFormaterEvent(eventName, formatEvent, parameters)
        if not eventName or type(eventName) ~= "string" then
            error("Event must be a string!", 2)
        end
        if not formatEvent or type(formatEvent) ~= "string" then
            error("FormatEvent must be a string!", 2)
        end
        if not parameters or type(parameters) ~= "table" or #parameters == 0 then
            error("Parameterized events must have parameters", 2)
        end
        local formattedEvent = { event = eventName, formatEvent = formatEvent, parameters = parameters }
        setmetatable(formattedEvent, eventFormatMetaTable)
        return formattedEvent
    end

    --- The local function for both Async and Sync callbacks
    ---@param eventName EventString
    ---@param asyncCount number? @How many events to fire per yield
    ---@param ... any @Input arguments for the callback
    ---@return table? @Returns a table of all the return values from the callbacks
    local function fire(eventName, asyncCount, ...)
        print("Event Fired", eventName)
        if Questie.db.global.debugEnabled then
            -- Add a ! to sort better in the EventLog
            LogEvent(eventName, format("%s: %s", MessageBusName, eventName), format("%s: %s", MessageBusName, eventName), "!", ...)
        end
        if executing[eventName] then
            error("Event '" .. eventName .. "' is already being executed! Did previous call crash?", 2)
        end

        executing[eventName] = true

        --* Fire once tables
        if onceEvents[eventName] then
            local eventList = onceEvents[eventName]
            for callbackIndex = 1, #eventList do
                -- Function call
                eventList[callbackIndex](...)
            end
            wipe(eventList)
        end

        --* Fire repeat tables
        local returnValues = nil
        if repeatEvents[eventName] then
            local eventList = repeatEvents[eventName]
            for callbackIndex = 1, #eventList do
                -- Function call
                local retValue = eventList[callbackIndex](...)

                -- If we have a return value we save it to the return table
                if retValue then
                    if not returnValues then returnValues = {} end
                    returnValues[#returnValues + 1] = retValue
                end

                --If we are a async function we yield after each asyncCount
                if asyncCount and callbackIndex % asyncCount == 0 then
                    yield()
                end
            end
        end

        --* Fire object tables
        if objects[eventName] then
            local count = 0
            for object, callback in pairs(objects[eventName]) do
                -- Function call
                local retValue = callback(object, ...)

                -- If we have a return value we save it to the return table
                if retValue then
                    if not returnValues then returnValues = {} end
                    returnValues[#returnValues + 1] = retValue
                end

                --If we are a async function we yield after each asyncCount
                if asyncCount and count % asyncCount == 0 then
                    yield()
                end
                count = count + 1
            end
        end
        executing[eventName] = nil

        return returnValues
    end

    --- Fire a callback event
    --- NOTE: It is up to you to match the number of parameters for the event you fire
    ---@param eventName EventString
    ---@param ... any @Input arguments for the callback
    ---@return table? @A table containing all the return values
    function handler:Fire(eventName, ...)
        return fire(eventName, nil, ...)
    end

    --- Fire a async callback event which invokes coroutine yield
    --- NOTE: It is up to you to match the number of parameters for the event you fire
    ---@param eventName EventString
    ---@param asyncCount number? @How many events to fire per yield
    ---@param ... any @Input arguments for the callback
    ---@return table? @A table containing all the return values
    function handler:FireAsync(eventName, asyncCount, ...)
        local returnValues = fire(eventName, asyncCount, ...)
        --? We call yield here returning the value to the calling resume, makes it take one more resume to finish
        yield(returnValues)
        return returnValues
    end

    ---Register a callback
    ---@param eventName EventString
    ---@param callback Callback
    function handler:RegisterRepeating(eventName, callback)
        if not callback or type(callback) ~= "function" then
            error("Usage: Register(eventName, callback): 'callback' - function expected.", 2)
        elseif not eventName or type(eventName) ~= "string" then
            error("Usage: Register(eventName, callback): 'eventName' - a string expected.", 2)
        end
        if not repeatEvents[eventName] then
            repeatEvents[eventName] = {}
        end
        insert(repeatEvents[eventName], callback)
    end

    ---Register a callback on an object, each callback is unique and registering a new one will overwrite it.
    ---The callbacks first parameter will aways be the object itself
    ---@param object table @The object that is registering the event
    ---@param eventName EventString
    ---@param callback Callback
    function handler:ObjectRegisterRepeating(object, eventName, callback)
        if not callback or type(callback) ~= "function" then
            error("Usage: ObjectRegisterRepeating(object, eventName, callback): 'callback' - function expected.", 2)
        elseif not eventName or type(eventName) ~= "string" then
            error("Usage: ObjectRegisterRepeating(object, eventName, callback): 'eventName' - a string expected.", 2)
        elseif not object or type(object) ~= "table" then
            error("Usage: ObjectRegisterRepeating(object, eventName, callback): 'object' - a table expected.", 2)
        end
        objects[eventName] = objects[eventName] or {}
        objects[eventName][object] = callback
    end

    --- Register a callback that will only be called once
    ---@param eventName EventString
    ---@param callback Callback
    function handler:RegisterOnce(eventName, callback)
        if not callback or type(callback) ~= "function" then
            error("Usage: RegisterOnce(eventName, callback): 'callback' - function expected.", 2)
        elseif not eventName or type(eventName) ~= "string" then
            error("Usage: RegisterOnce(eventName, callback): 'eventName' - a string expected.", 2)
        end
        if not onceEvents[eventName] then
            onceEvents[eventName] = {}
        end
        insert(onceEvents[eventName], callback)
    end

    ---Unregister a callback by function
    ---@param eventName EventString
    ---@param callback Callback
    function handler:UnregisterRepeating(eventName, callback)
        if not callback or type(callback) ~= "function" then
            error("Usage: Unregister(eventName, callback): 'callback' - function expected.", 2)
        elseif not eventName or type(eventName) ~= "string" then
            error("Usage: Unregister(eventName, callback): 'eventName' - a string expected.", 2)
        end
        local eventList = repeatEvents[eventName]
        if eventList then
            for callbackIndex = 1, #eventList do
                if eventList[callbackIndex] == callback then
                    remove(repeatEvents[eventName], callbackIndex)
                    return
                end
            end
        end
    end

    ---Unregister a callback by object
    ---@param object table
    ---@param eventName EventString
    function handler:ObjectUnregisterRepeating(object, eventName)
        if not eventName or type(eventName) ~= "string" then
            error("Usage: ObjectUnregisterRepeating(object, eventName, callback): 'eventName' - a string expected.", 2)
        elseif not object or type(object) ~= "table" then
            error("Usage: ObjectUnregisterRepeating(object, eventName, callback): 'object' - a table expected.", 2)
        end
        if objects[eventName] and objects[eventName][object] then
            objects[eventName][object] = nil
        end
    end

    ---Unregister all callbacks by object
    ---@param object table
    function handler:ObjectUnregisterAll(object)
        if not object or type(object) ~= "table" then
            error("Usage: ObjectUnregisterRepeating(object, eventName, callback): 'object' - a table expected.", 2)
        end
        for _, objectList in pairs(objects) do
            if objectList[object] then
                objectList[object] = nil
            end
        end
    end

    ---Unregisters all events for a given event name in repeat, once-lists and object-lists
    ---@param eventName EventString
    function handler:UnregisterAll(eventName)
        if not eventName or type(eventName) ~= "string" then
            error("Usage: UnregisterAll(eventName): 'eventName' - a string expected.", 2)
        end
        if repeatEvents[eventName] then
            wipe(repeatEvents[eventName])
        end
        if onceEvents[eventName] then
            wipe(onceEvents[eventName])
        end
        if objects[eventName] then
            wipe(objects[eventName])
        end
    end

    return handler
end

----- Tests -----
do
    --? This is the tests for MessageHandlerFactory
    local function RunMessageHandlerTests()
        Questie:Debug(Questie.DEBUG_CRITICAL, " -- Running " .. Questie:Colorize("MessageHandlerFactory", "yellow") .. " tests --")
        local testEvent = "EVENT_TEST"

        --- Test simple usage
        do
            local MessageHandler = MessageHandlerFactory.New("TestBus1")
            local returnedCount = 0

            local incrementFunction = function()
                returnedCount = returnedCount + 1
            end

            -- Add and fire
            MessageHandler:RegisterRepeating(testEvent, incrementFunction)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 1, Questie:Colorize(" -- FAILED: Event was not fired", "red"))

            -- Unregister and fire
            MessageHandler:UnregisterRepeating(testEvent, incrementFunction)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 1, Questie:Colorize(" -- FAILED: Event was fired after unregistering", "red"))

            -- Register two events and fire
            MessageHandler:RegisterRepeating(testEvent, incrementFunction)
            MessageHandler:RegisterRepeating(testEvent, incrementFunction)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 3, Questie:Colorize(" -- FAILED: Event was not fired twice", "red"))

            -- Unregister all events and fire
            MessageHandler:UnregisterAll(testEvent)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 3, Questie:Colorize(" -- FAILED: Event was fired after unregistering all", "red"))

            -- Register once and fire
            MessageHandler:RegisterOnce(testEvent, incrementFunction)
            MessageHandler:Fire(testEvent)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 4, Questie:Colorize(" -- FAILED: Event was not fired once", "red"))
        end

        --- Test multiple registered events
        do
            local MessageHandler = MessageHandlerFactory.New("TestBus2")
            local returnedCount = 0
            local incrementFunction = function()
                returnedCount = returnedCount + 1
            end
            local incrementFunction2 = function()
                returnedCount = returnedCount + 1
            end

            local testEvent2 = "EVENT_TEST2"

            MessageHandler:RegisterRepeating(testEvent, incrementFunction)
            MessageHandler:RegisterRepeating(testEvent2, incrementFunction2)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 1, Questie:Colorize(" -- FAILED: Event 1 was not fired", "red"))
            MessageHandler:Fire(testEvent2)
            assert(returnedCount == 2, Questie:Colorize(" -- FAILED: Event 2 was not fired", "red"))

            -- Unregister and fire
            MessageHandler:UnregisterRepeating(testEvent, incrementFunction)
            MessageHandler:Fire(testEvent)
            assert(returnedCount == 2, Questie:Colorize(" -- FAILED: Event 1 was fired after unregistering", "red"))
            MessageHandler:Fire(testEvent2)
            assert(returnedCount == 3, Questie:Colorize(" -- FAILED: Event 2 was not fired", "red"))
            MessageHandler:UnregisterRepeating(testEvent2, incrementFunction2)
            MessageHandler:Fire(testEvent2)
            assert(returnedCount == 3, Questie:Colorize(" -- FAILED: Event 2 was fired after unregistering", "red"))
        end

        --- Test return
        do
            local MessageHandler          = MessageHandlerFactory.New("TestBus3")
            local returnedCount           = 0
            local incrementReturnFunction = function()
                returnedCount = returnedCount + 1
                return returnedCount
            end

            -- Register mutliple events and fire
            for _ = 1, 5 do
                MessageHandler:RegisterRepeating(testEvent, incrementReturnFunction)
            end
            local retVal = MessageHandler:Fire(testEvent)
            assert(retVal, Questie:Colorize(" -- FAILED: Return value was nil", "red"))
            assert(retVal[1] == 1, Questie:Colorize(" -- FAILED: 1 Function value was not returned", "red"))
            assert(retVal[2] == 2, Questie:Colorize(" -- FAILED: 2 Function value was not returned", "red"))
            assert(retVal[3] == 3, Questie:Colorize(" -- FAILED: 3 Function value was not returned", "red"))
            assert(retVal[4] == 4, Questie:Colorize(" -- FAILED: 4 Function value was not returned", "red"))
            assert(retVal[5] == 5, Questie:Colorize(" -- FAILED: 5 Function value was not returned", "red"))
        end

        --- Test async and async return
        do
            local MessageHandler = MessageHandlerFactory.New("TestBus4")
            local returnedCount = 0

            local incrementReturnFunction = function()
                returnedCount = returnedCount + 1
                return returnedCount
            end

            -- Register mutliple events and fire
            for _ = 1, 5 do
                MessageHandler:RegisterRepeating(testEvent, incrementReturnFunction)
            end

            local routine = coroutine.create(
            function()
                MessageHandler:FireAsync(testEvent, 2)
                assert(returnedCount == 5, Questie:Colorize(" -- FAILED: Event was not fired the correct amount of times", "red"))
            end
            )
            local timer
            timer = C_Timer.NewTicker(0, function()
                local success, retVal = coroutine.resume(routine)
                if retVal then
                    assert(retVal[1] == 1, Questie:Colorize(" -- FAILED: 1 Function value was not returned", "red"))
                    assert(retVal[2] == 2, Questie:Colorize(" -- FAILED: 2 Function value was not returned", "red"))
                    assert(retVal[3] == 3, Questie:Colorize(" -- FAILED: 3 Function value was not returned", "red"))
                    assert(retVal[4] == 4, Questie:Colorize(" -- FAILED: 4 Function value was not returned", "red"))
                    assert(retVal[5] == 5, Questie:Colorize(" -- FAILED: 5 Function value was not returned", "red"))
                end
                assert(success, Questie:Colorize(" -- FAILED: Coroutine failed", "red"), retVal)

                -- Kill the timer when the coroutine is dead.
                if (coroutine.status(routine) == "dead") then
                    Questie:Debug(Questie.DEBUG_CRITICAL, "- MessageHandlerFactory - |cFF00FF00SUCCESS!|r")
                    timer:Cancel()
                end
            end)
        end
    end

    -- Run it after all files has been loaded
    C_Timer.After(2, RunMessageHandlerTests)

end
-----------------
