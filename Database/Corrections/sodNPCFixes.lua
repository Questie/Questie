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
        [202699] = { -- Baron Aquanis
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}}
        },
        [208275] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{58.6, 45.6}},
            },
        },
        [208752] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{69.2, 58.2}},
            },
        },
        [209678] = { -- Twilight Lord Kelris
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}}
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
        [212261] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{17,37.6}},
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
                [zoneIDs.ASHENVALE] = {{59.8, 72.4},{36.9,50.1}},
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
    }
end
