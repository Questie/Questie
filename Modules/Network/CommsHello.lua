--[[
QuestieH1 hello message, end-to-end:

    Decoded payload:
        {
            QuestieH1 = true,    -- this module registered the hello receiver
            questie = true,      -- legacy party quest-log comms receiver is active
            Questie = true,      -- daily quest availability comms receiver is active
            REPUTABLE = true,    -- legacy reputable daily receiver is active
        }

    Wire path:
        payload
            -> C_EncodingUtil.SerializeCBOR(payload)
            -> C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate)
            -> LibDeflate:EncodeForWoWAddonChannel(compressed)

    Send:
        Questie:SendCommMessage("QuestieH1", encodedPayload, "PARTY" | "RAID" | "INSTANCE_CHAT")

    Receive/store from "Friend-Realm":
        CommsHello.peerPrefixes["Friend-Realm"] = {
            QuestieH1 = true,
            questie = true,
            Questie = true,
            REPUTABLE = true,
        }

QuestieH1 only says which Questie prefixes a peer listens to or intentionally rejects.
The meaning of those prefixes lives in local code, not in the hello payload.

Known prefixes default to false, meaning this client knows the prefix contract but is not
currently listening/parsing it. The modules that actually register and parse a prefix mark
that prefix true after registering their own receiver, so disabled or sunset handlers naturally
advertise false without needing to keep this file in sync with deleted parser code.
]]
---@alias QuestieCommsPrefixState table<string, boolean>

---@class CommsHello : QuestieModule
local CommsHello = QuestieLoader:CreateModule("CommsHello")

-------------------------
-- Import modules.
-------------------------
---@type LibDeflate
local LibDeflate = QuestieLoader:ImportModule("LibDeflate")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

-------------------------
-- Protocol contract.
-------------------------
local HELLO_PREFIX = "QuestieH1"

-- Only prefixes defined here are meaningful to this client. Remote hello payloads are never allowed
-- to register or introduce new prefixes dynamically. False means the prefix contract is known, but
-- this client is not currently listening/parsing it.
---@type QuestieCommsPrefixState
local LOCAL_PREFIXES = {
    -- Hello module
    QuestieH1 = false,

    -- Modern comms modules
    -- (none yet)

    -- Legacy comms modules
    questie = false,
    Questie = false,

    -- Old Reputable module
    REPUTABLE = false,
}

CommsHello.prefix = HELLO_PREFIX

-- Peer state is keyed by the canonical comm sender exactly as AceComm gives it to us
-- (for example "Friend-Realm"). Do not strip realms here: same-name cross-realm players
-- must not collide, and GroupEventHandler prunes against the same full-name shape.
---@type table<string, QuestieCommsPrefixState>
CommsHello.peerPrefixes = CommsHello.peerPrefixes or {}
---@type table<string, number>
CommsHello.peerLastSeen = CommsHello.peerLastSeen or {}

local helloScheduled = false
local initialized = false
local undefinedPrefixWarnings = {}

-------------------------
-- Initialization.
-------------------------
---@return boolean
local function _HasCodecSupport()
    return C_EncodingUtil
        and C_EncodingUtil.SerializeCBOR
        and C_EncodingUtil.DeserializeCBOR
        and C_EncodingUtil.CompressString
        and C_EncodingUtil.DecompressString
        and Enum
        and Enum.CompressionMethod
        and Enum.CompressionMethod.Deflate ~= nil
        and Enum.CompressionLevel
        and Enum.CompressionLevel.Default ~= nil
        and LibDeflate
        and LibDeflate.EncodeForWoWAddonChannel
        and LibDeflate.DecodeForWoWAddonChannel
end

---@return boolean
function CommsHello:Initialize()
    if initialized then
        return true
    end

    if not _HasCodecSupport() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[CommsHello] Codec support unavailable, not registering QuestieH1")
        return false
    end

    Questie:RegisterComm(HELLO_PREFIX, CommsHello.OnCommReceived)
    CommsHello:RegisterLocalPrefix(HELLO_PREFIX)
    initialized = true
    return true
end

-------------------------
-- Sending hello.
-------------------------
---Builds the exact boolean map advertised in QuestieH1.
---@return QuestieCommsPrefixState
local function _BuildLocalPrefixMap()
    local prefixes = {}
    for prefix, active in pairs(LOCAL_PREFIXES) do
        prefixes[prefix] = active == true
    end

    return prefixes
end

---Serializes the modern-prefix payload into an addon-channel-safe string.
---@param payload table Plain Lua table accepted by Blizzard's CBOR serializer.
---@return string? encodedPayload Nil when serialization, compression, or channel encoding fails.
local function _Encode(payload)
    if not _HasCodecSupport() then
        return nil
    end

    local ok, encoded = pcall(function()
        local cbor = C_EncodingUtil.SerializeCBOR(payload)
        local compressed = C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.Default)
        return LibDeflate:EncodeForWoWAddonChannel(compressed)
    end)

    if ok then
        return encoded
    end

    return nil
end

---@return string?
local function _GetSendMode()
    local groupType = QuestiePlayer:GetGroupType()
    if groupType == "raid" then
        return "RAID"
    elseif groupType == "instance" then
        return "INSTANCE_CHAT"
    elseif groupType == "party" then
        return "PARTY"
    end

    return nil
end

---@return boolean
function CommsHello:SendHello()
    local mode = _GetSendMode()
    if not mode then
        return false
    end

    local message = _Encode(_BuildLocalPrefixMap())
    if not message then
        return false
    end

    Questie:SendCommMessage(HELLO_PREFIX, message, mode)
    return true
end

