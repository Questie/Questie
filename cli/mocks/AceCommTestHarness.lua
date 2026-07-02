-- luacheck: globals Questie QuestieLoader LibStub Enum C_EncodingUtil ChatThrottleLib

--[[
Opt-in harness for comms integration tests that want real AceComm/AceEvent while
running outside the WoW client.

The harness owns boring mechanics only: fake frames/events, C_ChatInfo addon
traffic capture, timers, roster APIs, real Ace library loading, and codec glue.
Questie protocol policy stays in the test files that use this helper.
]]
local AceCommTestHarness = {}
AceCommTestHarness.__index = AceCommTestHarness

local unpack = unpack

local function clearTable(tableToClear)
    for key in pairs(tableToClear) do
        tableToClear[key] = nil
    end
end

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copied = {}
    for key, childValue in pairs(value) do
        copied[deepCopy(key)] = deepCopy(childValue)
    end

    return copied
end

-------------------------
-- State capture/restore.
-------------------------
local function snapshotQuestieTable()
    local snapshot = {}
    for key, value in pairs(Questie) do
        snapshot[key] = value
    end

    -- The harness may install Ace embeds and tests may mutate settings leaves.
    -- Keep persistent DB leaves isolated so later tests do not inherit state.
    local questieDb = Questie.db
    snapshot.dbState = {
        charExists = questieDb and questieDb.char ~= nil,
        profileExists = questieDb and questieDb.profile ~= nil,
        globalExists = questieDb and questieDb.global ~= nil,
        char = questieDb and deepCopy(questieDb.char),
        profile = questieDb and deepCopy(questieDb.profile),
        global = questieDb and deepCopy(questieDb.global),
    }

    return snapshot
end

local function restoreQuestieTable(snapshot)
    local dbState = snapshot.dbState
    snapshot.dbState = nil

    for key in pairs(Questie) do
        Questie[key] = nil
    end
    for key, value in pairs(snapshot) do
        Questie[key] = value
    end

    if Questie.db and dbState then
        Questie.db.char = dbState.charExists and deepCopy(dbState.char) or nil
        Questie.db.profile = dbState.profileExists and deepCopy(dbState.profile) or nil
        Questie.db.global = dbState.globalExists and deepCopy(dbState.global) or nil
    end
end

local function captureHarnessState()
    local encodingUtil = _G.C_EncodingUtil

    return {
        globals = {
            Ambiguate = _G.Ambiguate,
            C_ChatInfo = _G.C_ChatInfo,
            C_Timer = _G.C_Timer,
            ChatThrottleLib = _G.ChatThrottleLib,
            CreateFrame = _G.CreateFrame,
            DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME,
            GetFramerate = _G.GetFramerate,
            GetNormalizedRealmName = _G.GetNormalizedRealmName,
            GetNumGroupMembers = _G.GetNumGroupMembers,
            GetRealmName = _G.GetRealmName,
            GetTime = _G.GetTime,
            LibStub = _G.LibStub,
            UnitFullName = _G.UnitFullName,
            UnitInParty = _G.UnitInParty,
            UnitInRaid = _G.UnitInRaid,
            UnitIsConnected = _G.UnitIsConnected,
            UnitName = _G.UnitName,
            geterrorhandler = _G.geterrorhandler,
            securecallfunction = _G.securecallfunction,
            wipe = _G.wipe,
            xpcall = _G.xpcall,
        },
        tableWipe = table.wipe,
        enum = {
            CompressionLevel = _G.Enum and _G.Enum.CompressionLevel,
            CompressionMethod = _G.Enum and _G.Enum.CompressionMethod,
            SendAddonMessageResult = _G.Enum and _G.Enum.SendAddonMessageResult,
        },
        encodingUtil = encodingUtil,
        compressString = encodingUtil and encodingUtil.CompressString,
        decompressString = encodingUtil and encodingUtil.DecompressString,
        questie = snapshotQuestieTable(),
    }
end

local function restoreHarnessState(snapshot)
    local globals = snapshot.globals

    -- pairs skips nil values, so every nil-able global is restored explicitly.
    _G.Ambiguate = globals.Ambiguate
    _G.C_ChatInfo = globals.C_ChatInfo
    _G.C_Timer = globals.C_Timer
    _G.ChatThrottleLib = globals.ChatThrottleLib
    _G.CreateFrame = globals.CreateFrame
    _G.DEFAULT_CHAT_FRAME = globals.DEFAULT_CHAT_FRAME
    _G.GetFramerate = globals.GetFramerate
    _G.GetNormalizedRealmName = globals.GetNormalizedRealmName
    _G.GetNumGroupMembers = globals.GetNumGroupMembers
    _G.GetRealmName = globals.GetRealmName
    _G.GetTime = globals.GetTime
    _G.LibStub = globals.LibStub
    _G.UnitFullName = globals.UnitFullName
    _G.UnitInParty = globals.UnitInParty
    _G.UnitInRaid = globals.UnitInRaid
    _G.UnitIsConnected = globals.UnitIsConnected
    _G.UnitName = globals.UnitName
    _G.geterrorhandler = globals.geterrorhandler
    _G.securecallfunction = globals.securecallfunction
    _G.wipe = globals.wipe
    _G.xpcall = globals.xpcall

    table.wipe = snapshot.tableWipe

    _G.Enum.CompressionLevel = snapshot.enum.CompressionLevel
    _G.Enum.CompressionMethod = snapshot.enum.CompressionMethod
    _G.Enum.SendAddonMessageResult = snapshot.enum.SendAddonMessageResult

    _G.C_EncodingUtil = snapshot.encodingUtil
    if snapshot.encodingUtil then
        snapshot.encodingUtil.CompressString = snapshot.compressString
        snapshot.encodingUtil.DecompressString = snapshot.decompressString
    end

    restoreQuestieTable(snapshot.questie)
end

-------------------------
-- Construction.
-------------------------
function AceCommTestHarness.New()
    local harness = setmetatable({}, AceCommTestHarness)
    harness.originalState = captureHarnessState()
    harness.clock = 100
    harness.frames = {}
    harness.framesByName = {}
    harness.registeredAddonPrefixes = {}
    harness.sentAddonMessages = {}
    harness.timers = {}
    harness.groupRoster = {
        playerName = "Player",
        realmName = "HomeRealm",
        groupMemberCount = 0,
        partyMembers = {},
        raidMembers = {},
        connectedMembers = {},
    }

    return harness
end

