---@class QuestieTBCNpcFixes
local QuestieTBCNpcFixes = QuestieLoader:CreateModule("QuestieTBCNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieTBCNpcFixes:Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [684] = {
            [npcKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE] = {{37.28,45.25},{39.29,45.54},{39.55,44.17},{46.09,26.19},{46.45,22.54},{47.23,23.07},{49.68,24.06},{49.71,25.47},{48.88,23.86},{46.52,28.44},{50.25,24.68},{48.66,20.75},{48.69,22.22},{50.66,20.61},{49.74,20.77},{48.09,20.2},{39.37,33.31},{38.7,32.86},{39.14,39.9},{39.22,37.91},{36.59,37.8},{45.94,27.72},{46.53,26.89},{38.33,34.67},{39.57,42.56},},},
            [npcKeys.zoneID] = zoneIDs.STRANGLETHORN_VALE,
        },
        [1356] = {
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE] = {{74.6,12},},},
            [npcKeys.zoneID] = zoneIDs.IRONFORGE,
        },
        [2552] = {
            [npcKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{32.04,46.29},{35.61,49.41},{37.5,40.95},{35.1,46.16},},},
        },
        [2553] = {
            [npcKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{31,42.4},{31.8,46.4},{34.6,39.4},{34.6,39.6},{35.2,46.4},{35.6,49.4},{37.4,40.8},{37.6,41},},},
            [npcKeys.waypoints] = {},
        },
        [2554] = {
            [npcKeys.waypoints] = {},
        },
        [2556] = {
            [npcKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{63.51,71.64},{67.08,70.15},{59.93,71.64},{62.55,73.17},{67.98,78.74},{67.65,77.23},{67.74,77.06},{67.93,76.49},{68.55,76.41},{69.97,68.65},{71.2,65.91},{71.25,69.92},{70.91,67.35},{70.64,69.64},{70.02,71.75},{69.03,71.98},{69.13,79.46},{72.68,64.43},{71.88,63.02},{64.28,68.95},{68.74,73.43},{66.03,81.88},{67.55,81.59},{66.28,82.24},{69.88,81.13},{69.55,81.58},{68.29,80.06},{69.17,81.66},{69.19,82.41},{68.17,79.5},{67.75,81.95},{67.18,80.83},{70.04,77.34},{68.99,78.68},{70.45,78.2},{69.75,78.01},},},
        },
        [16992] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{43.24,76.62},{42.95,76.43},{42.88,75.41},{43.11,78.29},{42.58,78.1},{44.3,79.35},{43.19,80.51},{26.33,66.82},{26.2,66.41},{23.66,61.87},{24.33,60.97},{22.99,58.95},{23.72,59.86},{22.45,58.09},{24.6,58.71},{24.39,57.88},{23.65,57.97},{23.06,56.98},{24.79,62.83},{25.41,63.77},{24.78,56.3},{24.05,55.43},{24.26,57.07},{25.19,53.55},{23.41,56.27},{23.56,54.34},{24.27,54.24},{23.98,52.22},{24.61,51.82},{23.11,53.18},{23.08,51.08},{24.0,50.7},{22.46,52.25},{22.4,54.07},{21.74,55.02},{22.37,55.94},{19.96,54.71},{21.19,55.99},{20.03,56.73},{20.36,57.06},{21.79,56.96},{19.04,56.28},{19.04,55.08},{18.66,56.61},{18.32,53.76},{17.58,54.21},{16.99,52.16},{17.39,53.31},{27.45,42.55},{25.59,41.21},{26.48,37.46},{26.74,37.48},{28.07,39.46},{27.31,39.01},{26.83,40.01},{27.57,41.47},{27.15,41.57},{28.34,41.75},{28.29,40.58},{29.45,43.69},{31.44,44.43},{30.88,43.32},{31.05,41.48},{29.47,39.59},},},
        },
        [16994] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{39.04,40.32},},},
        },
        [17000] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{40.22,31.09},},},
        },
        [17087] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{71.8,40.2},},},
        },
        [17204] = {
            [npcKeys.spawns] = {[zoneIDs.THE_EXODAR] = {{29.8,32.8},},},
            [npcKeys.waypoints] = {[zoneIDs.THE_EXODAR] = {{{29.8,32.8},{30.3,33.2},{31,32.4},{31,28.9},{31.3,27.7},{31,28.9},{31,32.4},{30.3,33.2},{29.8,32.8},},},},
            [npcKeys.zoneID] = zoneIDs.THE_EXODAR,
        },
        [17311] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{54.08,55.1},},[zoneIDs.AZUREMYST_ISLE] = {{16.6,94.4},},},
        },
        [17318] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{18.48,84.35},},},
        },
        [17350] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{43.74,24.11},{40.46,26.0},{47.68,32.78},{48.1,31.75},{35.84,43.61},{34.28,44.08},{31.29,42.66},{36.9,49.07},{36.72,50.54},{39.66,51.11},{43.58,51.24},{45.15,57.08},{42.6,58.1},{39.37,55.07},{43.64,62.19},{39.6,41.7},{43.7,39.3},{44.8,39.9},},},
        },
        [17352] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{36,75.6},{36.4,74},{36.4,74.6},{36.8,71.6},{36.8,74.4},{37.4,75.8},{43.8,91},{45.6,53.4},{45.8,55},{46.8,54.4},{47.2,54.8},{47.4,53.2},{48,53.4},{48,61.2},{48,68.4},{48.4,58.4},{48.4,73.2},{48.4,73.8},{48.4,86.6},{48.6,56.8},{48.6,73},{49,71.4},{49,72.4},{49,83.6},{49.2,74.2},{49.4,55.8},{49.6,51.6},{49.6,72.4},{49.8,74.4},{49.8,74.6},{49.8,76.6},{50,44},{50,54},{50,75.8},{50.2,49.6},{50.2,51.2},{50.2,53},{50.4,72.8},{50.6,71},{50.6,71.8},{50.6,73},{51,48.4},{51.2,48.6},{51.2,74.2},{51.2,79.4},{51.4,74.6},{51.6,51.2},{51.6,74},{51.6,74.6},{51.8,48.6},{51.8,73.4},{52.2,48},{52.8,80.8},{53.4,63.8},{53.4,79.6},{53.6,65.4},{53.6,82},{54,72.6},{55.4,47},{55.4,72.8},{56,47},{56,63.6},{56.2,45.2},{56.2,49.2},{56.4,48.4},{56.4,50.6},{56.4,60.6},{57,50.8},{57.4,68},{57.8,49.2},{57.8,60.8},{58,49.6},{58.2,68},{58.4,64},{58.6,50.4},{59.6,53},{59.6,59.2},{60,60},{61.2,57.4},{62.8,52.8},{63.2,59.8},},},
        },
        [17413] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{26.9,37.46}}}
        },
        [17496] = {
            [npcKeys.waypoints] = {},
        },
        [17550] = {
            [npcKeys.waypoints] = {},
        },
        [17610] = {
            [npcKeys.waypoints] = {},
        },
        [17702] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{64.2,76.4},},},
        },
        [17713] = {
            [npcKeys.waypoints] = {},
        },
        [17715] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{86,54},},},
            [npcKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
        },
        [17334] = {
            [npcKeys.waypoints] = {},
        },
        [17336] = {
            [npcKeys.waypoints] = {},
        },
        [17589] = {
            [npcKeys.waypoints] = {},
        },
        [17592] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{72.81,20.83},},},
            [npcKeys.waypoints] = {},
        },
        [18120] = {
            [npcKeys.waypoints] = {},
        },
        [18121] = {
            [npcKeys.waypoints] = {},
        },
        [18152] = {
            [npcKeys.spawns] = {[zoneIDs.ZANGARMARSH] = {{26.4,22},},},
        },
        [19305] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{13.64,39.12},},},
        },
        [19456] = {
            [npcKeys.spawns] = {[zoneIDs.EVERSONG_WOODS]={{37.4,86.2},},},
            [npcKeys.zoneID] = zoneIDs.EVERSONG_WOODS,
        },
        [20145] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{45.6,82.4},{46.2,83.2},{46.6,83},{48.2,85},{48.8,82.4},{49.4,82.8},{50,82},{50.2,83.2},{50.2,83.6},{51,82.6}},},
        },
        [20440] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM]={{26.07,38.78},},},
            [npcKeys.zoneID] = zoneIDs.NETHERSTORM,
        },
        [21446] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{38.8,56},{39,57.6},{39.2,57.4},{39.4,53},{40.2,50},{40.4,57.8},{42,57.2},{42,57.6},{42.4,53.8},{43,47.2},{43,50},},},
        },
        [21452] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{47.0,77.8},{46.6,79.2},},},
        },
        [21638] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{50.88,54.76},},},
        },

        -- Below are fake IDs to show specific quest starts/ends only at one specific location even though the
        -- corresponding real NPC has multiple spawns (e.g. "The Kessel Run" requires you to run to Azure Watch even
        -- though "Exarch Menelaous" also spawns at Bloodmyst Isle)

        [40000] = {
            [npcKeys.name] = "Exarch Menelaous",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 14,
            [npcKeys.zoneID] = zoneIDs.AZUREMYST_ISLE,
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{47.11,50.6},},},
            [npcKeys.friendlyToFaction] = "A",
        },
        [40001] = {
            [npcKeys.name] = "Admiral Odesyus",
            [npcKeys.minLevel] = 60,
            [npcKeys.maxLevel] = 60,
            [npcKeys.zoneID] = zoneIDs.AZUREMYST_ISLE,
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{47.04,70.21},},},
            [npcKeys.friendlyToFaction] = "A",
        },
        [40002] = {
            [npcKeys.name] = "Bristlelimb Furbolgs",
            [npcKeys.minLevel] = 10,
            [npcKeys.maxLevel] = 12,
            [npcKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE] = {{68,81},{64.9,81.6},{64.2,76.4},},},
            [npcKeys.friendlyToFaction] = "",
        },
    }
end