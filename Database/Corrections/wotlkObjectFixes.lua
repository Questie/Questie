---@class QuestieWotlkObjectFixes
local QuestieWotlkObjectFixes = QuestieLoader:CreateModule("QuestieWotlkObjectFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieWotlkObjectFixes:Load()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [185200] = {
            [objectKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{50.12,19.37}}},
        },
        [186419] = {
            [objectKeys.questStarts] = {4127},
        },
        [187674] = {
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{43,56.3},{43.1,56.8},{43.6,57.3},},},
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [188474] = {
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT] = {{32.29,71.72}}},
        },
        [189973] = {
            [objectKeys.spawns] = {[4494]={{-1,-1}},[4277]={{-1,-1}},[3711]={{43.89,40.53},{58.8,25.89},{29.27,79.62},{53.89,33.25},{48.43,28.55},{47.2,43.63},{24.66,49.38},{32.7,40.28},{53.74,26.86},{31.93,49.22},{28.97,61.38},{56.23,33.75},{39.99,27.31},{59.24,34.41},{49.44,44.71},{57.63,80.38},{70.42,71.71},{59.85,81.17},{30.68,50.31},{27.06,74.68},{32.06,79.65},{67.28,70.74},{51.55,42.5},{44.53,42.11},{44.35,38.96},{32.78,83.46},{71.26,69.28},{56.99,76.0},{50.26,42.84},{24.17,47.7},{31.24,49.45},{32.45,57.42},{23.32,53.98},{28.93,42.05},{33.43,46.14},{25.03,52.17},{47.01,33.2},{59.27,36.36},{25.42,78.25},{57.13,36.31},{58.0,78.15},{35.76,86.23},{28.54,44.65},{32.99,60.61},{42.26,35.79},{33.49,34.92},{58.78,31.46},{52.21,25.27},{35.65,32.51},{26.68,46.52},{31.61,59.56},{23.54,51.34},{27.15,81.24},{51.62,28.73},{34.04,42.83},{33.09,80.49},{55.43,35.76}},[3537]={{69.67,43.78},{79.23,41.04},{39.73,67.89},{34.66,51.6},{50.02,75.98},{43.03,75.64},{48.2,7.52},{47.7,21.75},{59.97,51.8},{41.03,44.99},{51.65,64.32},{49.72,25.53},{62.55,13.47},{57.75,52.14},{47.19,44.79},{62.44,41.4},{43.54,42.73},{57.05,34.01},{65.99,39.49},{48.44,48.38},{53.22,22.43},{53.47,19.23},{61.79,46.85},{54.96,54.35},{76.51,43.61},{76.76,31.97},{60.83,57.35},{41.92,36.9},{79.89,32.6},{75.59,28.94},{58.88,30.58},{54.74,43.75},{64.7,11.54},{53.34,47.31},{50.25,21.3},{65.48,14.23},{55.77,30.35},{72.42,20.53},{57.79,47.2},{59.12,54.29},{53.31,39.7},{74.83,25.53},{56.23,50.18},{51.08,69.59},{44.84,5.81},{55.23,53.76},{45.34,42.65},{54.27,61.36},{46.91,70.16},{47.97,74.52},{53.04,28.18},{50.5,50.39},{42.56,40.09},{40.39,48.93},{40.73,73.33},{46.15,73.39},{43.86,71.81},{78.9,36.49},{69.96,17.32},{61.74,60.41},{34.01,61.05}},[495]={{34.38,76.15},{58.36,40.1},{30.84,63.42},{46.79,71.61},{48.71,62.73},{52.47,60.53},{50.97,34.16},{67.14,74.89},{73.61,49.43},{74.1,44.8},{45.9,50.1},{65.76,72.47},{34.9,46.17},{78.29,44.51},{76.36,67.86},{60.44,81.25},{66.54,33.4},{67.17,24.39},{72.36,18.52},{69.92,51.09},{41.72,34.22},{46.26,31.4},{48.73,21.2},{29.43,31.82},{25.24,11.83},{28.59,18.06},{27.06,29.59},{33.43,76.37},{35.59,77.8},{69.39,24.62},{56.75,18.68},{45.04,59.5},{54.68,64.97},{52.33,17.85},{71.22,24.99},{26.41,7.93},{52.78,71.41},{54.88,19.69},{29.01,22.29},{48.58,30.02},{34.59,50.45},{47.12,28.95},{31.29,33.24},{33.92,79.19},{23.77,14.03},{46.39,54.32},{37.03,44.93},{29.96,69.22},{47.96,59.18},{26.75,60.88},{50.18,16.63},{68.21,21.95},{73.27,66.74},{56.53,21.25},{58.46,22.76},{69.98,22.13},{69.78,19.15},{38.96,54.25},{32.65,32.59},{28.26,25.71},{27.14,20.74},{49.03,42.36},{51.06,41.85},{42.06,27.71},{44.63,29.75},{59.16,50.31},{28.08,9.14},{29.17,12.03},{70.45,32.36},{58.96,55.52},{75.49,60.7},{79.15,49.69},{57.2,55.85},{56.95,67.15},{65.79,26.83},{76.27,42.81},{75.42,50.8},{33.21,63.56},{59.52,51.54},{26.87,14.58},{70.61,66.0},{69.73,69.61},{34.85,34.07},{70.08,71.98},{67.85,59.59},{63.71,28.01},{70.05,47.3},{48.21,18.06},{80.43,46.21},{49.24,72.09},{71.53,54.86},{73.57,26.69},{62.6,80.4},{60.96,26.08},{40.88,40.17},{51.86,59.16},{66.6,64.92},{76.85,49.84},{73.18,58.5},{76.68,63.9},{48.65,48.05},{50.44,63.88},{59.93,76.85},{39.23,33.09},{27.05,12.15},{52.45,32.16},{35.73,53.67},{43.36,44.08},{68.15,32.91},{64.87,67.63},{51.05,48.28},{36.99,39.9}},[394]={{82.23,56.11},{55.85,36.08},{10.68,34.62},{72.74,34.88},{25.24,31.3},{59.75,30.76},{11.3,69.48},{75.91,45.72},{45.75,31.14},{32.2,37.31},{27.12,38.42},{14.21,53.25},{15.02,50.41},{47.22,27.35},{49.2,27.28},{24.89,37.32},{64.67,26.49},{12.87,59.24},{68.54,21.52},{73.83,23.36},{62.72,27.49},{70.65,31.26},{75.87,38.32},{9.08,39.65},{24.35,33.15},{12.89,45.59},{12.29,55.76},{80.03,45.24},{78.15,42.57},{12.15,36.31},{14.74,61.38},{24.16,28.11},{21.94,25.63},{30.29,34.68},{73.84,28.26},{56.11,33.12},{76.78,50.7},{70.6,22.1},{54.6,31.33},{80.03,53.97},{52.0,28.6},{72.01,49.89},{12.69,41.68},{42.79,28.88},{63.64,24.02}},[65]={{65.62,74.62},{45.93,46.92},{64.79,77.14},{65.06,71.76},{63.56,70.58},{47.51,52.14},{49.24,50.53},{48.6,45.91}}},
        },
        [190094] = {
            [objectKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_VILLAGE]={{73.42,54.98},{83.87,59.05},{81.21,59.75},{77.85,54.92},{70.12,51.25}},[4100]={{-1,-1}}},
        },
        [190095] = {
            [objectKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_VILLAGE]={{73.42,54.98},{83.87,59.05},{81.21,59.75},{77.85,54.92},{70.12,51.25}},[4100]={{-1,-1}}},
        },
        [190169] = {
            [objectKeys.spawns] = {[4494]={{-1,-1}},[4277]={{-1,-1}},[3537]={{53.21,48.35},{52.68,41.46},{49.37,43.1},{52.65,47.97},{49.66,45.51},{53.29,44.11},{52.18,46.23},{52.35,46.02},{52.83,41.43},{49.6,45.38},{53.89,42.45},{52.26,45.85},{52.11,46.22},{54.12,46.55},{53.52,44.86},{54.0,42.61},{49.27,43.22},{54.15,46.28},{53.16,44.66},{53.56,45.59},{52.6,48.09}},[3711]={{64.16,46.35},{69.47,66.68},{60.11,85.28},{54.55,85.58},{56.37,86.67},{22.67,61.31},{32.81,61.48},{63.85,48.85},{25.25,59.03},{47.13,61.12},{46.72,64.88},{47.92,60.03},{50.22,55.92},{53.15,85.23},{49.53,69.37},{57.47,83.22},{53.52,86.75},{43.57,75.3},{46.21,72.78},{48.51,51.64},{50.17,65.06},{49.56,65.75},{68.64,66.59},{46.93,65.54},{49.46,60.74},{50.47,62.58},{47.12,74.54},{48.41,68.8},{48.07,70.47},{48.71,60.34},{46.22,63.07},{50.23,64.27},{49.43,71.11},{48.43,59.75},{59.7,86.36},{69.29,68.4},{46.44,63.84},{48.58,53.35},{47.58,49.58},{43.63,74.1},{32.7,64.51},{30.72,64.84},{56.29,84.83},{32.31,60.43},{27.16,61.08},{49.93,63.64},{59.22,86.3},{23.88,61.03},{49.46,52.33},{62.97,47.98},{45.96,49.71},{49.02,50.08},{44.67,49.08},{63.73,47.29},{22.34,60.32},{51.59,86.36},{58.28,86.63},{31.34,60.68},{68.45,67.95},{30.58,60.01},{47.96,73.95},{29.13,61.8},{29.1,63.7},{45.92,51.13},{23.89,59.83}},[495]={{55.07,47.6},{60.17,37.71},{59.99,32.38},{54.56,57.78},{39.23,19.92},{59.6,54.17},{30.27,25.6},{43.79,23.64},{22.18,25.96},{66.79,19.17},{67.93,18.93},{56.85,57.08},{22.7,26.32},{67.14,22.33},{68.42,20.74},{53.38,55.67},{59.69,55.83},{52.74,53.39},{60.25,52.35},{32.61,25.82},{47.21,41.4},{52.83,44.98},{42.4,39.81},{31.69,25.71},{52.47,50.02},{55.47,47.34},{35.09,23.86},{49.31,40.25},{40.29,21.76},{41.97,24.3},{26.44,27.38},{64.09,25.81},{53.38,57.71},{36.82,22.68},{62.81,28.91},{58.91,35.07},{53.43,52.1},{29.02,26.35},{46.26,18.85}},[394]={{22.07,41.69},{38.05,35.08},{62.76,50.06},{41.96,35.26},{29.18,55.86},{28.03,41.23},{25.77,40.56},{27.53,61.81},{56.12,51.0},{39.97,32.83},{29.31,52.46},{20.11,40.65},{32.27,43.86},{36.08,31.71},{9.7,41.06},{8.51,37.15},{15.46,38.36},{31.13,46.07},{54.22,44.3},{61.34,49.21},{53.23,48.28},{60.93,53.04},{10.33,38.88},{25.1,71.67},{13.97,41.1},{8.72,34.96},{27.38,65.75},{62.7,49.51},{29.06,58.87},{29.2,62.45},{34.47,42.43},{62.93,52.6},{11.8,39.29},{64.88,52.82},{37.15,41.59},{30.21,39.64},{16.82,40.6},{27.6,69.79},{66.61,54.91},{11.75,29.25},{30.12,43.2}}},
        },
        [190558] = {
            [objectKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN] = {{48.3,49.1},{49.4,53.1},{49.6,50.9},{49.7,54.4},{49.7,54.5},{49.8,49.1},{50,51.7},{50,59.8},{50.2,47.5},{50.3,53.3},{50.3,58.5},{50.4,47.2},{50.4,50.4},{50.4,56.8},{50.4,58.3},{50.5,50.4},{50.5,50.5},{50.6,55.5},{50.6,56.9},{50.9,52},{50.9,54.6},{51.1,58.8},{51.4,52.6},{51.4,53.6},{51.4,57.8},{51.5,52.4},{51.5,53.5},{51.5,57.8},{51.6,49.8},{51.7,49.4},{51.7,62.6},{51.8,54.7},{51.9,58.6},{52,61.3},{52.3,61.7},{52.4,53.1},{52.4,56.2},{52.5,51.6},{52.5,53.1},{52.5,56.2},{52.6,60.5},{52.7,60.3},{52.7,62.1},{52.8,54.9},{53.1,50.5},{53.2,47.4},{53.2,47.6},{53.2,50.3},{53.3,59.3},{53.4,49.4},{53.4,53.5},{53.5,49.5},{53.5,53.4},{53.5,53.5},{53.5,61.7},{53.7,60.8},{54.2,51.4},{54.2,51.5},{54.3,48.9},{54.3,59.9},{54.5,49.1},{54.7,57.9},{54.7,60.8},{54.9,51.5},{55,53.7},{55.1,51.2},{55.3,60.2},{55.5,60.2},{55.6,57.4},{55.6,57.6},{55.7,58.6},{55.8,48.9},{55.8,52.8},{55.9,56.3},{56.2,50.9},{56.2,55.2},{56.7,53.4},{56.7,53.5},{56.9,56.3},{56.9,56.5},{57.1,52.2},{57.1,58.8},{57.2,60.6},{57.3,54.5},{57.3,60.1},{57.5,54.4},{58,60.4},{58,60.5},{58.4,58.9},{58.7,53.8},{58.7,55.9},{58.8,62.3},{59.1,57.9},{59.1,60.2},{59.8,55},{59.8,60.4},{59.8,60.5},{59.9,57.3},{60.1,63.9},{60.3,61.9},},},
        },
        [190663] = {
            [objectKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_CITY]={{30.6,46.7}},[4100]={{-1,-1}}},
        },
        [190781] = {
            [objectKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN] = {{33.56,74.96}}},
        },
        [191092] = {
            [objectKeys.spawns] = {[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE] = {{63.12,68.33}}},
        },
        [191349] = {
            [objectKeys.spawns] = {[zoneIDs.BAND_OF_ALIGNMENT]={{47.6,85.9}},[4228]={{-1,-1}}},
        },
        [192124] = {
            [objectKeys.spawns] = {},
        },
        [192127] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{73.4,62.9},{73.5,63.4},{75,63.5},{75.4,62.9},{75.6,63.6},{75.7,63},{75.9,64.5},{76.9,62.2},{76.9,63.1},{77,63.9},{77.6,62.4},{77.6,62.5},}},
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [192536] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{52.36,73.26},{43.61,67.3},{43.76,67.21},{45.46,66.73},{43.87,67.74},{45.52,67.16},{45.19,66.82},{52.66,75.17},{52.36,75.08},{52.36,75.43},{53.28,75.10},{53.57,74.88},{53.53,74.64}}},
        },
        [192788] = {
            [objectKeys.spawns] = {[zoneIDs.THE_NEXUS_MAP] = {{18.9,51.7}},[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [192818] = {
            [objectKeys.spawns] = {[zoneIDs.THE_UNDERBELLY] = {{30.4,51.5},{30.5,51.3},{34.8,52.2},{35,42.4},{35.1,35.5},{35.3,42.9},{35.3,53},{35.4,35.1},{35.5,35.2},{35.5,35.5},{35.5,43},{35.7,52.4},{39.3,28.4},{39.3,28.6},{39.3,39.9},{39.4,40.6},{39.5,28.6},{39.5,40.4},{39.7,47},{39.8,28.3},{40,47.7},{43.3,32.6},{43.4,32.3},{43.5,32.2},{43.6,32.6},{44.4,65.1},{44.4,65.6},{44.5,65.1},{45.3,58.2},{45.6,58.1},{45.8,58.8},{47.3,56},{47.4,28.4},{47.4,56.9},{48,29.5},{48,55.5},{48.2,55.4},{48.3,29.4},{48.4,40.4},{48.4,40.7},{48.5,29.4},{48.5,29.8},{48.5,41.1},{50.4,25.6},{50.4,26.6},{50.4,52.8},{50.6,25.9},{50.6,26.6},{51.2,53},{51.2,53.6},{51.4,42.1},{51.4,42.5},{51.5,42.2},{51.5,42.6},{51.6,53.4},{51.8,53.8},{54.3,66.2},{54.7,66.8},{55,66.2},{55.3,56.3},{55.4,56.9},{55.5,57.6},{55.6,56.3},{55.7,56.7},{55.8,58.6},{56.7,40.1},{56.8,40.7},{57.4,41.5},{57.4,47.4},{57.5,40.9},{57.6,41.5},{57.6,47.4},{58,47.6},{59,12.5},{59.4,35},{59.4,35.6},{59.5,35.3},{59.7,11.7},{60.6,14.3},{61.8,9.2},{62.3,10.5},{62.4,10},{62.6,10},{64.2,15.1},{64.2,15.6},},},
            [objectKeys.zoneID] = zoneIDs.THE_UNDERBELLY,
        },
        [192826] = {
            [objectKeys.spawns] = {[zoneIDs.GUNDRAK_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.GUNDRAK_LOWER_LEVEL] = {{-1,-1}},[4416] = {{-1,-1}}},
        },
        [192941] = {
            [objectKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{-1,-1}},[1196] = {{-1,-1}}},
        },
        [192942] = {
            [objectKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{-1,-1}},[1196] = {{-1,-1}}},
        },
        [192943] = {
            [objectKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{-1,-1}},[1196] = {{-1,-1}}},
        },
        [192944] = {
            [objectKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{-1,-1}},[1196] = {{-1,-1}}},
        },
        [192945] = {
            [objectKeys.spawns] = {[zoneIDs.UTGARDE_PINNACLE_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_PINNACLE_LOWER_LEVEL] = {{-1,-1}},[1196] = {{-1,-1}}},
        },
        [193004] = {
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{59.35,71.77}}},
        },
        [193051] = {
            [objectKeys.spawns] = {[zoneIDs.THE_GILDED_GATE] = {{-1,-1}},[zoneIDs.HADRONOXS_LAIR] = {{-1,-1}},[4277] = {{-1,-1}}},
        },
        [193057] = {
            [objectKeys.spawns] = {[zoneIDs.AHNKAHET_MAP] = {{12.29,50.82}},[4494] = {{-1,-1}}},
        },
        [193059] = {
            [objectKeys.spawns] = {[zoneIDs.UTGARDE_KEEP_UPPER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_KEEP_LOWER_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_KEEP_MIDDLE_LEVEL] = {{-1,-1}},[zoneIDs.UTGARDE_KEEP] = {{-1,-1}}},
        },
        [193091] = {
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{34.7,66.0}}},
        },
        [193092] = {
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{36.6,67.6}}},
        },
        [193580] = {
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{60.84,63.38},{61.55,63.96},{62.26,63.38}}},
        },
        [193597] = {
            [objectKeys.spawns] = {[zoneIDs.THE_CULLING_OF_STRATHOLME_CITY]={{30.6,46.7}},[4100]={{-1,-1}}},
        },
        [193603] = {
            [objectKeys.spawns] = {[zoneIDs.BAND_OF_ALIGNMENT]={{47.6,85.9}},[4228]={{-1,-1}}},
        },
        [193980] = {
            [objectKeys.name] = "Bloodstained Stone",
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{49.7,73.4}}},
            [objectKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [193997] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{55.4,68},{57,65},{58.6,60.3},{60.7,57.5},{62.8,60.1},{63.5,57.9},{65.4,60.8},{68.4,55.7},{68.9,54.8},{69.7,63.1},{71.1,62.4},{72.6,61.9},{75.3,48.5},},},
        },
        [194023] = {
            [objectKeys.name] = "Bloodstained Stone",
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{49.2,73.9}}},
            [objectKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [194024] = {
            [objectKeys.name] = "Bloodstained Stone",
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{48.3,72.8}}},
            [objectKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [194032] = {
            [objectKeys.questStarts] = {13440},
            [objectKeys.questEnds] = {13440},
        },
        [194033] = {
            [objectKeys.questStarts] = {13441},
            [objectKeys.questEnds] = {13441},
        },
        [194034] = {
            [objectKeys.questStarts] = {13450},
            [objectKeys.questEnds] = {13450},
        },
        [194035] = {
            [objectKeys.questStarts] = {13442},
            [objectKeys.questEnds] = {13442},
        },
        [194036] = {
            [objectKeys.questStarts] = {13443},
            [objectKeys.questEnds] = {13443},
        },
        [194037] = {
            [objectKeys.questStarts] = {13451},
            [objectKeys.questEnds] = {13451},
        },
        [194038] = {
            [objectKeys.questStarts] = {13444},
            [objectKeys.questEnds] = {13444},
        },
        [194039] = {
            [objectKeys.questStarts] = {13453},
            [objectKeys.questEnds] = {13453},
        },
        [194040] = {
            [objectKeys.questStarts] = {13445},
            [objectKeys.questEnds] = {13445},
        },
        [194042] = {
            [objectKeys.questStarts] = {13454},
            [objectKeys.questEnds] = {13454},
        },
        [194043] = {
            [objectKeys.questStarts] = {13455},
            [objectKeys.questEnds] = {13455},
        },
        [194044] = {
            [objectKeys.questStarts] = {13446},
            [objectKeys.questEnds] = {13446},
        },
        [194045] = {
            [objectKeys.questStarts] = {13447},
            [objectKeys.questEnds] = {13447},
        },
        [194046] = {
            [objectKeys.questStarts] = {13457},
            [objectKeys.questEnds] = {13457},
        },
        [194048] = {
            [objectKeys.questStarts] = {13458},
            [objectKeys.questEnds] = {13458},
        },
        [194049] = {
            [objectKeys.questStarts] = {13449},
            [objectKeys.questEnds] = {13449},
        },
        [194123] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{64.5,46.9}},},
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [194200] = {
            [objectKeys.spawns] = {[zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR]={{64.1,60.2}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR,
        },
        [194201] = {
            [objectKeys.spawns] = {[zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR]={{64.1,60.2}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR,
        },
        [194313] = {
            [objectKeys.spawns] = {[zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR]={{70.7,48.5}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR,
        },
        [194314] = {
            [objectKeys.spawns] = {[zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR]={{70.7,48.5}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR,
        },
        [194327] = {
            [objectKeys.spawns] = {[zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR]={{53,25.4}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR,
        },
        [194331] = {
            [objectKeys.spawns] = {[zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR]={{53,25.4}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_INNER_SANCTUM_OF_ULDUAR,
        },
        [194463] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{40.1,60.5},{43.5,54.9},{45,57},{41,54},{39,60},{46.1,61},{46.2,59.2}}},
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [194555] = {
            [objectKeys.spawns] = {[zoneIDs.THE_ARCHIVUM]={{15.6,90.3}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_ARCHIVUM,
        },
        [194957] = {
            [objectKeys.spawns] = {[zoneIDs.THE_SPARK_OF_IMAGINATION]={{43.7,40.9}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_SPARK_OF_IMAGINATION,
        },
        [194958] = {
            [objectKeys.spawns] = {[zoneIDs.THE_SPARK_OF_IMAGINATION]={{43.7,40.9}},[zoneIDs.ULDUAR]={{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_SPARK_OF_IMAGINATION,
        },
        [195309] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{42.65,58.43},{42.25,60.1},{43.36,60.69},{43.4,57.84},{42.94,56.95},{43.22,55.94},{42.52,55.01},{43.09,54.6},{41.51,53.56},{41.19,52.62},{40.67,53.31},{40.06,52.53},{39.38,53.79},{38.55,53.96},{38.46,55.05},{37.61,56.07},{38.38,58.33},{37.73,59.86},{38.57,61.28},{38.87,60.57},{39.23,61.41},{40.61,60.33},{41.53,60.01},{42.24,60.09},{43.36,60.69},{44.68,59.4},{45.55,59.06},{45.47,60.13},{45.06,60.94},{45.15,61.93},{44.54,61.9},{46,61.18},{46.5,62.41},{46.08,63.36},{46.7,64.01},{47.35,62.49},{47.72,61.55},{46.88,59.91},{46.29,58.52},{45.85,57.6},{45.92,57.02},{45.77,55.82},{42.4,53.88},{43.38,59.28},{43.82,61.93},{46.69,60.7},{45.03,56.98},{45.15,55.61},{45.03,56.96},{43.9,56.55},{43.38,59.28},{44.27,61.01},{46.82,63.05},{44.34,58.48},{46.56,62.92},{38.21,62.04},{38.03,58.85},{37.67,57.9},{38.13,57.05},{39.95,61.25},{38.84,59.57},{40.56,62.92}}},
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },

        -- Below are fake objects
        [400015] = {
            [objectKeys.name] = "Summoning Stone",
            [objectKeys.spawns] = {[zoneIDs.ICECROWN]={{53.77,33.60}}},
            [objectKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [400016] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12941},
            [objectKeys.questEnds] = {12941},
            [objectKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{40.86,66.04}}}, -- Argent Stand
            [objectKeys.zoneID] = zoneIDs.ZUL_DRAK,
        },
        [400017] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12940},
            [objectKeys.questEnds] = {12940},
            [objectKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{59.33,57.20}}}, -- Zim'Torga
            [objectKeys.zoneID] = zoneIDs.ZUL_DRAK,
        },
        [400018] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12947},
            [objectKeys.questEnds] = {12947},
            [objectKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{65.35,47.00}}}, -- Camp Oneqwah
            [objectKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [400019] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12946},
            [objectKeys.questEnds] = {12946},
            [objectKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{20.89,64.77}}}, -- Conquest Hold
            [objectKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [400020] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13464},
            [objectKeys.questEnds] = {13464},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{49.44,10.75}}}, -- Camp Winterhoof
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400021] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13466},
            [objectKeys.questEnds] = {13466},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{79.27,30.62}}}, -- Vengeance Landing
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400022] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13465},
            [objectKeys.questEnds] = {13465},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{52.10,66.14}}}, -- New Agamand
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400023] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13452},
            [objectKeys.questEnds] = {13452},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{25.44,59.82}}}, -- Kamagua
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400024] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13470},
            [objectKeys.questEnds] = {13470},
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{76.82,63.29}}}, -- Venomspite
            [objectKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [400025] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13456},
            [objectKeys.questEnds] = {13456},
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{60.15,53.45}}}, -- Wyrmrest Temple
            [objectKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [400026] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13459},
            [objectKeys.questEnds] = {13459},
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{48.11,74.66}}}, -- Moa'ki Harbor
            [objectKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [400027] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13469},
            [objectKeys.questEnds] = {13469},
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{37.83,46.48}}}, -- Agmar's Hammer
            [objectKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [400028] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13460},
            [objectKeys.questEnds] = {13460},
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA]={{78.45,49.16}}}, -- Unu'pe
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [400029] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13467},
            [objectKeys.questEnds] = {13467},
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA]={{76.66,37.47}}}, -- Taunka'le Village
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [400030] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13468},
            [objectKeys.questEnds] = {13468},
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA]={{41.71,54.40}}}, -- Warsong Hold
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [400031] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13501},
            [objectKeys.questEnds] = {13501},
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA]={{49.75,9.98}}}, -- Bor'gorok Outpost
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [400032] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12950},
            [objectKeys.questEnds] = {12950},
            [objectKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{26.61,59.20}}}, -- Nesingwary Base Camp
            [objectKeys.zoneID] = zoneIDs.SHOLAZAR_BASIN,
        },
        [400033] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13461},
            [objectKeys.questEnds] = {13461},
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{41.07,85.85}}}, -- K3
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [400034] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13462},
            [objectKeys.questEnds] = {13462},
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{30.92,37.16}}}, -- Bouldercrag's Refuge
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [400035] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13471},
            [objectKeys.questEnds] = {13471},
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{67.65,50.69}}}, -- Camp Tunka'lo
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [400036] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13548},
            [objectKeys.questEnds] = {13548},
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{37.09,49.50}}}, -- Grom'arsh Crash Site
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [400037] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13448},
            [objectKeys.questEnds] = {13448},
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{28.72,74.28}}}, -- Frosthold
            [objectKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [400038] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12944},
            [objectKeys.questEnds] = {12944},
            [objectKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{31.94,60.21}}}, -- Amberpine Lodge
            [objectKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [400039] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {12945},
            [objectKeys.questEnds] = {12945},
            [objectKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{59.63,26.36}}}, -- Westfall Brigade Encampment
            [objectKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [400040] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13435},
            [objectKeys.questEnds] = {13435},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{60.47,15.91}}}, -- Fort Wildervar
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400041] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13433},
            [objectKeys.questEnds] = {13433},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{58.32,62.82}}}, -- Valgarde
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400042] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13434},
            [objectKeys.questEnds] = {13434},
            [objectKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{30.83,41.42}}}, -- Westguard Keep
            [objectKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [400043] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13438},
            [objectKeys.questEnds] = {13438},
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{28.95,56.22}}}, -- Stars' Rest
            [objectKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [400044] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13439},
            [objectKeys.questEnds] = {13439},
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{77.50,51.28}}}, -- Wintergarde Keep
            [objectKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [400045] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13437},
            [objectKeys.questEnds] = {13437},
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA]={{57.12,18.81}}}, -- Fizzcrank Airstrip
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [400046] = {
            [objectKeys.name] = "Candy Bucket",
            [objectKeys.questStarts] = {13436},
            [objectKeys.questEnds] = {13436},
            [objectKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA]={{58.52,67.87}}}, -- Valiance Keep
            [objectKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [400047] = {
            [objectKeys.name] = "Drakuru's Brazier",
            [objectKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{17.42,36.36}}}, -- Zeb'Halak
            [objectKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [400048] = {
            [objectKeys.name] = "Chemical Wagon", -- Orgrimmar
            [objectKeys.spawns] = {[zoneIDs.DUROTAR]={{40.13,15.71}}},
            [objectKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [400049] = {
            [objectKeys.name] = "Chemical Wagon", -- Ambermill
            [objectKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST]={{54.75,61.33}}},
            [objectKeys.zoneID] = zoneIDs.SILVERPINE_FOREST,
        },
        [400050] = {
            [objectKeys.name] = "Chemical Wagon", -- Elwynn
            [objectKeys.spawns] = {[zoneIDs.ELWYNN_FOREST]={{29.19,65.44}}},
            [objectKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
        },
        [400051] = {
            [objectKeys.name] = "Chemical Wagon", -- Darkshore
            [objectKeys.spawns] = {[zoneIDs.DARKSHORE]={{42.47,79.46}}},
            [objectKeys.zoneID] = zoneIDs.DARKSHORE,
        },
        [400052] = {
            [objectKeys.name] = "Chemical Wagon", -- Hillsbrad
            [objectKeys.spawns] = {[zoneIDs.HILLSBRAD_FOOTHILLS]={{28.22,37.63}}},
            [objectKeys.zoneID] = zoneIDs.HILLSBRAD_FOOTHILLS,
        },
        [400053] = {
            [objectKeys.name] = "Chemical Wagon", -- Theramore
            [objectKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{60.83,38.49}}},
            [objectKeys.zoneID] = zoneIDs.DUSTWALLOW_MARSH,
        },
        [400054] = {
            [objectKeys.name] = "Chemical Wagon", -- Aerie Peak
            [objectKeys.spawns] = {[zoneIDs.THE_HINTERLANDS]={{23.44,53.68}}},
            [objectKeys.zoneID] = zoneIDs.THE_HINTERLANDS,
        },
        [400055] = {
            [objectKeys.name] = "Chemical Wagon", -- Everlook
            [objectKeys.spawns] = {[zoneIDs.WINTERSPRING]={{64.67,37.36}}},
            [objectKeys.zoneID] = zoneIDs.WINTERSPRING,
        },
        [400056] = {
            [objectKeys.name] = "Chemical Wagon", -- Shattrath
            [objectKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST]={{41.46,22.52}}},
            [objectKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
        },
        [400057] = {
            [objectKeys.name] = "Chemical Wagon", -- Crystalsong
            [objectKeys.spawns] = {[zoneIDs.CRYSTALSONG_FOREST]={{50.5,50.11},{46.44,50.86},{48.46,51.01},{49.09,47.62}}},
            [objectKeys.zoneID] = zoneIDs.CRYSTALSONG_FOREST,
        },
    }
end
