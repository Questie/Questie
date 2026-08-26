---@class GroupEventHandler
local GroupEventHandler = QuestieLoader:CreateModule("GroupEventHandler")

---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type CommsVisibility
local CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
---@type QuestiePartyObjectives
local QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
---@type DailyQuestComms
local DailyQuestComms = QuestieLoader:ImportModule("DailyQuestComms")

-- Snapshot of online/offline state for party members who have shared quests, used to decide
-- whether a GROUP_ROSTER_UPDATE actually requires a party-objective redraw.
local previousOnlineStatus = {}

-- GROUP_ROSTER_UPDATE fires for many reasons, including party members crossing zone boundaries.
-- Party objectives only need redrawing when a quest-sharing member goes online/offline or leaves,
-- so this prevents a constant full redraw while a group travels.
---@return boolean
local function _OnlineStatusChanged()
    local changed = false
    local current = {}
    for _, players in pairs(QuestieComms.remoteQuestLogs) do
        for name in pairs(players) do
            if current[name] == nil then
                local online = UnitIsConnected(name) and true or false
                current[name] = online
                if previousOnlineStatus[name] ~= online then
                    changed = true
                end
            end
        end
    end
    for name in pairs(previousOnlineStatus) do
        if current[name] == nil then
            changed = true -- a member who previously shared quests no longer does
        end
    end
    previousOnlineStatus = current
    return changed
end

function GroupEventHandler.GroupRosterUpdate()
    local currentMembers = GetNumGroupMembers()
    local sizeChanged = currentMembers ~= QuestiePlayer.numberOfGroupMembers
    QuestiePlayer.numberOfGroupMembers = currentMembers

    -- Evaluate unconditionally so the online snapshot stays current even when the size also changed.
    local onlineChanged = _OnlineStatusChanged()

    -- Since GroupRosterUpdate is bucketed, we prune on every event to keep the cache accurate.
    -- Otherwise same-size replacements might leave stale states.
    CommsVisibility:PruneRemotePlayers()

    -- Only resync visibility when group size or a quest-sharing member's online state changed.
    -- Pure zone changes also fire GROUP_ROSTER_UPDATE and must NOT trigger a redraw.
    if sizeChanged or onlineChanged then
        CommsVisibility:ScheduleSnapshot("GROUP_ROSTER_UPDATE")
        QuestiePartyObjectives:ScheduleUpdate()
    end
end

function GroupEventHandler.GroupJoined()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] GROUP_JOINED")
    local checkTimer
    --We want this to be fairly quick.
    checkTimer = C_Timer.NewTicker(0.2, function()
        local partyPending = UnitInParty("player")
        local isInParty = UnitInParty("party1")
        local isInRaid = UnitInRaid("raid1")
        if partyPending then
            if (isInParty or isInRaid) then
                Questie.Debug(Questie.DEBUG_DEVELOP, "[EventHandler] Player joined party/raid, ask for questlogs")
                CommsVisibility:ScheduleSnapshot("GROUP_JOINED")
                --Request other players log.
                Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
                -- Ask for unavailable daily quests, only in the current party/raid, not the guild.
                DailyQuestComms.RequestUnavailableDailyQuests(false)
                checkTimer:Cancel()
            end
        else
            Questie.Debug(Questie.DEBUG_DEVELOP, "[EventHandler] Player no longer in a party or pending invite. Cancel timer")
            checkTimer:Cancel()
        end
    end)
end

function GroupEventHandler.GroupLeft()
    --Resets both QuestieComms.remoteQuestLog and QuestieComms.data
    QuestieComms:ResetAll()
    CommsVisibility:ResetAll()
    QuestiePartyObjectives:Clear()
    previousOnlineStatus = {}
end
