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
        [202060] = {
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{76.8, 51.4}},
                [zoneIDs.TIRISFAL_GLADES] = {{66.4, 40.2}},
            },
        },
        [203079] = {
            [npcKeys.spawns] = {
                [1] = {{53.5, 47.5}},
                [12] = {{24.6, 75.2},{38.6, 75.2}},
                [14] = {{36, 47.4},{41, 49.4},{55.8, 38.4},{56.6, 26.6}},
                [141] = {{39.6, 37.6},{39.8, 69.4},{43.8, 77},{54.8, 66},{62.6, 71.8}},
                [215] = {{40.4, 53.2},{45.6, 36.4},{60.2, 67.4}},
            },
        },
        [203226] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{69.6, 50.6}},
            },
        },
        [203475] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{22.4, 64.4}},
            },
        },
        [203478] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{22.6, 54.2}},
            },
        },
        [204068] = { -- Lady Sarevess
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,

        },
        [202699] = { -- Baron Aquanis
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [206248] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{66.8, 58}},
                [zoneIDs.MULGORE] = {{37.4, 49.6}},
            },
        },
        [207515] = {
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE] = {{30.6, 61.2}},
            },
        },
        [207743] = {
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{28.6, 18.2}},
            },
        },
        [207754] = {
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{26.6,19.8}},
            },
        },
        [207957] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{53, 43.4}},
            },
        },
        [208023] = {
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{58.8, 53.6}},
            },
        },
        [208275] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{58.6, 45.6}},
            },
        },
        [208619] = {
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{47.2, 71.2}},
            },
        },
        [208638] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{35.4,37.4},{30.4,41.2}},
            },
        },
        [208652] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{46.4, 53.2}},
            },
        },
        [208752] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{69.2, 58.2}},
            },
        },
        [208919] = {
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{61.6, 51.4}},
            },
        },
        [209004] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{71.2, 73.2}},
            },
        },
        [209608] = {
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{63.4, 22}},
            },
        },
        [209678] = { -- Twilight Lord Kelris
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [209872] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{56.6, 57.8}},
            },
        },
        [210995] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{43.4, 70.4}},
            },
        },
        [211022] = {
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{73.4,33}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [211033] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.8,80.2}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [211965] = {
            [npcKeys.spawns] = {
                [zoneIDs.WETLANDS] = {{46.6, 65.6}},
            },
        },
        [211200] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{65.1, 23.7}},
            },
        },
        [212261] = {
            [npcKeys.spawns] = {},
        },
        [212694] = {
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{43.2,78.6}},
            },
        },
        [212699] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212703] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212706] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212707] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{51.6, 54.6}},
            },
        },
        [212727] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212728] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212729] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212730] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{53.6, 54.2}},
            },
        },
        [212801] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.6, 36.4}},
            },
        },
        [212802] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{70.2, 62.8}},
            },
        },
        [212803] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{73.4, 73.4}},
            },
        },
        [212804] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.8}},
            },
        },
        [212969] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{39.4, 67.2},{73.8,61.9}},
            },
        },
        [212970] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{59.8, 72.4}},
            },
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
        [216902] = {
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.7,67.23}}},
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216915] = {
            [npcKeys.spawns] = {[zoneIDs.ALTERAC_MOUNTAINS]={{35.43,72.45}}},
        },
        [216924] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{53.3,66.47}}},
            [npcKeys.friendlyToFaction] = "AH",
        },
        [217706] = {
            [npcKeys.friendlyToFaction] = "H",
        },
        [217707] = {
            [npcKeys.friendlyToFaction] = "A",
        },
    }
end
