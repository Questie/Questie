QuestieQuestFixes = {...}

function QuestieQuestFixes:Load()
    table.insert(QuestieDB.questData, 7668, {}) -- Add missing quest index

    return {
        [5] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1198
        },
        [551] = {
            [QuestieDB.questKeys.startedBy] = {nil,{1765},{3706},}, -- #1245
        },
        [598] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
            [QuestieDB.questKeys.preQuestGroup] = {596,629,}
        },
        [639] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1205
        },
        [1026] = {
            [QuestieDB.questKeys.requiredSourceItems] = {5475},
        },
        [1100] = {
            [QuestieDB.questKeys.startedBy] = {nil,{1981},{5791},}, -- #1189
        },
        [1920] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1328
        },
        [2201] = {
            [QuestieDB.questKeys.childQuests] = {3375},
        },
        [3375] = {
            [QuestieDB.questKeys.parentQuest] = 2201,
        },
        [4083] = {
            [QuestieDB.questKeys.requiredSkill] = {186,230}, -- #1293
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
        [4763] = {
            [QuestieDB.questKeys.requiredSourceItems] = {12347,12341,12342,12343,}, -- #798
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
        [5166] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5167] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1335
        },
        [5721] = {
            [QuestieDB.questKeys.requiredSourceItems] = {177528,}, -- 857
        },
        [7541] = {
            [QuestieDB.questKeys.questLevel] = 40, -- #1320
        },
        [7562] = {
            [QuestieDB.questKeys.startedBy] = {{5520,5815,6382,},nil,nil,}, -- #1343
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
        [165] = {
            [QuestieDB.questKeys.exclusiveTo] = {148}, --#1173
        },
        [148] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1173
        },
        [310] = {
            [QuestieDB.questKeys.childQuests] = {403},
        },
        [403] = {
            [QuestieDB.questKeys.parentQuest] = 310,
        },
        [841] = {
            [QuestieDB.questKeys.specialFlags] = 1,
            [QuestieDB.questKeys.exclusiveTo] = {654},
        },
        [3090] = {
            [QuestieDB.questKeys.requiredRaces] = 256, -- #813
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
        [1638] = {
            [QuestieDB.questKeys.exclusiveTo] = {},
        },
        [1679] = {
            [QuestieDB.questKeys.exclusiveTo] = {},
        },
        [1684] = {
            [QuestieDB.questKeys.exclusiveTo] = {},
        },
        [535] = {
            [QuestieDB.questKeys.exclusiveTo] = {533}, -- #1134
        },
        [621] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
        },
        [1118] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
        },
        [1119] = {
            [QuestieDB.questKeys.inGroupWith] = {}, -- #886
        },
        [680] = {
            [QuestieDB.questKeys.preQuestSingle] = {678}, -- #1062
        },
        [691] = {
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [738] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1289
        },
        [7068] = {
            [QuestieDB.questKeys.requiredLevel] = 39,
        },
        [7070] = {
            [QuestieDB.questKeys.requiredLevel] = 39,
        },
        [2922] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- Save Techbot's Brain doesn't need the Tinkmaster Overspark breadcrumb #687
        },
        [1276] = {
            [QuestieDB.questKeys.preQuestGroup] = {1323,1273,},
            [QuestieDB.questKeys.preQuestSingle] = {},
        },
        [3374] = {
            [QuestieDB.questKeys.startedBy] = {{5353},nil,{10589,},}, -- #1233
        },
        [4641] = {
            [QuestieDB.questKeys.requiredRaces] = 178, -- #877
        },
        [1204] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #938
        },
        [4494] = {
            [QuestieDB.questKeys.preQuestSingle] = {82}, -- #942
        },
        [4496] = {
            [QuestieDB.questKeys.preQuestSingle] = {4493,4494},
        },
        [1127] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #884
            [QuestieDB.questKeys.parentQuest] = 1119, -- #1084
        },
        [1119] = {
            [QuestieDB.questKeys.childQuests] = {1127}, -- #1084
        },
        [1275] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #973 -- #745 prequest is not required in Classic
        },
        [1718] = {
            [QuestieDB.questKeys.startedBy] = {{3041,3354,4595,5113,5479,},nil,nil,}, -- #1034
        },
        [2781] = {
            [QuestieDB.questKeys.startedBy] = {nil,{142122,150075,},nil,}, -- #1081
        },
        [3449] = {
            [QuestieDB.questKeys.childQuests] = {3483}, -- #1008
        },
        [3483] = {
            [QuestieDB.questKeys.parentQuest] = 3449, -- #1008
            [QuestieDB.questKeys.specialFlags] = 1, -- #1131
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
        [5211] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #983
            [QuestieDB.questKeys.objectives] = {{{11064,"Darrowshire Spirits Freed"},{8530,"Darrowshire Spirits Freed"},{8531,"Darrowshire Spirits Freed"},{8532,"Darrowshire Spirits Freed"},},nil,nil,nil,},
        },
        [5059] = {
            [QuestieDB.questKeys.preQuestSingle] = {5058}, -- #922
        },
        [5060] = {
            [QuestieDB.questKeys.preQuestSingle] = {5059}, -- #922
        },
        [6609] = {
            [QuestieDB.questKeys.exclusiveTo] = {6607}, -- #1154
        },
        [6608] = {
            [QuestieDB.questKeys.exclusiveTo] = {6607}, -- #1186
        },
        [1879] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1192
        },
        [1860] = {
            [QuestieDB.questKeys.exclusiveTo] = {}, -- #1192
        },
        [1880] = {
            [QuestieDB.questKeys.exclusiveTo] = {1861}, -- #1192
        },
        [1861] = {
            [QuestieDB.questKeys.exclusiveTo] = {1880}, -- #1192
        },
        [1654] = {
            [QuestieDB.questKeys.childQuests] = {1442,1655},
        },
        [1442] = {
            [QuestieDB.questKeys.parentQuest] = 1654,
        },
        [1655] = {
            [QuestieDB.questKeys.parentQuest] = 1654,
        },
        [677] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, --#1162
        },
        [926] = {
            [QuestieDB.questKeys.parentQuest] = 924, -- #806
            [QuestieDB.questKeys.preQuestSingle] = {809}, --#606
        },
        [930] = {
            [QuestieDB.questKeys.preQuestSingle] = {918,919}, -- #971
        },
        [1131] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1065
        },
        [1302] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #889
        },
        [1598] = {
            [QuestieDB.questKeys.exclusiveTo] = {1599}, -- #999
        },
        [1599] = {
            [QuestieDB.questKeys.exclusiveTo] = {1598}, -- #999
        },
        [1559] = {
            [QuestieDB.questKeys.preQuestSingle] = {705}, -- #1164
        },
        [1470] = {
            [QuestieDB.questKeys.exclusiveTo] = {1485}, -- #999
        },
        [1485] = {
            [QuestieDB.questKeys.exclusiveTo] = {1470}, -- #999
        },
        [1708] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1230
        },
        [1710] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #1231
        },
        -- Profession quests
        [90] = {
            [QuestieDB.questKeys.requiredSkill] = {185, 50}
        },
        [769] = {
            [QuestieDB.questKeys.requiredSkill] = {165,10},
        },
        [862] = {
            [QuestieDB.questKeys.requiredSkill] = {185,76}, -- You need to be a Journeyman for this quest
        },
        [3385] = {
            [QuestieDB.questKeys.requiredSkill] = {197,226}, -- You need to be an Artisan for this quest
        },
        --------------------
        -- questRequirementFixes
        [46] = {
            [QuestieDB.questKeys.preQuestSingle] = {39},
        },
        [3903] = {
            [QuestieDB.questKeys.preQuestSingle] = {18},
        },
        [374] = {
            [QuestieDB.questKeys.preQuestSingle] = {427}, -- proof of demise requires at war with the scarlet crusade
        },
        [1106] = {
            [QuestieDB.questKeys.preQuestGroup] = {1104, 1105},
        },
        [431] = { -- candles of beckoning
            [QuestieDB.questKeys.preQuestSingle] = {366}, -- #638
            [QuestieDB.questKeys.exclusiveTo] = {411}, -- #752
        },
        [410] = { -- the dormant shade
            [QuestieDB.questKeys.preQuestSingle] = {366}, -- #638
            [QuestieDB.questKeys.exclusiveTo] = {411}, -- #752
        },
        [364] = {
            [QuestieDB.questKeys.preQuestSingle] = {}, -- #882
        },
        [473] = {
            [QuestieDB.questKeys.preQuestSingle] = {455}, -- #809
        },
        --------------------
        -- questExclusiveGroupFixes
        [463] = {
            [QuestieDB.questKeys.exclusiveTo] = {276}, --greenwarden cant be completed if you have trampling paws
        },
        [415] = {
            [QuestieDB.questKeys.exclusiveTo] = {413}, -- cant complete rejolds new brew if you do shimmer stout (see issue 567)
        },
        [1339] = {
            [QuestieDB.questKeys.exclusiveTo] = {1338}, -- mountaineer stormpike's task cant be done if you have finished stormpike's order
        },
        [1943] = {
            [QuestieDB.questKeys.exclusiveTo] = {1944}, -- mage robe breadcrumb
        },
        [526] = {
            [QuestieDB.questKeys.exclusiveTo] = {322,324}, -- not 100% sure on this one but it seems lightforge ingots is optional, block it after completing subsequent steps (#587)
        },
        [3765] = {
            [QuestieDB.questKeys.exclusiveTo] = {1275}, -- corruption abroad breadcrumb
        },
        [164] = {
            [QuestieDB.questKeys.exclusiveTo] = {95}, -- deliveries to sven is a breadcrumb
        },
        [428] = {
            [QuestieDB.questKeys.exclusiveTo] = {429}, -- lost deathstalkers breadcrumb
        },
        [308] = {
            [QuestieDB.questKeys.exclusiveTo] = {311}, -- distracting jarven can't be completed once you get the followup
        },
    
        -- Tome of Divinity starting quests for dwarfs #703
        [1645] = { -- This is repeatable giving an item starting 1646
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000,3681},
        },
        [1646] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,2997,2998,2999,3000,3681},
        },
        [2997] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2998,2999,3000,3681},
        },
        [2999] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,3000,3681},
        },
        [3000] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3681},
        },
    
        -- Tome of Divinity starting quests for humans #703
        [1641] = { -- This is repeatable giving an item starting 1642
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000,3681},
        },
        [1642] = {
            [QuestieDB.questKeys.exclusiveTo] = {1646,2997,2998,2999,3000,3681},
        },
        [2998] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,3000,3681},
        },
        [3681] = {
            [QuestieDB.questKeys.exclusiveTo] = {1642,1646,2997,2998,2999,3000},
        },
    
        -- Tome of Valor repeatable starting quests #742
        [1793] = {
            [QuestieDB.questKeys.exclusiveTo] = {1649},
        },
        [1794] = {
            [QuestieDB.questKeys.exclusiveTo] = {1649},
        },
    
        -- Tome of Nobility quests #1661
        [1661] = {
            [QuestieDB.questKeys.exclusiveTo] = {4485,4486},
        },
        [4485] = {
            [QuestieDB.questKeys.exclusiveTo] = {1661,4486},
        },
        [4486] = {
            [QuestieDB.questKeys.exclusiveTo] = {1661,4485},
        },
    
        -- Voidwalker questline for horde
        [1473] = {
            [QuestieDB.questKeys.exclusiveTo] = {1501},
        },
        [1501] = {
            [QuestieDB.questKeys.exclusiveTo] = {1473},
        },
    
        [163] = {
            [QuestieDB.questKeys.exclusiveTo] = {5}, -- Raven Hill breadcrumb
        },
        [1301] = {
            [QuestieDB.questKeys.exclusiveTo] = {1302}, -- breadcrumb of James Hyal #917
        },
        [578] = {
            [QuestieDB.questKeys.childQuests] = {579},
        },
        [579] = {
            [QuestieDB.questKeys.parentQuest] = 578,
        },
        [1085] = {
            [QuestieDB.questKeys.preQuestSingle] = {1070},
        },
        [2994] = {
            [QuestieDB.questKeys.questLevel] = 51, -- #1129
        },
        [3791] = {
            [QuestieDB.questKeys.preQuestSingle] = {3788}, -- #885
        },
        [861] = {
            [QuestieDB.questKeys.exclusiveTo] = {860,844}, -- #1109
        },
        [5122] = {
            [QuestieDB.questKeys.specialFlags] = 1, -- #1140
        },
        [2861] = {
            [QuestieDB.questKeys.startedBy] = {{4568,5144,5497,5885,},nil,nil,}, -- #1152
        },
        [5421] = {
            [QuestieDB.questKeys.questLevel] = 25,
        },
        -- fix two "The Hunter's Path" quests being started by "Sian'dur" in Orgrimmar
        -- this one is now started by "Kary Thunderhorn" in Thunder Bluff
        [6070] = {
            [QuestieDB.questKeys.startedBy] = {{3038,},nil,nil,},
        },
        -- Salve via Hunting/Mining/Gathering/Skinning/Disenchanting quests
        -- Alliance repeatable
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
        -- Horde repeatable
        [4108] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4109] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4110] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4111] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        [4112] = {
            [QuestieDB.questKeys.startedBy] = {{9529,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 178,
            [QuestieDB.questKeys.preQuestSingle] = {5887,5888,5889,5890,5891,},
        },
        -- Alliance non repeatable
        [5882] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.exclusiveTo] = {5883,5884,5885,5886,},
        },
        [5883] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.exclusiveTo] = {5882,5884,5885,5886,},
        },
        [5884] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.exclusiveTo] = {5882,5883,5885,5886,},
        },
        [5885] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.exclusiveTo] = {5882,5883,5884,5886,},
        },
        [5886] = {
            [QuestieDB.questKeys.startedBy] = {{9528,},nil,nil,},
            [QuestieDB.questKeys.requiredRaces] = 77,
            [QuestieDB.questKeys.exclusiveTo] = {5882,5883,5884,5885,},
        },
        -- Horde non repeatable
        [5887] = {
            [QuestieDB.questKeys.exclusiveTo] = {5888,5889,5890,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5888] = {
            [QuestieDB.questKeys.exclusiveTo] = {5887,5889,5890,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5889] = {
            [QuestieDB.questKeys.exclusiveTo] = {5887,5888,5890,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5890] = {
            [QuestieDB.questKeys.exclusiveTo] = {5887,5888,5889,5891,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
        [5891] = {
            [QuestieDB.questKeys.exclusiveTo] = {5887,5888,5889,5890,},
            [QuestieDB.questKeys.specialFlags] = 0,
        },
    }
end