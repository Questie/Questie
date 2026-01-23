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
    local itemClasses = QuestieDB.itemClasses

    return {
        [730] = { -- Murloc Eye
            [itemKeys.npcDrops] = {1259, 1418, 127, 2206, 2207, 517, 2203, 456, 1958, 2202, 2205, 1027, 513, 2208, 2204, 2201, 126, 515, 458, 1028, 171, 1767, 1025, 3739, 1024, 3737, 1026, 3742, 3740, 422, 578, 545, 548, 1083, 544},
        },
        [769] = { -- Chunk of Boar Meat
            [itemKeys.npcDrops] = {113, 119, 157, 330, 390, 454, 524, 547, 1125, 1126, 1127, 1190, 1191, 1192, 1689, 1985, 3098, 3099, 3100, 3225},
        },
        [858] = { -- Lesser Healing Potion
            [itemKeys.vendors] = {844, 958, 1257, 1453, 2140, 2380, 2480, 2481, 2812, 3548, 3658, 3956, 4226, 5178, 8157, 8177, 8178, 14847},
        },
        [910] = { -- An Undelivered Letter
            [itemKeys.objectDrops] = {1560},
        },
        [929] = { -- Healing Potion
            [itemKeys.vendors] = {1307, 1453, 1457, 2481, 2805, 3134, 3534, 3956, 4083, 4878, 8305, 13476},
            [itemKeys.relatedQuests] = {715},
        },
        [1013] = { -- Iron Rivet
            [itemKeys.npcDrops] = {426, 430, 446, 580}, -- Remove rare mob #903
        },
        [1206] = { -- Moss Agate
            [itemKeys.npcDrops] = {},
        },
        [1262] = { -- Keg of Thunderbrew
            [itemKeys.relatedQuests] = {116, 117},
            [itemKeys.vendors] = {239},
            [itemKeys.class] = 12,
            [itemKeys.name] = "Keg of Thunderbrew",
        },
        [1357] = { -- Captain Sander's Treasure Map
            [itemKeys.npcDrops] = {126, 127, 171, 391, 456, 458, 513, 515, 517},
        },
        [1524] = { -- Skullsplitter Tusk
            [itemKeys.npcDrops] = {667, 669, 670, 672, 696, 780, 781, 782, 783, 784, 1059, 1061, 1062},
        },
        [1529] = { -- Jade
            [itemKeys.npcDrops] = {},
        },
        [1708] = { -- Sweet Nectar
            [itemKeys.vendors] = {258, 274, 295, 465, 734, 955, 982, 1149, 1237, 1247, 1285, 1328, 1464, 1697, 2084, 2303, 2352, 2364, 2366, 2388, 2401, 2803, 2806, 2808, 2820, 2832, 2908, 3086, 3298, 3313, 3350, 3411, 3541, 3546, 3577, 3621, 3625, 3689, 3708, 3881, 3882, 3883, 3884, 3934, 3937, 3959, 3961, 4167, 4169, 4170, 4181, 4190, 4191, 4192, 4195, 4241, 4255, 4266, 4554, 4555, 4571, 4782, 4875, 4879, 4893, 4896, 4963, 4981, 5101, 5111, 5112, 5134, 5140, 5611, 5620, 5688, 5814, 5871, 6091, 6272, 6495, 6727, 6734, 6735, 6736, 6737, 6738, 6739, 6740, 6741, 6746, 6747, 6790, 6791, 6807, 6928, 6929, 6930, 7485, 7714, 7731, 7733, 7736, 7737, 7744, 7941, 7942, 7943, 8125, 8137, 8139, 8143, 8150, 8152, 8362, 8931, 9356, 9501, 10367, 11038, 11103, 11106, 11116, 11118, 11187, 11287, 11555, 12019, 12021, 12026, 12027, 12196, 12246, 12794, 12959, 12960, 14371, 14624, 14731, 14963, 14964, 15124, 15125, 15174, 16256, 16458},
        },
        [1939] = { -- Skin of Sweet Rum
            [itemKeys.relatedQuests] = {116},
        },
        [1941] = { -- Cask of Merlot
            [itemKeys.relatedQuests] = {116},
        },
        [1942] = { -- Bottle of Moonshine
            [itemKeys.relatedQuests] = {116},
        },
        [2318] = { -- Light Leather
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [2319] = { -- Medium Leather
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [2447] = { -- Peacebloom
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1618, 3724},
        },
        [2449] = { -- Earthroot
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1619, 3726},
        },
        [2589] = { -- Linen Cloth
            [itemKeys.npcDrops] = {},
        },
        [2592] = { -- Wool Cloth
            [itemKeys.npcDrops] = {},
        },
        [2594] = { -- Flagon of Dwarven Honeymead
            [itemKeys.npcDrops] = {},
            [itemKeys.vendors] = {12794, 2832, 12785, 5140, 5611, 277, 1301, 258, 5570, 1311, 5111, 1305, 1328, 5848, 955, 1697, 465, 1464, 5112},
            [itemKeys.relatedQuests] = {288},
        },
        [2633] = { -- Jungle Remedy
            [itemKeys.npcDrops] = {940, 941, 942}, -- #2433
        },
        [2686] = { -- Thunder Ale
            [itemKeys.relatedQuests] = {308},
            [itemKeys.npcDrops] = {1247, 1682, 7744},
        },
        [2798] = { --Rethban Ore
            [itemKeys.objectDrops] = {2054, 2055},
        },
        [2837] = { -- Thurman's Letter
            [itemKeys.relatedQuests] = {361},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [2856] = { -- Iron Pike
            [itemKeys.npcDrops] = {426, 430, 446, 580}, -- Remove rare mob #903
        },
        [2859] = { -- Vile Fin Scale
            [itemKeys.npcDrops] = {1543, 1544, 1545},
        },
        [2886] = { -- Crag Boar Rib
            [itemKeys.npcDrops] = {1125, 1126, 1127, 1689},
        },
        [2894] = { -- Rhapsody Malt (#1285)
            [itemKeys.relatedQuests] = {384},
            [itemKeys.npcDrops] = {1247, 1682, 7744},
            [itemKeys.objectDrops] = {},
        },
        [2997] = { -- Bolt of Woolen Cloth
            [itemKeys.npcDrops] = {},
        },
        [3016] = { -- Gunther's Spellbook
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3017] = { -- Sevren's Orders
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3080] = { -- Candle of Beckoning
            [itemKeys.relatedQuests] = {409, 431},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1586},
        },
        [3081] = { -- Nether Gem
            [itemKeys.relatedQuests] = {405},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3035] = { -- Laced Pumpkin
            [itemKeys.relatedQuests] = {407},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3165] = { -- Quinn's Potion
            [itemKeys.relatedQuests] = {430},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3173] = { -- Bear Meat
            [itemKeys.npcDrops] = {2163, 2164, 1188, 1189, 1186, 2165, 1797, 1778},
        },
        [3238] = { -- Johaan's Findings
            [itemKeys.relatedQuests] = {407},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3317] = { -- A Talking Head
            [itemKeys.npcDrops] = {1939, 1940, 1942, 1943},
        },
        [3340] = { -- Incendicite Ore
            [itemKeys.npcDrops] = {},
        },
        [3356] = { -- Kingsblood
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {1624},
        },
        [3357] = { -- Liferoot
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2041},
        },
        [3372] = { -- Leaded Vial (#1476)
            [itemKeys.relatedQuests] = {2609},
            [itemKeys.npcDrops] = {1286, 1313, 1326, 1257, 1325, 5503},
            [itemKeys.objectDrops] = {},
        },
        [3388] = { -- Strong Troll's Blood Potion
            [itemKeys.relatedQuests] = {515},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3421] = { -- Simple Wildflowers (#1476)
            [itemKeys.relatedQuests] = {2609},
            [itemKeys.npcDrops] = {1302, 1303},
            [itemKeys.objectDrops] = {},
        },
        [3460] = { -- Johaan's Special Drink
            [itemKeys.relatedQuests] = {492},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3508] = { -- Mudsnout Mixture
            [itemKeys.relatedQuests] = {515},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3252] = { -- Deathstalker Report
            [itemKeys.relatedQuests] = {449},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [3692] = { -- Hillsbrad Human Skull
            [itemKeys.npcDrops] = {232, 2244, 2260, 2261, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2305, 2335, 2360, 2387, 2403, 2404, 2427, 2428, 2448, 2449, 2450, 2451, 2503},
        },
        [3820] = { -- Stranglekelp
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2045},
        },
        [3823] = { -- Lesser Invisibility Potion
            [itemKeys.relatedQuests] = {715},
        },
        [3829] = { -- Frost Oil
            [itemKeys.relatedQuests] = {713, 1193},
            [itemKeys.npcDrops] = {},
            [itemKeys.itemDrops] = {11887},
        },
        [3864] = { -- Citrine
            [itemKeys.npcDrops] = {},
        },
        [3898] = { -- Library Scrip
            [itemKeys.class] = 15,
        },
        [3913] = { -- Filled Soul Gem
            [itemKeys.relatedQuests] = {592, 593},
            [itemKeys.npcDrops] = {2530},
            [itemKeys.objectDrops] = {},
        },
        [3917] = { -- Singing Blue Crystal
            [itemKeys.npcDrops] = {674, 675, 676, 677},
        },
        [4016] = { -- Zanzil's Mixture
            [itemKeys.npcDrops] = {1488, 1489, 1490, 1491, 2530, 2534, 2535, 2536, 2537},
        },
        [4098] = { -- Carefully Folded Note
            [itemKeys.relatedQuests] = {594},
        },
        [4234] = { -- Heavy Leather
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4304] = { -- Thick Leather
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4306] = { -- Silk Cloth
            [itemKeys.npcDrops] = {},
        },
        [4338] = { -- Mageweave Cloth
            [itemKeys.npcDrops] = {},
        },
        [4371] = { -- Bronze Tube
            [itemKeys.npcDrops] = {},
            [itemKeys.vendors] = {1448, 6777, 2685, 11185, 14637, 5519, 5175, 3413, 3133, 3495, 8679, 1694, 2687, 4587, 8678, 6730, 9544, 2682, 2683, 2684, 2688, 9676},
            [itemKeys.relatedQuests] = {174, 2609},
        },
        [4389] = { -- Gyrochronatom
            [itemKeys.npcDrops] = {}, -- Kept empty to not confuse users doing quest #714
            [itemKeys.itemDrops] = {6357},
            [itemKeys.vendors] = {5175, 2687, 8679, 5519, 9544, 3495, 2684, 4587, 8678, 6777, 3133, 1694, 6730, 2682, 2685, 3413, 1448, 2683, 11185, 14637},
            [itemKeys.relatedQuests] = {714},
        },
        [4502] = { -- Sample Elven Gem
            [itemKeys.relatedQuests] = {669},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4589] = { -- Long Elegant Feather
            [itemKeys.npcDrops] = {2347, 2651, 2657, 2658, 2659},
        },
        [4611] = { -- Blue Pearl
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2744},
        },
        [4625] = { -- Firebloom
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {2866},
        },
        [4639] = { -- Enchanted Sea Kelp
            [itemKeys.relatedQuests] = {735, 736},
            [itemKeys.npcDrops] = {4363},
            [itemKeys.objectDrops] = {},
        },
        [4483] = { -- Burning Key
            [itemKeys.npcDrops] = {},
        },
        [4494] = { -- Seahorn's Sealed Letter
            [itemKeys.relatedQuests] = {670},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [4531] = { -- Trelane's Orb
            [itemKeys.objectDrops] = {2716},
        },
        [4532] = { -- Trelane's Ember Agate
            [itemKeys.objectDrops] = {2718},
        },
        [4806] = { -- Plainstrider Scale
            [itemKeys.npcDrops] = {2956, 2957, 3068},
        },
        [4843] = { -- Amethyst Runestone
            [itemKeys.relatedQuests] = {793, 717},
            [itemKeys.npcDrops] = {},
        },
        [4844] = { -- Opal Runestone
            [itemKeys.relatedQuests] = {793, 717},
            [itemKeys.npcDrops] = {},
        },
        [4845] = { -- Diamond Runestone
            [itemKeys.relatedQuests] = {793, 717},
            [itemKeys.npcDrops] = {},
        },
        [4854] = { -- Demon Scarred Cloak
            [itemKeys.npcDrops] = {3056},
        },
        [4904] = { -- Venomtail Antidote
            [itemKeys.relatedQuests] = {812},
            [itemKeys.npcDrops] = {3189},
            [itemKeys.objectDrops] = {},
        },
        [4986] = { -- Flawed Power Stone
            [itemKeys.relatedQuests] = {924, 926},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {5621},
        },
        [5051] = { -- Dig Rat
            [itemKeys.relatedQuests] = {862},
        },
        [5056] = { -- Root Sample
            [itemKeys.objectDrops] = {3724, 3725, 3726, 3727, 3729, 3730}, -- only drops from these and we can remove from blacklist
        },
        [5058] = { -- Silithid Egg
            [itemKeys.npcDrops] = {},
        },
        [5068] = { -- Dried Seeds
            [itemKeys.relatedQuests] = {877},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5080] = { -- Gazlowe's Ledger
            [itemKeys.relatedQuests] = {890, 892},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5086] = { -- Zhevra Hooves
            [itemKeys.npcDrops] = {3242, 3426, 3466},
        },
        [5088] = { -- Control Console Operating Manual
            [itemKeys.relatedQuests] = {894},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5179] = { -- Moss-twined Heart
            [itemKeys.npcDrops] = {3535},
        },
        [5184] = { -- Filled Crystal Phial
            [itemKeys.relatedQuests] = {921},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19549},
        },
        [5185] = { -- Crystal Phial
            [itemKeys.relatedQuests] = {921},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5186] = { -- Partially Filled Vessel
            [itemKeys.relatedQuests] = {928},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5188] = { -- Filled Vessel
            [itemKeys.relatedQuests] = {935},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5251] = { -- Phial of Scrying
            [itemKeys.questRewards] = {960, 961},
        },
        [5359] = { -- Lorgalis Manuscript
            [itemKeys.objectDrops] = {13949}
        },
        [5411] = { -- Winterhoof Cleansing Totem
            [itemKeys.class] = itemClasses.QUEST,
        },
        [5445] = { -- Ring of Zoram
            [itemKeys.npcDrops] = {3943},
            [itemKeys.relatedQuests] = {1009},
        },
        [5455] = { -- Divined Scroll
            [itemKeys.relatedQuests] = {1016},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5461] = { -- Branch of Cenarius
            [itemKeys.npcDrops] = {4619},
        },
        [5475] = { -- Wooden Key
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {3919, 3834},
            [itemKeys.objectDrops] = {},
        },
        [5519] = { -- Iron Pommel
            [itemKeys.npcDrops] = {3928},
            [itemKeys.objectDrops] = {},
        },
        [5535] = { -- Compendium of the Fallen
            [itemKeys.objectDrops] = {19283},
        },
        [5619] = { -- Jade Phial
            [itemKeys.relatedQuests] = {929},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5621] = { -- Tourmaline Phial
            [itemKeys.relatedQuests] = {933},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5639] = { -- Filled Jade Phial
            [itemKeys.relatedQuests] = {929},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19550},
        },
        [5645] = { -- Filled Tourmaline Phial
            [itemKeys.relatedQuests] = {933},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19551},
        },
        [5646] = { -- Vial of Blessed Water (#1491)
            [itemKeys.relatedQuests] = {4441},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {138498},
        },
        [5797] = { -- Indurium Flake
            [itemKeys.npcDrops] = {6733, 2894, 2893, 2892},
        },
        [5804] = { -- Goblin Rumors
            [itemKeys.relatedQuests] = {1117},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [5847] = { -- Mirefin Head
            [itemKeys.npcDrops] = {4363, 4362, 4360, 4358, 4361, 4359},
        },
        [5868] = { -- Filled Etched Phial
            [itemKeys.relatedQuests] = {1195},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {20806},
        },
        [5877] = { -- Cracked Silithid Carapace
            [itemKeys.npcDrops] = {4130, 4131, 4133},
        },
        [5880] = { -- Crate With Holes
            [itemKeys.class] = 12,
        },
        [5942] = { -- Jeweled Pendant
            [itemKeys.npcDrops] = {4405, 4401, 4404, 4402, 4403, 14236},
        },
        [5959] = { -- Acidic Venom Sac
            [itemKeys.npcDrops] = {4411, 4412, 4413, 4414, 4415},
        },
        [6016] = { -- Wolf Heart Sample
            [itemKeys.relatedQuests] = {1429},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6065] = { -- Khadgar's Essays on Dimensional Convergence
            [itemKeys.npcDrops] = {764, 765, 766, 1081},
        },
        [6193] = { -- Bundle of Atal'ai Artifacts
            [itemKeys.relatedQuests] = {1429},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6358] = { -- Oily Blackmouth
            [itemKeys.objectDrops] = {},
        },
        [6359] = { -- Firefin Snapper
            [itemKeys.objectDrops] = {},
        },
        [6435] = { -- Infused Burning Gem
            [itemKeys.relatedQuests] = {1435},
            [itemKeys.npcDrops] = {4663, 4664, 4665, 4666, 4667, 4668, 4705, 13019},
            [itemKeys.objectDrops] = {},
        },
        [6462] = { -- Secure Crate
            [itemKeys.relatedQuests] = {1492},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [6522] = { -- Deviate Fish
            [itemKeys.objectDrops] = {},
        },
        [6912] = { -- Heartswood
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {93192},
            [itemKeys.relatedQuests] = {1738},
        },
        [6992] = { -- Jordan's Ore Shipment
            [itemKeys.npcDrops] = {},
        },
        [7067] = { -- Elemental Earth
            [itemKeys.npcDrops] = {92, 2258, 2359, 2592, 2735, 2736, 2752, 2755, 2791, 2919, 4034, 4035, 4120, 4499, 5465, 7031, 7032, 7135, 7136, 7137, 8278, 9396, 10119, 11658, 11659, 11665, 11746, 11747, 11777, 11778, 11781, 11782, 11783, 11784, 12076, 12100, 12101, 13256, 14462, 14464, 15205, 15208, 15307},
        },
        [7070] = { -- Elemental Water
            [itemKeys.objectDrops] = {},
        },
        [7079] = { -- Globe of Water
            [itemKeys.objectDrops] = {},
        },
        [7080] = { -- Essence of Water
            [itemKeys.objectDrops] = {},
        },
        [7083] = { -- Purified Kor Gem
            [itemKeys.relatedQuests] = {1442, 1654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7134] = { -- Sturdy Dragonmaw Shinbone (#1163)
            [itemKeys.relatedQuests] = {1846},
            [itemKeys.npcDrops] = {1034, 1035, 1036, 1038, 1057},
            [itemKeys.objectDrops] = {},
        },
        [7206] = { -- Mirror Lake Water Sample (#1286)
            [itemKeys.relatedQuests] = {1860},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174794},
        },
        [7207] = { -- Jennea's Flask (#1286)
            [itemKeys.relatedQuests] = {1860},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7208] = { -- Tazan's Key
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {6466},
            [itemKeys.objectDrops] = {},
        },
        [7228] = { -- Tigule's Strawberry Ice Cream
            [itemKeys.name] = "Tigule\'s Strawberry Ice Cream",
        },
        [7268] = { -- Xavian Water Sample (#1097)
            [itemKeys.relatedQuests] = {1944},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174797},
        },
        [7269] = { -- Deino's Flask (#1097)
            [itemKeys.relatedQuests] = {1944},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7297] = { -- Morbent's Bane
            [itemKeys.class] = 12,
        },
        [7628] = { -- Nondescript Letter
            [itemKeys.relatedQuests] = {8},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [7675] = { -- Defias Shipping Schedule
            [itemKeys.relatedQuests] = {2206},
        },
        [7737] = { -- Sethir's Journal
            [itemKeys.relatedQuests] = {2242},
            [itemKeys.npcDrops] = {6909},
            [itemKeys.objectDrops] = {},
        },
        [7769] = { -- Filled Brown Waterskin
            [itemKeys.relatedQuests] = {1535},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107046},
        },
        [7770] = { -- Filled Blue Waterskin
            [itemKeys.relatedQuests] = {1534},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107047},
        },
        [7771] = { -- Filled Red Waterskin
            [itemKeys.relatedQuests] = {1536},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {107045},
        },
        [7867] = { -- Vessel of Dragon's Blood (#1469)
            [itemKeys.relatedQuests] = {2203, 2501},
            [itemKeys.npcDrops] = {2726},
            [itemKeys.objectDrops] = {},
        },
        [7910] = { -- Star Ruby
            [itemKeys.npcDrops] = {},
        },
        [7923] = { -- Defias Tower Key
            [itemKeys.npcDrops] = {7051},
        },
        [7972] = { -- Ichor of Undeath
            [itemKeys.npcDrops] = {1488, 1489, 1783, 1784, 1785, 1787, 1788, 1789, 1791, 1793, 1794, 1795, 1796, 1802, 1804, 1805, 3094, 4472, 4474, 4475, 6116, 6117, 7370, 7523, 7524, 7864, 8523, 8524, 8525, 8526, 8527, 8528, 8529, 8530, 8531, 8532, 8538, 8539, 8540, 8541, 8542, 8543, 8545, 10500, 10580, 10816, 11873, 12262, 12263, 12377, 12378, 12379, 12380},
        },
        [7974] = { -- Zesty Clam Meat
            [itemKeys.itemDrops] = {7973},
        },
        [8072] = { -- Silixiz's Tower Key
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {7287},
            [itemKeys.objectDrops] = {},
        },
        [8170] = { -- Rugged Leather
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [8396] = { -- Vulture Gizzard
            [itemKeys.npcDrops] = {5982, 5983},
        },
        [8523] = { -- Field Testing Kit
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {7683},
            [itemKeys.objectDrops] = {},
        },
        [8584] = { -- Untapped Dowsing Widget
            [itemKeys.relatedQuests] = {992},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [8585] = { -- Tapped Dowsing Widget
            [itemKeys.relatedQuests] = {992},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {144052},
        },
        [8831] = { -- Purple Lotus
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {142140, 180165},
        },
        [8836] = { -- Arthas' Tears
            [itemKeys.npcDrops] = {},
        },
        [8846] = { -- Gromsblood
            [itemKeys.npcDrops] = {},
        },
        [9254] = { -- Cuergo's Treasure Map
            [itemKeys.relatedQuests] = {2882},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9284] = { -- Full Leaden Collection Phial
            [itemKeys.npcDrops] = {6213, 6329},
        },
        [9306] = { -- Stave of Equinex (#1487)
            [itemKeys.relatedQuests] = {2879, 2942},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {144063},
        },
        [9330] = { -- Snapshot of Gammerita
            [itemKeys.relatedQuests] = {2944},
            [itemKeys.npcDrops] = {7977},
            [itemKeys.objectDrops] = {},
        },
        [9365] = { -- High Potency Radioactive Fallout
            [itemKeys.npcDrops] = {6218, 6219, 6220},
        },
        [9438] = { -- Acceptable Scorpid Sample
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9440] = { -- Acceptable Basilisk Sample
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9441] = { -- Acceptable Hyena Sample
            [itemKeys.relatedQuests] = {654},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9574] = { -- Glyphic Scroll
            [itemKeys.relatedQuests] = {3098},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [9593] = { -- Treant Muisek (#1184)
            [itemKeys.relatedQuests] = {3126},
            [itemKeys.npcDrops] = {7584},
            [itemKeys.objectDrops] = {},
        },
        [9594] = { -- Wildkin Muisek (#1227)
            [itemKeys.relatedQuests] = {3123},
            [itemKeys.npcDrops] = {2927, 2928, 2929},
            [itemKeys.objectDrops] = {},
        },
        [9595] = { -- Hippogryph Muisek
            [itemKeys.relatedQuests] = {3124},
            [itemKeys.npcDrops] = {5300, 5304, 5305, 5306},
            [itemKeys.objectDrops] = {},
        },
        [9596] = { -- Faerie Dragon Muisek (#1184)
            [itemKeys.relatedQuests] = {3125},
            [itemKeys.npcDrops] = {5276, 5278},
            [itemKeys.objectDrops] = {},
        },
        [9597] = { -- Mountain Giant Muisek (#1461)
            [itemKeys.relatedQuests] = {3127},
            [itemKeys.npcDrops] = {5357, 5358, 14604, 14640},
            [itemKeys.objectDrops] = {},
        },
        [10283] = { -- Wolf Heart Samples
            [itemKeys.relatedQuests] = {1359},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [10327] = { -- Horn of Echeyakee
            [itemKeys.relatedQuests] = {881},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [10515] = { -- Torch of Retribution
            [itemKeys.class] = itemClasses.QUEST,
        },
        [10575] = { -- Black Dragonflight Molt
            [itemKeys.npcDrops] = {9461}, -- #1216
        },
        [10589] = { -- Oathstone of Ysera's Dragonflight
            [itemKeys.npcDrops] = {5353},
        },
        [10639] = { -- Hyacinth Mushroom
            [itemKeys.npcDrops] = {1988, 1989},
        },
        [10663] = { -- Essence of Hakkar
            [itemKeys.class] = itemClasses.QUEST,
        },
        [10691] = { -- Filled Vial Labeled #1 (#1396)
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152598},
        },
        [10692] = { -- Filled Vial Labeled #2 (#1396)
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152604},
        },
        [10693] = { -- Filled Vial Labeled #3 (#1396)
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152605},
        },
        [10694] = { -- Filled Vial Labeled #4 (#1396)
            [itemKeys.relatedQuests] = {3568},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {152606},
        },
        [10757] = { -- Ward of the Defiler
            [itemKeys.class] = 12,
        },
        [11018] = { -- Un'Goro Soil
            [itemKeys.npcDrops] = {},
        },
        [11040] = { -- Morrowgrain
            [itemKeys.relatedQuests] = {3785, 3786, 3803, 3792, 3804, 3791},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11078] = { -- Relic Coffer Key
            [itemKeys.class] = 12,
        },
        [11113] = { -- Crate of Foodstuffs
            [itemKeys.objectDrops] = {161526},
        },
        [11129] = { -- Essence of the Elements
            [itemKeys.npcDrops] = {8908, 8906, 8905, 8909, 8910, 8911, 8923, 9017, 9025, 9026, 9156,},
        },
        [11131] = { -- Hive Wall Sample
            [itemKeys.relatedQuests] = {3883},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174793},
        },
        [11148] = { -- Samophlange Manual Page
            [itemKeys.class] = 12,
        },
        [11149] = { -- Samophlange Manual
            [itemKeys.relatedQuests] = {3924},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11184] = { -- Blue Power Crystal
            [itemKeys.npcDrops] = {},
        },
        [11185] = { -- Green Power Crystal
            [itemKeys.npcDrops] = {},
        },
        [11186] = { -- Red Power Crystal
            [itemKeys.npcDrops] = {},
        },
        [11188] = { -- Yellow Power Crystal
            [itemKeys.npcDrops] = {},
        },
        [11243] = { -- Videre Elixir
            [itemKeys.npcDrops] = {7775},
        },
        [11370] = { -- Dark Iron Ore
            [itemKeys.npcDrops] = {},
        },
        [11412] = { -- Nagmara's Vial (#1136)
            [itemKeys.relatedQuests] = {4201},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [11413] = { -- Nagmara's Filled Vial (#1136)
            [itemKeys.relatedQuests] = {4201},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {165678},
        },
        [11470] = { -- Tablet Transcript
            [itemKeys.relatedQuests] = {4296},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {169294},
        },
        [11522] = { -- Silver Totem of Aquementas
            [itemKeys.relatedQuests] = {4005},
            [itemKeys.npcDrops] = {9453},
            [itemKeys.objectDrops] = {},
        },
        [11818] = { -- Grimesilt Outhouse Key
            [itemKeys.npcDrops] = {5840, 5844, 5846, 8504, 8566, 15692},
        },
        [11914] = { -- Empty Cursed Ooze Jar
            [itemKeys.npcDrops] = {},
            [itemKeys.class] = 12,
        },
        [11947] = { -- Filled Cursed Ooze Jar (#1315)
            [itemKeys.relatedQuests] = {4512},
            [itemKeys.npcDrops] = {7086},
            [itemKeys.objectDrops] = {},
        },
        [11948] = { -- Empty Tainted Ooze Jar
            [itemKeys.npcDrops] = {},
            [itemKeys.class] = 12,
        },
        [11949] = { -- Filled Tainted Ooze Jar (#1315)
            [itemKeys.relatedQuests] = {4512},
            [itemKeys.npcDrops] = {7092},
            [itemKeys.objectDrops] = {},
        },
        [11953] = { -- Empty Pure Sample Jar
            [itemKeys.class] = 12,
        },
        [11954] = { -- Filled Pure Sample Jar (#1070)
            [itemKeys.relatedQuests] = {4513},
            [itemKeys.npcDrops] = {6556, 6557, 6559},
            [itemKeys.objectDrops] = {},
        },
        [12234] = { -- Corrupted Felwood Sample
            [itemKeys.relatedQuests] = {4293},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174848},
        },
        [12236] = { -- Pure Un'Goro Sample
            [itemKeys.relatedQuests] = {4294},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {175265},
        },
        [12291] = { -- Merged Ooze Sample
            [itemKeys.npcDrops] = {6557, 9621},
        },
        [12347] = { -- Filled Cleansing Bowl
            [itemKeys.relatedQuests] = {4763},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174795},
        },
        [12349] = { -- Cliffspring River Sample
            [itemKeys.relatedQuests] = {4762},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {175371},
        },
        [12350] = { -- Empty Sampling Tube
            [itemKeys.relatedQuests] = {4762},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12364] = { -- Huge Emerald
            [itemKeys.npcDrops] = {},
        },
        [12366] = { -- Thick Yeti Fur
            [itemKeys.npcDrops] = {7457, 7458},
        },
        [12368] = { -- Dawn's Gambit
            [itemKeys.relatedQuests] = {4771},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12533] = { -- Roughshod Pike
            [itemKeys.npcDrops] = {},
        },
        [12562] = { -- Important Blackrock Documents
            [itemKeys.npcDrops] = {},
        },
        [12567] = { -- Filled Flasket
            [itemKeys.relatedQuests] = {4505},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {148501},
        },
        [12648] = { -- Imprisoned Felhound Spirit
            [itemKeys.relatedQuests] = {4962},
            [itemKeys.npcDrops] = {4678},
            [itemKeys.objectDrops] = {},
        },
        [12649] = { -- Imprisoned Infernal Spirit
            [itemKeys.relatedQuests] = {4963},
            [itemKeys.npcDrops] = {4676},
            [itemKeys.objectDrops] = {},
        },
        [12733] = { -- Sacred Frostsaber Meat
            [itemKeys.relatedQuests] = {5056},
            [itemKeys.npcDrops] = {7434, 7433, 7430, 7432, 7431},
            [itemKeys.objectDrops] = {},
        },
        [12765] = { -- Secret Note #1
            [itemKeys.objectDrops] = {176344},
        },
        [12766] = { -- Secret Note #2
            [itemKeys.objectDrops] = {176344},
        },
        [12768] = { -- Secret Note #3
            [itemKeys.objectDrops] = {176344},
        },
        [12813] = { -- Flask of Mystery Goo (#1313)
            [itemKeys.relatedQuests] = {5085},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12847] = { -- Soul Stained Pike
            [itemKeys.npcDrops] = {10899},
        },
        [12885] = { -- Pamela's Doll (#1148)
            [itemKeys.relatedQuests] = {5149},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [12886] = { -- Pamela's Doll's Head
            [itemKeys.class] = 12,
        },
        [12907] = { -- Corrupt Moonwell Water (#1083)
            [itemKeys.relatedQuests] = {5157},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {176184},
        },
        [12922] = { -- Empty Canteen (#1083)
            [itemKeys.relatedQuests] = {5157},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
            [itemKeys.class] = 12,
        },
        [13156] = { -- Mystic Crystal
            [itemKeys.class] = 12,
        },
        [13172] = { -- Grimm's Premium Tobacco
            [itemKeys.name] = "Grimm's Premium Tobacco",
        },
        [13422] = { -- Stonescale Eel
            [itemKeys.objectDrops] = {},
        },
        [13546] = { -- Bloodbelly Fish
            [itemKeys.relatedQuests] = {5386},
            [itemKeys.npcDrops] = {11317},
            [itemKeys.objectDrops] = {},
        },
        [14047] = { -- Runecloth
            [itemKeys.npcDrops] = {},
        },
        [14048] = { -- Bolt of Runecloth
            [itemKeys.npcDrops] = {},
        },
        [14338] = { -- Empty Water Tube
            [itemKeys.relatedQuests] = {4812},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [14339] = { -- Moonwell Water Tube
            [itemKeys.relatedQuests] = {4812},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {174795},
        },
        [14645] = { -- Unfinished Skeleton Key
            [itemKeys.relatedQuests] = {5801, 5802},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {4004},
        },
        [15209] = { -- Relic Bundle
            [itemKeys.relatedQuests] = {5721},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [15843] = { -- Filled Dreadmist Peak Sampler
            [itemKeys.relatedQuests] = {6127},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19464},
        },
        [15845] = { -- Filled Cliffspring Falls Sampler
            [itemKeys.relatedQuests] = {6122},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19463},
        },
        [15874] = { -- Soft-shelled Clam
            [itemKeys.npcDrops] = {12347},
        },
        [15924] = { -- Soft-shelled Clam Meat
            [itemKeys.objectDrops] = {177784},
            [itemKeys.npcDrops] = {12347},
        },
        [16209] = { -- Podrig's Order
            [itemKeys.relatedQuests] = {6321, 6323},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16210] = { -- Gordon's Crate
            [itemKeys.relatedQuests] = {6321, 6323},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16581] = { -- Resonite Crystal
            [itemKeys.relatedQuests] = {6421},
            [itemKeys.npcDrops] = {},
        },
        [16642] = { -- Shredder Operating Manual - Chapter 1
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16643] = { -- Shredder Operating Manual - Chapter 2
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16644] = { -- Shredder Operating Manual - Chapter 3
            [itemKeys.relatedQuests] = {6504},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16763] = { -- Warsong Runner Update
            [itemKeys.relatedQuests] = {6543, 6545},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16764] = { -- Warsong Scout Update
            [itemKeys.relatedQuests] = {6543, 6547},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16765] = { -- Warsong Outrider Update
            [itemKeys.relatedQuests] = {6543, 6546},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [16882] = { -- Battered Junkbox
            [itemKeys.itemDrops] = {},
        },
        [16883] = { -- Worn Junkbox
            [itemKeys.itemDrops] = {},
        },
        [16884] = { -- Sturdy Junkbox
            [itemKeys.itemDrops] = {},
        },
        [16967] = { -- Feralas Ahi
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400006},
        },
        [16968] = { -- Sar'theris Striker
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400008},
        },
        [16969] = { -- Savage Coast Blue Sailfin
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400009},
        },
        [16970] = { -- Misty Reed Mahi Mahi
            [itemKeys.relatedQuests] = {6607},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {400007},
        },
        [16973] = { -- Vial of Dire Water (#1156)
            [itemKeys.relatedQuests] = {5247},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {178224},
        },
        [16974] = { -- Empty Water Vial (#1156)
            [itemKeys.relatedQuests] = {5247},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [17124] = { -- Syndicate Emblem
            [itemKeys.relatedQuests] = {},
            [itemKeys.npcDrops] = {2246, 2590, 2240, 2586, 2589, 2587, 2588, 2242, 2241, 2319, 2261, 2244, 2260},
            [itemKeys.objectDrops] = {},
        },
        [17309] = { -- Discordant Bracers
            [itemKeys.npcDrops] = {8519, 8520, 8521, 8522},
        },
        [17684] = { -- Theradric Crystal Carving
            [itemKeys.npcDrops] = {11688, 11790, 11791, 11792, 11793, 11794, 12201, 12203, 12206, 12207, 12216, 12218, 12219, 12220, 12221, 12222, 12223, 12224, 12225, 12236, 12237, 12239, 12240, 12241, 12242, 12243, 12258, 13282, 13596, 13601, 13696, 13718},
        },
        [17696] = { -- Filled Cerulean Vial
            [itemKeys.relatedQuests] = {7029, 7041},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {178907},
        },
        [17761] = { -- Gem of the First Khan
            [itemKeys.npcDrops] = {12240},
        },
        [17762] = { -- Gem of the Second Khan
            [itemKeys.npcDrops] = {12239},
        },
        [17763] = { -- Gem of the Third Khan
            [itemKeys.npcDrops] = {12241},
        },
        [17764] = { -- Gem of the Fourth Khan
            [itemKeys.npcDrops] = {12242},
        },
        [17765] = { -- Gem of the Fifth Khan
            [itemKeys.npcDrops] = {12243},
        },
        [18151] = { -- Filled Amethyst Phial
            [itemKeys.relatedQuests] = {7383},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {19552},
        },
        [18152] = { -- Amethyst Phial
            [itemKeys.relatedQuests] = {7383},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [18240] = { -- Ogre Tannin
            [itemKeys.npcDrops] = {},
        },
        [18335] = { -- Pristine Black Diamond
            [itemKeys.class] = 12,
        },
        [18401] = { -- Nostro's Compendium of Dragon Slaying
            [itemKeys.name] = "Nostro's Compendium of Dragon Slaying",
        },
        [18605] = { -- Imprisoned Doomguard (#7583)
            [itemKeys.npcDrops] = {12396},
        },
        [18642] = { -- Jaina's Autograph
            [itemKeys.npcDrops] = {4968},
        },
        [18643] = { -- Cairne's Hoofprint
            [itemKeys.npcDrops] = {3057},
        },
        [18746] = { -- Divination Scryer (#1344)
            [itemKeys.relatedQuests] = {7666, 7669, 8258},
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
        },
        [18947] = { -- Rage Scar Yeti Hide (#2321)
            [itemKeys.npcDrops] = {5296, 5297, 5299},
        },
        [18952] = { -- Simone's Head
            [itemKeys.npcDrops] = {14527, 14533},
        },
        [18953] = { -- Klinfran's Head
            [itemKeys.npcDrops] = {14534, 14529},
        },
        [18954] = { -- Solenor's Head
            [itemKeys.npcDrops] = {14536, 14530},
        },
        [18955] = { -- Artorius's Head
            [itemKeys.npcDrops] = {14531, 14535},
        },
        [18956] = { -- Miniaturization Residue (#1470)
            [itemKeys.npcDrops] = {5357, 5358, 5359, 5360, 5361, 14603, 14604, 14638, 14639, 14640},
        },
        [19034] = { -- Lard's Lunch
            [itemKeys.objectDrops] = {179910},
        },
        [19016] = { -- Vessel of Rebirth
            [itemKeys.relatedQuests] = {7785},
            [itemKeys.npcDrops] = {14347},
            [itemKeys.objectDrops] = {},
        },
        [19803] = { -- Brownell's Blue Striped Racer
            [itemKeys.objectDrops] = {},
        },
        [19805] = { -- Keefer's Angelfish
            [itemKeys.objectDrops] = {},
        },
        [19806] = { -- Dezian Queenfish
            [itemKeys.objectDrops] = {},
        },
        [19807] = { -- Speckled Tastyfish
            [itemKeys.objectDrops] = {},
        },
        [19808] = { -- Rockhide Strongfish
            [itemKeys.objectDrops] = {},
        },
        [19975] = { -- Zulian Mudskunk
            [itemKeys.objectDrops] = {},
        },
        [20023] = { -- Encoded Fragment
            [itemKeys.npcDrops] = {8766},
        },
        [20310] = { -- Flayed Demon Skin
            [itemKeys.relatedQuests] = {1480},
        },
        [20378] = { -- Twilight Tablet Fragment
            [itemKeys.npcDrops] = {},
        },
        [20454] = { -- Hive'Zora Rubbing
            [itemKeys.relatedQuests] = {8309},
            [itemKeys.objectDrops] = {180455},
            [itemKeys.npcDrops] = {},
        },
        [20455] = { -- Hive'Ashi Rubbing
            [itemKeys.relatedQuests] = {8309},
            [itemKeys.objectDrops] = {180454},
            [itemKeys.npcDrops] = {},
        },
        [20456] = { -- Hive'Regal Rubbing
            [itemKeys.relatedQuests] = {8309},
            [itemKeys.objectDrops] = {180453},
            [itemKeys.npcDrops] = {},
        },
        [20464] = { -- Glyphs of Calling
            [itemKeys.class] = 12,
        },
        [20490] = { -- Ironforge Mint
            [itemKeys.npcDrops] = {5111},
        },
        [20491] = { -- Undercity Mint
            [itemKeys.npcDrops] = {6741},
        },
        [20492] = { -- Stormwind Nougat
            [itemKeys.npcDrops] = {6740},
        },
        [20493] = { -- Orgrimmar Nougat
            [itemKeys.npcDrops] = {6929},
        },
        [20494] = { -- Gnomeregan Gumdrop
            [itemKeys.npcDrops] = {6826},
        },
        [20495] = { -- Darkspear Gumdrop
            [itemKeys.npcDrops] = {11814},
        },
        [20496] = { -- Darnassus Marzipan
            [itemKeys.npcDrops] = {6735},
        },
        [20497] = { -- Thunder Bluff Marzipan
            [itemKeys.npcDrops] = {6746},
        },
        [20708] = { -- Tightly Sealed Trunk
            [itemKeys.objectDrops] = {},
        },
        [20709] = { -- Rumsey Rum Light
            [itemKeys.objectDrops] = {},
        },
        [20944] = { -- Tactical Task Briefing IX
            [itemKeys.npcDrops] = {},
        },
        [21071] = { -- Raw Sagefish
            [itemKeys.objectDrops] = {},
        },
        [21106] = { -- Draconic for Dummies
            [itemKeys.objectDrops] = {180666},
        },
        [21107] = { -- Draconic for Dummies
            [itemKeys.objectDrops] = {180665},
        },
        [21109] = { -- Draconic for Dummies
            [itemKeys.objectDrops] = {180667},
        },
        [21113] = { -- Watertight Trunk
            [itemKeys.objectDrops] = {},
        },
        [21114] = { -- Rumsey Rum Dark
            [itemKeys.objectDrops] = {},
        },
        [21150] = { -- Iron Bound Trunk
            [itemKeys.objectDrops] = {},
        },
        [21151] = { -- Rumsey Rum Black Label
            [itemKeys.objectDrops] = {},
        },
        [21153] = { -- Raw Greater Sagefish
            [itemKeys.objectDrops] = {},
        },
        [21158] = { -- Hive'Zora Scout Report
            [itemKeys.relatedQuests] = {8534},
            [itemKeys.npcDrops] = {15610},
            [itemKeys.objectDrops] = {},
        },
        [21160] = { -- Hive'Regal Scout Report
            [itemKeys.relatedQuests] = {8738},
            [itemKeys.npcDrops] = {15609},
            [itemKeys.objectDrops] = {},
        },
        [21161] = { -- Hive'Ashi Scout Report
            [itemKeys.relatedQuests] = {8739},
            [itemKeys.npcDrops] = {15611},
            [itemKeys.objectDrops] = {},
        },
        [21228] = { -- Mithril Bound Trunk
            [itemKeys.objectDrops] = {},
        },
        [21314] = { -- Metzen's Letters and Notes
            [itemKeys.npcDrops] = {},
        },
        [21232] = { -- Imperial Qiraji Armaments
            [itemKeys.npcDrops] = {15275, 15276, 15299, 15509, 15510, 15511, 15516, 15517, 15543, 15544},
        },
        [21237] = { -- Imperial Qiraji Regalia
            [itemKeys.npcDrops] = {15275, 15276, 15299, 15509, 15510, 15511, 15516, 15517, 15543, 15544},
        },
        [21557] = { -- Small Red Rocket
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21558] = { -- Small Blue Rocket
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21559] = { -- Small Green Rocket
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21571] = { -- Blue Rocket Cluster
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21574] = { -- Green Rocket Cluster
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21576] = { -- Red Rocket Cluster
            [itemKeys.relatedQuests] = {8867},
            [itemKeys.npcDrops] = {15898},
            [itemKeys.objectDrops] = {},
        },
        [21711] = { -- Lunar Festival Invitation
            [itemKeys.class] = itemClasses.QUEST,
        },
        [22094] = { -- Bloodkelp
            [itemKeys.npcDrops] = {4364, 4366, 4368, 4370, 4371, 16072},
        },
        [22229] = { -- Soul Ashes of the Banished (#2344)
            [itemKeys.npcDrops] = {7068, 7069, 7071, 7072, 7075},
        },
        [22374] = { -- Wartorn Chain Scrap
            [itemKeys.npcDrops] = {15974, 15975, 15976, 15978, 15979, 15980, 15981, 16017, 16018, 16020, 16021, 16022, 16025, 16067, 16145, 16154, 16156, 16157, 16158, 16163, 16164, 16165, 16167, 16168, 16193, 16194, 16215, 16216, 16244, 16368, 16446, 16447, 16448, 16449, 16451, 16452, 16453},
        },
        [22435] = { -- Gorishi Sting (#1771)
            [itemKeys.npcDrops] = {6551, 6554},
        },
        [22527] = { -- Core of Elements
            [itemKeys.npcDrops] = {6520, 6521, 7031, 7032, 7132, 8519, 8520, 8521, 8522, 8909, 8910, 8911, 9017, 9025, 9026, 9816, 9878, 9879, 11480, 11483, 11484, 11744, 11745, 11746, 11747, 13279, 13280, 14399, 14400, 14455, 14458, 14460, 14462},
        },
        [23179] = { -- Flame of Orgrimmar
            [itemKeys.objectDrops] = {181336},
        },
        [23180] = { -- Flame of Thunder Bluff
            [itemKeys.objectDrops] = {181337},
        },
        [23181] = { -- Flame of the Undercity
            [itemKeys.objectDrops] = {181335},
        },
        [23182] = { -- Flame of Stormwind
            [itemKeys.objectDrops] = {181332},
        },
        [23183] = { -- Flame of Ironforge
            [itemKeys.objectDrops] = {181333},
        },
        [23184] = { -- Flame of Darnassus
            [itemKeys.objectDrops] = {181334},
        },
        [190179] = { -- Avelina's Heart
            [itemKeys.name] = "Avelina's Heart",
            [itemKeys.npcDrops] = {185333},
            [itemKeys.relatedQuests] = {65593},
        },
        [190180] = { -- Isaac's Heart
            [itemKeys.name] = "Isaac's Heart",
            [itemKeys.npcDrops] = {185334},
            [itemKeys.relatedQuests] = {65593},
        },
        [190181] = { -- Lovers' Hearts
            [itemKeys.name] = "Lovers' Hearts",
            [itemKeys.relatedQuests] = {65597},
        },
        [190186] = { -- Wooden Figurine
            [itemKeys.name] = "Wooden Figurine",
            [itemKeys.relatedQuests] = {65603},
        },
        [190187] = { -- Withered Scarf
            [itemKeys.name] = "Withered Scarf",
            [itemKeys.relatedQuests] = {65604},
        },
        [190232] = { -- Withered Scarf
            [itemKeys.name] = "Withered Scarf",
            [itemKeys.npcDrops] = {3782, 3784},
            [itemKeys.relatedQuests] = {65610},
        },
        [190307] = { -- Unlit Torch
            [itemKeys.name] = "Unlit Torch",
            [itemKeys.objectDrops] = {400001},
            [itemKeys.flags] = 2, -- Conjured
            [itemKeys.relatedQuests] = {65602},
        },
        [190309] = { -- Wooden Figurine
            [itemKeys.name] = "Wooden Figurine",
            [itemKeys.objectDrops] = {375544},
            [itemKeys.relatedQuests] = {65602},
        },
        ----------------
        [227911] = { -- Head of Rend Blackhand
            [itemKeys.name] = "Head of Rend Blackhand",
            [itemKeys.npcDrops] = {10429},
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 84377,
        },
    }
end

-- some quest items are shared across factions but require different sources for each faction (not sure if there is a better way to implement this)
function QuestieItemFixes:LoadFactionFixes()
    local itemKeys = QuestieDB.itemKeys

    local itemFixesHorde = {
        [15882] = { -- Half Pendant of Aquatic Endurance
            [itemKeys.objectDrops] = {177790},
        },
        [15883] = { -- Half Pendant of Aquatic Agility
            [itemKeys.objectDrops] = {177794},
        },
        [3713] = { -- Soothing Spices
            [itemKeys.relatedQuests] = {7321, 1218},
            [itemKeys.npcDrops] = {2397, 8307},
            [itemKeys.objectDrops] = {},
        },
        [20810] = { -- Signed Field Duty Papers
            [itemKeys.npcDrops] = {15612},
        },
    }

    local itemFixesAlliance = {
        [15882] = { -- Half Pendant of Aquatic Endurance
            [itemKeys.objectDrops] = {177844},
        },
        [15883] = { -- Half Pendant of Aquatic Agility
            [itemKeys.objectDrops] = {177792},
        },
        [3713] = { -- Soothing Spices
            [itemKeys.name] = "Soothing Spices",
            [itemKeys.relatedQuests] = {555, 1218},
            [itemKeys.npcDrops] = {2381, 4897},
            [itemKeys.objectDrops] = {},
        },
        [20810] = { -- Signed Field Duty Papers
            [itemKeys.npcDrops] = {15440},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end
