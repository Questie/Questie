---@class CataNpcFixes
local CataNpcFixes = QuestieLoader:CreateModule("CataNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")

function CataNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local phases = Phasing.phases

    return {
        [2151] = { -- Moon Priestess Amara
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{49.35,44.67}}},
            [npcKeys.waypoints] = {},
        },
        [2988] = { -- Morin Cloudstalker
            [npcKeys.questStarts] = {749,26179,26180},
            [npcKeys.questEnds] = {749,24459,26179,26180},
        },
        [3594] = { -- Frahun Shadewhisper
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.8,33.8}}},
        },
        [7319] = { -- Lady Sathrah
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL]={{40.66,22.16}}},
        },
        [32959] = { -- Cerellean Whiteclaw
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{50.8,18.0},{50.13,19.46}}},
        },
        [34571] = { -- Gwen Armstead
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {37.41,63.35,phases.GILNEAS_CHAPTER_5},
                    {37.41,63.35,phases.GILNEAS_CHAPTER_6},
                },
            },
        },
        [34872] = { -- Foreman Dampwick
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {60.22,74.56,phases.KEZAN_CHAPTER_1},
                    {63.03,77.81,phases.KEZAN_CHAPTER_5},
                    {63.03,77.81,phases.KEZAN_CHAPTER_6},
                    {21.63,13.47,phases.KEZAN_CHAPTER_7},
                },
            },
        },
        [34874] = { -- Megs Dreadshredder
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {58.23,76.45,phases.KEZAN_CHAPTER_1},
                    {60.08,78.23,phases.KEZAN_CHAPTER_5},
                    {60.08,78.23,phases.KEZAN_CHAPTER_6},
                    {21.62,12.91,phases.KEZAN_CHAPTER_7},
                },
            },
        },
        [35222] = { -- Trade Prince Gallywix
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {50.48,59.89,phases.KEZAN_CHAPTER_1},
                    {56.7,76.9,phases.KEZAN_CHAPTER_2},
                    {16.7,26.06,phases.KEZAN_CHAPTER_5},
                    {20.84,13.69,phases.KEZAN_CHAPTER_7},
                },
            },
        },
        [35566] = { -- Lord Darius Crowley
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS_CITY] = {
                    {48.9,52.8,phases.LOST_ISLES_CHAPTER_3},
                    {48.9,52.8,phases.LOST_ISLES_CHAPTER_4},
                },
            },
        },
        [35875] = { -- Aggra
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {37.63,78.03,phases.LOST_ISLES_CHAPTER_1},
                    {37.63,78.03,phases.LOST_ISLES_CHAPTER_2},
                },
            },
        },
        [35906] = { -- Lord Godfrey
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS_CITY] = {
                    {65.6,77.6,phases.LOST_ISLES_CHAPTER_2},
                    {65.6,77.6,phases.LOST_ISLES_CHAPTER_3},
                },
            },
        },
        [36452] = {
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {37.63,65.23,phases.GILNEAS_CHAPTER_7},
                    {37.63,65.23,phases.GILNEAS_CHAPTER_8},
                },
            },
        },
        [36458] = { -- Grandma Wahl
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {32.52,75.48,phases.GILNEAS_CHAPTER_7},
                },
            },
        },
        [36743] = { -- King Genn Greymane
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {26.44,46.91,phases.GILNEAS_CHAPTER_8},
                },
            },
        },
        [37602] = { -- Claims Adjuster
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {59.6,76.48,phases.KEZAN_CHAPTER_6},
                },
            },
        },
        [37783] = { -- Lorna Crowley
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {70.88,39.84,phases.GILNEAS_CHAPTER_9},
                    {70.88,39.84,phases.GILNEAS_CHAPTER_10},
                },
            },
        },
        [37953] = { -- Dark Scout
            [npcKeys.waypoints] = {[zoneIDs.GILNEAS]={{66.10,81.01},{65.89,81.14},{65.68,81.26},{65.46,81.31},{65.24,81.31},{65.02,81.31},{64.80,81.31},{64.57,81.31},{64.35,81.31},{64.13,81.31},{63.90,81.30},{63.68,81.30},{63.46,81.30},{63.24,81.31},{63.01,81.34},{62.81,81.46},{62.61,81.62},{62.51,81.74}}},
        },
        [38144] = { -- Krennan Aranas
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {49.84,56.92,phases.GILNEAS_CHAPTER_11},
                    {49.84,56.92,phases.GILNEAS_CHAPTER_12},
                },
            },
        },
        [38387] = { -- Sassy Hardwrench
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {45.18,64.9,phases.LOST_ISLES_CHAPTER_5},
                    {45.18,64.9,phases.LOST_ISLES_CHAPTER_6},
                    {45.18,64.9,phases.LOST_ISLES_CHAPTER_7},
                    {37.3,41.9,phases.LOST_ISLES_CHAPTER_8},
                    {43.63,25.32,phases.LOST_ISLES_CHAPTER_9},
                    {42.57,16.38,phases.LOST_ISLES_CHAPTER_10},
                },
            },
        },
        [38553] = { -- Krennan Aranas
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {70.05,40.89,phases.GILNEAS_CHAPTER_9},
                    {70.05,40.89,phases.GILNEAS_CHAPTER_10},
                },
            },
        },
        [38539] = { -- King Genn Greymane
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {57.03,52.98,phases.GILNEAS_CHAPTER_10},
                    {57.03,52.98,phases.GILNEAS_CHAPTER_11},
                },
            },
        },
        [38611] = { -- Lorna Crowley
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {58.8,53.89,phases.GILNEAS_CHAPTER_10},
                    {58.8,53.89,phases.GILNEAS_CHAPTER_11},
                },
            },
        },
        [38935] = { -- Thrall
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {36.79,43.13,phases.LOST_ISLES_CHAPTER_5},
                    {36.79,43.13,phases.LOST_ISLES_CHAPTER_8},
                    {42.16,17.37,phases.LOST_ISLES_CHAPTER_10},
                },
            },
        },
        [39065] = { -- Aggra
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {36.26,43.37,phases.LOST_ISLES_CHAPTER_5},
                    {36.26,43.37,phases.LOST_ISLES_CHAPTER_8},
                    {42.55,18.22,phases.LOST_ISLES_CHAPTER_9},
                    {42.19,17.4,phases.LOST_ISLES_CHAPTER_10},
                },
            },
        },
        [41600] = { -- Erunak Stonespeaker
            [npcKeys.spawns] = {
                [zoneIDs.ABYSSAL_DEPTHS] = {{51.57,60.9}},
            },
        },
        [41636] = { -- Legionnaire Nazgrim
            [npcKeys.spawns] = {
                [zoneIDs.ABYSSAL_DEPTHS] = {{42.66,37.82}},
            },
        },
        [42288] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{50.56,71.89}},
            },
        },
        [42644] = { -- Smoot
            [npcKeys.waypoints] = {[zoneIDs.AZSHARA]={{56.89,49.26},{56.84,49.43},{56.73,49.64},{56.65,49.86},{56.60,50.03},{56.58,50.19},{56.65,49.94},{56.72,49.70},{56.80,49.46},{56.89,49.26},{56.98,49.33},{57.12,49.49},{57.28,49.60},{57.45,49.67},{57.50,49.69},{57.58,49.85},{57.71,49.96},{57.85,49.79},{58.00,49.65},{58.13,49.77},{58.13,49.89},{58.17,49.70},{58.21,49.45},{58.06,49.42},{57.89,49.49},{57.73,49.60},{57.56,49.61},{57.51,49.57},{57.36,49.53},{57.19,49.47},{57.02,49.38},{56.90,49.20},{56.81,48.97},{56.70,48.75},{56.58,48.56},{56.45,48.37},{56.31,48.22},{56.27,48.18},{56.26,48.20},{56.13,48.38},{56.00,48.57},{55.87,48.75},{55.75,48.94},{55.63,49.14},{55.56,49.25},{55.51,49.32},{55.39,49.51},{55.27,49.71},{55.23,49.78},{55.22,49.92},{55.24,50.18},{55.36,50.32},{55.46,50.12},{55.37,49.90},{55.29,49.89},{55.22,50.09},{55.26,50.35},{55.33,50.60},{55.40,50.84},{55.50,51.06},{55.62,51.24},{55.76,51.41},{55.90,51.58},{56.07,51.64},{56.24,51.74},{56.33,51.86},{56.35,51.71},{56.40,51.45},{56.46,51.20},{56.54,50.96},{56.60,50.71},{56.61,50.45},{56.61,50.18},{56.47,50.20},{56.43,50.24},{56.51,50.46},{56.58,50.69},{56.53,50.95},{56.45,51.19},{56.35,51.41},{56.27,51.64},{56.25,51.72},{56.36,51.93},{56.38,52.02},{56.30,51.87},{56.17,51.70},{56.01,51.58},{55.95,51.54},{55.80,51.40},{55.66,51.24},{55.53,51.07},{55.41,50.87},{55.37,50.70},{55.36,50.67},{55.32,50.41},{55.22,50.20},{55.17,49.94},{55.29,49.81},{55.30,49.81},{55.35,49.89},{55.48,50.06},{55.62,50.22},{55.79,50.31},{55.94,50.19},{55.94,50.18},{55.95,50.15},{56.00,49.94},{56.15,50.09},{56.31,50.21},{56.47,50.23},{56.58,50.42},{56.60,50.68},{56.54,50.93},{56.52,51.04},{56.46,51.29},{56.47,51.30},{56.64,51.34},{56.82,51.36},{57.00,51.39},{57.17,51.41},{57.35,51.39},{57.48,51.23},{57.53,51.07},{57.61,50.88},{57.69,50.80},{57.83,50.93},{57.84,51.18},{57.72,51.36},{57.64,51.37},{57.46,51.38},{57.28,51.36},{57.22,51.36},{57.09,51.39},{56.91,51.38},{56.74,51.39},{56.56,51.36},{56.46,51.27},{56.50,51.15},{56.56,50.90},{56.63,50.65},{56.64,50.52},{56.60,50.36},{56.56,50.21},{56.56,50.20},{56.63,49.95},{56.72,49.73},{56.81,49.49},{56.89,49.36},{57.01,49.42},{57.17,49.54},{57.35,49.58},{57.42,49.60},{57.55,49.79},{57.66,49.99},{57.69,50.03},{57.69,50.05},{57.71,50.31},{57.67,50.56},{57.57,50.78},{57.52,50.94},{57.46,51.03},{57.32,51.19},{57.17,51.31},{56.99,51.36},{56.82,51.34},{56.64,51.30},{56.51,51.27},{56.51,51.16},{56.55,50.90},{56.61,50.65},{56.59,50.38},{56.57,50.19},{56.43,50.18},{56.25,50.18},{56.07,50.17},{55.90,50.22},{55.72,50.26},{55.59,50.21},{55.53,50.12},{55.39,49.95},{55.31,49.88},{55.32,49.89},{55.41,49.98},{55.42,49.99},{55.56,50.15},{55.71,50.29},{55.87,50.23},{56.03,50.16},{56.21,50.17},{56.39,50.20},{56.56,50.21},{56.58,50.21},{56.60,50.05},{56.66,49.80},{56.75,49.57},{56.86,49.36},{56.89,49.29}}},
        },
        [43792] = { -- Therazane
            [npcKeys.questStarts] = {26709,28824},
        },
        [44025] = { -- Therazane
            [npcKeys.spawns] = {
                [zoneIDs.DEEPHOLM] = {
                    {63.33,24.95,phases.THE_STONE_MARCH},
                    {63.33,24.95,phases.TEMPLE_OF_EARTH_CHAPTER_1},
                },
            },
        },
        [45362] = { -- Earthcaller Yevaa
            [npcKeys.spawns] = {
                [zoneIDs.TWILIGHT_HIGHLANDS] = {
                    {44.21,18.13,phases.UNKNOWN},
                    {44.21,18.13,phases.TWILIGHT_GATE},
                },
            },
        },
        [46316] = { -- Gimme Shelter Kill Credit 00
            [npcKeys.spawns] = {},
        },
        [47493] = { -- Warlord Krogg
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{29.6,41,phases.GRIM_BATOL_ATTACK_HORDE}}},
        },
        [47838] = { -- Shrine 1 Cleansed
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{34.18,35.74}}},
            [npcKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [47839] = { -- Shrine 1 Cleansed
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{33.59,37.76}}},
            [npcKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [47840] = { -- Shrine 1 Cleansed
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{34.33,37.75}}},
            [npcKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [48264] = { -- Golluck Rockfist
            [npcKeys.spawns] = {
                [zoneIDs.TWILIGHT_HIGHLANDS] = {
                    {44.08,10.54,phases.UNKNOWN},
                    {44.08,10.54,phases.ISORATH_NIGHTMARE},
                },
            },
        },
        [48265] = { -- Lauriel Trueblade
            [npcKeys.spawns] = {
                [zoneIDs.TWILIGHT_HIGHLANDS] = {
                    {44.08,10.54,phases.UNKNOWN},
                    {44.08,10.54,phases.ISORATH_NIGHTMARE},
                },
            },
        },
        [49456] = { -- Finkle\'s Mole Machine
            [npcKeys.spawns] = {
                [zoneIDs.MOUNT_HYJAL] = {{42.7,28.8}},
            },
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [49476] = { -- Finkle Einhorn
            [npcKeys.questStarts] = {28735,28737,28738,28740,28741},
        },
        [49893] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{51.62,72.38}},
            },
        },
        [52189] = {
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{57.78,53.06},{57.71,53.28}},
            },
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
        },
        [53540] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{83.97,51.69}},
            },
        },
    }
