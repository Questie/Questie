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
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

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
    local factionIDs = QuestieDB.factionIDs
    local profKeys = QuestieProfessions.professionKeys
    local specKeys = QuestieProfessions.specializationKeys

    return {
        [2] = {
            [questKeys.startedBy] = {{12676},nil,{16305}},
        },
        [5] = {
            [questKeys.preQuestSingle] = {}, -- #1198
        },
        [17] = {
            [questKeys.requiredLevel] = 38, -- #2437
        },
        [23] = {
            [questKeys.startedBy] = {{12678},nil,{16303}},
        },
        [24] = {
            [questKeys.startedBy] = {{12677},nil,{16304}},
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
        },
        [46] = {
            [questKeys.preQuestSingle] = {39},
        },
        [90] = {
            [questKeys.requiredSkill] = {185, 50},
        },
        [100] = {
            [questKeys.childQuests] = {1103}, -- #1658
        },
        [109] = {
            [questKeys.startedBy] = {{233,237,240,261,294,963},nil,nil}, --#2158
        },
        [117] = {
            [questKeys.name] = "Thunderbrew",
        },
        [136] = {
            [questKeys.startedBy] = {{513,515,126,171,456,127,517,458,391},nil,{1357}},
        },
        [148] = {
            [questKeys.preQuestSingle] = {}, -- #1173
        },
        [155] = {
            [questKeys.triggerEnd] = {"Escort The Defias Traitor to discover where VanCleef is hiding", {[zoneIDs.WESTFALL]={{42.55,71.53}}}},
        },
        [163] = {
            [questKeys.exclusiveTo] = {5}, -- Raven Hill breadcrumb
        },
        [164] = {
            [questKeys.exclusiveTo] = {95}, -- deliveries to sven is a breadcrumb
        },
        [165] = {
            [questKeys.exclusiveTo] = {148}, --#1173
        },
        [178] = {
            [questKeys.startedBy] = {{429,431,432,433,434,568,579,703,947},nil,{1962}},
            [questKeys.objectivesText] = {"Bring the Faded Shadowhide Pendant to Theocritus the Mage. NOTE: This is a very rare drop!"},
        },
        [201] = {
            [questKeys.triggerEnd] = {"Locate the hunters' camp", {[zoneIDs.STRANGLETHORN_VALE]={{35.65,10.59}}}},
        },
        [214] = {
            [questKeys.preQuestSingle] = {155}, -- wotlkDB has prequest wrong data
        },
        [219] = {
            [questKeys.triggerEnd] = {"Escort Corporal Keeshan back to Redridge", {[zoneIDs.REDRIDGE_MOUNTAINS]={{33.36,48.7}}}},
        },
        [235] = {
            [questKeys.exclusiveTo] = {742,6382,6383},
        },
        [249] = {
            [questKeys.startedBy] = {{313},{31},nil},
        },
        [254] = {
            [questKeys.parentQuest] = 253,
            [questKeys.specialFlags] = 1,
            [questKeys.exclusiveTo] = {253}, --#2173
            [questKeys.preQuestSingle] = {252},
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
        [282] = {
            [questKeys.exclusiveTo] = {287},
        },
        [287] = {
            [questKeys.preQuestSingle] = {},
        },
        [308] = {
            [questKeys.exclusiveTo] = {311}, -- distracting jarven can't be completed once you get the followup
            [questKeys.specialFlags] = 1,
            [questKeys.preQuestSingle] = {},
            [questKeys.parentQuest] = 310
        },
        [309] = {
            [questKeys.triggerEnd] = {"Escort Miran to the excavation site", {[zoneIDs.LOCH_MODAN]={{65.12,65.77}}}},
        },
        [310] = {
            [questKeys.childQuests] = {308,403},
        },
        [353] = {
            [questKeys.preQuestSingle] = {}, -- #2364
        },
        [364] = {
            [questKeys.preQuestSingle] = {}, -- #882
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
        [373] = {
            [questKeys.startedBy] = {{639},nil,{2874}},
        },
        [374] = {
            [questKeys.preQuestSingle] = {427}, -- proof of demise requires at war with the scarlet crusade
        },
        [403] = {
            [questKeys.specialFlags] = 1,
            [questKeys.parentQuest] = 310,
        },
        [409] = {
            [questKeys.requiredSourceItems] = {3080},
        },
        [410] = { -- the dormant shade
            [questKeys.preQuestSingle] = {366}, -- #638
            [questKeys.exclusiveTo] = {411}, -- #752
        },
        [415] = {
            [questKeys.exclusiveTo] = {413}, -- cant complete rejolds new brew if you do shimmer stout (see issue 567)
        },
        [420] = {
            [questKeys.exclusiveTo] = {287}, -- senir's observations part 2 becomes unavailable if you have completed frostmane hold
        },
        [427] = {
            [questKeys.preQuestSingle] = {},
        },
        [428] = {
            [questKeys.exclusiveTo] = {429}, -- lost deathstalkers breadcrumb
        },
        [429] = {
            [questKeys.preQuestSingle] = {}, -- #1843
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
            [questKeys.exclusiveTo] = {297} -- #2492
        },
        [437] = {
            [questKeys.triggerEnd] = {"Enter the Dead Fields",{[zoneIDs.SILVERPINE_FOREST]={{45.91, 21.27}}}},
        },
        [452] = {
            [questKeys.triggerEnd] = {"Aid Faerleia in killing the Pyrewood Council", {[zoneIDs.SILVERPINE_FOREST]={{46.51,74.07}}}},
        },
        [455] = {
            [questKeys.preQuestSingle] = {}, -- #1858
        },
        [460] = {
            [questKeys.startedBy] = {{1939},nil,{3317}},
        },
        [463] = {
            [questKeys.exclusiveTo] = {276}, --greenwarden cant be completed if you have trampling paws
        },
        [464] = {
            [questKeys.preQuestSingle] = {}, -- #809
        },
        [466] = {
            [questKeys.preQuestSingle] = {}, -- #2066
        },
        [467] = {
            [questKeys.startedBy] = {{1340,2092},nil,nil}, -- #1379
            [questKeys.exclusiveTo] = {466}, -- #2066
        },
        [468] = {
            [questKeys.exclusiveTo] = {455}, -- #1858
        },
        [473] = {
            [questKeys.preQuestSingle] = {455}, -- #809
            [questKeys.exclusiveTo] = {464}, -- #2173
        },
        [484] = {
            [questKeys.requiredMinRep] = {72,0}, -- #1501
        },
        [489] = {
            [questKeys.startedBy] = {{2081,2083,2151,2155},nil,nil},
        },
        [495] = {
            [questKeys.exclusiveTo] = {518},
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
        },
        [522] = {
            [questKeys.startedBy] = {{2434},nil,{3668}},
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
        [551] = {
            [questKeys.startedBy] = {nil,{1765},{3706}}, -- #1245
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
        [594] = {
            [questKeys.startedBy] = {nil,{2560},{4098}},
        },
        [598] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {596,629},
        },
        [611]  = {
            [questKeys.requiredSourceItems] = {4034, 4027},
        },
        [619] = {
            [questKeys.parentQuest] = 8554, -- #1691
        },
        [621] = {
            [questKeys.inGroupWith] = {}, -- #886
        },
        [624] = {
            [questKeys.startedBy] = {nil,{2554},{4056}},
        },
        [637] = {
            [questKeys.startedBy] = {nil,{2656},{4433}}, -- #909
        },
        [638] = {
            [questKeys.exclusiveTo] = {639}, -- #1205
        },
        [639] = {
            [questKeys.preQuestSingle] = {}, -- #1205
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
        [665] = {
            [questKeys.triggerEnd] = {"Defend Professor Phizzlethorpe", {[zoneIDs.ARATHI_HIGHLANDS]={{33.87,80.6}}}},
        },
        [667] = {
            [questKeys.triggerEnd] = {"Defend Shakes O'Breen", {[zoneIDs.ARATHI_HIGHLANDS]={{31.93,81.82}}}},
        },
        [676] = {
            [questKeys.exclusiveTo] = {677},
        },
        [677] = {
            [questKeys.preQuestSingle] = {}, --#1162
        },
        [680] = {
            [questKeys.preQuestSingle] = {678}, -- #1062
        },
        [690] = {
            [questKeys.exclusiveTo] = {691}, -- #1587
        },
        [691] = {
            [questKeys.preQuestSingle] = {},
        },
        [707] = {
            [questKeys.exclusiveTo] = {738}, --#2069
        },
        [715] = {
            [questKeys.requiredSkill] = {},
        },
        [717] = {
            [questKeys.requiredSourceItems] = {4843,4844,4845},
        },
        [730] = {
            [questKeys.exclusiveTo] = {729}, -- #1587
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
            [questKeys.preQuestSingle] = {}, -- #1289
        },
        [742] = {
            [questKeys.exclusiveTo] = {235,6382,6383},
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
        [770] = {
            [questKeys.startedBy] = {{3056},nil,{4854}},
        },
        [781] = {
            [questKeys.startedBy] = {nil,{3076},{4851}},
        },
        [793] = {
            [questKeys.requiredSourceItems] = {4843,4844,4845},
        },
        [809] = {
            [questKeys.triggerEnd] = {"Destroy the Demon Seed", {[zoneIDs.THE_BARRENS]={{62.34,20.07}}}}, -- #2347
        },
        [819] = {
            [questKeys.startedBy] = {nil,{3238},{4926}},
        },
        [830] = {
            [questKeys.startedBy] = {nil,{3239},{4881}},
        },
        [832] = {
            [questKeys.startedBy] = {{3204},nil,{4903}},
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
            [questKeys.specialFlags] = 1,
            [questKeys.exclusiveTo] = {654},
        },
        [854] = {
            [questKeys.exclusiveTo] = {871}, -- #2014
        },
        [860] = {
            [questKeys.exclusiveTo] = {844},
        },
        [861] = {
            [questKeys.nextQuestInChain] = 860,
            [questKeys.exclusiveTo] = {860,844}, -- #1109
        },
        [862] = {
            [questKeys.requiredSkill] = {185,76}, -- You need to be a Journeyman for this quest
        },
        [863] = {
            [questKeys.triggerEnd] = {"Escort Wizzlecrank out of the Venture Co. drill site", {[zoneIDs.THE_BARRENS]={{55.36,7.68}}}},
        },
        [883] = {
            [questKeys.startedBy] = {{3474},nil,{5099}},
        },
        [884] = {
            [questKeys.startedBy] = {{3473},nil,{5102}},
        },
        [885] = {
            [questKeys.startedBy] = {{3472},nil,{5103}},
        },
        [886] = {
            [questKeys.exclusiveTo] = {870},
        },
        [897] = {
            [questKeys.startedBy] = {{3253},nil,{5138}},
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
            [questKeys.preQuestSingle] = {809}, --#606
            [questKeys.exclusiveTo] = {924}, -- #2195
        },
        [927] = {
            [questKeys.startedBy] = {{3535},nil,{5179}},
        },
        [930] = {
            [questKeys.preQuestSingle] = {918}, -- #971
        },
        [931] = {
            [questKeys.preQuestSingle] = {918},
        },
        [936] = {
            [questKeys.exclusiveTo] = {3762,3784,3761},
        },
        [938] = {
            [questKeys.triggerEnd] = {"Lead Mist safely to Sentinel Arynia Cloudsbreak", {[zoneIDs.TELDRASSIL]={{38.33,34.39}}}},
        },
        [939] = {
            [questKeys.startedBy] = {{10648},nil,{11668}},
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
            [questKeys.requiredClasses] = nil,
            [questKeys.objectivesText] = nil,
            [questKeys.triggerEnd] = nil,
            [questKeys.objectives] = nil,
            [questKeys.sourceItemId] = nil,
            [questKeys.preQuestGroup] = nil,
            [questKeys.preQuestSingle] = nil,
            [questKeys.childQuests] = nil,
            [questKeys.inGroupWith] = nil,
            [questKeys.exclusiveTo] = nil,
            [questKeys.zoneOrSort] = 148,
            [questKeys.requiredSkill] = nil,
            [questKeys.requiredMinRep] = nil,
            [questKeys.requiredMaxRep] = nil,
            [questKeys.requiredSourceItems] = nil,
            [questKeys.nextQuestInChain] = nil,
            [questKeys.questFlags] = 8,
            [questKeys.specialFlags] = 1,
            [questKeys.parentQuest] = 949, -- workaround, can't mimic ingame 100%
        },
        [961] = {
            [questKeys.preQuestSingle] = nil,
            [questKeys.exclusiveTo] = nil,
            [questKeys.specialFlags] = 1,
            [questKeys.parentQuest] = 950, -- workaround, can't mimic ingame 100%
        },
        [968] = {
            [questKeys.startedBy] = {{2338,2339},nil,{5352}},
        },
        [976] = {
            [questKeys.triggerEnd] = {"Protect Feero Ironhand", {[zoneIDs.DARKSHORE]={{43.54,94.39}}}},
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
            [questKeys.exclusiveTo] = {1057}, -- #1901
        },
        [1061] = {
            [questKeys.exclusiveTo] = {1062}, -- #1803
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
            [questKeys.preQuestSingle] = {1070},
        },
        [1086] = {
            [questKeys.triggerEnd] = {"Place the Toxic Fogger", {[zoneIDs.STONETALON_MOUNTAINS]={{66.44,45.46}}}},
        },
        [1090] = {
            [questKeys.objectives] = {{{4276,"Keep Piznik safe while he mines the mysterious ore"}}},
        },
        [1097] = {
            [questKeys.startedBy] = {{415,514},nil,nil},
            [questKeys.exclusiveTo] = {353}, -- #2364
        },
        [1100] = {
            [questKeys.startedBy] = {nil,{19861},{5791}}, -- #1189
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
            [questKeys.specialFlags] = 1, -- #884
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
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE]={{35.71,44.68}}}, Questie.ICON_TYPE_EVENT, l10n("Fish for Darkshore Groupers"),}},
        },
        [1144] = {
            [questKeys.triggerEnd] = {"Help Willix the Importer escape from Razorfen Kraul", {[zoneIDs.THE_BARRENS]={{42.27,89.88}}}},
        },
        [1148] = {
            [questKeys.preQuestSingle] = {1146},
            [questKeys.startedBy] = {{4132},nil,{5877}},
        },
        [1173] = {
            [questKeys.triggerEnd] = {"Drive Overlord Mok'Morokk from Brackenwall Village", {[zoneIDs.DUSTWALLOW_MARSH]={{36.41,31.43}}}},
        },
        [1190] = {
            [questKeys.childQuests] = {1191},
        },
        [1191] = {
            [questKeys.parentQuest] = 1190,
        },
        [1193] = {
            [questKeys.specialFlags] = 1, -- #1348
        },
        [1198] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1204] = {
            [questKeys.preQuestSingle] = {}, -- #938
        },
        [1206] = {
            [questKeys.objectivesText] = {"Bring 40 Unpopped Darkmist Eyes to \"Swamp Eye\" Jarl at the Swamplight Manor.",},
        },
        [1221] = {
            [questKeys.sourceItemId] = 6684,
            [questKeys.requiredSourceItems] = {5880, 6684},
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
            [questKeys.exclusiveTo] = {1204},
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
            [questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[zoneIDs.DUSTWALLOW_MARSH]={{48,24}}}},
        },
        [1271] = {
            [questKeys.preQuestGroup] = {1222,1204},
        },
        [1273] = {
            [questKeys.triggerEnd] = {"Question Reethe with Ogron", {[zoneIDs.DUSTWALLOW_MARSH]={{42.47,38.07}}}},
        },
        [1275] = {
            [questKeys.preQuestSingle] = {}, -- #973 -- #745 prequest is not required in Classic
        },
        [1276] = {
            [questKeys.preQuestSingle] = {1273}, -- #1574
        },
        [1284] = {
            [questKeys.preQuestSingle] = {1302,1282}, -- #1845
            [questKeys.startedBy] = {nil,{21015,21016},nil},
        },
        [1301] = {
            [questKeys.exclusiveTo] = {1302,1282}, -- #917 #2448
        },
        [1302] = {
            [questKeys.preQuestSingle] = {}, -- #889
        },
        [1324] = {
            [questKeys.objectives] = {{{4966,"Subdue Private Hendel"}}},
            [questKeys.nextQuestInChain] = 1267, -- wotlkDB is wrong, classicGB is right
        },
        [1339] = {
            [questKeys.exclusiveTo] = {1338}, -- mountaineer stormpike's task cant be done if you have finished stormpike's order
        },
        [1361] = {
            [questKeys.exclusiveTo] = {1362},
            [questKeys.startedBy] = {{2229,4485}},
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
        [1392] = {
            [questKeys.startedBy] = {{5477},nil,{6196}},
        },
        [1393] = {
            [questKeys.triggerEnd] = {"Escort Galen out of the Fallow Sanctuary.", {[zoneIDs.SWAMP_OF_SORROWS]={{53.08,29.55}}}},
        },
        [1395] = {
            [questKeys.preQuestSingle] = {}, -- #1727
        },
        [1418] = {
            [questKeys.exclusiveTo] = {1419,1420}, -- #1594
        },
        [1423] = {
            [questKeys.startedBy] = {nil,{28604},{6172}},
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
            [questKeys.preQuestGroup] = {1434,1480},
        },
        [1440] = {
            [questKeys.triggerEnd] = {"Rescue Dalinda Malem", {[zoneIDs.DESOLACE]={{58.27,30.91}}}},
        },
        [1442] = {
            [questKeys.specialFlags] = 1,
            [questKeys.parentQuest] = 1654,
        },
        [1447] = {
            [questKeys.objectives] = {{{4961,"Defeat Dashel Stonefist"}}},
        },
        [1448] = {
            [questKeys.triggerEnd] = {"Search for the Temple of Atal'Hakkar", {[zoneIDs.SWAMP_OF_SORROWS]={{70.2,45.2},{66.6,48.1},{73.6,48.1},{64.9,53.3},{75.4,53.3},{66.6,58.4},{73.6,58.4},{70.2,60.5}}}},
        },
        [1470] = {
            [questKeys.exclusiveTo] = {1485}, -- #999
        },
        [1471] = {
            [questKeys.exclusiveTo] = {1504}, -- #1542
        },
        [1472] = {
            [questKeys.exclusiveTo] = {},
        },
        [1473] = {
            [questKeys.exclusiveTo] = {1501},
        },
        [1474] = {
            [questKeys.exclusiveTo] = {1513},
        },
        [1477] = {
            [questKeys.exclusiveTo] = {1395}, -- #1727
        },
        [1478] = {
            [questKeys.exclusiveTo] = {1506}, -- #1427
        },
        [1479] = {
            [questKeys.triggerEnd] = {"Go to the bank in Darnassus, otherwise known as the Bough of the Eternals.", {[zoneIDs.DARNASSUS]={{41.31,43.54}}}},
        },
        [1480] = {
            [questKeys.startedBy] = {{4663,4664,4665,4666,4667,4668,4705,13019},nil,{20310}},
        },
        [1483] = {
            [questKeys.exclusiveTo] = {1093},
        },
        [1485] = {
            [questKeys.exclusiveTo] = {1470}, -- #999
        },
        [1501] = {
            [questKeys.exclusiveTo] = {1473},
        },
        [1504] = {
            [questKeys.exclusiveTo] = {1471}, -- #1542
        },
        [1506] = {
            [questKeys.exclusiveTo] = {1478}, -- #1427
        },
        [1507] = {
            [questKeys.exclusiveTo] = {},
        },
        [1513] = {
            [questKeys.exclusiveTo] = {1474},
        },
        [1516] = {
            [questKeys.exclusiveTo] = {1519},
        },
        [1517] = {
            [questKeys.exclusiveTo] = {1520},
        },
        [1518] = {
            [questKeys.exclusiveTo] = {1521},
        },
        [1519] = {
            [questKeys.exclusiveTo] = {1516},
        },
        [1520] = {
            [questKeys.exclusiveTo] = {1517},
        },
        [1521] = {
            [questKeys.exclusiveTo] = {1518},
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
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE]={{35.71,44.68}}}, Questie.ICON_TYPE_EVENT, l10n("Fish for Gaffer Jacks"),}},
        },
        [1580] = {
            [questKeys.requiredSkill] = {356,30},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE]={{50.7,23.8},{40,73.6},{44.3,74.4},{53.3,32.4},{43.3,80.6}}}, Questie.ICON_TYPE_EVENT, l10n("Fish for Electropellers"),}},
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
            [questKeys.specialFlags] = 1,
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
        [1687] = {
            [questKeys.triggerEnd] = {"Go to the Westfall Lighthouse.", {[zoneIDs.WESTFALL]={{30.41,85.61}}}},
        },
        [1700] = {
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.exclusiveTo] = {1703,1704,1705}, -- #1857
        },
        [1703] = {
            [questKeys.exclusiveTo] = {1700,1704,1710}, -- #1857
        },
        [1704] = {
            [questKeys.exclusiveTo] = {1700,1703,1708}, -- #1857
        },
        [1705] = {
            [questKeys.preQuestSingle] = {1700,1703,1704}, -- #1857
        },
        [1708] = {
            [questKeys.preQuestSingle] = {1700,1703,1704}, -- #1857
        },
        [1710] = {
            [questKeys.preQuestSingle] = {1700,1703,1704}, -- #1857
        },
        [1718] = {
            [questKeys.startedBy] = {{3041,3354,4595,5113,5479},nil,nil}, -- #1034
        },
        [1789] = {
            [questKeys.exclusiveTo] = {1785},
        },
        [1790] = {
            [questKeys.exclusiveTo] = {1788},
        },
        [1793] = {
            [questKeys.exclusiveTo] = {1649},
            [questKeys.specialFlags] = 1,
        },
        [1794] = {
            [questKeys.startedBy] = {{6179},nil,nil},
            [questKeys.exclusiveTo] = {1649},
            [questKeys.specialFlags] = 1,
        },
        [1799] = {
            [questKeys.preQuestSingle] = {4965,4967,4968,4969},
        },
        [1800] = {
            [questKeys.triggerEnd] = {"Go to the old Lordaeron Throne Room that lies just before descending into the Undercity.", {[zoneIDs.UNDERCITY]={{65.97,36.12}}}},
        },
        [1823] = {
            [questKeys.startedBy] = {{3041,3354,4595},nil,nil},
        },
        [1860] = {
            [questKeys.exclusiveTo] = {1861, 1880},
        },
        [1861] = {
            [questKeys.exclusiveTo] = {1880},
            [questKeys.preQuestSingle] = {},
        },
        [1879] = {
            [questKeys.exclusiveTo] = {1861, 1880},
        },
        [1880] = {
            [questKeys.exclusiveTo] = {1861},
            [questKeys.preQuestSingle] = {},
        },
        [1882] = {
            [questKeys.preQuestSingle] = {},
        },
        [1918] = {
            [questKeys.startedBy] = {{12759},nil,{16408}},
        },
        [1920] = {
            [questKeys.preQuestSingle] = {}, -- #1328
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Cantation of Manifestation to reveal Rift Spawn. Use Chest of Containment Coffers on stunned Rift Spawn"), 0, {{"monster", 6492}}}},
        },
        [1939] = {
            [questKeys.startedBy] = {{5144,5497},nil,nil},
        },
        [1943] = {
            [questKeys.exclusiveTo] = {1944}, -- mage robe breadcrumb
        },
        [1944] = {
            [questKeys.preQuestSingle] = {}, -- #2253
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
        },
        [1960] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Cantation of Manifestation to reveal Rift Spawn. Use Chest of Containment Coffers on stunned Rift Spawn"), 0, {{"monster", 6492}}}},
        },
        [2039] = {
            [questKeys.exclusiveTo] = {2038},
        },
        [2041] = {
            [questKeys.exclusiveTo] = {2040}, --#2068
        },
        [2118] = {
            [questKeys.objectives] = {{{2164,"Rabid Thistle Bear Captured"}}},
        },
        [2198] = {
            [questKeys.startedBy] = {{4852},nil,{7666}},
        },
        [2201] = {
            [questKeys.childQuests] = {3375},
            [questKeys.requiredLevel] = 37, -- #2447
        },
        [2205] = {
            [questKeys.exclusiveTo] = {}, -- #1466
        },
        [2218] = {
            [questKeys.exclusiveTo] = {}, -- #1466
        },
        [2240]  = {
            [questKeys.triggerEnd] = { "Explore the Hidden Chamber", {[zoneIDs.BADLANDS]={{35.22,10.32}}}},
        },
        [2241] = {
            [questKeys.exclusiveTo] = {}, -- #1466
        },
        [2259] = {
            [questKeys.exclusiveTo] = {2260, 2281}, -- #1825, #2476
        },
        [2260] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {2281}, -- #1825
        },
        [2278] = {
            [questKeys.objectives] = {{{7172,"Learn what lore that the stone watcher has to offer"}}},
        },
        [2281] = {
            [questKeys.exclusiveTo] = {2299}, -- #1817
        },
        [2298] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {2281}, -- #1825
        },
        [2299] = {
            [questKeys.exclusiveTo] = {2281}, -- #1817
        },
        [2300] = {
            [questKeys.preQuestSingle] = {}, -- #1825
            [questKeys.exclusiveTo] = {2281}, -- #1817
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
            [questKeys.objectives] = {{{7318,"Release Oben Rageclaw's spirit"}}},
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
            [questKeys.exclusiveTo] = {2770}, -- #2071
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
        [2843] = {
            [questKeys.triggerEnd] = {"Goblin Transponder", {[zoneIDs.STRANGLETHORN_VALE]={{27.56,77.42}}}},
        },
        [2845] = {
            [questKeys.triggerEnd] = {"Take Shay Leafrunner to Rockbiter's camp", {[zoneIDs.FERALAS]={{42.33,21.85}}}},
            [questKeys.requiredSourceItems] = {9189},
        },
        [2861] = {
            [questKeys.startedBy] = {{4568,5144,5497,5885},nil,nil}, -- #1152
            [questKeys.exclusiveTo] = {2846},
        },
        [2864] = {
            [questKeys.exclusiveTo] = {2865}, -- #2072
        },
        [2865] = {
            [questKeys.preQuestSingle] = {},
        },
        [2872] = {
            [questKeys.exclusiveTo] = {2873}, -- #1566
        },
        [2873] = {
            [questKeys.preQuestSingle] = {}, -- #1566
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
            [questKeys.preQuestSingle] = {}, -- Save Techbot's Brain doesn't need the Tinkmaster Overspark breadcrumb #687
        },
        [2923] = {
            [questKeys.exclusiveTo] = {2922}, -- #2067
        },
        [2925] = {
            [questKeys.exclusiveTo] = {2924},
        },
        [2926] = {
            [questKeys.preQuestSingle] = {}, -- #2389
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
        },
        [2931] = {
            [questKeys.exclusiveTo] = {2930},
        },
        [2932] = {
            [questKeys.triggerEnd] = {"Place the grim message.", {[zoneIDs.THE_HINTERLANDS]={{23.41,58.06}}}},
        },
        [2936] = {
            [questKeys.triggerEnd] = {"Find the Spider God's Name", {[zoneIDs.TANARIS]={{38.73,19.88}}}},
        },
        [2945] = {
            [questKeys.startedBy] = {{6212},nil,{9326}},
        },
        [2951] = {
            [questKeys.preQuestSingle] = {4601,4602},
            [questKeys.specialFlags] = 1,
        },
        [2952] = {
            [questKeys.exclusiveTo] = {4605,4606},
        },
        [2954] = {
            [questKeys.triggerEnd] = {"Learn the purpose of the Stone Watcher of Norgannon", {[zoneIDs.TANARIS]={{37.66,81.42}}}},
        },
        [2969] = {
            [questKeys.triggerEnd] = {"Save at least 6 Sprite Darters from capture", {[zoneIDs.FERALAS]={{67.27,46.67}}}},
        },
        [2978] = {
            [questKeys.startedBy] = {nil,{143980},{9370}}, -- #1596
        },
        [2981] = {
            [questKeys.exclusiveTo] = {2975},
        },
        [2992] = {
            [questKeys.triggerEnd] = {"Wait for Grimshade to finish", {[zoneIDs.BLASTED_LANDS]={{66.99,19.41}}}},
        },
        [2994] = {
            [questKeys.questLevel] = 51, -- #1129
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
        [3090] = {
            [questKeys.requiredRaces] = raceIDs.ORC, -- #2399
        },
        [3128] = {
            [questKeys.preQuestSingle] = {3122},
        },
        [3141] = {
            [questKeys.objectives] = {{{7783,"Loramus' Story"}}},
        },
        [3181] = {
            [questKeys.startedBy] = {{5833},nil,{10000}},
        },
        [3321] = {
            [questKeys.objectives] = {{{7804,"Watch Trenton Work"}}},
        },
        [3367] = {
            [questKeys.triggerEnd] = {"Dorius Escort", {[zoneIDs.SEARING_GORGE]={{74.47,19.44}}}},
        },
        [3374] = {
            [questKeys.startedBy] = {{5353},nil,{10589}}, -- #1233
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
            [questKeys.requiredSkill] = {197,226}, -- You need to be an Artisan for this quest
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
        [3483] = {
            [questKeys.parentQuest] = 3449, -- #1008
            [questKeys.specialFlags] = 1, -- #1131
        },
        [3513] = {
            [questKeys.startedBy] = {{5797},nil,{10621}},
        },
        [3520] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Vale Screechers and use Yeh'kinya's Bramble on their corpse."), 0, {{"monster", 5307},{"monster", 5308}}}},
        },
        [3525] = {
            [questKeys.triggerEnd] = {"Protect Belnistrasz while he performs the ritual to shut down the idol", {[zoneIDs.THE_BARRENS]={{50.86,92.87}}}},
        },
        [3526] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3625] = {
            [questKeys.objectives] = {{{7802,"Weaponry Creation"}}},
        },
        [3628] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Teleport to the top of the mountain."), 0, {{"object", 153203},{"monster", 8816}}},
                                          {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Ward of the Defiler to summon Razelikh."), 0, {{"object", 153205}}},
			},
        },
        [3629] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3630] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3632] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3633] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3634] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3635] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3637] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [3639] = {
            [questKeys.exclusiveTo] = {3643,3641},
        },
        [3641] = {
            [questKeys.exclusiveTo] = {3639},
        },
        [3643] = {
            [questKeys.exclusiveTo] = {3639},
        },
        [3681] = {
            [questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000},
        },
        [3702] = {
            [questKeys.objectives] = {{{8879,"Story of Thaurissan"}}},
        },
        [3763] = {
            [questKeys.exclusiveTo] = {3789,3790,3764},
        },
        [3762] = {
            [questKeys.exclusiveTo] = {936,3784,3761},
        },
        [3765] = {
            [questKeys.exclusiveTo] = {1275}, -- corruption abroad breadcrumb
            [questKeys.requiredLevel] = 18,
        },
        [3787] = {
            [questKeys.preQuestSingle] = {3781},
        },
        [3788] = {
            [questKeys.preQuestSingle] = {3781},
        },
        [3789] = {
            [questKeys.exclusiveTo] = {3763,3790,3764},
        },
        [3790] = {
            [questKeys.exclusiveTo] = {3763,3789,3764},
        },
        [3784] = {
            [questKeys.exclusiveTo] = {936,3762,3761},
        },
        [3785] = {
            [questKeys.requiredSourceItems] = {11018},
        },
        [3786] = {
            [questKeys.requiredSourceItems] = {11018},
        },
        [3791] = {
            [questKeys.preQuestSingle] = {3787,3788}, -- #885
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
        [4103] = {
            [questKeys.preQuestSingle] = {5882,5883,5884,5885,5886},
            [questKeys.specialFlags] = 1,
        },
        [4104] = {
            [questKeys.preQuestSingle] = {5882,5883,5884,5885,5886},
            [questKeys.specialFlags] = 1,
        },
        [4105] = {
            [questKeys.preQuestSingle] = {5882,5883,5884,5885,5886},
            [questKeys.specialFlags] = 1,
        },
        [4106] = {
            [questKeys.preQuestSingle] = {5882,5883,5884,5885,5886},
            [questKeys.specialFlags] = 1,
        },
        [4107] = {
            [questKeys.preQuestSingle] = {5882,5883,5884,5885,5886},
            [questKeys.specialFlags] = 1,
        },
        -- Horde
        [4108] = {
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887,5888,5889,5890,5891},
        },
        [4109] = {
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887,5888,5889,5890,5891},
        },
        [4110] = {
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887,5888,5889,5890,5891},
        },
        [4111] = {
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887,5888,5889,5890,5891},
        },
        [4112] = {
            [questKeys.startedBy] = {{9529},nil,nil},
            [questKeys.finishedBy] = {{9529},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {5887,5888,5889,5890,5891},
        },
        -----------------------
        [4121] = {
            [questKeys.triggerEnd] = {"Prisoner Transport", {[zoneIDs.BURNING_STEPPES]={{25.73,27.1}}}},
        },
        [4122] = {
            [questKeys.preQuestSingle] = {4082}, -- #1349
        },
        [4133] = {
            [questKeys.exclusiveTo] = {4134}, -- #1859
        },
        [4134] = {
            [questKeys.preQuestSingle] = {}, -- #1859
        },
        [4136] = {
            [questKeys.preQuestSingle] = {}, -- #4459
        },
        [4144] = {
            [questKeys.specialFlags] = 1, -- #1590
        },
        [4181] = {
            [questKeys.requiredSpecialization] = specKeys.ENGINEERING,
        },
        [4185] = {
            [questKeys.objectives] = {{{1749,"Advice from Lady Prestor"}}},
        },
        [4224] = {
            [questKeys.objectives] = {{{9563,"Ragged John's Story"}}},
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
        [4285] = {
            [questKeys.triggerEnd] = {"Discover and examine the Northern Crystal Pylon",{[zoneIDs.UN_GORO_CRATER]={{56,12}}}},
        },
        [4287] = {
            [questKeys.triggerEnd] = {"Discover and examine the Eastern Crystal Pylon",{[zoneIDs.UN_GORO_CRATER]={{77,50}}}},
        },
        [4288] = {
            [questKeys.triggerEnd] = {"Discover and examine the Western Crystal Pylon",{[zoneIDs.UN_GORO_CRATER]={{23,59}}}},
        },
        [4294] = {
            [questKeys.requiredSourceItems] = {12235,12236},
        },
        [4293] = {
            [questKeys.requiredSourceItems] = {12230,12234},
        },
        [4322] = {
            [questKeys.triggerEnd] = {"Jail Break!", {[zoneIDs.BLACKROCK_DEPTHS]={{-1,-1}}}},
        },
        [4342] = {
            [questKeys.objectives] = {{{9021,"Kharan's Tale"}}},
            [questKeys.preQuestSingle] = {4341},
        },
        [4361] = {
            [questKeys.preQuestSingle] = {4342},
        },
        [4451] = {
            [questKeys.startedBy] = {{8566,5840,5844,5846,15692,8504},nil,{11818}},
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
        [4493] = {
            [questKeys.preQuestSingle] = {4267},
        },
        [4494] = {
            [questKeys.preQuestSingle] = {32,7732},
        },
        [4496] = {
            [questKeys.preQuestSingle] = {4493,4494},
        },
        [4506] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Release the kitten near the Jadefire Satyrs' corrupted moonwell."), 0, {{"object", 148501}}}},
            [questKeys.triggerEnd] = {"Return the corrupted cat to Winna Hazzard", {[zoneIDs.FELWOOD]={{34.26,52.32}}}},
        },
        [4507] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Gorishi Queen Lure."), 0, {{"object", 174792}}}},
        },
        [4542] = {
            [questKeys.exclusiveTo] = {4841},
        },
        [4581] = {
            [questKeys.exclusiveTo] = {1011},
        },
        [4601] = {
            [questKeys.preQuestSingle] = {2951,4602},
            [questKeys.specialFlags] = 1,
        },
        [4602] = {
            [questKeys.preQuestSingle] = {2951,4601},
            [questKeys.specialFlags] = 1,
        },
        [4605] = {
            [questKeys.exclusiveTo] = {2952,4606},
        },
        [4606] = {
            [questKeys.exclusiveTo] = {2952,4605},
        },
        [4621] = {
            [questKeys.preQuestSingle] = {1036},
            [questKeys.requiredMinRep] = {87,3000},
            [questKeys.requiredMaxRep] = {21,-5999},
        },
        [4641] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- #877
            [questKeys.exclusiveTo] = {788}, -- #1956
        },
        [4729] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Empty Worg Pup Cage to capture it."), 0, {{"monster", 10221}}}},
        },
        [4734] = {
            [questKeys.objectives] = {nil,{{400062,"Test the Eggscilliscope Prototype"}}},
        },
        [4735] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Collect eggs using the Collectronic Module."), 0, {{"object", 400062}}}},
        },
        [4736] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4737] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [4742] = {
            [questKeys.startedBy] = {{10299}},
            [questKeys.finishedBy] = {{10299}},
        },
        [4743] = {
            [questKeys.requiredSourceItems] = {12339,12300,12323},
            [questKeys.startedBy] = {{10299}},
            [questKeys.finishedBy] = {{10299}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Beat Emberstrife till his will is broken, then place the Unforged Seal of Ascension before him and use the Orb of Draconic Energy."), 0, {{"monster", 10321}}},
			                               {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Flames of the Black Flight over it to create the Seal."), 0, {{"object", 175321}}},
			},
        },
        [4763] = {
            [questKeys.requiredSourceItems] = {12341,12342,12343,12347}, -- #798
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Xabraxxis once you have the required items from the Blackwood Stores."), 0, {{"object", 175338}}}},
        },
        [4764] = {
            [questKeys.preQuestSingle] = {}, -- #1916
        },
        [4766] = {
            [questKeys.exclusiveTo] = {4764} -- #1916
        },
        [4768] = {
            [questKeys.preQuestSingle] = {}, -- #1859
        },
        [4769] = {
            [questKeys.exclusiveTo] = {4768},
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
            [questKeys.specialFlags] = 1, -- #1367
        },
        [4786] = {
            [questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[zoneIDs.THE_BARRENS]={{62.52,35.47}}}},
        },
        [4811] = {
            [questKeys.triggerEnd] = {"Locate the large, red crystal on Darkshore's eastern mountain range",{[zoneIDs.DARKSHORE]={{47.24,48.68}}}}, -- #1373
        },
        [4841] = {
            [questKeys.preQuestSingle] = {},
        },
        [4822] = {
            [questKeys.objectivesText] = {"Get some Strawberry Ice Cream for your ward. The lad seems to prefer Tigule's brand ice cream."}, -- human orphan
            [questKeys.inGroupWith] = nil,
            [questKeys.preQuestGroup] = {1479,1558,1687},
            [questKeys.childQuests] = {},
        },
        [4866] = {
            [questKeys.objectives] = {{{9563,"Milked"}}},
        },
        [4867] = {
            [questKeys.requiredSourceItems] = {12533,12534},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Combine Omokk's Head with the Roughshod Pike."),0,{{"object", 175621}}},
			                               {nil, Questie.ICON_TYPE_OBJECT, l10n("Use it to instantly kill one nearby ogre."),0,{{"object", 400063}}},
			},
        },
        [4881] = {
            [questKeys.startedBy] = {{10617},nil,{12564}},
        },
        [4901] = {
            [questKeys.triggerEnd] = {"Discover the secret of the Altar of Elune", {[zoneIDs.WINTERSPRING]={{64.85,63.73}}}},
        },
        [4904] = {
            [questKeys.triggerEnd] = {"Escort Lakota Windsong from the Darkcloud Pinnacle.", {[zoneIDs.THOUSAND_NEEDLES]={{30.93,37.12}}}},
        },
        [4907] = {
            [questKeys.exclusiveTo] = {4734},
        },
        [4941] = {
            [questKeys.triggerEnd] = {"Council with Eitrigg.", {[zoneIDs.ORGRIMMAR]={{34.14,39.26}}}},
        },
        [4964] = {
            [questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[zoneIDs.THE_BARRENS]={{62.52,35.47}}}},
        },
        [4966] = {
            [questKeys.triggerEnd] = {"Protect Kanati Greycloud", {[zoneIDs.THOUSAND_NEEDLES]={{21.38,31.98}}}},
        },
        [4967] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [4968] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
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
        },
        [5059] = {
            [questKeys.preQuestSingle] = {5058}, -- #922
        },
        [5060] = {
            [questKeys.preQuestSingle] = {5058}, -- #922
        },
        [5063] = {
            [questKeys.specialFlags] = 1, -- #1335
        },
        [5067] = {
            [questKeys.specialFlags] = 1, -- #1335
        },
        [5068] = {
            [questKeys.specialFlags] = 1, -- #1335
        },
        [5082] = {
            [questKeys.preQuestSingle] = {}, -- #1824
        },
        [5088] = {
            [questKeys.triggerEnd] = {"Light the Sacred Fire of Life", {[zoneIDs.THOUSAND_NEEDLES]={{38.08,35.35}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Light the Sacred Fire of Life"),0,{{"object", 175944}}}},
        },
        [5089] = {
            [questKeys.startedBy] = {{9568},nil,{12780}},
        },
        [5092] = {
            [questKeys.preQuestSingle] = {},
        },
        [5096] = {
            [questKeys.triggerEnd] = {"Destroy the command tent and plant the Scourge banner in the camp", {[zoneIDs.WESTERN_PLAGUELANDS]={{40.72,52.04}}}},
            [questKeys.preQuestSingle] = {},
        },
        [5103] = {
            [questKeys.requiredSourceItems] = {12812},
        },
        [5122] = {
            [questKeys.specialFlags] = 1, -- #1140
        },
        [5123] = {
            [questKeys.startedBy] = {{10738},nil,{12842}},
        },
        [5124] = {
            [questKeys.requiredSkill] = {164,275},
        },
        [5126] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.SHAMAN,
            [questKeys.objectives] = {{{10918,"Listen to Lorax's Tale"}}},
            [questKeys.zoneOrSort] = sortKeys.BLACKSMITHING,
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
        [5261] = {
            [questKeys.exclusiveTo] = {33}, -- #1726
        },
        [5262] = {
            [questKeys.startedBy] = {{10813},nil,{13250}},
        },
        [5305]  ={
            [questKeys.exclusiveTo] = {8869},
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5306]  ={
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5307]  ={
            [questKeys.requiredSpecialization] = specKeys.BLACKSMITHING_WEAPON,
        },
        [5321] = {
            [questKeys.triggerEnd] = {"Escort Kerlonian Evershade to Maestra's Post", {[zoneIDs.ASHENVALE]={{26.77,36.91}}}},
            [questKeys.requiredSourceItems] = {13536},
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
            [questKeys.zoneOrSort] = zoneIDs.DIRE_MAUL,
        },
        [5561] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4700,4701,4702},4700,"Kodos Tamed"}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.DESOLACE]={{60.58,62}}}, Questie.ICON_TYPE_EVENT, l10n("Lure the Kodos to Smeed Scrabblescrew."),}},
        },
        [5582] = {
            [questKeys.startedBy] = {{10678},nil,{13920}},
        },
        [5622] = {
            [questKeys.questLevel] = 5, -- #2306
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
        [5639] = {
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
        [5647] = {
            [questKeys.startedBy] = {{11401},nil,nil}, -- #2424
        },
        [5676] = {
            [questKeys.exclusiveTo] = {5677,5678},
        },
        [5677] = {
            [questKeys.exclusiveTo] = {5676,5678},
        },
        [5678] = {
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
        [5713] = {
            [questKeys.triggerEnd] = {"Protect Aynasha", {[zoneIDs.DARKSHORE]={{45.87,90.42}}}},
        },
        [5721] = {
            [questKeys.requiredSourceItems] = {15209}, -- #857
            [questKeys.extraObjectives] = {{{[zoneIDs.EASTERN_PLAGUELANDS]={{38.8,91.2}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Relic Bundle in the Town Square."),}},
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
        [5882] = {
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.exclusiveTo] = {5883,5884,5885,5886},
        },
        [5883] = {
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.exclusiveTo] = {5882,5884,5885,5886},
        },
        [5884] = {
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.exclusiveTo] = {5882,5883,5885,5886},
        },
        [5885] = {
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.exclusiveTo] = {5882,5883,5884,5886},
        },
        [5886] = {
            [questKeys.startedBy] = {{9528},nil,nil},
            [questKeys.finishedBy] = {{9528},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {4101},
            [questKeys.exclusiveTo] = {5882,5883,5884,5885},
        },
        -- Horde
        [5887] = {
            [questKeys.preQuestSingle] = {4102},
            [questKeys.exclusiveTo] = {5888,5889,5890,5891},
            [questKeys.specialFlags] = 0,
        },
        [5888] = {
            [questKeys.preQuestSingle] = {4102},
            [questKeys.exclusiveTo] = {5887,5889,5890,5891},
            [questKeys.specialFlags] = 0,
        },
        [5889] = {
            [questKeys.preQuestSingle] = {4102},
            [questKeys.exclusiveTo] = {5887,5888,5890,5891},
            [questKeys.specialFlags] = 0,
        },
        [5890] = {
            [questKeys.preQuestSingle] = {4102},
            [questKeys.exclusiveTo] = {5887,5888,5889,5891},
            [questKeys.specialFlags] = 0,
        },
        [5891] = {
            [questKeys.preQuestSingle] = {4102},
            [questKeys.exclusiveTo] = {5887,5888,5889,5890},
            [questKeys.specialFlags] = 0,
        },
        [5892] = {
            [questKeys.questLevel] = 55,
        },
        [5893] = {
            [questKeys.questLevel] = 55,
        },
        [5923] = {
            [questKeys.startedBy] = {{4218},nil,nil},
        },
        [5924] = {
            [questKeys.startedBy] = {{5505},nil,nil},
        },
        [5925] = {
            [questKeys.startedBy] = {{3602},nil,nil},
        },
        [5926] = {
            [questKeys.startedBy] = {{6746},nil,nil},
        },
        [5927] = {
            [questKeys.startedBy] = {{6929},nil,nil},
        },
        [5928] = {
            [questKeys.startedBy] = {{3064},nil,nil},
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
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Lord Kragaru"), 0, {{"object", 400060}}}},
        },
        [6041] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Plant the bomb!"), 0, {{"object", 177668}}}},
        },
        [6061] = {
            [questKeys.objectives] = {{{2956, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6062] = {
            [questKeys.objectives] = {{{3099, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6063] = {
            [questKeys.objectives] = {{{1998, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6064] = {
            [questKeys.objectives] = {{{1126, nil}}},
            [questKeys.questFlags] = 0,
            [questKeys.specialFlags] = 0,
        },
        [6065] = {
            [questKeys.exclusiveTo] = {6066,6067,6061},
        },
        [6066] = {
            [questKeys.exclusiveTo] = {6065,6067,6061},
        },
        [6067] = {
            [questKeys.exclusiveTo] = {6065,6066,6061},
        },
        [6068] = {
            [questKeys.startedBy] = {{3407},nil,nil}, -- #2167
            [questKeys.exclusiveTo] = {6069,6070,6062}, -- #1795
        },
        [6069] = {
            [questKeys.startedBy] = {{11814},nil,nil}, -- #1523
            [questKeys.exclusiveTo] = {6068,6070,6062}, -- #1795
        },
        -- "The Hunter's Path" now started by "Kary Thunderhorn" in Thunder Bluff
        [6070] = {
            [questKeys.startedBy] = {{3038},nil,nil},
            [questKeys.exclusiveTo] = {6068,6069,6062}, -- #1795
        },
        [6071] = {
            [questKeys.exclusiveTo] = {6072,6073,6721,6722,6063},
        },
        [6072] = {
            [questKeys.exclusiveTo] = {6071,6073,6721,6722,6063},
        },
        [6073] = {
            [questKeys.startedBy] = {{5515},nil,nil},
            [questKeys.exclusiveTo] = {6071,6072,6721,6722,6063},
        },
        [6074] = {
            [questKeys.startedBy] = {{5516},nil,nil},
            [questKeys.exclusiveTo] = {6075,6076,6064},
        },
        [6075] = {
            [questKeys.startedBy] = {{11807},nil,nil},
            [questKeys.exclusiveTo] = {6074,6076,6064},
        },
        [6076] = {
            [questKeys.exclusiveTo] = {6074,6075,6064},
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
        [6136] = {
            [questKeys.preQuestSingle] = {6133}, -- #1572
        },
        [6141] = {
            [questKeys.exclusiveTo] = {261}, -- #1744
        },
        [6144] = {
            [questKeys.preQuestGroup] = {6022,6042,6133,6135,6136}, -- #1950
        },
        [6163] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {6022,6042,6133,6135,6136}, -- #1950
        },
        [6382] = {
            [questKeys.preQuestSingle] = {882},
            [questKeys.exclusiveTo] = {235,742,6383},
        },
        [6383] = {
            [questKeys.preQuestSingle] = {},
        },
        [6403] = {
            [questKeys.triggerEnd] = {"Reginald's March", {[zoneIDs.STORMWIND_CITY]={{77.57,18.59}}}},
        },
        [6482] = {
            [questKeys.triggerEnd] = {"Escort Ruul from the Thistlefurs.", {[zoneIDs.ASHENVALE]={{38.53,37.32}}}},
        },
        [6522] = {
            [questKeys.startedBy] = {{4421},nil,{17008}},
        },
        [6523] = {
            [questKeys.triggerEnd] = {"Kaya Escorted to Camp Aparaje", {[zoneIDs.STONETALON_MOUNTAINS]={{77.1,90.85}}}},
        },
        [6544] = {
            [questKeys.triggerEnd] = {"Take Silverwing Outpost.", {[zoneIDs.ASHENVALE]={{64.65,75.35}}}},
        },
        [6562] = {
            [questKeys.exclusiveTo] = {6563}, -- #1826
        },
        [6563] = {
            [questKeys.preQuestSingle] = {}, -- #1826
        },
        [6564] = {
            [questKeys.startedBy] = {{4802},nil,{16790}},
        },
        [6566] = {
            [questKeys.triggerEnd] = {"Thrall's Tale", {[zoneIDs.ORGRIMMAR]={{31.78,37.81}}}},
        },
        [6603] = {
            [questKeys.exclusiveTo] = {5082},
        },
        [6604] = {
            [questKeys.exclusiveTo] = {4861},
        },
        [6605] = {
            [questKeys.exclusiveTo] = {4505}, -- #1859 -- #1856
        },
        [6608] = {
            [questKeys.exclusiveTo] = {6607}, -- #1186
        },
        [6609] = {
            [questKeys.exclusiveTo] = {6607}, -- #1154
        },
        [6611] = {
            [questKeys.exclusiveTo] = {6610}, -- #2070
        },
        [6612] = {
            [questKeys.exclusiveTo] = {6610}, -- #2070
        },
        [6622] = {
            [questKeys.triggerEnd] = {"15 Patients Saved!", {[zoneIDs.DUSTWALLOW_MARSH]={{67.79,49.06}}}},
        },
        [6623] = {
            [questKeys.exclusiveTo] = {6622},
        },
        [6624] = {
            [questKeys.triggerEnd] = {"15 Patients Saved!", {[zoneIDs.DUSTWALLOW_MARSH]={{67.79,49.06}}}},
        },
        [6625] = {
            [questKeys.exclusiveTo] = {6624}, -- #1723
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
            [questKeys.objectives] = {{{13016,"Rats Captured"}}},
        },
        [6721] = {
            [questKeys.startedBy] = {{5116},nil,nil},
            [questKeys.exclusiveTo] = {6071,6072,6073,6722,6063},
        },
        [6722] = {
            [questKeys.startedBy] = {{1231},nil,nil},
            [questKeys.exclusiveTo] = {6071,6072,6073,6721,6063},
        },
        [6762] = {
            [questKeys.preQuestSingle] = {1015,1019,1047,6761},
        },
        [6861] = {
            [questKeys.objectivesText] = {},
        },
        [6862] = {
            [questKeys.objectivesText] = {},
        },
        [6922] = {
            [questKeys.startedBy] = {{12876},nil,{16782}},
            [questKeys.zoneOrSort] = 719,
        },
        [6961] = {
            [questKeys.exclusiveTo] = {7021,7024},
            [questKeys.nextQuestInChain] = 6962,
        },
        [6962] = {
            [questKeys.objectivesText] = {"Bring 5 Gingerbread Cookies and an Ice Cold Milk to Greatfather Winter in Orgrimmar."},
        },
        [6981] = {
            [questKeys.startedBy] = {{3654},nil,{10441}},
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
            [questKeys.triggerEnd] = {"Frostwolf Muzzled and Returned", {
                [zoneIDs.ALTERAC_MOUNTAINS]={{67,51.78}}},
            },
        },
        [7002] = {
            [questKeys.objectivesText] = {},
        },
        [7021] = {
            [questKeys.finishedBy] = {{13445},nil},
            [questKeys.exclusiveTo] = {6961,7024},
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
            [questKeys.nextQuestInChain] = 6962,
        },
        [7026] = {
            [questKeys.objectivesText] = {},
        },
        [7027] = {
            [questKeys.triggerEnd] = {"Ram Collared and Returned", {
                [zoneIDs.ALTERAC_MOUNTAINS]={{34.58,74.94}}},
            },
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
            [questKeys.requiredSourceItems] = {17757,17761,17762,17763,17764,17765,17781},
            [questKeys.sourceItemId] = 17757,
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
            [questKeys.exclusiveTo] = {7122},
        },
        [7123] = {
            [questKeys.exclusiveTo] = {7124},
        },
        [7141] = {
            [questKeys.triggerEnd] = {"Defeat Drek'thar.",{[zoneIDs.ALTERAC_VALLEY]={{47.22,86.95}}}},
        },
        [7142] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.triggerEnd] = {"Defeat Vanndar Stormpike.",{[zoneIDs.ALTERAC_VALLEY]={{42.29,12.85}}}},
        },
        [7161] = {
            [questKeys.requiredRaces] = raceIDs.NONE, -- #813
        },
        [7165] = {
            [questKeys.requiredRaces] = raceIDs.NONE, -- #813
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
            [questKeys.exclusiveTo] = {7161},
        },
        [7261] = {
            [questKeys.exclusiveTo] = {7162},
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
            [questKeys.specialFlags] = 1,
        },
        [7485] = {
            [questKeys.preQuestSingle] = {7481,7482},
        },
        [7488] = {
            [questKeys.preQuestSingle] = {}, -- #1740
        },
        [7489] = {
            [questKeys.preQuestSingle] = {}, -- #1514
        },
        [7490] = {
            [questKeys.startedBy] = {{10184},nil,{18422}},
        },
        [7492] = {
            [questKeys.startedBy] = {{10879,10880,10881},nil,nil}, -- #1350
        },
        [7494] = {
            [questKeys.startedBy] = {{2198,10877,10878},nil,nil}, -- #2489
        },
        [7495] = {
            [questKeys.startedBy] = {{10184},nil,{18423}},
        },
        [7507] = {
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
            [questKeys.requiredSourceItems] = {18663,18629,18670,18818},
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
            [questKeys.zoneOrSort] = 1637,
            [questKeys.exclusiveTo] = {8258}, -- 8258 after Phase 4
            [questKeys.childQuests] = {7669},
        },
        [7669] = { --#1449
            [questKeys.name] = "Again Into the Great Ossuary",
            [questKeys.startedBy] = {{13417},nil,nil},
            [questKeys.finishedBy] = {{13417},nil},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.zoneOrSort] = -141,
            [questKeys.specialFlags] = 1,
            [questKeys.parentQuest] = 8258,
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
            [questKeys.zoneOrSort] = -141,
        },
        [7735] = {
            [questKeys.startedBy] = {{5299},nil,{18969}},
        },
        [7738] = {
            [questKeys.startedBy] = {{5299},nil,{18972}},
        },
        [7761] = {
            [questKeys.startedBy] = {{9046},nil,{18987}},
        },
        [7781] = {
            [questKeys.startedBy] = {{11583},nil,{19003}},
        },
        [7783] = {
            [questKeys.startedBy] = {{11583},nil,{19002}},
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
            [questKeys.specialFlags] = 1, -- #1589
        },
        [7843] = {
            [questKeys.triggerEnd] = {"Message to the Wildhammer Delivered", {[zoneIDs.THE_HINTERLANDS]={{14.34,48.07}}}},
        },
        [7863] = {
            [questKeys.zoneOrSort] = 3277,
        },
        [7864] = {
            [questKeys.zoneOrSort] = 3277,
        },
        [7865] = {
            [questKeys.zoneOrSort] = 3277,
        },
        [7866] = {
            [questKeys.zoneOrSort] = 3277,
        },
        [7867] = {
            [questKeys.zoneOrSort] = 3277,
        },
        [7868] = {
            [questKeys.zoneOrSort] = 3277,
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
            [questKeys.specialFlags] = 1,
        },
        [7938] = {
            [questKeys.specialFlags] = 1,
        },
        [7945] = {
            [questKeys.specialFlags] = 1,
        },
        [7946] = {
            [questKeys.questLevel] = 60,
            [questKeys.specialFlags] = 1,
        },
        [8105] = {
            [questKeys.specialFlags] = 0,
        },
        [8114] = {
            [questKeys.requiredMinRep] = {509,3000},
            [questKeys.triggerEnd] = {"Control Four Bases.", {[zoneIDs.ARATHI_HIGHLANDS]={{46.03,45.3}}}},
        },
        [8115] = {
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
            [questKeys.requiredMinRep] = {510,42000},
        },
        [8149] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place a tribute at Uther's Tomb"),0,{{"object", 180204},}}},
        },
        [8150] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place a tribute at Grom's Monument"),0,{{"object", 180205},}}},
        },
        [8166] = {
            [questKeys.specialFlags] = 0,
        },
        [8167] = {
            [questKeys.specialFlags] = 0,
        },
        [8168] = {
            [questKeys.specialFlags] = 0,
        },
        [8169] = {
            [questKeys.specialFlags] = 0,
        },
        [8170] = {
            [questKeys.specialFlags] = 0,
        },
        [8171] = {
            [questKeys.specialFlags] = 0,
        },
        [8183] = {
            [questKeys.startedBy] = {{14834},nil,{19802}},
        },
        [8184] = {
            [questKeys.requiredClasses] = classIDs.WARRIOR,
        },
        [8185] = {
            [questKeys.requiredClasses] = classIDs.PALADIN,
        },
        [8186] = {
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [8187] = {
            [questKeys.requiredClasses] = classIDs.HUNTER,
        },
        [8188] = {
            [questKeys.requiredClasses] = classIDs.SHAMAN,
        },
        [8189] = {
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [8190] = {
            [questKeys.requiredClasses] = classIDs.WARLOCK,
        },
        [8191] = {
            [questKeys.requiredClasses] = classIDs.PRIEST,
        },
        [8192] = {
            [questKeys.requiredClasses] = classIDs.DRUID,
        },
        [8251] = {
            [questKeys.preQuestSingle] = {},
        },
        [8258] = {
            [questKeys.exclusiveTo] = {7668}, -- 7668 before Phase 4
            [questKeys.childQuests] = {7669},
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
        [8280] = {
            [questKeys.exclusiveTo] = {}, -- #1873
        },
        [8286] = {
            [questKeys.triggerEnd] = {"Discover the Brood of Nozdormu.",{[zoneIDs.TANARIS]={{63.43, 50.61}}}},
        },
        [8289] = { -- #1435
            [questKeys.startedBy] = {{14733},nil,nil},
            [questKeys.finishedBy] = {{14733},nil},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8296] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8304] = {
            [questKeys.objectives] = {{{15171,"Frankal Questioned"},{15170,"Rutgar Questioned"}},nil,nil,nil},
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
        [8331]  ={
            [questKeys.exclusiveTo] = {8332},
        },
        [8332] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),2,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8341] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."),2,{{"object", 180461},{"object", 180534},{"object", 180554},}}},
        },
        [8348] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Duke using a full Twilight set and neck."),0,{{"object", 180461},{"object", 180534},{"object", 180554},}}},
        },
        [8352] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Lord using a full Twilight set, neck and ring."),0,{{"object", 180466},{"object", 180539},{"object", 180559},}}},
        },
        [8353] = {
            [questKeys.objectives] = {{{5111, "Cluck like a chicken for Innkeeper Firebrew"}}},
            [questKeys.specialFlags] = 1,
        },
        [8354] = {
            [questKeys.objectives] = {{{6741, "Cluck like a chicken for Innkeeper Norman"}}},
            [questKeys.specialFlags] = 1,
        },
        [8355] = {
            [questKeys.objectives] = {{{6826, "Do the \"train\" for Talvash"}}},
            [questKeys.specialFlags] = 1,
        },
        [8356] = {
            [questKeys.objectives] = {{{6740, "Flex for Innkeeper Allison"}}},
            [questKeys.specialFlags] = 1,
        },
        [8357] = {
            [questKeys.objectives] = {{{6735, "Dance for Innkeeper Saelienne"}}},
            [questKeys.specialFlags] = 1,
        },
        [8358] = {
            [questKeys.objectives] = {{{11814, "Do the \"train\" for Kali Remik"}}},
            [questKeys.specialFlags] = 1,
        },
        [8359] = {
            [questKeys.objectives] = {{{6929, "Flex for Innkeeper Gryshka"}}},
            [questKeys.specialFlags] = 1,
        },
        [8360] = {
            [questKeys.objectives] = {{{6746, "Dance for Innkeeper Pala"}}},
            [questKeys.specialFlags] = 1,
        },
        [8361] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Templar using a full Twilight set."),0,{{"object", 180456},{"object", 180518},{"object", 180529},{"object", 180544},{"object", 180549},{"object", 180564},}}},
        },
        [8368] = {
            [questKeys.exclusiveTo] = {8426,8427,8428,8429,8430},
        },
        [8372] = {
            [questKeys.exclusiveTo] = {8399,8400,8401,8402,8403},
        },
        [8373] = {
            [questKeys.objectives] = {nil,{{180449,"Clean up a stink bomb that's been dropped on Southshore!"}}},
        },
        [8399] = {
            [questKeys.exclusiveTo] = {8372,8400,8401,8402,8403},
        },
        [8400] = {
            [questKeys.exclusiveTo] = {8372,8399,8401,8402,8403},
        },
        [8401] = {
            [questKeys.exclusiveTo] = {8372,8399,8400,8402,8403},
        },
        [8402] = {
            [questKeys.exclusiveTo] = {8372,8399,8400,8401,8403},
        },
        [8403] = {
            [questKeys.exclusiveTo] = {8372,8399,8400,8401,8402},
        },
        [8423] = {
            [questKeys.preQuestSingle] = {8417},
        },
        [8426] = {
            [questKeys.exclusiveTo] = {8368,8427,8428,8429,8430},
        },
        [8427] = {
            [questKeys.exclusiveTo] = {8368,8426,8428,8429,8430},
        },
        [8428] = {
            [questKeys.exclusiveTo] = {8368,8426,8427,8429,8430},
        },
        [8429] = {
            [questKeys.exclusiveTo] = {8368,8426,8427,8428,8430},
        },
        [8430] = {
            [questKeys.exclusiveTo] = {8368,8426,8427,8428,8429},
        },
        [8438] = {
            [questKeys.zoneOrSort] = sortKeys.ARATHI_BASIN,
        },
        [8446] = {
            [questKeys.startedBy] = {{14887,14888,14889,14890},nil,{20644}},
        },
        [8447] = {
            [questKeys.triggerEnd] = {"Waking Legends.",{[zoneIDs.MOONGLADE]={{40.0,48.6}}}},
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
            [questKeys.specialFlags] = 1,
        },
        [8494] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8495] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8498] = {
            [questKeys.specialFlags] = 1,
        },
        [8499] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8500] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.specialFlags] = 1,
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
            [questKeys.specialFlags] = 1,
        },
        [8513] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8514] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8515] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8516] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8517] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8518] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8520] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8521] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8522] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8523] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
        },
        [8524] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8525] = {
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = 1,
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
            [questKeys.specialFlags] = 1,
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
            [questKeys.specialFlags] = 1,
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
        [8552] = {
            [questKeys.startedBy] = {{1493},nil,{3985}},
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
        [8791] = {
            [questKeys.startedBy] = {{15339},nil,{21220}},
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
        [8801] = {
            [questKeys.startedBy] = {{15727},nil,{21221}},
        },
        [8804] = {
            [questKeys.specialFlags] = 1, -- #2401
        },
        [8805] = {
            [questKeys.specialFlags] = 1, -- #2401
        },
        [8806] = {
            [questKeys.specialFlags] = 1, -- #2401
        },
        [8807] = {
            [questKeys.specialFlags] = 1, -- #2401
        },
        [8829] = {
            [questKeys.specialFlags] = 1,
        },
        [8846] = {
            [questKeys.specialFlags] = 1,
        },
        [8847] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = 1,
        },
        [8848] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = 1,
        },
        [8849] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = 1,
        },
        [8850] = {
            [questKeys.startedBy] = {{15701},nil,nil},
            [questKeys.finishedBy] = {{15701},nil},
            [questKeys.specialFlags] = 1,
        },
        [8851] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = 1,
        },
        [8852] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = 1,
        },
        [8853] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = 1,
        },
        [8854] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = 1,
        },
        [8855] = {
            [questKeys.startedBy] = {{15700},nil,nil},
            [questKeys.finishedBy] = {{15700},nil},
            [questKeys.specialFlags] = 1,
        },
        [8863] = {
            [questKeys.specialFlags] = 1,
        },
        [8864] = {
            [questKeys.specialFlags] = 1,
        },
        [8865] = {
            [questKeys.specialFlags] = 1,
        },
        [8867] = {
            [questKeys.requiredSourceItems] = {21557,21558,21559,21571,21574,21576},
            [questKeys.objectives] = {nil,{{180771,"Lunar Fireworks Fired"},{180772,"Lunar Fireworks Cluster Fired"}}},
        },
        [8868] = {
            [questKeys.triggerEnd] = {"Receive Elune's Blessing.", {[zoneIDs.MOONGLADE]={{63.89,62.5}}}},
        },
        [8869]  ={
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
            [questKeys.specialFlags] = 1,
        },
        [8877] = {
            [questKeys.specialFlags] = 1,
        },
        [8878] = {
            [questKeys.specialFlags] = 1,
        },
        [8879] = {
            [questKeys.specialFlags] = 1,
        },
        [8880] = {
            [questKeys.specialFlags] = 1,
        },
        [8881] = {
            [questKeys.specialFlags] = 1,
        },
        [8882] = {
            [questKeys.specialFlags] = 1,
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
        [8980] = { -- bad race data
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
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
            [questKeys.specialFlags] = 1,
        },
        [9036] = {
            [questKeys.specialFlags] = 1,
        },
        [9037] = {
            [questKeys.specialFlags] = 1,
        },
        [9038] = {
            [questKeys.specialFlags] = 1,
        },
        [9039] = {
            [questKeys.specialFlags] = 1,
        },
        [9040] = {
            [questKeys.specialFlags] = 1,
        },
        [9041] = {
            [questKeys.specialFlags] = 1,
        },
        [9042] = {
            [questKeys.specialFlags] = 1,
        },
        [9043] = {
            [questKeys.specialFlags] = 1,
        },
        [9044] = {
            [questKeys.specialFlags] = 1,
        },
        [9045] = {
            [questKeys.specialFlags] = 1,
        },
        [9046] = {
            [questKeys.specialFlags] = 1,
        },
        [9047] = {
            [questKeys.specialFlags] = 1,
        },
        [9048] = {
            [questKeys.specialFlags] = 1,
        },
        [9049] = {
            [questKeys.specialFlags] = 1,
        },
        [9050] = {
            [questKeys.specialFlags] = 1,
        },
        [9052] = {
            [questKeys.preQuestSingle] = {},
        },
        [9054] = {
            [questKeys.specialFlags] = 1,
        },
        [9055] = {
            [questKeys.specialFlags] = 1,
        },
        [9056] = {
            [questKeys.specialFlags] = 1,
        },
        [9057] = {
            [questKeys.specialFlags] = 1,
        },
        [9058] = {
            [questKeys.specialFlags] = 1,
        },
        [9059] = {
            [questKeys.specialFlags] = 1,
        },
        [9060] = {
            [questKeys.specialFlags] = 1,
        },
        [9061] = {
            [questKeys.specialFlags] = 1,
        },
        [9063] = {
            [questKeys.exclusiveTo] = {9052},
            [questKeys.zoneOrSort] = 493,
        },
        [9069] = {
            [questKeys.specialFlags] = 1,
        },
        [9070] = {
            [questKeys.specialFlags] = 1,
        },
        [9071] = {
            [questKeys.specialFlags] = 1,
        },
        [9072] = {
            [questKeys.specialFlags] = 1,
        },
        [9073] = {
            [questKeys.specialFlags] = 1,
        },
        [9074] = {
            [questKeys.specialFlags] = 1,
        },
        [9075] = {
            [questKeys.specialFlags] = 1,
        },
        [9077] = {
            [questKeys.specialFlags] = 1,
        },
        [9078] = {
            [questKeys.specialFlags] = 1,
        },
        [9079] = {
            [questKeys.specialFlags] = 1,
        },
        [9080] = {
            [questKeys.specialFlags] = 1,
        },
        [9081] = {
            [questKeys.specialFlags] = 1,
        },
        [9082] = {
            [questKeys.specialFlags] = 1,
        },
        [9083] = {
            [questKeys.specialFlags] = 1,
        },
        [9084] = {
            [questKeys.specialFlags] = 1,
        },
        [9085] = {
            [questKeys.specialFlags] = 1,
        },
        [9086] = {
            [questKeys.specialFlags] = 1,
        },
        [9087] = {
            [questKeys.specialFlags] = 1,
        },
        [9088] = {
            [questKeys.specialFlags] = 1,
        },
        [9089] = {
            [questKeys.specialFlags] = 1,
        },
        [9090] = {
            [questKeys.specialFlags] = 1,
        },
        [9091] = {
            [questKeys.specialFlags] = 1,
        },
        [9092] = {
            [questKeys.specialFlags] = 1,
        },
        [9093] = {
            [questKeys.specialFlags] = 1,
        },
        [9095] = {
            [questKeys.specialFlags] = 1,
        },
        [9096] = {
            [questKeys.specialFlags] = 1,
        },
        [9097] = {
            [questKeys.specialFlags] = 1,
        },
        [9098] = {
            [questKeys.specialFlags] = 1,
        },
        [9099] = {
            [questKeys.specialFlags] = 1,
        },
        [9100] = {
            [questKeys.specialFlags] = 1,
        },
        [9101] = {
            [questKeys.specialFlags] = 1,
        },
        [9102] = {
            [questKeys.specialFlags] = 1,
        },
        [9103] = {
            [questKeys.specialFlags] = 1,
        },
        [9104] = {
            [questKeys.specialFlags] = 1,
        },
        [9105] = {
            [questKeys.specialFlags] = 1,
        },
        [9106] = {
            [questKeys.specialFlags] = 1,
        },
        [9107] = {
            [questKeys.specialFlags] = 1,
        },
        [9108] = {
            [questKeys.specialFlags] = 1,
        },
        [9109] = {
            [questKeys.specialFlags] = 1,
        },
        [9110] = {
            [questKeys.specialFlags] = 1,
        },
        [9111] = {
            [questKeys.specialFlags] = 1,
        },
        [9112] = {
            [questKeys.specialFlags] = 1,
        },
        [9113] = {
            [questKeys.specialFlags] = 1,
        },
        [9114] = {
            [questKeys.specialFlags] = 1,
        },
        [9115] = {
            [questKeys.specialFlags] = 1,
        },
        [9116] = {
            [questKeys.specialFlags] = 1,
        },
        [9117] = {
            [questKeys.specialFlags] = 1,
        },
        [9118] = {
            [questKeys.specialFlags] = 1,
        },
        [9120] = {
            [questKeys.startedBy] = {{15990},nil,{22520}},
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
        [9154] = {
            [questKeys.questLevel] = 60,
        },
        [9165] = {
            [questKeys.specialFlags] = 1,
        },
        [9211] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9213] = {
            [questKeys.requiredMinRep] = {529,3000},
        },
        [9223] = {
            [questKeys.specialFlags] = 1,
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
        },
        [9238] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9239] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9240] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.MAGE + classIDs.WARLOCK,
        },
        [9241] = {
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9242] = {
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9243] = {
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.DRUID,
        },
        [9244] = {
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9245] = {
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9246] = {
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.SHAMAN,
        },
        [9248] = {
            [questKeys.requiredMinRep] = {609,0},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon a Lord using a full Twilight set, neck and ring."),0,{{"object", 180466},{"object", 180539},{"object", 180559},}}},
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
        },
        [9264] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.MULGORE] = {{38.9,37.1}}}},
        },
        [9265] = {
            [questKeys.triggerEnd] = {"Investigate a circle", {[zoneIDs.TIRISFAL_GLADES] = {{60.4,61.7}}}},
        },
        [9319] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [9322] = {
            [questKeys.requiredLevel] = 1,
        },
        [9323] = {
            [questKeys.requiredLevel] = 1,
        },
        [9386] = {
            [questKeys.preQuestSingle] = {9319},
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.specialFlags] = 1,
        },
        [9415] = {
            [questKeys.exclusiveTo] = {},
        },
        [9416] = {
            [questKeys.exclusiveTo] = {},
        },
        [9419] = {
            [questKeys.preQuestSingle] = {},
        },
        [9422] = {
            [questKeys.preQuestSingle] = {},
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
            [questKeys.startedBy] = {{332,918,3327,3328,3401,4214,4215,4163,4582,4583,4584,5165,5166,5167,6467,13283},nil,{17126}}
        },
        [7562] = {
            [questKeys.startedBy] = {{5753,5815},nil,nil},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8151] = {
            [questKeys.startedBy] = {{3039,3352},nil,nil},
        },
        [8233] = {
            [questKeys.startedBy] = {{3328,4583},nil,nil},
        },
        [8250] = {
            [questKeys.startedBy] = {{3047,4567,7311},nil,nil},
        },
        [8254] = {
            [questKeys.startedBy] = {{6018},nil,nil},
        },
        [8417] = {
            [questKeys.startedBy] = {{3041,3354,4593},nil,nil},
        },
        [8419] = {
            [questKeys.startedBy] = {{3326,4563},nil,nil},
        },
        [8904] = {
            [questKeys.exclusiveTo] = {8900,8901,8902,8979}
        },
        [9063] = {
            [questKeys.startedBy] = {{3033,12042},nil,nil},
        },
        [9330] = {
            [questKeys.startedBy] = {nil,{181332},{23182}},
        },
        [9331] = {
            [questKeys.startedBy] = {nil,{181333},{23183}},
        },
        [9332] = {
            [questKeys.startedBy] = {nil,{181334},{23184}},
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
            [questKeys.startedBy] = {{918,4163,5165},nil,{17126}}
        },
        [7562] = {
            [questKeys.startedBy] = {{5520,6382},nil,nil},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8151] = {
            [questKeys.startedBy] = {{4205,5116,5516},nil,nil},
        },
        [8233] = {
            [questKeys.startedBy] = {{918,4163,5165},nil,nil},
        },
        [8250] = {
            [questKeys.startedBy] = {{331,7312},nil,nil},
        },
        [8254] = {
            [questKeys.startedBy] = {{5489,11406},nil,nil},
        },
        [8417] = {
            [questKeys.startedBy] = {{5113,5479},nil,nil},
        },
        [8419] = {
            [questKeys.startedBy] = {{461,5172},nil,nil},
        },
        [9063] = {
            [questKeys.startedBy] = {{4217,5505,12042},nil,nil},
        },
        [9324] = {
            [questKeys.startedBy] = {nil,{181336},{23179}},
        },
        [9325] = {
            [questKeys.startedBy] = {nil,{181337},{23180}},
        },
        [9326] = {
            [questKeys.startedBy] = {nil,{181335},{23181}},
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
