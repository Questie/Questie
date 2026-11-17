---Questie-owned runtime services for events, timers, commands, and addon messaging.
---@class QuestieRuntime
local QuestieRuntime = QuestieLoader:CreateModule("QuestieRuntime")
local _QuestieRuntime = QuestieRuntime.private

local unpack = unpack
local tinsert = table.insert
local strsub = string.sub
local strmatch = string.match

local MSG_MULTI_FIRST = "\001"
local MSG_MULTI_NEXT = "\002"
local MSG_MULTI_LAST = "\003"
local MSG_ESCAPE = "\004"

local function _Call(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local args = {...}
    local ok, err = xpcall(function()
        return callback(unpack(args))
    end, function(message)
        if geterrorhandler then
            geterrorhandler()(message)
        else
            print(message)
        end
        return message
    end)

    return ok, err
end

local function _AddEventCallback(registry, name, callback)
    local callbacks = registry[name]
    if not callbacks then
        callbacks = {}
        registry[name] = callbacks
    end

    for _, registered in ipairs(callbacks) do
        if registered == callback then
            return
        end
    end

    tinsert(callbacks, callback)
end

local function _RemoveEventCallbacks(registry, name)
    registry[name] = nil
end

local function _Fire(registry, name, ...)
    local callbacks = registry[name]
    if not callbacks then
        return
    end

    for _, callback in ipairs(callbacks) do
        _Call(callback, name, ...)
    end
end

local function _FireBucket(bucket)
    if not next(bucket.received) then
        bucket.timer = nil
        return
    end

    local received = bucket.received
    bucket.received = {}
    bucket.timer = nil

    if type(bucket.callback) == "string" then
        _Call(bucket.object[bucket.callback], bucket.object, received)
    else
        _Call(bucket.callback, received)
    end

    if next(bucket.received) then
        bucket.timer = bucket.object:ScheduleTimer(_FireBucket, bucket.interval, bucket)
    end
end

local function _BucketHandler(bucket, _, arg1)
    arg1 = arg1 == nil and "nil" or arg1
    bucket.received[arg1] = (bucket.received[arg1] or 0) + 1
    if not bucket.timer then
        bucket.timer = bucket.object:ScheduleTimer(_FireBucket, bucket.interval, bucket)
    end
end

local function _RegisterBucket(addon, registry, event, interval, callback)
    local bucket = {
        object = addon,
        callback = callback,
        interval = tonumber(interval),
        received = {},
    }

    if type(event) == "table" then
        for _, eventName in pairs(event) do
            _AddEventCallback(registry, eventName, function(firedEventName, ...)
                _BucketHandler(bucket, firedEventName, ...)
            end)
        end
    else
        _AddEventCallback(registry, event, function(eventName, ...)
            _BucketHandler(bucket, eventName, ...)
        end)
    end

    return bucket
end

local function _SendAddonMessage(prefix, text, distribution, target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        return C_ChatInfo.SendAddonMessage(prefix, text, distribution, target)
    end
    return _G.SendAddonMessage(prefix, text, distribution, target)
end

local function _HandleCommMessage(runtime, prefix, message, distribution, sender)
    local callback = runtime.comms[prefix]
    if not callback then
        return
    end

    sender = Ambiguate and Ambiguate(sender, "none") or sender
    local control, rest = strmatch(message, "^([\001-\009])(.*)")
    local key = prefix .. "\t" .. distribution .. "\t" .. sender

    if control == MSG_MULTI_FIRST then
        runtime.multipart[key] = rest
    elseif control == MSG_MULTI_NEXT then
        if runtime.multipart[key] then
            runtime.multipart[key] = runtime.multipart[key] .. rest
        end
    elseif control == MSG_MULTI_LAST then
        if runtime.multipart[key] then
            local complete = runtime.multipart[key] .. rest
            runtime.multipart[key] = nil
            _Call(callback, prefix, complete, distribution, sender)
        end
    elseif control == MSG_ESCAPE then
        _Call(callback, prefix, rest, distribution, sender)
    elseif not control then
        _Call(callback, prefix, message, distribution, sender)
    end
end

---Create the Questie addon object and install the runtime services it needs.
---@return Questie addon
function QuestieRuntime:CreateAddon()
    local runtime = {
        events = {},
        messages = {},
        comms = {},
        multipart = {},
        buckets = {},
        timers = {},
        slashCommands = {},
        initialized = false,
        enabled = false,
    }

    local addon = {
        name = "Questie",
        _runtime = runtime,
    }

    local frame = CreateFrame("Frame", "QuestieRuntimeFrame")
    runtime.frame = frame
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_ADDON" then
            _HandleCommMessage(runtime, ...)
            return
        end

        if event == "ADDON_LOADED" and select(1, ...) == "Questie" and not runtime.initialized then
            runtime.initialized = true
            if addon.OnInitialize then
                _Call(addon.OnInitialize, addon)
            end
        elseif event == "PLAYER_LOGIN" and not runtime.enabled then
            runtime.enabled = true
            if addon.OnEnable then
                _Call(addon.OnEnable, addon)
            end
        end

        _Fire(runtime.events, event, ...)
    end)

    function addon:RegisterEvent(event, callback)
        if not callback then
            local method = self[event]
            callback = function(eventName, ...)
                _Call(method, self, eventName, ...)
            end
        end
        if type(callback) ~= "function" then
            error("RegisterEvent requires a callback for " .. tostring(event), 2)
        end
        _AddEventCallback(runtime.events, event, callback)
        frame:RegisterEvent(event)
    end

    function addon:UnregisterEvent(event)
        _RemoveEventCallbacks(runtime.events, event)
        if event ~= "ADDON_LOADED" and event ~= "PLAYER_LOGIN" and event ~= "CHAT_MSG_ADDON" then
            frame:UnregisterEvent(event)
        end
    end

    function addon:RegisterMessage(message, callback)
        if not callback then
            local method = self[message]
            callback = function(messageName, ...)
                _Call(method, self, messageName, ...)
            end
        end
        _AddEventCallback(runtime.messages, message, callback)
    end

    function addon:SendMessage(message, ...)
        _Fire(runtime.messages, message, ...)
    end

    function addon:RegisterBucketEvent(event, interval, callback)
        local bucket = _RegisterBucket(self, runtime.events, event, interval, callback)
        tinsert(runtime.buckets, bucket)
        for _, eventName in pairs(type(event) == "table" and event or {event}) do
            frame:RegisterEvent(eventName)
        end
        return bucket
    end

    function addon:RegisterBucketMessage(message, interval, callback)
        local bucket = _RegisterBucket(self, runtime.messages, message, interval, callback)
        tinsert(runtime.buckets, bucket)
        return bucket
    end

    function addon:ScheduleTimer(callback, delay, ...)
        local timer = {cancelled = false}
        runtime.timers[timer] = true
        local args = {...}
        local function run()
            if timer.cancelled then
                return
            end
            runtime.timers[timer] = nil
            _Call(callback, unpack(args))
        end

        if C_Timer and C_Timer.NewTimer then
            timer.native = C_Timer.NewTimer(delay, run)
        else
            C_Timer.After(delay, run)
        end
        return timer
    end

    function addon:CancelTimer(timer)
        if not timer then
            return
        end
        timer.cancelled = true
        runtime.timers[timer] = nil
        if timer.native and timer.native.Cancel then
            timer.native:Cancel()
        end
    end

    function addon:RegisterComm(prefix, callback)
        runtime.comms[prefix] = callback or self.OnCommReceived
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            C_ChatInfo.RegisterAddonMessagePrefix(prefix)
        else
            _G.RegisterAddonMessagePrefix(prefix)
        end
        if not runtime.chatMessageRegistered then
            runtime.chatMessageRegistered = true
            frame:RegisterEvent("CHAT_MSG_ADDON")
        end
    end

    function addon:SendCommMessage(prefix, text, distribution, target)
        local maxTextLength = 255
        if type(prefix) ~= "string" or type(text) ~= "string" or type(distribution) ~= "string" then
            error("SendCommMessage requires string prefix, text, and distribution", 2)
        end

        local textLength = #text
        local forceMultipart
        if strmatch(text, "^[\001-\009]") then
            if textLength + 1 > maxTextLength then
                forceMultipart = true
            else
                text = MSG_ESCAPE .. text
            end
        end

        if not forceMultipart and textLength <= maxTextLength then
            _SendAddonMessage(prefix, text, distribution, target)
            return
        end

        maxTextLength = maxTextLength - 1
        local position = 1
        while position <= textLength do
            local chunk = strsub(text, position, position + maxTextLength - 1)
            local control
            if position == 1 then
                control = MSG_MULTI_FIRST
            elseif position + maxTextLength > textLength then
                control = MSG_MULTI_LAST
            else
                control = MSG_MULTI_NEXT
            end
            _SendAddonMessage(prefix, control .. chunk, distribution, target)
            position = position + maxTextLength
        end
    end

    function addon:RegisterChatCommand(name, callback)
        local key = "QUESTIE_" .. string.upper(name:gsub("[^%w]", "_"))
        runtime.slashCommands[name] = callback
        _G["SLASH_" .. key .. "1"] = "/" .. name
        SlashCmdList[key] = function(input)
            callback(input or "")
        end
    end

    function addon:Print(...)
        if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
            local values = {...}
            for index, value in ipairs(values) do
                values[index] = tostring(value)
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Questie|r: " .. table.concat(values, " "))
        else
            print(...)
        end
    end

    return addon
end

return QuestieRuntime
