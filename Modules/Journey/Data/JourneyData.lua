---@class JourneyData
local JourneyData = QuestieLoader:CreateModule("JourneyData")

---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---Build Journey's quest groups and matching dropdown choices after the database and ZoneDB are initialized.
---QuestieJourney:Initialize stores both results in self.zoneMap and self.zones. Tabs should read those tables,
---not call Build again: every call scans the quest database; this module does not cache results.
---Treat the returned tables as read-only. The quest map is also ZoneDB's latest generated map, not a copy.
---@param yield boolean? @True requires a coroutine managed by ThreadLib; false/nil builds synchronously.
---@return table<ZoneOrSort, table<QuestId, boolean>> zoneMap @Quest ID sets keyed by area ID or negative quest sort.
---@return table<number, table<ZoneOrSort, string>> zones @Localized dropdown labels grouped by Journey category ID.
function JourneyData.Build(yield)
    -- Journey grouping policy, not database corrections: quests keep their original zoneOrSort.
    -- Add [source] = destination here, using ZoneDB.zoneIDs for areas and QuestieDB.sortKeys for sorts.
    -- Sources are final groups after parent-zone grouping and seasonal splitting. Destinations are used
    -- as written; add a l10n.zoneCategoryLookup entry if a new destination needs a dropdown choice.
    -- A redirect moves the source quests into the destination, preserving existing quests without duplicates.
    -- Missing sources do nothing. Redirects apply once: A -> B and B -> C leave A's quests in B, not C.
    local zoneOrSortOverrides = {
        -- Blizzard groups these by race; Journey lists them with the starting zone's quests.
        [QuestieDB.sortKeys.NIGHT_ELF] = ZoneDB.zoneIDs.TELDRASSIL,
    }

    local zoneMap = ZoneDB.GetZonesWithQuests(yield, zoneOrSortOverrides)
    -- Derive dropdowns from this same map so removed sources and newly populated destinations stay in sync.
    return zoneMap, ZoneDB.GetRelevantZones(zoneMap)
end
