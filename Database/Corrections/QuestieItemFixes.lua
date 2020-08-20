---@class QuestieItemFixes
local QuestieItemFixes = QuestieLoader:CreateModule("QuestieItemFixes")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

function QuestieItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [730] = {
            [itemKeys.npcDrops] = {1418,127,2206,2207,517,2203,456,1958,2202,2205,1027,513,2208,2204,2201,126,515,458,1028,171,1767,1025,3739,1024,3737,1026,3742,3740,422,578,545,548,1083,544},
        },
        [1013] = {
            [itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [1206] = {
            [itemKeys.npcDrops] = {},
        },
        [1262] = {
            [itemKeys.name] = "Keg of Thunderbrew",
            [itemKeys.relatedQuests] = {116,117},
            [itemKeys.npcDrops] = {239},
            [itemKeys.objectDrops] = {},
        },
        [1524] = {
            [itemKeys.npcDrops] = {667,669,670,672,696,780,781,782,783,784,1059,1061,1062},
        },
        [1529] = {
            [itemKeys.npcDrops] = {},
        },
        [1939] = {
            [itemKeys.name] = "Skin of Sweet Rum",
            [itemKeys.relatedQuests] = {116},
            [itemKeys.npcDrops] = {465},
            [itemKeys.objectDrops] = {},
        },
        [1941] = {
            [itemKeys.name] = "Cask of Merlot",
            [itemKeys.relatedQuests] = {116},
            [itemKeys.npcDrops] = {277},
            [itemKeys.objectDrops] = {},
        },
        [1942] = {
            [itemKeys.name] = "Bottle of Moonshine",
            [itemKeys.relatedQuests] = {116},
            [itemKeys.npcDrops] = {274},
            [itemKeys.objectDrops] = {},
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
            [itemKeys.name] = "Flagon of Dwarven Honeymead",
            [itemKeys.npcDrops] = {1464},
        },
        [2676] = {
            [itemKeys.objectDrops] = {276,},
        },
        [2837] = {
            [itemKeys.name] = "Thurman's Letter",
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
            [itemKeys.name] = "Rhapsody Malt",
            [itemKeys.relatedQuests] = {384},
            [itemKeys.npcDrops] = {1247},
            [itemKeys.objectDrops] = {},
        },
        [2997] = {
            [itemKeys.npcDrops] = {},
        },
        [3016] = {
            [itemKeys.name] = "Gunther's Spellbook",
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3017] = {
            [itemKeys.name] = "Sevren's Orders",
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3080] = {
            [itemKeys.name] = "Candle of Beckoning",
            [itemKeys.relatedQuests] = {409,431,},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1586},
        },
        [3081] = {
            [itemKeys.name] = "Nether Gem",
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3035] = {
            [itemKeys.name] = "Laced Pumpkin",
            [itemKeys.relatedQuests] = {407},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3165] = {
            [itemKeys.name] = "Quinn's Potion",
            [itemKeys.relatedQuests] = {430},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3173] = {
            [itemKeys.npcDrops] = {2163,2164,1188,1189,1186,2165,1797,1778},
        },
        [3238] = {
            [itemKeys.name] = "Johaan's Findings",
            [itemKeys.relatedQuests] = {407},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3340] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1610,1667},
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
            [itemKeys.name] = "Leaded Vial",
            [itemKeys.relatedQuests] = {2609},
            [itemKeys.npcDrops] = {1286,1313,1326,1257,1325,5503,},
            [itemKeys.objectDrops] = {},
        },
        [3388] = {
            [itemKeys.name] = "Strong Troll's Brool Potion",
            [itemKeys.relatedQuests] = {515},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3421] = { -- #1476
            [itemKeys.name] = "Simple Wildflowers",
            [itemKeys.relatedQuests] = {2609},
            [itemKeys.npcDrops] = {1302,1303},
            [itemKeys.objectDrops] = {},
        },
        [3460] = {
            [itemKeys.name] = "Johaan's Special Drink",
            [itemKeys.relatedQuests] = {492},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3508] = {
            [itemKeys.name] = "Mudsnout Mixture",
            [itemKeys.relatedQuests] = {515},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3252] = {
            [itemKeys.name] = "Deathstalker Report",
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
        },
        [3864] = {
            [itemKeys.npcDrops] = {},
        },
        [3913] = {
            [itemKeys.name] = "Filled Soul Gem",
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
            [itemKeys.name] = "Carefully Folded Note",
            [itemKeys.relatedQuests] = {594},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2560},
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
            [itemKeys.npcDrops] = {3495,5519,5175,}, -- #1476
        },
        [4502] = {
            [itemKeys.name] = "Sample Elven Gem",
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
            [itemKeys.name] = "Enchanted Sea Kelp",
            [itemKeys.relatedQuests] = {736},
            [itemKeys.npcDrops] = {4363},
            [itemKeys.objectDrops] = {},
        },
        [4483] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2689},
        },
        [4494] = {
            [itemKeys.name] = "Seahorn's Sealed Letter",
            [itemKeys.relatedQuests] = {670},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4806] = {
            [itemKeys.npcDrops] = {2956,2957,3068},
        },
        [4843] = {
            [itemKeys.name] = "Amethyst Runestone",
            [itemKeys.relatedQuests] = {793,717},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2858},
        },
        [4844] = {
            [itemKeys.name] = "Opal Runestone",
            [itemKeys.relatedQuests] = {793,717},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2848},
        },
        [4845] = {
            [itemKeys.name] = "Diamond Runestone",
            [itemKeys.relatedQuests] = {793,717},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2842},
        },
        [4904] = {
            [itemKeys.name] = "Venomtail Antidote",
            [itemKeys.relatedQuests] = {812},
            [itemKeys.npcDrops] = {3189},
            [itemKeys.objectDrops] = {},
        },
        [4986] = {
            [itemKeys.name] = "Flawed Power Stone",
            [itemKeys.relatedQuests] = {924,926,},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {5621},
        },
        [5051] = {
            [itemKeys.name] = "Dig Rat",
            [itemKeys.relatedQuests] = {862},
            [itemKeys.npcDrops] = {3444},
            [itemKeys.objectDrops] = {},
        },
        [5056] = {
            [itemKeys.objectDrops] = {1619,3726,1618,3724,1620,3727},
        },
        [5068] = {
            [itemKeys.name] = "Dried Seeds",
            [itemKeys.relatedQuests] = {877},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5080] = {
            [itemKeys.name] = "Gazlowe's Ledger",
            [itemKeys.relatedQuests] = {890,892},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5088] = {
            [itemKeys.name] = "Control Console Operating Manual",
            [itemKeys.relatedQuests] = {894},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5184] = {
            [itemKeys.name] = "Filled Crystal Phial",
            [itemKeys.relatedQuests] = {921},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19549},
        },
        [5185] = {
            [itemKeys.name] = "Crystal Phial",
            [itemKeys.relatedQuests] = {921},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5186] = {
            [itemKeys.name] = "Partially Filled Vessel",
            [itemKeys.relatedQuests] = {928},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5188] = {
            [itemKeys.name] = "Filled Vessel",
            [itemKeys.relatedQuests] = {935},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5455] = {
            [itemKeys.name] = "Divined Scroll",
            [itemKeys.relatedQuests] = {1016},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5475] = {
            [itemKeys.name] = "Wooden Key",
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {3919,3834},
            [itemKeys.objectDrops] = {},
        },
        [5519] = {
            [itemKeys.npcDrops] = {3928},
            [itemKeys.objectDrops] = {},
        },
        [5619] = {
            [itemKeys.name] = "Jade Phial",
            [itemKeys.relatedQuests] = {929},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5621] = {
            [itemKeys.name] = "Tourmaline Phial",
            [itemKeys.relatedQuests] = {933},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5639] = {
            [itemKeys.name] = "Filled Jade Phial",
            [itemKeys.relatedQuests] = {929},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19550},
        },
        [5645] = {
            [itemKeys.name] = "Filled Tourmaline Phial",
            [itemKeys.relatedQuests] = {933},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19551},
        },
        [5646] = { -- #1491
            [itemKeys.name] = "Vial of Blessed Water",
            [itemKeys.relatedQuests] = {4441},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {138498},
        },
        [5798] = {
            [itemKeys.objectDrops] = {19868,19869,19870,19871,19872,19873},
        },
        [5804] = {
            [itemKeys.name] = "Goblin Rumors",
            [itemKeys.relatedQuests] = {1117},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5868] = {
            [itemKeys.name] = "Filled Etched Phial",
            [itemKeys.relatedQuests] = {1195},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {20806},
        },
        [5942] = {
            [itemKeys.npcDrops] = {4405,4401,4404,4402,4403,14236},
        },
        [6016] = {
            [itemKeys.name] = "Wolf Heart Sample",
            [itemKeys.relatedQuests] = {1429},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6175] = {
            [itemKeys.objectDrops] = {30854,30855,30856},
        },
        [6193] = {
            [itemKeys.name] = "Bundle of Atal'ai Artifacts",
            [itemKeys.relatedQuests] = {1429},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6435] = {
            [itemKeys.name] = "Infused Burning Gem",
            [itemKeys.relatedQuests] = {1435},
            [itemKeys.npcDrops] = {4663,4664,4665,4666,4667,4668,4705,13019},
            [itemKeys.objectDrops] = {},
        },
        [6462] = {
            [itemKeys.name] = "Secure Crate",
            [itemKeys.relatedQuests] = {1492},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7083] = {
            [itemKeys.name] = "Purified Kor Gem",
            [itemKeys.relatedQuests] = {1442,1654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7134] = { -- #1163
            [itemKeys.name] = "Sturdy Dragonmaw Shinbone",
            [itemKeys.relatedQuests] = {1846},
            [itemKeys.npcDrops] = {1034,1035,1036,1038,1057,},
            [itemKeys.objectDrops] = {},
        },
        [7206] = { -- #1286
            [itemKeys.name] = "Mirror Lake Water Sample",
            [itemKeys.relatedQuests] = {1860},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174794},
        },
        [7207] = { -- #1286
            [itemKeys.name] = "Jennea's Flask",
            [itemKeys.relatedQuests] = {1860},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7208] = {
            [itemKeys.name] = "Tazan's Key",
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {6466},
            [itemKeys.objectDrops] = {},
        },
        [7268] = { -- #1097
            [itemKeys.name] = "Xavian Water Sample",
            [itemKeys.relatedQuests] = {1944},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174797},
        },
        [7269] = { -- #1097
            [itemKeys.name] = "Deino's Flask",
            [itemKeys.relatedQuests] = {1944},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7628] = {
            [itemKeys.name] = "Nondescript Letter",
            [itemKeys.relatedQuests] = {8},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7675] = {
            [itemKeys.name] = "Defias Shipping Schedule",
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {6846},
            [itemKeys.objectDrops] = {},
        },
        [7737] = {
            [itemKeys.name] = "Sethir's Journal",
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {6909},
            [itemKeys.objectDrops] = {},
        },
        [7769] = {
            [itemKeys.name] = "Filled Brown Waterskin",
            [itemKeys.relatedQuests] = {1535},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107046},
        },
        [7770] = {
            [itemKeys.name] = "Filled Blue Waterskin",
            [itemKeys.relatedQuests] = {1534},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107047},
        },
        [7771] = {
            [itemKeys.name] = "Filled Red Waterskin",
            [itemKeys.relatedQuests] = {1536},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107045},
        },
        [7867] = { -- #1469
            [itemKeys.name] = "Vessel of Dragon's Blood",
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
            [itemKeys.name] = "Silixiz's Tower Key",
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
            [itemKeys.name] = "Field Testing Kit",
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {7683},
            [itemKeys.objectDrops] = {},
        },
        [8584] = {
            [itemKeys.name] = "Untapped Dowsing Widget",
            [itemKeys.relatedQuests] = {992},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [8585] = {
            [itemKeys.name] = "Tapped Dowsing Widget",
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
            [itemKeys.objectDrops] = {142141,176642},
        },
        [8846] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {142145,176637},
        },
        [9254] = {
            [itemKeys.name] = "Cuergo's Treasure Map",
            [itemKeys.relatedQuests] = {2882},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9306] = { -- #1487
            [itemKeys.name] = "Stave of Equinex",
            [itemKeys.relatedQuests] = {2879,2942},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {144063},
        },
        [9330] = {
            [itemKeys.name] = "Snapshot of Gammerita",
            [itemKeys.relatedQuests] = {2944},
            [itemKeys.npcDrops] = {7977},
            [itemKeys.objectDrops] = {},
        },
        [9438] = {
            [itemKeys.name] = "Acceptable Scorpid Sample",
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9440] = {
            [itemKeys.name] = "Acceptable Basilisk Sample",
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9441] = {
            [itemKeys.name] = "Acceptable Hyena Sample",
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9574] = {
            [itemKeys.name] = "Glyphic Scroll",
            [itemKeys.relatedQuests] = {3098},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9593] = { -- #1184
            [itemKeys.name] = "Treant Muisek",
            [itemKeys.relatedQuests] = {3126},
            [itemKeys.npcDrops] = {7584},
            [itemKeys.objectDrops] = {},
        },
        [9594] = { -- #1227
            [itemKeys.name] = "Wildkin Muisek",
            [itemKeys.relatedQuests] = {3123},
            [itemKeys.npcDrops] = {2927,2928,2929,},
            [itemKeys.objectDrops] = {},
        },
        [9595] = {
            [itemKeys.name] = "Hippogryph Muisek",
            [itemKeys.relatedQuests] = {3124},
            [itemKeys.npcDrops] = {5300,5304,5305,5306},
            [itemKeys.objectDrops] = {},
        },
        [9596] = { -- #1184
            [itemKeys.name] = "Faerie Dragon Muisek",
            [itemKeys.relatedQuests] = {3125},
            [itemKeys.npcDrops] = {5276,5278},
            [itemKeys.objectDrops] = {},
        },
        [9597] = { -- #1461
            [itemKeys.name] = "Mountain Giant Muisek",
            [itemKeys.relatedQuests] = {3127},
            [itemKeys.npcDrops] = {5357,5358,14604,14640},
            [itemKeys.objectDrops] = {},
        },
        [10283] = {
            [itemKeys.name] = "Wolf Heart Samples",
            [itemKeys.relatedQuests] = {1359},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [10327] = {
            [itemKeys.name] = "Horn of Echeyakee",
            [itemKeys.relatedQuests] = {881},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [10575] = {
            [itemKeys.npcDrops] = {9461}, -- #1216
        },
        [10639] = {
            [itemKeys.npcDrops] = {1988,1989},
            [itemKeys.objectDrops] = {152094},
        },
        [10691] = { -- #1396
            [itemKeys.name] = "Filled Vial Labeled #1",
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152598},
        },
        [10692] = { -- #1396
            [itemKeys.name] = "Filled Vial Labeled #2",
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152604},
        },
        [10693] = { -- #1396
            [itemKeys.name] = "Filled Vial Labeled #3",
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152605},
        },
        [10694] = { -- #1396
            [itemKeys.name] = "Filled Vial Labeled #4",
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152606},
        },
        [11018] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {157936},
        },
        [11040] = {
            [itemKeys.name] = "Morrowgrain",
            [itemKeys.relatedQuests] = {3785,3786,3803,3792,3804,3791},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11113] = {
            [itemKeys.objectDrops] = {161526},
        },
        [11114] = {
            [itemKeys.objectDrops] = {161527},
        },
        [11131] = {
            [itemKeys.name] = "Hive Wall Sample",
            [itemKeys.relatedQuests] = {3883},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174793},
        },
        [11149] = {
            [itemKeys.name] = "Samophlange Manual",
            [itemKeys.relatedQuests] = {3924},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11184] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {164658,164778},
        },
        [11185] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {164659,164779},
        },
        [11186] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {164660,164780},
        },
        [11188] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {164661,164781},
        },
        [11370] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {165658},
        },
        [11412] = { -- #1136
            [itemKeys.name] = "Nagmara's Vial",
            [itemKeys.relatedQuests] = {4201},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11413] = { -- #1136
            [itemKeys.name] = "Nagmara's Filled Vial",
            [itemKeys.relatedQuests] = {4201},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {165678},
        },
        [11470] = {
            [itemKeys.name] = "Tablet Transcript",
            [itemKeys.relatedQuests] = {4296},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {169294},
        },
        [11522] = {
            [itemKeys.name] = "Silver Totem of Aquementas",
            [itemKeys.relatedQuests] = {4005},
            [itemKeys.npcDrops] = {9453},
            [itemKeys.objectDrops] = {},
        },
        [11947] = { -- #1315
            [itemKeys.name] = "Filled Cursed Ooze Jar",
            [itemKeys.relatedQuests] = {4512},
            [itemKeys.npcDrops] = {7086},
            [itemKeys.objectDrops] = {},
        },
        [11949] = { -- #1315
            [itemKeys.name] = "Filled Tainted Ooze Jar",
            [itemKeys.relatedQuests] = {4512},
            [itemKeys.npcDrops] = {7092},
            [itemKeys.objectDrops] = {},
        },
        [11954] = { -- #1070
            [itemKeys.name] = "Filled Pure Sample Jar",
            [itemKeys.relatedQuests] = {4513},
            [itemKeys.npcDrops] = {6556,6557,6559,},
            [itemKeys.objectDrops] = {},
        },
        [12234] = {
            [itemKeys.name] = "Corrupted Felwood Sample",
            [itemKeys.relatedQuests] = {4293},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174848},
        },
        [12236] = {
            [itemKeys.name] = "Pure Un'Goro Sample",
            [itemKeys.relatedQuests] = {4294},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {175265},
        },
        [12283] = {
            [itemKeys.npcDrops] = {7047,7048,7049,},
        },
        [12291] = {
            [itemKeys.npcDrops] = {6557,9621,},
        },
        [12324] = {
            [itemKeys.npcDrops] = {10321}, -- #1175
            [itemKeys.objectDrops] = {},
        },
        [12334] = {
            [itemKeys.objectDrops] = {175324},
        },
        [12347] = {
            [itemKeys.name] = "Filled Cleansing Bowl",
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174795},
        },
        [12349] = {
            [itemKeys.name] = "Cliffspring River Sample",
            [itemKeys.relatedQuests] = {4762},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {175371},
        },
        [12350] = {
            [itemKeys.name] = "Empty Sampling Tube",
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
            [itemKeys.name] = "Dawn's Gambit",
            [itemKeys.relatedQuests] = {4771},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12567] = {
            [itemKeys.name] = "Filled Flasket",
            [itemKeys.relatedQuests] = {4505},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {148501},
        },
        [12733] = { 
            [itemKeys.name] = "Sacred Frostsaber Meat",
            [itemKeys.relatedQuests] = {5056},
            [itemKeys.npcDrops] = {7434,7433,7430,7432,7431,},
            [itemKeys.objectDrops] = {},
        },
        [12813] = { -- #1313
            [itemKeys.name] = "Flask of Mystery Goo",
            [itemKeys.relatedQuests] = {5085},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12885] = { -- #1148
            [itemKeys.name] = "Pamela's Doll",
            [itemKeys.relatedQuests] = {5149},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12907] = { -- #1083
            [itemKeys.name] = "Corrupted Moonwell Water",
            [itemKeys.relatedQuests] = {5157},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {176184},
        },
        [12922] = { -- #1083
            [itemKeys.name] = "Empty Canteen",
            [itemKeys.relatedQuests] = {5157},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [13546] = {
            [itemKeys.name] = "Bloodbelly Fish",
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
            [itemKeys.name] = "Empty Water Tube",
            [itemKeys.relatedQuests] = {4812},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [14339] = {
            [itemKeys.name] = "Moonwell Water Tube",
            [itemKeys.relatedQuests] = {4812},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174795},
        },
        [14645] = {
            [itemKeys.name] = "Unfinished Skeleton Key",
            [itemKeys.relatedQuests] = {5801,5802},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {4004},
        },
        [15209] = {
            [itemKeys.name] = "Relic Bundle",
            [itemKeys.relatedQuests] = {5721},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [15843] = {
            [itemKeys.name] = "Filled Dreadmist Peak Sampler",
            [itemKeys.relatedQuests] = {6127},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19464},
        },
        [15845] = {
            [itemKeys.name] = "Filled Cliffspring Falls Sampler",
            [itemKeys.relatedQuests] = {6122},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19463},
        },
        [15874] = {
            [itemKeys.objectDrops] = {177784},
        },
        [16209] = {
            [itemKeys.name] = "Podrig's Order",
            [itemKeys.relatedQuests] = {6321,6323},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16210] = {
            [itemKeys.name] = "Gordon's Crate",
            [itemKeys.relatedQuests] = {6321,6323},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16642] = {
            [itemKeys.name] = "Shredder Operating Manual - Chapter 1",
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16643] = {
            [itemKeys.name] = "Shredder Operating Manual - Chapter 2",
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16644] = {
            [itemKeys.name] = "Shredder Operating Manual - Chapter 3",
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16763] = {
            [itemKeys.name] = "Warsong Runner Update",
            [itemKeys.relatedQuests] = {6543,6545},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16764] = {
            [itemKeys.name] = "Warsong Scout Update",
            [itemKeys.relatedQuests] = {6543,6547},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16765] = {
            [itemKeys.name] = "Warsong Outrider Update",
            [itemKeys.relatedQuests] = {6543,6546},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16967] = {
            [itemKeys.name] = "Feralas Ahi",
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400000},
        },
        [16968] = {
            [itemKeys.name] = "Sar'theris Striker",
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400002},
        },
        [16969] = {
            [itemKeys.name] = "Savage Coast Blue Sailfin",
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400003},
        },
        [16970] = {
            [itemKeys.name] = "Misty Reed Mahi Mahi",
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400001},
        },
        [16973] = { -- #1156
            [itemKeys.name] = "Vial of Dire Water",
            [itemKeys.relatedQuests] = {5247},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {178224},
        },
        [16974] = { -- #1156
            [itemKeys.name] = "Empty Water Vial",
            [itemKeys.relatedQuests] = {5247},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [17124] = {
            [itemKeys.name] = "Syndicate Emblem",
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {2246,2590,2240,2586,2589,2587,2588,2242,2241,2319,2261,2244,2260},
            [itemKeys.objectDrops] = {},
        },
        [17309] = {
            [itemKeys.npcDrops] = {8519,8520,8521,8522,},
        },
        [17696] = {
            [itemKeys.name] = "Filled Cerulean Vial",
            [itemKeys.relatedQuests] = {7029,7041},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {178907},
        },
        [18151] = {
            [itemKeys.name] = "Filled Amethyst Phial",
            [itemKeys.relatedQuests] = {7383},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19552},
        },
        [18152] = {
            [itemKeys.name] = "Amethyst Phial",
            [itemKeys.relatedQuests] = {7383},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [18605] = {
            [itemKeys.npcDrops] = {12396}, -- #7583
        },
        [18746] = { -- #1344
            [itemKeys.name] = "Divination Scryer",
            [itemKeys.relatedQuests] = {7666,7669,8258,},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [18956] = {
            [itemKeys.npcDrops] = {5357,5358,5359,5360,5361,14603,14604,14638,14639,14640}, -- #1470
        },
        [19034] = {
            [itemKeys.objectDrops] = {179910},
        },
        [19061]= {
            [itemKeys.name] = "Vessel of Rebirth",
            [itemKeys.relatedQuests] = {7785,},
            [itemKeys.npcDrops] = {14347},
            [itemKeys.objectDrops] = {},
        },
        [20023] = {
            [itemKeys.npcDrops] = {8766},
        },
        [20378] = {
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {180436,180501},
        },
        [20454] = { 
            [itemKeys.name] = "Hive'Zora Rubbing",
            [itemKeys.relatedQuests] = {8309,},
            [itemKeys.objectDrops] = {180455,},
            [itemKeys.npcDrops] = {},
        },
        [20455] = { 
            [itemKeys.name] = "Hive'Ashi Rubbing",
            [itemKeys.relatedQuests] = {8309,},
            [itemKeys.objectDrops] = {180454,},
            [itemKeys.npcDrops] = {},
        },
        [20456] = { 
            [itemKeys.name] = "Hive'Regal Rubbing",
            [itemKeys.relatedQuests] = {8309,},
            [itemKeys.objectDrops] = {180453,},
            [itemKeys.npcDrops] = {},
        },
        [21158] = {
            [itemKeys.name] = "Hive'Zora Scout Report",
            [itemKeys.relatedQuests] = {8534},
            [itemKeys.npcDrops] = {15610},
            [itemKeys.objectDrops] = {},
        },
        [21160] = {
            [itemKeys.name] = "Hive'Regal Scout Report",
            [itemKeys.relatedQuests] = {8738},
            [itemKeys.npcDrops] = {15609},
            [itemKeys.objectDrops] = {},
        },
        [21161] = {
            [itemKeys.name] = "Hive'Ashi Scout Report",
            [itemKeys.relatedQuests] = {8739},
            [itemKeys.npcDrops] = {15611},
            [itemKeys.objectDrops] = {},
        },
        [21557] = {
            [itemKeys.name] = "Small Red Rocket",
            [itemKeys.relatedQuests] = {8867,},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21558] = {
            [itemKeys.name] = "Small Blue Rocket",
            [itemKeys.relatedQuests] = {8867,},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21559] = {
            [itemKeys.name] = "Small Green Rocket",
            [itemKeys.relatedQuests] = {8867,},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21571] = {
            [itemKeys.name] = "Blue Rocket Cluster",
            [itemKeys.relatedQuests] = {8867,},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21574] = {
            [itemKeys.name] = "Green Rocket Cluster",
            [itemKeys.relatedQuests] = {8867,},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21576] = {
            [itemKeys.name] = "Red Rocket Cluster",
            [itemKeys.relatedQuests] = {8867,},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [22435] = {
            [itemKeys.npcDrops] = {6551,6554}, -- #1771
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
            [itemKeys.name] = "Soothing Spices",
            [itemKeys.relatedQuests] = {7321,1218,},
            [itemKeys.npcDrops] = {2397,8307},
            [itemKeys.objectDrops] = {},
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
            [itemKeys.relatedQuests] = {555,1218,},
            [itemKeys.npcDrops] = {2381,4897},
            [itemKeys.objectDrops] = {},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end
