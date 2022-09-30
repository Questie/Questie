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

    return {
        [15351] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{24.55,55.42}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
            },
        },
        [16281] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.39}}},
        },
        [16361] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.45}}},
        },
        [17977] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BOTANICA]={{-1,-1}}},
        },
        [19220] = {
            [npcKeys.spawns] = {[zoneIDs.THE_MECHANAR]={{-1,-1}}},
        },
        [23763] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{50.2,29.2},{50.4,26.4},{50.4,27},{50.6,26.6},{51,26.2},{51,27.6},{51.2,25.4},{51.2,28.8},{51.6,25.4},{51.8,27.6},{52,29.6},{52.2,26.4},{52.2,26.6},{52.4,28.6},{52.6,28.6},{52.8,26.4},{52.8,27},{52.8,27.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [23954] = {
          [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP]={{-1,-1},}},
          [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [24060] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{45.2,27.3}}},
        },
        [24120] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{86.7,59.2}}},
        },
        [24130] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{45.2,27.3}}},
        },
        [24137] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP]={{-1,-1},}},
            [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [24170] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{39.2,50.2},}},
        },
        [24173] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{52.4,3.9},}},
        },
        [24329] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{72,26.4},{70.3,27.3},{68.7,28.1},{66.5,24.9},{69.7,21.5},{72.6,19.9},{73.6,23.1}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
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
        [24910] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{38.1, 74.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [25455] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{50.25,9.66},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25794] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{70.3,36.7},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [26170] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{84.8,41.68},},},
        },
        [26647] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{54.4,23.4}},
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [26723] = {
            [npcKeys.spawns] = {[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [27216] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{45.25,17.33}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [27315] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{77.2,49.8},{78.2,50.6},{78.8,50.8},{79.8,49.6},{80,49.4},{80,51},{81.8,50.6},{82.2,50.4},{83,49.2},{83,50.2},{83.4,51},{84.2,50.4},{84.6,51.6},{84.8,50.4},}
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [27959] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{61.1,2}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [28026] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{35.21,64.79},{37.15,64.77},{36.51,64.55},{37.99,65.5},},},
        },
        [28070] = {
            [npcKeys.spawns] = {[zoneIDs.HALLS_OF_STONE]={{-1,-1},{67.43,49.53}},},
            [npcKeys.zoneID] = zoneIDs.HALLS_OF_STONE,
        },
        [28083] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{49.8,85},{51.6,86.2},{58,83.8},{58.8,85.6},},},
        },
        [28358] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{57.4,52.2},{58.4,53.8},},},
        },
        [28912] = {
            [npcKeys.waypoints] = {},
        },
        [29173] = {
            [npcKeys.waypoints] = {},
        },
        [30082] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{38.2,61.6},},},
        },
        [30295] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{56.3,51.4},},},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30382] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{39.4,56.4},},},
        },
        [31134] = {
            [npcKeys.spawns] = {[zoneIDs.VIOLET_HOLD] = {{-1,-1},},},
            [npcKeys.zoneID] = zoneIDs.VIOLET_HOLD,
        },
        [38042] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{52.8,76.8}},},
        },
        [38043] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{64.6,66.2}},},
        },
        [38044] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF] = {{44,52.8}},},
        },
        [38045] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY] = {{66.6,38.6}},},
        },
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