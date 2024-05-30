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
        [658] = { -- Sten Stoutarm
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH] = {{36.55,70.41}}},
        },
        [1494] = { -- Negolash
            [npcKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN] = {{50.75,79.65}}},
        },
        [1514] = { -- Mokk the Savage
            [npcKeys.spawns] = {[zoneIDs.THE_CAPE_OF_STRANGLETHORN] = {{52.99,50.22}}},
        },
        [2039] = { -- Ursal the Mauler
            [npcKeys.waypoints] = {},
        },
        [2079] = { -- Ilthalaine
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {
                    {57.97,39.2,phases.ILTHALAINE_AT_BENCH},
                    {58.13,38.94,phases.ILTHALAINE_AT_ROAD},
                },
            },
            [npcKeys.waypoints] = {},
        },
        [2070] = { -- Moonstalker Runt
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{45.27,61.66},{41.75,63.49},{43.12,63.94},{41.47,65.86},{39.22,69.96},{39.94,70.13},{41.28,88.16},{45.73,89.78},{38.47,90.28}}},
            [npcKeys.zoneID] = zoneIDs.DARKSHORE,
        },
        [2151] = { -- Moon Priestess Amara
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{49.35,44.67}}},
            [npcKeys.waypoints] = {},
        },
        [2964] = { -- Windfury Sorceress
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE]={{34.12,28.06},{33.51,30.48},{34.68,26.31},{32.96,26.33},{31.81,28.09},{31.01,28.9},{31.13,28.04},{30.34,27.01},{29.58,22.98},{30.3,24.52},{31.94,26.01},{30.62,26.01},{31.23,25.43},{31.44,24.26},{30.96,23.84},{30.5,22.24},{31.68,22.15},{32.15,21.59},{33,21.67},{54.87,17.8},{55.82,18.38},{55.76,17.33},{56.03,16.44},{55,14.13},{54.2,13.45},{53.9,14.45},{53.78,12.46},{52.57,11.4},{53.22,8.87},{51.9,9.8},{51.17,9.68},{51.65,7.98},{41.06,10.04},{40.09,10.83},{39.96,8.73},{38.6,8.65},{38.64,10.73},{39.4,11.43},{55.44,19.75},{32.74,23.61}},
                [zoneIDs.THUNDER_BLUFF]={{12.66,28.9}},
            },
        },
        [2965] = { -- Windfury Matriarch
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE]={{32.29,27.02},{33.67,25.74},{32.8,25.28},{33.16,27.58},{33.89,26.71},{34.98,27.34},{34.77,28.72},{34.26,29.79},{33.35,29.03},{32.68,29.9},{32.5,28.84},{31.73,29.16},{31.36,26.77},{30.77,24.76},{30.37,23.36},{30.85,21.47},{31.53,21.18},{31.09,22.54},{31.52,23.36},{32.18,23.45},{32.49,22.48},{40.76,10.77},{40.36,9.71},{40.72,8.89},{41.41,7.81},{40.43,7.95},{39.43,8.09},{38.67,9.84},{38.56,12.08},{55.3,18.71},{55.89,15.44},{55.59,14.57},{54.85,12.95},{55.07,12.39},{54.68,11.54},{53.32,13.21},{52.39,12.33},{51.77,11.21},{53.37,10.66},{53.45,9.77},{52.56,8.07},{52.07,8.8},{51.13,8.58},{50.53,7.76}},
                [zoneIDs.THUNDER_BLUFF]={{17.31,33.02},{15.11,24.27}},
            },
        },
        [2988] = { -- Morin Cloudstalker
            [npcKeys.questStarts] = {749,26179,26180},
            [npcKeys.questEnds] = {749,24459,26179,26180},
            [npcKeys.waypoints] = {},
        },
        [3389] = { -- Regthar Deathgate
            [npcKeys.questStarts] = {851,852,855,4021},
        },
        [3475] = { -- Echeyakee
            [npcKeys.spawns] = {[zoneIDs.THE_BARRENS] = {{56.4,34.9}}},
        },
        [3515] = { -- Corithras Moonrage
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {
                    {41.07,45.66,phases.CORITHRAS_AT_CROSSROAD},
                    {55.82,53.9,phases.CORITHRAS_AT_DOLANAAR},
                },
            },
        },
        [3593] = { -- Alyissia
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.85,33.74}}},
        },
        [3594] = { -- Frahun Shadewhisper
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.85,33.92}}},
        },
        [3595] = { -- Shanda
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.45,35.47}}},
        },
        [3596] = { -- Ayanna Everstride
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.85,35.74}}},
        },
        [3694] = { -- Sentinel Selarin
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE] = {{42.51,45.15}}},
        },
        [3901] = { -- Illiyana
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{87.1,43.49}}},
        },
        [3943] = { -- Ruuzel
            [npcKeys.waypoints] = {},
        },
        [3987] = { -- Dal Bloodclaw
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{41.66,35.7}}},
            [npcKeys.waypoints] = {},
        },
        [7319] = { -- Lady Sathrah
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL]={{40.66,22.16}}},
        },
        [9684] = { -- Lar'korwi
            [npcKeys.spawns] = {[zoneIDs.UN_GORO_CRATER] = {{69.98,40.96}}},
        },
        [10445] = { -- Selina Dourman
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{55.56,55.01},{-1,-1}}},
        },
        [10878] = { -- Herald Moonstalker
            [npcKeys.waypoints] = {}, -- to do
        },
        [10916] = { -- Winterfall Runner
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING]={{21.24,46.13}}},
            [npcKeys.waypoints] = {[zoneIDs.WINTERSPRING]={{{21.24,46.13},{21.29,46.27},{21.38,46.62},{21.42,46.99},{21.41,47.36},{21.41,47.74},{21.40,48.12},{21.43,48.49},{21.52,48.84},{21.61,49.19},{21.71,49.56},{21.79,49.90},{21.85,50.26},{21.89,50.64},{21.93,51.01},{21.96,51.38},{21.96,51.70},{22.10,52.01},{22.24,52.32},{22.38,52.63},{22.54,52.92},{22.69,53.20},{22.97,53.75},{23.27,54.36},{23.58,54.98},{23.96,55.48},{24.47,55.49},{24.98,55.40},{25.49,55.30},{26.00,55.22},{26.51,55.14},{27.03,55.06},{27.54,54.98},{28.05,54.90},{28.56,54.82},{29.07,54.74},{29.58,54.66},{29.81,54.63},{30.10,54.95},{30.61,55.03},{30.75,55.05},{31.10,55.10},{31.16,55.10},{31.20,55.10},{31.65,55.08},{31.99,55.10},{32.49,54.94},{32.98,54.75},{33.47,54.50},{33.95,54.24},{34.44,53.99},{34.92,53.74},{35.41,53.51},{35.85,53.23},{36.23,53.11},{36.68,52.96},{37.16,52.84},{37.67,52.76},{38.18,52.68},{38.69,52.60},{39.20,52.53},{39.70,52.48},{40.20,52.42},{40.70,52.37},{41.20,52.31},{41.70,52.26},{42.20,52.20},{42.71,52.14},{43.22,52.09},{43.70,51.90},{44.17,51.60},{44.64,51.30},{45.11,51.00},{45.57,50.66},{45.99,50.23},{46.42,49.80},{46.84,49.37},{47.27,48.94},{47.76,48.72},{48.23,48.43},{48.70,48.11},{49.16,47.76},{49.60,47.38},{50.04,46.98},{50.42,46.47},{50.73,45.85},{50.99,45.27},{51.02,45.10},{51.11,44.46},{51.21,43.71},{51.31,42.96},{51.41,42.21},{51.48,41.45},{51.47,40.69},{51.46,39.92},{51.31,39.24},{51.32,38.95},{51.33,38.31},{51.32,37.55},{51.30,36.79},{51.52,36.41},{51.63,35.68},{51.73,34.94},{51.87,34.21},{52.08,33.55},{52.49,33.31},{52.70,33.36},{52.75,33.37},{53.26,33.43},{53.77,33.47},{54.28,33.54},{54.73,33.72},{55.21,33.92},{55.24,33.96},{55.14,34.51},{55.50,34.92},{55.95,35.12},{56.29,35.21},{56.33,35.22},{56.67,35.21},{57.07,34.92},{57.22,34.79},{57.29,34.76},{57.76,34.66},{58.26,34.68},{58.73,34.91},{59.22,34.80},{59.63,34.60},{60.02,34.16},{60.40,33.88},{60.80,33.96},{60.91,34.62},{61.00,35.33},{61.14,36.00},{61.47,36.53},{61.82,37.09},{62.13,37.70},{62.45,38.30},{62.76,38.82},{63.06,39.34},{63.45,39.85},{63.84,40.34},{64.21,40.80},{64.53,41.31},{64.88,41.86},{65.24,42.41},{65.55,42.99},{65.57,43.67},{65.47,44.38},{65.64,45.08},{65.89,45.74},{66.14,46.42},{66.33,47.03},{66.45,47.35}}}},
        },
        [10920] = { -- Kelek Skykeeper
            [npcKeys.questStarts] = {28479,28537,28848},
            [npcKeys.questEnds] = {28471,28536,28537},
        },
        [12759] = { -- Fury Shelda
            [npcKeys.waypoints] = {},
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{48.22,69.74}}},
        },
        [14431] = { -- Fury Shelda
            [npcKeys.waypoints] = {},
        },
        [14444] = { -- Orcish Orphan
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{58.18,57.5}}},
        },
        [14822] = { -- Sayge
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{53.24,75.84},{-1,-1}}},
        },
        [14823] = { -- Silas Darkmoon
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{49.49,71.01},{-1,-1}}},
        },
        [14827] = { -- Burth
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{49.52,71.35},{-1,-1}}},
        },
        [14828] = { -- Gelvas Grimegate
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{47.77,64.78},{-1,-1}}},
        },
        [14829] = { -- Yebb Neblegear
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{51.1,82.05},{-1,-1}}},
        },
        [14832] = { -- Yebb Neblegear
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{47.9,67.12},{-1,-1}}},
        },
        [14833] = { -- Chronos
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{55,70.77},{-1,-1}}},
        },
        [14841] = { -- Rinling
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{49.17,60.71},{-1,-1}}},
        },
        [14844] = { -- Sylannia
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{50.54,69.56},{-1,-1}}},
        },
        [14845] = { -- Stamp Thunderhorn
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{52.9,67.94},{-1,-1}}},
        },
        [14846] = { -- Lhara
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{48.09,69.55},{-1,-1}}},
        },
        [14847] = { -- Professor Thaddeus Paleo
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{51.89,60.93},{-1,-1}}},
        },
        [14849] = { -- Darkmoon Faire Carnie
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{44.79,88.94},{44.65,87.63},{48.75,69.37},{46.68,65.47},{44.88,87.5},{44.88,89.13},{43.65,87.1},{43.51,87.66},{51.59,68.07},{56.28,87.47},{51.97,55.09},{56.28,88.91},{53.47,84.33},{48.04,78.48},{56.38,87.15},{55.78,55.78},{-1,-1}}},
        },
        [14860] = { -- Flik
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{56.34,63.38},{-1,-1}}},
        },
        [14864] = { -- Khaz Modan Ram
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{58.16,82.88},{56.22,82.64},{57.76,81.98},{-1,-1}}},
        },
        [14865] = { -- Felinni
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{55.23,82.77},{-1,-1}}},
        },
        [14866] = { -- Flik's Frog
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{56.3,63.33},{-1,-1}}},
        },
        [14867] = { -- Jubjub
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{59.53,65.77},{57.38,64.09},{-1,-1}}},
        },
        [14868] = { -- Hornsley
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{53.71,82.42},{-1,-1}}},
        },
        [14871] = { -- Morja
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{55.93,70.73},{-1,-1}}},
        },
        [15303] = { -- Maxima Blastenheimer
            [npcKeys.spawns] = {[zoneIDs.DARKMOON_FAIRE_ISLAND]={{52.5,56.14},{-1,-1}}},
        },
        [15623] = { -- Xandivious
            [npcKeys.spawns] = {},
        },
        [17310] = { -- Gnarl
            [npcKeys.waypoints] = {},
        },
        [22819] = { -- Orphan Matron Mercy
            [npcKeys.spawns] = {[zoneIDs.SHATTRATH_CITY]={{75.07,47.88}}},
        },
        [23616] = { -- Kyle the Frenzied
            [npcKeys.spawns] = {[zoneIDs.MULGORE]={{48.48,61.57}}},
        },
        [28092] = { -- The Etymidian
            [npcKeys.spawns] = {[zoneIDs.UN_GORO_CRATER]={{47.38,9.21}}},
        },
        [32937] = { -- Tranquil Tidal Spirit
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{44.19,26.64},{43.5,27.26},{42.25,27.54},{43.09,28.12},{44.69,28.13},{43.66,28.55},{42.37,28.57},{44.33,28.99},{40.89,29.28},{44.82,29.52},{41.75,29.57},{42.4,29.59},{43.12,29.63},{43.49,29.94},{44.51,30.03},{42.71,30.46},{43.74,30.47},{44.01,31.01},{43.35,31.05}}},
        },
        [32959] = { -- Cerellean Whiteclaw
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE]={
                    {50.82,17.88,phases.CERELLEAN_NEAR_EDGE},
                    {50.13,19.46,phases.CERELLEAN_NEAR_TREE},
                },
            },
        },
        [33000] = { -- Spirit of Corruption
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{45.46,86.94},{44.52,86.88},{44.27,86.8},{45.75,86.43},{45.21,86.26},{44.75,86.25},{44.27,86},{43.61,84.91},{45.34,84.75},{44.97,84.64},{45.92,83.96},{45.29,83.64},{44.41,83.36},{46.32,83.35},{45.41,83.01},{44.36,82.9},{45.72,82.62},{45.1,82.56},{44.13,82.34},{45.71,82.13},{44.26,81.79},{43.58,81.66},{45.83,81.37},{44.8,81.33},{43.92,81.3},{43.89,80.82},{44.87,87.34},{46.56,87.07},{45.31,86.88},{44.8,86.75},{44.14,86.08},{46.51,85.71},{43.61,85.53},{44.28,85.49},{44.52,85},{45.65,84.98},{44.29,84.73},{45.34,84.2},{44.43,84.07},{45.06,84.01},{43.82,83.81},{45.88,83},{45.1,82.98},{43.97,82.92},{44.84,82.91},{46.14,82.76},{45.48,82.66},{44.55,82.5},{44.81,82.17}}},
            [npcKeys.zoneID] = zoneIDs.DARKSHORE,
        },
        [33181] = { -- Anaya Dawnrunner
            [npcKeys.waypoints] = {},
        },
        [33889] = { -- Krokk
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE]={{82.5,53.6}}},
        },
        [34009] = { -- Withered Ent
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{48.23,44.64},{48.01,43.58},{48.55,43.19},{48.19,43},{47.34,42.59},{47.94,42.46},{46.88,42.33},{47.3,42.24},{48.71,42.11},{48.24,41.84},{47.45,41.65},{46.98,41.56},{47.89,41.45},{48.85,40.95},{47.71,40.82},{47.21,40.45},{47.99,40.22},{48.43,40.11},{49.01,39.94},{46.87,39.79},{47.82,39.65},{47.3,39.51},{47.87,38.86},{49.05,38.86},{48.38,38.73},{49.24,38.19}}},
        },
        [34295] = { -- Lord Magmathar
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE]={{48.14,39.22}}},
        },
        [34365] = { -- Orphan Matron Aria
            [npcKeys.spawns] = {[zoneIDs.DALARAN]={{49.36,63.26}}},
        },
        [34398] = { -- Nightmare Guardian
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE]={{49.33,55.7}}},
            [npcKeys.waypoints] = {[zoneIDs.DARKSHORE]={{{50.02,55.25},{49.91,55.19},{49.79,55.18},{49.69,55.25},{49.60,55.36},{49.51,55.47},{49.42,55.58},{49.33,55.70},{49.23,55.84},{49.13,55.92},{49.02,55.99},{48.92,56.04}}}},
        },
        [34571] = { -- Gwen Armstead
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {37.41,63.35,phases.GILNEAS_CHAPTER_5},
                    {37.41,63.35,phases.GILNEAS_CHAPTER_6},
                },
            },
        },
        [34604] = { -- Big Baobob
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{22.22,52.88}}},
        },
        [34609] = { -- Demonic Invader
            [npcKeys.spawns] = {[zoneIDs.ASHENVALE] = {{22.38,53.06},{22.4,52.89},{22.31,52.63},{22.18,52.61},{22.03,52.75},{22.07,53.04},{22.25,53.1},{22.36,52.96}}},
            [npcKeys.zoneID] = zoneIDs.ASHENVALE,
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
        [35149] = { -- Talrendis Sniper
            [npcKeys.spawns] = {[zoneIDs.AZSHARA] = {{27.78,68.66},{28.73,69.61},{30.43,70.06},{31.44,69.46},{31.04,70.52},{35.43,80.8},{35.01,81.43},{35.02,79.8},{34.44,80.1},{34.26,79.18},{34.1,80.88},{32.4,77.91},{34.12,78.53},{33.52,78.09},{30.97,80.39},{32.89,79.42},{33.03,78.76},{32.23,78.92},{32.54,76.81},{31.6,79.23},{31.63,77.21},{31.11,72.15},{31.72,76.06},{31.14,78.24},{30.45,79.46},{29.73,70.75},{31.24,73.84},{30.12,71.35},{31.31,74.9},{30.55,76},{29.63,72.43},{30.17,73.63},{30.32,74.73},{23.15,73.3},{23.4,74.39},{22.67,74.05},{30.08,78.83},{29.73,77.96},{24.45,74.58}}},
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
        [35317] = { -- Squirming Slime Mold
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY]={{44,34.8},{48.1,44.7},{48.2,43.6},{48.3,45.5},{49.6,55},{50.5,30.4},{50.6,44.8},{50.7,41.8},{50.9,45.6},{51.3,41.3},{52,52.6},{52.3,35.8},{52.5,26},{52.7,31.7},{53,31.4},{53.2,57.3},{53.9,24.7},{55,60.4},{55,60.9},{55.1,64.4},{55.7,64.2},{56.3,21.6},{56.6,21.5},{56.6,62.4},{56.6,62.8},{57.3,64.9},{58,21.5},{58.4,21.1},{58.5,20.9},{58.6,68},{58.7,68.6},{59.7,18.9},{63.6,47},{63.7,39.7},{63.9,46.1},{64,48},{64,71.2},{64.1,21.7},{64.7,21.1},{64.7,66.9},{64.8,17.6},{64.9,21.8},{65,40.9},{65.3,70.6},{65.5,17.2},{65.5,39.9},{65.8,47.4},{65.9,21.1},{66,40.9},{66.3,47.5},{66.4,17.8},{66.6,40.5},{66.8,47.7},{67,71},{67.1,22.2},{67.9,40.3},{68.1,21.4},{68.4,47},{71.7,65.2},{72.9,68.5},{73,24.2},{73.3,68.4},{73.9,24.1},{74.3,65.4},{74.4,24.5},{74.5,24.4},{75.8,26.9},{75.9,66.2},{76.5,65.8},{77.3,23.3},{77.4,60.3},{77.5,26.6},{77.5,60.2},{77.6,24.2},{77.8,30.6},{77.9,29.6},{78.7,60.1},{78.9,31.1},{79,26.3},{79.1,32.1},{79.4,26.5},{79.4,61.6},{79.5,33.5},{79.8,27.4},{79.8,35.3},{79.9,27.6},{79.9,35.8},{80,36.6},{80,57.1},{80.3,59.4},{80.5,59.2},{80.7,28.4},{80.7,28.9},{80.7,45.5},{81,29.6},{81,46.5},{81.1,31.4},{81.1,32},{81.2,44.2},{81.2,44.9},{81.4,43},{81.6,31.5},{81.6,33.6},{81.7,56},{81.8,31.3},{82.7,33.9},{82.8,34.5},{83.6,41.9},{83.6,42.8},{83.7,40.1},{83.7,41.4},{83.7,44.9},{83.7,45.5},{83.8,43.6}}},
        },
        [35487] = { -- North Survey Marker Kill Credit
            [npcKeys.spawns] = {[zoneIDs.AZSHARA] = {{34.7,71.57}}},
        },
        [35488] = { -- West Survey Marker Kill Credit
            [npcKeys.spawns] = {[zoneIDs.AZSHARA] = {{34.28,76.64}}},
        },
        [35489] = { -- East Survey Marker Kill Credit
            [npcKeys.spawns] = {[zoneIDs.AZSHARA] = {{37.37,74.63}}},
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
                    {55.6,80.6,phases.LOST_ISLES_CHAPTER_2},
                    {55.6,80.6,phases.LOST_ISLES_CHAPTER_3},
                },
            },
        },
        [36452] = { -- Gwen Armstead
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
        [36644] = { -- Ahmo Thunderhorn
            [npcKeys.questStarts] = {24459,14438,14491},
            [npcKeys.questEnds] = {24215,14438,14491},
        },
        [36743] = { -- King Genn Greymane
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {26.44,46.91,phases.GILNEAS_CHAPTER_8},
                },
            },
        },
        [37115] = { -- Teo Hammerstorm
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH] = {{35.82,64.59}}},
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
            [npcKeys.waypoints] = {[zoneIDs.GILNEAS]={{{66.10,81.01},{65.89,81.14},{65.68,81.26},{65.46,81.31},{65.24,81.31},{65.02,81.31},{64.80,81.31},{64.57,81.31},{64.35,81.31},{64.13,81.31},{63.90,81.30},{63.68,81.30},{63.46,81.30},{63.24,81.31},{63.01,81.34},{62.81,81.46},{62.61,81.62},{62.51,81.74}}}},
        },
        [38144] = { -- Krennan Aranas
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {49.84,56.92,phases.GILNEAS_CHAPTER_11},
                    {49.84,56.92,phases.GILNEAS_CHAPTER_12},
                },
            },
        },
        [38150] = { -- Glaive Thrower
            [npcKeys.spawns] = {
                [zoneIDs.GILNEAS] = {
                    {42.91,37.24,phases.GILNEAS_CHAPTER_12},
                    {42.45,37.83,phases.GILNEAS_CHAPTER_12},
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
        [39096] = { -- Painmaster Thundrak
            [npcKeys.waypoints] = {[zoneIDs.ASHENVALE]={{{45.09,65.07},{44.87,65.16},{44.71,65.23},{44.62,65.15},{44.42,64.94},{44.32,64.84},{44.21,64.72},{44.18,64.68},{44.07,64.58},{43.88,64.38},{43.77,64.23},{43.66,64.08},{43.48,63.85},{43.46,63.82},{43.35,63.67},{43.33,63.65},{43.21,63.46},{43.12,63.36},{43.06,63.33},{42.92,63.45},{42.92,63.64},{42.93,63.75},{43.08,63.94},{43.19,63.94},{43.34,63.95},{43.44,63.98},{43.53,64.08},{43.61,64.16},{43.72,64.27},{43.91,64.47},{44.03,64.58},{44.18,64.75},{44.36,64.93},{44.39,64.96},{44.51,65.06},{44.58,65.14},{44.70,65.27},{44.86,65.30},{44.93,65.31},{45.13,65.28},{45.20,65.25},{45.34,65.19},{45.50,65.13},{45.57,65.11},{45.76,65.09},{45.90,65.07},{45.96,64.88},{45.97,64.67},{45.87,64.49},{45.77,64.52},{45.56,64.67},{45.46,64.85},{45.28,65.03},{45.22,65.05},{44.99,65.10}}}},
        },
        [39432] = { -- Takrik Ragehowl
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={
                {30.16,31.73,phases.HYJAL_CHAPTER_2},
                {28.45,29.88,phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE},
            }},
        },
        [39433] = { -- Ian Duran
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={
                {30.12,31.3,phases.HYJAL_CHAPTER_2},
                {28.22,29.75,phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE},
            }},
        },
        [39434] = { -- Rio Duran
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={
                {30.25,31.54,phases.HYJAL_CHAPTER_2},
                {28.17,29.88,phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE},
            }},
        },
        [39435] = { -- Royce Duskwhisper
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={
                {30.29,31.6,phases.HYJAL_CHAPTER_2},
                {28.3,29.98,phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE},
            }},
        },
        [39640] = { -- Kristoff Manheim
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{27.2,40.8}}},
        },
        [39858] = { -- Arch Druid Hamuul Runetotem
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={
                {27.12,62.64,phases.HYJAL_HAMUUL_RUNETOTEM_AT_SANCTUARY},
                {19.53,37.81,phases.HYJAL_HAMUUL_RUNETOTEM_AT_GROVE},
            }},
        },
        [39877] = { -- Toshe Chaosrender
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{55.5,12.5},{53.3,33.1}}},
        },
        [39881] = { -- Wavespeaker Valoren
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {64.38,62.56,phases.VASHJIR_LEGIONS_REST},
                {39.2,78.6,phases.VASHJIR_NAR_SHOLA_TERRACE},
                {29.6,78.9,phases.VASHJIR_NAR_SHOLA_TERRACE_WEST},
            }},
        },
        [39926] = { -- Twilight Inciter
            [npcKeys.spawns] = {},
        },
        [39996] = { -- Abyssal Seahorse
            [npcKeys.spawns] = {[zoneIDs.KELP_THAR_FOREST]={{45.06,47}}},
        },
        [40065] = { -- Unbound Flame Spirit
            [npcKeys.spawns] = {},
        },
        [40178] = { -- Alysra
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{52.12,17.42}}},
        },
        [40461] = { -- Flameward Activated
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{33.1,64.5},{41.6,56.2},{40.5,53.2},{38.4,63.9}}},
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [40462] = { -- Flameward Defended
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{33.1,64.5},{41.6,56.2},{40.5,53.2},{38.4,63.9}}},
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [40544] = { -- Rod of Subjugation 01
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{23.9,55.9}}},
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [40545] = { -- Rod of Subjugation 02
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{25.2,54.8}}},
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [40639] = { -- Engineer Hexascrub
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {48.99,49.2,phases.VASHJIR_LEGIONS_REST},
                {32.8,69.2,phases.VASHJIR_NORTHERN_GARDEN},
            }},
        },
        [40642] = { -- Captain Taylor
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {49.16,56.98,phases.VASHJIR_LEGIONS_REST},
                {33.2,68.2,phases.VASHJIR_NORTHERN_GARDEN},
                {39.1,78.5,phases.VASHJIR_NAR_SHOLA_TERRACE},
            }},
        },
        [40643] = { -- Admiral Dvorek
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {49.17,56.95,phases.VASHJIR_LEGIONS_REST},
                {33.0,67.8,phases.VASHJIR_NORTHERN_GARDEN},
                {39.1,78.7,phases.VASHJIR_NAR_SHOLA_TERRACE},
            }},
        },
        [40644] = { -- Levia Dreamwaker
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {49.69,57.15,phases.VASHJIR_LEGIONS_REST},
                {33.0,67.2,phases.VASHJIR_NORTHERN_GARDEN},
            }},
        },
        [40690] = { -- Captain Taylor
            [npcKeys.spawns] = {[zoneIDs.KELP_THAR_FOREST]={{45.05,23.58}}},
        },
        [40916] = { -- Captain Vilethorn
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {51.19,62.99,phases.VASHJIR_LEGIONS_REST},
                {39.8,54.0,phases.VASHJIR_NORTHERN_GARDEN},
                {39.1,78.7,phases.VASHJIR_NAR_SHOLA_TERRACE},
            }},
        },
        [40917] = { -- Legionnaire Nazgrim
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {51.24,63.02,phases.VASHJIR_LEGIONS_REST},
                {39.5,54.0,phases.VASHJIR_NORTHERN_GARDEN},
                {39.1,78.5,phases.VASHJIR_NAR_SHOLA_TERRACE},
            }},
        },
        [40918] = { -- Fiasco Sizzlegrin
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {51.75,62.5,phases.VASHJIR_LEGIONS_REST},
                {39.4,54.6,phases.VASHJIR_NORTHERN_GARDEN},
            }},
        },
        [40919] = { -- Wavespeaker Tulra
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {51.62,62.75,phases.VASHJIR_LEGIONS_REST},
                {39.2,78.6,phases.VASHJIR_NAR_SHOLA_TERRACE},
                {29.6,78.9,phases.VASHJIR_NAR_SHOLA_TERRACE_WEST},
            }},
        },
        [40920] = { -- Elendri Goldenbrow
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {51.27,62.42,phases.VASHJIR_LEGIONS_REST},
                {39.6,53.7,phases.VASHJIR_NORTHERN_GARDEN},
            }},
        },
        [40921] = { -- Bloodguard Toldrek
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{50.4,79.0}}},
        },
        [40963] = { -- Vashj'ir Gardens Credit
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{39.1,57.5}}},
            [npcKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
        },
        [40964] = { -- Vashj'ir Underpass Credit
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{36.2,63}}},
            [npcKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
        },
        [40965] = { -- Vashj'ir Southern Structures Credit
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{40.5,74.4}}},
            [npcKeys.zoneID] = zoneIDs.SHIMMERING_EXPANSE,
        },
        [41003] = { -- Morthis Whisperwing
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={{44.1,45.9}}},
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [41006] = { -- Thisalee Crow
            [npcKeys.spawns] = {[zoneIDs.MOUNT_HYJAL]={
                {42.18,45.46,phases.HYJAL_THISALEE_AT_SHRINE},
                {32.79,70.75,phases.HYJAL_THISALEE_AT_SETHRIAS_ROOST},
            }},
        },
        [41084] = { -- Blaithe
            [npcKeys.spawns] = {[616]={{36.72,33.68},{39.22,37.15},{35.67,42.33},{40.24,37.24},{44.54,38.16},{47.13,40.08},{49.55,41.54}}},
        },
        [41098] = { -- Gnaws
            [npcKeys.spawns] = {},
        },
        [41112] = { -- Marion Wormwing
            [npcKeys.spawns] = {},
        },
        [41281] = { -- Injured Assault Volunteer
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{29,79.8},{29.4,77.2},{29.6,77.2},{30,80.6},{30,83},{31.4,79.4},{31.6,79.4},{32.2,84},{32.6,78},{32.8,79.4},{33.6,83.6},{34.4,78.4},{34.4,83.2},{35,79.4},{35.2,83},{35.6,81},{35.8,75.2},{35.8,76},{36.2,77.8},{36.2,79.4},{36.2,79.6},{36.4,83.8},{36.6,77},{36.6,84},{36.8,82.2},{37.2,74.8},{37.4,80},{37.6,82},{37.8,75.2}}},
        },
        [41294] = { -- Undersea Sanctuary
            [npcKeys.spawns] = {[zoneIDs.KELP_THAR_FOREST]={{46.14,46.64}}},
        },
        [41455] = { -- Overseer Idra'kess
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{36.84,79.75}}},
        },
        [41476] = { -- Naz'jar Honor Guard
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{46.33,78.57}}},
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
        [41770] = { -- Fiasco Sizzlegrin
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{50.35,78.99}}},
        },
        [42074] = { -- Fathom-Stalker Azjentus
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={{46.2,79.55}}},
        },
        [42077] = { -- Lady Naz'jar
            [npcKeys.spawns] = {[zoneIDs.SHIMMERING_EXPANSE]={
                {33.13,75.88,phases.VASHJIR_LADY_NAZ_JAR_AT_TEMPLE},
                {42.51,78.62,phases.VASHJIR_LADY_NAZ_JAR_AT_BRIDGE},
            }},
        },
        [42288] = { -- Robby Flay
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{50.56,71.89}},
            },
        },
        [42463] = { -- Operation: Gnomeregan Recap Credit
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH] = {{33.54,36.52}}},
        },
        [42465] = { -- Therazane
            [npcKeys.questEnds] = {26709,26750,28824,29337},
        },
        [42644] = { -- Smoot
            [npcKeys.waypoints] = {[zoneIDs.AZSHARA]={{{56.89,49.26},{56.84,49.43},{56.73,49.64},{56.65,49.86},{56.60,50.03},{56.58,50.19},{56.65,49.94},{56.72,49.70},{56.80,49.46},{56.89,49.26},{56.98,49.33},{57.12,49.49},{57.28,49.60},{57.45,49.67},{57.50,49.69},{57.58,49.85},{57.71,49.96},{57.85,49.79},{58.00,49.65},{58.13,49.77},{58.13,49.89},{58.17,49.70},{58.21,49.45},{58.06,49.42},{57.89,49.49},{57.73,49.60},{57.56,49.61},{57.51,49.57},{57.36,49.53},{57.19,49.47},{57.02,49.38},{56.90,49.20},{56.81,48.97},{56.70,48.75},{56.58,48.56},{56.45,48.37},{56.31,48.22},{56.27,48.18},{56.26,48.20},{56.13,48.38},{56.00,48.57},{55.87,48.75},{55.75,48.94},{55.63,49.14},{55.56,49.25},{55.51,49.32},{55.39,49.51},{55.27,49.71},{55.23,49.78},{55.22,49.92},{55.24,50.18},{55.36,50.32},{55.46,50.12},{55.37,49.90},{55.29,49.89},{55.22,50.09},{55.26,50.35},{55.33,50.60},{55.40,50.84},{55.50,51.06},{55.62,51.24},{55.76,51.41},{55.90,51.58},{56.07,51.64},{56.24,51.74},{56.33,51.86},{56.35,51.71},{56.40,51.45},{56.46,51.20},{56.54,50.96},{56.60,50.71},{56.61,50.45},{56.61,50.18},{56.47,50.20},{56.43,50.24},{56.51,50.46},{56.58,50.69},{56.53,50.95},{56.45,51.19},{56.35,51.41},{56.27,51.64},{56.25,51.72},{56.36,51.93},{56.38,52.02},{56.30,51.87},{56.17,51.70},{56.01,51.58},{55.95,51.54},{55.80,51.40},{55.66,51.24},{55.53,51.07},{55.41,50.87},{55.37,50.70},{55.36,50.67},{55.32,50.41},{55.22,50.20},{55.17,49.94},{55.29,49.81},{55.30,49.81},{55.35,49.89},{55.48,50.06},{55.62,50.22},{55.79,50.31},{55.94,50.19},{55.94,50.18},{55.95,50.15},{56.00,49.94},{56.15,50.09},{56.31,50.21},{56.47,50.23},{56.58,50.42},{56.60,50.68},{56.54,50.93},{56.52,51.04},{56.46,51.29},{56.47,51.30},{56.64,51.34},{56.82,51.36},{57.00,51.39},{57.17,51.41},{57.35,51.39},{57.48,51.23},{57.53,51.07},{57.61,50.88},{57.69,50.80},{57.83,50.93},{57.84,51.18},{57.72,51.36},{57.64,51.37},{57.46,51.38},{57.28,51.36},{57.22,51.36},{57.09,51.39},{56.91,51.38},{56.74,51.39},{56.56,51.36},{56.46,51.27},{56.50,51.15},{56.56,50.90},{56.63,50.65},{56.64,50.52},{56.60,50.36},{56.56,50.21},{56.56,50.20},{56.63,49.95},{56.72,49.73},{56.81,49.49},{56.89,49.36},{57.01,49.42},{57.17,49.54},{57.35,49.58},{57.42,49.60},{57.55,49.79},{57.66,49.99},{57.69,50.03},{57.69,50.05},{57.71,50.31},{57.67,50.56},{57.57,50.78},{57.52,50.94},{57.46,51.03},{57.32,51.19},{57.17,51.31},{56.99,51.36},{56.82,51.34},{56.64,51.30},{56.51,51.27},{56.51,51.16},{56.55,50.90},{56.61,50.65},{56.59,50.38},{56.57,50.19},{56.43,50.18},{56.25,50.18},{56.07,50.17},{55.90,50.22},{55.72,50.26},{55.59,50.21},{55.53,50.12},{55.39,49.95},{55.31,49.88},{55.32,49.89},{55.41,49.98},{55.42,49.99},{55.56,50.15},{55.71,50.29},{55.87,50.23},{56.03,50.16},{56.21,50.17},{56.39,50.20},{56.56,50.21},{56.58,50.21},{56.60,50.05},{56.66,49.80},{56.75,49.57},{56.86,49.36},{56.89,49.29}}}},
        },
        [43006] = { -- Rhyanda
            [npcKeys.spawns] = {[zoneIDs.TELDRASSIL] = {{58.39,35.53}}},
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
        [44148] = { -- Stonescale Matriarch
            [npcKeys.spawns] = {},
        },
        [44806] = { -- Fargo Flintlocke
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY]={{26.2,47.2}}},
        },
        [44968] = { -- Ricket
            [npcKeys.spawns] = {[zoneIDs.DEEPHOLM] = {{61.4,26.2}}}
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
        [48533] = { -- Enormous Gyreworm
            [npcKeys.spawns] = {},
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
        [49893] = { -- Lisa McKeever
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{51.62,72.38}},
            },
        },
        [50482] = { -- Marith Lazuria
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR]={{72.6,34.4}}}
        },
        [51314] = { -- Azshara Event Credit
            [npcKeys.spawns] = {[zoneIDs.DARKSHORE] = {{32.89,84.09}}},
        },
        [51989] = { -- Orphan Matron Battlewail
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{57.96,57.62}},
            },
        },
        [52189] = { -- Rental Chopper
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{57.78,53.06},{57.71,53.28}},
            },
            [npcKeys.zoneID] = zoneIDs.WESTFALL,
        },
        [53540] = { -- Cold Water Crayfish
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{83.97,51.69}},
            },
        },
        -- Fake NPCs for Auto Accept and Auto Turn in
        [100000] = { -- "Burn, Baby, Burn!", "Bombs Away: Windshear Mine!"
            [npcKeys.name] = "!",
            [npcKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS] = {{73.23,46.61}}},
            [npcKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
            [npcKeys.questStarts] = {25622,25640},
        },
        [100001] = { -- Burn, Baby, Burn!
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.STONETALON_MOUNTAINS] = {{73.23,46.61}}},
            [npcKeys.zoneID] = zoneIDs.STONETALON_MOUNTAINS,
            [npcKeys.questEnds] = {25622},
        },
        [100002] = { -- A Personal Summons - Stormwind
            [npcKeys.name] = "!",
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{49.59,86.53}}},
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [npcKeys.questStarts] = {28825},
        },
        [100003] = { -- A Personal Summons - Orgrimmar
            [npcKeys.name] = "!",
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{48.28,64.53}}},
            [npcKeys.zoneID] = zoneIDs.ORGRIMMAR,
            [npcKeys.questStarts] = {28790},
        },
        [100004] = { -- Once More, With Eeling
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.KELP_THAR_FOREST] = {{47.22,21.56}}},
            [npcKeys.zoneID] = zoneIDs.KELP_THAR_FOREST,
            [npcKeys.questEnds] = {27729},
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
        [42790] = { -- Bloodlord Mandokir
            [npcKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE]={{38.4,48.6}}},
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
        [42790] = { -- Bloodlord Mandokir
            [npcKeys.spawns] = {[zoneIDs.STRANGLETHORN_VALE]={{47.2,10.6}}},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return npcFixesHorde
    else
        return npcFixesAlliance
    end
end
