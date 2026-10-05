---@class TrackerMapEligibility
local TrackerMapEligibility = QuestieLoader:CreateModule("TrackerMapEligibility")

---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")

---@class TrackerMapCapabilities
---@field quest Quest? Original map object, never a display copy.
---@field objectives table<table, boolean> Original objectives with usable location data.
---@field focusObjectives table<number, table> Original indices for focus and persisted icon visibility, not display indices.
---@field canFocusQuest boolean
---@field canNavigateQuest boolean
---@field canShowFinisher boolean

---Records an original objective with map locations as usable for map actions.
---@param capabilities TrackerMapCapabilities
---@param original table Original Questie objective.
local function _AddObjectiveLocations(capabilities, original)
    if not (original.spawnList and next(original.spawnList)) then
        return
    end
    capabilities.objectives[original] = true
    -- Synthetic source-item steps may have locations but no original index to focus or persist.
    if type(original.Index) == "number" then
        capabilities.focusObjectives[original.Index] = original
    end
end

---Evaluates a display snapshot without refreshing it or changing map state. Menus use it on the
---snapshot they render; commands use RefreshAndGetCapabilities so they act on current data.
---@param quest TrackerQuest?
---@return TrackerMapCapabilities
function TrackerMapEligibility.GetCapabilities(quest)
    local capabilities = {
        quest = quest and quest.enrichment,
        objectives = {},
        focusObjectives = {},
        canFocusQuest = false,
        canNavigateQuest = false,
        canShowFinisher = false,
    }
    local originalQuest = capabilities.quest
    if not originalQuest then
        return capabilities
    end

    local completionState = quest:IsComplete()
    local complete = completionState == 1 or (completionState ~= -1 and quest.isComplete == true)

    -- Objective locations. A complete quest points at its finisher instead, so it records none.
    local allObjectivesMatched = true
    for _, objective in pairs(quest.Objectives) do
        local original = objective.enrichment
        if not original then
            allObjectivesMatched = false
        elseif not complete then
            _AddObjectiveLocations(capabilities, original)
        end
    end
    -- SpecialObjectives already contains only the original objects exposed by verified tracker enrichment.
    if not complete then
        for _, original in pairs(quest.SpecialObjectives or {}) do
            _AddObjectiveLocations(capabilities, original)
        end
    end
    local hasObjectiveLocations = next(capabilities.objectives) ~= nil

    local finisher = originalQuest.Finisher
    local hasFinisher = finisher and ((finisher.NPC and next(finisher.NPC)) or (finisher.GameObject and next(finisher.GameObject)))
    capabilities.canShowFinisher = complete and not not hasFinisher
    -- Navigation can use an individual verified objective. Whole-quest focus hides other quests,
    -- so it requires every live objective to be matched, unless the quest is ready for its finisher.
    capabilities.canFocusQuest = capabilities.canShowFinisher or (not complete and allObjectivesMatched and hasObjectiveLocations)
    capabilities.canNavigateQuest = capabilities.canShowFinisher or (not complete and hasObjectiveLocations)
    return capabilities
end

---Refreshes a quest from the native log, then evaluates it. Commands call this before any map change,
---because a menu or tracker row can outlive the quest or its original map object.
---@param questId QuestId
---@param expectedQuest Quest? Original quest captured by the menu or row. A different current original fails.
---@return TrackerQuest? quest Refreshed display record; nil when the quest left the log or `expectedQuest` no longer matches.
---@return TrackerMapCapabilities? capabilities Nil exactly when `expectedQuest` no longer matches.
function TrackerMapEligibility.RefreshAndGetCapabilities(questId, expectedQuest)
    local quest = TrackerData.RefreshQuest(questId)
    local capabilities = TrackerMapEligibility.GetCapabilities(quest)
    if expectedQuest and capabilities.quest ~= expectedQuest then
        return nil, nil
    end
    return quest, capabilities
end
