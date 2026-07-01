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
-- Isolated two-client prototype.
-------------------------
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
        return client.clock
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

    env.C_ChatInfo = {
        RegisterAddonMessagePrefix = function(prefix)
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

    env.C_Timer = {
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

            client.timers[#client.timers + 1] = timer
            return timer
        end,
        After = function(_, callback)
            callback()
        end,
    }

    env.GetNumGroupMembers = function()
        return client.network.groupMemberCount
    end
    env.UnitName = function()
        return client.playerName
    end
    env.UnitFullName = function(unit)
        if unit == "player" then
            return client.playerName, client.realmName
        end
    end
    env.GetNormalizedRealmName = function()
        return client.realmName
    end
    env.GetRealmName = function()
        return client.realmName
    end
    env.UnitInParty = function(unit)
        return client.network:IsPartyMember(client, unit)
    end
    env.UnitInRaid = function()
        return false
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
    client:DoFile("Libs/AceComm-3.0/ChatThrottleLib.lua")
    client:DoFile("Libs/AceComm-3.0/AceComm-3.0.lua")

    env.LibStub("AceEvent-3.0"):Embed(env.Questie)
    env.LibStub("AceComm-3.0"):Embed(env.Questie)
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

function IsolatedClient:RunTimers()
    local timerCount = #self.timers
    for index = 1, timerCount do
        self.timers[index]:Fire()
    end
end

function IsolatedClient:FlushAddonTraffic()
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

function IsolatedClient:FireWoWEvent(eventName, ...)
    for _, frame in ipairs(self.frames) do
        if frame.registeredEvents[eventName] and frame.scripts.OnEvent then
            frame.scripts.OnEvent(frame, eventName, ...)
        end
    end
end

function IsolatedClient:LoadModernHelloStack()
    self:DoFile("setupTests.lua")
    _InstallIsolatedWowApi(self)
    _LoadIsolatedRealAce(self)
    _InstallIsolatedCompression(self)

    self.env.Questie.Debug = function() end
    self.env.Questie.Error = function(_, message)
        error(message)
    end

    self:DoFile("Modules/Network/CommsEncoding.lua")
    self:DoFile("Modules/Network/CommsRouting.lua")
    self:DoFile("Modules/Network/CommsPrefixRegistry.lua")

    local QuestiePlayer = self.env.QuestieLoader:ImportModule("QuestiePlayer")
    QuestiePlayer.GetGroupType = function() return "party" end

    self.CommsPrefixRegistry = self.env.QuestieLoader:ImportModule("CommsPrefixRegistry")
    self.CommsPrefixRegistry:Initialize()
    self.CommsPrefixRegistry:ResetAll()
end

function IsolatedNetwork:CreateClient(options)
    options = options or {}
    local client = setmetatable({}, IsolatedClient)
    client.network = self
    client.env = _NewIsolatedEnvironment()
    client.playerName = options.playerName or "Player"
    client.realmName = options.realmName or "HomeRealm"
    client.fullName = client.playerName .. "-" .. client.realmName
    client.clock = options.clock or 100
    client.frames = {}
    client.registeredAddonPrefixes = {}
    client.sentAddonMessages = {}
    client.timers = {}

    self.clients[#self.clients + 1] = client
    self.clientsByFullName[client.fullName] = client
    return client
end

function IsolatedNetwork:SetParty(clients)
    self.partyClients = clients or {}
    self.groupMemberCount = #self.partyClients
end

function IsolatedNetwork:IsPartyMember(localClient, fullName)
    for _, client in ipairs(self.partyClients) do
        if client ~= localClient and client.fullName == fullName then
            return true
        end
    end

    return false
end

function IsolatedNetwork:DeliverPendingAddonMessages()
    local pendingMessages = self.pendingMessages
    self.pendingMessages = {}

    for _, envelope in ipairs(pendingMessages) do
        if envelope.distribution == "WHISPER" then
            local targetClient = self.clientsByFullName[envelope.target]
            if targetClient and targetClient.registeredAddonPrefixes[envelope.prefix] then
                targetClient:FireWoWEvent("CHAT_MSG_ADDON", envelope.prefix, envelope.message, "WHISPER", envelope.sender.fullName)
            end
        else
            for _, targetClient in ipairs(self.partyClients) do
                if targetClient ~= envelope.sender and targetClient.registeredAddonPrefixes[envelope.prefix] then
                    targetClient:FireWoWEvent("CHAT_MSG_ADDON", envelope.prefix, envelope.message, envelope.distribution, envelope.sender.fullName)
                end
            end
        end
    end
end

function IsolatedNetwork:Flush()
    for _ = 1, 5 do
        for _, client in ipairs(self.clients) do
            client:RunTimers()
            client:FlushAddonTraffic()
        end

        if #self.pendingMessages == 0 then
            return
        end

        self:DeliverPendingAddonMessages()
    end
end

function AceCommTestHarness.NewIsolatedNetwork()
    return setmetatable({
        clients = {},
        clientsByFullName = {},
        partyClients = {},
        pendingMessages = {},
        trace = {},
        groupMemberCount = 0,
    }, IsolatedNetwork)
end

return AceCommTestHarness
