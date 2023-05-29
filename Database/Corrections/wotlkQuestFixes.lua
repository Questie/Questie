---@class QuestieWotlkQuestFixes
local QuestieWotlkQuestFixes = QuestieLoader:CreateModule("QuestieWotlkQuestFixes")

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


QuestieCorrections.killCreditObjectiveFirst[12100] = true
QuestieCorrections.killCreditObjectiveFirst[12546] = true
QuestieCorrections.killCreditObjectiveFirst[12561] = true
QuestieCorrections.killCreditObjectiveFirst[12762] = true
QuestieCorrections.killCreditObjectiveFirst[12919] = true
QuestieCorrections.killCreditObjectiveFirst[13086] = true
QuestieCorrections.killCreditObjectiveFirst[13373] = true
QuestieCorrections.killCreditObjectiveFirst[13380] = true

function QuestieWotlkQuestFixes:Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local zoneIDs = ZoneDB.zoneIDs
    local sortKeys = QuestieDB.sortKeys
    local profKeys = QuestieProfessions.professionKeys
    local specKeys = QuestieProfessions.specializationKeys

    return {
        [171] = {
            [questKeys.startedBy] = {{14305},nil,nil},
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [172] = {
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [236] = {
            [questKeys.startedBy] = {{31108}},
            [questKeys.finishedBy] = {{31108}},
            [questKeys.exclusiveTo] = {13154,13156,},
        },
        [403] = {
            [questKeys.startedBy] = {nil,{269}},
        },
        [508] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [558] = {
            [questKeys.questLevel] = -1,
            [questKeys.parentQuest] = 0,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [648] = {
            [questKeys.triggerEnd] = {"Escort OOX-17/TN to safety", {[zoneIDs.TANARIS]={{61,53}}}},
        },
        [768] = {
            [questKeys.requiredSkill] = {393,1},
        },
        [836] = {
            [questKeys.triggerEnd] = {"Escort OOX-09/HL to safety", {[zoneIDs.THE_HINTERLANDS]={{49.8,43.8}}}},
        },
        [910] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [911] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [915] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.parentQuest] = 0,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [925] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.parentQuest] = 0,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1056] = {
            [questKeys.nextQuestInChain] = 1057,
        },
        [1132] = {
            [questKeys.startedBy] = {{4455}},
            [questKeys.finishedBy] = {{4456}},
        },
        [1135] = {
            [questKeys.startedBy] = {{4456}},
            [questKeys.finishedBy] = {{4456}},
        },
        [1198] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1252] = {
            [questKeys.preQuestSingle] = {11123},
        },
        [1253] = {
            [questKeys.preQuestSingle] = {11123},
        },
        [1284] = {
            [questKeys.preQuestSingle] = {11123},
        },
        [1468] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1479] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1558] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1687] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1800] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [2767] = {
            [questKeys.triggerEnd] = {"Escort OOX-22/FE to safety", {[zoneIDs.FERALAS]={{54.3,51.2}}}},
        },
        [4362] = {
            [questKeys.preQuestSingle] = {4361},
        },
        [4740] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4763] = {
            [questKeys.objectives] = {nil,nil,{{12355}}},
        },
        [4822] = {
            [questKeys.questLevel] = -1,
            [questKeys.parentQuest] = 0,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [5502] = {
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.preQuestGroup] = {915,925},
        },
        [6961] = {
            [questKeys.exclusiveTo] = {6962},
        },
        [7022] = {
            [questKeys.exclusiveTo] = {7025},
        },
        [7023] = {
            [questKeys.exclusiveTo] = {7025},
        },
        [7024] = {
            [questKeys.exclusiveTo] = {6962},
        },
        [7800] = {
            [questKeys.preQuestSingle] = {},
        },
        [8150] = {
            [questKeys.requiredSourceItems] = {}, -- Overriding Classic correction
            [questKeys.triggerEnd] = {"Place a tribute at Grom's Monument",{[zoneIDs.ASHENVALE]={{83,78,},},},},
        },
        [8346] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{15274},15274,"Mana Tap creature"}}},
        },
        [8551] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8552] = {
            [questKeys.specialFlags] = 0,
        },
        [8746] = {
            [questKeys.objectives] = {{{15664,"Find Metzen the Reindeer and rescue him"}},nil,{{21211}}},
        },
        [8762] = {
            [questKeys.objectives] = {{{15664,"Find Metzen the Reindeer and rescue him"}},nil,{{21211}}},
        },
        [8892] = {
            [questKeys.preQuestSingle] = {},
        },
        [9078] = {
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [9154] = {
            [questKeys.startedBy] = {{16241,16255}},
            [questKeys.finishedBy] = {{16281}},
            [questKeys.questLevel] = -1,
        },
        [9189] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9211] = {
            [questKeys.specialFlags] = 1,
        },
        [9213] = {
            [questKeys.specialFlags] = 1,
        },
        [9221] = {
            [questKeys.specialFlags] = 1,
        },
        [9222] = {
            [questKeys.specialFlags] = 1,
        },
        [9223] = {
            [questKeys.specialFlags] = 1,
        },
        [9224] = {
            [questKeys.specialFlags] = 1,
        },
        [9225] = {
            [questKeys.specialFlags] = 1,
        },
        [9226] = {
            [questKeys.specialFlags] = 1,
        },
        [9227] = {
            [questKeys.specialFlags] = 1,
        },
        [9228] = {
            [questKeys.specialFlags] = 1,
        },
        [9247] = {
            [questKeys.finishedBy] = {{16281}},
        },
        [9358] = {
            [questKeys.exclusiveTo] = {9252},
        },
        [9361] = {
            [questKeys.requiredSourceItems] = {23270},
        },
        [9425] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9467] = {
            [questKeys.sourceItemId] = 24335,
            [questKeys.requiredSourceItems] = {23682,24335},
        },
        [9629] = {
            [questKeys.objectives] = {{{17326}}},
        },
        [9648] = {
            [questKeys.name] = "Maatparm Mushroom Menagerie",
            [questKeys.objectivesText] = {"Maatparm at Blood Watch wants 1 Aquatic Stinkhorn, 1 Blood Mushroom, 1 Ruinous Polyspore, and 1 Fel Cone Fungus."},
        },
        [9681] = {
            [questKeys.startedBy] = {{17717,17718}},
		},
        [9876] = {
            [questKeys.nextQuestInChain] = 9738,
        },
        [10110] = {
            [questKeys.preQuestSingle] = {13409},
        },
        [10173] = {
            [questKeys.requiredSourceItems] = {},
        },
        [10180] = {
            [questKeys.nextQuestInChain] = 10097,
        },
        [10445] = {
            [questKeys.exclusiveTo] = {13432},
        },
        [10667] = {
            [questKeys.preQuestSingle] = {},
        },
        [10670] = {
            [questKeys.preQuestSingle] = {},
        },
        [10702] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{21864,21878,21879,23020,21978},21978,},},},
        },
        [10703] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{21864,21878,21879,23020,21978},21978,},},},
        },
        [10769] = {
            [questKeys.objectives] = {{{19823}},nil,{{31108}}},
        },
        [10776] = {
            [questKeys.objectives] = {{{19823}},nil,{{31310}}},
        },
        [11120] = {
            [questKeys.startedBy] = {{24657}},
            [questKeys.finishedBy] = {{24657}},
        },
        [11140] = {
            [questKeys.requiredSourceItems] = {33040,33044},
        },
        [11153] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{28.1,42.2}}}, Questie.ICON_TYPE_EVENT, l10n("Wait for Harrowmeiser's zeppelin to dock"),}},
        },
        [11154] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Throw the firecrackers up to 20 yards away underneath a darkclaw bat to scare it"), 0, {{"monster", 23959}}}},
        },
        [11157] = {
            [questKeys.objectives] = {{{23777,"Proto-Drake Egg destroyed"}},nil,nil,nil,{{{23688,23750},23688}}},
        },
        [11170] = {
            [questKeys.objectives] = {{{24120,"North Fleet Reservist Infected"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Bat Handler Camille"), 0, {{"monster", 23816}}}},
        },
        [11175] = {
            [questKeys.exclusiveTo] = {11176},
        },
        [11241] = {
            [questKeys.triggerEnd] = {"Rescue Apothecary Hanes",{[zoneIDs.HOWLING_FJORD]={{78.72,37.23,},},},},
        },
        [11246] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23661,23662,23663,23664,23665,23666,23667,23668,23669,23670},23661,"Winterskorn Vrykul Dismembered"}}},
        },
        [11249] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Present the Vrykul Scroll of Ascension"), 0, {{"object", 186586}}}},
        },
        [11252] = {
            [questKeys.preQuestSingle] = {},
        },
        [11257] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23661,23662,23663,23664,23665,23666,23667,23668,23669,23670},23661,"Winterskorn Vrykul Dismembered"}}},
        },
        [11279] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Spray Proto-Drake Egg"), 0, {{"monster", 23777}}}},
        },
        [11280] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Place Tillinghast's Plagued Meat on the ground"), 0, {{"monster", 24170}}}},
        },
        [11281] = {
            [questKeys.objectives] = {{{24173}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Frostgore"), 0, {{"monster", 24173}}}},
        },
        [11282] = {
            [questKeys.objectives] = {{{24161,"Oric the Baleful's Corpse Impaled"},{24016,"Ulf the Bloodletter's Corpse Impaled"},{24162,"Gunnar Thorvardsson's Corpse Impaled"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Vrykul across the Forsaken blockade until they appear"), 0, {{"monster", 24015}}}},
        },
        [11286] = {
            [questKeys.preQuestSingle] = {},
        },
        [11296] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Break Riven Widow Cocoons to free captives"), 0, {{"monster", 24210}}}},
        },
        [11297] = {
            [questKeys.nextQuestInChain] = 11298,
        },
        [11298] = {
            [questKeys.preQuestSingle] = {},
        },
        [11300] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill gladiators at the Ring of Judgement until Oluf the Violent appears"), 0, {{"monster", 24213},{"monster", 24214},{"monster", 24215}}}},
        },
        [11301] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Use Grick's Bonesaw on corpses of Deranged Explorers"), 0, {{"monster", 23967}}}},
        },
        [11302] = {
            [questKeys.preQuestSingle] = {11269,11329},
        },
        [11306] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Fill the Empty Apothecary's Flask at the Cauldron of Vrykul Blood"),0,{{"object", 186656}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Mix the Flask of Vrykul Blood with Harris's Plague Samples"),1,{{"object", 186657}}},
            },
        },
        [11307] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23564,24198,24199},23564,"Plagued Vrykul Sprayed"}}},
        },
        [11310] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23564,24198,24199},23564,"Plagued Vrykul exterminated"}}},
        },
        [11314] = {
            [questKeys.objectives] = {{{23678,"Chill Nymphs Freed"}}},
        },
        [11319] = {
            [questKeys.objectives] = {{{23876,"Spores frozen"}}},
        },
        [11332] = {
            [questKeys.preQuestSingle] = {11331},
        },
        [11343] = {
            [questKeys.triggerEnd] = {"Secrets of Wyrmskull Uncovered",{[zoneIDs.HOWLING_FJORD]={{60.13,50.8,},},},},
        },
        [11344] = {
            [questKeys.triggerEnd] = {"Secrets of Nifflevar Uncovered",{[zoneIDs.HOWLING_FJORD]={{69.04,54.79,},},},},
        },
        [11346] = {
            [questKeys.preQuestSingle] = {11269,11329},
        },
        [11348] = {
            [questKeys.objectives] = {{{23725,"Test Rune of Command on normal Stone Giants"},{24334}}},
        },
        [11352] = {
            [questKeys.objectives] = {{{23725,"Test Rune of Command on normal Stone Giants"},{24334}}},
        },
        [11355] = {
            [questKeys.preQuestSingle] = {11269,11329},
            [questKeys.objectives] = {{{24329,"Runed Stone Giant Corpse Analyzed"},},nil,nil,nil,},
        },
        [11358] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Rune Sample"), 0, {{"object", 186718},}}},
        },
        [11365] = {
            [questKeys.objectives] = {{{24329,"Runed Stone Giant Corpse Analyzed"},},nil,nil,nil,},
        },
        [11366] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Rune Sample"), 0, {{"object", 186718},}}},
        },
        [11392] = {
            [questKeys.startedBy] = {nil,{186267}},
            [questKeys.finishedBy] = {nil,{186314}},
        },
        [11393] = {
            [questKeys.exclusiveTo] = {11394,},
        },
        [11394] = {
            [questKeys.preQuestSingle] = {},
        },
        [11401] = {
            [questKeys.startedBy] = {nil,{186267}},
            [questKeys.finishedBy] = {nil,{186314}},
        },
        [11410] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Fresh Barbfish Bait"), 0, {{"object", 186770},}}},
        },
        [11416] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Touch Talonshrike's Egg"), 0, {{"object", 186814},{"object", 190283},{"object", 190284}}}},
        },
        [11417] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Touch Talonshrike's Egg"), 0, {{"object", 186814},{"object", 190283},{"object", 190284}}}},
        },
        [11418] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Feathered Charm on Steelfeather"), 0, {{"monster", 24514},}}},
        },
        [11420] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{56.6,49.1}}}, Questie.ICON_TYPE_EVENT, l10n("Entrance to Utgarde Catacombs"),}},
        },
        [11421] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Commandeer Crykul Harpoon Gun"),0,{{"object",190512}}}},
        },
        [11428] = {
            [questKeys.preQuestSingle] = {11316},
        },
        [11429] = {
            [questKeys.triggerEnd] = {"Alliance Banner Defended",{[zoneIDs.HOWLING_FJORD]={{64.89,40.03,},},},},
        },
        [11431] = {
            [questKeys.startedBy] = {{24657}},
            [questKeys.finishedBy] = {{24657}},
        },
        [11436] = {
            [questKeys.triggerEnd] = {"Go Harpoon Surfing",{[zoneIDs.HOWLING_FJORD]={{60.08,62.06,},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Go Harpoon Surfing"),0,{{"object",186894}}}},
        },
        [11452] = {
            [questKeys.startedBy] = {{24018},nil,{34090}},
        },
        [11453] = {
            [questKeys.startedBy] = {{24018},nil,{34091}},
        },
        [11460] = {
            [questKeys.triggerEnd] = {"Fjord Rock Falcon Fed",{[zoneIDs.HOWLING_FJORD]={{75.26,64.91,},},},},
        },
        [11466] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Olga"), 0, {{"monster", 24639}}}},
        },
        [11471] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Fight Jonah"), 0, {{"monster", 24742}}}},
        },
        [11472] = {
            [questKeys.triggerEnd] = {"Reef Bull led to a Reef Cow",{[zoneIDs.HOWLING_FJORD]={{31.16,71.63,},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Lure Reef Bull with Tasty Reef Fish"), 0, {{"monster", 24786}}}},
            [questKeys.reputationReward] = {{1073,500}},
        },
        [11478] = {
            [questKeys.exclusiveTo] = {11448},
        },
        [11485] = {
            [questKeys.triggerEnd] = {"Rocket Jump Mastered",{[zoneIDs.HOWLING_FJORD]={{75.08,64.55,},},},},
        },
        [11491] = {
            [questKeys.triggerEnd] = {"Lebronski Bluffed",{[zoneIDs.HOWLING_FJORD]={{74.8,65.28,},},},},
        },
        [11495] = {
            [questKeys.triggerEnd] = {"Thundering Cave investigated",{[zoneIDs.HOWLING_FJORD]={{71.5,69.75,},},},},
        },
        [11529] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{37.2,74.8}}}, Questie.ICON_TYPE_OBJECT, l10n("Use The Big Gun at the front of the ship to slay Sorlof"),0,{{"monster", 24992}}}},
        },
        [11531] = {
            [questKeys.specialFlags] = 1,
        },
        [11567] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Ask Alanya for transportation"),0,{{"monster", 27933}}}},
        },
        [11569] = {
            [questKeys.preQuestSingle] = {11571},
        },
        [11570] = {
            [questKeys.triggerEnd] = {"Escort Lurgglbr to safety",{[zoneIDs.BOREAN_TUNDRA]={{41.35,16.29,},},},},
        },
        [11574] = {
            [questKeys.preQuestSingle] = {11595,11596,11597},
            [questKeys.exclusiveTo] = {11587},
        },
        [11575] = {
            [questKeys.exclusiveTo] = {11587},
        },
        [11586] = {
            [questKeys.preQuestSingle] = {},
        },
        [11587] = {
            [questKeys.preQuestSingle] = {},
        },
        [11590] = {
            [questKeys.objectives] = {{{25316,"Captured Beryl Sorcerer"},},nil,nil,nil,},
        },
        [11591] = {
            [questKeys.exclusiveTo] = {11592,11593,11594,},
        },
        [11592] = {
            [questKeys.triggerEnd] = {"Successfully assisted Longrunner Proudhoof's assault.",{[zoneIDs.BOREAN_TUNDRA]={{49.45,26.49,},},},},
        },
        [11594] = {
            [questKeys.preQuestSingle] = {},
        },
        [11596] = {
            [questKeys.preQuestSingle] = {11586},
        },
        [11606] = {
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [11611] = {
            [questKeys.objectives] = {{{25284,"Warsong Peon Freed"}}},
        },
        [11631] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Imperean's Primal on Snarlfang's Totem"),0,{{"monster", 25455}}}},
        },
        [11632] = {
            [questKeys.startedBy] = {nil,{187674},{34777}},
        },
        [11652] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25332,25333,25469,},25333,"Scourge Unit obliterated"},{{27106,27107,27108,27110},27106,"Injured Warsong Soldier rescued"}}},
            [questKeys.triggerEnd] = {"Scourge Leader identified",{[zoneIDs.BOREAN_TUNDRA]={{36.41,63.52,},},},},
        },
        [11653] = {
            [questKeys.objectives] = {{{25432,"Crafty's Blaster Tested"},{25434,"Crafty's Blaster Tested"},},nil,nil,nil,},
        },
        [11654] = {
            [questKeys.startedBy] = {{26115},nil,{34815}},
        },
        [11664] = {
            [questKeys.triggerEnd] = {"Mootoo Saved",{[zoneIDs.BOREAN_TUNDRA]={{31.19,54.44,},},},},
        },
        [11670] = {
            [questKeys.objectives] = {{{25430,"Warsong Banner Planted in Magmothregar"},},nil,{{34870,nil},},nil,},
        },
        [11671] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Kill Inquisitor Salrand"), 0, {{"monster", 25584}}},
                {{[zoneIDs.BOREAN_TUNDRA]={{41.8,39.1}}}, Questie.ICON_TYPE_EVENT, l10n("Use Beryl Shield Detonator"),},
            },
        },
        [11673] = {
            [questKeys.triggerEnd] = {"Bonker Togglevolt escorted to safety.",{[zoneIDs.BOREAN_TUNDRA]={{53.84,13.85,},},},},
        },
        [11688] = {
            [questKeys.preQuestSingle] = {},
        },
        [11704] = {
            [questKeys.preQuestSingle] = {11708},
        },
        [11705] = {
            [questKeys.triggerEnd] = {"Varidus the Flenser Defeated",{[zoneIDs.BOREAN_TUNDRA]={{35.13,46.32,},},},},
        },
        [11706] = {
            [questKeys.objectives] = {{{25768},{25768,"Nerubian tunnels collapsed"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use The Horn of Elemental Fury near the southern sinkhole"),0,{{"monster", 25664}}}},
        },
        [11708] = {
            [questKeys.triggerEnd] = {"Fizzcrank's tale listened to.",{[zoneIDs.BOREAN_TUNDRA]={{57.01,18.69,},},},},
        },
        [11711] = {
            [questKeys.triggerEnd] = {"Alliance Deserter Delivered",{[zoneIDs.BOREAN_TUNDRA]={{55.28,50.86,},},},},
        },
        [11712] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25765,25767,25783,25814,26601,26619},25814,"Fizzcrank Gnome cursed & ported"}}},
        },
        [11719] = {
            [questKeys.triggerEnd] = {"Bloodspore Flower Used",{[zoneIDs.BOREAN_TUNDRA]={{52.07,52.46,},},},},
        },
        [11728] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Throw Wolf Bait"),0,{{"monster", 25791}}}},
        },
        [11730] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25753,25758,25752},25753,"Robots reprogrammed"}}},
        },
        [11788] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),0,{{"object", 187984}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),1,{{"object", 187985}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),2,{{"object", 187986}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),3,{{"object", 187987}}},
            },
        },
        [11798] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use The Gearmaster's Manual"),0,{{"object", 190334}}}},
        },
        [11865] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place fake fur near Caribou Traps"),0,{{"object", 187995},{"object", 187996},{"object", 187997},{"object", 187998},{"object", 187999},{"object", 188000},{"object", 188001},{"object", 188002},{"object", 188003},{"object", 188004},{"object", 188005},{"object", 188006},{"object", 188007},{"object", 188008}}},
            },
        },
        [11878] = {
            [questKeys.triggerEnd] = {"Orphaned Mammoth Calf Delivered to Khu'nok",{[zoneIDs.BOREAN_TUNDRA]={{59.35,30.55,},},},},
        },
        [11879] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Mount Wooly Mammoth Bull to assist in killing Kaw the Mammoth Destroyer"),0,{{"monster", 25743}}}},
        },
        [11880] = {
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11881] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Jenny's Whistle near a crashed flying machine"),0,{{"monster", 25845},{"monster", 25846},{"monster", 25847}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Return Jenny to safety without losing cargo"),0,{{"monster", 25849},}},
            },
        },
        [11887] = {
            [questKeys.objectives] = {nil,nil,{{35276}}},
        },
        [11888] = {
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [11890] = {
            [questKeys.triggerEnd] = {"Fizzcrank Pumping Station environs inspected.",{[zoneIDs.BOREAN_TUNDRA]={{65.17,25.2,},},},},
        },
        [11893] = {
            [questKeys.objectives] = {{{24601}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Windsoul Totem to collect energy from killing Steam Ragers"),0,{{"monster", 24601}}}},
        },
        [11894] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Uncured Caribou Hide"),0,{{"object", 188086}}}},
        },
        [11895] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Storm Totem to summon Storm Tempest"),0,{{"monster", 26048}}}},
        },
        [11896] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25752,25753,25758},26082,}}},
        },
        [11898] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.BOREAN_TUNDRA]={{86.55,28.59}}}, Questie.ICON_TYPE_EVENT, l10n("Enter teleporter to access Naxxanar"),},
                {{[zoneIDs.BOREAN_TUNDRA]={{86.80,30.12}}}, Questie.ICON_TYPE_EVENT, l10n("Use Naxxanar teleporters"),},
            },
        },
        [11899] = {
            [questKeys.objectives] = {{{25814,"Gnome soul captured"},},nil,nil,nil,},
            [questKeys.preQuestSingle] = {11895},
        },
        [11905] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_NEXUS]={{64.9,21.6}}}, Questie.ICON_TYPE_EVENT, l10n("Use Interdimensional Refabricator")}},
        },
        [11906] = {
            [questKeys.preQuestSingle] = {11895},
        },
        [11907] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),0,{{"object", 187984}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),1,{{"object", 187985}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),2,{{"object", 187986}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),3,{{"object", 187987}}},
            },
        },
        [11908] = {
            [questKeys.preQuestSingle] = {11902},
        },
        [11909] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Research the Gearmaster's Manual"),0,{{"object", 190334},{"object", 190335}}}},
        },
        [11919] = {
            [questKeys.objectives] = {{{26127,"Captured Nexus Drake"},},nil,nil,nil,},
        },
        [11930] = {
            [questKeys.triggerEnd] = {"Secure Passage to Dragonblight",{[zoneIDs.DRAGONBLIGHT]={{10.29,53.83,},},},},
        },
        [11938] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25378,25383,25386,25387,25393,25609},25378,"En'kilah Casualty"}}},
        },
        [11940] = {
            [questKeys.objectives] = {{{26127,"Captured Nexus Drake"},},nil,nil,nil,},
        },
        [11945] = {
            [questKeys.reputationReward] = {{1073,500}},
        },
        [11956] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Ride Dusk"),0,{{"monster", 26191}}}},
        },
        [11957] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Keristrasza"),0,{{"monster", 26206}}},
                {{[zoneIDs.BOREAN_TUNDRA]={{22,22.6}}}, Questie.ICON_TYPE_EVENT, l10n("Use Arcane Power Focus"),},
            },
        },
        [11960] = {
            [questKeys.reputationReward] = {{1073,500}},
        },
        [11969] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Raelorasz' Spark"),0,{{"object", 194151}}}},
        },
        [11982] = {
            [questKeys.objectives] = {{{26270,"Iron Dwarf Operations Disrupted"}}},
            [questKeys.preQuestSingle] = {},
        },
        [11984] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Enlist Budd's help"), 0, {{"monster", 26422}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Escort Budd to the Drak' Zin Ruins"), 0, {{"monster", 32663}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Budd's Tag Troll spell to stun Drakkari trolls"), 0, {{"monster", 26425}, {"monster", 26447}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Capture stunned Drakkari trolls with Bounty Hunter's Cage"), 0, {{"monster", 26425}, {"monster", 26447}}},
            },
        },
        [11989] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Dull Carving Knife near Drakuru"),0,{{"monster", 26423}}},
            },
        },
        [12007] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Drink Drakuru's Elixir after gathering Zim'bo's Mojo"),0,{{"object", 400047}}}},
        },
        [12017] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Tu'u'gwar's Bait"),0,{{"object", 188370}}}},
        },
        [12019] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.BOREAN_TUNDRA]={{86.6,28.6}}}, Questie.ICON_TYPE_EVENT, l10n("Teleport to the top of Naxxanar"),},
                {{[zoneIDs.BOREAN_TUNDRA]={{86.6,31.4}}}, Questie.ICON_TYPE_TALK, l10n("Talk to Thassarian"),},
            },
        },
        [12027] = {
            [questKeys.triggerEnd] = {"Help Emily and Mr. Floppy return to the camp",{[zoneIDs.GRIZZLY_HILLS]={{53.81,33.33,},},},},
        },
        [12028] = {
            [questKeys.objectives] = {nil,{{188416}}},
        },
        [12029] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26458,26570,26582,26583},26612,}}},
        },
        [12032] = {
            [questKeys.triggerEnd] = {"Oacha'noa's compulsion obeyed.",{[zoneIDs.DRAGONBLIGHT]={{34.09,84.01,},},},},
        },
        [12033] = {
            [questKeys.preQuestSingle] = {11916},
            [questKeys.objectives] = {nil,{{188423,}},nil,nil,},
        },
        [12034] = {
            [questKeys.preQuestSingle] = {12008},
        },
        [12035] = {
            [questKeys.objectives] = {{{25623,"Harvest Collector Rewired"},},nil,nil,nil,},
        },
        [12036] = {
            [questKeys.triggerEnd] = {"Pit of Narjun Explored",{[zoneIDs.DRAGONBLIGHT]={{26.26,50.01,},},},},
        },
        [12038] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26458,26570,26582,26583},26612,}}},
        },
        [12039] = {
            [questKeys.preQuestSingle] = {12034},
        },
        [12050] = {
            [questKeys.preQuestGroup] = {12046,12047},
        },
        [12052] = {
            [questKeys.preQuestGroup] = {12046,12047},
        },
        [12053] = {
            [questKeys.triggerEnd] = {"Warsong Battle Standard Defended",{[zoneIDs.DRAGONBLIGHT]={{25.09,41.97,},},},},
        },
        [12055] = {
            [questKeys.startedBy] = {{26349},nil,{36742}},
            [questKeys.preQuestSingle] = {12000},
        },
        [12056] = {
            [questKeys.preQuestSingle] = {12034},
        },
        [12059] = {
            [questKeys.startedBy] = {{26349},nil,{36746}},
            [questKeys.preQuestSingle] = {11999},
        },
        [12063] = {
            [questKeys.preQuestSingle] = {12036},
        },
        [12065] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188445}}},
            },
        },
        [12066] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188445}}},
            },
        },
        [12067] = {
            [questKeys.startedBy] = {{26762},nil,{36756}},
        },
        [12069] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Free Roanauk Icemist"),0,{{"object", 188463}}}},
        },
        [12075] = {
            [questKeys.preQuestSingle] = {},
        },
        [12076] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Zort's Scraper when covered in Corrosive Spit"),0,{{"monster", 26358},{"monster", 26359}}}},
        },
        [12078] = {
            [questKeys.preQuestSingle] = {12077},
        },
        [12079] = {
            [questKeys.preQuestSingle] = {12075},
        },
        [12080] = {
            [questKeys.preQuestSingle] = {12076},
        },
        [12082] = {
            [questKeys.triggerEnd] = {"Harrison has escorted you to safety.",{[zoneIDs.GRIZZLY_HILLS]={{73.51,24.02,},},},},
        },
        [12083] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188474}}},
            },
        },
        [12084] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188474}}},
            },
        },
        [12085] = {
            [questKeys.startedBy] = {{26815},nil,{36780}},
        },
        [12092] = {
            [questKeys.preQuestSingle] = {12065},
        },
        [12095] = {
            [questKeys.preQuestGroup] = {12089,12090,12091},
        },
        [12096] = {
            [questKeys.preQuestSingle] = {12066},
        },
        [12097] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Rokhan to call down Sarathstra"), 0, {{"monster", 26859}}},},
        },
        [12099] = {
            [questKeys.objectives] = {{{26417,"Runed Giants Freed"}}},
        },
        [12100] = {
            [questKeys.preQuestSingle] = {12034},
        },
        [12105] = {
            [questKeys.startedBy] = {{27547},nil,{36940}},
        },
        [12107] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Ley Line Focus Control Talisman"),0,{{"object", 188491}}},
            },
        },
        [12110] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Ley Line Focus Control Talisman"),0,{{"object", 188491}}},
            },
        },
        [12111] = {
            [questKeys.objectives] = {{{26615,},{26482,}}},
        },
        [12112] = {
            [questKeys.preQuestGroup] = {12050,12052},
        },
        [12117] = {
            [questKeys.nextQuestInChain] = 11958,
        },
        [12118] = {
            [questKeys.nextQuestInChain] = 11958,
        },
        [12121] = {
            [questKeys.objectives] = {{{27199,}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ring the gong outside Drakil'jin to summon Warlord Jin'arrak"),0,{{"object", 188510}}},
            },
        },
        [12125] = {
            [questKeys.objectives] = {{{26411}},nil,{{36828}}},
        },
        [12126] = {
            [questKeys.objectives] = {{{26926}},nil,{{36836}}},
        },
        [12127] = {
            [questKeys.objectives] = {{{26283}},nil,{{36846}}},
        },
        [12132] = {
            [questKeys.preQuestGroup] = {12125,12126,12127},
        },
        [12135] = {
            [questKeys.triggerEnd] = {"Put Out the Fires",{
                [zoneIDs.AZUREMYST_ISLE]={{49.3,51.5,},},
                [zoneIDs.DUN_MOROGH]={{53.2,51.4,},},
                [zoneIDs.ELWYNN_FOREST]={{43.2,67,},},
            },},
        },
        [12137] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak with Gan'jo to return to life"),0,{{"monster", 26924}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Snow of Eternal Slumber on ancient Drakkari spirits"),0,{{"monster", 26811},{"monster", 26812}}},
            },
        },
        [12138] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26407,27017},26407,}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Fight Lightning Sentries with Depleted War Golem deployed nearby"),0,{{"monster", 26407}}},
            },
        },
        [12139] = {
            [questKeys.triggerEnd] = {"Put Out the Fires",{
                [zoneIDs.EVERSONG_WOODS]={{47.3,46.6,},},
                [zoneIDs.DUROTAR]={{52.8,42.6,},},
                [zoneIDs.TIRISFAL_GLADES]={{61,53.5,},},
            },},
        },
        [12146] = {
            [questKeys.startedBy] = {{27004,27005},nil,{36855}},
        },
        [12147] = {
            [questKeys.startedBy] = {{27004,27005},nil,{36856}},
        },
        [12150] = {
            [questKeys.objectives] = {{{27003,}}},
        },
        [12152] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Place the Infused Drakkari Offering at the gongs outside Drakil'jin"),0,{{"object", 188510}}},
            },
        },
        [12157] = {
            [questKeys.exclusiveTo] = {12171,12174,12235,12297},
        },
        [12159] = {
            [questKeys.objectives] = {{{26891,"Miner at Rest"}}},
        },
        [12166] = {
            [questKeys.objectives] = {{{26616,"Blighted Elk's corpse cleansed"},{26643,"Rabid Grizzly's corpse cleansed"},},nil,nil,nil,},
        },
        [12171] = {
            [questKeys.exclusiveTo] = {12174,12235,12297},
        },
        [12174] = {
            [questKeys.exclusiveTo] = {12235},
        },
        [12180] = {
            [questKeys.preQuestSingle] = {12014},
        },
        [12181] = {
            [questKeys.exclusiveTo] = {12188},
        },
        [12182] = {
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 12188,
        },
        [12184] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26408,26409,26410,26414,27177},26408,}}},
        },
        [12185] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Intercept the message from Loken"),1,{{"object", 188596}}},
            },
        },
        [12188] = {
            [questKeys.preQuestSingle] = {},
        },
        [12198] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26407,27017},26407,}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Fight Lightning Sentries with Depleted War Golem deployed nearby"),0,{{"monster", 26407}}},
            },
        },
        [12202] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26408,26409,26410,26414,27177},26408,}}},
        },
        [12203] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Intercept the message from Loken"),1,{{"object", 188596}}},
            },
        },
        [12204] = {
            [questKeys.preQuestSingle] = {12099,12058},
            [questKeys.preQuestGroup] = {},
        },
        [12206] = {
            [questKeys.objectives] = {{{27349,"Flask of Blight tested"}}},
        },
        [12207] = {
            [questKeys.preQuestSingle] = {12413},
        },
        [12208] = {
            [questKeys.preQuestSingle] = {12412},
        },
        [12211] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27202,27203,27206},27203,"Scarlet Onslaught corpses picked clean"}}},
        },
        [12213] = {
            [questKeys.preQuestSingle] = {12413},
        },
        [12214] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27206,27213,27296,27028},27296,}}},
        },
        [12218] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Commandeer a Forsaken Blight Spreader"),1,{{"monster", 26523}}},
            },
        },
        [12222] = {
            [questKeys.preQuestSingle] = {12294},
        },
        [12223] = {
            [questKeys.preQuestSingle] = {12294},
        },
        [12224] = {
            [questKeys.preQuestGroup] = {12221,12140,12072},
        },
        [12227] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Anderhol's Slider Cider"),0,{{"object", 188666}}}},
        },
        [12229] = {
            [questKeys.preQuestGroup] = {12207,12213},
        },
        [12231] = {
            [questKeys.objectives] = {{{27274,"Orsonn's Story"},{27275,"Kodian's Story"}}},
            [questKeys.preQuestGroup] = {12207,12213},
        },
        [12232] = {
            [questKeys.objectives] = {nil,{{188673,}}},
        },
        [12236] = {
            [questKeys.preQuestGroup] = {12241,12242},
            [questKeys.objectives] = {{{26633,}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tur Ragepaw to summon Ursoc"),0,{{"monster", 27328}}}},
        },
        [12237] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27315,27336,27345,27341},27315,"Helpless Villager Rescued"}}},
        },
        [12241] = {
            [questKeys.preQuestGroup] = {12229,12231},
        },
        [12242] = {
            [questKeys.preQuestGroup] = {12229,12231},
        },
        [12244] = {
            [questKeys.objectives] = {{{27354}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Deliver Shredder"),0,{{"monster", 27371}}}},
        },
        [12247] = {
            [questKeys.objectives] = {{{27274,"Orsonn's Story"},{27275,"Kodian's Story"}}},
        },
        [12249] = {
            [questKeys.objectives] = {{{26633,}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tur Ragepaw to summon Ursoc"),0,{{"monster", 27328}}}},
        },
        [12256] = {
            [questKeys.preQuestSingle] = {12468},
        },
        [12258] = {
            [questKeys.preQuestSingle] = {12251},
        },
        [12259] = {
            [questKeys.preQuestGroup] = {12256,12257},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ride Flamebringer"),0,{{"monster", 27292}}}},
        },
        [12260] = {
            [questKeys.objectives] = {{{27202,}}},
        },
        [12261] = {
            [questKeys.preQuestSingle] = {12447},
            [questKeys.objectives] = {{{27430,}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Destructive Ward"),0,{{"object", 188707}}},
            },
        },
        [12262] = {
            [questKeys.preQuestSingle] = {12447},
        },
        [12263] = {
            [questKeys.triggerEnd] = {"Uncover the Magmawyrm Resurrection Chamber",{[zoneIDs.DRAGONBLIGHT]={{31.76,30.46,},},},},
        },
        [12264] = {
            [questKeys.preQuestSingle] = {12263},
            [questKeys.objectives] = {{{27358},{27362},{27363}}},
        },
        [12265] = {
            [questKeys.preQuestSingle] = {12263},
        },
        [12269] = {
            [questKeys.preQuestSingle] = {12275},
        },
        [12270] = {
            [questKeys.objectives] = {{{27354}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Deliver Shredder"),0,{{"monster", 27423}}}},
        },
        [12271] = {
            [questKeys.startedBy] = {{27209},nil,{37432}},
            [questKeys.preQuestSingle] = {12252},
        },
        [12273] = {
            [questKeys.objectives] = {{{27237,},{27235,},{27234,},{27236,}}},
        },
        [12274] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Abbey Bell Rope"),0,{{"object", 188713}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("High Abbot spoken with"),1,{{"monster", 27245}}},
            },
        },
        [12284] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27475,27482,},27475,"Alliance units eliminated"}}},
        },
        [12288] = {
            [questKeys.objectives] = {{{27463,"Wounded Skirmishers Healed"}}},
        },
        [12289] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27456,27463},27456,"Horde units eliminated"}}},
        },
        [12296] = {
            [questKeys.objectives] = {{{27482,"Westfall Infantry Healed"}}},
        },
        [12297] = {
            [questKeys.preQuestSingle] = {11250},
            [questKeys.exclusiveTo] = {12157},
        },
        [12301] = {
            [questKeys.triggerEnd] = {"The Forgotten Redeemed",{[zoneIDs.DRAGONBLIGHT]={{86.86,66.18,},},},},
        },
        [12316] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27500,27550},27550,"Horde killed in Venture Bay"}}},
        },
        [12317] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27501,27549},27549,"Alliance killed in Venture Bay"}}},
        },
        [12323] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Smoke Bomb"),0,{{"monster", 27570}}}},
        },
        [12324] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Smoke Bomb"),0,{{"monster", 27570}}}},
        },
        [12321] = {
            [questKeys.triggerEnd] = {"Righteous Sermon Heard",{[zoneIDs.DRAGONBLIGHT]={{76.73,47.4,},},},},
        },
        [12327] = {
            [questKeys.triggerEnd] = {"Vision from the Past",{[zoneIDs.SILVERPINE_FOREST]={{46.53,76.18,},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Gossamer Potion"),0,{{"object", 189972}}}},
        },
        [12330] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Tranquilizer Dart on Tatjana"),0,{{"monster", 27627}}}},
            [questKeys.triggerEnd] = {"Tatjana Delivered",{[zoneIDs.GRIZZLY_HILLS]={{57.77,41.7,},},},},
        },
        [12372] = {
            [questKeys.objectivesText] = {"Devrestrasz at Wyrmrest Temple has asked you to slay 3 Azure Dragons, slay 5 Azure Drakes, and to destabilize the Azure Dragonshrine while riding a Wyrmrest Defender into battle."}, -- #4675
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ride a Wyrmrest Defender to defend the Temple"), 0, {{"monster", 27629}}},
            },
        },
        [12412] = {
            [questKeys.preQuestSingle] = {12259},
        },
        [12415] = {
            [questKeys.objectives] = {{{26472,}}},
        },
        [12419] = {
            [questKeys.startedBy] = {{27680},nil,{37833}},
        },
        [12423] = {
            [questKeys.startedBy] = {{27547},nil,{37830}},
        },
        [12427] = {
            [questKeys.preQuestSingle] = {12413},
            [questKeys.triggerEnd] = {"Ironhide defeated",{[zoneIDs.GRIZZLY_HILLS]={{23.2,64.68,},},},},
            [questKeys.objectives] = {{{27715,}}},
        },
        [12428] = {
            [questKeys.triggerEnd] = {"Torgg Thundertotem defeated",{[zoneIDs.GRIZZLY_HILLS]={{23.05,64.55,},},},},
            [questKeys.objectives] = {{{27716,}}},
        },
        [12429] = {
            [questKeys.triggerEnd] = {"Rustblood defeated",{[zoneIDs.GRIZZLY_HILLS]={{23.12,64.62,},},},},
            [questKeys.objectives] = {{{27717,}}},
        },
        [12430] = {
            [questKeys.triggerEnd] = {"Horgrenn Hellcleave defeated",{[zoneIDs.GRIZZLY_HILLS]={{23.11,64.6,},},},},
            [questKeys.objectives] = {{{27718,}}},
        },
        [12431] = {
            [questKeys.objectives] = {{{27727,}}},
        },
        [12434] = {
            [questKeys.specialFlags] = 1,
        },
        [12435] = { -- #4675
            [questKeys.name] = "Report to Lord Devrestrasz",
            [questKeys.objectivesText] = {"Speak with Lord Devrestrasz at Wyrmrest Temple."},
        },
        [12439] = {
            [questKeys.exclusiveTo] = {12000},
        },
        [12446] = {
            [questKeys.specialFlags] = 1,
        },
        [12453] = {
            [questKeys.preQuestSingle] = {12412},
            [questKeys.objectives] = {{{26369,}}},
        },
        [12456] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DRAGONBLIGHT]={{64.6,77}}}, Questie.ICON_TYPE_EVENT, l10n("Use Skytalon Molts"),0}},
        },
        [12459] = {
            [questKeys.objectives] = {{{26841,nil},{27808,nil},{27122,nil},},nil,nil,nil,},
        },
        [12462] = {
            [questKeys.preQuestSingle] = {12326},
        },
        [12464] = {
            [questKeys.preQuestSingle] = {},
        },
        [12467] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Wyrmbait and slay Icestorm"),0,{{"monster", 27843}}},},
        },
        [12470] = {
            [questKeys.triggerEnd] = {"Hourglass of Eternity protected",{[zoneIDs.DRAGONBLIGHT]={{71.57,38.91,},},},},
        },
        [12473] = {
            [questKeys.triggerEnd] = {"Thel'zan the Duskbringer Defeated",{[zoneIDs.DRAGONBLIGHT]={{81.11,50.64,},},},},
        },
        [12478] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Zelig's Scrying Orb"),0,{{"object", 190191}}},},
        },
        [12481] = {
            [questKeys.objectives] = {{{24238,"Bjorn Halgurdsson insulted"},{24238,"Bjorn Halgurdsson defeated"}}},
        },
        [12484] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.GRIZZLY_HILLS]={{16.84,48.34}}}, Questie.ICON_TYPE_EVENT, l10n("Place Scourged Troll Mummy in the fire"),0}},
        },
        [12486] = {
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [12498] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Antiok's mount to make him vulnerable"),0,{{"monster", 28018}}},},
        },
        [12500] = {
            [questKeys.preQuestSingle] = {12498},
        },
        [12503] = {
            [questKeys.preQuestSingle] = {12795},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28023,28026,28246,28669,28022},28022,"Scourge at The Argent Stand destroyed"}}},
        },
        [12506] = {
            [questKeys.triggerEnd] = {"Main building at the Altar of Sseratus investigated.",{[zoneIDs.ZUL_DRAK]={{40.32,39.46,},},},},
        },
        [12512] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28133,28136},28133},{{28141,28142},28141},{{28143,28148},28143}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Escort rescued Crusaders to Dr. Rogers"), 0, {{"monster", 28125}}}},
        },
        [12516] = {
            [questKeys.objectives] = {{{28068}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Muddled Mojo on Prophet of Sseratus before killing it"), 0, {{"monster", 28068}}}},
        },
        [12520] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12527] = {
            [questKeys.requiredSourceItems] = {38380},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Feed with Zul'Drak Rat"), 0, {{"monster", 28145}}}},
        },
        [12530] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Softknuckle Poker on Softknuckles"), 0, {{"monster", 28127}}}},
        },
        [12532] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12533,12534},
        },
        [12533] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12529,12530},
        },
        [12534] = {
            [questKeys.preQuestGroup] = {12529,12530},
        },
        [12536] = {
            [questKeys.triggerEnd] = {"Travel to Mistwhisper Refuge.",{[zoneIDs.SHOLAZAR_BASIN]={{46.31,39.88,},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Captive Crocolisk"), 0, {{"monster", 28298}}}},
        },
        [12537] = {
            [questKeys.triggerEnd] = {"Sabotage the Mistwhisper Weather Shrine",{[zoneIDs.SHOLAZAR_BASIN]={{45.23,37.1,},},},},
        },
        [12544] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Soo-rahm's Incense"), 0, {{"object", 190507}}}},
        },
        [12548] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{40.35,83.08,}}}, Questie.ICON_TYPE_EVENT, l10n("Travel through the Waygate"),}},
        },
        [12549] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12551] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12520,12549},
        },
        [12555] = {
            [questKeys.objectives] = {{{28274,"Plague Sprayers webbed and destroyed"}}},
        },
        [12557] = {
            [questKeys.objectives] = {nil,nil,{{38386},{38339},{38340},{38346}}},
        },
        [12561] = {
            [questKeys.requiredSpell] = 54197,
        },
        [12569] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Sandfern Disguise near the fallen log"), 0, {{"object", 190545}}}},
        },
        [12570] = {
            [questKeys.triggerEnd] = {"Escort the Injured Rainspeaker Oracle to Rainspaker Canopy",{[zoneIDs.SHOLAZAR_BASIN]={{53.59,56.76,},},},},
        },
        [12573] = {
            [questKeys.triggerEnd] = {"Extend Peace Offering to Shaman Vekjik",{[zoneIDs.SHOLAZAR_BASIN]={{51.34,64.67,},},},},
        },
        [12577] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12575,12576},
        },
        [12578] = {
            [questKeys.triggerEnd] = {"Travel to Mosswalker Village.",{[zoneIDs.SHOLAZAR_BASIN]={{75.07,51.88,},},},},
        },
        [12580] = {
            [questKeys.objectives] = {{{28113,"Mosswalker Victims Rescued"}}},
        },
        [12584] = {
            [questKeys.preQuestGroup] = {12552},
        },
        [12589] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12595] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
        },
        [12596] = {
            [questKeys.preQuestSingle] = {12740},
            [questKeys.preQuestGroup] = {},
        },
        [12603] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
        },
        [12605] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
        },
        [12606] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28415,28413},28415}}},
        },
        [12607] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28379,28374},28379,}}},
        },
        [12615] = {
            [questKeys.preQuestSingle] = {12516},
        },
        [12620] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{49.64,37.41,}}}, Questie.ICON_TYPE_EVENT, l10n("Use Freya's Horn atop of the Glimmering Pillar"),}},
        },
        [12621] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Listen to what the Avatar of Freya has to say"), 0, {{"monster", 27801}}}},
        },
        [12622] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Jin'Alai Trolls until their leaders appear"), 0, {{"monster", 28388},{"monster", 28504},{"object", 193768},{"object", 193769},{"object", 193770}}}},
        },
        [12629] = {
            [questKeys.preQuestSingle] = {12637},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12643},
            [questKeys.nextQuestInChain] = 12648,
        },
        [12630] = {
            [questKeys.objectives] = {{{28519,"Hair Samples Collected"},},nil,nil,nil,},
        },
        [12631] = {
            [questKeys.startedBy] = {nil,nil,{38660}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12633},
            [questKeys.nextQuestInChain] = 12637,
        },
        [12632] = {
            [questKeys.objectives] = {{{28404}}},
        },
        [12633] = {
            [questKeys.startedBy] = {nil,nil,{38673}},
            [questKeys.preQuestSingle] = {12238},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12631},
            [questKeys.nextQuestInChain] = 12638,
        },
        [12634] = {
            [questKeys.preQuestGroup] = {12520,12549},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Pull Sturdy Vines to reveal fruit"), 0, {{"object", 190622}}}},
        },
        [12637] = {
            [questKeys.preQuestSingle] = {12631},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12638},
            [questKeys.nextQuestInChain] = 12629,
        },
        [12638] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12633,12238},
            [questKeys.exclusiveTo] = {12637},
            [questKeys.nextQuestInChain] = 12643,
        },
        [12641] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Eye of Acherus Control Mechanism"), 0, {{"object", 191609}}}},
        },
        [12643] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12638,12238},
            [questKeys.exclusiveTo] = {12629},
            [questKeys.nextQuestInChain] = 12649,
        },
        [12648] = {
            [questKeys.preQuestSingle] = {12629},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12649},
            [questKeys.nextQuestInChain] = 12661,
        },
        [12649] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12643,12238},
            [questKeys.exclusiveTo] = {12648},
            [questKeys.nextQuestInChain] = 12661,
        },
        [12651] = {
            [questKeys.preQuestGroup] = {12558,12556,12592},
            [questKeys.exclusiveTo] = {12654},
            [questKeys.nextQuestInChain] = 12654,
        },
        [12652] = {
            [questKeys.requiredRaces] = 2047,
            [questKeys.preQuestSingle] = {12629,12643},
            [questKeys.exclusiveTo] = {12713},
            [questKeys.objectives] = {{{28565,}}},
        },
        [12659] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28465,28600},28622}}},
        },
        [12661] = {
            [questKeys.preQuestSingle] = {12648,12649},
            [questKeys.preQuestGroup] = {},
            [questKeys.childQuests] = {12663,12664},
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 12669,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, Questie.ICON_TYPE_EVENT, l10n("Infiltrate Voltarus using Ensorcelled Choker"),},
            },
        },
        [12662] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Heb'Jin's Drum to summon Heb'Jin"), 0, {{"object", 190695}}}},
        },
        [12663] = {
            [questKeys.preQuestSingle] = {12649},
            [questKeys.exclusiveTo] = {12664,12648},
            [questKeys.parentQuest] = 12661,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Gorebag and take the tour of Zul'Drak"), 0, {{"monster", 28666}}}},
        },
        [12664] = {
            [questKeys.preQuestSingle] = {12648},
            [questKeys.exclusiveTo] = {12663,12649},
            [questKeys.parentQuest] = 12661,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Gorebag and take the tour of Zul'Drak"), 0, {{"monster", 28666}}}},
        },
        [12665] = {
            [questKeys.triggerEnd] = {"Quetz'lun's fate revealed.",{[zoneIDs.ZUL_DRAK]={{75.75,58.39,},},},},
        },
        [12668] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28747,28748},28747,"Trolls killed near a Soul Font"}}},
        },
        [12669] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
            },
        },
        [12671] = {
            [questKeys.triggerEnd] = {"Reconnaissance Flight",{[zoneIDs.SHOLAZAR_BASIN]={{50.04,61.43,},},},},
        },
        [12673] = {
            [questKeys.objectives] = {nil,{{190716}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Scepter of Suggestion to mind control Blight Geist"), 0, {{"monster", 28750}}},
            },
        },
        [12674] = {
            [questKeys.objectives] = {{{28752,"High Priest Mu'funu hexed at death"},{28754,"High Priestess Tua-Tua hexed at death"},{28756,"High Priest Hawinni hexed at death"}}},
        },
        [12676] = {
            [questKeys.objectives] = {nil,{{190731},{192767},{190948}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
            },
        },
        [12677] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
            },
        },
        [12680] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28605,28606,28607},28605,"Horse Successfully Stolen"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Deliver Stolen Horse"), 0, {{"monster", 28653}}}},
        },
        [12683] = {
            [questKeys.objectives] = {{{28003,},{28003}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
        },
        [12685] = {
            [questKeys.objectives] = {{{28671}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Quetz'lun's Ritual"), 0, {{"monster", 28672}}}},
        },
        [12686] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Scepter of Empowerment to mind control Servant of Drakuru"), 0, {{"monster", 28802}}},
            },
        },
        [12687] = {
            [questKeys.triggerEnd] = {"The Horseman's Challenge",{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{52.41,34.59,},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Dark Rider of Acherus and take his horse"), 0, {{"monster", 28768},{"monster", 28782}}}},
        },
        [12688] = {
            [questKeys.triggerEnd] = {"Escort Engineer Helice out of Swindlegrin's Dig",{[zoneIDs.SHOLAZAR_BASIN]={{37.26,50.56,},},},},
        },
        [12690] = {
            [questKeys.objectives] = {{{28844,"Drakkari Skullcrushers Slain"},{28873,"Drakkari Chieftain Lured"},},nil,nil,nil,},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Scepter of Command"), 0, {{"monster", 28843}}}},
        },
        [12692] = {
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12695] = {
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12697] = {
            [questKeys.preQuestGroup] = {12678,12679,12687,12733,},
        },
        [12698] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28819,28822,28891},28819,"Scarlet Ghoul Returned"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Return Scarlet Ghouls"), 0, {{"monster", 28658}}}},
        },
        [12699] = {
            [questKeys.preQuestSingle] = {12523},
        },
        [12701] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Climb inside the Inconspicuous Mine Car"), 0, {{"object", 190767}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Scarlet Cannon"), 0, {{"monster", 28833}}},
            },
        },
        [12702] = {
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12703] = {
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12704] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to High-Oracle Soo-say to retrieve a Gorloc companion"), 0, {{"monster", 28027}}},
            },
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12705] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Tainted Crystal at the Great Lightning Stone"), 0, {{"object", 190781}}},
            },
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12707] = {
            [questKeys.objectives] = {{{28861,"Mam'toth Disciples trampled to death"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Medallion of Mam'toth to calm and ride an Enraged Mammoth"),0,{{"monster", 28851}}},
            },
        },
        [12710] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, Questie.ICON_TYPE_EVENT, l10n("Take the teleporter to Drakuru's upper chamber"),},
            },
        },
        [12713] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28503,28998},28503,}}},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, Questie.ICON_TYPE_EVENT, l10n("Infiltrate Voltarus using Ensorcelled Choker"),},
            },
        },
        [12720] = {
            [questKeys.triggerEnd] = {"\"Crimson Dawn\" Revealed",{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{55.09,66.12},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Equip Keleseth's Persuaders and persuade Scarlet Crusaders"), 0, {{"monster", 28610},{"monster", 28936},{"monster", 28939},{"monster", 28940},}}},
        },
        [12721] = {
            [questKeys.triggerEnd] = {"Akali unfettered from his chains.",{[zoneIDs.ZUL_DRAK]={{78.64,25.11,},},},},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Release Akali from his chains"), 0, {{"object", 191018}}}},
        },
        [12723] = {
            [questKeys.preQuestGroup] = {12717,12720,12722},
        },
        [12726] = {
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.objectives] = {{{28862,},{28858,}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{26.51,35.63}}}, Questie.ICON_TYPE_EVENT, l10n("Use Drums of the Tempest at Stormwright's Shelf"),}},
        },
        [12730] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.ZUL_DRAK]={{77.61,36.64}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Prophet of Akali Convocation"),}},
        },
        [12732] = {
            [questKeys.requiredMinRep] = {1104,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Fill Rejek's Vial"), 0, {{"object", 191122}}}},
        },
        [12733] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28391,28394,28406},28391,"Death Knights defeated in a duel"}}},
        },
        [12734] = {
            [questKeys.objectives] = {{{28086,"Blade blooded on Sapphire Hive Wasp"},{28096,"Blade blooded on Hardknuckle Charger"}},nil,nil,nil,{{{28109,28110},28109,"Blade Blooded on Mistwhisper members"}}},
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12735] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.SHOLAZAR_BASIN]={{43,42}}}, Questie.ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Atha"),0},
                {{[zoneIDs.SHOLAZAR_BASIN]={{49,63}}}, Questie.ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Ha-Khalan"),1},
                {{[zoneIDs.SHOLAZAR_BASIN]={{46,74}}}, Questie.ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Koosu"),2},
            },
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12736] = {
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12737] = {
            [questKeys.objectives] = {nil,{{191136,}}},
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12740] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28028,28029},28028,}}},
        },
        [12741] = {
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12754] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{60.9,75.5}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Makeshift Cover"),}},
        },
        [12758] = {
            [questKeys.requiredMinRep] = {1104,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Venture Co. Explosive on dead Stonewatcher"),0,{{"monster", 28877}}}},
        },
        [12759] = {
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12760] = {
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12761] = {
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12762] = {
            [questKeys.requiredMinRep] = {1105,9000},
            ---[questKeys.objectives] = {nil,nil,{{39748}},nil,{{{28079,28078},28078,"Frenzyheart Attacker"}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{65.60,59.48}}}, Questie.ICON_TYPE_EVENT, l10n("Charge the Dormant Polished Crystal at the exposed Lifeblood Pillar"),}},
        },
        [12779] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{53.5,36.7}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Horn of the Frostbrood"),}},
        },
        [12797] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.UN_GORO_CRATER]={{50.54,7.74,}}}, Questie.ICON_TYPE_EVENT, l10n("Travel through the Waygate"),}},
        },
        [12801] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Highlord Darion Mograine"), 0, {{"monster", 29173}}},
                {{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{38.8,38.4}}}, Questie.ICON_TYPE_EVENT, l10n("The Light of Dawn Uncovered"),},
            },
        },
        [12803] = {
            [questKeys.requiredSpell] = 54197,
        },
        [12804] = {
            [questKeys.preQuestSingle] = {12520},
        },
        [12805] = {
            [questKeys.objectives] = {{{29124,}}},
        },
        [12807] = {
            [questKeys.objectives] = {{{29344,}}},
        },
        [12810] = {
            [questKeys.objectives] = {{{29392,}}},
        },
        [12813] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29329,29330,29333,29338},29398}}},
            [questKeys.preQuestSingle] = {12807},
        },
        [12814] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29406,29405},29406}}},
        },
        [12815] = {
            [questKeys.preQuestSingle] = {12814},
        },
        [12816] = {
            [questKeys.triggerEnd] = {"Investigate a circle",{[zoneIDs.EVERSONG_WOODS]={{56.5,52,},},},},
        },
        [12817] = {
            [questKeys.triggerEnd] = {"Investigate a circle",{[zoneIDs.AZUREMYST_ISLE]={{34.9,45.5,},},},},
        },
        [12821] = {
            [questKeys.name] = "Cell Block Tango",
            [questKeys.triggerEnd] = {"Garm Teleporter Activated",{[zoneIDs.STORM_PEAKS]={{50.7,81.9,},},},},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12820,12828,12832},
        },
        [12823] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place Hardpacked Explosive Bundle at Frostgut's Altar"), 0, {{"object", 191842}}}},
        },
        [12828] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Retrieve U.D.E.D."), 0, {{"object", 191553}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use U.D.E.D on Ironwool Mammoth"), 0, {{"monster", 29402}}},
            },
        },
        [12831] = {
            [questKeys.preQuestSingle] = {},
        },
        [12832] = {
            [questKeys.triggerEnd] = {"Escort the Injured Goblin Miner to K3.",{[zoneIDs.STORM_PEAKS]={{40.2,79,},},},},
        },
        [12838] = {
            [questKeys.preQuestSingle] = {12807},
        },
        [12842] = {
            [questKeys.triggerEnd] = {"Weapon emblazoned",{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{47.28,31.36},{47.82,27.42},{50.43,28.17},},},},
        },
        [12851] = {
            [questKeys.name] = "Bearly Hanging On",
            [questKeys.objectives] = {{{29358},{29351}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount Icefang"), 0, {{"monster", 29598}}},
            },
        },
        [12852] = {
            [questKeys.objectives] = {{{29621,}}},
        },
        [12855] = {
            [questKeys.preQuestSingle] = {12854},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.STORM_PEAKS]={{36.4,64.2}}}, Questie.ICON_TYPE_EVENT, l10n("Use Frosthound's Collar at the Abandoned Camp"),},
            },
        },
        [12856] = {
            [questKeys.objectives] = {{{29639,"Rescued Brunnhildar Prisoners"},{29708,"Freed Proto-Drakes"}}},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.STORM_PEAKS]={{62.00,59.50}}}, Questie.ICON_TYPE_EVENT, l10n("Fly freed Proto-Drakes to safety while carrying rescued Brunnhildar Prisoners"),},
            },
        },
        [12862] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Ricket for transportation"), 0, {{"monster", 29428}}}},
        },
        [12864] = {
            [questKeys.triggerEnd] = {"Locate Missing Scout",{[zoneIDs.STORM_PEAKS]={{37.68,66.75},{38.49,77.19},{31.65,64.53},{34.56,64.64},{36.43,77.3},},},},
        },
        [12865] = {
            [questKeys.objectives] = {{{30013,"Stormcrest Eagles fed"}}},
            [questKeys.preQuestSingle] = {12863},
        },
        [12869] = {
            [questKeys.preQuestSingle] = {12867,13417},
        },
        [12874] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Fjorlin Frostbrow"), 0, {{"monster", 29732}}}},
        },
        [12876] = {
            [questKeys.preQuestSingle] = {12874},
        },
        [12885] = {
            [questKeys.nextQuestInChain] = 12930,
        },
        [12886] = {
            [questKeys.objectives] = {{{29694}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Hyldnir Harpoon to land on nearby Proto-Drakes"), 0, {{"monster", 29625}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Hyldnir Harpoon on Column Ornaments to dismount"), 0, {{"monster", 29754}}},
            },
        },
        [12887] = {
            [questKeys.objectives] = {{{29747,"The Ocular has been destroyed"}}},
        },
        [12889] = {
            [questKeys.requiredSkill] = {202,400},
        },
        [12892] = {
            [questKeys.objectives] = {{{29747,"The Ocular has been destroyed"}}},
        },
        [12893] = {
            [questKeys.objectives] = {{{29769},{29770},{29840}}},
        },
        [12897] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Tamper with General's Weapon Rack to summon General Lightsbane"), 0, {{"object", 191778},{"object", 191779}}},
            },
        },
        [12906] = {
            [questKeys.objectives] = {{{30146,"Exhausted Vrykul Disciplined"}}},
        },
        [12910] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount Frostbite to track scent"), 0, {{"monster", 29857}}},
            },
        },
        [12919] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Slay Scourge while riding Gymer"), 0, {{"monster", 29647}}},
                {{[zoneIDs.ZUL_DRAK]={{26.71,57.29}}}, Questie.ICON_TYPE_EVENT, l10n("Slay Scourge while riding Gymer"),},
            },
        },
        [12920] = {
            [questKeys.preQuestSingle] = {12917},
        },
        [12924] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to King Jokkum about Thorim's armor"), 0, {{"monster", 30105}}},
            },
        },
        [12925] = {
            [questKeys.preQuestSingle] = {12905},
        },
        [12927] = {
            [questKeys.objectives] = {{{29746}}},
        },
        [12932] = {
            [questKeys.objectives] = {{{30014}}},
            [questKeys.exclusiveTo] = {12954},
            [questKeys.nextQuestInChain] = 9977, -- This is the version of the quest you get if you have NOT completed 9977
            [questKeys.triggerEnd] = {"Yggdras Defeated",{[zoneIDs.ZUL_DRAK]={{47.93,56.85,},},},},
        },
        [12933] = {
            [questKeys.triggerEnd] = {"Stinkbeard Defeated",{[zoneIDs.ZUL_DRAK]={{47.94,56.61,},},},},
        },
        [12934] = {
            [questKeys.triggerEnd] = {"Elemental Lord Defeated",{[zoneIDs.ZUL_DRAK]={{48.01,56.72,},},},},
        },
        [12935] = {
            [questKeys.triggerEnd] = {"Orinoko Tuskbreaker Defeated",{[zoneIDs.ZUL_DRAK]={{48,56.72,},},},},
        },
        [12936] = {
            [questKeys.triggerEnd] = {"Korrak the Bloodrager Defeated",{[zoneIDs.ZUL_DRAK]={{48.04,56.75,},},},},
        },
        [12939] = {
            [questKeys.objectives] = {{{30037,}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Challenge Flag on sparring Mjordin Combatants"), 0, {{"monster", 30037}}},
            },
        },
        [12940] = {
            [questKeys.startedBy] = {nil,{400017}},
            [questKeys.finishedBy] = {nil,{400017}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [12941] = {
            [questKeys.startedBy] = {nil,{400016}},
            [questKeys.finishedBy] = {nil,{400016}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [12942] = {
            [questKeys.preQuestSingle] = {12905},
        },
        [12944] = {
            [questKeys.startedBy] = {nil,{400038}},
            [questKeys.finishedBy] = {nil,{400038}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [12945] = {
            [questKeys.startedBy] = {nil,{400039}},
            [questKeys.finishedBy] = {nil,{400039}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [12946] = {
            [questKeys.startedBy] = {nil,{400019}},
            [questKeys.finishedBy] = {nil,{400019}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [12947] = {
            [questKeys.startedBy] = {nil,{400018}},
            [questKeys.finishedBy] = {nil,{400018}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [12948] = {
            [questKeys.triggerEnd] = {"Vladof the Butcher Defeated",{[zoneIDs.ZUL_DRAK]={{47.98,56.74,},},},},
        },
        [12950] = {
            [questKeys.startedBy] = {nil,{400032}},
            [questKeys.finishedBy] = {nil,{400032}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [12953] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Harpoon Guns to burn Dry Haystacks"), 0, {{"monster", 30066}}},
            },
        },
        [12954] = {
            [questKeys.objectives] = {{{30014}}},
            [questKeys.preQuestSingle] = {9977},
            [questKeys.exclusiveTo] = {12932},
            [questKeys.triggerEnd] = {"Yggdras Defeated",{[zoneIDs.ZUL_DRAK]={{47.93,56.85,},},},},
        },
        [12957] = {
            [questKeys.objectives] = {{{29384},{29369}}},
        },
        [12966] = {
            [questKeys.preQuestGroup] = {12915,12956},
            [questKeys.requiredMinRep] = {1119,0},
        },
        [12967] = {
            [questKeys.objectives] = {{{30120}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Ride Snorri"), 0, {{"monster", 30123}}}},
        },
        [12968] = {
            [questKeys.preQuestSingle] = {12905},
        },
        [12970] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Listen to Lok'lira's proposal"), 0, {{"monster", 29975}}},
            },
        },
        [12973] = {
            [questKeys.triggerEnd] = {"Accompany Brann Bronzebeard to Frosthold.",{[zoneIDs.STORM_PEAKS]={{30.2,74.6,},},},},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORM_PEAKS]={{39.6,56.4}}}, Questie.ICON_TYPE_EVENT, l10n("Get in Brann Bronzebeard Flying Machine"),}},
            [questKeys.preQuestSingle] = {12880},
        },
        [12974] = {
            [questKeys.exclusiveTo] = {12932,12954},
        },
        [12975] = {
            [questKeys.preQuestSingle] = {12924},
        },
        [12977] = {
            [questKeys.name] = "Hodir's Call",
            [questKeys.objectives] = {{{29974,"Niffelem Forefather freed"},},nil,nil,nil,{{{30144,30135},30144,},},},
            [questKeys.preQuestSingle] = {12976},
        },
        [12978] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29370,29374,29380},29370,"Nidavelir Stormforged slain"}}},
        },
        [12979] = {
            [questKeys.objectives] = {nil,nil,{{42204},},nil,nil,},
        },
        [12981] = {
            [questKeys.preQuestSingle] = {12967},
        },
        [12985] = {
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Diamond Tipped Pick on the corpses of Dead Iron Giants"), 0, {{"monster", 29914},{"monster", 30163}}}},
        },
        [12987] = {
            [questKeys.name] = "Placing Hodir's Helm",
            [questKeys.requiredMinRep] = {1119,3000},
        },
        [12994] = {
            [questKeys.requiredMinRep] = {1119,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Ethereal Worg's Fang"), 0, {{"monster", 32569}}}},
        },
        [12995] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29915,29919,30037,30243,30250,30409,30475,30483,30484,30632,30725,30751,29880},29880,"Ebon Blade Banner planted near vrykul corpse"}}},
        },
        [12996] = {
            [questKeys.objectives] = {{{29352,"Kirgaraak Defeated"}}},
        },
        [13001] = {
            [questKeys.name] = "Forging Hodir's Spear",
            [questKeys.requiredMinRep] = {1119,9000},
        },
        [13003] = {
            [questKeys.name] = "How To Slay Your Dragon",
            [questKeys.objectives] = {{{30275,"Wild Wyrm Slain"}}},
            [questKeys.preQuestSingle] = {13001},
        },
        [13005] = {
            [questKeys.objectives] = {{{29984,"Iron Sentinel slain"},{29978,"Iron Dwarf Assailant slain"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use the Horn of the Peaks and call on the Earthen to defeat Iron Dwarves and Iron Sentinels"), 0, {{"monster", 29984},{"monster",29978}}}},
            [questKeys.preQuestSingle] = {13057},
        },
        [13006] = {
            [questKeys.name] = "A Viscous Cleaning",
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.preQuestSingle] = {12987},
        },
        [13007] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount Tamed Jormungar to fight Iron Colossus"),0,{{"monster", 30301},{"object", 192262}}},},
        },
        [13008] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30273,30268,30274},30273,}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Talk to Wyrmbait and slay Icestorm"),0,{{"monster", 28674}}},},
        },
        [13010] = {
            [questKeys.objectives] = {{{30105}},nil,nil,{1119,3000}},
        },
        [13011] = {
            [questKeys.name] = "Culling Jorcuttar",
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.requiredSourceItems] = {42733},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORM_PEAKS]={{53.1,61.2}}}, Questie.ICON_TYPE_EVENT, l10n("Place Icemaw Bear Flank"), 0}}
        },
        [13012] = {
            [questKeys.startedBy] = {{30348}},
            [questKeys.finishedBy] = {{30348}},
        },
        [13013] = {
            [questKeys.startedBy] = {{30357}},
            [questKeys.finishedBy] = {{30357}},
        },
        [13014] = {
            [questKeys.startedBy] = {{30358}},
            [questKeys.finishedBy] = {{30358}},
        },
        [13015] = {
            [questKeys.startedBy] = {{30359}},
            [questKeys.finishedBy] = {{30359}},
        },
        [13016] = {
            [questKeys.startedBy] = {{30360}},
            [questKeys.finishedBy] = {{30360}},
        },
        [13017] = {
            [questKeys.startedBy] = {{30531}},
            [questKeys.finishedBy] = {{30531}},
        },
        [13018] = {
            [questKeys.startedBy] = {{30362}},
            [questKeys.finishedBy] = {{30362}},
        },
        [13019] = {
            [questKeys.startedBy] = {{30363}},
            [questKeys.finishedBy] = {{30363}},
        },
        [13020] = {
            [questKeys.startedBy] = {{30375}},
            [questKeys.finishedBy] = {{30375}},
        },
        [13021] = {
            [questKeys.startedBy] = {{30536}},
            [questKeys.finishedBy] = {{30536}},
        },
        [13022] = {
            [questKeys.startedBy] = {{30533}},
            [questKeys.finishedBy] = {{30533}},
        },
        [13023] = {
            [questKeys.startedBy] = {{30534}},
            [questKeys.finishedBy] = {{30534}},
        },
        [13024] = {
            [questKeys.startedBy] = {{30365}},
            [questKeys.finishedBy] = {{30365}},
        },
        [13025] = {
            [questKeys.startedBy] = {{30367}},
            [questKeys.finishedBy] = {{30367}},
        },
        [13026] = {
            [questKeys.startedBy] = {{30368}},
            [questKeys.finishedBy] = {{30368}},
        },
        [13027] = {
            [questKeys.startedBy] = {{30369}},
            [questKeys.finishedBy] = {{30369}},
        },
        [13028] = {
            [questKeys.startedBy] = {{30370}},
            [questKeys.finishedBy] = {{30370}},
        },
        [13029] = {
            [questKeys.startedBy] = {{30371}},
            [questKeys.finishedBy] = {{30371}},
        },
        [13030] = {
            [questKeys.startedBy] = {{30372}},
            [questKeys.finishedBy] = {{30372}},
        },
        [13031] = {
            [questKeys.startedBy] = {{30373}},
            [questKeys.finishedBy] = {{30373}},
        },
        [13032] = {
            [questKeys.startedBy] = {{30374}},
            [questKeys.finishedBy] = {{30374}},
        },
        [13033] = {
            [questKeys.startedBy] = {{30364}},
            [questKeys.finishedBy] = {{30364}},
        },
        [13034] = {
            [questKeys.preQuestSingle] = {},
        },
        [13035] = {
            [questKeys.preQuestSingle] = {13057},
        },
        [13037] = {
            [questKeys.objectives] = {{{30395}}},
        },
        [13038] = {
            [questKeys.objectives] = {{{30448}}},
            [questKeys.preQuestSingle] = {13034},
        },
        [13039] = {
            [questKeys.preQuestSingle] = {13036},
        },
        [13040] = {
            [questKeys.preQuestSingle] = {13036},
        },
        [13042] = {
            [questKeys.preQuestSingle] = {12999},
        },
        [13043] = {
            [questKeys.startedBy] = {{30409},nil,{42772}},
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Mount Nergeld"), 0, {{"monster", 30403}}},
            },
        },
        [13044] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13008,13039,13040},
        },
        [13045] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Mount Argent Skytalon"), 0, {{"monster", 30500}}},
                {{[zoneIDs.ICECROWN]={{86.85,76.61}}}, Questie.ICON_TYPE_EVENT, l10n("Drop Off Captured Crusader"), 0},
            },
        },
        [13046] = {
            [questKeys.objectives] = {{{30422}}},
            [questKeys.requiredMinRep] = {1119,21000},
        },
        [13047] = {
            [questKeys.preQuestGroup] = {13035,13005},
            [questKeys.triggerEnd] = {"Witness the Reckoning",{[zoneIDs.STORM_PEAKS]={{36,31.4,},},},},
        },
        [13048] = {
            [questKeys.objectives] = {{{80000}}},
            [questKeys.preQuestGroup] = {13037,13038},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Attune the Lorehammer"), 0, {{"object", 192541},{"object", 192542},{"object", 192543},{"object", 192544},{"object", 192545},{"object", 192546}}},
            },
        },
        [13049] = {
            [questKeys.preQuestGroup] = {13037,13038},
        },
        [13058] = {
            [questKeys.preQuestGroup] = {13048,13049},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.STORM_PEAKS]={{64.4,46.7}}}, Questie.ICON_TYPE_OBJECT, l10n("Use the Lorehammer to travel back in time"), 0},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Defeat the North Wind"), 0, {{"monster", 30474}}},
            },
        },
        [13059] = {
            [questKeys.objectives] = {nil,{{192560}},nil,nil,{{{30475},32821,}}},
        },
        [13060] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Ricket for transportation"), 0, {{"monster", 29428}}},
            },
        },
        [13064] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Listen to Thorim's history"), 0, {{"monster", 29445}}},
            },
        },
        [13068] = {
            [questKeys.preQuestSingle] = {13141},
        },
        [13069] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 30337}}}},
        },
        [13071] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 30272}}}},
        },
        [13073] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Arch Druid Lilliandra for transportation to Moonglade"), 0, {{"monster", 30630}}}},
        },
        [13086] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Mount Argent Cannon"), 0, {{"monster", 30236}}},
            },
        },
        [13091] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30725,29880,30632,30243,30250},30644,}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Possess a Water Terror"), 0, {{"object", 192774}}},
            },
        },
        [13092] = {
            [questKeys.preQuestSingle] = {12999},
            [questKeys.specialFlags] = 0,
        },
        [13093] = {
            [questKeys.preQuestSingle] = {13092},
        },
        [13098] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 13099,
        },
        [13106] = {
            [questKeys.preQuestSingle] = {12897},
        },
        [13109] = {
            [questKeys.preQuestSingle] = {13047},
        },
        [13110] = {
            [questKeys.objectives] = {{{30202}}},
            [questKeys.preQuestSingle] = {13104},
        },
        [13118] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13121] = {
            [questKeys.objectives] = {nil,{{192861}}},
        },
        [13122] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13125] = {
            [questKeys.preQuestGroup] = {13122,13118},
        },
        [13130] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13133] = {
            [questKeys.objectives] = {{{30886}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Wake Slumbering Mjordin until you find Iskalder"), 0, {{"monster", 30718}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Iskalder delivered to The Bone Witch"), 0, {{"monster", 30232}}},
            },
        },
        [13134] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13135] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13136] = {
            [questKeys.startedBy] = {{30597},nil,{43242}},
            [questKeys.objectives] = {nil,nil,{{43259}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13137] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Battlescar Signal Fire to summon Iskalder"), 0, {{"object", 193024}}},
            },
        },
        [13138] = {
            [questKeys.preQuestSingle] = {13136},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Bag of Jagged Shards near Malykriss Furnace"), 0, {{"object", 193004}}}},
        },
        [13139] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13125,13130,13135},
        },
        [13140] = {
            [questKeys.preQuestSingle] = {13136},
        },
        [13141] = {
            [questKeys.triggerEnd] = {"Battle for Crusaders' Pinnacle",{[zoneIDs.ICECROWN]={{80.06,71.81,},},},},
        },
        [13142] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Blow the War Horn of Jotunheim to challenge Overthane Balargarde"), 0, {{"object", 193028}}},
            },
        },
        [13143] = {
            [questKeys.objectives] = {{{30894}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Lead a subdued Lithe Stalker to the cliff above Vereth the Cunning"), 0, {{"monster", 31049}}}},
        },
        [13144] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30689,31048},30689,}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13152,13211},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Free Burning Skeletons to destroy Chained Abominations"), 0, {{"object", 193060}}}},
        },
        [13145] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}}},
        },
        [13146] = {
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Drag Scourge Bombs to Lumbering Atrocities"), 0, {{"monster", 30920}}},
            },
        },
        [13147] = {
            [questKeys.objectives] = {{{30922}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}}},
        },
        [13152] = {
            [questKeys.preQuestSingle]= {},
            [questKeys.preQuestGroup] = {13134,13138,13140},
        },
        [13154] = {
            [questKeys.exclusiveTo] = {236,13156,},
        },
        [13155] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13172,13174},
        },
        [13156] = {
            [questKeys.exclusiveTo] = {236,13154,},
        },
        [13160] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}}},
        },
        [13164] = {
            [questKeys.preQuestSingle]= {},
            [questKeys.preQuestGroup] = {13161,13162,13163},
        },
        [13168] = {
            [questKeys.triggerEnd] = {"Seize Control of an Eidolon Watcher", {[zoneIDs.ICECROWN]={{44.19,24.69}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Eye of Dominion"), 0, {{"object", 193058}}}},
        },
        [13169] = {
            [questKeys.objectives] = {{{30952,"Hungering Plaguehounds fed"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of an Eidolon Watcher"), 0, {{"object", 193058}}}},
        },
        [13170] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of an Eidolon Watcher"), 0, {{"object", 193058}}}},
        },
        [13171] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of an Eidolon Watcher"), 0, {{"object", 193058}}}},
        },
        [13172] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13169,13170,13171},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Keritose Bloodblade to secure a Skeletal Gryphon"), 0, {{"monster", 30946}}}},
        },
        [13174] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13169,13170,13171},
        },
        [13181] = {
            [questKeys.triggerEnd] = {"Victory in Lake Wintergrasp", {[zoneIDs.DALARAN]={{33,67.2}}}},
        },
        [13183] = {
            [questKeys.triggerEnd] = {"Victory in Lake Wintergrasp", {[zoneIDs.DALARAN]={{58.2,25.6}}}},
        },
        [13185] = {
            [questKeys.exclusiveTo] = {13223},
        },
        [13186] = {
            [questKeys.exclusiveTo] = {13222},
        },
        [13191] = {
            [questKeys.finishedBy] = {{31106}},
            [questKeys.exclusiveTo] = {13193,13194,},
        },
        [13193] = {
            [questKeys.exclusiveTo] = {13191,13194,},
        },
        [13194] = {
            [questKeys.exclusiveTo] = {13191,13193,},
        },
        [13204] = {
            [questKeys.startedBy] = {{30329},nil,{43512}},
        },
        [13211] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13134,13138,13140},
        },
        [13214] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31191,31192,31193,31194,31195,31196,},31191}}},
        },
        [13215] = {
            [questKeys.objectives] = {{{31222}}},
        },
        [13216] = {
            [questKeys.objectives] = {{{31242}}},
        },
        [13217] = {
            [questKeys.objectives] = {{{31271}}},
        },
        [13218] = {
            [questKeys.objectives] = {{{31277}}},
        },
        [13219] = {
            [questKeys.objectives] = {{{14688}}},
        },
        [13220] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Crusader Olakin's Remains at the Sanctum of Reanimation Slab"), 0, {{"object", 193090}}}},
        },
        [13221] = {
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13222] = {
            [questKeys.exclusiveTo] = {13186},
        },
        [13223] = {
            [questKeys.exclusiveTo] = {13185},
        },
        [13226] = {
            [questKeys.nextQuestInChain] = 13036,
        },
        [13227] = {
            [questKeys.nextQuestInChain] = 13036,
        },
        [13228] = {
            [questKeys.objectives] = {{{31273,"Dying Berserker Questioned"}}},
            [questKeys.childQuests] = {13230},
            [questKeys.preQuestSingle] = {13224},
        },
        [13229] = {
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13230] = {
            [questKeys.parentQuest] = 13228,
            [questKeys.preQuestSingle] = {13228},
        },
        [13231] = {
            [questKeys.objectives] = {{{31304,"Dying Soldier Questioned"}}},
            [questKeys.childQuests] = {13232},
            [questKeys.preQuestSingle] = {13225},
        },
        [13232] = {
            [questKeys.parentQuest] = 13231,
            [questKeys.preQuestSingle] = {13231},
        },
        [13233] = {
            [questKeys.objectives] = {{{30344,}}},
            [questKeys.preQuestSingle] = {13231},
        },
        [13234] = {
            [questKeys.preQuestSingle] = {13228},
            [questKeys.objectives] = {{{30824,}}},
        },
        [13235] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Margrave Dhakar to fight Morbidus"), 0, {{"monster", 31306}}}},
        },
        [13236] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31254,32414,31276},31329}}},
        },
        [13238] = {
            [questKeys.preQuestSingle] = {13228},
        },
        [13239] = {
            [questKeys.preQuestSingle] = {13238},
        },
        [13240] = {
            [questKeys.startedBy] = {{31439},nil,nil},
            [questKeys.finishedBy] = {{31439},nil,nil},
            [questKeys.exclusiveTo] = {13241,13243,13244},
        },
        [13241] = {
            [questKeys.startedBy] = {{31439},nil,nil},
            [questKeys.finishedBy] = {{31439},nil,nil},
            [questKeys.exclusiveTo] = {13240,13243,13244},
        },
        [13242] = {
            [questKeys.preQuestSingle] = {12500},
        },
        [13243] = {
            [questKeys.startedBy] = {{31439},nil,nil},
            [questKeys.finishedBy] = {{31439},nil,nil},
            [questKeys.exclusiveTo] = {13240,13241,13244},
        },
        [13244] = {
            [questKeys.startedBy] = {{31439},nil,nil},
            [questKeys.finishedBy] = {{31439},nil,nil},
            [questKeys.exclusiveTo] = {13240,13241,13243},
        },
        [13245] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256},
        },
        [13246] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256},
        },
        [13247] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13248,13249,13250,13251,13252,13253,13254,13255,13256},
        },
        [13248] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13249,13250,13251,13252,13253,13254,13255,13256},
        },
        [13249] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13250,13251,13252,13253,13254,13255,13256},
        },
        [13250] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13251,13252,13253,13254,13255,13256},
        },
        [13251] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13252,13253,13254,13255,13256},
        },
        [13252] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13253,13254,13255,13256},
        },
        [13253] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13254,13255,13256},
        },
        [13254] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13255,13256},
        },
        [13255] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13256},
        },
        [13256] = {
            [questKeys.startedBy] = {{20735},nil,nil},
            [questKeys.finishedBy] = {{20735},nil,nil},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255},
        },
        [13258] = {
            [questKeys.preQuestGroup] = {12938,13224},
        },
        [13260] = {
            [questKeys.preQuestSingle] = {13228},
        },
        [13261] = {
            [questKeys.preQuestSingle] = {13239},
        },
        [13264] = {
            [questKeys.objectives] = {{{31142,"Icy Ghouls Exploded"},{31147,"Vicious Geists Exploded"},{31205,"Risen Alliance Soldiers Exploded"}}},
            [questKeys.preQuestSingle] = {13237},
        },
        [13265] = {
            [questKeys.requiredSpell] = -59390,
        },
        [13268] = {
            [questKeys.requiredSpell] = -59390,
        },
        [13269] = {
            [questKeys.requiredSpell] = -59390,
        },
        [13270] = {
            [questKeys.requiredSpell] = -59390,
        },
        [13272] = {
            [questKeys.requiredSpell] = -59390,
        },
        [13276] = {
            [questKeys.objectives] = {{{31142,"Icy Ghouls Exploded"},{31147,"Vicious Geists Exploded"},{31205,"Risen Alliance Soldiers Exploded"}}},
            [questKeys.preQuestSingle] = {13264},
        },
        [13277] = {
            [questKeys.preQuestSingle] = {13237},
        },
        [13278] = {
            [questKeys.preQuestSingle] = {13277},
        },
        [13279] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Pustulant Spinal Fluid"), 0, {{"object", 193580}}}},
        },
        [13280] = {
            [questKeys.preQuestSingle] = {13296},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant Alliance Battle Standard"), 0, {{"object", 193565}}}},
        },
        [13281] = {
            [questKeys.preQuestSingle] = {13279},
        },
        [13283] = {
            [questKeys.preQuestSingle] = {13293},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant Horde Battle Standard"), 0, {{"object", 193565}}}},
        },
        [13284] = {
            [questKeys.preQuestSingle] = {13341},
        },
        [13286] = {
            [questKeys.preQuestSingle] = {13231},
        },
        [13288] = {
            [questKeys.objectives] = {{{31142,"Icy Ghouls Exploded"},{31147,"Vicious Geists Exploded"},{31205,"Risen Alliance Soldiers Exploded"}}},
            [questKeys.preQuestSingle] = {13287},
        },
        [13289] = {
            [questKeys.objectives] = {{{31142,"Icy Ghouls Exploded"},{31147,"Vicious Geists Exploded"},{31205,"Risen Alliance Soldiers Exploded"}}},
            [questKeys.preQuestSingle] = {13288},
        },
        [13290] = {
            [questKeys.preQuestSingle] = {13231},
        },
        [13292] = {
            [questKeys.preQuestSingle] = {13291},
        },
        [13293] = {
            [questKeys.preQuestSingle] = {13224},
        },
        [13294] = {
            [questKeys.preQuestSingle] = {13287},
        },
        [13296] = {
            [questKeys.preQuestSingle] = {13225},
        },
        [13297] = {
            [questKeys.preQuestSingle] = {13295},
        },
        [13298] = {
            [questKeys.preQuestSingle] = {13294},
        },
        [13300] = {
            [questKeys.objectives] = {{{31397,"Saronite Mine Slave rescued"}}},
            [questKeys.preQuestSingle] = {13225},
        },
        [13301] = {
            [questKeys.preQuestSingle] = {13340},
        },
        [13302] = {
            [questKeys.objectives] = {{{31397,"Saronite Mine Slave rescued"}}},
            [questKeys.preQuestSingle] = {13224},
        },
        [13305] = {
            [questKeys.preQuestSingle] = {13304},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Board Refurbished Demolisher"), 0, {{"monster", 32370}}}},
        },
        [13306] = {
            [questKeys.preQuestSingle] = {13366},
        },
        [13307] = {
            [questKeys.preQuestSingle] = {13306},
        },
        [13308] = {
            [questKeys.preQuestSingle] = {13224,13225},
        },
        [13309] = {
            [questKeys.preQuestSingle] = {13341},
        },
        [13310] = {
            [questKeys.preQuestSingle] = {13340},
        },
        [13312] = {
            [questKeys.preQuestGroup] = {13306,13367},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Rune of Distortion near Grimkor's Orb to summon Grimkor the Wicked"), 0, {{"object", 193622}}}},
        },
        [13313] = {
            [questKeys.preQuestSingle] = {13306},
        },
        [13314] = {
            [questKeys.preQuestSingle] = {13332},
        },
        [13315] = {
            [questKeys.preQuestSingle] = {13288},
        },
        [13316] = {
            [questKeys.preQuestSingle] = {13329},
        },
        [13318] = {
            [questKeys.objectives] = {{{32236,"Dark Subjugator dragged and dropped"}}},
            [questKeys.preQuestSingle] = {13315},
        },
        [13319] = {
            [questKeys.preQuestSingle] = {13315},
        },
        [13320] = {
            [questKeys.preQuestSingle] = {13315},
        },
        [13321] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
        },
        [13322] = {
            [questKeys.preQuestSingle] = {13321},
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
        },
        [13323] = {
            [questKeys.preQuestSingle] = {13318},
        },
        [13328] = {
            [questKeys.preQuestSingle] = {13329},
        },
        [13329] = {
            [questKeys.objectives] = {{{32467,"Skeletal Reaver bones dissolved"}}},
            [questKeys.preQuestGroup] = {13307,13312},
        },
        [13330] = {
            [questKeys.preQuestSingle] = {13224},
        },
        [13331] = {
            [questKeys.preQuestSingle] = {13313},
        },
        [13332] = {
            [questKeys.preQuestSingle] = {13345},
        },
        [13333] = {
            [questKeys.preQuestSingle] = {13314},
        },
        [13334] = {
            [questKeys.preQuestSingle] = {13332},
        },
        [13335] = {
            [questKeys.objectives] = {{{32467,"Skeletal Reaver bones dissolved"}}},
            [questKeys.preQuestGroup] = {13334,13337},
        },
        [13336] = {
            [questKeys.preQuestSingle] = {13225},
        },
        [13337] = {
            [questKeys.preQuestGroup] = {13332,13346},
        },
        [13338] = {
            [questKeys.preQuestSingle] = {13335},
        },
        [13339] = {
            [questKeys.preQuestSingle] = {13335},
        },
        [13340] = {
            [questKeys.preQuestSingle] = {13224},
        },
        [13341] = {
            [questKeys.preQuestSingle] = {13225},
        },
        [13342] = {
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13318},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 400015}}}},
        },
        [13343] = {
            [questKeys.triggerEnd] = {"Hourglass of Eternity protected from the Infinite Dragonflight.",{[zoneIDs.DRAGONBLIGHT]={{71.74,39.17,},},},},
        },
        [13344] = {
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13342},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 400015}}}},
        },
        [13345] = {
            [questKeys.preQuestSingle] = {13318},
        },
        [13346] = {
            [questKeys.preQuestSingle] = {13345},
        },
        [13347] = {
            [questKeys.preQuestSingle] = {12499},
        },
        [13350] = {
            [questKeys.preQuestSingle] = {13346},
        },
        [13351] = {
            [questKeys.preQuestSingle] = {13264},
        },
        [13352] = {
            [questKeys.objectives] = {{{32236,"Dark Subjugator dragged and dropped"}}},
            [questKeys.preQuestSingle] = {13351},
        },
        [13353] = {
            [questKeys.objectives] = {{{32236,"Dark Subjugator dragged and dropped"}}},
            [questKeys.preQuestSingle] = {13352},
        },
        [13354] = {
            [questKeys.preQuestSingle] = {13351},
        },
        [13355] = {
            [questKeys.preQuestSingle] = {13351},
        },
        [13356] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
        },
        [13357] = {
            [questKeys.preQuestSingle] = {13356},
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
        },
        [13358] = {
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13352},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 400015}}}},
        },
        [13359] = {
            [questKeys.preQuestSingle] = {13348},
            [questKeys.nextQuestInChain] = 13360,
        },
        [13360] = {
            [questKeys.preQuestSingle] = {13359},
        },
        [13361] = {
            [questKeys.objectives] = {{{32588,"The Prince's Destiny"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Pick it up"), 0, {{"object", 193980},{"object", 194023},{"object", 194024}}}},
        },
        [13363] = {
            [questKeys.preQuestSingle] = {13362},
        },
        [13365] = {
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13358},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 400015}}}},
        },
        [13366] = {
            [questKeys.preQuestSingle] = {13352},
        },
        [13368] = {
            [questKeys.preQuestSingle] = {13367},
        },
        [13372] = {
            [questKeys.startedBy] = {{15989},nil,{44569}},
        },
        [13373] = {
            [questKeys.objectives] = {{{32769},{32771}},nil,nil,nil,{{{32770,32772},32770}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Rizzy Ratchwiggle"), 0, {{"monster", 31839}}}},
        },
        [13375] = {
            [questKeys.startedBy] = {{15989},nil,{44577}},
        },
        [13376] = {
            [questKeys.preQuestSingle] = {13373},
        },
        [13377] = {
            [questKeys.triggerEnd] = {"Assist King Varian Wrynn",{[zoneIDs.UNDERCITY]={{53.75,89.96,},},},},
        },
        [13379] = {
            [questKeys.preQuestSingle] = {13239},
        },
        [13380] = {
            [questKeys.objectives] = {{{32769},{32771}},nil,nil,nil,{{{32770,32772},32770}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Karen No"), 0, {{"monster", 31648}}}},
        },
        [13382] = {
            [questKeys.preQuestSingle] = {13380},
        },
        [13383] = {
            [questKeys.preQuestSingle] = {13291},
        },
        [13394] = {
            [questKeys.preQuestSingle] = {13393},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Board Refurbished Demolisher"), 0, {{"monster", 32370}}}},
        },
        [13395] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31254,32414,31276},31329}}},
        },
        [13398] = {
            [questKeys.preQuestSingle] = {13396},
        },
        [13400] = {
            [questKeys.objectives] = {{{32588,"The Prince's Destiny"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Pick it up"), 0, {{"object", 193980},{"object", 194023},{"object", 194024}}}},
        },
        [13404] = {
            [questKeys.preQuestSingle] = {13380},
        },
        [13405] = {
            [questKeys.triggerEnd] = {"Victory in Strand of the Ancients", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [13406] = {
            [questKeys.preQuestSingle] = {13373},
        },
        [13407] = {
            [questKeys.triggerEnd] = {"Victory in Strand of the Ancients", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [13409] = {
            [questKeys.preQuestSingle] = {10124},
        },
        [13410] = {
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [13411] = {
            [questKeys.preQuestSingle] = {10124},
        },
        [13420] = {
            [questKeys.startedBy] = {nil,{193997},{44725}},
            [questKeys.requiredMinRep] = {1119,3000},
        },
        [13422] = {
            [questKeys.preQuestSingle] = {12906},
            [questKeys.objectives] = {{{30146,"Exhausted Vrykul Disciplined"}}},
            [questKeys.exclusiveTo] = {13423,13424,13425},
        },
        [13423] = {
            [questKeys.preQuestSingle] = {12971},
            [questKeys.exclusiveTo] = {13422,13424,13425},
        },
        [13424] = {
            [questKeys.preQuestSingle] = {12997},
            [questKeys.exclusiveTo] = {13422,13423,13425},
        },
        [13425] = {
            [questKeys.preQuestSingle] = {12925},
            [questKeys.exclusiveTo] = {13422,13423,13424},
        },
        [13426] = {
            [questKeys.preQuestSingle] = {13285},
            [questKeys.nextQuestInChain] = 13034,
        },
        [13427] = {
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [13428] = {
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [13429] = {
            [questKeys.triggerEnd] = {"Help Akama and Maiev enter the Black Temple.",{[zoneIDs.SHADOWMOON_VALLEY]={{71.02,46.12,},},},},
        },
        [13430] = {
            [questKeys.exclusiveTo] = {10888},
            [questKeys.preQuestSingle] = {10588},
        },
        [13431] = {
            [questKeys.exclusiveTo] = {10901},
        },
        [13432] = {
            [questKeys.exclusiveTo] = {10445},
        },
        [13433] = {
            [questKeys.startedBy] = {nil,{400041}},
            [questKeys.finishedBy] = {nil,{400041}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13434] = {
            [questKeys.startedBy] = {nil,{400042}},
            [questKeys.finishedBy] = {nil,{400042}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13435] = {
            [questKeys.startedBy] = {nil,{400040}},
            [questKeys.finishedBy] = {nil,{400040}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13436] = {
            [questKeys.startedBy] = {nil,{400046}},
            [questKeys.finishedBy] = {nil,{400046}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13437] = {
            [questKeys.startedBy] = {nil,{400045}},
            [questKeys.finishedBy] = {nil,{400045}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13438] = {
            [questKeys.startedBy] = {nil,{400043}},
            [questKeys.finishedBy] = {nil,{400043}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13439] = {
            [questKeys.startedBy] = {nil,{400044}},
            [questKeys.finishedBy] = {nil,{400044}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13448] = {
            [questKeys.startedBy] = {nil,{400037}},
            [questKeys.finishedBy] = {nil,{400037}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13452] = {
            [questKeys.startedBy] = {nil,{400023}},
            [questKeys.finishedBy] = {nil,{400023}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13456] = {
            [questKeys.startedBy] = {nil,{400025}},
            [questKeys.finishedBy] = {nil,{400025}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13459] = {
            [questKeys.startedBy] = {nil,{400026}},
            [questKeys.finishedBy] = {nil,{400026}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13460] = {
            [questKeys.startedBy] = {nil,{400028}},
            [questKeys.finishedBy] = {nil,{400028}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13461] = {
            [questKeys.startedBy] = {nil,{400033}},
            [questKeys.finishedBy] = {nil,{400033}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13462] = {
            [questKeys.startedBy] = {nil,{400034}},
            [questKeys.finishedBy] = {nil,{400034}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13464] = {
            [questKeys.startedBy] = {nil,{400020}},
            [questKeys.finishedBy] = {nil,{400020}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13465] = {
            [questKeys.startedBy] = {nil,{400022}},
            [questKeys.finishedBy] = {nil,{400022}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13466] = {
            [questKeys.startedBy] = {nil,{400021}},
            [questKeys.finishedBy] = {nil,{400021}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13467] = {
            [questKeys.startedBy] = {nil,{400029}},
            [questKeys.finishedBy] = {nil,{400029}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13468] = {
            [questKeys.startedBy] = {nil,{400030}},
            [questKeys.finishedBy] = {nil,{400030}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13469] = {
            [questKeys.startedBy] = {nil,{400027}},
            [questKeys.finishedBy] = {nil,{400027}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13470] = {
            [questKeys.startedBy] = {nil,{400024}},
            [questKeys.finishedBy] = {nil,{400024}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13471] = {
            [questKeys.startedBy] = {nil,{400035}},
            [questKeys.finishedBy] = {nil,{400035}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13473] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13474] = {
            [questKeys.startedBy] = {nil,{194081}},
            [questKeys.finishedBy] = {nil,{194081}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13501] = {
            [questKeys.startedBy] = {nil,{400031}},
            [questKeys.finishedBy] = {nil,{400031}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13548] = {
            [questKeys.startedBy] = {nil,{400036}},
            [questKeys.finishedBy] = {nil,{400036}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13549] = {
            [questKeys.objectives] = {{{29327,"Female Frost Leopards recovered"},{29319,"Female Icepaw Bears recovered"},},nil,nil,nil,},
        },
        [13559] = {
            [questKeys.requiredMinRep] = {1119,3000},
        },
        [13600] = {
            [questKeys.exclusiveTo] = {13603,13616},
        },
        [13603] = {
            [questKeys.exclusiveTo] = {13600,13616},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13607] = {
            [questKeys.triggerEnd] = {"Entrance to Celestial Planetarium located",{[zoneIDs.THE_ARCHIVUM]={{60,46.3}}}},
            [questKeys.preQuestSingle] = {13604},
        },
        [13616] = {
            [questKeys.exclusiveTo] = {13600,13603},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13625] = {
            [questKeys.objectives] = {{{33973,"Use Thrust on Melee Target"},{33974,"Use Shield-Breaker on vulnerable Ranged Target"},{33972,"Use Charge on vulnerable Charge Target"}}},
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
        },
        [13627] = {
            [questKeys.startedBy] = {{33434}},
            [questKeys.finishedBy] = {{33434}},
        },
        [13631] = {
            [questKeys.startedBy] = {{32871},nil,{46052}},
        },
        [13633] = {
            [questKeys.preQuestSingle] = {13668},
        },
        [13634] = {
            [questKeys.preQuestSingle] = {13668},
        },
        [13662] = {
            [questKeys.preQuestSingle] = {7722},
            [questKeys.requiredMinRep] = {59,3000},
            [questKeys.requiredMaxRep] = {59,9000},
        },
        [13664] = {
            [questKeys.preQuestSingle] = {13700,13701},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33870}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Cavin"), 0, {{"monster", 33522}}},
            },
        },
        [13666] = {
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13669] = {
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
        },
        [13670] = {
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13671] = {
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
        },
        [13673] = {
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13674,13675},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13674] = {
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13673,13675},
            [questKeys.parentQuest] = 0,
        },
        [13675] = {
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13673,13674},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13676] = {
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13680},
            [questKeys.parentQuest] = 0,
        },
        [13677] = {
            [questKeys.objectives] = {{{33229,"Use Thrust on Melee Target"},{33243,"Use Shield-Breaker on vulnerable Ranged Target"},{33272,"Use Charge on vulnerable Charge Target"}}},
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13680},
            [questKeys.parentQuest] = 0,
        },
        [13679] = {
            [questKeys.objectives] = {{{33448,"Argent Valiant defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33843}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire David"), 0, {{"monster", 33447}}},
            },
        },
        [13680] = {
            [questKeys.objectives] = {{{33448,"Argent Valiant defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33843}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire David"), 0, {{"monster", 33447}}},
            },
        },
        [13681] = {
            [questKeys.startedBy] = {{33435}},
            [questKeys.finishedBy] = {{33435}},
        },
        [13682] = {
            [questKeys.preQuestSingle] = {13664},
        },
        [13699] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33800}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13713] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33795}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13723] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33793}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13724] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33790}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13725] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33794}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13726] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33799}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13727] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33796}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13728] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33792}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13729] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33798}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13731] = {
            [questKeys.objectives] = {{{30675,"Argent Champion defeated"}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33791}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
        },
        [13741] = {
            [questKeys.exclusiveTo] = {13742,13743},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13742] = {
            [questKeys.exclusiveTo] = {13741,13743},
        },
        [13743] = {
            [questKeys.exclusiveTo] = {13741,13742},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13746] = {
            [questKeys.exclusiveTo] = {13747,13748},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13747] = {
            [questKeys.exclusiveTo] = {13746,13748},
        },
        [13748] = {
            [questKeys.exclusiveTo] = {13746,13747},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13752] = {
            [questKeys.exclusiveTo] = {13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13753] = {
            [questKeys.exclusiveTo] = {13752,13754},
        },
        [13754] = {
            [questKeys.exclusiveTo] = {13752,13753},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13757] = {
            [questKeys.exclusiveTo] = {13758,13759},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13758] = {
            [questKeys.exclusiveTo] = {13757,13759},
        },
        [13759] = {
            [questKeys.exclusiveTo] = {13757,13758},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13762] = {
            [questKeys.exclusiveTo] = {13763,13764},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13763] = {
            [questKeys.exclusiveTo] = {13762,13764},
        },
        [13764] = {
            [questKeys.exclusiveTo] = {13762,13763},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13767] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33799}}}},
        },
        [13768] = {
            [questKeys.exclusiveTo] = {13769,13770},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13769] = {
            [questKeys.exclusiveTo] = {13768,13770},
        },
        [13770] = {
            [questKeys.exclusiveTo] = {13768,13769},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13772] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33796}}}},
        },
        [13773] = {
            [questKeys.exclusiveTo] = {13774,13775},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13774] = {
            [questKeys.exclusiveTo] = {13773,13775},
        },
        [13775] = {
            [questKeys.exclusiveTo] = {13773,13774},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13777] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33792}}}},
        },
        [13778] = {
            [questKeys.exclusiveTo] = {13779,13780},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13779] = {
            [questKeys.exclusiveTo] = {13778,13780},
        },
        [13780] = {
            [questKeys.exclusiveTo] = {13778,13779},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13782] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33798}}}},
        },
        [13783] = {
            [questKeys.exclusiveTo] = {13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
        },
        [13784] = {
            [questKeys.exclusiveTo] = {13783,13785},
        },
        [13785] = {
            [questKeys.exclusiveTo] = {13783,13784},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13787] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33791}}}},
        },
        [13788] = {
            [questKeys.preQuestSingle] = {13664},
        },
        [13789] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29717,31145,31731,31738,32236,32238,32250,32259,32262,32263,32268,32276,32279,32285,32289,32290,32291,32297,32300,32349,33537,35127,35297},35297,"Cult of the Damned member slain"}}},
            [questKeys.preQuestSingle] = {13700},
        },
        [13790] = {
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33794},{"monster", 33800},{"monster", 33793},{"monster", 33795},{"monster", 33790}}}},
        },
        [13791] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29717,31145,31731,31738,32236,32238,32250,32259,32262,32263,32268,32276,32279,32285,32289,32290,32291,32297,32300,32349,33537,35127,35297},35297,"Cult of the Damned member slain"}}},
            [questKeys.preQuestSingle] = {13700},
        },
        [13793] = {
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33794},{"monster", 33800},{"monster", 33793},{"monster", 33795},{"monster", 33790}}}},
        },
        [13795] = {
            [questKeys.preQuestSingle] = {13702,13732,13733,13734,13735,13736,13737,13738,13739,13740},
        },
        [13809] = {
            [questKeys.preQuestSingle] = {13664},
        },
        [13810] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29717,31145,31731,31738,32236,32238,32250,32259,32262,32263,32268,32276,32279,32285,32289,32290,32291,32297,32300,32349,33537,35127,35297},35297,"Cult of the Damned member slain"}}},
            [questKeys.preQuestSingle] = {13701},
        },
        [13811] = {
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33796},{"monster", 33798},{"monster", 33799},{"monster", 33791},{"monster", 33792}}}},
        },
        [13812] = {
            [questKeys.preQuestSingle] = {13664},
        },
        [13813] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29717,31145,31731,31738,32236,32238,32250,32259,32262,32263,32268,32276,32279,32285,32289,32290,32291,32297,32300,32349,33537,35127,35297},35297,"Cult of the Damned member slain"}}},
            [questKeys.preQuestSingle] = {13701},
        },
        [13814] = {
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33796},{"monster", 33798},{"monster", 33799},{"monster", 33791},{"monster", 33792}}}},
        },
        [13816] = {
            [questKeys.triggerEnd] = {"Entrance to Celestial Planetarium located",{[zoneIDs.THE_ARCHIVUM]={{60,46.3}}}},
            [questKeys.preQuestSingle] = {13817},
        },
        [13817] = {
            [questKeys.preQuestSingle] = {},
        },
        [13819] = {
            [questKeys.startedBy] = {{32871},nil,{46053}},
        },
        [13820] = {
            [questKeys.startedBy] = {{33817}},
            [questKeys.finishedBy] = {{33434}},
            [questKeys.exclusiveTo] = {13627},
        },
        [13825] = {
            [questKeys.startedBy] = {{8125}},
            [questKeys.finishedBy] = {{8125}},
            -- [questKeys.exclusiveTo] = {6610}, -- This is not ideal. You can only do 13825 if you completed 6610 prior to Wotlk. But now with Wotlk you do 6610 and then can not do 13825
            [questKeys.requiredSkill] = {185,225},
        },
        [13826] = {
            [questKeys.startedBy] = {{12919}},
            [questKeys.finishedBy] = {{12919}},
            -- [questKeys.exclusiveTo] = {6607}, -- This is not ideal. You can only do 13826 if you completed 6607 prior to Wotlk. But now with Wotlk you do 6607 and then can not do 13826
            [questKeys.requiredSkill] = {356,225},
        },
        [13828] = {
            [questKeys.objectives] = {{{33973,"Jeran Lockwood's advice"},{33229,"Use Thrust on Melee Target"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13829] = {
            [questKeys.objectives] = {{{33973,"Jeran Lockwood's advice"},{33229,"Use Thrust on Melee Target"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13830] = {
            [questKeys.triggerEnd] = {"Discover the Ghostfish mystery",{[zoneIDs.SHOLAZAR_BASIN]={{48.89,62.29,},},},},
        },
        [13832] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_UNDERBELLY]={{46,68}}}, Questie.ICON_TYPE_EVENT, l10n("Fish for Corroded Jewelry")}},
        },
        [13833] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.BOREAN_TUNDRA]={{57.5,33.2},{62.2,64.2},{45,45}}}, Questie.ICON_TYPE_SLAY, l10n("Slay any beast, jump in any water location and fish in the Pool of Blood"), 0}},
        },
        [13834] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.WINTERGRASP]={{70,36},{63,60},{50,44},{37.6,36},{56,66},{42,75},{34.7,19.5}}}, Questie.ICON_TYPE_EVENT, l10n("Fish for Terror Fish"), 0}},
        },
        [13835] = {
            [questKeys.objectives] = {{{33974,"Valis Windchaser's advice"},{33243,"Use Shield-Breaker on vulnerable Ranged Target"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13836] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DALARAN]={{64,64}}}, Questie.ICON_TYPE_EVENT, l10n("Fish for Severed Arm")}},
        },
        [13837] = {
            [questKeys.objectives] = {{{33972,"Rugan Steelbelly's advice"},{33272,"Charge vulnerable Charge Target"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13838] = {
            [questKeys.objectives] = {{{33974,"Valis Windchaser's advice"},{33243,"Use Shield-Breaker on vulnerable Ranged Target"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13839] = {
            [questKeys.objectives] = {{{33972,"Rugan Steelbelly's advice"},{33272,"Charge vulnerable Charge Target"}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13843] = {
            [questKeys.startedBy] = {nil,{191761}},
            [questKeys.finishedBy] = {nil,{191761}},
            [questKeys.preQuestSingle] = {12889},
            [questKeys.requiredSkill] = {profKeys.ENGINEERING,400},
        },
        [13846] = {
            [questKeys.preQuestSingle] = {13700,13701},
            [questKeys.requiredMaxRep] = {1106,42000},
        },
        [13847] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13850] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Melee attack Venomhide Ravasaur"), 0, {{"monster", 6508}}}},
        },
        [13851] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13852] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13854] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13855] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13856] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13857] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13858] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13859] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13860] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13861] = {
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13862] = {
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13863] = {
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13864] = {
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13887] = {
            [questKeys.preQuestSingle] = {13850},
        },
        [13906] = {
            [questKeys.preQuestSingle] = {13887},
        },
        [13929] = {
            [questKeys.triggerEnd] = {"Roo taken to visit Grizzlemaw", {[zoneIDs.GRIZZLY_HILLS]={{50.7,43.9}}}}, -- oracle orphan
            [questKeys.preQuestSingle] = {13926},
            [questKeys.exclusiveTo] = {13927},
        },
        [13930] = {
            [questKeys.triggerEnd] = {"Keken taken to visit Grizzlemaw", {[zoneIDs.GRIZZLY_HILLS]={{50.7,43.9}}}}, -- wolvar orphan
            [questKeys.preQuestSingle] = {13927},
            [questKeys.exclusiveTo] = {13926},
        },
        [13933] = {
            [questKeys.triggerEnd] = {"Roo taken to visit Bronze Dragonshrine", {[zoneIDs.DRAGONBLIGHT]={{72,39}}}}, -- oracle orphan
            [questKeys.preQuestSingle] = {13926},
            [questKeys.exclusiveTo] = {13927},
        },
        [13934] = {
            [questKeys.triggerEnd] = {"Keken taken to visit Bronze Dragonshrine", {[zoneIDs.DRAGONBLIGHT]={{72,39}}}}, -- wolvar orphan
            [questKeys.preQuestSingle] = {13927},
            [questKeys.exclusiveTo] = {13926},
        },
        [13937] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Buy a Small Paper Zeppelin"), 0, {{"monster", 29478}}}},
            [questKeys.objectives] = {{{33533,"Throw Small Paper Zeppelin to Roo"},},nil,nil,nil,},
            [questKeys.preQuestGroup] = {13954,13956},
            [questKeys.nextQuestInChain] = 13959,
            [questKeys.exclusiveTo] = {13927},
        },
        [13938] = {
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Buy a Small Paper Zeppelin"), 0, {{"monster", 29478}}}},
            [questKeys.objectives] = {{{33532,"Throw Small Paper Zeppelin to Kekek"},},nil,nil,nil,},
            [questKeys.preQuestGroup] = {13955,13957},
            [questKeys.nextQuestInChain] = 13960,
            [questKeys.exclusiveTo] = {13926},
        },
        [13950] = {
            [questKeys.triggerEnd] = {"Roo taken to visit Winterfin Retreat", {[zoneIDs.BOREAN_TUNDRA]={{43.5,13.6}}}}, -- oracle orphan
            [questKeys.preQuestSingle] = {13926},
            [questKeys.exclusiveTo] = {13927},
        },
        [13951] = {
            [questKeys.triggerEnd] = {"Keken taken to visit Snowfall Glade", {[zoneIDs.DRAGONBLIGHT]={{46,61},{44,70}}}}, -- wolvar orphan
            [questKeys.preQuestSingle] = {13927},
            [questKeys.exclusiveTo] = {13926},
        },
        [13954] = {
            [questKeys.triggerEnd] = {"Roo taken to visit Alexstrasza the Life-Binder", {[zoneIDs.DRAGONBLIGHT]={{59.8,54.5}}}}, -- oracle orphan
            [questKeys.preQuestGroup] = {13929,13933,13950},
            [questKeys.exclusiveTo] = {13927},
        },
        [13955] = {
            [questKeys.triggerEnd] = {"Keken taken to visit Alexstrasza the Life-Binder", {[zoneIDs.DRAGONBLIGHT]={{59.8,54.5}}}}, -- wolvar orphan
            [questKeys.preQuestGroup] = {13930,13934,13951},
            [questKeys.exclusiveTo] = {13926},
        },
        [13956] = {
            [questKeys.triggerEnd] = {"Roo taken to visit The Etymidian", {[zoneIDs.UN_GORO_CRATER]={{47.38,9.21}}}}, -- oracle orphan
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{40.3,83.3}}}, Questie.ICON_TYPE_EVENT, l10n("Use the waygate to teleport to Un'goro Crater")}},
            [questKeys.preQuestGroup] = {13929,13933,13950},
            [questKeys.exclusiveTo] = {13927},
        },
        [13957] = {
            [questKeys.triggerEnd] = {"Keken taken to visit Hemet Nesingwary", {[zoneIDs.SHOLAZAR_BASIN]={{27.1,58.8}}}}, -- wolvar orphan
            [questKeys.preQuestGroup] = {13930,13934,13951},
            [questKeys.exclusiveTo] = {13926},
        },
        [13959] = {
            [questKeys.preQuestSingle] = {13937},
            [questKeys.exclusiveTo] = {13927},
        },
        [13960] = {
            [questKeys.preQuestSingle] = {13938},
            [questKeys.exclusiveTo] = {13926},
        },
        [14023] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14024] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14028] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14030] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14033] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14035] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14037] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14040] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14041] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14043] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14044] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14047] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14048] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14051] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14053] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14054] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14055] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14058] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14059] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14060] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14061] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14062] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14064] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14065] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14079] = {
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [14081] = {
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [14082] = {
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [14083] = {
            [questKeys.requiredRaces] = raceIDs.DWARF,
        },
        [14084] = {
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [14085] = {
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [14086] = {
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [14087] = {
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [14088] = {
            [questKeys.requiredRaces] = raceIDs.TROLL,
        },
        [14089] = {
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14163] = {
            [questKeys.triggerEnd] = {"Victory in the Isle of Conquest", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [14164] = {
            [questKeys.triggerEnd] = {"Victory in the Isle of Conquest", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [14178] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [14179] = {
            [questKeys.triggerEnd] = {"Victory in the Eye of the Storm", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [14180] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [14181] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [14182] = {
            [questKeys.triggerEnd] = {"Victory in Eye of the Storm", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [14183] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [14352] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [14418] = {
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14419] = {
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14420] = {
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14421] = {
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [24216] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [24217] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [24218] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [24219] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [24220] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [24221] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [24223] = {
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [24224] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [24225] = {
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [24426] = {
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.SHATTRATH_CITY]={{66.85,57.04}},
                [zoneIDs.ORGRIMMAR]={{79.09,31.1}},
                [zoneIDs.THUNDER_BLUFF]={{56.05,76.69}},
                [zoneIDs.UNDERCITY]={{60.67,87.66}},
                [zoneIDs.DALARAN]={{58.3,20.5}},
            }},
        },
        [24427] = {
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.SHATTRATH_CITY]={{67.38,33.8}},
                [zoneIDs.STORMWIND_CITY]={{82.45,12.92}},
                [zoneIDs.IRONFORGE]={{70.12,89.41}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.58,50.04}},
                [zoneIDs.DALARAN]={{29.8,75.7}},
            }},
        },
        [24431] = {
            [questKeys.specialFlags] = 1,
        },
        [24536] = {
            [questKeys.objectives] = {{{3296}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Snagglebolt's Air Analyzer on perfumed guards"), 0, {{"monster", 3296}}}},
        },
        [24541] = {
            [questKeys.sourceItemId] = 49867,
        },
        [24597] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24609] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24610] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24611] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24612] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24613] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24614] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24615] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        -- Hackfix to hide the other two as a available once one of the random three dailies has been accepted
        [24629] = {
            [questKeys.exclusiveTo] = {24635, 24636},
        },
        [24635] = {
            [questKeys.exclusiveTo] = {24629, 24636},
        },
        [24636] = {
            [questKeys.exclusiveTo] = {24629, 24635},
        },
        [24638] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24645, 24647, 24648, 24649, 24650, 24651, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400048}}}},
        },
        [24645] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24647, 24648, 24649, 24650, 24651, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400049}}}},
        },
        [24647] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24648, 24649, 24650, 24651, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400052}}}},
        },
        [24648] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24649, 24650, 24651, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400053}}}},
        },
        [24649] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24650, 24651, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400054}}}},
        },
        [24650] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24649, 24651, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400055}}}},
        },
        [24651] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24649, 24650, 24652},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400056}}}},
        },
        [24652] = {
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24649, 24650, 24651},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400057}}}},
        },
        [24655] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{68,1976},1976}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Snagglebolt's Air Analyzer on perfumed guards"), 0, {{"monster", 68},{"monster", 1976}}}},
        },
        [24656] = {
            [questKeys.sourceItemId] = 49867,
        },
        [24658] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24659, 24660, 24662, 24663, 24664, 24665, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400050}}}},
        },
        [24659] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24660, 24662, 24663, 24664, 24665, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400051}}}},
        },
        [24660] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24662, 24663, 24664, 24665, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400052}}}},
        },
        [24662] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24663, 24664, 24665, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400053}}}},
        },
        [24663] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24664, 24665, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400054}}}},
        },
        [24664] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24663, 24665, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400055}}}},
        },
        [24665] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24663, 24664, 24666},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400056}}}},
        },
        [24666] = {
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24663, 24664, 24665},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Chemical Wagon using Snagglebolt's Khorium Bomb"), 0, {{"object", 400057}}}},
        },
        [24792] = {
            [questKeys.preQuestSingle] = {24657},
        },
        [24793] = {
            [questKeys.preQuestSingle] = {24576},
        },
        [24803] = {
            [questKeys.specialFlags] = 1,
        },
        [24857] = {
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
    }
end
