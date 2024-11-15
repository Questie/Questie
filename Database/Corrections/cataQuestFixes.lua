---@class CataQuestFixes
local CataQuestFixes = QuestieLoader:CreateModule("CataQuestFixes")

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

QuestieCorrections.objectObjectiveFirst[14125] = true
QuestieCorrections.objectObjectiveFirst[24817] = true
QuestieCorrections.objectObjectiveFirst[25371] = true
QuestieCorrections.objectObjectiveFirst[25731] = true
QuestieCorrections.objectObjectiveFirst[25813] = true
QuestieCorrections.objectObjectiveFirst[26659] = true
QuestieCorrections.objectObjectiveFirst[26809] = true
QuestieCorrections.killCreditObjectiveFirst[52] = true
QuestieCorrections.killCreditObjectiveFirst[13798] = true
QuestieCorrections.killCreditObjectiveFirst[25015] = true
QuestieCorrections.killCreditObjectiveFirst[25801] = true
QuestieCorrections.killCreditObjectiveFirst[26621] = true
QuestieCorrections.killCreditObjectiveFirst[26875] = true
QuestieCorrections.killCreditObjectiveFirst[29290] = true

function CataQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceKeys = QuestieDB.raceKeys
    local classKeys = QuestieDB.classKeys
    local profKeys = QuestieProfessions.professionKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local specialFlags = QuestieDB.specialFlags

    return {
        [2] = { -- Sharptalon's Claw
            [questKeys.preQuestSingle] = {},
        },
        [11] = { -- Riverpaw Gnoll Bounty
            [questKeys.preQuestSingle] = {},
        },
        [23] = { -- Ursangous's Paw
            [questKeys.preQuestSingle] = {},
        },
        [24] = { -- Shadumbra's Head
            [questKeys.preQuestSingle] = {},
        },
        [54] = { -- Report to Goldshire
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.preQuestSingle] = {26390},
        },
        [106] = { -- Young Lovers
            [questKeys.preQuestSingle] = {},
        },
        [171] = { -- A Warden of the Alliance
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29117,29119},
            [questKeys.zoneOrSort] = -378,
        },
        [172] = { -- Children's Week
            [questKeys.zoneOrSort] = -378,
            [questKeys.startedBy] = {{51989}},
        },
        [218] = { -- Ice and Fire
            [questKeys.objectives] = {{{808}},nil,nil,nil,{{{946,37507},946},{{37112},37112}}},
            [questKeys.startedBy] = {{786}},
            [questKeys.nextQuestInChain] = 24490,
        },
        [297] = { -- Gathering Idols
            [questKeys.exclusiveTo] = {26961},
        },
        [309] = { -- Protecting the Shipment
            [questKeys.preQuestSingle] = {13639},
            [questKeys.triggerEnd] = nil,
            [questKeys.objectives] = {{{1380}}},
        },
        [313] = { -- Forced to Watch from Afar
            [questKeys.preQuestSingle] = {25724},
            [questKeys.startedBy] = {{40950}},
            [questKeys.objectives] = {{{40991,nil,Questie.ICON_TYPE_TALK},{40994,nil,Questie.ICON_TYPE_TALK},{41056,nil,Questie.ICON_TYPE_TALK}}},
        },
        [314] = { -- Protecting the Herd
            [questKeys.preQuestSingle] = {25932},
        },
        [384] = { -- Beer Basted Boar Ribs
            [questKeys.requiredSkill] = {},
        },
        [412] = { -- Operation Recombobulation
            [questKeys.preQuestSingle] = {313},
        },
        [433] = { -- The Public Servant
            [questKeys.objectives] = {{{41671,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [487] = { -- The Road to Darnassus
            [questKeys.preQuestSingle] = {483},
        },
        [489] = { -- Seek Redemption!
            [questKeys.startedBy] = {{2083}},
        },
        [495] = { -- The Crown of Will
            [questKeys.nextQuestInChain] = 0,
        },
        [578] = { -- The Stone of the Tides
            [questKeys.childQuests] = {579},
        },
        [579] = { -- Stormwind Library
            [questKeys.parentQuest] = 578,
        },
        [583] = { -- Welcome to the Jungle
            [questKeys.preQuestSingle] = {},
        },
        [648] = { -- Rescue OOX-17/TN!
            [questKeys.zoneOrSort] = zoneIDs.TANARIS,
            [questKeys.triggerEnd] = {"Escort OOX-17/TN to safety", {[zoneIDs.TANARIS]={{60.8,53.68}}}},
        },
        [749] = { -- The Ravaged Caravan
            [questKeys.preQuestSingle] = {},
        },
        [773] = { -- Rite of Wisdom
            [questKeys.preQuestSingle] = {20441},
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [824] = { -- Je'neu of the Earthen Ring
            [questKeys.finishedBy] = {{12736}},
        },
        [834] = { -- Winds in the Desert
            [questKeys.nextQuestInChain] = 0,
        },
        [835] = { -- Securing the Lines
            [questKeys.preQuestSingle] = {},
        },
        [836] = { -- Rescue OOX-09/HL!
            [questKeys.zoneOrSort] = zoneIDs.THE_HINTERLANDS,
        },
        [840] = { -- Conscript of the Horde
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 871,
            [questKeys.zoneOrSort] = 14,
        },
        [850] = { -- Kolkar Leaders
            [questKeys.startedBy] = {{34841}},
        },
        [867] = { -- Harpy Raiders
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {},
        },
        [869] = { -- To Track a Thief
            [questKeys.triggerEnd] = {"Source of Tracks Discovered",{[zoneIDs.THE_BARRENS] = {{63.5,61.5}}}},
        },
        [870] = { -- The Forgotten Pools
            [questKeys.triggerEnd] = {"Explore the waters of the Forgotten Pools",{[zoneIDs.THE_BARRENS] = {{37.1,45.4}}}},
        },
        [871] = { -- In Defense of Far Watch
            [questKeys.preQuestSingle] = {840, 26642, 28494},
            [questKeys.nextQuestInChain] = 872,
        },
        [872] = { -- The Far Watch Offensive
            [questKeys.preQuestSingle] = {871},
        },
        [875] = { -- Harpy Lieutenants
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {},
        },
        [918] = { -- Timberling Seeds
            [questKeys.preQuestSingle] = {997},
        },
        [919] = { -- Timberling Sprouts
            [questKeys.preQuestSingle] = {997},
        },
        [929] = { -- Teldrassil: The Refusal of the Aspects
            [questKeys.preQuestSingle] = {28731},
        },
        [930] = { -- The Glowing Fruit
            [questKeys.preQuestSingle] = {},
        },
        [931] = { -- The Shimmering Frond
            [questKeys.preQuestSingle] = {},
        },
        [932] = { -- Twisted Hatred
            [questKeys.preQuestSingle] = {489},
        },
        [933] = { -- Teldrassil: The Coming Dawn
            [questKeys.preQuestSingle] = {7383},
            [questKeys.nextQuestInChain] = 14005,
        },
        [935] = { -- The Waters of Teldrassil
            [questKeys.preQuestSingle] = {14005},
        },
        [938] = { -- Mist
            [questKeys.triggerEnd] = {"Lead Mist safely to Sentinel Arynia Cloudsbreak",{[zoneIDs.TELDRASSIL] = {{39.5,29.86}}}},
        },
        [997] = { -- Denalan's Earth
            [questKeys.preQuestSingle] = {486},
        },
        [1468] = { -- Children's Week
            [questKeys.zoneOrSort] = -378,
            [questKeys.startedBy] = {{51988}},
        },
        [1918] = { -- The Befouled Element
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [2158] = { -- Rest and Relaxation
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [2438] = { -- The Emerald Dreamcatcher
            [questKeys.specialFlags] = 0,
            [questKeys.nextQuestInChain] = 0,-- there are some weird things happening if you completed these quests before prepatch
        },
        [2499] = { -- Oakenscowl
            [questKeys.preQuestSingle] = {923},
        },
        [2518] = { -- Tears of the Moon
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 0,-- there are some weird things happening if you completed these quests before prepatch
        },
        [2947] = { -- Return of the Ring
            [questKeys.zoneOrSort] = 6457,
        },
        [3091] = { -- Simple Note -- Tauren Warrior
            [questKeys.preQuestSingle] = {},
        },
        [3092] = { -- Etched Note -- Tauren Hunter
            [questKeys.preQuestSingle] = {},
        },
        [3093] = { -- Rune-Inscribed Note -- Tauren Shaman
            [questKeys.preQuestSingle] = {},
        },
        [3094] = { -- Verdant Note -- Tauren Druid
            [questKeys.preQuestSingle] = {},
        },
        [3100] = { -- Simple Letter -- Human Warrior
            [questKeys.nextQuestInChain] = 26913,
            [questKeys.startedBy] = {{197}},
        },
        [3101] = { -- Consecrated Letter -- Human Paladin
            [questKeys.nextQuestInChain] = 26918,
            [questKeys.startedBy] = {{197}},
        },
        [3102] = { -- Encrypted Letter -- Human Rogue
            [questKeys.nextQuestInChain] = 26915,
        },
        [3103] = { -- Hallowed Letter -- Human Priest
            [questKeys.nextQuestInChain] = 26919,
        },
        [3104] = { -- Glyphic Letter -- Human Mage
            [questKeys.nextQuestInChain] = 26916,
            [questKeys.startedBy] = {{197}},
        },
        [3105] = { -- Tainted Letter -- Human Warlock
            [questKeys.nextQuestInChain] = 26914,
        },
        [3106] = { -- Simple Rune -- Dwarf Warrior
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [3107] = { -- Consecrated Rune -- Dwarf Paladin
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [3108] = { -- Etched Rune -- Dwarf Hunter
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [3110] = { -- Hallowed Rune -- Dwarf Priest
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [3116] = { -- Simple Sigil -- Night Elf Warrior
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [3117] = { -- Etched Sigil -- Night Elf Hunter
            [questKeys.startedBy] = {{2077,2079}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [3118] = { -- Encrypted Sigil -- Night Elf Rogue
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [3119] = { -- Hallowed Sigil -- Night Elf Priest
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [3120] = { -- Verdant Sigil -- Night Elf Druid
            [questKeys.startedBy] = {{2077,2079}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [3361] = { -- A Refugee's Quandary
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [3631] = { -- Summon Felsteed
            [questKeys.exclusiveTo] = {4489},
            [questKeys.nextQuestInChain] = 4490,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [4487] = { -- Summon Felsteed
            [questKeys.exclusiveTo] = {4488},
            [questKeys.nextQuestInChain] = 4490,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [4488] = { -- Summon Felsteed
            [questKeys.exclusiveTo] = {4487},
            [questKeys.nextQuestInChain] = 4490,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [4489] = { -- Summon Felsteed
            [questKeys.exclusiveTo] = {3631},
            [questKeys.nextQuestInChain] = 4490,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [5041] = { -- Supplies for the Crossroads
            [questKeys.preQuestSingle] = {871},
        },
        [5386] = { -- Catch of the Day
            [questKeys.childQuests] = nil,
        },
        [5421] = { -- Fish in a Bucket
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.parentQuest] = 0,
        },
        [5502] = { -- A Warden of the Horde
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29190,29191},
            [questKeys.zoneOrSort] = -378,
            [questKeys.finishedBy] = {{51989}},
        },
        [5561] = { -- Kodo Roundup
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4700,4702},4700,"Kodos Tamed"}}},
        },
        [5581] = { -- Portals of the Legion [Horde]
            [questKeys.preQuestSingle] = {},
        },
        [5627] = { -- Stars of Elune
            [questKeys.startedBy] = {{11401}},
        },
        [5628] = { -- Returning Home
            [questKeys.startedBy] = {{377,49749}},
            [questKeys.exclusiveTo] = {5629,5630,5631,5632,5633},
            [questKeys.nextQuestInChain] = 5627,
        },
        [5629] = { -- Returning Home
            [questKeys.startedBy] = {{3600}},
            [questKeys.exclusiveTo] = {5628,5630,5631,5632,5633},
            [questKeys.nextQuestInChain] = 5627,
        },
        [5630] = { -- Returning Home
            [questKeys.startedBy] = {{1226}},
            [questKeys.exclusiveTo] = {5628,5629,5631,5632,5633},
            [questKeys.nextQuestInChain] = 5627,
        },
        [5631] = { -- Returning Home
            [questKeys.startedBy] = {{376}},
            [questKeys.exclusiveTo] = {5628,5629,5630,5632,5633},
            [questKeys.nextQuestInChain] = 5627,
        },
        [5632] = { -- Returning Home
            [questKeys.startedBy] = {{11397}},
            [questKeys.exclusiveTo] = {5628,5629,5630,5631,5633},
            [questKeys.nextQuestInChain] = 5627,
        },
        [5633] = { -- Returning Home
            [questKeys.startedBy] = {{11406}},
            [questKeys.exclusiveTo] = {5628,5629,5630,5631,5632},
            [questKeys.nextQuestInChain] = 5627,
        },
        [5641] = { -- A Lack of Fear
            [questKeys.requiredRaces] = raceKeys.DWARF,
            [questKeys.startedBy] = {{11406}},
            [questKeys.exclusiveTo] = {},
        },
        [5642] = { -- Shadowguard
            [questKeys.exclusiveTo] = {5643},
            [questKeys.nextQuestInChain] = 5680,
        },
        [5643] = { -- Shadowguard
            [questKeys.exclusiveTo] = {5642},
            [questKeys.nextQuestInChain] = 5680,
        },
        [5645] = { -- A Lack of Fear
            [questKeys.startedBy] = {{376}},
            [questKeys.exclusiveTo] = {5647},
            [questKeys.nextQuestInChain] = 5641,
        },
        [5647] = { -- A Lack of Fear
            [questKeys.requiredRaces] = raceKeys.DWARF,
            [questKeys.exclusiveTo] = {5645},
            [questKeys.nextQuestInChain] = 5641,
        },
        [5672] = { -- Elune's Grace
            [questKeys.startedBy] = {{11401}},
        },
        [5673] = { -- Elune's Grace
            [questKeys.exclusiveTo] = {5674,5675},
            [questKeys.nextQuestInChain] = 5672,
            [questKeys.startedBy] = {{376}},
        },
        [5674] = { -- Elune's Grace
            [questKeys.exclusiveTo] = {5673,5675},
            [questKeys.nextQuestInChain] = 5672,
            [questKeys.startedBy] = {{11397}},
        },
        [5675] = { -- Elune's Grace
            [questKeys.exclusiveTo] = {5673,5674},
            [questKeys.nextQuestInChain] = 5672,
            [questKeys.startedBy] = {{11406}},
        },
        [5680] = { -- Shadowguard
            [questKeys.startedBy] = {{6018}},
        },
        [5713] = { -- One Shot. One Kill.
            [questKeys.triggerEnd] = {"Protect Aynasha", {[zoneIDs.DARKSHORE]={{47.65,88.97}}}},
        },
        [6031] = { -- Runecloth
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD,8}},
        },
        [6261] = { -- Dungar Longdrink
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [6281] = { -- Continue to Stormwind
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [6285] = { -- Return to Lewis
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [6322] = { -- Michael Garrett
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [6323] = { -- Ride to the Undercity
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [6324] = { -- Return to Morris
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [6362] = { -- Ride to Thunder Bluff
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [6363] = { -- Tal the Wind Rider Master
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [6364] = { -- Return to Varg
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [6365] = { -- Meats to Orgrimmar
            [questKeys.requiredRaces] = raceKeys.ORC + raceKeys.TROLL,
            [questKeys.startedBy] = {{3881}},
        },
        [6384] = { -- Ride to Orgrimmar
            [questKeys.requiredRaces] = raceKeys.ORC + raceKeys.TROLL,
            [questKeys.startedBy] = {{41140}},
        },
        [6385] = { -- Doras the Wind Rider Master
            [questKeys.requiredRaces] = raceKeys.ORC + raceKeys.TROLL,
        },
        [6386] = { -- Return to Razor Hill
            [questKeys.requiredRaces] = raceKeys.ORC + raceKeys.TROLL,
        },
        [6387] = { -- Honor Students
            [questKeys.requiredRaces] = raceKeys.GNOME + raceKeys.DWARF,
        },
        [6388] = { -- Gryth Thurden
            [questKeys.requiredRaces] = raceKeys.GNOME + raceKeys.DWARF,
        },
        [6391] = { -- Ride to Ironforge
            [questKeys.requiredRaces] = raceKeys.GNOME + raceKeys.DWARF,
        },
        [6392] = { -- Return to Gremlock
            [questKeys.requiredRaces] = raceKeys.GNOME + raceKeys.DWARF,
        },
        [6441] = { -- Satyr Horns
            [questKeys.preQuestSingle] = {26449},
        },
        [6581] = { -- Warsong Saw Blades
            [questKeys.parentQuest] = 0,
        },
        [6622] = { -- Triage
            [questKeys.preQuestSingle] = {},
        },
        [6623] = { -- Horde Trauma
            [questKeys.nextQuestInChain] = 6622,
        },
        [6624] = { -- Triage
            [questKeys.preQuestSingle] = {},
        },
        [6625] = { -- Alliance Trauma
            [questKeys.nextQuestInChain] = 6624,
        },
        [7383] = { -- Teldrassil: The Burden of the Kaldorei
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {918,919},
        },
        [7490] = { -- Victory for the Horde
            [questKeys.finishedBy] = {{39605}},
        },
        [7491] = { -- For All To See
            [questKeys.startedBy] = {{39605}},
        },
        [7495] = { -- Victory for the Alliance
            [questKeys.finishedBy] = {{29611}},
        },
        [7781] = { -- The Lord of Blackrock
            [questKeys.finishedBy] = {{29611}},
        },
        [7782] = { -- The Lord of Blackrock
            [questKeys.startedBy] = {{29611}},
        },
        [7783] = { -- The Lord of Blackrock
            [questKeys.finishedBy] = {{39605}},
        },
        [7784] = { -- The Lord of Blackrock
            [questKeys.startedBy] = {{39605}},
        },
        [7905] = { -- The Darkmoon Faire
            [questKeys.objectivesText] = {"Deliver the Free Ticket Voucher to Gelvas Grimgate, located inside the Darkmoon Faire."},
            [questKeys.startedBy] = {{54334}},
            [questKeys.zoneOrSort] = zoneIDs.IRONFORGE,
        },
        [7926] = { -- The Darkmoon Faire
            [questKeys.objectivesText] = {"Deliver the Free Ticket Voucher to Gelvas Grimgate, located inside the Darkmoon Faire."},
            [questKeys.startedBy] = {{55382}},
        },
        [8280] = { -- Securing the Supply Lines
            [questKeys.preQuestSingle] = {},
        },
        [8284] = { -- The Twilight Mystery
            [questKeys.preQuestSingle] = {8321},
        },
        [8329] = { -- Warrior Training
            [questKeys.finishedBy] = {{43010}},
            [questKeys.zoneOrSort] = 6455,
        },
        [8334] = { -- Aggression
            [questKeys.startedBy] = {{15281}},
        },
        [8335] = { -- Felendren the Banished
            [questKeys.startedBy] = {{15281}},
        },
        [8481] = { -- The Root of All Evil
            [questKeys.objectives] = {nil,nil,{{21145}},{576,42000}},
        },
        [8544] = { -- Conqueror's Spaulders
            [questKeys.objectives] = {nil,nil,{{20928},{20875},{20863},{20858}},{910,0}},
        },
        [8556] = { -- Signet of Unyielding Strength
            [questKeys.objectives] = {nil,nil,{{20884},{20868},{20861},{20865}},{609,9000}},
        },
        [8557] = { -- Drape of Unyielding Strength
            [questKeys.objectives] = {nil,nil,{{20885},{20867},{20864},{20860}},{609,21000}},
        },
        [8558] = { -- Sickle of Unyielding Strength
            [questKeys.objectives] = {nil,nil,{{20886},{20873},{20862},{20858}},{609,42000}},
        },
        [8559] = { -- Conqueror's Greaves
            [questKeys.objectives] = {nil,nil,{{20928},{20882},{20865},{20859}},{910,0}},
        },
        [8560] = { -- Conqueror's Legguards
            [questKeys.objectives] = {nil,nil,{{20927},{20876},{20861},{20865}},{910,3000}},
        },
        [8561] = { -- Conqueror's Crown
            [questKeys.objectives] = {nil,nil,{{20926},{20874},{20862},{20858}},{910,3000}},
        },
        [8562] = { -- Conqueror's Breastplate
            [questKeys.objectives] = {nil,nil,{{20929},{20882},{20860},{20864}},{910,9000}},
        },
        [8592] = { -- Tiara of the Oracle
            [questKeys.objectives] = {nil,nil,{{20926},{20877},{20860},{20864}},{910,3000}},
        },
        [8593] = { -- Trousers of the Oracle
            [questKeys.objectives] = {nil,nil,{{20927},{20879},{20859},{20863}},{910,3000}},
        },
        [8594] = { -- Mantle of the Oracle
            [questKeys.objectives] = {nil,nil,{{20928},{20878},{20860},{20865}},{910,0}},
        },
        [8596] = { -- Footwraps of the Oracle
            [questKeys.objectives] = {nil,nil,{{20928},{20876},{20861},{20859}},{910,0}},
        },
        [8602] = { -- Stormcaller's Pauldrons
            [questKeys.objectives] = {nil,nil,{{20932},{20879},{20859},{20862}},{910,0}},
        },
        [8603] = { -- Vestments of the Oracle
            [questKeys.objectives] = {nil,nil,{{20933},{20876},{20858},{20862}},{910,9000}},
        },
        [8621] = { -- Stormcaller's Footguards
            [questKeys.objectives] = {nil,nil,{{20932},{20877},{20861},{20863}},{910,0}},
        },
        [8622] = { -- Stormcaller's Hauberk
            [questKeys.objectives] = {nil,nil,{{20929},{20877},{20860},{20864}},{910,9000}},
        },
        [8623] = { -- Stormcaller's Diadem
            [questKeys.objectives] = {nil,nil,{{20930},{20878},{20858},{20862}},{910,3000}},
        },
        [8624] = { -- Stormcaller's Leggings
            [questKeys.objectives] = {nil,nil,{{20931},{20881},{20865},{20861}},{910,3000}},
        },
        [8625] = { -- Enigma Shoulderpads
            [questKeys.objectives] = {nil,nil,{{20932},{20876},{20858},{20861}},{910,0}},
        },
        [8626] = { -- Striker's Footguards
            [questKeys.objectives] = {nil,nil,{{20928},{20879},{20858},{20864}},{910,0}},
        },
        [8627] = { -- Avenger's Breastplate
            [questKeys.objectives] = {nil,nil,{{20929},{20877},{20860},{20864}},{910,9000}},
        },
        [8628] = { -- Avenger's Crown
            [questKeys.objectives] = {nil,nil,{{20930},{20878},{20858},{20862}},{910,3000}},
        },
        [8629] = { -- Avenger's Legguards
            [questKeys.objectives] = {nil,nil,{{20931},{20881},{20865},{20861}},{910,3000}},
        },
        [8630] = { -- Avenger's Pauldrons
            [questKeys.objectives] = {nil,nil,{{20932},{20879},{20859},{20862}},{910,0}},
        },
        [8631] = { -- Enigma Leggings
            [questKeys.objectives] = {nil,nil,{{20927},{20877},{20860},{20864}},{910,3000}},
        },
        [8632] = { -- Enigma Circlet
            [questKeys.objectives] = {nil,nil,{{20926},{20875},{20861},{20865}},{910,3000}},
        },
        [8633] = { -- Enigma Robes
            [questKeys.objectives] = {nil,nil,{{20933},{20874},{20859},{20863}},{910,9000}},
        },
        [8634] = { -- Enigma Boots
            [questKeys.objectives] = {nil,nil,{{20932},{20874},{20860},{20862}},{910,0}},
        },
        [8637] = { -- Deathdealer's Boots
            [questKeys.objectives] = {nil,nil,{{20928},{20881},{20862},{20864}},{910,0}},
        },
        [8638] = { -- Deathdealer's Vest
            [questKeys.objectives] = {nil,nil,{{20929},{20881},{20861},{20865}},{910,9000}},
        },
        [8639] = { -- Deathdealer's Helm
            [questKeys.objectives] = {nil,nil,{{20930},{20882},{20863},{20859}},{910,3000}},
        },
        [8640] = { -- Deathdealer's Leggings
            [questKeys.objectives] = {nil,nil,{{20927},{20875},{20858},{20862}},{910,3000}},
        },
        [8641] = { -- Deathdealer's Spaulders
            [questKeys.objectives] = {nil,nil,{{20928},{20874},{20860},{20863}},{910,0}},
        },
        [8655] = { -- Avenger's Greaves
            [questKeys.objectives] = {nil,nil,{{20932},{20877},{20861},{20863}},{910,0}},
        },
        [8656] = { -- Striker's Hauberk
            [questKeys.objectives] = {nil,nil,{{20929},{20879},{20859},{20863}},{910,9000}},
        },
        [8657] = { -- Striker's Diadem
            [questKeys.objectives] = {nil,nil,{{20930},{20881},{20861},{20865}},{910,3000}},
        },
        [8658] = { -- Striker's Leggings
            [questKeys.objectives] = {nil,nil,{{20931},{20874},{20860},{20864}},{910,3000}},
        },
        [8659] = { -- Striker's Pauldrons
            [questKeys.objectives] = {nil,nil,{{20928},{20882},{20862},{20865}},{910,0}},
        },
        [8660] = { -- Doomcaller's Footwraps
            [questKeys.objectives] = {nil,nil,{{20932},{20875},{20863},{20865}},{910,0}},
        },
        [8661] = { -- Doomcaller's Robes
            [questKeys.objectives] = {nil,nil,{{20933},{20875},{20862},{20858}},{910,9000}},
        },
        [8662] = { -- Doomcaller's Circlet
            [questKeys.objectives] = {nil,nil,{{20926},{20876},{20860},{20864}},{910,3000}},
        },
        [8663] = { -- Doomcaller's Trousers
            [questKeys.objectives] = {nil,nil,{{20931},{20878},{20859},{20863}},{910,3000}},
        },
        [8664] = { -- Doomcaller's Mantle
            [questKeys.objectives] = {nil,nil,{{20932},{20877},{20861},{20864}},{910,0}},
        },
        [8665] = { -- Genesis Boots
            [questKeys.objectives] = {nil,nil,{{20932},{20878},{20858},{20860}},{910,0}},
        },
        [8666] = { -- Genesis Vest
            [questKeys.objectives] = {nil,nil,{{20933},{20878},{20861},{20865}},{910,9000}},
        },
        [8667] = { -- Genesis Helm
            [questKeys.objectives] = {nil,nil,{{20930},{20879},{20859},{20863}},{910,3000}},
        },
        [8668] = { -- Genesis Trousers
            [questKeys.objectives] = {nil,nil,{{20931},{20882},{20858},{20862}},{910,3000}},
        },
        [8669] = { -- Genesis Shoulderpads
            [questKeys.objectives] = {nil,nil,{{20932},{20881},{20859},{20864}},{910,0}},
        },
        [8689] = { -- Shroud of Infinite Wisdom
            [questKeys.objectives] = {nil,nil,{{20885},{20870},{20859},{20863}},{609,21000}},
        },
        [8690] = { -- Cloak of the Gathering Storm
            [questKeys.objectives] = {nil,nil,{{20889},{20871},{20863},{20859}},{609,21000}},
        },
        [8691] = { -- Drape of Vaulted Secrets
            [questKeys.objectives] = {nil,nil,{{20885},{20873},{20858},{20862}},{609,21000}},
        },
        [8692] = { -- Cloak of Unending Life
            [questKeys.objectives] = {nil,nil,{{20889},{20872},{20864},{20860}},{609,21000}},
        },
        [8693] = { -- Cloak of Veiled Shadows
            [questKeys.objectives] = {nil,nil,{{20885},{20866},{20861},{20865}},{609,21000}},
        },
        [8694] = { -- Shroud of Unspoken Names
            [questKeys.objectives] = {nil,nil,{{20889},{20869},{20861},{20865}},{609,21000}},
        },
        [8695] = { -- Cape of Eternal Justice
            [questKeys.objectives] = {nil,nil,{{20889},{20871},{20859},{20863}},{609,21000}},
        },
        [8696] = { -- Cloak of the Unseen Path
            [questKeys.objectives] = {nil,nil,{{20889},{20868},{20858},{20862}},{609,21000}},
        },
        [8697] = { -- Ring of Infinite Wisdom
            [questKeys.objectives] = {nil,nil,{{20888},{20871},{20860},{20864}},{609,9000}},
        },
        [8698] = { -- Ring of the Gathering Storm
            [questKeys.objectives] = {nil,nil,{{20884},{20872},{20860},{20864}},{609,9000}},
        },
        [8699] = { -- Band of Vaulted Secrets
            [questKeys.objectives] = {nil,nil,{{20884},{20866},{20859},{20863}},{609,9000}},
        },
        [8700] = { -- Band of Unending Life
            [questKeys.objectives] = {nil,nil,{{20884},{20873},{20861},{20865}},{609,9000}},
        },
        [8701] = { -- Band of Veiled Shadows
            [questKeys.objectives] = {nil,nil,{{20888},{20867},{20858},{20862}},{609,9000}},
        },
        [8702] = { -- Ring of Unspoken Names
            [questKeys.objectives] = {nil,nil,{{20888},{20870},{20858},{20862}},{609,9000}},
        },
        [8703] = { -- Ring of Eternal Justice
            [questKeys.objectives] = {nil,nil,{{20884},{20872},{20860},{20864}},{609,9000}},
        },
        [8704] = { -- Signet of the Unseen Path
            [questKeys.objectives] = {nil,nil,{{20888},{20869},{20859},{20863}},{609,9000}},
        },
        [8705] = { -- Gavel of Infinite Wisdom
            [questKeys.objectives] = {nil,nil,{{20890},{20868},{20861},{20865}},{609,42000}},
        },
        [8706] = { -- Hammer of the Gathering Storm
            [questKeys.objectives] = {nil,nil,{{20886},{20869},{20861},{20865}},{609,42000}},
        },
        [8707] = { -- Blade of Vaulted Secrets
            [questKeys.objectives] = {nil,nil,{{20890},{20871},{20860},{20864}},{609,42000}},
        },
        [8708] = { -- Mace of Unending Life
            [questKeys.objectives] = {nil,nil,{{20890},{20870},{20862},{20858}},{609,42000}},
        },
        [8709] = { -- Dagger of Veiled Shadows
            [questKeys.objectives] = {nil,nil,{{20886},{20872},{20859},{20863}},{609,42000}},
        },
        [8710] = { -- Kris of Unspoken Names
            [questKeys.objectives] = {nil,nil,{{20890},{20867},{20859},{20863}},{609,42000}},
        },
        [8711] = { -- Blade of Eternal Justice
            [questKeys.objectives] = {nil,nil,{{20886},{20869},{20861},{20865}},{609,42000}},
        },
        [8712] = { -- Scythe of the Unseen Path
            [questKeys.objectives] = {nil,nil,{{20886},{20866},{20860},{20864}},{609,42000}},
        },
        [8764] = { -- The Changing of Paths - Protector No More
            [questKeys.preQuestSingle] = {8751,8756,8761},
        },
        [8765] = { -- The Changing of Paths - Invoker No More
            [questKeys.preQuestSingle] = {8751,8756,8761},
        },
        [8766] = { -- The Changing of Paths - Conqueror No More
            [questKeys.preQuestSingle] = {8751,8756,8761},
        },
        [9062] = { -- Soaked Pages
            [questKeys.preQuestSingle] = {},
        },
        [9067] = { -- The Party Never Ends
            [questKeys.preQuestSingle] = {},
        },
        [9130] = { -- Goods from Silvermoon City
            [questKeys.preQuestSingle] = {},
        },
        [9143] = { -- Dealing with Zeb'Sora
            [questKeys.preQuestSingle] = {},
        },
        [9144] = { -- Missing in the Ghostlands
            [questKeys.exclusiveTo] = {28560},
        },
        [9145] = { -- Help Ranger Valanna!
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9150] = { -- Salvaging the Past
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9155] = { -- Down the Dead Scar
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9160] = { -- Investigate An'daroth
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9171] = { -- Culinary Crunch
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9173] = { -- Retaking Windrunner Spire
            [questKeys.requiredMinRep] = {922,9000},
        },
        [9175] = { -- The Lady's Necklace
            [questKeys.startedBy] = {{16314,16315},nil,{22597}},
        },
        [9192] = { -- Trouble at the Underlight Mines
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9220] = { -- War on Deatholme
            [questKeys.preQuestSingle] = {},
        },
        [9252] = { -- Defending Fairbreeze Village
            [questKeys.preQuestSingle] = {},
        },
        [9283] = { -- Rescue the Survivors!
            [questKeys.objectives] = {{{16483,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.startedBy] = {{16483}},
        },
        [9294] = { -- Healing the Lake
            [questKeys.objectives] = {nil,{{181433,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9303] = { -- Inoculation
            [questKeys.startedBy] = {{16535}},
            [questKeys.preQuestSingle] = {},
        },
        [9305] = { -- Spare Parts
            [questKeys.preQuestSingle] = {},
        },
        [9324] = { -- Stealing Orgrimmar's Flame
            [questKeys.startedBy] = {nil,{181336},{23179}},
        },
        [9325] = { -- Stealing Thunder Bluff's Flame
            [questKeys.startedBy] = {nil,{181337},{23180}},
        },
        [9326] = { -- Stealing the Undercity's Flame
            [questKeys.startedBy] = {nil,{181335},{23181}},
        },
        [9327] = { -- The Forsaken
            [questKeys.preQuestSingle] = {},
        },
        [9329] = { -- The Forsaken
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE - raceKeys.BLOOD_ELF,
        },
        [9330] = { -- Stealing Stormwind's Flame
            [questKeys.startedBy] = {nil,{181332},{23182}},
        },
        [9331] = { -- Stealing Ironforge's Flame
            [questKeys.startedBy] = {nil,{181333},{23183}},
        },
        [9332] = { -- Stealing Darnassus's Flame
            [questKeys.startedBy] = {nil,{181334},{23184}},
        },
        [9339] = { -- A Thief's Reward
            [questKeys.startedBy] = {{16818}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [9365] = { -- A Thief's Reward
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [9369] = { -- Replenishing the Healing Crystals
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.DRAENEI,
        },
        [9436] = { -- Bloodscalp Insight
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26280,26321},
        },
        [9455] = { -- Strange Findings
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [9563] = { -- Gaining Mirren's Trust
            [questKeys.objectives] = {nil,nil,{{23848}},{946,3000}},
        },
        [9612] = { -- A Hearty Thanks!
            [questKeys.requiredRaces] = raceKeys.DRAENEI,
        },
        [9616] = { -- Bandits!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [9623] = { -- Coming of Age
            [questKeys.zoneOrSort] = zoneIDs.AZUREMYST_ISLE,
        },
        [9626] = { -- Meeting the Warchief
            [questKeys.finishedBy] = {{39605}},
        },
        [9672] = { -- The Bloodcurse Legacy
            [questKeys.exclusiveTo] = {9751},
        },
        [9731] = { -- Drain Schematics
            [questKeys.preQuestSingle] = {9720},
        },
        [9751] = { -- The Bloodcurse Legacy
            [questKeys.exclusiveTo] = {9672},
        },
        [9811] = { -- Friend of the Sin'dorei
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE - raceKeys.BLOOD_ELF,
        },
        [9812] = { -- Envoy to the Horde
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE - raceKeys.BLOOD_ELF - raceKeys.GOBLIN,
        },
        [9813] = { -- Meeting the Warchief
            [questKeys.finishedBy] = {{39605}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE - raceKeys.BLOOD_ELF - raceKeys.GOBLIN,
        },
        [9824] = { -- Arcane Disturbances
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {},
        },
        [9825] = { -- Restless Activity
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {},
        },
        [9871] = { -- Murkblood Invaders
            [questKeys.startedBy] = {{18238},nil,{24559}},
        },
        [9872] = { -- Murkblood Invaders
            [questKeys.startedBy] = {{18238},nil,{24558}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [9931] = { -- Returning the Favor
            [questKeys.preQuestSingle] = {},
        },
        [9932] = { -- Body of Evidence
            [questKeys.preQuestSingle] = {},
        },
        [9934] = { -- Message to Garadar
            [questKeys.preQuestSingle] = {},
        },
        [9968] = { -- Strange Energy
            [questKeys.preQuestSingle] = {},
        },
        [9978] = { -- By Any Means Necessary
            [questKeys.preQuestSingle] = {},
        },
        [10066] = { -- Oh, the Tangled Webs They Weave
            [questKeys.startedBy] = {{17986}},
        },
        [10067] = { -- Fouled Water Spirits
            [questKeys.startedBy] = {{17986}},
        },
        [10068] = { -- Arcane Missiles
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 15279}}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.finishedBy] = {{15279}},
            [questKeys.zoneOrSort] = 6455,
        },
        [10069] = { -- Ways of the Light
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{20271},{20154}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Judgement"), 2, {{"monster", 15280}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Seal of Righteousness"), 3, {{"monster", 15280}}},
            },
            [questKeys.exclusiveTo] = {},
            [questKeys.finishedBy] = {{15280}},
            [questKeys.zoneOrSort] = 6455,
        },
        [10070] = { -- Steady Shot
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 15513}}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.finishedBy] = {{15513}},
            [questKeys.zoneOrSort] = 6455,
        },
        [10071] = { -- Evisceration
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 15285}}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.finishedBy] = {{15285}},
            [questKeys.zoneOrSort] = 6455,
        },
        [10072] = { -- Healing the Wounded
            [questKeys.objectives] = {{{44857,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 15284}}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.finishedBy] = {{15284}},
            [questKeys.zoneOrSort] = 6455,
        },
        [10073] = { -- Immolation
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 15283}}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.finishedBy] = {{15283}},
            [questKeys.zoneOrSort] = 6455,
        },
        [10186] = { -- You're Hired!
            [questKeys.preQuestSingle] = {},
        },
        [10302] = { -- Volatile Mutations
            [questKeys.preQuestSingle] = {9369,9280},
        },
        [10328] = { -- Sunfury Briefings
            [questKeys.preQuestSingle] = {},
        },
        [10388] = { -- Return to Thrallmar
            [questKeys.startedBy] = {{19273}},
        },
        [10416] = { -- Synthesis of Power
            [questKeys.requiredMinRep] = {934,0},
        },
        [10419] = { -- Arcane Tomes
            [questKeys.requiredMinRep] = {934,0},
        },
        [10420] = { -- A Cleansing Light
            [questKeys.requiredMinRep] = {932,0},
        },
        [10421] = { -- Fel Armaments
            [questKeys.requiredMinRep] = {932,0},
        },
        [10450] = { -- Bonechewer Blood
            [questKeys.preQuestSingle] = {10291,10875},
        },
        [10639] = { -- Teron Gorefiend, I am...
            [questKeys.preQuestSingle] = {},
        },
        [10645] = { -- Teron Gorefiend, I am...
            [questKeys.preQuestSingle] = {},
        },
        [10646] = { -- Illidan's Pupil
            [questKeys.preQuestSingle] = {},
        },
        [10647] = { -- Wanted: Uvuros, Scourge of Shadowmoon
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [10648] = { -- Wanted: Uvuros, Scourge of Shadowmoon
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [10676] = { -- Bane of the Illidari
            [questKeys.preQuestSingle] = {},
        },
        [10729] = { -- Path of the Violet Mage
            [questKeys.exclusiveTo] = {10730,10731,10732},
            [questKeys.reputationReward] = {{967,5}},
        },
        [10730] = { -- Path of the Violet Restorer
            [questKeys.exclusiveTo] = {10729,10731,10732},
            [questKeys.reputationReward] = {{967,5}},
        },
        [10731] = { -- Path of the Violet Assassin
            [questKeys.exclusiveTo] = {10729,10730,10732},
            [questKeys.reputationReward] = {{967,5}},
        },
        [10732] = { -- Path of the Violet Protector
            [questKeys.exclusiveTo] = {10729,10730,10731},
            [questKeys.reputationReward] = {{967,5}},
        },
        [10942] = { -- Children's Week
            [questKeys.zoneOrSort] = -378,
            [questKeys.startedBy] = {{22819}},
        },
        [10943] = { -- Children's Week
            [questKeys.zoneOrSort] = -378,
        },
        [10945] = { -- Hch'uu and the Mushroom People
            [questKeys.zoneOrSort] = -378,
            [questKeys.startedBy] = {{22817}},
        },
        [10950] = { -- Auchindoun and the Ring of Observance
            [questKeys.zoneOrSort] = -378,
        },
        [10951] = { -- A Trip to the Dark Portal
            [questKeys.zoneOrSort] = -378,
            [questKeys.triggerEnd] = {"Salandria taken to the Dark Portal",{[zoneIDs.HELLFIRE_PENINSULA] = {{89.1,50.23}}}},
        },
        [10952] = { -- A Trip to the Dark Portal
            [questKeys.zoneOrSort] = -378,
            [questKeys.triggerEnd] = {"Dornaa taken to the Dark Portal",{[zoneIDs.HELLFIRE_PENINSULA] = {{89.1,50.23}}}},
        },
        [10953] = { -- Visit the Throne of the Elements
            [questKeys.zoneOrSort] = -378,
            [questKeys.triggerEnd] = {"Salandria taken to the Throne of the Elements",{[zoneIDs.NAGRAND] = {{60.65,22.38}}}},
            [questKeys.startedBy] = {{22817}},
        },
        [10954] = { -- Jheel is at Aeris Landing!
            [questKeys.zoneOrSort] = -378,
        },
        [10956] = { -- The Seat of the Naaru
            [questKeys.zoneOrSort] = -378,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10950,10952,10954},
        },
        [10962] = { -- Time to Visit the Caverns
            [questKeys.zoneOrSort] = -378,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10950,10952,10954},
            [questKeys.triggerEnd] = {"Dornaa taken to the Caverns of Time",{[zoneIDs.TANARIS] = {{60.02,57.32}}}},
        },
        [10963] = { -- Time to Visit the Caverns
            [questKeys.zoneOrSort] = -378,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10945,10951,10953},
            [questKeys.triggerEnd] = {"Salandria taken to the Caverns of Time",{[zoneIDs.TANARIS] = {{60.02,57.32}}}},
        },
        [10966] = { -- Back to the Orphanage
            [questKeys.zoneOrSort] = -378,
        },
        [10967] = { -- Back to the Orphanage
            [questKeys.zoneOrSort] = -378,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10963,11975},
        },
        [10968] = { -- Call on the Farseer
            [questKeys.zoneOrSort] = -378,
        },
        [10998] = { -- Grim(oire) Business
            [questKeys.preQuestSingle] = {},
        },
        [11002] = { -- The Fall of Magtheridon
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_PENINSULA,
        },
        [11003] = { -- The Fall of Magtheridon
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_PENINSULA,
        },
        [11031] = { -- Archmage No More
            [questKeys.specialFlags] = 1,
        },
        [11032] = { -- Protector No More
            [questKeys.specialFlags] = 1,
        },
        [11033] = { -- Assassin No More
            [questKeys.specialFlags] = 1,
        },
        [11034] = { -- Restorer No More
            [questKeys.specialFlags] = 1,
        },
        [11103] = { -- Sage No More
            [questKeys.startedBy] = {{19935}},
            [questKeys.finishedBy] = {{19935}},
            [questKeys.specialFlags] = 1,
        },
        [11104] = { -- Restorer No More
            [questKeys.startedBy] = {{19935}},
            [questKeys.finishedBy] = {{19935}},
            [questKeys.specialFlags] = 1,
        },
        [11105] = { -- Champion No More
            [questKeys.startedBy] = {{19935}},
            [questKeys.finishedBy] = {{19935}},
            [questKeys.specialFlags] = 1,
        },
        [11106] = { -- Defender No More
            [questKeys.startedBy] = {{19935}},
            [questKeys.finishedBy] = {{19935}},
            [questKeys.specialFlags] = 1,
        },
        [11129] = { -- Kyle's Gone Missing!
            [questKeys.objectives] = {{{23616,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11131] = { -- Stop the Fires!
            [questKeys.exclusiveTo] = {12135},
            [questKeys.preQuestSingle] = {11360,11439,11440},
        },
        [11219] = { -- Stop the Fires!
            [questKeys.exclusiveTo] = {12139},
            [questKeys.preQuestSingle] = {11361,11449,11450},
        },
        [11250] = { -- All Hail the Conqueror of Skorn!
            [questKeys.preQuestSingle] = {},
        },
        [11272] = { -- A Score to Settle
            [questKeys.exclusiveTo] = {30112},
        },
        [11293] = { -- Bark for the Barleybrews!
            [questKeys.exclusiveTo] = {11294},
        },
        [11294] = { -- Bark for the Thunderbrews!
            [questKeys.exclusiveTo] = {11293},
        },
        [11356] = { -- Costumed Orphan Matron
            [questKeys.startedBy] = {{20102}},
        },
        [11357] = { -- Masked Orphan Matron
            [questKeys.startedBy] = {{20102}},
        },
        [11360] = { -- Fire Brigade Practice
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11361] = { -- Fire Training
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11407] = { -- Bark for Drohn's Distillery!
            [questKeys.exclusiveTo] = {11408},
        },
        [11408] = { -- Bark for T'chali's Voodoo Brewery!
            [questKeys.exclusiveTo] = {11407},
        },
        [11439] = { -- Fire Brigade Practice
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11440] = { -- Fire Brigade Practice
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11449] = { -- Fire Training
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11450] = { -- Fire Training
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11585] = { -- Hellscream's Vigil
            [questKeys.preQuestSingle] = {},
        },
        [11632] = { -- What the Cold Wind Brings...
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [11657] = { -- Torch Catching
            [questKeys.triggerEnd] = {"Catch 4 torches in a row", {
                [zoneIDs.DARNASSUS]={{63.81,48.83}},
                [zoneIDs.STORMWIND_CITY]={{48.71,70.9}},
                [zoneIDs.IRONFORGE]={{61.97,28.05}},
                [zoneIDs.THE_EXODAR]={{41.4,22.65}},
            }},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [11665] = { -- Crocolisks in the City
            [questKeys.extraObjectives] = {
                {{[zoneIDs.ORGRIMMAR] = {{38.2,81.6},{36.0,75.8},{46.0,45.3},{64.9,42.5}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Baby Crocolisk")},
                {{[zoneIDs.STORMWIND_CITY] = {{60.4,60.2},{54.6,66.3},{69.8,65.2},{62.2,48.2},{71.2,40.7},{56.1,38.3}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Baby Crocolisk")},
            },
        },
        [11672] = { -- Enlistment Day
            [questKeys.preQuestSingle] = {},
        },
        [11724] = { -- Massive Moth Omelet?
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [11731] = { -- Torch Tossing
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Hit 8 braziers", {
                [zoneIDs.DARNASSUS]={{63.63,44.3}},
                [zoneIDs.STORMWIND_CITY]={{49.91,71.17}},
                [zoneIDs.IRONFORGE]={{64.69,21.17}},
                [zoneIDs.THE_EXODAR]={{40.09,28.3}},
            }},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [11905] = { -- Postponing the Inevitable
            [questKeys.startedBy] = {{55535}},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectivesText] = {"Image of Warmage Kaitlyn in the Nexus wants you to use the Interdimensional Refabricator near the rift."},
        },
        [11911] = { -- Quickening
            [questKeys.startedBy] = {{55536}},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectivesText] = {"Image of Warmage Kaitlyn in the Nexus wants you to collect 5 Arcane Splinters from Crystalline Protectors."},
        },
        [11917] = { -- Striking Back
            [questKeys.preQuestSingle] = {12012,29092},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188049},{"object",188137},{"object",188138}}}},
        },
        [11921] = { -- More Torch Tossing
            [questKeys.triggerEnd] = {"Hit 20 braziers", {
                [zoneIDs.DARNASSUS]={{63.63,44.3}},
                [zoneIDs.STORMWIND_CITY]={{49.91,71.17}},
                [zoneIDs.IRONFORGE]={{64.69,21.17}},
                [zoneIDs.THE_EXODAR]={{40.09,28.3}},
            }},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [11922] = { -- Torch Tossing
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Hit 8 braziers", {
                [zoneIDs.TIRISFAL_GLADES]={{62.29,66.39}},
                [zoneIDs.ORGRIMMAR]={{46.21,35.66}},
                [zoneIDs.THUNDER_BLUFF]={{20.34,28.26}},
                [zoneIDs.SILVERMOON_CITY]={{67.58,43.78}},
            }},
        },
        [11923] = { -- Torch Catching
            [questKeys.triggerEnd] = {"Catch 4 torches in a row", {
                [zoneIDs.ORGRIMMAR]={{44.75,38.09}},
                [zoneIDs.THUNDER_BLUFF]={{21.95,26.74}},
                [zoneIDs.TIRISFAL_GLADES]={{61.93,66.77}},
                [zoneIDs.SILVERMOON_CITY]={{70.86,42.27}},
            }},
        },
        [11924] = { -- More Torch Catching
            [questKeys.triggerEnd] = {"Catch 10 torches in a row", {
                [zoneIDs.DARNASSUS]={{63.81,48.83}},
                [zoneIDs.STORMWIND_CITY]={{48.71,70.9}},
                [zoneIDs.IRONFORGE]={{61.97,28.05}},
                [zoneIDs.THE_EXODAR]={{41.4,22.65}},
            }},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [11925] = { -- More Torch Catching
            [questKeys.triggerEnd] = {"Catch 10 torches in a row", {
                [zoneIDs.ORGRIMMAR]={{44.75,38.09}},
                [zoneIDs.THUNDER_BLUFF]={{21.95,26.74}},
                [zoneIDs.TIRISFAL_GLADES]={{61.93,66.77}},
                [zoneIDs.SILVERMOON_CITY]={{70.86,42.27}},
            }},
        },
        [11926] = { -- More Torch Tossing
            [questKeys.triggerEnd] = {"Hit 20 braziers", {
                [zoneIDs.TIRISFAL_GLADES]={{62.29,66.39}},
                [zoneIDs.ORGRIMMAR]={{46.21,35.66}},
                [zoneIDs.THUNDER_BLUFF]={{20.34,28.26}},
                [zoneIDs.SILVERMOON_CITY]={{67.58,43.78}},
            }},
        },
        [11947] = { -- Striking Back
            [questKeys.preQuestSingle] = {12012,29092},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188130},{"object",188134},{"object",188135}}}},
        },
        [11948] = { -- Striking Back
            [questKeys.preQuestSingle] = {12012,29092},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188139},{"object",188143},{"object",188144}}}},
        },
        [11952] = { -- Striking Back
            [questKeys.preQuestSingle] = {12012,29092},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188145},{"object",188146},{"object",188147}}}},
        },
        [11953] = { -- Striking Back
            [questKeys.preQuestSingle] = {12012,29092},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188148},{"object",188149},{"object",188150}}}},
        },
        [11954] = { -- Striking Back
            [questKeys.preQuestSingle] = {12012,29092},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon one of Ahune's templars"),0,{{"object",188151},{"object",188152},{"object",188153},{"object",188154}}}},
        },
        [11973] = { -- Prisoner of War
            [questKeys.startedBy] = {{55531}},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectivesText] = {"Warmage Kaitlyn wants you to free Keristrasza."},
        },
        [11975] = { -- Now, When I Grow Up...
            [questKeys.zoneOrSort] = -378,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10945,10951,10953},
        },
        [11978] = { -- Into the Fold
            [questKeys.preQuestSingle] = {},
        },
        [11999] = { -- Rifle the Bodies
            [questKeys.preQuestSingle] = {},
        },
        [12012] = { -- Inform the Elder
            [questKeys.exclusiveTo] = {29092},
            [questKeys.startedBy] = {{25324}},
        },
        [12133] = { -- Smash the Pumpkin
            [questKeys.zoneOrSort] = -21,
        },
        [12135] = { -- "Let the Fires Come!"
            [questKeys.zoneOrSort] = -21,
            [questKeys.exclusiveTo] = {11131},
            [questKeys.preQuestSingle] = {11360,11439,11440},
        },
        [12139] = { -- "Let the Fires Come!"
            [questKeys.zoneOrSort] = -21,
            [questKeys.exclusiveTo] = {11219},
            [questKeys.preQuestSingle] = {11361,11449,11450},
        },
        [12155] = { -- Smash the Pumpkin
            [questKeys.zoneOrSort] = -21,
        },
        [12171] = { -- Of Traitors and Treason
            [questKeys.preQuestSingle] = {},
        },
        [12172] = { -- Attunement to Dalaran
            [questKeys.objectives] = {{{27135,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12173] = { -- Attunement to Dalaran
            [questKeys.objectives] = {{{27135,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12246] = { -- A Possible Link
            [questKeys.preQuestSingle] = {},
        },
        [12247] = { -- Children of Ursoc
            [questKeys.preQuestSingle] = {},
        },
        [12248] = { -- Vordrassil's Sapling
            [questKeys.preQuestSingle] = {},
        },
        [12249] = { -- Ursoc, the Bear God
            [questKeys.preQuestSingle] = {},
        },
        [12250] = { -- Vordrassil's Seeds
            [questKeys.preQuestSingle] = {},
        },
        [12255] = { -- The Thane of Voldrune
            [questKeys.preQuestSingle] = {},
        },
        [12281] = { -- Understanding the Scourge War Machine
            [questKeys.preQuestSingle] = {},
        },
        [12300] = { -- Test of Mettle
            [questKeys.preQuestSingle] = {},
        },
        [12325] = { -- Into Hostile Territory
            [questKeys.preQuestSingle] = {},
        },
        [12427] = { -- The Conquest Pit: Bear Wrestling!
            [questKeys.preQuestGroup] = {},
        },
        [12491] = { -- Direbrew's Dire Brew
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [12492] = { -- Direbrew's Dire Brew
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [12539] = { -- Hoofing It
            [questKeys.preQuestGroup] = {},
        },
        [12563] = { -- Troll Patrol
            [questKeys.startedBy] = {},
        },
        [12581] = { -- A Hero's Burden
            [questKeys.preQuestGroup] = {},
        },
        [12587] = { -- Troll Patrol
            [questKeys.startedBy] = {},
        },
        [12601] = { -- The Alchemist's Apprentice
            [questKeys.startedBy] = {},
        },
        [12602] = { -- The Alchemist's Apprentice
            [questKeys.startedBy] = {},
        },
        [12604] = { -- Congratulations!
            [questKeys.preQuestGroup] = {},
        },
        [12614] = { -- Post-partum Aggression
            [questKeys.preQuestSingle] = {12607},
        },
        [12618] = { -- Blessing of Zim'Torga
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [12656] = { -- Blessing of Zim'Rhuk
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [12696] = { -- Aerial Surveillance
            [questKeys.preQuestGroup] = {},
        },
        [12706] = { -- Victory At Death's Breach!
            [questKeys.preQuestGroup] = {},
        },
        [12754] = { -- Ambush At The Overlook
            [questKeys.preQuestGroup] = {},
        },
        [12774] = { -- Stormwind
            [questKeys.finishedBy] = {{29611}},
        },
        [12821] = { -- Opening the Backdoor
            [questKeys.objectives] = {nil,nil,{{40731}}},
        },
        [12828] = { -- Ample Inspiration
            [questKeys.preQuestSingle] = {},
        },
        [12869] = { -- Pushed Too Far
            [questKeys.preQuestSingle] = {},
        },
        [13095] = { -- Have They No Shame?
            [questKeys.startedBy] = {{55537}},
            [questKeys.objectivesText] = {"Image of Warmage Kaitlyn wants you to recover Berinand's Research."},
        },
        [13124] = { -- The Struggle Persists
            [questKeys.startedBy] = {}, -- needs a fake NPC inside oculus
        },
        [13125] = { -- The Air Stands Still
            [questKeys.preQuestSingle] = {},
        },
        [13187] = { -- The Faceless Ones
            [questKeys.preQuestSingle] = {29826},
        },
        [13188] = { -- Where Kings Walk
            [questKeys.finishedBy] = {{29611}},
        },
        [13189] = { -- Warchief's Blessing
            [questKeys.finishedBy] = {{39605}},
        },
        [13312] = { -- The Ironwall Rampart
            [questKeys.preQuestSingle] = {},
        },
        [13337] = { -- The Ironwall Rampart
            [questKeys.preQuestSingle] = {},
        },
        [13504] = { -- Shatterspear Laborers
            [questKeys.preQuestSingle] = {13589},
        },
        [13505] = { -- Remnants of the Highborne
            [questKeys.preQuestSingle] = {13589},
        },
        [13506] = { -- Reason to Worry
            [questKeys.startedBy] = {{32863},nil,{44979}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13507] = { -- Denying Manpower
            [questKeys.preQuestSingle] = {13505},
        },
        [13509] = { -- War Supplies
            [questKeys.preQuestSingle] = {13504},
            [questKeys.objectives] = {nil,{{194102}}},
        },
        [13510] = { -- Timely Arrival
            [questKeys.triggerEnd] = {"Escort Sentinel Aynasha to the Dock",{[zoneIDs.DARKSHORE] = {{60.25,6.93}}}},
        },
        [13512] = { -- Strategic Strikes
            [questKeys.preQuestSingle] = {13507},
        },
        [13513] = { -- On the Brink
            [questKeys.preQuestSingle] = {13507},
        },
        [13514] = { -- The Ancients' Ire
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get on the Protector's back"),0,{{"monster",43742}}}},
            [questKeys.preQuestSingle] = {13512},
        },
        [13515] = { -- Ending the Threat
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak to Sandrya Moonfall to start the attack"),0,{{"monster",33178}}}},
        },
        [13518] = { -- The Last Wave of Survivors
            [questKeys.objectives] = {{{33093,nil,Questie.ICON_TYPE_TALK},{32911,nil,Questie.ICON_TYPE_TALK},{33095,nil,Questie.ICON_TYPE_TALK},{33094,nil,Questie.ICON_TYPE_TALK}}},
        },
        [13519] = { -- The Twilight's Hammer
            [questKeys.preQuestSingle] = {13591},
        },
        [13520] = { -- The Boon of the Seas
            [questKeys.preQuestSingle] = {13518},
        },
        [13521] = { -- Buzzbox 413
            [questKeys.preQuestSingle] = {13518},
        },
        [13523] = { -- Power Over the Tides
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use Orb of Elune on its corpse"),0,{{"monster",32890}}}},
        },
        [13526] = { -- The Bear's Paw
            [questKeys.preQuestSingle] = {13525},
        },
        [13529] = { -- The Corruption's Source
            [questKeys.preQuestSingle] = {13528},
        },
        [13537] = { -- A Taste for Grouper
            [questKeys.requiredSkill] = {profKeys.FISHING,1},
            [questKeys.preQuestGroup] = {13518,13522},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE] = {{52.44,17.43}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Darkshore Groupers")}},
        },
        [13542] = { -- Against the Wind
            [questKeys.requiredSourceItems] = {44868},
            [questKeys.objectives] = {{{32986,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [13544] = { -- The Bear's Blessing
            [questKeys.requiredSourceItems] = {44886},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use Fleetfoot's Tailfeathers"),0,{{"object",194106}}}},
        },
        [13545] = { -- Coaxing the Spirits
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the Blessed Herb Bundle"),0,{{"monster",33043},{"monster",33044}}}},
        },
        [13547] = { -- Coaxing the Spirits
            [questKeys.objectives] = {{{33001,nil,Questie.ICON_TYPE_TALK},{33033,nil,Questie.ICON_TYPE_TALK},{33035,nil,Questie.ICON_TYPE_TALK},{33037,nil,Questie.ICON_TYPE_TALK}}},
        },
        [13557] = { -- Bearer of Good Fortune
            [questKeys.startedBy] = {{33020,33022},nil,{44927}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{33023,33024},33023,"Uncorrupted animals freed",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",194124},{"object",194133}}}},
        },
        [13558] = { -- Call Down the Thunder
            [questKeys.objectives] = {nil,{{194145}},{{44929}}},
        },
        [13560] = { -- An Ocean Not So Deep
            [questKeys.preQuestGroup] = {13566,13569},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Take control of the decoy"),0,{{"object",195006}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{33262,33277},33262,"Scavenging Greymist Murlocs"}}},
        },
        [13562] = { -- The Final Flame of Bashal'Aran
            [questKeys.objectives] = {nil,{{194179}}},
            [questKeys.preQuestGroup] = {13529,13554},
        },
        [13563] = { -- A Love Eternal
            [questKeys.preQuestGroup] = {13529,13554},
        },
        [13564] = { -- A Lost Companion
            [questKeys.objectives] = {{{33053,"Locate Grimclaw.",Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {13529,13554},
        },
        [13565] = { -- Twice Removed
            [questKeys.preQuestSingle] = {13564},
            [questKeys.objectives] = {{{33207},{34009,"Withered Ents called",Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use Petrified Root on its corpse"),0,{{"monster",33206}}}},
        },
        [13566] = { -- Ritual Materials
            [questKeys.preQuestSingle] = {13564},
        },
        [13567] = { -- Spirit of the Stag
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {13568,13597},
            [questKeys.parentQuest] = 13569,
        },
        [13568] = { -- Spirit of the Moonstalker
            [questKeys.startedBy] = {{33131}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {13567,13597},
            [questKeys.parentQuest] = 13569,
        },
        [13569] = { -- The Ritual Bond
            [questKeys.objectives] = {nil,nil,nil,nil,{{{33131,33132,33133},33131,"Receive the blessing of a great animal spirit.",Questie.ICON_TYPE_EVENT}}},
            [questKeys.childQuests] = {13567,13568,13597},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13565,13566,13598},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Breathe in the incense"),0,{{"object",194771}}}},
        },
        [13570] = { -- Remembrance of Auberdine
            [questKeys.preQuestSingle] = {13591},
        },
        [13572] = { -- Jadefire Braziers
            [questKeys.preQuestSingle] = {13544},
        },
        [13576] = { -- Mutual Aid
            [questKeys.objectives] = {{{32999}}},
        },
        [13580] = { -- Soothing the Elements
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Ritual of Soothing complete",{[zoneIDs.DARKSHORE] = {{39.54,62.23}}}},
        },
        [13583] = { -- The Wildkin's Oath
            [questKeys.preQuestSingle] = {13582},
        },
        [13586] = { -- The Emerald Dream
            [questKeys.preQuestGroup] = {13581,13583,13585},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Step through the Nightmare Portal"),0,{{"object",195071}}}},
        },
        [13587] = { -- The Waking Nightmare
            [questKeys.preQuestSingle] = {13586},
        },
        [13588] = { -- The Eye of All Storms
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Ride Thessera"),0,{{"monster",34401}}}},
        },
        [13589] = { -- The Shatterspear Invaders
            [questKeys.preQuestSingle] = {13569},
        },
        [13590] = { -- The Front Line
            [questKeys.preQuestSingle] = {13512},
        },
        [13591] = { -- Disturbing Connections
            [questKeys.startedBy] = {{32862},nil,{46318}},
            [questKeys.preQuestSingle] = {13590},
        },
        [13594] = { -- Don't Forget the Horde
            [questKeys.preQuestSingle] = {26408},
        },
        [13595] = { -- Of Their Own Design
            [questKeys.requiredSourceItems] = {44967},
            [questKeys.objectives] = {{{33183,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13596] = { -- Twilight Plans
            [questKeys.preQuestSingle] = {13591},
        },
        [13597] = { -- Spirit of the Thistle Bear
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {13567,13568},
            [questKeys.parentQuest] = 13569,
        },
        [13598] = { -- Unsavory Remedies
            [questKeys.preQuestSingle] = {13564},
        },
        [13599] = { -- Grimclaw's Return
            [questKeys.preQuestSingle] = {13569},
        },
        [13601] = { -- In Aid of the Refugees
            [questKeys.preQuestSingle] = {13596},
        },
        [13605] = { -- The Last Refugee
            [questKeys.triggerEnd] = {"Archaeologist Hollee escorted to safety.",{[zoneIDs.DARKSHORE] = {{41.18,43.36}}}},
        },
        [13617] = { -- West to the Strand
            [questKeys.nextQuestInChain] = 26465,
        },
        [13621] = { -- Gorat's Vengeance
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the imbued blood"),0,{{"monster",33294}}}},
            [questKeys.preQuestSingle] = {13620},
        },
        [13628] = { -- Got Wood?
            [questKeys.preQuestSingle] = {13621},
        },
        [13635] = { -- South Gate Status Report
            [questKeys.nextQuestInChain] = 26145,
        },
        [13636] = { -- Stormpike's Orders
            [questKeys.nextQuestInChain] = 26843,
        },
        [13639] = { -- Resupplying the Excavation
            [questKeys.objectives] = {{{2057,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {26868},
        },
        [13642] = { -- Bathed in Light
            [questKeys.preQuestSingle] = {13623},
        },
        [13646] = { -- Astranaar Bound
            [questKeys.preQuestSingle] = {26464},
        },
        [13647] = { -- Joining the Hunt
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {309,-26961},
        },
        [13650] = { -- Keep Your Hands Off The Goods!
            [questKeys.objectives] = {{{33487,nil,Questie.ICON_TYPE_EVENT},{33485,nil,Questie.ICON_TYPE_EVENT},{33486,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13653] = { -- Crisis at Splintertree
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak to Gorka"),0,{{"monster",33421}}}},
            [questKeys.triggerEnd] = {"Gorka accompanied to Mor'shan Ramparts",{[zoneIDs.ASHENVALE] = {{68.43,88.43}}}},
            [questKeys.objectives] = {},
        },
        [13655] = { -- Explorers' League Document (2 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13656] = { -- Explorers' League Document (1 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13657] = { -- Explorers' League Document (3 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13658] = { -- Explorers' League Document (4 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13659] = { -- Explorers' League Document (6 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13660] = { -- Explorers' League Document (5 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13661] = { -- Heartfelt Appreciation
            [questKeys.startedBy] = {{1153}},
            [questKeys.preQuestGroup] = {13655,13656,13657,13658,13659,13660},
        },
        [13683] = { -- Stopping the Rituals
            [questKeys.preQuestSingle] = {26468},
        },
        [13684] = { -- A Valiant Of Stormwind
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [13685] = { -- A Valiant Of Ironforge
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [13688] = { -- A Valiant Of Gnomeregan
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [13689] = { -- A Valiant Of Darnassus
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
        },
        [13690] = { -- A Valiant Of The Exodar
            [questKeys.requiredRaces] = raceKeys.DRAENEI,
        },
        [13691] = { -- A Valiant Of Orgrimmar
            [questKeys.requiredRaces] = raceKeys.ORC,
        },
        [13693] = { -- A Valiant Of Sen'jin
            [questKeys.requiredRaces] = raceKeys.TROLL,
        },
        [13694] = { -- A Valiant Of Thunder Bluff
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [13695] = { -- A Valiant Of Undercity
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [13696] = { -- A Valiant Of Silvermoon
            [questKeys.requiredRaces] = raceKeys.BLOOD_ELF,
        },
        [13698] = { -- Explosives Shredding
            [questKeys.objectives] = {nil,{{194482}},nil,nil,{{{17287},17287,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in the Shredder"),0,{{"monster",33706}}}},
        },
        [13708] = { -- Valiant Of Sen'jin
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [13712] = { -- To The Rescue
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak to Kadrak"),0,{{"monster",8582}}}},
            [questKeys.triggerEnd] = {"Splintertree Post Siege Broken",{[zoneIDs.ASHENVALE] = {{73.81,61.32}}}},
            [questKeys.objectives] = {},
        },
        [13730] = { -- Playing With Felfire
            [questKeys.preQuestSingle] = {13803},
        },
        [13766] = { -- Closure is Only Natural
            [questKeys.objectives] = {{{33767,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13796] = { -- The Forest Heart
            [questKeys.preQuestSingle] = {13792},
            [questKeys.requiredSourceItems] = {45571,45572},
        },
        [13798] = { -- Rain of Destruction
            [questKeys.objectives] = {{{33688}},nil,nil,nil,{{{33945,33195},33195,"Attacking elves slain"}}},
        },
        [13801] = { -- Dead Elves Walking
            [questKeys.preQuestSingle] = {13803},
        },
        [13806] = { -- Demon Duty
            [questKeys.preQuestSingle] = {26449},
        },
        [13808] = { -- Mission Improbable
            [questKeys.preQuestSingle] = {13805},
        },
        [13831] = { -- A Troubling Prescription
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {13528},
        },
        [13841] = { -- All Apologies
            [questKeys.preQuestSingle] = {13798},
            [questKeys.finishedBy] = {{39605}},
        },
        [13842] = { -- Dread Head Redemption
            [questKeys.finishedBy] = {{39605}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak to Durek"),0,{{"monster",44414}}}},
            [questKeys.objectives] = {nil,nil,{{60638}},nil,nil},
        },
        [13844] = { -- The Looting of Althalaxx
            [questKeys.preQuestSingle] = {13509},
        },
        [13845] = { -- Sealed Vial of Poison
            [questKeys.zoneOrSort] = 4613,
        },
        [13848] = { -- Bad News Bear-er
            [questKeys.preQuestSingle] = {13805},
        },
        [13849] = { -- Astranaar's Burning!
            [questKeys.objectives] = {{{34123,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13853] = { -- Return Fire
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",34132}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{34160,34163},34160}}},
        },
        [13865] = { -- Wet Work
            [questKeys.preQuestSingle] = {13808},
        },
        [13868] = { -- Corrupting Influence?
            [questKeys.startedBy] = {{3924,3925,3926},nil,{46128}},
        },
        [13869] = { -- Recover the Remains
            [questKeys.preQuestSingle] = {26454},
        },
        [13870] = { -- As Good as it Gets
            [questKeys.preQuestGroup] = {13865,13815},
        },
        [13871] = { -- Security!
            [questKeys.preQuestSingle] = {13870},
        },
        [13873] = { -- Sheelah's Last Wish
            [questKeys.preQuestSingle] = {13871},
        },
        [13876] = { -- Too Far Gone
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {13868},
        },
        [13879] = { -- Thunder Peak
            [questKeys.preQuestSingle] = {13947},
        },
        [13880] = { -- Hot Lava
            [questKeys.preQuestSingle] = {13877},
        },
        [13881] = { -- Consumed
            [questKeys.triggerEnd] = {"Watering Hole Investigated",{[zoneIDs.DARKSHORE] = {{45,79.1}}}},
        },
        [13884] = { -- Put Out The Fire
            [questKeys.preQuestSingle] = {13877},
        },
        [13885] = { -- In Defense of Darkshore
            [questKeys.objectives] = {nil,nil,nil,nil,{{{2165,34417},2165,nil,Questie.ICON_TYPE_EVENT},{{2071,2237,2070},2071,nil,Questie.ICON_TYPE_EVENT},{{34318,34396},34318,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Ask Orseus for a hippogryph"),0,{{"monster",34392}}}},
        },
        [13886] = { -- Vortex [Alliance]
            [questKeys.preQuestGroup] = {13880,13884},
            [questKeys.objectives] = {{{34295}}},
        },
        [13888] = { -- Vortex [Horde]
            [questKeys.preQuestGroup] = {13880,13884},
            [questKeys.objectives] = {{{34295}}},
        },
        [13891] = { -- The Devourer of Darkshore
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Destroy the Devouring Artifact"),0,{{"object",195057}}}},
        },
        [13892] = { -- Leave No Tracks
            [questKeys.objectives] = {{{34406,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13895] = { -- The Slumbering Ancients
            [questKeys.preQuestSingle] = {13893},
        },
        [13896] = { -- Unearthed Knowledge
            [questKeys.preQuestSingle] = {13948},
        },
        [13897] = { -- The Battle for Darkshore
            [questKeys.preQuestSingle] = {13900},
        },
        [13898] = { -- The Tides Turn Against Us
            [questKeys.preQuestSingle] = {13953},
        },
        [13900] = { -- The Offering to Azshara
            [questKeys.objectives] = {{{51314,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Darkscale Priestesses"),0,{{"monster",34415}}}},
        },
        [13902] = { -- Mounting the Offensive
            [questKeys.preQuestSingle] = {13588},
        },
        [13910] = { -- A New Home
            [questKeys.objectives] = {nil,{{195043}}},
        },
        [13911] = { -- The Absent-Minded Prospector
            [questKeys.triggerEnd] = {"Prospector Remtravel Escorted",{[zoneIDs.DARKSHORE] = {{37.69,82.94}}}},
        },
        [13913] = { -- They Took Our Gnomes
            [questKeys.objectives] = {{{39096}}},
        },
        [13918] = { -- The Titans' Terminal
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKSHORE] = {{37.1,80.4},{35.4,83.8},{35.2,86.5}}},Questie.ICON_TYPE_EVENT,l10n("Use the Buried Artifact Detector to collect 5 Ancient Device Fragment")}},
            [questKeys.requiredSourceItems] = {46702},
        },
        [13919] = { -- A Trip to the Moonwell
            [questKeys.preQuestSingle] = {26475},
            [questKeys.objectives] = {nil,{{301015,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13922] = { -- In the Hands of the Perverse
            [questKeys.preQuestSingle] = {13921},
        },
        [13924] = { -- All's Well
            [questKeys.preQuestSingle] = {13922},
        },
        [13925] = { -- An Ounce of Prevention
            [questKeys.objectives] = {nil,nil,nil,nil,{{{2071,2165,2237,34318},2071,"Lifebringer Sapling Tested",Questie.ICON_TYPE_INTERACT}}},
        },
        [13926] = { -- Little Orphan Roo Of The Oracles
            [questKeys.exclusiveTo] = {13927},
        },
        [13927] = { -- Little Orphan Kekek Of The Wolvar
            [questKeys.exclusiveTo] = {13926},
        },
        [13935] = { -- Defend the Tree!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Summon the Shade of Shadumbra"),0,{{"monster",34377}}}},
        },
        [13937] = { -- A Trip To The Wonderworks
            [questKeys.preQuestSingle] = {},
        },
        [13938] = { -- A Trip To The Wonderworks
            [questKeys.preQuestSingle] = {},
        },
        [13943] = { -- Breathing Room
            [questKeys.preQuestSingle] = {13936},
        },
        [13945] = { -- Resident Danger
            [questKeys.preQuestSingle] = {476},
        },
        [13946] = { -- Nature's Reprisal
            [questKeys.preQuestSingle] = {489},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{2002,2003,2004,2005},2002}}},
        },
        [13947] = { -- Blastranaar!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak with Thraka to begin the assault"),0,{{"monster",34429}}}},
        },
        [13948] = { -- Stepping Up Surveillance
            [questKeys.objectives] = {{{34326,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13949] = { -- Crossroads Caravan Pickup
            [questKeys.preQuestGroup] = {872, 5041},
        },
        [13952] = { -- The Grateful Dead
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.exclusiveTo] = {14166,14167,14168,14169,14170,14171,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [13953] = { -- Naga In Our Midst
            [questKeys.preQuestSingle] = {13895},
        },
        [13954] = { -- The Dragon Queen
            [questKeys.preQuestSingle] = {},
        },
        [13955] = { -- The Dragon Queen
            [questKeys.preQuestSingle] = {},
        },
        [13956] = { -- Meeting a Great One
            [questKeys.preQuestSingle] = {},
        },
        [13957] = { -- The Mighty Hemet Nesingwary
            [questKeys.preQuestSingle] = {},
        },
        [13958] = { -- Condition Critical!
            [questKeys.preQuestSingle] = {13947},
        },
        [13961] = { -- Drag it Out of Them
            [questKeys.triggerEnd] = {"Razormane Prisoner Delivered",{[zoneIDs.THE_BARRENS] = {{56.4,40.3}}}},
        },
        [13963] = { -- By Hook Or By Crook
            [questKeys.objectives] = {{{34523}}},
        },
        [13964] = { -- To the Spire
            [questKeys.preQuestSingle] = {26478},
            [questKeys.nextQuestInChain] = 26470,
        },
        [13965] = { -- Check in on the Edunes
            [questKeys.preQuestSingle] = {26478},
            [questKeys.nextQuestInChain] = 13976,
        },
        [13969] = { -- Grol'dom's Missing Kodo
            [questKeys.preQuestSingle] = {13963},
        },
        [13974] = { -- Tweedle's Tiny Parcel
            [questKeys.preQuestSingle] = {13947},
        },
        [13975] = { -- Crossroads Caravan Delivery
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Crossroads Caravan Escorted",{[zoneIDs.THE_BARRENS] = {{50.3,58.5}}}},
        },
        [13976] = { -- Three Friends of the Forest
            [questKeys.preQuestSingle] = {},
        },
        [13977] = { -- Mass Production
            [questKeys.preQuestSingle] = {13974},
        },
        [13982] = { -- In a Bind
            [questKeys.preQuestSingle] = {13976},
        },
        [13983] = { -- Building Your Own Coffin
            [questKeys.preQuestSingle] = {13977},
        },
        [13985] = { -- Clear the Shrine
            [questKeys.preQuestSingle] = {13982},
        },
        [13989] = { -- King of the Foulweald
            [questKeys.requiredSourceItems] = {46739},
        },
        [13998] = { -- In Fungus We Trust
            [questKeys.triggerEnd] = {"Fungal Culture Planted",{[zoneIDs.THE_BARRENS] = {{55.1,80.4},{57,78.9},{57.7,81.1}}}},
        },
        [14001] = { -- Goblin Escape Pods
            [questKeys.objectives] = {nil,nil,nil,nil,{{{34748,35649},34748,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Open the Goblin Escape Pod"), 0, {{"object", 195188}}}},
        },
        [14007] = { -- Steady Shot
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{56641}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 34673}}}},
        },
        [14008] = { -- Arcane Missiles
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{5143}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 34689}}}},
        },
        [14009] = { -- Flash Heal
            [questKeys.objectives] = {{{48305,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 34692}}}},
        },
        [14010] = { -- Eviscerate
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{2098}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 34693}}}},
        },
        [14011] = { -- Primal Strike
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{73899}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Primal Strike"), 2, {{"monster", 34695}}}},
        },
        [14012] = { -- Immolate
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{348}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 34696}}}},
        },
        [14013] = { -- Charge
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{100}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 34697}}}},
        },
        [14019] = { -- Monkey Business
            [questKeys.objectives] = {{{34699,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {14001},
        },
        [14021] = { -- Miner Troubles
            [questKeys.triggerEnd] = {"Kaja'mite Ore mining a success!",{[zoneIDs.THE_LOST_ISLES] = {{31.9,73.6}}}},
            [questKeys.objectives] = {nil,{{195622,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14031] = { -- Capturing the Unknown
            [questKeys.objectives] = {{{37872,nil,Questie.ICON_TYPE_EVENT},{37895,nil,Questie.ICON_TYPE_EVENT},{37896,nil,Questie.ICON_TYPE_EVENT},{37897,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14066] = { -- Investigate the Wreckage
            [questKeys.triggerEnd] = {"Caravan Scene Searched",{[zoneIDs.THE_BARRENS] = {{59.2,67.5}}}},
        },
        [14069] = { -- Good Help is Hard to Find
            [questKeys.objectives] = {{{34830,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14070] = { -- Do it Yourself
            [questKeys.sourceItemId] = 46856,
        },
        [14071] = { -- Rolling with my Homies
            [questKeys.objectives] = {{{48323},{34890,nil,Questie.ICON_TYPE_EVENT},{34892,nil,Questie.ICON_TYPE_EVENT},{34954,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.childQuests] = {28606},
            [questKeys.startedBy] = {{34874}},
        },
        [14078] = { -- Lockdown!
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.ROGUE + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [14094] = { -- Salvage the Supplies
            [questKeys.preQuestSingle] = {14078},
        },
        [14098] = { -- Evacuate the Merchant Square
            [questKeys.startedBy] = {{34913}},
            [questKeys.objectives] = {nil,{{195327}}},
        },
        [14099] = { -- Royal Orders
            [questKeys.preQuestGroup] = {14093,14098},
            [questKeys.preQuestSingle] = {},
        },
        [14109] = { -- The New You
            [questKeys.requiredSourceItems] = {47044},
            [questKeys.exclusiveTo] = {14110},
            [questKeys.sourceItemId] = 46856,
        },
        [14110] = { -- The New You
            [questKeys.requiredSourceItems] = {47044},
            [questKeys.exclusiveTo] = {14109},
            [questKeys.sourceItemId] = 46856,
        },
        [14113] = { -- Life of the Party
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14109,24520,14007}, -- 14007 or 14008 or 14009 or 14010 or 14011 or 14012 or 14013
            [questKeys.objectives] = {nil,nil,nil,nil,{{{35186,35175},35175,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14115] = { -- Pirate Party Crashers
            [questKeys.sourceItemId] = 46856,
        },
        [14121] = { -- Robbing Hoods
            [questKeys.childQuests] = {28607},
            [questKeys.sourceItemId] = 46856,
        },
        [14122] = { -- The Great Bank Heist
            [questKeys.startedBy] = {{34668}},
            [questKeys.sourceItemId] = 46856,
            [questKeys.objectives] = {{{35486,nil,Questie.ICON_TYPE_EVENT}},nil,{{46858}}},
        },
        [14123] = { -- Waltz Right In
            [questKeys.sourceItemId] = 46856,
        },
        [14124] = { -- Liberate the Kaja'mite
            [questKeys.requiredSourceItems] = {46856},
        },
        [14125] = { -- 447
            [questKeys.startedBy] = {{34668}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14121,14122,14123,14124},
            [questKeys.objectives] = {{{37598,nil,Questie.ICON_TYPE_EVENT}},{{201734},{201733},{201735}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Activate Gasbot after sabotaging the Headquarters"),0,{{"object",201736}}}},
        },
        [14126] = { -- Life Savings
            [questKeys.sourceItemId] = 46856,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Get on the yacht"),0,{{"object",207355},{"object",201791}}}},
        },
        [14127] = { -- Return of the Highborne?
            [questKeys.startedBy] = {{35095},nil,{47039}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [14129] = { -- Runaway Shredder!
            [questKeys.preQuestSingle] = {},
        },
        [14130] = { -- Friends Come In All Colors
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in"),0,{{"monster",36917}}}},
        },
        [14131] = { -- A Little Pick-me-up
            [questKeys.preQuestSingle] = {14130},
        },
        [14132] = { -- That's Just Rude!
            [questKeys.preQuestSingle] = {14130},
        },
        [14135] = { -- Up a Tree
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Cut down the tree"),0,{{"monster",35162}}}},
        },
        [14146] = { -- Defend the Gates!
            [questKeys.startedBy] = {{35086,35195}},
            [questKeys.finishedBy] = {{100007}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Get in if you don't have a shredder"),0,{{"monster",35196}}}},
        },
        [14138] = { -- Taking Care of Business
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.ROGUE + classKeys.PRIEST + classKeys.SHAMAN + classKeys.MAGE + classKeys.WARLOCK, -- no DKs for goblin starter quests
        },
        [14153] = { -- Life of the Party
            [questKeys.objectives] = {nil,nil,nil,nil,{{{35186,35175},35175,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14110,24520,14007}, -- 14007 or 14008 or 14009 or 14010 or 14011 or 14012 or 14013
        },
        [14154] = { -- By the Skin of His Teeth
            [questKeys.triggerEnd] = {"Survive while holding back the worgen for 2 minutes",{[zoneIDs.GILNEAS_CITY] = {{55.1,62.7}}}},
        },
        [14155] = { -- Arborcide
            [questKeys.startedBy] = {{35195}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Get in if you don't have a shredder"),0,{{"monster",35196}}}},
        },
        [14159] = { -- The Rebel Lord's Arsenal
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24930,26129},
        },
        [14161] = { -- Basilisk Bashin'
            [questKeys.preQuestSingle] = {},
        },
        [14162] = { -- Report to Horzak
            [questKeys.preQuestSingle] = {14155},
            [questKeys.exclusiveTo] = {14161},
        },
        [14165] = { -- Stone Cold
            [questKeys.objectives] = {{{35257,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.AZSHARA] = {{29.06,66.41}}},Questie.ICON_TYPE_EVENT,l10n("Deliver the Stonified Miner here")}},
        },
        [14166] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14167,14168,14169,14170,14171,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [14167] = { -- The Grateful Dead
            [questKeys.requiredRaces] = raceKeys.DWARF,
            [questKeys.exclusiveTo] = {13952,14166,14168,14169,14170,14171,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [14168] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14169,14170,14171,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [14169] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14170,14171,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [14170] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14171,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [14171] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14172,14173,14174,14175,14176,14177,27841,27846},
        },
        [14172] = { -- The Grateful Dead
            [questKeys.requiredMinRep] = {932,0},
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14173,14174,14175,14176,14177,27841,27846},
        },
        [14173] = { -- The Grateful Dead
            [questKeys.requiredMinRep] = {934,0},
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14174,14175,14176,14177,27841,27846},
        },
        [14174] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14173,14175,14176,14177,27841,27846},
        },
        [14175] = { -- The Grateful Dead
            [questKeys.requiredRaces] = raceKeys.ORC,
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14173,14174,14176,14177,27841,27846},
        },
        [14176] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14173,14174,14175,14177,27841,27846},
        },
        [14177] = { -- The Grateful Dead
            [questKeys.requiredRaces] = raceKeys.TROLL,
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14173,14174,14175,14176,27841,27846},
        },
        [14189] = { -- Translation
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak to Narimar"),0,{{"monster",35315}}}},
        },
        [14191] = { -- Furien's Footsteps
            [questKeys.objectives] = {{{35363,nil,Questie.ICON_TYPE_EVENT},{35367,nil,Questie.ICON_TYPE_EVENT},{35366,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14193] = { -- Nothing a Couple of Melons Won't Fix [Alliance]
            [questKeys.objectives] = {nil,{{195438}}},
            [questKeys.requiredSourceItems] = {48106},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [14194] = { -- Refleshification
            [questKeys.objectives] = {{{35257,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14195] = { -- All Becoming Clearer
            [questKeys.objectives] = {{{35382,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14196] = { -- Firestarter
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Slay Disciple of Elune"),0,{{"monster",35384}}}},
        },
        [14198] = { -- Rider on the Storm
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Raging Vortex Gem"),0,{{"monster",100030}}}},
        },
        [14201] = { -- A Thousand Stories in the Sand
            [questKeys.preQuestSingle] = {24453},
        },
        [14202] = { -- Survey the Lakeshore
            [questKeys.preQuestSingle] = {24453},
            [questKeys.objectives] = {{{35488,nil,Questie.ICON_TYPE_EVENT},{35487,nil,Questie.ICON_TYPE_EVENT},{35489,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14203] = { -- Waterlogged Recipe
            [questKeys.zoneOrSort] = 4613,
        },
        [14204] = { -- From the Shadows
            [questKeys.startedBy] = {{35378}},
        },
        [14209] = { -- Gunk in the Trunk
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Inspect the bulldozer"),0,{{"monster",35526}}}},
        },
        [14212] = { -- Sacrifices
            [questKeys.objectives] = {{{35229,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount Crowley's Horse"),0,{{"monster",44427}}}},
        },
        [14213] = { -- Ten Pounds of Flesh [Horde]
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.requiredSourceItems] = {48857},
            [questKeys.preQuestSingle] = {14189},
        },
        [14215] = { -- Memories of the Dead
            [questKeys.objectives] = {{{35595,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Touch the spirit"),0,{{"monster",35567}}}},
        },
        [14217] = { -- Satyrical Offerings
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.requiredSourceItems] = {48857},
            [questKeys.preQuestSingle] = {14213},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [14218] = { -- By Blood and Ash
            [questKeys.startedBy] = {{35618}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in a cannon"),0,{{"monster",35317}}}},
        },
        [14219] = { -- To the Hilt! [Horde]
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.objectives] = {nil,{{195517}}},
            [questKeys.requiredSourceItems] = {48943},
            [questKeys.preQuestSingle] = {14189},
        },
        [14222] = { -- Last Stand
            [questKeys.startedBy] = {{35566}},
        },
        [14223] = { -- Peace of Mind [Horde]
            [questKeys.preQuestSingle] = {14189},
        },
        [14226] = { -- Trouble Under Foot
            [questKeys.preQuestGroup] = {14249,14250,14263},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use Polymorph Insect on it"),0,{{"monster",6200},{"monster",6201},{"monster",6202}}}},
        },
        [14227] = { -- Putting Their Heads Together [Horde]
            [questKeys.requiredSourceItems] = {48953},
        },
        [14230] = { -- Manual Labor
            [questKeys.preQuestGroup] = {14249,14250,14263},
        },
        [14232] = { -- Ears Are Burning [Horde]
            [questKeys.startedBy] = {{4663,4664,4665,4666,4667},nil,{49010}},
        },
        [14233] = { -- Orcs Can Write?
            [questKeys.exclusiveTo] = {},
        },
        [14234] = { -- The Enemy of My Enemy
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14021,14031,14233},
        },
        [14242] = { -- Precious Cargo
            [questKeys.objectives] = {{{36145,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14244] = { -- Up, Up & Away!
            [questKeys.objectives] = {nil,{{196439}}},
        },
        [14245] = { -- It's a Town-In-A-Box
            [questKeys.objectives] = {nil,{{201938}}},
        },
        [14246] = { -- Early Adoption
            [questKeys.objectives] = {nil,{{195588}}},
        },
        [14248] = { -- Help Wanted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14014,14019,14473}
        },
        [14249] = { -- Shear Will
            [questKeys.preQuestSingle] = {14340},
        },
        [14250] = { -- Renewable Resource
            [questKeys.preQuestSingle] = {14340},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Arcane Charge in Balboa's path"), 0, {{"monster", 35759}}}},
        },
        [14255] = { -- Ethel Rethor -- #6159
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.preQuestSingle] = {14189},
            [questKeys.nextQuestInChain] = 14256,
        },
        [14256] = { -- The Emerging Threat
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Korrah"), 2, {{"monster", 35773}}}},
        },
        [14261] = { -- Ice Cold
            [questKeys.preQuestSingle] = {14391},
        },
        [14262] = { -- To Gut a Fish
            [questKeys.preQuestSingle] = {14258},
        },
        [14263] = { -- Waste of Thyme
            [questKeys.preQuestSingle] = {14340},
        },
        [14264] = { -- Wetter Than Wet
            [questKeys.objectives] = {{{35842,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14266] = { -- Charge
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 35839}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14267] = { -- Investigating the Sea Shrine
            [questKeys.preQuestSingle] = {14258},
        },
        [14268] = { -- Deep Impact
            [questKeys.requiredSourceItems] = {49102},
        },
        [14272] = { -- Eviscerate
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 35871}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14274] = { -- Immolate
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 35869}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14276] = { -- Steady Shot
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 35874}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14279] = { -- Flash Heal
            [questKeys.objectives] = {{{47091,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 35870}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14281] = { -- Arcane Missiles
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 35872}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14283] = { -- A Rejuvenating Touch
            [questKeys.objectives] = {{{47091,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{774}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Rejuvenation"), 2, {{"monster", 35873}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14284] = { -- A Revenant's Vengeance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Lord Hydronis"), 2, {{"monster", 35902}}}},
        },
        [14293] = { -- Save Krennan Aranas
            [questKeys.objectives] = {{{35753,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14295] = { -- Sisters of the Sea
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_INTERACT, l10n("Break the Power Stone"), 0, {{"monster", 35892},{"monster", 35968}}},
            },
        },
        [14296] = { -- Watch Your Step
            [questKeys.objectives] = {nil,{{195365,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14297] = { -- Pro-liberation
            [questKeys.preQuestSingle] = {14391},
            [questKeys.requiredSourceItems] = {49533},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Open the cage"), 0, {{"object", 197332}}}},
            [questKeys.objectives] = {{{36722,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14299] = { -- Xylem's Asylum
            [questKeys.preQuestGroup] = {14300,24478,24479},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Take the portal to Xylem's Tower"), 0, {{"object", 201606}}}},
        },
        [14300] = { -- The Trial of Fire
            [questKeys.preQuestSingle] = {14296},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_EVENT,l10n("Touch the Fire Portal Stone"),0,{{"object",196460}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Go to your trial"),0,{{"object",195678}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Go back"),0,{{"object",195681}}},
            },
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Fire Trial Completed",{[zoneIDs.AZSHARA] = {{33.43,23.39}}}},
        },
        [14304] = { -- Blood Theory
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Throw Bottle of Leeches"), 0, {{"monster", 35412}}}},
        },
        [14308] = { -- When Science Attacks
            [questKeys.objectives] = {{{36025,nil,Questie.ICON_TYPE_EVENT},{36061,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
        },
        [14309] = { -- Calming the Kodo
            [questKeys.objectives] = {{{36094,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14310] = { -- Segmentation Fault: Core Dumped
            [questKeys.objectives] = {{{36105,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Reactor Control Console"), 0, {{"object", 195683}}}},
        },
        [14311] = { -- Taking Part
            [questKeys.preQuestSingle] = {14305},
            [questKeys.objectives] = {{{36123,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14312] = { -- An Introduction Is In Order
            [questKeys.preQuestSingle] = {14311},
        },
        [14316] = { -- Cenarion Property
            [questKeys.preQuestSingle] = {14312},
        },
        [14318] = { -- Delicate Negotiations
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Khan Leh'prah"), 0, {{"monster", 36056}}}},
        },
        [14323] = { -- Absorbent
            [questKeys.preQuestSingle] = {14130},
        },
        [14324] = { -- Full of Hot Water
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Scalding Water Lord"), 0, {{"object", 195711}}}},
        },
        [14330] = { -- Behind Closed Doors
            [questKeys.startedBy] = {{4656},nil,{38567}},
            [questKeys.preQuestSingle] = {14328},
        },
        [14333] = { -- While You're Here
            [questKeys.requiredSourceItems] = {49194},
        },
        [14335] = { -- Chipping In
            [questKeys.preQuestGroup] = {5421,14334}, -- #6449
        },
        [14337] = { -- Shadowprey Village
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.preQuestSingle] = {14325}, -- Uncertain if correct but would mirror Alliance equivalent and definitely improves existing state
        },
        [14338] = { -- Ghost Walker Post
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.preQuestSingle] = {14311},
        },
        [14340] = { -- Dressed to Impress
            [questKeys.objectives] = {{{35187,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14345] = { -- Wash Out
            [questKeys.preQuestGroup] = {14131,14132,14324},
        },
        [14346] = { -- Cleansing Our Crevasse [Horde]
            [questKeys.objectives] = {{{36227,nil,Questie.ICON_TYPE_MOUNT_UP},{35606,nil,Questie.ICON_TYPE_INTERACT},{90,nil,Questie.ICON_TYPE_INTERACT},{35605,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14348] = { -- You Can't Take 'Em Alone
            [questKeys.objectives] = {{{36231}}},
            [questKeys.requiredSourceItems] = {49202},
        },
        [14357] = { -- To the Hilt! [Alliance]
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,{{195517}}},
            [questKeys.requiredSourceItems] = {48943},
        },
        [14358] = { -- Ten Pounds of Flesh [Alliance]
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.requiredSourceItems] = {48857},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [14359] = { -- Blessings From Above
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.preQuestSingle] = {14358},
            [questKeys.requiredSourceItems] = {48857},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [14360] = { -- Nothing a Couple of Melons Won't Fix [Horde]
            [questKeys.objectives] = {nil,{{195438}}},
            [questKeys.requiredSourceItems] = {48106},
        },
        [14361] = { -- Peace of Mind
            [questKeys.preQuestSingle] = {14354},
        },
        [14362] = { -- Ears Are Burning [Alliance]
            [questKeys.startedBy] = {{4663,4664,4665,4666,4667},nil,{49203}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [14364] = { -- Putting Their Heads Together [Alliance]
            [questKeys.requiredSourceItems] = {48953},
        },
        [14365] = { -- Ethel Rethor
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {14354},
        },
        [14366] = { -- Holding Steady
            [questKeys.preQuestGroup] = {14347,14348},
            [questKeys.preQuestSingle] = {},
        },
        [14368] = { -- Save the Children!
            [questKeys.objectives] = {{{36287,nil,Questie.ICON_TYPE_INTERACT},{36288,nil,Questie.ICON_TYPE_INTERACT},{36289,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14369] = { -- Unleash the Beast
            [questKeys.objectives] = {nil,nil,nil,nil,{{{36236,36396,36810},36236}}},
        },
        [14370] = { -- Mysterious Azsharite
            [questKeys.preQuestSingle] = {14310},
        },
        [14371] = { -- A Gigantic Snack
            [questKeys.preQuestSingle] = {14310},
        },
        [14372] = { -- Thargad's Camp
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [14376] = { -- Jugkar's Undoing
            [questKeys.startedBy] = {{4676,35591},nil,{49220}},
        },
        [14377] = { -- Befriending Giants
            [questKeys.preQuestGroup] = {14370,14371},
            [questKeys.objectives] = {{{36297,nil,Questie.ICON_TYPE_TALK}}},
        },
        [14378] = { -- Hunting Brendol
            [questKeys.preQuestGroup] = {14373,14374},
        },
        [14379] = { -- Rock Lobstrock!
            [questKeys.preQuestGroup] = {14373,14374},
        },
        [14381] = { -- Cleansing Our Crevasse [Alliance]
            [questKeys.objectives] = {{{36227,nil,Questie.ICON_TYPE_MOUNT_UP},{35606,nil,Questie.ICON_TYPE_INTERACT},{90,nil,Questie.ICON_TYPE_INTERACT},{35605,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14382] = { -- Two By Sea
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Use the catapult to board the ship"),0,{{"monster",36283}}},
                {nil,Questie.ICON_TYPE_SLAY,l10n("Take out the Forsaken Machinist"),0,{{"monster",36292}}},
            },
        },
        [14383] = { -- The Terrible Tinkers of the Ruined Reaches
            [questKeys.preQuestSingle] = {14377},
        },
        [14385] = { -- Azsharite Experiment Number One
            [questKeys.objectives] = {{{36297,nil,Questie.ICON_TYPE_TALK}},nil,{{49230}}},
        },
        [14386] = { -- Leader of the Pack
            [questKeys.preQuestGroup] = {14368,14369,14382},
            [questKeys.preQuestSingle] = {},
        },
        [14388] = { -- Azsharite Experiment Number Two
            [questKeys.objectives] = {{{36297,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get on a Rocketway Rat after you got shrunk"),0,{{"monster",36437}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Assistant Greely"),0,{{"monster",36077}}},
            },
        },
        [14389] = { -- Wasn't It Obvious?
            [questKeys.triggerEnd] = {"Find Anara, and hopefully, Azuregos",{[zoneIDs.AZSHARA] = {{27.7,40.4}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Take the portal"), 0, {{"object", 196474}}}},
        },
        [14390] = { -- Easy is Boring
            [questKeys.objectives] = {{{36436,nil,Questie.ICON_TYPE_TALK}}},
        },
        [14391] = { -- Turning the Tables
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Revive"), 0, {{"monster", 37040}}}},
        },
        [14392] = { -- Farewell, Minnow
            [questKeys.preQuestGroup] = {24467,14261,14297},
        },
        [14393] = { -- Into the Fray!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Speak to Khan Leh'Prah"), 0, {{"monster", 36398}}}},
        },
        [14394] = { -- Death to Agogridon
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Speak to Khan Leh'Prah"), 0, {{"monster", 36398}}}},
        },
        [14395] = { -- Gasping for Breath
            [questKeys.objectives] = {{{36440,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14400] = { -- I Can't Wear This
            [questKeys.exclusiveTo] = {},
        },
        [14401] = { -- Grandma's Cat
            [questKeys.exclusiveTo] = {},
        },
        [14402] = { -- Ready to Go
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14401,14404,14412,14416},
            [questKeys.exclusiveTo] = {14405,14463},
        },
        [14404] = { -- Not Quite Shipshape
            [questKeys.exclusiveTo] = {},
        },
        [14405] = { -- Escape By Sea
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14401,14404,14412,14416},
            [questKeys.exclusiveTo] = {14402,14463},
        },
        [14408] = { -- Nine's Plan
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{36472,nil,Questie.ICON_TYPE_INTERACT}},nil,{{49204}}},
        },
        [14410] = { -- The Wilds of Feralas [Alliance]
            [questKeys.preQuestGroup] = {14381,14394},
            [questKeys.exclusiveTo] = {25447,28511},
        },
        [14412] = { -- Washed Up
            [questKeys.preQuestSingle] = {14403},
        },
        [14413] = { -- The Pinnacle of Learning
            [questKeys.preQuestGroup] = {14226,14230},
        },
        [14416] = { -- The Hungry Ettin
            [questKeys.objectives] = {{{36540,nil,Questie.ICON_TYPE_MOUNT_UP}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Bring the horses to Lorna Crowley"),0,{{"monster",36457}}}},
            [questKeys.exclusiveTo] = {},
        },
        [14422] = { -- Raptor Raptor Rocket
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",196486}}},
                {nil,Questie.ICON_TYPE_EVENT,l10n("Bring the raptors to The Velocistar"),0,{{"monster",36527}}},
            },
            [questKeys.objectives] = {{{36509,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14424] = { -- Need More Science
            [questKeys.preQuestSingle] = {14423},
            [questKeys.exclusiveTo] = {14308},
        },
        [14430] = { -- Hacking the Construct
            [questKeys.objectives] = {{{36599,nil,Questie.ICON_TYPE_TALK}}},
        },
        [14432] = { -- A Pale Brew
            [questKeys.preQuestSingle] = {14431},
        },
        [14433] = { -- Diplomacy by Another Means
            [questKeys.preQuestSingle] = {14431},
        },
        [14435] = { -- The Blackmaw Doublecross
            [questKeys.preQuestGroup] = {14432,14433},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Andorel Sunsworn while in disguise"),0,{{"monster",36596}}}},
            [questKeys.objectives] = {{{36618},{36013},{36012}}},
        },
        [14442] = { -- My Favorite Subject
            [questKeys.exclusiveTo] = {14408},
            [questKeys.preQuestSingle] = {14322},
        },
        [14449] = { -- The First Step
            [questKeys.zoneOrSort] = 215,
        },
        [14452] = { -- Rite of Strength
            [questKeys.zoneOrSort] = 215,
        },
        [14455] = { -- Stop the Thorncallers
            [questKeys.zoneOrSort] = 215,
        },
        [14456] = { -- Rite of Courage
            [questKeys.zoneOrSort] = 215,
        },
        [14458] = { -- Go to Adana
            [questKeys.zoneOrSort] = 215,
        },
        [14459] = { -- The Battleboars
            [questKeys.zoneOrSort] = 215,
            [questKeys.preQuestGroup] = {14455,14456},
            [questKeys.preQuestSingle] = {},
        },
        [14460] = { -- Rite of Honor
            [questKeys.zoneOrSort] = 215,
            [questKeys.preQuestGroup] = {14459,14461},
            [questKeys.preQuestSingle] = {},
        },
        [14461] = { -- Feed of Evil
            [questKeys.zoneOrSort] = 215,
            [questKeys.preQuestGroup] = {14455,14456},
            [questKeys.preQuestSingle] = {},
        },
        [14463] = { -- Horses for Duskhaven
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14401,14404,14412,14416},
            [questKeys.exclusiveTo] = {14402,14405},
        },
        [14464] = { -- Lightning Strike Assassination
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Jump on!"),0,{{"monster",36761}}}},
        },
        [14468] = { -- Another Warm Body
            [questKeys.preQuestGroup] = {14161,14194,14197},
        },
        [14469] = { -- Hand-me-downs
            [questKeys.preQuestSingle] = {14468},
        },
        [14470] = { -- Military Breakthrough
            [questKeys.preQuestSingle] = {14468},
        },
        [14471] = { -- First Degree Mortar
            [questKeys.preQuestSingle] = {14468},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the mortar"),0,{{"monster",36768}}}},
        },
        [14472] = { -- In The Face!
            [questKeys.preQuestGroup] = {14469,14470,14471},
        },
        [14473] = { -- It's Our Problem Now
            [questKeys.preQuestSingle] = {14001},
        },
        [14477] = { -- Push the Button!
            [questKeys.objectives] = {nil,{{460003,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14478] = { -- Operation Fishgut
            [questKeys.preQuestSingle] = {24452},
        },
        [14480] = { -- Extermination
            [questKeys.preQuestSingle] = {24448},
        },
        [14482] = { -- Call of Duty
            [questKeys.objectives] = {},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORMWIND_CITY] = {{18.3,25.5}}},Questie.ICON_TYPE_EVENT,l10n("Wait for the Mercenary Ship to arrive")}},
            [questKeys.zoneOrSort] = 4411,
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Ride the mercenary ship to Vashj'ir",{[zoneIDs.KELP_THAR_FOREST] = {{53.9,39.9}}}},
        },
        [14484] = { -- Head of the Snake
            [questKeys.preQuestSingle] = {24448},
        },
        [14485] = { -- Ticker Required
            [questKeys.preQuestSingle] = {24448},
            [questKeys.objectives] = {nil,{{199333,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14486] = { -- Handling the Goods
            [questKeys.preQuestSingle] = {24448},
        },
        [14487] = { -- Still Beating Heart
            [questKeys.preQuestSingle] = {24448},
        },
        [14491] = { -- The Restless Earth
            [questKeys.objectives] = {{{36845,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [20441] = { -- Rite of Vision
            [questKeys.preQuestSingle] = {24456},
            [questKeys.objectives] = {nil,{{18035}}},
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [23733] = { -- Rites of the Earthmother
            [questKeys.zoneOrSort] = 215,
        },
        [24215] = { -- Rite of the Winds
            [questKeys.zoneOrSort] = 215,
        },
        [24429] = { -- A Most Puzzling Circumstance
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24430] = { -- Blacken the Skies
            [questKeys.preQuestSingle] = {14477},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",36900}}}},
            [questKeys.objectives] = {{{36890},{36906,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24432] = { -- Sea Legs
            [questKeys.preQuestSingle] = {},
        },
        [24436] = { -- Halo Drops
            [questKeys.preQuestSingle] = {14479},
            [questKeys.objectives] = {{{36922,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [24437] = { -- First Come, First Served
            [questKeys.objectives] = {{{36953,nil,Questie.ICON_TYPE_EVENT},{36952,nil,Questie.ICON_TYPE_EVENT},{36951,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24438] = { -- Exodus
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Board the carriage"),0,{{"monster",38755},{"monster",44928}}}},
        },
        [24439] = { -- The Conquest of Azshara
            [questKeys.preQuestSingle] = {24430},
        },
        [24440] = { -- Winterhoof Cleansing
            [questKeys.preQuestSingle] = {20440},
            [questKeys.triggerEnd] = {"Cleanse the Winterhoof Water Well",{[zoneIDs.MULGORE] = {{53.51,65.38}}}},
        },
        [24448] = { -- Field Promotion
            [questKeys.preQuestGroup] = {24435,24436,24437},
        },
        [24449] = { -- Shore Leave
            [questKeys.preQuestGroup] = {14480,14484,14485,14486,14487},
        },
        [24452] = { -- Profitability Scouting
            [questKeys.objectives] = {nil,{{200298,"Heart of Arkkoroc identified"}}},
            [questKeys.preQuestSingle] = {14472},
        },
        [24456] = { -- Thunderhorn Cleansing
            [questKeys.triggerEnd] = {"Cleanse the Thunderhorn Water Well",{[zoneIDs.MULGORE] = {{44.8,45.56}}}},
        },
        [24457] = { -- Rite of Vision
            [questKeys.nextQuestInChain] = 20441,
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [24458] = { -- A Hello to Arms
            [questKeys.preQuestSingle] = {14388}, -- might need 14295 too
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take a free airlift"),0,{{"monster",37005}}}},
            [questKeys.objectives] = {{{37009,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24459] = { -- Morin Cloudstalker
            [questKeys.nextQuestInChain] = 749,
        },
        [24463] = { -- Probing into Ashenvale
            [questKeys.preQuestSingle] = {24439},
            [questKeys.exclusiveTo] = {13612,13866,28493},
        },
        [24467] = { -- Fade to Black
            [questKeys.preQuestSingle] = {14391},
        },
        [24468] = { -- Stranded at the Marsh
            [questKeys.objectives] = {{{37067,"Crash Survivor rescued",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Rescue the Crash Survivor"),0,{{"monster",37078}}}},
        },
        [24471] = { -- Aid For The Wounded
            [questKeys.objectives] = {{{37080,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [24473] = { -- Lockdown in Anvilmar
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24470,24471},
        },
        [24478] = { -- The Trial of Frost
            [questKeys.preQuestSingle] = {14296},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_EVENT,l10n("Touch the Frost Portal Stone"),0,{{"object",196459}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Go to your trial"),0,{{"object",195680}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Go back"),0,{{"object",195681}}},
            },
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Frost Trial Completed",{[zoneIDs.AZSHARA] = {{61.81,20.46}}}},
        },
        [24479] = { -- The Trial of Shadow
            [questKeys.preQuestSingle] = {14296},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_EVENT,l10n("Touch the Shadow Portal Stone"),0,{{"object",196461}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Go to your trial"),0,{{"object",195364}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Go back"),0,{{"object",195681}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Begin your trial"),0,{{"object",201597}}},
            },
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Shadow Trial Completed",{[zoneIDs.AZSHARA] = {{31.02,27.82}}}},
        },
        [24487] = { -- Whitebeard Needs Ye
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24475,24486},
        },
        [24489] = { -- Trolling For Information
            [questKeys.objectives] = {{{37108,nil,Questie.ICON_TYPE_EVENT},{37173,nil,Questie.ICON_TYPE_EVENT},{37174,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 218,
        },
        [24490] = { -- A Trip to Ironforge
            [questKeys.nextQuestInChain] = 24491,
        },
        [24491] = { -- Follow that Gyro-Copter!
            [questKeys.nextQuestInChain] = 24492,
        },
        [24493] = { -- Don't Forget About Us
            [questKeys.exclusiveTo] = {25724},
        },
        [24494] = { -- Empowered Rune -- Dwarf Shaman
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24496] = { -- Arcane Rune -- Dwarf Mage
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24497] = { -- Airborne Again
            [questKeys.preQuestSingle] = {14392},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Secure a ride to Valormok"),0,{{"monster",37139}}}},
        },
        [24502] = { -- Necessary Roughness
            [questKeys.objectives] = {{{48526,nil,Questie.ICON_TYPE_MOUNT_UP},{37114}}},
            [questKeys.finishedBy] = {{100005}},
            [questKeys.startedBy] = {{37106}},
        },
        [24503] = { -- Fourth and Goal
            [questKeys.objectives] = {{{37203,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.startedBy] = {{37106,100006}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 48526}}}},
            [questKeys.exclusiveTo] = {28414},
        },
        [24512] = { -- Warriors' Redemption
            [questKeys.requiredSourceItems] = {49769},
            [questKeys.objectives] = {{{37167,"Stonetalon Prisoner Armed",Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Acquire crates of Confiscated Arms"),0,{{"object",201701}}}},
        },
        [24518] = { -- The Low Road
            [questKeys.startedBy] = {{37216}},
        },
        [24520] = { -- Give Sassy the News
            [questKeys.sourceItemId] = 46856,
        },
        [24524] = { -- Wildmane Cleansing
            [questKeys.triggerEnd] = {"Cleanse the Wildmane Well",{[zoneIDs.MULGORE] = {{43.18,16.09}}}},
        },
        [24526] = { -- Filling Up the Spellbook
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 37121}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24527] = { -- Your Path Begins Here
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{73899}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Primal Strike"), 2, {{"monster", 37115}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24528] = { -- The Power of the Light
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{20271},{20154}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Judgement"), 2, {{"monster", 926}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Seal of Righteousness"), 3, {{"monster", 926}}},
            },
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24530] = { -- Oh, A Hunter's Life For Me
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 895}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24531] = { -- Getting Battle-Ready
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 912}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24532] = { -- Evisceratin' the Enemy
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 916}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24533] = { -- Words of Power
            [questKeys.objectives] = {{{44405,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 837}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [24540] = { -- War Dance
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [24543] = { -- A Family Divided
            [questKeys.preQuestSingle] = {24529},
        },
        [24546] = { -- A Line in the Dirt
            [questKeys.preQuestSingle] = {},
        },
        [24550] = { -- Journey into Thunder Bluff
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [24566] = { -- Sowing a Solution
            [questKeys.preQuestGroup] = {24570,24571},
        },
        [24567] = { -- Report for Tryouts
            [questKeys.sourceItemId] = 46856,
        },
        [24569] = { -- Siegebreaker
            [questKeys.preQuestGroup] = {24546,24551},
        },
        [24575] = { -- Liberation Day
            [questKeys.requiredSourceItems] = {49881},
            [questKeys.objectives] = {{{37694,"Enslaved Gilnean freed",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Unlock the Ball and Chain"),0,{{"object",201775}}}},
        },
        [24577] = { -- Desolation Hold Inspection
            [questKeys.objectives] = {{{37811,"Gar'dul Notified",Questie.ICON_TYPE_TALK}}},
        },
        [24593] = { -- Neither Human Nor Beast
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24646,24628},
        },
        [24597] = { -- A Gift for the King of Stormwind
            [questKeys.finishedBy] = {{29611}},
        },
        [24606] = { -- Blood of the Barrens
            [questKeys.startedBy] = {{37560,37660,37661},nil,{49932}},
        },
        [24612] = { -- A Gift for the Emissary of Orgrimmar
            [questKeys.finishedBy] = {{39605}},
        },
        [24618] = { -- Claim the Battle Scar
            [questKeys.preQuestSingle] = {24591},
            [questKeys.objectives] = {{{37923}},{{201879,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24622] = { -- A Troll's Truest Companion
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24623] = { -- Saving the Young
            [questKeys.objectives] = {{{39157,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24624] = { -- Mercy for the Lost
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24625] = { -- Consort of the Sea Witch
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24626] = { -- Young and Vicious
            [questKeys.startedBy] = {{37969}},
            [questKeys.objectives] = {{{37989,nil,Questie.ICON_TYPE_INTERACT},{38002,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24623,24624,24625},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24628] = { -- Preparations
            [questKeys.preQuestSingle] = {24617},
        },
        [24633] = { -- Mahka's Plea
            [questKeys.preQuestSingle] = {24653},
            [questKeys.objectives] = {{{37847,nil,Questie.ICON_TYPE_TALK}}},
        },
        [24634] = { -- Intelligence Warfare
            [questKeys.preQuestSingle] = {24591},
        },
        [24637] = { -- The Butcher of Taurajo
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak with Karthog to lure out General Hawthorne"),0,{{"monster",38015}}}},
        },
        [24639] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24640] = { -- The Arts of a Warrior
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 38037}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24641] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24642] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24643] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24671] = { -- Cluster Cluck
            [questKeys.objectives] = {{{38111}}},
            [questKeys.preQuestSingle] = {14245},
        },
        [24676] = { -- Push Them Out
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24675,24674,24575},
        },
        [24677] = { -- Flank the Forsaken
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Lord Hewell for a horse"),0,{{"monster",38764}}}},
        },
        [24679] = { -- Patriarch's Blessing
            [questKeys.objectives] = {nil,{{201964}}},
        },
        [24681] = { -- They Have Allies, But So Do We
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in a Glaive Thrower"),0,{{"monster",38150}}}},
        },
        [24684] = { -- A Weezil in the Henhouse
            [questKeys.preQuestSingle] = {},
        },
        [24691] = { -- Peculiar Delicacies
            [questKeys.preQuestSingle] = {24690},
        },
        [24692] = { -- The Fledgling Colossus
            [questKeys.preQuestSingle] = {24690},
        },
        [24694] = { -- The Shaper's Terrace
            [questKeys.preQuestGroup] = {24720,24721,24722,24723},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to the Un'Goro Examinant"),0,{{"monster",38504}}}},
        },
        [24695] = { -- Ever Watching From Above
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Pull the lever"),0,{{"object",202187}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Pull the lever"),0,{{"object",202195}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Pull the lever"),0,{{"object",202196}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Pull the lever"),0,{{"object",202197}}}
            },
        },
        [24697] = { -- How to Make Meat Fresh Again
            [questKeys.objectives] = {{{9163,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [24698] = { -- Adventures in Archaeology
            [questKeys.preQuestSingle] = {24693},
            [questKeys.nextQuestInChain] = 24730,
        },
        [24700] = { -- Hard to Harvest
            [questKeys.preQuestSingle] = {24693},
        },
        [24701] = { -- Marshal's Refuse
            [questKeys.preQuestSingle] = {24693},
        },
        [24702] = { -- Here Lies Dadanga
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24703] = { -- An Important Lesson
            [questKeys.objectives] = {{{38237,nil,Questie.ICON_TYPE_TALK}}},
        },
        [24704] = { -- The Evil Dragons of Un'Goro Crater
            [questKeys.preQuestSingle] = {24703},
        },
        [24705] = { -- Town Dwellers Were Made to be Saved
            [questKeys.name] = 'Town Dwellers Were Made to be Saved',
            [questKeys.preQuestSingle] = {24703},
            [questKeys.objectives] = {{{38238,nil,Questie.ICON_TYPE_EVENT},{38239,nil,Questie.ICON_TYPE_EVENT},{38240,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [24706] = { -- The Spirits of Golakka Hot Springs
            [questKeys.preQuestGroup] = {24704,24705},
            [questKeys.objectives] = {{{38254,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [24707] = { -- The Ballad of Maximillian
            [questKeys.preQuestSingle] = {24706},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Speak to Maximillian"),0,{{"monster",38237}}}},
        },
        [24714] = { -- Chasing A-Me 01
            [questKeys.preQuestSingle] = {24701},
        },
        [24715] = { -- Repairing A-Me 01
            [questKeys.requiredSourceItems] = {50237,50238},
        },
        [24717] = { -- The Apes of Un'Goro
            [questKeys.preQuestSingle] = {24701},
        },
        [24719] = { -- Claws of White
            [questKeys.preQuestSingle] = {},
        },
        [24721] = { -- The Eastern Pylon
            [questKeys.objectives] = {nil,{{164957,"Discover and examine the Eastern Crystal Pylon"}}},
        },
        [24722] = { -- The Northern Pylon
            [questKeys.preQuestSingle] = {24717},
            [questKeys.objectives] = {nil,{{164955,"Discover and examine the Northern Crystal Pylon"}}},
        },
        [24723] = { -- The Western Pylon
            [questKeys.objectives] = {nil,{{164956,"Discover and examine the Western Crystal Pylon"}}},
        },
        [24724] = { -- Crystal Restore
            [questKeys.preQuestSingle] = {24695},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24725] = { -- Crystal Charge
            [questKeys.preQuestSingle] = {24695},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24726] = { -- Crystal Force
            [questKeys.preQuestSingle] = {24695},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24727] = { -- Crystal Spire
            [questKeys.preQuestSingle] = {24695},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24728] = { -- Crystal Ward
            [questKeys.preQuestSingle] = {24695},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24729] = { -- Crystal Yield
            [questKeys.preQuestSingle] = {24695},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24730] = { -- Roll the Bones
            [questKeys.preQuestSingle] = {},
        },
        [24733] = { -- The Bait for Lar'korwi
            [questKeys.requiredSourceItems] = {11569,11570},
            [questKeys.sourceItemId] = 11568,
        },
        [24735] = { -- A Little Help From My Friends
            [questKeys.preQuestSingle] = {24734},
            [questKeys.triggerEnd] = {"Escort Ringo to Marshal's Stand", {[zoneIDs.UN_GORO_CRATER]={{54.88,62.07}}}},
        },
        [24737] = { -- Super Sticky
            [questKeys.preQuestSingle] = {24693},
        },
        [24740] = { -- Volcanic Activity
            [questKeys.preQuestSingle] = {},
        },
        [24741] = { -- Trading Up
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Place the Wild Clucker Eggs in the trap"),0,{{"object",201972}}}},
        },
        [24742] = { -- Finding the Source
            [questKeys.objectives] = {{{10541,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [24744] = { -- The Biggest Egg Ever
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Mechachicken"),0,{{"monster",38224}}}},
        },
        [24751] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24752] = { -- The Arts of a Mage
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 38246}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24753] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24754] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24755] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24759] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24760] = { -- The Arts of a Shaman
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{73899}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Primal Strike"), 2, {{"monster", 38242}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24761] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24762] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24763] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24765] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24766] = { -- The Arts of a Druid
            [questKeys.objectives] = {{{47057,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{774}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Rejuvenation"), 2, {{"monster", 38243}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24767] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24768] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24769] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24771] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24772] = { -- The Arts of a Rogue
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 38244}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24773] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24774] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24775] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24777] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24778] = { -- The Arts of a Hunter
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 38247}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24779] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24780] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24781] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24783] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24784] = { -- The Arts of a Priest
            [questKeys.objectives] = {{{47057,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 38245}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [24785] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24786] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24787] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24794] = { -- Speak With Spraggle
            [questKeys.nextQuestInChain] = 24736,
        },
        [24807] = { -- Winnoa Pineforest
            [questKeys.preQuestSingle] = {24601},
        },
        [24812] = { -- No More Mercy
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24813] = { -- Territorial Fetish
            [questKeys.objectives] = {nil,{{202113}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24814] = { -- An Ancient Enemy
            [questKeys.objectives] = {{{38225,nil,Questie.ICON_TYPE_TALK},{38306}}},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("After Zar'jira is defeated, take a portal back to Darkspear Hold"),0,{{"monster",38437}}},
                {nil,Questie.ICON_TYPE_INTERACT,l10n("Put out the fires"),0,{{"monster",38542}}},
            },
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [24817] = { -- A Goblin in Shark's Clothing
            [questKeys.objectives] = {{{36682}},{{202108}}},
        },
        [24852] = { -- Our Tribe, Imprisoned
            [questKeys.zoneOrSort] = 215,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",202112}}}},
            [questKeys.objectives] = {{{38345,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [24854] = { -- Finding Stormclaw
            [questKeys.nextQuestInChain] = 24719,
        },
        [24861] = { -- Last Rites, First Rites
            [questKeys.zoneOrSort] = 215,
            [questKeys.objectives] = {{{38438,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24864] = { -- Irresistible Pool Pony
            [questKeys.objectives] = {nil,nil,nil,nil,{{{38412,44578,44579,44580},38412,"Naga Hatchling lured",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24858,24859},
        },
        [24901] = { -- Town-In-A-Box: Under Attack
            [questKeys.objectives] = {{{38531}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get on the B.C. Eliminator"),0,{{"monster",38526}}}},
        },
        [24902] = { -- The Hunt For Sylvanas
            [questKeys.triggerEnd] = {"Hunt for Sylvanas",{[zoneIDs.GILNEAS_CITY] = {{44.9,52.3}}}},
        },
        [24904] = { -- The Battle for Gilneas City
            [questKeys.objectives] = {{{38469}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Krennan Aranas to join the battle"),0,{{"monster",38553}}}},
        },
        [24905] = { -- Returning a Favor [Horde]
            [questKeys.preQuestSingle] = {24953},
            [questKeys.exclusiveTo] = {24955},
        },
        [24910] = { -- Rocket Rescue
            [questKeys.objectives] = {{{38571},{40583}}},
            [questKeys.preQuestGroup] = {24907,24906},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in the balloon"),0,{{"monster",40604}}}},
        },
        [24920] = { -- Slowing the Inevitable
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get on the Captured Riding Bat"),0,{{"monster",38615}}}},
        },
        [24925] = { -- Free the Captives
            [questKeys.objectives] = {{{38643,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Oomlot Shaman"),0,{{"monster",38644}}}},
        },
        [24927] = { -- Dead Man's Chest [Horde]
            [questKeys.preQuestSingle] = {24947},
        },
        [24928] = { -- To The Ground! [Horde]
            [questKeys.preQuestSingle] = {24947},
        },
        [24930] = { -- While You're At It
            [questKeys.startedBy] = {{35115}},
            [questKeys.preQuestSingle] = {14285,14286,14287,14288,14289,14290,14291},
        },
        [24931] = { -- Gazer Tag
            [questKeys.preQuestSingle] = {24932},
        },
        [24932] = { -- Cutting Losses
            [questKeys.preQuestSingle] = {25103},
        },
        [24937] = { -- Oomlot Dealt With
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24925,24929},
        },
        [24942] = { -- Zombies vs. Super Booster Rocket Boots
            [questKeys.objectives] = {nil,nil,nil,nil,{{{38753,38813,38815,38816},38813,"Goblin Zombies slain"}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_LOST_ISLES] = {{51.8,47.11}}},Questie.ICON_TYPE_EVENT,l10n("Use Super Booster Rocket Boots in the vicinity of Coach Crosscheck")}},
        },
        [24945] = { -- Three Little Pygmies
            [questKeys.preQuestSingle] = {24940},
        },
        [24949] = { -- Booty Duty
            [questKeys.preQuestSingle] = {24947},
        },
        [24950] = { -- Captain Dreadbeard [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25534,25541},
        },
        [24951] = { -- A Great Idea
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Capture a Hazzali Swarmer"),0,{{"monster",5451}}}},
        },
        [24952] = { -- Rocket Boot Boost
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24942,24945,24946},
            [questKeys.objectives] = {{{38842,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24953] = { -- Just Trying to Kill Some Bugs
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Narain to mount your bug"),0,{{"monster",11811}}}},
        },
        [24955] = { -- Un-Chartered
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{5471,5472,5473,5474,5475},5471,"Signatures obtained",Questie.ICON_TYPE_TALK}}},
        },
        [24957] = { -- Get The Centipaarty Started
            [questKeys.preQuestSingle] = {24955},
        },
        [24958] = { -- Volcanoth!
            [questKeys.objectives] = {{{38855}}},
        },
        [24960] = { -- The Wakening
            [questKeys.preQuestSingle] = {28608},
            [questKeys.startedBy] = {{2307}},
            [questKeys.objectives] = {{{38895,nil,Questie.ICON_TYPE_TALK},{49230,nil,Questie.ICON_TYPE_TALK},{49231,nil,Questie.ICON_TYPE_TALK}}},
        },
        [24961] = { -- The Truth of the Grave
            [questKeys.preQuestSingle] = {26801},
            [questKeys.objectives] = {{{38910,nil,Questie.ICON_TYPE_TALK}}},
        },
        [24962] = { -- Trail-Worn Scroll
            [questKeys.startedBy] = {{1569}},
        },
        [24963] = { -- Maul 'Em With Kindness
            [questKeys.objectives] = {nil,nil,nil,nil,{{{5471,5472,5473,5474,5475},5471,"Ogres fed"}}},
        },
        [24964] = { -- The Thrill of the Hunt
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 38911}}}},
        },
        [24965] = { -- Arcane Missiles
            [questKeys.objectives] = {{{44795}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 2124}}}},
        },
        [24966] = { -- Of Light and Shadows
            [questKeys.objectives] = {{{44795,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 2123}}}},
        },
        [24967] = { -- Stab!
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 2122}}}},
        },
        [24968] = { -- Dark Deeds
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 2126}}}},
        },
        [24969] = { -- Charging into Battle
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 2119}}}},
        },
        [24974] = { -- Ever So Lonely
            [questKeys.objectives] = {nil,nil,nil,nil,{{{1543,1544},1543,nil,Questie.ICON_TYPE_INTERACT},{{38925},38925,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24979] = { -- A Scarlet Letter
            [questKeys.startedBy] = {{1535},nil,{52079}},
            [questKeys.objectives] = {{{38999,nil,Questie.ICON_TYPE_TALK}}},
        },
        [24982] = { -- The New Forsaken
            [questKeys.exclusiveTo] = {24983},
        },
        [24983] = { -- Forsaken Duties
            [questKeys.preQuestSingle] = {},
        },
        [24988] = { -- The Chill of Death
            [questKeys.preQuestSingle] = {24983},
        },
        [24989] = { -- Return to the Magistrate
            [questKeys.preQuestSingle] = {24988},
        },
        [24990] = { -- Darkhound Pounding
            [questKeys.preQuestSingle] = {24989},
        },
        [24991] = { -- Garren's Haunt
            [questKeys.preQuestSingle] = {24996},
            [questKeys.exclusiveTo] = {24994},
        },
        [24999] = { -- Garren's Haunt
            [questKeys.preQuestSingle] = {24994},
            [questKeys.objectives] = {{{38937,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25003] = { -- The Family Crypt
            [questKeys.preQuestSingle] = {},
        },
        [25004] = { -- The Mills Overrun
            [questKeys.preQuestSingle] = {25003},
        },
        [25005] = { -- Speak with Sevren
            [questKeys.preQuestGroup] = {25004,25029},
        },
        [25006] = { -- The Grasp Weakens
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the procedure"), 0, {{"monster", 39117}}}},
        },
        [25012] = { -- Take to the Skies
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Get a ride to Brill"), 0, {{"monster", 37915}}}},
        },
        [25029] = { -- Deaths in the Family
            [questKeys.preQuestSingle] = {25003},
        },
        [25030] = { -- The Haunted Mills
            [questKeys.startedBy] = {{1658},nil,{3082}},
        },
        [25031] = { -- Head for the Mills
            [questKeys.exclusiveTo] = {25003},
            [questKeys.preQuestGroup] = {24995,24999},
        },
        [25035] = { -- Breaking the Line
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Jornun"), 0, {{"monster", 38989}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [25038] = { -- Gordo's Task
            [questKeys.preQuestSingle] = {24976},
        },
        [25046] = { -- A Daughter's Embrace
            [questKeys.objectives] = {{{39097,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25037] = { -- Crab Fishin'
            [questKeys.preQuestSingle] = {24643,24755,24763,24769,24775,24781,24787,26277},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [25050] = { -- Rocket Rescue
            [questKeys.objectives] = {{{38571},{40583}}},
            [questKeys.preQuestGroup] = {25048,25049},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in the balloon"),0,{{"monster",40604}}}},
        },
        [25052] = { -- Dead Man's Chest [Alliance]
            [questKeys.preQuestSingle] = {25121},
        },
        [25053] = { -- To The Ground! [Alliance]
            [questKeys.preQuestSingle] = {25121},
        },
        [25064] = { -- Moraya
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [25066] = { -- The Pride of Kezan
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25024,25058,25093},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Sassy Hardwrench"), 0, {{"monster", 38387}}}},
        },
        [25067] = { -- Thunderdrome: The Ginormus!
            [questKeys.objectives] = {{{39075}}},
        },
        [25068] = { -- The Crumbling Past
            [questKeys.preQuestSingle] = {25017},
        },
        [25069] = { -- The Secrets of Uldum
            [questKeys.preQuestSingle] = {25017},
        },
        [25072] = { -- A Few Good Goblins
            [questKeys.preQuestSingle] = {25103},
        },
        [25073] = { -- Sen'jin Village
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [25081] = { -- Claim the Battlescar
            [questKeys.objectives] = {{{37922}},{{201878,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25094] = { -- Thunderdrome: Zumonga!
            [questKeys.objectives] = {{{39148}}},
            [questKeys.preQuestSingle] = {25067},
        },
        [25095] = { -- Thunderdrome: Sarinexx!
            [questKeys.objectives] = {{{39149}}},
            [questKeys.preQuestSingle] = {25094},
        },
        [25105] = { -- Nibbler!  No!
            [questKeys.exclusiveTo] = {25154,25155,25156,25157},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25107] = { -- The Grand Tablet
            [questKeys.preQuestSingle] = {25070},
        },
        [25111] = { -- Scavengers Scavenged
            [questKeys.objectives] = {{{5429}}},
        },
        [25112] = { -- Butcherbot
            [questKeys.objectives] = {{{5419}}},
        },
        [25115] = { -- Blisterpaw Butchery
            [questKeys.objectives] = {{{5426}}},
        },
        [25122] = { -- Morale Boost
            [questKeys.requiredSourceItems] = {52484},
            [questKeys.objectives] = {{{38441,nil,Questie.ICON_TYPE_INTERACT},{38647,nil,Questie.ICON_TYPE_INTERACT},{38746,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{38745,38409},38409,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {},
        },
        [25123] = { -- Throw It On the Ground!
            [questKeys.objectives] = {{{39194}}},
            [questKeys.requiredSourceItems] = {52481},
            [questKeys.exclusiveTo] = {},
        },
        [25125] = { -- Light at the End of the Tunnel
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25122,25123},
        },
        [25128] = { -- Hana'zua
            [questKeys.exclusiveTo] = {790},
        },
        [25129] = { -- Sarkoth
            [questKeys.preQuestSingle] = {},
        },
        [25134] = { -- Lazy Peons
            [questKeys.sourceItemId] = 16114,
            [questKeys.objectives] = {{{10556,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25139] = { -- Steady Shot
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 39214}}}},
        },
        [25141] = { -- Eviscerate
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 3155}}}},
        },
        [25143] = { -- Primal Strike
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{73899}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Primal Strike"), 2, {{"monster", 3157}}}},
        },
        [25145] = { -- Immolate
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 3156}}}},
        },
        [25147] = { -- Charge
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 3153}}}},
        },
        [25149] = { -- Arcane Missiles
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 39206}}}},
        },
        [25154] = { -- A Present for Lila
            [questKeys.exclusiveTo] = {25105,25155,25156,25157},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25155] = { -- Ogrezonians in the Mood
            [questKeys.exclusiveTo] = {25105,25154,25156,25157},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25156] = { -- Elemental Goo
            [questKeys.exclusiveTo] = {25105,25154,25155,25157},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25157] = { -- The Latest Fashion!
            [questKeys.exclusiveTo] = {25105,25154,25155,25156},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORMWIND_CITY] = {{63.8,60.8}}},Questie.ICON_TYPE_EVENT,l10n("Use Stardust No. 2 on ten Humanoids")}},
        },
        [25158] = { -- Nibbler!  No!
            [questKeys.exclusiveTo] = {25159,25160,25161,25162},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25159] = { -- The Latest Fashion!
            [questKeys.exclusiveTo] = {25158,25160,25161,25162},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
            [questKeys.extraObjectives] = {{{[zoneIDs.ORGRIMMAR] = {{72.5,36.2}}},Questie.ICON_TYPE_EVENT,l10n("Use Stardust No. 2 on ten Humanoids")}},
        },
        [25160] = { -- A Present for Lila
            [questKeys.exclusiveTo] = {25158,25159,25161,25162},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25161] = { -- Ogrezonians in the Mood
            [questKeys.exclusiveTo] = {25158,25159,25160,25162},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25162] = { -- Elemental Goo
            [questKeys.exclusiveTo] = {25158,25159,25160,25161},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [25164] = { -- Backed Into a Corner
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39397,40162,40372},39397},{{40161},40161}}},
        },
        [25165] = { -- Never Trust a Big Barb and a Smile
            [questKeys.objectives] = {{{3125,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25166] = { -- Captain Dreadbeard [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26886,26887},
        },
        [25171] = { -- Riding On
            [questKeys.preQuestSingle] = {25169},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Get a ride to Razor Hill"), 0, {{"monster", 10676}}}},
        },
        [25178] = { -- Shipwreck Searching
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25173,25176},
        },
        [25179] = { -- Loss Reduction
            [questKeys.objectives] = {{{39270,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25184] = { -- Wild Mine Cart Ride
            [questKeys.objectives] = {{{39335,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25187] = { -- Lost in the Floods
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{39357,nil,Questie.ICON_TYPE_EVENT},{39358,nil,Questie.ICON_TYPE_EVENT},{39359,nil,Questie.ICON_TYPE_EVENT},{39360,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25188] = { -- Watershed Patrol
            [questKeys.childQuests] = {25189,25190,25192,25193,25194,25195},
            [questKeys.objectives] = {{{39325,nil,Questie.ICON_TYPE_EVENT},{39326,nil,Questie.ICON_TYPE_EVENT},{3193,nil,Questie.ICON_TYPE_EVENT},{39324,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25189] = { -- Spirits Be Praised
            [questKeys.parentQuest] = 25188,
            [questKeys.triggerEnd] = {"Escort Grandmatron Tekla to Raggaran",{[zoneIDs.DUROTAR] = {{42.6,49.96}}}},
        },
        [25190] = { -- Raggaran's Rage
            [questKeys.parentQuest] = 25188,
        },
        [25191] = { -- Survey the Destruction
            [questKeys.objectives] = {{{38383,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25192] = { -- Raggaran's Fury
            [questKeys.parentQuest] = 25188,
        },
        [25193] = { -- Lost But Not Forgotten
            [questKeys.parentQuest] = 25188,
        },
        [25194] = { -- Unbidden Visitors
            [questKeys.parentQuest] = 25188,
            [questKeys.objectives] = {{{39337,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25195] = { -- That's the End of That Raptor
            [questKeys.parentQuest] = 25188,
        },
        [25202] = { -- The Fastest Way to His Heart
            [questKeys.preQuestGroup] = {25200,25201},
            [questKeys.exclusiveTo] = {25203},
        },
        [25203] = { -- What Kind of Name is Chip, Anyway?
            [questKeys.preQuestGroup] = {25200,25201},
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {25202},
        },
        [25204] = { -- Release the Valves
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25200,25201},
        },
        [25205] = { -- The Wolf and The Kodo
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{39365,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start listening to the story"),0,{{"monster",39380}}}},
        },
        [25206] = { -- Ignoring the Warnings
            [questKeys.preQuestSingle] = {25205},
        },
        [25207] = { -- Good-bye, Sweet Oil
            [questKeys.objectives] = {nil,{{205061}}},
        },
        [25208] = { -- Tell Silvia
            [questKeys.preQuestSingle] = {25403},
        },
        [25213] = { -- The Slave Pits
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25203,25207},
        },
        [25214] = { -- Escape Velocity
            [questKeys.objectives] = {{{39456,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25215] = { -- A Distracting Scent
            [questKeys.preQuestSingle] = {25222},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHIMMERING_EXPANSE] = {{49.7,47.4}}},Questie.ICON_TYPE_EVENT,l10n("Drag the corpses here")}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{40847,39911},39911,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25216] = { -- The Great Sambino
            [questKeys.preQuestSingle] = {25222},
        },
        [25217] = { -- Totem Modification
            [questKeys.requiredSourceItems] = {53052,54214,54216,54217},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHIMMERING_EXPANSE] = {{40.4,34.2}}},Questie.ICON_TYPE_EVENT,l10n("Place a totem on the ground and defend it")}},
        },
        [25218] = { -- Undersea Inflation
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Fill the balloon"),0,{{"object",202887}}}},
        },
        [25219] = { -- Don't be Shellfish
            [questKeys.preQuestSingle] = {25222},
        },
        [25220] = { -- Slippery Threat
            [questKeys.preQuestSingle] = {25222},
        },
        [25227] = { -- Thonk
            [questKeys.exclusiveTo] = {25187},
        },
        [25233] = { -- End of the Supply Line
            [questKeys.preQuestSingle] = {25584},
        },
        [25234] = { -- In the Rear With the Gear
            [questKeys.preQuestSingle] = {25584},
        },
        [25236] = { -- Thunder Down Under
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{39464,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25237] = { -- Tears of Stone
            [questKeys.preQuestSingle] = {25230},
        },
        [25241] = { -- The Land, Corrupted
            [questKeys.preQuestSingle] = {25230},
        },
        [25244] = { -- What Kind of Name is Candy, Anyway?
            [questKeys.preQuestSingle] = {25213},
        },
        [25246] = { -- A Change of Heart
            [questKeys.preQuestSingle] = {},
        },
        [25247] = { -- A Change of Heart
            [questKeys.preQuestSingle] = {},
        },
        [25248] = { -- A Change of Heart
            [questKeys.preQuestSingle] = {},
        },
        [25249] = { -- A Change of Heart
            [questKeys.preQuestSingle] = {},
        },
        [25250] = { -- Sealing the Dream [Horde]
            [questKeys.objectives] = {{{39834,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25251] = { -- Final Confrontation
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25214,25243}, -- 25243 or 25244
            [questKeys.objectives] = {{{39592,nil,Questie.ICON_TYPE_INTERACT},{39582}}},
        },
        [25264] = { -- Ak'Zeloth
            [questKeys.zoneOrSort] = 14,
        },
        [25266] = { -- Warchief's Emissary
            [questKeys.finishedBy] = {{39609}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Sassy Hardwrench"),0,{{"monster",38387}}}},
        },
        [25267] = { -- Message for Garrosh
            [questKeys.startedBy] = {{39609}},
            [questKeys.finishedBy] = {{39605}},
        },
        [25268] = { -- The Voice of Goldrinn
            [questKeys.preQuestSingle] = {25233},
        },
        [25269] = { -- The Voice of Lo'Gosh
            [questKeys.preQuestSingle] = {25233},
        },
        [25272] = { -- Lycanthoth the Corruptor
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Summon Lycanthoth"),0,{{"object",202660}}}},
        },
        [25273] = { -- Lycanthoth the Corruptor
            [questKeys.finishedBy] = {{39627}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Summon Lycanthoth"),0,{{"object",202660}}}},
        },
        [25275] = { -- Report to the Labor Captain
            [questKeys.startedBy] = {{39605}},
            [questKeys.exclusiveTo] = {14129},
        },
        [25277] = { -- Cleaning House
            [questKeys.preQuestSingle] = {25272},
        },
        [25278] = { -- Cleaning House
            [questKeys.preQuestSingle] = {25273},
        },
        [25279] = { -- The Shrine Reclaimed
            [questKeys.preQuestSingle] = {25272},
            [questKeys.nextQuestInChain] = 25277,
        },
        [25280] = { -- The Shrine Reclaimed
            [questKeys.preQuestSingle] = {25273},
            [questKeys.nextQuestInChain] = 25278,
        },
        [25281] = { -- Pay It Forward
            [questKeys.objectives] = {{{39663,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25291] = { -- Twilight Training
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25223,25224,25330},
        },
        [25292] = { -- Next of Kin
            [questKeys.preQuestSingle] = {24747},
        },
        [25294] = { -- Walking the Dog
            [questKeys.objectives] = {{{39659,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {25291},
            [questKeys.requiredSourceItems] = {52708},
        },
        [25296] = { -- Gather the Intelligence
            [questKeys.preQuestSingle] = {25291},
        },
        [25297] = { -- From the Mouth of Madness
            [questKeys.preQuestSingle] = {25272,25273},
        },
        [25298] = { -- Free Your Mind, the Rest Follows
            [questKeys.objectives] = {{{39644,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25299] = { -- The Eye of Twilight
            [questKeys.objectives] = {{{39601,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25300] = { -- The Eye of Twilight
            [questKeys.preQuestSingle] = {25272,25273},
        },
        [25303] = { -- Elementary!
            [questKeys.objectives] = {{{39737},{39736},{39730},{39738}}},
        },
        [25308] = { -- Seeds of Discord
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_EVENT,l10n("Put on your disguise"),0,{{"object",203091}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Karr'gonn"),0,{{"monster",40489}}},
            },
        },
        [25310] = { -- The Greater of Two Evils
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25309,25496},
        },
        [25311] = { -- Twilight Territory
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25309,25496},
        },
        [25315] = { -- Graduation Speech
            [questKeys.objectives] = {nil,{{202996}}},
        },
        [25316] = { -- As Hyjal Burns
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {25317,25370,25460},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get on Aronus"),0,{{"monster",39140}}}},
        },
        [25317] = { -- Protect the World Tree
            [questKeys.preQuestSingle] = {},
        },
        [25314] = { -- Speech Writing for Dummies
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25308,25310,25311},
        },
        [25323] = { -- Flamebreaker
            [questKeys.objectives] = {{{40080}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use Flameseer's Staff"),0,{{"monster",38896}}}},
        },
        [25325] = { -- Through the Dream
            [questKeys.triggerEnd] = {"Arch Druid Fandral Staghelm delivered",{[zoneIDs.MOUNT_HYJAL] = {{52.3,17.4}}}},
        },
        [25329] = { -- Might of the Stonemaul
            [questKeys.preQuestSingle] = {25344},
            [questKeys.objectives] = {{{45115,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25330] = { -- Waste of Flesh
            [questKeys.objectives] = {{{39453,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25332] = { -- Get Me Outta Here!
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Kristoff Escorted Out",{[zoneIDs.MOUNT_HYJAL] = {{27.1,35.9}}}},
            [questKeys.preQuestSingle] = {25328},
        },
        [25333] = { -- Might of the Sentinels
            [questKeys.objectives] = {{{45115,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25334] = { -- The Looming Threat
            [questKeys.objectives] = {{{39226,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25340] = { -- Dark Heart [Horde]
            [questKeys.requiredSourceItems] = {9530},
        },
        [25344] = { -- Ogre Abduction [Horde]
            [questKeys.objectives] = {{{11443,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25352] = { -- Sweeping the Shelf
            [questKeys.preQuestSingle] = {25278},
        },
        [25353] = { -- Lightning in a Bottle
            [questKeys.preQuestSingle] = {25278},
            [questKeys.finishedBy] = {{39627}},
        },
        [25354] = { -- Sweeping the Shelf
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.preQuestSingle] = {25277},
        },
        [25355] = { -- Lightning in a Bottle
            [questKeys.preQuestSingle] = {25277},
        },
        [25357] = { -- Buy Us Some Time
            [questKeys.exclusiveTo] = {},
        },
        [25359] = { -- Toshe's Vengeance
            [questKeys.nextQuestInChain] = 25439,
        },
        [25361] = { -- A New Cloak's Sheen
            [questKeys.preQuestSingle] = {25338},
        },
        [25364] = { -- Alpha Strike [Horde]
            [questKeys.preQuestSingle] = {25363},
        },
        [25365] = { -- Woodpaw Investigation
            [questKeys.preQuestSingle] = {25366},
        },
        [25367] = { -- Zukk'ash Infestation
            [questKeys.preQuestSingle] = {25366},
        },
        [25369] = { -- Stinglasher (Horde)
            [questKeys.preQuestSingle] = {25427},
        },
        [25370] = { -- Inciting the Elements
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSourceItems] = {53009},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Feed Juniper Berries"),0,{{"monster",39921}}}},
        },
        [25371] = { -- The Abyssal Ride
            [questKeys.objectives] = {{{39996,nil,Questie.ICON_TYPE_MOUNT_UP}},{{202766}}},
        },
        [25374] = { -- Sasquatch Sighting [Horde]
            [questKeys.preQuestSingle] = {25373},
        },
        [25375] = { -- Taming The Tamers [Horde]
            [questKeys.preQuestSingle] = {25373},
        },
        [25377] = { -- The Horde's Hoard
            [questKeys.startedBy] = {{39918},nil,{53053}},
        },
        [25379] = { -- Taerar's Fall
            [questKeys.objectives] = {{{39853}}},
        },
        [25381] = { -- Fighting Fire With ... Anything
            [questKeys.preQuestSingle] = {25584},
        },
        [25382] = { -- Disrupting the Rituals
            [questKeys.preQuestSingle] = {25584},
        },
        [25383] = { -- Ysondre's Farewell [Horde]
            [questKeys.preQuestSingle] = {25379},
        },
        [25385] = { -- Save the Wee Animals
            [questKeys.preQuestSingle] = {25584},
        },
        [25388] = { -- Crate of Crab Meat
            [questKeys.name] = 'Crate of Crab Meat',
        },
        [25392] = { -- Oh, Deer!
            [questKeys.objectives] = {{{39999,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Escort the Injured Fawn back home"),0,{{"monster",39930}}}},
        },
        [25395] = { -- The Stolen Keg
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 25770,
        },
        [25396] = { -- Tears of Stone
            [questKeys.preQuestSingle] = {25394},
        },
        [25397] = { -- The Land, Corrupted
            [questKeys.preQuestSingle] = {25394},
        },
        [25398] = { -- Sealing the Dream [Alliance]
            [questKeys.objectives] = {{{39834,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25403] = { -- Ogre Abduction [Alliance]
            [questKeys.objectives] = {{{11443,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25404] = { -- If You're Not Against Us...
            [questKeys.objectives] = {{{39933,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {25584},
        },
        [25407] = { -- Forces of Nature: Wisps
            [questKeys.objectives] = {{{40079,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25409] = { -- Forces of Nature: Hippogryphs
            [questKeys.objectives] = {nil,nil,nil,nil,{{{5300,5304},5300,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25410] = { -- Forces of Nature: Treants
            [questKeys.objectives] = {{{7584,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25411] = { -- A New Master
            [questKeys.objectives] = {{{39974}}},
        },
        [25412] = { -- The Name Never Spoken
            [questKeys.preQuestSingle] = {25411},
            [questKeys.exclusiveTo] = {25443},
        },
        [25419] = { -- Lady La-La's Medallion
            [questKeys.requiredSourceItems] = {55188},
            [questKeys.startedBy] = {{41017},nil,{55186}},
            [questKeys.preQuestSingle] = {25459},
            [questKeys.finishedBy] = {{100009}},
        },
        [25422] = { -- The Darkmist Legacy
            [questKeys.preQuestSingle] = {25350},
        },
        [25423] = { -- Ancient Suffering
            [questKeys.preQuestSingle] = {25350},
        },
        [25431] = { -- Stinglasher
            [questKeys.preQuestSingle] = {25427},
        },
        [25433] = { -- Sasquatch Sighting
            [questKeys.preQuestSingle] = {25432},
        },
        [25434] = { -- Taming The Tamers
            [questKeys.preQuestSingle] = {25432},
        },
        [25436] = { -- Spiteful Sisters
            [questKeys.preQuestGroup] = {25433,25434},
        },
        [25437] = { -- Ysondre's Call
            [questKeys.preQuestSingle] = {25436},
        },
        [25438] = { -- Ysondre's Farewell
            [questKeys.preQuestSingle] = {25379},
        },
        [25439] = { -- Vengeful Heart
            [questKeys.preQuestSingle] = {25222},
        },
        [25441] = { -- Vortex
            [questKeys.objectives] = {{{40280,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25442] = { -- A Pearl of Wisdom
            [questKeys.startedBy] = {{40510},nil,{54614}},
            [questKeys.preQuestSingle] = {25222},
            [questKeys.nextQuestInChain] = 25890,
        },
        [25443] = { -- The Name Never Spoken
            [questKeys.preQuestSingle] = {25411},
            [questKeys.exclusiveTo] = {25412},
        },
        [25451] = { -- Pristine Yeti Hide
            [questKeys.startedBy] = {{39896},nil,{55166}},
            [questKeys.preQuestSingle] = {25449},
        },
        [25459] = { -- Ophidophobia
            [questKeys.preQuestSingle] = {25602},
        },
        [25460] = { -- The Earth Rises
            [questKeys.preQuestSingle] = {},
        },
        [25462] = { -- The Bears Up There
            [questKeys.preQuestSingle] = {25428},
            [questKeys.objectives] = {{{40240,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Climb the tree"),0,{{"monster",40190}}}},
        },
        [25463] = { -- Report to Silvia
            [questKeys.preQuestSingle] = {25458},
        },
        [25464] = { -- The Return of Baron Geddon
            [questKeys.objectives] = {{{40147,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25467] = { -- Kliklak's Craw
            [questKeys.startedBy] = {{40276},nil,{54345}},
        },
        [25468] = { -- Forces of Nature: Faerie Dragons
            [questKeys.objectives] = {nil,nil,nil,nil,{{{5276,5278},5276,"Faerie Dragons Rallied",Questie.ICON_TYPE_INTERACT}}},
        },
        [25469] = { -- Forces of Nature: Mountain Giants
            [questKeys.objectives] = {{{40026,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25473] = { -- Kaja'Cola
            [questKeys.startedBy] = {{34872}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14075,14069},
        },
        [25476] = { -- Rescue OOX-22/FE!
            [questKeys.triggerEnd] = {"Escort OOX-22/FE to safety",{[zoneIDs.FERALAS]={{55.63,51.35}}}},
            [questKeys.zoneOrSort] = zoneIDs.FERALAS,
        },
        [25477] = { -- Better Late Than Dead
            [questKeys.objectives] = {{{40223,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {25949,25558},
        },
        [25478] = { -- To the Summit
            [questKeys.objectives] = {{{40358,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
        },
        [25481] = { -- To New Thalanaar
            [questKeys.zoneOrSort] = zoneIDs.FERALAS,
        },
        [25486] = { -- The Grimtotem are Coming
            [questKeys.zoneOrSort] = zoneIDs.FERALAS,
        },
        [25496] = { -- Grudge Match
            [questKeys.preQuestSingle] = {25494},
        },
        [25499] = { -- Agility Training: Run Like Hell!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Run away from the Blazing Trainer"),0,{{"monster",40434}}}},
        },
        [25502] = { -- Prepping the Soil
            [questKeys.objectives] = {nil,{{460007}},nil,nil,{{{40460},40460,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25503] = { -- Blackfin's Booty
            [questKeys.startedBy] = {{41183},nil,{54639}},
        },
        [25513] = { -- Thunderdrome: Grudge Match!
            [questKeys.objectives] = {{{40875}}},
        },
        [25514] = { -- Breaking the Bonds
            [questKeys.objectives] = {{{40544,nil,Questie.ICON_TYPE_EVENT},{40545,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_EVENT,l10n("Disable the Rod of Subjugation"),1,{{"object",460008}}},
                {nil,Questie.ICON_TYPE_EVENT,l10n("Disable the Rod of Subjugation"),2,{{"object",460009}}},
            },
        },
        [25517] = { -- Bar Fight! [Alliance]
            [questKeys.preQuestSingle] = {25488},
            [questKeys.requiredSourceItems] = {54747},
        },
        [25518] = { -- Bar Fight! [Horde]
            [questKeys.preQuestSingle] = {25489},
            [questKeys.requiredSourceItems] = {54747},
        },
        [25519] = { -- Children of Tortolla
            [questKeys.objectives] = {nil,nil,nil,nil,{{{40555,40557},40555,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Deep Corruptor"),0,{{"monster",40561}}}},
        },
        [25520] = { -- An Ancient Awakens
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25514,25519},
        },
        [25522] = { -- Gargantapid
            [questKeys.preQuestSingle] = {25521},
        },
        [25523] = { -- Flight in the Firelands
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
            [questKeys.objectives] = {nil,{{202973}}},
        },
        [25524] = { -- In the Outhouse [Alliance]
            [questKeys.preQuestSingle] = {25504},
            [questKeys.requiredSourceItems] = {54821},
        },
        [25525] = { -- Wave One
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39833,39835},39835}}},
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
        },
        [25526] = { -- In the Outhouse [Horde]
            [questKeys.preQuestSingle] = {25505},
            [questKeys.requiredSourceItems] = {54821},
        },
        [25533] = { -- Pirate Accuracy Increasing
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25516,25518,25526},
        },
        [25534] = { -- Going Off-Task [Horde]
            [questKeys.exclusiveTo] = {};
        },
        [25536] = { -- Cold Welcome
            [questKeys.finishedBy] = {{40642}},
        },
        [25537] = { -- Art of Attraction
            [questKeys.objectives] = {{{40654,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25538] = { -- Odor Coater
            [questKeys.objectives] = {{{40646,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25540] = { -- Bellies Await
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25538,25539},
        },
        [25541] = { -- Filling Our Pockets
            [questKeys.exclusiveTo] = {};
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24927,24949},
        },
        [25544] = { -- Wave Two
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{40650,40660},40650}}},
        },
        [25545] = { -- To Arms!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25357,25546},
            [questKeys.exclusiveTo] = {},
        },
        [25546] = { -- Traveling on Our Stomachs
            [questKeys.exclusiveTo] = {},
        },
        [25547] = { -- On Our Own Terms
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25545,25564},
        },
        [25551] = { -- The Firelord
            [questKeys.startedBy] = {{40773}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25550,25553,25555},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.MOUNT_HYJAL] = {{55.5,66.2}}},Questie.ICON_TYPE_EVENT,l10n("Go through the portal")},
                {nil,Questie.ICON_TYPE_TALK,l10n("Start the fight"),0,{{"monster",40803},{"monster",41631}}},
            },
        },
        [25556] = { -- Into Zul'Farrak
            [questKeys.exclusiveTo] = {27068},
        },
        [25558] = { -- All or Nothing
            [questKeys.extraObjectives] = {{{[zoneIDs.KELP_THAR_FOREST] = {{44.59,25.37}}},Questie.ICON_TYPE_EVENT,l10n("Defend The Briny Cutter")}},
            [questKeys.objectives] = {{{40714,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25560] = { -- Egg Wave
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
        },
        [25561] = { -- Circle the Wagons... er, Boats [Alliance]
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak with Mazzer Stripscrew to get on your boat"),0,{{"monster",40726}}}},
            [questKeys.preQuestSingle] = {25532},
        },
        [25562] = { -- Circle the Wagons... er, Boats [Horde]
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak with Griznak to get on your boat"),0,{{"monster",40727}}}},
            [questKeys.preQuestSingle] = {25533},
        },
        [25564] = { -- Stormwind Elite Aquatic and Land Forces
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25357,25546},
            [questKeys.exclusiveTo] = {},
        },
        [25574] = { -- Flames from Above
            [questKeys.objectives] = {{{40856,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25575] = { -- Forged of Shadow and Flame
            [questKeys.objectives] = {nil,{{203066}}},
            [questKeys.preQuestSingle] = {}, -- quest is available by default in Mount Hyjal. Blizzard things
        },
        [25576] = { -- Rage of the Wolf Ancient
            [questKeys.preQuestSingle] = {}, -- quest is available by default in Mount Hyjal. Blizzard things
        },
        [25577] = { -- Crushing the Cores
            [questKeys.objectives] = {nil,{{203067}}},
            [questKeys.preQuestSingle] = {}, -- quest is available by default in Mount Hyjal. Blizzard things
            [questKeys.requiredSourceItems] = {55123},
        },
        [25582] = { -- A Better Vantage
            [questKeys.objectives] = {{{40963,nil,Questie.ICON_TYPE_EVENT},{40964,nil,Questie.ICON_TYPE_EVENT},{40965,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25583] = { -- Upon the Scene of Battle
            [questKeys.preQuestSingle] = {25922},
        },
        [25585] = { -- Quiet the Cannons [Alliance]
            [questKeys.objectives] = {{{40869,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25586] = { -- Quiet the Cannons [Horde]
            [questKeys.objectives] = {{{40869,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25587] = { -- Gimme Shelter!
            [questKeys.preQuestSingle] = {25949,25558},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.KELP_THAR_FOREST] = {{56.74,30.41}}},Questie.ICON_TYPE_EVENT,l10n("Smuggler's Scar Scouted"),1},
                {{[zoneIDs.KELP_THAR_FOREST] = {{54.1,34.4}}},Questie.ICON_TYPE_EVENT,l10n("Adarrah Signaled"),2},
            },
        },
        [25589] = { -- A Little Payback
            [questKeys.preQuestSingle] = {25562},
        },
        [25590] = { -- Where's Wizzle?
            [questKeys.preQuestSingle] = {25561},
        },
        [25591] = { -- Thunderdrome: Grudge Match!
            [questKeys.objectives] = {{{40876}}},
            [questKeys.preQuestSingle] = {25095},
        },
        [25592] = { -- Deep Attraction
            [questKeys.preQuestSingle] = {25996},
            [questKeys.startedBy] = {{40917}},
            [questKeys.finishedBy] = {{40917}},
        },
        [25593] = { -- Shelled Salvation
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39729,41203,41219,42404},39729,"Shell Survivors rescued",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {25996},
            [questKeys.requiredSourceItems] = {55141},
        },
        [25594] = { -- Crafty Crabs
            [questKeys.preQuestSingle] = {25996},
        },
        [25595] = { -- Something Edible
            [questKeys.preQuestSingle] = {25996},
        },
        [25596] = { -- Where's Synge?
            [questKeys.preQuestSingle] = {25562},
        },
        [25598] = { -- Ain't Too Proud to Beg
            [questKeys.objectives] = {{{39669,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25599] = { -- Cindermaul, the Portal Master
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25575,25576,25577},
        },
        [25600] = { -- Forgemaster Pyrendius
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Activate"),0,{{"object",203092}}}},
        },
        [25601] = { -- Head of the Class
            [questKeys.preQuestSingle] = {25314},
        },
        [25602] = { -- Can't Start a Fire Without a Spark
            [questKeys.preQuestSingle] = {25598},
        },
        [25608] = { -- Slash and Burn
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40934}}}},
        },
        [25613] = { -- Do Yourself a Favor
            [questKeys.preQuestSingle] = {13913},
        },
        [25614] = { -- The Only Way Down is in a Body Bag
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_SLAY,l10n("Shoot the wyvern"),0,{{"monster",34832}}},
                {nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Use the cannon"),0,{{"monster",32254}}},
            },
        },
        [25617] = { -- Into the Maw!
            --[questKeys.exclusiveTo] = {25624}, -- curiously, this one is NOT exclusiveTo 25624. That one IS exclusiveTo this one. Blizzard things
            [questKeys.exclusiveTo] = {25575,25576,25577}, -- using these as followups so we don't get stuck with the quest marker on map if you chose the other "Into the Maw!"
        },
        [25618] = { -- Into the Maw!
            --[questKeys.exclusiveTo] = {25623}, -- curiously, this one is NOT exclusiveTo 25623. That one IS exclusiveTo this one. Blizzard things
            [questKeys.exclusiveTo] = {25575,25576,25577}, -- using these as followups so we don't get stuck with the quest marker on map if you chose the other "Into the Maw!"
        },
        [25621] = { -- Field Test: Gnomecorder
            [questKeys.triggerEnd] = {"Gnomecorder Tested",{[zoneIDs.STONETALON_MOUNTAINS] = {{73.2,46.6}}}},
            [questKeys.preQuestSingle] = {25615},
        },
        [25622] = { -- Burn, Baby, Burn!
            [questKeys.startedBy] = {{40895,100000}},
            [questKeys.finishedBy] = {{40895,100001}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25615,25621},
            [questKeys.requiredSourceItems] = {55152},
        },
        [25623] = { -- Into the Maw!
            [questKeys.preQuestSingle] = {25353},
            [questKeys.exclusiveTo] = {25618},
        },
        [25624] = { -- Into the Maw!
            [questKeys.preQuestSingle] = {25355},
            [questKeys.exclusiveTo] = {25617},
        },
        [25626] = { -- Visions of the Past: Rise from the Deep
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460005}}}},
            [questKeys.objectives] = {{{41982,nil,Questie.ICON_TYPE_EVENT},{41222}}},
        },
        [25629] = { -- Her Lady's Hand
            [questKeys.objectives] = {{{41999,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25630] = { -- The Fires of Mount Hyjal
            [questKeys.preQuestSingle] = {25611,25612},
            [questKeys.exclusiveTo] = {25381},
        },
        [25640] = { -- Bombs Away: Windshear Mine!
            [questKeys.startedBy] = {{40895,100000}},
        },
        [25644] = { -- The Twilight Egg
            [questKeys.nextQuestInChain] = 25552,
        },
        [25645] = { -- Return to Sage Palerunner
            [questKeys.preQuestSingle] = {25368},
        },
        [25646] = { -- Windshear Mine Cleanup
            [questKeys.preQuestSingle] = {25640},
        },
        [25647] = { -- Illegible Orc Letter
            [questKeys.startedBy] = {{40905},nil,{55181}},
        },
        [25648] = { -- Beyond Durotar
            [questKeys.preQuestSingle] = {25206},
            [questKeys.zoneOrSort] = 14,
        },
        [25651] = { -- Oh, the Insanity!
            [questKeys.requiredSourceItems] = {55185},
            [questKeys.preQuestSingle] = {25602},
        },
        [25652] = { -- Commandeer That Balloon!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Climb into the balloon"),0,{{"monster",41019}}}},
            [questKeys.objectives] = {{{40984,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25654] = { -- Dark Heart [Alliance]
            [questKeys.requiredSourceItems] = {9530},
        },
        [25655] = { -- The Wormwing Problem
            [questKeys.exclusiveTo] = {},
        },
        [25656] = { -- Scrambling for Eggs
            [questKeys.exclusiveTo] = {},
        },
        [25657] = { -- Dah, Nunt... Dah, Nunt...
            [questKeys.objectives] = {nil,{{203137,"Explosive Grub fed to Gnaws",Questie.ICON_TYPE_EVENT}}},
        },
        [25658] = { -- Built to Last
            [questKeys.objectives] = {nil,{{203185}}},
        },
        [25660] = { -- Haunted
            [questKeys.preQuestSingle] = {25627,25628},
        },
        [25663] = { -- An Offering for Aviana
            [questKeys.preQuestSingle] = {25578},
            [questKeys.objectives] = {nil,{{203147}}},
        },
        [25664] = { -- A Prayer and a Wing
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use Enormous Bird Call"),0,{{"object",203169}}}},
        },
        [25667] = { -- Culling the Wendigos
            [questKeys.preQuestSingle] = {25724},
        },
        [25668] = { -- Pilfered Supplies
            [questKeys.preQuestSingle] = {25724},
        },
        [25670] = { -- DUN-dun-DUN-dun-DUN-dun
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use Budd's Chain"),0,{{"object",203137}}}},
        },
        [25671] = { -- Thinning the Horde
            [questKeys.requiredMaxRep] = {69,21000},
        },
        [25675] = { -- Ogre Combat
            [questKeys.preQuestSingle] = {25674},
        },
        [25678] = { -- Pick Your Fate
            [questKeys.objectives] = {{{5996},{5997},{5998}}},
        },
        [25679] = { -- Into the Mountain
            [questKeys.preQuestGroup] = {25677,25678},
        },
        [25690] = { -- A Bloodmage's Gotta Eat Too
            [questKeys.preQuestSingle] = {25684},
        },
        [25691] = { -- The Charred Granite of the Dark Portal
            [questKeys.preQuestSingle] = {25689},
        },
        [25692] = { -- The Vile Blood of Demons
            [questKeys.preQuestSingle] = {25689},
        },
        [25693] = { -- Enhancing the Stone
            [questKeys.preQuestGroup] = {25691,25692},
        },
        [25696] = { -- The Sunveil Excursion
            [questKeys.preQuestSingle] = {25695},
        },
        [25697] = { -- The Amulet of Allistarj
            [questKeys.preQuestSingle] = {25693},
        },
        [25698] = { -- The Amulet of Sevine
            [questKeys.preQuestSingle] = {25693},
        },
        [25699] = { -- The Amulet of Grol
            [questKeys.preQuestSingle] = {25693},
        },
        [25700] = { -- Loramus Thalipedes Awaits
            [questKeys.preQuestGroup] = {25697,25698,25699},
            [questKeys.objectives] = {{{7506,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25702] = { -- Home... Gone... Naga...
            [questKeys.nextQuestInChain] = 25703,
        },
        [25705] = { -- False Idols
            [questKeys.preQuestSingle] = {25703},
        },
        [25706] = { -- Neptool's Revenge
            [questKeys.preQuestSingle] = {25703},
        },
        [25710] = { -- Minor Distractions
            [questKeys.preQuestSingle] = {},
        },
        [25715] = { -- A Closer Look
            [questKeys.triggerEnd] = {"Scout the ships on the Shattershore",{[zoneIDs.BLASTED_LANDS] = {{69,32.7}}}},
        },
        [25721] = { -- Fight the Flood
            [questKeys.nextQuestInChain] = 25727,
            [questKeys.preQuestSingle] = {},
        },
        [25727] = { -- Drungeld Glowerglare
            [questKeys.nextQuestInChain] = 25733,
        },
        [25731] = { -- A Bird in Hand
            [questKeys.objectives] = {{{41112,nil,Questie.ICON_TYPE_EVENT},{41112,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25655,25656},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Extinguish the fire"),0,{{"object",460000}}}},
        },
        [25733] = { -- Get Out Of Here, Stalkers
            [questKeys.nextQuestInChain] = 25777,
        },
        [25736] = { -- The Floodsurge Core
            [questKeys.startedBy] = {{41167},nil,{55243}},
            [questKeys.preQuestSingle] = {25726},
        },
        [25740] = { -- Fact-Finding Mission
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25731,25664},
        },
        [25743] = { -- Decisions, Decisions
            [questKeys.objectives] = {nil,{{203194}}},
        },
        [25744] = { -- Negotiations (Alliance)
            [questKeys.preQuestSingle] = {25562},
        },
        [25745] = { -- Negotiations (Horde)
            [questKeys.preQuestSingle] = {25562},
        },
        [25749] = { -- Not Entirely Unprepared
            [questKeys.objectives] = {nil,nil,nil,nil,{{{41235,46470},41235,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25752] = { -- Swift Action
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25748,25749,25751},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",50591}}}},
            [questKeys.objectives] = {{{40639,nil,Questie.ICON_TYPE_TALK},{41249},{41250},{42549}}},
        },
        [25753] = { -- Fallen But Not Forgotten
            [questKeys.objectives] = {{{41281,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25754] = { -- Gauging Success
            [questKeys.extraObjectives] = {
                {{[zoneIDs.SHIMMERING_EXPANSE]={{31.77,67.70}}},Questie.ICON_TYPE_EVENT,l10n("Scout the Tunnel to the North"),1},
                {{[zoneIDs.SHIMMERING_EXPANSE]={{30.81,71.79}}},Questie.ICON_TYPE_EVENT,l10n("Scout the Northwestern Terrace"),2},
            },
        },
        [25755] = { -- Visions of the Past: The Slaughter of Biel'aran Ridge
            [questKeys.preQuestGroup] = {25753,25754},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460006}}}},
            [questKeys.preQuestSingle] = {},
        },
        [25760] = { -- Visions of the Past: The Invasion of Vashj'ir
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25579,25580,25581,25582,25583},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460004}}}},
        },
        [25762] = { -- The Ancient Brazier
            [questKeys.preQuestSingle] = {25744,25745},
            [questKeys.objectives] = {{{41242,nil,Questie.ICON_TYPE_INTERACT}},nil,{{55979}}},
        },
        [25764] = { -- Egg Hunt
            [questKeys.objectives] = {{{41224,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Disable the Shadow Cloak Generator"),0,{{"object",203208}}}},
        },
        [25766] = { -- Arcane Legacy
            [questKeys.objectives] = {nil,nil,nil,nil,{{{34931,34932,34938},34931,"Highborne Spirit Bound",Questie.ICON_TYPE_INTERACT}}},
        },
        [25765] = { -- Tell 'Em Koko Sent You
            [questKeys.preQuestSingle] = {25739},
        },
        [25770] = { -- Keg Run
            [questKeys.nextQuestInChain] = 25721,
        },
        [25776] = { -- Sethria's Demise
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25761,25764},
        },
        [25777] = { -- Onwards to Menethil
            [questKeys.nextQuestInChain] = 25780,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25733,25734,25735},
        },
        [25780] = { -- Assault on Menethil Keep
            [questKeys.preQuestSingle] = {},
        },
        [25792] = { -- Pushing Forward
            [questKeys.preQuestGroup] = {313,25667},
        },
        [25794] = { -- Undersea Sanctuary
            [questKeys.objectives] = {{{41294,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25796] = { -- Eminent Domain
            [questKeys.preQuestSingle] = {25790},
            [questKeys.exclusiveTo] = {},
        },
        [25797] = { -- Eminent Domain
            [questKeys.preQuestSingle] = {25791},
            [questKeys.exclusiveTo] = {},
        },
        [25798] = { -- Defend the Drill (Alliance)
            [questKeys.objectives] = {{{41299,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {25790},
            [questKeys.exclusiveTo] = {},
        },
        [25799] = { -- Defend the Drill (Horde)
            [questKeys.objectives] = {{{41299,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {25791},
            [questKeys.exclusiveTo] = {},
        },
        [25801] = { -- Claws from the Deep
            [questKeys.preQuestSingle] = {25800},
        },
        [25802] = { -- Reclaiming Goods
            [questKeys.preQuestSingle] = {25800},
        },
        [25807] = { -- An Ancient Reborn
            [questKeys.objectives] = {{{41300,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25810] = { -- The Hatchery Must Burn
            [questKeys.startedBy] = {{41003}},
        },
        [25815] = { -- The Third Fleet
            [questKeys.nextQuestInChain] = 25816,
        },
        [25816] = { -- Cursed To Roam
            [questKeys.nextQuestInChain] = 25817,
        },
        [25817] = { -- The Cursed Crew
            [questKeys.nextQuestInChain] = 25818,
        },
        [25818] = { -- Lifting the Curse
            [questKeys.nextQuestInChain] = 25819,
        },
        [25824] = { -- Debriefing
            [questKeys.objectives] = {{{41340,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25830] = { -- The Last Living Lorekeeper
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25520,25807},
        },
        [25835] = { -- Free Freewind Post [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25825,25704},
        },
        [25836] = { -- Free Freewind Post [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25826,25704},
        },
        [25838] = { -- Help from Steelgrill's Depot
            [questKeys.preQuestGroup] = {412,25792},
        },
        [25839] = { -- The Ultrasafe Personnel Launcher
            [questKeys.objectives] = {{{41398,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25840] = { -- Eliminate the Resistance
            [questKeys.preQuestSingle] = {25839},
        },
        [25841] = { -- Strike From Above
            [questKeys.preQuestSingle] = {25839},
            [questKeys.objectives] = {{{41372,nil,Questie.ICON_TYPE_EVENT},{41373,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25843] = { -- Tortolla's Revenge
            [questKeys.preQuestSingle] = {25372},
            [questKeys.nextQuestInChain] = 25904,
            [questKeys.startedBy] = {{52838}},
        },
        [25849] = { -- When Archaeology Attacks
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 26189,
        },
        [25854] = { -- I'll Call Him Bitey
            [questKeys.nextQuestInChain] = 25855,
        },
        [25856] = { -- Crocolisk Hides
            [questKeys.nextQuestInChain] = 25857,
        },
        [25860] = { -- At All Costs
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25629,25896},
        },
        [25861] = { -- Setting An Example
            [questKeys.objectives] = {{{41457,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {25858},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Attack an Kvaldir High-Shaman and kite him to Executioner Verathress"),0,{{"monster",41997},{"monster",41537}}}},
        },
        [25864] = { -- Dinosaur Crisis
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 25865,
        },
        [25866] = { -- Dark Iron Trappers
            [questKeys.preQuestSingle] = {25865},
            [questKeys.inGroupWith] = {25867},
            [questKeys.nextQuestInChain] = 25868,
            [questKeys.exclusiveTo] = {},
        },
        [25867] = { -- Gnoll Escape
            [questKeys.preQuestSingle] = {25865},
            [questKeys.inGroupWith] = {25866},
            [questKeys.nextQuestInChain] = 25868,
            [questKeys.exclusiveTo] = {},
            [questKeys.requiredSourceItems] = {56081},
            [questKeys.objectives] = {{{41410,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",203282}}}},
        },
        [25868] = { -- Yorla Darksnare
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25866,25867},
        },
        [25872] = { -- The Brave and the Bold
            [questKeys.preQuestSingle] = {25836},
        },
        [25873] = { -- Horn of the Traitor [Alliance]
            [questKeys.preQuestSingle] = {25835},
        },
        [25874] = { -- Horn of the Traitor [Horde]
            [questKeys.preQuestSingle] = {25836},
        },
        [25881] = { -- Lost Wardens
            [questKeys.preQuestSingle] = {25372},
            [questKeys.objectives] = {{{41499,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25882] = { -- A Hand at the Ranch
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25840,25841},
            [questKeys.nextQuestInChain] = 25932,
        },
        [25883] = { -- How Disarming
            [questKeys.preQuestSingle] = {25887},
        },
        [25887] = { -- Wake of Destruction
            [questKeys.objectives] = {{{41996}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Subdue a Famished Great Shark"),0,{{"monster",41997},{"monster",41998}}}},
        },
        [25888] = { -- Decompression
            [questKeys.objectives] = {{{41548,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25890] = { -- Nespirah
            [questKeys.triggerEnd] = {"Find a way to communicate with Nespirah",{[zoneIDs.SHIMMERING_EXPANSE] = {{51.7,52.1}}}},
            [questKeys.preQuestSingle] = {25440},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take the Swift Seahorse to Nespirah"),0,{{"monster",40851}}}},
        },
        [25891] = { -- Last Ditch Effort
            [questKeys.objectives] = {{{41482,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25892] = { -- Losing Ground
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",48901}}}},
            [questKeys.objectives] = {{{41562,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25896] = { -- Devout Assembly
            [questKeys.objectives] = {{{41985,nil,Questie.ICON_TYPE_TALK},{41980,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25898] = { -- Honor and Privilege
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25894,25895,25897},
            [questKeys.requiredSourceItems] = {56188},
            [questKeys.objectives] = {{{42340,nil,Questie.ICON_TYPE_EVENT},{40645,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25899] = { -- Breakthrough
            [questKeys.preQuestSingle] = {25372},
        },
        [25900] = { -- Making Contact
            [questKeys.objectives] = {{{41531,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25901] = { -- Hyjal Recycling Program
            [questKeys.preQuestSingle] = {25372},
        },
        [25904] = { -- The Hammer and the Key
            [questKeys.preQuestSingle] = {25372},
        },
        [25905] = { -- Rams on the Lam
            [questKeys.preQuestSingle] = {25932},
            [questKeys.objectives] = {{{41539,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25907] = { -- Slave Labor
            [questKeys.objectives] = {nil,nil,nil,nil,{{{41494,41495},41494,"Pearl Miners rescued",Questie.ICON_TYPE_INTERACT}}},
        },
        [25909] = { -- Capture the Crab
            [questKeys.objectives] = {{{41520,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25907,25908},
        },
        [25915] = { -- The Strength of Tortolla
            [questKeys.preQuestSingle] = {25906},
            [questKeys.objectives] = {nil,{{203375,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25916] = { -- Breaking Through
            [questKeys.objectives] = {{{41531,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25921] = { -- Overseer Idra'kess
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25918,25919,25920},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHIMMERING_EXPANSE]={{62.9,57.1}}}, Questie.ICON_TYPE_EVENT, l10n("Head to the top of Nespirah")}},
        },
        [25922] = { -- Waking the Beast
            [questKeys.objectives] = {{{41531},{41776,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [25924] = { -- Call of Duty
            [questKeys.extraObjectives] = {{{[zoneIDs.DUROTAR] = {{57.8,10.4}}},Questie.ICON_TYPE_EVENT,l10n("Wait for the Mercenary Ship to arrive")}},
            [questKeys.preQuestSingle] = {},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
            [questKeys.objectives] = {{{36901,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25926] = { -- Mired in Hatred
            [questKeys.nextQuestInChain] = 25927,
        },
        [25929] = { -- Sea Legs
            [questKeys.preQuestSingle] = {},
        },
        [25930] = { -- Ascending the Vale
            [questKeys.triggerEnd] = {"Ascend the Charred Vale",{[zoneIDs.STONETALON_MOUNTAINS] = {{31.3,73.2}}}},
        },
        [25932] = { -- It's Raid Night Every Night
            [questKeys.objectives] = {{{42169,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25933] = { -- Help for the Quarry
            [questKeys.preQuestGroup] = {314,25905},
        },
        [25936] = { -- Pay It Forward
            [questKeys.objectives] = {{{41672,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25938] = { -- Help for Desolace
            [questKeys.zoneOrSort] = zoneIDs.STONETALON_MOUNTAINS,
        },
        [25939] = { -- For Peat's Sake
            [questKeys.preQuestSingle] = {25926},
            [questKeys.nextQuestInChain] = 26196,
            [questKeys.objectives] = {{{41628,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25940] = { -- Last Stand at Whistling Grove
            [questKeys.preQuestSingle] = {25428},
            [questKeys.exclusiveTo] = {25462},
        },
        [25942] = { -- Buy Us Some Time
            [questKeys.preQuestSingle] = {25941},
        },
        [25943] = { -- Traveling on Our Stomachs
            [questKeys.preQuestSingle] = {25941},
        },
        [25944] = { -- Girding Our Loins
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25942,25943},
        },
        [25945] = { -- We're Here to Do One Thing, Maybe Two...
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Krom'gar Wagon taken to the Fold",{[zoneIDs.STONETALON_MOUNTAINS] = {{74.5,43.9}}}},
        },
        [25946] = { -- Helm's Deep
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25942,25943},
            [questKeys.exclusiveTo] = {},
        },
        [25947] = { -- Finders, Keepers
            [questKeys.exclusiveTo] = {},
        },
        [25948] = { -- Bring It On!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25944,25947},
        },
        [25949] = { -- Blood and Thunder!
            [questKeys.startedBy] = {{41750,41769}},
            [questKeys.extraObjectives] = {{{[zoneIDs.KELP_THAR_FOREST] = {{39.81,30.65}}},Questie.ICON_TYPE_EVENT,l10n("Defend The Immortal Coil")}},
            [questKeys.objectives] = {{{41759,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25951] = { -- Final Judgement
            [questKeys.objectives] = {{{42135,nil,Questie.ICON_TYPE_EVENT},{42063}}},
        },
        [25952] = { -- Caught Off-Guard
            [questKeys.preQuestGroup] = {25592,25593,25594,25595},
        },
        [25953] = { -- Swift Approach
            [questKeys.preQuestGroup] = {25592,25593,25594,25595},
        },
        [25954] = { -- An Occupation of Time
            [questKeys.preQuestGroup] = {25592,25593,25594,25595},
        },
        [25955] = { -- A Better Vantage
            [questKeys.objectives] = {{{40963,nil,Questie.ICON_TYPE_EVENT},{40964,nil,Questie.ICON_TYPE_EVENT},{40965,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {25592,25593,25594,25595},
        },
        [25956] = { -- Upon the Scene of Battle
            [questKeys.preQuestSingle] = {25996},
        },
        [25957] = { -- Visions of the Past: The Invasion of Vashj'ir
            [questKeys.preQuestGroup] = {25952,25953,25954,25955,25956},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460004}}}},
        },
        [25958] = { -- Looking Forward
            [questKeys.preQuestSingle] = {25957},
        },
        [25959] = { -- Clear Goals
            [questKeys.preQuestSingle] = {25958},
        },
        [25960] = { -- Not Entirely Unprepared
            [questKeys.objectives] = {nil,nil,nil,nil,{{{41780,46468},41780,"Horde Lookout restocked",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {25958},
        },
        [25962] = { -- Properly Inspired
            [questKeys.preQuestSingle] = {25958},
        },
        [25963] = { -- Swift Action
            [questKeys.preQuestGroup] = {25959,25960,25962},
            [questKeys.objectives] = {{{40918,nil,Questie.ICON_TYPE_TALK},{41249},{41250},{42549}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",50592}}}},
        },
        [25964] = { -- Fallen But Not Forgotten
            [questKeys.preQuestSingle] = {25963},
            [questKeys.objectives] = {{{41784,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25965] = { -- Gauging Success
            [questKeys.preQuestSingle] = {25963},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.SHIMMERING_EXPANSE]={{31.77,67.70}}},Questie.ICON_TYPE_EVENT,l10n("Scout the Tunnel to the North"),1},
                {{[zoneIDs.SHIMMERING_EXPANSE]={{30.81,71.79}}},Questie.ICON_TYPE_EVENT,l10n("Scout the Northwestern Terrace"),2},
            },
        },
        [25966] = { -- Visions of the Past: The Slaughter of Biel'aran Ridge
            [questKeys.preQuestGroup] = {25964,25965},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460006}}}},
        },
        [25967] = { -- Losing Ground
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",48910}}}},
            [questKeys.objectives] = {{{41779,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25969] = { -- Hostile Waters
            [questKeys.preQuestSingle] = {25968},
        },
        [25970] = { -- Come Prepared
            [questKeys.preQuestSingle] = {25968},
        },
        [25971] = { -- Unfurling Plan
            [questKeys.preQuestSingle] = {25968},
        },
        [25972] = { -- Honor and Privilege
            [questKeys.objectives] = {{{41572,nil,Questie.ICON_TYPE_EVENT},{40921,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {25968,25970,25971},
            [questKeys.requiredSourceItems] = {56188},
        },
        [25974] = { -- Sira'kess Slaying
            [questKeys.preQuestSingle] = {26092},
        },
        [25976] = { -- Treasure Reclamation
            [questKeys.preQuestSingle] = {26092},
        },
        [25977] = { -- A Standard Day for Azrajar
            [questKeys.objectives] = {{{41590,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25978] = { -- Entombed in Ice
            [questKeys.objectives] = {nil,nil,nil,nil,{{{41768,41763},41768}}},
        },
        [25980] = { -- A Standard Day for Azrajar
            [questKeys.objectives] = {{{41590,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {26092},
        },
        [25982] = { -- Those Aren't Masks
            [questKeys.preQuestSingle] = {26092},
        },
        [25983] = { -- Promontory Point
            [questKeys.nextQuestInChain] = 26070,
        },
        [25984] = { -- Promontory Point
            [questKeys.nextQuestInChain] = 26071,
        },
        [25985] = { -- Wings Over Mount Hyjal
            [questKeys.startedBy] = {{40833}},
            [questKeys.exclusiveTo] = {27874},
            [questKeys.nextQuestInChain] = 25663,
        },
        [25986] = { -- Trouble at the Lake
            [questKeys.preQuestGroup] = {432,433,25937},
            [questKeys.nextQuestInChain] = 25978,
        },
        [25987] = { -- Put It On
            [questKeys.objectives] = {{{41814,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25988] = { -- Put It On
            [questKeys.objectives] = {{{41814,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25989] = { -- Capture the Crab
            [questKeys.objectives] = {{{41520,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25907,25908},
        },
        [25990] = { -- Breaking Through
            [questKeys.objectives] = {{{41531,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25992] = { -- Hopelessly Gearless
            [questKeys.preQuestSingle] = {25991},
        },
        [25994] = { -- Still Valuable
            [questKeys.preQuestSingle] = {25991},
        },
        [25995] = { -- Overseer Idra'kess
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25992,25993,25994},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHIMMERING_EXPANSE]={{62.9,57.1}}}, Questie.ICON_TYPE_EVENT, l10n("Head to the top of Nespirah")}},
        },
        [25996] = { -- Waking the Beast
            [questKeys.objectives] = {{{41531},{41776,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [25997] = { -- Dark Iron Scheming
            [questKeys.preQuestGroup] = {25978,25979},
        },
        [25998] = { -- Get to the Airfield
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in"),0,{{"monster",41848}}}},
        },
        [25999] = { -- Barrier to Entry
            [questKeys.objectives] = {nil,{{460013}}}
        },
        [26000] = { -- Spelunking
            [questKeys.preQuestSingle] = {25794},
        },
        [26003] = { -- Lessons from the Lost Isles
            [questKeys.preQuestSingle] = {25999},
        },
        [26007] = { -- Debriefing
            [questKeys.objectives] = {{{41885,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {26000},
        },
        [26008] = { -- Decompression
            [questKeys.preQuestSingle] = {25887},
            [questKeys.objectives] = {{{41955,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26009] = { -- Seek and Destroy
            [questKeys.requiredMaxRep] = {76,21000},
        },
        [26010] = { -- Ashes to Ashes
            [questKeys.preQuestSingle] = {26004},
        },
        [26011] = { -- Enemy of the Horde: Marshal Paltrow
            [questKeys.preQuestSingle] = {26004},
        },
        [26019] = { -- Enormous Eel Egg
            [questKeys.startedBy] = {{41925,41926},nil,{56571}},
            [questKeys.preQuestSingle] = {26015},
        },
        [26021] = { -- The Brothers Digsong 2: Eel-Egg-Trick Boogaloo
            [questKeys.objectives] = {{{41927,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{42006,41927},41927}}},
        },
        [26026] = { -- Dream of a Better Tomorrow
            [questKeys.preQuestSingle] = {26004},
        },
        [26040] = { -- What? What? In My Gut...?
            [questKeys.preQuestSingle] = {25887},
        },
        [26043] = { -- BEWARE OF CRAGJAW!
            [questKeys.preQuestSingle] = {26004},
        },
        [26046] = { -- Between a Rock and a Hard Place
            [questKeys.preQuestSingle] = {26044},
        },
        [26047] = { -- And That's Why They Call Them Peons...
            [questKeys.preQuestSingle] = {26044},
        },
        [26048] = { -- Spare Parts Up In Here!
            [questKeys.preQuestGroup] = {26045,26046,26047},
        },
        [26049] = { -- The Princess Unleashed
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Summon Myzrael"),0,{{"object",138492}}}},
        },
        [26050] = { -- Goggle Boggle
            [questKeys.triggerEnd] = {"Defend Professor Phizzlethorpe", {[zoneIDs.ARATHI_HIGHLANDS]={{29.47,82.07}}}},
        },
        [26056] = { -- The Wavespeaker
            [questKeys.nextQuestInChain] = 26065,
        },
        [26057] = { -- The Wavespeaker
            [questKeys.preQuestSingle] = {25988},
            [questKeys.nextQuestInChain] = 26065,
        },
        [26059] = { -- Eyes and Ears: Malaka'jin
            [questKeys.preQuestSingle] = {26115},
        },
        [26060] = { -- Da Voodoo: Stormer Heart
            [questKeys.preQuestSingle] = {26059},
        },
        [26061] = { -- Da Voodoo: Ram Horns
            [questKeys.preQuestSingle] = {26059},
        },
        [26062] = { -- Da Voodoo: Resonite Crystal
            [questKeys.preQuestGroup] = {26060,26061},
        },
        [26064] = { -- Fight On Their Stomachs
            [questKeys.preQuestSingle] = {26059},
        },
        [26065] = { -- Free Wil'hai
            [questKeys.preQuestSingle] = {26080,26092},
            [questKeys.objectives] = {{{41642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill all three Tentacle Horrors"),0,{{"monster",41641}}}},
        },
        [26066] = { -- Reinforcements...
            [questKeys.preQuestGroup] = {26060,26061},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{11915,11917,11918},11915,"Boulderslide Kobold subdued",Questie.ICON_TYPE_INTERACT}}},
        },
        [26068] = { -- Kobold Fury!
            [questKeys.objectives] = {nil,{{203446}}},
        },
        [26069] = { -- Nura Pathfinder
            [questKeys.exclusiveTo] = {24504,28549},
        },
        [26070] = { -- Clearing the Defiled
            [questKeys.preQuestSingle] = {25987},
        },
        [26071] = { -- Clearing the Defiled
            [questKeys.preQuestSingle] = {25988},
        },
        [26072] = { -- Into the Totem
            [questKeys.objectives] = {nil,nil,nil,nil,{{{41644,42051},42051}}},
            [questKeys.preQuestSingle] = {25987,25988},
        },
        [26073] = { -- All's Quiet on the Southern Front
            [questKeys.preQuestGroup] = {26067,26068},
        },
        [26077] = { -- Final Delivery
            [questKeys.objectives] = {{{41418,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26078] = { -- Extinguish the Fires
            [questKeys.objectives] = {{{42046,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26079] = { -- Wanted!  Otto and Falconcrest
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26080] = { -- One Last Favor
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26017,26018},
        },
        [26082] = { -- To Battlescar!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in Krom'gar Demolisher"),0,{{"monster",35163}}}},
        },
        [26085] = { -- Rallying the Defenders
            [questKeys.objectives] = {nil,{{203452}}},
        },
        [26086] = { -- Orako
            [questKeys.preQuestSingle] = {26126},
        },
        [26088] = { -- Here Fishie Fishie
            [questKeys.preQuestSingle] = {26087},
        },
        [26089] = { -- Die Fishman Die
            [questKeys.preQuestSingle] = {26087},
        },
        [26090] = { -- I Brought You This Egg
            [questKeys.startedBy] = {{41925,41926},nil,{56812}},
            [questKeys.preQuestSingle] = {26087},
        },
        [26091] = { -- Here Fishie Fishie 2: Eel-Egg-Trick Boogaloo
            [questKeys.objectives] = {{{41927,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{42006,41927},41927}}},
        },
        [26092] = { -- Orako's Report
            [questKeys.preQuestGroup] = {26088,26089},
        },
        [26093] = { -- Northfold Manor
            [questKeys.preQuestSingle] = {},
        },
        [26094] = { -- Striking Back
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in"),0,{{"monster",42092}}}},
        },
        [26096] = { -- Scalding Shrooms
            [questKeys.preQuestSingle] = {25987,25988},
        },
        [26097] = { -- Proof of Lies
            [questKeys.preQuestSingle] = {26082},
        },
        [26099] = { -- Is This Justice?
            [questKeys.preQuestSingle] = {26098},
        },
        [26105] = { -- Claim Korthun's End
            [questKeys.startedBy] = {{42115}},
            [questKeys.exclusiveTo] = {26121},
        },
        [26106] = { -- Fuel-ology 101
            [questKeys.objectives] = {nil,{{203461}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Three Hammerhead Oil and two Remora Oil"), 0, {{"object", 203461}}}},
            [questKeys.requiredSourceItems] = {56833},
        },
        [26111] = { -- ... It Will Come
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon Ick'thys the Unfathomable"), 0, {{"object", 203456}}}},
        },
        [26116] = { -- Kinelory Strikes
            [questKeys.triggerEnd] = {"Protect Kinelory", {[zoneIDs.ARATHI_HIGHLANDS] = {{54.85,55.55}}}},
            [questKeys.preQuestSingle] = {26114},
        },
        [26118] = { -- Seize the Ambassador
            [questKeys.objectives] = {{{42146,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.IRONFORGE] = {{41.67,53.03}}},Questie.ICON_TYPE_EVENT,l10n("The High Seat")}},
            [questKeys.preQuestSingle] = {26112},
        },
        [26121] = { -- Claim Korthun's End
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27443,26219},
            [questKeys.exclusiveTo] = {26105},
        },
        [26122] = { -- Environmental Awareness
            [questKeys.preQuestSingle] = {26221},
        },
        [26124] = { -- Secure Seabrush
            [questKeys.startedBy] = {{42114}},
            [questKeys.preQuestSingle] = {26006},
            [questKeys.exclusiveTo] = {26125},
        },
        [26125] = { -- Secure Seabrush
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26006,26221},
            [questKeys.exclusiveTo] = {26124},
        },
        [26126] = { -- The Perfect Fuel
            [questKeys.objectives] = {nil,{{203461}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Three Hammerhead Oil and two Remora Oil"), 0, {{"object", 203461}}}},
            [questKeys.requiredSourceItems] = {56833},
        },
        [26127] = { -- The Twilight's Hammer Revealed
            [questKeys.preQuestSingle] = {},
        },
        [26131] = { -- Reinforcements for Loch Modan
            [questKeys.exclusiveTo] = {28567},
        },
        [26133] = { -- Fiends from the Netherworld
            [questKeys.preQuestSingle] = {26111},
        },
        [26134] = { -- Nothing Left for You Here
            [questKeys.preQuestSingle] = {26115},
        },
        [26135] = { -- Visions of the Past: Rise from the Deep
            [questKeys.preQuestSingle] = {25973},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460005}}}},
            [questKeys.objectives] = {{{41982,nil,Questie.ICON_TYPE_EVENT},{41222}}},
        },
        [26137] = { -- Checking on the Boys
            [questKeys.nextQuestInChain] = 25395,
        },
        [26139] = { -- Into Arathi
            [questKeys.nextQuestInChain] = 26093,
        },
        [26143] = { -- All That Rises
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Control the Bound Torrent"),0,{{"monster",47969}}}},
        },
        [26144] = { -- Prisoners
            [questKeys.startedBy] = {{41652,41657},nil,{57102}},
            [questKeys.preQuestSingle] = {26140},
            [questKeys.objectives] = {{{42225,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",203709}}}},
        },
        [26145] = { -- The Trogg Threat
            [questKeys.preQuestSingle] = {},
        },
        [26147] = { -- Bigger and Uglier
            [questKeys.preQuestSingle] = {26146},
        },
        [26149] = { -- Prisoners
            [questKeys.startedBy] = {{41652,41657},nil,{57118}},
            [questKeys.preQuestSingle] = {26140},
            [questKeys.objectives] = {{{42234,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",203709}}}},
        },
        [26150] = { -- A Visit With Maybell
            [questKeys.preQuestSingle] = {60},
            [questKeys.exclusiveTo] = {106},
            [questKeys.nextQuestInChain] = 106,
        },
        [26154] = { -- Twilight Extermination
            [questKeys.objectives] = {{{47969,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{42281,42280},42280},{{42285},42285}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26141,26142},
        },
        [26160] = { -- Blood Ritual
            [questKeys.objectives] = {{{42298,nil,Questie.ICON_TYPE_TALK}}},
        },
        [26170] = { -- The Final Ritual
            [questKeys.objectives] = {{{42298,nil,Questie.ICON_TYPE_TALK}}},
        },
        [26176] = { -- Onward to Thelsamar
            [questKeys.nextQuestInChain] = 26842,
        },
        [26179] = { -- The Venture Co.
            [questKeys.preQuestSingle] = {751},
        },
        [26180] = { -- Supervisor Fizsprocket
            [questKeys.preQuestSingle] = {751},
        },
        [26182] = { -- Back to the Tenebrous Cavern
            [questKeys.preQuestSingle] = {26143},
        },
        [26186] = { -- Demoniac Vessel
            [questKeys.requiredSourceItems] = {57177,57178,57179},
        },
        [26189] = { -- The Angerfang Menace
            [questKeys.nextQuestInChain] = 26195,
        },
        [26191] = { -- The Culmination of Our Efforts
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25859,25863},
        },
        [26193] = { -- Defending the Rift
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Erunak"), 0, {{"monster", 41600}}}},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Fight in the Battle for the Abyssal Breach", {[zoneIDs.ABYSSAL_DEPTHS] = {{69.57,34.79}}}},
        },
        [26194] = { -- Defending the Rift
            [questKeys.preQuestSingle] = {26182},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Erunak"), 0, {{"monster", 41600}}}},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Fight in the Battle for the Abyssal Breach", {[zoneIDs.ABYSSAL_DEPTHS] = {{69.57,34.79}}}},
        },
        [26197] = { -- The Future of Gnomeregan
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26198] = { -- The Arts of a Mage
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 42331}}}},
        },
        [26199] = { -- The Future of Gnomeregan
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26200] = { -- The Arts of a Priest
            [questKeys.objectives] = {{{42501,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 42323}}}},
        },
        [26201] = { -- The Power of a Warlock
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 460}}}},
        },
        [26202] = { -- The Future of Gnomeregan
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26203] = { -- The Future of Gnomeregan
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26204] = { -- The Arts of a Warrior
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 42324}}}},
        },
        [26205] = { -- A Job for the Multi-Bot
            [questKeys.objectives] = {{{42563,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26206] = { -- The Future of Gnomeregan
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26207] = { -- The Arts of a Rogue
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 42366}}}},
        },
        [26208] = { -- The Fight Continues
            [questKeys.objectives] = {{{42463,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26209] = { -- Murder Was The Case That They Gave Me
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{42383,42391,42386},42383,nil,Questie.ICON_TYPE_TALK},{{42383,42391,42386},42383,nil,Questie.ICON_TYPE_TALK},{{42383,42391,42386},42383,nil,Questie.ICON_TYPE_TALK},{{42383,42391,42386},42383,nil,Questie.ICON_TYPE_TALK}}},
        },
        [26213] = { -- Hot On the Trail: The Riverpaw Clan
            [questKeys.preQuestSingle] = {26209},
        },
        [26214] = { -- Hot On the Trail: Murlocs
            [questKeys.preQuestSingle] = {26209},
        },
        [26215] = { -- Meet Two-Shoed Lou
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26213,26214},
        },
        [26219] = { -- Full Circle
            [questKeys.objectives] = {{{42486,nil,Questie.ICON_TYPE_EVENT},{48416,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26221] = { -- Full Circle
            [questKeys.preQuestSingle] = {26006},
            [questKeys.objectives] = {{{42486,nil,Questie.ICON_TYPE_EVENT},{48416,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26222] = { -- Scrounging for Parts
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26228] = { -- Livin' the Life
            [questKeys.triggerEnd] = {"Livin' the Life!", {[zoneIDs.WESTFALL]={{46.25,18.99}}}},
        },
        [26229] = { -- "I TAKE Candle!"
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {26215},
        },
        [26230] = { -- Feast or Famine
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {26215},
        },
        [26232] = { -- Lou's Parting Thoughts
            [questKeys.objectives] = {{{42417,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26233] = { -- Stealing From Our Own
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE - raceKeys.TROLL,
        },
        [26234] = { -- Stealing From Our Own
            [questKeys.requiredRaces] = raceKeys.TROLL,
        },
        [26236] = { -- Shakedown at the Saldean's
            [questKeys.preQuestSingle] = {26232},
        },
        [26237] = { -- Times are Tough
            [questKeys.preQuestSingle] = {26236},
        },
        [26241] = { -- Westfall Stew
            [questKeys.preQuestSingle] = {26236},
        },
        [26245] = { -- Gunship Down
            [questKeys.objectives] = {{{43048,nil,Questie.ICON_TYPE_EVENT},{43032,nil,Questie.ICON_TYPE_EVENT},{43044,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
        },
        [26247] = { -- Diplomacy First
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26244,26245,26246,27136},
        },
        [26248] = { -- All Our Friends Are Dead
            [questKeys.preQuestSingle] = {26247},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{42681,42682,42747,42757},42681,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26249] = { -- The Admiral's Cabin
            [questKeys.preQuestSingle] = {26247},
        },
        [26250] = { -- On Second Thought, Take One Prisoner
            [questKeys.preQuestSingle] = {26248},
        },
        [26252] = { -- Heart of the Watcher
            [questKeys.preQuestSingle] = {26236},
            [questKeys.startedBy] = {{114},nil,{57935}},
        },
        [26254] = { -- Some Spraining to Do
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 42716}}}},
            [questKeys.objectives] = {{{42964,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26257] = { -- It's Alive!
            [questKeys.objectives] = {{{42381,nil,Questie.ICON_TYPE_INTERACT},{42342}}},
        },
        [26258] = { -- Deathwing's Fall
            [questKeys.triggerEnd] = {"Deathwing's Fall reached", {[zoneIDs.DEEPHOLM]={{61.3,57.5}}}},
        },
        [26259] = { -- Blood of the Earthwarder
            [questKeys.preQuestSingle] = {26255},
        },
        [26261] = { -- Question the Slaves
            [questKeys.objectives] = {{{44768,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {60739},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Unlock the Ball and Chain"),0,{{"object",205098}}}},
        },
        [26264] = { -- What's Left Behind
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26265] = { -- Dealing with the Fallout
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26266] = { -- Hope for the People
            [questKeys.preQuestSingle] = {26270},
        },
        [26269] = { -- The Green Hills of Stranglethorn
            [questKeys.preQuestSingle] = {583},
        },
        [26270] = { -- You Have Our Thanks
            [questKeys.preQuestSingle] = {26241},
        },
        [26271] = { -- Feeding the Hungry and the Hopeless
            [questKeys.objectives] = {nil,nil,nil,nil,{{{42383,42384,42386,42390,42391,42400},42383,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26273] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26274] = { -- The Arts of a Warlock
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 42618}}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.zoneOrSort] = 6453,
        },
        [26275] = { -- A Rough Start
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26276] = { -- Proving Pit
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26277] = { -- More Than Expected
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26284] = { -- Missing in Action
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",460002}}}},
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26285] = { -- Get Me Explosives Back!
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26286] = { -- In Defense of Westfall
            [questKeys.preQuestSingle] = {26266},
        },
        [26287] = { -- The Westfall Brigade
            [questKeys.preQuestSingle] = {26266},
        },
        [26289] = { -- Find Agent Kearnen
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26286,26271}, -- needs check if 26287 is ALSO required. Turn it in last
        },
        [26290] = { -- Secrets of the Tower
            [questKeys.objectives] = {{{42655,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26292] = { -- To Moonbrook!
            [questKeys.preQuestSingle] = {26291},
        },
        [26293] = { -- Machines of War
            [questKeys.startedBy] = {{39605}},
            [questKeys.preQuestSingle] = {},
        },
        [26294] = { -- Weapons of Mass Dysfunction
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{42673,nil,Questie.ICON_TYPE_INTERACT},{42671,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26296] = { -- Evidence Collection
            [questKeys.startedBy] = {{42677},nil,{58117}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {26292}, -- might be 26291, needs double check
        },
        [26297] = { -- The Dawning of a New Day
            [questKeys.objectives] = {{{42680,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26298] = { -- Hunt for Yenniku
            [questKeys.preQuestSingle] = {26280},
        },
        [26300] = { -- Nezzliok Will Know
            [questKeys.preQuestSingle] = {26299},
        },
        [26301] = { -- Speaking with Nezzliok
            [questKeys.preQuestSingle] = {26300},
        },
        [26304] = { -- Nighttime in the Jungle
            [questKeys.preQuestSingle] = {26359},
        },
        [26311] = { -- Unfamiliar Waters
            [questKeys.preQuestSingle] = {},
        },
        [26312] = { -- Crumbling Defenses
            [questKeys.preQuestSingle] = {26326},
            [questKeys.objectives] = {{{44352,nil,Questie.ICON_TYPE_EVENT},{44353,nil,Questie.ICON_TYPE_EVENT},{42788,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26313] = { -- Core of Our Troubles
            [questKeys.preQuestSingle] = {26326},
        },
        [26314] = { -- On Even Ground
            [questKeys.preQuestSingle] = {26326},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{42479,42781},42781}}},
        },
        [26315] = { -- Imposing Confrontation
            [questKeys.preQuestGroup] = {26312,26313,26314},
            [questKeys.objectives] = {{{42471,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26316] = { -- What's Keeping Jessup?
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26318] = { -- Finishin' the Job
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.objectives] = {nil,{{204042}},nil,nil,{{{42773},42773}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26284,26285},
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26320] = { -- A Vision of the Past
            [questKeys.triggerEnd] = {"Vision of the Past uncovered", {[zoneIDs.THE_DEADMINES]={{25,14.5},{-1,-1}}}},
        },
        [26322] = { -- Rise of the Brotherhood
            [questKeys.finishedBy] = {{29611}},
            [questKeys.triggerEnd] = {"Rise of the Brotherhood witnessed", {[zoneIDs.WESTFALL]={{56.29,47.52}}}},
        },
        [26324] = { -- Where Is My Warfleet?
            [questKeys.startedBy] = {{39605}},
            [questKeys.preQuestGroup] = {26294,26311},
            [questKeys.preQuestSingle] = {},
        },
        [26325] = { -- A Nose for This Sort of Thing
            [questKeys.preQuestSingle] = {26323},
        },
        [26326] = { -- The Very Earth Beneath Our Feet
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26876,27938},
        },
        [26327] = { -- Anvilmar the Hero
            [questKeys.nextQuestInChain] = 26127,
        },
        [26329] = { -- One More Thing
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26331] = { -- Crushcog's Minions
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26333] = { -- No Tanks!
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26334] = { -- Bloodlord Mandokir
            [questKeys.preQuestSingle] = {26332},
        },
        [26335] = { -- Ready the Navy
            [questKeys.preQuestSingle] = {26324},
        },
        [26337] = { -- Beating the Market
            [questKeys.objectives] = {{{42777}}},
        },
        [26338] = { -- Population Con-Troll
            [questKeys.preQuestSingle] = {26299},
        },
        [26339] = { -- Staging in Brewnall
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26331,26333},
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26340] = { -- The Hunt
            [questKeys.preQuestSingle] = {9457},
        },
        [26342] = { -- Paint it Black
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.objectives] = {{{42291,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26346] = { -- Myzrael's Tale [Alliance]
            [questKeys.preQuestSingle] = {26042},
        },
        [26348] = { -- The Coast Isn't Clear
            [questKeys.preQuestSingle] = {},
        },
        [26350] = { -- Priestess Hu'rala
            [questKeys.preQuestSingle] = {26334},
        },
        [26352] = { -- Cozzle's Plan
            [questKeys.preQuestSingle] = {26399},
        },
        [26353] = { -- Captain Sanders' Hidden Treasure
            [questKeys.startedBy] = {{513,515,126,171,456,127,517,458,391},nil,{1357}},
            [questKeys.finishedBy] = {nil,{35}},
        },
        [26354] = { -- Captain Sanders' Hidden Treasure
            [questKeys.startedBy] = {nil,{35}},
            [questKeys.finishedBy] = {nil,{36}},
        },
        [26355] = { -- Captain Sanders' Hidden Treasure
            [questKeys.startedBy] = {nil,{36}},
            [questKeys.finishedBy] = {nil,{34}},
        },
        [26356] = { -- Captain Sanders' Hidden Treasure
            [questKeys.startedBy] = {nil,{34}},
            [questKeys.finishedBy] = {nil,{33}},
        },
        [26358] = { -- Ready the Air Force
            [questKeys.preQuestSingle] = {26324},
        },
        [26361] = { -- Smoot's Samophlange
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Stop Smoot"),0,{{"monster",42644}}}},
        },
        [26364] = { -- Down with Crushcog!
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to High Tinker Mekkatorque"),0,{{"monster",42849}}}},
            [questKeys.objectives] = {{{42839}}},
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26365] = { -- Hero's Call: Redridge Mountains!
            [questKeys.nextQuestInChain] = 26503,
            [questKeys.exclusiveTo] = {28563},
        },
        [26371] = { -- The Legend of Captain Grayson
            [questKeys.nextQuestInChain] = 26348,
        },
        [26373] = { -- On to Kharanos
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.exclusiveTo] = {25724},
        },
        [26374] = { -- Ready the Ground Troops
            [questKeys.objectives] = {{{42646}}},
        },
        [26375] = { -- Loose Stones
            [questKeys.preQuestSingle] = {26328},
            [questKeys.objectives] = {{{42900,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26376] = { -- Hatred Runs Deep
            [questKeys.preQuestSingle] = {26328},
            [questKeys.exclusiveTo] = {},
        },
        [26377] = { -- Unsolid Ground
            [questKeys.requiredSourceItems] = {58500,58783},
            [questKeys.preQuestSingle] = {26328},
            [questKeys.exclusiveTo] = {},
            [questKeys.objectives] = {{{43031,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26378] = { -- Hero's Call: Westfall!
            [questKeys.nextQuestInChain] = 26209,
        },
        [26388] = { -- Twilight Skies
            [questKeys.extraObjectives] = {{{[zoneIDs.AZSHARA]={{50.7,73.9}}}, Questie.ICON_TYPE_EVENT, l10n("Wait for the Zeppelin")}},
            [questKeys.preQuestSingle] = {28849},
        },
        [26389] = { -- Blackrock Invasion
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [26390] = { -- Ending the Invasion!
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [26391] = { -- Extinguishing Hope
            [questKeys.preQuestSingle] = {28817,28818,28819,28820,28821,28822,28823,29083},
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{42940,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26393] = { -- A Swift Message
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [26394] = { -- Continue to Stormwind
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [26395] = { -- Dungar Longdrink
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [26396] = { -- Return to Argus
            [questKeys.requiredRaces] = raceKeys.HUMAN,
        },
        [26397] = { -- Walk With The Earth Mother
            [questKeys.finishedBy] = {{39605}},
            [questKeys.preQuestSingle] = {24540},
            [questKeys.requiredRaces] = raceKeys.TAUREN,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tal"),0,{{"monster",2995}}}},
        },
        [26398] = { -- Walk With The Earth Mother
            [questKeys.finishedBy] = {{39605}},
        },
        [26401] = { -- Return to Vestia
            [questKeys.preQuestSingle] = {25368},
        },
        [26403] = { -- Venture Company Mining
            [questKeys.preQuestSingle] = {26399},
        },
        [26405] = { -- Zul'Mamwe Mambo
            [questKeys.preQuestSingle] = {26359},
        },
        [26408] = { -- Ashes in Ashenvale
            [questKeys.preQuestSingle] = {13897},
        },
        [26409] = { -- Where's Goldmine?
            [questKeys.preQuestSingle] = {},
        },
        [26410] = { -- Explosive Bonding Compound
            [questKeys.preQuestSingle] = {26409},
            [questKeys.exclusiveTo] = {},
        },
        [26411] = { -- Apply and Flash Dry
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26410,27135},
            [questKeys.objectives] = {{{43036,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26413] = { -- Take Him to the Earthcaller
            [questKeys.objectives] = {{{44207,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26414] = { -- Hitting a Walleye
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORMWIND_CITY]={{50.84,32.69}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Hardened Walleye")}},
        },
        [26420] = { -- Diggin' For Worms
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26442,26488,26536},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.STORMWIND_CITY]={{59.92,15.33}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Crystal Bass")},
            },
            [questKeys.requiredSourceItems] = {58788},
        },
        [26421] = { -- Meet the High Tinker
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26422] = { -- Meet the High Tinker
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26423] = { -- Meet the High Tinker
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26424] = { -- Meet the High Tinker
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26425] = { -- Meet the High Tinker
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26426] = { -- Violent Gale
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26375,26376,26377},
            [questKeys.objectives] = {{{44281,nil,Questie.ICON_TYPE_EVENT},{44282,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26433] = { -- The Holy Water of Clarity
            [questKeys.exclusiveTo] = {26590},
        },
        [26434] = { -- Primal Reagents of Power
            [questKeys.preQuestSingle] = {26433},
        },
        [26436] = { -- Entrenched
            [questKeys.preQuestSingle] = {26871},
        },
        [26437] = { -- Making Things Crystal Clear
            [questKeys.preQuestSingle] = {26436},
        },
        [26438] = { -- Intervention
            [questKeys.preQuestSingle] = {26436},
        },
        [26439] = { -- Putting the Pieces Together
            [questKeys.preQuestSingle] = {26436},
            [questKeys.objectives] = {{{43115,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26440] = { -- Clingy
            [questKeys.triggerEnd] = {"Pebble brought to crystal formation",{[zoneIDs.DEEPHOLM]={{29.45,47.47}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {26439},
        },
        [26442] = { -- Rock Lobster
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26488,26536},
        },
        [26443] = { -- Diabolical Plans [Alliance]
            [questKeys.startedBy] = {{6073,6115,11697}},
        },
        [26447] = { -- Diabolical Plans [Horde]
            [questKeys.startedBy] = {{6073,6115,11697}},
        },
        [26452] = { -- Gurubashi Challenge
            [questKeys.preQuestSingle] = {26451},
        },
        [26454] = { -- A Shameful Waste
            [questKeys.preQuestSingle] = {},
        },
        [26463] = { -- Finding Teronis
            [questKeys.preQuestSingle] = {13623},
        },
        [26465] = { -- The Ancient Statuettes
            [questKeys.preQuestSingle] = {},
        },
        [26466] = { -- Ruuzel
            [questKeys.preQuestSingle] = {26465},
        },
        [26469] = { -- Satyr Slaying!
            [questKeys.preQuestSingle] = {26468},
        },
        [26470] = { -- Retaking Mystral Lake
            [questKeys.preQuestSingle] = {},
        },
        [26472] = { -- Insane Druids
            [questKeys.preQuestSingle] = {13792},
        },
        [26475] = { -- Elune's Tear
            [questKeys.preQuestSingle] = {26474},
        },
        [26476] = { -- Dryad Delivery
            [questKeys.preQuestSingle] = {26475},
        },
        [26482] = { -- True Power of the Rod
            [questKeys.objectives] = {{{34618,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26488] = { -- Big Gulp
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26442,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORMWIND_CITY]={{69.12,88.51},{73.31,83.29}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Royal Monkfish")}},
            [questKeys.requiredSourceItems] = {58856},
        },
        [26493] = { -- There's Somebody Out There Who Wants It
            [questKeys.preQuestGroup] = {26450,26487},
        },
        [26494] = { -- Mixmaster Jasper
            [questKeys.preQuestSingle] = {26493},
        },
        [26495] = { -- Chabal
            [questKeys.preQuestSingle] = {26493},
        },
        [26496] = { -- Down with the Vilebranch
            [questKeys.nextQuestInChain] = 26497,
        },
        [26497] = { -- Vilebranch Scum
            [questKeys.preQuestSingle] = {},
        },
        [26499] = { -- Stonefather's Boon
            [questKeys.objectives] = {{{43138,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26500] = { -- We're Surrounded
            [questKeys.preQuestSingle] = {27935,27936},
        },
        [26501] = { -- Sealing the Way
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Rockslide Reagent on Earthen Geomancer"),0,{{"monster",43170}}}},
            [questKeys.objectives] = {{{43164,nil,Questie.ICON_TYPE_EVENT},{43165,nil,Questie.ICON_TYPE_EVENT},{43166,nil,Questie.ICON_TYPE_EVENT},{43167,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26503] = { -- Still Assessing the Threat
            [questKeys.preQuestSingle] = {},
        },
        [26507] = { -- Petrified Delicacies
            [questKeys.preQuestSingle] = {26441},
        },
        [26510] = { -- We Must Prepare!
            [questKeys.preQuestSingle] = {},
        },
        [26512] = { -- Tuning the Gnomecorder
            [questKeys.triggerEnd] = {"Test the Gnomecorder at the Lakeshire Graveyard", {[zoneIDs.REDRIDGE_MOUNTAINS]={{32.3,39.5}}}},
        },
        [26513] = { -- Like a Fart in the Wind
            [questKeys.preQuestSingle] = {26510},
        },
        [26519] = { -- He Who Controls the Ettins
            [questKeys.startedBy] = {{430,445,446,580},nil,{58898}},
            [questKeys.preQuestSingle] = {26512},
        },
        [26520] = { -- Saving Foreman Oslow
            [questKeys.objectives] = {{{341,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_INTERACT, l10n("Control the Canyon Ettin"),0,{{"monster",43094}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Ettin to lift the boulder"),0,{{"monster",43196}}},
            },
        },
        [26536] = { -- Thunder Falls
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26442,26488},
            [questKeys.extraObjectives] = {{{[zoneIDs.ELWYNN_FOREST]={{26.50,60.57},{24.5,59.57},{21.49,59.4}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Violet Perch")}},
        },
        [26538] = { -- Emergency Aid
            [questKeys.objectives] = {{{43191,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {26388},
        },
        [26539] = { -- Stalled Negotiations
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Go to the shore"),0,{{"monster",43188}}}},
        },
        [26540] = { -- Dangerous Compassion
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Go back to the ship"),0,{{"monster",43188}}}},
        },
        [26545] = { -- Yowler Must Die!
            [questKeys.startedBy] = {{344}},
        },
        [26546] = { -- Razorbeak Friends
            [questKeys.objectives] = {{{2657,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26549] = { -- Madness
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Negotiations Concluded",{[zoneIDs.TWILIGHT_HIGHLANDS]={{75.5,55.25}}}},
        },
        [26542] = { -- Hero's Call: The Hinterlands!
            [questKeys.requiredMaxLevel] = 33,
            [questKeys.nextQuestInChain] = 26547,
        },
        [26543] = { -- Clammy Hands
            [questKeys.exclusiveTo] = {26572,26557,26556,26588,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
        },
        [26553] = { -- High Priestess Jeklik
            [questKeys.preQuestSingle] = {26552},
        },
        [26556] = { -- No Dumping Allowed
            [questKeys.exclusiveTo] = {26572,26543,26557,26588,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.ORGRIMMAR]={{37.8,81.3}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Toxic Puddlefish")}},
        },
        [26557] = { -- A Staggering Effort
            [questKeys.exclusiveTo] = {26572,26543,26556,26588,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
            [questKeys.requiredSourceItems] = {58949},
            [questKeys.extraObjectives] = {{{[zoneIDs.ORGRIMMAR]={{47.1,46.3}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Attach a Stag Eye to your Fishing Pole and fish for Sandy Carp")}},
        },
        [26560] = { -- Jorgensen
            [questKeys.preQuestSingle] = {26587},
        },
        [26561] = { -- Krakauer
            [questKeys.preQuestSingle] = {26560},
        },
        [26562] = { -- And Last But Not Least... Danforth
            [questKeys.preQuestSingle] = {26561},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Free Danforth"),0,{{"object",460019}}}},
        },
        [26563] = { -- Return of the Bravo Company
            [questKeys.preQuestSingle] = {26562},
            [questKeys.exclusiveTo] = {},
        },
        [26566] = { -- A Triumph of Gnomish Ingenuity
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.requiredRaces] = raceKeys.GNOME,
        },
        [26567] = { -- John J. Keeshan
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26520,26545},
        },
        [26569] = { -- Surveying Equipment
            [questKeys.preQuestSingle] = {26568},
        },
        [26570] = { -- Render's Army
            [questKeys.preQuestSingle] = {26568},
        },
        [26572] = { -- A Golden Opportunity
            [questKeys.requiredSourceItems] = {58958},
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
        },
        [26573] = { -- His Heart Must Be In It
            [questKeys.exclusiveTo] = {},
        },
        [26575] = { -- Rock Bottom
            [questKeys.preQuestSingle] = {26441},
        },
        [26576] = { -- Steady Hand
            [questKeys.preQuestGroup] = {26507,26575},
        },
        [26577] = { -- Rocky Upheaval
            [questKeys.preQuestGroup] = {26507,26575},
        },
        [26578] = { -- Doomshrooms
            [questKeys.preQuestSingle] = {26577},
        },
        [26579] = { -- Gone Soft
            [questKeys.preQuestSingle] = {26577},
        },
        [26580] = { -- Familiar Intruders
            [questKeys.preQuestSingle] = {26577},
        },
        [26581] = { -- A Head Full of Wind
            [questKeys.objectives] = {{{43370,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26583] = { -- Wrath of the Fungalmancer
            [questKeys.preQuestSingle] = {26582},
            [questKeys.objectives] = {{{43503,nil,Questie.ICON_TYPE_TALK},{43372}}},
        },
        [26584] = { -- Shaken and Stirred
            [questKeys.preQuestSingle] = {26582},
            [questKeys.exclusiveTo] = {},
        },
        [26585] = { -- Corruption Destruction
            [questKeys.preQuestSingle] = {26582},
        },
        [26586] = { -- In Search of Bravo Company
            [questKeys.preQuestSingle] = {26568},
        },
        [26588] = { -- A Furious Catch
            [questKeys.exclusiveTo] = {26572,26557,26543,26556,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_BARRENS]={{71.1,7.9}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Giant Furious Pike")}},
        },
        [26589] = { -- The Wilds of Feralas [Horde]
            [questKeys.preQuestGroup] = {14381,14394},
            [questKeys.exclusiveTo] = {25210,28510},
        },
        [26590] = { -- The Holy Water of Clarity
            [questKeys.exclusiveTo] = {26433},
        },
        [26591] = { -- Battlefront Triage
            [questKeys.objectives] = {{{43229,"Injured Earthen patched up",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {26501,26502},
        },
        [26592] = { -- Diffractory Chromascope
            [questKeys.preQuestSingle] = {26433},
        },
        [26597] = { -- Stranglethorn Fever
            [questKeys.childQuests] = {26598},
        },
        [26598] = { -- The Heart of Mokk
            [questKeys.objectivesText] = {},
            [questKeys.parentQuest] = 26597,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [26602] = { -- A Dish Best Served Huge
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Negolash"), 0, {{"object", 2289}}}},
        },
        [26607] = { -- They Drew First Blood
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26563,26573},
        },
        [26609] = { -- The Bloodsail Buccaneers
            [questKeys.preQuestSingle] = {26595,26601,26606},
        },
        [26613] = { -- Up to Snuff
            [questKeys.preQuestSingle] = {26611},
        },
        [26614] = { -- Keep An Eye Out
            [questKeys.preQuestSingle] = {26611},
        },
        [26616] = { -- It's Never Over
            [questKeys.preQuestSingle] = {26607},
            [questKeys.objectives] = {{{43443,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [26618] = { -- Wolves at Our Heels
            [questKeys.preQuestSingle] = {},
        },
        [26619] = { -- You Say You Want a Revolution
            [questKeys.preQuestGroup] = {26540,26608},
        },
        [26621] = { -- Insurrection
            [questKeys.objectives] = {{{43575},{43394}},nil,nil,nil,{{{43577,43578},43577,"Dragonmaw Civilian Armed",Questie.ICON_TYPE_TALK}}},
        },
        [26625] = { -- Troggzor the Earthinator
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26537,26564,26591},
        },
        [26627] = { -- The Hermit
            [questKeys.nextQuestInChain] = 26653,
            [questKeys.preQuestSingle] = {26618},
        },
        [26628] = { -- Death from Below
            [questKeys.triggerEnd] = {"Defend Shakes O'Breen", {[zoneIDs.ARATHI_HIGHLANDS]={{24.76,86.2}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Fire the cannon"), 0, {{"object", 113531}}}},
        },
        [26629] = { -- Seeing Where Your Loyalties Lie
            [questKeys.childQuests] = {26630},
        },
        [26630] = { -- Looks Like a Tauren Pirate to Me
            [questKeys.parentQuest] = 26629,
            [questKeys.objectives] = {{{2487,nil,Questie.ICON_TYPE_TALK}},nil,{{59148,nil,Questie.ICON_TYPE_TALK},{59147,nil,Questie.ICON_TYPE_TALK}},nil,},
        },
        [26632] = { -- Close Escort
            [questKeys.triggerEnd] = {"Earthen Catapult safely escorted", {[zoneIDs.DEEPHOLM]={{21.8,51.7}}}},
            [questKeys.objectives] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Peak Grindstone"), 0, {{"monster", 45043}}}},
        },
        [26634] = { -- The Bane of Many A Pirate
            [questKeys.preQuestSingle] = {26631},
        },
        [26635] = { -- Cannonball Swim
            [questKeys.preQuestSingle] = {26631},
        },
        [26636] = { -- Bravo Company Field Kit: Camouflage
            [questKeys.preQuestSingle] = {26616},
        },
        [26637] = { -- Bravo Company Field Kit: Chloroform
            [questKeys.preQuestSingle] = {26616},
        },
        [26638] = { -- Hunting the Hunters
            [questKeys.preQuestSingle] = {26616},
        },
        [26642] = { -- Preserving the Barrens
            [questKeys.exclusiveTo] = {28494},
            [questKeys.nextQuestInChain] = 871,
        },
        [26644] = { -- Attracting Attention
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26634,26635},
        },
        [26645] = { -- The Night Watch
            [questKeys.preQuestSingle] = {26618},
        },
        [26646] = { -- Prisoners of War
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26637,26638,26639,26640},
            [questKeys.requiredSourceItems] = {59261},
            [questKeys.objectives] = {nil,{{460020,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26647] = { -- Ol' Blasty
            [questKeys.preQuestSingle] = {26644},
        },
        [26648] = { -- Our Mortal Enemies
            [questKeys.preQuestSingle] = {26644},
        },
        [26650] = { -- The Damsel's Luck
            [questKeys.preQuestSingle] = {26649},
        },
        [26651] = { -- To Win a War, You Gotta Become War
            [questKeys.startedBy] = {{43458}},
            [questKeys.objectives] = {nil,{{204444,nil,Questie.ICON_TYPE_EVENT}},nil,nil,{{{43590},43590,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26656] = { -- Don't. Stop. Moving.
            [questKeys.extraObjectives] = {{{[zoneIDs.DEEPHOLM]={{50.61,13.76}}}, Questie.ICON_TYPE_EVENT, l10n("Bring the Opalescent Guardians here")}},
            [questKeys.objectives] = {{{42466,nil,Questie.ICON_TYPE_TALK},{43591,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26657] = { -- Hard Falls
            [questKeys.preQuestSingle] = {26656},
            [questKeys.exclusiveTo] = {},
        },
        [26658] = { -- Fragile Values
            [questKeys.preQuestSingle] = {26656},
            [questKeys.exclusiveTo] = {},
        },
        [26659] = { -- Resonating Blow
            [questKeys.objectives] = {{{43641}},{{204837}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26657,26658},
            [questKeys.exclusiveTo] = {},
        },
        [26662] = { -- The Brashtide Crew
            [questKeys.preQuestSingle] = {26650},
            [questKeys.objectives] = {{{43659,"Speak with Long John Copper",Questie.ICON_TYPE_TALK},{43660,"Speak with Enormous Shawn Stooker",Questie.ICON_TYPE_TALK},{43661,"Speak with Wailing Mary Smitts",Questie.ICON_TYPE_TALK}}}
        },
        [26663] = { -- Sinking From Within
            [questKeys.preQuestSingle] = {26650},
            [questKeys.objectives] = {{{43623,"Sabotage the Grog",Questie.ICON_TYPE_INTERACT},{43631,"Sabotage the Gunpowder",Questie.ICON_TYPE_INTERACT},{43632,"Sabotage the Cannonballs",Questie.ICON_TYPE_INTERACT}}}
        },
        [26664] = { -- Making Mutiny
            [questKeys.preQuestSingle] = {26650},
        },
        [26665] = { -- Call of Booty
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26662,26663,26664},
        },
        [26668] = { -- Detonation
            [questKeys.triggerEnd] = {"Blow up Render's Valley.", {[zoneIDs.REDRIDGE_MOUNTAINS]={{77.19,65.64}}}},
            [questKeys.preQuestSingle] = {26651},
        },
        [26682] = { -- A Shambling Threat
            [questKeys.preQuestSingle] = {},
        },
        [26683] = { -- Look To The Stars
            [questKeys.preQuestSingle] = {26618},
        },
        [26692] = { -- Shadowhide Extinction
            [questKeys.preQuestSingle] = {26668},
        },
        [26693] = { -- The Dark Tower
            [questKeys.preQuestSingle] = {26668},
        },
        [26694] = { -- The Grand Magus Doane
            [questKeys.startedBy] = {{43611}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Unlock the ward"), 0, {{"object", 460021}}}},
        },
        [26695] = { -- Prepare for Takeoff
            [questKeys.preQuestSingle] = {26679},
        },
        [26697] = { -- The Final Voyage of the Brashtide
            [questKeys.preQuestSingle] = {26695},
        },
        [26698] = { -- Seeking Seahorn
            [questKeys.preQuestSingle] = {26679},
        },
        [26699] = { -- Turning the Brashtide
            [questKeys.preQuestSingle] = {26698},
        },
        [26700] = { -- The Damsel's (Bad) Luck
            [questKeys.preQuestSingle] = {26698},
        },
        [26701] = { -- Flight to Brackenwall
            [questKeys.nextQuestInChain] = 26682,
        },
        [26706] = { -- Endgame
            [questKeys.objectives] = {{{43729,"Gunship destroyed",Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get on a Hippogryph"), 0, {{"monster", 43747}}}},
        },
        [26708] = { -- AHHHHHHHHHHHH! AHHHHHHHHH!!!
            [questKeys.preQuestSingle] = {26694},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 43714}}}},
        },
        [26710] = { -- Lost In The Deeps
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Pebble brought to safety",{[zoneIDs.DEEPHOLM]={{58.4,25.6}}}},
            [questKeys.exclusiveTo] = {27048,28488},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Pebble"), 0, {{"monster", 49956}}}},
        },
        [26711] = { -- Off to the Bank (female)
            [questKeys.exclusiveTo] = {26712},
            [questKeys.sourceItemId] = 46856,
        },
        [26712] = { -- Off to the Bank (male)
            [questKeys.exclusiveTo] = {26711},
            [questKeys.sourceItemId] = 46856,
        },
        [26714] = { -- Darkblaze, Brood of the Worldbreaker
            [questKeys.startedBy] = {{43733}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Summon Darkblaze"), 0, {{"monster", 43863}}}},
        },
        [26720] = { -- A Curse We Cannot Lift
            [questKeys.objectives] = {{{43814,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26723] = { -- The Fate of Morbent Fel
            [questKeys.preQuestSingle] = {26720},
        },
        [26728] = { -- Hero's Call: Duskwood!
            [questKeys.nextQuestInChain] = 26618,
        },
        [26734] = { -- The Source of the Madness
            [questKeys.preQuestSingle] = {26733},
        },
        [26735] = { -- The Fate of Kurzen
            [questKeys.preQuestSingle] = {},
        },
        [26738] = { -- Just Hatched
            [questKeys.preQuestSingle] = {26732},
        },
        [26742] = { -- Bloodscalp Insight
            [questKeys.preQuestSingle] = {26736},
        },
        [26744] = { -- Deep Roots
            [questKeys.preQuestSingle] = {26739},
        },
        [26750] = { -- At the Stonemother's Call
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26584,26585,26659},
        },
        [26752] = { -- Audience with the Stonemother
            [questKeys.objectives] = {{{42465,nil,Questie.ICON_TYPE_TALK}}},
        },
        [26755] = { -- Keep Them off the Front
            [questKeys.objectives] = {nil,nil,nil,nil,{{{43954,43960},43954,"Reinforcements bombarded",Questie.ICON_TYPE_SLAY}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Take control of a catapult"), 0, {{"monster",43952}}}},
        },
        [26760] = { -- Cry For The Moon
            [questKeys.objectives] = {{{43950,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26762] = { -- Reactivate the Constructs
            [questKeys.objectives] = {{{43984,"Deactivated War Constructs reactivated",Questie.ICON_TYPE_INTERACT}}},
        },
        [26766] = { -- Big Game, Big Bait
            [questKeys.preQuestSingle] = {27061},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Mylra's Knife on dead Jadecrest Basilisks"), 0, {{"monster",43981}}}},
        },
        [26768] = { -- To Catch a Dragon
            [questKeys.preQuestSingle] = {27061},
        },
        [26770] = { -- Mystic Masters
            [questKeys.preQuestSingle] = {26755},
        },
        [26771] = { -- Testing the Trap
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26766,26768},
            [questKeys.extraObjectives] = {{{[zoneIDs.DEEPHOLM]={{50.9,85.3}}}, Questie.ICON_TYPE_EVENT, l10n("Place Trapped Basilisk Meat to spawn Stonescale Matriarch")}},
        },
        [26777] = { -- Soothing Spirits
            [questKeys.objectives] = {{{43923,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26778] = { -- The Cries of the Dead
            [questKeys.preQuestSingle] = {26760},
        },
        [26782] = { -- The Mosh'Ogg Bounty
            [questKeys.exclusiveTo] = {26783},
        },
        [26783] = { -- The Mosh'Ogg Bounty
            [questKeys.exclusiveTo] = {26782},
        },
        [26785] = { -- Part of the Pack
            [questKeys.preQuestSingle] = {26674},
            [questKeys.nextQuestInChain] = 26717,
        },
        [26788] = { -- Cementing Our Victory
            [questKeys.preQuestSingle] = {26622},
        },
        [26791] = { -- Sprout No More
            [questKeys.objectives] = {{{44126,nil,Questie.ICON_TYPE_INTERACT},{44049}},nil,nil,nil,},
            [questKeys.preQuestSingle] = {26834},
        },
        [26792] = { -- Fungal Monstrosities
            [questKeys.objectives] = {{{44126,nil,Questie.ICON_TYPE_INTERACT},{44035}},nil,nil,nil,},
            [questKeys.preQuestSingle] = {26834},
        },
        [26798] = { -- The Warchief Will Be Pleased
            [questKeys.finishedBy] = {{39605}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26784,26788},
        },
        [26800] = { -- Recruitment
            [questKeys.objectives] = {{{49340,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.startedBy] = {{1740}},
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [26801] = { -- Scourge on our Perimeter
            [questKeys.preQuestSingle] = {},
        },
        [26803] = { -- Missing Reports
            [questKeys.preQuestSingle] = {},
        },
        [26809] = { -- Backdoor Dealings
            [questKeys.objectives] = {{{43245}},{{204361}}},
        },
        [26812] = { -- High Priestess Jeklik
            [questKeys.preQuestSingle] = {26811},
        },
        [26815] = { -- Zanzil's Secret
            [questKeys.preQuestSingle] = {26817},
        },
        [26816] = { -- Recipe for Disaster
            [questKeys.preQuestSingle] = {26815},
        },
        [26818] = { -- Plush Pelts
            [questKeys.preQuestSingle] = {26823},
        },
        [26819] = { -- Akiris by the Bundle
            [questKeys.preQuestSingle] = {26823},
        },
        [26820] = { -- If They're Just Going to Leave Them Lying Around...
            [questKeys.preQuestSingle] = {26823},
        },
        [26824] = { -- Results: Inconclusive
            [questKeys.preQuestSingle] = {26815},
        },
        [26827] = { -- Rallying the Earthen Ring
            [questKeys.objectives] = {nil,nil,nil,nil,{{{43836,44631,44633,44634,44642,44644,44646,44647,45034},44642,"Earthen Ring rallied",Questie.ICON_TYPE_TALK}}},
        },
        [26829] = { -- The Stone March
            [questKeys.preQuestSingle] = {26828},
            [questKeys.exclusiveTo] = {},
        },
        [26830] = { -- Traitor's Bait
            [questKeys.startedBy] = {{39605}},
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{44160,nil,Questie.ICON_TYPE_TALK},{44120}}},
        },
        [26831] = { -- The Twilight Flight
            [questKeys.finishedBy] = {{44080}},
            [questKeys.preQuestSingle] = {26828},
        },
        [26832] = { -- Therazane's Mercy
            [questKeys.preQuestSingle] = {26828},
            [questKeys.exclusiveTo] = {},
        },
        [26833] = { -- Word In Stone
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26829,26831,26832},
        },
        [26834] = { -- Down Into the Chasm
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26762,26770},
        },
        [26835] = { -- A Slight Problem
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26791,26792},
        },
        [26838] = { -- Rebels Without a Clue
            [questKeys.nextQuestInChain] = 26735,
        },
        [26840] = { -- Return to the Highlands
            [questKeys.startedBy] = {{39605}},
        },
        [26841] = { -- Forbidden Sigil -- Night Elf Mage
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [26842] = { -- Out of Gnoll-where
            [questKeys.preQuestSingle] = {},
        },
        [26843] = { -- A Tiny, Clever Commander
            [questKeys.preQuestSingle] = {},
        },
        [26845] = { -- Who's In Charge Here?
            [questKeys.preQuestSingle] = {26844},
        },
        [26846] = { -- A Nasty Exploit
            [questKeys.preQuestSingle] = {26844},
        },
        [26854] = { -- The Lost Pilot
            [questKeys.preQuestSingle] = {},
        },
        [26858] = { -- Taragaman the Hungerer
            [questKeys.preQuestSingle] = {},
        },
        [26861] = { -- Block the Gates
            [questKeys.preQuestSingle] = {26771},
            [questKeys.objectives] = {{{44930,nil,Questie.ICON_TYPE_EVENT},{44931,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26863] = { -- Filthy Paws
            [questKeys.preQuestSingle] = {26844},
        },
        [26865] = { -- Enemies Below
            [questKeys.nextQuestInChain] = 26858,
        },
        [26866] = { -- Enemies Below
            [questKeys.nextQuestInChain] = 26858,
        },
        [26867] = { -- Enemies Below
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.nextQuestInChain] = 26858,
        },
        [26868] = { -- Axis of Awful
            [questKeys.requiredSourceItems] = {60502,60503},
            [questKeys.objectives] = {{{44262,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [26876] = { -- The World Pillar Fragment
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Summon Abyssion"), 0, {{"object", 205205}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Abyssion"), 0, {{"monster", 44289}}},
            },
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26857,26861},
        },
        [26881] = { -- In Search of Thaelrid
            [questKeys.finishedBy] = {{4787}},
        },
        [26882] = { -- Blackfathom Villainy
            [questKeys.questFlags] = 128,
        },
        [26886] = { -- Going Off-Task [Alliance]
            [questKeys.exclusiveTo] = {},
        },
        [26892] = { -- Deep in the Deeps
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26893] = { -- Blackfathom Deeps
            [questKeys.finishedBy] = {{12736}},
            [questKeys.exclusiveTo] = {26894},
        },
        [26894] = { -- Blackfathom Deeps
            [questKeys.finishedBy] = {{12736}},
            [questKeys.exclusiveTo] = {26893},
        },
        [26895] = { -- The Thunderdrome!
            [questKeys.nextQuestInChain] = 25067,
        },
        [26896] = { -- The Thunderdrome!
            [questKeys.nextQuestInChain] = 25067,
        },
        [26897] = { -- Blackfathom Deeps
            [questKeys.exclusiveTo] = {26898},
            [questKeys.finishedBy] = {{33260}},
        },
        [26898] = { -- Blackfathom Deeps
            [questKeys.exclusiveTo] = {26897},
            [questKeys.finishedBy] = {{33260}},
        },
        [26903] = { -- Willix the Importer
            [questKeys.triggerEnd] = {"Help Willix the Importer escape from Razorfen Kraul", {[zoneIDs.RAZORFEN_KRAUL]={{-1,-1}}}},
        },
        [26904] = { -- Harnessing the Flames
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{348}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 43455}}}},
            [questKeys.requiredRaces] = raceKeys.DWARF,
        },
        [26907] = { -- Take Them Down!
            [questKeys.objectives] = {{{4424},{4428},{4420},{4422}}},
        },
        [26910] = { -- Etched Letter
            [questKeys.requiredClasses] = classKeys.HUNTER,
            [questKeys.nextQuestInChain] = 26917,
        },
        [26911] = { -- Myzrael's Tale [Horde]
            [questKeys.preQuestSingle] = {26042},
        },
        [26913] = { -- Charging into Battle -- Human Warrior
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{100}}},
            [questKeys.nextQuestInChain] = 28789,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 911}}}},
        },
        [26914] = { -- Immolation -- Human Warlock
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{348}}},
            [questKeys.nextQuestInChain] = 28788,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Immolate"), 2, {{"monster", 459}}}},
        },
        [26915] = { -- The Deepest Cut -- Human Rogue
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{2098}}},
            [questKeys.nextQuestInChain] = 28787,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 915}}}},
        },
        [26916] = { -- Mastering the Arcane -- Human Mage
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{5143}}},
            [questKeys.nextQuestInChain] = 28784,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 198}}}},
        },
        [26917] = { -- The Hunter's Path -- Human Hunter
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{56641}}},
            [questKeys.nextQuestInChain] = 28780,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 43278}}}},
        },
        [26918] = { -- The Power of the Light -- Human Paladin
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{20271},{20154}}},
            [questKeys.nextQuestInChain] = 28785,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Judgement"), 2, {{"monster", 925}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Seal of Righteousness"), 3, {{"monster", 925}}},
            },
        },
        [26919] = { -- Healing the Wounded -- Human Priest
            [questKeys.objectives] = {{{44564,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.nextQuestInChain] = 28786,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 375}}}},
        },
        [26929] = { -- A Load of Croc
            [questKeys.preQuestSingle] = {26927},
        },
        [26930] = { -- After the Crusade
            [questKeys.triggerEnd] = {"Scarlet Crusade camp scouted", {[zoneIDs.WESTERN_PLAGUELANDS]={{40.6,52.6}}}},
        },
        [26932] = { -- Buzz Off
            [questKeys.preQuestSingle] = {26927},
        },
        [26940] = { -- Arcane Missiles
            [questKeys.startedBy] = {{43006}},
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 43006}}}},
        },
        [26945] = { -- Learning New Techniques
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 3593}}}},
        },
        [26946] = { -- A Rogue's Advantage
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{2098}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Eviscerate"), 2, {{"monster", 3594}}}},
        },
        [26947] = { -- A Woodsman's Training
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 3596}}}},
        },
        [26948] = { -- Rejuvenating Touch
            [questKeys.objectives] = {{{44617,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{774}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Rejuvenation"), 2, {{"monster", 3597}}}},
        },
        [26949] = { -- Healing for the Wounded
            [questKeys.objectives] = {{{44617,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 3595}}}},
        },
        [26950] = { -- The Dark Side of the Light
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26958] = { -- Your First Lesson
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 16503}}}},
            [questKeys.preQuestSingle] = {},
        },
        [26959] = { -- Stripping Their Defenses
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26960] = { -- My Son, the Prince
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{1747,nil,Questie.ICON_TYPE_TALK}}},
        },
        [26961] = { -- Gathering Idols
            [questKeys.exclusiveTo] = {297},
        },
        [26962] = { -- Stripping Their Offense
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26963] = { -- Steadying Your Shot
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 16499}}}},
            [questKeys.preQuestSingle] = {},
        },
        [26964] = { -- Warchief's Command: Silverpine Forest!
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {26965,28568},
        },
        [26965] = { -- The Warchief Cometh
            [questKeys.preQuestSingle] = {},
        },
        [26966] = { -- The Light's Power
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{20271},{20154}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Judgement"), 2, {{"monster", 16501}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Seal of Righteousness"), 3, {{"monster", 16501}}},
            },
            [questKeys.preQuestSingle] = {},
        },
        [26967] = { -- Battle for the Scarlet Monastery
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [26968] = { -- Arcane Missiles
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{5143}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Arcane Missiles"), 2, {{"monster", 16500}}}},
            [questKeys.preQuestSingle] = {},
        },
        [26969] = { -- Primal Strike
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{73899}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Primal Strike"), 2, {{"monster", 17089}}}},
            [questKeys.preQuestSingle] = {},
        },
        [26970] = { -- Aiding the Injured
            [questKeys.objectives] = {{{16971,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 16502}}}},
            [questKeys.preQuestSingle] = {},
        },
        [26971] = { -- The Binding
            [questKeys.startedBy] = {{43835}},
        },
        [26972] = { -- The Dark Side of the Light
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26973] = { -- The Only True Path
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26974] = { -- The False Champion
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26975] = { -- Rallying the Fleet
            [questKeys.triggerEnd] = {"Prince Anduin Escorted to Graves", {[zoneIDs.STORMWIND_CITY]={{33.5,40.9}}}},
            [questKeys.preQuestSingle] = {26960},
        },
        [26976] = { -- Battle for the Scarlet Monastery
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26977] = { -- Twilight Investigation
            [questKeys.preQuestSingle] = {26960},
        },
        [26980] = { -- Swiftgear Station
            [questKeys.nextQuestInChain] = 25864,
            [questKeys.preQuestGroup] = {25805,25819,25820},
        },
        [26981] = { -- Whelgar's Retreat
            [questKeys.nextQuestInChain] = 25849,
            [questKeys.preQuestSingle] = {25868},
        },
        [26989] = { -- The Gilneas Liberation Front
            [questKeys.preQuestSingle] = {26965},
        },
        [26992] = { -- Agony Abounds
            [questKeys.preQuestSingle] = {26965},
        },
        [26995] = { -- Guts and Gore
            [questKeys.preQuestSingle] = {26965},
        },
        [26997] = { -- The Usual Suspects
            [questKeys.objectives] = {{{29152,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27003] = { -- Easy Money
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{46517,nil, Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [27004] = { -- The Twilight Plot
            [questKeys.preQuestSingle] = {},
        },
        [27005] = { -- The Twilight Plot
            [questKeys.preQuestSingle] = {},
        },
        [27006] = { -- Fly Over
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Master's Gate investigated", {[zoneIDs.DEEPHOLM]={{38.79,74.4}}}},
        },
        [27007] = { -- Silvermarsh Rendezvous
            [questKeys.triggerEnd] = {"Upper Silvermarsh reached", {[zoneIDs.DEEPHOLM]={{72.3,62.3}}}},
        },
        [27008] = { -- Fly Over
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Master's Gate investigated", {[zoneIDs.DEEPHOLM]={{38.79,74.4}}}},
        },
        [27009] = { -- The Coldbringer
            [questKeys.preQuestSingle] = {},
        },
        [27010] = { -- Quicksilver Submersion
            [questKeys.requiredSourceItems] = {60809},
            [questKeys.objectives] = {{{44938,nil, Questie.ICON_TYPE_EVENT}}},
        },
        [27014] = { -- Hallowed Note -- Tauren Priest
            [questKeys.preQuestSingle] = {},
        },
        [27015] = { -- Consecrated Note -- Tauren Paladin
            [questKeys.preQuestSingle] = {},
        },
        [27020] = { -- The First Lesson
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 3059}}}},
        },
        [27021] = { -- The Hunter's Path
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{56641}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Steady Shot"), 2, {{"monster", 3061}}}},
        },
        [27022] = { -- Extinguishing the Idol
            [questKeys.triggerEnd] = {"Protect Belnistrasz while he performs the ritual to shut down the idol", {[zoneIDs.RAZORFEN_DOWNS]={{-1,-1}}}},
        },
        [27023] = { -- The Way of the Sunwalkers
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{20271},{20154}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Judgement"), 2, {{"monster", 37737}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Seal of Righteousness"), 3, {{"monster", 37737}}},
            },
        },
        [27027] = { -- Primal Strike
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{73899}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Primal Strike"), 2, {{"monster", 3062}}}},
        },
        [27036] = { -- Vyrin's Revenge
            [questKeys.preQuestSingle] = {27016},
        },
        [27039] = { -- Dangerous Intentions
            [questKeys.preQuestSingle] = {26998},
        },
        [27040] = { -- Decryption Made Easy
            [questKeys.finishedBy] = {{100008}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27004,27006},
        },
        [27041] = { -- Decryption Made Easy
            [questKeys.finishedBy] = {{100008}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27005,27008},
        },
        [27042] = { -- Fight Fire and Water and Air with...
            [questKeys.objectives] = {{{44887},{44886},{44885},{44835}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27004,27006},
        },
        [27043] = { -- Fight Fire and Water and Air with...
            [questKeys.objectives] = {{{44887},{44886},{44885},{44835}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27005,27008},
        },
        [27044] = { -- Peasant Problems
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.triggerEnd] = {"Anduin Escorted to Farmer Wollerton", {[zoneIDs.STORMWIND_CITY]={{52.1,6.5}}}},
            [questKeys.preQuestSingle] = {26975},
            [questKeys.exclusiveTo] = {},
        },
        [27045] = { -- Waiting to Exsanguinate
            [questKeys.objectives] = {nil,{{44894,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27048] = { -- Underground Economy
            [questKeys.exclusiveTo] = {26710,28488},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.DEEPHOLM]={{63.4,22.6}}}, Questie.ICON_TYPE_EVENT, l10n("Place Ricket's Tickers next to the white rocks"), 1},
                {{[zoneIDs.DEEPHOLM]={{61.8,19.3}}}, Questie.ICON_TYPE_EVENT, l10n("Place Ricket's Tickers next to the blue rocks"), 2},
                {{[zoneIDs.DEEPHOLM]={{64.5,18.7}}}, Questie.ICON_TYPE_EVENT, l10n("Place Ricket's Tickers next to the purple rocks"), 3},
                {{[zoneIDs.DEEPHOLM]={{66.5,20.6}}}, Questie.ICON_TYPE_EVENT, l10n("Place Ricket's Tickers next to the red rocks"), 4},
            },
        },
        [27050] = { -- Fungal Fury
            [questKeys.objectives] = {nil,{{205146},{205147},{205151},{205152}}},
        },
        [27051] = { -- Through Persistence
            [questKeys.requiredSourceItems] = {60768},
        },
        [27059] = { -- The Wrong Sequence
            [questKeys.preQuestSingle] = {27041},
        },
        [27060] = { -- Unholy Cow
            [questKeys.exclusiveTo] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Follow the trail of gore"), 0, {{"object", 205162},{"object", 205163}}}},
            [questKeys.objectives] = {nil,{{205164}},nil,nil,{{{44910},44910,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27061] = { -- The Twilight Overlook
            [questKeys.exclusiveTo] = {26766,26768,28866},
        },
        [27062] = { -- Looming Threat
            [questKeys.exclusiveTo] = {27009},
            [questKeys.finishedBy] = {{44837}},
        },
        [27063] = { -- Looming Threat
            [questKeys.exclusiveTo] = {27009},
            [questKeys.finishedBy] = {{44837}},
        },
        [27064] = { -- He's Holding Out on Us
            [questKeys.triggerEnd] = {"Samuelson's Papers Examined by Anduin", {[zoneIDs.STORMWIND_CITY]={{80.2,62.3}}}},
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27038,26997},
            [questKeys.objectives] = {nil,{{205190,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27066] = { -- Healing in a Flash
            [questKeys.objectives] = {{{45199,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{2061}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Flash Heal"), 2, {{"monster", 37724}}}},
        },
        [27067] = { -- Rejuvenating Touch
            [questKeys.objectives] = {{{45199,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,nil,{{774}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Rejuvenation"), 2, {{"monster", 3060}}}},
        },
        [27068] = { -- Chief Ukorz Sandscalp
            [questKeys.preQuestSingle] = {},
        },
        [27073] = { -- Give 'em Hell!
            [questKeys.preQuestSingle] = {27065},
        },
        [27075] = { -- Servants of Cho'gall
            [questKeys.preQuestSingle] = {27074},
            [questKeys.exclusiveTo] = {},
        },
        [27077] = { -- Clutching at Chaos
            [questKeys.preQuestSingle] = {27074},
            [questKeys.exclusiveTo] = {},
        },
        [27078] = { -- Gor'kresh
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27075,27077},
        },
        [27082] = { -- Playing Dirty
            [questKeys.preQuestSingle] = {27065},
        },
        [27091] = { -- Charge!
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 43010}}}},
            [questKeys.zoneOrSort] = 6455,
        },
        [27093] = { -- Lost in the Darkness
            [questKeys.objectives] = {{{44941}}},
        },
        [27095] = { -- Skitterweb Menace
            [questKeys.preQuestSingle] = {27073},
        },
        [27097] = { -- Rise, Forsaken
            [questKeys.preQuestSingle] = {27096},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{44954,44966},44954},},}
        },
        [27099] = { -- No Escape
            [questKeys.objectives] = {{{44951,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [27100] = { -- Twilight Research
            [questKeys.startedBy] = {{43158,44936,44988},nil,{60816}},
            [questKeys.preQuestSingle] = {27007},
        },
        [27106] = { -- A Villain Unmasked
            [questKeys.objectives] = {{{2439,nil,Questie.ICON_TYPE_TALK},{2439}}},
        },
        [27111] = { -- The Treasure of the Shen'dralar
            [questKeys.preQuestSingle] = {27110},
        },
        [27118] = { -- A Broken Trap
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27120] = { -- The Gordok Ogre Suit
            [questKeys.preQuestSingle] = {27119},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27123] = { -- Deepholm, Realm of Earth
            [questKeys.exclusiveTo] = {26244,26245,26246},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 45005}}}},
        },
        [27126] = { -- Rush Delivery
            [questKeys.preQuestSingle] = {26625},
        },
        [27135] = { -- Something that Burns
            [questKeys.preQuestSingle] = {26409},
            [questKeys.exclusiveTo] = {},
        },
        [27136] = { -- Elemental Energy
            [questKeys.objectives] = {nil,nil,nil,nil,{{{43254,43258},43254,"Totem energized"}}},
        },
        [27139] = { -- Hobart Needs You
            [questKeys.exclusiveTo] = {24671},
        },
        [27141] = { -- Exploding Through
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27923,27924,28105},
            [questKeys.name] = "Exploding Through",
            [questKeys.objectives] = {nil,{{205241}}},
        },
        [27152] = { -- Unusual Behavior... Even For Gnolls
            [questKeys.triggerEnd] = {"Gnoll camp investigated", {[zoneIDs.WESTERN_PLAGUELANDS]={{57.5,35.6}}}},
        },
        [27176] = { -- A Strange Disc
            [questKeys.requiredSourceItems] = {60865},
            [questKeys.name] = "A Strange Disc",
            [questKeys.exclusiveTo] = {},
        },
        [27177] = { -- Salvage Operation
            [questKeys.preQuestSingle] = {28599},
        },
        [27178] = { -- Naga Reinforcements
            [questKeys.preQuestSingle] = {28599},
        },
        [27179] = { -- Field Work
            [questKeys.exclusiveTo] = {},
        },
        [27180] = { -- Honor the Dead
            [questKeys.preQuestSingle] = {27098},
        },
        [27181] = { -- Excising the Taint
            [questKeys.preQuestSingle] = {27098},
        },
        [27186] = { -- Jarl Needs a Blade
            [questKeys.preQuestSingle] = {27184},
        },
        [27187] = { -- Do the World a Favor
            [questKeys.finishedBy] = {{100012}},
        },
        [27191] = { -- Hungry as an Ogre!
            [questKeys.preQuestSingle] = {27184},
        },
        [27195] = { -- Nowhere to Run
            [questKeys.preQuestSingle] = {27194},
            [questKeys.objectives] = {nil,{{205269,nil,Questie.ICON_TYPE_EVENT}}}, -- No bunny for this one, but the dynamite object is uniquely placed as a suitable location for the quest objective
        },
        [27196] = { -- On to Something
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27176,27179},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{45180,45238},45238,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27200] = { -- Siren's Song
            [questKeys.objectives] = {{{45183}}},
            [questKeys.preQuestSingle] = {28599},
        },
        [27203] = { -- The Maelstrom
            [questKeys.preQuestSingle] = {},
        },
        [27222] = { -- Take Down Tethyr!
            [questKeys.objectives] = {{{23899,"Defend Theramore Docks from Tethyr"}}},
        },
        [27225] = { -- A Summons from Ander Germaine
            [questKeys.nextQuestInChain] = 27337,
        },
        [27226] = { -- Hair of the Dog
            [questKeys.preQuestSingle] = {27098},
            [questKeys.objectives] = {{{45196,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [27231] = { -- Reinforcements from Fenris
            [questKeys.preQuestSingle] = {27098},
        },
        [27239] = {
            [questKeys.triggerEnd] = {"Survey Alcaz Island", {[zoneIDs.DUSTWALLOW_MARSH]={{69.96,19.55}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Cassa Crimsonwing to fly on a gryphon"), 0, {{"monster", 23704}}}},
        },
        [27240] = { -- Proof of Treachery
            [questKeys.finishedBy] = {{29611}},
        },
        [27258] = { -- The Black Shield
            [questKeys.preQuestGroup] = {27257,27259,27261},
        },
        [27261] = { -- Questioning Reethe
            [questKeys.triggerEnd] = {"Question Reethe with Ogron", {[zoneIDs.DUSTWALLOW_MARSH]={{42.47,38.07}}}},
        },
        [27265] = { -- Lord Grayson Shadowbreaker
            [questKeys.nextQuestInChain] = 27343,
        },
        [27266] = { -- Wulf Calls
            [questKeys.nextQuestInChain] = 27344,
        },
        [27267] = { -- Make Contact with SI:7
            [questKeys.nextQuestInChain] = 27351,
        },
        [27268] = { -- Make Haste to the Cathedral
            [questKeys.nextQuestInChain] = 27361,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.NIGHT_ELF - raceKeys.GNOME,
        },
        [27269] = { -- The Temple of the Moon
            [questKeys.nextQuestInChain] = 27362,
            [questKeys.startedBy] = {{11401,11406,16756}},
        },
        [27270] = { -- An Audience with the Farseer
            [questKeys.nextQuestInChain] = 27353,
            [questKeys.startedBy] = {{17519,23127,52292}},
        },
        [27271] = { -- Journey to the Wizard's Sanctum
            [questKeys.nextQuestInChain] = 27354,
        },
        [27272] = { -- Demisette Sends Word
            [questKeys.nextQuestInChain] = 27355,
        },
        [27273] = { -- An Invitation from Moonglade
            [questKeys.nextQuestInChain] = 27356,
        },
        [27274] = { -- The Chief Surgeon
            [questKeys.nextQuestInChain] = 27363,
            [questKeys.startedBy] = {{11401,11406,16756}},
        },
        [27277] = { -- An Audience with Ureda
            [questKeys.nextQuestInChain] = 27400,
        },
        [27278] = { -- Grimshot's Call
            [questKeys.nextQuestInChain] = 27395,
        },
        [27279] = { -- The Shattered Hand
            [questKeys.nextQuestInChain] = 27396,
        },
        [27280] = { -- The Dreamseeker Calls
            [questKeys.finishedBy] = {{3344}},
            [questKeys.startedBy] = {{16661,51639}},
            [questKeys.nextQuestInChain] = 27397,
        },
        [27281] = { -- Grezz Ragefist
            [questKeys.nextQuestInChain] = 27365,
        },
        [27282] = { -- Zevrost's Behest
            [questKeys.finishedBy] = {{3326}},
            [questKeys.nextQuestInChain] = 27402,
        },
        [27283] = { -- A Journey to Moonglade
            [questKeys.nextQuestInChain] = 27404,
        },
        [27290] = { -- To Forsaken Forward Command
            [questKeys.preQuestSingle] = {27195}, -- Might also be The Waters Run Red... which turns in at the same time (27232)
        },
        [27293] = { -- The Grimtotem Plot
            [questKeys.preQuestSingle] = {27292},
            [questKeys.requiredSourceItems] = {33050},
        },
        [27294] = { -- More than Coincidence
            [questKeys.preQuestSingle] = {27292},
        },
        [27295] = { -- Seek Out Tabetha
            [questKeys.preQuestGroup] = {27293,27294},
        },
        [27298] = { -- Seek Out Master Pyreanor
            [questKeys.nextQuestInChain] = 27434,
        },
        [27299] = { -- Torn Ground
            [questKeys.preQuestSingle] = {},
        },
        [27301] = { -- Unbroken
            [questKeys.preQuestSingle] = {27299},
        },
        [27302] = { -- Simple Solutions
            [questKeys.preQuestSingle] = {27299},
        },
        [27304] = { -- Follow the Sun
            [questKeys.nextQuestInChain] = 27403,
            [questKeys.startedBy] = {{16681,20406,43795}},
        },
        [27306] = { -- Talk to Ogron
            [questKeys.preQuestSingle] = {27260},
        },
        [27310] = { -- No Weapons For You! [Alliance]
            [questKeys.preQuestSingle] = {27275},
        },
        [27311] = { -- No Weapons For You! [Horde]
            [questKeys.preQuestSingle] = {27276},
        },
        [27312] = { -- Darkcloud Grimtotem [Alliance]
            [questKeys.preQuestSingle] = {27275},
        },
        [27313] = { -- Darkcloud Grimtotem [Horde]
            [questKeys.preQuestSingle] = {27276},
        },
        [27315] = { -- Grimtotem Chiefs: Isha Gloomaxe
            [questKeys.preQuestSingle] = {27275},
        },
        [27316] = { -- The Rattle of Bones [Alliance]
            [questKeys.preQuestSingle] = {27275},
        },
        [27317] = { -- The Rattle of Bones [Horde]
            [questKeys.preQuestSingle] = {27276},
        },
        [27320] = { -- The Writ of History [Alliance]
            [questKeys.preQuestSingle] = {27316},
        },
        [27321] = { -- The Writ of History [Horde]
            [questKeys.preQuestSingle] = {27317},
        },
        [27325] = { -- The Drums of War [Alliance]
            [questKeys.preQuestSingle] = {27316},
        },
        [27326] = { -- The Drums of War [Horde]
            [questKeys.preQuestSingle] = {27317},
        },
        [27331] = { -- The Seer's Call
            [questKeys.nextQuestInChain] = 27435,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [27332] = { -- Seek the Shadow-Walker
            [questKeys.requiredRaces] = raceKeys.TROLL,
            [questKeys.nextQuestInChain] = 27436,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [27333] = { -- Losing Ground
            [questKeys.preQuestSingle] = {27290},
        },
        [27334] = { -- Dark Cleric Cecille
            [questKeys.nextQuestInChain] = 27437,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [27335] = { -- Journey to Orgrimmar
            [questKeys.nextQuestInChain] = 27439,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [27336] = { -- The Grimtotem Weapon
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4344,4345},4344,"Totem Tests Performed"}}},
        },
        [27337] = { -- A Fitting Weapon
            [questKeys.startedBy] = {{914}},
            [questKeys.preQuestSingle] = {},
        },
        [27341] = { -- Scouting the Shore
            [questKeys.triggerEnd] = {"Beach Head Control Point Scouted", {[zoneIDs.TWILIGHT_HIGHLANDS]={{77.5,65.2}}}},
            [questKeys.preQuestSingle] = {27338},
            [questKeys.exclusiveTo] = {},
        },
        [27343] = { -- The Hand of the Light
            [questKeys.preQuestSingle] = {},
        },
        [27344] = { -- A Well-Earned Reward
            [questKeys.startedBy] = {{44247}},
            [questKeys.preQuestSingle] = {},
        },
        [27345] = { -- The F.C.D.
            [questKeys.preQuestSingle] = {27290},
        },
        [27346] = { -- The Zeppelin Crash
            [questKeys.exclusiveTo] = {27348},
        },
        [27347] = { -- Corrosion Prevention
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4393,4394},4393,"Oozes Dissolved"}}},
        },
        [27349] = { -- Break in Communications: Dreadwatch Outpost
            [questKeys.triggerEnd] = {"Investigate Dreadwatch Outpost", {[zoneIDs.RUINS_OF_GILNEAS]={{53,32.6}}}},
        },
        [27351] = { -- A Royal Reward
            [questKeys.preQuestSingle] = {},
        },
        [27353] = { -- Blessings of the Elements
            [questKeys.preQuestSingle] = {},
        },
        [27354] = { -- Mastering the Arcane
            [questKeys.startedBy] = {{331}},
            [questKeys.preQuestSingle] = {},
        },
        [27355] = { -- A Boon for the Powerful
            [questKeys.preQuestSingle] = {},
        },
        [27356] = { -- The Circle's Future
            [questKeys.preQuestSingle] = {},
        },
        [27357] = { -- The Captive Bride [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27320,27325,27327},
        },
        [27358] = { -- The Captive Bride [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27321,27326,27328},
        },
        [27361] = { -- Favored of the Light
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.NIGHT_ELF - raceKeys.GNOME,
        },
        [27362] = { -- Favored of Elune
            [questKeys.preQuestSingle] = {},
        },
        [27363] = { -- A Budding Young Surgeon
            [questKeys.preQuestSingle] = {},
        },
        [27364] = { -- On Whose Orders?
            [questKeys.preQuestSingle] = {27350},
        },
        [27365] = { -- A Fitting Weapon
            [questKeys.preQuestSingle] = {},
        },
        [27366] = { -- Landgrab
            [questKeys.preQuestSingle] = {27338},
            [questKeys.exclusiveTo] = {},
        },
        [27369] = { -- Greasing the Wheel
            [questKeys.preQuestSingle] = {27368},
            [questKeys.exclusiveTo] = {},
        },
        [27372] = { -- A Gift For Fiona
            [questKeys.exclusiveTo] = {},
        },
        [27373] = { -- Onward, to Light's Hope Chapel
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27369,27372},
        },
        [27374] = { -- The Maw of Madness
            [questKeys.preQuestSingle] = {28655},
            [questKeys.startedBy] = {{49374}},
            [questKeys.nextQuestInChain] = 27299,
        },
        [27375] = { -- The Weeping Wound
            [questKeys.nextQuestInChain] = 27299,
        },
        [27376] = { -- The Maw of Iso'rath
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27300,27302,27303},
            [questKeys.objectives] = {{{45435,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [27377] = { -- Devoured
            [questKeys.objectives] = {{{48108,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27378] = { -- The Worldbreaker
            [questKeys.objectives] = {{{48051,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27379] = { -- The Terrors of Iso'rath
            [questKeys.objectives] = {{{48739,nil,Questie.ICON_TYPE_EVENT},{48790,nil,Questie.ICON_TYPE_EVENT},{48794,nil,Questie.ICON_TYPE_EVENT},{48796,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27381] = { -- Traveling Companions
            [questKeys.objectives] = {{{45451}}},
            [questKeys.preQuestSingle] = {27373},
        },
        [27382] = { -- Rough Roads
            [questKeys.preQuestSingle] = {27373},
        },
        [27384] = { -- Pamela's Doll
            [questKeys.preQuestSingle] = {27383},
            [questKeys.requiredSourceItems] = {12886,12887,12888},
        },
        [27387] = { -- Villains of Darrowshire
            [questKeys.preQuestSingle] = {27386},
        },
        [27388] = { -- Heroes of Darrowshire
            [questKeys.preQuestSingle] = {27386},
        },
        [27389] = { -- Marauders of Darrowshire
            [questKeys.preQuestSingle] = {27386},
        },
        [27392] = { -- I'm Not Supposed to Tell You This
            [questKeys.preQuestSingle] = {27383},
        },
        [27393] = { -- The Call of the Blade
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.nextQuestInChain] = 25583,
        },
        [27394] = { -- The Call of the Blade
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.preQuestSingle] = {25953},
            [questKeys.nextQuestInChain] = 25956,
        },
        [27395] = { -- A Marksman's Weapon
            [questKeys.preQuestSingle] = {},
        },
        [27396] = { -- Blade of the Shattered Hand
            [questKeys.preQuestSingle] = {},
        },
        [27397] = { -- Dreamseeker's Task
            [questKeys.preQuestSingle] = {},
        },
        [27398] = { -- The Battle Is Won, The War Goes On
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {25551},
            [questKeys.exclusiveTo] = {27443},
            [questKeys.nextQuestInChain] = 27203,
        },
        [27399] = { -- The Battle Is Won, The War Goes On
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.preQuestSingle] = {25551},
            [questKeys.exclusiveTo] = {27442},
            [questKeys.nextQuestInChain] = 27203,
        },
        [27400] = { -- Mastering the Arcane
            [questKeys.preQuestSingle] = {},
        },
        [27401] = { -- What Tomorrow Brings
            [questKeys.objectives] = {{nil,{205417,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27402] = { -- Token of Power
            [questKeys.preQuestSingle] = {},
        },
        [27403] = { -- A True Sunwalker
            [questKeys.preQuestSingle] = {},
        },
        [27404] = { -- The Circle's Future
            [questKeys.preQuestSingle] = {},
        },
        [27406] = { -- A Man Named Godfrey
            [questKeys.objectives] = {{{44369,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [27408] = { -- Banner of the Stonemaul
            [questKeys.preQuestSingle] = {27407},
        },
        [27409] = { -- The Essence of Enmity
            [questKeys.preQuestSingle] = {27407},
        },
        [27416] = { -- The Brood of Onyxia
            [questKeys.preQuestSingle] = {27414},
        },
        [27418] = { -- Challenge Overlord Mok'Morokk
            [questKeys.preQuestSingle] = {27415},
            [questKeys.objectives] = {{{4500}},nil,nil,nil,},
        },
        [27420] = { -- Postponing the Inevitable
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSourceItems] = {61037},
        },
        [27423] = { -- Resistance is Futile
            [questKeys.preQuestSingle] = {27405},
        },
        [27431] = { -- Tipping the Balance
            [questKeys.objectives] = {{{45296,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27549,28602}, -- thanks to exclusiveTo, 28602 is same as 27517
        },
        [27433] = { -- Shredderectomy
            [questKeys.preQuestSingle] = {27338},
        },
        [27434] = { -- The Adept's Path
            [questKeys.preQuestSingle] = {},
        },
        [27435] = { -- A Seer's Staff
            [questKeys.preQuestSingle] = {},
        },
        [27436] = { -- The Shadow-Walker's Task
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceKeys.TROLL,
        },
        [27437] = { -- The Dark Cleric's Bidding
            [questKeys.preQuestSingle] = {},
        },
        [27438] = { -- The Great Escape
            [questKeys.preQuestSingle] = {27406},
            [questKeys.triggerEnd] = {"Escape the Ruins of Gilneas",{[zoneIDs.SILVERPINE_FOREST]={{51.82,66.59}}}},
        },
        [27439] = { -- Staff of the Light
            [questKeys.preQuestSingle] = {},
        },
        [27441] = { -- A Seer's Staff
            [questKeys.preQuestSingle] = {},
        },
        [27442] = { -- The War Has Many Fronts
            [questKeys.preQuestSingle] = {26006},
            [questKeys.exclusiveTo] = {27203,27399},
        },
        [27443] = { -- The War Has Many Fronts
            [questKeys.exclusiveTo] = {27203,27398},
        },
        [27448] = { -- The Trek Continues
            [questKeys.preQuestSingle] = {27381},
        },
        [27451] = { -- To Kill With Purpose
            [questKeys.requiredSourceItems] = {15447},
        },
        [27453] = { -- Catalysm
            [questKeys.preQuestSingle] = {27451},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Betina's Flasks on living Blighted Surge or Plague Ravager"), 0, {{"monster", 8519},{"monster",8520}}}},
        },
        [27454] = { -- Just a Drop in the Bucket
            [questKeys.objectives] = {nil,{{205485,"Disturb Mereldar Plague Cauldron",Questie.ICON_TYPE_TALK}}},
        },
        [27461] = { -- To Take the Abbey
            [questKeys.preQuestSingle] = {27460},
        },
        [27462] = { -- To Take the Barracks
            [questKeys.preQuestSingle] = {27460},
        },
        [27467] = { -- Buried Blades
            [questKeys.preQuestSingle] = {27464},
        },
        [27468] = { -- Siege Tank Rescue
            [questKeys.objectives] = {{{45524},{45526}}},
        },
        [27472] = { -- Rise, Godfrey
            [questKeys.preQuestSingle] = {27438},
        },
        [27474] = { -- Breaking the Barrier
            [questKeys.preQuestSingle] = {27472},
        },
        [27475] = { -- Unyielding Servitors
            [questKeys.preQuestSingle] = {27472},
        },
        [27480] = { -- Ley Energies
            [questKeys.preQuestSingle] = {27476},
            [questKeys.objectives] = {nil,nil,{{61311}}},
        },
        [27483] = { -- Practical Vengeance
            [questKeys.preQuestSingle] = {27476},
        },
        [27485] = { -- Warm Welcome
            [questKeys.preQuestSingle] = {27380},
            [questKeys.objectives] = {{{45708,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27486] = { -- Warm Welcome
            [questKeys.objectives] = {{{45708,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27490] = { -- SI:7 Drop
            [questKeys.objectives] = {{{45904,nil,Questie.ICON_TYPE_TALK},{45877,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {28248},
        },
        [27491] = { -- Kor'kron Drop
            [questKeys.objectives] = {{{45947,nil,Questie.ICON_TYPE_TALK},{45877,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {28249},
        },
        [27494] = { -- Move the Mountain
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27490,27492,27496},
            [questKeys.finishedBy] = {{100016}},
        },
        [27495] = { -- Move the Mountain
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27491,27493,27497},
            [questKeys.finishedBy] = {{100016}},
        },
        [27496] = { -- Call in the Artillery
            [questKeys.preQuestSingle] = {28248},
            [questKeys.objectives] = {{{45865,nil,Questie.ICON_TYPE_EVENT},{45864,nil,Questie.ICON_TYPE_EVENT},{45863,nil,Questie.ICON_TYPE_EVENT},{45862,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27497] = { -- Call in the Artillery
            [questKeys.preQuestSingle] = {28249},
            [questKeys.objectives] = {{{45865,nil,Questie.ICON_TYPE_EVENT},{45864,nil,Questie.ICON_TYPE_EVENT},{45863,nil,Questie.ICON_TYPE_EVENT},{45862,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27498] = { -- Signal the Attack
            [questKeys.exclusiveTo] = {27588},
            [questKeys.triggerEnd] = {"Signal the Attack", {[zoneIDs.TWILIGHT_HIGHLANDS]={{42.33,68.8},{40.62,62.21}}}},
            [questKeys.objectives] = {},
            [questKeys.startedBy] = {{100017}},
            [questKeys.finishedBy] = {{100018}},
        },
        [27499] = { -- Signal the Attack
            [questKeys.exclusiveTo] = {27590},
            [questKeys.triggerEnd] = {"Signal the Attack", {[zoneIDs.TWILIGHT_HIGHLANDS]={{42.33,68.8},{40.62,62.21}}}},
            [questKeys.objectives] = {},
            [questKeys.startedBy] = {{100017}},
            [questKeys.finishedBy] = {{100018}},
            [questKeys.preQuestSingle] = {27495},
        },
        [27500] = { -- Four Heads are Better than None
            [questKeys.preQuestSingle] = {27498,27588},
            [questKeys.startedBy] = {{100019}},
            [questKeys.exclusiveTo] = {27608},
        },
        [27501] = { -- Four Heads are Better than None
            [questKeys.preQuestSingle] = {27499,27590},
            [questKeys.startedBy] = {{100019}},
            [questKeys.exclusiveTo] = {27609},
        },
        [27502] = { -- Up to the Citadel
            [questKeys.preQuestSingle] = {27500,27608},
            [questKeys.objectives] = {{{46076,nil,Questie.ICON_TYPE_TALK},{46121,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.finishedBy] = {{100020}},
        },
        [27503] = { -- Up to the Citadel
            [questKeys.preQuestSingle] = {27501,27609},
            [questKeys.objectives] = {{{46117,nil,Questie.ICON_TYPE_TALK},{46121,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.finishedBy] = {{100020}},
        },
        [27506] = { -- Life from Death
            [questKeys.preQuestSingle] = {27504},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{45746,45748,45788},45788,"Dragonkin corpse reclaimed",Questie.ICON_TYPE_EVENT}}},
        },
        [27509] = { -- Breach in the Defenses
            [questKeys.objectives] = {nil,{{205486,"Twilight Portal destroyed"}}},
        },
        [27510] = { -- A Wolf in Bear's Clothing
            [questKeys.preQuestSingle] = {27484},
        },
        [27511] = { -- The Thrill of Discovery
            [questKeys.objectives] = {{{45757,nil,Questie.ICON_TYPE_EVENT},{45760,nil,Questie.ICON_TYPE_EVENT},{45759,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27514] = { -- Bird Down! Bird Down!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27341,27366},
        },
        [27516] = { -- Wings Over Highbank
            [questKeys.objectives] = {{{45172,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27517] = { -- Be Prepared
            [questKeys.objectives] = {nil,nil,{{61321}}},
            [questKeys.preQuestSingle] = {27196},
            [questKeys.startedBy] = {{45765},{205540},{61322}},
        },
        [27519] = { -- Under the Choking Sands
            [questKeys.preQuestSingle] = {28135},
            [questKeys.objectives] = {{{45715,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [27538] = { -- The Perfect Poultice
            [questKeys.preQuestSingle] = {27516},
        },
        [27541] = { -- Lessons From the Past
            [questKeys.preQuestSingle] = {27196},
        },
        [27542] = { -- Taking the Battlefront
            [questKeys.preQuestSingle] = {27518},
        },
        [27544] = { -- Cenarion Tenacity
            [questKeys.preQuestSingle] = {27386},
        },
        [27545] = { -- The Way is Open
            [questKeys.preQuestSingle] = {27537},
        },
        [27547] = { -- Of No Consequence
            [questKeys.preQuestSingle] = {27542},
            [questKeys.objectives] = {{{45910,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27548] = { -- Lessons in Fear
            [questKeys.preQuestSingle] = {27542},
        },
        [27549] = { -- By the Light of the Stars
            [questKeys.startedBy] = {{45296,45874}},
        },
        [27550] = { -- Pyrewood's Fall
            [questKeys.preQuestSingle] = {27542},
            [questKeys.objectives] = {{{45937,nil,Questie.ICON_TYPE_INTERACT},{45938,nil,Questie.ICON_TYPE_INTERACT},{45939,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [27555] = { -- Fiona's Lucky Charm
            [questKeys.preQuestGroup] = {27372,27369},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27556] = { -- Gidwin's Weapon Oil
            [questKeys.preQuestGroup] = {27372,27369},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27557] = { -- Tarenar's Talisman
            [questKeys.preQuestGroup] = {27372,27369},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27558] = { -- Pamela's Doll
            [questKeys.preQuestSingle] = {27391},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27559] = { -- Vex'tul's Armbands
            [questKeys.preQuestSingle] = {27449},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27560] = { -- Argus' Journal
            [questKeys.preQuestSingle] = {27381},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27561] = { -- Rimblat's Stone
            [questKeys.preQuestSingle] = {27457},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27562] = { -- Beezil's Cog
            [questKeys.preQuestSingle] = {27373},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27564] = { -- In Defense of the Redoubt
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27505,27506},
        },
        [27574] = { -- I Never Forget a Face
            [questKeys.preQuestSingle] = {27542},
            [questKeys.exclusiveTo] = {27594}, -- Not breadcrumb, but unavailable after this point in the main zone quest chain
            [questKeys.objectives] = {nil,nil,{{61505}}},
        },
        [27576] = { -- Patchwork Command
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27507,27508,27509},
        },
        [27583] = { -- The Northern Flank
            [questKeys.preQuestSingle] = {26840},
        },
        [27586] = { -- Shells on the Sea Shore
            [questKeys.preQuestSingle] = {27583},
        },
        [27588] = { -- Signal the Attack
            [questKeys.triggerEnd] = {"Signal the Attack", {[zoneIDs.TWILIGHT_HIGHLANDS]={{42.33,68.8},{40.62,62.21}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {27494},
            [questKeys.exclusiveTo] = {27498},
            [questKeys.finishedBy] = {{100018}},
        },
        [27590] = { -- Signal the Attack
            [questKeys.triggerEnd] = {"Signal the Attack", {[zoneIDs.TWILIGHT_HIGHLANDS]={{42.33,68.8},{40.62,62.21}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {27495},
            [questKeys.exclusiveTo] = {27499},
            [questKeys.finishedBy] = {{100018}},
        },
        [27594] = { -- On Her Majesty's Secret Service
            [questKeys.objectives] = {{{45997}}},
        },
        [27595] = { -- The Prophet Hadassi
            [questKeys.preQuestSingle] = {28135},
        },
        [27601] = { -- Cities in Dust
            [questKeys.preQuestSingle] = {27594},
            [questKeys.triggerEnd] = {"Victory: Final and Absolute", {[zoneIDs.SILVERPINE_FOREST]={{45.32,84.45}}}},
        },
        [27604] = { -- Jammal'an the Prophet
            [questKeys.zoneOrSort] = zoneIDs.SUNKEN_TEMPLE,
        },
        [27605] = { -- Eranikus
            [questKeys.zoneOrSort] = zoneIDs.SUNKEN_TEMPLE,
        },
        [27606] = { -- Blast Him!
            [questKeys.preQuestGroup] = {27584,27586},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Heth'Jatari Conch"), 0, {{"object", 205831}}}},
        },
        [27608] = { -- Four Heads are Better than None
            [questKeys.preQuestSingle] = {27498,27588},
            [questKeys.exclusiveTo] = {27500},
        },
        [27609] = { -- Four Heads are Better than None
            [questKeys.preQuestSingle] = {27499,27590},
            [questKeys.exclusiveTo] = {27501},
        },
        [27610] = { -- Scouting the Shore
            [questKeys.triggerEnd] = {"Beach Head Control Point Scouted", {[zoneIDs.TWILIGHT_HIGHLANDS]={{77.5,65.2}}}},
        },
        [27612] = { -- Victory From Within
            [questKeys.objectives] = {nil,{{205876},{205877}}},
            [questKeys.preQuestSingle] = {27461},
        },
        [27613] = { -- The Assassin
            [questKeys.preQuestSingle] = {27461},
        },
        [27614] = { -- Scarlet Salvage
            [questKeys.preQuestSingle] = {27462},
        },
        [27615] = { -- The Wrathcaster
            [questKeys.preQuestSingle] = {27462},
        },
        [27616] = { -- The Huntsman
            [questKeys.preQuestSingle] = {27462},
        },
        [27619] = { -- The Commander
            [questKeys.preQuestSingle] = {27462},
        },
        [27621] = { -- Firebeard's Patrol
            [questKeys.preQuestSingle] = {27545},
        },
        [27622] = { -- Mo' Better Shredder
            [questKeys.objectives] = {{{46100,nil,Questie.ICON_TYPE_INTERACT},{46100,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {27611},
        },
        [27627] = { -- Just a Fancy Cockroach
            [questKeys.startedBy] = {{46126,46127,46128,46129}},
            [questKeys.finishedBy] = {{100012}},
            [questKeys.preQuestSingle] = {27431},
        },
        [27629] = { -- The Vizier's Vote
            [questKeys.preQuestSingle] = {27628},
        },
        [27631] = { -- The High Commander's Vote
            [questKeys.preQuestSingle] = {27628},
        },
        [27633] = { -- The Blood God Hakkar
            [questKeys.zoneOrSort] = zoneIDs.SUNKEN_TEMPLE,
        },
        [27635] = { -- Decontamination
            [questKeys.objectives] = {{{46185,nil,Questie.ICON_TYPE_MOUNT_UP}}},
            [questKeys.zoneOrSort] = zoneIDs.DUN_MOROGH,
        },
        [27636] = { -- Just You and Mathias
            [questKeys.startedBy] = {{100021}},
            [questKeys.exclusiveTo] = {27637},
            [questKeys.preQuestSingle] = {27502},
        },
        [27637] = { -- Just You and Mathias
            [questKeys.startedBy] = {{45669}},
            [questKeys.exclusiveTo] = {27636},
            [questKeys.preQuestSingle] = {27502},
        },
        [27638] = { -- Just You and Garona
            [questKeys.startedBy] = {{100021}},
            [questKeys.exclusiveTo] = {27639},
        },
        [27639] = { -- Just You and Garona
            [questKeys.startedBy] = {{45665}},
            [questKeys.exclusiveTo] = {27638},
            [questKeys.preQuestSingle] = {27503},
        },
        [27640] = { -- Dunwalds Don't Die
            [questKeys.preQuestSingle] = {27817},
        },
        [27641] = { -- While Meeting The Family
            [questKeys.preQuestSingle] = {27640},
            [questKeys.finishedBy] = {{46143}},
        },
        [27642] = { -- Sifting Through The Wreckage
            [questKeys.preQuestSingle] = {27640},
            [questKeys.startedBy] = {{46143}},
            [questKeys.finishedBy] = {{46143}},
            [questKeys.objectives] = {{{46609,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [27643] = { -- Donnelly Dunwald
            [questKeys.preQuestSingle] = {27640},
        },
        [27644] = { -- Eoin Dunwald
            [questKeys.preQuestSingle] = {27640},
        },
        [27645] = { -- Cayden Dunwald
            [questKeys.preQuestSingle] = {27640},
        },
        [27646] = { -- Finding Beak
            [questKeys.exclusiveTo] = {},
            [questKeys.objectives] = {{{46599,nil,Questie.ICON_TYPE_EVENT},{46600,nil,Questie.ICON_TYPE_EVENT},{46601,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27648] = { -- Once More Into The Fire
            [questKeys.objectives] = {{{46174,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {},
        },
        [27649] = { -- A Steady Supply
            [questKeys.finishedBy] = {{46585}},
        },
        [27650] = { -- Home Again
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27646,27648,27649},
            [questKeys.startedBy] = {{46174,46176,46583}},
        },
        [27651] = { -- Doing It Like a Dunwald
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 46628}}}},
        },
        [27652] = { -- Dark Assassins
            [questKeys.preQuestSingle] = {27636,27637},
        },
        [27653] = { -- Dark Assassins
            [questKeys.preQuestSingle] = {27638,27639},
        },
        [27654] = { -- Bring the Hammer Down
            [questKeys.preQuestSingle] = {27636,27637},
        },
        [27655] = { -- Bring the Hammer Down
            [questKeys.preQuestSingle] = {27638,27639},
        },
        [27657] = { -- Help from the Earthcaller
            [questKeys.preQuestSingle] = {27636,27637},
        },
        [27658] = { -- Help from the Earthcaller
            [questKeys.preQuestSingle] = {27638,27639},
        },
        [27659] = { -- Portal Overload
            [questKeys.preQuestSingle] = {27657,27658},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Debilitate Apexar!"), 1, {{"object", 206018}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Debilitate Aetharon!"), 2, {{"object", 206019}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Debilitate Edemantus!"), 3, {{"object", 206017}}},
            },
            [questKeys.objectives] = {nil,nil,nil,nil,{{{46258,46273},46258},{{46259,46270},46259},{{46256,46272},46256}}},
        },
        [27660] = { -- Spirit of the Loch
            [questKeys.preQuestSingle] = {27657,27658},
        },
        [27662] = { -- Unbinding
            [questKeys.preQuestSingle] = {27657,27658},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{46332,46331,46330,46328,46329,46327},46327}}},
        },
        [27664] = { -- Darkmoon Volcanic Deck
            [questKeys.specialFlags] = 1,
        },
        [27665] = { -- Darkmoon Hurricane Deck
            [questKeys.specialFlags] = 1,
        },
        [27666] = { -- Darkmoon Earthquake Deck
            [questKeys.specialFlags] = 1,
        },
        [27667] = { -- Darkmoon Earthquake Deck
            [questKeys.specialFlags] = 1,
        },
        [27668] = { -- Pay Attention!
            [questKeys.preQuestSingle] = {25944},
            [questKeys.exclusiveTo] = {25946},
        },
        [27669] = { -- Do the Honors
            [questKeys.objectives] = {{{46283,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27670] = { -- Pinned Down
            [questKeys.zoneOrSort] = zoneIDs.DUN_MOROGH,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.MAGE + classKeys.WARLOCK + classKeys.ROGUE + classKeys.PRIEST, -- gnome DKs don't get these quests
        },
        [27671] = { -- See to the Survivors
            [questKeys.objectives] = {{{46268,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.startedBy] = {{47250}},
            [questKeys.zoneOrSort] = zoneIDs.DUN_MOROGH,
        },
        [27674] = { -- To the Surface
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Torben Zapblast"), 0, {{"monster", 46293}}}},
            [questKeys.zoneOrSort] = zoneIDs.DUN_MOROGH,
        },
        [27683] = { -- Into the Woods
            [questKeys.exclusiveTo] = {27684},
            [questKeys.nextQuestInChain] = 27367,
        },
        [27684] = { -- Visitors
            [questKeys.exclusiveTo] = {27683},
            [questKeys.nextQuestInChain] = 27367,
        },
        [27685] = { -- Good Deed Left Undone
            [questKeys.nextQuestInChain] = 25587,
        },
        [27687] = { -- An Opened Can of Whoop Gnash
            [questKeys.startedBy] = {{40987},nil,{62138}},
            [questKeys.preQuestSingle] = {25598},
        },
        [27688] = { -- Distract Them for Me
            [questKeys.preQuestGroup] = {27652,27654},
            [questKeys.exclusiveTo] = {},
        },
        [27689] = { -- Distract Them for Me
            [questKeys.preQuestGroup] = {27653,27655},
            [questKeys.exclusiveTo] = {},
        },
        [27690] = { -- Narkrall, the Drake-Tamer
            [questKeys.preQuestSingle] = {27606},
            [questKeys.exclusiveTo] = {27947},
        },
        [27694] = { -- Pool of Tears
            [questKeys.preQuestSingle] = {},
        },
        [27695] = { -- The Elementium Axe
            [questKeys.preQuestGroup] = {27652,27654},
            [questKeys.exclusiveTo] = {},
        },
        [27696] = { -- The Elementium Axe
            [questKeys.preQuestGroup] = {27653,27655},
            [questKeys.exclusiveTo] = {},
        },
        [27700] = { -- Dragon, Unchained
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27695,27688},
            [questKeys.objectives] = {{{46456,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27701] = { -- Dragon, Unchained
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27696,27689},
            [questKeys.objectives] = {{{46456,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27702] = { -- Coup de Grace
            [questKeys.preQuestSingle] = {27700},
            [questKeys.exclusiveTo] = {},
        },
        [27703] = { -- Coup de Grace
            [questKeys.preQuestSingle] = {27701},
            [questKeys.exclusiveTo] = {},
        },
        [27704] = { -- Legends of the Sunken Temple
            [questKeys.triggerEnd] = {"Hall of Masks found", {[zoneIDs.SWAMP_OF_SORROWS]={{54.27,79.02}}}},
        },
        [27705] = { -- Step One: The Priestess
            [questKeys.startedBy] = {{46071}},
        },
        [27707] = { -- Neferset Prison
            [questKeys.objectives] = {{{46425,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.finishedBy] = {{100013}},
        },
        [27711] = { -- Back to the Elementium Depths
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27702,27719},
            [questKeys.nextQuestInChain] = 27720,
        },
        [27712] = { -- Back to the Elementium Depths
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27703,27798},
            [questKeys.nextQuestInChain] = 28885,
        },
        [27716] = { -- Piece of the Past
            [questKeys.startedBy] = {{39638,41227},nil,{62281}},
            [questKeys.preQuestSingle] = {25922},
        },
        [27717] = { -- Piece of the Past
            [questKeys.startedBy] = {{39638,41227},nil,{62282}},
            [questKeys.preQuestSingle] = {25996},
        },
        [27718] = { -- Warchief's Command: Vashj'ir!
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
            [questKeys.nextQuestInChain] = 25924,
        },
        [27719] = { -- Water of Life
            [questKeys.objectives] = {{{46819,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {},
        },
        [27720] = { -- Mr. Goldmine's Wild Ride
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27702,27719},
            [questKeys.objectives] = {{{46243,nil,Questie.ICON_TYPE_TALK},{46459,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27721] = { -- Warchief's Command: Mount Hyjal!
            [questKeys.objectives] = {{{15188, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.nextQuestInChain] = 25316,
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [27722] = { -- Warchief's Command: Deepholm!
            [questKeys.nextQuestInChain] = 27203,
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [27724] = { -- Hero's Call: Vashj'ir!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.nextQuestInChain] = 14482,
        },
        [27726] = { -- Hero's Call: Mount Hyjal!
            [questKeys.objectives] = {{{15187, nil, Questie.ICON_TYPE_TALK}}},
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.nextQuestInChain] = 25316,
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [27727] = { -- Hero's Call: Deepholm!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.nextQuestInChain] = 27203,
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [27729] = { -- Once More, With Eeling
            [questKeys.preQuestSingle] = {14482,25924},
            [questKeys.finishedBy] = {{100004}},
        },
        [27738] = { -- The Pit of Scales
            [questKeys.startedBy] = {{46136,47709}},
            [questKeys.objectives] = {{{46276}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tahet"), 0, {{"monster", 46496}}}},
        },
        [27742] = { -- A Little on the Side
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {27720,28885},
        },
        [27743] = { -- While We're Here
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {27720,28885},
        },
        [27744] = { -- Rune Ruination
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {27720,28885},
        },
        [27745] = { -- A Fiery Reunion
            [questKeys.objectives] = {nil,{{301087}},{{62394}}},
            [questKeys.preQuestGroup] = {27742,27743,27744},
            [questKeys.preQuestSingle] = {},
        },
        [27747] = { -- Total War
            [questKeys.objectives] = {nil,{{206195}}},
            [questKeys.preQuestSingle] = {27690},
        },
        [27750] = { -- War Forage
            [questKeys.preQuestSingle] = {27690},
        },
        [27751] = { -- Crushing the Wildhammer
            [questKeys.preQuestSingle] = {27690},
        },
        [27753] = { -- Never Leave a Dinner Behind
            [questKeys.preQuestSingle] = {},
        },
        [27755] = { -- The Curse of the Tombs
            [questKeys.preQuestSingle] = {28501},
        },
        [27756] = { -- The Foreman
            [questKeys.nextQuestInChain] = 27758,
        },
        [27758] = { -- The Carpenter
            [questKeys.preQuestSingle] = {27756},
            [questKeys.nextQuestInChain] = 27781,
        },
        [27760] = { -- Artificial Intelligence
            [questKeys.startedBy] = {{46590,46920,47014},nil,{62483}},
            [questKeys.preQuestSingle] = {28501},
        },
        [27761] = { -- A Disarming Distraction
            [questKeys.objectives] = {nil,{{206395},{206396},{206397}},nil,nil,{{{46888},46888,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {},
        },
        [27762] = { -- Fuselight, Ho!
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 48708}}}},
        },
        [27768] = { -- Step Two: The Bloodletter
            [questKeys.startedBy] = {{46071}},
        },
        [27773] = { -- Step Three: Prophet
            [questKeys.startedBy] = {{46071}},
        },
        [27777] = { -- Core Access Codes
            [questKeys.exclusiveTo] = {},
        },
        [27778] = { -- Hacking the Wibson
            [questKeys.objectives] = {{{46715}}},
            [questKeys.requiredSourceItems] = {62621},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27761,27777},
        },
        [27779] = { -- Gnomebliteration
            [questKeys.objectives] = {{{46384}}},
        },
        [27781] = { -- The Machination
            [questKeys.preQuestSingle] = {27758},
            [questKeys.nextQuestInChain] = 27785,
        },
        [27782] = { -- Mathias Needs You
            [questKeys.preQuestSingle] = {27745},
            [questKeys.nextQuestInChain] = 27784,
        },
        [27783] = { -- Garona Needs You
            [questKeys.preQuestSingle] = {27745},
            [questKeys.nextQuestInChain] = 27786,
        },
        [27785] = { -- The Admiral
            [questKeys.preQuestSingle] = {27781},
            [questKeys.nextQuestInChain] = 27790,
        },
        [27798] = { -- Water of Life
            [questKeys.objectives] = {{{46819,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {},
        },
        [27803] = { -- Welcome Relief
            [questKeys.preQuestSingle] = {27621},
            [questKeys.exclusiveTo] = {},
        },
        [27804] = { -- The Only Homes We Have
            [questKeys.preQuestSingle] = {27621},
            [questKeys.exclusiveTo] = {},
            [questKeys.requiredSourceItems] = {62508},
            [questKeys.objectives] = {{{46849,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27805] = { -- Small Comforts
            [questKeys.preQuestSingle] = {27621},
        },
        [27806] = { -- Honorable Bearing
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27803,27804},
        },
        [27807] = { -- Clan Mullan
            [questKeys.preQuestSingle] = {27806},
            [questKeys.exclusiveTo] = {},
        },
        [27808] = { -- Stubborn as a Doyle
            [questKeys.preQuestSingle] = {27806},
        },
        [27809] = { -- Firebeard Bellows
            [questKeys.preQuestSingle] = {27806},
            [questKeys.exclusiveTo] = {},
        },
        [27810] = { -- The Fighting Spirit
            [questKeys.exclusiveTo] = {},
        },
        [27811] = { -- The Scent of Battle
            [questKeys.preQuestSingle] = {27807},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{46939,46968,46969},46968,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27812] = { -- The Loyalty of Clan Mullan
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27810,27811},
            [questKeys.exclusiveTo] = {},
        },
        [27813] = { -- Death Worthy of a Dragonmaw
            [questKeys.exclusiveTo] = {},
        },
        [27814] = { -- Anything We Can Get
            [questKeys.preQuestSingle] = {27809},
        },
        [27815] = { -- Somethin' for the Boys
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27813,27814,28234},
        },
        [27816] = { -- Personal Request
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27812,27815,27999},
        },
        [27817] = { -- Dropping the Hammer
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 47241}}}},
        },
        [27841] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14173,14174,14175,14176,14177,27846},
        },
        [27846] = { -- The Grateful Dead
            [questKeys.exclusiveTo] = {13952,14166,14167,14168,14169,14170,14171,14172,14173,14174,14175,14176,14177,27841},
        },
        [27854] = { -- Tides of Darkness
            [questKeys.preQuestGroup] = {27852,27853},
        },
        [27855] = { -- Reinforcements Denied
            [questKeys.preQuestGroup] = {27852,27853},
        },
        [27856] = { -- Marking the Fallen
            [questKeys.preQuestGroup] = {27852,27853},
        },
        [27857] = { -- We're Under Attack!
            [questKeys.preQuestGroup] = {27854,27855,27856},
        },
        [27861] = { -- The Crucible of Carnage: The Bloodeye Bruiser!
            [questKeys.exclusiveTo] = {27862,27863},
        },
        [27862] = { -- The Crucible of Carnage: The Bloodeye Bruiser!
            [questKeys.exclusiveTo] = {27861,27863},
        },
        [27863] = { -- The Crucible of Carnage: The Bloodeye Bruiser!
            [questKeys.objectives] = {{{46944}}},
            [questKeys.exclusiveTo] = {27861,27862},
        },
        [27864] = { -- The Crucible of Carnage: The Deadly Dragonmaw!
            [questKeys.objectives] = {{{46945}}},
        },
        [27865] = { -- The Crucible of Carnage: The Wayward Wildhammer!
            [questKeys.objectives] = {{{46946}}},
        },
        [27866] = { -- The Crucible of Carnage: Calder's Creation!
            [questKeys.objectives] = {{{46947}}},
        },
        [27867] = { -- The Crucible of Carnage: The Earl of Evisceration!
            [questKeys.objectives] = {{{46948}}},
        },
        [27868] = { -- The Crucible of Carnage: The Twilight Terror!
            [questKeys.objectives] = {{{46949}}},
        },
        [27869] = { -- The Dragon and the Temple
            [questKeys.nextQuestInChain] = 27694,
        },
        [27870] = { -- To Marshtide Watch
            [questKeys.preQuestSingle] = {27914},
            [questKeys.nextQuestInChain] = 27821,
        },
        [27871] = { -- To Stonard
            [questKeys.preQuestSingle] = {27914},
            [questKeys.nextQuestInChain] = 27852,
        },
        [27874] = { -- Aviana's Legacy
            [questKeys.preQuestSingle] = {25611,25612},
            [questKeys.exclusiveTo] = {25985},
            [questKeys.nextQuestInChain] = 25663,
        },
        [27901] = { -- They Don't Know What They've Got Here
            [questKeys.requiredSourceItems] = {62608,62610},
            [questKeys.preQuestSingle] = {27899},
        },
        [27905] = { -- Tailgunner!
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Escaped the Obelisk of the Sun",{[zoneIDs.ULDUM] = {{54.54,42.08}}}},
        },
        [27906] = { -- Neeka Bloodscar
            [questKeys.preQuestSingle] = {27857},
            [questKeys.nextQuestInChain] = 27907,
        },
        [27909] = { -- The Purespring
            [questKeys.preQuestGroup] = {27907,27908},
        },
        [27910] = { -- Last Regrets
            [questKeys.preQuestGroup] = {27907,27908},
        },
        [27911] = { -- With Dying Breath
            [questKeys.preQuestGroup] = {27909,27910},
        },
        [27915] = { -- The Heart of the Temple
            [questKeys.preQuestSingle] = {27914},
            [questKeys.nextQuestInChain] = 27605,
            [questKeys.zoneOrSort] = zoneIDs.SUNKEN_TEMPLE,
        },
        [27916] = { -- Ruag's Report
            [questKeys.nextQuestInChain] = 28553,
        },
        [27922] = { -- Traitors!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Hide behind Neferset Frond"), 0, {{"object", 206579}}}},
        },
        [27925] = { -- Efficient Excavations
            [questKeys.exclusiveTo] = {28132},
            [questKeys.preQuestSingle] = {27669},
        },
        [27926] = { -- Eastern Hospitality
            [questKeys.objectives] = {{{47176,nil,Questie.ICON_TYPE_TALK},{47185,nil,Questie.ICON_TYPE_TALK},{47187,nil,Questie.ICON_TYPE_TALK},{47189,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {27669},
        },
        [27929] = { -- Drag 'em Down
            [questKeys.preQuestSingle] = {27690},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Throw the Barbed Fleshhook at them"), 0, {{"monster", 47186}}}},
        },
        [27932] = { -- The Axe of Earthly Sundering
            [questKeys.preQuestSingle] = {27931},
            [questKeys.objectives] = {{{44218}}},
            [questKeys.exclusiveTo] = {},
        },
        [27933] = { -- Elemental Ore
            [questKeys.preQuestSingle] = {27931},
            [questKeys.exclusiveTo] = {},
        },
        [27934] = { -- One With the Ground
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Slate Quicksand"),0,{{"monster", 47195}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27932,27933},
            [questKeys.finishedBy] = {{100010}},
        },
        [27935] = { -- Bring Down the Avalanche
            [questKeys.preQuestSingle] = {27934},
            [questKeys.startedBy] = {{100011}},
            [questKeys.nextQuestInChain] = 26499,
            [questKeys.exclusiveTo] = {27936},
        },
        [27936] = { -- Bring Down the Avalanche
            [questKeys.preQuestSingle] = {27934},
            [questKeys.nextQuestInChain] = 26499,
            [questKeys.exclusiveTo] = {27935},
        },
        [27939] = { -- The Desert Fox
            [questKeys.preQuestSingle] = {27926},
        },
        [27940] = { -- Dirty Birds
            [questKeys.preQuestSingle] = {27926},
            [questKeys.finishedBy] = {{100015}},
        },
        [27942] = { -- Idolatry
            [questKeys.preQuestSingle] = {27939},
            [questKeys.exclusiveTo] = {},
        },
        [27943] = { -- Angered Spirits
            [questKeys.preQuestSingle] = {27939},
            [questKeys.exclusiveTo] = {},
        },
        [27944] = { -- Thinning the Brood
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27945] = { -- Paint it Black
            [questKeys.preQuestGroup] = {27747,27750,27751,27929},
        },
        [27947] = { -- A Vision of Twilight
            [questKeys.preQuestGroup] = {27747,27750,27751,27929},
        },
        [27948] = { -- A Sticky Task
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27949] = { -- The Forgotten
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27950] = { -- Gobbles!
            [questKeys.objectives] = {{{47255,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27941,27942,27943},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Commander Schnottz"), 0, {{"monster", 47159}}}},
            [questKeys.finishedBy] = {{100014}},
        },
        [27952] = { -- The Explorers
            [questKeys.nextQuestInChain] = 27004,
            [questKeys.preQuestSingle] = {},
        },
        [27953] = { -- The Reliquary
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 27005,
        },
        [27955] = { -- Eye Spy
            [questKeys.objectives] = {{{47274,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27966] = { -- Salvaging the Remains
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27967] = { -- First Lieutenant Connor
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27969] = { -- Make Yourself Useful
            [questKeys.objectives] = {{{47292,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27970] = { -- Captain P. Harris
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27971] = { -- Rattling Their Cages
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27972] = { -- Boosting Morale
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27973] = { -- Watch Out For Splinters!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27975] = { -- WANTED: Foreman Wellson
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27978] = { -- Ghostbuster
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27979] = { -- Dark Ministry
            [questKeys.requiredSourceItems] = {62823,62824,62825},
        },
        [27984] = { -- Lunthistle's Tale
            [questKeys.objectives] = {{{8436,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27987] = { -- Cannonball!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27989] = { -- Ruumbo Demands Honey
            [questKeys.preQuestSingle] = {28100},
            [questKeys.reputationReward] = {},
        },
        [27990] = { -- Battlezone
            [questKeys.objectives] = {{{47385},{47159,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Man the Siege Tank"), 0, {{"monster", 47732},{"monster", 47743}}}},
        },
        [27991] = { -- Taking the Overlook Back
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27992] = { -- Magnets, How Do They Work?
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27993] = { -- Take it to 'Em!
            [questKeys.triggerEnd] = {"Khartut's Tomb Investigated",{[zoneIDs.ULDUM]={{64.6,22.6}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {28112},
            [questKeys.nextQuestInChain] = 27141,
        },
        [27994] = { -- Ruumbo Demands Justice
            [questKeys.preQuestSingle] = {28100},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 8}},
        },
        [27995] = { -- Dance for Ruumbo!
            [questKeys.preQuestGroup] = {27989,27994},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Ruumbo's Secret Discovered",{[zoneIDs.FELWOOD]={{51.5,83.7}}}},
            [questKeys.reputationReward] = {},
        },
        [27997] = { -- The Corruption of the Jadefire
            [questKeys.preQuestSingle] = {},
        },
        [27999] = { -- The Fate of the Doyles
            [questKeys.preQuestSingle] = {27808},
        },
        [28000] = { -- Do the Imp-Possible
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{47339}}},
        },
        [28001] = { -- A Coward's Due
            [questKeys.preQuestSingle] = {27817},
        },
        [28002] = { -- Crisis Management
            [questKeys.objectives] = {{{47516,nil,Questie.ICON_TYPE_TALK},{47519,nil,Questie.ICON_TYPE_TALK},{47520,nil,Questie.ICON_TYPE_TALK},{47707,nil,Questie.ICON_TYPE_TALK}}},
        },
        [28031] = { -- Special Delivery for Brivelthwerp [Alliance]
            [questKeys.preQuestSingle] = {25542,25561},
        },
        [28038] = { -- Blood in the Highlands
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 27863,
            [questKeys.preQuestGroup] = {27751,27929},
        },
        [28041] = { -- Bait and Throttle
            [questKeys.preQuestGroup] = {27751,27929},
        },
        [28042] = { -- Special Delivery for Brivelthwerp [Horde]
            [questKeys.preQuestSingle] = {25543,25562},
        },
        [28043] = { -- How to Maim Your Dragon
            [questKeys.objectives] = {{{47422,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the bait near it"), 0, {{"monster", 47391}}}},
        },
        [28044] = { -- Touch the Untouchable
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Phaseblood Potion at the Sigil of Tichondrius"),0,{{"object",206656}}}},
        },
        [28046] = { -- Finish The Job
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28047] = { -- Freezing the Pipes
            [questKeys.preQuestGroup] = {28051,28045},
        },
        [28048] = { -- That Smart One's Gotta Go
            [questKeys.preQuestGroup] = {28051,28045},
        },
        [28049] = { -- See the Invisible
            [questKeys.preQuestSingle] = {28000},
        },
        [28050] = { -- Shark Tank
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28051] = { -- We All Scream for Ice Cream... and then Die!
            [questKeys.objectives] = {{{47446,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {28031,28042},
        },
        [28059] = { -- Claiming The Keep
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28063] = { -- Leave No Weapon Behind
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28065] = { -- Walk A Mile In Their Shoes
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28068] = { -- Adventurers Wanted: Blackrock Depths
            [questKeys.requiredMaxLevel] = 56,
        },
        [28069] = { -- Adventurers Wanted: Blackrock Depths
            [questKeys.requiredMaxLevel] = 56,
        },
        [28084] = { -- Might of the Krom'gar
            [questKeys.preQuestSingle] = {26004},
        },
        [28086] = { -- Free the Pridelings
            [questKeys.preQuestSingle] = {28085},
            [questKeys.objectives] = {{{47481,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28087] = { -- Death to all Trappers!
            [questKeys.preQuestSingle] = {28085},
        },
        [28088] = { -- Release Heartrazor
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28086,28087},
        },
        [28089] = { -- Warchief's Command: Hillsbrad Foothills!
            [questKeys.exclusiveTo] = {28096},
            [questKeys.preQuestSingle] = {26965},
        },
        [28090] = { -- Precious Goods
            [questKeys.exclusiveTo] = {},
        },
        [28091] = { -- Easy Pickings
            [questKeys.exclusiveTo] = {},
        },
        [28093] = { -- Pressing Forward
            [questKeys.objectives] = {{{47566,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28094] = { -- Paving the Way
            [questKeys.preQuestSingle] = {28097},
        },
        [28096] = { -- Welcome to the Machine
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount the Skeletal Steed"), 0, {{"monster", 47445}}}},
        },
        [28097] = { -- The Gates of Grim Batol
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28090,28091},
        },
        [28098] = { -- The Twilight Skymaster
            [questKeys.objectives] = {{{47503,nil,Questie.ICON_TYPE_MOUNT_UP},{47510}}},
        },
        [28100] = { -- A Talking Totem
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 12}},
        },
        [28101] = { -- Mathias' Command
            [questKeys.preQuestGroup] = {27507,27508,27509},
        },
        [28102] = { -- Fight the Power
            [questKeys.preQuestSingle] = {28044},
        },
        [28103] = { -- Easy Pickings
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {28101},
        },
        [28104] = { -- Precious Goods
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {28101},
        },
        [28107] = { -- Paving the Way
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28103,28104},
        },
        [28108] = { -- If the Key Fits
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28103,28104},
            [questKeys.objectives] = {{{47539,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28109] = { -- Pressing Forward
            [questKeys.objectives] = {{{47566,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28112] = { -- Escape From the Lost City
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27923,27924,28105},
        },
        [28113] = { -- Break the Unbreakable
            [questKeys.preQuestSingle] = {28044},
        },
        [28116] = { -- Crying Violet
            [questKeys.preQuestSingle] = {},
        },
        [28119] = { -- Purity From Corruption
            [questKeys.preQuestGroup] = {28116,28121},
        },
        [28125] = { -- Something to Wear
            [questKeys.preQuestSingle] = {28124},
        },
        [28126] = { -- Dousing the Flames of Protection
            [questKeys.preQuestSingle] = {28119},
            [questKeys.preQuestGroup] = {},
        },
        [28127] = { -- Break Them Out
            [questKeys.preQuestSingle] = {28124},
        },
        [28128] = { -- The Inner Circle
            [questKeys.preQuestSingle] = {28119},
        },
        [28129] = { -- The Demon Prince
            [questKeys.preQuestSingle] = {28119},
        },
        [28130] = { -- Not The Friendliest Town
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28132] = { -- Efficient Excavations
            [questKeys.preQuestSingle] = {27669},
            [questKeys.startedBy] = {{46993},nil,{62768}},
            [questKeys.exclusiveTo] = {27925},
            [questKeys.nextQuestInChain] = 27926,
        },
        [28133] = { -- Fury Unbound
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the fight"), 0, {{"monster", 47671}}}},
        },
        [28134] = { -- Impending Retribution
            [questKeys.objectives] = {{{46603,nil,Questie.ICON_TYPE_TALK},{47715,nil,Questie.ICON_TYPE_TALK},{47930,nil,Questie.ICON_TYPE_TALK}}},
        },
        [28137] = { -- Teach A Man To Fish.... Or Steal
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28140] = { -- The Elder Crone
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28136,28139},
        },
        [28141] = { -- Relics of the Sun King
            [questKeys.preQuestSingle] = {28112},
        },
        [28145] = { -- Venomblood Antidote
            [questKeys.objectives] = {{{45859,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {28112},
        },
        [28147] = { -- Purple is Your Color
            [questKeys.preQuestSingle] = {28133},
        },
        [28149] = { -- Whispers in the Wind
            [questKeys.preQuestSingle] = {28133},
        },
        [28150] = { -- An Arcane Ally
            [questKeys.preQuestGroup] = {27995,27997,28148},
            [questKeys.nextQuestInChain] = 28000,
        },
        [28152] = { -- Jaedenar Awaits
            [questKeys.preQuestSingle] = {28113},
            [questKeys.nextQuestInChain] = 28116,
        },
        [28157] = { -- Four Twilight Elements
            [questKeys.preQuestSingle] = {28142},
        },
        [28158] = { -- Unbound
            [questKeys.preQuestSingle] = {28142},
        },
        [28160] = { -- Spread the Word [Alliance]
            [questKeys.preQuestSingle] = {28159},
        },
        [28161] = { -- Spread the Word [Horde]
            [questKeys.preQuestSingle] = {28159},
        },
        [28163] = { -- The Leftovers
            [questKeys.objectives] = {nil,nil,nil,nil,{{{47607,47608,47609,47610},47607},},},
        },
        [28164] = { -- Seek Brother Silverhallow
            [questKeys.nextQuestInChain] = 27441,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [28167] = { -- Venomblood Antidote
            [questKeys.zoneOrSort] = zoneIDs.DUN_MOROGH,
        },
        [28169] = { -- Withdraw to the Loading Room!
            [questKeys.zoneOrSort] = zoneIDs.DUN_MOROGH,
        },
        [28170] = { -- Night Terrors
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Uchek"), 0, {{"monster", 47826}}}},
        },
        [28173] = { -- Blackout
            [questKeys.exclusiveTo] = {},
        },
        [28174] = { -- Burning Vengeance
            [questKeys.preQuestSingle] = {},
        },
        [28175] = { -- Shining Through the Dark
            [questKeys.preQuestSingle] = {28171},
            [questKeys.objectives] = {{{47876,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28176] = { -- Following the Young Home
            [questKeys.preQuestGroup] = {28173,28175,28191},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{47855,nil,Questie.ICON_TYPE_EVENT},{47874,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28187] = { -- Missed Me By Zhat Much!
            [questKeys.objectives] = {{{47940,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28189] = { -- Do the Right Thing
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28191] = { -- A Fitting End
            [questKeys.preQuestSingle] = {28171},
            [questKeys.exclusiveTo] = {},
        },
        [28193] = { -- Lockdown!
            [questKeys.objectives] = {{{47970,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28194] = { -- The Great Escape
            [questKeys.preQuestSingle] = {28187},
        },
        [28201] = { -- Ploughshares to Swords
            [questKeys.objectives] = {{{46333,nil,Questie.ICON_TYPE_TALK}}},
        },
        [28208] = { -- Winna's Kitten
            [questKeys.preQuestGroup] = {28190,28207},
        },
        [28211] = { -- Tempered in Elemental Flame
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28212] = { -- Hot Stuff
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28214] = { -- Cleanup at Bloodvenom Post
            [questKeys.preQuestSingle] = {28208},
        },
        [28215] = { -- Potential Energy
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28216] = { -- Magmalord Falthazar
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
            [questKeys.finishedBy] = {{46591}},
        },
        [28217] = { -- Wanted: The Demon Hunter
            [questKeys.preQuestSingle] = {28374},
        },
        [28218] = { -- A Destiny of Flame and Sorrow
            [questKeys.preQuestSingle] = {28217},
            [questKeys.objectives] = {{{47733}}},
        },
        [28219] = { -- Buzzers for Baby
            [questKeys.preQuestSingle] = {28229},
        },
        [28220] = { -- Seeking Soil
            [questKeys.objectives] = {nil,{{460017,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28221] = { -- These Roots Were Made For Stompin'
            [questKeys.preQuestGroup] = {28219,28220},
        },
        [28224] = { -- The Last Protector
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestSingle] = {28221,28222},
        },
        [28228] = { -- Rejoining the Forest
            [questKeys.triggerEnd] = {"Protector brought to hill", {[zoneIDs.FELWOOD]={{48.7,25.2}}}},
        },
        [28229] = { -- Nature and Nurture
            [questKeys.preQuestSingle] = {28374},
            [questKeys.requiredSourceItems] = {63387},
        },
        [28233] = { -- The Lost Brother
            [questKeys.preQuestSingle] = {27809},
        },
        [28241] = { -- A Vision of Twilight
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28243] = { -- The Eyes Have It
            [questKeys.finishedBy] = {{48010}},
        },
        [28244] = { -- Eye Spy
            [questKeys.objectives] = {{{48116,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.finishedBy] = {{48010}},
        },
        [28247] = { -- Last of Her Kind
            [questKeys.objectives] = {{{47929,"Obsidia defeated"}}},
        },
        [28248] = { -- Victors' Point
            [questKeys.preQuestSingle] = {28247},
        },
        [28250] = { -- Thieving Little Pluckers
            [questKeys.objectives] = {nil,nil,nil,nil,{{{48040,48041,48043},48040,"Thieving plucker smashed",nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
        },
        [28256] = { -- The Skull of Gul'dan
            [questKeys.preQuestSingle] = {28218},
            [questKeys.objectives] = {{{47812,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28257] = { -- The Fall of Tichondrius
            [questKeys.preQuestSingle] = {28256},
            [questKeys.objectives] = {{{47917}}},
        },
        [28258] = { -- Meet with Ander Germaine
            [questKeys.nextQuestInChain] = 28393,
        },
        [28259] = { -- Meet with Demisette Cloyce
            [questKeys.nextQuestInChain] = 28399,
        },
        [28260] = { -- Meet with Wulf Hansreim
            [questKeys.nextQuestInChain] = 28394,
        },
        [28261] = { -- Deceivers In Our Midst
            [questKeys.preQuestSingle] = {28257},
        },
        [28262] = { -- Meet with Lord Tony Romano
            [questKeys.nextQuestInChain] = 28406,
        },
        [28263] = { -- Meet with Maginor Dumas
            [questKeys.requiredClasses] = classKeys.MAGE,
            [questKeys.nextQuestInChain] = 28398,
        },
        [28267] = { -- Firing Squad
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Commander Schnottz"),0,{{"monster",47972}}}},
            [questKeys.objectives] = {{{48189,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28194,28195},
        },
        [28268] = { -- Meet with Lord Grayson Shadowbreaker
            [questKeys.nextQuestInChain] = 28405,
        },
        [28271] = { -- Reduced Productivity
            [questKeys.preQuestSingle] = {28274},
            [questKeys.exclusiveTo] = {},
        },
        [28272] = { -- Missing Pieces
            [questKeys.preQuestSingle] = {28274},
            [questKeys.exclusiveTo] = {},
        },
        [28274] = { -- Two Tents
            [questKeys.objectives] = {{{48431,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28275] = { -- Bombs Away!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the cannon"),0,{{"monster",48283}}}},
        },
        [28277] = { -- Salhet the Tactician
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Salhet"),0,{{"monster",48237}}}},
            [questKeys.objectives] = {{{48199}}},
        },
        [28280] = { -- Tear Them From the Sky!
            [questKeys.preQuestGroup] = {28211,28212},
        },
        [28281] = { -- Last Stand at Thundermar
            [questKeys.preQuestSingle] = {28280},
        },
        [28282] = { -- Narkrall, The Drake-Tamer
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 48173}}}},
        },
        [28283] = { -- What's that Rattle? [Alliance]
            [questKeys.preQuestSingle] = {27275},
            [questKeys.nextQuestInChain] = 27316,
        },
        [28284] = { -- What's that Rattle? [Horde]
            [questKeys.preQuestSingle] = {27276},
            [questKeys.nextQuestInChain] = 27317,
        },
        [28285] = { -- Meet with High Priestess Laurena
            [questKeys.nextQuestInChain] = 28328,
            [questKeys.startedBy] = {{4090,11401,11406,16756}},
        },
        [28287] = { -- Meet with Farseer Umbrua
            [questKeys.nextQuestInChain] = 28401,
            [questKeys.startedBy] = {{17519,23127,52292}},
        },
        [28288] = { -- Open Their Eyes
            [questKeys.preQuestSingle] = {28113},
            [questKeys.objectives] = {{{47369}}},
        },
        [28289] = { -- Moonglade Calls
            [questKeys.nextQuestInChain] = 28343,
        },
        [28290] = { -- Meet with Grezz Ragefist
            [questKeys.nextQuestInChain] = 28457,
        },
        [28292] = { -- That's No Pyramid!
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [28293] = { -- That's No Pyramid!
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [28295] = { -- Meetup with the Caravan
            [questKeys.exclusiveTo] = {28558},
            [questKeys.zoneOrSort] = zoneIDs.TANARIS,
        },
        [28296] = { -- Meetup with the Caravan
            [questKeys.exclusiveTo] = {28557},
            [questKeys.zoneOrSort] = zoneIDs.TANARIS,
        },
        [28297] = { -- Meet with Ormak Grimshot
            [questKeys.nextQuestInChain] = 28461,
        },
        [28298] = { -- Meet with Gordul
            [questKeys.nextQuestInChain] = 28463,
        },
        [28299] = { -- Meet with Zevrost
            [questKeys.finishedBy] = {{3326}},
            [questKeys.nextQuestInChain] = 28459,
        },
        [28300] = { -- Meet with Ureda
            [questKeys.nextQuestInChain] = 28458,
        },
        [28301] = { -- Meet with Kardris Dreamseeker
            [questKeys.finishedBy] = {{3344}},
            [questKeys.startedBy] = {{16661,51639}},
            [questKeys.nextQuestInChain] = 28465,
        },
        [28302] = { -- Meet with Sunwalker Atohmo
            [questKeys.nextQuestInChain] = 28466,
            [questKeys.startedBy] = {{16681,20406,43795}},
        },
        [28303] = { -- Meet with Master Pyreanor
            [questKeys.nextQuestInChain] = 28473,
        },
        [28304] = { -- Meet with Dark Cleric Cecille
            [questKeys.nextQuestInChain] = 28474,
        },
        [28305] = { -- The Fate of Bloodvenom Post
            [questKeys.preQuestGroup] = {28126,28128,28155},
        },
        [28306] = { -- Whisperwind Grove
            [questKeys.preQuestGroup] = {28213,28214},
        },
        [28307] = { -- Meet with Tyelis
            [questKeys.nextQuestInChain] = 28475,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [28308] = { -- Meet with Seer Liwatha
            [questKeys.nextQuestInChain] = 28476,
            [questKeys.requiredClasses] = classKeys.PRIEST,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
        },
        [28309] = { -- Meet with Shadow-Walker Zuru
            [questKeys.requiredRaces] = raceKeys.TROLL,
            [questKeys.requiredClasses] = classKeys.PRIEST,
            [questKeys.nextQuestInChain] = 28477,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
            [questKeys.zoneOrSort] = 1637,
        },
        [28323] = { -- Meet with Brother Silverhallow
            [questKeys.nextQuestInChain] = 28478,
            [questKeys.requiredClasses] = classKeys.PRIEST,
            [questKeys.startedBy] = {{3045,4606,16658,43870}},
            [questKeys.zoneOrSort] = 1637,
        },
        [28328] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
        },
        [28329] = { -- Angry Scrubbing Bubbles
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28333] = { -- It's Time to Oil Up
            [questKeys.requiredSourceItems] = {63515},
            [questKeys.objectives] = {{{48259,nil,Questie.ICON_TYPE_INTERACT}}}
        },
        [28335] = { -- Turn It Off! Turn It Off!
            [questKeys.preQuestSingle] = {28380},
        },
        [28336] = { -- Slap and Cap
            [questKeys.preQuestGroup] = {28357,28370},
            [questKeys.objectives] = {{{48331,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28338] = { -- Deadwood of the North
            [questKeys.preQuestSingle] = {},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 10}},
        },
        [28339] = { -- Is Your Oil Running?
            [questKeys.preQuestGroup] = {28357,28370},
        },
        [28340] = { -- A Bomb Deal
            [questKeys.preQuestSingle] = {28380},
        },
        [28343] = { -- The Breath of Cenarius
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {nil,{{207103}},{{63469}}},
            [questKeys.sourceItemId] = 63469,
        },
        [28351] = { -- Unlimited Potential
            [questKeys.objectives] = {{{51217,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28352] = { -- Camelraderie
            [questKeys.name] = "Camelraderie",
            [questKeys.objectives] = {{{51193,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28353] = { -- Jonesy Sent For You
            [questKeys.nextQuestInChain] = 28271,
        },
        [28355] = { -- Terrible Little Creatures
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28357] = { -- Take it to the Tree
            [questKeys.preQuestGroup] = {28333,28334},
        },
        [28361] = { -- Squirrely Clean
            [questKeys.objectives] = {{{48457,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28362] = { -- Stupid Drizle!
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 8}},
        },
        [28363] = { -- Stirred the Hornet's Nest
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28271,28272},
        },
        [28364] = { -- The Chieftain's Key
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 10}},
        },
        [28366] = { -- Disarming Bears
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 8}},
        },
        [28369] = { -- My Sister, Fanny
            [questKeys.nextQuestInChain] = 27753,
        },
        [28370] = { -- Wisp-napping
            [questKeys.preQuestGroup] = {28333,28334},
        },
        [28372] = { -- Back to Business
            [questKeys.preQuestSingle] = {28264},
        },
        [28374] = { -- Weeding the Lawn
            [questKeys.preQuestGroup] = {28360.28361},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{47747,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28376] = { -- Myzerian's Head
            [questKeys.startedBy] = {{48428},nil,{63700}},
            [questKeys.preQuestSingle] = {28367},
        },
        [28377] = { -- Rescue at Glopgut's Hollow
            [questKeys.preQuestSingle] = {28346},
        },
        [28378] = { -- Find Fanny
            [questKeys.preQuestSingle] = {28377},
            [questKeys.startedBy] = {{48472}},
            [questKeys.objectives] = {{{48499,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28379] = { -- Ogre Bashin
            [questKeys.preQuestSingle] = {28377},
            [questKeys.startedBy] = {{48472}},
        },
        [28380] = { -- Pikwik in Peril
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28336,28339},
        },
        [28390] = { -- Glop, Son of Glop
            [questKeys.exclusiveTo] = {28391},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the chase"), 0, {{"monster", 43503}}}},
            [questKeys.requiredMinRep] = {1171,21000},
        },
        [28391] = { -- The Restless Brood
            [questKeys.objectives] = {{{43641}},{{204837}}},
            [questKeys.exclusiveTo] = {28390},
            [questKeys.requiredMinRep] = {1171,21000},
        },
        [28393] = { -- A Dangerous Alliance
            [questKeys.preQuestSingle] = {},
        },
        [28394] = { -- The Golem Lord's Creations
            [questKeys.startedBy] = {{44247}},
            [questKeys.finishedBy] = {{44247}},
            [questKeys.preQuestSingle] = {},
        },
        [28395] = { -- Feathers for Nafien
            [questKeys.preQuestGroup] = {28338,28366},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 11}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28396] = { -- Feathers for Grazle
            [questKeys.preQuestSingle] = {27995},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 11}},
        },
        [28398] = { -- The Pyromancer's Grimoire
            [questKeys.startedBy] = {{331}},
            [questKeys.finishedBy] = {{331}},
            [questKeys.preQuestSingle] = {},
        },
        [28399] = { -- Stones of Binding
            [questKeys.preQuestSingle] = {},
        },
        [28401] = { -- Slaves of the Firelord
            [questKeys.preQuestSingle] = {},
        },
        [28403] = { -- Bad Datas
            [questKeys.triggerEnd] = {"Titan Data Uploaded",{[zoneIDs.ULDUM]={{36.18,23.25}}}},
            [questKeys.objectives] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 48528}}}},
        },
        [28404] = { -- I'll Do It By Hand
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat the defenses"), 0, {{"monster", 48529}}}},
        },
        [28405] = { -- Weapons of Darkness
            [questKeys.preQuestSingle] = {},
        },
        [28406] = { -- The Dark Iron Army
            [questKeys.preQuestSingle] = {},
        },
        [28407] = { -- The Bachelorette
            [questKeys.preQuestGroup] = {28378,28379},
        },
        [28408] = { -- Something Bold
            [questKeys.preQuestSingle] = {28407},
        },
        [28409] = { -- Something Brewed
            [questKeys.preQuestSingle] = {28407},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 48758}}}},
            [questKeys.triggerEnd] = {"Supply Caravan Escorted",{[zoneIDs.TWILIGHT_HIGHLANDS]={{56.05,20.4}}}},
            [questKeys.objectives] = {},
        },
        [28410] = { -- Something Stolen
            [questKeys.preQuestSingle] = {28407},
        },
        [28411] = { -- Something Stewed
            [questKeys.preQuestSingle] = {28407},
        },
        [28413] = { -- Words and Music By...
            [questKeys.objectives] = {{{48366,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {28407},
        },
        [28414] = { -- Fourth and Goal
            [questKeys.objectives] = {{{37203,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.startedBy] = {{37106,100006}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 48526}}}},
            [questKeys.exclusiveTo] = {24503},
        },
        [28457] = { -- A Dangerous Alliance
            [questKeys.preQuestSingle] = {},
        },
        [28458] = { -- The Pyromancer's Grimoire
            [questKeys.preQuestSingle] = {},
        },
        [28459] = { -- Stones of Binding
            [questKeys.finishedBy] = {{3326}},
            [questKeys.preQuestSingle] = {},
        },
        [28460] = { -- Threat of the Winterfall
            [questKeys.preQuestSingle] = {},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 10}},
        },
        [28461] = { -- The Golem Lord's Creations
            [questKeys.preQuestSingle] = {},
        },
        [28463] = { -- The Dark Iron Army
            [questKeys.preQuestSingle] = {},
        },
        [28464] = { -- Falling to Corruption
            [questKeys.preQuestSingle] = {},
        },
        [28465] = { -- Slaves of the Firelord
            [questKeys.finishedBy] = {{3344}},
            [questKeys.preQuestSingle] = {},
        },
        [28466] = { -- Weapons of Darkness
            [questKeys.preQuestSingle] = {},
        },
        [28469] = { -- Winterfall Runners
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 8}},
        },
        [28470] = { -- High Chief Winterfall
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 11}},
        },
        [28471] = { -- The Final Piece
            [questKeys.startedBy] = {{10738},nil,{12842}},
            [questKeys.preQuestSingle] = {28470},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 8}},
        },
        [28472] = { -- Words of the High Chief
            [questKeys.nextQuestInChain] = 28479,
        },
        [28473] = { -- Weapons of Darkness
            [questKeys.preQuestSingle] = {},
        },
        [28474] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
        },
        [28475] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
        },
        [28476] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredClasses] = classKeys.PRIEST,
        },
        [28477] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceKeys.TROLL,
        },
        [28478] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredClasses] = classKeys.PRIEST,
        },
        [28479] = { -- The Ruins of Kel'Theril
            [questKeys.preQuestSingle] = {},
        },
        [28486] = { -- Salhet's Gambit
            [questKeys.triggerEnd] = {"Higher ground secured", {[zoneIDs.ULDUM]={{53.76,75.39}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 49244}}}},
            [questKeys.preQuestSingle] = {28623},
            [questKeys.objectives] = {},
        },
        [28488] = { -- Beneath the Surface
            [questKeys.exclusiveTo] = {26710,27048},
        },
        [28490] = { -- Hero's Call: Darkshore!
            [questKeys.requiredMaxLevel] = 18,
        },
        [28492] = { -- Hero's Call: Ashenvale!
            [questKeys.requiredMaxLevel] = 23,
        },
        [28493] = { -- Warchief's Command: Ashenvale!
            [questKeys.requiredMaxLevel] = 23,
        },
        [28494] = { -- Warchief's Command: Northern Barrens!
            [questKeys.exclusiveTo] = {26642},
            [questKeys.nextQuestInChain] = 871,
            [questKeys.requiredMaxLevel] = 18,
        },
        [28496] = { -- Warchief's Command: Azshara!
            [questKeys.exclusiveTo] = {14129},
            [questKeys.requiredMaxLevel] = 18,
        },
        [28497] = { -- Fire From the Sky
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 48699}}}},
        },
        [28500] = { -- The Cypher of Keset
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28498,28499},
        },
        [28501] = { -- The Defense of Nahom
            [questKeys.objectives] = {{{48490}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 49228}}}},
        },
        [28502] = { -- The Bandit Warlord
            [questKeys.preQuestSingle] = {28141},
        },
        [28503] = { -- Hero's Call: Thousand Needles!
            [questKeys.requiredMaxLevel] = 43,
        },
        [28504] = { -- Warchief's Command: Thousand Needles!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 43,
        },
        [28507] = { -- Hero's Call: Tanaris!
            [questKeys.requiredMaxLevel] = 48,
        },
        [28509] = { -- Warchief's Command: Tanaris!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 48,
        },
        [28510] = { -- Warchief's Command: Feralas!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28511] = { -- Hero's Call: Feralas!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28517] = { -- The Howling Oak
            [questKeys.preQuestSingle] = {},
        },
        [28520] = { -- The Fall of Neferset City
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28480,28483,28486}, -- 28483 might not be needed, worth to double check
        },
        [28521] = { -- Speak to Salfa
            [questKeys.preQuestGroup] = {28362,28364,28338,28366},
            [questKeys.exclusiveTo] = {28522,28524},
            [questKeys.zoneOrSort] = zoneIDs.WINTERSPRING,
        },
        [28523] = { -- More Beads for Salfa
            [questKeys.preQuestSingle] = {28522},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 11}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28524] = { -- Delivery for Donova
            [questKeys.exclusiveTo] = {28544,28545,28768},
            [questKeys.nextQuestInChain] = 28460,
        },
        [28525] = { -- Hero's Call: Un'Goro Crater!
            [questKeys.requiredMaxLevel] = 53,
            [questKeys.nextQuestInChain] = 24740,
        },
        [28526] = { -- Warchief's Command: Un'Goro Crater!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 53,
            [questKeys.nextQuestInChain] = 24740,
        },
        [28527] = { -- Warchief's Command: Silithus!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 57,
            [questKeys.nextQuestInChain] = 8280,
        },
        [28528] = { -- Hero's Call: Silithus!
            [questKeys.nextQuestInChain] = 8280,
            [questKeys.requiredMaxLevel] = 57,
        },
        [28529] = { -- Writings of the Void
            [questKeys.startedBy] = {{48764},nil,{64450}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28530] = { -- Scalding Signs
            [questKeys.preQuestSingle] = {28467},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 10}},
        },
        [28532] = { -- Warchief's Command: Stonetalon Mountains!
            [questKeys.requiredMaxLevel] = 28,
            [questKeys.exclusiveTo] = {25945},
        },
        [28531] = { -- Hero's Call: Desolace!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28533] = { -- The High Council's Decision
            [questKeys.preQuestGroup] = {27738,27838,28291},
            [questKeys.preQuestSingle] = {},
        },
        [28539] = { -- Hero's Call: Stonetalon Mountains!
            [questKeys.requiredMaxLevel] = 28,
        },
        [28542] = { -- Warchief's Command: Felwood!
            [questKeys.requiredMaxLevel] = 48,
        },
        [28543] = { -- Hero's Call: Felwood!
            [questKeys.requiredMaxLevel] = 48,
        },
        [28544] = { -- Hero's Call: Winterspring!
            [questKeys.exclusiveTo] = {28524,28545,28768},
            [questKeys.nextQuestInChain] = 28460,
            [questKeys.requiredMaxLevel] = 53,
        },
        [28545] = { -- Warchief's Command: Winterspring!
            [questKeys.exclusiveTo] = {28524,28544,28768},
            [questKeys.nextQuestInChain] = 28460,
            [questKeys.requiredMaxLevel] = 53,
        },
        [28548] = { -- Warchief's Command: Desolace!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28549] = { -- Warchief's Command: Southern Barrens!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 33,
        },
        [28550] = { -- Hero's Call: Southern Barrens!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28551] = { -- Hero's Call: Southern Barrens!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28552] = { -- Hero's Call: Dustwallow Marsh!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28553] = { -- Okrilla and the Blasted Lands
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 25674,
        },
        [28554] = { -- Warchief's Command: Dustwallow Marsh!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 38,
        },
        [28557] = { -- Warchief's Command: Uldum!
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
            [questKeys.zoneOrSort] = 989,
            [questKeys.nextQuestInChain] = 27003,
        },
        [28558] = { -- Hero's Call: Uldum!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.zoneOrSort] = 989,
            [questKeys.nextQuestInChain] = 27003,
        },
        [28559] = { -- Hero's Call: Bloodmyst Isle!
            [questKeys.requiredMaxLevel] = 18,
        },
        [28560] = { -- Warchief's Command: Ghostlands!
            [questKeys.exclusiveTo] = {9144,9327,9329},
            [questKeys.requiredMaxLevel] = 18,
        },
        [28561] = { -- Nahom Must Hold
            [questKeys.preQuestSingle] = {28533},
        },
        [28562] = { -- Hero's Call: Westfall!
            [questKeys.requiredMaxLevel] = 18,
            [questKeys.nextQuestInChain] = 26209,
        },
        [28563] = { -- Hero's Call: Redridge Mountains!
            [questKeys.requiredMaxLevel] = 18,
            [questKeys.nextQuestInChain] = 26503,
            [questKeys.exclusiveTo] = {26365},
        },
        [28564] = { -- Hero's Call: Duskwood!
            [questKeys.requiredMaxLevel] = 23,
            [questKeys.nextQuestInChain] = 26618,
        },
        [28565] = { -- Hero's Call: Wetlands!
            [questKeys.nextQuestInChain] = 25395,
            [questKeys.requiredMaxLevel] = 23,
        },
        [28567] = { -- Hero's Call: Loch Modan!
            [questKeys.requiredMaxLevel] = 18,
            [questKeys.exclusiveTo] = {26131},
            [questKeys.nextQuestInChain] = 26854,
        },
        [28568] = { -- Warchief's Command: Silverpine Forest!
            [questKeys.exclusiveTo] = {26964,26965},
            [questKeys.requiredMaxLevel] = 18,
        },
        [28571] = { -- Warchief's Command: Hillsbrad Foothills!
            [questKeys.exclusiveTo] = {28096},
            [questKeys.requiredMaxLevel] = 23,
        },
        [28572] = { -- Warchief's Command: Arathi Highlands!
            [questKeys.requiredMaxLevel] = 28,
        },
        [28573] = { -- Hero's Call: Arathi Highlands!
            [questKeys.requiredMaxLevel] = 28,
            [questKeys.nextQuestInChain] = 26093,
        },
        [28574] = { -- Warchief's Command: The Hinterlands!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28575] = { -- Warchief's Command: Western Plaguelands!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28576] = { -- Hero's Call: Western Plaguelands!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28577] = { -- Warchief's Command: Eastern Plaguelands!
            [questKeys.requiredMaxLevel] = 43,
        },
        [28578] = { -- Hero's Call: Eastern Plaguelands!
            [questKeys.requiredMaxLevel] = 43,
        },
        [28579] = { -- Hero's Call: Badlands!
            [questKeys.nextQuestInChain] = 27762,
            [questKeys.requiredMaxLevel] = 46,
        },
        [28580] = { -- Warchief's Command: Badlands!
            [questKeys.requiredMaxLevel] = 47,
            [questKeys.nextQuestInChain] = 27762,
        },
        [28581] = { -- Warchief's Command: Searing Gorge!
            [questKeys.startedBy] = {nil,{207324,207325}},
            [questKeys.requiredMaxLevel] = 48,
        },
        [28582] = { -- Hero's Call: Searing Gorge!
            [questKeys.requiredMaxLevel] = 48,
        },
        [28584] = { -- Quality Construction
            [questKeys.preQuestSingle] = {28583},
            [questKeys.objectives] = {nil,{{207298}}},
        },
        [28586] = { -- Pool Pony Rescue
            [questKeys.preQuestSingle] = {28583},
            [questKeys.objectives] = {{{49548,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28589] = { -- Everything But the Kitchen Sink
            [questKeys.objectives] = {{{49680,nil,Questie.ICON_TYPE_MOUNT_UP},{49683}}},
        },
        [28591] = { -- Off the Wall
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 49135}}}},
        },
        [28592] = { -- Parting Packages
            [questKeys.preQuestSingle] = {28591},
            [questKeys.objectives] = {{{49381,nil,Questie.ICON_TYPE_EVENT},{49380,nil,Questie.ICON_TYPE_EVENT},{49144,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28593] = { -- Of Utmost Importance
            [questKeys.startedBy] = {{49000,49378}},
            [questKeys.exclusiveTo] = {},
        },
        [28594] = { -- Highbank, Crybank
            [questKeys.startedBy] = {{49000,49378}},
            [questKeys.exclusiveTo] = {},
        },
        [28595] = { -- Krazz Works!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28592,28593,28594},
            [questKeys.startedBy] = {{49000,49378}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 50268}}}},
        },
        [28597] = { -- Burnin' at Both Ends
            [questKeys.preQuestSingle] = {28596},
        },
        [28598] = { -- Burnin' at Both Ends
            [questKeys.objectives] = {nil,{{207277,nil,Questie.ICON_TYPE_EVENT}},nil,nil,{{{49212},49212}}},
        },
        [28602] = { -- Be Prepared
            [questKeys.preQuestSingle] = {27541},
        },
        [28606] = { -- The Keys to the Hot Rod
            [questKeys.startedBy] = {{34874}},
            [questKeys.parentQuest] = 14071,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28607] = { -- The Keys to the Hot Rod
            [questKeys.parentQuest] = 14121,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28611] = { -- The Defilers' Ritual
            [questKeys.extraObjectives] = {{{[zoneIDs.ULDUM]={{52.08,40.04}}}, Questie.ICON_TYPE_EVENT, l10n("Dive into the underwater cave")}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27836,27837},
        },
        [28612] = { -- Harrison Jones and the Temple of Uldum
            [questKeys.objectives] = {nil,{{205939}}},
            [questKeys.zoneOrSort] = 989,
        },
        [28613] = { -- See You on the Other Side!
            [questKeys.zoneOrSort] = 989,
        },
        [28622] = { -- Three if by Air
            [questKeys.objectives] = {{{49211,nil,Questie.ICON_TYPE_EVENT},{49215,nil,Questie.ICON_TYPE_EVENT},{49216,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28624] = { -- Kilram's Boast
            [questKeys.preQuestSingle] = {28618},
        },
        [28627] = { -- Seril's Boast
            [questKeys.preQuestSingle] = {28624},
        },
        [28629] = { -- Are We There, Yeti?
            [questKeys.preQuestSingle] = {28627},
        },
        [28630] = { -- Echo Three
            [questKeys.preQuestSingle] = {28627},
        },
        [28631] = { -- The Perfect Horns
            [questKeys.preQuestSingle] = {28627},
        },
        [28635] = { -- A Haunting in Hillsbrad
            [questKeys.triggerEnd] = {"Search Dun Garok for Evidence of a Haunting", {[zoneIDs.HILLSBRAD_FOOTHILLS]={{61.9,84.5}}}},
        },
        [28640] = { -- Fresh Frostsabers
            [questKeys.preQuestSingle] = {},
        },
        [28649] = { -- A Special Surprise (Worgen)
            [questKeys.preQuestSingle] = {12738},
            [questKeys.nextQuestInChain] = 12751,
        },
        [28650] = { -- A Special Surprise (Goblin)
            [questKeys.preQuestSingle] = {12738},
            [questKeys.nextQuestInChain] = 12751,
        },
        [28651] = { -- Novice Elreth
            [questKeys.startedBy] = {{2119,2122,2123,2124,2126,38911}},
            [questKeys.exclusiveTo] = {24961},
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [28652] = { -- Caretaker Caice
            [questKeys.exclusiveTo] = {24960},
        },
        [28653] = { -- Shadow Priest Sarvis
            [questKeys.exclusiveTo] = {26801},
            [questKeys.requiredRaces] = raceKeys.UNDEAD,
        },
        [28655] = { -- Wild, Wild, Wildhammer Wedding
            [questKeys.preQuestGroup] = {28408,28409,28410,28411},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the wedding!"),0,{{"monster",48368}}}},
        },
        [28659] = { -- The Leftovers
            [questKeys.objectives] = {nil,nil,nil,nil,{{{47595,47598,47599,47600},47595}}},
        },
        [28666] = { -- Hero's Call: Burning Steppes!
            [questKeys.nextQuestInChain] = 28174,
            [questKeys.requiredMaxLevel] = 50,
        },
        [28667] = { -- Warchief's Command: Burning Steppes!
            [questKeys.requiredMaxLevel] = 51,
        },
        [28671] = { -- Warchief's Command: Blasted Lands!
            [questKeys.startedBy] = {nil,{207324,207325}},
            [questKeys.requiredMaxLevel] = 57,
        },
        [28673] = { -- Hero's Call: Blasted Lands!
            [questKeys.requiredMaxLevel] = 57,
            [questKeys.exclusiveTo] = {28857,28867},
            [questKeys.nextQuestInChain] = 25710,
        },
        [28674] = { -- Starfall Village
            [questKeys.preQuestGroup] = {28722,28628},
            [questKeys.nextQuestInChain] = 28701,
        },
        [28675] = { -- Hero's Call: Swamp of Sorrows!
            [questKeys.requiredMaxLevel] = 52,
        },
        [28677] = { -- Warchief's Command: Swamp of Sorrows!
            [questKeys.requiredMaxLevel] = 53,
        },
        [28678] = { -- Captain P. Harris
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28679] = { -- Rattling Their Cages
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28680] = { -- Boosting Morale
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28681] = { -- Shark Tank
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28682] = { -- Claiming The Keep
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28683] = { -- Thinning the Brood
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28684] = { -- A Sticky Task
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28685] = { -- Leave No Weapon Behind
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28686] = { -- Not The Friendliest Town
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28687] = { -- Teach A Man To Fish.... Or Steal
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28688] = { -- Warchief's Command: Northern Stranglethorn Vale!
            [questKeys.requiredMaxLevel] = 28,
        },
        [28689] = { -- The Forgotten
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28690] = { -- Salvaging the Remains
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28691] = { -- First Lieutenant Connor
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28692] = { -- Magnets, How Do They Work?
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28693] = { -- Finish The Job
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28694] = { -- Watch Out For Splinters!
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28695] = { -- WANTED: Foreman Wellson
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28696] = { -- Bombs Away!
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the cannon"),0,{{"monster",48283}}}},
        },
        [28697] = { -- Ghostbuster
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28698] = { -- Cannonball!
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28699] = { -- Hero's Call: Northern Stranglethorn Vale!
            [questKeys.nextQuestInChain] = 26735,
            [questKeys.requiredMaxLevel] = 28,
        },
        [28700] = { -- Taking the Overlook Back
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28702] = { -- Hero's Call: The Cape of Stranglethorn!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28704] = { -- Warchief's Command: The Cape of Stranglethorn!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28705] = { -- Warchief's Command: Outland!
            [questKeys.requiredMaxLevel] = 67,
        },
        [28708] = { -- Hero's Call: Outland!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.requiredMaxLevel] = 67,
        },
        [28709] = { -- Hero's Call: Northrend!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.requiredMaxLevel] = 77,
            [questKeys.nextQuestInChain] = 11672,
        },
        [28711] = { -- Warchief's Command: Northrend!
            [questKeys.requiredMaxLevel] = 77,
        },
        [28712] = { -- Enter the Dragon Queen
            [questKeys.preQuestSingle] = {28093,28109},
        },
        [28713] = { -- The Balance of Nature
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28714] = { -- Fel Moss Corruption
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28715] = { -- Demonic Thieves
            [questKeys.preQuestSingle] = {28713},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28716] = { -- Hero's Call: Twilight Highlands!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.finishedBy] = {{29611}},
            [questKeys.nextQuestInChain] = 26960,
        },
        [28717] = { -- Warchief's Command: Twilight Highlands!
            [questKeys.finishedBy] = {{39605}},
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
            [questKeys.nextQuestInChain] = 26293,
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [28718] = { -- Where There's Smoke, There's Delicious Meat
            [questKeys.nextQuestInChain] = 28640,
        },
        [28721] = { -- Walk A Mile In Their Shoes
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28723] = { -- Priestess of the Moon
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.startedBy] = {{3593,3594,3595,3596,3597,43006}},
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28724] = { -- Iverron's Antidote
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28725] = { -- The Woodland Protector
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28726] = { -- Webwood Corruption
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28727] = { -- Vile Touch
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28728] = { -- Signs of Things to Come
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28729] = { -- Teldrassil: Crown of Azeroth
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28730] = { -- Precious Waters
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28731] = { -- Teldrassil: Passing Awareness
            [questKeys.requiredRaces] = raceKeys.NIGHT_ELF,
            [questKeys.requiredClasses] = classKeys.WARRIOR + classKeys.HUNTER + classKeys.MAGE + classKeys.DRUID + classKeys.ROGUE + classKeys.PRIEST, -- night elf DKs don't get these quests
        },
        [28732] = { -- This Can Only Mean One Thing...
            [questKeys.objectives] = {{{49456,nil,Questie.ICON_TYPE_EVENT},{49456,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 28735,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Get in"),0,{{"object",207327}}}},
            [questKeys.objectivesText] = {"Take Pip's Mole Machine to Blackrock Mountain."},
        },
        [28734] = { -- A Favor for Melithar
            [questKeys.exclusiveTo] = {28715},
            [questKeys.nextQuestInChain] = 28715,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28735] = { -- To the Chamber of Incineration!
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 28737,
        },
        [28736] = { -- Fire From the Sky
            [questKeys.preQuestSingle] = {28613},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 49499}}}},
            [questKeys.zoneOrSort] = 989,
        },
        [28737] = { -- What Is This Place?
            [questKeys.nextQuestInChain] = 28738,
        },
        [28738] = { -- The Twilight Forge
            [questKeys.nextQuestInChain] = 28740,
        },
        [28741] = { -- Ascendant Lord Obsidius
            [questKeys.preQuestSingle] = {28738},
        },
        [28745] = { -- Screechy Keen
            [questKeys.preQuestSingle] = {28638},
        },
        [28755] = { -- Annals of the Silver Hand
            [questKeys.preQuestSingle] = {27464},
            [questKeys.requiredMaxRep] = {529,42999},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28756] = { -- Aberrations of Bone
            [questKeys.objectives] = {{{11622}}},
            [questKeys.preQuestSingle] = {27464},
            [questKeys.requiredMaxRep] = {529,42999},
            [questKeys.zoneOrSort] = zoneIDs.SCHOLOMANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28757] = { -- Beating Them Back! -- Human Mage
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28769,
        },
        [28758] = { -- Battle of Life and Death
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 49910}}}},
        },
        [28759] = { -- Lions for Lambs -- Human Hunter
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 26910,
        },
        [28762] = { -- Beating Them Back! -- Human Paladin
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28770,
        },
        [28763] = { -- Beating Them Back! -- Human Priest
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28771,
        },
        [28764] = { -- Beating Them Back! -- Human Rogue
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28772,
        },
        [28765] = { -- Beating Them Back! -- Human Warlock
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28773,
        },
        [28766] = { -- Beating Them Back! -- Human Warrior
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28774,
        },
        [28767] = { -- Beating Them Back! -- Human Hunter
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.nextQuestInChain] = 28759,
        },
        [28768] = { -- Winterspring!
            [questKeys.exclusiveTo] = {28524,28544,28545},
            [questKeys.nextQuestInChain] = 28460,
            [questKeys.requiredMaxLevel] = 53,
        },
        [28769] = { -- Lions for Lambs -- Human Mage
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            --[questKeys.nextQuestInChain] = 3104, -- removing this key because some chars did these class quests before the prepatch
        },
        [28770] = { -- Lions for Lambs -- Human Paladin
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            --[questKeys.nextQuestInChain] = 3101, -- removing this key because some chars did these class quests before the prepatch
        },
        [28771] = { -- Lions for Lambs -- Human Priest
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            --[questKeys.nextQuestInChain] = 3103, -- removing this key because some chars did these class quests before the prepatch
        },
        [28772] = { -- Lions for Lambs -- Human Rogue
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            --[questKeys.nextQuestInChain] = 3102, -- removing this key because some chars did these class quests before the prepatch
        },
        [28773] = { -- Lions for Lambs -- Human Warlock
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            --[questKeys.nextQuestInChain] = 3105, -- removing this key because some chars did these class quests before the prepatch
        },
        [28774] = { -- Lions for Lambs -- Human Warrior
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            --[questKeys.nextQuestInChain] = 3100, -- removing this key because some chars did these class quests before the prepatch
        },
        [28780] = { -- Join the Battle! -- Human Hunter
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28784] = { -- Join the Battle! -- Human Mage
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28785] = { -- Join the Battle! -- Human Paladin
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28786] = { -- Join the Battle! -- Human Priest
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28787] = { -- Join the Battle! -- Human Rogue
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28788] = { -- Join the Battle! -- Human Warlock
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28789] = { -- Join the Battle! -- Human Warrior
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28790] = { -- A Personal Summons
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.startedBy] = {{100003}},
        },
        [28791] = { -- They Sent Assassins -- Human Hunter
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28792] = { -- They Sent Assassins -- Human Mage
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28793] = { -- They Sent Assassins -- Human Paladin
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28794] = { -- They Sent Assassins -- Human Priest
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28795] = { -- They Sent Assassins -- Human Rogue
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28796] = { -- They Sent Assassins -- Human Warlock
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28797] = { -- They Sent Assassins -- Human Warrior
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28798] = { -- Waters of Elune
            [questKeys.requiredLevel] = 77,
        },
        [28799] = { -- Might of the Earthen
            [questKeys.requiredLevel] = 80,
        },
        [28800] = { -- Whispers of the Djinn
            [questKeys.requiredLevel] = 80,
        },
        [28801] = { -- Tol'vir Heiroglyphics
            [questKeys.requiredLevel] = 83,
        },
        [28802] = { -- Map of the Architects
            [questKeys.requiredLevel] = 83,
        },
        [28803] = { -- Vengeance of the Wildhammer
            [questKeys.requiredLevel] = 83,
        },
        [28804] = { -- Dark Iron Contingency Plan
            [questKeys.requiredLevel] = 77,
        },
        [28805] = { -- The Eye of the Storm
            [questKeys.objectives] = {nil,{{207414}}},
        },
        [28806] = { -- Fear No Evil -- Human Hunter
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28807] = { -- Expert Opinion
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27060,27064},
        },
        [28808] = { -- Fear No Evil -- Human Mage
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28809] = { -- Fear No Evil -- Human Paladin
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {28785},
        },
        [28810] = { -- Fear No Evil -- Human Priest
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28811] = { -- Fear No Evil -- Human Rogue
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28812] = { -- Fear No Evil -- Human Warlock
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28813] = { -- Fear No Evil -- Human Warrior
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.requiredClasses] = classKeys.WARRIOR,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {28789},
        },
        [28816] = { -- To the Depths
            [questKeys.requiredMaxLevel] = 81,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.nextQuestInChain] = 25924,
        },
        [28817] = { -- The Rear is Clear -- Human Hunter
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28818] = { -- The Rear is Clear -- Human Mage
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28819] = { -- The Rear is Clear -- Human Paladin
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28820] = { -- The Rear is Clear -- Human Priest
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28821] = { -- The Rear is Clear -- Human Rogue
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28822] = { -- The Rear is Clear -- Human Warlock
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28823] = { -- The Rear is Clear -- Human Warrior
            [questKeys.requiredRaces] = raceKeys.HUMAN,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [28824] = { -- Wayward Child
            [questKeys.preQuestSingle] = {26871},
        },
        [28825] = { -- A Personal Summons
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.startedBy] = {{100002}},
        },
        [28826] = { -- The Eye of the Storm
            [questKeys.objectives] = {nil,{{207416}}},
        },
        [28827] = { -- To the Depths
            [questKeys.requiredMaxLevel] = 81,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.nextQuestInChain] = 14482,
        },
        [28830] = { -- Chips off the Old Block
            [questKeys.preQuestSingle] = {28829},
        },
        [28831] = { -- Damn You, Frostilicus
            [questKeys.preQuestSingle] = {28829},
        },
        [28832] = { -- Twilight Shores
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 50262}}}},
        },
        [28838] = { -- The Owlbeasts' Defense
            [questKeys.preQuestSingle] = {28837},
        },
        [28841] = { -- The Arcane Storm Within
            [questKeys.preQuestSingle] = {28840},
        },
        [28842] = { -- Umbranse's Deliverance
            [questKeys.preQuestSingle] = {28840},
        },
        [28845] = { -- The Vortex Pinnacle
            [questKeys.exclusiveTo] = {28760,28779},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27520,27519,27706},
        },
        [28847] = { -- The Pursuit of Umbranse
            [questKeys.preQuestGroup] = {28537,28628,28722},
        },
        [28849] = { -- Twilight Skies
            [questKeys.preQuestGroup] = {26337,26372,26374},
            [questKeys.exclusiveTo] = {},
        },
        [28856] = { -- The Sands of Silithus
            [questKeys.nextQuestInChain] = 8280,
        },
        [28857] = { -- Hero's Call: Blasted Lands!
            [questKeys.exclusiveTo] = {28673,28867},
            [questKeys.nextQuestInChain] = 25710,
        },
        [28859] = { -- The Dunes of Silithus
            [questKeys.nextQuestInChain] = 8280,
        },
        [28860] = { -- Keeping the Dragonmaw at Bay
            [questKeys.preQuestSingle] = {28655},
        },
        [28861] = { -- Fight Like a Wildhammer
            [questKeys.preQuestSingle] = {28655},
        },
        [28862] = { -- Never Leave a Dinner Behind
            [questKeys.preQuestSingle] = {28655},
            [questKeys.finishedBy] = {{48010}},
        },
        [28863] = { -- Warlord Halthar is Back
            [questKeys.preQuestSingle] = {28655},
        },
        [28864] = { -- Beer Run
            [questKeys.preQuestSingle] = {28655},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 48758}}}},
            [questKeys.triggerEnd] = {"Supply Caravan Escorted",{[zoneIDs.TWILIGHT_HIGHLANDS]={{56.05,20.4}}}},
            [questKeys.objectives] = {},
        },
        [28866] = { -- Into the Stonecore
            [questKeys.preQuestSingle] = {27061},
        },
        [28867] = { -- Nethergarde Needs You!
            [questKeys.exclusiveTo] = {28857,28673},
            [questKeys.nextQuestInChain] = 25710,
        },
        [28868] = { -- The View from Down Here
            [questKeys.preQuestSingle] = {25839},
            [questKeys.objectives] = {{{41251,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28869] = { -- Pebble
            [questKeys.nextQuestInChain] = 26440,
            [questKeys.preQuestSingle] = {26439},
        },
        [28870] = { -- Return to the Lost City
            [questKeys.preQuestSingle] = {28520},
            [questKeys.nextQuestInChain] = 28783,
        },
        [28871] = { -- Crushing the Wildhammer
            [questKeys.preQuestSingle] = {28133},
        },
        [28872] = { -- Total War
            [questKeys.objectives] = {nil,{{206195}}},
            [questKeys.preQuestSingle] = {28133},
        },
        [28873] = { -- Another Maw to Feed
            [questKeys.preQuestSingle] = {28133},
        },
        [28874] = { -- Hook 'em High
            [questKeys.preQuestSingle] = {28133},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Throw the Barbed Fleshhook at them"), 0, {{"monster", 47186}}}},
        },
        [28875] = { -- Bring Down the High Shaman
            [questKeys.preQuestSingle] = {28133},
        },
        [28882] = { -- Victory in Tol Barad
            [questKeys.triggerEnd] = {"Victory in Tol Barad",{[zoneIDs.TOL_BARAD]={{51.1,49.9}}}},
        },
        [28884] = { -- Victory in Tol Barad
            [questKeys.triggerEnd] = {"Victory in Tol Barad",{[zoneIDs.TOL_BARAD]={{51.1,49.9}}}},
        },
        [28885] = { -- Mr. Goldmine's Wild Ride
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27703,27798},
            [questKeys.objectives] = {{{46243,nil,Questie.ICON_TYPE_TALK},{46459,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28909] = { -- Sauranok Will Point the Way
            [questKeys.startedBy] = {{39605}},
            [questKeys.preQuestSingle] = {26294},
            [questKeys.nextQuestInChain] = 26311,
        },
        [29030] = { -- Honor the Flame
            [questKeys.objectives] = {nil,{{208184}}},
        },
        [29031] = { -- Honor the Flame
            [questKeys.objectives] = {nil,{{208187}}},
        },
        [29034] = { -- They Grow Up So Fast
            --[questKeys.childQuests] = {29035,29037,29038,29039,29040,29051,29052,29053}, -- this is the full list, but some quests are blacklisted for now
            [questKeys.childQuests] = {29039,29051,29052,29053},
        },
        [29035] = { -- A Cub's Cravings
            [questKeys.startedBy] = {}, -- we need this too, even while blacklisted, or it shows due to childQuests logic
            [questKeys.requiredSourceItems] = {12622},
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.DRAENEI + raceKeys.GNOME + raceKeys.NIGHT_ELF, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29037,29038,29039,29040,29051,29052,29053},
        },
        [29036] = { -- Honor the Flame
            [questKeys.objectives] = {nil,{{208188}}},
        },
        [29037] = { -- 'Borrowing' From the Winterfall
            [questKeys.requiredSourceItems] = {68645},
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.startedBy] = {}, -- we need this too, even while blacklisted, or it shows due to childQuests logic
            --[questKeys.requiredRaces] = raceKeys.DRAENEI + raceKeys.GNOME + raceKeys.NIGHT_ELF, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29038,29039,29040,29051,29052,29053},
        },
        [29038] = { -- Hunting Practice
            [questKeys.startedBy] = {}, -- we need this too, even while blacklisted, or it shows due to childQuests logic
            [questKeys.objectives] = {{{51711,nil,Questie.ICON_TYPE_EVENT}}},
            --[questKeys.requiredRaces] = raceKeys.DRAENEI + raceKeys.GNOME + raceKeys.NIGHT_ELF, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29037,29039,29040,29051,29052,29053},
        },
        [29039] = { -- Hunting Practice
            [questKeys.objectives] = {{{51711,nil,Questie.ICON_TYPE_EVENT}}},
            --[questKeys.requiredRaces] = raceKeys.HUMAN + raceKeys.DWARF + raceKeys.WORGEN, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29037,29038,29040,29051,29052,29053},
        },
        [29040] = { -- Cub's First Toy
            [questKeys.startedBy] = {}, -- we need this too, even while blacklisted, or it shows due to childQuests logic
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.DRAENEI + raceKeys.GNOME + raceKeys.NIGHT_ELF, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.requiredSourceItems] = {68662,68663,68668},
            [questKeys.exclusiveTo] = {29035,29037,29038,29039,29051,29052,29053},
        },
        [29051] = { -- Cub's First Toy
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.HUMAN + raceKeys.DWARF + raceKeys.WORGEN, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.requiredSourceItems] = {68662,68663,68668},
            [questKeys.exclusiveTo] = {29035,29037,29038,29039,29040,29052,29053},
        },
        [29052] = { -- A Cub's Cravings
            [questKeys.requiredSourceItems] = {12622},
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.HUMAN + raceKeys.DWARF + raceKeys.WORGEN, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29037,29038,29039,29040,29051,29053},
        },
        [29053] = { -- 'Borrowing' From the Winterfall
            [questKeys.requiredSourceItems] = {68645},
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.HUMAN + raceKeys.DWARF + raceKeys.WORGEN, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29037,29038,29039,29040,29051,29052},
        },
        [29054] = { -- Stink Bombs Away!
            [questKeys.objectives] = {nil,{{180449,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the bombing run"),0,{{"monster",52548}}}},
        },
        [29066] = { -- Good News... and Bad News
            [questKeys.startedBy] = {},
            [questKeys.preQuestSingle] = {25428},
            [questKeys.nextQuestInChain] = 25830,
        },
        [29067] = { -- Potion Master
            [questKeys.name] = "Potion Master",
            [questKeys.objectivesText] = {"Bring a large supply of potions to an alchemy trainer in any capital city."},
            [questKeys.objectives] = {nil,nil,{{57191},{57192},{58488}}},
            [questKeys.exclusiveTo] = {10897,10899,10902,29481,29482},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29071] = { -- Make Haste to Stormwind!
            [questKeys.exclusiveTo] = {25316}, -- it's not this one, needs to be discovered the actual one. Also no HS to Dalaran, that's silly
        },
        [29073] = { -- Make Haste to Orgrimmar!
            [questKeys.exclusiveTo] = {25316}, -- same as above
        },
        [29074] = { -- A Season for Celebration
            [questKeys.startedBy] = {{20102}},
        },
        [29075] = { -- A Time to Gain
            [questKeys.objectives] = {nil,{{208186}}},
            [questKeys.preQuestSingle] = {},
        },
        [29078] = { -- Beating Them Back! -- non Human
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.HUMAN,
            [questKeys.requiredClasses] = classKeys.NONE,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [29079] = { -- Lions for Lambs -- non Human
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.HUMAN,
            [questKeys.requiredClasses] = classKeys.NONE,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [29080] = { -- Join the Battle! -- non Human
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.HUMAN,
            [questKeys.requiredClasses] = classKeys.NONE,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [29081] = { -- They Sent Assassins -- non Human
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.HUMAN,
            [questKeys.requiredClasses] = classKeys.NONE,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [29082] = { -- Fear No Evil -- non Human
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.HUMAN,
            [questKeys.requiredClasses] = classKeys.NONE,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
            [questKeys.objectives] = {{{50047,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29083] = { -- The Rear is Clear -- non Human
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE - raceKeys.HUMAN,
            [questKeys.requiredClasses] = classKeys.NONE,
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST,
        },
        [29092] = { -- Inform the Elder
            [questKeys.preQuestSingle] = {11891},
            [questKeys.exclusiveTo] = {12012},
            [questKeys.startedBy] = {{25324}},
        },
        [29093] = { -- Cruisin' the Chasm
            [questKeys.objectives] = {{{52189,"Chopper Tour of the Raging Chasm",Questie.ICON_TYPE_MOUNT_UP}}},
            [questKeys.preQuestSingle] = {1468},
        },
        [29100] = { -- Bwemba's Spirit
            [questKeys.preQuestSingle] = {},
            [questKeys.childQuests] = {29102,29103,29104,29105,29114,29115,29116,29118,29120,29121,29124,29131,29133,29150,29151,29152,29213,29267},
            [questKeys.objectives] = {{{52767,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29101] = { -- Punting Season
            [questKeys.objectives] = {nil,nil,nil,nil,{{{52218,52177},52177,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {29125,29147,29161,29164},
        },
        [29102] = { -- To Fort Livingston
            [questKeys.objectives] = {{{52281,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.parentQuest] = 29100,
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 29103,
        },
        [29103] = { -- Serpents and Poison
            [questKeys.parentQuest] = 29100,
            [questKeys.objectives] = {{{52224}},nil,nil,nil,{{{52225,52279,52280,53555,53556,53557},52225,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29104,
        },
        [29104] = { -- Spirits Are With Us
            [questKeys.parentQuest] = 29100,
            [questKeys.objectives] = {nil,{{460010}}},
            [questKeys.nextQuestInChain] = 29105,
        },
        [29105] = { -- Nesingwary Will Know
            [questKeys.parentQuest] = 29100,
            [questKeys.objectives] = {{{52294,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.nextQuestInChain] = 29114,
        },
        [29106] = { -- The Biggest Diamond Ever!
            [questKeys.triggerEnd] = {"Visit King Magni in Old Ironforge", {[zoneIDs.IRONFORGE]={{33.17,47.65}}}},
            [questKeys.preQuestSingle] = {1468},
        },
        [29107] = { -- Malfurion Has Returned!
            [questKeys.objectives] = {{{43845,"Visit Malfurion Stormrage with your orphan",Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {1468},
        },
        [29114] = { -- Track the Tracker
            [questKeys.parentQuest] = 29100,
            [questKeys.nextQuestInChain] = 29115,
        },
        [29115] = { -- The Hunter's Revenge
            [questKeys.parentQuest] = 29100,
            [questKeys.finishedBy] = {{100022}},
            [questKeys.objectives] = {{{52349,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29116,
        },
        [29116] = { -- Follow That Cat
            [questKeys.parentQuest] = 29100,
            [questKeys.startedBy] = {{100023}},
            [questKeys.exclusiveTo] = {29118},
            [questKeys.objectives] = {{{52911,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29120,
        },
        [29117] = { -- Let's Go Fly a Kite
            [questKeys.triggerEnd] = {"Fly Dragon Kites with your orphan", {[zoneIDs.STORMWIND_CITY]={{59.2,63.4}}}},
            [questKeys.preQuestGroup] = {29093,29106,29107},
            [questKeys.requiredSourceItems] = {68890},
        },
        [29118] = { -- Follow That Cat
            [questKeys.parentQuest] = 29100,
            [questKeys.exclusiveTo] = {29116},
            [questKeys.preQuestSingle] = {29115},
            [questKeys.objectives] = {{{52911,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29120,
        },
        [29119] = { -- You Scream, I Scream...
            [questKeys.triggerEnd] = {"Take your orphan out for ice cream.", {[zoneIDs.STORMWIND_CITY]={{49.28,89.8}}}},
            [questKeys.preQuestGroup] = {29093,29106,29107},
            [questKeys.requiredSourceItems] = {69027},
        },
        [29120] = { -- Mauti
            [questKeys.parentQuest] = 29100,
            [questKeys.objectives] = {{{52372,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29213,
        },
        [29121] = { -- Bury Me With Me Boots...
            [questKeys.parentQuest] = 29100,
            [questKeys.nextQuestInChain] = 29124,
        },
        [29122] = { -- Echoes of Nemesis
            [questKeys.startedBy] = {{52671}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak with Torga"),0,{{"monster",52425}}}},
        },
        [29123] = { -- Rage Against the Flames
            [questKeys.exclusiveTo] = {29127,29149,29163,29166,29246,29247,29248},
        },
        [29124] = { -- Warn the Rebel Camp
            [questKeys.parentQuest] = 29100,
            [questKeys.preQuestSingle] = {29121},
            [questKeys.nextQuestInChain] = 29131,
        },
        [29125] = { -- Between the Trees
            [questKeys.exclusiveTo] = {29101,29147,29161,29164},
            [questKeys.objectives] = {{{52176,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29126] = { -- The Power of Malorne
            [questKeys.startedBy] = {{52669}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Summon Galenges"),0,{{"object",208381}}}},
        },
        [29127] = { -- Rage Against the Flames
            [questKeys.exclusiveTo] = {29123,29149,29163,29166,29246,29247,29248},
        },
        [29129] = { -- A Legendary Engagement
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Ziradormi"),0,{{"monster",52382}}}},
            [questKeys.requiredClasses] = classKeys.SHAMAN + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [29131] = { -- Defend the Rebel Camp
            [questKeys.parentQuest] = 29100,
            [questKeys.triggerEnd] = {"Help Defend the Camp", {[zoneIDs.STRANGLETHORN_VALE]={{47.55,11.22}}}},
            [questKeys.nextQuestInChain] = 29133,
        },
        [29132] = { -- A Legendary Engagement
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Coridormi"),0,{{"monster",52408}}}},
            [questKeys.requiredClasses] = classKeys.SHAMAN + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [29133] = { -- To the Digsite
            [questKeys.parentQuest] = 29100,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take a ride"),0,{{"monster",52753}}}},
            [questKeys.objectives] = {{{52762,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29150,
        },
        [29134] = { -- A Wrinkle in Time
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Anachronos"),0,{{"monster",15192}}}},
            [questKeys.requiredClasses] = classKeys.SHAMAN + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [29135] = { -- All-Seeing Eye
            [questKeys.requiredClasses] = classKeys.SHAMAN + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [29137] = { -- Breach in the Defenses
            [questKeys.preQuestSingle] = {29201},
            [questKeys.exclusiveTo] = {29141,29142,29304},
        },
        [29138] = { -- Burn Victims
            [questKeys.preQuestSingle] = {29201},
            [questKeys.objectives] = {{{52834,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29139] = { -- Aggressive Growth
            [questKeys.objectives] = {nil,{{208545}}},
            [questKeys.preQuestSingle] = {29201},
            [questKeys.exclusiveTo] = {29143},
        },
        [29141] = { -- The Harder They Fall
            [questKeys.preQuestSingle] = {29201},
            [questKeys.exclusiveTo] = {29137,29142,29304},
        },
        [29142] = { -- Traitors Return
            [questKeys.preQuestSingle] = {29201},
            [questKeys.exclusiveTo] = {29137,29141,29304},
        },
        [29143] = { -- Wisp Away
            [questKeys.objectives] = {{{52531,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {29201},
            [questKeys.exclusiveTo] = {29139},
        },
        [29144] = { -- Clean Up in Stormwind
            [questKeys.objectives] = {nil,{{195122,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29145] = { -- Opening the Door
            [questKeys.preQuestSingle] = {25372},
        },
        [29146] = { -- Ridin' the Rocketway
            [questKeys.objectives] = {{{52585,nil,Questie.ICON_TYPE_MOUNT_UP}}},
            [questKeys.preQuestSingle] = {172},
        },
        [29147] = { -- Call the Flock
            [questKeys.objectives] = {{{52595,nil,Questie.ICON_TYPE_INTERACT},{52596,nil,Questie.ICON_TYPE_INTERACT},{52594,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {29101,29125,29161,29164},
        },
        [29148] = { -- Wings Aflame
            [questKeys.startedBy] = {{52669}},
        },
        [29149] = { -- Rage Against the Flames
            [questKeys.exclusiveTo] = {29123,29127,29163,29166,29246,29247,29248},
        },
        [29150] = { -- Voodoo Zombies
            [questKeys.parentQuest] = 29100,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{52604,52870},52604}}},
            [questKeys.nextQuestInChain] = 29151,
        },
        [29151] = { -- Bad Supplies
            [questKeys.parentQuest] = 29100,
            [questKeys.objectives] = {nil,{{460011}}},
            [questKeys.nextQuestInChain] = 29152,
        },
        [29152] = { -- Making Contact
            [questKeys.parentQuest] = 29100,
            [questKeys.nextQuestInChain] = 29153,
        },
        [29153] = { -- Booty Bay's Interests
            [questKeys.preQuestSingle] = {29152},
        },
        [29156] = { -- The Troll Incursion
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
        },
        [29157] = { -- The Zandalari Menace
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
        },
        [29160] = { -- Egg-stinction
            [questKeys.exclusiveTo] = {29189},
            [questKeys.preQuestSingle] = {29205},
        },
        [29161] = { -- Those Bears Up There
            [questKeys.objectives] = {{{52688,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Climb the tree"),0,{{"monster",52676}}}},
            [questKeys.exclusiveTo] = {29101,29125,29147,29164},
        },
        [29162] = { -- Nature's Blessing
            [questKeys.startedBy] = {{52669}},
        },
        [29163] = { -- Rage Against the Flames
            [questKeys.exclusiveTo] = {29123,29127,29149,29166,29246,29247,29248},
        },
        [29164] = { -- Perfecting Your Howl
            [questKeys.objectives] = {nil,nil,nil,nil,{{{54362,52816,52795,52300,52289,52794,52791,52219},54362,"Howl atop an invader's corpse",Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {29101,29125,29147,29161},
        },
        [29165] = { -- The Call of the Pack
            [questKeys.startedBy] = {{52669}},
        },
        [29166] = { -- Supplies for the Other Side
            [questKeys.preQuestSingle] = {29198},
            [questKeys.exclusiveTo] = {29123,29127,29149,29163,29246,29247,29248},
        },
        [29167] = { -- The Banshee Queen
            [questKeys.objectives] = {{{10181,"Meeting with Lady Sylvanas Windrunner",Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {172},
        },
        [29176] = { -- The Fallen Chieftain
            [questKeys.triggerEnd] = {"Take Your Orphan to Visit Red Rocks", {[zoneIDs.MULGORE]={{60.7,23.0}}}},
            [questKeys.preQuestSingle] = {172},
        },
        [29177] = { -- Vigilance on Wings
            [questKeys.preQuestSingle] = {25560},
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{40650,40660},40650}}},
        },
        [29179] = { -- Hostile Elements
            [questKeys.preQuestSingle] = {29201},
        },
        [29181] = { -- Druids of the Talon
            [questKeys.objectives] = {nil,{{460014}}},
        },
        [29186] = { -- The Hex Lord's Fetish
            [questKeys.preQuestSingle] = {},
        },
        [29189] = { -- Wicked Webs
            [questKeys.preQuestSingle] = {29205},
            [questKeys.exclusiveTo] = {29160},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{52705,52783,52784,52989,52990,52991,52992,52751},52751}}},
        },
        [29190] = { -- Let's Go Fly a Kite
            [questKeys.triggerEnd] = {"Fly Dragon Kites with your orphan", {[zoneIDs.ORGRIMMAR]={{58.5,58.3}}}},
            [questKeys.preQuestGroup] = {29146,29167,29176},
            [questKeys.requiredSourceItems] = {69231},
        },
        [29191] = { -- You Scream, I Scream...
            [questKeys.triggerEnd] = {"Take your orphan out for ice cream.", {[zoneIDs.ORGRIMMAR]={{38.56,86.7}}}},
            [questKeys.preQuestGroup] = {29146,29167,29176},
            [questKeys.requiredSourceItems] = {69233},
        },
        [29192] = { -- The Wardens are Watching
            [questKeys.exclusiveTo] = {29211},
            [questKeys.preQuestSingle] = {29205},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{52122,52871,52872},52872,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29197] = { -- Caught Unawares
            [questKeys.objectives] = {{{52906,nil,Questie.ICON_TYPE_EVENT},{52907,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{52903,52904},52903,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Defeat Raging Invader"),0,{{"monster",52557}}}},
        },
        [29199] = { -- Calling for Reinforcements
            [questKeys.objectives] = {nil,{{460014}}},
        },
        [29200] = { -- Leyara
            [questKeys.objectives] = {{{53014,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29201] = { -- Through the Gates of Hell
            [questKeys.preQuestSingle] = {29200},
            [questKeys.objectives] = {{{53381}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Go through the portal"),0,{{"object",208900}}}},
            [questKeys.finishedBy] = {{53385}},
        },
        [29202] = { -- The Fate of Runetotem
            [questKeys.preQuestSingle] = {29200},
        },
        [29205] = { -- The Forlorn Spire
            [questKeys.exclusiveTo] = {29206},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29214,29138,29179,29139,29137}, -- 29139 or 29143,29137 or 29141 or 29142 or 29304
            [questKeys.objectives] = {{{52998}}},
        },
        [29206] = { -- Into the Fire
            [questKeys.exclusiveTo] = {29205},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29181,29138,29179,29139,29137}, -- 29139 or 29143,29137 or 29141 or 29142 or 29304
            [questKeys.objectives] = {{{52683}}},
        },
        [29208] = { -- An Old Friend
            [questKeys.preQuestSingle] = {26386,26776},
        },
        [29210] = { -- Enduring the Heat
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29192}, -- 29192 or 29211
            [questKeys.objectives] = {{{53886,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{52889,52885,52888,52890,52886,52887,52884,53887},52889,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29211] = { -- Solar Core Destruction
            [questKeys.preQuestSingle] = {29205},
            [questKeys.objectives] = {nil,{{208474}}},
            [questKeys.exclusiveTo] = {29192},
        },
        [29213] = { -- How's the Hunter Holding Up?
            [questKeys.parentQuest] = 29100,
            [questKeys.nextQuestInChain] = 29121,
        },
        [29214] = { -- The Shadow Wardens
            [questKeys.objectives] = {nil,{{460014}}},
        },
        [29219] = { -- Bwemba's Spirit
            [questKeys.preQuestSingle] = {},
            [questKeys.childQuests] = {29220,29221,29222,29223,29226,29227,29228,29229,29230,29231,29232,29233,29235,29236,29237,29238,29250,29268},
            [questKeys.objectives] = {{{52767,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29220] = { -- To Bambala
            [questKeys.objectives] = {{{52980,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29221,
        },
        [29221] = { -- Serpents and Poison
            [questKeys.objectives] = {{{52224}},nil,nil,nil,{{{52978,53440,53441,53442,53443,53444,53445},53443,"Headhunters healed",Questie.ICON_TYPE_EVENT}}},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29222,
        },
        [29222] = { -- Spirits Are With Us
            [questKeys.objectives] = {nil,{{208508}}},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29223,
        },
        [29223] = { -- Nesingwary Will Know
            [questKeys.objectives] = {{{52294,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29226,
        },
        [29226] = { -- Track the Tracker
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29227,
        },
        [29227] = { -- The Hunter's Revenge
            [questKeys.finishedBy] = {{100022}},
            [questKeys.objectives] = {{{52349,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29228,
        },
        [29228] = { -- Follow That Cat
            [questKeys.startedBy] = {{100023}},
            [questKeys.objectives] = {{{52911,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {29229},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29230,
        },
        [29229] = { -- Follow That Cat
            [questKeys.objectives] = {{{52911,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {29228},
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29230,
        },
        [29230] = { -- Mauti
            [questKeys.parentQuest] = 29219,
            [questKeys.objectives] = {{{52372,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29231,
        },
        [29231] = { -- How's the Hunter Holding Up?
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29232,
        },
        [29232] = { -- Bury Me With Me Boots...
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29233,
        },
        [29233] = { -- Warn Grom'gol
            [questKeys.parentQuest] = 29219,
            [questKeys.preQuestSingle] = {29232},
            [questKeys.nextQuestInChain] = 29235,
        },
        [29235] = { -- Defend Grom'gol
            [questKeys.parentQuest] = 29219,
            [questKeys.triggerEnd] = {"	Help Defend Grom'gol Base Camp", {[zoneIDs.STRANGLETHORN_VALE]={{38.1,50.3}}}},
            [questKeys.nextQuestInChain] = 29236,
        },
        [29236] = { -- To Hardwrench Hideaway
            [questKeys.parentQuest] = 29219,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take a ride"),0,{{"monster",53008}}}},
            [questKeys.objectives] = {{{52762,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29237,
        },
        [29237] = { -- Voodoo Zombies
            [questKeys.parentQuest] = 29219,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{53011,53016},53011}}},
            [questKeys.nextQuestInChain] = 29238,
        },
        [29238] = { -- Bad Supplies
            [questKeys.parentQuest] = 29219,
            [questKeys.objectives] = {nil,{{460012}}},
            [questKeys.nextQuestInChain] = 29250,
        },
        [29243] = { -- Strike at the Heart
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29210,29283,-29205},
        },
        [29245] = { -- The Mysterious Seed
            [questKeys.preQuestSingle] = {29214},
        },
        [29246] = { -- Relieving the Pain
            [questKeys.exclusiveTo] = {29123,29127,29149,29163,29166,29247,29248},
        },
        [29247] = { -- Treating the Wounds
            [questKeys.exclusiveTo] = {29123,29127,29149,29163,29166,29246,29248},
        },
        [29248] = { -- Releasing the Pressure
            [questKeys.exclusiveTo] = {29123,29127,29149,29163,29166,29246,29247},
        },
        [29249] = { -- Planting Season
            [questKeys.objectives] = {nil,{{208537}}},
        },
        [29250] = { -- Making Contact
            [questKeys.parentQuest] = 29219,
            [questKeys.nextQuestInChain] = 29251,
        },
        [29251] = { -- Booty Bay's Interests
            [questKeys.preQuestSingle] = {29250},
        },
        [29254] = { -- Little Lasher
            [questKeys.startedBy] = {{53079}},
        },
        [29255] = { -- Embergris
            [questKeys.exclusiveTo] = {29257,29299},
            [questKeys.preQuestSingle] = {29254},
        },
        [29257] = { -- Steal Magmolias
            [questKeys.exclusiveTo] = {29255,29299},
            [questKeys.preQuestSingle] = {29254},
        },
        [29261] = { -- Zul'Aman Voodoo
            [questKeys.requiredLevel] = 85,
        },
        [29262] = { -- Zul'Gurub Voodoo
            [questKeys.requiredLevel] = 85,
        },
        [29263] = { -- A Bitter Pill
            [questKeys.exclusiveTo] = {29278,29295,29297},
            [questKeys.preQuestSingle] = {29281},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Start the fight"),0,{{"monster",53131}}}},
        },
        [29265] = { -- Fire Flowers
            [questKeys.preQuestSingle] = {29206},
        },
        [29267] = { -- Some Good Will Come
            [questKeys.parentQuest] = 29100,
            [questKeys.preQuestSingle] = {29121},
            [questKeys.startedBy] = {{52374}},
        },
        [29268] = { -- Some Good Will Come
            [questKeys.parentQuest] = 29219,
            [questKeys.preQuestSingle] = {29232},
            [questKeys.startedBy] = {{52374}},
        },
        [29272] = { -- Need... Water... Badly...
            [questKeys.preQuestSingle] = {29206},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the escort"),0,{{"monster",53233}}}},
            [questKeys.objectives] = {{{53234,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29273] = { -- How Hot
            [questKeys.exclusiveTo] = {29274,29275,29276},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {-29206,29272},
            [questKeys.objectives] = {{{53190,nil,Questie.ICON_TYPE_EVENT},{53191,nil,Questie.ICON_TYPE_EVENT},{53192,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29274] = { -- Hounds of Shannox
            [questKeys.exclusiveTo] = {29273,29275,29276},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {-29206,29272},
        },
        [29275] = { -- Fandral's Methods
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29211,29272,-29205}, -- 29211 + 29192
            [questKeys.exclusiveTo] = {29273,29274,29276},
        },
        [29276] = { -- The Flame Spider Queen
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29272,-29205},
            [questKeys.exclusiveTo] = {29273,29274,29275},
        },
        [29278] = { -- Living Obsidium
            [questKeys.exclusiveTo] = {29263,29295,29297},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Make it rain"),0,{{"monster",53373}}}},
        },
        [29279] = { -- Filling the Moonwell
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29181,29214},
            [questKeys.objectives] = {nil,{{460014}}},
        },
        [29280] = { -- Nourishing Waters
            [questKeys.preQuestSingle] = {29279},
        },
        [29281] = { -- Additional Armaments
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29181,29214},
            [questKeys.objectives] = {nil,{{460014}}},
        },
        [29282] = { -- Well Armed
            [questKeys.preQuestSingle] = {29281},
        },
        [29283] = { -- Calling the Ancients
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29181,29214},
            [questKeys.objectives] = {nil,{{460014}}},
        },
        [29284] = { -- Aid of the Ancients
            [questKeys.preQuestSingle] = {29283},
        },
        [29287] = { -- Peaked Interest
            [questKeys.exclusiveTo] = {29288,29290},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29264,29265},
        },
        [29288] = { -- Starting Young
            [questKeys.exclusiveTo] = {29287,29290},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29264,29265},
        },
        [29290] = { -- Fire in the Skies
            [questKeys.exclusiveTo] = {29287,29288},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",53297}}}},
            [questKeys.objectives] = {{{53310}},nil,nil,nil,{{{53477,53478,53479},53479},{{53309,53310,53469,53308},53308}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29264,29265},
        },
        [29293] = { -- Singed Wings
            [questKeys.exclusiveTo] = {29296},
            [questKeys.objectives] = {{{53243,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29264,29265},
        },
        [29295] = { -- The Bigger They Are
            [questKeys.exclusiveTo] = {29263,29278,29297},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {-29206,29281,29265,29264}, -- need to check if both 29264 and 29265 are required. turn in 29264 first, see if 29265 is needed
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill them to spawn the chips"),0,{{"monster",52107}}}},
        },
        [29296] = { -- Territorial Birds
            [questKeys.exclusiveTo] = {29293},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29264,29265},
        },
        [29297] = { -- Bye Bye Burdy
            [questKeys.exclusiveTo] = {29263,29278,29295},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {-29205,29281},
            [questKeys.objectives] = {{{52661}}},
        },
        [29298] = { -- A Smoke-Stained Locket
            [questKeys.startedBy] = {nil,nil,{69854}},
            [questKeys.nextQuestInChain] = 29302,
        },
        [29299] = { -- Some Like It Hot
            [questKeys.exclusiveTo] = {29255,29257},
            [questKeys.preQuestSingle] = {29254},
            [questKeys.objectives] = {{{53256,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Engage it to create Ember Pools"),0,{{"monster",53240}}}},
        },
        [29302] = { -- Unlocking the Secrets Within
            [questKeys.nextQuestInChain] = 29303,
            [questKeys.objectives] = {{{53296,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29303] = { -- Tragedy and Family
            [questKeys.nextQuestInChain] = 29310,
            [questKeys.objectives] = {nil,{{208790,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.finishedBy] = {{100024}},
        },
        [29304] = { -- The Dogs of War
            [questKeys.preQuestSingle] = {29201},
            [questKeys.exclusiveTo] = {29137,29141,29142},
        },
        [29305] = { -- Strike at the Heart
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29283,29287,29293,-29206}, -- 29287 or 29288 or 29290, 29293 or 29296.
        },
        [29310] = { -- The Tipping Point
            [questKeys.nextQuestInChain] = 29311,
            [questKeys.startedBy] = {{100025}},
            [questKeys.objectives] = {nil,{{208791,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.finishedBy] = {{100026}},
            [questKeys.preQuestSingle] = {29303},
        },
        [29311] = { -- The Rest is History
            [questKeys.objectivesText] = {"Bring the Smoke-Stained Locket to Malfurion in the Molten Front."},
            [questKeys.startedBy] = {{100027}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Go through the portal"),0,{{"object",208900}}}},
        },
        [29317] = { -- Fish Head
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29354,29346,29348,29345,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.UNDERCITY]={{80.11,32.27},{82.51,44.29},{65.8,68.61},{49.62,43.89},{77.96,61.36},{54.29,61.1},{51.86,30.62},{66.24,19.53}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Severed Abomination Head")}},
        },
        [29318] = { -- Ribs for the Sentinels
            [questKeys.objectives] = {{{4262,"Feed Ribs to Sentinels",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {69906},
        },
        [29319] = { -- Tadpole Terror
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29354,29346,29348,29345,29317,29320,29361,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.TIRISFAL_GLADES]={{49.51,54.52}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Giant Flesh-Eating Tadpole")}},
        },
        [29320] = { -- Like Pike?
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29354,29346,29348,29345,29317,29361,29319,29322},
            [questKeys.requiredSourceItems] = {69907},
            [questKeys.extraObjectives] = {{{[zoneIDs.TIRISFAL_GLADES]={{68.48,48.59}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Corpse-Fed Pike")}},
        },
        [29321] = { -- Happy as a Clam Digger
            [questKeys.exclusiveTo] = {29325,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26442,26488,26536},
        },
        [29322] = { -- Time for Slime
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29354,29346,29348,29345,29317,29361,29319,29320},
            [questKeys.extraObjectives] = {{{[zoneIDs.UNDERCITY]={{63.6,41.7},{67.1,48.1},{65.8,68.6},{82.2,43.5},{68.3,18.7},{49.8,43.7}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Squirming Slime Mold")}},
        },
        [29323] = { -- Stocking Up
            [questKeys.exclusiveTo] = {29325,29321,29324,29342,29343,29344,29347,29350,29359,26414,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARNASSUS]={{38.03,58.83},{39.19,44.04},{47.62,45.83},{50.52,9.02},{46.83,20.04},{48.62,62.83}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Lake Whitefish")}},
        },
        [29324] = { -- The Sister's Pendant
            [questKeys.exclusiveTo] = {29325,29321,29323,29342,29343,29344,29347,29350,29359,26414,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARNASSUS]={{38.03,58.83},{39.19,44.04},{47.62,45.83},{50.52,9.02},{46.83,20.04},{48.62,62.83}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Giant Catfish")}},
            [questKeys.requiredSourceItems] = {69914},
        },
        [29325] = { -- A Slippery Snack
            [questKeys.exclusiveTo] = {29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26442,26488,26536},
        },
        [29326] = { -- The Nordrassil Summit
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 29335,
            [questKeys.objectives] = {{{54313,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29327] = { -- Elemental Bonds: Doubt
            [questKeys.nextQuestInChain] = 29336,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Cyclonas"),0,{{"monster",53524}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{53518,53537},53518,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29328] = { -- Elemental Bonds: Desire
            [questKeys.objectives] = {nil,nil,nil,nil,{{{53676,53649},53649,nil,Questie.ICON_TYPE_EVENT},{{53670},53670,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {29336},
            [questKeys.nextQuestInChain] = 29337,
        },
        [29329] = { -- Elemental Bonds: Patience
            [questKeys.preQuestSingle] = {29337},
            [questKeys.nextQuestInChain] = 29338,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Aggra"),0,{{"monster",53738}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{53755,53736},53736,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29330] = { -- Elemental Bonds: Fury
            [questKeys.preQuestSingle] = {29338},
            [questKeys.nextQuestInChain] = 29331,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{53915,53916,53917,53918},53915,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.finishedBy] = {{100029}},
        },
        [29331] = { -- Elemental Bonds: The Vow
            [questKeys.preQuestSingle] = {29330},
        },
        [29335] = { -- Into Slashing Winds
            [questKeys.nextQuestInChain] = 29327,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Aggra"),0,{{"monster",54312}}}},
        },
        [29336] = { -- Into Coaxing Tides
            [questKeys.preQuestSingle] = {29327},
            [questKeys.nextQuestInChain] = 29328,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Aggra"),0,{{"monster",53519}}}},
        },
        [29337] = { -- Into Constant Earth
            [questKeys.nextQuestInChain] = 29329,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Aggra"),0,{{"monster",53652}}}},
        },
        [29338] = { -- Into Unrelenting Flame
            [questKeys.nextQuestInChain] = 29330,
        },
        [29342] = { -- Cold Water Fishing
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29343,29344,29347,29350,29359,26414,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.DUN_MOROGH]={{83.97,51.69}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Arctic Char")}},
        },
        [29343] = { -- One fer the Ages
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29344,29347,29350,29359,26414,26420,26442,26488,26536},
            [questKeys.requiredSourceItems] = {69932},
            [questKeys.extraObjectives] = {{{[zoneIDs.IRONFORGE]={{47.09,18.54}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Young Ironjaw")}},
            [questKeys.objectives] = {nil,{{208860,"Put Young Ironjaw on Display",Questie.ICON_TYPE_INTERACT}}},
        },
        [29344] = { -- Fish fer Squirky
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29347,29350,29359,26414,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.IRONFORGE]={{47.09,18.54}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Blind Minnow")}},
            [questKeys.requiredSourceItems] = {69933},
            [questKeys.objectives] = {{{53544,"Feed Squirky",Questie.ICON_TYPE_EVENT}}},
        },
        [29345] = { -- Pond Predators
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29354,29346,29348,29317,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.THUNDER_BLUFF]={{40.4,58.5}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Azshara Snakehead")}},
        },
        [29346] = { -- The Ring's the Thing
            [questKeys.exclusiveTo] = {26572,26557,26543,26556,26588,29349,29345,29354,29348,29317,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.THUNDER_BLUFF]={{25.58,18.19}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Blind Cavefish")}},
            [questKeys.requiredSourceItems] = {69956},
        },
        [29347] = { -- Live Bait
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29350,29359,26414,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.DUN_MOROGH]={{83.97,51.65}}}, Questie.ICON_TYPE_EVENT, l10n("Use Grimnur's Bait on yourself"),1}},
            [questKeys.objectives] = {{{53540,"Catch Cold Water Crayfish",Questie.ICON_TYPE_NODE_FISH},{1355,"Take Crayfish to Cook Ghilm",Questie.ICON_TYPE_INTERACT}}},
        },
        [29348] = { -- The Race to Restock
            [questKeys.exclusiveTo] = {26572,26557,26543,26556,26588,29349,29345,29354,29346,29317,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.MULGORE]={{51.8,52.06},{45.15,63.21}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Randy Smallfish and Amorous Mud Snapper")}},
        },
        [29349] = { -- Craving Crayfish
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29345,29354,29346,29348,29317,29320,29361,29319,29322},
            [questKeys.extraObjectives] = {{{[zoneIDs.MULGORE]={{51.8,52.06},{45.15,63.21}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Stonebull Crayfish")}},
        },
        [29350] = { -- The Gnomish Bait-o-Matic
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29359,26414,26420,26442,26488,26536},
            [questKeys.requiredSourceItems] = {6529,39684,69980},
        },
        [29351] = { -- A Round for the Guards
            [questKeys.objectives] = {{{5595,"Ironforge Guards Fed",Questie.ICON_TYPE_INTERACT}}},
        },
        [29354] = { -- Shiny Baubles
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29345,29346,29348,29317,29320,29361,29319,29322},
        },
        [29355] = { -- Can't Get Enough Spice Bread
            [questKeys.extraObjectives] = {{{[zoneIDs.IRONFORGE]={{60.34,38.17}}}, Questie.ICON_TYPE_EVENT, l10n("Cook 10 Spice Bread")}},
        },
        [29356] = { -- I Need to Cask a Favor
            [questKeys.objectives] = {{{5159,"Deliver Cask of Drugan's IPA",Questie.ICON_TYPE_INTERACT}},{{208872}}},
        },
        [29357] = { -- Spice Bread Aplenty
            [questKeys.extraObjectives] = {{{[zoneIDs.DARNASSUS]={{49.58,36.56}}}, Questie.ICON_TYPE_EVENT, l10n("Cook 10 Spice Bread")}},
        },
        [29358] = { -- Pining for Nuts
            [questKeys.requiredSourceItems] = {69990},
        },
        [29359] = { -- An Old Favorite
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,26414,26420,26442,26488,26536},
            [questKeys.extraObjectives] = {{{[zoneIDs.TELDRASSIL]={{54.68,92.46},{52.75,91.38},{53.16,88.28},{54.42,86.53},{57.16,86.77},{58.22,90.45},{56.4,93.07}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Kaldorei Herring")}},
        },
        [29361] = { -- Moat Monster!
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,26572,29349,29354,29346,29348,29345,29317,29320,29319,29322},
            [questKeys.requiredSourceItems] = {69995,69998},
            [questKeys.extraObjectives] = {{{[zoneIDs.TIRISFAL_GLADES]={{61.4,68.6}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Alliance Decoy Kit in the Ruins of Lordaeron and feed the Moat Monster")}},
        },
        [29363] = { -- Mulgore Spice Bread
            [questKeys.extraObjectives] = {{{[zoneIDs.THUNDER_BLUFF]={{51.3,52.9}}}, Questie.ICON_TYPE_EVENT, l10n("Cook 5 Spice Bread and combine with Mulgore Spices")}},
        },
        [29371] = { -- A Time to Lose
            [questKeys.objectives] = {nil,{{301112,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29374] = { -- Stink Bombs Away!
            [questKeys.objectives] = {nil,{{180449,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the bombing run"),0,{{"monster",53764}}}},
        },
        [29376] = { -- A Time to Build Up
            [questKeys.objectives] = {nil,{{205016},{460018}}},
            [questKeys.preQuestSingle] = {},
        },
        [29377] = { -- A Time to Break Down
            [questKeys.objectives] = {nil,{{301111,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29387] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25611,25807,25520,25372},
            [questKeys.nextQuestInChain] = 29145,
        },
        [29388] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25612,25807,25520,25372},
            [questKeys.nextQuestInChain] = 29145,
        },
        [29389] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.nextQuestInChain] = 29145,
        },
        [29390] = { -- Guardians of Hyjal: Call of the Ancients
            [questKeys.startedBy] = {nil,{206109,206116,207323,207324,207325}},
            [questKeys.nextQuestInChain] = 29388,
            [questKeys.exclusiveTo] = {25372,29389},
        },
        [29391] = { -- Guardians of Hyjal: Call of the Ancients
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.nextQuestInChain] = 29387,
            [questKeys.exclusiveTo] = {25372,29389},
        },
        [29392] = { -- Missing Heirlooms
            [questKeys.objectives] = {{{53950,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29393] = { -- Brew For Brewfest
            [questKeys.startedBy] = {{24497}},
            [questKeys.preQuestSingle] = {11412},
        },
        [29394] = { -- Brew For Brewfest
            [questKeys.startedBy] = {{23558}},
            [questKeys.preQuestSingle] = {11122},
        },
        [29396] = { -- A New Supplier of Souvenirs
            [questKeys.startedBy] = {{24510}},
            [questKeys.preQuestSingle] = {11409},
        },
        [29397] = { -- A New Supplier of Souvenirs
            [questKeys.startedBy] = {{24468}},
            [questKeys.preQuestSingle] = {11318},
        },
        [29398] = { -- Fencing the Goods
            [questKeys.objectives] = {{{8719,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29399] = { -- Shopping Around
            [questKeys.objectives] = {{{53991,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [29400] = { -- A Season for Celebration
            [questKeys.startedBy] = {{20102}},
        },
        [29402] = { -- Taking Precautions
            [questKeys.objectives] = {nil,nil,{{3371},{17020},{71035}}},
        },
        [29413] = { -- The Creepy Crate
            [questKeys.startedBy] = {nil,{209076}},
        },
        [29415] = { -- Missing Heirlooms
            [questKeys.objectives] = {{{54142,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29416] = { -- Fencing the Goods
            [questKeys.objectives] = {{{44866,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29425] = { -- Shopping Around
            [questKeys.objectives] = {{{6986,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29426] = { -- Taking Precautions
            [questKeys.objectives] = {nil,nil,{{3371},{17020},{71035}}},
        },
        [29429] = { -- The Creepy Crate
            [questKeys.startedBy] = {nil,{209095}},
        },
        [29430] = { -- A Friend in Need
            [questKeys.nextQuestInChain] = 29392,
        },
        [29431] = { -- A Friend in Need
            [questKeys.nextQuestInChain] = 29415,
        },
        [29433] = { -- Test Your Strength
            [questKeys.specialFlags] = 17,
        },
        [29434] = { -- Tonk Commander
            [questKeys.objectives] = {{{33081}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Finlay Coolshot to start the game"),0,{{"monster",54605}}}},
        },
        [29436] = { -- The Humanoid Cannonball
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Maxima Blastenheimer to start the game"),0,{{"monster",15303}}}},
        },
        [29437] = { -- The Fallen Guardian
            [questKeys.preQuestGroup] = {29326,25372}, -- for some chars it opens after 29326, for others it opens after 29327. i have no idea Oo
            [questKeys.finishedBy] = {{100028}},
            [questKeys.startedBy] = {{40289,52793}},
        },
        [29438] = { -- He Shoots, He Scores!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Rinling to start the game"),0,{{"monster",14841}}}},
        },
        [29439] = { -- The Call of the World-Shaman
            [questKeys.nextQuestInChain] = 29326,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [29440] = { -- The Call of the World-Shaman
            [questKeys.nextQuestInChain] = 29326,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [29443] = { -- A Curious Crystal
            [questKeys.specialFlags] = 17,
        },
        [29444] = { -- An Exotic Egg
            [questKeys.specialFlags] = 17,
        },
        [29445] = { -- An Intriguing Grimoire
            [questKeys.specialFlags] = 17,
        },
        [29446] = { -- A Wondrous Weapon
            [questKeys.specialFlags] = 17,
        },
        [29451] = { -- The Master Strategist
            [questKeys.specialFlags] = 17,
        },
        [29452] = { -- Your Time Has Come
            [questKeys.nextQuestInChain] = 29129,
            [questKeys.requiredClasses] = classKeys.SHAMAN + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [29453] = { -- Your Time Has Come
            [questKeys.nextQuestInChain] = 29132,
            [questKeys.requiredClasses] = classKeys.SHAMAN + classKeys.PRIEST + classKeys.MAGE + classKeys.WARLOCK + classKeys.DRUID,
        },
        [29455] = { -- Target: Turtle
            [questKeys.objectives] = {{{54490}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Jessica Rogers to start the game"),0,{{"monster",54485}}}},
        },
        [29456] = { -- A Captured Banner
            [questKeys.specialFlags] = 17,
        },
        [29457] = { -- The Enemy's Insignia
            [questKeys.specialFlags] = 17,
        },
        [29458] = { -- The Captured Journal
            [questKeys.specialFlags] = 17,
        },
        [29463] = { -- It's Hammer Time
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mola to start the game"),0,{{"monster",54601}}}},
        },
        [29464] = { -- Tools of Divination
            [questKeys.startedBy] = {nil,nil,{71716}},
            [questKeys.specialFlags] = 17,
        },
        [29475] = { -- Goblin Engineering
            [questKeys.requiredSkill] = {profKeys.ENGINEERING,200},
        },
        [29477] = { -- Gnomish Engineering
            [questKeys.requiredSkill] = {profKeys.ENGINEERING,200},
        },
        [29481] = { -- Elixir Master
            [questKeys.requiredLevel] = 75,
            [questKeys.objectives] = {nil,nil,{{58086},{58087},{58085},{58088}}},
            [questKeys.exclusiveTo] = {10897,10899,10902,29067,29482},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29482] = { -- Transmutation Master
            [questKeys.requiredLevel] = 75,
            [questKeys.objectives] = {nil,nil,{{58480}}},
            [questKeys.exclusiveTo] = {10897,10899,10902,29067,29481},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29506] = { -- A Fizzy Fusion
            [questKeys.objectives] = {nil,{{460001}}},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,75},
            [questKeys.specialFlags] = 17,
            [questKeys.requiredSourceItems] = {1645,19299},
        },
        [29507] = { -- Fun for the Little Ones
            [questKeys.startedBy] = {{14847}},
            [questKeys.objectives] = {nil,{{460001}}},
            [questKeys.requiredSkill] = {profKeys.ARCHAEOLOGY,75},
            [questKeys.specialFlags] = 17,
        },
        [29508] = { -- Baby Needs Two Pair of Shoes
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,75},
            [questKeys.requiredSourceItems] = {71967},
            [questKeys.objectives] = {{{54510,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.specialFlags] = 17,
        },
        [29509] = { -- Putting the Crunch in the Frog
            [questKeys.requiredSkill] = {profKeys.COOKING,75},
            [questKeys.requiredSourceItems] = {30817,72057},
            [questKeys.specialFlags] = 17,
            [questKeys.objectives] = {{{54551,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29510] = { -- Putting Trash to Good Use
            [questKeys.requiredSourceItems] = {72018},
            [questKeys.requiredSkill] = {profKeys.ENCHANTING,75},
            [questKeys.specialFlags] = 17,
        },
        [29511] = { -- Talkin' Tonks
            [questKeys.objectives] = {{{54504,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSkill] = {profKeys.ENGINEERING,75},
            [questKeys.specialFlags] = 17,
        },
        [29512] = { -- Putting the Carnies Back Together Again
            [questKeys.objectives] = {{{54518,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSkill] = {profKeys.FIRST_AID,75},
            [questKeys.specialFlags] = 17,
        },
        [29513] = { -- Spoilin' for Salty Sea Dogs
            [questKeys.requiredSkill] = {profKeys.FISHING,75},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKMOON_FAIRE_ISLAND]={{53.2,89.5}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Great Sea Herring")}},
            [questKeys.specialFlags] = 17,
        },
        [29514] = { -- Herbs for Healing
            [questKeys.requiredSkill] = {profKeys.HERBALISM,75},
            [questKeys.specialFlags] = 17,
        },
        [29515] = { -- Writing the Future
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,75},
            [questKeys.specialFlags] = 17,
            [questKeys.requiredSourceItems] = {39354,71972},
        },
        [29516] = { -- Keeping the Faire Sparkling
            [questKeys.requiredSourceItems] = {72052},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,75},
            [questKeys.specialFlags] = 17,
        },
        [29517] = { -- Eyes on the Prizes
            [questKeys.requiredSkill] = {profKeys.LEATHERWORKING,75},
            [questKeys.specialFlags] = 17,
            [questKeys.requiredSourceItems] = {6260,2320,6529},
        },
        [29518] = { -- Rearm, Reuse, Recycle
            [questKeys.requiredSkill] = {profKeys.MINING,75},
            [questKeys.specialFlags] = 17,
        },
        [29519] = { -- Tan My Hide
            [questKeys.requiredSkill] = {profKeys.SKINNING,75},
            [questKeys.specialFlags] = 17,
        },
        [29520] = { -- Banners, Banners Everywhere!
            [questKeys.requiredSkill] = {profKeys.TAILORING,75},
            [questKeys.requiredSourceItems] = {2320,2604,6260,72049},
            [questKeys.objectives] = {nil,{{209288}}},
            [questKeys.specialFlags] = 17,
        },
        [29536] = { -- Heart of Rage
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.THE_BLOOD_FURNACE]={{64.9,41.5}}}},
        },
        [29539] = { -- Heart of Rage
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.THE_BLOOD_FURNACE]={{64.9,41.5}}}},
        },
        [29598] = { -- Taretha's Diversion
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Set the fuse on a barrel"),0,{{"object",460015}}}},
        },
        [29642] = { -- Trouble at Auchindoun
            [questKeys.exclusiveTo] = {10094},
            [questKeys.nextQuestInChain] = 29643,
        },
        [29682] = { -- Magisters' Terrace
            [questKeys.objectives] = {{{55007,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29684] = { -- Severed Communications
            [questKeys.objectives] = {{{24822,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29692] = { -- Bring Me Another Shrubbery!
            [questKeys.preQuestSingle] = {29691},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [29826] = { -- Reclaiming Ahn'Kahet
            [questKeys.startedBy] = {{55658}},
        },
        [29829] = { -- Discretion is Key
            [questKeys.nextQuestInChain] = 29830,
        },
        [29830] = { -- Containment
            [questKeys.preQuestSingle] = {},
        },
        [29834] = { -- Gal'darah Must Pay
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [29835] = { -- Gal'darah Must Pay
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [29838] = { -- One of a Kind
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [29839] = { -- One of a Kind
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [29840] = { -- For Posterity
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [29844] = { -- For Posterity
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [29851] = { -- Champion of the Tournament
            [questKeys.objectives] = {{{35451}}},
            [questKeys.requiredRaces] = raceKeys.NONE,
        },
        [30112] = { -- A Score to Settle
            [questKeys.exclusiveTo] = {11272},
        },
        [82948] = {
            [questKeys.name] = "Hero's Call Board",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5515,13283,20407,44395}},
            [questKeys.finishedBy] = {{12480}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Stormwind City and speak to Melris Malagan."},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [82949] = {
            [questKeys.name] = "Warchief's Command Board",
            [questKeys.startedBy] = {{3324,3328,3344,3353,23128,45339,47246,47788}},
            [questKeys.finishedBy] = {{49750}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Orgrimmar and speak to the Warchief's Herald."},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [82983] = {
            [questKeys.name] = "Hero's Call Board",
            [questKeys.startedBy] = {{29194,29195,29196}},
            [questKeys.finishedBy] = {{12480}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classKeys.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Stormwind City and speak to Melris Malagan."},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [82985] = {
            [questKeys.name] = "Warchief's Command Board",
            [questKeys.startedBy] = {{29194,29195,29196}},
            [questKeys.finishedBy] = {{49750}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.requiredClasses] = classKeys.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Orgrimmar and speak to the Warchief's Herald."},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [82989] = {
            [questKeys.name] = "Warchief's Command Board",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{49750}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.requiredClasses] = classKeys.DRUID,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Orgrimmar and speak to the Warchief's Herald."},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
    }
end

function CataQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys

    local questFixesHorde = {
        [12318] = { -- Save Brewfest!
            [questKeys.startedBy] = {},
        },
        [24911] = { -- Tropical Paradise Beckons
            [questKeys.startedBy] = {{44374}},
            [questKeys.nextQuestInChain] = 24740,
        },
        [25619] = { -- Reoccupation
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25952,25953,25954,25955,25956},
        },
        [25858] = { -- By Her Lady's Word
            [questKeys.objectives] = {{{42072,nil,Questie.ICON_TYPE_TALK},{42071,nil,Questie.ICON_TYPE_TALK},{41455,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25964,25965},
        },
        [25629] = { -- Her Lady's Hand
            [questKeys.preQuestSingle] = {25973},
        },
        [25896] = { -- Devout Assembly
            [questKeys.preQuestSingle] = {25973},
        },
        [26111] = { -- ... It Will Come
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26071,26072,26096},
        },
        [26191] = { -- The Culmination of Our Efforts
            [questKeys.nextQuestInChain] = {25967},
        },
        [27203] = { -- The Maelstrom
            [questKeys.startedBy] = {{45244}},
        },
        [29067] = { -- Potion Master
            [questKeys.startedBy] = {{3347}},
            [questKeys.finishedBy] = {{3347,3009,4611,16642}},
        },
        [29389] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.preQuestGroup] = {25612,25807,25520,25372},
        },
        [29475] = { -- Goblin Engineering
            [questKeys.startedBy] = {{11017,11031,16667,29513,52651}},
            [questKeys.finishedBy] = {{11017,11031,16667,29513,52651}},
            [questKeys.exclusiveTo] = {3526,3629,3633,4181,29476,29477,3630,3632,3634,3635,3637},
        },
        [29477] = { -- Gnomish Engineering
            [questKeys.startedBy] = {{11017,11031,16667,29513,52651}},
            [questKeys.finishedBy] = {{11017,11031,16667,29513,52651}},
            [questKeys.exclusiveTo] = {3630,3632,3634,3635,3637,29475,29476,3526,3629,3633,4181},
        },
        [29481] = { -- Elixir Master
            [questKeys.startedBy] = {{3347}},
            [questKeys.finishedBy] = {{3347,3009,4611,16642}},
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{3347}},
            [questKeys.finishedBy] = {{3347,3009,4611,16642}},
        },
        [29836] = { -- Just Checkin'
            [questKeys.nextQuestInChain] = 29840,
            [questKeys.exclusiveTo] = {13098},
        },
    }

    local questFixesAlliance = {
        [12318] = { -- Save Brewfest!
            [questKeys.startedBy] = {{27584}},
        },
        [24911] = { -- Tropical Paradise Beckons
            [questKeys.startedBy] = {{38578}},
        },
        [25513] = { -- Thunderdrome: Grudge Match!
            [questKeys.preQuestGroup] = {25065,25095},
        },
        [25619] = { -- Reoccupation
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25579,25580,25581,25582,25583},
        },
        [25629] = { -- Her Lady's Hand
            [questKeys.preQuestSingle] = {25911},
        },
        [25896] = { -- Devout Assembly
            [questKeys.preQuestSingle] = {25911},
        },
        [25858] = { -- By Her Lady's Word
            [questKeys.objectives] = {{{42072,nil,Questie.ICON_TYPE_TALK},{42071,nil,Questie.ICON_TYPE_TALK},{41455,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25753,25754},
        },
        [26111] = { -- ... It Will Come
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26070,26072,26096},
        },
        [26191] = { -- The Culmination of Our Efforts
            [questKeys.nextQuestInChain] = {25892},
        },
        [27203] = { -- The Maelstrom
            [questKeys.startedBy] = {{45226}},
        },
        [29067] = { -- Potion Master
            [questKeys.startedBy] = {{5499}},
            [questKeys.finishedBy] = {{5499,1537,4160,16723}},
        },
        [29389] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.preQuestGroup] = {25611,25807,25520,25372},
        },
        [29475] = { -- Goblin Engineering
            [questKeys.startedBy] = {{5174,5518,16726,29513,52636}},
            [questKeys.finishedBy] = {{5174,5518,16726,29513,52636}},
            [questKeys.exclusiveTo] = {3526,3629,3633,4181,29476,29477,3630,3632,3634,3635,3637},
        },
        [29477] = { -- Gnomish Engineering
            [questKeys.startedBy] = {{5174,5518,16726,29513,52636}},
            [questKeys.finishedBy] = {{5174,5518,16726,29513,52636}},
            [questKeys.exclusiveTo] = {3630,3632,3634,3635,3637,29475,29476,3526,3629,3633,4181},
        },
        [29481] = { -- Elixir Master
            [questKeys.startedBy] = {{5499}},
            [questKeys.finishedBy] = {{5499,1537,4160,16723}},
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{5499}},
            [questKeys.finishedBy] = {{5499,1537,4160,16723}},
        },
        [29836] = { -- Just Checkin'
            [questKeys.nextQuestInChain] = 29844,
            [questKeys.exclusiveTo] = {13098},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
