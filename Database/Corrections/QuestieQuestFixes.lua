---@class QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:CreateModule("QuestieQuestFixes")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

function QuestieQuestFixes:Load()
    table.insert(QuestieDB.questData, 7668, {}) -- Add missing quest index
    table.insert(QuestieDB.questData, 7669, {}) -- Add missing quest index
    table.insert(QuestieDB.questData, 7670, {}) -- Add missing quest index #1432

    return {
        [2] = {
            [QuestieDB.questKeys.startedBy] = {{12676},nil,{16305}},
        },
        [5] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1198
        },
        [23] = {
            [QuestieDB.questKeys.startedBy] = {{12678},nil,{16303}},
        },
        [24] = {
            [QuestieDB.questKeys.startedBy] = {{12677},nil,{16304}},
        },
        [25] = {
            [QuestieDB.questKeys.triggerEnd] = {"Scout the gazebo on Mystral Lake that overlooks the nearby Alliance outpost.",{[331]={{48.92,69.56},},},},
        },
        [26] = { -- Switch Alliance and Horde Druid quest IDs #948
            [QuestieDB.questKeys.startedBy] = {{4217,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 8,
            [QuestieDB.questKeys.nextQuestInChain] = 29,
        },
        [27] = { -- Switch Alliance and Horde Druid quest IDs #948
            [QuestieDB.questKeys.startedBy] = {{3033,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 32,
            [QuestieDB.questKeys.nextQuestInChain] = 28,
        },
        [28] = {
            [QuestieDB.questKeys.triggerEnd] = {"Complete the Trial of the Lake.", {[493]={{36.17,41.67},},},},
        },
        [29] = {
            [QuestieDB.questKeys.triggerEnd] = {"Complete the Trial of the Lake.", {[493]={{36.17,41.67},},},},
        },
        [33] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [46] = {
            [QuestieDB.questKeys.preQuestSingle] = {39},
        },
        [90] = {
            [QuestieDB.questKeys.requiredSkill] = {185, 50}
        },
        [100] = {
            [QuestieDB.questKeys.childQuests] = {1103}, -- #1658
        },
        --[103] = { -- bad race data (actually this is correct)
        --    [QuestieDB.questKeys.requiredRaces] = 77,
        --},
        --[104] = { -- bad race data (actually this is correct)
        --    [QuestieDB.questKeys.requiredRaces] = 77,
        --},
        [123] = {
            [QuestieDB.questKeys.startedBy] = {{100},nil,{1307}},
        },
        [148] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1173
        },
        --[152] = { -- bad race data (actually this is correct)
        --    [QuestieDB.questKeys.requiredRaces] = 77,
        --},
        [163] = {
            [QuestieDB.questKeys.exclusiveTo] = {5}, -- Raven Hill breadcrumb
        },
        [164] = {
            [QuestieDB.questKeys.exclusiveTo] = {95}, -- deliveries to sven is a breadcrumb
        },
        [165] = {
            [QuestieDB.questKeys.exclusiveTo] = {148}, --#1173
        },
        [219] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Corporal Keeshan back to Redridge", {[44]={{33.36,48.7},},},},
        },
        [235] = {
            [QuestieDB.questKeys.exclusiveTo] = {742,6382,6383,},
        },
        [254] = {
            [QuestieDB.questKeys.parentQuest] = 253,
        },
        [273] = {
            [QuestieDB.questKeys.triggerEnd] = {"Find Huldar, Miran, and Saean",{[38]={{51.16, 68.96},},},},
        },
        [308] = {
            [QuestieDB.questKeys.exclusiveTo] = {311}, -- distracting jarven can't be completed once you get the followup
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [309] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Miran to the excavation site", {[38]={{65.12,65.77},},},},
        },
        [310] = {
            [QuestieDB.questKeys.childQuests] = {403},
        },
        [364] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #882
        },
        [367] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #888
        },
        [368] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #888
        },
        [369] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #888
        },
        [373] = {
            [QuestieDB.questKeys.startedBy] = {{639},nil,{2874}},
        },
        [374] = {
            [QuestieDB.questKeys.preQuestSingle] = {427}, -- proof of demise requires at war with the scarlet crusade
        },
        [403] = {
            [QuestieDB.questKeys.specialFlags] = 1,
            [QuestieDB.questKeys.parentQuest] = 310,
        },
        [410] = { -- the dormant shade
            [QuestieDB.questKeys.preQuestSingle] = {366}, -- #638
            [QuestieDB.questKeys.exclusiveTo] = {411}, -- #752
        },
        [415] = {
            [QuestieDB.questKeys.exclusiveTo] = {413}, -- cant complete rejolds new brew if you do shimmer stout (see issue 567)
        },
        [428] = {
            [QuestieDB.questKeys.exclusiveTo] = {429}, -- lost deathstalkers breadcrumb
        },
        [429] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1843
        },
        [431] = { -- candles of beckoning
            [QuestieDB.questKeys.preQuestSingle] = {366}, -- #638
            [QuestieDB.questKeys.exclusiveTo] = {411}, -- #752
        },
        [434] = {
            [QuestieDB.questKeys.triggerEnd] = {"Overhear Lescovar and Marzon's Conversation", {[1519]={{68.66,14.44},},},},
        },
        [435] = {
            [QuestieDB.questKeys.triggerEnd] = {"Erland must reach Rane Yorick", {[130]={{54.37,13.38},},},},
        },
        [437] = {
            [QuestieDB.questKeys.triggerEnd] = {"Enter the Dead Fields",{[130]={{45.91, 21.27},},},},
        },
        [452] = {
            [QuestieDB.questKeys.triggerEnd] = {"Aid Faerleia in killing the Pyrewood Council", {[130]={{46.51,74.07},},},},
        },
        [455] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1858
        },
        [460] = {
            [QuestieDB.questKeys.startedBy] = {{1939},nil,{3317,},},
        },
        [463] = {
            [QuestieDB.questKeys.exclusiveTo] = {276}, --greenwarden cant be completed if you have trampling paws
        },
        [464] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #809
        },
        [467] = {
            [QuestieDB.questKeys.startedBy] = {{1340,2092,},nil,nil,}, -- #1379
        },
        [468] = {
            [QuestieDB.questKeys.exclusiveTo] = {455}, -- #1858
        },
        [473] = {
            [QuestieDB.questKeys.preQuestSingle] = {455}, -- #809
        },
        [484] = {
            [QuestieDB.questKeys.requiredMinRep] = nil, -- #1501
        },
        [510] = {
            [QuestieDB.questKeys.startedBy] = {nil,{1740},nil}, -- #1512
        },
        [511] = {
            [QuestieDB.questKeys.startedBy] = {nil,{1740},nil}, -- #1512
        },
        [522] = {
            [QuestieDB.questKeys.startedBy] = {{2434},nil,{3668}},
        },
        [526] = {
            [QuestieDB.questKeys.exclusiveTo] = {322,324}, -- not 100% sure on this one but it seems lightforge ingots is optional, block it after completing subsequent steps (#587)
        },
        [533] = {
            [QuestieDB.questKeys.childQuests] = {535},
        },
        [535] = {
            [QuestieDB.questKeys.parentQuest] = 533,
        },
        [549] = {
            [QuestieDB.questKeys.nextQuestInChain] = 566, -- #1134
        },
        [551] = {
            [QuestieDB.questKeys.startedBy] = {nil,{1765},{3706},}, -- #1245
        },
        [566] = {
            [QuestieDB.questKeys.preQuestSingle] = {549}, -- #1484
        },
        [578] = {
            [QuestieDB.questKeys.childQuests] = {579},
        },
        [579] = {
            [QuestieDB.questKeys.parentQuest] = 578,
        },
        [590] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defeat Calvin Montague",{[85]={{38.19,56.74},},},},
        },
        [594] = {
            [QuestieDB.questKeys.startedBy] = {nil,{2560,},{4098,},},
        },
        [598] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.preQuestGroup] = {596,629,}
        },
        [619] = {
            [QuestieDB.questKeys.parentQuest] = 8554, -- #1691
        },
        [621] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
        },
        [624] = {
            [QuestieDB.questKeys.startedBy] = {nil,{2554},{4056,},},
        },
        [637] = {
            [QuestieDB.questKeys.startedBy] = {nil,{2656},{4433,},}, -- #909
        },
        [638] = {
            [QuestieDB.questKeys.exclusiveTo] = {639}, -- #1205
        },
        [639] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1205
        },
        [648] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort OOX-17/TN to Steamwheedle Port", {[440]={{67.06,23.16},},},},
        },
        [660] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Kinelory", {[45]={{60.1,53.83},},},},
        },
        [665] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defend Professor Phizzlethorpe", {[45]={{33.87,80.6},},},},
        },
        [667] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defend Shakes O'Breen", {[45]={{31.93,81.82},},},},
        },
        [677] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, --#1162
        },
        [680] = {
            [QuestieDB.questKeys.preQuestSingle] = {678}, -- #1062
        },
        [690] = {
            [QuestieDB.questKeys.exclusiveTo] = {691}, -- #1587
        },
        [691] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [715] = {
            [QuestieDB.questKeys.preQuestGroup] = {712,714,},
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.requiredSkill] = {},
        },
        [730] = {
            [QuestieDB.questKeys.exclusiveTo] = {729}, -- #1587
        },
        [731] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Prospector Remtravel", {[148]={{35.67,84.03},},},},
        },
        [736] = {
            [QuestieDB.questKeys.requiredSourceItems] = {4639},
        },
        [738] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1289
        },
        [742] = {
            [QuestieDB.questKeys.exclusiveTo] = {235,6382,6383,},
        },
        [754] = {
            [QuestieDB.questKeys.triggerEnd] = {"Cleanse the Winterhoof Water Well", {[215]={{53.61, 66.2},},},},
        },
        [758] = {
            [QuestieDB.questKeys.triggerEnd] = {"Cleanse the Thunderhorn Water Well", {[215]={{44.52, 45.46},},},},
        },
        [760] = {
            [QuestieDB.questKeys.triggerEnd] = {"Cleanse the Wildmane Well", {[215]={{42.75, 14.16,},},},},
        },
        [769] = {
            [QuestieDB.questKeys.requiredSkill] = {165,10},
        },
        [770] = {
            [QuestieDB.questKeys.startedBy] = {{3056},nil,{4854}},
        },
        [781] = {
            [QuestieDB.questKeys.startedBy] = {nil,{3076},{4851,},},
        },
        [819] = {
            [QuestieDB.questKeys.startedBy] = {nil,{3238},{4926,},},
        },
        [830] = {
            [QuestieDB.questKeys.startedBy] = {nil,{3239},{4881,},},
        },
        [832] = {
            [QuestieDB.questKeys.startedBy] = {{3204},nil,{4903}},
        },
        [834] = {
            [QuestieDB.questKeys.requiredRaces] = 255, -- #1665
        },
        [835] = {
            [QuestieDB.questKeys.requiredRaces] = 255, -- #1665
        },
        [836] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort OOX-09/HL to the shoreline beyond Overlook Cliff", {[47]={{79.14,61.36},},},},
        },
        [841] = {
            [QuestieDB.questKeys.specialFlags] = 1,
            [QuestieDB.questKeys.exclusiveTo] = {654},
        },
        [860] = {
            [QuestieDB.questKeys.exclusiveTo] = {844},
        },
        [861] = {
            [QuestieDB.questKeys.nextQuestInChain] = 860,
            [QuestieDB.questKeys.exclusiveTo] = {860,844}, -- #1109
        },
        [862] = {
            [QuestieDB.questKeys.requiredSkill] = {185,76}, -- You need to be a Journeyman for this quest
        },
        [863] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Wizzlecrank out of the Venture Co. drill site", {[17]={{55.36,7.68},},},},
        },
        [883] = {
            [QuestieDB.questKeys.startedBy] = {{3474},nil,{5099}},
        },
        [884] = {
            [QuestieDB.questKeys.startedBy] = {{3473},nil,{5102}},
        },
        [885] = {
            [QuestieDB.questKeys.startedBy] = {{3472},nil,{5103}},
        },
        [886] = {
            [QuestieDB.questKeys.exclusiveTo] = {870},
        },
        [897] = {
            [QuestieDB.questKeys.startedBy] = {{3253},nil,{5138}},
        },
        [898] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Gilthares Firebough back to Ratchet", {[17]={{62.27,39.09},},},},
        },
        [910] = {
            [QuestieDB.questKeys.triggerEnd] = {"Go to the docks of Ratchet in the Barrens.", {[17]={{62.96,38.04},},},},
        },
        [911] = {
            [QuestieDB.questKeys.triggerEnd] = {"Go to the Mor'shan Rampart in the Barrens.", {[17]={{47.9,5.36},},},},
        },
        [926] = {
            [QuestieDB.questKeys.parentQuest] = 924, -- #806
            [QuestieDB.questKeys.preQuestSingle] = {809}, --#606
        },
        [927] = {
            [QuestieDB.questKeys.startedBy] = {{3535},nil,{5179}},
        },
        [930] = {
            [QuestieDB.questKeys.preQuestSingle] = {918,919}, -- #971
        },
        [938] = {
            [QuestieDB.questKeys.triggerEnd] = {"Lead Mist safely to Sentinel Arynia Cloudsbreak", {[141]={{38.33,34.39},},},},
        },
        [939] = {
            [QuestieDB.questKeys.startedBy] = {{10648},nil,{11668}},
        },
        [944] = {
            [QuestieDB.questKeys.triggerEnd] = {"Enter the Master's Glaive",{[148]={{38.48,86.45},},},},
        },
        [945] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Therylune away from the Master's Glaive", {[148]={{40.51,87.08},},},},
        },
        [961] = {
            [QuestieDB.questKeys.preQuestSingle] = {944}, -- #1517
            [QuestieDB.questKeys.exclusiveTo] = {950}, -- #1517
        },
        [976] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Feero Ironhand", {[148]={{43.54,94.39},},},},
        },
        [984] = {
            [QuestieDB.questKeys.triggerEnd] = {"Find a corrupt furbolg camp",{[148]={{39.34,53.51},{39.86,53.89},{42.68,86.53},},},},
        },
        [994] = {
            [QuestieDB.questKeys.triggerEnd] = {"Help Volcor to the road", {[148]={{41.92,81.76},},},},
        },
        [995] = {
            [QuestieDB.questKeys.triggerEnd] = {"Help Volcor escape the cave", {[148]={{44.57,85},},},},
        },
        [1000] = {
            [QuestieDB.questKeys.exclusiveTo] = {1004,1018,},
        },
        [1004] = {
            [QuestieDB.questKeys.exclusiveTo] = {1000,1018,},
        },
        [1015] = {
            [QuestieDB.questKeys.exclusiveTo] = {1047,1019,},
        },
        [1018] = {
            [QuestieDB.questKeys.exclusiveTo] = {1000,1004,},
        },
        [1019] = {
            [QuestieDB.questKeys.exclusiveTo] = {1015,1047,},
        },
        [1026] = {
            [QuestieDB.questKeys.requiredSourceItems] = {5475},
        },
        [1036] = {
            [QuestieDB.questKeys.requiredMinRep] = {87,3000},
            [QuestieDB.questKeys.requiredMaxRep] = {21,-5999},
        },
        [1047] = {
            [QuestieDB.questKeys.exclusiveTo] = {1015,1019,},
        },
        [1056] = {
            [QuestieDB.questKeys.exclusiveTo] = {1057}, -- #1901
        },
        [1061] = {
            [QuestieDB.questKeys.exclusiveTo] = {1062}, -- #1803
        },
        [1085] = {
            [QuestieDB.questKeys.preQuestSingle] = {1070},
        },
        [1086] = {
            [QuestieDB.questKeys.triggerEnd] = {"Place the Toxic Fogger", {[406]={{66.44,45.46},},},},
        },
        [1090] = {
            [QuestieDB.questKeys.triggerEnd] = {"Keep Piznik safe while he mines the mysterious ore", {[406]={{71.76, 60.22},},},},
        },
        [1100] = {
            [QuestieDB.questKeys.startedBy] = {nil,{19861},{5791},}, -- #1189
        },
        [1103] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1658
            [QuestieDB.questKeys.parentQuest] = 100, -- #1658
        },
        [1106] = {
            [QuestieDB.questKeys.preQuestGroup] = {1104, 1105},
        },
        [1118] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
        },
        [1119] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
            [QuestieDB.questKeys.childQuests] = {1127}, -- #1084
        },
        [1127] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #884
            [QuestieDB.questKeys.parentQuest] = 1119, -- #1084
        },
        [1131] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1065
        },
        [1132] = {
            [QuestieDB.questKeys.exclusiveTo] = {1133}, -- #1738
        },
        [1133] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1738
        },
        [1144] = {
            [QuestieDB.questKeys.triggerEnd] = {"Help Willix the Importer escape from Razorfen Kraul", {[17]={{42.27,89.88},},},},
        },
        [1148] = {
            [QuestieDB.questKeys.preQuestSingle] = {1146},
            [QuestieDB.questKeys.startedBy] = {{4130,4131,4133,},nil,{5877,},},
        },
        [1173] = {
            [QuestieDB.questKeys.triggerEnd] = {"Drive Overlord Mok'Morokk from Brackenwall Village", {[15]={{36.41,31.43},},},},
        },
        [1193] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1348
        },
        [1204] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #938
        },
        [1222] = {
            [QuestieDB.questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[15]={{48.87,24.58},},},},
        },
        [1249] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defeat Tapoke Jahn", {[11]={{10.87,59.35},},},},
        },
        [1252] = {
            [QuestieDB.questKeys.preQuestSingle] = {1302,1282}, -- #1845
        },
        [1253] = {
            [QuestieDB.questKeys.preQuestSingle] = {1302,1282}, -- #1845
        },
        [1260] = {
            [QuestieDB.questKeys.exclusiveTo] = {1204},
        },
        [1265] = {
            [QuestieDB.questKeys.triggerEnd] = {"Sentry Point explored",{[15]={{59.92,40.9},}}},
        },
        [1268] = {
            [QuestieDB.questKeys.startedBy] = {nil,{21015,21016,},nil,}, -- #1574
        },
        [1270] = {
            [QuestieDB.questKeys.triggerEnd] = {"Help Stinky find Bogbean Leaves", {[15]={{45.87,24.58},},},},
        },
        [1273] = {
            [QuestieDB.questKeys.triggerEnd] = {"Question Reethe with Ogron", {[15]={{42.47,38.07},},},},
        },
        [1275] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #973 -- #745 prequest is not required in Classic
        },
        [1276] = {
            [QuestieDB.questKeys.preQuestSingle] = {1273,}, -- #1574
        },
        [1284] = {
            [QuestieDB.questKeys.preQuestSingle] = {1302,1282}, -- #1845
            [QuestieDB.questKeys.startedBy] = {nil,{21015,21016,},nil,},
        },
        [1301] = {
            [QuestieDB.questKeys.exclusiveTo] = {1302}, -- breadcrumb of James Hyal #917
        },
        [1302] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #889
        },
        [1324] = {
            [QuestieDB.questKeys.triggerEnd] = {"Subdue Private Hendel", {[15]={{45.21,24.49},},},},
        },
        [1339] = {
            [QuestieDB.questKeys.exclusiveTo] = {1338}, -- mountaineer stormpike's task cant be done if you have finished stormpike's order
        },
        [1361] = {
            [QuestieDB.questKeys.exclusiveTo] = {1362},
        },
        [1364] = {
            [QuestieDB.questKeys.preQuestSingle] = {1363}, -- #1674
        },
        [1392] = {
            [QuestieDB.questKeys.startedBy] = {{5477},nil,{6196}},
        },
        [1393] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Galen out of the Fallow Sanctuary.", {[8]={{53.08,29.55},},},},
        },
        [1395] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1727
        },
        [1418] = {
            [QuestieDB.questKeys.exclusiveTo] = {1419,1420}, -- #1594
        },
        [1423] = {
            [QuestieDB.questKeys.startedBy] = {nil,{28604},{6172,},},
        },
        [1427] = {
            [QuestieDB.questKeys.nextQuestInChain] = 1428,
        },
        [1428] = {
            [QuestieDB.questKeys.preQuestSingle] = {1427},
        },
        [1432] = {
            [QuestieDB.questKeys.nextQuestInChain] = 1433,
        },
        [1434] = {
            [QuestieDB.questKeys.preQuestSingle] = {1432}, -- #1536
        },
        [1436] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.preQuestGroup] = {1434,1480},
        },
        [1440] = {
            [QuestieDB.questKeys.triggerEnd] = {"Rescue Dalinda Malem", {[405]={{58.27,30.91},},},},
        },
        [1442] = {
            [QuestieDB.questKeys.parentQuest] = 1654,
        },
        [1447] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defeat Dashel Stonefist", {[1519]={{70.1,44.85},},},},
        },
        [1470] = {
            [QuestieDB.questKeys.exclusiveTo] = {1485}, -- #999
        },
        [1471] = {
            [QuestieDB.questKeys.exclusiveTo] = {1504}, -- #1542
        },
        [1473] = {
            [QuestieDB.questKeys.exclusiveTo] = {1501},
        },
        [1477] = {
            [QuestieDB.questKeys.exclusiveTo] = {1395}, -- #1727
        },
        [1478] = {
            [QuestieDB.questKeys.exclusiveTo] = {1506}, -- #1427
        },
        [1479] = {
            [QuestieDB.questKeys.triggerEnd] = {"Go to the bank in Darnassus, otherwise known as the Bough of the Eternals.", {[1657]={{41.31,43.54},},},},
        },
        [1483] = {
            [QuestieDB.questKeys.exclusiveTo] = {1093},
        },
        [1485] = {
            [QuestieDB.questKeys.exclusiveTo] = {1470}, -- #999
        },
        [1501] = {
            [QuestieDB.questKeys.exclusiveTo] = {1473},
        },
        [1504] = {
            [QuestieDB.questKeys.exclusiveTo] = {1471}, -- #1542
        },
        [1506] = {
            [QuestieDB.questKeys.exclusiveTo] = {1478}, -- #1427
        },
        [1558] = {
            [QuestieDB.questKeys.triggerEnd] = {"Go to the top of the Stonewrought Dam in Loch Modan.", {[38]={{47.63,14.33},},},},
        },
        [1559] = {
            [QuestieDB.questKeys.preQuestSingle] = {705},
        },
        [1560] = {
            [QuestieDB.questKeys.triggerEnd] = {"Lead Tooga to Torta", {[440]={{66.56,25.65},},},},
        },
        [1580] = {
            [QuestieDB.questKeys.requiredSkill] = {356,30},
        },
        [1581] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [1598] = {
            [QuestieDB.questKeys.exclusiveTo] = {1599}, -- #999
        },
        [1599] = {
            [QuestieDB.questKeys.exclusiveTo] = {1598}, -- #999
            [QuestieDB.questKeys.preQuestSingle] = {705}, -- #1164
        },
        [1638] = {
            [QuestieDB.questKeys.exclusiveTo] = {1666,1678,1680,1683,1686},
        },
        [1639] = {
            [QuestieDB.questKeys.exclusiveTo] = {1678},
        },
        [1640] = {
            [QuestieDB.questKeys.triggerEnd] = {"Beat Bartleby", {[1519]={{73.7,36.85},},},},
        },
        [1641] = { -- This is repeatable giving an item starting 1642
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000,3681},
        },
        [1642] = {
            [QuestieDB.questKeys.exclusiveTo] = {1646,2997,2998,2999,3000,3681},
        },
        [1645] = { -- This is repeatable giving an item starting 1646
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000,3681},
        },
        [1646] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,2997,2998,2999,3000,3681},
        },
        [1651] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Daphne Stilwell", {[40]={{42.15,88.44},},},},
        },
        [1654] = {
            [QuestieDB.questKeys.childQuests] = {1442,1655},
        },
        [1655] = {
            [QuestieDB.questKeys.parentQuest] = 1654,
        },
        [1661] = {
            [QuestieDB.questKeys.exclusiveTo] = {4485,4486},
        },
        [1666] = {
            [QuestieDB.questKeys.preQuestSingle] = {1639,1678,1683},
        },
        [1678] = {
            [QuestieDB.questKeys.exclusiveTo] = {1639},
        },
        [1679] = {
            [QuestieDB.questKeys.exclusiveTo] = {1639,1666,1680,1683,1686}, -- #1724
        },
        [1680] = {
            [QuestieDB.questKeys.preQuestSingle] = {1639,1678,1683},
            [QuestieDB.questKeys.exclusiveTo] = {1681}, -- #1724
        },
        [1684] = {
            [QuestieDB.questKeys.exclusiveTo] = {1639,1666,1678,1686,1680},
        },
        [1686] = {
            [QuestieDB.questKeys.preQuestSingle] = {1639,1678,1683},
        },
        [1687] = {
            [QuestieDB.questKeys.triggerEnd] = {"Go to the Westfall Lighthouse.", {[40]={{30.41,85.61},},},},
        },
        [1700] = {
            [QuestieDB.questKeys.requiredRaces] = 1,
            [QuestieDB.questKeys.exclusiveTo] = {1703,1704,1705}, -- #1857
        },
        [1703] = {
            [QuestieDB.questKeys.exclusiveTo] = {1700,1704,1710}, -- #1857
        },
        [1704] = {
            [QuestieDB.questKeys.exclusiveTo] = {1700,1703,1708}, -- #1857
        },
        [1705] = {
            [QuestieDB.questKeys.preQuestSingle] = {1700,1703,1704}, -- #1857
        },
        [1708] = {
            [QuestieDB.questKeys.preQuestSingle] = {1700,1703,1704}, -- #1857
        },
        [1710] = {
            [QuestieDB.questKeys.preQuestSingle] = {1700,1703,1704}, -- #1857
        },
        [1718] = {
            [QuestieDB.questKeys.startedBy] = {{3041,3354,4595,5113,5479,},nil,nil,}, -- #1034
        },
        [1793] = {
            [QuestieDB.questKeys.exclusiveTo] = {1649},
        },
        [1794] = {
            [QuestieDB.questKeys.exclusiveTo] = {1649},
        },
        [1800] = {
            [QuestieDB.questKeys.triggerEnd] = {"Go to the old Lordaeron Throne Room that lies just before descending into the Undercity.", {[1497]={{65.97,36.12},},},},
        },
        [1860] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1192
        },
        [1861] = {
            [QuestieDB.questKeys.preQuestSingle] = {1860,1879}, -- #1380
            [QuestieDB.questKeys.exclusiveTo] = {1880}, -- #1192
        },
        [1879] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1192
        },
        [1880] = {
            [QuestieDB.questKeys.preQuestSingle] = {1860,1879}, -- #1380
            [QuestieDB.questKeys.exclusiveTo] = {1861}, -- #1192
        },
        [1918] = {
            [QuestieDB.questKeys.startedBy] = {{12759},nil,{16408}},
        },
        [1920] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1328
        },
        [1943] = {
            [QuestieDB.questKeys.exclusiveTo] = {1944}, -- mage robe breadcrumb
        },
        [1950] = {
            [QuestieDB.questKeys.triggerEnd] = {"Secret phrase found", {[400]={{79.56,75.65},},},},
        },
        [2201] = {
            [QuestieDB.questKeys.childQuests] = {3375},
        },
        [2205] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1466
        },
        [2218] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1466
        },
        [2241] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1466
        },
        [2259] = {
            [QuestieDB.questKeys.exclusiveTo] = {2260}, -- #1825
        },
        [2260] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.exclusiveTo] = {2281}, -- #1825
        },
        [2278] = {
            [QuestieDB.questKeys.triggerEnd] = {"Learn what lore that the stone watcher has to offer", {[3]={{35.21,10.33},},},},
        },
        [2281] = {
            [QuestieDB.questKeys.exclusiveTo] = {2299}, -- #1817
        },
        [2298] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.exclusiveTo] = {2281}, -- #1825
        },
        [2299] = {
            [QuestieDB.questKeys.exclusiveTo] = {2281}, -- #1817
        },
        [2300] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1825
            [QuestieDB.questKeys.exclusiveTo] = {2281}, -- #1817
        },
        [2358] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [2460] = {
            [QuestieDB.questKeys.triggerEnd] = {"Shattered Salute Performed", {[1637]={{43.11,53.48},},},},
        },
        [2480] = {
            [QuestieDB.questKeys.triggerEnd] = {"Cure Completed",{[267]={{61.57, 19.21}},},},
        },
        [2501] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1541
            [QuestieDB.questKeys.preQuestGroup] = {2500,17}, -- #1541
        },
        [2520] = {
            [QuestieDB.questKeys.triggerEnd] = {"Offer the sacrifice at the fountain", {[1657]={{38.63,85.99},},},},
        },
        [2561] = {
            [QuestieDB.questKeys.triggerEnd] = {"Release Oben Rageclaw's spirit", {[141]={{45.52,58.71},},},},
        },
        [2608] = {
            [QuestieDB.questKeys.triggerEnd] = {"Diagnosis Complete", {[1519]={{78.04,59},},},},
        },
        [2742] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Rin'ji to safety", {[47]={{34.58,56.33},},},},
        },
        [2744] = {
            [QuestieDB.questKeys.triggerEnd] = {"Conversation with Loramus", {[16]={{60.8,66.4}},},},
        },
        [2755] = {
            [QuestieDB.questKeys.triggerEnd] = {"Omosh Dance of Joy Learned", {[1637]={{79.28,22.3},},},},
        },
        [2765] = {
            [QuestieDB.questKeys.triggerEnd] = {"You Are The Big Winner", {[33]={{50.58,20.54},},},},
        },
        [2767] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort OOX-22/FE to the dock along the Forgotten Coast", {[357]={{45.63,43.39},},},},
        },
        [2781] = {
            [QuestieDB.questKeys.startedBy] = {nil,{142122,150075,},nil,}, -- #1081
        },
        [2784] = {
            [QuestieDB.questKeys.triggerEnd] = {"The Tale of Sorrow", {[8]={{34.28,65.96},},},},
        },
        [2801] = {
            [QuestieDB.questKeys.triggerEnd] = {"A Tale of Sorrow", {[8]={{34.24,66.02},},},},
        },
        [2843] = {
            [QuestieDB.questKeys.triggerEnd] = {"Goblin Transponder", {[33]={{27.56,77.42},},},},
        },
        [2845] = {
            [QuestieDB.questKeys.triggerEnd] = {"Take Shay Leafrunner to Rockbiter's camp", {[357]={{42.33,21.85},},},},
        },
        [2861] = {
            [QuestieDB.questKeys.startedBy] = {{4568,5144,5497,5885,},nil,nil,}, -- #1152
            [QuestieDB.questKeys.exclusiveTo] = {2846},
        },
        [2872] = {
            [QuestieDB.questKeys.exclusiveTo] = {2873}, -- #1566
        },
        [2873] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1566
        },
        [2882] = {
            [QuestieDB.questKeys.zoneOrSort] = 440, -- #1780
        },
        [2904] = {
            [QuestieDB.questKeys.triggerEnd] = {"Kernobee Rescue", {[1]={{17.67,39.15},},},},
        },
        [2922] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- Save Techbot's Brain doesn't need the Tinkmaster Overspark breadcrumb #687
        },
        [2925] = {
            [QuestieDB.questKeys.exclusiveTo] = {2924},
        },
        [2931] = {
            [QuestieDB.questKeys.exclusiveTo] = {2930},
        },
        [2932] = {
            [QuestieDB.questKeys.triggerEnd] = {"Place the grim message.", {[47]={{23.41,58.06}},},},
        },
        [2936] = {
            [QuestieDB.questKeys.triggerEnd] = {"Find the Spider God's Name", {[440]={{38.73,19.88},},},},
        },
        [2945] = {
            [QuestieDB.questKeys.startedBy] = {{6212},nil,{9326}},
        },
        [2951] = {
            [QuestieDB.questKeys.preQuestSingle] = {4601,4602},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [2952] = {
            [QuestieDB.questKeys.exclusiveTo] = {4605,4606},
        },
        [2954] = {
            [QuestieDB.questKeys.triggerEnd] = {"Learn the purpose of the Stone Watcher of Norgannon", {[440]={{37.66,81.42},},},},
        },
        [2969] = {
            [QuestieDB.questKeys.triggerEnd] = {"Save at least 6 Sprite Darters from capture", {[357]={{67.27,46.67},},},},
        },
        [2978] = {
            [QuestieDB.questKeys.startedBy] = {nil,{143980},{9370,},}, -- #1596
        },
        [2981] = {
            [QuestieDB.questKeys.exclusiveTo] = {2975},
        },
        [2992] = {
            [QuestieDB.questKeys.triggerEnd] = {"Wait for Grimshade to finish", {[4]={{66.99,19.41},},},},
        },
        [2994] = {
            [QuestieDB.questKeys.questLevel] = 51, -- #1129
        },
        [2997] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2998,2999,3000,3681},
        },
        [2998] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,3000,3681},
        },
        [2999] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,3000,3681},
        },
        [3000] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3681},
        },
        [3090] = {
            [QuestieDB.questKeys.requiredRaces] = 0, -- #813
        },
        [3128] = {
            [QuestieDB.questKeys.preQuestSingle] = {3122},
        },
        [3141] = {
            [QuestieDB.questKeys.triggerEnd] = {"Loramus' Story", {[16]={{60.8,66.36},},},},
        },
        [3181] = {
            [QuestieDB.questKeys.startedBy] = {{5833},nil,{10000}},
        },
        [3321] = {
            [QuestieDB.questKeys.triggerEnd] = {"Watch Trenton Work", {[440]={{51.43,28.7},},},},
        },
        [3367] = {
            [QuestieDB.questKeys.triggerEnd] = {"Dorius Escort", {[51]={{74.47,19.44},},},},
        },
        [3374] = {
            [QuestieDB.questKeys.startedBy] = {{5353},nil,{10589,},}, -- #1233
        },
        [3375] = {
            [QuestieDB.questKeys.parentQuest] = 2201,
        },
        [3377] = {
            [QuestieDB.questKeys.triggerEnd] = {"Zamael Story",{[51]={{29.59, 26.38},},},},
        },
        [3382] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Captain Vanessa Beltis from the naga attack", {[16]={{52.86,87.77},},},},
        },
        [3385] = {
            [QuestieDB.questKeys.requiredSkill] = {197,226}, -- You need to be an Artisan for this quest
        },
        [3441] = {
            [QuestieDB.questKeys.triggerEnd] = {"Kalaran Story", {[51]={{39.03,38.94},},},},
        },
        [3449] = {
            [QuestieDB.questKeys.childQuests] = {3483}, -- #1008
        },
        [3453] = {
            [QuestieDB.questKeys.triggerEnd] = {"Torch Creation", {[51]={{39.02,38.97},},},},
        },
        [3483] = {
            [QuestieDB.questKeys.parentQuest] = 3449, -- #1008
            [QuestieDB.questKeys.specialFlags] = 1, -- #1131
        },
        [3513] = {
            [QuestieDB.questKeys.startedBy] = {{5797},nil,{10621}},
        },
        [3525] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Belnistrasz while he performs the ritual to shut down the idol", {[17]={{50.86,92.87},},},},
        },
        [3625] = {
            [QuestieDB.questKeys.triggerEnd] = {"Weaponry Creation", {[33]={{50.62,20.49},},},},
        },
        [3639] = {
            [QuestieDB.questKeys.exclusiveTo] = {3643,3641},
        },
        [3641] = {
            [QuestieDB.questKeys.exclusiveTo] = {3639},
        },
        [3643] = {
            [QuestieDB.questKeys.exclusiveTo] = {3639},
        },
        [3681] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000},
        },
        --[3741] = { -- bad race data (actually this is correct)
        --    [QuestieDB.questKeys.requiredRaces] = 77,
        --},
        [3702] = {
            [QuestieDB.questKeys.triggerEnd] = {"Story of Thaurissan", {[1537]={{38.62,55.44},},},},
        },
        [3765] = {
            [QuestieDB.questKeys.exclusiveTo] = {1275}, -- corruption abroad breadcrumb
        },
        [3791] = {
            [QuestieDB.questKeys.preQuestSingle] = {3787,3788}, -- #885
        },
        [3903] = {
            [QuestieDB.questKeys.preQuestSingle] = {18},
        },
        [3982] = {
            [QuestieDB.questKeys.triggerEnd] = {"Survive the Onslaught", {[51]={{27.11,72.56},},},},
        },
        [4001] = {
            [QuestieDB.questKeys.triggerEnd] = {"Information Gathered from Kharan", {[51]={{27.12,72.56},},},},
        },
        [4022] = {
            [QuestieDB.questKeys.triggerEnd] = {"Proof Presented", {[46]={{95,31.61},},},},
        },
        [4083] = {
            [QuestieDB.questKeys.requiredSkill] = {186,230}, -- #1293
        },
        [4084] = {
            [QuestieDB.questKeys.questLevel] = 54, -- #1495
        },
        -- Salve via Hunting/Mining/Gathering/Skinning/Disenchanting repeatable quests
        -- Alliance
        [4103] = {
            [QuestieDB.questKeys.preQuestSingle] = {5882,5883,5884,5885,5886,},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [4104] = {
            [QuestieDB.questKeys.preQuestSingle] = {5882,5883,5884,5885,5886,},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [4105] = {
            [QuestieDB.questKeys.preQuestSingle] = {5882,5883,5884,5885,5886,},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [4106] = {
            [QuestieDB.questKeys.preQuestSingle] = {5882,5883,5884,5885,5886,},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [4107] = {
            [QuestieDB.questKeys.preQuestSingle] = {5882,5883,5884,5885,5886,},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        -- Horde
        [4108] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9529,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4109] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9529,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4110] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9529,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4111] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9529,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4112] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9529,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        -----------------------
        [4121] = {
            [QuestieDB.questKeys.triggerEnd] = {"Prisoner Transport", {[46]={{25.73,27.1},},},},
        },
        [4122] = {
            [QuestieDB.questKeys.preQuestSingle] = {4082}, -- #1349
        },
        [4133] = {
            [QuestieDB.questKeys.exclusiveTo] = {4134}, -- #1859
        },
        [4134] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1859
        },
        [4144] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1590
        },
        [4185] = {
            [QuestieDB.questKeys.triggerEnd] = {"Advice from Lady Prestor", {[1519]={{78.04,17.96},},},},
        },
        [4224] = {
            [QuestieDB.questKeys.triggerEnd] = {"Ragged John's Story",{[46]={{64,23},},},},
        },
        [4245] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect A-Me 01 until you reach Karna Remtravel",{[490]={{46.43, 13.78},},},},
        },
        [4261] = {
            [QuestieDB.questKeys.triggerEnd] = {"Help Arei get to Safety", {[361]={{49.42,14.54},},},},
        },
        [4265] = {
            [QuestieDB.questKeys.triggerEnd] = {"Free Raschal.", {[357]={{72.13,63.84},},},},
        },
        [4285] = {
            [QuestieDB.questKeys.triggerEnd] = {"Discover and examine the Northern Crystal Pylon",{[490]={{56,12},},},},
        },
        [4287] = {
            [QuestieDB.questKeys.triggerEnd] = {"Discover and examine the Eastern Crystal Pylon",{[490]={{77,50},},},},
        },
        [4288] = {
            [QuestieDB.questKeys.triggerEnd] = {"Discover and examine the Western Crystal Pylon",{[490]={{23,59},},},},
        },
        [4322] = {
            [QuestieDB.questKeys.triggerEnd] = {"Jail Break!", {[1584]={{-1,-1}},},},
        },
        [4342] = {
            [QuestieDB.questKeys.triggerEnd] = {"Kharan's Tale", {[51]={{27.1,72.54},},},},
        },
        [4485] = {
            [QuestieDB.questKeys.exclusiveTo] = {1661,4486},
        },
        [4486] = {
            [QuestieDB.questKeys.exclusiveTo] = {1661,4485},
        },
        [4491] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Ringo to Spraggle Frock at Marshal's Refuge", {[490]={{43.71,8.29},},},},
        },
        [4493] = {
            [QuestieDB.questKeys.preQuestSingle] = {4267},
        },
        [4494] = {
            [QuestieDB.questKeys.preQuestSingle] = {32,7732},
        },
        [4496] = {
            [QuestieDB.questKeys.preQuestSingle] = {4493,4494},
        },
        [4505] = {
            [QuestieDB.questKeys.exclusiveTo] = {6605},
        },
        [4506] = {
            [QuestieDB.questKeys.triggerEnd] = {"Return the corrupted cat to Winna Hazzard", {[361]={{34.26,52.32},},},},
        },
        [4601] = {
            [QuestieDB.questKeys.preQuestSingle] = {2951,4602},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [4602] = {
            [QuestieDB.questKeys.preQuestSingle] = {2951,4601},
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [4605] = {
            [QuestieDB.questKeys.exclusiveTo] = {2952,4606},
        },
        [4606] = {
            [QuestieDB.questKeys.exclusiveTo] = {2952,4605},
        },
        [4621] = {
            [QuestieDB.questKeys.preQuestSingle] = {1036},
            [QuestieDB.questKeys.requiredMinRep] = {87,3000},
            [QuestieDB.questKeys.requiredMaxRep] = {21,-5999},
        },
        [4641] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #877
            [QuestieDB.questKeys.exclusiveTo] = {788}, -- #1956
        },
        [4734] = {
            [QuestieDB.questKeys.triggerEnd] = {"Test the Eggscilliscope Prototype", {[51]={{40.78,95.66},},},},
        },
        [4763] = {
            [QuestieDB.questKeys.requiredSourceItems] = {12347,12341,12342,12343,}, -- #798
        },
        [4764] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1916
        },
        [4766] = {
            [QuestieDB.questKeys.exclusiveTo] = {4764} -- #1916
        },
        [4768] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1859
        },
        [4769] = {
            [QuestieDB.questKeys.exclusiveTo] = {4768},
        },
        [4770] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Pao'ka from Highperch", {[400]={{15.15,32.65},},},},
        },
        [4784] = {
            [QuestieDB.questKeys.childQuests] = {4785}, -- #1367
        },
        [4785] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1367
            [QuestieDB.questKeys.parentQuest] = 4784, -- #1367
            [QuestieDB.questKeys.specialFlags] = 1, -- #1367
        },
        [4786] = {
            [QuestieDB.questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[17]={{62.52,35.47},},},},
        },
        [4811] = {
            [QuestieDB.questKeys.triggerEnd] = {"Locate the large, red crystal on Darkshore's eastern mountain range",{[148]={{47.24,48.68},},},}, -- #1373
        },
        [4866] = {
            [QuestieDB.questKeys.triggerEnd] = {"Milked", {[46]={{65.11,23.68},},},},
        },
        [4881] = {
            [QuestieDB.questKeys.startedBy] = {{10617},nil,{12564}},
        },
        [4901] = {
            [QuestieDB.questKeys.triggerEnd] = {"Discover the secret of the Altar of Elune", {[618]={{64.85,63.73},},},},
        },
        [4904] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Lakota Windsong from the Darkcloud Pinnacle.", {[400]={{30.93,37.12},},},},
        },
        [4907] = {
            [QuestieDB.questKeys.exclusiveTo] = {4734},
        },
        [4941] = {
            [QuestieDB.questKeys.triggerEnd] = {"Council with Eitrigg.", {[1637]={{34.14,39.26},},},},
        },
        [4964] = {
            [QuestieDB.questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[17]={{62.52,35.47},},},},
        },
        [4966] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Kanati Greycloud", {[400]={{21.38,31.98},},},},
        },
        [4975] = {
            [QuestieDB.questKeys.triggerEnd] = {"Wait for Menara Voidrender to complete your item", {[17]={{62.52,35.47},},},},
        },
        [5041] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [5057] = {
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [5059] = {
            [QuestieDB.questKeys.preQuestSingle] = {5058}, -- #922
        },
        [5060] = {
            [QuestieDB.questKeys.preQuestSingle] = {5059}, -- #922
        },
        [5063] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5067] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5068] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5082] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1824
        },
        [5088] = {
            [QuestieDB.questKeys.triggerEnd] = {"Light the Sacred Fire of Life", {[400]={{38.08,35.35},},},},
        },
        [5089] = {
            [QuestieDB.questKeys.startedBy] = {{9568},nil,{12780}},
        },
        [5096] = {
            [QuestieDB.questKeys.triggerEnd] = {"Destroy the command tent and plant the Scourge banner in the camp", {[28]={{40.72,52.04},},},},
        },
        [5122] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1140
        },
        [5123] = {
            [QuestieDB.questKeys.startedBy] = {{10738},nil,{12842}},
        },
        [5124] = {
            [QuestieDB.questKeys.requiredSkill] = {164,275},
        },
        [5126] = {
            [QuestieDB.questKeys.triggerEnd] = {"Listen to Lorax's Tale", {[618]={{63.82,73.79},},},},
        },
        [5156] = {
            [QuestieDB.questKeys.triggerEnd] = {"Explore the craters in Shatter Scar Vale", {[361]={{41.03,41.96},},},},
        },
        [5166] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5167] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5203] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Arko'narin out of Shadow Hold", {[361]={{35.45,59.06},},},},
        },
        [5211] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #983
        },
        [5234] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [5261] = {
            [QuestieDB.questKeys.exclusiveTo] = {33}, -- #1726
        },
        [5262] = {
            [QuestieDB.questKeys.startedBy] = {{10813},nil,{13250}},
        },
        [5321] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Kerlonian Evershade to Maestra's Post", {[331]={{26.77,36.91},},},},
        },
        [5421] = {
            [QuestieDB.questKeys.questLevel] = 25,
        },
        [5582] = {
            [QuestieDB.questKeys.startedBy] = {{10678},nil,{13920}},
        },
        [5634] = {
            [QuestieDB.questKeys.startedBy] = {{11401,},nil,nil,},
        },
        [5713] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect Aynasha", {[148]={{45.87,90.42},},},},
        },
        [5721] = {
            [QuestieDB.questKeys.requiredSourceItems] = {15209,}, -- #857
        },
        -- Salve via Hunting/Mining/Gathering/Skinning/Disenchanting non repeatable quests
        -- Alliance
        [5727] = {
            [QuestieDB.questKeys.triggerEnd] = {"Gauge Neeru Fireblade's reaction to you being a member of the Burning Blade", {[1637]={{49.6,50.46},},},},
        },
        [5742] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tirion's Tale", {[139]={{7.51,43.69},},},},
        },
        [5821] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Gizelton Caravan past Kolkar Centaur Village", {[405]={{67.17,56.62},},},},
        },
        [5882] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9528,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.preQuestSingle] = {4101},
            [QuestieDB.questKeys.exclusiveTo] = {5883,5884,5885,5886,},
        },
        [5883] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9528,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.preQuestSingle] = {4101},
            [QuestieDB.questKeys.exclusiveTo] = {5882,5884,5885,5886,},
        },
        [5884] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9528,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.preQuestSingle] = {4101},
            [QuestieDB.questKeys.exclusiveTo] = {5882,5883,5885,5886,},
        },
        [5885] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9528,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.preQuestSingle] = {4101},
            [QuestieDB.questKeys.exclusiveTo] = {5882,5883,5884,5886,},
        },
        [5886] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{9528,},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.preQuestSingle] = {4101},
            [QuestieDB.questKeys.exclusiveTo] = {5882,5883,5884,5885,},
        },
        -- Horde
        [5887] = {
            [QuestieDB.questKeys.preQuestSingle] = {4102},
            [QuestieDB.questKeys.exclusiveTo] = {5888,5889,5890,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5888] = {
            [QuestieDB.questKeys.preQuestSingle] = {4102},
            [QuestieDB.questKeys.exclusiveTo] = {5887,5889,5890,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5889] = {
            [QuestieDB.questKeys.preQuestSingle] = {4102},
            [QuestieDB.questKeys.exclusiveTo] = {5887,5888,5890,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5890] = {
            [QuestieDB.questKeys.preQuestSingle] = {4102},
            [QuestieDB.questKeys.exclusiveTo] = {5887,5888,5889,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5891] = {
            [QuestieDB.questKeys.preQuestSingle] = {4102},
            [QuestieDB.questKeys.exclusiveTo] = {5887,5888,5889,5890,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5892] = {
            [QuestieDB.questKeys.questLevel] = 55,
        },
        [5893] = {
            [QuestieDB.questKeys.questLevel] = 55,
        },
        -----------------------
        [5929] = {
            [QuestieDB.questKeys.triggerEnd] = {"Seek out the Great Bear Spirit and learn what it has to share with you about the nature of the bear.", {[493]={{39.25,27.73},},},},
        },
        [5930] = {
            [QuestieDB.questKeys.triggerEnd] = {"Seek out the Great Bear Spirit and learn what it has to share with you about the nature of the bear.", {[493]={{39.25,27.73},},},},
        },
        [5943] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Gizelton Caravan past Mannoroc Coven", {[405]={{55.69,67.79},},},},
        },
        [5944] = {
            [QuestieDB.questKeys.triggerEnd] = {"Redemption?", {[28]={{53.86,24.32},},},},
        },
        [6001] = {
            [QuestieDB.questKeys.triggerEnd] = {"Face Lunaclaw and earn the strength of body and heart it possesses.", {[148]={{43.3,45.82}},[17]={{41.96,60.81},},},},
        },
        [6002] = {
            [QuestieDB.questKeys.triggerEnd] = {"Face Lunaclaw and earn the strength of body and heart it possesses.", {[148]={{43.3,45.82}},[17]={{41.96,60.81},},},},
        },
        [6061] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame an Adult Plainstrider", {[215]={{43.5,44.99},{43.69,51.84},{52.68,57.44},{41.96,55.26},{48.15,47.89},},},},
        },
        [6062] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Dire Mottled Boar", {[14]={{51.54,45.89},{52.44,48.97},},},},
        },
        [6063] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Webwood Lurker", {[141]={{59.18,58.07},{53.97,62.29},},},},
        },
        [6064] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Large Crag Boar", {[1]={{48.29,56.71},{40.19,47.1},{50.59,51.31},{48.07,47.34},},},},
        },
        [6065] = {
            [QuestieDB.questKeys.exclusiveTo] = {6066,6067,6061},
        },
        [6066] = {
            [QuestieDB.questKeys.exclusiveTo] = {6065,6067,6061},
        },
        [6067] = {
            [QuestieDB.questKeys.exclusiveTo] = {6065,6066,6061},
        },
        [6068] = {
            [QuestieDB.questKeys.exclusiveTo] = {6069,6070,6062}, -- #1795
        },
        [6069] = {
            [QuestieDB.questKeys.startedBy] = {{11814,},nil,nil,}, -- #1523
            [QuestieDB.questKeys.exclusiveTo] = {6068,6070,6062}, -- #1795
        },
        -- "The Hunter's Path" now started by "Kary Thunderhorn" in Thunder Bluff
        [6070] = {
            [QuestieDB.questKeys.startedBy] = {{3038,},nil,nil,},
            [QuestieDB.questKeys.exclusiveTo] = {6068,6069,6062}, -- #1795
        },
        [6071] = {
            [QuestieDB.questKeys.exclusiveTo] = {6072,6073,6721,6722,6063},
        },
        [6072] = {
            [QuestieDB.questKeys.exclusiveTo] = {6071,6073,6721,6722,6063},
        },
        [6073] = {
            [QuestieDB.questKeys.startedBy] = {{5515,},nil,nil,},
            [QuestieDB.questKeys.exclusiveTo] = {6071,6072,6721,6722,6063},
        },
        [6074] = {
            [QuestieDB.questKeys.startedBy] = {{5516,},nil,nil,},
            [QuestieDB.questKeys.exclusiveTo] = {6075,6076,6064},
        },
        [6075] = {
            [QuestieDB.questKeys.startedBy] = {{11807,},nil,nil,},
            [QuestieDB.questKeys.exclusiveTo] = {6074,6076,6064},
        },
        [6076] = {
            [QuestieDB.questKeys.exclusiveTo] = {6074,6075,6064},
        },
        [6082] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame an Armored Scorpid", {[14]={{45.27,45.59},{54.99,37.63},},},},
        },
        [6083] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Surf Crawler", {[14]={{58.94,29.09},{61.07,78.01},},},},
        },
        [6084] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Snow Leopard", {[1]={{48.41,59.35},{37.78,38.02},},},},
        },
        [6085] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame an Ice Claw Bear", {[1]={{49.89,53.52},{37.04,44.95},{50.16,58.83},},},},
        },
        [6087] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Prairie Stalker", {[215]={{43.5,51.95},{46.73,49.71},{42.99,47.64},{59.13,58.63},},},},
        },
        [6088] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Swoop", {[215]={{46.55,49.4},{42.75,49.11},{43.07,52.3},{46.58,45.05},{42.44,43.16},},},},
        },
        [6101] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Nightsaber Stalker", {[141]={{40.09,55.45},{55.92,72.07},{46.89,72.28},},},},
        },
        [6102] = {
            [QuestieDB.questKeys.triggerEnd] = {"Tame a Strigid Screecher", {[141]={{43.81,50.88},},},},
        },
        [6136] = {
            [QuestieDB.questKeys.preQuestSingle] = {6133}, -- #1572
        },
        [6141] = {
            [QuestieDB.questKeys.exclusiveTo] = {261}, -- #1744
        },
        [6144] = {
            [QuestieDB.questKeys.preQuestSingle] = {6022,6042,6133,6135,6136}, -- #1950
        },
        [6163] = {
            [QuestieDB.questKeys.preQuestSingle] = {6022,6042,6133,6135,6136}, -- #1950
        },
        [6185] = {
            [QuestieDB.questKeys.triggerEnd] = {"The Blightcaller Uncovered",{[28]={{84.65,52.25},},},},
        },
        [6382] = {
            [QuestieDB.questKeys.preQuestSingle] = {882},
            [QuestieDB.questKeys.exclusiveTo] = {235,742,},
        },
        [6383] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [6403] = {
            [QuestieDB.questKeys.triggerEnd] = {"Reginald's March", {[1519]={{77.57,18.59}},},},
        },
        [6482] = {
            [QuestieDB.questKeys.triggerEnd] = {"Escort Ruul from the Thistlefurs.", {[331]={{38.53,37.32},},},},
        },
        [6522] = {
            [QuestieDB.questKeys.startedBy] = {{4421},nil,{17008}},
        },
        [6523] = {
            [QuestieDB.questKeys.triggerEnd] = {"Kaya Escorted to Camp Aparaje", {[406]={{77.1,90.85},},},},
        },
        [6544] = {
            [QuestieDB.questKeys.triggerEnd] = {"Take Silverwing Outpost.", {[331]={{64.65,75.35},},},},
        },
        [6562] = {
            [QuestieDB.questKeys.exclusiveTo] = {6563}, -- #1826
        },
        [6563] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1826
        },
        [6564] = {
            [QuestieDB.questKeys.startedBy] = {{4802},nil,{16790}},
        },
        [6566] = {
            [QuestieDB.questKeys.triggerEnd] = {"Thrall's Tale", {[1637]={{31.78,37.81},},},},
        },
        [6603] = {
            [QuestieDB.questKeys.exclusiveTo] = {5082},
        },
        [6605] = {
            [QuestieDB.questKeys.exclusiveTo] = {4505}, -- #1859
        },
        [6608] = {
            [QuestieDB.questKeys.exclusiveTo] = {6607}, -- #1186
        },
        [6609] = {
            [QuestieDB.questKeys.exclusiveTo] = {6607}, -- #1154
        },
        [6622] = {
            [QuestieDB.questKeys.triggerEnd] = {"15 Patients Saved!", {[15]={{67.79,49.06},},},},
        },
        [6623] = {
            [QuestieDB.questKeys.exclusiveTo] = {6622},
        },
        [6624] = {
            [QuestieDB.questKeys.triggerEnd] = {"15 Patients Saved!", {[15]={{67.79,49.06},},},},
        },
        [6625] = {
            [QuestieDB.questKeys.exclusiveTo] = {6624}, -- #1723
        },
        [6627] = {
            [QuestieDB.questKeys.triggerEnd] = {"Answer Braug Dimspirit's question correctly", {[406]={{78.75,45.63},},},},
        },
        [6628] = {
            [QuestieDB.questKeys.triggerEnd] = {"Answer Parqual Fintallas' question correctly", {[1497]={{57.72,65.22},},},},
        },
        [6641] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defeat Vorsha the Lasher", {[331]={{9.59,27.58},},},},
        },
        [6642] = {
            [QuestieDB.questKeys.requiredMinRep] = {59,9000},
        },
        [6643] = {
            [QuestieDB.questKeys.requiredMinRep] = {59,9000},
        },
        [6644] = {
            [QuestieDB.questKeys.requiredMinRep] = {59,9000},
        },
        [6645] = {
            [QuestieDB.questKeys.requiredMinRep] = {59,9000},
        },
        [6646] = {
            [QuestieDB.questKeys.requiredMinRep] = {59,9000},
        },
        [6721] = {
            [QuestieDB.questKeys.startedBy] = {{5116},nil,nil},
            [QuestieDB.questKeys.exclusiveTo] = {6071,6072,6073,6722,6063},
        },
        [6722] = {
            [QuestieDB.questKeys.startedBy] = {{1231},nil,nil},
            [QuestieDB.questKeys.exclusiveTo] = {6071,6072,6073,6721,6063},
        },
        [6861] = {
            [QuestieDB.questKeys.objectivesText] = {},
        },
        [6862] = {
            [QuestieDB.questKeys.objectivesText] = {},
        },
        [6922] = {
            [QuestieDB.questKeys.startedBy] = {{12876},nil,{16782}},
        },
        [6961] = {
            [QuestieDB.questKeys.exclusiveTo] = {7021,7024},
        },
        [6981] = {
            [QuestieDB.questKeys.startedBy] = {{3654},nil,{10441}},
            [QuestieDB.questKeys.triggerEnd] = {"Speak with someone in Ratchet about the Glowing Shard", {[17]={{62.97,37.21},},},},
        },
        [6982] = {
            [QuestieDB.questKeys.questLevel] = 55,
        },
        [6985] = {
            [QuestieDB.questKeys.questLevel] = 55,
        },
        [7001] = {
            [QuestieDB.questKeys.triggerEnd] = {"Frostwolf Muzzled and Returned", {[1637]={{79.18,31.12},{32.63,63.29},{59.27,53.14}},[36]={{67,51.78},},},},
        },
        [7002] = {
            [QuestieDB.questKeys.objectivesText] = {},
        },
        [7021] = {
            [QuestieDB.questKeys.finishedBy] = {{13445,},nil,},
            [QuestieDB.questKeys.exclusiveTo] = {6961,7024},
        },
        [7024] = {
            [QuestieDB.questKeys.finishedBy] = {{13445,},nil,},
            [QuestieDB.questKeys.exclusiveTo] = {6961,7021},
        },
        [7026] = {
            [QuestieDB.questKeys.objectivesText] = {},
        },
        [7027] = {
            [QuestieDB.questKeys.triggerEnd] = {"Ram Collared and Returned", {[1537]={{70.1,90.32},{66.54,86.33}},[36]={{34.58,74.94}},[1519]={{82.34,12.46},},},},
        },
        [7046] = {
            [QuestieDB.questKeys.triggerEnd] = {"Create the Scepter of Celebras", {[405]={{35.97,64.41},},},},
        },
        [7062] = {
            [QuestieDB.questKeys.startedBy] = {{1365,},nil,nil,},
        },
        [7068] = {
            [QuestieDB.questKeys.requiredLevel] = 39,
        },
        [7070] = {
            [QuestieDB.questKeys.requiredLevel] = 39,
        },
        [7081] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [7082] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [7121] = {
            [QuestieDB.questKeys.exclusiveTo] = {7122},
        },
        [7123] = {
            [QuestieDB.questKeys.exclusiveTo] = {7124},
        },
        [7141] = {
            [QuestieDB.questKeys.triggerEnd] = {"Defeat Drek'thar.",{[2597]={{47.22,86.95},},},},
        },
        [7142] = {
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.triggerEnd] = {"Defeat Vanndar Stormpike.",{[2597]={{42.29,12.85},},},},
        },
        [7161] = {
            [QuestieDB.questKeys.requiredRaces] = 0, -- #813
        },
        [7165] = {
            [QuestieDB.questKeys.requiredRaces] = 0, -- #813
        },
        [7166] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [7167] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [7170] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [7171] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [7172] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [7201] = {
            [QuestieDB.questKeys.preQuestSingle] = {3906},
        },
        [7241] = {
            [QuestieDB.questKeys.exclusiveTo] = {7161},
        },
        [7261] = {
            [QuestieDB.questKeys.exclusiveTo] = {7162},
        },
        [7281] = {
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [7282] = {
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [7385] = {
            [QuestieDB.questKeys.objectivesText] = {},
        },
        [7386] = {
            [QuestieDB.questKeys.objectivesText] = {},
        },
        [7426] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [7427] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [7428] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [7481] = {
            [QuestieDB.questKeys.triggerEnd] = {"Master Kariel Winthalus Found", {[357]={{62.86,24.88},{60.34,30.71},},},},
        },
        [7482] = {
            [QuestieDB.questKeys.triggerEnd] = {"Master Kariel Winthalus Found", {[357]={{62.86,24.88},{60.34,30.71},},},},
        },
        [7483] = {
            [QuestieDB.questKeys.preQuestSingle] = {7481,7482},
        },
        [7484] = {
            [QuestieDB.questKeys.preQuestSingle] = {7481,7482},
        },
        [7485] = {
            [QuestieDB.questKeys.preQuestSingle] = {7481,7482},
        },
        [7488] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1740
        },
        [7489] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1514
        },
        [7492] = {
            [QuestieDB.questKeys.startedBy] = {{10879,10880,10881,},nil,nil,}, -- #1350
        },
        [7507] = {
            [QuestieDB.questKeys.requiredClasses] = 3,
        },
        [7508] = {
            [QuestieDB.questKeys.requiredClasses] = 3,
        },
        [7509] = {
            [QuestieDB.questKeys.requiredClasses] = 3,
        },
        [7541] = {
            [QuestieDB.questKeys.questLevel] = 40, -- #1320
        },
        [7562] = {
            [QuestieDB.questKeys.startedBy] = {{5520,5815,6382,},nil,nil,}, -- #1343
        },
        [7633] = {
            [QuestieDB.questKeys.preQuestSingle] = {7632},
        },
        [7668] = { -- #1344
            [QuestieDB.questKeys.name] = "The Darkreaver Menace",
            [QuestieDB.questKeys.startedBy] = {{13417},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{13417},nil,},
            [QuestieDB.questKeys.requiredLevel] = 58,
            [QuestieDB.questKeys.questLevel] = 60,
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.requiredClasses] = 64,
            [QuestieDB.questKeys.objectivesText] = {"Bring Darkreaver's Head to Sagorne Creststrider in the Valley of Wisdom, Orgrimmar."},
            [QuestieDB.questKeys.objectives] = {nil,nil,{{18880,nil},},nil,},
            [QuestieDB.questKeys.sourceItemId] = 18746,
            [QuestieDB.questKeys.zoneOrSort] = 1637,
        },
        [7669] = { --#1449
            [QuestieDB.questKeys.name] = "Again Into the Great Ossuary",
            [QuestieDB.questKeys.startedBy] = {{13417,},nil,nil,},            -- Quest is started by Lord Grayson Shadowbreaker
            [QuestieDB.questKeys.finishedBy] = {{13417,},nil,nil,},           --       & ended*
            [QuestieDB.questKeys.requiredLevel] = 58,
            [QuestieDB.questKeys.questLevel] = 60,
            [QuestieDB.questKeys.requiredRaces] = 178,                      -- Any race can take on quest
            [QuestieDB.questKeys.requiredClasses] = 64,                     -- This quest is for the Shaman class
            [QuestieDB.questKeys.zoneOrSort] = -141,                        -- <0: QuestSort.dbc ID
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [7670] = { -- #1432
            [QuestieDB.questKeys.name] = "Lord Grayson Shadowbreaker",
            [QuestieDB.questKeys.startedBy] = {{5149},nil,nil,},
            [QuestieDB.questKeys.finishedBy] = {{928},nil,},
            [QuestieDB.questKeys.requiredLevel] = 60,
            [QuestieDB.questKeys.questLevel] = 60,
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.requiredClasses] = 2,
            [QuestieDB.questKeys.objectivesText] = {"Speak with Lord Grayson Shadowbreaker in Stormwind's Cathedral District."},
            [QuestieDB.questKeys.nextQuestInChain] = 7637,
            [QuestieDB.questKeys.exclusiveTo] = {7638,},
            [QuestieDB.questKeys.zoneOrSort] = -141,
        },
        [7761] = {
            [QuestieDB.questKeys.startedBy] = {{9046},nil,{18987}},
        },
        [7785] = {
            [QuestieDB.questKeys.requiredClasses] = 15,
        },
        [7786] = {
            [QuestieDB.questKeys.requiredClasses] = 15,
        },
        [7787] = {
            [QuestieDB.questKeys.requiredClasses] = 15,
        },
        [7838] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1589
        },
        [7843] = {
            [QuestieDB.questKeys.triggerEnd] = {"Message to the Wildhammer Delivered", {[47]={{14.34,48.07},},},},
        },
        [7886] = { -- #1435
            [QuestieDB.questKeys.startedBy] = {{14733},nil,nil},
            [QuestieDB.questKeys.finishedBy] = {{14733},nil,},
        },
        [7887] = { -- #1435
            [QuestieDB.questKeys.startedBy] = {{14733},nil,nil},
            [QuestieDB.questKeys.finishedBy] = {{14733},nil,},
        },
        [7888] = { -- #1435
            [QuestieDB.questKeys.startedBy] = {{14733},nil,nil},
            [QuestieDB.questKeys.finishedBy] = {{14733},nil,},
        },
        [7921] = { -- #1435
            [QuestieDB.questKeys.startedBy] = {{14733},nil,nil},
            [QuestieDB.questKeys.finishedBy] = {{14733},nil,},
        },
        [7946] = {
            [QuestieDB.questKeys.questLevel] = 60,
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8105] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8114] = {
            [QuestieDB.questKeys.requiredMinRep] = {509,3000},
            [QuestieDB.questKeys.triggerEnd] = {"Control Four Bases.", {[45]={{46.03,45.3},},},},
        },
        [8115] = {
            [QuestieDB.questKeys.requiredMinRep] = {509,42000},
        },
        [8120] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8121] = {
            [QuestieDB.questKeys.requiredMinRep] = {510,3000},
            [QuestieDB.questKeys.triggerEnd] = {"Hold Four Bases.", {[1638]={{40.4,51.57}},[45]={{73.72,29.52}},[1637]={{50.1,69.03}},[130]={{39.68,17.75},},},},
        },
        [8122] = {
            [QuestieDB.questKeys.requiredMinRep] = {510,42000},
        },
        [8149] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8150] = { -- bad race data
            [QuestieDB.questKeys.exclusiveTo] = {2851},
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8166] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8167] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8168] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8169] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8170] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8171] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8184] = {
            [QuestieDB.questKeys.requiredClasses] = 1,
        },
        [8185] = {
            [QuestieDB.questKeys.requiredClasses] = 2,
        },
        [8186] = {
            [QuestieDB.questKeys.requiredClasses] = 8,
        },
        [8187] = {
            [QuestieDB.questKeys.requiredClasses] = 4,
        },
        [8188] = {
            [QuestieDB.questKeys.requiredClasses] = 64,
        },
        [8189] = {
            [QuestieDB.questKeys.requiredClasses] = 128,
        },
        [8190] = {
            [QuestieDB.questKeys.requiredClasses] = 256,
        },
        [8191] = {
            [QuestieDB.questKeys.requiredClasses] = 16,
        },
        [8192] = {
            [QuestieDB.questKeys.requiredClasses] = 1024,
        },
        [8251] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [8271] = {
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8272] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8280] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1873
        },
        [8286] = {
            [QuestieDB.questKeys.triggerEnd] = {"Discover the Brood of Nozdormu.",{[440]={{63.43, 50.61},},},},
        },
        [8289] = { -- #1435
            [QuestieDB.questKeys.startedBy] = {{14733},nil,nil},
            [QuestieDB.questKeys.finishedBy] = {{14733},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8296] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8314] = {
            [QuestieDB.questKeys.specialFlags] = nil, -- #1870
        },
        [8331]  ={
            [QuestieDB.questKeys.exclusiveTo] = {},
        },
        [8332] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [8368] = {
            [QuestieDB.questKeys.exclusiveTo] = {8426,8427,8428,8429,8430},
        },
        [8371] = {
            [QuestieDB.questKeys.zoneOrSort] = 3358,
        },
        [8372] = {
            [QuestieDB.questKeys.exclusiveTo] = {8399,8400,8401,8402,8403},
        },
        [8385] = {
            [QuestieDB.questKeys.zoneOrSort] = 3358,
        },
        [8399] = {
            [QuestieDB.questKeys.exclusiveTo] = {8372,8400,8401,8402,8403},
        },
        [8400] = {
            [QuestieDB.questKeys.exclusiveTo] = {8372,8399,8401,8402,8403},
        },
        [8401] = {
            [QuestieDB.questKeys.exclusiveTo] = {8372,8399,8400,8402,8403},
        },
        [8402] = {
            [QuestieDB.questKeys.exclusiveTo] = {8372,8399,8400,8401,8403},
        },
        [8403] = {
            [QuestieDB.questKeys.exclusiveTo] = {8372,8399,8400,8401,8402},
        },
        [8423] = {
            [QuestieDB.questKeys.preQuestSingle] = {8417},
        },
        [8426] = {
            [QuestieDB.questKeys.exclusiveTo] = {8368,8427,8428,8429,8430},
        },
        [8427] = {
            [QuestieDB.questKeys.exclusiveTo] = {8368,8426,8428,8429,8430},
        },
        [8428] = {
            [QuestieDB.questKeys.exclusiveTo] = {8368,8426,8427,8429,8430},
        },
        [8429] = {
            [QuestieDB.questKeys.exclusiveTo] = {8368,8426,8427,8428,8430},
        },
        [8430] = {
            [QuestieDB.questKeys.exclusiveTo] = {8368,8426,8427,8428,8429},
        },
        [8493] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8495] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8504] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8506] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8510] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8512] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8514] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8516] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8518] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8521] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8523] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8525] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8527] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8529] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8533] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8543] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8546] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8548] = {
            [QuestieDB.questKeys.preQuestSingle] = {8800},
        },        
        [8550] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8552] = {
            [QuestieDB.questKeys.startedBy] = {{1493},nil,{3985,},},
        },
        [8572] = {
            [QuestieDB.questKeys.preQuestSingle] = {8800},
        },
        [8573] = {
            [QuestieDB.questKeys.preQuestSingle] = {8800},
        },
        [8574] = {
            [QuestieDB.questKeys.preQuestSingle] = {8800},
        },        
        [8581] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8583] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8589] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8591] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8601] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8605] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8608] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8610] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8612] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8614] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8616] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8767] = {
            [QuestieDB.questKeys.requiredRaces] = 255,
            [QuestieDB.questKeys.requiredClasses] = 0,
            [QuestieDB.questKeys.exclusiveTo] = {8788},
        },
        [8788] = {
            [QuestieDB.questKeys.requiredRaces] = 255,
            [QuestieDB.questKeys.requiredClasses] = 0,
            [QuestieDB.questKeys.exclusiveTo] = {8767},
        },
        [8798] = {
            [QuestieDB.questKeys.requiredSkill] = {202,250},
        },
        [8863] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8864] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8865] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8867] = {
            [QuestieDB.questKeys.requiredSourceItems] = {21557,21558,21559,21571,21574,21576,},
        },
        [8868] = {
            [QuestieDB.questKeys.triggerEnd] = {"Receive Elune's Blessing.", {[493]={{63.89,62.5},},},},
        },
        [8870] = {
            [QuestieDB.questKeys.exclusiveTo] = {8867,8871,8872},
        },
        [8871] = {
            [QuestieDB.questKeys.exclusiveTo] = {8867,8870,8872},
        },
        [8872] = {
            [QuestieDB.questKeys.exclusiveTo] = {8867,8870,8871},
        },
        [8873] = {
            [QuestieDB.questKeys.exclusiveTo] = {8867,8874,8875},
        },
        [8874] = {
            [QuestieDB.questKeys.exclusiveTo] = {8867,8873,8875},
        },
        [8875] = {
            [QuestieDB.questKeys.exclusiveTo] = {8867,8873,8874},
        },
        [8876] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8877] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8878] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8879] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8880] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8881] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8882] = {
            [QuestieDB.questKeys.specialFlags] = 1,
        },
        [8897] = {
            [QuestieDB.questKeys.exclusiveTo] = {8898,8899,8903},
        },
        [8898] = {
            [QuestieDB.questKeys.exclusiveTo] = {8897,8899,8903},
        },
        [8899] = {
            [QuestieDB.questKeys.exclusiveTo] = {8897,8898,8903},
        },
        [8900] = {
            [QuestieDB.questKeys.exclusiveTo] = {8901,8902,8904},
        },
        [8901] = {
            [QuestieDB.questKeys.exclusiveTo] = {8900,8902,8904},
        },
        [8902] = {
            [QuestieDB.questKeys.exclusiveTo] = {8900,8901,8904},
        },
        [8903] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [8904] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [8980] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [9026] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [9033] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [9051] = {
            [QuestieDB.questKeys.triggerEnd] = {"Devilsaur stabbed with barb", {[490]={{64.32,59.45},{67.98,58.07},{53.82,63.08},{57.99,73.93},{73.87,38.34},},},},
        },
        [9063] = {
            [QuestieDB.questKeys.zoneOrSort] = 493,
        },
        [9261] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [9262] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [9319] = {
            [QuestieDB.questKeys.requiredRaces] = 255,
            [QuestieDB.questKeys.parentQuest] = 9386,
        },
        [9386] = {
            [QuestieDB.questKeys.preQuestSingle] = {9319},
            [QuestieDB.questKeys.requiredRaces] = 255,
            [QuestieDB.questKeys.specialFlags] = 1,
        },
    }
