--[[
QuestieH1 is the modern comms handshake. It does not describe features or packet
schemas; it only advertises which fixed Questie addon prefixes this client is
currently listening to.

    Decoded payload:
        {
            QuestieH1 = true,    -- this module registered the hello receiver
            QuestieV1 = true,    -- CommsVisibility registered the visibility receiver
            questie = true,      -- legacy party quest-log comms receiver is active
            Questie = true,      -- daily quest availability comms receiver is active
            REPUTABLE = true,    -- legacy reputable daily receiver is active
        }

    Wire path:
        payload -> CommsEncoding:EncodePayload(payload)

    Discovery pattern:
        * joining/reloading clients broadcast QuestieH1 to announce themselves;
        * receivers store that state and whisper their own QuestieH1 back;
        * whispered hellos are stored without answering to avoid ping-pong.

    Receive/store from "Friend-Realm":
        CommsHello.peerPrefixes["Friend-Realm"] = {
            QuestieH1 = true,
            QuestieV1 = true,
            questie = true,
            Questie = true,
            REPUTABLE = true,
        }

Known prefixes default to false. That means this client knows the prefix contract
but is not currently listening/parsing it. Owning modules mark prefixes true only
after registering their own receiver, so disabled or sunset handlers naturally
advertise false without letting remote payloads grow the protocol surface.
]]
---@alias QuestieCommsPrefixState table<string, boolean> Prefix -> listening state; false is an intentional local rejection/disabled state.

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

-- Local protocol manifest. This is the only place a prefix becomes meaningful to this
-- client; remote hello payloads are filtered through this table and can never register
-- or introduce prefixes dynamically.
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

-- Remote routing table for future modern comms. Keys intentionally use AceComm's sender
-- string (for example "Friend-Realm") so same-name cross-realm players do not collide,
-- and roster pruning compares against the same sender shape.
---@type table<string, QuestieCommsPrefixState>
CommsHello.peerPrefixes = CommsHello.peerPrefixes or {}
---@type table<string, number>
CommsHello.peerLastSeen = CommsHello.peerLastSeen or {}

-- Debounced outbound broadcast. Roster events can cluster during joins/reloads, so the
-- latest scheduled hello replaces any earlier pending one.
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
---The payload stays deliberately dumb: prefix names are the contract; meanings live in local code.
---@return QuestieCommsPrefixState
local function _BuildLocalPrefixMap()
    local prefixes = {}
    for prefix, active in pairs(LOCAL_PREFIXES) do
        prefixes[prefix] = active == true
    end

    return prefixes
end


---Broadcasts this client's current prefix state to the active group channel.
---@return boolean sent False when not grouped or when the payload cannot be encoded.
function CommsHello:SendHello()
    local distribution = CommsRouting:GetGroupBroadcastDistribution(QuestiePlayer:GetGroupType())
    if not distribution then
        return false
    end

    local message = CommsEncoding:EncodePayload(_BuildLocalPrefixMap())
    if not message then
        return false
    end

    Questie:SendCommMessage(HELLO_PREFIX, message, distribution)
    return true
end

---Schedules a jittered hello so group roster events do not make every client speak at once.
---The timer is cancellable; ResetAll cancels it when group state is cleared.
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

---Copies only known boolean prefix states from an untrusted remote hello.
---Unknown keys are ignored so remote clients cannot expand our known protocol set.
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

---Receives a peer's prefix state and performs first-contact convergence.
---Trust boundary: only grouped senders on group channels or WHISPER are accepted.
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
---@return nil
function CommsHello.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= HELLO_PREFIX then
        return
    end

    if CommsRouting:IsSelf(sender) or not CommsRouting:IsMessageFromGroupMember(distribution, sender) then
        return
    end

    local payload = CommsEncoding:DecodePayload(message)
    if not payload then
        return
    end

    -- Store peer state before replying so future modules can immediately route by prefix.
    CommsHello.peerPrefixes[sender] = _SanitizePrefixMap(payload)
    CommsHello.peerLastSeen[sender] = GetTime()

    -- A group-broadcast hello means the sender is announcing itself after a join/reload and
    -- needs our current state. Reply only to that sender so one hello does not cause a
    -- raid-wide response fanout. Whispered hellos are already targeted replies, so storing
    -- them without answering prevents ping-pong.
    if CommsRouting:GetGroupBroadcastDistribution(distribution) then
        local replyMessage = CommsEncoding:EncodePayload(_BuildLocalPrefixMap())
        if replyMessage then
            Questie:SendCommMessage(HELLO_PREFIX, replyMessage, "WHISPER", sender)
        end
    end
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
---QuestieH1 state is a routing cache, not durable player data.
---@return nil
function CommsHello:PrunePeers()
    for playerName in pairs(CommsHello.peerPrefixes) do
        if not (UnitInParty(playerName) or UnitInRaid(playerName)) then
            CommsHello.peerPrefixes[playerName] = nil
            CommsHello.peerLastSeen[playerName] = nil
        end
    end
end

---Returns true when the remote player advertised that they listen on this prefix.
---@param playerName string
---@param prefix string
---@return boolean
function CommsHello:IsPlayerListening(playerName, prefix)
    local peerPrefixes = CommsHello.peerPrefixes[playerName]
    return peerPrefixes and peerPrefixes[prefix] == true or false
end

---Returns true when the remote player advertised this known prefix as intentionally disabled.
---@param playerName string
---@param prefix string
---@return boolean
function CommsHello:DoesPlayerRejectPrefix(playerName, prefix)
    local peerPrefixes = CommsHello.peerPrefixes[playerName]
    return peerPrefixes and peerPrefixes[prefix] == false or false
end

---Marks a known local prefix active after its receiver has registered with AceComm.
---Undefined prefixes produce a delayed visible error because they indicate a local module/manifest mismatch.
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
