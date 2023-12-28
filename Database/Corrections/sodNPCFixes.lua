---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function SeasonOfDiscovery:LoadNPCs()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags
    local waypointPresets = QuestieDB.waypointPresets

    return {
        [202060] = {
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{76.8, 51.4}},
                [zoneIDs.TIRISFAL_GLADES] = {{66.4, 40.2}},
            },
        },
        [202699] = { -- Baron Aquanis
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [204068] = { -- Lady Sarevess
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,

        },
        [204070] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{42.2, 35.4}},
                [zoneIDs.DUROTAR] = {{67.4, 87.8}},
                [zoneIDs.UNDERCITY] = {{22.8, 42.8}},
                [zoneIDs.STORMWIND_CITY] = {{25.6, 78}},
            },
        },
        [204503] = {
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{56.4, 57.8}},
            },
        },
        [206248] = {
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{66.8, 58}},
                [zoneIDs.MULGORE] = {{37.4, 49.6}},
            },
        },
        [208275] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{58.6, 45.6}},
            },
        },
        [208752] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{69.2, 58.2}},
            },
        },
        [209678] = { -- Twilight Lord Kelris
            [npcKeys.spawns] = {[zoneIDs.BLACKFATHOM_DEEPS]={{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [209954] = {
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{72.6, 68.8}},
            },
        },
        [211022] = {
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{73.4,33}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [211033] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.8,80.2}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [211965] = {
            [npcKeys.spawns] = {
                [zoneIDs.WETLANDS] = {{46.6, 65.6}},
            },
        },
        [212261] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{17,37.6}},
            },
        },
        [212694] = {
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{43.2,78.6}},
            },
        },
        [212699] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212703] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212706] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212707] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{51.6, 54.6}},
            },
        },
        [212727] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212728] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212729] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212730] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{53.6, 54.2}},
            },
        },
        [212801] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.6, 36.4}},
            },
        },
        [212802] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{70.2, 62.8}},
            },
        },
        [212803] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{73.4, 73.4}},
            },
        },
        [212804] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.8}},
            },
        },
        [212969] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{39.4, 67.2},{73.8,61.9}},
            },
        },
        [212970] = {
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{59.8, 72.4}},
            },
        },
        [213077] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{54.4,61.2}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214070] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{51.4,63.8}}},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214096] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF] = {{39.2,53.4}}},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214098] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY] = {{64,39.2}}},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214099] = {
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE] = {{24.4,67.6}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214101] = {
            [npcKeys.spawns] = {[zoneIDs.DARNASSUS] = {{59.8,56.4}}},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214519] = {
            [npcKeys.spawns] = {
                [zoneIDs.REDRIDGE_MOUNTAINS] = {{77.6, 85.8}},
            },
        },
        [216902] = {
            [npcKeys.minLevel] = 30,
            [npcKeys.maxLevel] = 30,
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE]={{33.7,67.23}}},
            [npcKeys.zoneID] = zoneIDs.IRONFORGE,
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216915] = {
            [npcKeys.minLevel] = 35,
            [npcKeys.maxLevel] = 35,
            [npcKeys.spawns] = {[zoneIDs.ALTERAC_MOUNTAINS]={{35.43,72.45}}},
            [npcKeys.zoneID] = zoneIDs.ALTERAC_MOUNTAINS,
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216924] = {
            [npcKeys.minLevel] = 30,
            [npcKeys.maxLevel] = 30,
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{53.3,66.47}}},
            [npcKeys.zoneID] = zoneIDs.ORGRIMMAR,
            [npcKeys.friendlyToFaction] = "AH",
        },
        [217707] = {
            [npcKeys.name] = "Felore Moonray",
            [npcKeys.minLevel] = 99,
            [npcKeys.maxLevel] = 99,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{36.9,50.1}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        -- fake NPCs used for quests with too many starters
        [300000] = { -- 90008
            [npcKeys.name] = "Defias Pillager",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 15,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{31.4,45},{38.1,57.2},{42.9,67.7}},
            },
        },
        [300001] = { -- 90009
            [npcKeys.name] = "Dalaran Apprentice",
            [npcKeys.minLevel] = 13,
            [npcKeys.maxLevel] = 14,
            [npcKeys.zoneID] = zoneIDs.SILVERPINE_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {{51.2,60.6},{50.7,68.8},{55.9,73}},
            },
        },
        [300002] = { -- 90010
            [npcKeys.name] = "Polymorphed Apprentice",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{47.2,80.3}},
            },
        },
        [300003] = { -- 90011
            [npcKeys.name] = "Odd Melon",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{53.5,57.3}},
            },
        },
        [300004] = { -- 90015
            [npcKeys.name] = "Kobold Geomancer",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{61.8,53.2}},
            },
        },
        [300005] = { -- 90016
            [npcKeys.name] = "Frostmane Shadowcaster",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{25.2,50.7}},
            },
        },
        [300006] = { -- 90017
            [npcKeys.name] = "Burning Blade Fanatic",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{54.7,9.9},{42.5,26.3}},
            },
        },
        [300007] = { -- 90018
            [npcKeys.name] = "Scarlet Warrior",
            [npcKeys.minLevel] = 6,
            [npcKeys.maxLevel] = 7,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{32.6,47.9}},
            },
        },
        [300008] = { -- 90020
            [npcKeys.name] = "Stonesplinter Seer",
            [npcKeys.minLevel] = 13,
            [npcKeys.maxLevel] = 14,
            [npcKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{30.6,80.1},{36,83.2}},
            },
        },
        [300009] = { -- 90023
            [npcKeys.name] = "Grimtotem Tauren",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 15,
            [npcKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
            [npcKeys.spawns] = {
                [zoneIDs.STONETALON_MOUNTAINS] = {{74.2,91.6}},
            },
        },
        [300010] = { -- 90036
            [npcKeys.name] = "Harvest Watcher",
            [npcKeys.minLevel] = 14,
            [npcKeys.maxLevel] = 15,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{38.2,51.9}},
            },
        },
        [300011] = { -- 90036
            [npcKeys.name] = "Rusty Harvest Golem",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{54,32}},
            },
        },
        [300012] = { -- 90036
            [npcKeys.name] = "Dust Devil",
            [npcKeys.minLevel] = 18,
            [npcKeys.maxLevel] = 19,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{62.1,52.6}},
            },
        },
        [300013] = { -- 90036
            [npcKeys.name] = "Harvest Reaper Prototype",
            [npcKeys.minLevel] = 18,
            [npcKeys.maxLevel] = 18,
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{45.4,38.5}},
            },
        },
        [300014] = { -- 90016
            [npcKeys.name] = "Frostmane Seer",
            [npcKeys.minLevel] = 9,
            [npcKeys.maxLevel] = 10,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{40.7,43.6}},
            },
        },
        [300015] = { -- 90077
            [npcKeys.name] = "Wendigo",
            [npcKeys.minLevel] = 5,
            [npcKeys.maxLevel] = 6,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{42.6,53.7}},
            },
        },
        [300016] = { -- 90077
            [npcKeys.name] = "Wolf",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{44.6,46.5}},
            },
        },
        [300017] = { -- 90077
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{42.2, 35.4}},
            },
        },
        [300018] = { -- 90078
            [npcKeys.name] = "Kobold",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{61.8,53.2}},
            },
        },
        [300019] = { -- 90078
            [npcKeys.name] = "Gnoll",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{27.73,86.64}},
            },
        },
        [300020] = { -- 90079
            [npcKeys.name] = "Voodoo Troll",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{67.22,87.34}},
            },
        },
        [300021] = { -- 90079
            [npcKeys.name] = "Makrura",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.DURATAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{60.28,73.5}},
            },
        },
        [300022] = { -- 90079
            [npcKeys.name] = "Kul Tiran",
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 9,
            [npcKeys.zoneID] = zoneIDs.DURATAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{60.22,59.18}},
            },
        },
        [300023] = { -- 90079
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{67.4, 87.8}},
            },
        },
        [300024] = { -- 90080
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.UNDERCITY,
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{22.8, 42.8}},
            },
        },
        [300025] = { -- 90078
            [npcKeys.name] = "Soboz", -- duplicate of NPC 204070
            [npcKeys.minLevel] = 8,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{25.6, 78}},
            },
        },
        [300026] = { -- 90080
            [npcKeys.name] = "Darkeye Bonecaster",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{48.1,35.6}},
            },
        },
        [300027] = { -- 90080
            [npcKeys.name] = "Gnoll",
            [npcKeys.minLevel] = 7,
            [npcKeys.maxLevel] = 8,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{59.4,35.3}},
            },
        },
        [300028] = { -- 90080
            [npcKeys.name] = "Darkhound",
            [npcKeys.minLevel] = 5,
            [npcKeys.maxLevel] = 6,
            [npcKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{46.8,51.4}},
            },
        },
        [300029] = { -- 90078
            [npcKeys.name] = "Wolf",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{47.2,80.3}},
            },
        },
        [300029] = { -- 90085
            [npcKeys.name] = "Dark Iron Insurgent",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 1,
            [npcKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{58.95,13.51}},
            },
        },
        [300030] = { -- 968
            [npcKeys.name] = "Twilight Member",
            [npcKeys.minLevel] = 17,
            [npcKeys.maxLevel] = 17,
            [npcKeys.zoneID] = zoneIDs.DARKSHORE,
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{38.9,86.7}},
            },
        },
        [300031] = { -- 90035
            [npcKeys.name] = "Dark Strand Fanatic",
            [npcKeys.minLevel] = 16,
            [npcKeys.maxLevel] = 17,
            [npcKeys.zoneID] = zoneIDs.DARKSHORE,
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{56.2,26.8}},
            },
        },
    }
end
