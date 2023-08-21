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
    local waypointPresets = QuestieDB.waypointPresets

    return {
        [658] = {
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH] = {{29.87,71.87}}},
        },
        [1105] = {
            [npcKeys.spawns] = {[zoneIDs.LOCH_MODAN]={{36.99,47.02}}},
        },
        [1721] = {
            [npcKeys.waypoints] = {[zoneIDs.STORMWIND_CITY]={{{73.27,55.49},{73.73,55.09},{75.57,56.13},{75.54,57.84},{75.91,58.32},{76.11,59.22},{76.37,59.7},{76.37,60.23},{76.64,60.47},{76.03,60.65},{75.74,62.34},{75.83,62.98},{76.46,63.65},{76.3,63.4},{75.79,63.03},{75.78,62.88},{72.89,62.06},{71.71,60},{71.21,59.16},{71.13,58.79},{70.6,58.07},{70.49,57.83},{70.71,57.55},{71.19,56.65},{72.54,55.16},{72.89,54.98},{73.27,55.49}}}},
        },
        [2079] = {
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.62,44.71}}},
        },
        [2142] = {
            [npcKeys.questStarts] = nil, -- corrected children's week quest
        },
        [3189] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{47,53.6}}},
        },
        [3190] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR] = {{42.1,15.0}}},
        },
        [3996] = {
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{35.77,49.1}}},
        },
        [4076] = {
            [npcKeys.spawns] = {[406]={{34.88,59.85},{31.82,59.91},{31.28,72.32},{30.51,74.54},{34.16,71.52}},[405]={{53.97,67.86},{68.35,49.33},{53.61,9.2},{64.06,23.28},{67.08,53.35},{41.45,85.11},{49.77,47.75},{45.09,36.34},{53.33,85.01},{50.6,27.03},{43.48,73.69},{67.95,81.93},{70.57,54.45},{38.03,75.25},{61.53,73.65},{77.8,43.63},{49.56,6.81},{77.07,52.31},{56.5,84.65},{64.05,33.14},{74.01,30.74}},[4100]={{55.3,2.04},{47.73,9.76},{42.87,14.73},{55.76,1.55},{42.95,14.23},{52.98,1.42},{47.6,9.6},{54.6,2.89}},[3792]={{-1,-1}},[3791]={{-1,-1}},[28]={{49.94,57.65},{45.49,21.05},{36.45,78.43},{50.31,60.09},{43.84,11.46},{54.35,34.13},{51.83,82.05},{48.94,45.56},{54.72,26.32},{51.69,39.66},{50.77,23.47},{49.57,50.1},{53.81,25.12},{42.2,19.96},{40.4,57.36},{48.59,42.98}},[495]={{32.96,10.34},{35.88,12.33},{36.5,14.89},{33.5,10.36},{35.7,15.91},{36.93,9.4},{36.56,11.4},{36.29,15.45}},[2557]={{-1,-1}},[2100]={{-1,-1}},[1583]={{-1,-1}},[722]={{-1,-1}},[4277]={{-1,-1}},[4494]={{74.05,76.21},{55.47,54.94},{55.12,40.53},{77.15,43.11},{60.57,29.98},{69.92,43.19},{63.7,60.09},{80.08,50.93},{60.35,78.57},{59.97,65.8},{82.95,56.71},{57.75,69.05},{77.61,53.91},{53.33,59.0},{84.06,64.27}},[4812]={{34.0,73.87},{34.11,74.39},{33.91,79.81},{34.47,75.32}}},
        },
        [5111] = {
            [npcKeys.questStarts] = {3790,8353},
        },
        [6740] = {
            [npcKeys.questStarts] = {3789,8356},
        },
        [11886] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{24.8,79.8}}},
        },
        [14305] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{56.1,54.3}}}, -- Human Orphan, only WOTLK
        },
        [14842] = {
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE] = {{29.65,75.25}}},
            [npcKeys.waypoints] = {[zoneIDs.IRONFORGE] = {{{50.55,82.85},{50.53,83.71},{49.19,84.47},{46.53,84.65},{43.28,84.31},{41.55,83.87},{38.55,82.34},{36.72,81.3},{34.22,79.88},{31.64,78.36},{29.65,75.25},{27.58,71.68},{24.97,66.97},{23.38,62.81},{22.38,58.13},{21.78,54.25},{21.56,50.41},{21.48,47.63},{21.56,43.81},{21.73,40.75},{22.3,36.8},{22.9,34.03},{24.24,34.15},{24.76,35.01},{24.34,37.9},{24.49,39.16},{24.54,40.85},{24.19,44.54},{23.81,47.81},{24.47,52.25},{25.04,56.1},{25.33,58.08},{26.44,58.53},{28.97,58.59},{28.14,66.92},{29.77,69.53},{34.9,71.1},{34.75,75.56},{36.0,76.98},{37.81,78.22},{40.32,79.37},{41.78,79.98},{42.85,80.12},{44.2,80.44},{46.47,80.61},{47.45,80.77},{49.36,81.07},{50.27,81.22},{50.58,82.28}}}},
            [npcKeys.zoneID] = zoneIDs.IRONFORGE,
        },
        [14881] = {
            [npcKeys.spawns] = {[4196]={{-1,-1}},[1196]={{-1,-1}},[3805]={{-1,-1}},[3433]={{45.32,31.32},{52.28,18.77},{76.66,17.02},{68.59,32.27},{77.24,33.38},{68.89,32.33},{52.37,19.12},{38.6,16.14},{30.17,25.42},{24.06,19.96},{27.3,31.04},{20.49,52.45},{42.78,53.18}},[3959]={{-1,-1}},[3790]={{-1,-1}},[3792]={{-1,-1}},[3791]={{-1,-1}},[3789]={{-1,-1}},[495]={{69.66,52.14},{70.69,54.13},{37.69,9.4},{64.6,37.88},{35.54,13.38},{35.17,11.25},{64.83,41.44},{35.83,16.85},{33.58,12.58},{34.58,14.38},{36.07,11.05},{35.64,10.82},{33.93,13.78},{38.43,9.03},{38.71,11.56}},[3456]={{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1},{-1,-1}},[3457]={{-1,-1}},[1977]={{-1,-1}},[4277]={{-1,-1}},[4415]={{51.16,66.81},{25.37,26.61},{39.21,66.89},{41.73,13.77}},[4494]={{70.61,29.58},{56.41,64.8},{72.65,33.51},{66.31,47.35},{59.43,44.25},{72.51,37.6},{86.18,73.16},{82.7,42.93},{73.11,31.36},{66.73,46.29},{74.38,42.19},{76.94,20.42},{68.65,35.06},{46.41,65.45},{56.34,51.78},{51.26,53.5}},[4812]={{34.06,75.98},{34.04,73.36},{34.41,75.45},{28.7,19.4},{29.01,20.35},{28.85,18.59},{29.02,18.33},{33.6,75.48},{29.84,18.28},{29.5,21.16},{29.13,20.52},{30.02,20.3},{34.04,73.78},{34.48,75.29},{34.59,78.32},{32.96,78.3},{33.63,75.18},{34.06,75.98},{34.16,75.8},{33.7,78.81},{33.96,72.62},{34.06,76.77},{34.09,77.08}},[4809]={{42.13,19.94},{43.07,18.37},{40.13,12.27},{40.3,13.91},{40.12,11.08}},[4813]={{53.78,30.91},{50.18,34.18},{46.53,47.95},{57.41,60.4},{50.96,36.2},{58.65,31.85},{39.35,70.11},{55.04,17.7},{63.01,22.24},{44.1,72.79},{61.49,30.02},{49.27,45.11},{44.18,53.8},{54.95,62.3},{49.72,62.62},{60.35,30.97},{59.26,19.19},{52.33,17.61},{56.04,18.17}},[4820]={{37.19,11.29},{38.25,12.64},{38.98,13.82},{37.43,11.58},{38.99,13.81},{38.72,12.99}}},
        },
        [15278] = {
            [npcKeys.spawns] = {[zoneIDs.EVERSONG_WOODS] = {{38.02,21.01}}},
        },
        [15351] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{24.55,55.42}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
            },
        },
        [15576] = {
            [npcKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE] = {{26.5,76.5}}},
        },
        [15892] = {
            [npcKeys.spawns] = {
            [zoneIDs.STORMWIND_CITY]={{61.73,75.73}},
            [zoneIDs.IRONFORGE]={{30.4,61.4},{30.4,61.6},{30.6,17.8},{30.6,61.4},{30.8,61.8},{31.2,63.2},{31.6,62.8}},
            [zoneIDs.DARNASSUS]={{42.16,43.97},{32.2,12.2}},
            [zoneIDs.DALARAN]={{48.96,44.53},{49.35,43.57},{49.78,44.62}},
            [zoneIDs.SHATTRATH_CITY]={{53.51,34.4},{53.32,35.34},{52.88,34.63}}},
        },
        [16281] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.39}}},
        },
        [16361] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.45}}},
        },
        [16075] = {
            [npcKeys.spawns] = {}, -- Replaced in WotLK
        },
        [16438] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH]={{47.4,40.4},{48.2,40.8},{48.4,38.4},{48.4,41.6},{48.8,40.8},{49,36.8},{49.2,38.8},{49.2,40},{49.6,36.2},{50,38.6},{50,40.2},{50,40.6},{50.4,42.8},{50.4,43.6},{50.4,44.8},{50.6,40.6},{51.2,43.6},{51.2,45},{51.4,39.6},{51.4,41.6},{51.4,45.6},{51.6,41.2},{51.6,43},{51.6,43.8},{51.6,44.8},{51.8,42},{51.8,45.8},{52.6,43.8},{52.8,44.8}},
                [zoneIDs.MULGORE]={{39.43,38.54},{38.78,38.51},{39.04,38.51},{38.71,38.04},{39.4,37.54},{38.76,37.49},{38.35,37.39},{38.99,37.18},{40.3,37.03},{38.32,37.01},{38.37,36.59},{39.37,36.49},{39.0,36.15},{38.73,36.06},{38.34,35.42}},
                [zoneIDs.DUROTAR]={{44.42,18.56},{44.71,18.02},{43.9,17.97},{45.3,17.93},{45.04,17.61},{44.36,17.53},{45.29,16.99},{44.42,16.98},{45.25,16.64},{45.03,16.57},{43.97,16.55},{45.58,16.5},{44.94,16.39},{44.67,16.13},{45.67,15.99},{45.83,15.97}},
                [zoneIDs.TELDRASSIL]={{38.17,57.75},{38.38,57.18},{38.7,57.17},{38.13,56.67},{38.36,56.66},{37.76,56.29},{36.44,56.19},{36.78,56.13},{38.78,56.12},{38.09,55.73},{38.41,55.66},{37.48,55.22},{38.12,55.16},{37.11,54.81},{36.77,54.75},{36.77,54.66},{36.76,54.66}}
            },
        },
        [16817] = { 
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL]={{56.5,92.3}},
                [zoneIDs.STORMWIND_CITY]={{49.53,72.27}},
                [zoneIDs.IRONFORGE]={{63.81,25.31}},
                [zoneIDs.SHATTRATH_CITY]={{61.39,31.91}},
                [zoneIDs.THE_EXODAR]={{41.62,25.28}},
            },
        },
        [16475] = {
            [npcKeys.spawns] = {[zoneIDs.AZUREMYST_ISLE] = {{84.19,43.03}}},
        },
        [17663] = {
            [npcKeys.name] = "Maatparm",
        },
        [17718] = {
            [npcKeys.questStarts] = {9684,9681},
        },
        [17977] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BOTANICA]={{-1,-1}}},
        },
        [19220] = {
            [npcKeys.spawns] = {[zoneIDs.THE_MECHANAR]={{-1,-1}}},
        },
        [19481] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM]={{58.34,86.4}}},
        },
        [22515] = {
            [npcKeys.spawns] = {[4264]={{70.68,57.53},{71.63,57.69},{59.72,39.98},{63.76,39.98}},[4131]={{-1,-1}},[4075]={{-1,-1}},[1196]={{-1,-1}},[3805]={{-1,-1}},[3959]={{-1,-1}},[3562]={{-1,-1}},[495]={{57.65,77.64},{60.53,78.47},{58.97,80.08},{58.71,78.18},{59.2,76.94},{59.78,79.37},{60.5,80.44},{57.84,75.7},{61.86,79.8}},[210]={{44.94,61.23},{45.33,60.99},{45.53,62.56},{44.84,62.0}},[4197]={{46.88,43.15}},[4384]={{50.19,45.79},{47.32,45.25},{50.08,44.72},{47.13,44.65}},[2597]={{42.36,13.25}},[4196]={{39.21,21.91},{48.25,10.59},{44.3,10.39},{46.08,10.63}},[4277]={{-1,-1}},[4273]={{39.71,29.29},{39.74,26.52},{39.71,23.82}},[4710]={{53.16,78.39},{44.96,26.93},{51.45,26.9},{52.3,26.94},{48.72,23.31},{47.96,30.87},{49.23,32.2},{47.89,78.23},{49.32,78.25},{52.15,72.32},{51.24,80.86},{54.45,78.97},{52.24,74.48},{45.78,26.83}},[4812]={{32.42,20.8},{31.22,20.81}},[4723]={{56.99,83.83}},[4820]={{41.07,13.75}}},
        },
        [23472] = {
            [npcKeys.spawns] = {[4075]={{-1,-1}},[1196]={{-1,-1}},[3959]={{-1,-1}},[4395]={{49.8,47.27}},[4197]={{56.14,20.62},{49.58,16.33},{31.75,38.45},{32.28,38.7},{66.59,67.42},{66.62,68.38},{45.15,17.5},{45.13,16.47},{65.17,38.64},{64.47,38.47},{34.63,67.72},{34.54,68.64},{54.12,16.53},{54.13,17.45},{45.41,23.68},{43.98,20.7},{52.23,26.44},{54.66,23.53},{47.81,26.53},{50.4,15.87}},[4384]={{50.2,72.24},{41.15,59.32},{58.66,56.38},{39.26,42.52},{58.96,38.04}},[2597]={{44.11,1.48}},[4277]={{-1,-1}}},
        },
        [23763] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{50.2,29.2},{50.4,26.4},{50.4,27},{50.6,26.6},{51,26.2},{51,27.6},{51.2,25.4},{51.2,28.8},{51.6,25.4},{51.8,27.6},{52,29.6},{52.2,26.4},{52.2,26.6},{52.4,28.6},{52.6,28.6},{52.8,26.4},{52.8,27},{52.8,27.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [23931] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55,57.6}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [23953] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP_LOWER_LEVEL]={{29.6,65.1}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [23954] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP_UPPER_LEVEL]={{75.8,35.5}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [24028] = { --"Talu Frosthoof", "Bowyer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24031] = { --"Camp Winterhoof Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24032] = { --"Celea Frozenmane", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24033] = { --"Bori Wintertotem", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24060] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{45.2,27.3}}},
        },
        [24067] = { --"Mahana Frosthoof", "Stable Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24083] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP_UPPER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
        },
        [24120] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{86.7,59.2}}},
        },
        [24123] = { --"Nokoma Snowseer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24127] = { --"Ahota Whitefrost"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24129] = { --"Chieftain Ashtotem"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24130] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{45.2,27.3}}},
        },
        [24135] = { --"Greatmother Ankha"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24137] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [24142] = { --"Camp Winterhoof Wind Rider"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24161] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{69.6,38.6}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24162] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{69.6,39.8}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24170] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{39.2,50.2},}},
        },
        [24173] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{52.4,3.9},}},
        },
        [24186] = { --"Sage Mistwalker"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24195] = { --"Winterhoof Longrunner"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24209] = { --"Longrunner Skycloud"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24211] = { --"Freed Winterhoof Longrunner"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24213] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55.00,57.43}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24214] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55.00,57.43}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24215] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55.00,57.43}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24234] = { --"Junat the Wanderer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24236] = { --"Wind Tamer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24256] = { --"Wind Tamer Kagan"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24329] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{72,26.4},{70.3,27.3},{68.7,28.1},{66.5,24.9},{69.7,21.5},{72.6,19.9},{73.6,23.1}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24362] = { --"Longrunner Pembe"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24390] = { --"Sage Edan"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24440] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{30.2,26.4},{30.4,27},{30.6,24},{30.8,23.4},{30.8,26.6},{30.8,28.2},{30.8,28.6},{31,24.6},{31,26.4},{31.2,31},{31.6,27.2},{31.6,27.6},{31.8,26},},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24657] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{45.01,17.41}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [24702] = { --"Greatfather Mahan"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24703] = { --"Chieftain Wintergale"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24706] = { --"Durm Icehide"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24709] = { --"Sage Aeire"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24730] = { --"Wind Tamer Barah"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24733] = { --"Snow Tracker Junek"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24910] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{37.19,74.79}},
            },
            [npcKeys.waypoints] = {[zoneIDs.HOWLING_FJORD]={{{37.19,74.79},{37.22,74.80},{37.28,74.80},{37.36,74.81},{37.46,74.83},{37.58,74.87},{37.71,74.94},{37.82,75.07},{37.90,75.24},{37.93,75.46},{37.92,75.71},{37.88,76.01},{37.82,76.37},{37.84,76.74},{37.93,77.01},{38.02,77.33},{38.11,77.69},{38.22,78.10},{38.34,78.53},{38.50,79.00},{38.69,79.48},{38.91,79.90},{39.12,80.21},{39.38,80.50},{39.67,80.78},{39.98,81.05},{40.30,81.31},{40.62,81.56},{40.94,81.78},{41.24,82.00},{41.52,82.19},{41.81,82.38},{42.17,82.62},{42.50,82.83},{42.82,83.00},{43.13,83.14},{43.42,83.24},{43.70,83.31},{44.06,83.36},{44.43,83.35},{44.79,83.27},{45.11,83.16},{45.42,83.03},{45.75,82.79},{45.95,82.35},{46.03,81.83},{46.03,81.30},{46.02,80.80},{45.92,80.33},{45.74,79.89},{45.53,79.48},{45.31,79.12},{45.06,78.73},{44.88,78.28},{44.75,77.81},{44.65,77.29},{43.16,77.68},{43.13,77.68},{43.10,77.69},{43.05,77.69},{42.98,77.68},{42.90,77.67},{42.80,77.64},{42.69,77.60},{42.56,77.54},{42.41,77.45},{42.24,77.34},{42.07,77.21},{41.89,77.06},{41.73,76.91},{41.59,76.77},{41.47,76.64},{41.37,76.53},{41.29,76.43},{41.22,76.34},{41.16,76.28},{41.12,76.23},{41.09,76.19},{41.08,76.17},{41.04,76.12},{41.01,76.08},{40.95,76.03},{40.89,75.96},{40.81,75.88},{40.71,75.78},{40.60,75.67},{40.49,75.54},{40.36,75.40},{40.24,75.25},{40.13,75.10},{40.03,74.97},{39.95,74.85},{39.88,74.74},{39.83,74.65},{39.78,74.57},{39.74,74.51},{39.72,74.47},{39.70,74.44},{39.67,74.41},{39.64,74.36},{39.60,74.29},{39.55,74.20},{39.49,74.10},{39.42,73.97},{39.35,73.81},{39.29,73.62},{39.22,73.41},{39.16,73.18},{39.11,72.97},{39.07,72.78},{39.04,72.61},{39.01,72.47},{38.98,72.35},{38.97,72.25},{38.95,72.18},{38.94,72.13},{38.93,72.11},{38.92,72.08},{38.91,72.04},{38.88,71.97},{38.85,71.87},{38.82,71.75},{38.78,71.61},{38.75,71.43},{38.71,71.22},{38.66,70.99},{38.62,70.72},{38.57,70.45},{38.53,70.21},{38.49,69.99},{38.46,69.81},{38.43,69.66},{38.41,69.53},{38.39,69.42},{38.38,69.34},{38.37,69.28},{38.37,69.25},{38.36,69.23},{38.36,69.19},{38.34,69.13},{38.31,69.05},{38.28,68.95},{38.24,68.82},{38.19,68.67},{38.13,68.50},{38.07,68.31},{37.99,68.11},{37.89,67.89},{37.78,67.66},{37.62,67.43},{37.45,67.28},{37.25,67.19},{37.01,67.13},{36.74,67.11},{36.44,67.13},{36.12,67.20},{35.77,67.35},{35.50,67.56},{35.23,67.84},{34.94,68.16},{34.65,68.51},{34.37,68.87},{34.10,69.25},{33.86,69.61},{33.64,69.96},{33.48,70.36},{33.43,70.83},{33.48,71.32},{33.60,71.82},{33.77,72.30},{33.97,72.75},{34.20,73.17},{34.42,73.53},{34.61,73.87},{34.83,74.16},{35.08,74.36},{35.34,74.50},{35.60,74.60},{35.84,74.66},{36.07,74.71},{36.27,74.75},{36.44,74.78},{36.60,74.80},{36.73,74.81},{36.83,74.82},{36.93,74.83},{37.00,74.82},{37.06,74.82},{37.11,74.81},{37.15,74.80},{37.17,74.79}}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [25320] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{42.59,36.75},{40.44,39.15},{41.79,42.55}}},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25335] = { --"Longrunner Proudhoof"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25455] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{50.25,9.66},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25469] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{33.2,62.2},{33.6,59.8},{34,58.4},{34,63.8},{34.4,56.8},{34.4,63},{34.8,59},{34.8,63},{34.8,65.6},{35,61.8},{35,68.4},{35,68.8},{35.2,57.2},{35.2,63.8},{35.2,64.8},{35.4,58},{35.4,67},{35.6,60.8},{35.6,64.2},{35.6,64.6},{35.6,67.8},{35.8,60.4},{35.8,62.2},{35.8,62.6},{35.8,65.6},{36,58},{36,66.6},{36,73.6},{36.2,59.2},{36.4,69.8},{36.4,70.8},{36.6,57.2},{36.6,61.2},{36.6,70.4},{36.6,70.8},{36.8,68.6},{37,62.4},{37,62.6},{37,68},{37.2,59.4},{37.2,67},{37.4,58.4},{37.4,60.2},{37.6,59.2},{37.6,60.4},{37.6,61.2},{37.6,65.8},{38,69.4},{38.2,67},{38.2,68},{38.6,67},{38.6,69.2},{39.8,71.4},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25516] = { --"Snow Tracker Grumm"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25602] = { --"Greatmother Taiga"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25604] = { --"Sage Highmesa"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25658] = { --"Longrunner Bristlehorn"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25790] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{46.04,62.01}}},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25794] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{70.3,36.7},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25889] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{41.57,65.92}}},
        },
        [25912] = {
            [npcKeys.spawns] = {[zoneIDs.ZANGARMARSH] = {{68.79,51.95}}},
        },
        [25918] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM] = {{32.11,68.31}}},
        },
        [25926] = {
            [npcKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{49.92,58.66}}},
        },
        [25938] = {
            [npcKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY] = {{33.4,30.53},},},
        },
        [25975] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL]={{56.56,92.09}},
                [zoneIDs.IRONFORGE]={{65.36,25.06}},
                [zoneIDs.STORMWIND_CITY]={{50.13,72.56}},
                [zoneIDs.THE_EXODAR]={{40.90,25.59}},
            },
        },
        [25978] = { --"Ambassador Talonga"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25982] = { --"Sage Earth and Sky"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25983] = { --"Dorain Frosthoof", "Apprentice Wind Tamer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26104] = { --"Iron Eyes"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26105] = {
            [npcKeys.spawns] = {[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [26123] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{64.82,26.28}},
                [zoneIDs.TELDRASSIL]={{56.02,92.22}},
                [zoneIDs.THE_EXODAR]={{42.51,25.97}},
                [zoneIDs.STORMWIND_CITY]={{49.03,71.95}},
            },
        },
        [26156] = { --"Wartook Iceborn"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26157] = { --"Taunka'le Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26158] = { --"Mother Tauranook"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26159] = { --"Taunka'le Evacuee"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26170] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{84.8,41.68},},},
        },
        [26179] = { --"Taunka'le Refugee"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26184] = { --"Taunka'le Refugee"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26401] = { -- Summer Scorchling
            [npcKeys.spawns] = {[3518]={{49.57,69.4}},[3521]={{68.73,51.95}},[3522]={{41.52,65.87}},[3519]={{54.01,55.57}},[3520]={{39.63,54.56}},[3523]={{31.16,62.65}},[141]={{55.0,60.41}},[405]={{66.19,17.1}},[15]={{61.87,40.5}},[45]={{49.94,44.79}},[33]={{33.94,73.56}},[267]={{50.45,47.45}},[11]={{13.5,46.97}},[12]={{43.48,62.5}},[44]={{26.08,59.25}},[47]={{14.41,50.01}},[40]={{55.86,53.39}},[1]={{46.69,46.85}},[38]={{32.59,41.1}},[10]={{73.77,54.5}},[4]={{59.3,16.88}},[1377]={{57.56,35.23}},[618]={{62.52,35.47}},[440]={{52.79,29.32}},[331]={{37.79,54.81}},[148]={{36.95,46.23}},[3483]={{62.2,58.25}},[67]={{41.42,86.75}},[2817]={{78.07,74.91}},[66]={{40.37,61.4}},[495]={{57.84,16.18}},[394]={{33.94,60.52}},[65]={{75.24,43.77}},[3537]={{55.15,19.92}},[3711]={{48.12,65.93}},[3524]={{44.4,52.48}},[3525]={{55.81,67.74}},[357]={{28.27,43.86}},[46]={{80.28,63.03}},[28]={{43.43,82.24}},},
        },
        [26488] = { --"Taunka Pack Kodo"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26520] = { -- Festival Scorchling
            [npcKeys.spawns] = {[67]={{40.27,85.41}},[2817]={{80.08,53.21}},[66]={{43.42,71.81}},[495]={{48.64,13.09}},[394]={{19.26,61.17}},[65]={{38.31,48.45}},[3537]={{51.16,11.47}},[3711]={{46.74,61.65}},[3430]={{46.41,50.51}},[3433]={{46.89,26.48}},[85]={{57.29,51.76}},[130]={{49.65,38.4}},[267]={{58.65,25.52}},[45]={{74.27,41.38}},[47]={{76.66,75.07}},[33]={{32.89,75.18}},[8]={{46.73,47.17}},[46]={{61.86,29.12}},[3]={{4.7,48.79}},[3519]={{51.97,42.96}},[3520]={{33.62,30.64}},[3522]={{49.92,58.75}},[3523]={{32.16,68.33}},[3483]={{57.17,41.99}},[3521]={{35.47,51.69}},[3518]={{50.97,34.13}},[14]={{52.15,47.25}},[618]={{59.88,35.58}},[331]={{70.2,69.31}},[17]={{52.22,28}},[15]={{33.49,30.91}},[400]={{42.36,52.93}},[440]={{49.81,26.99}},[1377]={{46.41,44.56}},[357]={{72.41,47.76}},[405]={{26.13,77.01}},[406]={{50.54,60.41}},[215]={{51.88,59.77}},},
        },
        [26527] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_VILLAGE]={{86.45,61.47}},[4100]={{-1,-1}}},
        },
        [26533] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_CITY]={{32.3,46.2}},[4100]={{-1,-1}}},
        },
        [26555] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{-1,-1}},[1196] = {{-1,-1}}},
        },
        [26584] = { --"Sage Paluna"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26620] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26621] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26623] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26631] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{69.7,47.3}},[4196]={{-1,-1}}},
        },
        [26632] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{47.6,13.3}},[4196]={{-1,-1}}},
        },
        [26633] = {
            [npcKeys.spawns] = {
                [zoneIDs.GRIZZLY_HILLS] = {{51.8,18.2}},
            },
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [26635] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26636] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26637] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
            [npcKeys.waypoints] = {},
        },
        [26638] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26639] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26647] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{54.50,23.62}},
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [26664] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{69.9,22.1},{67.6,30.6},{63.7,25},{64,14.2},{69.7,15.1},{71.2,17.5}},[4196]={{-1,-1}}},
        },
        [26669] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
        },
        [26670] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
        },
        [26691] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
        },
        [26694] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL]={{-1,-1}},[zoneIDs.UTGARDE_KEEP]={{-1,-1}}},
        },
        [26680] = { --"Aiyan Coldwind", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26696] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{42.8,52.7},{42.8,54.1},{49.4,53.3},{49.4,53.9},{61.8,35.6}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{55.6,33.5},{57.5,18.4}},[1196] = {{-1,-1}}},
            [npcKeys.waypoints] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL]={{{49.4,53.3},{55.9,53.9}}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL]={{{48.4,44.5},{51.5,42.8},{54,38.9},{56,38.2},{55.9,42.9},{55,46.2},{53,47.9},{50.9,45.9},{48.4,44.5}}}},
        },
        [26697] = { --"Tewah Chillmane", "Leather Armor Merchant"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26707] = { --"Litoko Icetotem", "Armor Merchant"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26709] = { --"Pahu Frosthoof", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26718] = { --"Trader Alorn", "General Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26720] = { --"Danook Stormwhisper", "Trade Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26721] = { --"Halona Stormwhisper", "Stable Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26723] = {
            [npcKeys.spawns] = {[zoneIDs.THE_NEXUS_MAP] = {{36.1,67.4}},[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [26725] = { --"Wind Tamer Oril"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26766] = { --"Brave Storming Sky"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26790] = { --"Taunka'le Longrunner"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26792] = {
            [npcKeys.spawns] = {[zoneIDs.THE_NEXUS_MAP] = {{50.2,68.4},{54.7,55.9},{58.5,55.3},{59.8,48.5},{65.1,51.2},{62.6,63.9}},[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [26810] = { --"Roanauk Icemist", "High Chieftain of the Taunka"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26830] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [26847] = { --"Omu Spiritbreeze", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26853] = { --"Makki Wintergale", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26861] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{40.9,53.4}},[1196] = {{-1,-1}}},
        },
        [26935] = {
            [npcKeys.waypoints] = {},
        },
        [26936] = { --"Chaska Frosthoof", "General Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26939] = { --"Koro the Wanderer", "Trade Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26944] = { --"Soulok Stormfury", "Stable Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26950] = { --"Sanut Swiftspear", "Reagents and Poisons"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26986] = { --"Tiponi Stormwhisper", "Grand Master Skinning Trainer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26996] = { --"Awan Iceborn", "Grand Master Leatherworker"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [27126] = { --"Camp Oneqwah Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [27199] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{71.41,23.78}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27216] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{45.25,17.33}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [27221] = { --"Tormak the Scarred", "Camp Oneqwah Chieftain"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [27315] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{77.2,49.8},{78.2,50.6},{78.8,50.8},{79.8,49.6},{80,49.4},{80,51},{81.8,50.6},{82.2,50.4},{83,49.2},{83,50.2},{83.4,51},{84.2,50.4},{84.6,51.6},{84.8,50.4},}
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [27328] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{52.62,24.06}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27431] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [27575] = { -- #4675
            [npcKeys.name] = "Lord Devrestrasz",
        },
        [27627] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{62.18,42.41}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27641] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_ACCELERATION]={{40.9,67.1},{40.1,55.2},{57.6,54.1},{57.5,66},{72.2,73.3},{72.7,77.4},{74.7,75.3},{27.4,79.8},{25.9,81.2},{25.8,78.5}},[4228]={{-1,-1}}},
        },
        [27642] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_TRANSMUTATION]={{-1,-1}},[4228]={{-1,-1}}},
        },
        [27655] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_ALIGNMENT]={{39.7,35.7}},[4228]={{-1,-1}}},
        },
        [27656] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_ALIGNMENT]={{47.3,13.3}},[4228]={{-1,-1}}},
            [npcKeys.waypoints] = {[zoneIDs.BAND_OF_ALIGNMENT]={{{47.3,13.3},{43.8,13.9},{40.5,15.5},{37.2,18.4},{34.4,22.2},{31.9,27},{30,33.7},{29.3,40.3},{29.9,48.7},{31.8,55.3},{34.2,60},{37.5,64.4},{42,68},{47.8,69.5},{53.3,68.3},{57.3,65.4},{60.7,61.9},{63.4,56.9},{65.9,48.9},{66.4,43.4},{66.3,36.6},{64.6,28.4},{62.3,23},{58.2,17.8},{54,14.8},{50.1,13.3},{47.3,13.3}}}},
        },
        [27658] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_VARIANCE]={{50,81.2}},[4228]={{-1,-1}}},
        },
        [27447] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_ACCELERATION]={{46.1,19.1}},[4228]={{-1,-1}}},
        },
        [27715] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27716] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27717] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27718] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27727] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27744] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_CITY]={{66.4,28},{62.1,31.1},{59.3,27.1},{57.8,32.2}},[4100]={{-1,-1}}},
        },
        [27871] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [27909] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_LOWER_LEVEL]={{-1,-1}},[4196]={{-1,-1}}},
        },
        [27915] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_VILLAGE]={{47.5,39.7}},[4100]={{-1,-1}}},
        },
        [27959] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD] = {{61.1,2}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [27978] = {
            [npcKeys.spawns] = {[zoneIDs.HALLS_OF_STONE_MAP]={{49.9,13.3}},[4264]={{-1,-1}}},
        },
        [28012] = {
            [npcKeys.spawns] = {[zoneIDs.BAND_OF_ACCELERATION]={{46.1,19.1}},[zoneIDs.BAND_OF_ALIGNMENT]={{39.7,35.7}},[4228]={{-1,-1}}},
        },
        [28013] = {
            [npcKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{71.81,82.70}}},
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [28016] = {
            [npcKeys.spawns] = {[zoneIDs.DRAKTHARON_KEEP_UPPER_LEVEL]={{47.6,13.3}},[4196]={{-1,-1}}},
        },
        [28026] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{35.21,64.79},{37.15,64.77},{36.51,64.55},{37.99,65.5},},},
        },
        [28070] = {
            [npcKeys.spawns] = {[zoneIDs.HALLS_OF_STONE_MAP]={{71.1,48.5}},[zoneIDs.HALLS_OF_STONE]={{-1,-1}},},
            [npcKeys.zoneID] = zoneIDs.HALLS_OF_STONE,
            [npcKeys.waypoints] = {},
        },
        [28083] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{49.8,85},{51.6,86.2},{58,83.8},{58.8,85.6},},},
        },
        [28136] = {
            [npcKeys.spawns] = {},
        },
        [28142] = {
            [npcKeys.spawns] = {},
        },
        [28148] = {
            [npcKeys.spawns] = {},
        },
        [28314] = { --"Longrunner Nanik"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [28341] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_CITY]={{-1,-1}}},
        },
        [28358] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{57.4,52.2},{58.4,53.8},},},
        },
        [28546] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{60.9,77.2}},[zoneIDs.HALLS_OF_LIGHTNING]={{-1,-1}}},
        },
        [28584] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{-1,-1}},[zoneIDs.HALLS_OF_LIGHTNING]={{-1,-1}}},
        },
        [28587] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{37.6,20.9}},[zoneIDs.HALLS_OF_LIGHTNING]={{-1,-1}}},
        },
        [28684] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{50.2,44.6}},[4277]={{-1,-1}}},
        },
        [28729] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28730] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28731] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28732] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28733] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28734] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28826] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{-1,-1}},[zoneIDs.HALLS_OF_LIGHTNING]={{-1,-1}}},
        },
        [28838] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{40.1,66.5},{45,82.6},{40.2,84},{45.1,68.1},{32.7,75.8},{33.2,75.8},{51.2,75.8},{51.9,75.8}},[zoneIDs.HALLS_OF_LIGHTNING]={{-1,-1}}},
            [npcKeys.waypoints] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{{32.7,75.8},{32.9,72.2},{34.2,70.4},{36.2,69.4},{39.1,70.4},{40.7,72.2},{41.3,74.9},{40.7,77.8},{39.1,80.3},{36.4,81.1},{34.5,80.7},{32.9,78.8},{32.7,75.8}},{{51.2,75.8},{51.1,78.8},{49.5,80.1},{47.8,80.7},{45.6,80.3},{44.3,77.6},{43.8,75.3},{44.3,72.5},{45.8,70.8},{47.8,69.8},{49.8,70.6},{50.8,72.2},{51.2,75.8}}}},
        },
        [28912] = {
            [npcKeys.waypoints] = {},
        },
        [28921] = {
            [npcKeys.spawns] = {[zoneIDs.HADRONOXS_LAIR]={{43.3,59}},[4277]={{-1,-1}}},
        },
        [28922] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [28923] = {
            [npcKeys.spawns] = {[zoneIDs.THE_TERRESTRIAL_WATCHTOWER]={{19.2,51.7}},[zoneIDs.HALLS_OF_LIGHTNING]={{-1,-1}}},
        },
        [29117] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
            [npcKeys.waypoints] = {},
        },
        [29118] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
            [npcKeys.waypoints] = {},
        },
        [29120] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BROOD_PIT]={{63.2,48.1}},[4277]={{-1,-1}}},
        },
        [29128] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BROOD_PIT]={{63.2,48.1}},[4277]={{-1,-1}}},
        },
        [29173] = {
            [npcKeys.waypoints] = {},
        },
        [29216] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BROOD_PIT]={{63.2,48.1}},[4277]={{-1,-1}}},
        },
        [29301] = { --"Camp Winterhoof Wayfarer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29306] = {
            [npcKeys.spawns] = {[zoneIDs.GUNDRAK_UPPER_LEVEL]={{46.6,28}},[4416]={{-1,-1}}},
        },
        [29311] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{21.43,50.95}},[4494]={{-1,-1}}},
        },
        [29313] = {
            [npcKeys.spawns] = {[4415]={{60.99,25.06},{-1,-1}}},
        },
        [29335] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
            [npcKeys.waypoints] = {},
        },
        [29340] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [29456] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{19.74,47.93},},},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{20.03,47.56},{20.26,47.70},{20.32,47.93},{20.26,48.16},{20.03,48.30},{19.80,48.16},{19.74,47.93},{19.80,47.70},{20.03,47.56}}}},
        },
        [29503] = {
            [npcKeys.waypoints] = {[zoneIDs.STORM_PEAKS] = {{{77.4,62.8},{77.2,63.8},{76.15,63.9}}}},
        },
        [29563] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{54.79,60.36}}},
        },
        [29573] = {
            [npcKeys.spawns] = {[zoneIDs.GUNDRAK_UPPER_LEVEL]={{46.5,65.3}},[4416]={{-1,-1}}},
        },
        [29595] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{63.24,62.52},{61.48,61.4},{63.0,60.41},{63.84,58.29},{62.76,60.93},{65.35,62.54},{59.82,60.46},{61.29,59.34},{57.85,61.98},{59.23,59.01},{58.58,60.81},},},
        },
        [29597] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{60.55,60.22},{57.78,62.32},{60.8,58.67},{60.74,61.13},{59.01,61.85},{59.66,60.87},{58.57,62.99},{59.88,59.07},{58.15,63.85},{58.58,59.45},{56.69,64.95},{56.85,63.18},},},
        },
        [29762] = { --"Hyeyoung Parka", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29795] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = waypointPresets.ORGRIMS_HAMMER,
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [29799] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [29821] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{32.50,63.37},},},
        },
        [29840] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{42.56,20.81},},},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{42.56,20.81},{42.80,20.02},{43.36,19.23},{44.32,18.80},{45.28,19.23},{45.84,20.02},{46.08,20.81},{46.15,21.54},{46.08,22.27},{45.84,23.06},{45.28,23.85},{44.32,24.28},{43.36,23.85},{42.80,23.06}}}},
        },
        [29872] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{28.38,44.85},},},
            [npcKeys.waypoints] = {[zoneIDs.ZUL_DRAK]={{{28.38,46.85},{29.79,46.26},{30.38,44.85},{29.79,43.44},{28.38,42.85},{26.97,43.44},{26.38,44.85},{26.97,46.26},{28.38,46.85}}}},
        },
        [29875] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{43.4,74.2},{44.4,73.8},{45.2,74},{45.4,74.8},{45.8,73},{45.8,75.4},{46.4,74},{46.4,76.2},{46.4,78.4},{46.4,78.8},{46.6,74},{46.6,78.8},{46.8,74.6},{46.8,77.4},{46.8,77.6},{47,72.4},{47,72.6},{47.4,76.2},{47.6,78.8},{48.2,74},{48.2,76.6},{48.4,75},{48.4,75.6},{48.6,77.2},{48.8,79.4},{48.8,79.8},{49,76.4},}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [29895] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{16.43,66.79}}},
            [npcKeys.waypoints] = {[zoneIDs.ZUL_DRAK]={{{16.69,66.78},{18.68,66.8},{20.72,66.61},{21.98,66.82},{23.67,66.65},{25.18,66.75},{26.62,66.96},{28.6,66.48},{31.82,66.66},{30.45,66.6},{28.49,66.53},{25.93,66.93},{24.48,66.73},{22.76,66.75},{21.01,66.6},{18.55,66.86},{16.7,66.75},{16.31,66.75},{13.9,67.32},{13.45,67.33},{12.76,66.96},{13.45,66.28},{13.87,66.26},{16.07,66.7}}}},
        },
        [29968] = { --"Hapanu Coldwind", "Poisons & Reagents"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29969] = { --"Ontak", "Blacksmithing Supplies"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29970] = { --"Danho Farcloud", "General Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29971] = { --"Wabada Whiteflower", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29973] = { --"Tunka'lo Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29999] = {
            [npcKeys.spawns] = {},
        },
        [30222] = {
            [npcKeys.spawns] = {},
        },
        [30082] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{38.2,61.6},},},
        },
        [30120] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{76.8,63},{77,62.2},{77.6,62.6},}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30163] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{68.4,58},{68.6,60},{68.6,63.2},{69.2,57},{69.4,58.8},{69.6,59},{69.6,61.2},{70,60.2},{70.2,57.4},{70.2,58.4},{70.2,62.4},{70.6,59.4},{70.6,59.6},{70.8,56.8},{70.8,58.4},{70.8,61.2},{71.8,62.8},{72.4,62.2},{72.6,62.2},}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30208] = {
            [npcKeys.spawns] = {},
        },
        [30210] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{64.21,59.21},},},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30236] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{85.2,75.8},{85.8,76.6},{85.8,78},{86,74.8},},},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30276] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
        },
        [30277] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
        },
        [30278] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
        },
        [30283] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
        },
        [30284] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
            [npcKeys.waypoints] = {},
        },
        [30286] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
        },
        [30287] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{-1,-1}},[4494]={{-1,-1}}},
        },
        [30295] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{56.3,51.4},},},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30300] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{26.4,36.6},{26.6,41},{27.2,36.8},{27.2,43},{27.4,42},{27.4,44.4},{27.4,44.6},{27.4,45.6},{27.6,44.4},{27.6,45.4},{27.8,42.4},{27.8,42.8},{27.8,46.4},{28,47.2},{28.2,47.6},{28.4,48.6},{28.6,47.2},{28.6,48.4},{28.6,48.8},{29.6,48.4}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30301] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{26.2,35.8},{27.2,35.8}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30302] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30315] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{45,49}}},
        },
        [30316] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{64,47}}},
        },
        [30317] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{52,56}}},
        },
        [30318] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{53,42}}},
        },
        [30329] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{65.9,60.7},{65.9,65.7},{69,71.6},{70.9,75.3},{61.4,72.9},{59.2,80.3}},[4494]={{-1,-1}}},
        },
        [30344] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30345] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30374] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{64.59,51.34}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30375] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{31.26,37.61}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30382] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{39.4,56.4},},},
        },
        [30390] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{71.37,48.79}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30414] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{32.7,50},{29.2,47},{29.2,54}},[4494]={{-1,-1}}},
            [npcKeys.waypoints] = {[zoneIDs.AHNKAHET_MAP]={{{27.3,44.2},{31.1,49.4}},{{27.7,56.6},{31.1,51.2}}}},
        },
        [30448] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{61.75,39.81},{61.96,40.01},{61.98,41.01},{62.63,40.42},{61.74,38.88},{61.08,39.37},{61.42,38.72},{61.74,38.29},{61.61,38.05},{62.24,40.37}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30469] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{48.52,54.36}}},
        },
        [30533] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BROOD_PIT]={{21.1,43.4}},[4277]={{-1,-1}}},
        },
        [30575] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{84.2,75.6},{84.4,75},{84.6,76.8},{85,76.2},{85,77.6},{85.2,73.4},{85.2,74.6},{85.4,74},{85.6,73.8},{85.6,78.4},{86.4,76.6},},},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30593] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{83.4,72.8},{83.8,73.4},{84,74.4},{84.2,75.4},{84.2,75.8},{84.6,73},{84.8,78.6},{84.8,79.6},{85,74.2},{85,76.2},{85.4,74.8},{85.4,76.8},{85.4,78},{85.6,74.2},{85.6,75},{85.6,76.6},{85.8,79.8},{86,78.8},{86.2,75.6},{86.8,75},},},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30696] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{29.4,61.4},{29.6,61.6},{30.4,60.8},{30.8,61.8},{31.2,60.2},{31.2,61.2},{31.2,63.2},{31.2,65},{31.2,66.8},{31.4,58.4},{31.4,58.6},{31.4,63.6},{31.4,66.4},{31.4,67.6},{31.4,69.4},{31.4,70},{31.6,58.4},{31.6,58.8},{31.6,60.4},{31.6,60.6},{31.6,66.4},{31.6,67.2},{31.6,68},{31.8,68.8},{32,64.4},{32,64.6},{32,70},{32,70.6},{32.6,69.2},{32.8,70.2},{33.2,70.6},{33.4,65.8},{33.4,67.6},{33.8,69.6},{34,68.4},{34.2,69},{34.8,69.2},{34.8,70.4},{35,70.6},{35.2,71.8},{35.4,66.2},{35.4,66.6},{35.6,72},{35.8,70.2},{36.2,66},{36.2,67.6},{36.2,71},{36.4,65.4},{36.4,66.8},{36.6,65.4},{36.6,65.8},{36.6,67},{36.8,67.8},{37,71.2},{37.2,71.6},{37.4,70.4},{37.6,70.4},{37.6,70.8}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30698] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{29.8,61.6}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30750] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{26.16,62.28}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30824] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = waypointPresets.ORGRIMS_HAMMER,
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30825] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = waypointPresets.ORGRIMS_HAMMER,
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30871] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{43.9,18}},[1196] = {{-1,-1}}},
        },
        [30944] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54.15,71.18}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30996] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_VILLAGE]={{-1,-1}}},
        },
        [30997] = {
            [npcKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_CITY]={{31.9,44.6}},[4100]={{-1,-1}}},
        },
        [31104] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{81.37,61.1},{82.39,60.19}},[4494]={{-1,-1}}},
        },
        [31105] = {
            [npcKeys.spawns] = {[zoneIDs.AHNKAHET_MAP]={{12.29,50.82}},[4494]={{-1,-1}}},
        },
        [31134] = {
            [npcKeys.spawns] = {[zoneIDs.VIOLET_HOLD] = {{45.9,56.5},{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.VIOLET_HOLD,
        },
        [31191] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31205] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN] = {{65.6,67},{66,62.6},{66,65.4},{66.4,59.6},{66.4,60.6},{66.4,62},{66.4,64},{66.4,66.2},{66.6,59.6},{66.6,65.6},{66.8,65},{67,69},{67.2,61.4},{67.2,63},{67.2,66.6},{67.4,59.4},{67.4,62.2},{67.4,64},{67.4,68.2},{67.4,70},{67.6,69.4},{67.6,70},{67.8,60.4},{67.8,63.4},{67.8,65.8},{68,62.4},{68,63.8},{68,67.4},{68.2,59.2},{68.2,61.4},{68.2,68},{68.4,65.4},{68.6,59.8},{68.8,58.4},{68.8,59.2},{68.8,62.2},{68.8,64.4},{69,65.4},{69,66},{69,66.6},{69,67.8},{69.2,63.2},{69.4,61.2},{69.6,59.8},{69.6,61.8},{69.6,66},{69.8,59.4},{69.8,61.4},{70,63},{70,64.4},{70,65},{70.4,67.4},{70.6,60.4},{70.6,60.6},{70.6,65},{70.6,68.6},{70.8,63.4},{70.8,67.2},{70.8,68.4},{71,62.2},{71.6,68},}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31222] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31237] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{53.8,86.9}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31242] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31259] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31261] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = waypointPresets.ORGRIMS_HAMMER,
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31271] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31277] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31306] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{29.8,61.2}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31440] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54.5,84.2}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31648] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,43}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31839] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,36.6}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32195] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,44}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32196] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,40}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32197] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,34}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32199] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{51,33}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32239] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{44.4,76.2}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32301] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = waypointPresets.ORGRIMS_HAMMER,
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32370] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{68.05,51.83}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32408] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{68.02,51.59}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32423] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{71.6,37.5}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32430] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,36.9}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32497] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{49.2,73.2}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32593] = {
            [npcKeys.spawns] = {[zoneIDs.THE_GILDED_GATE]={{-1,-1}},[4277]={{-1,-1}}},
        },
        [32801] = {
            [npcKeys.questStarts] = {13485},
            [npcKeys.questEnds] = {13485},
        },
        [32802] = {
            [npcKeys.questStarts] = {13486},
            [npcKeys.questEnds] = {13486},
        },
        [32803] = {
            [npcKeys.questStarts] = {13487},
            [npcKeys.questEnds] = {13487},
        },
        [32804] = {
            [npcKeys.questStarts] = {13488},
            [npcKeys.questEnds] = {13488},
        },
        [32805] = {
            [npcKeys.questStarts] = {13489},
            [npcKeys.questEnds] = {13489},
        },
        [32806] = {
            [npcKeys.questStarts] = {13490},
            [npcKeys.questEnds] = {13490},
        },
        [32807] = {
            [npcKeys.questStarts] = {13491},
            [npcKeys.questEnds] = {13491},
        },
        [32808] = {
            [npcKeys.questStarts] = {13492},
            [npcKeys.questEnds] = {13492},
        },
        [32809] = {
            [npcKeys.questStarts] = {13493},
            [npcKeys.questEnds] = {13493},
        },
        [32810] = {
            [npcKeys.questStarts] = {13495},
            [npcKeys.questEnds] = {13495},
        },
        [32811] = {
            [npcKeys.questStarts] = {13494},
            [npcKeys.questEnds] = {13494},
        },
        [32812] = {
            [npcKeys.questStarts] = {13496},
            [npcKeys.questEnds] = {13496},
        },
        [32813] = {
            [npcKeys.questStarts] = {13497},
            [npcKeys.questEnds] = {13497},
        },
        [32814] = {
            [npcKeys.questStarts] = {13498},
            [npcKeys.questEnds] = {13498},
        },
        [32815] = {
            [npcKeys.questStarts] = {13499},
            [npcKeys.questEnds] = {13499},
        },
        [32816] = {
            [npcKeys.questStarts] = {13500},
            [npcKeys.questEnds] = {13500},
        },
        [33288] = {
            [npcKeys.spawns] = {[zoneIDs.THE_PRISON_OF_YOGG_SARON]={{68,40.2}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.ULDUAR,
        },
        [33308] = {
            [npcKeys.spawns] = {[zoneIDs.CRYSTALSONG_FOREST]={{10.4,35},{11.6,37},{11.6,39.8},{11.8,40.6},{12.4,29.2},{12.4,39.4},{12.8,25},{12.8,39.2},{14.2,27.8},{14.4,38.4},{15,37},{15.2,31.4},{15.2,31.8},{15.4,34},{15.4,34.8},{17.6,28.4},{18.2,35.6},{19.8,30.6},{20.4,38}}},
            [npcKeys.zoneID] = zoneIDs.CRYSTALSONG_FOREST,
        },
        [33519] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{77.8,21.6}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [33532] = {
            [npcKeys.spawns] = {[zoneIDs.DALARAN] = {{49.5,62.6}}}, -- Wolvar Orphan
            [npcKeys.zoneID] = zoneIDs.DALARAN,
        },
        [33533] = {
            [npcKeys.spawns] = {[zoneIDs.DALARAN] = {{49.5,62.6}}}, -- Oracle Orphan
            [npcKeys.zoneID] = zoneIDs.DALARAN,
        },
        [33695] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{44.2,32.4},{44.2,32.6},{44.2,33.6},{44.4,31.4},{44.6,32},{44.6,34.2},{44.8,31.4},{45.6,32},{46.6,32.4},{46.8,32.6},{46.8,33.6}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [33956] = {
            [npcKeys.spawns] = {[zoneIDs.THE_ARCHIVUM]={{15.6,89.5}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_ARCHIVUM,
        },
        [33957] = {
            [npcKeys.spawns] = {[zoneIDs.THE_ARCHIVUM]={{15.6,89.5}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_ARCHIVUM,
        },
        [34920] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{42.65,58.43},{42.25,60.1},{43.36,60.69},{43.4,57.84},{42.94,56.95},{43.22,55.94},{42.52,55.01},{43.09,54.6},{41.51,53.56},{41.19,52.62},{40.67,53.31},{40.06,52.53},{39.38,53.79},{38.55,53.96},{38.46,55.05},{37.61,56.07},{38.38,58.33},{37.73,59.86},{38.57,61.28},{38.87,60.57},{39.23,61.41},{40.61,60.33},{41.53,60.01},{42.24,60.09},{43.36,60.69},{44.68,59.4},{45.55,59.06},{45.47,60.13},{45.06,60.94},{45.15,61.93},{44.54,61.9},{46,61.18},{46.5,62.41},{46.08,63.36},{46.7,64.01},{47.35,62.49},{47.72,61.55},{46.88,59.91},{46.29,58.52},{45.85,57.6},{45.92,57.02},{45.77,55.82},{42.4,53.88},{43.38,59.28},{43.82,61.93},{46.69,60.7},{45.03,56.98},{45.15,55.61},{45.03,56.96},{43.9,56.55},{43.38,59.28},{44.27,61.01},{46.82,63.05},{44.34,58.48},{46.56,62.92},{38.21,62.04},{38.03,58.85},{37.67,57.9},{38.13,57.05},{39.95,61.25},{38.84,59.57},{40.56,62.92}}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [34925] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{42.55,54.63},{49.61,48.11},{51.31,50.77},{44.78,53.07}}},
        },
        [34965] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{43.8,24.6}}},
            [npcKeys.zoneID] = zoneIDs.HROTHGARS_LANDING,
        },
        [34980] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{50.4,15.6}}},
            [npcKeys.zoneID] = zoneIDs.HROTHGARS_LANDING,
        },
        [35012] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{58.59,31.72}}},
            [npcKeys.zoneID] = zoneIDs.HROTHGARS_LANDING,
        },
        [35060] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{66.87,8.97},{66.36,8.08},{67.31,8.2},{66.92,7.55},{74.14,10.52},{74.7,9.72},{74.15,9.14},{73.76,9.69}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35061] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{66.87,8.97},{66.36,8.08},{67.31,8.2},{66.92,7.55},{74.14,10.52},{74.7,9.72},{74.15,9.14},{73.76,9.69}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35071] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{66.87,8.97},{66.36,8.08},{67.31,8.2},{66.92,7.55},{74.14,10.52},{74.7,9.72},{74.15,9.14},{73.76,9.69}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35116] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{79.48,23.30}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35127] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{79.49,23.23}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35451] = {
            [npcKeys.spawns] = {[zoneIDs.TRIAL_OF_THE_CHAMPION]={{51,52.4},{-1,-1}}},
        },
        [37172] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{50.7,65.8}}},
            [npcKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [37214] = {
            [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST]={{29.1,66.5},{28.8,66.2},{29.5,65.7},{28.8,65.7},{29.2,65.2}},[zoneIDs.DUROTAR]={{40.3,15.8},{40.1,15.5},{40.5,15.5},{40.5,15.2},{40.3,15.0}}}
        },
        [37671] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{47.7,11.9},{47.8,11.7},{47.6,11.8}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [37675] = {
            [npcKeys.spawns] = {[1657]={{41.95,51.96}},[1537]={{34.15,66.42}},[1519]={{62.41,75.38}},[3557]={{73.73,56.06}}, -- original data
                               [zoneIDs.THUNDER_BLUFF]={{43.6,52.9}},[zoneIDs.ORGRIMMAR]={{53.8,66.4}},[zoneIDs.UNDERCITY]={{65.9,38.7}},[zoneIDs.SILVERMOON_CITY]={{64.6,67.3}}}, -- corrections
        },
        [37715] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{27.43,34.83}},[zoneIDs.DUROTAR]={{50.63,13.13}}}
        },
        [37917] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST]={{55.2,61.0},{55.3,62.0},{54.9,63.1},{54.6,62.3}},[zoneIDs.DARKSHORE]={{43.3,79.9},{43.2,79.9},{43.2,79.5},{42.7,79.5},{43.0,79.4}}}
        },
        [37984] = {
            [npcKeys.spawns] = {[zoneIDs.HILLSBRAD_FOOTHILLS] = {{28.3,38.5},{28.6,38.2},{27.9,37.8},{28.6,37.4},{28.3,36.7}}},
        },
        [38006] = {
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH] = {{61.5,39.8},{61.9,39.7},{61.4,39.5},{61.5,39.3},{61.8,39.3}}},
        },
        [38016] = {
            [npcKeys.spawns] = {[zoneIDs.THE_HINTERLANDS] = {{21.3,52.9},{21.6,52.8},{21.0,52.8},{21.8,52.6},{20.9,52.4}}},
        },
        [38023] = {
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{64.2,37.6},{64.4,37.6},{64.2,37.4},{64.5,37.3},{64.4,37.1}}},
        },
        [38030] = {
            [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{41.2,22.5},{41.1,22.2},{41.6,22.0},{41.2,21.9},{41.4,21.8}}},
        },
        [38035] = {
            [npcKeys.spawns] = {},
        },
        [38042] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{53.7,66.9}},},
        },
        [38043] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{64.4,66.5}},},
        },
        [38044] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF] = {{44,52.8}},},
        },
        [38045] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY] = {{66.6,38.6}},},
        },
        [38065] = {
            [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST]={{33.92,47.27},{34.07,47.27}}},
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
        },
        [38293] = {
            [npcKeys.spawns] = {[1657]={{42.0,50.05}},[1537]={{35.37,69.01}}, -- original data
                               [zoneIDs.THE_EXODAR]={{76,57.5}}}, -- correction
        },
        [38294] = {
            [npcKeys.spawns] = {[zoneIDs.DALARAN] = {{52.5,66.5}},},
            [npcKeys.zoneID] = zoneIDs.DALARAN,
        },
        [38295] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF]={{44.2,55.8}},[zoneIDs.UNDERCITY]={{64.3,37.5}},[zoneIDs.SILVERMOON_CITY]={{64.4,70.3}}}
        },
        [38328] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{58.96,53.12}}}
        },
        [38340] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49,68.96}}}
        },
        [38341] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{54.26,63.77}}}
        },
        [38342] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{47.21,54.09}}}
        },

        -- Below are fake IDs to show specific quest starts/ends only at one specific location even though the
        -- corresponding real NPC has multiple spawns (e.g. "The Kessel Run" requires you to run to Azure Watch even
        -- though "Exarch Menelaous" also spawns at Bloodmyst Isle)

        [80000] = {
            [npcKeys.name] = "Lorehammer attuned",
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        }
    }