-------------------------
-- Fake WoW client boundary.
-------------------------
function AceCommTestHarness:CreateFakeFrame(name)
    local frame = {
        name = name,
        scripts = {},
        registeredEvents = {},
        shown = true,
    }

    function frame:SetScript(scriptName, callback)
        self.scripts[scriptName] = callback
    end
    function frame:GetScript(scriptName)
        return self.scripts[scriptName]
    end
    function frame:RegisterEvent(eventName)
        self.registeredEvents[eventName] = true
    end
    function frame:UnregisterEvent(eventName)
        self.registeredEvents[eventName] = nil
    end
    function frame:UnregisterAllEvents()
        clearTable(self.registeredEvents)
    end
    function frame:Show()
        self.shown = true
    end
    function frame:Hide()
        self.shown = false
    end
    function frame:IsShown()
        return self.shown
    end

    self.frames[#self.frames + 1] = frame
    if name then
        self.framesByName[name] = frame
    end

    return frame
end

function AceCommTestHarness:InstallWoWClient(options)
    options = options or {}
    self.clock = options.clock or self.clock
    self:SetGroupRoster(options)

    local harness = self
    local luaXpcall = xpcall
    _G.xpcall = function(callback, errorHandler, ...)
        local args = {...}
        return luaXpcall(function()
            return callback(unpack(args))
        end, errorHandler)
    end
    _G.securecallfunction = function(callback, ...)
        return callback(...)
    end
    _G.geterrorhandler = function()
        return function(message)
            error(message)
        end
    end
    _G.DEFAULT_CHAT_FRAME = {AddMessage = function() end}
    _G.GetTime = function()
        return harness.clock
    end
    _G.GetFramerate = function()
        return 60
    end
    _G.Ambiguate = function(sender)
        return sender
    end
    _G.wipe = clearTable
    table.wipe = clearTable

    _G.Enum.SendAddonMessageResult = {
        Success = 0,
        InvalidPrefix = 1,
        InvalidMessage = 2,
        AddonMessageThrottle = 3,
        InvalidChatType = 4,
        NotInGroup = 5,
        TargetRequired = 6,
        InvalidChannel = 7,
        ChannelThrottle = 8,
        GeneralError = 9,
        NotInGuild = 10,
    }

    _G.CreateFrame = function(_, name)
        return harness:CreateFakeFrame(name)
    end

    _G.C_ChatInfo = {
        RegisterAddonMessagePrefix = function(prefix)
            harness.registeredAddonPrefixes[prefix] = true
            return Enum.RegisterAddonMessagePrefixResult and Enum.RegisterAddonMessagePrefixResult.Success or true
        end,
        IsAddonMessagePrefixRegistered = function(prefix)
            return harness.registeredAddonPrefixes[prefix] == true
        end,
        GetRegisteredAddonMessagePrefixes = function()
            local prefixes = {}
            for prefix in pairs(harness.registeredAddonPrefixes) do
                prefixes[#prefixes + 1] = prefix
            end
            return prefixes
        end,
        SendAddonMessage = function(prefix, message, distribution, target)
            harness.sentAddonMessages[#harness.sentAddonMessages + 1] = {
                prefix = prefix,
                message = message,
                distribution = distribution,
                target = target,
            }
            return Enum.SendAddonMessageResult.Success
        end,
        SendAddonMessageLogged = function(prefix, message, distribution, target)
            harness.sentAddonMessages[#harness.sentAddonMessages + 1] = {
                prefix = prefix,
                message = message,
                distribution = distribution,
                target = target,
                logged = true,
            }
            return Enum.SendAddonMessageResult.Success
        end,
    }

    _G.C_Timer = {
        NewTimer = function(_, callback)
            local timer = {cancelled = false, fired = false}
            function timer:Cancel()
                self.cancelled = true
            end
            function timer:Fire()
                if not self.cancelled and not self.fired then
                    self.fired = true
                    callback()
                end
            end

            harness.timers[#harness.timers + 1] = timer
            return timer
        end,
        NewTicker = function(_, callback)
            local ticker = {cancelled = false}
            function ticker:Cancel()
                self.cancelled = true
            end
            function ticker:Fire()
                if not self.cancelled then
                    callback()
                end
            end

            harness.timers[#harness.timers + 1] = ticker
            return ticker
        end,
        After = function(_, callback)
            local timer = {cancelled = false, fired = false}
            function timer:Cancel()
                self.cancelled = true
            end
            function timer:Fire()
                if not self.cancelled and not self.fired then
                    self.fired = true
                    callback()
                end
            end

            harness.timers[#harness.timers + 1] = timer
        end,
    }
end

function AceCommTestHarness:SetGroupRoster(options)
    options = options or {}
    self.groupRoster = {
        playerName = options.playerName or self.groupRoster.playerName,
        realmName = options.realmName or self.groupRoster.realmName,
        groupMemberCount = options.groupMemberCount ~= nil and options.groupMemberCount or self.groupRoster.groupMemberCount,
        partyMembers = options.partyMembers or self.groupRoster.partyMembers or {},
        raidMembers = options.raidMembers or self.groupRoster.raidMembers or {},
        connectedMembers = options.connectedMembers or self.groupRoster.connectedMembers or {},
    }

    local harness = self
    _G.GetNumGroupMembers = function()
        return harness.groupRoster.groupMemberCount
    end
    _G.UnitName = function()
        return harness.groupRoster.playerName
    end
    _G.UnitFullName = function(unit)
        if unit == "player" then
            return harness.groupRoster.playerName, harness.groupRoster.realmName
        end
    end
    _G.GetNormalizedRealmName = function()
        return harness.groupRoster.realmName
    end
    _G.GetRealmName = function()
        return harness.groupRoster.realmName
    end
    _G.UnitInParty = function(unit)
        return harness.groupRoster.partyMembers[unit] == true
    end
    _G.UnitInRaid = function(unit)
        return harness.groupRoster.raidMembers[unit] == true
    end
    _G.UnitIsConnected = function(unit)
        local configuredConnection = harness.groupRoster.connectedMembers[unit]
        if configuredConnection ~= nil then
            return configuredConnection == true
        end

        return unit == "player"
            or unit == harness.groupRoster.playerName
            or unit == (harness.groupRoster.playerName .. "-" .. harness.groupRoster.realmName)
            or harness.groupRoster.partyMembers[unit] == true
            or harness.groupRoster.raidMembers[unit] == true
    end
end

-------------------------
-- Real Ace + codec boundary.
-------------------------
function AceCommTestHarness:LoadRealAceCommInto(addon)
    _G.LibStub = nil
    _G.ChatThrottleLib = nil

    dofile("Libs/LibStub/LibStub.lua")
    dofile("Libs/LibDeflate/LibDeflate.lua")
    dofile("Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")
    dofile("Libs/AceEvent-3.0/AceEvent-3.0.lua")
    dofile("Libs/AceTimer-3.0/AceTimer-3.0.lua")
    dofile("Libs/AceBucket-3.0/AceBucket-3.0.lua")
    dofile("Libs/AceComm-3.0/ChatThrottleLib.lua")
    dofile("Libs/AceComm-3.0/AceComm-3.0.lua")

    LibStub("AceEvent-3.0"):Embed(addon)
    LibStub("AceBucket-3.0"):Embed(addon)
    LibStub("AceComm-3.0"):Embed(addon)
end

function AceCommTestHarness:InstallBlizzardDeflateCompression()
    local LibDeflate = LibStub("LibDeflate")

    _G.Enum.CompressionMethod = {Deflate = 1}
    _G.Enum.CompressionLevel = {Default = 1}
    _G.C_EncodingUtil.CompressString = function(payload, method, level)
        if method ~= Enum.CompressionMethod.Deflate then
            error("unexpected compression method")
        end
        if level ~= Enum.CompressionLevel.Default then
            error("unexpected compression level")
        end

        return LibDeflate:CompressDeflate(payload)
    end
    _G.C_EncodingUtil.DecompressString = function(payload, method)
        if method ~= Enum.CompressionMethod.Deflate then
            error("unexpected decompression method")
        end

        return LibDeflate:DecompressDeflate(payload)
    end
end

-------------------------
-- Test driver helpers.
-------------------------
function AceCommTestHarness:RunTimers()
    local timerCount = #self.timers
    for index = 1, timerCount do
        self.timers[index]:Fire()
    end
end

function AceCommTestHarness:BuildEncodedAddonMessage(prefix, payload, distribution, target)
    local CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
    local encodedPayload = CommsEncoding:EncodePayload(payload)
    if not encodedPayload then
        error("failed to encode addon message for prefix " .. tostring(prefix))
    end

    return {
        prefix = prefix,
        message = encodedPayload,
        distribution = distribution or "PARTY",
        target = target,
    }
end

function AceCommTestHarness:FlushAddonTraffic()
    for _ = 1, 3 do
        self.clock = self.clock + 10
        for _, frame in ipairs(self.frames) do
            local onUpdate = frame.scripts.OnUpdate
            if onUpdate then
                onUpdate(frame, 0.1)
            end
        end
    end
end

function AceCommTestHarness:FireWoWEvent(eventName, ...)
    for _, frame in ipairs(self.frames) do
        if frame.registeredEvents[eventName] and frame.scripts.OnEvent then
            frame.scripts.OnEvent(frame, eventName, ...)
        end
    end
end

function AceCommTestHarness:DeliverAddonMessage(envelope, sender, distribution)
    self:FireWoWEvent("CHAT_MSG_ADDON", envelope.prefix, envelope.message, distribution or envelope.distribution, sender)
    self:FlushAddonTraffic()
end

function AceCommTestHarness:FindSentAddonMessage(prefix, distribution, target)
    for _, message in ipairs(self.sentAddonMessages) do
        if message.prefix == prefix
            and (not distribution or message.distribution == distribution)
            and (target == nil or message.target == target)
        then
            return message
        end
    end
end

function AceCommTestHarness:Restore()
    if not self.originalState then
        return
    end

    restoreHarnessState(self.originalState)
    self.originalState = nil
end

-------------------------
-- Isolated comms emulator.
-------------------------
-- This is the multi-client path: every client gets its own Lua environment,
-- QuestieLoader registry, LibStub/Ace singletons, fake WoW globals, and timer
-- queue. The only shared object is the network, which acts like the addon
-- channel and deterministic clock.
local IsolatedNetwork = {}
IsolatedNetwork.__index = IsolatedNetwork

local IsolatedClient = {}
IsolatedClient.__index = IsolatedClient

local function _RunFileInEnv(path, env)
    local chunk, loadError = loadfile(path)
    if not chunk then
        error(loadError)
    end

    setfenv(chunk, env)
    return chunk()
end

local function _CopyTable(tableToCopy)
    local copied = {}
    for key, value in pairs(tableToCopy) do
        copied[key] = value
    end

    return copied
end

local function _NewIsolatedEnvironment()
    local env = {}
    setmetatable(env, {__index = _G})
    env._G = env
    -- setupTests and the isolated codec boundary mutate these globals; keep those changes inside this client.
    env.Enum = _CopyTable(_G.Enum or {})
    env.table = _CopyTable(table)
    env.string = _CopyTable(string)
    env.math = _CopyTable(math)
    env.dofile = function(path)
        return _RunFileInEnv(path, env)
    end

    return env
end

local function _InstallIsolatedFrameApi(client)
    client.env.CreateFrame = function(_, name)
        local frame = {
            name = name,
            scripts = {},
            registeredEvents = {},
            shown = true,
        }

        function frame:SetScript(scriptName, callback)
            self.scripts[scriptName] = callback
        end
        function frame:GetScript(scriptName)
            return self.scripts[scriptName]
        end
        function frame:RegisterEvent(eventName)
            self.registeredEvents[eventName] = true
        end
        function frame:UnregisterEvent(eventName)
            self.registeredEvents[eventName] = nil
        end
        function frame:UnregisterAllEvents()
            clearTable(self.registeredEvents)
        end
        function frame:Show()
            self.shown = true
        end
        function frame:Hide()
            self.shown = false
        end
        function frame:IsShown()
            return self.shown
        end

        client.frames[#client.frames + 1] = frame
        return frame
    end
end

-- Schedules timers against the network clock instead of wall time. One-shots
-- and tickers share the same shape so FlushUntilIdle can drive them uniformly.
local function _ScheduleIsolatedTimer(client, delay, callback, interval, iterations)
    local timer = {
        cancelled = false,
        dueTime = client.network.clock + (delay or 0),
        interval = interval,
        remainingIterations = iterations,
        callback = callback,
    }

    function timer:Cancel()
        self.cancelled = true
    end

    client.timers[#client.timers + 1] = timer
    return timer
end

local function _InstallIsolatedWowApi(client)
    local env = client.env
    local luaXpcall = xpcall

    env.xpcall = function(callback, errorHandler, ...)
        local args = {...}
        return luaXpcall(function()
            return callback(unpack(args))
        end, errorHandler)
    end
    env.securecallfunction = function(callback, ...)
        return callback(...)
    end
    env.geterrorhandler = function()
        return function(message)
            error(message)
        end
    end
    env.DEFAULT_CHAT_FRAME = {AddMessage = function() end}
    env.GetTime = function()
        return client.network.clock
    end
    env.GetFramerate = function()
        return 60
    end
    env.Ambiguate = function(sender)
        return sender
    end
    env.wipe = clearTable
    env.table.wipe = clearTable

    env.Enum.CompressionMethod = {Deflate = 1}
    env.Enum.CompressionLevel = {Default = 1}
    env.Enum.SendAddonMessageResult = {
        Success = 0,
        InvalidPrefix = 1,
        InvalidMessage = 2,
        AddonMessageThrottle = 3,
        InvalidChatType = 4,
        NotInGroup = 5,
        TargetRequired = 6,
        InvalidChannel = 7,
        ChannelThrottle = 8,
        GeneralError = 9,
        NotInGuild = 10,
    }

    _InstallIsolatedFrameApi(client)

    -- C_ChatInfo is the client boundary: invalid topology is rejected before a
    -- send is traced or queued. Valid sends still may not reach a callback when
    -- the target is disconnected or did not register that prefix, matching the
    -- two-stage shape of WoW send validation followed by receive-side filtering.
    env.C_ChatInfo = {
        RegisterAddonMessagePrefix = function(prefix)
            if not client.network:IsValidAddonPrefix(prefix) then
                return false
            end

            client.registeredAddonPrefixes[prefix] = true
            return true
        end,
        IsAddonMessagePrefixRegistered = function(prefix)
            return client.registeredAddonPrefixes[prefix] == true
        end,
        GetRegisteredAddonMessagePrefixes = function()
            local prefixes = {}
            for prefix in pairs(client.registeredAddonPrefixes) do
                prefixes[#prefixes + 1] = prefix
            end
            return prefixes
        end,
        SendAddonMessage = function(prefix, message, distribution, target)
            local sendResult = client.network:ValidateAddonSend(client, prefix, message, distribution, target)
            if sendResult ~= env.Enum.SendAddonMessageResult.Success then
                return sendResult
            end

            local envelope = {
                sender = client,
                prefix = prefix,
                message = message,
                distribution = distribution,
                target = target,
            }
            client.sentAddonMessages[#client.sentAddonMessages + 1] = envelope
            client.network.pendingMessages[#client.network.pendingMessages + 1] = envelope
            client.network.trace[#client.network.trace + 1] = {
                sender = client.fullName,
                prefix = prefix,
                distribution = distribution,
                target = target,
            }
            return env.Enum.SendAddonMessageResult.Success
        end,
        SendAddonMessageLogged = function(prefix, message, distribution, target)
            return env.C_ChatInfo.SendAddonMessage(prefix, message, distribution, target)
        end,
    }

    -- AceTimer/AceBucket see normal C_Timer APIs, but tests control time by
    -- advancing the network clock. No isolated test should depend on real sleep.
    env.C_Timer = {
        NewTimer = function(delay, callback)
            return _ScheduleIsolatedTimer(client, delay, callback)
        end,
        NewTicker = function(delay, callback, iterations)
            return _ScheduleIsolatedTimer(client, delay, callback, delay, iterations)
        end,
        After = function(delay, callback)
            _ScheduleIsolatedTimer(client, delay, callback)
        end,
    }

    -- Roster APIs resolve both WoW unit tokens and AceComm sender names so the
    -- same network can drive protocol trust checks and group-lifecycle tests.
    env.GetNumGroupMembers = function()
        return client.network:GetGroupMemberCount(client)
    end
    env.UnitName = function(unit)
        local rosterClient = client.network:ResolveUnit(client, unit or "player")
        if rosterClient then
            return rosterClient.playerName
        end

        return nil
    end
    env.UnitFullName = function(unit)
        local rosterClient = client.network:ResolveUnit(client, unit or "player")
        if rosterClient then
            return rosterClient.playerName, rosterClient.realmName
        end

        return nil
    end
    env.GetNormalizedRealmName = function()
        return client.realmName
    end
    env.GetRealmName = function()
        return client.realmName
    end
    env.UnitInParty = function(unit)
        -- Questie's modern trust check accepts PARTY/RAID/INSTANCE_CHAT only
        -- after UnitInParty/UnitInRaid confirms the sender. Model instance
        -- groups as party-like for that trust boundary without claiming this is
        -- a complete WoW unit-token emulation.
        return client.network:IsClientInRoster(client, unit, "partyClients")
            or client.network:IsClientInRoster(client, unit, "instanceClients")
    end
    env.UnitInRaid = function(unit)
        return client.network:IsClientInRoster(client, unit, "raidClients")
    end
    env.UnitIsConnected = function(unit)
        return client.network:IsUnitConnected(client, unit)
    end
    env.IsInGroup = function()
        return client.network:IsInParty(client) or client.network:IsInRaid(client) or client.network:IsInInstance(client)
    end
    env.IsInRaid = function()
        return client.network:IsInRaid(client)
    end
    env.IsInGuild = function()
        return client.network:IsInGuild(client)
    end
end

local function _LoadIsolatedRealAce(client)
    local env = client.env
    -- Mask parent-process libraries inherited through __index so this client owns
    -- an independent LibStub registry and Ace singleton set.
    env.LibStub = false
    env.ChatThrottleLib = false

    client:DoFile("Libs/LibStub/LibStub.lua")
    client:DoFile("Libs/LibDeflate/LibDeflate.lua")
    client:DoFile("Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")
    client:DoFile("Libs/AceEvent-3.0/AceEvent-3.0.lua")
    client:DoFile("Libs/AceTimer-3.0/AceTimer-3.0.lua")
    client:DoFile("Libs/AceBucket-3.0/AceBucket-3.0.lua")
    client:DoFile("Libs/AceComm-3.0/ChatThrottleLib.lua")
    client:DoFile("Libs/AceComm-3.0/AceComm-3.0.lua")

    env.LibStub("AceEvent-3.0"):Embed(env.Questie)
    env.LibStub("AceTimer-3.0"):Embed(env.Questie)
    env.LibStub("AceBucket-3.0"):Embed(env.Questie)
    env.LibStub("AceComm-3.0"):Embed(env.Questie)
end

local function _LoadIsolatedAceSerializer(client)
    local env = client.env

    -- Daily `Questie` prefix messages use AceSerializer through Questie:Serialize,
    -- unlike modern CBOR payloads or legacy QuestieSerializer packets.
    client:DoFile("Libs/AceSerializer-3.0/AceSerializer-3.0.lua")
    env.LibStub("AceSerializer-3.0"):Embed(env.Questie)
end

local function _InstallIsolatedCompression(client)
    local env = client.env
    local LibDeflate = env.LibStub("LibDeflate")

    env.C_EncodingUtil.CompressString = function(payload, method, level)
        if method ~= env.Enum.CompressionMethod.Deflate then
            error("unexpected compression method")
        end
        if level ~= env.Enum.CompressionLevel.Default then
            error("unexpected compression level")
        end

        return LibDeflate:CompressDeflate(payload)
    end
    env.C_EncodingUtil.DecompressString = function(payload, method)
        if method ~= env.Enum.CompressionMethod.Deflate then
            error("unexpected decompression method")
        end

        return LibDeflate:DecompressDeflate(payload)
    end
end

function IsolatedClient:DoFile(path)
    return _RunFileInEnv(path, self.env)
end

function IsolatedClient:RunDueTimers()
    local firedAnyTimer = false

    for _, timer in ipairs(self.timers) do
        if not timer.cancelled and timer.dueTime <= self.network.clock then
            firedAnyTimer = true
            if timer.interval then
                if timer.remainingIterations then
                    timer.remainingIterations = timer.remainingIterations - 1
                end

                timer.callback(timer)

                if timer.cancelled or timer.remainingIterations == 0 then
                    timer.cancelled = true
                else
                    timer.dueTime = self.network.clock + timer.interval
                end
            else
                timer.cancelled = true
                timer.callback(timer)
            end
        end
    end

    return firedAnyTimer
end

function IsolatedClient:RunTimers()
    self.network:AdvanceTime(10)
end

function IsolatedClient:PumpAddonTraffic(elapsed)
    for _, frame in ipairs(self.frames) do
        local onUpdate = frame.scripts.OnUpdate
        if onUpdate then
            onUpdate(frame, elapsed or 0.1)
        end
    end
end

function IsolatedClient:FlushAddonTraffic()
    for _ = 1, 3 do
        self.network:AdvanceTime(10)
        self:PumpAddonTraffic(0.1)
    end
end

function IsolatedClient:FireWoWEvent(eventName, ...)
    for _, frame in ipairs(self.frames) do
        if frame.registeredEvents[eventName] and frame.scripts.OnEvent then
            frame.scripts.OnEvent(frame, eventName, ...)
        end
    end
end

local function _InstallIsolatedQuestieBoundary(client)
    client.env.Questie.Debug = function() end
    client.env.Questie.Error = function(_, message)
        error(message)
    end

    client.env.Questie.db.char = {hidden = {}}
    client.env.Questie.db.profile = {}
    client.env.Questie._sessionWarnings = {}
end

local function _InstallIsolatedGroupTypeFixture(client)
    local QuestiePlayer = client.env.QuestieLoader:ImportModule("QuestiePlayer")
    QuestiePlayer.GetGroupType = function()
        if client.network:IsInRaid(client) then
            return "raid"
        end
        if client.network:IsInInstance(client) then
            return "instance"
        end
        if client.network:IsInParty(client) then
            return "party"
        end

        return nil
    end

    return QuestiePlayer
end

local function _SplitPlain(delimiter, value)
    local parts = {}
    local startIndex = 1

    while true do
        local delimiterStart, delimiterEnd = string.find(value, delimiter, startIndex, true)
        if not delimiterStart then
            parts[#parts + 1] = string.sub(value, startIndex)
            break
        end

        parts[#parts + 1] = string.sub(value, startIndex, delimiterStart - 1)
        startIndex = delimiterEnd + 1
    end

    return unpack(parts)
end

local function _InstallIsolatedLegacyGlobals(client)
    local env = client.env

    -- QuestieSerializer and old QuestieComms predate the newer module style and
    -- expect several WoW/Lua helpers as globals. Keep that compatibility surface
    -- local to the isolated client so the parent test process is not polluted.
    env.floor = math.floor
    env.frexp = math.frexp
    env.ldexp = math.ldexp
    env.mod = math.fmod
    env.random = function() return 0 end
    env.tinsert = table.insert
    env.tremove = table.remove
    env.strsplit = _SplitPlain

    env.UnitClassBase = function()
        return "DRUID"
    end
    env.UnitInBattleground = function()
        return false
    end
    env.UnitAffectingCombat = function()
        return false
    end
    env.C_Map = {
        GetBestMapForUnit = function()
            return 1
        end,
    }
    env.GetChannelName = function()
        return 1
    end
end

local function _InstallIsolatedLegacyModuleFixtures(client)
    local env = client.env

    -- Keep yell/channel side paths out of this fixture; these tests cover
    -- party/whisper quest-log sharing through the legacy `questie` prefix.
    env.Questie.db.profile.disableYellComms = true

    local HBD = env.LibStub:GetLibrary("HereBeDragonsQuestie-2.0", true)
    if not HBD then
        HBD = env.LibStub:NewLibrary("HereBeDragonsQuestie-2.0", "1")
    end
    HBD.GetPlayerZone = function()
        return 1
    end
    HBD.GetZoneDistance = function()
        return 1
    end

    local l10n = env.QuestieLoader:ImportModule("l10n")
    setmetatable(l10n, {
        __call = function(_, text, ...)
            if select("#", ...) > 0 then
                local ok, formatted = pcall(string.format, text, ...)
                if ok then
                    return formatted
                end
            end

            return text
        end,
    })

    local QuestieLib = env.QuestieLoader:ImportModule("QuestieLib")
    QuestieLib.GetAddonVersionInfo = function()
        -- Version 5 keeps this first legacy emulator slice on the stable full-list
        -- packet shape. V2 packet edge cases are tested separately before relying
        -- on V2 as the default quest-list response.
        return 5, 0, 0
    end

    -- QuestieComms still registers the old daily callback in production. Keep the
    -- fixture as a no-op so the legacy quest-log stack can initialize, but do not
    -- make REPUTABLE part of the emulator's supported protocol story.
    local DailyQuests = env.QuestieLoader:ImportModule("DailyQuests")
    DailyQuests.FilterDailies = function() end
    client.DailyQuests = DailyQuests

    local ZoneDB = env.QuestieLoader:ImportModule("ZoneDB")
    ZoneDB.GetUiMapIdByAreaId = function()
        return 1
    end

    -- One-quest fixture: enough real quest/objective shape for QuestieComms to
    -- build and parse serializer-backed packets without pulling the full DB into
    -- the emulator. Tests can compare the resulting remoteQuestLogs directly.
    client.legacyQuestId = 101
    client.legacyObjectiveId = 9001
    client.legacyQuestDefinitions = {
        [client.legacyQuestId] = {
            Objectives = {
                [1] = {Id = client.legacyObjectiveId},
            },
        },
    }
    client.legacyQuestObjectives = {
        [client.legacyQuestId] = {
            [1] = {
                type = "monster",
                finished = false,
                numFulfilled = 1,
                numRequired = 5,
            },
        },
    }

    local QuestieDB = env.QuestieLoader:ImportModule("QuestieDB")
    QuestieDB.QuestPointers = {[client.legacyQuestId] = true}
    QuestieDB.GetQuest = function(questId)
        return client.legacyQuestDefinitions[questId]
    end
    QuestieDB.QueryQuestSingle = function(_, key)
        if key == "zoneOrSort" then
            return 1
        end

        return nil
    end

    local QuestLogCache = env.QuestieLoader:ImportModule("QuestLogCache")
    QuestLogCache.questLog_DO_NOT_MODIFY = {
        [client.legacyQuestId] = {questTag = "Group"},
    }
    QuestLogCache.GetQuestObjectives = function(questId)
        return client.legacyQuestObjectives[questId]
    end

    client.QuestieDB = QuestieDB
    client.QuestLogCache = QuestLogCache
end

local function _InstallIsolatedLegacyDataBoundary(client)
    -- QuestieCommsData owns tooltip presentation and broader DB lookups. The
    -- comms emulator only needs to prove when packets would register/remove
    -- remote progress, so this sink records those side effects without loading
    -- the map/tooltip data layer.
    client.legacyTooltipRegistrations = {}
    client.legacyTooltipRemovals = {}
    client.legacyDataResetCount = 0

    client.QuestieComms.data = {
        RegisterTooltip = function(_, questId, playerName, objectives)
            client.legacyTooltipRegistrations[#client.legacyTooltipRegistrations + 1] = {
                questId = questId,
                playerName = playerName,
                objectives = deepCopy(objectives),
            }
        end,
        RemoveQuestFromPlayer = function(_, questId, playerName)
            client.legacyTooltipRemovals[#client.legacyTooltipRemovals + 1] = {
                questId = questId,
                playerName = playerName,
            }
        end,
        ResetAll = function()
            client.legacyDataResetCount = client.legacyDataResetCount + 1
        end,
    }

    client.QuestieComms.remoteQuestLogs = {}
    client.QuestieComms.remotePlayerClasses = {}
    client.QuestieComms.remotePlayerEnabled = {}
    client.QuestieComms.remotePlayerTimes = {}
end

local function _InstallIsolatedDailyCommsFixture(client)
    -- Daily comms only need the receive-side effect. Keep the AvailableQuests
    -- boundary as captured calls so tests can assert routing and validation
    -- without loading daily quest database behavior.
    client.dailyQuestRemovals = {}

    local AvailableQuests = client.env.QuestieLoader:ImportModule("AvailableQuests")
    AvailableQuests.RemoveQuestsForToday = function(npcId, questIds)
        client.dailyQuestRemovals[#client.dailyQuestRemovals + 1] = {
            npcId = npcId,
            questIds = deepCopy(questIds),
        }
    end

    client.AvailableQuests = AvailableQuests
end

local function _LoadIsolatedCommsBase(client)
    client:DoFile("setupTests.lua")
    _InstallIsolatedWowApi(client)
    _LoadIsolatedRealAce(client)
    _InstallIsolatedCompression(client)
    _InstallIsolatedQuestieBoundary(client)
    client.QuestiePlayer = _InstallIsolatedGroupTypeFixture(client)
    client.QuestiePlayer.numberOfGroupMembers = client.network:GetGroupMemberCount(client)

    client:DoFile("Modules/Network/CommsEncoding.lua")
    client:DoFile("Modules/Network/CommsRouting.lua")
    client:DoFile("Modules/Network/CommsPrefixRegistry.lua")

    client.CommsEncoding = client.env.QuestieLoader:ImportModule("CommsEncoding")
    client.CommsPrefixRegistry = client.env.QuestieLoader:ImportModule("CommsPrefixRegistry")
    client.CommsPrefixRegistry:Initialize()
    client.CommsPrefixRegistry:ResetAll()
end

-- Loads the smallest real Questie stack needed for isolated QuestieH1 tests.
-- H1-only tests stay intentionally light; V1 and later protocols opt into the
-- richer modern stack below so their fixture state is obvious at the call site.
function IsolatedClient:LoadModernHelloStack()
    _LoadIsolatedCommsBase(self)
end

-- Loads the modern typed-prefix stack without group lifecycle or legacy quest-log
-- comms. The fixtures here are the minimum policy surface CommsVisibility reads:
-- local quest log, tracker/hidden state, party-objective redraw hooks, and a
-- QuestieComms table used by tests to prove V1 does not mutate legacy progress.
function IsolatedClient:LoadModernCommsStack()
    _LoadIsolatedCommsBase(self)

    -- V1 source truth: tests edit these tables directly to describe Alice's UI
    -- intent. We avoid full QuestLogCache/QuestieQuest loading so the isolated
    -- stack stays focused on modern visibility transport, not quest DB behavior.
    local QuestLogCache = self.env.QuestieLoader:ImportModule("QuestLogCache")
    QuestLogCache.questLog_DO_NOT_MODIFY = {}
    QuestLogCache.GetQuestObjectives = function()
        return nil
    end

    local QuestieQuest = self.env.QuestieLoader:ImportModule("QuestieQuest")
    QuestieQuest.IsQuestTracked = function(_, questId)
        local trackedQuests = self.trackedQuests or {}
        if trackedQuests[questId] ~= nil then
            return trackedQuests[questId] == true
        end

        return true
    end

    -- V1 receive side effect: redraw requests are counted, not rendered. That
    -- keeps assertions on the comms contract while leaving map UI out of scope.
    local QuestiePartyObjectives = self.env.QuestieLoader:ImportModule("QuestiePartyObjectives")
    QuestiePartyObjectives.scheduleUpdateCount = 0
    QuestiePartyObjectives.clearCount = 0
    QuestiePartyObjectives.ScheduleUpdate = function()
        QuestiePartyObjectives.scheduleUpdateCount = QuestiePartyObjectives.scheduleUpdateCount + 1
    end
    QuestiePartyObjectives.Clear = function()
        QuestiePartyObjectives.clearCount = QuestiePartyObjectives.clearCount + 1
    end

    -- Legacy separation guard: V1 is only party-objective visibility. Tests can
    -- inspect this stub to catch accidental writes to quest-log progress state.
    local QuestieComms = self.env.QuestieLoader:ImportModule("QuestieComms")
    QuestieComms.remoteQuestLogs = {}

    self:DoFile("Modules/Network/CommsVisibility.lua")

    self.QuestLogCache = QuestLogCache
    self.QuestieQuest = QuestieQuest
    self.QuestiePartyObjectives = QuestiePartyObjectives
    self.QuestieComms = QuestieComms
    self.CommsVisibility = self.env.QuestieLoader:ImportModule("CommsVisibility")

    self.CommsVisibility:Initialize()
    self.CommsVisibility:ResetAll()
end

-- Adds the real group lifecycle handler on top of the modern H1/V1 stack. This
-- stack intentionally keeps QuestieComms as a narrow lifecycle stub; full legacy
-- packet behavior is covered by LoadLegacyQuestieCommsStack() and QuestieComms tests.
function IsolatedClient:LoadModernGroupStack()
    self:LoadModernCommsStack()

    -- GROUP_LEFT cleanup boundary: real GroupEventHandler calls QuestieComms:ResetAll().
    -- Keep this stub narrow so lifecycle tests prove reset/cancel behavior without
    -- silently testing legacy packet policy.
    self.QuestieComms.resetAllCount = 0
    self.QuestieComms.ResetAll = function()
        self.QuestieComms.resetAllCount = self.QuestieComms.resetAllCount + 1
        self.QuestieComms.remoteQuestLogs = {}
    end

    -- GROUP_JOINED convergence signal: count the AceEvent message that would ask
    -- legacy QuestieComms peers for a full quest log, without loading the responder.
    self.fullQuestLogRequestCount = 0
    self.env.Questie:RegisterMessage("QC_ID_REQUEST_FULL_QUESTLIST", function()
        self.fullQuestLogRequestCount = self.fullQuestLogRequestCount + 1
    end)

    self:DoFile("Modules/EventHandler/GroupEventHandler.lua")
    self.GroupEventHandler = self.env.QuestieLoader:ImportModule("GroupEventHandler")

    -- Match production registration shape: joined/left are immediate AceEvent
    -- handlers, while roster updates pass through AceBucket's debounce path.
    self.env.Questie:RegisterEvent("GROUP_JOINED", self.GroupEventHandler.GroupJoined)
    self.env.Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, self.GroupEventHandler.GroupRosterUpdate)
    self.env.Questie:RegisterEvent("GROUP_LEFT", self.GroupEventHandler.GroupLeft)
end

-- Loads the real legacy quest-log sharing module behind a narrow test fixture.
-- QuestieComms itself is production code; the fixture only supplies the DB, HBD,
-- serializer globals, and tooltip sink that a one-quest packet exchange needs.
function IsolatedClient:LoadLegacyQuestieCommsStack()
    -- Keep the modern lifecycle alive: legacy packets should coexist with H1/V1,
    -- and QuestieH1 should advertise legacy prefixes once QuestieComms registers them.
    self:LoadModernGroupStack()

    -- Old serializer/QuestieComms code expects WoW-era globals and addon modules
    -- at load time, so install that compatibility surface before dofile().
    _InstallIsolatedLegacyGlobals(self)
    _InstallIsolatedLegacyModuleFixtures(self)

    -- Production load order for the legacy wire path: binary stream mechanics,
    -- QuestieSerializer packet format, then the real questie-prefix protocol.
    self:DoFile("Modules/QuestieStream.lua")
    self:DoFile("Modules/Libs/QuestieSerializer.lua")
    self:DoFile("Modules/Network/QuestieComms.lua")

    self.QuestieSerializer = self.env.QuestieLoader:ImportModule("QuestieSerializer")
    self.QuestieComms = self.env.QuestieLoader:ImportModule("QuestieComms")

    -- Replace the lifecycle stub's data hooks after the real module table exists.
    _InstallIsolatedLegacyDataBoundary(self)

    -- Initializes the current production legacy comm module. Emulator assertions
    -- focus on the `questie` quest-log path; old daily-prefix cleanup is separate.
    self.QuestieComms:Initialize()
end

-- Loads daily quest availability comms on the `Questie` prefix. This stack uses
-- real AceSerializer because Comms.lua calls Questie:Serialize/Deserialize,
-- while keeping AvailableQuests as a narrow receive-side fixture.
function IsolatedClient:LoadDailyCommsStack()
    self:LoadModernCommsStack()
    _LoadIsolatedAceSerializer(self)
    _InstallIsolatedDailyCommsFixture(self)

    self:DoFile("Modules/Network/Comms.lua")
    self.Comms = self.env.QuestieLoader:ImportModule("Comms")
    self.Comms.Initialize()
end

function IsolatedNetwork:CreateClient(options)
    options = options or {}
    local client = setmetatable({}, IsolatedClient)
    client.network = self
    client.env = _NewIsolatedEnvironment()
    client.playerName = options.playerName or "Player"
    client.realmName = options.realmName or "HomeRealm"
    client.fullName = client.playerName .. "-" .. client.realmName
    client.frames = {}
    client.registeredAddonPrefixes = {}
    client.sentAddonMessages = {}
    client.timers = {}
    client.connected = options.connected ~= false

    -- Jittered comm timers use math.random(). Give each isolated client a deterministic
    -- RNG instead of inheriting and mutating the parent process's global math state.
    client.randomSeed = options.randomSeed or (#self.clients + 1)
    client.env.math.random = function(min, max)
        client.randomSeed = (client.randomSeed * 1103515245 + 12345) % 2147483648
        local randomFraction = client.randomSeed / 2147483648
        if min and max then
            return math.floor(randomFraction * (max - min + 1)) + min
        end
        if min then
            return math.floor(randomFraction * min) + 1
        end

        return randomFraction
    end

    self.clients[#self.clients + 1] = client
    self.clientsByFullName[client.fullName] = client
    return client
end

-------------------------
-- Topology.
-------------------------
-- Rosters are explicit per distribution instead of inferred from one group list.
-- That keeps PARTY/RAID/INSTANCE/GUILD routing differences visible in tests.
function IsolatedNetwork:SetParty(clients)
    self.partyClients = clients or {}
end

function IsolatedNetwork:SetRaid(clients)
    self.raidClients = clients or {}
end

function IsolatedNetwork:SetInstance(clients)
    self.instanceClients = clients or {}
end

function IsolatedNetwork:SetGuild(clients)
    self.guildClients = clients or {}
end

function IsolatedNetwork:SetConnected(clientOrFullName, connected)
    local client = type(clientOrFullName) == "table" and clientOrFullName or self.clientsByFullName[clientOrFullName]
    if client then
        client.connected = connected ~= false
    end
end

function IsolatedNetwork:IsInRoster(client, rosterName)
    for _, rosterClient in ipairs(self[rosterName]) do
        if rosterClient == client then
            return true
        end
    end

    return false
end

function IsolatedNetwork:IsInParty(client)
    return self:IsInRoster(client, "partyClients")
end

function IsolatedNetwork:IsInRaid(client)
    return self:IsInRoster(client, "raidClients")
end

function IsolatedNetwork:IsInInstance(client)
    return self:IsInRoster(client, "instanceClients")
end

function IsolatedNetwork:IsInGuild(client)
    return self:IsInRoster(client, "guildClients")
end

function IsolatedNetwork:GetGroupMemberCount(client)
    if self:IsInRaid(client) then
        return #self.raidClients
    end
    if self:IsInInstance(client) then
        return #self.instanceClients
    end
    if self:IsInParty(client) then
        return #self.partyClients
    end

    return 0
end

-- Resolves the unit forms Questie comm code commonly asks about:
-- local player aliases, full AceComm sender names, and partyN/raidN tokens.
-- Instance-only groups reuse partyN-style resolution because Questie's group
-- lifecycle checks party1 while deciding whether an instance group is ready.
function IsolatedNetwork:ResolveUnit(localClient, unit)
    if unit == "player" or unit == "Player" or unit == localClient.playerName or unit == localClient.fullName then
        return localClient
    end

    local fullNameClient = self.clientsByFullName[unit]
    if fullNameClient then
        return fullNameClient
    end

    local partyIndex = tonumber(string.match(unit or "", "^party(%d+)$"))
    if partyIndex then
        local partyLikeClients = #self.partyClients > 0 and self.partyClients or self.instanceClients
        local remotePartyIndex = 0
        for _, rosterClient in ipairs(partyLikeClients) do
            if rosterClient ~= localClient then
                remotePartyIndex = remotePartyIndex + 1
                if remotePartyIndex == partyIndex then
                    return rosterClient
                end
            end
        end
    end

    local raidIndex = tonumber(string.match(unit or "", "^raid(%d+)$"))
    if raidIndex then
        return self.raidClients[raidIndex]
    end

    return nil
end

function IsolatedNetwork:IsClientInRoster(localClient, unit, rosterName)
    if unit == "player" then
        return self:IsInRoster(localClient, rosterName)
    end

    local rosterClient = self:ResolveUnit(localClient, unit)
    return rosterClient ~= nil and self:IsInRoster(rosterClient, rosterName)
end

function IsolatedNetwork:IsUnitConnected(localClient, unit)
    local rosterClient = self:ResolveUnit(localClient, unit)
    if rosterClient then
        return rosterClient.connected
    end

    return false
end

function IsolatedNetwork:IsPartyMember(localClient, fullName)
    local rosterClient = self.clientsByFullName[fullName]
    return rosterClient ~= nil and rosterClient ~= localClient and self:IsInParty(rosterClient) and self:IsInParty(localClient)
end

-------------------------
-- Addon-channel delivery.
-------------------------
-- Validate at the fake C_ChatInfo boundary, then deliver by distribution. This
-- catches impossible sends before they enter the network while still preserving
-- low-level trace evidence for valid sends whose targets later drop the prefix,
-- are offline, or otherwise disappear before receive-side callback dispatch.
---Validates the subset of addon prefix rules the fake C_ChatInfo boundary enforces.
---@param prefix any Candidate addon prefix.
---@return boolean valid True when the prefix can be registered or sent.
function IsolatedNetwork:IsValidAddonPrefix(prefix)
    return type(prefix) == "string" and prefix ~= "" and string.len(prefix) <= 16
end

---Resolves WHISPER targets the way same-realm Questie tests use them.
---Full sender names are exact; short names resolve only on the sender's realm.
---@param senderClient table Isolated client sending the whisper.
---@param target string Target name passed to C_ChatInfo.SendAddonMessage.
---@return table? targetClient Matching isolated client, if any.
function IsolatedNetwork:ResolveWhisperTarget(senderClient, target)
    local targetClient = self.clientsByFullName[target]
    if targetClient then
        return targetClient
    end

    if type(target) == "string" and not string.find(target, "-", 1, true) then
        for _, client in ipairs(self.clients) do
            if client.playerName == target and client.realmName == senderClient.realmName then
                return client
            end
        end
    end

    return nil
end

---Applies fake C_ChatInfo send validation before a message can enter trace/queue state.
---@param senderClient table Isolated client attempting the send.
---@param prefix any Addon prefix candidate.
---@param message any Addon message candidate.
---@param distribution string Requested AceComm distribution.
---@param target string? Optional WHISPER target.
---@return integer sendResult Enum.SendAddonMessageResult value from the sender environment.
function IsolatedNetwork:ValidateAddonSend(senderClient, prefix, message, distribution, target)
    local SendAddonMessageResult = senderClient.env.Enum.SendAddonMessageResult

    if not self:IsValidAddonPrefix(prefix) then
        return SendAddonMessageResult.InvalidPrefix
    end
    if type(message) ~= "string" or string.len(message) > 255 then
        return SendAddonMessageResult.InvalidMessage
    end
    if not senderClient.connected then
        return SendAddonMessageResult.GeneralError
    end

    if distribution == "WHISPER" then
        if not target or target == "" then
            return SendAddonMessageResult.TargetRequired
        end

        return SendAddonMessageResult.Success
    end

    if distribution == "PARTY" then
        return self:IsInParty(senderClient) and SendAddonMessageResult.Success or SendAddonMessageResult.NotInGroup
    end
    if distribution == "RAID" then
        return self:IsInRaid(senderClient) and SendAddonMessageResult.Success or SendAddonMessageResult.NotInGroup
    end
    if distribution == "INSTANCE_CHAT" then
        return self:IsInInstance(senderClient) and SendAddonMessageResult.Success or SendAddonMessageResult.NotInGroup
    end
    if distribution == "GUILD" then
        return self:IsInGuild(senderClient) and SendAddonMessageResult.Success or SendAddonMessageResult.NotInGuild
    end

    return SendAddonMessageResult.InvalidChatType
end

function IsolatedNetwork:GetBroadcastRecipients(envelope)
    if envelope.distribution == "PARTY" then
        return self.partyClients
    end
    if envelope.distribution == "RAID" then
        return self.raidClients
    end
    if envelope.distribution == "INSTANCE_CHAT" then
        return self.instanceClients
    end
    if envelope.distribution == "GUILD" then
        return self.guildClients
    end

    return {}
end

function IsolatedNetwork:DeliverAddonEnvelope(envelope, targetClient, distribution)
    -- Delivery filtering is intentionally later than send validation. A valid
    -- addon send can still vanish because the recipient is offline or has no
    -- local AceComm registration for that prefix.
    if not targetClient.connected or not targetClient.registeredAddonPrefixes[envelope.prefix] then
        return
    end

    targetClient:FireWoWEvent("CHAT_MSG_ADDON", envelope.prefix, envelope.message, distribution, envelope.sender.fullName)
end

function IsolatedNetwork:DeliverPendingAddonMessages()
    local pendingMessages = self.pendingMessages
    self.pendingMessages = {}

    for _, envelope in ipairs(pendingMessages) do
        if envelope.distribution == "WHISPER" then
            local targetClient = self:ResolveWhisperTarget(envelope.sender, envelope.target)
            if targetClient then
                self:DeliverAddonEnvelope(envelope, targetClient, "WHISPER")
            end
        else
            for _, targetClient in ipairs(self:GetBroadcastRecipients(envelope)) do
                if targetClient ~= envelope.sender then
                    self:DeliverAddonEnvelope(envelope, targetClient, envelope.distribution)
                end
            end
        end
    end
end

function IsolatedNetwork:RunDueTimers()
    local firedAnyTimer = false
    for _, client in ipairs(self.clients) do
        firedAnyTimer = client:RunDueTimers() or firedAnyTimer
    end

    return firedAnyTimer
end

function IsolatedNetwork:HasPendingTimers()
    for _, client in ipairs(self.clients) do
        for _, timer in ipairs(client.timers) do
            -- Future timers matter for lifecycle tests: GROUP_JOINED, AceBucket,
            -- and H1/V1 scheduling often enqueue work for a later fake timestamp.
            if not timer.cancelled then
                return true
            end
        end
    end

    return false
end

---Returns true while ChatThrottleLib still owns outbound work for any isolated client.
---FlushUntilIdle uses this in addition to timers and pending deliveries so large
---AceComm payloads cannot report idle before CTL has released every chunk.
---@return boolean pending True when AceComm/ChatThrottleLib queues still contain work.
function IsolatedNetwork:HasPendingAddonTraffic()
    for _, client in ipairs(self.clients) do
        local ChatThrottleLib = client.env.ChatThrottleLib
        if ChatThrottleLib and ChatThrottleLib.Prio then
            if ChatThrottleLib.bQueueing then
                return true
            end

            for _, priorityQueue in pairs(ChatThrottleLib.Prio) do
                if priorityQueue.Ring and priorityQueue.Ring.pos then
                    return true
                end
                if priorityQueue.Blocked and priorityQueue.Blocked.pos then
                    return true
                end
                if priorityQueue.ByName and next(priorityQueue.ByName) ~= nil then
                    return true
                end
            end
        end
    end

    return false
end

function IsolatedNetwork:PumpAddonTraffic(elapsed)
    for _, client in ipairs(self.clients) do
        client:PumpAddonTraffic(elapsed or 0.1)
    end
end

function IsolatedNetwork:AdvanceTime(seconds)
    self.clock = self.clock + (seconds or 0)
    for _, client in ipairs(self.clients) do
        client.clock = self.clock
    end

    return self:RunDueTimers()
end

-- Drives one deterministic event loop: timers, ChatThrottleLib/AceComm frame
-- updates, queued addon-channel delivery, then receive-side frame updates.
--
-- The idle check intentionally waits for future timers too. Group lifecycle code
-- chains ticker -> H1/V1 timer -> AceComm traffic, so returning while a later
-- timer still exists would make tests pass or fail based on helper timing rather
-- than production ordering.
function IsolatedNetwork:FlushUntilIdle(maxIterations)
    maxIterations = maxIterations or 50

    for _ = 1, maxIterations do
        local pendingBefore = #self.pendingMessages

        -- Advance first so delayed C_Timer/AceBucket work can become ready, then
        -- pump outgoing AceComm chunks through ChatThrottleLib before delivery.
        self:AdvanceTime(10)
        self:PumpAddonTraffic(0.1)
        self:DeliverPendingAddonMessages()

        -- Pump again after fake CHAT_MSG_ADDON delivery so receiver-side AceComm
        -- can reassemble chunks and invoke Questie callbacks in the same pass.
        self:PumpAddonTraffic(0.1)

        if pendingBefore == 0
            and #self.pendingMessages == 0
            and not self:RunDueTimers()
            and not self:HasPendingTimers()
            and not self:HasPendingAddonTraffic()
        then
            self:PumpAddonTraffic(0.1)
            if #self.pendingMessages == 0 and not self:HasPendingAddonTraffic() then
                return true
            end
        end
    end

    return false
end

function IsolatedNetwork:Flush()
    return self:FlushUntilIdle()
end

function IsolatedNetwork:FireAll(eventName, ...)
    for _, client in ipairs(self.clients) do
        client:FireWoWEvent(eventName, ...)
    end
end

function AceCommTestHarness.NewIsolatedNetwork()
    return setmetatable({
        clients = {},
        clientsByFullName = {},
        partyClients = {},
        raidClients = {},
        instanceClients = {},
        guildClients = {},
        pendingMessages = {},
        trace = {},
        clock = 100,
    }, IsolatedNetwork)
end

return AceCommTestHarness
