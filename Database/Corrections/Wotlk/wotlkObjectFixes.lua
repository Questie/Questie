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
        [188474] = {
            [objectKeys.spawns] = {[zoneIDs.DRAGONBLIGHT] = {{52,66}}},
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
        [192818] = {
            [objectKeys.spawns] = {[zoneIDs.THE_UNDERBELLY] = {{30.4,51.5},{30.5,51.3},{34.8,52.2},{35,42.4},{35.1,35.5},{35.3,42.9},{35.3,53},{35.4,35.1},{35.5,35.2},{35.5,35.5},{35.5,43},{35.7,52.4},{39.3,28.4},{39.3,28.6},{39.3,39.9},{39.4,40.6},{39.5,28.6},{39.5,40.4},{39.7,47},{39.8,28.3},{40,47.7},{43.3,32.6},{43.4,32.3},{43.5,32.2},{43.6,32.6},{44.4,65.1},{44.4,65.6},{44.5,65.1},{45.3,58.2},{45.6,58.1},{45.8,58.8},{47.3,56},{47.4,28.4},{47.4,56.9},{48,29.5},{48,55.5},{48.2,55.4},{48.3,29.4},{48.4,40.4},{48.4,40.7},{48.5,29.4},{48.5,29.8},{48.5,41.1},{50.4,25.6},{50.4,26.6},{50.4,52.8},{50.6,25.9},{50.6,26.6},{51.2,53},{51.2,53.6},{51.4,42.1},{51.4,42.5},{51.5,42.2},{51.5,42.6},{51.6,53.4},{51.8,53.8},{54.3,66.2},{54.7,66.8},{55,66.2},{55.3,56.3},{55.4,56.9},{55.5,57.6},{55.6,56.3},{55.7,56.7},{55.8,58.6},{56.7,40.1},{56.8,40.7},{57.4,41.5},{57.4,47.4},{57.5,40.9},{57.6,41.5},{57.6,47.4},{58,47.6},{59,12.5},{59.4,35},{59.4,35.6},{59.5,35.3},{59.7,11.7},{60.6,14.3},{61.8,9.2},{62.3,10.5},{62.4,10},{62.6,10},{64.2,15.1},{64.2,15.6},},},
            [objectKeys.zoneID] = zoneIDs.THE_UNDERBELLY,
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
        [193997] = {
            [objectKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{55.4,68},{57,65},{58.6,60.3},{60.7,57.5},{62.8,60.1},{63.5,57.9},{65.4,60.8},{68.4,55.7},{68.9,54.8},{69.7,63.1},{71.1,62.4},{72.6,61.9},{75.3,48.5},},},
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
    }
end