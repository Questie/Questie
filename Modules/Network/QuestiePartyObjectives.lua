---@class QuestiePartyObjectives : QuestieModule
local QuestiePartyObjectives = QuestieLoader:CreateModule("QuestiePartyObjectives")
---@class QuestiePartyObjectivesPrivate
QuestiePartyObjectives.private = QuestiePartyObjectives.private or {}
-------------------------
--Import modules.
-------------------------
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

local NOP_FUNCTION = function() end

-- Beyond a 5-man group (party or 5-man dungeon) we stop drawing party objectives, to avoid
-- flooding the map with every raid member's quests.
local MAX_GROUP_SIZE = 5
-- Total ceiling on the number of party objective map-icons, independent of the per-objective
-- icon limit, so a crowded zone with a full group can't flood the map.
local MAX_PARTY_ICONS = 500
-- How many quests we redraw per frame when spreading a large refresh across frames.
local CHUNK_SIZE = 50
-- How many times we re-poll the client for a party member's quest objective data (for the
-- Blizzard objective text) before giving up, when it isn't cached yet on the first draw.
local MAX_PREFETCH_RETRIES = 5

-- The single-character objective types used in the QuestieComms packets, mapped to the
-- full type names used by the drawing pipeline and the database ObjectiveData.
local typeCharToFull = {
    ["m"] = "monster",
    ["o"] = "object",
    ["i"] = "item",
}

-- drawnByQuest[questId] = { objectives = { synthetic objective tables }, iconCount = number }
-- Tracked per quest so we can clear/redraw a single quest incrementally and account for the
-- icon budget.
local drawnByQuest = {}
-- spawnListCache[questId][objectiveIndex] = spawnList. Spawn data is static (DB + the
-- objective's icon, both constant per questId+objectiveIndex), so it is built once and reused.
local spawnListCache = {}
-- Running total of party map-icons currently drawn, compared against MAX_PARTY_ICONS.
local drawnIconCount = 0
-- prefetchedQuests[questId] = { attempts = number, pending = boolean }. Tracks our bounded poll
-- for a party member's quest objective data so a cache miss is retried a few times (not forever)
-- and only one retry timer is in flight per quest.
local prefetchedQuests = {}

-- Scheduling state.
local dirtyQuests = {}
local fullRefreshPending = false
local updateScheduled = false
local processing = false

-- Forward declarations (these reference each other).
local _ScheduleProcessing, _ProcessScheduled, _ProcessQueue

---@param questId number
---@return boolean @true if the local player currently has this quest in their log
local function _PlayerHasQuest(questId)
    return QuestLogCache.questLog_DO_NOT_MODIFY[questId] ~= nil
end

-- The objective needs a non-nil Description or the map icon tooltip skips it entirely
-- (see MapIconTooltip "iconData.ObjectiveData.Description" check). The compiled database
-- objective text is often empty, so fall back to the target's name.
---@param objType string
---@param objId number
---@return string?
local function _GetObjectiveName(objType, objId)
    if objType == "monster" then
        local npc = QuestieDB:GetNPC(objId)
        return npc and npc.name
    elseif objType == "object" then
        local object = QuestieDB:GetObject(objId)
        return object and object.name
    elseif objType == "item" then
        local item = QuestieDB:GetItem(objId)
        return item and item.name
    end
end

-- A flagged objective's database name is meaningless (kill-credit, event, etc.). The Blizzard API
-- returns the real objective text for quests we don't have, once the client has cached the quest
-- data (same pattern as Link.lua _AddQuestRequirements).
---@param questId number
---@param objectiveIndex number
---@return string?
local function _GetApiObjectiveText(questId, objectiveIndex)
    if not HaveQuestData(questId) then
        C_QuestLog.GetQuestObjectives(questId) -- prime the client cache
        -- The data arrives asynchronously and QUEST_DATA_LOAD_RESULT isn't available on Classic
        -- clients, so poll with a bounded number of delayed redraws until it's cached (a server
        -- round-trip can take a few seconds on login). One timer in flight per quest so multiple
        -- objectives don't multiply retries; gives up after MAX_PREFETCH_RETRIES so it can't loop.
        local state = prefetchedQuests[questId]
        if not state then
            state = { attempts = 0, pending = false }
            prefetchedQuests[questId] = state
        end
        if (not state.pending) and state.attempts < MAX_PREFETCH_RETRIES then
            state.pending = true
            C_Timer.After(1.5, function()
                state.pending = false
                state.attempts = state.attempts + 1
                QuestiePartyObjectives:ScheduleUpdate(questId)
            end)
        end
        return nil
    end
    local objectives = C_QuestLog.GetQuestObjectives(questId)
    local objective = objectives and objectives[objectiveIndex]
    local text = objective and objective.text
    if (not text) or text == "" then
        return nil
    end

    -- Strip the counter from the objective text; the tooltip prepends fulfilled/required separately
    return QuestieLib.GetFullObjectiveText(text) or text
