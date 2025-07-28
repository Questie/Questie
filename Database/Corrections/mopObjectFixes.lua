---@class MopObjectFixes
local MopObjectFixes = QuestieLoader:CreateModule("MopObjectFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function MopObjectFixes.Load()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [4406] = { -- Webwood Eggs
            [objectKeys.spawns] = {[zoneIDs.SHADOWTHREAD_CAVE] = {{44.22,31.59},{44.72,32.08},{45.49,32.76},{45.65,31.64},{46.53,31.94},{47.86,31.88}}},
            [objectKeys.zoneID] = zoneIDs.SHADOWTHREAD_CAVE,
        },
        [178087] = { -- Thazz'ril's Pick
            [objectKeys.spawns] = {[zoneIDs.BURNING_BLADE_COVEN] = {{40.73,52.51}}},
            [objectKeys.zoneID] = zoneIDs.BURNING_BLADE_COVEN,
        },
        [182052] = { -- Harbinger of the Second Trial
            [objectKeys.spawns] = {[zoneIDs.SUNSTRIDER_ISLE] = {{77.46,68.81}}},
            [objectKeys.zoneID] = zoneIDs.SUNSTRIDER_ISLE,
        },
        [202113] = { -- Spitescale Flag
            [objectKeys.spawns] = {[zoneIDs.SPITESCALE_CAVERN] = {{31.61,43.07},{39.94,41.39},{48.18,36.24},{46.5,64.53},{52.44,61.74},{62.98,65.16},{67.52,78.6},{74.64,75.09},{76.79,63.5},{73.11,55.41},{77.84,47},{72.46,43.91},{77.49,16.99},{70.17,27.77},{62.34,28.39},{56.64,44.03},{59.8,55.14},{68.98,40.85},{61.32,39.95},{64.18,52.98},{66.21,58.53},{62.14,71.58}}},
            [objectKeys.zoneID] = zoneIDs.SPITESCALE_CAVERN,
        },
        [202586] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SUNSTRIDER_ISLE] = {{61.68,44.9}}},
            [objectKeys.zoneID] = zoneIDs.SUNSTRIDER_ISLE,
        },
        [204042] = { -- Detonator
            [objectKeys.spawns] = {[zoneIDs.FROSTMANE_HOLD] = {{36,40.92}}},
            [objectKeys.zoneID] = zoneIDs.FROSTMANE_HOLD,
        },
        [209550] = { -- Blushleaf Cluster
            [objectKeys.name] = 'Blushleaf Cluster',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{36.32,21.112},{36.04,21.23},{35.81,20.55},{35.31,21.09},{34.93,20.51},{34.48,20.42},{34.29,20.47},{34.4,20.68},{34.17,20.76},{34,20.75},{33.75,19.93},{33.52,19.69},{33.12,20.19},{33.5,20.98},{33.98,21.25},{34.19,21.25}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209551] = { -- Boiling Cauldron
            [objectKeys.name] = 'Boiling Cauldron',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{37.74,17.57}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209594] = { -- Infested Book
            [objectKeys.name] = 'Infested Book',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{55.64,59.98},{55.84,59.62},{56.31,60.1},{56.71,60.02},{56.76,60.24},{56.53,61.16},{56.29,60.81},{55.51,60.64},{55.79,60.12},{55.69,59.71},{56.3,59.8},{56.47,60.82},{56.84,60.46},{56.57,61.03},{55.72,60.78}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209621] = { -- Sniper Rifle
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{62.56,82.14}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209629] = { -- Staff of Pei-Zhi
            [objectKeys.name] = 'Staff of Pei-Zhi',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.23,14.9}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209656] = { -- Defaced Scroll of Wisdom
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{29.07,51.28},{29.2,51.22},{29.07,51.28},{29.2,51.22},{29.2,51.22},{29.07,51.28},{31.26,49.96},{31.47,49.92},{32.7,53.5},{32.5,53.58},{32.5,53.58},{31.47,49.92},{31.26,49.96},{32.7,53.5},{32.53,46.81},{32.48,46.66},{33.17,46.15},{33.45,50.86},{32.48,46.66},{33.13,46.3},{33.17,46.15},{33.13,46.3},{32.53,46.81},{33.45,50.86},{33.17,46.15},{33.13,46.3},{32.48,46.66},{32.53,46.81},{32.53,46.81},{32.48,46.66},{33.17,46.15},{33.13,46.3},{28.26,49.88},{28.26,49.58},{28.19,49.95},{28.19,49.95},{28.26,49.58},{28.26,49.88},{28.19,49.95},{28.26,49.58}}},
        },
        [209672] = { -- Firework Launcher
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{56.4,58.2},{56.9,58.8},{57.1,57.7},{57.2,59.9},{57.5,61.4},{57.5,61.5},{57.9,59.5},{58,58.8},{58.3,58.2},{58.4,57.2},{58.5,56.3},{58.6,56.9},{58.6,57.6}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209826] = { -- Silk Patch
            [objectKeys.name] = 'Silk Patch',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{45.11,47.31},{45.06,47.99},{44.9,48.08},{45.13,48.66},{45.1,49.39},{44.84,49.44},{44.52,48.44},{44.36,47.24},{43.34,48.88},{43.71,48.27},{43.45,49.11},{43.44,48.29},{42.64,48.56},{42.65,48.02},{42.94,47.5},{43.22,49.68},{42.64,50.06},{42.91,50.31},{42.31,50.4},{42.06,51.06},{44.18,50.78},{44.4,50.93},{44.24,50.42},{44.2,49.57}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209835] = { -- Marmot Hole
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{81.77,25.59},{82.41,25.93},{82.43,24.80},{81.66,24.86},{81.86,25.09},{82.15,25.07},{82.53,26.27},{82.24,26.16},{82.14,26.37},{82.23,26.15}}},
        },
        [209842] = { -- Pang's Extra-Spicy Tofu
            [objectKeys.name] = 'Pang\'s Extra-Spicy Tofu',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{83.94,22.04},{84.04,22.08}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [209843] = { -- Ang's Summer Watermelon
            [objectKeys.name] = 'Ang\'s Summer Watermelon',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{84.19,22.16},{84.2,22.18},{84.2,22.2},{84.18,22.07},{84.13,22.14},{84.14,22.07},{84.16,21.99},{84.11,21.92}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [209844] = { -- Ang's Giant Pink Turnip
            [objectKeys.name] = 'Ang\'s Giant Pink Turnip',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{84.42,21.96},{84.33,22.08},{84.32,21.97},{84.31,21.87},{84.29,21.89},{84.28,22}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [209863] = { -- Chunk of Jade
            [objectKeys.name] = 'Chunk of Jade',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.3,31.4},{47.3,31.5},{47.4,30.1},{47.9,30.9},{48,29.4},{48.1,32.7},{48.2,31.5},{48.4,30.2},{48.5,32.5},{48.8,30.4},{49,29.4},{49,30.7},{49.2,31.6},{49.5,30.4},{49.5,30.6},{49.5,31.9}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209877] = { -- Dead Deepriver Slicky
            [objectKeys.name] = 'Dead Deepriver Slicky',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{26.52,55.65},{26.62,56.07},{26.38,55.54}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209889] = { -- Restorative Spirit
            [objectKeys.name] = 'Restorative Spirit',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{68.04,81.86}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209890] = { -- Restorative Heart
            [objectKeys.name] = 'Restorative Heart',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{66.43,80}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [209891] = { -- Stolen Turnip
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{85.45,35.03},{85.88,34.53},{85.69,34.35},{85.64,33.64},{84.54,26.8},{84.49,26.64},{84.51,26.58},{84.63,26.5},{84.69,26.48},{84.72,26.48},{84.75,26.67},{84.76,26.72},{84.99,27.77},{85.19,26.97},{85.11,26.91},{85.09,27.14},{85.02,27.11}}},
        },
        [209899] = { -- Stolen Watermelon
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{85.45,35.03},{85.88,34.53},{85.69,34.35},{85.64,33.64},{85.69,33.34},{85.67,32.92},{85.58,32.39},{85.53,32.68},{85.53,32.65},{85.57,32.09},{85.43,32.19},{85.51,32.33},{85.45,32.49},{85.41,32.61},{85.37,32.76},{85.11,32.35},{85.08,32.23},{85.17,32.24}}},
        },
        [209907] = { -- Meadow Marigold
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{65.71,42.75},{69.74,46.85},{69.37,47.34},{70.20,49.92},{70.11,49.17},{70.24,49.00},{70.28,48.84},{70.35,48.44},{71.39,48.09},{71.31,47.93},{71.11,47.57},{70.99,47.43},{71.28,47.35},{69.75,42.90},{69.51,42.83},{69.30,43.03},{69.42,42.59},{65.72,42.78},{66.83,40.54},{67.64,39.75},{67.82,39.56},{67.62,39.52}}},
        },
        [209974] = { -- Barrel of Slickies
            [objectKeys.name] = 'Barrel of Slickies',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{28.15,47.34},{28.14,47.42},{28.11,47.39}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [210005] = { -- Weapon Rack
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{59.19,17.25},{58.67,16.32},{56.86,19.64},{57.59,17.59},{58.03,19.95},{57.85,20.06},{58.86,16.72},{57.24,16.73},{57.23,19.23},{56.98,20.49}}},
        },
        [210191] = { -- Memorial Flame of Zhu
            [objectKeys.name] = 'Memorial Flame of Zhu',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{72.75,18.2}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210213] = { -- Memorial Flame of Rin
            [objectKeys.name] = 'Memorial Flame of Rin',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{71.23,17.56}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210214] = { -- Memorial Flame of Po
            [objectKeys.name] = 'Memorial Flame of Po',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{73.95,16.88}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210565] = { -- Dark Soil
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.82,47.98}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210931] = { -- Dak Dak's Altar
            [objectKeys.spawns] = {[zoneIDs.THE_DEEPER] = {{49.56,39.54}}},
            [objectKeys.zoneID] = zoneIDs.THE_DEEPER,
        },
        [210933] = { -- Yaungol Banner
            [objectKeys.name] = 'Yaungol Banner',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{58.2,84.09}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [210964] = { -- Pei-Wu Forest Gate
            [objectKeys.name] = 'Pei-Wu Forest Gate',
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{52.26,68.52}}},
            [objectKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [210965] = { -- Mandori Village Gate
            [objectKeys.name] = 'Mandori Village Gate',
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{51.59,61.29}}},
            [objectKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [211020] = { -- Yoon's Apples
            [objectKeys.name] = 'Yoon\'s Apples',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.63,47.8}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [211022] = { -- Yoon's Craneberries
            [objectKeys.name] = 'Yoon\'s Craneberries',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.82,47.84}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [211112] = { -- Mysterious Whirlpool
            [objectKeys.name] = 'Mysterious Whirlpool',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{34.17,31.69}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211118] = { -- Jagged Abalone
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{69.5,38.67},{69.34,37.76},{70.61,38.74},{70.53,41.76},{69.08,39.99},{69.14,39.19},{68.67,39.33},{68.26,40.18},{68.88,36.48},{69.18,36.89},{69.7,36.38},{71.31,37.11},{71.39,37.83},{71.87,38.29},{71.76,40.36},{71.01,40.86},{70.28,41.78}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211169] = { -- Crane Yolk Pool
            [objectKeys.name] = 'Crane Yolk Pool',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{65.03,50.04}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211275] = { -- Ko Ko's Altar
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{52.27,71.44}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211276] = { -- Tak Tak's Altar
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{56.84,70.98}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211306] = { -- Revelite Crystal
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{23.15,30.87},{23.49,33.25},{26.96,32.85},{27.65,29.00},{26.07,28.38},{26.33,25.12},{24.14,27.42},{21.59,28.46},{20.39,30.60},{22.37,30.78},{21.57,31.41},{23.16,30.73},{23.18,26.58},{22.11,27.19}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [211312] = { -- Items for Barrels of Fun
            [objectKeys.name] = 'Explosives Barrel',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{51.24,79.33},{49.61,78.99},{49.34,81.06},{47.55,80.08}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211365] = { -- Ball and Chain
            [objectKeys.spawns] = {[6088] = {{38.68,23.02}}},
            [objectKeys.zoneID] = 6088,
        },
        [211376] = { -- Items for Build Your Own Raft
            [objectKeys.name] = 'Spare Plank',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{52.41,76.14}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211382] = { -- Items for Build Your Own Raft
            [objectKeys.name] = 'Tough Kelp',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{52.24,77.89}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211510] = { -- Sage Liao's Belongings
            [objectKeys.name] = 'Sage Liao\'s Belongings',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{61.01,21.52}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211511] = { -- Drywood Cage
            [objectKeys.name] = 'Drywood Cage',
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{66.72,43.99},{65.9,44.81},{66.68,45.31},{66.15,46.24},{66.41,46.96},{67.39,46.31},{67.04,45.83},{67.5,46.92},{66.75,48.05},{67.28,49.51},{65.67,49.39},{66.13,48.83},{64.82,50.52},{66.26,51.48},{66.06,52.13},{67.29,51.36},{67.96,50.82}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [211515] = { -- Peat Mound
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{71.48,72.29}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [211526] = { -- Waterfall Polished Stone
            [objectKeys.name] = 'Waterfall-Polished Stone',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{58.78,24.71},{58.96,24.63},{60.22,31.40},{60.11,31.09},{59.71,29.96},{59.69,29.61},{59.17,27.32},{58.96,27.32},{59.03,27.20}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211545] = { -- Incense of Life
            [objectKeys.name] = 'Incense of Life',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{66.95,33.33}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211720] = { -- Meeting Stone (Terrace of Endless Spring)
            [objectKeys.spawns] = {[zoneIDs.THE_VEILED_STAIRS] = {{51.7,69.4}}},
            [objectKeys.zoneID] = zoneIDs.THE_VEILED_STAIRS,
        },
        [211754] = { -- Curious Text
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{57.11,47.89}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211770] = { -- Shen Dynasty Tablet
            [objectKeys.name] = 'Shen Dynasty Tablet',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{57.13,43.5}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211790] = { -- Wai Dynasty Tablet
            [objectKeys.name] = 'Wai Dynasty Tablet',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{56.34,43.43}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211863] = { -- Krik'thik Limb
            [objectKeys.name] = 'Krik\'thik Limb',
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{77.19,88.74},{76.93,88.98},{76.72,88.92},{76.3,90.03},{74.87,82.69},{74.28,83.72},{74.33,83.81},{74.39,84.01},{74.19,84.34},{74.17,84.36},{74.27,85.47},{73.85,84.98},{73.34,84.29},{71.54,85.1}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [211871] = { -- Dread Orb
            [objectKeys.name] = 'Dread Orb',
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{56.8,7.6},{65.4,87.1},{65.4,88.7},{65.5,88.6},{66,87.7},{66.1,86.4},{66.1,86.6},{66.8,87.3},{66.8,87.5},{67.7,87.5},{67.9,86.4},{68,86.5},{68.3,89.1},{69.1,88.1},{69.1,89.5},{69.3,89.2}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [211872] = { -- Dread Orb
            [objectKeys.name] = 'Dread Orb',
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{64.9,88.7},{66,87.7},{66.2,86.6},{67.3,86.9},{67.8,87.6},{67.9,86.7},{68.3,89.1},{69.1,88.1},{69.4,88.9}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [211873] = { -- Dread Orb
            [objectKeys.name] = 'Dread Orb',
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{65.9,86.7},{66.2,87.5},{66.9,87.1},{68,86.4},{68,88.3},{68,88.6},{68.1,86.5},{69.1,88.1},{69.1,89.5},{69.3,89.1}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [211883] = { -- Scout Cage
            [objectKeys.name] = 'Scout Cage',
            [objectKeys.spawns] = {[zoneIDs.RAGEFIRE_CHASM] = {{36.72,84.38},{36.24,84.61},{35.79,84.91},{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.RAGEFIRE_CHASM,
        },
        [212003] = { -- Yaungol Oil Barrel
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{26.2, 59.9}, {26.3, 59.1}, {26.6, 59.4}, {27.2, 60.2}, {27.4, 60.8}, {27.7, 61}, {28.4, 61.5}, {28.5, 61.1}, {28.5, 61.5}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [212131] = { -- Niuzao Food Supply
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{41.58,61.5},{42.34,62.04},{39.82,63.39},{38.99,64.1},{38.3,63.61},{37.61,64.03},{37.57,63.98},{40.13,56.89},{40.32,58.7},{42.66,58.73},{41.35,62.11},{39.28,61.58},{39.27,61.6},{37.74,62.45},{37.85,61.03},{39.65,57.7},{42.44,57.99},{41.79,61.62},{43.26,58.19},{41.4,63.08},{40.94,63.59},{40.32,64.19},{39.72,64.67},{39.81,60.92},{38.69,60.97},{38.62,61.45},{39.01,60.13}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [212294] = { -- Ocean-Worn Rocks
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{43.3,63.49}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [214674] = { -- Ancient Amber Chunk
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{44.76,41.66}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212389] = { -- Scroll of Auspice
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{53.08,12.35}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212524] = { -- Inactive Sonic Relay
            [objectKeys.name] = 'Inactive Sonic Relay',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{40.07,38.99}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212526] = { -- An empty bookshelf
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{82.4,29.4},{82.4,29.5},{82.5,29.4},{82.5,29.5}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [212742] = { -- Fresh Dirt
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{37.3,45.4},{37.3,45.5},{38,42.1},{38,46},{38.2,48.1},{38.3,48.8},{38.4,44.9},{38.4,47.4},{38.5,44.4},{38.5,47.5},{38.5,48.9},{38.6,44.7},{38.6,47.4},{39.1,53.5},{39.2,42.4},{39.2,42.5},{39.2,53.3},{40,53.2},{40.2,42},{40.3,41},{40.3,51.7},{40.5,40.9},{40.5,42.1},{41.3,40.2},{41.4,42.6},{41.4,52.2},{41.5,40.1},{41.6,42.6},{41.6,52.4},{42.2,42.1},{42.3,53.3},{42.3,53.5},{42.5,53.6},{42.7,39.4},{42.7,39.5},{42.9,42},{43,51.8},{43,53.1},{43.4,50.8},{43.5,50.8},{43.6,50.4},{44.6,51.4},{44.6,51.5},{44.7,50},{44.9,45.7},{45.4,39.4},{45.4,39.6},{45.5,39.4},{45.5,39.6},{45.8,47.5},{45.9,47.4},{46.1,42.7},{46.4,41.2},{46.8,46.3},{46.8,46.5},{47.1,41.4},{47.1,41.5}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [212868] = { -- Ancient Amber Chunk
            [objectKeys.name] = 'Ancient Amber Chunk',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{70.19,25.63}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212923] = { -- Amber Collector
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{32.9,50.4},{32.9,50.5},{34,51.1},{34.4,51.6},{34.5,51.3},{34.8,51.5},{37,51.8},{38.6,49.3},{39.4,52.1},{39.6,52},{40.4,47.7},{40.5,47.9},{41.4,52.4},{41.4,52.5},{41.5,52.4},{41.5,52.6},{42.3,50.2},{42.5,50.2},{44.9,57.9},{45,57},{45.6,52.1},{46.8,53.7},{48.8,64},{49.3,62.6},{49.7,66.3},{50.7,64.2},{51.4,66.2},{51.5,66.2}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212935] = { -- Mogu Artifact
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{26.67,37.64},{27.59,39.59},{26.08,40.92},{25.75,41.04},{25.01,42.41},{23.33,40.36},{24.49,39.12},{23.63,38.15},{24.21,45.82},{24.03,45.79},{26.01,49.28},{25.77,49.07},{26.33,46.56},{26.22,46.71},{26.21,46.53}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [212980] = { -- Ancient Amber Chunk
            [objectKeys.name] = 'Ancient Amber Chunk',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{25.7,50.34}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213254] = { -- Meeting Stone (Mogu Shan Palace)
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{82.9,40.8}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [213255] = { -- Meeting Stone (Mogu Shan Palace)
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{74.8,30.3}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [213454] = { -- Soggy's Footlocker
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{44.7,78.6}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213508] = { -- Full Crab Pot
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{46.28,67.93},{46.7,80.5},{46.8,74.4},{47.55,70.64},{47.8,72.17},{47.9,75.1},{49.1,76}}},
        },
        [213744] = { -- Serpent Rod
            [objectKeys.name] = 'Serpent Rod',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{53.69,76.05}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213746] = { -- Bamboo Rod
            [objectKeys.name] = 'Bamboo Rod',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{53.69,76.05}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213752] = { -- Classic Rod
            [objectKeys.name] = 'Classic Rod',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{53.58,76.04}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213753] = { -- Improvised Rod
            [objectKeys.name] = 'Improvised Rod',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{53.58,76.04}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213754] = { -- Potent Dream Brew
            [objectKeys.name] = "Potent Dream Brew",
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{54.68,92.06}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [213795] = { -- Stormstout Secrets
            [objectKeys.name] = "Stormstout Secrets",
            [objectKeys.spawns] = {[zoneIDs.STORMSTOUT_BREWERY] = {{-1,-1}}}, -- TODO: Add coords from inside the dungeon
            [objectKeys.zoneID] = zoneIDs.STORMSTOUT_BREWERY,
        },
        [214062] = { -- Glowing Amber
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{41.87,63.71}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [214101] = { -- In the Shadow of the Light
            [objectKeys.spawns] = {[zoneIDs.SCHOLOMANCE_MOP] = {{58.91,81.74},{50.21,36.36},{76.73,48.96},{72.15,64.34},{53.37,53.62},{69.29,45.05},{65.87,78.88},{58.59,39.78},{-1,-1}}},
        },
        [214105] = { -- Kel'Thuzad's Deep Knowledge
            [objectKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{57.87,9.91},{65.37,28.12},{60.21,28.13},{74.18,17.67},{70.87,28.26},{73.76,8.32},{68.6,17.63},{66.3,8.32}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [214106] = { -- Forbidden Rites and other Rituals Necromantic
            [objectKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{34.76,23.69},{43.91,42.72},{31.39,40.57},{33.42,43.57},{33.08,55.8},{40.07,34.78},{43.25,54.95},{33.26,31.54}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [214107] = { -- The Dark Grimoire
            [objectKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{47.42,77.3},{50.01,74.97},{47.19,72.34},{49.09,62.91},{43.84,62.95},{54.09,72.29},{53.32,79.51}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [214169] = { -- Meeting Stone (Gate of the Setting Sun)
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{15.5,76.7}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [214277] = { -- The Dark Grimoire
            [objectKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{47.42,77.3},{50.01,74.97},{47.19,72.34},{49.09,62.91},{43.84,62.95},{54.09,72.29},{53.32,79.51}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [214278] = { -- Kel'Thuzad's Deep Knowledge
            [objectKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{57.87,9.91},{65.37,28.12},{60.21,28.13},{74.18,17.67},{70.87,28.26},{73.76,8.32},{68.6,17.63},{66.3,8.32}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [214279] = { -- In the Shadow of the Light
            [objectKeys.spawns] = {[zoneIDs.SCHOLOMANCE_MOP] = {{58.91,81.74},{50.21,36.36},{76.73,48.96},{72.15,64.34},{53.37,53.62},{69.29,45.05},{65.87,78.88},{58.59,39.78},{-1,-1}}},
        },
        [214280] = { -- Forbidden Rites and other Rituals Necromantic
            [objectKeys.spawns] = {
                [zoneIDs.SCHOLOMANCE_MOP_CHAMBER_OF_SUMMONING] = {{34.76,23.69},{43.91,42.72},{31.39,40.57},{33.42,43.57},{33.08,55.8},{40.07,34.78},{43.25,54.95},{33.26,31.54}},
                [zoneIDs.SCHOLOMANCE_MOP] = {{-1,-1}},
            },
        },
        [214284] = { -- Blade of the Anointed
            [objectKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY_MOP_FORLORN_CLOISTER] = {{20.55,45.65}},
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
            [objectKeys.zoneID] = zoneIDs.SCARLET_MONASTERY,
        },
        [214543] = { -- Dreadspore Bulb
            [objectKeys.name] = "Dreadspore Bulb",
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{33.2,85.93}}}, -- there are like 100 more spawns, used one so we can have tooltips
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [214824] = { -- Ancient Mogu Chest
            [objectKeys.spawns] = {[zoneIDs.MOGUSHAN_PALACE_VAULTS_OF_KINGS_PAST] = {{60.12,82.45},{38.92,88.24},{37.39,64.61},{42.97,59.72}}},
            [objectKeys.zoneID] = zoneIDs.MOGUSHAN_PALACE_VAULTS_OF_KINGS_PAST,
        },
        [214873] = { -- Vacant Destroyer
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.81,18.73},{47.75,18.26},{47.13,16.98},{47.82,16.4},{46.72,16.75},{46.91,16.16},{46.99,15.68},{46.29,15.78},{45.23,16.22},{48.55,16.22},{48.72,19.74},{48.97,20.27},{48.54,20.75},{48.11,20.25},{48.61,19.37},{48.32,18.78},{48.8,18.06},{48.8,17.7}}},
        },
        [214962] = { -- Requisitioned Firework Launcher
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{27,23.3},{27,23.8},{27.3,24.8},{27.8,23.2},{28.1,24.7},{28.3,23.5},{28.5,23.9},{28.5,24.8},{28.8,24.2},{29.1,23.6},{29.3,24.1},{29.5,23.4},{29.7,24.9},{30,23.7},{30.2,24.3},{30.5,23.8},{30.8,24.4},{31,23.9},{31.3,24.5},{31.5,24},{31.8,24.6},{32,25}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [214979] = { -- Meeting Stone (Stormstout Brewery)
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{35.6,65.6}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [215390] = { -- Powder Keg
            [objectKeys.name] = 'Powder Keg',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{45.81,95.12},{46.03,96.11}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215682] = { -- Skyfire Parachute
            [objectKeys.name] = 'Skyfire Parachute',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{42.31,92.81}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [221268] = { -- Meeting Stone (Siege of Orgrimmar) TODO: Enable correct spawns, once SoO is available
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = {},
            --[objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            --[objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{69.8,45.5}}},
        },
        [223816] = { -- Meeting Stone (Heart of Fear)
            [objectKeys.name] = 'Meeting Stone', -- DB says "unk name" and wowhead does not know this object, so we reuse it.
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{40.6,33.6}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [223817] = { -- Meeting Stone (Throne of Thunder) TODO: Add correct spawns, once The Isle of Thunder is available
            [objectKeys.name] = 'Meeting Stone', -- DB says "unk name" and wowhead does not know this object, so we reuse it.
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = {},
        },
        [223818] = { -- Pools spawned during quest The Pools of Youth
            [objectKeys.name] = 'Water of Youth', -- DB says "unk name" and wowhead does not know this object, so we reuse it.
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{51.58,33.08},{51.68,33.24},{51.76,33.41},{51.86,33.08},{51.95,33.26},{52.02,33.03},{52.29,33.10},{52.39,32.98},{52.53,32.91},{52.29,32.74},{52.45,32.52},{52.31,32.43},{51.82,32.37},{51.65,32.26},{51.78,32.13},{52.05,32.16},{52.02,32.37}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [223819] = { -- Traps for quest Tread Lightly
            [objectKeys.name] = 'Riverblade Spike Trap', -- DB says "unk name" and wowhead does not know this object, so we reuse it.
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{51.58,33.08},{47.24,29.63},{47.30,30.53},{48.61,33.45},{46.66,36.47},{47.22,38.36},{46.59,38.07},{41.29,41.19},{41.98,42.24},{40.14,41.87},{39.16,39.98},{38.83,38.51},{37.11,39.04},{37.14,37.00},{37.89,34.22},{43.55,32.98}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },

        -- Below are fake objects
        -- These objects are from previous expansions and they need updated coords
        [430003] = {
            [objectKeys.spawns] = {[zoneIDs.NEW_TINKERTOWN] = {{34.35,65.06},{36.57,68.47},{38.14,68.84},{37.97,72.46},{37.5,77.21},{38.77,74.26},{39.98,78.03},{41.17,69.78},{40.74,74.41},{42.04,73.67},{43.89,70.28},{45.04,73.37},{47.12,73.45},{45.79,69.35},{48.77,73.59},{47,71.02},{48.67,69.06}}},
            [objectKeys.zoneID] = zoneIDs.NEW_TINKERTOWN,
        },

        -- For MoP fixes 440001-449999
        [440001] = { -- For Fresh Pots 31181
            [objectKeys.name] = 'Empty Crab Pot',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{58.41,81.83},{58.91,82.32},{59.07,83.39},{59.93,83.38},{60.23,83.06},{60,82.56},{60.6,82.5},{61.18,82.9},{61.44,84.22},{61.24,84.5},{60.52,84.82},{61.51,82.01},{62.16,81.84},{62.06,81.2},{61.1,80.89},{61.49,79.62},{59.84,79.62},{59.56,80.92},{59.54,81.25},{58.15,80.47}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [440002] = { -- For Evie Stormstout 31077
            [objectKeys.name] = 'Evie Stormstout',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{50.22,10.14}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [440003] = { -- For Fires and Fears of Old 31085
            [objectKeys.name] = 'Enormous Landslide',
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{29.91,31.27}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [440004] = {
            [objectKeys.name] = "Lesser Charm of Good Fortune",
        },
        [440005] = {
            [objectKeys.name] = "Elder Charm of Good Fortune",
        },
    }
end
