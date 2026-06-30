--[[
QuestieH1 hello message, end-to-end:

    Decoded payload:
        {
            QuestieH1 = true,    -- this module registered the hello receiver
            QuestieV1 = true,    -- CommsVisibility registered the visibility receiver
            questie = true,      -- legacy party quest-log comms receiver is active
            Questie = true,      -- daily quest availability comms receiver is active
            REPUTABLE = true,    -- legacy reputable daily receiver is active
        }

    Wire path:
        payload
            -> CommsEncoding:EncodePayload(payload)

    Send:
        Questie:SendCommMessage("QuestieH1", encodedPayload, "PARTY" | "RAID" | "INSTANCE_CHAT")

    Receive/store from "Friend-Realm":
        CommsHello.peerPrefixes["Friend-Realm"] = {
            QuestieH1 = true,
            QuestieV1 = true,
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
---@type CommsEncoding
local CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
---@type CommsRouting
local CommsRouting = QuestieLoader:ImportModule("CommsRouting")
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
    QuestieV1 = false,

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

-- Timer
local helloTimer
local function _CancelHelloTimer()
    if helloTimer then
        helloTimer:Cancel()
        helloTimer = nil
    end
end

local initialized = false
local undefinedPrefixWarnings = {}

-------------------------
-- Initialization.
-------------------------
---@return boolean
function CommsHello:Initialize()
    if initialized then
        return true
    end

    if not CommsEncoding:HasCodecSupport() then
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



---@return boolean
function CommsHello:SendHello()
    local mode = CommsRouting:GetGroupBroadcastDistribution(QuestiePlayer:GetGroupType())
    if not mode then
        return false
    end

    local message = CommsEncoding:EncodePayload(_BuildLocalPrefixMap())
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
    -- Send with timer debounce.
    _CancelHelloTimer()

    helloTimer = C_Timer.NewTimer(math.random() * 2, function()
        helloTimer = nil
        CommsHello:SendHello()
    end)
end

-------------------------
-- Receiving hello.
-------------------------

---AceComm calls Ambiguate(sender, "none"), so our own sender is the short player name.
---@param sender string
---@return boolean
local function _IsSelf(sender)
    return sender == UnitName("player")
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

    local payload = CommsEncoding:DecodePayload(message)
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
    _CancelHelloTimer()
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
