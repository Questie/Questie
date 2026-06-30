--[[
QuestieV1 visibility message, end-to-end:

    Decoded payload:
        {
            [questId] = true,   -- this player wants party members to draw party objective pins for the quest
            [questId] = false,  -- this player wants party members to suppress party objective pins for the quest
        }

    Wire path:
        payload
            -> CommsEncoding:EncodePayload(payload)

QuestieV1 is a full snapshot of party-objective pin display intent. It is intentionally
separate from QuestieComms.remoteQuestLogs, which remains the absolute quest-log/progress
truth and can still feed contextual tooltip progress.
]]
---@alias QuestieCommsVisibilitySnapshot table<number, boolean> QuestId -> show party objective pins.
-- Missing quest IDs mean unknown and are treated as shown by readers.

---@class CommsVisibility : QuestieModule
local CommsVisibility = QuestieLoader:CreateModule("CommsVisibility")

-------------------------
-- Import modules.
-------------------------
---@type CommsEncoding
local CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
---@type CommsRouting
local CommsRouting = QuestieLoader:ImportModule("CommsRouting")
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
local MAX_VISIBILITY_GROUP_SIZE = 5

CommsVisibility.prefix = VISIBILITY_PREFIX

-- remoteQuestVisibility["Friend-Realm"][questId] = true/false for party objective pins.
-- Missing data means unknown and defaults to shown for backward compatibility with clients
-- that do not speak QuestieV1.
---@type table<string, QuestieCommsVisibilitySnapshot>
CommsVisibility.remoteQuestVisibility = CommsVisibility.remoteQuestVisibility or {}

-- Timer
local snapshotTimer
local function _CancelSnapshotTimer()
    if snapshotTimer then
        snapshotTimer:Cancel()
        snapshotTimer = nil
    end
end

local initialized = false

-------------------------
-- Send eligibility.
-------------------------
---@return boolean
local function _CanSendVisibilitySnapshot()
    -- QuestieV1 only controls party objective pins, and those are only drawn for small groups.
    -- Avoid raid/BG/formation churn traffic where visibility snapshots cannot affect rendering.
    return GetNumGroupMembers() <= MAX_VISIBILITY_GROUP_SIZE
end

-------------------------
-- Initialization.
-------------------------
---@return boolean
function CommsVisibility:Initialize()
    if initialized then
        return true
    end

    if not CommsEncoding:HasCodecSupport() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[CommsVisibility] Codec support unavailable, not registering QuestieV1")
        return false
    end

    Questie:RegisterComm(VISIBILITY_PREFIX, CommsVisibility.OnCommReceived)
    CommsHello:RegisterLocalPrefix(VISIBILITY_PREFIX)
    initialized = true
    return true
end

-------------------------
-- Sending visibility.
-------------------------
---@return QuestieCommsVisibilitySnapshot
local function _BuildLocalSnapshot()
    local snapshot = {}
    for questId in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do
        if type(questId) == "number" then
            -- Local policy: explicit Questie hidden state wins, otherwise party pins follow
            -- the tracker state. This is map/minimap UI intent, not quest-log truth.
            if Questie.db.char.hidden and Questie.db.char.hidden[questId] then
                snapshot[questId] = false
            else
                snapshot[questId] = QuestieQuest:IsQuestTracked(questId)
            end
        end
    end

    return snapshot
end

---Schedules a jittered full visibility snapshot. The full payload is tiny, so there is no
---incremental QuestieV1 update path.
---
--- Call this whenever local visibility policy can change for the current quest log: quest
--- accept/remove, hide/unhide, tracked/untracked, bulk tracker mode changes, and group
--- convergence points such as roster changes or full quest-log responses.
---@param _reason string? Debug-only call-site label reserved for future logging.
function CommsVisibility:ScheduleSnapshot(_reason)
    -- Send with timer debounce.
    _CancelSnapshotTimer()

    if not _CanSendVisibilitySnapshot() then
        return
    end

    snapshotTimer = C_Timer.NewTimer(math.random() * 2, function()
        snapshotTimer = nil

        if not _CanSendVisibilitySnapshot() then
            return
        end

        local distribution = CommsRouting:GetGroupBroadcastDistribution(QuestiePlayer:GetGroupType())
        if not distribution then
            return
        end

        local message = CommsEncoding:EncodePayload(_BuildLocalSnapshot())
        if not message then
            return
        end

        Questie:SendCommMessage(VISIBILITY_PREFIX, message, distribution)
    end)
end

-------------------------
-- Receiving visibility.
-------------------------
---@param payload table Decoded remote payload; invalid quest IDs and non-boolean values are ignored.
---@return QuestieCommsVisibilitySnapshot snapshot Sanitized snapshot safe to store.
local function _SanitizeSnapshot(payload)
    local snapshot = {}
    local acceptedQuestCount = 0

    -- Receive trust boundary: WoW quest logs are much smaller than this. The cap keeps
    -- hostile or malformed group payloads from growing unbounded while leaving room for
    -- future client-side quest-log changes.
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
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
function CommsVisibility.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= VISIBILITY_PREFIX then
        return
    end

    if CommsRouting:IsSelf(sender) or not CommsRouting:IsMessageFromGroupMember(distribution, sender) then
        return
    end

    local payload = CommsEncoding:DecodePayload(message)
    if not payload then
        return
    end

    -- Replace the remote player's whole snapshot. QuestieV1 is full-state only; a missing quest ID
    -- means unknown/default-show, not an instruction to edit QuestieComms.remoteQuestLogs.
    CommsVisibility.remoteQuestVisibility[sender] = _SanitizeSnapshot(payload)
    QuestiePartyObjectives:ScheduleUpdate()
end

-------------------------
-- Remote visibility state and queries.
-------------------------
---Returns the remote player's display intent for party objective pin rendering.
---Unknown remote players/quests default to shown so older clients keep existing behavior.
---This does not hide contextual tooltip progress; remoteQuestLogs remains visible there.
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

function CommsVisibility:ResetAll()
    wipe(CommsVisibility.remoteQuestVisibility)
    _CancelSnapshotTimer()
end

function CommsVisibility:PruneRemotePlayers()
    for playerName in pairs(CommsVisibility.remoteQuestVisibility) do
        if not (UnitInParty(playerName) or UnitInRaid(playerName)) then
            CommsVisibility.remoteQuestVisibility[playerName] = nil
        end
    end
end
