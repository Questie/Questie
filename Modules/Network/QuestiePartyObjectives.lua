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
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type CommsVisibility
local CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type GamepadMapHover
local GamepadMapHover = QuestieLoader:ImportModule("GamepadMapHover")
---@type MapIconTooltip
local MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")

local NOP_FUNCTION = function() end

-- Beyond a 5-man group (party or 5-man dungeon) we stop drawing party objectives, to avoid
-- flooding the map with every raid member's quests.
local MAX_GROUP_SIZE = 5
-- Total ceiling on the number of party objective map-icons, independent of the per-objective
-- icon limit, so a crowded zone with a full group can't flood the map.
local MAX_PARTY_ICONS = 500
-- How many quests we redraw per frame when spreading a large refresh across frames.
local CHUNK_SIZE = 10
-- How many icons are unloaded per frame, so clearing many party icons does not stall a single frame.
local ICONS_PER_FRAME = 50

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

-- Scheduling state.
local dirtyQuests = {}
local fullRefreshPending = false
local updateScheduled = false
local processing = false

-- Forward declarations (these reference each other).
local _ScheduleProcessing, _ProcessScheduled, _ProcessQueue

-- The objective needs a non-nil Description or the map icon tooltip skips it entirely
-- (see MapIconTooltip "iconData.ObjectiveData.Description" check). Provider objective text
-- is often empty, so fall back to the target's name.
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
                QuestieFramePool:UnloadFrame(mapIcon)
            end
        end
        for _, minimapIcon in pairs(spawn.minimapRefs) do
            if minimapIcon.data == spawn.data then
                QuestieFramePool:UnloadFrame(minimapIcon)
            end
        end
    end
end

-- Icons waiting to be unloaded, as {icon, data} pairs in the order they were queued.
local pendingUnloads = {}
local pendingUnloadCount = 0
local nextPendingUnload = 1
local unloadScheduled = false

local _UnloadPendingIcons

local function _ScheduleUnload()
    unloadScheduled = true
    C_Timer.After(0, function()
        unloadScheduled = false
        xpcall(_UnloadPendingIcons, CallErrorHandler)
        -- Also reached when an unload failed, so the queue is retired and the icons behind it still get unloaded
        if nextPendingUnload > pendingUnloadCount then
            pendingUnloads = {}
            pendingUnloadCount = 0
            nextPendingUnload = 1
        else
            _ScheduleUnload()
        end
    end)
end

_UnloadPendingIcons = function()
    local stop = math.min(nextPendingUnload + ICONS_PER_FRAME - 1, pendingUnloadCount)
    while nextPendingUnload <= stop do
        local pending = pendingUnloads[nextPendingUnload]
        nextPendingUnload = nextPendingUnload + 1
        -- Checked now rather than when queued, since the icon may have been recycled in between
        if pending[1].data == pending[2] then
            QuestieFramePool:UnloadFrame(pending[1])
        end
    end
end

-- Like _UnloadObjective, but spread over the next frames
---@param objective table
local function _UnloadObjectiveLater(objective)
    for _, spawn in pairs(objective.AlreadySpawned) do
        for _, mapIcon in pairs(spawn.mapRefs) do
            pendingUnloadCount = pendingUnloadCount + 1
            pendingUnloads[pendingUnloadCount] = {mapIcon, spawn.data}
        end
        for _, minimapIcon in pairs(spawn.minimapRefs) do
            pendingUnloadCount = pendingUnloadCount + 1
            pendingUnloads[pendingUnloadCount] = {minimapIcon, spawn.data}
        end
    end

    if (not unloadScheduled) and nextPendingUnload <= pendingUnloadCount then
        _ScheduleUnload()
    end
end

-- Whether every icon the entry adopted is still shown for it. The local player's own quest unloads all icons
-- of its quest id (QuestieMap:UnloadQuestFrames), party icons included, and empties their AlreadySpawned.
-- So the icons still shown are counted against the adopted count, like _CountIcons counted them.
---@param entry table
---@return boolean
local function _HasAllIcons(entry)
    local shownCount = 0
    for _, objective in pairs(entry.objectives) do
        for _, spawn in pairs(objective.AlreadySpawned) do
            for _, mapIcon in pairs(spawn.mapRefs) do
                if mapIcon.data ~= spawn.data then
                    return false
                end
                shownCount = shownCount + 1
            end
            for _, minimapIcon in pairs(spawn.minimapRefs) do
                if minimapIcon.data ~= spawn.data then
                    return false
                end
            end
        end
    end
    return shownCount == entry.iconCount
end

