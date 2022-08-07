---@class QuestieItemFixes
local QuestieItemFixes = QuestieLoader:CreateModule("QuestieItemFixes")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

-- Further information on how to use this can be found at the wiki
-- https://github.com/Questie/Questie/wiki/Corrections

function QuestieItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [730] = {
            [itemKeys.npcDrops] = {1418,127,2206,2207,517,2203,456,1958,2202,2205,1027,513,2208,2204,2201,126,515,458,1028,171,1767,1025,3739,1024,3737,1026,3742,3740,422,578,545,548,1083,544},
        },
        [929] = {
            [itemKeys.vendors] = {1307,1453,1457,2481,2805,3134,3534,3956,4878,8305,13476,4083},
            [itemKeys.relatedQuests] = {715},
        },
        [1013] = {
            [itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [1206] = {
            [itemKeys.npcDrops] = {},
        },
        [1262] = {
            [itemKeys.relatedQuests] = {116,117},
            [itemKeys.npcDrops] = {239},
        },
        [1524] = {
            [itemKeys.npcDrops] = {667,669,670,672,696,780,781,782,783,784,1059,1061,1062},
        },
        [1529] = {
            [itemKeys.npcDrops] = {},
        },
        [1939] = {
            [itemKeys.relatedQuests] = {116},
        },
        [1941] = {
            [itemKeys.relatedQuests] = {116},
        },
        [1942] = {
            [itemKeys.relatedQuests] = {116},
        },
        [2318] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [2319] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [2447] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1618,3724},
        },
        [2449] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1619,3726},
        },
        [2589] = {
            [itemKeys.npcDrops] = {},
        },
        [2592] = {
            [itemKeys.npcDrops] = {},
        },
        [2594] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.vendors] = {12794,2832,12785,5140,5611,277,1301,258,5570,1311,5111,1305,1328,5848,955,1697,465,1464,5112},
            [itemKeys.relatedQuests] = {288},
        },
        [2633] = {
            [itemKeys.npcDrops] = {940,941,942}, -- #2433
        },
        [2665] = {
            [itemKeys.relatedQuests] = {90},
        },
        [2686] = {
            [itemKeys.relatedQuests] = {308},
            [itemKeys.npcDrops] = {1247,1682,7744},
        },
        [2837] = {
            [itemKeys.relatedQuests] = {361},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [2856] = {
            [itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [2886] = {
            [itemKeys.npcDrops] = {1125,1126,1127,1689},
        },
        [2894] = { -- #1285
            [itemKeys.relatedQuests] = {384},
            [itemKeys.npcDrops] = {1247,1682,7744},
            [itemKeys.objectDrops] = {},
        },
        [2997] = {
            [itemKeys.npcDrops] = {},
        },
        [3016] = {
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3017] = {
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3080] = {
            [itemKeys.relatedQuests] = {409,431},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1586},
        },
        [3081] = {
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3035] = {
            [itemKeys.relatedQuests] = {407},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3165] = {
            [itemKeys.relatedQuests] = {430},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3173] = {
            [itemKeys.npcDrops] = {2163,2164,1188,1189,1186,2165,1797,1778},
        },
        [3238] = {
            [itemKeys.relatedQuests] = {407},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3340] = {
            [itemKeys.npcDrops] = {},
        },
        [3356] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1624},
        },
        [3357] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2041},
        },
        [3372] = { -- #1476
            [itemKeys.relatedQuests] = {2609},
            [itemKeys.npcDrops] = {1286,1313,1326,1257,1325,5503},
            [itemKeys.objectDrops] = {},
        },
        [3388] = {
            [itemKeys.relatedQuests] = {515},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3421] = { -- #1476
            [itemKeys.relatedQuests] = {2609},
            [itemKeys.npcDrops] = {1302,1303},
            [itemKeys.objectDrops] = {},
        },
        [3460] = {
            [itemKeys.relatedQuests] = {492},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3508] = {
            [itemKeys.relatedQuests] = {515},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3252] = {
            [itemKeys.relatedQuests] = {449},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3820] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2045},
        },
        [3829] = {
            [itemKeys.relatedQuests] = {713,1193},
            [itemKeys.npcDrops] = {},
            [itemKeys.itemDrops] = {11887},
        },
        [3823] = {
            [itemKeys.relatedQuests] = {715},
        },
        [3864] = {
            [itemKeys.npcDrops] = {},
        },
        [3913] = {
            [itemKeys.relatedQuests] = {592,593},
            [itemKeys.npcDrops] = {2530},
            [itemKeys.objectDrops] = {},
        },
        [3917] = {
            [itemKeys.npcDrops] = {674,675,676,677},
        },
        [4016] = {
            [itemKeys.npcDrops] = {1488,1489,1490,1491,2530,2534,2535,2536,2537},
        },
        [4098] = {
            [itemKeys.relatedQuests] = {594},
        },
        [4234] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4304] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4306] = {
            [itemKeys.npcDrops] = {},
        },
        [4338] = {
            [itemKeys.npcDrops] = {},
        },
        [4371] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.vendors] = {1448,6777,2685,11185,14637,5519,5175,3413,3133,3495,8679,1694,2687,4587,8678,6730,9544,2682,2683,2684,2688,9676},
            [itemKeys.relatedQuests] = {174,2609},
        },
        [4389] = {
            [itemKeys.npcDrops] = {}, -- Kept empty to not confuse users doing quest #714
            [itemKeys.itemDrops] = {6357},
            [itemKeys.vendors] = {5175,2687,8679,5519,9544,3495,2684,4587,8678,6777,3133,1694,6730,2682,2685,3413,1448,2683,11185,14637},
            [itemKeys.relatedQuests] = {714},
        },
        [4502] = {
            [itemKeys.relatedQuests] = {669},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4589] = {
            [itemKeys.npcDrops] = {2347,2651,2657,2658,2659},
        },
        [4611] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2744},
        },
        [4625] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2866},
        },
        [4639] = {
            [itemKeys.relatedQuests] = {736},
            [itemKeys.npcDrops] = {4363},
            [itemKeys.objectDrops] = {},
        },
        [4483] = {
            [itemKeys.npcDrops] = {},
        },
        [4494] = {
            [itemKeys.relatedQuests] = {670},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4806] = {
            [itemKeys.npcDrops] = {2956,2957,3068},
        },
        [4843] = {
            [itemKeys.relatedQuests] = {793,717},
            [itemKeys.npcDrops] = {},
        },
        [4844] = {
            [itemKeys.relatedQuests] = {793,717},
            [itemKeys.npcDrops] = {},
        },
        [4845] = {
            [itemKeys.relatedQuests] = {793,717},
            [itemKeys.npcDrops] = {},
        },
        [4904] = {
            [itemKeys.relatedQuests] = {812},
            [itemKeys.npcDrops] = {3189},
            [itemKeys.objectDrops] = {},
        },
        [4986] = {
            [itemKeys.relatedQuests] = {924,926},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {5621},
        },
        [5051] = {
            [itemKeys.relatedQuests] = {862},
        },
        [5056] = {
            [itemKeys.objectDrops] = {1619,3726,1618,3724,1620,3727},
        },
        [5058] = {
            [itemKeys.npcDrops] = {},
        },
        [5068] = {
            [itemKeys.relatedQuests] = {877},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5080] = {
            [itemKeys.relatedQuests] = {890,892},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5088] = {
            [itemKeys.relatedQuests] = {894},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5179] = {
            [itemKeys.npcDrops] = {3535},
        },
        [5184] = {
            [itemKeys.relatedQuests] = {921},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19549},
        },
        [5185] = {
            [itemKeys.relatedQuests] = {921},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5186] = {
            [itemKeys.relatedQuests] = {928},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5188] = {
            [itemKeys.relatedQuests] = {935},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5445] = {
            [itemKeys.npcDrops] = {3943,10559},
            [itemKeys.relatedQuests] = {1009},
        },
        [5455] = {
            [itemKeys.relatedQuests] = {1016},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5475] = {
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {3919,3834},
            [itemKeys.objectDrops] = {},
        },
        [5519] = {
            [itemKeys.npcDrops] = {3928},
            [itemKeys.objectDrops] = {},
        },
        [5619] = {
            [itemKeys.relatedQuests] = {929},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5621] = {
            [itemKeys.relatedQuests] = {933},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5639] = {
            [itemKeys.relatedQuests] = {929},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19550},
        },
        [5645] = {
            [itemKeys.relatedQuests] = {933},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19551},
        },
        [5646] = { -- #1491
            [itemKeys.relatedQuests] = {4441},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {138498},
        },
        [5797] = {
            [itemKeys.npcDrops] = {6733,2894,2893,2892},
        },
        [5804] = {
            [itemKeys.relatedQuests] = {1117},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5847] = {
            [itemKeys.npcDrops] = {4363,4362,4360,4358,4361,4359},
        },
        [5868] = {
            [itemKeys.relatedQuests] = {1195},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {20806},
        },
        [5942] = {
            [itemKeys.npcDrops] = {4405,4401,4404,4402,4403,14236},
        },
        [5959] = {
            [itemKeys.npcDrops] = {4411,4412,4413,4414,4415},
        },
        [6016] = {
            [itemKeys.relatedQuests] = {1429},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6193] = {
            [itemKeys.relatedQuests] = {1429},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6358] = {
            [itemKeys.objectDrops] = {},
        },
        [6359] = {
            [itemKeys.objectDrops] = {},
        },
        [6435] = {
            [itemKeys.relatedQuests] = {1435},
            [itemKeys.npcDrops] = {4663,4664,4665,4666,4667,4668,4705,13019},
            [itemKeys.objectDrops] = {},
        },
        [6462] = {
            [itemKeys.relatedQuests] = {1492},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6522] = {
            [itemKeys.objectDrops] = {},
        },
        [6912] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {93192},
            [itemKeys.relatedQuests] = {1738},
        },
        [6992] = {
            [itemKeys.npcDrops] = {},
        },
        [7070] = {
            [itemKeys.objectDrops] = {},
        },
        [7079] = {
            [itemKeys.objectDrops] = {},
        },
        [7080] = {
            [itemKeys.objectDrops] = {},
        },
        [7083] = {
            [itemKeys.relatedQuests] = {1442,1654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7134] = { -- #1163
            [itemKeys.relatedQuests] = {1846},
            [itemKeys.npcDrops] = {1034,1035,1036,1038,1057},
            [itemKeys.objectDrops] = {},
        },
        [7206] = { -- #1286
            [itemKeys.relatedQuests] = {1860},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174794},
        },
        [7207] = { -- #1286
            [itemKeys.relatedQuests] = {1860},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7208] = {
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {6466},
            [itemKeys.objectDrops] = {},
        },
        [7268] = { -- #1097
            [itemKeys.relatedQuests] = {1944},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174797},
        },
        [7269] = { -- #1097
            [itemKeys.relatedQuests] = {1944},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7628] = {
            [itemKeys.relatedQuests] = {8},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7675] = {
            [itemKeys.relatedQuests] = {2206},
        },
        [7737] = {
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {6909},
            [itemKeys.objectDrops] = {},
        },
        [7769] = {
            [itemKeys.relatedQuests] = {1535},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107046},
        },
        [7770] = {
            [itemKeys.relatedQuests] = {1534},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107047},
        },
        [7771] = {
            [itemKeys.relatedQuests] = {1536},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107045},
        },
        [7867] = { -- #1469
            [itemKeys.relatedQuests] = {2203,2501},
            [itemKeys.npcDrops] = {2726},
            [itemKeys.objectDrops] = {},
        },
        [7910] = {
            [itemKeys.npcDrops] = {},
        },
        [7923] = {
            [itemKeys.npcDrops] = {7051},
        },
        [7972] = {
            [itemKeys.npcDrops] = {1488,1489,1783,1784,1785,1787,1788,1789,1791,1793,1794,1795,1796,1802,1804,1805,3094,4472,4474,4475,6116,6117,7370,7523,7524,7864,8523,8524,8525,8526,8527,8528,8529,8530,8531,8532,8538,8539,8540,8541,8542,8543,8545,10500,10580,10816,11873,12262,12263,12377,12378,12379,12380},
        },
        [8072] = {
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {7287},
            [itemKeys.objectDrops] = {},
        },
        [8170] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [8396] = {
            [itemKeys.npcDrops] = {5982},
        },
        [8523] = {
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {7683},
            [itemKeys.objectDrops] = {},
        },
        [8584] = {
            [itemKeys.relatedQuests] = {992},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [8585] = {
            [itemKeys.relatedQuests] = {992},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {144052},
        },
        [8831] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {142140,180165},
        },
        [8836] = {
            [itemKeys.npcDrops] = {},
        },
        [8846] = {
            [itemKeys.npcDrops] = {},
        },
        [9254] = {
            [itemKeys.relatedQuests] = {2882},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9306] = { -- #1487
            [itemKeys.relatedQuests] = {2879,2942},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {144063},
        },
        [9330] = {
            [itemKeys.relatedQuests] = {2944},
            [itemKeys.npcDrops] = {7977},
            [itemKeys.objectDrops] = {},
        },
        [9438] = {
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9440] = {
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9441] = {
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9574] = {
            [itemKeys.relatedQuests] = {3098},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9593] = { -- #1184
            [itemKeys.relatedQuests] = {3126},
            [itemKeys.npcDrops] = {7584},
            [itemKeys.objectDrops] = {},
        },
        [9594] = { -- #1227
            [itemKeys.relatedQuests] = {3123},
            [itemKeys.npcDrops] = {2927,2928,2929},
            [itemKeys.objectDrops] = {},
        },
        [9595] = {
            [itemKeys.relatedQuests] = {3124},
            [itemKeys.npcDrops] = {5300,5304,5305,5306},
            [itemKeys.objectDrops] = {},
        },
        [9596] = { -- #1184
            [itemKeys.relatedQuests] = {3125},
            [itemKeys.npcDrops] = {5276,5278},
            [itemKeys.objectDrops] = {},
        },
        [9597] = { -- #1461
            [itemKeys.relatedQuests] = {3127},
            [itemKeys.npcDrops] = {5357,5358,14604,14640},
            [itemKeys.objectDrops] = {},
        },
        [10283] = {
            [itemKeys.relatedQuests] = {1359},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [10327] = {
            [itemKeys.relatedQuests] = {881},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [10575] = {
            [itemKeys.npcDrops] = {9461}, -- #1216
        },
        [10639] = {
            [itemKeys.npcDrops] = {1988,1989},
        },
        [10691] = { -- #1396
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152598},
        },
        [10692] = { -- #1396
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152604},
        },
        [10693] = { -- #1396
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152605},
        },
        [10694] = { -- #1396
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152606},
        },
        [11018] = {
            [itemKeys.npcDrops] = {},
        },
        [11040] = {
            [itemKeys.relatedQuests] = {3785,3786,3803,3792,3804,3791},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11113] = {
            [itemKeys.objectDrops] = {161526},
        },
        [11129] = {
            [itemKeys.npcDrops] = {8908,8906,8905,8909,8910,8911,8923,9017,9025,9026,9156,},
        },
        [11131] = {
            [itemKeys.relatedQuests] = {3883},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174793},
        },
        [11149] = {
            [itemKeys.relatedQuests] = {3924},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11184] = {
            [itemKeys.npcDrops] = {},
        },
        [11185] = {
            [itemKeys.npcDrops] = {},
        },
        [11186] = {
            [itemKeys.npcDrops] = {},
        },
        [11188] = {
            [itemKeys.npcDrops] = {},
        },
        [11243] = {
            [itemKeys.npcDrops] = {7775},
        },
        [11370] = {
            [itemKeys.npcDrops] = {},
        },
        [11412] = { -- #1136
            [itemKeys.relatedQuests] = {4201},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11413] = { -- #1136
            [itemKeys.relatedQuests] = {4201},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {165678},
        },
        [11470] = {
            [itemKeys.relatedQuests] = {4296},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {169294},
        },
        [11522] = {
            [itemKeys.relatedQuests] = {4005},
            [itemKeys.npcDrops] = {9453},
            [itemKeys.objectDrops] = {},
        },
        [11947] = { -- #1315
            [itemKeys.relatedQuests] = {4512},
            [itemKeys.npcDrops] = {7086},
            [itemKeys.objectDrops] = {},
        },
        [11949] = { -- #1315
            [itemKeys.relatedQuests] = {4512},
            [itemKeys.npcDrops] = {7092},
            [itemKeys.objectDrops] = {},
        },
        [11954] = { -- #1070
            [itemKeys.relatedQuests] = {4513},
            [itemKeys.npcDrops] = {6556,6557,6559},
            [itemKeys.objectDrops] = {},
        },
        [12234] = {
            [itemKeys.relatedQuests] = {4293},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174848},
        },
        [12236] = {
            [itemKeys.relatedQuests] = {4294},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {175265},
        },
        [12283] = {
            [itemKeys.npcDrops] = {7047,7048,7049},
        },
        [12291] = {
            [itemKeys.npcDrops] = {6557,9621},
        },
        [12324] = {
            [itemKeys.npcDrops] = {10321}, -- #1175
            [itemKeys.objectDrops] = {},
        },
        [12347] = {
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174795},
        },
        [12349] = {
            [itemKeys.relatedQuests] = {4762},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {175371},
        },
        [12350] = {
            [itemKeys.relatedQuests] = {4762},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12364] = {
            [itemKeys.npcDrops] = {},
        },
        [12366] = {
            [itemKeys.npcDrops] = {7457,7458},
        },
        [12368] = {
            [itemKeys.relatedQuests] = {4771},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12562] = {
            [itemKeys.npcDrops] = {},
        },
        [12567] = {
            [itemKeys.relatedQuests] = {4505},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {148501},
        },
        [12648] = {
            [itemKeys.relatedQuests] = {4962},
            [itemKeys.npcDrops] = {4678},
            [itemKeys.objectDrops] = {},
        },
        [12649] = {
            [itemKeys.relatedQuests] = {4963},
            [itemKeys.npcDrops] = {4676},
            [itemKeys.objectDrops] = {},
        },
        [12733] = {
            [itemKeys.relatedQuests] = {5056},
            [itemKeys.npcDrops] = {7434,7433,7430,7432,7431},
            [itemKeys.objectDrops] = {},
        },
        [12765] = {
            [itemKeys.objectDrops] = {176344},
        },
        [12766] = {
            [itemKeys.objectDrops] = {190483},
        },
        [12768] = {
            [itemKeys.objectDrops] = {190484},
        },
        [12813] = { -- #1313
            [itemKeys.relatedQuests] = {5085},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12885] = { -- #1148
            [itemKeys.relatedQuests] = {5149},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12907] = { -- #1083
            [itemKeys.relatedQuests] = {5157},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {176184},
        },
        [12922] = { -- #1083
            [itemKeys.relatedQuests] = {5157},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [13422] = {
            [itemKeys.objectDrops] = {},
        },
        [13546] = {
            [itemKeys.relatedQuests] = {5386},
            [itemKeys.npcDrops] = {11317},
            [itemKeys.objectDrops] = {},
        },
        [14047] = {
            [itemKeys.npcDrops] = {},
        },
        [14048] = {
            [itemKeys.npcDrops] = {},
        },
        [14338] = {
            [itemKeys.relatedQuests] = {4812},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [14339] = {
            [itemKeys.relatedQuests] = {4812},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174795},
        },
        [14645] = {
            [itemKeys.relatedQuests] = {5801,5802},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {4004},
        },
        [15209] = {
            [itemKeys.relatedQuests] = {5721},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [15843] = {
            [itemKeys.relatedQuests] = {6127},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19464},
        },
        [15845] = {
            [itemKeys.relatedQuests] = {6122},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19463},
        },
        [15874] = {
            [itemKeys.npcDrops] = {12347},
        },
        [15924] = {
            [itemKeys.objectDrops] = {177784},
            [itemKeys.npcDrops] = {12347},
        },
        [16209] = {
            [itemKeys.relatedQuests] = {6321,6323},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16210] = {
            [itemKeys.relatedQuests] = {6321,6323},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16642] = {
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16643] = {
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16644] = {
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16763] = {
            [itemKeys.relatedQuests] = {6543,6545},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16764] = {
            [itemKeys.relatedQuests] = {6543,6547},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16765] = {
            [itemKeys.relatedQuests] = {6543,6546},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16882] = {
            [itemKeys.itemDrops] = {},
        },
        [16883] = {
            [itemKeys.itemDrops] = {},
        },
        [16884] = {
            [itemKeys.itemDrops] = {},
        },
        [16967] = {
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {500000},
        },
        [16968] = {
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {500002},
        },
        [16969] = {
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {500003},
        },
        [16970] = {
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {500001},
        },
        [16973] = { -- #1156
            [itemKeys.relatedQuests] = {5247},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {178224},
        },
        [16974] = { -- #1156
            [itemKeys.relatedQuests] = {5247},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [17124] = {
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {2246,2590,2240,2586,2589,2587,2588,2242,2241,2319,2261,2244,2260},
            [itemKeys.objectDrops] = {},
        },
        [17309] = {
            [itemKeys.npcDrops] = {8519,8520,8521,8522},
        },
        [17696] = {
            [itemKeys.relatedQuests] = {7029,7041},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {178907},
        },
        [18151] = {
            [itemKeys.relatedQuests] = {7383},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19552},
        },
        [18152] = {
            [itemKeys.relatedQuests] = {7383},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [18605] = {
            [itemKeys.npcDrops] = {12396}, -- #7583
        },
        [18642] = {
            [itemKeys.npcDrops] = {4968},
        },
        [18643] = {
            [itemKeys.npcDrops] = {3057},
        },
        [18746] = { -- #1344
            [itemKeys.relatedQuests] = {7666,7669,8258},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [18947] = {
            [itemKeys.npcDrops] = {5296,5297,5299}, -- #2321
        },
        [18952] = {
            [itemKeys.npcDrops] = {14527,14533},
        },
        [18953] = {
            [itemKeys.npcDrops] = {14534,14529},
        },
        [18954] = {
            [itemKeys.npcDrops] = {14536,14530},
        },
        [18955] = {
            [itemKeys.npcDrops] = {14531,14535},
        },
        [18956] = {
            [itemKeys.npcDrops] = {5357,5358,5359,5360,5361,14603,14604,14638,14639,14640}, -- #1470
        },
        [19034] = {
            [itemKeys.objectDrops] = {179910},
        },
        [19016] = {
            [itemKeys.relatedQuests] = {7785},
            [itemKeys.npcDrops] = {14347},
            [itemKeys.objectDrops] = {},
        },
        [19803] = {
            [itemKeys.objectDrops] = {},
        },
        [19805] = {
            [itemKeys.objectDrops] = {},
        },
        [19806] = {
            [itemKeys.objectDrops] = {},
        },
        [19807] = {
            [itemKeys.objectDrops] = {},
        },
        [19808] = {
            [itemKeys.objectDrops] = {},
        },
        [19850] = {
            [itemKeys.objectDrops] = {180204},
        },
        [19851] = {
            [itemKeys.objectDrops] = {180205},
        },
        [19975] = {
            [itemKeys.objectDrops] = {},
        },
        [20023] = {
            [itemKeys.npcDrops] = {8766},
        },
        [20378] = {
            [itemKeys.npcDrops] = {},
        },
        [20454] = { 
            [itemKeys.relatedQuests] = {8309},
            [itemKeys.objectDrops] = {180455},
            [itemKeys.npcDrops] = {},
        },
        [20455] = { 
            [itemKeys.relatedQuests] = {8309},
            [itemKeys.objectDrops] = {180454},
            [itemKeys.npcDrops] = {},
        },
        [20456] = { 
            [itemKeys.relatedQuests] = {8309},
            [itemKeys.objectDrops] = {180453},
            [itemKeys.npcDrops] = {},
        },
        [20708] = {
            [itemKeys.objectDrops] = {},
        },
        [20709] = {
            [itemKeys.objectDrops] = {},
        },
        [21071] = {
            [itemKeys.objectDrops] = {},
        },
        [21106] = {
            [itemKeys.objectDrops] = {180666},
        },
        [21107] = {
            [itemKeys.objectDrops] = {180665},
        },
        [21109] = {
            [itemKeys.objectDrops] = {180667},
        },
        [21113] = {
            [itemKeys.objectDrops] = {},
        },
        [21114] = {
            [itemKeys.objectDrops] = {},
        },
        [21150] = {
            [itemKeys.objectDrops] = {},
        },
        [21151] = {
            [itemKeys.objectDrops] = {},
        },
        [21153] = {
            [itemKeys.objectDrops] = {},
        },
        [21158] = {
            [itemKeys.relatedQuests] = {8534},
            [itemKeys.npcDrops] = {15610},
            [itemKeys.objectDrops] = {},
        },
        [21160] = {
            [itemKeys.relatedQuests] = {8738},
            [itemKeys.npcDrops] = {15609},
            [itemKeys.objectDrops] = {},
        },
        [21161] = {
            [itemKeys.relatedQuests] = {8739},
            [itemKeys.npcDrops] = {15611},
            [itemKeys.objectDrops] = {},
        },
        [21228] = {
            [itemKeys.objectDrops] = {},
        },
        [21557] = {
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21558] = {
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21559] = {
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21571] = {
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21574] = {
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21576] = {
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [22094] = {
            [itemKeys.npcDrops] = {4364,4366,4368,4370,4371,16072},
        },
        [22229] = {
            [itemKeys.npcDrops] = {7068,7069,7071,7072,7075}, -- #2344
        },
        [22435] = {
            [itemKeys.npcDrops] = {6551,6554}, -- #1771
        },
        [22527] = {
            [itemKeys.npcDrops] = {6520,6521,7031,7032,7132,8519,8520,8521,8522,8909,8910,8911,9017,9025,9026,9816,9878,9879,11480,11483,11484,11744,11745,11746,11747,13279,13280,14399,14400,14455,14458,14460,14462},
        },
        [190179] = {
            [itemKeys.name] = "Avelina's Heart",
            [itemKeys.npcDrops] = {185333},
            [itemKeys.relatedQuests] = {65593},
        },
        [190180] = {
            [itemKeys.name] = "Isaac's Heart",
            [itemKeys.npcDrops] = {185334},
            [itemKeys.relatedQuests] = {65593},
        },
        [190181] = {
            [itemKeys.name] = "Lovers' Hearts",
            [itemKeys.relatedQuests] = {65597},
        },
        [190186] = {
            [itemKeys.name] = "Wooden Figurine",
            [itemKeys.relatedQuests] = {65603},
        },
        [190187] = {
            [itemKeys.name] = "Withered Scarf",
            [itemKeys.relatedQuests] = {65604},
        },
        [190232] = {
            [itemKeys.name] = "Withered Scarf",
            [itemKeys.npcDrops] = {3782,3784},
            [itemKeys.relatedQuests] = {65610},
        },
        [190309] = {
            [itemKeys.name] = "Wooden Figurine",
            [itemKeys.objectDrops] = {400013},
            [itemKeys.relatedQuests] = {65602},
        },
    }
end

-- some quest items are shared across factions but require different sources for each faction (not sure if there is a better way to implement this)
function QuestieItemFixes:LoadFactionFixes()
    local itemKeys = QuestieDB.itemKeys

    local itemFixesHorde = {
        [15882] = {
            [itemKeys.objectDrops] = {177790},
        },
        [15883] = {
            [itemKeys.objectDrops] = {177794},
        },
        [3713] = {
            [itemKeys.relatedQuests] = {7321,1218},
            [itemKeys.npcDrops] = {2397,8307},
            [itemKeys.objectDrops] = {},
        },
        -- TBC
        [25911] = {
            [itemKeys.objectDrops] = {182936},
        },
        [25912] = {
            [itemKeys.objectDrops] = {182937,182938},
        },
    }

    local itemFixesAlliance = {
        [15882] = {
            [itemKeys.objectDrops] = {177844},
        },
        [15883] = {
            [itemKeys.objectDrops] = {177792},
        },
        [3713] = {
            [itemKeys.name] = "Soothing Spices",
            [itemKeys.relatedQuests] = {555,1218},
            [itemKeys.npcDrops] = {2381,4897},
            [itemKeys.objectDrops] = {},
        },
        -- TBC
        [25911] = {
            [itemKeys.objectDrops] = {182799},
        },
        [25912] = {
            [itemKeys.objectDrops] = {182798,182797},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end
