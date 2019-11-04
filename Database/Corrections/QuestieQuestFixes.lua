QuestieQuestFixes = {...}
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

function QuestieQuestFixes:Load()
    table.insert(QuestieDB.questData, 7668, {}) -- Add missing quest index
    table.insert(QuestieDB.questData, 7669, {}) -- Add missing quest index
    table.insert(QuestieDB.questData, 7670, {}) -- Add missing quest index #1432

    return {
        [5] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1198
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
            [QuestieDB.questKeys.exclusiveTo] = {5261},
        },
        [46] = {
            [QuestieDB.questKeys.preQuestSingle] = {39},
        },
        [90] = {
            [QuestieDB.questKeys.requiredSkill] = {185, 50}
        },
        [148] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1173
        },
        [163] = {
            [QuestieDB.questKeys.exclusiveTo] = {5}, -- Raven Hill breadcrumb
        },
        [164] = {
            [QuestieDB.questKeys.exclusiveTo] = {95}, -- deliveries to sven is a breadcrumb
        },
        [165] = {
            [QuestieDB.questKeys.exclusiveTo] = {148}, --#1173
        },
        [308] = {
            [QuestieDB.questKeys.exclusiveTo] = {311}, -- distracting jarven can't be completed once you get the followup
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
        [374] = {
            [QuestieDB.questKeys.preQuestSingle] = {427}, -- proof of demise requires at war with the scarlet crusade
        },
        [403] = {
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
        [431] = { -- candles of beckoning
            [QuestieDB.questKeys.preQuestSingle] = {366}, -- #638
            [QuestieDB.questKeys.exclusiveTo] = {411}, -- #752
        },
        [463] = {
            [QuestieDB.questKeys.exclusiveTo] = {276}, --greenwarden cant be completed if you have trampling paws
        },
        [467] = {
            [QuestieDB.questKeys.startedBy] = {{1340,2092,},nil,nil,}, -- #1379
        },
        [473] = {
            [QuestieDB.questKeys.preQuestSingle] = {455}, -- #809
        },
        [526] = {
            [QuestieDB.questKeys.exclusiveTo] = {322,324}, -- not 100% sure on this one but it seems lightforge ingots is optional, block it after completing subsequent steps (#587)
        },
        [535] = {
            [QuestieDB.questKeys.exclusiveTo] = {533}, -- #1134
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
        [598] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.preQuestGroup] = {596,629,}
        },
        [621] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
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
        [691] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [715] = {
            [QuestieDB.questKeys.preQuestGroup] = {712,714,},
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.requiredSkill] = {},
        },
        [736] = {
            [QuestieDB.questKeys.requiredSourceItems] = {4639},
        },
        [738] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1289
        },
        [769] = {
            [QuestieDB.questKeys.requiredSkill] = {165,10},
        },
        [841] = {
            [QuestieDB.questKeys.specialFlags] = 1,
            [QuestieDB.questKeys.exclusiveTo] = {654},
        },
        [861] = {
            [QuestieDB.questKeys.exclusiveTo] = {860,844}, -- #1109
        },
        [862] = {
            [QuestieDB.questKeys.requiredSkill] = {185,76}, -- You need to be a Journeyman for this quest
        },
        [926] = {
            [QuestieDB.questKeys.parentQuest] = 924, -- #806
            [QuestieDB.questKeys.preQuestSingle] = {809}, --#606
        },
        [930] = {
            [QuestieDB.questKeys.preQuestSingle] = {918,919}, -- #971
        },
        [1026] = {
            [QuestieDB.questKeys.requiredSourceItems] = {5475},
        },
        [1085] = {
            [QuestieDB.questKeys.preQuestSingle] = {1070},
        },
        [1100] = {
            [QuestieDB.questKeys.startedBy] = {nil,{19861},{5791},}, -- #1189
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
        [1193] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1348
        },
        [1204] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #938
        },
        [1275] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #973 -- #745 prequest is not required in Classic
        },
        [1276] = {
            [QuestieDB.questKeys.preQuestSingle] = {1273,},
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
        [1442] = {
            [QuestieDB.questKeys.parentQuest] = 1654,
        },
        [1470] = {
            [QuestieDB.questKeys.exclusiveTo] = {1485}, -- #999
        },
        [1473] = {
            [QuestieDB.questKeys.exclusiveTo] = {1501},
        },
        [1478] = {
            [QuestieDB.questKeys.exclusiveTo] = {1506}, -- #1427
        },
        [1485] = {
            [QuestieDB.questKeys.exclusiveTo] = {1470}, -- #999
        },
        [1501] = {
            [QuestieDB.questKeys.exclusiveTo] = {1473},
        },
        [1506] = {
            [QuestieDB.questKeys.exclusiveTo] = {1478}, -- #1427
        },
        [1598] = {
            [QuestieDB.questKeys.exclusiveTo] = {1599}, -- #999
        },
        [1599] = {
            [QuestieDB.questKeys.exclusiveTo] = {1598}, -- #999
            [QuestieDB.questKeys.preQuestSingle] = {705}, -- #1164
        },
        [1638] = {
            [QuestieDB.questKeys.exclusiveTo] = {},
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
        [1679] = {
            [QuestieDB.questKeys.exclusiveTo] = {},
        },
        [1684] = {
            [QuestieDB.questKeys.exclusiveTo] = {},
        },
        [1708] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1230
        },
        [1710] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1231
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
        [2781] = {
            [QuestieDB.questKeys.startedBy] = {nil,{142122,150075,},nil,}, -- #1081
        },
        [2861] = {
            [QuestieDB.questKeys.startedBy] = {{4568,5144,5497,5885,},nil,nil,}, -- #1152
            [QuestieDB.questKeys.exclusiveTo] = {2846},
        },
        [2922] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- Save Techbot's Brain doesn't need the Tinkmaster Overspark breadcrumb #687
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
        [3374] = {
            [QuestieDB.questKeys.startedBy] = {{5353},nil,{10589,},}, -- #1233
        },
        [3375] = {
            [QuestieDB.questKeys.parentQuest] = 2201,
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
        [3681] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000},
        },
        [3765] = {
            [QuestieDB.questKeys.exclusiveTo] = {1275}, -- corruption abroad breadcrumb
        },
        [3791] = {
            [QuestieDB.questKeys.preQuestSingle] = {3788}, -- #885
        },
        [3903] = {
            [QuestieDB.questKeys.preQuestSingle] = {18},
        },
        [4083] = {
            [QuestieDB.questKeys.requiredSkill] = {186,230}, -- #1293
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
        [4224] = {
            [QuestieDB.questKeys.triggerEnd] = {"Ragged John's Story",{[46]={{64,23},},},},
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
        [4494] = {
            [QuestieDB.questKeys.preQuestSingle] = {82}, -- #942
        },
        [4496] = {
            [QuestieDB.questKeys.preQuestSingle] = {4493,4494},
        },
        [4641] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #877
        },
        [4763] = {
            [QuestieDB.questKeys.requiredSourceItems] = {12347,12341,12342,12343,}, -- #798
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
        [5122] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1140
        },
        [5166] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5167] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5211] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #983
            [QuestieDB.questKeys.objectives] = {{{11064,"Darrowshire Spirits Freed"},{8530,"Darrowshire Spirits Freed"},{8531,"Darrowshire Spirits Freed"},{8532,"Darrowshire Spirits Freed"},},nil,nil,nil,},
        },
        [5421] = {
            [QuestieDB.questKeys.questLevel] = 25,
        },
        [5634] = {
            [QuestieDB.questKeys.startedBy] = {{11401,},nil,nil,},
        },
        [5721] = {
            [QuestieDB.questKeys.requiredSourceItems] = {177528,}, -- 857
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
        -----------------------
        -- "The Hunter's Path" now started by "Kary Thunderhorn" in Thunder Bluff
        [6070] = {
            [QuestieDB.questKeys.startedBy] = {{3038,},nil,nil,},
        },
        [6608] = {
            [QuestieDB.questKeys.exclusiveTo] = {6607}, -- #1186
        },
        [6609] = {
            [QuestieDB.questKeys.exclusiveTo] = {6607}, -- #1154
        },
        [7068] = {
            [QuestieDB.questKeys.requiredLevel] = 39,
        },
        [7070] = {
            [QuestieDB.questKeys.requiredLevel] = 39,
        },
        [7492] = {
            [QuestieDB.questKeys.startedBy] = {{10879,10880,10881,},nil,nil,}, -- #1350
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
        [8289] = { -- #1435
            [QuestieDB.questKeys.startedBy] = {{14733},nil,nil},
            [QuestieDB.questKeys.finishedBy] = {{14733},nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.specialFlags] = 1,
        },
    }
end
