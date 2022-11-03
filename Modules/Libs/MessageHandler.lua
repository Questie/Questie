---@class MessageHandlerFactory
local MessageHandlerFactory = setmetatable(QuestieLoader:CreateModule("MessageHandlerFactory"),
                                           { __call = function(MessageBusName) return self.New(MessageBusName) end })

---@alias Event string
---@alias Callback fun(...:any):any


--- Localize functions
local yield = coroutine.yield
local insert, remove = table.insert, table.remove
local format = string.format
local safePack = SafePack
local wipe = wipe

--- Creates a new MessageHandler
---@param MessageBusName string @The name of the message bus, used in eventtrace
---@return MessageHandler
function MessageHandlerFactory.New(MessageBusName)
    ---@class MessageHandler
    local handler = {}

    --- Contains all the events that are fired repeatably
    ---@type table<Event,Callback[]>
    local repeatEvents = {}

    --- Contains all the events that are fired once
    ---@type table<Event,Callback[]>
    local onceEvents = {}

    -- Used when asyncronously calling events
    ---@type table<Event, boolean>
    local executing = {}

    ---@type table<Event, table<table, Callback>>
    local objects = {}

    --- The local function for both Async and Sync callbacks
    ---@param eventName Event
    ---@param asyncCount number? @How many events to fire per yield
    ---@param ... any @Input arguments for the callback
    ---@return table? @Returns a table of all the return values from the callbacks
    local function fire(eventName, asyncCount, ...)
        print("Event Fired", eventName)
        if Questie.db.global.debugEnabled then
            if EventTrace and EventTrace:CanLogEvent(eventName) then
                local elementData = {
                    event = eventName,
                    args = safePack(...),
                    displayEvent = format("%s: %s", MessageBusName, eventName),
                    displayMessage = format("%s: %s", MessageBusName, eventName),
                }
                EventTrace:LogLine(elementData);
            end
        end
        if executing[eventName] then
            error("Event '" .. eventName .. "' is already being executed!", 2)
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
    ---@param eventName Event
    ---@param ... any @Input arguments for the callback
    ---@return table? @A table containing all the return values
    function handler:Fire(eventName, ...)
        return fire(eventName, nil, ...)
    end

    --- Fire a async callback event which invokes coroutine yield
    ---@param eventName Event
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
    ---@param eventName Event
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
    ---@param eventName Event
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
    ---@param eventName Event
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
    ---@param eventName Event
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
    ---@param eventName Event
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
    ---@param eventName Event
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
