---@class CataItemFixes
local CataItemFixes = QuestieLoader:CreateModule("CataItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function CataItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [1357] = { -- Captain Sander's Treasure Map
            [itemKeys.startQuest] = 26353,
        },
        [2629] = { -- Intrepid Strongbox Key
            [itemKeys.npcDrops] = {41429},
        },
        [2633] = { -- Jungle Remedy
            [itemKeys.npcDrops] = {937,940,941,942},
        },
        [2859] = { -- Vile Fin Scale
            [itemKeys.npcDrops] = {1541,1543,1544,1545},
        },
        [3082] = { -- Dargol's Skull
            [itemKeys.startQuest] = 25030,
        },
        [4106] = { -- Tumbled Crystal
            [itemKeys.npcDrops] = {1096,4260},
        },
        [4506] = { -- Stromgarde Badge
            [itemKeys.npcDrops] = {2588,2590,2591,24477},
        },
        [5084] = { -- Cap'n Garvey's Head
            [itemKeys.npcDrops] = {34750},
        },
        [5169] = { -- Timberling Sprout
            [itemKeys.objectDrops] = {4608},
        },
        [5382] = { -- Anaya's Pendant
            [itemKeys.npcDrops] = {33181},
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
        [8170] = { -- Rugged Leather
            [itemKeys.vendors] = {},
        },
        [8705] = { -- OOX-22/FE Distress Beacon
            [itemKeys.startQuest] = 25475,
        },
        [10441] = { -- Glowing Shard
            [itemKeys.startQuest] = 0,
        },
        [10458] = { -- Prayer to Elune
            [itemKeys.npcDrops] = {},
        },
        [11114] = { -- Dinosaur Bone
            [itemKeys.npcDrops] = {6501,6502,6503,6504,9162,9163,9164},
        },
        [11818] = { -- Grimesilt Outhouse Key
            [itemKeys.startQuest] = 0,
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
        [16790] = { -- Damp Note
            [itemKeys.startQuest] = 0,
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
        [19424] = { -- Sayge's Fortune #24
            [itemKeys.startQuest] = 0,
        },
        [18960] = { -- Lookout's Spyglass
            [itemKeys.npcDrops] = {5840},
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
        [23798] = { -- Diabolical Plans
            [itemKeys.npcDrops] = {6073},
        },
        [24025] = { -- Deathclaw's Paw
            [itemKeys.npcDrops] = {17661},
        },
        [24026] = { -- Elder Brown Bear Flank
            [itemKeys.npcDrops] = {17348},
        },
        [24049] = { -- Ysera's Tear
            [itemKeys.npcDrops] = {},
        },
        [24416] = { -- Corrupted Flower
            [itemKeys.npcDrops] = {},
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
        [38567] = { -- Maraudine Prisoner Manifest
            [itemKeys.startQuest] = 14330,
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
        [45027] = { -- Tuft of Mottled Doe Hair
            [itemKeys.npcDrops] = {33313},
        },
        [45042] = { -- Feero's Holy Hammer
            [itemKeys.npcDrops] = {33348},
        },
        [45043] = { -- The Purifier's Prayer Book
            [itemKeys.npcDrops] = {33347},
        },
        [45066] = { -- Bathed Concoction
            [itemKeys.objectDrops] = {194651},
        },
        [45573] = { -- The Forest HEart
            [itemKeys.npcDrops] = {},
        },
        [45885] = { -- Thistle Bear Fur
            [itemKeys.npcDrops] = {33978},
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
        [49164] = { -- Cenarion Supply Crate
            [itemKeys.npcDrops] = {},
        },
        [49172] = { -- Simmering Water Droplet
            [itemKeys.npcDrops] = {36131},
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
        [56178] = { -- Duarn's Rope
            [itemKeys.class] = itemClasses.QUEST,
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
        [60297] = { -- Side of Basilisk Meat
            [itemKeys.npcDrops] = {43981},
        },
        [60337] = { -- Verrall River Muck
            [itemKeys.npcDrops] = {},
        },
        [60382] = { -- Mylra's Knife
            [itemKeys.class] = itemClasses.QUEST,
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
        [60879] = { -- Commander's Holy Symbol
            [itemKeys.npcDrops] = {4278},
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
        [61317] = { -- Vermillion Egg
            [itemKeys.npcDrops] = {45651,45682},
        },
        [61376] = { -- Suspended Starlight
            [itemKeys.npcDrops] = {},
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
        [62817] = { -- Neferset Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62820] = { -- Deadwood Honey Glob
            [itemKeys.objectDrops] = {460015},
        },
        [62822] = { -- Twilight Collar
            [itemKeys.npcDrops] = {5860,5861,5862,8419,47309,47310,47311},
        },
        [62926] = { -- Twilight Caravan Cargo Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [62927] = { -- Twilight's Hammer Gatestone
            [itemKeys.npcDrops] = {},
        },
        [63027] = { -- Brazier Torch
            [itemKeys.class] = itemClasses.QUEST,
        },
        [63034] = { -- Dusty Prison Journal
            [itemKeys.npcDrops] = {},
        },
        [63149] = { -- Cursed Shackles
            [itemKeys.npcDrops] = {},
        },
        [63315] = { -- Cellblock Rations
            [itemKeys.npcDrops] = {47550},
        },
        [63333] = { -- Obsidian Piston
            [itemKeys.npcDrops] = {7039},
        },
        [63334] = { -- Stone Power Core
            [itemKeys.npcDrops] = {7039},
        },
        [63335] = { -- Thorium Gearshaft
            [itemKeys.npcDrops] = {7039},
        },
        [63336] = { -- Flux Exhaust Sieve
            [itemKeys.npcDrops] = {7039},
        },
        [63351] = { -- Tahret Dynasty Mallet
            [itemKeys.class] = itemClasses.QUEST,
        },
        [63685] = { -- Ancient Copper Scroll
            [itemKeys.npcDrops] = {},
        },
        [64318] = { -- Fine Dark Cloth
            [itemKeys.npcDrops] = {},
        },
        [64404] = { -- Ruby Crystal Cluster
            [itemKeys.npcDrops] = {48533,48639},
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
        [68638] = { -- Frostsaber Cub
            [itemKeys.npcDrops] = {51681},
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
        [73269] = { -- Great Sea Herring
            [itemKeys.npcDrops] = {},
        },
    }
end

-- This should allow manual fix for item availability
function CataItemFixes:LoadFactionFixes()
    local itemKeys = QuestieDB.itemKeys

    local itemFixesHorde = {
        [56188] = { -- Rescue Flare
            [itemKeys.objectDrops] = {203410},
        },
        [71034] = { -- Windswept Balloon
            [itemKeys.objectDrops] = {209058},
        },
    }

    local itemFixesAlliance = {
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