end

-- This should allow manual fix for NPC availability
function CataNpcFixes:LoadFactionFixes()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    local npcFixesHorde = {
        --[[[15898] = {
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR]={{41.27,32.36}},
                [zoneIDs.THUNDER_BLUFF]={{70.56,27.83}},
                [zoneIDs.UNDERCITY]={{66.45,36.02}},
                [zoneIDs.MOONGLADE]={{36.58,58.1},{36.3,58.53}},
                [zoneIDs.SHATTRATH_CITY]={{52.63,33.25},{48.64,36.29}},
                [zoneIDs.SILVERMOON_CITY]={{73.41,82.17}},
                [zoneIDs.DALARAN]={{47.93,43.32}},
            },
        },
        [26221] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY]={{66.9,13.53}},[zoneIDs.ORGRIMMAR]={{46.44,38.69}},[zoneIDs.THUNDER_BLUFF]={{22.16,23.98}},[zoneIDs.SHATTRATH_CITY]={{60.68,30.62}},[zoneIDs.SILVERMOON_CITY]={{68.67,42.94}}},
        },
        [34806] = {
            [npcKeys.name] = "Spirit of Sharing",
            [npcKeys.spawns] = {
                [zoneIDs.STORM_PEAKS]={{40.38,85.5}},
                [zoneIDs.ZUL_DRAK]={{41.2,68.25}},
                [zoneIDs.GRIZZLY_HILLS]={{22.43,65.94}},
                [zoneIDs.HOWLING_FJORD]={{49.14,13.05}},
                [zoneIDs.DRAGONBLIGHT]={{37.25,47.11}},
                [zoneIDs.BOREAN_TUNDRA]={{40.95,52.44},{40.62,52.88}},
                [zoneIDs.SHOLAZAR_BASIN]={{47.59,60.92}},
                [zoneIDs.SHATTRATH_CITY]={{43.42,51.93},{43.17,50.29},{42.96,48.61},{42.7,46.84}},
                [zoneIDs.SHADOWMOON_VALLEY]={{29.97,28.77}},
                [zoneIDs.NAGRAND]={{56.65,33.94}},
                [zoneIDs.ZANGARMARSH]={{32.75,51.19}},
                [zoneIDs.BLADES_EDGE_MOUNTAINS]={{52.28,54.96}},
                [zoneIDs.NETHERSTORM]={{33.9,64.43}},
                [zoneIDs.HELLFIRE_PENINSULA]={{56.44,38.39},{56.02,37.74}},
                [zoneIDs.WINTERSPRING]={{60.26,36.41}},
                [zoneIDs.TANARIS]={{51.95,25.55}},
                [zoneIDs.SILITHUS]={{51.89,37.71}},
                [zoneIDs.FERALAS]={{74.88,43.33}},
                [zoneIDs.THOUSAND_NEEDLES]={{45.54,51.59}},
                [zoneIDs.STRANGLETHORN_VALE]={{32.35,28.3}},
                [zoneIDs.SWAMP_OF_SORROWS]={{46.2,56.66}},
                [zoneIDs.BURNING_STEPPES]={{63.96,31.66}},
                [zoneIDs.BADLANDS]={{5.02,48.98}},
                [zoneIDs.ARATHI_HIGHLANDS]={{74.86,36.88}},
                [zoneIDs.HILLSBRAD_FOOTHILLS]={{61.03,20.84}},
                [zoneIDs.THE_HINTERLANDS]={{79,80.76}},
                [zoneIDs.EASTERN_PLAGUELANDS]={{74.11,52.14}},
                [zoneIDs.DUROTAR]={{46.32,14.58},{46.37,15.08},{46.66,15.02},{46.64,14.58},{52.98,43.89},{52.99,43.54}},
                [zoneIDs.GHOSTLANDS]={{44.85,30.98}},
                [zoneIDs.EVERSONG_WOODS]={{55.65,53.15},{55.61,53.53},{55.3,53.18},{55.29,53.64},{46.52,46.64},{46.5,46.94},{46.46,47.27}},
                [zoneIDs.UNDERCITY]={{64.1,14.23},{67.82,14.3},{67.98,7.85},{64.37,7.86}},
                [zoneIDs.TIRISFAL_GLADES]={{58.81,51.17},{59.12,51.21},{59.38,51.26}},
                [zoneIDs.SILVERPINE_FOREST]={{44.33,42.33}},
                [zoneIDs.THUNDER_BLUFF]={{29.83,62.24},{31.24,66.99},{30.21,67.43},{28.76,62.4}},
                [zoneIDs.MULGORE]={{46.43,59.57},{46.23,59.77}},
                [zoneIDs.THE_BARRENS]={{51.52,29.52},{51.62,29.42},{62.48,38.22}},
                [zoneIDs.STONETALON_MOUNTAINS]={{46.25,59.98}},
                [zoneIDs.ASHENVALE]={{73.9,60.47}},
                [zoneIDs.DUSTWALLOW_MARSH]={{35.68,31.53}},
                [zoneIDs.DESOLACE]={{25.41,72.09}},
            },
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
        [37917] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST]={{55.2,61.0},{55.3,62.0},{54.9,63.1},{54.6,62.3}}},
        },
        [37214] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{40.3,15.8},{40.1,15.5},{40.5,15.5},{40.5,15.2},{40.3,15.0}}},
        },]] -- copied from wotlk fixes, need to edit these when we get the events live
        [29579] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{36.62,49.27}}},
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
        --[[[15898] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY]={{37.32,64.04}},
                [zoneIDs.IRONFORGE]={{29.92,14.21}},
                [zoneIDs.DARNASSUS]={{34.57,12.8}},
                [zoneIDs.MOONGLADE]={{36.58,58.1},{36.3,58.53}},
                [zoneIDs.SHATTRATH_CITY]={{52.63,33.25},{48.64,36.29}},
                [zoneIDs.THE_EXODAR]={{74.02,58.23}},
                [zoneIDs.DALARAN]={{47.93,43.32}},
            },
        },
        [26221] = {
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL]={{56.1,92.16}},[zoneIDs.SHATTRATH_CITY]={{60.68,30.62}},[zoneIDs.IRONFORGE]={{65.14,27.71}},[zoneIDs.STORMWIND_CITY]={{49.32,72.3}},[zoneIDs.THE_EXODAR]={{43.27,26.26}}},
        },
        [34806] = {
            [npcKeys.name] = "Spirit of Sharing",
            [npcKeys.spawns] = {
                [zoneIDs.STORM_PEAKS]={{40.38,85.5}},
                [zoneIDs.ZUL_DRAK]={{41.2,68.25}},
                [zoneIDs.GRIZZLY_HILLS]={{31.3,59.59}},
                [zoneIDs.HOWLING_FJORD]={{60.45,16.74}},
                [zoneIDs.DRAGONBLIGHT]={{77.78,50.85}},
                [zoneIDs.BOREAN_TUNDRA]={{56.93,67.48},{56.92,67.82}},
                [zoneIDs.SHOLAZAR_BASIN]={{47.59,60.92}},
                [zoneIDs.SHATTRATH_CITY]={{43.42,51.93},{43.17,50.29},{42.96,48.61},{42.7,46.84}},
                [zoneIDs.SHADOWMOON_VALLEY]={{37.78,55.62}},
                [zoneIDs.NAGRAND]={{54.03,75.49}},
                [zoneIDs.ZANGARMARSH]={{67.72,51.16}},
                [zoneIDs.BLADES_EDGE_MOUNTAINS]={{37.9,61.97}},
                [zoneIDs.NETHERSTORM]={{33.9,64.43}},
                [zoneIDs.HELLFIRE_PENINSULA]={{55.07,63.22},{56.45,63.92}},
                [zoneIDs.THE_EXODAR]={{75.74,52.29},{75.75,50.51},{76.95,51.26},{77.21,53.08}},
                [zoneIDs.AZUREMYST_ISLE]={{51.71,52.11},{51.69,51.14}},
                [zoneIDs.BLOODMYST_ISLE]={{56.03,58.75}},
                [zoneIDs.DARKSHORE]={{36.91,43.65}},
                [zoneIDs.WINTERSPRING]={{62.17,37.03}},
                [zoneIDs.DARNASSUS]={{69.56,38.23},{67.85,38.08},{67.81,36.09},{69.47,36.08}},
                [zoneIDs.TELDRASSIL]={{56.44,58.4},{56.36,56.92}},
                [zoneIDs.TANARIS]={{51.2,29.42}},
                [zoneIDs.SILITHUS]={{51.89,37.71}},
                [zoneIDs.FERALAS]={{29.96,43.41}},
                [zoneIDs.ELWYNN_FOREST]={{34.33,51.18},{34.58,50.81},{34.81,50.45},{41.52,64.04},{41.43,64.65},{41.67,64.83}},
                [zoneIDs.DUN_MOROGH]={{52.77,36.41},{52.76,36.74},{52.76,37.03},{46.69,55.41},{46.66,55.12},{46.64,54.75},{46.19,52.91}},
                [zoneIDs.WESTFALL]={{53.21,52.61}},
                [zoneIDs.STRANGLETHORN_VALE]={{37.87,3.78}},
                [zoneIDs.DUSKWOOD]={{77.64,43.85}},
                [zoneIDs.BLASTED_LANDS]={{66.54,23.66}},
                [zoneIDs.REDRIDGE_MOUNTAINS]={{32.23,53.35}},
                [zoneIDs.BURNING_STEPPES]={{85.83,69.78}},
                [zoneIDs.LOCH_MODAN]={{32.16,48.4}},
                [zoneIDs.WETLANDS]={{9.19,60.77},},
                [zoneIDs.ARATHI_HIGHLANDS]={{46,45.97}},
                [zoneIDs.HILLSBRAD_FOOTHILLS]={{49.61,61.05}},
                [zoneIDs.THE_HINTERLANDS]={{13.91,46.87}},
                [zoneIDs.EASTERN_PLAGUELANDS]={{74.81,54.22}},
                [zoneIDs.WESTERN_PLAGUELANDS]={{43.73,84.72}},
                [zoneIDs.THE_BARRENS]={{62.64,38.23}},
                [zoneIDs.DUSTWALLOW_MARSH]={{68,50.78}},
                [zoneIDs.DESOLACE]={{65.19,8.73}},
                [zoneIDs.ASHENVALE]={{35.26,50.41}},
            },
        },
        [37214] = {
            [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST]={{29.1,66.5},{28.8,66.2},{29.5,65.7},{28.8,65.7},{29.2,65.2}}},
        },
        [37917] = {
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{43.3,79.9},{43.2,79.9},{43.2,79.5},{42.7,79.5},{43.0,79.4}}},
        },
        [38340] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{63.08,78.86}}},
        },
        [38341] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{60.81,70.03}}},
        },
        [38342] = {
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{61.33,65.64}}},
        },]] -- copied from wotlk fixes, need to edit these when we get the events live
        [29579] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{30.1,73.9}}},
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
