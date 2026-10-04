---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

--- Contains last known valid state of each quest in game's quest log, per quest.
--- I.E. All data related to a quest is valid.
--- Includes a "hack" to have correct objectives' progress while quest isComplete = 1. Otherwise it would need to be done everywhere else in code
---@class QuestLogCache
local QuestLogCache = QuestieLoader:CreateModule("QuestLogCache")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type Sounds
local Sounds = QuestieLoader:ImportModule("Sounds")
---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

local GetQuestLogTitle, C_QuestLog_GetQuestObjectives = QuestieCompat.GetQuestLogTitle, C_QuestLog.GetQuestObjectives

-- 3 * (Max possible number of quests in game quest log)
-- This is a safe value, even smaller would be enough. Too large won't effect performance
local MAX_QUEST_LOG_INDEX = 75

--[[
Example of data in cache table.
text contains Blizzard's accepted wording unchanged, including any progress counters.
Only progress and completion have raw_* counterparts alongside normalized values.

local cache = {
    [questId] = {
        title = "Quest name",
        questTag = "Dungeon", -- nil, "Dungeon", "Raid", etc.
        isComplete = nil,
        objectives = {
            {
                type = "monster",
                finished = false,
                numFulfilled = 2,
                numRequired = 3,
                text = "Objective Text slain: 2/3",
                raw_finished = false
                raw_numFulfilled = 2,
            },
            {
                type = "item",
                finished = false,
                numFulfilled = 0,
                numRequired = 5,
                text = "Objective2 : 0/5",
                raw_finished = false,
                raw_numFulfilled = 0,
            },
            ....
        },
    [questId2] = ....,
}
]]--


---@class QuestLogCacheObjectiveData
---@field type "monster"|"object"|"item"|"reputation"|"killcredit"|"event"|"spell"|string Includes client objective types unknown to Questie.
---@field finished boolean
---@field numFulfilled number
---@field numRequired number
---@field text string Accepted native wording, unchanged; e.g. "Objective Text slain: 2/3".
---@field raw_finished boolean
---@field raw_numFulfilled number

---@class QuestLogCacheData
---@field title string
---@field questTag QuestTag
---@field isComplete -1|0|1 @ -1 = failed, 0 = not complete, 1 = complete
---@field objectives QuestLogCacheObjectiveData[]


---@type table<QuestId, QuestLogCacheData>
local cache = {}
local questCount = 0

-- Loading screens can temporarily lower objective counts. Protect each cached quest until its own
-- valid, non-regressing snapshot arrives, so an unavailable quest cannot freeze another quest's item decreases.
---@type table<QuestId, boolean>
local questsAwaitingRecovery = {}

--- NEVER EVER EDIT this table outside of the QuestLogCache module!  !!!
---@type table<QuestId, QuestLogCacheData>
QuestLogCache.questLog_DO_NOT_MODIFY = cache


---@param questId QuestId
---@param oldObjectives QuestLogCacheObjectiveData[]
---@param isCompleteAccordingToBlizzard number @ -1 = failed, nil = not complete, 1 = complete
---@param suppressRegressions boolean @ when true, treat numFulfilled decreases as cache misses (zone transition)
---@return table? newObjectives, ObjectiveIndex[] changedObjIds, isComplete, boolean needsRetry @Nil objectives or retained placeholder rows need another scan.
local function GetNewObjectives(questId, oldObjectives, isCompleteAccordingToBlizzard, suppressRegressions)
    local newObjectives = {} -- creating a fresh one to be able revert to old easily in case of missing data
    local changedObjIds -- not assigning {} for easier nil when nothing changed
    local allObjectivesFinished = true -- default to true for easier handling
    local needsRetry = false
    local objectives = C_QuestLog_GetQuestObjectives(questId)
    if not objectives then
        return nil, nil, isCompleteAccordingToBlizzard, false
    end

    -- HaveQuestData can be true before individual rows have their type. Validate before processing
    -- progress so a rejected snapshot cannot play sounds on each retry. Empty text rows are
    -- intentionally omitted below, preserving the existing client workaround.
    for _, objective in ipairs(objectives) do
        if not objective.type and objective.text ~= "" then
            return nil, nil, isCompleteAccordingToBlizzard, false
        end
    end

    for objIndex=1, #objectives do -- iterate manually to be sure getting those in order
        local oldObj = oldObjectives[objIndex]
        local newObj = objectives[objIndex]

        if QuestieLib.IsObjectiveDataLoaded(newObj) then
            if (newObj.text ~= "") then -- Some quests have empty objectives, which shouldn't exist in the first place - We skip those
                -- Check if objective has changed
                if oldObj and oldObj.raw_numFulfilled == newObj.numFulfilled and oldObj.text == newObj.text and oldObj.raw_finished == newObj.finished and oldObj.numRequired == newObj.numRequired and oldObj.type == newObj.type then
                    -- Not changed
                    newObjectives[objIndex] = oldObj
                    allObjectivesFinished = allObjectivesFinished and oldObj.finished -- if any objective is not finished, whole quest is not complete
                else
                    -- Detect a regression: numFulfilled went down from what we had cached.
                    -- During zone transitions Blizzard temporarily returns stale (lower) objective counts
                    -- while it rebuilds its cache. We suppress these as cache misses so no sounds or
                    -- announces fire. Outside of zone transitions, all decreases are legitimate
                    -- (e.g. banking items, deleting items, using consumable quest items) and accepted.
                    if oldObj and newObj.numFulfilled < oldObj.raw_numFulfilled then
                        if suppressRegressions then
                            return nil, nil, isCompleteAccordingToBlizzard, true
                        end
                        -- not a zone transition — fall through and accept the decrease
                    end

                    -- objective has changed, add it to list of change ones
                    if (not changedObjIds) then
                        changedObjIds = { objIndex }
                    else
                        changedObjIds[#changedObjIds+1] = objIndex
                    end

                    if oldObj and newObj and oldObj.numRequired ~= oldObj.numFulfilled and newObj.numRequired == newObj.numFulfilled then
                        Sounds.PlayObjectiveComplete()
                    end

                    if oldObj and newObj and oldObj.numRequired ~= oldObj.numFulfilled and newObj.numRequired ~= newObj.numFulfilled and newObj.numFulfilled > oldObj.raw_numFulfilled then
                        Sounds.PlayObjectiveProgress()
                    end

                    allObjectivesFinished = allObjectivesFinished and newObj.finished -- if any objective is not finished, whole quest is not complete

                    newObjectives[objIndex] = {
                        text = newObj.text,
                        raw_finished = newObj.finished,
                        raw_numFulfilled = newObj.numFulfilled,
                        type = newObj.type,
                        numRequired = newObj.numRequired,
                        finished = newObj.finished, -- gets overwritten with correct value later if quest isComplete
                        numFulfilled = newObj.numFulfilled, -- gets overwritten with correct value later if quest isComplete
                    }
                end
            end
        else -- objective text not in game's cache
            if oldObj then
                needsRetry = true
                Questie.Debug(Questie.DEBUG_INFO, "[GetNewObjectives] objective not in game's cache. Using addon's cache. questID, objIndex:", questId, objIndex)
                -- Extremely unlikely that the objective has changed from cached version as a change SHOULD trigger fetching data into game cache.
                -- Possible bug point if there comes desync issues.
                newObjectives[objIndex] = oldObj
                allObjectivesFinished = allObjectivesFinished and oldObj.finished -- if any objective is not finished, whole quest is not complete
            else
                Questie.Debug(Questie.DEBUG_INFO, "[GetNewObjectives] \"WARNING\" objective not in game's cache nor addon's cache. questID, objIndex:", questId,
                    objIndex)
                -- Objective has been never cached
                -- Tell to function caller that we couldn't get all required data from game's cache
                -- Don't loop rest of objectives as we won't anyway save those into cache[] and C_QuestLog.GetQuestObjectives() call already triggered game to initiate caching those into game's cache.
                return nil, nil, isCompleteAccordingToBlizzard, false
            end
        end
    end

    local isComplete = isCompleteAccordingToBlizzard
    if (not isCompleteAccordingToBlizzard) then
        -- A finished visible stage is not a finished sequenced quest. Premature completion would also
        -- make the recovery guard reject the next stage. Keep the legacy empty-row workaround otherwise.
        isComplete = (not QuestieCompat.IsQuestSequenced(questId)) and allObjectivesFinished and 1 or 0
    end

    return newObjectives, changedObjIds, isComplete, needsRetry
end

-- For profiling
QuestLogCache._GetNewObjectives = GetNewObjectives

--- Updates questlogcache.
--- Remember to handle returned changes table even when cacheMiss == true. Returned changes are still valid. There may just be more changes that we couldn't get yet.
--- Called only from QuestEventHandler.
---@param questIdsToCheck table? @keys are the questIds
---@return boolean cacheMiss, table changes, table questIdsChecked @cacheMiss = couldn't get all required data  ; changes[questId] = list of changed objectiveIndexes (may be an empty list if quest has no objectives)
function QuestLogCache.CheckForChanges(questIdsToCheck)
    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestLogCache.CheckForChanges]")

    local cacheMiss = false
    local changes = {} -- table key = questid of the changed quest, table value = list of changed objective ids
    local questIdsChecked = {} -- for debug / error detection

    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        ----- title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questLogIndex)

        local title, _, questTag, isHeader, _, isCompleteAccordingToBlizzard, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) and ((not questIdsToCheck) or questIdsToCheck[questId]) then -- check all quests if no list what to check, otherwise just ones in the list
            ---@cast questId number
            questIdsChecked[questId] = true

            if HaveQuestData(questId) then
                local cachedQuest = cache[questId]
                local cachedObjectives = cachedQuest and cachedQuest.objectives or {}

                -- During zone transitions (e.g. entering/leaving a dungeon) GetQuestLogTitle temporarily
                -- returns incorrect values (e.g. isCompleteAccordingToBlizzard being nil for quests that are actually complete and objective
                -- numFulfilled being 0 instead of what the player actually has).
                -- To avoid caching incorrect values, we skip the update entirely and set cacheMiss so we retry next QUEST_LOG_UPDATE.
                local blizzardCacheIncorrect = (not isCompleteAccordingToBlizzard) and cachedQuest and cachedQuest.isComplete == 1
                if blizzardCacheIncorrect then
                    cacheMiss = true
                else
                    local suppressRegressions = questsAwaitingRecovery[questId] == true
                    local newObjectives, changedObjIds, isComplete, needsRetry = GetNewObjectives(questId, cachedObjectives, isCompleteAccordingToBlizzard, suppressRegressions)
                    cacheMiss = cacheMiss or needsRetry

                    if newObjectives then
                        -- Unchanged valid data confirms recovery too; retained placeholder rows do not.
                        if not needsRetry then
                            questsAwaitingRecovery[questId] = nil
                        end
                        if (not cachedQuest) or cachedQuest.isComplete ~= isComplete then
                            -- Publish completion changes even when the final stage removes objective rows.
                            -- An empty change list still notifies consumers of the new quest-wide status.
                            changedObjIds = {}
                            -- Empty native rows are omitted. Preserve sparse indices in ordered notifications.
                            for index, objective in pairs(newObjectives) do
                                changedObjIds[#changedObjIds + 1] = index
                                if isComplete == 1 then
                                    -- Event objectives can remain unfinished when the whole quest is complete.
                                    objective.finished = true
                                    objective.numFulfilled = objective.numRequired
                                end
                            end
                            table.sort(changedObjIds)
                        end

                        if cachedQuest and cachedQuest.isComplete == 0 and isComplete == 1 then
                            Sounds.PlayQuestComplete()
                        end

                        if changedObjIds then
                            if (not cache[questId]) then
                                -- Quest is new to cache
                                questCount = questCount + 1
                            end
                            -- Save to cache
                            cache[questId] = {
                                title = title,
                                questTag = questTag,
                                isComplete = isComplete,
                                objectives = newObjectives,
                            }
                            changes[questId] = changedObjIds
                        end
                    else
                        cacheMiss = true
                    end
                end
            else
                Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestLogCache.CheckForChanges] HaveQuestData() == false. questId, index:", questId, questLogIndex)

                -- In theory this shouldn't happen, but it does. This is not error but an edge case.

                -- Game's quest log has the questId, but game doesn't have data of the quest right now.
                -- Use earlier cached version of the quest. This may very well be nonexisting version, which is okey.
                -- Query with HaveQuestData() triggers game to get the data and fire QUEST_LOG_UPDATE once game has the data.
                --   Does NOT trigger getting objectives data! (read: item data related to objectives)
                -- It is also possible that the objective data is somewhat corrupted and we can't get it - Thanks Blizzard.

                -- Speed up caching of objective items as HaveQuestData() won't trigger game to cache those.
                C_QuestLog_GetQuestObjectives(questId)

                cacheMiss = true
            end
        end
    end

    -- debug / error detection to see if this happens sometimes. If happens there is fault in QuestEventHandler side.
    if questIdsToCheck then
        for questId in pairs(questIdsToCheck) do
            if (not questIdsChecked[questId]) then
                -- TODO: This actually happens and need to be fixed
                Questie.Warning("Please report on Github or Discord. QuestId doesn't exist in Game's quest log:", questId)
            end
        end
    end

    return cacheMiss, changes, questIdsChecked
