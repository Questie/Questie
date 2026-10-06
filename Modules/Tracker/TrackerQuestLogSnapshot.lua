-- Defines when a quest-log refresh can reuse ordinary quest layout. It owns no cached or frame state.
---@class TrackerQuestLogSnapshot
local TrackerQuestLogSnapshot = QuestieLoader:CreateModule("TrackerQuestLogSnapshot")

---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local supportedSorts = {
    byZone = true, byLevel = true, byLevelReversed = true, byComplete = true, byCompleteReversed = true,
}

---Copies ordinary quest layout inputs after TrackerData.Refresh, without measuring or changing frames.
---Nil means extra display state is outside this comparison; retain a full rebuild in that case.
---The caller owns the snapshot and must only save it after a successful layout, never after a text-only refresh.
---@return table? snapshot Values only: display records and objective rows are mutated in place by TrackerData.
function TrackerQuestLogSnapshot.Capture()
    local profile, char = Questie.db.profile, Questie.db.char
    local _, instanceType, _, difficultyName = GetInstanceInfo()

    -- These modes depend on display inputs beyond the quest records copied below.
    if not supportedSorts[profile.trackerSortObjectives]
        or (char.trackedAchievementIds and next(char.trackedAchievementIds))
        or instanceType == "scenario" or difficultyName == "Challenge Mode"
        or TrackerUtils:IsVoiceOverLoaded() then
        return nil
    end

    local _, totalQuests = QuestieCompat.GetNumQuestLogEntries()
    local snapshot = {quests = {}, totalQuests = totalQuests, expanded = char.isTrackerExpanded}
    for questId, quest in pairs(TrackerData.GetQuests()) do
        -- Include untracked quests in this conservative fallback. Timers and secure buttons resolve more state during layout.
        -- Shared item selection keeps ordinary collection objectives eligible when their items are not usable.
        if TrackerQuestTimers:GetRemainingTimeByQuestId(questId) ~= nil
            or #TrackerUtils.GetQuestItemIds(quest, quest:IsComplete()) > 0 then
            return nil
        end

        local group = TrackerUtils.GetQuestGroupName(quest)
        local entry = {
            -- Identity, title appearance and ordering.
            name = quest.name,
            level = quest.level,
            group = group,
            title = TrackerData.GetColoredQuestName(quest, profile.trackerShowQuestLevel, true),
            -- Equal-level sorting uses native tags even when the title hides the level/suffix.
            suffixPriority = QuestieLib.GetQuestTypeSuffixPriority(questId),

            -- Loading and completion can change without different objective text.
            complete = quest:IsComplete(),
            isComplete = quest.isComplete,
            objectivesLoaded = quest.objectivesLoaded,
            completionText = TrackerUtils:GetCompletionText(quest),

            -- Row visibility and expansion state.
            tracked = (profile.autoTrackQuests and not char.AutoUntrackedQuests[questId])
                or (not profile.autoTrackQuests and char.TrackedQuests[questId]) or false,
            collapsed = char.collapsedQuests[questId],
            zoneCollapsed = char.collapsedZones[group],
            objectives = {},
        }
        -- Copy values, not row references: incremental text updates reuse and mutate the display records.
        for index, objective in ipairs(quest.Objectives) do
            entry.objectives[index] = {
                nativeIndex = objective.NativeIndex,
                description = objective.Description,
                type = objective.Type,
                collected = objective.Collected,
                needed = objective.Needed,
                completed = objective.Completed,
            }
        end
        snapshot.quests[questId] = entry
    end
    return snapshot
end

-- Only walks the small, value-only records constructed above, never the enriched quest/map object graph.
local function _Equal(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then
        return left == right
    end
    for key, value in pairs(left) do
        if not _Equal(value, right[key]) then
            return false
        end
    end
    for key in pairs(right) do
        if left[key] == nil then
            return false
        end
    end
    return true
end

---Only a supported candidate and a completed-layout baseline can establish that layout is unchanged.
---@param snapshot table?
---@param renderedSnapshot table?
---@return boolean
function TrackerQuestLogSnapshot.IsUnchanged(snapshot, renderedSnapshot)
    -- Two unsupported snapshots must not compare equal and suppress a rebuild.
    return snapshot ~= nil and renderedSnapshot ~= nil and _Equal(snapshot, renderedSnapshot)
end
