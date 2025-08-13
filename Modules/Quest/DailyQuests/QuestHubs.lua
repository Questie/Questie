---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")

---@alias HubId string

---@class Hub
---@field quests QuestId[]
---@field limit number
---@field exclusiveHubs table<HubId, boolean> A list of other hubs that are exclusive to this hub. If the player has quests from any of these hubs, they cannot have quests from this hub.

---@type table<HubId, Hub>
DailyQuests.hubs = {
    TOL_BARAD_ALLIANCE = {
        quests = {27944,27948,27949,27966,27967,27970,27971,27972,27973,27975,27978,27987,27991,27992,28046,28050,28059,28063,28130,28137,28275},
        limit = 6,
        exclusiveHubs = {},
    },
    TOL_BARAD_HORDE = {
        quests = {28678,28679,28680,28681,28682,28683,28684,28685,28686,28687,28689,28690,28691,28692,28693,28694,28695,28696,28697,28698,28700},
        limit = 6,
        exclusiveHubs = {},
    },
    THE_ANGLERS = {
        quests = {30584,30585,30586,30588,30598,30613,30658,30678,30698,30700,30701,30753,30754,30763},
        limit = 3,
        exclusiveHubs = {},
    },
    AUGUST_CELESTIALS_RED_CRANE = {
        quests = {30716,30717,30718,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        limit = 4, -- 3(TO DO - progressive daily chain)
        exclusiveHubs = {
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
    },
    AUGUST_CELESTIALS_JADE_SERPENT = {
        quests = {30006,30063,30064,30065,30066},
        limit = 3, -- 3 (random of 5)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
    },
    AUGUST_CELESTIALS_WHITE_TIGER = {
        quests = {31492,31517,30879,30880},
        limit = 2, -- 1 (random of 2) + 1 (2 random chains of 4 each, showing only first one)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
    },
    AUGUST_CELESTIALS_NIUZAO_TEMPLE = {
        quests = {30952,30953,30954,30955,30956,30957,30958,30959},
        limit = 4, -- 1 (random of 2) + 3 (random of 6)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = {
        quests = {30150,30151,31704,31705,31716},
        limit = 3, -- 2 (random of 4) + 1 (Needle Me Not)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_SPRITES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = {
        quests = {30156,30157,30158,31194},
        limit = 3, -- 2 (random of 3) + 1 (Slitherscale Suppression)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SPRITES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_SPRITES = {
        quests = {31699,31700,31703},
        limit = 3, -- all 3
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_TIGERS = {
        quests = {30154,30155,31698,31701,31702},
        limit = 3, -- 2 (random of 4) + 1 (random of 2)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_SPRITES = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = {
        quests = {30152,31717,31718,31719,31720,31721},
        limit = 3, -- 1 (The Sky Race) + 2 (random of 5)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_SPRITES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = {
        quests = {31706,31707,31708,31709,31710,31711},
        limit = 3, -- 2 (random of 5) + 1 (The Seed of Doubt)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_SPRITES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = true,
        },
    },
    ORDER_OF_THE_CLOUD_SERPENT_OONA_KAGU = {
        quests = {30159,31712,31713,31714,31715},
        limit = 3, -- 2 (random of 4) + 1 (The Big Kah-Oona)
        exclusiveHubs = {
            ORDER_OF_THE_CLOUD_SERPENT_ARBORETUM = true,
            ORDER_OF_THE_CLOUD_SERPENT_SAUROK_TURTLES = true,
            ORDER_OF_THE_CLOUD_SERPENT_SPRITES = true,
            ORDER_OF_THE_CLOUD_SERPENT_TIGERS = true,
            ORDER_OF_THE_CLOUD_SERPENT_RACE_DAY = true,
            ORDER_OF_THE_CLOUD_SERPENT_WIDOWS_WALL = true,
        },
    },
    THE_KLAXXI_LAKE = {
        quests = {31024,31267,31268,31269,31270,31271,31272},
        limit = 7, -- 6 honored + 1 revered
        exclusiveHubs = {
            THE_KLAXXI_TERRACE = true,
            THE_KLAXXI_CLUTCHES = true,
            THE_KLAXXI_ZANVESS = true,
        },
    },
    THE_KLAXXI_TERRACE = {
        quests = {31231,31232,31233,31234,31235,31237,31238,31677},
        limit = 8, -- 6 honored + 1 revered + 1 hidden
        exclusiveHubs = {
            THE_KLAXXI_LAKE = true,
            THE_KLAXXI_CLUTCHES = true,
            THE_KLAXXI_ZANVESS = true,
        },
    },
    THE_KLAXXI_CLUTCHES = {
        quests = {31109,31487,31494,31496,31502,31503,31504,31599},
        limit = 8, -- 6 honored + 1 revered + 1 hidden
        exclusiveHubs = {
            THE_KLAXXI_LAKE = true,
            THE_KLAXXI_TERRACE = true,
            THE_KLAXXI_ZANVESS = true,
        },
    },
    THE_KLAXXI_ZANVESS = {
        quests = {31111,31505,31506,31507,31508,31509,31510,31598},
        limit = 8, -- 6 honored + 1 revered + 1 hidden
        exclusiveHubs = {
            THE_KLAXXI_LAKE = true,
            THE_KLAXXI_TERRACE = true,
            THE_KLAXXI_CLUTCHES = true,
        },
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
        preQuestHubs = {},
    },
    GOLDEN_LOTUS_MISTFALL_PEACE = {
        quests = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263},
        limit = 4, -- 2 random sets of 2
        exclusiveHubs = {},
        preQuestHubs = {},
    },
    GOLDEN_LOTUS_MISTFALL_PEACE_LEADOUTS = {
        quests = {30385,31294,31295},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubs = {GOLDEN_LOTUS_MISTFALL_PEACE = true},
    },
    GOLDEN_LOTUS_MISTFALL_PEACE_ELITES = {
        quests = {30235,30236,30239},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubs = {GOLDEN_LOTUS_MISTFALL_PEACE = true},
    },
    GOLDEN_LOTUS_MISTFALL_ATTACK = {
        quests = {30285,30286,30287,30288,30289,30290,31293},
        limit = 4, -- 2 random sets of 2
        exclusiveHubs = {},
        preQuestHubs = {},
    },
    GOLDEN_LOTUS_MISTFALL_ATTACK_LEADOUTS = {
        quests = {31296,31297},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubs = {GOLDEN_LOTUS_MISTFALL_ATTACK = true},
    },
    GOLDEN_LOTUS_MISTFALL_ATTACK_ELITES = {
        quests = {30296,30297},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubs = {GOLDEN_LOTUS_MISTFALL_ATTACK = true},
    },
    GOLDEN_LOTUS_RUINS_PEACE = {
        quests = {30200,30204,30205,30206,30226,30228,30304},
        limit = 4,
        exclusiveHubs = {},
        preQuestHubs = {},
    },
    GOLDEN_LOTUS_RUINS_PEACE_ELITES = {
        quests = {30225,30227},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubs = {GOLDEN_LOTUS_RUINS_PEACE = true},
    },
    GOLDEN_LOTUS_RUINS_ATTACK = {
        quests = {30298,30299,30300,30301,30305,30481},
        limit = 4,
        exclusiveHubs = {},
        preQuestHubs = {},
    },
    GOLDEN_LOTUS_RUINS_ATTACK_ELITES = {
        quests = {30302},
        limit = 1,
        exclusiveHubs = {},
        preQuestHubs = {GOLDEN_LOTUS_RUINS_ATTACK = true},
    },
}