end

---Protects cached quests from stale objective decreases until each quest's data recovers.
---@return nil
function QuestLogCache.OnLoadingScreenEnabled()
    questsAwaitingRecovery = {}
    for questId in pairs(cache) do
        questsAwaitingRecovery[questId] = true
    end
end


---@param questId QuestId
---@return nil
function QuestLogCache.RemoveQuest(questId)
    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestLogCache.RemoveQuest] remove questId:", questId)
    questsAwaitingRecovery[questId] = nil
    if cache[questId] then
        cache[questId] = nil
        questCount = questCount - 1
    end
end


--- Tests if game client's cache has all quest log quests and objectives cached.
--- Avoid using this function if possible.
---@return boolean gameCacheOK
function QuestLogCache.TestGameCache()
    local gameCacheOK = true
    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) then
            -- Use the loader's client-wording checks, including Forever's counter-first placeholders.
            if not QuestieLib.GetLoadedQuestObjectives(questId) then
                gameCacheOK = false
            end
        end
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestLogCache.TestGameCache]", (gameCacheOK and "Cache ok." or "Cache missing data."))
    return gameCacheOK
end


---Reads the last accepted snapshot when a cache miss is expected, without reporting an error.
---Tracker and tooltip rendering can run before the initial snapshot loads or for party-only quests
---absent from the local cache. Those callers need nil to choose a fallback, not GetQuest's stack trace.
---This only reads the cache: it never queries Blizzard, starts a retry, or changes cached data.
---@param questId QuestId
---@return QuestLogCacheData? @Borrowed snapshot; NEVER modify the returned table or its objectives.
function QuestLogCache.TryGetQuest(questId)
    return cache[questId]