end

function QuestieWotlkNpcFixes:LoadAutomatics()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

  --! This file is automatically generated from wowhead data by looking at mobs with no spawns, but drops questiems or are objectives of quests.
  return {
    --! 3.0.1
    --* Halfdan the Ice-Hearted https://www.wowhead.com/wotlk/npc=23671
    [23671] = {
      [npcKeys.spawns] = {
        [495]={{44.9,34.9},},
      },
    },
    --* Scarlet Ivy https://www.wowhead.com/wotlk/npc=23763
    [23763] = {
      [npcKeys.spawns] = {
        [495]={{51.6,25.3},{52.5,26.4},{50.9,27.1},{52.4,27.8},{52.7,29.1},},
      },
    },
    --* Fallen Combatant https://www.wowhead.com/wotlk/npc=24008
    [24008] = {
      [npcKeys.spawns] = {
        [495]={{74.9,32.0},{75.5,34.1},},
      },
    },
    --* Plaguehound Tracker https://www.wowhead.com/wotlk/npc=24156
    [24156] = {
      [npcKeys.spawns] = {
        [495]={{77.6,22.0},{78.5,26.9},},
      },
    },
    --* Plagued Proto-Whelp https://www.wowhead.com/wotlk/npc=24160
    [24160] = {
      [npcKeys.spawns] = {
        [495]={{37.9,52.5},{40.0,50.3},{42.4,53.1},},
      },
    },
    --* Frostgore https://www.wowhead.com/wotlk/npc=24173
    [24173] = {
      [npcKeys.spawns] = {
        [495]={{52.4,3.9},{53.6,6.6},},
      },
    },
    --* Prowling Worg https://www.wowhead.com/wotlk/npc=24206
    [24206] = {
      [npcKeys.spawns] = {
        [495]={{51.4,20.2},{59.6,22.3},},
      },
    },
    --* Northern Barbfish https://www.wowhead.com/wotlk/npc=24285
    [24285] = {
      [npcKeys.spawns] = {
        [495]={{62.8,18.5},{64.6,20.2},},
      },
    },
    --* Image of Megalith https://www.wowhead.com/wotlk/npc=24381
    [24381] = {
      [npcKeys.spawns] = {
        [495]={{71.7,17.6},},
      },
    },
    --* Gjalerbron Gargoyle https://www.wowhead.com/wotlk/npc=24440
    [24440] = {
      [npcKeys.spawns] = {
        [495]={{31.4,22.8},{31.0,26.0},{31.6,26.8},{30.8,27.2},{31.4,27.8},},
      },
    },
    --* Frostfin https://www.wowhead.com/wotlk/npc=24500
    [24500] = {
      [npcKeys.spawns] = {
        [495]={{63.7,19.4},},
      },
    },
    --* Black Conrad's Ghost https://www.wowhead.com/wotlk/npc=24790
    [24790] = {
      [npcKeys.spawns] = {
        [495]={{32.5,60.1},},
      },
    },
    --* Mutinous Sea Dog https://www.wowhead.com/wotlk/npc=25026
    [25026] = {
      [npcKeys.spawns] = {
        [495]={{37.8,75.5},{39.1,73.3},{40.5,75.5},},
      },
    },
    --* Warsong Peon https://www.wowhead.com/wotlk/npc=25270
    [25270] = {
      [npcKeys.spawns] = {
        [3537]={{40.8,58.5},{44.0,58.6},},
      },
    },
    --* Arcane Prisoner https://www.wowhead.com/wotlk/npc=25318
    [25318] = {
      [npcKeys.spawns] = {
        [3537]={{42.5,36.8},},
      },
    },
    --* Alluvius https://www.wowhead.com/wotlk/npc=25742
    [25742] = {
      [npcKeys.spawns] = {
        [3537]={{70.2,36.2},{75.5,35.5},},
      },
    },
    --* Nedar, Lord of Rhinos https://www.wowhead.com/wotlk/npc=25801
    [25801] = {
      [npcKeys.spawns] = {
        [3537]={{48.5,40.1},{46.1,40.6},{47.4,41.1},{47.1,42.5},{45.6,44.9},},
      },
    },
    --* Twonky https://www.wowhead.com/wotlk/npc=25830
    [25830] = {
      [npcKeys.spawns] = {
        [3537]={{60.2,20.4},},
      },
    },
    --* ED-210 https://www.wowhead.com/wotlk/npc=25831
    [25831] = {
      [npcKeys.spawns] = {
        [3537]={{65.5,17.6},},
      },
    },
    --* Max Blasto https://www.wowhead.com/wotlk/npc=25832
    [25832] = {
      [npcKeys.spawns] = {
        [3537]={{63.6,22.4},},
      },
    },
    --* The Grinder https://www.wowhead.com/wotlk/npc=25833
    [25833] = {
      [npcKeys.spawns] = {
        [3537]={{65.0,28.8},},
      },
    },
    --* Nesingwary Trapper https://www.wowhead.com/wotlk/npc=25835
    [25835] = {
      [npcKeys.spawns] = {
        [3537]={{57.5,46.3},},
      },
    },
    --* Storm Tempest https://www.wowhead.com/wotlk/npc=26045
    [26045] = {
      [npcKeys.spawns] = {
        [3537]={{77.0,38.6},},
      },
    },
    --* Keristrasza https://www.wowhead.com/wotlk/npc=26206
    [26206] = {
      [npcKeys.spawns] = {
        [3537]={{21.6,22.5},{30.8,33.2},{33.4,34.0},},
      },
    },
    --* Saragosa https://www.wowhead.com/wotlk/npc=26232
    [26232] = {
      [npcKeys.spawns] = {
        [3537]={{21.9,22.5},},
      },
    },
    --* Keristrasza https://www.wowhead.com/wotlk/npc=26237
    [26237] = {
      [npcKeys.spawns] = {
        [3537]={{25.6,22.0},},
      },
    },
    --* Tu'u'gwar https://www.wowhead.com/wotlk/npc=26510
    [26510] = {
      [npcKeys.spawns] = {
        [65]={{46.6,78.0},},
      },
    },
    --* Iron Rune Avenger https://www.wowhead.com/wotlk/npc=26786
    [26786] = {
      [npcKeys.spawns] = {
        [394]={{69.9,5.1},{70.6,7.8},{69.3,9.5},{67.5,10.4},},
      },
    },
    --* Kor'kron War Rider https://www.wowhead.com/wotlk/npc=26813
    [26813] = {
      [npcKeys.spawns] = {
        [65]={{23.6,41.4},{25.8,42.2},{26.0,40.2},},
      },
    },
    --* Overseer Durval https://www.wowhead.com/wotlk/npc=26920
    [26920] = {
      [npcKeys.spawns] = {
        [394]={{67.6,29.3},},
      },
    },
    --* Overseer Korgan https://www.wowhead.com/wotlk/npc=26921
    [26921] = {
      [npcKeys.spawns] = {
        [394]={{72.0,34.2},},
      },
    },
    --* Overseer Lochli https://www.wowhead.com/wotlk/npc=26922
    [26922] = {
      [npcKeys.spawns] = {
        [394]={{74.9,37.5},},
      },
    },
    --* Overseer Brunon https://www.wowhead.com/wotlk/npc=26923
    [26923] = {
      [npcKeys.spawns] = {
        [394]={{78.6,43.8},},
      },
    },
    --* Grom'thar the Thunderbringer https://www.wowhead.com/wotlk/npc=27002
    [27002] = {
      [npcKeys.spawns] = {
        [65]={{57.1,75.6},},
      },
    },
    --* Xink's Shredder https://www.wowhead.com/wotlk/npc=27061
    [27061] = {
      [npcKeys.spawns] = {
        [65]={{52.6,19.3},},
      },
    },
    --* Onslaught Knight https://www.wowhead.com/wotlk/npc=27206
    [27206] = {
      [npcKeys.spawns] = {
        [65]={{74.5,65.5},{72.6,67.3},{72.5,69.7},{73.1,71.3},{71.5,71.5},{69.4,74.2},{72.6,74.4},{67.4,75.4},{72.8,76.4},{69.2,79.5},{71.3,81.5},},
      },
    },
    --* Foreman Kaleiki https://www.wowhead.com/wotlk/npc=27238
    [27238] = {
      [npcKeys.spawns] = {
        [65]={{68.4,74.1},},
      },
    },
    --* Wintergarde Gryphon https://www.wowhead.com/wotlk/npc=27258
    [27258] = {
      [npcKeys.spawns] = {
        [65]={{77.2,50.0},{78.2,48.8},{78.4,48.0},{80.8,48.8},{83.2,51.0},},
      },
    },
    --* Frigid Ghoul Attacker https://www.wowhead.com/wotlk/npc=27685
    [27685] = {
      [npcKeys.spawns] = {
        [65]={{42.8,51.4},{49.8,51.4},{52.1,49.6},},
      },
    },
    --* Frigid Geist Attacker https://www.wowhead.com/wotlk/npc=27686
    [27686] = {
      [npcKeys.spawns] = {
        [65]={{43.0,51.2},{49.5,51.2},{51.2,52.8},{52.6,46.3},},
      },
    },
    --* Injured 7th Legion Soldier https://www.wowhead.com/wotlk/npc=27788
    [27788] = {
      [npcKeys.spawns] = {
        [65]={{86.2,51.0},},
      },
    },
    --* Hourglass of Eternity https://www.wowhead.com/wotlk/npc=27840
    [27840] = {
      [npcKeys.spawns] = {
        [65]={{71.4,39.3},},
      },
    },
    --* Your Inner Turmoil https://www.wowhead.com/wotlk/npc=27959
    [27959] = {
      [npcKeys.spawns] = {
        [495]={{61.0,2.0},},
      },
    },
    --* Wyrmrest Vanquisher https://www.wowhead.com/wotlk/npc=27996
    [27996] = {
      [npcKeys.spawns] = {
        [65]={{59.6,54.5},},
      },
    },
    --* Warlord Tartek https://www.wowhead.com/wotlk/npc=28105
    [28105] = {
      [npcKeys.spawns] = {
        [3711]={{41.5,19.7},},
      },
    },
    --* Watery Lord https://www.wowhead.com/wotlk/npc=28118
    [28118] = {
      [npcKeys.spawns] = {
        [66]={{41.6,74.3},{39.5,76.2},{42.5,82.6},},
      },
    },
    --* Crusader Jonathan https://www.wowhead.com/wotlk/npc=28136
    [28136] = {
      [npcKeys.spawns] = {
        [66]={{50.6,69.8},{54.0,73.8},},
      },
    },
    --* Crusader Lamoof https://www.wowhead.com/wotlk/npc=28142
    [28142] = {
      [npcKeys.spawns] = {
        [66]={{51.4,75.0},{53.6,75.0},{58.0,72.2},},
      },
    },
    --* Crusader Josephine https://www.wowhead.com/wotlk/npc=28148
    [28148] = {
      [npcKeys.spawns] = {
        [66]={{49.4,74.8},{57.8,72.6},},
      },
    },
    --* Bushwhacker https://www.wowhead.com/wotlk/npc=28317
    [28317] = {
      [npcKeys.spawns] = {
        [3711]={{46.5,63.5},},
      },
    },
    --* Drakkari Captive https://www.wowhead.com/wotlk/npc=28414
    [28414] = {
      [npcKeys.spawns] = {
        [66]={{53.9,67.7},{55.5,70.4},},
      },
    },
    --* Captive Footman https://www.wowhead.com/wotlk/npc=28415
    [28415] = {
      [npcKeys.spawns] = {
        [66]={{55.8,71.0},},
      },
    },
    --* Scarlet Ghost https://www.wowhead.com/wotlk/npc=28846
    [28846] = {
      [npcKeys.spawns] = {
        [4298]={{60.9,26.8},{61.6,28.8},{60.0,29.7},{58.8,30.6},{60.2,31.5},{58.6,33.9},},
      },
    },
    --* Drakkari Chieftain https://www.wowhead.com/wotlk/npc=28873
    [28873] = {
      [npcKeys.spawns] = {
        [66]={{33.7,38.3},},
      },
    },
    --* High Inquisitor Valroth https://www.wowhead.com/wotlk/npc=29001
    [29001] = {
      [npcKeys.spawns] = {
        [4298]={{63.0,68.0},},
      },
    },
    --* Prophet of Akali https://www.wowhead.com/wotlk/npc=29028
    [29028] = {
      [npcKeys.spawns] = {
        [66]={{77.5,36.3},},
      },
    },
    --* Scarlet Courier https://www.wowhead.com/wotlk/npc=29076
    [29076] = {
      [npcKeys.spawns] = {
        [4298]={{63.4,72.5},{61.1,75.7},{64.3,76.7},{59.5,78.5},{62.2,79.3},},
      },
    },
    --* Drakuru Raptor Rider https://www.wowhead.com/wotlk/npc=29699
    [29699] = {
      [npcKeys.spawns] = {
        [66]={{22.9,82.7},{26.4,82.8},{29.9,82.8},},
      },
    },
    --* Prince Navarius https://www.wowhead.com/wotlk/npc=29821
    [29821] = {
      [npcKeys.spawns] = {
        [66]={{30.2,63.0},{32.6,64.0},},
      },
    },
    --* Algar the Chosen https://www.wowhead.com/wotlk/npc=29872
    [29872] = {
      [npcKeys.spawns] = {
        [66]={{27.8,47.3},{32.2,51.4},},
      },
    },
    --! 3.0.2
    --* Tormar Frostgut https://www.wowhead.com/wotlk/npc=29626
    [29626] = {
      [npcKeys.spawns] = {
        [67]={{50.4,78.4},},
      },
    },
    --* General Lightsbane https://www.wowhead.com/wotlk/npc=29851
    [29851] = {
      [npcKeys.spawns] = {
        [210]={{44.6,20.0},},
      },
    },
    --* Stormforged Eradicator https://www.wowhead.com/wotlk/npc=29861
    [29861] = {
      [npcKeys.spawns] = {
        [67]={{26.9,66.7},{24.8,69.4},},
      },
    },
    --* Stormforged Monitor https://www.wowhead.com/wotlk/npc=29862
    [29862] = {
      [npcKeys.spawns] = {
        [67]={{26.9,66.7},{24.8,69.2},},
      },
    },
    --* Reanimated Crusader https://www.wowhead.com/wotlk/npc=30202
    [30202] = {
      [npcKeys.spawns] = {
        [210]={{76.5,66.4},{76.5,68.6},{78.2,67.6},{78.5,69.5},{79.2,65.5},{82.8,71.5},},
      },
    },
    --* Stormforged Ambusher https://www.wowhead.com/wotlk/npc=30208
    [30208] = {
      [npcKeys.spawns] = {
        [67]={{70.3,59.1},},
      },
    },
    --* Freed Crusader https://www.wowhead.com/wotlk/npc=30274
    [30274] = {
      [npcKeys.spawns] = {
        [210]={{83.1,71.8},{83.6,74.0},},
      },
    },
    --* Overseer Narvir https://www.wowhead.com/wotlk/npc=30299
    [30299] = {
      [npcKeys.spawns] = {
        [67]={{36.0,60.8},},
      },
    },
    --* Dr. Terrible https://www.wowhead.com/wotlk/npc=30404
    [30404] = {
      [npcKeys.spawns] = {
        [210]={{33.4,33.2},},
      },
    },
    --* Veranus https://www.wowhead.com/wotlk/npc=30461
    [30461] = {
      [npcKeys.spawns] = {
        [67]={{38.7,65.5},},
      },
    },
    --* Forgotten Depths Underking https://www.wowhead.com/wotlk/npc=30541
    [30541] = {
      [npcKeys.spawns] = {
        [210]={{78.6,64.3},{77.5,64.7},{80.9,65.3},{79.2,67.5},{79.5,68.6},},
      },
    },
    --* Forgotten Depths High Priest https://www.wowhead.com/wotlk/npc=30543
    [30543] = {
      [npcKeys.spawns] = {
        [210]={{78.7,57.3},{79.5,60.7},{77.6,62.2},{77.6,65.4},},
      },
    },
    --* Salranax the Flesh Render https://www.wowhead.com/wotlk/npc=30829
    [30829] = {
      [npcKeys.spawns] = {
        [210]={{77.5,62.1},},
      },
    },
    --* Underking Talonox https://www.wowhead.com/wotlk/npc=30830
    [30830] = {
      [npcKeys.spawns] = {
        [210]={{76.4,53.8},},
      },
    },
    --* High Priest Yath'amon https://www.wowhead.com/wotlk/npc=30831
    [30831] = {
      [npcKeys.spawns] = {
        [210]={{79.8,61.0},},
      },
    },
    --* Possessed Iskalder https://www.wowhead.com/wotlk/npc=30924
    [30924] = {
      [npcKeys.spawns] = {
        [210]={{28.8,52.2},},
      },
    },
    --* Overthane Balargarde https://www.wowhead.com/wotlk/npc=31016
    [31016] = {
      [npcKeys.spawns] = {
        [210]={{17.2,56.0},},
      },
    },
    --* Hulking Horror https://www.wowhead.com/wotlk/npc=31413
    [31413] = {
      [npcKeys.spawns] = {
        [210]={{55.3,87.3},},
      },
    },
    --* Armored Decoy https://www.wowhead.com/wotlk/npc=31578
    [31578] = {
      [npcKeys.spawns] = {
        [210]={{70.6,63.0},{69.2,64.6},},
      },
    },
    --* Brann Bronzebeard https://www.wowhead.com/wotlk/npc=31810
    [31810] = {
      [npcKeys.spawns] = {
        [67]={{45.4,49.4},},
      },
    },
    --* Grimkor the Wicked https://www.wowhead.com/wotlk/npc=32162
    [32162] = {
      [npcKeys.spawns] = {
        [210]={{45.4,46.0},},
      },
    },
    --* Alumeth the Ascended https://www.wowhead.com/wotlk/npc=32300
    [32300] = {
      [npcKeys.spawns] = {
        [210]={{51.8,28.6},},
      },
    },
    --* Hourglass of Eternity https://www.wowhead.com/wotlk/npc=32327
    [32327] = {
      [npcKeys.spawns] = {
        [65]={{72.2,38.2},},
      },
    },
    --* Orabus the Helmsman https://www.wowhead.com/wotlk/npc=32576
    [32576] = {
      [npcKeys.spawns] = {
        [3537]={{26.3,54.5},},
      },
    },
  }
  end