end

function QuestieQuestFixes:LoadFactionFixes()
    local questFixesHorde = {
        [687] = {
            [QuestieDB.questKeys.startedBy] = {{2787,},nil,nil}
        },
        [737] = {
            [QuestieDB.questKeys.startedBy] = {{2934,},nil,nil}
        },
        [1718] = {
            [QuestieDB.questKeys.startedBy] = {{3041,3354,4595,},nil,nil}
        },
        [1947] = {
            [QuestieDB.questKeys.startedBy] = {{3048,4568,5885,},nil,nil}
        },
        [1953] = {
            [QuestieDB.questKeys.startedBy] = {{3048,4568,5885,},nil,nil}
        },
        [2861] = {
            [QuestieDB.questKeys.startedBy] = {{4568,5885,},nil,nil}
        },
        [5050] = {
            [QuestieDB.questKeys.startedBy] = {{8403,},nil,nil}
        },
        [7562] = {
            [QuestieDB.questKeys.startedBy] = {{5753,5815,},nil,nil}
        },
        [8151] = {
            [QuestieDB.questKeys.startedBy] = {{3039,3352,},nil,nil},
        },
        [8233] = {
            [QuestieDB.questKeys.startedBy] = {{3328,4583,},nil,nil},
        },
        [8250] = {
            [QuestieDB.questKeys.startedBy] = {{3047,7311,},nil,nil},
        },
        [8254] = {
            [QuestieDB.questKeys.startedBy] = {{6018,},nil,nil},
        },
        [8417] = {
            [QuestieDB.questKeys.startedBy] = {{3354,4593,},nil,nil,},
        },
        [8419] = {
            [QuestieDB.questKeys.startedBy] = {{3326,4563,},nil,nil,},
        },
        [9063] = {
            [QuestieDB.questKeys.startedBy] = {{3033,12042,},nil,nil,},
        },
        [9388] = {
            [QuestieDB.questKeys.startedBy] = {{16818,},nil,nil,},
        },
        [9389] = {
            [QuestieDB.questKeys.startedBy] = {{16818,},nil,nil,},
        },
    }

    local questFixesAlliance = {
        [687] = {
            [QuestieDB.questKeys.startedBy] = {{2786,},nil,nil}
        },
        [737] = {
            [QuestieDB.questKeys.startedBy] = {{2786,},nil,nil}
        },
        [1718] = {
            [QuestieDB.questKeys.startedBy] = {{5113,5479,},nil,nil}
        },
        [1947] = {
            [QuestieDB.questKeys.startedBy] = {{5144,5497,},nil,nil}
        },
        [1953] = {
            [QuestieDB.questKeys.startedBy] = {{5144,5497,},nil,nil}
        },
        [2861] = {
            [QuestieDB.questKeys.startedBy] = {{5144,5497,},nil,nil}
        },
        [5050] = {
            [QuestieDB.questKeys.startedBy] = {{3520,},nil,nil}
        },
        [7562] = {
            [QuestieDB.questKeys.startedBy] = {{5520,6382,},nil,nil}
        },
        [8151] = {
            [QuestieDB.questKeys.startedBy] = {{4205,5116,5516,},nil,nil},
        },
        [8233] = {
            [QuestieDB.questKeys.startedBy] = {{918,4163,5165,},nil,nil},
        },
        [8250] = {
            [QuestieDB.questKeys.startedBy] = {{331,7312,},nil,nil},
        },
        [8254] = {
            [QuestieDB.questKeys.startedBy] = {{5489,11406,},nil,nil},
        },
        [8417] = {
            [QuestieDB.questKeys.startedBy] = {{5113,5479,},nil,nil,},
        },
        [8419] = {
            [QuestieDB.questKeys.startedBy] = {{461,5172,},nil,nil,},
        },
        [9063] = {
            [QuestieDB.questKeys.startedBy] = {{4217,5505,12042,},nil,nil,},
        },
        [9388] = {
            [QuestieDB.questKeys.startedBy] = {{16817,},nil,nil,},
        },
        [9389] = {
            [QuestieDB.questKeys.startedBy] = {{16817,},nil,nil,},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
