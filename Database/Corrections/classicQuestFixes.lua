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

QuestieCorrections.itemObjectiveFirst[5088] = true

-- Further information on how to use this can be found at the wiki
-- https://github.com/Questie/Questie/wiki/Corrections

function QuestieQuestFixes:LoadMissingQuests()
    QuestieDB.questData[5640] = {} -- Desperate Prayer
    QuestieDB.questData[5678] = {} -- Arcane Feedback

    QuestieDB.questData[7668] = {} -- Add missing quest index
    QuestieDB.questData[7669] = {} -- Add missing quest index
    QuestieDB.questData[7670] = {} -- Add missing quest index #1432

    QuestieDB.questData[65593] = {} -- Hearts of the Lovers
    QuestieDB.questData[65597] = {} -- The Binding
    QuestieDB.questData[65601] = {} -- Love Hurts
    QuestieDB.questData[65602] = {} -- What Is Love?
    QuestieDB.questData[65603] = {} -- The Binding
    QuestieDB.questData[65604] = {} -- The Binding
    QuestieDB.questData[65610] = {} -- Wish You Were Here
end

function QuestieQuestFixes:Load()
    local questKeys = QuestieDB.questKeys
    local zoneIDs = ZoneDB.zoneIDs
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local sortKeys = QuestieDB.sortKeys
    local specialFlags = QuestieDB.specialFlags
    local profKeys = QuestieProfessions.professionKeys
    local specKeys = QuestieProfessions.specializationKeys

    return {
        [5] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {163} -- #1198
        },
        [11] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {239},
        },
        [17] = {
            [questKeys.requiredLevel] = 38, -- #2437
        },
        [25] = {
            [questKeys.triggerEnd] = {"Scout the gazebo on Mystral Lake that overlooks the nearby Alliance outpost.",{[zoneIDs.ASHENVALE]={{48.92,69.56}}}},
        },
        [26] = { -- Switch Alliance and Horde Druid quest IDs #948
            [questKeys.startedBy] = {{4217},nil,nil},
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
            [questKeys.nextQuestInChain] = 29,
        },
        [27] = { -- Switch Alliance and Horde Druid quest IDs #948
            [questKeys.startedBy] = {{3033},nil,nil},
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.nextQuestInChain] = 28,
        },
        [28] = {
            [questKeys.triggerEnd] = {"Complete the Trial of the Lake.", {[zoneIDs.MOONGLADE]={{36.17,41.67}}}},
        },
        [29] = {
            [questKeys.triggerEnd] = {"Complete the Trial of the Lake.", {[zoneIDs.MOONGLADE]={{36.17,41.67}}}},
        },
        [30] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.MOONGLADE]={{36.5,41.7}}}, Questie.ICON_TYPE_EVENT, l10n("Combine the Pendant halves at the Shrine of Remulos.")}},
        },
        [33] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5261}, -- #1726
        },
        [46] = {
            [questKeys.preQuestSingle] = {39},
        },
        [90] = {
            [questKeys.requiredSkill] = {185, 50},
        },
        [95] = {
            [questKeys.breadcrumbs] = {164},
        },
        [100] = {
            [questKeys.childQuests] = {1103}, -- #1658
        },
        [109] = {
            [questKeys.startedBy] = {{233,237,240,261,294,963},nil,nil}, -- #2158
        },
        [117] = {
            [questKeys.name] = "Thunderbrew",
        },
        [121] = { -- Messenger to Stormwind
            [questKeys.nextQuestInChain] = 143,
        },
        [144] = { -- Messenger to Westfall
            [questKeys.nextQuestInChain] = 145,
        },
        [148] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {165} -- #1173
        },
        [155] = {
            [questKeys.triggerEnd] = {"Escort The Defias Traitor to discover where VanCleef is hiding", {[zoneIDs.WESTFALL]={{42.55,71.53}}}},
        },
        [162] = { -- Rise of the Silithid
            [questKeys.nextQuestInChain] = 4493,
        },
        [163] = {
            [questKeys.breadcrumbForQuestId] = 5, -- #1198
            [questKeys.nextQuestInChain] = 5,
        },
        [164] = {
            [questKeys.breadcrumbForQuestId] = 95, -- deliveries to sven is a breadcrumb
            [questKeys.nextQuestInChain] = 95,
        },
        [165] = {
            [questKeys.breadcrumbForQuestId] = 148, -- #1173
            [questKeys.nextQuestInChain] = 148,
        },
        [178] = {
            [questKeys.objectivesText] = {"Bring the Faded Shadowhide Pendant to Theocritus the Mage. NOTE: This is a very rare drop!"},
        },
        [201] = {
            [questKeys.triggerEnd] = {"Locate the hunters' camp", {[zoneIDs.STRANGLETHORN_VALE]={{35.65,10.59}}}},
        },
        [214] = {
            [questKeys.preQuestSingle] = {155}, -- wotlkDB has prequest wrong data
        },
        [217] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {263,267},
        },
        [219] = {
            [questKeys.triggerEnd] = {"Escort Corporal Keeshan back to Redridge", {[zoneIDs.REDRIDGE_MOUNTAINS]={{33.36,48.7}}}},
        },
        [235] = {
            [questKeys.breadcrumbForQuestId] = 6383,
            [questKeys.nextQuestInChain] = 6383,
        },
        [239] = {
            [questKeys.breadcrumbForQuestId] = 11,
        },
        [249] = {
            [questKeys.startedBy] = {{313},{31},nil},
        },
        [254] = {
            [questKeys.parentQuest] = 253,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.exclusiveTo] = {253}, -- #2173
            [questKeys.preQuestSingle] = {252},
        },
        [261] = {
            [questKeys.breadcrumbs] = {6141}, -- #1744
        },
        [272] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.MOONGLADE]={{36.5,41.7}}}, Questie.ICON_TYPE_EVENT, l10n("Combine the Pendant halves at the Shrine of Remulos.")}},
        },
        [273] = {
            [questKeys.triggerEnd] = {"Find Huldar, Miran, and Saean",{[zoneIDs.LOCH_MODAN]={{51.16, 68.96}}}},
        },
        [275] = {
            [questKeys.objectivesText] = {"Kill 12 Fen Creepers, then return to Rethiel the Greenwarden in the Wetlands."},
        },
        [276] = {
            [questKeys.breadcrumbs] = {463},
        },
        [282] = {
            [questKeys.exclusiveTo] = {287},
        },
        [287] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {420},
        },
        [297] = {
             [questKeys.breadcrumbs] = {436}, -- #2492
        },
        [308] = {
            [questKeys.exclusiveTo] = {311}, -- distracting jarven can't be completed once you get the followup
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {},
            [questKeys.parentQuest] = 310
        },
        [309] = {
            [questKeys.triggerEnd] = {"Escort Miran to the excavation site", {[zoneIDs.LOCH_MODAN]={{65.12,65.77}}}},
        },
        [310] = {
            [questKeys.childQuests] = {308,403},
        },
        [349] = {
            [questKeys.objectivesText] = {},
        },
        [353] = {
            [questKeys.preQuestSingle] = {}, -- #2364
            [questKeys.breadcrumbs] = {1097},
        },
        [355] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {354,362},
        },
        [363] = {
            [questKeys.breadcrumbForQuestId] = 364, -- #882
        },
        [364] = {
            [questKeys.preQuestSingle] = {}, -- #882
            [questKeys.breadcrumbs] = {363},
        },
        [367] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #888
        },
        [368] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #888
        },
        [369] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #888
        },
        [374] = {
            [questKeys.preQuestSingle] = {427}, -- proof of demise requires at war with the scarlet crusade
        },
        [403] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 310,
        },
        [409] = {
            [questKeys.requiredSourceItems] = {3080},
        },
        [410] = { -- the dormant shade
            [questKeys.preQuestSingle] = {366}, -- #638
            [questKeys.exclusiveTo] = {411}, -- #752
        },
        [413] = {
            [questKeys.breadcrumbs] = {415}, -- #567
        },
        [415] = {
            [questKeys.breadcrumbForQuestId] = 413, -- #567
        },
        [420] = {
            [questKeys.nextQuestInChain] = 287,
            [questKeys.breadcrumbForQuestId] = 287,
        },
        [427] = {
            [questKeys.preQuestSingle] = {},
        },
        [428] = {
            [questKeys.nextQuestInChain] = 429,
            [questKeys.breadcrumbForQuestId] = 429,
        },
        [429] = {
            [questKeys.preQuestSingle] = {}, -- #1843
            [questKeys.breadcrumbs] = {428},
        },
        [431] = { -- candles of beckoning
            [questKeys.preQuestSingle] = {366}, -- #638
            [questKeys.exclusiveTo] = {411}, -- #752
        },
        [434] = {
            [questKeys.triggerEnd] = {"Overhear Lescovar and Marzon's Conversation", {[zoneIDs.STORMWIND_CITY]={{68.66,14.44}}}},
        },
        [435] = {
            [questKeys.triggerEnd] = {"Erland must reach Rane Yorick", {[zoneIDs.SILVERPINE_FOREST]={{54.37,13.38}}}},
        },
        [436] = {
            [questKeys.breadcrumbForQuestId] = 297, -- #2492
        },
        [437] = {
            [questKeys.triggerEnd] = {"Enter the Dead Fields",{[zoneIDs.SILVERPINE_FOREST]={{45.91, 21.27}}}},
        },
        [443] = {
            [questKeys.preQuestSingle] = {439},
        },
        [452] = {
            [questKeys.triggerEnd] = {"Aid Faerleia in killing the Pyrewood Council", {[zoneIDs.SILVERPINE_FOREST]={{46.51,74.07}}}},
        },
        [455] = {
            [questKeys.preQuestSingle] = {}, -- #1858
            [questKeys.breadcrumbs] = {468},
        },
        [463] = {
            [questKeys.nextQuestInChain] = 276,
            [questKeys.breadcrumbForQuestId] = 276,
        },
        [464] = {
            [questKeys.preQuestSingle] = {}, -- #809
            [questKeys.breadcrumbs] = {473}, -- #2173
        },
        [466] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {467}, -- #2066
        },
        [467] = {
            [questKeys.startedBy] = {{1340,2092},nil,nil}, -- #1379
            [questKeys.breadcrumbForQuestId] = 466, -- #2066
        },
        [468] = {
            [questKeys.nextQuestInChain] = 455, -- #1858
            [questKeys.breadcrumbForQuestId] = 455,
        },
        [473] = {
            [questKeys.preQuestSingle] = {455}, -- #809
            [questKeys.nextQuestInChain] = 464,
            [questKeys.breadcrumbForQuestId] = 464, -- #2173
        },
        [484] = {
            [questKeys.requiredMinRep] = {72,0}, -- #1501
        },
        [489] = {
            [questKeys.startedBy] = {{2081,2083,2151,2155},nil,nil},
        },
        [495] = {
             [questKeys.breadcrumbForQuestId] = 518,
        },
        [504] = {
            [questKeys.objectivesText] = {"Slay 15 Crushridge Warmongers, then return to Marshal Redpath in Southshore."},
        },
        [510] = {
            [questKeys.startedBy] = {nil,{1738,1739,1740},nil}, -- #1512
        },
        [511] = {
            [questKeys.startedBy] = {nil,{1738,1739,1740},nil}, -- #1512
        },
        [518] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {495},
        },
        [526] = {
            [questKeys.exclusiveTo] = {322,324}, -- not 100% sure on this one but it seems lightforge ingots is optional, block it after completing subsequent steps (#587)
        },
        [533] = {
            [questKeys.childQuests] = {535},
        },
        [535] = {
            [questKeys.parentQuest] = 533,
        },
        [546] = {
            [questKeys.preQuestSingle] = {527},
        },
        [549] = {
            [questKeys.nextQuestInChain] = 566, -- #1134
        },
        [558] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestGroup] = {1687,1479,1558},
            [questKeys.inGroupWith] = nil,
            [questKeys.childQuests] = {},
        },
        [566] = {
            [questKeys.preQuestSingle] = {549}, -- #1484
        },
        [578] = {
            [questKeys.childQuests] = {579},
        },
        [579] = {
            [questKeys.parentQuest] = 578,
        },
        [590] = {
            [questKeys.triggerEnd] = {"Defeat Calvin Montague",{[zoneIDs.TIRISFAL_GLADES]={{38.19,56.74}}}},
        },
        [598] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {596,629},
        },
        [619] = {
            [questKeys.parentQuest] = 8554, -- #1691
        },
        [621] = {
            [questKeys.inGroupWith] = {}, -- #886
        },
        [638] = {
            [questKeys.nextQuestInChain] = 639,
            [questKeys.breadcrumbForQuestId] = 639, -- #1205
        },
        [639] = {
            [questKeys.preQuestSingle] = {}, -- #1205
            [questKeys.breadcrumbs] = {638},
        },
        [640] = {
            [questKeys.objectivesText] = {"Retrieve the 11 Sigil Fragments from the defenders in Stromgarde, and bring them to Tor'gan in Hammerfall.",},
        },
        [648] = {
            [questKeys.triggerEnd] = {"Escort OOX-17/TN to Steamwheedle Port", {[zoneIDs.TANARIS]={{67.06,23.16}}}},
        },
        [660] = {
            [questKeys.triggerEnd] = {"Protect Kinelory", {[zoneIDs.ARATHI_HIGHLANDS]={{60.1,53.83}}}},
        },
        [664] = {
            [questKeys.preQuestSingle] = {663}, -- #7258
        },
        [665] = {
            [questKeys.triggerEnd] = {"Defend Professor Phizzlethorpe", {[zoneIDs.ARATHI_HIGHLANDS]={{33.87,80.6}}}},
            [questKeys.preQuestSingle] = {663}, -- #6972
        },
        [667] = {
            [questKeys.triggerEnd] = {"Defend Shakes O'Breen", {[zoneIDs.ARATHI_HIGHLANDS]={{31.93,81.82}}}},
        },
        [676] = {
            [questKeys.exclusiveTo] = {677},
        },
        [677] = {
            [questKeys.preQuestSingle] = {}, -- #1162
        },
        [680] = {
            [questKeys.preQuestSingle] = {678}, -- #1062
        },
        [690] = {
            [questKeys.exclusiveTo] = {691}, -- #1587
        },
        [691] = {
            [questKeys.preQuestSingle] = {}, -- #1587
        },
        [707] = {
            [questKeys.nextQuestInChain] = 738,
            [questKeys.breadcrumbForQuestId] = 738, -- #1289
        },
        [715] = {
            [questKeys.requiredSkill] = {},
        },
        [717] = {
            [questKeys.requiredSourceItems] = {4843,4844,4845},
        },
        [729] = {
            [questKeys.breadcrumbs] = {730},
        },
        [730] = {
            [questKeys.breadcrumbForQuestId] = 729,
            [questKeys.zoneOrSort] = 1657,
        },
        [731] = {
            [questKeys.triggerEnd] = {"Escort Prospector Remtravel", {[zoneIDs.DARKSHORE]={{35.67,84.03}}}},
        },
        [735] = {
            [questKeys.requiredSourceItems] = {4639},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Dagun the Ravenous using an Enchanted Sea Kelp"), 2, {{"object", 2871}}}},
        },
        [736] = {
            [questKeys.requiredSourceItems] = {4639},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Dagun the Ravenous using an Enchanted Sea Kelp"), 2, {{"object", 2871}}}},
        },
        [738] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {707}, -- #1289
        },
        [742] = {
            [questKeys.breadcrumbForQuestId] = 6383,
            [questKeys.nextQuestInChain] = 6383,
        },
        [752] = {
            [questKeys.breadcrumbForQuestId] = 753,
        },
        [753] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {752},
        },
        [754] = {
            [questKeys.triggerEnd] = {"Cleanse the Winterhoof Water Well", {[zoneIDs.MULGORE]={{53.61, 66.2}}}},
        },
        [758] = {
            [questKeys.triggerEnd] = {"Cleanse the Thunderhorn Water Well", {[zoneIDs.MULGORE]={{44.52, 45.46}}}},
        },
        [760] = {
            [questKeys.triggerEnd] = {"Cleanse the Wildmane Well", {[zoneIDs.MULGORE]={{42.75, 14.16}}}},
        },
        [769] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSkill] = {165,10},
        },
        [788] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4641}, -- #1956
        },
        [793] = {
            [questKeys.requiredSourceItems] = {4843,4844,4845},
        },
        [809] = {
            [questKeys.triggerEnd] = {"Destroy the Demon Seed", {[zoneIDs.THE_BARRENS]={{62.34,20.07}}}}, -- #2347
        },
        [834] = {
            [questKeys.requiredRaces] = raceIDs.NONE, -- #1665
        },
        [835] = {
            [questKeys.requiredRaces] = raceIDs.NONE, -- #1665
        },
        [836] = {
            [questKeys.triggerEnd] = {"Escort OOX-09/HL to the shoreline beyond Overlook Cliff", {[zoneIDs.THE_HINTERLANDS]={{79.14,61.36}}}},
        },
        [841] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.exclusiveTo] = {654},
        },
        [844] = {
            [questKeys.breadcrumbs] = {860},
        },
        [854] = {
            [questKeys.breadcrumbForQuestId] = 871, -- #2014
            [questKeys.nextQuestInChain] = 871,
        },
        [860] = {
            [questKeys.breadcrumbForQuestId] = 844,
        },
        [861] = {
            [questKeys.nextQuestInChain] = 860,
            [questKeys.exclusiveTo] = {844}, -- #1109
        },
        [862] = {
            [questKeys.requiredSkill] = {185,76}, -- You need to be a Journeyman for this quest -- this needs proper fix
        },
        [863] = {
            [questKeys.triggerEnd] = {"Escort Wizzlecrank out of the Venture Co. drill site", {[zoneIDs.THE_BARRENS]={{55.36,7.68}}}},
        },
        [870] = {
            [questKeys.breadcrumbs] = {886},
        },
        [871] = {
            [questKeys.breadcrumbs] = {854}, -- #2014
        },
        [886] = {
            [questKeys.breadcrumbForQuestId] = 870,
        },
        [898] = {
            [questKeys.triggerEnd] = {"Escort Gilthares Firebough back to Ratchet", {[zoneIDs.THE_BARRENS]={{62.27,39.09}}}},
        },
        [910] = {
            [questKeys.triggerEnd] = {"Go to the docks of Ratchet in the Barrens.", {[zoneIDs.THE_BARRENS]={{62.96,38.04}}}},
        },
        [911] = {
            [questKeys.triggerEnd] = {"Go to the Mor'shan Rampart in the Barrens.", {[zoneIDs.THE_BARRENS]={{47.9,5.36}}}},
        },
        [915] = {
            [questKeys.objectivesText] = {"Get some Strawberry Ice Cream for your ward. The lad seems to prefer Tigule's brand ice cream."}, -- orc orphan
            [questKeys.preQuestGroup] = {1800,910,911},
            [questKeys.inGroupWith] = nil,
            [questKeys.childQuests] = {},
            [questKeys.parentQuest] = 0,
        },
        [918] = {
            [questKeys.preQuestSingle] = {},
        },
        [924] = {
            [questKeys.requiredSourceItems] = {4986},
        },
        [925] = {
            [questKeys.preQuestGroup] = {1800,910,911},
            [questKeys.inGroupWith] = nil,
            [questKeys.parentQuest] = 0,
        },
        [926] = {
            [questKeys.parentQuest] = 924, -- #806
            [questKeys.preQuestSingle] = {809}, -- #606
            [questKeys.exclusiveTo] = {924}, -- #2195
        },
        [930] = {
            [questKeys.preQuestSingle] = {918}, -- #971
        },
        [931] = {
            [questKeys.preQuestSingle] = {918},
        },
        [936] = {
            [questKeys.breadcrumbForQuestId] = 3761,
        },
        [938] = {
            [questKeys.triggerEnd] = {"Lead Mist safely to Sentinel Arynia Cloudsbreak", {[zoneIDs.TELDRASSIL]={{38.33,34.39}}}},
        },
        [944] = {
            [questKeys.triggerEnd] = {"Enter the Master's Glaive",{[zoneIDs.DARKSHORE]={{38.48,86.45}}}},
        },
        [945] = {
            [questKeys.triggerEnd] = {"Escort Therylune away from the Master's Glaive", {[zoneIDs.DARKSHORE]={{40.51,87.08}}}},
        },
        [949] = {
            [questKeys.childQuests] = {960}, -- workaround, can't mimic ingame 100%
        },
        [950] = {
            [questKeys.childQuests] = {961}, -- workaround, can't mimic ingame 100%
        },
        [960] = {
            [questKeys.name] = "Onu is meditating",
            [questKeys.startedBy] = {{3616}},
            [questKeys.finishedBy] = {{3616}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.zoneOrSort] = zoneIDs.DARKSHORE,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.questFlags] = 8,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 949, -- workaround, can't mimic ingame 100%
        },
        [961] = {
            [questKeys.finishedBy] = {{3616}},
            [questKeys.preQuestSingle] = nil,
            [questKeys.exclusiveTo] = nil,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 950, -- workaround, can't mimic ingame 100%
        },
        [976] = {
            [questKeys.triggerEnd] = {"Protect Feero Ironhand", {[zoneIDs.DARKSHORE]={{43.54,94.39}}}},
        },
        [979] = { -- Find Ranshalla
            [questKeys.nextQuestInChain] = 4901,
        },
        [984] = {
            [questKeys.triggerEnd] = {"Find a corrupt furbolg camp",{[zoneIDs.DARKSHORE]={{50.91,34.74},{39.86,53.89},{42.68,86.53},{39.95,78.41}}}},
        },
        [994] = {
            [questKeys.triggerEnd] = {"Help Volcor to the road", {[zoneIDs.DARKSHORE]={{41.92,81.76}}}},
        },
        [995] = {
            [questKeys.triggerEnd] = {"Help Volcor escape the cave", {[zoneIDs.DARKSHORE]={{44.57,85}}}},
        },
        [1000] = {
            [questKeys.exclusiveTo] = {1004,1018},
        },
        [1004] = {
            [questKeys.exclusiveTo] = {1000,1018},
        },
        [1011] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4581},
        },
        [1015] = {
            [questKeys.exclusiveTo] = {1047,1019},
        },
        [1018] = {
            [questKeys.exclusiveTo] = {1000,1004},
        },
        [1019] = {
            [questKeys.exclusiveTo] = {1015,1047},
        },
        [1026] = {
            [questKeys.requiredSourceItems] = {5475},
        },
        [1036] = {
            [questKeys.requiredMinRep] = {87,3000},
            [questKeys.requiredMaxRep] = {21,-5999},
        },
        [1046] = {
            [questKeys.objectives] = {nil,nil,{{5388,nil},{5462,nil}}},
        },
        [1047] = {
            [questKeys.exclusiveTo] = {1015,1019},
        },
        [1056] = {
            [questKeys.breadcrumbForQuestId] = 1057, -- #1901
        },
        [1057] = {
            [questKeys.breadcrumbs] = {1056}, -- #1901
        },
        [1061] = {
            [questKeys.breadcrumbForQuestId] = 1062, -- #1803
            [questKeys.nextQuestInChain] = 1062,
        },
        [1062] = {
            [questKeys.breadcrumbs] = {1061}, -- #1803
        },
        [1070] = {
            [questKeys.breadcrumbForQuestId] = 1085,
        },
        [1079] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1077,1074},
            [questKeys.requiredSourceItems] = {5695,5694,5693,5692},
        },
        [1080] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1077,1074},
        },
        [1085] = {
            [questKeys.breadcrumbs] = {1070},
        },
        [1086] = {
            [questKeys.triggerEnd] = {"Place the Toxic Fogger", {[zoneIDs.STONETALON_MOUNTAINS]={{66.44,45.46}}}},
        },
        [1090] = {
            [questKeys.objectives] = {{{4276,"Keep Piznik safe while he mines the mysterious ore"}}},
        },
        [1097] = {
            [questKeys.startedBy] = {{415,514},nil,nil},
            [questKeys.breadcrumbForQuestId] = 353, -- #2364
        },
        [1103] = {
            [questKeys.preQuestSingle] = {}, -- #1658
            [questKeys.parentQuest] = 100, -- #1658
        },
        [1106] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1104,1105},
        },
        [1107] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1104,1105} -- #2444
        },
        [1118] = {
            [questKeys.inGroupWith] = {}, -- #886
        },
        [1119] = {
            [questKeys.inGroupWith] = {}, -- #886
            [questKeys.childQuests] = {1127}, -- #1084
        },
        [1123] = {
            [questKeys.preQuestSingle] = {1000, 1004, 1018},
        },
        [1127] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #884
            [questKeys.parentQuest] = 1119, -- #1084
        },
        [1131] = {
            [questKeys.preQuestSingle] = {}, -- #1065
        },
        [1132] = {
            [questKeys.exclusiveTo] = {1133}, -- #1738
        },
        [1133] = {
            [questKeys.preQuestSingle] = {}, -- #1738
            [questKeys.zoneOrSort] = zoneIDs.DUSTWALLOW_MARSH,
        },
        [1136] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use a Fresh Carcass at the Flame of Uzel"), 0, {{"object", 1770}}}},
        },
        [1141] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE]={{35.71,44.68}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Darkshore Groupers"),}},
        },
        [1144] = {
            [questKeys.triggerEnd] = {"Help Willix the Importer escape from Razorfen Kraul", {[zoneIDs.THE_BARRENS]={{42.27,89.88}}}},
        },
        [1148] = {
            [questKeys.preQuestSingle] = {1146},
        },
        [1173] = {
            [questKeys.triggerEnd] = {"Drive Overlord Mok'Morokk from Brackenwall Village", {[zoneIDs.DUSTWALLOW_MARSH]={{36.41,31.43}}}},
        },
        [1177] = {
            [questKeys.objectivesText] = {"Mudcrush Durtfeet in northern Dustwallow wants 12 Mirefin Heads."},
        },
        [1190] = {
            [questKeys.childQuests] = {1191},
        },
        [1191] = {
            [questKeys.parentQuest] = 1190,
        },
        [1193] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1348
        },
        [1198] = {
            [questKeys.requiredRaces] = raceIDs.NONE, -- horde CAN get this quest
        },
        [1204] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1260} -- #938
        },
        [1206] = {
            [questKeys.objectivesText] = {"Bring 40 Unpopped Darkmist Eyes to \"Swamp Eye\" Jarl at the Swamplight Manor.",},
        },
        [1221] = {
            [questKeys.sourceItemId] = 6684,
        },
        [1222] = {
            [questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[zoneIDs.DUSTWALLOW_MARSH]={{48.87,24.58}}}},
        },
        [1249] = {
            [questKeys.objectives] = {{{4962,"Defeat Tapoke Jahn"}}},
        },
        [1252] = {
            [questKeys.preQuestSingle] = {1302,1282}, -- #1845
        },
        [1253] = {
            [questKeys.preQuestSingle] = {1302,1282}, -- #1845
        },
        [1260] = {
            [questKeys.breadcrumbForQuestId] = 1204, -- #938
        },
        [1264] = {
            [questKeys.preQuestSingle] = {1250}, -- wotlkDB is wrong
        },
        [1265] = {
            [questKeys.triggerEnd] = {"Sentry Point explored",{[zoneIDs.DUSTWALLOW_MARSH]={{59.92,40.9}}}},
        },
        [1267] = {
            [questKeys.startedBy] = {{4968},nil,nil},
        },
        [1268] = {
            [questKeys.startedBy] = {nil,{21015,21016},nil}, -- #1574
        },
        [1270] = {
            [questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[zoneIDs.DUSTWALLOW_MARSH]={{48.87,24.58}}}},
        },
        [1271] = {
            [questKeys.preQuestGroup] = {1222,1204},
        },
        [1273] = {
            [questKeys.triggerEnd] = {"Question Reethe with Ogron", {[zoneIDs.DUSTWALLOW_MARSH]={{42.47,38.07}}}},
        },
        [1275] = {
            [questKeys.preQuestSingle] = {}, -- #973
            [questKeys.breadcrumbs] = {3765}, -- #745
        },
        [1276] = {
            [questKeys.preQuestSingle] = {1273}, -- #1574
        },
        [1282] = {
            [questKeys.exclusiveTo] = {1301,1302}, -- #917
        },
        [1284] = {
            [questKeys.preQuestSingle] = {1302,1282}, -- #1845
            [questKeys.startedBy] = {nil,{21015,21016},nil},
        },
        [1301] = {
            [questKeys.breadcrumbForQuestId] = 1302, -- #889
        },
        [1302] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {}, -- #889
            [questKeys.breadcrumbs] = {1301}, -- #889
        },
        [1322] = {
            [questKeys.objectivesText] = {"Acquire 6 Acidic Venom Sacs for Do'gol in Brackenwall Village."},
        },
        [1324] = {
            [questKeys.objectives] = {{{4966,"Subdue Private Hendel"}}},
            [questKeys.nextQuestInChain] = 1267, -- wotlkDB is wrong, classicGB is right
        },
        [1338] = {
            [questKeys.breadcrumbs] = {1339},
        },
        [1339] = {
            [questKeys.breadcrumbForQuestId] = 1338, -- mountaineer stormpike's task cant be done if you have finished stormpike's order
        },
        [1361] = {
            [questKeys.breadcrumbForQuestId] = 1362,
            [questKeys.startedBy] = {{2229,3230,4485}},
        },
        [1362] = {
            [questKeys.breadcrumbs] = {1361},
        },
        [1364] = {
            [questKeys.preQuestSingle] = {1363}, -- #1674
        },
        [1367] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Gelkis centaur to increase your reputation with the Magram Clan"), 0, {{"monster", 4653},{"monster", 4647},{"monster", 4646},{"monster", 4661},{"monster", 5602},{"monster", 4648},{"monster", 4649},{"monster", 4651},{"monster", 4652}}}},
        },
        [1368] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Magram centaur to increase your reputation with the Gelkis Clan"), 0, {{"monster", 4643},{"monster", 4645},{"monster", 4662},{"monster", 5601},{"monster", 4638},{"monster", 4641},{"monster", 6068},{"monster", 4640},{"monster", 4639},{"monster", 4642},{"monster", 4644}}}},
        },
        [1380] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the War Horn Mouthpiece to summon Khan Hratha"), 0, {{"object", 138497}}}},
        },
        [1381] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the War Horn Mouthpiece to summon Khan Hratha"), 0, {{"object", 138497}}}},
        },
        [1388] = {
            [questKeys.preQuestSingle] = {1383},
        },
        [1393] = {
            [questKeys.triggerEnd] = {"Escort Galen out of the Fallow Sanctuary.", {[zoneIDs.SWAMP_OF_SORROWS]={{53.08,29.55}}}},
        },
        [1395] = {
            [questKeys.preQuestSingle] = {}, -- #1727
            [questKeys.breadcrumbs] = {1477},
        },
        [1418] = {
            [questKeys.breadcrumbForQuestId] = 1420, -- #1594
        },
        [1420] = {
            [questKeys.breadcrumbs] = {1418}, -- #1594
        },
        [1427] = {
            [questKeys.nextQuestInChain] = 1428,
        },
        [1428] = {
            [questKeys.preQuestSingle] = {1427},
        },
        [1432] = {
            [questKeys.nextQuestInChain] = 1433,
        },
        [1434] = {
            [questKeys.preQuestSingle] = {1432}, -- #1536
        },
        [1436] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1434,1435},
        },
        [1440] = {
            [questKeys.triggerEnd] = {"Rescue Dalinda Malem", {[zoneIDs.DESOLACE]={{58.27,30.91}}}},
        },
        [1442] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 1654,
        },
        [1447] = {
            [questKeys.objectives] = {{{4961,"Defeat Dashel Stonefist"}}},
        },
        [1448] = {
            [questKeys.triggerEnd] = {"Search for the Temple of Atal'Hakkar", {[zoneIDs.SWAMP_OF_SORROWS]={{70.2,45.2},{66.6,48.1},{73.6,48.1},{64.9,53.3},{75.4,53.3},{66.6,58.4},{73.6,58.4},{70.2,60.5}}}},
        },
        [1462] = {
            [questKeys.parentQuest] = 1521, -- #6723
            [questKeys.objectivesText] = {},
        },
        [1463] = {
            [questKeys.parentQuest] = 1518, -- #6723
            [questKeys.objectivesText] = {},
        },
        [1464] = {
            [questKeys.objectivesText] = {},
        },
        [1470] = {
            [questKeys.exclusiveTo] = {1485}, -- #999
        },
        [1471] = {
            [questKeys.exclusiveTo] = {1504}, -- #1542
            [questKeys.requiredSourceItems] = {},
        },
        [1472] = {
            [questKeys.exclusiveTo] = {},
        },
        [1473] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1501},
            [questKeys.breadcrumbs] = {1478},
        },
        [1474] = {
            [questKeys.exclusiveTo] = {1513},
            [questKeys.requiredSourceItems] = {},
        },
        [1477] = {
            [questKeys.breadcrumbForQuestId] = 1395, -- #1727
        },
        [1478] = {
            [questKeys.exclusiveTo] = {1506}, -- #1427
            [questKeys.breadcrumbForQuestId] = 1473,
        },
        [1479] = {
            [questKeys.triggerEnd] = {"Go to the bank in Darnassus, otherwise known as the Bough of the Eternals.", {[zoneIDs.DARNASSUS]={{41.31,43.54}}}},
        },
        [1480] = {
            [questKeys.startedBy] = {nil,nil,{20310}},
        },
        [1483] = {
            [questKeys.exclusiveTo] = {1093},
        },
        [1485] = {
            [questKeys.exclusiveTo] = {1470}, -- #999
        },
       [1498] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1505},
        },
        [1501] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1473},
            [questKeys.breadcrumbs] = {1506},
        },
        [1504] = {
            [questKeys.exclusiveTo] = {1471}, -- #1542
            [questKeys.requiredSourceItems] = {},
        },
        [1505] = {
            [questKeys.breadcrumbForQuestId] = 1498,
        },
        [1506] = {
            [questKeys.exclusiveTo] = {1478}, -- #1427
            [questKeys.breadcrumbForQuestId] = 1501,
        },
        [1507] = {
            [questKeys.exclusiveTo] = {},
        },
        [1513] = {
            [questKeys.exclusiveTo] = {1474},
            [questKeys.requiredSourceItems] = {},
        },
        [1516] = {
            [questKeys.exclusiveTo] = {1519}, -- #6723
        },
        [1517] = {
            [questKeys.preQuestSingle] = {1516,1519}, -- #6723
            [questKeys.childQuests] = {}, -- #6723
        },
        [1518] = {
            [questKeys.childQuests] = {1463}, -- #6723
        },
        [1519] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #6723
            [questKeys.exclusiveTo] = {1516}, -- #6723
        },
        [1520] = {
            [questKeys.preQuestSingle] = {1516,1519}, -- #6723
            [questKeys.childQuests] = {}, -- #6723
        },
        [1521] = {
            [questKeys.childQuests] = {1462}, -- #6723
        },
        [1522] = {
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [1523] = {
            [questKeys.startedBy] = {{5906}},
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [1524] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1522,1523,2983,2984},
        },
        [1528] = {
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [1529] = {
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [1530] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1528,1529,2985,2986},
        },
        [1558] = {
            [questKeys.triggerEnd] = {"Go to the top of the Stonewrought Dam in Loch Modan.", {[zoneIDs.LOCH_MODAN]={{47.63,14.33}}}},
        },
        [1559] = {
            [questKeys.preQuestSingle] = {705},
        },
        [1560] = {
            [questKeys.triggerEnd] = {"Lead Tooga to Torta", {[zoneIDs.TANARIS]={{66.56,25.65}}}},
        },
        [1579] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE]={{35.71,44.68}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Gaffer Jacks"),}},
        },
        [1580] = {
            [questKeys.requiredSkill] = {356,30},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE]={{50.7,23.8},{40,73.6},{44.3,74.4},{53.3,32.4},{43.3,80.6}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Electropellers"),}},
        },
        [1581] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1598] = {
            [questKeys.exclusiveTo] = {1599}, -- #999
        },
        [1599] = {
            [questKeys.exclusiveTo] = {1598}, -- #999
        },
        [1618] = {
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING, 60},
        },
        [1638] = {
            [questKeys.exclusiveTo] = {1666,1678,1680,1683,1686},
        },
        [1639] = {
            [questKeys.exclusiveTo] = {1678,1683},
            [questKeys.preQuestSingle] = {1638,1679,1684},
        },
        [1640] = {
            [questKeys.triggerEnd] = {"Beat Bartleby", {[zoneIDs.STORMWIND_CITY]={{73.7,36.85}}}},
            [questKeys.preQuestSingle] = {1638,1679,1684},
        },
        [1641] = { -- This is repeatable giving an item starting 1642
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000,3681},
        },
        [1642] = {
            [questKeys.exclusiveTo] = {1646,2997,2998,2999,3000,3681},
        },
        [1645] = { -- This is repeatable giving an item starting 1646
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000,3681},
        },
        [1646] = {
            [questKeys.exclusiveTo] = {1642,2997,2998,2999,3000,3681},
        },
        [1651] = {
            [questKeys.triggerEnd] = {"Protect Daphne Stilwell", {[zoneIDs.WESTFALL]={{42.15,88.44}}}},
        },
        [1654] = {
            [questKeys.childQuests] = {1442,1655},
        },
        [1655] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.parentQuest] = 1654,
        },
        [1661] = {
            [questKeys.exclusiveTo] = {4485,4486},
        },
        [1678] = {
            [questKeys.preQuestSingle] = {1638,1679,1684},
        },
        [1679] = {
            [questKeys.exclusiveTo] = {1639,1666,1680,1683,1686}, -- #1724
        },
        [1681] = {
            [questKeys.preQuestSingle] = {1678},
        },
        [1683] = {
            [questKeys.preQuestSingle] = {1638,1679,1684},
        },
        [1684] = {
            [questKeys.startedBy] = {{2151,3598,3657},nil,nil},
            [questKeys.exclusiveTo] = {1639,1666,1678,1686,1680},
        },
        [1685] = {
            [questKeys.breadcrumbForQuestId] = 1688, -- #7095
            [questKeys.exclusiveTo] = {},
        },
        [1687] = {
            [questKeys.triggerEnd] = {"Go to the Westfall Lighthouse.", {[zoneIDs.WESTFALL]={{30.41,85.61}}}},
        },
        [1688] = {
            [questKeys.breadcrumbs] = {1685,1715}, -- #7095
        },
        [1689] = {
            [questKeys.requiredSourceItems] = {},
        },
        [1698] = {
            [questKeys.startedBy] = {{5113,5479,7315}},
            [questKeys.breadcrumbForQuestId] = 1699,
        },
        [1699] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1698},
        },
        [1700] = {
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.breadcrumbForQuestId] = 1705, -- #1857
        },
        [1703] = {
            [questKeys.breadcrumbForQuestId] = 1710, -- #1857
        },
        [1704] = {
            [questKeys.breadcrumbForQuestId] = 1708, -- #1857
        },
        [1705] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1700}, -- #1857
        },
        [1708] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1704}, -- #1857
        },
        [1710] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1703}, -- #1857
        },
        [1715] = {
            [questKeys.nextQuestInChain] = 1688,
            [questKeys.breadcrumbForQuestId] = 1688, -- #7095
            [questKeys.exclusiveTo] = {},
        },
        [1716] = {
            [questKeys.breadcrumbs] = {1717},
        },
        [1717] = {
            [questKeys.breadcrumbForQuestId] = 1716,
        },
        [1718] = {
            [questKeys.startedBy] = {{3041,3354,4595,5113,5479},nil,nil}, -- #1034
        },
        [1739] = {
            [questKeys.requiredSourceItems] = {},
        },
        [1758] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1798},
        },
        [1789] = {
            [questKeys.exclusiveTo] = {1785},
        },
        [1790] = {
            [questKeys.exclusiveTo] = {1788},
        },
        [1793] = {
            [questKeys.exclusiveTo] = {1649},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [1794] = {
            [questKeys.startedBy] = {{6179},nil,nil},
            [questKeys.exclusiveTo] = {1649},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [1796] = {
            [questKeys.breadcrumbs] = {4736,4737,4738,4739},
        },
        [1798] = {
            [questKeys.breadcrumbForQuestId] = 1758,
        },
        [1799] = {
            [questKeys.breadcrumbs] = {4965,4967,4968,4969},
        },
        [1800] = {
            [questKeys.triggerEnd] = {"Go to the old Lordaeron Throne Room that lies just before descending into the Undercity.", {[zoneIDs.UNDERCITY]={{65.97,36.12}}}},
        },
        [1801] = {
            [questKeys.breadcrumbs] = {2996,3001},
        },
        [1818] = {
            [questKeys.breadcrumbForQuestId] = 1819,
        },
        [1819] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1818},
        },
        [1823] = {
            [questKeys.startedBy] = {{3041,3354,4595},nil,nil},
            [questKeys.breadcrumbForQuestId] = 1824,
        },
        [1824] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1823},
        },
        [1839] = {
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbForQuestId] = 1842,
        },
        [1840] = {
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbForQuestId] = 1844,
        },
        [1841] = {
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbForQuestId] = 1846,
        },
        [1842] = {
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbs] = {1839},
        },
        [1844] = {
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbs] = {1840},
        },
        [1846] = {
            [questKeys.preQuestSingle] = {1848},
            [questKeys.breadcrumbs] = {1841},
        },
        [1859] = {
            [questKeys.breadcrumbForQuestId] = 1963,
        },
        [1860] = { -- #1192
            [questKeys.breadcrumbForQuestId] = 1861,
            [questKeys.exclusiveTo] = {},
        },
        [1861] = { -- #1192
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1880},
            [questKeys.breadcrumbs] = {1860},
        },
        [1879] = { -- #1192
            [questKeys.breadcrumbForQuestId] = 1880,
            [questKeys.exclusiveTo] = {},
        },
        [1880] = { -- #1192
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1861},
            [questKeys.breadcrumbs] = {1879},
        },
        [1881] = {
            [questKeys.breadcrumbForQuestId] = 1882,
            [questKeys.exclusiveTo] = {},
        },
        [1882] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1884},
            [questKeys.breadcrumbs] = {1881},
        },
        [1883] = {
            [questKeys.breadcrumbForQuestId] = 1884,
            [questKeys.exclusiveTo] = {},
        },
        [1884] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {1882},
            [questKeys.breadcrumbs] = {1883},
        },
        [1885] = {
            [questKeys.breadcrumbForQuestId] = 1886,
        },
        [1886] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1885},
        },
        [1919] = { -- Report to Jennea
            [questKeys.startedBy] = {{328,1228,7312}},
            [questKeys.breadcrumbForQuestId] = 1920, -- #1328
        },
        [1920] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1919}, -- #1328
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Cantation of Manifestation to reveal Rift Spawn. Use Chest of Containment Coffers on stunned Rift Spawn"), 0, {{"monster", 6492}}}},
        },
        [1938] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1939},
        },
        [1939] = {
            [questKeys.startedBy] = {{5144,5497},nil,nil},
            [questKeys.breadcrumbForQuestId] = 1938,
        },
        [1943] = {
            [questKeys.breadcrumbForQuestId] = 1944, -- #2253
        },
        [1944] = {
            [questKeys.preQuestSingle] = {}, -- #2253
            [questKeys.breadcrumbs] = {1943},
        },
        [1948] = {
            [questKeys.preQuestSingle] = {1947},
        },
        [1950] = {
            [questKeys.objectives] = {{{6626,"Secret phrase found"}}},
        },
        [1954] = {
            [questKeys.preQuestSingle] = {},
        },
        [1955] = {
            [questKeys.triggerEnd] = {"Kill the Demon of the Orb", {[zoneIDs.DUSTWALLOW_MARSH]={{45.6,57.2}}}},
        },
        [1959] = {
            [questKeys.startedBy] = {{2128,3049,5880,7311},nil,nil},
            [questKeys.breadcrumbForQuestId] = 1960,
        },
        [1960] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1959},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Cantation of Manifestation to reveal Rift Spawn. Use Chest of Containment Coffers on stunned Rift Spawn"), 0, {{"monster", 6492}}}},
        },
        [1963] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1859},
        },
        [2038] = {
            [questKeys.breadcrumbs] = {2039},
        },
        [2039] = {
            [questKeys.breadcrumbForQuestId] = 2038,
        },
        [2040] = {
            [questKeys.breadcrumbs] = {2041}, -- #2068
        },
        [2041] = {
            [questKeys.breadcrumbForQuestId] = 2040, -- #2068
        },
        [2118] = {
            [questKeys.objectives] = {{{2164,"Rabid Thistle Bear Captured"}}},
        },
        [2201] = {
            [questKeys.childQuests] = {3375},
            [questKeys.requiredLevel] = 37, -- #2447
        },
        [2205] = {
            [questKeys.exclusiveTo] = {}, -- #1466
            [questKeys.breadcrumbForQuestId] = 2206,
            [questKeys.nextQuestInChain] = 2206,
        },
        [2206] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2205},
        },
        [2218] = {
            [questKeys.exclusiveTo] = {}, -- #1466
            [questKeys.breadcrumbForQuestId] = 2238,
        },
        [2238] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2218},
        },
        [2240]  = {
            [questKeys.triggerEnd] = { "Explore the Hidden Chamber", {[zoneIDs.BADLANDS]={{35.22,10.32}}}},
        },
        [2241] = {
            [questKeys.exclusiveTo] = {}, -- #1466
            [questKeys.breadcrumbForQuestId] = 2242,
            [questKeys.nextQuestInChain] = 2242,
        },
        [2242] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2241},
        },
        [2259] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbForQuestId] = 2260, -- #2476
            [questKeys.exclusiveTo] = {2281}, -- #1825
        },
        [2260] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2259}, -- #2476
            [questKeys.breadcrumbForQuestId] = 2281, -- #2476
            [questKeys.nextQuestInChain] = 2281,
        },
        [2278] = {
            [questKeys.objectives] = {{{7172,"Learn what lore that the stone watcher has to offer",Questie.ICON_TYPE_TALK}}},
        },
        [2281] = {
            [questKeys.preQuestSingle] = {}, -- #1825
            [questKeys.breadcrumbs] = {2260,2298,2300},
        },
        [2298] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2299}, -- #2476
            [questKeys.breadcrumbForQuestId] = 2281, -- #2476
            [questKeys.nextQuestInChain] = 2281,
        },
        [2299] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbForQuestId] = 2298, -- #2476
            [questKeys.exclusiveTo] = {2281}, -- #1817
        },
        [2300] = {
            [questKeys.preQuestSingle] = {}, -- #1825
            [questKeys.breadcrumbForQuestId] = 2281, -- #2476
        },
        [2318] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [2358] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2438] = {
            [questKeys.specialFlags] = 0,
        },
        [2460] = {
            [questKeys.triggerEnd] = {"Shattered Salute Performed", {[zoneIDs.ORGRIMMAR]={{43.11,53.48}}}},
        },
        [2480] = {
            [questKeys.triggerEnd] = {"Cure Completed",{[zoneIDs.HILLSBRAD_FOOTHILLS]={{61.57, 19.21}}}},
        },
        [2501] = {
            [questKeys.preQuestSingle] = {}, -- #1541
            [questKeys.preQuestGroup] = {2500,17}, -- #1541
        },
        [2520] = {
            [questKeys.triggerEnd] = {"Offer the sacrifice at the fountain", {[zoneIDs.DARNASSUS]={{38.63,85.99}}}},
        },
        [2561] = {
            [questKeys.objectives] = {{{7318,"Release Oben Rageclaw's spirit",Questie.ICON_TYPE_INTERACT}}},
        },
        [2608] = {
            [questKeys.triggerEnd] = {"Diagnosis Complete", {[zoneIDs.STORMWIND_CITY]={{78.04,59}}}},
        },
        [2742] = {
            [questKeys.triggerEnd] = {"Escort Rin'ji to safety", {[zoneIDs.THE_HINTERLANDS]={{34.58,56.33}}}},
        },
        [2744] = {
            [questKeys.objectives] = {{{7783,"Conversation with Loramus"}}},
        },
        [2755] = {
            [questKeys.objectives] = {{{7790,"Omosh Dance of Joy Learned"}}},
        },
        [2765] = {
            [questKeys.objectives] = {{{7802,"You Are The Big Winner"}}},
        },
        [2767] = {
            [questKeys.triggerEnd] = {"Escort OOX-22/FE to the dock along the Forgotten Coast", {[zoneIDs.FERALAS]={{45.63,43.39}}}},
        },
        [2769] = {
            [questKeys.breadcrumbForQuestId] = 2770, -- #2071
        },
        [2770] = {
            [questKeys.breadcrumbs] = {2769}, -- #2071
        },
        [2771] = {
            [questKeys.preQuestSingle] = {2764},
        },
        [2772] = {
            [questKeys.preQuestSingle] = {2764},
        },
        [2773] = {
            [questKeys.preQuestSingle] = {2764},
        },
        [2781] = {
            [questKeys.startedBy] = {nil,{142122,150075},nil}, -- #1081
        },
        [2784] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{7572},7572,"The Tale of Sorrow"}}},
        },
        [2801] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{7572},7572,"A Tale of Sorrow"}}},
        },
        [2841] = {
            [questKeys.exclusiveTo] = {2842},
            [questKeys.childQuests] = {},
        },
        [2842] = {
            [questKeys.requiredLevel] = 20,
            [questKeys.parentQuest] = 0,
        },
        [2843] = {
            [questKeys.triggerEnd] = {"Goblin Transponder", {[zoneIDs.STRANGLETHORN_VALE]={{27.56,77.42}}}},
        },
        [2845] = {
            [questKeys.triggerEnd] = {"Take Shay Leafrunner to Rockbiter's camp", {[zoneIDs.FERALAS]={{42.33,21.85}}}},
        },
        [2846] = {
            [questKeys.breadcrumbs] = {2861},
        },
        [2847] = {
            [questKeys.requiredSkill] = {profKeys.LEATHERWORKING,200},
        },
        [2851] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2848,2849,2850}, -- #7161
        },
        [2852] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2848,2849,2850}, -- #7161
        },
        [2853] = {
             [questKeys.preQuestGroup] = {2851,2852}, -- #7161
        },
        [2854] = {
            [questKeys.requiredSkill] = {profKeys.LEATHERWORKING,200},
        },
        [2858] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2855,2856,2857}, -- #7161
        },
        [2859] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {2855,2856,2857}, -- #7161
        },
        [2860] = {
             [questKeys.preQuestGroup] = {2858,2859}, -- #7161
        },
        [2861] = {
            [questKeys.startedBy] = {{4568,5144,5497,5885},nil,nil}, -- #1152
            [questKeys.breadcrumbForQuestId] = 2846,
        },
        [2864] = {
            [questKeys.breadcrumbForQuestId] = 2865, -- #2072
        },
        [2865] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2864}, -- #2072
        },
        [2872] = {
            [questKeys.breadcrumbForQuestId] = 2873, -- #1566
        },
        [2873] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2872}, -- #1566
        },
        [2875] = {
            [questKeys.startedBy] = {nil,{142122,150075},nil},
        },
        [2882] = {
            [questKeys.zoneOrSort] = 440, -- #1780
        },
        [2904] = {
            [questKeys.triggerEnd] = {"Kernobee Rescue", {[zoneIDs.GNOMEREGAN]={{-1,-1}}}},
        },
        [2922] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {2923}, -- #2067
        },
        [2923] = {
            [questKeys.breadcrumbForQuestId] = 2922, -- #2067
        },
        [2924] = {
            [questKeys.breadcrumbs] = {2925},
        },
        [2925] = {
            [questKeys.breadcrumbForQuestId] = 2924,
        },
        [2926] = { -- Gnogaine
            [questKeys.preQuestSingle] = {}, -- #2389
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Empty Leaden Collection Phial."), 0, {{"monster", 6213},{"monster", 6329}}}},
        },
        [2927] = {
            [questKeys.nextQuestInChain] = 2926,
        },
        [2930] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 1: obtain the Yellow Punch Card. You need the White Punch Card."), 0, {{"object", 142345}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 2: obtain the Blue Punch Card. You need the Yellow Punch Card."), 0, {{"object", 142475}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 3: obtain the Red Punch Card. You need the Blue Punch Card."), 0, {{"object", 142476}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Step 4: obtain the Prismatic Punch Card. You need the Red Punch Card."), 0, {{"object", 142696}}},
            },
            [questKeys.requiredSourceItems] = {9279,9280,9281,9282},
            [questKeys.breadcrumbs] = {2931},
        },
        [2931] = {
            [questKeys.breadcrumbForQuestId] = 2930,
        },
        [2932] = {
            [questKeys.triggerEnd] = {"Place the grim message.", {[zoneIDs.THE_HINTERLANDS]={{23.41,58.06}}}},
        },
        [2936] = {
            [questKeys.triggerEnd] = {"Find the Spider God's Name", {[zoneIDs.TANARIS]={{38.73,19.88}}}},
        },
        [2943] = { -- Return to Troyas
            [questKeys.nextQuestInChain] = 2879,
        },
        [2951] = {
            [questKeys.exclusiveTo] = {4601,4602},
        },
        [2952] = {
            [questKeys.exclusiveTo] = {4605,4606},
            [questKeys.preQuestSingle] = {2951,4601,4602},
        },
        [2953] = {
            [questKeys.exclusiveTo] = {4603,4604},
            [questKeys.preQuestSingle] = {2952,4605,4606},
        },
        [2954] = {
            [questKeys.triggerEnd] = {"Learn the purpose of the Stone Watcher of Norgannon", {[zoneIDs.TANARIS]={{37.66,81.42}}}},
        },
        [2969] = {
            [questKeys.triggerEnd] = {"Save at least 6 Sprite Darters from capture", {[zoneIDs.FERALAS]={{67.27,46.67}}}},
        },
        [2975] = {
            [questKeys.breadcrumbs] = {2981},
        },
        [2981] = {
            [questKeys.breadcrumbForQuestId] = 2975,
        },
        [2983] = {
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [2984] = {
            [questKeys.breadcrumbForQuestId] = 1524,
        },
        [2985] = {
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [2986] = {
            [questKeys.breadcrumbForQuestId] = 1530,
        },
        [2992] = {
            [questKeys.triggerEnd] = {"Wait for Grimshade to finish", {[zoneIDs.BLASTED_LANDS]={{66.99,19.41}}}},
        },
        [2994] = {
            [questKeys.questLevel] = 51, -- #1129
        },
        [2996] = {
            [questKeys.nextQuestInChain] = 1801,
            [questKeys.breadcrumbForQuestId] = 1801,
        },
        [2997] = {
            [questKeys.exclusiveTo] = {1642,1646,2998,2999,3000,3681},
        },
        [2998] = {
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,3000,3681},
        },
        [2999] = {
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,3000,3681},
        },
        [3000] = {
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3681},
        },
        [3001] = {
            [questKeys.nextQuestInChain] = 1801,
            [questKeys.breadcrumbForQuestId] = 1801,
        },
        [3090] = {
            [questKeys.requiredRaces] = raceIDs.ORC, -- #2399
        },
        [3128] = {
            [questKeys.preQuestSingle] = {3122},
        },
        [3141] = {
            [questKeys.objectives] = {{{7783,"Loramus' Story"}}},
        },
        [3182] = { -- Proof of Deed
            [questKeys.nextQuestInChain] = 3201,
        },
        [3321] = {
            [questKeys.objectives] = {{{7804,"Watch Trenton Work"}}},
        },
        [3367] = {
            [questKeys.triggerEnd] = {"Dorius Escort", {[zoneIDs.SEARING_GORGE]={{74.47,19.44}}}},
        },
        [3375] = {
            [questKeys.parentQuest] = 2201,
        },
        [3377] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{8436},8436,"Zamael Story"}}},
        },
        [3382] = {
            [questKeys.triggerEnd] = {"Protect Captain Vanessa Beltis from the naga attack", {[zoneIDs.AZSHARA]={{52.86,87.77}}}},
        },
        [3385] = {
            [questKeys.requiredSkill] = {197,226}, -- You need to be an Artisan for this quest -- this needs proper fix
        },
        [3441] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{8479},8479,"Kalaran Story"}}},
        },
        [3449] = {
            [questKeys.childQuests] = {3483}, -- #1008
        },
        [3453] = {
            [questKeys.objectives] = {{{8479,"Torch Creation"}}},
        },
        [3454] = { -- The Torch of Retribution
            [questKeys.nextQuestInChain] = 3462,
        },
        [3483] = {
            [questKeys.parentQuest] = 3449, -- #1008
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1131
        },
        [3520] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Vale Screechers and use Yeh'kinya's Bramble on their corpse."), 0, {{"monster", 5307},{"monster", 5308}}}},
        },
        [3525] = {
            [questKeys.triggerEnd] = {"Protect Belnistrasz while he performs the ritual to shut down the idol", {[zoneIDs.THE_BARRENS]={{50.86,92.87}}}},
            [questKeys.finishedBy] = {nil,{152097}},
        },
        [3526] = { -- Goblin Engineering (Undercity)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3633,3642},
        },
        [3625] = {
            [questKeys.objectives] = {{{7802,"Weaponry Creation"}}},
        },
        [3628] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Teleport to the top of the mountain."), 0, {{"object", 153203},{"monster", 8816}}},
                                          {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Ward of the Defiler to summon Razelikh."), 0, {{"object", 153205}}},
			},
        },
        [3629] = { -- Goblin Engineering (Stormwind)
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3633,3640,4181},
        },
        [3630] = { -- Gnome Engineering (Stormwind)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3632,3634,3638},
        },
        [3632] = { -- Gnome Engineering (Ironforge)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3630,3634,3638},
        },
        [3633] = { -- Goblin Engineering (Ratchet Neutral)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3526,3629,3640,3642,4181},
        },
        [3634] = { -- Gnome Engineering (Ratchet Alliance)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3630,3632,3638}
        },
        [3635] = { -- Gnome Engineering (Undercity)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3637,3638},
        },
        [3637] = { -- Gnome Engineering (Ratchet Horde)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3635,3638},
        },
        [3639] = {
            [questKeys.exclusiveTo] = {3641,3643},
        },
        [3641] = {
            [questKeys.exclusiveTo] = {3639},
        },
        [3643] = {
            [questKeys.exclusiveTo] = {3639},
        },
        [3644] = {
            [questKeys.preQuestSingle] = {3639,3641,3643},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GOBLIN,
        },
        [3645] = {
            [questKeys.preQuestSingle] = {3639,3641,3643},
            [questKeys.startedBy] = {{7406},nil,nil},
            [questKeys.finishedBy] = {{7406},nil},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GNOMISH,
        },
        [3646] = {
            [questKeys.preQuestSingle] = {3639,3641,3643},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GOBLIN,
        },
        [3647] = {
            [questKeys.preQuestSingle] = {3639,3641,3643},
            [questKeys.startedBy] = {{7944},nil,nil},
            [questKeys.finishedBy] = {{7944},nil},
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING_GNOMISH,
        },
        [3681] = {
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000},
        },
        [3702] = {
            [questKeys.objectives] = {{{8879,"Story of Thaurissan"}}},
        },
        [3761] = {
            [questKeys.breadcrumbs] = {936,3762,3784},
        },
        [3762] = {
            [questKeys.breadcrumbForQuestId] = 3761,
        },
        [3763] = {
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [3764] = {
            [questKeys.breadcrumbs] = {3763,3789,3790},
        },
        [3765] = {
            [questKeys.breadcrumbForQuestId] = 1275, -- #745
            [questKeys.requiredLevel] = 18,
        },
        [3784] = {
            [questKeys.breadcrumbForQuestId] = 3761,
        },
        [3785] = {
            [questKeys.requiredSourceItems] = {11018,11022},
        },
        [3786] = {
            [questKeys.requiredSourceItems] = {11018,11022},
        },
        [3787] = {
            [questKeys.preQuestSingle] = {3781},
            [questKeys.breadcrumbForQuestId] = 3791,
        },
        [3788] = {
            [questKeys.preQuestSingle] = {3781},
            [questKeys.breadcrumbForQuestId] = 3791,
        },
        [3789] = {
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [3790] = {
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [3791] = {
            [questKeys.requiredSourceItems] = {11018,11022},
            [questKeys.preQuestSingle] = {3781}, -- #7241
            [questKeys.breadcrumbs] = {3787,3788}, -- #885
        },
        [3903] = {
            [questKeys.preQuestSingle] = {18},
        },
        [3909] = {
            [questKeys.requiredSourceItems] = {11141,11242},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Bait in front of Miblon Snarltooth."), 0, {{"monster", 9467}}}},
        },
        [3982] = {
            [questKeys.objectives] = {{{9020,"Survive the Onslaught"}}},
        },
        [4001] = {
            [questKeys.objectives] = {{{9021,"Information Gathered from Kharan"}}},
        },
        [4021] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Hold off Kolkar invaders until Warlord Krom'zar spawns and then loot the banner spawned on his corpse."), 0, {{"monster", 9456}}}},
        },
        [4022] = {
            [questKeys.objectives] = {nil,nil,{{10575}},nil,{{{9459},9459,"Proof Presented"}}},
            [questKeys.objectivesText] = {"Show Cyrus Therepentous the Black Dragonflight Molt you received from Kalaran Windblade."},
        },
        [4023] = {
            [questKeys.exclusiveTo] = {3481,4022},
        },
        [4024] = {
            [questKeys.preQuestGroup] = {4022,4023}, -- it has to be preQuestGroup or it shows prematurely
            [questKeys.preQuestSingle] = {},
            [questKeys.objectivesText] = {"Travel to Blackrock Depths and slay Bael'Gar.","","You only know that the giant resides inside Blackrock Depths. Remember to use the Altered Black Dragonflight Molt on Bael'Gar's remains to capture the Fiery Essence.","","Return the Encased Fiery Essence to Cyrus Therepentous."},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Altered Black Dragonflight Molt on Bael'gar's corpse."), 0, {{"monster", 9016}}}},
        },
        [4083] = {
            [questKeys.requiredSkill] = {186,230}, -- #1293
        },
        [4084] = {
            [questKeys.questLevel] = 54, -- #1495
        },
        -- Salve via Hunting/Mining/Gathering/Skinning/Disenchanting repeatable quests
        -- Alliance
        [4103] = { -- Salve via Hunting
            [questKeys.preQuestSingle] = {5882},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [4104] = { -- Salve via Mining
            [questKeys.preQuestSingle] = {5883},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [4105] = { -- Salve via Gathering
            [questKeys.preQuestSingle] = {5884},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [4106] = { -- Salve via Skinning
            [questKeys.preQuestSingle] = {5885},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [4107] = { -- Salve via Disenchanting
            [questKeys.preQuestSingle] = {5886},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        -- Horde
        [4108] = { -- Salve via Hunting
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887},
        },
        [4109] = { -- Salve via Mining
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5888},
        },
        [4110] = { -- Salve via Gathering
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5889},
        },
        [4111] = { -- Salve via Skinning
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5890},
        },
        [4112] = { -- Salve via Disenchanting
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5891},
        },
        -----------------------
        [4121] = {
            [questKeys.triggerEnd] = {"Prisoner Transport", {[zoneIDs.BURNING_STEPPES]={{25.73,27.1}}}},
        },
        [4122] = {
            [questKeys.preQuestSingle] = {4082}, -- #1349
        },
        [4123] = {
            [questKeys.requiredSourceItems] = {11078},
        },
        [4126] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4128},
        },
        [4128] = {
            [questKeys.breadcrumbForQuestId] = 4126,
        },
        [4133] = {
            [questKeys.breadcrumbForQuestId] = 4134, -- #1859
        },
        [4134] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4133}, -- #1859
        },
        [4136] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4324}, -- #4459
        },
        [4144] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1590
        },
        [4146] = { -- Zapper Fuel
            [questKeys.zoneOrSort] = zoneIDs.UN_GORO_CRATER,
        },
        [4181] = { -- Goblin Engineering (Ironforge)
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING, -- engineering skill, no specializations
            [questKeys.exclusiveTo] = {3629,3633,3640},
        },
        [4185] = {
            [questKeys.objectives] = {{{1749,"Advice from Lady Prestor"}}},
        },
        [4224] = {
            [questKeys.objectives] = {{{9563,"Ragged John's Story",Questie.ICON_TYPE_TALK}}},
        },
        [4245] = {
            [questKeys.triggerEnd] = {"Protect A-Me 01 until you reach Karna Remtravel",{[zoneIDs.UN_GORO_CRATER]={{46.43, 13.78}}}},
        },
        [4261] = {
            [questKeys.triggerEnd] = {"Help Arei get to Safety", {[zoneIDs.FELWOOD]={{49.42,14.54}}}},
        },
        [4265] = {
            [questKeys.triggerEnd] = {"Free Raschal.", {[zoneIDs.FERALAS]={{72.13,63.84}}}},
        },
        [4267] = { -- Rise of the Silithid
            [questKeys.nextQuestInChain] = 4493,
        },
        [4285] = {
            [questKeys.triggerEnd] = {"Discover and examine the Northern Crystal Pylon",{[zoneIDs.UN_GORO_CRATER]={{56,12}}}},
        },
        [4287] = {
            [questKeys.triggerEnd] = {"Discover and examine the Eastern Crystal Pylon",{[zoneIDs.UN_GORO_CRATER]={{77,50}}}},
        },
        [4288] = {
            [questKeys.triggerEnd] = {"Discover and examine the Western Crystal Pylon",{[zoneIDs.UN_GORO_CRATER]={{23,59}}}},
        },
        [4295] = {
            [questKeys.requiredLevel] = 42,
        },
        [4322] = {
            [questKeys.triggerEnd] = {"Jail Break!", {[zoneIDs.BLACKROCK_DEPTHS]={{-1,-1}}}},
        },
        [4324] = {
            [questKeys.breadcrumbForQuestId] = 4136, -- #4459
        },
        [4342] = {
            [questKeys.objectives] = {{{9021,"Kharan's Tale"}}},
            [questKeys.preQuestSingle] = {4341},
        },
        [4361] = {
            [questKeys.preQuestSingle] = {4342},
        },
        [4485] = {
            [questKeys.startedBy] = {{6179},nil,nil},
            [questKeys.exclusiveTo] = {1661,4486},
        },
        [4486] = {
            [questKeys.exclusiveTo] = {1661,4485},
        },
        [4490] = {
            [questKeys.preQuestSingle] = {3631,4487,4488,4489},
        },
        [4491] = {
            [questKeys.triggerEnd] = {"Escort Ringo to Spraggle Frock at Marshal's Refuge", {[zoneIDs.UN_GORO_CRATER]={{43.71,8.29}}}},
        },
        [4492] = {
            [questKeys.triggerEnd] = {"Escort Ringo to Spraggle Frock at Marshal's Refuge", {[zoneIDs.UN_GORO_CRATER]={{43.71,8.29}}}}, -- needed for deDE blizzard spaghetti #2432
        },
        [4493] = { -- March of the Silithid
            [questKeys.preQuestSingle] = {162,4267},
        },
        [4494] = {
            [questKeys.preQuestSingle] = {7732},
        },
        [4495] = {
            [questKeys.nextQuestInChain] = 3519,
        },
        [4496] = {
            [questKeys.preQuestSingle] = {4493,4494},
        },
        [4505] = {
            [questKeys.breadcrumbs] = {6605}, -- #1859
        },
        [4506] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Release the kitten near the Jadefire Satyrs' corrupted moonwell."), 0, {{"object", 148501}}}},
            [questKeys.triggerEnd] = {"Return the corrupted cat to Winna Hazzard", {[zoneIDs.FELWOOD]={{34.26,52.32}}}},
        },
        [4507] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Gorishi Queen Lure."), 0, {{"object", 174792}}}},
        },
        [4512] = {
            [questKeys.requiredSourceItems] = {11914,11948},
        },
        [4513] = {
            [questKeys.requiredSourceItems] = {11953},
        },
        [4542] = {
            [questKeys.breadcrumbForQuestId] = 4841,
        },
        [4581] = {
            [questKeys.nextQuestInChain] = 1011,
            [questKeys.breadcrumbForQuestId] = 1011,
        },
        [4601] = {
            [questKeys.exclusiveTo] = {2951,4602},
        },
        [4602] = {
            [questKeys.exclusiveTo] = {2951,4601},
        },
        [4603] = {
            [questKeys.exclusiveTo] = {2953,4604},
            [questKeys.preQuestSingle] = {2952,4605,4606},
        },
        [4604] = {
            [questKeys.exclusiveTo] = {2953,4603},
            [questKeys.preQuestSingle] = {2955,4605,4606},
        },
        [4605] = {
            [questKeys.exclusiveTo] = {2952,4606},
            [questKeys.preQuestSingle] = {2951,4601,4602},
        },
        [4606] = {
            [questKeys.exclusiveTo] = {2952,4605},
            [questKeys.preQuestSingle] = {2951,4601,4602},
        },
        [4621] = {
            [questKeys.preQuestSingle] = {1036},
            [questKeys.requiredMinRep] = {87,3000},
            [questKeys.requiredMaxRep] = {21,-5999},
        },
        [4641] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #877
            [questKeys.breadcrumbForQuestId] = 788, -- #1956
        },
        [4726] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Draco-Incarcinatrix 900 and defeat the dragonkin."), 0, {{"monster",7047},{"monster",7048}},{"monster",7049}}},
        },
        [4729] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Empty Worg Pup Cage to capture it."), 0, {{"monster", 10221}}}},
        },
        [4734] = {
            [questKeys.objectives] = {nil,{{175124,"Test the Eggscilliscope Prototype"}}},
            [questKeys.breadcrumbs] = {4907},
        },
        [4735] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Collect eggs using the Collectronic Module."), 0, {{"object", 175124}}}},
        },
        [4736] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4737] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4738] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4739] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1796,
        },
        [4742] = {
            [questKeys.startedBy] = {{10299}},
            [questKeys.finishedBy] = {{10299}},
        },
        [4743] = {
            [questKeys.requiredSourceItems] = {12300,12323},
            [questKeys.startedBy] = {{10299}},
            [questKeys.finishedBy] = {{10299}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Beat Emberstrife till his will is broken, then place the Unforged Seal of Ascension before him and use the Orb of Draconic Energy."), 0, {{"monster", 10321}}},
			                               {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Flames of the Black Flight over it to create the Seal."), 0, {{"object", 175321}}},
			},
        },
        [4763] = {
            [questKeys.requiredSourceItems] = {12341,12342,12343,12347}, -- #798
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Xabraxxis once you have the required items from the Blackwood Stores."), 0, {{"object", 175338}}}},
        },
        [4764] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4766}, -- #1916
        },
        [4766] = {
            [questKeys.breadcrumbForQuestId] = 4764 -- #1916
        },
        [4768] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4769}, -- #1859
        },
        [4769] = {
            [questKeys.breadcrumbForQuestId] = 4768, -- #1859
        },
        [4770] = {
            [questKeys.triggerEnd] = {"Escort Pao'ka from Highperch", {[zoneIDs.THOUSAND_NEEDLES]={{15.15,32.65}}}},
        },
        [4771] = {
            [questKeys.triggerEnd] = {"Place Dawn's Gambit",{[zoneIDs.SCHOLOMANCE]={{-1,-1}}}},
        },
        [4784] = {
            [questKeys.childQuests] = {4785}, -- #1367
        },
        [4785] = {
            [questKeys.preQuestSingle] = {}, -- #1367
            [questKeys.parentQuest] = 4784, -- #1367
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1367
        },
        [4786] = {
            [questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[zoneIDs.THE_BARRENS]={{62.52,35.47}}}},
        },
        [4811] = {
            [questKeys.triggerEnd] = {"Locate the large, red crystal on Darkshore's eastern mountain range",{[zoneIDs.DARKSHORE]={{47.24,48.68}}}}, -- #1373
        },
        [4841] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {4542},
        },
        [4822] = {
            [questKeys.objectivesText] = {"Get some Strawberry Ice Cream for your ward. The lad seems to prefer Tigule's brand ice cream."}, -- human orphan
            [questKeys.inGroupWith] = nil,
            [questKeys.preQuestGroup] = {1479,1558,1687},
            [questKeys.childQuests] = {},
        },
        [4861] = {
            [questKeys.breadcrumbs] = {6604},
        },
        [4866] = {
            [questKeys.objectives] = {{{9563,"Milked"}}},
        },
        [4867] = {
            [questKeys.requiredSourceItems] = {12533,12534},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Combine Omokk's Head with the Roughshod Pike."),0,{{"object", 175621}}},
                                           {nil, Questie.ICON_TYPE_OBJECT, l10n("Use it to instantly kill one nearby ogre."),0,{{"object", 175584}}},
            },
        },
        [4882] = {
            [questKeys.preQuestSingle] = {4741},
        },
        [4901] = {
            [questKeys.triggerEnd] = {"Discover the secret of the Altar of Elune", {[zoneIDs.WINTERSPRING]={{64.85,63.73}}}},
        },
        [4904] = {
            [questKeys.triggerEnd] = {"Escort Lakota Windsong from the Darkcloud Pinnacle.", {[zoneIDs.THOUSAND_NEEDLES]={{30.93,37.12}}}},
        },
        [4907] = {
            [questKeys.breadcrumbForQuestId] = 4734,
        },
        [4941] = {
            [questKeys.triggerEnd] = {"Council with Eitrigg.", {[zoneIDs.ORGRIMMAR]={{34.14,39.26}}}},
        },
        [4964] = {
            [questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[zoneIDs.THE_BARRENS]={{62.52,35.47}}}},
        },
        [4965] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4966] = {
            [questKeys.triggerEnd] = {"Protect Kanati Greycloud", {[zoneIDs.THOUSAND_NEEDLES]={{21.38,31.98}}}},
        },
        [4967] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4968] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4969] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.breadcrumbForQuestId] = 1799,
        },
        [4975] = {
            [questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[zoneIDs.THE_BARRENS]={{62.52,35.47}}}},
        },
        [5041] = {
            [questKeys.preQuestSingle] = {},
        },
        [5047] = {
            [questKeys.name] = "Pip Quickwit, At Your Service!",
        },
        [5056] = {
            [questKeys.requiredSourceItems] = {12733},
        },
        [5057] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {},
        },
        [5059] = {
            [questKeys.preQuestSingle] = {5058}, -- #922
        },
        [5060] = {
            [questKeys.preQuestSingle] = {5058}, -- #922
        },
        [5063] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1335
        },
        [5067] = { -- Leggings of Arcana
            [questKeys.questLevel] = 60,
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1335
        },
        [5066] = {
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [5068] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1335
        },
        [5082] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {6603}, -- #1824
        },
        [5088] = {
            [questKeys.objectives] = {nil,{{175944}},{{12925}}},
        },
        [5090] = {
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [5091] = {
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [5092] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5066,5090,5091},
        },
        [5093] = {
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [5094] = {
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [5095] = {
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [5096] = {
            [questKeys.triggerEnd] = {"Destroy the command tent and plant the Scourge banner in the camp", {[zoneIDs.WESTERN_PLAGUELANDS]={{40.72,52.04}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5093,5094,5095},
        },
        [5103] = {
            [questKeys.requiredLevel] = 55,
            [questKeys.requiredSourceItems] = {12812},
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,270},
        },
        [5122] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1140
        },
        [5124] = {
            [questKeys.requiredSkill] = {164,275},
        },
        [5126] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.SHAMAN,
            [questKeys.objectives] = {{{10918,"Listen to Lorax's Tale"}}},
            [questKeys.zoneOrSort] = sortKeys.BLACKSMITHING,
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,270},
        },
        [5127] = {
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,270},
        },
        [5143] = {
            [questKeys.preQuestSingle] = {2853},
        },
        [5148] = {
            [questKeys.preQuestSingle] = {2860},
        },
        [5149] = {
            [questKeys.preQuestSingle] = {},
        },
        [5156] = {
            [questKeys.triggerEnd] = {"Explore the craters in Shatter Scar Vale", {[zoneIDs.FELWOOD]={{41.03,41.96}}}},
        },
        [5203] = {
            [questKeys.triggerEnd] = {"Protect Arko'narin out of Shadow Hold", {[zoneIDs.FELWOOD]={{35.45,59.06}}}},
        },
        [5211] = {
            [questKeys.preQuestSingle] = {}, -- #983
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay ghouls to free Darrowshire spirits"), 0, {{"monster", 8530}, {"monster", 8531}, {"monster", 8532}}}},
            [questKeys.objectives] = {{{11064,nil,Questie.ICON_TYPE_TALK}}},
        },
        [5214] = {
            [questKeys.name] = "The Great Ezra Grimm",
        },
        [5218] = {
            [questKeys.preQuestSingle] = {5217,5230},
        },
        [5221] = {
            [questKeys.preQuestSingle] = {5220,5232},
        },
        [5224] = {
            [questKeys.preQuestSingle] = {5223,5234},
        },
        [5227] = {
            [questKeys.preQuestSingle] = {5226,5236},
        },
        [5234] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [5237] = {
            [questKeys.startedBy] = {{10838},nil,nil},
            [questKeys.finishedBy] = {{10838},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {5226},
        },
        [5238] = {
            [questKeys.startedBy] = {{10837},nil,nil},
            [questKeys.finishedBy] = {{10837},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {5236},
        },
        [5244] = {
            [questKeys.breadcrumbs] = {5249,5250},
        },
        [5249] = {
            [questKeys.breadcrumbForQuestId] = 5244,
        },
        [5250] = {
            [questKeys.breadcrumbForQuestId] = 5244,
        },
        [5261] = {
            [questKeys.breadcrumbForQuestId] = 33, -- #1726
        },
        [5305] = {
            [questKeys.exclusiveTo] = {8869},
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5306] = {
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5307] = {
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5321] = {
            [questKeys.triggerEnd] = {"Escort Kerlonian Evershade to Maestra's Post", {[zoneIDs.ASHENVALE]={{26.77,36.91}}}},
        },
        [5402] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5403] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5404] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5405] = {
            [questKeys.startedBy] = {{11039},nil,nil},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5406] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5407] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5408] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5421] = {
            [questKeys.questLevel] = 25,
        },
        [5503] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.startedBy] = {{10839},nil,nil},
        },
        [5508] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
        },
        [5509] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
        },
        [5510] = {
            [questKeys.preQuestSingle] = {5401,5503,5405},
        },
        [5526] = {
            [questKeys.zoneOrSort] = zoneIDs.MOONGLADE,
            [questKeys.requiredSourceItems] = {18501},
        },
        [5561] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4700,4701,4702},4700,"Kodos Tamed",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.DESOLACE]={{60.58,62}}}, Questie.ICON_TYPE_EVENT, l10n("Lure the Kodos to Smeed Scrabblescrew.")}},
        },
        [5621] = { -- Garments of the Moon
            [questKeys.objectives] = {{{12429,"Heal and fortify Sentinel Shaya",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5622},
        },
        [5622] = {
            [questKeys.breadcrumbForQuestId] = 5621,
        },
        [5623] = {
            [questKeys.breadcrumbForQuestId] = 5624,
        },
        [5624] = { -- Garments of the Light
            [questKeys.objectives] = {{{12423,"Heal and fortify Guard Roberts",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5623},
        },
        [5625] = { -- Garments of the Light
            [questKeys.objectives] = {{{12427,"Heal and fortify Mountaineer Dolf",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5626},
        },
        [5626] = {
            [questKeys.breadcrumbForQuestId] = 5625,
        },
        [5634] = {
            [questKeys.startedBy] = {{376},nil,nil},
            [questKeys.objectivesText] = {},
            [questKeys.exclusiveTo] = {5635,5636,5637,5638,5639,5640},
        },
        [5635] = {
            [questKeys.startedBy] = {{377},nil,nil},
            [questKeys.exclusiveTo] = {5634,5636,5637,5638,5639,5640},
        },
        [5636] = {
            [questKeys.exclusiveTo] = {5634,5635,5637,5638,5639,5640},
        },
        [5637] = {
            [questKeys.startedBy] = {{1226},nil,nil},
            [questKeys.exclusiveTo] = {5634,5635,5636,5638,5639,5640},
        },
        [5638] = {
            [questKeys.exclusiveTo] = {5634,5635,5636,5637,5639,5640},
        },
        [5639] = { -- Desperate Prayer (Ironforge)
            [questKeys.exclusiveTo] = {5634,5635,5636,5637,5638,5640},
        },
        [5640] = {
            [questKeys.name] = "Desperate Prayer",
            [questKeys.startedBy] = {{11401},nil,nil},
            [questKeys.finishedBy] = {{376},nil},
            [questKeys.requiredLevel] = 10,
            [questKeys.questLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.HUMAN + raceIDs.DWARF,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectivesText] = {"Speak to High Priestess Laurena in Stormwind."},
            [questKeys.exclusiveTo] = {5634,5635,5636,5637,5638,5639},
            [questKeys.zoneOrSort] = sortKeys.PRIEST,
        },
        [5641] = { -- Fear Ward (Ironforge)
            [questKeys.startedBy] = {{11406},nil,nil},
            [questKeys.objectivesText] = {},
        },
        [5643] = { -- Shadowguard (Undercity)
            [questKeys.startedBy] = {{4606},nil,nil},
        },
        [5644] = { -- Devouring Plague (Thunder Bluff)
            [questKeys.startedBy] = {{3044},nil,nil},
        },
        [5645] = { -- Fear Ward (Stormwind)
            [questKeys.startedBy] = {{376},nil,nil},
        },
        [5646] = { -- Devouring Plague (Orgrimmar)
            [questKeys.startedBy] = {{6018},nil,nil},
        },
        [5647] = {
            [questKeys.startedBy] = {{11401},nil,nil}, -- #2424
        },
        [5648] = { -- Garments of Spirituality
            [questKeys.objectives] = {{{12427,"Heal and fortify Grunt Kor'ja",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5649},
        },
        [5649] = {
            [questKeys.breadcrumbForQuestId] = 5648,
        },
        [5650] = { -- Garments of Darkness
            [questKeys.objectives] = {{{12428,"Heal and fortify Deathguard Kel",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {5651},
        },
        [5651] = {
            [questKeys.breadcrumbForQuestId] = 5650,
        },
        [5652] = { -- Hex of Weakness (Orgrimmar)
            [questKeys.objectivesText] = {},
        },
        [5654] = { -- Hex of Weakness (Durotar)
            [questKeys.startedBy] = {{3706},nil,nil},
        },
        [5655] = { -- Hex of Weakness (Mulgore)
            [questKeys.startedBy] = {{11407},nil,nil},
        },
        [5656] = { -- Hex of Weakness (Thunder Bluff)
            [questKeys.startedBy] = {{3044},nil,nil},
        },
        [5657] = { -- Hex of Weakness (Undercity)
            [questKeys.startedBy] = {{4606},nil,nil},
        },
        [5658] = { -- #7083 and #1603 Touch of Weakness (Undercity)
            [questKeys.startedBy] = {{4606},nil,nil},
            [questKeys.objectivesText] = {},
        },
        [5661] = { -- #7083 and #1603 Touch of Weakness (Mulgore)
            [questKeys.startedBy] = {{11407},nil,nil},
        },
        [5663] = { -- #7083 and #1603 Touch of Weakness (Thunder Bluff)
            [questKeys.startedBy] = {{3044},nil,nil},
        },
        [5672] = { -- Elune's Grace (Darnassus)
            [questKeys.startedBy] = {{11401},nil,nil},
            [questKeys.objectivesText] = {},
        },
        [5676] = { -- Feedback (Stormwind)
            [questKeys.startedBy] = {{376},nil,nil},
            [questKeys.exclusiveTo] = {5677,5678},
            [questKeys.objectivesText] = {},
        },
        [5677] = { -- Feedback (Ironforge)
            [questKeys.exclusiveTo] = {5676,5678},
        },
        [5678] = { -- Feedback (Darnassus)
            [questKeys.name] = "Arcane Feedback",
            [questKeys.startedBy] = {{11401},nil,nil},
            [questKeys.finishedBy] = {{376},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectivesText] = {"Speak to High Priestess Laurena in Stormwind."},
            [questKeys.exclusiveTo] = {5676,5677},
            [questKeys.zoneOrSort] = sortKeys.PRIEST,
        },
        [5679] = { -- Devouring Plague (Undercity)
            [questKeys.startedBy] = {{4606},nil,nil},
            [questKeys.objectivesText] = {},
        },
        [5680] = { -- Shadowguard (Orgrimmar)
            [questKeys.startedBy] = {{6018},nil,nil},
            [questKeys.objectivesText] = {},
        },
        [5713] = {
            [questKeys.triggerEnd] = {"Protect Aynasha", {[zoneIDs.DARKSHORE]={{45.87,90.42}}}},
        },
        [5721] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.EASTERN_PLAGUELANDS]={{38.8,91.2}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Relic Bundle in the Town Square."),}},
            [questKeys.objectives] = {{{10936,nil,Questie.ICON_TYPE_TALK}}},
        },
        -- Salve via Hunting/Mining/Gathering/Skinning/Disenchanting non repeatable quests
        -- Alliance
        [5727] = {
            [questKeys.triggerEnd] = {"Gauge Neeru Fireblade's reaction to you being a member of the Burning Blade", {[zoneIDs.ORGRIMMAR]={{49.6,50.46}}}},
        },
        [5742] = {
            [questKeys.objectives] = {{{1855,"Tirion's Tale"}}},
        },
        [5781] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Search the false grave for the Taelan's Hammer."), 0, {{"object", 177240}}}},
        },
        [8519] = {
            [questKeys.triggerEnd] = {"The War of the Shifting Sands", {[zoneIDs.SILITHUS]={{29.04,92.09}}}},
        },
        [5821] = {
            [questKeys.triggerEnd] = {"Escort Gizelton Caravan past Kolkar Centaur Village", {[zoneIDs.DESOLACE]={{67.17,56.62}}}},
        },
        [5882] = { -- Salve via Hunting
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
        },
        [5883] = { -- Salve via Mining
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
        },
        [5884] = { -- Salve via Gathering
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
        },
        [5885] = { -- Salve via Skinning
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
        },
        [5886] = { -- Salve via Disenchanting
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
        },
        -- Horde
        [5887] = { -- Salve via Hunting
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = 0,
        },
        [5888] = { -- Salve via Mining
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = 0,
        },
        [5889] = { -- Salve via Gathering
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = 0,
        },
        [5890] = { -- Salve via Skinning
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = 0,
        },
        [5891] = { -- Salve via Disenchanting
            [questKeys.preQuestSingle] = {4102},
            [questKeys.specialFlags] = 0,
        },
        [5892] = {
            [questKeys.questLevel] = 55,
        },
        [5893] = {
            [questKeys.questLevel] = 55,
        },
        [5921] = {
            [questKeys.breadcrumbs] = {5923,5924,5925},
        },
        [5922] = {
            [questKeys.breadcrumbs] = {5926,5927,5928},
        },
        [5923] = {
            [questKeys.startedBy] = {{4218},nil,nil},
            [questKeys.breadcrumbForQuestId] = 5921,
        },
        [5924] = {
            [questKeys.startedBy] = {{5505},nil,nil},
            [questKeys.breadcrumbForQuestId] = 5921,
        },
        [5925] = {
            [questKeys.startedBy] = {{3602},nil,nil},
            [questKeys.breadcrumbForQuestId] = 5921,
        },
        [5926] = {
            [questKeys.startedBy] = {{6746},nil,nil},
            [questKeys.breadcrumbForQuestId] = 5922,
        },
        [5927] = {
            [questKeys.startedBy] = {{6929},nil,nil},
            [questKeys.breadcrumbForQuestId] = 5922,
        },
        [5928] = {
            [questKeys.startedBy] = {{3064},nil,nil},
            [questKeys.breadcrumbForQuestId] = 5922,
        },
        [5929] = {
            [questKeys.objectives] = {{{11956,"Seek out the Great Bear Spirit and learn what it has to share with you about the nature of the bear."}}},
        },
        [5930] = {
            [questKeys.objectives] = {{{11956,"Seek out the Great Bear Spirit and learn what it has to share with you about the nature of the bear."}}},
        },
        [5931] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Silva Fil'naveth to fly back to Darnassus"), 0, {{"monster", 11800}}}},
        },
        [5932] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Bunthen Plainswind to fly back to Thunder Bluff"), 0, {{"monster", 11798}}}},
        },
        [5943] = {
            [questKeys.triggerEnd] = {"Escort Gizelton Caravan past Mannoroc Coven", {[zoneIDs.DESOLACE]={{55.69,67.79}}}},
        },
        [5944] = {
            [questKeys.triggerEnd] = {"Redemption?", {[zoneIDs.WESTERN_PLAGUELANDS]={{53.86,24.32}}}},
        },
        [6001] = {
            [questKeys.triggerEnd] = {"Face Lunaclaw and earn the strength of body and heart it possesses.", {
                [zoneIDs.DARKSHORE]={{43.3,45.82}},
                [zoneIDs.THE_BARRENS]={{41.96,60.81}}},
            },
        },
        [6002] = {
            [questKeys.triggerEnd] = {"Face Lunaclaw and earn the strength of body and heart it possesses.", {
                [zoneIDs.DARKSHORE]={{43.3,45.82}},
                [zoneIDs.THE_BARRENS]={{41.96,60.81}}},
            },
        },
        [6027] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Lord Kragaru"), 0, {{"object", 177673}}}},
        },
        [6041] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Plant the bomb!"), 0, {{"object", 177668}}}},
        },
        [6061] = {
            [questKeys.objectives] = {{{2956, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
            [questKeys.breadcrumbs] = {6065,6066,6067},
        },
        [6062] = {
            [questKeys.objectives] = {{{3099, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
            [questKeys.breadcrumbs] = {6068,6069,6070},
        },
        [6063] = {
            [questKeys.objectives] = {{{1998, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
            [questKeys.breadcrumbs] = {6071,6072,6073,6721,6722},
        },
        [6064] = {
            [questKeys.objectives] = {{{1126, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
            [questKeys.breadcrumbs] = {6074,6075,6076},
        },
        [6065] = {
            [questKeys.exclusiveTo] = {6066,6067},
            [questKeys.breadcrumbForQuestId] = 6061,
        },
        [6066] = {
            [questKeys.exclusiveTo] = {6065,6067},
            [questKeys.breadcrumbForQuestId] = 6061,
        },
        [6067] = {
            [questKeys.exclusiveTo] = {6065,6066},
            [questKeys.breadcrumbForQuestId] = 6061,
        },
        [6068] = {
            [questKeys.startedBy] = {{3407},nil,nil}, -- #2167
            [questKeys.exclusiveTo] = {6069,6070}, -- #1795
            [questKeys.breadcrumbForQuestId] = 6062,
        },
        [6069] = {
            [questKeys.startedBy] = {{11814},nil,nil}, -- #1523
            [questKeys.exclusiveTo] = {6068,6070}, -- #1795
            [questKeys.breadcrumbForQuestId] = 6062,
        },
        [6070] = {
            [questKeys.startedBy] = {{3038},nil,nil}, -- "The Hunter's Path" now started by "Kary Thunderhorn" in Thunder Bluff
            [questKeys.exclusiveTo] = {6068,6069}, -- #1795
            [questKeys.breadcrumbForQuestId] = 6062,
        },
        [6071] = {
            [questKeys.exclusiveTo] = {6072,6073,6721,6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6072] = {
            [questKeys.exclusiveTo] = {6071,6073,6721,6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6073] = {
            [questKeys.startedBy] = {{5515},nil,nil},
            [questKeys.exclusiveTo] = {6071,6072,6721,6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6074] = {
            [questKeys.startedBy] = {{5516},nil,nil},
            [questKeys.exclusiveTo] = {6075,6076},
            [questKeys.breadcrumbForQuestId] = 6064,
        },
        [6075] = {
            [questKeys.startedBy] = {{11807},nil,nil},
            [questKeys.exclusiveTo] = {6074,6076},
            [questKeys.breadcrumbForQuestId] = 6064,
        },
        [6076] = {
            [questKeys.exclusiveTo] = {6074,6075},
            [questKeys.breadcrumbForQuestId] = 6064,
        },
        [6082] = {
            [questKeys.objectives] = {{{3126, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6083] = {
            [questKeys.objectives] = {{{3107, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6084] = {
            [questKeys.objectives] = {{{1201, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6085] = {
            [questKeys.objectives] = {{{1196, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6087] = {
            [questKeys.objectives] = {{{2959, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6088] = {
            [questKeys.objectives] = {{{2970, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6101] = {
            [questKeys.objectives] = {{{2043, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6102] = {
            [questKeys.objectives] = {{{1996, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6132] = {
            [questKeys.triggerEnd] = {"Melizza Brimbuzzle escorted to safety", {[zoneIDs.DESOLACE]={{40.15,61.58}}}},
        },
        [6134] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DESOLACE]={{63.71,91.9}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Crate of Ghost Magnets"),}},
        },
        [6135] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {6022,6042,6133}, -- #1572
        },
        [6136] = {
            [questKeys.preQuestGroup] = {6022,6042,6133}, -- #1572
        },
        [6141] = {
            [questKeys.breadcrumbForQuestId] = 261, -- #1744
        },
        [6144] = {
            [questKeys.preQuestGroup] = {6135,6136}, -- #1950
        },
        [6163] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {6135,6136}, -- #1950
        },
        [6382] = {
            [questKeys.preQuestSingle] = {882},
            [questKeys.breadcrumbForQuestId] = 6383,
            [questKeys.nextQuestInChain] = 6383,
        },
        [6383] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {235,742,6382},
        },
        [6403] = {
            [questKeys.triggerEnd] = {"Reginald's March", {[zoneIDs.STORMWIND_CITY]={{77.57,18.59}}}},
        },
        [6482] = {
            [questKeys.triggerEnd] = {"Escort Ruul from the Thistlefurs.", {[zoneIDs.ASHENVALE]={{38.53,37.32}}}},
        },
        [6523] = {
            [questKeys.triggerEnd] = {"Kaya Escorted to Camp Aparaje", {[zoneIDs.STONETALON_MOUNTAINS]={{77.1,90.85}}}},
        },
        [6544] = {
            [questKeys.triggerEnd] = {"Take Silverwing Outpost.", {[zoneIDs.ASHENVALE]={{64.65,75.35}}}},
        },
        [6562] = {
            [questKeys.breadcrumbForQuestId] = 6563, -- #1826
        },
        [6563] = {
            [questKeys.preQuestSingle] = {}, -- #1826
            [questKeys.breadcrumbs] = {6562},
        },
        [6566] = {
            [questKeys.triggerEnd] = {"Thrall's Tale", {[zoneIDs.ORGRIMMAR]={{31.78,37.81}}}},
        },
        [6603] = {
            [questKeys.breadcrumbForQuestId] = 5082, -- #1824
        },
        [6604] = {
            [questKeys.breadcrumbForQuestId] = 4861,
        },
        [6605] = {
            [questKeys.breadcrumbForQuestId] = 4505, -- #1859 -- #1856
        },
        [6607] = {
            [questKeys.breadcrumbs] = {6608,6609}, -- #1154 -- #1186
        },
        [6608] = {
            [questKeys.breadcrumbForQuestId] = 6607, -- #1186
            [questKeys.nextQuestInChain] = 6607,
        },
        [6609] = {
            [questKeys.breadcrumbForQuestId] = 6607, -- #1154
            [questKeys.nextQuestInChain] = 6607,
        },
        [6610] = {
            [questKeys.breadcrumbs] = {6611,6612}, -- #2070
        },
        [6611] = {
            [questKeys.breadcrumbForQuestId] = 6610, -- #2070
            [questKeys.nextQuestInChain] = 6610,
        },
        [6612] = {
            [questKeys.breadcrumbForQuestId] = 6610, -- #2070
            [questKeys.nextQuestInChain] = 6610,
        },
        [6622] = {
            [questKeys.triggerEnd] = {"15 Patients Saved!", {[zoneIDs.DUSTWALLOW_MARSH]={{67.79,49.06}}}},
            [questKeys.breadcrumbs] = {6623},
        },
        [6623] = {
            [questKeys.breadcrumbForQuestId] = 6622,
        },
        [6624] = {
            [questKeys.triggerEnd] = {"15 Patients Saved!", {[zoneIDs.DUSTWALLOW_MARSH]={{67.79,49.06}}}},
            [questKeys.breadcrumbs] = {6625}, -- #1723
        },
        [6625] = {
            [questKeys.breadcrumbForQuestId] = 6624, -- #1723
        },
        [6627] = {
            [questKeys.triggerEnd] = {"Answer Braug Dimspirit's question correctly", {[zoneIDs.STONETALON_MOUNTAINS]={{78.75,45.63}}}},
        },
        [6628] = {
            [questKeys.triggerEnd] = {"Answer Parqual Fintallas' question correctly", {[zoneIDs.UNDERCITY]={{57.72,65.22}}}},
        },
        [6641] = {
            [questKeys.triggerEnd] = {"Defeat Vorsha the Lasher", {[zoneIDs.ASHENVALE]={{9.59,27.58}}}},
        },
        [6642] = {
            [questKeys.requiredMinRep] = {59,9000},
        },
        [6643] = {
            [questKeys.requiredMinRep] = {59,9000},
        },
        [6644] = {
            [questKeys.requiredMinRep] = {59,9000},
        },
        [6645] = {
            [questKeys.requiredMinRep] = {59,9000},
        },
        [6646] = {
            [questKeys.requiredMinRep] = {59,9000},
        },
        [6661] = {
            [questKeys.objectives] = {{{13016,"Rats Captured",Questie.ICON_TYPE_INTERACT}}},
        },
        [6681] = {
            [questKeys.startedBy] = {{332,918,3327,3328,3401,4214,4215,4163,4582,4583,4584,5165,5166,5167},nil,{17126}}, -- #7244
        },
        [6721] = {
            [questKeys.startedBy] = {{5116},nil,nil},
            [questKeys.exclusiveTo] = {6071,6072,6073,6722},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6722] = {
            [questKeys.startedBy] = {{1231},nil,nil},
            [questKeys.exclusiveTo] = {6071,6072,6073,6721},
            [questKeys.breadcrumbForQuestId] = 6063,
        },
        [6762] = {
            [questKeys.preQuestSingle] = {1015,1019,1047,6761},
        },
        [6804] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Aspect of Neptulon."), 0, {{"monster", 8519},{"monster", 8520},{"monster", 8521},{"monster", 8522}}}},
        },
        [6861] = {
            [questKeys.objectivesText] = {},
        },
        [6862] = {
            [questKeys.objectivesText] = {},
        },
        [6922] = {
            [questKeys.zoneOrSort] = 719,
        },
        [6961] = {
            [questKeys.exclusiveTo] = {7021,7024},
            [questKeys.breadcrumbForQuestId] = 6962,
            [questKeys.nextQuestInChain] = 6962,
        },
        [6962] = {
            [questKeys.objectivesText] = {"Bring 5 Gingerbread Cookies and an Ice Cold Milk to Greatfather Winter in Orgrimmar."},
            [questKeys.breadcrumbs] = {6961,7021,7024},
        },
        [6981] = {
            [questKeys.objectives] = {{{3442,"Speak with someone in Ratchet about the Glowing Shard"}},nil,nil,nil},
        },
        [6982] = {
            [questKeys.questLevel] = 55,
        },
        [6984] = {
            [questKeys.name] = "A Smokywood Pastures' Thank You!",
        },
        [6985] = {
            [questKeys.questLevel] = 55,
        },
        [7001] = {
            [questKeys.objectives] = {{{14282,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [7002] = {
            [questKeys.objectivesText] = {},
        },
        [7021] = {
            [questKeys.finishedBy] = {{13445},nil},
            [questKeys.exclusiveTo] = {6961,7024},
            [questKeys.breadcrumbForQuestId] = 6962,
            [questKeys.nextQuestInChain] = 6962,
        },
        [7022] = {
            [questKeys.startedBy] = {{13433},nil,nil},
        },
        [7023] = {
            [questKeys.startedBy] = {{13435},nil,nil},
        },
        [7024] = {
            [questKeys.finishedBy] = {{13445},nil},
            [questKeys.exclusiveTo] = {6961,7021},
            [questKeys.breadcrumbForQuestId] = 6962,
            [questKeys.nextQuestInChain] = 6962,
        },
        [7026] = {
            [questKeys.objectivesText] = {},
        },
        [7027] = {
            [questKeys.objectives] = {{{10990,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [7042] = {
            [questKeys.finishedBy] = {{13636}},
        },
        [7043] = {
            [questKeys.objectivesText] = {"Locate and return the Stolen Treats to Wulmort Jinglepocket in Ironforge. It was last thought to be in the possession of the Abominable Greench, found somewhere in the snowy regions of the Alterac Mountains."},
        },
        [7045] = {
            [questKeys.name] = "A Smokywood Pastures' Thank You!",
        },
        [7046] = {
            [questKeys.triggerEnd] = {"Create the Scepter of Celebras", {[zoneIDs.DESOLACE]={{35.97,64.41}}}},
        },
        [7062] = {
            [questKeys.startedBy] = {{1365},nil,nil},
        },
        [7067] = {
            [questKeys.requiredSourceItems] = {17757,17761,17762,17763,17764,17765},
        },
        [7068] = {
            [questKeys.requiredLevel] = 39,
        },
        [7070] = {
            [questKeys.requiredLevel] = 39,
        },
        [7081] = {
            [questKeys.specialFlags] = 0,
        },
        [7082] = {
            [questKeys.specialFlags] = 0,
        },
        [7121] = {
            [questKeys.exclusiveTo] = {5892,6892},
        },
        [7123] = {
            [questKeys.exclusiveTo] = {5893,6985},
        },
        [7141] = {
            [questKeys.triggerEnd] = {"Defeat Drek'thar.",{[zoneIDs.ALTERAC_VALLEY]={{47.22,86.95}}}},
        },
        [7142] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.triggerEnd] = {"Defeat Vanndar Stormpike.",{[zoneIDs.ALTERAC_VALLEY]={{42.29,12.85}}}},
        },
        [7161] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.breadcrumbs] = {7241},
        },
        [7162] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.breadcrumbs] = {7261},
        },
        [7165] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [7166] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7167] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7170] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7171] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7172] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7201] = {
            [questKeys.preQuestSingle] = {3906},
        },
        [7241] = {
            [questKeys.breadcrumbForQuestId] = 7161,
            [questKeys.nextQuestInChain] = 7161,
        },
        [7261] = {
            [questKeys.breadcrumbForQuestId] = 7162,
            [questKeys.nextQuestInChain] = 7162,
        },
        [7281] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7282] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7385] = {
            [questKeys.objectivesText] = {},
        },
        [7386] = {
            [questKeys.objectivesText] = {},
        },
        [7426] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7427] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7428] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7463] = {
            [questKeys.zoneOrSort] = sortKeys.MAGE,
        },
        [7481] = {
            [questKeys.objectives] = {nil,{{179544,"Master Telmius Dreamseeker Found"}}},
            [questKeys.objectivesText] = {"Search Dire Maul for Telmius Dreamseeker. Report back to Sage Korolusk at Camp Mojache with whatever information that you may find."},
        },
        [7482] = {
            [questKeys.objectives] = {nil,{{179544,"Master Telmius Dreamseeker Found"}}},
            [questKeys.objectivesText] = {"Search Dire Maul for Telmius Dreamseeker. Report back to Scholar Runethorn at Feathermoon with whatever information that you may find."},
        },
        [7483] = {
            [questKeys.preQuestSingle] = {7481,7482},
        },
        [7484] = {
            [questKeys.preQuestSingle] = {7481,7482},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7485] = {
            [questKeys.preQuestSingle] = {7481,7482},
        },
        [7488] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {7494} -- #1740
        },
        [7489] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {7492}, -- #1514
        },
        [7492] = {
            [questKeys.startedBy] = {{10879,10880,10881},nil,nil}, -- #1350
            [questKeys.breadcrumbForQuestId] = 7489, -- #1514
        },
        [7494] = {
            [questKeys.startedBy] = {{2198,10877,10878},nil,nil}, -- #2489
            [questKeys.breadcrumbForQuestId] = 7488, -- #1740
        },
        [7495] = { -- Victory for the Alliance
            [questKeys.requiredLevel] = 60,
        },
        [7507] = {
            [questKeys.name] = "Nostro's Compendium",
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [7508] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [7509] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [7541] = {
            [questKeys.questLevel] = 40, -- #1320
        },
        [7604] = {
            [questKeys.specialFlags] = 0,
        },
        [7622] = {
            [questKeys.triggerEnd] = {"The Balance of Light and Shadow", {[zoneIDs.EASTERN_PLAGUELANDS]={{21.19,17.79}}}}, -- #2332
        },
        [7631] = {
            [questKeys.requiredSourceItems] = {18663,18629,18670},
        },
        [7632] = {
            [questKeys.startedBy] = {{12018},{179703},{18703}},
        },
        [7633] = {
            [questKeys.preQuestSingle] = {7632},
        },
        [7640] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Exorcise the spirits"), 0, {{"object", 179747}}}},
        },
        [7651] = {
            [questKeys.specialFlags] = 0,
        },
        [7668] = { -- #1344
            [questKeys.name] = "The Darkreaver Menace",
            [questKeys.startedBy] = {{13417},nil,nil},
            [questKeys.finishedBy] = {{13417},nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectivesText] = {"Bring Darkreaver's Head to Sagorne Creststrider in the Valley of Wisdom, Orgrimmar."},
            [questKeys.objectives] = {nil,nil,{{18880,nil}},nil},
            [questKeys.sourceItemId] = 18746,
            [questKeys.zoneOrSort] = sortKeys.SHAMAN,
            [questKeys.exclusiveTo] = {8258}, -- 8258 after Phase 4
            [questKeys.preQuestSingle] = {7667},
        },
        [7669] = { -- #1449
            [questKeys.name] = "Again Into the Great Ossuary",
            [questKeys.startedBy] = {{13417},nil,nil},
            [questKeys.finishedBy] = {{13417},nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.zoneOrSort] = sortKeys.SHAMAN,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {7668,8258},
        },
        [7670] = { -- #1432
            [questKeys.name] = "Lord Grayson Shadowbreaker",
            [questKeys.startedBy] = {{5149},nil,nil},
            [questKeys.finishedBy] = {{928},nil},
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
        [7736] = {
            [questKeys.objectivesText] = {},
        },
        [7738] = { -- Perfect Yeti Hide H
            [questKeys.preQuestSingle] = {2822},
        },
        [7782] = { -- The Lord of Blackrock
            [questKeys.startedBy] = {{1748}},
        },
        [7784] = { -- The Lord of Blackrock
            [questKeys.startedBy] = {{4949}},
        },
        [7785] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.HUNTER + classIDs.ROGUE,
        },
        [7786] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.HUNTER + classIDs.ROGUE,
        },
        [7787] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.HUNTER + classIDs.ROGUE,
        },
        [7816] = {
            [questKeys.preQuestSingle] = {}, -- #2247
        },
        [7838] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #1589
        },
        [7843] = {
            [questKeys.triggerEnd] = {"Message to the Wildhammer Delivered", {[zoneIDs.THE_HINTERLANDS]={{14.34,48.07}}}},
        },
        [7863] = {
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7864] = {
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7865] = {
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7866] = {
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7867] = {
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7868] = {
            [questKeys.zoneOrSort] = zoneIDs.WARSONG_GULCH,
        },
        [7886] = { -- #1435
            [questKeys.startedBy] = {{14733},nil,nil},
            [questKeys.finishedBy] = {{14733},nil},
        },
        [7887] = { -- #1435
            [questKeys.startedBy] = {{14733},nil,nil},
            [questKeys.finishedBy] = {{14733},nil},
        },
        [7888] = { -- #1435
            [questKeys.startedBy] = {{14733},nil,nil},
            [questKeys.finishedBy] = {{14733},nil},
        },
        [7905] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7921] = { -- #1435
            [questKeys.startedBy] = {{14733},nil,nil},
            [questKeys.finishedBy] = {{14733},nil},
        },
        [7926] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7937] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7938] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7945] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [7946] = {
            [questKeys.questLevel] = 60,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8044] = {
            [questKeys.name] = "The Rage of Mugamba",
        },
        [8053] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8054] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8055] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8056] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8057] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8058] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8059] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8060] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8061] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8062] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8063] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8064] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8065] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8066] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8067] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8068] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8069] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8070] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8071] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8072] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8073] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8074] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8075] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8076] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8077] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8078] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8079] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8105] = {
            [questKeys.specialFlags] = 0,
        },
        [8114] = {
            [questKeys.requiredMinRep] = {509,3000},
            [questKeys.triggerEnd] = {"Control Four Bases.", {[zoneIDs.ARATHI_HIGHLANDS]={{46.03,45.3}}}},
        },
        [8115] = {
            [questKeys.triggerEnd] = {"Take Five Bases.", {[zoneIDs.ARATHI_HIGHLANDS]={{46.03,45.3}}}},
            [questKeys.requiredMinRep] = {509,42000},
        },
        [8120] = {
            [questKeys.specialFlags] = 0,
        },
        [8121] = {
            [questKeys.requiredMinRep] = {510,3000},
            [questKeys.triggerEnd] = {"Hold Four Bases.", {
                [zoneIDs.THUNDER_BLUFF]={{40.4,51.57}},
                [zoneIDs.ARATHI_HIGHLANDS]={{73.72,29.52}},
                [zoneIDs.ORGRIMMAR]={{50.1,69.03}},
                [zoneIDs.SILVERPINE_FOREST]={{39.68,17.75}}},
            },
        },
        [8122] = {
            [questKeys.triggerEnd] = {"Hold Five Bases.", {
                [zoneIDs.THUNDER_BLUFF]={{40.4,51.57}},
                [zoneIDs.ARATHI_HIGHLANDS]={{73.72,29.52}},
                [zoneIDs.ORGRIMMAR]={{50.1,69.03}},
                [zoneIDs.SILVERPINE_FOREST]={{39.68,17.75}}},
            },
            [questKeys.requiredMinRep] = {510,42000},
        },
        [8148] = {
            [questKeys.name] = "Maelstrom's Wrath",
        },
        [8149] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place a tribute at Uther's Tomb"),0,{{"object", 2082},}}},
        },
        [8150] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place a tribute at Grom's Monument"),0,{{"object", 21004},}}},
        },
        [8151] = {
            [questKeys.startedBy] = {{3039,3352,4205,5116,5516}},
        },
        [8166] = {
            [questKeys.specialFlags] = 0,
            [questKeys.requiredMaxLevel] = 49,
        },
        [8167] = {
            [questKeys.specialFlags] = 0,
            [questKeys.requiredMaxLevel] = 39,
        },
        [8168] = {
            [questKeys.specialFlags] = 0,
            [questKeys.requiredMaxLevel] = 29,
        },
        [8169] = {
            [questKeys.specialFlags] = 0,
            [questKeys.requiredMaxLevel] = 49,
        },
        [8170] = {
            [questKeys.specialFlags] = 0,
            [questKeys.requiredMaxLevel] = 39,
        },
        [8171] = {
            [questKeys.specialFlags] = 0,
            [questKeys.requiredMaxLevel] = 29,
        },
        [8181] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8183] = { -- The Heart of Hakkar
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8184] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.objectivesText] = {},
        },
        [8185] = {
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {},
        },
        [8186] = {
            [questKeys.requiredClasses] = classIDs.ROGUE,
            [questKeys.objectivesText] = {},
        },
        [8187] = {
            [questKeys.requiredClasses] = classIDs.HUNTER,
            [questKeys.objectivesText] = {},
        },
        [8188] = {
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectivesText] = {},
        },
        [8189] = {
            [questKeys.requiredClasses] = classIDs.MAGE,
            [questKeys.objectivesText] = {},
        },
        [8190] = {
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {},
        },
        [8191] = {
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectivesText] = {},
        },
        [8192] = {
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {},
        },
        [8193] = {
            [questKeys.questLevel] = 60,
        },
        [8194] = {
            [questKeys.questLevel] = 60,
        },
        [8195] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8196] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8201] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8221] = {
            [questKeys.questLevel] = 60,
        },
        [8224] = {
            [questKeys.questLevel] = 60,
        },
        [8225] = {
            [questKeys.questLevel] = 60,
        },
        [8227] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8228] = {
            [questKeys.startedBy] = {{15116},nil,nil},
            [questKeys.finishedBy] = {{15116},nil},
        },
        [8229] = {
            [questKeys.startedBy] = {{15119},nil,nil},
            [questKeys.finishedBy] = {{15119},nil},
        },
        [8233] = {
            [questKeys.startedBy] = {{918,3328,4163,4583,5165}},
        },
        [8238] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8239] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8240] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8243] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8246] = {
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
        },
        [8249] = {
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8250] = {
            [questKeys.startedBy] = {{331,3047,4567,7311,7312}},
        },
        [8251] = {
            [questKeys.preQuestSingle] = {},
        },
        [8254] = {
            [questKeys.startedBy] = {{5489,6018,11406}},
        },
        [8258] = {
            [questKeys.exclusiveTo] = {7668}, -- 7668 before Phase 4
        },
        [8262] = {
            [questKeys.requiredMinRep] = {509,3000},
        },
        [8271] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8272] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8275] = {
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbForQuestId] = 8280, -- #1873
        },
        [8276] = {
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbForQuestId] = 8280, -- #1873
        },
        [8280] = {
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbs] = {8275,8276}, -- #1873
        },
        [8286] = {
            [questKeys.triggerEnd] = {"Discover the Brood of Nozdormu.",{[zoneIDs.TANARIS]={{63.43, 50.61}}}},
        },
        [8289] = { -- #1435
            [questKeys.startedBy] = {{14733},nil,nil},
            [questKeys.finishedBy] = {{14733},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8296] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8304] = {
            [questKeys.objectives] = {{{15171,"Frankal Questioned",Questie.ICON_TYPE_TALK},{15170,"Rutgar Questioned",Questie.ICON_TYPE_TALK}},nil,nil,nil},
            [questKeys.requiredLevel] = 58, -- #2166
        },
        [8314] = {
            [questKeys.specialFlags] = 0, -- #1870
        },
        [8315] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SILITHUS]={{47.50,54.50}}}, Questie.ICON_TYPE_EVENT, l10n("Draw the glyphs into the sand to summon the Qiraji Emissary."),}},
        },
        [8317] = {
            [questKeys.requiredSourceItems] = {20424},
        },
        [8331] = {
            [questKeys.breadcrumbForQuestId] = 8332,
        },
        [8332] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8331},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),2,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8341] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8343},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."),2,{{"object", 180461},{"object", 180534},{"object", 180554},}}},
        },
        [8343] = {
            [questKeys.breadcrumbForQuestId] = 8341,
        },
        [8348] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8349},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."),0,{{"object", 180461},{"object", 180534},{"object", 180554},}}},
        },
        [8349] = {
            [questKeys.breadcrumbForQuestId] = 8348,
        },
        [8351] = {
            [questKeys.breadcrumbForQuestId] = 8352,
        },
        [8352] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8351},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Lord using a full Twilight set, neck and ring."),0,{{"object", 180466},{"object", 180539},{"object", 180559},}}},
        },
        [8353] = {
            [questKeys.objectives] = {{{5111, "Cluck like a chicken for Innkeeper Firebrew",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8354] = {
            [questKeys.objectives] = {{{6741, "Cluck like a chicken for Innkeeper Norman",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8355] = {
            [questKeys.objectives] = {{{6826, "Do the \"train\" for Talvash",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8356] = {
            [questKeys.objectives] = {{{6740, "Flex for Innkeeper Allison",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8357] = {
            [questKeys.objectives] = {{{6735, "Dance for Innkeeper Saelienne",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8358] = {
            [questKeys.objectives] = {{{11814, "Do the \"train\" for Kali Remik",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8359] = {
            [questKeys.objectives] = {{{6929, "Flex for Innkeeper Gryshka",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8360] = {
            [questKeys.objectives] = {{{6746, "Dance for Innkeeper Pala",Questie.ICON_TYPE_EVENT}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8361] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),0,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8363] = { -- Abyssal Signets
            [questKeys.requiredMinRep] = {609,3000},
        },
        [8367] = { -- For Great Honor
            [questKeys.zoneOrSort] = sortKeys.ORGRIMMAR,
        },
        [8368] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8426,8427,8428,8429,8430},
            [questKeys.requiredMaxLevel] = 19,
        },
        [8370] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8436,8437,8438,8439},
            [questKeys.requiredMaxLevel] = 29,
        },
        [8371] = { -- Concerted Efforts
            [questKeys.zoneOrSort] = sortKeys.IRONFORGE,
        },
        [8372] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8399,8400,8401,8402,8403},
            [questKeys.requiredMaxLevel] = 19,
        },
        [8373] = {
            [questKeys.objectives] = {nil,{{180449,"Clean up a stink bomb that's been dropped on Southshore!"}}},
        },
        [8374] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8393,8394,8395,8396}, -- #6068
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
            [questKeys.zoneOrSort] = sortKeys.IRONFORGE,
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
            [questKeys.zoneOrSort] = sortKeys.ORGRIMMAR,
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
            [questKeys.preQuestSingle] = {8374,8393},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8392] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374,8393,8394},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8393] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374,8394,8395,8396},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8394] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374,8393,8395,8396},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8395] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374,8393,8394,8396},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8396] = { -- Claiming Arathi Basin
            [questKeys.exclusiveTo] = {8374,8393,8394,8395},
        },
        [8397] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374,8393,8394,8395},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8398] = { -- Claiming Arathi Basin
            [questKeys.preQuestSingle] = {8374,8393,8394,8395,8396},
            [questKeys.objectivesText] = {},
        },
        [8399] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372,8400,8401,8402,8403},
            [questKeys.requiredMaxLevel] = 29,
        },
        [8400] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372,8399,8401,8402,8403},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8401] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372,8399,8400,8402,8403},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8402] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372,8399,8400,8401,8403},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8403] = { -- Fight for Warsong Gulch
            [questKeys.exclusiveTo] = {8372,8399,8400,8401,8402},
        },
        [8404] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372,8399},
            [questKeys.requiredMaxLevel] = 29,
            [questKeys.objectivesText] = {},
        },
        [8405] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372,8399,8400},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8406] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372,8399,8400,8401},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8407] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372,8399,8400,8401,8402},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8408] = { -- Fight for Warsong Gulch
            [questKeys.preQuestSingle] = {8372,8399,8400,8401,8402,8403},
            [questKeys.objectivesText] = {},
        },
        [8410] = {
            [questKeys.exclusiveTo] = {8411}, -- other preQuestSingle
            [questKeys.startedBy] = {{3032,13417}},
        },
        [8411] = {
            [questKeys.exclusiveTo] = {8410}, -- other preQuestSingle
        },
        [8412] = {
            [questKeys.preQuestSingle] = {8410,8411}, -- 8411 was missing
        },
        [8414] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {8414},
        },
        [8415] = {
            [questKeys.startedBy] = {{928,5149}},
            [questKeys.breadcrumbForQuestId] = 8414,
        },
        [8417] = {
            [questKeys.startedBy] = {{3041,3354,4593,5113,5479,7315}},
            [questKeys.breadcrumbForQuestId] = 8423,
        },
        [8419] = {
            [questKeys.startedBy] = {{461,3326,4563,5172}},
        },
        [8423] = {
            [questKeys.breadcrumbs] = {8417},
        },
        [8426] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368,8427,8428,8429,8430},
            [questKeys.requiredMaxLevel] = 29,
        },
        [8427] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368,8426,8428,8429,8430},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8428] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368,8426,8427,8429,8430},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8429] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368,8426,8427,8428,8430},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8430] = { -- Battle of Warsong Gulch
            [questKeys.exclusiveTo] = {8368,8426,8427,8428,8429},
        },
        [8431] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368,8426},
            [questKeys.requiredMaxLevel] = 29,
            [questKeys.objectivesText] = {},
        },
        [8432] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368,8426,8427},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8433] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368,8426,8427,8428},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8434] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368,8426,8427,8428,8429},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8435] = { -- Battle of Warsong Gulch
            [questKeys.preQuestSingle] = {8368,8426,8427,8428,8429,8430},
            [questKeys.objectivesText] = {},
        },
        [8436] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370,8437,8438,8439},
            [questKeys.requiredMaxLevel] = 39,
        },
        [8437] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370,8436,8438,8439},
            [questKeys.requiredMaxLevel] = 49,
        },
        [8438] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370,8436,8437,8439},
            [questKeys.requiredMaxLevel] = 59,
        },
        [8439] = { -- Conquering Arathi Basin
            [questKeys.exclusiveTo] = {8370,8436,8437,8438},
        },
        [8440] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370,8436},
            [questKeys.requiredMaxLevel] = 39,
            [questKeys.objectivesText] = {},
        },
        [8441] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370,8436,8437},
            [questKeys.requiredMaxLevel] = 49,
            [questKeys.objectivesText] = {},
        },
        [8442] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370,8436,8437,8438},
            [questKeys.requiredMaxLevel] = 59,
            [questKeys.objectivesText] = {},
        },
        [8443] = { -- Conquering Arathi Basin
            [questKeys.preQuestSingle] = {8370,8436,8437,8438,8439},
            [questKeys.objectivesText] = {},
        },
        [8447] = {
            [questKeys.triggerEnd] = {"Waking Legends.",{[zoneIDs.MOONGLADE]={{40.0,48.6}}}},
        },
        [8466] = {
            [questKeys.objectivesText] = {},
        },
        [8467] = {
            [questKeys.objectivesText] = {},
        },
        [8469] = {
            [questKeys.objectivesText] = {},
        },
        [8481] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant the Demon Summoning Torch"),0,{{"object", 180673}}}},
        },
        [8484] = {
            [questKeys.preQuestSingle] = {8481},
        },
        [8485] = {
            [questKeys.preQuestSingle] = {8481},
        },
        [8492] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8493] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8494] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8495] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8498] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8499] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8500] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8503] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8504] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8505] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8506] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8507] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ask to see the Captain."),0,{{"monster", 15443}}}},
        },
        [8509] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8510] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8511] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8512] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8513] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8514] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8515] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8516] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8517] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8518] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8520] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8521] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8522] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8523] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8524] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8525] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8526] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8527] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8528] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8529] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8532] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8533] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8535] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),0,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8536] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),0,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8537] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),0,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8538] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."),0,{{"object", 180461},{"object", 180534},{"object", 180554},}}},
        },
        [8542] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8543] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8545] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8546] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8548] = {
            [questKeys.preQuestSingle] = {8800},
        },
        [8549] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8550] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8551] = {
            [questKeys.requiredLevel] = 35,
        },
        [8572] = {
            [questKeys.preQuestSingle] = {8800},
        },
        [8573] = {
            [questKeys.preQuestSingle] = {8800},
        },
        [8574] = {
            [questKeys.preQuestSingle] = {8800},
        },
        [8575] = {
            [questKeys.startedBy] = {{15481},nil,nil},
            [questKeys.preQuestSingle] = {8555}, -- #2365
        },
        [8580] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8581] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8582] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8583] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8588] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8589] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8590] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8591] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8600] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8601] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8604] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8605] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8607] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8608] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8609] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8610] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8611] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8612] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8613] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8614] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8615] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8616] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8620] = {
            [questKeys.requiredSourceItems] = {21103,21104,21105,21106,21107,21108,21109,21110},
        },
        [8729] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Arcanite Buoy"),0,{{"object", 180669}}}},
        },
        [8733] = {
            [questKeys.preQuestSingle] = {8555}, -- #2365
        },
        [8736] = {
            [questKeys.triggerEnd] = {"The Redemption of Eranikus", {[zoneIDs.MOONGLADE]={{51.8,36.4}}}},
        },
        [8737] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),0,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8746] = {
            [questKeys.requiredSourceItems] = {21314},
        },
        [8747] = {
            [questKeys.exclusiveTo] = {8752,8753,8754,8755,8756,8757,8758,8759,8760,8761}, --protector neutral
        },
        [8748] = {
            [questKeys.exclusiveTo] = {8752,8753,8754,8755,8756,8757,8758,8759,8760,8761}, --protector friendly
        },
        [8749] = {
            [questKeys.exclusiveTo] = {8752,8753,8754,8755,8756,8757,8758,8759,8760,8761}, --protector honored
        },
        [8750] = {
            [questKeys.exclusiveTo] = {8752,8753,8754,8755,8756,8757,8758,8759,8760,8761}, --protector revered
        },
        [8751] = {
            [questKeys.exclusiveTo] = {8752,8753,8754,8755,8756,8757,8758,8759,8760,8761}, --protector exalted
        },
        [8752] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8757,8758,8759,8760,8761}, --conqueror neutral
        },
        [8753] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8757,8758,8759,8760,8761}, --conqueror friendly
        },
        [8754] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8757,8758,8759,8760,8761}, --conqueror honored
        },
        [8755] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8757,8758,8759,8760,8761}, --conqueror revered
        },
        [8756] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8757,8758,8759,8760,8761}, --conqueror exalted
        },
        [8757] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8752,8753,8754,8755,8756}, --invoker neutral
        },
        [8758] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8752,8753,8754,8755,8756}, --invoker friendly
        },
        [8759] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8752,8753,8754,8755,8756}, --invoker honored
        },
        [8760] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8752,8753,8754,8755,8756}, --invoker revered
        },
        [8761] = {
            [questKeys.exclusiveTo] = {8747,8748,8749,8750,8751,8752,8753,8754,8755,8756}, --invoker exalted
        },
        [8762] = {
            [questKeys.requiredSourceItems] = {21314},
        },
        [8767] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.WARRIOR + classIDs.HUNTER + classIDs.PALADIN,
            [questKeys.exclusiveTo] = {8788},
        },
        [8788] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.WARLOCK + classIDs.MAGE + classIDs.SHAMAN + classIDs.DRUID,
            [questKeys.exclusiveTo] = {8767},
        },
        [8792] = {
            [questKeys.requiredLevel] = 1,
        },
        [8793] = {
            [questKeys.requiredLevel] = 1,
        },
        [8794] = {
            [questKeys.requiredLevel] = 1,
        },
        [8795] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {8796,8797},
        },
        [8796] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {8795,8797},
        },
        [8797] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {8795,8796},
        },
        [8798] = {
            [questKeys.requiredSkill] = {202,250},
        },
        [8804] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8805] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8806] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8807] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- #2401
        },
        [8829] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8846] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8847] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8848] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8849] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8850] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8851] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8852] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8853] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8854] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8855] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
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
        [8863] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8864] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8865] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8867] = {
            [questKeys.requiredSourceItems] = {21557,21558,21559,21571,21574,21576},
            [questKeys.objectives] = {nil,{{180771,"Lunar Fireworks Fired"},{180772,"Lunar Fireworks Cluster Fired"}}},
        },
        [8868] = {
            [questKeys.triggerEnd] = {"Receive Elune's Blessing.", {[zoneIDs.MOONGLADE]={{63.89,62.5}}}},
        },
        [8869] = {
            [questKeys.exclusiveTo] = {5305},
        },
        [8870] = {
            [questKeys.exclusiveTo] = {8867,8871,8872},
        },
        [8871] = {
            [questKeys.exclusiveTo] = {8867,8870,8872},
        },
        [8872] = {
            [questKeys.exclusiveTo] = {8867,8870,8871},
        },
        [8873] = {
            [questKeys.exclusiveTo] = {8867,8874,8875},
        },
        [8874] = {
            [questKeys.exclusiveTo] = {8867,8873,8875},
        },
        [8875] = {
            [questKeys.exclusiveTo] = {8867,8873,8874},
        },
        [8876] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8877] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8878] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8879] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8880] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8881] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8882] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8883] = {
            [questKeys.requiredSourceItems] = {21711},
        },
        [8897] = {
            [questKeys.exclusiveTo] = {8898,8899,8903},
        },
        [8898] = {
            [questKeys.exclusiveTo] = {8897,8899,8903},
        },
        [8899] = {
            [questKeys.exclusiveTo] = {8897,8898,8903},
        },
        [8900] = {
            [questKeys.exclusiveTo] = {8901,8902,8904},
        },
        [8901] = {
            [questKeys.exclusiveTo] = {8900,8902,8904},
        },
        [8902] = {
            [questKeys.exclusiveTo] = {8900,8901,8904},
        },
        [8903] = {
            [questKeys.requiredSourceItems] = {11018},
            [questKeys.preQuestSingle] = {},
        },
        [8904] = {
            [questKeys.requiredSourceItems] = {11018},
            [questKeys.preQuestSingle] = {},
        },
        [8966] = {
            [questKeys.exclusiveTo] = {8967,8968,8969},
            [questKeys.preQuestSingle] = {8962,8963,8964,8965},
        },
        [8967] = {
            [questKeys.exclusiveTo] = {8966,8968,8969},
            [questKeys.preQuestSingle] = {8962,8963,8964,8965},
        },
        [8968] = {
            [questKeys.exclusiveTo] = {8966,8967,8969},
            [questKeys.preQuestSingle] = {8962,8963,8964,8965},
        },
        [8969] = {
            [questKeys.exclusiveTo] = {8966,8967,8968},
            [questKeys.preQuestSingle] = {8962,8963,8964,8965},
        },
        [8980] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8985] = {
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8986,8987,8988},
            [questKeys.nextQuestInChain] = 8989,
        },
        [8986] = {
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8985,8987,8988},
            [questKeys.nextQuestInChain] = 8990,
        },
        [8987] = {
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8986,8988,8989},
            [questKeys.nextQuestInChain] = 8991,
        },
        [8988] = {
            [questKeys.preQuestSingle] = {8970},
            [questKeys.exclusiveTo] = {8986,8987,8989},
            [questKeys.nextQuestInChain] = 8992,
        },
        [8989] = {
            [questKeys.preQuestSingle] = {8985,8986,8987,8988},
            [questKeys.exclusiveTo] = {8990,8991,8992},
        },
        [8990] = {
            [questKeys.preQuestSingle] = {8985,8986,8987,8988},
            [questKeys.exclusiveTo] = {8989,8991,8992},
        },
        [8991] = {
            [questKeys.preQuestSingle] = {8985,8986,8987,8988},
            [questKeys.exclusiveTo] = {8989,8990,8992},
        },
        [8992] = {
            [questKeys.preQuestSingle] = {8985,8986,8987,8988},
            [questKeys.exclusiveTo] = {8989,8990,8991},
        },
        [9015] = {
            [questKeys.objectives] = {{{16059,"Theldren's Team Defeated"}},nil,{{22047,nil}},nil}, -- #2408
        },
        [9026] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9051] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{6498,6499,6500},6498,"Devilsaur stabbed with barb"}}},
        },
        [9034] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9036] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9037] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9038] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9039] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9040] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9041] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9042] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9043] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9044] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9045] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9046] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9047] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9048] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9049] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9050] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9052] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9063},
        },
        [9054] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9055] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9056] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9057] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9058] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9059] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9060] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9061] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9063] = {
            [questKeys.startedBy] = {{3033,4217,5505,12042}},
            [questKeys.breadcrumbForQuestId] = 9052,
        },
        [9069] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9070] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9071] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9072] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9073] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9074] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9075] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9077] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9078] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9079] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9080] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9081] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9082] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9083] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9084] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9085] = {
            [questKeys.requiredLevel] = 50,
        },
        [9086] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9087] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9088] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9089] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9090] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9091] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9092] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9093] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9094] = {
            [questKeys.requiredLevel] = 50,
        },
        [9095] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9096] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9097] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9098] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9099] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9100] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9101] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9102] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9103] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9104] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9105] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9106] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9107] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9108] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9109] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9110] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9111] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9112] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9113] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9114] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9115] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9116] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9117] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9118] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9121] = {
            [questKeys.requiredMinRep] = {529,0},
        },
        [9124] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9126] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9128] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9131] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9136] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9141] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9153] = {
            [questKeys.requiredLevel] = 50,
        },
        [9154] = {
            [questKeys.questLevel] = 60,
        },
        [9165] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9211] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9213] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9223] = {
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9229] = {
            [questKeys.preQuestSingle] = {9033},
        },
        [9232] = {
            [questKeys.preQuestSingle] = {9033},
        },
        [9234] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [9235] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
        },
        [9236] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN,
            [questKeys.requiredMinRep] = {nil,nil},
        },
        [9237] = {
            [questKeys.requiredMinRep] = {nil,nil},
        },
        [9238] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9239] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9240] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
            [questKeys.requiredMinRep] = {nil,nil},
        },
        [9241] = {
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9242] = {
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9243] = {
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
            [questKeys.requiredMinRep] = {nil,nil},
        },
        [9244] = {
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9245] = {
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9246] = {
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
            [questKeys.requiredMinRep] = {nil,nil},
        },
        [9247] = {
            [questKeys.requiredLevel] = 1,
        },
        [9248] = {
            [questKeys.requiredMinRep] = {609,0},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Lord using a full Twilight set, neck and ring."),0,{{"object", 180466},{"object", 180539},{"object", 180559},}}},
        },
        [9250] = {
            [questKeys.requiredClasses] = classIDs.MAGE + classIDs.PRIEST + classIDs.DRUID + classIDs.WARLOCK,
        },
        [9251] = {
            [questKeys.requiredClasses] = classIDs.MAGE + classIDs.PRIEST + classIDs.DRUID + classIDs.WARLOCK,
        },
        [9260] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.ELWYNN_FOREST] = {{34.72,50.95},{34.18,48.47},{32.24,53.77},{35.05,55.22}}}},
        },
        [9261] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.DUN_MOROGH] = {{48.53,39.54},{49.70,39.17}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9262] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.TELDRASSIL] = {{36.96,55.49},{38.30,56.49}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9263] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.DUROTAR] = {{44.9,16.7},{44.6,18.1}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [9264] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.MULGORE] = {{38.9,37.1}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [9265] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.TIRISFAL_GLADES] = {{60.4,61.7}}}},
        },
        [9292] = {
            [questKeys.requiredLevel] = 1,
        },
        [9295] = {
            [questKeys.requiredLevel] = 45,
        },
        [9299] = {
            [questKeys.requiredLevel] = 45,
        },
        [9300] = {
            [questKeys.requiredLevel] = 45,
        },
        [9301] = {
            [questKeys.requiredLevel] = 45,
        },
        [9302] = {
            [questKeys.requiredLevel] = 45,
        },
        [9304] = {
            [questKeys.requiredLevel] = 45,
        },
        [9310] = {
            [questKeys.requiredLevel] = 1,
        },
        [9317] = {
            [questKeys.requiredLevel] = 50,
        },
        [9318] = { -- Blessed Wizard Oil
            [questKeys.questLevel] = 60,
        },
        [9319] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [9320] = { -- Major Mana Potion
            [questKeys.requiredLevel] = 50,
        },
        [9321] = { -- Major Healing Potion
            [questKeys.zoneOrSort] = sortKeys.INVASION,
            [questKeys.questLevel] = 60,
        },
        [9322] = {
            [questKeys.requiredLevel] = 1,
        },
        [9323] = {
            [questKeys.requiredLevel] = 1,
        },
        [9333] = {
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
        [9341] = { -- Tabard of the Argent Dawn
            [questKeys.questLevel] = 60,
        },
        [9343] = { -- Tabard of the Argent Dawn
            [questKeys.questLevel] = 60,
        },
        [9386] = {
            [questKeys.preQuestSingle] = {9319},
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9415] = { -- Report to Marshal Bluewall
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 0,
        },
        [9416] = { -- Report to General Kirika
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 0,
        },
        [9419] = { -- Scouring the Desert
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{17090,"Return Silithyst",Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Silithyst"),0,{{"object", 181597},{"object", 181598}}}},
        },
        [9422] = { -- Scouring the Desert
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{18199,"Return Silithyst",Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Silithyst"),0,{{"object", 181597},{"object", 181598}}}},
        },
        ----- Warlock Incubus quest chain -----
        [65593] = {
            [questKeys.name] = "Hearts of the Lovers",
            [questKeys.startedBy] = {{5693},nil,nil},
            [questKeys.finishedBy] = {{5675},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Bring the hearts of Avelina Lilly and Isaac Pearson to Carendin Halgar in the Temple of the Damned."},
            [questKeys.objectives] = {nil,nil,{{190179},{190180}},nil,nil},
            [questKeys.preQuestSingle] = {1472},
            [questKeys.exclusiveTo] = {65610},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },
        [65597] = {
            [questKeys.name] = "The Binding",
            [questKeys.startedBy] = {{5675},nil,nil},
            [questKeys.finishedBy] = {{5675},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Using the Lovers' Hearts, summon and subdue an incubus, then return the Lovers' Hearts to Carendin Halgar in the Magic Quarter of the Undercity."},
            [questKeys.objectives] = {{{185335}},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {65593},
            [questKeys.requiredSourceItems] = {190181},
            [questKeys.exclusiveTo] = {65604},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.extraObjectives] = {{{[zoneIDs.UNDERCITY]={{86.4,26.4}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Lovers' Hearts to summon an Incubus and slay it."),}},
        },
        [65601] = {
            [questKeys.name] = "Love Hurts",
            [questKeys.startedBy] = {{5909},nil,nil},
            [questKeys.finishedBy] = {{3363},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Speak with Magar in Orgrimmar."},
            [questKeys.preQuestSingle] = {1507},
            [questKeys.exclusiveTo] = {65593,65610},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },
        [65602] = {
            [questKeys.name] = "What Is Love?",
            [questKeys.startedBy] = {{6244},nil,nil},
            [questKeys.finishedBy] = {{6122},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Retrieve the Wooden Figurine and bring it to Gakin the Darkbinder in the Mage Quarter of Stormwind."},
            [questKeys.objectives] = {nil,nil,{{190309}},nil,nil},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.requiredSourceItems] = {190307},
            [questKeys.extraObjectives] = {{{[zoneIDs.ASHENVALE]={{26.7,22.5}}}, Questie.ICON_TYPE_EVENT, l10n("Light the Unlit Torch near a fire and use the Burning Torch to set the Archaeologist's Cart on fire."),}},
        },
        [65603] = {
            [questKeys.name] = "The Binding",
            [questKeys.startedBy] = {{6122},nil,nil},
            [questKeys.finishedBy] = {{6122},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Using the Wooden Figurine, summon and subdue an incubus, then return the Wooden Figurine to Gakin the Darkbinder in the Slaughtered Lamb."},
            [questKeys.objectives] = {{{185335}},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {65602},
            [questKeys.requiredSourceItems] = {190186},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.extraObjectives] = {{{[zoneIDs.STORMWIND_CITY]={{25.2,77.4}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Withered Scarf to summon an Incubus and slay it."),}},
        },
        [65604] = {
            [questKeys.name] = "The Binding",
            [questKeys.startedBy] = {{5875},nil,nil},
            [questKeys.finishedBy] = {{5875},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Using the Withered Scarf, summon and subdue an incubus, then return the Withered Scarf to Gan'rul Bloodeye in Orgrimmar."},
            [questKeys.objectives] = {{{185335}},nil,nil,nil,nil},
            [questKeys.preQuestSingle] = {65610},
            [questKeys.requiredSourceItems] = {190187},
            [questKeys.exclusiveTo] = {65597},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.extraObjectives] = {{{[zoneIDs.ORGRIMMAR]={{49.4,50}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Withered Scarf to summon an Incubus and slay it."),}},
        },
        [65610] = {
            [questKeys.name] = "Wish You Were Here",
            [questKeys.startedBy] = {{3363},nil,nil},
            [questKeys.finishedBy] = {{5875},nil},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Investigate Fallen Sky Lake in Ashenvale and report your findings to Gan'rul Bloodeye in Orgrimmar."},
            [questKeys.preQuestSingle] = {65601},
            [questKeys.objectives] = {nil,nil,{{190232}},nil,nil},
            [questKeys.exclusiveTo] = {65593},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },
    }
end

function QuestieQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys

    local questFixesHorde = {
        [687] = {
            [questKeys.startedBy] = {{2787},nil,nil}
        },
        [737] = {
            [questKeys.startedBy] = {{2934},nil,nil}
        },
        [1718] = {
            [questKeys.startedBy] = {{3041,3354,4595},nil,nil}
        },
        [1947] = {
            [questKeys.startedBy] = {{3048,4568,5885},nil,nil}
        },
        [1953] = {
            [questKeys.startedBy] = {{3048,4568,5885},nil,nil}
        },
        [2861] = {
            [questKeys.startedBy] = {{4568,5885},nil,nil}
        },
        [5050] = {
            [questKeys.startedBy] = {{8403},nil,nil}
        },
        [6681] = {
            [questKeys.startedBy] = {{3327,3328,3401,4582,4583,4584},nil,{17126}} -- #7244
        },
        [7562] = {
            [questKeys.startedBy] = {{5753,5815},nil,nil},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8254] = {
            [questKeys.startedBy] = {{6018},nil,nil},
        },
        [8904] = {
            [questKeys.exclusiveTo] = {8900,8901,8902,8979}
        },
        [9388] = {
            [questKeys.startedBy] = {{16818},nil,nil},
        },
        [9389] = {
            [questKeys.startedBy] = {{16818},nil,nil},
        },
    }

    local questFixesAlliance = {
        [687] = {
            [questKeys.startedBy] = {{2786},nil,nil}
        },
        [737] = {
            [questKeys.startedBy] = {{2786},nil,nil}
        },
        [1718] = {
            [questKeys.startedBy] = {{5113,5479},nil,nil}
        },
        [1947] = {
            [questKeys.startedBy] = {{5144,5497},nil,nil}
        },
        [1953] = {
            [questKeys.startedBy] = {{5144,5497},nil,nil}
        },
        [2861] = {
            [questKeys.startedBy] = {{5144,5497},nil,nil}
        },
        [5050] = {
            [questKeys.startedBy] = {{3520},nil,nil}
        },
        [6681] = {
            [questKeys.startedBy] = {{332,918,4214,4215,4163,5165,5166,5167},nil,{17126}} -- #7244
        },
        [7562] = {
            [questKeys.startedBy] = {{5520,6382},nil,nil},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8254] = {
            [questKeys.startedBy] = {{5489,11406},nil,nil},
        },
        [9388] = {
            [questKeys.startedBy] = {{16817},nil,nil},
        },
        [9389] = {
            [questKeys.startedBy] = {{16817},nil,nil},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end


