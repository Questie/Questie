---@class MopItemFixes
local MopItemFixes = QuestieLoader:CreateModule("MopItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [10641] = { -- Moonpetal Lily
            [itemKeys.objectDrops] = {207346},
        },
        [71635] = { -- Imbued Crystal
            [itemKeys.npcDrops] = {4832,9018,10264,10813,11496,12201,12258,17377,17977,18344,24664,26794,28923,36658,39732},
        },
        [71637] = { -- Mysterious Grimoire
            [itemKeys.npcDrops] = {3671,4421,5710,7795,9019,18373,18732,19220,26530,26631,29310,39425,46964,54938},
        },
        [71638] = { -- Ornate Weapon
            [itemKeys.npcDrops] = {2748,4420,7800,9568,10363,11486,12236,27975,29306,29308,39698,40177,44577,45412,46383,54968},
        },
        [72589] = { -- Ripe Orange
            [itemKeys.npcDrops] = {54930},
            [itemKeys.objectDrops] = {209436},
        },
        [73193] = { -- Blushleaf Extrac
            [itemKeys.objectDrops] = {209550},
        },
        [74033] = { -- Ancient Hozen Skull
            [itemKeys.objectDrops] = {209595},
        },
        [74160] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74161] = { -- Zin\'Jun\'s Left Eye
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74162] = { -- Zin\'Jun\'s Right Eye
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74163] = { -- Snuff\'s Corpse
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74258] = { -- Staff of Pei-Zhi
            [itemKeys.objectDrops] = {209629},
        },
        [74260] = { -- Bamboo Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [74296] = { -- Stolen Carrot
            [itemKeys.npcDrops] = {55504},
        },
        [74615] = { -- Paint Soaked Brush
            [itemKeys.npcDrops] = {55601},
            [itemKeys.objectDrops] = {},
        },
        [74621] = { -- Viscous Chlorophyll
            [itemKeys.npcDrops] = {55610},
        },
        [74623] = { -- Emergency Supplies
            [itemKeys.npcDrops] = {62930},
        },
        [74760] = { -- Chipped Ritual Bowl
            [itemKeys.objectDrops] = {209700},
        },
        [74761] = { -- Pungent Ritual Candle
            [itemKeys.objectDrops] = {209701},
        },
        [74762] = { -- Jade Cong
            [itemKeys.objectDrops] = {209699},
        },
        [74763] = { -- Spirit Bottle
            [itemKeys.npcDrops] = {55291,65779},
        },
        [74843] = { -- Scallions
            [itemKeys.npcDrops] = {59547,59751,59808,61216,61239,61240,61242,63164,63165,63521,63536,63997,64194,64196,64197,65317},
        },
        [75023] = { -- Pristine Silk Strand
            [itemKeys.objectDrops] = {209826},
        },
        [75202] = { -- Speckled Trout
            [itemKeys.npcDrops] = {56180},
        },
        [75208] = { -- Rancher's Lariat
            [itemKeys.class] = itemClasses.QUEST,
        },
        [75214] = { -- Tidemist Cap
            [itemKeys.objectDrops] = {209825},
        },
        [75219] = { -- Freshly Fallen Petal
            [itemKeys.objectDrops] = {209836},
        },
        [75256] = { -- Pang's Extra-Spicy Tofu
            [itemKeys.objectDrops] = {209842},
        },
        [75258] = { -- Ang's Summer Watermelon
            [itemKeys.objectDrops] = {209843},
        },
        [75259] = { -- Ang's Giant Pink Turnip
            [itemKeys.objectDrops] = {209844},
        },
        [75271] = { -- Jian
            [itemKeys.npcDrops] = {56253},
        },
        [75272] = { -- Ling
            [itemKeys.npcDrops] = {56254},
        },
        [75273] = { -- Smelly
            [itemKeys.npcDrops] = {56255},
        },
        [75275] = { -- Mushan Shoulder Steak
            [itemKeys.npcDrops] = {56239},
        },
        [75276] = { -- Turtle Meat Scrap
            [itemKeys.npcDrops] = {56256},
        },
        [76107] = { -- Pristine Crocolisk Eye
            [itemKeys.npcDrops] = {54558},
        },
        [76115] = { -- Amberfly Wing
            [itemKeys.npcDrops] = {54559},
        },
        [76173] = { -- Bug Leg
            [itemKeys.npcDrops] = {56283},
        },
        [76209] = { -- Chunk of Jade
            [itemKeys.npcDrops] = {56349},
            [itemKeys.objectDrops] = {209863},
        },
        [76225] = { -- Fistful of Bird Guts
            [itemKeys.npcDrops] = {56396},
        },
        [76260] = { -- Exploded Slicky
            [itemKeys.objectDrops] = {209877},
        },
        [76297] = { -- Stolen Turnip
            [itemKeys.objectDrops] = {209891},
        },
        [76334] = { -- Meadow Marigold
            [itemKeys.objectDrops] = {209907},
        },
        [76335] = { -- Vial of Animal Blood
            [itemKeys.npcDrops] = {56523,56524,56526,56531,56532},
        },
        [76336] = { -- Nazgrim's Grog
            [itemKeys.class] = itemClasses.QUEST,
        },
        [76337] = { -- Stolen Sack of Hops
            [itemKeys.objectDrops] = {211696},
        },
        [76350] = { -- Li Li's Wishing-Stone
            [itemKeys.class] = itemClasses.QUEST,
        },
        [76362] = { -- Mudmug's Vial
            [itemKeys.class] = itemClasses.QUEST,
        },
        [76370] = { -- Orange-Painted Turnip
            [itemKeys.class] = itemClasses.QUEST,
        },
        [76420] = { -- Snapper Steak
            [itemKeys.npcDrops] = {56447},
        },
        [76499] = { -- Jademoon Leaf
            [itemKeys.objectDrops] = {209952},
        },
        [76501] = { -- Emperor Tern Egg
            [itemKeys.objectDrops] = {209953},
        },
        [76503] = { -- Whitefisher Crane Egg
            [itemKeys.objectDrops] = {209954},
        },
        [76516] = { -- Hornbill Strider Egg
            [itemKeys.objectDrops] = {209955},
        },
        [76973] = { -- Sprig of Dreamleaf
            [itemKeys.objectDrops] = {209987},
        },
        [77033] = { -- Sack of Grain
            [itemKeys.objectDrops] = {210001,210002},
        },
        [77034] = { -- Malted Cave Barley
            [itemKeys.objectDrops] = {210037},
        },
        [77452] = { -- Defender's Arrow
            [itemKeys.objectDrops] = {210087},
        },
        [77455] = { -- Mulberry Leaves
            [itemKeys.objectDrops] = {210080},
        },
        [77456] = { -- Raw Silk
            [itemKeys.objectDrops] = {210088},
        },
        [78911] = { -- Intact Skitterer Glands
            [itemKeys.npcDrops] = {58067},
        },
        [78917] = { -- Dojani Orders
            [itemKeys.npcDrops] = {58165},
        },
        [78918] = { -- Imperial Lotus Leaves
            [itemKeys.objectDrops] = {210209},
        },
        [78934] = { -- The Water of Youth
            [itemKeys.objectDrops] = {223818},
        },
        [78942] = { -- Jar of Pigment
            [itemKeys.objectDrops] = {210228},
        },
        [78958] = { -- Pillaged Jinyu Loot
            [itemKeys.npcDrops] = {58273,58274},
        },
        [78959] = { -- Serpent Egg
            [itemKeys.objectDrops] = {210238,210239,210240},
        },
        [79030] = { -- Honeycomb
            [itemKeys.npcDrops] = {58363},
        },
        [79049] = { -- Serpentrider Relic
            [itemKeys.npcDrops] = {},
        },
        [79058] = { -- Darkhide's Head
            [itemKeys.npcDrops] = {58435},
        },
        [79059] = { -- Intact Tortoise Shell
            [itemKeys.npcDrops] = {58431},
        },
        [79104] = { -- Rusty Watering Can
            [itemKeys.class] = itemClasses.QUEST,
        },
        [79120] = { -- Mogu Artifact
            [itemKeys.objectDrops] = {212935},
        },
        [79197] = { -- Glade Glimmer
            [itemKeys.npcDrops] = {57301},
        },
        [79199] = { -- Murkscale Head
            [itemKeys.npcDrops] = {58631},
        },
        [79238] = { -- Enormous Crocolisk Tail
            [itemKeys.startQuest] = 30275,
        },
        [79244] = { -- Fairlands Gazelle Meat
            [itemKeys.npcDrops] = {58454},
        },
        [79246] = { -- Delicate Blossom Petals
            [itemKeys.objectDrops] = {210537,210538,210539},
        },
        [79250] = { -- Fresh Pomfruit
            [itemKeys.npcDrops] = {58767},
        },
        [79252] = { -- Mogu Poisoned Blade
            [itemKeys.npcDrops] = {58377,65598},
        },
        [79269] = { -- Marsh Lily
            [itemKeys.objectDrops] = {210565},
        },
        [79332] = { -- Sentinel Scout's Report
            [itemKeys.npcDrops] = {59137},
        },
        [79745] = { -- Sunwalker Scout's Report
            [itemKeys.npcDrops] = {59136},
        },
        [79807] = { -- Waterspeaker's Staff
            [itemKeys.npcDrops] = {55110},
        },
        [79808] = { -- Ceremonial Robes
            [itemKeys.npcDrops] = {55110},
        },
        [79809] = { -- Jade Crown
            [itemKeys.npcDrops] = {55110},
        },
        [79810] = { -- Rosewood Beads
            [itemKeys.npcDrops] = {55110},
        },
        [79811] = { -- Glassfin Heirloom
            [itemKeys.npcDrops] = {56233},
        },
        [79824] = { -- Stolen Vegetable
            [itemKeys.objectDrops] = {210763,210764,210765,210766,210767,210768,210769},
        },
        [79827] = { -- Authentic Valley Stir Fry
            [itemKeys.npcDrops] = {59124},
        },
        [79828] = { -- Yak Statuette
            [itemKeys.npcDrops] = {59124},
        },
        [79833] = { -- Shadelight Truffle
            [itemKeys.objectDrops] = {210810,210811,210812},
        },
        [79867] = { -- Fatty Goatsteak
            [itemKeys.npcDrops] = {59139},
        },
        [79870] = { -- Yu-Ping Soup
            [itemKeys.objectDrops] = {210873},
        },
        [79871] = { -- Spicy Shrimp Dumplings
            [itemKeys.npcDrops] = {59119,59120,59121,59122,59123,59124,59125,59126,59127,59128,59129,59130,59131,59132,59133,59134,59135},
        },
        [79875] = { -- Song of the Vale
            [itemKeys.objectDrops] = {209582},
        },
        [79884] = { -- Bucket of Slicky Water
            [itemKeys.objectDrops] = {209974},
        },
        [79894] = { -- Mushan Tail Stew
            [itemKeys.objectDrops] = {214463},
        },
        [79952] = { -- Pungent Sprite Needles
            [itemKeys.npcDrops] = {55593},
        },
        [80013] = { -- Shademaster Kiryn's Report
            [itemKeys.npcDrops] = {56841},
        },
        [80014] = { -- Rivett Clutchpop's Report
            [itemKeys.npcDrops] = {59305},
        },
        [80015] = { -- Shokia's Report
            [itemKeys.npcDrops] = {56838},
        },
        [80061] = { -- Riko's Report
            [itemKeys.npcDrops] = {56840},
        },
        [80074] = { -- Celestial Jade
            [itemKeys.objectDrops] = {210921},
        },
        [80122] = { -- Spideroot
            [itemKeys.objectDrops] = {210945,211117},
        },
        [80213] = { -- Spicemaster Jin Jao\'s Payment
            [itemKeys.npcDrops] = {59581},
        },
        [80214] = { -- Trader Jambeezi\'s Payment
            [itemKeys.npcDrops] = {59583},
        },
        [80215] = { -- Innkeeper Lei Lan\'s Payment
            [itemKeys.npcDrops] = {59582},
        },
        [80216] = { -- Lolo Lio\'s Payment
            [itemKeys.npcDrops] = {59585},
        },
        [80227] = { -- Root Vegetable
            [itemKeys.objectDrops] = {211017,211018,211019},
        },
        [80228] = { -- Enormous Cattail Grouper Tooth
            [itemKeys.npcDrops] = {59639},
        },
        [80230] = {  -- Cast Iron Pot
            [itemKeys.objectDrops] = {211023},
        },
        [80234] = {  -- Yoon's Apple
            [itemKeys.objectDrops] = {211020},
        },
        [80235] = {  -- Yoon's Craneberry
            [itemKeys.objectDrops] = {211022},
        },
        [80236] = {  -- Apple-Berry Hooch
            [itemKeys.vendors] = {58717},
        },
        [80241] = { -- Muskpaw's Keepsake
            [itemKeys.startQuest] = 30582,
        },
        [80277] = { -- Jagged Abalone Meat
            [itemKeys.objectDrops] = {211118},
        },
        [80294] = { -- Mogu Relic
            [itemKeys.objectDrops] = {211143},
        },
        [80302] = { -- EZ-Gro Green Cabbage Seeds
            [itemKeys.class] = itemClasses.QUEST,
        },
        [80303] = { -- Pristine Crane Egg
            [itemKeys.objectDrops] = {211160},
        },
        [80307] = { -- Grummlepack
            [itemKeys.npcDrops] = {59408,59896,59897,59898},
        },
        [80311] = { -- Filled Oil Vial
            [itemKeys.objectDrops] = {211530,211531},
        },
        [80314] = { -- EZ-Gro Green Cabbage
            [itemKeys.npcDrops] = {59833},
        },
        [80315] = { -- Stolen Supplies
            [itemKeys.objectDrops] = {211266,211268,211269,211270},
        },
        [80316] = { -- Lucky Virmen\'s Foot
            [itemKeys.npcDrops] = {59693,59967},
        },
        [80317] = { -- Lucky Yak Shoe
            [itemKeys.npcDrops] = {59693,59967},
        },
        [80318] = { -- Lucky Four Winds Clover
            [itemKeys.npcDrops] = {59693,59967},
        },
        [80319] = { -- Lucky "Gold" Coin
            [itemKeys.npcDrops] = {59693,59967},
        },
        [80429] = { -- Corpse of Ko Ko
            [itemKeys.npcDrops] = {59430},
        },
        [80430] = { -- Corpse of Tak Tak
            [itemKeys.npcDrops] = {59958},
        },
        [80437] = { -- Armored Carp
            [itemKeys.npcDrops] = {59936},
        },
        [80511] = { -- Revelite Crystal
            [itemKeys.objectDrops] = {211306},
        },
        [80528] = { -- Explosives Barrel
            [itemKeys.objectDrops] = {211312},
        },
        [80591] = { -- Scallion Seeds
            [itemKeys.vendors] = {58718},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [80677] = { -- Emerald Tailfeather
            [itemKeys.npcDrops] = {60200},
        },
        [80678] = { -- Crimson Tailfeather
            [itemKeys.npcDrops] = {60198},
        },
        [80679] = { -- Dusky Tailfeather
            [itemKeys.npcDrops] = {60196},
        },
        [80685] = { -- Spare Plank
            [itemKeys.objectDrops] = {211376},
        },
        [80804] = { -- Tough Kelp
            [itemKeys.objectDrops] = {211382},
        },
        [80817] = { -- Buried Hozen Treasure
            [itemKeys.objectDrops] = {211420},
        },
        [80827] = { -- Confusing Treasure Map
            [itemKeys.npcDrops] = {60299,60357},
            [itemKeys.startQuest] = 30675;
        },
        [80907] = { -- Opalescent Blue Crab Shell
            [itemKeys.npcDrops] = {60437,63722},
        },
        [81054] = { -- Kafa'kota Berry
            [itemKeys.objectDrops] = {211454,211480},
        },
        [81116] = { -- Suncrawler
            [itemKeys.objectDrops] = {211474},
        },
        [81174] = { -- Dark Pitch
            [itemKeys.objectDrops] = {211506,211507},
        },
        [81176] = { -- Mist-Shaman's Torch
            [itemKeys.npcDrops] = {60698},
        },
        [81177] = { -- Pandaren Healing Draught
            [itemKeys.objectDrops] = {211510},
        },
        [81250] = { -- Snarlvine
            [itemKeys.objectDrops] = {211517,211518},
        },
        [81261] = { -- Stolen Pandaren Spices
            [itemKeys.objectDrops] = {211521},
            [itemKeys.npcDrops] = {60560,60846},
        },
        [81269] = { -- Waterfall-Polished Stone
            [itemKeys.objectDrops] = {211526},
        },
        [81293] = { -- Stolen Luckydos
            [itemKeys.objectDrops] = {211536,211537,211538},
        },
        [81355] = { -- Palewind Totem
            [itemKeys.objectDrops] = {211566},
        },
        [81385] = { -- Stolen Inkgill Ritual Staff
            [itemKeys.npcDrops] = {59180},
        },
        [82298] = { -- Handful of Volatile Blooms
            [itemKeys.objectDrops] = {211684},
        },
        [82299] = { -- Blood-Stained Blade
            [itemKeys.npcDrops] = {60580},
        },
        [82332] = { -- Father's Crossbow
            [itemKeys.npcDrops] = {61540},
        },
        [82342] = { -- Violet Citron
            [itemKeys.objectDrops] = {211719,211721},
        },
        [82353] = { -- Sra'thik Weapon
            [itemKeys.objectDrops] = {211765,211766},
        },
        [82389] = { -- Mao-Willow
            [itemKeys.objectDrops] = {211779},
        },
        [82393] = { -- Shen Dynasty Rubbing
            [itemKeys.objectDrops] = {211770},
        },
        [82394] = { -- Qiang Dynasty Rubbing
            [itemKeys.objectDrops] = {211794},
        },
        [82395] = { -- Wai Dynasty Rubbing
            [itemKeys.objectDrops] = {211790},
        },
        [82722] = { -- Krik'thik Limb
            [itemKeys.objectDrops] = {211863},
        },
        [82723] = { -- Volatile Dread Orb
            [itemKeys.npcDrops] = {61302,61811},
            [itemKeys.objectDrops] = {211871,211872,211873},
        },
        [82764] = { -- Bottom Fragment of Lei Shen\'s Tablet
            [itemKeys.objectDrops] = {211967},
        },
        [82799] = { -- Yaungol Oil Barrel
            [itemKeys.objectDrops] = {212003},
        },
        [82864] = { -- Living Amber
            [itemKeys.objectDrops] = {212009,212012},
        },
        [82867] = { -- Mantid Relic
            [itemKeys.objectDrops] = {212078,212079},
        },
        [82869] = { -- Meaty Turtle Haunch
            [itemKeys.npcDrops] = {62160},
        },
        [82870] = { -- Strange Relic
            [itemKeys.startQuest] = 31023,
            [itemKeys.npcDrops] = {61970,63176},
        },
        [83024] = { -- Shado-Pan Fire Arrows
            [itemKeys.objectDrops] = {212135,212136},
        },
        [83075] = { -- Sapfly Bits
            [itemKeys.npcDrops] = {62386},
        },
        [83076] = { -- Between a Saurok and a Hard Place
            [itemKeys.startQuest] = 31055,
        },
        [83129] = { -- Cloudrunner Egg
            [itemKeys.objectDrops] = {212230,214479,214480,214481},
        },
        [83135] = { -- Amber Blade
            [itemKeys.npcDrops] = {62563,62749,65995},
        },
        [83769] = { -- Between a Saurok and a Hard Place
            [itemKeys.startQuest] = 31055,
        },
        [83770] = { -- Hozen in the Mist
            [itemKeys.startQuest] = 31093,
        },
        [83771] = { -- Fish Tales
            [itemKeys.startQuest] = 31094,
        },
        [83772] = { -- The Dark Heart of the Mogu
            [itemKeys.startQuest] = 31095,
        },
        [83773] = { -- Heart of the Mantid Swarm
            [itemKeys.startQuest] = 31097,
        },
        [83774] = { -- What is Worth Fighting For
            [itemKeys.startQuest] = 31096,
        },
        [83777] = { -- The Song of the Yaungol
            [itemKeys.startQuest] = 31100,
        },
        [83779] = { -- The Seven Burdens of Shaohao
            [itemKeys.startQuest] = 31102,
        },
        [83780] = { -- The Ballad of Liu Lang
            [itemKeys.startQuest] = 31103,
        },
        [84107] = { -- Large Mushan Tooth
            [itemKeys.npcDrops] = {62760},
        },
        [84111] = { -- Blade of Kz'Kzik
            [itemKeys.npcDrops] = {62832},
        },
        [84118] = { -- Fragrant Corewood
            [itemKeys.npcDrops] = {62876},
        },
        [84239] = { -- Flitterling Dust
            [itemKeys.npcDrops] = {62764},
        },
        [84240] = { -- Fresh Whitepetal Worm
            [itemKeys.objectDrops] = {212742},
        },
        [84241] = { -- Whitepetal Reed
            [itemKeys.objectDrops] = {212744},
        },
        [84656] = { -- Stunned Whitepetal Carp
            [itemKeys.npcDrops] = {62984},
        },
        [84779] = { -- Chunk of Solidified Amber
            [itemKeys.objectDrops] = {212902},
        },
        [85159] = { -- Amber-Filled Jar
            [itemKeys.objectDrops] = {212923},
        },
        [85230] = { -- Sea Monarch Chunks
            [itemKeys.class] = itemClasses.QUEST,
        },
        [85282] = { -- Tiger Flank
            [itemKeys.npcDrops] = {63537,63538,65612,67085},
        },
        [85782] = { -- Mistfall Water Bucket
            [itemKeys.objectDrops] = {213369},
        },
        [85783] = { -- Captain Jack's Head
            [itemKeys.npcDrops] = {63809},
            [itemKeys.startQuest] = 31261,
        },
        [85784] = { -- Alliance Service Medallion
            [itemKeys.npcDrops] = {63764,63782},
        },
        [85854] = { -- The Needlebeak
            [itemKeys.npcDrops] = {63796},
        },
        [85869] = { -- Potion of Mazu's Breath
            [itemKeys.class] = itemClasses.QUEST,
        },
        [85886] = { -- Sealed Charter Tube
            [itemKeys.objectDrops] = {213454},
        },
        [85955] = { -- Dog's Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [85981] = { -- Black Market Merchandise
            [itemKeys.objectDrops] = {213516,213517,213518,213519,213520},
        },
        [85998] = { -- Thresher Jaw
            [itemKeys.npcDrops] = {63944},
        },
        [86404] = { -- Old Map
            [itemKeys.npcDrops] = {59639},
        },
        [86431] = { -- Stormstout Secrets
            [itemKeys.objectDrops] = {213795},
        },
        [86489] = { -- Succulent Turtle Filet
            [itemKeys.npcDrops] = {63981},
        },
        [86542] = { -- Flying Tiger Gourami
            [itemKeys.startQuest] = 31442,
        },
        [86544] = { -- Spinefish Alpha
            [itemKeys.startQuest] = 31444,
        },
        [86545] = { -- Mimic Octopus
            [itemKeys.startQuest] = 31446,
        },
        [86598] = { -- Vor'thik Eggs
            [itemKeys.objectDrops] = {214170},
        },
        [86616] = { -- Dread Amber Focus
            [itemKeys.npcDrops] = {62814},
        },
        [87282] = { -- Blade of the Anointed
            [itemKeys.objectDrops] = {214284},
        },
        [87389] = { -- Blade of the Anointed
            [itemKeys.objectDrops] = {214284},
        },
        [87401] = { -- Needler Wings
            [itemKeys.npcDrops] = {64714},
        },
        [87813] = { -- Zan'thik Shackles
            [itemKeys.npcDrops] = {64970},
        },
        [87871] = { -- Massive Kyparite Core
            [itemKeys.npcDrops] = {65229},
        },
        [87874] = { -- Kyparite Shards
            [itemKeys.npcDrops] = {65231},
        },
        [88538] = { -- Sha-Haunted Crystal
            [itemKeys.startQuest] = 31661,
        },
        [89054] = { -- Stolen Boots
            [itemKeys.objectDrops] = {214865,214866,214867,214868},
        },
        [89163] = { -- Requisitioned Firework Launcher
            [itemKeys.class] = itemClasses.QUEST,
        },
        [89603] = { -- Encoded Captain's Log
            [itemKeys.npcDrops] = {66148},
        },
        [89812] = { -- "Jinyu Princess" Irrigation System
            [itemKeys.startQuest] = 31936,
        },
        [89813] = { -- "Thunder King" Pest Repellers
            [itemKeys.startQuest] = 31937,
        },
        [89814] = { -- "Earth-Slasher" Master Plow
            [itemKeys.startQuest] = 31938,
        },
        [244172] = { -- Eternal Blossom
            [itemKeys.name] = "Eternal Blossom",
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.objectDrops] = {210537,210538,210539},
        },
    }
end