---@param questId number
local function _ClearQuest(questId)
    local entry = drawnByQuest[questId]
    if not entry then
        return
    end
    for _, objective in pairs(entry.objectives) do
        _UnloadObjectiveLater(objective)
    end
    drawnIconCount = drawnIconCount - entry.iconCount
    drawnByQuest[questId] = nil
end

---@param objectives table
---@return boolean
local function _AllFinished(objectives)
    if (not objectives[1]) then
        return false
    end
    for _, objective in pairs(objectives) do
        if (not objective.finished) then
            return false
        end
    end
    return true
end

-- Indices of the objectives online, visible party members reported, or nil if there is nothing to draw.
-- needed holds the unfinished ones, known every reported one (see the SpecialObjectives loop in _DrawQuest).
-- drawSpecials is false while the local player's own quest still draws the special objectives.
---@param questId number
---@return table? needed, table? known, boolean drawSpecials
local function _CollectIndices(questId)
    local players = QuestieComms.remoteQuestLogs[questId]
    if not players then
        return nil, nil, false
    end

    -- The local player's own quest draws the objectives they still need, so the party only adds the ones they
    -- finished already. Once their quest is complete it draws none of them anymore.
    local localEntry = QuestLogCache.questLog_DO_NOT_MODIFY[questId] -- DO NOT MODIFY THE RETURNED TABLE
    local localObjectives = localEntry and localEntry.objectives or {}
    -- A failed quest draws its quest giver instead, and Questie shows the finisher once every objective is finished,
    -- even before the game reports the quest complete. A sequenced quest shows its next stage instead (as in
    -- QuestieQuest:UpdateQuest), so all its visible objectives being finished does not end its own drawing.
    local localDrawsNothing = localEntry and (localEntry.isComplete == 1 or localEntry.isComplete == -1
        or ((not QuestieCompat.IsQuestSequenced(questId)) and _AllFinished(localObjectives)))
    -- Only objectives with ObjectiveData have a runtime objective, which the local quest draws icons for
    local localQuest = localEntry and (not localDrawsNothing) and QuestieDB.GetQuest(questId)
    local localMapped = localQuest and localQuest.Objectives or {}

    -- An objective index is drawn if at least one visible, online party member still needs it.
    -- Offline members disappear until they reconnect, and CommsVisibility can suppress members
    -- who hid or untracked the quest locally. knownIndices records every index online members
    -- reported (needed or not), so an extraObjective's hide-index can be told apart from a
    -- loose/out-of-range one (see the SpecialObjectives loop in _DrawQuest).
    local neededIndices = {}
    local knownIndices = {}
    for playerName, objectives in pairs(players) do
        if _IsPlayerOnline(playerName) and CommsVisibility:ShouldShowPartyObjective(playerName, questId) then
            for objectiveIndex, objective in pairs(objectives) do
                knownIndices[objectiveIndex] = true
                local localObjective = localObjectives[objectiveIndex]
                -- An objective the local quest has no row or no objective data for is not drawn by it either
                local drawnByLocalQuest = localEntry and (not localDrawsNothing) and localObjective and (not localObjective.finished)
                    and localMapped[objectiveIndex]
                if (not objective.finished) and (not drawnByLocalQuest) then
                    neededIndices[objectiveIndex] = objective
                end
            end
        end
    end
    if not next(neededIndices) then
        return nil, nil, false
    end
    return neededIndices, knownIndices, (not localEntry) or localDrawsNothing
end

