QuestieItemFixes = {...}

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

-- [item ID] = {"name",{objective of},{dropped by},{contained in/gathered from/mined from}}
function QuestieItemFixes:Load()
    local itemFixes = {
        [5475] = {"Wooden Key",{},{3919,3834},{}},
        [5519] = {"Iron Pommel",{1027},{3928},{}},
        [4611] = {"Blue Pearl",{705},{},{2744}},
        [3340] = {"Incendicite Ore",{466},{},{1610,1667}},
        [4483] = {"Burning Key",{651},{},{2689}},
        [3829] = {"Frost Oil",{713,1193},{},{}},
        [15843] = {"Filled Dreadmist Peak Sampler",{6127},{},{19464}},
        [15845] = {"Filled Cliffspring Falls Sampler",{6122},{},{19463}},
        [17124] = {"Syndicate Emblem",{},{2246,2590,2240,2586,2589,2587,2588,2242,2241,2319,2261,2244,2260},{}},
        [8072] = {"Silixiz's Tower Key",{},{7287},{}},
        [7923] = {"Defias Tower Key",{2359},{7051},{}},
        [7675] = {"Defias Shipping Schedule",{},{6846},{}},
        [7737] = {"Sethir's Journal",{},{6909},{}},
        [7208] = {"Tazan's Key",{},{6466},{}},
        [12347] = {"Filled Cleansing Bowl",{},{},{174795}},
        [2886] = {"Crag Boar Rib",{384},{1125,1126,1127,1689},{}},
        [5051] = {"Dig Rat",{862},{3444},{}},
        [5056] = {"Root Sample",{866},{},{1619,3726,1618,3724,1620,3727}},
        [12349] = {"Cliffspring River Sample",{4762},{},{175371}},
        [12350] = {"Empty Sampling Tube",{4762},{},{}},
        [5184] = {"Filled Crystal Phial",{921},{},{19549}},
        [5185] = {"Crystal Phial",{921},{},{}},
        [5186] = {"Partially Filled Vessel",{928},{},{}},
        [5639] = {"Filled Jade Phial",{929},{},{19550}},
        [5619] = {"Jade Phial",{929},{},{}},
        [5645] = {"Filled Tourmaline Phial",{933},{},{19551}},
        [5621] = {"Tourmaline Phial",{933},{},{}},
        [18151] = {"Filled Amethyst Phial",{7383},{},{19552}},
        [18152] = {"Amethyst Phial",{7383},{},{}},
        [5188] = {"Filled Vessel",{935},{},{}},
        [11184] = {"Blue Power Crystal",{4284,4382,4384,4386},{},{164658,164778}},
        [11185] = {"Green Power Crystal",{4284,4381,4382,4383},{},{164659,164779}},
        [11186] = {"Red Power Crystal",{4284,4383,4384,4385},{},{164660,164780}},
        [11188] = {"Yellow Power Crystal",{4284,4381,4385,4386},{},{164661,164781}},
        -- add NPC 1988 (missing in cmangos) and object 152094 (present in cmangos)
        [10639] = {"Hyacinth Mushroom",{3521},{1988,1989},{152094}},
        [14338] = {"Empty Water Tube",{4812},{},{}},
        [15209] = {"Relic Bundle",{5721},{},{}},
        [14339] = {"Moonwell Water Tube",{4812},{},{174795}},
        [8584] = {"Untapped Dowsing Widget",{992},{},{}},
        [8585] = {"Tapped Dowsing Widget",{992},{},{144052}},
        [11149] = {"Samophlange Manual",{3924},{},{}},
        [11018] = {"Un\'Goro Soil",{4496,3761,3764},{},{157936}},
        [6435] = {"Infused Burning Gem",{1435},{4663,4664,4665,4666,4667,4668,4705,13019},{}},
        [3388] = {"Strong Troll's Brool Potion",{515},{},{}},
        [3508] = {"Mudsnout Mixture",{515},{},{}},
        [4904] = {"Venomtail Antidote",{812},{},{}},
        [2594] = {"Flagon of Dwarven Honeymead",{288},{1464},{}},
        [5868] = {"Filled Etched Phial",{1195},{},{20806}},
        [16642] = {"Shredder Operating Manual - Chapter 1",{6504},{},{}},
        [16643] = {"Shredder Operating Manual - Chapter 2",{6504},{},{}},
        [16644] = {"Shredder Operating Manual - Chapter 3",{6504},{},{}},
        [16764] = {"Warsong Scout Update",{6543,6547},{},{}},
        [16763] = {"Warsong Runner Update",{6543,6545},{},{}},
        [16765] = {"Warsong Outrider Update",{6543,6546},{},{}},
        [1013] = {"Iron Rivet",{89},{426,430,446,580},{}}, -- Remove rare mob #903
        [2856] = {"Iron Pike",{89},{426,430,446,580},{}}, -- Remove rare mob #903
        [11131] = {"Hive Wall Sample",{3883},{},{174793}},
        [5455] = {"Divined Scroll",{1016},{},{}},
        [9440] = {"Acceptable Basilisk Sample",{654},{},{}},
        [9441] = {"Acceptable Hyena Sample",{654},{},{}},
        [9438] = {"Acceptable Scorpid Sample",{654},{},{}},
        [8523] = {"Field Testing Kit",{654},{7683},{}},
        [9330] = {"Snapshot of Gammerita",{2944},{7977},{}},
        [11113] = {"Crate of Foodstuffs",{3881},{},{161526}},
        [11470] = {"Tablet Transcript",{4296},{},{169294}},
        [12283] = {"Broodling Essence",{4726},{7047,7048,7049,},{175264}},
        [11522] = {"Silver Totem of Aquementas",{4005},{},{148507}},
        [9593] = {"Treant Muisek",{3126},{7584},{}}, -- #1184
        [9595] = {"Hippogryph Muisek",{3124},{5300,5304,5305,5306},{}},
        [9596] = {"Faerie Dragon Muisek",{3125},{5276,5278},{}}, -- #1184
        [11954] = {"Filled Pure Sample Jar",{4513},{6556,6557,6559,},{}}, -- #1070
        [12907] = {"Corrupted Moonwell Water",{5157},{},{176184}}, -- #1083
        [12922] = {"Empty Canteen",{5157},{},{}}, -- #1083
        [7268] = {"Xavian Water Sample",{1944},{},{174797}}, -- #1097
        [7269] = {"Deino's Flask",{1944},{},{}}, -- #1097
        [11412] = {"Nagmara's Vial",{4201},{},{}}, -- #1136
        [11413] = {"Nagmara's Filled Vial",{4201},{},{165678}}, -- #1136
        [15874] = {"Soft-shelled Clam",{6142},{12347},{177784}},
        [12885] = {"Pamela's Doll",{5149},{},{}}, -- #1148
        [5798] = {"Rocket Car Parts",{1110},{},{19868,19869,19870,19871,19872,19873}},
        [16974] = {"Empty Water Vial",{5247},{},{}}, -- #1156
        [16973] = {"Vial of Dire Water",{5247},{},{178224}}, -- #1156
        [7134] = {"Sturdy Dragonmaw Shinbone",{1846},{1034,1035,1036,1038,1057,},{}}, -- #1163
        [12324] = {"Forged Seal of Ascension",{4743},{10321},{}}, -- #1175
        [7206] = {"Mirror Lake Water Sample",{1860},{},{174794}}, -- #1286
        [7207] = {"Jennea's Flask",{1860},{},{}}, -- #1286
        [10575] = {"Black Dragonflight Molt",{4022,4023},{},{10569}}, -- #1216
        [9594] = {"Wildkin Muisek",{3123},{2927,2928,2929,},{}}, -- #1227
        [2894] = {"Rhapsody Malt",{384},{1247},{}}, -- #1285
        [12813] = {"Flask of Mystery Goo",{5085},{},{}}, -- #1313
        [11947] = {"Filled Cursed Ooze Jar",{4512},{7086},{}}, -- #1315
        [11949] = {"Filled Tainted Ooze Jar",{4512},{7092},{}}, -- #1315
        [18746] = {"Divination Scryer",{7666,7669,8258,},{},{}}, -- #1344
        [18605] = {"Imprisoned Doomguard",{7583},{12396},{179644}}, -- #7583
        [10691] = {"Filled Vial Labeled #1",{3568},{},{152598}}, -- #1396
        [10692] = {"Filled Vial Labeled #2",{3568},{},{152604}}, -- #1396
        [10693] = {"Filled Vial Labeled #3",{3568},{},{152605}}, -- #1396
        [10694] = {"Filled Vial Labeled #4",{3568},{},{152606}}, -- #1396
        [9597] = {"Mountain Giant Muisek",{3127},{5357,5358,5359,5360,5361,14603,14604,14638,14639,14640},{}}, -- #1461
        [7867] = {"Vessel of Dragon's Blood",{2203,2501},{2726},{}}, -- #1469
        [18956] = {"Miniaturization Residue",{7003,7725},{5357,5358,5359,5360,5361,14603,14604,14638,14639,14640},{}}, -- #1470
        [3421] = {"Simple Wildflowers",{2609},{1302,1303},{}}, -- #1476
        [3372] = {"Leaded Vial",{2609},{1286,1313,1326,1257,1325,5503,},{}}, -- #1476
        [4371] = {"Bronze Tube",{174,2609},{3495,5519,5175,},{}}, -- #1476
        [4639] = {"Enchanted Sea Kelp",{736},{4363},{}},

        -- quest related herbs
        [2449] = {"Earthroot",{6123,6128},{},{1619,3726}},
        [2447] = {"Peacebloom",{8549,8550},{},{1618,3724}},
        [8846] = {"Gromsblood",{4201},{},{142145,176637}},
        [3356] = {"Kingsblood",{7736},{},{1624}},
        [3357] = {"Liferoot",{1712},{},{2041}},
        [8836] = {"Arthas' Tears",{8509,8510,7642},{},{142141,176642}},
        [4625] = {"Firebloom",{8580,8581},{},{2866}},
        [3820] = {"Stranglekelp",{8503,8504},{},{2045}},
        [8831] = {"Purple Lotus",{8505,8506,8582,8583},{},{142140,180165}},

        -- quest related leather
        [4304] = {"Thick Leather",{8515,8516,8590,8591,2847,2854},{},{}},
        [4234] = {"Heavy Leather",{8242,8588,8589},{},{}},
        [2318] = {"Light Leather",{8511,8512,768,769},{},{}},
        [2319] = {"Medium Leather",{8513,8514},{},{}},
        [8170] = {"Rugged Leather",{8600,8601,5518,5519},{},{}},

        -- quest related mining stuff
        [11370] = {"Dark Iron Ore",{6642,7627},{},{165658}},
        [1206] = {"Moss Agate",{2948,2950},{},{}},
        [12364] = {"Huge Emerald",{8779,8807},{},{}},
        [1529] = {"Jade",{1948},{},{}},
        [7910] = {"Star Ruby",{4083,5124},{},{}},
        [3864] = {"Citrine",{2763},{},{}},

        -- other quest related trade goods
        [2592] = {"Wool Cloth",{7791,7797,7802,7807,7813,7820,7826,7833},{},{}},
        [2997] = {"Bolt of Woolen Cloth",{565},{},{}},
        [4306] = {"Silk Cloth",{9259,2746,4449,7793,7798,7803,7808,7814,7821,7827,7834},{},{}},
        [4338] = {"Mageweave Cloth",{9268,7794,7799,7804,7809,7817,7822,7831,7835},{},{}},
        [2589] = {"Linen Cloth",{9267,1644,1648,1921,1961},{},{}},
        [14047] = {"Runecloth",{9266,5218,5221,5224,5227,6031,7642,7795,7796,7800,7801,7805,7806,7811,7812,7818,7819,7823,7824,7825,7832,7836,7837},{},{}},
        [14048] = {"Bolt of Runecloth",{8782,8808,9237,9238,9239,9240,5518,5519},{},{}},
    }

    for k,v in pairs(itemFixes) do
        CHANGEME_Questie4_ItemDB[k]=v
    end

    return CHANGEME_Questie4_ItemDB
end

-- some quest items are shared across factions but require different sources for each faction (not sure if there is a better way to implement this)
function QuestieItemFixes:LoadFactionFixes()
    local itemFixesHorde = {
        [15882] = {"Half Pendant of Aquatic Endurance",{30,272},{},{177790}},
        [15883] = {"Half Pendant of Aquatic Agility",{30,272},{},{177794}},
        [3713] = {"Soothing Spices",{7321,1218,},{2397,8307},{}},
    }

    local itemFixesAlliance = {
        [15882] = {"Half Pendant of Aquatic Endurance",{30,272},{},{177844}},
        [15883] = {"Half Pendant of Aquatic Agility",{30,272},{},{177792}},
        [3713] = {"Soothing Spices",{555,1218,},{2381,4897},{}},
    }

    if UnitFactionGroup("Player") == "Horde" then
        for index, fix in pairs(itemFixesHorde) do
            QuestieCorrections.itemFixes[index] = fix
        end
    else
        for index, fix in pairs(itemFixesAlliance) do
            QuestieCorrections.itemFixes[index] = fix
        end
    end
end
