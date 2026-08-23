---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieTBCItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [2633] = { -- Jungle Remedy
            [itemKeys.npcDrops] = {937,940,941,942},
        },
        [4503] = { -- Witherbark Tusk
            [itemKeys.npcDrops] = {2557,2556,2555,2553,2552,2558,2554},
        },
        [5445] = { -- Ring of Zoram
            [itemKeys.npcDrops] = {3943},
        },
        [5060] = { -- Thieves' Tools
            [itemKeys.vendors] = {1325,1326,1457,2622,3090,3135,3334,3490,3542,3551,3561,3969,4585,5139,5169,6779,7166,10364,12096,12097,15175,16268,16683,16829,18006,18019,20121},
        },
        [5359] = { -- Lorgalis Manuscript
            [itemKeys.npcDrops] = {},
        },
        [5883] = { -- Forked Mudrock Tongue
            [itemKeys.npcDrops] = {4397},
        },
        [5959] = { -- Acidic Venom Sac
            [itemKeys.npcDrops] = {4376,4378,4379,4380},
        },
        [6083] = { -- Broken Tears
            [itemKeys.npcDrops] = {},
        },
        [7923] = { -- Defias Tower Key
            [itemKeys.npcDrops] = {7051},
        },
        [8073] = { -- Cache of Zanzil's Altered Mixture
            [itemKeys.npcDrops] = {},
        },
        [12366] = { -- Thick Yeti Fur
            [itemKeys.npcDrops] = {7457,7458,7459,7460},
        },
        [12740] = { -- Fifth Mosh'aru Tablet
            [itemKeys.npcDrops] = {},
        },
        [17126] = { -- Elegant Letter
            [itemKeys.npcDrops] = {332,918,3327,3328,3401,4163,4214,4215,4582,4583,4584,5165,5166,5167,15285,16279,16684,16685,16686},
        },
        [20023] = { -- Encoded Fragment
            [itemKeys.npcDrops] = {6375,6377,6378,6379,6380,8759,8761,8762,8763,8764,8766,},
        },
        [22435] = { -- Gorishi Sting
            [itemKeys.npcDrops] = {6551,6552,6553,6554,6555,10040,10041},
        },
        [22775] = { -- Suntouched Special Reserve
            [itemKeys.npcDrops] = {16442},
        },
        [22776] = { -- Springpaw Appetizers
            [itemKeys.npcDrops] = {16443},
        },
        [22777] = { -- Bundle of Fireworks
            [itemKeys.npcDrops] = {16444},
        },
        [23217] = { -- Ravager Egg
            [itemKeys.npcDrops] = {16933},
        },
        [23339] = { -- Arelion's Journal
            [itemKeys.npcDrops] = {},
            [itemKeys.objectDrops] = {},
            [itemKeys.itemDrops] = {31955},
        },
        [23361] = { -- Cleansing Vial
            [itemKeys.class] = itemClasses.QUEST,
        },
        [23417] = { -- Sanctified Crystal
            [itemKeys.class] = itemClasses.QUEST,
        },
        [23486] = { -- Caged Female Kaliri Hatchling
            [itemKeys.npcDrops] = {17034},
        },
        [23552] = { -- Filled Azure Phial
            [itemKeys.objectDrops] = {184079},
        },
        [23614] = { -- Red Snapper
            [itemKeys.objectDrops] = {181616},
        },
        [23645] = { -- Seer's Relic
            [itemKeys.class] = itemClasses.QUEST,
        },
        [23670] = { -- Thalanaar Moonwell Water
            [itemKeys.objectDrops] = {181632},
        },
        [23686] = { -- Lacy Handkerchief
            [itemKeys.npcDrops] = {17210},
        },
        [23750] = { -- Filled Bota Bag
            [itemKeys.objectDrops] = {107047},
        },
        [23789] = { -- Remains of Cowlen's Family
            [itemKeys.npcDrops] = {17186,17187,17188},
        },
        [23792] = { -- Tree Disguise Kit
            [itemKeys.class] = itemClasses.QUEST,
        },
        [23801] = { -- Bristlelimb Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [23818] = { -- Stillpine Furbolg Language Primer
            [itemKeys.class] = itemClasses.QUEST,
        },
        [23837] = { -- Weathered Treasure Map
            [itemKeys.npcDrops] = {17421},
        },
        [23848] = { -- Nethergarde Bitter
            [itemKeys.npcDrops] = {3546},
        },
        [23878] = { -- Impact Site Crystal Sample
            [itemKeys.objectDrops] = {181779},
        },
        [23879] = { -- Altered Crystal Sample
            [itemKeys.objectDrops] = {181780},
        },
        [23880] = { -- Axxarien Crystal Sample
            [itemKeys.objectDrops] = {181781},
        },
        [23894] = { -- Fel Orc Blood Vial
            [itemKeys.npcDrops] = {17370,17371,17377,17381,17395,17397,17398,17414,17429,17491,17624,17626,},
        },
        [23901] = { -- Nazan's Head
            [itemKeys.npcDrops] = {17307},
        },
        [23984] = { -- Irradiated Crystal Shard
            [itemKeys.npcDrops] = {17324,17327,17339,17342,17343,17344,17346,17347,17348,17350,17352,17353,17522,17523,17527,17588,17589,17661,17683,17322,17323,17325,17326,17328,17329,17330,17334,17336,17337,17338,17340,17341,17358,17494,17550,17604,17606,17607,17608,17609,17610,17713,17714,17715},
        },
        [24084] = { -- Draenei Banner
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24099] = { -- The High Chief's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24132] = { -- A Letter from the Admiral
            [itemKeys.objectDrops] = {410001},
        },
        [24156] = { -- Filled Shimmering Vessel
            [itemKeys.npcDrops] = {17544},
        },
        [24226] = { -- Blood Knight Insignia
            [itemKeys.npcDrops] = {17832},
        },
        [24246] = { -- Sanguine Hibiscus
            [itemKeys.npcDrops] = {},
        },
        [24278] = { -- Flare Gun
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24285] = { -- Crepuscular Powder
            [itemKeys.npcDrops] = {16683},
        },
        [24286] = { -- Arcane Catalyst
            [itemKeys.npcDrops] = {16611},
        },
        [24287] = { -- Extinguishing Mixture
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24289] = { -- Chrono-beacon
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24317] = { -- Bloodmyst Water Sample
            [itemKeys.objectDrops] = {182074},
        },
        [24335] = { -- Orb of Returning
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24355] = { -- Ironvine Seeds
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24467] = { -- Living Fire
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24474] = { -- Violet Scrying Crystal
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24483] = { -- Withered Basidium
            [itemKeys.startQuest] = 9827,
        },
        [24501] = { -- Gordawg's Boulder
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24502] = { -- Warmaul Skull
            [itemKeys.npcDrops] = {17138,18037,18064,18065},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [24573] = { -- Elder Kuruti's Response
            [itemKeys.npcDrops] = {18197},
        },
        [25458] = { -- Mag'har Battle Standard
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25460] = { -- Bleeding Hollow Supply Crate
            [itemKeys.npcDrops] = {},
        },
        [25461] = { -- Book of Forgotten Names
            [itemKeys.npcDrops] = {18472},
        },
        [25462] = { -- Tome of Dusk
            [itemKeys.npcDrops] = {16807},
        },
        [25465] = { -- Stormcrow Amulet
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25539] = { -- Potion of Water Breathing
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25552] = { -- Warmaul Ogre Banner
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25554] = { -- Kil'sorrow Armaments
            [itemKeys.npcDrops] = {},
        },
        [25555] = { -- Kil'sorrow Banner
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25604] = { -- Warmaul Prison Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25642] = { -- Eye of Veil Shienor
            [itemKeys.objectDrops] = {185201},
        },
        [25658] = { -- Damp Woolen Blanket
            [itemKeys.class] = itemClasses.QUEST,
        },
        [25807] = { -- Timber Worg Tail
            [itemKeys.npcDrops] = {18476,18477},
        },
        [25853] = { -- Pack of Incendiary Bombs
            [itemKeys.class] = itemClasses.QUEST,
        },
        [28038] = { -- Seaforium PU-36 Explosive Nether Modulator
            [itemKeys.class] = itemClasses.QUEST,
        },
        [28106] = { -- Kingston's Primers
            [itemKeys.class] = itemClasses.QUEST,
        },
        [28132] = { -- Area 52 Special
            [itemKeys.class] = itemClasses.QUEST,
        },
        [28478] = { -- To'arch's Primers
            [itemKeys.class] = itemClasses.QUEST,
        },
        [28607] = { -- Sunfury Disguise
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29112] = { -- Cenarion Spirits
            [itemKeys.npcDrops] = {18907},
        },
        [29324] = { -- Warp-Attuned Orb
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29460] = { -- Ethereum Prison Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29473] = { -- Protectorate Igniter
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29482] = { -- Ethereum Essence
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29742] = { -- The Warden's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29769] = { -- Diagnostic Results
            [itemKeys.objectDrops] = {184609},
        },
        [29778] = { -- Phase Disruptor
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29795] = { -- Burning Legion Gate Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [29796] = { -- Socrethar's Teleportation Stone
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30259] = { -- Voren'thal's Presence
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30426] = { -- Coilskar Chest Key
            [itemKeys.npcDrops] = {19762,19768,19789},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30430] = { -- Boiled Blood
            [itemKeys.objectDrops] = {184715},
        },
        [30451] = { -- Lohn'goron, Bow of the Torn-heart
            [itemKeys.npcDrops] = {19799,19800,19802,21337,21656},
        },
        [30540] = { -- Tally's Waiver (Unsigned)
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30639] = { -- Blood Elf Disguise
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30658] = { -- Flanis's Pack
            [itemKeys.npcDrops] = {21727},
        },
        [30659] = { -- Kagrosh's Pack
            [itemKeys.npcDrops] = {21725},
        },
        [30672] = { -- Elemental Displacer
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30712] = { -- The Doctor's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30719] = { -- Spectrecles
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30721] = { -- Spectrecles
            [itemKeys.class] = itemClasses.QUEST,
        },
        [30743] = { -- Proto-Nether Drake Essence
            [itemKeys.npcDrops] = {21821,20021},
        },
        [30782] = { -- Adolescent Nether Drake Essence
            [itemKeys.npcDrops] = {21817,20021},
        },
        [30783] = { -- Mature Nether Drake Essence
            [itemKeys.npcDrops] = {21820,20021},
        },
        [30808] = { -- Book of Fel Names
            [itemKeys.npcDrops] = {18667},
        },
        [30823] = { -- Demon Warding Totem
            [itemKeys.npcDrops] = {19678},
        },
        [31085] = { -- Top Shard of the Arcatraz Key
            [itemKeys.npcDrops] = {17977},
        },
        [31086] = { -- Bottom Shard of the Arcatraz Key
            [itemKeys.npcDrops] = {19220},
        },
        [31121] = { -- Costume Scraps
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31122] = { -- Overseer Disguise
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31130] = { -- Wyrmcult Blackwhelp
            [itemKeys.npcDrops] = {21387},
        },
        [31252] = { -- Charred Key Mold
            [itemKeys.npcDrops] = {18733},
        },
        [31261] = { -- Sketh'lon Commander's Journal - Page 2
            [itemKeys.npcDrops] = {19826,19827,21386},
        },
        [31279] = { -- Enchanted Illidari Tabard
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31316] = { -- Lianthe's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31530] = { -- Sample of Primal Mooncloth
            [itemKeys.objectDrops] = {177281},
        },
        [31495] = { -- Grishnath Orb
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31517] = { -- Dire Pinfeather
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31518] = { -- Exorcism Feather
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31607] = { -- Demoniac Scryer Reading
            [itemKeys.npcDrops] = {22258},
        },
        [31655] = { -- Veil Skith Prison Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31664] = { -- Zuluhed's Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31702] = { -- Challenge from the Horde
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31708] = { -- Scroll of Atalor
            [itemKeys.objectDrops] = {185224},
        },
        [31709] = { -- Drape of Arunen
            [itemKeys.objectDrops] = {185226},
        },
        [31710] = { -- Gavel of K'alen
            [itemKeys.objectDrops] = {185225},
        },
        [31716] = { -- Unused Axe of the Executioner
            [itemKeys.npcDrops] = {17301},
        },
        [31721] = { -- Kalithresh's Trident
            [itemKeys.npcDrops] = {17798},
        },
        [31722] = { -- Murmur's Essence
            [itemKeys.npcDrops] = {18708},
        },
        [31813] = { -- Warp Chaser Blood
            [itemKeys.npcDrops] = {18884},
        },
        [31880] = { -- Blood Elf Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31881] = { -- Draenei Orphan Whistle
            [itemKeys.class] = itemClasses.QUEST,
        },
        [31941] = { -- Mark of the Nexus-King
            [itemKeys.npcDrops] = {20888,20889,22825,22826,22827,22828},
        },
        [31951] = { -- Toy Dragon
            [itemKeys.vendors] = {21643},
        },
        [31955] = { -- Arelion's Knapsack
            [itemKeys.objectDrops] = {184115},
        },
        [31956] = { -- Salvaged Ethereum Prison Key
            [itemKeys.npcDrops] = {20452,20453,20454,20456,20457,20458,20459,20474,20727,20770,20854,22821,22822,23008},
        },
        [31957] = { -- Ethereum Prisoner I.D. Tag
            [itemKeys.npcDrops] = {20520},
        },
        [31994] = { -- Ethereum Key Tablet - Alpha
            [itemKeys.class] = itemClasses.QUEST,
        },
        [32061] = { -- Evidence from Alpha
            [itemKeys.npcDrops] = {20889,22920},
        },
        [32364] = { -- Southfury Moonstone
            [itemKeys.objectDrops] = {185566},
            [itemKeys.npcDrops] = {23002},
        },
        [32379] = { -- Grulloc's Dragon Skull
            [itemKeys.npcDrops] = {},
        },
        [32383] = { -- Skulloc's Soul
            [itemKeys.npcDrops] = {},
        },
        [32406] = { -- Skyguard Blasting Charges
            [itemKeys.class] = itemClasses.QUEST,
        },
        [32598] = { -- Unstable Flask of the Beast
            [itemKeys.objectDrops] = {185920},
        },
        [32601] = { -- Unstable Flask of the Sorcerer
            [itemKeys.objectDrops] = {185921},
        },
        [32723] = { -- Nethermine Cargo
            [itemKeys.npcDrops] = {},
        },
        [32742] = { -- Adversarial Bloodlines
            [itemKeys.npcDrops] = {23363},
        },
        [32971] = { -- Water Bucket
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.objectDrops] = {186234},
        },
        [33071] = { -- Blackhoof Armaments
            [itemKeys.npcDrops] = {},
        },
        [33039] = { -- Tool Kit
            [itemKeys.npcDrops] = {},
        },
        [33041] = { -- Salvaged Strongbox
            [itemKeys.objectDrops] = {186283},
        },
        [33061] = { -- Grimtotem Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [33086] = { -- Stonemaul Banner
            [itemKeys.npcDrops] = {},
        },
        [33087] = { -- Black Dragonkin Essence
            [itemKeys.npcDrops] = {4328,4329,4331},
        },
        [33112] = { -- Witchbane
            [itemKeys.npcDrops] = {},
        },
        [33175] = { -- Wyrmtail
            [itemKeys.npcDrops] = {},
        },
        [33814] = { -- Keli'dan's Feathered Stave
            [itemKeys.npcDrops] = {17377},
        },
        [33815] = { -- Bladefist's Seal
            [itemKeys.npcDrops] = {16808},
        },
        [33821] = { -- The Heart of Quagmirran
            [itemKeys.npcDrops] = {17942},
        },
        [33826] = { -- Black Stalker Egg
            [itemKeys.npcDrops] = {17882},
        },
        [33827] = { -- The Warlord's Treatise
            [itemKeys.npcDrops] = {17798},
        },
        [33833] = { -- Nazan's Riding Crop
            [itemKeys.npcDrops] = {17307},
        },
        [33834] = { -- The Headfeathers of Ikiss
            [itemKeys.npcDrops] = {18473},
        },
        [33835] = { -- Shaffar's Wondrous Amulet
            [itemKeys.npcDrops] = {18344},
        },
        [33836] = { -- The Exarch's Soul Gem
            [itemKeys.npcDrops] = {18373},
        },
        [33837] = { -- Cooking Pot
            [itemKeys.npcDrops] = {18096},
        },
        [33840] = { -- Murmur's Whisper
            [itemKeys.npcDrops] = {18708},
        },
        [33847] = { -- Epoch Hunter's Head
            [itemKeys.npcDrops] = {18096},
        },
        [33858] = { -- Aeonus's Hourglass
            [itemKeys.npcDrops] = {17881},
        },
        [33859] = { -- Warp Splinter Clipping
            [itemKeys.npcDrops] = {17977},
        },
        [33860] = { -- Pathaleon's Projector
            [itemKeys.npcDrops] = {19220},
        },
        [33861] = { -- The Scroll of Skyriss
            [itemKeys.npcDrops] = {20912},
        },
        [34130] = { -- Recovery Diver's Potion
            [itemKeys.class] = itemClasses.QUEST,
        },
        [34160] = { -- The Signet Ring of Prince Kael'thas
            [itemKeys.npcDrops] = {24664},
        },
        [34246] = { -- Smuggled Mana Cell
            [itemKeys.npcDrops] = {},
        },
        [34338] = { -- Mana Remnants
            [itemKeys.npcDrops] = {24960,24966},
        },
        [34475] = { -- Arcane Charges
            [itemKeys.class] = itemClasses.QUEST,
        },
        [34477] = { -- Darkspine Chest Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [35229] = { -- Nether Residue
            [itemKeys.objectDrops] = {410014},
        },
        [35277] = { -- Twilight Correspondence
            [itemKeys.npcDrops] = {25866,25863,25924},
        },
        [35568] = { -- Flame of Silvermoon
            [itemKeys.objectDrops] = {188129},
        },
        [35569] = { -- Flame of the Exodar
            [itemKeys.objectDrops] = {188128},
        },
        [37736] = { -- 2021 Brewfest item (Alliance)
            [itemKeys.name] = "\"Brew of the Month\" Club Membership Form",
            [itemKeys.startQuest] = 12420,
            [itemKeys.itemLevel] = 1,
            [itemKeys.requiredLevel] = 1,
            [itemKeys.ammoType] = 0,
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.subClass] = 0,
            [itemKeys.vendors] = {23710,27478},
        },
        [37737] = { -- 2021 Brewfest item (Horde)
            [itemKeys.name] = "\"Brew of the Month\" Club Membership Form",
            [itemKeys.startQuest] = 12421,
            [itemKeys.itemLevel] = 1,
            [itemKeys.requiredLevel] = 1,
            [itemKeys.ammoType] = 0,
            [itemKeys.class] = itemClasses.QUEST,
            [itemKeys.subClass] = 0,
            [itemKeys.vendors] = {24495,27489},
        },
        [185956] = { -- Shimmering Vessel
            [itemKeys.name] = "Shimmering Vessel",
            [itemKeys.class] = itemClasses.QUEST,
        },
    }
end

-- This should allow manual fix for item availability
function QuestieTBCItemFixes:LoadFactionFixes()
    local itemKeys = QuestieDB.itemKeys

    local itemFixesHorde = {
        [17126] = { -- Elegant Letter
            [itemKeys.npcDrops] = {3327,3328,3401,4582,4583,4584,15285,16279,16684,16685,16686},
        },
        [25911] = { -- Salvaged Wood
            [itemKeys.objectDrops] = {182936},
        },
        [25912] = { -- Salvaged Metal
            [itemKeys.objectDrops] = {182937, 182938},
        },
        [30712] = { -- The Doctor's Key
            [itemKeys.npcDrops] = {21779},
        },
        [30713] = { -- The Art of Fel Reaver Maintenance
            [itemKeys.objectDrops] = {185233},
        },
    }

    local itemFixesAlliance = {
        [17126] = { -- Elegant Letter
            [itemKeys.npcDrops] = {332,918,4163,4214,4215,5165,5166,5167},
        },
        [25911] = { -- Salvaged Wood
            [itemKeys.objectDrops] = {182799},
        },
        [25912] = { -- Salvaged Metal
            [itemKeys.objectDrops] = {182798, 182797},
        },
        [30712] = { -- The Doctor's Key
            [itemKeys.npcDrops] = {21778},
        },
        [30713] = { -- The Art of Fel Reaver Maintenance
            [itemKeys.objectDrops] = {184947},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end
