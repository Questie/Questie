---@class QuestiePartyObjectives : QuestieModule
local QuestiePartyObjectives = QuestieLoader:CreateModule("QuestiePartyObjectives")
---@class QuestiePartyObjectivesPrivate
QuestiePartyObjectives.private = QuestiePartyObjectives.private or {}
-------------------------
--Import modules.
-------------------------
---@type PartyObjectivesProvider
local PartyObjectivesProvider = QuestieLoader:ImportModule("PartyObjectivesProvider")
---@type PartyObjectiveDrawer
local PartyObjectiveDrawer = QuestieLoader:ImportModule("PartyObjectiveDrawer")

-- How many quests we redraw per frame when spreading a large refresh across frames.
local CHUNK_SIZE = 50
-- How many times we re-poll the client for a party member's quest objective data (for the Blizzard
-- objective text) before giving up, when the generator reports it isn't cached yet.
local MAX_PREFETCH_RETRIES = 5

-- Scheduling state.
local dirtyQuests = {}
local fullRefreshPending = false
local updateScheduled = false
local processing = false
-- prefetchedQuests[questId] = { attempts = number, pending = boolean }. Bounded poll for a party
-- member's quest objective data so a cache miss is retried a few times (not forever) and only one
-- retry timer is in flight per quest. Reset on a full clear so a fresh group starts over.
local prefetchedQuests = {}

-- Forward declarations (these reference each other).
local _ScheduleProcessing, _ProcessScheduled, _ProcessQueue

-- Schedule a bounded, delayed redraw for a quest whose Blizzard objective text wasn't cached yet
-- (the generator primed the client cache and flagged the plan). The data arrives asynchronously and
-- QUEST_DATA_LOAD_RESULT isn't available on Classic clients, so poll until it lands; one timer in
-- flight per quest, giving up after MAX_PREFETCH_RETRIES so it can't loop.
---@param questId number
local function _ScheduleApiRetry(questId)
    local state = prefetchedQuests[questId]
    if not state then
        state = { attempts = 0, pending = false }
        prefetchedQuests[questId] = state
    end
    if (not state.pending) and state.attempts < MAX_PREFETCH_RETRIES then
        state.pending = true
        C_Timer.After(1.5, function()
            xpcall(function()
                state.pending = false
                state.attempts = state.attempts + 1
                QuestiePartyObjectives:ScheduleUpdate(questId)
            end, CallErrorHandler)
        end)
    end
end

-- Process a queue of questIds in chunks, one chunk per frame, to avoid a single large hitch.
-- The generator decides what should be drawn; the drawer performs the actual map calls.
---@param queue number[]
---@param index number
_ProcessQueue = function(queue, index)
    local stop = math.min(index + CHUNK_SIZE - 1, #queue)
    for i = index, stop do
        local questId = queue[i]
        PartyObjectiveDrawer:ClearQuest(questId)
        local plan = PartyObjectivesProvider.BuildQuestPlan(questId)
        if plan then
            PartyObjectiveDrawer:DrawQuest(plan)
            if plan.needsApiRetry then
                _ScheduleApiRetry(questId)
            end
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

    if not PartyObjectivesProvider.ShouldDraw() then
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
        queue = PartyObjectivesProvider.GetAllRemoteQuestIds()
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
    prefetchedQuests = {}
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