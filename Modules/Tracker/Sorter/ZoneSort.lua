-- The orders available for the tracker's groups: zones, dungeons and categories such as a class or profession.
---@class ZoneSort
local ZoneSort = QuestieLoader:CreateModule("ZoneSort")

---A tracker header and the quests listed under it.
---@class QuestGroup
---@field name string Header text, which is also the group's key in `collapsedZones`.
---@field questIds QuestId[]

---@class ZoneSortDefinition
---@field order fun(groups: QuestGroup[], questDetails: table<QuestId, QuestSortDetails>) Sorts the groups in place.
---@field usesPlayerPosition boolean? The sort reads `distance`, which is only set for these sorts.
---@field usesShownState boolean? The sort reads `isShown`, which is only set for these sorts.

---A group is as near as its nearest quest that the tracker shows, so a hidden quest cannot move a header.
---@param groups QuestGroup[]
---@param questDetails table<QuestId, QuestSortDetails>
---@return table<string, number> nearestDistances By group name. Groups without a shown quest at a known location have no entry.
local function _GetNearestDistances(groups, questDetails)
    local nearestDistances = {}
    for _, group in ipairs(groups) do
        for _, questId in ipairs(group.questIds) do
            local details = questDetails[questId]
            if details.isShown and details.distance then
                nearestDistances[group.name] = math.min(nearestDistances[group.name] or math.huge, details.distance)
            end
        end
    end
    return nearestDistances
end

---@param groups QuestGroup[]
---@param questDetails table<QuestId, QuestSortDetails>
---@param farthestFirst boolean
local function _OrderByProximity(groups, questDetails, farthestFirst)
    local nearestDistances = _GetNearestDistances(groups, questDetails)

    table.sort(groups, function(a, b)
        local distanceA, distanceB = nearestDistances[a.name], nearestDistances[b.name]
        if distanceA == distanceB then
            return a.name < b.name
        end

        -- Groups without a known location come last in both directions.
        if not distanceA then
            return false
        elseif not distanceB then
            return true
        end

        if farthestFirst then
            return distanceA > distanceB
        end
        return distanceA < distanceB
    end)
end

-- Each sort in both directions, by the value of the trackerZoneSort setting.
---@type table<string, {forward: ZoneSortDefinition, reversed: ZoneSortDefinition}>
local sorts = {
    alphabetical = {
        forward = {
            order = function(groups)
                table.sort(groups, function(a, b)
                    return a.name < b.name
                end)
            end,
        },
        reversed = {
            order = function(groups)
                table.sort(groups, function(a, b)
                    return a.name > b.name
                end)
            end,
        },
    },

    proximity = {
        forward = {
            order = function(groups, questDetails)
                _OrderByProximity(groups, questDetails, false)
            end,
            usesPlayerPosition = true,
            usesShownState = true,
        },
        reversed = {
            order = function(groups, questDetails)
                _OrderByProximity(groups, questDetails, true)
            end,
            usesPlayerPosition = true,
            usesShownState = true,
        },
    },
}

---@param sortName string Value of the trackerZoneSort setting.
---@param reversed boolean? Value of the trackerZoneSortReversed setting.
---@return ZoneSortDefinition? zoneSort Nil for "none", which lists all quests under one group, and for a name this version does not know.
function ZoneSort.Get(sortName, reversed)
    local sort = sorts[sortName]
    if not sort then
        return nil
    end

    return reversed and sort.reversed or sort.forward
end
