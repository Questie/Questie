---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")

---@alias HubId string

---@class Hub
---@field quests QuestId[]
---@field limit number

---@type table<HubId, Hub>
DailyQuests.hubs = {
    TOL_BARAD_ALLIANCE = {
        quests = {27944,27948,27949,27966,27967,27970,27971,27972,27973,27975,27978,27987,27991,27992,28046,28050,28059,28063,28130,28137,28275},
        limit = 6,
    },
    TOL_BARAD_HORDE = {
        quests = {28678,28679,28680,28681,28682,28683,28684,28685,28686,28687,28689,28690,28691,28692,28693,28694,28695,28696,28697,28698,28700},
        limit = 6,
    },
    THE_ANGLERS = {
        quests = {30584,30585,30586,30588,30598,30613,30658,30678,30698,30700,30701,30753,30754,30763},
        limit = 3,
    },
    THE_TILLERS = {
        quests = {30317,30318,30319,30321,30322,30323,30324,30325,30326,30327},
        limit = 2,
        exclusiveHubs = {},
    },
    AUGUST_CELESTIALS_RED_CRANE = {
        quests = {30716,30717,30718},
        limit = 3, -- 3(TO DO - progressive daily chain)
        exclusiveHubs = {
            AUGUST_CELESTIALS_JADE_SERPENT = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
    },
    AUGUST_CELESTIALS_JADE_SERPENT = {
        quests = {30006,30063,60064,30065,30066},
        limit = 3, -- 3 (random of 5)
        exclusiveHubs = {
            AUGUST_CELESTIALS_RED_CRANE = true,
            AUGUST_CELESTIALS_WHITE_TIGER = true,
            AUGUST_CELESTIALS_NIUZAO_TEMPLE = true,
        },
    },
    AUGUST_CELESTIALS_WHITE_TIGER = {
        quests = {31492,31517,30879,30880},
        limit = 2, -- 1 (random of 2) + 1 (2 random chains of 4 each,showing only firs one)
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
}