end

---Reads a quest that the caller expects to be cached; reports an error when that invariant is broken.
---Use TryGetQuest instead when absence is normal and the caller can render a fallback.
---@param questId QuestId
---@return QuestLogCacheData? @NEVER EVER MODIFY THE RETURNED TABLE
function QuestLogCache.GetQuest(questId)
    -- Fix the issue at function caller side if this error pops up.
    if (not cache[questId]) then
        Questie:Print(debugstack(1, 20, 4))
        Questie.Error("Please report this error. GetQuest: The quest doesn't exist in QuestLogCache.", questId)
        return
    end
    return cache[questId]
end

--- This is for debugging of #6734
function QuestLogCache.PrintQuestLogStates()
    -- Concat the questLogStates to the debug output to help debugging of #6734
    local cacheStr = "QuestLogCache: "
    for qId, _ in pairs(cache) do
        cacheStr = cacheStr .. qId .. ", "
    end

    local questLogStates = QuestEventHandler.GetQuestLogStates()
    local questLogStatesStr = "QuestEventHandler: "
    for qId, entry in pairs(questLogStates) do
        questLogStatesStr = questLogStatesStr .. qId .. "=" .. tostring(entry.state) .. " / "
    end

    local currentQuestLog = QuestiePlayer.currentQuestlog
    local currentQuestLogStr = "CurrentQuestLog: "
    for qId, _ in pairs(currentQuestLog) do
        currentQuestLogStr = currentQuestLogStr .. qId .. ", "
    end

    Questie.Error(cacheStr)
    Questie.Error(questLogStatesStr)
    Questie.Error(currentQuestLogStr)
