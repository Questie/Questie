---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")

---@alias HubId string

---@class Hub
---@field quests QuestId[]
---@field limit number
---@field exclusiveHubs table<HubId, boolean> A list of other hubs that are exclusive to this hub. If the player has quests from any of these hubs, they cannot have quests from this hub.
---@field preQuestHubsSingle table<HubId, boolean> A list of other hubs that must be completed before this hub can be accessed. Only a single hub needs to be complete to unlock this hub.
---@field preQuestHubsGroup table<HubId, boolean> A list of other hubs that must be completed before this hub can be accessed. All these hubs need to be complete to unlock this hub.
---@field IsActive? function(completedQuests: table<QuestId, boolean>, questLog: table<QuestId, Quest>): boolean A function that returns true if the hub is active, false otherwise.

---@format disable
---@type table<HubId, Hub>
DailyQuests.hubs = {
    TOL_BARAD_ALLIANCE = {
        quests = {27944,27948,27949,27966,27967,27970,27971,27972,27973,27975,27978,27987,27991,27992,28046,28050,28059,28063,28130,28137,28275},
        limit = 6,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    TOL_BARAD_HORDE = {
        quests = {28678,28679,28680,28681,28682,28683,28684,28685,28686,28687,28689,28690,28691,28692,28693,28694,28695,28696,28697,28698,28700},
        limit = 6,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    THE_ANGLERS = {
        quests = {30584,30585,30586,30588,30598,30613,30658,30678,30698,30700,30701,30753,30754,30763},
        limit = 3,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    AUGUST_CELESTIALS_RED_CRANE = {
        quests = {30716,30717,30718,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        limit = 4, -- 3(TO DO - progressive daily chain)
        exclusiveHubs = {
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    AUGUST_CELESTIALS_JADE_SERPENT = {
        quests = {30006,30063,30064,30065,30066},
        limit = 3, -- 3 (random of 5)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    AUGUST_CELESTIALS_JADE_SERPENT_ELITES = {
        quests = {30067,30068},
        limit = 1, -- 1 (random of 2)
        exclusiveHubs = {},
        preQuestHubsSingle = {AUGUST_CELESTIALS_JADE_SERPENT = true},
        preQuestHubsGroup = {},
    },
    AUGUST_CELESTIALS_WHITE_TIGER = {
        quests = {31492,31517,30879,30880},
        limit = 2, -- 1 (random of 2) + 1 (2 random chains of 4 each, showing only first one)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    AUGUST_CELESTIALS_NIUZAO_TEMPLE = {
        quests = {30952,30953,30954,30955,30956,30957,30958,30959},
        limit = 4, -- 1 (random of 2) + 3 (random of 6)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = {
        quests = {30150,30151,31704},
        limit = 2, -- 2 (random of 3)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM_FINAL = {
        quests = {31705},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = { -- not good
        quests = {30155,30156,30157,30158,31194},
        limit = 3, -- 2 (random of 3) + 1 (Slitherscale Suppression)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_TIGERS = {
        quests = {30154,31698,31699,31700,31701,31702,31703},
        limit = 3, -- 2 (random of 4) + 1 (random of 2)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = {
        quests = {30152,31716,31717,31718,31719,31720,31721}, -- 31716 uncertain
        limit = 3, -- 1 (The Sky Race) + 2 (random of 5)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = {
        quests = {31706,31707,31708,31709,31710,31711},
        limit = 3, -- 2 (random of 5) + 1 (The Seed of Doubt)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = { -- good
        quests = {30159,31712,31713,31714,31715},
        limit = 3, -- 2 (random of 4) + 1 (The Big Kah-Oona)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    THE_KLAXXI_LAKE = {
        quests = {31024,31267,31268,31269,31270,31271,31272},
        limit = 7, -- 6 honored + 1 revered
        exclusiveHubs = {
            THE_KLAXXI_TERRACE = true,
            THE_KLAXXI_CLUTCHES = true,
            THE_KLAXXI_ZANVESS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    THE_KLAXXI_TERRACE = {
        quests = {31231,31232,31233,31234,31235,31237,31238,31677},
        limit = 8, -- 6 honored + 1 revered + 1 hidden
        exclusiveHubs = {
            THE_KLAXXI_LAKE = true,
            THE_KLAXXI_CLUTCHES = true,
            THE_KLAXXI_ZANVESS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    THE_KLAXXI_CLUTCHES = {
        quests = {31109,31487,31494,31496,31502,31503,31504,31599},
        limit = 8, -- 6 honored + 1 revered + 1 hidden
        exclusiveHubs = {
            THE_KLAXXI_LAKE = true,
            THE_KLAXXI_TERRACE = true,
            THE_KLAXXI_ZANVESS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    THE_KLAXXI_ZANVESS = {
        quests = {31111,31505,31506,31507,31508,31509,31510,31598},
        limit = 8, -- 6 honored + 1 revered + 1 hidden
        exclusiveHubs = {
            THE_KLAXXI_LAKE = true,
            THE_KLAXXI_TERRACE = true,
            THE_KLAXXI_CLUTCHES = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    SHADO_PAN_OMNIA_MYSTICS_1 = {
        quests = {31039,31040,31041,31046},
        limit = 4, -- followups are not here
        exclusiveHubs = {
            SHADO_PAN_OMNIA_MYSTICS_2 = true,
            SHADO_PAN_OMNIA_MYSTICS_3 = true,
            SHADO_PAN_WU_KAO_ASSASSINS = true,
            SHADO_PAN_BLACKGUARD_DEFENDERS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    SHADO_PAN_OMNIA_MYSTICS_2 = {
        quests = {31042,31043,31047,31105},
        limit = 4, -- followups are not here
        exclusiveHubs = {
            SHADO_PAN_OMNIA_MYSTICS_1 = true,
            SHADO_PAN_OMNIA_MYSTICS_3 = true,
            SHADO_PAN_WU_KAO_ASSASSINS = true,
            SHADO_PAN_BLACKGUARD_DEFENDERS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    SHADO_PAN_OMNIA_MYSTICS_3 = {
        quests = {31044,31045,31048,31106},
        limit = 4, -- followups are not here
        exclusiveHubs = {
            SHADO_PAN_OMNIA_MYSTICS_1 = true,
            SHADO_PAN_OMNIA_MYSTICS_2 = true,
            SHADO_PAN_WU_KAO_ASSASSINS = true,
            SHADO_PAN_BLACKGUARD_DEFENDERS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    SHADO_PAN_WU_KAO_ASSASSINS = {
        quests = {31196,31197,31198,31199,31200,31201},
        limit = 4, -- followups are not here
        exclusiveHubs = {
            SHADO_PAN_OMNIA_MYSTICS_1 = true,
            SHADO_PAN_OMNIA_MYSTICS_2 = true,
            SHADO_PAN_OMNIA_MYSTICS_3 = true,
            SHADO_PAN_BLACKGUARD_DEFENDERS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    SHADO_PAN_WU_KAO_ASSASSINS_ELITES = {
        quests = {31203,31204},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {SHADO_PAN_WU_KAO_ASSASSINS = true},
        preQuestHubsGroup = {},
    },
    SHADO_PAN_BLACKGUARD_DEFENDERS = {
        quests = {31113,31114,31116,31118,31119},
        limit = 4, -- followups are not here
        exclusiveHubs = {
            SHADO_PAN_OMNIA_MYSTICS_1 = true,
            SHADO_PAN_OMNIA_MYSTICS_2 = true,
            SHADO_PAN_OMNIA_MYSTICS_3 = true,
            SHADO_PAN_WU_KAO_ASSASSINS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_MISTFALL_PEACE = {
        quests = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263},
        limit = 4, -- 2 random sets of 2
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_MISTFALL_PEACE_LEADOUTS = {
        quests = {30385,31294,31295},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_MISTFALL_PEACE = true},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_MISTFALL_PEACE_ELITES = {
        quests = {30235,30236,30239},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_MISTFALL_PEACE = true},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_MISTFALL_ATTACK = {
        quests = {30285,30286,30287,30288,30289,30290,31293},
        limit = 4, -- 2 random sets of 2
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_MISTFALL_ATTACK_LEADOUTS = {
        quests = {31296,31297},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_MISTFALL_ATTACK = true},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_MISTFALL_ATTACK_ELITES = {
        quests = {30296,30297},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_MISTFALL_ATTACK = true},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_RUINS_PEACE = {
        quests = {30200,30204,30205,30206,30226,30228,30304},
        limit = 4,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_RUINS_PEACE_ELITES = {
        quests = {30225,30227},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_RUINS_PEACE = true},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_RUINS_ATTACK = {
        quests = {30298,30299,30300,30301,30305,30481},
        limit = 4,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_RUINS_ATTACK_ELITES = {
        quests = {30302},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_RUINS_ATTACK = true},
        preQuestHubsGroup = {},
    },
    GOLDEN_LOTUS_RUINS_EXTRA = {
        quests = {30277,30280},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {GOLDEN_LOTUS_RUINS_PEACE = true, GOLDEN_LOTUS_RUINS_ATTACK = true},
        preQuestHubsGroup = {},
    },
    OPERATION_SHIELDWALL_LIONS_LANDING = {
        quests = {32148,32149,32150,32151,32152,32153},
        limit = 5,
        exclusiveHubs = {
            OPERATION_SHIELDWALL_RUINS_OF_OGUDEI = true,
            OPERATION_SHIELDWALL_BILGEWATER_OPERATIONS = true,
            OPERATION_SHIELDWALL_DOMINATION_POINT = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    OPERATION_SHIELDWALL_RUINS_OF_OGUDEI = {
        quests = {32116,32121,32115,32119,32346,32347,32122},
        limit = 6,
        exclusiveHubs = {
            OPERATION_SHIELDWALL_LIONS_LANDING = true,
            OPERATION_SHIELDWALL_BILGEWATER_OPERATIONS = true,
            OPERATION_SHIELDWALL_DOMINATION_POINT = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    OPERATION_SHIELDWALL_BILGEWATER_OPERATIONS = {
        quests = {32452,32154,32155,32156,32157,32158,32159,32433,32446},
        limit = 6,
        exclusiveHubs = {
            OPERATION_SHIELDWALL_LIONS_LANDING = true,
            OPERATION_SHIELDWALL_RUINS_OF_OGUDEI = true,
            OPERATION_SHIELDWALL_DOMINATION_POINT = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    OPERATION_SHIELDWALL_DOMINATION_POINT = {
        quests = {32451,32142,32143,32144,32145,32146},
        limit = 6,
        exclusiveHubs = {
            OPERATION_SHIELDWALL_LIONS_LANDING = true,
            OPERATION_SHIELDWALL_RUINS_OF_OGUDEI = true,
            OPERATION_SHIELDWALL_BILGEWATER_OPERATIONS = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    DOMINANCE_OFFENSIVE_DOMINATION_POINT = {
        quests = {32123,32126,32127,32128,32235},
        limit = 5,
        exclusiveHubs = {
            DOMINANCE_OFFENSIVE_LIONS_LANDING = true,
            DOMINANCE_OFFENSIVE_RUINS_OF_OGUDEI = true,
            DOMINANCE_OFFENSIVE_BILGEWATER_BEACH = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    DOMINANCE_OFFENSIVE_LIONS_LANDING = {
        quests = {32450,32130,32131,32132,32133,32134,32135},
        limit = 6,
        exclusiveHubs = {
            DOMINANCE_OFFENSIVE_DOMINATION_POINT = true,
            DOMINANCE_OFFENSIVE_RUINS_OF_OGUDEI = true,
            DOMINANCE_OFFENSIVE_BILGEWATER_BEACH = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    DOMINANCE_OFFENSIVE_RUINS_OF_OGUDEI = {
        quests = {32118,32120,32342,32343,32344,32345,32348,32449},
        limit = 7,
        exclusiveHubs = {
            DOMINANCE_OFFENSIVE_DOMINATION_POINT = true,
            DOMINANCE_OFFENSIVE_LIONS_LANDING = true,
            DOMINANCE_OFFENSIVE_BILGEWATER_BEACH = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    DOMINANCE_OFFENSIVE_BILGEWATER_BEACH = {
        quests = {32136,32137,32138,32139,32140,32141,32197,32199,32214,32221,32222,32223,32236,32237,32238},
        limit = 6,
        exclusiveHubs = {
            DOMINANCE_OFFENSIVE_DOMINATION_POINT = true,
            DOMINANCE_OFFENSIVE_LIONS_LANDING = true,
            DOMINANCE_OFFENSIVE_RUINS_OF_OGUDEI = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    KIRIN_TOR_OFFENSIVE_STAGE_1_BREADCRUMBS = {
        quests = {32731,32732,32733},
        limit = 3,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed The Assault on Shaol'mara
            -- if (not completedQuests[32644]) then print("alliance stage1 breadcrumb active") end
            return (not completedQuests[32644])
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_1 = {
        quests = {
            32525,32526,32527,32528,32529,32530,32531,32532,32533, -- court of bones
            32538,32539,32540,32541,32542,32543,32544, -- za'tual
            32535,32536,32537,32545,32546,32547,32548,32606, -- ihgaluk crag
        },
        limit = 11,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed The Assault on Shaol'mara
            -- if (not completedQuests[32644]) then print("alliance stage1 active") end
            return (not completedQuests[32644])
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_1_FINAL_BOSS = {
        quests = {32576,32577,32578},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_STAGE_1 = true,
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed The Assault on Shaol'mara
            -- if (not completedQuests[32644]) then print("alliance stage1 final boss active") end
            return (not completedQuests[32644])
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_2_PVE_BREADCRUMBS = {
        quests = {32731,32732,32733},
        limit = 3,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed Tear Down This Wall!
            -- if (completedQuests[32644] and (not completedQuests[32654])) then print("alliance stage2 breadcrumb active") end
            return (completedQuests[32644] and (not completedQuests[32654]))
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_2_PVE = {
        quests = {
            32525,32526,32527,32528,32529,32530,32531,32532,32533, -- court of bones
            32538,32539,32540,32541,32542,32543,32544, -- za'tual
            32535,32536,32537,32545,32546,32547,32548,32606, -- ihgaluk crag
            32571,32572,32573,32574,32575, -- diremoor
        },
        limit = 11,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed Tear Down This Wall!
            -- if (completedQuests[32644] and (not completedQuests[32654])) then print("alliance stage2 active") end
            return (completedQuests[32644] and (not completedQuests[32654]))
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_2_FINAL_BOSS = {
        quests = {32578,32579,32580,32581},
        limit = 1,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_STAGE_2_PVE = true,
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed Tear Down This Wall!
            -- if (completedQuests[32644] and (not completedQuests[32654])) then print("alliance stage2 final boss active") end
            return (completedQuests[32644] and (not completedQuests[32654]))
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_3_PVE_BREADCRUMBS = {
        quests = {32731,32732,32733,32567,32568},
        limit = 3,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {KIRIN_TOR_OFFENSIVE_STAGE_3_PVE = true},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed To the Skies!
            -- if (completedQuests[32654] and (not completedQuests[32652])) then print("alliance stage3 breadcrumb active") end
            return (completedQuests[32654] and (not completedQuests[32652]))
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_3_PVE = {
        quests = {
            32525,32526,32527,32528,32529,32530,32531,32532,32533, -- court of bones
            32538,32539,32540,32541,32542,32543,32544, -- za'tual
            32535,32536,32537,32545,32546,32547,32548,32606, -- ihgaluk crag
            32571,32572,32573,32574,32575, -- diremoor
            32550,32551,32552,32553,32554, -- beast pens
            32555,32556,32557,32558,32559,32560, -- conqueror's terrace
        },
        limit = 8,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed To the Skies!
            -- if (completedQuests[32654] and (not completedQuests[32652])) then print("alliance stage3 active") end
            return (completedQuests[32654] and (not completedQuests[32652]))
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_3_FINAL_BOSS = {
        quests = {32578,32579,32580,32581,32582,32583},
        limit = 1,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_STAGE_3_PVE = true,
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE = true,
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed Tear Down This Wall!
            -- if (completedQuests[32654]) then print("alliance stage3 final boss active") end
            return completedQuests[32654]
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE_BREADCRUMBS = {
        quests = {32731,32732,32733},
        limit = 3,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {KIRIN_TOR_OFFENSIVE_STAGE_3_PVE = true},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32652] then print("alliance stage4 step1 breadcrumb active") end
            return completedQuests[32652]
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE = {
        quests = {
            32525,32526,32527,32528,32529,32530,32531,32532,32533, -- court of bones
            32538,32539,32540,32541,32542,32543,32544, -- za'tual
            32535,32536,32537,32545,32546,32547,32548,32606, -- ihgaluk crag
            32571,32572,32573,32574,32575, -- diremoor
        },
        limit = 6,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
            KIRIN_TOR_OFFENSIVE_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32652] then print("alliance stage4 step1 active") end
            return completedQuests[32652]
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_2_PVE_BREADCRUMBS = {
        quests = {32567,32568},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE = true
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32652] then print("alliance stage4 step2 breadcrumb active") end
            return completedQuests[32652]
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_2_PVE = {
        quests = {
            32550,32551,32552,32553,32554, -- beast pens
            32555,32556,32557,32558,32559,32560, -- conqueror's terrace
        },
        limit = 3,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE = true
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32652] then print("alliance stage4 step2 active") end
            return completedQuests[32652]
        end,
    },
    KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_3_PVE = {
        quests = {32586,32588},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_2_PVE = true
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32652] then print("alliance stage4 step3 active") end
            return completedQuests[32652]
        end,
    },
    KIRIN_TOR_OFFENSIVE_PVP = {
        quests = {32301,32485,32627,32628,32632,32633,32634,32635,32636,32637,32638,32639},
        limit = 7,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_STAGE_2_PVE_BREADCRUMBS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_2_PVE = true,
            KIRIN_TOR_OFFENSIVE_STAGE_2_FINAL_BOSS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_3_PVE_BREADCRUMBS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_3_PVE = true,
            KIRIN_TOR_OFFENSIVE_STAGE_3_FINAL_BOSS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE_BREADCRUMBS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    KIRIN_TOR_OFFENSIVE_PVP_FINAL = {
        quests = {32631},
        limit = 1,
        exclusiveHubs = {
            KIRIN_TOR_OFFENSIVE_STAGE_2_PVE_BREADCRUMBS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_2_PVE = true,
            KIRIN_TOR_OFFENSIVE_STAGE_2_FINAL_BOSS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_3_PVE_BREADCRUMBS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_3_PVE = true,
            KIRIN_TOR_OFFENSIVE_STAGE_3_FINAL_BOSS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE_BREADCRUMBS = true,
            KIRIN_TOR_OFFENSIVE_STAGE_4_STEP_1_PVE = true,
        },
        preQuestHubsSingle = {
            KIRIN_TOR_OFFENSIVE_PVP = true,
        },
        preQuestHubsGroup = {},
    },
    SUNREAVER_ONSLAUGHT_STAGE_1_BREADCRUMBS = {
        quests = {32728,32729,32730},
        limit = 3,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed The Assault on Zeb'tula
            -- if (not completedQuests[32212]) then print("horde stage1 breadcrumb active") end
            return (not completedQuests[32212])
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_1 = {
        quests = {
            32201,32218,32219,32220,32224,32225,32226,32495,32517, -- court of bones
            32200,32215,32216,32217,32227,32252,32275, -- za'tual
            32204,32254,32255,32274,32299,32489,32491,32605, -- ihgaluk crag
        },
        limit = 11,
        exclusiveHubs = {},
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed The Assault on Zeb'tula
            -- if (not completedQuests[32212]) then print("horde stage1 active") end
            return (not completedQuests[32212])
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_1_FINAL_BOSS = {
        quests = {32293,32561,32562},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_STAGE_1 = true,
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed The Assault on Zeb'tula
            -- if (not completedQuests[32212]) then print("horde stage1 final boss active") end
            return (not completedQuests[32212])
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_2_PVE_BREADCRUMBS = {
        quests = {32728,32729,32730},
        limit = 3,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed Tear Down This Wall!
            -- if (completedQuests[32212] and (not completedQuests[32276])) then print("horde stage2 breadcrumb active") end
            return (completedQuests[32212] and (not completedQuests[32276]))
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_2_PVE = {
        quests = {
            32201,32218,32219,32220,32224,32225,32226,32495,32517, -- court of bones
            32200,32215,32216,32217,32227,32252,32275, -- za'tual
            32204,32254,32255,32274,32299,32489,32491,32605, -- ihgaluk crag
            32228,32230,32285,32287,32506, -- diremoor
        },
        limit = 11,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed Tear Down This Wall!
            -- if (completedQuests[32212] and (not completedQuests[32276])) then print("horde stage2 active") end
            return (completedQuests[32212] and (not completedQuests[32276]))
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_2_FINAL_BOSS = {
        quests = {32293,32520,32521,32522},
        limit = 1,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_STAGE_2_PVE = true,
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed Tear Down This Wall!
            -- if (completedQuests[32212] and (not completedQuests[32276])) then print("horde stage2 final boss active") end
            return (completedQuests[32212] and (not completedQuests[32276]))
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_3_PVE_BREADCRUMBS = {
        quests = {32728,32729,32730,32523,32524},
        limit = 3,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed To the Skies!
            -- if (completedQuests[32276] and (not completedQuests[32277])) then print("horde stage3 breadcrumb active") end
            return (completedQuests[32276] and (not completedQuests[32277]))
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_3_PVE = {
        quests = {
            32201,32218,32219,32220,32224,32225,32226,32495,32517, -- court of bones
            32200,32215,32216,32217,32227,32252,32275, -- za'tual
            32204,32254,32255,32274,32299,32489,32491,32605, -- ihgaluk crag
            32228,32230,32285,32287,32506, -- diremoor
            32207,32282,32283,32297,32298, -- beast pens
            32206,32232,32233,32234,32493,32494, -- conqueror's terrace
        },
        limit = 11,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has not completed To the Skies!
            -- if (completedQuests[32276] and (not completedQuests[32277])) then print("horde stage3 active") end
            return (completedQuests[32276] and (not completedQuests[32277]))
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_3_FINAL_BOSS = {
        quests = {32293,32294,32520,32521,32522,32564},
        limit = 1,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_STAGE_3_PVE = true,
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE = true,
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed Tear Down This Wall!
            -- if completedQuests[32276] then print("horde stage3 final boss active") end
            return completedQuests[32276]
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE_BREADCRUMBS = {
        quests = {32728,32729,32730},
        limit = 3,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32277] then print("horde stage4 step1 breadcrumb active") end
            return completedQuests[32277]
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE = {
        quests = {
            32201,32218,32219,32220,32224,32225,32226,32495,32517, -- court of bones
            32200,32215,32216,32217,32227,32252,32275, -- za'tual
            32204,32254,32255,32274,32299,32489,32491,32605, -- ihgaluk crag
            32228,32230,32285,32287,32506, -- diremoor
        },
        limit = 6,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_PVP = true,
            SUNREAVER_ONSLAUGHT_PVP_FINAL = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32277] then print("horde stage4 step1 active") end
            return completedQuests[32277]
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_4_STEP_2_PVE_BREADCRUMBS = {
        quests = {32523,32524},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE = true
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32277] then print("horde stage4 step2 breadcrumb active") end
            return completedQuests[32277]
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_4_STEP_2_PVE = {
        quests = {
            32207,32282,32283,32297,32298, -- beast pens
            32206,32232,32233,32234,32493,32494, -- conqueror's terrace
        },
        limit = 3,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE = true
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32277] then print("horde stage4 step2 active") end
            return completedQuests[32277]
        end,
    },
    SUNREAVER_ONSLAUGHT_STAGE_4_STEP_3_PVE = {
        quests = {32208,32209},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_2_PVE = true
        },
        preQuestHubsGroup = {},
        IsActive = function(completedQuests)
            -- Active only if the player has completed To the Skies!
            -- if completedQuests[32277] then print("horde stage4 step3 active") end
            return completedQuests[32277]
        end,
    },
    SUNREAVER_ONSLAUGHT_PVP = {
        quests = {32213,32262,32264,32265,32266,32268,32269,32288,32300,32302,32303,32305},
        limit = 7,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_STAGE_2_PVE_BREADCRUMBS = true,
            SUNREAVER_ONSLAUGHT_STAGE_2_PVE = true,
            SUNREAVER_ONSLAUGHT_STAGE_2_FINAL_BOSS = true,
            SUNREAVER_ONSLAUGHT_STAGE_3_PVE_BREADCRUMBS = true,
            SUNREAVER_ONSLAUGHT_STAGE_3_PVE = true,
            SUNREAVER_ONSLAUGHT_STAGE_3_FINAL_BOSS = true,
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE_BREADCRUMBS = true,
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE = true,
        },
        preQuestHubsSingle = {},
        preQuestHubsGroup = {},
    },
    SUNREAVER_ONSLAUGHT_PVP_FINAL = {
        quests = {32304},
        limit = 1,
        exclusiveHubs = {
            SUNREAVER_ONSLAUGHT_STAGE_2_PVE_BREADCRUMBS = true,
            SUNREAVER_ONSLAUGHT_STAGE_2_PVE = true,
            SUNREAVER_ONSLAUGHT_STAGE_2_FINAL_BOSS = true,
            SUNREAVER_ONSLAUGHT_STAGE_3_PVE_BREADCRUMBS = true,
            SUNREAVER_ONSLAUGHT_STAGE_3_PVE = true,
            SUNREAVER_ONSLAUGHT_STAGE_3_FINAL_BOSS = true,
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE_BREADCRUMBS = true,
            SUNREAVER_ONSLAUGHT_STAGE_4_STEP_1_PVE = true,
        },
        preQuestHubsSingle = {
            SUNREAVER_ONSLAUGHT_PVP = true,
        },
        preQuestHubsGroup = {},
    },
}
