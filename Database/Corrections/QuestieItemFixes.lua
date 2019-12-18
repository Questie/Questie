QuestieItemFixes = {...}
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

local tinsert = table.insert
local _AddMissingItemIDs

function QuestieItemFixes:Load()
    _AddMissingItemIDs()

    return {
        [730] = {
            [QuestieDB.itemKeys.npcDrops] = {1418,127,2206,2207,517,2203,456,1958,2202,2205,1027,513,2208,2204,2201,126,515,458,1028,171,1767,1025,3739,1024,3737,1026,3742,3740,422,578,545,548,1083,544},
        },
        [3173] = {
            [QuestieDB.itemKeys.npcDrops] = {2163,2164,1188,1189,1186,2165,1797,1778},
        },
        [5475] = {
            [QuestieDB.itemKeys.name] = "Wooden Key",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {3919,3834},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5519] = {
            [QuestieDB.itemKeys.npcDrops] = {3928},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4611] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2744},
        },
        [3340] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1610,1667},
        },
        [4483] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2689},
        },
        [3829] = {
            [QuestieDB.itemKeys.relatedQuests] = {713,1193},
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [14645] = {
            [QuestieDB.itemKeys.name] = "Unfinished Skeleton Key",
            [QuestieDB.itemKeys.relatedQuests] = {5801,5802},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {4004},
        },
        [15843] = {
            [QuestieDB.itemKeys.name] = "Filled Dreadmist Peak Sampler",
            [QuestieDB.itemKeys.relatedQuests] = {6127},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19464},
        },
        [15845] = {
            [QuestieDB.itemKeys.name] = "Filled Cliffspring Falls Sampler",
            [QuestieDB.itemKeys.relatedQuests] = {6122},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19463},
        },
        [17124] = {
            [QuestieDB.itemKeys.name] = "Syndicate Emblem",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {2246,2590,2240,2586,2589,2587,2588,2242,2241,2319,2261,2244,2260},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [8072] = {
            [QuestieDB.itemKeys.name] = "Silixiz's Tower Key",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {7287},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7923] = {
            [QuestieDB.itemKeys.npcDrops] = {7051},
        },
        [7675] = {
            [QuestieDB.itemKeys.name] = "Defias Shipping Schedule",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {6846},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7737] = {
            [QuestieDB.itemKeys.name] = "Sethir's Journal",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {6909},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7208] = {
            [QuestieDB.itemKeys.name] = "Tazan's Key",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {6466},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12347] = {
            [QuestieDB.itemKeys.name] = "Filled Cleansing Bowl",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174795},
        },
        [2886] = {
            [QuestieDB.itemKeys.npcDrops] = {1125,1126,1127,1689},
        },
        [5051] = {
            [QuestieDB.itemKeys.name] = "Dig Rat",
            [QuestieDB.itemKeys.relatedQuests] = {862},
            [QuestieDB.itemKeys.npcDrops] = {3444},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5056] = {
            [QuestieDB.itemKeys.objectDrops] = {1619,3726,1618,3724,1620,3727},
        },
        [12349] = {
            [QuestieDB.itemKeys.name] = "Cliffspring River Sample",
            [QuestieDB.itemKeys.relatedQuests] = {4762},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {175371},
        },
        [12350] = {
            [QuestieDB.itemKeys.name] = "Empty Sampling Tube",
            [QuestieDB.itemKeys.relatedQuests] = {4762},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5184] = {
            [QuestieDB.itemKeys.name] = "Filled Crystal Phial",
            [QuestieDB.itemKeys.relatedQuests] = {921},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19549},
        },
        [5185] = {
            [QuestieDB.itemKeys.name] = "Crystal Phial",
            [QuestieDB.itemKeys.relatedQuests] = {921},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5186] = {
            [QuestieDB.itemKeys.name] = "Partially Filled Vessel",
            [QuestieDB.itemKeys.relatedQuests] = {928},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5639] = {
            [QuestieDB.itemKeys.name] = "Filled Jade Phial",
            [QuestieDB.itemKeys.relatedQuests] = {929},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19550},
        },
        [5619] = {
            [QuestieDB.itemKeys.name] = "Jade Phial",
            [QuestieDB.itemKeys.relatedQuests] = {929},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5645] = {
            [QuestieDB.itemKeys.name] = "Filled Tourmaline Phial",
            [QuestieDB.itemKeys.relatedQuests] = {933},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19551},
        },
        [5621] = {
            [QuestieDB.itemKeys.name] = "Tourmaline Phial",
            [QuestieDB.itemKeys.relatedQuests] = {933},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [18151] = {
            [QuestieDB.itemKeys.name] = "Filled Amethyst Phial",
            [QuestieDB.itemKeys.relatedQuests] = {7383},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19552},
        },
        [18152] = {
            [QuestieDB.itemKeys.name] = "Amethyst Phial",
            [QuestieDB.itemKeys.relatedQuests] = {7383},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5188] = {
            [QuestieDB.itemKeys.name] = "Filled Vessel",
            [QuestieDB.itemKeys.relatedQuests] = {935},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11184] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {164658,164778},
        },
        [11185] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {164659,164779},
        },
        [11186] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {164660,164780},
        },
        [11188] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {164661,164781},
        },
        [10639] = {
            [QuestieDB.itemKeys.npcDrops] = {1988,1989},
            [QuestieDB.itemKeys.objectDrops] = {152094},
        },
        [14338] = {
            [QuestieDB.itemKeys.name] = "Empty Water Tube",
            [QuestieDB.itemKeys.relatedQuests] = {4812},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [15209] = {
            [QuestieDB.itemKeys.name] = "Relic Bundle",
            [QuestieDB.itemKeys.relatedQuests] = {5721},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [14339] = {
            [QuestieDB.itemKeys.name] = "Moonwell Water Tube",
            [QuestieDB.itemKeys.relatedQuests] = {4812},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174795},
        },
        [8584] = {
            [QuestieDB.itemKeys.name] = "Untapped Dowsing Widget",
            [QuestieDB.itemKeys.relatedQuests] = {992},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [8585] = {
            [QuestieDB.itemKeys.name] = "Tapped Dowsing Widget",
            [QuestieDB.itemKeys.relatedQuests] = {992},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {144052},
        },
        [11149] = {
            [QuestieDB.itemKeys.name] = "Samophlange Manual",
            [QuestieDB.itemKeys.relatedQuests] = {3924},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11018] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {157936},
        },
        [6435] = {
            [QuestieDB.itemKeys.name] = "Infused Burning Gem",
            [QuestieDB.itemKeys.relatedQuests] = {1435},
            [QuestieDB.itemKeys.npcDrops] = {4663,4664,4665,4666,4667,4668,4705,13019},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3388] = {
            [QuestieDB.itemKeys.name] = "Strong Troll's Brool Potion",
            [QuestieDB.itemKeys.relatedQuests] = {515},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3508] = {
            [QuestieDB.itemKeys.name] = "Mudsnout Mixture",
            [QuestieDB.itemKeys.relatedQuests] = {515},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4904] = {
            [QuestieDB.itemKeys.name] = "Venomtail Antidote",
            [QuestieDB.itemKeys.relatedQuests] = {812},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [2594] = {
            [QuestieDB.itemKeys.name] = "Flagon of Dwarven Honeymead",
            [QuestieDB.itemKeys.npcDrops] = {1464},
        },
        [5868] = {
            [QuestieDB.itemKeys.name] = "Filled Etched Phial",
            [QuestieDB.itemKeys.relatedQuests] = {1195},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {20806},
        },
        [16642] = {
            [QuestieDB.itemKeys.name] = "Shredder Operating Manual - Chapter 1",
            [QuestieDB.itemKeys.relatedQuests] = {6504},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16643] = {
            [QuestieDB.itemKeys.name] = "Shredder Operating Manual - Chapter 2",
            [QuestieDB.itemKeys.relatedQuests] = {6504},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16644] = {
            [QuestieDB.itemKeys.name] = "Shredder Operating Manual - Chapter 3",
            [QuestieDB.itemKeys.relatedQuests] = {6504},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16764] = {
            [QuestieDB.itemKeys.name] = "Warsong Scout Update",
            [QuestieDB.itemKeys.relatedQuests] = {6543,6547},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16763] = {
            [QuestieDB.itemKeys.name] = "Warsong Runner Update",
            [QuestieDB.itemKeys.relatedQuests] = {6543,6545},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16765] = {
            [QuestieDB.itemKeys.name] = "Warsong Outrider Update",
            [QuestieDB.itemKeys.relatedQuests] = {6543,6546},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [1013] = {
            [QuestieDB.itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [2856] = {
            [QuestieDB.itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [11131] = {
            [QuestieDB.itemKeys.name] = "Hive Wall Sample",
            [QuestieDB.itemKeys.relatedQuests] = {3883},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174793},
        },
        [5455] = {
            [QuestieDB.itemKeys.name] = "Divined Scroll",
            [QuestieDB.itemKeys.relatedQuests] = {1016},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9440] = {
            [QuestieDB.itemKeys.name] = "Acceptable Basilisk Sample",
            [QuestieDB.itemKeys.relatedQuests] = {654},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9441] = {
            [QuestieDB.itemKeys.name] = "Acceptable Hyena Sample",
            [QuestieDB.itemKeys.relatedQuests] = {654},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9438] = {
            [QuestieDB.itemKeys.name] = "Acceptable Scorpid Sample",
            [QuestieDB.itemKeys.relatedQuests] = {654},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [8523] = {
            [QuestieDB.itemKeys.name] = "Field Testing Kit",
            [QuestieDB.itemKeys.relatedQuests] = {654},
            [QuestieDB.itemKeys.npcDrops] = {7683},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9330] = {
            [QuestieDB.itemKeys.name] = "Snapshot of Gammerita",
            [QuestieDB.itemKeys.relatedQuests] = {2944},
            [QuestieDB.itemKeys.npcDrops] = {7977},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11113] = {
            [QuestieDB.itemKeys.objectDrops] = {161526},
        },
        [11470] = {
            [QuestieDB.itemKeys.name] = "Tablet Transcript",
            [QuestieDB.itemKeys.relatedQuests] = {4296},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {169294},
        },
        [12283] = {
            [QuestieDB.itemKeys.npcDrops] = {7047,7048,7049,},
        },
        [11522] = {
            [QuestieDB.itemKeys.name] = "Silver Totem of Aquementas",
            [QuestieDB.itemKeys.relatedQuests] = {4005},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {148507},
        },
        [9593] = { -- #1184
            [QuestieDB.itemKeys.name] = "Treant Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3126},
            [QuestieDB.itemKeys.npcDrops] = {7584},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9595] = {
            [QuestieDB.itemKeys.name] = "Hippogryph Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3124},
            [QuestieDB.itemKeys.npcDrops] = {5300,5304,5305,5306},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9596] = { -- #1184
            [QuestieDB.itemKeys.name] = "Faerie Dragon Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3125},
            [QuestieDB.itemKeys.npcDrops] = {5276,5278},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11954] = { -- #1070
            [QuestieDB.itemKeys.name] = "Filled Pure Sample Jar",
            [QuestieDB.itemKeys.relatedQuests] = {4513},
            [QuestieDB.itemKeys.npcDrops] = {6556,6557,6559,},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12907] = { -- #1083
            [QuestieDB.itemKeys.name] = "Corrupted Moonwell Water",
            [QuestieDB.itemKeys.relatedQuests] = {5157},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {176184},
        },
        [12922] = { -- #1083
            [QuestieDB.itemKeys.name] = "Empty Canteen",
            [QuestieDB.itemKeys.relatedQuests] = {5157},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7268] = { -- #1097
            [QuestieDB.itemKeys.name] = "Xavian Water Sample",
            [QuestieDB.itemKeys.relatedQuests] = {1944},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174797},
        },
        [7269] = { -- #1097
            [QuestieDB.itemKeys.name] = "Deino's Flask",
            [QuestieDB.itemKeys.relatedQuests] = {1944},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11412] = { -- #1136
            [QuestieDB.itemKeys.name] = "Nagmara's Vial",
            [QuestieDB.itemKeys.relatedQuests] = {4201},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11413] = { -- #1136
            [QuestieDB.itemKeys.name] = "Nagmara's Filled Vial",
            [QuestieDB.itemKeys.relatedQuests] = {4201},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {165678},
        },
        [15874] = {
            [QuestieDB.itemKeys.objectDrops] = {177784},
        },
        [12885] = { -- #1148
            [QuestieDB.itemKeys.name] = "Pamela's Doll",
            [QuestieDB.itemKeys.relatedQuests] = {5149},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5798] = {
            [QuestieDB.itemKeys.objectDrops] = {19868,19869,19870,19871,19872,19873},
        },
        [16974] = { -- #1156
            [QuestieDB.itemKeys.name] = "Empty Water Vial",
            [QuestieDB.itemKeys.relatedQuests] = {5247},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16973] = { -- #1156
            [QuestieDB.itemKeys.name] = "Vial of Dire Water",
            [QuestieDB.itemKeys.relatedQuests] = {5247},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {178224},
        },
        [7134] = { -- #1163
            [QuestieDB.itemKeys.name] = "Sturdy Dragonmaw Shinbone",
            [QuestieDB.itemKeys.relatedQuests] = {1846},
            [QuestieDB.itemKeys.npcDrops] = {1034,1035,1036,1038,1057,},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12324] = {
            [QuestieDB.itemKeys.npcDrops] = {10321}, -- #1175
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7206] = { -- #1286
            [QuestieDB.itemKeys.name] = "Mirror Lake Water Sample",
            [QuestieDB.itemKeys.relatedQuests] = {1860},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174794},
        },
        [7207] = { -- #1286
            [QuestieDB.itemKeys.name] = "Jennea's Flask",
            [QuestieDB.itemKeys.relatedQuests] = {1860},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [10575] = {
            [QuestieDB.itemKeys.npcDrops] = {}, -- #1216
            [QuestieDB.itemKeys.objectDrops] = {10569},
        },
        [9594] = { -- #1227
            [QuestieDB.itemKeys.name] = "Wildkin Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3123},
            [QuestieDB.itemKeys.npcDrops] = {2927,2928,2929,},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [2894] = { -- #1285
            [QuestieDB.itemKeys.name] = "Rhapsody Malt",
            [QuestieDB.itemKeys.relatedQuests] = {384},
            [QuestieDB.itemKeys.npcDrops] = {1247},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12567] = {
            [QuestieDB.itemKeys.name] = "Filled Flasket",
            [QuestieDB.itemKeys.relatedQuests] = {4505},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {148501},
        },
        [12813] = { -- #1313
            [QuestieDB.itemKeys.name] = "Flask of Mystery Goo",
            [QuestieDB.itemKeys.relatedQuests] = {5085},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11947] = { -- #1315
            [QuestieDB.itemKeys.name] = "Filled Cursed Ooze Jar",
            [QuestieDB.itemKeys.relatedQuests] = {4512},
            [QuestieDB.itemKeys.npcDrops] = {7086},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11949] = { -- #1315
            [QuestieDB.itemKeys.name] = "Filled Tainted Ooze Jar",
            [QuestieDB.itemKeys.relatedQuests] = {4512},
            [QuestieDB.itemKeys.npcDrops] = {7092},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [18746] = { -- #1344
            [QuestieDB.itemKeys.name] = "Divination Scryer",
            [QuestieDB.itemKeys.relatedQuests] = {7666,7669,8258,},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [18605] = {
            [QuestieDB.itemKeys.npcDrops] = {12396}, -- #7583
        },
        [10691] = { -- #1396
            [QuestieDB.itemKeys.name] = "Filled Vial Labeled #1",
            [QuestieDB.itemKeys.relatedQuests] = {3568},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {152598},
        },
        [10692] = { -- #1396
            [QuestieDB.itemKeys.name] = "Filled Vial Labeled #2",
            [QuestieDB.itemKeys.relatedQuests] = {3568},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {152604},
        },
        [10693] = { -- #1396
            [QuestieDB.itemKeys.name] = "Filled Vial Labeled #3",
            [QuestieDB.itemKeys.relatedQuests] = {3568},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {152605},
        },
        [10694] = { -- #1396
            [QuestieDB.itemKeys.name] = "Filled Vial Labeled #4",
            [QuestieDB.itemKeys.relatedQuests] = {3568},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {152606},
        },
        [9597] = { -- #1461
            [QuestieDB.itemKeys.name] = "Mountain Giant Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3127},
            [QuestieDB.itemKeys.npcDrops] = {5357,5358,14604,14640},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7867] = { -- #1469
            [QuestieDB.itemKeys.name] = "Vessel of Dragon's Blood",
            [QuestieDB.itemKeys.relatedQuests] = {2203,2501},
            [QuestieDB.itemKeys.npcDrops] = {2726},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [18956] = {
            [QuestieDB.itemKeys.npcDrops] = {5357,5358,5359,5360,5361,14603,14604,14638,14639,14640}, -- #1470
        },
        [3421] = { -- #1476
            [QuestieDB.itemKeys.name] = "Simple Wildflowers",
            [QuestieDB.itemKeys.relatedQuests] = {2609},
            [QuestieDB.itemKeys.npcDrops] = {1302,1303},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3372] = { -- #1476
            [QuestieDB.itemKeys.name] = "Leaded Vial",
            [QuestieDB.itemKeys.relatedQuests] = {2609},
            [QuestieDB.itemKeys.npcDrops] = {1286,1313,1326,1257,1325,5503,},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4371] = {
            [QuestieDB.itemKeys.npcDrops] = {3495,5519,5175,}, -- #1476
        },
        [4589] = {
            [QuestieDB.itemKeys.npcDrops] = {2347,2651,2657,2658,2659},
        },
        [4639] = {
            [QuestieDB.itemKeys.name] = "Enchanted Sea Kelp",
            [QuestieDB.itemKeys.relatedQuests] = {736},
            [QuestieDB.itemKeys.npcDrops] = {4363},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9306] = { -- #1487
            [QuestieDB.itemKeys.name] = "Stave of Equinex",
            [QuestieDB.itemKeys.relatedQuests] = {2879,2942},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {144063},
        },
        [5646] = { -- #1491
            [QuestieDB.itemKeys.name] = "Vial of Blessed Water",
            [QuestieDB.itemKeys.relatedQuests] = {4441},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {138498},
        },
        [6175] = {
            [QuestieDB.itemKeys.objectDrops] = {30854,30855,30856},
        },
        [8396] = {
            [QuestieDB.itemKeys.npcDrops] = {5982},
        },
        [11040] = {
            [QuestieDB.itemKeys.name] = "Morrowgrain",
            [QuestieDB.itemKeys.relatedQuests] = {3785,3786,3803,3792,3804,3791},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12236] = {
            [QuestieDB.itemKeys.name] = "Pure Un'Goro Sample",
            [QuestieDB.itemKeys.relatedQuests] = {4294},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16967] = {
            [QuestieDB.itemKeys.name] = "Feralas Ahi",
            [QuestieDB.itemKeys.relatedQuests] = {6607},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {400000},
        },
        [16970] = {
            [QuestieDB.itemKeys.name] = "Misty Reed Mahi Mahi",
            [QuestieDB.itemKeys.relatedQuests] = {6607},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {400001},
        },
        [16968] = {
            [QuestieDB.itemKeys.name] = "Sar'theris Striker",
            [QuestieDB.itemKeys.relatedQuests] = {6607},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {400002},
        },
        [16969] = {
            [QuestieDB.itemKeys.name] = "Savage Coast Blue Sailfin",
            [QuestieDB.itemKeys.relatedQuests] = {6607},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {400003},
        },

        -- quest related herbs
        [2449] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1619,3726},
        },
        [2447] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1618,3724},
        },
        [8846] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {142145,176637},
        },
        [3356] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1624},
        },
        [3357] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2041},
        },
        [8836] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {142141,176642},
        },
        [4625] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2866},
        },
        [3820] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2045},
        },
        [8831] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {142140,180165},
        },

        -- quest related leather
        [4304] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4234] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [2318] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [2319] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [8170] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },

        -- quest related mining stuff
        [11370] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {165658},
        },
        [1206] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [12364] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [1529] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [7910] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [3864] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },

        -- other quest related trade goods
        [2592] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [2997] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [4306] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [4338] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [2589] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [14047] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [14048] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
    }