-- This should allow manual fix for NPC availability
function QuestieWotlkNpcFixes:LoadFactionFixes()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    local npcFixesHorde = {
        [26221] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY]={{66.9,13.53}},[zoneIDs.ORGRIMMAR]={{46.44,38.69}},[zoneIDs.THUNDER_BLUFF]={{22.16,23.98}},[zoneIDs.SHATTRATH_CITY]={{60.68,30.62}},[zoneIDs.SILVERMOON_CITY]={{68.67,42.94}}},
        },
        [34907] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{43.43,53.57},{43.1,53.5},{42.94,53.83},{43.92,54.36},{44.07,54.44},{43.82,54.64},{42.62,53.3},{42.85,53.33},{44.23,54.41},{43.36,53.87}}},
        },
        [34947] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{43.43,53.57},{43.1,53.5},{42.94,53.83},{43.92,54.36},{44.07,54.44},{43.82,54.64},{42.62,53.3},{42.85,53.33},{44.23,54.41},{43.36,53.87}}},
        },
        [35060] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{74.14,10.52},{74.7,9.72},{74.15,9.14},{73.76,9.69}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35061] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{74.14,10.52},{74.7,9.72},{74.15,9.14},{73.76,9.69}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35071] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{74.14,10.52},{74.7,9.72},{74.15,9.14},{73.76,9.69}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
    }

    local npcFixesAlliance = {
        [26221] = {
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL]={{56.1,92.16}},[zoneIDs.SHATTRATH_CITY]={{60.68,30.62}},[zoneIDs.IRONFORGE]={{65.14,27.71}},[zoneIDs.STORMWIND_CITY]={{49.32,72.3}},[zoneIDs.THE_EXODAR]={{43.27,26.26}}},
        },
        [34907] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{50.21,49.08},{50.14,49.47},{49.75,49.51},{50.06,49.08},{50.63,48.98},{51.18,48.81},{50.43,49.05},{49.9,49.59},{50.3,49.61},{51,48.53}}},
        },
        [34947] = {
            [npcKeys.spawns] = {[zoneIDs.HROTHGARS_LANDING]={{50.21,49.08},{50.14,49.47},{49.75,49.51},{50.06,49.08},{50.63,48.98},{51.18,48.81},{50.43,49.05},{49.9,49.59},{50.3,49.61},{51,48.53}}},
        },
        [35060] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{66.87,8.97},{66.36,8.08},{67.31,8.2},{66.92,7.55}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35061] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{66.87,8.97},{66.36,8.08},{67.31,8.2},{66.92,7.55}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [35071] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{66.87,8.97},{66.36,8.08},{67.31,8.2},{66.92,7.55}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return npcFixesHorde
    else
        return npcFixesAlliance
    end
end
