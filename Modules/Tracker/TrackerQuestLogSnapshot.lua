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
    if not supportedSorts[profile.trackerSortObjectives]
        or (char.trackedAchievementIds and next(char.trackedAchievementIds))
        or instanceType == "scenario" or difficultyName == "Challenge Mode"
        or TrackerUtils:IsVoiceOverLoaded() then
        return nil
    end

    local _, totalQuests = QuestieCompat.GetNumQuestLogEntries()
    local snapshot = {quests = {}, totalQuests = totalQuests, expanded = char.isTrackerExpanded}
    for questId, quest in pairs(TrackerData.GetQuests()) do
        -- Timers and secure item buttons have additional state resolved during rendering.
        -- Use the same item selection as the renderer so ordinary, non-usable item objectives remain eligible.
        if TrackerQuestTimers:GetRemainingTimeByQuestId(questId) ~= nil
            or #TrackerUtils.GetQuestItemIds(quest, quest:IsComplete()) > 0 then
            return nil
        end

        local group = TrackerUtils.GetQuestGroupName(quest)
        local entry = {
            name = quest.name,
            level = quest.level,
            group = group,
            title = TrackerData.GetColoredQuestName(quest, profile.trackerShowQuestLevel, true),
            -- Equal-level sorting uses native tags even when the title hides the level/suffix.
            suffixPriority = QuestieLib.GetQuestTypeSuffixPriority(questId),
            complete = quest:IsComplete(),
            isComplete = quest.isComplete,
            objectivesLoaded = quest.objectivesLoaded,
            completionText = TrackerUtils:GetCompletionText(quest),
            tracked = (profile.autoTrackQuests and not char.AutoUntrackedQuests[questId])
                or (not profile.autoTrackQuests and char.TrackedQuests[questId]) or false,
            collapsed = char.collapsedQuests[questId],
            zoneCollapsed = char.collapsedZones[group],
            objectives = {},
        }
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

---@param snapshot table?
---@param renderedSnapshot table?
---@return boolean
function TrackerQuestLogSnapshot.IsUnchanged(snapshot, renderedSnapshot)
    -- Two unsupported snapshots must not compare equal and suppress a rebuild.
    return snapshot ~= nil and renderedSnapshot ~= nil and _Equal(snapshot, renderedSnapshot)
end
