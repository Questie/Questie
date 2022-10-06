---@class QuestieWotlkQuestFixes
local QuestieWotlkQuestFixes = QuestieLoader:CreateModule("QuestieWotlkQuestFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


QuestieCorrections.killCreditObjectiveFirst[12546] = true
QuestieCorrections.killCreditObjectiveFirst[12561] = true
QuestieCorrections.killCreditObjectiveFirst[12762] = true
QuestieCorrections.killCreditObjectiveFirst[12919] = true
QuestieCorrections.killCreditObjectiveFirst[13373] = true
QuestieCorrections.killCreditObjectiveFirst[13380] = true

function QuestieWotlkQuestFixes:Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local zoneIDs = ZoneDB.zoneIDs
    local sortKeys = QuestieDB.sortKeys

    return {
        [236] = {
            [questKeys.exclusiveTo] = {13154,13156,},
        },
        [1198] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4740] = {
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [7800] = {
            [questKeys.preQuestSingle] = {},
        },
        [8150] = {
            [questKeys.requiredSourceItems] = {}, -- Overriding Classic correction
            [questKeys.triggerEnd] = {"Place a tribute at Grom's Monument",{[zoneIDs.ASHENVALE]={{83,78,},},},},
        },
        [9154] = {
            [questKeys.startedBy] = {{16241,16255}},
            [questKeys.finishedBy] = {{16281}},
            [questKeys.questLevel] = -1,
        },
        [9247] = {
            [questKeys.finishedBy] = {{16281}},
        },
        [9648] = {
            [questKeys.name] = "Maatparm Mushroom Menagerie",
        },
        [10110] = {
            [questKeys.preQuestSingle] = {13409},
        },
        [10173] = {
            [questKeys.requiredSourceItems] = {},
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
        [11120] = {
            [questKeys.startedBy] = {{24657}},
            [questKeys.finishedBy] = {{24657}},
        },
        [11153] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{28.1,42,2}}}, ICON_TYPE_EVENT, l10n("Wait for Harrowmeiser's zeppelin to dock"),}},
        },
        [11154] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Throw the firecrackers up to 20 yards away underneath a darkclaw bat to scare it"), 0, {{"monster", 23959}}}},
        },
        [11157] = {
            [questKeys.objectives] = {{{23777,"Proto-Drake Egg destroyed"}},nil,nil,nil,{{{23688,23750},23688}}},
        },
        [11170] = {
            [questKeys.objectives] = {{{24120,"North Fleet Reservist Infected"}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Bat Handler Camille"), 0, {{"monster", 23816}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Present the Vrykul Scroll of Ascension"), 0, {{"object", 186586}}}},
        },
        [11252] = {
            [questKeys.preQuestSingle] = {},
        },
        [11257] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23661,23662,23663,23664,23665,23666,23667,23668,23669,23670},23661,"Winterskorn Vrykul Dismembered"}}},
        },
        [11279] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Spray Proto-Drake Egg"), 0, {{"monster", 23777}}}},
        },
        [11280] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Place Tillinghast's Plagued Meat on the ground"), 0, {{"monster", 24170}}}},
        },
        [11281] = {
            [questKeys.objectives] = {{{24173}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Slay Frostgore"), 0, {{"monster", 24173}}}},
        },
        [11282] = {
            [questKeys.objectives] = {{{24161,"Oric the Baleful's Corpse Impaled"},{24016,"Ulf the Bloodletter's Corpse Impaled"},{24162,"Gunnar Thorvardsson's Corpse Impaled"}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Slay Vrykul across the Forsaken blockade until they appear"), 0, {{"monster", 24015}}}},
        },
        [11296] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Break Riven Widow Cocoons to free captives"), 0, {{"monster", 24210}}}},
        },
        [11301] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_LOOT, l10n("Use Grick's Bonesaw on corpses of Deranged Explorers"), 0, {{"monster", 23967}}}},
        },
        [11302] = {
            [questKeys.preQuestSingle] = {11269,11329},
        },
        [11306] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.HOWLING_FJORD]={{53.65,66.50},},}, ICON_TYPE_OBJECT, l10n("Fill the Empty Apothecary's Flask at the Cauldron of Vrykul Blood"),0},
                {{[zoneIDs.HOWLING_FJORD]={{53.49,66.23},},}, ICON_TYPE_OBJECT, l10n("Mix the Flask of Vrykul Blood with Harris's Plague Samples"),1},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Rune Sample"), 0, {{"object", 186718},}}},
        },
        [11365] = {
            [questKeys.objectives] = {{{24329,"Runed Stone Giant Corpse Analyzed"},},nil,nil,nil,},
        },
        [11366] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Rune Sample"), 0, {{"object", 186718},}}},
        },
        [11393] = {
            [questKeys.exclusiveTo] = {11394,},
        },
        [11394] = {
            [questKeys.preQuestSingle] = {},
        },
        [11410] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Fresh Barbfish Bait"), 0, {{"object", 186770},}}},
        },
        [11416] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Touch Talonshrike's Egg"), 0, {{"object", 186814},{"object", 190283},{"object", 190284}}}},
        },
        [11417] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Touch Talonshrike's Egg"), 0, {{"object", 186814},{"object", 190283},{"object", 190284}}}},
        },
        [11418] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Feathered Charm on Steelfeather"), 0, {{"monster", 24514},}}},
        },
        [11420] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{56.6,49,1}}}, ICON_TYPE_EVENT, l10n("Entrance to Utgarde Catacombs"),}},
        },
        [11421] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Commandeer Crykul Harpoon Gun"),0,{{"object",190512}}}},
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
        },
        [11460] = {
            [questKeys.triggerEnd] = {"Fjord Rock Falcon Fed",{[zoneIDs.HOWLING_FJORD]={{75.26,64.91,},},},},
        },
        [11466] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Olga"), 0, {{"monster", 24639}}}},
        },
        [11471] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Fight Jonah"), 0, {{"monster", 24742}}}},
        },
        [11472] = {
            [questKeys.triggerEnd] = {"Reef Bull led to a Reef Cow",{[zoneIDs.HOWLING_FJORD]={{31.16,71.63,},},},},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Lure Reef Bull with Tasty Reef Fish"), 0, {{"monster", 24786}}}},
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
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{37.2,74.8}}}, ICON_TYPE_OBJECT, l10n("Use The Big Gun at the front of the ship to slay Sorlof"),0,{{"monster", 24992}}}},
        },
        [11531] = {
            [questKeys.specialFlags] = 1,
        },
        [11567] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Ask Alanya for transportation"),0,{{"monster", 27933}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Imperean's Primal on Snarlfang's Totem"),0,{{"monster", 25455}}}},
        },
        [11632] = {
            [questKeys.startedBy] = {nil,{187674},{34777}},
        },
        [11652] = {
            [questKeys.triggerEnd] = {"Scourge Leader identified",{[zoneIDs.BOREAN_TUNDRA]={{36.41,63.52,},},},},
        },
        [11653] = {
            [questKeys.objectives] = {{{25432,"Crafty's Blaster Tested"},{25434,"Crafty's Blaster Tested"},},nil,nil,nil,},
        },
        [11664] = {
            [questKeys.triggerEnd] = {"Mootoo Saved",{[zoneIDs.BOREAN_TUNDRA]={{31.19,54.44,},},},},
        },
        [11670] = {
            [questKeys.objectives] = {{{25430,"Warsong Banner Planted in Magmothregar"},},nil,{{34870,nil},},nil,},
        },
        [11671] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_SLAY, l10n("Kill Inquisitor Salrand"), 0, {{"monster", 25584}}},
                {{[zoneIDs.BOREAN_TUNDRA]={{41.8,39.1}}}, ICON_TYPE_EVENT, l10n("Use Beryl Shield Detonator"),},
            },
        },
        [11673] = {
            [questKeys.triggerEnd] = {"Bonker Togglevolt escorted to safety.",{[zoneIDs.BOREAN_TUNDRA]={{53.84,13.85,},},},},
        },
        [11704] = {
            [questKeys.preQuestSingle] = {11708},
        },
        [11705] = {
            [questKeys.triggerEnd] = {"Varidus the Flenser Defeated",{[zoneIDs.BOREAN_TUNDRA]={{35.13,46.32,},},},},
        },
        [11706] = {
            [questKeys.objectives] = {{{25768},{25768,"Nerubian tunnels collapsed"}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use The Horn of Elemental Fury near the southern sinkhole"),0,{{"monster", 25664}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Throw Wolf Bait"),0,{{"monster", 25791}}}},
        },
        [11730] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25753,25758,25752},25753,"Robots reprogrammed"}}},
        },
        [11788] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),0,{{"object", 187984}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),1,{{"object", 187985}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),2,{{"object", 187986}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),3,{{"object", 187987}}},
            },
        },
        [11798] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use The Gearmaster's Manual"),0,{{"object", 190334}}}},
        },
        [11865] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Place fake fur near Caribou Traps"),0,{{"object", 187995},{"object", 187996},{"object", 187997},{"object", 187998},{"object", 187999},{"object", 188000},{"object", 188001},{"object", 188002},{"object", 188003},{"object", 188004},{"object", 188005},{"object", 188006},{"object", 188007},{"object", 188008}}},
            },
        },
        [11878] = {
            [questKeys.triggerEnd] = {"Orphaned Mammoth Calf Delivered to Khu'nok",{[zoneIDs.BOREAN_TUNDRA]={{59.35,30.55,},},},},
        },
        [11881] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Jenny's Whistle near a crashed flying machine"),0,{{"monster", 25845},{"monster", 25846},{"monster", 25847}}},},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Windsoul Totem to collect energy from killing Steam Ragers"),0,{{"monster", 24601}}}},
        },
        [11896] = {
        [questKeys.objectives] = {nil,nil,nil,nil,{{{25752,25753,25758},26082,}}},
        },
        [11899] = {
            [questKeys.objectives] = {{{25814,"Gnome soul captured"},},nil,nil,nil,},
            [questKeys.preQuestSingle] = {11895},
        },
        [11906] = {
            [questKeys.preQuestSingle] = {11895},
        },
        [11907] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),0,{{"object", 187984}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),1,{{"object", 187985}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),2,{{"object", 187986}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Valve"),3,{{"object", 187987}}},
            },
        },
        [11908] = {
            [questKeys.preQuestSingle] = {11902},
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
        [11956] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Ride Dusk"),0,{{"monster", 26191}}}},
        },
        [11957] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Talk to Keristrasza"),0,{{"monster", 26206}}},
                {{[zoneIDs.BOREAN_TUNDRA]={{22,22.6}}}, ICON_TYPE_EVENT, l10n("Use Arcane Power Focus"),},
            },
        },
        [11969] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Raelorasz' Spark"),0,{{"object", 194151}}}},
        },
        [11982] = {
            [questKeys.preQuestSingle] = {},
        },
        [11984] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Enlist Budd's help"), 0, {{"monster", 26422}}},
                {nil, ICON_TYPE_EVENT, l10n("Escort Budd to the Drak' Zin Ruins"), 0, {{"monster", 32663}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use Budd's Tag Troll spell to stun Drakkari trolls"), 0, {{"monster", 26425}, {"monster", 26447}}},
                {nil, ICON_TYPE_OBJECT, l10n("Capture stunned Drakkari trolls with Bounty Hunter's Cage"), 0, {{"monster", 26425}, {"monster", 26447}}},
            },
        },
        [12017] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Tu'u'gwar's Bait"),0,{{"object", 188370}}}},
        },
        [12019] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.BOREAN_TUNDRA]={{86.6,28.6}}}, ICON_TYPE_EVENT, l10n("Teleport to the top of Naxxanar"),},
                {{[zoneIDs.BOREAN_TUNDRA]={{86.6,31.4}}}, ICON_TYPE_TALK, l10n("Talk to Thassarian"),},
            },
        },
        [12027] = {
            [questKeys.triggerEnd] = {"Help Emily and Mr. Floppy return to the camp",{[zoneIDs.GRIZZLY_HILLS]={{53.81,33.33,},},},},
        },
        [12028] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Spiritual insight concerning Indu'le Village attained."), 0, {{"object", 188416}}},
            },
        },
        [12029] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26570},26612,}}},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26570},26612,}}},
        },
        [12039] = {
            [questKeys.preQuestSingle] = {12034},
        },
        [12044] = {
            [questKeys.nextQuestInChain] = 12045,
        },
        [12045] = {
            [questKeys.preQuestSingle] = {12044},
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
        [12056] = {
            [questKeys.preQuestSingle] = {12034},
        },
        [12063] = {
            [questKeys.preQuestSingle] = {12036},
        },
        [12065] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188445}}},
            },
        },
        [12066] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188445}}},
            },
        },
        [12069] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Free Roanauk Icemist"),0,{{"object", 188463}}}},
        },
        [12076] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Zort's Scraper when covered in Corrosive Spit"),0,{{"monster", 26358},{"monster", 26359}}}},
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
                {nil, ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188474}}},
            },
        },
        [12084] = {
            [questKeys.childQuests] = {12096},
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188474}}},
            },
        },
        [12092] = {
            [questKeys.preQuestSingle] = {12065},
        },
        [12095] = {
            [questKeys.preQuestGroup] = {12089,12090,12091},
        },
        [12096] = {
            [questKeys.parentQuest] = 12084,
        },
        [12099] = {
            [questKeys.objectives] = {{{26417,"Runed Giants Freed"}}},
        },
        [12100] = {
            [questKeys.preQuestSingle] = {12034},
        },
        [12107] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Use Ley Line Focus Control Talisman"),0,{{"object", 188491}}},
                {nil, ICON_TYPE_EVENT, l10n("Azure Dragonshrine observed"),0,{{"object", 188474}}},
            },
        },
        [12110] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Use Ley Line Focus Control Talisman"),0,{{"object", 188491}}},
                {nil, ICON_TYPE_EVENT, l10n("Azure Dragonshrine observed"),0,{{"object", 188474}}},
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
                {nil, ICON_TYPE_OBJECT, l10n("Ring the gong outside Drakil'jin to summon Warlord Jin'arrak"),0,{{"object", 188510}}},
                {nil, ICON_TYPE_TALK, l10n("Speak with Gan'jo in the afterlife"),0,{{"monster", 26924}}},
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
        [12135] = {
            [questKeys.triggerEnd] = {"Put Out the Fires",{
                [zoneIDs.AZUREMYST_ISLE]={{49.3,51.5,},},
                [zoneIDs.DUN_MOROGH]={{53.2,51.4,},},
                [zoneIDs.ELWYNN_FOREST]={{43.2,67,},},
            },},
        },
        [12137] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Speak with Gan'jo to return to life"),0,{{"monster", 26924}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use the Snow of Eternal Slumber on ancient Drakkari spirits"),0,{{"monster", 26811},{"monster", 26812}}},
            },
        },
        [12138] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26407,27017},26407,}}},
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_SLAY, l10n("Fight Lightning Sentries with Depleted War Golem deployed nearby"),0,{{"monster", 26407}}},
            },
        },
        [12139] = {
            [questKeys.triggerEnd] = {"Put Out the Fires",{
                [zoneIDs.EVERSONG_WOODS]={{47.3,46.6,},},
                [zoneIDs.DUROTAR]={{52.8,42.6,},},
                [zoneIDs.TIRISFAL_GLADES]={{61,53.5,},},
            },},
        },
        [12150] = {
            [questKeys.objectives] = {{{27003,}}},
        },
        [12152] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Place the Infused Drakkari Offering at the gongs outside Drakil'jin"),0,{{"object", 188510}}},
            },
        },
        [12157] = {
            [questKeys.exclusiveTo] = {12171,12174,12235,12297},
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
                {nil, ICON_TYPE_EVENT, l10n("Intercept the message from Loken"),1,{{"object", 188596}}},
            },
        },
        [12188] = {
            [questKeys.preQuestSingle] = {},
        },
        [12198] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26407,27017},26407,}}},
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_SLAY, l10n("Fight Lightning Sentries with Depleted War Golem deployed nearby"),0,{{"monster", 26407}}},
            },
        },
        [12202] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26408,26409,26410,26414,27177},26408,}}},
        },
        [12203] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Intercept the message from Loken"),1,{{"object", 188596}}},
            },
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27296,27028},27296,}}},
        },
        [12218] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Commandeer a Forsaken Blight Spreader"),1,{{"monster", 26523}}},
            },
        },
        [12224] = {
            [questKeys.preQuestSingle] = {12221,12140,12072},
        },
        [12229] = {
            [questKeys.preQuestGroup] = {12207,12213},
        },
        [12231] = {
            [questKeys.preQuestGroup] = {12207,12213},
        },
        [12232] = {
            [questKeys.objectives] = {nil,{{188673,}}},
        },
        [12236] = {
            [questKeys.preQuestGroup] = {12241,12242},
            [questKeys.objectives] = {{{26633,}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Tur Ragepaw to summon Ursoc"),0,{{"monster", 27328}}}},
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
        [12249] = {
            [questKeys.objectives] = {{{26633,}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Tur Ragepaw to summon Ursoc"),0,{{"monster", 27328}}}},
        },
        [12258] = {
            [questKeys.preQuestSingle] = {12251},
        },
        [12259] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Ride Flamebringer"),0,{{"monster", 27292}}}},
        },
        [12260] = {
            [questKeys.objectives] = {{{27202,}}},
        },
        [12261] = {
            [questKeys.preQuestSingle] = {12447},
            [questKeys.objectives] = {{{27430,}}},
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Use Destructive Ward"),0,{{"object", 188707}}},
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
        [12273] = {
            [questKeys.objectives] = {{{27237,},{27235,},{27234,},{27236,}}},
        },
        [12274] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Use Abbey Bell Rope"),0,{{"object", 188713}}},
                {nil, ICON_TYPE_TALK, l10n("High Abbot spoken with"),1,{{"monster", 27245}}},
            },
        },
        [12288] = {
            [questKeys.objectives] = {{{27463,"Wounded Skirmishers Healed"}}},
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
        [12321] = {
            [questKeys.triggerEnd] = {"Righteous Sermon Heard",{[zoneIDs.DRAGONBLIGHT]={{76.73,47.4,},},},},
        },
        [12327] = {
            [questKeys.triggerEnd] = {"Vision from the Past",{[zoneIDs.SILVERPINE_FOREST]={{46.53,76.18,},},},},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Gossamer Potion"),0,{{"object", 189972}}}},
        },
        [12330] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Tranquilizer Dart on Tatjana"),0,{{"monster", 27627}}}},
            [questKeys.triggerEnd] = {"Tatjana Delivered",{[zoneIDs.GRIZZLY_HILLS]={{57.77,41.7,},},},},
        },
        [12412] = {
            [questKeys.preQuestSingle] = {12259},
        },
        [12415] = {
            [questKeys.objectives] = {{{26472,}}},
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
        [12439] = {
            [questKeys.exclusiveTo] = {11995},
        },
        [12453] = {
            [questKeys.preQuestSingle] = {12412},
            [questKeys.objectives] = {{{26369,}}},
        },
        [12456] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DRAGONBLIGHT]={{64.6,77}}}, ICON_TYPE_EVENT, l10n("Use Skytalon Molts"),0}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Wyrmbait and slay Icestorm"),0,{{"monster", 27843}}},},
        },
        [12470] = {
            [questKeys.triggerEnd] = {"Hourglass of Eternity protected",{[zoneIDs.DRAGONBLIGHT]={{71.57,38.91,},},},},
        },
        [12473] = {
            [questKeys.triggerEnd] = {"Thel'zan the Duskbringer Defeated",{[zoneIDs.DRAGONBLIGHT]={{81.11,50.64,},},},},
        },
        [12481] = {
            [questKeys.objectives] = {{{24238,"Bjorn Halgurdsson insulted"},{24238,"Bjorn Halgurdsson defeated"}}},
        },
        [12484] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.GRIZZLY_HILLS]={{16.84,48.34}}}, ICON_TYPE_EVENT, l10n("Place Scourged Troll Mummy in the fire"),0}},
        },
        [12486] = {
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [12498] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Slay Antiok's mount to make him vulnerable"),0,{{"monster", 28018}}},},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Escort rescued Crusaders to Dr. Rogers"), 0, {{"monster", 28125}}}},
        },
        [12516] = {
            [questKeys.objectives] = {{{28068}}},
        },
        [12520] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12527] = {
            [questKeys.requiredSourceItems] = {38380},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Feed with Zul'Drak Rat"), 0, {{"monster", 28145}}}},
        },
        [12530] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Softknuckle Poker on Softknuckles"), 0, {{"monster", 28127}}}},
        },
        [12532] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12533,12534},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Capture Chicken Escapee"), 0, {{"monster", 28161}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Captive Crocolisk"), 0, {{"monster", 28298}}}},
        },
        [12537] = {
            [questKeys.triggerEnd] = {"Sabotage the Mistwhisper Weather Shrine",{[zoneIDs.SHOLAZAR_BASIN]={{45.23,37.1,},},},},
        },
        [12544] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Soo-rahm's Incense"), 0, {{"object", 190507}}}},
        },
        [12548] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{40.35,83.08,}}}, ICON_TYPE_EVENT, l10n("Travel through the Waygate"),}},
        },
        [12549] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12555] = {
            [questKeys.objectives] = {{{28274,"Plague Sprayers webbed and destroyed"}}},
        },
        [12557] = {
            [questKeys.objectives] = {nil,nil,{{38386},{38339},{38340},{38346}}},
        },
        [12561] = {
            [questKeys.preQuestSingle] = {12803},
        },
        [12569] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Sandfern Disguise near the fallen log"), 0, {{"object", 190545}}}},
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
        [12606] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28415,28413},28415}}},
        },
        [12607] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28379,28374},28379,}}},
        },
        [12620] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{49.64,37.41,}}}, ICON_TYPE_EVENT, l10n("Use Freya's Horn atop of the Glimmering Pillar"),}},
        },
        [12621] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Listen to what the Avatar of Freya has to say"), 0, {{"monster", 27801}}}},
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
        [12633] = {
            [questKeys.startedBy] = {nil,nil,{38673}},
            [questKeys.preQuestSingle] = {12238},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12631},
            [questKeys.nextQuestInChain] = 12638,
        },
        [12634] = {
            [questKeys.preQuestGroup] = {12520,12549},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Pull Sturdy Vines to reveal fruit"), 0, {{"object", 190622}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Eye of Acherus Control Mechanism"), 0, {{"object", 191609}}}},
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
            [questKeys.exclusiveTo] = {12654},
            [questKeys.nextQuestInChain] = 12654,
        },
        [12652] = {
            [questKeys.requiredRaces] = 2047,
            [questKeys.preQuestSingle] = {12629,12643},
            [questKeys.exclusiveTo] = {12713},
            [questKeys.objectives] = {{{28565,}}},
        },
        [12661] = {
            [questKeys.preQuestSingle] = {12648,12649},
            [questKeys.preQuestGroup] = {},
            [questKeys.childQuests] = {12663,12664},
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 12669,
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, ICON_TYPE_EVENT, l10n("Infiltrate Voltarus using Ensorcelled Choker"),},
            },
        },
        [12663] = {
            [questKeys.preQuestSingle] = {12649},
            [questKeys.exclusiveTo] = {12664,12648},
            [questKeys.parentQuest] = 12661,
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Speak to Gorebag and take the tour of Zul'Drak"), 0, {{"monster", 28666}}}},
        },
        [12664] = {
            [questKeys.preQuestSingle] = {12648},
            [questKeys.exclusiveTo] = {12663,12649},
            [questKeys.parentQuest] = 12661,
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Speak to Gorebag and take the tour of Zul'Drak"), 0, {{"monster", 28666}}}},
        },
        [12665] = {
            [questKeys.triggerEnd] = {"Quetz'lun's fate revealed.",{[zoneIDs.ZUL_DRAK]={{75.75,58.39,},},},},
        },
        [12668] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28747,28748},28747,"Trolls killed near a Soul Font"}}},
        },
        [12669] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
            },
        },
        [12671] = {
            [questKeys.triggerEnd] = {"Reconnaissance Flight",{[zoneIDs.SHOLAZAR_BASIN]={{50.04,61.43,},},},},
        },
        [12673] = {
            [questKeys.objectives] = {nil,{{190716}}},
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Use Scepter of Suggestion to mind control Blight Geist"), 0, {{"monster", 28750}}},
            },
        },
        [12674] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Quetz'lun's Hexxing Stick and slay him/her"), 0, {{"monster", 28752},{"monster", 28754},{"monster", 28756}}}},
        },
        [12676] = {
            [questKeys.objectives] = {nil,{{190731},{192767},{190948}}},
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
            },
        },
        [12677] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Complete Overlord Drakuru's task"), 0, {{"monster", 28503}}},
            },
        },
        [12680] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28605,28606,28607},28605,"Horse Successfully Stolen"}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Deliver Stolen Horse"), 0, {{"monster", 28653}}}},
        },
        [12683] = {
            [questKeys.objectives] = {{{28003,},{28003}}},
        },
        [12685] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Quetz'lun's Ritual"), 0, {{"monster", 28672}}}},
        },
        [12686] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_EVENT, l10n("Use Scepter of Empowerment to mind control Servant of Drakuru"), 0, {{"monster", 28802}}},
            },
        },
        [12687] = {
            [questKeys.triggerEnd] = {"The Horseman's Challenge",{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{52.41,34.59,},},},},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Defeat Dark Rider of Acherus and take his horse"), 0, {{"monster", 28768},{"monster", 28782}}}},
        },
        [12688] = {
            [questKeys.triggerEnd] = {"Escort Engineer Helice out of Swindlegrin's Dig",{[zoneIDs.SHOLAZAR_BASIN]={{37.26,50.56,},},},},
        },
        [12690] = {
            [questKeys.objectives] = {{{28844,"Drakkari Skullcrushers Slain"},{28873,"Drakkari Chieftain Lured"},},nil,nil,nil,},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Scepter of Command"), 0, {{"monster", 28843}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Return Scarlet Ghouls"), 0, {{"monster", 28658}}}},
        },
        [12699] = {
            [questKeys.preQuestSingle] = {12523},
        },
        [12701] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Climb inside the Inconspicuous Mine Car"), 0, {{"object", 190767}}},
                {nil, ICON_TYPE_OBJECT, l10n("Use the Scarlet Cannon"), 0, {{"monster", 28833}}},
            },
        },
        [12710] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, ICON_TYPE_EVENT, l10n("Take the teleporter to Drakuru's upper chamber"),},
            },
        },
        [12713] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28503,28998},28503,}}},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, ICON_TYPE_EVENT, l10n("Infiltrate Voltarus using Ensorcelled Choker"),},
            },
        },
        [12720] = {
            [questKeys.triggerEnd] = {"\"Crimson Dawn\" Revealed",{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{55.09,66.12},},},},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_SLAY, l10n("Equip Keleseth's Persuaders and persuade Scarlet Crusaders"), 0, {{"monster", 28610},{"monster", 28936},{"monster", 28939},{"monster", 28940},}}},
        },
        [12721] = {
            [questKeys.triggerEnd] = {"Akali unfettered from his chains.",{[zoneIDs.ZUL_DRAK]={{78.64,25.11,},},},},
        },
        [12723] = {
            [questKeys.preQuestGroup] = {12717,12720,12722},
        },
        [12726] = {
            [questKeys.objectives] = {{{28862,},{28858,}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{26.51,35.63}}}, ICON_TYPE_EVENT, l10n("Use Drums of the Tempest at Stormwright's Shelf"),}},
        },
        [12733] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28391,28394,28406},28391,"Death Knights defeated in a duel"}}},
        },
        [12735] = {
            [questKeys.extraObjectives] = {
                {{[zoneIDs.SHOLAZAR_BASIN]={{43,42}}}, ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Atha"),0},
                {{[zoneIDs.SHOLAZAR_BASIN]={{49,63}}}, ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Ha-Khalan"),1},
                {{[zoneIDs.SHOLAZAR_BASIN]={{46,74}}}, ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Koosu"),2},
            },
        },
        [12740] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28028,28029},28028,}}},
        },
        [12754] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{60.9,75,5}}}, ICON_TYPE_EVENT, l10n("Use the Makeshift Cover"),}},
        },
        [12762] = {
            ---[questKeys.objectives] = {nil,nil,{{39748}},nil,{{{28079,28078},28078,"Frenzyheart Attacker"}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{65.60,59.48}}}, ICON_TYPE_EVENT, l10n("Charge the Dormant Polished Crystal at the exposed Lifeblood Pillar"),}},
        },
        [12779] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{53.5,36.7}}}, ICON_TYPE_EVENT, l10n("Use the Horn of the Frostbrood"),}},
        },
        [12801] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Talk to Highlord Darion Mograine"), 0, {{"monster", 29173}}},
                {{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{38.8,38.4}}}, ICON_TYPE_EVENT, l10n("The Light of Dawn Uncovered"),},
            },
        },
        [12804] = {
            [questKeys.preQuestSingle] = {12520},
        },
        [12805] = {
            [questKeys.objectives] = {{{29124,}}},
        },
        [12813] = {
            [questKeys.preQuestSingle] = {12807},
        },
        [12815] = {
            [questKeys.preQuestSingle] = {12807},
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
        [12856] = {
            [questKeys.objectives] = {{{29639,"Rescued Brunnhildar Prisoners"},{29708,"Freed Proto-Drakes"}}},
        },
        [12864] = {
            [questKeys.triggerEnd] = {"Locate Missing Scout",{[zoneIDs.STORM_PEAKS]={{37.68,66.75},{38.49,77.19},{31.65,64.53},{34.56,64.64},{36.43,77.3},},},},
        },
        [12887] = {
            [questKeys.objectives] = {{{29747,"The Ocular has been destroyed"}}},
        },
        [12892] = {
            [questKeys.objectives] = {{{29747,"The Ocular has been destroyed"}}},
        },
        [12906] = {
            [questKeys.objectives] = {{{30146,"Exhausted Vrykul Disciplined"}}},
        },
        [12919] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_TALK, l10n("Slay Scourge while riding Gymer"), 0, {{"monster", 29647}}},
                {{[zoneIDs.ZUL_DRAK]={{26.71,57.29}}}, ICON_TYPE_EVENT, l10n("Slay Scourge while riding Gymer"),},
            },
        },
        [12932] = {
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
        [12948] = {
            [questKeys.triggerEnd] = {"Vladof the Butcher Defeated",{[zoneIDs.ZUL_DRAK]={{47.98,56.74,},},},},
        },
        [12954] = {
            [questKeys.triggerEnd] = {"Yggdras Defeated",{[zoneIDs.ZUL_DRAK]={{47.93,56.85,},},},},
        },
        [12973] = {
            [questKeys.triggerEnd] = {"Accompany Brann Bronzebeard to Frosthold.",{[zoneIDs.STORM_PEAKS]={{30.2,74.6,},},},},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORM_PEAKS]={{39.6,56.4}}}, ICON_TYPE_EVENT, l10n("Get in Brann Bronzebeard Flying Machine"),}},
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
        },
        [12979] = {
            [questKeys.objectives] = {nil,nil,{{42204},},nil,nil,},
        },
        [12981] = {
            [questKeys.preQuestSingle] = {12967},
        },
        [12985] = {
            [questKeys.preQuestSingle] = {12976},
        },
        [12987] = {
            [questKeys.name] = "Placing Hodir's Helm",
            [questKeys.requiredMinRep] = {1119,3000},
        },
        [12994] = {
            [questKeys.requiredMinRep] = {1119,9000},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Use Ethereal Worg's Fang"), 0, {{"monster", 32569}}}},
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
        [13006] = {
            [questKeys.name] = "A Viscous Cleaning",
            [questKeys.requiredMinRep] = {1119,3000},
        },
        [13008] = {
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30273,30268,30274},30273,}}},
        },
        [13011] = {
            [questKeys.name] = "Culling Jorcuttar",
            [questKeys.requiredSourceItems] = {42733},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORM_PEAKS]={{53.1,61.2}}}, ICON_TYPE_EVENT, l10n("Place Icemaw Bear Flank"), 0}}
        },
        [13039] = {
            [questKeys.preQuestSingle] = {13036},
        },
        [13040] = {
            [questKeys.preQuestSingle] = {13036},
        },
        [13044] = {
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13008,13039,13040},
        },
        [13045] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Mount Argent Skytalon"), 0, {{"monster", 30500}}},
                {{[zoneIDs.ICECROWN]={{86.85,76.61}}}, ICON_TYPE_EVENT, l10n("Drop Off Captured Crusader"), 0},
            },
        },
        [13046] = {
            [questKeys.requiredMinRep] = {1119,21000},
        },
        [13047] = {
            [questKeys.preQuestGroup] = {13035,13005},
            [questKeys.triggerEnd] = {"Witness the Reckoning",{[zoneIDs.STORM_PEAKS]={{36,31.4,},},},},
        },
        [13073] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Speak to Arch Druid Lilliandra for transportation to Moonglade"), 0, {{"monster", 30630}}}},
        },
        [13086] = {
            [questKeys.extraObjectives] = {
                {nil, ICON_TYPE_OBJECT, l10n("Mount Argent Cannon"), 0, {{"monster", 30236}}},
            },
        },
        [13092] = {
            [questKeys.preQuestSingle] = {12999},
        },
        [13093] = {
            [questKeys.preQuestSingle] = {13092},
        },
        [13106] = {
            [questKeys.preQuestSingle] = {12899},
        },
        [13109] = {
            [questKeys.preQuestSingle] = {13047},
        },
        [13110] = {
            [questKeys.objectives] = {{{30202}}},
            [questKeys.preQuestSingle] = {13104},
        },
        [13125] = {
            [questKeys.preQuestGroup] = {13122,13118},
        },
        [13130] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13135] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13139] = {
            [questKeys.preQuestGroup] = {13125,13130,13135},
        },
        [13141] = {
            [questKeys.triggerEnd] = {"Battle for Crusaders' Pinnacle",{[zoneIDs.ICECROWN]={{80.06,71.81,},},},},
        },
        [13118] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13122] = {
            [questKeys.preQuestSingle] = {13104},
        },
        [13136] = {
            [questKeys.objectives] = {nil,nil,{{43259}}},
        },
        [13154] = {
            [questKeys.exclusiveTo] = {236,13156,},
        },
        [13156] = {
            [questKeys.exclusiveTo] = {236,13154,},
        },
        [13168] = {
            [questKeys.triggerEnd] = {"Seize Control of an Eidolon Watcher", {[zoneIDs.ICECROWN]={{44.19,24.69}}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_OBJECT, l10n("Use Eye of Dominion"), 0, {{"object", 193058}}}},
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
            [questKeys.exclusiveTo] = {13193,13194,},
        },
        [13193] = {
            [questKeys.exclusiveTo] = {13191,13194,},
        },
        [13194] = {
            [questKeys.exclusiveTo] = {13191,13193,},
        },
        [13221] = {
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
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
        [13234] = {
            [questKeys.preQuestSingle] = {13228},
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
        [13281] = {
            [questKeys.preQuestSingle] = {13279},
        },
        [13283] = {
            [questKeys.preQuestSingle] = {13293},
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
            [questKeys.preQuestSingle] = {13315},
        },
        [13319] = {
            [questKeys.preQuestSingle] = {13315},
        },
        [13320] = {
            [questKeys.preQuestSingle] = {13315},
        },
        [13322] = {
            [questKeys.preQuestSingle] = {13321},
        },
        [13323] = {
            [questKeys.preQuestSingle] = {13318},
        },
        [13328] = {
            [questKeys.preQuestSingle] = {13329},
        },
        [13329] = {
            [questKeys.preQuestGroup] = {13307,13312},
        },
        [13330] = {
            [questKeys.preQuestSingle] = {13224},
        },
        [13331] = {
            [questKeys.preQuestSingle] = {13313},
        },
        [13333] = {
            [questKeys.preQuestSingle] = {13314},
        },
        [13334] = {
            [questKeys.preQuestSingle] = {13332},
        },
        [13335] = {
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
            [questKeys.preQuestSingle] = {13318},
        },
        [13343] = {
            [questKeys.triggerEnd] = {"Hourglass of Eternity protected from the Infinite Dragonflight.",{[zoneIDs.DRAGONBLIGHT]={{71.74,39.17,},},},},
        },
        [13344] = {
            [questKeys.preQuestSingle] = {13342},
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
            [questKeys.preQuestSingle] = {13351},
        },
        [13353] = {
            [questKeys.preQuestSingle] = {13352},
        },
        [13354] = {
            [questKeys.preQuestSingle] = {13351},
        },
        [13355] = {
            [questKeys.preQuestSingle] = {13351},
        },
        [13357] = {
            [questKeys.preQuestSingle] = {13356},
        },
        [13358] = {
            [questKeys.preQuestSingle] = {13352},
        },
        [13365] = {
            [questKeys.preQuestSingle] = {13352},
        },
        [13366] = {
            [questKeys.preQuestSingle] = {13352},
        },
        [13368] = {
            [questKeys.preQuestSingle] = {13366},
        },
        [13373] = {
            [questKeys.objectives] = {{{32769},{32771}},nil,nil,nil,{{{32770,32772},32770}}},
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Rizzy Ratchwiggle"), 0, {{"monster", 31839}}}},
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
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_TALK, l10n("Talk to Karen No"), 0, {{"monster", 31648}}}},
        },
        [13382] = {
            [questKeys.preQuestSingle] = {13380},
        },
        [13383] = {
            [questKeys.preQuestSingle] = {13291},
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
        [13410] = {
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [13411] = {
            [questKeys.preQuestSingle] = {10124},
        },
        [13420] = {
            [questKeys.startedBy] = {nil,{193997},{44725}},
        },
        [13422] = {
            [questKeys.objectives] = {{{30146,"Exhausted Vrykul Disciplined"}}},
            [questKeys.exclusiveTo] = {13423,13424,13425},
        },
        [13423] = {
            [questKeys.exclusiveTo] = {13422,13424,13425},
        },
        [13424] = {
            [questKeys.exclusiveTo] = {13422,13423,13425},
        },
        [13425] = {
            [questKeys.exclusiveTo] = {13422,13423,13424},
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
        [13549] = {
            [questKeys.objectives] = {{{29327,"Female Frost Leopards recovered"},{29319,"Female Icepaw Bears recovered"},},nil,nil,nil,},
        },
        [13559] = {
            [questKeys.requiredMinRep] = {1119,3000},
        },
        [13830] = {
            [questKeys.triggerEnd] = {"Discover the Ghostfish mystery",{[zoneIDs.SHOLAZAR_BASIN]={{48.89,62.29,},},},},
        },
        [13832] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_UNDERBELLY]={{46,68}}}, ICON_TYPE_EVENT, l10n("Fish for Corroded Jewelry")}},
        },
        [13833] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.BOREAN_TUNDRA]={{57.5,33.2},{62.2,64.2},{45,45}}}, ICON_TYPE_SLAY, l10n("Slay any beast, jump in any water location and fish in the Pool of Blood"), 0}},
        },
        [13834] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.WINTERGRASP]={{70,36},{63,60},{50,44},{37.6,36},{56,66},{42,75},{34.7,19.5}}}, ICON_TYPE_EVENT, l10n("Fish for Terror Fish"), 0}},
        },
        [13836] = {
            [questKeys.extraObjectives] = {{{[zoneIDs.DALARAN]={{64,64}}}, ICON_TYPE_EVENT, l10n("Fish for Severed Arm")}},
        },
        [13850] = {
            [questKeys.extraObjectives] = {{nil, ICON_TYPE_EVENT, l10n("Melee attack Venomhide Ravasaur"), 0, {{"monster", 6508}}}},
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
    }
end
