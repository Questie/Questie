---@class QuestieWotlkNpcFixes
local QuestieWotlkNpcFixes = QuestieLoader:CreateModule("QuestieWotlkNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieWotlkNpcFixes:Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

    return {
        [15351] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{24.55,55.42}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
            },
        },
        [16281] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.39}}},
        },
        [16361] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.45}}},
        },
        [17977] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BOTANICA]={{-1,-1}}},
        },
        [19220] = {
            [npcKeys.spawns] = {[zoneIDs.THE_MECHANAR]={{-1,-1}}},
        },
        [23763] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{50.2,29.2},{50.4,26.4},{50.4,27},{50.6,26.6},{51,26.2},{51,27.6},{51.2,25.4},{51.2,28.8},{51.6,25.4},{51.8,27.6},{52,29.6},{52.2,26.4},{52.2,26.6},{52.4,28.6},{52.6,28.6},{52.8,26.4},{52.8,27},{52.8,27.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24329] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{72,26.4},{70.3,27.3},{68.7,28.1},{66.5,24.9},{69.7,21.5},{72.6,19.9},{73.6,23.1}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24440] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{30.2,26.4},{30.4,27},{30.6,24},{30.8,23.4},{30.8,26.6},{30.8,28.2},{30.8,28.6},{31,24.6},{31,26.4},{31.2,31},{31.6,27.2},{31.6,27.6},{31.8,26},},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24910] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{38.1, 74.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [25794] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{70.3,36.7},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [26170] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{84.8,41.68},},},
        },
        [26647] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{54.4,23.4}},
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [26723] = {
            [npcKeys.spawns] = {[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [27315] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{77.2,49.8},{78.2,50.6},{78.8,50.8},{79.8,49.6},{80,49.4},{80,51},{81.8,50.6},{82.2,50.4},{83,49.2},{83,50.2},{83.4,51},{84.2,50.4},{84.6,51.6},{84.8,50.4},}
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [27959] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{61.1,2}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [28026] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{35.21,64.79},{37.15,64.77},{36.51,64.55},{37.99,65.5},},},
        },
        [28083] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{49.8,85},{51.6,86.2},{58,83.8},{58.8,85.6},},},
        },
        [28358] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{57.4,52.2},{58.4,53.8},},},
        },
        [28912] = {
            [npcKeys.waypoints] = {},
        },
        [29173] = {
            [npcKeys.waypoints] = {},
        },
        [30082] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{38.2,61.6},},},
        },
        [30382] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{39.4,56.4},},},
        },
        [38042] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{52.8,76.8}},},
        },
        [38043] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{64.6,66.2}},},
        },
        [38044] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF] = {{44,52.8}},},
        },
        [38045] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY] = {{66.6,38.6}},},
        },
    }
end