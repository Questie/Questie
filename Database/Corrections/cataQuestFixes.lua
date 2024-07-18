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
QuestieCorrections.objectObjectiveFirst[26659] = true
QuestieCorrections.objectObjectiveFirst[26809] = true
QuestieCorrections.killCreditObjectiveFirst[52] = true
QuestieCorrections.killCreditObjectiveFirst[26621] = true
QuestieCorrections.killCreditObjectiveFirst[26875] = true

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
        [487] = { -- The Road to Darnassus
            [questKeys.preQuestSingle] = {483},
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
        [840] = { -- Conscript of the Horde
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 871,
            [questKeys.zoneOrSort] = 14,
        },
        [850] = { -- Kolkar Leaders
            [questKeys.startedBy] = {{34841}},
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
        [5041] = { -- Supplies for the Crossroads
            [questKeys.preQuestSingle] = {871}
        },
        [5502] = { -- A Warden of the Horde
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29190,29191},
            [questKeys.zoneOrSort] = -378,
            [questKeys.finishedBy] = {{51989}},
        },
        [6031] = { -- Runecloth
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD,8}},
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
        [7383] = { -- Teldrassil: The Burden of the Kaldorei
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {918,919},
        },
        [7490] = { -- Victory for the Horde
            [questKeys.finishedBy] = {{39605}},
        },
        [7783] = { -- The Lord of Blackrock
            [questKeys.finishedBy] = {{39605}},
        },
        [7905] = { -- The Darkmoon Faire
            [questKeys.objectivesText] = {"Deliver the Free Ticket Voucher to Gelvas Grimgate, located inside the Darkmoon Faire."},
        },
        [7926] = { -- The Darkmoon Faire
            [questKeys.objectivesText] = {"Deliver the Free Ticket Voucher to Gelvas Grimgate, located inside the Darkmoon Faire."},
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
        [9563] = { -- Gaining Mirren's Trust
            [questKeys.objectives] = {nil,nil,{{23848}},{946,3000}},
        },
        [9612] = { -- A Hearty Thanks!
            [questKeys.requiredRaces] = raceKeys.DRAENEI,
        },
        [9616] = { -- Bandits!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [9626] = { -- Meeting the Warchief
            [questKeys.finishedBy] = {{39605}},
        },
        [9731] = { -- Drain Schematics
            [questKeys.preQuestSingle] = {9720},
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
        [9871] = { -- Murkblood Invaders
            [questKeys.startedBy] = {{18238},nil,{24559}},
        },
        [9872] = { -- Murkblood Invaders
            [questKeys.startedBy] = {{18238},nil,{24558}},
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
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
        [10647] = { -- Wanted: Uvuros, Scourge of Shadowmoon
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [10648] = { -- Wanted: Uvuros, Scourge of Shadowmoon
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
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
        [11129] = { -- Kyle's Gone Missing!
            [questKeys.objectives] = {{{23616,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11272] = { -- A Score to Settle
            [questKeys.exclusiveTo] = {30112},
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
        [11891] = { -- An Innocent Disguise
            [questKeys.requiredSourceItems] = {35237,35828},
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
        [11975] = { -- Now, When I Grow Up...
            [questKeys.zoneOrSort] = -378,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10945,10951,10953},
        },
        [12012] = { -- Inform the Elder
            [questKeys.exclusiveTo] = {29092},
            [questKeys.startedBy] = {{25324}},
        },
        [12563] = { -- Troll Patrol
            [questKeys.startedBy] = {},
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
        [12614] = { -- Post-partum Aggression
            [questKeys.preQuestSingle] = {12607},
        },
        [12618] = { -- Blessing of Zim'Torga
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [12656] = { -- Blessing of Zim'Rhuk
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [12821] = { -- Opening the Backdoor
            [questKeys.objectives] = {nil,nil,{{40731}}}
        },
        [13188] = { -- Where Kings Walk
            [questKeys.finishedBy] = {{29611}},
        },
        [13189] = { -- Warchief's Blessing
            [questKeys.finishedBy] = {{39605}},
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
            [questKeys.preQuestSingle] = {13620},
        },
        [13628] = { -- Got Wood?
            [questKeys.preQuestSingle] = {13621},
        },
        [13639] = { -- Resupplying the Excavation
            [questKeys.triggerEnd] = {"Find Huldar, Miran, and Saean",{[zoneIDs.LOCH_MODAN] = {{55.6,68.5}}}},
        },
        [13642] = { -- Bathed in Light
            [questKeys.preQuestSingle] = {13623},
        },
        [13646] = { -- Astranaar Bound
            [questKeys.preQuestSingle] = {26464},
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
        [13766] = { -- Closure is Only Natural
            [questKeys.objectives] = {{{33767,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13796] = { -- The Forest Heart
            [questKeys.preQuestSingle] = {13792},
            [questKeys.requiredSourceItems] = {45571,45572},
            [questKeys.sourceItemId] = 45571,
        },
        [13831] = { -- A Troubling Prescription
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {13528},
        },
        [13841] = { -- All Apologies
            [questKeys.finishedBy] = {{39605}},
        },
        [13842] = { -- Dread Head Redemption
            [questKeys.finishedBy] = {{39605}},
        },
        [13844] = { -- The Looting of Althalaxx
            [questKeys.preQuestSingle] = {13509},
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
        [13886] = { -- Vortex
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
            [questKeys.requiredSourceItems] = {46388,46702},
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
        [13945] = { -- Resident Danger
            [questKeys.preQuestSingle] = {476},
        },
        [13946] = { -- Nature's Reprisal
            [questKeys.preQuestSingle] = {489},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{2002,2003,2004,2005},2002}}},
        },
        [13948] = { -- Stepping Up Surveillance
            [questKeys.objectives] = {{{34326,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13949] = { -- Crossroads Caravan Pickup
            [questKeys.preQuestGroup] = {872, 5041},
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
        [13975] = { -- Crossroads Caravan Delivery
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Crossroads Caravan Escorted",{[zoneIDs.THE_BARRENS] = {{50.3,58.5}}}},
        },
        [13976] = { -- Three Friends of the Forest
            [questKeys.preQuestSingle] = {},
        },
        [13982] = { -- In a Bind
            [questKeys.preQuestSingle] = {13976},
        },
        [13985] = { -- Clear the Shrine
            [questKeys.preQuestSingle] = {13982},
        },
        [13989] = { -- King of the Foulweald
            [questKeys.requiredSourceItems] = {46777,46739},
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
            [questKeys.preQuestGroup] = {14109,24520,14007 or 14008 or 14009 or 14010 or 14011 or 14012 or 14013},
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
            [questKeys.requiredSourceItems] = {46856,48768},
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
            [questKeys.preQuestGroup] = {14110,24520,14007 or 14008 or 14009 or 14010 or 14011 or 14012 or 14013},
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
        [14193] = { -- Nothing a Couple of Melons Won't Fix
            [questKeys.objectives] = {nil,{{195438}}},
            [questKeys.requiredSourceItems] = {48106},
        },
        [14194] = { -- Refleshification
            [questKeys.objectives] = {{{35257,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14201] = { -- A Thousand Stories in the Sand
            [questKeys.preQuestSingle] = {24453},
        },
        [14202] = { -- Survey the Lakeshore
            [questKeys.preQuestSingle] = {24453},
            [questKeys.objectives] = {{{35488,nil,Questie.ICON_TYPE_EVENT},{35487,nil,Questie.ICON_TYPE_EVENT},{35489,nil,Questie.ICON_TYPE_EVENT}}},
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
        [14213] = { -- Ten Pounds of Flesh
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.requiredSourceItems] = {48857},
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
        [14219] = { -- To the Hilt!
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.objectives] = {nil,{{195517}}},
            [questKeys.requiredSourceItems] = {48943},
        },
        [14222] = { -- Last Stand
            [questKeys.startedBy] = {{35566}},
        },
        [14226] = { -- Trouble Under Foot
            [questKeys.preQuestGroup] = {14249,14250,14263},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use Polymorph Insect on it"),0,{{"monster",6200},{"monster",6201},{"monster",6202}}}},
        },
        [14230] = { -- Manual Labor
            [questKeys.preQuestGroup] = {14249,14250,14263},
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
        [14261] = { -- Ice Cold
            [questKeys.preQuestSingle] = {14391},
        },
        [14262] = { -- To Gut a Fish
            [questKeys.preQuestSingle] = {14258},
        },
        [14263] = { -- Waste of Thyme
            [questKeys.preQuestSingle] = {14340},
        },
        [14266] = { -- Charge
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 35839}}}},
            [questKeys.requiredRaces] = raceKeys.WORGEN,
        },
        [14267] = { -- Investigating the Sea Shrine
            [questKeys.preQuestSingle] = {14258},
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
        [14308] = { -- When Science Attacks
            [questKeys.objectives] = {{{36025,nil,Questie.ICON_TYPE_EVENT},{36061,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
        },
        [14310] = { -- Segmentation Fault: Core Dumped
            [questKeys.objectives] = {{{36105,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Reactor Control Console"), 0, {{"object", 195683}}}},
        },
        [14311] = { -- Taking Part
            [questKeys.preQuestGroup] = {14305,14306},
        },
        [14312] = { -- An Introduction Is In Order
            [questKeys.preQuestSingle] = {14311},
        },
        [14316] = { -- Cenarion Property
            [questKeys.preQuestSingle] = {14312},
        },
        [14323] = { -- Absorbent
            [questKeys.preQuestSingle] = {14130},
        },
        [14324] = { -- Full of Hot Water
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Scalding Water Lord"), 0, {{"object", 195711}}}},
        },
        [14340] = { -- Dressed to Impress
            [questKeys.objectives] = {{{35187,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [14345] = { -- Wash Out
            [questKeys.preQuestGroup] = {14131,14132,14324},
        },
        [14348] = { -- You Can't Take 'Em Alone
            [questKeys.objectives] = {{{36231}}},
            [questKeys.requiredSourceItems] = {49202},
        },
        [14357] = { -- To the Hilt!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,{{195517}}},
            [questKeys.requiredSourceItems] = {48943},
        },
        [14358] = { -- Ten Pounds of Flesh
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.requiredSourceItems] = {48857},
        },
        [14359] = { -- Blessings From Above
            [questKeys.objectives] = {nil,{{195497}}},
            [questKeys.preQuestSingle] = {14358},
            [questKeys.requiredSourceItems] = {48857},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [14361] = { -- Peace of Mind
            [questKeys.preQuestSingle] = {14354},
        },
        [14365] = { -- Ethel Rethor
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
        [14377] = { -- Befriending Giants
            [questKeys.preQuestGroup] = {14370,14371},
            [questKeys.objectives] = {{{36297,nil,Questie.ICON_TYPE_TALK}}},
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
        [24550] = { -- Journey into Thunder Bluff
            [questKeys.requiredRaces] = raceKeys.TAUREN,
        },
        [24567] = { -- Report for Tryouts
            [questKeys.sourceItemId] = 46856,
        },
        [24575] = { -- Liberation Day
            [questKeys.requiredSourceItems] = {49881},
            [questKeys.objectives] = {{{37694,"Enslaved Gilnean freed",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Unlock the Ball and Chain"),0,{{"object",201775}}}},
        },
        [24593] = { -- Neither Human Nor Beast
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24646,24628},
        },
        [24612] = { -- A Gift for the Emissary of Orgrimmar
            [questKeys.finishedBy] = {{39605}},
        },
        [24618] = { -- Claim the Battle Scar
            [questKeys.triggerEnd] = {"Battlescar Flag Scouted",{[zoneIDs.THE_BARRENS] = {{45.2,69.4}}}},
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
            [questKeys.objectives] = {{{37847,nil,Questie.ICON_TYPE_TALK}}},
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
        [24721] = { -- The Eastern Pylon
            [questKeys.objectives] = {nil,{{164957,"Discover and examine the Eastern Crystal Pylon"}}},
        },
        [24722] = { -- The Northern Pylon
            [questKeys.objectives] = {nil,{{164955,"Discover and examine the Northern Crystal Pylon"}}},
        },
        [24723] = { -- The Western Pylon
            [questKeys.objectives] = {nil,{{164956,"Discover and examine the Western Crystal Pylon"}}},
        },
        [24735] = { -- A Little Help From My Friends
            [questKeys.preQuestSingle] = {24734},
        },
        [24741] = { -- Trading Up
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Place the Wild Clucker Eggs in the trap"),0,{{"object",201972}}}},
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
        [24920] = { -- Slowing the Inevitable
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get on the Captured Riding Bat"),0,{{"monster",38615}}}},
        },
        [24925] = { -- Free the Captives
            [questKeys.objectives] = {{{38643,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Oomlot Shaman"),0,{{"monster",38644}}}},
        },
        [24930] = { -- While You're At It
            [questKeys.startedBy] = {{35115}},
            [questKeys.preQuestSingle] = {14285,14286,14287,14288,14289,14290,14291},
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
        [24952] = { -- Rocket Boot Boost
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24942,24945,24946},
            [questKeys.objectives] = {{{38842,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.preQuestSingle] = {25049},
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
        [25073] = { -- Sen'jin Village
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [25081] = { -- Claim the Battlescar
            [questKeys.triggerEnd] = {"Battlescar Flag Scouted",{[zoneIDs.THE_BARRENS] = {{45.2,69.4}}}},
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
        [25112] = { -- Butcherbot
            [questKeys.objectives] = {{{5419}}},
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
        [25190] = { -- Raggaran's Rage TODO: add preQuestSingle to childQuests
            [questKeys.parentQuest] = 25188,
        },
        [25191] = { -- Survey the Destruction
            [questKeys.objectives] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Nibb Spindlegear"), 0, {{"monster", 38383}}}},
        },
        [25192] = { -- Raggaran's Fury TODO: add preQuestSingle to childQuests
            [questKeys.parentQuest] = 25188,
        },
        [25193] = { -- Lost But Not Forgotten
            [questKeys.parentQuest] = 25188,
        },
        [25194] = { -- Unbidden Visitors TODO: add preQuestSingle to childQuests
            [questKeys.parentQuest] = 25188,
            [questKeys.objectives] = {{{39337,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25195] = { -- That's the End of That Raptor TODO: add preQuestSingle to childQuests
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
            [questKeys.requiredSourceItems] = {53052,54214,54216,54217}, -- can't be fixed, we need to able to show one item from multiple requiredSourceItems in QIB.
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
        [25244] = { -- What Kind of Name is Candy, Anyway?
            [questKeys.preQuestSingle] = {25213},
        },
        [25251] = { -- Final Confrontation
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25214,25243 or 25244},
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
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25233,25234,25255}
        },
        [25269] = { -- The Voice of Lo'Gosh
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25233,25234,25255}
        },
        [25273] = { -- Lycanthoth the Corruptor
            [questKeys.finishedBy] = {{39627}},
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
            [questKeys.preQuestSingle] = {25223,25224,25330},
        },
        [25294] = { -- Walking the Dog
            [questKeys.objectives] = {{{39659,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {25291},
            [questKeys.requiredSourceItems] = {52708,52717},
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
        [25330] = { -- Waste of Flesh
            [questKeys.objectives] = {{{39453,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25332] = { -- Get Me Outta Here!
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Kristoff Escorted Out",{[zoneIDs.MOUNT_HYJAL] = {{27.1,35.9}}}},
            [questKeys.preQuestSingle] = {25328},
        },
        [25334] = { -- The Looming Threat
            [questKeys.objectives] = {{{39226,nil,Questie.ICON_TYPE_TALK}}},
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
        [25359] = { -- Toshe's Vengeance
            [questKeys.nextQuestInChain] = 25439,
        },
        [25370] = { -- Inciting the Elements
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSourceItems] = {53009},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Feed Juniper Berries"),0,{{"monster",39921}}}},
        },
        [25371] = { -- The Abyssal Ride
            [questKeys.objectives] = {{{39996,nil,Questie.ICON_TYPE_MOUNT_UP}},{{202766}}},
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
        [25404] = { -- If You're Not Against Us...
            [questKeys.objectives] = {{{39933,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {25584},
        },
        [25411] = { -- A New Master
            [questKeys.objectives] = {{{39974}}},
        },
        [25412] = { -- The Name Never Spoken
            [questKeys.preQuestSingle] = {25411},
            [questKeys.exclusiveTo] = {25443},
        },
        [25419] = { -- Lady La-La's Medallion
            [questKeys.requiredSourceItems] = {55188}, -- can't be fixed, we need to able to show both sourceItemId and requiredSourceItems in both QIB in same time.
            [questKeys.startedBy] = {{41017},nil,{55186}},
            [questKeys.preQuestSingle] = {25459},
            [questKeys.finishedBy] = {{100009}},
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
        [25459] = { -- Ophidophobia
            [questKeys.preQuestSingle] = {25602},
        },
        [25460] = { -- The Earth Rises
            [questKeys.preQuestSingle] = {},
        },
        [25462] = { -- The Bears Up There
            [questKeys.preQuestSingle] = {25428},
            [questKeys.objectives] = {{{40240}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Climb the tree"),0,{{"monster",40190}}}},
        },
        [25464] = { -- The Return of Baron Geddon
            [questKeys.objectives] = {{{40147,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25467] = { -- Kliklak's Craw
            [questKeys.startedBy] = {{40276},nil,{54345}},
        },
        [25473] = { -- Kaja'Cola
            [questKeys.startedBy] = {{34872}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14075,14069},
        },
        [25476] = { -- Rescue OOX-22/FE!
            [questKeys.triggerEnd] = {"Escort OOX-22/FE to safety",{[zoneIDs.FERALAS]={{55.1,51.1}}}},
        },
        [25477] = { -- Better Late Than Dead
            [questKeys.objectives] = {{{40223,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {25949,25558},
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
        [25525] = { -- Wave One
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39833,39835},39835}}},
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
        },
        [25536] = { -- Cold Welcome
            [questKeys.finishedBy] = {{40642}},
        },
        [25537] = { -- Art of Attraction
            [questKeys.objectives] = {{{40654,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25540] = { -- Bellies Await
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25538,25539},
        },
        [25544] = { -- Wave Two
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{40650,40660},40650}}},
        },
        [25545] = { -- To Arms!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25357,25546},
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
        [25558] = { -- All or Nothing
            [questKeys.extraObjectives] = {{{[zoneIDs.KELP_THAR_FOREST] = {{44.59,25.37}}},Questie.ICON_TYPE_EVENT,l10n("Defend The Briny Cutter")}},
            [questKeys.objectives] = {{{40714,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25560] = { -- Egg Wave
            [questKeys.requiredSourceItems] = {52716},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",40720},{"monster",40723}}}},
        },
        [25564] = { -- Stormwind Elite Aquatic and Land Forces
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25357,25546},
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
        [25587] = { -- Gimme Shelter!
            [questKeys.preQuestSingle] = {25949,25558},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.KELP_THAR_FOREST] = {{56.74,30.41}}},Questie.ICON_TYPE_EVENT,l10n("Smuggler's Scar Scouted"),1},
                {{[zoneIDs.KELP_THAR_FOREST] = {{54.1,34.4}}},Questie.ICON_TYPE_EVENT,l10n("Adarrah Signaled"),2},
            },
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
            [questKeys.preQuestSingle] = {25615},
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
        [25663] = { -- An Offering for Aviana
            [questKeys.preQuestSingle] = {25578},
            [questKeys.objectives] = {nil,{{203147}}},
        },
        [25664] = { -- A Prayer and a Wing
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use Enormous Bird Call"),0,{{"object",203169}}}},
        },
        [25670] = { -- DUN-dun-DUN-dun-DUN-dun
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use Budd's Chain"),0,{{"object",203137}}}},
        },
        [25678] = { -- Pick Your Fate
            [questKeys.objectives] = {{{5996},{5997},{5998}}},
        },
        [25731] = { -- A Bird in Hand
            [questKeys.objectives] = {{{41112,nil,Questie.ICON_TYPE_EVENT},{41112,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25655,25656},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Extinguish the fire"),0,{{"object",460000}}}},
        },
        [25715] = { -- A Closer Look
            [questKeys.triggerEnd] = {"Scout the ships on the Shattershore",{[zoneIDs.BLASTED_LANDS] = {{69,32.7}}}},
        },
        [25740] = { -- Fact-Finding Mission
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25731,25664},
        },
        [25743] = { -- Decisions, Decisions
            [questKeys.objectives] = {nil,{{203194}}},
        },
        [25749] = { -- Not Entirely Unprepared
            [questKeys.objectives] = {nil,nil,nil,nil,{{{41235,46470},41235,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25752] = { -- Swift Action
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25749,25748,25751},
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
        [25776] = { -- Sethria's Demise
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25761,25764},
        },
        [25794] = { -- Undersea Sanctuary
            [questKeys.objectives] = {{{41294,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25798] = { -- Defend the Drill
            [questKeys.triggerEnd] = {"Oil Drilling Rig defended",[zoneIDs.THOUSAND_NEEDLES]={{85.9,44.6},{90.2,50.7},{87.2,49.5},{88.3,44.4}}},
        },
        [25799] = { -- Defend the Drill
            [questKeys.triggerEnd] = {"Oil Drilling Rig defended",[zoneIDs.THOUSAND_NEEDLES]={{85.9,44.6},{90.2,50.7},{87.2,49.5},{88.3,44.4}}},
        },
        [25807] = { -- An Ancient Reborn
            [questKeys.objectives] = {{{41300,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [25810] = { -- The Hatchery Must Burn
            [questKeys.startedBy] = {{41003}},
        },
        [25824] = { -- Debriefing
            [questKeys.objectives] = {{{41340,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25830] = { -- The Last Living Lorekeeper
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25520,25807},
        },
        [25843] = { -- Tortolla's Revenge
            [questKeys.preQuestSingle] = {25372},
            [questKeys.nextQuestInChain] = 25904,
            [questKeys.startedBy] = {{41480}},
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
        [25881] = { -- Lost Wardens
            [questKeys.preQuestSingle] = {25372},
            [questKeys.objectives] = {{{41499,nil,Questie.ICON_TYPE_INTERACT}}},
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
        [25929] = { -- Sea Legs
            [questKeys.preQuestSingle] = {},
        },
        [25930] = { -- Ascending the Vale
            [questKeys.triggerEnd] = {"Ascend the Charred Vale",{[zoneIDs.STONETALON_MOUNTAINS] = {{31.3,73.2}}}},
        },
        [25936] = { -- Pay It Forward
            [questKeys.objectives] = {{{41672,nil,Questie.ICON_TYPE_EVENT}}},
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
        [26000] = { -- Spelunking
            [questKeys.preQuestSingle] = {25794},
        },
        [26007] = { -- Debriefing
            [questKeys.objectives] = {{{41885,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {26000},
        },
        [26008] = { -- Decompression
            [questKeys.preQuestSingle] = {25887},
            [questKeys.objectives] = {{{41955,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26019] = { -- Enormous Eel Egg
            [questKeys.startedBy] = {{41925,41926},nil,{56571}},
            [questKeys.preQuestSingle] = {26015},
        },
        [26021] = { -- The Brothers Digsong 2: Eel-Egg-Trick Boogaloo
            [questKeys.objectives] = {{{41927,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{42006,41927},41927}}},
        },
        [26040] = { -- What? What? In My Gut...?
            [questKeys.preQuestSingle] = {25887},
        },
        [26043] = { -- BEWARE OF CRAGJAW!
            [questKeys.preQuestSingle] = {26004},
        },
        [26050] = { -- Goggle Boggle
            [questKeys.triggerEnd] = {"Defend Professor Phizzlethorpe", {[zoneIDs.ARATHI_HIGHLANDS]={{33.80,80.40}}}},
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
        [26065] = { -- Free Wil'hai
            [questKeys.preQuestSingle] = {26080,26092},
            [questKeys.objectives] = {{{41642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill all three Tentacle Horrors"),0,{{"monster",41641}}}},
        },
        [26068] = { -- Kobold Fury!
            [questKeys.objectives] = {nil,{{203446}}},
        },
        [26070] = { -- Clearing the Defiled
            [questKeys.preQuestSingle] = {25987},
        },
        [26071] = { -- Clearing the Defiled
            [questKeys.preQuestSingle] = {25988},
        },
        [26072] = { -- Into the Totem
            [questKeys.objectives] = {{{42051}}},
            [questKeys.preQuestSingle] = {25987,25988},
        },
        [26079] = { -- Wanted!  Otto and Falconcrest
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26080] = { -- One Last Favor
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26017,26018},
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
        [26096] = { -- Scalding Shrooms
            [questKeys.preQuestSingle] = {25987,25988},
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
        },
        [26121] = { -- Claim Korthun's End
            [questKeys.preQuestSingle] = {27443},
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
            [questKeys.preQuestSingle] = {26006},
            [questKeys.exclusiveTo] = {26124},
        },
        [26126] = { -- The Perfect Fuel
            [questKeys.objectives] = {nil,{{203461}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Three Hammerhead Oil and two Remora Oil"), 0, {{"object", 203461}}}},
            [questKeys.requiredSourceItems] = {56833},
        },
        [26133] = { -- Fiends from the Netherworld
            [questKeys.preQuestSingle] = {26111},
        },
        [26135] = { -- Visions of the Past: Rise from the Deep
            [questKeys.preQuestSingle] = {25973},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Use the Blade to become a naga"),0,{{"object",460005}}}},
            [questKeys.objectives] = {{{41982,nil,Questie.ICON_TYPE_EVENT},{41222}}},
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
            [questKeys.exclusiveTo] = {106},
            [questKeys.nextQuestInChain] = 106,
        },
        [26154] = { -- Twilight Extermination
            [questKeys.objectives] = {{{47969,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{42281,42280},42280},{{42285},42285}}},
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
        },
        [26213] = { -- Hot On the Trail: The Riverpaw Clan
            [questKeys.preQuestSingle] = {26209},
        },
        [26214] = { -- Hot On the Trail: Murlocs
            [questKeys.preQuestSingle] = {26209},
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
        },
        [26228] = { -- Livin' the Life
            [questKeys.triggerEnd] = {"Livin' the Life!", {[zoneIDs.WESTFALL]={{61,25}}}},
        },
        [26229] = { -- "I TAKE Candle!"
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {26215},
        },
        [26230] = { -- Feast or Famine
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {26215},
        },
        [26233] = { -- Stealing From Our Own
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE - raceKeys.TROLL,
        },
        [26234] = { -- Stealing From Our Own
            [questKeys.requiredRaces] = raceKeys.TROLL,
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
        [26254] = { -- Some Spraining to Do
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 42716}}}},
            [questKeys.objectives] = {{{42964,nil,Questie.ICON_TYPE_EVENT}}},
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
        },
        [26265] = { -- Dealing with the Fallout
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26269] = { -- The Green Hills of Stranglethorn
            [questKeys.preQuestSingle] = {583},
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
        },
        [26285] = { -- Get Me Explosives Back!
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26290] = { -- Secrets of the Tower
            [questKeys.objectives] = {{{42662}}},
        },
        [26293] = { -- Machines of War
            [questKeys.startedBy] = {{39605}},
            [questKeys.preQuestSingle] = {},
        },
        [26294] = { -- Weapons of Mass Dysfunction
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{42673},{42671}}},
        },
        [26311] = { -- Unfamiliar Waters
            [questKeys.preQuestSingle] = {},
        },
        [26312] = { -- Crumbling Defenses
            [questKeys.preQuestSingle] = {26326},
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
        },
        [26318] = { -- Finishin' the Job
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.objectives] = {nil,{{204042}},nil,nil,{{{42773},42773}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26284,26285},
        },
        [26320] = { -- A Vision of the Past
            [questKeys.triggerEnd] = {"Vision of the Past uncovered", {[zoneIDs.THE_DEADMINES]={{-1,-1}}}},
        },
        [26324] = { -- Where Is My Warfleet?
            [questKeys.startedBy] = {{39605}},
            [questKeys.preQuestGroup] = {26294,26311},
        },
        [26326] = { -- The Very Earth Beneath Our Feet
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26876,27938},
        },
        [26329] = { -- One More Thing
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26331] = { -- Crushcog's Minions
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26333] = { -- No Tanks!
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26335] = { -- Ready the Navy
            [questKeys.preQuestSingle] = {26324},
        },
        [26337] = { -- Beating the Market
            [questKeys.objectives] = {{{42777}}},
        },
        [26339] = { -- Staging in Brewnall
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26331,26333},
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26342] = { -- Paint it Black
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.objectives] = {{{42291,nil,Questie.ICON_TYPE_INTERACT}}},
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
        [26364] = { -- Down with Crushcog!
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to High Tinker Mekkatorque"),0,{{"monster",42849}}}},
            [questKeys.objectives] = {{{42839}}},
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
        [26388] = { -- Twilight Skies
            [questKeys.extraObjectives] = {{{[zoneIDs.AZSHARA]={{50.7,73.9}}}, Questie.ICON_TYPE_EVENT, l10n("Wait for the Zeppelin")}},
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
        [26397] = { -- Walk With The Earth Mother
            [questKeys.finishedBy] = {{39605}},
            [questKeys.preQuestSingle] = {24540},
            [questKeys.requiredRaces] = raceKeys.TAUREN,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tal"),0,{{"monster",2995}}}},
        },
        [26408] = { -- Ashes in Ashenvale
            [questKeys.preQuestSingle] = {13897},
        },
        [26409] = { -- Where's Goldmine?
            [questKeys.preQuestSingle] = {},
        },
        [26410] = { -- Explosive Bonding Compound
            [questKeys.preQuestSingle] = {26409},
        },
        [26411] = { -- Apply and Flash Dry
            [questKeys.preQuestSingle] = {27135},
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
            [questKeys.preQuestGroup] = {26376,26377},
        },
        [26433] = { -- The Holy Water of Clarity
            [questKeys.exclusiveTo] = {26590},
        },
        [26440] = { -- Clingy
            [questKeys.triggerEnd] = {"Pebble brought to crystal formation",{[zoneIDs.DEEPHOLM]={{29.45,47.47}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {26439},
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
        [26442] = { -- Rock Lobster
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26488,26536},
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
        [26507] = { -- Petrified Delicacies
            [questKeys.preQuestSingle] = {26441},
        },
        [26512] = { -- Tuning the Gnomecorder
            [questKeys.triggerEnd] = {"Test the Gnomecorder at the Lakeshire Graveyard", {[zoneIDs.REDRIDGE_MOUNTAINS]={{32.3,39.5}}}},
        },
        [26536] = { -- Thunder Falls
            [questKeys.exclusiveTo] = {29325,29321,29323,29324,29342,29343,29344,29347,29350,29359,26414,26420,26442,26488},
            [questKeys.extraObjectives] = {{{[zoneIDs.ELWYNN_FOREST]={{26.50,60.57},{24.5,59.57},{21.49,59.4}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Violet Perch")}},
        },
        [26538] = { -- Emergency Aid
            [questKeys.objectives] = {{{43191}}},
        },
        [26549] = { -- Madness
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Negotiations Concluded",{[zoneIDs.TWILIGHT_HIGHLANDS]={{75.5,55.25}}}},
        },
        [26543] = { -- Clammy Hands
            [questKeys.exclusiveTo] = {26572,26557,26556,26588,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
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
        [26566] = { -- A Triumph of Gnomish Ingenuity
            [questKeys.zoneOrSort] = zoneIDs.CHILL_BREEZE_VALLEY,
        },
        [26567] = { -- John J. Keeshan
            [questKeys.preQuestSingle] = {26520},
        },
        [26569] = { -- Surveying Equipment
            [questKeys.preQuestSingle] = {26568},
        },
        [26570] = { -- Render's Army
            [questKeys.preQuestSingle] = {26568},
        },
        [26572] = { -- A Golden Opportunity
            [questKeys.requiredSourceItems] = {58955,58958},
            [questKeys.exclusiveTo] = {26557,26543,26556,26588,29349,29345,29354,29346,29348,29317,29320,29361,29319,29322},
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
        [26590] = { -- The Holy Water of Clarity
            [questKeys.exclusiveTo] = {26433},
        },
        [26591] = { -- Battlefront Triage
            [questKeys.objectives] = {{{43229,"Injured Earthen patched up",Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {26501},
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
            [questKeys.objectives] = {{{43450,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [26619] = { -- You Say You Want a Revolution
            [questKeys.preQuestGroup] = {26540,26608},
        },
        [26621] = { -- Insurrection
            [questKeys.objectives] = {{{43575},{43394}},nil,nil,nil,{{{43577,43578},43577,"Dragonmaw Civilian Armed"}}},
        },
        [26625] = { -- Troggzor the Earthinator
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26564,26591},
        },
        [26627] = { -- The Hermit
            [questKeys.exclusiveTo] = {26653},
        },
        [26628] = { -- Death from Below
            [questKeys.triggerEnd] = {"Defend Shakes O'Breen", {[zoneIDs.ARATHI_HIGHLANDS]={{32.20,81.40}}}},
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
        [26642] = { -- Preserving the Barrens
            [questKeys.exclusiveTo] = {28494},
            [questKeys.nextQuestInChain] = 871,
        },
        [26645] = { -- The Night Watch
            [questKeys.preQuestSingle] = {26618},
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
        [26656] = { -- Don't. Stop. Moving.
            [questKeys.extraObjectives] = {{{[zoneIDs.DEEPHOLM]={{50.61,13.76}}}, Questie.ICON_TYPE_EVENT, l10n("Bring the Opalescent Guardians here")}},
            [questKeys.objectives] = {{{42466,nil,Questie.ICON_TYPE_TALK},{43591,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [26657] = { -- Hard Falls
            [questKeys.preQuestSingle] = {26656},
        },
        [26658] = { -- Fragile Values
            [questKeys.preQuestSingle] = {26656},
        },
        [26659] = { -- Resonating Blow
            [questKeys.objectives] = {{{43641}},{{204837}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {26657,26658},
        },
        [26662] = { -- The Brashtide Crew
            [questKeys.preQuestSingle] = {26650},
        },
        [26663] = { -- Sinking From Within
            [questKeys.preQuestSingle] = {26650},
        },
        [26664] = { -- Making Mutiny
            [questKeys.preQuestSingle] = {26650},
        },
        [26668] = { -- Detonation
            [questKeys.triggerEnd] = {"Blow up Render's Valley.", {[zoneIDs.REDRIDGE_MOUNTAINS]={{77.19,65.64}}}},
        },
        [26683] = { -- Look To The Stars
            [questKeys.preQuestSingle] = {26661},
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
        [26706] = { -- Endgame
            [questKeys.objectives] = {{{43729,"Gunship destroyed",Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get on a Hippogryph"), 0, {{"monster", 43747}}}},
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
        [26717] = { -- The Yorgen Worgen
            [questKeys.preQuestSingle] = {26785},
        },
        [26720] = { -- A Curse We Cannot Lift
            [questKeys.objectives] = {{{43814}}},
        },
        [26723] = { -- The Fate of Morbent Fel
            [questKeys.preQuestSingle] = {26760},
        },
        [26734] = { -- The Source of the Madness
            [questKeys.preQuestSingle] = {26733},
        },
        [26738] = { -- Just Hatched
            [questKeys.preQuestSingle] = {26732},
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
            [questKeys.objectives] = {{{43923}}},
        },
        [26778] = { -- The Cries of the Dead
            [questKeys.preQuestSingle] = {26760},
        },
        [26785] = { -- Part of the Pack
            [questKeys.preQuestSingle] = {26674},
            [questKeys.exclusiveTo] = {26717},
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
        },
        [26830] = { -- Traitor's Bait
            [questKeys.startedBy] = {{39605}},
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{44160},{44120}}},
        },
        [26831] = { -- The Twilight Flight
            [questKeys.finishedBy] = {{44080}},
            [questKeys.preQuestSingle] = {26828},
        },
        [26832] = { -- Therazane's Mercy
            [questKeys.preQuestSingle] = {26828},
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
        [26840] = { -- Return to the Highlands
            [questKeys.startedBy] = {{39605}},
        },
        [26841] = { -- Forbidden Sigil -- Night Elf Mage
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [26858] = { -- Taragaman the Hungerer
            [questKeys.preQuestSingle] = {},
        },
        [26861] = { -- Block the Gates
            [questKeys.preQuestSingle] = {26771},
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
        [26876] = { -- The World Pillar Fragment
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Summon Abyssion"), 0, {{"object", 205205}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Abyssion"), 0, {{"monster", 44289}}},
            },
        },
        [26881] = { -- In Search of Thaelrid
            [questKeys.finishedBy] = {{4787}},
        },
        [26882] = { -- Blackfathom Villainy
            [questKeys.questFlags] = 128,
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
            [questKeys.exclusiveTo] = {25067},
        },
        [26896] = { -- The Thunderdrome!
            [questKeys.exclusiveTo] = {25067},
        },
        [26897] = { -- Blackfathom Deeps
            [questKeys.exclusiveTo] = {26898},
            [questKeys.finishedBy] = {{33260}},
        },
        [26898] = { -- Blackfathom Deeps
            [questKeys.exclusiveTo] = {26897},
            [questKeys.finishedBy] = {{33260}},
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
        [26930] = { -- After the Crusade
            [questKeys.triggerEnd] = {"Scarlet Crusade camp scouted", {[zoneIDs.WESTERN_PLAGUELANDS]={{40.6,52.6}}}},
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
        [26958] = { -- Your First Lesson
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 16503}}}},
            [questKeys.preQuestSingle] = {},
        },
        [26960] = { -- My Son, the Prince
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{1747,nil,Questie.ICON_TYPE_TALK}}},
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
        [27040] = { -- Decryption Made Easy
            [questKeys.finishedBy] = {{100008}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27004,27006},
        },
        [27041] = { -- Decryption Made Easy
            [questKeys.finishedBy] = {{100008}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27004,27006},
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
            [questKeys.finishedBy] = {{44837}},
        },
        [27063] = { -- Looming Threat
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
        [27073] = { -- Give 'em Hell!
            [questKeys.preQuestSingle] = {27065},
        },
        [27082] = { -- Playing Dirty
            [questKeys.preQuestSingle] = {27065},
        },
        [27091] = { -- Charge!
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{100}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Learn Spell: Charge"), 2, {{"monster", 43010}}}},
            [questKeys.zoneOrSort] = 6455,
        },
        [27100] = { -- Twilight Research
            [questKeys.startedBy] = {{43158,44936,44988},nil,{60816}},
            [questKeys.preQuestSingle] = {27007},
        },
        [27106] = { -- A Villain Unmasked
            [questKeys.objectives] = {{{2439,nil,Questie.ICON_TYPE_TALK},{2439}}},
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
        },
        [27136] = { -- Elemental Energy
            [questKeys.objectives] = {nil,nil,nil,nil,{{{43254,43258},43254,"Totem energized"}}},
        },
        [27139] = { -- Hobart Needs You
            [questKeys.exclusiveTo] = {24671},
        },
        [27141] = { -- Exploding Through
            [questKeys.preQuestSingle] = {28112},
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
        [27187] = { -- Do the World a Favor
            [questKeys.finishedBy] = {{100012}},
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
        [27225] = { -- A Summons from Ander Germaine
            [questKeys.exclusiveTo] = {27337},
        },
        [27261] = { -- Questioning Reethe
            [questKeys.triggerEnd] = {"Question Reethe with Ogron", {[zoneIDs.DUSTWALLOW_MARSH]={{42.47,38.07}}}},
        },
        [27273] = { -- An Invitation from Moonglade
            [questKeys.nextQuestInChain] = 27356,
        },
        [27277] = { -- An Audience with Ureda
            [questKeys.nextQuestInChain] = 27400,
        },
        [27278] = { -- Grimshot's Call
            [questKeys.nextQuestInChain] = 27395,
        },
        [27280] = { -- The Dreamseeker Calls
            [questKeys.finishedBy] = {{3344}},
        },
        [27281] = { -- Grezz Ragefist
            [questKeys.exclusiveTo] = {28290,27365,28457},
        },
        [27282] = { -- Zevrost's Behest
            [questKeys.finishedBy] = {{3326}},
        },
        [27283] = { -- A Journey to Moonglade
            [questKeys.nextQuestInChain] = 27404,
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
        [27317] = { -- The Rattle of Bones
            [questKeys.preQuestSingle] = {},
        },
        [27337] = { -- A Fitting Weapon
            [questKeys.startedBy] = {{914}},
            [questKeys.preQuestSingle] = {},
        },
        [27341] = { -- Scouting the Shore
            [questKeys.triggerEnd] = {"Beach Head Control Point Scouted", {[zoneIDs.TWILIGHT_HIGHLANDS]={{77.5,65.2}}}},
            [questKeys.preQuestSingle] = {27338},
        },
        [27344] = { -- A Well-Earned Reward
            [questKeys.startedBy] = {{44247}},
        },
        [27349] = { -- Break in Communications: Dreadwatch Outpost
            [questKeys.triggerEnd] = {"Investigate Dreadwatch Outpost", {[zoneIDs.RUINS_OF_GILNEAS]={{53,32.6}}}},
        },
        [27354] = { -- Mastering the Arcane
            [questKeys.startedBy] = {{331}},
        },
        [27356] = { -- The Circle's Future
            [questKeys.preQuestSingle] = {},
        },
        [27366] = { -- Landgrab
            [questKeys.preQuestSingle] = {27338},
        },
        [27369] = { -- Greasing the Wheel
            [questKeys.preQuestSingle] = {27368},
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
        [27402] = { -- Token of Power
            [questKeys.preQuestSingle] = {},
        },
        [27404] = { -- The Circle's Future
            [questKeys.preQuestSingle] = {},
        },
        [27420] = { -- Postponing the Inevitable
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSourceItems] = {61037},
        },
        [27431] = { -- Tipping the Balance
            [questKeys.objectives] = {{{45296,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27433] = { -- Shredderectomy
            [questKeys.preQuestSingle] = {27338},
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
        [27485] = { -- Warm Welcome
            [questKeys.preQuestSingle] = {27380},
            [questKeys.objectives] = {{{45708,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27490] = { -- SI:7 Drop
            [questKeys.objectives] = {{{45904,nil,Questie.ICON_TYPE_TALK},{45877,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {28248},
        },
        [27491] = { -- Kor'kron Drop
            [questKeys.objectives] = {{{45947},{45877}}},
        },
        [27494] = { -- Move the Mountain
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27490,27492,27496},
            [questKeys.finishedBy] = {{100016}},
        },
        [27496] = { -- Call in the Artillery
            [questKeys.preQuestSingle] = {28248},
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
        [27544] = { -- Cenarion Tenacity
            [questKeys.preQuestSingle] = {27386},
        },
        [27545] = { -- The Way is Open
            [questKeys.preQuestSingle] = {27537},
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
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27562] = { -- Beezil's Cog
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [27564] = { -- In Defense of the Redoubt
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27505,27506},
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
        [27595] = { -- The Prophet Hadassi
            [questKeys.preQuestSingle] = {28135},
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
            [questKeys.objectives] = {{{46100},{46098}}},
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
        [27684] = { -- Visitors
            [questKeys.exclusiveTo] = {27367,27370},
        },
        [27685] = { -- Good Deed Left Undone
            [questKeys.nextQuestInChain] = 25587,
        },
        [27687] = { -- An Opened Can of Whoop Gnash
            [questKeys.startedBy] = {{40987},nil,{62138}},
            [questKeys.preQuestSingle] = {25598},
        },
        [27688] = { -- Distract Them for Me
            [questKeys.preQuestGroup] = {27719,27652,27654},
            [questKeys.exclusiveTo] = {},
        },
        [27689] = { -- Distract Them for Me
            [questKeys.preQuestSingle] = {27655},
            [questKeys.exclusiveTo] = {},
        },
        [27690] = { -- Narkrall, the Drake-Tamer
            [questKeys.preQuestSingle] = {27606},
            [questKeys.exclusiveTo] = {27947},
        },
        [27695] = { -- The Elementium Axe
            [questKeys.preQuestGroup] = {27719,27652,27654},
            [questKeys.exclusiveTo] = {},
        },
        [27696] = { -- The Elementium Axe
            [questKeys.preQuestSingle] = {27689},
            [questKeys.exclusiveTo] = {},
        },
        [27700] = { -- Dragon, Unchained
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27695,27688},
            [questKeys.objectives] = {{{46456,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [27701] = { -- Dragon, Unchained
            [questKeys.preQuestGroup] = {27696,27689},
        },
        [27702] = { -- Coup de Grace
            [questKeys.preQuestSingle] = {27700},
        },
        [27703] = { -- Coup de Grace
            [questKeys.preQuestSingle] = {27701},
        },
        [27704] = { -- Legends of the Sunken Temple
            [questKeys.triggerEnd] = {"Hall of Masks found", {[zoneIDs.THE_TEMPLE_OF_ATAL_HAKKAR]={{74,44.4}}}},
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
            [questKeys.preQuestSingle] = {27798},
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
            [questKeys.objectives] = {{{46496,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.preQuestSingle] = {27742,27743,27744},
            [questKeys.requiredSourceItems] = {62394},
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
        [27760] = { -- Artificial Intelligence
            [questKeys.startedBy] = {{46590,46920,47014},nil,{62483}},
            [questKeys.preQuestSingle] = {28501},
        },
        [27761] = { -- A Disarming Distraction
            [questKeys.objectives] = {nil,{{206395},{206396},{206397}},nil,nil,{{{46888},46888,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {},
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
        [27782] = { -- Mathias Needs You
            [questKeys.preQuestSingle] = {27745},
            [questKeys.nextQuestInChain] = 27784,
        },
        [27783] = { -- Garona Needs You
            [questKeys.preQuestSingle] = {27745},
            [questKeys.nextQuestInChain] = 27786,
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
            [questKeys.preQuestGroup] = {27813,27814},
        },
        [27816] = { -- Personal Request
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27812,27815,27999},
        },
        [27817] = { -- Dropping the Hammer
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 47241}}}},
        },
        [27863] = { -- The Crucible of Carnage: The Bloodeye Bruiser!
            [questKeys.objectives] = {{{46944}}},
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
        [27874] = { -- Aviana's Legacy
            [questKeys.startedBy] = {{40289}},
            [questKeys.preQuestSingle] = {25611,25612},
            [questKeys.exclusiveTo] = {25985},
            [questKeys.nextQuestInChain] = 25663,
        },
        [27901] = { -- They Don't Know What They've Got Here
            [questKeys.requiredSourceItems] = {62608,62610},
            [questKeys.preQuestSingle] = {27899},
            [questKeys.sourceItemId] = 62610,
        },
        [27905] = { -- Tailgunner!
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Escaped the Obelisk of the Sun",{[zoneIDs.ULDUM] = {{54.54,42.08}}}},
        },
        [27922] = { -- Traitors!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Hide behind Neferset Frond"), 0, {{"object", 206579}}}},
        },
        [27925] = { -- Efficient Excavations
            [questKeys.exclusiveTo] = {28132},
            [questKeys.preQuestSingle] = {27899},
        },
        [27926] = { -- Eastern Hospitality
            [questKeys.objectives] = {{{47176,nil,Questie.ICON_TYPE_TALK},{47185,nil,Questie.ICON_TYPE_TALK},{47187,nil,Questie.ICON_TYPE_TALK},{47189,nil,Questie.ICON_TYPE_TALK}}},
        },
        [27929] = { -- Drag 'em Down
            [questKeys.preQuestSingle] = {27690},
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
        },
        [27936] = { -- Bring Down the Avalanche
            [questKeys.preQuestSingle] = {27934},
            [questKeys.nextQuestInChain] = 26499,
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
            [questKeys.preQuestSingle] = {27751,27929},
        },
        [27947] = { -- A Vision of Twilight
            [questKeys.preQuestSingle] = {27751,27929},
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
            [questKeys.exclusiveTo] = {27005,27008},
        },
        [27955] = { -- Eye Spy
            [questKeys.objectives] = {{{47274}}},
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
        [27987] = { -- Cannonball!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [27989] = { -- Ruumbo Demands Honey
            [questKeys.preQuestSingle] = {28100},
            [questKeys.reputationReward] = {},
        },
        [27990] = { -- Battlezone
            [questKeys.objectives] = {{{47778},{47159,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Man the Siege Tank"), 0, {{"monster", 47732}}}},
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
            [questKeys.exclusiveTo] = {27141},
        },
        [27994] = { -- Ruumbo Demands Justice
            [questKeys.preQuestSingle] = {28100},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 8}},
        },
        [27995] = { -- Dance for Ruumbo!
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Ruumbo's Secret Discovered",{[zoneIDs.FELWOOD]={{51.5,83.7}}}},
            [questKeys.reputationReward] = {},
        },
        [27999] = { -- The Fate of the Doyles
            [questKeys.preQuestSingle] = {27808},
        },
        [28001] = { -- A Coward's Due
            [questKeys.preQuestSingle] = {27817},
        },
        [28002] = { -- Crisis Management
            [questKeys.objectives] = {{{47516,nil,Questie.ICON_TYPE_TALK},{47519,nil,Questie.ICON_TYPE_TALK},{47520,nil,Questie.ICON_TYPE_TALK},{47707,nil,Questie.ICON_TYPE_TALK}}},
        },
        [28038] = { -- Blood in the Highlands
            [questKeys.preQuestSingle] = {27955},
            [questKeys.exclusiveTo] = {27863},
        },
        [28041] = { -- Bait and Throttle
            [questKeys.preQuestGroup] = {27751,27929},
        },
        [28043] = { -- How to Maim Your Dragon
            [questKeys.objectives] = {{{47391}}},
        },
        [28046] = { -- Finish The Job
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28050] = { -- Shark Tank
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
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
        [28089] = { -- Warchief's Command: Hillsbrad Foothills!
            [questKeys.exclusiveTo] = {28096},
        },
        [28094] = { -- Paving the Way
            [questKeys.preQuestSingle] = {28097},
        },
        [28096] = { -- Welcome to the Machine
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount the Skeletal Steed"), 0, {{"monster", 47445}}}},
        },
        [28100] = { -- A Talking Totem
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 12}},
        },
        [28101] = { -- Mathias' Command
            [questKeys.preQuestGroup] = {27507,27508,27508},
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
        [28117] = { -- Clearing the Depths
            [questKeys.finishedBy] = {{48039}}, -- temporary until Questie can show multiple turn ins
        },
        [28118] = { -- The Imprisoned Archmage
            [questKeys.finishedBy] = {{48039}}, -- temporary until Questie can show multiple turn ins
        },
        [28120] = { -- Learning From The Past
            [questKeys.finishedBy] = {{48039}}, -- temporary until Questie can show multiple turn ins
        },
        [28122] = { -- A Huge Problem
            [questKeys.finishedBy] = {{48066}}, -- temporary until Questie can show multiple turn ins
        },
        [28130] = { -- Not The Friendliest Town
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [28132] = { -- Efficient Excavations
            [questKeys.preQuestSingle] = {27899},
            [questKeys.startedBy] = {{46993},nil,{62768}},
            [questKeys.exclusiveTo] = {27925},
        },
        [28134] = { -- Impending Retribution
            [questKeys.objectives] = {{{46603,nil,Questie.ICON_TYPE_TALK},{47715,nil,Questie.ICON_TYPE_TALK},{47930,nil,Questie.ICON_TYPE_TALK}}}
        },
        [28137] = { -- Teach A Man To Fish.... Or Steal
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
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
        [28162] = { -- Swamp Bait
            [questKeys.finishedBy] = {{48066}}, -- temporary until Questie can show multiple turn ins
        },
        [28163] = { -- The Leftovers
            [questKeys.finishedBy] = {{48066}}, -- temporary until Questie can show multiple turn ins
            [questKeys.objectives] = {nil,nil,nil,nil,{{{47607,47608,47609,47610},47607},},},
        },
        [28165] = { -- D-Block
            [questKeys.finishedBy] = {{48061}}, -- temporary until Questie can show multiple turn ins
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
        [28175] = { -- Shining Through the Dark
            [questKeys.preQuestSingle] = {28171},
            [questKeys.objectives] = {{{47876,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28176] = { -- Following the Young Home
            [questKeys.preQuestGroup] = {28173,28175,28191},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{47874,nil,Questie.ICON_TYPE_EVENT},{47855,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28185] = { -- D-Svarnos
            [questKeys.finishedBy] = {{48061}}, -- temporary until Questie can show multiple turn ins
        },
        [28186] = { -- Cursed Shackles
            [questKeys.finishedBy] = {{48061}}, -- temporary until Questie can show multiple turn ins
        },
        [28187] = { -- Missed Me By Zhat Much!
            [questKeys.objectives] = {{{47940,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28188] = { -- Prison Revolt
            [questKeys.finishedBy] = {{48074}}, -- temporary until Questie can show multiple turn ins
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
            [questKeys.objectives] = {{{46333,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [28211] = { -- Tempered in Elemental Flame
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28212] = { -- Hot Stuff
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28215] = { -- Potential Energy
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
        },
        [28216] = { -- Magmalord Falthazar
            [questKeys.preQuestGroup] = {27752,27754}, -- could also be 27753
            [questKeys.finishedBy] = {{46591}},
        },
        [28223] = { -- The Warden
            [questKeys.finishedBy] = {{48074}}, -- temporary until Questie can show multiple turn ins
        },
        [28228] = { -- Rejoining the Forest
            [questKeys.triggerEnd] = {"Protector brought to hill", {[zoneIDs.FELWOOD]={{48.7,25.2}}}},
        },
        [28232] = { -- Food From Below
            [questKeys.finishedBy] = {{48074}}, -- temporary until Questie can show multiple turn ins
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
        [28244] = { -- The Eyes Have It
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
        [28267] = { -- Firing Squad
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Commander Schnottz"),0,{{"monster",47972}}}},
            [questKeys.objectives] = {{{48189,nil,Questie.ICON_TYPE_EVENT}}},
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
        [28284] = { -- What's that Rattle?
            [questKeys.exclusiveTo] = {27317},
        },
        [28289] = { -- Moonglade Calls
            [questKeys.nextQuestInChain] = 28343,
        },
        [28290] = { -- Meet with Grezz Ragefist
            [questKeys.exclusiveTo] = {27281,27365,28457},
        },
        [28295] = { -- Meetup with the Caravan
            [questKeys.exclusiveTo] = {28296,28558},
            [questKeys.zoneOrSort] = zoneIDs.TANARIS,
        },
        [28296] = { -- Meetup with the Caravan
            [questKeys.exclusiveTo] = {28295,28557},
            [questKeys.zoneOrSort] = zoneIDs.TANARIS,
        },
        [28299] = { -- Meet with Zevrost
            [questKeys.finishedBy] = {{3326}},
        },
        [28301] = { -- Meet with Kardris Dreamseeker
            [questKeys.finishedBy] = {{3344}},
        },
        [28309] = { -- Meet with Shadow-Walker Zuru
            [questKeys.requiredRaces] = raceKeys.TROLL,
            [questKeys.requiredClasses] = classKeys.PRIEST,
            [questKeys.nextQuestInChain] = 28477,
        },
        [28338] = { -- Deadwood of the North
            [questKeys.preQuestSingle] = {},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 10}},
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
            [questKeys.exclusiveTo] = {28271},
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
        [28394] = { -- The Golem Lord's Creations
            [questKeys.startedBy] = {{44247}},
            [questKeys.finishedBy] = {{44247}},
        },
        [28395] = { -- Feathers for Nafien
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
        },
        [28403] = { -- Bad Datas
            [questKeys.triggerEnd] = {"Titan Data Uploaded",{[zoneIDs.ULDUM]={{36.18,23.25}}}},
            [questKeys.objectives] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 48528}}}},
        },
        [28404] = { -- I'll Do It By Hand
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat the defenses"), 0, {{"monster", 48529}}}},
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
        },
        [28414] = { -- Fourth and Goal
            [questKeys.objectives] = {{{37203,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.startedBy] = {{37106,100006}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 48526}}}},
            [questKeys.exclusiveTo] = {24503},
        },
        [28458] = { -- The Pyromancer's Grimoire
            [questKeys.preQuestSingle] = {},
        },
        [28459] = { -- Stones of Binding
            [questKeys.finishedBy] = {{3326}},
        },
        [28460] = { -- Threat of the Winterfall
            [questKeys.preQuestSingle] = {},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 10}},
        },
        [28465] = { -- Slaves of the Firelord
            [questKeys.finishedBy] = {{3344}},
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
        [28477] = { -- Twilight Scheming
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceKeys.TROLL,
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
        [28504] = { -- Warchief's Command: Thousand Needles!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 43,
        },
        [28509] = { -- Warchief's Command: Tanaris!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 48,
        },
        [28510] = { -- Warchief's Command: Feralas!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28521] = { -- Speak to Salfa
            [questKeys.preQuestGroup] = {28362,28364,28338,28366},
            [questKeys.exclusiveTo] = {28522,28524},
        },
        [28523] = { -- More Beads for Salfa
            [questKeys.preQuestSingle] = {28522},
            [questKeys.reputationReward] = {{factionIDs.TIMBERMAW_HOLD, 11}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [28524] = { -- Delivery for Donova
            [questKeys.exclusiveTo] = {28544,28545,28460,28768},
        },
        [28526] = { -- Warchief's Command: Un'Goro Crater!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 53,
        },
        [28527] = { -- Warchief's Command: Silithus!
            [questKeys.objectives] = {},
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
        },
        [28533] = { -- The High Council's Decision
            [questKeys.preQuestGroup] = {27738,27838,28291},
            [questKeys.preQuestSingle] = {},
        },
        [28542] = { -- Warchief's Command: Felwood!
            [questKeys.requiredMaxLevel] = 48,
        },
        [28544] = { -- Hero's Call: Winterspring!
            [questKeys.exclusiveTo] = {28524,28545,28460,28768},
        },
        [28545] = { -- Warchief's Command: Winterspring!
            [questKeys.exclusiveTo] = {28524,28544,28460,28768},
            [questKeys.requiredMaxLevel] = 53,
        },
        [28548] = { -- Warchief's Command: Desolace!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28549] = { -- Warchief's Command: Southern Barrens!
            [questKeys.objectives] = {},
            [questKeys.requiredMaxLevel] = 33,
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
        [28560] = { -- Warchief's Command: Ghostlands!
            [questKeys.exclusiveTo] = {9144,9327,9329},
            [questKeys.requiredMaxLevel] = 18,
        },
        [28561] = { -- Nahom Must Hold
            [questKeys.preQuestSingle] = {28533},
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
        [28574] = { -- Warchief's Command: The Hinterlands!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28575] = { -- Warchief's Command: Western Plaguelands!
            [questKeys.requiredMaxLevel] = 38,
        },
        [28577] = { -- Warchief's Command: Eastern Plaguelands!
            [questKeys.requiredMaxLevel] = 43,
        },
        [28580] = { -- Warchief's Command: Badlands!
            [questKeys.requiredMaxLevel] = 47,
        },
        [28581] = { -- Warchief's Command: Searing Gorge!
            [questKeys.startedBy] = {nil,{207324,207325}},
            [questKeys.requiredMaxLevel] = 48,
        },
        [28584] = { -- Quality Construction
            [questKeys.preQuestSingle] = {28583},
            [questKeys.objectives] = {nil,{{207298}}},
        },
        [28586] = { -- Pool Pony Rescue
            [questKeys.preQuestSingle] = {28583},
        },
        [28592] = { -- Parting Packages
            [questKeys.preQuestSingle] = {28591},
        },
        [28597] = { -- Burnin' at Both Ends
            [questKeys.preQuestSingle] = {28596},
        },
        [28598] = { -- Burnin' at Both Ends
            [questKeys.objectives] = {nil,{{207277,nil,Questie.ICON_TYPE_EVENT}},nil,nil,{{{49212},49212}}},
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
            [questKeys.extraObjectives] = {{{[zoneIDs.ULDUM]={{51.4,39.7}}}, Questie.ICON_TYPE_EVENT, l10n("Dive into the underwater cave")}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27836,27837},
        },
        [28612] = { -- Harrison Jones and the Temple of Uldum
            [questKeys.objectives] = {nil,{{205939}}},
        },
        [28622] = { -- Three if by Air
            [questKeys.objectives] = {{{49211,nil,Questie.ICON_TYPE_EVENT},{49215,nil,Questie.ICON_TYPE_EVENT},{49216,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28635] = { -- A Haunting in Hillsbrad
            [questKeys.triggerEnd] = {"Search Dun Garok for Evidence of a Haunting", {[zoneIDs.HILLSBRAD_FOOTHILLS]={{61.9,84.5}}}},
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
        [28657] = { -- A Huge Problem
            [questKeys.finishedBy] = {{48069}}, -- temporary until Questie can show multiple turn ins
        },
        [28658] = { -- Swamp Bait
            [questKeys.finishedBy] = {{48069}}, -- temporary until Questie can show multiple turn ins
        },
        [28659] = { -- The Leftovers
            [questKeys.finishedBy] = {{48069}}, -- temporary until Questie can show multiple turn ins
            [questKeys.objectives] = {nil,nil,nil,nil,{{{47595,47598,47599,47600},47595}}},
        },
        [28660] = { -- Clearing the Depths
            [questKeys.finishedBy] = {{48071}}, -- temporary until Questie can show multiple turn ins
        },
        [28661] = { -- The Imprisoned Archmage
            [questKeys.finishedBy] = {{48071}}, -- temporary until Questie can show multiple turn ins
        },
        [28662] = { -- Learning From The Past
            [questKeys.finishedBy] = {{48071}}, -- temporary until Questie can show multiple turn ins
        },
        [28663] = { -- D-Block
            [questKeys.finishedBy] = {{48070}}, -- temporary until Questie can show multiple turn ins
        },
        [28664] = { -- Svarnos
            [questKeys.finishedBy] = {{48070}}, -- temporary until Questie can show multiple turn ins
        },
        [28665] = { -- Cursed Shackles
            [questKeys.finishedBy] = {{48070}}, -- temporary until Questie can show multiple turn ins
        },
        [28667] = { -- Warchief's Command: Burning Steppes!
            [questKeys.requiredMaxLevel] = 51,
        },
        [28668] = { -- Prison Revolt
            [questKeys.finishedBy] = {{48062}}, -- temporary until Questie can show multiple turn ins
        },
        [28669] = { -- The Warden
            [questKeys.finishedBy] = {{48062}}, -- temporary until Questie can show multiple turn ins
        },
        [28670] = { -- Food From Below
            [questKeys.finishedBy] = {{48062}}, -- temporary until Questie can show multiple turn ins
        },
        [28671] = { -- Warchief's Command: Blasted Lands!
            [questKeys.startedBy] = {nil,{207324,207325}},
            [questKeys.requiredMaxLevel] = 57,
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
        [28700] = { -- Taking the Overlook Back
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [28704] = { -- Warchief's Command: The Cape of Stranglethorn!
            [questKeys.requiredMaxLevel] = 33,
        },
        [28705] = { -- Warchief's Command: Outland!
            [questKeys.requiredMaxLevel] = 67,
        },
        [28708] = { -- Hero's Call: Outland!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
        },
        [28709] = { -- Hero's Call: Borean Tundra!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
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
        },
        [28737] = { -- What Is This Place?
            [questKeys.nextQuestInChain] = 28738,
        },
        [28738] = { -- The Twilight Forge
            [questKeys.nextQuestInChain] = 28740,
        },
        [28740] = { -- Do My Eyes Deceive Me?
            [questKeys.nextQuestInChain] = 28741,
        },
        [28755] = { -- Annals of the Silver Hand
            [questKeys.preQuestSingle] = {27464},
            [questKeys.requiredMaxRep] = {529,42999},
        },
        [28756] = { -- Aberrations of Bone
            [questKeys.objectives] = {{{11622}}},
            [questKeys.preQuestSingle] = {27464},
            [questKeys.requiredMaxRep] = {529,42999},
            [questKeys.zoneOrSort] = zoneIDs.SCHOLOMANCE,
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
            [questKeys.startedBy] = {{42465}},
            [questKeys.finishedBy] = {{42465}},
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
        [28832] = { -- Twilight Shores
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 50262}}}},
        },
        [28845] = { -- The Vortex Pinnacle
            [questKeys.exclusiveTo] = {28760,28779},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {27520,27519,27706},
        },
        [28849] = { -- Twilight Skies
            [questKeys.preQuestGroup] = {26337,26372,26374},
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
        [28869] = { -- Pebble
            [questKeys.nextQuestInChain] = 26440,
            [questKeys.preQuestGroup] = {26437,26438,26439},
        },
        [28870] = { -- Return to the Lost City
            [questKeys.preQuestSingle] = {28520},
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
            [questKeys.childQuests] = {29035,29037,29038,29039,29040,29051,29052,29053},
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
        [29037] = { -- Hunting Practice
            [questKeys.startedBy] = {}, -- we need this too, even while blacklisted, or it shows due to childQuests logic
            --[questKeys.requiredRaces] = raceKeys.DRAENEI + raceKeys.GNOME + raceKeys.NIGHT_ELF, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29038,29039,29040,29051,29052,29053},
        },
        [29038] = { -- 'Borrowing' From the Winterfall
            [questKeys.startedBy] = {}, -- we need this too, even while blacklisted, or it shows due to childQuests logic
            [questKeys.requiredSourceItems] = {68645},
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.DRAENEI + raceKeys.GNOME + raceKeys.NIGHT_ELF, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.exclusiveTo] = {29035,29037,29039,29040,29051,29052,29053},
        },
        [29039] = { -- Hunting Practice
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
            [questKeys.sourceItemId] = 68668,
            [questKeys.exclusiveTo] = {29035,29037,29038,29039,29051,29052,29053},
        },
        [29051] = { -- Cub's First Toy
            [questKeys.objectives] = {{{51677,nil,Questie.ICON_TYPE_INTERACT}}},
            --[questKeys.requiredRaces] = raceKeys.HUMAN + raceKeys.DWARF + raceKeys.WORGEN, -- these are the correct races
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE, -- but we use these so we only show the quests once.
            [questKeys.parentQuest] = 29034,
            [questKeys.requiredSourceItems] = {68662,68663,68668},
            [questKeys.sourceItemId] = 68668,
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
        [29066] = { -- Good News... and Bad News
            [questKeys.startedBy] = {},
            [questKeys.preQuestSingle] = {25428},
            [questKeys.nextQuestInChain] = 25830,
        },
        [29067] = { -- Potion Master
            [questKeys.name] = "Potion Master",
            [questKeys.objectivesText] = {"Bring a large supply of potions to an alchemy trainer in any capital city."},
            [questKeys.objectives] = {nil,nil,{{57191},{57192},{58488}}},
            [questKeys.exclusiveTo] = {29481,29482},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29071] = { -- Make Haste to Stormwind!
            [questKeys.exclusiveTo] = {25316}, -- it's not this one, needs to be discovered the actual one. Also no HS to Dalaran, that's silly
        },
        [29073] = { -- Make Haste to Orgrimmar!
            [questKeys.exclusiveTo] = {25316}, -- same as above
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
        [29102] = { -- To Fort Livingston
            [questKeys.triggerEnd] = {"Head to Fort Livingston in Northern Stranglethorn Vale.", {[zoneIDs.STRANGLETHORN_VALE]={{52.8,67.2}}}},
        },
        [29106] = { -- The Biggest Diamond Ever!
            [questKeys.triggerEnd] = {"Visit King Magni in Old Ironforge", {[zoneIDs.IRONFORGE]={{33.17,47.65}}}},
            [questKeys.preQuestSingle] = {1468},
        },
        [29107] = { -- Malfurion Has Returned!
            [questKeys.objectives] = {{{43845,"Visit Malfurion Stormrage with your orphan",Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {1468},
        },
        [29117] = { -- Let's Go Fly a Kite
            [questKeys.triggerEnd] = {"Fly Dragon Kites with your orphan", {[zoneIDs.STORMWIND_CITY]={{59.2,63.4}}}},
            [questKeys.preQuestGroup] = {29093,29106,29107},
            [questKeys.requiredSourceItems] = {18598,68890},
        },
        [29119] = { -- You Scream, I Scream...
            [questKeys.triggerEnd] = {"Take your orphan out for ice cream.", {[zoneIDs.STORMWIND_CITY]={{49.28,89.8}}}},
            [questKeys.preQuestGroup] = {29093,29106,29107},
            [questKeys.requiredSourceItems] = {18598,69027},
        },
        [29129] = { -- A Legendary Engagement
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Ziradormi"),0,{{"monster",52382}}}},
        },
        [29132] = { -- A Legendary Engagement
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Coridormi"),0,{{"monster",52408}}}},
        },
        [29134] = { -- A Wrinkle in Time
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Anachronos"),0,{{"monster",15192}}}},
        },
        [29146] = { -- Ridin' the Rocketway
            [questKeys.objectives] = {{{52585,nil,Questie.ICON_TYPE_MOUNT_UP}}},
            [questKeys.preQuestSingle] = {172},
        },
        [29156] = { -- The Troll Incursion
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
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
        [29190] = { -- Let's Go Fly a Kite
            [questKeys.triggerEnd] = {"Fly Dragon Kites with your orphan", {[zoneIDs.ORGRIMMAR]={{58.5,58.3}}}},
            [questKeys.preQuestGroup] = {29146,29167,29176},
            [questKeys.requiredSourceItems] = {18597,69231},
        },
        [29191] = { -- You Scream, I Scream...
            [questKeys.triggerEnd] = {"Take your orphan out for ice cream.", {[zoneIDs.ORGRIMMAR]={{38.56,86.7}}}},
            [questKeys.preQuestGroup] = {29146,29167,29176},
            [questKeys.requiredSourceItems] = {18597,69233},
        },
        [29220] = { -- To Bambala
            [questKeys.triggerEnd] = {"Head to Bambala in Northern Stranglethorn Vale.", {[zoneIDs.STRANGLETHORN_VALE]={{64.6,40.4}}}},
        },
        [29298] = { -- A Smoke-Stained Locket
            [questKeys.startedBy] = {nil,nil,{69854}},
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
        },
        [29327] = { -- Elemental Bonds: Doubt
            [questKeys.nextQuestInChain] = 29336,
        },
        [29328] = { -- Elemental Bonds: Desire
            [questKeys.objectives] = {{{53646},{53647}}},
            [questKeys.preQuestSingle] = {29336},
            [questKeys.nextQuestInChain] = 29337,
        },
        [29329] = { -- Elemental Bonds: Patience
            [questKeys.preQuestSingle] = {29337},
            [questKeys.nextQuestInChain] = 29338,
        },
        [29330] = { -- Elemental Bonds: Fury
            [questKeys.preQuestSingle] = {29338},
            [questKeys.nextQuestInChain] = 29331,
        },
        [29331] = { -- Elemental Bonds: The Vow
            [questKeys.preQuestSingle] = {29330},
        },
        [29335] = { -- Into Slashing Winds
            [questKeys.nextQuestInChain] = 29327,
        },
        [29336] = { -- Into Coaxing Tides
            [questKeys.preQuestSingle] = {29327},
            [questKeys.nextQuestInChain] = 29328,
        },
        [29337] = { -- Into Constant Earth
            [questKeys.nextQuestInChain] = 29329,
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
            [questKeys.sourceItemId] = 69998,
            [questKeys.requiredSourceItems] = {69995,69998,69999},
            [questKeys.extraObjectives] = {{{[zoneIDs.TIRISFAL_GLADES]={{61.4,68.6}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Alliance Decoy Kit in the Ruins of Lordaeron and feed the Moat Monster")}},
        },
        [29363] = { -- Mulgore Spice Bread
            [questKeys.extraObjectives] = {{{[zoneIDs.THUNDER_BLUFF]={{51.3,52.9}}}, Questie.ICON_TYPE_EVENT, l10n("Cook 5 Spice Bread and combine with Mulgore Spices")}},
        },
        [29371] = { -- A Time to Lose
            [questKeys.objectives] = {nil,{{209140}}},
        },
        [29377] = { -- A Time to Break Down
            [questKeys.objectives] = {nil,{{209139}}},
        },
        [29387] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
        },
        [29391] = { -- Guardians of Hyjal: Call of the Ancients
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322}},
        },
        [29392] = { -- Missing Heirlooms
            [questKeys.triggerEnd] = {"Search the courier's cabin", {[zoneIDs.STORMWIND_CITY]={{41.4,72.5}}}},
        },
        [29415] = { -- Missing Heirlooms
            [questKeys.triggerEnd] = {"Search the courier's cabin", {[zoneIDs.DUROTAR]={{60,46.1}}}},
        },
        [29434] = { -- Tonk Commander
            [questKeys.objectives] = {{{33081}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Finlay Coolshot to start the game"),0,{{"monster",54605}}}},
        },
        [29436] = { -- The Humanoid Cannonball
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Maxima Blastenheimer to start the game"),0,{{"monster",15303}}}},
        },
        [29438] = { -- He Shoots, He Scores!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Rinling to start the game"),0,{{"monster",14841}}}},
        },
        [29439] = { -- The Call of the World-Shaman
            [questKeys.exclusiveTo] = {29326},
            [questKeys.nextQuestInChain] = 29326,
        },
        [29440] = { -- The Call of the World-Shaman
            [questKeys.exclusiveTo] = {29326},
            [questKeys.nextQuestInChain] = 29326,
        },
        [29452] = { -- Your Time Has Come
            [questKeys.nextQuestInChain] = 29129,
        },
        [29453] = { -- Your Time Has Come
            [questKeys.nextQuestInChain] = 29132,
        },
        [29455] = { -- Target: Turtle
            [questKeys.objectives] = {{{54490}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Jessica Rogers to start the game"),0,{{"monster",54485}}}},
        },
        [29463] = { -- It's Hammer Time
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mola to start the game"),0,{{"monster",54601}}}},
        },
        [29464] = { -- Tools of Divination
            [questKeys.startedBy] = {nil,nil,{71716}},
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
            [questKeys.exclusiveTo] = {29067,29482},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29482] = { -- Transmutation Master
            [questKeys.requiredLevel] = 75,
            [questKeys.objectives] = {nil,nil,{{58480}}},
            [questKeys.exclusiveTo] = {29067,29481},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29506] = { -- A Fizzy Fusion
            [questKeys.objectives] = {nil,{{460001}}},
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,75},
        },
        [29507] = { -- Fun for the Little Ones
            [questKeys.startedBy] = {{14847}},
            [questKeys.objectives] = {nil,{{460001}}},
            [questKeys.requiredSkill] = {profKeys.ARCHAEOLOGY,75},
        },
        [29508] = { -- Baby Needs Two Pair of Shoes
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,75},
        },
        [29509] = { -- Putting the Crunch in the Frog
            [questKeys.requiredSkill] = {profKeys.COOKING,75},
        },
        [29510] = { -- Putting Trash to Good Use
            [questKeys.requiredSourceItems] = {72018},
            [questKeys.requiredSkill] = {profKeys.ENCHANTING,75},
        },
        [29511] = { -- Talkin' Tonks
            [questKeys.objectives] = {{{54504,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSkill] = {profKeys.ENGINEERING,75},
        },
        [29512] = { -- Putting the Carnies Back Together Again
            [questKeys.objectives] = {{{54518,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSkill] = {profKeys.FIRST_AID,75},
        },
        [29513] = { -- Spoilin' for Salty Sea Dogs
            [questKeys.requiredSkill] = {profKeys.FISHING,75},
            [questKeys.extraObjectives] = {{{[zoneIDs.DARKMOON_FAIRE_ISLAND]={{53.2,89.5}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Great Sea Herring")}},
        },
        [29514] = { -- Herbs for Healing
            [questKeys.requiredSkill] = {profKeys.HERBALISM,75},
        },
        [29515] = { -- Writing the Future
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,75},
        },
        [29516] = { -- Keeping the Faire Sparkling
            [questKeys.requiredSourceItems] = {72052},
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,75},
        },
        [29517] = { -- Eyes on the Prizes
            [questKeys.requiredSkill] = {profKeys.LEATHERWORKING,75},
        },
        [29518] = { -- Rearm, Reuse, Recycle
            [questKeys.requiredSkill] = {profKeys.MINING,75},
        },
        [29519] = { -- Tan My Hide
            [questKeys.requiredSkill] = {profKeys.SKINNING,75},
        },
        [29520] = { -- Rearm, Reuse, Recycle
            [questKeys.requiredSkill] = {profKeys.TAILORING,75},
        },
        [29536] = { -- Heart of Rage
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.THE_BLOOD_FURNACE]={{64.9,41.5}}}},
        },
        [29539] = { -- Heart of Rage
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.THE_BLOOD_FURNACE]={{64.9,41.5}}}},
        },
        [29642] = { -- Trouble at Auchindoun
            [questKeys.exclusiveTo] = {10094,10177},
            [questKeys.nextQuestInChain] = 29643,
        },
        [29684] = { -- Severed Communications
            [questKeys.objectives] = {{{24822,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29692] = { -- Bring Me Another Shrubbery!
            [questKeys.preQuestSingle] = {29691},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [29829] = { -- Discretion is Key
            [questKeys.exclusiveTo] = {29830},
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
            [questKeys.finishedBy] = {{3347}},
            --[questKeys.finishedBy] = {{3347,3009,4611,16642}}, -- TODO: Add when multiple turn-in locations are handled
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
            [questKeys.finishedBy] = {{3347}},
            --[questKeys.finishedBy] = {{3347,3009,4611,16642}}, -- TODO: Add when multiple turn-in locations are handled
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{3347}},
            [questKeys.finishedBy] = {{3347}},
            --[questKeys.finishedBy] = {{3347,3009,4611,16642}}, -- TODO: Add when multiple turn-in locations are handled
        },
    }

    local questFixesAlliance = {
        [25513] = { -- Thunderdrome: Grudge Match!
            [questKeys.preQuestSingle] = {25065,25095},
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
            [questKeys.finishedBy] = {{5499}},
            --[questKeys.finishedBy] = {{5499,1537,4160,16723}}, -- TODO: Add when multiple turn-in locations are handled
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
            [questKeys.finishedBy] = {{5499}},
            --[questKeys.finishedBy] = {{5499,1537,4160,16723}}, -- TODO: Add when multiple turn-in locations are handled
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{5499}},
            [questKeys.finishedBy] = {{5499}},
            --[questKeys.finishedBy] = {{5499,1537,4160,16723}}, -- TODO: Add when multiple turn-in locations are handled
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