end

-- The tooltips prefer FullDescription (the objective text including "slain", see
-- QuestieLib:GetObjectiveDescription), which QuestieQuest extracts from the local quest log
-- when trimObjectiveText is inactive. The local player does not have a party member's quest,
-- so rebuild the text from the client's own quest log format string for the objective type.
local objectiveTypePatterns = {
    monster = QUEST_MONSTERS_KILLED, -- "%s slain: %d/%d"
    item = QUEST_ITEMS_NEEDED,
    object = QUEST_OBJECTS_FOUND,
}

---@param objType string
---@param description string
---@return string?
local function _GetFullDescription(objType, description)
    if Questie.db.profile.trimObjectiveText or description == "" then
        return nil
    end
    local pattern = objectiveTypePatterns[objType]
    if not pattern then
        return nil
    end
    local rawText = string.format(pattern, description, 0, 0)

    return QuestieLib.GetFullObjectiveText(rawText)
end

---@return boolean
local function _ShouldDraw()
    return Questie.db.profile.showPartyQuestObjectives
        and QuestiePlayer:GetGroupType() ~= nil
        and GetNumGroupMembers() <= MAX_GROUP_SIZE
end

---@param name string
---@return boolean @true if the named party member is online
local function _IsPlayerOnline(name)
    -- UnitIsConnected accepts a group member's name (same pattern as QuestieComms:CheckInGroup,
    -- which calls UnitInParty/UnitInRaid by name). Returns falsy for offline or non-group names.
    return UnitIsConnected(name)
end

---@param objective table
---@return number @the number of map-icons this objective drew
local function _CountIcons(objective)
    local count = 0
    for _, spawn in pairs(objective.AlreadySpawned) do
        count = count + #spawn.mapRefs
    end
    return count
end

-- Unload an objective's icons. We only unload an icon if it still holds the exact data table
-- we drew it with: party icons are keyed by questId in QuestieMap.questIdFrames, the same key
-- the local player's own quest uses, so an icon may have already been unloaded and recycled.
-- _Qframe.Unload sets `data = nil` on unload, so unloaded/reused frames are skipped.
---@param objective table
local function _UnloadObjective(objective)
    for _, spawn in pairs(objective.AlreadySpawned) do
        for _, mapIcon in pairs(spawn.mapRefs) do
            if mapIcon.data == spawn.data then
                mapIcon:Unload()
            end
        end
        for _, minimapIcon in pairs(spawn.minimapRefs) do
            if minimapIcon.data == spawn.data then
                minimapIcon:Unload()
            end
        end
    end
end

---@param questId number
local function _ClearQuest(questId)
    local entry = drawnByQuest[questId]
    if not entry then
        return
    end
    for _, objective in pairs(entry.objectives) do
        _UnloadObjective(objective)
    end
    drawnIconCount = drawnIconCount - entry.iconCount
    drawnByQuest[questId] = nil
end

