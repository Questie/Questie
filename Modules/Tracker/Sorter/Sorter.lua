-- Orders the tracker in two independent steps: a zone sort orders the groups, a quest sort orders the quests inside each group.
-- ZoneSort and QuestSort define the available sorts; this module combines one of each.
---@class Sorter
local Sorter = QuestieLoader:CreateModule("Sorter")

---@type QuestSort
local QuestSort = QuestieLoader:ImportModule("QuestSort")
---@type ZoneSort
local ZoneSort = QuestieLoader:ImportModule("ZoneSort")

---What the sorts know about one tracked quest.
---@class QuestSortDetails
---@field quest TrackerQuest
---@field zoneName string Name of the group the quest is listed under.
---@field questCompletePercent number Finished share of the objectives, from 0 to 1.
---@field distance number? World distance to the nearest unfinished objective, or to the finisher of a complete quest.
---Nil when no location is known. Only set for sorts with `usesPlayerPosition`.
---@field isOnPlayerContinent boolean? Only set for sorts with `usesPlayerPosition`.
---@field isShown boolean? Whether the tracker draws the quest. Only set for zone sorts with `usesShownState`.

-- Every value of the trackerSortObjectives setting as a zone sort and a quest sort.
-- Without a zone sort, TrackerUtils.GetQuestGroupName lists every quest under one group.
---@type table<string, {zoneSort: string?, questSort: string}>
local sortNamesBySetting = {
    byZone = {zoneSort = "alphabetical", questSort = "level"},
    byZonePlayerProximity = {zoneSort = "proximity", questSort = "proximity"},
    byZonePlayerProximityReversed = {zoneSort = "proximityReversed", questSort = "proximityReversed"},
    byLevel = {questSort = "level"},
    byLevelReversed = {questSort = "levelReversed"},
    byComplete = {questSort = "complete"},
    byCompleteReversed = {questSort = "completeReversed"},
    byProximity = {questSort = "proximity"},
    byProximityReversed = {questSort = "proximityReversed"},
}

---@param sortSetting string Value of the trackerSortObjectives setting.
---@return QuestSortDefinition? questSort Nil when this version does not know the value, for example one saved by a newer Questie.
---@return ZoneSortDefinition? zoneSort Nil when the setting lists all quests under one group.
function Sorter.GetSorts(sortSetting)
    local sortNames = sortNamesBySetting[sortSetting]
    if not sortNames then
        return nil, nil
    end

    return QuestSort.sorts[sortNames.questSort], ZoneSort.sorts[sortNames.zoneSort]
end

---@param questDetails table<QuestId, QuestSortDetails>
---@param questSort QuestSortDefinition? Nil leaves the quests of each group in no particular order.
---@param zoneSort ZoneSortDefinition? Nil leaves the groups in no particular order.
---@return QuestGroup[] groups In tracker order, each with its quests in tracker order.
function Sorter.Sort(questDetails, questSort, zoneSort)
    -- Collect the quests of each group
    ---@type QuestGroup[]
    local groups = {}
    ---@type table<string, QuestGroup>
    local groupsByName = {}
    for questId, details in pairs(questDetails) do
        local group = groupsByName[details.zoneName]
        if not group then
            group = {name = details.zoneName, questIds = {}}
            groupsByName[details.zoneName] = group
            groups[#groups + 1] = group
        end
        group.questIds[#group.questIds + 1] = questId
    end

    if zoneSort then
        zoneSort.order(groups, questDetails)
    end

    if questSort then
        local function _CompareQuestIds(questIdA, questIdB)
            return questSort.compare(questDetails[questIdA], questDetails[questIdB])
        end
        for _, group in ipairs(groups) do
            table.sort(group.questIds, _CompareQuestIds)
        end
    end

    return groups
end
