---@class CataObjectFixes
local CataObjectFixes = QuestieLoader:CreateModule("CataObjectFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")


function CataObjectFixes.Load()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs
    local waypointPresets = QuestieDB.waypointPresets

    return {
        [2712] = { -- Calcified Elven Gem
            [objectKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS] = {{17.9,89.15},{10.7,91.52},{13.84,89.84},{17.68,87.3},{12.79,87.24},{14.29,93.01},{15.8,92.75},{16.21,95.14},{18.65,93.58},{14.25,95.1},{12.55,92.85},{18.32,92.14},{14.29,93.01},{18.32,92.14},{12.79,87.24},{16.21,95.14}}},
        },
        [7510] = { -- Sprouted Frond
            [objectKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{43.91,43.99},{43.93,44.04},{43.95,44.08},{59.88,59.89},{59.84,59.86},{59.81,59.84}}},
        },
        [13949] = { -- Pitted Iron Chest
            [objectKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS] = {{32.87,41.17},{-1,-1}}},
        },
        [19283] = { -- Compendium of the Fallen
            [objectKeys.spawns] = {[zoneIDs.SCARLET_MONASTERY_LIBRARY] = {{82.1,14.1}},[zoneIDs.SCARLET_MONASTERY] = {{-1,-1}}},
        },
        [126158] = { -- Tallonkai's Dresser
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{66.1,52}},
            },
        },
        [144052] = { -- Sandsorrow Watch Water Hole
            [objectKeys.name] = "Sandsorrow Watch Water Hole",
        },
        [147557] = { -- Stolen Silver
            [objectKeys.spawns] = {[zoneIDs.THE_BARRENS]={{63.72,58.80}}},
        },
        [148503] = { -- Fire Plume Ridge Hot Spot
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{48.32,43.48}}},
        },
        [154357] = { -- Glinting Mud
            [objectKeys.spawns] = {[zoneIDs.REDRIDGE_MOUNTAINS]={{25.88,47.15},{23.94,49.78},{34.8,49.43},{32.07,51.94},{19.77,47.27},{27.09,50.94},{35.73,49.6},{35.71,49.6},{21.92,48.48}}},
        },
        [161752] = { -- Tool Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_BARRENS]={{40.75,33.22},{40.74,33.38},{40.65,33.46},{40.44,32.85},{41.00,32.98},{41.49,32.08},{41.90,32.09},{42.07,32.31},{42.14,31.90},{42.48,31.92},{42.72,31.82},{42.98,32.12},{42.69,32.68},{42.19,32.65},{43.12,31.49},{43.04,30.90}}},
        },
        [164658] = { -- Blue Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{58.20,49.87},{56.20,60.56},{59.56,60.24},{59.79,49.38},{64.27,53.91},{60.37,59.65},{59.48,60.30},{58.17,65.89},{56.85,76.19},{58.62,78.34},{62.33,70.35},{62.35,68.47},{60.87,68.56},{68.39,59.81},{68.03,51.40},{72.76,51.92},{71.67,63.41},{70.15,64.10},{69.55,69.50},{66.73,73.31},{63.13,75.27},{60.36,77.47},{58.64,78.34},{57.38,82.59},{50.00,92.42},{61.96,85.24},{69.41,79.99},{69.98,77.22},{74.99,70.50},{74.41,63.87},{75.33,61.51},{79.89,61.92},{81.57,60.57},{79.38,57.94},{76.72,57.72},{74.42,57.05},{80.31,49.72}}},
        },
        [164659] = { -- Green Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{53.72,38.76},{51.79,34.97},{51.76,34.97},{51.54,13.58},{55.68,7.93},{58.08,8.73},{57.35,10.07},{58.34,10.78},{56.54,12.31},{56.09,18.58},{54.11,18.21},{59.19,20.26},{60.95,15.03},{62.54,16.69},{63.39,23.16},{62.57,27.03},{62.14,40.54},{66.14,21.10},{69.86,18.86},{72.17,21.17},{71.94,23.19},{68.29,25.42},{66.72,47.00},{72.92,46.81},{78.21,40.13},{81.41,39.07},{72.36,35.52},{69.58,35.07}}},
        },
        [164660] = { -- Red Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{20.60,50.00},{25.72,63.26},{26.06,59.50},{24.58,60.38},{30.31,70.50},{28.94,76.88},{31.16,81.26},{33.86,76.94},{38.23,81.86},{45.77,92.64},{44.18,88.89},{42.76,86.26},{40.62,79.88},{40.47,75.21},{32.69,73.47},{29.67,64.82},{30.77,63.33},{27.94,61.06},{26.00,59.59},{25.78,53.88},{36.15,69.04},{40.46,75.25},{43.86,74.63},{36.15,68.94},{37.80,66.50},{40.58,50.09},{42.88,52.74},{42.81,65.99},{45.46,65.93},{46.95,61.04}}},
        },
        [164661] = { -- Yellow Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{24.32,43.57},{42.98,45.54},{42.52,33.91},{38.13,41.81},{46.2,19.53},{39.74,26.91},{34.67,33.25},{27.74,46.43},{32.98,29.54},{37.82,20.53},{43.83,21.45},{46.21,19.69},{46.87,14.92},{47.35,12.89},{39.34,14.47},{37.75,20.61},{31.27,18.55},{30.13,21.21},{26.39,29.08},{19.61,38.82},{25.52,39.9},{24.73,40.49}}},
        },
        [164778] = { -- Blue Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{58.20,49.87},{56.20,60.56},{59.56,60.24},{59.79,49.38},{64.27,53.91},{60.37,59.65},{59.48,60.30},{58.17,65.89},{56.85,76.19},{58.62,78.34},{62.33,70.35},{62.35,68.47},{60.87,68.56},{68.39,59.81},{68.03,51.40},{72.76,51.92},{71.67,63.41},{70.15,64.10},{69.55,69.50},{66.73,73.31},{63.13,75.27},{60.36,77.47},{58.64,78.34},{57.38,82.59},{50.00,92.42},{61.96,85.24},{69.41,79.99},{69.98,77.22},{74.99,70.50},{74.41,63.87},{75.33,61.51},{79.89,61.92},{81.57,60.57},{79.38,57.94},{76.72,57.72},{74.42,57.05},{80.31,49.72}}},
        },
        [164779] = { -- Green Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{53.72,38.76},{51.79,34.97},{51.76,34.97},{51.54,13.58},{55.68,7.93},{58.08,8.73},{57.35,10.07},{58.34,10.78},{56.54,12.31},{56.09,18.58},{54.11,18.21},{59.19,20.26},{60.95,15.03},{62.54,16.69},{63.39,23.16},{62.57,27.03},{62.14,40.54},{66.14,21.10},{69.86,18.86},{72.17,21.17},{71.94,23.19},{68.29,25.42},{66.72,47.00},{72.92,46.81},{78.21,40.13},{81.41,39.07},{72.36,35.52},{69.58,35.07}}},
        },
        [164780] = { -- Red Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{20.60,50.00},{25.72,63.26},{26.06,59.50},{24.58,60.38},{30.31,70.50},{28.94,76.88},{31.16,81.26},{33.86,76.94},{38.23,81.86},{45.77,92.64},{44.18,88.89},{42.76,86.26},{40.62,79.88},{40.47,75.21},{32.69,73.47},{29.67,64.82},{30.77,63.33},{27.94,61.06},{26.00,59.59},{25.78,53.88},{36.15,69.04},{40.46,75.25},{43.86,74.63},{36.15,68.94},{37.80,66.50},{40.58,50.09},{42.88,52.74},{42.81,65.99},{45.46,65.93},{46.95,61.04}}},
        },
        [164781] = { -- Yellow Power Crystal
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{24.32,43.57},{42.98,45.54},{42.52,33.91},{38.13,41.81},{46.2,19.53},{39.74,26.91},{34.67,33.25},{27.74,46.43},{32.98,29.54},{37.82,20.53},{43.83,21.45},{46.21,19.69},{46.87,14.92},{47.35,12.89},{39.34,14.47},{37.75,20.61},{31.27,18.55},{30.13,21.21},{26.39,29.08},{19.61,38.82},{25.52,39.9},{24.73,40.49}}},
        },
        [169216] = { -- Preserved Threshadon Carcass
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER] = {{70.11,40.95}}},
        },
        [177964] = { -- Fathom Stone
            [objectKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS_MOONSHRINE_SANCTUM] = {{41.41,75.37}},[zoneIDs.BLACKFATHOM_DEEPS] = {{-1,-1}}},
        },
        [179832] = { -- Pillaclencher's Ornate Pillow
            [objectKeys.spawns] = {[zoneIDs.SEARING_GORGE] = {{45.86,29.54}}},
        },
        [180453] = { -- Hive'Regal Glyphed Crystal
            [objectKeys.spawns] = {[zoneIDs.SILITHUS]={{55.61,90.54}}},
        },
        [180771] = { -- Firework Launcher
            [objectKeys.spawns] = {
                [zoneIDs.MOONGLADE]={{37.15,57.88},{37.59,58.72},{37.39,59.64},{37.2,58.45},{37.38,59.26},{53.38,36.7},{54.16,36.9},{36.3,57.86},{35.98,59.94},{37.9,58.39},{53.92,36.84},{36.92,56.77},{36.52,60.23},{35.48,58.67},{36.5,56.81},{35.95,58.69},{42.64,35.39},{53.07,36.61},{36.45,57.12},{37.05,59.11},{36.15,57.41},{36.61,59.4},{42.53,34.3},{35.69,57.86},{35.68,58.43},{44.59,38.64},{53.63,36.77}},
                [zoneIDs.UNDERCITY]={{65.44,36.74},{66.37,37.56},{65.65,37.56},{66.01,37.75},{66.58,36.75},{50.61,56.53},{52.76,55.96},{74.28,67.11},{79.36,55.39},{55.7,22.96},{78.99,56.28},{52.43,55.02},{55.13,23.62},{73.24,64.33},{50.97,57.45},{78.21,25.35},{57.82,63.6},{56.96,25.43},{58.43,64.13}},
                [zoneIDs.STORMWIND_CITY]={{56.02,42.12},{55.15,69.79},{56.53,42.04},{54.64,68.04},{54.74,69.81},{56.26,42.45},{46.45,57.72},{68.22,64.95},{55.08,44.3},{46.84,58.45},{69.13,65.14},{62.84,50.33},{62.74,49.8},{56.55,41.36},{63.04,51.43},{69.18,65.99},{55.79,43.25},{68.46,64.42},{55.06,68},{55.35,43.9},{56.03,42.86},{62.96,50.97},{55.09,68.55},{62.43,50.51},{68.52,65.28},{55.13,43.53},{55.12,69.2},{55.57,42.87}},
                [zoneIDs.IRONFORGE]={{31.43,19.12},{29.85,18.67},{30.72,19.34},{30.45,20.68},{31.42,16.83},{29.1,19.58},{32.16,15.77},{32.61,18.02},{31.76,18.09},{64.67,24.81},{65.06,25.57},{64.26,24.08}},
                [zoneIDs.ORGRIMMAR]={{51.86,57.02},{52.6,57.14},{51.38,59.8},{52.39,59.25},{52.62,57.68},{52.55,59.37},{51.74,58.1},{51.48,58.85},{52.36,59.6},{52.26,57.77},{52.59,58.97},{52.22,57.14}},
                [zoneIDs.THUNDER_BLUFF]={{71.24,27.05},{71.58,27.15},{72,26.37},{71.12,25.74},{71.02,26.7},{54.95,52.01},{54.94,52.23},{54.96,51.85},{54.94,52.44},{54.96,50.34},{54.97,50.73},{54.96,50.53}},
                [zoneIDs.DARNASSUS]={{37.7,30.95},{38.36,30.77},{37.92,30.03},{37.65,30.38},{38.1,31.1},{38.28,30.2},{63.54,48.49},{63.28,48.49},{62.69,51.75},{63.57,51.71},{64.14,51.73},{62.9,48.49},{63.86,51.73},{64.14,48.48},{62.51,48.48},{63.29,51.71}},
                [zoneIDs.SILVERMOON_CITY]={{74.21,83.71},{73.64,82.59},{74.18,84.25},{73.8,82.87},{73.8,84.15},{73.4,83.33},{73.25,83.03}},
                [zoneIDs.THE_EXODAR]={{73.45,57.46},{73.74,57.47},{72.76,58.39},{72.76,57.4},{73.72,58.28},{72.49,57.91},{73.42,58.29}},
                [zoneIDs.SHATTRATH_CITY]={{49.51,38.51},{49.6,37.94},{48.95,36.76},{53.44,34.09},{53.6,35.17},{48.48,37.29},{49.11,38.5},{48.65,37.65},{53.36,33.65},{52.81,33.86},{53.37,35.63},{49.12,37.06},{52.88,34.3},{53.05,35.32}},
                [zoneIDs.DALARAN]={{49.13,45.4},{49.96,45.29},{48.48,44.82},{50.41,44.76},{50.52,44.51},{48.76,45.12},{48.3,44.58}},
                [zoneIDs.ELWYNN_FOREST]={{34.66,50.42},{34.39,50.64},{34.72,51.01},{34.61,51.07},{34.81,50.72},{34.36,50.83},{34.75,50.58},{34.48,51.05},{34.47,50.43}},
            },
        },
        [180772] = { -- Cluster Launcher
            [objectKeys.spawns] = {
                [zoneIDs.MOONGLADE]={{63.68,62.35},{64.6,60.44},{36.74,56.71},{37.32,58.85},{48.78,34.52},{47.91,33.35},{37.15,57.61},{35.88,58.39},{44.2,47.15},{35.87,57.31},{53.79,36.8},{36.77,59.74},{36.44,59.26},{44.97,42.58},{54.05,36.87},{36.05,59.5},{37.16,59.96},{54.29,36.93},{53.5,36.74},{37.92,58.14},{36.43,57.61},{45.25,38.5},{53.23,36.66},{35.48,59.15},{50.92,37.23},{47.66,34.75}},
                [zoneIDs.UNDERCITY]={{66.56,37.19},{65.46,37.17},{80.84,57.87},{74.88,66.58},{58.43,64.13},{56.96,25.43},{57.38,66.88},{57.82,63.6},{73.87,63.84},{81.18,56.96},{76.71,27.62},{56.39,26.07},{78.68,26.13},{56.75,66.35},{77.21,28.36},{73.24,64.33},{50.97,57.45},{78.21,25.35},{50.61,56.53}},
                [zoneIDs.STORMWIND_CITY]={{55.79,42.53},{62.43,50.51},{54.7,69.26},{46.63,58.06},{55.61,43.52},{68.88,65.66},{46.18,58.04},{56.31,41.7},{46.36,58.39},{55.09,68.55},{54.66,68.62},{55.13,43.53},{54.85,43.93},{55.57,42.87},{62.62,51.62},{62.35,49.94},{68.52,65.28},{55.12,69.2},{68.46,64.42},{69.13,65.14},{55.15,69.79},{56.26,42.45},{56.02,42.12},{56.55,41.36},{56.03,42.86},{54.64,68.04},{62.74,49.8}},
                [zoneIDs.IRONFORGE]={{31.14,15.12},{28.84,17.94},{31.75,19.74},{31.36,17.51},{30.36,18.71},{65.43,26.28},{64.26,24.08},{63.88,23.38},{63.49,22.7}},
                [zoneIDs.ORGRIMMAR]={{51.61,59.8},{52.67,57.56},{52.14,57.26},{52.53,57.06},{52.27,59.42},{52.4,58.97},{52.34,57.83},{51.45,58.02},{51.69,58.88},{51.56,56.92}},
                [zoneIDs.THUNDER_BLUFF]={{54.96,50.53},{54.95,50.95},{54.96,50.34},{54.94,52.23},{54.97,50.73},{54.95,52.01},{71.4,25.41},{72.05,25.95}},
                [zoneIDs.DARNASSUS]={{62.51,48.48},{63.29,51.71},{62.99,51.73},{63.82,48.48},{64.14,48.48},{63.86,51.73},{64.14,51.73},{62.9,48.49},{63.54,48.49},{38.15,30.87},{38.09,30.26}},
                [zoneIDs.SILVERMOON_CITY]={{74.2,83.21},{73.4,84}},
                [zoneIDs.THE_EXODAR]={{72.99,56.96},{73,58.72}},
                [zoneIDs.SHATTRATH_CITY]={{53.75,34.68},{48.74,38.39},{49.58,37.43},{52.77,35}},
                [zoneIDs.DALARAN]={{50.15,45.12},{48.93,45.25}},
                [zoneIDs.ELWYNN_FOREST]={{34.7,50.81},{34.49,50.86},{34.57,50.58}},
            },
        },		
        [181148] = { -- Mummified Troll Remains
            [objectKeys.spawns] = {[zoneIDs.GHOSTLANDS] = {{62.62,32.58},{61.03,30.84},{58.59,27.51},{58.44,28.21},{64.19,28.26},{63.52,31.74},{62.37,31.34},{63.96,28.97},{64.43,28.28},{64.69,28.93},{64.94,28.96},{65.67,28.89},{65.91,28.26},{61.26,27.43},{58.81,28.72},{59.08,28.35},{58.62,28.47},{65.42,28.25},{60.3,30.84},{58.75,27.8},{59.76,27.54},{65.17,28.27},{65.92,28.88},{65.43,28.91},{58.31,27.9},{62.39,32.25},{62.3,31.8},{62.92,32.59},{63.23,32.56},{63.43,31.29},{62.59,30.99},{63.22,30.97},{63.45,32.21},{63.71,28.96},{63.69,28.27},{65.18,28.91},{65.66,28.24},{64.94,28.26},{64.68,28.33},{64.45,28.98},{63.94,28.29},{63.14,30.71},{61.84,30.34},{61.86,27.93},{61.86,29.98},{61.5,27.43},{61.85,29.61},{61.81,29.24},{61.28,30.84},{61.52,30.83},{61.01,27.51},{59.8,30.87},{60.05,30.88},{59.25,30.05},{59.23,30.41},{60.02,27.55},{59.22,28.03},{59.25,29.67},{59.22,29.32},{59.53,27.57},{58.91,28.06},{59.55,30.9}}},
        },
        [181151] = { -- Glistening Mud
            [objectKeys.spawns] = {[zoneIDs.GHOSTLANDS] = {{73.5,21.1},{73.7,22.23},{73.71,21.51},{73.43,22.85},{72.78,23.65},{73.42,24.66},{71.44,22.18},{70.17,22.01},{71.3,15.25},{70.63,13.7},{71.17,13.77},{72.79,26.41},{72.56,27.62},{71.99,28.39},{71.26,29.02},{69.94,19.86},{69.59,18.8},{70.45,17.2},{73.49,18.42},{71.1,15.37}}},
        },
        [181250] = { -- Raw Meat Rack
            [objectKeys.spawns] = {[zoneIDs.GHOSTLANDS] = {{65.11,66.74}}},
        },
        [181251] = { -- Smoked Meat Rack
            [objectKeys.spawns] = {[zoneIDs.GHOSTLANDS] = {{63.03,74.99}}},
        },
        [181252] = { -- Fresh Fish Rack
            [objectKeys.spawns] = {[zoneIDs.GHOSTLANDS] = {{68.24,57.78}}},
        },
        [181597] = { -- Silithyst Mound
            [objectKeys.spawns] = {},
        },
        [181598] = { -- Silithyst Geyser
            [objectKeys.spawns] = {[zoneIDs.SILITHUS] = {{18.8,80.4},{25.6,76.7},{27.2,72.1},{28.9,73},{30.4,70.5},{30.58,76.64},{33.67,73.11},{34.52,69.41},{35.01,64.8},{36.3,22.8},{37.18,62.94},{37.8,26},{37.84,59.34},{38.01,29.99},{38.4,66.4},{39.7,33.8},{40.4,21.4},{40.9,26.1},{41,65.6},{41.7,60.1},{41.9,36.2},{42,28.9},{42.4,69.7},{42.5,83.6},{43,75.7},{43.1,64.3},{43.5,25.7},{43.5,77},{43.74,60.8},{44.4,72.4},{44.9,30.1},{45.27,22.34},{45.2,80.8},{46.3,69.3},{46.4,66.1},{46.51,72.47},{46.7,26.4},{47.4,74.9},{47.7,39.2},{48.54,31.14},{48.4,69.3},{49.1,76.4},{50,50},{50.7,77},{51.1,72.4},{51.6,43.3},{51.7,46.9},{52.89,76.2},{53.23,41.64},{54.3,46.8},{57.18,47.23},{57.8,51.1},{59,49.5},{60,41},{60.8,46.1},{61.84,53.6},{62.2,44.8},{62.57,42.58},{63.1,57.1},{64.9,54.5},{65.55,59.42},{65.74,41.31},{66,63.9},{67.2,42.2}}},
        },
        [181758] = { -- Mound of Dirt
            [objectKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE] = {{61.17,49.64}}},
        },
        [181781] = { -- Axxarien Crystal
            [objectKeys.name] = "Axxarien Crystal",
        },
        [181892] = { -- Aquatic Stinkhorn
            [objectKeys.spawns] = {[zoneIDs.BLOODMYST_ISLE] = {{64.48,62.54},{61.04,68.68},{57.86,73.45},{57.24,75.25},{56.02,79.56},{55.09,82.45},{54.99,81.9},{61.35,67.99},{56.75,79.14},{58.17,72.75},{57.41,75.72},{66.2,59.95}}},
        },
        [185309] = { -- Altar of Goc
            [objectKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{64.15,18.5}}},
        },
        [186273] = { -- Damaged Diving Gear
            [objectKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH] = {{62.64,18.23},{62.33,18.88},{61.68,18.19}}},
        },
        [187922] = { -- Alliance Bonfire - Burning Steppes
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{68.57,60.2}}},
        },
        [187929] = { -- Alliance Bonfire - Feralas
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{46.66,43.72}}},
        },
        [187965] = { -- Horde Bonfire - Mulgore
            [objectKeys.spawns] = {[zoneIDs.MULGORE]={{51.93,59.46}}},
        },
        [188418] = { -- Wanted!
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{37.68,46.55}}},
        },
        [189989] = { -- Dark Iron Mole Machine Wreckage
            [objectKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{56.01,37.07}}},
        },
        [189990] = { -- Dark Iron Mole Machine Wreckage
            [objectKeys.spawns] = {[zoneIDs.DUROTAR]={{40.64,17.47}}},
        },
        [190034] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TELDRASSIL]={{55.36,52.28}}},
        },
        [190036] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{54.49,50.77}}},
        },
        [190040] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{60.5,75.34}}},
        },
        [190046] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.REDRIDGE_MOUNTAINS]={{26.46,41.5}}},
        },
        [190050] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{40.53,17.69}}},
        },
        [190051] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DESOLACE]={{66.33,6.59}}},
        },
        [190052] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{66.6,45.27}}},
        },
        [190053] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{46.33,45.19}}},
        },
        [190054] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_HINTERLANDS]={{14.19,44.6}}},
        },
        [190064] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DUROTAR]={{51.54,41.58}}},
        },
        [190065] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.MULGORE]={{46.78,60.41}}},
        },
        [190066] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES]={{60.99,51.41}}},
        },
        [190067] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.EVERSONG_WOODS]={{48.2,47.88}}},
        },
        [190068] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.EVERSONG_WOODS]={{43.7,71.03}}},
        },
        [190069] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{53.92,78.93}}},
        },
        [190070] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THUNDER_BLUFF]={{45.62,64.92}}},
        },
        [190074] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST]={{46.45,42.9}}},
        },
        [190076] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_BARRENS]={{49.51,57.9}}},
        },
        [190078] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.HILLSBRAD_FOOTHILLS]={{57.85,47.27}}},
        },
        [190079] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ASHENVALE]={{73.96,60.6}}},
        },
        [190080] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{50.38,63.8}}},
        },
        [190082] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS]={{69.02,33.27}}},
        },
        [190084] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE]={{37.38,51.78}}},
        },
        [190086] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SWAMP_OF_SORROWS]={{46.87,56.93}}},
        },
        [190088] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{74.83,45.14}}},
        },
        [190089] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_HINTERLANDS]={{78.19,81.47}}},
        },
        [190090] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{56.81,37.44}}},
        },
        [190091] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.HELLFIRE_PENINSULA]={{26.89,59.47}}},
        },
        [190096] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ZANGARMARSH]={{30.62,50.87}}},
        },
        [190097] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST]={{48.73,45.17}}},
        },
        [190098] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.NAGRAND]={{56.68,34.48}}},
        },
        [190099] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{53.43,55.55}}},
        },
        [190100] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BLADES_EDGE_MOUNTAINS]={{76.22,60.39}}},
        },
        [190101] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SHADOWMOON_VALLEY]={{30.27,27.69}}},
        },
        [190102] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_BARRENS]={{67.34,74.66}}},
        },
        [190103] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN]={{40.95,73.74}}},
            [objectKeys.zoneID] = zoneIDs.THE_CAPE_OF_STRANGLETHORN,
        },
        [190104] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DUSTWALLOW_MARSH]={{41.86,74.09}}},
        },
        [190105] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TANARIS]={{52.55,27.1}}},
        },
        [190106] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.WINTERSPRING]={{59.83,51.21}}},
        },
        [190107] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SILITHUS]={{55.47,36.79}}},
        },
        [190108] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{75.57,52.3}}},
        },
        [194070] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{30.92,37.16}}},
        },
        [194071] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DALARAN]={{48.15,41.31}}},
        },
        [194072] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_UNDERBELLY]={{38.22,59.57}}},
            [objectKeys.zoneID] = zoneIDs.THE_UNDERBELLY,
        },
        [194080] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS]={{67.65,50.69}}},
        },
        [194081] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DALARAN]={{66.85,29.6}}},
        },
        [194102] = { -- Shatterspear Armaments
            [objectKeys.spawns] = {[141]={{90.96,99.06},{87.07,99.87},{91.69,98.44}},[148]={{62.81,7.27},{62.38,7.8},{63.28,10.48},{61.29,10.61},{61.2,7.71},{63.53,8.07},{63.21,8.92},{61.96,8.94},{61.52,9.23},{61.38,9.81},{62.9,10.82},{62.76,11.37},{62.06,11.44},{62.2,8.98},{61.66,9.22},{63.08,9.56},{62.78,9.64},{61.94,9.95},{61.89,11.07}}},
        },
        [194238] = { -- Blade of Drak'Mar
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{93.19,25.98}}},
        },
        [195365] = { -- Energy Conduit
            [objectKeys.spawns] = {[zoneIDs.AZSHARA] = {{55.74,14.76},{56.28,13.52},{56.89,14.35},{57.57,11.7},{55.5,10.53},{56.17,11.07}}},
        },
        [195492] = { -- Kaja'mite Chunk
            [objectKeys.spawns] = {[zoneIDs.KEZAN]={{57.4,99.51},{60.23,99.83},{77.28,86.03},{78.67,84.77},{78.65,86.94},{80.2,89.35},{68.99,83.12},{64.46,83.48},{66.56,84.01},{66.03,87.42},{67.22,77.64},{69.64,79.33},{77.22,85.91},{63.89,92.22},{63.87,89.37},{63.38,95.11},{72.87,72.8},{72.24,69.93},{72.17,75.36},{74.68,71.35},{72.28,85.55},{73.59,69.35},{70.44,87.2},{73.92,84.08},{72.72,80.01},{72.65,78.12},{71.13,76.9}}},
        },
        [195602] = { -- Animate Besalt Chunk
            [objectKeys.spawns] = {[zoneIDs.AZSHARA]={{46.6,16.4},{47.4,16.7},{47.8,17.4},{48.1,17.9},{48.3,18.5},{48.6,18.4},{49.1,18.8},{49.4,19.6},{49.5,19.3},{49.9,19.9},{50.9,20.5},{51.3,20.2},{51.5,20.2},{52.5,20.3},{52.9,20.8},{53.7,21.1},{53.7,21.5}}},
        },
        [195622] = { -- Kaja'mite Ore
            [objectKeys.spawns] = {[zoneIDs.THE_LOST_ISLES]={{31.76,73.52}}},
        },
        [196393] = { -- Broken Relic
            [objectKeys.spawns] = {[zoneIDs.DESOLACE]={{27.22,63.35}}},
        },
        [196472] = { -- Grandma's Good Clothes
            [objectKeys.spawns] = {[zoneIDs.GILNEAS]={{32.03,75.45}}},
        },
        [197196] = { -- Waters of Farseeing
            [objectKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{41.71,47.5}},
                [zoneIDs.ORGRIMMAR] = {{50.9,37.9}},
            }
        },
        [201743] = { -- Field Banner
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS] = {{49.42,54.04},{46.37,47.23},{46.29,56.75}}},
        },
        [201744] = { -- Horde Field Banner
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS] = {{49.42,54.04},{46.37,47.23},{46.29,56.75}}},
        },
        [201974] = { -- Raptor Egg
            [objectKeys.spawns] = {[zoneIDs.THE_LOST_ISLES] = {{47.32,74.75},{53.56,72.47},{50.67,74.99},{48.78,75.77},{50.19,73.17},{47.74,72.83},{49.24,73.88},{46.7,71.89},{52.34,69.56},{52.9,68.11},{53.43,70.49},{50.64,68.34},{50.46,69.96},{49.07,62.85},{50.19,63.86},{50.25,65.79},{49.33,64.54},{51.54,65.54},{51.7,67.45},{49.67,69.15},{47.63,68.45},{45.93,69.88},{48.47,67.66},{47.67,70.16}}},
        },
        [201977] = { -- The Biggest Egg Ever
            [objectKeys.spawns] = {[zoneIDs.THE_LOST_ISLES] = {{43.78,56.02}}},
        },
        [202065] = { -- Dweller's Crate
            [objectKeys.name] = "Dweller's Crate",
        },
        [202418] = { -- Quilboar Restraint -- needs locale translations
            [objectKeys.name] = "Quilboar Restraint",
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{53.15,46.63}}},
            [objectKeys.zoneID] = zoneIDs.SOUTHERN_BARRENS,
        },
        [202419] = { -- Quilboar Restraint -- needs locale translations
            [objectKeys.name] = "Quilboar Restraint",
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{53.1,46.7}}},
            [objectKeys.zoneID] = zoneIDs.SOUTHERN_BARRENS,
        },
        [202460] = { -- Alliance Field Banner
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS] = {{49.42,54.04},{46.37,47.23},{46.29,56.75}}},
        },
        [202574] = { -- Blastshadow's Soulstone
            [objectKeys.spawns] = {[zoneIDs.THE_LOST_ISLES] = {{55.36,31.64},{55.52,31.87},{55.23,33.08},{53.69,37.14}}},
        },
        [202596] = { -- Frazzlecraz Explosives -- needs locale translations
            [objectKeys.name] = "Frazzlecraz Explosives",
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS] = {{39.84,73.85},{40.03,73.9},{39.97,74.29},{40.28,74.07},{40.28,74.52},{40.02,74.54},{39.67,74.54},{39.89,74.87},{40.05,75.16},{39.55,75.71},{39.99,75.89},{39.7,76.16},{39.37,76.58},{39.64,76.57},{39.9,76.47},{40.27,76.59},{40.22,76.95}}},
            [objectKeys.zoneID] = zoneIDs.SOUTHERN_BARRENS,
        },
        [203092] = { -- Portal Rune - Fully added here, because we don't scrape "objectType = button" objects
            [objectKeys.name] = "Portal Rune",
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{31.64,46.03},{32.03,45.79},{31.68,46.61},{32.36,46.16},{31.92,46.92}}},
            [objectKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [203134] = { -- Empty Pedestal
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{65.92,62.88}}},
        },
        [203312] = { -- Coil of Kvaldir Rope
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{56.12,85.89},{55.28,86.21},{55.94,86.92},{58.18,85.92},{55.81,86.03},{58.9,86.11},{56.44,89.27},{57.26,89.64},{56.92,88.93},{57.49,84.87},{52.2,85.53},{50.68,85.34},{48.9,78.83},{47.77,80.3},{52.08,82.99},{52.46,83.77},{51.84,80.56},{51.65,85.05},{50.57,84.95},{51.87,85.31},{51.26,85.24}}},
        },
        [203403] = { -- Survival Kit Remnants
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{56.56,80.29}}},
            [objectKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
        },
        [204091] = { -- Induction Samophlange
            [objectKeys.spawns] = {[zoneIDs.AZSHARA]={{55.28,49.89}}},
        },
        [204279] = { -- Spool of Rope
            [objectKeys.spawns] = {[zoneIDs.DEEPHOLM]={{61.79,46.28}}},
            [objectKeys.waypoints] = waypointPresets.ALLIANCE_GUNSHIP,
        },
        [204280] = { -- Bottle of Whiskey
            [objectKeys.spawns] = {[zoneIDs.DEEPHOLM]={{61.79,46.28}}},
            [objectKeys.waypoints] = waypointPresets.ALLIANCE_GUNSHIP,
        },
        [204281] = { -- Worm Mound
            [objectKeys.spawns] = {[1519]={{49.24,18.03},{52.53,14.86},{64.01,16.59},{63.39,5.73},{64.93,8.47},{56.45,22.58},{55.73,16.51},{53.73,19.56},{60.51,6.85},{58.05,10.49},{62.12,17.65},{59.07,20.64}}},
        },
        [204360] = { -- Monstrous Clam
            [objectKeys.spawns] = {[14]={{59.03,14.08},{59.42,9.93},{59.37,12.45},{58.24,11.4},{58.08,13.54},{57.51,10.09},{56.24,9.64},{58.2,3.99},{58.96,5.17},{58.49,6.23},{56.88,6.68},{58.26,8.28}}},
        },
        [205016] = { -- Bonfire
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES]={{62.24,68.02}}},
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
        },
        [205876] = { -- Argent Portal
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{78.58,73.03}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [205877] = { -- Argent Portal
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{77.86,70.85}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [206111] = { -- Hero's Call Board -- Stormwind AH
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{62.86,71.49}}},
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [objectKeys.questStarts] = {27724,27726,27727,28551,28552,28558,28562,28563,28564,28576,28578,28579,28582,28666,28673,28675,28699,28702,28708,28709,28716,28825,29156,29387,29391},
        },
        [206294] = { -- Hero's Call Board -- Stormwind North
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{62.23,29.86}}},
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [objectKeys.questStarts] = {27724,27726,27727,28551,28552,28558,28562,28563,28564,28576,28578,28579,28582,28666,28673,28675,28699,28702,28708,28709,28716,29156,29387,29391},
        },
        [206320] = { -- Wild Black Dragon Egg
            [objectKeys.spawns] = {[zoneIDs.BADLANDS]={{73.72,48.82},{65.32,53.65},{64.59,49.09},{72.68,49.58},{65.05,50.85},{65.15,47.31},{66.58,45.8},{67.55,45.7},{67.91,44.59},{68.99,42.67},{72.69,39.42},{73.41,42.84},{69.16,53.41},{71.04,53.64},{69.52,37.81},{69.35,39.53},{68.29,43.55},{74.12,44.57},{71.49,49.73},{73.73,43.71},{71.25,52.02},{70.28,54.17},{73.16,41.22},{74.84,46.06},{74.4,47.56},{72.22,38.14},{70.61,37.55},{68.97,41.04}}},
        },
        [206550] = { -- The Sun
            [objectKeys.spawns] = {[zoneIDs.BADLANDS] = {{49.13,57.28},{54.02,46.75},{17.07,65.65},{14.32,53.07},{22.85,47.96},{35.5,50.75},{27.27,38.97},{33.84,36.98},{28.34,58.8},{39.33,59.84},{44.18,35.91}}},
            [objectKeys.zoneID] = zoneIDs.BADLANDS,
        },
        [206573] = { -- Dark Ember
            [objectKeys.spawns] = {[zoneIDs.SEARING_GORGE] = {{53.44,44.82}}},
        },
        [206585] = { -- Totem of Ruumbo
            [objectKeys.questStarts] = {27989,27994,27995},
            [objectKeys.questEnds] = {27989,27994,28100},
        },
        [206971] = { -- War Reaver Parts
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{44.13,37.25},{45.62,32.83},{44.05,34.97},{42.84,37.48},{47.51,37.38},{46.39,40.27},{52.32,34.98},{52.28,35.06},{48.14,36.25},{43.81,38.37},{45.27,41.07},{50.99,42.54},{56.58,38.14},{56.4,37.16},{55.74,40.64},{57.21,40.87},{57.35,35.98},{60.52,35.83},{53.36,40.15},{54.42,39.82},{49.05,37.28},{44.68,41.44},{48.09,35.18},{49.84,35.59},{48.24,38.21},{53.14,34.37},{52.13,35.05},{45.97,39.73},{43.17,38.45},{55.38,36.23},{55.7,39.96},{57.6,40.83}}},
        },
        [206972] = { -- War Reaver Parts
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{44.13,37.25},{45.62,32.83},{44.05,34.97},{42.84,37.48},{47.51,37.38},{46.39,40.27},{52.32,34.98},{52.28,35.06},{48.14,36.25},{43.81,38.37},{45.27,41.07},{50.99,42.54},{56.58,38.14},{56.4,37.16},{55.74,40.64},{57.21,40.87},{57.35,35.98},{60.52,35.83},{53.36,40.15},{54.42,39.82},{49.05,37.28},{44.68,41.44},{48.09,35.18},{49.84,35.59},{48.24,38.21},{53.14,34.37},{52.13,35.05},{45.97,39.73},{43.17,38.45},{55.38,36.23},{55.7,39.96},{57.6,40.83}}},
        },
        [206973] = { -- War Reaver Parts
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{44.13,37.25},{45.62,32.83},{44.05,34.97},{42.84,37.48},{47.51,37.38},{46.39,40.27},{52.32,34.98},{52.28,35.06},{48.14,36.25},{43.81,38.37},{45.27,41.07},{50.99,42.54},{56.58,38.14},{56.4,37.16},{55.74,40.64},{57.21,40.87},{57.35,35.98},{60.52,35.83},{53.36,40.15},{54.42,39.82},{49.05,37.28},{44.68,41.44},{48.09,35.18},{49.84,35.59},{48.24,38.21},{53.14,34.37},{52.13,35.05},{45.97,39.73},{43.17,38.45},{55.38,36.23},{55.7,39.96},{57.6,40.83}}},
        },
        [206974] = { -- War Reaver Parts
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{44.13,37.25},{45.62,32.83},{44.05,34.97},{42.84,37.48},{47.51,37.38},{46.39,40.27},{52.32,34.98},{52.28,35.06},{48.14,36.25},{43.81,38.37},{45.27,41.07},{50.99,42.54},{56.58,38.14},{56.4,37.16},{55.74,40.64},{57.21,40.87},{57.35,35.98},{60.52,35.83},{53.36,40.15},{54.42,39.82},{49.05,37.28},{44.68,41.44},{48.09,35.18},{49.84,35.59},{48.24,38.21},{53.14,34.37},{52.13,35.05},{45.97,39.73},{43.17,38.45},{55.38,36.23},{55.7,39.96},{57.6,40.83}}},
        },
        [207162] = { -- Crate of Fine Cloth
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS] = {{80.78,29.09}}},
            [objectKeys.waypoints] = {[zoneIDs.TWILIGHT_HIGHLANDS] = {{{73.69,52.50},{73.23,52.59},{72.21,52.53},{71.32,51.62},{70.61,50.03},{70.43,48.73},{70.44,47.08},{70.59,45.07},{70.76,43.60},{70.99,41.88},{71.24,40.05},{71.49,38.21},{71.71,36.51},{71.87,34.99},{72.02,33.05},{72.09,31.44},{72.09,29.95},{72.04,28.35},{71.89,26.64},{71.67,24.97},{71.45,23.37},{71.23,21.62},{71.00,19.88},{70.88,18.34},{71.05,16.48},{71.66,15.10},{72.79,14.50},{73.94,14.23},{75.09,14.03},{76.18,14.47},{76.64,14.85},{76.66,14.87},{77.31,15.28},{78.36,16.28},{78.92,17.55},{79.36,18.90},{79.77,20.57},{80.14,22.60},{80.34,24.12},{80.50,25.68},{80.65,27.38},{80.79,29.16},{80.91,30.98},{81.02,32.79},{81.13,34.53},{81.24,36.27},{81.39,38.10},{81.54,39.96},{81.67,41.80},{81.75,43.53},{81.75,45.10},{81.65,46.47},{81.24,48.18},{80.50,49.45},{79.58,50.30},{78.58,50.99},{77.52,51.59},{76.29,52.00},{75.06,52.26},{74.02,52.44},{73.69,52.50}}}},
        },
        [207320] = { -- Hero's Call Board -- Ironforge
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE] = {{25.46,69.78}}},
            [objectKeys.zoneID] = zoneIDs.IRONFORGE,
            [objectKeys.questStarts] = {26542,27724,27726,27727,28558,28565,28567,28573,28576,28578,28579,28582,28666,28673,28675,28708,28709,28716},
        },
        [207321] = { -- Hero's Call Board -- Darnassus
            [objectKeys.spawns] = {[zoneIDs.DARNASSUS] = {{44.88,49.95}}},
            [objectKeys.zoneID] = zoneIDs.DARNASSUS,
            [objectKeys.questStarts] = {27724,27726,27727,28490,28492,28503,28507,28511,28525,28528,28531,28539,28543,28544,28550,28552,28558,28708,28709,28716,29156,29387,29391},
        },
        [207322] = { -- Hero's Call Board -- Exodar
            [objectKeys.spawns] = {[zoneIDs.THE_EXODAR] = {{55.36,47.23}}},
            [objectKeys.zoneID] = zoneIDs.THE_EXODAR,
            [objectKeys.questStarts] = {27724,27726,27727,28492,28503,28507,28511,28525,28528,28531,28539,28543,28544,28550,28552,28558,28559,28708},
        },
        [207327] = { -- Pip's Mole Machine
            [objectKeys.name] = "Pip's Mole Machine",
        },
        [207328] = { -- Pip's Mole Machine
            [objectKeys.name] = "Pip's Mole Machine",
        },
        [207381] = { -- Deep Alabaster Crystal Chunk
            [objectKeys.spawns] = {},
        },
        [207382] = { -- Deep Celestite Crystal Chunk
            [objectKeys.spawns] = {},
        },
        [207383] = { -- Deep Amethyst Crystal Chunk
            [objectKeys.spawns] = {},
        },
        [207384] = { -- Deep Garnet Crystal Chunk
            [objectKeys.spawns] = {},
        },
        [208115] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DARKSHORE]={{50.8,18.9}}},
        },
        [208116] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{51.07,17.81}}},
        },
        [208118] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ASHENVALE]={{38.65,42.34}}},
        },
        [208119] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ASHENVALE]={{13,34.1}}},
        },
        [208120] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ARATHI_HIGHLANDS]={{40.06,49.09}}},
        },
        [208121] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BADLANDS]={{20.87,56.31}}},
        },
        [208122] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BLASTED_LANDS]={{60.69,14.07}}},
        },
        [208123] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BLASTED_LANDS]={{44.34,87.6}}},
        },
        [208124] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.LOCH_MODAN]={{83.02,63.53}}},
        },
        [208125] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE]={{53.16,66.98}}},
        },
        [208126] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SWAMP_OF_SORROWS]={{28.93,32.4}}},
        },
        [208127] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_HINTERLANDS]={{66.16,44.43}}},
        },
        [208128] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{60.35,58.24}}},
        },
        [208129] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{79.48,78.54},{78.87,77.8}}},
        },
        [208130] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{49.6,30.36}}},
        },
        [208131] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{43.5,57.27}}},
        },
        [208132] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ABYSSAL_DEPTHS]={{54.67,72.11}}},
        },
        [208133] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{49.72,57.39}}},
        },
        [208134] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.WESTERN_PLAGUELANDS]={{43.38,84.38}}},
        },
        [208135] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.WETLANDS]={{58.21,39.2}}},
        },
        [208136] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.WETLANDS]={{26.06,25.99}}},
        },
        [208137] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BADLANDS]={{65.85,35.64}}},
        },
        [208138] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SEARING_GORGE]={{39.48,66.02}}},
        },
        [208139] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SWAMP_OF_SORROWS]={{71.65,14.1}}},
        },
        [208140] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.AZSHARA]={{57.11,50.16}}},
        },
        [208141] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KELP_THAR_FOREST]={{63.5,60.17}}},
        },
        [208142] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{49.18,41.87}}},
        },
        [208143] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BADLANDS]={{18.36,42.73}}},
        },
        [208144] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.BLASTED_LANDS]={{40.47,11.28}}},
        },
        [208145] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.HILLSBRAD_FOOTHILLS]={{60.26,63.74}}},
        },
        [208146] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST]={{44.3,20.28}}},
        },
        [208147] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN]={{35.04,27.21}}},
        },
        [208148] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_HINTERLANDS]={{31.8,57.86}}},
        },
        [208149] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES]={{83.05,72.07}}},
        },
        [208150] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{53.39,42.84}}},
        },
        [208151] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{45.11,76.82}}},
        },
        [208152] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{75.36,54.93}}},
        },
        [208153] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{75.41,16.54}}},
        },
        [208154] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{51.48,62.39}}},
        },
        [208155] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ABYSSAL_DEPTHS]={{51.34,60.54}}},
        },
        [208156] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.WESTERN_PLAGUELANDS]={{48.28,63.65}}},
        },
        [208157] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DESOLACE]={{56.72,50.12}}},
        },
        [208158] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FELWOOD]={{44.59,28.99}}},
        },
        [208159] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FELWOOD]={{61.86,26.71}}},
        },
        [208160] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{41.45,15.69}}},
        },
        [208161] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.FERALAS]={{51.97,47.63}}},
        },
        [208162] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{63.05,24.14}}},
        },
        [208163] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{18.62,37.32}}},
        },
        [208164] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{42.67,45.71}}},
        },
        [208165] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_BARRENS]={{56.2,40.03}}},
        },
        [208166] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_BARRENS]={{62.5,16.6}}},
        },
        [208167] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{39.29,20.09}}},
        },
        [208168] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{40.7,69.31}}},
        },
        [208169] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{39.02,10.99}}},
        },
        [208170] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{65.6,46.54}}},
        },
        [208171] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SOUTHERN_BARRENS]={{49.04,68.5}}},
        },
        [208172] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{66.5,64.19}}},
        },
        [208173] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{71.02,79.08}}},
        },
        [208174] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{59.04,56.32}}},
        },
        [208175] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{39.48,32.81}}},
        },
        [208176] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{31.53,60.66}}},
        },
        [208177] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TANARIS]={{55.7,60.97}}},
        },
        [208178] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ULDUM]={{26.58,7.24}}},
        },
        [208179] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.ULDUM]={{54.68,33.01}}},
        },
        [208180] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{55.26,62.12}}},
        },
        [208181] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.DEEPHOLM]={{51.19,49.9}}},
        },
        [208316] = { -- Hero's Call Board -- Dalaran
            [objectKeys.spawns] = {[zoneIDs.DALARAN] = {{37.41,63.21}}},
            [objectKeys.zoneID] = zoneIDs.DALARAN,
            [objectKeys.questStarts] = {29071},
            [objectKeys.questEnds] = {29071},
        },
        [208317] = { -- Warchief's Command Board -- Dalaran
            [objectKeys.spawns] = {[zoneIDs.DALARAN] = {{58.8,27.49}}},
            [objectKeys.zoneID] = zoneIDs.DALARAN,
        },
        [208376] = { -- Direhammer's Boots
            [objectKeys.name] = "Direhammer's Boots",
            [objectKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE] = {{76.05,66.49}}},
            [objectKeys.zoneID] = zoneIDs.STRANGLETHORN_VALE,
        },
        [208442] = { -- Blueroot Vine
            [objectKeys.spawns] = {[616]={{26.85,54.58},{34.19,65.22},{26.47,64.54},{28.84,51.87},{27.95,51.29},{30.21,56.93},{33.57,65.24},{27.32,59.67},{27.13,58.83},{24.57,62.74},{37.74,50.71},{24.97,61.86},{33.15,64.61},{35.17,53.14},{29.55,50.79},{28.53,57.15},{34.19,65.21},{41.84,57.54},{40.56,57.17},{40.54,56.65},{39.90,56.90},{39.36,56.71},{40.17,56.32}}},
        },
        [208551] = { -- Lucifern
            [objectKeys.spawns] = {[zoneIDs.MOLTEN_FRONT] = {{51.9,63.2},{52.51,63.32},{51.83,59.66},{52.47,62.19},{48.87,57.88},{48.37,58.2},{49.86,57.03},{50.08,56.45},{49.71,55.71},{48.04,53.36},{47.6,53.06},{46.9,53.33},{46.96,41.86},{47.41,41.39},{47.8,43.74},{48.98,44.41},{47.3,37.42},{48.28,35.65},{48.35,36.98},{47.48,36.67},{51.26,34.03},{51.71,31.69},{53.13,34.97},{52.77,35.88},{54.21,39.29},{53.48,39.27},{54.64,42.05},{54.83,43.45},{55.03,51.91},{54.51,54.62},{53.82,58.38},{52.23,58.79},{52.27,60.68}}},
        },
        [209058] = { -- Windswept Balloon
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{25.7,61.7},{30.8,61.3},{31.4,68.4},{34.8,73.1},{34.9,67.3},{35.9,49.6},{37.2,77.5},{38.3,86.7},{40,42.7},{40.2,39.8},{40.2,71.9},{40.3,80.7},{42.1,52.5},{43,60.8},{47.7,81.4},{49.4,77.4},{49.9,82.6},{50,84.6},{50.1,68.5},{50.2,49.9},{52.2,39.2},{52.3,49.2},{52.3,66},{52.3,73.9},{52.4,68.8},{52.6,79.7},{53.1,33.1},{53.3,63.2},{53.4,83.8},{53.5,76.2},{53.7,82.7},{53.9,46.4},{53.9,65.3},{55.1,53.2},{56.6,62.6},{56.9,65.3},{57,58.1},{58.4,49.9},{58.9,63.3},{60.4,52.1},{63.6,23.4},{64.9,17},{65.8,24.1},{66.7,39.4},{66.8,13.3},{68.1,36.9},{68.3,50.2},{68.4,30.1},{70.9,48.1},{71.4,35.4}}},
        },
        [209072] = { -- Stolen Crate
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{55.39,43.41}}},
        },
        [209076] = { -- Anson's Crate
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{60.08,75.05},{65.07,33.52}}},
        },
        [209094] = { -- Stolen Crate
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES] = {{65.77,74.8}}},
        },
        [209095] = { -- Edgar's Crate
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{54.47,77.53},{71.75,49.88}}},
        },
        [209242] = { -- Windswept Balloon
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{43,58.4},{46.1,64.8},{47.4,62.3},{50.7,43.3},{52.4,62.9},{55.2,58.7},{56,44.3},{56.4,63.1},{57.8,43},{59.7,68.7},{59.8,35.8},{60.1,69.8},{60.4,73.2},{61,43.2},{61.2,66.5},{61.3,33.4},{61.7,76.9},{62,51.6},{62.6,76.3},{62.8,68.6},{62.9,40.2},{63,28.9},{63,41.8},{63.3,65.6},{64.3,38.8},{64.4,44.4},{64.6,68.3},{64.8,51},{64.9,76.5},{65.6,46.3},{66.2,33.4},{66.8,38.9},{67.3,73.3},{67.9,44.2},{69.6,43.2},{70.4,57.4},{71.6,47.3},{72.9,67.9},{73,61.7},{73.6,54.3},{75.4,56.7},{75.4,64.3},{76.2,61.7}}},
        },
        [278575] = { -- Hero's Call Board -- Twilight Highlands
            [objectKeys.spawns] = {[4922] = {{49.32,30.05,169}}},
            [objectKeys.zoneID] = 4922,
        },
        [281339] = { -- Hero's Call Board -- Deepholm
            [objectKeys.spawns] = {[5042] = {{48.82,53.06,169}}},
            [objectKeys.zoneID] = 5042,
        },
        [300246] = { -- Flat Un'Goro Rock
            [objectKeys.spawns] = {[zoneIDs.UN_GORO_CRATER] = {{70.11,40.95}}},
        },
        [301087] = { -- Fire Portal
            [objectKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS] = {{36.4,83.76}}},
            [objectKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [301111] = { -- Alliance Wickerman
            [objectKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{33.38,48.35}}},
            [objectKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
        },
        [301112] = { -- Horde Wickerman
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES] = {{62.48,68.3}}},
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
        },

        -- Below are fake objects
        -- These objects are from previous expansions and they need updated coords
        [420037] = { -- Chemical Wagon
            [objectKeys.spawns] = {[zoneIDs.DARKSHORE]={{44.17,77.99}}},
        },
        [420038] = { -- Chemical Wagon
            [objectKeys.spawns] = {[zoneIDs.HILLSBRAD_FOOTHILLS]={{34.7,58.2}}},
        },
        [420041] = { -- Chemical Wagon
            [objectKeys.spawns] = {[zoneIDs.WINTERSPRING]={{63.65,49.47}}},
        },

        -- Below are fake objects
        -- For Cata fixes 430001-439999
        [430001] = {
            [objectKeys.name] = "Harpy Signal Fire",
            [objectKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL] = {{32.81,46.53},{35.59,47.3},{36.53,44.72},{38.33,44.18},{49.77,46.3},{44.66,51.24}}},
        },
        [430002] = {
            [objectKeys.name] = "Fossil Archaeology Object",
        },
        [430003] = {
            [objectKeys.name] = "Makeshift Cage",
            [objectKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [objectKeys.spawns] = {[zoneIDs.DUN_MOROGH] = {{37.43,51.86},{37.4,50.15},{33.18,53.23},{31.99,48.64},{34.11,53.54},{36.81,51.81},{34.89,51.89},{34.4,52.17},{33.66,52.11},{33.36,51.43},{36.77,50.89},{32.83,49.93},{33.42,50.07},{36.03,51.78},{34.56,50.42},{35.59,50.61},{36.31,50.26}}},
        },
        [430004] = {
            [objectKeys.name] = "Goblin Detonator",
            [objectKeys.zoneID] = zoneIDs.AZSHARA,
            [objectKeys.spawns] = {[zoneIDs.AZSHARA] = {{14.41,75.74}}},
        },
        [430005] = {
            [objectKeys.name] = "Vision of the Battlemaiden",
            [objectKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE] = {{40.49,75.58}}},
        },
        [430006] = {
            [objectKeys.name] = "Vision of the Battlemaiden",
            [objectKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE] = {{33.1,77.81}}},
        },
        [430007] = {
            [objectKeys.name] = "Vision of the Battlemaiden",
            [objectKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
            [objectKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE] = {{28.92,78.64}}},
        },
        [430008] = {
            [objectKeys.name] = "Flameward",
            [objectKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL] = {{34.78,52.74},{33.04,64.58},{38.31,63.93},{41.83,56.12},{40.51,53.14}}},
        },
        [430009] = {
            [objectKeys.name] = "Rod of Subjugation",
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{23.9,55.9}}},
            [objectKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [430010] = {
            [objectKeys.name] = "Rod of Subjugation",
            [objectKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{25.25,54.8}}},
            [objectKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [430011] = {
            [objectKeys.name] = "Bonfire",
            [objectKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE]={{52.96,66.59}}},
            [objectKeys.zoneID] = zoneIDs.STRANGLETHORN_VALE,
        },
        [430012] = {
            [objectKeys.name] = "Grain Sack",
            [objectKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN]={{54.97,41.94}}},
            [objectKeys.zoneID] = zoneIDs.THE_CAPE_OF_STRANGLETHORN,
        },
        [430013] = {
            [objectKeys.name] = "Sack of Spices",
            [objectKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN]={{33.66,30.18}}},
            [objectKeys.zoneID] = zoneIDs.THE_CAPE_OF_STRANGLETHORN,
        },
        [430014] = {
            [objectKeys.name] = "Krom'gar Elf Killer",
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{73.33,45.12},{73.60,44.81},{73.28,44.77},{73.01,44.96},{72.82,44.35},{73.15,44.49},{73.44,44.34},{72.99,43.75},{73.15,43.53},{73.43,43.39},{73.23,43.15},{73.16,42.86},{73.70,42.65}}},
            [objectKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
        },
        [430015] = {
            [objectKeys.name] = "Mark of the World Tree",
        },
        [430016] = {
            [objectKeys.name] = "Felwood Bee Hive",
            [objectKeys.spawns] = {[zoneIDs.FELWOOD]={{49.03,84.95},{48.74,84.98},{48.58,84.43},{48.34,84.62},{46.92,88.14},{46.52,90.53},{45.78,86.46},{47.34,85.70},{48.19,87.39},{51.19,84.19},{50.76,85.02},{49.94,86.24},{49.74,86.48},{49.12,86.24},{48.73,86.30},{48.75,87.55},{48.83,88.62},{49.46,89.44},{48.89,89.28},{48.29,89.76},{49.08,90.81},{49.00,91.35},{48.47,92.23},{48.23,92.26},{47.74,91.68},{48.35,91.20},{48.35,91.20}}},
            [objectKeys.zoneID] = zoneIDs.FELWOOD,
        },
        [430017] = {
            [objectKeys.name] = "Durnholde Keep Barrel",
            [objectKeys.spawns] = {[zoneIDs.OLD_HILLSBRAD_FOOTHILLS]={{76.60,68.80},{77.14,66.30},{74.68,68.79},{69.09,62.61},{68.03,59.82},{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.OLD_HILLSBRAD_FOOTHILLS,
        },
        [430018] = {
            [objectKeys.name] = "Felwood Rich Soil", -- For Seeking Soil
            [objectKeys.spawns] = {[zoneIDs.FELWOOD]={{50.00,30.20},{48.11,31.21},{49.36,30.67},{48.72,28.15},{48.04,27.57},{47.65,28.81},{48.29,29.18}}},
            [objectKeys.zoneID] = zoneIDs.FELWOOD,
        },
        [430019] = {
            [objectKeys.name] = "Wickerman Ashes",
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES]={{62.5,67.97},{62.41,68},{62.31,67.96},{62.34,68.13},{62.26,68.14},{62.15,68.22},{62.21,68.28},{62.12,68.36},{62.14,68.51}}},
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
        },
        [430020] = {
            [objectKeys.name] = "Chain Lever",
            [objectKeys.spawns] = {[zoneIDs.REDRIDGE_MOUNTAINS]={{27.77,17.94}}},
            [objectKeys.zoneID] = zoneIDs.REDRIDGE_MOUNTAINS,
        },
        [430021] = {
            [objectKeys.name] = "Blackrock Holding Pen",
            [objectKeys.spawns] = {[zoneIDs.REDRIDGE_MOUNTAINS]={{68.92,58.76},{68.98,60.11},{69.8,59.14}}},
            [objectKeys.zoneID] = zoneIDs.REDRIDGE_MOUNTAINS,
        },
        [430022] = {
            [objectKeys.name] = "Ward of Ilgalar",
            [objectKeys.spawns] = {[zoneIDs.REDRIDGE_MOUNTAINS]={{71.94,44.82}}},
            [objectKeys.zoneID] = zoneIDs.REDRIDGE_MOUNTAINS,
        },
        [430023] = {
            [objectKeys.name] = "Cultist Cage",
            [objectKeys.spawns] = {[zoneIDs.WESTERN_PLAGUELANDS]={{64.71,46.24},{67.17,45.51},{68.03,47.98},{67.58,46.85},{64.98,47.89},{65.56,46.69},{65.65,49.15},{66.74,48.84},{67.2,48.55},{66.69,47.04}}},
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
        },
        [430024] = {
            [objectKeys.name] = "Timeless Eye",
            [objectKeys.spawns] = {[zoneIDs.TANARIS]={{57.89,56.05}}},
            [objectKeys.zoneID] = zoneIDs.TANARIS,
        },
        [430025] = {
            [objectKeys.name] = "Timeless Eye",
            [objectKeys.spawns] = {[5786]={{59.2,20.4}},[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [objectKeys.zoneID] = 5786,
        },
        [430026] = {
            [objectKeys.name] = "Kurzen Cage",
            [objectKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE]={{56.40,20.29}}},
            [objectKeys.zoneID] = zoneIDs.STRANGLETHORN_VALE,
        },
        [430027] = {
            [objectKeys.name] = "Horde Cage",
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{67.63,51.45},{67.25,53.3},{64.56,49.23},{68.35,53.69},{65.3,56.49},{64.95,52.27},{66.57,53.9},{66.5,55.83},{67.25,55.27},{65.28,53.48},{64.5,51.04},{65.13,54.72},{64.09,55.68},{66.18,50.51},{66.11,52.09}}},
            [objectKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
        },
        [430028] = {
            [objectKeys.name] = "Huntress Illiona's Cage",
            [objectKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS]={{66.2,54.52}}},
            [objectKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
        },
        [430029] = {
            [objectKeys.name] = "Chemical Wagon", -- Uldum
            [objectKeys.spawns] = {[zoneIDs.ULDUM]={{67.81,19.76},{67.28,18.36},{66.66,19.08},{67.33,20.77},{66.65,20.63}}},
            [objectKeys.zoneID] = zoneIDs.ULDUM,
        },
        [430030] = {
            [objectKeys.name] = "Chemical Wagon", -- Duskwood
            [objectKeys.spawns] = {[zoneIDs.DUSKWOOD]={{75.84,55.61}}},
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
        },
    }
