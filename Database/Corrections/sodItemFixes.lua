---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function SeasonOfDiscovery:LoadItems()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [2287] = { -- Haunch of Meat (modified to add new SoD vendors to food vendor townsfolk)
            [itemKeys.vendors] = {982,1464,2365,2388,2814,3025,3089,3312,3368,3411,3489,3621,3705,3881,3882,3933,3935,3960,4084,4169,4255,4782,4875,4879,4891,4894,4954,4963,5111,5124,5611,5620,5870,6928,6929,6930,7485,7731,7733,7736,7941,8125,9356,10367,11118,11187,12196,12794,12959,14624,15174,241664},
        },
        [2320] = { -- Coarse Thread (modified to add new SoD vendors to trade goods vendor townsfolk)
            [itemKeys.vendors] = {66,777,843,960,989,1148,1250,1286,1347,1454,1456,1465,1474,1672,1692,2118,2225,2381,2393,2394,2668,2669,2670,2672,2697,2698,2699,2810,2816,2819,2821,2846,3005,3081,3091,3096,3168,3187,3364,3366,3367,3482,3485,3499,3556,3614,3779,3954,3955,3958,4168,4189,4194,4225,4229,4561,4577,4589,4775,4877,4897,5100,5128,5135,5154,5163,5565,5783,5817,5944,6301,6567,6568,6574,6576,6731,7852,7854,7940,7947,8145,8160,8363,8681,8934,9636,11189,11557,11874,12022,12028,12043,12245,12941,12942,12943,12956,12957,12958,15165,15179,240631,240632},
        },
        [5359] = { -- Lorgalis Manuscript
            [itemKeys.relatedQuests] = {78923}, -- SoD Knowledge in the Deeps
        },
        [5881] = { -- Head of Kelris
            [itemKeys.relatedQuests] = {78921,78922}, -- SoD Blackfathom Villainy A,H
            [itemKeys.npcDrops] = {209678}, -- now drops from raid version of npc
        },
        [5952] = { -- Corrupted Brain Stem
            [itemKeys.relatedQuests] = {78926}, -- SoD Researching the Corruption
            [itemKeys.npcDrops] = {216660, 4788, 4789, 4803, 4802, 4805, 4807, 4799, 4798, 204645, 216662, 4831, 216659, 216661, 204068}, -- now drops from raid version of npc
        },
        [8766] = { -- Morning Glory Dew (modified to add new SoD vendors to drink vendor townsfolk)
            [itemKeys.vendors] = {258,274,295,465,734,955,982,1237,1247,1328,1464,1697,2303,2352,2364,2366,2388,2803,2832,3086,3298,3411,3546,3577,3621,3689,3708,3881,3882,3883,3884,3934,3937,3959,3961,4167,4169,4181,4190,4191,4192,4195,4255,4266,4554,4555,4571,4782,4875,4879,4893,4963,4981,5111,5112,5140,5611,5620,5688,5814,5871,6091,6272,6495,6727,6734,6735,6736,6737,6738,6739,6740,6741,6746,6747,6790,6791,6807,6928,6929,6930,7485,7714,7731,7733,7736,7737,7744,7941,7943,8125,8137,8143,8150,8152,8931,9356,9501,10367,11038,11103,11106,11116,11118,11187,11287,12019,12026,12196,12794,12959,14371,14624,14731,14961,14962,14963,14964,15124,15125,15174,16256,16458,241664},
        },
        [9279] = { -- White Punch Card
            [itemKeys.npcDrops] = {216667,216668,216669,216670,216671},
        },
        [9309] = { -- Robo-mechanical Guts
            [itemKeys.npcDrops] = {215728,216666,216668,216669,216670,216671,217582,217733,218242,218243,218244,218245,218537,220072},
        },
        [204806] = { -- Rune of Victory Rush
            [itemKeys.npcDrops] = {706,946,1986},
        },
        [205944] = { -- Reciprocal Epiphany
            [itemKeys.npcDrops] = {204937},
        },
        [206157] = { -- Seaforium Mining Charge
            [itemKeys.objectDrops] = {403041},
        },
        [206170] = { -- Windfury Cone
            [itemKeys.objectDrops] = {403105},
        },
        [206264] = { -- Rune of Inspiration
            [itemKeys.npcDrops] = {204937},
        },
        [206469] = { -- Prairie Flower
            [itemKeys.objectDrops] = {403718},
        },
        [208085] = { -- Scarlet Lieutenant Signet Ring
            [itemKeys.npcDrops] = {1662,1664,1665},
        },
        [208205] = { -- Blackrat's Note
            [itemKeys.npcDrops] = {6123,6124},
        },
        [208609] = { -- Glade Flower
            [itemKeys.objectDrops] = {407247},
        },
        [208612] = { -- Severed Spider Head
            [itemKeys.npcDrops] = {1998,1999,2000,2001},
        },
        [208689] = { -- Ferocious Idol
            [itemKeys.npcDrops] = {98,117,452,500,1065,1972,6788},
        },
        [208771] = { -- Rune of Blade Dance
            [itemKeys.objectDrops] = {407453,408718,414532},
        },
        [208772] = { -- Rune of Saber Slash
            [itemKeys.objectDrops] = {407457,407731,409131,414624},
        },
        [209693] = { -- Alliance Blackfathom Pearl
            [itemKeys.relatedQuests] = {78916},
            [itemKeys.startQuest] = 78916,
        },
        [209846] = { -- Secrets of the Dreamers
            [itemKeys.objectDrops] = {409692},
        },
        [210026] = { -- Symbol of the Third Owl
            [itemKeys.objectDrops] = {409942,409949},
        },
        [210044] = { -- Symbol of the First Owl
            [itemKeys.objectDrops] = {410220},
        },
        [210055] = { -- Hillsbrad Human Bones
            [itemKeys.npcDrops] = {2265,2266,2267,2268,2360,2387},
        },
        [210195] = { -- Unbalanced Idol
            [itemKeys.npcDrops] = {1769,1770,1779,1782,1924},
        },
        [210589] = { -- Echo of the Ancestors
            [itemKeys.npcDrops] = {204937},
        },
        [210955] = { -- Scarlet Initiate's Uniform
            [itemKeys.objectDrops] = {412147},
        },
        [211452] = { -- Horde Blackfathom Pearl
            [itemKeys.relatedQuests] = {78917},
            [itemKeys.startQuest] = 78917,
        },
        [211454] = { -- Horde Strange Water Globe (starts Baron Aquanis)
            [itemKeys.relatedQuests] = {78920},
            [itemKeys.startQuest] = 78920,
        },
        [211818] = { -- Alliance Strange Water Globe (required for but does not start Baron Aquanis)
            [itemKeys.relatedQuests] = {79099},
            [itemKeys.startQuest] = nil,
        },
        [212347] = { -- Illari's Key
            [itemKeys.npcDrops] = {215655},
        },
        [213446] = { -- Tarnished Prayer Bead III
            [itemKeys.npcDrops] = {2552,2553,2554,2555,2556,2557,2562,2564,2566,2569,2570,2572,2573,2574,2575,2586,2587,2588,2589,2590,2618,2619,4062},
        },
        [215376] = { -- Crusader's Mace
            [itemKeys.npcDrops] = {4281,4283,4286,4287,4288,4289,4290,4291,4292,4293,4294,4295,4296,4297,4298,4299,4300,4301,4302,4303,4306,4540},
        },
        [216635] = { -- Spent Voidcore
            [itemKeys.npcDrops] = {5335,5336,5337},
        },
        [216946] = { -- Glittering Dalaran Relic
            [itemKeys.npcDrops] = {900000},
        },
        [216947] = { -- Whirring Dalaran Relic
            [itemKeys.npcDrops] = {900001},
        },
        [216948] = { -- Odd Dalaran Relic
            [itemKeys.npcDrops] = {900002},
        },
        [216949] = { -- Heavy Dalaran Relic
            [itemKeys.npcDrops] = {900003},
        },
        [216950] = { -- Creepy Dalaran Relic
            [itemKeys.npcDrops] = {900004},
        },
        [216951] = { -- Slippery Dalaran Relic
            [itemKeys.npcDrops] = {900005},
        },
        [219759] = { -- Charla's Field Report
            [itemKeys.npcDrops] = {221472},
        },
        [219770] = { -- Gemeron's Field Report
            [itemKeys.npcDrops] = {221482},
        },
        [219771] = { -- Thandros' Field Report
            [itemKeys.npcDrops] = {221484},
        },
        [219772] = { -- Fallia's Field Report
            [itemKeys.npcDrops] = {221483},
        },
        [219776] = { -- Intelligence Report: Vul'gol Ogre Mound
            [itemKeys.npcDrops] = {221222},
        },
        [219778] = { -- Intelligence Report: Rotting Orchard
            [itemKeys.npcDrops] = {221221},
        },
        [219803] = { -- Intelligence Report: Yorgen Farmstead
            [itemKeys.npcDrops] = {221220},
        },
        [219924] = { -- Intelligence Report: Forest Song
            [itemKeys.npcDrops] = {221271},
        },
        [219925] = { -- Intelligence Report: Satyrnaar
            [itemKeys.npcDrops] = {221272},
        },
        [219926] = { -- Intelligence Report: Warsong Lumber Camp
            [itemKeys.npcDrops] = {221273},
        },
        [219928] = { -- Intelligence Report: Agol'watha
            [itemKeys.npcDrops] = {221353},
        },
        [219937] = { -- Intelligence Report: Shaol'watha
            [itemKeys.npcDrops] = {221352},
        },
        [219938] = { -- Intelligence Report: Skulk Rock
            [itemKeys.npcDrops] = {221351},
        },
        [219957] = { -- Intelligence Report: Oneiros
            [itemKeys.npcDrops] = {221401},
        },
        [219958] = { -- Intelligence Report: Twin Colossals
            [itemKeys.npcDrops] = {221402},
        },
        [219959] = { -- Intelligence Report: Ruins of Ravenwind
            [itemKeys.npcDrops] = {221404},
        },
        [220345] = { -- Sanguine Sorcery
            [itemKeys.objectDrops] = {441247},
        },
        [220349] = { -- Stonewrought Design
            [itemKeys.objectDrops] = {441251},
        },
        [221326] = { -- Sacred Stag Heart
            [itemKeys.class] = itemClasses.QUEST,
        },
        [221191] = { -- Dreamstone
            [itemKeys.npcDrops] = {211956},
        },
        [225954] = { -- Charred Spell Notes
            [itemKeys.npcDrops] = {227324},
        },
        [226122] = { -- Dalton's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [226523] = { -- Dalton's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [226545] = { -- Dalton's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [227768] = { -- Dreamjuice
            [itemKeys.class] = itemClasses.QUEST,
        },
        [228141] = { -- Necromancy 101
            [itemKeys.objectDrops] = {463211},
        },
        [229362] = { -- Storehouse Key
            [itemKeys.npcDrops] = {230775},
        },
        [231298] = { -- Scroll of Lesser Spatial Mending
            [itemKeys.class] = itemClasses.QUEST,
        },
        [231797] = { -- Soul of the Void
            [itemKeys.npcDrops] = {232875},
        },
        [231798] = { -- Soul of Enthralling
            [itemKeys.npcDrops] = {230146},
        },
        [231799] = { -- Soul of Devouring
            [itemKeys.npcDrops] = {232896},
        },
        [231842] = { -- Nandieb's Stave
            [itemKeys.npcDrops] = {232529},
        },
        [231904] = { -- Tarnished Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [234006] = { -- Monstrous Silithid Chitin
            [itemKeys.npcDrops] = {11698,11724,11727,13136,15240,15286,15288,15341,15348,234798},
        },
        [234007] = { -- Spiked Silithid Chitin
            [itemKeys.npcDrops] = {11698,11722,11723,11724,11727,13136,15230,15233,15235,15236,15240,15318,15319,15320,15323,15324,15325,15327,15336,234798},
        },
        [234008] = { -- Qiraji Silk
            [itemKeys.npcDrops] = {11880,11881,11882,11883,14479,15201,15202,15213,15247,15249,15263,15343,15516,15541,15542,234762,234800},
        },
        [234011] = { -- Qiraji Stalker Venom
            [itemKeys.npcDrops] = {6551,6552,6554,6555,11698,11722,11724,11726,11727,11728,11729,11732,11733,11734,13136,15235,15236,15325,15327,15509},
        },
        [235045] = { -- Imperial Qiraji Regalia
            [itemKeys.npcDrops] = {15275,15276,15299,15509,15510,15511,15516,15517,15543,15544},
        },
        [235046] = { -- Imperial Qiraji Armaments
            [itemKeys.npcDrops] = {15275,15276,15299,15509,15510,15511,15516,15517,15543,15544},
        },
        [235788] = { -- Enthusiastic Wisp
            [itemKeys.npcDrops] = {238431},
        },
        [235789] = { -- Flame of Life
            [itemKeys.npcDrops] = {1045,1046,1047,1048,1049,1050},
        },
        [235790] = { -- Enchanted Firebrand
            [itemKeys.class] = itemClasses.QUEST,
        },
        [236350] = { -- The Phylactery of Kel'Thuzad
            [itemKeys.npcDrops] = {15990},
        },
        [236786] = { -- Heart of Doom
            [itemKeys.objectDrops] = {525416},
        },
        [237143] = { -- Orders from the High General
            [itemKeys.objectDrops] = {600002}, -- fake for tooltips
        },
        [238794] = { -- Unappetizing Leftovers
            [itemKeys.objectDrops] = {526132,526143,526144},
        },
        [238811] = { -- Juicy Apple
            [itemKeys.npcDrops] = {240998,240978},
        },
        [238830] = { -- Apple Scope
            [itemKeys.objectDrops] = {526217},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [238831] = { -- Apple Rope
            [itemKeys.objectDrops] = {526220},
            [itemKeys.class] = itemClasses.QUEST,
        },
        [238899] = { -- Assorted Fish
            [itemKeys.objectDrops] = {526809},
        },
        [238960] = { -- Quartermaster's Crate
            [itemKeys.objectDrops] = {526937},
        },
        [239016] = { -- Holy Salts
            [itemKeys.npcDrops] = {240998,241048,241119,241120,241121,241122,241123,241877,242367,242757},
        },
        [239092] = { -- Preposterously Prosed Postage
            [itemKeys.class] = itemClasses.QUEST,
        },
        [239119] = { -- Holy Arrow
            [itemKeys.objectDrops] = {527513},
        },
        [239216] = { -- Lightforged Iron
            [itemKeys.npcDrops] = {240794,240811,240812,241021,241772,241768,241769,241770,243021,243269},
        },
        [239223] = { -- House Prop
            [itemKeys.objectDrops] = {527821},
        },
        [239764] = { -- Crimson Bladeleaf
            [itemKeys.objectDrops] = {528481},
        },
        [241652] = { -- Discolored Beast Heart
            [itemKeys.npcDrops] = {1815,1816,1817,1821,1822,1824,8596,8597,8598,8600,8601,8602,8603,8605,240247},
        },
        [241655] = { -- Mishandled Healing Potion
            [itemKeys.objectDrops] = {531291},
        },
        [241656] = { -- Mishandled Healing Potion
            [itemKeys.objectDrops] = {531291},
        },
        [242018] = { -- Plaguelands Bleeding Heart
            [itemKeys.objectDrops] = {531301},
        },
        [242257] = { -- Mysterious Alchemical Sample
            [itemKeys.objectDrops] = {531545},
        },
        [242258] = { -- Research Notes
            [itemKeys.objectDrops] = {531545},
        },
        [242319] = { -- New Plague Samples
            [itemKeys.class] = itemClasses.QUEST,
        },
        [242320] = { -- New Plague Samples
            [itemKeys.class] = itemClasses.QUEST,
        },
    }
end
