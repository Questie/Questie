---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function SeasonOfDiscovery:LoadNPCs()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags
    local waypointPresets = QuestieDB.waypointPresets

    return {
        [40] = { -- Kobold Miner
            [npcKeys.questStarts] = {90178},
        },
        [46] = { -- Murloc Forager
            [npcKeys.questStarts] = {90140},
        },
        [95] = { -- Defias Smuggler
            [npcKeys.questStarts] = {90140},
        },
        [98] = { -- Riverpaw Taskmaster
            [npcKeys.questStarts] = {90144},
        },
        [114] = { -- Harvest Watcher
            [npcKeys.questStarts] = {90036},
        },
        [117] = { -- Riverpaw Gnoll
            [npcKeys.questStarts] = {90144},
        },
        [121] = { -- Defias Pathstalker
            [npcKeys.questStarts] = {90140},
        },
        [123] = { -- Riverpaw Mongrel
            [npcKeys.questStarts] = {90144},
        },
        [124] = { -- Riverpaw Brute
            [npcKeys.questStarts] = {90144},
        },
        [125] = { -- Riverpaw Overseer
            [npcKeys.questStarts] = {90144},
        },
        [198] = { -- Khelden Bremen
            [npcKeys.questStarts] = {77620},
            [npcKeys.questEnds] = {3104,77620},
        },
        [215] = { -- Defias Night Runner
            [npcKeys.questStarts] = {90148,90192,90201},
        },
        [285] = { -- Murloc
            [npcKeys.questStarts] = {90140},
        },
        [327] = { -- Goldtooth
            [npcKeys.questStarts] = {90093,90095,90156},
        },
        [332] = { -- Master Mathias Shaw
            [npcKeys.questEnds] = {135,393,394,2205,2206,2359,6182,6183,84377,85882},
        },
        [375] = { -- Priestess Anetta
            [npcKeys.questStarts] = {5623,77619},
            [npcKeys.questEnds] = {3103,77619},
        },
        [376] = { -- High Priestess Laurena
            [npcKeys.questStarts] = {5634,5641,5673,84320,84321,84324,84326,84327,84329,84413},
            [npcKeys.questEnds] = {5634,5635,5636,5637,5638,5639,5640,5676,5677,5678,78193,84320,84323,84324,84325,84326,84412,84413},
        },
        [391] = { -- Old Murk-Eye
            [npcKeys.questStarts] = {90065,90112},
            [npcKeys.questEnds] = {90112},
        },
        [436] = { -- Blackrock Shadowcaster
            [npcKeys.questStarts] = {90169},
        },
        [448] = { -- Hogger
            [npcKeys.questStarts] = {90004,90074,90093,90095},
        },
        [449] = { -- Defias Knuckleduster
            [npcKeys.questStarts] = {90140},
        },
        [452] = { -- Riverpaw Bandit
            [npcKeys.questStarts] = {90144},
        },
        [453] = { -- Riverpaw Mystic
            [npcKeys.questStarts] = {90144},
        },
        [459] = { -- Drusilla La Salle
            [npcKeys.questStarts] = {1598,77621},
            [npcKeys.questEnds] = {1598,3105,77621},
        },
        [460] = { -- Alamar Grimm
            [npcKeys.questStarts] = {1599,77666},
            [npcKeys.questEnds] = {1599,3115,77666},
        },
        [474] = { -- Defias Rogue Wizard
            [npcKeys.questStarts] = {90183},
        },
        [476] = { -- Kobold Geomancer
            [npcKeys.questStarts] = {90015},
        },
        [480] = { -- Rusty Harvest Golem
            [npcKeys.questStarts] = {90036},
        },
        [500] = { -- Riverpaw Scout
            [npcKeys.questStarts] = {90144},
        },
        [501] = { -- Riverpaw Herbalist
            [npcKeys.questStarts] = {90144},
        },
        [504] = { -- Defias Trapper
            [npcKeys.questStarts] = {90140},
        },
        [572] = { -- Leprithus
            [npcKeys.questStarts] = {90147,90187},
        },
        [589] = { -- Defias Pillager
            [npcKeys.questStarts] = {90008,90140},
        },
        [590] = { -- Defias Looter
            [npcKeys.questStarts] = {90140},
        },
        [702] = { -- Bloodscalp Scavenger
            [npcKeys.questStarts] = {79731},
        },
        [715] = { -- Hemet Nesingwary
            [npcKeys.questStarts] = {194,195,196,197,208,78830},
            [npcKeys.questEnds] = {194,195,196,197,208,583,5762,5763,78823,78830,79731},
        },
        [732] = { -- Murloc Lurker
            [npcKeys.questStarts] = {90140},
        },
        [735] = { -- Murloc Streamrunner
            [npcKeys.questStarts] = {90140},
        },
        [780] = { -- Skullsplitter Mystic
            [npcKeys.questStarts] = {90226,90227},
        },
        [832] = { -- Dust Devil
            [npcKeys.questStarts] = {90036},
        },
        [837] = { -- Branstock Khalder
            [npcKeys.questStarts] = {5626,77661},
            [npcKeys.questEnds] = {3110,77661},
        },
        [846] = { -- Ghoul
            [npcKeys.questStarts] = {90147},
        },
        [895] = { -- Thorgas Grimson
            [npcKeys.questStarts] = {77660},
            [npcKeys.questEnds] = {3108,77660},
        },
        [906] = { -- Maximillian Crowe
            [npcKeys.questStarts] = {90071},
        },
        [909] = { -- Defias Night Blade
            [npcKeys.questStarts] = {90148,90192,90201},
        },
        [910] = { -- Defias Enchanter
            [npcKeys.questStarts] = {90148,90192,90201},
        },
        [911] = { -- Llane Beshere
            [npcKeys.questStarts] = {77616},
            [npcKeys.questEnds] = {3100,77616},
        },
        [912] = { -- Thran Khorman
            [npcKeys.questStarts] = {77655,77656},
            [npcKeys.questEnds] = {3106,3112,77655,77656},
        },
        [915] = { -- Jorik Kerridan
            [npcKeys.questStarts] = {77618},
            [npcKeys.questEnds] = {3102,77618},
        },
        [916] = { -- Solm Hargrin
            [npcKeys.questStarts] = {77658,77659},
            [npcKeys.questEnds] = {3109,3113,77658,77659},
        },
        [925] = { -- Brother Sammuel
            [npcKeys.questStarts] = {77617},
            [npcKeys.questEnds] = {3101,77617},
        },
        [926] = { -- Bromos Grummner
            [npcKeys.questStarts] = {77657},
            [npcKeys.questEnds] = {3107,77657},
        },
        [944] = { -- Marryk Nurribit
            [npcKeys.questStarts] = {77667},
            [npcKeys.questEnds] = {3114,77667},
        },
        [1065] = { -- Riverpaw Shaman
            [npcKeys.questStarts] = {90144},
        },
        [1115] = { -- Rockjaw Skullthumper
            [npcKeys.questStarts] = {90206},
        },
        [1116] = { -- Rockjaw Ambusher
            [npcKeys.questStarts] = {90206},
        },
        [1117] = { -- Rockjaw Bonesnapper
            [npcKeys.questStarts] = {90206},
        },
        [1118] = { -- Rockjaw Backbreaker
            [npcKeys.questStarts] = {90206},
        },
        [1124] = { -- Frostmane Shadowcaster
            [npcKeys.questStarts] = {90016,90182},
        },
        [1132] = { -- Timber
            [npcKeys.questStarts] = {90004},
        },
        [1161] = { -- Stonesplinter Trogg
            [npcKeys.questStarts] = {90139},
        },
        [1162] = { -- Stonesplinter Scout
            [npcKeys.questStarts] = {90139},
        },
        [1163] = { -- Stonesplinter Skullthumper
            [npcKeys.questStarts] = {90139},
        },
        [1164] = { -- Stonesplinter Bonesnapper
            [npcKeys.questStarts] = {90139},
        },
        [1166] = { -- Stonesplinter Seer
            [npcKeys.questStarts] = {90020},
        },
        [1169] = { -- Dark Iron Insurgent
            [npcKeys.questStarts] = {90085},
        },
        [1211] = { -- Leper Gnome
            [npcKeys.questStarts] = {90155},
        },
        [1212] = { -- Bishop Farthing
            [npcKeys.questStarts] = {270,79077},
            [npcKeys.questEnds] = {269,79077},
        },
        [1224] = { -- Young Threshadon
            [npcKeys.questEnds] = {90128},
        },
        [1268] = { -- Ozzie Togglevolt
            [npcKeys.questStarts] = {2926,2962,80139,80182},
            [npcKeys.questEnds] = {2926,2927,2962,80139,80182},
        },
        [1271] = { -- Old Icebeard
            [npcKeys.questStarts] = {90004,90093,90095},
        },
        [1388] = { -- Vagash
            [npcKeys.questStarts] = {90004,90093,90095},
        },
        [1397] = { -- Frostmane Seer
            [npcKeys.questStarts] = {90016,90182},
        },
        [1426] = { -- Riverpaw Miner
            [npcKeys.questStarts] = {90144},
        },
        [1443] = { -- Fel'zerul
            [npcKeys.questStarts] = {1424,1429,1445,82100},
            [npcKeys.questEnds] = {1424,1444,1445,82100},
        },
        [1498] = { -- Bethor Iceshard
            [npcKeys.questStarts] = {357,366,446,78277},
            [npcKeys.questEnds] = {357,405,411,444,491,78277},
        },
        [1535] = { -- Scarlet Warrior
            [npcKeys.questStarts] = {90018,90186},
        },
        [1536] = { -- Scarlet Missionary
            [npcKeys.questStarts] = {90186},
        },
        [1684] = { -- Khara Deepwater
            [npcKeys.questStarts] = {90128},
        },
        [1748] = { -- Highlord Bolvar Fordragon
            [npcKeys.questStarts] = {4185,4186,6182,6187,6501,7496,7782,84560,85643,85659,88969},
        },
        [1753] = { -- Maggot Eye
            [npcKeys.questStarts] = {90076},
        },
        [1773] = { -- Rot Hide Mystic
            [npcKeys.questStarts] = {90204},
        },
        [1778] = { -- Ferocious Grizzled Bear
            [npcKeys.questStarts] = {90175},
        },
        [1783] = { -- Skeletal Flayer
            [npcKeys.questStarts] = {90341,90342},
        },
        [1854] = { -- High Priest Thel'danis
            [npcKeys.questStarts] = {8416,85034},
            [npcKeys.questEnds] = {8414,85034,85455},
        },
        [1867] = { -- Dalaran Apprentice
            [npcKeys.questStarts] = {90009},
        },
        [1883] = { -- Scarlet Worker
            [npcKeys.questStarts] = {90346},
        },
        [1934] = { -- Tirisfal Farmer
            [npcKeys.questStarts] = {90181},
        },
        [1937] = { -- Apothecary Renferrel
            [npcKeys.questEnds] = {429,443,445,446,450,3221,90566},
        },
        [1972] = { -- Grimson the Pale
            [npcKeys.questStarts] = {90215},
        },
        [1973] = { -- Ravenclaw Guardian
            [npcKeys.questStarts] = {90069},
        },
        [1974] = { -- Ravenclaw Drudger
            [npcKeys.questStarts] = {90069},
        },
        [2002] = { -- Rascal Sprite
            [npcKeys.questStarts] = {90184},
        },
        [2003] = { -- Shadow Sprite
            [npcKeys.questStarts] = {90184},
        },
        [2004] = { -- Dark Sprite
            [npcKeys.questStarts] = {90184},
        },
        [2005] = { -- Vicious Grell
            [npcKeys.questStarts] = {90184},
        },
        [2009] = { -- Gnarlpine Shaman
            [npcKeys.questStarts] = {90207},
        },
        [2010] = { -- Gnarlpine Defender
            [npcKeys.questStarts] = {90207},
        },
        [2011] = { -- Gnarlpine Augur
            [npcKeys.questStarts] = {90207},
        },
        [2012] = { -- Gnarlpine Pathfinder
            [npcKeys.questStarts] = {90207},
        },
        [2013] = { -- Gnarlpine Avenger
            [npcKeys.questStarts] = {90207},
        },
        [2014] = { -- Gnarlpine Totemic
            [npcKeys.questStarts] = {90207},
        },
        [2038] = { -- Lord Melenas
            [npcKeys.questStarts] = {90179,90199},
        },
        [2055] = { -- Master Apothecary Faranell
            [npcKeys.questStarts] = {450,515,1109,1113,90566},
            [npcKeys.questEnds] = {447,451,513,1109,1113,2938,90560},
        },
        [2119] = { -- Dannal Stern
            [npcKeys.questStarts] = {77668},
            [npcKeys.questEnds] = {3095,77668},
        },
        [2122] = { -- David Trias
            [npcKeys.questStarts] = {77669},
            [npcKeys.questEnds] = {3096,77669},
        },
        [2123] = { -- Dark Cleric Duesten
            [npcKeys.questStarts] = {5651,77670},
            [npcKeys.questEnds] = {3097,77670},
        },
        [2124] = { -- Isabella
            [npcKeys.questStarts] = {77671},
            [npcKeys.questEnds] = {3098,77671},
        },
        [2126] = { -- Maximillion
            [npcKeys.questStarts] = {77672},
            [npcKeys.questEnds] = {3099,77672},
        },
        [2127] = { -- Rupert Boch
            [npcKeys.questStarts] = {90072},
        },
        [2129] = { -- Dark Cleric Beryl
            [npcKeys.questStarts] = {5650,5663,90158},
        },
        [2152] = { -- Gnarlpine Ambusher
            [npcKeys.questStarts] = {90207},
        },
        [2167] = { -- Blackwood Pathfinder
            [npcKeys.questStarts] = {90145,90173},
        },
        [2168] = { -- Blackwood Warrior
            [npcKeys.questStarts] = {90145,90173},
        },
        [2169] = { -- Blackwood Totemic
            [npcKeys.questStarts] = {90145,90173},
        },
        [2170] = { -- Blackwood Ursa
            [npcKeys.questStarts] = {90145,90173},
        },
        [2171] = { -- Blackwood Shaman
            [npcKeys.questStarts] = {90145,90173},
        },
        [2234] = { -- Young Reef Crawler
            [npcKeys.questStarts] = {90145,90173},
        },
        [2252] = { -- Crushridge Ogre
            [npcKeys.questStarts] = {90232},
        },
        [2253] = { -- Crushridge Brute
            [npcKeys.questStarts] = {90232},
        },
        [2254] = { -- Crushridge Mauler
            [npcKeys.questStarts] = {79624},
        },
        [2255] = { -- Crushridge Mage
            [npcKeys.questStarts] = {79624},
        },
        [2256] = { -- Crushridge Enforcer
            [npcKeys.questStarts] = {79624},
        },
        [2287] = { -- Crushridge Warmonger
            [npcKeys.questStarts] = {79624},
        },
        [2324] = { -- Blackwood Windtalker
            [npcKeys.questStarts] = {90145,90173},
        },
        [2336] = { -- Dark Strand Fanatic
            [npcKeys.questStarts] = {90035},
        },
        [2373] = { -- Mudsnout Shaman
            [npcKeys.questStarts] = {90205},
        },
        [2478] = { -- Haren Swifthoof
            [npcKeys.questStarts] = {90114},
            [npcKeys.questEnds] = {90114},
        },
        [2496] = { -- Baron Revilgaz
            [npcKeys.questStarts] = {578,601,602,1182,1183,85979,85980,85981,85982},
            [npcKeys.questEnds] = {578,601,611,616,1181,1182,85979,85980,85981,85982},
        },
        [2569] = { -- Boulderfist Mauler
            [npcKeys.questStarts] = {79624},
        },
        [2570] = { -- Boulderfist Shaman
            [npcKeys.questStarts] = {79624},
        },
        [2571] = { -- Boulderfist Lord
            [npcKeys.questStarts] = {79624},
        },
        [2590] = { -- Syndicate Conjuror
            [npcKeys.questStarts] = {90255},
        },
        [2649] = { -- Witherbark Scalper
            [npcKeys.questStarts] = {90283},
        },
        [2650] = { -- Witherbark Zealot
            [npcKeys.questStarts] = {90283},
        },
        [2651] = { -- Witherbark Hideskinner
            [npcKeys.questStarts] = {90283},
        },
        [2652] = { -- Witherbark Venomblood
            [npcKeys.questStarts] = {90283},
        },
        [2653] = { -- Witherbark Sadist
            [npcKeys.questStarts] = {90283},
        },
        [2655] = { -- Green Sludge
            [npcKeys.questStarts] = {81960},
        },
        [2656] = { -- Jade Ooze
            [npcKeys.questStarts] = {81960},
        },
        [2701] = { -- Dustbelcher Ogre
            [npcKeys.questStarts] = {78823},
        },
        [2715] = { -- Dustbelcher Brute
            [npcKeys.questStarts] = {78823},
        },
        [2716] = { -- Dustbelcher Wyrmhunter
            [npcKeys.questStarts] = {78823},
        },
        [2717] = { -- Dustbelcher Mauler
            [npcKeys.questStarts] = {78823},
        },
        [2718] = { -- Dustbelcher Shaman
            [npcKeys.questStarts] = {78823},
        },
        [2786] = { -- Gerrig Bonegrip
            [npcKeys.questStarts] = {687,735,737,971,78923},
            [npcKeys.questEnds] = {653,727,735,968,971,78923},
        },
        [2836] = { -- Brikk Keencraft
            [npcKeys.questStarts] = {85556},
            [npcKeys.questEnds] = {85555},
        },
        [2888] = { -- Garek
            [npcKeys.questStarts] = {717,732,85447},
            [npcKeys.questEnds] = {717,732,85445},
        },
        [2893] = { -- Stonevault Bonesnapper
            [npcKeys.questStarts] = {78823},
        },
        [2894] = { -- Stonevault Shaman
            [npcKeys.questStarts] = {78823},
        },
        [2906] = { -- Dustbelcher Warrior
            [npcKeys.questStarts] = {78823},
        },
        [2907] = { -- Dustbelcher Mystic
            [npcKeys.questStarts] = {78823},
        },
        [2949] = { -- Palemane Tanner
            [npcKeys.questStarts] = {90209},
        },
        [2950] = { -- Palemane Skinner
            [npcKeys.questStarts] = {90209},
        },
        [2951] = { -- Palemane Poacher
            [npcKeys.questStarts] = {90209},
        },
        [2960] = { -- Prairie Wolf Alpha
            [npcKeys.questStarts] = {90146},
        },
        [2995] = { -- Tal
            [npcKeys.questStarts] = {6364,90243},
        },
        [3058] = { -- Arra'chea
            [npcKeys.questStarts] = {90093,90095},
        },
        [3059] = { -- Harutt Thunderhorn
            [npcKeys.questStarts] = {77651},
            [npcKeys.questEnds] = {3091,77651},
        },
        [3060] = { -- Gart Mistrunner
            [npcKeys.questStarts] = {77648},
            [npcKeys.questEnds] = {3094,77648},
        },
        [3061] = { -- Lanka Farshot
            [npcKeys.questStarts] = {6066,77649},
            [npcKeys.questEnds] = {3092,77649},
        },
        [3062] = { -- Meela Dawnstrider
            [npcKeys.questStarts] = {77652},
            [npcKeys.questEnds] = {3093,77652},
        },
        [3111] = { -- Razormane Quilboar
            [npcKeys.questStarts] = {90208},
        },
        [3112] = { -- Razormane Scout
            [npcKeys.questStarts] = {90208},
        },
        [3113] = { -- Razormane Dustrunner
            [npcKeys.questStarts] = {90208},
        },
        [3114] = { -- Razormane Battleguard
            [npcKeys.questStarts] = {90208},
        },
        [3128] = { -- Kul Tiras Sailor
            [npcKeys.questStarts] = {90158},
        },
        [3153] = { -- Frang
            [npcKeys.questStarts] = {77582,77588},
            [npcKeys.questEnds] = {2383,3065,77582,77588},
        },
        [3154] = { -- Jen'shan
            [npcKeys.questStarts] = {77584,77590},
            [npcKeys.questEnds] = {3082,3087,77584,77590},
        },
        [3155] = { -- Rwag
            [npcKeys.questStarts] = {77583,77592},
            [npcKeys.questEnds] = {3083,3088,77583,77592},
        },
        [3156] = { -- Nartok
            [npcKeys.questStarts] = {77586},
            [npcKeys.questEnds] = {3090,77586},
        },
        [3157] = { -- Shikrik
            [npcKeys.questStarts] = {77585,77587},
            [npcKeys.questEnds] = {3084,3089,77585,77587},
        },
        [3179] = { -- Harold Riggs
            [npcKeys.questStarts] = {90250},
        },
        [3197] = { -- Burning Blade Fanatic
            [npcKeys.questStarts] = {90017},
        },
        [3204] = { -- Gazz'uz
            [npcKeys.questStarts] = {90075,90093,90095,90180},
        },
        [3205] = { -- Zalazane
            [npcKeys.questStarts] = {90005,90093,90095},
        },
        [3206] = { -- Voodoo Troll
            [npcKeys.questStarts] = {90185},
        },
        [3265] = { -- Razormane Hunter
            [npcKeys.questStarts] = {90165},
        },
        [3266] = { -- Razormane Defender
            [npcKeys.questStarts] = {90165},
        },
        [3267] = { -- Razormane Water Seeker
            [npcKeys.questStarts] = {90165},
        },
        [3268] = { -- Razormane Thornweaver
            [npcKeys.questStarts] = {90165},
        },
        [3281] = { -- Sarkoth
            [npcKeys.questStarts] = {90093,90095},
        },
        [3291] = { -- Greishan Ironstove
            [npcKeys.questStarts] = {90034},
        },
        [3399] = { -- Zamja
            [npcKeys.questStarts] = {6611,90109},
            [npcKeys.questEnds] = {90109},
        },
        [3408] = { -- Zel'mak
            [npcKeys.questStarts] = {78304},
            [npcKeys.questEnds] = {78288},
        },
        [3412] = { -- Nogg
            [npcKeys.questStarts] = {2841,2950,80132,80141},
            [npcKeys.questEnds] = {2841,2949,2950,80132,80140,80141,80325},
        },
        [3413] = { -- Sovik
            [npcKeys.questStarts] = {2842,80133},
        },
        [3445] = { -- Supervisor Lugwizzle
            [npcKeys.questStarts] = {90067},
        },
        [3457] = { -- Razormane Stalker
            [npcKeys.questStarts] = {90165},
        },
        [3497] = { -- Kilxx
            [npcKeys.questStarts] = {90142,90153},
        },
        [3536] = { -- Kris Legace
            [npcKeys.questStarts] = {90198},
        },
        [3537] = { -- Zixil
            [npcKeys.questStarts] = {90032,90083},
        },
        [3566] = { -- Flatland Prowler
            [npcKeys.questStarts] = {90146},
        },
        [3593] = { -- Alyissia
            [npcKeys.questStarts] = {77575},
            [npcKeys.questEnds] = {3116,77575},
        },
        [3594] = { -- Frahun Shadewhisper
            [npcKeys.questStarts] = {77573},
            [npcKeys.questEnds] = {3118,77573},
        },
        [3595] = { -- Shanda
            [npcKeys.questStarts] = {5622,77574},
            [npcKeys.questEnds] = {3119,77574},
        },
        [3596] = { -- Ayanna Everstride
            [npcKeys.questStarts] = {6072,77568},
            [npcKeys.questEnds] = {3117,77568},
        },
        [3597] = { -- Mardant Strongoak
            [npcKeys.questStarts] = {77571},
            [npcKeys.questEnds] = {3120,77571},
        },
        [3663] = { -- Delgren the Purifier
            [npcKeys.questStarts] = {970,973,1140,1167,78088,78089},
            [npcKeys.questEnds] = {967,970,973,976,981,1140,78088,78093},
        },
        [3707] = { -- Ken'jai
            [npcKeys.questStarts] = {5649,5657,77642},
            [npcKeys.questEnds] = {3085,77642},
        },
        [4047] = { -- Zor Lonetree
            [npcKeys.questStarts] = {1061,7541,90241},
        },
        [4077] = { -- Gaxim Rustfizzle
            [npcKeys.questStarts] = {1071,1072,1075,1079,1080,1091,2931,80142},
        },
        [4086] = { -- Veenix
            [npcKeys.questEnds] = {78270},
        },
        [4092] = { -- Lariia
            [npcKeys.questStarts] = {79078},
            [npcKeys.questEnds] = {79078},
        },
        [4160] = { -- Ainethil
            [npcKeys.questEnds] = {90567},
        },
        [4607] = { -- Father Lankester
            [npcKeys.questStarts] = {5643,5656,5658,5679,79080},
            [npcKeys.questEnds] = {79080},
        },
        [4713] = { -- Slitherblade Warrior
            [npcKeys.questStarts] = {90235},
        },
        [4722] = { -- Rau Cliffrunner
            [npcKeys.questStarts] = {1197,79360,79366,79442},
            [npcKeys.questEnds] = {1196,1197,79358,79365,79366},
        },
        [4783] = { -- Dawnwatcher Selgorm
            [npcKeys.questEnds] = {1200,78916,78921},
        },
        [4784] = { -- Argent Guard Manados
            [npcKeys.questStarts] = {1199,78925},
            [npcKeys.questEnds] = {1199,78925},
        },
        [4786] = { -- Dawnwatcher Shaedlass
            [npcKeys.questStarts] = {1198,78924},
        },
        [4787] = { -- Argent Guard Thaelrid
            [npcKeys.questStarts] = {1200,6561,78921,78922},
            [npcKeys.questEnds] = {1198,78924},
        },
        [4792] = { -- "Swamp Eye" Jarl
            [npcKeys.questStarts] = {1203,1206,1218,81570},
            [npcKeys.questEnds] = {1203,1206,1218,81570},
        },
        [4949] = { -- Thrall
            [npcKeys.questStarts] = {4002,4003,4974,5726,5727,5728,5729,6566,6567,7491,7784,84561,85644,85658,85883,88968},
            [npcKeys.questEnds] = {4001,4002,4004,4941,4974,5726,5727,5728,5730,6566,7490,7783,8485,85883},
        },
        [5164] = { -- Grumnus Steelshaper
            [npcKeys.questStarts] = {5283,85713},
            [npcKeys.questEnds] = {5283,85713},
        },
        [5353] = { -- Itharius
            [npcKeys.questStarts] = {3512,82019,82020},
            [npcKeys.questEnds] = {3374,82018,82019},
        },
        [5384] = { -- Brohann Caskbelly
            [npcKeys.questStarts] = {1448,1449,1475,82098},
            [npcKeys.questEnds] = {1448,1469,1475,82098},
        },
        [5420] = { -- Glasshide Gazer
            [npcKeys.questStarts] = {82072},
        },
        [5426] = { -- Blisterpaw Hyena
            [npcKeys.questStarts] = {82072},
        },
        [5465] = { -- Land Rager
            [npcKeys.questStarts] = {82072},
        },
        [5481] = { -- Thistleshrub Dew Collector
            [npcKeys.questStarts] = {90290},
        },
        [5485] = { -- Thistleshrub Rootshaper
            [npcKeys.questStarts] = {90290},
        },
        [5492] = { -- Katherine the Pure
            [npcKeys.questStarts] = {78090,79940,79946,81764,84418,85507,85509,85510},
            [npcKeys.questEnds] = {78089,79939,79940,79945,81762,81766,82135,84418,85508,85509},
        },
        [5495] = { -- Ursula Deline
            [npcKeys.questStarts] = {78091,78092},
            [npcKeys.questEnds] = {78090,78091},
        },
        [5497] = { -- Jennea Cannon
            [npcKeys.questStarts] = {1861,1920,1921,1939,1947,1953,2861,84394,85385},
            [npcKeys.questEnds] = {1860,1861,1919,1920,84394,84395,84396,84397,84398,84399,84400,84401,84402,85304},
        },
        [5570] = { -- Bruuk Barleybeard
            [npcKeys.questStarts] = {90106,90123},
            [npcKeys.questEnds] = {90106,90123},
        },
        [5598] = { -- Atal'ai Exile
            [npcKeys.questStarts] = {1444,1446,82104},
            [npcKeys.questEnds] = {1429,1446,82104},
        },
        [5616] = { -- Wastewander Thief
            [npcKeys.questStarts] = {90287,90288},
        },
        [5617] = { -- Wastewander Shadow Mage
            [npcKeys.questStarts] = {90287,90288},
        },
        [5675] = { -- Carendin Halgar
            [npcKeys.questStarts] = {1471,1472,1473,1474,3001,65597,90072},
        },
        [5769] = { -- Arch Druid Hamuul Runetotem
            [npcKeys.questStarts] = {886,1123,1490,3761,3782,90242},
        },
        [5824] = { -- Captain Flat Tusk
            [npcKeys.questStarts] = {90208},
        },
        [5826] = { -- Geolord Mottle
            [npcKeys.questStarts] = {90208},
        },
        [5852] = { -- Inferno Elemental
            [npcKeys.questStarts] = {82071},
        },
        [5855] = { -- Magma Elemental
            [npcKeys.questStarts] = {82071},
        },
        [5884] = { -- Mai'ah
            [npcKeys.questStarts] = {77643},
            [npcKeys.questEnds] = {3086,77643},
        },
        [6004] = { -- Shadowsworn Cultist
            [npcKeys.questStarts] = {90343},
        },
        [6006] = { -- Shadowsworn Adept
            [npcKeys.questStarts] = {90343},
        },
        [6018] = { -- Ur'kyo
            [npcKeys.questStarts] = {5652,5662,8254,79079},
            [npcKeys.questEnds] = {5642,5643,5652,5654,5655,5656,5657,5680,79079},
        },
        [6113] = { -- Vejrek
            [npcKeys.questStarts] = {90093,90095},
        },
        [6122] = { -- Gakin the Darkbinder
            [npcKeys.questStarts] = {1688,1689,1716,1739,1798,65603,90071},
        },
        [6123] = { -- Dark Iron Spy
            [npcKeys.questStarts] = {90200},
        },
        [6124] = { -- Captain Beld
            [npcKeys.questStarts] = {90073,90177},
        },
        [6125] = { -- Haldarr Satyr
            [npcKeys.questStarts] = {82073},
        },
        [6126] = { -- Haldarr Trickster
            [npcKeys.questStarts] = {82073},
        },
        [6127] = { -- Haldarr Felsworn
            [npcKeys.questStarts] = {82073},
        },
        [6142] = { -- Mathiel
            [npcKeys.questStarts] = {1693,1710,1711,2925,80135},
        },
        [6169] = { -- Klockmort Spannerspan
            [npcKeys.questStarts] = {1708,1709,2769,2924,80136},
            [npcKeys.questEnds] = {1704,1708,1709,2924,2925,80135,80136},
        },
        [6176] = { -- Bath'rah the Windwatcher
            [npcKeys.questStarts] = {1712,1713,1792,8411,8412,8413,79361,79362,79363,79364,79365,82113},
            [npcKeys.questEnds] = {1712,1713,1791,1792,8410,8411,8412,8413,79360,79361,79362,79363,79364,79442,82113},
        },
        [6247] = { -- Doan Karhan
            [npcKeys.questStarts] = {1740,78680,78681,78702,85468},
            [npcKeys.questEnds] = {1740,78680,78684,78702,85112},
        },
        [6272] = { -- Innkeeper Janene
            [npcKeys.questEnds] = {81765},
        },
        [6375] = { -- Thunderhead Hippogryph
            [npcKeys.questStarts] = {90299},
        },
        [6491] = { -- Spirit Healer
            [npcKeys.questEnds] = {78197},
        },
        [6505] = { -- Ravasaur
            [npcKeys.questStarts] = {90307},
        },
        [6506] = { -- Ravasaur Runner
            [npcKeys.questStarts] = {90307},
        },
        [6507] = { -- Ravasaur Hunter
            [npcKeys.questStarts] = {90307},
        },
        [6508] = { -- Venomhide Ravasaur
            [npcKeys.questStarts] = {90307},
        },
        [6579] = { -- Shoni the Shilent
            [npcKeys.questStarts] = {2040,2928,80181},
            [npcKeys.questEnds] = {2040,2041,2928,80181},
        },
        [6706] = { -- Baritanas Skyriver
            [npcKeys.questEnds] = {84881},
        },
        [6707] = { -- Fahrad
            [npcKeys.questStarts] = {8249,80411,80453,80526,84881},
            [npcKeys.questEnds] = {6681,8249,80411,80455,80526,84880},
        },
        [6736] = { -- Innkeeper Keldamyr
            [npcKeys.questStarts] = {90108,90125},
            [npcKeys.questEnds] = {2159,90108,90125},
        },
        [6768] = { -- Lord Jorach Ravenholdt
            [npcKeys.questEnds] = {8233,8236,82110},
        },
        [6777] = { -- Zan Shivsproket
            [npcKeys.questStarts] = {80454},
            [npcKeys.questEnds] = {80453},
        },
        [6788] = { -- Den Mother
            [npcKeys.questStarts] = {90130},
        },
        [6826] = { -- Talvash del Kissel
            [npcKeys.questStarts] = {2199,2200,2361,2948,3375,8355,80131},
            [npcKeys.questEnds] = {2198,2199,2204,2361,2947,2948,3375,8355,79987,80131},
        },
        [7032] = { -- Greater Obsidian Elemental
            [npcKeys.questStarts] = {90340},
        },
        [7050] = { -- Defias Drone
            [npcKeys.questStarts] = {90147},
        },
        [7156] = { -- Deadwood Den Watcher
            [npcKeys.questStarts] = {90311},
        },
        [7157] = { -- Deadwood Avenger
            [npcKeys.questStarts] = {90311},
        },
        [7158] = { -- Deadwood Shaman
            [npcKeys.questStarts] = {90311,90338},
        },
        [7318] = { -- Rageclaw
            [npcKeys.questStarts] = {90127},
            [npcKeys.questEnds] = {90127},
        },
        [7408] = { -- Spigot Operator Luglunket
            [npcKeys.questStarts] = {1707,1878,82209},
            [npcKeys.questEnds] = {1707,1878,82209},
        },
        [7506] = { -- Bloodmage Lynnore
            [npcKeys.questStarts] = {2601,2602,2603,2604,81917,81919},
            [npcKeys.questEnds] = {2601,2602,2603,2604,81900,81917,81919},
        },
        [7572] = { -- Fallen Hero of the Horde
            [npcKeys.questStarts] = {2621,2681,2702,2721,2744,2784,2801,3627,3628,8423,8424,8425,82107},
            [npcKeys.questEnds] = {2623,2681,2743,2783,2784,2801,3626,3627,3628,8417,8423,8424,8425,82107},
        },
        [7771] = { -- Marvon Rivetseeker
            [npcKeys.questStarts] = {3161,3444,3446,3447,82096,82097},
        },
        [7775] = { -- Gregan Brewspewer
            [npcKeys.questStarts] = {4041,4143,82099},
        },
        [7798] = { -- Hank the Hammer
            [npcKeys.questStarts] = {2758,2759,80241},
            [npcKeys.questEnds] = {2758,80241},
        },
        [7825] = { -- Oran Snakewrithe
            [npcKeys.questStarts] = {2995,8273,85385},
            [npcKeys.questEnds] = {2782,2995,8273,84394,84395,84396,84397,84398,84399,84400,84401,84402,85304},
        },
        [7850] = { -- Kernobee
            [npcKeys.questStarts] = {2904,79985},
        },
        [7852] = { -- Pratt McGrubben
            [npcKeys.questStarts] = {2821,2847,2848,2849,2850,2851,2852,2853,7733,82657},
            [npcKeys.questEnds] = {2821,2847,2848,2849,2850,2851,2852,7733,7735,82657},
        },
        [7853] = { -- Scooty
            [npcKeys.questStarts] = {2843,79984,80134},
            [npcKeys.questEnds] = {2842,2843,2904,79984,79985,80133,80134},
        },
        [7854] = { -- Jangdor Swiftstrider
            [npcKeys.questStarts] = {2822,2854,2855,2856,2857,2858,2859,2860,7734,82656},
            [npcKeys.questEnds] = {2822,2854,2855,2856,2857,2858,2859,7734,7738,82656},
        },
        [7855] = { -- Southsea Pirate
            [npcKeys.questStarts] = {90294},
        },
        [7856] = { -- Southsea Freebooter
            [npcKeys.questStarts] = {90294},
        },
        [7866] = { -- Peter Galen
            [npcKeys.questStarts] = {5141,85701},
            [npcKeys.questEnds] = {5141,85701},
        },
        [7867] = { -- Thorkaf Dragoneye
            [npcKeys.questStarts] = {5145,85702},
            [npcKeys.questEnds] = {5145,85702},
        },
        [7868] = { -- Sarah Tanner
            [npcKeys.questStarts] = {5144,85703},
            [npcKeys.questEnds] = {5144,85703},
        },
        [7869] = { -- Brumn Winterhoof
            [npcKeys.questStarts] = {5146,85704},
            [npcKeys.questEnds] = {5146,85704},
        },
        [7870] = { -- Caryssia Moonhunter
            [npcKeys.questStarts] = {5143,85705},
            [npcKeys.questEnds] = {5143,85705},
        },
        [7871] = { -- Se'Jib
            [npcKeys.questStarts] = {5148,85706},
            [npcKeys.questEnds] = {5148,85706},
        },
        [7884] = { -- Fraggar Thundermantle
            [npcKeys.questStarts] = {2877,2880,2881,82210},
            [npcKeys.questEnds] = {2877,2880,2881,82210},
        },
        [7917] = { -- Brother Sarno
            [npcKeys.questStarts] = {2923,80138},
        },
        [7937] = { -- High Tinker Mekkatorque
            [npcKeys.questStarts] = {2929,80180},
            [npcKeys.questEnds] = {2929,80180,80324},
        },
        [7944] = { -- Tinkmaster Overspark
            [npcKeys.questStarts] = {2922,3640,3641,3645,80137},
            [npcKeys.questEnds] = {2922,2923,3630,3632,3634,3640,3641,3645,80137,80138},
        },
        [7950] = { -- Master Mechanic Castpipe
            [npcKeys.questStarts] = {2930,80143},
            [npcKeys.questEnds] = {2930,2931,80142,80143},
        },
        [8139] = { -- Jabbey
            [npcKeys.questStarts] = {90294},
        },
        [8379] = { -- Archmage Xylem
            [npcKeys.questStarts] = {3565,8235,8236,8251,8252,8253,9362,9364,82110,82114},
            [npcKeys.questEnds] = {3561,8234,8235,8251,8252,8253,9362,9364,82114},
        },
        [8383] = { -- Master Wood
            [npcKeys.questStarts] = {78297},
            [npcKeys.questEnds] = {78287},
        },
        [8405] = { -- Ogtinc
            [npcKeys.questStarts] = {8153,8231,8232,8255,8256,8257,82108,82111},
            [npcKeys.questEnds] = {8151,8153,8231,8232,8254,8255,8256,82108},
        },
        [8496] = { -- Liv Rizzlefix
            [npcKeys.questStarts] = {4146,4502,82101},
        },
        [8579] = { -- Yeh'kinya
            [npcKeys.questStarts] = {3520,3527,3528,4787,82095},
            [npcKeys.questEnds] = {3520,3527,3528,4787,8181,82095},
        },
        [8603] = { -- Carrion Grub
            [npcKeys.questStarts] = {90332},
        },
        [8606] = { -- Living Decay
            [npcKeys.questStarts] = {90331},
        },
        [8607] = { -- Rotting Sludge
            [npcKeys.questStarts] = {90331},
        },
        [8997] = { -- Gershala Nightwhisper
            [npcKeys.questStarts] = {1275,78926},
            [npcKeys.questEnds] = {1275,3765,78926},
        },
        [9087] = { -- Bashana Runetotem
            [npcKeys.questEnds] = {3782,3786,3804,6561,78917,78922},
        },
        [9118] = { -- Larion
            [npcKeys.questEnds] = {4145,4146,4148,82101},
        },
        [9119] = { -- Muigin
            [npcKeys.questEnds] = {4141,4143,4144,82099},
        },
        [9619] = { -- Torwa Pathfinder
            [npcKeys.questStarts] = {4289,4290,4291,4292,4301,9051,9052,9053,82112},
            [npcKeys.questEnds] = {4289,4290,4291,4292,4301,9051,9052,9053,9063,82112},
        },
        [10429] = { -- Warchief Rend Blackhand
            [npcKeys.questStarts] = {85521,85882},
        },
        [10637] = { -- Malyfous Darkhammer
            [npcKeys.questStarts] = {5124,84495},
            [npcKeys.questEnds] = {5047,5063,5067,5068,5103,5124,84495},
        },
        [10667] = { -- Chromie
            [npcKeys.questStarts] = {4971,4972,4973,5154,5210,5721,85066,85068},
            [npcKeys.questEnds] = {4971,4972,4973,5153,5154,5941,85065},
        },
        [10758] = { -- Grimtotem Bandit
            [npcKeys.questStarts] = {90232},
        },
        [10759] = { -- Grimtotem Stomper
            [npcKeys.questStarts] = {90232},
        },
        [10760] = { -- Grimtotem Geomancer
            [npcKeys.questStarts] = {90232},
        },
        [10761] = { -- Grimtotem Reaver
            [npcKeys.questStarts] = {90232},
        },
        [10838] = { -- Commander Ashlam Valorfist
            [npcKeys.questStarts] = {211,5092,5097,5215,5237,5533,8414,8418,82106},
            [npcKeys.questEnds] = {211,5066,5090,5091,5092,5097,5237,8415,8416,8418,82106},
        },
        [10922] = { -- Greta Mosshoof
            [npcKeys.questEnds] = {5155,5157,5159,5165,5242,8257,82111},
        },
        [10929] = { -- Haleh
            [npcKeys.questEnds] = {5160,5161,6501,6502,85388},
        },
        [11034] = { -- Lord Maxwell Tyrosus
            [npcKeys.questStarts] = {5265,87509,89443,89563},
            [npcKeys.questEnds] = {5264,8859,87508,89442,89475,89563},
        },
        [11036] = { -- Leonid Barthalomew the Revered
            [npcKeys.questStarts] = {5243,5463,5465,5531,87459,87493,87498,89562,89567},
            [npcKeys.questEnds] = {5243,5462,5464,5522,87459,87497,89229,89562},
        },
        [11039] = { -- Duke Nicholas Zverenhoff
            [npcKeys.questStarts] = {5251,5263,5264,5405,5508,5509,5510,85963,85964,85965,85966},
            [npcKeys.questEnds] = {5251,5262,5263,5503,5508,5509,5510,6030,85963,85964,85965,85966},
        },
        [11082] = { -- Stratholme Courier
            [npcKeys.questStarts] = {90349,90350},
        },
        [11146] = { -- Ironus Coldsteel
            [npcKeys.questStarts] = {5284,82662},
            [npcKeys.questEnds] = {5284,82662},
        },
        [11177] = { -- Okothos Ironrager
            [npcKeys.questStarts] = {5301,85712},
            [npcKeys.questEnds] = {5301,85712},
        },
        [11178] = { -- Borgosh Corebender
            [npcKeys.questStarts] = {5302,82665},
            [npcKeys.questEnds] = {5302,82665},
        },
        [11191] = { -- Lilith the Lithe
            [npcKeys.questStarts] = {5305,84496},
            [npcKeys.questEnds] = {5305,84496},
        },
        [11192] = { -- Kilram
            [npcKeys.questStarts] = {5306,85699},
            [npcKeys.questEnds] = {5306,85699},
        },
        [11193] = { -- Seril Scourgebane
            [npcKeys.questStarts] = {5307,85700},
            [npcKeys.questEnds] = {5307,85700},
        },
        [11397] = { -- Nara Meideros
            [npcKeys.questStarts] = {5632,5638,78194,78195},
            [npcKeys.questEnds] = {78194},
        },
        [11438] = { -- Bibbly F'utzbuckle
            [npcKeys.questStarts] = {5501,79235},
            [npcKeys.questEnds] = {5501,79229},
        },
        [11536] = { -- Quartermaster Miranda Breechlock
            [npcKeys.questStarts] = {5513,5517,9221,9222,9223,9224,9225,9226,9227,9228,88721,88722,88723,88724,88725,88726,88727,88728},
            [npcKeys.questEnds] = {5513,5517,9221,9222,9223,9224,9225,9226,9227,9228,88721,88722,88723,88724,88725,88726,88727,88728},
        },
        [11736] = { -- Stonelash Pincer
            [npcKeys.questStarts] = {90334},
        },
        [11811] = { -- Narain Soothfancy
            [npcKeys.questStarts] = {8576,8577,8584,8597,8606,8620,8728,8729,86444,86445},
            [npcKeys.questEnds] = {8575,8576,8578,8587,8598,8599,8606,8620,8728,86444},
        },
        [11832] = { -- Keeper Remulos
            [npcKeys.questStarts] = {8447,8735,8736,8741,86443,86680,90244},
            [npcKeys.questEnds] = {7066,8446,8447,8734,8735,8736,86443,86679,86680},
        },
        [11880] = { -- Twilight Avenger
            [npcKeys.questStarts] = {90334},
        },
        [11910] = { -- Grimtotem Ruffian
            [npcKeys.questStarts] = {90023},
        },
        [11911] = { -- Grimtotem Mercenary
            [npcKeys.questStarts] = {90023},
        },
        [11912] = { -- Grimtotem Brute
            [npcKeys.questStarts] = {90023},
        },
        [11913] = { -- Grimtotem Sorcerer
            [npcKeys.questStarts] = {90023},
        },
        [12042] = { -- Loganaar
            [npcKeys.questStarts] = {9063,78229,82018},
            [npcKeys.questEnds] = {78229,82017,82020,90088,90089,90090},
        },
        [12179] = { -- Tortured Sentinel
            [npcKeys.questStarts] = {90334},
        },
        [12736] = { -- Je'neu Sancrea
            [npcKeys.questStarts] = {6563,6565,6921,78506,78537,78561,78575,78927,85772},
            [npcKeys.questEnds] = {824,6562,6563,6564,6565,6921,6922,78506,78537,78561,78575,78920,78927,85772},
        },
        [12944] = { -- Lokhtos Darkbargainer
            [npcKeys.questEnds] = {6642,6643,6644,6645,6646,7604,84338},
        },
        [13020] = { -- Vaelastrasz the Corrupt
            [npcKeys.questStarts] = {8730,86442},
        },
        [13157] = { -- Makasgar
            [npcKeys.questStarts] = {90180},
        },
        [13278] = { -- Duke Hydraxis
            [npcKeys.questStarts] = {6804,6805,6821,6822,6823,6824,7486,84545,85971,85972,85973,85974},
            [npcKeys.questEnds] = {6804,6805,6821,6822,6823,6824,85971,85972,85973,85974},
        },
        [13444] = { -- Greatfather Winter
            [npcKeys.questEnds] = {7022,7023,7025,7045,8827,79486},
        },
        [13445] = { -- Great-father Winter
            [npcKeys.questEnds] = {6961,6962,6984,7021,7024,8828,79487},
        },
        [14347] = { -- Highlord Demitrian
            [npcKeys.questStarts] = {7786,85442},
        },
        [14353] = { -- Mizzle the Crafty
            [npcKeys.questEnds] = {90627},
        },
        [14368] = { -- Lorekeeper Lydros
            [npcKeys.questStarts] = {7463,7483,7484,7485,7509,84557},
            [npcKeys.questEnds] = {7463,7483,7484,7485,7507,7508,7509,7649,7650,7651,84555,84556,84557},
        },
        [14382] = { -- Lorekeeper Mykos
            [npcKeys.questEnds] = {7501,7502,7503,84551},
        },
        [14383] = { -- Lorekeeper Kildrath
            [npcKeys.questEnds] = {7498,7499,7500,84548,84549,84550},
        },
        [14392] = { -- Overlord Runthak
            [npcKeys.questEnds] = {7491,7493,84561,85658},
        },
        [14394] = { -- Major Mattingly
            [npcKeys.questEnds] = {7496,7497,84560,85659},
        },
        [14401] = { -- Master Elemental Shaper Krixix
            [npcKeys.questStarts] = {85557,85558},
            [npcKeys.questEnds] = {85556,85557,85558},
        },
        [14470] = { -- Impsy
            [npcKeys.questStarts] = {7602,7603,8420,8421,8422,82115},
            [npcKeys.questEnds] = {7601,7602,8419,8420,8421,8422,82115},
        },
        [14494] = { -- Eris Havenfire
            [npcKeys.questStarts] = {7621,7622,84590},
            [npcKeys.questEnds] = {7621,7622,84590},
        },
        [14524] = { -- Vartrus the Ancient
            [npcKeys.questStarts] = {7633,7636,84546},
            [npcKeys.questEnds] = {7632,7633,7636,84546},
        },
        [14624] = { -- Master Smith Burninate
            [npcKeys.questStarts] = {7722,7736,7737,8241,8242,84356},
            [npcKeys.questEnds] = {7722,7736,7737,8241,8242,84356},
        },
        [14625] = { -- Overseer Oilfist
            [npcKeys.questStarts] = {84360,85975,85976,85977,85978},
            [npcKeys.questEnds] = {8858,84360,85975,85976,85977,85978},
        },
        [14626] = { -- Taskmaster Scrange
            [npcKeys.questStarts] = {84351,84355},
            [npcKeys.questEnds] = {7728,7729,84351,84355},
        },
        [14627] = { -- Hansel Heavyhands
            [npcKeys.questStarts] = {7723,7724,7727,84348,84372},
            [npcKeys.questEnds] = {7723,7724,7727,84348,84372},
        },
        [14628] = { -- Evonice Sootsmoker
            [npcKeys.questStarts] = {84350,84359},
            [npcKeys.questEnds] = {7704,84350,84359},
        },
        [14634] = { -- Lookout Captain Lolo Longstriker
            [npcKeys.questStarts] = {84349},
            [npcKeys.questEnds] = {7701,84349},
        },
        [14720] = { -- High Overlord Saurfang
            [npcKeys.questEnds] = {7784,85644,88968},
        },
        [14721] = { -- Field Marshal Stonebridge
            [npcKeys.questEnds] = {7782,85643,88969},
        },
        [14829] = { -- Yebb Neblegear
            [npcKeys.questStarts] = {7899,7900,7901,7902,7903,7943,8222,8223,79588,79589,80417,82271,82272,82273,82274,82323},
            [npcKeys.questEnds] = {7899,7900,7901,7902,7903,7943,8222,8223,79588,79589,80417,82271,82272,82273,82274,82323},
        },
        [14832] = { -- Kerri Hicks
            [npcKeys.questStarts] = {7889,7890,7891,7892,7893,7939,79590,79593,80421,82275,82276,82277},
            [npcKeys.questEnds] = {7889,7890,7891,7892,7893,7939,79590,79593,80421,82275,82276,82277},
        },
        [14833] = { -- Chronos
            [npcKeys.questStarts] = {7881,7882,7883,7884,7885,7941,79592,79595,80423,82281,82282,82283},
            [npcKeys.questEnds] = {7881,7882,7883,7884,7885,7941,79592,79595,80423,82281,82282,82283},
        },
        [14841] = { -- Rinling
            [npcKeys.questStarts] = {7894,7895,7896,7897,7898,7942,79591,79594,80422,82278,82279,82280},
            [npcKeys.questEnds] = {7894,7895,7896,7897,7898,7942,79591,79594,80422,82278,82279,82280},
        },
        [14847] = { -- Professor Thaddeus Paleo
            [npcKeys.questEnds] = {7907,7927,7928,7929,82055,82056,82057,82058,86760,86761,86762,86763},
        },
        [14875] = { -- Molthor
            [npcKeys.questEnds] = {8182,8183,82081,82083,85660},
        },
        [14887] = { -- Ysondre
            [npcKeys.questStarts] = {86679},
        },
        [14888] = { -- Lethon
            [npcKeys.questStarts] = {86679},
        },
        [14889] = { -- Emeriss
            [npcKeys.questStarts] = {86679},
        },
        [14890] = { -- Taerar
            [npcKeys.questStarts] = {86679},
        },
        [14902] = { -- Jin'rokh the Breaker
            [npcKeys.questStarts] = {8041,8042,8043,8044,8045,8046,8047,8048,8053,8054,8055,8058,8078,8079,85612,85613,85614,85615,85617,85618,85619,85620},
            [npcKeys.questEnds] = {8041,8042,8043,8044,8045,8046,8047,8048,8053,8054,8055,8058,8078,8079,85612,85613,85614,85615,85617,85618,85619,85620},
        },
        [14903] = { -- Al'tabim the All-Seeing
            [npcKeys.questStarts] = {8049,8050,8051,8052,8059,8060,8061,8068,8069,8070,8071,8076,8077,8101,8102,8103,8104,8106,8107,8108,8109,85616,85622,85623,85624,85625,85626,85627,85628,85629,85630,85631,85632},
            [npcKeys.questEnds] = {8049,8050,8051,8052,8059,8060,8061,8068,8069,8070,8071,8076,8077,8101,8102,8103,8104,8106,8107,8108,8109,85616,85622,85623,85624,85625,85626,85627,85628,85629,85630,85631,85632},
        },
        [14904] = { -- Maywiki of Zuldazar
            [npcKeys.questStarts] = {8056,8057,8064,8065,8074,8075,8110,8111,8112,8113,8116,8117,8118,8119,85604,85605,85606,85607,85608,85609,85610,85611},
            [npcKeys.questEnds] = {8056,8057,8064,8065,8074,8075,8110,8111,8112,8113,8116,8117,8118,8119,85604,85605,85606,85607,85608,85609,85610,85611},
        },
        [14905] = { -- Falthir the Sightless
            [npcKeys.questStarts] = {8062,8063,8066,8067,8072,8073,8141,8142,8143,8144,8145,8146,8147,8148,85633,85634,85635,85636,85637,85638,85639,85640},
            [npcKeys.questEnds] = {8062,8063,8066,8067,8072,8073,8141,8142,8143,8144,8145,8146,8147,8148,85633,85634,85635,85636,85637,85638,85639,85640},
        },
        [14910] = { -- Exzhal
            [npcKeys.questStarts] = {8201,85983,85984,85985,85986},
            [npcKeys.questEnds] = {8201,85983,85984,85985,85986},
        },
        [14984] = { -- Sergeant Maclear
            [npcKeys.questStarts] = {79990},
            [npcKeys.questEnds] = {79990},
        },
        [15022] = { -- Deathstalker Mortis
            [npcKeys.questStarts] = {79991},
            [npcKeys.questEnds] = {79991},
        },
        [15042] = { -- Zanza the Restless
            [npcKeys.questStarts] = {8184,8185,8186,8187,8188,8189,8190,8191,8192,9208,9209,9210,85595,85596,85597,85598,85599,85600,85601,85602,85603},
            [npcKeys.questEnds] = {8184,8185,8186,8187,8188,8189,8190,8191,8192,9208,9209,9210,85595,85596,85597,85598,85599,85600,85601,85602,85603},
        },
        [15076] = { -- Zandalarian Emissary
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{27.2, 77.0},{39.5, 5.0}},
            },
        },
        [15176] = { -- Vargus
            [npcKeys.questStarts] = {8548,8572,8573,8574,86675,86676,86677,86678},
            [npcKeys.questEnds] = {8548,8572,8573,8574,8783,8800,8809,86675,86676},
        },
        [15181] = { -- Commander Mar'alith
            [npcKeys.questStarts] = {8304,8306,85150,85248,85250},
            [npcKeys.questEnds] = {8287,8304,8306,8498,8501,8502,8538,8539,8687,8770,8771,8772,8773,8774,8775,8776,8777,8791,85061,85150,85248,86673},
        },
        [15192] = { -- Anachronos
            [npcKeys.questStarts] = {8305,8555,8742,8747,8748,8749,8750,8751,8752,8753,8754,8755,8756,8757,8758,8759,8760,8761,8764,8765,8766,9251,9257,9269,9270,9271,87441,87443},
            [npcKeys.questEnds] = {8303,8519,8555,8729,8730,8741,8742,8747,8748,8749,8750,8751,8752,8753,8754,8755,8756,8757,8758,8759,8760,8761,8764,8765,8766,8802,9250,9251,9257,9269,9270,9271,86442,86445,86670,87441,87442,87443,87444},
        },
        [15213] = { -- Twilight Overlord
            [npcKeys.questStarts] = {90334},
        },
        [15282] = { -- Aurel Goldleaf
            [npcKeys.questStarts] = {8332,8333,8341,8342,8349,8351,9248,85967,85968,85969,85970},
            [npcKeys.questEnds] = {8331,8332,8333,8341,8342,8343,8829,9248,85967,85968,85969,85970},
        },
        [15378] = { -- Merithra of the Dream
            [npcKeys.questStarts] = {8790,86671,86672},
            [npcKeys.questEnds] = {8790,86671,86672},
        },
        [15379] = { -- Caelestrasz
            [npcKeys.questStarts] = {8802,86670},
        },
        [15395] = { -- Nafien
            [npcKeys.questStarts] = {8461,8465,8467,84777,85987,85988,86160,86161},
            [npcKeys.questEnds] = {8461,8462,8467,84777,85987,85988,86160,86161},
        },
        [15443] = { -- Janela Stouthammer
            [npcKeys.questEnds] = {8780,8781,85798},
        },
        [15693] = { -- Jonathan the Revelator
            [npcKeys.questStarts] = {8745,86449},
            [npcKeys.questEnds] = {8745,86449},
        },
        [15909] = { -- Fariel Starsong
            [npcKeys.questStarts] = {8876,8877,8878,8879,8880,8881,8882,80164,80165,80166,80167,80168,80169,80170},
            [npcKeys.questEnds] = {8876,8877,8878,8879,8880,8881,8882,80164,80165,80166,80167,80168,80169,80170},
        },
        [16016] = { -- Anthion Harmon
            [npcKeys.questStarts] = {8945,8947,8948,8951,8952,8953,8954,8955,8956,8957,8958,8959,9016,9017,9018,9019,9020,9021,9022,84179,84180,84181,84182,84183,84184,84185,84186,84187,84188,84189,84190,84191,84192,84193,84194},
        },
        [16091] = { -- Dirk Thunderwood
            [npcKeys.questStarts] = {9023,86674},
            [npcKeys.questEnds] = {9023,86674},
        },
        [16112] = { -- Korfax, Champion of the Light
            [npcKeys.questStarts] = {9034,9036,9037,9038,9039,9040,9041,9042,9131,9132,9229,9230,88729},
            [npcKeys.questEnds] = {9034,9036,9037,9038,9039,9040,9041,9042,9131,9132,9229,9230,88729},
        },
        [16113] = { -- Father Inigo Montoy
            [npcKeys.questEnds] = {9111,9112,9113,9114,9115,9116,9117,9118,9120,87360},
        },
        [16117] = { -- Plagued Swine
            [npcKeys.questStarts] = {90331},
        },
        [16361] = { -- Commander Thomas Helleran
            [npcKeys.questStarts] = {9085,9153,88744,88745},
            [npcKeys.questEnds] = {9085,9153,88744,88745},
        },
        [16365] = { -- Master Craftsman Omarion
            [npcKeys.questStarts] = {89447,89448,89449},
            [npcKeys.questEnds] = {89446,89447,89448},
        },
        [16376] = { -- Craftsman Wilhelm
            [npcKeys.questStarts] = {9232,9234,9235,9236,9237,9238,9239,9240,9241,9242,9243,9244,9245,9246,88730,89446},
            [npcKeys.questEnds] = {9232,9233,9234,9235,9236,9237,9238,9239,9240,9241,9242,9243,9244,9245,9246,88730,89445},
        },
        [16381] = { -- Archmage Tarsis Kir-Moldir
            [npcKeys.questEnds] = {87283},
        },
        [16478] = { -- Lieutenant Orrin
            [npcKeys.questEnds] = {9260,9292,88748},
        },
        [16494] = { -- Lieutenant Rukag
            [npcKeys.questEnds] = {9265,9310,88749},
        },
        [16531] = { -- Faint Necrotic Crystal
            [npcKeys.questStarts] = {9310,88748,88749},
        },
        [16786] = { -- Argent Quartermaster
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY]={{54.8,62.13},{54.55,62.22}},
                [zoneIDs.IRONFORGE]={{29.59,61.44},{29.37,60.04}},
                [zoneIDs.DARNASSUS]={{39.11,45.43},{39.55,46.88}},
                [zoneIDs.EASTERN_PLAGUELANDS]={{81.04,59.74},{80.74,59.9}},
            },
            [npcKeys.questStarts] = {9094,9317,9318,9321,9337,9341,87434,87436,87438,87440,88746,88883},
            [npcKeys.questEnds] = {9094,9317,9318,9321,9337,9341,87434,87436,87438,87440,88746,88883},
        },
        [16787] = { -- Argent Outfitter
            [npcKeys.questStarts] = {9320,9333,9334,9335,9336,9343,87433,87435,87437,87439,88747,88882},
            [npcKeys.questEnds] = {9320,9333,9334,9335,9336,9343,87433,87435,87437,87439,88747,88882},
        },
        [17068] = { -- Chief Expeditionary Requisitioner Enkles
            [npcKeys.questStarts] = {86725},
            [npcKeys.questEnds] = {86725},
        },
        [17070] = { -- Apothecary Quinard
            [npcKeys.questStarts] = {86724},
            [npcKeys.questEnds] = {86724},
        },
        [202060] = { -- Frozen Murloc
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{76.8, 51.4}},
                [zoneIDs.TIRISFAL_GLADES] = {{66.4, 40.2}},
            },
            [npcKeys.questStarts] = {90002,90061,90063},
        },
        [202093] = { -- Polymorphed Apprentice
            [npcKeys.questStarts] = {90010},
        },
        [202699] = { -- Baron Aquanis
            [npcKeys.spawns] = {
                [zoneIDs.BLACKFATHOM_DEEPS] = {{-1, -1}},
            },
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [203079] = { -- Wandering Swordsman
            [npcKeys.spawns] = {
                [1] = {{53.5, 47.5}},
                [12] = {{24.6, 75.2},{38.6, 75.2}},
                [14] = {{36, 47.4},{41, 49.4},{55.8, 38.4},{56.6, 26.6}},
                [141] = {{39.6, 37.6},{39.8, 69.4},{43.8, 77},{54.8, 66},{62.6, 71.8}},
                [215] = {{40.4, 53.2},{45.6, 36.4},{60.2, 67.4}},
            },
            [npcKeys.questStarts] = {90092},
        },
        [203226] = { -- Viktoria Woods
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{69.6, 50.6}},
            },
            [npcKeys.questStarts] = {90101},
        },
        [203475] = { -- Liv Bradford
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{22.4, 64.4}},
            },
            [npcKeys.questStarts] = {90124,90355},
            [npcKeys.questEnds] = {90124,90355},
        },
        [203478] = { -- Stuart
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{22.6, 54.2}},
            },
        },
        [204068] = { -- Lady Sarevess
            [npcKeys.spawns] = {
                [zoneIDs.BLACKFATHOM_DEEPS] = {{-1, -1}},
            },
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [204070] = { -- Soboz
            [npcKeys.spawns] = {
                [1] = {{42, 36.6}},
                [14] = {{67.4, 89.2}},
                [1497] = {{24.6, 40.6}},
                [1519] = {{25, 77.6}},
            },
            [npcKeys.questStarts] = {90077,90078,90079,90080},
        },
        [204256] = { -- Damien Kane
            [npcKeys.questStarts] = {90074},
        },
        [204503] = { -- Dead Acolyte
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{56.4, 57.8}},
            },
            [npcKeys.questStarts] = {90071},
        },
        [204827] = { -- Adventurer's Remains
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{43, 49.4}},
                [zoneIDs.ELWYNN_FOREST] = {{52.2, 84.4}},
                [zoneIDs.DUROTAR] = {{48, 79.4}},
                [zoneIDs.TELDRASSIL] = {{33.6, 35.4}},
                [zoneIDs.MULGORE] = {{60.4, 33.4}},
            },
            [npcKeys.questStarts] = {90058,90059,90060,90121},
            [npcKeys.questEnds] = {90121},
        },
        [204989] = { -- Wounded Adventurer
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{61.8, 47.6}},
            },
            [npcKeys.questStarts] = {90354},
            [npcKeys.questEnds] = {90354},
        },
        [205153] = { -- Ada Gelhardt
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{4.4, 28.2}},
            },
            [npcKeys.questStarts] = {90117},
            [npcKeys.questEnds] = {90117},
        },
        [205278] = { -- Brother Romulus
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{38.4, 27.4}},
            },
            [npcKeys.questStarts] = {90117},
        },
        [205382] = { -- Mokwa
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE] = {{35.8, 57.2}},
            },
            [npcKeys.questStarts] = {90171},
        },
        [205635] = { -- Takoda Sunmane
            [npcKeys.questStarts] = {90209},
        },
        [205692] = { -- Rustling Bush
            [npcKeys.questStarts] = {90082},
        },
        [206248] = { -- Wooden Effigy
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{66.8, 58}},
                [zoneIDs.MULGORE] = {{37.4, 49.6}},
            },
            [npcKeys.questStarts] = {90054,90055},
        },
        [207515] = { -- Lurkmane
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE] = {{30.6, 61.2}},
            },
            [npcKeys.questStarts] = {90093},
        },
        [207577] = { -- Lunar Stone
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{52.8, 79.8}},
                [zoneIDs.MULGORE] = {{35.2, 69.6}},
            },
            [npcKeys.questStarts] = {90057},
        },
        [207637] = { -- Vateya Timberhoof
            [npcKeys.questStarts] = {90104},
        },
        [207743] = { -- Netali Proudwind
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{28.6, 18.2}},
            },
            [npcKeys.questStarts] = {90110},
            [npcKeys.questEnds] = {90110},
        },
        [207754] = { -- Mooart
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{26.6,19.8}},
            },
        },
        [207957] = { -- Vahi Bonesplitter
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{53, 43.4}},
            },
            [npcKeys.questStarts] = {90103},
        },
        [208023] = { -- Gru'ark
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{58.8, 53.6}},
            },
        },
        [208124] = { -- Raluk
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{68.6, 71.6}},
            },
            [npcKeys.questStarts] = {90170},
        },
        [208179] = { -- Rustling Bush
            [npcKeys.questStarts] = {90082},
        },
        [208184] = { -- Razzil
            [npcKeys.questStarts] = {90208},
        },
        [208196] = { -- Gillgar
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{28.4, 46.8}},
            },
            [npcKeys.questStarts] = {90005,90093,90095,90159},
        },
        [208226] = { -- Darmak Bloodhowl
            [npcKeys.questStarts] = {90075},
        },
        [208275] = { -- Frozen Makrura
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{58.6, 45.6}},
            },
            [npcKeys.questStarts] = {90003,90062,90219},
        },
        [208518] = { -- Gaeriyan
            [npcKeys.questStarts] = {},
            [npcKeys.questEnds] = {},
        },
        [208619] = { -- Dorac Graves
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{47.2, 71.2}},
            },
            [npcKeys.questStarts] = {90105},
        },
        [208638] = { -- Fyodi
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{35.4,37.4},{30.4,41.2}},
            },
            [npcKeys.questStarts] = {90093,90095},
        },
        [208652] = { -- Junni Steelpass
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{46.4, 53.2}},
            },
            [npcKeys.questStarts] = {90100},
        },
        [208682] = { -- Denton Bleakway
            [npcKeys.questStarts] = {90076},
        },
        [208711] = { -- Toby
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{63.6, 50.2}},
            },
            [npcKeys.questStarts] = {90206},
        },
        [208712] = { -- Odd Melon
            [npcKeys.questStarts] = {90011},
        },
        [208752] = { -- Frozen Trogg
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{69.2, 58.2}},
            },
            [npcKeys.questStarts] = {90001,90039},
        },
        [208802] = { -- Wounded Adventurer
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{25.4, 43.6}},
            },
            [npcKeys.questStarts] = {90354},
            [npcKeys.questEnds] = {90354},
        },
        [208812] = { -- Jorul
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{37.8, 42.4}},
            },
            [npcKeys.questStarts] = {90167},
        },
        [208919] = { -- Blueheart
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{61.6, 51.4}},
            },
        },
        [208841] = { -- Revered Champion
            [npcKeys.questStarts] = {84124},
        },
        [208886] = { -- Blackrat
            [npcKeys.questStarts] = {90200},
        },
        [208920] = { -- Penny Hawkins
            [npcKeys.questStarts] = {90111},
            [npcKeys.questEnds] = {90111},
        },
        [208927] = { -- Dead Acolyte
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{76.4, 44.8}},
            },
            [npcKeys.questStarts] = {90072},
        },
        [208975] = { -- Rustling Bush
            [npcKeys.questStarts] = {90082},
        },
        [209002] = { -- Gaklik Voidtwist
            [npcKeys.questStarts] = {90073},
        },
        [209004] = { -- Bruart
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{71.2, 73.2}},
            },
        },
        [209524] = { -- Patrolling Cheetah
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{44.4, 55.4}},
            },
            [npcKeys.questStarts] = {90176},
        },
        [209607] = { -- Lieutenant Stonebrew
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {},
            },
            [npcKeys.questStarts] = {90115},
            [npcKeys.questEnds] = {90115},
        },
        [209608] = { -- Delwynna
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{63.4, 22}},
            },
            [npcKeys.questStarts] = {90102},
        },
        [209678] = { -- Twilight Lord Kelris
            [npcKeys.spawns] = {
                [zoneIDs.BLACKFATHOM_DEEPS] = {{-1, -1}},
            },
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [209742] = { -- Desert Mirage
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{57.6, 35.8}},
            },
            [npcKeys.questStarts] = {90188,90203},
        },
        [209797] = { -- Bruuz
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{64.8, 39.8}},
            },
            [npcKeys.questStarts] = {90142,90153},
        },
        [209811] = { -- Rustling Bush
            [npcKeys.questStarts] = {90082},
        },
        [209872] = { -- Syllart
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{56.6, 57.8}},
            },
        },
        [209908] = { -- Heretic Idol
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{71.8, 27.0}},
            },
            [npcKeys.questStarts] = {90189},
        },
        [209928] = { -- Mowgh
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{48.0, 31.6}},
            },
            [npcKeys.questStarts] = {90168},
        },
        [209948] = { -- Relaeron
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{39.2, 9.0}},
            },
            [npcKeys.questStarts] = {90207},
        },
        [209954] = { -- Demonic Remains
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{72.6, 68.8}},
            },
            [npcKeys.questStarts] = {90064},
        },
        [209958] = { -- Graix
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{72.6, 68.8}},
            },
            [npcKeys.questStarts] = {90064},
        },
        [210107] = { -- Kackle
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{55.0, 55.4}},
            },
            [npcKeys.questStarts] = {90152},
        },
        [210451] = { -- Lady Sedorax
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{55.4, 36.6}},
            },
            [npcKeys.questStarts] = {90113},
            [npcKeys.questEnds] = {90113},
        },
        [210482] = { -- Paxnozz
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{47.8, 16.0}},
            },
            [npcKeys.questStarts] = {90141,90150},
        },
        [210483] = { -- Aggressive Squashling
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{51.2, 22.3},{54, 31.8},{44.6, 35.2},{38.4, 52.5},{62.5, 61.1}},
            },
            [npcKeys.questStarts] = {90154},
        },
        [210501] = { -- Harvest Reaper Prototype
            [npcKeys.questStarts] = {90036},
        },
        [210533] = { -- Silverspur
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{35.6, 38.4}},
            },
            [npcKeys.questStarts] = {90172},
        },
        [210537] = { -- Undying Laborer
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{44.9, 24},{31.5, 45}},
            },
            [npcKeys.questStarts] = {90119,90163},
            [npcKeys.questEnds] = {90119},
        },
        [210549] = { -- Defias Scout
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{51.2, 46.8},{51.6, 55.6}},
            },
            [npcKeys.questStarts] = {90151,90211},
        },
        [210802] = { -- Webbed Victim
            [npcKeys.questStarts] = {90353},
        },
        [210845] = { -- Jixo Madrocket
            [npcKeys.spawns] = {
                [zoneIDs.STONETALON_MOUNTAINS] = {{59.2, 62.4}},
            },
        },
        [210995] = { -- Alonso
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{43.4, 70.4}},
            },
        },
        [211022] = { -- Owen Thadd
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{73.4, 33}},
            },
            [npcKeys.questStarts] = {82084},
            [npcKeys.friendlyToFaction] = "H",
        },
        [211033] = { -- Garion Wendell
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.8, 80.2}},
            },
            [npcKeys.questStarts] = {78124,78127,78142,78143,78145,78146,78147,78148,78149,78150,79097,79535,79536,79905,79947,79948,79949,79950,79951,79952,79953,81947,81949,81951,81952,81953,81954,81955,81956,82084,82208},
            [npcKeys.friendlyToFaction] = "A",
        },
        [211146] = { -- Lost Adventurer
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {},
            },
            [npcKeys.questStarts] = {90353},
            [npcKeys.questEnds] = {90353},
        },
        [211653] = { -- Grizzby
            [npcKeys.questStarts] = {78265,78266,78267,78287,78288,82850,82851,82853,90019,90024,90025,90026,90027,90028,90029,90030,90031},
        },
        [211736] = { -- Grizzled Protector
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {},
            },
            [npcKeys.questStarts] = {90175},
        },
        [211951] = { -- Koartul
            [npcKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{60.8, 31.8}},
            },
            [npcKeys.questStarts] = {90083},
        },
        [211965] = { -- Carrodin
            [npcKeys.spawns] = {
                [zoneIDs.WETLANDS] = {{46.6, 65.6}},
            },
            [npcKeys.questStarts] = {90081,90094},
        },
        [211200] = { -- Agon
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{65.1, 23.7}},
            },
        },
        [212186] = { -- Grugimdern
            [npcKeys.questStarts] = {90056},
        },
        [212209] = { -- Vodyanoi
            [npcKeys.questStarts] = {90056},
        },
        [212252] = { -- Harvest Golem V000-A
            [npcKeys.spawns] = {},
        },
        [212261] = { -- Awakened Lich
            [npcKeys.spawns] = {},
            [npcKeys.questStarts] = {90014,90091},
        },
        [212598] = { -- Recke Grinnes
            [npcKeys.questStarts] = {90143},
        },
        [212694] = { -- Hirzek
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{43.2, 78.6}},
            },
        },
        [212699] = { -- Silverwing Archer
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
            [npcKeys.questStarts] = {79098},
        },
        [212703] = { -- Silverwing Dryad
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
            [npcKeys.questStarts] = {79098},
        },
        [212706] = { -- Silverwing Druid
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
            [npcKeys.questStarts] = {79098},
        },
        [212707] = { -- Larodar
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{51.6, 54.6}},
            },
            [npcKeys.questStarts] = {79098},
        },
        [212727] = { -- Warsong Grunt
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
            [npcKeys.questStarts] = {79090},
        },
        [212728] = { -- Warsong Raider
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
            [npcKeys.questStarts] = {79090},
        },
        [212729] = { -- Warsong Shaman
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
            [npcKeys.questStarts] = {79090},
        },
        [212730] = { -- Tojara
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{53.6, 54.2}},
            },
            [npcKeys.questStarts] = {79090},
        },
        [212763] = { -- Sadistic Fiend
            [npcKeys.questStarts] = {90037},
        },
        [212801] = { -- Jubei
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.6, 36.4}},
            },
            [npcKeys.questStarts] = {79090},
        },
        [212802] = { -- Moogul the Sly
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{70.2, 62.8}},
            },
            [npcKeys.questStarts] = {79090},
        },
        [212803] = { -- Ceredwyn
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{73.4, 73.4}},
            },
            [npcKeys.questStarts] = {79098},
        },
        [212804] = { -- Centrius
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.8}},
            },
            [npcKeys.questStarts] = {79098},
        },
        [212809] = { -- Wailing Spirit
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {{59.6, 71.4}},
            },
            [npcKeys.questStarts] = {90166},
        },
        [212837] = { -- Primordial Anomaly
            [npcKeys.spawns] = {
                [zoneIDs.STONETALON_MOUNTAINS] = {{32.6, 67.6}},
            },
            [npcKeys.questStarts] = {90202},
        },
        [212969] = { -- Kazragore
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{39.4, 67.2}},
            },
        },
        [212970] = { -- Felore Moonray
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{59.8, 72.4}},
            },
        },
        [213077] = { -- Elaine Compton
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{54.4, 61.2}},
            },
            [npcKeys.questStarts] = {90012,90040,90042,90044,90046,90048,90050,90052},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214070] = { -- Jornah
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{51.4, 63.8}},
            },
            [npcKeys.questStarts] = {90013,90041,90043,90045,90047,90049,90051,90053},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214096] = { -- Dokimi
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{39.2, 53.4}},
            },
            [npcKeys.questStarts] = {90013,90041,90043,90045,90047,90049,90051,90053},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214098] = { -- Gishah
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{64, 39.2}},
            },
            [npcKeys.questStarts] = {90013,90041,90043,90045,90047,90049,90051,90053},
            [npcKeys.friendlyToFaction] = "H",
        },
        [214099] = { -- Tamelyn Aldridge
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{24.4, 67.6}},
            },
            [npcKeys.questStarts] = {90012,90040,90042,90044,90046,90048,90050,90052},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214101] = { -- Marcy Baker
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{59.8, 56.4}},
            },
            [npcKeys.questStarts] = {78611,78612,78872,79100,79101,79102,79103,80307,80308,80309,82307,82308,82309,90012,90040,90042,90044,90046,90048,90050,90052},
            [npcKeys.friendlyToFaction] = "A",
        },
        [214456] = { -- Dro'zem the Blasphemous
            [npcKeys.spawns] = {
                [zoneIDs.REDRIDGE_MOUNTAINS] = {{35.4, 8.6},{64.2, 45.8},{77.4, 69.4}},
            },
            [npcKeys.questStarts] = {90122},
            [npcKeys.questEnds] = {90122},
        },
        [214519] = { -- Incinerator Gar'im
            [npcKeys.spawns] = {
                [zoneIDs.REDRIDGE_MOUNTAINS] = {{77.6, 85.8}},
            },
            [npcKeys.questStarts] = {90070},
        },
        [214954] = { -- Rix Xizzix
            [npcKeys.questStarts] = {90323},
        },
        [215062] = { -- Supplicant
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{39.50,29.37}},
            },
        },
        [215850] = { -- Raszel Ander
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216289] = { -- Orokai
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{41.2, 43.6}},
            },
        },
        [216666] = { -- Techbot
            [npcKeys.zoneID] = zoneIDs.GNOMEREGAN,
            [npcKeys.spawns] = {[zoneIDs.GNOMEREGAN]={{-1,-1}}},
            [npcKeys.questStarts] = {79981},
        },
        [216668] = { -- Irradiated Invader
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{20.9,36.02},{22.09,34.14},{19.68,36.71},{19.32,38.8},{21.81,32.2}}},
        },
        [216669] = { -- Caverndeep Pillager
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{21.79,33.69},{20.61,36.96},{18.76,39.16}}},
        },
        [216670] = { -- Caverndeep Looter
            [npcKeys.zoneID] = zoneIDs.GNOMEREGAN,
            [npcKeys.spawns] = {[zoneIDs.GNOMEREGAN]={{-1,-1}}},
        },
        [216671] = { -- Caverndeep Invader
            [npcKeys.zoneID] = zoneIDs.GNOMEREGAN,
            [npcKeys.spawns] = {[zoneIDs.GNOMEREGAN]={{-1,-1}}},
        },
        [216902] = { -- Wulmort Jinglepocket
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{33.7, 67.23}},
            },
            [npcKeys.questStarts] = {79482,79486,79492,79501},
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216915] = { -- Strange Snowman
            [npcKeys.spawns] = {
                [zoneIDs.ALTERAC_MOUNTAINS]={{35.43, 72.45}},
            },
        },
        [216924] = { -- Kaymard Copperpinch
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{53.3, 66.47}},
            },
            [npcKeys.questStarts] = {79483,79487,79495,79502},
            [npcKeys.friendlyToFaction] = "AH",
        },
        [217305] = { -- Ancient Fire Elemental
            [npcKeys.questStarts] = {90234},
        },
        [217387] = { -- Brother Atticus
            [npcKeys.questStarts] = {90248},
        },
        [217392] = { -- Flameseer Dubelen
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE]={{56.4, 21.8}},
            },
            [npcKeys.questStarts] = {90239},
        },
        [217412] = { -- Amaryllis Webb
            [npcKeys.spawns] = {
                [zoneIDs.SWAMP_OF_SORROWS] = {{25.2, 54.6}},
            },
            [npcKeys.questStarts] = {90251,90265},
        },
        [217588] = { -- Arbor Tarantula
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{45.2, 19.6}},
            },
            [npcKeys.questStarts] = {90252,90266},
        },
        [217589] = { -- Hay Weevil
            [npcKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{30.8, 28.6},{54.2, 38.6},{61.2, 55.4}},
            },
            [npcKeys.questStarts] = {90253,90267},
        },
        [217590] = { -- Flesh Picker
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{51.4, 59.8}},
            },
            [npcKeys.questStarts] = {90254,90268},
        },
        [217620] = { -- Reckless Warlock
            [npcKeys.questStarts] = {90257},
        },
        [217669] = { -- Scorched Screeching Roguefeather
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{26.4, 46.4}},
            },
            [npcKeys.questStarts] = {90237},
        },
        [217683] = { -- Altar of the Wind Spirit
            [npcKeys.zoneID] = zoneIDs.THOUSAND_NEEDLES,
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{39.4,42}},
            },
            [npcKeys.questStarts] = {90247},
        },
        [217703] = { -- Singed Highperch Consort
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{10.4, 40.2}},
            },
            [npcKeys.questStarts] = {90236},
        },
        [217706] = { -- Kazragore
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{74.0, 60.6}},
            },
        },
        [217707] = { -- Felore Moonray
            [npcKeys.friendlyToFaction] = "A",
        },
        [217711] = { -- Seared Needles Cougar
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{23.4, 23.4}},
            },
            [npcKeys.questStarts] = {90238},
        },
        [217783] = { -- Bloodscalp Guerrilla
            [npcKeys.questStarts] = {90223},
        },
        [217836] = { -- Needletooth
            [npcKeys.questStarts] = {90233},
        },
        [218019] = { -- Combat Dummy
            [npcKeys.questStarts] = {90224},
        },
        [218020] = { -- Combat Dummy
            [npcKeys.questStarts] = {90224},
        },
        [218021] = { -- Combat Dummy
            [npcKeys.questStarts] = {90224},
        },
        [218115] = { -- Mai'zin
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{31.2, 48.4}},
            },
        },
        [218160]  = { -- Aeonas the Vindicated
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.4, 31.8}},
            },
        },
        [218229] = { -- Captain Aransas
            [npcKeys.questStarts] = {90264},
        },
        [218230] = { -- Wendel Mathers
            [npcKeys.questStarts] = {90264},
        },
        [218237] = { -- Wirdal Wondergear
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.zoneID] = zoneIDs.FERALAS,
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{84.2,43.8}},
            },
        },
        [218240] = { -- Tower Defense Automaton
            [npcKeys.questStarts] = {90323},
        },
        [218249] = { -- Slitherblade Tide Priestess
            [npcKeys.questStarts] = {90235},
        },
        [218273] = { -- Wandering Swordsman
            [npcKeys.questStarts] = {90225},
        },
        [218537] = { -- Mekgineer Thermaplugg
            [npcKeys.questStarts] = {80324,80325},
        },
        [218908] = { -- Scarlet Crusade Assassin
            [npcKeys.questStarts] = {79945},
        },
        [218920] = {
            [npcKeys.spawns] = {
                [zoneIDs.DEADWIND_PASS] = {{52.1,34.12}},
            },
            [npcKeys.questStarts] = {80120,86966,86969,86970},
        },
        [218931] = { -- Dark Rider Deadwind Pass
            [npcKeys.zoneID] = zoneIDs.DEADWIND_PASS,
            [npcKeys.spawns] = {
                [zoneIDs.DEADWIND_PASS] = {{43,29}},
            },
            [npcKeys.questStarts] = {80098},
        },
        [220930] = { -- Frix Xizzix
            [npcKeys.questStarts] = {90323},
        },
        [221282] = { -- Emberspark Dreamsworn
            [npcKeys.questStarts] = {90284},
        },
        [221283] = { -- Dreampyre Imp
            [npcKeys.questStarts] = {90284},
        },
        [221210] = { -- Kroll Mountainshade
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{66.11, 69.28}},
            },
        },
        [221215] = { -- Alara Grovemender
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{49.15, 77.55}},
            },
        },
        [221216] = { -- Elenora Marshwalker
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{32.39, 69.48}},
            },
        },
        [221268] = { -- Doran Dreambough
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{87.23, 43.56}},
            },
        },
        [221269] = { -- Maseara Autumnmoon
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{81.2, 50.5}},
            },
        },
        [221270] = { -- Alyssian Windcaller
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{92, 54.0}},
            },
        },
        [221292] = { -- Dreamhunter Hound
            [npcKeys.questStarts] = {90284},
        },
        [221335] = { -- Elianar Shadowdrinker
            [npcKeys.spawns] = {
                [zoneIDs.THE_HINTERLANDS] = {{53.47, 39.05}},
            },
        },
        [221336] = { -- Serlina Starbright
            [npcKeys.spawns] = {
                [zoneIDs.THE_HINTERLANDS] = {{71.11, 47.98}},
            },
        },
        [221337] = { -- Veanna Cloudsleeper
            [npcKeys.spawns] = {
                [zoneIDs.THE_HINTERLANDS] = {{57.29, 42.80}},
            },
        },
        [221395] = { -- Mellias Earthtender
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{49.65, 15.35}},
            },
        },
        [221398] = { -- Nerene Brooksinger
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{46.00, 16.50}},
            },
        },
        [221399] = { -- Jamniss Treemender
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{40.62, 8.08}},
            },
        },
        [221484] = { -- Scout Thandros
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{51.06,10.54}},
            },
        },
        [221827] = { -- Magister Falath
            [npcKeys.questStarts] = {90275},
        },
        [221828] = { -- Vengeful Spirit
            [npcKeys.questStarts] = {90275},
        },
        [222044] = { -- Twilight Dark Shaman
            [npcKeys.questStarts] = {90324},
        },
        [222188] = { -- Shadowy Figure
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{52.12,40.89}},
            },
        },
        [222228] = { -- Fel Sliver
            [npcKeys.questStarts] = {90285,90293},
        },
        [222233] = { -- Ohk'zi
            [npcKeys.questStarts] = {90281},
        },
        [222243] = { -- Zopilote
            [npcKeys.questStarts] = {90271},
        },
        [222286] = { -- Namida Grimtotem
            [npcKeys.questStarts] = {90269},
        },
        [222288] = { -- Fel Rift
            [npcKeys.questStarts] = {90285,90293,90351},
        },
        [222376] = { -- Groddoc Infant
            [npcKeys.questStarts] = {90292},
        },
        [222405] = { -- Leyline Conflux
            [npcKeys.questStarts] = {90300,90303,90306},
        },
        [222406] = { -- Groddoc Matriarch
            [npcKeys.questStarts] = {90292},
        },
        [222546] = { -- Iodax the Obliterator
            [npcKeys.questStarts] = {90289},
        },
        [222684] = { -- Quartermaster Falinar
            [npcKeys.questStarts] = {90270,90272,90273,90274,90276,90277,90278,90279,90280},
        },
        [222685] = { -- Quartermaster Kyleen
            [npcKeys.questStarts] = {90270,90272,90273,90274,90276,90277,90278,90279,90280},
        },
        [222686] = { -- Quartermaster Alandra
            [npcKeys.questStarts] = {90270,90272,90273,90274,90276,90277,90278,90279,90280},
        },
        [222687] = { -- Quartermaster Valdane
            [npcKeys.questStarts] = {90270,90272,90273,90274,90276,90277,90278,90279,90280},
        },
        [222696] = { -- Fel Crack
            [npcKeys.questStarts] = {90285,90293},
        },
        [222697] = { -- Fel Tear
            [npcKeys.questStarts] = {90285,90293},
        },
        [222698] = { -- Fel Scar
            [npcKeys.questStarts] = {90285,90293,90352},
        },
        [222726] = { -- Tyrant of the Hive
            [npcKeys.questStarts] = {90282},
        },
        [222856] = { -- Odd Totem
            [npcKeys.questStarts] = {90298},
        },
        [222857] = { -- Odd Totem
            [npcKeys.questStarts] = {90298},
        },
        [223061] = { -- Charged Totem
            [npcKeys.questStarts] = {90286},
        },
        [223123] = { -- Diseased Forest Walker
            [npcKeys.questStarts] = {90305},
        },
        [223590] = { -- Shrine of the Watcher
            [npcKeys.questStarts] = {82316,90304},
        },
        [223591] = { -- Echo of a Lost Soul
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{30.0,73.0}},
                [zoneIDs.THE_HINTERLANDS] = {{72.8,68.6}},
                [zoneIDs.SWAMP_OF_SORROWS] = {{50.2,62.0}},
                [zoneIDs.TANARIS] = {{53.8,29.0}},
            },
            [npcKeys.questStarts] = {90302},
        },
        [226797] = { -- Prazik Pilfershard
            [npcKeys.questStarts] = {90342},
        },
        [226799] = { -- Pixi Pilfershard
            [npcKeys.questStarts] = {90341},
        },
        [226982] = { -- Frijidar
            [npcKeys.questStarts] = {90339},
        },
        [227028] = { -- Hellscream's Phantom
            [npcKeys.questStarts] = {90312},
        },
        [227324] = { -- Novice Frost Mage
            [npcKeys.questStarts] = {90336},
        },
        [227385] = { -- Novice Frost Mage
            [npcKeys.questStarts] = {90336},
        },
        [227386] = { -- Novice Frost Mage
            [npcKeys.questStarts] = {90336},
        },
        [227387] = { -- Novice Frost Mage
            [npcKeys.questStarts] = {90336},
        },
        [227464] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
            [npcKeys.questStarts] = {84008},
        },
        [227493] = { -- Sandworm
            [npcKeys.questStarts] = {90335},
        },
        [227511] = { -- Pedestal
            [npcKeys.questStarts] = {90349,90350},
        },
        [227672] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
            [npcKeys.questStarts] = {83808,83822,83935,83936},
        },
        [227673] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
            [npcKeys.questStarts] = {83823},
        },
        [227674] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
        },
        [227746] = { -- Escaped Core Hound
            [npcKeys.questStarts] = {90333},
        },
        [227755] = { -- Estelenn
            [npcKeys.zoneID] = zoneIDs.BURNING_STEPPES,
            [npcKeys.spawns] = {
                -- TODO: Is there a better way? The NPC ID is correct, but the locations are needed for different quests
                [zoneIDs.BURNING_STEPPES] = {{17.03,46.32}},
                [zoneIDs.WINTERSPRING] = {{58,21}},
            },
        },
        [227951] = { -- Edwi Copperbolt
            [npcKeys.questStarts] = {90334,90335},
        },
        [228414] = { -- Heliath
            [npcKeys.questStarts] = {90344},
        },
        [228596] = { -- Vengeful Wisp
            [npcKeys.questStarts] = {90309},
        },
        [228611] = { -- Wandering Swordsman
            [npcKeys.questStarts] = {84317},
        },
        [228620] = { -- Slack-Jawed Ghoul
            [npcKeys.questStarts] = {84318},
        },
        [228814] = { -- Arcterris
            [npcKeys.questStarts] = {90308},
        },
        [228818] = { -- Shrine of Cooperation
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{47,58}}},
        },
        [229897] = { -- Wild Windtwister
            [npcKeys.zoneID] = zoneIDs.MOONGLADE,
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{39,68}},
            },
        },
        [230302] = { -- Lord Kazzak
            [npcKeys.zoneID] = zoneIDs.THE_TAINTED_SCAR,
            [npcKeys.spawns] = {[zoneIDs.THE_TAINTED_SCAR]={{-1,-1}}},
        },
        [230317] = { -- Mokvar
            [npcKeys.questStarts] = {84155,84156,84157,84158,84159,84160,84161,84162,84171,84172,84173,84174,84175,84176,84177,84178,84203,84204,84205,84206,84207,84208,84209,84210},
            [npcKeys.questEnds] = {84155,84156,84157,84158,84159,84160,84161,84162,84171,84172,84173,84174,84175,84176,84177,84178,84187,84188,84189,84190,84191,84192,84193,84194,84203,84204,84205,84206,84207,84208,84209,84210},
        },
        [230319] = { -- Deliana
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE]={{43.53,52.64}}},
            [npcKeys.questStarts] = {84147,84148,84149,84150,84151,84152,84153,84154,84163,84164,84165,84166,84167,84168,84169,84170,84195,84196,84197,84198,84199,84200,84201,84202},
            [npcKeys.questEnds] = {84147,84148,84149,84150,84151,84152,84153,84154,84163,84164,84165,84166,84167,84168,84169,84170,84179,84180,84181,84182,84183,84184,84185,84186,84195,84196,84197,84198,84199,84200,84201,84202},
        },
        [230481] = { -- Earth Elemental Fragment
            [npcKeys.zoneID] = zoneIDs.MOONGLADE,
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{72.4,62.2}},
            },
        },
        [230775] = { -- Rage Talon Quartermaster
            [npcKeys.zoneID] = zoneIDs.LOWER_BLACKROCK_SPIRE,
            [npcKeys.spawns] = {[zoneIDs.LOWER_BLACKROCK_SPIRE] = {{-1, -1}}},
        },
        [231050] = { -- Syndicate Infiltrator
            [npcKeys.zoneID] = zoneIDs.LOWER_BLACKROCK_SPIRE,
            [npcKeys.spawns] = {[zoneIDs.LOWER_BLACKROCK_SPIRE] = {{-1, -1}}},
        },
        [231430] = { -- Caius Blackwood
            [npcKeys.zoneID] = zoneIDs.FELWOOD,
            [npcKeys.spawns] = {[zoneIDs.FELWOOD] = {{35.4,57.8}}},
        },
        [231485] = { -- Procrastimond (actuall this NPC is in "elsewhere", but to get to him you need to use an item in Tanaris)
            [npcKeys.zoneID] = zoneIDs.TANARIS,
            [npcKeys.spawns] = {[zoneIDs.TANARIS] = {{50,28}}},
        },
        [231500] = { -- Gregory
            [npcKeys.questEnds] = {85064,85457,85511},
        },
        [232381] = { -- Valxx Cracklequil
            [npcKeys.questStarts] = {85386,85388},
        },
        [232398] = { -- Primordial Flame
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{15.6,56.6}}},
        },
        [232399] = { -- Outcast Cryomancer
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{63.2,68.9}}},
        },
        [232429] = { -- Magical Stone
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{14.8,56.7}}},
        },
        [232466] = { -- Magical Stone
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{63.2,68.4}}},
        },
        [232529] = { -- Nandieb
            [npcKeys.zoneID] = zoneIDs.WINTERSPRING,
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{50.7,27.9}}},
        },
        [232532] = { -- Fel Interloper
            [npcKeys.spawns] = {}, -- Spawned when closing a Growing Fel Rift (232538)
        },
        [232755] = { -- Van Amburgh
            [npcKeys.zoneID] = zoneIDs.UN_GORO_CRATER,
            [npcKeys.spawns] = {
                [zoneIDs.UN_GORO_CRATER] = {{23.64,33.23}},
            },
        },
        [232924] = { -- Doan Karhan
            [npcKeys.questStarts] = {},
        },
        [232929] = { -- Gregory
            [npcKeys.zoneID] = zoneIDs.WINTERSPRING,
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{53.36,83.59}}},
        },
        [232932] = { -- Gregory
            [npcKeys.questEnds] = {85066,85067,85090},
        },
        [233084] = { -- Estelenn
            [npcKeys.zoneID] = zoneIDs.UN_GORO_CRATER,
            [npcKeys.spawns] = {
                [zoneIDs.UN_GORO_CRATER] = {{23.64,33.23}},
            },
        },
        [233158] = { -- Azgaloth
            [npcKeys.zoneID] = zoneIDs.DEMON_FALL_CANYON,
            [npcKeys.spawns] = {[zoneIDs.DEMON_FALL_CANYON] = {{-1,-1}}},
        },
        [233335] = { -- Rune Broker (Alliance)
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{57.4,26.8}},
                [zoneIDs.IRONFORGE] = {{53.8,14.1}},
                [zoneIDs.DARNASSUS] = {{28.6,38.6}},
                [zoneIDs.ELWYNN_FOREST] = {{48.2,41.5}},
                [zoneIDs.DUN_MOROGH] = {{29.5,72.1}},
                [zoneIDs.TELDRASSIL] = {{58.9,43.7}},
            },
            [npcKeys.questStarts] = {91000},
        },
        [233428] = { -- Rune Broker (Horde)
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{49.5,46}},
                [zoneIDs.THUNDER_BLUFF] = {{22.8,13.8}},
                [zoneIDs.UNDERCITY] = {{79.4,19.8}},
                [zoneIDs.DUROTAR] = {{42.7,68}},
                [zoneIDs.MULGORE] = {{44.3,76.7}},
                [zoneIDs.TIRISFAL_GLADES] = {{31.3,66.4}},
            },
            [npcKeys.questStarts] = {91001},
        },
        [237818] = { -- Harrison Jones
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{52.3,34.08}}},
            [npcKeys.questStarts] = {86968,86971,86972},
        },
        [237819] = { -- Injured Adventurer
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{65.43,78.64}}},
        },
        [237820] = { -- Deceased Adventurer
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{39.99,74.16}}},
        },
        [238376] = { -- Brother Luctus
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{80.56,65.46}},
                [zoneIDs.AZSHARA] = {{32,54}},
                [zoneIDs.BURNING_STEPPES] = {{65.43,55.13}},
                [zoneIDs.SWAMP_OF_SORROWS] = {{32,54}},
                [zoneIDs.WINTERSPRING] = {{58.41,35.97}},
                [zoneIDs.TANARIS] = {{53.9,28.6}},
            },
        },
        [238415] = { -- Grok'lo Mok'lo
            [npcKeys.questStarts] = {90626,90627},
            [npcKeys.questEnds] = {90625,90626},
        },
        [239337] = { -- Lord Maxwell Tyrosus
            [npcKeys.questStarts] = {87517,87518},
            [npcKeys.questEnds] = {87516,87517,87518},
        },
        [239031] = { -- Scarlet Inquisitor Caldoran
            [npcKeys.name] = "Scarlet Inquisitor Caldoran",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{68.3,82.7}}},
            [npcKeys.questStarts] = {87502,87506},
            [npcKeys.questEnds] = {87502},
        },
        [239032] = { -- Commander Beatrix
            [npcKeys.name] = "Commander Beatrix",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{67.8,83.3}}},
            [npcKeys.questStarts] = {87497,87516},
            [npcKeys.questEnds] = {87493,87498,87506,87509},
        },
        [239047] = { -- Scarlet Siege Commander
            [npcKeys.name] = "Scarlet Siege Commander",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{78.4,79.6},{78.4,83.1},{81.1,80.9},{83.2,87.8},{84.4,81.9},{84.9,85.2}}},
        },
        [239054] = { -- Argent Emissary
            [npcKeys.name] = "Argent Emissary",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{67.79,83.27}}},
            [npcKeys.questStarts] = {87508},
            [npcKeys.questEnds] = nil,
        },
        [239152] = { -- Scout the Mage Tower in New Avalon - Bunny
            [npcKeys.name] = "New Avalon Mage Tower",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{98.3,88.4}}},
        },
        [239153] = { -- Scout the Keep in New Avalon - Bunny
            [npcKeys.name] = "New Avalon Keep",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{97.6,83.2}}},
        },
        [239154] = { -- Scout the Cathedral in Tyr's Hand - Bunny
            [npcKeys.name] = "Tyr's Hand Cathedral",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{85.3,84.0}}},
        },
        [240248] = { -- Bryon Steelblade
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{98.48, 84.14}}},
            [npcKeys.questStarts] = {89255,89256,89257,89258,89259,89260,89261,89262},
            [npcKeys.questEnds] = {89255,89256,89257,89258,89259,89260,89261,89262},
            [npcKeys.npcFlags] = npcFlags.REPAIR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Repair",
        },
        [240604] = { -- Carrie Hearthfire
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{95.3,78.38}}},
            [npcKeys.questStarts] = {89224,89236,89245,89253,89341,90518,90519,90520},
        },
        [240607] = { -- Devon Woods
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{95.31,80.24}}},
        },
        [240631] = { -- Taylor Stitchings
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{94.69, 83.54}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Tailoring Supplies",
        },
        [240632] = { -- Tanya Hyde
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{94.24,93.38}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Leatherworking Supplies",
        },
        [240654] = { -- Fizzlefuse
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{62.77,24.31}}},
        },
        [240978] = { -- Apple
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [241006] = { -- Grand Crusader Caldoran
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE] = {{-1,-1}}},
        },
        [241019] = { -- Johnny
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{94.911,91.356}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.minLevel] = 60,
            [npcKeys.maxLevel] = 60,
        },
        [241032] = { -- Fish Barrel
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{63.08,26.35}}},
        },
        [241334] = { -- The Will of the Ashbringer
            [npcKeys.questStarts] = {89232,89301,89303,89442,89451,89473,89474},
            [npcKeys.questEnds] = {89232,89300,89301,89303,89443,90559},
        },
        [241408] = { -- Scarlet Courier
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{99.02,89.07}}},
        },
        [241613] = { -- Kyndra Swiftarrow
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{93.81,90.07}}},
        },
        [241664] = { -- Malorie
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{95.29,78.80}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Food & Drink",
        },
        [241768] = { -- Herod
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241769] = { -- Arcanist Doan
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241770] = { -- Interrogator Vishas
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241772] = { -- Grand Crusader Caldoran
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241834] = { -- Istaria
            [npcKeys.questStarts] = {89462},
            [npcKeys.questEnds] = {89451},
        },
        [241862] = { -- Scarlet Stash
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{98.75,82.25},{98.51,82.57}}},
            [npcKeys.npcFlags] = npcFlags.BANKER,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Banker",
        },
        [241877] = { -- Mayor Quimby
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{90.87,85.69}}},
        },
        [242019] = { -- Leonid Barthalomew the Revered, scarlet caravan
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{33.54,27.42}}},
            [npcKeys.questStarts] = {89234,89568,89574},
            [npcKeys.questEnds] = {89567,89568,89574},
        },
        [242125] = { -- Master Craftsman Omarion
            [npcKeys.questStarts] = {89237,89304,90107},
            [npcKeys.questEnds] = {89237,89304,89449,90107},
        },
        [242174] = { -- Thisalee Crow
            [npcKeys.questStarts] = {90506,90507,90508},
            [npcKeys.questEnds] = {89462,90506,90507},
        },
        [242439] = { -- Thisalee Crow
            [npcKeys.questEnds] = {90508},
        },
        [242499] = { -- Highlord Mograine
            [npcKeys.questStarts] = {89475},
            [npcKeys.questEnds] = {89474},
        },
        [242501] = { -- The Will of the Ashbringer
            [npcKeys.questStarts] = {89488},
            [npcKeys.questEnds] = {89488},
        },
        [242827] = { -- Captain Bloodcoin
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{62.8376,26.2241}}},
            [npcKeys.npcFlags] = npcFlags.AUCTIONEER,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Seafaring Auctioneer",
        },
        [242863] = { -- Hyjal Bonfire
            [npcKeys.questStarts] = {90559},
            [npcKeys.questEnds] = {89473},
        },
        [242954] = { -- Anvil (New Avalon)
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{99.57,77.84}}},
            [npcKeys.npcFlags] = npcFlags.REPAIR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Repair",
        },
        [243021] = { -- Lillian Voss
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [243023] = { -- Inquisitor Jociphine
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{68.2,82.4}}},
            [npcKeys.questStarts] = {90510},
            [npcKeys.questEnds] = {90510},
        },
        [243269] = { -- Solistrasza
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [243386] = { -- Leonid Barthalomew the Revered, terrordale
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{16.54,31.21}}},
            [npcKeys.questStarts] = {89229,89328,89329},
            [npcKeys.questEnds] = {89310,89328,89329},
        },
        [243393] = { -- Leonid Barthalomew the Revered, service entrance gate, also inside stratholme
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.94,21.90}},
                [zoneIDs.STRATHOLME] = {{-1,-1}}
            },
            [npcKeys.questStarts] = {89235,89310},
            [npcKeys.questEnds] = {89234,89235},
        },

        -- fake NPCs
        [900000] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.DUSKWOOD,
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{23,47}},
            },
            [npcKeys.questStarts] = {80147},
        },
        [900001] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.ARATHI_HIGHLANDS,
            [npcKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{60,40}},
            },
            [npcKeys.questStarts] = {80148},
        },
        [900002] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.SWAMP_OF_SORROWS,
            [npcKeys.spawns] = {
                [zoneIDs.SWAMP_OF_SORROWS] = {{69,28}},
            },
            [npcKeys.questStarts] = {80149},
        },
        [900003] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.THE_BARRENS,
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{52,36}},
            },
            [npcKeys.questStarts] = {80150},
        },
        [900004] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.DESOLACE,
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{65,25}},
            },
            [npcKeys.questStarts] = {80151},
        },
        [900005] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.BADLANDS,
            [npcKeys.spawns] = {
                [zoneIDs.BADLANDS] = {{58,54}},
            },
            [npcKeys.questStarts] = {80152},
        },
    }
end
