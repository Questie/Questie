--- Contains last known valid state of each quest in game's quest log, per quest.
--- I.E. All data related to a quest is valid.
--- Includes a "hack" to have correct objectives' progress while quest isComplete = 1. Otherwise it would need to be done everywhere else in code
---@class QuestLogCache
local QuestLogCache = QuestieLoader:CreateModule("QuestLogCache")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local stringByte = string.byte
local GetQuestLogTitle, C_QuestLog_GetQuestObjectives = GetQuestLogTitle, C_QuestLog.GetQuestObjectives
local type = type

-- 3 * (Max possible number of quests in game quest log)
-- This is a safe value, even smaller would be enough. Too large won't effect performance
local MAX_QUEST_LOG_INDEX = 75

--[[
Example of data in cache table.
raw_* are as in game's quest log. Their non-raw versions are corrected/modified for addon's easy use.

local cache = {
    [questId] = {
        title = "Quest name",
        questTag = "Dungeon", -- nil, "Dungeon", "Raid", etc.
        isComplete = nil,
        objectives = {
            {
                text = "Objective Text"
                type = "monster",
                finished = false,
                numFulfilled = 2,
                numRequired = 3,
                raw_Text = "Objective Text slain: 2/3",
                raw_finished = false
                raw_numFulfilled = 2,
            },
            {
                text = "Objective2"
                type = "item",
                finished = false,
                numFulfilled = 0,
                numRequired = 5,
                raw_text = "Objective2 : 0/5",
                raw_finished = false,
                raw_numFulfilled = 0,
            },
            ....
        },
    [questId2] = ....,
}
]]--


---@class QuestLogCacheObjectiveData
---@field text string "Objective Text"
---@field type "monster"|"object"|"item"|"reputation"|"killcredit"|"event"
---@field finished boolean
---@field numFulfilled number
---@field numRequired number
---@field raw_Text string E.g "Objective Text slain: 2/3",
---@field raw_finished boolean
---@field raw_numFulfilled number

---@class QuestLogCacheData
---@field title string
---@field questTag QuestTag
---@field isComplete -1|0|1 @ -1 = failed, 0 = not complete, 1 = complete
---@field objectives QuestLogCacheObjectiveData[]


---@type table<QuestId, QuestLogCacheData>
local cache = {}

--- NEVER EVER EDIT this table outside of the QuestLogCache module!  !!!
---@type table<QuestId, QuestLogCacheData>
QuestLogCache.questLog_DO_NOT_MODIFY = cache



---@return table? newObjectives, ObjectiveIndex[] changedObjIds @nil == cache miss in both addon and game caches. table {} == no objectives.
local function GetNewObjectives(questId, oldObjectives)
    local newObjectives = {} -- creating a fresh one to be able revert to old easily in case of missing data
    local changedObjIds -- not assigning {} for easier nil when nothing changed
    local objectives = C_QuestLog_GetQuestObjectives(questId)

    for objIndex=1, #objectives do -- iterate manually to be sure getting those in order
        local oldObj = oldObjectives[objIndex]
        local newObj = objectives[objIndex]
        -- Check if objective.text is in game's cache
        if (newObj.text) and (stringByte(newObj.text, 1) ~= 32) then
            -- Check if objective has changed
            if oldObj and oldObj.raw_numFulfilled == newObj.numFulfilled and oldObj.raw_text == newObj.text and oldObj.raw_finished == newObj.finished and oldObj.numRequired == newObj.numRequired and oldObj.type == newObj.type then
                -- Not changed
                newObjectives[objIndex] = oldObj
            else
                -- objective has changed, add it to list of change ones
                if (not changedObjIds) then
                    changedObjIds = { objIndex }
                else
                    changedObjIds[#changedObjIds+1] = objIndex
                end

                newObjectives[objIndex] = {
                    raw_text = newObj.text,
                    raw_finished = newObj.finished,
                    raw_numFulfilled = newObj.numFulfilled,
                    type = newObj.type,
                    numRequired = newObj.numRequired,
                    text = QuestieLib.TrimObjectiveText(newObj.text, newObj.type),
                    finished = newObj.finished, -- gets overwritten with correct value later if quest isComplete
                    numFulfilled = newObj.numFulfilled, -- gets overwritten with correct value later if quest isComplete
                }
            end
        else -- objective text not in game's cache
            if oldObj then
                Questie:Debug(Questie.DEBUG_INFO, "[GetNewObjectives] objective not in game's cache. Using addon's cache. questID, objIndex:", questId, objIndex)
                -- Extremely unlikely that the objective has changed from cached version as a change SHOULD trigger fetching data into game cache.
                -- Possible bug point if there comes desync issues.
                newObjectives[objIndex] = oldObj
            else
                Questie:Debug(Questie.DEBUG_INFO, "[GetNewObjectives] \"WARNING\" objective not in game's cache nor addon's cache. questID, objIndex:", questId, objIndex)
                -- Objective has been never cached
                -- Tell to function caller that we couldn't get all required data from game's cache
                -- Don't loop rest of objectives as we won't anyway save those into cache[] and C_QuestLog.GetQuestObjectives() call already triggered game to initiate caching those into game's cache.
                return nil
            end
        end
    end

    return newObjectives, changedObjIds
end

-- For profiling
QuestLogCache._GetNewObjectives = GetNewObjectives

--- Updates questlogcache.
--- Remember to handle returned changes table even when cacheMiss == true. Returned changes are still valid. There may just be more changes that we couldn't get yet.
--- Called only from QuestEventHandler.
---@param questIdsToCheck table? @keys are the questIds
---@return boolean cacheMiss, table changes @cacheMiss = couldn't get all required data  ; changes[questId] = list of changed objectiveIndexes (may be an empty list if quest has no objectives)
function QuestLogCache.CheckForChanges(questIdsToCheck)
    local cacheMiss = false
    local changes = {} -- table key = questid of the changed quest, table value = list of changed objective ids
    local questIdsChecked = {} -- for debug / error detection

    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        ----- title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questLogIndex)

        local title, _, questTag, isHeader, _, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) and ((not questIdsToCheck) or questIdsToCheck[questId]) then -- check all quests if no list what to check, otherwise just ones in the list
            questIdsChecked[questId] = true
            if HaveQuestData(questId) then
                local cachedQuest = cache[questId]
                local cachedObjectives = cachedQuest and cachedQuest.objectives or {}

                local newObjectives, changedObjIds = GetNewObjectives(questId, cachedObjectives)

                if newObjectives then
                    if cachedQuest and (#cachedObjectives ~= #newObjectives) then
                        Questie:Error("Please report on Github or Discord! Number of the objectives of the quest changed. questId, oldNum, newNum", questId, #cachedObjectives, #newObjectives)
                        -- Number of the objectives changed?! Shouldn't be possible.
                        -- For now go as nothing in the quest changed.
                        cacheMiss = true
                    else
                        if (not cachedQuest) or (cachedQuest.title ~= title) or (cachedQuest.questTag ~= questTag) or (cachedQuest.isComplete ~= isComplete) then
                            -- Mark all objectives changed to force update those too.
                            -- changedObjIds is nil from GetObjectives() for quests not having objectives. This is easiest place to change it to {}.

                            changedObjIds = {}
                            for i=1, #newObjectives do
                                changedObjIds[i] = i
                            end

                            if isComplete == 1 then
                                -- Set all objectives finished if whole quest isComplete.
                                -- Because of: Game API returns "event" type objectives as unfinished while whole quest isComplete.

                                local o
                                for i=1, #newObjectives do
                                    o = newObjectives[i]
                                    o.finished = true
                                    o.numFulfilled = o.numRequired
                                end
                            end
                        end
                        if changedObjIds then
                            -- Save to cache
                            cache[questId] = {
                                title = title,
                                questTag = questTag,
                                isComplete = isComplete,
                                objectives = newObjectives,
                            }
                            changes[questId] = changedObjIds
                        end
                    end
                else
                    cacheMiss = true
                end
            else
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestLogCache.CheckForChanges] HaveQuestData() == false. questId, index:", questId, questLogIndex)

                -- In theory this shouldn't happen. This is not error but an edge case.

                -- Game's quest log has the questId, but game doesn't have data of the quest right now.
                -- Use earlier cached version of the quest. This may very well be nonexisting version, which is okey.
                -- Query with HaveQuestData() triggers game to get the data and fire QUEST_LOG_UPDATE once game has the data.
                --   Does NOT trigger getting objectives data! (read: item data related to objectives)

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
                Questie:Error("Please report on Github or Discord. QuestId doesn't exist in Game's quest log:", questId)
            end
        end
    end

    -- DEBUG prints:
--[[
    local ids = "ALL"
    if questIdsToCheck then
        ids = ""
        for questId in pairs(questIdsToCheck) do
            ids = ids..tostring(questId).."," --yes, ugly extra comma at end. CBA
        end
    end
    print("questIdsToCheck=", ids)
    QuestLogCache.DebugPrintCacheChanges(cacheMiss, changes)
]]--

    return cacheMiss, changes
end


function QuestLogCache.RemoveQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestLogCache.RemoveQuest] remove questId:", questId)
    cache[questId] = nil
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
            if HaveQuestData(questId) then
                local objectives = C_QuestLog_GetQuestObjectives(questId)

                if type(objectives) ~= "table" then
                    -- I couldn't find yet a quest returning nil like older code suggested for example for quest 2744, which isn't true.
                    -- I guess older code queried data before HaveQuestData() was true.
                    -- This check is to catch if that is possible.
                    -- TODO: Remove this if block once confirmed error never happens.
                    -- I = Laume / Laumesis@Github
                    Questie:Error("Please report on Github or Discord! Quest objectives aren't a table at TestGameCache. questId =", questId)
                    error("Please report on Github or Discord! Quest objectives aren't a table at TestGameCache. questId = "..questId)
                    -- execution ends here because of error ^
                end

                for objIndex=1, #objectives do
                    local text = objectives[objIndex].text
                    -- Check if objective.text is not in game's cache
                    if (not text) or (stringByte(text, 1) == 32) then
                        gameCacheOK = false
                    end
                end
            else
                gameCacheOK = false
            end
        end
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestLogCache.TestGameCache]", (gameCacheOK and "Cache ok." or "Cache missing data."))
    return gameCacheOK
