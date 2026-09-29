---@class TrackerMapEligibility
local TrackerMapEligibility = QuestieLoader:CreateModule("TrackerMapEligibility")

---@class TrackerMapCapabilities
---@field quest Quest? Original map object, never a display copy.
---@field objectives table<table, boolean> Original objectives with usable location data.
---@field focusObjectives table<number, table> Original indices for focus and persisted icon visibility, not display indices.
---@field canFocusQuest boolean
---@field canNavigateQuest boolean
---@field canShowFinisher boolean

---Evaluates a display snapshot without refreshing it or changing map state.
---Commands refresh explicitly before calling this same policy used to construct menus.
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
    local allObjectivesMatched = true
    local hasObjectiveLocations = false
    for _, objective in pairs(quest.Objectives) do
        local original = objective.enrichment
        if not original then
            allObjectivesMatched = false
        elseif not complete and original.spawnList and next(original.spawnList) then
            capabilities.objectives[original] = true
            hasObjectiveLocations = true
            -- Synthetic source-item steps may have locations but no original index to focus or persist.
            if type(original.Index) == "number" then
                capabilities.focusObjectives[original.Index] = original
            end
        end
    end
    -- SpecialObjectives already contains only the original objects exposed by verified tracker enrichment.
    for _, original in pairs(quest.SpecialObjectives or {}) do
        if not complete and original.spawnList and next(original.spawnList) then
            capabilities.objectives[original] = true
            hasObjectiveLocations = true
            if type(original.Index) == "number" then
                capabilities.focusObjectives[original.Index] = original
            end
        end
    end

    local finisher = originalQuest.Finisher
    local hasFinisher = finisher and ((finisher.NPC and next(finisher.NPC)) or (finisher.GameObject and next(finisher.GameObject)))
    capabilities.canShowFinisher = complete and not not hasFinisher
    -- Navigation can use an individual verified objective. Whole-quest focus hides other quests,
    -- so it requires every live objective to be matched, unless the quest is ready for its finisher.
    capabilities.canFocusQuest = capabilities.canShowFinisher or (not complete and allObjectivesMatched and hasObjectiveLocations)
    capabilities.canNavigateQuest = capabilities.canShowFinisher or (not complete and hasObjectiveLocations)
    return capabilities
end
