---@class CataItemFixes
local CataItemFixes = QuestieLoader:CreateModule("CataItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function CataItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [1349] = { -- Abercrombie's Crate
            [itemKeys.objectDrops] = {119},
        },
        [1357] = { -- Captain Sander's Treasure Map
            [itemKeys.startQuest] = 26353,
        },
        [2536] = { -- Trogg Stone Tooth
            [itemKeys.npcDrops] = {1161,1162,1163,1164,1165,1166,1167,1197,1393},
        },
        [2629] = { -- Intrepid Strongbox Key
            [itemKeys.npcDrops] = {41429},
        },
        [2633] = { -- Jungle Remedy
            [itemKeys.npcDrops] = {937,940,941,942},
        },
        [2676] = { -- Shimmerweed
            [itemKeys.npcDrops] = {41121},
        },
        [2794] = { -- An Old History Book
            [itemKeys.startQuest] = 0,
        },
        [2859] = { -- Vile Fin Scale
            [itemKeys.npcDrops] = {1541,1543,1544,1545},
        },
        [3082] = { -- Dargol's Skull
            [itemKeys.startQuest] = 25030,
        },
        [3897] = { -- Dizzy's Eye
            [itemKeys.npcDrops] = {1561,1562,1563,1564,1565,1653,2545,2546,2547,2548,2549,2550,2551,4505,4506,43364,43454,43542,43636},
        },
        [3910] = { -- Snuff
            [itemKeys.npcDrops] = {1561,1562,1563,1564,1565,1653,2545,2546,2547,2548,2549,2550,2551,4505,4506,43364,43454,43542,43636},
        },
        [4106] = { -- Tumbled Crystal
            [itemKeys.npcDrops] = {1096,4260},
        },
        [4440] = { -- Sigil of Strom
            [itemKeys.npcDrops] = {2588,2590,2591,24477},
        },
        [4506] = { -- Stromgarde Badge
            [itemKeys.npcDrops] = {2588,2590,2591,24477},
        },
        [5030] = { -- Centaur Bracers
            [itemKeys.npcDrops] = {3275,3396,9456,9523,9524,44170},
        },
        [5061] = { -- Stolen Silver
            [itemKeys.objectDrops] = {195224},
        },
        [5078] = { -- Theramore Medal
            [itemKeys.npcDrops] = {3385,3386,3393,5629,34706,34707},
        },
        [5084] = { -- Cap'n Garvey's Head
            [itemKeys.npcDrops] = {34750},
        },
        [5085] = { -- Quilboar Tusk
            [itemKeys.npcDrops] = {3261,3265,3266,3267,3268,3269,3271,34503,34545},
        },
        [5086] = { -- Zhevra Hooves
            [itemKeys.npcDrops] = {3242,3426,3466,44166},
        },
        [5169] = { -- Timberling Sprout
            [itemKeys.objectDrops] = {4608},
        },
        [5382] = { -- Anaya's Pendant
            [itemKeys.npcDrops] = {33181},
        },
        [5464] = { -- Iron Shaft
            [itemKeys.relatedQuests] = {26477},
            [itemKeys.npcDrops] = {},
        },
        [5475] = { -- Wooden Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [5508] = { -- Fallen Moonstone
            [itemKeys.npcDrops] = {3758,3759,3762,3763},
        },
        [5519] = { -- Iron Pommel
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {195111},
        },
        [5533] = { -- Ilkrud Magthrull's Tome
            [itemKeys.npcDrops] = {},
        },
        [5847] = { -- Mirefin Head
            [itemKeys.npcDrops] = {4358,4359,4360,4361,4362,4363,23841},
        },
        [5883] = { -- Forked Mudrock Tongue
            [itemKeys.npcDrops] = {4397},
        },
        [8170] = { -- Rugged Leather
            [itemKeys.vendors] = {},
        },
        [8244] = { -- Flawless Draenethyst Sphere
            [itemKeys.startQuest] = 25772,
        },
        [8623] = { -- OOX-17/TN Distress Beacon
            [itemKeys.npcDrops] = {5419,5420,5421,5422,5423,5424,5425,5426,5427,5428,5429,5430,5431,5441,5450,5451,5452,5453,5454,5455,5456,5457,5458,5459,5460,5465,5466,5469,5470,5471,5472,5473,5474,5475,5481,5485,5490,5616,5617,5623,5645,5646,5647,5648,5649,5650,7246,7247,7269,7272,7274,7276,7286,7604,7605,7606,7608,7795,7796,7797,7803,7855,7856,7857,7858,7899,7902,8095,8120,8667,9396,9397,10080,10081,10082,12046,14123,38646,38750,38909,38914,38916,38997,38998,39020,39022,40527,40581,40632,40635,40636,40648,40656,40665,40717,40764,44546,44557,44612},
        },
        [8704] = { -- OOX-09/HL Distress Beacon
            [itemKeys.npcDrops] = {2505,2639,2640,2641,2642,2643,2644,2645,2646,2647,2648,2649,2650,2651,2652,2653,2654,2655,2656,2657,2658,2659,2680,2681,2686,2691,2692,2693,2694,2707,2923,2924,2925,2926,2927,2928,2929,4465,4466,4467,4468,4469,7808,7809,7977,7995,7996,8636,10802,17235,17236,42536,42555,42724,42879,42901},
        },
        [8705] = { -- OOX-22/FE Distress Beacon
            [itemKeys.npcDrops] = {5229,5232,5234,5236,5237,5238,5239,5240,5241,5244,5245,5246,5247,5249,5251,5253,5254,5255,5258,5260,5262,5268,5272,5274,5276,5278,5286,5287,5288,5292,5293,5295,5296,5297,5299,5300,5304,5305,5306,5307,5308,5327,5328,5331,5332,5333,5334,5335,5336,5337,5357,5358,5359,5360,5361,5362,5363,5364,5366,5461,5462,5881,7584,7725,7726,7727,7848,8075,12418,14603,14604,14638,14639,14640,14661,39384,39728,39896,39949,39952,39957,40059,40168,40193,40224,40972},
            [itemKeys.startQuest] = 25475,
        },
        [8973] = { -- Thick Yeti Hide
            [itemKeys.npcDrops] = {40224},
        },
        [9597] = { -- Mountain Giant Muisek
            [itemKeys.npcDrops] = {40026},
        },
        [10441] = { -- Glowing Shard
            [itemKeys.startQuest] = 0,
        },
        [10458] = { -- Prayer to Elune
            [itemKeys.npcDrops] = {},
        },
        [10593] = { -- Imperfect Draenethyst Fragment
            [itemKeys.startQuest] = 25771,
        },
        [10753] = { -- Amulet of Grol
            [itemKeys.npcDrops] = {41267},
        },
        [10754] = { -- Amulet of Sevine
            [itemKeys.npcDrops] = {41265},
        },
        [10755] = { -- Amulet of Allistarj
            [itemKeys.npcDrops] = {},
        },
        [11078] = { -- Relic Coffer Key
            [itemKeys.npcDrops] = {8889,8890,8891,8892,8893,8894,8895,8898,8899,8903,9437,9438,9439,9441,9442,9443,9445,9541,9554,9680,10043,24818,24819}, -- removed the bosses to clean up the map
        },
        [11114] = { -- Dinosaur Bone
            [itemKeys.npcDrops] = {6501,6502,6503,6504,9162,9163,9164},
        },
        [11148] = { -- Samophlange Manual Page
            [itemKeys.npcDrops] = {3283,3286,9336},
        },
        [11569] = { -- Preserved Threshadon Meat
            [itemKeys.npcDrops] = {},
        },
        [11570] = { -- Preserved Pheromone Mixture
            [itemKeys.npcDrops] = {},
        },
        [11818] = { -- Grimesilt Outhouse Key
            [itemKeys.startQuest] = 0,
        },
        [11829] = { -- Un'Goro Ash
            [itemKeys.npcDrops] = {6520,6521,9376},
        },
        [11949] = { -- Filled Tainted Ooze Jar
            [itemKeys.npcDrops] = {7092,14345},
        },
        [12283] = { -- Broodling Essence
            [itemKeys.npcDrops] = {},
        },
        [12842] = { -- Crudely-Written Log
            [itemKeys.startQuest] = 28471,
        },
        [13202] = { -- Extended Annals of Darrowshire
            [itemKeys.npcDrops] = {11063},
        },
        [13250] = { -- Head of Balnazzar
            [itemKeys.startQuest] = 0,
        },
        [13920] = { -- Healthy Dragon Scale
            [itemKeys.startQuest] = 0,
        },
        [16790] = { -- Damp Note
            [itemKeys.startQuest] = 0,
        },
        [16976] = { -- Murgut's Totem
            [itemKeys.npcDrops] = {},
        },
        [18240] = { -- Ogre Tannin
            [itemKeys.objectDrops] = {179499},
            [itemKeys.npcDrops] = {},
        },
        [18597] = { -- Orcish Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [18598] = { -- Human Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [18943] = { -- Dark Iron Pillow
            [itemKeys.npcDrops] = {},
        },
        [18947] = { -- Feral Scar Yeti Hide
            [itemKeys.npcDrops] = {39896},
        },
        [18950] = { -- Chambermaid Pillaclencher's Pillow
            [itemKeys.startQuest] = 0,
        },
        [18960] = { -- Lookout's Spyglass
            [itemKeys.npcDrops] = {5840},
        },
        [19034] = { -- Lard's Lunch
            [itemKeys.objectDrops] = {},
        },
        [19424] = { -- Sayge's Fortune #24
            [itemKeys.startQuest] = 0,
        },
        [19716] = { -- Primal Hakkari Bindings
            [itemKeys.npcDrops] = {},
        },
        [19717] = { -- Primal Hakkari Armsplint
            [itemKeys.npcDrops] = {},
        },
        [19718] = { -- Primal Hakkari Stanchion
            [itemKeys.npcDrops] = {},
        },
        [19719] = { -- Primal Hakkari Girdle
            [itemKeys.npcDrops] = {},
        },
        [19720] = { -- Primal Hakkari Sash
            [itemKeys.npcDrops] = {},
        },
        [19721] = { -- Primal Hakkari Shawl
            [itemKeys.npcDrops] = {},
        },
        [19722] = { -- Primal Hakkari Tabard
            [itemKeys.npcDrops] = {},
        },
        [19723] = { -- Primal Hakkari Kossack
            [itemKeys.npcDrops] = {},
        },
        [19724] = { -- Primal Hakkari Aegis
            [itemKeys.npcDrops] = {},
        },
        [19802] = { -- Heart of Hakkar
            [itemKeys.npcDrops] = {},
        },
        [20483] = { -- Tainted Arcane Sliver
            [itemKeys.class] = itemClasses.QUEST,
        },
        [20743] = { -- Unstable Mana Crystal
            [itemKeys.npcDrops] = {},
        },
        [21145] = { -- Essence of Xandivious
            [itemKeys.npcDrops] = {},
        },
        [22674] = { -- Wavefront Medallion
            [itemKeys.npcDrops] = {},
        },
        [22978] = { -- Emitter Spare Part
            [itemKeys.npcDrops] = {},
        },
        [23726] = { -- Fel Ember
            [itemKeys.objectDrops] = {181679},
        },
        [23735] = { -- Grand Warlock's Amulet
            [itemKeys.npcDrops] = {16807},
        },
        [23777] = { -- Diabolical Plans
            [itemKeys.startQuest] = 26443,
        },
        [23797] = { -- Diabolical Plans
            [itemKeys.startQuest] = 26447,
        },
        [23901] = { -- Nazan's Head
            [itemKeys.npcDrops] = {17307},
        },
        [24025] = { -- Deathclaw's Paw
            [itemKeys.npcDrops] = {17661},
        },
        [24026] = { -- Elder Brown Bear Flank
            [itemKeys.npcDrops] = {17348},
        },
        [24040] = { -- Blood Mushroom
            [itemKeys.npcDrops] = {},
        },
        [24041] = { -- Aquatic Stinkhorn
            [itemKeys.npcDrops] = {17673},
        },
        [24042] = { -- Ruinous Polyspore
            [itemKeys.npcDrops] = {},
        },
        [24043] = { -- Fel Cone Fungus
            [itemKeys.npcDrops] = {},
        },
        [24049] = { -- Ysera's Tear
            [itemKeys.npcDrops] = {},
        },
        [24081] = { -- Satyrnaar Fel Wood
            [itemKeys.npcDrops] = {},
        },
        [24416] = { -- Corrupted Flower
            [itemKeys.npcDrops] = {},
        },
        [27480] = { -- Soul Device
            [itemKeys.objectDrops] = {182940},
        },
        [31880] = { -- Blood Elf Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31881] = { -- Draenei Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [33009] = { -- Tender Strider Meat
            [itemKeys.npcDrops] = {2956,2957},
        },
        [33833] = { -- Nazan's Riding Crop
            [itemKeys.npcDrops] = {17307},
        },
        [34028] = { -- "Honorary Brewer" Hand Stamp
            [itemKeys.npcDrops] = {},
        },
        [34130] = { -- Recovery Diver's Potion
            [itemKeys.class] = itemClasses.QUEST,
        },
        [38567] = { -- Maraudine Prisoner Manifest
            [itemKeys.startQuest] = 14330,
        },
        [38575] = { -- Shiny Treasures
            [itemKeys.npcDrops] = {},
        },
        [39684] = { -- Hair Trigger
            [itemKeys.npcDrops] = {},
        },
        [44830] = { -- Highborne Relic
            [itemKeys.npcDrops] = {},
        },
        [44911] = { -- Foul Bear Carcass Sample
            [itemKeys.npcDrops] = {32975},
        },
        [44925] = { -- Corruptor's Master Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [44966] = { -- Foul Ichor
            [itemKeys.npcDrops] = {33020,33021,33022},
        },
        [44968] = { -- Twilight Plans
            [itemKeys.npcDrops] = {},
        },
        [44969] = { -- Moonstalker Whisker
            [itemKeys.npcDrops] = {33127},
        },
        [44976] = { -- Fuming Toadstool
            [itemKeys.npcDrops] = {},
        },
        [44979] = { -- Overseer's Orders
            [itemKeys.npcDrops] = {32863},
        },
        [45004] = { -- Serviceable Arrow
            [itemKeys.npcDrops] = {},
        },
        [45027] = { -- Tuft of Mottled Doe Hair
            [itemKeys.npcDrops] = {33313},
        },
        [45042] = { -- Feero's Holy Hammer
            [itemKeys.npcDrops] = {33348},
        },
        [45043] = { -- The Purifier's Prayer Book
            [itemKeys.npcDrops] = {33347},
        },
        [45051] = { -- Kadrak's Reins
            [itemKeys.npcDrops] = {8582},
        },
        [45066] = { -- Bathed Concoction
            [itemKeys.objectDrops] = {194651},
        },
        [45069] = { -- Freshly Cut Wood
            [itemKeys.npcDrops] = {},
        },
        [45573] = { -- The Forest HEart
            [itemKeys.npcDrops] = {},
        },
        [45885] = { -- Thistle Bear Fur
            [itemKeys.npcDrops] = {33978},
        },
        [46128] = { -- Troll Charm
            [itemKeys.npcDrops] = {3924,3925,3926},
        },
        [46354] = { -- Seed of the Earth
            [itemKeys.npcDrops] = {33072},
        },
        [46355] = { -- Seed of the Sky
            [itemKeys.npcDrops] = {34306},
        },
        [46392] = { -- Venison Steak
            [itemKeys.class] = itemClasses.QUEST,
        },
        [46396] = { -- Wolvar Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [46397] = { -- Oracle Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [46471] = { -- Furbolg Ear
            [itemKeys.npcDrops] = {3743,3745,3750},
        },
        [46543] = { -- Laughing Sister's Corpse
            [itemKeys.npcDrops] = {34426},
        },
        [46696] = { -- Panther Figurine
            [itemKeys.class] = itemClasses.QUEST,
        },
        [46698] = { -- Moon-kissed Clay
            [itemKeys.npcDrops] = {},
        },
        [46702] = { -- Ancient Device Fragment
            [itemKeys.class] = itemClasses.QUEST,
        },
        [46827] = { -- Ship Schematics
            [itemKeys.npcDrops] = {34754},
        },
        [46858] = { -- Personal Riches
            [itemKeys.objectDrops] = {195525},
        },
        [46896] = { -- Salvaged Supplies
            [itemKeys.npcDrops] = {},
        },
        [47044] = { -- Shiny Bling
            [itemKeys.vendors] = {35120},
        },
        [47045] = { -- Shiny Bling
            [itemKeys.vendors] = {35126},
        },
        [47046] = { -- Hip New Outfit
            [itemKeys.vendors] = {35128},
        },
        [47047] = { -- Cool Shades
            [itemKeys.vendors] = {35130},
        },
        [47050] = { -- The Captain's Logs
            [itemKeys.objectDrops] = {195361},
        },
        [48106] = { -- Melonfruit
            [itemKeys.npcDrops] = {},
        },
        [48128] = { -- Mountainfoot Iron
            [itemKeys.npcDrops] = {},
        },
        [48707] = { -- Gilnean Mastiff Collar
            [itemKeys.class] = itemClasses.QUEST,
        },
        [48766] = { -- Kaja'mite Chunk
            [itemKeys.npcDrops] = {},
        },
        [48953] = { -- Bleached Skull
            [itemKeys.npcDrops] = {},
        },
        [49136] = { -- Blood-Filled Leech
            [itemKeys.npcDrops] = {36059},
        },
        [49164] = { -- Cenarion Supply Crate
            [itemKeys.npcDrops] = {},
        },
        [49172] = { -- Simmering Water Droplet
            [itemKeys.npcDrops] = {36131},
        },
        [49200] = { -- Infernal Power Core
            [itemKeys.npcDrops] = {35591},
        },
        [49220] = { -- Infernal Power Core
            [itemKeys.npcDrops] = {35591},
        },
        [49281] = { -- Chance the Cat
            [itemKeys.npcDrops] = {36459,36461},
        },
        [49365] = { -- Briaroot Brew
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49533] = { -- Ironwrought Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49599] = { -- Military Supplies
            [itemKeys.npcDrops] = {36756,36987},
        },
        [49642] = { -- Heart of Arkkoroc
            [itemKeys.npcDrops] = {},
        },
        [49667] = { -- Waterlogged Recipe
            [itemKeys.npcDrops] = {},
        },
        [49743] = { -- Sten's First Aid Kit
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49744] = { -- Cask of Stormhammer Stout
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49745] = { -- Cask of Theramore Pale Ale
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49746] = { -- Cask of Gnomenbrau
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49747] = { -- Boar Haunch
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49748] = { -- Ragged Wolf Hide
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49751] = { -- Priceless Rockjaw Artifact
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49754] = { -- Coldridge Beer Flagon
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49755] = { -- Ragged Wolf-Hide Cloak
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49756] = { -- Leftover Boar Meat
            [itemKeys.class] = itemClasses.QUEST,
        },
        [49875] = { -- Enervated Adder
            [itemKeys.npcDrops] = {37738},
        },
        [49881] = { -- Slaver's Key
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.npcDrops] = {37701},
        },
        [49921] = { -- Unearthed Memento
            [itemKeys.npcDrops] = {},
        },
        [49944] = { -- Belysra's Talisman
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50054] = { -- SI:7 Briefings
            [itemKeys.npcDrops] = {38033},
        },
        [50134] = { -- Horn of Tal'doren
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50218] = { -- Krennan's Potion of Stealth
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50220] = { -- Half-Burnt Torch
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50237] = { -- Un'Goro Coconut
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50253] = { -- Un'Goro Lasher Seed
            [itemKeys.npcDrops] = {38202},
        },
        [50334] = { -- Rapier of the Gilnean Patriots
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50374] = { -- Unbelievably Sticky Tar
            [itemKeys.npcDrops] = {38307},
        },
        [50405] = { -- Fossil-Finder 3000
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50430] = { -- Scraps of Rotting Meat
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50441] = { -- Garl's Net
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50742] = { -- Tara's Tar Scraper
            [itemKeys.class] = itemClasses.QUEST,
        },
        [50746] = { -- Tara's Tar Scraper
            [itemKeys.class] = itemClasses.QUEST,
        },
        [51549] = { -- Pirate Booty
            [itemKeys.npcDrops] = {},
        },
        [51956] = { -- Blessed Offerings
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52024] = { -- Rockin' Powder
            [itemKeys.npcDrops] = {},
        },
        [52068] = { -- Briny Sea Cucumber
            [itemKeys.npcDrops] = {38933},
        },
        [52481] = { -- Blastshadow's Soulstone
            [itemKeys.npcDrops] = {},
        },
        [52483] = { -- Kaja'Cola Zero-One
            [itemKeys.npcDrops] = {},
        },
        [52505] = { -- Poison Extraction Totem
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52506] = { -- Elemental Goo
            [itemKeys.npcDrops] = {38896,39370,39373,39414,39415,39844,39873,39994,40004,40021,40023,40033,40170,40229,40272,40273,40464,40709,40925,42210,42475,42527,42766,42789,42810,43026,43123,43254,43258,43374,43480,44011,44220,44257,44259,45084,45477,45755,45912,45915,46327,46328,46329,46911,47081,47150,47151,47226,47728,48016,51672,52219,52300,52503,52794,52816,53264},
        },
        [52514] = { -- Thonk's Spyglass
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52537] = { -- Flame Blossom
            [itemKeys.npcDrops] = {},
        },
        [52568] = { -- Twilight Supplies
            [itemKeys.npcDrops] = {},
        },
        [52580] = { -- Fizzle's Orb
            [itemKeys.npcDrops] = {3203},
        },
        [52716] = { -- Twilight Firelance
            [itemKeys.objectDrops] = {202967},
        },
        [52717] = { -- Fiery Leash
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52724] = { -- Twilight Communique
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52725] = { -- Hyjal Battleplans
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52789] = { -- Rusted Skull Key
            [itemKeys.npcDrops] = {},
        },
        [52819] = { -- Frostgale Crystal
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52828] = { -- Orb of Ascension
            [itemKeys.class] = itemClasses.QUEST,
        },
        [52973] = { -- Sunken Cargo
            [itemKeys.npcDrops] = {},
        },
        [52975] = { -- Coilshell Sifter
            [itemKeys.npcDrops] = {39422},
        },
        [53009] = { -- Juniper Berries
            [itemKeys.npcDrops] = {},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [53060] = { -- Frightened Animal
            [itemKeys.npcDrops] = {39997,39998},
        },
        [53107] = { -- Flameseer's Staff
            [itemKeys.class] = itemClasses.QUEST,
        },
        [53139] = { -- Twilight Overseer's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [54461] = { -- Charred Staff Fragment
            [itemKeys.npcDrops] = {},
        },
        [54463] = { -- Flameseer's Staff
            [itemKeys.class] = itemClasses.QUEST,
        },
        [54574] = { -- Hyjal Seedling
            [itemKeys.npcDrops] = {},
        },
        [54745] = { -- Nemesis Shell Fragment
            [itemKeys.npcDrops] = {40340},
        },
        [54788] = { -- Twilight Pick
            [itemKeys.class] = itemClasses.QUEST,
        },
        [54809] = { -- Rocket Car Parts
            [itemKeys.npcDrops] = {},
        },
        [54814] = { -- Talisman of Flame Ascendancy
            [itemKeys.class] = itemClasses.QUEST,
        },
        [54861] = { -- Glimmerdeep Clam
            [itemKeys.npcDrops] = {},
        },
        [55122] = { -- Tholo's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55136] = { -- Tome of Openings
            [itemKeys.npcDrops] = {40844},
        },
        [55137] = { -- Ogre Disguise
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55141] = { -- Spiralung
            [itemKeys.npcDrops] = {39745},
        },
        [55153] = { -- Horn of Cenarius
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55173] = { -- Young Twilight Drake Skull
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55179] = { -- Drums of the Turtle God
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55189] = { -- Hyjal Egg
            [itemKeys.npcDrops] = {},
        },
        [55200] = { -- Horde Cage Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55212] = { -- Gnaws' Tooth
            [itemKeys.npcDrops] = {},
        },
        [55213] = { -- Huntress Illiona's Cage Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55226] = { -- Creature Carcass
            [itemKeys.npcDrops] = {41097,41099,41100,41101,41103,41104,41111,41113,48147,48148},
        },
        [55238] = { -- Concentrated Solvent
            [itemKeys.class] = itemClasses.QUEST,
        },
        [55241] = { -- Incendicite Ore
            [itemKeys.npcDrops] = {},
        },
        [55280] = { -- Deepmoss Venom Sac
            [itemKeys.npcDrops] = {41185,4005,4006,4007},
        },
        [55807] = { -- Alliance's Proposal
            [itemKeys.npcDrops] = {41196},
        },
        [55808] = { -- Horde's Proposal
            [itemKeys.npcDrops] = {41199},
        },
        [55809] = { -- Twilight Armor Plate
            [itemKeys.npcDrops] = {},
        },
        [55989] = { -- Charred Granite Chips
            [itemKeys.npcDrops] = {},
        },
        [56012] = { -- Stone Knife of Sealing
            [itemKeys.class] = itemClasses.QUEST,
        },
        [56091] = { -- Krom'gar Log Book
            [itemKeys.npcDrops] = {},
        },
        [56178] = { -- Duarn's Rope
            [itemKeys.class] = itemClasses.QUEST,
        },
        [56225] = { -- Frozen Artifact
            [itemKeys.npcDrops] = {},
        },
        [56254] = { -- Merciless Head
            [itemKeys.npcDrops] = {41601,41729,41747},
        },
        [56569] = { -- Underlight Nibbler
            [itemKeys.npcDrops] = {41916},
        },
        [56819] = { -- Remora Oil
            [itemKeys.npcDrops] = {42112},
        },
        [56818] = { -- Terrapin Oil
            [itemKeys.npcDrops] = {42108},
        },
        [56820] = { -- Hammerhead Oil
            [itemKeys.npcDrops] = {42113},
        },
        [57175] = { -- Canal Crab
            [itemKeys.npcDrops] = {42339},
        },
        [57197] = { -- Juicy Apple
            [itemKeys.npcDrops] = {},
        },
        [57756] = { -- Murloc Clue
            [itemKeys.npcDrops] = {126,458,515},
        },
        [57765] = { -- Muddy Crawfish
            [itemKeys.npcDrops] = {42548},
        },
        [57766] = { -- Prickly Pear Fruit
            [itemKeys.npcDrops] = {},
        },
        [57789] = { -- Fresh Dirt
            [itemKeys.npcDrops] = {},
        },
        [58120] = { -- Skittering Spiderling
            [itemKeys.npcDrops] = {42689},
        },
        [58141] = { -- Twilight Highlands Coastal Chart
            [itemKeys.npcDrops] = {42638},
        },
        [58167] = { -- Spirit Totem
            [itemKeys.class] = itemClasses.QUEST,
        },
        [58224] = { -- Induction Samophlange
            [itemKeys.objectDrops] = {204091},
        },
        [58228] = { -- Spider Idol
            [itemKeys.npcDrops] = {42857},
        },
        [58252] = { -- Shadraspawn Egg
            [itemKeys.npcDrops] = {},
        },
        [58282] = { -- Eye of Shadra
            [itemKeys.objectDrops] = {204133},
        },
        [58365] = { -- Horn of the Ancients
            [itemKeys.class] = itemClasses.QUEST,
        },
        [58490] = { -- Opened Mosh'Ogg Bounty
            [itemKeys.npcDrops] = {43003},
        },
        [58500] = { -- Jade Crystal Cluster
            [itemKeys.npcDrops] = {},
        },
        [58809] = { -- Rock Lobster
            [itemKeys.npcDrops] = {},
        },
        [58864] = { -- Precious Locket
            [itemKeys.itemDrops] = {58856},
        },
        [58886] = { -- Thunder Stone
            [itemKeys.npcDrops] = {},
        },
        [58899] = { -- Violet Perch
            [itemKeys.npcDrops] = {},
        },
        [58944] = { -- Catapult Part
            [itemKeys.npcDrops] = {}
        },
        [58945] = { -- Toxic Puddlefish
            [itemKeys.npcDrops] = {}
        },
        [58950] = { -- Messner's Cage Key
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.npcDrops] = {}
        },
        [58951] = { -- Giant Furious Pike
            [itemKeys.npcDrops] = {}
        },
        [58958] = { -- Drowned Thunder Lizard Tail
            [itemKeys.npcDrops] = {39464},
        },
        [58959] = { -- Petrified Stone Bat
            [itemKeys.npcDrops] = {43181,43182,43339},
        },
        [58969] = { -- Jorgensen's Cage Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [59033] = { -- Blackrock Lever Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [59057] = { -- Poobah's Tiara
            [itemKeys.npcDrops] = {2521,43417},
        },
        [59058] = { -- Poobah's Scepter
            [itemKeys.npcDrops] = {2521,43417},
        },
        [59059] = { -- Poobah's Slippers
            [itemKeys.npcDrops] = {2521,43417},
        },
        [59060] = { -- Poobah's Diary
            [itemKeys.npcDrops] = {2521,43417},
        },
        [59123] = { -- Verlok Miracle-Grow
            [itemKeys.npcDrops] = {},
        },
        [59146] = { -- Head of Fleet Master Seahorn
            [itemKeys.npcDrops] = {2487},
        },
        [59147] = { -- Cow Head
            [itemKeys.npcDrops] = {43505},
        },
        [59148] = { -- Oversized Pirate Hat
            [itemKeys.npcDrops] = {2663},
        },
        [59261] = { -- Blackrock Holding Pen Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [59361] = { -- A Torn Journal
            [itemKeys.objectDrops] = {204464},
        },
        [59522] = { -- Key of Ilgalar
            [itemKeys.class] = itemClasses.QUEST,
        },
        [60263] = { -- Whispering Blue Stone
            [itemKeys.npcDrops] = {939,941,942,978,979,43910,43911,43912,43913},
        },
        [60291] = { -- Tkashi Fetish
            [itemKeys.npcDrops] = {43977},
        },
        [60297] = { -- Side of Basilisk Meat
            [itemKeys.npcDrops] = {43981},
        },
        [60337] = { -- Verrall River Muck
            [itemKeys.npcDrops] = {},
        },
        [60382] = { -- Mylra's Knife
            [itemKeys.class] = itemClasses.QUEST,
        },
        [60502] = { -- Clever Plant Disguise Kit
            [itemKeys.npcDrops] = {},
        },
        [60503] = { -- Potent Murloc Pheromones
            [itemKeys.npcDrops] = {},
        },
        [60574] = { -- The Upper World Pillar Fragment
            [itemKeys.npcDrops] = {},
        },
        [60680] = { -- S.A.F.E. "Parachute"
            [itemKeys.class] = itemClasses.QUEST,
        },
        [60681] = { -- Cannary's Cache
            [itemKeys.class] = itemClasses.QUEST,
        },
        [60738] = { -- Nascent Elementium Spike
            [itemKeys.npcDrops] = {},
        },
        [60739] = { -- Twilight Slaver's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [60791] = { -- Painite Mote
            [itemKeys.npcDrops] = {},
        },
        [60835] = { -- Depleted Totem
            [itemKeys.class] = itemClasses.QUEST,
        },
        [60850] = { -- Brownfeather Quill
            [itemKeys.npcDrops] = {},
        },
        [60857] = { -- Recovered Supplies
            [itemKeys.npcDrops] = {},
        },
        [60862] = { -- Forsaken Insignia
            [itemKeys.npcDrops] = {45197},
        },
        [60874] = { -- Deathless Sinew
            [itemKeys.npcDrops] = {47131,47132,47134,47135,47136},
        },
        [60875] = { -- Ghostly Essence
            [itemKeys.npcDrops] = {3873,3875,3877,47231,47232},
        },
        [60878] = { -- Silverlaine's Enchanted Crystal
            [itemKeys.npcDrops] = {3887},
        },
        [60879] = { -- Commander's Holy Symbol
            [itemKeys.npcDrops] = {4278},
        },
        [60880] = { -- Springvale's Sharpening Stone
            [itemKeys.npcDrops] = {4278},
        },
        [60881] = { -- Walden's Talisman
            [itemKeys.npcDrops] = {46963},
        },
        [60885] = { -- Silverlaine Family Sword
            [itemKeys.npcDrops] = {3887},
        },
        [61285] = { -- Active Liquid Plague Agent
            [itemKeys.npcDrops] = {8519,8520},
        },
        [61292] = { -- Plague Puffer
            [itemKeys.npcDrops] = {45650},
        },
        [61293] = { -- Infectis Incher
            [itemKeys.npcDrops] = {45655},
        },
        [61294] = { -- Infectis Scuttler
            [itemKeys.npcDrops] = {45657},
        },
        [61310] = { -- Arcane Remnant
            [itemKeys.startQuest] = 27480,
        },
        [61317] = { -- Vermillion Egg
            [itemKeys.npcDrops] = {45651,45682},
        },
        [61376] = { -- Suspended Starlight
            [itemKeys.npcDrops] = {},
        },
        [61505] = { -- Partially Digested Head
            [itemKeys.startQuest] = 27574,
        },
        [61929] = { -- Broken Spectacles
            [itemKeys.npcDrops] = {45874},
        },
        [61923] = { -- Steamwheedle Ditty Bag
            [itemKeys.npcDrops] = {46014},
        },
        [61973] = { -- Highvale Records
            [itemKeys.objectDrops] = {144071},
        },
        [61976] = { -- Orb of the North Star
            [itemKeys.npcDrops] = {},
        },
        [62324] = { -- Wildhammer Food Store
            [itemKeys.npcDrops] = {},
        },
        [62330] = { -- Keg of Thundermar Ale
            [itemKeys.objectDrops] = {206195},
        },
        [62534] = { -- Horn of Ramkahen
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62542] = { -- Mech Control Scrambler
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62544] = { -- Dustbelcher Meat
            [itemKeys.npcDrops] = {},
        },
        [62607] = { -- Titan Activation Device
            [itemKeys.objectDrops] = {},
        },
        [62608] = { -- Uldum Chest Key Code
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62777] = { -- The Desert Fox
            [itemKeys.npcDrops] = {47201},
        },
        [62789] = { -- Trooper Uniform
            [itemKeys.npcDrops] = {47207,47213,47216,47219},
        },
        [62792] = { -- Well-preserved Idol
            [itemKeys.npcDrops] = {},
        },
        [62793] = { -- Furious Spectral Essence
            [itemKeys.npcDrops] = {47220},
        },
        [62806] = { -- Dark Ember
            [itemKeys.npcDrops] = {},
        },
        [62809] = { -- Glassweb Venom
            [itemKeys.npcDrops] = {5856,47281},
        },
        [62817] = { -- Neferset Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62820] = { -- Deadwood Honey Glob
            [itemKeys.objectDrops] = {430016},
        },
        [62822] = { -- Twilight Collar
            [itemKeys.npcDrops] = {5860,5861,5862,8419,47309,47310,47311},
        },
        [62827] = { -- Filled Furnace Flask
            [itemKeys.npcDrops] = {5850,5852,5855,47553},
        },
        [62926] = { -- Twilight Caravan Cargo Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62927] = { -- Twilight's Hammer Gatestone
            [itemKeys.npcDrops] = {},
        },
        [62934] = { -- Ash Chicken
            [itemKeys.npcDrops] = {47278},
        },
        [63027] = { -- Brazier Torch
            [itemKeys.class] = itemClasses.QUEST,
        },
        [63029] = { -- Creeper Egg
            [itemKeys.npcDrops] = {47203},
        },
        [63034] = { -- Dusty Prison Journal
            [itemKeys.npcDrops] = {},
        },
        [63053] = { -- Codemaster's Code
            [itemKeys.npcDrops] = {},
        },
        [63090] = { -- Muckgill's Flipper
            [itemKeys.startQuest] = 28154,
        },
        [63114] = { -- Freed Red Whelpling
            [itemKeys.npcDrops] = {47814},
        },
        [63116] = { -- Freed Green Whelpling
            [itemKeys.npcDrops] = {47820},
        },
        [63117] = { -- Freed Blue Whelpling
            [itemKeys.npcDrops] = {47821},
        },
        [63119] = { -- Freed Bronze Whelpling
            [itemKeys.npcDrops] = {47822},
        },
        [63149] = { -- Cursed Shackles
            [itemKeys.npcDrops] = {},
        },
        [63250] = { -- The Battle for Hillsbrad
            [itemKeys.startQuest] = 28196,
        },
        [63315] = { -- Cellblock Rations
            [itemKeys.npcDrops] = {47550},
        },
        [63333] = { -- Obsidian Piston
            [itemKeys.objectDrops] = {206971,206972,206973,206974},
        },
        [63334] = { -- Stone Power Core
            [itemKeys.objectDrops] = {206971,206972,206973,206974},
        },
        [63335] = { -- Thorium Gearshaft
            [itemKeys.objectDrops] = {206971,206972,206973,206974},
        },
        [63336] = { -- Flux Exhaust Sieve
            [itemKeys.objectDrops] = {206971,206972,206973,206974},
        },
        [63351] = { -- Tahret Dynasty Mallet
            [itemKeys.class] = itemClasses.QUEST,
        },
        [63423] = { -- Fallen Flamekin
            [itemKeys.npcDrops] = {9776,9778,9779},
        },
        [63424] = { -- Worg Cutlet
            [itemKeys.npcDrops] = {9697},
        },
        [63685] = { -- Ancient Copper Scroll
            [itemKeys.npcDrops] = {},
        },
        [63686] = { -- Daggerspine Attack Plans
            [itemKeys.startQuest] = 28356,
        },
        [64313] = { -- Elemental-Imbued Weapon
            [itemKeys.npcDrops] = {8889,8890,8891,8892,8893,8894,8898,8903,24818,24819},
        },
        [64318] = { -- Fine Dark Cloth
            [itemKeys.npcDrops] = {},
        },
        [64380] = { -- Beating Yeti Heart
            [itemKeys.npcDrops] = {2248,48628},
        },
        [64404] = { -- Ruby Crystal Cluster
            [itemKeys.npcDrops] = {48533,48639},
        },
        [64409] = { -- Flamefly
            [itemKeys.npcDrops] = {48671},
        },
        [64585] = { -- Cannon Powder
            [itemKeys.npcDrops] = {49143},
        },
        [64662] = { -- Pure Glacier Ice
            [itemKeys.npcDrops] = {49233},
        },
        [65504] = { -- Deep Alabaster Crystal
            [itemKeys.npcDrops] = {},
        },
        [65507] = { -- Deep Celestite Crystal
            [itemKeys.npcDrops] = {},
        },
        [65734] = { -- Twilight Documents
            [itemKeys.class] = itemClasses.QUEST,
        },
        [67419] = { -- Salvaged Metal
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {182937,182938},
        },
        [68638] = { -- Frostsaber Cub
            [itemKeys.npcDrops] = {51681},
        },
        [68820] = { -- Sputtervalve's Blueprints
            [itemKeys.npcDrops] = {3282,3284,3285,52356,52357},
        },
        [68890] = { -- Dragon Kite 2-Pack
            [itemKeys.class] = itemClasses.QUEST,
        },
        [68937] = { -- Direhammer's Boots
            [itemKeys.objectDrops] = {208376},
        },
        [69027] = { -- Cone of Cold
            [itemKeys.class] = itemClasses.QUEST,
        },
        [69233] = { -- Cone of Cold
            [itemKeys.class] = itemClasses.QUEST,
        },
        [69238] = { -- Timeless Eye
            [itemKeys.objectDrops] = {430024},
        },
        [69765] = { -- Lucifern
            [itemKeys.npcDrops] = {},
        },
        [69812] = { -- Flame Druid Reagent Pouch
            [itemKeys.npcDrops] = {},
        },
        [69813] = { -- Flame Druid Idol
            [itemKeys.npcDrops] = {},
        },
        [69815] = { -- Seething Cinder
            [itemKeys.class] = itemClasses.QUEST,
        },
        [69845] = { -- Fire Hawk Hatchling
            [itemKeys.npcDrops] = {53275},
        },
        [69905] = { -- Giant Flesh-Eating Tadpole
            [itemKeys.npcDrops] = {},
        },
        [69911] = { -- Squirming Slime Mold
            [itemKeys.npcDrops] = {53517},
        },
        [69913] = { -- Aquinne's Moon Pendant
            [itemKeys.itemDrops] = {69914},
        },
        [69914] = { -- Giant Catfish
            [itemKeys.npcDrops] = {},
        },
        [69915] = { -- Baby Octopus
            [itemKeys.npcDrops] = {53522},
        },
        [69918] = { -- Brightwater Snail
            [itemKeys.npcDrops] = {53526},
        },
        [69931] = { -- Arctic Char
            [itemKeys.npcDrops] = {},
        },
        [69935] = { -- Poshken's Ring
            [itemKeys.itemDrops] = {69956},
        },
        [69977] = { -- Stonebull Crayfish
            [itemKeys.npcDrops] = {53561},
        },
        [69982] = { -- Dun Morogh Chicken
            [itemKeys.npcDrops] = {53568},
        },
        [69984] = { -- Bag o' Sheep Innards
            [itemKeys.vendors] = {5124},
        },
        [70000] = { -- Succulent Sweet Potatoes
            [itemKeys.objectDrops] = {208887},
        },
        [70001] = { -- Savory Spices
            [itemKeys.objectDrops] = {208888},
        },
        [70002] = { -- Fresh-Caught Fish
            [itemKeys.objectDrops] = {208889},
        },
        [70003] = { -- Fresh-Hunted Fowl
            [itemKeys.objectDrops] = {208890},
        },
        [70928] = { -- Gift Receipt
            [itemKeys.class] = itemClasses.QUEST,
        },
        [70932] = { -- Gift Receipt
            [itemKeys.class] = itemClasses.QUEST,
        },
        [71141] = { -- Eternal Ember
            [itemKeys.class] = itemClasses.QUEST,
        },
        [71716] = { -- Soothsayer's Runes
            [itemKeys.class] = itemClasses.QUEST,
        },
        [72160] = { -- Hellfire Supplies
            [itemKeys.objectDrops] = {209347},
        },
        [73269] = { -- Great Sea Herring
            [itemKeys.npcDrops] = {},
        },
        [224452] = { -- Teleport Scroll: Stormwind
            [itemKeys.name] = "Teleport Scroll: Stormwind",
            [itemKeys.class] = itemClasses.QUEST,
        },
        [224458] = { -- Teleport Scroll: Orgrimmar
            [itemKeys.name] = "Teleport Scroll: Orgrimmar",
            [itemKeys.class] = itemClasses.QUEST,
        },
    }
end

-- This should allow manual fix for item availability
function CataItemFixes:LoadFactionFixes()
    local itemKeys = QuestieDB.itemKeys

    local itemFixesHorde = {
        [17662] = { -- Stolen Treats
            [itemKeys.objectDrops] = {209506},
        },
        [56188] = { -- Rescue Flare
            [itemKeys.objectDrops] = {203410},
        },
        [71034] = { -- Windswept Balloon
            [itemKeys.objectDrops] = {209058},
        },
    }

    local itemFixesAlliance = {
        [17662] = { -- Stolen Treats
            [itemKeys.objectDrops] = {209497},
        },
        [56188] = { -- Rescue Flare
            [itemKeys.objectDrops] = {203403},
        },
        [71034] = { -- Windswept Balloon
            [itemKeys.objectDrops] = {209242},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end