end

--- A wrapper function to add error check instead using exposed table directly.
---@param questId QuestId
---@return table<ObjectiveIndex, QuestLogCacheObjectiveData>? @NEVER EVER MODIFY THE RETURNED TABLE
function QuestLogCache.GetQuestObjectives(questId)
    -- Fix the issue at function caller side if this error pops up.
    if (not cache[questId]) then
        Questie:Print(debugstack(1, 20, 4))
        Questie.Error("Please report this error. GetQuestObjectives: The quest doesn't exist in QuestLogCache.", questId)
        QuestLogCache.PrintQuestLogStates()
        return
    end
    return cache[questId].objectives
end

---@return number @The amount of quests in the quest cache
function QuestLogCache.GetQuestCount()
    return questCount
end


---@param q table @quest
---@param i number @index of the objective
---@param o table @objective
local function DebugPrintObjective(q, i, o)
    if (o.raw_numFulfilled == o.numFulfilled) and (o.raw_finished == o.finished) then
        print(" ", i.."/"..#q.objectives..":",
            o.numFulfilled.."/"..o.numRequired.."="..tostring(o.finished),
            o.type,
            "\""..o.text.."\"")
    else
        print(" ", i.."/"..#q.objectives..":",
            o.raw_numFulfilled.."/"..o.numRequired.."="..tostring(o.raw_finished),
            "FIX:", o.numFulfilled.."/"..o.numRequired.."="..tostring(o.finished),
            o.type,
            "\""..o.text.."\"")
    end
