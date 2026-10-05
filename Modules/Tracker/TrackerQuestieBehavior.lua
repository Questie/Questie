-- Owns quest completion and Questie-specific additions to the shared tracker display record.
-- Completion is not optional metadata: every refresh, including a cache miss, is resolved here.
---@class TrackerQuestieBehavior
local TrackerQuestieBehavior = QuestieLoader:CreateModule("TrackerQuestieBehavior")

---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")

---Resolves quest completion and applies Questie-specific data and exceptions. This is not a second renderer.
---Only the display record is modified; the cache and original map objects remain owned by their modules.
---Call after rebuilding baseline objectives so synthetic steps from a previous refresh cannot accumulate.
---@param displayQuest TrackerQuest
---@param cached QuestLogCacheData? Presence confirms objectives have loaded; never modified here.
---@param nativeComplete number? Native quest-log state; only failure is authoritative before objectives are loaded.
function TrackerQuestieBehavior.Apply(displayQuest, cached, nativeComplete)
    -- Optional database/map metadata. Missing enrichment must not prevent the baseline from displaying.
    local originalQuestieQuest = QuestiePlayer.currentQuestlog[displayQuest.Id]
    if type(originalQuestieQuest) ~= "table" then
        originalQuestieQuest = nil
    end
    displayQuest.enrichment = originalQuestieQuest
    displayQuest.zoneOrSort = originalQuestieQuest and originalQuestieQuest.zoneOrSort
    displayQuest.Description = originalQuestieQuest and originalQuestieQuest.Description
    displayQuest.Finisher = originalQuestieQuest and originalQuestieQuest.Finisher or {}
    displayQuest.sourceItemId = originalQuestieQuest and originalQuestieQuest.sourceItemId or 0
    displayQuest.requiredSourceItems = originalQuestieQuest and originalQuestieQuest.requiredSourceItems or {}
    displayQuest.ObjectiveData = {}
    displayQuest.SpecialObjectives = {}

    for _, objective in ipairs(displayQuest.Objectives) do
        -- Display rows are reused. Clear references before attaching the current index-based mapping.
        objective.enrichment = nil
        objective.Id = nil
        -- DistanceUtils reads this field; mutations of map state use the original enrichment object.
        objective.spawnList = {}
    end
    if not cached then
        -- A cache miss must not imply completion or retain an earlier completion result.
        -- Preserve the existing exception that native failure can be displayed before objectives load.
        displayQuest.completionState = nativeComplete == -1 and -1 or 0
        displayQuest.isComplete = false
        return
    end

    -- Existing Questie completion semantics apply to every cached quest, including database-unknown ones.
    -- Keep the shared helper (and its source-item checks), rather than inventing a second completion rule.
    displayQuest.completionState = QuestieDB.IsComplete(displayQuest.Id)
    local allObjectivesMapped = originalQuestieQuest ~= nil

    -- Database corrections own objective ordering, as in QuestieQuest:PopulateQuestLogInfo.
    -- Use the native index, not the dense display index. Wording and types are not identity checks:
    -- client languages can differ, and database kill-credit objectives can be native monster objectives.
    for _, objective in ipairs(displayQuest.Objectives) do
        local index = objective.NativeIndex
        local metadata = originalQuestieQuest and originalQuestieQuest.ObjectiveData and originalQuestieQuest.ObjectiveData[index]
        local original = originalQuestieQuest and originalQuestieQuest.Objectives and originalQuestieQuest.Objectives[index]
        if metadata and original then
            objective.enrichment = original
            objective.Id = original.Id
            objective.spawnList = original.spawnList or {}
            displayQuest.ObjectiveData[#displayQuest.ObjectiveData + 1] = metadata
        else
            allObjectivesMapped = false
        end
    end

    -- Questie compatibility exceptions can change the display, unlike location enrichment above.
    -- Preserve the missing-source-item step for quests with no native objectives. An empty list alone
    -- does not justify adding this step or declaring the quest complete.
    if #displayQuest.Objectives == 0 and originalQuestieQuest and originalQuestieQuest.Objectives then
        for _, original in ipairs(originalQuestieQuest.Objectives) do
            if original.Type == "item" and original.Id == originalQuestieQuest.sourceItemId and original.Completed == false then
                local objective = {
                    Id = original.Id,
                    Index = #displayQuest.Objectives + 1,
                    questId = displayQuest.Id,
                    Type = original.Type,
                    -- This synthetic step has no native text. Build its complete display string here.
                    Description = original.Description .. ": " .. original.Collected .. "/" .. original.Needed,
                    Collected = original.Collected,
                    Needed = original.Needed,
                    Completed = original.Completed,
                    spawnList = original.spawnList or {},
                    enrichment = original,
                }
                displayQuest.Objectives[objective.Index] = objective
                allObjectivesMapped = false
            end
        end
    end
    displayQuest.SpecialObjectives = allObjectivesMapped and originalQuestieQuest.SpecialObjectives or {}
    -- Additional completion must not hide objectives with missing mappings or a missing-source-item step.
    displayQuest.isComplete = displayQuest.completionState ~= -1 and (displayQuest.completionState == 1
        or (allObjectivesMapped and originalQuestieQuest.isComplete == true)) or false
end

---Questie-specific title traits are separate from the shared level/name/state formatting.
---Read them when formatting, as before; do not introduce another metadata cache.
---@param displayQuest TrackerQuest
---@return boolean? isRepeatable, boolean? isEvent, boolean? isPvP
function TrackerQuestieBehavior.GetTitleFlags(displayQuest)
    local originalQuestieQuest = displayQuest.enrichment
    return originalQuestieQuest and originalQuestieQuest.IsRepeatable, originalQuestieQuest and QuestieEvent.IsEventQuest(displayQuest.Id),
        originalQuestieQuest and QuestieDB.IsPvPQuest(displayQuest.Id)
end
