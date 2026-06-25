---@class QuestiePartyObjectives : QuestieModule
local QuestiePartyObjectives = QuestieLoader:CreateModule("QuestiePartyObjectives")
---@class QuestiePartyObjectivesPrivate
QuestiePartyObjectives.private = QuestiePartyObjectives.private or {}
-------------------------
--Import modules.
-------------------------
---@type PartyObjectivesGenerator
local PartyObjectivesGenerator = QuestieLoader:ImportModule("PartyObjectivesGenerator")
---@type PartyObjectiveDrawer
local PartyObjectiveDrawer = QuestieLoader:ImportModule("PartyObjectiveDrawer")

-- How many quests we redraw per frame when spreading a large refresh across frames.
local CHUNK_SIZE = 50

-- Scheduling state.
local dirtyQuests = {}
local fullRefreshPending = false
local updateScheduled = false
local processing = false

-- Forward declarations (these reference each other).
local _ScheduleProcessing, _ProcessScheduled, _ProcessQueue

-- Process a queue of questIds in chunks, one chunk per frame, to avoid a single large hitch.
-- The generator decides what should be drawn; the drawer performs the actual map calls.
---@param queue number[]
---@param index number
_ProcessQueue = function(queue, index)
    local stop = math.min(index + CHUNK_SIZE - 1, #queue)
    for i = index, stop do
        local questId = queue[i]
        PartyObjectiveDrawer:ClearQuest(questId)
        local plan = PartyObjectivesGenerator.BuildQuestPlan(questId)
        if plan then
            PartyObjectiveDrawer:DrawQuest(plan)
        end
    end

    if stop < #queue then
        C_Timer.After(0, function()
            local ok = xpcall(function()
                _ProcessQueue(queue, stop + 1)
            end, CallErrorHandler)
            if not ok then
                processing = false
            end
        end)
    else
        processing = false
        -- Work that arrived while we were processing.
        if fullRefreshPending or next(dirtyQuests) then
            _ScheduleProcessing()
        end
    end
end

_ProcessScheduled = function()
    if processing then
        _ScheduleProcessing()
        return
    end

    if not PartyObjectivesGenerator.ShouldDraw() then
        QuestiePartyObjectives:Clear()
        dirtyQuests = {}
        fullRefreshPending = false
        return
    end

    local queue = {}
    if fullRefreshPending then
        fullRefreshPending = false
        dirtyQuests = {}
        QuestiePartyObjectives:Clear()
        queue = PartyObjectivesGenerator.GetAllRemoteQuestIds()
    else
        for questId in pairs(dirtyQuests) do
            queue[#queue + 1] = questId
        end
        dirtyQuests = {}
    end

    if #queue == 0 then
        return
    end
    processing = true
    _ProcessQueue(queue, 1)
end

-- Debounce: coalesce bursts of incoming packets into a single processing pass.
_ScheduleProcessing = function()
    if updateScheduled then
        return
    end
    updateScheduled = true
    C_Timer.After(1.5, function()
        local ok = xpcall(function()
            updateScheduled = false
            _ProcessScheduled()
        end, CallErrorHandler)
        if not ok then
            updateScheduled = false
            processing = false
        end
    end)
end

-- Unload all party objective icons and forget them.
function QuestiePartyObjectives:Clear()
    PartyObjectiveDrawer:ClearAll()
end

-- Immediate full refresh, used by the options toggle.
function QuestiePartyObjectives:Update()
    fullRefreshPending = true
    _ProcessScheduled()
end

-- Schedule a debounced redraw. Pass a questId to redraw only that quest (incremental); pass
-- nothing to request a full refresh (e.g. a player left the group).
---@param questId number?
function QuestiePartyObjectives:ScheduleUpdate(questId)
    if not Questie.db.profile.showPartyQuestObjectives then
        return
    end
    if questId then
        dirtyQuests[questId] = true
    else
        fullRefreshPending = true
    end
    _ScheduleProcessing()
end

return QuestiePartyObjectives