end

--- Debug function, prints whole cache
function QuestLogCache.DebugPrintCache()
    print("DebugPrintCache", GetTime())
    local count = 0
    for questId, q in pairs(cache) do
        count = count + 1
        print("Quest: ("..questId..") \""..q.title.."\" questTag="..tostring(q.questTag) ,"isComplete="..tostring(q.isComplete))
        if not next(q.objectives) then
            print("  no objectives")
        else
            for i, o in ipairs(q.objectives) do
                DebugPrintObjective(q, i, o)
            end
        end
    end
    print("Total Quests ", count)
end

--- Debug function, prints changes
function QuestLogCache.DebugPrintCacheChanges(cacheMiss, changes)
    local highlight = ((not cacheMiss) and (not next(changes))) or (cacheMiss and next(changes)) -- highlight untypical cases. they are okey, but sometimes interesting.
    print("DebugPrintCacheChanges", GetTime(), (highlight and "\124cffFF4444CacheMiss:\124r" or "CacheMiss"), cacheMiss)

    for questId, objIndexes in pairs(changes) do
        local q = cache[questId]
        print("Quest: ("..questId..") \""..q.title.."\" questTag="..tostring(q.questTag) ,"isComplete="..tostring(q.isComplete))
        if not next(objIndexes) then
            print("  no objectives changed (or quest doesn't have objectives)")
        else
            for _, i in ipairs(objIndexes) do
                DebugPrintObjective(q, i, q.objectives[i])
            end
        end
    end
end