---Schedules a jittered hello so group roster events do not make every client speak at once.
---@param _reason string? Debug-only call-site label reserved for future logging.
---@return nil
function CommsHello:ScheduleHello(_reason)
    if helloScheduled then
        return
    end

    helloScheduled = true
    local function send()
        helloScheduled = false
        CommsHello:SendHello()
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(math.random() * 2, send)
    else
        send()
    end
end

-------------------------
-- Receiving hello.
-------------------------
---Decodes a QuestieH1 wire payload back into the untrusted remote prefix map.
---@param message string Addon-channel-safe payload received under QuestieH1.
---@return table? payload Nil when any decode stage fails or the decoded value is not a table.
local function _Decode(message)
    if not _HasCodecSupport() then
        return nil
    end

    local ok, decoded = pcall(function()
        local compressed = LibDeflate:DecodeForWoWAddonChannel(message)
        if not compressed then
            return nil
        end

        local cbor = C_EncodingUtil.DecompressString(compressed, Enum.CompressionMethod.Deflate)
        if not cbor then
            return nil
        end

        return C_EncodingUtil.DeserializeCBOR(cbor)
    end)

    if ok and type(decoded) == "table" then
        return decoded
    end

    return nil
end

---Returns true only for our own short name or normalized full name.
---This avoids dropping same-name players from other realms as if they were self echoes.
---@param sender string Full sender name, including realm when AceComm provided one.
---@return boolean
local function _IsSelf(sender)
    local playerName = UnitName("player")
    if sender == playerName then
        return true
    end

    local fullName
    if UnitFullName then
        local name, realm = UnitFullName("player")
        if name and realm and realm ~= "" then
            fullName = name .. "-" .. realm
        end
    end

    if not fullName and playerName and GetNormalizedRealmName then
        local realmName = GetNormalizedRealmName()
        if realmName and realmName ~= "" then
            fullName = playerName .. "-" .. realmName
        end
    end

    if not fullName and playerName and GetRealmName then
        local realmName = GetRealmName()
        if realmName and realmName ~= "" then
            fullName = playerName .. "-" .. realmName
        end
    end

    return fullName ~= nil and sender == fullName
end

---@param distribution string
---@param sender string Full sender name, including realm when AceComm provided one.
---@return boolean
local function _CanAcceptHello(distribution, sender)
    local allowedDistribution = distribution == "PARTY"
        or distribution == "RAID"
        or distribution == "INSTANCE_CHAT"
        or distribution == "WHISPER"
    local senderInGroup = UnitInParty(sender) or UnitInRaid(sender)

    return allowedDistribution and senderInGroup
end

---Copies only known boolean prefix states from an untrusted remote hello.
---@param payload table Decoded remote payload; unknown keys and non-booleans are ignored.
---@return QuestieCommsPrefixState prefixes Sanitized prefix map safe to store.
local function _SanitizePrefixMap(payload)
    local prefixes = {}
    for prefix in pairs(LOCAL_PREFIXES) do
        if type(payload[prefix]) == "boolean" then
            prefixes[prefix] = payload[prefix]
        end
    end

    return prefixes
end

---Accepts QuestieH1 only from current group members, including WHISPER senders.
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
---@return nil
function CommsHello.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= HELLO_PREFIX then
        return
    end

    if _IsSelf(sender) or not _CanAcceptHello(distribution, sender) then
        return
    end

    local payload = _Decode(message)
    if not payload then
        return
    end

    CommsHello.peerPrefixes[sender] = _SanitizePrefixMap(payload)
    CommsHello.peerLastSeen[sender] = GetTime()
end

-------------------------
-- Peer state and queries.
-------------------------

---@return nil
function CommsHello:ResetAll()
    wipe(CommsHello.peerPrefixes)
    wipe(CommsHello.peerLastSeen)
    helloScheduled = false
end

---Drops capability records for peers no longer present in the current group roster.
---@return nil
function CommsHello:PrunePeers()
    for playerName in pairs(CommsHello.peerPrefixes) do
        if not (UnitInParty(playerName) or UnitInRaid(playerName)) then
            CommsHello.peerPrefixes[playerName] = nil
            CommsHello.peerLastSeen[playerName] = nil
        end
    end
end

---@param playerName string
---@param prefix string
---@return boolean?
function CommsHello:GetPeerPrefixState(playerName, prefix)
    local peerPrefixes = CommsHello.peerPrefixes[playerName]
    if peerPrefixes then
        return peerPrefixes[prefix]
    end

    return nil
end

---@param playerName string
---@param prefix string
---@return boolean
function CommsHello:IsPeerListening(playerName, prefix)
    return self:GetPeerPrefixState(playerName, prefix) == true
end

---@param playerName string
---@param prefix string
---@return boolean
function CommsHello:DoesPeerRejectPrefix(playerName, prefix)
    return self:GetPeerPrefixState(playerName, prefix) == false
end

---Marks a known local prefix active after its receiver has registered with AceComm.
---Unknown prefixes are ignored so remote/local input cannot grow the protocol surface dynamically.
---@param prefix string
---@return boolean registered
function CommsHello:RegisterLocalPrefix(prefix)
    if LOCAL_PREFIXES[prefix] == nil then
        local prefixName = tostring(prefix)
        if not undefinedPrefixWarnings[prefixName] then
            undefinedPrefixWarnings[prefixName] = true
            C_Timer.After(5, function()
                Questie:Error("[CommsHello] A module tried to register undefined Questie comm prefix '" .. prefixName .. "'. Add it to the QuestieH1 prefix manifest before registering support.")
            end)
        end

        return false
    end

    LOCAL_PREFIXES[prefix] = true
    return true
end

---@param prefix string
---@return boolean?
function CommsHello:GetLocalPrefixState(prefix)
    return LOCAL_PREFIXES[prefix]
end
