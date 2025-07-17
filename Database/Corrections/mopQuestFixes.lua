---@class MopQuestFixes
local MopQuestFixes = QuestieLoader:CreateModule("MopQuestFixes")

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

QuestieCorrections.spellObjectiveFirst[10068] = true
QuestieCorrections.spellObjectiveFirst[10069] = true
QuestieCorrections.spellObjectiveFirst[10070] = true
QuestieCorrections.spellObjectiveFirst[10071] = true
QuestieCorrections.spellObjectiveFirst[10072] = true
QuestieCorrections.spellObjectiveFirst[10073] = true
QuestieCorrections.spellObjectiveFirst[24526] = true
QuestieCorrections.spellObjectiveFirst[24527] = true
QuestieCorrections.spellObjectiveFirst[24528] = true
QuestieCorrections.spellObjectiveFirst[24530] = true
QuestieCorrections.spellObjectiveFirst[24531] = true
QuestieCorrections.spellObjectiveFirst[24532] = true
QuestieCorrections.spellObjectiveFirst[24533] = true
QuestieCorrections.spellObjectiveFirst[24964] = true
QuestieCorrections.spellObjectiveFirst[24965] = true
QuestieCorrections.spellObjectiveFirst[24966] = true
QuestieCorrections.spellObjectiveFirst[24967] = true
QuestieCorrections.spellObjectiveFirst[24968] = true
QuestieCorrections.spellObjectiveFirst[24969] = true
QuestieCorrections.spellObjectiveFirst[26904] = true
QuestieCorrections.spellObjectiveFirst[26913] = true
QuestieCorrections.spellObjectiveFirst[26914] = true
QuestieCorrections.spellObjectiveFirst[26915] = true
QuestieCorrections.spellObjectiveFirst[26916] = true
QuestieCorrections.spellObjectiveFirst[26918] = true
QuestieCorrections.spellObjectiveFirst[26919] = true
QuestieCorrections.spellObjectiveFirst[26940] = true
QuestieCorrections.spellObjectiveFirst[26945] = true
QuestieCorrections.spellObjectiveFirst[26946] = true
QuestieCorrections.spellObjectiveFirst[26947] = true
QuestieCorrections.spellObjectiveFirst[26948] = true
QuestieCorrections.spellObjectiveFirst[26949] = true
QuestieCorrections.spellObjectiveFirst[26958] = true
QuestieCorrections.spellObjectiveFirst[26963] = true
QuestieCorrections.spellObjectiveFirst[26966] = true
QuestieCorrections.spellObjectiveFirst[26968] = true
QuestieCorrections.spellObjectiveFirst[26969] = true
QuestieCorrections.spellObjectiveFirst[26970] = true
QuestieCorrections.spellObjectiveFirst[27091] = true
QuestieCorrections.killCreditObjectiveFirst[29555] = true
QuestieCorrections.objectObjectiveFirst[29730] = true
QuestieCorrections.spellObjectiveFirst[31142] = true
QuestieCorrections.spellObjectiveFirst[31147] = true
QuestieCorrections.spellObjectiveFirst[31151] = true
QuestieCorrections.spellObjectiveFirst[31169] = true
QuestieCorrections.spellObjectiveFirst[31171] = true
QuestieCorrections.spellObjectiveFirst[31173] = true

function MopQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local profKeys = QuestieProfessions.professionKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local specialFlags = QuestieDB.specialFlags
    local questFlags = QuestieDB.questFlags

    return {
        [3095] = { -- Simple Scroll
            [questKeys.requiredLevel] = 2,
        },
        [3096] = { -- Encrypted Scroll
            [questKeys.requiredLevel] = 2,
        },
        [3097] = { -- Hallowed Scroll
            [questKeys.requiredLevel] = 2,
        },
        [3098] = { -- Glyphic Scroll
            [questKeys.requiredLevel] = 2,
        },
        [3099] = { -- Tainted Scroll
            [questKeys.requiredLevel] = 2,
        },
        [3100] = { -- Simple Letter
            [questKeys.requiredLevel] = 2,
        },
        [3101] = { -- Consecrated Letter
            [questKeys.requiredLevel] = 2,
        },
        [3102] = { -- Encrypted Letter
            [questKeys.requiredLevel] = 2,
        },
        [3103] = { -- Hallowed Letter
            [questKeys.requiredLevel] = 2,
        },
        [3104] = { -- Glyphic Letter
            [questKeys.requiredLevel] = 2,
        },
        [3105] = { -- Tainted Letter
            [questKeys.requiredLevel] = 2,
        },
        [3106] = { -- Simple Rune
            [questKeys.requiredLevel] = 2,
        },
        [3107] = { -- Consecrated Rune
            [questKeys.requiredLevel] = 2,
        },
        [3108] = { -- Etched Rune
            [questKeys.requiredLevel] = 2,
        },
        [3109] = { -- Encrypted Rune
            [questKeys.requiredLevel] = 2,
        },
        [3110] = { -- Hallowed Rune
            [questKeys.requiredLevel] = 2,
        },
        [3115] = { -- Tainted Rune
            [questKeys.requiredLevel] = 2,
        },
        [3116] = { -- Simple Sigil
            [questKeys.requiredLevel] = 2,
        },
        [3117] = { -- Etched Sigil
            [questKeys.requiredLevel] = 2,
        },
        [3118] = { -- Encrypted Sigil
            [questKeys.requiredLevel] = 2,
        },
        [3119] = { -- Hallowed Sigil
            [questKeys.requiredLevel] = 2,
        },
        [3120] = { -- Verdant Sigil
            [questKeys.requiredLevel] = 2,
        },
        [8327] = { -- Report to Lanthan Perilon
            [questKeys.nextQuestInChain] = 0,
        },
        [8328] = { -- Mage Training
            [questKeys.requiredLevel] = 2,
        },
        [8329] = { -- Warrior Training
            [questKeys.requiredLevel] = 2,
        },
        [8334] = { -- Aggression
            [questKeys.preQuestSingle] = {8326},
        },
        [8345] = { -- The Shrine of Dath'Remar
            [questKeys.preQuestSingle] = {},
        },
        [8563] = { -- Warlock Training
            [questKeys.requiredLevel] = 2,
        },
        [8564] = { -- Priest Training
            [questKeys.requiredLevel] = 2,
        },
        [9392] = { -- Rogue Training
            [questKeys.requiredLevel] = 2,
        },
        [9393] = { -- Hunter Training
            [questKeys.requiredLevel] = 2,
        },
        [9676] = { -- Paladin Training
            [questKeys.requiredLevel] = 2,
        },
        [10068] = { -- Frost Nova
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [10069] = { -- Ways of the Light
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{105361}}},
            [questKeys.extraObjectives] = {},
        },
        [10070] = { -- Steady Shot
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [10071] = { -- Evisceration
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [10072] = { -- Learning the Word
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [10073] = { -- Corruption
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [13408] = { -- Hellfire Fortifications
            [questKeys.requiredClasses] = 2015, -- all classes except DK
        },
        [13409] = { -- Hellfire Fortifications
            [questKeys.requiredClasses] = 2015, -- all classes except DK
        },
        [24494] = { -- Empowered Rune
            [questKeys.requiredLevel] = 2,
        },
        [24496] = { -- Arcane Rune
            [questKeys.requiredLevel] = 2,
        },
        [24526] = { -- Filling Up the Spellbook
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [24527] = { -- Your Path Begins Here
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24528] = { -- The Power of the Light
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{105361}}},
            [questKeys.extraObjectives] = {},
        },
        [24530] = { -- Oh, A Hunter's Life For Me
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24531] = { -- Getting Battle-Ready
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24532] = { -- Evisceratin' the Enemy
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24533] = { -- Words of Power
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [24961] = { -- The Truth of the Grave
            [questKeys.breadcrumbs] = {28651,31148},
        },
        [24962] = { -- Trail-Worn Scroll
            [questKeys.requiredLevel] = 2,
        },
        [24964] = { -- The Thrill of the Hunt
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24965] = { -- Magic Training
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [24966] = { -- Of Light and Shadows
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [24967] = { -- Stab!
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24968] = { -- Dark Deeds
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [24969] = { -- Charging into Battle
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26389] = { -- Blackrock Invasion
            [questKeys.preQuestSingle] = {28817,28818,28819,28820,28821,28822,28823,29083,31145},
        },
        [26391] = { -- Extinguishing Hope
            [questKeys.preQuestSingle] = {28817,28818,28819,28820,28821,28822,28823,29083,31145},
        },
        [26841] = { -- Forbidden Sigil
            [questKeys.requiredLevel] = 2,
        },
        [26904] = { -- Corruption
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [26910] = { -- Etched Letter
            [questKeys.requiredLevel] = 2,
        },
        [26913] = { -- Charging into Battle
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26914] = { -- Corruption
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [26915] = { -- The Deepest Cut
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26916] = { -- Mastering the Arcane
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [26917] = { -- The Hunter's Path
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26918] = { -- The Power of the Light
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{105361}}},
            [questKeys.extraObjectives] = {},
        },
        [26919] = { -- Learning the Word
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [26940] = { -- Frost Nova
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [26945] = { -- Learning New Techniques
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26946] = { -- A Rogue's Advantage
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26947] = { -- A Woodsman's Training
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26948] = { -- Moonfire
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{8921}}},
            [questKeys.extraObjectives] = {},
        },
        [26949] = { -- Learning the Word
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [26958] = { -- Your First Lesson
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26963] = { -- Steadying Your Shot
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26966] = { -- The Light's Power
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{105361}}},
            [questKeys.extraObjectives] = {},
        },
        [26968] = { -- Frost Nova
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [26969] = { -- Primal Strike
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26970] = { -- Learning the Word
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [27091] = { -- Charge!
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [27670] = { -- Pinned Down
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [27671] = { -- See to the Survivors
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [28167] = { -- Report to Carvo Blastbolt
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [28169] = { -- Withdraw to the Loading Room!
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [28651] = { -- Novice Elreth
            [questKeys.exclusiveTo] = {31148},
            [questKeys.preQuestSingle] = {24964,24965,24966,24967,24968,24969,31147},
            [questKeys.nextQuestInChain] = 24961,
            [questKeys.breadcrumbForQuestId] = 24961,
        },
        [28723] = { -- Priestess of the Moon
            [questKeys.startedBy] = {{3593,3594,3595,3596,3597,43006,63331}},
            [questKeys.preQuestSingle] = {26940,26945,26946,26947,26948,26949,31169},
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28724] = { -- Iverron's Antidote
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28725] = { -- The Woodland Protector
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28726] = { -- Webwood Corruption
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28727] = { -- Vile Touch
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28728] = { -- Signs of Things to Come
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28729] = { -- Teldrassil: Crown of Azeroth
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28730] = { -- Precious Waters
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28731] = { -- Teldrassil: Passing Awareness
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.MAGE + classIDs.DRUID + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- night elf DKs don't get these quests
        },
        [28756] = { -- Aberrations of Bone
            [questKeys.objectives] = {{{59153}}},
            [questKeys.zoneOrSort] = zoneIDs.SCHOLOMANCE_MOP,
        },
        [29406] = { -- The Lesson of the Sandy Fist
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29408] = { -- The Lesson of the Burning Scroll
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {{{53566,nil,Questie.ICON_TYPE_EVENT}},{{210986}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29409] = { -- The Disciple's Challenge
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29410] = { -- Aysa of the Tushui
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29414] = { -- The Way of the Tushui
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {{{59642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29417] = { -- The Way of the Huojin
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29418] = { -- Kindling the Fire
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29419] = { -- The Missing Driver
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {{{54855,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29420] = { -- The Spirit's Guardian
            [questKeys.requiredLevel] = 2,
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29421] = { -- Only the Worthy Shall Pass
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29422] = { -- Huo, the Spirit of Fire
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{57779,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29423] = { -- The Passion of Shen-zin Su
            [questKeys.startedBy] = {{54787,54135}},
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {{{54786,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29424] = { -- Items of Utmost Importance
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29521] = { -- The Singing Pools
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29522] = { -- Ji of the Huojin
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29523] = { -- Fanning the Flames
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Wind Stone"),0,{{"object",210122}}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29524] = { -- The Lesson of Stifled Pride
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29547] = { -- The King's Command
            [questKeys.startedBy] = {{100002}},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Stormwind Keep visited", {[zoneIDs.STORMWIND_CITY]={{84.9,32.5}}}},
        },
        [29548] = { -- The Mission
            [questKeys.objectives] = {{{66292,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29552] = { -- Critical Condition
            [questKeys.preQuestGroup] = {31736,31737},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{61492,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29553] = { -- The Missing Admiral
            [questKeys.preQuestGroup] = {29555,29556},
            [questKeys.preQuestSingle] = {},
        },
        [29555] = { -- The White Pawn
            [questKeys.preQuestSingle] = {31745},
            [questKeys.objectives] = {nil,nil,{{89603}},nil,{{{55155,55167,55168},55155,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {73410},
        },
        [29556] = { -- Hozen Aren't Your Friends, Hozen Are Your Enemies
            [questKeys.preQuestSingle] = {31745},
        },
        [29558] = { -- The Path of War
            [questKeys.preQuestSingle] = {29553},
        },
        [29559] = { -- Freeing Our Brothers
            [questKeys.preQuestSingle] = {29553},
            [questKeys.requiredSourceItems] = {74260},
            [questKeys.objectives] = {{{55490,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Open the cage"), 0, {{"object", 209586}}}},
        },
        [29560] = { -- Ancient Power
            [questKeys.preQuestSingle] = {29553},
        },
        [29576] = { -- An Air of Worry
            [questKeys.nextQuestInChain] = 29578,
            [questKeys.breadcrumbForQuestId] = 29578,
        },
        [29577] = { -- Ashyo's Vision
            [questKeys.objectives] = {{{56113,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29578] = { -- Defiance
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29576},
        },
        [29611] = { -- The Art of War
            [questKeys.objectives] = {{{54870,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29612] = { -- The Art of War
            [questKeys.objectives] = {{{54870,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29617] = { -- Tian Monastery
            [questKeys.nextQuestInChain] = 29618,
            [questKeys.breadcrumbForQuestId] = 29618,
        },
        [29618] = { -- The High Elder
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29617},
        },
        [29661] = { -- The Lesson of Dry Fur
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {nil,{{209608}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29662] = { -- Stronger Than Reeds
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29663] = { -- The Lesson of the Balanced Rock
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{55019,65468},55019}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29664] = { -- The Challenger's Fires
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {nil,{{209369},{209801},{209802},{209803}}},
            [questKeys.requiredSourceItems] = {75000},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29665] = { -- From Bad to Worse
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29796},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29666] = { -- The Sting of Learning
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29676] = { -- Finding an Old Friend
            [questKeys.requiredLevel] = 3,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29661,29662,29663},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29677] = { -- The Sun Pearl
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29678] = { -- Shu, the Spirit of Water
            [questKeys.finishedBy] = {{110000}},
            [questKeys.requiredLevel] = 3,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29666,29677},
            [questKeys.objectives] = {{{57476,nil,Questie.ICON_TYPE_EVENT},{55205,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29679] = { -- A New Friend
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {{{60488,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29680] = { -- The Source of Our Livelihood
            [questKeys.requiredLevel] = 3,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57710}}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29690] = { -- Into the Mists
            [questKeys.objectives] = {{{55054,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29694] = { -- Regroup!
            [questKeys.objectives] = {{{55141,nil,Questie.ICON_TYPE_TALK},{55146,nil,Questie.ICON_TYPE_TALK},{55162,nil,Questie.ICON_TYPE_TALK},{55170,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31769},
        },
        [29730] = { -- Scouting Report: Hostile Natives
            [questKeys.preQuestSingle] = {29971},
        },
        [29731] = { -- Scouting Report: On the Right Track
            [questKeys.preQuestSingle] = {29730},
        },
        [29743] = { -- Monstrosity
            [questKeys.finishedBy] = {{110002}},
            [questKeys.objectives] = {nil,{{212182},{212183},{212184},{212186}}},
            [questKeys.preQuestSingle] = {31774},
        },
        [29744] = { -- Some "Pupil of Nature"
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbForQuestId] = 29745,
        },
        [29745] = { -- The Sprites' Plight
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29744},
        },
        [29757] = { -- Bottletoads
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Scoop the toadspawn"),0,{{"object",209950}}}},
        },
        [29768] = { -- Missing Mallet
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29769,29770},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29769] = { -- Rascals
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29770] = { -- Still Good!
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29680},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29771] = { -- Stronger Than Wood
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestGroup] = {29769,29770},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29772] = { -- Raucous Rousing
            [questKeys.requiredLevel] = 4,
            [questKeys.objectives] = {nil,{{209626}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29774] = { -- Not In the Face!
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29771,29772},
            [questKeys.objectives] = {{{55556,nil,Questie.ICON_TYPE_TALK},{60916,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29775] = { -- The Spirit and Body of Shen-zin Su
            [questKeys.requiredLevel] = 4,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",59497}}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29776] = { -- Morning Breeze Village
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestSingle] = {29775},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29777] = { -- Tools of the Enemy
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29778] = { -- Rewritten Wisdoms
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {nil,{{209656}}},
            [questKeys.preQuestSingle] = {29776},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29779] = { -- The Direct Solution
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29780] = { -- Do No Evil
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29781] = { -- Monkey Advisory Warning
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29782] = { -- Stronger Than Bone
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29783},
            [questKeys.nextQuestInChain] = 29785,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29783] = { -- Stronger Than Stone
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29784] = { -- Balanced Perspective
            [questKeys.startedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29779,29780,29781},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29785] = { -- Dafeng, the Spirit of Air
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{55592,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29782,29784},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29786] = { -- Battle for the Skies
            [questKeys.requiredLevel] = 5,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Firework Launcher"),0,{{"monster",64507}}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29787] = { -- Worthy of Passing
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29788] = { -- Unwelcome Nature
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29789] = { -- Small, But Significant
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29790] = { -- Passing Wisdom
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{56686,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29788,29789},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29791] = { -- The Suffering of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{55918,nil,Questie.ICON_TYPE_MOUNT_UP},{55939}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29792] = { -- Bidden to Greatness
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {nil,{{210965,nil,Questie.ICON_TYPE_EVENT},{210964,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29793] = { -- Evil from the Seas
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {30589},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29794] = { -- None Left Behind
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{55999,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {29796},
            [questKeys.nextQuestInChain] = 29798,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Bring the Injured Sailor to Delora Lionheart"),0,{{"monster",55944}}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29795] = { -- Stocking Stalks
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29792},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29796] = { -- Urgent News
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29793,30590},
            [questKeys.nextQuestInChain] = 29797,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29797] = { -- Medical Supplies
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29796},
            [questKeys.nextQuestInChain] = 29798,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29798] = { -- An Ancient Evil
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29665,29794,29797},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29799] = { -- The Healing of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60770,60834,60877,60878},60770,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29800,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29800] = { -- New Allies
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29799},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57741}}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [29815] = { -- Forensic Science
            [questKeys.objectives] = {nil,nil,{{74621,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.preQuestSingle] = {31999},
        },
        [29821] = { -- Missed Me By... That Much!
            [questKeys.preQuestSingle] = {31999},
        },
        [29822] = { -- Lay of the Land
            [questKeys.objectives] = {{{63058,nil,Questie.ICON_TYPE_EVENT},{63059,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{55651,55622},55622},},},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29827,31112},
        },
        [29823] = { -- Scouting Report: The Friend of My Enemy
            [questKeys.preQuestSingle] = {29731},
        },
        [29824] = { -- Scouting Report: Like Jinyu in a Barrel
            [questKeys.preQuestSingle] = {29823},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Get in"),0,{{"object",209621}}}},
        },
        [29827] = { -- Acid Rain
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in"),0,{{"monster",55674}}}},
        },
        [29871] = { -- Clever Ashyo
            [questKeys.preQuestSingle] = {30086},
        },
        [29872] = { -- Lin Tenderpaw
            [questKeys.preQuestSingle] = {30086},
        },
        [29873] = { -- Ken-Ken
            [questKeys.preQuestSingle] = {30086},
        },
        [29874] = { -- Kang Bramblestaff [Alliance]
            [questKeys.preQuestSingle] = {30086},
        },
        [29875] = { -- Kang Bramblestaff [Horde]
            [questKeys.preQuestSingle] = {30086},
        },
        [29877] = { -- A Poor Grasp of the Basics
            [questKeys.preQuestSingle] = {29907},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56146,56149,56150,56151,56278,56279,56280,56281},56146}}},
        },
        [29907] = { -- Chen and Li Li
            [questKeys.preQuestSingle] = {},
        },
        [29910] = { -- Rampaging Rodents
            [questKeys.preQuestSingle] = {29909},
            [questKeys.objectives] = {{{56203,nil,Questie.ICON_TYPE_INTERACT}},{{209835,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29913] = { -- The Meat They'll Eat
            [questKeys.preQuestSingle] = {29912},
        },
        [29914] = { -- Back to the Sty
            [questKeys.preQuestSingle] = {29912},
        },
        [29916] = { -- Piercing Talons and Slavering Jaws
            [questKeys.preQuestSingle] = {29915},
        },
        [29917] = { -- Lupello
            [questKeys.preQuestSingle] = {29915},
        },
        [29918] = { -- A Lesson in Bravery
            [questKeys.preQuestGroup] = {29916,29917},
            [questKeys.sourceItemId] = 75208;
        },
        [29919] = { -- Great Minds Drink Alike
            [questKeys.preQuestSingle] = {29918},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}}},
        },
        [29924] = { -- Kill Kher Shan
            [questKeys.finishedBy] = {{110003}},
            [questKeys.preQuestSingle] = {31167},
        },
        [29933] = { -- The Bees' Knees
            [questKeys.preQuestSingle] = {31167},
        },
        [29936] = { -- Instant Messaging
            [questKeys.objectives] = {{{56402,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.preQuestSingle] = {29935},
        },
        [29937] = { -- Furious Fowl
            [questKeys.preQuestSingle] = {29941},
        },
        [29939] = { -- Boom Bait
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST]={{26.75,55.33}}},Questie.ICON_TYPE_INTERACT,l10n("Throw the Gut Bomb"),0}},
        },
        [29941] = { -- Beyond the Horizon
            [questKeys.objectives] = {{{56340,nil,Questie.ICON_TYPE_TALK},{56477,nil,Questie.ICON_TYPE_TALK},{56478,nil,Questie.ICON_TYPE_TALK},{56336,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {29936},
        },
        [29942] = { -- Silly Wikket, Slickies are for Hozen
            [questKeys.preQuestSingle] = {31239},
        },
        [29943] = { -- Guerrillas in our Midst
            [questKeys.preQuestSingle] = {29824},
        },
        [29944] = { -- Leaders Among Breeders
            [questKeys.preQuestSingle] = {29919},
        },
        [29945] = { -- Yellow and Red Make Orange
            [questKeys.preQuestSingle] = {29919},
        },
        [29947] = { -- Crouching Carrot, Hidden Turnip
            [questKeys.sourceItemId] = 76370;
            [questKeys.objectives] = {{{56538,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29948] = { -- Thieves to the Core
            [questKeys.preQuestSingle] = {29944}, -- might be prequestgroup with 29945
        },
        [29950] = { -- Li Li's Day Off
            [questKeys.objectives] = {{{56546,nil,Questie.ICON_TYPE_EVENT},{56547,nil,Questie.ICON_TYPE_EVENT},{56548,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29951] = { -- Muddy Water
            [questKeys.preQuestSingle] = {29949},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Fill the vial"),0,{{"object",209921}}}},
        },
        [29952] = { -- Broken Dreams
            [questKeys.preQuestSingle] = {29950}, -- might be prequest group with 29951
            [questKeys.objectives] = {{{56680,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}}},
        },
        [29968] = { -- Green-ish Energy
            [questKeys.preQuestSingle] = {29824},
        },
        [29971] = { -- The Scouts Return
            [questKeys.preQuestGroup] = {29939,29942},
        },
        [29981] = { -- Stemming the Swarm
            [questKeys.preQuestSingle] = {},
        },
        [29982] = { -- Evacuation Orders
            [questKeys.objectives] = {{{57120,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{57122,57121},57121,nil,Questie.ICON_TYPE_TALK},{{57124,57123},57123,nil,Questie.ICON_TYPE_TALK},{{57127,57126},57126,nil,Questie.ICON_TYPE_TALK},},}
        },
        [29984] = { -- Unyielding Fists: Trial of Bamboo
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Master Bruised Paw"),0,{{"monster",56714}}}},
        },
        [29985] = { -- They Will Be Mist
            [questKeys.preQuestSingle] = {29984},
        },
        [29986] = { -- Fog Wards
            [questKeys.preQuestSingle] = {29984},
            [questKeys.objectives] = {nil,{{209945,nil,Questie.ICON_TYPE_OBJECT},{209946,nil,Questie.ICON_TYPE_OBJECT},{209947,nil,Questie.ICON_TYPE_OBJECT}}},
        },
        [29987] = { -- Unyielding Fists: Trial of Wood
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Master Bruised Paw"),0,{{"monster",56714}}}},
        },
        [29989] = { -- Unyielding Fists: Trial of Stone
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Master Bruised Paw"),0,{{"monster",56714}}}},
        },
        [29990] = { -- Training and Discipline
            [questKeys.preQuestSingle] = {29989},
        },
        [29992] = { -- Tenderpaw By Name, Tender Paw By Reputation
            [questKeys.preQuestSingle] = {29984},
        },
        [30027] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73209},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30028] = { -- Grain Recovery
            [questKeys.preQuestSingle] = {30031},
        },
        [30029] = { -- Wee Little Shenanigans
            [questKeys.preQuestSingle] = {30048},
        },
        [30030] = { -- Out of Sprite
            [questKeys.preQuestSingle] = {30048},
        },
        [30032] = { -- The Quest for Better Barley
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30029,30031},
        },
        [30033] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {76390,76392},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30034] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73211},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30035] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73207,76393},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30036] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73208,73212},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30037] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73213,76391},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30038] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73210},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30039] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30040] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.MAGE,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30041] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.HUNTER,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30042] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30043] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.ROGUE,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30044] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30045] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30046] = { -- Chen's Resolution
            [questKeys.preQuestSingle] = {29952},
        },
        [30048] = { -- Li Li and the Grain
            [questKeys.preQuestSingle] = {30046},
        },
        [30049] = { -- Doesn't Hold Water
            [questKeys.preQuestSingle] = {30046},
        },
        [30050] = { -- Gardener Fran and the Watering Can
            [questKeys.preQuestSingle] = {30046},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Gardener Fran"),0,{{"monster",62377}}}},
        },
        [30051] = { -- The Great Water Hunt
            [questKeys.objectives] = {{{58786,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mudmug"),0,{{"monster",56474}}}},
        },
        [30052] = { -- Weed War
            [questKeys.preQuestSingle] = {30046},
            [questKeys.objectives] = {{{57306,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Gai Lan"),0,{{"monster",57385}}}},
        },
        [30053] = { -- Hop Hunting
            [questKeys.preQuestSingle] = {30046},
            [questKeys.objectives] = {{{62377,nil,Questie.ICON_TYPE_TALK},{57385,nil,Questie.ICON_TYPE_TALK},{62385,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30054] = { -- Enough is Ookin' Enough
            [questKeys.preQuestSingle] = {30046},
        },
        [30056] = { -- The Farmer's Daughter
            [questKeys.preQuestSingle] = {30046},
        },
        [30057] = { -- Seeing Orange
            [questKeys.triggerEnd] = {"Bring Mina Mudclaw home to her father", {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS]={{44.22,34.65}}}},
        },
        [30058] = { -- Mothallus!
            [questKeys.preQuestSingle] = {30059},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the bait"),0,{{"object",210117}}}},
        },
        [30069] = { -- No Plan Survives Contact with the Enemy
            [questKeys.preQuestSingle] = {31733},
        },
        [30070] = { -- The Fall of Ga'trul
            [questKeys.preQuestGroup] = {31741,31742,31743,31744},
        },
        [30072] = { -- Where Silk Comes From
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {32035}, --ingame bug
        },
        [30075] = { -- Clear the Way
            [questKeys.preQuestSingle] = {30074},
        },
        [30076] = { -- The Fanciest Water
            [questKeys.preQuestSingle] = {30074},
        },
        [30077] = { -- Barrels, Man
            [questKeys.preQuestSingle] = {30074},
            [questKeys.objectives] = {{{57662,nil,Questie.ICON_TYPE_INTERACT}}};
        },
        [30078] = { -- Cleaning House
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}},{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mudmug"),0,{{"monster",58027}}},{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Li Li"),0,{{"monster",58028}}},{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",58029}}}},
        },
        [30085] = { -- Into the Brewery
            [questKeys.breadcrumbForQuestId] = 31327,
        },
        [30086] = { -- The Search for the Hidden Master
            [questKeys.preQuestSingle] = {29908},
        },
        [30117] = { -- Stoneplow Thirsts
            [questKeys.preQuestSingle] = {30078},
        },
        [30135] = { -- Beating the Odds
            [questKeys.nextQuestInChain] = 30136,
        },
        [30136] = { -- Empty Nests
            [questKeys.preQuestSingle] = {30135},
            [questKeys.nextQuestInChain] = 30137,
        },
        [30137] = { -- Egg Collection
            [questKeys.preQuestSingle] = {30136},
            [questKeys.nextQuestInChain] = 30138,
        },
        [30138] = { -- Choosing the One
            [questKeys.preQuestSingle] = {30137},
        },
        [30139] = { -- The Rider's Journey
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30140,30141},
        },
        [30140] = { -- The Rider's Journey
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30139,30141},
        },
        [30141] = { -- The Rider's Journey
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30139,30140},
        },
        [30142] = { -- It's A...
            [questKeys.preQuestSingle] = {30139,30140,30141},
            [questKeys.nextQuestInChain] = 30143,
        },
        [30143] = { -- They Grow Like Weeds
            [questKeys.preQuestSingle] = {30142},
        },
        [30172] = { -- Barreling Along
            [questKeys.triggerEnd] = {"Lead Mudmug back to Halfhill", {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS]={{55.92,49.33}}}},
        },
        [30184] = { -- Mushan Mastery: Darkhide
            [questKeys.preQuestSingle] = {30181},
        },
        [30185] = { -- Tortoise Mastery
            [questKeys.preQuestSingle] = {30184},
        },
        [30186] = { -- Parental Mastery
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Hemet"),0,{{"monster",58461}}}},
        },
        [30188] = { -- Riding the Skies (Jade Cloud Serpent)
            [questKeys.preQuestGroup] = {30140,30187},
        },
        [30240] = { -- Survival Ring: Flame
            [questKeys.preQuestSingle] = {30640},
        },
        [30242] = { -- Survival Ring: Blades
            [questKeys.preQuestSingle] = {30640},
        },
        [30243] = { -- Mantid Under Fire
            [questKeys.preQuestSingle] = {30640},
        },
        [30252] = { -- A Helping Hand
            [questKeys.objectives] = {{{58719,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30254] = { -- Learn and Grow II: Tilling and Planting
            [questKeys.objectives] = {{{59985,nil,Questie.ICON_TYPE_INTERACT}},{{59990,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30255] = { -- Learn and Grow III: Tending Crops
            [questKeys.objectives] = {{{59987,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30256] = { -- Learn and Grow IV: Harvesting
            [questKeys.objectives] = {nil,nil,{{80314,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30257] = { -- Learn and Grow V: Halfhill Market
            [questKeys.objectives] = {nil,nil,{{80314,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30261] = { -- Roll Club: Serpent's Spine
            [questKeys.preQuestSingle] = {30640},
        },
        [30266] = { -- Bloodied Skies
            [questKeys.preQuestSingle] = {30640},
        },
        [30277] = { -- The Crumbling Hall
            [questKeys.preQuestSingle] = {30640},
        },
        [30280] = { -- The Thunder Below
            [questKeys.preQuestSingle] = {30640},
        },
        [30306] = { -- The Battle Ring
            [questKeys.preQuestSingle] = {30640},
        },
        [30319] = { -- Pest Problems
            [questKeys.preQuestSingle] = {30257},
        },
        [30322] = { -- Money Matters
            [questKeys.preQuestSingle] = {30257},
        },
        [30326] = { -- The Kunzen Legend-Chief
            [questKeys.preQuestSingle] = {30257},
        },
        [30328] = { -- The Thousand-Year Dumpling
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30329,30330,30331,30332},
        },
        [30329] = { -- Cindergut Peppers
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30328,30330,30331,30332},
        },
        [30330] = { -- The Truffle Shuffle
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30328,30329,30331,30332},
        },
        [30331] = { -- The Mile-High Grub
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30328,30329,30330,30332},
        },
        [30332] = { -- Fatty Goatsteak
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30328,30329,30330,30331},
        },
        [30334] = { -- Stealing is Bad... Re-Stealing is OK
            [questKeys.preQuestSingle] = {30257},
        },
        [30379] = { -- A Ruby Shard for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30380] = { -- A Lovely Apple for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30381] = { -- A Jade Cat for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30382] = { -- A Blue Feather for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30383] = { -- A Marsh Lily for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30386] = { -- A Dish for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30387] = { -- A Jade Cat for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30388] = { -- A Blue Feather for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30389] = { -- A Marsh Lily for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30390] = { -- A Dish for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30391] = { -- A Ruby Shard for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30392] = { -- A Lovely Apple for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30393] = { -- A Jade Cat for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30394] = { -- A Blue Feather for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30395] = { -- A Marsh Lily for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30396] = { -- A Dish for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30397] = { -- A Ruby Shard for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30398] = { -- A Lovely Apple for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30399] = { -- A Jade Cat for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30400] = { -- A Blue Feather for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30401] = { -- A Marsh Lily for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30402] = { -- A Dish for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30403] = { -- A Ruby Shard for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30404] = { -- A Lovely Apple for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30405] = { -- A Jade Cat for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30406] = { -- A Blue Feather for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30407] = { -- A Marsh Lily for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30408] = { -- A Dish for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30409] = { -- A Ruby Shard for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30410] = { -- A Lovely Apple for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30411] = { -- A Jade Cat for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30412] = { -- A Blue Feather for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30413] = { -- A Marsh Lily for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30414] = { -- A Dish for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30415] = { -- A Ruby Shard for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30416] = { -- A Ruby Shard for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30417] = { -- A Lovely Apple for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30418] = { -- A Jade Cat for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30419] = { -- A Blue Feather for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30420] = { -- A Marsh Lily for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30421] = { -- A Dish for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30422] = { -- A Ruby Shard for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30423] = { -- A Lovely Apple for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30424] = { -- A Jade Cat for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30425] = { -- A Blue Feather for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30426] = { -- A Marsh Lily for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30427] = { -- A Dish for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30428] = { -- A Ruby Shard for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30429] = { -- A Lovely Apple for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30430] = { -- A Jade Cat for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30431] = { -- A Blue Feather for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30432] = { -- A Marsh Lily for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30433] = { -- A Dish for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30434] = { -- A Ruby Shard for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30435] = { -- A Lovely Apple for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30436] = { -- A Jade Cat for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30437] = { -- A Blue Feather for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30438] = { -- A Marsh Lily for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30439] = { -- A Dish for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30470] = { -- A Gift For Tina
            [questKeys.preQuestSingle] = {30257},
        },
        [30471] = { -- A Gift For Chee Chee
            [questKeys.preQuestSingle] = {30257},
        },
        [30472] = { -- A Gift For Sho
            [questKeys.preQuestSingle] = {30257},
        },
        [30473] = { -- A Gift For Fish
            [questKeys.preQuestSingle] = {30257},
        },
        [30474] = { -- A Gift For Ella
            [questKeys.preQuestSingle] = {30257},
        },
        [30475] = { -- A Gift For Fung
            [questKeys.preQuestSingle] = {30257},
        },
        [30476] = { -- A Gift For Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
        },
        [30477] = { -- A Gift For Haohan
            [questKeys.preQuestSingle] = {30257},
        },
        [30478] = { -- A Gift For Jogu
            [questKeys.preQuestSingle] = {30257},
        },
        [30479] = { -- A Gift For Gina
            [questKeys.preQuestSingle] = {30257},
        },
        [30535] = { -- Learn and Grow I: Seeds
            [questKeys.preQuestSingle] = {30252},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Merchant Greenfield"),0,{{"monster",58718}}}},
        },
        [30589] = { -- Wrecking the Wreck
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29795,30591},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30590] = { -- Handle With Care
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30591] = { -- Preying on the Predators
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30745] = { -- Trouble Brewing
            [questKeys.requiredLevel] = 85,
        },
        [30767] = { -- Risking It All
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{60727,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30982] = { -- Animal Control
            [questKeys.preQuestSingle] = {},
        },
        [30984] = { -- No Orc Left Behind
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61680,61780,61790},61680,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211883}}}},
        },
        [30987] = { -- Joining the Alliance
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {31450},
            [questKeys.nextQuestInChain] = 30988,
        },
        [30988] = { -- The Alliance Way
            [questKeys.startedBy] = {{29611}},
            [questKeys.finishedBy] = {{61796}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {30987},
        },
        [30989] = { -- An Old Pit Fighter
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{61796,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30995] = { -- No Man Left Behind
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61788,61780,61790},61788,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211883}}}},
        },
        [31034] = { -- Enemies Below
            [questKeys.startedBy] = {{39605}},
            [questKeys.exclusiveTo] = {31036,31037},
            [questKeys.nextQuestInChain] = 0,
        },
        [31036] = { -- Enemies Below
            [questKeys.startedBy] = {{36648}},
            [questKeys.exclusiveTo] = {31034,31037},
            [questKeys.nextQuestInChain] = 0,
        },
        [31037] = { -- Enemies Below
            [questKeys.startedBy] = {{10181}},
            [questKeys.exclusiveTo] = {31034,31036},
            [questKeys.nextQuestInChain] = 0,
        },
        [31012] = { -- Joining the Horde
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {31450},
        },
        [31013] = { -- The Horde Way
            [questKeys.startedBy] = {{39605}},
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{62087,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 31014,
        },
        [31014] = { -- Hellscream's Gift
            [questKeys.finishedBy] = {{39605}},
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{62209,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31013},
        },
        [31121] = { -- Stay a While, and Listen
            [questKeys.objectives] = {nil,{{212900}}},
        },
        [31134] = { -- If These Stones Could Speak
            [questKeys.objectives] = {nil,{{212926},{212925},{212924}}},
        },
        [31135] = { -- The Future of Gnomeregan
            [questKeys.startedBy] = {{42396}},
            [questKeys.preQuestSingle] = {27674},
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [31137] = { -- Meet the High Tinker
            [questKeys.preQuestSingle] = {31135},
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [31138] = { -- The Arts of a Monk
            [questKeys.preQuestSingle] = {31135},
            [questKeys.requiredRaces] = raceIDs.GNOME,
            [questKeys.requiredClasses] = classIDs.MONK,
        },
        [31139] = { -- Beating Them Back!
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [31140] = { -- Lions for Lambs
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [31142] = { -- Palm of the Tiger
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{100787}}},
        },
        [31143] = { -- Join the Battle!
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.startedBy] = {{63258}},
            [questKeys.preQuestSingle] = {31142},
        },
        [31144] = { -- They Sent Assassins
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [31145] = { -- The Rear is Clear
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [31146] = { -- Scribbled Scroll
            [questKeys.startedBy] = {{1569}},
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {26801},
        },
        [31147] = { -- Scribbled Scroll
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31146},
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{100787}}},
        },
        [31148] = { -- Novice Elreth
            [questKeys.startedBy] = {{63272}},
            [questKeys.exclusiveTo] = {28651},
            [questKeys.preQuestSingle] = {24964,24965,24966,24967,24968,24969,31147},
            [questKeys.nextQuestInChain] = 24961,
            [questKeys.breadcrumbForQuestId] = 24961,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [31150] = { -- Elegant Rune
            [questKeys.startedBy] = {{37087}},
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {24473},
        },
        [31151] = { -- Kick, Punch, It's All in the Mind
            [questKeys.requiredRaces] = raceIDs.DWARF,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31150},
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{100787}}},
        },
        [31152] = { -- Peering Into the Past
            [questKeys.triggerEnd] = {"Lorewalker Cho escorted to Circle of Stone", {[zoneIDs.THE_JADE_FOREST]={{29,32.4}}}},
            [questKeys.preQuestSingle] = {31134},
        },
        [31167] = { -- Family Tree
            [questKeys.objectives] = {nil,{{212969}}},
            [questKeys.preQuestSingle] = {31152},
        },
        [31168] = { -- Calligraphed Sigil
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {28714,28715},
        },
        [31169] = { -- The Art of the Monk
            [questKeys.preQuestSingle] = {31168},
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{100787}}},
        },
        [31170] = { -- Monk Training
            [questKeys.startedBy] = {{15278}},
            [questKeys.preQuestSingle] = {8325},
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.zoneOrSort] = zoneIDs.SUNSTRIDER_ISLE,
        },
        [31171] = { -- Tiger Palm
            [questKeys.preQuestSingle] = {31170},
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{100787}}},
        },
        [31173] = { -- The Tiger Palm
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{100787}}},
        },
        [31239] = { -- What's in a Name Name?
            [questKeys.preQuestSingle] = {29941},
        },
        [31241] = { -- Wicked Wikkets
            [questKeys.preQuestSingle] = {29879},
        },
        [31261] = { -- Captain Jack's Dead
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31288] = { -- Research Project: The Mogu Dynasties
            [questKeys.exclusiveTo] = {31289},
        },
        [31289] = { -- Uncovering the Past
            [questKeys.exclusiveTo] = {31288},
        },
        [31309] = { -- On The Mend
            [questKeys.objectives] = {{{6749,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31302] = { -- Ready For Greatness
            [questKeys.preQuestSingle] = {31281},
        },
        [31312] = { -- The Old Map
            [questKeys.nextQuestInChain] = 31313,
        },
        [31313] = { -- Just A Folk Stor
            [questKeys.preQuestSingle] = {31312},
            [questKeys.nextQuestInChain] = 31314,
        },
        [31314] = { -- Old Man Thistle's Treasure
            [questKeys.preQuestSingle] = {31313},
            [questKeys.nextQuestInChain] = 31315,
        },
        [31315] = { -- The Heartland Legacy
            [questKeys.preQuestSingle] = {31314},
        },
        [31316] = { -- Julia, The Pet Tamer
            [questKeys.objectives] = {{{64330,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31327] = { -- Trouble Brewing
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {30085},
        },
        [31376] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.exclusiveTo] = {31378,31380,31382},
        },
        [31377] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.exclusiveTo] = {31379,31381,31383},
        },
        [31378] = { -- Challenge At The Temple of the Red Crane
            [questKeys.exclusiveTo] = {31376,31380,31382},
        },
        [31379] = { -- Challenge At The Temple of the Red Crane
            [questKeys.exclusiveTo] = {31377,31381,31383},
        },
        [31380] = { -- Trial At The Temple of the White Tiger
            [questKeys.exclusiveTo] = {31376,31378,31382},
        },
        [31381] = { -- Trial At The Temple of the White Tiger
            [questKeys.exclusiveTo] = {31377,31379,31383},
        },
        [31382] = { -- Defense At Niuzao Temple
            [questKeys.exclusiveTo] = {31376,31378,31380},
        },
        [31383] = { -- Defense At Niuzao Temple
            [questKeys.exclusiveTo] = {31377,31379,31381},
        },
        [31450] = { -- A New Fate
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{56013,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [31488] = { -- Stranger in a Strange Land
            [questKeys.startedBy] = {{62871,64047,64144,66225,66409,66415}},
        },
        [31490] = { -- Rank and File
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58632,58676,58683,58684,58685,58756,58898,58998,59150,59175,59191,59240,59241,59293,59303,59372,59373},58632}}}
        },
        [31495] = { -- Rank and File
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58632,58676,58683,58684,58685,58756,58898,58998,59150,59175,59191,59240,59241,59293,59303,59372,59373},58632}}}
        },
        [31514] = { -- Unto Dust Thou Shalt Return
            [questKeys.objectives] = {{{3977,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31516] = { -- Unto Dust Thou Shalt Return
            [questKeys.objectives] = {{{3977,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31519] = {-- A Worthy Challenge: Yan-zhu the Uncasked
            [questKeys.exclusiveTo] = {31520,31522,31523,31524,31525,31526,31527,31528},
        },
        [31520] = {-- A Worthy Challenge: Sha of Doubt
            [questKeys.exclusiveTo] = {31519,31522,31523,31524,31525,31526,31527,31528},
        },
        [31521] = { -- To Be a Master
            [questKeys.objectives] = {{{64930},{64931},{64932},{64933},{64934},{64935}}},
        },
        [31522] = {-- A Worthy Challenge: Sha of Hatred
            [questKeys.exclusiveTo] = {31519,31520,31523,31524,31525,31526,31527,31528},
        },
        [31523] = {-- A Worthy Challenge: Xin the Weaponmaster
            [questKeys.exclusiveTo] = {31519,31520,31522,31524,31525,31526,31527,31528},
        },
        [31524] = {-- A Worthy Challenge: Raigonn
            [questKeys.exclusiveTo] = {31519,31520,31522,31523,31525,31526,31527,31528},
        },
        [31525] = {-- A Worthy Challenge: Wing Leader Ner'onok
            [questKeys.exclusiveTo] = {31519,31520,31522,31523,31524,31526,31527,31528},
        },
        [31526] = {-- A Worthy Challenge: Durand
            [questKeys.exclusiveTo] = {31519,31520,31522,31523,31524,31525,31527,31528},
        },
        [31527] = {-- A Worthy Challenge: Flameweaver Koegler
            [questKeys.exclusiveTo] = {31519,31520,31522,31523,31524,31525,31526,31528},
        },
        [31528] = {-- A Worthy Challenge: Darkmaster Gandling
            [questKeys.exclusiveTo] = {31519,31520,31522,31523,31524,31525,31526,31527},
        },
        [31548] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63075}},
        },
        [31549] = { -- On The Mend
            [questKeys.objectives] = {{{9980,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31551] = { -- Got one!
            [questKeys.startedBy] = {{63075}},
        },
        [31552] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63070}},
        },
        [31553] = { -- On The Mend
            [questKeys.startedBy] = {{63070}},
            [questKeys.objectives] = {{{10051,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31556] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63077}},
        },
        [31568] = { -- On The Mend
            [questKeys.startedBy] = {{63077}},
            [questKeys.objectives] = {{{17485,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31569] = { -- Got one!
            [questKeys.startedBy] = {{63077}},
        },
        [31572] = { -- On The Mend
            [questKeys.startedBy] = {{63061}},
            [questKeys.objectives] = {{{9987,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31573] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63067}},
        },
        [31574] = { -- On The Mend
            [questKeys.startedBy] = {{63067}},
            [questKeys.objectives] = {{{10050,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31575] = { -- Got one!
            [questKeys.startedBy] = {{63067}},
        },
        [31576] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63073}},
        },
        [31577] = { -- On The Mend
            [questKeys.startedBy] = {{63073}},
            [questKeys.objectives] = {{{10055,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31578] = { -- Got one!
            [questKeys.startedBy] = {{63073}},
        },
        [31580] = { -- On The Mend
            [questKeys.startedBy] = {{63080}},
            [questKeys.objectives] = {{{16185,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31581] = { -- Got one!
            [questKeys.startedBy] = {{63080}},
        },
        [31582] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63083}},
        },
        [31583] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.objectives] = {{{10085,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31586] = { -- On The Mend
            [questKeys.startedBy] = {{63086}},
            [questKeys.objectives] = {{{45789,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31587] = { -- Got one!
            [questKeys.startedBy] = {{63086}},
        },
        [31589] = { -- On The Mend
            [questKeys.objectives] = {{{47764,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31592] = { -- On The Mend
            [questKeys.objectives] = {{{11069,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31693] = { -- Julia Stevens
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{64330,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31724] = { -- Old MacDonald
            [questKeys.objectives] = {{{65648,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31725] = { -- Lindsay
            [questKeys.objectives] = {{{65651,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31726] = { -- Eric Davidson
            [questKeys.objectives] = {{{65655,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31728] = { -- Bill Buckler
            [questKeys.objectives] = {{{65656,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31729] = { -- Steven Lisbane
            [questKeys.objectives] = {{{63194,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31732] = { -- Unleash Hell
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",66297}}}},
        },
        [31733] = { -- Touching Ground
            [questKeys.objectives] = {nil,{{215682}}},
        },
        [31734] = { -- Welcome Wagons
            [questKeys.preQuestSingle] = {31733},
        },
        [31735] = { -- The Right Tool For The Job
            [questKeys.preQuestGroup] = {30069,31734},
            [questKeys.objectives] = {nil,{{215390},{215390}},nil,nil,{{{66396},66396,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31736] = { -- Envoy of the Alliance
            [questKeys.preQuestSingle] = {31735},
            [questKeys.objectives] = {{{65910,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31737] = { -- The Cost of War
            [questKeys.preQuestSingle] = {31735},
        },
        [31738] = { -- Pillaging Peons
            [questKeys.preQuestGroup] = {31736,31737},
        },
        [31739] = { -- The Cost of War
            [questKeys.preQuestSingle] = {31737},
            [questKeys.objectives] = {nil,{{215133}}},
        },
        [31743] = { -- Smoke Before Fire
            [questKeys.objectives] = {nil,{{215275,nil,Questie.ICON_TYPE_EVENT}},nil,nil,{{{66279},66279,nil,Questie.ICON_TYPE_EVENT},{{66277},66277,nil,Questie.ICON_TYPE_EVENT},{{66278},66278,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31744] = { -- Unfair Trade
            [questKeys.objectives] = {{{66366,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31745] = { -- Onward and Inward
            [questKeys.objectives] = {{{67067,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [31765] = { -- Paint it Red!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in a cannon"),0,{{"monster",66677}}}},
        },
        [31766] = { -- Touching Ground
            [questKeys.objectives] = {nil,{{210039}}},
        },
        [31768] = { -- Fire Is Always the Answer
            [questKeys.objectives] = {{{66308,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31766},
        },
        [31769] = { -- The Final Blow!
            [questKeys.objectives] = {{{66554,nil,Questie.ICON_TYPE_INTERACT},{66555,nil,Questie.ICON_TYPE_INTERACT},{66556,nil,Questie.ICON_TYPE_INTERACT},{66283,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31770] = { -- You're Either With Us Or...
            [questKeys.objectives] = {{{66220,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31769},
        },
        [31771] = { -- Face to Face With Consequence
            [questKeys.preQuestSingle] = {31769},
        },
        [31772] = { -- Priorities!
            [questKeys.objectives] = {nil,{{215695}}},
            [questKeys.preQuestSingle] = {31769},
            [questKeys.exclusiveTo] = {31978},
        },
        [31773] = { -- Prowler Problems
            [questKeys.preQuestSingle] = {31769},
        },
        [31774] = { -- Seeking Zin'jun
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29694,31770,31771,31773},
        },
        [31775] = { -- Assault on the Airstrip
            [questKeys.preQuestSingle] = {29804},
        },
        [31776] = { -- Strongarm Tactics
            [questKeys.preQuestSingle] = {29804},
        },
        [31777] = { -- Choppertunity
            [questKeys.requiredSourceItems] = {89163},
            [questKeys.preQuestSingle] = {29804},
        },
        [31778] = { -- Unreliable Allies
            [questKeys.preQuestSingle] = {29804},
        },
        [31779] = { -- The Darkness Within
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31775,31776,31777,31778,},
        },
        [31780] = { -- Old MacDonald
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65648,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31781] = { -- Lindsay
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65651,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31810] = { -- Riding the Skies (Azure Cloud Serpent)
            [questKeys.preQuestGroup] = {30139,30187},
        },
        [31811] = { -- Riding the Skies (Golden Cloud Serpent)
            [questKeys.preQuestGroup] = {30141,30187},
        },
        [31812] = { -- Zunta, The Pet Tamer
            [questKeys.objectives] = {{{66126,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31813] = { -- Dagra the Fierce
            [questKeys.objectives] = {{{66135,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31814] = { -- Analynn
            [questKeys.objectives] = {{{66136,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31815] = { -- Zonya the Sadist
            [questKeys.objectives] = {{{66137,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31817] = { -- Merda Stronghoof
            [questKeys.objectives] = {{{66372,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31818] = { -- Zunta
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66126,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31819] = { -- Dagra the Fierce
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66135,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31824] = { -- Level Up!
            [questKeys.startedBy] = {{63080}},
        },
        [31831] = { -- Level Up!
            [questKeys.startedBy] = {{63067}},
        },
        [31834] = { -- Begin Your Training: Master Cheng
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.zoneOrSort] = zoneIDs.PEAK_OF_SERENITY,
        },
        [31840] = { -- Practice Makes Perfect: Master Cheng
            [questKeys.preQuestSingle] = {31834},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31850] = { -- Eric Davidson
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65655,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31851] = { -- Bill Buckler
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65656,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31852] = { -- Steven Lisbane
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{63194,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31853] = { -- All Aboard!
            [questKeys.objectives] = {},
        },
        [31854] = { -- Analynn
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66136,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31862] = { -- Zonya the Sadist
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66137,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31870] = { -- Cassandra Kaboom
            [questKeys.objectives] = {{{66422,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31871] = { -- Traitor Gluk
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31872] = { -- Merda Stronghoof
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66372,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31876] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [31878] = { -- Audrey Burnhep
            [questKeys.exclusiveTo] = {31316},
        },
        [31879] = { -- Audrey Burnhep
            [questKeys.exclusiveTo] = {31316},
        },
        [31880] = { -- Audrey Burnhep
            [questKeys.exclusiveTo] = {31316},
        },
        [31881] = { -- Audrey Burnhep
            [questKeys.exclusiveTo] = {31316},
        },
        [31877] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [31889] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE},{66436,nil,Questie.ICON_TYPE_PET_BATTLE},{66452,nil,Questie.ICON_TYPE_PET_BATTLE},{66442,nil,Questie.ICON_TYPE_PET_BATTLE},{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31917},
        },
        [31891] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE},{66436,nil,Questie.ICON_TYPE_PET_BATTLE},{66452,nil,Questie.ICON_TYPE_PET_BATTLE},{66442,nil,Questie.ICON_TYPE_PET_BATTLE},{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31918},
        },
        [31897] = { -- Grand Master Trixxy
            [questKeys.objectives] = {{{66466,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31902] = { -- Battle Pet Tamers: Eastern Kingdoms
            [questKeys.objectives] = {{{66478,nil,Questie.ICON_TYPE_PET_BATTLE},{66512,nil,Questie.ICON_TYPE_PET_BATTLE},{66515,nil,Questie.ICON_TYPE_PET_BATTLE},{66518,nil,Questie.ICON_TYPE_PET_BATTLE},{66520,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31917},
        },
        [31903] = { -- Battle Pet Tamers: Eastern Kingdoms
            [questKeys.objectives] = {{{66478,nil,Questie.ICON_TYPE_PET_BATTLE},{66512,nil,Questie.ICON_TYPE_PET_BATTLE},{66515,nil,Questie.ICON_TYPE_PET_BATTLE},{66518,nil,Questie.ICON_TYPE_PET_BATTLE},{66520,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31918},
        },
        [31904] = { -- Cassandra Kaboom
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66422,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31905] = { -- Grazzle the Great
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66436,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31906] = { -- Kela Grimtotem
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66452,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31907] = { -- Zoltan
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66442,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31908] = { -- Elena Flutterfly
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31909] = { -- Grand Master Trixxy
            [questKeys.objectives] = {{{66466,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31910] = { -- David Kosse
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66478,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31911] = { -- Deiza Plaguehorn
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66512,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31912] = { -- Kortas Darkhammer
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66515,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31913] = { -- Everessa
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66518,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31914] = { -- Durin Darkhammer
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66520,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31915] = { -- Grand Master Lydia Accoste
            [questKeys.objectives] = {{{66522,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31916] = { -- Grand Master Lydia Accoste
            [questKeys.objectives] = {{{66522,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31919] = { -- Battle Pet Tamers: Outland
            [questKeys.objectives] = {{{66550,nil,Questie.ICON_TYPE_PET_BATTLE},{66551,nil,Questie.ICON_TYPE_PET_BATTLE},{66552,nil,Questie.ICON_TYPE_PET_BATTLE},{66553,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31920] = { -- Grand Master Antari
            [questKeys.objectives] = {{{66557,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31921] = { -- Battle Pet Tamers: Outland
            [questKeys.objectives] = {{{66550,nil,Questie.ICON_TYPE_PET_BATTLE},{66551,nil,Questie.ICON_TYPE_PET_BATTLE},{66552,nil,Questie.ICON_TYPE_PET_BATTLE},{66553,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31922] = { -- Nicki Tinytech
            [questKeys.objectives] = {{{66550,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31923] = { -- Ras'an
            [questKeys.objectives] = {{{66551,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31924] = { -- Narrok
            [questKeys.objectives] = {{{66552,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31925] = { -- Morulu The Elder
            [questKeys.objectives] = {{{66553,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31926] = { -- Grand Master Antari
            [questKeys.objectives] = {{{66557,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31927] = { -- Battle Pet Tamers: Northrend
            [questKeys.objectives] = {{{66635,nil,Questie.ICON_TYPE_PET_BATTLE},{66636,nil,Questie.ICON_TYPE_PET_BATTLE},{66638,nil,Questie.ICON_TYPE_PET_BATTLE},{66639,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31928] = { -- Grand Master Payne
            [questKeys.objectives] = {{{66675,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31929] = { -- Battle Pet Tamers: Northrend
            [questKeys.objectives] = {{{66635,nil,Questie.ICON_TYPE_PET_BATTLE},{66636,nil,Questie.ICON_TYPE_PET_BATTLE},{66638,nil,Questie.ICON_TYPE_PET_BATTLE},{66639,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31930] = { -- Battle Pet Tamers: Pandaria
            [questKeys.objectives] = {{{66730,nil,Questie.ICON_TYPE_PET_BATTLE},{66734,nil,Questie.ICON_TYPE_PET_BATTLE},{66733,nil,Questie.ICON_TYPE_PET_BATTLE},{66738,nil,Questie.ICON_TYPE_PET_BATTLE},{66918,nil,Questie.ICON_TYPE_PET_BATTLE},{66739,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31931] = { -- Beegle Blastfuse
            [questKeys.objectives] = {{{66635,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31932] = { -- Nearly Headless Jacob
            [questKeys.objectives] = {{{66636,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31933] = { -- Okrut Dragonwaste
            [questKeys.objectives] = {{{66638,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31934] = { -- Gutretch
            [questKeys.objectives] = {{{66639,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31935] = { -- Grand Master Payne
            [questKeys.objectives] = {{{66675,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31945] = { -- Learn and Grow VI: Gina's Vote
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_LOOT,l10n("Buy Scallion Seeds"),0,{{"monster",58718}}}},
        },
        [31952] = { -- Battle Pet Tamers: Pandaria
            [questKeys.objectives] = {{{66730,nil,Questie.ICON_TYPE_PET_BATTLE},{66734,nil,Questie.ICON_TYPE_PET_BATTLE},{66733,nil,Questie.ICON_TYPE_PET_BATTLE},{66738,nil,Questie.ICON_TYPE_PET_BATTLE},{66918,nil,Questie.ICON_TYPE_PET_BATTLE},{66739,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31953] = { -- Grand Master Hyuna
            [questKeys.objectives] = {{{66730,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31954] = { -- Grand Master Mo'ruk
            [questKeys.objectives] = {{{66733,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31955] = { -- Grand Master Nishi
            [questKeys.objectives] = {{{66734,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31956] = { -- Grand Master Yon
            [questKeys.objectives] = {{{66738,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31957] = { -- Grand Master Shu
            [questKeys.objectives] = {{{66739,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31958] = { -- Grand Master Aki
            [questKeys.objectives] = {{{66741,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31966] = { -- Battle Pet Tamers: Cataclysm
            [questKeys.objectives] = {{{66819,nil,Questie.ICON_TYPE_PET_BATTLE},{66815,nil,Questie.ICON_TYPE_PET_BATTLE},{66822,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31967] = { -- Battle Pet Tamers: Cataclysm
            [questKeys.objectives] = {{{66819,nil,Questie.ICON_TYPE_PET_BATTLE},{66815,nil,Questie.ICON_TYPE_PET_BATTLE},{66822,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31970] = { -- Grand Master Obalis
            [questKeys.objectives] = {{{66824,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31971] = { -- Grand Master Obalis
            [questKeys.objectives] = {{{66824,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31972] = { -- Brok
            [questKeys.objectives] = {{{66819,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31973] = { -- Bordin Steadyfist
            [questKeys.objectives] = {{{66815,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31974] = { -- Goz Banefury
            [questKeys.objectives] = {{{66822,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31975] = { -- The Returning Champion
            [questKeys.startedBy] = {{66466}},
            [questKeys.preQuestSingle] = {31897},
        },
        [31976] = { -- The Returning Champion
            [questKeys.preQuestSingle] = {31897},
        },
        [31977] = { -- The Returning Champion
            [questKeys.preQuestSingle] = {31897},
        },
        [31978] = { -- Priorities!
            [questKeys.objectives] = {nil,{{215695}}},
            [questKeys.preQuestSingle] = {31769},
            [questKeys.exclusiveTo] = {31772},
        },
        [31980] = { -- The Returning Champion
            [questKeys.preQuestSingle] = {31897},
        },
        [31981] = { -- Exceeding Expectations
            [questKeys.preQuestSingle] = {31920},
        },
        [31982] = { -- Exceeding Expectations
            [questKeys.preQuestSingle] = {31920},
        },
        [31983] = { -- A Brief Reprieve
            [questKeys.preQuestSingle] = {31928},
        },
        [31984] = { -- A Brief Reprieve
            [questKeys.preQuestSingle] = {31928},
        },
        [31985] = { -- The Triumphant Return
            [questKeys.preQuestSingle] = {31970},
        },
        [31986] = { -- The Triumphant Return
            [questKeys.preQuestSingle] = {31970},
        },
        [31990] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
        },
        [31991] = { -- Grand Master Zusshi
            [questKeys.objectives] = {{{66918,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31998] = {-- A Worthy Challenge: Sha of Doubt
            [questKeys.exclusiveTo] = {32000,32001,32002,32003,32004,32005,32006,32007},
        },
        [32000] = {-- A Worthy Challenge: Yan-zhu the Uncasked
            [questKeys.exclusiveTo] = {31998,32001,32002,32003,32004,32005,32006,32007},
        },
        [32001] = {-- A Worthy Challenge: Sha of Hatred
            [questKeys.exclusiveTo] = {31998,32000,32002,32003,32004,32005,32006,32007},
        },
        [32002] = {-- A Worthy Challenge: Xin the Weaponmaster
            [questKeys.exclusiveTo] = {31998,32000,32001,32003,32004,32005,32006,32007},
        },
        [32003] = {-- A Worthy Challenge: Raigonn
            [questKeys.exclusiveTo] = {31998,32000,32001,32002,32004,32005,32006,32007},
        },
        [32004] = {-- A Worthy Challenge: Wing Leader Ner'onok
            [questKeys.exclusiveTo] = {31998,32000,32001,32002,32003,32005,32006,32007},
        },
        [32005] = {-- A Worthy Challenge: Durand
            [questKeys.exclusiveTo] = {31998,32000,32001,32002,32003,32004,32006,32007},
        },
        [32006] = {-- A Worthy Challenge: Flameweaver Koegler
            [questKeys.exclusiveTo] = {31998,32000,32001,32002,32003,32004,32005,32007},
        },
        [32007] = {-- A Worthy Challenge: Darkmaster Gandling
            [questKeys.exclusiveTo] = {31998,32000,32001,32002,32003,32004,32005,32006},
        },
        [32008] = { -- Audrey Burnhep
            [questKeys.exclusiveTo] = {31316},
        },
        [32016] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{64029}},
        },
        [32017] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{63996}},
        },
        [32035] = { -- Got Silk?
            [questKeys.exclusiveTo] = {30072},
        },
        [32038] = { -- Stag Mastery
            [questKeys.preQuestSingle] = {30181},
        },
        [32175] = { -- Darkmoon Pet Battle
            [questKeys.objectives] = {{{67370,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32428] = { -- Pandaren Spirit Tamer
            [questKeys.objectives] = {{{68463},{68465},{68464},{68462}}},
        },
        [32434] = { -- Burning Pandaren Spirit
            [questKeys.objectives] = {{{68463,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32439] = { -- Flowing Pandaren Spirit
            [questKeys.objectives] = {{{68462,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32440] = { -- Whispering Pandaren Spirit
            [questKeys.objectives] = {{{68464,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32441] = { -- Thundering Pandaren Spirit
            [questKeys.objectives] = {{{68465,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32603] = { -- Beasts of Fable
            [questKeys.objectives] = {{{68555,nil,Questie.ICON_TYPE_PET_BATTLE},{68558,nil,Questie.ICON_TYPE_PET_BATTLE},{68559,nil,Questie.ICON_TYPE_PET_BATTLE},{68560,nil,Questie.ICON_TYPE_PET_BATTLE},{68561,nil,Questie.ICON_TYPE_PET_BATTLE},{68562,nil,Questie.ICON_TYPE_PET_BATTLE},{68563,nil,Questie.ICON_TYPE_PET_BATTLE},{68564,nil,Questie.ICON_TYPE_PET_BATTLE},{68565,nil,Questie.ICON_TYPE_PET_BATTLE},{68566,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31958},
        },
        [32604] = { -- Beasts of Fable Book I
            [questKeys.objectives] = {{{68555,nil,Questie.ICON_TYPE_PET_BATTLE},{68563,nil,Questie.ICON_TYPE_PET_BATTLE},{68564,nil,Questie.ICON_TYPE_PET_BATTLE},{68565,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {32603},
        },
        [32618] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [32661] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [32662] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.DWARF,
        },
        [32663] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [32664] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [32665] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
        },
        [32667] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
        },
        [32668] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [32669] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [32670] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [32671] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.TROLL,
        },
        [32672] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [32673] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.GOBLIN,
        },
        [32674] = { -- I Believe You Can Fly
            [questKeys.requiredLevel] = 60,
        },
        [32675] = { -- I Believe You Can Fly
            [questKeys.requiredLevel] = 60,
        },
        [32863] = { -- What We've Been Training For
            [questKeys.objectives] = {{{110001}}},
        },
        [32868] = { -- Beasts of Fable Book II
            [questKeys.objectives] = {{{68560,nil,Questie.ICON_TYPE_PET_BATTLE},{68561,nil,Questie.ICON_TYPE_PET_BATTLE},{68566,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {32603},
        },
        [32869] = { -- Beasts of Fable Book III
            [questKeys.objectives] = {{{68558,nil,Questie.ICON_TYPE_PET_BATTLE},{68559,nil,Questie.ICON_TYPE_PET_BATTLE},{68562,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {32603},
        },
        [33136] = { -- The Rainy Day is Here
            [questKeys.preQuestSingle] = {33137},
        },
        [33137] = { -- The Celestial Tournament
            [questKeys.objectives] = {{{73082,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [33222] = { -- Little Tommy Newcomer
            [questKeys.objectives] = {{{73626,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [33336] = { -- The Essence of Time
            [questKeys.preQuestSingle] = {33161},
        },
        [33337] = { -- A Vision in Time
            [questKeys.preQuestSingle] = {33338},
        },
        [33338] = { -- Empowering the Hourglass
            [questKeys.preQuestSingle] = {33336},
        },
        [33375] = { -- Refining The Vision
            [questKeys.preQuestSingle] = {33337},
        },
        [33376] = { -- Seeking Fate
            [questKeys.preQuestSingle] = {33375},
        },
        [33377] = { -- Hidden Threads
            [questKeys.preQuestSingle] = {33376},
        },
        [33378] = { -- Courting Destiny
            [questKeys.preQuestSingle] = {33377},
        },
        [33379] = { -- One Final Turn
            [questKeys.preQuestSingle] = {33378},
        },
        [64845] = { -- Alliance War Effort
            [questKeys.triggerEnd] = {"Victory in a battleground match", {
                [zoneIDs.SHATTRATH_CITY] = {{67.41,33.86}},
                [zoneIDs.STORMWIND_CITY] = {{86.82,36.09}},
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{44.5,46}},
                [zoneIDs.ASHENVALE] = {{61.8,83.8}},
                [zoneIDs.THE_EXODAR] = {{26.6,50.06}},
                [zoneIDs.ARATHI_HIGHLANDS] = {{40.43,45.84}},
                [zoneIDs.DALARAN] = {{29.79,75.78}},
                [zoneIDs.DARNASSUS] = {{56.05,47.61}},
                [zoneIDs.IRONFORGE] = {{70.41,91.10}},
                [zoneIDs.WINTERGRASP] = {{50.02,15.16}},
            }},
        },
    }
end