-- Everything a quest's party icons depend on. Progress counts are left out on purpose: tooltips read them from
-- QuestieComms when they are shown, so a changed count needs no redraw, only a refresh of open tooltips.
---@param neededIndices table?
---@param knownIndices table?
---@param drawSpecials boolean
---@return string?
local function _GetDrawSignature(neededIndices, knownIndices, drawSpecials)
    if not neededIndices then
        return nil
    end
    local parts = {}
    for objectiveIndex, objective in pairs(neededIndices) do
        parts[#parts + 1] = objectiveIndex .. ":" .. tostring(objective.type) .. ":" .. tostring(objective.id)
    end
    for objectiveIndex in pairs(knownIndices) do
        parts[#parts + 1] = "k" .. objectiveIndex
    end
    -- No icons are drawn while the objectives are disabled, so a quest drawn then has to be drawn again after
    if Questie.db.profile.enableObjectives then
        parts[#parts + 1] = "o"
    end
    if drawSpecials then
        parts[#parts + 1] = "s"
    end
    table.sort(parts)
    return table.concat(parts, ",")
end

-- Draw a single party quest's objectives (assumes it has already been cleared).
---@param questId number
---@param neededIndices table
---@param knownIndices table
---@param drawSpecials boolean
---@param signature string
local function _DrawQuest(questId, neededIndices, knownIndices, drawSpecials, signature)
    if drawnIconCount >= MAX_PARTY_ICONS then
        return
    end

    local quest = QuestieDB.GetQuest(questId)
    if not (quest and quest.ObjectiveData) then
        return
    end
    if not quest.Color then
        quest.Color = QuestieLib:ColorWheel()
    end

    -- Register the entry before scheduling any drawing. PopulateObjective runs inside a coroutine
    -- whose first resume happens on a later frame, so the icons it draws must already be reachable
    -- from drawnByQuest by the time they appear, otherwise _ClearQuest/Clear can never unload them
    -- and the icons survive leaving a group.
    local entry = {objectives = {}, iconCount = 0, signature = signature}
    drawnByQuest[questId] = entry

    -- The quest may be cleared (or the group left) while a coroutine is queued or yielding.
    local function _IsStale()
        return drawnByQuest[questId] ~= entry or (not _ShouldDraw())
    end

    -- Draw one objective and adopt the icons it produced. The body is queued, not run here: it
    -- first resumes on a later frame, so everything it depends on is revalidated inside it.
    ---@param objective table @Synthetic party objective; PopulateObjective fills its AlreadySpawned
    ---@param objectiveIndex number @Index handed to PopulateObjective
    ---@param cacheSpawnListAt number? @Objective index to cache the built spawn list under; nil skips caching
    local function _ScheduleObjectiveDraw(objective, objectiveIndex, cacheSpawnListAt)
        ThreadLib.Thread(function()
            -- Nothing has been drawn yet, so an already-cleared quest can bail without cleanup.
            if _IsStale() then
                -- Dropped while still current (e.g. the group was briefly too large), so it must not be skipped later
                entry.signature = nil
                return
            end

            QuestieQuest:PopulateObjective(quest, objectiveIndex, objective, true)

            -- PopulateObjective yields, so re-check before adopting the icons it drew.
            if _IsStale() then
                entry.signature = nil
                _UnloadObjective(objective)
                return
            end

            -- The budget is global and only grows as objectives are adopted, so the check in the
            -- scheduling loop is already out of date by now and has to be repeated against the
            -- count this objective actually produced.
            local objectiveIconCount = _CountIcons(objective)
            if drawnIconCount + objectiveIconCount > MAX_PARTY_ICONS then
                _UnloadObjective(objective)
                -- Drawn incompletely, so the next update must not skip it
                entry.signature = nil
                return
            end

            -- Only standard objectives build a spawn list worth caching (see spawnListCache).
            if cacheSpawnListAt and objective.spawnList and next(objective.spawnList) then
                if not spawnListCache[questId] then
                    spawnListCache[questId] = {}
                end
                spawnListCache[questId][cacheSpawnListAt] = objective.spawnList
            end

            -- Commit point: past here the icons belong to the entry and count against the budget,
            -- so _ClearQuest/Clear can find and release them.
            entry.objectives[#entry.objectives + 1] = objective
            entry.iconCount = entry.iconCount + objectiveIconCount
            drawnIconCount = drawnIconCount + objectiveIconCount
        end, 0, nil, nil, function()
            -- Left incomplete, so a later update must draw the quest again, however releasing what it drew so far goes
            entry.signature = nil
            _UnloadObjective(objective)
        end)
    end

    -- Draw standard objectives using API wording, or database fallbacks if loading failed.
    -- Invoked from the loading callbacks only while entry is still the current draw.
    ---@param apiObjectives table?
    local function _DrawObjectives(apiObjectives)
        for objectiveIndex, remoteObjective in pairs(neededIndices) do
            if drawnIconCount + entry.iconCount >= MAX_PARTY_ICONS then
                entry.signature = nil
                break
            end

            -- Prefer the database ObjectiveData (canonical Type/Id). It only misses an entry at
            -- this index when the party members' databases disagree (e.g. different Questie
            -- versions); in that case fall back to the comms data as a whole, to not mix sources.
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
                -- Fetch the API text for this objective, if available.
                local apiObjective = apiObjectives and apiObjectives[objectiveIndex]
                local apiText
                if apiObjective then
                    apiText = QuestieLib.GetFullObjectiveText(apiObjective.text) or apiObjective.text
                    apiText = apiText ~= "" and apiText or nil
                end
                local dbText = objData and objData.Text
                local description = apiText or (dbText ~= "" and dbText) or _GetObjectiveName(objType, objId) or ""
                local objective = {
                    Id = objId,
                    Type = objType,
                    Index = objectiveIndex,
                    questId = questId,
                    Description = description,
                    -- Map tooltips replace the native counter with each remote player's progress.
                    NativeText = apiObjective and apiObjective.text,
                    Icon = objData and objData.Icon,
                    Completed = false,
                    -- Pre-fill from cache so PopulateObjective skips rebuilding the spawn list.
                    spawnList = cachedSpawnList or {},
                    AlreadySpawned = {},
                    Update = NOP_FUNCTION,
                    -- Marks this as a party member's objective (one the local player does not need), so the map
                    -- tooltip doesn't label it with the local player's name.
                    IsPartyObjective = true,
                    -- Skip in-world unit/item tooltip registration; the map icon tooltip already
                    -- shows party members via QuestieComms, and this avoids leaking tooltip entries.
                    hasRegisteredTooltips = true,
                    registeredItemTooltips = true,
                }

                -- Only ask for caching when this objective had no cached spawn list to start with.
                _ScheduleObjectiveDraw(objective, objectiveIndex, (not cachedSpawnList) and objectiveIndex or nil)
            end
        end
    end

    ---@param apiObjectives table?
    local function _DrawObjectivesOrInvalidate(apiObjectives)
        local ok, err = pcall(_DrawObjectives, apiObjectives)
        if not ok then
            -- Left incomplete, so a later update must draw the quest again
            entry.signature = nil
            error(err, 0)
        end
    end

    -- Matching types do not imply matching wording. Load API text for every objective,
    -- but never revive a draw that became stale while waiting.
    QuestieLib.ContinueOnQuestObjectivesLoad(questId, function(loadedObjectives)
        if _IsStale() then
            -- Dropped while still current (e.g. the group was too large), so a later update must draw it
            entry.signature = nil
            return
        end
        _DrawObjectivesOrInvalidate(loadedObjectives)
    end, function()
        -- Drawn with fallback wording or not at all, so the next update retries loading the API wording
        entry.signature = nil
        if not _IsStale() then
            _DrawObjectivesOrInvalidate(nil)
        end
    end)

    -- Also draw the quest's extra/special objectives (DB-defined, e.g. "use item" custom spawns
    -- and required source items). These come from QuestieDB.GetQuest, independent of comms data.
    for specialIndex, special in pairs(quest.SpecialObjectives or {}) do
        if drawnIconCount + entry.iconCount >= MAX_PARTY_ICONS then
            entry.signature = nil
            break
        end

        -- An extra tied to a standard objective follows it, as the local pipeline syncs an extraObjective's
        -- Completed from its RealObjectiveIndex (QuestieQuest:PopulateQuestLogInfo): it is drawn while that
        -- objective is needed here, which leaves out one the party finished and one the local quest draws itself.
        -- RealObjectiveIndex is used loosely in the DB (it can be 0 or point past the real objectives), so this
        -- only applies when it maps to an objective the party members actually reported. Any other extra is
        -- drawn by the local quest, unless that draws nothing anymore.
        local realIndex = special.RealObjectiveIndex
        local linked = realIndex and knownIndices[realIndex]
        local draw
        if linked then
            draw = neededIndices[realIndex] ~= nil
        else
            draw = drawSpecials
        end
        if draw then
            local objective = {
                Id = special.Id,
                Type = special.Type,
                -- Offset past standard objective indices, matching PopulateQuestLogInfo.
                Index = 64 + specialIndex,
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

            -- Special objectives reuse the DB-built spawn list, so there is nothing to cache.
            _ScheduleObjectiveDraw(objective, objective.Index, nil)
        end
    end
end

-- Process a queue of questIds in chunks, one chunk per frame, to avoid a single large hitch.
---@param queue number[]
---@param index number
_ProcessQueue = function(queue, index)
    local stop = math.min(index + CHUNK_SIZE - 1, #queue)
    for i = index, stop do
        local questId = queue[i]
        local neededIndices, knownIndices, drawSpecials = _CollectIndices(questId)
        local signature = _GetDrawSignature(neededIndices, knownIndices, drawSpecials)
        local entry = drawnByQuest[questId]
        -- Most updates only change progress counts, which leaves the icons as they are
        if not (signature and entry and entry.signature == signature and _HasAllIcons(entry)) then
            _ClearQuest(questId)
            if signature then
                local ok, err = pcall(_DrawQuest, questId, neededIndices, knownIndices, drawSpecials, signature)
                if not ok then
                    -- Left incomplete, so a later update must draw the quest again
                    local failed = drawnByQuest[questId]
                    if failed then
                        failed.signature = nil
                    end
                    error(err, 0)
                end
            end
        else
            -- The icons stay, so open tooltips would keep the progress they were built with
            MapIconTooltip.RefreshQuest(questId)
            if GamepadMapHover.RefreshQuest then
                GamepadMapHover.RefreshQuest(questId)
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
            _UnloadObjectiveLater(objective)
        end
    end
    drawnByQuest = {}
    drawnIconCount = 0
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
