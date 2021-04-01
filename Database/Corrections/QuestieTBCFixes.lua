-- this should be eventually refactored into a proper place
---@class QuestieTBCFixes
local QuestieTBCFixes = QuestieLoader:CreateModule("QuestieTBCFixes")
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieTBCFixes:Load()
    local questKeys = QuestieDB.questKeys
    return {
        [11058]={
            [questKeys.triggerEnd] = {"Apexis Vibrations attained", {
                [3522]={
                    {33.46,51.84},
                    {28.79,46.68},
                    {31.82,64.05},
                    {27.39,68.4},
                },
            }},
        },
        [10044]={
            [questKeys.triggerEnd] = {"Listen to Greatmother Geyah", {
                [3518]={
                    {56.66,34.31},
                },
            }},
        },
        [11082]={
            [questKeys.triggerEnd] = {"Murkblood Information Gathered", {
                [3520]={
                    {73.06,82.26},
                    {68.63,79.81},
                },
            }},
        },
        [11142]={
            [questKeys.triggerEnd] = {"Survey Alcaz Island", {
                [15]={
                    {69.96,19.55},
                    {67.36,50.87},
                },
            }},
        },
        [11657]={
            [questKeys.triggerEnd] = {"Catch 4 torches in a row.", {
                [1637]={
                    {47.02,36.83},
                },
                [1638]={
                    {21.95,26.74},
                },
                [1519]={
                    {37.65,59.98},
                },
                [1537]={
                    {62.15,27.58},
                },
                [1497]={
                    {64.58,8.08},
                },
            }},
        },
        [9645]={
            [questKeys.triggerEnd] = {"Journal Entry Read", {
                [41]={
                    {46.57,70.49},
                    {46.77,74.5},
                },
            }},
        },
        [10204]={
            [questKeys.triggerEnd] = {"Siphon Bloodgem Crystal", {
                [3523]={
                    {25.42,66.51},
                    {22.37,65.73},
                },
            }},
        },
        [9729]={
            [questKeys.triggerEnd] = {"Ark of Ssslith safely returned to Sporeggar", {
                [3521]={
                    {19.71,50.72},
                },
            }},
        },
        [11338]={
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [3703]={
                    {67.4,34.64},
                    {66.62,57.45},
                },
                [1519]={
                    {82.5,13.26},
                },
                [1637]={
                    {79.03,30.65},
                },
                [1537]={
                    {70.5,89.56},
                },
            }},
        },
        [11342]={
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [3703]={
                    {67.4,34.64},
                    {66.62,57.45},
                },
                [1519]={
                    {82.5,13.26},
                },
                [1637]={
                    {79.03,30.65},
                },
                [1537]={
                    {70.5,89.56},
                },
            }},
        },
        [10839]={
            [questKeys.triggerEnd] = {"Attempt to purify the Darkstone of Terrok", {
                [3519]={
                    {30.84,42.03},
                },
            }},
        },
        [10879]={
            [questKeys.triggerEnd] = {"Attack thwarted", {
                [3703]={
                    {51.62,20.69},
                },
            }},
        },
        [455]={
            [questKeys.triggerEnd] = {"Traverse Dun Algaz", {
                [11]={
                    {53.49,70.36},
                },
            }},
        },
        [10951]={
            [questKeys.triggerEnd] = {"Salandria taken to the Dark Portal", {
                [3483]={
                    {88.33,50.19},
                },
            }},
        },
        [10963]={
            [questKeys.triggerEnd] = {"Salandria taken to the Caverns of Time", {
                [440]={
                    {60.53,57.72},
                },
            }},
        },
        [9446]={
            [questKeys.triggerEnd] = {"Escort Anchorite Truuen to Uther's Tomb", {
                [28]={
                    {52.06,83.26},
                },
            }},
        },
        [9973]={
            [questKeys.triggerEnd] = {"The Warmaul Champion Defeated", {
                [3518]={
                    {43.37,20.69},
                },
            }},
        },
        [9486]={
            [questKeys.triggerEnd] = {"Tame an Elder Springpaw", {
                [3430]={
                    {61.95,64.61},
                    {64.77,59.93},
                },
            }},
        },
        [8488]={
            [questKeys.triggerEnd] = {"Protect Apprentice Mirveda", {
                [3430]={
                    {54.3,71.02},
                },
            }},
        },
        [11067]={
            [questKeys.triggerEnd] = {"Trope the Filth-Belcher Defeated", {
                [3520]={
                    {64.75,85},
                },
            }},
        },
        [9686]={
            [questKeys.triggerEnd] = {"Complete the Second Trial", {
                [3430]={
                    {43.34,28.7},
                },
            }},
        },
        [201]={
            [questKeys.triggerEnd] = {"Locate the hunters' camp", {
                [33]={
                    {35.73,10.82},
                },
            }},
        },
        [9718]={
            [questKeys.triggerEnd] = {"Lakes of Zangarmarsh Explored", {
                [3521]={
                    {77.26,45.12},
                },
            }},
        },
        [10772]={
            [questKeys.triggerEnd] = {"The Path of Conquest Discovered", {
                [3520]={
                    {51.23,62.75},
                    {52.45,59.19},
                },
            }},
        },
        [10277]={
            [questKeys.triggerEnd] = {"Caverns of Time Explained", {
                [440]={
                    {58.87,54.3},
                },
            }},
        },
        [11335]={
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [3703]={
                    {67.38,33.8},
                    {66.58,56.23},
                },
                [1519]={
                    {82.45,12.92},
                },
                [1637]={
                    {79.39,30.08},
                },
                [1537]={
                    {70.12,89.41},
                },
            }},
        },
        [11339]={
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [3703]={
                    {67.38,33.8},
                    {66.58,56.23},
                },
                [1519]={
                    {82.45,12.92},
                },
                [1637]={
                    {79.39,30.08},
                },
                [1537]={
                    {70.12,89.41},
                },
            }},
        },
        [11922]={
            [questKeys.triggerEnd] = {"Hit 8 braziers.", {
                [141]={
                    {56.59,92.06},
                },
                [1637]={
                    {46.65,38.17},
                },
                [1519]={
                    {39.21,61.71},
                },
                [1537]={
                    {65,23.73},
                },
                [1497]={
                    {68.58,7.88},
                },
            }},
        },
        [2240]={
            [questKeys.triggerEnd] = {"Explore the Hidden Chamber", {
                [3]={
                    {35.22,10.32},
                },
            }},
        },
        [9962]={
            [questKeys.triggerEnd] = {"Brokentoe Defeated", {
                [3518]={
                    {43.32,20.72},
                },
            }},
        },
        [9970]={
            [questKeys.triggerEnd] = {"Rokdar the Sundered Lord Defeated", {
                [3518]={
                    {43.34,20.71},
                },
            }},
        },
        [6025]={
            [questKeys.triggerEnd] = {"Overlook Hearthglen from a high vantage point", {
                [28]={
                    {45.7,18.5},
                },
            }},
        },
        [11064]={
            [questKeys.triggerEnd] = {"Murg \"Oldie\" Muckjaw Defeated", {
                [3520]={
                    {64.76,85.05},
                },
            }},
        },
        [10557]={
            [questKeys.triggerEnd] = {"Test Tally's Experiment", {
                [3522]={
                    {60.1,68.84},
                },
            }},
        },
        [11080]={
            [questKeys.triggerEnd] = {"Apexis Emanations attained", {
                [3522]={
                    {28.7,46.64},
                    {27.3,68.39},
                    {31.82,63.62},
                    {33.42,51.9},
                },
            }},
        },
        [11108]={
            [questKeys.triggerEnd] = {"Meeting with Illidan Stormrage", {
                [3520]={
                    {65.93,86.15},
                },
            }},
        },
        [287]={
            [questKeys.triggerEnd] = {"Fully explore Frostmane Hold", {
                [1]={
                    {21.47,52.2},
                },
            }},
        },
        [11926]={
            [questKeys.triggerEnd] = {"Hit 20 braziers.", {
                [1637]={
                    {46.67,38.13},
                },
                [1638]={
                    {20.99,26.46},
                },
                [1519]={
                    {39.2,61.72},
                },
                [1537]={
                    {65,23.68},
                },
                [1497]={
                    {68.62,8.01},
                },
            }},
        },
        [11925]={
            [questKeys.triggerEnd] = {"Catch 10 torches in a row.", {
                [1637]={
                    {47.11,36.69},
                },
                [3557]={
                    {41.63,22.55},
                },
                [1519]={
                    {37.5,59.8},
                },
                [1537]={
                    {62.04,27.83},
                },
                [1638]={
                    {22.17,26.94},
                },
            }},
        },
        [11924]={
            [questKeys.triggerEnd] = {"Catch 10 torches in a row.", {
                [1637]={
                    {47.11,36.69},
                },
                [3557]={
                    {41.63,22.55},
                },
                [1519]={
                    {37.5,59.8},
                },
                [1537]={
                    {62.04,27.83},
                },
                [1638]={
                    {22.17,26.94},
                },
            }},
        },
        [9160]={
            [questKeys.triggerEnd] = {"Investigate An'daroth", {
                [3433]={
                    {37.13,16.15},
                },
            }},
        },
        [11923]={
            [questKeys.triggerEnd] = {"Catch 4 torches in a row.", {
                [1637]={
                    {47.02,36.83},
                },
                [1638]={
                    {21.95,26.74},
                },
                [1519]={
                    {37.65,59.98},
                },
                [1537]={
                    {62.15,27.58},
                },
                [1497]={
                    {64.58,8.08},
                },
            }},
        },
        [11921]={
            [questKeys.triggerEnd] = {"Hit 20 braziers.", {
                [1637]={
                    {46.67,38.13},
                },
                [1638]={
                    {20.99,26.46},
                },
                [1519]={
                    {39.2,61.72},
                },
                [1537]={
                    {65,23.68},
                },
                [1497]={
                    {68.62,8.01},
                },
            }},
        },
        [10198]={
            [questKeys.triggerEnd] = {"Information Gathering", {
                [3523]={
                    {48.18,84.08},
                },
            }},
        },
        [11891]={
            [questKeys.triggerEnd] = {"Listen to the plan of the Twilight Cultists", {
                [331]={
                    {9.15,12.41},
                },
            }},
        },
        [578]={
            [questKeys.triggerEnd] = {"Locate the haunted island", {
                [33]={
                    {21.56,21.98},
                },
            }},
        },
        [11731]={
            [questKeys.triggerEnd] = {"Hit 8 braziers.", {
                [141]={
                    {56.59,92.06},
                },
                [1637]={
                    {46.65,38.17},
                },
                [1519]={
                    {39.21,61.71},
                },
                [1537]={
                    {65,23.73},
                },
                [1497]={
                    {68.58,7.88},
                },
            }},
        },
        [11523]={
            [questKeys.triggerEnd] = {"Energize a Crystal Ward", {
                [4075]={
                    {47.7,34.52},
                    {48.43,31.21},
                },
            }},
        },
        [10218]={
            [questKeys.triggerEnd] = {"Escort Cryo-Engineer Sha'heen", {
                [3519]={
                    {39.62,57.57},
                },
            }},
        },
        [9711]={
            [questKeys.triggerEnd] = {"Matis the Cruel Captured", {
                [3525]={
                    {32.74,48.02},
                    {29.51,51.36},
                    {25.63,53.52},
                    {37.81,46.44},
                    {40.88,45.13},
                },
            }},
        },
        [10712]={
            [questKeys.triggerEnd] = {"Launch to Ruuan Weald.", {
                [3522]={
                    {60.18,68.62},
                },
            }},
        },
        [11506]={
            [questKeys.triggerEnd] = {"Secure a Spirit Tower", {
                [3519]={
                    {42.49,54},
                    {32.47,57.86},
                    {48.98,60.29},
                    {47.2,72.29},
                    {40.48,77.99},
                },
            }},
        },
        [9212]={
            [questKeys.triggerEnd] = {"Escort Ranger Lilatha back to the Farstrider Enclave", {
                [3433]={
                    {72.24,30.21},
                },
            }},
        },
        [11505]={
            [questKeys.triggerEnd] = {"Secure a Spirit Tower", {
                [3519]={
                    {42.49,54},
                    {32.47,57.86},
                    {48.98,60.29},
                    {47.2,72.29},
                    {40.48,77.99},
                },
            }},
        },
        [9731]={
            [questKeys.triggerEnd] = {"Drain Located", {
                [3521]={
                    {50.44,40.91},
                },
            }},
        },
        [11496]={
            [questKeys.triggerEnd] = {"Energize a Crystal Ward", {
                [4075]={
                    {47.7,34.52},
                    {48.43,31.21},
                },
            }},
        },
        [10297]={
            [questKeys.triggerEnd] = {"The Dark Portal Opened", {
                [440]={
                    {57.21,62.92},
                },
            }},
        },
        [10310]={
            [questKeys.triggerEnd] = {"Burning Legion warp-gate sabotaged", {
                [3523]={
                    {48.14,63.38},
                },
            }},
        },
        [11090]={
            [questKeys.triggerEnd] = {"Subdue Reth'hedron the Subduer", {
                [3518]={
                    {8.7,42.79},
                },
            }},
        },
        [10409]={
            [questKeys.triggerEnd] = {"Deathblow to the Legion", {
                [3523]={
                    {29.56,14.29},
                },
            }},
        },
        [11071]={
            [questKeys.triggerEnd] = {"Captain Skyshatter Defeated", {
                [3520]={
                    {64.71,85.05},
                },
            }},
        },
        [11070]={
            [questKeys.triggerEnd] = {"Wing Commander Mulverick Defeated", {
                [3520]={
                    {64.77,84.36},
                },
            }},
        },
        [11069]={
            [questKeys.triggerEnd] = {"Wing Commander Ichman Defeated", {
                [3520]={
                    {64.77,85.09},
                },
            }},
        },
        [6185]={
            [questKeys.triggerEnd] = {"The Blightcaller Uncovered", {
                [139]={
                    {27.4,75.14},
                },
            }},
        },
        [11336]={
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [3703]={
                    {66.85,57.04},
                    {67.49,34.31},
                },
                [1519]={
                    {82.12,12.83},
                },
                [1637]={
                    {79.09,31.1},
                },
                [1537]={
                    {70.09,90.26},
                },
            }},
        },
        [11068]={
            [questKeys.triggerEnd] = {"Corlok the Vet Defeated", {
                [3520]={
                    {64.72,84.75},
                },
            }},
        },
        [10814]={
            [questKeys.triggerEnd] = {"The Tale of Neltharaku", {
                [3520]={
                    {63.48,60.71},
                    {59.4,58.67},
                    {66.89,59.79},
                    {63.21,55.88},
                    {59.88,54.21},
                },
            }},
        },
        [10968]={
            [questKeys.triggerEnd] = {"Dornaa taken to Farseer Nobundo", {
                [3557]={
                    {30.8,29.88},
                },
            }},
        },
        [10962]={
            [questKeys.triggerEnd] = {"Dornaa taken to the Caverns of Time", {
                [440]={
                    {60.52,57.74},
                },
            }},
        },
        [10956]={
            [questKeys.triggerEnd] = {"Dornaa taken to the Seat of the Naaru", {
                [3557]={
                    {56.65,40.73},
                },
            }},
        },
        [10953]={
            [questKeys.triggerEnd] = {"Salandria taken to the Throne of the Elements", {
                [3518]={
                    {60.5,22.7},
                },
            }},
        },
        [10952]={
            [questKeys.triggerEnd] = {"Dornaa taken to the Dark Portal", {
                [3483]={
                    {88.26,50.32},
                },
            }},
        },
        [10985]={
            [questKeys.triggerEnd] = {"Help Akama and Maiev enter the Black Temple.", {
                [3520]={
                    {71.05,46.11},
                    {66.29,44.06},
                },
            }},
        },
        [11341]={
            [questKeys.triggerEnd] = {"Victory in Eye of the Storm", {
                [3703]={
                    {67.02,56.14},
                    {63.9,58.34},
                },
                [1637]={
                    {79.21,30.08},
                },
            }},
        },
        [11340]={
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [3703]={
                    {66.85,57.04},
                    {67.49,34.31},
                },
                [1519]={
                    {82.12,12.83},
                },
                [1637]={
                    {79.09,31.1},
                },
                [1537]={
                    {70.09,90.26},
                },
            }},
        },
        [10406]={
            [questKeys.triggerEnd] = {"Ethereum Conduit Sabotaged", {
                [3523]={
                    {56.42,42.66},
                },
            }},
        },
        [9528]={
            [questKeys.triggerEnd] = {"Magwin Escorted to Safety", {
                [3524]={
                    {16.38,94.14},
                },
            }},
        },
        [11198]={
            [questKeys.triggerEnd] = {"Defend Theramore Docks from Tethyr", {
                [15]={
                    {70.01,51.88},
                },
            }},
        },
        [9400]={
            [questKeys.triggerEnd] = {"Find Krun Spinebreaker", {
                [3483]={
                    {33.59,43.62},
                },
            }},
        },
        [10945]={
            [questKeys.triggerEnd] = {"Salandria taken to Sporeggar", {
                [3521]={
                    {19.22,51.23},
                },
            }},
        },
        [10946]={
            [questKeys.triggerEnd] = {"Ruse of the Ashtongue", {
                [3523]={
                    {73.88,63.76},
                },
            }},
        },
        [10922]={
            [questKeys.triggerEnd] = {"Protect the Explorers", {
                [3519]={
                    {30.12,70.9},
                },
            }},
        },
        [10977]={
            [questKeys.triggerEnd] = {"Mana-Tombs Stasis Chamber Investigated", {
                [3519]={
                    {39.63,57.54},
                },
            }},
        },
        [10781]={
            [questKeys.triggerEnd] = {"Crimson Sigil Forces Annihilated", {
                [3520]={
                    {51.75,72.79},
                },
            }},
        },
        [1699]={
            [questKeys.triggerEnd] = {"Enter the Rethban Caverns", {
                [44]={
                    {19.22,25.25},
                },
            }},
        },
        [10750]={
            [questKeys.triggerEnd] = {"The Path of Conquest Discovered", {
                [3520]={
                    {51.23,62.75},
                    {52.45,59.19},
                },
            }},
        },
        [10722]={
            [questKeys.triggerEnd] = {"Meeting with Kolphis Darkscale attended", {
                [3522]={
                    {32.61,37.45},
                },
            }},
        },
        [11516]={
            [questKeys.triggerEnd] = {"Legion Gateway Destroyed", {
                [3483]={
                    {58.51,18.5},
                },
            }},
        },
        [10711]={
            [questKeys.triggerEnd] = {"Reach the Sky's Limit.", {
                [3522]={
                    {60.25,68.55},
                },
            }},
        },
        [9991]={
            [questKeys.triggerEnd] = {"Forge Camps Surveyed", {
                [3518]={
                    {27.22,43.05},
                },
            }},
        },
        [9836]={
            [questKeys.triggerEnd] = {"Master's Touch", {
                [440]={
                    {57.21,62.95},
                },
            }},
        },
        [1448]={
            [questKeys.triggerEnd] = {"Search for the Temple of Atal'Hakkar", {
                [8]={
                    {64.67,48.82},
                    {64.36,56.12},
                    {64.09,51.95},
                    {69.6,44.18},
                    {73.97,46.36},
                },
            }},
        },
        [9977]={
            [questKeys.triggerEnd] = {"Mogor, Hero of the Warmaul Defeated", {
                [3518]={
                    {43.31,20.72},
                },
            }},
        },
        [9879]={
            [questKeys.triggerEnd] = {"Free the Kurenai Captive", {
                [3518]={
                    {31.59,38.78},
                },
            }},
        },
        [10275]={
            [questKeys.triggerEnd] = {"Second triangulation point discovered", {
                [3523]={
                    {28.92,41.25},
                },
            }},
        },
        [10577]={
            [questKeys.triggerEnd] = {"Illidan's Message Delivered", {
                [3520]={
                    {46.46,71.86},
                },
            }},
        },
        [10525]={
            [questKeys.triggerEnd] = {"Final Thunderlord artifact discovered", {
                [3522]={
                    {52.76,58.89},
                },
            }},
        },
        [1719]={
            [questKeys.triggerEnd] = {"Step on the grate to begin the Affray", {
                [17]={
                    {68.61,48.72},
                },
            }},
        },
        [10425]={
            [questKeys.triggerEnd] = {"Captured Protectorate Vanguard Escorted", {
                [3523]={
                    {58.9,32.43},
                },
            }},
        },
        [11085]={
            [questKeys.triggerEnd] = {"Rescue the Skyguard Prisoner.", {
                [3519]={
                    {69.77,75.98},
                    {62.41,73.85},
                    {73.94,88.3},
                },
            }},
        },
        [10337]={
            [questKeys.triggerEnd] = {"Escort Bessy on her way home.", {
                [3523]={
                    {57.71,84.97},
                },
            }},
        },
        [11097]={
            [questKeys.triggerEnd] = {"Dragonmaw Forces Defeated", {
                [3520]={
                    {56.87,58.18},
                    {64.27,31.01},
                },
            }},
        },
        [11101]={
            [questKeys.triggerEnd] = {"Dragonmaw Forces Defeated", {
                [3520]={
                    {56.87,58.18},
                    {64.27,31.01},
                },
            }},
        },
        [10594]={
            [questKeys.triggerEnd] = {"Singing crystal resonant frequency gauged", {
                [3522]={
                    {59.77,73.83},
                },
            }},
        },
        [10269]={
            [questKeys.triggerEnd] = {"First triangulation point discovered", {
                [3523]={
                    {66.67,33.85},
                },
            }},
        },
        [10107]={
            [questKeys.triggerEnd] = {"Hear the Tale of the Blademaster", {
                [3518]={
                    {73.82,62.59},
                },
            }},
        },
        [10231]={
            [questKeys.triggerEnd] = {"Beat Down \"Dirty\" Larry and Get Information", {
                [3703]={
                    {43.86,27.97},
                },
            }},
        },
        [9608]={
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {
                [3483]={
                    {45.89,51.93},
                },
            }},
        },
        [62]={
            [questKeys.triggerEnd] = {"Scout through the Fargodeep Mine", {
                [12]={
                    {40.01,81.42},
                },
            }},
        },
        [76]={
            [questKeys.triggerEnd] = {"Scout through the Jasperlode Mine", {
                [12]={
                    {60.53,50.18},
                },
            }},
        },
        [10211]={
            [questKeys.triggerEnd] = {"City of Light", {
                [3703]={
                    {50.45,42.93},
                },
            }},
        },
        [10646]={
            [questKeys.triggerEnd] = {"Illidan's Pupil", {
                [3518]={
                    {27.36,43.07},
                },
            }},
        },
        [10172]={
            [questKeys.triggerEnd] = {"Speak to Greatmother Geyah", {
                [3518]={
                    {56.66,34.31},
                },
            }},
        },
        [10108]={
            [questKeys.triggerEnd] = {"Hear the Tale of the Blademaster", {
                [3518]={
                    {73.82,62.59},
                },
            }},
        },
        [10052]={
            [questKeys.triggerEnd] = {"Escort Isla Starmane to safety", {
                [3519]={
                    {67.51,37.28},
                },
            }},
        },
        [10051]={
            [questKeys.triggerEnd] = {"Escort Isla Starmane to safety", {
                [3519]={
                    {67.51,37.28},
                },
            }},
        },
        [10682]={
            [questKeys.triggerEnd] = {"Negotiations with Overseer Nuaar complete", {
                [3522]={
                    {62.22,31.78},
                    {59.86,40.22},
                    {59.46,35.84},
                },
            }},
        },
        [4842]={
            [questKeys.triggerEnd] = {"Discover Darkwhisper Gorge", {
                [618]={
                    {60.1,73.44},
                },
            }},
        },
        [9967]={
            [questKeys.triggerEnd] = {"The Blue Brothers Defeated", {
                [3518]={
                    {43.26,20.76},
                },
            }},
        },
        [9889]={
            [questKeys.triggerEnd] = {"Unkor Submits", {
                [3519]={
                    {20.02,63.05},
                },
            }},
        },
        [10191]={
            [questKeys.triggerEnd] = {"Escort the Maxx A. Million Mk. V safely through the Ruins of Enkaat", {
                [3523]={
                    {31.54,56.47},
                },
            }},
        },
        [10710]={
            [questKeys.triggerEnd] = {"Throw caution to the wind.", {
                [3522]={
                    {60.33,68.89},
                },
            }},
        },
        [9786]={
            [questKeys.triggerEnd] = {"Explore the Boha'mu Ruins", {
                [3521]={
                    {44.13,68.97},
                },
            }},
        },
        [9700]={
            [questKeys.triggerEnd] = {"Sun Portal Site Confirmed", {
                [3525]={
                    {52.92,22.32},
                },
            }},
        },
        [9193]={
            [questKeys.triggerEnd] = {"Investigate the Amani Catacombs", {
                [3433]={
                    {62.91,30.98},
                },
            }},
        },
        [9759]={
            [questKeys.triggerEnd] = {"Vector Coil Destroyed and Sironas Slain", {
                [3525]={
                    {14.86,54.84},
                },
            }},
        },
        [9752]={
            [questKeys.triggerEnd] = {"Escort Kayra Longmane to safety", {
                [3521]={
                    {79.76,71.09},
                },
            }},
        },
        [9716]={
            [questKeys.triggerEnd] = {"Umbrafen Lake Investigated", {
                [3521]={
                    {70.89,80.51},
                },
            }},
        },
        [9701]={
            [questKeys.triggerEnd] = {"Investigate the Spawning Glen", {
                [3521]={
                    {15.1,61.21},
                },
            }},
        },
        [9666]={
            [questKeys.triggerEnd] = {"Declaration of Power", {
                [3525]={
                    {68.52,67.88},
                },
            }},
        },
        [9607]={
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {
                [3483]={
                    {45.89,51.93},
                },
            }},
        },
        [6421]={
            [questKeys.triggerEnd] = {"Investigate Cave in Boulderslide Ravine", {
                [406]={
                    {58.96,90.16},
                },
            }},
        },
        [870]={
            [questKeys.triggerEnd] = {"Explore the waters of the Forgotten Pools", {
                [17]={
                    {45.06,22.56},
                },
            }},
        },
        [9593]={
            [questKeys.triggerEnd] = {"Tame a Nightstalker", {
                [3524]={
                    {36.41,40.24},
                    {35.82,37.14},
                },
            }},
        },
        [9592]={
            [questKeys.triggerEnd] = {"Tame a Greater Timberstrider", {
                [3524]={
                    {36.46,35.49},
                    {35.16,30.99},
                    {40.27,37.65},
                    {40.25,32.31},
                },
            }},
        },
        [9591]={
            [questKeys.triggerEnd] = {"Tame a Barbed Crawler", {
                [3524]={
                    {20.29,64.87},
                    {22.04,72.29},
                    {20.57,68.9},
                },
            }},
        },
        [9538]={
            [questKeys.triggerEnd] = {"Stillpine Furbolg Language Primer Read", {
                [3524]={
                    {49.29,51.07},
                },
            }},
        },
        [11337]={
            [questKeys.triggerEnd] = {"Victory in the Eye of the Storm", {
                [3703]={
                    {67.4,34.08},
                },
                [1519]={
                    {82.51,13.69},
                },
                [1537]={
                    {70.04,89.98},
                },
            }},
        },
        [9484]={
            [questKeys.triggerEnd] = {"Tame a Crazed Dragonhawk", {
                [3430]={
                    {60.39,59.09},
                    {61.23,65.08},
                },
            }},
        },
        [155]={
            [questKeys.triggerEnd] = {"Escort The Defias Traitor to discover where VanCleef is hiding", {
                [40]={
                    {42.55,71.53},
                },
            }},
        },
        [9375]={
            [questKeys.triggerEnd] = {"Escort Wounded Blood Elf Pilgrim to Falcon Watch", {
                [3483]={
                    {27.09,61.92},
                },
            }},
        },
        [10886]={
            [questKeys.triggerEnd] = {"Millhouse Manastorm Rescued", {
                [3523]={
                    {74.5,57.67},
                },
            }},
        },
        [9868]={
            [questKeys.triggerEnd] = {"Free the Mag'har Captive", {
                [3518]={
                    {31.77,38.78},
                },
            }},
        },
        [10898]={
            [questKeys.triggerEnd] = {"Escort Skywing", {
                [3519]={
                    {55.71,69.68},
                },
            }},
        },
        [2989]={
            [questKeys.triggerEnd] = {"Search the Altar of Zul", {
                [47]={
                    {48.86,68.42},
                },
            }},
        },
        [503]={
            [questKeys.triggerEnd] = {"Find where Gol'dir is being held", {
                [2597]={
                    {60.58,43.86},
                },
            }},
        },
        [3505]={
            [questKeys.triggerEnd] = {"Find Magus Rimtori's camp", {
                [16]={
                    {59.29,31.21},
                },
            }},
        },
        [10950]={
            [questKeys.triggerEnd] = {"Dornaa taken to the Ring of Observance", {
                [3519]={
                    {39.71,64.6},
                },
            }},
        },
        [10954]={
            [questKeys.triggerEnd] = {"Dornaa taken to Aeris Landing", {
                [3518]={
                    {31.47,57.45},
                },
            }},
        },
        [10451]={
            [questKeys.triggerEnd] = {"Earthmender Wilda Escorted to Safety", {
                [3520]={
                    {53.14,25.18},
                },
            }},
        },
        [9972]={
            [questKeys.triggerEnd] = {"Skra'gath Defeated", {
                [3518]={
                    {43.26,20.77},
                },
            }},
        },
        [9485]={
            [questKeys.triggerEnd] = {"Tame a Mistbat", {
                [3433]={
                    {48.29,13.42},
                    {55.22,11.22},
                    {50.59,15.86},
                },
            }},
        },
        [10004]={
            [questKeys.triggerEnd] = {"Sal'salabim Persuaded", {
                [3703]={
                    {76.68,33.96},
                },
            }},
        },
        [10519]={
            [questKeys.triggerEnd] = {"The Cipher of Damnation - History and Truth", {
                [3520]={
                    {53.9,23.48},
                },
            }},
        },
    }
end
