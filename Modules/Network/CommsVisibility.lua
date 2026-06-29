--[[
QuestieV1 visibility message, end-to-end:

    Decoded payload:
        {
            [questId] = true,   -- this player wants party members to draw objectives for the quest
            [questId] = false,  -- this player wants party members to suppress objectives for the quest
        }

    Wire path:
        payload
            -> C_EncodingUtil.SerializeCBOR(payload)
            -> C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate)
            -> LibDeflate:EncodeForWoWAddonChannel(compressed)

QuestieV1 is a full snapshot of display intent. It is intentionally separate from
QuestieComms.remoteQuestLogs, which remains the absolute quest-log/progress truth.
]]
---@alias QuestieCommsVisibilitySnapshot table<number, boolean> QuestId -> show party objectives.
-- Missing quest IDs mean unknown and are treated as shown by readers.

---@class CommsVisibility : QuestieModule
local CommsVisibility = QuestieLoader:CreateModule("CommsVisibility")

-------------------------
-- Import modules.
-------------------------
---@type LibDeflate
local LibDeflate = QuestieLoader:ImportModule("LibDeflate")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type CommsHello
local CommsHello = QuestieLoader:ImportModule("CommsHello")
---@type QuestiePartyObjectives
local QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")

-------------------------
-- Protocol contract.
-------------------------
local VISIBILITY_PREFIX = "QuestieV1"
local MAX_VISIBILITY_SNAPSHOT_QUESTS = 50

CommsVisibility.prefix = VISIBILITY_PREFIX

-- remoteQuestVisibility["Friend-Realm"][questId] = true/false. Missing data means unknown and
-- defaults to shown for backward compatibility with clients that do not speak QuestieV1.
---@type table<string, QuestieCommsVisibilitySnapshot>
CommsVisibility.remoteQuestVisibility = CommsVisibility.remoteQuestVisibility or {}

local snapshotScheduled = false
local initialized = false

-------------------------
-- Codec.
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

---@param message string Addon-channel-safe payload received under QuestieV1.
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

-------------------------
-- Group/send helpers.
-------------------------
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

---Returns true only for our own short name or normalized full name.
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
local function _CanAcceptVisibility(distribution, sender)
    local allowedDistribution = distribution == "PARTY"
        or distribution == "RAID"
        or distribution == "INSTANCE_CHAT"
        or distribution == "WHISPER"
    local senderInGroup = UnitInParty(sender) or UnitInRaid(sender)

    return allowedDistribution and senderInGroup
end

---@param payload table Decoded remote payload; invalid quest IDs and non-boolean values are ignored.
---@return QuestieCommsVisibilitySnapshot snapshot Sanitized snapshot safe to store.
local function _SanitizeSnapshot(payload)
    local snapshot = {}
    local acceptedQuestCount = 0

    -- WoW quest logs are much smaller than this. The cap keeps hostile or malformed group
    -- payloads from growing unbounded while leaving room for future client-side quest-log changes.
    for questId, visible in pairs(payload) do
        if acceptedQuestCount >= MAX_VISIBILITY_SNAPSHOT_QUESTS then
            break
        end

        if type(questId) == "number" and questId > 0 and questId % 1 == 0 and type(visible) == "boolean" then
            snapshot[questId] = visible
            acceptedQuestCount = acceptedQuestCount + 1
        end
    end

    return snapshot
end

-------------------------
-- Initialization.
-------------------------
---@return boolean
function CommsVisibility:Initialize()
    if initialized then
        return true
    end

    if not _HasCodecSupport() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[CommsVisibility] Codec support unavailable, not registering QuestieV1")
        return false
    end

    Questie:RegisterComm(VISIBILITY_PREFIX, CommsVisibility.OnCommReceived)
    CommsHello:RegisterLocalPrefix(VISIBILITY_PREFIX)
    initialized = true
    return true
end

-------------------------
-- Local snapshot.
-------------------------
---Computes the local display intent that is shared with party members.
---This is deliberately UI intent, not quest-log membership or progress truth.
---@param questId QuestId
---@return boolean
local function _ShouldShowQuestToParty(questId)
    if Questie.db.char.hidden and Questie.db.char.hidden[questId] then
        return false
    end

    return QuestieQuest:IsQuestTracked(questId)
end

---@return QuestieCommsVisibilitySnapshot
function CommsVisibility:BuildLocalSnapshot()
    local snapshot = {}
    for questId in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do
        if type(questId) == "number" then
            snapshot[questId] = _ShouldShowQuestToParty(questId)
        end
    end

    return snapshot
end

---@return boolean
function CommsVisibility:SendSnapshot()
    local mode = _GetSendMode()
    if not mode then
        return false
    end

    local message = _Encode(CommsVisibility:BuildLocalSnapshot())
    if not message then
        return false
    end

    Questie:SendCommMessage(VISIBILITY_PREFIX, message, mode)
    return true
end

---Schedules a jittered full visibility snapshot. The full payload is tiny, so there is no
---incremental QuestieV1 update path.
---
--- Call this whenever local visibility policy can change for the current quest log: quest
--- accept/remove, hide/unhide, tracked/untracked, bulk tracker mode changes, and group
--- convergence points such as roster changes or full quest-log responses.
---@param _reason string? Debug-only call-site label reserved for future logging.
---@return nil
function CommsVisibility:ScheduleSnapshot(_reason)
    if snapshotScheduled then
        return
    end

    snapshotScheduled = true
    local function send()
        snapshotScheduled = false
        CommsVisibility:SendSnapshot()
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(math.random() * 2, send)
    else
        send()
    end
end

-------------------------
-- Receiving visibility.
-------------------------
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
---@return nil
function CommsVisibility.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= VISIBILITY_PREFIX then
        return
    end

    if _IsSelf(sender) or not _CanAcceptVisibility(distribution, sender) then
        return
    end

    local payload = _Decode(message)
    if not payload then
        return
    end

    -- Replace the peer's whole snapshot. QuestieV1 is full-state only; a missing quest ID
    -- means unknown/default-show, not an instruction to edit QuestieComms.remoteQuestLogs.
    CommsVisibility.remoteQuestVisibility[sender] = _SanitizeSnapshot(payload)
    QuestiePartyObjectives:ScheduleUpdate()
end

-------------------------
-- Peer state and queries.
-------------------------
---Returns the remote player's display intent for party objective rendering.
---Unknown peers/quests default to shown so older clients keep existing behavior.
---@param playerName string
---@param questId QuestId
---@return boolean
function CommsVisibility:ShouldShowPartyObjective(playerName, questId)
    local visibility = CommsVisibility.remoteQuestVisibility[playerName]
    if not visibility or visibility[questId] == nil then
        return true
    end

    return visibility[questId]
end

---@return nil
function CommsVisibility:ResetAll()
    wipe(CommsVisibility.remoteQuestVisibility)
    snapshotScheduled = false
end

---@return nil
function CommsVisibility:PrunePeers()
    for playerName in pairs(CommsVisibility.remoteQuestVisibility) do
        if not (UnitInParty(playerName) or UnitInRaid(playerName)) then
            CommsVisibility.remoteQuestVisibility[playerName] = nil
        end
    end
end