end


--- A wrapper function to add error check instead using exposed table directly.
---@param questId QuestId
---@return QuestLogCacheData? @NEVER EVER MODIFY THE RETURNED TABLE
function QuestLogCache.GetQuest(questId)
    -- Fix the issue at function caller side if this error pops up.
    if (not cache[questId]) then
        Questie:Print(debugstack(1, 20, 4))
        Questie:Error("Please report this error. GetQuest: The quest doesn't exist in QuestLogCache.", questId)
        return
    end
    return cache[questId]
end

--- A wrapper function to add error check instead using exposed table directly.
---@param questId QuestId
---@return table<ObjectiveIndex, QuestLogCacheObjectiveData>? @NEVER EVER MODIFY THE RETURNED TABLE
function QuestLogCache.GetQuestObjectives(questId)
    -- Fix the issue at function caller side if this error pops up.
    if (not cache[questId]) then
        Questie:Print(debugstack(1, 20, 4))
        Questie:Error("Please report this error. GetQuestObjectives: The quest doesn't exist in QuestLogCache.", questId)
        return
    end
    return cache[questId].objectives
end



---@param q table @quest
---@param i number @index of the objective
---@param o table @objective
local function DebugPrintObjective(q, i, o)
    if (o.raw_numFulfilled == o.numFulfilled) and (o.raw_finished == o.finished) then
        print(" ", i.."/"..#q.objectives..":",
            o.numFulfilled.."/"..o.numRequired.."="..tostring(o.finished),
            o.type,
            "\""..o.raw_text.."\" \""..o.text.."\"")
    else
        print(" ", i.."/"..#q.objectives..":",
            o.raw_numFulfilled.."/"..o.numRequired.."="..tostring(o.raw_finished),
            "FIX:", o.numFulfilled.."/"..o.numRequired.."="..tostring(o.finished),
            o.type,
            "\""..o.raw_text.."\" \""..o.text.."\"")
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
