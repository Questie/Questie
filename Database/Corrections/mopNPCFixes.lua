---@class MopNpcFixes
local MopNpcFixes = QuestieLoader:CreateModule("MopNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")

function MopNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local phases = Phasing.phases

    return {
        [658] = { -- Sten Stoutarm
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{65.5,43.12}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [706] = { -- Frostmane Troll Whelp
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{17.34,62.74},{18.38,71.08},{21.23,66.65},{20.96,66.48},{22.78,65.38},{22.29,63.77},{20.41,64.62},{20.28,61.25},{23.33,63.6},{21.85,60.2},{24.19,68.19},{23.38,73.3},{28.8,75.1},{27.87,77.83},{30.56,85.16},{31.36,83.89},{30.34,84.95},{31.69,84.21},{30.88,87.03},{28.76,80.64},{29.35,82.59},{30.65,81.86},{30.31,78.65},{31.97,80.85},{35.94,85.78},{33.89,83.94},{44.52,71.9},{46.32,79.25},{49.21,80.62},{49.42,80.58},{51.78,79.06},{48.16,83.82},{46.64,75.29},{49.07,76.22},{53.47,76.51},{55.77,77.6}},[zoneIDs.FROSTMANE_HOVEL] = {{77.29,30.75}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [808] = { -- Grik'nir the Cold
            [npcKeys.spawns] = {[zoneIDs.FROSTMANE_HOVEL] = {{76.4,31.9}}},
            [npcKeys.zoneID] = zoneIDs.FROSTMANE_HOVEL,
        },
        [946] = { -- Frostmane Novice
            [npcKeys.spawns] = {[zoneIDs.FROSTMANE_HOVEL] = {{57.55,52.31},{62.92,38.31},{61.75,31.6},{61.01,24},{66.03,20.04},{71.52,24.45},{79.32,26.34},{72.08,32.84},{74.51,38.54},{76.86,48.1},{70.66,76.16},{51.31,54.34},{49.4,80.2},{44.76,90.8}}},
            [npcKeys.zoneID] = zoneIDs.FROSTMANE_HOVEL,
        },
        [1505] = { -- Night Web Spider
            [npcKeys.spawns] = {[zoneIDs.NIGHTS_WEB_HOLLOW] = {{30.53,31.2},{19.76,30.83},{21.3,46.91},{21.97,29.66},{27.54,30.46},{20.13,40.46},{13.25,54.72},{16.15,63.84},{20.4,68.96},{30.97,75.94},{35.77,81.26},{42.22,77.29},{41.25,56.13},{44.56,64.17},{49.61,68.49},{56.11,69.95},{47.2,56.97},{48.98,52.46},{50.77,45.85},{56.85,54.83},{61.33,60.79},{65.05,53.24},{71.1,54.79},{76.16,72.28},{77.28,68.19},{77.57,56.8},{85.16,53.25}}},
            [npcKeys.zoneID] = zoneIDs.NIGHTS_WEB_HOLLOW,
        },
        [1688] = { -- Night Web Matriarch
            [npcKeys.spawns] = {[zoneIDs.NIGHTS_WEB_HOLLOW] = {{31.82,26.37}}},
            [npcKeys.zoneID] = zoneIDs.NIGHTS_WEB_HOLLOW,
        },
        [1986] = { -- Webwood Spider
            [npcKeys.spawns] = {[zoneIDs.SHADOWTHREAD_CAVE] = {{37.34,37},{35.29,40.05},{32.59,47.14},{33.85,54.1},{38.03,58.14},{54.04,42.38},{56.43,38.82},{59.73,38.93},{56.63,32.96},{56.99,26.61},{50.27,29.7},{47.11,21.96},{41.08,26.06},{42.44,19.34},{33.51,16.16},{35.38,30.24},{39.48,31.6},{44.74,36.54},{46.14,54.54},{50.18,42.47},{55.19,47.64},{56.39,52.77},{58.48,55.24},{52.01,58.71},{50.15,67.39},{41.18,66.5},{41.7,75.81},{44.25,80.46}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWTHREAD_CAVE,
        },
        [1994] = { -- Githyiss the Vile
            [npcKeys.spawns] = {[zoneIDs.SHADOWTHREAD_CAVE] = {{44.86,29.34}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWTHREAD_CAVE,
        },
        [2079] = { -- Ilthalaine
            [npcKeys.spawns] = {
                [zoneIDs.SHADOWGLEN] = {
                    {45.65,74.56,phases.ILTHALAINE_AT_BENCH},
                    {46.3,73.49,phases.ILTHALAINE_AT_ROAD},
                },
            },
        },
        [3101] = { -- Vile Familiar
            [npcKeys.spawns] = {[zoneIDs.BURNING_BLADE_COVEN] = {{22.41,48.41},{43.38,52.32},{45.42,61.84},{53.59,67.31},{50.91,82.17},{43.94,81.35},{34.25,86.64},{18.7,68.29},{30.72,63},{37.02,46.1},{22.03,26.88},{41.04,30.07},{43.58,48.4},{54.73,29.47},{60.22,52.04},{68.79,76.59},{74.33,85.37}},[zoneIDs.VALLEY_OF_TRIALS] = {{56.76,19.04},{55.36,20.95},{55.12,24.12},{59.86,23.13},{58.17,24.17},{57.36,26.77},{60.31,28.41},{59.11,31.39},{56.81,31.9},{54.72,28.46},{54.49,31.39},{54.66,34.95},{52.41,30.8},{52.47,27.79},{52.26,24.07},{53.39,19.55},{52.2,20.9},{47.54,16.6},{49.98,19.63},{49.33,20.89},{49.84,23.26},{49.81,27.88},{49.98,31.06},{49.39,35.34},{45.93,32.44},{47.25,31.05},{47.54,28.35},{47.04,22.73},{44.23,23.11},{44.53,27.33},{42.4,30.4},{40.31,28.26}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_TRIALS,
        },
        [3102] = { -- Felstalker
            [npcKeys.spawns] = {[zoneIDs.BURNING_BLADE_COVEN] = {{20.64,37.63},{25.84,20.57},{36.45,20.64},{49.07,33.77},{62.26,27.54},{63.68,40.05},{31.13,53.33},{13.49,60.64},{26.38,82.64},{43.24,73},{51.1,60.08},{61.2,68.97},{56.02,77.15},{76.64,80.9},{72.3,90.22}}},
            [npcKeys.zoneID] = zoneIDs.BURNING_BLADE_COVEN,
        },
        [3183] = { -- Yarrog Baneshadow
            [npcKeys.spawns] = {[zoneIDs.BURNING_BLADE_COVEN] = {{14.94,46.65}}},
            [npcKeys.zoneID] = zoneIDs.BURNING_BLADE_COVEN,
        },
        [3593] = { -- Alyissia
            [npcKeys.spawns] = {[zoneIDs.SHADOWGLEN] = {{49.21,52.42}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWGLEN,
        },
        [3594] = { -- Frahun Shadewhisper
            [npcKeys.spawns] = {[zoneIDs.SHADOWGLEN] = {{49.22,53.19}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWGLEN,
        },
        [3595] = { -- Shanda
            [npcKeys.spawns] = {[zoneIDs.SHADOWGLEN] = {{47.59,59.43}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWGLEN,
        },
        [3596] = { -- Ayanna Everstride
            [npcKeys.spawns] = {[zoneIDs.SHADOWGLEN] = {{49.22,60.54}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWGLEN,
        },
        [3597] = { -- Mardant Strongoak
            [npcKeys.spawns] = {[zoneIDs.SHADOWGLEN] = {{46.6,56.62}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWGLEN,
        },
        [3977] = { -- High Inquisitor Whitemane
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49.06,89.61}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [10181] = { -- Lady Sylvanas Windrunner
            [npcKeys.questStarts] = {9626,9813,31037},
        },
        [15187] = { -- Cenarion Emissary Jademoon
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{82.69,29.59}}},
        },
        [15278] = { -- Magistrix Erona
            [npcKeys.spawns] = {[zoneIDs.SUNSTRIDER_ISLE] = {{61.04,45.12}}},
            [npcKeys.zoneID] = zoneIDs.SUNSTRIDER_ISLE,
        },
        [15295] = { -- Well Watcher Solanian
            [npcKeys.spawns] = {[zoneIDs.SUNSTRIDER_ISLE] = {{63.96,42.84}}},
            [npcKeys.zoneID] = zoneIDs.SUNSTRIDER_ISLE,
        },
        [15493] = { -- Marsilla Dawnstar
            [npcKeys.spawns] = {[zoneIDs.SUNSTRIDER_ISLE] = {{62.26,42.31}}},
            [npcKeys.zoneID] = zoneIDs.SUNSTRIDER_ISLE,
        },
        [17087] = { -- Spirit of the Vale
            [npcKeys.spawns] = {[zoneIDs.AMMEN_VALE] = {{32.36,20.7}}},
        },
        [36648] = { -- Baine Bloodhoof
            [npcKeys.questStarts] = {24540,26397,31036},
        },
        [37087] = { -- Jona Ironstock
            [npcKeys.questStarts] = {3106,3107,3108,3109,3110,3115,24474,24475,24487,24493,24494,24496,31150},
        },
        [37112] = { -- Wayward Fire Elemental
            [npcKeys.spawns] = {[zoneIDs.FROSTMANE_HOVEL] = {{69.32,28.82}}},
            [npcKeys.zoneID] = zoneIDs.FROSTMANE_HOVEL,
        },
        [37113] = { -- Milo Geartwinge
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{69.84,44}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [37115] = { -- Teo Hammerstorm
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{61.16,13.79}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [37169] = { -- Milo's Gyro
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{69.83,43.64}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [37507] = { -- Frostmane Blade
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{51.47,82.68}},[zoneIDs.FROSTMANE_HOVEL] = {{44.06,30.42},{78.9,58.17},{79.91,67.83},{53.4,68.98},{45.46,88.5},{44.58,87.82},{42.49,88.56},{37.31,73.4},{57.84,35.62},{59.34,41.62},{68.04,42.93},{74.16,23.83},{69.97,18},{60.56,17.75},{55.47,12.55},{43.85,15.86},{42.27,26.36},{45.63,34.52},{46.32,43.84},{53.13,52.72},{49.28,50.58},{43.53,50.04},{42.21,47.59},{32.8,36.3},{31.15,45.97},{30.6,52.38},{26.73,47.47},{11.43,52.4},{13.95,40.87}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [37961] = { -- Corrupted Bloodtalon
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{38.04,66.02},{35.1,67.5},{36.57,65.81},{36.46,64.17},{37.82,62.97},{35.63,63.02},{34.67,62.51},{34.37,64.41},{34.17,66.08},{33.52,68.78},{32.76,69.58},{31.92,71.53},{33.03,72.51},{34.36,70.31},{34.13,71.92},{35.3,72.77},{36,72.98},{36.7,74.21},{38.1,74.01},{39.9,74.8},{39.14,72.51},{40.52,73.21},{40.31,70.25},{40.27,68.88},{40.43,67.57},{38.67,69.15},{37.72,71.39},{38.16,70.22}}},
            [npcKeys.zoneID] = zoneIDs.ECHO_ISLES,
        },
        [37989] = { -- Swiftclaw
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{45.02,85.47}}},
            [npcKeys.waypoints] = {[zoneIDs.ECHO_ISLES] = {{{45.02,85.47},{45.47,85.89},{45.89,86.41},{46.09,87.14},{46.04,87.91},{45.58,88.27},{45.04,88.32},{44.26,88.37},{43.72,89.21},{43.50,90.21},{43.20,91.32},{43.37,91.96},{44.11,91.94},{44.57,91.62},{44.91,90.55},{45.19,89.92},{45.69,89.65},{46.17,89.90},{46.33,90.67},{46.48,91.44},{46.64,92.20},{46.85,92.95},{47.28,93.17},{47.58,92.53},{47.67,91.75},{47.66,90.94},{47.68,90.13},{47.72,89.32},{47.85,88.53},{48.30,88.22},{48.66,88.71},{48.58,89.49},{48.23,90.07},{47.79,89.70},{47.61,88.95},{47.56,88.15},{47.50,87.35},{47.22,86.68},{46.83,86.13},{46.47,85.54},{46.28,84.84},{46.53,84.15},{47.00,83.77},{47.47,83.94},{47.89,84.45},{48.38,84.19},{48.42,83.43},{48.20,82.70},{47.84,82.18},{47.32,81.98},{46.80,81.84},{46.27,81.90},{45.88,82.37},{45.66,82.98},{45.36,83.65},{45.07,84.32},{44.77,84.99},{44.62,85.33},{44.52,85.61},{44.29,86.35},{44.04,87.08},{43.65,87.63},{43.17,87.80},{42.99,87.04},{42.88,86.25},{43.04,85.50},{43.38,84.87},{43.73,84.25},{44.07,83.35},{43.59,82.72},{42.86,82.32},{42.38,82.62},{42.09,83.62},{41.90,84.18},{41.50,85.23},{41.08,86.22},{40.80,86.89},{40.72,87.68},{40.93,88.38},{41.45,88.49},{41.97,88.34},{42.38,87.81},{42.65,87.12},{42.90,86.40},{43.26,85.80},{43.72,85.38},{44.24,85.25},{44.64,85.32}}}},
            [npcKeys.zoneID] = zoneIDs.ECHO_ISLES,
        },
        [38002] = { -- Swiftclaw
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{53.35,63.86}}},
            [npcKeys.zoneID] = zoneIDs.ECHO_ISLES,
        },
        [38142] = { -- Captive Spitescale Scout
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{56.89,51.93},{51.07,50.73}}},
        },
        [38300] = { -- Spitescale Wavethrasher
            [npcKeys.spawns] = {[zoneIDs.SPITESCALE_CAVERN] = {{71.18,50.44},{68.27,31.81},{72.41,66.18},{72.07,67.53},{33.53,42.5},{43.42,38.38},{43.47,46.43},{47.25,56.73},{53.9,54.4},{63.63,69.31},{62.76,68.58},{71.51,79.77},{75.03,78.92},{77.54,62.88},{76.99,61.59},{74.21,48.97},{79.34,34.28},{78.77,35.64},{76.27,22.35},{73.9,33.4},{70.05,28.74},{62.35,30.55},{60.88,47.32},{61.22,48.77},{70.24,43.6},{69.26,43.21},{62.15,42.18},{63.3,49.34},{67.68,53.12},{65.48,63.4}},[zoneIDs.ECHO_ISLES] = {{63.67,39.33},{63.89,39.85},{63.74,40.26},{62.98,39.02},{62.77,39.16},{62.88,39.72},{62.09,39.97},{62.04,39.42},{61.77,39.12},{60.76,37.29},{60.56,37.2},{60.53,37.39},{59.64,35.72},{59.13,35.92},{61.52,27.65},{61.51,27.54},{61.38,27.36},{61.05,26.6},{60.93,26.68},{60.81,26.56},{61.14,25.76},{61.12,25.59},{61.64,25.8},{61.72,25.38},{64.02,25.62},{65.86,25.56},{65.7,21.45},{67.16,21.26},{65.96,14.01},{67.39,12.81},{65.89,9.27},{64.21,11},{55.34,15.97},{63.35,8.97},{62.27,9.01},{62.32,7.74},{60.47,8.51},{58.63,9.93},{56.36,9.64},{56.69,12.17},{55.02,11.68},{56.62,14.23}}},
        },
        [38301] = { -- Spitescale Siren
            [npcKeys.spawns] = {[zoneIDs.SPITESCALE_CAVERN] = {{71.38,48.94},{67.39,32.04},{33.23,43.86},{40.79,41.42},{59.91,59.23},{76.65,85.68},{74.18,47.98},{78.59,17.06},{63.14,29.8},{65.16,53.92},{62.13,41.2},{66.48,61.36}},[zoneIDs.ECHO_ISLES] = {{62.01,24.97},{62.56,37.68},{62.08,38.2},{62.43,26.07},{60.32,15.75},{60.68,15.1},{68.42,17.23},{65.33,27.73}}},
        },
        [38437] = { -- Vanira
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{60.29,15.71}}},
        },
        [38440] = { -- Tortunga
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{58.96,66.83}}},
        },
        [38442] = { -- Morakki
            [npcKeys.spawns] = {[zoneIDs.ECHO_ISLES] = {{58.91,23.09}}},
        },
        [39605] = { -- Garrosh Hellscream
            [npcKeys.questStarts] = {9627,13842,25275,26293,26324,26830,26840,28909,31034},
        },
        [41938] = { -- Tremor Totem
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{61.56,13.94}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [41940] = { -- Windfury Totem
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{62.02,13.31}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [42222] = { -- Rockjaw Marauder
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN] = {{34.55,68.11},{36.16,73.6},{38.94,70.29},{36.57,75.19},{37.34,79.56},{38.77,72.22},{40.14,77.79},{40.13,73.04},{40.45,67.37},{40.71,73.84},{40.86,71.82},{42.14,69.81},{42.68,74.92},{44.92,77.45},{46.97,78.12},{46.66,73.8},{49.11,75.36},{46.05,71.34},{50.54,69.21},{46.94,69.5},{46.97,66.46},{51.85,70.38}},[zoneIDs.FROSTMANE_HOLD] = {{27.6,63.07}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN,
        },
        [42463] = { -- Operation: Gnomeregan Recap Credit
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN] = {{38.46,32.97}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN,
        },
        [42552] = { -- Physician's Assistant
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{53.57,83.24},{51.63,79.6}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [42604] = { -- Elemental Resistance Totem
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{61.65,13.37}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [42605] = { -- Flametongue Totem
            [npcKeys.spawns] = {[zoneIDs.COLDSHIRE_VALLEY] = {{62,13.98}}},
            [npcKeys.zoneID] = zoneIDs.COLDSHIRE_VALLEY,
        },
        [42773] = { -- Boss Bruggor
            [npcKeys.spawns] = {[zoneIDs.FROSTMANE_HOLD] = {{28.17,49.7}}},
            [npcKeys.zoneID] = zoneIDs.FROSTMANE_HOLD,
        },
        [43006] = { -- Rhyanda
            [npcKeys.spawns] = {[zoneIDs.SHADOWGLEN] = {{47.36,59.69}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWGLEN,
        },
        [43089] = { -- Living Contamination
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN] = {{36.37,40.84},{37.17,40.98},{37.97,41.33},{38.59,40.54},{39.06,40.72},{39.98,40.43},{40.99,40.26}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN,
        },
        [43929] = { -- Blingtron 4000
            [npcKeys.name] = "Blingtron 4000",
        },
        [45847] = { -- S.A.F.E. Operative
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{55.32,73.84},{48.16,44.14},{48.44,44.2},{48.69,44.23},{58.77,23.21},{59.04,23.28},{59.31,23.34},{55.83,85.03},{55.38,85.46},{55.33,79.45},{54.59,75.91},{53.36,75.82},{49.12,62.94},{49.13,61.97},{51.02,32.35},{50.47,31.5},{40.88,34.77},{41.13,29.76},{36.62,29.92},{36.34,30.46},{36.34,32.24},{33.21,31.64},{34.43,35.26},{35.07,33.52},{36.55,33.61},{38.13,33.66},{39.89,33.6},{39.96,32.61},{40.09,31.64},{40.17,30.71}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [45966] = { -- Nevin Twistwrench
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{34.08,32.21}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46025] = { -- S.A.F.E. Officer
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{55.34,84.72},{52.06,81.23},{49.31,64.92},{47.93,44.09},{58.46,23.19}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46185] = { -- Sanitron 500
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{58.74,82.97},{58.79,81.74},{58.85,80.51}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46208] = { -- Clean Cannon X-2
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{61.53,79.32},{63.19,79.6},{62.7,84.63},{61,84.54}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46230] = { -- S.A.F.E. Technician
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{60.41,84.44},{61.32,85.6},{65.05,84.86},{63.84,78.51},{63.48,78.98},{61.72,78.81},{60.73,78.58},{56.38,65.2}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46255] = { -- Technician Braggle
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{66.42,81.62}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46267] = { -- Rescued Survivor
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{55.05,85.63},{54.74,83.09},{53.38,83.36},{52.46,82.04},{52.33,81.67},{51.4,78.25},{51.14,81.93},{51.16,81.56},{51.48,80.68},{51.17,79.48},{52.03,77.28},{53.57,83.24},{51.63,79.6}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46268] = { -- Survivor
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{54.47,60.74},{50.66,54.71},{52.88,56.34},{55.69,53.74},{54.95,45.13},{53.42,47.3},{54.89,35.91},{55.11,36.99},{53.87,43.43},{60.22,43.73},{64.36,37.56},{64.03,32.78},{62.89,28.4},{57.71,30.97},{56.03,23.34},{53.17,29.39},{52.17,27.67},{52.65,23.14},{45.87,24.34},{50.08,30.67},{47.65,29.98},{43.92,30.14},{42.58,36.44},{51,42.9},{51.56,37.33}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46274] = { -- Gaffer Coilspring
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{53.08,82.33}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46293] = { -- Torben Zapblast
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{67.28,84.11}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46363] = { -- Crazed Leper Gnome
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{61.89,43.09},{56.44,30.34},{53.97,25.23},{50.87,39.28},{49,39.34},{47.73,41.64},{45.17,39.95},{44.34,31.82},{44.18,35.89},{46.68,35.71},{44.94,26.18},{46.57,24.68},{48.49,26.26},{50.84,29.76},{53.02,29.54},{57.24,24.79},{58.57,27.01},{62.14,27.88},{61.77,32.52},{63.44,35.16},{59.17,35.3},{60.49,37.32},{58.82,43.2},{56.84,42.47},{55.6,36.98},{54.56,40.41},{54.46,32.9},{51.69,41.78},{52.73,36.17},{52.77,46.56},{51.39,52.24},{50.72,56.89},{54.51,59.39},{53.85,63.72},{55.01,68.35},{52.74,68.35}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46391] = { -- Crazed Leper Gnome
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{55.46,73.67},{54.74,71.99},{53.75,71.91},{42.9,33.32},{42.95,32.27},{42.96,31.42}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46447] = { -- Injured Gnome
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{35.29,34.47},{33.09,31.4},{34.59,29.52}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [46449] = { -- S.A.F.E. Operative
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{42.42,25.57},{33.8,29.71}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [47250] = { -- Carvo Blastbolt
            [npcKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN_OLD] = {{50.95,31.94}}},
            [npcKeys.zoneID] = zoneIDs.NEW_TINKERTOWN_OLD,
        },
        [49480] = { -- Tarindrella
            [npcKeys.spawns] = {[zoneIDs.SHADOWTHREAD_CAVE] = {{45.32,91.08}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWTHREAD_CAVE,
        },
        [49598] = { -- Gnarlpine Corruption Totem
            [npcKeys.spawns] = {[zoneIDs.SHADOWTHREAD_CAVE] = {{44.96,31.16}}},
            [npcKeys.zoneID] = zoneIDs.SHADOWTHREAD_CAVE,
        },
        [53566] = { -- Master Shang Xi
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {56.67,18.18,phases.SHANG_XI_BENCH},
                    {59.69,19.11,phases.SHANG_XI_DOORWAY},
                    {65.98,22.81,phases.SHANG_XI_BRIDGE},
                },
            },
        },
        [54135] = { -- Master Li Fei
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{38.81,25.51}}},
        },
        [54567] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{55.1,32.55}}},
        },
        [54614] = { -- Mishka
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.13,84.57}}},
        },
        [54616] = { -- Sully "The Pickle" McLeary
            [npcKeys.spawns] = {
                [zoneIDs.THE_JADE_FOREST] = {
                    {43.62,90.68,phases.SULLY_BELOW_SKYFIRE},
                    {41.39,79.57,phases.SULLY_TWINSPIRE_KEEP},
                },
            },
        },
        [54617] = { -- Rell Nightwind
            [npcKeys.spawns] = {
                [zoneIDs.THE_JADE_FOREST] = {
                    {45.17,94.98,phases.RELL_ON_BARRELS},
                    {46.47,96.3,phases.RELL_ON_DOCKS},
                    {46.47,96.41,phases.RELL_ON_DOCKS_2},
                    {46.2,84.81,phases.RELL_PAWDON_VILLAGE},
                    {41.46,79.15,phases.RELL_TWINSPIRE_KEEP},
                },
            },
        },
        [54631] = { -- Living Air
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{48.02,31.39}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [54780] = { -- Orchard Fire
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{43.21,75.17},{42.96,74.78},{43.79,73.5},{43.71,73.26},{43.91,72.75},{43.57,72.41},{43.69,71.8},{43.43,71.66},{43.74,71.08},{44.08,71.88},{44.44,72.4},{44.7,71.94},{44.73,73.29},{44.83,74.02},{44.6,74.6},{44.46,75.54},{43.89,76.75}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [54786] = { -- Master Shang Xi
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {51.41,46.39,phases.SHANG_XI_TEMPLE_NORTH},
                    {51.59,48.34,phases.SHANG_XI_TEMPLE_SOUTH},
                },
            },
        },
        [54787] = { -- Huo
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{39.42,29.55}}},
        },
        [54894] = { -- Rassharom
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.63,83.15}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [54914] = { -- High Elder Cloudfall
            [npcKeys.spawns] = {
                [zoneIDs.THE_JADE_FOREST] = {
                    {45.22,25.07,phases.HIGH_ELDER_CLOUDFALL_AT_TOWER},
                    {42.74,23.17,phases.HIGH_ELDER_CLOUDFALL_AT_BANQUET},
                },
            },
        },
        [54943] = { -- Merchant Lorvo
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {55.09,32.84,phases.DRIVER_NOT_RESCUED},
                    {55.11,32.39,phases.DRIVER_RESCUED},
                },
            },
        },
        [54961] = { -- Lorewalker Cho
            [npcKeys.spawns] = {
                [zoneIDs.THE_JADE_FOREST] = {
                    {53.66,91.4,phases.CHO_NEAR_BEER_TABLE},
                    {53.77,90.64,phases.CHO_NEAR_PAGODAS},
                },
            },
        },
        [54975] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {65.59,42.61,phases.AYSA_LIANG_POOL_HOUSE},
                    {78.61,42.81,phases.AYSA_LIANG_BRIDGE},
                    {79.81,39.31,phases.AYSA_LIANG_LAKE},
                },
            },
        },
        [54960] = { -- Elder Lusshan
            [npcKeys.spawns] = {
                [zoneIDs.THE_JADE_FOREST] = {
                    {58.04,80.55,phases.LUSSHAN_TOP_STAIRS},
                    {58.58,82.89,phases.LUSSHAN_PUDDLE},
                    {58.89,81.48,phases.LUSSHAN_PEARLS},
                },
            },
        },
        [55020] = { -- Old Man Liang
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {70.62,38.73,phases.AYSA_LIANG_POOL_HOUSE},
                    {78.49,42.86,phases.AYSA_LIANG_BRIDGE},
                    {79.94,39.31,phases.AYSA_LIANG_LAKE},
                },
            },
        },
        [55054] = { -- General Nazgrim
            [npcKeys.spawns] = {[zoneIDs.KALIMDOR] = {{61.23,44.59}}},
            [npcKeys.zoneID] = zoneIDs.KALIMDOR,
        },
        [55205] = { -- Water Spirit Coaxed Credit
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{79.03,37.8}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [55234] = { -- An Windfur
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.65,46.15,phases.AN_WINDFUR_DAWNS_BLOSSOM_GATE}}},
        },
        [55274] = { -- An Windfur
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{39.47,47.55,phases.AN_WINDFUR_FOREST_HEART}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [55282] = { -- Sully "The Pickle" McLeary
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.87,81.81}}},
        },
        [55283] = { -- Amber Kearnen
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.93,81.93}}},
        },
        [55284] = { -- Little Lu
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{59.07,81.89}}},
        },
        [55333] = { -- Rell Nightwind
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.98,81.82}}},
        },
        [55349] = { -- Sully SE Credit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{49.32,61.74}}},
        },
        [55350] = { -- Sully SW Credit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.28,61.86}}},
        },
        [55351] = { -- Sully N Credit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.85,58.36}}},
        },
        [55352] = { -- Sully Return Credit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{50.93,63.06}}},
        },
        [55368] = { -- Widow Greenpaw
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{39.34,46.22}}},
        },
        [55369] = { -- An Windfur
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{39.88,46.28,phases.AN_WINDFUR_DAWNS_BLOSSOM_JADE_HOUSE}}},
        },
        [55378] = { -- Lifelike Jade Statue
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{38.85,45.92},{38.84,46.19},{38.88,46.42},{39.04,46.51},{38.93,46},{39.08,46.01},{39.15,45.79}}},
        },
        [55381] = { -- Widow Greenpaw
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{39.24,46.21}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [55413] = { -- An Windfur
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.77,44.71,phases.AN_WINDFUR_DAWNS_BLOSSOM_UP}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [55438] = { -- Outcast Sprite
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{48.67,24.94},{47.87,21.61},{47.49,21.26},{47.88,21.32},{48.16,21.3},{48.12,21.1},{47.68,20.73},{49.47,22.51},{49.44,21.36},{49.47,21.45},{49.34,21.94},{49.29,22.59},{49.43,22.84},{48.93,22.8},{49.15,21.45},{48.99,23.45},{48.98,22.99},{49.1,21.98},{49.19,22.51},{48.77,21.85},{48.73,21.86},{48.95,22.8},{49.03,22.4},{48.93,22.4},{48.91,24.44},{48.79,24.88},{48.64,24.2},{48.78,24.65},{48.52,24.34},{48.69,24.69},{49.03,23.94},{49.06,24.01},{48.93,23.95},{48.91,23.96}}},
        },
        [55471] = { -- Mogu Ruins Discovery Kill Credit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.95,20.53}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [55480] = { -- Pei-Zhi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.2,14.94}}},
        },
        [55521] = { -- Rivett Clutchpop
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {
                {31.2,21.6,phases.RIVETT_CLUTCHPOP_NOOK_OF_KONK},
                {28,24.6,phases.RIVETT_CLUTCHPOP_STROGARM_AIRSTRIP},
            }},
        },
        [55583] = { -- Ji Firepaw
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{30.98,36.74}}},
        },
        [55586] = { -- Master Shang Xi
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{30,60.37}}},
        },
        [55595] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {32.95,35.61,phases.AYSA_ROPE},
                    {24.78,69.78,phases.AYSA_CAVE},
                },
            },
        },
        [55614] = { -- Pei-Zhi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.24,15.02}}},
        },
        [55768] = { -- Lore Walker Cho
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{27.59,32.68}}},
        },
        [55787] = { -- Peaceful Beast Spirit
            [npcKeys.spawns] = {},
        },
        [55788] = { -- Lo Wanderbrew
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{52.59,38.12}}},
        },
        [55790] = { -- Raging Beast Spirit
            [npcKeys.spawns] = {},
        },
        [55809] = { -- Peiji Goldendraft
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{45.72,43.7}}},
        },
        [55892] = { -- Pei-Zhi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{43.83,12.53}}},
        },
        [55942] = { -- Ji Firepaw
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{36.36,72.53}}},
        },
        [55944] = { -- Delora Lionheart
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{42.22,86.54}}},
        },
        [56111] = { -- Lin Tenderpaw
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {19.87,56.92,phases.LIN_TENDERPAW_EAST_OF_STONEPLOW},
                {18.06,31.01,phases.LIN_TENDERPAW_AT_PAOQUAN_HOLLOW},
            }},
        },
        [56113] = { -- Clever Ashyo
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {59.25,27.56,phases.CLEVER_ASHYO_AT_POOLS_OF_PURITY},
                {61.23,34.23,phases.CLEVER_ASHYO_AT_NEW_CIFERA},
            }},
        },
        [56133] = { -- Chen Stormstout
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {85.93,22.11,phases.CHEN_AT_EAST_BRIDGE},
                {83.64,21.45,phases.CHEN_AT_PANGS_STEAD},
                {75.28,35.5,phases.CHEN_AT_SHANGS_STEAD},
                {68.88,43.14,phases.CHEN_AT_MUDMUGS_PLACE},
                {68.86,43.4,phases.CHEN_AT_MUDMUGS_PLACE_LEGACY},
                {55.89,49.44,phases.CHEN_AT_HALFHILL},
                {55.83,49.34,phases.CHEN_AT_HALFHILL_BREWED},
                {32.26,68.56,phases.CHEN_AT_STORMSTOUT_BREWERY_DOOR},
                {32.12,68.34,phases.CHEN_AT_STORMSTOUT_BREWERY_HOZEN},
                {36.04,68.98,phases.CHEN_AT_STORMSTOUT_BREWERY_SIDE},
                {36,69.12,phases.CHEN_AT_STORMSTOUT_BREWERY_CLEANED_HOUSE},
            }},
        },
        [56138] = { -- Li Li
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {68.88,43.31,phases.CHEN_AT_MUDMUGS_PLACE},
                {68.77,43.44,phases.CHEN_AT_MUDMUGS_PLACE_LEGACY},
                {52.69,62.83,phases.CHEN_AT_HALFHILL},
                {32.27,68.45,phases.CHEN_AT_STORMSTOUT_BREWERY_DOOR},
                {32.33,68.48,phases.LI_LI_AT_STORMSTOUT_BREWERY_HOZEN},
                {36.13,69.06,phases.LI_LI_AT_STORMSTOUT_BREWERY_SIDE},
            }},
        },
        [56146] = { -- Barrow Tree
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{79.14,25.83}}},
        },
        [56149] = { -- Rake Tree
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{81.55,18.62},{80.19,24.66},{80.15,26.61},{78.56,23.64}}},
        },
        [56150] = { -- Hoe Tree
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{80.61,22.42},{81.27,19.12}}},
        },
        [56151] = { -- Plow Tree
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{80.20,18.91},{80.82,23.74},{79.12,24.66}}},
        },
        [56180] = { -- Speckled Trout
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{22.2,34.8},{22.8,35.4},{23,34.2},{23,35.8},{23.4,36.8},{23.6,36.8},{24,34},{24.2,34.8},{24.4,36.4},{24.6,35.8}}},
        },
        [56183] = { -- Engorged Crocolisk
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{22.2,35},{22.4,34.4},{22.6,34.6},{22.8,33.4},{23.4,33.6},{23.4,36.2},{23.4,37},{23.6,33.4},{23.6,33.6},{23.6,37},{24.4,35.2},{24.4,36.2},{24.6,34.4},{24.6,34.6},{24.6,36.4},{24.6,36.6}}},
        },
        [56192] = { -- Miss Fanny
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{83,21.37}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56222] = { -- Bold Karasshi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.98,81.7}}},
        },
        [56310] = { -- Mist Horror
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.2,90}}},
        },
        [56312] = { -- Shang Thunderfoot
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {78.19,32.8,phases.SHANG_THUNDERFOOT_AT_THUNDERFOOT_FIELDS},
                {74.68,34.59,phases.SHANG_THUNDERFOOT_SOUTH_OF_THUNDERFOOT_FIELDS},
            }},
        },
        [56343] = { -- Chen Stormstout
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{83.78,21.16}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56344] = { -- Li Li
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{83.83,21.56}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56347] = { -- Hao Mann
            [npcKeys.spawns] = {[zoneIDs.GREENSTONE_QUARRY] = {{60.9,36.4}}},
            [npcKeys.zoneID] = zoneIDs.GREENSTONE_QUARRY,
        },
        [56401] = { -- Greenstone Nibbler
            [npcKeys.spawns] = {[zoneIDs.GREENSTONE_QUARRY_LOWER] = {{36.73,52.42},{36.16,69.73},{49.41,64.86},{53.84,43.3},{55.11,39.92},{54.33,35.25},{40.84,25.74},{43.22,27.67},{42.29,31.33},{38.26,49.54},{35,56.75},{33.16,74.9},{34.5,76.75},{48.57,61.77},{48.26,65.44},{48.35,76.66},{46.28,77.65},{46.76,81.83}},[zoneIDs.GREENSTONE_QUARRY] = {{54.89,55.99},{60.38,58.1}}},
            [npcKeys.zoneID] = zoneIDs.GREENSTONE_QUARRY,
        },
        [56404] = { -- Greenstone Gorger
            [npcKeys.spawns] = {[zoneIDs.GREENSTONE_QUARRY_LOWER] = {{80.28,41.34},{39.85,17.01},{42.22,37.43},{34.13,67.7},{40.31,87.74},{55.38,64.33},{59.29,56.09}}},
            [npcKeys.zoneID] = zoneIDs.GREENSTONE_QUARRY,
        },
        [56406] = { -- Rivett Clutchpop
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {
                {28.3,47.79,phases.RIVETT_CLUTCHPOP_NEXT_TO_NAZGRIM},
                {27.23,50.78,phases.RIVETT_CLUTCHPOP_GROOKIN_HILL_SOUTH_END},
            }},
        },
        [56439] = { -- Sha of Doubt
            [npcKeys.spawns] = {[zoneIDs.TEMPLE_OF_THE_JADE_SERPENT]= {{60.91,59.35},{-1,-1}}},
        },
        [56448] = { -- Wise Mari
            [npcKeys.spawns] = {[zoneIDs.TEMPLE_OF_THE_JADE_SERPENT]= {{44.58,19.28},{-1,-1}}},
        },
        [56456] = { -- Silk Farm Exploration Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{62.39,59.73}}},
        },
        [56464] = { -- Greenstone Miner
            [npcKeys.spawns] = {[zoneIDs.GREENSTONE_QUARRY_LOWER] = {{62.58,36.13},{53.03,43.78},{52.99,32.97},{47.06,27.38},{39.11,18.58},{36.77,22},{35.89,38.82},{36.88,56.02},{33.05,77.07},{39.21,76.47},{42.04,88.16},{37.64,88.07},{49.28,81.36},{45.16,66.53},{47.3,60.72},{63.18,61.09},{67.39,45.1},{73.55,32.22},{79.1,45.03}},[zoneIDs.GREENSTONE_QUARRY] = {{58.28,64.07}}},
            [npcKeys.zoneID] = zoneIDs.GREENSTONE_QUARRY,
        },
        [56467] = { -- Hao Mann
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.3,29.39}}},
        },
        [56474] = { -- Mudmug
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {68.71,43.12,phases.CHEN_AT_MUDMUGS_PLACE},
                {68.71,43.12,phases.CHEN_AT_MUDMUGS_PLACE_LEGACY},
                {54.28,38.74,phases.CHEN_AT_HALFHILL},
                {32.13,68.43,phases.CHEN_AT_STORMSTOUT_BREWERY_DOOR},
                {32.26,68.28,phases.MUDMUG_AT_STORMSTOUT_BREWERY_HOZEN},
                {36,69.1,phases.MUDMUG_AT_STORMSTOUT_BREWERY_SIDE},
            }},
        },
        [56527] = { -- Jade Cart
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.27,29.47}}},
        },
        [56546] = { -- Silk Farm Exploration Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{62.06,59.32}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56547] = { -- Water Village Exploration Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{61.42,35.43}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56548] = { -- Waterfall Exploration Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{74.85,42.36}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56571] = { -- Chen Stormstout
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{68.88,43.15}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56572] = { -- Li Li
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{68.88,43.31}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [56595] = { -- Stonebound Colossus
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{42.54,10.57}}},
        },
        [56596] = { -- Shan Jitong
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{42.48,10.31}}},
        },
        [56686] = { -- Master Shang Xi
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{19.46,51.22}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [56708] = { -- Syra Goldendraft
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{52.57,38.12}}},
        },
        [56720] = { -- Loon Mai
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {19.55,56.87,phases.BEFORE_MANTID_INVASION},
                {17.83,56.24,phases.AFTER_MANTID_INVASION},
            }},
        },
        [56732] = { -- Liu Flameheart
            [npcKeys.spawns] = {[zoneIDs.TEMPLE_OF_THE_JADE_SERPENT]= {{48.2,53.18},{-1,-1}}},
        },
        [56786] = { -- Lorewalker Stonestep
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{56.26,60.43}}},
        },
        [56787] = { -- Wise Mari
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{57.57,56.04}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [56797] = { -- Stack of Bamboo Reeds
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{18.36,32.18}}},
        },
        [56800] = { -- Stack of Wooden Planks
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{18.25,32.22}}},
        },
        [56801] = { -- Stack of Stone Blocks
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{18.15,32.18}}},
        },
        [56838] = { -- Shokia
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{28.4,51.8}}},
        },
        [56843] = { -- Lorewalker Stonestep
            [npcKeys.spawns] = {[zoneIDs.TEMPLE_OF_THE_JADE_SERPENT]= {{26.18,75.03},{-1,-1}}},
        },
        [56856] = { -- Playful Azure Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{59.19,56.74}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [56858] = { -- Playful Crimson Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.18, 61.39}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [56859] = { -- Playful Emerald Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{56.54,58.4}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [56860] = { -- Playful Gold Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{55.99, 60.33}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [57108] = { -- General Nazgrim
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{28.03,47.21}}},
        },
        [57198] = { -- Guard Captain Oakenshield
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{11.58,49.53}}},
        },
        [57237] = { -- Bookworm
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{55.64,59.98},{55.84,59.62},{56.31,60.1},{56.71,60.02},{56.76,60.24},{56.53,61.16},{56.29,60.81},{55.51,60.64},{55.79,60.12},{55.69,59.71},{56.3,59.8},{56.47,60.82},{56.84,60.46},{56.57,61.03},{55.72,60.78}}},
        },
        [57242] = { -- Elder Sage Wind-Yi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{55.84,57.08}}},
        },
        [57298] = { -- Farmer Fung
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {48.28,33.85,phases.FARMER_FUNG_NORMAL},
                    {52.14,47.97,phases.FARMER_FUNG_FARM},
                    {52.8,51.6,phases.FARMER_FUNG_MARKET}, -- TO DO double check existing coords
                },
            },
        },
        [57306] = { -- Ugly Weed
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{38.54,49.84},{38.88,49.91},{39.14,50.01},{39.08,50.34},{38.74,50.37},{38.45,50.37},{38.19,50.47},{38.20,50.88},{38.48,50.85},{38.80,50.83},{39.01,50.88},{38.96,51.25},{38.61,51.28},{38.34,51.31},{38.07,51.41},{38.51,79.00},{38.27,51.76},{38.84,51.70},{39.10,51.80},{39.02,52.22},{38.70,52.27},{38.37,52.26},{38.09,52.25}}},
        },
        [57401] = { -- Mung-Mung
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.16,34.23}}},
        },
        [57402] = { -- Haohan Mudclaw
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {44.64,34.07,phases.HAOHAN_MUDCLAW_NORMAL},
                    {52.23,48.7,phases.HAOHAN_MUDCLAW_FARM},
                    {52.99,51.72,phases.HAOHAN_MUDCLAW_MARKET},
                },
            },
        },
        [57408] = { -- Mina Mudclaw
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{41.33,38.14}}},
        },
        [57476] = { -- Crossing Rocks Credit
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{79.7,39.07}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [57662] = { -- Barreled Pandaren
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{32.97,67.94},{34.28,67.24},{35.10,66.44},{35.30,66.23},{35.72,65.55},{35.86,66.11},{36.20,65.79},{36.69,65.85},{36.88,65.73},{37.08,65.30},{37.25,65.02},{37.51,64.80},{37.51,64.64},{37.72,64.77}}},
        },
        [58014] = { -- Eddy
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{33.84,70.73}}},
        },
        [58015] = { -- Jooga
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{34.55,70.47}}},
        },
        [58017] = { -- Fizzy Yellow Alemental
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{38.77,69.65}}},
        },
        [58113] = { -- Sunwalker Dezco
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {
                {60.41,25.57,phases.DEZCO_AT_THUNDER_CLEFT},
                {15.98,39.78,phases.DEZCO_AT_SHATTERED_CONVOY},
                {28.89,50.87,phases.DEZCO_AT_DAWNCHASER_RETREAT},
            }},
        },
        [58225] = { -- Instructor Tong
            [npcKeys.questStarts] = {30135,30136,30137,30138,30139},
        },
        [58408] = { -- Leven Dawnblade
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{56.7,43.59}}},
        },
        [58421] = { -- Hemet Nesingwary
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {16.01,82.49,phases.HEMETS_AT_CAMP},
                {19.83,75.64,phases.HEMETS_OUTSIDE_CAMP},
            }},
        },
        [58422] = { -- Hemet Nesingwary Jr.
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {16.07,82.62,phases.HEMETS_AT_CAMP},
                {19.91,75.67,phases.HEMETS_OUTSIDE_CAMP},
            }},
        },
        [58428] = { -- Azure Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58429] = { -- Golden Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58430] = { -- Jade Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58438] = { -- Checkpoint
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{60.70,39.36},{59.72,31.46},{61.35,25.18},{66.30,35.88},{66.10,42.39},{66.81,51.43},{64.09,51.01},{61.86,54.50},{60.45,52.88},{58.79,46.82}}},
        },
        [58440] = { -- Azure Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58441] = { -- Golden Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58442] = { -- Jade Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58444] = { -- Instructor Windblade
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.61,43.65}}},
        },
        [58497] = { -- Azure Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58498] = { -- Jade Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58499] = { -- Golden Cloud Serpent
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.58,43.5}}},
        },
        [58455] = { -- Stillwater Crocolisk
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{29.4,68.8},{29.4,69.6},{29.6,68.8},{31.2,66.6},{32.4,67.4},{33,65.4},{33,65.6},{34.4,61.8},{34.6,60.2},{34.8,58.4},{34.8,58.6},{35.4,56.8},{36.6,55},{36.6,56.4},{39.37,49.97},{40.7,47.36}}},
        },
        [58459] = { -- Ashweb Weaver
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{18.4,30.2},{19.2,28.8},{19.2,30.6},{19.4,29.8},{19.6,29.8},{19.6,30.6},{19.8,29.4},{20,34.4},{20,34.6},{21,35.4},{21.2,35.6},{21.4,30},{21.4,30.6},{21.6,29.8},{21.6,30.6},{21.8,29.2},{22.4,39},{22.4,40.2},{22.6,40.6},{23.2,39.4},{23.2,39.6},{23.2,42.2},{23.2,42.6},{23.4,27.4},{23.4,27.8},{23.4,29.2},{23.8,27.2},{23.8,27.8},{23.8,39.4},{23.8,42.4},{24.2,37.4},{24.2,40.6},{24.2,42.6},{24.4,29.4},{24.4,29.6},{24.4,37.6},{24.4,40.2},{24.6,27.8},{24.6,38.6},{24.6,39.8},{24.6,40.6},{24.8,28.8},{24.8,29.6},{24.8,42},{25,26.6},{25,38},{25.4,25},{25.4,42.6},{25.6,25},{25.6,37},{25.8,38.6},{26,30.6},{26,42.4},{26,42.6},{26.2,26.4},{26.2,27},{26.2,29.4},{26.2,29.6},{26.2,37.8},{26.4,27.6},{26.4,41.4},{26.6,27},{26.6,28},{26.6,41.4},{26.6,42},{26.6,43.2},{26.8,30.8},{27,29.4},{27,29.6},{27,37.6},{27.2,37.2},{27.6,37},{27.8,29.4},{27.8,29.6}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [58465] = { -- Anji Autumnlight
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {
                {33.97,38.11,phases.GOLDEN_LOTUS_DAILY_LOCKED},
                {56.56,43.61,phases.GOLDEN_LOTUS_DAILY_UNLOCKED},
            }},
        },
        [58468] = { -- Sun Tenderheart
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{56.5,43.39}}},
        },
        [58469] = { -- Ren Firetongue
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{56.68,43.15}}},
        },
        [58470] = { -- He Softfoot
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{56.54,43.22}}},
        },
        [58471] = { -- Kun Autumnlight
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {
                {34.06,38.11,phases.GOLDEN_LOTUS_DAILY_LOCKED},
                {56.52,43.63,phases.GOLDEN_LOTUS_DAILY_UNLOCKED},
            }},
        },
        [58503] = { -- Anji Autumnlight
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.97,38.11}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [58504] = { -- Kun Autumnlight
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{34.06,38.11}}},
        },
        [58545] = { -- Stonebark Trickster
            [npcKeys.spawns] = {}, -- Remove invalid spawns
        },
        [58563] = { -- Tilled Soil
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [58567] = { -- Ripe Green Cabbage
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [58607] = { -- Sunwalker Dezco
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{15.97,39.78}}},
        },
        [58608] = { -- Dawnchaser Captive
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{27.5,39.73},{26.51,39.39},{26.74,41.99},{26.77,37.96},{25.46,39.46},{24.68,37.91},{22.48,47.1},{22.47,46.27},{22.61,44.04},{22.6,45.1},{24.07,45.86},{23.53,44.79},{23.05,43.47},{23.82,41.44},{25.33,42.59},{26.23,45.28},{22.51,47.16},{22.51,46.24},{24.04,45.89},{26.13,45.27}}},
        },
        [58632] = { -- Armsmaster Harlan
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_HALLS_ATHENAEUM] = {{61.78,45.22}},
                [zoneIDs.SCARLET_HALLS] = {{-1,-1}},
            },
        },
        [58646] = { -- Farmer Yoon
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {52.75,47.94,phases.FARMER_YOON_HOUSE},
                    {52.25,48.79,phases.FARMER_YOON_FARM},
                    {52.92,51.82,phases.FARMER_YOON_MARKET},
                },
            },
        },
        [58647] = { -- Ella
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {31.51,58.07,phases.ELLA_NORMAL},
                    {51.87,48.65,phases.ELLA_FARM},
                    {53.04,51.72,phases.ELLA_MARKET},
                },
            },
        },
        [58672] = { -- Fog Walker
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{36.6,57.8},{37.4,47.4},{37.4,47.6},{37.6,47.4},{37.6,47.8},{38,56.6},{38.2,45.4},{38.2,45.6},{38.2,58.2},{38.4,43.2},{38.4,43.6},{38.4,55.4},{38.4,55.8},{38.6,43.2},{38.6,43.6},{38.6,44.6},{38.6,46},{38.6,55.6},{39,52.6},{39.2,52.4},{39.2,54.8},{39.4,54.4},{39.6,44},{39.6,54.6},{39.8,42.4},{39.8,42.8},{40.4,53.4},{40.4,53.6},{40.4,55.6},{40.6,53.8},{40.6,55.4},{40.6,55.8},{40.8,42.6},{41.2,40},{41.2,41.2},{41.2,41.6},{41.2,52.8},{41.4,52.2},{41.6,41},{41.6,52.4},{41.6,53},{43,51.8},{43.4,46.2},{43.4,50.8},{43.6,46.2},{43.6,49.2},{43.6,51.4},{43.8,52},{43.8,52.6},{44,40.4},{44,50},{44.2,40.6},{44.4,47.2},{44.6,41.4},{44.6,41.6},{44.6,47.2},{44.6,47.6},{46.2,45.2}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [58673] = { -- Slateskin Troublemaker
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{32.4,71.8},{32.4,75},{32.6,75},{32.8,72.2},{32.8,73},{33.2,73.8},{33.2,75.6},{33.6,73.6},{33.8,73.4},{34.4,72.4},{35.4,72.4},{35.4,72.6},{35.4,74.4},{35.4,74.6},{35.6,74.6},{36,71.4},{36,71.8},{36.2,70.4},{36.2,72.8},{36.4,73.6},{36.4,75.6},{36.4,79.2},{36.4,79.6},{36.6,73.4},{36.6,73.6},{36.8,74.8},{36.8,79},{37,76.2},{37,76.8},{37,78.4},{37.2,79.8},{37.4,81.4},{37.4,81.6},{37.6,81.2},{37.6,81.6},{37.8,79.4},{38.2,78.2},{38.4,77.4},{38.4,80.4},{38.6,78.2},{38.6,79.6},{39,74.6},{39,76},{39,76.6},{39.2,74.4},{39.4,78.6},{39.6,77.4},{39.6,78.2},{39.6,78.6}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [58674] = { -- Angry Hound
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58676] = { -- Scarlet Defender
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58683] = { -- Scarlet Myrmidon
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58684] = { -- Scarlet Scourge Hewer
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58685] = { -- Scarlet Evangelist
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58705] = { -- Fish Fellreed
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {41.73,30.02,phases.FISH_FELLREED_NORMAL},
                    {52.53,49.06,phases.FISH_FELLREED_FARM},
                    {52.76,51.85,phases.FISH_FELLREED_MARKET},
                },
            },
        },
        [58706] = { -- Gina Mudclaw
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {52.23,48.7,phases.GINA_MUDCLAW_FARM},
                    {53.16,51.8,phases.GINA_MUDCLAW_MARKET},
                },
            },
        },
        [58707] = { -- Old Hillpaw
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {30.95,53.1,phases.OLD_HILLPAW_NORMAL},
                    {51.6,49.42,phases.OLD_HILLPAW_FARM},
                    {53.06,51.86,phases.OLD_HILLPAW_MARKET},
                },
            },
        },
        [58708] = { -- Sho
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {29.52,30.6,phases.SHO_NORMAL},
                    {52.16,47.87,phases.SHO_FARM},
                    {53.14,52.06,phases.SHO_MARKET},
                },
            },
        },
        [58709] = { -- Chee Chee
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {34.41,46.76,phases.CHEE_CHEE_NORMAL},
                    {52.85,49.99,phases.CHEE_CHEE_FARM},
                    {53.1,52.09,phases.CHEE_CHEE_MARKET},
                },
            },
        },
        [58710] = { -- Jogu the Drunk
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {52.63,49.33,phases.JOGU_THE_DRUNK_FARM},
                    {53.56,52.57,phases.JOGU_THE_DRUNK_MARKET},
                },
            },
        },
        [58719] = { -- Unbudging Rock
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.21,47.66},{52.17,48.21},{52.83,49.88},{52.37,49.23},{51.92,49.18},{51.57,49.29},{51.70,48.71}}},
        },
        [58721] = { -- Farmer Yoon
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.02,48.01}}},
        },
        [58756] = { -- Scarlet Evoker
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58761] = { -- Tina Mudclaw
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                    {45.09,33.78,phases.TINA_MUDCLAW_NORMAL},
                    {52.75,47.91,phases.TINA_MUDCLAW_FARM},
                    {52.97,51.79,phases.TINA_MUDCLAW_MARKET}, -- TO DO double check coords
                },
            },
        },
        [58858] = { -- Riverblade Pathstalker
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{38.63,38.77},{38.81,40.63},{41.58,43.11},{40.43,42.09},{41.19,40.06},{46.40,40.66},{47.08,37.93},{47.66,37.27},{47.28,36.67},{47.96,35.52},{47.42,33.35},{46.45,34.28},{45.79,33.29},{47.22,30.59},{46.13,30.18},{47.49,77.92},{44.90,27.42},{42.32,29.31},{41.27,29.69},{36.75,31.35},{37.4,34.41}}},
        },
        [58876] = { -- Starving Hound
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58898] = { -- Vigilant Watchman
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [58911] = { -- Rook Stonetoe
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{35.25,74.9}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [58955] = { -- Stoneplow Envoy
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{17.01,35.22},{15.89,34.65},{15.41,35.45},{14.23,35.62},{13.57,36.29},{14.43,36.67},{15.92,36.63},{15.45,37.74},{16.67,37.62}}},
        },
        [58967] = { -- Survival Ring Flame Credit
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{18.87,67.83}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [58978] = { -- Koro Mistwalker
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{43.79,38.30}}},
        },
        [58998] = { -- Scarlet Defender
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59037] = { -- Kung Din
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{54.65,80.1}}},
        },
        [59080] = { -- Darkmaster Gandling
            [npcKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_HEADMASTERS_STUDY] = {{49.84,38.45}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [59150] = { -- Flameweaver Koegler
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_HALLS_ATHENAEUM] = {{39.26,12.52}},
                [zoneIDs.SCARLET_HALLS] = {{-1,-1}},
            },
        },
        [59153] = { -- Rattlegore
            [npcKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{48.42,26.6}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [59175] = { -- Master Archer
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59178] = { -- Lo Wanderbrew
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.63,45.31}}},
        },
        [59183] = { -- Wounded Defender
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{55.09,27.63},{53.87,28.26},{52.52,27.43},{51.46,30.18},{52.52,30.79},{52.81,29.92},{53.97,29.28}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59184] = { -- Jandice Barov
            [npcKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{58.85,18.32}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [59191] = { -- Commander Lindon
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{48.88,51.44},{-1,-1}}},
        },
        [59193] = { -- Boneweaver
            [npcKeys.spawns] = {[zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}}},
        },
        [59223] = { -- Brother Korloff
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49.3,52.4}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [59240] = { -- Scarlet Hall Guardian
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59241] = { -- Scarlet Treasurer
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59272] = { -- Wu-Peng
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {
                {74.68,76.94,phases.WU_PENG_ALONE},
                {74.97,88.78,phases.WU_PENG_REUNITED},
            }},
        },
        [59276] = { -- Weapons Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{30.44,28.09}}},
        },
        [59278] = { -- Tools Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{32.75,30.52}}},
        },
        [59279] = { -- Beer Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{32.13,25.98}}},
        },
        [59280] = { -- Grain Credit
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{34.94,21.95}}},
        },
        [59303] = { -- Houndmaster Braun
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{54.55,29.07},{-1,-1}}},
        },
        [59309] = { -- Obedient Hound
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59332] = { -- Leven Dawnblade
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.8,38.6}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59333] = { -- Rook Stonetoe
            --[npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{}}}, -- TO DO wowhead coords, need recheck
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59334] = { -- Sun Tenderheart
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.2,39}}}, -- TO DO wowhead coords, need recheck
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59336] = { -- Mayor Shiyo
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{35.29,76.78}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59337] = { -- Sun Tenderheart
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{35.12,75.37}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59338] = { -- Che Wildwalker
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.87,72.21}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59340] = { -- Leven Dawnblade
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{21.49,71.18}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59341] = { -- Merchant Tantan
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {
                {42.22,45.93,phases.TANTAN_AT_LAKE},
                {73.49,41.36,phases.PAGODA_UNDER_ATTACK},
            }},
        },
        [59342] = { -- He Softfoot
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {
                {43.8,49.18,phases.HE_SOFTFOOT_NOT_DAILY},
                {43.67,46.06,phases.HE_SOFTFOOT_DAILY},
            }},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59343] = { -- Ren Firetongue
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{42.31,46.01}}},
        },
        [59372] = { -- Scarlet Scholar
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59373] = { -- Scarlet Pupil
            [npcKeys.spawns] = {[zoneIDs.SCARLET_HALLS] = {{-1,-1}}},
        },
        [59391] = { -- Foreman Raike
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{48.31,61.35}}},
        },
        [59392] = { -- Kitemaster Shoku
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{48.18,60.02}}},
        },
        [59397] = { -- Taskmaster Emi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.58,60.67}}},
        },
        [59400] = { -- Kitemaster Inga
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.45,60.51}}},
        },
        [59401] = { -- Surveyor Sawa
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.94,60.36}}},
        },
        [59404] = { -- Knifetooth Swarmer
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{38.4,50.4},{38.4,50.6},{38.6,50.4},{38.6,51},{38.6,51.6},{39.4,45.4},{39.4,46.2},{39.4,47.2},{39.4,47.6},{39.4,49.4},{39.6,46},{39.6,47},{39.6,47.6},{40.4,44.4},{40.4,45},{40.4,48.8},{40.4,50.4},{40.4,50.8},{40.6,44.4},{40.6,50.4},{40.6,50.8},{40.8,45.2},{40.8,45.6},{41,48.6},{41.2,47.4},{41.2,48},{41.6,49.4},{41.6,49.8},{42,47.6},{42.2,47.4}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59411] = { -- Lorewalker Cho
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.78,67.09}}},
        },
        [59418] = { -- Lorewalker Cho
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{49.3,61.49}}},
        },
        [59424] = { -- Dak Dak
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{53.27,71.59}}},
        },
        [59452] = { -- Brother Rabbitsfoot
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {
                -- This phasing is good enough for now, even though it's not 100% correct to tie Rabbitsfoots' phasing for Yakshoes'
                {51.97,67.21,phases.BROTHER_YAKSHOE_AT_BURLAP_WAYSTATION},
                {45.91,64.07,phases.BROTHER_YAKSHOE_AT_THE_DOOKER_DOME},
            }},
        },
        [59467] = { -- Candlestick Mage
            [npcKeys.spawns] = {[zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}}},
        },
        [59492] = { -- Pei-Zhi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{43.83,12.52}}},
        },
        [59501] = { -- Reanimated Corpse
            [npcKeys.spawns] = {[zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}}},
        },
        [59503] = { -- Brittle Skeleton
            [npcKeys.spawns] = {[zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}}},
        },
        [59505] = { -- Suspicious Footprint
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{39.94,45.21},{38.66,46.56},{37.75,46.37},{37.9,43.67},{38.06,45.31},{38.17,46.44},{39.35,46.14},{39.24,45.28},{39.67,45.17},{39.23,44.16},{38.99,43.95},{38.74,43.99},{38.48,44.38}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [59550] = { -- Sully "The Pickle" McLeary
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.55,82.3}}},
        },
        [59572] = { -- Pearlfin Recruit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{59.66,84.53},{59.44,85.22},{58.95,85.14},{59.35,84.73},{59.13,84.57},{60.11,83.93},{59.97,83.53},{59.68,83.93},{59.5,83.86},{59.34,84.17},{59.26,83.69},{59.01,83.69},{58.24,84.33},{58.23,83.89}}},
        },
        [59574] = { -- Dusty Spot
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{45.8,52.84},{43.15,50.27},{39.71,51.11},{32.35,57.1},{33.11,50.09},{34.61,43.2},{35.16,38},{37.35,33.19},{40.29,39.54},{43.24,34.72},{47.32,33.06},{46.99,38.41},{45.87,42.88},{47.93,45.63},{48.27,48.73}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [59609] = { -- Wounded Pearlfin
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{59.82,86.61},{60.03,86.34},{60.37,86.85},{60.29,87.43},{60.61,86.83},{60.86,86.86},{61.1,86.79},{61.18,86.79},{61.18,86.93},{61.08,87.19},{61.08,87.74},{60.63,88.07},{60.29,87.43},{60.25,87.91},{60.31,88.22},{60.35,88.52},{59.86,88.44},{59.56,88.61},{59.55,87.9},{59.4,87.56},{59.15,87.14},{59,86.89},{58.96,86.59},{59.34,86.96},{59.61,87.49},{59.72,87.21},{59.9,86.92}}},
        },
        [59611] = { -- Captured Yak
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{62.17,79.93}}},
        },
        [59620] = { -- Lorewalker Cho
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.85,81.11}}},
        },
        [59789] = { -- Thalnos the Soulrender
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_FORLORN_CLOISTER] = {{26.2,45.6}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [59833] = { -- Ripe EZ-Gro Green Cabbage
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.03,48.24},{52.01,48.44}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [59874] = { -- Manifestation of Fear
            [npcKeys.spawns] = {}, -- removed for quest clutter
        },
        [59894] = { -- Brother Yakshoe
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {
                {50.6,64.08,phases.BROTHER_YAKSHOE_AT_KNUCKLETHUMP_HOLE},
                {52.02,67.18,phases.BROTHER_YAKSHOE_AT_BURLAP_WAYSTATION},
                {45.94,64.13,phases.BROTHER_YAKSHOE_AT_THE_DOOKER_DOME},
            }},
        },
        [59905] = { -- Zhi the Harmonious
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{57.25,42.99,phases.ZIN_AT_PAGODA},{44.79,76.33,phases.ZIN_AT_AXE_OF_THUNDER_KING}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59906] = { -- Sinan the Dreamer
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{74.17,41.83}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59908] = { -- Jaluu the Generous
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{74.15,72.61}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59971] = { -- Stone Guardian
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{23.69,29.61}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59973] = { -- Stone Guardian
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{26.55,26.63},{25.12,26.37},{23.77,27.37},{22.70,26.97},{22.28,27.26},{20.97,30.17},{21.71,30.58},{21.75,28.90},{22.69,29.77},{22.64,30.60},{23.55,29.50},{23.23,30.99},{24.01,31.82},{25.61,31.46},{25.60,30.70},{26.80,30.49}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [59985] = { -- Untilled Soil
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.03,48.24},{52.01,48.44}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [59987] = { -- Parched EZ-Gro Green Cabbage
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.03,48.24},{52.01,48.44}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [59990] = { -- Tilled Soil
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [60011] = { -- Kill Credit: Barring Entry
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{27.5,15.15}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [60040] = { -- Commander Durand
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49,80.4}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [60096] = { -- Eastern Oil Rig
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{50.95,79.29}}},
        },
        [60098] = { -- Southern Oil Rig
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{49.61,80.99}}},
        },
        [60099] = { -- Western Oil Rig
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{47.79,81.61}}},
        },
        [60121] = { -- Reanimated Jade Warrior
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{43.2,24.6},{44.8,23},{47.8,30},{51.8,42.2},{63,42.8},{64.4,31.6},{65.4,30.8}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [60113] = { -- Plump Green Cabbage
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [60273] = { -- Zhao-Jin the Bloodletter
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{78.65,35.69}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [60376] = { -- Kill Credit: Battle Axe Trial
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{44.32,76.41}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [60401] = { -- Snapclaw
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{73.8,38.36}}},
        },
        [60488] = { -- Water Spout Bunny
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{78.54,37.08},{78.31,37.77},{78.77,37.52},{78.63,38.81},{78.72,37.2},{78.32,37.1},{79.46,37.99},{79.56,37.64},{78.33,37.75},{78.8,38.64},{79.41,36.63},{79.78,37.54},{79.22,37.4},{79.94,37.7},{79.2,36.68},{78.4,38.79},{79.07,37.03}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [60491] = { -- Sha of Anger
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{70.82,63.83},{51.22,87.72},{49.98,69.05},{67.81,78.05},{53.77,64.55}}},
        },
        [60564] = { -- Kafa-Crazed Yeti
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{39.28,75.27},{39.53,75.5},{39.24,74.31},{38.81,74.18},{38.57,74.15},{38.16,74.26},{38.13,72.52},{37.8,73.92},{35.24,69.62},{35.09,70.77},{35.41,70.66},{36.07,69.26},{35.95,68.96},{36.54,68.56},{37.22,67.87}}},
        },
        [60566] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{74.2,91.98}}},
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [60570] = { -- Ji Firepaw
            [npcKeys.spawns] = {[zoneIDs.DUROTAR] = {{45.58,12.61}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [60622] = { -- Orbiss
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES]= {
                {67.8,67.6,phases.ORBISS_AT_SUMPRUSH},
                {76.19,72.91,phases.ORBISS_AT_BORROW},
            }}
        },
        [60684] = { -- Suna Silentstrike
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES]= {
                {71.2,56.4,phases.SUNA_AT_OUTPOST},
                {67.2,52.2,phases.SUNA_AT_CAMP_OSUL},
            }}
        },
        [60687] = { -- Ban Bearheart
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES]= {
                {71,56.6,phases.BAN_AT_OUTPOST},
                {67.2,52.2,phases.BAN_AT_CAMP_OSUL},
            }}
        },
        [60727] = { -- Explosion Triggered Credit
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{36.43,87.53}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [60734] = { -- Golgoss
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{70.6,69.6}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [60883] = { -- Light Incense Kill Credit
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{66.96,33.32},}},
            [npcKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [60916] = { -- Wugou
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{68.84,64.88}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [60948] = { -- Kill Credit: Last Toll of the Yaungol 1
            [npcKeys.name] = "Eastern Smoke Trail",
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{84.66,71.6}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [60949] = { -- Kill Credit: Last Toll of the Yaungol 2
            [npcKeys.name] = "Western Smoke Trail",
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{81.08,72.06}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [60950] = { -- Kill Credit: Last Toll of the Yaungol 3
            [npcKeys.name] = "Southern Smoke Trail",
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{83.56,78.42}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [60968] = { -- Xuen
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {
                {67.24,55.9,phases.XUEN_START},
                {70.29,51.28,phases.XUEN_AFTER_FIRST_FIGHT},
                {71.77,44.86,phases.XUEN_AFTER_SECOND_FIGHT},
                {66.39,46.33,phases.XUEN_AFTER_THIRD_FIGHT},
                {68.48,44.6,phases.XUEN_AFTER_FOURTH_FIGHT},
            }},
        },
        [60970] = { -- Admiral Taylor
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.88,81.67}}},
        },
        [60978] = { -- Kang Bramblestaff
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{71.68,45.27}}}, -- only used at these coords
        },
        [60979] = { -- Ken-Ken
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{71.65,45.24}}}, -- only used at these coords
        },
        [60980] = { -- Clever Ashyo
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{71.67,45.32}}}, -- only used at these coords
        },
        [60996] = { -- Brewmaster Chani
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{70.95,51.81}}}, -- only used at these coords
        },
        [60997] = { -- The Wrestler
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{66.72,46.53}}}, -- only used at these coords
        },
        [61004] = { -- Healiss
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{69,43.74}}}, -- only used at these coords
        },
        [61006] = { -- Tankiss
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{68.83,43.41}}}, -- only used at these coords
        },
        [61007] = { -- Hackiss
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{68.59,43.65}}}, -- only used at these coords
        },
        [61012] = { -- Master Windfur
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{68.8,43.69}}}, -- only used at these coords
        },
        [61013] = { -- Master Boom Boom
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{66.68,46.49}}}, -- only used at these coords
        },
        [61071] = { -- Small Frog
            [npcKeys.spawns] = {
                [10] = {{2.8,35.6},{3.8,28.8},{4.4,26.8},{4.8,28},{5.6,36},{6,35.2},{7.4,29.4},{7.6,29.2},{7.8,42.6},{7.8,46.6},{8,42.2},{8.2,48.2},{8.6,50.8},{10,30.2},{10.4,28.6},{11.4,27.2},{11.4,28},{14.4,23.4},{14.4,23.6},{14.8,23.6},{15,22.8},{15.6,22.6},{16.8,22.2},{23.4,24.8},{24.4,24.8},{30.4,23.6},{31.8,22.6},{32.2,22},{35.2,19.8},{37,18.4},{38,17.4},{38,17.6},{46,15.6},{46.4,15.2},{46.6,15},{48.6,12.4},{48.6,12.8},{55.4,11},{55.4,11.6},{57.8,13},{60.4,13.8},{65.2,14.4},{65.4,14.6},{65.6,14.6},{70.2,15.2},{71.2,15.6},{71.6,15.6},{75.4,16},{75.6,16},{79.6,16.4}},
                [12] = {{20.2,75.4},{20.2,75.6},{20.4,72.4},{20.4,72.6},{20.4,76.8},{20.6,72.4},{20.6,76.4},{20.6,77},{22.4,82.6},{22.6,82.4},{22.8,82.8},{22.8,94.4},{22.8,94.6},{23.2,90.4},{23.2,90.6},{23.2,92.2},{23.8,87},{23.8,87.6},{24.4,96.4},{25,96.8},{28.6,80},{28.8,81.6},{29,92.4},{29,92.6},{29.2,76.4},{29.2,77.4},{29.2,77.6},{29.2,86.4},{29.2,86.6},{29.2,89},{29.2,91.4},{29.4,80.6},{29.4,84.4},{29.4,84.6},{29.6,80.6},{30,75.8},{30.4,63.4},{30.4,63.8},{30.4,90.8},{30.6,63.8},{31,90.8},{31.2,60.4},{31.2,60.8},{31.2,75.2},{31.4,90.4},{31.6,61},{31.6,90.6},{31.8,72.6},{32,72},{32.4,65.4},{32.4,65.6},{32.4,90.4},{32.6,65.2},{33,66},{33,90.4},{33,90.6},{33.2,68.2},{33.2,68.6},{33.4,63.8},{33.6,63.4},{33.6,63.8},{33.8,65.4},{33.8,65.6},{33.8,69.4},{33.8,69.6},{34.4,90.6},{34.6,90.6},{37.8,92.2},{39,93},{39.6,93.6},{40.2,93},{41.8,93.2},{44.8,91.4},{44.8,91.6},{45.6,90.6},{46.2,89.4},{46.2,89.6},{46.4,64.4},{46.4,64.6},{46.4,66.2},{46.8,66.2},{47.2,63.4},{47.2,63.6},{47.4,60.4},{47.4,60.8},{47.4,67.2},{47.6,60.4},{47.6,60.6},{47.6,67.2},{48.2,52.4},{48.2,52.8},{48.2,54.4},{48.2,54.6},{48.4,62.8},{48.6,62.8},{48.8,56.4},{48.8,56.8},{48.8,65.4},{48.8,65.6},{48.8,87},{49.2,68.2},{49.4,52.2},{49.4,52.8},{49.6,52.2},{49.6,52.6},{49.6,62.8},{49.6,68.4},{49.8,68.6},{50.2,66.8},{50.4,64},{50.6,64.2},{51.2,68.8},{51.4,66},{51.4,87.8},{51.6,87.8},{52,87.4},{52.4,65.4},{52.4,65.6},{52.4,68.4},{52.4,68.6},{52.6,64.8},{52.6,68.4},{52.6,87.6},{52.8,64.2},{53.4,68.6},{54.2,62.8},{54.2,66.4},{54.4,68.6},{54.6,62.8},{54.8,68.4},{54.8,68.6},{55.6,63.6},{55.6,88.8},{56,69},{56.2,66.2},{56.2,67.2},{56.2,85.6},{56.6,63.4},{56.6,63.6},{56.6,66.8},{57,68.2},{57.6,65},{58,84.2},{62,82.2},{64.4,83.4},{64.6,83.4},{65.4,83.8},{67.2,84.6},{68.8,47.8},{70,57.2},{70,85.2},{70.4,49.2},{71.2,47.6},{71.4,85.2},{73.4,74.8},{73.4,85.2},{74,75.8},{74.2,85.4},{74.4,62.6},{74.4,71.4},{74.8,72.8},{75.4,65.4},{75.6,79.4},{76,61.8},{76.4,65.4},{76.4,65.6},{76.6,65.4},{76.6,65.6},{77,68.4},{77,68.6},{79.6,86.4},{81.8,87.8},{82.8,87.6},{83.8,87.8}},
                [17] = {{35,50},{35.2,48.6},{35.6,41.6},{35.6,46.4},{35.8,50.4},{36,46.6},{36.4,44.8},{36.4,50.6},{36.6,44},{36.6,47.8},{36.6,50.6},{37.2,41.4},{37.4,50.2},{37.6,43.6},{37.6,70.4},{37.6,70.6},{37.8,49},{38,47.4},{38,47.6},{38.4,45.4},{38.4,45.6},{38.4,72.2},{38.6,46.2},{38.8,70.4},{39.8,70},{40.2,72.6},{40.8,70.8},{40.8,73.4},{41.8,74},{42.4,72.2},{42.4,77.4},{42.6,72.8},{42.8,76},{43,74.8},{43.2,70.2},{43.2,77},{43.6,72.6},{43.8,69.2},{44.8,68.8},{45,73.8},{45.8,69.2},{47.2,68.4},{47.2,68.6},{52.4,84.6},{53,78.8},{53.6,81},{54.4,81.6},{54.8,80.2},{55,81.4},{55,81.6},{55.2,75.8},{55.4,77.8},{55.8,76.2},{56.4,78.8},{56.6,78.8},{56.8,76.8},{57.2,81.2},{57.4,80}},
                [38] = {{42.6,22.4},{44,23.4},{48.2,57.2},{50.2,65.6},{51.4,41.6},{52.6,57.8},{54.6,60.8},{55.2,53.4},{56.8,46.4},{58,44.8},{58,49.6},{58,58},{61,52.8}},
                [40] = {{60.4,13.4},{60.4,13.6},{60.6,13.2},{60.6,13.6},{62.4,20.2},{62.4,20.6},{62.6,20.4},{62.6,20.8},{62.8,32.4},{63,30.2},{63,32.6},{63.2,29},{63.8,23.2},{63.8,27},{64,26.2},{65.8,46.4},{66,46.6},{66.8,49.6},{67.2,51.4}},
                [45] = {{16.4,54.6},{16.6,52.4},{16.6,53},{16.6,54.4},{17.6,55.8},{18.8,50.2},{21.8,52.6},{22.6,53},{23,53.8},{23,56},{23.2,55.4},{37.4,84.4},{37.4,88},{37.6,88.2},{38.4,72.2},{38.4,78},{38.6,83.2},{39.2,71.2},{39.6,78},{39.6,79},{39.8,80.4},{39.8,80.6},{40,74.4},{40,74.6},{40.4,71.8},{40.6,72.2},{55.2,66.8},{56.4,65},{56.8,65.4},{56.8,66.8},{57,66.4},{60.4,68.4},{60.8,68.6},{61,70.4},{61.2,70.8},{61.4,66.8},{62.4,64.2},{62.8,63.8},{63.6,67.4},{63.6,67.8},{63.8,69},{65,67.4},{65,67.6},{65.2,64.2},{65.4,64.6}},
                [141] = {{41.4,55.2},{42.2,55.8},{42.4,56.8},{42.4,58},{43,57.8},{43,59},{44.8,23.6},{45.4,23.2},{52.4,63.4},{53.4,60.4},{56.8,59},{57.2,60.6},{58.8,58}},
                [405] = {{61.2,43.8},{61.2,46.2},{62,36.6},{62,45.4},{62,47.4},{62.2,43.2},{62.2,44.4},{62.4,46},{62.4,48.2},{62.6,34.2},{62.8,40.8},{63.2,35.4},{63.4,49},{63.6,49.4},{64,44},{64,45},{64.2,40.8},{64.2,49.8},{64.4,46.6},{64.8,46},{65.4,41},{65.8,36.8},{66,39.6},{66.6,40.8},{66.6,49.4}},
                [1657] = {{33,43.4},{36.2,46.2},{36.4,55},{36.8,39.2},{37.4,47.8},{38,51},{39.2,56},{39.2,57.4},{39.8,58},{39.8,62.6},{40.6,57.4},{42,47.2},{42,53.2},{42.6,46.6},{45,16.8},{45,49.2},{45,52.2},{45.4,51.4},{45.6,19.6},{46.8,37.8},{47,11.8},{47.4,55.2},{47.6,55.2},{52,10.8},{52.2,70},{52.6,13.2},{52.6,39.6},{52.8,61.2},{53.4,54.8},{54,64.2},{56.4,42}},
                [3430] = {{39.4,59},{43.6,37},{43.8,36},{46,41.6},{46.2,43.8},{57,58},{60.8,67.4},{66.2,79}},
                [3433] = {{26,34.2},{27.6,35.2},{28.4,33.6},{32.2,32},{36.6,32.6},{47,51.2},{62.8,59},{68.2,19}},
                [3521] = {{18.4,46.8},{20.8,53.4},{29.4,54.6},{39.4,55.2},{48.4,33},{53.2,34.4},{55.8,48.8},{63.8,46.6},{65,64},{66.2,69.4},{66.6,64.6},{66.6,73},{67.4,79.6},{68,63},{70.6,67},{73.8,84.6},{74,51.8},{79.8,57.2},{82.4,79.6},{82.8,54.4},{82.8,78.8}},
                [4709] = {{41.4,34.8},{41.6,33.8},{41.8,30},{42,26.2},{42,28},{42,30.6},{42.2,29},{42.2,32},{42.2,33.2},{42.2,35.4},{42.4,25.2},{42.4,27.2},{42.6,24},{42.6,29.4},{42.6,29.6},{42.6,32.8},{42.6,36},{42.8,24.8},{42.8,31},{42.8,33.8},{43,31.8},{43,37.8},{43.2,26},{43.2,28.2},{43.2,35.4},{43.6,31},{43.6,34.2},{43.8,36.8},{44,28.6},{44.2,38},{44.6,28},{45.2,34.2},{45.4,30.8},{45.4,31.8},{45.4,35.4},{45.4,36.6},{45.4,38.2},{45.8,33.8},{45.8,38.2},{46,36},{46,37},{46.2,32.8},{46.4,35.4},{46.4,39.4},{46.6,37},{46.8,29.6},{47.2,33.4},{47.2,33.6},{47.4,31},{47.4,32},{47.4,40.4},{47.4,40.6},{47.6,31},{47.6,37.4},{47.6,41.6},{48,33.4},{48,36},{48,38.8},{48.8,41.2},{49.2,41.6},{49.4,38},{49.6,35.4},{50,41},{50,43.4},{50,43.6},{50.4,38},{50.6,41.6},{50.8,35.6},{51.2,45.4},{51.4,35.4},{51.4,43},{51.6,36.2},{51.6,45.4},{51.8,35},{52,41.6},{52,44.4},{53,34.8},{53,45},{53.2,48.2},{54,46.4},{54,48.4},{54.2,47},{54.8,45},{55,43.4},{55.2,42.2},{55.2,44.2},{55.4,41.4},{55.6,42.8},{56,41.4}},
            },
        },
        [61080] = { -- Rabbit
            [npcKeys.spawns] = {
                [12] = {{30.6,53.2},{32.2,52.2},{33.2,49.2},{34,51.4},{34,51.6},{34.4,54.4}},
                [1519] = {{69.8,23.8},{70,23.4},{71.8,28.8},{72,28.2},{79.4,64.4},{79.4,64.6},{79.8,64.2}},
            },
        },
        [61081] = { -- Squirrel
            [npcKeys.spawns] = {
                [10] = {{16.6,22.8},{17.6,22.6},{40.2,19.4},{44.8,41},{44.8,41.6},{47.4,40},{48.4,40.6},{62.6,16.6},{83,16.4}},
                [11] = {{63.4,48.4},{66,50.6},{66.6,44},{67.2,52.6},{70.4,46.6}},
                [12] = {{35.2,78},{36.2,55.8},{36.2,90.2},{36.4,81.4},{37,61.6},{37.8,58.6},{38.2,58.4},{39.8,61.4},{40,61.6},{40.2,73.4},{41.6,57},{42.4,53.4},{44.4,55.2},{45.8,53},{46.2,74.4},{46.6,71.4},{46.6,71.6},{47,49.4},{47,61},{47.2,49.6},{48,54.6},{54.4,78.6},{56,74.6},{56.6,82},{64.4,79.4},{87.2,66.8}},
                [16] = {{15.4,65.6},{17,62.2},{17.6,66},{26.2,47},{26.6,66.6},{27.4,66.2},{27.6,65.6},{27.6,68},{27.8,40.2},{28.4,62.4},{29.2,72.4},{29.4,61.2},{29.6,68.4},{31.8,65.4},{33,68.4},{35,70.4},{39,75.4},{39.4,66.6},{40.4,71.2},{40.8,73},{43,69.2},{44.2,30.4},{44.4,72.6},{48.6,76.6},{52,78},{57.4,25.6}},
                [28] = {{32,60.6},{37.6,67.4},{43,52.2},{50.4,47.8}},
                [38] = {{21.2,17.8},{25.4,36.8},{26.2,66.6},{27.4,12.8},{27.4,13.6},{27.4,21.4},{28.4,17},{28.4,28.8},{29.8,12.4},{30,40.8},{30.4,12.8},{30.8,32.2},{31,50.4},{31.4,58},{32.2,16.4},{33.6,45.6},{33.8,49.4},{34,35},{35.4,51.4},{37.2,47.8},{37.4,43.2},{38.6,19.8},{38.8,42.4},{39.2,13.6},{39.2,34.8},{39.2,48.2},{39.4,48.8},{39.8,45.4},{39.8,47},{41,52}},
                [40] = {{53.6,51.8},{64.4,25.2}},
                [130] = {{54.6,37.8}},
                [148] = {{39.8,47},{44.2,81},{44.8,51.2},{45,35.2},{47,31.6},{48,29},{50.6,19.4},{55.2,22.2},{56.8,18.4},{59.6,16.8},{60.6,13.8},{62.6,21.8},{63.4,19}},
                [331] = {{18,25},{18.8,59.2},{20.2,33},{21.6,57.6},{23.2,30.6},{24.4,37.8},{31,44},{34,37.8},{35.2,32.4},{42,57.4},{44.8,56.6},{52.4,63.2},{53.8,71.6},{54,70.8},{54,72.6},{54.8,55.2},{55.2,69.2},{57,68.4},{58.2,66.6},{58.8,62.2},{60.8,80.2},{62.4,81.2},{62.8,82.6},{63.8,73.6},{63.8,84.4},{64.4,65.6},{64.6,84},{65.4,71.8},{65.8,74},{66.2,68.8},{67,62.4},{67.6,85.6},{68.4,61.6},{68.6,81.2},{69,64.2},{69,79.6},{69.2,82.6},{70,84.6},{70.8,84.4},{71.4,56.6},{71.6,79.6},{72.2,70.4},{72.6,55.2},{73,72.8},{73.2,54.4},{73.6,46.8},{73.8,67.6},{74.8,72.8},{75.8,65.2},{76.2,71},{77,72.6},{80.8,59.2},{82.8,49.2},{84,47.2}},
                [357] = {{39,20.6},{43,21.8},{46,39},{46.2,15.2},{46.4,29.4},{48.8,50.4},{49,15.8},{49.4,51},{49.8,15},{49.8,25.4},{50,33.2},{50.2,29.6},{50.2,31.6},{50.4,10.6},{51,22.2},{51,33.2},{51.2,15.6},{52.2,16},{53.2,46.8},{53.4,14.8},{53.6,48.8},{54,53.6},{54.2,69.4},{54.8,75.2},{55.2,58.4},{55.8,56.4},{56.6,69},{57,44.6},{58.4,55.4},{58.6,52.4},{60.2,51.2},{68.2,44.6},{68.8,56.4},{70.6,61.4},{70.8,50.2},{70.8,57.2},{71.4,53.6},{72.2,63},{72.4,36.6},{72.4,46.4},{75.8,38.6},{80.8,44.6},{81.2,40.2},{84.4,38.6}},
                [493] = {{33.4,58.4},{35,40},{35.4,53.6},{35.8,51.4},{37.2,44.2},{40.8,63.8},{41.2,40.8},{41.8,60.8},{48,63},{48.4,31.4},{50.4,63.2}},
                [495] = {{28.8,64},{39.8,41.4},{43.8,43.8},{45.8,43.8},{66,46}},
                [1519] = {{44.2,79.8},{44.2,82.4},{44.2,82.6},{44.4,81},{44.6,79.6},{45,93.8},{47.6,87},{47.8,77},{47.8,86.4},{47.8,87.6},{48.6,11.4},{48.6,11.6},{49.2,9.2},{49.4,82.4},{49.4,83.4},{49.4,83.6},{49.6,81.6},{49.6,83.4},{49.6,83.8},{49.8,80.4},{49.8,80.8},{50.2,78.4},{50.2,78.8},{50.4,85.4},{50.4,85.8},{50.4,86.6},{50.6,78.4},{50.6,78.6},{50.6,85.4},{50.6,85.8},{50.8,15.8},{50.8,87.4},{50.8,87.6},{52.4,15.6},{53,15.6},{53.4,3.8},{53.6,3.8},{54.2,84.6},{54.4,84.2},{54.6,83.4},{54.6,83.8},{54.8,20.2},{54.8,20.8},{54.8,84.6},{55.2,4.8},{55.4,15.8},{55.6,15.8},{55.8,15.2},{56.8,3.4},{56.8,3.6},{57,12.6},{57.2,12.2},{59.2,3.6},{59.6,82.4},{59.6,82.6},{60.8,80},{64.2,6.6},{69.2,7},{69.8,23.6},{70,9.4},{70,9.6},{70,23.4},{71.8,28.8},{72,28.2},{73.8,7.4},{76.4,6.6},{76.8,6.4},{77.4,6.6},{77.6,6.4},{77.6,6.6},{79,8.2},{79.2,8.6},{79.4,64.2},{79.4,64.8},{79.6,64.2},{79.6,64.6},{80.2,63.4},{80.6,11},{81.2,13.4},{85.6,15.4},{85.6,20.6}},
                [2817] = {{12.2,48.6},{13.6,51},{16.4,27.8},{17.2,32},{18.8,49.2},{21.6,56.8},{22.4,37.4},{25.6,36.8},{26,30.8},{27.6,48.6},{28.8,54.4},{30.4,58.2},{34.8,53.8},{35.4,59.4},{35.8,38.8},{35.8,59},{39.4,44},{40.2,47.4},{40.2,47.6},{40.4,38.4},{40.4,38.8},{40.6,38.4},{41.4,57.6},{44,45.6},{44.2,45.4},{44.2,60},{46,52},{48,45.2},{48,45.8},{49,61.2},{49.2,61.6},{50.8,49.2},{50.8,49.8},{51,41},{51.4,44.2},{51.6,44.6},{52.6,54.6},{54,46.2},{54.2,46.6},{56,60.2},{61.8,60.6},{61.8,66.4},{66.8,68.8}},
                [3518] = {{31.2,60},{33.6,28.8},{50,68},{56.6,51.2},{59,40.8},{59.2,47.2},{59.6,62.8},{66.8,47.4},{67.6,50.4},{69.2,59.6},{69.4,49.8},{69.8,42.8},{70.2,55.4},{70.8,48.2},{72.4,46.6}},
                [3519] = {{32.8,37.8},{33.6,41.2},{38,35.4},{38.2,29},{40.4,28.4},{40.6,28.4},{40.6,31.8},{42.4,33.8},{42.6,33.8},{44.2,29.8},{44.4,17.4},{44.4,17.6},{45.8,32.8},{46,29.8},{46.8,12.4},{46.8,12.6},{47.4,22.4},{47.4,22.6},{47.4,33.6},{47.6,22.4},{47.6,22.6},{49.4,34.8},{49.6,34.8},{50.2,26.2},{53.2,42.8},{54.8,37.4},{54.8,37.6},{55.2,57},{56.4,26.6},{56.6,26.8},{57.4,38.4},{57.4,38.6},{57.4,41.2},{58.8,36.2},{58.8,40},{60.6,24.4},{61,44.2},{62.8,31.4},{64.8,41},{65.8,34.4},{65.8,34.6},{67.6,41.8},{68.4,38.6},{69,88.4},{70.2,34},{70.8,45.2}},
                [3522] = {{36.2,71.6},{53.8,71}},
                [3524] = {{39,67.2}},
                [3711] = {{26.4,82.4},{52.2,30.2},{55,45.2},{64.8,28.6},{65,75}},
            },
        },
        [61141] = { -- Prairie Dog
            [npcKeys.spawns] = {
                [17] = {{23.6,33.4},{24,33.6},{25.4,33.2},{26.2,28.4},{26.4,31},{26.4,34.6},{26.6,31},{26.8,28.8},{27,27.4},{27,32},{27.2,27.6},{27.8,34.4},{27.8,34.6},{28.4,33.2},{28.6,33},{28.8,37.4},{28.8,37.8},{29.2,38.8},{29.4,36.4},{29.8,36.2},{29.8,41.2},{30.2,35.4},{30.2,38.8},{30.6,37.8},{30.6,41.4},{30.6,41.6},{31,40.4},{31.6,41.6},{31.8,31.8},{33.8,40},{34,33.6},{34.4,32.8},{34.8,38.2},{36,41},{36.4,63.2},{36.8,31.8},{38.8,31.2},{39.2,29.6},{39.2,57.2},{40,31},{40.6,29.4},{40.8,31.6},{41,46.8},{41.4,29.8},{41.4,49.6},{43.4,51},{44.8,70.2},{45,31},{46.4,57.6},{46.8,31},{46.8,66.4},{48.2,38.2},{49,41.6},{50,29.8},{50.2,28.4},{50.2,70.2},{52,25},{52,26.4},{52.6,58.6},{53.2,25.8},{53.4,48.2},{53.4,55.4},{53.6,24.2},{53.6,27.8},{53.8,31.2},{54,30},{54.2,22.6},{54.4,20.4},{54.4,51.2},{54.8,20.4},{54.8,20.8},{54.8,27.4},{54.8,49.6},{54.8,63.4},{55,49.4},{55.2,19},{55.2,30.4},{55.4,47.4},{55.4,48.4},{56,15.4},{56,16.2},{56.2,29.8},{56.6,36.2},{56.8,33.4},{56.8,48.2},{57,46.8},{57.2,14.4},{57.2,14.6},{57.4,35},{57.4,87},{57.6,16.4},{57.6,31.6},{57.6,47.6},{57.8,46},{58.8,23},{58.8,34.6},{58.8,45.8},{59,42.4},{59.4,46.8},{59.4,48.4},{59.6,36.6},{60,17.6},{60,41},{60.2,18.8},{60.4,49},{60.6,47.4},{60.6,48.6},{61,17},{61.2,18.8},{61.2,41.4},{61.4,44.8},{61.6,18.6},{61.8,52},{62.4,36.6},{62.4,44},{62.8,65.6},{62.8,68.4},{63.2,52.2},{63.4,19},{63.4,62.4},{63.4,78.6},{64.2,44},{64.4,46},{64.6,67.2},{64.8,22},{64.8,62.2},{64.8,63.4},{65.2,44.4},{65.4,28.6},{65.4,46},{65.4,60.2},{65.4,66.4},{65.6,30},{65.8,44.8},{65.8,48.8},{66,42.2},{66.2,61.6},{66.6,82.8},{67,35.4},{67,35.6},{67,41.6},{67,45},{67,45.8},{67.4,33},{67.4,48.8},{67.4,51.2},{67.6,33},{67.6,54.2},{67.6,65},{68.2,28.4},{68.2,32.2},{68.2,64},{68.6,52},{69,19.4},{69.2,18},{69.4,57.2},{70,16.2},{70,60},{70.8,61.2},{71.6,63.4},{71.6,63.6},{71.6,65.2}},
                [40] = {{34,49.2},{34.8,71.4},{35,73.2},{35.2,47},{36.2,83.2},{38,71.4},{38.2,73},{38.4,55.2},{40.2,49.6},{41.6,55.8},{41.8,79},{42,18},{44.8,48.6},{48.2,77.4},{53.2,68},{54.8,64.8},{56.6,28.6},{58.2,62.6},{66.4,69},{66.6,67.2},{67.2,70.2}},
                [45] = {{18.8,25.2},{21,33.6},{22.4,22},{22.6,22.2},{30.4,39.6},{31.2,38.8},{35,63.4},{35.8,52.4},{36,52.6},{37,40.2},{37.2,62.6},{40.6,54.4},{40.6,54.6},{42.8,78.2},{47.6,45},{47.8,69.4},{47.8,69.8},{48,45.6},{48.2,57.4},{52.4,62.4},{52.4,67.2},{52.6,62.4},{52.6,67.4},{53.2,52},{55.2,51.6},{57,39},{61.4,53},{61.6,52.6},{65.4,47.4},{65.6,47.4},{65.6,47.6}},
                [215] = {{34.6,28.4},{36,40.2},{37.2,44},{39.2,48.2},{40,41},{43,12.4},{45.4,16.6},{45.6,16.6},{48,16.2},{49,56},{49.6,15.4},{51.8,57.2},{53,17.4},{53.4,23.4},{57.2,22},{59.2,62.8}},
                [1638] = {{22,26},{24.8,13.8},{25,11.8},{26,13.2},{30,15.8},{32,18.6},{33.4,51.6},{33.8,52.2},{39,46.4},{39,46.6},{39.8,67.6},{40.6,67.2},{40.6,68.2},{43.8,54},{48.6,40},{49,38.8},{51.4,49.4},{55.2,50},{55.4,42.6},{55.4,50.8},{55.8,43},{57.8,61.6},{60.8,76.2},{61.8,45.6},{62.6,56.2},{62.8,53.4},{62.8,54.4},{62.8,55.2},{74.4,23.6}},
                [3518] = {{52.4,31.4},{63.8,36.8}},
                [4709] = {{37.6,13},{38.4,82},{38.8,81.8},{39.6,79.4},{39.6,79.8},{40.8,20.8},{40.8,53.8},{41.4,40.6},{41.4,66.8},{41.6,46.8},{41.6,48.2},{41.6,79.6},{41.6,81.8},{42,49},{42,51.8},{42.2,65.4},{42.2,67.4},{42.2,84.4},{42.4,40.6},{42.4,46},{42.4,68},{42.8,42.8},{42.8,58.4},{43,50.2},{43,70.6},{43.2,40.4},{43.2,69.2},{43.2,70.4},{43.4,53},{43.4,65.6},{44,48.4},{44.6,87.8},{44.8,72.6},{45,59},{45.4,58.4},{45.4,82.6},{45.4,85.4},{45.6,71.4},{45.8,69},{46,58.4},{46.2,56.6},{46.2,68.4},{46.4,58.6},{46.6,69.6},{46.8,49.6},{46.8,59.6},{46.8,73.6},{46.8,87.8},{47.4,67.6},{47.6,67},{47.8,46},{47.8,51.8},{47.8,63.8},{47.8,81.8},{47.8,88.6},{48,57.4},{48,62.6},{48,68.8},{48.2,61.4},{48.2,61.6},{48.2,68.2},{48.2,81},{48.4,47.8},{49,78},{49.2,50},{49.4,59.2},{49.4,76},{50.2,77.2}},
                [6452] = {{13.8,32.6}},
            },
        },
        [61142] = { -- Snake
            [npcKeys.spawns] = {
                [15] = {{33,47.6},{33.6,71.6},{35,59.2},{35.4,27.2},{35.6,27},{36.4,42},{37,62.2},{37.8,61.4},{38.4,19.6},{39.4,28.8},{41,62.4},{43.2,61.4},{43.4,62},{43.8,69.2},{44.2,70.4},{44.4,74.8},{45.8,22},{46,77.4},{46,77.6},{46.2,70.2},{46.2,74.4},{46.2,80.4},{47.4,72.8},{47.4,75.2},{47.4,76.4},{47.4,76.6},{47.6,76.4},{47.8,73.4},{47.8,73.6},{48.2,60},{48.4,17.8},{48.4,70.4},{48.6,20.8},{49,61.6},{49,70.2},{49.6,69.4},{49.6,74},{50,63.4},{50.2,65.4},{50.2,72.8},{50.4,61},{51,70},{51.6,56},{52,73.4},{52,73.6},{52.2,68},{52.2,71.2},{52.8,73},{53.2,55.2},{53.4,73.8},{54.2,73.8},{54.4,52.4},{54.8,72.8},{55.8,71.4},{55.8,74.4},{55.8,74.6},{56.2,76},{56.6,73.4},{56.6,73.8},{56.6,80.2},{57.4,76.4},{57.6,28.8},{57.6,76.2}},
                [38] = {{42.8,19.8},{51.4,50.2},{54.8,19.2}},
                [40] = {{31.8,77.4},{33.8,48.4},{36.8,83.8},{37,26.2},{38,35.2},{38.2,19.2},{39.2,69.4},{40.2,25},{40.8,63.4},{41.6,55},{42.8,51.8},{43.2,80},{43.4,14.8},{43.4,46.2},{43.8,17.2},{45.4,81},{47.4,16.6},{47.6,68.4},{47.8,67.2},{48.8,57.8},{49.6,24.4},{49.6,78},{50.2,56.4},{50.2,65.6},{52.2,17.2},{55.6,61.8},{56,28.8},{57.8,45.8},{58,15.2},{59,28.2},{61.2,27.2}},
                [66] = {{15,74.2},{19.8,68},{35.2,63},{45,63.4}},
                [357] = {{39.6,24},{39.8,20.8},{41.6,36},{41.8,21.6},{42,21.4},{42.2,37.4},{43.2,9.6},{45.2,67},{45.8,22.4},{45.8,23.6},{46.2,14},{46.4,8},{46.4,10.4},{46.4,15.4},{46.4,24.8},{46.4,29.6},{46.6,29.4},{47.2,36.8},{47.4,60.8},{48.6,50.6},{48.8,25.2},{49,15.8},{49,49.6},{49.2,28.4},{49.4,32.4},{49.4,32.6},{49.8,15},{49.8,25.4},{49.8,33.4},{49.8,33.6},{50.2,29.4},{50.2,31.8},{50.4,10.6},{50.6,24},{50.8,17.8},{51.2,15.6},{52.2,16},{52.2,49.6},{53,10.6},{53,16.4},{53.2,47},{53.4,14.8},{53.8,48.8},{54,53.8},{54.6,65},{55.4,49.6},{57,44.4},{57,44.6},{57,47.8},{57,51},{57,52},{57.8,50.6},{59.4,48.4},{59.4,51.6},{61.6,53.6},{62,53},{67,47.8},{68.2,44.6},{69.4,51},{69.6,43.8},{73.6,54.4},{74.2,50.4},{74.2,58.6},{74.6,58.4},{75.2,36.4},{75.2,53.4},{75.6,57.2},{76.4,40.2},{78.8,43.4},{80.6,40},{80.8,44.6}},
                [3430] = {{42.4,40.6},{43.2,35},{44,35.4},{45.6,46.6},{45.8,35.2},{47.6,34.8},{47.6,42.2},{47.8,36.4},{47.8,36.6},{47.8,43.8},{48,38.2},{63,78.8},{67,56},{68.2,57.4},{68.6,70.2}},
                [3433] = {{76.2,7.6},{76.2,43.6}},
                [3519] = {{41,52.4}},
                [3521] = {{17.4,49.6},{33.8,47.4},{35.8,55.2},{43.6,54.4},{45,34.6},{46,35},{49.6,31.2},{60.8,38.8},{62.8,45.2},{65.6,50.4},{69.2,66},{73.8,84.6},{77.6,53.8},{78.2,56.6},{82.4,80.8},{84.8,50.2},{85.4,84.4}},
                [3711] = {{22,70},{36.4,80.4},{41.4,48.2},{51.8,30.4},{57.8,45}},
            },
        },
        [61161] = { -- Bluesaddle
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {
                {39.21,61.99,phases.BLUESADDLE_TEMPLE},
                {35.42,56.67,phases.BLUESADDLE_LAKE},
            }},
        },
        [61166] = { -- Cho Summon Bunny
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{57.97,49.04}}},
            [npcKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [61169] = { -- Roach
            [npcKeys.zoneID] = 10,
            [npcKeys.spawns] = {
                [10] = {{21,45.6},{21.4,43.2},{21.8,47.6},{22.4,67.6},{26.8,35.6},{27.8,75.8},{36.6,71.2},{38.8,73.4},{56.2,23.2},{64,74.2},{84.2,36}},
                [16] = {{66,17.2},{66,18.2},{67,12},{67,18.2},{67.4,13.8},{67.6,13.8},{69,15.2},{70.8,16.6},{71,16.4},{71.8,16.2}},
                [44] = {{15.8,55.4},{26.8,27.2},{47.4,36.2},{47.6,38.6},{60.4,36.2},{68,43.4}},
                [331] = {{46.4,59.2},{72.6,80.2},{73.2,60},{73.2,62.8},{73.6,62.8},{85.8,61.2},{88.4,56.6}},
                [400] = {{7.2,25.4},{7.2,25.6},{7.4,34.4},{25,25.6},{47.4,64.6},{94.4,75.8}},
                [405] = {{50.2,63.6},{51.4,57.8},{52.4,57.6},{55,66.8},{59.2,31.4},{60.6,65.6},{73,36},{74.2,22},{75.4,35.2}},
                [1497] = {{50.8,60},{59.2,29},{59.6,37},{59.8,36},{61.4,52.2},{64.2,33.4},{65.8,25.8},{66.2,27.8},{68,36},{68.8,36.8},{73.4,68.6},{78.2,72.6},{81.6,68.4},{83.4,33.8},{83.6,63.8},{84,41.8},{84.2,63.4}},
                [5287] = {{39.8,72.6},{41.6,73},{42,68.4},{42,74.4},{42,74.6},{43,71.6},{43.2,71.2}},
            },
        },
        [61218] = { -- Lorewalker Cho
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{54.02,91.19}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [61291] = { -- Kill Credit: Last Toll of the Yaungol 4
            [npcKeys.name] = "Northwestern Smoke Trail",
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{83.97,70.85}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [61297] = { -- Image of Lorewalker Cho
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{57.97,49.04}}},
            [npcKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [61313] = { -- Parrot
            [npcKeys.spawns] = {
                [8] = {{19.4,50.4},{19.4,50.6},{19.6,50.4},{19.6,50.6},{29,59.8},{29.6,60},{33.4,52.4},{33.4,52.6},{33.6,52.4},{33.6,52.6},{35,37.4},{35,37.6},{39.2,49.6},{39.4,50.6},{39.6,50.6},{39.8,50},{44.4,46.4},{44.4,46.6},{44.6,46.4},{44.6,46.8},{47.4,32.4},{47.4,32.6},{47.6,32.4},{47.6,32.6},{60,59.2},{60.4,60},{60.6,60},{68.2,68.4},{68.2,68.6},{68.6,68.4},{75,20.2},{75,20.6},{79.4,75.4},{79.6,75.8},{79.8,36.6},{79.8,75.4},{80,36.4}},
                [490] = {{20.4,42.6},{26.8,55},{27.8,33.4},{30,65.4},{30.2,23.6},{30.8,41},{33,41},{33.8,46.6},{34,70.2},{36,66.6},{37.8,61.6},{39.6,22.4},{40.8,54.2},{43.2,70.2},{43.4,7},{48.8,69.2},{50.2,8.6},{53.2,22.8},{54.4,82.6},{56,71.6},{58.2,40.6},{58.6,81.2},{59.6,25.2},{59.8,63.2},{60.2,72.6},{60.6,66.8},{62,69.2},{64.6,76.6},{67.2,70.2},{67.8,76.4},{67.8,76.8},{69.4,71.2},{69.6,71},{70.4,76.6},{70.6,38.6},{70.8,58.8},{71,61.8},{73.8,63.2},{79.4,45},{79.8,49.8}},
            },
        },
        [61317] = { -- Long-tailed Mole
            [npcKeys.spawns] = {
                [33] = {{66.8,54}},
                [490] = {{36.2,31},{36.8,33.6},{36.8,34.6},{38.4,66.2},{47.4,20},{47.4,30.6},{52,28},{55.4,60.8},{65,72}},
                [1537] = {{21.2,45.6},{21.6,23.2},{21.6,47.4},{22,23.6},{22.4,17.2},{22.4,18},{22.6,17.4},{22.6,17.6},{28.2,28.6},{28.6,28},{29.2,28.8},{38.8,78},{40.4,43.8},{41.4,11.4},{42.4,11},{42.8,11},{42.8,80.4},{49.8,85},{50.4,84},{53.2,10.6},{53.4,10},{53.8,54.8},{54.2,11},{55,11.2},{55.2,53.2},{55.2,53.6},{57.8,38.6},{58.4,39.6},{59,20},{59.2,28.2},{59.6,28.8},{63.2,5.2},{63.6,5},{64.2,5.6},{64.6,5},{72,15.4},{74.6,13},{75,10.8},{75,23.2},{75.6,21}},
                [5287] = {{39.8,72.4},{39.8,72.6},{41.6,73},{42,68.4},{42,68.6},{42.6,71.8},{43.2,71.2},{64,30.2}},
            },
        },
        [61318] = { -- Tree Python
            [npcKeys.spawns] = {
                [33] = {{23.8,22.2},{26.4,24.6},{26.6,20},{27.8,19.8},{28,30.2},{28.4,22},{29,24.6},{29.4,31.2},{30.6,23},{31.4,19.4},{32.4,25.6},{33,22.8},{33.2,29},{34.4,20.8},{34.8,40.2},{35.2,30.2},{36.6,41.4},{36.6,41.6},{37,44.8},{37.2,46.8},{37.4,24},{37.6,24},{37.8,27.4},{37.8,35.4},{37.8,40.4},{37.8,40.6},{38,35.6},{38.4,20.4},{38.8,43},{39.6,33.6},{39.6,43},{40,23.4},{40,38.8},{40.6,36.2},{41,24.4},{41.2,35.2},{41.4,49.4},{41.6,43.4},{41.6,43.6},{41.6,49.6},{42.4,24},{42.4,46.8},{42.6,46.6},{42.6,54.4},{43,22.4},{43,22.6},{43.2,38.6},{43.4,36.2},{43.6,36.4},{44,26},{44,58.4},{44,58.6},{44.2,44.8},{44.2,64.4},{44.4,44.4},{44.4,54.4},{44.4,54.6},{44.8,42.2},{44.8,50.8},{45.8,23.4},{46,43},{46.4,29.2},{46.4,30.8},{46.4,48.4},{46.4,48.6},{46.6,50.4},{47.2,62.6},{47.4,41.2},{47.6,41.2},{47.6,52.8},{47.8,62.4},{47.8,62.6},{48,34},{48.4,38.2},{48.4,44.8},{48.6,44.8},{49,30},{49.2,16.2},{49.2,39.6},{49.6,15.4},{49.6,15.6},{50,57.6},{50.4,55.6},{50.6,55.4},{50.6,55.6},{51.4,18.4},{51.4,64.8},{51.4,69.2},{51.6,18.2},{51.6,65},{52,43},{52.4,68.4},{52.6,49.6},{52.6,68.2},{52.8,43.4},{52.8,43.6},{52.8,59.4},{53,20.4},{53,22.8},{53.4,21},{53.6,18},{53.6,47.2},{53.8,25.4},{53.8,61.8},{54,22.8},{54,41.4},{54,65.4},{54.6,26.2},{54.8,57.8},{54.8,63},{55.2,38.8},{55.4,40.4},{55.4,40.6},{55.4,42.8},{55.6,57.4},{55.8,67.4},{56.4,19.2},{56.4,37.8},{56.6,35},{56.6,49.2},{56.6,53.2},{57,51},{57.2,43},{57.4,68.6},{57.6,31.6},{57.6,45},{57.6,68.4},{57.8,72.2},{58,21.6},{58,62},{58.4,35.2},{58.6,32.2},{58.8,37.4},{59,27.4},{59,46},{59.6,39.6},{59.6,71},{60.2,27.8},{60.2,72.2},{60.6,36.4},{61,37.2},{61.4,21.4},{61.4,26.2},{61.4,35.2},{61.4,43},{61.6,67.2},{61.8,24.8},{61.8,62.6},{62.2,58.4},{62.4,56.4},{62.4,58.8},{62.6,47.8},{62.6,52.4},{62.6,52.8},{62.6,69.8},{62.8,42.4},{62.8,69.4},{63,23.4},{63,23.6},{63,29.4},{63,42.6},{63.2,37.6},{63.2,59.4},{63.4,33.8},{63.4,54.6},{63.6,31},{63.6,41.2},{64,37.4},{64,52.8},{64,61},{64.2,50.2},{64.2,67.8},{64.4,39.8},{64.8,34},{64.8,43.8},{65,48},{65,70},{65.4,31.2},{65.8,42.2},{66.2,35.4},{66.2,43.2},{66.4,30.4},{66.4,35.6},{66.4,53.4},{66.8,38.2},{76.6,31.6},{79.2,26.8},{80.2,23},{80.4,19.4},{83.6,35.2},{83.8,38.4},{87.6,23.2},{88.6,29.4},{89.2,25.4}},
                [490] = {{22.6,64.6},{27.4,66},{30.2,71.6},{30.4,30.8},{31.6,77.8},{35.4,77.8},{38.6,61.2},{38.6,80.8},{39,67.8},{40.6,76.8},{40.8,75.4},{45.2,32.4},{45.8,20.8},{46.2,24},{49.8,85.4},{50,8.6},{53,32.2},{53.6,73.6},{54,72},{55.6,29.6},{56.2,66.6},{56.4,66.4},{58.4,81},{58.6,53.2},{59.4,22.2},{59.6,82.4},{60.6,67},{63,25.2},{63.2,80},{66,40.6},{67.2,64.4},{67.4,51},{68,76.4},{68,76.6},{71,46},{71.4,81.4},{72,40.4},{80,50}},
                [5287] = {{36.8,52.2},{37.2,47.2},{39.2,48.2},{39.2,48.6},{39.4,50.4},{40.4,55},{40.4,78.2},{40.6,78.2},{40.8,44.4},{40.8,50.8},{41.2,30},{41.8,28},{41.8,30.6},{41.8,77.6},{42,25.2},{42.2,49},{42.2,77.4},{43,16.8},{43.4,19},{43.6,32.4},{43.6,32.6},{44.2,42},{44.2,76.6},{44.4,34.8},{44.6,42},{44.8,34.8},{45.2,37},{45.4,38.2},{45.4,41},{45.6,40.8},{45.8,42.8},{46,43.6},{46,55.6},{46,59.2},{46,59.6},{46.4,14.2},{46.6,14.2},{46.8,19},{46.8,35.8},{47.2,21.2},{47.2,52.6},{47.6,49.6},{47.6,66},{47.8,12.6},{47.8,34.4},{47.8,34.6},{47.8,49.4},{48,12.4},{48,36.4},{48,59},{48.2,20.2},{48.6,18.8},{48.6,46.4},{48.6,46.6},{49,31},{49.4,56.6},{49.6,15},{49.8,35.4},{49.8,43.4},{49.8,47.6},{49.8,67.4},{50,51.4},{50,51.6},{50.4,11.4},{50.4,25},{50.6,26},{51,9.6},{51,41},{51.4,9.4},{51.4,33.2},{51.4,50},{51.8,28.4},{51.8,28.8},{52,53},{52.6,20.6},{54,12.6},{54.8,40.6},{55.6,38},{56,40.2},{57.2,27.8},{57.2,49.4},{57.4,81},{57.6,80.8},{57.8,83.2},{58,83.6},{58.2,76.4},{58.2,78},{58.6,47.2},{58.8,43.2},{59.4,85.2},{59.4,85.6},{59.6,85.2},{59.6,85.6},{59.8,21.2},{60.2,40.8},{60.2,87.6},{60.4,77.4},{60.4,77.6},{61.2,86.8},{61.6,86.8},{62.2,78},{62.4,81.2},{62.8,80.6},{63,77.8},{63,86},{63.2,31.2},{63.4,29.2},{63.6,29.2}},
            },
        },
        [61319] = { -- Beetle
            [npcKeys.spawns] = {
                [3] = {{41.8,10.6},{42,10.4},{43.4,10.2},{43.6,9.8},{45.8,57.6},{46,57.2},{48,28},{49.4,28.6},{49.6,28.8},{49.8,28.4},{55.2,14.8},{55.2,15.6}},
                [33] = {{31.2,28},{31.4,19.4},{31.4,19.8},{32.6,20.8},{34.6,20.6},{35.6,30},{36.2,22.8},{38,35.8},{38,40.6},{38.6,20.4},{39.6,43},{40,38.8},{41.4,32.8},{41.8,28},{42.4,24},{42.6,46.8},{43,22.4},{43,22.6},{43.2,38.6},{43.4,36.2},{44,25.8},{44,58.6},{44.2,44.8},{44.2,64.2},{44.4,54.6},{44.8,42.2},{45.8,23.8},{46.4,29.2},{46.4,43.2},{46.4,48.2},{47.2,62.4},{47.2,62.6},{47.4,41.2},{47.6,41},{47.6,52.8},{48.4,44.8},{48.4,49.8},{48.6,44.8},{49,30},{49.2,16.2},{49.2,39.8},{49.6,15.4},{49.6,15.6},{50.6,55.6},{51.2,69},{51.4,18.4},{52.2,43.2},{52.6,68.2},{52.8,43.4},{52.8,43.6},{53,22.8},{53,59.4},{53.6,18},{53.8,49.6},{54,22.8},{54.4,25.2},{54.8,26.4},{55.2,38.6},{55.2,40.6},{55.4,40.4},{55.4,43},{55.8,67.4},{56.6,19.4},{56.6,49},{57,38.6},{57.2,43.2},{57.6,45},{57.6,68.4},{58,31.2},{58,61.8},{58.6,35.2},{58.6,59.8},{58.6,68.2},{58.8,32},{58.8,43},{59,37.4},{59,46},{59.6,71},{60.2,72.2},{61.2,35.2},{61.2,43},{61.4,37},{61.6,67.2},{62.6,47.8},{63.4,33.8},{63.6,33.6},{63.8,41.4},{64.6,52.8},{64.8,52.4},{65.4,31.2},{66.4,35.4},{66.6,38},{66.6,53.6},{79.8,22.6},{83.8,40.2}},
                [361] = {{64,7.4},{64,7.6},{64.6,5.8},{65.8,5.8}},
                [490] = {{21.2,49.8},{22.6,33.4},{22.8,66.6},{30.2,26.8},{30.4,30.6},{32,36},{32,77.8},{32.8,68},{33,72.6},{33.2,65.2},{33.6,22.6},{33.6,72.6},{34,22},{35.2,73.8},{35.4,78},{35.6,73.6},{36,62.2},{38.8,24},{38.8,45.8},{38.8,67.6},{38.8,80.6},{40.6,54.2},{40.6,58.2},{41.6,18},{44.8,66.4},{46,20.8},{48.2,16.6},{49.4,85.4},{50.4,21.4},{52.4,25.2},{52.4,82.4},{53,32.4},{55.4,77.4},{55.6,29.8},{56,79.6},{56.6,77.4},{57,76.4},{59,52.6},{59.6,25.2},{59.6,69.6},{60.6,67},{60.8,78},{61.6,27},{61.6,81.4},{63.2,77},{64,65.2},{64.6,72.4},{65.8,36.8},{65.8,61.4},{67.2,48},{67.2,50.8},{67.2,64.6},{67.2,70},{68.2,76.2},{68.6,64.6},{70.8,64.2},{71,62.4},{71.8,68},{72,69.2},{73.2,37},{78.2,67.4},{79.8,45.2},{80,49.6}},
                [1377] = {{31.4,44},{32.4,56.6},{34.2,59.4},{34.4,64.4},{37,62.8},{37.2,50.8},{37.4,56.6},{38,61.2},{38.8,49.6},{39,57.4},{39.4,56.4},{48.4,32.4},{48.8,19.6},{50,26.2},{50.4,29},{51,41.8},{51.2,47.4},{51.4,31.6},{51.4,44.2},{51.6,49.2},{51.8,40.4},{51.8,44.6},{51.8,47},{52,40.6},{52.4,30.2},{52.8,66.8},{53.2,27.2},{53.2,38.6},{53.4,27.6},{53.4,50.6},{54,28.2},{54.8,48.8},{55,39.4},{55,69.2},{55.6,80.4},{56.4,14.4},{57.8,59},{60.4,45.4},{60.6,47.2},{60.6,57.2},{61.6,51.8},{63.6,49},{64.4,43.2},{64.4,43.8},{64.4,47.6},{64.6,47.6},{64.6,54.6},{65.2,73.2},{65.6,45.8},{65.8,51.4}},
                [5287] = {{37.2,47.2},{39.2,50.4},{40.2,55.2},{40.4,78.2},{42.2,49.4},{42.4,77.2},{43.6,32.4},{44,42.2},{44,76.8},{44.6,42},{44.8,34.6},{45.2,36.8},{45.8,42.6},{46,55.6},{46,59.2},{46.6,19.2},{47.2,52.6},{47.6,49.6},{47.6,58.8},{47.6,66},{47.8,20},{47.8,49.4},{48,36.4},{48.2,13.8},{48.6,18.8},{48.6,46.4},{48.6,46.6},{48.6,65.4},{48.8,31},{49,43.4},{49.8,47.6},{50,51.8},{50,56.6},{50.4,25.2},{51.4,33},{51.4,50},{51.6,27.6},{55.4,38.2},{56,40.2},{57.2,27.6},{57.8,80.8},{58.2,76.2},{58.2,78},{58.2,83.4},{58.4,47},{58.4,76.6},{58.8,29.2},{58.8,43.2},{59.4,85.4},{59.4,85.6},{59.6,85.4},{60.2,21},{60.2,87.8},{60.4,77.4},{60.4,77.6},{60.6,77.6},{61.4,86.8},{61.6,86.8},{62,78.2},{62.2,81.2},{62.6,81},{62.8,80.4},{63,77.8},{63,86},{63.4,29.2},{63.4,29.6},{63.4,31.2}},
            },
        },
        [61326] = { -- Scorpid
            [npcKeys.spawns] = {
                [4] = {{37.6,55.2},{38.6,54.4},{39.8,74.4},{40.6,54.2},{40.6,63.2},{42.6,31.6},{43.2,42.6},{43.2,80},{43.4,19.8},{44.2,37.8},{45.4,80.2},{45.8,13.8},{47.8,26},{48.2,12.6},{48.2,46.8},{48.6,79.2},{48.8,35.8},{49,26},{50.4,32.2},{52.4,25.4},{53.6,29.8},{55,15.4},{55.2,32.4},{55.6,80.2},{57,73},{58,39.8},{59,28.2},{59.6,27.4},{59.8,79},{60.6,35.8},{60.8,33.4},{61,71.2},{61.8,66},{63.6,72.8},{64.4,30.6},{65,42},{67.6,32.2},{68,39.8},{68.8,63.4},{69.6,63.4},{69.8,73}},
                [46] = {{2,29.2},{4.2,36},{5.2,38.4},{5.2,48.8},{11.2,64},{15,50},{19.4,61.4},{24,50},{25,53},{26.2,49.6},{29.4,55.4},{29.6,55.4},{29.8,58.2},{31,41.8},{31,56.6},{32,39.4},{33.8,25.6},{35.2,26.2},{35.6,40},{37.2,58.4},{37.4,45.6},{38.4,35.4},{38.4,35.6},{40,33.6},{40.8,55.2},{42,38.4},{42,62.6},{43.2,51},{48.6,61.6},{48.8,59.4},{49.8,58.4},{50.2,51.8},{51.4,54.6},{55.4,58.2},{55.8,58.4},{57,29.4},{57.6,44.2},{58,32.8},{60,27.2},{60.2,60.4},{62.8,56.8},{64.8,64.2},{65.2,26.8},{69.2,53.8},{74.6,33.2},{74.6,65.4},{78.8,53.6},{79.6,30.6},{83,55.4}},
                [400] = {{6.4,42.2},{7.2,25.6},{7.4,34.4},{7.8,32.6},{8,40},{8.4,42.8},{8.8,31.2},{8.8,42},{9.4,26.4},{9.6,26.8},{11.8,43.2},{15.6,27.8},{15.8,21.2},{16.2,45.4},{17,41.2},{17.4,45.8},{18.4,45.6},{18.4,46.8},{18.6,45.6},{24.6,50},{30.6,55.6},{32,56},{32,59.6},{33,57.8},{34.8,58.2},{35,60.2},{36.6,52.8},{37.6,60.4},{40.6,63.2},{41.2,62},{42.2,63},{42.2,64},{47.4,64.4},{47.4,64.6},{47.6,63.8},{51,61.8},{52,60},{52.4,62.2},{53.2,50.6},{53.4,61},{53.4,63.2},{53.6,61},{54,60},{55.8,58.4},{56,61.6},{57.2,53},{58,62},{58.4,64},{58.4,66.2},{58.6,66.2},{58.8,63.6},{59.4,61.6},{60,63},{63.8,70},{65.2,78},{91.6,76.4},{94.4,76.2}},
                [1377] = {{28.8,70.8},{29.4,36.8},{32.8,27.4},{32.8,74.2},{36.8,21.8},{37.8,35.4},{38,66.2},{39.4,74.8},{39.8,78},{40.6,68.2},{41.4,27.4},{41.4,46.4},{42,30.6},{42.2,76.6},{42.6,17.6},{43,54.2},{45.4,46},{45.8,46.6},{46,66.2},{46.8,37.6},{47,37},{47.8,41.6},{48.6,35.6},{49.2,70.6},{50.4,76},{59.2,52.4},{62.6,42.6},{63,31},{63.6,39.8},{64.2,55},{64.6,41.6},{65.6,22.2},{68.4,67.8},{69,36.4},{74,32},{74,35.6}},
                [3483] = {{13.6,50},{14.6,55},{14.6,55.8},{15.6,50.6},{20.4,45.8},{21.4,53},{22.8,54.4},{23,62.8},{23.4,59},{24.2,54.8},{24.4,70.2},{24.6,69.8},{24.8,62.2},{25.4,54.6},{25.6,67.6},{26,65.6},{26.2,65.4},{27.2,69.6},{28.2,56.2},{28.2,67.4},{29.4,71.2},{30,56},{30.8,37.2},{31.8,56.2},{32.6,48.2},{32.6,52.2},{32.6,52.6},{33,49.8},{36.4,46.4},{37,49},{38,66.2},{38.2,46.4},{39.2,51.6},{39.8,60},{40.2,84.4},{40.4,51.2},{40.6,51.6},{40.8,68.8},{41.8,44.6},{41.8,64},{42.2,72.4},{42.6,47.2},{42.6,61},{43,51.2},{43.4,79.2},{43.6,45.4},{43.6,45.6},{44.2,71.4},{44.4,71.6},{45,58},{47.4,59.8},{47.4,68.6},{47.6,68.6},{47.6,79.4},{48.2,77.4},{48.4,74.6},{48.4,80.4},{49.4,69.6},{50,64.8},{50,80.2},{50.2,44.8},{50.2,57.2},{50.2,57.6},{50.8,41},{50.8,72.6},{51.4,66.6},{51.6,77.4},{52.4,58},{52.4,69.4},{52.6,57.6},{52.6,68.8},{52.6,69.6},{54,58},{54,71.6},{54.6,76.4},{55.4,55},{55.4,70.4},{55.6,55},{55.6,57.4},{55.6,57.6},{55.8,70.4},{56,70.6},{56,75.4},{56.8,55.8},{58,54.8},{58.4,57},{58.4,73.4},{58.6,57},{58.6,73.6},{59,60.2},{59,71.4},{59,71.6},{59.2,62.4},{59.2,63},{59.8,40.6},{59.8,65.4},{59.8,65.6},{61,76.4},{61,76.6},{61,78.4},{61,78.6},{61,80.4},{61,80.6},{61.2,55},{61.2,73.4},{61.4,72.2},{61.6,72.2},{61.8,52.4},{61.8,52.8},{62,57.2},{63,52.2},{63.2,52.6},{63.6,59.2},{63.6,69.4},{63.8,69.8},{64,54.2},{64,54.8},{64,56.2},{64.2,57},{64.4,73.2},{65,66.6},{65.4,45.2},{65.4,61},{65.6,61},{66.2,51.6},{66.4,51.2},{66.4,54},{66.4,65},{66.6,51.2},{66.6,54},{67.4,61.8},{67.6,60.2},{68,51.6},{68.2,51.4},{68.6,55.4},{68.8,56},{68.8,64.6},{69.4,62},{70.2,65.6},{79,51.4},{85.4,50}},
                [3520] = {{22.4,34.6},{23.4,28.2},{24.8,22.2},{25,36.8},{26.6,31.8},{32,28},{32,52.4},{33.4,40},{37.2,36.2},{37.4,41.8},{40.4,29},{42.6,35.2},{43.2,49.2},{45,58.2},{45.2,21},{45.6,31.8},{45.8,37.2},{51.8,31.4},{54.8,30.2},{55.8,35.6},{55.8,39},{55.8,55.4},{56.6,48.4},{57.6,31.8},{58.4,45.4},{59.4,37},{61.2,44},{62.8,36.6},{63,60.6},{64.2,35},{64.6,40.2},{66.4,44},{70.4,67}},
                [3522] = {{29.6,68.2},{43.4,75.8},{44,67.6},{44.8,73},{45.2,57},{46.8,68.2},{56.2,28.6},{56.4,60.8},{57.8,54.2},{58.2,28.4},{58.8,68.8},{59.6,65.8},{64.8,52.4},{67.4,55.6},{67.4,75.2},{68.4,32.4},{68.6,65.8},{71,30.6},{74.2,23}},
                [4922] = {{32.4,25.8},{32.6,25.8},{36.4,19.6},{37,25.6},{37.6,37.4},{37.8,37.6},{42.4,53.8},{43.6,43.4},{44,31.8},{44,34.2},{44.6,36.6},{45.8,21},{46.2,50},{46.8,34.2},{47.4,21},{47.4,45.8},{47.6,21.2},{47.6,35.8},{47.6,49.4},{47.8,22.4},{49,35.4},{49,48.4},{49.6,39.6},{50.6,52.6},{51.2,22},{51.4,17.8},{51.4,77.4},{51.8,23.2},{52,52.4},{52.6,22.4},{52.6,22.6},{52.6,81.2},{53.8,33.2},{53.8,35.6},{54.2,25.8},{54.4,32.2},{54.6,24.4},{55,32.6},{55.6,27.8},{55.8,35.8},{56,37.6},{56.2,8.8},{56.4,12.8},{56.6,36},{56.8,40},{57.2,17},{57.2,22.8},{57.4,39},{59.8,37.6},{60.4,37.2},{61.2,33.8},{62,38.6},{62.8,32.2},{63.2,41.6},{63.6,40.4},{65.6,47.4},{66.2,49.4},{68.6,44.6}},
            },
        },
        [61328] = { -- Fire Beetle
            [npcKeys.spawns] = {
                [4] = {{31.8,72.6},{32.2,64.4},{33.4,75},{36.8,73.4},{37,48.4},{37,48.8},{37.6,60.4},{40,74.8},{40.2,54.6},{40.4,68.4},{40.6,54.2},{40.8,63},{41.4,35.8},{41.6,35.6},{42,14.8},{42,26.4},{42.2,14.4},{42.4,22.4},{42.4,23},{42.8,32.6},{43.2,80.4},{43.4,19.4},{43.4,20.6},{43.4,42.6},{43.4,79.2},{43.6,31.8},{43.6,42.2},{43.6,79.4},{44.2,37.8},{44.4,33.4},{44.4,33.6},{44.6,38.6},{45.4,45.6},{45.4,79.2},{45.4,86.6},{45.6,13.6},{45.6,20},{47.8,12.8},{47.8,26.4},{48.2,47.4},{48.4,11.8},{48.8,35.8},{49,82.4},{49.6,36.4},{50.6,29.2},{51.2,37.4},{51.4,38.6},{53,30.6},{53.2,17.6},{54.8,15.6},{55.2,38.2},{55.4,32.2},{55.8,78.6},{56.6,74},{57.6,19.6},{57.8,24},{57.8,34.8},{58,24.6},{58,39.8},{59.6,27.2},{59.6,27.6},{59.8,79.6},{60,16.4},{60,16.6},{60.6,71.2},{60.8,32.8},{60.8,35.8},{61,64.6},{61.2,32},{61.2,70.4},{61.4,66},{61.6,39.4},{61.6,65.4},{62,40.2},{62.4,13.8},{62.6,79.8},{63.4,72.8},{63.4,73.8},{63.6,34.6},{63.8,27.6},{64.2,26.4},{64.4,30.4},{64.6,30.2},{65,42.2},{65.4,68.8},{65.8,79.8},{66.4,73},{66.4,78.6},{67,36.6},{67.6,32},{67.8,35.8},{67.8,40.6},{71.4,53.2},{71.8,48.2},{71.8,53.4},{71.8,53.6}},
                [46] = {{9.8,46.4},{16,66.4},{20.4,54.8},{30,46},{31.8,55.2},{34.4,36.2},{34.8,35.8},{36.4,52.6},{36.6,52.8},{37.6,55},{38,54},{39.4,52.4},{39.4,52.6},{39.6,52.6},{44.8,55.4},{44.8,55.6},{47.8,59.6},{48,59.2},{54.2,58},{55.8,46.6},{56,46.4},{56.8,36},{60.8,46.2},{61,53.4},{61,53.6},{66.4,30},{68,42.8},{69.8,57.6},{72.8,30},{76.6,47},{77,35.4},{77.2,36}},
                [51] = {{24.4,36.4},{24.4,45.8},{24.6,36.2},{24.6,46.2},{25.8,25.8},{27.4,54},{27.8,46.4},{27.8,55.4},{29,35.4},{29,35.6},{29.8,70.4},{30,50.4},{30,70.8},{30,72},{30.2,26.8},{30.2,50.6},{30.4,26.2},{30.8,60.4},{31,61.4},{31,61.6},{33.6,65.8},{34.4,23.2},{34.4,23.6},{34.6,23.4},{34.6,23.6},{34.8,28.4},{35,28.6},{35.2,45},{35.2,70.4},{35.2,70.8},{35.4,26},{35.6,23},{35.6,26},{36.8,62.8},{37.2,37.4},{37.2,38},{37.2,41.4},{37.2,41.6},{38.8,46.2},{38.8,46.6},{39,38.4},{39,38.6},{40.4,50.4},{40.4,50.6},{40.6,50.6},{40.8,43.4},{40.8,43.6},{40.8,44.6},{40.8,50.4},{42.2,46.4},{42.4,47},{43.2,50.6},{43.2,64.2},{43.2,64.6},{43.4,73.2},{44.2,37.4},{44.2,37.8},{44.2,42.2},{44.6,37.6},{47.2,39.8},{47.2,55},{47.2,55.6},{47.2,68.6},{47.4,68.4},{47.6,55.2},{48.8,42.2},{49,38.4},{49,69.6},{49.2,63.2},{49.2,69},{49.6,69.8},{50.4,69.2},{52.2,39},{53.6,61.4},{53.8,69.4},{54,61.6},{54.4,52},{54.4,69.8},{54.6,70},{55.2,51.4},{55.2,51.6},{55.6,48.4},{56.2,37.2},{56.2,58},{56.6,58.2},{56.6,59},{59.2,61},{59.4,61.6},{59.8,62.2},{61.4,71},{61.8,71.6},{62,60.4},{62.4,54.4},{62.4,54.6},{62.4,65.8},{68.4,37},{68.6,54.2},{72.4,30.2},{72.6,30}},
                [490] = {{44,49.4},{45,56.8},{45.8,54.6},{46,46.6},{47.2,49.6},{47.4,43},{48,53.6},{48,57},{48.2,43},{48.2,48.8},{49.8,54.2},{51.8,54.2},{52,51.8},{52.6,45.2},{52.6,56.2},{53.4,50.4}},
                [616] = {{30.4,79.2},{30.4,80.4},{30.6,80.6},{30.8,78.4},{31.2,82.8},{32,73.2},{32.4,73.6},{32.6,71.8},{32.6,73.6},{32.6,96.6},{32.8,71.4},{33,90.6},{33.4,94.4},{34.8,95.6},{35.8,57.8},{36.4,63},{36.6,97},{37.2,75},{37.6,83.8},{37.8,59.4},{38.4,54.4},{38.4,56.6},{38.8,52.2},{38.8,59.4},{39,79},{39.2,74.2},{39.8,63.6},{40.2,58},{41.8,86.4},{42,83.8},{42.4,77},{42.4,80.6},{42.6,61.8},{42.6,69.6},{42.6,72.8},{42.6,86.4},{43.2,84.8},{43.4,67.4},{43.8,71.2},{44,60.8},{44.2,84.2},{44.6,88.2},{45,86},{45.4,60.4},{45.8,84.8},{46.2,66.8},{46.4,72.4},{46.4,86.8},{47,56.6},{47.4,65.6},{47.6,65.6},{48,64},{48.2,54.4},{48.2,54.6},{48.4,53.2},{48.4,73.4},{48.6,66.8},{48.8,54.2},{49.4,74.2},{50.4,73},{50.8,67},{51.2,51.6},{51.4,86.4},{51.4,86.6},{51.6,83.4},{51.6,83.6},{51.6,86.6},{52,53.4},{52,66.6},{52.2,84.8},{52.6,81.6},{52.8,52.4},{52.8,52.6},{53.4,87.8},{53.6,88},{53.8,54.2},{53.8,66},{54.4,76.2},{54.6,53.2},{54.6,81.4},{55.2,67.8},{55.2,75},{55.2,80.2},{55.6,74.6},{55.8,53.4},{55.8,53.6},{56,57.2},{56.4,58.2},{56.6,57.2},{57,76.8},{57.4,54},{57.6,54},{57.6,76.8},{57.8,85.4},{58,58},{58.8,68},{59.2,68.8},{59.2,76},{60,59.2},{61.4,58.6},{61.4,72.4},{61.6,58.6},{62.4,77.4},{62.6,77.6},{63.2,55.8},{63.2,74},{64,53.6},{64.8,54.8},{66,63},{66.2,73.2},{69.2,72},{74.6,62.6},{77.6,47.8},{78.4,59},{78.6,54.4},{78.6,62.6},{78.8,62.4},{79.4,58.2},{79.6,65},{80.4,49.4},{80.6,49.4},{81.6,65.2},{83.8,63.2},{84.6,58},{88.2,50.2},{89.4,50.4}},
            },
        },
        [61366] = { -- Rat
            [npcKeys.zoneID] = 16,
            [npcKeys.spawns] = {
                [16] = {{30.8,38.2}},
                [38] = {{24.4,30.2},{28.4,80.2},{34.8,76.6},{35.2,61.6},{36,58.2}},
                [45] = {{12.4,36},{14.2,33.8},{19.4,58.4},{25.2,26.2},{47.6,78.8},{48.2,41.2},{49.8,40.6},{49.8,41.8},{69,35.2},{69,35.6}},
                [47] = {{23.4,57.4},{23.4,57.6},{23.8,57.4},{49.8,53},{53.2,39.2},{58.6,65.4},{62.4,65.8},{73,53.2}},
                [85] = {{47.2,53.4},{47.2,53.8},{47.6,30},{50.8,60.6},{52.4,29.6},{53.6,56.2},{54.4,41.2},{54.8,56.8},{55.8,41.2},{56.4,42.6},{57.6,38},{58,32.2},{58.2,47.4},{58.4,37.2},{58.8,33.8},{58.8,36.4},{59.6,37.2},{59.6,50.2},{60,70.8},{60.4,33.8},{61.8,40.4},{62,66.6},{62.2,46.2},{62.2,66.4},{64.2,37},{65.2,58.8},{75,70.4},{77.8,61.6},{81.8,68.4},{82,70.2},{84,40.6}},
                [148] = {{39.8,39.6},{41.6,83.4},{43.6,58.4},{44.6,59.2},{58.8,20.8},{59,25},{62,10}},
                [267] = {{28.6,44.2},{30.2,43.6},{32.2,42.4},{32.4,42.8},{32.6,42.8},{32.8,43.6},{33,31.2},{33.2,31.8},{33.6,41.4},{33.8,30.8},{34,33.4},{34,34.6},{34.2,34.2},{48.8,69.8},{49,67.8},{55.4,25},{56.2,25},{56.6,26.6},{56.8,26.4},{56.8,46.8},{57.6,24.8},{57.8,24.4}},
                [331] = {{11,31.8},{11.2,34.4},{11.2,34.6},{11.4,30.6},{12,31},{12,32.6},{12.2,35.4},{12.2,35.6},{12.4,34.2},{13,32.2},{47.4,65.4},{72.6,80.2},{73,81},{73.2,60},{73.6,61},{87.2,52.8}},
                [405] = {{49.4,55.2},{50.2,63.6},{50.4,74.4},{52.4,58.8},{54,60},{57.6,47.6},{73,36},{74.2,22},{75.4,35.2}},
                [406] = {{42.2,45.4}},
                [495] = {{43.4,29.2},{43.6,36.4},{44.6,27.6},{45.8,27}},
                [3433] = {{60.4,57.8}},
                [3518] = {{43.2,22},{73.2,68.4},{75,71.2}},
                [3519] = {{36,49.4},{36.4,51.8},{36.6,51.8},{37.2,49.8},{38,40},{38,52},{38.4,39},{39.4,54.4},{40.2,42.4},{49,56.6},{49,65.8},{49,68.2},{49.8,67.2},{52,30.4},{52,30.6},{52.2,28.8},{52.2,32},{53.6,29.4},{53.6,29.6},{54.2,32.8},{64,55.6},{64.6,52.4},{64.8,52.6},{66.6,53.6}},
                [3525] = {{51,70}},
                [6454] = {{49,63.6}},
            },
        },
        [61384] = { -- Cockroach
            [npcKeys.spawns] = {
                [11] = {{26.8,25.2},{34,54.4},{34,54.8},{34.6,48.8},{34.8,27.8},{53.2,41.2},{54.2,34.2},{55.4,30.4},{56,25.4},{56.8,30.2},{57.8,35.2},{58.6,24.6},{60,43.8},{60,46},{61.4,46.6},{62.6,37.4},{69.6,33.2}},
                [14] = {{49.4,40},{49.6,40.2}},
                [46] = {{2.2,29.2},{4.2,51.8},{10,50.8},{15,49.8},{26.2,49.4},{29.4,55.6},{30.8,42.6},{31.2,56.8},{35.2,26.2},{36,28.4},{38.4,35.4},{38.4,68},{47,25.8},{48.4,62.2},{50.4,60},{51.6,54.8},{63.8,34.8},{68.4,32.6},{72.4,65.8},{74.4,65.6},{75.4,39.4},{77.4,40}},
                [47] = {{16.8,44.6},{23.2,56.6},{23.4,57.6},{23.6,57.4},{23.6,57.8},{26,66.2},{26,66.8},{32,57.6},{45.4,40.4},{45.6,39.4},{45.6,39.6},{49,53.2},{49.6,53},{53.2,39.2},{58.6,64.2},{58.6,64.6},{58.6,67.2},{58.8,66},{59.4,77.6},{60.4,64.8},{60.6,65.4},{61.4,74},{62.2,75.8},{62.2,76.8},{62.4,66.2},{63.2,60.4},{63.8,74.2},{67.4,66.4},{67.4,66.6},{67.6,75.4},{68.6,72.8},{70.8,48.4},{72.8,53.4}},
                [67] = {{22.8,61.4}},
                [210] = {{18,53.6},{19.6,57},{28,45.2},{28.2,40.4},{30.2,35.2},{30.4,37.4},{30.6,28.4},{30.6,33.4},{30.6,33.6},{30.6,37.4},{31.8,42.4},{33.4,26.8},{36.4,26.4},{40.2,51.4},{41.4,53.4},{42.8,48.8},{43.2,39.4},{43.2,39.6},{43.2,44.2},{44.4,40.6},{45,40.2},{45,80},{46.6,84.2},{46.8,71.8},{47.6,47.2},{48.8,41},{48.8,81},{49.4,45.4},{49.6,86},{50.2,37.4},{50.4,43.4},{50.6,64.2},{51,40.2},{51.8,74.4},{52,43},{52.2,37.4},{52.2,37.6},{53.4,55.4},{54,77},{54.6,52.6},{55.4,40},{55.6,40},{57.2,53.8},{57.2,56.2},{58,36.6},{58,43.2},{59.2,55.2},{59.2,60.4},{60,37.4},{60,44},{60.8,41.4},{62.2,46},{63,40.4},{63,40.6},{63.4,47.8},{63.6,52},{64.4,45.4},{64.4,54.4},{65.2,49.8},{65.6,56.8},{65.8,52.2},{66.4,66.6},{66.6,54.6},{66.8,46.4},{66.8,46.6},{67,68.2},{67.2,50.2},{67.2,60.6},{67.4,63},{67.8,52.4},{67.8,52.6},{68,65.6},{68,67.2},{68,67.6},{68,71},{68.2,65.4},{68.4,55.6},{70,63},{70,65.8},{70.2,67.2},{71.2,69.2},{75.4,60.2},{76,60.8},{76.8,54.6},{76.8,67.4},{77,57.8},{77.6,63.6},{77.6,66.6},{78.6,55.8},{78.8,64.2},{78.8,65.4},{78.8,65.6}},
                [490] = {{36.4,31.2},{36.8,33.8},{45.2,17.8},{47.4,19.8},{47.4,30.6},{47.8,16.8},{48.4,24.6},{49.4,21},{51.2,29.2},{54.6,23.4},{54.6,60.2},{55.4,60.8},{56.6,62.8},{65.4,72.2},{66.6,66.6},{69.4,39.6}},
                [4922] = {{19.8,15.2},{19.8,16.6},{20.6,14.8},{21.8,19.6},{23,22.4},{23,22.6},{36.4,81.6},{37.4,47.6},{38.6,48},{41.2,84.8},{45,37.8},{46.2,33.8},{49,37.2},{50.4,69},{50.8,33.6},{51.6,26.2},{53,29.4},{53,74.6},{55.6,47},{55.6,50.4},{55.8,56.6},{56,52},{56.2,32.8},{56.2,50.6},{56.8,47.6},{57,33.6},{57,49},{57,57.4},{57.4,46},{57.6,47.2},{57.8,56.4},{57.8,57.2},{58,30.2},{58.2,54},{58.4,48},{58.4,49.4},{58.4,58.2},{58.4,84.2},{58.6,49.6},{58.6,56.6},{58.6,58.2},{58.8,29.2},{59,30.6},{59,47.4},{59,54.8},{59.4,46.2},{59.4,54.4},{59.6,46.2},{59.6,51},{59.6,54.2},{60.2,55.8},{60.6,50.6},{61,76.8},{61.2,48.4},{61.2,48.6},{61.4,54},{61.6,50},{61.8,53},{61.8,55.2},{62,51.8},{62,56.2},{62.2,48.8},{62.4,85},{62.8,49.8},{62.8,54.8},{63.6,51.2},{63.6,70.8},{63.8,49},{63.8,53},{64.8,77.4},{66.4,83.2}},
            },
        },
        [61398] = { -- Xin the Weaponmaster
            [npcKeys.spawns] = {
                [zoneIDs.MOGUSHAN_PALACE_THRONE_OF_ANCIENT_CONQUERORS] = {{40.2,86.1}},
                [zoneIDs.MOGUSHAN_PALACE] = {{-1,-1}},
            },
        },
        [61528] = { -- Lava Guard Gordoth
            [npcKeys.spawns] = {[zoneIDs.RAGEFIRE_CHASM] = {{33.76,81.74},{-1,-1}}},
        },
        [61530] = { -- Explosive Hatred
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{74.8,88.4}}},
        },
        [61539] = { -- Ku-Mo
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES]= {
                {43.8,65.8,phases.KU_MO_AT_BRIDGE},
                {39.4,61.8,phases.KU_MO_AT_TEMPLE},
            }}
        },
        [61680] = { -- Kor'kron Scout
            [npcKeys.spawns] = {[zoneIDs.RAGEFIRE_CHASM] = {{51.99,26.09},{61.04,43.06},{64.58,71.16},{67.97,60.23},{43.09,66.3},{36.72,84.38},{36.24,84.61},{35.79,84.91},{-1,-1}}},
        },
        [61694] = { -- Sentinel Ku-Yao
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{17.44,57.01}}},
        },
        [61716] = { -- Invoker Xorenth
            [npcKeys.spawns] = {
                [zoneIDs.RAGEFIRE_CHASM] = {
                    {-1,-1},
                    {67.72,11.41},
                    {33.39,80.42,phases.RAGEFIRE_CHASM_GORDOTH_DEAD},
                },
            },
        },
        [61724] = { -- Commander Bagran
            [npcKeys.spawns] = {
                [zoneIDs.RAGEFIRE_CHASM] = {
                    {-1,-1},
                    {68.21,12.22},
                    {31.63,76.34,phases.RAGEFIRE_CHASM_GORDOTH_DEAD},
                },
            },
        },
        [61757] = { -- Red-Tailed Chipmunk
            [npcKeys.spawns] = {
                [141] = {{36.2,28.2},{37,23.6},{37.4,26.8},{37.6,28.2},{37.8,32},{38.4,27.2},{38.6,31},{38.6,34.2},{39.2,35},{39.2,48.6},{39.4,48.4},{39.8,45.4},{40,25},{40.4,54},{40.6,54.4},{41.2,27.4},{41.2,33.2},{41.2,44},{41.4,35.8},{41.4,43},{41.6,43},{41.8,53.6},{42.2,23.4},{42.4,30.2},{42.4,41.8},{42.4,45.4},{42.4,55.6},{42.4,59.4},{42.6,39.2},{42.6,43.2},{42.6,47},{42.8,23.4},{42.8,36.8},{43,23.6},{43,26.4},{43.2,38.4},{43.4,61.6},{44,60.4},{44,60.6},{44.4,42.2},{45.4,41.6},{45.8,67.2},{46.2,66},{47,24.8},{47.2,62.2},{47.6,67.8},{47.8,21.8},{48.8,23.8},{48.8,55.8},{49.2,47.2},{49.2,48.4},{49.8,52},{50,67.6},{50.2,49},{51.2,66},{51.6,53.4},{52.2,59.6},{52.4,59.4},{53,47.8},{54,67.2},{54.6,64.6},{54.6,89},{54.8,87.8},{55,52},{55,66.2},{55,89.8},{55.2,56},{55.4,90.8},{55.6,54.4},{56.6,51.2},{56.6,62},{57,54},{57.2,48.6},{57.8,52.2},{57.8,55.8},{59.6,48.6},{60.2,47.6},{60.4,60.8},{61.6,47.6},{61.6,57.8},{62.4,46},{62.6,46},{63.6,44.4},{64,51},{64,58.4},{65,55.4},{65.2,44.2},{65.4,46.6},{65.4,49.4},{65.4,51.4},{65.8,51},{66.2,46}},
                [267] = {{28,62},{29,67},{30.4,46.4},{30.8,46},{31,49},{31.4,60.8},{31.6,60.6},{32.4,52.2},{33.4,54.4},{33.6,54.2},{34.6,54.2},{35.2,77.4},{35.4,31.4},{35.4,35.6},{35.4,42.4},{35.6,42.4},{35.6,44},{35.6,69.2},{35.8,31.6},{36,34.4},{36.2,35.2},{36.8,38.6},{36.8,69},{37,77.2},{37.2,72.4},{37.2,77.6},{37.4,38.2},{37.6,71.8},{37.8,38.4},{37.8,39.2},{38.2,74.6},{38.4,45},{38.8,41.8},{39,47.8},{39.2,49.8},{39.4,39.6},{39.6,44.6},{39.8,39.8},{40.2,45.8},{40.8,46},{40.8,68.6},{41.6,65.2},{43,47.4},{43.4,47.8},{43.4,50.4},{43.6,47.6},{43.6,70.6},{44.2,68.4},{45.4,48.8},{46.4,63.4},{47.2,62.4},{47.2,62.8},{47.2,64},{47.4,48.2},{50.2,50},{51,60.4},{51.4,42.4},{52.2,61.4},{52.8,39.4},{52.8,44.4},{54,43.2},{54.2,60.6},{54.6,70.2},{54.6,73.4},{55.2,43.4},{55.2,61},{56.4,66.4},{56.6,66.4},{57.6,54.8},{58,65.2},{58.2,51.8},{58.8,41.8},{59.2,50},{59.6,46.6},{59.6,49.6},{59.8,46.4},{59.8,71.4},{59.8,71.6},{61,42.2},{61.2,72.6},{61.4,52.4},{61.6,72.8},{62.8,58.2},{62.8,62.8},{63,48.2},{63,71.6},{63,75.4},{64.6,36.4},{65.2,70.8},{65.4,69.2},{65.8,69},{66.2,74.8},{66.2,75.6},{66.4,71.4},{66.8,75.6},{68.4,67.4},{68.6,66.8},{68.8,54},{68.8,66.2},{68.8,68.2},{69,56.8}},
                [405] = {{49,52.4},{50,51},{50.2,58},{51,50.8},{51.2,49.6},{52.2,55.6},{52.4,47.4},{53.2,44},{53.2,50.4},{53.2,50.6},{54.4,40.2},{54.8,50},{54.8,58.4},{55,50.6},{55.6,52.8},{55.8,52.4},{57.2,54},{57.4,62},{57.8,54},{57.8,54.8},{57.8,59.8},{58.6,36.6},{59,40},{59,53.6},{59.2,53.4},{60,38.6},{60.4,44},{61,44.2},{61.2,48.4},{61.8,38.4},{61.8,40.8},{62.4,50.6},{62.8,53.4},{63.2,55.8},{65.4,54},{65.8,43}},
                [1657] = {{32.4,41.6},{32.4,60.8},{32.6,41.2},{32.6,41.8},{32.6,60.8},{37.2,47.8},{37.4,49},{41.2,36.8},{41.2,81.4},{41.2,81.6},{42.2,47.4},{43.6,17.8},{45.2,35.4},{45.2,35.6},{45.2,80},{45.6,36.2},{49,24.2},{49.8,86.4},{49.8,86.6},{52.8,19.2},{53.2,20},{53.4,80.8},{53.8,26.8},{55,66.6},{56,80},{57,40.6},{57.8,62},{58.4,31.2},{59,31.4},{60.4,30.4},{60.6,30.6},{61.2,38.8},{61.2,82.6},{61.4,42.2},{61.4,47.4},{61.4,71.6},{61.6,47.6},{61.6,71.2},{61.8,38.4},{61.8,38.6},{61.8,42.2},{61.8,47.2},{63.2,46},{63.4,78.4},{63.4,78.6},{63.6,78.6},{64,78.2},{66.4,34.4},{66.6,34.4},{66.6,34.6},{67.4,52.2},{67.6,52},{68,56.6},{68.8,46.4},{73.2,50.4}},
                [6450] = {{47.4,77.2}},
            },
        },
        [61796] = { -- King Varian Wrynn
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{82.59,28.08}}},
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [61822] = { -- SI:7 Field Commander Dirken
            [npcKeys.spawns] = {
                [zoneIDs.RAGEFIRE_CHASM] = {
                    {-1,-1},
                    {68.34,12.81},
                    {31.63,76.34,phases.RAGEFIRE_CHASM_GORDOTH_DEAD},
                },
            },
        },
        [61823] = { -- High Sorceress Aryna
            [npcKeys.spawns] = {
                [zoneIDs.RAGEFIRE_CHASM] = {
                    {-1,-1},
                    {69.38,10.95},
                    {33.39,80.42,phases.RAGEFIRE_CHASM_GORDOTH_DEAD},
                },
            },
        },
        [61829] = { -- Bat
            [npcKeys.spawns] = {
                [85] = {{11.2,58.8},{11.6,63.4},{11.8,63.8},{13,55.8},{13.2,57.8},{14.4,59.8},{14.4,68},{14.6,60.4},{15.4,70.4},{15.6,70},{15.6,71.2},{16,62.8},{16.2,62.2},{16.8,65},{18,70.6},{18.4,70.2},{18.8,60.4},{18.8,61.2},{21.4,58.8},{21.6,73.4},{47.4,57.6},{48,57.6},{48.8,60.2},{49.8,58.4},{50.6,58.8},{51.2,56.8},{51.2,57.6},{61.4,66.4},{61.4,67.4},{61.4,68.2},{61.8,66.4},{61.8,68},{62.2,66.8}},
                [130] = {{33.4,3}},
                [139] = {{4,45.4},{4,45.6},{4.4,43},{4.6,42.8},{5.2,49},{6.8,51.4},{8.2,53.2},{8.6,54.4},{8.6,55},{10.2,57.6},{11.8,56.8},{12.2,72.4},{12.2,72.8},{13.2,21.6},{13.6,64.6},{14.2,70.8},{14.2,71.6},{14.6,24.2},{15,64.2},{15.2,70.8},{15.4,23.4},{15.6,21},{15.6,71.4},{16,31.4},{16.4,18.8},{16.4,72},{16.6,21},{16.8,72.2},{17,32.2},{17.2,72.6},{18.6,78.4},{18.8,78.6},{19,73.2},{19.4,23.4},{20,66.2},{20.6,30.2},{21,26.2},{21,77.6},{21.2,26.8},{21.4,62},{21.6,18.6},{22,81.6},{22,82.8},{22.2,32.8},{23.8,34.2},{23.8,57.8},{24,62.4},{24,62.6},{24.6,61.6},{25.2,63.2},{25.8,75.2},{26.8,59},{26.8,65.8},{27,65.4},{27.2,18.4},{27.2,33.6},{27.2,70},{28,37.2},{28,67.2},{28.4,76.8},{28.8,76.8},{29,63.2},{29.2,67},{29.8,71.2},{29.8,71.6},{30,65},{30,75.4},{30,75.6},{30.2,35},{30.6,66.8},{30.8,21.6},{30.8,61.8},{31,25.8},{31.2,23.4},{31.6,31.6},{32.4,63.4},{32.4,66.2},{32.6,63.6},{32.6,66},{33,78.6},{33.2,78.4},{33.6,74.8},{34.2,25.8},{34.6,27},{35.2,16.4},{35.2,73.2},{35.4,16.8},{35.4,62.8},{35.4,75.2},{35.4,75.6},{35.6,62.8},{35.8,18.4},{35.8,76.2},{36.4,19.6},{36.6,18.8},{36.6,29.4},{37,63},{37.2,60.6},{37.6,61.4},{37.6,69.2},{37.6,71},{37.8,79.6},{38.2,66.2},{38.4,34},{38.6,30.4},{38.6,77.4},{38.6,77.6},{39.2,24.2},{39.2,65},{39.4,73},{39.6,64.8},{39.6,70.8},{39.6,73},{39.8,68},{40,67.4},{40.2,69.4},{40.2,74.2},{40.6,60.4},{41,28},{41,29},{41,31},{41.2,34.4},{41.4,73},{41.6,23.8},{41.6,73},{42,59.8},{42.2,31.6},{42.4,31.2},{42.6,33.4},{43,72.8},{43.2,25.6},{43.8,24.8},{43.8,26.8},{43.8,36},{43.8,64},{44.2,22},{44.4,61.6},{44.8,34.2},{44.8,54.4},{44.8,55.2},{45,49.6},{45,56.2},{45,72.2},{45.4,70.4},{45.6,27.8},{46,22.6},{46,39.4},{46.2,39.8},{46.6,58.6},{46.8,58.2},{47.2,25.6},{47.6,18.6},{48.2,71},{48.4,50.8},{48.6,37.8},{49.2,28.4},{49.6,39.4},{49.8,30.8},{49.8,73.8},{50.4,50},{50.6,25.4},{50.6,72.8},{51.4,67.2},{51.6,69.2},{51.6,69.8},{52.2,16},{52.4,42.4},{52.4,42.8},{52.4,71.8},{52.4,74.4},{52.4,74.6},{52.8,58},{52.8,75.6},{53,29.2},{53.2,27.6},{53.2,48.2},{53.4,17},{53.8,22.2},{53.8,23.8},{53.8,42.4},{54,42.8},{55,19.8},{55,48.6},{56,44.6},{56,52},{56.4,78.6},{56.6,78.4},{56.6,78.6},{57.6,42.8},{58,31.8},{58.4,33},{58.4,59.6},{58.6,21},{58.6,37.8},{58.6,58.4},{58.6,61.6},{58.6,78.2},{58.8,54.6},{58.8,61.4},{59.4,45},{59.6,61.6},{59.8,45.2},{60,37.6},{60.2,25.2},{60.4,22.8},{61,36},{61.6,59.2},{61.6,62.8},{61.8,23.2},{62,29.4},{62,37.4},{62,74.2},{62.4,26.2},{62.4,72.8},{62.6,26.2},{63,28},{63,45.6},{64,32},{64,37},{64.2,30.8},{64.2,53.2},{64.4,44.8},{64.4,65.8},{64.6,43.4},{64.6,45},{64.6,72.6},{64.8,34},{64.8,38.4},{64.8,38.6},{64.8,43.6},{65,40.4},{65.2,32.6},{65.2,36},{65.6,32.8},{65.6,66.2},{66.4,48.8},{67,51},{67.4,63.4},{67.8,27.6},{68,69.8},{68.2,65},{68.4,30},{68.6,46},{69.4,48.8},{69.4,50.6},{69.4,67},{69.6,67.2},{69.6,67.8},{70,71},{70.2,48.4},{70.4,65},{71,60.4},{71,61.4},{72,63.6},{72.2,53.6},{72.4,49.4},{72.6,54},{73.6,61},{73.8,56.2}},
            },
        },
        [61834] = { -- Alyn Black
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{64.4,69.4},{64.4,69.8},{64.8,68.4},{64.8,69.4},{64.8,69.6}}},
        },
        [61836] = { -- Moni Widdlesprock
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{64.4,69.8},{64.8,68.4},{64.8,69.4},{64.8,69.6}}},
        },
        [61838] = { -- Gavin Marlsbury
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{65.2,65.2},{65.6,64.6},{65.8,64.4}}},
        },
        [61841] = { -- Brunn Goldenmug
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{71.4,48.6},{71.8,48.4},{72,48.6}}},
        },
        [61842] = { -- Zandalari Warrior
            [npcKeys.spawns] = {[6201] = {{80.91,75.69},{67.31,70.34},{66.93,77.92},{62.82,87.17},{56.48,86.10},{55.81,76.68},{56.28,66.40},{60.15,58.71},{62.69,60.09}}},
        },
        [61981] = { -- Dreadspinner Tender
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{65.8,28},{66,29.8},{66.4,28.8},{67.2,29.4},{67.2,29.6},{67.4,30.8},{67.6,30.4},{67.8,31.2},{68.4,29},{68.6,30},{70.2,25.8},{70.4,27.6},{70.6,27.6},{71.2,22.4},{71.2,22.6},{71.2,26.2},{71.4,24.2},{71.4,27.2},{71.6,24.4},{71.6,28.4},{72,26.4},{72,26.6},{72.2,29.2},{72.4,22.4},{72.4,23},{72.4,29.6},{72.6,22.2},{72.8,23.4},{72.8,23.6},{72.8,29.4},{72.8,29.8},{74,22.4},{74,22.6},{74,24.4},{74,24.6}}},
        },
        [62019] = { -- Cat
            [npcKeys.spawns] = {
                [12] = {{43.4,52.8},{44,52.6},{44.2,52.4},{44.4,53.8},{44.6,53.4},{44.6,53.6}},
                [45] = {{16,65.6},{18.4,67.6}},
                [3487] = {{91.2,56},{91.8,57.8}},
                [6455] = {{59.4,41.2},{61,41.2}},
            },
        },
        [62024] = { -- Dragon Launcher
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{70.62,31.42}}},
            [npcKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [62077] = { -- Dreadspinner Egg
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{68.72,30.33},{67.91,31.6},{67.49,30.45},{67.48,28.78},{65.99,30.08},{65.58,28.08},{66.03,27.34},{68.56,28.79},{69.31,30.24},{72.83,30.16},{72.47,29.83},{72.56,28.73},{72.04,27.58},{71.52,28.67},{71.36,27.47},{72.1,26.59},{71.13,26.08},{71.41,24.29},{70.89,22.17},{71.58,22.02},{72.47,22.12},{72.57,23.3},{73.78,22.49},{74.75,21.22},{74.23,23.9},{74.13,24.78}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [62092] = { -- Garrosh Hellscream
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{70.62,31.42}}},
            [npcKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [62166] = { -- Marksman Lann
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{72.55,28.67}}},
        },
        [62177] = { -- Forest Moth
            [npcKeys.spawns] = {
                [141] = {{39.2,47.2},{40.6,30.2},{56,54},{62,50.2}},
                [331] = {{16.8,36.6},{17,24.6},{17.6,20.8},{17.8,31.4},{18.6,19.2},{18.8,59.2},{19,57.2},{19.2,34.4},{19.8,20.2},{20,28.8},{20,33},{20.4,58.2},{20.6,50.8},{21,48.6},{22.2,34.6},{22.4,57.6},{22.8,47.4},{22.8,48.6},{23,35},{23.4,52.6},{23.8,37.8},{25,28.4},{25.2,27.4},{25.2,31.2},{25.4,52.6},{25.6,25.4},{26.2,30.6},{26.6,42.4},{27,21.4},{28,17.6},{29,47.4},{31.8,46},{32.2,41.6},{35,69.8},{35.2,42.8},{39.2,40.6},{39.2,69.4},{39.4,66.8},{40,66},{40.4,56.4},{40.6,57.8},{42.6,61.4},{43.2,43.6},{43.2,48.6},{43.6,69.2},{44.4,63.4},{44.6,67.6},{46.6,64.4},{46.6,64.6},{47,62},{48.6,66},{51.2,62.8},{52,61},{52.6,63.2},{53.8,71.6},{54,70.8},{54,72.6},{54,74},{54.4,69.6},{54.8,29.2},{55.2,69.2},{56.4,55.2},{56.4,70.8},{56.4,72.4},{56.6,72.4},{57.2,73.4},{57.2,73.6},{57.4,69.2},{58.2,66.8},{58.8,65.4},{59.4,68.4},{59.4,73.2},{59.4,74.2},{59.8,64.6},{59.8,71.8},{60,70.8},{60.8,55.4},{61,80.2},{61.2,57},{61.4,42.2},{61.8,78.4},{61.8,82.6},{62.2,54.4},{62.2,81.2},{62.2,84.2},{62.8,82.6},{63.2,75.6},{63.2,77.8},{63.6,43.6},{63.8,73.6},{63.8,84.4},{64,72.8},{64,85.6},{64.2,49.4},{64.2,51.6},{64.4,65.6},{64.6,83.8},{65.4,71.8},{65.6,60.6},{65.6,85.8},{65.8,74},{66.2,68.8},{66.8,74},{66.8,86.4},{67,62.4},{68,74.2},{68.4,61.6},{68.4,65},{68.6,81.2},{69,64.2},{69,79.6},{69.2,66},{69.2,82.6},{69.4,86},{69.8,63},{70,84.8},{70.4,59.8},{70.8,84.4},{71.2,50.2},{71.4,56.6},{71.4,73.4},{71.6,79.4},{71.6,79.6},{72,67.6},{72.2,70.4},{72.2,72.2},{72.6,55.4},{72.8,71},{73,72.8},{73.2,77.4},{73.2,78.6},{73.4,70.4},{73.8,67.6},{73.8,77},{74.2,74.6},{74.4,70.2},{76,52},{76.2,71.2},{77.8,65.8},{87,41.2},{87.2,50.6},{88.8,65.4},{89,47.4},{90.2,48.6},{90.8,61.4}},
                [405] = {{48.2,46},{48.2,49.2},{49,46.8},{49.8,51.8},{49.8,56.2},{50.4,42.8},{50.4,49.4},{50.4,57},{51.2,44.8},{51.4,57.4},{52.4,50},{52.6,46.4},{53,48.8},{53,57.6},{53.4,43.2},{53.4,48.4},{53.6,48.6},{53.6,54},{53.8,46.6},{54.6,63.4},{54.6,63.6},{54.8,52.6},{55.2,51.8},{55.8,36.8},{56.6,47.4},{56.8,39.8},{57,49.4},{57.6,45.8},{58.4,56.8},{59,55.6},{59.2,45},{59.6,47.4},{59.8,55.8},{60.2,40.6},{60.2,51.4},{60.2,57.6},{61.2,36.2},{61.2,47.8},{61.8,60.2},{62,38.4},{62.4,55.4},{64.6,41.6},{65.2,52},{66,51.8}},
                [493] = {{42,43.4}},
                [1657] = {{42.4,47.4},{45.2,50},{46.4,36.6},{46.6,36.8},{48.4,56.4},{53.6,54.4},{61.2,51},{62.2,45.8},{67.4,54},{67.8,47.6},{73.2,50.4}},
            },
        },
        [62178] = { -- Elfin Rabbit
            [npcKeys.spawns] = {
                [141] = {{40.2,30.6},{40.6,33.4},{43,61.6},{43.4,38.2},{49.4,47.4},{50.2,50.4},{55.2,56},{55.4,90.8},{60.4,60.8}},
                [405] = {{49,51.6},{53,43.4},{54.4,46.4},{55,50.8},{56,37.8},{57.6,40.4}},
                [616] = {{18.6,42.2},{19,39.2},{19.2,36.4},{21,39.2},{22.8,32},{31.6,36},{38.8,44},{43.8,44},{47.6,17.4},{47.8,17.6},{49.8,16.8},{50.4,22},{50.6,22.2},{56.2,34.6},{56.4,36.4},{56.4,36.6},{56.6,36.8},{57.2,17.2},{57.4,15.8},{57.4,22.8},{58,19.8},{58.2,16.4},{58.2,16.6},{58.2,23.2},{58.2,36.8},{58.6,26.4},{58.6,26.6},{58.6,37.2},{58.8,17.8},{59,36.2},{59.2,21},{59.2,32.2},{59.2,32.6},{60.4,17.8},{60.6,36},{61,19.4},{61.2,19.6},{61.2,34.4},{61.2,34.6},{61.4,29.2},{61.4,29.6},{61.6,22.4},{61.6,22.6},{61.8,28.4},{61.8,28.6},{62.4,20.4},{62.6,32.4},{62.6,32.6},{63,21},{63,34},{63.2,29.4},{63.2,29.6},{63.4,30.6},{63.6,25},{63.6,30.8},{64,25.8},{64.8,19.6},{64.8,21.2},{65.8,20.8},{66,30.6},{66.2,18.8},{66.2,25.4},{66.2,25.6},{66.4,22.2},{66.6,28.2},{68,21.8},{68.2,23},{68.2,24.2}},
                [1657] = {{32,70.8},{32.6,41.6},{41.2,81.6},{42.2,47.4},{45,80.8},{45.2,35.4},{49.2,74.2},{55.2,66.4},{67.2,51.6},{68,47.4}},
            },
        },
        [62180] = { -- Korven the Prime
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{54.31,36.09}}},
        },
        [62184] = { -- Rock Viper
            [npcKeys.spawns] = {
                [405] = {{24.2,68.8},{24.2,70.8},{24.4,70.4},{25.2,71.4},{25.4,70.2},{28,82.8},{29,79},{29.2,77.6},{29.8,66.6},{30.4,71},{30.4,81.4},{30.6,33.2},{30.8,52.6},{30.8,60.2},{30.8,76.4},{31.6,61.8},{32,69.6},{32,77.4},{32.2,69.2},{33.4,50.8},{33.4,52.6},{33.8,51},{33.8,74.6},{35.2,38.8},{35.4,80.8},{36.4,61.2},{36.6,40.8},{37.6,36.6},{39.2,89.6},{39.4,33.8},{39.8,35},{40.6,31.2},{40.8,69.4},{41,25},{41.8,25},{41.8,52},{42.2,33.6},{42.2,86.2},{42.4,59},{42.6,82.8},{42.6,85.8},{44,39.2},{44.2,50.8},{44.6,76.8},{45,17.2},{45,27.6},{45,88},{47.2,29.2},{48.6,31.8},{49.6,67.4},{49.8,27.6},{50.2,68.8},{50.6,68.8},{51,63.8},{52.2,60.8},{52.8,66.6},{53,6.4},{53,6.6},{54,11.8},{54,84},{54.2,34.4},{54.4,8.8},{54.6,8.8},{54.8,13},{54.8,33},{54.8,68.6},{55.2,10},{55.4,66.4},{55.4,85},{56,14.4},{56,14.6},{56,22.8},{56.4,16.2},{56.8,81.2},{57,64.4},{57,84},{57.2,15.4},{57.2,15.6},{57.4,24.2},{57.6,29},{57.6,63.8},{58.4,77.8},{58.6,16.2},{58.8,22.2},{59,19.8},{59,30},{59,70.8},{59.2,25.4},{59.2,79},{59.4,73.4},{59.4,75.8},{59.6,75.8},{60.2,32.2},{60.4,26.8},{60.4,76.6},{60.6,77},{61,78},{61.4,29.8},{61.8,27.8},{62.2,72.8},{62.4,27},{62.8,24.8},{63.8,92.2},{64.4,17.4},{64.4,23.4},{64.4,35.6},{64.6,17.4},{64.6,90.4},{64.6,90.6},{64.8,23.4},{64.8,23.6},{65,20},{65.8,25.6},{66,25.4},{66,30.8},{66.2,10},{66.2,19.2},{66.2,31.6},{66.6,17.2},{67,22.2},{67,22.6},{67.2,20.4},{67.2,20.8},{67.2,23.6},{67.2,26.4},{67.6,31.4},{67.8,31.8},{68,23.4},{68,49.8},{68.2,18.6},{68.2,54.2},{68.4,18},{68.4,24},{68.8,32.8},{68.8,59},{69.2,44.4},{69.2,44.6},{69.4,25.6},{69.4,32.2},{69.4,35.2},{69.4,43.2},{69.4,49.6},{69.6,49.4},{70,25.6},{70,61.2},{70.2,40.4},{70.2,40.6},{70.2,47.2},{70.4,25.2},{70.4,30.2},{70.4,55.4},{70.6,30.2},{70.6,41.2},{70.6,55},{70.8,35.2},{71,15.4},{71,15.6},{71,35.8},{71.2,60.4},{71.4,27},{71.4,44.6},{71.4,46.8},{71.4,56.6},{71.6,17.8},{71.6,27},{72,41.8},{72.2,23},{72.2,32.4},{72.2,32.6},{72.4,37},{72.4,49.8},{72.8,18.2},{72.8,33},{72.8,36.8},{72.8,64.6},{73,49},{73,56.8},{73.4,21.4},{73.4,21.6},{73.6,21.4},{73.6,21.6},{73.8,27},{73.8,30},{73.8,34.4},{74,29.4},{74,35.4},{74,47.4},{74,47.6},{74,51.8},{74.2,24.4},{74.2,25},{74.2,45.6},{75.2,30},{75.2,33.2},{75.4,33.6},{76,23.4},{76,23.6},{76.2,17.8},{76.4,25},{76.4,25.6},{76.4,33.8},{76.6,25.4},{76.6,33.8},{76.8,52.2},{77.4,25.6},{77.6,18.4},{77.6,18.6},{78,25.4},{78,25.6},{78.8,21.2},{80.2,17}},
                [616] = {{35.4,80.8},{35.6,58},{35.8,52},{36.2,59.6},{36.4,79.2},{36.4,83.2},{37,77.8},{37.2,75},{37.6,83.8},{38.2,56.6},{39,52.2},{39,79},{39,81.4},{39,81.6},{39.6,83.6},{39.8,57.8},{40,80},{41.2,75.8},{41.2,79.8},{41.4,85.2},{42.2,75.4},{42.6,87.6},{42.8,69.8},{43.8,71.2},{45.6,69},{48,68.6},{55.2,67.6},{55.8,87.2},{57.8,85.4},{60.8,74.6},{61.4,72.4},{61.4,72.6},{61.6,72.4},{61.8,77},{62.6,77.4},{63,71.4},{63.2,74},{63.6,73.4},{64.2,75},{64.8,76},{68,66.2},{68.4,70.4},{70.2,66.2},{71.8,59.8},{72.6,59},{72.6,59.6},{73.6,61.8},{74,59.6},{74.4,59},{74.6,62.4},{74.6,62.6},{75.2,61.4},{76.8,59.4},{77.6,47.8},{77.6,63.6},{78.8,54.4},{78.8,62.4},{78.8,63.6},{79.2,60.2},{79.4,58.2},{79.8,54.2},{80.4,49.4},{80.6,49.4},{80.6,51.6},{80.6,60.4},{80.8,49.6},{81.4,63.4},{81.4,65},{81.6,63.4},{81.6,63.6},{82.6,62.4},{82.6,65.2},{83,55.8},{83,61},{83.4,59.6},{83.6,57},{84.2,65},{84.4,57.6},{84.8,55.8},{86.2,58},{87.4,54.4},{89,49.4},{89.2,56},{89.8,51.8}},
                [1377] = {{27.4,21.2},{28,22.4},{28.6,15.6},{28.8,15.4},{29,11.8},{29,18.4},{29,18.8},{29.2,17},{29.6,16.8},{29.6,18},{30.2,13.8},{30.4,12},{30.4,15.8},{30.8,16},{31,12.4},{31,12.6},{31.2,14.6},{31.4,14.4},{32,15},{32.6,12.2},{34.2,13.2},{35.2,15.6},{36,15.2},{36.2,16}},
                [3522] = {{29.2,57},{31.4,48.8},{32.8,59.4},{39.4,54.6},{39.6,74.8},{40.8,48.2},{41.4,78.6},{41.6,82.8},{43.8,68.4},{44.2,77.4},{45.2,57},{45.2,68},{46.6,71.8},{47,76.8},{50.4,45.2},{51.4,41.6},{53.2,45.8},{54,33},{54.6,37},{55.8,31.8},{57.2,57.4},{57.6,64},{58.6,62.8},{58.8,68.8},{59.8,66.2},{60.2,71.8},{64.6,56.4},{64.8,52.4},{64.8,78},{65.4,13.6},{67.4,55.6},{67.4,75.2},{68,39.6},{68,58.8},{69.6,43},{72.8,30.2}},
            },
        },
        [62186] = { -- Desert Spider
            [npcKeys.spawns] = {
                [405] = {{24.2,68.8},{28,81},{29,80.8},{30.8,58},{31,53},{31.8,61.8},{32.6,31.2},{33.4,51},{33.4,52.6},{33.6,54.6},{36.4,61},{36.6,40.8},{39.8,25},{41.4,42.8},{41.6,26.8},{41.6,56.6},{42.2,59.2},{43.4,50.2},{44,58.8},{44.2,30.6},{44.2,58.4},{44.4,50.6},{50.8,63.6},{52.2,60.8},{53,6.4},{53.8,12.4},{54.2,69},{54.8,9},{56,14.4},{56,22.8},{56,68.8},{56.4,16.4},{57.2,15.4},{57.2,24.2},{57.4,85.4},{57.6,29},{58.6,19.6},{59.2,21.6},{59.4,30},{59.6,75.4},{60,27.2},{60,29.6},{60,32},{60.4,76.8},{60.8,90.6},{61.2,21},{62.4,27.2},{62.8,25},{63.2,30.2},{63.4,62.8},{63.8,22},{64.6,23.4},{64.8,20.2},{66,25.4},{66,31},{66.8,68.6},{67.4,23},{67.6,31.6},{68,49.4},{68.4,54.2},{69.2,44.6},{69.4,32.2},{69.4,35},{69.4,49.8},{70,25.6},{70.4,55.4},{70.6,29.6},{70.6,41.4},{70.6,41.6},{70.8,35.2},{71,15.4},{71,15.6},{71.4,47},{72.2,22.8},{72.4,49.8},{72.6,37},{72.8,56.8},{73,49},{73.4,21.4},{73.4,21.6},{73.6,21.4},{73.6,21.6},{73.8,27},{73.8,30},{74,51.6},{74.2,24.8},{74.2,45.6},{74.6,24.6},{75.4,33.4},{75.6,33.6},{76,17.8},{76,23.6},{76.4,25.4},{76.6,33.4},{77.6,18.4},{77.8,18.6},{77.8,25.4},{78,25.6},{78.8,21.4},{80.2,17.2}},
                [440] = {{34.6,55.2},{35.6,36.6},{37.6,36.8},{41.4,37.2},{42,26.6},{45.8,31.6},{45.8,48.8},{48.2,28},{48.4,25.8},{48.4,29.6},{48.6,27.2},{48.6,31.2},{48.8,28.6},{48.8,32.8},{49,28.2},{49,30.2},{49.2,33.6},{49.6,28.4},{49.6,28.6},{49.6,29.6},{49.6,32.6},{49.8,30.8},{49.8,33.6},{49.8,34.6},{50,26.4},{50,31.8},{50.4,37},{50.6,34.4},{50.8,36},{50.8,46.6},{51.2,26.6},{51.2,38.2},{51.4,31.2},{51.6,34.2},{52,48.4},{52.8,26},{60,51.4},{60.6,54.6}},
                [1377] = {{33,68.4},{42,61.6},{43.6,78},{45.8,54.4},{46.4,80.6},{46.6,80.2}},
                [5034] = {{24,9.4},{26,7},{27.6,13},{28,33},{28.2,33.6},{28.2,35.8},{29.4,9.6},{29.4,35.4},{30,26.6},{30.8,41.8},{45.2,16.4},{46.4,13.8},{48.6,21},{51.4,15.6},{51.8,70.4},{53.2,28.6},{60.2,72.2},{60.6,72},{61.4,74.4},{61.4,75.2},{62.2,18.4},{62.4,14.6},{62.6,24.6},{63,23.4},{63.2,39.8},{65.8,46},{66,47.8},{67.6,24},{67.8,21},{67.8,33},{68.2,39.2},{68.4,40.4},{69.6,56.2},{70.2,40.2},{70.4,38.8},{70.6,38.8},{70.6,40},{72.8,70.8},{73,42},{76.6,43.4},{76.8,66},{78,65.8},{79.2,49.8}},
            },
        },
        [62209] = { -- Arena Credit
            [npcKeys.spawns] = {[zoneIDs.BRAWLGAR_ARENA] = {{51.6,49},{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BRAWLGAR_ARENA,
        },
        [62232] = { -- Korven the Prime
            [npcKeys.name] = "Korven the Prime",
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{66.76,65.29}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [62281] = { -- Fear-Stricken Sentinel
            [npcKeys.spawns] = {{{32.4,61.2},{32.4,61.8},{32.8,61},{33,61.6},{34.2,61.2},{34.2,62},{34.4,60.4},{34.8,61.8},{35.4,57.4},{35.4,57.6},{35.4,60.2},{35.6,60.8},{35.6,61.6},{35.8,60},{36.2,58.2},{36.4,57},{36.4,59},{36.6,57.2},{36.6,58.6},{36.6,61.8},{36.8,59.8},{37,61.4},{37.2,57.6},{37.6,59.4},{38,60.2},{38,60.8}}},
        },
        [62304] = { -- Ban Bearheart
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {
                {49.02,70.45,phases.SHADO_PAN_GARRISON_NORMAL},
                {49.17,71.05,phases.SHADO_PAN_GARRISON_SURPRISE_ATTACK},
            }},
        },
        [62373] = { -- Silky Moth
            [npcKeys.spawns] = {
                [490] = {{30.2,30.6},{34.2,28.6},{47.4,28.6}},
                [493] = {{37.8,62.2},{40.2,69.2},{62.2,45.6}},
                [616] = {{39.4,25.6},{39.6,25.8},{40.2,26.6},{40.6,30.6},{40.8,29.8},{41.4,24.6},{46.2,32.6},{48.4,22.4},{48.4,22.6},{49.2,22.4},{49.2,23.6},{49.6,21.4},{50,28.8},{51.2,26.6},{59,24},{59,26.2},{59.4,28.8},{59.6,29},{59.8,23.4},{59.8,23.6},{60.4,29.6},{60.6,29.4},{60.6,29.6},{61,21.4},{61,21.6},{61.4,23.2},{61.4,27.4},{61.4,27.6},{61.6,23.2},{61.6,27.4},{62.2,27.8},{62.4,21},{62.6,21.2},{62.8,22.8},{62.8,26},{63.8,23.6},{64,22.8},{65.2,23.4}},
            },
        },
        [62385] = { -- Den Mudclaw
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.26,34.21}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [62463] = { -- Sho the Wise
            [npcKeys.zoneID] = zoneIDs.SILVERMOON_CITY,
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{82.8,38.8}}},
        },
        [62538] = { -- Kil'ruk the Wind-Reaver
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {55.09,33.83,phases.KIL_RUK_AT_PILLAR},
                {55.06,35.85,phases.KIL_RUK_NEXT_TO_ZIKK},
            }},
        },
        [62542] = { -- Kovok
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{41.34,71.29}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [62562] = { -- Find Cave Credit
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{33.13,61.49}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [62666] = { -- Sapmaster Vu
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {51.21,11.39,phases.SAP_MASTERS_AT_BREWGARDEN},
                {38.18,17.18,phases.SAP_MASTERS_AT_RIKKITUN},
            }},
        },
        [62667] = { -- Lya of Ten Songs
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {50.73,11.71,phases.SAP_MASTERS_AT_BREWGARDEN},
                {38.3,17.14,phases.SAP_MASTERS_AT_RIKKITUN},
            }},
        },
        [62668] = { -- Olon
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {51.17,11.21,phases.SAP_MASTERS_AT_BREWGARDEN},
                {38.2,17.12,phases.SAP_MASTERS_AT_RIKKITUN},
            }},
        },
        [62751] = { -- Dread Lurker
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{51.6,19},{52,18.4},{52.8,18.6},{54,20.4},{54,20.6},{54.2,18.2},{54.4,17.4},{54.4,18.6},{54.6,18.4},{54.6,18.6},{54.6,19.6},{54.8,16.8},{56,16.4},{56.2,17.4},{56.2,17.6},{56.4,19},{56.8,18.6},{57.4,20.4},{57.6,20.4},{58.4,19.2},{58.6,19.2}}},
        },
        [62760] = { -- Frightened Mushan
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{46.8,20.4},{47.2,20.8},{47.8,20.6},{48.4,18.6},{48.4,20.4},{48.6,20.2},{48.8,21.4},{49,18.4},{49,18.6},{49.2,16.4},{49.6,16.4},{49.6,16.6},{49.8,17.6},{49.8,19.4},{51,17.6},{51.2,15},{51.2,16.8},{51.4,16.2},{51.6,14.8},{52,16.4},{52,16.6},{54,16},{56,19.4},{56,19.6}}},
        },
        [62773] = { -- Iyyokuk the Lucid
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{32.67,33.88}}},
        },
        [62774] = { -- Malik the Unscathed
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {54.89,34.14,phases.MALIK_AT_PILLAR},
                {55.06,35.47,phases.MALIK_NEXT_TO_ZIKK},
            }},
        },
        [62779] = { -- Chen Stormstout
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {50.45,12.05,phases.CHEN_62779_AT_BREWGARDEN},
                {44.41,16.8,phases.CHEN_62779_INSIDE_KOR_VESS}
            }},
        },
        [62923] = { -- Empty Package
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{22.9,30.6}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [62984] = { -- Stunned Whitepetal Carp
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{40.45,49.71},{40.69,50.28},{42.27,47.42},{41.99,47.4},{41.45,46.73},{41.4,46.48}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63009] = { -- Master Snowdrift
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {
                {49.49,70.5,phases.SHADO_PAN_GARRISON_NORMAL},
                {49.24,70.85,phases.SHADO_PAN_GARRISON_SURPRISE_ATTACK},
            }},
        },
        [63071] = { -- Skeer the Bloodseeker
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {25.71,50.58,phases.SKEER_IN_CAVE},
                {44.41,16.8,phases.SKEER_IN_KLAXXI_VEES}
            }},
        },
        [63072] = { -- Rik'kal the Dissector
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{54.37,35.94}}},
        },
        [63087] = { -- Shao-Tien Ritual Statue
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{43.81,44.73}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63088] = { -- Shao-Tien Ritual Statue
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{44.19,44.25}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63089] = { -- Shao-Tien Ritual Statue
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{43.36,42.84}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63090] = { -- Shao-Tien Ritual Statue
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{42.99,43.37}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63123] = { -- Mogu Ritual Destroyed Credit
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{43.6,43.77}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63128] = { -- Chao the Voice
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{43.6,43.77}}},
        },
        [63136] = { -- Lao-Chin the Iron Belly
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{50.56,67.86}}},
        },
        [63154] = { -- Ripe Juicycrunch Carrot
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63156] = { -- Plump Juicycrunch Carrot
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63157] = { -- Bursting Green Cabbage
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63158] = { -- Bursting Juicycrunch Carrot
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63160] = { -- Bursting Scallions
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63164] = { -- Plump Scallions
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63165] = { -- Ripe Scallions
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63180] = { -- Bursting Mogu Pumpkin
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63184] = { -- Plump Mogu Pumpkin
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63185] = { -- Ripe Mogu Pumpkin
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63194] = { -- Steven Lisbane
            [npcKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE] = {{46,40.45}}},
        },
        [63206] = { -- Ik'thik Harvester
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{32.4,50},{32.6,50.4},{33.2,50.6},{34,51},{34.4,51.6},{35,51.8},{37.2,51.8},{38.4,49.4},{38.4,49.6},{38.6,49.4},{38.6,49.6},{40.2,47.8},{40.2,52.2},{40.6,52.4},{42.4,50.4},{42.4,50.6},{42.6,50.4},{43.2,52},{43.6,52.4},{44.8,57.8},{45,56.4},{45,56.6},{45.2,53.2},{45.6,58},{46,53.2},{47.6,60.2},{48.6,61.4},{49,62.4},{49,63.6}}},
        },
        [63223] = { -- Bursting Red Blossom Leek
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63228] = { -- Plump Red Blossom Leek
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63229] = { -- Ripe Red Blossom Leek
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63245] = { -- Bursting Pink Turnip
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63249] = { -- Plump Pink Turnip
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63250] = { -- Ripe Pink Turnip
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63260] = { -- Bursting White Turnip
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63264] = { -- Plump White Turnip
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63265] = { -- Ripe White Turnip
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [63266] = { -- Sinan the Dreamer
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.49,40.79}}},
        },
        [63273] = { -- Ancient Mogu Artifact
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{31.19,30.96}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63296] = { -- Gato
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_TRIALS,
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_TRIALS] = {{42.2,68.4}}},
        },
        [63307] = { -- Lore Walker Cho
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{28.82,32.62}}},
        },
        [63314] = { -- Wodin the Troll-Servant
            [npcKeys.spawns] = {[zoneIDs.ARENA_OF_ANNIHILATION] = {{50,18.48}}},
            [npcKeys.zoneID] = zoneIDs.ARENA_OF_ANNIHILATION,
        },
        [63317] = { -- Captain "Soggy" Su-Dao
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {55.66,72.49,phases.SOGGY_IN_HUT},
                {54.77,72.11,phases.SOGGY_OUTSIDE},
            }},
        },
        [63335] = { -- Mojo Stormstout
            [npcKeys.spawns] = {[zoneIDs.AMMEN_VALE] = {{50.46,48.71}}},
        },
        [63349] = { -- Deck Boss Arie
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {56.57,75.82,phases.ARIE_AT_DOCK},
                {54.72,72.16}, -- She is always at this location. Right now she won't show at both locations, because the distance is too short.
            }},
        },
        [63369] = { -- Rockshell Snapclaw
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{39,79.4},{39.2,79.6},{39.4,78.4},{39.6,78.2},{40,79.6},{40.2,79.4},{40.8,77.8},{41,77.4},{41.6,76},{41.8,78},{42,77},{42.2,75},{42.4,79.2},{42.6,79.2},{42.6,79.6},{42.8,77},{43,78.4},{43.2,76.2},{43.4,74.8},{43.6,74.8},{43.8,71.8},{43.8,79.6},{44,78.6},{44.4,76.4},{44.4,77.4},{44.4,78},{44.6,76.4},{44.6,76.6},{45.2,78.4},{45.2,79.4},{45.4,79.6},{45.6,69},{45.6,76},{45.6,78.4},{45.6,78.6},{46.6,74.8},{46.6,78.6},{47,77.4},{47,77.6},{47,80.2},{47,81.4},{47,81.6},{47.8,71.4},{47.8,75.4},{48,76},{48.8,76.6},{49,75.4},{49.2,75.8}}},
        },
        [63465] = { -- Muckscale Flesheater
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{25.73,52.79}}},
        },
        [63466] = { -- Muckscale Flesheater
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{25.73,52.79}}},
        },
        [63510] = { -- Wulon
            [npcKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{75.36,71.72}}},
            [npcKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [63517] = { -- The Spring Drifter
            [npcKeys.spawns] = {[zoneIDs.THE_VEILED_STAIRS] = {{52.04,43.12}}},
        },
        [63576] = { -- Osul Fire-Warrior
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{26.57,59.32},{26.15,59.18},{26.22,59.82},{26.60,59.96},{27.00,60.04},{27.30,60.74},{27.65,60.96},{28.11,60.83},{28.47,61.50}}},
        },
        [63614] = { -- Ling of the Six Pools
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {
                {49.01,71.33,phases.SHADO_PAN_GARRISON_NORMAL},
            }},
        },
        [63618] = { -- Hawkmaster Nurong
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{48.96,71}}},
        },
        [63758] = { -- Kaz'tik the Manipulator
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{54.26,35.78}}},
        },
        [63765] = { -- Kovok
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{50.79,41.37}}},
        },
        [63778] = { -- Messenger Grummie
            [npcKeys.spawns] = {
                [zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{18.47,56.60},{55.32,50.15},{70.02,23.57}},
                [zoneIDs.KRASARANG_WILDS] = {{40.46,33.92}},
                [zoneIDs.THE_JADE_FOREST] = {{45.72,43.8}},
            }
        },
        [63822] = { -- Tani
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{16.2,82.54}}},
        },
        [63879] = { -- Silt Vents Kill Credit
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{46.42,73.94}}},
        },
        [63880] = { -- Shipwreck Kill Credit
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{44.66,78.66}}},
        },
        [63881] = { -- Whale Corpse Kill Credit
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{40.01,78.89}}},
        },
        [63908] = { -- Ban Bearheart
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{42.62,63.92}}},
        },
        [63943] = { -- Mistfall Village Fire Bunny
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{32.54,75.39},{32.45,73.56},{34.06,73.93},{36.10,76.54},{38.54,71.85},{36.60,71.08}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [63944] = { -- Longfin Thresher
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{38.8,78.2},{39,79.6},{39.4,77.4},{39.4,78.6},{39.8,79.8},{40.2,78.4},{40.2,78.6},{40.8,80.6},{41.2,76.8},{41.2,78.2},{41.2,80},{41.4,76.4},{41.4,79},{41.6,76},{41.6,79.2},{41.8,80.6},{42,79.6},{42.4,77.4},{42.4,77.8},{42.6,77.4},{42.8,76.4},{42.8,78.8},{43,81},{43.2,75.4},{43.2,80.2},{43.4,70.4},{43.4,77.8},{43.8,80},{44,69.6},{44,76},{44,79},{44,80.6},{44.2,77.2},{44.4,75.2},{44.4,78.4},{44.6,77.4},{44.8,74.2},{44.8,78},{45,71.2},{45,74.6},{45,80.4},{45,80.6},{45.2,72.8},{45.2,78.6},{45.2,81.6},{45.4,75.6},{45.6,74.6},{45.6,76},{45.8,76.6},{45.8,78.2},{45.8,80},{45.8,82.2},{46,73.2},{46,80.6},{46.2,74.4},{46.2,79.2},{46.6,76},{46.6,78.6},{46.6,80.6},{46.8,71.4},{46.8,72.2},{46.8,74.4},{46.8,77.4},{46.8,77.6},{47,82},{47,83.2},{47.2,75.2},{47.4,72.8},{47.4,79.6},{47.6,73},{47.6,75.6},{47.6,77.6},{47.6,79.8},{47.8,75.2},{48,77},{48,79.4},{48.2,74},{48.2,82.8},{48.6,72.4},{48.8,77}}},
        },
        [63948] = { -- Shao-Tien Pillager
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.47,72.26}}}, -- TO DO: add the rest of the spawns
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [64033] = { -- Master Angler Marina
            [npcKeys.friendlyToFaction] = "A",
        },
        [64183] = { -- Enormous Stone Quilen
            [npcKeys.name] = "Enormous Stone Quilen",
            [npcKeys.spawns] = {[zoneIDs.MOGUSHAN_VAULTS] = {{48.1,63},{55.2,66.1},{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.MOGUSHAN_VAULTS,
        },
        [64200] = { -- Golden Lotus Guard
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{33.49,72.28}}}, -- TO DO: add the rest of the spawns
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [64244] = { -- Mishi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.77,67.04}}},
        },
        [64259] = { -- Master Angler Ju Lien
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {53.64,76.04,phases.JU_LIEN_AT_COAST},
                {54.9,72.82,phases.JU_LIEN_IN_TOWN},
            }},
        },
        [64269] = { -- Sha of Doubt Portal
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{49.36,60.79},{49.13,59.67},{48.67,58.91},{48.14,58.81},{47.38,58.59},{46.58,58.95},{45.99,59.7},{45.93,60.64},{46.3,61.87},{46.93,62.54},{47.68,62.36},{48.37,62.03}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [64280] = { -- Maki Waterblade
            [npcKeys.spawns] = {[zoneIDs.ARENA_OF_ANNIHILATION] = {{45.96,51.27}}},
        },
        [64281] = { -- Satay Byu
            [npcKeys.spawns] = {[zoneIDs.ARENA_OF_ANNIHILATION] = {{45.96,51.27}}},
        },
        [64328] = { -- Kill Credit: Find Cave Entrance
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{37.05,23.86}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [64330] = { -- Julia Stevens
            [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{41.66,83.66}}},
        },
        [64344] = { -- Kaz'tik the Manipulator
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{41.77,72.03}}},
        },
        [64385] = { -- Sheepie
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{34.99,38.5,phases.SHEEPIE_FIRST_TIME}}},
        },
        [64386] = { -- Sheepie
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{47.54,37.64,phases.SHEEPIE_SECOND_TIME}}},
        },
        [64432] = { -- Sinan the Dreamer
            [npcKeys.spawns] = {
                [zoneIDs.MOGUSHAN_PALACE_THE_CRIMSON_ASSEMBLY_HALL] = {{30.40,19.60}},
                [zoneIDs.MOGUSHAN_PALACE] = {{-1,-1}},
            },
            [npcKeys.zoneID] = zoneIDs.MOGUSHAN_PALACE,
        },
        [64459] = { -- Shado-Pan Trainee
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{17.57,58.04}}},
        },
        [64460] = { -- Shado-Pan Trainee
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{17.4,56.92}}},
        },
        [64461] = { -- Shado-Pan Trainee
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{18,53.45}}},
        },
        [64473] = { -- Tenwu of the Red Smoke
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{50.62,68.5}}},
        },
        [64474] = { -- Hawkmaster Nurong
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{50.7,68.18}}},
        },
        [64475] = { -- Mishi
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.84,81.08}}},
        },
        [64562] = { -- Talking Skull
            [npcKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP] = {{26.87,58.66,phases.TALKING_SKULL_BRIDGE_43},{-1,-1}},
                [zoneIDs.SCHOLOMANCE_MOP_THE_UPPER_STUDY] = {{49.02,21.01,phases.TALKING_SKULL_STUDY_43}},
            },
        },
        [64563] = { -- Talking Skull
            [npcKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP] = {{26.87,58.66,phases.TALKING_SKULL_BRIDGE_90},{-1,-1}},
                [zoneIDs.SCHOLOMANCE_MOP_THE_UPPER_STUDY] = {{49.02,21.01,phases.TALKING_SKULL_STUDY_90}},
            },
        },
        [64583] = { -- Klaxxi Traitor
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{56.19,57.52}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [64596] = { -- Teng Applebloom
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.22,84.68}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [64599] = { -- Ambersmith Zikk
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{55.02,35.55}}},
        },
        [64645] = { -- Hisek the Swarmkeeper
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{56.28,58.24}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [64647] = { -- He Softfoot
            [npcKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{40.88,52.31}}},
            [npcKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [64663] = { -- Zhao-Jin the Bloodletter
            [npcKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{47.93,27.35}}},
            [npcKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [64705] = { -- Hisek the Swarmkeeper
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{56.26,57.6}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [64738] = { -- Hooded Crusader
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_HALLS] = {{31.88,84.39},{-1,-1}},
                [zoneIDs.SCARLET_HALLS_ATHENAEUM] = {{39.26,13.38,phases.HOODED_CRUSADER_ATHENAEUM_31}},
            },
        },
        [64764] = { -- Hooded Crusader
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_HALLS] = {{31.88,84.39},{-1,-1}},
                [zoneIDs.SCARLET_HALLS_ATHENAEUM] = {{39.26,13.38,phases.HOODED_CRUSADER_ATHENAEUM_90}},
            },
        },
        [64827] = { -- Hooded Crusader
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_FORLORN_CLOISTER] = {{72.66,46.91}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [64838] = { -- Hooded Crusader
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_FORLORN_CLOISTER] = {{72.66,46.91}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [64841] = { -- Hooded Crusader
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49.15,76.32}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [64842] = { -- Hooded Crusader
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49.15,76.32}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [64854] = { -- Blade of the Anointed
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49.14,24.63}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [64855] = { -- Blade of the Anointed
            [npcKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_CRUSADERS_CHAPEL] = {{49.14,24.63}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
        },
        [64889] = { -- Ren Firetongue
            [npcKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{58.58,44.28}}},
            [npcKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [64895] = { -- Survival Ring Blades Credit
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{18.87,67.83}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [64937] = { -- Great Cliff Hawk
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{46.62,16.64}}},
        },
        [65310] = { -- Turnip Punching Bag
            [npcKeys.zoneID] = 0,
            [npcKeys.spawns] = {},
        },
        [65325] = { -- Puntable Marmot
            [npcKeys.zoneID] = 0,
            [npcKeys.spawns] = {},
        },
        [65341] = { -- Ku-Mo
            [npcKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{48.66,71.07}}},
        },
        [65354] = { -- Ancient Amber Chunk
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{66.88,65.4}}},
        },
        [65365] = { -- Kor'ik
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{48.12,49.62}}},
        },
        [65648] = { -- Old MacDonald
            [npcKeys.spawns] = {[zoneIDs.WESTFALL] = {{60.85,18.5}}},
        },
        [65651] = { -- Lindsay
            [npcKeys.spawns] = {[zoneIDs.REDRIDGE_MOUNTAINS] = {{33.3,52.57}}},
        },
        [65655] = { -- Eric Davidson
            [npcKeys.spawns] = {[zoneIDs.DUSKWOOD] = {{19.88,44.62}}},
        },
        [65656] = { -- Bill Buckler
            [npcKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN] = {{51.47,73.39}}},
        },
        [65824] = { -- Shao-Tien Behemoth
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{44.1,15.24}}},
            [npcKeys.waypoints] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{{47.53,37.16},{47.51,36.79},{47.47,36.12},{47.44,35.46},{47.45,34.78},{47.45,34.27},{47.46,33.81},{47.46,33.35},{47.44,32.89},{47.41,32.43},{47.38,31.98},{47.36,31.52},{47.30,31.07},{47.21,30.63},{47.08,30.21},{46.92,29.82},{46.69,29.34},{46.45,28.78},{46.29,28.15},{46.17,27.51},{46.04,27.03},{45.88,26.64},{45.70,26.26},{45.52,25.88},{45.34,25.51},{45.16,25.14},{44.99,24.76},{44.83,24.37},{44.68,23.96},{44.55,23.56},{44.41,23.14},{44.30,22.71},{44.22,22.26},{44.17,21.81},{44.13,21.36},{44.09,20.90},{44.06,20.44},{44.03,19.99},{44.02,19.53},{44.01,18.93},{44.01,18.26},{44.01,17.59},{44.04,16.92},{44.05,16.39},{44.06,16.11},{44.1,15.24}}}},
        },
        [65868] = { -- Lao Softfoot
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{37.62,22.99},{39.2,19.09},{40.71,18.28},{39.67,25.98},{43.1,22.36},{47.56,18.96},{50.44,23.43}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [65899] = { -- Master Kistane
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{48.12,40.35}}},
        },
        [65910] = { -- Sunke Khang
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.25,84.72}}},
        },
        [65935] = { -- Unleashed Spirit
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{38.2,23.2},{38.2,23.6},{38.4,22.4},{38.6,22.6},{38.8,22.4},{39.4,19.2},{39.4,23.6},{39.6,23.2},{40.2,19.4},{40.2,25},{40.4,19.6},{40.4,23.8},{40.4,26.2},{40.4,26.6},{40.6,19.4},{40.6,19.6},{40.6,25.6},{40.8,18.4},{41,24.4},{41.2,22.2},{41.2,25},{41.2,27.4},{41.4,20.6},{41.4,23},{41.4,27.6},{41.4,28.8},{41.6,22.4},{41.6,23},{41.6,25},{41.6,27.2},{41.6,28.2},{41.8,23.6},{42,25.6},{42.2,20.6},{42.4,19.2},{42.4,19.8},{42.6,19.4},{42.8,19.8},{43,34.2},{43.2,21.8},{43.2,27.6},{43.4,20.6},{43.4,23.4},{43.4,23.6},{43.4,25.4},{43.4,26.2},{43.4,26.8},{43.6,21},{43.6,27.2},{43.8,20.4},{43.8,26.4},{43.8,27.6},{44.2,17.6},{44.2,19.4},{44.2,22.4},{44.2,23.2},{44.2,25.4},{44.4,15.4},{44.4,16.4},{44.4,16.8},{44.4,23.6},{44.6,16.2},{44.6,17},{44.6,18.4},{44.6,19.4},{44.6,20.4},{44.6,21.4},{44.6,22.4},{44.6,23.4},{44.8,24},{45,15.2},{45.2,14.4},{45.2,30.8},{45.4,25.4},{45.4,25.6},{45.4,26.6},{45.4,27.6},{45.4,29},{45.4,33.4},{45.4,33.8},{45.6,22.2},{45.6,25.4},{45.6,26.4},{45.8,23.6},{45.8,33.6},{46,23.4},{46,30.8},{46,33.4},{46.2,27.2},{46.2,27.8},{46.4,28.6},{46.4,30.4},{46.4,32.2},{46.6,23.8},{46.6,28},{46.8,22.6},{46.8,26.4},{46.8,26.6},{46.8,28.8},{47,30.2},{47.2,30.6},{47.2,32},{47.4,21.8},{47.4,32.6},{47.4,34.2},{47.4,35},{47.4,36.4},{47.4,36.8},{47.6,28.4},{47.6,28.8},{47.6,30.4},{47.6,31.2},{47.6,32.4},{47.6,34},{47.6,35.2},{47.6,36},{47.6,36.8},{47.8,26.4},{47.8,37.8},{48,21.6},{48,38.6},{48.2,20.4},{48.4,21.2},{48.4,25.2},{48.4,26.8},{48.4,39.8},{48.4,41},{48.6,30.2},{48.6,31.6},{48.6,40.6},{48.8,26.6},{48.8,40},{49,21},{49,25.8},{49.4,20},{49.4,21.6},{49.4,25.2},{49.6,20.4},{49.6,20.6},{49.6,21.6},{49.6,25.6},{49.8,38.4},{49.8,38.6},{50,24.6},{50,33},{50.2,24.4},{50.6,24.8},{50.6,38.4},{51,29},{51,34.2},{51.2,34.6},{51.4,22.4},{51.4,23},{51.4,23.6},{51.4,29.6},{51.6,22.4},{51.6,22.8},{51.6,23.6},{51.6,28.8},{51.6,40.8},{52,27.8},{52.2,29.6},{52.6,22.4},{52.6,22.8},{52.6,41},{53,28.6},{53.4,23.6},{53.4,26},{53.4,27.8},{53.6,23.8},{53.6,26.2}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [65960] = { -- Master Woo
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{48.12,40.35}}},
        },
        [65962] = { -- Shao-Tien Behemoth
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{44.15,15.52}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [65978] = { -- Shao-Tien Soul-Render
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{55.4,92.6}}},
        },
        [66073] = { -- Master Yoon
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{48.12,40.35}}},
        },
        [66080] = { -- Bursting Witchberries
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66084] = { -- Plump Witchberries
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66085] = { -- Ripe Witchberries
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66108] = { -- Bursting Jade Squash
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66112] = { -- Plump Jade Squash
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66113] = { -- Ripe Jade Squash
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66123] = { -- Bursting Striped Melon
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66128] = { -- Plump Striped Melon
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66129] = { -- Ripe Striped Melon
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {
                {52.03,48.24},{52.01,48.44},
                {51.9,48.44,phases.FARM_HAS_4_SLOTS},
                {51.92,48.24,phases.FARM_HAS_4_SLOTS},
                {51.78,48.45,phases.FARM_HAS_8_SLOTS},
                {51.81,48.25,phases.FARM_HAS_8_SLOTS},
                {51.71,48.24,phases.FARM_HAS_8_SLOTS},
                {51.68,48.46,phases.FARM_HAS_8_SLOTS},
                {51.66,47.87,phases.FARM_HAS_12_SLOTS},
                {51.77,47.87,phases.FARM_HAS_12_SLOTS},
                {51.78,47.65,phases.FARM_HAS_12_SLOTS},
                {51.67,47.67,phases.FARM_HAS_12_SLOTS},
                {51.86,47.86,phases.FARM_HAS_16_SLOTS},
                {51.98,47.84,phases.FARM_HAS_16_SLOTS},
                {51.99,47.64,phases.FARM_HAS_16_SLOTS},
                {51.89,47.65,phases.FARM_HAS_16_SLOTS},
            }},
        },
        [66138] = { -- Master Cheng
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{48.12,40.35}}},
        },
        [66180] = { -- Master Cheng
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{48.12,40.35}}},
        },
        [66190] = { -- General Nazgrim
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{31.4,11.2}}},
        },
        [66256] = { -- Master Cheng
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{48.53,41.5}}},
        },
        [66292] = { -- Sky Admiral Rogers
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_KINGDOMS] = {
                    {41.48,70.2,phases.SKYFIRE_STORMWIND},
                },
                [zoneIDs.THE_JADE_FOREST] = {
                    {42.04,92.75,phases.SKYFIRE_JADE_FOREST},
                    {48.05,88.39,phases.ADMIRAL_ROGERS_PAWDON_VILLAGE},
                },
            },
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
        },
        [66296] = { -- Taran Zhu
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.25,84.8}}},
        },
        [66297] = { -- Skyfire Gyrocopter
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{42.02,92.51}}},
        },
        [66308] = { -- Thunder Hold Munitions
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{33.6,13.4},{34.86,12.21},{33.91,12.15},{33.66,12.1},{34.38,13.37},{34.49,13.01},{34.65,11.68},{34.99,11.61},{34.05,11.7},{33.55,11.47},{33.68,9.69},{34.13,9.53},{34.63,9.55},{35.11,9.45},{34.86,9.2},{34.59,9.14},{34.77,8.22},{34.07,9.06},{33.62,9.11},{34.45,7.32},{35.47,8.47},{35.59,7.41},{35.28,7.03},{34.37,6.68},{33.88,6.52},{33.22,6.16},{33.02,6.59},{32.8,6.79},{32.48,5.74},{32.14,5.96},{33.85,10.17},{33.86,11.05},{34.48,11.2},{33.29,10.03},{34.69,10.04},{34.88,10.92}}},
        },
        [66352] = { -- Traitor Gluk
            [npcKeys.spawns] = {[zoneIDs.FERALAS] = {{59.75,49.64}}},
        },
        [66400] = { -- Ship 1 Kill Credit
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.13,99.38}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [66401] = { -- Ship 2 Kill Credit
            [npcKeys.spawns] = {[zoneIDs.PANDARIA] = {{65.31,74.96}}},
            [npcKeys.zoneID] = zoneIDs.PANDARIA,
        },
        [66412] = { -- Elena Flutterfly
            [npcKeys.spawns] = {[zoneIDs.MOONGLADE] = {{46.13,60.27}}},
        },
        [66436] = { -- Grazzle the Great
            [npcKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH] = {{53.85,74.88}}},
        },
        [66442] = { -- Zoltan
            [npcKeys.spawns] = {[zoneIDs.FELWOOD] = {{39.95,56.57}}},
        },
        [66449] = { -- Ang the Wise
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{68.5,17}}},
        },
        [66452] = { -- Kela Grimtotem
            [npcKeys.spawns] = {[zoneIDs.THOUSAND_NEEDLES] = {{31.88,32.94}}},
        },
        [66466] = { -- Stone Cold Trixxy
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{65.64,64.52}}},
        },
        [66478] = { -- David Kosse
            [npcKeys.spawns] = {[zoneIDs.THE_HINTERLANDS] = {{62.99,54.58}}},
        },
        [66512] = { -- Deiza Plaguehorn
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{66.96,52.42}}},
        },
        [66515] = { -- Kortas Darkhammer
            [npcKeys.spawns] = {[zoneIDs.SEARING_GORGE] = {{35.3,27.76}}},
        },
        [66518] = { -- Everessa
            [npcKeys.spawns] = {[zoneIDs.SWAMP_OF_SORROWS] = {{76.81,41.5}}},
        },
        [66520] = { -- Durin Darkhammer
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{25.54,47.5}}},
        },
        [66522] = { -- Lydia Accoste
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{40.05,76.46}}},
        },
        [66550] = { -- Nicki Tinytech
            [npcKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA] = {{64.31,49.3}}},
        },
        [66553] = { -- Morulu The Elder
            [npcKeys.spawns] = {[zoneIDs.SHATTRATH_CITY] = {{58.76,70.05}}},
        },
        [66555] = { -- Alliance Barricade
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{34.72,9.95}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [66556] = { -- Alliance Barricade
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{34.93,10.63}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [66574] = { -- Mishka
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{46.13,84.57}}},
        },
        [66581] = { -- Rell Nightwind
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{41.46,79.15}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [66741] = { -- Aki the Chosen - Remove with Patch 5.4
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{67.5,40.6}}},
        },
        [66776] = { -- Malik the Unscathed
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{40.4,34.56}}},
        },
        [66800] = { -- Kil'ruk the Wind-Reaver
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{54.01,34.51,phases.KILRUK_REVEALED}}},
            [npcKeys.questEnds] = {31612}, -- This is only possible for a short moment, the NPC will despawn quite fast
        },
        [66949] = { -- Rell Nightwind
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{58.93,81.93}}},
        },
        [67067] = { -- Rell's Gyrocopter
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{41.51,79.75}}},
        },
        [67091] = { -- Rik'kal the Dissector
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{31.8,89,phases.RIKKAL_AT_ZANVESS}}},
        },
        [67099] = { -- Succula
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{51.44,26.76}}},
        },
        [67125] = { -- Thundergill
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{55.95,25.38}}},
        },
        [67128] = { -- Kracor
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{56.06,33.83}}},
        },
        [67138] = { -- Chen Stormstout
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {
                {54.11,20.48,phases.CHEN_AT_FEAR_CLUTCH},
                {44.41,16.8,phases.CHEN_AT_BREWGARDEN},
            }},
        },
        [68430] = { -- Arcanis Mechanica
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{86.4,31.8}}},
        },
        [68558] = {
            [npcKeys.name] = "Gorespine",
            [npcKeys.minLevel] = 25,
            [npcKeys.maxLevel] = 25,
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{26.2,50.2}}},
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [68561] = {
            [npcKeys.name] = "Lucky Yi",
            [npcKeys.minLevel] = 25,
            [npcKeys.maxLevel] = 25,
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{40.4,43.8}}},
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [68564] = {
            [npcKeys.name] = "Dos-Ryga",
            [npcKeys.minLevel] = 25,
            [npcKeys.maxLevel] = 25,
            [npcKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
            [npcKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{67.8,84.6}}},
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [68565] = {
            [npcKeys.name] = "Nitun",
            [npcKeys.minLevel] = 25,
            [npcKeys.maxLevel] = 25,
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{57,29.2}}},
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [69161] = { -- Oondasta
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{49.9,54},{50.6,54.4}}},
        },
        [69359] = { -- Beeble Sockwrench
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{41.8,79.2}}},
        },
        [69360] = { -- Bozzle Blastinfuse
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{51.8,75.4},{51.8,75.6}}},
        },
        [69925] = { -- Zandalari Dinomancer
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{38.8,70.6},{39,72.2},{39.2,73.2},{41,70.8},{46.4,54.8},{46.6,54.4},{47.2,55.2},{47.4,56},{47.4,57.4},{47.4,57.6},{47.6,57.4},{47.6,57.6},{48.8,57.8},{49.4,52.2},{49.4,52.8},{49.6,52.4},{49.6,53.2},{50.6,52.2},{50.6,52.6},{52.2,52.8},{52.4,52},{52.4,53.6},{52.6,53.4},{52.6,53.6},{53,55.8},{53.2,55.2},{53.6,56},{64.4,65.6},{64.8,64.4},{65,64.6},{65,65.8},{65,76.4},{65.6,75.2},{65.6,76},{67,53.8},{67,75.4},{67,76.2},{67.2,37.4},{67.2,37.6},{67.2,39},{67.2,53.4},{67.6,76},{67.8,38.2},{67.8,38.6},{67.8,39.6},{68,40.6},{68.2,53.4},{68.4,71},{68.6,41.8},{68.8,41},{69.2,69.4},{69.2,70.6},{69.4,70.2},{69.6,69},{69.6,70.4},{69.8,71.4},{69.8,71.6},{75.4,76},{75.8,77.6},{76.2,77.2},{77.2,81.2},{77.4,82.8},{77.8,79.6},{77.8,83.2},{78,79.4},{78,81.6},{78,85},{78.2,80.8},{78.6,80.2},{78.6,82},{78.6,82.8},{79.2,79},{79.4,78.4},{79.8,77.4},{79.8,80.2},{80.4,77.6}}},
        },
        [69983] = { -- Primal Direhorn
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{32.4,74.4},{33.2,75.2},{33.4,75.6},{33.4,76.8},{33.4,79.6},{33.6,76.8},{34,75.4},{34.2,76},{34.4,67},{34.6,66.8},{34.6,72.8},{34.6,75.8},{34.8,66.4},{35,67.8},{35,75.4},{35,77},{35.2,74.2},{35.8,68},{36,76.8},{36.2,75.8},{36.4,72.8},{36.4,73.6},{36.4,74.6},{36.6,72.4},{36.6,72.6},{37,73.8},{37.8,72.2}}},
        },
        [69991] = { -- Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{70,54},{70,54.6},{70.2,53.4},{70.4,51.4},{70.4,52},{70.6,52.2},{70.6,53.4},{70.6,54.2},{71,51.4},{71.6,52.8},{71.8,50.4},{71.8,51.2},{72,52},{72.2,54.2},{72.6,53.6},{73,53.4}}},
        },
        [69992] = { -- Primal Direhorn Hatchling
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{32.6,78.4},{33.2,79.6},{33.4,79.2},{33.6,79.6},{33.8,78.6},{34,77},{34.4,78},{34.8,77.4},{34.8,78.2},{34.8,78.6},{35,68.2},{35.2,75.2},{35.4,69.2},{35.4,69.6},{35.4,75.6},{35.6,78.6},{35.8,68.4},{35.8,78.2},{36,68.6},{36,76.8},{36.2,75.4},{36.4,70},{36.4,76},{36.6,69.4},{36.6,69.6},{36.6,75.8},{36.8,75},{36.8,76.6}}},
        },
        [69993] = { -- Young Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{22.4,59.4},{22.4,60},{22.8,59.6},{22.8,60.6},{23,62.2},{23,62.6},{23.2,59.4},{23.4,57.2},{23.8,61.6},{24,58.8},{24,61.2},{24.4,58.4},{24.4,59.8},{24.8,58.4},{25,57},{25,59}}},
        },
        [70004] = { -- Young Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{69.2,54.8},{70,54.4},{70,54.8},{70,55.6},{70.4,49.4},{70.4,53.4},{70.6,53.2},{70.6,54.4},{70.6,55.8},{71,48.6},{71,51.4},{71.2,47.6},{71.2,54.6},{71.4,50.2},{71.4,52},{71.6,49.6},{71.6,53.6},{71.8,47.4},{71.8,48.6},{71.8,52.4},{71.8,53},{72,48},{72,51.2},{72.6,48.4},{72.6,54},{73.2,50},{73.4,49.4},{74,49.4},{74,50.6},{74.2,49.6},{74.6,49.8}}},
        },
        [70005] = { -- Young Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{42.4,49.4},{42.4,49.8},{42.6,48.4},{42.8,49.8},{43,50.8},{43.2,49.2},{43.4,51.6},{43.4,52.8},{43.6,48.8},{43.8,49.8},{44.4,47},{45.2,47},{45.4,45.4},{45.4,46.4},{45.4,47.6},{45.6,45.4},{45.6,45.6},{45.8,46.6},{45.8,48.2},{46.4,49},{46.4,52},{46.8,52},{47,50.6},{47.2,47.4},{47.2,49.2},{47.2,49.6},{47.4,45.4},{47.6,49},{47.6,49.6},{47.8,44.4},{47.8,48.4},{47.8,50.6},{48,46.6},{48.4,45.4},{48.4,45.8},{48.6,45.8},{48.8,45},{49,50.8},{50.4,45.4},{51,44.8},{51.2,48.4},{51.4,45.6},{51.8,45},{52.2,44.2},{52.2,50},{52.4,45.6},{52.4,46.6},{52.4,49.2},{52.4,50.8},{52.6,45.4},{52.6,45.6},{52.8,48.8},{53,47.4},{53,48.4},{53,49.6},{53.6,50.2},{53.8,48.4},{53.8,48.8},{54,55.6},{54.4,57},{54.4,58.2},{55.2,56.8},{55.4,56.2},{55.4,57.8},{55.4,58.6},{55.8,55.8},{55.8,57.2},{55.8,57.6},{56.2,55.2},{57,55.6},{57.2,54.4},{57.4,53.4},{57.4,54.8},{57.6,53.2},{57.6,54.2},{57.6,54.6},{57.8,55.6}}},
        },
        [70006] = { -- Young Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{32,57.4},{32,57.6},{32.2,59.6},{32.4,58.8},{32.6,58.2},{33.4,59.4},{33.4,60},{33.8,59.4},{33.8,60.2},{34.4,56.8},{34.4,57.6},{34.6,57.2},{34.6,59.8},{34.8,58.2},{35.2,56.4},{35.2,58.8},{35.6,59},{35.6,59.8},{37.2,60.4}}},
        },
        [70007] = { -- Young Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{72.4,64.4},{72.8,65},{73.2,62.6},{73.4,61.4},{73.4,62},{73.4,66},{73.4,67.4},{73.4,67.8},{73.6,63.8},{73.6,68},{73.8,65.4},{73.8,66},{73.8,68.6},{74,61},{74,62.6},{74.2,62.4}}},
        },
        [70008] = { -- Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{42.4,55.8},{43.4,53},{43.6,55.8},{44.4,49.8},{44.4,57.6},{44.8,50},{45.4,48.8},{49.4,45},{50,45},{50.2,45.8},{50.8,45.6},{51,45},{51.2,50},{51.8,45.2},{52.6,54.2},{54.2,47.8},{54.6,48.6},{55.6,50.4},{56.2,47.6},{56.2,53.6},{56.2,55.2},{56.4,52.8},{75,77.8},{75.4,78.6},{75.8,77.4},{76,77.6}}},
        },
        [70009] = { -- Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{34.4,59},{35.2,59.6},{35.4,58.4},{35.4,59.4},{35.6,59.2},{36.2,59.8},{37.2,60.4},{37.2,60.6},{38,60.4},{38,60.6},{38.6,60}}},
        },
        [70010] = { -- Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{71.2,63.4},{71.2,64.6},{71.4,64},{71.4,65.6},{71.6,63.4},{71.6,67},{72,63.6},{72.2,65.6},{72.4,64.6},{72.6,64.2},{72.6,64.8},{72.6,66.6},{72.8,63.2},{73.2,65.6},{73.8,64.6},{74,63}}},
        },
        [70011] = { -- Primal Devilsaur
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{22.4,58.8},{22.4,60},{22.4,61},{22.8,60.4},{22.8,61.6},{23.2,57.8},{23.2,59},{23.2,60.8},{23.4,56.6},{23.6,58},{23.6,59.2},{23.8,60.4},{23.8,60.8},{24.8,59}}},
        },
        [70012] = { -- Primal Direhorn Hatchling
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{53.8,70.6},{54.4,70.4},{55,69.4},{55.2,70.2},{55.2,71},{55.2,71.6},{55.6,70.4},{55.6,70.6},{59.4,71.4},{59.4,72},{60,70.8},{60.2,71.8},{60.6,70.6},{60.6,71.8},{61,75.2},{61.2,74.2},{61.8,73},{62.2,72.2},{62.2,74.6},{62.4,73.8},{62.6,74},{62.8,73.4},{62.8,75.2},{63.4,71},{63.4,72.2},{63.6,71.4},{64,72.2},{64.2,72.6},{64.6,72.2},{64.6,72.6}}},
        },
        [70013] = { -- Primal Direhorn Hatchling
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{42.4,74},{42.4,74.8},{43.2,74.6},{43.4,73.2},{43.4,74.4},{43.6,74},{43.6,74.6},{44,73.2},{44.2,75.8},{44.6,73.8},{46.2,73.2},{46.8,75.8},{47,74.8},{47.4,73.4},{47.4,74.2},{47.6,74.4},{47.6,74.6},{47.8,72.4},{47.8,73.4},{48.2,75.8},{48.4,71.4},{48.4,77.4},{49.2,71.2},{49.2,71.6},{49.4,70.4},{49.4,72.8},{49.6,71.4},{49.8,70.4},{49.8,71.6},{50,72.6},{50.6,71.6}}},
        },
        [70014] = { -- Primal Direhorn Hatchling
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{63,63.6},{63.2,64.8},{63.4,66.2},{63.6,64.2},{63.6,65.2},{63.8,66.2},{64,63.4},{64.2,66.6},{64.4,61.2},{64.4,61.6},{64.6,61.8},{64.6,63},{64.8,61.2},{66,55.4},{66.2,56.4},{66.2,58.4},{66.4,57},{66.4,58.6},{66.4,59.6},{66.4,60.6},{66.6,58.2},{66.6,59.2},{66.8,55.4},{66.8,56.2},{66.8,57.2},{66.8,59.8},{67.6,55.8}}},
        },
        [70015] = { -- Primal Direhorn Hatchling
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{25.4,69.4},{25.4,70.8},{26,72.8},{26.2,69.4},{26.2,71.2},{26.2,71.6},{26.4,68.4},{26.4,69.6},{26.6,68},{26.6,70},{26.6,72.2},{26.6,72.8},{26.8,68.6},{26.8,71},{26.8,74},{28.4,69.6},{28.4,70.6},{28.6,68.4},{29,69.4},{29,71},{29.2,70.2},{29.4,71.6},{29.6,71},{29.6,71.6},{30,70.4},{30.2,68.8},{30.6,73.2}}},
        },
        [70016] = { -- Primal Direhorn
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{52.6,69.4},{53.2,73.2},{56.4,71.2},{56.4,71.6},{56.4,74},{56.6,71.6},{57,73},{57.2,73.6},{57.4,71.4},{57.6,73.6},{57.8,73.2},{58,71.2}}},
        },
        [70017] = { -- Primal Direhorn
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{44.4,72.4},{44.4,73},{44.4,74.2},{44.6,73.2},{45.2,72.4},{45.8,72},{46,72.8},{47.2,72.6},{47.4,72},{47.4,74},{47.6,72.6},{47.8,71.4},{47.8,72},{48.8,72.2}}},
        },
        [70018] = { -- Primal Direhorn
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{62,63.4},{62,67.2},{62.2,66.4},{62.6,63.2},{62.6,63.6},{62.8,66.2},{62.8,66.6},{63,65.2},{63.6,66.2},{63.8,65.2},{64.4,64},{64.6,64.2}}},
        },
        [70019] = { -- Primal Direhorn
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{26,68.4},{26.8,68.2},{27.2,67.2},{27.2,68.6},{27.6,68.4},{28,69},{29.2,70.6},{30.2,68.4},{30.4,69.2},{30.4,69.6},{30.6,69.2},{30.6,69.6},{31.2,67.6}}},
        },
        [70020] = { -- Pterrorwing Skyscreamer
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{25.4,49.2},{25.4,50},{25.6,49.2},{26,50.4},{27.4,49.2},{32.4,50},{32.8,49.8},{33.2,49.2},{52.4,64.2},{52.6,64.2},{52.6,64.6},{53.4,63.4},{53.6,62.6},{53.6,63.8},{68.4,39.6},{70.2,39.8},{71.6,31.2}}},
        },
        [70021] = { -- Pterrorwing Skyscreamer
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{30,54.2},{30,55.4},{30.4,49},{30.4,60.2},{30.8,48.8},{30.8,52.8},{30.8,53.6},{30.8,64.2},{31,58.4},{31.2,52.2},{31.2,66.8},{31.6,52},{31.8,52.6},{32.2,50},{32.2,50.8},{32.4,49.4},{32.6,49.4},{33.2,50.2},{34,73.4},{34.4,50.8},{38.6,56.4},{38.8,52},{41.2,62},{41.4,63},{41.8,62.4},{42.4,63.4},{42.4,63.6},{42.8,63.6},{43,61},{43.4,63.4},{43.6,63.4},{44.4,63.6},{44.4,65},{44.8,61.4},{44.8,64},{45,61.8},{46.8,56.8},{47,68.6},{48.8,68.6},{50.2,62.8},{50.4,58.6},{50.4,64.2},{57.4,60.4},{61.8,55},{62,69.4},{62.8,54.8},{62.8,56.4},{63.8,67.8},{65.4,39.8},{66,38.2},{66.6,39.8},{67.2,37.8},{68.2,44.6}}},
        },
        [70022] = { -- Ku'ma
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{32.4,54.4},{32.4,54.6},{32.6,54.4},{32.6,54.6},{33,53.4}}},
        },
        [70030] = { -- Agrant Sharpshot
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{35.4,53.2},{35.4,53.6},{35.6,53.4},{35.8,53.6}}},
        },
        [70031] = { -- Nellie Sattler
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{36.2,52.4},{36.2,52.8}}},
        },
        [70032] = { -- Dr. Ion Goldbloom
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{60.4,44.2},{60.4,44.6},{60.6,44.6},{60.8,44.2}}},
        },
        [70033] = { -- Nedris Smuggler
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{60.4,44.4},{60.4,44.6},{60.6,44.4},{60.6,44.6}}},
        },
        [70034] = { -- Arnold Raygun
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{60.4,44},{60.6,43.4},{60.6,44}}},
        },
        [70035] = { -- Atten Hamlock
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{36.6,51.6},{36.8,51.4}}},
        },
        [70059] = { -- Stunted Direhorn
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {
                [zoneIDs.ISLE_OF_GIANTS] = {{67,75.2},{69.6,71.4},{69.8,71.6}}},
                [zoneIDs.ISLE_OF_THUNDER] = {{50.4,42.8},{50.8,43.4},{51,43.6}},
        },
        [70414] = { -- Skumblade Pillager
            [npcKeys.name] = "Skumblade Pillager",
            -- [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{}}}, Unknown location, not part of quest causing error
            -- [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [70434] = { -- Talak
            [npcKeys.zoneID] = zoneIDs.ISLE_OF_GIANTS,
            [npcKeys.spawns] = {[zoneIDs.ISLE_OF_GIANTS] = {{28.8,67.4},{29,67.8}}},
        },
        [71143] = { -- Windfeather Chick
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{26.4,52.4},{26.6,52.2},{28.4,50.4},{29.4,52.4},{29.4,52.6},{29.4,60.4},{29.4,67.2},{29.6,52.4},{29.6,52.6},{29.6,60.4},{29.6,67.2},{29.8,34.8},{29.8,60.6},{30,34.2},{30.4,39.2},{30.4,66.2},{30.6,38.8},{30.6,41.4},{30.6,41.6},{30.6,62.2},{31.2,50},{31.4,49},{31.4,64.8},{31.4,78.4},{31.4,78.8},{31.6,50.2},{31.6,51.2},{31.6,60},{31.6,64.8},{31.6,78.8},{31.6,79.8},{32,52},{32,61.4},{32.4,52.8},{32.4,70.6},{32.6,52.4},{32.6,52.8},{32.8,69.2},{33,65.8},{33.2,51.4},{33.2,80.2},{33.6,51.8},{33.6,66.4},{33.6,66.6},{33.6,79.6},{34,81.4},{34,81.6},{34.8,82.2},{35.4,38.2},{35.4,38.8},{35.8,38.2},{35.8,38.8},{35.8,82.6},{36,82.2},{36.4,81},{36.6,83.4},{37.4,38.8},{37.6,39},{39,38},{39,41.2},{39.2,44.8},{39.4,44},{39.6,41.6},{40,41},{40.4,81.4},{40.6,80},{40.8,81.2},{41.2,69.4},{41.2,69.6},{41.6,81.2},{41.8,80.2},{42.2,69.8},{42.4,44.8},{42.4,65.4},{42.4,68.6},{42.6,44.4},{42.6,44.8},{42.6,67.2},{43,68},{43,68.6},{43,69.6},{43.2,66.2},{43.6,67.4},{44.2,61.4},{44.2,61.6},{44.4,55.4},{44.4,55.6},{44.4,65.4},{44.6,54.8},{44.8,53.4},{44.8,53.6},{44.8,62.2},{44.8,62.6},{45,56.2},{45.2,52.4},{45.2,56.8}}},
        },
        [71920] = { -- Cursed Hozen Swabby
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{38,90.8},{38.4,93.2},{39,93.2},{39.2,91.4},{39.2,91.6},{39.8,93.6},{40,93}}},
        },
        [71986] = { -- Cove Shark
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{16.4,57},{16.4,57.8},{16.4,60.2},{16.8,57.4},{17,56.4},{17,58.6},{17,60.6},{17.2,53},{17.2,58.2},{17.4,60.4},{17.6,52.8},{17.6,57},{17.6,58},{17.6,60.2},{18.4,59},{18.4,63.2},{18.6,54.6},{18.6,62},{18.8,55.6},{19.2,52.2},{19.2,58},{19.4,53},{19.4,53.6},{19.4,58.8},{19.4,60.2},{19.6,52.4},{19.6,53.2},{19.6,53.6},{19.6,60.4},{19.8,55.4},{19.8,59},{19.8,61.6},{19.8,65.6},{20,64.8},{20.2,56.8},{20.2,61.4},{20.2,63.8},{20.4,56.4},{20.6,56.6},{20.6,64.4},{20.8,56.2},{20.8,58.6},{21,60.2},{21.2,58.4},{21.4,65.6},{21.6,58.4},{21.6,59.4},{38.2,91.4},{38.2,92.2},{38.6,90.8},{38.6,92},{38.6,94.4},{39,92.8},{39.6,94},{39.8,92},{40.4,92.6},{41,88.8},{41.2,92.8},{41.8,89.4},{44.6,88.6}}},
        },
        [72095] = { -- Fishgorged Crane
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{43.8,69.4},{43.8,69.6},{43.8,83},{44,83.8},{44.8,85.2},{45.2,83.8},{46,85},{46.2,85.6},{46.6,84.6}}},
        },
        [72761] = { -- Windfeather Nestkeeper
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{26.6,52.2},{28.4,50.4},{29.4,52.4},{29.4,67},{29.6,52.4},{29.6,60.4},{29.6,67.2},{30.2,33.2},{30.2,61.2},{30.4,39.2},{30.4,66.2},{30.6,38.8},{30.6,41.4},{30.6,41.6},{30.6,60.6},{30.6,62.2},{30.8,43.8},{31.2,50},{31.4,49},{31.4,65},{31.4,78.8},{31.6,63.4},{31.6,64.8},{31.6,78.6},{32.4,52.4},{32.8,52.4},{32.8,52.8},{32.8,69},{33,65.8},{33.2,80.4},{33.8,66.6},{34,81.4},{34,81.6},{35.6,38.8},{35.8,38.4},{36,82.2},{36.6,83.8},{37.4,38.8},{37.6,39},{39.2,44.8},{39.4,44.4},{39.6,41.6},{40,41},{40.6,81.6},{40.8,80.4},{41.2,69.6},{41.4,69},{41.6,68.8},{41.6,81.4},{42,69.8},{42.4,44.8},{42.6,44.4},{42.6,44.8},{43,66.6},{43,68},{43.2,68.6},{43.4,66.2},{43.8,69.8},{44,65.2},{44.2,61.6},{44.4,65.8},{44.6,55.4},{44.6,62.2},{44.8,53.6},{44.8,55.8},{44.8,62.6},{45,53},{45.2,52.4}}},
        },
        [72766] = { -- Ancient Spineclaw
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{15.6,36.8},{17.6,53},{18,75.2},{18.2,54.6},{18.2,58},{18.2,58.6},{18.2,63},{18.8,54.4},{20.2,47.2},{20.4,47.6},{20.6,47.4},{20.6,47.6},{20.8,71.6},{21,63.4},{21,71},{21.2,32.4},{21.2,32.6},{21.2,63.6},{21.4,35.4},{21.4,35.6},{21.6,32.4},{21.6,32.6},{21.6,35.4},{22,35.6},{22.4,30.4},{22.4,30.8},{22.6,30.2},{22.6,30.8},{22.6,35.2},{22.8,35.6},{23.4,27.4},{23.4,28.2},{23.4,28.6},{23.6,28.4},{23.6,28.6},{23.8,34.8},{23.8,35.6},{24.4,74.8},{25.4,74.4},{25.4,74.6},{25.6,74.4},{25.6,74.6},{27.4,74.2},{27.4,74.6},{27.6,74.2},{27.6,80},{27.8,74.6},{29.2,84},{30.4,30.8},{30.6,30.4},{30.6,31},{30.8,31.6},{32.8,85.4},{38.4,87.2},{40.6,90.8},{41,90},{44.8,90.4},{52,86.8},{61.8,83},{62.2,82.4},{62.6,81.8},{66,78.4},{68,77.8},{68.6,74.2},{70.2,70.4}}},
        },
        [72775] = { -- Bufo
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{62,76.4},{62.2,76.8},{63.4,73},{63.6,72.4},{63.6,72.6},{64.8,74.2},{64.8,74.6},{65.2,69.2},{65.2,69.6},{65.6,69.8},{66.4,67.2},{66.8,65.4},{66.8,65.8},{66.8,66.6}}},
        },
        [72777] = { -- Gulp Frog
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{60.8,71.4},{61,72.2},{61.4,72.6},{61.4,74.4},{61.4,74.6},{61.6,72.4},{61.6,74.4},{61.6,74.6},{62.2,75.8},{62.2,77.2},{62.2,77.6},{62.4,73.4},{62.6,74.2},{62.6,77.6},{63,72.4},{63,72.8},{63,80.8},{63.2,76.6},{63.4,75.4},{63.4,75.6},{63.6,75.2},{63.6,77.6},{63.8,77},{64,72.2},{64,72.6},{64,76.2},{64.2,73.8},{65,71},{65,73.6},{65.2,64.4},{65.2,64.6},{65.2,67.4},{65.2,67.8},{65.2,71.6},{65.2,73.2},{65.2,78.2},{65.4,66.4},{65.4,68.6},{65.4,70.4},{65.6,66.4},{65.6,74},{65.8,68.8},{66,67.2},{66,69.8},{66,72.2},{66,72.6},{66.4,64.4},{66.4,64.6},{66.4,68},{66.4,71.4},{66.6,65},{66.6,67.8},{66.6,68.6},{66.6,76.4},{66.8,66.2},{66.8,70},{67,66.6},{67,71.4},{67.4,71.6},{67.8,70.2},{67.8,70.8},{70.2,70.4}}},
        },
        [72805] = { -- Primal Stalker
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{49,58.8},{49.4,58.4},{49.6,58.4},{49.6,58.6},{50.4,56.2},{50.4,56.6},{50.6,56},{52.2,61.6},{52.4,61.2},{52.4,63.4},{52.4,63.8},{52.6,61.4},{52.6,63.8},{52.8,63.4},{55.4,45},{55.6,45},{56,44.4},{57.4,47.2},{57.4,47.6},{57.6,47.6},{57.8,46.8},{59.8,66.2},{59.8,66.8},{61.2,52.6},{61.4,52.4},{61.6,52.6},{62.4,52.4},{62.6,52.6},{62.8,52.2},{63.4,57.6},{63.4,59.2},{63.4,59.6},{63.6,57.8},{63.6,59.2},{63.6,59.6},{63.8,57.4},{64.4,54.6},{64.6,54.4},{64.8,54.8}}},
        },
        [72807] = { -- Crag Stalker
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{47.8,63.8},{48.4,46.8},{48.6,46.4},{48.6,63.2},{48.6,63.6},{48.8,59},{48.8,62.4},{49,52.4},{49,52.8},{49,64.6},{49.2,47},{49.2,49.2},{49.2,49.6},{49.2,60},{49.4,47.6},{49.4,54.2},{49.4,58.2},{49.4,60.6},{49.6,47},{49.6,49.8},{49.6,52.4},{49.6,58.4},{49.6,60.2},{49.6,70.6},{49.8,49.2},{49.8,60.6},{49.8,65.4},{49.8,65.6},{49.8,70.2},{50,51.2},{50.2,53.2},{50.2,55.2},{50.2,66.8},{50.4,53.6},{50.4,56.2},{50.4,56.6},{50.4,63.6},{50.6,53.4},{50.6,56.4},{50.6,66},{50.6,66.6},{50.8,53.6},{50.8,63.4},{51,60.4},{51,61.4},{51,61.6},{51.2,57.2},{51.2,57.8},{51.2,63.8},{51.4,55},{51.4,58.6},{51.6,54.6},{51.6,63.2},{51.6,63.6},{51.8,53.4},{51.8,54.2},{52,58.6},{52,67.6},{52.2,57.4},{52.2,57.8},{52.2,71},{52.4,66.4},{52.4,66.8},{52.4,70.2},{52.6,66.8},{52.8,58.2},{52.8,60.4},{52.8,60.6},{52.8,66},{53,46},{53,70.2},{53,70.6},{53.2,54.8},{53.6,69.8},{54.2,43},{54.2,69.2},{54.4,43.8},{54.4,45.4},{54.4,45.6},{54.4,55.8},{54.4,68.4},{54.6,44.4},{54.6,56.6},{54.6,68.4},{54.6,69.2},{54.8,55.4},{54.8,55.6},{55,45.6},{55.2,45.4},{55.6,44.4},{55.6,45.6},{56.2,44.6},{56.4,65.4},{56.4,65.6},{56.6,44.4},{56.6,44.6},{56.8,55},{57,45.6},{57,65.4},{57,65.6},{57.2,46.6},{57.4,48.4},{57.4,48.8},{57.4,50.4},{57.4,51},{57.4,51.6},{57.4,54.4},{57.8,48.4},{57.8,48.6},{58,46.4},{58,46.6},{58,50.4},{58,51.6},{58,54.4},{58.2,43.8},{58.2,50.8},{58.4,54.8},{58.4,69.4},{58.4,70},{58.6,69.4},{58.8,51.4},{58.8,51.6},{58.8,69.8},{59,40.4},{59,40.6},{59.2,48.8},{59.2,65.6},{59.2,67.6},{59.4,67.2},{59.6,67.4},{59.8,67.6},{60.2,55.2},{60.2,57},{60.2,64.4},{60.2,65},{60.2,66.2},{60.2,68.6},{60.4,52},{60.4,52.6},{60.4,55.6},{60.6,52.4},{60.8,52.6},{60.8,55.4},{60.8,55.8},{61,57},{62,52.8},{62.2,52.4},{62.6,52.8},{63,59.6},{63.2,58.8},{63.4,58.2},{63.6,59},{63.8,54.4},{64,50.8},{64,54.8},{64,60.4},{64,60.8},{64.2,61.6},{64.4,55.8},{64.6,55.4},{64.6,55.8},{65,50.4},{65,50.6}}},
        },
        [72809] = { -- Eroded Cliffdweller
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{52.2,57},{52.4,56.2},{52.6,56.8},{52.8,55.6},{53.4,55},{53.6,55},{54.4,54.4},{54.8,54.6},{55.2,54.2},{55.2,67},{55.2,67.6},{55.6,53.6},{55.6,67.8},{55.8,53.4},{56,67.2},{56.2,45.6},{56.4,47.2},{56.4,48.2},{56.4,48.8},{56.4,49.8},{56.4,51},{56.4,51.6},{56.6,46.8},{56.6,48},{56.6,50.8},{56.6,53.4},{56.8,48.6},{56.8,50.4},{56.8,51.8},{56.8,67.8},{57.2,67},{57.8,66.6},{57.8,68.4},{58.2,66.4},{58.6,65.8},{59.2,53.4},{59.2,64.4},{59.4,64.6},{59.6,53.2},{59.6,64.6},{60.2,53.8},{60.2,63.2},{60.2,64.2},{60.8,63.4},{60.8,63.6},{61.2,54.6},{61.4,54.4},{61.6,54.4},{62,55.2},{62.2,57.2},{62.2,59.2},{62.4,56.2},{62.4,58.2},{62.4,59.6},{62.4,60.6},{62.6,55.4},{62.6,56},{62.6,57.4},{62.6,57.6},{62.6,59},{62.6,60.4},{62.8,61},{63,61.8},{63,62.8},{63.6,62.4},{64,63},{65.2,58}}},
        },
        [72875] = { -- Ordon Candlekeeper
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{47.4,78.4},{47.4,78.6},{47.6,78.6},{48,77.2},{48,78.4},{50,81.4},{50.2,82.2},{50.4,82.6},{50.6,82.4},{50.6,82.8},{51,76.6},{51.4,83.8},{51.6,83.4},{51.6,83.8},{52.2,75.6},{52.2,82.2},{52.4,75.4},{53,80.6},{53.2,78.2},{53.2,78.8},{53.2,80},{53.8,76.4},{53.8,79.6},{54.2,73.4},{54.2,73.8},{54.2,79.4},{54.4,83.8},{54.6,79.2},{54.6,80},{54.6,84.2},{55,82.4},{55.2,82.6},{55.4,78},{55.6,78},{55.6,79.4},{56.2,80.4},{56.4,80.6},{56.4,84},{56.6,75.2},{56.6,80.6},{56.6,84},{56.8,75.8},{56.8,79.4},{56.8,80},{58,81.2},{58.4,76},{58.4,78.4},{58.4,78.6},{58.6,76.2}}},
        },
        [72876] = { -- Crimsonscale Firestorm
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{55.4,61.6},{56.4,61.2},{57,61.8},{57.2,61},{57.6,60},{57.6,60.6},{57.8,58.8},{58.2,56.8},{58.4,56.4},{58.6,56.2},{62,57.4},{62.2,45.4},{62.8,33.6},{62.8,44.2},{63,33.4},{63.8,44.6},{64,34.8},{65.4,57},{65.6,35},{65.8,40.4},{66,44},{66,57},{66.6,44.2},{66.8,56.6},{67.4,45.2},{67.4,56.4},{68,55.4},{68.2,37.2},{68.4,43.6},{68.4,46.8},{68.4,58.4},{68.8,53.8},{69,47.6},{69.2,48.6},{69.8,59.8},{70.4,59.4},{71.2,50.6},{71.2,52.8},{71.4,55.4},{71.6,38},{71.8,40.4},{71.8,58.4},{72,39.4},{72,54.6},{72.4,50},{72.4,56.2},{72.6,38.8},{72.6,42.6},{72.6,50.8},{72.8,38},{72.8,40.2},{72.8,42},{72.8,49.6},{72.8,54.6},{74,44.2},{75.2,44.8}}},
        },
        [72877] = { -- Ashleaf Sprite
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{63,41.2},{63.4,41.6},{63.6,42},{63.8,36},{65.2,40.2},{65.8,57.4},{65.8,58},{65.8,58.6},{66.2,38.8},{66.4,38.2},{66.4,44},{66.6,39.2},{67.2,44},{67.4,43.4},{67.6,43.4},{67.6,44},{67.6,44.6},{68.4,52.6},{68.8,51.2},{68.8,52.6},{69,52.4},{69.6,52.2},{69.8,55.8},{70.2,41.6},{70.2,55},{70.2,57},{70.4,40.8},{70.6,42},{70.6,56.8},{71,55.4},{71.2,41.4},{72,41},{73.6,47.2},{74.4,47.8}}},
        },
        [72892] = { -- Ordon Oathguard
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{48.8,78.6},{49.4,78.4},{50.4,78.2},{50.8,76.8},{51.4,83.8},{51.6,83.8},{51.8,77.6},{52.2,75.4},{52.2,75.6},{52.4,82.2},{53.8,75.6},{54,75.2},{54.2,73.4},{54.2,73.8},{54.4,80.4},{54.4,80.6},{54.6,80.4},{55,73.4},{55,73.8},{56,73.8},{56.2,82.6},{56.4,73.4},{56.4,82.4},{56.4,84},{56.6,82.2},{56.6,84},{56.8,75.4},{57,73.6},{57.4,72.4},{57.4,72.6},{57.4,81},{57.6,72.2},{58,77.4},{58,77.6},{58,81.2},{58.2,76},{58.4,78.8},{58.6,71.2},{59.4,81.4},{59.4,82.2},{59.6,81.4},{59.6,81.6}}},
        },
        [72894] = { -- Ordon Fire-Watcher
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{51,76.4},{51,76.6},{51.4,83.4},{51.4,83.8},{51.6,83.6},{52.2,75.4},{52.2,75.6},{52.4,80},{52.4,80.8},{52.4,82},{52.4,83.4},{52.6,75.4},{52.6,75.6},{52.6,80.4},{52.6,80.6},{52.6,83.4},{52.8,83.8},{53.2,82.4},{53.8,76.4},{53.8,79},{53.8,79.6},{54,82.8},{54.2,73.4},{54.2,73.6},{54.2,76.6},{54.2,78.4},{54.6,73.4},{54.6,77.8},{54.6,78.6},{54.6,83},{55.8,79.4},{55.8,79.6},{55.8,81.6},{56.2,78.2},{56.2,80.6},{56.4,75.4},{56.4,83},{56.6,75.2},{56.6,78.2},{56.6,79.2},{56.8,83},{57,82.4},{57.4,77.4},{57.6,77.4},{57.8,77.6},{57.8,81.2},{58.4,76},{58.4,78.8},{58.6,79},{59.2,76},{59.6,75.8}}},
        },
        [72895] = { -- Burning Berserker
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{58.2,71.6},{58.4,71.4},{59,70.8},{59.4,70.4},{59.6,52.6},{59.8,51.6},{60,50.4},{60,51.2},{60,69.8},{60.4,46.8},{60.4,47.6},{60.4,49.2},{60.4,69.4},{60.6,48.6},{60.8,47},{61,46.4},{61,68.8},{61.2,47.6},{61.4,68.4},{61.6,68.2},{62.2,67.4},{62.6,66.8},{63,66.2},{63.4,39.2},{63.4,39.6},{63.4,65.2},{63.6,64.8},{63.8,39.4},{63.8,39.6},{64,44.8},{64,63.8},{64.4,62.4},{64.4,62.8},{64.6,62.6},{64.8,61.8},{65.2,60.8},{65.4,39.4},{65.4,40.4},{65.4,40.6},{65.4,60.4},{65.6,40.4},{65.6,40.8},{65.6,60},{66.4,36.4},{66.4,36.6},{66.6,36.4},{66.6,36.6},{67.2,34.6},{67.4,34.2},{67.4,54.4},{67.4,55},{67.4,55.6},{67.6,54.4},{67.6,55.2},{67.8,34.6},{67.8,55.6},{68,32.6},{68.2,32.2},{68.2,34.2},{68.2,40.4},{68.4,39.2},{68.4,40.8},{68.6,32.4},{68.6,40},{68.6,40.6},{69,36.4},{69,37},{69,46.2},{69,46.6},{69,48.8},{69.2,34.6},{69.2,48.4},{69.4,33.4},{69.4,33.6},{69.4,58.2},{69.4,58.6},{69.6,32.8},{69.6,34},{69.6,58.2},{69.6,58.6},{69.8,35},{70,36},{71,58},{71.2,38.8},{71.2,43.6},{71.4,38.4},{71.4,43.4},{71.4,57.4},{71.6,43.4},{71.6,43.6},{72,41},{72.2,46},{72.2,46.8},{72.2,50.4},{72.2,51.2},{72.2,51.6},{72.2,54.6},{72.4,41.8},{72.4,53.4},{72.4,53.8},{72.6,46.8},{72.6,50.8},{72.6,53.4},{72.6,54},{72.8,41.2},{72.8,41.6},{72.8,45.6},{73.4,49.4},{73.4,49.6},{73.6,49.4},{73.6,49.8},{74,51.2}}},
        },
        [72896] = { -- Eternal Kilnmaster
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{33.4,34},{34.2,29.4},{34.2,35.4},{34.4,29.6},{34.4,36.4},{34.6,29.4},{35,35.4},{35.4,35.6},{35.8,35.4},{36,31.4},{36.6,31.2},{40.4,25.4},{40.6,30.8},{40.8,25.2},{40.8,25.6},{41.4,28.4},{41.4,28.8},{42.4,31.2},{42.4,31.6},{42.6,31.4},{42.6,31.6},{43.4,33.8},{43.8,33.8},{44.2,31},{44.6,28.6},{44.8,28.4},{45.4,22.6},{45.6,22.6},{45.8,24.8},{47.2,36},{47.2,36.6},{47.4,23.2},{47.4,23.6},{48.8,38.4},{48.8,38.6},{49.6,25.4},{49.8,24.4},{50.4,31.4},{50.8,31.2},{50.8,31.6},{51.4,26.6},{51.6,26.4},{51.8,23.4},{51.8,23.6},{51.8,26.6},{53,30.4},{53.2,30.6},{55.2,33.4},{55.2,33.6},{55.4,24.4},{55.4,24.6},{55.4,27.6},{55.6,24.4},{55.6,24.6},{55.8,28},{56,38.2},{56,59.4},{56,59.6},{56.4,38.6},{56.4,62.4},{56.6,38.6},{56.6,62.4},{56.6,62.6},{57,33.4},{57,33.6},{57.2,61.4},{65.4,34.8},{65.8,34.4},{65.8,34.6},{67,33.4},{67,33.6},{67.2,36.2},{67.6,35.8},{68,35},{68.4,34.4},{68.6,35.2},{69,34.2},{69.8,35.4}}},
        },
        [72897] = { -- Blazebound Chanter
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{33.4,33.4},{33.4,33.8},{33.6,31.4},{35.2,32},{36.4,31.6},{36.6,31.4},{36.6,31.8},{39.8,26},{39.8,26.6},{43.4,26.4},{43.4,26.6},{43.4,33.8},{43.6,25.4},{43.6,26.6},{43.6,33.4},{43.6,33.8},{43.8,25.6},{44.2,30.8},{45.4,22.6},{45.6,22.6},{46,36.2},{46.4,29.8},{47,26.8},{47.4,23.4},{48.4,36.4},{48.4,36.6},{48.4,41.4},{48.4,41.6},{48.6,36.4},{48.6,36.6},{48.6,41.4},{48.6,41.6},{48.8,30.4},{48.8,30.6},{48.8,38.4},{49.4,27.4},{49.4,27.8},{49.6,27.2},{49.6,27.6},{50.8,31.2},{50.8,31.6},{51.4,26.4},{51.4,27},{51.6,26.4},{51.6,26.8},{53.2,30.4},{53.2,30.6},{54.4,60.8},{54.6,60.8},{54.8,60.4},{55.2,33.4},{55.2,33.8},{55.4,27.8},{55.6,27.8},{55.6,34},{57,31},{57,31.6},{57.4,28.2},{57.4,28.6},{57.8,61.2},{57.8,61.6},{65.4,35},{65.6,34.8},{65.8,34.4},{67.2,33.8},{67.2,36},{67.6,35.8},{67.8,34.8},{68.2,34.4},{68.6,35},{69,33.4},{69,34.2},{69.6,34.6}}},
        },
        [72908] = { -- Spotted Swarmer
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{30.8,71},{31.4,72.2},{32.4,74.6},{32.6,75.2},{33.8,78},{34.8,77.8},{37.4,69.4},{38.4,83},{38.6,83},{40.4,76.8},{40.4,80.8},{40.6,75},{40.6,78.8},{40.6,79.8},{40.6,81},{40.8,75.8},{41.8,75.6},{41.8,76.8},{42,72.4},{42.2,74.6},{42.6,75.4}}},
        },
        [72909] = { -- Gu'chi the Swarmbringer
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{30.2,71},{30.2,71.6},{30.2,72.8},{30.6,72.8},{31.2,70.2},{31.2,70.6},{31.4,74.4},{31.4,74.6},{31.6,74.2},{31.6,74.6},{31.8,70.6},{31.8,76},{32.2,77.4},{32.4,78},{32.6,70.8},{32.6,77.4},{33,70.4},{33.4,79.4},{33.6,70.8},{33.6,79.4},{34.4,70.2},{34.4,79.8},{35.2,70},{35.2,80},{35.4,69.4},{35.8,69.4},{36.2,69.6},{36.4,80.6},{36.8,69.4},{36.8,81},{37.2,70},{37.2,82.2},{37.8,69.4},{38,69.8},{38,82.2},{38.6,82.2},{39.4,69.8},{39.8,69.8},{40.2,82.8},{40.4,79.2},{40.4,79.8},{40.4,81.4},{40.4,81.6},{40.6,79.4},{40.6,79.6},{40.6,80.6},{40.6,81.6},{40.8,69.2},{40.8,70},{41.2,77.6},{41.4,71},{41.4,71.8},{41.4,72.6},{41.4,77.4},{41.6,71.4},{41.6,72.2},{41.6,78},{41.8,76.6},{42,73},{42.2,74},{42.2,76},{42.4,75},{42.6,75}}},
        },
        [73018] = { -- Spectral Brewmaster
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{34,85},{35.2,76.8},{35.2,79.2},{35.6,77.2},{35.6,79.2},{36,75.4},{36,75.8},{36.8,71.4},{36.8,71.8},{37.4,73.4},{37.4,74},{37.4,74.6},{37.4,80},{37.4,80.6},{37.6,73.4},{37.6,74},{37.6,74.6},{37.6,80.2},{37.6,80.8},{38.2,72.4},{38.4,76.4},{38.4,77},{38.4,79},{38.6,72.6},{38.6,76.8},{38.8,71.6},{38.8,76.2},{39.4,74.4},{39.4,74.6},{39.4,77.6},{39.6,74.6},{39.6,76.4},{39.6,77.4},{39.8,77.8},{40.4,74.2},{40.6,74.2},{40.8,74.8},{41.2,73.4}}},
        },
        [73021] = { -- Spectral Windwalker
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{35.4,77},{35.4,77.6},{35.6,77},{35.8,77.8},{36,75.4},{36,75.8},{36.2,80.2},{36.4,80.6},{36.8,80.4},{36.8,80.6},{37.4,73.4},{37.4,74},{37.4,74.6},{37.6,74},{39,72.2},{39,72.6},{39.4,74.4},{39.4,74.6},{39.4,79.4},{39.4,79.6},{39.6,73.8},{39.6,79.4},{39.6,79.6}}},
        },
        [73025] = { -- Spectral Mistweaver
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{34.4,83.8},{34.8,83.2},{34.8,83.6},{35,78},{35.4,77},{35.6,77.2},{36,75.4},{36.2,75.6},{36.6,75.6},{37.4,74},{37.6,74},{37.6,81},{38.6,72.6},{39.2,74.6},{39.2,79.4},{39.4,74.4},{39.6,79.4}}},
        },
        [73167] = { -- Huolon
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{57.4,57.8},{57.6,57.8},{57.8,58.8},{58,57.4},{65,57.2},{65.4,36.2},{65.6,57},{66,58.8},{66.4,59.8},{66.6,57.6},{67.2,57.4},{67.2,59},{68,58.8},{68.2,58.4},{68.6,58.4},{68.6,58.6},{72.4,54.4},{73,50.8},{73,53.6},{73.8,50.8},{74.2,41.6},{74.4,43.6}}},
        },
        [73171] = { -- Champion of the Black Flame
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{60.6,48.4},{61,46.6},{61.2,46.4},{61.4,45.4},{61.6,45.4},{61.6,45.6},{62.4,44.2},{63,43.6},{63.2,43.2},{64.2,41.2},{64.2,42.4},{64.2,42.8},{65.4,42.4},{65.4,42.6},{65.4,60.2},{65.6,42.4},{65.6,42.6},{66.4,58.4},{66.4,58.8},{66.6,58.6},{66.8,43},{67.2,57.4},{67.2,57.8},{67.4,42.4},{67.6,57.6},{67.8,41.8},{67.8,42.6},{68.2,44.2},{68.4,54.8},{68.4,56.8},{68.6,56.6},{68.8,43.2},{68.8,43.6},{68.8,56.2},{69,44.6},{69.2,58.4},{69.4,45.6},{69.4,54.4},{69.4,54.6},{69.6,44.4},{69.6,55},{69.8,43.4},{69.8,44.6},{69.8,54},{70.2,45.8},{70.2,52},{70.2,53},{70.4,49.2},{70.4,50.2},{70.4,50.8},{70.6,50.2},{70.6,51.4},{70.6,51.8},{70.8,47.6},{70.8,48.8},{71,44.8},{71,46.4},{71,47.2}}},
        },
        [73277] = { -- Leafmender
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{67.2,44},{67.6,44.2}}},
        },
        [73307] = { -- Speaker Gulan
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{75,44.8}}},
        },
        [73531] = { -- Highwind Albatross
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{25.4,44},{25.6,44.2},{25.6,58.6},{25.6,59.6},{25.6,60.6},{25.6,62.2},{25.8,58.2},{25.8,63.2},{26.2,57.2},{26.2,64.4},{26.4,65},{26.6,56.8},{26.6,65.2},{27,65.8},{27.4,56.2},{27.6,56},{28.2,67.6},{28.4,33.4},{28.4,34.2},{28.6,33.8},{28.6,55.6},{29.2,55.4},{29.4,32.6},{29.4,69.2},{29.6,69.4},{29.8,55.2},{29.8,69.6},{30.8,70.4},{31,70.6},{31.4,55},{31.6,55},{32,55.6},{32,71.4},{32.2,71.6},{32.8,72},{33.4,55.2},{33.4,55.6},{33.6,72.6},{33.8,29.8},{33.8,55.4},{34.2,29.4},{34.4,55.6},{34.8,56},{34.8,73.4},{35,73.6},{35.4,48.8},{35.4,56.6},{35.6,48.8},{35.6,56.4},{35.6,56.8},{35.6,74},{36.6,57.2},{37.2,56.2},{37.4,57.8},{37.4,75},{38.2,75.4},{39.4,76},{40.4,22.8},{40.4,76.2},{40.6,59.6},{40.6,76.2},{41.2,22},{41.4,59.4},{41.6,21.6},{42,76.4},{42.4,49},{42.4,58.6},{42.4,76.6},{43,76.6},{43.2,59},{44,76.6},{45.2,52.2},{45.4,76.6},{45.6,76.6},{46.4,49.2},{46.6,49.2},{46.6,76.6},{47,67.2},{47,76.4},{47.8,68},{47.8,76.4},{49,69},{49.4,76.4},{50.2,76.4},{50.4,16},{50.6,16},{50.6,56.6},{51.2,76.6},{51.6,76.6},{52.2,55.6},{52.2,65},{52.4,70.2},{52.6,55.4},{52.8,76.6},{53.4,76.4},{53.8,76.4},{55,75.6},{55.4,68.2},{55.4,75.4},{56,67.6},{56,75},{56.6,74.6},{56.8,66.6},{57.4,73.6},{57.6,73.6},{58.4,13.8},{58.6,13.8},{59.2,71.8},{59.8,62.6},{60.2,70.6},{60.4,13.8},{60.4,70.4},{60.6,54},{60.6,70.2},{60.8,57.8},{61,14},{61.2,55},{61.4,55.8},{61.4,69.2},{61.6,56.4},{61.6,69},{62.2,68.2},{62.6,23.4},{62.6,67.8},{62.8,24},{63.2,67},{63.4,25.2},{63.6,25.4},{63.6,66.6},{64.2,25.8},{64.2,65.8},{65,26.2},{65,64.8},{65.4,64.2},{65.6,26.4},{66.2,26.6},{66.2,63.2},{66.6,26.8},{66.6,62.8},{67.4,61.8},{67.6,27.4},{68.2,28},{68.4,60.4},{68.4,60.6},{68.6,28.4},{68.8,28.6},{69.2,59.6},{69.4,59.4},{69.6,29.4},{69.6,59.2},{69.8,29.6},{70.4,58.4},{70.6,30.4},{71.4,31.4},{71.4,31.6},{71.4,57.6},{71.6,31.6},{72,57.4},{72.2,57.6},{72.4,32.8},{72.6,33.2},{72.6,57.6},{72.8,57.4},{73.2,34.4},{73.2,34.6},{73.2,56},{73.4,54.8},{73.6,35.2},{73.6,35.6},{73.8,36.6},{73.8,47.4},{73.8,48.4},{73.8,48.6},{73.8,49.6},{73.8,51},{74,38},{74,39.2},{74,42.4},{74,43.4},{74,44.4},{74,44.8},{74,46.4}}},
        },
        [73542] = { -- Ashwing Moth
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{29,70.6},{29.6,68},{30.2,67.4},{30.4,65},{30.6,65},{30.6,73},{30.6,73.6},{31.4,70.8},{31.6,70.8},{32.4,64.4},{32.8,65},{35.4,67},{35.4,72.4},{35.4,72.6},{35.6,67.2},{35.6,72.8},{35.8,81.2},{36.2,69.4},{36.2,69.6},{36.2,80.2},{36.2,81.6},{36.6,69.6},{37.4,83.4},{37.8,83.6},{38,83.2},{38.6,38.2},{38.8,81.4},{39,37.4},{39,82.2},{39.2,73.8},{40.2,67},{40.6,67},{41,83.4},{41,83.6},{41.2,72},{41.4,42.8},{41.4,65.2},{41.6,42.8},{41.6,65.4},{41.6,72.4},{42.2,81.6},{42.4,70.4},{42.4,74.4},{42.4,75.2},{42.4,81.2},{42.6,74.6},{42.8,69.8},{42.8,82.2},{43,84.4},{43.2,84.6},{43.4,71.4},{43.4,72.2},{43.4,72.6},{43.6,72.4},{43.6,72.6},{44,55.4},{44.2,45.4},{44.2,45.8},{44.4,64},{44.4,75.2},{44.6,75},{44.8,43.8},{44.8,64.4},{45,82.8},{45.4,49.8},{45.4,58.4},{45.4,58.6},{45.6,50.2},{45.6,58.8},{46.4,44.8},{46.4,48},{46.4,72.4},{46.4,72.6},{46.6,72.4},{46.8,45.2},{46.8,46.2},{46.8,48.4},{47,46.6},{47,72.6},{47.2,48.6},{47.6,49.6},{47.8,48.6},{48.2,60.2},{48.2,61},{48.6,48.8},{48.6,60.8},{49.6,53.2},{50,53.8},{50,64.4},{50.6,68},{50.8,54.4},{51,68.6},{51.2,55.8},{52.2,60},{52.4,57.8},{52.8,55.2},{52.8,55.6},{52.8,57.8},{52.8,66},{53.2,68},{53.4,68.8},{54.4,55.4},{54.6,55.4},{55,67.6},{55.4,47},{55.4,53.8},{55.6,47.6},{55.6,68},{56,47.4},{56.2,51.4},{56.4,51.8},{56.6,47.2},{56.6,52},{56.6,54.2},{57.2,53.2},{57.6,53},{57.6,66.6},{58.4,52.2},{58.6,52.4},{59.2,71},{59.6,71.4},{59.8,55.2},{59.8,71.6},{60,54.4},{61,63},{61.2,62.2},{62.2,52.8},{62.4,56},{62.6,56.4},{62.8,52.8},{62.8,75.8},{63.2,73.4},{63.8,50.8},{64,50.4},{64.4,48},{64.6,47.4},{64.6,47.8},{64.6,63.2},{64.8,64.6},{65.2,64.2},{65.2,72.2},{65.8,67.6},{66.2,51.2},{66.2,51.6},{67,67.8}}},
        },
        [73543] = { -- Flamering Moth
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{51.6,82.2},{51.6,82.6},{52.6,79.4},{52.8,79.8},{54.2,75.6},{54.6,75.6},{54.8,58.4},{54.8,73.4},{55,58.6},{55,61},{55.2,73.6},{55.6,61.2},{55.8,59.8},{58.2,76.4},{58.2,80.2},{58.4,59.4},{58.4,59.6},{58.6,59.4},{58.6,59.6},{63.4,40.2},{64,40},{64.2,35.4},{64.6,35},{67.4,55.4},{67.6,55.8},{67.8,55.4},{68,33.2},{68.2,38.2},{68.2,44.6},{68.4,44.4},{68.4,59.6},{68.6,38.4},{68.8,58.6},{69,58.4},{69.4,49.4},{69.4,49.6},{69.6,49.2},{69.6,49.6},{71.6,52.4},{71.6,52.6},{72.2,41.8},{73.2,47.4},{73.2,47.8}}},
        },
        [73570] = { -- Senior Historian Evelyna
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{65,50.4},{65,50.6}}},
        },
        [73573] = { -- Ashwing Moth
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{28.6,71},{30.8,73.2},{35.4,67.8},{35.8,66.8},{38,82.8},{39.2,81.6},{39.4,81.4},{41.2,72.6},{41.2,83},{42.4,74.4},{42.4,74.6},{42.8,69.6},{43.6,84.4},{43.8,55.4},{43.8,56},{44.2,45.6},{44.2,74.6},{44.4,44.2},{44.6,75},{45.4,58.8},{45.4,83},{46.4,72},{46.6,73.2},{46.8,45.4},{46.8,46.6},{46.8,72.4},{47,45.8},{48,49.8},{48.4,60.4},{49.8,53.4},{56,68},{56.6,51.4},{58.6,52.2},{59.8,71.6},{60,71.4},{62.4,52.4},{62.4,76.4},{62.6,76},{63,56},{63.8,50.4},{64,50.8},{64.8,72.6},{65,64.2},{65.2,72},{65.4,67.4},{65.6,71.8},{65.8,67.6},{66.8,68},{66.8,68.6}}},
        },
        [73615] = { -- Historian Llore
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{65,50.4},{65,50.6}}},
        },
        [73616] = { -- Historian Ju'pa
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{65,50.6},{65.2,49.4},{65.4,50.4},{65.6,49.4},{65.6,49.6}}},
        },
        [73718] = { -- Southsea Lookout
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{66,74.6},{66.2,74},{66.6,74.4},{71.2,81.4},{71.2,82.8},{71.4,81.6}}},
        },
        [73828] = { -- Flamering Moth
            [npcKeys.zoneID] = zoneIDs.TIMELESS_ISLE,
            [npcKeys.spawns] = {[zoneIDs.TIMELESS_ISLE] = {{52,75.8},{52.2,75.4},{52.6,80},{54.4,75.4},{54.6,58.6},{55.2,60.2},{55.8,60},{57.8,76.4},{58.4,59},{58.4,59.8},{58.6,59.4},{58.6,59.8},{58.6,80.2},{58.8,81},{67.6,55.2},{67.6,55.8},{69.2,59},{69.4,49}}},
        },
        [244975] = { -- Aetha
            [npcKeys.name] = "Aetha",
            [npcKeys.subName] = "Spirit of the Golden Winds",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{35.03,89.98}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [244995] = { -- Quid
            [npcKeys.name] = "Quid",
            [npcKeys.subName] = "Spirit of the Misty Falls",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{30.82,79.3}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [245153] = { -- Gaohun the Soul-Severer
            [npcKeys.name] = "Gaohun the Soul-Severer",
            [npcKeys.subName] = "Shao-Tien Imperion",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{39.1,74.63}}}, -- guesstimate coords from wowhead, need to find out where it spawns
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [245163] = { -- Baolai the Immolator
            [npcKeys.name] = "Baolai the Immolator",
            [npcKeys.subName] = "Shao-Tien Imperion",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{37.48,81.47}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [245926] = { -- Bloodtip
            [npcKeys.name] = "Bloodtip",
            [npcKeys.subName] = "Ashweb Matriarch",
            [npcKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{75.77,47.59}}},
            [npcKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [246176] = { -- Vicejaw
            [npcKeys.name] = "Vicejaw",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{37.41,50.91}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246178] = { -- Cracklefang
            [npcKeys.name] = "Cracklefang",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{46.44,59.32}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246242] = { -- General Temuja
            [npcKeys.name] = "General Temuja ",
            [npcKeys.subName] = "The Soul-Slaver",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{26.4,51.2}}},
            [npcKeys.waypoints] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{{26.4,51.2},{26.6,51.4},{26.6,52.2},{26.6,52.6},{27.4,53.6},{27.6,54},{28,55.2},{28.2,55.6},{28.4,56.6},{28.6,56.6},{29.4,57.6},{29.6,57.6},{30.2,57.6},{30.6,58.2}}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246246] = { -- Shadowmaster Sydow
            [npcKeys.name] = "Shadowmaster Sydow",
            [npcKeys.subName] = "The Soul-Gatherer",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{40.78,48.04}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246383] = { -- Kri'chon
            [npcKeys.name] = "Kri\'chon",
            [npcKeys.subName] = "The Corpse-Reaver",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{5.9,58.65}}}, -- guesstimate coords from wowhead, need to find out where it spawns
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246384] = { -- Vyraxxis
            [npcKeys.name] = "Vyraxxis",
            [npcKeys.subName] = "Krik'thik Swarm-Lord",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{7.93,33.84}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246386] = { -- Bai-Jin the Butcher
            [npcKeys.name] = "Bai-Jin the Butcher",
            [npcKeys.subName] = "Shao-Tien Imperion",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{15.33,24.92}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [246479] = { -- Spirit of Lao-Fe
            [npcKeys.name] = "Spirit of Lao-Fe",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{47.44,65.68}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },

        -- Fake NPCs for Auto Accept and Auto Turn in
        [100002] = { -- A Personal Summons - Stormwind
            [npcKeys.questStarts] = {28825,29547},
        },

        -- For MoP fixes 110000-119999
        [110000] = { -- Shu, the Spirit of Water
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{79.03,37.8}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
            [npcKeys.questEnds] = {29678},
        },
        [110001] = { -- Dummy NPC for "Win PvP Pet Battles" objective
            [npcKeys.name] = "Win PvP Pet Battles",
        },
        [110002] = { -- Monstrosity
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{29.38,21.77}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.questEnds] = {29743},
        },
        [110003] = { -- Kill Kher Shan
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{33.37,41.98}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.questEnds] = {29924},
        },
        [110004] = { -- The Sprites' Plight
            [npcKeys.name] = "!",
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{49.04,21.03}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.questEnds] = {29745},
        },
        [110005] = { -- Break the Cycle & Simulacrumble
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.73,16.71}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.questEnds] = {29747,29748},
        },
        [110006] = { -- To Bridge Earth and Sky
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{43.77,12.58}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.questEnds] = {29754},
        },
        [110007] = { -- Moving On
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{86.04,21.82}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
            [npcKeys.questEnds] = {29754},
        },
        [110008] = { -- Dead Zone
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{40.07,38.99}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
            [npcKeys.questEnds] = {31009},
        },
        [110009] = { -- Anduin's Decision
            [npcKeys.name] = "!",
            [npcKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{65.9,79.37}}},
            [npcKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [npcKeys.questStarts] = {29901},
        },
        [110010] = { -- The Guo-Lai Halls
            [npcKeys.name] = "!",
            [npcKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{23.02,28.29}}},
            [npcKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            [npcKeys.questStarts] = {30637},
        },
        [110011] = { -- The Empress' Gambit
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{39.99,34.7}}},
            [npcKeys.zoneID] = zoneIDs.DREAD_WASTES,
            [npcKeys.questEnds] = {31959},
        },
        [110012] = { -- Hop Hunting
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.26,34.21},{38.58,51.72},{48.31,33.48}}},
            [npcKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
            [npcKeys.questEnds] = {30053},
        },
    }
end

function MopNpcFixes:LoadFactionFixes()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    local npcFixesHorde = {
        [59151] = { -- Zhu's Watch Courier
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{62.56,25.46}}},
        }
    }

    local npcFixesAlliance = {
        [59151] = { -- Zhu's Watch Courier
            [npcKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{66.2,30.8}}},
        }
    }

    if UnitFactionGroup("Player") == "Horde" then
        return npcFixesHorde
    else
        return npcFixesAlliance
    end
end