end

-- some quest items are shared across factions but require different sources for each faction (not sure if there is a better way to implement this)
function QuestieItemFixes:LoadFactionFixes()
    local itemFixesHorde = {
        [15882] = {
            [QuestieDB.itemKeys.objectDrops] = {177790},
        },
        [15883] = {
            [QuestieDB.itemKeys.objectDrops] = {177794},
        },
        [3713] = {
            [QuestieDB.itemKeys.name] = "Soothing Spices",
            [QuestieDB.itemKeys.relatedQuests] = {7321,1218,},
            [QuestieDB.itemKeys.npcDrops] = {2397,8307},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
    }

    local itemFixesAlliance = {
        [15882] = {
            [QuestieDB.itemKeys.objectDrops] = {177844},
        },
        [15883] = {
            [QuestieDB.itemKeys.objectDrops] = {177792},
        },
        [3713] = {
            [QuestieDB.itemKeys.name] = "Soothing Spices",
            [QuestieDB.itemKeys.relatedQuests] = {555,1218,},
            [QuestieDB.itemKeys.npcDrops] = {2381,4897},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end

_AddMissingItemIDs = function()
    local missingItemIDs = {
        5475,
        11040,
        12567,
        12236,
        15843,
        15845,
        17124,
        8072,
        7675,
        7737,
        7208,
        12347,
        5051,
        12349,
        12350,
        5184,
        5185,
        5186,
        5639,
        5619,
        5645,
        5621,
        18151,
        18152,
        5188,
        14338,
        15209,
        14339,
        8584,
        8585,
        11149,
        6435,
        3388,
        3508,
        4904,
        5868,
        16642,
        16643,
        16644,
        16764,
        16763,
        16765,
        11131,
        5455,
        9440,
        9441,
        9438,
        8523,
        9330,
        11470,
        11522,
        9593,
        9595,
        9596,
        11954,
        12907,
        12922,
        7268,
        7269,
        11412,
        11413,
        12885,
        16974,
        16973,
        7134,
        7206,
        7207,
        9594,
        2894,
        12813,
        11947,
        11949,
        18746,
        10691,
        10692,
        10693,
        10694,
        9597,
        7867,
        3421,
        3372,
        4639,
        9306,
        5646,
        16967,
        16970,
        16968,
        16969,
        3713,
        14645,
    }

    for _, id in pairs(missingItemIDs) do
        tinsert(QuestieDB.itemData, id, {})
    end
end