-- Draw a single party quest's objectives (assumes it has already been cleared).
---@param questId number
local function _DrawQuest(questId)
    -- Quests the local player has are drawn by the normal pipeline; don't double up.
    if _PlayerHasQuest(questId) or drawnIconCount >= MAX_PARTY_ICONS then
        return
    end

    local players = QuestieComms.remoteQuestLogs[questId]
    if not players then
        return
    end

    -- An objective index is drawn if at least one online party member still needs it. Offline
    -- members are ignored so their icons disappear until they reconnect.
    local neededIndices = {}
    for playerName, objectives in pairs(players) do
        if _IsPlayerOnline(playerName) then
            for objectiveIndex, objective in pairs(objectives) do
                if not objective.finished then
                    neededIndices[objectiveIndex] = objective
                end
            end
        end
    end
    if not next(neededIndices) then
        return
    end

    local quest = QuestieDB.GetQuest(questId)
    if not (quest and quest.ObjectiveData) then
        return
    end
    if not quest.Color then
        quest.Color = QuestieLib:ColorWheel()
    end

    local objectives = {}
    local iconCount = 0

    for objectiveIndex, remoteObjective in pairs(neededIndices) do
        if drawnIconCount + iconCount >= MAX_PARTY_ICONS then
            break
        end

        -- Prefer the database ObjectiveData (canonical Type/Id). It only misses an entry at this
        -- index when the party members' databases disagree (e.g. different Questie versions);
        -- in that case fall back to the comms data as a whole, to not mix the two sources.
        local objData = quest.ObjectiveData[objectiveIndex]
        local objType, objId
        if objData then
            objType = objData.Type
            objId = objData.Id
        else
            objType = typeCharToFull[remoteObjective.type]
            objId = remoteObjective.id
        end

        if objType and objId then
            local cachedSpawnList = spawnListCache[questId] and spawnListCache[questId][objectiveIndex]
            -- When the objective's live API type (first char, from comms) differs from the
            -- database's compiled type (kill-credit, events, invisible "bunny" NPCs), the id/type
            -- no longer map to a meaningful name, so use the Blizzard objective text and skip the
            -- name-based fallback. Derived here rather than transmitted so it works for every comms
            -- path, including the full quest list received on login/join.
            local useApiObjectiveText = objData ~= nil and remoteObjective.type ~= nil
                and string.sub(objData.Type, 1, 1) ~= remoteObjective.type
            local apiText = useApiObjectiveText and _GetApiObjectiveText(questId, objectiveIndex) or nil
            local description = apiText or (objData and objData.Text) or (not useApiObjectiveText and _GetObjectiveName(objType, objId)) or ""
            local objective = {
                Id = objId,
                Type = objType,
                Index = objectiveIndex,
                questId = questId,
                Description = description,
                FullDescription = (not useApiObjectiveText) and _GetFullDescription(objType, description) or nil,
                Icon = objData and objData.Icon,
                Completed = false,
                -- Pre-fill from cache so PopulateObjective skips rebuilding the spawn list.
                spawnList = cachedSpawnList or {},
                AlreadySpawned = {},
                Update = NOP_FUNCTION,
                -- Marks this as a party member's objective (the local player does not have the
                -- quest), so the map tooltip doesn't label it with the local player's name.
                IsPartyObjective = true,
                -- Skip in-world unit/item tooltip registration; the map icon tooltip already
                -- shows party members via QuestieComms, and this avoids leaking tooltip entries.
                hasRegisteredTooltips = true,
                registeredItemTooltips = true,
            }

            -- must be p-called (matches how QuestieQuest calls it internally)
            local ok, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, objectiveIndex, objective, true)
            if ok then
                local objectiveIconCount = _CountIcons(objective)
                if drawnIconCount + iconCount + objectiveIconCount > MAX_PARTY_ICONS then
                    _UnloadObjective(objective)
                    break
                end
                if (not cachedSpawnList) and objective.spawnList and next(objective.spawnList) then
                    if not spawnListCache[questId] then
                        spawnListCache[questId] = {}
                    end
                    spawnListCache[questId][objectiveIndex] = objective.spawnList
                end
                objectives[#objectives + 1] = objective
                iconCount = iconCount + objectiveIconCount
            else
                Questie:Debug(Questie.DEBUG_ELEVATED, "[QuestiePartyObjectives] Error populating party objective for quest", questId, "objective", objectiveIndex, err)
            end
        end
    end

    -- Also draw the quest's extra/special objectives (DB-defined, e.g. "use item" custom spawns
    -- and required source items). These come from QuestieDB.GetQuest, independent of comms data.
    local specialCounter = 0
    for _, special in pairs(quest.SpecialObjectives or {}) do
        if drawnIconCount + iconCount >= MAX_PARTY_ICONS then
            break
        end

        -- Always draw extras. RealObjectiveIndex is used loosely in the DB (it can be 0 or point
        -- past the real objectives), so we can't reliably tie an extra to a standard objective's
        -- completion for party members; matching Questie's own pipeline, we just draw them.
        specialCounter = specialCounter + 1
        local objective = {
            Id = special.Id,
            Type = special.Type,
            -- Offset past standard objective indices, matching PopulateQuestLogInfo.
            Index = 64 + specialCounter,
            questId = questId,
            Description = special.Description or "Special objective",
            Icon = special.Icon,
            Coordinates = special.Coordinates,
            Completed = false,
            -- Reuse the DB-built spawn list read-only; PopulateObjective builds it from
            -- Type/Id when absent (the required-source-item case).
            spawnList = special.spawnList or {},
            AlreadySpawned = {},
            Update = NOP_FUNCTION,
            IsPartyObjective = true,
            hasRegisteredTooltips = true,
            registeredItemTooltips = true,
        }

        local ok = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, objective.Index, objective, true)
        if ok then
            objectives[#objectives + 1] = objective
            iconCount = iconCount + _CountIcons(objective)
        end
    end

    if #objectives > 0 then
        drawnByQuest[questId] = { objectives = objectives, iconCount = iconCount }
        drawnIconCount = drawnIconCount + iconCount
    end
end

-- Process a queue of questIds in chunks, one chunk per frame, to avoid a single large hitch.
---@param queue number[]
---@param index number
_ProcessQueue = function(queue, index)
    local stop = math.min(index + CHUNK_SIZE - 1, #queue)
    for i = index, stop do
        local questId = queue[i]
        _ClearQuest(questId)
        _DrawQuest(questId)
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

    if not _ShouldDraw() then
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
        for questId in pairs(QuestieComms.remoteQuestLogs) do
            queue[#queue + 1] = questId
        end
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
    for _, entry in pairs(drawnByQuest) do
        for _, objective in pairs(entry.objectives) do
            _UnloadObjective(objective)
        end
    end
    drawnByQuest = {}
    drawnIconCount = 0
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

return QuestiePartyObjectives
