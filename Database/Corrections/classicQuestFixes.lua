---@class QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:CreateModule("QuestieQuestFixes")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieCorrections.itemObjectiveFirst[503] = true
QuestieCorrections.itemObjectiveFirst[5088] = true

-- Further information on how to use this can be found at the wiki
-- https://github.com/Questie/Questie/wiki/Corrections

function QuestieQuestFixes:Load()
    local questKeys = QuestieDB.questKeys
    local zoneIDs = ZoneDB.zoneIDs
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local sortKeys = QuestieDB.sortKeys
    local specialFlags = QuestieDB.specialFlags
    local profKeys = QuestieProfessions.professionKeys
    local specKeys = QuestieProfessions.specializationKeys
    local factionIDs = QuestieDB.factionIDs
    local rankKeys = QuestieProfessions.rankNames

    return {
        [5] = { -- Jitters' Growling Gut
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {163}, -- #1198
        },
        [7] = { -- Kobold Camp Cleanup
            [questKeys.nextQuestInChain] = 15,
        },
        [11] = { -- Riverpaw Gnoll Bounty
            [questKeys.preQuestSingle] = {76}, -- #7364
            [questKeys.breadcrumbs] = {239},
        },
        [17] = { -- Uldaman Reagent Run
            [questKeys.requiredLevel] = 38, -- #2437
        },
        [21] = { -- Skirmish at Echo Ridge
            [questKeys.nextQuestInChain] = 54,
        },
        [25] = { -- Stonetalon Standstill
            [questKeys.triggerEnd] = {"Scout the gazebo on Mystral Lake that overlooks the nearby Alliance outpost.", {[zoneIDs.ASHENVALE] = {{48.92, 69.56}}}},
        },
        [26] = { -- A Lesson to Learn
            [questKeys.startedBy] = {{4217}},
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
            [questKeys.nextQuestInChain] = 29,
        },
        [27] = { -- A Lesson to Learn
            [questKeys.startedBy] = {{3033}},
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.nextQuestInChain] = 28,
        },
        [28] = { -- Trial of the Lake
            [questKeys.preQuestSingle] = {27},
            [questKeys.objectives] = {nil, {{15885, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [29] = { -- Trial of the Lake
            [questKeys.preQuestSingle] = {26},
            [questKeys.objectives] = {nil, {{15885, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [30] = { -- Trial of the Sea Lion
            [questKeys.objectives] = {nil, nil, {{15885, nil, Questie.ICON_TYPE_EVENT}}}, -- we need event icon here
        },
        [33] = { -- Wolves Across the Border
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5261}, -- #1726
        },
        [46] = { -- Bounty on Murlocs
            [questKeys.preQuestSingle] = {39},
        },
        [55] = { -- Morbent Fel
            [questKeys.objectives] = {{{1200}}},
        },
        [63] = { -- Call of Water
            [questKeys.requiredSourceItems] = {6637},
        },
        [76] = { -- The Jasperlode Mine
            [questKeys.nextQuestInChain] = 239,
        },
        [82] = { -- The Scrimshank Redemption
            [questKeys.nextQuestInChain] = 10,
        },
        [90] = { -- Seasoned Wolf Kabobs
            [questKeys.requiredSkill] = {185, 50},
        },
        [95] = { -- Sven's Revenge
            [questKeys.breadcrumbs] = {164},
        },
        [96] = { -- Call of Water
            [questKeys.exclusiveTo] = {},
        },
        [109] = { -- Report to Gryan Stoutmantle
            [questKeys.startedBy] = {{233, 237, 240, 261, 294, 963}}, -- #2158
        },
        [112] = { -- Collecting Kelp
            [questKeys.nextQuestInChain] = 114,
        },
        [117] = { -- Thunderbrew
            [questKeys.requiredLevel] = 10,
            [questKeys.name] = "Thunderbrew",
        },
        [121] = { -- Messenger to Stormwind
            [questKeys.nextQuestInChain] = 143,
        },
        [125] = { -- The Lost Tools
            [questKeys.nextQuestInChain] = 89,
        },
        [142] = { -- The Defias Brotherhood
            [questKeys.nextQuestInChain] = 155,
        },
        [144] = { -- Messenger to Westfall
            [questKeys.nextQuestInChain] = 145,
        },
        [148] = { -- Supplies from Darkshire
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {165}, -- #1173
        },
        [155] = { -- The Defias Brotherhood
            [questKeys.triggerEnd] = {"Escort The Defias Traitor to discover where VanCleef is hiding", {[zoneIDs.WESTFALL] = {{42.55, 71.53}}}},
        },
        [162] = { -- Rise of the Silithid
            [questKeys.nextQuestInChain] = 4493,
        },
        [163] = { -- Raven Hill
            [questKeys.breadcrumbForQuestId] = 5, -- #1198
            [questKeys.nextQuestInChain] = 5,
        },
        [164] = { -- Deliveries to Sven
            [questKeys.breadcrumbForQuestId] = 95, -- deliveries to sven is a breadcrumb
            [questKeys.nextQuestInChain] = 95,
        },
        [165] = { -- The Hermit
            [questKeys.breadcrumbForQuestId] = 148, -- #1173
            [questKeys.nextQuestInChain] = 148,
        },
        [189] = { -- Bloodscalp Ears
            [questKeys.nextQuestInChain] = 209,
        },
        [201] = { -- Investigate the Camp
            [questKeys.triggerEnd] = {"Locate the hunters' camp", {[zoneIDs.STRANGLETHORN_VALE] = {{35.65, 10.59}}}},
        },
        [214] = { -- Red Silk Bandanas
            [questKeys.preQuestSingle] = {155}, -- wotlkDB has prequest wrong data
        },
        [217] = { -- In Defense of the King's Lands
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {263, 267}, -- #7059
        },
        [219] = { -- Missing In Action
            [questKeys.triggerEnd] = {"Escort Corporal Keeshan back to Redridge", {[zoneIDs.REDRIDGE_MOUNTAINS] = {{33.36, 48.7}}}},
        },
        [224] = { -- In Defense of the King's Lands
            [questKeys.nextQuestInChain] = 237,
        },
        [235] = { -- The Ashenvale Hunt
            [questKeys.breadcrumbForQuestId] = 6383,
            [questKeys.nextQuestInChain] = 6383,
        },
        [237] = { -- In Defense of the King's Lands
            [questKeys.nextQuestInChain] = 263,
        },
        [239] = { -- Westbrook Garrison Needs Help!
            [questKeys.breadcrumbForQuestId] = 11,
        },
        [248] = { -- Looking Further
            [questKeys.nextQuestInChain] = 249,
        },
        [249] = { -- Morganth
            [questKeys.startedBy] = {{313}, {31}},
        },
        [251] = { -- Translate Abercrombie's Note
            [questKeys.nextQuestInChain] = 401,
        },
        [252] = { -- Translation to Ello
            [questKeys.nextQuestInChain] = 253,
        },
        [254] = { -- Digging Through the Dirt
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [258] = { -- A Hunter's Challenge
            [questKeys.nextQuestInChain] = 271,
        },
        [261] = { -- Down the Scarlet Path
            [questKeys.breadcrumbs] = {6141}, -- #1744
        },
        [263] = { -- In Defense of the King's Lands
            [questKeys.nextQuestInChain] = 217,
        },
        [272] = { -- Trial of the Sea Lion
            [questKeys.objectives] = {nil, nil, {{15885, nil, Questie.ICON_TYPE_EVENT}}}, -- we need event icon here
        },
        [273] = { -- Resupplying the Excavation
            [questKeys.triggerEnd] = {"Find Huldar, Miran, and Saean", {[zoneIDs.LOCH_MODAN] = {{51.16, 68.96}}}},
        },
        [275] = { -- Blisters on The Land
            [questKeys.objectivesText] = {"Kill 12 Fen Creepers, then return to Rethiel the Greenwarden in the Wetlands."},
        },
        [276] = { -- Tramping Paws
            [questKeys.breadcrumbs] = {463},
        },
        [282] = { -- Senir's Observations
            [questKeys.exclusiveTo] = {287},
        },
        [287] = { -- Frostmane Hold
            [questKeys.preQuestSingle] = {},
        },
        [297] = { -- Gathering Idols
            [questKeys.breadcrumbs] = {436}, -- #2492
        },
        [303] = { -- The Dark Iron War
            [questKeys.nextQuestInChain] = 378,
        },
        [308] = { -- Distracting Jarven
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {},
            [questKeys.parentQuest] = 310
        },
        [309] = { -- Protecting the Shipment
            [questKeys.triggerEnd] = {"Escort Miran to the excavation site", {[zoneIDs.LOCH_MODAN] = {{65.12, 65.77}}}},
        },
        [310] = { -- Bitter Rivals
            [questKeys.childQuests] = {308, 403},
        },
        [315] = { -- The Perfect Stout
            [questKeys.nextQuestInChain] = 413,
        },
        [336] = { -- A Noble Brew
            [questKeys.nextQuestInChain] = 397,
        },
        [349] = { -- Stranglethorn Fever
            [questKeys.objectivesText] = {},
        },
        [353] = { -- Stormpike's Delivery
            [questKeys.preQuestSingle] = {}, -- #2364
            [questKeys.breadcrumbs] = {1097},
        },
        [355] = { -- Speak with Sevren
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {354, 362},
        },
        [363] = { -- Rude Awakening
            [questKeys.breadcrumbForQuestId] = 364, -- #882
        },
        [364] = { -- The Mindless Ones
            [questKeys.preQuestSingle] = {}, -- #882
            [questKeys.breadcrumbs] = {363},
        },
        [367] = { -- A New Plague
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #888
        },
        [368] = { -- A New Plague
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #888
        },
        [369] = { -- A New Plague
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #888
        },
        [374] = { -- Proof of Demise
            [questKeys.preQuestSingle] = {427}, -- proof of demise requires at war with the scarlet crusade
        },
        [384] = { -- Beer Basted Boar Ribs
            [questKeys.zoneOrSort] = sortKeys.COOKING,
        },
        [403] = { -- Guarded Thunderbrew Barrel
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 310,
        },
        [409] = { -- Proving Allegiance
            [questKeys.requiredSourceItems] = {3080},
        },
        [410] = { -- The Dormant Shade
            [questKeys.preQuestSingle] = {366}, -- #638
            [questKeys.exclusiveTo] = {411}, -- #752
        },
        [413] = { -- Shimmer Stout
            [questKeys.breadcrumbs] = {415}, -- #567
        },
        [415] = { -- Rejold's New Brew
            [questKeys.breadcrumbForQuestId] = 413, -- #567
        },
        [427] = { -- At War With The Scarlet Crusade
            [questKeys.preQuestSingle] = {},
        },
        [428] = { -- Lost Deathstalkers
            [questKeys.nextQuestInChain] = 429,
            [questKeys.breadcrumbForQuestId] = 429,
        },
        [429] = { -- Wild Hearts
            [questKeys.preQuestSingle] = {}, -- #1843
            [questKeys.breadcrumbs] = {428},
        },
        [431] = { -- Candles Of Beckoning
            [questKeys.preQuestSingle] = {366}, -- #638
            [questKeys.exclusiveTo] = {411}, -- #752
        },
        [434] = { -- The Attack!
            [questKeys.triggerEnd] = {"Overhear Lescovar and Marzon's Conversation", {[zoneIDs.STORMWIND_CITY] = {{68.66, 14.44}}}},
        },
        [435] = { -- Escorting Erland
            [questKeys.triggerEnd] = {"Erland must reach Rane Yorick", {[zoneIDs.SILVERPINE_FOREST] = {{54.37, 13.38}}}},
        },
        [436] = { -- Ironband's Excavation
            [questKeys.breadcrumbForQuestId] = 297, -- #2492
        },
        [437] = { -- The Dead Fields
            [questKeys.triggerEnd] = {"Enter the Dead Fields", {[zoneIDs.SILVERPINE_FOREST] = {{45.91, 21.27}}}},
        },
        [443] = { -- Rot Hide Ichor
            [questKeys.preQuestSingle] = {439},
        },
        [452] = { -- Pyrewood Ambush
            [questKeys.objectives] = {nil, nil, nil, nil, {{{2060, 2061, 2062, 2063, 2064, 2065, 2066, 2067, 2068}, 2060}}},
        },
        [454] = { -- After the Ambush
            [questKeys.nextQuestInChain] = 309,
        },
        [455] = { -- The Algaz Gauntlet
            [questKeys.preQuestSingle] = {}, -- #1858
            [questKeys.breadcrumbs] = {468},
        },
        [456] = { -- The Balance of Nature
            [questKeys.nextQuestInChain] = 457,
        },
        [463] = { -- The Greenwarden
            [questKeys.nextQuestInChain] = 276,
            [questKeys.breadcrumbForQuestId] = 276,
        },
        [464] = { -- War Banners
            [questKeys.preQuestSingle] = {}, -- #809
            [questKeys.breadcrumbs] = {473}, -- #2173
        },
        [466] = { -- Search for Incendicite
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {467}, -- #2066
        },
        [467] = { -- Stonegear's Search
            [questKeys.startedBy] = {{1340, 2092}}, -- #1379
            [questKeys.breadcrumbForQuestId] = 466, -- #2066
        },
        [468] = { -- Report to Mountaineer Rockgar
            [questKeys.nextQuestInChain] = 455, -- #1858
            [questKeys.breadcrumbForQuestId] = 455,
        },
        [473] = { -- Report to Captain Stoutfist
            [questKeys.preQuestSingle] = {455}, -- #809
            [questKeys.nextQuestInChain] = 464,
            [questKeys.breadcrumbForQuestId] = 464, -- #2173
        },
        [484] = { -- Young Crocolisk Skins
            [questKeys.requiredMinRep] = {72, 0}, -- #1501
        },
        [489] = { -- Seek Redemption!
            [questKeys.startedBy] = {{2081, 2083, 2151, 2155}},
        },
        [495] = { -- The Crown of Will
            [questKeys.breadcrumbForQuestId] = 518,
        },
        [503] = { -- Gol'dir
            [questKeys.objectives] = {{{2316, nil, Questie.ICON_TYPE_EVENT}}, nil, {{3704}}},
        },
        [504] = { -- Crushridge Warmongers
            [questKeys.objectivesText] = {"Slay 15 Crushridge Warmongers, then return to Marshal Redpath in Southshore."},
        },
        [510] = { -- Foreboding Plans
            [questKeys.startedBy] = {nil, {1738, 1739, 1740}}, -- #1512
        },
        [511] = { -- Encrypted Letter
            [questKeys.startedBy] = {nil, {1738, 1739, 1740}}, -- #1512
        },
        [518] = { -- The Crown of Will
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {495},
        },
        [526] = { -- Lightforge Ingots
            [questKeys.exclusiveTo] = {322, 324}, -- not 100% sure on this one but it seems lightforge ingots is optional, block it after completing subsequent steps (#587)
        },
        [532] = { -- Battle of Hillsbrad
            [questKeys.objectivesText] = {"Kill Magistrate Burnside and 5 Hillsbrad Councilmen. Destroy the Hillsbrad Proclamation. Steal the Hillsbrad Town Registry. Report back to Darthalia in Tarren Mill afterwards."},
        },
        [533] = { -- Infiltration
            [questKeys.childQuests] = {535},
        },
        [535] = { -- Valik
            [questKeys.parentQuest] = 533,
        },
        [546] = { -- Souvenirs of Death
            [questKeys.preQuestSingle] = {527},
        },
        [549] = { -- WANTED: Syndicate Personnel
            [questKeys.nextQuestInChain] = 566, -- #1134
        },
        [558] = { -- Jaina's Autograph
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestGroup] = {1687, 1479, 1558},
            [questKeys.objectives] = {nil, nil, {{18642, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.inGroupWith] = nil,
            [questKeys.childQuests] = {},
            [questKeys.requiredSourceItems] = {18598},
        },
        [566] = { -- WANTED: Baron Vardus
            [questKeys.preQuestSingle] = {549}, -- #1484
        },
        [575] = { -- Supply and Demand
            [questKeys.nextQuestInChain] = 577,
        },
        [576] = { -- Keep An Eye Out
            [questKeys.preQuestSingle] = {597},
        },
        [577] = { -- Some Assembly Required
            [questKeys.nextQuestInChain] = 628,
        },
        [587] = { -- Up to Snuff
            [questKeys.preQuestSingle] = {597},
        },
        [590] = { -- A Rogue's Deal
            [questKeys.triggerEnd] = {"Defeat Calvin Montague", {[zoneIDs.TIRISFAL_GLADES] = {{38.19, 56.74}}}},
        },
        [598] = { -- Split Bone Necklace
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {596, 629},
        },
        [602] = { -- Magical Analysis
            [questKeys.nextQuestInChain] = 603,
        },
        [609] = { -- Voodoo Dues
            [questKeys.nextQuestInChain] = 613,
        },
        [617] = { -- Akiris by the Bundle
            [questKeys.nextQuestInChain] = 623,
        },
        [619] = { -- Enticing Negolash
            [questKeys.parentQuest] = 8554, -- #1691
            [questKeys.requiredLevel] = 35,
        },
        [621] = { -- Zanzil's Secret
            [questKeys.inGroupWith] = {}, -- #886
        },
        [637] = { -- Sully Balloo's Letter
            [questKeys.nextQuestInChain] = 683,
        },
        [638] = { -- Trollbane
            [questKeys.nextQuestInChain] = 639,
            [questKeys.breadcrumbForQuestId] = 639, -- #1205
        },
        [639] = { -- Sigil of Strom
            [questKeys.preQuestSingle] = {}, -- #1205
            [questKeys.breadcrumbs] = {638},
        },
        [640] = { -- The Broken Sigil
            [questKeys.objectivesText] = {"Retrieve the 11 Sigil Fragments from the defenders in Stromgarde, and bring them to Tor'gan in Hammerfall.",},
        },
        [648] = { -- Rescue OOX-17/TN!
            [questKeys.triggerEnd] = {"Escort OOX-17/TN to Steamwheedle Port", {[zoneIDs.TANARIS] = {{67.06, 23.16}}}},
        },
        [652] = { -- Breaking the Keystone
            [questKeys.nextQuestInChain] = 653,
        },
        [657] = { -- Hints of a New Plague?
            [questKeys.nextQuestInChain] = 660,
        },
        [660] = { -- Hints of a New Plague?
            [questKeys.triggerEnd] = {"Protect Kinelory", {[zoneIDs.ARATHI_HIGHLANDS] = {{60.1, 53.83}}}},
        },
        [664] = { -- Drowned Sorrows
            [questKeys.preQuestSingle] = {663}, -- #7258
        },
        [665] = { -- Sunken Treasure
            [questKeys.triggerEnd] = {"Defend Professor Phizzlethorpe", {[zoneIDs.ARATHI_HIGHLANDS] = {{33.87, 80.6}}}},
            [questKeys.preQuestSingle] = {663}, -- #6972
        },
        [667] = { -- Death From Below
            [questKeys.triggerEnd] = {"Defend Shakes O'Breen", {[zoneIDs.ARATHI_HIGHLANDS] = {{31.93, 81.82}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the cannon"), 0, {{"object", 113531}}}},
        },
        [670] = { -- Sunken Treasure
            [questKeys.nextQuestInChain] = 667,
        },
        [676] = { -- The Hammer May Fall
            [questKeys.breadcrumbForQuestId] = 677,
        },
        [677] = { -- Call to Arms
            [questKeys.preQuestSingle] = {}, -- #1162
            [questKeys.breadcrumbs] = {676},
        },
        [680] = { -- The Real Threat
            [questKeys.preQuestSingle] = {678}, -- #1062
        },
        [681] = { -- Northfold Manor
            [questKeys.nextQuestInChain] = 682,
        },
        [683] = { -- Sara Balloo's Plea
            [questKeys.nextQuestInChain] = 686,
        },
        [689] = { -- A King's Tribute
            [questKeys.nextQuestInChain] = 700,
        },
        [690] = { -- Malin's Request
            [questKeys.breadcrumbForQuestId] = 691,
            [questKeys.nextQuestInChain] = 691,
        },
        [691] = { -- Worth Its Weight in Gold
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {690},
            [questKeys.nextQuestInChain] = 693,
        },
        [692] = { -- The Lost Fragments
            [questKeys.nextQuestInChain] = 656,
        },
        [693] = { -- Trelane's Defenses
            [questKeys.nextQuestInChain] = 694,
        },
        [694] = { -- Wand over Fist
            [questKeys.nextQuestInChain] = 695,
        },
        [696] = { -- Attack on the Tower
            [questKeys.requiredSourceItems] = {4529},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use it"), 0, {{"object", 2715}}}},
        },
        [707] = { -- Ironband Wants You!
            [questKeys.nextQuestInChain] = 738,
            [questKeys.breadcrumbForQuestId] = 738, -- #1289
        },
        [714] = { -- Gyro... What?
            [questKeys.nextQuestInChain] = 715,
        },
        [715] = { -- Liquid Stone
            [questKeys.requiredSkill] = {},
        },
        [717] = { -- Tremors of the Earth
            [questKeys.requiredSourceItems] = {4843, 4844, 4845},
        },
        [724] = { -- Prospect of Faith
            [questKeys.nextQuestInChain] = 725,
        },
        [729] = { -- The Absent Minded Prospector
            [questKeys.breadcrumbs] = {730},
            [questKeys.nextQuestInChain] = 731,
        },
        [730] = { -- Trouble In Darkshore?
            [questKeys.breadcrumbForQuestId] = 729,
            [questKeys.zoneOrSort] = 1657,
        },
        [731] = { -- The Absent Minded Prospector
            [questKeys.triggerEnd] = {"Escort Prospector Remtravel", {[zoneIDs.DARKSHORE] = {{35.67, 84.03}}}},
        },
        [735] = { -- The Star, the Hand and the Heart
            [questKeys.requiredSourceItems] = {4639},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Dagun the Ravenous using an Enchanted Sea Kelp"), 2, {{"object", 2871}}}},
        },
        [736] = { -- The Star, the Hand and the Heart
            [questKeys.requiredSourceItems] = {4639},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Dagun the Ravenous using an Enchanted Sea Kelp"), 2, {{"object", 2871}}}},
        },
        [738] = { -- Find Agmond
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {707}, -- #1289
        },
        [742] = { -- The Ashenvale Hunt
            [questKeys.breadcrumbForQuestId] = 6383,
            [questKeys.nextQuestInChain] = 6383,
        },
        [748] = { -- Poison Water
            [questKeys.nextQuestInChain] = 754,
        },
        [752] = { -- A Humble Task
            [questKeys.breadcrumbForQuestId] = 753,
        },
        [753] = { -- A Humble Task
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {752},
        },
        [754] = { -- Winterhoof Cleansing
            [questKeys.triggerEnd] = {"Cleanse the Winterhoof Water Well", {[zoneIDs.MULGORE] = {{53.61, 66.2}}}},
            [questKeys.nextQuestInChain] = 756,
        },
        [756] = { -- Thunderhorn Totem
            [questKeys.nextQuestInChain] = 758,
        },
        [758] = { -- Thunderhorn Cleansing
            [questKeys.triggerEnd] = {"Cleanse the Thunderhorn Water Well", {[zoneIDs.MULGORE] = {{44.52, 45.46}}}},
            [questKeys.nextQuestInChain] = 759,
        },
        [759] = { -- Wildmane Totem
            [questKeys.nextQuestInChain] = 760,
        },
        [760] = { -- Wildmane Cleansing
            [questKeys.triggerEnd] = {"Cleanse the Wildmane Well", {[zoneIDs.MULGORE] = {{42.75, 14.16}}}},
        },
        [763] = { -- Rites of the Earthmother
            [questKeys.breadcrumbForQuestId] = 767,
            [questKeys.nextQuestInChain] = 767,
        },
        [767] = { -- Rite of Vision
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {763},
        },
        [769] = { -- Kodo Hide Bag
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSkill] = {165, 10},
        },
        [771] = { -- Rite of Vision
            [questKeys.nextQuestInChain] = 772,
        },
        [779] = { -- Seal of the Earth
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [788] = { -- Cutting Teeth
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4641}, -- #1956
        },
        [793] = { -- Broken Alliances
            [questKeys.requiredSourceItems] = {4843, 4844, 4845},
        },
        [806] = { -- Dark Storms
            [questKeys.nextQuestInChain] = 828,
        },
        [809] = { -- Ak'Zeloth
            [questKeys.triggerEnd] = {"Destroy the Demon Seed", {[zoneIDs.THE_BARRENS] = {{62.34, 20.07}}}}, -- #2347
        },
        [823] = { -- Report to Orgnil
            [questKeys.nextQuestInChain] = 806,
        },
        [827] = { -- Skull Rock
            [questKeys.nextQuestInChain] = 829,
        },
        [834] = { -- Winds in the Desert
            [questKeys.requiredRaces] = raceIDs.NONE, -- #1665
        },
        [835] = { -- Securing the Lines
            [questKeys.requiredRaces] = raceIDs.NONE, -- #1665
        },
        [836] = { -- Rescue OOX-09/HL!
            [questKeys.triggerEnd] = {"Escort OOX-09/HL to the shoreline beyond Overlook Cliff", {[zoneIDs.THE_HINTERLANDS] = {{79.14, 61.36}}}},
        },
        [841] = { -- Another Power Source?
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.exclusiveTo] = {654},
        },
        [844] = { -- Plainstrider Menace
            [questKeys.breadcrumbs] = {860},
        },
        [848] = { -- Fungal Spores
            [questKeys.nextQuestInChain] = 853,
        },
        [850] = { -- Kolkar Leaders
            [questKeys.nextQuestInChain] = 851,
        },
        [852] = { -- Hezrul Bloodmark
            [questKeys.nextQuestInChain] = 4021,
        },
        [854] = { -- Journey to the Crossroads
            [questKeys.exclusiveTo] = {844},
        },
        [858] = { -- Ignition
            [questKeys.nextQuestInChain] = 863,
        },
        [860] = { -- Sergra Darkthorn
            [questKeys.breadcrumbForQuestId] = 844,
        },
        [861] = { -- The Hunter's Way
            [questKeys.nextQuestInChain] = 860,
            [questKeys.exclusiveTo] = {844}, -- #1109
        },
        [862] = { -- Dig Rat Stew
            [questKeys.requiredSkill] = {profKeys.COOKING, 15},
        },
        [863] = { -- The Escape
            [questKeys.triggerEnd] = {"Escort Wizzlecrank out of the Venture Co. drill site", {[zoneIDs.THE_BARRENS] = {{55.36, 7.68}}}},
        },
        [865] = { -- Raptor Horns
            [questKeys.nextQuestInChain] = 1491,
        },
        [870] = { -- The Forgotten Pools
            [questKeys.breadcrumbs] = {886},
        },
        [878] = { -- Tribes at War
            [questKeys.nextQuestInChain] = 5052,
        },
        [886] = { -- The Barrens Oases
            [questKeys.breadcrumbForQuestId] = 870,
        },
        [893] = { -- Weapons of Choice
            [questKeys.nextQuestInChain] = 1153,
        },
        [898] = { -- Free From the Hold
            [questKeys.triggerEnd] = {"Escort Gilthares Firebough back to Ratchet", {[zoneIDs.THE_BARRENS] = {{62.27, 39.09}}}},
        },
        [910] = { -- Down at the Docks
            [questKeys.triggerEnd] = {"Go to the docks of Ratchet in the Barrens.", {[zoneIDs.THE_BARRENS] = {{62.96, 38.04}}}},
            [questKeys.requiredSourceItems] = {18597},
        },
        [911] = { -- Gateway to the Frontier
            [questKeys.triggerEnd] = {"Go to the Mor'shan Rampart in the Barrens.", {[zoneIDs.THE_BARRENS] = {{47.9, 5.36}}}},
            [questKeys.requiredSourceItems] = {18597},
        },
        [915] = { -- You Scream, I Scream...
            [questKeys.objectivesText] = {"Get some Strawberry Ice Cream for your ward. The lad seems to prefer Tigule's brand ice cream."}, -- orc orphan
            [questKeys.preQuestGroup] = {1800, 910, 911},
            [questKeys.inGroupWith] = nil,
            [questKeys.childQuests] = {},
            [questKeys.parentQuest] = 0,
            [questKeys.requiredSourceItems] = {18597},
        },
        [918] = { -- Timberling Seeds
            [questKeys.preQuestSingle] = {},
            [questKeys.disabledByQuest] = 997,
        },
        [919] = { -- Timberling Sprouts
            [questKeys.disabledByQuest] = 997,
        },
        [923] = { -- Tumors
            [questKeys.nextQuestInChain] = 2498,
        },
        [924] = { -- The Demon Seed
            [questKeys.requiredSourceItems] = {4986},
        },
        [925] = { -- Cairne's Hoofprint
            [questKeys.preQuestGroup] = {1800, 910, 911},
            [questKeys.objectives] = {nil, nil, {{18643, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.inGroupWith] = nil,
            [questKeys.parentQuest] = 0,
            [questKeys.requiredSourceItems] = {18597},
        },
        [926] = { -- Flawed Power Stone
            [questKeys.parentQuest] = 924, -- #806
        },
        [927] = { -- The Moss-twined Heart
            [questKeys.nextQuestInChain] = 941,
        },
        [930] = { -- The Glowing Fruit
            [questKeys.preQuestSingle] = {918}, -- #971
        },
        [931] = { -- The Shimmering Frond
            [questKeys.preQuestSingle] = {918},
            [questKeys.nextQuestInChain] = 2399,
        },
        [936] = { -- Assisting Arch Druid Runetotem
            [questKeys.breadcrumbForQuestId] = 3761,
        },
        [937] = { -- The Enchanted Glade
            [questKeys.nextQuestInChain] = 940,
        },
        [938] = { -- Mist
            [questKeys.triggerEnd] = {"Lead Mist safely to Sentinel Arynia Cloudsbreak", {[zoneIDs.TELDRASSIL] = {{38.33, 34.39}}}},
        },
        [944] = { -- The Master's Glaive
            [questKeys.triggerEnd] = {"Enter the Master's Glaive", {[zoneIDs.DARKSHORE] = {{38.48, 86.45}}}},
        },
        [945] = { -- Therylune's Escape
            [questKeys.triggerEnd] = {"Escort Therylune away from the Master's Glaive", {[zoneIDs.DARKSHORE] = {{40.51, 87.08}}}},
        },
        [950] = { -- Mathystra Relics
            [questKeys.nextQuestInChain] = 951,
        },
        [960] = { -- Onu is meditating
            [questKeys.name] = "Onu is meditating",
            [questKeys.startedBy] = {{3616}},
            [questKeys.finishedBy] = {{3616}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 1,
            [questKeys.preQuestSingle] = {944},
            [questKeys.availableUntilCompleted] = 949,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.zoneOrSort] = zoneIDs.DARKSHORE,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.questFlags] = 8,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [961] = { -- Onu is meditating
            [questKeys.finishedBy] = {{3616}},
            [questKeys.preQuestSingle] = {949},
            [questKeys.availableUntilCompleted] = 950,
            [questKeys.exclusiveTo] = {},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [970] = { -- The Tower of Althalaxx
            [questKeys.nextQuestInChain] = 973,
        },
        [972] = { -- Water Sapta
            [questKeys.exclusiveTo] = {},
            [questKeys.parentQuest] = 0,
            [questKeys.preQuestSingle] = {220},
            [questKeys.availableUntilCompleted] = 96,
        },
        [974] = { -- Finding the Source
            [questKeys.objectives] = {nil, {{148503, nil, Questie.ICON_TYPE_EVENT}}}
        },
        [976] = { -- Supplies to Auberdine
            [questKeys.triggerEnd] = {"Protect Feero Ironhand", {[zoneIDs.DARKSHORE] = {{43.54, 94.39}}}},
        },
        [979] = { -- Find Ranshalla
            [questKeys.nextQuestInChain] = 4901,
        },
        [984] = { -- How Big a Threat?
            [questKeys.triggerEnd] = {"Find a corrupt furbolg camp", {[zoneIDs.DARKSHORE] = {{50.91, 34.74}, {39.86, 53.89}, {42.68, 86.53}, {39.95, 78.41}}}},
        },
        [985] = { -- How Big a Threat?
            [questKeys.nextQuestInChain] = 986,
        },
        [986] = { -- A Lost Master
            [questKeys.nextQuestInChain] = 993,
        },
        [994] = { -- Escape Through Force
            [questKeys.triggerEnd] = {"Help Volcor to the road", {[zoneIDs.DARKSHORE] = {{41.92, 81.76}}}},
            [questKeys.nextQuestInChain] = 990,
        },
        [995] = { -- Escape Through Stealth
            [questKeys.triggerEnd] = {"Help Volcor escape the cave", {[zoneIDs.DARKSHORE] = {{44.57, 85}}}},
            [questKeys.nextQuestInChain] = 990,
        },
        [1000] = { -- The New Frontier
            [questKeys.exclusiveTo] = {1004, 1018},
        },
        [1004] = { -- The New Frontier
            [questKeys.exclusiveTo] = {1000, 1018},
        },
        [1007] = { -- The Ancient Statuette
            [questKeys.nextQuestInChain] = 1009,
        },
        [1008] = { -- The Zoram Strand
            [questKeys.nextQuestInChain] = 1134,
            [questKeys.disabledByQuest] = 1133,
        },
        [1010] = { -- Bathran's Hair
            [questKeys.nextQuestInChain] = 1020,
        },
        [1011] = { -- Forsaken Diseases
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 1012,
        },
        [1015] = { -- The New Frontier
            [questKeys.exclusiveTo] = {1047, 1019},
        },
        [1018] = { -- The New Frontier
            [questKeys.exclusiveTo] = {1000, 1004},
        },
        [1019] = { -- The New Frontier
            [questKeys.exclusiveTo] = {1015, 1047},
        },
        [1020] = { -- Orendil's Cure
            [questKeys.nextQuestInChain] = 1033,
        },
        [1023] = { -- Raene's Cleansing
            [questKeys.nextQuestInChain] = 1024,
        },
        [1026] = { -- Raene's Cleansing
            [questKeys.requiredSourceItems] = {5475},
        },
        [1027] = { -- Raene's Cleansing
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay slimes until they leave behind a Rusty Chest"), 0, {{"monster", 3928}}}},
        },
        [1031] = { -- The Branch of Cenarius
            [questKeys.nextQuestInChain] = 1032,
        },
        [1033] = { -- Elune's Tear
            [questKeys.nextQuestInChain] = 1034,
        },
        [1034] = { -- The Ruins of Stardust
            [questKeys.nextQuestInChain] = 1035,
        },
        [1036] = { -- Avast Ye, Scallywag
            [questKeys.requiredMinRep] = {87, 3000},
            [questKeys.requiredMaxRep] = {21, -6000},
            [questKeys.breadcrumbForQuestId] = 4621,
        },
        [1045] = { -- Raene's Cleansing
            [questKeys.requiredSourceItems] = {},
        },
        [1046] = { -- Raene's Cleansing
            [questKeys.objectives] = {nil, nil, {{5388}, {5462}}},
            [questKeys.sourceItemId] = 0,
        },
        [1047] = { -- The New Frontier
            [questKeys.exclusiveTo] = {1015, 1019},
        },
        [1052] = { -- Down the Scarlet Path
            [questKeys.nextQuestInChain] = 1053,
        },
        [1056] = { -- Journey to Stonetalon Peak
            [questKeys.breadcrumbForQuestId] = 1057, -- #1901
        },
        [1057] = { -- Reclaiming the Charred Vale
            [questKeys.breadcrumbs] = {1056}, -- #1901
        },
        [1061] = { -- The Spirits of Stonetalon
            [questKeys.breadcrumbForQuestId] = 1062, -- #1803
            [questKeys.nextQuestInChain] = 1062,
        },
        [1062] = { -- Goblin Invaders
            [questKeys.breadcrumbs] = {1061}, -- #1803
        },
        [1070] = { -- On Guard in Stonetalon
            [questKeys.breadcrumbForQuestId] = 1085,
        },
        [1076] = { -- Devils in Westfall
            [questKeys.nextQuestInChain] = 1077,
        },
        [1079] = { -- Covert Ops - Alpha
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1077, 1074},
            [questKeys.requiredSourceItems] = {5692, 5693, 5694, 5695, 5737},
        },
        [1080] = { -- Covert Ops - Beta
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1077, 1074},
            [questKeys.requiredSourceItems] = {5692, 5693, 5694, 5695, 5737},
        },
        [1085] = { -- On Guard in Stonetalon
            [questKeys.breadcrumbs] = {1070},
        },
        [1086] = { -- The Flying Machine Airport
            [questKeys.triggerEnd] = {"Place the Toxic Fogger", {[zoneIDs.STONETALON_MOUNTAINS] = {{66.44, 45.46}}}},
        },
        [1090] = { -- Gerenzo's Orders
            [questKeys.objectives] = {{{4276, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [1093] = { -- Super Reaper 6000
            [questKeys.breadcrumbs] = {1483},
        },
        [1097] = { -- Elmore's Task
            [questKeys.startedBy] = {{415, 514}},
            [questKeys.breadcrumbForQuestId] = 353, -- #2364
        },
        [1103] = { -- Call of Water
            [questKeys.preQuestSingle] = {63},
            [questKeys.parentQuest] = 0,
            [questKeys.childQuests] = {},
            [questKeys.availableUntilCompleted] = 96,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [1105] = { -- Hardened Shells
            [questKeys.disabledByQuest] = 1179,
        },
        [1106] = { -- Martek the Exiled
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1104, 1105},
        },
        [1107] = { -- Encrusted Tail Fins
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1104, 1105}, -- #2444
        },
        [1108] = { -- Indurium
            [questKeys.nextQuestInChain] = 1137,
        },
        [1112] = { -- Parts for Kravel
            [questKeys.nextQuestInChain] = 1114,
        },
        [1114] = { -- Delivery to the Gnomes
            [questKeys.nextQuestInChain] = 1115,
        },
        [1117] = { -- Rumors for Kravel
            [questKeys.nextQuestInChain] = 1118,
        },
        [1118] = { -- Back to Booty Bay
            [questKeys.inGroupWith] = {}, -- #886
        },
        [1119] = { -- Zanzil's Mixture and a Fool's Stout
            [questKeys.inGroupWith] = {}, -- #886
            [questKeys.childQuests] = {1127}, -- #1084
        },
        [1120] = { -- Get the Gnomes Drunk
            [questKeys.nextQuestInChain] = 1122,
        },
        [1121] = { -- Get the Goblins Drunk
            [questKeys.nextQuestInChain] = 1122,
        },
        [1123] = { -- Rabine Saturna
            [questKeys.preQuestSingle] = {1000, 1004, 1018},
        },
        [1126] = { -- Hive in the Tower
            [questKeys.requiredSourceItems] = {17345},
        },
        [1127] = { -- Fool's Stout
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #884
            [questKeys.parentQuest] = 1119, -- #1084
        },
        [1130] = { -- Melor Sends Word
            [questKeys.breadcrumbForQuestId] = 1131,
        },
        [1131] = { -- Steelsnap
            [questKeys.preQuestSingle] = {}, -- #1065
            [questKeys.breadcrumbs] = {1130},
        },
        [1132] = { -- Fiora Longears
            [questKeys.breadcrumbForQuestId] = 1133, -- #1738
        },
        [1133] = { -- Journey to Astranaar
            [questKeys.breadcrumbs] = {1132},
            [questKeys.preQuestSingle] = {}, -- #1738
            [questKeys.zoneOrSort] = zoneIDs.DUSTWALLOW_MARSH,
        },
        [1135] = { -- Highperch Venom
            [questKeys.disabledByQuest] = 1132,
        },
        [1136] = { -- Frostmaw
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use a Fresh Carcass at the Flame of Uzel"), 0, {{"object", 1770}}}},
        },
        [1137] = { -- News for Fizzle
            [questKeys.nextQuestInChain] = 1190,
        },
        [1141] = { -- The Family and the Fishing Pole
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE] = {{35.71, 44.68}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Darkshore Groupers"),}},
        },
        [1144] = { -- Willix the Importer
            [questKeys.triggerEnd] = {"Help Willix the Importer escape from Razorfen Kraul", {[zoneIDs.RAZORFEN_KRAUL] = {{-1, -1}}}},
        },
        [1148] = { -- Parts of the Swarm
            [questKeys.preQuestSingle] = {1146},
        },
        [1173] = { -- Challenge Overlord Mok'Morokk
            [questKeys.triggerEnd] = {"Drive Overlord Mok'Morokk from Brackenwall Village", {[zoneIDs.DUSTWALLOW_MARSH] = {{36.41, 31.43}}}},
        },
        [1177] = { -- Hungry!
            [questKeys.objectivesText] = {"Mudcrush Durtfeet in northern Dustwallow wants 12 Mirefin Heads."},
        },
        [1190] = { -- Keeping Pace
            [questKeys.childQuests] = {1191},
        },
        [1191] = { -- Zamek's Distraction
            [questKeys.parentQuest] = 1190,
        },
        [1193] = { -- A Broken Trap
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1348
        },
        [1194] = { -- Rizzle's Schematics
            [questKeys.startedBy] = {nil, {20805, 179888}},
            [questKeys.nextQuestInChain] = 1192,
        },
        [1198] = { -- In Search of Thaelrid
            [questKeys.requiredRaces] = raceIDs.NONE, -- horde CAN get this quest
        },
        [1200] = { -- Blackfathom Villainy
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1198},
        },
        [1204] = { -- Mudrock Soup and Bugs
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1260}, -- #938
        },
        [1206] = { -- Jarl Needs Eyes
            [questKeys.objectivesText] = {"Bring 40 Unpopped Darkmist Eyes to \"Swamp Eye\" Jarl at the Swamplight Manor.",},
        },
        [1221] = { -- Blueleaf Tubers
            [questKeys.sourceItemId] = 6684,
        },
        [1222] = { -- Stinky's Escape
            [questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[zoneIDs.DUSTWALLOW_MARSH] = {{48.87, 24.58}}}},
        },
        [1249] = { -- The Missing Diplomat
            [questKeys.objectives] = {{{4962}}},
            [questKeys.nextQuestInChain] = 1250,
        },
        [1252] = { -- Lieutenant Paval Reethe
            [questKeys.preQuestSingle] = {1302, 1282}, -- #1845
        },
        [1253] = { -- The Black Shield
            [questKeys.preQuestSingle] = {1302, 1282}, -- #1845
        },
        [1260] = { -- Morgan Stern
            [questKeys.breadcrumbForQuestId] = 1204, -- #938
        },
        [1264] = { -- The Missing Diplomat
            [questKeys.preQuestSingle] = {1250}, -- wotlkDB is wrong
        },
        [1265] = { -- The Missing Diplomat
            [questKeys.triggerEnd] = {"Sentry Point explored", {[zoneIDs.DUSTWALLOW_MARSH] = {{59.92, 40.9}}}},
        },
        [1267] = { -- The Missing Diplomat
            [questKeys.startedBy] = {{4968}},
        },
        [1268] = { -- Suspicious Hoofprints
            [questKeys.startedBy] = {nil, {21015, 21016}}, -- #1574
        },
        [1270] = { -- Stinky's Escape
            [questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[zoneIDs.DUSTWALLOW_MARSH] = {{48.87, 24.58}}}},
        },
        [1271] = { -- Feast at the Blue Recluse
            [questKeys.preQuestSingle] = {1222},
            [questKeys.preQuestGroup] = {},
        },
        [1273] = { -- Questioning Reethe
            [questKeys.triggerEnd] = {"Question Reethe with Ogron", {[zoneIDs.DUSTWALLOW_MARSH] = {{42.47, 38.07}}}},
        },
        [1275] = { -- Researching the Corruption
            [questKeys.preQuestSingle] = {}, -- #973
            [questKeys.breadcrumbs] = {3765}, -- #745
        },
        [1276] = { -- The Black Shield
            [questKeys.preQuestSingle] = {1273}, -- #1574
        },
        [1282] = { -- They Call Him Smiling Jim
            [questKeys.availableUntilCompleted] = 1302,
            [questKeys.exclusiveTo] = {},
        },
        [1284] = { -- Suspicious Hoofprints
            [questKeys.preQuestSingle] = {1282, 1302}, -- #1845
            [questKeys.startedBy] = {nil, {21015, 21016}},
        },
        [1301] = { -- James Hyal
            [questKeys.breadcrumbForQuestId] = 1302, -- #889
            [questKeys.availableUntilCompleted] = 1282,
        },
        [1302] = { -- James Hyal
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {}, -- #889
            [questKeys.breadcrumbs] = {1301}, -- #889
        },
        [1322] = { -- The Black Shield
            [questKeys.objectivesText] = {"Acquire 6 Acidic Venom Sacs for Do'gol in Brackenwall Village."},
        },
        [1324] = { -- The Missing Diplomat
            [questKeys.objectives] = {{{4966}}},
            [questKeys.nextQuestInChain] = 1267, -- wotlkDB is wrong, classicDB is right
        },
        [1338] = { -- Stormpike's Order
            [questKeys.breadcrumbs] = {1339},
        },
        [1339] = { -- Mountaineer Stormpike's Task
            [questKeys.breadcrumbForQuestId] = 1338, -- mountaineer stormpike's task cant be done if you have finished stormpike's order
        },
        [1361] = { -- Regthar Deathgate
            [questKeys.breadcrumbForQuestId] = 1362,
            [questKeys.startedBy] = {{2229, 3230, 4485}},
        },
        [1362] = { -- The Kolkar of Desolace
            [questKeys.breadcrumbs] = {1361},
            [questKeys.breadcrumbForQuestId] = 1365,
        },
        [1364] = { -- Mazen's Behest
            [questKeys.preQuestSingle] = {1363}, -- #1674
        },
        [1365] = { -- Khan Dez'hepah
            [questKeys.breadcrumbs] = {1362},
        },
        [1367] = { -- Magram Alliance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Gelkis centaur to increase your reputation with the Magram Clan"), 0, {{"monster", 4653}, {"monster", 4647}, {"monster", 4646}, {"monster", 4661}, {"monster", 5602}, {"monster", 4648}, {"monster", 4649}, {"monster", 4651}, {"monster", 4652}}}},
            [questKeys.reputationReward] = {{factionIDs.GELKIS_CLAN_CENTAUR, -500}, {factionIDs.MAGRAM_CLAN_CENTAUR, 100}},
        },
        [1368] = { -- Gelkis Alliance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Magram centaur to increase your reputation with the Gelkis Clan"), 0, {{"monster", 4643}, {"monster", 4645}, {"monster", 4662}, {"monster", 5601}, {"monster", 4638}, {"monster", 4641}, {"monster", 6068}, {"monster", 4640}, {"monster", 4639}, {"monster", 4642}, {"monster", 4644}}}},
            [questKeys.reputationReward] = {{factionIDs.MAGRAM_CLAN_CENTAUR, -500}, {factionIDs.GELKIS_CLAN_CENTAUR, 100}},
        },
        [1369] = { -- Broken Tears
            [questKeys.requiredMinRep] = {factionIDs.MAGRAM_CLAN_CENTAUR, 3000},
        },
        [1370] = { -- Stealing Supplies
            [questKeys.requiredMinRep] = {factionIDs.GELKIS_CLAN_CENTAUR, 3000},
        },
        [1371] = { -- Gizmo for Warug
            [questKeys.nextQuestInChain] = 1375,
            [questKeys.requiredMinRep] = {factionIDs.MAGRAM_CLAN_CENTAUR, 3000},
        },
        [1373] = { -- Ongeku
            [questKeys.requiredMinRep] = {factionIDs.GELKIS_CLAN_CENTAUR, 3000},
        },
        [1374] = { -- Khan Jehn
            [questKeys.requiredMinRep] = {factionIDs.GELKIS_CLAN_CENTAUR, 3000},
        },
        [1375] = { -- Khan Shaka
            [questKeys.requiredMinRep] = {factionIDs.MAGRAM_CLAN_CENTAUR, 3000},
        },
        [1380] = { -- Khan Hratha
            [questKeys.requiredMinRep] = {factionIDs.GELKIS_CLAN_CENTAUR, 3000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the War Horn Mouthpiece to summon Khan Hratha"), 0, {{"object", 138497}}}},
        },
        [1381] = { -- Khan Hratha
            [questKeys.requiredMinRep] = {factionIDs.MAGRAM_CLAN_CENTAUR, 3000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the War Horn Mouthpiece to summon Khan Hratha"), 0, {{"object", 138497}}}},
        },
        [1382] = { -- Strange Alliance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Magram centaur to increase your reputation with the Gelkis Clan"), 0, {{"monster", 4643}, {"monster", 4645}, {"monster", 4662}, {"monster", 5601}, {"monster", 4638}, {"monster", 4641}, {"monster", 6068}, {"monster", 4640}, {"monster", 4639}, {"monster", 4642}, {"monster", 4644}}}},
            [questKeys.reputationReward] = {{factionIDs.MAGRAM_CLAN_CENTAUR, -500}, {factionIDs.GELKIS_CLAN_CENTAUR, 100}},
        },
        [1384] = { -- Raid on the Kolkar
            [questKeys.requiredMinRep] = {factionIDs.GELKIS_CLAN_CENTAUR, 3000},
        },
        [1385] = { -- Brutal Politics
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Gelkis centaur to increase your reputation with the Magram Clan"), 0, {{"monster", 4653}, {"monster", 4647}, {"monster", 4646}, {"monster", 4661}, {"monster", 5602}, {"monster", 4648}, {"monster", 4649}, {"monster", 4651}, {"monster", 4652}}}},
            [questKeys.reputationReward] = {{factionIDs.GELKIS_CLAN_CENTAUR, -500}, {factionIDs.MAGRAM_CLAN_CENTAUR, 100}},
        },
        [1386] = { -- Assault on the Kolkar
            [questKeys.requiredMinRep] = {factionIDs.MAGRAM_CLAN_CENTAUR, 3000},
        },
        [1388] = { -- Nothing But The Truth
            [questKeys.preQuestSingle] = {1383},
        },
        [1393] = { -- Galen's Escape
            [questKeys.triggerEnd] = {"Escort Galen out of the Fallow Sanctuary.", {[zoneIDs.SWAMP_OF_SORROWS] = {{53.08, 29.55}}}},
        },
        [1395] = { -- Supplies for Nethergarde
            [questKeys.preQuestSingle] = {}, -- #1727
            [questKeys.breadcrumbs] = {1477},
        },
        [1418] = { -- Neeka Bloodscar
            [questKeys.breadcrumbForQuestId] = 1420, -- #1594
        },
        [1420] = { -- Report to Helgrum
            [questKeys.breadcrumbs] = {1418}, -- #1594
        },
        [1427] = { -- Threat From the Sea
            [questKeys.nextQuestInChain] = 1428,
        },
        [1428] = { -- Continued Threat
            [questKeys.preQuestSingle] = {1427},
        },
        [1432] = { -- Alliance Relations
            [questKeys.nextQuestInChain] = 1433,
        },
        [1434] = { -- Befouled by Satyr
            [questKeys.preQuestSingle] = {1432}, -- #1536
        },
        [1436] = { -- Alliance Relations
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1434, 1435},
        },
        [1439] = { -- Search for Tyranis
            [questKeys.nextQuestInChain] = 1440,
        },
        [1440] = { -- Return to Vahlarriel
            [questKeys.triggerEnd] = {"Rescue Dalinda Malem", {[zoneIDs.DESOLACE] = {{58.27, 30.91}}}},
        },
        [1442] = { -- Seeking the Kor Gem
            [questKeys.preQuestSingle] = {},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 1654,
        },
        [1447] = { -- The Missing Diplomat
            [questKeys.objectives] = {{{4961}}},
        },
        [1448] = { -- In Search of The Temple
            [questKeys.triggerEnd] = {"Search for the Temple of Atal'Hakkar", {[zoneIDs.SWAMP_OF_SORROWS] = {{70.2, 45.2}, {66.6, 48.1}, {73.6, 48.1}, {64.9, 53.3}, {75.4, 53.3}, {66.6, 58.4}, {73.6, 58.4}, {70.2, 60.5}}}},
        },
        [1452] = { -- Rhapsody's Kalimdor Kocktail
            [questKeys.nextQuestInChain] = 1469,
        },
        [1462] = { -- Earth Sapta
            [questKeys.preQuestSingle] = {1520},
            [questKeys.objectivesText] = {},
            [questKeys.parentQuest] = 0,
            [questKeys.availableUntilCompleted] = 1521,
        },
        [1463] = { -- Earth Sapta
            [questKeys.preQuestSingle] = {1517},
            [questKeys.objectivesText] = {},
            [questKeys.parentQuest] = 0,
            [questKeys.availableUntilCompleted] = 1518,
        },
        [1464] = { -- Fire Sapta
            [questKeys.preQuestSingle] = {1525},
            [questKeys.objectivesText] = {},
            [questKeys.parentQuest] = 0,
            [questKeys.availableUntilCompleted] = 1526,
        },
        [1470] = { -- Piercing the Veil
            [questKeys.exclusiveTo] = {1485}, -- #999
        },
        [1471] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Voidwalker"), 0, {{"object", 37097}}}},
        },
        [1472] = { -- Devourer of Souls
            [questKeys.questLevel] = -1,
        },
        [1473] = { -- Creature of the Void
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1478},
        },
        [1474] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Succubus"), 0, {{"object", 37097}}}},
            [questKeys.exclusiveTo] = {1507},
        },
        [1476] = { -- Hearts of the Pure
            [questKeys.exclusiveTo] = {1507},
            [questKeys.questLevel] = -1,
        },
        [1477] = { -- Vital Supplies
            [questKeys.breadcrumbForQuestId] = 1395, -- #1727
        },
        [1478] = { -- Halgar's Summons
            [questKeys.breadcrumbForQuestId] = 1473,
        },
        [1479] = { -- The Bough of the Eternals
            [questKeys.triggerEnd] = {"Go to the bank in Darnassus, otherwise known as the Bough of the Eternals.", {[zoneIDs.DARNASSUS] = {{41.31, 43.54}}}},
            [questKeys.requiredSourceItems] = {18598},
        },
        [1480] = { -- The Corrupter
            [questKeys.startedBy] = {nil, nil, {20310}},
        },
        [1483] = { -- Ziz Fizziks
            [questKeys.breadcrumbForQuestId] = 1093,
        },
        [1485] = { -- Vile Familiars
            [questKeys.exclusiveTo] = {1470}, -- #999
        },
        [1498] = { -- Path of Defense
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1505},
            [questKeys.exclusiveTo] = {1819},
        },
        [1499] = { -- Vile Familiars
            [questKeys.preQuestSingle] = {1470, 1485},
        },
        [1501] = { -- Creature of the Void
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1506},
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [1502] = { -- Thun'grim Firegaze
            [questKeys.preQuestSingle] = {1498, 1819},
        },
        [1504] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Voidwalker"), 0, {{"object", 105576}}}},
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [1505] = { -- Veteran Uzzek
            [questKeys.startedBy] = {{3041, 3063, 3169, 3354}},
            [questKeys.breadcrumbForQuestId] = 1498,
            [questKeys.exclusiveTo] = {1819},
        },
        [1506] = { -- Gan'rul's Summons
            [questKeys.breadcrumbForQuestId] = 1501,
        },
        [1507] = { -- Devourer of Souls
            [questKeys.questLevel] = -1,
        },
        [1508] = { -- Blind Cazul
            [questKeys.exclusiveTo] = {1472},
            [questKeys.questLevel] = -1,
        },
        [1509] = { -- News of Dogran
            [questKeys.exclusiveTo] = {1472},
        },
        [1510] = { -- News of Dogran
            [questKeys.exclusiveTo] = {1472},
        },
        [1511] = { -- Ken'zigla's Draught
            [questKeys.exclusiveTo] = {1472},
        },
        [1512] = { -- Love's Gift
            [questKeys.exclusiveTo] = {1472},
        },
        [1513] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Succubus"), 0, {{"object", 105576}}}},
            [questKeys.exclusiveTo] = {1472},
        },
        [1515] = { -- Dogran's Captivity
            [questKeys.exclusiveTo] = {1472},
        },
        [1516] = { -- Call of Earth
            [questKeys.exclusiveTo] = {1519}, -- #6723
        },
        [1517] = { -- Call of Earth
            [questKeys.preQuestSingle] = {1516, 1519}, -- #6723
            [questKeys.childQuests] = {}, -- #6723
        },
        [1518] = { -- Call of Earth
            [questKeys.requiredSourceItems] = {6635},
        },
        [1519] = { -- Call of Earth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #6723
            [questKeys.exclusiveTo] = {1516}, -- #6723
        },
        [1520] = { -- Call of Earth
            [questKeys.preQuestSingle] = {1516, 1519}, -- #6723
            [questKeys.childQuests] = {}, -- #6723
        },
        [1521] = { -- Call of Earth
            [questKeys.childQuests] = {1462}, -- #6723
            [questKeys.requiredSourceItems] = {6635},
        },
        [1522] = { -- Call of Fire
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [1523] = { -- Call of Fire
            [questKeys.startedBy] = {{5906}},
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [1524] = { -- Call of Fire
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1522, 1523, 2983, 2984},
        },
        [1526] = { -- Call of Fire
            [questKeys.requiredSourceItems] = {6636},
            [questKeys.childQuests] = {},
        },
        [1528] = { -- Call of Water
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [1529] = { -- Call of Water
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [1530] = { -- Call of Water
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1528, 1529, 2985, 2986},
        },
        [1558] = { -- The Stonewrought Dam
            [questKeys.triggerEnd] = {"Go to the top of the Stonewrought Dam in Loch Modan.", {[zoneIDs.LOCH_MODAN] = {{47.63, 14.33}}}},
            [questKeys.requiredSourceItems] = {18598},
        },
        [1559] = { -- Flash Bomb Recipe
            [questKeys.preQuestSingle] = {705},
        },
        [1560] = { -- Tooga's Quest
            [questKeys.objectives] = {{{6015, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [1579] = { -- Gaffer Jacks
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE] = {{35.71, 44.68}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Gaffer Jacks"),}},
        },
        [1580] = { -- Electropellers
            [questKeys.requiredSkill] = {356, 30},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE] = {{50.7, 23.8}, {40, 73.6}, {44.3, 74.4}, {53.3, 32.4}, {43.3, 80.6}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Electropellers"),}},
        },
        [1581] = { -- Elixirs for the Bladeleafs
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1598] = { -- The Stolen Tome
            [questKeys.exclusiveTo] = {1599}, -- #999
        },
        [1599] = { -- Beginnings
            [questKeys.exclusiveTo] = {1598}, -- #999
        },
        [1618] = { -- Gearing Redridge
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING, 60},
        },
        [1638] = { -- A Warrior's Training
            [questKeys.exclusiveTo] = {
                1678, 1683, -- not available once you turn in these main quests
                1639, -- "follow up" quest from same NPC. NOT breadcrumb
            },
            [questKeys.nextQuestInChain] = 0,
        },
        [1639] = { -- Bartleby the Drunk
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1678, 1683},
        },
        [1640] = { -- Beat Bartleby
            [questKeys.objectives] = {{{6090}}},
            [questKeys.preQuestSingle] = {1639, 1678, 1683},
        },
        [1641] = { -- The Tome of Divinity (Stormwind)
            [questKeys.nextQuestInChain] = 1642,
        },
        [1642] = { -- The Tome of Divinity (Stormwind)
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2998, 3681},
        },
        [1645] = { -- The Tome of Divinity (Ironforge)
            [questKeys.nextQuestInChain] = 1646,
        },
        [1646] = { -- The Tome of Divinity (Ironforge)
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2997, 2999, 3000},
        },
        [1650] = { -- The Tome of Valor
            [questKeys.nextQuestInChain] = 1651,
        },
        [1651] = { -- The Tome of Valor
            [questKeys.triggerEnd] = {"Protect Daphne Stilwell", {[zoneIDs.WESTFALL] = {{42.15, 88.44}}}},
        },
        [1654] = { -- The Test of Righteousness
            [questKeys.childQuests] = {1442, 1655},
        },
        [1655] = { -- Bailor's Ore Shipment
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 1654,
        },
        [1658] = { -- Crashing the Wickerman Festival
            [questKeys.name] = "Crashing the Wickerman Festival",
        },
        [1661] = { -- The Tome of Nobility
            [questKeys.exclusiveTo] = {4485, 4486},
        },
        [1665] = { -- Bartleby's Mug
            [questKeys.nextQuestInChain] = 1666,
        },
        [1678] = { -- Vejrek
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1679},
            [questKeys.exclusiveTo] = {1639, 1683},
        },
        [1679] = { -- Muren Stormpike
            [questKeys.exclusiveTo] = {
                1639, 1683, -- not available once you turn in these main quests
            },
            [questKeys.breadcrumbForQuestId] = 1678,
        },
        [1680] = { -- Tormus Deepforge
            [questKeys.preQuestSingle] = {1683, 1678, 1639},
            [questKeys.breadcrumbForQuestId] = 1681,
        },
        [1681] = { -- Ironband's Compound
            [questKeys.preQuestSingle] = {1683, 1678, 1639},
            [questKeys.breadcrumbs] = {1680},
        },
        [1683] = { -- Vorlus Vilehoof
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1639, 1678},
            [questKeys.nextQuestInChain] = 1686,
        },
        [1684] = { -- Elanaria
            [questKeys.startedBy] = {{2151, 3598, 3657}},
            [questKeys.exclusiveTo] = {
                1639, 1678, -- not available once you pick these main quests
                1683, -- "follow up" quest from same NPC. NOT breadcrumb
            },
            [questKeys.nextQuestInChain] = 0,
        },
        [1685] = { -- Gakin's Summons
            [questKeys.breadcrumbForQuestId] = 1688, -- #7095
            [questKeys.exclusiveTo] = {},
        },
        [1686] = { -- The Shade of Elura
            [questKeys.preQuestSingle] = {1683, 1678, 1639},
        },
        [1687] = { -- Spooky Lighthouse
            [questKeys.triggerEnd] = {"Go to the Westfall Lighthouse.", {[zoneIDs.WESTFALL] = {{30.41, 85.61}}}},
            [questKeys.requiredSourceItems] = {18598},
        },
        [1688] = { -- Surena Caledon
            [questKeys.breadcrumbs] = {1685}, -- #7095
        },
        [1689] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Voidwalker"), 0, {{"object", 92015}}}},
        },
        [1692] = { -- Smith Mathiel
            [questKeys.preQuestSingle] = {1686},
            [questKeys.nextQuestInChain] = 1693,
        },
        [1698] = { -- Yorus Barleybrew
            [questKeys.startedBy] = {{5113, 5479, 7315}},
            [questKeys.breadcrumbForQuestId] = 1699,
        },
        [1699] = { -- The Rethban Gauntlet
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1698},
        },
        [1700] = { -- Grimand Elmore
            [questKeys.preQuestSingle] = {1782},
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.breadcrumbForQuestId] = 1705, -- #1857
        },
        [1701] = { -- Fire Hardened Mail
            [questKeys.nextQuestInChain] = 1782,
        },
        [1703] = { -- Mathiel
            [questKeys.preQuestSingle] = {1782},
            [questKeys.breadcrumbForQuestId] = 1710, -- #1857
        },
        [1704] = { -- Klockmort Spannerspan
            [questKeys.preQuestSingle] = {1782},
            [questKeys.breadcrumbForQuestId] = 1708, -- #1857
        },
        [1705] = { -- Burning Blood
            [questKeys.preQuestSingle] = {1782},
            [questKeys.breadcrumbs] = {1700}, -- #1857
            [questKeys.nextQuestInChain] = 1706,
        },
        [1708] = { -- Iron Coral
            [questKeys.preQuestSingle] = {1782},
            [questKeys.breadcrumbs] = {1704}, -- #1857
            [questKeys.nextQuestInChain] = 1709,
        },
        [1710] = { -- Sunscorched Shells
            [questKeys.preQuestSingle] = {1782},
            [questKeys.breadcrumbs] = {1703}, -- #1857
            [questKeys.nextQuestInChain] = 1711,
        },
        [1715] = { -- The Slaughtered Lamb
            [questKeys.exclusiveTo] = {1688},
        },
        [1716] = { -- Devourer of Souls
            [questKeys.questLevel] = -1,
        },
        [1717] = { -- Gakin's Summons
            [questKeys.exclusiveTo] = {1716},
            [questKeys.nextQuestInChain] = 0,
        },
        [1718] = { -- The Islander
            [questKeys.startedBy] = {{3041, 3354, 4595, 5113, 5479}}, -- #1034
        },
        [1739] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Succubus"), 0, {{"object", 92015}}}},
        },
        [1758] = { -- Tome of the Cabal
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1798},
        },
        [1783] = { -- The Tome of Divinity
            [questKeys.requiredSourceItems] = {6866},
        },
        [1786] = { -- The Tome of Divinity
            [questKeys.requiredSourceItems] = {6866},
        },
        [1789] = { -- The Symbol of Life (Ironforge)
            [questKeys.exclusiveTo] = {1784},
            [questKeys.preQuestSingle] = {1779},
        },
        [1790] = { -- The Symbol of Life (Stormwind)
            [questKeys.exclusiveTo] = {1787},
            [questKeys.preQuestSingle] = {1781},
        },
        [1793] = { -- The Tome of Valor
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 1649,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [1794] = { -- The Tome of Valor
            [questKeys.startedBy] = {{6179}},
            [questKeys.finishedBy] = {{6179}},
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 1649,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [1795] = { -- The Binding
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Felhunter"), 0, {{"object", 92388}}}},
        },
        [1796] = { -- Components for the Enchanted Gold Bloodrobe
            [questKeys.breadcrumbs] = {4736, 4737, 4738, 4739},
        },
        [1798] = { -- Seeking Strahad
            [questKeys.startedBy] = {{6120, 6122}},
            [questKeys.breadcrumbForQuestId] = 1758,
        },
        [1799] = { -- Fragments of the Orb of Orahil
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4965, 4967, 4968, 4969},
        },
        [1800] = { -- Lordaeron Throne Room
            [questKeys.triggerEnd] = {"Go to the old Lordaeron Throne Room that lies just before descending into the Undercity.", {[zoneIDs.UNDERCITY] = {{65.97, 36.12}}}},
            [questKeys.requiredSourceItems] = {18597},
        },
        [1801] = { -- Tome of the Cabal
            [questKeys.breadcrumbs] = {2996, 3001},
        },
        [1818] = { -- Speak with Dillinger
            [questKeys.breadcrumbForQuestId] = 1819,
            [questKeys.exclusiveTo] = {1498},
        },
        [1819] = { -- Ulag the Cleaver
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1818},
            [questKeys.exclusiveTo] = {1498},
        },
        [1820] = { -- Speak with Coleman
            [questKeys.preQuestSingle] = {1498, 1819},
            [questKeys.breadcrumbForQuestId] = 1821,
        },
        [1821] = { -- Agamand Heirlooms
            [questKeys.preQuestSingle] = {1498, 1819},
            [questKeys.breadcrumbs] = {1820},
        },
        [1823] = { -- Speak with Ruga
            [questKeys.startedBy] = {{3041, 3354, 4595}},
            [questKeys.breadcrumbForQuestId] = 1824,
        },
        [1824] = { -- Trial at the Field of Giants
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1823},
        },
        [1825] = { -- Speak with Thun'grim
            [questKeys.breadcrumbForQuestId] = 1838,
        },
        [1838] = { -- Brutal Armor
            [questKeys.preQuestSingle] = {1824},
            [questKeys.breadcrumbs] = {1825},
            [questKeys.nextQuestInChain] = 1848,
        },
        [1839] = { -- Ula'elek and the Brutal Gauntlets
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbForQuestId] = 1842,
        },
        [1840] = { -- Orm Stonehoof and the Brutal Helm
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbForQuestId] = 1844,
        },
        [1841] = { -- Velora Nitely and the Brutal Legguards
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbForQuestId] = 1846,
        },
        [1842] = { -- Satyr Hooves
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbs] = {1839},
            [questKeys.nextQuestInChain] = 1843,
        },
        [1844] = { -- Chimaeric Horn
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbs] = {1840},
            [questKeys.nextQuestInChain] = 1845,
        },
        [1846] = { -- Dragonmaw Shinbones
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbs] = {1841},
            [questKeys.nextQuestInChain] = 1847,
        },
        [1859] = { -- Therzok
            [questKeys.breadcrumbForQuestId] = 1963,
        },
        [1860] = { -- Speak with Jennea
            [questKeys.breadcrumbForQuestId] = 1861,
            [questKeys.exclusiveTo] = {1880},
        },
        [1861] = { -- Mirror Lake
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1880},
            [questKeys.breadcrumbs] = {1860},
        },
        [1879] = { -- Speak with Bink
            [questKeys.breadcrumbForQuestId] = 1880,
            [questKeys.exclusiveTo] = {1861},
        },
        [1880] = { -- Mage-tastic Gizmonitor
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1861},
            [questKeys.breadcrumbs] = {1879},
        },
        [1881] = { -- Speak with Anastasia
            [questKeys.breadcrumbForQuestId] = 1882,
            [questKeys.exclusiveTo] = {1884},
        },
        [1882] = { -- The Balnir Farmstead
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1884},
            [questKeys.breadcrumbs] = {1881},
        },
        [1883] = { -- Speak with Un'thuwa
            [questKeys.breadcrumbForQuestId] = 1884,
            [questKeys.exclusiveTo] = {1882},
            [questKeys.startedBy] = {{3049, 7311}},
        },
        [1884] = { -- Ju-Ju Heaps
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1882},
            [questKeys.breadcrumbs] = {1883},
        },
        [1885] = { -- Mennet Carkad
            [questKeys.breadcrumbForQuestId] = 1886,
        },
        [1886] = { -- The Deathstalkers
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1885},
        },
        [1919] = { -- Report to Jennea
            [questKeys.startedBy] = {{328, 1228, 7312}},
            [questKeys.breadcrumbForQuestId] = 1920, -- #1328
        },
        [1920] = { -- Investigate the Blue Recluse
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1919}, -- #1328
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Cantation of Manifestation to reveal Rift Spawn. Use Chest of Containment Coffers on stunned Rift Spawn"), 0, {{"monster", 6492}}}},
        },
        [1921] = { -- Gathering Materials
            [questKeys.nextQuestInChain] = 1941,
        },
        [1938] = { -- Ur's Treatise on Shadow Magic
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1939},
        },
        [1939] = { -- High Sorcerer Andromath
            [questKeys.startedBy] = {{5144, 5497}},
            [questKeys.breadcrumbForQuestId] = 1938,
        },
        [1940] = { -- Pristine Spider Silk
            [questKeys.nextQuestInChain] = 1942,
        },
        [1943] = { -- Speak with Deino
            [questKeys.breadcrumbForQuestId] = 1944, -- #2253
        },
        [1944] = { -- Waters of Xavian
            [questKeys.preQuestSingle] = {}, -- #2253
            [questKeys.breadcrumbs] = {1943},
        },
        [1945] = { -- Laughing Sisters
            [questKeys.nextQuestInChain] = 1946,
        },
        [1947] = { -- Journey to the Marsh
            [questKeys.startedBy] = {{3048, 4568, 5885, 5144, 5497}}, -- further split in faction fixes below
        },
        [1948] = { -- Items of Power
            [questKeys.preQuestSingle] = {1947},
        },
        [1950] = { -- Get the Scoop
            [questKeys.objectives] = {{{6626, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [1952] = { -- Mage's Wand
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1948, 1951},
        },
        [1953] = { -- Return to the Marsh
            [questKeys.breadcrumbForQuestId] = 1954,
            [questKeys.startedBy] = {{3048, 4568, 5885, 5144, 5497}}, -- further split in faction fixes below
        },
        [1954] = { -- The Infernal Orb
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1953},
        },
        [1955] = { -- The Exorcism
            [questKeys.triggerEnd] = {"Kill the Demon of the Orb", {[zoneIDs.DUSTWALLOW_MARSH] = {{45.6, 57.2}}}},
        },
        [1957] = { -- Mana Surges
            [questKeys.nextQuestInChain] = 1958,
        },
        [1959] = { -- Report to Anastasia
            [questKeys.startedBy] = {{2128, 3049, 5880, 7311}},
            [questKeys.breadcrumbForQuestId] = 1960,
        },
        [1960] = { -- Investigate the Alchemist Shop
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1959},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Cantation of Manifestation to reveal Rift Spawn. Use Chest of Containment Coffers on stunned Rift Spawn"), 0, {{"monster", 6492}}}},
        },
        [1961] = { -- Gathering Materials
            [questKeys.nextQuestInChain] = 1962,
        },
        [1962] = { -- Spellfire Robes
            [questKeys.startedBy] = {{4576, 11048, 11049}},
            [questKeys.finishedBy] = {{4576, 11048, 11049}},
        },
        [1963] = { -- The Shattered Hand
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1859},
        },
        [1999] = { -- Tools of the Trade
            [questKeys.requiredSourceItems] = {5060},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Estelle Gendry"), 0, {{"monster", 6566}}}},
        },
        [2038] = { -- Bingles' Missing Supplies
            [questKeys.breadcrumbs] = {2039},
        },
        [2039] = { -- Find Bingles
            [questKeys.breadcrumbForQuestId] = 2038,
        },
        [2040] = { -- Underground Assault
            [questKeys.breadcrumbs] = {2041}, -- #2068
        },
        [2041] = { -- Speak with Shoni
            [questKeys.breadcrumbForQuestId] = 2040, -- #2068
        },
        [2118] = { -- Plagued Lands
            [questKeys.objectives] = {{{2164, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [2138] = { -- Cleansing of the Infected
            [questKeys.nextQuestInChain] = 2139,
        },
        [2201] = { -- Find the Gems
            [questKeys.requiredLevel] = 37, -- #2447
        },
        [2205] = { -- Seek out SI: 7
            [questKeys.exclusiveTo] = {}, -- #1466
            [questKeys.nextQuestInChain] = 2206,
        },
        [2206] = { -- Snatch and Grab
            [questKeys.objectives] = {nil, nil, {{7675, nil, Questie.ICON_TYPE_INTERACT}}}, -- only obtainable via Pick Pocket
        },
        [2218] = { -- Road to Salvation
            [questKeys.exclusiveTo] = {}, -- #1466
        },
        [2240] = { -- The Hidden Chamber
            [questKeys.triggerEnd] = {"Explore the Hidden Chamber", {[zoneIDs.ULDAMAN] = {{-1, -1}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2398},
        },
        [2241] = { -- The Apple Falls
            [questKeys.exclusiveTo] = {}, -- #1466
            [questKeys.nextQuestInChain] = 2242,
        },
        [2242] = { -- Destiny Calls
            [questKeys.objectives] = {nil, nil, {{7737, nil, Questie.ICON_TYPE_INTERACT}}}, -- only obtainable via Pick Pocket
        },
        [2259] = { -- Erion Shadewhisper
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbForQuestId] = 2260, -- #2476
            [questKeys.availableUntilCompleted] = 2281,
        },
        [2260] = { -- Erion's Behest
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2259}, -- #2476
            [questKeys.availableUntilCompleted] = 2281,
        },
        [2278] = { -- The Platinum Discs
            [questKeys.objectives] = {{{7172, nil, Questie.ICON_TYPE_TALK}}},
        },
        [2298] = { -- Kingly Shakedown
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2299}, -- #2476
            [questKeys.availableUntilCompleted] = 2281,
        },
        [2299] = { -- To Hulfdan!
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbForQuestId] = 2298, -- #2476
            [questKeys.availableUntilCompleted] = 2281,
        },
        [2300] = { -- SI:7
            [questKeys.preQuestSingle] = {}, -- #1825
            [questKeys.availableUntilCompleted] = 2281,
            [questKeys.nextQuestInChain] = 0,
        },
        [2318] = { -- Translating the Journal
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [2358] = { -- Horns of Nez'ra
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2378] = { -- Find the Shattered Hand
            [questKeys.nextQuestInChain] = 0, -- if needed to be removed, move this one to tbcQuestFixes.lua
        },
        [2379] = { -- Zando'zan
            [questKeys.preQuestSingle] = {},
        },
        [2380] = { -- To Orgrimmar!
            [questKeys.nextQuestInChain] = 0, -- if needed to be removed, move this one to tbcQuestFixes.lua
        },
        [2381] = { -- Plundering the Plunderers
            [questKeys.objectivesText] = {"Bring the Southsea Treasure back to Wrenix the Wretched in Ratchet. Do not forget to get an E.C.A.C. and Thieves' Tools from Wrenix's Gizmotronic Apparatus. You will need both of these items to complete your mission.", "", "Should you be attacked by any unusually hostile parrots, use your E.C.A.C.!"},
            [questKeys.requiredSourceItems] = {7970, 5060},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Open the chest"), 0, {{"object", 123462}}},
                {nil, Questie.ICON_TYPE_INTERACT, l10n("Use the E.C.A.C. to weaken it"), 0, {{"monster", 7167}}},
            },
        },
        [2398] = { -- The Lost Dwarves
            [questKeys.breadcrumbForQuestId] = 2240,
        },
        [2438] = { -- The Emerald Dreamcatcher
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [2460] = { -- The Shattered Salute
            [questKeys.objectives] = {{{3401, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [2478] = { -- Mission: Possible But Not Probable
            [questKeys.requiredSourceItems] = {8066},
        },
        [2480] = { -- Hinott's Assistance
            [questKeys.triggerEnd] = {"Cure Completed", {[zoneIDs.HILLSBRAD_FOOTHILLS] = {{61.57, 19.21}}}},
        },
        [2500] = { -- Badlands Reagent Run
            [questKeys.nextQuestInChain] = 17,
        },
        [2501] = { -- Badlands Reagent Run II
            [questKeys.preQuestSingle] = {}, -- #1541
            [questKeys.preQuestGroup] = {2500, 17}, -- #1541
        },
        [2518] = { -- Tears of the Moon
            [questKeys.breadcrumbs] = {2519},
        },
        [2519] = { -- The Temple of the Moon
            [questKeys.breadcrumbForQuestId] = 2518,
        },
        [2520] = { -- Sathrah's Sacrifice
            [questKeys.objectives] = {nil, {{138498}}},
        },
        [2521] = { -- To Serve Kum'isha
            [questKeys.nextQuestInChain] = 2522,
        },
        [2561] = { -- Druid of the Claw
            [questKeys.objectives] = {{{7318, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [2581] = { -- Snickerfang Jowls
            [questKeys.nextQuestInChain] = 2582,
        },
        [2583] = { -- A Boar's Vitality
            [questKeys.nextQuestInChain] = 2584,
        },
        [2585] = { -- The Decisive Striker
            [questKeys.nextQuestInChain] = 2586,
        },
        [2601] = { -- The Basilisk's Bite
            [questKeys.nextQuestInChain] = 2602,
        },
        [2603] = { -- Vulture's Vigor
            [questKeys.nextQuestInChain] = 2604,
        },
        [2608] = { -- The Touch of Zanzil
            [questKeys.triggerEnd] = {"Diagnosis Complete", {[zoneIDs.STORMWIND_CITY] = {{78.04, 59}}}},
        },
        [2609] = { -- The Touch of Zanzil
            [questKeys.objectivesText] = {"Bring Doc Mixilpixil one bundle of Simple Wildflowers, one Leaded Vial, one Bronze Tube, and one Spool of Light Chartreuse Silk Thread. The 'itis' doesn't cure itself, young <fella/lady>."},
        },
        [2641] = { -- Sprinkle's Secret Ingredient
            [questKeys.nextQuestInChain] = 2661,
        },
        [2681] = { -- The Stones That Bind Us
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Release the Servant"), 1, {{"object", 141812}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Release the Servant"), 2, {{"object", 141857}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Release the Servant"), 3, {{"object", 141858}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Release the Servant"), 4, {{"object", 141859}}},
            },
        },
        [2701] = { -- Heroes of Old
            [questKeys.nextQuestInChain] = 2721,
        },
        [2742] = { -- Rin'ji is Trapped!
            [questKeys.triggerEnd] = {"Escort Rin'ji to safety", {[zoneIDs.THE_HINTERLANDS] = {{34.58, 56.33}}}},
        },
        [2744] = { -- The Demon Hunter
            [questKeys.objectives] = {{{7783, nil, Questie.ICON_TYPE_TALK}}},
        },
        [2746] = { -- Items of Some Consequence
            [questKeys.nextQuestInChain] = 434,
        },
        [2755] = { -- Joys of Omosh
            [questKeys.objectives] = {{{7790, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [2765] = { -- Expert Blacksmith!
            [questKeys.objectives] = {{{7802, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [2767] = { -- Rescue OOX-22/FE!
            [questKeys.triggerEnd] = {"Escort OOX-22/FE to the dock along the Forgotten Coast", {[zoneIDs.FERALAS] = {{45.63, 43.39}}}},
        },
        [2769] = { -- The Brassbolts Brothers
            [questKeys.breadcrumbForQuestId] = 2770, -- #2071
        },
        [2770] = { -- Gahz'rilla
            [questKeys.breadcrumbs] = {2769}, -- #2071
        },
        [2771] = { -- A Good Head On Your Shoulders
            [questKeys.preQuestSingle] = {2764},
        },
        [2772] = { -- The World At Your Feet
            [questKeys.preQuestSingle] = {2764},
        },
        [2773] = { -- The Mithril Kid
            [questKeys.preQuestSingle] = {2764},
        },
        [2781] = { -- WANTED: Caliph Scorpidsting
            [questKeys.startedBy] = {nil, {142122, 150075}}, -- #1081
        },
        [2784] = { -- Fall From Grace
            [questKeys.objectives] = {{{7572, nil, Questie.ICON_TYPE_TALK}}},
        },
        [2801] = { -- A Tale of Sorrow
            [questKeys.objectives] = {{{7572, nil, Questie.ICON_TYPE_TALK}}},
        },
        [2821] = { -- The Mark of Quality
            [questKeys.nextQuestInChain] = 7733,
        },
        [2822] = { -- The Mark of Quality
            [questKeys.nextQuestInChain] = 7734,
        },
        [2841] = { -- Rig Wars
            [questKeys.disabledByQuest] = 2842,
            [questKeys.childQuests] = {},
        },
        [2842] = { -- Chief Engineer Scooty
            [questKeys.requiredLevel] = 20,
            [questKeys.parentQuest] = 0,
        },
        [2843] = { -- Gnomer-gooooone!
            [questKeys.objectives] = {{{7853, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [2845] = { -- Wandering Shay
            [questKeys.triggerEnd] = {"Take Shay Leafrunner to Rockbiter's camp", {[zoneIDs.FERALAS] = {{42.33, 21.85}}}},
        },
        [2846] = { -- Tiara of the Deep
            [questKeys.breadcrumbs] = {2861},
        },
        [2847] = { -- Wild Leather Armor
            [questKeys.requiredSkill] = {profKeys.LEATHERWORKING, 200},
        },
        [2851] = { -- Wild Leather Boots
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2848, 2849, 2850}, -- #7161
        },
        [2852] = { -- Wild Leather Leggings
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2848, 2849, 2850}, -- #7161
        },
        [2853] = { -- Master of the Wild Leather
            [questKeys.preQuestGroup] = {2851, 2852}, -- #7161
        },
        [2854] = { -- Wild Leather Armor
            [questKeys.requiredSkill] = {profKeys.LEATHERWORKING, 200},
        },
        [2858] = { -- Wild Leather Boots
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2855, 2856, 2857}, -- #7161
        },
        [2859] = { -- Wild Leather Leggings
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2855, 2856, 2857}, -- #7161
        },
        [2860] = { -- Master of the Wild Leather
            [questKeys.preQuestGroup] = {2858, 2859}, -- #7161
        },
        [2861] = { -- Tabetha's Task
            [questKeys.startedBy] = {{4568, 5144, 5497, 5885}}, -- #1152
            [questKeys.breadcrumbForQuestId] = 2846,
        },
        [2864] = { -- Tran'rek
            [questKeys.breadcrumbForQuestId] = 2865, -- #2072
        },
        [2865] = { -- Scarab Shells
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2864}, -- #2072
        },
        [2867] = { -- Return to Feathermoon Stronghold
            [questKeys.nextQuestInChain] = 3130,
        },
        [2872] = { -- Stoley's Debt
            [questKeys.breadcrumbForQuestId] = 2873, -- #1566
        },
        [2873] = { -- Stoley's Shipment
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2872}, -- #1566
        },
        [2875] = { -- WANTED: Andre Firebeard
            [questKeys.startedBy] = {nil, {142122, 150075}},
        },
        [2880] = { -- Troll Necklace Bounty
            [questKeys.nextQuestInChain] = 2881,
        },
        [2882] = { -- Cuergo's Gold
            [questKeys.zoneOrSort] = 440, -- #1780
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use it"), 0, {{"object", 142189}}}},
        },
        [2904] = { -- A Fine Mess
            [questKeys.triggerEnd] = {"Kernobee Rescue", {[zoneIDs.GNOMEREGAN] = {{-1, -1}}}},
        },
        [2922] = { -- Save Techbot's Brain!
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2923}, -- #2067
        },
        [2923] = { -- Tinkmaster Overspark
            [questKeys.breadcrumbForQuestId] = 2922, -- #2067
        },
        [2924] = { -- Essential Artificials
            [questKeys.breadcrumbs] = {2925},
        },
        [2925] = { -- Klockmort's Essentials
            [questKeys.breadcrumbForQuestId] = 2924,
        },
        [2926] = { -- Gnogaine
            [questKeys.preQuestSingle] = {}, -- #2389
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Empty Leaden Collection Phial."), 0, {{"monster", 6213}, {"monster", 6329}}}},
            [questKeys.breadcrumbs] = {2927},
        },
        [2927] = { -- The Day After
            [questKeys.nextQuestInChain] = 2926,
            [questKeys.breadcrumbForQuestId] = 2926,
        },
        [2930] = { -- Data Rescue
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 1: obtain the Yellow Punch Card. You need the White Punch Card."), 0, {{"object", 142345}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 2: obtain the Blue Punch Card. You need the Yellow Punch Card."), 0, {{"object", 142475}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 3: obtain the Red Punch Card. You need the Blue Punch Card."), 0, {{"object", 142476}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 4: obtain the Prismatic Punch Card. You need the Red Punch Card."), 0, {{"object", 142696}}},
            },
            [questKeys.requiredSourceItems] = {9279, 9280, 9281, 9282},
            [questKeys.breadcrumbs] = {2931},
        },
        [2931] = { -- Castpipe's Task
            [questKeys.breadcrumbForQuestId] = 2930,
        },
        [2932] = { -- Grim Message
            [questKeys.triggerEnd] = {"Place the grim message.", {[zoneIDs.THE_HINTERLANDS] = {{23.41, 58.06}}}},
        },
        [2936] = { -- The Spider God
            [questKeys.triggerEnd] = {"Find the Spider God's Name", {[zoneIDs.TANARIS] = {{38.73, 19.88}}}},
        },
        [2939] = { -- In Search of Knowledge
            [questKeys.nextQuestInChain] = 2940,
        },
        [2943] = { -- Return to Troyas
            [questKeys.nextQuestInChain] = 2879,
        },
        [2946] = { -- Seeing What Happens
            [questKeys.nextQuestInChain] = 2954,
        },
        [2951] = { -- The Sparklematic 5200!
            [questKeys.exclusiveTo] = {4601, 4602},
        },
        [2952] = { -- The Sparklematic 5200!
            [questKeys.exclusiveTo] = {4605, 4606},
            [questKeys.preQuestSingle] = {2951, 4601, 4602},
        },
        [2953] = { -- More Sparklematic Action
            [questKeys.exclusiveTo] = {4603, 4604},
            [questKeys.preQuestSingle] = {2952, 4605, 4606},
        },
        [2954] = { -- The Stone Watcher
            [questKeys.startedBy] = {{7918}, {142343}},
            [questKeys.objectives] = {{{7918, nil, Questie.ICON_TYPE_TALK}}},
        },
        [2966] = { -- Seeing What Happens
            [questKeys.nextQuestInChain] = 2954,
        },
        [2969] = { -- Freedom for All Creatures
            [questKeys.triggerEnd] = {"Save at least 6 Sprite Darters from capture", {[zoneIDs.FERALAS] = {{67.27, 46.67}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the cage"), 0, {{"object", 143979}}}},
            [questKeys.nextQuestInChain] = 2970,
        },
        [2970] = { -- Doling Justice
            [questKeys.nextQuestInChain] = 2972,
        },
        [2972] = { -- Doling Justice
            [questKeys.nextQuestInChain] = 3841,
        },
        [2975] = { -- The Ogres of Feralas
            [questKeys.breadcrumbs] = {2981},
        },
        [2981] = { -- A Threat in Feralas
            [questKeys.breadcrumbForQuestId] = 2975,
        },
        [2983] = { -- Call of Fire
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [2984] = { -- Call of Fire
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [2985] = { -- Call of Water
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [2986] = { -- Call of Water
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [2992] = { -- The Divination
            [questKeys.objectives] = {{{8022, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [2994] = { -- Saving Sharpbeak
            [questKeys.questLevel] = 51, -- #1129
        },
        [2996] = { -- Seeking Strahad
            [questKeys.nextQuestInChain] = 1801,
            [questKeys.breadcrumbForQuestId] = 1801,
            [questKeys.exclusiveTo] = {},
        },
        [2997] = { -- Tome of Divinity (Dun Morogh)
            [questKeys.nextQuestInChain] = 1646,
            [questKeys.breadcrumbForQuestId] = 1646,
        },
        [2998] = { -- Tome of Divinity (Elwynn Forest)
            [questKeys.nextQuestInChain] = 1642,
            [questKeys.breadcrumbForQuestId] = 1642,
        },
        [2999] = { -- Tome of Divinity (Ironforge)
            [questKeys.nextQuestInChain] = 1646,
            [questKeys.breadcrumbForQuestId] = 1646,
        },
        [3000] = { -- Tome of Divinity (Stormwind)
            [questKeys.nextQuestInChain] = 1646,
            [questKeys.breadcrumbForQuestId] = 1646,
        },
        [3001] = { -- Seeking Strahad
            [questKeys.nextQuestInChain] = 1801,
            [questKeys.breadcrumbForQuestId] = 1801,
            [questKeys.exclusiveTo] = {},
        },
        [3090] = { -- Tainted Parchment
            [questKeys.requiredRaces] = raceIDs.ORC, -- #2399
        },
        [3128] = { -- Natural Materials
            [questKeys.preQuestSingle] = {3122},
        },
        [3141] = { -- Loramus
            [questKeys.objectives] = {{{7783, nil, Questie.ICON_TYPE_TALK}}},
        },
        [3182] = { -- Proof of Deed
            [questKeys.nextQuestInChain] = 3201,
        },
        [3321] = { -- Did You Lose This?
            [questKeys.objectives] = {{{7804, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [3364] = { -- Scalding Mornbrew Delivery
            [questKeys.nextQuestInChain] = 3365,
        },
        [3367] = { -- Suntara Stones
            [questKeys.triggerEnd] = {"Dorius Escort", {[zoneIDs.SEARING_GORGE] = {{74.47, 19.44}}}},
        },
        [3372] = { -- Release Them
            [questKeys.nextQuestInChain] = 3566,
        },
        [3374] = { -- The Essence of Eranikus
            [questKeys.nextQuestInChain] = 3512,
        },
        [3375] = { -- Replacement Phial
            [questKeys.preQuestSingle] = {2201},
            [questKeys.availableUntilCompleted] = 2361,
        },
        [3377] = { -- Prayer to Elune
            [questKeys.objectives] = {{{8436, nil, Questie.ICON_TYPE_TALK}}},
        },
        [3382] = { -- A Crew Under Fire
            [questKeys.triggerEnd] = {"Protect Captain Vanessa Beltis from the naga attack", {[zoneIDs.AZSHARA] = {{52.86, 87.77}}}},
        },
        [3385] = { -- The Undermarket
            [questKeys.requiredSkill] = {197, 230},
        },
        [3402] = { -- The Undermarket
            [questKeys.requiredSkill] = {197, 230},
        },
        [3441] = { -- Divine Retribution
            [questKeys.objectives] = {{{8479, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.nextQuestInChain] = 3442,
        },
        [3449] = { -- Arcane Runes
            [questKeys.childQuests] = {3450},
            [questKeys.requiredSourceItems] = {10444},
        },
        [3450] = { -- An Easy Pickup
            [questKeys.parentQuest] = 3449,
            [questKeys.preQuestSingle] = {},
        },
        [3451] = { -- Signal for Pickup
            [questKeys.availableUntilCompleted] = 3449,
            [questKeys.nextQuestInChain] = 3483,
        },
        [3453] = { -- The Torch of Retribution
            [questKeys.objectives] = {{{8479, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [3454] = { -- The Torch of Retribution
            [questKeys.nextQuestInChain] = 3462,
        },
        [3463] = { -- Set Them Ablaze!
            [questKeys.nextQuestInChain] = 3481,
        },
        [3481] = { -- Trinkets...
            [questKeys.nextQuestInChain] = 4022,
        },
        [3483] = { -- Signal for Pickup
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1131
            [questKeys.availableUntilCompleted] = 3449,
        },
        [3520] = { -- Screecher Spirits
            [questKeys.objectives] = {{{8612, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Vale Screechers and use Yeh'kinya's Bramble on their corpse."), 0, {{"monster", 5307}, {"monster", 5308}}}},
        },
        [3525] = { -- Extinguishing the Idol
            [questKeys.triggerEnd] = {"Protect Belnistrasz while he performs the ritual to shut down the idol", {[zoneIDs.THE_BARRENS] = {{50.86, 92.87}}}},
            [questKeys.finishedBy] = {nil, {152097}},
        },
        [3526] = { -- Goblin Engineering (Undercity)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3629, 3633, 4181, 3640, 3642},
            [questKeys.nextQuestInChain] = 3638,
        },
        [3528] = { -- The God Hakkar
            [questKeys.nextQuestInChain] = 5065,
        },
        [3601] = { -- Kim'jael Indeed!
            [questKeys.nextQuestInChain] = 5534,
        },
        [3602] = { -- Azsharite
            [questKeys.nextQuestInChain] = 3621,
            [questKeys.requiredSourceItems] = {10831, 10832},
        },
        [3625] = { -- Enchanted Azsharite Fel Weaponry
            [questKeys.objectives] = {{{7802, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [3628] = { -- You Are Rakh'likh, Demon
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Teleport to the top of the mountain."), 0, {{"object", 153203}, {"monster", 8816}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Ward of the Defiler to summon Razelikh."), 0, {{"object", 153205}}},
            },
        },
        [3629] = { -- Goblin Engineering (Stormwind)
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3526, 3633, 4181, 3640, 3642},
            [questKeys.nextQuestInChain] = 3638,
        },
        [3630] = { -- Gnome Engineering (Stormwind)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3632, 3634, 3635, 3637, 3638, 3642},
            [questKeys.nextQuestInChain] = 3640,
        },
        [3632] = { -- Gnome Engineering (Ironforge)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3630, 3634, 3635, 3637, 3638, 3642},
            [questKeys.nextQuestInChain] = 3640,
        },
        [3633] = { -- Goblin Engineering (Ratchet Neutral)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3526, 3629, 4181, 3640, 3642},
            [questKeys.nextQuestInChain] = 3638,
        },
        [3634] = { -- Gnome Engineering (Ratchet Alliance)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3630, 3632, 3635, 3637, 3638, 3642},
            [questKeys.nextQuestInChain] = 3640,
        },
        [3635] = { -- Gnome Engineering (Undercity)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3630, 3632, 3634, 3637, 3638, 3640},
            [questKeys.nextQuestInChain] = 3642,
        },
        [3637] = { -- Gnome Engineering (Ratchet Horde)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3630, 3632, 3634, 3635, 3638, 3640},
            [questKeys.nextQuestInChain] = 3642,
        },
        [3638] = { -- The Pledge of Secrecy
            [questKeys.exclusiveTo] = {3640, 3642},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
        },
        [3639] = { -- Show Your Work
            [questKeys.exclusiveTo] = {3640, 3641, 3642, 3643},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.nextQuestInChain] = 3644,
        },
        [3640] = { -- The Pledge of Secrecy
            [questKeys.exclusiveTo] = {3638, 3642},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
        },
        [3641] = { -- Show Your Work
            [questKeys.exclusiveTo] = {3638, 3639},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.nextQuestInChain] = 3647,
        },
        [3642] = { -- The Pledge of Secrecy
            [questKeys.exclusiveTo] = {3638, 3640},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
        },
        [3643] = { -- Show Your Work
            [questKeys.exclusiveTo] = {3638, 3639},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.nextQuestInChain] = 3645,
        },
        [3644] = { -- Membership Card Renewal
            [questKeys.preQuestSingle] = {3639, 3641, 3643},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GOBLIN,
        },
        [3645] = { -- Membership Card Renewal
            [questKeys.preQuestSingle] = {3639, 3641, 3643},
            [questKeys.startedBy] = {{7406}},
            [questKeys.finishedBy] = {{7406}},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GNOMISH,
        },
        [3646] = { -- Membership Card Renewal
            [questKeys.preQuestSingle] = {3639, 3641, 3643},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GOBLIN,
        },
        [3647] = { -- Membership Card Renewal
            [questKeys.preQuestSingle] = {3639, 3641, 3643},
            [questKeys.startedBy] = {{7944}},
            [questKeys.finishedBy] = {{7944}},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GNOMISH,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [3661] = { -- Favored of Elune?
            [questKeys.nextQuestInChain] = 978,
        },
        [3681] = { -- Tome of Divinity (Ironforge)
            [questKeys.nextQuestInChain] = 1642,
            [questKeys.breadcrumbForQuestId] = 1642,
        },
        [3701] = { -- The Smoldering Ruins of Thaurissan
            [questKeys.nextQuestInChain] = 4341,
        },
        [3702] = { -- The Smoldering Ruins of Thaurissan
            [questKeys.objectives] = {{{8879, nil, Questie.ICON_TYPE_TALK}}},
        },
        [3721] = { -- An OOX of Your Own
            [questKeys.zoneOrSort] = zoneIDs.STRANGLETHORN_VALE,
        },
        [3761] = { -- Un'Goro Soil
            [questKeys.breadcrumbs] = {936, 3762, 3784},
            [questKeys.nextQuestInChain] = 3782,
        },
        [3762] = { -- Assisting Arch Druid Runetotem
            [questKeys.breadcrumbForQuestId] = 3761,
        },
        [3763] = { -- Assisting Arch Druid Staghelm
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [3764] = { -- Un'Goro Soil
            [questKeys.breadcrumbs] = {3763, 3789, 3790},
            [questKeys.nextQuestInChain] = 3781,
        },
        [3765] = { -- The Corruption Abroad
            [questKeys.breadcrumbForQuestId] = 1275, -- #745
            [questKeys.requiredLevel] = 18,
        },
        [3784] = { -- Assisting Arch Druid Runetotem
            [questKeys.breadcrumbForQuestId] = 3761,
        },
        [3785] = { -- Morrowgrain Research
            [questKeys.nextQuestInChain] = 3803,
            [questKeys.requiredSourceItems] = {11018, 11022},
        },
        [3786] = { -- Morrowgrain Research
            [questKeys.nextQuestInChain] = 3804,
            [questKeys.requiredSourceItems] = {11018, 11022},
        },
        [3787] = { -- Jonespyre's Request
            [questKeys.preQuestSingle] = {3781},
            [questKeys.breadcrumbForQuestId] = 3791,
        },
        [3788] = { -- Jonespyre's Request
            [questKeys.preQuestSingle] = {3781},
            [questKeys.breadcrumbForQuestId] = 3791,
        },
        [3789] = { -- Assisting Arch Druid Staghelm
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [3790] = { -- Assisting Arch Druid Staghelm
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [3791] = { -- The Mystery of Morrowgrain
            [questKeys.requiredSourceItems] = {11018, 11022},
            [questKeys.preQuestSingle] = {3781}, -- #7241
            [questKeys.breadcrumbs] = {3787, 3788}, -- #885
            [questKeys.nextQuestInChain] = 3792,
        },
        [3842] = { -- A Short Incubation
            [questKeys.nextQuestInChain] = 3843,
        },
        [3903] = { -- Milly Osworth
            [questKeys.preQuestSingle] = {18},
            [questKeys.breadcrumbForQuestId] = 3904,
        },
        [3904] = { -- Milly's Harvest
            [questKeys.preQuestSingle] = {18},
            [questKeys.breadcrumbs] = {3903},
        },
        [3909] = { -- The Videre Elixir
            [questKeys.requiredSourceItems] = {11141, 11242},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Bait in front of Miblon Snarltooth."), 0, {{"monster", 9467}}}},
        },
        [3912] = { -- Meet at the Grave
            [questKeys.requiredSourceItems] = {11243},
        },
        [3922] = { -- Nugget Slugs
            [questKeys.nextQuestInChain] = 3923,
        },
        [3982] = { -- What Is Going On?
            [questKeys.objectives] = {{{9020, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [4001] = { -- What Is Going On?
            [questKeys.objectives] = {{{9021, nil, Questie.ICON_TYPE_TALK}}},
        },
        [4005] = { -- Aquementas
            [questKeys.requiredSourceItems] = {11169, 11172, 11173},
        },
        [4021] = { -- Counterattack!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Hold off Kolkar invaders until Warlord Krom'zar spawns and then loot the banner spawned on his corpse."), 0, {{"monster", 9456}}}},
        },
        [4022] = { -- A Taste of Flame
            [questKeys.objectives] = {nil, nil, {{10575}}, nil, {{{9459}, 9459, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.objectivesText] = {"Show Cyrus Therepentous the Black Dragonflight Molt you received from Kalaran Windblade."},
        },
        [4023] = { -- A Taste of Flame
            [questKeys.availableUntilCompleted] = 3481,
        },
        [4024] = { -- A Taste of Flame
            [questKeys.objectivesText] = {"Travel to Blackrock Depths and slay Bael'Gar.", "", "You only know that the giant resides inside Blackrock Depths. Remember to use the Altered Black Dragonflight Molt on Bael'Gar's remains to capture the Fiery Essence.", "", "Return the Encased Fiery Essence to Cyrus Therepentous."},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Altered Black Dragonflight Molt on Bael'gar's corpse."), 0, {{"monster", 9016}}}},
        },
        [4083] = { -- The Spectral Chalice
            [questKeys.requiredSkill] = {186, 230}, -- #1293
        },
        [4084] = { -- Silver Heart
            [questKeys.questLevel] = 54, -- #1495
        },
        [4101] = { -- Cleansing Felwood
            [questKeys.nextQuestInChain] = 5882,
        },
        -- Alliance
        [4103] = { -- Salve via Hunting
            [questKeys.preQuestSingle] = {5882},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [4104] = { -- Salve via Mining
            [questKeys.preQuestSingle] = {5883},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredSkill] = {profKeys.MINING, 200},
        },
        [4105] = { -- Salve via Gathering
            [questKeys.preQuestSingle] = {5884},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredSkill] = {profKeys.HERBALISM, 200},
        },
        [4106] = { -- Salve via Skinning
            [questKeys.preQuestSingle] = {5885},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredSkill] = {profKeys.SKINNING, 200},
        },
        [4107] = { -- Salve via Disenchanting
            [questKeys.preQuestSingle] = {5886},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredSkill] = {profKeys.ENCHANTING, 200},
        },
        -- Horde
        [4108] = { -- Salve via Hunting
            [questKeys.startedBy] = {{9529}},
            [questKeys.finishedBy] = {{9529}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887},
        },
        [4109] = { -- Salve via Mining
            [questKeys.startedBy] = {{9529}},
            [questKeys.finishedBy] = {{9529}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5888},
            [questKeys.requiredSkill] = {profKeys.MINING, 200},
        },
        [4110] = { -- Salve via Gathering
            [questKeys.startedBy] = {{9529}},
            [questKeys.finishedBy] = {{9529}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5889},
            [questKeys.requiredSkill] = {profKeys.HERBALISM, 200},
        },
        [4111] = { -- Salve via Skinning
            [questKeys.startedBy] = {{9529}},
            [questKeys.finishedBy] = {{9529}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5890},
            [questKeys.requiredSkill] = {profKeys.SKINNING, 200},
        },
        [4112] = { -- Salve via Disenchanting
            [questKeys.startedBy] = {{9529}},
            [questKeys.finishedBy] = {{9529}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5891},
            [questKeys.requiredSkill] = {profKeys.ENCHANTING, 200},
        },
        [4121] = { -- Precarious Predicament
            [questKeys.triggerEnd] = {"Prisoner Transport", {[zoneIDs.BURNING_STEPPES] = {{25.73, 27.1}}}},
        },
        [4122] = { -- Grark Lorkrub
            [questKeys.preQuestSingle] = {4082}, -- #1349
        },
        [4123] = { -- The Heart of the Mountain
            [questKeys.requiredSourceItems] = {11078},
        },
        [4126] = { -- Hurley Blackbreath
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4128},
        },
        [4127] = { -- Boat Wreckage
            [questKeys.startedBy] = {nil, {164909, 186419}},
        },
        [4128] = { -- Ragnar Thunderbrew
            [questKeys.breadcrumbForQuestId] = 4126,
        },
        [4133] = { -- Vivian Lagrave
            [questKeys.breadcrumbForQuestId] = 4134, -- #1859
        },
        [4134] = { -- Lost Thunderbrew Recipe
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4133}, -- #1859
        },
        [4136] = { -- Ribbly Screwspigot
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4324}, -- #4459
        },
        [4143] = { -- Haze of Evil
            [questKeys.nextQuestInChain] = 4144,
        },
        [4146] = { -- Zapper Fuel
            [questKeys.zoneOrSort] = zoneIDs.UN_GORO_CRATER,
            [questKeys.nextQuestInChain] = 4148,
        },
        [4181] = { -- Goblin Engineering (Ironforge)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3526, 3629, 3633, 3640, 3642},
            [questKeys.nextQuestInChain] = 3638,
        },
        [4185] = { -- The True Masters
            [questKeys.objectives] = {{{1749, nil, Questie.ICON_TYPE_TALK}}},
        },
        [4224] = { -- The True Masters
            [questKeys.objectives] = {{{9563, nil, Questie.ICON_TYPE_TALK}}},
        },
        [4242] = { -- Abandoned Hope
            [questKeys.nextQuestInChain] = 4264,
        },
        [4244] = { -- Chasing A-Me 01
            [questKeys.nextQuestInChain] = 4245,
        },
        [4245] = { -- Chasing A-Me 01
            [questKeys.triggerEnd] = {"Protect A-Me 01 until you reach Karna Remtravel", {[zoneIDs.UN_GORO_CRATER] = {{46.43, 13.78}}}},
        },
        [4261] = { -- Ancient Spirit
            [questKeys.triggerEnd] = {"Help Arei get to Safety", {[zoneIDs.FELWOOD] = {{49.42, 14.54}}}},
        },
        [4265] = { -- Freed from the Hive
            [questKeys.triggerEnd] = {"Free Raschal.", {[zoneIDs.FERALAS] = {{72.13, 63.84}}}},
        },
        [4281] = { -- Thalanaar Delivery
            [questKeys.preQuestSingle] = {4131},
        },
        [4282] = { -- A Shred of Hope
            [questKeys.nextQuestInChain] = 4322,
        },
        [4285] = { -- The Northern Pylon
            [questKeys.objectives] = {nil, {{164955}}},
        },
        [4287] = { -- The Eastern Pylon
            [questKeys.objectives] = {nil, {{164957}}},
        },
        [4288] = { -- The Western Pylon
            [questKeys.objectives] = {nil, {{164956}}},
        },
        [4289] = { -- The Apes of Un'Goro
            [questKeys.nextQuestInChain] = 4301,
        },
        [4292] = { -- The Bait for Lar'korwi
            [questKeys.requiredSourceItems] = {11569, 11570},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Place the meat"), 0, {{"object", 172619}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Apply the pheromones"), 0, {{"object", 169216}}},
            },
        },
        [4295] = { -- Rocknot's Ale
            [questKeys.requiredLevel] = 42,
        },
        [4322] = { -- Jail Break!
            [questKeys.triggerEnd] = {"Jail Break!", {[zoneIDs.BLACKROCK_DEPTHS] = {{-1, -1}}}},
        },
        [4324] = { -- Yuka Screwspigot
            [questKeys.breadcrumbForQuestId] = 4136, -- #4459
        },
        [4341] = { -- Kharan Mighthammer
            [questKeys.nextQuestInChain] = 4342,
        },
        [4342] = { -- Kharan's Tale
            [questKeys.objectives] = {{{9021, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {4341},
        },
        [4361] = { -- The Bearer of Bad News
            [questKeys.preQuestSingle] = {4342},
        },
        [4421] = { -- The Corruption of the Jadefire
            [questKeys.nextQuestInChain] = 4906,
        },
        [4441] = { -- Felbound Ancients
            [questKeys.nextQuestInChain] = 4442,
        },
        [4442] = { -- Purified!
            [questKeys.nextQuestInChain] = 4261,
        },
        [4485] = { -- The Tome of Nobility
            [questKeys.startedBy] = {{6179}},
            [questKeys.exclusiveTo] = {1661, 4486},
        },
        [4486] = { -- The Tome of Nobility
            [questKeys.exclusiveTo] = {1661, 4485},
        },
        [4490] = { -- Summon Felsteed
            [questKeys.preQuestSingle] = {3631, 4487, 4488, 4489},
        },
        [4491] = { -- A Little Help From My Friends
            [questKeys.triggerEnd] = {"Escort Ringo to Spraggle Frock at Marshal's Refuge", {[zoneIDs.UN_GORO_CRATER] = {{43.71, 8.29}}}},
        },
        [4492] = { -- Lost!
            [questKeys.triggerEnd] = {"Escort Ringo to Spraggle Frock at Marshal's Refuge", {[zoneIDs.UN_GORO_CRATER] = {{43.71, 8.29}}}}, -- needed for deDE blizzard spaghetti #2432
            [questKeys.nextQuestInChain] = 4491,
        },
        [4493] = { -- March of the Silithid
            [questKeys.preQuestSingle] = {162},
        },
        [4494] = { -- March of the Silithid
            [questKeys.preQuestSingle] = {32, 7732},
        },
        [4495] = { -- A Good Friend
            [questKeys.nextQuestInChain] = 3519,
        },
        [4496] = { -- Bungle in the Jungle
            [questKeys.preQuestSingle] = {4493, 4494},
            [questKeys.nextQuestInChain] = 4507,
        },
        [4505] = { -- Well of Corruption
            [questKeys.breadcrumbs] = {6605}, -- #1859
        },
        [4506] = { -- Corrupted Sabers
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Release the kitten near the Jadefire Satyrs' corrupted moonwell."), 0, {{"object", 148501}}}},
            [questKeys.triggerEnd] = {"Return the corrupted cat to Winna Hazzard", {[zoneIDs.FELWOOD] = {{34.26, 52.32}}}},
        },
        [4507] = { -- Pawn Captures Queen
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Gorishi Queen Lure."), 0, {{"object", 174792}}}},
        },
        [4512] = { -- A Little Slime Goes a Long Way
            [questKeys.requiredSourceItems] = {11914, 11948},
            [questKeys.nextQuestInChain] = 4513,
        },
        [4513] = { -- A Little Slime Goes a Long Way
            [questKeys.requiredSourceItems] = {11953},
        },
        [4542] = { -- Message to Freewind Post
            [questKeys.breadcrumbForQuestId] = 4841,
        },
        [4601] = { -- The Sparklematic 5200!
            [questKeys.exclusiveTo] = {2951, 4602},
        },
        [4602] = { -- The Sparklematic 5200!
            [questKeys.exclusiveTo] = {2951, 4601},
        },
        [4603] = { -- More Sparklematic Action
            [questKeys.exclusiveTo] = {2953, 4604},
            [questKeys.preQuestSingle] = {2952, 4605, 4606},
        },
        [4604] = { -- More Sparklematic Action
            [questKeys.exclusiveTo] = {2953, 4603},
            [questKeys.preQuestSingle] = {2955, 4605, 4606},
        },
        [4605] = { -- The Sparklematic 5200!
            [questKeys.exclusiveTo] = {2952, 4606},
            [questKeys.preQuestSingle] = {2951, 4601, 4602},
        },
        [4606] = { -- The Sparklematic 5200!
            [questKeys.exclusiveTo] = {2952, 4605},
            [questKeys.preQuestSingle] = {2951, 4601, 4602},
        },
        [4621] = { -- Avast Ye, Admiral!
            [questKeys.breadcrumbs] = {1036},
            [questKeys.requiredMinRep] = {87, 3000},
            [questKeys.requiredMaxRep] = {21, -6000},
        },
        [4641] = { -- Your Place In The World
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #877
            [questKeys.breadcrumbForQuestId] = 788, -- #1956
        },
        [4726] = { -- Broodling Essence
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Draco-Incarcinatrix 900 and defeat the dragonkin."), 0, {{"monster", 7047}, {"monster", 7048}, {"monster", 7049}}}},
        },
        [4729] = { -- Kibler's Exotic Pets
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Empty Worg Pup Cage to capture it."), 0, {{"monster", 10221}}}},
        },
        [4734] = { -- Egg Freezing
            [questKeys.objectives] = {nil, {{175124}}},
            [questKeys.breadcrumbs] = {4907},
            [questKeys.nextQuestInChain] = 4735,
        },
        [4735] = { -- Egg Collection
            [questKeys.objectives] = {nil, {{175124}}},
        },
        [4736] = { -- In Search of Menara Voidrender
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4737] = { -- In Search of Menara Voidrender
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4738] = { -- In Search of Menara Voidrender
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4739] = { -- In Search of Menara Voidrender
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4742] = { -- Seal of Ascension
            [questKeys.startedBy] = {{10299}},
            [questKeys.finishedBy] = {{10299}},
        },
        [4743] = { -- Seal of Ascension
            [questKeys.requiredSourceItems] = {12300, 12323},
            [questKeys.startedBy] = {{10299}},
            [questKeys.finishedBy] = {{10299}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Beat Emberstrife till his will is broken, then place the Unforged Seal of Ascension before him and use the Orb of Draconic Energy."), 0, {{"monster", 10321}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Flames of the Black Flight over it to create the Seal."), 0, {{"object", 175321}}},
            },
        },
        [4762] = { -- The Cliffspring River
            [questKeys.nextQuestInChain] = 4763,
        },
        [4763] = { -- The Blackwood Corrupted
            [questKeys.requiredSourceItems] = {12341, 12342, 12343, 12347}, -- #798
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Xabraxxis once you have the required items from the Blackwood Stores."), 0, {{"object", 175338}}}},
        },
        [4764] = { -- Doomrigger's Clasp
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4766}, -- #1916
        },
        [4766] = { -- Mayara Brightwing
            [questKeys.breadcrumbForQuestId] = 4764 -- #1916
        },
        [4768] = { -- The Darkstone Tablet
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4769}, -- #1859
        },
        [4769] = { -- Vivian Lagrave and the Darkstone Tablet
            [questKeys.breadcrumbForQuestId] = 4768, -- #1859
        },
        [4770] = { -- Homeward Bound
            [questKeys.triggerEnd] = {"Escort Pao'ka from Highperch", {[zoneIDs.THOUSAND_NEEDLES] = {{15.15, 32.65}}}},
        },
        [4771] = { -- Dawn's Gambit
            [questKeys.triggerEnd] = {"Place Dawn's Gambit", {[zoneIDs.SCHOLOMANCE] = {{-1, -1}}}},
        },
        [4785] = { -- Fine Gold Thread
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1367
            [questKeys.availableUntilCompleted] = 4784,
        },
        [4786] = { -- The Completed Robe
            [questKeys.objectives] = {{{6266, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [4788] = { -- The Final Tablets
            [questKeys.nextQuestInChain] = 8181,
        },
        [4810] = { -- Return to Tinkee
            [questKeys.nextQuestInChain] = 4907,
        },
        [4811] = { -- The Red Crystal
            [questKeys.objectives] = {nil, {{175524, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [4841] = { -- Pacify the Centaur
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4542},
        },
        [4822] = { -- You Scream, I Scream...
            [questKeys.objectivesText] = {"Get some Strawberry Ice Cream for your ward. The lad seems to prefer Tigule's brand ice cream."}, -- human orphan
            [questKeys.inGroupWith] = nil,
            [questKeys.preQuestGroup] = {1479, 1558, 1687},
            [questKeys.childQuests] = {},
            [questKeys.requiredSourceItems] = {18598},
        },
        [4861] = { -- Enraged Wildkin
            [questKeys.breadcrumbs] = {6604},
        },
        [4866] = { -- Mother's Milk
            [questKeys.objectives] = {{{9563, nil, Questie.ICON_TYPE_TALK}}},
        },
        [4867] = { -- Urok Doomhowl
            [questKeys.requiredSourceItems] = {12533, 12534},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Combine Omokk's Head with the Roughshod Pike."), 0, {{"object", 175621}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use it to instantly kill one nearby ogre."), 0, {{"object", 175584}}},
            },
        },
        [4882] = { -- Guarding Secrets
            [questKeys.preQuestSingle] = {4741},
        },
        [4901] = { -- Guardians of the Altar
            [questKeys.triggerEnd] = {"Discover the secret of the Altar of Elune", {[zoneIDs.WINTERSPRING] = {{64.85, 63.73}}}},
            [questKeys.nextQuestInChain] = 4902,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use it when Ranshalla tells you to"), 0, {{"object", 177404}, {"object", 177417}}}},
        },
        [4904] = { -- Free at Last
            [questKeys.triggerEnd] = {"Escort Lakota Windsong from the Darkcloud Pinnacle.", {[zoneIDs.THOUSAND_NEEDLES] = {{30.93, 37.12}}}},
        },
        [4907] = { -- Tinkee Steamboil
            [questKeys.breadcrumbForQuestId] = 4734,
        },
        [4921] = { -- Lost in Battle
            [questKeys.objectives] = {{{10668, nil, Questie.ICON_TYPE_TALK}}},
        },
        [4941] = { -- Eitrigg's Wisdom
            [questKeys.triggerEnd] = {"Council with Eitrigg.", {[zoneIDs.ORGRIMMAR] = {{34.14, 39.26}}}},
        },
        [4961] = { -- Cleansing of the Orb of Orahil
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1799, 4962}, -- 4962+4963
        },
        [4962] = { -- Shard of an Infernal
            [questKeys.parentQuest] = 0,
        },
        [4963] = { -- Shard of an Infernal
            [questKeys.parentQuest] = 0,
        },
        [4964] = { -- The Completed Orb of Dar'Orahil
            [questKeys.objectives] = {{{6266, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {4976, -4962},
            [questKeys.exclusiveTo] = {4963},
        },
        [4965] = { -- Knowledge of the Orb of Orahil
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4966] = { -- Protect Kanati Greycloud
            [questKeys.objectives] = {{{10720}}},
        },
        [4967] = { -- Knowledge of the Orb of Orahil
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4968] = { -- Knowledge of the Orb of Orahil
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4969] = { -- Knowledge of the Orb of Orahil
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4971] = { -- A Matter of Time
            [questKeys.nextQuestInChain] = 4972,
        },
        [4972] = { -- Counting Out Time
            [questKeys.nextQuestInChain] = 4973,
        },
        [4975] = { -- The Completed Orb of Noh'Orahil
            [questKeys.objectives] = {{{6266, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {4976, -4963},
            [questKeys.exclusiveTo] = {4962},
        },
        [5041] = { -- Supplies for the Crossroads
            [questKeys.preQuestSingle] = {},
        },
        [5047] = { -- Pip Quickwit, At Your Service!
            [questKeys.name] = "Pip Quickwit, At Your Service!",
        },
        [5052] = { -- Blood Shards of Agamaggan
            [questKeys.nextQuestInChain] = 879,
        },
        [5056] = { -- Shy-Rotam
            [questKeys.requiredSourceItems] = {12733},
            [questKeys.nextQuestInChain] = 5057,
        },
        [5057] = { -- Past Endeavors
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {},
        },
        [5063] = { -- Cap of the Scarlet Savant
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1335
        },
        [5067] = { -- Leggings of Arcana
            [questKeys.questLevel] = 60,
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1335
        },
        [5066] = { -- A Call to Arms: The Plaguelands!
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [5068] = { -- Breastplate of Bloodthirst
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1335
        },
        [5082] = { -- Threat of the Winterfall
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {6603}, -- #1824
        },
        [5088] = { -- Arikara
            [questKeys.objectives] = {nil, {{175944}}, {{12925}}},
        },
        [5090] = { -- A Call to Arms: The Plaguelands!
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [5091] = { -- A Call to Arms: The Plaguelands!
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [5092] = { -- Clear the Way
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5066, 5090, 5091},
            [questKeys.nextQuestInChain] = 5097, -- chose the more important quest branch
        },
        [5093] = { -- A Call to Arms: The Plaguelands!
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [5094] = { -- A Call to Arms: The Plaguelands!
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [5095] = { -- A Call to Arms: The Plaguelands!
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [5096] = { -- Scarlet Diversions
            [questKeys.triggerEnd] = {"Destroy the command tent and plant the Scourge banner in the camp", {[zoneIDs.WESTERN_PLAGUELANDS] = {{40.72, 52.04}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5093, 5094, 5095},
            [questKeys.nextQuestInChain] = 5098, -- chose the more important quest branch
        },
        [5097] = { -- All Along the Watchtowers
            [questKeys.nextQuestInChain] = 5533, -- chose the more important quest branch
            [questKeys.objectives] = {{{10902, nil, Questie.ICON_TYPE_EVENT}, {10903, nil, Questie.ICON_TYPE_EVENT}, {10904, nil, Questie.ICON_TYPE_EVENT}, {10905, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [5098] = { -- All Along the Watchtowers
            [questKeys.nextQuestInChain] = 838, -- chose the more important quest branch
            [questKeys.objectives] = {{{10902, nil, Questie.ICON_TYPE_EVENT}, {10903, nil, Questie.ICON_TYPE_EVENT}, {10904, nil, Questie.ICON_TYPE_EVENT}, {10905, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [5103] = { -- Hot Fiery Death
            [questKeys.requiredLevel] = 55,
            [questKeys.requiredSourceItems] = {12812},
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING, 270},
        },
        [5122] = { -- The Medallion of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1140
        },
        [5123] = { -- The Final Piece
            [questKeys.nextQuestInChain] = 5128,
        },
        [5124] = { -- Fiery Plate Gauntlets
            [questKeys.requiredSkill] = {164, 275},
        },
        [5126] = { -- Lorax's Tale
            [questKeys.nextQuestInChain] = 5127,
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.SHAMAN,
            [questKeys.objectives] = {{{10918, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.zoneOrSort] = sortKeys.BLACKSMITHING,
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING, 270},
        },
        [5127] = { -- The Demon Forge
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING, 270},
        },
        [5142] = { -- Little Pamela
            [questKeys.breadcrumbForQuestId] = 5149,
        },
        [5143] = { -- Tribal Leatherworking
            [questKeys.preQuestSingle] = {2853},
        },
        [5148] = { -- Tribal Leatherworking
            [questKeys.preQuestSingle] = {2860},
        },
        [5149] = { -- Pamela's Doll
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5142, 5601},
        },
        [5151] = { -- Hypercapacitor Gizmo
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the cage"), 0, {{"object", 176195}}}},
        },
        [5156] = { -- Verifying the Corruption
            [questKeys.triggerEnd] = {"Explore the craters in Shatter Scar Vale", {[zoneIDs.FELWOOD] = {{41.03, 41.96}}}},
        },
        [5158] = { -- Seeking Spiritual Aid
            [questKeys.nextQuestInChain] = 5159,
        },
        [5163] = { -- Are We There, Yeti?
            [questKeys.objectives] = {{{10978, nil, Questie.ICON_TYPE_EVENT}, {7583, nil, Questie.ICON_TYPE_EVENT}, {10977, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [5165] = { -- Dousing the Flames of Protection
            [questKeys.nextQuestInChain] = 5242,
        },
        [5202] = { -- A Strange Red Key
            [questKeys.nextQuestInChain] = 5203,
        },
        [5203] = { -- Rescue From Jaedenar
            [questKeys.triggerEnd] = {"Protect Arko'narin out of Shadow Hold", {[zoneIDs.FELWOOD] = {{35.45, 59.06}}}},
        },
        [5211] = { -- Defenders of Darrowshire
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5241},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay ghouls to free Darrowshire spirits"), 0, {{"monster", 8530}, {"monster", 8531}, {"monster", 8532}}}},
            [questKeys.objectives] = {{{11064, nil, Questie.ICON_TYPE_TALK}}},
        },
        [5214] = { -- The Great Ezra Grimm
            [questKeys.name] = "The Great Ezra Grimm",
            [questKeys.objectivesText] = {"Find Ezra Grimm's smoke shop in Stratholme and recover a box of Grimm's Premium Tobacco. Return to Smokey LaRue when the job is done."},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the box"), 0, {{"object", 176248}}}},
        },
        [5218] = { -- Felstone Field Cauldron
            [questKeys.preQuestSingle] = {5217, 5230},
        },
        [5221] = { -- Dalson's Tears Cauldron
            [questKeys.preQuestSingle] = {5220, 5232},
        },
        [5224] = { -- Writhing Haunt Cauldron
            [questKeys.preQuestSingle] = {5223, 5234},
        },
        [5226] = { -- Return to Chillwind Camp
            [questKeys.name] = "Return to Chillwind Camp",
            [questKeys.nextQuestInChain] = 5238,
        },
        [5227] = { -- Gahrron's Withering Cauldron
            [questKeys.preQuestSingle] = {5226, 5236},
        },
        [5234] = { -- Return to the Bulwark
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [5236] = { -- Return to the Bulwark
            [questKeys.nextQuestInChain] = 5237,
        },
        [5237] = { -- Mission Accomplished!
            [questKeys.startedBy] = {{10838}},
            [questKeys.finishedBy] = {{10838}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {5226},
        },
        [5238] = { -- Mission Accomplished!
            [questKeys.startedBy] = {{10837}},
            [questKeys.finishedBy] = {{10837}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {5236},
        },
        [5241] = { -- Brother Carlin
            [questKeys.breadcrumbForQuestId] = 5211,
        },
        [5244] = { -- The Ruins of Kel'Theril
            [questKeys.breadcrumbs] = {5249, 5250},
        },
        [5249] = { -- To Winterspring!
            [questKeys.breadcrumbForQuestId] = 5244,
        },
        [5250] = { -- Starfall
            [questKeys.breadcrumbForQuestId] = 5244,
        },
        [5261] = { -- Eagan Peltskinner
            [questKeys.breadcrumbForQuestId] = 33, -- #1726
        },
        [5263] = { -- Above and Beyond
            [questKeys.nextQuestInChain] = 5264,
        },
        [5305] = { -- Sweet Serenity
            [questKeys.exclusiveTo] = {8869},
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5306] = { -- Snakestone of the Shadow Huntress
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5307] = { -- Corruption
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5321] = { -- The Sleeper Has Awakened
            [questKeys.triggerEnd] = {"Escort Kerlonian Evershade to Maestra's Post", {[zoneIDs.ASHENVALE] = {{26.77, 36.91}}}},
        },
        [5384] = { -- Kirtonos the Herald
            [questKeys.nextQuestInChain] = 5461,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Kirtonos"), 0, {{"object", 175564}}}},
        },
        [5386] = { -- Catch of the Day
            [questKeys.childQuests] = {},
        },
        [5401] = { -- Argent Dawn Commission
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5402] = { -- Minion's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5403] = { -- Invader's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5404] = { -- Corruptor's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5405] = { -- Argent Dawn Commission
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5406] = { -- Corruptor's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5407] = { -- Invader's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5408] = { -- Minion's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5421] = { -- Fish in a Bucket
            [questKeys.parentQuest] = 0,
            [questKeys.questLevel] = 25,
        },
        [5441] = { -- Lazy Peons
            [questKeys.objectives] = {{{10556, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [5508] = { -- Corruptor's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
        },
        [5509] = { -- Invader's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
        },
        [5510] = { -- Minion's Scourgestones
            [questKeys.preQuestSingle] = {5401, 5503, 5405},
        },
        [5518] = { -- The Gordok Ogre Suit
            [questKeys.nextQuestInChain] = 5519,
        },
        [5525] = { -- Free Knot!
            [questKeys.nextQuestInChain] = 7429,
        },
        [5526] = { -- Shards of the Felvine
            [questKeys.zoneOrSort] = zoneIDs.MOONGLADE,
            [questKeys.requiredSourceItems] = {18501},
        },
        [5542] = { -- Demon Dogs
            [questKeys.startedBy] = {{1855, 12126}},
        },
        [5543] = { -- Blood Tinged Skies
            [questKeys.startedBy] = {{1855, 12126}},
        },
        [5544] = { -- Carrion Grubbage
            [questKeys.startedBy] = {{1855, 12126}},
        },
        [5561] = { -- Kodo Roundup
            [questKeys.objectives] = {nil, nil, nil, nil, {{{4700, 4701, 4702}, 4700, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.DESOLACE] = {{60.58, 62}}}, Questie.ICON_TYPE_EVENT, l10n("Lure the Kodos to Smeed Scrabblescrew.")}},
        },
        [5601] = { -- Sister Pamela
            [questKeys.breadcrumbForQuestId] = 5149,
        },
        [5621] = { -- Garments of the Moon
            [questKeys.objectives] = {{{12429, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5622},
        },
        [5622] = { -- In Favor of Elune
            [questKeys.breadcrumbForQuestId] = 5621,
        },
        [5623] = { -- In Favor of the Light
            [questKeys.breadcrumbForQuestId] = 5624,
        },
        [5624] = { -- Garments of the Light
            [questKeys.objectives] = {{{12423, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5623},
        },
        [5625] = { -- Garments of the Light
            [questKeys.objectives] = {{{12427, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5626},
        },
        [5626] = { -- In Favor of the Light
            [questKeys.breadcrumbForQuestId] = 5625,
        },
        [5627] = { -- Stars of Elune (Darnassus)
            [questKeys.exclusiveTo] = {5628, 5629, 5630, 5631, 5632, 5633},
        },
        [5628] = { -- Returning Home (Elwynn Forest)
            [questKeys.exclusiveTo] = {5627, 5629, 5630, 5631, 5632, 5633},
            [questKeys.nextQuestInChain] = 0,
        },
        [5629] = { -- Returning Home (Teldrassil)
            [questKeys.exclusiveTo] = {5627, 5628, 5630, 5631, 5632, 5633},
            [questKeys.nextQuestInChain] = 0,
        },
        [5630] = { -- Returning Home (Dun Morogh)
            [questKeys.exclusiveTo] = {5627, 5628, 5629, 5631, 5632, 5633},
            [questKeys.nextQuestInChain] = 0,
        },
        [5631] = { -- Returning Home (Stormwind City)
            [questKeys.startedBy] = {{376}},
            [questKeys.exclusiveTo] = {5627, 5628, 5629, 5630, 5632, 5633},
            [questKeys.nextQuestInChain] = 0,
        },
        [5632] = { -- Returning Home (Stormwind City)
            [questKeys.exclusiveTo] = {5627, 5628, 5629, 5630, 5631, 5633},
            [questKeys.nextQuestInChain] = 0,
        },
        [5633] = { -- Returning Home (Ironforge)
            [questKeys.startedBy] = {{11406}},
            [questKeys.exclusiveTo] = {5627, 5628, 5629, 5630, 5631, 5632},
            [questKeys.nextQuestInChain] = 0,
        },
        [5634] = { -- Desperate Prayer (Stormwind City)
            [questKeys.startedBy] = {{376}},
            [questKeys.objectivesText] = {},
            [questKeys.exclusiveTo] = {5635, 5636, 5637, 5638, 5639, 5640},
        },
        [5635] = { -- Desperate Prayer (Elwynn Forest)
            [questKeys.startedBy] = {{377}},
            [questKeys.exclusiveTo] = {5634, 5636, 5637, 5638, 5639, 5640},
        },
        [5636] = { -- Desperate Prayer (Teldrassil)
            [questKeys.exclusiveTo] = {5634, 5635, 5637, 5638, 5639, 5640},
        },
        [5637] = { -- Desperate Prayer (Dun Morogh)
            [questKeys.startedBy] = {{1226}},
            [questKeys.exclusiveTo] = {5634, 5635, 5636, 5638, 5639, 5640},
        },
        [5638] = { -- Desperate Prayer (Stormwind City)
            [questKeys.exclusiveTo] = {5634, 5635, 5636, 5637, 5639, 5640},
        },
        [5639] = { -- Desperate Prayer (Ironforge)
            [questKeys.exclusiveTo] = {5634, 5635, 5636, 5637, 5638, 5640},
        },
        [5640] = { -- Desperate Prayer (Darnassus)
            [questKeys.name] = "Desperate Prayer",
            [questKeys.startedBy] = {{11401}},
            [questKeys.finishedBy] = {{376}},
            [questKeys.requiredLevel] = 10,
            [questKeys.questLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.HUMAN + raceIDs.DWARF,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectivesText] = {"Speak to High Priestess Laurena in Stormwind."},
            [questKeys.exclusiveTo] = {5634, 5635, 5636, 5637, 5638, 5639},
            [questKeys.zoneOrSort] = sortKeys.PRIEST,
        },
        [5641] = { -- A Lack of Fear (Ironforge)
            [questKeys.startedBy] = {{11406}},
            [questKeys.objectivesText] = {},
        },
        [5643] = { -- Shadowguard (Undercity)
            [questKeys.startedBy] = {{4606}},
        },
        [5644] = { -- Devouring Plague (Thunder Bluff)
            [questKeys.startedBy] = {{3044}},
        },
        [5645] = { -- A Lack of Fear (Stormwind City)
            [questKeys.startedBy] = {{376}},
        },
        [5646] = { -- Devouring Plague (Orgrimmar)
            [questKeys.startedBy] = {{6018}},
        },
        [5647] = { -- A Lack of Fear (Darnassus)
            [questKeys.startedBy] = {{11401}}, -- #2424
        },
        [5648] = { -- Garments of Spirituality
            [questKeys.objectives] = {{{12430, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5649},
        },
        [5649] = { -- In Favor of Spirituality
            [questKeys.breadcrumbForQuestId] = 5648,
        },
        [5650] = { -- Garments of Darkness
            [questKeys.objectives] = {{{12428, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5651},
        },
        [5651] = { -- In Favor of Darkness
            [questKeys.breadcrumbForQuestId] = 5650,
        },
        [5652] = { -- Hex of Weakness (Orgrimmar)
            [questKeys.objectivesText] = {},
        },
        [5654] = { -- Hex of Weakness (Durotar)
            [questKeys.startedBy] = {{3706}},
        },
        [5655] = { -- Hex of Weakness (Mulgore)
            [questKeys.startedBy] = {{11407}},
        },
        [5656] = { -- Hex of Weakness (Thunder Bluff)
            [questKeys.startedBy] = {{3044}},
        },
        [5657] = { -- Hex of Weakness (Undercity)
            [questKeys.startedBy] = {{4606}},
        },
        [5658] = { -- Touch of Weakness (Undercity)
            [questKeys.startedBy] = {{4606}},
            [questKeys.objectivesText] = {},
        },
        [5661] = { -- Touch of Weakness (Mulgore)
            [questKeys.startedBy] = {{11407}},
        },
        [5663] = { -- Touch of Weakness (Thunder Bluff)
            [questKeys.startedBy] = {{3044}},
        },
        [5672] = { -- Elune's Grace (Darnassus)
            [questKeys.startedBy] = {{11401}},
            [questKeys.objectivesText] = {},
        },
        [5674] = { -- Elune's Grace (Stormwind City)
            [questKeys.startedBy] = {{11397}},
        },
        [5676] = { -- Arcane Feedback (Stormwind City)
            [questKeys.startedBy] = {{376}},
            [questKeys.exclusiveTo] = {5677, 5678},
            [questKeys.objectivesText] = {},
        },
        [5677] = { -- Arcane Feedback (Ironforge)
            [questKeys.exclusiveTo] = {5676, 5678},
        },
        [5678] = { -- Arcane Feedback (Darnassus)
            [questKeys.name] = "Arcane Feedback",
            [questKeys.startedBy] = {{11401}},
            [questKeys.finishedBy] = {{376}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectivesText] = {"Speak to High Priestess Laurena in Stormwind."},
            [questKeys.exclusiveTo] = {5676, 5677},
            [questKeys.zoneOrSort] = sortKeys.PRIEST,
        },
        [5679] = { -- Devouring Plague (Undercity)
            [questKeys.startedBy] = {{4606}},
            [questKeys.objectivesText] = {},
        },
        [5680] = { -- Shadowguard (Orgrimmar)
            [questKeys.startedBy] = {{6018}},
            [questKeys.objectivesText] = {},
        },
        [5713] = { -- One Shot. One Kill.
            [questKeys.triggerEnd] = {"Protect Aynasha", {[zoneIDs.DARKSHORE] = {{45.87, 90.42}}}},
        },
        [5721] = { -- The Battle of Darrowshire
            [questKeys.extraObjectives] = {{{[zoneIDs.EASTERN_PLAGUELANDS] = {{38.8, 91.2}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Relic Bundle in the Town Square."),}},
            [questKeys.objectives] = {{{10936, nil, Questie.ICON_TYPE_TALK}}},
        },
        [5727] = { -- Hidden Enemies
            [questKeys.objectives] = {{{3216, nil, Questie.ICON_TYPE_TALK}}},
        },
        [5742] = { -- Redemption
            [questKeys.objectives] = {{{1855, nil, Questie.ICON_TYPE_TALK}}},
        },
        [5781] = { -- Of Forgotten Memories
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Search the false grave for the Taelan's Hammer."), 0, {{"object", 177240}}}},
        },
        [5821] = { -- Bodyguard for Hire
            [questKeys.triggerEnd] = {"Escort Gizelton Caravan past Kolkar Centaur Village", {[zoneIDs.DESOLACE] = {{67.17, 56.62}}}},
        },
        [5862] = { -- Scarlet Subterfuge
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ask for the illusion"), 0, {{"monster", 11872}}}},
            [questKeys.nextQuestInChain] = 5944,
        },
        -- Alliance
        [5882] = { -- Salve via Hunting
            [questKeys.startedBy] = {{9528}},
            [questKeys.finishedBy] = {{9528}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.nextQuestInChain] = 4103,
        },
        [5883] = { -- Salve via Mining
            [questKeys.startedBy] = {{9528}},
            [questKeys.finishedBy] = {{9528}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.requiredSkill] = {profKeys.MINING, 200},
            [questKeys.nextQuestInChain] = 4104,
        },
        [5884] = { -- Salve via Gathering
            [questKeys.startedBy] = {{9528}},
            [questKeys.finishedBy] = {{9528}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.requiredSkill] = {profKeys.HERBALISM, 200},
            [questKeys.nextQuestInChain] = 4105,
        },
        [5885] = { -- Salve via Skinning
            [questKeys.startedBy] = {{9528}},
            [questKeys.finishedBy] = {{9528}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.requiredSkill] = {profKeys.SKINNING, 200},
            [questKeys.nextQuestInChain] = 4106,
        },
        [5886] = { -- Salve via Disenchanting
            [questKeys.startedBy] = {{9528}},
            [questKeys.finishedBy] = {{9528}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.requiredSkill] = {profKeys.ENCHANTING, 200},
            [questKeys.nextQuestInChain] = 4107,
        },
        -- Horde
        [5887] = { -- Salve via Hunting
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.nextQuestInChain] = 4108,
        },
        [5888] = { -- Salve via Mining
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredSkill] = {profKeys.MINING, 200},
            [questKeys.nextQuestInChain] = 4109,
        },
        [5889] = { -- Salve via Gathering
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredSkill] = {profKeys.HERBALISM, 200},
            [questKeys.nextQuestInChain] = 4110,
        },
        [5890] = { -- Salve via Skinning
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredSkill] = {profKeys.SKINNING, 200},
            [questKeys.nextQuestInChain] = 4111,
        },
        [5891] = { -- Salve via Disenchanting
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredSkill] = {profKeys.ENCHANTING, 200},
            [questKeys.nextQuestInChain] = 4112,
        },
        [5892] = { -- Irondeep Supplies
            [questKeys.questLevel] = 55,
        },
        [5893] = { -- Coldtooth Supplies
            [questKeys.questLevel] = 55,
        },
        [5904] = { -- A Plague Upon Thee
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Place the Termite Barrel"), 0, {{"object", 177490}}}},
        },
        [5921] = { -- Moonglade
            [questKeys.breadcrumbs] = {5923, 5924, 5925},
        },
        [5922] = { -- Moonglade
            [questKeys.breadcrumbs] = {5926, 5927, 5928},
        },
        [5923] = { -- Heeding the Call
            [questKeys.startedBy] = {{4218}},
            [questKeys.breadcrumbForQuestId] = 5921,
        },
        [5924] = { -- Heeding the Call
            [questKeys.startedBy] = {{5505}},
            [questKeys.breadcrumbForQuestId] = 5921,
        },
        [5925] = { -- Heeding the Call
            [questKeys.startedBy] = {{3602}},
            [questKeys.breadcrumbForQuestId] = 5921,
        },
        [5926] = { -- Heeding the Call
            [questKeys.startedBy] = {{6746}},
            [questKeys.breadcrumbForQuestId] = 5922,
        },
        [5927] = { -- Heeding the Call
            [questKeys.startedBy] = {{6929}},
            [questKeys.breadcrumbForQuestId] = 5922,
        },
        [5928] = { -- Heeding the Call
            [questKeys.startedBy] = {{3064}},
            [questKeys.breadcrumbForQuestId] = 5922,
        },
        [5929] = { -- Great Bear Spirit
            [questKeys.objectives] = {{{11956, nil, Questie.ICON_TYPE_TALK}}},
        },
        [5930] = { -- Great Bear Spirit
            [questKeys.objectives] = {{{11956, nil, Questie.ICON_TYPE_TALK}}},
        },
        [5931] = { -- Back to Darnassus
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Silva Fil'naveth to fly back to Darnassus"), 0, {{"monster", 11800}}}},
        },
        [5932] = { -- Back to Thunder Bluff
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Bunthen Plainswind to fly back to Thunder Bluff"), 0, {{"monster", 11798}}}},
        },
        [5943] = { -- Gizelton Caravan
            [questKeys.triggerEnd] = {"Escort Gizelton Caravan past Mannoroc Coven", {[zoneIDs.DESOLACE] = {{55.69, 67.79}}}},
        },
        [5944] = { -- In Dreams
            [questKeys.triggerEnd] = {"Redemption?", {[zoneIDs.WESTERN_PLAGUELANDS] = {{53.86, 24.32}}}},
        },
        [6001] = { -- Body and Heart
            [questKeys.objectives] = {{{12144, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Cenarion Moondust"), 0, {{"object", 177525}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Lunaclaw"), 0, {{"monster", 12138}}},
            },
        },
        [6002] = { -- Body and Heart
            [questKeys.objectives] = {{{12144, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Cenarion Lunardust"), 0, {{"object", 177525}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Lunaclaw"), 0, {{"monster", 12138}}},
            },
        },
        [6027] = { -- Book of the Ancients
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Lord Kragaru"), 0, {{"object", 177673}}}},
        },
        [6032] = { -- Sacred Cloth
            [questKeys.requiredSkill] = {profKeys.TAILORING, 280},
        },
        [6041] = { -- When Smokey Sings, I Get Violent
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Plant the bomb!"), 0, {{"object", 177668}}}},
        },
        [6061] = { -- Taming the Beast
            [questKeys.objectives] = {{{2956, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.breadcrumbs] = {6065, 6066, 6067},
        },
        [6062] = { -- Taming the Beast
            [questKeys.objectives] = {{{3099, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.breadcrumbs] = {6068, 6069, 6070},
        },
        [6063] = { -- Taming the Beast
            [questKeys.objectives] = {{{1998, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.breadcrumbs] = {6071, 6072, 6073, 6721, 6722},
        },
        [6064] = { -- Taming the Beast
            [questKeys.objectives] = {{{1126, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.breadcrumbs] = {6074, 6075, 6076},
        },
        [6065] = { -- The Hunter's Path
            [questKeys.exclusiveTo] = {6066, 6067},
            [questKeys.breadcrumbForQuestId] = 6061,
        },
        [6066] = { -- The Hunter's Path
            [questKeys.startedBy] = {{3407}},
            [questKeys.exclusiveTo] = {6065, 6067},
            [questKeys.breadcrumbForQuestId] = 6061,
        },
        [6067] = { -- The Hunter's Path
            [questKeys.exclusiveTo] = {6065, 6066},
            [questKeys.breadcrumbForQuestId] = 6061,
        },
        [6068] = { -- The Hunter's Path
            [questKeys.startedBy] = {{3407}}, -- #2167
            [questKeys.exclusiveTo] = {6069, 6070}, -- #1795
            [questKeys.breadcrumbForQuestId] = 6062,
        },
        [6069] = { -- The Hunter's Path
            [questKeys.startedBy] = {{11814}}, -- #1523
            [questKeys.exclusiveTo] = {6068, 6070}, -- #1795
            [questKeys.breadcrumbForQuestId] = 6062,
        },
        [6070] = { -- The Hunter's Path
            [questKeys.startedBy] = {{3038}}, -- "The Hunter's Path" now started by "Kary Thunderhorn" in Thunder Bluff
            [questKeys.exclusiveTo] = {6068, 6069}, -- #1795
            [questKeys.breadcrumbForQuestId] = 6062,
        },
        [6071] = { -- The Hunter's Path
            [questKeys.exclusiveTo] = {6072, 6073, 6721, 6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6072] = { -- The Hunter's Path
            [questKeys.exclusiveTo] = {6071, 6073, 6721, 6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6073] = { -- The Hunter's Path
            [questKeys.startedBy] = {{5515}},
            [questKeys.exclusiveTo] = {6071, 6072, 6721, 6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6074] = { -- The Hunter's Path
            [questKeys.startedBy] = {{5116}},
            [questKeys.exclusiveTo] = {6075, 6076},
            [questKeys.breadcrumbForQuestId] = 6064,
        },
        [6075] = { -- The Hunter's Path
            [questKeys.startedBy] = {{11807}},
            [questKeys.exclusiveTo] = {6074, 6076},
            [questKeys.breadcrumbForQuestId] = 6064,
        },
        [6076] = { -- The Hunter's Path
            [questKeys.exclusiveTo] = {6074, 6075},
            [questKeys.breadcrumbForQuestId] = 6064,
        },
        [6082] = { -- Taming the Beast
            [questKeys.objectives] = {{{3126, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6083] = { -- Taming the Beast
            [questKeys.objectives] = {{{3107, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6084] = { -- Taming the Beast
            [questKeys.objectives] = {{{1201, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6085] = { -- Taming the Beast
            [questKeys.objectives] = {{{1196, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6087] = { -- Taming the Beast
            [questKeys.objectives] = {{{2959, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6088] = { -- Taming the Beast
            [questKeys.objectives] = {{{2970, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6101] = { -- Taming the Beast
            [questKeys.objectives] = {{{2043, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6102] = { -- Taming the Beast
            [questKeys.objectives] = {{{1996, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [6124] = { -- Curing the Sick
            [questKeys.objectives] = {{{12298, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [6129] = { -- Curing the Sick
            [questKeys.objectives] = {{{12296, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [6132] = { -- Get Me Out of Here!
            [questKeys.triggerEnd] = {"Melizza Brimbuzzle escorted to safety", {[zoneIDs.DESOLACE] = {{40.15, 61.58}}}},
        },
        [6134] = { -- Ghost-o-plasm Round Up
            [questKeys.extraObjectives] = {{{[zoneIDs.DESOLACE] = {{63.71, 91.9}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Crate of Ghost Magnets"),}},
        },
        [6135] = { -- Duskwing, Oh How I Hate Thee...
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {6022, 6042, 6133}, -- #1572
        },
        [6136] = { -- The Corpulent One
            [questKeys.preQuestGroup] = {6022, 6042, 6133}, -- #1572
        },
        [6141] = { -- Brother Anton
            [questKeys.breadcrumbForQuestId] = 261, -- #1744
        },
        [6144] = { -- The Call to Command
            [questKeys.preQuestGroup] = {6135, 6136}, -- #1950
        },
        [6163] = { -- Ramstein
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {6135, 6136}, -- #1950
        },
        [6185] = { -- The Eastern Plagues
            [questKeys.objectives] = {nil, nil, {{16003}, {16001}, {16002}}, nil, {{{11878}, 11878, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [6187] = { -- Order Must Be Restored
            [questKeys.objectivesText] = {"Assemble an army and travel to the Eastern Plaguelands. Launch a full assault on Nathanos Blightcaller and any Horde filth that may attempt to protect him.", "", "Keep your wits about you, <Name>. The Horde will defend the ranger lord with their very lives."},
        },
        [6341] = { -- The Bounty of Teldrassil
            [questKeys.breadcrumbs] = {6344},
            [questKeys.preQuestSingle] = {},
        },
        [6344] = { -- Nessa Shadowsong
            [questKeys.breadcrumbForQuestId] = 6341,
        },
        [6382] = { -- The Ashenvale Hunt
            [questKeys.preQuestSingle] = {882},
            [questKeys.availableUntilCompleted] = 6383,
        },
        [6383] = { -- The Ashenvale Hunt
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {235, 742},
        },
        [6402] = { -- Stormwind Rendezvous
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Squire Rowe"), 0, {{"monster", 17804}}}},
        },
        [6403] = { -- The Great Masquerade
            [questKeys.triggerEnd] = {"Reginald's March", {[zoneIDs.STORMWIND_CITY] = {{77.57, 18.59}}}},
        },
        [6482] = { -- Freedom to Ruul
            [questKeys.triggerEnd] = {"Escort Ruul from the Thistlefurs.", {[zoneIDs.ASHENVALE] = {{38.53, 37.32}}}},
        },
        [6504] = { -- The Lost Pages
            [questKeys.requiredSourceItems] = {16645, 16646, 16647, 16648, 16649, 16650, 16651, 16652, 16653, 16654, 16655, 16656},
        },
        [6523] = { -- Protect Kaya
            [questKeys.triggerEnd] = {"Kaya Escorted to Camp Aparaje", {[zoneIDs.STONETALON_MOUNTAINS] = {{77.1, 90.85}}}},
        },
        [6541] = { -- Report to Kadrak
            [questKeys.breadcrumbForQuestId] = 6543,
            [questKeys.exclusiveTo] = {},
            [questKeys.disabledByQuest] = 6542,
        },
        [6542] = { -- Report to Kadrak
            [questKeys.breadcrumbForQuestId] = 6543,
            [questKeys.exclusiveTo] = {},
            [questKeys.disabledByQuest] = 6541,
        },
        [6543] = { -- The Warsong Reports
            [questKeys.breadcrumbs] = {6541, 6542},
            [questKeys.requiredSourceItems] = {16746},
        },
        [6544] = { -- Torek's Assault
            [questKeys.triggerEnd] = {"Take Silverwing Outpost.", {[zoneIDs.ASHENVALE] = {{64.65, 75.35}}}},
        },
        [6562] = { -- Trouble in the Deeps
            [questKeys.breadcrumbForQuestId] = 6563, -- #1826
        },
        [6563] = { -- The Essence of Aku'Mai
            [questKeys.preQuestSingle] = {}, -- #1826
            [questKeys.breadcrumbs] = {6562},
        },
        [6564] = { -- Allegiance to the Old Gods
            [questKeys.preQuestSingle] = {6562},
        },
        [6566] = { -- What the Wind Carries
            [questKeys.triggerEnd] = {"Thrall's Tale", {[zoneIDs.ORGRIMMAR] = {{31.78, 37.81}}}},
        },
        [6603] = { -- Trouble in Winterspring!
            [questKeys.breadcrumbForQuestId] = 5082, -- #1824
        },
        [6604] = { -- Enraged Wildkin
            [questKeys.breadcrumbForQuestId] = 4861,
        },
        [6605] = { -- A Strange One
            [questKeys.breadcrumbForQuestId] = 4505, -- #1859 -- #1856
        },
        [6607] = { -- Nat Pagle, Angler Extreme
            [questKeys.breadcrumbs] = {6608, 6609}, -- #1154 -- #1186
        },
        [6608] = { -- You Too Good.
            [questKeys.breadcrumbForQuestId] = 6607, -- #1186
            [questKeys.nextQuestInChain] = 6607,
        },
        [6609] = { -- I Got Nothin' Left!
            [questKeys.breadcrumbForQuestId] = 6607, -- #1154
            [questKeys.nextQuestInChain] = 6607,
        },
        [6610] = { -- Clamlette Surprise
            [questKeys.breadcrumbs] = {6611, 6612}, -- #2070
        },
        [6611] = { -- To Gadgetzan You Go!
            [questKeys.breadcrumbForQuestId] = 6610, -- #2070
            [questKeys.nextQuestInChain] = 6610,
        },
        [6612] = { -- I Know A Guy...
            [questKeys.breadcrumbForQuestId] = 6610, -- #2070
            [questKeys.nextQuestInChain] = 6610,
        },
        [6622] = { -- Triage
            [questKeys.triggerEnd] = {"15 Patients Saved!", {[zoneIDs.DUSTWALLOW_MARSH] = {{67.79, 49.06}}}},
            [questKeys.breadcrumbs] = {6623},
        },
        [6623] = { -- Horde Trauma
            [questKeys.breadcrumbForQuestId] = 6622,
        },
        [6624] = { -- Triage
            [questKeys.triggerEnd] = {"15 Patients Saved!", {[zoneIDs.DUSTWALLOW_MARSH] = {{67.79, 49.06}}}},
            [questKeys.breadcrumbs] = {6625}, -- #1723
        },
        [6625] = { -- Alliance Trauma
            [questKeys.breadcrumbForQuestId] = 6624, -- #1723
        },
        [6627] = { -- Test of Lore
            [questKeys.triggerEnd] = {"Answer Braug Dimspirit's question correctly", {[zoneIDs.STONETALON_MOUNTAINS] = {{78.75, 45.63}}}},
        },
        [6628] = { -- Test of Lore
            [questKeys.triggerEnd] = {"Answer Parqual Fintallas' question correctly", {[zoneIDs.UNDERCITY] = {{57.72, 65.22}}}},
        },
        [6641] = { -- Vorsha the Lasher
            [questKeys.triggerEnd] = {"Defeat Vorsha the Lasher", {[zoneIDs.ASHENVALE] = {{9.59, 27.58}}}},
        },
        [6661] = { -- Deeprun Rat Roundup
            [questKeys.objectives] = {{{13016, nil, Questie.ICON_TYPE_INTERACT}}},
            [questKeys.nextQuestInChain] = 6662,
        },
        [6721] = { -- The Hunter's Path
            [questKeys.startedBy] = {{5116}},
            [questKeys.exclusiveTo] = {6071, 6072, 6073, 6722},
            [questKeys.breadcrumbForQuestId] = 6063,
            [questKeys.zoneOrSort] = zoneIDs.IRONFORGE,
        },
        [6722] = { -- The Hunter's Path
            [questKeys.startedBy] = {{1231}},
            [questKeys.exclusiveTo] = {6071, 6072, 6073, 6721},
            [questKeys.breadcrumbForQuestId] = 6063,
            [questKeys.zoneOrSort] = zoneIDs.KHARANOS,
        },
        [6761] = { -- The New Frontier
            [questKeys.preQuestSingle] = {1015, 1019, 1047},
        },
        [6824] = { -- Hands of the Enemy
            [questKeys.nextQuestInChain] = 7486,
        },
        [6845] = { -- Uncovering Past Secrets
            [questKeys.nextQuestInChain] = 1185,
        },
        [6846] = { -- Begin the Attack!
            [questKeys.requiredLevel] = 51,
        },
        [6861] = { -- Zinfizzlex's Portable Shredder Unit
            [questKeys.objectivesText] = {},
        },
        [6862] = { -- Zinfizzlex's Portable Shredder Unit
            [questKeys.objectivesText] = {},
        },
        [6922] = { -- Baron Aquanis
            [questKeys.zoneOrSort] = 719,
        },
        [6961] = { -- Great-father Winter is Here!
            [questKeys.exclusiveTo] = {7021, 7024},
            [questKeys.breadcrumbForQuestId] = 6962,
            [questKeys.nextQuestInChain] = 6962,
        },
        [6962] = { -- Treats for Great-father Winter
            [questKeys.objectivesText] = {"Bring 5 Gingerbread Cookies and an Ice Cold Milk to Greatfather Winter in Orgrimmar."},
            [questKeys.breadcrumbs] = {6961, 7021, 7024},
        },
        [6981] = { -- The Glowing Shard
            [questKeys.objectives] = {{{3442, nil, Questie.ICON_TYPE_TALK}}},
        },
        [6982] = { -- Coldtooth Supplies
            [questKeys.questLevel] = 55,
        },
        [6984] = { -- A Smokywood Pastures' Thank You!
            [questKeys.name] = "A Smokywood Pastures' Thank You!",
        },
        [6985] = { -- Irondeep Supplies
            [questKeys.questLevel] = 55,
        },
        [7001] = { -- Empty Stables
            [questKeys.objectives] = {{{14282, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [7002] = { -- Ram Hide Harnesses
            [questKeys.objectivesText] = {},
        },
        [7021] = { -- Great-father Winter is Here!
            [questKeys.finishedBy] = {{13445}},
            [questKeys.exclusiveTo] = {6961, 7024},
            [questKeys.breadcrumbForQuestId] = 6962,
            [questKeys.nextQuestInChain] = 6962,
        },
        [7022] = { -- Greatfather Winter is Here!
            [questKeys.startedBy] = {{13433}},
        },
        [7023] = { -- Greatfather Winter is Here!
            [questKeys.startedBy] = {{13435}},
        },
        [7024] = { -- Great-father Winter is Here!
            [questKeys.finishedBy] = {{13445}},
            [questKeys.exclusiveTo] = {6961, 7021},
            [questKeys.breadcrumbForQuestId] = 6962,
            [questKeys.nextQuestInChain] = 6962,
        },
        [7026] = { -- Ram Riding Harnesses
            [questKeys.objectivesText] = {},
        },
        [7027] = { -- Empty Stables
            [questKeys.objectives] = {{{10990, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [7042] = { -- Stolen Winter Veil Treats
            [questKeys.finishedBy] = {{13636}},
        },
        [7043] = { -- You're a Mean One...
            [questKeys.objectivesText] = {"Locate and return the Stolen Treats to Wulmort Jinglepocket in Ironforge. It was last thought to be in the possession of the Abominable Greench, found somewhere in the snowy regions of the Alterac Mountains."},
        },
        [7044] = { -- Legends of Maraudon
            [questKeys.nextQuestInChain] = 7046,
        },
        [7045] = { -- A Smokywood Pastures' Thank You!
            [questKeys.name] = "A Smokywood Pastures' Thank You!",
        },
        [7046] = { -- The Scepter of Celebras
            [questKeys.objectives] = {nil, {{178965}}},
        },
        [7062] = { -- The Reason for the Season
            [questKeys.startedBy] = {{1365}},
        },
        [7067] = { -- The Pariah's Instructions
            [questKeys.requiredSourceItems] = {17757, 17761, 17762, 17763, 17764, 17765},
        },
        [7068] = { -- Shadowshard Fragments
            [questKeys.requiredLevel] = 39,
        },
        [7070] = { -- Shadowshard Fragments
            [questKeys.requiredLevel] = 39,
        },
        [7081] = { -- Alterac Valley Graveyards
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [7082] = { -- The Graveyards of Alterac
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [7121] = { -- The Quartermaster
            [questKeys.exclusiveTo] = {5892, 6892},
        },
        [7123] = { -- Speak with our Quartermaster
            [questKeys.exclusiveTo] = {5893, 6985},
        },
        [7141] = { -- The Battle of Alterac
            [questKeys.triggerEnd] = {"Defeat Drek'thar.", {[zoneIDs.ALTERAC_VALLEY] = {{47.22, 86.95}}}},
        },
        [7142] = { -- The Battle for Alterac
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.triggerEnd] = {"Defeat Vanndar Stormpike.", {[zoneIDs.ALTERAC_VALLEY] = {{42.29, 12.85}}}},
        },
        [7161] = { -- Proving Grounds
            [questKeys.breadcrumbs] = {7241},
        },
        [7162] = { -- Proving Grounds
            [questKeys.breadcrumbs] = {7261},
        },
        [7163] = { -- Rise and Be Recognized
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7164] = { -- Honored Amongst the Clan
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7166] = { -- Legendary Heroes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7167] = { -- The Eye of Command
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7168] = { -- Rise and Be Recognized
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7169] = { -- Honored Amongst the Guard
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7170] = { -- Earned Reverence
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7171] = { -- Legendary Heroes
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7172] = { -- The Eye of Command
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7201] = { -- The Last Element
            [questKeys.preQuestSingle] = {3906},
        },
        [7241] = { -- In Defense of Frostwolf
            [questKeys.breadcrumbForQuestId] = 7161,
            [questKeys.nextQuestInChain] = 7161,
        },
        [7261] = { -- The Sovereign Imperative
            [questKeys.breadcrumbForQuestId] = 7162,
            [questKeys.nextQuestInChain] = 7162,
        },
        [7281] = { -- Brotherly Love
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7282] = { -- Brotherly Love
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7385] = { -- A Gallon of Blood
            [questKeys.objectivesText] = {},
        },
        [7386] = { -- Crystal Cluster
            [questKeys.objectivesText] = {},
        },
        [7426] = { -- One Man's Love
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7427] = { -- Wanted: MORE DWARVES!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7428] = { -- Wanted: MORE ORCS!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7463] = { -- Arcane Refreshment
            [questKeys.zoneOrSort] = sortKeys.MAGE,
        },
        [7481] = { -- Elven Legends
            [questKeys.objectives] = {nil, {{179544}}},
            [questKeys.objectivesText] = {"Search Dire Maul for Telmius Dreamseeker. Report back to Sage Korolusk at Camp Mojache with whatever information that you may find."},
        },
        [7482] = { -- Elven Legends
            [questKeys.objectives] = {nil, {{179544}}},
            [questKeys.objectivesText] = {"Search Dire Maul for Telmius Dreamseeker. Report back to Scholar Runethorn at Feathermoon with whatever information that you may find."},
        },
        [7483] = { -- Libram of Rapidity
            [questKeys.preQuestSingle] = {7481, 7482},
            [questKeys.reputationReward] = {{factionIDs.SHEN_DRALAR, 200}},
        },
        [7484] = { -- Libram of Focus
            [questKeys.preQuestSingle] = {7481, 7482},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7485] = { -- Libram of Protection
            [questKeys.preQuestSingle] = {7481, 7482},
        },
        [7488] = { -- Lethtendris's Web
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {7494}, -- #1740
        },
        [7489] = { -- Lethtendris's Web
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {7492}, -- #1514
        },
        [7490] = { -- Victory for the Horde
            [questKeys.preQuestSingle] = {6602},
        },
        [7492] = { -- Camp Mojache
            [questKeys.startedBy] = {{10879, 10880, 10881}}, -- #1350
            [questKeys.breadcrumbForQuestId] = 7489, -- #1514
        },
        [7494] = { -- Feathermoon Stronghold
            [questKeys.startedBy] = {{2198, 10877, 10878}}, -- #2489
            [questKeys.breadcrumbForQuestId] = 7488, -- #1740
        },
        [7495] = { -- Victory for the Alliance
            [questKeys.requiredLevel] = 60,
            [questKeys.preQuestSingle] = {6502},
        },
        [7507] = { -- Nostro's Compendium
            [questKeys.name] = "Nostro's Compendium",
            [questKeys.objectivesText] = {"Return Nostro's Compendium of Dragon Slaying to the Athenaeum."},
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
            [questKeys.nextQuestInChain] = 7508,
        },
        [7508] = { -- The Forging of Quel'Serrar
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [7509] = { -- The Forging of Quel'Serrar
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
            [questKeys.requiredSourceItems] = {18488},
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [7541] = { -- Service to the Horde
            [questKeys.questLevel] = 40, -- #1320
        },
        [7562] = { -- Mor'zul Bloodbringer
            [questKeys.breadcrumbForQuestId] = 7563,
        },
        [7563] = { -- Rage of Blood
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {7562},
        },
        [7583] = { -- Suppression
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Imprison the Doomguard Commander"), 0, {{"monster", 12396}}}},
        },
        [7604] = { -- A Binding Contract
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [7622] = { -- The Balance of Light and Shadow
            [questKeys.triggerEnd] = {"The Balance of Light and Shadow", {[zoneIDs.EASTERN_PLAGUELANDS] = {{21.19, 17.79}}}}, -- #2332
        },
        [7629] = { -- Imp Delivery
            [questKeys.preQuestSingle] = {7625},
            [questKeys.preQuestGroup] = {},
            [questKeys.objectives] = {{{14500, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [7631] = { -- Dreadsteed of Xoroth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7629, 7630},
            [questKeys.requiredSourceItems] = {18663, 18629, 18670},
        },
        [7632] = { -- The Ancient Leaf
            [questKeys.startedBy] = {{12018}, {179703}, {18703}},
            [questKeys.objectivesText] = {"Find the owner of the Ancient Petrified Leaf. Good luck, <Name>; It's a big world."},
        },
        [7633] = { -- An Introduction
            [questKeys.preQuestSingle] = {7632},
        },
        [7640] = { -- Exorcising Terrordale
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Exorcise the spirits"), 0, {{"object", 179747}}}},
        },
        [7651] = { -- Enchanted Thorium Platemail: Volume III
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [7668] = { -- The Darkreaver Menace
            [questKeys.name] = "The Darkreaver Menace", -- #1344
            [questKeys.startedBy] = {{13417}},
            [questKeys.finishedBy] = {{13417}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectivesText] = {"Bring Darkreaver's Head to Sagorne Creststrider in the Valley of Wisdom, Orgrimmar."},
            [questKeys.objectives] = {nil, nil, {{18880}}},
            [questKeys.sourceItemId] = 18746,
            [questKeys.zoneOrSort] = sortKeys.SHAMAN,
            [questKeys.exclusiveTo] = {8258}, -- 8258 after Phase 4
            [questKeys.preQuestSingle] = {7667},
        },
        [7669] = { -- Again Into the Great Ossuary
            [questKeys.name] = "Again Into the Great Ossuary", -- #1449
            [questKeys.startedBy] = {{13417}},
            [questKeys.finishedBy] = {{13417}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.zoneOrSort] = sortKeys.SHAMAN,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {7668, 8258},
        },
        [7670] = { -- Lord Grayson Shadowbreaker
            [questKeys.name] = "Lord Grayson Shadowbreaker", -- #1432
            [questKeys.startedBy] = {{5149}},
            [questKeys.finishedBy] = {{928}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Speak with Lord Grayson Shadowbreaker in Stormwind's Cathedral District."},
            [questKeys.nextQuestInChain] = 7637,
            [questKeys.exclusiveTo] = {7638},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
        },
        [7735] = { -- Pristine Yeti Hide A
            [questKeys.preQuestSingle] = {2821},
        },
        [7736] = { -- Restoring Fiery Flux Supplies via Kingsblood
            [questKeys.objectivesText] = {},
        },
        [7738] = { -- Perfect Yeti Hide H
            [questKeys.preQuestSingle] = {2822},
        },
        [7781] = { -- The Lord of Blackrock
            [questKeys.preQuestSingle] = {7761},
        },
        [7782] = { -- The Lord of Blackrock
            [questKeys.startedBy] = {{1748}},
        },
        [7783] = { -- The Lord of Blackrock
            [questKeys.preQuestSingle] = {7761},
        },
        [7784] = { -- The Lord of Blackrock
            [questKeys.startedBy] = {{4949}},
        },
        [7795] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7796,
        },
        [7800] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7801,
        },
        [7805] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7806,
        },
        [7810] = { -- Arena Master
            [questKeys.nextQuestInChain] = 7838,
        },
        [7811] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7812,
        },
        [7816] = { -- Gammerita, Mon!
            [questKeys.preQuestSingle] = {}, -- #2247
        },
        [7818] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7819,
        },
        [7823] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7825,
        },
        [7824] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7832,
        },
        [7836] = { -- A Donation of Runecloth
            [questKeys.nextQuestInChain] = 7837,
        },
        [7838] = { -- Arena Grandmaster
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1589
        },
        [7843] = { -- The Final Message to the Wildhammer
            [questKeys.triggerEnd] = {"Message to the Wildhammer Delivered", {[zoneIDs.THE_HINTERLANDS] = {{14.34, 48.07}}}},
        },
        [7863] = { -- Sentinel Basic Care Package
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7864] = { -- Sentinel Standard Care Package
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7865] = { -- Sentinel Advanced Care Package
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7866] = { -- Outrider Basic Care Package
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7867] = { -- Outrider Standard Care Package
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7868] = { -- Outrider Advanced Care Package
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7877] = { -- The Treasure of the Shen'dralar
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [7886] = { -- Talismans of Merit (#1435)
            [questKeys.startedBy] = {{14733}},
            [questKeys.finishedBy] = {{14733}},
        },
        [7887] = { -- Talismans of Merit (#1435)
            [questKeys.startedBy] = {{14733}},
            [questKeys.finishedBy] = {{14733}},
        },
        [7888] = { -- Talismans of Merit (#1435)
            [questKeys.startedBy] = {{14733}},
            [questKeys.finishedBy] = {{14733}},
        },
        [7905] = { -- The Darkmoon Faire
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7921] = { -- Talismans of Merit (#1435)
            [questKeys.startedBy] = {{14733}},
            [questKeys.finishedBy] = {{14733}},
        },
        [7926] = { -- The Darkmoon Faire
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7937] = { -- Your Fortune Awaits You...
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7938] = { -- Your Fortune Awaits You...
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7945] = { -- Your Fortune Awaits You...
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7946] = { -- Spawn of Jubjub
            [questKeys.questLevel] = 60,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8041] = { -- Strength of Mount Mugamba
            [questKeys.nextQuestInChain] = 8042,
        },
        [8042] = { -- Strength of Mount Mugamba
            [questKeys.nextQuestInChain] = 8043,
        },
        [8043] = { -- Strength of Mount Mugamba
            [questKeys.nextQuestInChain] = 8044,
        },
        [8044] = { -- The Rage of Mugamba
            [questKeys.name] = "The Rage of Mugamba",
        },
        [8045] = { -- The Heathen's Brand
            [questKeys.nextQuestInChain] = 8046,
        },
        [8046] = { -- The Heathen's Brand
            [questKeys.nextQuestInChain] = 8047,
        },
        [8047] = { -- The Heathen's Brand
            [questKeys.nextQuestInChain] = 8048,
        },
        [8049] = { -- The Eye of Zuldazar
            [questKeys.nextQuestInChain] = 8050,
        },
        [8050] = { -- The Eye of Zuldazar
            [questKeys.nextQuestInChain] = 8051,
        },
        [8051] = { -- The Eye of Zuldazar
            [questKeys.nextQuestInChain] = 8052,
        },
        [8053] = { -- Paragons of Power: The Freethinker's Armguards
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8054] = { -- Paragons of Power: The Freethinker's Belt
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8055] = { -- Paragons of Power: The Freethinker's Breastplate
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8056] = { -- Paragons of Power: The Augur's Bracers
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8057] = { -- Paragons of Power: The Haruspex's Bracers
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8058] = { -- Paragons of Power: The Vindicator's Armguards
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8059] = { -- Paragons of Power: The Demoniac's Wraps
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8060] = { -- Paragons of Power: The Illusionist's Wraps
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8061] = { -- Paragons of Power: The Confessor's Wraps
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8062] = { -- Paragons of Power: The Predator's Bracers
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8063] = { -- Paragons of Power: The Madcap's Bracers
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8064] = { -- Paragons of Power: The Haruspex's Belt
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8065] = { -- Paragons of Power: The Haruspex's Tunic
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8066] = { -- Paragons of Power: The Predator's Belt
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8067] = { -- Paragons of Power: The Predator's Mantle
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8068] = { -- Paragons of Power: The Illusionist's Mantle
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8069] = { -- Paragons of Power: The Illusionist's Robes
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8070] = { -- Paragons of Power: The Confessor's Bindings
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8071] = { -- Paragons of Power: The Confessor's Mantle
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8072] = { -- Paragons of Power: The Madcap's Mantle
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8073] = { -- Paragons of Power: The Madcap's Tunic
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8074] = { -- Paragons of Power: The Augur's Belt
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8075] = { -- Paragons of Power: The Augur's Hauberk
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8076] = { -- Paragons of Power: The Demoniac's Mantle
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8077] = { -- Paragons of Power: The Demoniac's Robes
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8078] = { -- Paragons of Power: The Vindicator's Belt
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8079] = { -- Paragons of Power: The Vindicator's Breastplate
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8101] = { -- The Pebble of Kajaro
            [questKeys.nextQuestInChain] = 8102,
        },
        [8102] = { -- The Pebble of Kajaro
            [questKeys.nextQuestInChain] = 8103,
        },
        [8103] = { -- The Pebble of Kajaro
            [questKeys.nextQuestInChain] = 8104,
        },
        [8105] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [8106] = { -- Kezan's Taint
            [questKeys.nextQuestInChain] = 8107,
        },
        [8107] = { -- Kezan's Taint
            [questKeys.nextQuestInChain] = 8108,
        },
        [8108] = { -- Kezan's Taint
            [questKeys.nextQuestInChain] = 8109,
        },
        [8110] = { -- Enchanted South Seas Kelp
            [questKeys.nextQuestInChain] = 8111,
        },
        [8111] = { -- Enchanted South Seas Kelp
            [questKeys.nextQuestInChain] = 8112,
        },
        [8112] = { -- Enchanted South Seas Kelp
            [questKeys.nextQuestInChain] = 8113,
        },
        [8114] = { -- Control Four Bases
            [questKeys.requiredMinRep] = {509, 3000},
            [questKeys.triggerEnd] = {"Control Four Bases.", {[zoneIDs.ARATHI_HIGHLANDS] = {{46.03, 45.3}}}},
        },
        [8115] = { -- Control Five Bases
            [questKeys.triggerEnd] = {"Take Five Bases.", {[zoneIDs.ARATHI_HIGHLANDS] = {{46.03, 45.3}}}},
            [questKeys.requiredMinRep] = {509, 42000},
        },
        [8116] = { -- Vision of Voodress
            [questKeys.nextQuestInChain] = 8117,
        },
        [8117] = { -- Vision of Voodress
            [questKeys.nextQuestInChain] = 8118,
        },
        [8118] = { -- Vision of Voodress
            [questKeys.nextQuestInChain] = 8119,
        },
        [8120] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [8121] = { -- Take Four Bases
            [questKeys.requiredMinRep] = {510, 3000},
            [questKeys.triggerEnd] = {"Hold Four Bases.", {
                [zoneIDs.THUNDER_BLUFF] = {{40.4, 51.57}},
                [zoneIDs.ARATHI_HIGHLANDS] = {{73.72, 29.52}},
                [zoneIDs.ORGRIMMAR] = {{50.1, 69.03}},
                [zoneIDs.SILVERPINE_FOREST] = {{39.68, 17.75}}
            },
            },
        },
        [8122] = { -- Take Five Bases
            [questKeys.triggerEnd] = {"Hold Five Bases.", {
                [zoneIDs.THUNDER_BLUFF] = {{40.4, 51.57}},
                [zoneIDs.ARATHI_HIGHLANDS] = {{73.72, 29.52}},
                [zoneIDs.ORGRIMMAR] = {{50.1, 69.03}},
                [zoneIDs.SILVERPINE_FOREST] = {{39.68, 17.75}}
            },
            },
            [questKeys.requiredMinRep] = {510, 42000},
        },
        [8145] = { -- The Maelstrom's Tendril
            [questKeys.nextQuestInChain] = 8146,
        },
        [8146] = { -- The Maelstrom's Tendril
            [questKeys.nextQuestInChain] = 8147,
        },
        [8147] = { -- The Maelstrom's Tendril
            [questKeys.nextQuestInChain] = 8148,
        },
        [8148] = { -- Maelstrom's Wrath
            [questKeys.name] = "Maelstrom's Wrath",
        },
        [8149] = { -- Honoring a Hero
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place a tribute at Uther's Tomb"), 0, {{"object", 2082},}}},
        },
        [8150] = { -- Honoring a Hero
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place a tribute at Grom's Monument"), 0, {{"object", 21004},}}},
        },
        [8151] = { -- The Hunter's Charm
            [questKeys.startedBy] = {{3039, 3352, 4205, 5116, 5516}},
        },
        [8166] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredMaxLevel] = 49,
        },
        [8167] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredMaxLevel] = 39,
        },
        [8168] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredMaxLevel] = 29,
        },
        [8169] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredMaxLevel] = 49,
        },
        [8170] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredMaxLevel] = 39,
        },
        [8171] = { -- The Battle for Arathi Basin!
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredMaxLevel] = 29,
        },
        [8181] = { -- Confront Yeh'kinya
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.nextQuestInChain] = 8182,
        },
        [8183] = { -- The Heart of Hakkar
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8184] = { -- Presence of Might
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.objectivesText] = {},
        },
        [8185] = { -- Syncretist's Sigil
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {},
        },
        [8186] = { -- Death's Embrace
            [questKeys.requiredClasses] = classIDs.ROGUE,
            [questKeys.objectivesText] = {},
        },
        [8187] = { -- Falcon's Call
            [questKeys.requiredClasses] = classIDs.HUNTER,
            [questKeys.objectivesText] = {},
        },
        [8188] = { -- Vodouisant's Vigilant Embrace
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectivesText] = {},
        },
        [8189] = { -- Presence of Sight
            [questKeys.requiredClasses] = classIDs.MAGE,
            [questKeys.objectivesText] = {},
        },
        [8190] = { -- Hoodoo Hex
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {},
        },
        [8191] = { -- Prophetic Aura
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectivesText] = {},
        },
        [8192] = { -- Animist's Caress
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {},
        },
        [8193] = { -- Master Angler
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 60,
            [questKeys.requiredSkill] = {},
        },
        [8194] = { -- Apprentice Angler
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 60,
            [questKeys.requiredSkill] = {},
        },
        [8195] = { -- Zulian, Razzashi, and Hakkari Coins
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8196] = { -- Essence Mangoes
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8201] = { -- A Collection of Heads
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8221] = { -- Rare Fish - Keefer's Angelfish
            [questKeys.questLevel] = 60,
            [questKeys.requiredSkill] = {},
        },
        [8224] = { -- Rare Fish - Dezian Queenfish
            [questKeys.questLevel] = 60,
            [questKeys.requiredSkill] = {},
        },
        [8225] = { -- Rare Fish - Brownell's Blue Striped Racer
            [questKeys.questLevel] = 60,
            [questKeys.requiredSkill] = {},
        },
        [8227] = { -- Nat's Measuring Tape
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8228] = { -- Could I get a Fishing Flier?
            [questKeys.startedBy] = {{15116}},
            [questKeys.finishedBy] = {{15116}},
            [questKeys.requiredLevel] = 35,
            [questKeys.requiredSkill] = {profKeys.FISHING, 175},
        },
        [8229] = { -- Could I get a Fishing Flier?
            [questKeys.startedBy] = {{15119}},
            [questKeys.finishedBy] = {{15119}},
            [questKeys.requiredLevel] = 35,
            [questKeys.requiredSkill] = {profKeys.FISHING, 175},
        },
        [8233] = { -- A Simple Request
            [questKeys.startedBy] = {{918, 3328, 4163, 4583, 5165, 5167}},
        },
        [8238] = { -- Gurubashi, Vilebranch, and Witherbark Coins
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8239] = { -- Sandfury, Skullsplitter, and Bloodscalp Coins
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8240] = { -- A Bijou for Zanza
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.requiredSourceItems] = {19707, 19708, 19709, 19710, 19711, 19712, 19713, 19714, 19715},
        },
        [8243] = { -- Zanza's Potent Potables
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8246] = { -- Signets of the Zandalar
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8249] = { -- Junkboxes Needed
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8250] = { -- Magecraft
            [questKeys.startedBy] = {{331, 3047, 4567, 7311, 7312}},
        },
        [8251] = { -- Magic Dust
            [questKeys.preQuestSingle] = {},
        },
        [8254] = { -- Cenarion Aid
            [questKeys.startedBy] = {{3045, 5489, 6018, 11406}},
        },
        [8258] = { -- The Darkreaver Menace
            [questKeys.exclusiveTo] = {7668}, -- 7668 before Phase 4
        },
        [8262] = { -- Arathor Advanced Care Package
            [questKeys.requiredMinRep] = {509, 3000},
        },
        [8271] = { -- Hero of the Stormpike
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8272] = { -- Hero of the Frostwolf
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8275] = { -- Taking Back Silithus
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbForQuestId] = 8280, -- #1873
        },
        [8276] = { -- Taking Back Silithus
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbForQuestId] = 8280, -- #1873
        },
        [8277] = { -- Deadly Desert Venom
            [questKeys.nextQuestInChain] = 8278,
        },
        [8278] = { -- Noggle's Last Hope
            [questKeys.nextQuestInChain] = 8282,
        },
        [8280] = { -- Securing the Supply Lines
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbs] = {8275, 8276}, -- #1873
        },
        [8286] = { -- What Tomorrow Brings
            [questKeys.objectives] = {{{15192, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 8288,
        },
        [8289] = { -- Talismans of Merit (#1435)
            [questKeys.startedBy] = {{14733}},
            [questKeys.finishedBy] = {{14733}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8296] = { -- Mark of Honor
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8301] = { -- The Path of the Righteous
            [questKeys.nextQuestInChain] = 8303,
        },
        [8304] = { -- Dearest Natalia
            [questKeys.objectives] = {{{15171, nil, Questie.ICON_TYPE_TALK}, {15170, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredLevel] = 58, -- #2166
        },
        [8306] = { -- Into The Maw of Madness
            [questKeys.objectivesText] = {"Commander Mar'alith at Cenarion Hold in Silithus wants you to find his beloved Natalia. The information that you gathered points to Hive'Regal in the south as being the area in which you may find Mistress Natalia Mar'alith.", "", "Do not forget to visit the dwarves at Bronzebeard's camp before venturing into the hive. They might have some additional work and advice for you.", "", "And <Name>, remember the Commander's words: \"Do what you must...\""},
        },
        [8314] = { -- Unraveling the Mystery
            [questKeys.specialFlags] = specialFlags.NONE, -- #1870
        },
        [8315] = { -- The Calling
            [questKeys.extraObjectives] = {{{[zoneIDs.SILITHUS] = {{47.50, 54.50}}}, Questie.ICON_TYPE_EVENT, l10n("Draw the glyphs into the sand to summon the Qiraji Emissary."),}},
            [questKeys.objectivesText] = {"Geologist Larksbane at Cenarion Hold in Silithus wants you to recover the Crystal Unlocking Mechanism from the Qiraji Emissary.", "", "You have been instructed to take the Glyphs of Calling to the Bones of Grakkarond, south of Cenarion Hold, and draw them in the sand. Should the Qiraji Emissary appear, slay it and recover the Crystal Unlocking Mechanism. Return to Geologist Larksbane if you succeed.", "", "Assemble an army for this task, <Name>!"},
        },
        [8317] = { -- Kitchen Assistance
            [questKeys.requiredSourceItems] = {20424},
        },
        [8331] = { -- Aurel Goldleaf
            [questKeys.breadcrumbForQuestId] = 8332,
        },
        [8332] = { -- Dukes of the Council
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8331},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."), 2, {{"object", 180456}, {"object", 180518}, {"object", 180529}, {"object", 180544}, {"object", 180549}, {"object", 180564},}}},
        },
        [8341] = { -- Lords of the Council
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8343},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."), 2, {{"object", 180461}, {"object", 180534}, {"object", 180554},}}},
        },
        [8343] = { -- Goldleaf's Discovery
            [questKeys.breadcrumbForQuestId] = 8341,
        },
        [8348] = { -- Signet of the Dukes
            [questKeys.preQuestSingle] = {8332},
            [questKeys.breadcrumbs] = {8349},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."), 0, {{"object", 180461}, {"object", 180534}, {"object", 180554},}}},
        },
        [8349] = { -- Bor Wildmane
            [questKeys.breadcrumbForQuestId] = 8348,
        },
        [8351] = { -- Bor Wishes to Speak
            [questKeys.breadcrumbForQuestId] = 8352,
        },
        [8352] = { -- Scepter of the Council
            [questKeys.preQuestSingle] = {8341},
            [questKeys.breadcrumbs] = {8351},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Lord using a full Twilight set, neck and ring."), 0, {{"object", 180466}, {"object", 180539}, {"object", 180559},}}},
        },
        [8353] = { -- Chicken Clucking for a Mint
            [questKeys.objectives] = {{{5111, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8354] = { -- Chicken Clucking for a Mint
            [questKeys.objectives] = {{{6741, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8355] = { -- Incoming Gumdrop
            [questKeys.objectives] = {{{6826, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8356] = { -- Flexing for Nougat
            [questKeys.objectives] = {{{6740, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8357] = { -- Dancing for Marzipan
            [questKeys.objectives] = {{{6735, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8358] = { -- Incoming Gumdrop
            [questKeys.objectives] = {{{11814, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8359] = { -- Flexing for Nougat
            [questKeys.objectives] = {{{6929, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8360] = { -- Dancing for Marzipan
            [questKeys.objectives] = {{{6746, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8361] = { -- Abyssal Contacts
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."), 0, {{"object", 180456}, {"object", 180518}, {"object", 180529}, {"object", 180544}, {"object", 180549}, {"object", 180564},}}},
        },
        [8363] = { -- Abyssal Signets
            [questKeys.requiredMinRep] = {609, 3000},
        },
        [8368] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8426, 8427, 8428, 8429, 8430},
            [questKeys.requiredMaxLevel] = 19,
        },
        [8370] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8436, 8437, 8438, 8439},
            [questKeys.requiredMaxLevel] = 29,
        },
        [8372] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8399, 8400, 8401, 8402, 8403},
            [questKeys.requiredMaxLevel] = 19,
        },
        [8373] = { -- The Power of Pine
            [questKeys.objectives] = {nil, {{180449}}},
        },
        [8374] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8393, 8394, 8395, 8396}, -- #6068
            [questKeys.requiredMaxLevel] = 29,
        },
        [8375] = { -- Remember Alterac Valley!
            [questKeys.zoneOrSort] = zoneIDs.ALTERAC_VALLEY,
        },
        [8383] = { -- Remember Alterac Valley!
            [questKeys.zoneOrSort] = zoneIDs.ALTERAC_VALLEY,
            [questKeys.objectivesText] = {},
        },
        [8384] = { -- Claiming Arathi Basin
            [questKeys.requiredMaxLevel] = 29,
        },
        [8385] = { -- Concerted Efforts
            [questKeys.objectivesText] = {},
        },
        [8386] = { -- Fight for Warsong Gulch
            [questKeys.requiredMaxLevel] = 19,
            [questKeys.objectivesText] = {},
        },
        [8387] = { -- Invaders of Alterac Valley
            [questKeys.zoneOrSort] = zoneIDs.ALTERAC_VALLEY,
            [questKeys.objectivesText] = {},
        },
        [8388] = { -- For Great Honor
            [questKeys.objectivesText] = {},
        },
        [8389] = { -- Battle of Warsong Gulch
            [questKeys.requiredMaxLevel] = 19,
            [questKeys.objectivesText] = {},
        },
        [8390] = { -- Conquering Arathi Basin
            [questKeys.requiredMaxLevel] = 29,
            [questKeys.objectivesText] = {},
        },
        [8391] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374, 8393},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8392] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374, 8393, 8394},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8393] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374, 8394, 8395, 8396},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8394] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374, 8393, 8395, 8396},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8395] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374, 8393, 8394, 8396},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8396] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374, 8393, 8394, 8395},
        },
        [8397] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374, 8393, 8394, 8395},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8398] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374, 8393, 8394, 8395, 8396},
            [questKeys.objectivesText] = {},
        },
        [8399] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372, 8400, 8401, 8402, 8403},
            [questKeys.requiredMaxLevel] = 29,
        },
        [8400] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372, 8399, 8401, 8402, 8403},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8401] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372, 8399, 8400, 8402, 8403},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8402] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372, 8399, 8400, 8401, 8403},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8403] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372, 8399, 8400, 8401, 8402},
        },
        [8404] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372, 8399},
            [questKeys.requiredMaxLevel] = 29,
            [questKeys.objectivesText] = {},
        },
        [8405] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372, 8399, 8400},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8406] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372, 8399, 8400, 8401},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8407] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372, 8399, 8400, 8401, 8402},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8408] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372, 8399, 8400, 8401, 8402, 8403},
            [questKeys.objectivesText] = {},
        },
        [8410] = { -- Elemental Mastery
            [questKeys.exclusiveTo] = {8411},
            [questKeys.startedBy] = {{3032, 13417}},
        },
        [8411] = { -- Mastering the Elements
            [questKeys.exclusiveTo] = {8410},
        },
        [8412] = { -- Spirit Totem
            [questKeys.preQuestSingle] = {8410, 8411},
        },
        [8414] = { -- Dispelling Evil
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8414},
        },
        [8415] = { -- Chillwind Camp
            [questKeys.startedBy] = {{928, 5149}},
            [questKeys.breadcrumbForQuestId] = 8414,
        },
        [8417] = { -- A Troubled Spirit
            [questKeys.startedBy] = {{3041, 3354, 4593, 5113, 5479, 7315}},
            [questKeys.breadcrumbForQuestId] = 8423,
        },
        [8419] = { -- An Imp's Request
            [questKeys.startedBy] = {{461, 3326, 4563, 5172}},
        },
        [8423] = { -- Warrior Kinship
            [questKeys.breadcrumbs] = {8417},
        },
        [8426] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368, 8427, 8428, 8429, 8430},
            [questKeys.requiredMaxLevel] = 29,
        },
        [8427] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368, 8426, 8428, 8429, 8430},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8428] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368, 8426, 8427, 8429, 8430},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8429] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368, 8426, 8427, 8428, 8430},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8430] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368, 8426, 8427, 8428, 8429},
        },
        [8431] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368, 8426},
            [questKeys.requiredMaxLevel] = 29,
            [questKeys.objectivesText] = {},
        },
        [8432] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368, 8426, 8427},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8433] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368, 8426, 8427, 8428},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8434] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368, 8426, 8427, 8428, 8429},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8435] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368, 8426, 8427, 8428, 8429, 8430},
            [questKeys.objectivesText] = {},
        },
        [8436] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370, 8437, 8438, 8439},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8437] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370, 8436, 8438, 8439},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8438] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370, 8436, 8437, 8439},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8439] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370, 8436, 8437, 8438},
        },
        [8440] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370, 8436},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8441] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370, 8436, 8437},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8442] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370, 8436, 8437, 8438},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8443] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370, 8436, 8437, 8438, 8439},
            [questKeys.objectivesText] = {},
        },
        [8447] = { -- Waking Legends
            [questKeys.triggerEnd] = {"Waking Legends.", {[zoneIDs.MOONGLADE] = {{40.0, 48.6}}}},
        },
        [8460] = { -- Timbermaw Ally
            [questKeys.nextQuestInChain] = 8462,
        },
        [8461] = { -- Deadwood of the North
            [questKeys.nextQuestInChain] = 8465,
        },
        [8464] = { -- Winterfall Activity
            [questKeys.nextQuestInChain] = 8469,
        },
        [8466] = { -- Feathers for Grazle
            [questKeys.objectivesText] = {},
        },
        [8467] = { -- Feathers for Nafien
            [questKeys.objectivesText] = {},
        },
        [8469] = { -- Beads for Salfa
            [questKeys.objectivesText] = {},
        },
        [8481] = { -- The Root of All Evil
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant the Demon Summoning Torch"), 0, {{"object", 180673}}}},
        },
        [8484] = { -- The Brokering of Peace
            [questKeys.preQuestSingle] = {8481},
        },
        [8485] = { -- The Brokering of Peace
            [questKeys.preQuestSingle] = {8481},
        },
        [8492] = { -- The Alliance Needs Copper Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8493] = { -- The Alliance Needs More Copper Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8494] = { -- The Alliance Needs Iron Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8495] = { -- The Alliance Needs More Iron Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8498] = { -- Twilight Battle Orders
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8499] = { -- The Alliance Needs Thorium Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8500] = { -- The Alliance Needs More Thorium Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8503] = { -- The Alliance Needs Stranglekelp!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8504] = { -- The Alliance Needs More Stranglekelp!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8505] = { -- The Alliance Needs Purple Lotus!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8506] = { -- The Alliance Needs More Purple Lotus!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8507] = { -- Field Duty
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ask to see the Captain."), 0, {{"monster", 15443}}}},
        },
        [8509] = { -- The Alliance Needs Arthas' Tears!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8510] = { -- The Alliance Needs More Arthas' Tears!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8511] = { -- The Alliance Needs Light Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8512] = { -- The Alliance Needs Light Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8513] = { -- The Alliance Needs Medium Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8514] = { -- The Alliance Needs More Medium Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8515] = { -- The Alliance Needs Thick Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8516] = { -- The Alliance Needs More Thick Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8517] = { -- The Alliance Needs Linen Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8518] = { -- The Alliance Needs More Linen Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8519] = { -- A Pawn on the Eternal Board
            [questKeys.triggerEnd] = {"The War of the Shifting Sands", {[zoneIDs.SILITHUS] = {{29.04, 92.09}}}},
            [questKeys.nextQuestInChain] = 8555,
        },
        [8520] = { -- The Alliance Needs Silk Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8521] = { -- The Alliance Needs More Silk Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8522] = { -- The Alliance Needs Runecloth Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8523] = { -- The Alliance Needs More Runecloth Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8524] = { -- The Alliance Needs Rainbow Fin Albacore!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8525] = { -- The Alliance Needs More Rainbow Fin Albacore!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8526] = { -- The Alliance Needs Roast Raptor!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8527] = { -- The Alliance Needs More Roast Raptor!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8528] = { -- The Alliance Needs Spotted Yellowtail!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8529] = { -- The Alliance Needs More Spotted Yellowtail!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8532] = { -- The Horde Needs Copper Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8533] = { -- The Horde Needs More Copper Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8535] = { -- Hoary Templar
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."), 0, {{"object", 180456}, {"object", 180518}, {"object", 180529}, {"object", 180544}, {"object", 180549}, {"object", 180564},}}},
        },
        [8536] = { -- Earthen Templar
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."), 0, {{"object", 180456}, {"object", 180518}, {"object", 180529}, {"object", 180544}, {"object", 180549}, {"object", 180564},}}},
        },
        [8537] = { -- Crimson Templar
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."), 0, {{"object", 180456}, {"object", 180518}, {"object", 180529}, {"object", 180544}, {"object", 180549}, {"object", 180564},}}},
        },
        [8538] = { -- The Four Dukes
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."), 0, {{"object", 180461}, {"object", 180534}, {"object", 180554},}}},
        },
        [8542] = { -- The Horde Needs Tin Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8543] = { -- The Horde Needs More Tin Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8545] = { -- The Horde Needs Mithril Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8546] = { -- The Horde Needs More Mithril Bars!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8548] = { -- Volunteer's Battlegear
            [questKeys.preQuestSingle] = {8800},
        },
        [8549] = { -- The Horde Needs Peacebloom!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8550] = { -- The Horde Needs Peacebloom!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8551] = { -- The Captain's Chest
            [questKeys.requiredLevel] = 35,
        },
        [8552] = { -- The Monogrammed Sash
            [questKeys.nextQuestInChain] = 8553,
        },
        [8572] = { -- Veteran's Battlegear
            [questKeys.preQuestSingle] = {8800},
        },
        [8573] = { -- Champion's Battlegear
            [questKeys.preQuestSingle] = {8800},
        },
        [8574] = { -- Stalwart's Battlegear
            [questKeys.preQuestSingle] = {8800},
        },
        [8575] = { -- Azuregos's Magical Ledger
            [questKeys.startedBy] = {{15481}},
            [questKeys.preQuestSingle] = {8555}, -- #2365
            [questKeys.nextQuestInChain] = 8576,
        },
        [8579] = { -- Mortal Champions
            [questKeys.nextQuestInChain] = 8595,
        },
        [8580] = { -- The Horde Needs Firebloom!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8581] = { -- The Horde Needs More Firebloom!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8582] = { -- The Horde Needs Purple Lotus!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8583] = { -- The Horde Needs More Purple Lotus!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8588] = { -- The Horde Needs Heavy Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8589] = { -- The Horde Needs More Heavy Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8590] = { -- The Horde Needs Thick Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8591] = { -- The Horde Needs More Thick Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8600] = { -- The Horde Needs Rugged Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8601] = { -- The Horde Needs More Rugged Leather!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8604] = { -- The Horde Needs Wool Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8605] = { -- The Horde Needs More Wool Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8607] = { -- The Horde Needs Mageweave Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8608] = { -- The Horde Needs More Mageweave Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8609] = { -- The Horde Needs Runecloth Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8610] = { -- The Horde Needs More Runecloth Bandages!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8611] = { -- The Horde Needs Lean Wolf Steaks!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8612] = { -- The Horde Needs More Lean Wolf Steaks!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8613] = { -- The Horde Needs Spotted Yellowtail!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8614] = { -- The Horde Needs More Spotted Yellowtail!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8615] = { -- The Horde Needs Baked Salmon!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8616] = { -- The Horde Needs More Baked Salmon!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8620] = { -- The Only Prescription
            [questKeys.requiredSourceItems] = {21103, 21104, 21105, 21106, 21107, 21108, 21109, 21110},
        },
        [8728] = { -- The Good News and The Bad News
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {8578, 8587, 8620},
        },
        [8729] = { -- The Wrath of Neptulon
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Arcanite Buoy"), 0, {{"object", 180669}}}},
        },
        [8733] = { -- Eranikus, Tyrant of the Dream
            [questKeys.preQuestSingle] = {8555}, -- #2365
        },
        [8735] = { -- The Nightmare's Corruption
            [questKeys.nextQuestInChain] = 8736,
        },
        [8736] = { -- The Nightmare Manifests
            [questKeys.triggerEnd] = {"The Redemption of Eranikus", {[zoneIDs.MOONGLADE] = {{51.8, 36.4}}}},
            [questKeys.nextQuestInChain] = 8741,
        },
        [8737] = { -- Azure Templar
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."), 0, {{"object", 180456}, {"object", 180518}, {"object", 180529}, {"object", 180544}, {"object", 180549}, {"object", 180564},}}},
        },
        [8746] = { -- Metzen the Reindeer
            [questKeys.requiredSourceItems] = {21314},
        },
        [8747] = { -- The Path of the Protector
            [questKeys.exclusiveTo] = {8752, 8753, 8754, 8755, 8756, 8757, 8758, 8759, 8760, 8761}, --protector neutral
        },
        [8748] = { -- The Path of the Protector
            [questKeys.exclusiveTo] = {8752, 8753, 8754, 8755, 8756, 8757, 8758, 8759, 8760, 8761}, --protector friendly
        },
        [8749] = { -- The Path of the Protector
            [questKeys.exclusiveTo] = {8752, 8753, 8754, 8755, 8756, 8757, 8758, 8759, 8760, 8761}, --protector honored
        },
        [8750] = { -- The Path of the Protector
            [questKeys.exclusiveTo] = {8752, 8753, 8754, 8755, 8756, 8757, 8758, 8759, 8760, 8761}, --protector revered
        },
        [8751] = { -- The Protector of Kalimdor
            [questKeys.exclusiveTo] = {8752, 8753, 8754, 8755, 8756, 8757, 8758, 8759, 8760, 8761}, --protector exalted
        },
        [8752] = { -- The Path of the Conqueror
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8757, 8758, 8759, 8760, 8761}, --conqueror neutral
        },
        [8753] = { -- The Path of the Conqueror
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8757, 8758, 8759, 8760, 8761}, --conqueror friendly
        },
        [8754] = { -- The Path of the Conqueror
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8757, 8758, 8759, 8760, 8761}, --conqueror honored
        },
        [8755] = { -- The Path of the Conqueror
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8757, 8758, 8759, 8760, 8761}, --conqueror revered
        },
        [8756] = { -- The Qiraji Conqueror
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8757, 8758, 8759, 8760, 8761}, --conqueror exalted
        },
        [8757] = { -- The Path of the Invoker
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8752, 8753, 8754, 8755, 8756}, --invoker neutral
        },
        [8758] = { -- The Path of the Invoker
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8752, 8753, 8754, 8755, 8756}, --invoker friendly
        },
        [8759] = { -- The Path of the Invoker
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8752, 8753, 8754, 8755, 8756}, --invoker honored
        },
        [8760] = { -- The Path of the Invoker
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8752, 8753, 8754, 8755, 8756}, --invoker revered
        },
        [8761] = { -- The Grand Invoker
            [questKeys.exclusiveTo] = {8747, 8748, 8749, 8750, 8751, 8752, 8753, 8754, 8755, 8756}, --invoker exalted
        },
        [8762] = { -- Metzen the Reindeer
            [questKeys.requiredSourceItems] = {21314},
        },
        [8767] = { -- A Gently Shaken Gift
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.WARRIOR + classIDs.HUNTER + classIDs.PALADIN,
            [questKeys.exclusiveTo] = {8788},
        },
        [8788] = { -- A Gently Shaken Gift
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.WARLOCK + classIDs.MAGE + classIDs.SHAMAN + classIDs.DRUID,
            [questKeys.exclusiveTo] = {8767},
        },
        [8792] = { -- The Horde Needs Your Help!
            [questKeys.requiredLevel] = 1,
        },
        [8793] = { -- The Horde Needs Your Help!
            [questKeys.requiredLevel] = 1,
        },
        [8794] = { -- The Horde Needs Your Help!
            [questKeys.requiredLevel] = 1,
        },
        [8795] = { -- The Alliance Needs Your Help!
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {8796, 8797},
        },
        [8796] = { -- The Alliance Needs Your Help!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {8795, 8797},
        },
        [8797] = { -- The Alliance Needs Your Help!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {8795, 8796},
        },
        [8798] = { -- A Yeti of Your Own
            [questKeys.requiredSkill] = {202, 250},
        },
        [8804] = { -- Desert Survival Kits
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8805] = { -- Boots for the Guard
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8806] = { -- Grinding Stones for the Guard
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8807] = { -- Scrying Materials
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8829] = { -- The Ultimate Deception
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8846] = { -- Five Signets for War Supplies
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8847] = { -- Ten Signets for War Supplies
            [questKeys.startedBy] = {{15701}},
            [questKeys.finishedBy] = {{15701}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8848] = { -- Fifteen Signets for War Supplies
            [questKeys.startedBy] = {{15701}},
            [questKeys.finishedBy] = {{15701}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8849] = { -- Twenty Signets for War Supplies
            [questKeys.startedBy] = {{15701}},
            [questKeys.finishedBy] = {{15701}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8850] = { -- Thirty Signets for War Supplies
            [questKeys.startedBy] = {{15701}},
            [questKeys.finishedBy] = {{15701}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8851] = { -- Five Signets for War Supplies
            [questKeys.startedBy] = {{15700}},
            [questKeys.finishedBy] = {{15700}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8852] = { -- Ten Signets for War Supplies
            [questKeys.startedBy] = {{15700}},
            [questKeys.finishedBy] = {{15700}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8853] = { -- Fifteen Signets for War Supplies
            [questKeys.startedBy] = {{15700}},
            [questKeys.finishedBy] = {{15700}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8854] = { -- Twenty Signets for War Supplies
            [questKeys.startedBy] = {{15700}},
            [questKeys.finishedBy] = {{15700}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8855] = { -- Thirty Signets for War Supplies
            [questKeys.startedBy] = {{15700}},
            [questKeys.finishedBy] = {{15700}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8860] = { -- New Year Celebrations!
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 60,
        },
        [8861] = { -- New Year Celebrations!
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 60,
        },
        [8863] = { -- Festival Dumplings
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questLevel] = 60,
        },
        [8864] = { -- Festive Lunar Dresses
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8865] = { -- Festive Lunar Pant Suits
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8867] = { -- Lunar Fireworks
            [questKeys.breadcrumbs] = {8870, 8871, 8872, 8873, 8874, 8875},
            [questKeys.requiredSourceItems] = {21557, 21558, 21559, 21571, 21574, 21576},
            [questKeys.objectives] = {nil, {{180771}, {180772}}},
        },
        [8868] = { -- Elune's Blessing
            [questKeys.triggerEnd] = {"Receive Elune's Blessing.", {[zoneIDs.MOONGLADE] = {{63.89, 62.5}}}},
        },
        [8869] = { -- Sweet Serenity
            [questKeys.exclusiveTo] = {5305},
        },
        [8870] = { -- The Lunar Festival
            [questKeys.breadcrumbForQuestId] = 8867,
            [questKeys.exclusiveTo] = {8871, 8872},
        },
        [8871] = { -- The Lunar Festival
            [questKeys.breadcrumbForQuestId] = 8867,
            [questKeys.exclusiveTo] = {8870, 8872},
            [questKeys.startedBy] = {},
        },
        [8872] = { -- The Lunar Festival
            [questKeys.breadcrumbForQuestId] = 8867,
            [questKeys.exclusiveTo] = {8870, 8871},
            [questKeys.startedBy] = {},
        },
        [8873] = { -- The Lunar Festival
            [questKeys.breadcrumbForQuestId] = 8867,
            [questKeys.exclusiveTo] = {8874, 8875},
        },
        [8874] = { -- The Lunar Festival
            [questKeys.breadcrumbForQuestId] = 8867,
            [questKeys.exclusiveTo] = {8873, 8875},
            [questKeys.startedBy] = {},
        },
        [8875] = { -- The Lunar Festival
            [questKeys.breadcrumbForQuestId] = 8867,
            [questKeys.exclusiveTo] = {8873, 8874},
            [questKeys.startedBy] = {},
        },
        [8876] = { -- Small Rockets
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8877] = { -- Firework Launcher
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8878] = { -- Festive Recipes
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8879] = { -- Large Rockets
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8880] = { -- Cluster Rockets
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8881] = { -- Large Cluster Rockets
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8882] = { -- Cluster Launcher
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8883] = { -- Valadar Starsong
            [questKeys.requiredSourceItems] = {21711},
        },
        [8897] = { -- Dearest Colara,
            [questKeys.nextQuestInChain] = 8903,
            [questKeys.breadcrumbForQuestId] = 8903,
        },
        [8898] = { -- Dearest Colara,
            [questKeys.nextQuestInChain] = 8903,
            [questKeys.breadcrumbForQuestId] = 8903,
        },
        [8899] = { -- Dearest Colara,
            [questKeys.nextQuestInChain] = 8903,
            [questKeys.breadcrumbForQuestId] = 8903,
        },
        [8900] = { -- Dearest Elenia,
            [questKeys.exclusiveTo] = {8901, 8902, 8904},
            [questKeys.nextQuestInChain] = 8979,
        },
        [8901] = { -- Dearest Elenia,
            [questKeys.exclusiveTo] = {8900, 8902, 8904},
            [questKeys.nextQuestInChain] = 8979,
        },
        [8902] = { -- Dearest Elenia,
            [questKeys.exclusiveTo] = {8900, 8901, 8904},
            [questKeys.nextQuestInChain] = 8979,
        },
        [8903] = { -- Dangerous Love
            [questKeys.requiredSourceItems] = {21815, 21829, 21833, 22178},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8897, 8898, 8899},
        },
        [8904] = { -- Dangerous Love
            [questKeys.requiredSourceItems] = {21815, 21829, 21833, 22163},
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {8900, 8901, 8902},
        },
        [8905] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8906] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8907] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8908] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8909] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8910] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8911] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8912] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [8913] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8914] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8915] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8916] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8917] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8918] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8919] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8920] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [8950] = { -- The Instigator's Enchantment
            [questKeys.nextQuestInChain] = 9015,
        },
        [8961] = { -- Three Kings of Flame
            [questKeys.nextQuestInChain] = 8962,
        },
        [8962] = { -- Components of Importance
            [questKeys.nextQuestInChain] = 8966,
        },
        [8963] = { -- Components of Importance
            [questKeys.nextQuestInChain] = 8966,
        },
        [8964] = { -- Components of Importance
            [questKeys.nextQuestInChain] = 8966,
        },
        [8965] = { -- Components of Importance
            [questKeys.nextQuestInChain] = 8966,
        },
        [8966] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.exclusiveTo] = {8967, 8968, 8969},
            [questKeys.preQuestSingle] = {8962, 8963, 8964, 8965},
        },
        [8967] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.exclusiveTo] = {8966, 8968, 8969},
            [questKeys.preQuestSingle] = {8962, 8963, 8964, 8965},
        },
        [8968] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.exclusiveTo] = {8966, 8967, 8969},
            [questKeys.preQuestSingle] = {8962, 8963, 8964, 8965},
        },
        [8969] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.exclusiveTo] = {8966, 8967, 8968},
            [questKeys.preQuestSingle] = {8962, 8963, 8964, 8965},
        },
        [8970] = { -- I See Alcaz Island In Your Future...
            [questKeys.nextQuestInChain] = 8985,
        },
        [8979] = { -- Fenstad's Hunch
            [questKeys.nextQuestInChain] = 8980,
            [questKeys.preQuestSingle] = {8900, 8901, 8902, 8904},
        },
        [8980] = { -- Zinge's Assessment
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8985] = { -- More Components of Importance
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8986, 8987, 8988},
            [questKeys.nextQuestInChain] = 8989,
        },
        [8986] = { -- More Components of Importance
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8985, 8987, 8988},
            [questKeys.nextQuestInChain] = 8989,
        },
        [8987] = { -- More Components of Importance
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8986, 8988, 8989},
            [questKeys.nextQuestInChain] = 8989,
        },
        [8988] = { -- More Components of Importance
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8986, 8987, 8989},
            [questKeys.nextQuestInChain] = 8989,
        },
        [8989] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.preQuestSingle] = {8985, 8986, 8987, 8988},
            [questKeys.exclusiveTo] = {8990, 8991, 8992},
        },
        [8990] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.preQuestSingle] = {8985, 8986, 8987, 8988},
            [questKeys.exclusiveTo] = {8989, 8991, 8992},
        },
        [8991] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.preQuestSingle] = {8985, 8986, 8987, 8988},
            [questKeys.exclusiveTo] = {8989, 8990, 8992},
        },
        [8992] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.preQuestSingle] = {8985, 8986, 8987, 8988},
            [questKeys.exclusiveTo] = {8989, 8990, 8991},
        },
        [9015] = { -- The Challenge
            [questKeys.objectives] = {{{16059, nil, Questie.ICON_TYPE_EVENT}}, nil, {{22047}}}, -- #2408
        },
        [9024] = { -- Aristan's Hunch
            [questKeys.nextQuestInChain] = 9025,
        },
        [9026] = { -- Tracing the Source
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9033] = { -- Echoes of War
            [questKeys.nextQuestInChain] = 9229,
        },
        [9034] = { -- Dreadnaught Breastplate
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9036] = { -- Dreadnaught Legplates
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9037] = { -- Dreadnaught Helmet
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9038] = { -- Dreadnaught Pauldrons
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9039] = { -- Dreadnaught Sabatons
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9040] = { -- Dreadnaught Gauntlets
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9041] = { -- Dreadnaught Waistguard
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9042] = { -- Dreadnaught Bracers
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9043] = { -- Redemption Tunic
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9044] = { -- Redemption Legguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9045] = { -- Redemption Headpiece
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9046] = { -- Redemption Spaulders
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9047] = { -- Redemption Boots
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9048] = { -- Redemption Handguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9049] = { -- Redemption Girdle
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9050] = { -- Redemption Wristguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9051] = { -- Toxic Test
            [questKeys.objectives] = {nil, nil, nil, nil, {{{6498, 6499, 6500}, 6498, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [9052] = { -- Bloodpetal Poison
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9063},
        },
        [9054] = { -- Cryptstalker Tunic
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9055] = { -- Cryptstalker Legguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9056] = { -- Cryptstalker Headpiece
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9057] = { -- Cryptstalker Spaulders
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9058] = { -- Cryptstalker Boots
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9059] = { -- Cryptstalker Handguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9060] = { -- Cryptstalker Girdle
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9061] = { -- Cryptstalker Wristguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9063] = { -- Torwa Pathfinder
            [questKeys.startedBy] = {{3033, 4217, 5505, 12042}},
            [questKeys.breadcrumbForQuestId] = 9052,
        },
        [9068] = { -- Earthshatter Tunic
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9069] = { -- Earthshatter Legguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9070] = { -- Earthshatter Headpiece
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9071] = { -- Earthshatter Spaulders
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9072] = { -- Earthshatter Boots
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9073] = { -- Earthshatter Handguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9074] = { -- Earthshatter Girdle
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9075] = { -- Earthshatter Wristguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9077] = { -- Bonescythe Breastplate
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9078] = { -- Bonescythe Legplates
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9079] = { -- Bonescythe Helmet
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9080] = { -- Bonescythe Pauldrons
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9081] = { -- Bonescythe Sabatons
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9082] = { -- Bonescythe Gauntlets
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9083] = { -- Bonescythe Waistguard
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9084] = { -- Bonescythe Bracers
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9085] = { -- Shadows of Doom
            [questKeys.requiredLevel] = 50,
        },
        [9086] = { -- Dreamwalker Tunic
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9087] = { -- Dreamwalker Legguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9088] = { -- Dreamwalker Headpiece
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9089] = { -- Dreamwalker Spaulders
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9090] = { -- Dreamwalker Boots
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9091] = { -- Dreamwalker Handguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9092] = { -- Dreamwalker Girdle
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9093] = { -- Dreamwalker Wristguards
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9094] = { -- Argent Dawn Gloves
            [questKeys.requiredLevel] = 50,
        },
        [9095] = { -- Frostfire Robe
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9096] = { -- Frostfire Leggings
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9097] = { -- Frostfire Circlet
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9098] = { -- Frostfire Shoulderpads
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9099] = { -- Frostfire Sandals
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9100] = { -- Frostfire Gloves
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9101] = { -- Frostfire Belt
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9102] = { -- Frostfire Bindings
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9103] = { -- Plagueheart Robe
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9104] = { -- Plagueheart Leggings
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9105] = { -- Plagueheart Circlet
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9106] = { -- Plagueheart Shoulderpads
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9107] = { -- Plagueheart Sandals
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9108] = { -- Plagueheart Gloves
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9109] = { -- Plagueheart Belt
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9110] = { -- Plagueheart Bindings
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9111] = { -- Robe of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9112] = { -- Leggings of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9113] = { -- Circlet of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9114] = { -- Shoulderpads of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9115] = { -- Sandals of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9116] = { -- Gloves of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9117] = { -- Belt of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9118] = { -- Bindings of Faith
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9120] = { -- The Fall of Kel'Thuzad
            [questKeys.preQuestSingle] = {9121, 9122, 9123},
        },
        [9121] = { -- The Dread Citadel - Naxxramas
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 0},
            [questKeys.requiredMaxRep] = {factionIDs.ARGENT_DAWN, 21000},
            [questKeys.nextQuestInChain] = 9033,
        },
        [9122] = { -- The Dread Citadel - Naxxramas
            [questKeys.nextQuestInChain] = 9033,
            [questKeys.requiredMaxRep] = {factionIDs.ARGENT_DAWN, 42000},
        },
        [9123] = { -- The Dread Citadel - Naxxramas
            [questKeys.nextQuestInChain] = 9033,
            [questKeys.reputationReward] = {{factionIDs.ARGENT_DAWN, 1000}},
        },
        [9124] = { -- Cryptstalker Armor Doesn't Make Itself...
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
            [questKeys.nextQuestInChain] = 9125,
        },
        [9125] = { -- Crypt Fiend Parts
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
        },
        [9126] = { -- Bonescythe Digs
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
            [questKeys.nextQuestInChain] = 9127,
        },
        [9127] = { -- Bone Fragments
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
        },
        [9128] = { -- The Elemental Equation
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
            [questKeys.nextQuestInChain] = 9129,
        },
        [9129] = { -- Core of Elements
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
        },
        [9131] = { -- Binding the Dreadnaught
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
            [questKeys.nextQuestInChain] = 9132,
        },
        [9132] = { -- Dark Iron Scraps
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
        },
        [9136] = { -- Savage Flora
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
            [questKeys.nextQuestInChain] = 9137,
        },
        [9137] = { -- Savage Fronds
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
        },
        [9141] = { -- They Call Me "The Rooster"
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
            [questKeys.nextQuestInChain] = 9142,
        },
        [9142] = { -- Craftsman's Writ
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 3000},
        },
        [9153] = { -- Under the Shadow
            [questKeys.requiredLevel] = 50,
        },
        [9154] = { -- Light's Hope Chapel
            [questKeys.questLevel] = 60,
        },
        [9165] = { -- Writ of Safe Passage
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9211] = { -- The Ice Guard
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 9000},
        },
        [9213] = { -- The Shadow Guard
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 9000},
        },
        [9223] = { -- Superior Armaments of Battle - Honored Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9229] = { -- The Fate of Ramaladni
            [questKeys.preQuestSingle] = {9033},
        },
        [9232] = { -- The Only Song I Know...
            [questKeys.preQuestSingle] = {9033},
        },
        [9233] = { -- Omarion's Handbook
            [questKeys.preQuestSingle] = {9121, 9122, 9123},
            [questKeys.requiredMinRep] = {factionIDs.ARGENT_DAWN, 21000},
            [questKeys.requiredRanks] = {{profKeys.TAILORING, -rankKeys.ARTISAN}, {profKeys.BLACKSMITHING, -rankKeys.ARTISAN}, {profKeys.LEATHERWORKING, -rankKeys.ARTISAN}},
        },
        [9234] = { -- Icebane Gauntlets
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [9235] = { -- Icebane Bracers
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [9236] = { -- Icebane Breastplate
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
            [questKeys.requiredMinRep] = {},
        },
        [9237] = { -- Glacial Cloak
            [questKeys.requiredMinRep] = {},
        },
        [9238] = { -- Glacial Wrists
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9239] = { -- Glacial Gloves
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9240] = { -- Glacial Vest
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
            [questKeys.requiredMinRep] = {},
        },
        [9241] = { -- Polar Bracers
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9242] = { -- Polar Gloves
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9243] = { -- Polar Tunic
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
            [questKeys.requiredMinRep] = {},
        },
        [9244] = { -- Icy Scale Bracers
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9245] = { -- Icy Scale Gauntlets
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9246] = { -- Icy Scale Breastplate
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
            [questKeys.requiredMinRep] = {},
        },
        [9247] = { -- The Keeper's Call
            [questKeys.requiredLevel] = 1,
        },
        [9248] = { -- A Humble Offering
            [questKeys.requiredMinRep] = {609, 0},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Lord using a full Twilight set, neck and ring."), 0, {{"object", 180466}, {"object", 180539}, {"object", 180559},}}},
        },
        [9250] = { -- Frame of Atiesh
            [questKeys.requiredClasses] = classIDs.MAGE + classIDs.PRIEST + classIDs.DRUID + classIDs.WARLOCK,
        },
        [9251] = { -- Atiesh, the Befouled Greatstaff
            [questKeys.requiredClasses] = classIDs.MAGE + classIDs.PRIEST + classIDs.DRUID + classIDs.WARLOCK,
        },
        [9260] = { -- Investigate the Scourge of Stormwind
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.ELWYNN_FOREST] = {{34.72, 50.95}, {34.18, 48.47}, {32.24, 53.77}, {35.05, 55.22}}}},
        },
        [9261] = { -- Investigate the Scourge of Ironforge
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.DUN_MOROGH] = {{48.53, 39.54}, {49.70, 39.17}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9262] = { -- Investigate the Scourge of Darnassus
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.TELDRASSIL] = {{36.96, 55.49}, {38.30, 56.49}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9263] = { -- Investigate the Scourge of Orgrimmar
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.DUROTAR] = {{44.9, 16.7}, {44.6, 18.1}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [9264] = { -- Investigate the Scourge of Thunder Bluff
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.MULGORE] = {{38.9, 37.1}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [9265] = { -- Investigate the Scourge of the Undercity
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.TIRISFAL_GLADES] = {{60.4, 61.7}}}},
        },
        [9272] = { -- Dressing the Part
            [questKeys.requiredMinRep] = {87, 0},
        },
        [9292] = { -- Cracked Necrotic Crystal
            [questKeys.requiredLevel] = 1,
        },
        [9295] = { -- Letter from the Front
            [questKeys.requiredLevel] = 45,
        },
        [9299] = { -- Note from the Front
            [questKeys.requiredLevel] = 45,
        },
        [9300] = { -- Page from the Front
            [questKeys.requiredLevel] = 45,
        },
        [9301] = { -- Envelope from the Front
            [questKeys.requiredLevel] = 45,
        },
        [9302] = { -- Missive from the Front
            [questKeys.requiredLevel] = 45,
        },
        [9304] = { -- Document from the Front
            [questKeys.requiredLevel] = 45,
        },
        [9310] = { -- Faint Necrotic Crystal
            [questKeys.requiredLevel] = 1,
        },
        [9317] = { -- Consecrated Sharpening Stones
            [questKeys.requiredLevel] = 50,
        },
        [9318] = { -- Blessed Wizard Oil
            [questKeys.questLevel] = 60,
        },
        [9319] = { -- A Light in Dark Places
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [9320] = { -- Major Mana Potion
            [questKeys.requiredLevel] = 50,
        },
        [9321] = { -- Major Healing Potion
            [questKeys.zoneOrSort] = sortKeys.INVASION,
            [questKeys.questLevel] = 60,
        },
        [9322] = { -- Wild Fires in Kalimdor
            [questKeys.requiredLevel] = 1,
        },
        [9323] = { -- Wild Fires in the Eastern Kingdoms
            [questKeys.requiredLevel] = 1,
        },
        [9333] = { -- Argent Dawn Gloves
            [questKeys.requiredLevel] = 50,
        },
        [9334] = { -- Blessed Wizard Oil
            [questKeys.questLevel] = 60,
        },
        [9335] = { -- Consecrated Sharpening Stones
            [questKeys.questLevel] = 60,
        },
        [9336] = { -- Major Healing Potion
            [questKeys.questLevel] = 60,
        },
        [9337] = { -- Major Mana Potion
            [questKeys.questLevel] = 60,
        },
        [9339] = { -- A Thief's Reward
            [questKeys.objectivesText] = {},
        },
        [9341] = { -- Tabard of the Argent Dawn
            [questKeys.questLevel] = 60,
        },
        [9343] = { -- Tabard of the Argent Dawn
            [questKeys.questLevel] = 60,
        },
        [9365] = { -- A Thief's Reward
            [questKeys.objectivesText] = {},
        },
        [9386] = { -- A Light in Dark Places
            [questKeys.preQuestSingle] = {9319},
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9415] = { -- Report to Marshal Bluewall
            [questKeys.requiredLevel] = 1,
            [questKeys.nextQuestInChain] = 0,
        },
        [9416] = { -- Report to General Kirika
            [questKeys.requiredLevel] = 1,
            [questKeys.nextQuestInChain] = 0,
        },
        [9419] = { -- Scouring the Desert
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredLevel] = 1,
            [questKeys.disabledByQuest] = 9415,
            [questKeys.objectives] = {{{17090, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Silithyst"), 0, {{"object", 181597}, {"object", 181598}}}},
        },
        [9422] = { -- Scouring the Desert
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredLevel] = 1,
            [questKeys.disabledByQuest] = 9416,
            [questKeys.objectives] = {{{18199, nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Silithyst"), 0, {{"object", 181597}, {"object", 181598}}}},
        },
        [9664] = { -- Establishing New Outposts
            [questKeys.objectives] = {{{17689, nil, Questie.ICON_TYPE_EVENT}, {17690, nil, Questie.ICON_TYPE_EVENT}, {17696, nil, Questie.ICON_TYPE_EVENT}, {17698, nil, Questie.ICON_TYPE_EVENT}}},
        },
        [9665] = { -- Bolstering Our Defenses
            [questKeys.objectives] = {{{17689, nil, Questie.ICON_TYPE_EVENT}, {17690, nil, Questie.ICON_TYPE_EVENT}, {17696, nil, Questie.ICON_TYPE_EVENT}, {17698, nil, Questie.ICON_TYPE_EVENT}}},
        },
        ----- Warlock Incubus quest chain -----
        [65593] = { -- Hearts of the Lovers
            [questKeys.name] = "Hearts of the Lovers",
            [questKeys.startedBy] = {{5693}},
            [questKeys.finishedBy] = {{5675}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 65597,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Bring the hearts of Avelina Lilly and Isaac Pearson to Carendin Halgar in the Temple of the Damned."},
            [questKeys.objectives] = {nil, nil, {{190179}, {190180}}},
            [questKeys.preQuestSingle] = {1472},
            [questKeys.exclusiveTo] = {1507},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },
        [65597] = { -- The Binding
            [questKeys.name] = "The Binding",
            [questKeys.startedBy] = {{5675}},
            [questKeys.finishedBy] = {{5675}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Using the Lovers' Hearts, summon and subdue an incubus, then return the Lovers' Hearts to Carendin Halgar in the Magic Quarter of the Undercity."},
            [questKeys.objectives] = {{{185335}}},
            [questKeys.preQuestSingle] = {65593},
            [questKeys.requiredSourceItems] = {190181},
            [questKeys.exclusiveTo] = {1507},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Incubus"), 0, {{"object", 37097}}}},
        },
        [65601] = { -- Love Hurts
            [questKeys.name] = "Love Hurts",
            [questKeys.startedBy] = {{5909}},
            [questKeys.finishedBy] = {{3363}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 65610,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Speak with Magar in Orgrimmar."},
            [questKeys.preQuestSingle] = {1507},
            [questKeys.exclusiveTo] = {1472},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },
        [65602] = { -- What Is Love?
            [questKeys.name] = "What Is Love?",
            [questKeys.startedBy] = {{6244}},
            [questKeys.finishedBy] = {{6122}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 65603,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Retrieve the Wooden Figurine and bring it to Gakin the Darkbinder in the Mage Quarter of Stormwind."},
            [questKeys.preQuestSingle] = {1716},
            [questKeys.objectives] = {nil, nil, {{190309}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.requiredSourceItems] = {190307, 190308},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Light the Unlit Torch near a fire and use the Burning Torch to set the Archaeologist's Cart on fire."), 0, {{"object", 400002}}}},
        },
        [65603] = { -- The Binding
            [questKeys.name] = "The Binding",
            [questKeys.startedBy] = {{6122}},
            [questKeys.finishedBy] = {{6122}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Using the Wooden Figurine, summon and subdue an incubus, then return the Wooden Figurine to Gakin the Darkbinder in the Slaughtered Lamb."},
            [questKeys.objectives] = {{{185335}}},
            [questKeys.preQuestSingle] = {65602},
            [questKeys.requiredSourceItems] = {190186},
            [questKeys.exclusiveTo] = {},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Incubus"), 0, {{"object", 92015}}}},
        },
        [65604] = { -- The Binding
            [questKeys.name] = "The Binding",
            [questKeys.startedBy] = {{5875}},
            [questKeys.finishedBy] = {{5875}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Using the Withered Scarf, summon and subdue an incubus, then return the Withered Scarf to Gan'rul Bloodeye in Orgrimmar."},
            [questKeys.objectives] = {{{185335}}},
            [questKeys.preQuestSingle] = {65610},
            [questKeys.requiredSourceItems] = {190187},
            [questKeys.exclusiveTo] = {1472},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Incubus"), 0, {{"object", 105576}}}},
        },
        [65610] = { -- Wish You Were Here
            [questKeys.name] = "Wish You Were Here",
            [questKeys.startedBy] = {{3363}},
            [questKeys.finishedBy] = {{5875}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 65604,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Investigate Fallen Sky Lake in Ashenvale and report your findings to Gan'rul Bloodeye in Orgrimmar."},
            [questKeys.preQuestSingle] = {65601},
            [questKeys.objectives] = {nil, nil, {{190232}}},
            [questKeys.exclusiveTo] = {1472},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },
    }
end

function QuestieQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local playerClass = UnitClassBase("player")
    local factionIDs = QuestieDB.factionIDs

    local questFixesHorde = {
        [113] = { -- Insect Part Analysis
            [questKeys.nextQuestInChain] = 32,
        },
        [687] = { -- Theldurin the Lost
            [questKeys.startedBy] = {{2787}},
        },
        [709] = { -- Solution to Doom
            [questKeys.nextQuestInChain] = 728,
        },
        [737] = { -- Forbidden Knowledge
            [questKeys.startedBy] = {{2934}},
        },
        [1198] = { -- In Search of Thaelrid
            [questKeys.nextQuestInChain] = 0,
        },
        [1393] = { -- Galen's Escape
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [1718] = { -- The Islander
            [questKeys.startedBy] = {{3041, 3354, 4595}},
        },
        [1947] = { -- Journey to the Marsh
            [questKeys.startedBy] = {{3048, 4568, 5885}},
        },
        [1953] = { -- Return to the Marsh
            [questKeys.startedBy] = {{3048, 4568, 5885}},
        },
        [2861] = { -- Tabetha's Task
            [questKeys.startedBy] = {{4568, 5885}},
        },
        [2954] = { -- The Stone Watcher
            [questKeys.nextQuestInChain] = 2967,
        },
        [3741] = { -- Hilary's Necklace
            [questKeys.reputationReward] = {}, -- doable as horde, but no SW reputation for horde side
        },
        [4507] = { -- Pawn Captures Queen
            [questKeys.nextQuestInChain] = 4509,
        },
        [4985] = { -- The Wildlife Suffers Too
            [questKeys.nextQuestInChain] = 4987,
        },
        [5021] = { -- Better Late Than Never
            [questKeys.nextQuestInChain] = 5023,
        },
        [5050] = { -- Good Luck Charm
            [questKeys.startedBy] = {{8403}},
        },
        [6981] = { -- The Glowing Shard
            [questKeys.nextQuestInChain] = 3369,
        },
        [7562] = { -- Mor'zul Bloodbringer
            [questKeys.startedBy] = {{5753, 5815}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8151] = { -- The Hunter's Charm
            [questKeys.startedBy] = {{3039, 3352}},
        },
        [8233] = { -- A Simple Request
            [questKeys.startedBy] = {{3328, 4583}},
        },
        [8250] = { -- Magecraft
            [questKeys.startedBy] = {{3047, 4567, 7311}},
        },
        [8254] = { -- Cenarion Aid
            [questKeys.startedBy] = {{3045, 6018}},
        },
        [8315] = { -- The Calling
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 8382,
                ["HUNTER"] = 8377,
                ["MAGE"] = 8381,
                ["PALADIN"] = 8376,
                ["PRIEST"] = 8379,
                ["ROGUE"] = 8378,
                ["SHAMAN"] = 8380,
                ["WARLOCK"] = 8381,
                ["WARRIOR"] = 8316,
            })[playerClass],
        },
        [8417] = { -- A Troubled Spirit
            [questKeys.startedBy] = {{3041, 3354, 4593}},
        },
        [8419] = { -- An Imp's Request
            [questKeys.startedBy] = {{3326, 4563}},
        },
        [8619] = { -- Morndeep the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8635] = { -- Splitrock the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8636] = { -- Rumblerock the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8642] = { -- Silvervein the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8643] = { -- Highpeak the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8644] = { -- Stonefort the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8645] = { -- Obsidian the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8646] = { -- Hammershout the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8647] = { -- Bellowrage the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8648] = { -- Darkcore the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8649] = { -- Stormbrow the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8650] = { -- Snowcrown the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8651] = { -- Ironband the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8652] = { -- Graveborn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8653] = { -- Goldwell the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8654] = { -- Primestone the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8670] = { -- Runetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8671] = { -- Ragetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8672] = { -- Stonespire the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8673] = { -- Bloodhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8674] = { -- Winterhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8675] = { -- Skychaser the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8676] = { -- Wildmane the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8677] = { -- Darkhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8678] = { -- Proudhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8679] = { -- Grimtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8680] = { -- Windtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8681] = { -- Thunderhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8682] = { -- Skyseer the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8683] = { -- Dawnstrider the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8684] = { -- Dreamseer the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8685] = { -- Mistwalker the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8686] = { -- High Mountain the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8688] = { -- Windrun the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8713] = { -- Starsong the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8714] = { -- Moonstrike the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8715] = { -- Bladeleaf the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8716] = { -- Starglade the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8717] = { -- Moonwarden the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8718] = { -- Bladeswift the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8719] = { -- Bladesing the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8720] = { -- Skygleam the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8721] = { -- Starweave the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8722] = { -- Meadowrun the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8723] = { -- Nightwind the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8724] = { -- Morningdew the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8725] = { -- Riversong the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8726] = { -- Brightspear the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8727] = { -- Farwhisper the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8866] = { -- Bronzebeard the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE, 50}},
        },
        [8928] = { -- A Shifty Merchant
            [questKeys.nextQuestInChain] = 8978,
        },
        [8978] = { -- Return to Mokvar
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 8927,
                ["HUNTER"] = 8938,
                ["MAGE"] = 8939,
                ["PRIEST"] = 8940,
                ["ROGUE"] = 8941,
                ["SHAMAN"] = 8942,
                ["WARLOCK"] = 8943,
                ["WARRIOR"] = 8944,
            })[playerClass],
        },
        [8996] = { -- Return to Bodley
            [questKeys.nextQuestInChain] = 8998,
        },
        [8998] = { -- Back to the Beginning
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 9007,
                ["HUNTER"] = 9008,
                ["MAGE"] = 9014,
                ["PRIEST"] = 9009,
                ["ROGUE"] = 9010,
                ["SHAMAN"] = 9011,
                ["WARLOCK"] = 9012,
                ["WARRIOR"] = 9013,
            })[playerClass],
        },
        [9015] = { -- The Challenge
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 9016,
                ["HUNTER"] = 9017,
                ["MAGE"] = 9018,
                ["PRIEST"] = 9019,
                ["ROGUE"] = 9020,
                ["SHAMAN"] = 8957,
                ["WARLOCK"] = 9021,
                ["WARRIOR"] = 9022,
            })[playerClass],
        },
        [9063] = { -- Torwa Pathfinder
            [questKeys.startedBy] = {{3033, 12042}},
        },
        [9388] = { -- Flickering Flames in Kalimdor
            [questKeys.startedBy] = {{16818}},
        },
        [9389] = { -- Flickering Flames in the Eastern Kingdoms
            [questKeys.startedBy] = {{16818}},
        },
    }

    local questFixesAlliance = {
        [113] = { -- Insect Part Analysis
            [questKeys.nextQuestInChain] = 162,
        },
        [687] = { -- Theldurin the Lost
            [questKeys.startedBy] = {{2786}},
        },
        [709] = { -- Solution to Doom
            [questKeys.nextQuestInChain] = 727,
        },
        [737] = { -- Forbidden Knowledge
            [questKeys.startedBy] = {{2786}},
        },
        [1198] = { -- In Search of Thaelrid
            [questKeys.breadcrumbForQuestId] = 1200,
        },
        [1393] = { -- Galen's Escape
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [1718] = { -- The Islander
            [questKeys.startedBy] = {{5113, 5479}},
        },
        [1947] = { -- Journey to the Marsh
            [questKeys.startedBy] = {{5144, 5497}},
        },
        [1953] = { -- Return to the Marsh
            [questKeys.startedBy] = {{5144, 5497}},
        },
        [2861] = { -- Tabetha's Task
            [questKeys.startedBy] = {{5144, 5497}},
        },
        [2954] = { -- The Stone Watcher
            [questKeys.nextQuestInChain] = 2977,
        },
        [4507] = { -- Pawn Captures Queen
            [questKeys.nextQuestInChain] = 4508,
        },
        [4985] = { -- The Wildlife Suffers Too
            [questKeys.nextQuestInChain] = 4986,
        },
        [5021] = { -- Better Late Than Never
            [questKeys.nextQuestInChain] = 5022,
        },
        [5050] = { -- Good Luck Charm
            [questKeys.startedBy] = {{3520}},
        },
        [6804] = { -- Poisoned Water
            [questKeys.reputationReward] = {}, -- need to check if horde actually gets any reputation at all
        },
        [6981] = { -- The Glowing Shard
            [questKeys.nextQuestInChain] = 3370,
        },
        [7562] = { -- Mor'zul Bloodbringer
            [questKeys.startedBy] = {{5520, 6382}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8151] = { -- The Hunter's Charm
            [questKeys.startedBy] = {{4205, 5116, 5516}},
        },
        [8233] = { -- A Simple Request
            [questKeys.startedBy] = {{918, 4163, 5165, 5167}},
        },
        [8250] = { -- Magecraft
            [questKeys.startedBy] = {{331, 7312}},
        },
        [8254] = { -- Cenarion Aid
            [questKeys.startedBy] = {{5489, 11406}},
        },
        [8315] = { -- The Calling
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 8382,
                ["HUNTER"] = 8377,
                ["MAGE"] = 8381,
                ["PALADIN"] = 8376,
                ["PRIEST"] = 8379,
                ["ROGUE"] = 8378,
                ["SHAMAN"] = 8380,
                ["WARLOCK"] = 8381,
                ["WARRIOR"] = 8316,
            })[playerClass],
        },
        [8417] = { -- A Troubled Spirit
            [questKeys.startedBy] = {{5113, 5479, 7315}},
        },
        [8419] = { -- An Imp's Request
            [questKeys.startedBy] = {{461, 5172}},
        },
        [8619] = { -- Morndeep the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8635] = { -- Splitrock the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8636] = { -- Rumblerock the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8642] = { -- Silvervein the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8643] = { -- Highpeak the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8644] = { -- Stonefort the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8645] = { -- Obsidian the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8646] = { -- Hammershout the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8647] = { -- Bellowrage the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8648] = { -- Darkcore the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8649] = { -- Stormbrow the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8650] = { -- Snowcrown the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8651] = { -- Ironband the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8652] = { -- Graveborn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8653] = { -- Goldwell the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8654] = { -- Primestone the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8670] = { -- Runetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8671] = { -- Ragetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8672] = { -- Stonespire the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8673] = { -- Bloodhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8674] = { -- Winterhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8675] = { -- Skychaser the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8676] = { -- Wildmane the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8677] = { -- Darkhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8678] = { -- Proudhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8679] = { -- Grimtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8680] = { -- Windtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8681] = { -- Thunderhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8682] = { -- Skyseer the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8683] = { -- Dawnstrider the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8684] = { -- Dreamseer the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8685] = { -- Mistwalker the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8686] = { -- High Mountain the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8688] = { -- Windrun the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8713] = { -- Starsong the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8714] = { -- Moonstrike the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8715] = { -- Bladeleaf the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8716] = { -- Starglade the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8717] = { -- Moonwarden the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8718] = { -- Bladeswift the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8719] = { -- Bladesing the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8720] = { -- Skygleam the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8721] = { -- Starweave the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8722] = { -- Meadowrun the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8723] = { -- Nightwind the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8724] = { -- Morningdew the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8725] = { -- Riversong the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8726] = { -- Brightspear the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8727] = { -- Farwhisper the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8866] = { -- Bronzebeard the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE, 50}},
        },
        [8928] = { -- A Shifty Merchant
            [questKeys.nextQuestInChain] = 8977,
        },
        [8977] = { -- Return to Deliana
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 8926,
                ["HUNTER"] = 8931,
                ["MAGE"] = 8932,
                ["PALADIN"] = 8933,
                ["PRIEST"] = 8934,
                ["ROGUE"] = 8935,
                ["WARLOCK"] = 8936,
                ["WARRIOR"] = 8937,
            })[playerClass],
        },
        [8996] = { -- Return to Bodley
            [questKeys.nextQuestInChain] = 8997,
        },
        [8997] = { -- Back to the Beginning
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 8999,
                ["HUNTER"] = 9000,
                ["MAGE"] = 9001,
                ["PALADIN"] = 9002,
                ["PRIEST"] = 9003,
                ["ROGUE"] = 9004,
                ["WARLOCK"] = 9005,
                ["WARRIOR"] = 9006,
            })[playerClass],
        },
        [9015] = { -- The Challenge
            [questKeys.nextQuestInChain] = ({
                ["DRUID"] = 8951,
                ["HUNTER"] = 8952,
                ["MAGE"] = 8953,
                ["PALADIN"] = 8954,
                ["PRIEST"] = 8955,
                ["ROGUE"] = 8956,
                ["WARLOCK"] = 8958,
                ["WARRIOR"] = 8959,
            })[playerClass],
        },
        [9063] = { -- Torwa Pathfinder
            [questKeys.startedBy] = {{4217, 5505, 12042}},
        },
        [9388] = { -- Flickering Flames in Kalimdor
            [questKeys.startedBy] = {{16817}},
        },
        [9389] = { -- Flickering Flames in the Eastern Kingdoms
            [questKeys.startedBy] = {{16817}},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
