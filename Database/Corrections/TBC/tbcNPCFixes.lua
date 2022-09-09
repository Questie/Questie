---@class QuestieTBCNpcFixes
local QuestieTBCNpcFixes = QuestieLoader:CreateModule("QuestieTBCNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieTBCNpcFixes:Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

    return {
        [2552] = {
            [npcKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{32.04,46.29},{35.61,49.41},{37.5,40.95},{35.1,46.16}}},
        },
        [2553] = {
            [npcKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{31,42.4},{31.8,46.4},{34.6,39.4},{34.6,39.6},{35.2,46.4},{35.6,49.4},{37.4,40.8},{37.6,41}}},
            [npcKeys.waypoints] = {},
        },
        [2554] = {
            [npcKeys.waypoints] = {},
        },
        [2556] = {
            [npcKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{63.51,71.64},{67.08,70.15},{59.93,71.64},{62.55,73.17},{67.98,78.74},{67.65,77.23},{67.74,77.06},{67.93,76.49},{68.55,76.41},{69.97,68.65},{71.2,65.91},{71.25,69.92},{70.91,67.35},{70.64,69.64},{70.02,71.75},{69.03,71.98},{69.13,79.46},{72.68,64.43},{71.88,63.02},{64.28,68.95},{68.74,73.43},{66.03,81.88},{67.55,81.59},{66.28,82.24},{69.88,81.13},{69.55,81.58},{68.29,80.06},{69.17,81.66},{69.19,82.41},{68.17,79.5},{67.75,81.95},{67.18,80.83},{70.04,77.34},{68.99,78.68},{70.45,78.2},{69.75,78.01}}},
        },
        [4323] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{41.87,80.76},{41.38,77.81},{42.77,81.06},{43.25,81.46},{42.14,76.6},{44.81,76.61},{45.68,84.1},{55.1,73.11},{51.06,74.15},{46.55,84.9},{51.74,67.65},{47.74,70.1},{44.76,73.97},{45.06,78.74},{54.38,70.54},{44.6,81.58},{46.67,82.35},{47.27,82.46},{43.57,70.0},{45.76,72.13},{45.51,73.14},{46.82,71.51},{50.51,71.97},{48.94,70.24},{50.01,69.05},{46.2,65.05},{48.18,80.52},{44.11,66.44},{44.93,64.48},{46.71,65.42},{47.21,67.19},{43.08,69.23},{43.71,64.4},{45.79,65.18},{45.95,67.21},},},
        },
        [4324] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{45.78,82.35},{41.5,79.51},{42.8,79.17},{42.19,78.86},{45.77,84.33},{55.46,83.41},{55.02,84.13},{51.41,71.02},{49.11,68.06},{44.83,75.86},{45.56,68.91},{45.07,69.71},{47.18,77.95},{52.72,70.07},{48.46,78.55},{56.37,70.08},{43.03,82.1},{45.21,67.98},{46.45,83.4},{46.48,67.42},{42.48,65.63},{47.74,66.3},{48.45,67.02},},},
        },
        [4358] = {
            [npcKeys.spawns] = {},
            [npcKeys.zoneID] = zoneIDs.DUSTWALLOW_MARSH,
        },
        [4359] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{57.13,15.03},{57.42,14.93},{57.44,15.17},{58.2,16.26},{57.98,15.41},{58.06,15.91},{58.48,16.22},{58.36,15.33},{58.85,14.9},{54.17,15.11},{54.07,14.94},{59.14,15.51},{54.57,15.53},{57.34,15.54},{54.19,15.66},{53.78,15.15},{55.36,16.61},{54.74,16.48},{57.45,16.0},{57.6,15.85},{57.49,16.58}}},
        },
        [4360] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{57,11},{57.4,10.4},{57.8,11.6},{58,11},{58.2,9.2},{58.4,8.4},{58.4,10.2},{58.6,8},{59,10.8},{59.4,9.4},{59.4,9.8},{59.6,7.2},{59.6,9.2},{59.6,9.8},{59.6,10.6},{59.8,7.6},{61.8,7.4},{62.4,8},{62.8,8},{62.8,9},{63,7.2},{63.2,6}}},
            [npcKeys.zoneID] = zoneIDs.DUSTWALLOW_MARSH,
        },
        [4361] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{57,11},{57.4,10.4},{57.8,11.6},{58,11},{58.2,9.2},{58.4,8.4},{58.4,10.2},{58.6,8},{59,10.8},{59.4,9.4},{59.4,9.8},{59.6,7.2},{59.6,9.2},{59.6,9.8},{59.6,10.6},{59.8,7.6},{61.8,7.4},{62.4,8},{62.8,8},{62.8,9},{63,7.2},{63.2,6}}},
            [npcKeys.zoneID] = zoneIDs.DUSTWALLOW_MARSH,
        },
        [5082] = {
            [npcKeys.spawns] = {[zoneIDs.WETLANDS] = {{8.4,61.8}}}, -- New position in TBC
        },
        [5676] = {
            [npcKeys.zoneID] = zoneIDs.ORGRIMMAR,
            [npcKeys.spawns] = {
                [zoneIDs.GHOSTLANDS] = {{27,15.2}},
                [zoneIDs.UNDERCITY] = {{86.51,26.94}},
                [zoneIDs.STORMWIND_CITY] = {{25.16,77.49}},
                [zoneIDs.ORGRIMMAR] = {{49.66,50.14}},
            },
        },
        [6072] = {
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{78.95,84.67},{78.8,82.4},{77.8,83.6},{78.6,85.6}}},
        },
        [8580] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TEMPLE_OF_ATAL_HAKKAR] = {{-1,-1}}},
        },
        [8888] = {
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{28.96,28.93},},},
            [npcKeys.zoneID] = zoneIDs.BURNING_STEPPES,
        },
        [9046] = {
            [npcKeys.spawns] = {
                [zoneIDs.BURNING_STEPPES]={{34.94,27.86},},
                [zoneIDs.SEARING_GORGE]={{43.34,99.17},},
            },
            [npcKeys.zoneID] = zoneIDs.BURNING_STEPPES,
        },
        [10182] = {
            [npcKeys.spawns] = {[zoneIDs.DESOLACE] = {{25.6,70.0}}},
            [npcKeys.waypoints] = {},
        },
        [11943] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR] = {{51,41}}},
        },
        [11980] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{71.0,62.2}}},
            [npcKeys.waypoints] = {},
        },
        [14387] = {
            [npcKeys.spawns] = {
                [zoneIDs.BURNING_STEPPES] = {{26.4,24.45},},
                [zoneIDs.SEARING_GORGE] = {{32.13,94.7},},
            },
            [npcKeys.zoneID] = zoneIDs.BURNING_STEPPES,
        },
        [17767] = {
            [npcKeys.spawns] = {[zoneIDs.HYJAL_SUMMIT] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.HYJAL_SUMMIT,
        },
        [17830] = {
            [npcKeys.spawns] = {[zoneIDs.RAGEFIRE_CHASM] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.RAGEFIRE_CHASM,
        },
        [15350] = {
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
            },
        },
        [15351] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{24.55,55.42}},
                [zoneIDs.STORMWIND_CITY]={{82.91,14.16}},
            },
        },
        [15493] = {
            [npcKeys.spawns] = {[3430]={{46.8,46.4}}},
        },
        [15658] = {
            [npcKeys.waypoints] = {},
        },
        [15668] = {
            [npcKeys.waypoints] = {},
        },
        [15669] = {
            [npcKeys.waypoints] = {},
        },
        [15920] = {
            [npcKeys.waypoints] = {[zoneIDs.EVERSONG_WOODS]={{{30,58.6}}}},
        },
        [15967] = {
            [npcKeys.waypoints] = {},
        },
        [16033] = {
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES]={{32.29,25.8},},[zoneIDs.SEARING_GORGE]={{39.87,96.46},},},
        },
        [16224] = {
            [npcKeys.waypoints] = {},
        },
        [16245] = {
            [npcKeys.waypoints] = {[zoneIDs.GHOSTLANDS] = {{{35.0,75.04},{36.85,68.71},{38.43,58.59},{36.4,51.93},{34.26,52.17},{34.3,49.7},{34.26,52.17},{36.4,51.93},{38.43,58.59},{36.85,68.71},{37.72,63.38},{38.17,56.86},{37.85,50.32},{38,45.5},{38.8,39.5},{39.1,34.9},{39.4,31.9},{39.1,34.9},{38.8,39.5},{38,45.5},{37.85,50.32},{38.17,56.86},{37.72,63.38},{35.0,75.04}}}},
        },
        [16333] = {
            [npcKeys.waypoints] = {},
        },
        [16817] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL]={{56.5,92.3}},
                [zoneIDs.STORMWIND_CITY]={{38.6,61.8}},
                [zoneIDs.IRONFORGE]={{63.81,25.31}},
                [zoneIDs.SHATTRATH_CITY]={{61.39,31.91}},
                [zoneIDs.THE_EXODAR]={{41.62,25.28}},
            },
        },
        [16818] = {
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF]={{21.33,26.44}},
                [zoneIDs.SHATTRATH_CITY]={{62.16,32.04}},
                [zoneIDs.UNDERCITY]={{67.62,8.28}},
                [zoneIDs.ORGRIMMAR]={{46.7,38.0}},
                [zoneIDs.SILVERMOON_CITY]={{69.83,42.99}},
            },
        },
        [16927] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{37.8,58.71},{37.7,58.88},{37.37,61.08},{36.55,57.83},{37.18,59.21},{37.79,62.12},{35.31,62.14},{35.18,62.99},{36.99,64.38},{35.36,63.18},{36.53,64.41},{35.31,69.79},{35.21,69.45},{34.57,66.62},{34.66,66.76},{34.15,65.74},{34.05,65.65},{33.3,64.8},{33.25,65.03},{32.8,65.87},{32.87,65.84},{35.04,59.27},{33.84,60.63},{33.96,60.9},{34.32,59.03},{34.36,58.67},{33.29,60.46},{33.51,58.77},{33.42,59.07},{34.6,57.88},{33.07,60.34},{32.09,61.48},{32.33,61.24},{32.06,61.02},{32.61,63.69},{32.81,63.61},{31.46,65.95},{31.46,66.1},{30.66,66.84},{30.54,66.36},{31.02,64.56},{31.03,64.77},{31.16,63.3},{31.14,62.91},{31.32,61.74},{31.49,61.91},{29.64,64.99},{30.79,61.11},{30.75,60.85},{31.32,60.41},{29.4,63.24},{30.28,60.1},{30.0,59.98},{31.39,60.21},{30.28,59.75},{29.44,65.19},{28.32,66.86},{28.45,66.54},{28.01,68.25},{27.8,68.29},{28.99,69.8},{28.97,69.83},{29.44,68.62},{29.58,68.61},{27.72,69.55},{27.38,69.08},{28.97,71.66},{29.59,70.57},{29.52,70.47},{28.89,71.41},{30.12,71.48},{30.16,71.71},{29.47,72.84},{29.46,72.62}}},
        },
        [16944] = {
            [npcKeys.waypoints] = {},
        },
        [16992] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{43.24,76.62},{42.95,76.43},{42.88,75.41},{43.11,78.29},{42.58,78.1},{44.3,79.35},{43.19,80.51},{26.33,66.82},{26.2,66.41},{23.66,61.87},{24.33,60.97},{22.99,58.95},{23.72,59.86},{22.45,58.09},{24.6,58.71},{24.39,57.88},{23.65,57.97},{23.06,56.98},{24.79,62.83},{25.41,63.77},{24.78,56.3},{24.05,55.43},{24.26,57.07},{25.19,53.55},{23.41,56.27},{23.56,54.34},{24.27,54.24},{23.98,52.22},{24.61,51.82},{23.11,53.18},{23.08,51.08},{24.0,50.7},{22.46,52.25},{22.4,54.07},{21.74,55.02},{22.37,55.94},{19.96,54.71},{21.19,55.99},{20.03,56.73},{20.36,57.06},{21.79,56.96},{19.04,56.28},{19.04,55.08},{18.66,56.61},{18.32,53.76},{17.58,54.21},{16.99,52.16},{17.39,53.31},{27.45,42.55},{25.59,41.21},{26.48,37.46},{26.74,37.48},{28.07,39.46},{27.31,39.01},{26.83,40.01},{27.57,41.47},{27.15,41.57},{28.34,41.75},{28.29,40.58},{29.45,43.69},{31.44,44.43},{30.88,43.32},{31.05,41.48},{29.47,39.59}}},
        },
        [16994] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{39.04,40.32}}},
        },
        [17000] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{40.22,31.09}}},
        },
        [17076] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY]={{92.2,36.4}}},
            [npcKeys.zoneID] = zoneIDs.SILVERMOON_CITY,
        },
        [17085] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{28.94,81.46}}},
        },
        [17087] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{71.8,40.2}}},
        },
        [17110] = {
            [npcKeys.waypoints] = {},
        },
        [17116] = {
            [npcKeys.waypoints] = {},
        },
        [17204] = {
            [npcKeys.spawns] = {[zoneIDs.THE_EXODAR] = {{29.8,32.8}}},
            [npcKeys.waypoints] = {[zoneIDs.THE_EXODAR] = {{{29.8,32.8},{30.3,33.2},{31,32.4},{31,28.9},{31.3,27.7},{31,28.9},{31,32.4},{30.3,33.2},{29.8,32.8}}}},
            [npcKeys.zoneID] = zoneIDs.THE_EXODAR,
        },
        [17214] = {
            [npcKeys.waypoints] = {},
        },
        [17240] = {
            [npcKeys.waypoints] = {},
        },
        [17241] = {
            [npcKeys.waypoints] = {},
        },
        [17288] = {
            [npcKeys.spawns] = {[zoneIDs.THE_SHATTERED_HALLS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_SHATTERED_HALLS,
        },
        [17290] = {
            [npcKeys.spawns] = {[zoneIDs.THE_SHATTERED_HALLS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_SHATTERED_HALLS,
        },
        [17294] = {
            [npcKeys.spawns] = {[zoneIDs.THE_SHATTERED_HALLS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_SHATTERED_HALLS,
        },
        [17296] = {
            [npcKeys.spawns] = {[zoneIDs.THE_SHATTERED_HALLS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_SHATTERED_HALLS,
        },
        [17301] = {
            [npcKeys.spawns] = {[zoneIDs.THE_SHATTERED_HALLS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_SHATTERED_HALLS,
        },
        [17311] = {
            [npcKeys.spawns] = {
                [zoneIDs.BLOODMYST_ISLE]={{54.08,55.1}},
                [zoneIDs.AZUREMYST_ISLE] = {{16.6,94.4}},
            },
        },
        [17318] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{18.48,84.35}}},
        },
        [17350] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{43.74,24.11},{40.46,26.0},{47.68,32.78},{48.1,31.75},{35.84,43.61},{34.28,44.08},{31.29,42.66},{36.9,49.07},{36.72,50.54},{39.66,51.11},{43.58,51.24},{45.15,57.08},{42.6,58.1},{39.37,55.07},{43.64,62.19},{39.6,41.7},{43.7,39.3},{44.8,39.9}}},
        },
        [17352] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{36,75.6},{36.4,74},{36.4,74.6},{36.8,71.6},{36.8,74.4},{37.4,75.8},{43.8,91},{45.6,53.4},{45.8,55},{46.8,54.4},{47.2,54.8},{47.4,53.2},{48,53.4},{48,61.2},{48,68.4},{48.4,58.4},{48.4,73.2},{48.4,73.8},{48.4,86.6},{48.6,56.8},{48.6,73},{49,71.4},{49,72.4},{49,83.6},{49.2,74.2},{49.4,55.8},{49.6,51.6},{49.6,72.4},{49.8,74.4},{49.8,74.6},{49.8,76.6},{50,44},{50,54},{50,75.8},{50.2,49.6},{50.2,51.2},{50.2,53},{50.4,72.8},{50.6,71},{50.6,71.8},{50.6,73},{51,48.4},{51.2,48.6},{51.2,74.2},{51.2,79.4},{51.4,74.6},{51.6,51.2},{51.6,74},{51.6,74.6},{51.8,48.6},{51.8,73.4},{52.2,48},{52.8,80.8},{53.4,63.8},{53.4,79.6},{53.6,65.4},{53.6,82},{54,72.6},{55.4,47},{55.4,72.8},{56,47},{56,63.6},{56.2,45.2},{56.2,49.2},{56.4,48.4},{56.4,50.6},{56.4,60.6},{57,50.8},{57.4,68},{57.8,49.2},{57.8,60.8},{58,49.6},{58.2,68},{58.4,64},{58.6,50.4},{59.6,53},{59.6,59.2},{60,60},{61.2,57.4},{62.8,52.8},{63.2,59.8}}},
        },
        [17413] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{26.9,37.46}}},
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
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{64.2,76.4}}},
        },
        [17713] = {
            [npcKeys.waypoints] = {},
        },
        [17715] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{86,54}}},
            [npcKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
        },
        [17334] = {
            [npcKeys.waypoints] = {},
        },
        [17336] = {
            [npcKeys.waypoints] = {},
        },
        [17544] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{92.6,37.5}}},
            [npcKeys.zoneID] = zoneIDs.SILVERMOON_CITY,
        },
        [17589] = {
            [npcKeys.waypoints] = {},
        },
        [17592] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE]={{72.81,20.83}}},
            [npcKeys.waypoints] = {},
        },
        [17612] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{31.8,25.4},{34.0,25.4},{34.4,22.8},{34.0,20.8},{34.6,17.6},{34.2,14.6},{35.2,12.6},{35.6,11.6}}},
        },
        [17831] = {
            [npcKeys.waypoints] = {[zoneIDs.ZANGARMARSH] = {{{23.32,66.21},{23.28,66.08},{23.39,65.98},{23.51,66.01},{23.67,66.09},{24.52,66.48},{24.69,66.5},{24.52,66.48},{23.7,66.18},{23.48,66.01},{23.39,66.01},{23.34,66.1},{23.32,66.21}}}},
        },
        [17839] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BLACK_MORASS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_BLACK_MORASS,
        },
        [17923] = {
            [npcKeys.waypoints] = {[zoneIDs.ZANGARMARSH] = {{{19,62.4},{19,63.5},{19.2,64.6}}}},
        },
        [17976] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BOTANICA] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_BOTANICA,
        },
        [18099] = {
            [npcKeys.waypoints] = {[zoneIDs.NAGRAND] = {{{60.68,25.15},{60.07,24.67},{59.31,24.05},{60.03,24.71},{61.12,24.83}}}},
        },
        [18120] = {
            [npcKeys.waypoints] = {},
        },
        [18121] = {
            [npcKeys.waypoints] = {},
        },
        [18152] = {
            [npcKeys.spawns] = {[zoneIDs.ZANGARMARSH] = {{26.4,22}}},
        },
        [18238] = {
            [npcKeys.npcFlags] = QuestieDB.npcFlags.QUEST_GIVER,
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{32.27,58.41},{37.92,27.53}}},
        },
        [18294] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{71.4,40.6}}},
            [npcKeys.zoneID] = zoneIDs.NAGRAND,
        },
        [18369] = {
            [npcKeys.waypoints] = {},
        },
        [18398] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{43.7,20.4}}},
        },
        [18399] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{43.7,20.4}}},
        },
        [18400] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{43.7,20.4}}},
        },
        [18401] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{43.7,20.4}}},
        },
        [18402] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{43.7,20.4}}},
        },
        [18472] = {
            [npcKeys.spawns] = {[zoneIDs.SETHEKK_HALLS] = {{-1,-1}}},
        },
        [18473] = {
            [npcKeys.spawns] = {[zoneIDs.SETHEKK_HALLS] = {{-1,-1}}},
        },
        [18537] = {
            [npcKeys.waypoints] = {},
        },
        [18538] = {
            [npcKeys.waypoints] = {},
        },
        [18542] = {
            [npcKeys.npcFlags] = 128,
        },
        [18816] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{41.2,44.2}}},
        },
        [18817] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{41.2,44.2}}},
        },
        [19305] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{13.64,39.12}}},
        },
        [19412] = {
            [npcKeys.spawns] = {[zoneIDs.AUCHENAI_CRYPTS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.AUCHENAI_CRYPTS,
        },
        [19456] = {
            [npcKeys.spawns] = {[zoneIDs.EVERSONG_WOODS] = {{37.8,86.2}}},
            [npcKeys.zoneID] = zoneIDs.EVERSONG_WOODS,
        },
        [19493] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM]={{40.8,72.6}}},
        },
        [19543] = {
            [npcKeys.waypoints] = {[zoneIDs.NETHERSTORM] = {{{60.4,88.01},{60.4,88.01}},{{56.74,86.64},{56.83,86.81},{56.85,86.83}}}},
        },
        [19544] = {
            [npcKeys.waypoints] = {[zoneIDs.NETHERSTORM] = {{{59.79,85.72},{59.82,85.65},{59.92,85.48},{60.29,84.92},{60.0,84.48},{59.76,84.54},{59.7,84.79},{59.76,84.56},{59.98,84.48},{60.29,84.9},{59.91,85.48},{59.83,85.66},{59.47,86.17},{59.76,85.75}},{{56.51,87.65},{56.39,87.75},{56.39,87.75}}}},
        },
        [19545] = {
            [npcKeys.waypoints] = {[zoneIDs.NETHERSTORM] = {{{59.74,87.05},{59.87,86.87},{59.53,86.36},{58.93,85.67},{59.37,86.13},{59.87,86.85},{59.71,87.13},{59.83,87.44},{59.64,87.72},{59.52,87.55},{59.64,87.74},{59.86,87.46},{59.71,87.1}},{{55.32,87.28},{55.1,87.53},{55.1,87.53},{55.11,87.51}}}},
        },
        [19546] = {
            [npcKeys.waypoints] = {[zoneIDs.NETHERSTORM] = {{{58.06,88.65},{58.09,88.7},{58.45,88.32},{59.07,88.35},{59.01,88.19},{59.07,88.3},{58.86,88.37},{58.4,88.35},{58.12,88.68},{57.74,88.08},{58.06,88.64}},{{55.43,86.62},{55.42,86.57},{55.46,86.51}}}},
        },
        [19622] = {
            [npcKeys.spawns] = {[zoneIDs.TEMPEST_KEEP] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.TEMPEST_KEEP,
        };
        [19644] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM] = {{31.36,66.15}}},
            [npcKeys.zoneID] = zoneIDs.NETHERSTORM,
        },
        [19657] = {
            [npcKeys.waypoints] = {[zoneIDs.NETHERSTORM] = {{{57.45,67.37},{57.36,67.08},{57.27,66.84},{57.17,66.59},{57.13,66.47},{57.2,66.31},{57.22,66.12},{57.24,65.95},{57.26,65.78},{57.12,65.76},{57.06,65.77},{57.12,65.76},{57.26,65.78},{57.24,65.95},{57.22,66.12},{57.2,66.31},{57.13,66.47},{57.17,66.59},{57.27,66.84},{57.36,67.08}}}},
        },
        [19671] = {
            [npcKeys.spawns] = {[zoneIDs.MANA_TOMBS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.MANA_TOMBS,
        },
        [19705] = {
            [npcKeys.waypoints] = {[zoneIDs.NETHERSTORM] = {{{56.06,66.4},{56.2,66.18},{56.42,66.34},{56.62,66.04},{56.81,65.71},{56.61,66.07},{56.42,66.35},{56.2,66.2},{56.05,66.43},{55.97,66.69},{55.8,66.74},{55.63,66.74},{55.39,66.82},{55.19,66.86},{55.4,66.81},{55.65,66.73},{55.82,66.74}}}},
        },
        [19909] = {
            [npcKeys.friendlyToFaction] = "H",
        },
        [19911] = {
            [npcKeys.friendlyToFaction] = "A",
        },
        [19915] = {
            [npcKeys.friendlyToFaction] = "A",
        },
        [19923] = {
            [npcKeys.friendlyToFaction] = "H",
        },
        [19925] = {
            [npcKeys.friendlyToFaction] = "A",
        },
        [19942] = {
            [npcKeys.spawns] = {[zoneIDs.BLASTED_LANDS]={{58.2,55}}},
        },
        [20145] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{45.6,82.4},{46.2,83.2},{46.6,83},{48.2,85},{48.8,82.4},{49.4,82.8},{50,82},{50.2,83.2},{50.2,83.6},{51,82.6}}},
        },
        [20390] = {
            [npcKeys.friendlyToFaction] = "H",
        },
        [20440] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM]={{26.07,38.78}}},
            [npcKeys.zoneID] = zoneIDs.NETHERSTORM,
        },
        [20497] = {
            [npcKeys.friendlyToFaction] = "A",
        },
        [20499] = {
            [npcKeys.friendlyToFaction] = "H",
        },
        [20518] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM]={{71.2,38.8}}},
            [npcKeys.zoneID] = zoneIDs.NETHERSTORM,
        },
        [20680] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{14.32,62.18}}},
            [npcKeys.waypoints] = {[zoneIDs.HELLFIRE_PENINSULA] = {{{14.34,61.07},{14.32,59.92},{14.32,58.88},{14.32,57.9},{14.32,56.98},{14.33,58.76},{14.31,59.58},{14.31,60.21},{14.31,60.95},{14.32,62.16},{14.32,62.16}}}},
        },
        [20706] = {
            [npcKeys.spawns] = {[zoneIDs.SETHEKK_HALLS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.SETHEKK_HALLS,
        },
        [21181] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{43.2,46.2}}},
        },
        [21118] = {
            [npcKeys.waypoints] = {},
        },
        [21446] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{38.8,56},{39,57.6},{39.2,57.4},{39.4,53},{40.2,50},{40.4,57.8},{42,57.2},{42,57.6},{42.4,53.8},{43,47.2},{43,50}}},
        },
        [21452] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{47.0,77.8},{46.6,79.2}}},
        },
        [21638] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{50.88,54.76}}},
        },
        [21651] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST]={{61,75.4},{61,75.6},{61,80},{61.4,73},{61.4,73.6},{61.6,73.2},{61.6,80},{62,74.4},{62,74.6},{63.2,79.6},{67.4,78.8},{67.4,79.6},{67.6,79.8},{67.8,79},{68.4,74.2},{68.6,73.6},{69.4,78.2},{69.4,79.2},{69.6,74.4},{69.6,78.4},{69.6,79},{70,74.8},{70,84.4},{70.2,83.2},{70.2,84.8},{70.8,84.8},{71.4,81.8},{71.4,82.6},{71.6,82.4},{71.6,82.6},{72.2,88},{72.6,83},{73,83.6},{73.4,80.4},{73.4,80.6},{74,80.2},{74,80.6},{74.6,87.4},{74.6,88.6},{75,86.2},{75,88},{75.2,81.2}}},
        },
        [21735] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{37.80,38.73}}},
        },
        [21763] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST]={{61,78.8},{61.4,75.4},{61.4,75.6},{61.4,78},{61.6,78},{61.8,75.6},{62,75},{62.2,74.4},{65.8,79.4},{66,79.6},{6.8,80.2},{68.4,85.2},{68.6,74.4},{69,85.6},{69.2,85.4},{69.4,74.8},{69.4,75.6},{69.6,74.4},{69.6,74.8},{69.6,76},{69.6,84.8},{69.8,79.6},{70,79.4},{70,83.6},{70.2,83.4},{70.4,82},{70.6,82.2},{71.8,85.6},{72,85.4},{72.2,88},{72.8,87.8},{73,84.4},{73,84.8},{73.4,82},{73.6,87.8},{73.8,83.2},{73.8,86},{73.8,86.6},{74.4,81},{74.4,84.2},{74.6,83},{74.6,87.4},{74.6,87.6},{75.2,81.2},{75.2,81.6}}},
        },
        [21787] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST]={{60.8,75.6},{61,74.8},{61,80.2},{61.2,79.2},{61.4,73.6},{61.8,73.4},{61.8,73.6},{62,74.6},{63,79.6},{65.8,78.2},{65.8,79.2},{66.4,79.8},{67.2,79},{67.4,79.8},{67.6,79.8},{68.2,73.8},{68.8,74},{69,78.8},{69.2,78.4},{69.4,74.6},{69.6,78.4},{69.8,75.2},{70,79.4},{70,79.6},{70.2,74.4},{70.2,83.2},{70.4,85},{70.6,84.2},{70.6,85},{71.2,82.4},{71.2,82.6},{71.6,81.8},{72,85.4},{72,85.6},{72.4,88},{73,82.8},{73,83.6},{73.4,80.2},{73.4,80.6},{73.6,81},{74,80.2},{74.4,88.4},{74.6,88.2},{74.6,88.6},{75,81.2},{75.2,86},{75.2,86.8}}},
        },
        [21959] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY]={{23.04,40.74},{23.18,40.73},{22.43,40.72},{22.72,40.95},{22.59,40.96},{23.18,41.21},{22.74,41.19},{23.03,41.2},{22.89,41.21},{22.42,41.19},{22.9,40.96},{23.18,40.97},{22.58,41.19},{23.04,40.96},{22.44,40.96},{22.13,40.27},{21.97,40.27},{22.14,40.04},{22.14,39.37},{22.16,38.92},{21.97,39.6},{21.81,39.39},{21.83,40.07},{21.99,38.92},{21.82,39.83},{21.82,39.61},{21.98,39.83},{21.97,40.06},{21.98,39.14},{21.97,39.38},{21.82,40.29},{21.82,39.16},{21.81,38.93}}},
        },
        [21962] = {
            [npcKeys.spawns] = {[zoneIDs.THE_ARCATRAZ] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_ARCATRAZ,
        },
        [21998] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{51.23,62.75},{52.45,59.19}}},
        },
        [22025] = {
            [npcKeys.waypoints] = {[zoneIDs.SHADOWMOON_VALLEY] = {{{39.78,30.03},{39.77,30.3},{39.88,30.65},{40.04,30.92},{40.12,30.89},{40.25,30.57},{40.41,30.42},{40.46,30.12},{40.45,29.65},{40.32,29.19},{39.71,29.14}}}},
        },
        [22059] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{51.23,62.75},{52.45,59.19}}},
        },
        [22370] = {
            [npcKeys.waypoints] = {[zoneIDs.TEROKKAR_FOREST] = {{{38.17,51.74},{38.22,50.7},{37.89,49.88},{37.16,50.22},{37.33,51.01}}}},
        },
        [22374] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{47.31,49.66}}},
        },
        [22408] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM] = {{35.6,66.6}}},
        },
        [22423] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{61.4,59.9},{64.9,68.1}}},
        },
        [22434] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{30.59,22.19}}},
        },
        [22441] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{48.7,67.2}}},
            [npcKeys.waypoints] = {},
        },
        [22454] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{44.4,74.0},{44.6,75.4},{45.0,74.4},{45.6,73.6}}},
        },
        [22817] = {
            [npcKeys.spawns] = {[zoneIDs.SHATTRATH_CITY]={{75.23,48.0},},},
            [npcKeys.zoneID] = zoneIDs.SHATTRATH_CITY,
        },
        [22818] = {
            [npcKeys.spawns] = {[zoneIDs.SHATTRATH_CITY]={{75.23,48.0},},},
            [npcKeys.zoneID] = zoneIDs.SHATTRATH_CITY,
        },
        [22911] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{77.5,31.1}}},
        },
        [22920] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{51.1,11.6}}},
        },
        [22932] = {
            [npcKeys.waypoints] = {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{{29.54,59.72},{30.6,59.5},{31.5,58.1},{31.5,56.8},{30.5,56.2},{30.0,54.5},{30.5,56.2},{31.5,56.8},{31.5,58.1},{30.6,59.5},{29.54,59.72}}}},
        },
        [23035] = {
            [npcKeys.spawns] = {[zoneIDs.SETHEKK_HALLS] = {{-1,-1},},},
        },
        [23053] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{55,45}}},
            [npcKeys.zoneID] = zoneIDs.BLADES_EDGE_MOUNTAINS,
        },
        [23068] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{70.1,74.4},},},
        },
        [23338] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{46.5,45.1},{60.6,60.1},},},
        },
        [23383] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{75.07,86.3},{68.4,74.1},{61.0,75.5},},},
        },
        [23786] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH] = {{40.6,68.0},{41.4,67.0},{42.2,65.8},{42.2,67.8},{42.4,67.2},{42.6,67.8},{43.0,65.4},{43.0,65.6},{43.4,67.0},{43.6,66.8},{43.8,67.6},{44.0,63.6},{44.0,65.2},{44.2,66.2},{44.6,65.6},{44.8,65.4},{44.8,66.6},{45.2,63.6},{45.6,68.4},{45.8,64.8},{46.0,66.2},{46.0,67.2},{46.2,69.0},{46.6,65.8}}},
        },
        [23789] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH] = {{52.2,76.2}}},
        },
        [23861] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH] = {{52.2,22.2},{52.4,24.2},{52.4,24.6},{52.4,27.4},{52.8,27.6},{53.0,21.6},{53.0,23.6},{53.0,27.2},{53.4,20.8},{53.6,27.8},{54.0,23.0},{54.0,29.0},{54.4,25.0},{55.0,21.4},{55.2,22.6},{55.4,22.0},{55.4,24.0},{55.8,21.0},{55.8,22.6},{56.0,24.0},{56.0,28.2},{56.0,28.6},{56.4,22.4},{56.4,27.4},{56.8,22.4},{56.8,23.4},{56.8,25.0},{57.0,23.8},{57.0,26.2},{57.0,30.4},{57.2,21.0},{57.2,26.8},{57.2,28.2},{57.4,30.6},{57.6,21.4},{57.6,23.2},{57.6,27.8},{57.6,28.8},{58.2,22.0},{58.2,26.4},{58.6,22.4},{58.6,26.0},{58.8,23.4},{59.2,25.0}}},
        },
        [23904] = {
            [npcKeys.spawns] = {[zoneIDs.SCARLET_MONASTERY] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.SCARLET_MONASTERY,
        },
        [24202] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{52,66.6}},[zoneIDs.IRONFORGE]={{30.2,66.5}}},
        },
        [24203] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{70.2,36.3}},[zoneIDs.IRONFORGE]={{64,78.2}}},
        },
        [24204] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{43.9,36.8}},[zoneIDs.IRONFORGE]={{64.3,24.3}}},
        },
        [24205] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{37.3,74.3}},[zoneIDs.IRONFORGE]={{32.2,21}}},
        },
        [24782] = {
            [npcKeys.spawns] = {[zoneIDs.DUSKWOOD] = {{16.9,33.4}}},
        },
        [24848] = {
            [npcKeys.spawns] = {[zoneIDs.MAGISTERS_TERRACE] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.MAGISTERS_TERRACE,
        },
        [24885] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{55.8,53.8}}},
        },
        [25324] = {
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{15.5,19.0},{9.3,13.0}}},
        },
        [25580] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{38.73,12.8}}},
        },
        [25863] = {
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{14.2,16.8},{14.4,18.2},{14.4,19.2},{14.4,19.8},{14.4,22.4},{15.0,18.2},{15.2,18.6},{15.4,17.4},{15.4,20.0},{15.4,20.8},{15.6,17.4},{15.6,20.2},{16.0,18.4},{16.0,19.2},{16.0,20.8},{16.6,19.2},{16.6,19.6},{16.8,18.4},{16.8,20.6}}},
        },
        [25888] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{44.5,52.5}}},
        },
        [25889] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{41.4,65.9}}},
        },
        [25891] = {
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE] = {{55.8,67.9}}},
        },
        [25892] = {
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{80.3,62.9}}},
        },
        [25899] = {
            [npcKeys.spawns] = {[zoneIDs.FERALAS] = {{28.3,43.9}}},
        },
        [25903] = {
            [npcKeys.spawns] = {[zoneIDs.NAGRAND] = {{49.7,69.4}}},
        },
        [25905] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{39.7,54.7}}},
        },
        [25907] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{54.1,55.6}}},
        },
        [25909] = {
            [npcKeys.spawns] = {[zoneIDs.WESTERN_PLAGUELANDS] = {{43.5,82.3}}},
        },
        [25912] = {
            [npcKeys.spawns] = {[zoneIDs.ZANGARMARSH] = {{69.1,51.9}}},
        },
        [25913] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM] = {{31.2,62.7}}},
        },
        [25918] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM] = {{32.0,68.0}}},
        },
        [25926] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{50.0,58.3}}},
        },
        [25929] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR] = {{52.2,47.3}}},
        },
        [25931] = {
            [npcKeys.spawns] = {[zoneIDs.EVERSONG_WOODS] = {{46.4,50.6}}},
        },
        [25933] = {
            [npcKeys.spawns] = {[zoneIDs.GHOSTLANDS] = {{46.9,26.3}}},
        },
        [25936] = {
            [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{51.8,59.8}}},
        },
        [25938] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{33.5,30.6}}},
        },
        [25946] = {
            [npcKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES] = {{57.2,51.8}}},
        },
        [25975] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL]={{56.56,92.09}},
                [zoneIDs.IRONFORGE]={{65.36,25.06}},
                [zoneIDs.STORMWIND_CITY]={{39.36,62.2}},
                [zoneIDs.THE_EXODAR]={{40.90,25.59}},
            },
        },
        [26116] = {
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{9.62,12.20},{9.25,11.50},{9.66,11.17}}},
        },
        [26178] = {
            [npcKeys.spawns] = {[zoneIDs.DESOLACE] = {{40.35,30.27},{40.26,31.35},{39.28,30.35}}},
        },
        [26204] = {
            [npcKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE] = {{21.17,22.74},{21.30,23.36},{21.26,24.30}}},
        },
        [26113] = {
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY]={{68.87,8.47}},
                [zoneIDs.THUNDER_BLUFF]={{21.72,25.35}},
                [zoneIDs.ORGRIMMAR]={{47.14,38.15}},
                [zoneIDs.SILVERMOON_CITY]={{69.48,42.45}},
            },
        },
        [26123] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{64.82,26.28}},
                [zoneIDs.TELDRASSIL]={{56.02,92.22}},
                [zoneIDs.THE_EXODAR]={{42.51,25.97}},
                [zoneIDs.STORMWIND_CITY]={{37.92,61.42}},
            },
        },
        [26124] = {
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY]={{68.07,11.2}},
                [zoneIDs.THUNDER_BLUFF]={{20.87,24.18}},
                [zoneIDs.ORGRIMMAR]={{47.36,39.22}},
                [zoneIDs.SILVERMOON_CITY]={{70.39,44.30}},
            },
        },
        [26214] = {
            [npcKeys.spawns] = {[zoneIDs.SEARING_GORGE] = {{16.02,36.87},{14.66,34.22},{13.55,37.20}}},
        },
        [26215] = {
            [npcKeys.spawns] = {[zoneIDs.SILITHUS] = {{66.60,20.62},{67.03,18.72},{67.45,20.14}}},
        },
        [26216] = {
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{84.2,47.0},{84.2,53.4},{85.4,47.0},{85.6,53.2},{85.8,47.2},{85.8,47.6}}},
        },
        [26221] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL]={{56.1,92.16}},
                [zoneIDs.UNDERCITY]={{66.9,13.53}},
                [zoneIDs.THUNDER_BLUFF]={{22.16,23.98}},
                [zoneIDs.SHATTRATH_CITY]={{60.68,30.62}},
                [zoneIDs.IRONFORGE]={{65.14,27.71}},
                [zoneIDs.ORGRIMMAR]={{46.44,38.69}},
                [zoneIDs.SILVERMOON_CITY]={{68.68,42.94}},
                [zoneIDs.THE_EXODAR]={{43.27,26.26}},
                [zoneIDs.STORMWIND_CITY]={{38.31,61.84}},
            },
        },
        [26760] = {
            [npcKeys.npcFlags] = npcFlags.NONE,
        },
        [178420] = {
            [npcKeys.name] = "Magister Astalor Bloodsworn",
            [npcKeys.minLevel] = 60,
            [npcKeys.maxLevel] = 60,
            [npcKeys.zoneID] = zoneIDs.SILVERMOON_CITY,
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{92.3,36.5}}},
            [npcKeys.friendlyToFaction] = "H",
        },

        -- Below are fake IDs to show specific quest starts/ends only at one specific location even though the
        -- corresponding real NPC has multiple spawns (e.g. "The Kessel Run" requires you to run to Azure Watch even
        -- though "Exarch Menelaous" also spawns at Bloodmyst Isle)

        [40000] = {
            [npcKeys.name] = "Exarch Menelaous",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 14,
            [npcKeys.zoneID] = zoneIDs.AZUREMYST_ISLE,
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{47.11,50.6}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [40001] = {
            [npcKeys.name] = "Admiral Odesyus",
            [npcKeys.minLevel] = 60,
            [npcKeys.maxLevel] = 60,
            [npcKeys.zoneID] = zoneIDs.AZUREMYST_ISLE,
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{47.04,70.21}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [40002] = {
            [npcKeys.name] = "Bristlelimb Furbolgs",
            [npcKeys.minLevel] = 10,
            [npcKeys.maxLevel] = 12,
            [npcKeys.zoneID] = zoneIDs.BLOODMYST_ISLE,
            [npcKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE] = {{68,81},{64.9,81.6},{64.2,76.4}}},
            [npcKeys.friendlyToFaction] = "",
        },
    }
end
