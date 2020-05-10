---@class QuestieItemFixes
local QuestieItemFixes = QuestieLoader:CreateModule("QuestieItemFixes")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

local tinsert = table.insert

function QuestieItemFixes:Load()

    return {
        [730] = {
            [QuestieDB.itemKeys.npcDrops] = {1418,127,2206,2207,517,2203,456,1958,2202,2205,1027,513,2208,2204,2201,126,515,458,1028,171,1767,1025,3739,1024,3737,1026,3742,3740,422,578,545,548,1083,544},
        },
        [1013] = {
            [QuestieDB.itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [1206] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [1262] = {
            [QuestieDB.itemKeys.name] = "Keg of Thunderbrew",
            [QuestieDB.itemKeys.relatedQuests] = {116,117},
            [QuestieDB.itemKeys.npcDrops] = {239},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [1524] = {
            [QuestieDB.itemKeys.npcDrops] = {667,669,670,672,696,780,781,782,783,784,1059,1061,1062},
        },
        [1529] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [1939] = {
            [QuestieDB.itemKeys.name] = "Skin of Sweet Rum",
            [QuestieDB.itemKeys.relatedQuests] = {116},
            [QuestieDB.itemKeys.npcDrops] = {465},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [1941] = {
            [QuestieDB.itemKeys.name] = "Cask of Merlot",
            [QuestieDB.itemKeys.relatedQuests] = {116},
            [QuestieDB.itemKeys.npcDrops] = {277},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [1942] = {
            [QuestieDB.itemKeys.name] = "Bottle of Moonshine",
            [QuestieDB.itemKeys.relatedQuests] = {116},
            [QuestieDB.itemKeys.npcDrops] = {274},
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
        [2447] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1618,3724},
        },
        [2449] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1619,3726},
        },
        [2589] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [2592] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [2594] = {
            [QuestieDB.itemKeys.name] = "Flagon of Dwarven Honeymead",
            [QuestieDB.itemKeys.npcDrops] = {1464},
        },
        [2837] = {
            [QuestieDB.itemKeys.name] = "Thurman's Letter",
            [QuestieDB.itemKeys.relatedQuests] = {361},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [2856] = {
            [QuestieDB.itemKeys.npcDrops] = {426,430,446,580}, -- Remove rare mob #903
        },
        [2886] = {
            [QuestieDB.itemKeys.npcDrops] = {1125,1126,1127,1689},
        },
        [2894] = { -- #1285
            [QuestieDB.itemKeys.name] = "Rhapsody Malt",
            [QuestieDB.itemKeys.relatedQuests] = {384},
            [QuestieDB.itemKeys.npcDrops] = {1247},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [2997] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [3016] = {
            [QuestieDB.itemKeys.name] = "Gunther's Spellbook",
            [QuestieDB.itemKeys.relatedQuests] = {405},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3017] = {
            [QuestieDB.itemKeys.name] = "Sevren's Orders",
            [QuestieDB.itemKeys.relatedQuests] = {405},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3081] = {
            [QuestieDB.itemKeys.name] = "Nether Gem",
            [QuestieDB.itemKeys.relatedQuests] = {405},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3035] = {
            [QuestieDB.itemKeys.name] = "Laced Pumpkin",
            [QuestieDB.itemKeys.relatedQuests] = {407},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3165] = {
            [QuestieDB.itemKeys.name] = "Quinn's Potion",
            [QuestieDB.itemKeys.relatedQuests] = {430},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3173] = {
            [QuestieDB.itemKeys.npcDrops] = {2163,2164,1188,1189,1186,2165,1797,1778},
        },
        [3238] = {
            [QuestieDB.itemKeys.name] = "Johaan's Findings",
            [QuestieDB.itemKeys.relatedQuests] = {407},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3340] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1610,1667},
        },
        [3356] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {1624},
        },
        [3357] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2041},
        },
        [3372] = { -- #1476
            [QuestieDB.itemKeys.name] = "Leaded Vial",
            [QuestieDB.itemKeys.relatedQuests] = {2609},
            [QuestieDB.itemKeys.npcDrops] = {1286,1313,1326,1257,1325,5503,},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3388] = {
            [QuestieDB.itemKeys.name] = "Strong Troll's Brool Potion",
            [QuestieDB.itemKeys.relatedQuests] = {515},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3421] = { -- #1476
            [QuestieDB.itemKeys.name] = "Simple Wildflowers",
            [QuestieDB.itemKeys.relatedQuests] = {2609},
            [QuestieDB.itemKeys.npcDrops] = {1302,1303},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3460] = {
            [QuestieDB.itemKeys.name] = "Johaan's Special Drink",
            [QuestieDB.itemKeys.relatedQuests] = {492},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3508] = {
            [QuestieDB.itemKeys.name] = "Mudsnout Mixture",
            [QuestieDB.itemKeys.relatedQuests] = {515},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3252] = {
            [QuestieDB.itemKeys.name] = "Deathstalker Report",
            [QuestieDB.itemKeys.relatedQuests] = {449},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [3820] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2045},
        },
        [3829] = {
            [QuestieDB.itemKeys.relatedQuests] = {713,1193},
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [3864] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [4098] = {
            [QuestieDB.itemKeys.name] = "Carefully Folded Note",
            [QuestieDB.itemKeys.relatedQuests] = {594},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2560},

        },
        [4234] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4304] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4306] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [4338] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [4371] = {
            [QuestieDB.itemKeys.npcDrops] = {3495,5519,5175,}, -- #1476
        },
        [4502] = {
            [QuestieDB.itemKeys.name] = "Sample Elven Gem",
            [QuestieDB.itemKeys.relatedQuests] = {669},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4589] = {
            [QuestieDB.itemKeys.npcDrops] = {2347,2651,2657,2658,2659},
        },
        [4611] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2744},
        },
        [4625] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2866},
        },
        [4639] = {
            [QuestieDB.itemKeys.name] = "Enchanted Sea Kelp",
            [QuestieDB.itemKeys.relatedQuests] = {736},
            [QuestieDB.itemKeys.npcDrops] = {4363},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4483] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2689},
        },
        [4494] = {
            [QuestieDB.itemKeys.name] = "Seahorn's Sealed Letter",
            [QuestieDB.itemKeys.relatedQuests] = {670},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [4806] = {
            [QuestieDB.itemKeys.npcDrops] = {2956,2957,3068},
        },
        [4843] = {
            [QuestieDB.itemKeys.name] = "Amethyst Runestone",
            [QuestieDB.itemKeys.relatedQuests] = {793,717},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2858},
        },
        [4844] = {
            [QuestieDB.itemKeys.name] = "Opal Runestone",
            [QuestieDB.itemKeys.relatedQuests] = {793,717},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2848},
	    },
        [4845] = {
            [QuestieDB.itemKeys.name] = "Diamond Runestone",
            [QuestieDB.itemKeys.relatedQuests] = {793,717},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {2842},
        },
        [4904] = {
            [QuestieDB.itemKeys.name] = "Venomtail Antidote",
            [QuestieDB.itemKeys.relatedQuests] = {812},
            [QuestieDB.itemKeys.npcDrops] = {3189},
            [QuestieDB.itemKeys.objectDrops] = {},
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
        [5068] = {
            [QuestieDB.itemKeys.name] = "Dried Seeds",
            [QuestieDB.itemKeys.relatedQuests] = {877},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5080] = {
            [QuestieDB.itemKeys.name] = "Gazlowe's Ledger",
            [QuestieDB.itemKeys.relatedQuests] = {890,892},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5088] = {
            [QuestieDB.itemKeys.name] = "Control Console Operating Manual",
            [QuestieDB.itemKeys.relatedQuests] = {894},
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
        [5188] = {
            [QuestieDB.itemKeys.name] = "Filled Vessel",
            [QuestieDB.itemKeys.relatedQuests] = {935},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5455] = {
            [QuestieDB.itemKeys.name] = "Divined Scroll",
            [QuestieDB.itemKeys.relatedQuests] = {1016},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
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
        [5619] = {
            [QuestieDB.itemKeys.name] = "Jade Phial",
            [QuestieDB.itemKeys.relatedQuests] = {929},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5621] = {
            [QuestieDB.itemKeys.name] = "Tourmaline Phial",
            [QuestieDB.itemKeys.relatedQuests] = {933},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5639] = {
            [QuestieDB.itemKeys.name] = "Filled Jade Phial",
            [QuestieDB.itemKeys.relatedQuests] = {929},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19550},
        },
        [5645] = {
            [QuestieDB.itemKeys.name] = "Filled Tourmaline Phial",
            [QuestieDB.itemKeys.relatedQuests] = {933},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {19551},
        },
        [5646] = { -- #1491
            [QuestieDB.itemKeys.name] = "Vial of Blessed Water",
            [QuestieDB.itemKeys.relatedQuests] = {4441},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {138498},
        },
        [5798] = {
            [QuestieDB.itemKeys.objectDrops] = {19868,19869,19870,19871,19872,19873},
        },
        [5804] = {
            [QuestieDB.itemKeys.name] = "Goblin Rumors",
            [QuestieDB.itemKeys.relatedQuests] = {1117},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [5868] = {
            [QuestieDB.itemKeys.name] = "Filled Etched Phial",
            [QuestieDB.itemKeys.relatedQuests] = {1195},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {20806},
        },
        [5942] = {
            [QuestieDB.itemKeys.npcDrops] = {4405,4401,4404,4402,4403,14236},
        },
        [6016] = {
            [QuestieDB.itemKeys.name] = "Wolf Heart Sample",
            [QuestieDB.itemKeys.relatedQuests] = {1429},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [6175] = {
            [QuestieDB.itemKeys.objectDrops] = {30854,30855,30856},
        },
        [6193] = {
            [QuestieDB.itemKeys.name] = "Bundle of Atal'ai Artifacts",
            [QuestieDB.itemKeys.relatedQuests] = {1429},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [6435] = {
            [QuestieDB.itemKeys.name] = "Infused Burning Gem",
            [QuestieDB.itemKeys.relatedQuests] = {1435},
            [QuestieDB.itemKeys.npcDrops] = {4663,4664,4665,4666,4667,4668,4705,13019},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [6462] = {
            [QuestieDB.itemKeys.name] = "Secure Crate",
            [QuestieDB.itemKeys.relatedQuests] = {1492},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7134] = { -- #1163
            [QuestieDB.itemKeys.name] = "Sturdy Dragonmaw Shinbone",
            [QuestieDB.itemKeys.relatedQuests] = {1846},
            [QuestieDB.itemKeys.npcDrops] = {1034,1035,1036,1038,1057,},
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
        [7208] = {
            [QuestieDB.itemKeys.name] = "Tazan's Key",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {6466},
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
        [7628] = {
            [QuestieDB.itemKeys.name] = "Nondescript Letter",
            [QuestieDB.itemKeys.relatedQuests] = {8},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
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
        [7769] = {
            [QuestieDB.itemKeys.name] = "Filled Brown Waterskin",
            [QuestieDB.itemKeys.relatedQuests] = {1535},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {107046},
        },
        [7770] = {
            [QuestieDB.itemKeys.name] = "Filled Blue Waterskin",
            [QuestieDB.itemKeys.relatedQuests] = {1534},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {107047},
        },
        [7771] = {
            [QuestieDB.itemKeys.name] = "Filled Red Waterskin",
            [QuestieDB.itemKeys.relatedQuests] = {1536},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {107045},
        },
        [7867] = { -- #1469
            [QuestieDB.itemKeys.name] = "Vessel of Dragon's Blood",
            [QuestieDB.itemKeys.relatedQuests] = {2203,2501},
            [QuestieDB.itemKeys.npcDrops] = {2726},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [7910] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [7923] = {
            [QuestieDB.itemKeys.npcDrops] = {7051},
        },
        [7972] = {
            [QuestieDB.itemKeys.npcDrops] = {1488,1489,1783,1784,1785,1787,1788,1789,1791,1793,1794,1795,1796,1802,1804,1805,3094,4472,4474,4475,6116,6117,7370,7523,7524,7864,8523,8524,8525,8526,8527,8528,8529,8530,8531,8532,8538,8539,8540,8541,8542,8543,8545,10500,10580,10816,11873,12262,12263,12377,12378,12379,12380},
        },
        [8072] = {
            [QuestieDB.itemKeys.name] = "Silixiz's Tower Key",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {7287},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [8170] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [8396] = {
            [QuestieDB.itemKeys.npcDrops] = {5982},
        },
        [8523] = {
            [QuestieDB.itemKeys.name] = "Field Testing Kit",
            [QuestieDB.itemKeys.relatedQuests] = {654},
            [QuestieDB.itemKeys.npcDrops] = {7683},
            [QuestieDB.itemKeys.objectDrops] = {},
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
        [8831] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {142140,180165},
        },
        [8836] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {142141,176642},
        },
        [8846] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {142145,176637},
        },
        [9254] = {
            [QuestieDB.itemKeys.name] = "Cuergo's Treasure Map",
            [QuestieDB.itemKeys.relatedQuests] = {2882},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9306] = { -- #1487
            [QuestieDB.itemKeys.name] = "Stave of Equinex",
            [QuestieDB.itemKeys.relatedQuests] = {2879,2942},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {144063},
        },
        [9330] = {
            [QuestieDB.itemKeys.name] = "Snapshot of Gammerita",
            [QuestieDB.itemKeys.relatedQuests] = {2944},
            [QuestieDB.itemKeys.npcDrops] = {7977},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9438] = {
            [QuestieDB.itemKeys.name] = "Acceptable Scorpid Sample",
            [QuestieDB.itemKeys.relatedQuests] = {654},
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
        [9574] = {
            [QuestieDB.itemKeys.name] = "Glyphic Scroll",
            [QuestieDB.itemKeys.relatedQuests] = {3098},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9593] = { -- #1184
            [QuestieDB.itemKeys.name] = "Treant Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3126},
            [QuestieDB.itemKeys.npcDrops] = {7584},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [9594] = { -- #1227
            [QuestieDB.itemKeys.name] = "Wildkin Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3123},
            [QuestieDB.itemKeys.npcDrops] = {2927,2928,2929,},
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
        [9597] = { -- #1461
            [QuestieDB.itemKeys.name] = "Mountain Giant Muisek",
            [QuestieDB.itemKeys.relatedQuests] = {3127},
            [QuestieDB.itemKeys.npcDrops] = {5357,5358,14604,14640},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [10283] = {
            [QuestieDB.itemKeys.name] = "Wolf Heart Samples",
            [QuestieDB.itemKeys.relatedQuests] = {1359},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [10327] = {
            [QuestieDB.itemKeys.name] = "Horn of Echeyakee",
            [QuestieDB.itemKeys.relatedQuests] = {881},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [10575] = {
            [QuestieDB.itemKeys.npcDrops] = {9461}, -- #1216
        },
        [10639] = {
            [QuestieDB.itemKeys.npcDrops] = {1988,1989},
            [QuestieDB.itemKeys.objectDrops] = {152094},
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
        [11018] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {157936},
        },
        [11040] = {
            [QuestieDB.itemKeys.name] = "Morrowgrain",
            [QuestieDB.itemKeys.relatedQuests] = {3785,3786,3803,3792,3804,3791},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [11113] = {
            [QuestieDB.itemKeys.objectDrops] = {161526},
        },
        [11114] = {
            [QuestieDB.itemKeys.objectDrops] = {161527},
        },
        [11131] = {
            [QuestieDB.itemKeys.name] = "Hive Wall Sample",
            [QuestieDB.itemKeys.relatedQuests] = {3883},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174793},
        },
        [11149] = {
            [QuestieDB.itemKeys.name] = "Samophlange Manual",
            [QuestieDB.itemKeys.relatedQuests] = {3924},
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
        [11370] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {165658},
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
        [11470] = {
            [QuestieDB.itemKeys.name] = "Tablet Transcript",
            [QuestieDB.itemKeys.relatedQuests] = {4296},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {169294},
        },
        [11522] = {
            [QuestieDB.itemKeys.name] = "Silver Totem of Aquementas",
            [QuestieDB.itemKeys.relatedQuests] = {4005},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {148507},
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
        [11954] = { -- #1070
            [QuestieDB.itemKeys.name] = "Filled Pure Sample Jar",
            [QuestieDB.itemKeys.relatedQuests] = {4513},
            [QuestieDB.itemKeys.npcDrops] = {6556,6557,6559,},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12236] = {
            [QuestieDB.itemKeys.name] = "Pure Un'Goro Sample",
            [QuestieDB.itemKeys.relatedQuests] = {4294},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12283] = {
            [QuestieDB.itemKeys.npcDrops] = {7047,7048,7049,},
        },
        [12324] = {
            [QuestieDB.itemKeys.npcDrops] = {10321}, -- #1175
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [12334] = {
            [QuestieDB.itemKeys.objectDrops] = {175324},
        },
        [12347] = {
            [QuestieDB.itemKeys.name] = "Filled Cleansing Bowl",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174795},
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
        [12364] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [12366] = {
            [QuestieDB.itemKeys.npcDrops] = {7457,7458},
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
        [12885] = { -- #1148
            [QuestieDB.itemKeys.name] = "Pamela's Doll",
            [QuestieDB.itemKeys.relatedQuests] = {5149},
            [QuestieDB.itemKeys.npcDrops] = {},
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
        [13546] = {
            [QuestieDB.itemKeys.name] = "Bloodbelly Fish",
            [QuestieDB.itemKeys.relatedQuests] = {5386},
            [QuestieDB.itemKeys.npcDrops] = {11317},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [14047] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [14048] = {
            [QuestieDB.itemKeys.npcDrops] = {},
        },
        [14338] = {
            [QuestieDB.itemKeys.name] = "Empty Water Tube",
            [QuestieDB.itemKeys.relatedQuests] = {4812},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [14339] = {
            [QuestieDB.itemKeys.name] = "Moonwell Water Tube",
            [QuestieDB.itemKeys.relatedQuests] = {4812},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {174795},
        },
        [14645] = {
            [QuestieDB.itemKeys.name] = "Unfinished Skeleton Key",
            [QuestieDB.itemKeys.relatedQuests] = {5801,5802},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {4004},
        },
        [15209] = {
            [QuestieDB.itemKeys.name] = "Relic Bundle",
            [QuestieDB.itemKeys.relatedQuests] = {5721},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
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
        [15874] = {
            [QuestieDB.itemKeys.objectDrops] = {177784},
        },
        [16209] = {
            [QuestieDB.itemKeys.name] = "Podrig's Order",
            [QuestieDB.itemKeys.relatedQuests] = {6321,6323},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16210] = {
            [QuestieDB.itemKeys.name] = "Gordon's Crate",
            [QuestieDB.itemKeys.relatedQuests] = {6321,6323},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
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
        [16763] = {
            [QuestieDB.itemKeys.name] = "Warsong Runner Update",
            [QuestieDB.itemKeys.relatedQuests] = {6543,6545},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16764] = {
            [QuestieDB.itemKeys.name] = "Warsong Scout Update",
            [QuestieDB.itemKeys.relatedQuests] = {6543,6547},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16765] = {
            [QuestieDB.itemKeys.name] = "Warsong Outrider Update",
            [QuestieDB.itemKeys.relatedQuests] = {6543,6546},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [16967] = {
            [QuestieDB.itemKeys.name] = "Feralas Ahi",
            [QuestieDB.itemKeys.relatedQuests] = {6607},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {400000},
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
        [16970] = {
            [QuestieDB.itemKeys.name] = "Misty Reed Mahi Mahi",
            [QuestieDB.itemKeys.relatedQuests] = {6607},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {400001},
        },
        [16973] = { -- #1156
            [QuestieDB.itemKeys.name] = "Vial of Dire Water",
            [QuestieDB.itemKeys.relatedQuests] = {5247},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {178224},
        },
        [16974] = { -- #1156
            [QuestieDB.itemKeys.name] = "Empty Water Vial",
            [QuestieDB.itemKeys.relatedQuests] = {5247},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [17124] = {
            [QuestieDB.itemKeys.name] = "Syndicate Emblem",
            [QuestieDB.itemKeys.relatedQuests] = {},
            [QuestieDB.itemKeys.npcDrops] = {2246,2590,2240,2586,2589,2587,2588,2242,2241,2319,2261,2244,2260},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [17309] = {
            [QuestieDB.itemKeys.npcDrops] = {8519,8520,8521,8522,},
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
        [18605] = {
            [QuestieDB.itemKeys.npcDrops] = {12396}, -- #7583
        },
        [18746] = { -- #1344
            [QuestieDB.itemKeys.name] = "Divination Scryer",
            [QuestieDB.itemKeys.relatedQuests] = {7666,7669,8258,},
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [18956] = {
            [QuestieDB.itemKeys.npcDrops] = {5357,5358,5359,5360,5361,14603,14604,14638,14639,14640}, -- #1470
        },
        [19061]= {
            [QuestieDB.itemKeys.name] = "Vessel of Rebirth",
            [QuestieDB.itemKeys.relatedQuests] = {7785,},
            [QuestieDB.itemKeys.npcDrops] = {14347},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [20023] = {
            [QuestieDB.itemKeys.npcDrops] = {8766},
        },
        [20378] = {
            [QuestieDB.itemKeys.npcDrops] = {},
            [QuestieDB.itemKeys.objectDrops] = {180436,180501},
        },
        [21557] = {
            [QuestieDB.itemKeys.name] = "Small Red Rocket",
            [QuestieDB.itemKeys.relatedQuests] = {8867,},
            [QuestieDB.itemKeys.npcDrops] = {15898},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [21558] = {
            [QuestieDB.itemKeys.name] = "Small Blue Rocket",
            [QuestieDB.itemKeys.relatedQuests] = {8867,},
            [QuestieDB.itemKeys.npcDrops] = {15898},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [21559] = {
            [QuestieDB.itemKeys.name] = "Small Green Rocket",
            [QuestieDB.itemKeys.relatedQuests] = {8867,},
            [QuestieDB.itemKeys.npcDrops] = {15898},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [21571] = {
            [QuestieDB.itemKeys.name] = "Blue Rocket Cluster",
            [QuestieDB.itemKeys.relatedQuests] = {8867,},
            [QuestieDB.itemKeys.npcDrops] = {15898},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [21574] = {
            [QuestieDB.itemKeys.name] = "Green Rocket Cluster",
            [QuestieDB.itemKeys.relatedQuests] = {8867,},
            [QuestieDB.itemKeys.npcDrops] = {15898},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [21576] = {
            [QuestieDB.itemKeys.name] = "Red Rocket Cluster",
            [QuestieDB.itemKeys.relatedQuests] = {8867,},
            [QuestieDB.itemKeys.npcDrops] = {15898},
            [QuestieDB.itemKeys.objectDrops] = {},
        },
        [22435] = {
            [QuestieDB.itemKeys.npcDrops] = {6551,6554}, -- #1771
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
