---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function SeasonOfDiscovery:LoadNPCs()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags
    local waypointPresets = QuestieDB.waypointPresets

    return {
        [202699] = { -- Baron Aquanis
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}}
        },
        [209678] = { -- Twilight Lord Kelris
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}}
        },
        [213077] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{54.4,61.2}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214070] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{51.4,63.8}}},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214096] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF] = {{39.2,53.4}}},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214098] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY] = {{64,39.2}}},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214099] = {
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE] = {{24.4,67.6}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214101] = {
            [npcKeys.spawns] = {[zoneIDs.DARNASSUS] = {{59.8,56.4}}},
            [npcKeys.friendlyToFaction] = "A",
        },
    }
end
