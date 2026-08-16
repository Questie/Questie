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
-- No snapshot for a player means unknown. Within a stored full snapshot, omission means suppressed.

---@class CommsVisibility : QuestieModule
local CommsVisibility = QuestieLoader:CreateModule("CommsVisibility")

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
---@type QuestiePartyObjectives
local QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")

-------------------------
-- Protocol contract.
-------------------------
local VISIBILITY_PREFIX = "QuestieV1"
local MAX_VISIBILITY_GROUP_SIZE = 5
local MAX_SNAPSHOT_ENTRIES

CommsVisibility.prefix = VISIBILITY_PREFIX

-- remoteQuestVisibility["Friend-Realm"][questId] = true/false for party objective pins.
-- A missing player means unknown and defaults to shown for clients that do not speak QuestieV1.
-- Once a player's full snapshot is stored, omitted quest IDs are authoritatively suppressed.
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

---@return boolean
local function _CanSendVisibilitySnapshot()
    -- QuestieV1 only controls party objective pins, and those are only drawn for small groups.
    -- Avoid raid/BG/formation churn traffic where visibility snapshots cannot affect rendering.
    return GetNumGroupMembers() <= MAX_VISIBILITY_GROUP_SIZE
end

function CommsVisibility:Initialize()
    if initialized then
        return
    end

    if (not CommsEncoding.hasCodecSupport) then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[CommsVisibility] Codec support unavailable, not registering QuestieV1")
        return
    end

    MAX_SNAPSHOT_ENTRIES = C_QuestLog.GetMaxNumQuestsCanAccept()

    Questie:RegisterComm(VISIBILITY_PREFIX, CommsVisibility.OnCommReceived)
    initialized = true
end

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
--- accept/remove, hide/unhide, tracked/untracked, bulk tracker mode changes, profile changes,
--- and group convergence points such as roster changes or full quest-log responses.
---@param reason string? Debug-only call-site label reserved for future logging.
function CommsVisibility:ScheduleSnapshot(reason)
    Questie.Debug(Questie.DEBUG_INFO, "[CommsVisibility:ScheduleSnapshot] Reason", reason)

    -- Send with timer debounce.
    _CancelSnapshotTimer()

    if (not _CanSendVisibilitySnapshot()) then
        return
    end

    snapshotTimer = C_Timer.NewTimer(math.random() * 2, function()
        snapshotTimer = nil

        if (not _CanSendVisibilitySnapshot()) then
            return
        end

        local distribution = CommsRouting:GetGroupBroadcastDistribution(QuestiePlayer:GetGroupType())
        if (not distribution) then
            return
        end

        local message = CommsEncoding:EncodePayload(_BuildLocalSnapshot())
        if (not message) then
            return
        end

        Questie:SendCommMessage(VISIBILITY_PREFIX, message, distribution)
    end)
end

---Rejects the whole payload instead of sanitizing partial authoritative state.
---@param payload any Decoded remote payload.
---@return QuestieCommsVisibilitySnapshot? snapshot Complete validated snapshot safe to store.
local function _ValidateSnapshot(payload)
    if type(payload) ~= "table" then
        return nil
    end

    local count = 0
    for questId, visible in pairs(payload) do
        count = count + 1
        if count > MAX_SNAPSHOT_ENTRIES then
            return nil
        end

        if type(questId) ~= "number"
            or questId <= 0
            or questId % 1 ~= 0
            or type(visible) ~= "boolean"
        then
            return nil
        end
    end

    return payload
end

---Validates a complete V1 snapshot before atomically replacing the sender's prior state.
---@param prefix string
---@param message string
---@param distribution string
---@param sender string
function CommsVisibility.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= VISIBILITY_PREFIX then
        return
    end

    if CommsRouting:IsSelf(sender) or (not CommsRouting:IsMessageFromGroupMember(distribution, sender)) then
        return
    end

    local payload = CommsEncoding:DecodePayload(message)
    local snapshot = _ValidateSnapshot(payload)
    if (not snapshot) then
        return
    end

    -- Commit only after validating the complete payload. QuestieV1 is full-state only;
    -- omission suppresses that player's party pins and never edits remoteQuestLogs.
    CommsVisibility.remoteQuestVisibility[sender] = snapshot
    QuestiePartyObjectives:ScheduleUpdate()
end

---Returns the remote player's display intent for party objective pin rendering.
---Players without a snapshot default to shown for compatibility. Once a complete snapshot
---exists, only quests explicitly marked true are shown; false and omission are suppressed.
---This does not hide contextual tooltip progress; remoteQuestLogs remains visible there.
---@param playerName string
---@param questId QuestId
---@return boolean
function CommsVisibility:ShouldShowPartyObjective(playerName, questId)
    local visibility = CommsVisibility.remoteQuestVisibility[playerName]
    if (not visibility) then
        return true
    end

    return visibility[questId] == true
end

function CommsVisibility:ResetAll()
    wipe(CommsVisibility.remoteQuestVisibility)
    _CancelSnapshotTimer()
end

function CommsVisibility:PruneRemotePlayers()
    for playerName in pairs(CommsVisibility.remoteQuestVisibility) do
        if (not (UnitInParty(playerName) or UnitInRaid(playerName))) then
            CommsVisibility.remoteQuestVisibility[playerName] = nil
        end
    end
end
