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
        [210229] = { -- Water of Youth
            [objectKeys.name] = 'Water of Youth',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{51.58,33.08},{51.68,33.24},{51.76,33.41},{51.86,33.08},{51.95,33.26},{52.02,33.03},{52.29,33.10},{52.39,32.98},{52.53,32.91},{52.29,32.74},{52.45,32.52},{52.31,32.43},{51.82,32.37},{51.65,32.26},{51.78,32.13},{52.05,32.16},{52.02,32.37}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210527] = { -- Northeast Oubliette Shackle
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{67.94,31.54}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210533] = { -- Northwest Oubliette Shackle
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{66.7,31.58}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210535] = { -- Southwest Oubliette Shackle
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{66.71,33.69}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [210565] = { -- Dark Soil
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.82,47.98}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210680] = { -- Mogu Tent
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{25.19,26.64},{25.69,26.56},{27.2,29.17},{27.43,29.76},{25.85,30.51},{20.63,30.51},{20.96,31.07},{24.48,38.14},{24.7,37.65},{26.34,39.77},{25.91,39.77},{26.21,41.01},{26.59,43.33},{24.84,43.27},{22.82,41.6}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [210931] = { -- Dak Dak's Altar
            [objectKeys.spawns] = {[zoneIDs.THE_DEEPER_LOWER_LEVEL] = {{49.66,39.68}}},
            [objectKeys.zoneID] = zoneIDs.THE_DEEPER,
        },
        [210933] = { -- Yaungol Banner
            [objectKeys.name] = 'Yaungol Banner',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{58.2,84.09}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [210938] = { -- Partially Chewed Carrot
            [objectKeys.name] = 'Partially Chewed Carrot',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{41.3,40},{41.5,38.4},{41.8,35.3},{42,40},{42.7,39.2},{43.6,37.5},{43.9,35.1},{44.2,40.1},{44.5,42.6},{44.6,40}}}, -- wowhead coords, might be more
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210942] = { -- Partially Chewed Carrot
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{41.6,39.2},{42.8,36.3},{43.4,38.5},{43.6,37.4},{43.6,41.4},{44.5,38.2},{44.7,42.2}}}, -- wowhead coords, might be more
        },
        [210944] = { -- Mailbox
            [objectKeys.name] = 'Mailbox',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{67.52,51.4}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [210956] = { -- Preserved Vegetables
            [objectKeys.name] = 'Preserved Vegetables',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{39.3,17.1},{43.8,22.7},{44.1,20.4},{44.9,18.7},{46.1,21.6},{46.7,21.7},{47.7,18.8},{48.3,19.6}}}, -- wowhead coords, might be more
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210957] = { -- Preserved Vegetables
            [objectKeys.name] = 'Preserved Vegetables',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.2,19.9},{44.9,18.7},{44.9,19.8},{46.1,21.5},{46.2,21.4},{46.7,20.7},{47.2,20.4},{47.5,19},{48.5,18.2}}}, -- wowhead coords, might be more
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210958] = { -- Chrysoberyl Outcropping
            [objectKeys.name] = 'Chrysoberyl Outcropping',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{39.7,20},{44,22.7},{47.3,21}}}, -- wowhead coords, might be more
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210959] = { -- Chrysoberyl Outcropping
            [objectKeys.name] = 'Chrysoberyl Outcropping',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{39.2,18.9},{44.5,20.8}}}, -- wowhead coords, might be more
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210960] = { -- Chrysoberyl Outcropping
            [objectKeys.name] = 'Chrysoberyl Outcropping',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{38.9,16.6},{45,18.9},{45.2,19.5},{48.9,19.2}}}, -- wowhead coords, might be more
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
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
        [210968] = { -- Bloodbloom
            [objectKeys.name] = 'Bloodbloom',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.36,19.67},{44.38,19.03},{45,18.75},{45.22,19.28},{44.71,20.57}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210969] = { -- Cave Lily
            [objectKeys.name] = 'Cave Lily',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{47.83,20.16},{48.93,19.3},{49.05,18.68},{48.62,18.17},{48.41,18.39},{47.45,18.99}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210970] = { -- Ghostcap
            [objectKeys.name] = 'Ghostcap',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{38.7,17.88},{38.6,17.39},{38.53,17.22},{38.58,16.8},{39,16.56},{39.39,17.22},{39.3,17.76},{39.24,19.23}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [210971] = { -- Violet Lichen
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.38,21.96},{40.25,21.23},{42.49,22.36},{41.44,22.58},{40.13,19.76},{38.56,21.67},{47.14,20.31},{36.42,21.09}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [211006] = { -- Sunsong Ranch Mailbox
            [objectKeys.name] = 'Sunsong Ranch Mailbox',
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{51.29,48.83}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
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
        [211025] = { -- Goldenfire Orchid
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{47.26,47.73},{46.44,49},{45.11,49.76},{38.28,37.15},{37.84,38.39},{42.06,40.9},{42.4,41.53},{41.77,43.68},{36.65,36.09},{45.65,49.57},{46.1,50.15}}},
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
        [211129] = { -- Signal Flame
            [objectKeys.name] = 'Signal Flame',
            [objectKeys.spawns] = {[zoneIDs.GATE_OF_THE_SETTING_SUN] = {{48.03,12.24},{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.GATE_OF_THE_SETTING_SUN,
        },
        [211169] = { -- Crane Yolk Pool
            [objectKeys.name] = 'Crane Yolk Pool',
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{65.03,50.04}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211220] = { -- Mailbox
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [211226] = { -- Mailbox
            [objectKeys.factionID] = 1735, -- horde only
        },
        [211266] = { -- Stolen Supplies
            [objectKeys.spawns] = {[zoneIDs.HOWLINGWIND_CAVERN] = {{30.94,50.39},{28.8,77.02},{30.8,76.19},{33.45,77.75},{34.94,72.1},{35.64,71.28},{36.54,68.73},{35.99,42.81},{41.63,43.68},{41.71,42.15},{41.27,41.48},{23.72,49.43},{30.95,34.37},{35.29,23.36},{44.28,19.98},{46.86,21.57},{47.13,22.92},{46.02,23.1},{46,23.45},{48.66,23.55},{48.29,21.85},{50.19,22.64},{53.66,26.6},{55.62,28.49},{56.42,31.29},{56.25,33.12},{55.63,33.91},{55.72,34.51},{66.03,50.95},{66,47.8},{70.95,52.33},{70.83,52.04},{71.3,51.24},{66.49,40.91},{65.58,40.32},{48.45,49.58},{48.6,49.3},{54.62,55.68},{53.8,56.71},{46.04,58},{46.52,63.34},{45.45,60.85},{45.23,61.9},{45.6,63.45},{52.64,73.67},{66.31,83.3},{66.21,85.9},{66.81,85.69}}},
        },
        [211275] = { -- Ko Ko's Altar
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{52.27,71.44}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211276] = { -- Tak Tak's Altar
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{56.84,70.98}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211305] = { -- Rocks
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{37.01,23.69}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [211306] = { -- Revelite Crystal
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{23.15,30.87},{23.49,33.25},{26.96,32.85},{27.65,29.00},{26.07,28.38},{26.33,25.12},{24.14,27.42},{21.59,28.46},{20.39,30.60},{22.37,30.78},{21.57,31.41},{23.16,30.73},{23.18,26.58},{22.11,27.19}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [211307] = { -- Grummle Cage
            [objectKeys.name] = 'Grummle Cage',
            [objectKeys.spawns] = {[zoneIDs.KNUCKLETHUMP_HOLE] = {{24.19,11.87},{49.84,19.75},{48.54,23.08},{55.06,50.82},{83.61,45.42}},[zoneIDs.KUN_LAI_SUMMIT] = {{49.8,64},{50.2,62.4},{50.4,63.2},{50.8,62.8},{51,61.4},{51,61.6},{51.6,63.2}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211312] = { -- Items for Barrels of Fun
            [objectKeys.name] = 'Explosives Barrel',
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{51.24,79.33},{49.61,78.99},{49.34,81.06},{47.55,80.08}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [211365] = { -- Ball and Chain
            [objectKeys.spawns] = {[zoneIDs.KNUCKLETHUMP_HOLE] = {{38.68,23.02}}},
            [objectKeys.zoneID] = zoneIDs.KNUCKLETHUMP_HOLE,
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
        [211393] = { -- Battle Helm of the Thunder King
            [objectKeys.name] = 'Battle Helm of the Thunder King',
            [objectKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS_THE_HALL_OF_THE_SERPENT] = {{50.01,82.1}}},
            [objectKeys.zoneID] = zoneIDs.GUO_LAI_HALLS_THE_HALL_OF_THE_SERPENT,
        },
        [211395] = { -- Battle Spear of the Thunder King
            [objectKeys.name] = 'Battle Spear of the Thunder King',
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{21.4,19.79}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [211396] = { -- Battle Axe of the Thunder King
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{45.49,76.19}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
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
        [211574] = { -- Mailbox
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [211596] = { -- Goblin Fishing Raft
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{67.43,44.77}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [211597] = { -- Shrine of the Seeker's Body
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{44.78,49.21}}},
        },
        [211601] = { -- Shrine of the Seeker's Breath
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{42.67,50.06}}},
        },
        [211602] = { -- Shrine of the Seeker's Heart
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{43.2,52.02}}},
        },
        [211720] = { -- Meeting Stone (Terrace of Endless Spring)
            [objectKeys.spawns] = {[zoneIDs.THE_VEILED_STAIR] = {{51.7,69.4}}},
            [objectKeys.zoneID] = zoneIDs.THE_VEILED_STAIR,
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
        [211967] = { -- King's Coffer
            [objectKeys.spawns] = {[zoneIDs.TOMB_OF_CONQUERORS] = {{58.42,72.66}}},
            [objectKeys.zoneID] = zoneIDs.TOMB_OF_CONQUERORS,
        },
        [211968] = { -- Top Fragment of Lei Shen's Tablet
            [objectKeys.spawns] = {[zoneIDs.TOMB_OF_CONQUERORS] = {{34.13,61.49}}},
            [objectKeys.zoneID] = zoneIDs.TOMB_OF_CONQUERORS,
        },
        [212003] = { -- Yaungol Oil Barrel
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{26.2, 59.9}, {26.3, 59.1}, {26.6, 59.4}, {27.2, 60.2}, {27.4, 60.8}, {27.7, 61}, {28.4, 61.5}, {28.5, 61.1}, {28.5, 61.5}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [212038] = { -- Ancient Amber Chunk
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{31.92,42.43}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212106] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS_TOP_FLOOR] = {{74.23,51.42}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [212113] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS] = {{61.97,38.44}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [212115] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS] = {{29.92,63.18}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [212117] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS_TOP_FLOOR] = {{64.5,33.89}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [212118] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS_TOP_FLOOR] = {{39.26,61.48}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [212119] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS_TOP_FLOOR] = {{44.49,84.11}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [212131] = { -- Niuzao Food Supply
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{41.58,61.5},{42.34,62.04},{39.82,63.39},{38.99,64.1},{38.3,63.61},{37.61,64.03},{37.57,63.98},{40.13,56.89},{40.32,58.7},{42.66,58.73},{41.35,62.11},{39.28,61.58},{39.27,61.6},{37.74,62.45},{37.85,61.03},{39.65,57.7},{42.44,57.99},{41.79,61.62},{43.26,58.19},{41.4,63.08},{40.94,63.59},{40.32,64.19},{39.72,64.67},{39.81,60.92},{38.69,60.97},{38.62,61.45},{39.01,60.13}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [212159] = { -- Mailbox
            [objectKeys.factionID] = 1735, -- horde only
        },
        [212294] = { -- Ocean-Worn Rocks
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{43.3,63.49}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [212389] = { -- Scroll of Auspice
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{53.08,12.36}}},
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
        [212744] = { -- Whitepetal Reeds
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{38.4,48.1},{38.4,49.4},{38.4,49.5},{38.5,49.4},{38.5,49.5},{38.6,47.3},{38.6,47.5},{38.8,44.4},{38.8,53.2},{38.9,45.5},{39,44.8},{39.4,52},{39.7,43.9},{40,51.4},{40.4,42.9},{40.4,51.6},{40.5,51.4},{40.5,51.6},{40.7,42.4},{40.7,42.8},{42.3,52.5},{42.4,52.4},{42.5,52.4},{42.5,52.5},{43.3,48.4},{43.3,48.6},{43.3,51},{43.4,47},{43.5,47},{43.6,49.2},{43.6,50.5},{43.8,50.2}}},
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
        [213004] = { -- Mailbox
            [objectKeys.factionID] = 1735, -- horde only
        },
        [213250] = { -- Silent Beacon
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{48.16,49.71}}},
        },
        [213254] = { -- Meeting Stone (Mogu Shan Palace)
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{82.9,40.8}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [213255] = { -- Meeting Stone (Mogu Shan Palace)
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{74.8,30.3}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [213265] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.BREWMOON_FESTIVAL] = {{45.07,67.83}}},
            [objectKeys.zoneID] = zoneIDs.BREWMOON_FESTIVAL,
        },
        [213289] = { -- Shao-Tien Cage
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{32.94,34.29},{18.07,32.12},{19.6,28.83},{20.55,30.11},{21.59,28.72},{22.09,29.89},{22.9,26.82},{23.57,33.07},{24.51,28.87},{24.62,26.5},{25.05,26.92},{26.18,30.68},{27.42,30.18},{28.99,30.59},{30.65,32.51},{30.04,29.28},{31.17,33.15},{31.96,29.2},{29.36,24.06},{22.71,41.25},{28.16,37.63},{26.76,39.18},{25.2,39.48},{24.75,39.88},{24.34,38.55},{22.53,38.28}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [213303] = { -- Sra'thik Idol
            [objectKeys.name] = 'Sra\'thik Idol',
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{21.52,49.2}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [213319] = { -- Amber Pot
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{67.5,43.87},{66.14,44.81},{66.6,43.77},{66.44,43.43},{65.87,44.48},{67.37,42.64},{66.17,43.01},{68.09,40.14},{66.53,39.25},{65.6,38.31},{68.34,33.98},{69.65,34.18},{69.39,32.34},{71.13,30.25},{72.33,35.55},{72.2,30.66},{70.87,29.39},{73.88,28.79},{71.15,24.11},{69.71,17.14},{68.1,17.06}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213365] = { -- Stolen Mistfall Keg
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{34.6,75.32}}}, -- needs more spawns
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [213454] = { -- Soggy's Footlocker
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{44.7,78.6}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [213508] = { -- Full Crab Pot
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{46.28,67.93},{46.7,80.5},{46.8,74.4},{47.55,70.64},{47.8,72.17},{47.9,75.1},{49.1,76}}},
        },
        [213654] = { -- Mailbox
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [213655] = { -- Mailbox
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [213682] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR] = {{22.79,39.05}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [213683] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR] = {{71.36,28.72}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [213698] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS] = {{66.96,52.17}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [213708] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR] = {{62.83,74.39}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [213727] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR] = {{39.23,79.06}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [213728] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS] = {{33.9,59.07}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
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
        [213767] = { -- Hidden Treasure
            [objectKeys.spawns] = {[zoneIDs.CAVERN_OF_ENDLESS_ECHOES] = {{31.36,52.86}}},
            [objectKeys.zoneID] = zoneIDs.CAVERN_OF_ENDLESS_ECHOES,
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
        [214176] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS] = {{59.45,50.62}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [214260] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS] = {{57.95,52.91}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
            [objectKeys.factionID] = 1732, -- alliance only
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
        [214394] = { -- Ancient Guo-Lai Artifact
            [objectKeys.name] = "Ancient Guo-Lai Artifact",
            [objectKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{49.8,30.81}}},
            [objectKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [214475] = { -- Deactivate First Spirit Wall
            [objectKeys.name] = "Deactivate First Spirit Wall",
            [objectKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{36.3,36.74}}},
            [objectKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [214476] = { -- Deactivate Second Spirit Wall
            [objectKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{22.97,28.71}}},
            [objectKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [214477] = { -- Deactivate Final Spirit Wall
            [objectKeys.spawns] = {[zoneIDs.GUO_LAI_HALLS] = {{41.92,27.8},{49.29,22.55},{38.13,31.48},{41.67,18.15}}},
            [objectKeys.zoneID] = zoneIDs.GUO_LAI_HALLS,
        },
        [214543] = { -- Dreadspore Bulb
            [objectKeys.name] = "Dreadspore Bulb",
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{33.2,85.93}}}, -- there are like 100 more spawns, used one so we can have tooltips
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [214572] = { -- Tablet of Thunder
            [objectKeys.spawns] = {[zoneIDs.TOMB_OF_CONQUERORS] = {{34.13,61.49}}},
            [objectKeys.zoneID] = zoneIDs.TOMB_OF_CONQUERORS,
        },
        [214674] = { -- Ancient Amber Chunk
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{44.76,41.66}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [214824] = { -- Ancient Mogu Chest
            [objectKeys.spawns] = {[zoneIDs.MOGUSHAN_PALACE_VAULTS_OF_KINGS_PAST] = {{60.12,82.45},{38.92,88.24},{37.39,64.61},{42.97,59.72}}},
            [objectKeys.zoneID] = zoneIDs.MOGUSHAN_PALACE_VAULTS_OF_KINGS_PAST,
        },
        [214843] = { -- Serpent's Scale
            [objectKeys.spawns] = {[zoneIDs.THE_WIDOWS_WAIL] = {{63.18,46.59},{55.92,40.81},{60.37,40.02},{45.57,22.69},{27.97,66.18},{29.82,84.8},{40.09,81.8},{41.25,89.83},{60.87,87.18},{62.71,75.72},{57.15,79.94},{47.11,76.41},{55.33,69.02},{61.58,67.5},{69.73,57.06},{73.18,42.71},{58.04,53.8},{57.39,33.58},{74.36,17.61},{74.67,23.35},{67.38,26.81},{63.36,26.85},{64.02,18.12},{54.83,26.8},{54.41,18.96},{42.04,9.56},{34.59,15.24},{32.28,18.53},{38.77,51.87},{51.64,39.19},{43.34,26.3},{37.8,65.46},{39.77,59.99},{33.26,43.65}}},
        },
        [214873] = { -- Vacant Destroyer
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{47.81,18.73},{47.75,18.26},{47.13,16.98},{47.82,16.4},{46.72,16.75},{46.91,16.16},{46.99,15.68},{46.29,15.78},{45.23,16.22},{48.55,16.22},{48.72,19.74},{48.97,20.27},{48.54,20.75},{48.11,20.25},{48.61,19.37},{48.32,18.78},{48.8,18.06},{48.8,17.7}}},
        },
        [214945] = { -- Onyx Egg
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{62.82,28.93},{66.00,30.71},{67.06,30.25},{70.33,28.63},{65.24,23.91},{65.18,24.77},{66.43,29.55},{62.71,29.78},{62.30,28.12},{63.73,21.90},{62.00,29.54},{62.21,29.29},{62.46,28.77},{67.02,32.68},{62.19,31.21},{62.17,31.75},{62.37,32.84},{62.98,21.95},{63.39,21.62},{64.18,23.92},{65.63,25.07},{62.40,32.36},{66.18,33.43},{61.89,30.20},{70.53,28.99},{69.65,31.64},{63.09,29.31},{66.54,32.20},{66.61,31.58},{67.05,33.81},{65.18,24.77},{67.12,24.94},{65.08,26.20},{66.64,28.69}}},
        },
        [214962] = { -- Requisitioned Firework Launcher
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{27,23.3},{27,23.8},{27.3,24.8},{27.8,23.2},{28.1,24.7},{28.3,23.5},{28.5,23.9},{28.5,24.8},{28.8,24.2},{29.1,23.6},{29.3,24.1},{29.5,23.4},{29.7,24.9},{30,23.7},{30.2,24.3},{30.5,23.8},{30.8,24.4},{31,23.9},{31.3,24.5},{31.5,24},{31.8,24.6},{32,25}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [214979] = { -- Meeting Stone (Stormstout Brewery)
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{35.6,65.6}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [214988] = { -- Mailbox
            [objectKeys.factionID] = 1735, -- horde only
        },
        [215126] = { -- Silvermoon (Portal)
            [objectKeys.name] = 'Silvermoon',
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR] = {{75.79,52.72}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR,
        },
        [215390] = { -- Powder Keg
            [objectKeys.name] = 'Powder Keg',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{45.81,95.12},{46.03,96.11}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215650] = { -- Thunder Hold Explosives
            [objectKeys.name] = 'Thunder Hold Explosives',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{34.93,10.81},{34.94,10.79},{34.96,10.78},{34.96,10.76},{34.93,10.71},{34.94,10.52},{34.91,10.44},{34.93,10.46},{34.95,10.47},{34.95,10.5},{34.76,9.95},{34.8,9.9},{34.77,9.88},{34.79,9.84},{34.77,9.84},{33.96,9.76},{33.99,9.75},{33.98,9.78},{33.96,9.83},{33.97,9.95},{34.05,9.95}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215682] = { -- Skyfire Parachute
            [objectKeys.name] = 'Skyfire Parachute',
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{42.31,92.81}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215689] = { -- Rappelling Rope
            [objectKeys.name] = "Rappelling Rope",
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{31.51,11.1},{31.43,10.69},{31.35,10.42}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215705] = { -- Tillers Shrine
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{52.02,49.05}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [215873] = { -- Candy Bucket
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [215874] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{41.69,23.14}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215875] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR] = {{58.64,78.23}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS_TOP_FLOOR,
        },
        [215876] = { -- Candy Bucket
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [215877] = { -- Candy Bucket
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [215879] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_VEILED_STAIR] = {{55.11,72.23}}},
            [objectKeys.zoneID] = zoneIDs.THE_VEILED_STAIR,
        },
        [215880] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{45.79,43.61}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215881] = { -- Candy Bucket
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215884] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{48.1,34.62}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215886] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{55.72,24.41}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215889] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{54.6,63.33}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215891] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{59.56,83.24}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215892] = { -- Candy Bucket
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [215894] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{75.92,6.87}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [215895] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{57.46,59.96}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [215897] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{72.74,92.28}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [215898] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{62.77,80.5}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [215899] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{64.21,61.28}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [215900] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{54.07,82.82}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [215902] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.TOWNLONG_STEPPES] = {{71.14,57.77}}},
            [objectKeys.zoneID] = zoneIDs.TOWNLONG_STEPPES,
        },
        [215903] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{35.14,77.78}}},
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
        },
        [215904] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{61.03,25.14}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [215905] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{83.65,20.13}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [215906] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{19.88,55.78}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [215907] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.8,84.36}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215908] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{28.46,13.27}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [215914] = { -- Candy Bucket
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [215915] = { -- Candy Bucket
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_SEVEN_STARS] = {{37.81,65.86}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_SEVEN_STARS,
        },
        [215973] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{44.83,84.61}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [216100] = { -- Mailbox
            [objectKeys.factionID] = 1735, -- horde only
        },
        [216106] = { -- Mailbox
            [objectKeys.factionID] = 1735, -- horde only
        },
        [216160] = { -- Chunk of Stone
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{77.1,20.4},{77.3,18.3},{77.4,17.2},{77.4,19.1},{77.4,20.5},{77.5,20.5},{77.9,19.1},{78,18},{78.2,16.9},{78.4,19.9},{78.5,17.9},{78.5,18.6},{78.5,19.9},{79.1,17}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216162] = { -- Mound of Dirt
            [objectKeys.name] = "Mound of Dirt",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{13.87,41.34}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {32162,32165},
        },
        [216163] = { -- Mound of Dirt
            [objectKeys.name] = "Mound of Dirt",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{56.3,42.05}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {32163,32166},
        },
        [216231] = { -- Powder Magazine
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{12.33,75.58}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216232] = { -- Powder Magazine
            [objectKeys.name] = "Powder Magazine",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{15.1,76.65},{15.09,76.65},{15.09,76.63},{15.09,76.64},{15.1,76.63},{15.1,76.61},{15.11,76.62},{15.12,76.62},{15.11,76.6},{15.11,76.57},{15.1,76.59},{15.09,76.61},{15.07,76.62},{15.07,76.64},{15.06,76.67}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216274] = { -- Signal Fire
            [objectKeys.name] = "Signal Fire",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{8.44,63.98}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {32108},
        },
        [216347] = { -- Divine Bell
            [objectKeys.name] = "Divine Bell",
            [objectKeys.spawns] = {[zoneIDs.DARNASSUS] = {{39.81,39.75}}},
            [objectKeys.zoneID] = zoneIDs.DARNASSUS,
        },
        [216360] = { -- Untamed Amber
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTES] = {{65.68,71.66}}},
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTES,
        },
        [216362] = { -- A Keg of Metal Brew
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{33.74,34.44}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [216420] = { -- Portal to The Purple Parlor
            [objectKeys.name] = "Portal to The Purple Parlor",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{89.19,33.56}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216421] = { -- Mallet Head
            [objectKeys.name] = "Mallet Head",
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{24.98,28.06}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
        [216427] = { -- Hammer of Fellowship
            [objectKeys.name] = "Hammer of Fellowship",
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{33.4,34.3}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
        [216452] = { -- Treasure Chest
            [objectKeys.name] = "Treasure Chest",
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = nil,
            [objectKeys.questStarts] = nil,
            [objectKeys.questEnds] = {32340},
        },
        [216625] = { -- Memory Wine
            [objectKeys.name] = "Memory Wine",
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{60.5,55.4}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [216643] = { -- Mogu Statue
            [objectKeys.name] = "Mogu Statue",
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{58.08,84.56},{58.22,84.94},{58.35,84.05}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [216664] = { -- Weathered Journal
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{58.26,84.21}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [216678] = { -- Divine Bell
            [objectKeys.name] = "Divine Bell",
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{61.71,20.75}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [216710] = { -- Sunreaver Portal: Darnassus
            [objectKeys.name] = "Sunreaver Portal: Darnassus",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{9.78,53.3}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216720] = { -- Portal to Dalaran
            [objectKeys.name] = "Portal to Dalaran",
            [objectKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{39.98,50.6}}},
            [objectKeys.zoneID] = zoneIDs.TELDRASSIL,
        },
        [216721] = { -- Divine Bell
            [objectKeys.name] = "Divine Bell",
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{55.95,31.8}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
        },
        [216743] = { -- Goblin Explosives Crate
            [objectKeys.name] = "Goblin Explosives Crate",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{25.47,59.41}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216744] = { -- Goblin Explosives Crate
            [objectKeys.name] = "Goblin Explosives Crate",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{23.91,54.62}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216745] = { -- Goblin Explosives Crate
            [objectKeys.name] = "Goblin Explosives Crate",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{15.27,58.98}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
        },
        [216837] = { -- Wrathion's Jewel Chest
            [objectKeys.spawns] = {[zoneIDs.THE_VEILED_STAIR] = {{54.99,72.65}}},
            [objectKeys.zoneID] = zoneIDs.THE_VEILED_STAIR,
        },
        [216885] = { -- Mailbox
            [objectKeys.name] = "Mailbox",
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{86.72,30.65}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [216886] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.KRASARANG_WILDS] = {{88.67,34.48}}},
            [objectKeys.zoneID] = zoneIDs.KRASARANG_WILDS,
            [objectKeys.factionID] = 1732, -- alliance only
        },
        [218229] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.SHRINE_OF_TWO_MOONS] = {{49.54,83.26}}},
            [objectKeys.zoneID] = zoneIDs.SHRINE_OF_TWO_MOONS,
            [objectKeys.factionID] = 1735, -- horde only
        },
        [220069] = { -- Mailbox
            [objectKeys.spawns] = {[zoneIDs.KUN_LAI_SUMMIT] = {{35.86,83.24}}},
            [objectKeys.zoneID] = zoneIDs.KUN_LAI_SUMMIT,
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
        [440006] = {
            [objectKeys.name] = "Mogu Archaeology Fragment",
        },
        [440007] = {
            [objectKeys.name] = "Pandaren Archaeology Fragment",
        },
        [440008] = {
            [objectKeys.name] = "Golden Falls",
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{56.71,21.87}}},
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
        },
    }
end

function MopObjectFixes:LoadFactionFixes()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    local objectFixesHorde = {
        [209621] = { -- Sniper Rifle
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{62.56,82.14}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
    }

    local objectFixesAlliance = {
        [209621] = { -- Sniper Rifle
            [objectKeys.spawns] = {[zoneIDs.THE_JADE_FOREST] = {{28.59,54.42}}},
            [objectKeys.zoneID] = zoneIDs.THE_JADE_FOREST,
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return objectFixesHorde
    else
        return objectFixesAlliance
    end
end
