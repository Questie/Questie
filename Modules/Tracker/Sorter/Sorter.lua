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

---The sorts chosen in the tracker options.
---@return QuestSortDefinition? questSort Nil when this version does not know the saved quest sort.
---@return ZoneSortDefinition? zoneSort Nil when all quests are listed under one group.
function Sorter.GetSorts()
    local profile = Questie.db.profile
    return QuestSort.Get(profile.trackerQuestSort, profile.trackerQuestSortReversed),
        ZoneSort.Get(profile.trackerZoneSort, profile.trackerZoneSortReversed)
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