end

function CataObjectFixes:LoadFactionFixes()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    local objectFixesHorde = {
        [180449] = { -- Forsaken Stink Bomb
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{71.9,73.37},{72.97,66.13},{73.77,59.68},{73.62,52.32},{71.2,46.14},{65.58,40.17},{61.68,30.26},{62.75,33.49},{58.73,36.76},{55.11,44.8},{55.47,48.75},{58.21,53.72},{54.01,54.66},{50.43,52.9},{46.47,53.99},{48.12,62.84},{48.34,67.39},{50.01,71.56},{53.45,71.01},{57.88,68.15},{60.17,71.63},{62.18,73.99},{65.23,75.58},{67.4,79.36}}},
        },
        [180743] = { -- Carefully Wrapped Present
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49.29,78.27}}},
        },
        [180746] = { -- Gently Shaken Gift
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49.19,77.75}}},
        },
        [180747] = { -- Gaily Wrapped Present
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49.53,78.1}}},
        },
        [180748] = { -- Ticking Present
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49.19,77.75}}},
        },
        [180793] = { -- Festive Gift
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49.54,77.82}}},
        },
        [186189] = { -- Complimentary Brewfest Sampler
            [objectKeys.spawns] = {[zoneIDs.DUROTAR]={{41.56,17.56},{41.52,17.5},{41.39,17.42},{40.74,16.82},{40.34,16.81},{40.13,17.48},{40.39,18.04},{40.85,18.28},{40.9,18.31}}},
        },
        [186234] = { -- Water Barrel
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES]={{56.63,52.55},{61.02,53.64}},
                [zoneIDs.DUROTAR]={{49.16,44.5},{52.54,41.29}},
                [zoneIDs.EVERSONG_WOODS]={{46.35,55.02},{47.19,46.62}},
            },
        },
        [186887] = { -- Large Jack-o'-Lantern
            [objectKeys.spawns] = {
                [zoneIDs.DUROTAR]={{52.45,42.27}},
                [zoneIDs.TIRISFAL_GLADES]={{60.9,52.72}},
                [zoneIDs.EVERSONG_WOODS]={{47.58,46.24}},
            },
        },
        [187236] = { -- Winter Veil Gift
            [objectKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{49.39,77.62}}},
        },
        [195122] = { -- Forsaken Stink Bomb Cloud
            [objectKeys.spawns] = {[zoneIDs.UNDERCITY]={{83.7,47.97},{81.66,37.08},{77.76,27.23},{64.27,19.51},{54.97,24.69},{51.59,31.68},{49.66,41.7},{51.01,53.73},{56.21,63.97},{63.71,68.2},{71.03,63.23},{78.75,59.37},{84.11,52.19},{71.06,20.77},{65.98,24.28},{66.01,37.53},{67.8,41.42},{64.28,41.54},{63.66,47.05},{67.2,47.66},{69.54,38.78},{68.4,33.68},{63.31,33.81},{59.41,39.68},{58.97,47.16},{62.18,53.13},{67.4,55.15},{71.57,51.18},{73.04,44.58},{71.95,38.48},{65.9,31.49},{62.32,20.03},{57.95,22.51}}},
        },
        [203461] = { -- Fuel Sampling Station
            [objectKeys.spawns] = {[zoneIDs.ABYSSAL_DEPTHS]={{51.49,60.41}}},
        },
        [207125] = { -- Crate of Left Over Supplies
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{54.79,24.41}}},
        },
    }

    local objectFixesAlliance = {
        [180449] = { -- Forsaken Stink Bomb
            [objectKeys.spawns] = {[zoneIDs.UNDERCITY]={{83.7,47.97},{81.66,37.08},{77.76,27.23},{64.27,19.51},{54.97,24.69},{51.59,31.68},{49.66,41.7},{51.01,53.73},{56.21,63.97},{63.71,68.2},{71.03,63.23},{78.75,59.37},{84.11,52.19},{71.06,20.77},{65.98,24.28},{66.01,37.53},{67.8,41.42},{64.28,41.54},{63.66,47.05},{67.2,47.66},{69.54,38.78},{68.4,33.68},{63.31,33.81},{59.41,39.68},{58.97,47.16},{62.18,53.13},{67.4,55.15},{71.57,51.18},{73.04,44.58},{71.95,38.48},{65.9,31.49},{62.32,20.03},{57.95,22.51}}},
        },
        [180743] = {
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.86,65.69}}},
        },
        [180746] = {
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.46,65.57}}},
        },
        [180747] = {
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.78,66.4}}},
        },
        [180748] = {
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.9,66.68}}},
        },
        [180793] = {
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.96,65.86}}},
        },
        [186189] = { -- Complimentary Brewfest Sampler
            [objectKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{54.03,38.92},{54.03,38.95},{54.17,38.31},{54.67,37.93},{54.8,37.9},{54.69,37.94},{55.32,37.26},{55.3,37.28},{55.7,38.16},{55.67,38.17},{56.53,36.68},{55.63,36.48},{55.65,36.48},{56.26,37.94},{56.26,37.97},{55.9,36.43},{55.9,36.4},{56.29,37.96},{59.79,33.5},{59.77,33.51}}},
        },
        [186234] = { -- Water Barrel
            [objectKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST]={{42.5,64.49},{42.73,62.01}},
                [zoneIDs.DUN_MOROGH]={{53.41,51.53},{53.52,55.45}},
                [zoneIDs.AZUREMYST_ISLE]={{49.24,51.28},{43.67,51.56}},
            },
        },
        [186887] = { -- Large Jack-o'-Lantern
            [objectKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST]={{42.5,65.8}},
                [zoneIDs.DUN_MOROGH]={{53.53,52.09}},
                [zoneIDs.AZUREMYST_ISLE]={{48.99,51.02}},
            },
        },
        [187236] = { -- Winter Veil Gift
            [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.71,65.85}}},
        },
        [195122] = { -- Forsaken Stink Bomb Cloud
            [objectKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{71.9,73.37},{72.97,66.13},{73.77,59.68},{73.62,52.32},{71.2,46.14},{65.58,40.17},{61.68,30.26},{62.75,33.49},{58.73,36.76},{55.11,44.8},{55.47,48.75},{58.21,53.72},{54.01,54.66},{50.43,52.9},{46.47,53.99},{48.12,62.84},{48.34,67.39},{50.01,71.56},{53.45,71.01},{57.88,68.15},{60.17,71.63},{62.18,73.99},{65.23,75.58},{67.4,79.36}}},
        },
        [203461] = { -- Fuel Sampling Station
            [objectKeys.spawns] = {[zoneIDs.ABYSSAL_DEPTHS]={{55.8,72.44}}},
        },
        [207125] = { -- Crate of Left Over Supplies
            [objectKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{73.73,67.34}}},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return objectFixesHorde
    else
        return objectFixesAlliance
    end
end
