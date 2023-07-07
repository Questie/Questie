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
        [190558] = {
            [objectKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN] = {{48.3,49.1},{49.4,53.1},{49.6,50.9},{49.7,54.4},{49.7,54.5},{49.8,49.1},{50,51.7},{50,59.8},{50.2,47.5},{50.3,53.3},{50.3,58.5},{50.4,47.2},{50.4,50.4},{50.4,56.8},{50.4,58.3},{50.5,50.4},{50.5,50.5},{50.6,55.5},{50.6,56.9},{50.9,52},{50.9,54.6},{51.1,58.8},{51.4,52.6},{51.4,53.6},{51.4,57.8},{51.5,52.4},{51.5,53.5},{51.5,57.8},{51.6,49.8},{51.7,49.4},{51.7,62.6},{51.8,54.7},{51.9,58.6},{52,61.3},{52.3,61.7},{52.4,53.1},{52.4,56.2},{52.5,51.6},{52.5,53.1},{52.5,56.2},{52.6,60.5},{52.7,60.3},{52.7,62.1},{52.8,54.9},{53.1,50.5},{53.2,47.4},{53.2,47.6},{53.2,50.3},{53.3,59.3},{53.4,49.4},{53.4,53.5},{53.5,49.5},{53.5,53.4},{53.5,53.5},{53.5,61.7},{53.7,60.8},{54.2,51.4},{54.2,51.5},{54.3,48.9},{54.3,59.9},{54.5,49.1},{54.7,57.9},{54.7,60.8},{54.9,51.5},{55,53.7},{55.1,51.2},{55.3,60.2},{55.5,60.2},{55.6,57.4},{55.6,57.6},{55.7,58.6},{55.8,48.9},{55.8,52.8},{55.9,56.3},{56.2,50.9},{56.2,55.2},{56.7,53.4},{56.7,53.5},{56.9,56.3},{56.9,56.5},{57.1,52.2},{57.1,58.8},{57.2,60.6},{57.3,54.5},{57.3,60.1},{57.5,54.4},{58,60.4},{58,60.5},{58.4,58.9},{58.7,53.8},{58.7,55.9},{58.8,62.3},{59.1,57.9},{59.1,60.2},{59.8,55},{59.8,60.4},{59.8,60.5},{59.9,57.3},{60.1,63.9},{60.3,61.9},},},
        },
        [190781] = {
            [objectKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN] = {{33.56,74.96}}},
        },
        [191092] = {
            [objectKeys.spawns] = {[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE] = {{63.12,68.33}}},
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
            [objectKeys.spawns] = {[zoneIDs.THE_NEXUS] = {{19.3,52.7},{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [192818] = {
            [objectKeys.spawns] = {[zoneIDs.THE_UNDERBELLY] = {{30.4,51.5},{30.5,51.3},{34.8,52.2},{35,42.4},{35.1,35.5},{35.3,42.9},{35.3,53},{35.4,35.1},{35.5,35.2},{35.5,35.5},{35.5,43},{35.7,52.4},{39.3,28.4},{39.3,28.6},{39.3,39.9},{39.4,40.6},{39.5,28.6},{39.5,40.4},{39.7,47},{39.8,28.3},{40,47.7},{43.3,32.6},{43.4,32.3},{43.5,32.2},{43.6,32.6},{44.4,65.1},{44.4,65.6},{44.5,65.1},{45.3,58.2},{45.6,58.1},{45.8,58.8},{47.3,56},{47.4,28.4},{47.4,56.9},{48,29.5},{48,55.5},{48.2,55.4},{48.3,29.4},{48.4,40.4},{48.4,40.7},{48.5,29.4},{48.5,29.8},{48.5,41.1},{50.4,25.6},{50.4,26.6},{50.4,52.8},{50.6,25.9},{50.6,26.6},{51.2,53},{51.2,53.6},{51.4,42.1},{51.4,42.5},{51.5,42.2},{51.5,42.6},{51.6,53.4},{51.8,53.8},{54.3,66.2},{54.7,66.8},{55,66.2},{55.3,56.3},{55.4,56.9},{55.5,57.6},{55.6,56.3},{55.7,56.7},{55.8,58.6},{56.7,40.1},{56.8,40.7},{57.4,41.5},{57.4,47.4},{57.5,40.9},{57.6,41.5},{57.6,47.4},{58,47.6},{59,12.5},{59.4,35},{59.4,35.6},{59.5,35.3},{59.7,11.7},{60.6,14.3},{61.8,9.2},{62.3,10.5},{62.4,10},{62.6,10},{64.2,15.1},{64.2,15.6},},},
            [objectKeys.zoneID] = zoneIDs.THE_UNDERBELLY,
        },
        [193004] = {
            [objectKeys.spawns] = {[zoneIDs.ICECROWN] = {{59.35,71.77}}},
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
