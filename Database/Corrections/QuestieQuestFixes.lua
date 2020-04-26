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
        [437] = {
            [QuestieDB.questKeys.triggerEnd] = {"Enter the Dead Fields",{[130]={{45.91, 21.27},},},},
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
        [535] = {
            [QuestieDB.questKeys.childQuests] = {535},
        },
        [535] = {
            [QuestieDB.questKeys.parentQuest] = {533},
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
        [841] = {
            [QuestieDB.questKeys.specialFlags] = 1,
            [QuestieDB.questKeys.exclusiveTo] = {654},
        },
        [860] = {
            [QuestieDB.questKeys.exclusiveTo] = {844},
        },
        [861] = {
            [QuestieDB.questKeys.nextQuestInChain] = {860},
            [QuestieDB.questKeys.exclusiveTo] = {860,844}, -- #1109
        },
        [862] = {
            [QuestieDB.questKeys.requiredSkill] = {185,76}, -- You need to be a Journeyman for this quest
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
        [939] = {
            [QuestieDB.questKeys.startedBy] = {{10648},nil,{11668}},
        },
        [944] = {
            [QuestieDB.questKeys.triggerEnd] = {"Enter the Master's Glaive",{[148]={{38.48,86.45},},},},
        },
        [961] = {
            [QuestieDB.questKeys.preQuestSingle] = {944}, -- #1517
            [QuestieDB.questKeys.exclusiveTo] = {950}, -- #1517
        },
        [1026] = {
            [QuestieDB.questKeys.requiredSourceItems] = {5475},
        },
        [1036] = {
            [QuestieDB.questKeys.requiredMinRep] = {87,1}, -- #1854
        },
        [1061] = {
            [QuestieDB.questKeys.exclusiveTo] = {1062}, -- #1803
        },
        [1085] = {
            [QuestieDB.questKeys.preQuestSingle] = {1070},
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
        [1148] = {
            [QuestieDB.questKeys.preQuestSingle] = {1146},
            [QuestieDB.questKeys.startedBy] = {{4130,4131,4133,},nil,{5877,},},
        },
        [1193] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1348
        },
        [1204] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #938
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
        [1442] = {
            [QuestieDB.questKeys.parentQuest] = 1654,
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
        [1559] = {
            [QuestieDB.questKeys.preQuestSingle] = {705},
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
        [1708] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1230
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
        [2480] = {
            [QuestieDB.questKeys.triggerEnd] = {"Cure Completed",{[267]={{61.57, 19.21}},},},
        },
        [2501] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1541
            [QuestieDB.questKeys.preQuestGroup] = {2500,17}, -- #1541
        },
        [2744] = {
            [QuestieDB.questKeys.triggerEnd] = {"Conversation with Loramus", {[16]={{60.8,66.4}},},},
        },
        [2781] = {
            [QuestieDB.questKeys.startedBy] = {nil,{142122,150075,},nil,}, -- #1081
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
        [2922] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- Save Techbot's Brain doesn't need the Tinkmaster Overspark breadcrumb #687
        },
        [2925] = {
            [QuestieDB.questKeys.exclusiveTo] = {2924},
        },
        [2931] = {
            [QuestieDB.questKeys.exclusiveTo] = {2930},
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
        [2978] = {
            [QuestieDB.questKeys.startedBy] = {nil,{143980},{9370,},}, -- #1596
        },
        [2981] = {
            [QuestieDB.questKeys.exclusiveTo] = {2975},
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
            [QuestieDB.questKeys.requiredRaces] = 256, -- #813
        },
        [3128] = {
            [QuestieDB.questKeys.preQuestSingle] = {3122},
        },
        [3181] = {
            [QuestieDB.questKeys.startedBy] = {{5833},nil,{10000}},
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
        [3385] = {
            [QuestieDB.questKeys.requiredSkill] = {197,226}, -- You need to be an Artisan for this quest
        },
        [3449] = {
            [QuestieDB.questKeys.childQuests] = {3483}, -- #1008
        },
        [3483] = {
            [QuestieDB.questKeys.parentQuest] = 3449, -- #1008
            [QuestieDB.questKeys.specialFlags] = 1, -- #1131
        },
        [3513] = {
            [QuestieDB.questKeys.startedBy] = {{5797},nil,{10621}},
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
        [3765] = {
            [QuestieDB.questKeys.exclusiveTo] = {1275}, -- corruption abroad breadcrumb
        },
        [3791] = {
            [QuestieDB.questKeys.preQuestSingle] = {3787,3788}, -- #885
        },
        [3903] = {
            [QuestieDB.questKeys.preQuestSingle] = {18},
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
        [4224] = {
            [QuestieDB.questKeys.triggerEnd] = {"Ragged John's Story",{[46]={{64,23},},},},
        },
        [4245] = {
            [QuestieDB.questKeys.triggerEnd] = {"Protect A-Me 01 until you reach Karna Remtravel",{[490]={{46.43, 13.78},},},},
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
        [4485] = {
            [QuestieDB.questKeys.exclusiveTo] = {1661,4486},
        },
        [4486] = {
            [QuestieDB.questKeys.exclusiveTo] = {1661,4485},
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
        [4641] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #877
        },
        [4763] = {
            [QuestieDB.questKeys.requiredSourceItems] = {12347,12341,12342,12343,}, -- #798
        },
        [4768] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1859
        },
        [4769] = {
            [QuestieDB.questKeys.exclusiveTo] = {4768},
        },
        [4784] = {
            [QuestieDB.questKeys.childQuests] = {4785}, -- #1367
        },
        [4785] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1367
            [QuestieDB.questKeys.parentQuest] = 4784, -- #1367
            [QuestieDB.questKeys.specialFlags] = 1, -- #1367
        },
        [4811] = {
            [QuestieDB.questKeys.triggerEnd] = {"Locate the large, red crystal on Darkshore's eastern mountain range",{[148]={{47.24,48.68},},},}, -- #1373
        },
        [4881] = {
            [QuestieDB.questKeys.startedBy] = {{10617},nil,{12564}},
        },
        [4907] = {
            [QuestieDB.questKeys.exclusiveTo] = {4734},
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
        [5089] = {
            [QuestieDB.questKeys.startedBy] = {{9568},nil,{12780}},
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
        [5166] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5167] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
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
        [5421] = {
            [QuestieDB.questKeys.questLevel] = 25,
        },
        [5582] = {
            [QuestieDB.questKeys.startedBy] = {{10678},nil,{13920}},
        },
        [5634] = {
            [QuestieDB.questKeys.startedBy] = {{11401,},nil,nil,},
        },
        [5721] = {
            [QuestieDB.questKeys.requiredSourceItems] = {15209,}, -- #857
        },
        -- Salve via Hunting/Mining/Gathering/Skinning/Disenchanting non repeatable quests
        -- Alliance
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
        [6136] = {
            [QuestieDB.questKeys.preQuestSingle] = {6133}, -- #1572
        },
        [6141] = {
            [QuestieDB.questKeys.exclusiveTo] = {261}, -- #1744
        },
        [6144] = {
            [QuestieDB.questKeys.preQuestSingle] = {6135,6136}, -- #1572
        },
        [6382] = {
            [QuestieDB.questKeys.preQuestSingle] = {882},
            [QuestieDB.questKeys.exclusiveTo] = {235,742,},
        },
        [6383] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [6522] = {
            [QuestieDB.questKeys.startedBy] = {{4421},nil,{17008}},
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
        [6623] = {
            [QuestieDB.questKeys.exclusiveTo] = {6622},
        },
        [6625] = {
            [QuestieDB.questKeys.exclusiveTo] = {6624}, -- #1723
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
        },
        [6982] = {
            [QuestieDB.questKeys.questLevel] = 55,
        },
        [6985] = {
            [QuestieDB.questKeys.questLevel] = 55,
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
        [7028] = {
            [QuestieDB.questKeys.objectivesText] = {"Collect 25 Theradric Crystal Carvings for Willow in Desolace.",},
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
        },
        [8115] = {
            [QuestieDB.questKeys.requiredMinRep] = {509,42000},
        },
        [8120] = {
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [8121] = {
            [QuestieDB.questKeys.requiredMinRep] = {510,3000},
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
        [8251] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
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
        [8271] = {
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [8240] = {
            [QuestieDB.questKeys.triggerEnd] = {"Destroy any Hakkari Bijou", {[33]={{13.4,15.1},},},},
        },
        [8272] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
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
        [8550] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 178,
        },
        [8552] = {
            [QuestieDB.questKeys.startedBy] = {{1493},nil,{3985,},},
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
        [9063] = {
            [QuestieDB.questKeys.zoneOrSort] = 493,
        },
        [9261] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
        },
        [9262] = { -- bad race data
            [QuestieDB.questKeys.requiredRaces] = 77,
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
