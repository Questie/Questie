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
QuestieCorrections.spellObjectiveFirst[24640] = true
QuestieCorrections.spellObjectiveFirst[24752] = true
QuestieCorrections.spellObjectiveFirst[24760] = true
QuestieCorrections.spellObjectiveFirst[24766] = true
QuestieCorrections.spellObjectiveFirst[24772] = true
QuestieCorrections.spellObjectiveFirst[24784] = true
QuestieCorrections.spellObjectiveFirst[24964] = true
QuestieCorrections.spellObjectiveFirst[24965] = true
QuestieCorrections.spellObjectiveFirst[24966] = true
QuestieCorrections.spellObjectiveFirst[24967] = true
QuestieCorrections.spellObjectiveFirst[24968] = true
QuestieCorrections.spellObjectiveFirst[24969] = true
QuestieCorrections.spellObjectiveFirst[25139] = true
QuestieCorrections.spellObjectiveFirst[25141] = true
QuestieCorrections.spellObjectiveFirst[25143] = true
QuestieCorrections.spellObjectiveFirst[25145] = true
QuestieCorrections.spellObjectiveFirst[25147] = true
QuestieCorrections.spellObjectiveFirst[25149] = true
QuestieCorrections.spellObjectiveFirst[26198] = true
QuestieCorrections.spellObjectiveFirst[26200] = true
QuestieCorrections.spellObjectiveFirst[26201] = true
QuestieCorrections.spellObjectiveFirst[26204] = true
QuestieCorrections.spellObjectiveFirst[26207] = true
QuestieCorrections.spellObjectiveFirst[26274] = true
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
QuestieCorrections.spellObjectiveFirst[27020] = true
QuestieCorrections.spellObjectiveFirst[27021] = true
QuestieCorrections.spellObjectiveFirst[27023] = true
QuestieCorrections.spellObjectiveFirst[27027] = true
QuestieCorrections.spellObjectiveFirst[27066] = true
QuestieCorrections.spellObjectiveFirst[27067] = true
QuestieCorrections.spellObjectiveFirst[27091] = true
QuestieCorrections.killCreditObjectiveFirst[29555] = true
QuestieCorrections.killCreditObjectiveFirst[29578] = true
QuestieCorrections.objectObjectiveFirst[29628] = true
QuestieCorrections.objectObjectiveFirst[29726] = true
QuestieCorrections.objectObjectiveFirst[29730] = true
QuestieCorrections.itemObjectiveFirst[29749] = true
QuestieCorrections.objectObjectiveFirst[30325] = true
QuestieCorrections.killCreditObjectiveFirst[30457] = true
QuestieCorrections.killCreditObjectiveFirst[30466] = true
QuestieCorrections.itemObjectiveFirst[30607] = true
QuestieCorrections.itemObjectiveFirst[30800] = true
QuestieCorrections.objectObjectiveFirst[30932] = true
QuestieCorrections.killCreditObjectiveFirst[31019] = true
QuestieCorrections.spellObjectiveFirst[31138] = true
QuestieCorrections.spellObjectiveFirst[31142] = true
QuestieCorrections.spellObjectiveFirst[31147] = true
QuestieCorrections.spellObjectiveFirst[31151] = true
QuestieCorrections.spellObjectiveFirst[31157] = true
QuestieCorrections.spellObjectiveFirst[31162] = true
QuestieCorrections.spellObjectiveFirst[31166] = true
QuestieCorrections.spellObjectiveFirst[31169] = true
QuestieCorrections.spellObjectiveFirst[31171] = true
QuestieCorrections.spellObjectiveFirst[31173] = true
QuestieCorrections.spellObjectiveFirst[31467] = true
QuestieCorrections.spellObjectiveFirst[31471] = true
QuestieCorrections.spellObjectiveFirst[31474] = true
QuestieCorrections.spellObjectiveFirst[31476] = true
QuestieCorrections.spellObjectiveFirst[31477] = true
QuestieCorrections.spellObjectiveFirst[31480] = true

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
        [2383] = { -- Simple Parchment
            [questKeys.requiredLevel] = 2,
        },
        [3087] = { -- Etched Parchment
            [questKeys.requiredLevel] = 2,
        },
        [3088] = { -- Encrypted Parchment
            [questKeys.requiredLevel] = 2,
        },
        [3089] = { -- Rune-Inscribed Parchment
            [questKeys.requiredLevel] = 2,
        },
        [3090] = { -- Tainted Parchment
            [questKeys.requiredLevel] = 2,
        },
        [3091] = { -- Simple Note
            [questKeys.requiredLevel] = 2,
        },
        [3092] = { -- Etched Note
            [questKeys.requiredLevel] = 2,
        },
        [3093] = { -- Rune-Inscribed Note
            [questKeys.requiredLevel] = 2,
        },
        [3094] = { -- Verdant Note
            [questKeys.requiredLevel] = 2,
        },
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
        [24622] = { -- A Troll's Truest Companion
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24623] = { -- Saving the Young
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24624] = { -- Mercy for the Lost
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24625] = { -- Consort of the Sea Witch
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24626] = { -- Young and Vicious
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24640] = { -- The Arts of a Warrior
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24752] = { -- The Arts of a Mage
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{122}}},
        },
        [24760] = { -- The Arts of a Shaman
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24766] = { -- The Arts of a Druid
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{8921}}},
        },
        [24772] = { -- The Arts of a Rogue
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24778] = { -- The Arts of a Hunter
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [24784] = { -- Learnin' tha Word
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{589}}},
        },
        [24812] = { -- No More Mercy
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24813] = { -- Territorial Fetish
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [24814] = { -- An Ancient Enemy
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
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
        [25035] = { -- Breaking the Line
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [25037] = { -- Crab Fishin'
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
            [questKeys.preQuestSingle] = {24643,24755,24763,24769,24775,24781,24787,26277,31163},
        },
        [25064] = { -- Moraya
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
            [questKeys.preQuestSingle] = {24643,24755,24763,24769,24775,24781,24787,26277,31163},
        },
        [25073] = { -- Sen'jin Village
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.HUNTER + classIDs.DRUID + classIDs.SHAMAN + classIDs.MONK,
        },
        [25138] = { -- Glyphic Parchment
            [questKeys.requiredLevel] = 2,
        },
        [25139] = { -- Steady Shot
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [25141] = { -- Eviscerate
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [25143] = { -- Primal Strike
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [25145] = { -- Corruption
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [25147] = { -- Charge
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [25149] = { -- Frost Nova
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [26198] = { -- The Arts of a Mage
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [26200] = { -- The Arts of a Priest
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [26201] = { -- The Power of a Warlock
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [26204] = { -- The Arts of a Warrior
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26205] = { -- A Job for the Multi-Bot
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26207] = { -- The Arts of a Rogue
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [26208] = { -- The Fight Continues
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26222] = { -- Scrounging for Parts
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26264] = { -- What's Left Behind
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26265] = { -- Dealing with the Fallout
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26274] = { -- The Arts of a Warlock
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{172}}},
        },
        [26284] = { -- Missing in Action
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26285] = { -- Get Me Explosives Back!
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26316] = { -- What's Keeping Jessup?
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26318] = { -- Finishin' the Job
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26329] = { -- One More Thing
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26331] = { -- Crushcog's Minions
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26333] = { -- No Tanks!
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26342] = { -- Paint it Black
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26364] = { -- Down with Crushcog!
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26373] = { -- On to Kharanos
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [26389] = { -- Blackrock Invasion
            [questKeys.preQuestSingle] = {28817,28818,28819,28820,28821,28822,28823,29083,31145},
        },
        [26391] = { -- Extinguishing Hope
            [questKeys.preQuestSingle] = {28817,28818,28819,28820,28821,28822,28823,29083,31145},
        },
        [26566] = { -- A Triumph of Gnomish Ingenuity
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
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
        [27014] = { -- Hallowed Note
            [questKeys.requiredLevel] = 2,
        },
        [27015] = { -- Consecrated Note
            [questKeys.requiredLevel] = 2,
        },
        [27020] = { -- The First Lesson
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [27021] = { -- The Hunter's Path
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [27023] = { -- The Way of the Sunwalkers
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{105361}}},
        },
        [27027] = { -- Primal Strike
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [27066] = { -- Learning the Word
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{589}}},
        },
        [27067] = { -- Moonfire
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{8921}}},
        },
        [27091] = { -- Charge!
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [27635] = { -- Decontamination
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [27670] = { -- Pinned Down
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [27671] = { -- See to the Survivors
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.MAGE + classIDs.WARLOCK + classIDs.ROGUE + classIDs.PRIEST + classIDs.MONK, -- gnome DKs don't get these quests
        },
        [27674] = { -- To the Surface
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
            [questKeys.triggerEnd] = {"Stormwind Keep visited", {[zoneIDs.STORMWIND_CITY] = {{84.9,32.5}}}},
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
        [29579] = { -- Rally the Survivors
            [questKeys.objectives] = {nil,nil,nil,nil,{{{54763,54872},54872,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29585] = { -- Spitfire
            [questKeys.objectives] = {{{54780,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29586] = { -- The Splintered Path
            [questKeys.objectives] = {{{55009,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {29578,29579,29580,29585},
            [questKeys.preQuestSingle] = {},
        },
        [29587] = { -- Unbound
            [questKeys.objectives] = {nil,nil,nil,nil,{{{54990,61472},54990,nil,Questie.ICON_TYPE_INTERACT}}},
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
        [29619] = { -- A Courteous Guest
            [questKeys.preQuestSingle] = {29618},
        },
        [29620] = { -- The Great Banquet
            [questKeys.objectives] = {{{54914,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29622] = { -- Your Training Starts Now
            [questKeys.preQuestSingle] = {29620},
        },
        [29623] = { -- Perfection
            [questKeys.triggerEnd] = {"Survive the Melee", {[zoneIDs.THE_JADE_FOREST] = {{41.36,27.57}}}},
            [questKeys.objectives] = {},
        },
        [29626] = { -- Groundskeeper Wu
            [questKeys.preQuestSingle] = {29620},
        },
        [29627] = { -- A Proper Weapon
            [questKeys.preQuestSingle] = {29626},
        },
        [29628] = { -- A Strong Back
            [questKeys.objectives] = {{{54915,nil,Questie.ICON_TYPE_EVENT}},{{209551}}},
            [questKeys.preQuestSingle] = {29627},
        },
        [29629] = { -- A Steady Hand
            [questKeys.preQuestSingle] = {29627},
        },
        [29630] = { -- And a Heavy Fist
            [questKeys.preQuestSingle] = {29627},
        },
        [29631] = { -- Burning Bright
            [questKeys.preQuestSingle] = {29627},
        },
        [29632] = { -- Becoming Battle-Ready
            [questKeys.preQuestSingle] = {29620},
        },
        [29633] = { -- Zhi-Zhi, the Dextrous
            [questKeys.preQuestSingle] = {29632},
        },
        [29634] = { -- Husshun, the Wizened
            [questKeys.preQuestSingle] = {29632},
        },
        [29635] = { -- Xiao, the Eater
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29633,29634},
        },
        [29637] = { -- The Rumpus
            [questKeys.triggerEnd] = {"Survive the Melee", {[zoneIDs.THE_JADE_FOREST] = {{39,23.18}}}},
            [questKeys.objectives] = {},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{39,23.18}}}, Questie.ICON_TYPE_INTERACT, l10n("Shoot the fireworks")}},
        },
        [29639] = { -- Flying Colors
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29624,29628,29629,29630,29635,29637},
            [questKeys.exclusiveTo] = {29646,29647},
        },
        [29646] = { -- Flying Colors
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29624,29628,29629,29630,29635,29637},
            [questKeys.exclusiveTo] = {29639,29647},
        },
        [29647] = { -- Flying Colors
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29624,29628,29629,29630,29635,29637},
            [questKeys.exclusiveTo] = {29639,29646},
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
        [29670] = { -- Maul Gormal
            [questKeys.preQuestSingle] = {29586},
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
        [29716] = { -- The Double Hozen Dare
            [questKeys.objectives] = {{{55267,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31230},
        },
        [29717] = { -- Down Kitty!
            [questKeys.startedBy] = {{55274,55413,55369}},
            [questKeys.preQuestSingle] = {31230},
        },
        [29725] = { -- SI:7 Report: Fire From the Sky
            [questKeys.preQuestSingle] = {29733},
            [questKeys.objectives] = {{{55349,nil,Questie.ICON_TYPE_EVENT},{55350,nil,Questie.ICON_TYPE_EVENT},{55351,nil,Questie.ICON_TYPE_EVENT},{55352,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29726] = { -- SI:7 Report: Hostile Natives
            [questKeys.preQuestSingle] = {29725},
            [questKeys.objectives] = {{{55378,nil,Questie.ICON_TYPE_INTERACT},{55380,nil,Questie.ICON_TYPE_INTERACT},{55381,nil,Questie.ICON_TYPE_TALK}},{{209615}}},
        },
        [29727] = { -- SI:7 Report: Hostile Natives
            [questKeys.preQuestSingle] = {29726},
            [questKeys.objectives] = {{{55408,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use it"),0,{{"object",209621}}}},
        },
        [29730] = { -- Scouting Report: Hostile Natives
            [questKeys.preQuestSingle] = {29971},
        },
        [29731] = { -- Scouting Report: On the Right Track
            [questKeys.preQuestSingle] = {29730},
        },
        [29733] = { -- SI:7 Report: Lost in the Woods
            [questKeys.preQuestSingle] = {29894},
            [questKeys.objectives] = {{{55454}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",55343}}}},
        },
        [29743] = { -- Monstrosity
            [questKeys.finishedBy] = {{110002}},
            [questKeys.objectives] = {nil,{{212182},{212183},{212184},{212186}}},
            [questKeys.preQuestSingle] = {31774},
        },
        [29745] = { -- The Sprites' Plight
            [questKeys.finishedBy] = {{110004}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29744},
        },
        [29747] = { -- Break the Cycle
            [questKeys.finishedBy] = {{110005}},
        },
        [29748] = { -- Simulacrumble
            [questKeys.finishedBy] = {{110005}},
            [questKeys.objectives] = {nil,{{214873}}},
            [questKeys.preQuestSingle] = {29745},
        },
        [29749] = { -- An Urgent Plea
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29747,29748},
        },
        [29750] = { -- Vessels of the Spirit
            [questKeys.preQuestSingle] = {29749},
        },
        [29751] = { -- Ritual Artifacts
            [questKeys.preQuestSingle] = {29749},
        },
        [29752] = { -- The Wayward Dead
            [questKeys.objectives] = {{{55290,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {29749},
        },
        [29753] = { -- Back to Nature
            [questKeys.preQuestGroup] = {29750,29751,29752},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{39.42,13.13},{40.36,12.34},{41.11,10.94},{37.92,8.02},{38.84,10}}},Questie.ICON_TYPE_EVENT,l10n("Smash the Spirit Bottles")}},
        },
        [29754] = { -- To Bridge Earth and Sky
            [questKeys.finishedBy] = {{110006}},
            [questKeys.triggerEnd] = {"Protect Pei-Zhi during his ritual", {[zoneIDs.THE_JADE_FOREST] = {{43.77,12.58}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestGroup] = {29753,29756},
        },
        [29755] = { -- Pei-Back
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Defeat the Stonebound Colossus"),0,{{"monster",56595}}}},
        },
        [29756] = { -- A Humble Offering
            [questKeys.preQuestGroup] = {29750,29751,29752},
        },
        [29757] = { -- Bottletoads
            [questKeys.objectives] = {nil,{{209950,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29759] = { -- Kung Din
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29558,29559,29560},
        },
        [29762] = { -- Family Heirlooms
            [questKeys.preQuestGroup] = {29883,29885},
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
            [questKeys.preQuestSingle] = {29827},
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
        [29865] = { -- The Silkwood Road
            [questKeys.preQuestSingle] = {31230},
        },
        [29866] = { -- The Threads that Stick
            [questKeys.preQuestSingle] = {31230},
        },
        [29871] = { -- Clever Ashyo
            [questKeys.preQuestSingle] = {30086},
        },
        [29872] = { -- Lin Tenderpaw
            [questKeys.preQuestSingle] = {30086},
            [questKeys.breadcrumbForQuestId] = 29981,
        },
        [29873] = { -- Ken-Ken
            [questKeys.breadcrumbForQuestId] = 30079,
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56146,56149,56150,56151,56278,56279,56280,56281},56146,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29883] = { -- The Pearlfin Situation
            [questKeys.preQuestSingle] = {29562},
            [questKeys.objectives] = {{{59058,nil,Questie.ICON_TYPE_TALK},{56693,nil,Questie.ICON_TYPE_TALK},{56690,nil,Questie.ICON_TYPE_TALK},{54960,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29885] = { -- Road Rations
            [questKeys.preQuestSingle] = {29562},
        },
        [29887] = { -- The Elder's Instruments
            [questKeys.preQuestGroup] = {29883,29885},
        },
        [29888] = { -- Seek Out the Lorewalker
            [questKeys.preQuestSingle] = {29727},
        },
        [29889] = { -- Borrowed Brew
            [questKeys.objectives] = {nil,{{209845}}},
        },
        [29890] = { -- Finding Your Center
            [questKeys.preQuestGroup] = {29891,29892,29893},
            [questKeys.objectives] = {nil,{{213754}}},
        },
        [29891] = { -- Potency
            [questKeys.preQuestSingle] = {31130},
            [questKeys.startedBy] = {{56287,61218}},
        },
        [29892] = { -- Body
            [questKeys.preQuestSingle] = {31130},
            [questKeys.startedBy] = {{56287,61218}},
        },
        [29893] = { -- Hue
            [questKeys.preQuestSingle] = {31130},
            [questKeys.startedBy] = {{56287,61218}},
        },
        [29894] = { -- Spirits of the Water
            [questKeys.preQuestGroup] = {29762,29887},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56398,54960},56398,nil,Questie.ICON_TYPE_TALK},{{54894},54894,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29898] = { -- Sacred Waters
            [questKeys.preQuestSingle] = {29890},
            [questKeys.objectives] = {nil,{{209885},{209888},{209889},{209890}}},
        },
        [29899] = { -- Rest in Peace
            [questKeys.preQuestSingle] = {29890},
        },
        [29900] = { -- An Ancient Legend
            [questKeys.preQuestSingle] = {29890},
        },
        [29901] = { -- Anduin's Decision
            [questKeys.startedBy] = {{110009}},
            [questKeys.preQuestGroup] = {29898,29899,29900},
            [questKeys.objectives] = {{{56434,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29903] = { -- A Perfect Match
            [questKeys.preQuestSingle] = {29727},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{54959,56585,56591,56592},56585,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("Give him a shield"),0,{{"monster",54959}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Give him a book"),0,{{"monster",56585}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Give him a staff"),0,{{"monster",56591}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Give him a dagger"),0,{{"monster",56592}}},
            },
        },
        [29905] = { -- Let Them Burn
            [questKeys.finishedBy] = {{54960}},
        },
        [29906] = { -- Carp Diem
            [questKeys.finishedBy] = {{54960}},
            [questKeys.preQuestSingle] = {29904},
        },
        [29907] = { -- Chen and Li Li
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {32018,32019}
        },
        [29908] = { -- A Seemingly Endless Nuisance
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Reveal Virmen Pesters"),0,{{"object",214638}}}},
        },
        [29909] = { -- Low Turnip Turnout
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29908,29877},
        },
        [29910] = { -- Rampaging Rodents
            [questKeys.preQuestSingle] = {29909},
            [questKeys.objectives] = {{{56203,nil,Questie.ICON_TYPE_INTERACT}},{{209835,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29912] = { -- The Fabulous Miss Fanny
            [questKeys.requiredSourceItems] = {75256,75258,75259},
            [questKeys.objectives] = {{{56192,nil,Questie.ICON_TYPE_TALK},{56192,nil,Questie.ICON_TYPE_TALK},{56192,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("After quest is complete, select 3rd option"),0,{{"monster",56192}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Pink Turnip - 2nd option"),1,{{"monster",56192}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Watermelon - 1st option"),2,{{"monster",56192}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Tofu - 3rd option"),3,{{"monster",56192}}},
            },
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
            [questKeys.sourceItemId] = 75208,
        },
        [29919] = { -- Great Minds Drink Alike
            [questKeys.preQuestSingle] = {29918},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Escort Chen and Li Li", {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{68.87,43.14}}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}}},
        },
        [29922] = { -- In Search of Wisdom
            [questKeys.preQuestGroup] = {29901,29905,29906},
            [questKeys.objectives] = {{{56737,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29924] = { -- Kill Kher Shan
            [questKeys.finishedBy] = {{110003}},
            [questKeys.preQuestSingle] = {31167},
        },
        [29925] = { -- All We Can Spare
            [questKeys.preQuestSingle] = {29723}, -- could also be 29716
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Toya"),0,{{"monster",56348}}}},
        },
        [29926] = { -- Calamity Jade
            [questKeys.preQuestSingle] = {29928},
        },
        [29927] = { -- Mann's Man
            [questKeys.objectives] = {{{56347,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {29928},
        },
        [29928] = { -- I Have No Jade And I Must Scream
            [questKeys.preQuestSingle] = {29925},
        },
        [29929] = { -- Trapped!
            [questKeys.objectives] = {{{56464,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29930] = { -- What's Mined Is Yours
            [questKeys.objectives] = {{{56527,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [29931] = { -- The Serpent's Heart
            [questKeys.preQuestGroup] = {29926,29930},
        },
        [29932] = { -- The Temple of the Jade Serpent
            [questKeys.objectives] = {{{57242,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take a ride to the Temple of the Jade Serpent"),0,{{"monster",59392}}}},
        },
        [29933] = { -- The Bees' Knees
            [questKeys.preQuestSingle] = {31167},
        },
        [29936] = { -- Instant Messaging
            [questKeys.objectives] = {{{56402,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.preQuestSingle] = {29935},
            [questKeys.finishedBy] = {{56339}},
        },
        [29937] = { -- Furious Fowl
            [questKeys.preQuestSingle] = {29941},
            [questKeys.finishedBy] = {{56406}},
        },
        [29939] = { -- Boom Bait
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{26.75,55.33}}},Questie.ICON_TYPE_INTERACT,l10n("Throw the Gut Bomb"),0}},
        },
        [29941] = { -- Beyond the Horizon
            [questKeys.objectives] = {{{56340,nil,Questie.ICON_TYPE_TALK},{56477,nil,Questie.ICON_TYPE_TALK},{56478,nil,Questie.ICON_TYPE_TALK},{56336,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {29936},
        },
        [29942] = { -- Silly Wikket, Slickies are for Hozen
            [questKeys.preQuestGroup] = {29937,31239}, -- 29937 is definitely a prequest. If someone else had 31239 then assume it must need both rather than just 31239
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
            [questKeys.sourceItemId] = 76370,
            [questKeys.objectives] = {{{56538,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29948] = { -- Thieves to the Core
            [questKeys.preQuestSingle] = {29944}, -- might be preQuestGroup with 29945
        },
        [29950] = { -- Li Li's Day Off
            [questKeys.objectives] = {{{56546,nil,Questie.ICON_TYPE_EVENT},{56547,nil,Questie.ICON_TYPE_EVENT},{56548,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.sourceItemId] = 76350,
        },
        [29951] = { -- Muddy Water
            [questKeys.preQuestSingle] = {29949},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Fill the vial"),0,{{"object",209921}}}},
        },
        [29952] = { -- Broken Dreams
            [questKeys.preQuestSingle] = {29950},
            [questKeys.objectives] = {{{56680,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}}},
        },
        [29966] = { -- Burning Down the House
            [questKeys.objectives] = {{{56509,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29967] = { -- Boom Goes the Doonamite!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56603,56624,56639,56644,56645},56603}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Rivett"),0,{{"monster",56525}}}},
        },
        [29968] = { -- Green-ish Energy
            [questKeys.preQuestSingle] = {29824},
        },
        [29971] = { -- The Scouts Return
            [questKeys.preQuestGroup] = {29939,29942},
        },
        [29981] = { -- Stemming the Swarm
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29872},
        },
        [29982] = { -- Evacuation Orders
            [questKeys.objectives] = {{{57120,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{57122,57121},57121,nil,Questie.ICON_TYPE_TALK},{{57124,57123},57123,nil,Questie.ICON_TYPE_TALK},{{57127,57126},57126,nil,Questie.ICON_TYPE_TALK},},}
        },
        [29983] = { -- The Hidden Master
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29981,29982},
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
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29985,29986,29992},
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
        [29993] = { -- Find the Boy
            [questKeys.preQuestSingle] = {29866},
        },
        [29997] = { -- The Scryer's Dilemma
            [questKeys.preQuestSingle] = {29932},
        },
        [29998] = { -- The Librarian's Quandary
            [questKeys.preQuestSingle] = {29932},
        },
        [29999] = { -- The Rider's Bind
            [questKeys.objectives] = {{{56853,nil,Questie.ICON_TYPE_INTERACT},{56852,nil,Questie.ICON_TYPE_INTERACT},{56851,nil,Questie.ICON_TYPE_INTERACT},{56850,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {29932},
        },
        [30000] = { -- The Jade Serpent
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29999,30004,30005,30011},
        },
        [30002] = { -- Pages of History
            [questKeys.preQuestSingle] = {29998},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Search through the book"),0,{{"object",209594}}}},
        },
        [30004] = { -- Everything In Its Place
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30001,30002},
        },
        [30005] = { -- Lighting Up the Sky
            [questKeys.objectives] = {nil,{{209672}}},
            [questKeys.preQuestSingle] = {29932},
        },
        [30006] = { -- The Darkness Around Us
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30015] = { -- Dawn's Blossom
            [questKeys.preQuestSingle] = {29967},
            [questKeys.preQuestGroup] = {},
        },
        [30027] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73209},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30028] = { -- Grain Recovery
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30029,30030,30031},
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
            [questKeys.triggerEnd] = {"Bring Mina Mudclaw home to her father", {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{44.22,34.65}}}},
            [questKeys.objectives] = {},
        },
        [30058] = { -- Mothallus!
            [questKeys.preQuestSingle] = {30059},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the bait"),0,{{"object",210117}}}},
        },
        [30063] = { -- Behind the Masks
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30064] = { -- Saving the Sutras
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30065},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30065] = { -- Arrows of Fortune
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30064},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30066] = { -- Hidden Power
            [questKeys.objectives] = {nil,nil,nil,nil,{{{57316,57326,57400},57316,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30067] = { -- The Shadow of Doubt
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30068},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30068] = { -- Flames of the Void
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30067},
            [questKeys.questFlags] = questFlags.DAILY,
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
        [30073] = { -- The Emperor
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30047,30172,30055},
        },
        [30075] = { -- Clear the Way
            [questKeys.preQuestSingle] = {30074},
        },
        [30076] = { -- The Fanciest Water
            [questKeys.preQuestSingle] = {30074},
        },
        [30077] = { -- Barrels, Man
            [questKeys.preQuestSingle] = {30074},
            [questKeys.objectives] = {{{57662,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30078] = { -- Cleaning House
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30075,30076,30077},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}},{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mudmug"),0,{{"monster",58027}}},{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Li Li"),0,{{"monster",58028}}},{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",58029}}}},
        },
        [30079] = { -- What's Eating Zhu's Watch?
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29873},
            [questKeys.objectives] = {{{57457,nil,Questie.ICON_TYPE_TALK},{57830,nil,Questie.ICON_TYPE_TALK},{57825,nil,Questie.ICON_TYPE_TALK},{57744,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30080] = { -- Finding Yi-Mo
            [questKeys.objectives] = {{{58376,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30081] = { -- Materia Medica
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30079,30082},
        },
        [30082] = { -- Cheer Up, Yi-Mo
            [questKeys.objectives] = {{{57310,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Yi-Mo"),0,{{"monster",58376}}}},
        },
        [30083] = { -- Securing the Province
            [questKeys.preQuestSingle] = {30091},
        },
        [30084] = { -- Borderlands
            [questKeys.preQuestSingle] = {30091},
            [questKeys.objectives] = {nil,{{210191},{210214},{210213}}},
        },
        [30085] = { -- Into the Brewery
            [questKeys.breadcrumbForQuestId] = 31327,
        },
        [30086] = { -- The Search for the Hidden Master
            [questKeys.preQuestGroup] = {29908,29877},
        },
        [30088] = { -- Why So Serious?
            [questKeys.preQuestSingle] = {30081},
        },
        [30089] = { -- Apply Directly to the Forehead
            [questKeys.preQuestSingle] = {30088},
            [questKeys.objectives] = {{{57457,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30090] = { -- Zhu's Despair
            [questKeys.preQuestSingle] = {30089},
            [questKeys.objectives] = {{{58409},{58410,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30117] = { -- Stoneplow Thirsts
            [questKeys.preQuestSingle] = {30078},
        },
        [30121] = { -- Search Party
            [questKeys.nextQuestInChain] = 30179,
            [questKeys.breadcrumbForQuestId] = 30179,
        },
        [30123] = { -- Skitterer Stew
            [questKeys.preQuestSingle] = {30179},
        },
        [30124] = { -- Blind Them!
            [questKeys.preQuestSingle] = {30179},
        },
        [30127] = { -- Threat from Dojan
            [questKeys.preQuestSingle] = {30123}, --might be group with 30124
        },
        [30128] = { -- The Water of Youth
            [questKeys.objectives] = {nil, nil,{{78934,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Na Lek"),0,{{"monster",55597}}}},
        },
        [30129] = { -- The Mogu Agenda
            [questKeys.preQuestSingle] = {30123}, --might be group with 30124
        },
        [30130] = { -- Herbal Remedies
            [questKeys.preQuestSingle] = {30123}, --might be group with 30124
        },
        [30131] = { -- Life
            [questKeys.objectives] = {{{58585,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Sunwalker Dezco"),0,{{"monster",58113}}}},
        },
        [30133] = { -- Into the Wilds
            [questKeys.preQuestSingle] = {30090},
            [questKeys.objectives] = {{{59151,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30135] = { -- Beating the Odds
            [questKeys.nextQuestInChain] = 30136,
        },
        [30136] = { -- Empty Nests
            [questKeys.preQuestSingle] = {30134},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58243,58244,58220},58244,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{63.33,31.46},{63.87,30.06},{64.28,29.03},{64.87,26.46},{65.32,26.38},{64.9,28.9},{65.15,30.07},{65.62,30.2},{65.68,30.67},{65.78,31.25}}}, Questie.ICON_TYPE_EVENT, l10n("Return the hatchlings to the nests")}},
        },
        [30137] = { -- Egg Collection
            [questKeys.preQuestSingle] = {30134},
        },
        [30138] = { -- Choosing the One
            [questKeys.preQuestGroup] = {30135,30136,30137},
        },
        [30139] = { -- The Rider's Journey
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30140,30141},
        },
        [30140] = { -- The Rider's Journey
            [questKeys.startedBy] = {},
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30139,30141},
        },
        [30141] = { -- The Rider's Journey
            [questKeys.startedBy] = {},
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30139,30140},
        },
        [30142] = { -- It's A...
            [questKeys.preQuestSingle] = {30139,30140,30141},
            [questKeys.nextQuestInChain] = 30143,
        },
        [30143] = { -- They Grow Like Weeds
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
            [questKeys.objectives] = {{{58420,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30144] = { -- Flight Training: Ring Round-Up
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",58428},{"monster",58429},{"monster",58430}}}},
        },
        [30145] = { -- Flight Training: Flight Training: Full Speed Ahead
            [questKeys.objectives] = {{{58444,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",58440},{"monster",58441},{"monster",58442}}}},
        },
        [30146] = { -- Snack Time
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30147] = { -- Fragments of the Past
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30148] = { -- Just a Flesh Wound
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
            [questKeys.objectives] = {{{58416,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {72985,72986},
        },
        [30149] = { -- A Feast for the Senses
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30150] = { -- Sweet as Honey
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30151] = { -- Catch!
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30152] = { -- The Sky Race
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30154] = { -- The Easiest Way To A Serpent's Heart
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30155] = { -- Restoring the Balance
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30156] = { -- The Easiest Way To A Serpent's Heart
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
            [questKeys.requiredSourceItems] = {79027,79028},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58348,58349,58350},58348,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30157] = { -- Emptier Nests
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58243,58244,58220},58244,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{63.33,31.46},{63.87,30.06},{64.28,29.03},{64.87,26.46},{65.32,26.38},{64.9,28.9},{65.15,30.07},{65.62,30.2},{65.68,30.67},{65.78,31.25}}}, Questie.ICON_TYPE_EVENT, l10n("Return the hatchlings to the nests")}},
        },
        [30158] = { -- Disarming the Enemy
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30159] = { -- Preservation
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30160] = { -- A Ruby Shard for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,41999} -- Not available at Best Friend
        },
        [30163] = { -- For the Tribe
            [questKeys.preQuestSingle] = {30132},
            [questKeys.objectives] = {{{58608,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30164] = { -- The Stoneplow Convoy [Horde]
            [questKeys.preQuestGroup] = {30229,30230,30163}, -- might not be all, my turn in order was 30229, 30163, 30230
            [questKeys.objectives] = {{{58955,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30172] = { -- Barreling Along
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Lead Mudmug back to Halfhill", {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{55.92,49.33}}}},
        },
        [30174] = { -- For Family
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30164,30175},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kor Bloodtusk"),0,{{"monster",58670}}}},
        },
        [30175] = { -- The Mantid
            [questKeys.preQuestGroup] = {30229,30230,30163}, -- might not be all, my turn in order was 30229, 30163, 30230
        },
        [30178] = { -- Into the Wilds
            [questKeys.preQuestSingle] = {30090},
            [questKeys.objectives] = {{{59151,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredSourceItems] = {79825},
        },
        [30179] = { -- Poisoned! [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {30121},
        },
        [30184] = { -- Mushan Mastery: Darkhide
            [questKeys.preQuestSingle] = {30181},
        },
        [30185] = { -- Tortoise Mastery
            [questKeys.preQuestSingle] = {30184},
        },
        [30186] = { -- Parental Mastery
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Hemet"),0,{{"monster",58461}}},
                {{[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{21.9,74.18}}},Questie.ICON_TYPE_EVENT,l10n("Enter the underwater cave")},
            },
        },
        [30187] = { -- Flight Training: In Due Course
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",58440},{"monster",58441},{"monster",58442}}}},
        },
        [30188] = { -- Riding the Skies (Jade Cloud Serpent)
            [questKeys.preQuestGroup] = {30140,30187},
        },
        [30189] = { -- A Lovely Apple for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,41999} -- Not available at Best Friend
        },
        [30190] = { -- Sprite Plight
            [questKeys.startedBy] = {{58819}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30191] = { -- Steer Clear of the Beer Here
            [questKeys.startedBy] = {{58819}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Attack it to drop the Stolen Mistfall Keg"),0,{{"monster",58673}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30192] = { -- My Town, It's on Fire
            [questKeys.startedBy] = {{58819}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.requiredSourceItems] = {85782},
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30193] = { -- Meating Expectations
            [questKeys.startedBy] = {{58818}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30194] = { -- Encroaching Storm
            [questKeys.startedBy] = {{59338}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30195] = { -- Blooming Blossoms
            [questKeys.startedBy] = {{58820}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.objectives] = {nil,nil,{{244172}}},
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30196] = { -- Lushroom Rush
            [questKeys.startedBy] = {{58818}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30200] = { -- In Ashen Webs
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30227}, -- not visible once the final quest in hub is picked up
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30204] = { -- That's Not a Rock! -- 2 out of 4 - 30204 30205 30206 30304
            [questKeys.startedBy] = {{58504}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30227}, -- TO DO. fugly fix to stop showing them once the elite quest is picked up. That one doesn't need these though
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30205] = { -- Runelocked -- 2 out of 4 - 30204 30205 30206 30304
            [questKeys.startedBy] = {{63266}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30227}, -- TO DO. fugly fix to stop showing them once the elite quest is picked up. That one doesn't need these though
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30206] = { -- Runes in the Ruins -- 2 out of 4 - 30204 30205 30206 30304
            [questKeys.startedBy] = {{63266}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30227}, -- TO DO. fugly fix to stop showing them once the elite quest is picked up. That one doesn't need these though
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30225] = { -- The Ashweb Matriarch
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestGroup] = {30200,30226}, -- TO DO: check if it is offered after Anji quests are turned in
            [questKeys.objectives] = {{{245926}}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30227},
        },
        [30226] = { -- Blood on the Rise
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30227,30228}, -- not visible once the final quest in hub is picked up
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30227] = { -- Wulon, the Granite Sentinel
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestGroup] = {30200,30226}, -- is offered after Anji quests are turned in
            [questKeys.objectives] = {{{63510}}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30225},
        },
        [30228] = { -- Troubling the Troublemakers
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30226,30227}, -- not visible once the final quest in hub is picked up
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30229] = { -- The Greater Danger
            [questKeys.preQuestSingle] = {30132},
        },
        [30230] = { -- Re-Reclaim
            [questKeys.preQuestSingle] = {30132},
        },
        [30231] = { -- Pomfruit Pickup
            [questKeys.startedBy] = {{58818}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30232] = { -- Ruffling Some Feathers
            [questKeys.startedBy] = {{58818}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30233] = { -- Cracklefang
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{59343}},
            [questKeys.objectives] = {{{246178}}},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284},
            [questKeys.exclusiveTo] = {30234,31240,31244,31245,31246,31247},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30234] = { -- Vicejaw
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{59343}},
            [questKeys.objectives] = {{{246176}}},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284},
            [questKeys.exclusiveTo] = {30233,31240,31244,31245,31246,31247},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30235] = { -- Quid Pro Quo
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.objectives] = {{{244995}}},
            [questKeys.preQuestSingle] = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263}, -- needs daily module
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30236,30239,30385,31294,31295},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30236] = { -- Aetha
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.objectives] = {{{244975}}},
            [questKeys.preQuestSingle] = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263}, -- needs daily module
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30235,30239,30385,31294,31295},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30237] = { -- The Pandaren Uprising Relived
            [questKeys.startedBy] = {{59338}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30238] = { -- Return to Rest
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.objectives] = {nil,{{210419}}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30239] = { -- Lao-Fe the Slavebinder
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.objectives] = {{{246479}}},
            [questKeys.exclusiveTo] = {30235,30236,30385,31294,31295},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30240] = { -- Survival Ring: Flame
            [questKeys.startedBy] = {{59340}},
            [questKeys.finishedBy] = {{58743}},
            [questKeys.exclusiveTo] = {30242},
            [questKeys.preQuestSingle] = {30385, -- Setting Sun Garrison from 59338 Mistfall Peace
                                          31247, -- Setting Sun Garrison from 59343 Lake Peace
                                          31250, -- Setting Sun Garrison from 59337 Mistfall Attack
                                          31297, -- Setting Sun Garrison from 58408 Lake Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58967,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30241] = { -- Warn Stoneplow [Horde]
            [questKeys.exclusiveTo] = {30376},
        },
        [30242] = { -- Survival Ring: Blades
            [questKeys.startedBy] = {{59340}},
            [questKeys.finishedBy] = {{59340}},
            [questKeys.exclusiveTo] = {30240},
            [questKeys.preQuestSingle] = {30385, -- Setting Sun Garrison from 59338 Mistfall Peace
                                          31247, -- Setting Sun Garrison from 59343 Lake Peace
                                          31250, -- Setting Sun Garrison from 59337 Mistfall Attack
                                          31297, -- Setting Sun Garrison from 58408 Lake Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30243] = { -- Mantid Under Fire -- TO DO check it
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30245,30246,30266,30444}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use it"),0,{{"monster",64369}}}},
        },
        [30244] = { -- Along the Serpent's Spine -- TO DO check it
            [questKeys.startedBy] = {{58920}},
            [questKeys.finishedBy] = {{58920}},
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63974,63976},63974}}}, -- TO DO check it
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30245,30246,30266,30444}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.nextQuestInChain] = 30249,
        },
        [30245] = { -- Lost Scouts
            [questKeys.startedBy] = {{58920}},
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30243,30244,30246,30266}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58947,58930},58930,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.nextQuestInChain] = 30248,
        },
        [30246] = { -- Upon the Ramparts
            [questKeys.startedBy] = {{58919}},
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30243,30244,30245,30444}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.nextQuestInChain] = 30251,
        },
        [30248] = { -- The Butcher
            [questKeys.startedBy] = {{58920}},
            [questKeys.finishedBy] = {{58920}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {{{246386}}},
            [questKeys.questFlags] = questFlags.DAILY,
            -- [questKeys.exclusiveTo] = {30249,30251}, -- doesn't need, all 3 are direct followups
        },
        [30249] = { -- Under the Setting Sun
            [questKeys.startedBy] = {{58920}},
            [questKeys.finishedBy] = {{58920}},
            -- [questKeys.preQuestSingle] = {30244}, -- doesn't need, it is direct followup
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {{{246383}}},
            [questKeys.questFlags] = questFlags.DAILY,
            -- [questKeys.exclusiveTo] = {30248,30251}, -- doesn't need, all 3 are direct followups
        },
        [30251] = { -- Vyraxxis, the Krik'thik Swarm-Lord
            [questKeys.startedBy] = {{58919}},
            -- [questKeys.preQuestSingle] = {30246}, -- doesn't need, it is direct followup
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {{{246384}}},
            [questKeys.questFlags] = questFlags.DAILY,
            -- [questKeys.exclusiveTo] = {30248,30249}, -- doesn't need, all 3 are direct followups
        },
        [30252] = { -- A Helping Hand
            [questKeys.objectives] = {{{58719,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.breadcrumbs] = {31372,31374},
        },
        [30254] = { -- Learn and Grow II: Tilling and Planting
            [questKeys.preQuestSingle] = {30535},
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
            [questKeys.requiredSourceItems] = {79269},
        },
        [30258] = { --Mung-Mung's Vote I: A Hozen's Problem
            [questKeys.requiredMinRep] = {1272,14600}, -- available at 5600/12000 honored with Tillers
        },
        [30260] = { -- Growing the Farm I: The Weeds
            [questKeys.requiredMinRep] = {1272,9000},
        },
        [30261] = { -- Roll Club: Serpent's Spine
            [questKeys.preQuestSingle] = {30640},
        },
        [30263] = { -- Clearing in the Forest
            [questKeys.startedBy] = {{59338}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30265] = { -- Sparkle in the Eye
            [questKeys.startedBy] = {{59343}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30291,30338},
        },
        [30266] = { -- Bloodied Skies
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30243,30244,30245,30444}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use it"),0,{{"monster",64336}}}},
        },
        [30268] = { -- The Murksweats
            [questKeys.preQuestSingle] = {30269},
        },
        [30269] = { -- Unsafe Passage
            [questKeys.preQuestSingle] = {30133,30178}, -- Either Horde or Alliance version as prequest
            [questKeys.triggerEnd] = {"Accompany Koro to Crane Wing Refuge", {[zoneIDs.KRASARANG_WILDS] = {{43.86,36.77}}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Koro Mistwalker"),0,{{"monster",58547}}},{nil,Questie.ICON_TYPE_INTERACT,l10n("Talk to Koro Mistwalker"),0,{{"monster",58978}}}},
        },
        [30270] = { -- Blinding the Riverblades
            [questKeys.preQuestSingle] = {30269},
        },
        [30271] = { -- Sha Can Awe
            [questKeys.preQuestGroup] = {30268,30270,30694}, -- might not be all, my turn in order was 30268, 30694, 30270
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58968,58969,59297},59297,nil,Questie.ICON_TYPE_EVENT},},},
        },
        [30272] = { -- Striking the Rain
            [questKeys.preQuestGroup] = {30268,30270,30694}, -- might not be all, my turn in order was 30268, 30694, 30270
        },
        [30273] = { -- In the House of the Red Crane
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30271,30272,30695}, -- might not be all, my turn in order was 30695, 30271, 30272
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chi-Ji"),0,{{"monster",59653}}}},
        },
        [30277] = { -- The Crumbling Hall
            [questKeys.startedBy] = {{58503,58919}},
            [questKeys.finishedBy] = {{58503,58919}},
            --[questKeys.objectives] = {{{65286}},nil,{{87790}}}, -- TO DO: check this
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestGroup] = {30642,31240}, -- TO DO: 31240 needs exclusiveTo with the other Ruins lead ins
            [questKeys.exclusiveTo] = {30280},
        },
        [30280] = { -- The Thunder Below
            [questKeys.startedBy] = {{58503,58919}},
            [questKeys.finishedBy] = {{58503,58919}},
            --[questKeys.objectives] = {{{64965}}}, -- TO DO: check ID and Milau needs spawn anyway
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestGroup] = {30642,31240}, -- TO DO: 31240 needs exclusiveTo with the other Ruins lead ins
            [questKeys.exclusiveTo] = {30277},
        },
        [30281] = { -- The Silent Approach
            [questKeys.startedBy] = {{58470}},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
            [questKeys.exclusiveTo] = {31131,31242,31243},
        },
        [30282] = { -- Burning Away the Filth
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
            [questKeys.objectives] = {{{63076,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {31131,31242,31243},
        },
        [30283] = { -- A Smashing Impression
            [questKeys.startedBy] = {{58469}},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
            [questKeys.exclusiveTo] = {31131,31242,31243},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63087,63088,63089,63090},63087,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30284] = { -- A Thousand Pointy Teeth
            [questKeys.startedBy] = {{59343}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30342},
        },
        [30285] = { -- Wu Kao Scouting Reports
            [questKeys.startedBy] = {{59337}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30286] = { -- Backed Into a Corner
            [questKeys.startedBy] = {{59337}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.objectives] = {nil,nil,nil,nil,{{{64187,63949},63949,nil,Questie.ICON_TYPE_INTERACT}}}, -- both IDs need spawns
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30287] = { -- Mogu Make Poor House Guests
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30288] = { -- My Town, It's On Fire Again
            [questKeys.startedBy] = {{59336}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.requiredSourceItems] = {85950},
            [questKeys.objectives] = {{{63943,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30289] = { -- Freeing Mind and Body
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.objectives] = {{{64200,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30290] = { -- Stonebound Killers
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.objectives] = {{{64200,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30291] = { -- Stunning Display
            [questKeys.startedBy] = {{59343}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30265,30338},
        },
        [30292] = { -- Rude Awakenings
            [questKeys.startedBy] = {{58471}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63130,63082},63082}}},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
            [questKeys.exclusiveTo] = {30293,31131,31242,31243},
        },
        [30293] = { -- In Enemy Hands
            [questKeys.startedBy] = {{58471}},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
            [questKeys.exclusiveTo] = {30292,31131,31242,31243},
        },
        [30296] = { -- Gaohun the Soul-Severer
            [questKeys.startedBy] = {{58911}},
            [questKeys.finishedBy] = {{58911}},
            [questKeys.objectives] = {{{245153}}},
            [questKeys.preQuestSingle] = {30288}, -- needs daily module
            [questKeys.exclusiveTo] = {30297,31250,31296},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30297] = { -- Baolai the Immolator
            [questKeys.startedBy] = {{58911}},
            [questKeys.finishedBy] = {{58911}},
            [questKeys.objectives] = {{{245163}}},
            [questKeys.preQuestSingle] = {30288}, -- needs daily module
            [questKeys.exclusiveTo] = {30296,31250,31296},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30298] = { -- Painting the Ruins Red
            [questKeys.startedBy] = {{59332}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30302}, -- TO DO: check if still showing once the elite quest is picked up. 
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63610,63611,63641},63610}}}, -- TO DO: check this
        },
        [30299] = { -- No Stone Unturned
            [questKeys.startedBy] = {{59334}},
            [questKeys.finishedBy] = {{59334}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30302,30305}, -- TO DO: check if still showing once the elite quest is picked up. 
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63333,63447,63556,63674},63333}}}, -- TO DO: check this. 63333,63447 have no spawns atm
        },
        [30300] = { -- The Key to Success
            [questKeys.startedBy] = {{59334}},
            [questKeys.finishedBy] = {{59334}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30302,30481}, -- TO DO: check if still showing once the elite quest is picked up. 
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63640,63652,63653,63654,63655,63656,63657},63640,nil,Questie.ICON_TYPE_INTERACT}}}, -- TO DO: 63655 -> 63657 have no spawns atm
            -- [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",182484}}}}, -- TO DO: find out cage id
            [questKeys.requiredSourceItems] = {85582},
        },
        [30301] = { -- Offering a Warm Welcome
            [questKeys.startedBy] = {{59332}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30302}, -- TO DO: check if still showing once the elite quest is picked up. 
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,{{210680}}}, -- TO DO: check this
        },
        [30302] = { -- The Imperion Threat
            [questKeys.startedBy] = {{59332}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestGroup] = {30298,30301,30305,30481}, -- TO DO: check if it needs 4 prequests
            [questKeys.objectives] = {nil,nil,nil,nil,{{{62880,62881,63691},62880}}}, -- check IDs
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30304] = { -- Hard as a Rock -- 2 out of 4 - 30204 30205 30206 30304
            [questKeys.startedBy] = {{58504}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.exclusiveTo] = {30225,30227}, -- TO DO. fugly fix to stop showing them once the elite quest is picked up. That one doesn't need these though
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30305] = { -- He Knows What He's Doing
            [questKeys.startedBy] = {{59333}},
            [questKeys.finishedBy] = {{59333}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30299,30302}, -- TO DO: check if still showing once the elite quest is picked up. 
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            --[questKeys.objectives] = {}, -- TO DO: need to check this
        },
        [30306] = { -- The Battle Ring
            [questKeys.startedBy] = {{58919}},
            [questKeys.finishedBy] = {{58962}},
            [questKeys.preQuestSingle] = {30385, -- Setting Sun Garrison from 59338 Mistfall Peace
                                          31247, -- Setting Sun Garrison from 59343 Lake Peace
                                          31250, -- Setting Sun Garrison from 59337 Mistfall Attack
                                          31297, -- Setting Sun Garrison from 58408 Lake Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30307] = { -- The Eternal Vigil
            [questKeys.startedBy] = {{58408}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.requiredSpell] = 115913,
        },
        [30308] = { -- Stone Hard Quilen
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31757,30309,30310},
            [questKeys.requiredSpell] = 115913,
        },
        [30309] = { -- Set in Stone
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31757,30308,30310},
            [questKeys.requiredSpell] = 115913,
        },
        [30310] = { -- Thundering Skies
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31757,30308,30309},
            [questKeys.requiredSpell] = 115913,
        },
        [30312] = { -- Given a Second Chance
            [questKeys.startedBy] = {{58468}},
            [questKeys.objectives] = {{{59183,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {30320,31755},
            [questKeys.requiredSpell] = 115913,
        },
        [30313] = { -- The Moving Mists
            [questKeys.startedBy] = {{59342}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30314,30341},
        },
        [30314] = { -- The Displaced Paleblade
            [questKeys.startedBy] = {{59342}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30313,30341},
        },
        [30317] = { -- Water, Water Everywhere
            [questKeys.objectives] = {{{59574,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Borrow a kite"),0,{{"monster",60231}}}},
        },
        [30319] = { -- Pest Problems
            [questKeys.preQuestSingle] = {30257},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Wika-Wika"),0,{{"monster",59532}}}},
        },
        [30320] = { -- Free Spirits
            [questKeys.startedBy] = {{58468}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {30312,31755},
            [questKeys.objectives] = {{{59231,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Phase into the spirit void"),0,{{"monster",59219}}}},
            [questKeys.requiredSpell] = 115913,
        },
        [30321] = { -- Weed War II
            [questKeys.requiredMinRep] = {1272,9000},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",57385},{"monster",59529}}}},
        },
        [30322] = { -- Money Matters
            [questKeys.preQuestSingle] = {30257},
        },
        [30325] = { -- Where it Counts
            [questKeys.objectives] = {{{59123}},{{210890},{210955}}},
        },
        [30326] = { -- The Kunzen Legend-Chief
            [questKeys.preQuestSingle] = {30257},
        },
        [30327] = { -- You Have to Burn the Ropes
            [questKeys.objectives] = {nil,{{210760}}},
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
        [30333] = { -- The Lesser of Two Evils
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30334,30335,30336,30337},
        },
        [30334] = { -- Stealing is Bad... Re-Stealing is OK
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30335,30336,30337},
        },
        [30335] = { -- Stalling the Ravage
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30334,30336,30337},
        },
        [30336] = { -- The Kunzen Hunter-Chief
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30334,30335,30337},
        },
        [30337] = { -- Simian Sabotage
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30334,30335,30336},
            [questKeys.objectives] = {{{59276,nil,Questie.ICON_TYPE_INTERACT},{59278,nil,Questie.ICON_TYPE_INTERACT},{59279,nil,Questie.ICON_TYPE_INTERACT},{59280,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30338] = { -- A Weighty Task
            [questKeys.startedBy] = {{59343}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30265,30291},
        },
        [30339] = { -- Getting your Hands Dirty
            [questKeys.startedBy] = {{59341}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30340},
        },
        [30340] = { -- Stick in the Mud
            [questKeys.startedBy] = {{59341}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30339},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30341] = { -- Under Watchful Eyes
            [questKeys.startedBy] = {{59342}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30313,30314},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30342] = { -- Fiery Tongue, Fragile Feet
            [questKeys.startedBy] = {{59343}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30284},
        },
        [30344] = { -- The Lost Dynasty
            [questKeys.preQuestSingle] = {30274},
        },
        --[[[30346] = { -- Where are the Pools
            [questKeys.preQuestSingle] = {30344}, -- it might also need 30350
        },]]
        [30348] = { -- Immortality?
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30347,30349}, -- might also need 30346/30351
        },
        [30349] = { -- Threat from Dojan
            [questKeys.preQuestSingle] = {30344}, -- it might also need 30350
        },
        [30350] = { -- Squirmy Delight
            [questKeys.preQuestSingle] = {29874},
        },
        [30351] = { -- Lotus Tea
            [questKeys.preQuestSingle] = {30344}, -- it might also need 30350
        },
        [30354] = { -- No Sister Left Behind
            [questKeys.preQuestSingle] = {30363,30465},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58720,58639},58639,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30355] = { -- Re-Reclaim
            [questKeys.preQuestSingle] = {30363,30465},
        },
        [30356] = { -- Sever Their Supply Line
            [questKeys.preQuestSingle] = {30363,30465},
        },
        [30357] = { -- The Stoneplow Convoy [Alliance]
            [questKeys.preQuestGroup] = {30354,30355,30356},
            [questKeys.objectives] = {{{58955,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30359] = { -- The Lord Reclaimer
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30357,30361},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Lyalia"),0,{{"monster",58976}}}},
        },
        [30360] = { -- Warn Stoneplow [Alliance]
            [questKeys.exclusiveTo] = {30376},
        },
        [30361] = { -- The Mantid
            [questKeys.preQuestGroup] = {30354,30355,30356},
        },
        [30363] = { -- Going on the Offensive
            [questKeys.preQuestSingle] = {30348},
            [questKeys.exclusiveTo] = {30465},
        },
        [30379] = { -- A Ruby Shard for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,41999} -- Not available at Best Friend
        },
        [30380] = { -- A Lovely Apple for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,41999} -- Not available at Best Friend
        },
        [30381] = { -- A Jade Cat for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,41999} -- Not available at Best Friend
        },
        [30382] = { -- A Blue Feather for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,41999} -- Not available at Best Friend
        },
        [30383] = { -- A Marsh Lily for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,41999} -- Not available at Best Friend
        },
        [30384] = { -- Blind Them!
            [questKeys.preQuestSingle] = {30274},
        },
        [30385] = { -- Setting Sun Garrison -- Mistfall Peace to Garrison lead out
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{58919}},
            [questKeys.preQuestSingle] = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263}, -- needs daily module
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31294,31295},
        },
        [30386] = { -- A Dish for Ella
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30387] = { -- A Jade Cat for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,41999} -- Not available at Best Friend
        },
        [30388] = { -- A Blue Feather for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,41999} -- Not available at Best Friend
        },
        [30389] = { -- A Marsh Lily for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,41999} -- Not available at Best Friend
        },
        [30390] = { -- A Dish for Gina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30391] = { -- A Ruby Shard for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,41999} -- Not available at Best Friend
        },
        [30392] = { -- A Lovely Apple for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,41999} -- Not available at Best Friend
        },
        [30393] = { -- A Jade Cat for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,41999} -- Not available at Best Friend
        },
        [30394] = { -- A Blue Feather for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,41999} -- Not available at Best Friend
        },
        [30395] = { -- A Marsh Lily for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,41999} -- Not available at Best Friend
        },
        [30396] = { -- A Dish for Old Hillpaw
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30397] = { -- A Ruby Shard for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,41999} -- Not available at Best Friend
        },
        [30398] = { -- A Lovely Apple for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,41999} -- Not available at Best Friend
        },
        [30399] = { -- A Jade Cat for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,41999} -- Not available at Best Friend
        },
        [30400] = { -- A Blue Feather for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,41999} -- Not available at Best Friend
        },
        [30401] = { -- A Marsh Lily for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,41999} -- Not available at Best Friend
        },
        [30402] = { -- A Dish for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30403] = { -- A Ruby Shard for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,41999} -- Not available at Best Friend
        },
        [30404] = { -- A Lovely Apple for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,41999} -- Not available at Best Friend
        },
        [30405] = { -- A Jade Cat for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,41999} -- Not available at Best Friend
        },
        [30406] = { -- A Blue Feather for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,41999} -- Not available at Best Friend
        },
        [30407] = { -- A Marsh Lily for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,41999} -- Not available at Best Friend
        },
        [30408] = { -- A Dish for Sho
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30409] = { -- A Ruby Shard for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,41999} -- Not available at Best Friend
        },
        [30410] = { -- A Lovely Apple for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,41999} -- Not available at Best Friend
        },
        [30411] = { -- A Jade Cat for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,41999} -- Not available at Best Friend
        },
        [30412] = { -- A Blue Feather for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,41999} -- Not available at Best Friend
        },
        [30413] = { -- A Marsh Lily for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,41999} -- Not available at Best Friend
        },
        [30414] = { -- A Dish for Haohan
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30415] = { -- A Ruby Shard for Chee Chee
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,41999} -- Not available at Best Friend
        },
        [30416] = { -- A Ruby Shard for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,41999} -- Not available at Best Friend
        },
        [30417] = { -- A Lovely Apple for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,41999} -- Not available at Best Friend
        },
        [30418] = { -- A Jade Cat for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,41999} -- Not available at Best Friend
        },
        [30419] = { -- A Blue Feather for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,41999} -- Not available at Best Friend
        },
        [30420] = { -- A Marsh Lily for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,41999} -- Not available at Best Friend
        },
        [30421] = { -- A Dish for Farmer Fung
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30422] = { -- A Ruby Shard for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,41999} -- Not available at Best Friend
        },
        [30423] = { -- A Lovely Apple for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,41999} -- Not available at Best Friend
        },
        [30424] = { -- A Jade Cat for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,41999} -- Not available at Best Friend
        },
        [30425] = { -- A Blue Feather for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,41999} -- Not available at Best Friend
        },
        [30426] = { -- A Marsh Lily for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,41999} -- Not available at Best Friend
        },
        [30427] = { -- A Dish for Fish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30428] = { -- A Ruby Shard for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,41999} -- Not available at Best Friend
        },
        [30429] = { -- A Lovely Apple for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,41999} -- Not available at Best Friend
        },
        [30430] = { -- A Jade Cat for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,41999} -- Not available at Best Friend
        },
        [30431] = { -- A Blue Feather for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,41999} -- Not available at Best Friend
        },
        [30432] = { -- A Marsh Lily for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,41999} -- Not available at Best Friend
        },
        [30433] = { -- A Dish for Tina
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30434] = { -- A Ruby Shard for Jogu
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,41999} -- Not available at Best Friend
        },
        [30435] = { -- A Lovely Apple for Jogu
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,41999} -- Not available at Best Friend
        },
        [30436] = { -- A Jade Cat for Jogu
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,41999} -- Not available at Best Friend
        },
        [30437] = { -- A Blue Feather for Jogu
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,41999} -- Not available at Best Friend
        },
        [30438] = { -- A Marsh Lily for Jogu
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,41999} -- Not available at Best Friend
        },
        [30439] = { -- A Dish for Jogu
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30444] = { -- No Reprieve
            [questKeys.startedBy] = {{58919}},
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30243,30244,30246,30266}, -- the other 2 groups of 2 quests in this hub stage
        },
        [30457] = { -- Call Out Their Leader
            [questKeys.preQuestSingle] = {},
        },
        [30460] = { -- Hit Medicine
            [questKeys.objectives] = {{{59143,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30465] = { -- Going on the Offensive
            [questKeys.exclusiveTo] = {30363}, -- need to find actual prequest
        },
        [30466] = { -- Sufficient Motivation
            [questKeys.objectives] = {nil,nil,{{79884}},nil,{{{59740,59296},59296,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30000},
            [questKeys.breadcrumbs] = {30499},
        },
        [30467] = { -- My Son...
            [questKeys.breadcrumbs] = {31451,31452},
        },
        [30470] = { -- A Gift For Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30471,30472,30473,30474,30475,30476,30477,30478,30479},
        },
        [30471] = { -- A Gift For Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30472,30473,30474,30475,30476,30477,30478,30479},
        },
        [30472] = { -- A Gift For Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30473,30474,30475,30476,30477,30478,30479},
            [questKeys.objectives] = {nil,{{210873,nil,Questie.ICON_TYPE_OBJECT}}},
        },
        [30473] = { -- A Gift For Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30474,30475,30476,30477,30478,30479},
        },
        [30474] = { -- A Gift For Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30475,30476,30477,30478,30479},
        },
        [30475] = { -- A Gift For Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30476,30477,30478,30479},
            [questKeys.requiredSourceItems] = {80232},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Ask him to cook the Bloody Plainshawk Leg"),0,{{"monster",58712}}}},
        },
        [30476] = { -- A Gift For Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30477,30478,30479},
        },
        [30477] = { -- A Gift For Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30476,30478,30479},
        },
        [30478] = { -- A Gift For Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30476,30477,30479},
            [questKeys.requiredSourceItems] = {80234,80235},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30479] = { -- A Gift For Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30476,30477,30478},
        },
        [30480] = { -- The Ritual
            [questKeys.preQuestGroup] = {30468,30967}, -- might also be 30496
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{60973,nil,Questie.ICON_TYPE_TALK},{61654},{61530}}},
        },
        [30481] = { -- Carved in Stone
            [questKeys.startedBy] = {{59333}},
            [questKeys.finishedBy] = {{59333}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30300,30302}, -- TO DO: check if still showing once the elite quest is picked up. 
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,{{85278}}},
        },
        [30482] = { -- The Soul-Gatherer
            [questKeys.startedBy] = {{58470}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31136,31248,31249,31297},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30484] = { -- Gauging Our Progress
            [questKeys.objectives] = {nil,nil,{{80013,nil,Questie.ICON_TYPE_TALK},{80014,nil,Questie.ICON_TYPE_TALK},{80015,nil,Questie.ICON_TYPE_TALK},{80061,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30485] = { -- Last Piece of the Puzzle
            [questKeys.preQuestGroup] = {30466,30484},
            [questKeys.objectives] = {nil,{{213652}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mishi"),0,{{"monster",64207}}}},
        },
        [30487] = { -- Comin' Round the Mountain
            [questKeys.preQuestGroup] = {30601,30618,30621},
            [questKeys.objectives] = {{{60094,nil,Questie.ICON_TYPE_MOUNT_UP},{60022,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30488] = { -- The Missing Muskpaw
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31456,31457},
        },
        [30491] = { -- At the Yak Wash
            [questKeys.triggerEnd] = {"Escaped Yak Washed", {[zoneIDs.KUN_LAI_SUMMIT] = {{71.4,69.27}}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",59319},{"monster",59662},{"monster",61874}}}},
        },
        [30492] = { -- Back in Yak
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30489,30491,30587}, -- probably needs 30804 too
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"	Bring Yak Herd to Lucky Eightcoins", {[zoneIDs.KUN_LAI_SUMMIT] = {{65.38,61.45}}}},
        },
        [30495] = { -- Love's Labor
            [questKeys.objectives] = {{{59395,nil,Questie.ICON_TYPE_TALK},{59401,nil,Questie.ICON_TYPE_TALK},{59392,nil,Questie.ICON_TYPE_TALK},{59397,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kitemaster Shoku for a ride to the top"),4,{{"monster",59392}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kitemaster Inga for a ride back to the bottom"),4,{{"monster",59400}}},
            },
        },
        [30498] = { -- Get Back Here! (Alliance)
            [questKeys.preQuestSingle] = {30000},
        },
        [30499] = { -- Get Back Here! (Horde)
            [questKeys.preQuestSingle] = {30000},
            [questKeys.breadcrumbForQuestId] = 30466,
        },
        [30502] = { -- Jaded Heart
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59434,59454},59454,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31303},
            [questKeys.requiredSourceItems] = {80074},
        },
        [30504] = { -- Emergency Response
            [questKeys.objectives] = {{{64360,nil,Questie.ICON_TYPE_INTERACT},{64362,nil,Questie.ICON_TYPE_INTERACT},{64363,nil,Questie.ICON_TYPE_INTERACT},{64364,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31303},
        },
        [30506] = { -- Admiral Taylor has Awakened
            [questKeys.exclusiveTo] = {30507,30508},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30457,30459,30460},
        },
        [30507] = { -- Admiral Taylor has Awakened
            [questKeys.exclusiveTo] = {30506,30508},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30457,30459,30460},
        },
        [30508] = { -- Admiral Taylor has Awakened
            [questKeys.exclusiveTo] = {30506,30507},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30457,30459,30460},
        },
        [30509] = { -- General Nazgrim has Awakened
            [questKeys.exclusiveTo] = {30510,30511},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30457,30459,30460},
        },
        [30510] = { -- General Nazgrim has Awakened
            [questKeys.exclusiveTo] = {30509,30511},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30457,30459,30460},
        },
        [30511] = { -- General Nazgrim has Awakened
            [questKeys.exclusiveTo] = {30509,30510},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30457,30459,30460},
        },
        [30512] = { -- Westwind Rest
            [questKeys.preQuestSingle] = {30506,30507,30508},
            [questKeys.objectives] = {{{63754,nil,Questie.ICON_TYPE_TALK},{63542,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30513] = { -- Eastwind Rest
            [questKeys.preQuestSingle] = {30509,30510,30511},
            [questKeys.objectives] = {{{63751,nil,Questie.ICON_TYPE_TALK},{63535,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30514] = { -- Challenge Accepted [Alliance]
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Set the Yaungol Banner ablaze"),0,{{"object",210933}}}},
        },
        [30515] = { -- Challenge Accepted [Horde]
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Set the Yaungol Banner ablaze"),0,{{"object",210933}}}},
        },
        [30516] = { -- Growing the Farm I: A Little Problem
            [questKeys.requiredMinRep] = {1272,9000},
        },
        [30517] = { -- Farmer Fung's Vote I: Yak Attack
            --[questKeys.preQuestSingle] = {31946}, -- Conflicting info that Mung-Mung's chain needs to be completed before Farmer Fung's - some comments on wowhead about doing in parallel. Placeholder prequest in case this is a requirement
            [questKeys.requiredMinRep] = {1272,25200} -- Tillers 4200 into Revered (wowhead)
        },
        [30518] = { -- Farmer Fung's Vote I: Yak Attack
            [questKeys.extraObjectives] = {{{[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{50.44,34.33}}},Questie.ICON_TYPE_EVENT,l10n("Bring the yaks here")}},
            [questKeys.objectives] = {{{59491,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [30519] = { -- Nana's Vote I: Nana's Secret Recipe
            [questKeys.preQuestSingle] = {31947}, -- Farmer Fung chain required for Nana
            [questKeys.requiredMinRep] = {1272,29400} -- Tillers 8400 into Revered (wowhead)
        },
        [30521] = { -- Haohan's Vote I: Bungalow Break-In
            [questKeys.preQuestSingle] = {31949}, -- Nana chain required for Haohan
            [questKeys.requiredMinRep] = {1272,37800} -- Tillers 16800 into Revered (wowhead)
        },
        [30523] = { -- Growing the Farm II: The Broken Wagon
            [questKeys.requiredMinRep] = {1272,21000} -- Tillers at Revered (wowhead)
        },
        [30525] = { -- Haohan's Vote III: Pure Poison
            [questKeys.preQuestSingle] = {30522},
        },
        [30526] = { -- Lost and Lonely
            [questKeys.requiredMinRep] = {1272,33600} -- Tillers 12600 into Revered (wowpedia)
        },
        [30527] = { -- Haohan's Vote IV: Melons For Felons
            [questKeys.preQuestSingle] = {30525},
        },
        [30528] = { -- Haohan's Vote V: Chief Yip-Yip
            [questKeys.preQuestSingle] = {30527},
        },
        [30529] = { -- Growing the Farm III: The Mossy Boulder
            [questKeys.requiredMinRep] = {1272,42000} -- Tillers at Exalted (wowhead)
        },
        [30535] = { -- Learn and Grow I: Seeds
            [questKeys.preQuestSingle] = {30252},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Merchant Greenfield"),0,{{"monster",58718}}}},
        },
        [30565] = { -- An Unexpected Advantage
            [questKeys.preQuestSingle] = {30000},
        },
        [30568] = { -- Helping the Cause
            [questKeys.preQuestSingle] = {30000},
            [questKeys.objectives] = {{{59572},{59562},{59609,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),2,{{"monster",59563}}}},
        },
        [30569] = { -- Trouble on the Farmstead
            [questKeys.preQuestSingle] = {30514},
        },
        [30570] = { -- Trouble on the Farmstead
            [questKeys.preQuestSingle] = {30515},
        },
        [30571] = { -- Farmhand Freedom
            [questKeys.preQuestSingle] = {30569,30570},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Slay the overseers"),0,{{"monster",59580}}}},
            [questKeys.objectives] = {{{59577,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30575] = { -- Round 'Em Up
            [questKeys.preQuestSingle] = {30514},
            [questKeys.objectives] = {{{59611,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Round up a yak"),0,{{"monster",59610}}}},
        },
        [30581] = { -- ...and the Pot, Too!
            [questKeys.preQuestSingle] = {30569,30570},
        },
        [30583] = { -- Blue Dwarf Needs Food Badly
            [questKeys.preQuestSingle] = {30514},
        },
        [30584] = { -- Shocking!
            [questKeys.extraObjectives] = {{{[zoneIDs.KRASARANG_WILDS] = {{64.51,28.12}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Dojani Eel")}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30585] = { -- What Lurks Below
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_NODE_FISH,l10n("Fish in the Mysterious Whirlpool"),0,{{"object",211112}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30586] = { -- Jagged Abalone
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30588] = { -- Fishing for a Bruising
            [questKeys.questFlags] = questFlags.DAILY,
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
        [30593] = { -- Deanimate the Reanimated
            [questKeys.preQuestSingle] = {30514},
        },
        [30594] = { -- Deanimate the Reanimated
            [questKeys.preQuestSingle] = {30515},
        },
        [30595] = { -- Profiting off of the Past
            [questKeys.preQuestSingle] = {30515},
        },
        [30598] = { -- Who Knew Fish Liked Eggs?
            [questKeys.requiredSourceItems] = {80303},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_NODE_FISH,l10n("Use the crane egg and fish in the yolk"),0,{{"object",211169}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30599] = { -- A Monkey Idol
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30602,30603},
            [questKeys.objectives] = {nil,{{210931},{211275},{211276}}},
            [questKeys.requiredSourceItems] = {80428,80429,80430},
        },
        [30600] = { -- No Pack Left Behind
            [questKeys.preQuestSingle] = {30603},
        },
        [30601] = { -- Instant Courage
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60382,59818},59818,nil,Questie.ICON_TYPE_INTERACT}}}
        },
        [30602] = { -- The Rabbitsfoot
            [questKeys.objectives] = {{{59806,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30603] = { -- The Broketooth Ravage
            [questKeys.preQuestSingle] = {30592},
        },
        [30604] = { -- Breaking Brokentooth
            [questKeys.preQuestSingle] = {30603},
        },
        [30605] = { -- Bros Before Hozen
            [questKeys.name] = "Lucky Yakshoe",
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30599,30600},
            [questKeys.objectives] = {{{60008,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30606] = { -- Thumping Knucklethump
            [questKeys.preQuestSingle] = {30605},
        },
        [30607] = { -- Hozen Love Their Keys
            [questKeys.objectives] = {{{59421,nil,Questie.ICON_TYPE_INTERACT}},nil,{{80535}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Unlock the Ball and Chain"),0,{{"object",211365}}}},
        },
        [30608] = { -- The Snackrifice
            [questKeys.preQuestSingle] = {30605},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60027,60012},60012,nil,Questie.ICON_TYPE_INTERACT}}}
        },
        [30610] = { -- Grummle! Grummle! Grummle!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30606,30607,30608},
            [questKeys.objectives] = {nil,{{211686,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30611] = { -- Unleash The Yeti!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30606,30607,30608},
        },
        [30612] = { -- Unleash The Yeti!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30610,30611},
        },
        [30613] = { -- Armored Carp
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30617] = { -- Roadside Assistance
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30616,30616,30808},
        },
        [30618] = { -- Resupplying One Keg
            [questKeys.preQuestSingle] = {30999},
        },
        [30619] = { -- Mogu?! Oh No-gu!
            [questKeys.preQuestSingle] = {30514},
        },
        [30620] = { -- Mogu?! Oh No-gu!
            [questKeys.preQuestSingle] = {30515},
        },
        [30621] = { -- They Stole My Luck
            [questKeys.preQuestSingle] = {30999},
        },
        [30622] = { -- The Swarm Begins
            [questKeys.preQuestSingle] = {30241,30360,30376}, -- any of the (mandatory) breadcrumbs that trigger the mantid invasion phase in western four winds
        },
        [30623] = { -- The Mantidote
            [questKeys.preQuestSingle] = {30241,30360,30376}, -- any of the (mandatory) breadcrumbs that trigger the mantid invasion phase in western four winds
            [questKeys.objectives] = {{{59874}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use Ken-Ken's Mask on Ik'thik Wing Commander"),0,{{"monster",56723}}}},
        },
        [30624] = { -- It Does You No Good Inside The Keg
            [questKeys.preQuestSingle] = {30360,30376}, -- any of the (mandatory) breadcrumbs that trigger the mantid invasion phase in western four winds
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59844,59845},59844,nil,Questie.ICON_TYPE_EVENT},{{59846,59847,59848},59846,nil,Questie.ICON_TYPE_EVENT},{{59829,59830,59831},59829,nil,Questie.ICON_TYPE_EVENT},{{59849,59850},59849,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30625] = { -- Students No More
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30622,30623,30624},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Follow the students and help them"),0,{{"monster",59839}}}},
        },
        [30627] = { -- The Savior of Stoneplow
            [questKeys.preQuestSingle] = {30626},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Talk to Miss Fanny"),0,{{"monster",59857}}}},
        },
        [30631] = { -- The Shrine of Seven Stars
            [questKeys.startedBy] = {{58468}},
            [questKeys.preQuestSingle] = {31512},
            [questKeys.objectives] = {{{59908,nil,Questie.ICON_TYPE_TALK},{59961,nil,Questie.ICON_TYPE_TALK},{64149,nil,Questie.ICON_TYPE_TALK},{64029,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30632] = { -- The Ruins of Guo-Lai
            [questKeys.startedBy] = {{58408}},
            [questKeys.preQuestSingle] = {30631,30649,31384,31385},
        },
        [30633] = { -- Out with the Scouts
            [questKeys.startedBy] = {{58465}},
        },
        [30634] = { -- Barring Entry
            [questKeys.startedBy] = {{58471}},
            [questKeys.preQuestSingle] = {30632},
            [questKeys.objectives] = {{{65252,nil,Questie.ICON_TYPE_TALK},{60011,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30635] = { -- Killing the Quilen
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30633,30634},
        },
        [30636] = { -- Stones of Power
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestGroup] = {30633,30634},
        },
        [30637] = { -- The Guo-Lai Halls
            [questKeys.startedBy] = {{110010}},
            [questKeys.preQuestGroup] = {30633,30634},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Attack Zhao-Jin the Bloodletter"),0,{{"monster",59921}}}},
        },
        [30638] = { -- Leaving an Opening
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestGroup] = {30635,30636,30637},
        },
        [30639] = { -- The Secrets of Guo-Lai
            [questKeys.startedBy] = {{58408}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {{{64647,nil,Questie.ICON_TYPE_TALK},{64663,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [30648] = { -- Moving On
            [questKeys.finishedBy] = {{110007}},
            [questKeys.objectives] = {{{59899,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {30504,31319}, -- became available after 30504/31319 only
        },
        [30649] = { -- The Shrine of Two Moons
            [questKeys.startedBy] = {{58468}},
            [questKeys.finishedBy] = {{58468}},
            [questKeys.objectives] = {{{59908,nil,Questie.ICON_TYPE_TALK},{59959,nil,Questie.ICON_TYPE_TALK},{62996,nil,Questie.ICON_TYPE_TALK},{63996,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31511},
        },
        [30650] = { -- Pandaren Prisoners [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31252,30593,30619}, -- might also need 30575 30583
            [questKeys.objectives] = {{{60038,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30651] = { -- Barrels of Fun [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31252,30593,30619}, -- might also need 30575 30583
            [questKeys.requiredSourceItems] = {80528},
            [questKeys.objectives] = {{{60096,nil,Questie.ICON_TYPE_INTERACT},{60098,nil,Questie.ICON_TYPE_INTERACT},{60099,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30652] = { -- In Tents Channeling [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31252,30593,30619}, -- might also need 30575 30583
        },
        [30653] = { -- It Does You No Good Inside The Keg
            [questKeys.preQuestSingle] = {30241,30376}, -- any of the (mandatory) breadcrumbs that trigger the mantid invasion phase in western four winds
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59844,59845},59844,nil,Questie.ICON_TYPE_EVENT},{{59846,59847,59848},59846,nil,Questie.ICON_TYPE_EVENT},{{59829,59830,59831},59829,nil,Questie.ICON_TYPE_EVENT},{{59851,59853},59851,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30655] = { -- Pandaren Prisoners [Horde]
            --[questKeys.preQuestGroup] = {31253,30594,30620}, -- might also need 30595 31251 31256
            [questKeys.objectives] = {{{60038,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30656] = { -- Barrels of Fun [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31253,30594,30620}, -- might also need 30595 31251 31256
            [questKeys.requiredSourceItems] = {80528},
            [questKeys.objectives] = {{{60096,nil,Questie.ICON_TYPE_INTERACT},{60098,nil,Questie.ICON_TYPE_INTERACT},{60099,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30657] = { -- In Tents Channeling [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31253,30594,30620}, -- might also need 30595 31251 31256
        },
        [30658] = { -- Huff & Puff
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30660] = { -- The Ordo Warbringer
            [questKeys.exclusiveTo] = {30662},
        },
        [30661] = { -- The Ordo Warbringer
            [questKeys.exclusiveTo] = {30663},
        },
        [30662] = { -- The Ordo Warbringer
            [questKeys.exclusiveTo] = {30660},
        },
        [30663] = { -- The Ordo Warbringer
            [questKeys.exclusiveTo] = {30661},
        },
        [30665] = { -- The Defense of Shado-Pan Fallback
            [questKeys.preQuestGroup] = {30459,30460},
            [questKeys.breadcrumbs] = {31453,31455},
        },
        [30670] = { -- Turnabout
            [questKeys.preQuestSingle] = {30457},
        },
        [30672] = { -- Balance
            [questKeys.preQuestSingle] = {30671},
        },
        [30674] = { -- Balance Without Violence
            [questKeys.preQuestSingle] = {30671},
            [questKeys.objectives] = {{{60367,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30678] = { -- Like Bombing Fish In A Barrel
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Use the raft"),0,{{"object",211596}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30682] = { -- Holed Up
            [questKeys.objectives] = {{{60187,nil,Questie.ICON_TYPE_TALK},{60189,nil,Questie.ICON_TYPE_TALK},{60190,nil,Questie.ICON_TYPE_TALK},{60178,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30683] = { -- One Traveler's Misfortune
            [questKeys.objectives] = {nil,{{212903}},nil,nil,{{{60769},60769}}},
        },
        [30684] = { -- Seeker's Folly
            [questKeys.preQuestSingle] = {30683},
        },
        [30690] = { -- Unmasking the Yaungol
            [questKeys.objectives] = {{{61303,nil,Questie.ICON_TYPE_INTERACT},{61333}}},
        },
        [30691] = { -- Misery
            [questKeys.preQuestSingle] = {30669},
            [questKeys.extraObjectives] = {{{[zoneIDs.KRASARANG_WILDS] = {{46,79.23}}},Questie.ICON_TYPE_EVENT,l10n("Enter the underwater cave")}},
        },
        [30692] = { -- The Burlap Trail: To Kota Basecamp
            [questKeys.preQuestSingle] = {30612},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Escort grummies to Kota Basecamp", {[zoneIDs.KUN_LAI_SUMMIT] = {{43.74,68.93}}}},
        },
        [30694] = { -- Tread Lightly
            [questKeys.preQuestSingle] = {30269},
            [questKeys.objectives] = {nil,{{223819}}},
        },
        [30695] = { -- Ahead on the Way
            [questKeys.preQuestGroup] = {30268,30270,30694}, -- might not be all, my turn in order was 30268, 30694, 30270
        },
        [30698] = { -- Scavenger Hunt
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30700] = { -- Snapclaw
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30701] = { -- Viseclaw Soup
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30715] = { -- A Line Unbroken
            [questKeys.objectives] = {{{61808,nil,Questie.ICON_TYPE_INTERACT},{61806,nil,Questie.ICON_TYPE_INTERACT},{61810,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30716] = { -- Chasing Hope
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.objectives] = {{{60487,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30717] = { -- Gifts of the Great Crane
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30718] = { -- Students of Chi-Ji
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30724] = { -- To the Wall!
            [questKeys.preQuestSingle] = {30715}, -- might also need 30723
            [questKeys.objectives] = {{{61512,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30725] = { -- Ellia Ravenmane
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30726] = { -- Minh Do-Tan
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30727] = { -- Ellia Ravenmane: Rematch
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30728] = { -- Fat Long-Fat
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30729] = { -- Julia Bates
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30730] = { -- Dextrous Izissha
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30731] = { -- Kuo-Na Quillpaw
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30732] = { -- Ellia Ravenmane: Revenge
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30733] = { -- Tukka-Tuk
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30734] = { -- Huck Wheelbarrow
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30735] = { -- Mindel Sunspeaker
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30736] = { -- Yan Quillpaw
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30737] = { -- Fat Long-Fat: Rematch
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30738] = { -- Thelonius
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30739] = { -- Ellia Ravenmane: Redemption
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30740] = { -- Champion of Chi-Ji
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30742] = { -- Shut it Down
            [questKeys.exclusiveTo] = {30823},
        },
        [30743] = { -- Gourmet Kafa
            [questKeys.objectives] = {nil,{{211456}}},
            [questKeys.exclusiveTo] = {30824},
        },
        [30744] = { -- Kota Blend
            [questKeys.objectives] = {nil,nil,{{81054}}},
            [questKeys.exclusiveTo] = {30825},
        },
        [30745] = { -- Trouble Brewing
            [questKeys.exclusiveTo] = {30826},
        },
        [30747] = { -- The Burlap Grind
            [questKeys.preQuestSingle] = {30746},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Feed the Flask of Kafa to Kota Kon"),0,{{"monster",60587}}}},
        },
        [30751] = { -- A Terrible Sacrifice
            [questKeys.preQuestSingle] = {30724},
        },
        [30752] = { -- Unbelievable!
            [questKeys.preQuestSingle] = {30993},
            [questKeys.objectives] = {{{62220,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30753] = { -- Jumping the Shark
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30754] = { -- Bright Bait
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30757] = { -- Lord of the Shado-Pan
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31030,31031},
        },
        [30763] = { -- Piranha!
            [questKeys.extraObjectives] = {{{[zoneIDs.KRASARANG_WILDS] = {{36.56,41.41}}},Questie.ICON_TYPE_NODE_FISH,l10n("Fish for Wolf Piranha")}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30767] = { -- Risking It All
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{60727,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [30768] = { -- My Husband...
            [questKeys.preQuestSingle] = {30992},
            [questKeys.exclusiveTo] = {31386,31388,31695},
        },
        [30769] = { -- First Assault
            [questKeys.preQuestSingle] = {30814},
        },
        [30770] = { -- Running Rampant
            [questKeys.preQuestSingle] = {30814},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60739,60669},60669,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30771] = { -- Perfect Pitch
            [questKeys.preQuestSingle] = {30814},
        },
        [30772] = { -- Seeing Red
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30069,30770,30771},
        },
        [30773] = { -- Pitching In
            [questKeys.objectives] = {{{60705,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30069,30770,30771},
        },
        [30774] = { -- Ranger Rescue
            [questKeys.preQuestGroup] = {30069,30770,30771},
            [questKeys.requiredSourceItems] = {81178},
            [questKeys.objectives] = {{{60730,nil,Questie.ICON_TYPE_EVENT},{60899,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211511}}}},
        },
        [30775] = { -- The Exile
            [questKeys.preQuestGroup] = {30069,30770,30771},
        },
        [30776] = { -- Jung Duk
            [questKeys.preQuestGroup] = {30772,30773,30774},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Plant the banner"),0,{{"object",211524}}}},
        },
        [30777] = { -- In Search of Suna
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",61205}}}},
        },
        [30778] = { -- Dust to Dust
            [questKeys.preQuestSingle] = {30777},
            [questKeys.objectives] = {{{60925,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30779] = { -- Slaying the Scavengers
            [questKeys.preQuestSingle] = {30777},
        },
        [30780] = { -- Totemic Research
            [questKeys.preQuestSingle] = {30777},
        },
        [30781] = { -- Last Toll of the Yaungol
            [questKeys.objectives] = {{{60948,nil,Questie.ICON_TYPE_EVENT},{60949,nil,Questie.ICON_TYPE_EVENT},{60950,nil,Questie.ICON_TYPE_EVENT},{61291,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {30777},
        },
        [30782] = { -- Spiteful Spirits
            [questKeys.preQuestSingle] = {30827},
        },
        [30783] = { -- Hatred Becomes Us
            [questKeys.preQuestSingle] = {30827},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Place a totem next to the ranger"),0,{{"monster",61050}}}},
        },
        [30784] = { -- The Point of No Return
            [questKeys.preQuestGroup] = {30782,30783},
        },
        [30785] = { -- Gao-Ran Battlefront
            [questKeys.breadcrumbForQuestId] = 30884,
        },
        [30786] = { -- A Spear Through My Side, A Chain Through My Soul
            [questKeys.preQuestSingle] = {31894},
        },
        [30787] = { -- The Torches
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Mist-Shamans after they placed their torch"),0,{{"monster",60697}}}},
        },
        [30788] = { -- Golgoss
            [questKeys.objectives] = {{{60734,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {30787},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Plant the torch"),0,{{"object",211513}}}},
        },
        [30789] = { -- Arconiss
            [questKeys.objectives] = {{{60764,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {30787},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Plant the torch"),0,{{"object",211515}}}},
        },
        [30790] = { -- Golgoss Hungers
            [questKeys.preQuestSingle] = {30815},
        },
        [30791] = { -- Arconiss Thirsts
            [questKeys.preQuestSingle] = {30815},
        },
        [30792] = { -- Orbiss Fades
            [questKeys.objectives] = {{{60862,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {30815},
        },
        [30793] = { -- Mists' Opportunity
            [questKeys.preQuestGroup] = {30790,30791,30792},
        },
        [30794] = { -- Emergency Care
            [questKeys.breadcrumbs] = {30816},
            [questKeys.objectives] = {{{60694,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {81177},
        },
        [30795] = { -- Staying Connected
            [questKeys.objectives] = {{{61166,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mishi"),0,{{"monster",60796}}}},
        },
        [30797] = { -- It Was Almost Alive
            [questKeys.preQuestSingle] = {30684},
            [questKeys.objectives] = {nil,{{211783}}},
        },
        [30800] = { -- Stealing Their Thunder King
            [questKeys.objectives] = {nil,{{214572}},{{82764}}},
        },
        [30801] = { -- Lessons from History
            [questKeys.objectives] = {nil,{{214572}}},
        },
        [30806] = { -- The Scent of Life
            [questKeys.preQuestSingle] = {30794},
        },
        [30807] = { -- By the Falls, For the Fallen
            [questKeys.preQuestSingle] = {30794},
        },
        [30808] = { -- A Grummle's Luck
            [questKeys.preQuestSingle] = {},
        },
        [30814] = { -- A Foot in the Door
            [questKeys.preQuestSingle] = {},
        },
        [30815] = { -- The Death of Me
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30788,30789},
            [questKeys.objectives] = {{{60857,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30816] = { -- Checking In
            [questKeys.preQuestSingle] = {30935},
            [questKeys.breadcrumbForQuestId] = 30794,
        },
        [30819] = { -- Preparing the Remains
            [questKeys.preQuestGroup] = {30805,30806,30807},
        },
        [30820] = { -- A Funeral
            [questKeys.preQuestSingle] = {30819},
            [questKeys.objectives] = {nil,{{211545}}},
        },
        [30821] = { -- The Burlap Grind (Daily)
            [questKeys.preQuestSingle] = {30747},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Feed the Flask of Kafa to Kota Kon"),0,{{"monster",60587}}}},
        },
        [30823] = { -- Shut it Down
            [questKeys.exclusiveTo] = {30742},
        },
        [30824] = { -- Gourmet Kafa
            [questKeys.objectives] = {nil,{{211456}}},
            [questKeys.exclusiveTo] = {30743},
        },
        [30825] = { -- Kota Blend
            [questKeys.objectives] = {nil,nil,{{81054}}},
            [questKeys.exclusiveTo] = {30744},
        },
        [30826] = { -- Trouble Brewing
            [questKeys.exclusiveTo] = {30745},
        },
        [30827] = { -- What Lies Beneath
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30778,30779,30780,30781},
            [questKeys.objectives] = {{{60864,nil,Questie.ICON_TYPE_TALK},{60933,nil,Questie.ICON_TYPE_INTERACT},{60990,nil,Questie.ICON_TYPE_INTERACT},{60991,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.triggerEnd] = {"Ritual completed", {[zoneIDs.TOWNLONG_STEPPES] = {{82.59,73.24}}}},
        },
        [30828] = { -- Cleansing the Mere
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Cleanse the pool"),0,{{"monster",61500}}}},
        },
        [30829] = { -- The Tongue of Ba-Shon
            [questKeys.preQuestSingle] = {30684},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Cho"),0,{{"monster",61315}}}},
        },
        [30834] = { -- Father and Child Reunion
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {30467},
            [questKeys.triggerEnd] = {"Reunite Wu-Peng and Merchant Shi", {[zoneIDs.KUN_LAI_SUMMIT] = {{74.92,88.72}}}},
        },
        [30879] = { -- Round 1: Brewmaster Chani
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Brewmaster Chani"),0,{{"monster",60996}}}},
            [questKeys.exclusiveTo] = {30880},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30880] = { -- Round 1: The Streetfighter
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Lun-Chi"),0,{{"monster",60994}}}},
            [questKeys.exclusiveTo] = {30879},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30881] = { -- Round 2: Clever Ashyo & Ken-Ken
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to ??"),0,{{"monster",??}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30882] = { -- Round 2: Kang Bramblestaff
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kang Bramblestaff"),0,{{"monster",60978}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30883] = { -- Round 3: The Wrestler
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to The Wrestler"),0,{{"monster",60997}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30884] = { -- Behind the Battlefront
            [questKeys.breadcrumbs] = {30785},
        },
        [30885] = { -- Round 3: Master Boom Boom
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Master Boom Boom"),0,{{"monster",61013}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30888] = { -- Breach in the Defenses
            [questKeys.preQuestSingle] = {30887},
        },
        [30889] = { -- Trap Setting
            [questKeys.objectives] = {{{61426,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30887},
        },
        [30890] = { -- The Restless Watch
            [questKeys.objectives] = {{{61378,nil,Questie.ICON_TYPE_TALK},{61395,nil,Questie.ICON_TYPE_TALK},{61396,nil,Questie.ICON_TYPE_TALK},{61397,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {30887},
        },
        [30892] = { -- Back on Their Feet
            [questKeys.preQuestGroup] = {30891,30960},
            [questKeys.objectives] = {{{61692,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30894] = { -- Rummaging Through the Remains
            [questKeys.preQuestGroup] = {30891,30960},
        },
        [30895] = { -- Improvised Ammunition
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30892,30893,30894},
        },
        [30896] = { -- Thieves and Troublemakers
            [questKeys.preQuestGroup] = {30892,30893,30894},
        },
        [30897] = { -- In the Wrong Hands
            [questKeys.preQuestGroup] = {30892,30893,30894},
        },
        [30898] = { -- Cutting the Swarm
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30895,30896,30897},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Man a Dragon Launcher"),0,{{"monster",61746},{"monster",62024}}}},
        },
        [30902] = { -- Round 4: Master Windfur
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Master Windfur"),0,{{"monster",61012}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30907] = { -- Round 4: The P.U.G
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to ??"),0,{{"monster",??}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30921] = { -- The Motives of the Mantid
            [questKeys.objectives] = {nil,nil,nil,nil,{ -- all clues are found on the same NPCs
                {{61376,61377},61376},
                {{61376,61377},61376},
                {{61376,61377},61376},
                {{61376,61377},61376},
            }},
        },
        [30923] = { -- Set the Mantid Back
            [questKeys.objectives] = {nil,{{211677,nil,Questie.ICON_TYPE_EVENT},{211683,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30924] = { -- The Wisdom of Niuzao
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30921,30923},
        },
        [30925] = { -- Niuzao's Price
            [questKeys.objectives] = {nil,nil,nil,nil,{ -- all clues are found on the same NPCs
                {{61516,61517,61518},61516},
                {{61516,61517,61518},61516},
                {{61516,61517,61518},61516},
                {{61516,61517,61518},61516},
            }},
        },
        [30926] = { -- The Terrible Truth
            [questKeys.preQuestSingle] = {30925},
        },
        [30927] = { -- Give Them Peace
            [questKeys.preQuestSingle] = {30925},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{62276,62277,62281,62282},62276,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30928] = { -- A Trail of Fear
            [questKeys.preQuestSingle] = {30925},
        },
        [30929] = { -- Bad Yak
            [questKeys.objectives] = {{{61163,nil,Questie.ICON_TYPE_INTERACT},{61163,nil,Questie.ICON_TYPE_INTERACT},{61163,nil,Questie.ICON_TYPE_INTERACT},{61163,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30921}, -- not 100% on this but it's definitely missing at least one prequest and showed up after I did a few including 30921
        },
        [30930] = { -- Pick a Yak
            [questKeys.objectives] = {{{61635,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30929},
        },
        [30932] = { -- Father's Footsteps
            [questKeys.preQuestSingle] = {30931},
            [questKeys.objectives] = {{{61685,nil,Questie.ICON_TYPE_INTERACT},{61683,nil,Questie.ICON_TYPE_TALK}},{{211836},{211837}}},
        },
        [30935] = { -- Fisherman's Tale
            [questKeys.objectives] = {{{61382,nil,Questie.ICON_TYPE_TALK},{61380,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30942] = { -- Make A Fighter Out of Me
            [questKeys.preQuestSingle] = {30935},
            [questKeys.objectives] = {{{66165},{64202},{66707}}},
        },
        [30943] = { -- Handle With Care
            [questKeys.preQuestSingle] = {30935},
        },
        [30944] = { -- It Takes A Village
            [questKeys.preQuestSingle] = {30935},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61417,61554,61381},61381,nil,Questie.ICON_TYPE_TALK}}}
        },
        [30945] = { -- What's Yours Is Mine
            [questKeys.preQuestSingle] = {30935},
        },
        [30946] = { -- Revelations
            [questKeys.objectives] = {{{62629,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30952] = { -- The Unending Siege
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30953] = { -- Fallen Sentinels
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.objectives] = {{{61570,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30954] = { -- A Blade is a Blade
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30955] = { -- Paying Tribute
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.objectives] = {nil,{{212131}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30956] = { -- The Siege Swells
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30957] = { -- The Overwhelming Swarm
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30958] = { -- In Battle's Shadow
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30959] = { -- The Big Guns
            [questKeys.preQuestSingle] = {31511,31512},
        },
        [30960] = { -- Returning from the Pass
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30888,30890},
        },
        [30967] = { -- Free the Dissenters
            [questKeys.objectives] = {{{61566,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30968] = { -- The Sha of Hatred
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30981,31063,31064},
        },
        [30971] = { -- Taking Stock
            [questKeys.preQuestSingle] = {30901},
        },
        [30972] = { -- Joining the Fight
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30970,30971},
        },
        [30973] = { -- Up In Flames
            [questKeys.preQuestSingle] = {30972},
        },
        [30975] = { -- The Taking of Dusklight Bridge
            [questKeys.preQuestSingle] = {30973},
        },
        [30977] = { -- Grounded Welcome
            [questKeys.preQuestSingle] = {30976},
        },
        [30978] = { -- Hostile Skies
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in the cannon"),0,{{"monster",62747}}}},
        },
        [30981] = { -- Taoshi and Korvexxis
            [questKeys.preQuestSingle] = {31065},
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
        [30991] = { -- Do a Barrel Roll!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in"),0,{{"monster",60553}}}},
        },
        [30992] = { -- Finish This!
            [questKeys.preQuestSingle] = {30991},
        },
        [30993] = { -- Where are My Reinforcements?
            [questKeys.preQuestSingle] = {30992},
        },
        [30994] = { -- Lao-Chin's Gambit
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30750,30751},
        },
        [30995] = { -- No Man Left Behind
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61788,61780,61790},61788,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211883}}}},
        },
        [30999] = { -- Path Less Traveled
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31459,31460},
        },
        [31000] = { -- Dread Space
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31390,31391,31656,31847,31886,31895},
        },
        [31001] = { -- Falling Down
            [questKeys.objectives] = {{{62166,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31000,31390,31391,31656,31847,31886,31895},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use the rope"),0,{{"object",212229}}}},
        },
        [31002] = { -- Nope
            [questKeys.objectives] = {{{62077,nil,Questie.ICON_TYPE_INTERACT},{61981}}},
        },
        [31003] = { -- Psycho Mantid
            [questKeys.preQuestGroup] = {31001,31002},
        },
        [31004] = { -- Preserved in Amber
            [questKeys.objectives] = {nil,{{212868}}},
        },
        [31005] = { -- Wakening Sickness
            [questKeys.preQuestSingle] = {31004},
        },
        [31006] = { -- The Klaxxi Council
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31005,31676},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62202}}}},
        },
        [31007] = { -- The Dread Clutches
            [questKeys.preQuestSingle] = {31006},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62202}}}},
        },
        [31008] = { -- Amber Arms
            [questKeys.preQuestSingle] = {31006},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62202}}}},
        },
        [31009] = { -- Dead Zone
            [questKeys.finishedBy] = {{110008}},
            [questKeys.objectives] = {nil,{{212524}}},
            [questKeys.preQuestSingle] = {31006},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62202}}}},
        },
        [31010] = { -- In Her Clutch
            [questKeys.objectives] = {nil,{{214674}}},
        },
        [31011] = { -- Enemies At Our Door
            [questKeys.preQuestGroup] = {30942,30943,30944,30945},
            [questKeys.preQuestSingle] = {},
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
        [31015] = { -- Your Private Collection
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31016,31367,31368},
        },
        [31016] = { -- The Lorewalkers
            [questKeys.breadcrumbForQuestId] = 31015,
            [questKeys.exclusiveTo] = {31367,31368},
        },
        [31018] = { -- Beneath the Heart of Fear
            [questKeys.objectives] = {{{62073},{62074},{62075},{62076}},{{212038}}},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
            [questKeys.extraObjectives] = {{{[zoneIDs.DREAD_WASTES] = {{28.22,42.45}}},Questie.ICON_TYPE_EVENT,l10n("Enter the burrow")}},
        },
        [31019] = { -- Amber Is Life
            [questKeys.preQuestSingle] = {31066},
        },
        [31020] = { -- Feeding the Beast
            [questKeys.preQuestSingle] = {31019},
        },
        [31021] = { -- Living Amber
            [questKeys.preQuestSingle] = {31019},
            [questKeys.requiredSourceItems] = {82864},
            [questKeys.objectives] = {{{62232,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31022] = { -- Kypari Zar
            [questKeys.triggerEnd] = {"Korven the Prime defeneded", {[zoneIDs.DREAD_WASTES] = {{59.93,59.43}}}},
            [questKeys.objectives] = {nil,{{212933}}},
            [questKeys.preQuestGroup] = {31020,31021},
        },
        [31024] = { -- Kunchong Treats
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.exclusiveTo] = {31238,31494,31506}, -- exclusivity for honored The Klaxxi
        },
        [31030] = { -- Into the Monastery
            [questKeys.exclusiveTo] = {31031},
            [questKeys.breadcrumbForQuestId] = 30757,
        },
        [31031] = { -- Into the Monastery
            [questKeys.preQuestSingle] = {30752},
            [questKeys.exclusiveTo] = {31030},
            [questKeys.breadcrumbForQuestId] = 30757,
        },
        [31032] = { -- Choking the Skies
            [questKeys.objectives] = {{{62128,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30976},
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
        [31038] = { -- The Challenger's Ring: Snow Blossom
            [questKeys.objectives] = {{{62380,nil,Questie.ICON_TYPE_TALK},{62781}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,9000}
        },
        [31039] = { -- The Mogu Menace
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31040] = { -- Spiteful Sprites
            [questKeys.exclusiveTo] = {31042,31048},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31041] = { -- Egg Rescue!
            [questKeys.exclusiveTo] = {31044,31047},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31042] = { -- Onyx Hearts
            [questKeys.exclusiveTo] = {31040,31048},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31043] = { -- Dark Arts
            [questKeys.exclusiveTo] = {31045,31046},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31044] = { -- Bronze Claws
            [questKeys.exclusiveTo] = {31041,31047},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31045] = { -- Illusions Of The Past
            [questKeys.exclusiveTo] = {31043,31046},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31046] = { -- Little Hatchlings
            [questKeys.objectives] = {{{62567,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",213571}}}}, -- there are way more object ids, but 1 should be enough
            [questKeys.exclusiveTo] = {31043,31045},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31047] = { -- Born Free
            [questKeys.objectives] = {{{62539,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.exclusiveTo] = {31041,31044},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31048] = { -- Grave Consequences
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Release Ancestors"),0,{{"object",212324}}}},
            [questKeys.exclusiveTo] = {31040,31042},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31049] = { -- In Sprite Of Everything
            [questKeys.exclusiveTo] = {31061,31062},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31061] = { -- Riding the Storm
            [questKeys.objectives] = {nil,nil,nil,nil,{{{62311,62584,62585,62586},62311}}},
            [questKeys.exclusiveTo] = {31049,31062},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31062] = { -- When The Dead Speak
            [questKeys.exclusiveTo] = {31049,31061},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31063] = { -- Lao-Chin and Serevex
            [questKeys.preQuestSingle] = {31065},
        },
        [31064] = { -- Nurong and Rothek
            [questKeys.preQuestSingle] = {31065},
        },
        [31066] = { -- A Cry From Darkness
            [questKeys.preQuestGroup] = {31007,31010,31660},
        },
        [31067] = { -- The Heavens Hum With War
            [questKeys.preQuestSingle] = {31066},
            [questKeys.breadcrumbs] = {31730},
            [questKeys.extraObjectives] = {{{[zoneIDs.DREAD_WASTES] = {{53.66,15.87}}},Questie.ICON_TYPE_EVENT,l10n("Enter the burrow")}},
        },
        [31068] = { -- Sacred Recipe
            [questKeys.preQuestSingle] = {31066},
        },
        [31069] = { -- Bound With Shade
            [questKeys.objectives] = {nil,nil,nil,nil,{{{62751,65996},62751}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31067,31068},
        },
        [31070] = { -- Daggers of the Great Ones
            [questKeys.preQuestSingle] = {31068},
        },
        [31071] = { -- I Bring Us Great Shame
            [questKeys.preQuestSingle] = {31068},
        },
        [31072] = { -- Rending Daggers
            [questKeys.preQuestGroup] = {31067,31068},
        },
        [31073] = { -- Bound With Wood
            [questKeys.preQuestGroup] = {31069,31070},
        },
        [31074] = { -- Wood and Shade
            [questKeys.objectives] = {nil,{{212643,nil,Questie.ICON_TYPE_EVENT},{212642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31072},
        },
        [31075] = { -- Sunset Kings
            [questKeys.preQuestGroup] = {31073,31074,31078},
        },
        [31076] = { -- Fate of the Stormstouts
            [questKeys.objectives] = {{{62666,nil,Questie.ICON_TYPE_TALK},{62667,nil,Questie.ICON_TYPE_TALK},{62845,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestGroup] = {31067,31068},
            [questKeys.exclusiveTo] = {29907,31129},
        },
        [31077] = { -- Evie Stormstout
            [questKeys.finishedBy] = {{67138}},
            [questKeys.objectives] = {{{67138,nil,Questie.ICON_TYPE_EVENT}},{{440002,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31129},
        },
        [31078] = { -- Han Stormstout
            [questKeys.objectives] = {{{62776,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.DREAD_WASTES] = {{47.29,16.82}}},Questie.ICON_TYPE_EVENT,l10n("Enter the burrow")}},
        },
        [31079] = { -- The Horror Comes A-Rising
            [questKeys.preQuestSingle] = {31075},
        },
        [31080] = { -- Fiery Wings
            [questKeys.preQuestSingle] = {31075},
        },
        [31081] = { -- Incantations Fae and Primal
            [questKeys.preQuestSingle] = {31075},
        },
        [31082] = { -- Great Vessel of Salvation
            [questKeys.triggerEnd] = {"Bring Motherseeds back to the Motherseed Pit", {[zoneIDs.DREAD_WASTES] = {{36.86,17.44}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {31075},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Let the Chanter pick-up the Motherseeds"),0,{{"monster",62601}}}},
        },
        [31083] = { -- Promises of Gold
            [questKeys.startedBy] = {{62767}},
            [questKeys.preQuestSingle] = {31075},
        },
        [31084] = { -- Bind the Glamour
            [questKeys.triggerEnd] = {"Allow Chief Rikkitun to enchant the forked blade", {[zoneIDs.DREAD_WASTES] = {{39.42,23.15}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31079,31080,31081,31082},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chief Rikkitun"),0,{{"monster",62771}}}},
        },
        [31085] = { -- Fires and Fears of Old
            [questKeys.objectives] = {{{62773,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{63102,63103,63104},63102}}},
            [questKeys.preQuestSingle] = {31084},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Remove the boulders"),0,{{"object",440003}}}},
        },
        [31086] = { -- Blood of Ancients
            [questKeys.preQuestSingle] = {31084},
        },
        [31087] = { -- Extending Our Coverage
            [questKeys.objectives] = {{{65328,nil,Questie.ICON_TYPE_EVENT},{65478}},{{213250}}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31679},
        },
        [31088] = { -- Crime and Punishment
            [questKeys.preQuestSingle] = {31087},
            [questKeys.exclusiveTo] = {31680}
        },
        [31089] = { -- By the Sea, Nevermore
            [questKeys.objectives] = {nil,{{212294,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31088,31090},
            [questKeys.exclusiveTo] = {31682},
        },
        [31090] = { -- Better With Age
            [questKeys.preQuestSingle] = {31087},
            [questKeys.exclusiveTo] = {31681},
        },
        [31091] = { -- Reunited
            [questKeys.finishedBy] = {{64344}},
            [questKeys.objectives] = {nil,{{213444,nil,Questie.ICON_TYPE_EVENT}},nil,nil,{{{62542},62542,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31089,31682},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kaz'tik"),0,{{"monster",63876}}}},
        },
        [31092] = { -- Feed or Be Eaten
            [questKeys.preQuestSingle] = {31091},
            [questKeys.requiredSourceItems] = {86489},
            [questKeys.objectives] = {{{64485,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31105] = { -- The Mogu Menace
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31106] = { -- The Mogu Menace
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31107] = { -- Citizens of a New Empire
            [questKeys.preQuestGroup] = {31007,31010,31660},
        },
        [31108] = { -- Concentrated Fear
            [questKeys.preQuestSingle] = {31661},
        },
        [31109] = { -- Culling the Swarm
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31111,31231,31267}, -- exclusivity for honored The Klaxxi
        },
        [31111] = { -- Eradicating the Zan'thik
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31109,31231,31267}, -- exclusivity for honored The Klaxxi
        },
        [31113] = { -- Assault Fire Camp Gai-Cho
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31114] = { -- Assault Deadtalker's Plateau
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31116] = { -- Spirit Dust
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31117] = { -- Uruk!
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31118] = { -- The Deadtalker Cipher
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31119] = { -- The Enemy of My Enemy... Is Still My Enemy!
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31120] = { -- Cheng Bo!
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31121] = { -- Stay a While, and Listen
            [questKeys.objectives] = {nil,{{212900}}},
        },
        [31129] = { -- Fate of the Stormstouts
            [questKeys.objectives] = {{{62666,nil,Questie.ICON_TYPE_TALK},{62667,nil,Questie.ICON_TYPE_TALK},{62845,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31068},
            [questKeys.exclusiveTo] = {31076},
        },
        [31130] = { -- A Visit with Lorewalker Cho
            [questKeys.objectives] = {nil,{{211659},{211661},{213191}}},
            [questKeys.finishedBy] = {{56287,61218}},
        },
        [31131] = { -- Whitepetal Lake -- Pagoda to Lake Peace
            [questKeys.startedBy] = {{58408}},
            [questKeys.exclusiveTo] = {30281,30282,30283,30292,30293,31242,31243},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
        },
        [31132] = { -- A Mile in My Shoes
            [questKeys.finishedBy] = {{63217}},
        },
        [31133] = { -- Kor'thik Aggression
            [questKeys.preQuestSingle] = {31070},
        },
        [31134] = { -- If These Stones Could Speak
            [questKeys.objectives] = {nil,{{212926},{212925},{212924}}},
        },
        [31135] = { -- The Future of Gnomeregan
            [questKeys.startedBy] = {{42396}},
            [questKeys.preQuestSingle] = {27674},
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [31136] = { -- Behind Our Lines
            [questKeys.startedBy] = {{58470}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30482,31248,31249,31297},
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.objectives] = {{{246242}}},
            [questKeys.requiredMaxRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31137] = { -- Meet the High Tinker
            [questKeys.startedBy] = {{63238}},
            [questKeys.preQuestSingle] = {31135},
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [31138] = { -- The Arts of a Monk
            [questKeys.requiredLevel] = 2,
            [questKeys.preQuestSingle] = {31135},
            [questKeys.requiredRaces] = raceIDs.GNOME,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{100787}}},
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
            [questKeys.triggerEnd] = {"Lorewalker Cho escorted to Circle of Stone", {[zoneIDs.THE_JADE_FOREST] = {{29,32.4}}}},
            [questKeys.preQuestSingle] = {31134},
        },
        [31156] = { -- Calligraphed Parchment
            [questKeys.startedBy] = {{3143}},
            [questKeys.requiredRaces] = raceIDs.ORC,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {25126},
        },
        [31157] = { -- Tiger Palm
            [questKeys.requiredRaces] = raceIDs.ORC,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{100787}}},
        },
        [31158] = { -- The Basics: Hitting Things
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31160] = { -- A Rough Start
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31161] = { -- Proving Pit
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{39062,nil,Questie.ICON_TYPE_TALK},{38142}}},
        },
        [31162] = { -- The Arts of a Monk
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{100787}}},
        },
        [31163] = { -- More Than Expected
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31165] = { -- Calligraphed Note
            [questKeys.startedBy] = {{44927}},
            [questKeys.requiredClasses] = classIDs.MONK,
        },
        [31166] = { -- Tiger Palm
            [questKeys.preQuestSingle] = {31165},
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{100787}}},
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
        [31175] = { -- Skeer the Bloodseeker
            [questKeys.objectives] = {nil,{{212980}}},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,9000},
            [questKeys.extraObjectives] = {{{[zoneIDs.DREAD_WASTES] = {{25.72,54.31}}},Questie.ICON_TYPE_EVENT,l10n("Enter the underwater cave")}},
        },
        [31176] = { -- A Strange Appetite
            [questKeys.preQuestSingle] = {31175},
        },
        [31177] = { -- Fine Dining
            [questKeys.preQuestSingle] = {31175},
        },
        [31178] = { -- A Bloody Delight
            [questKeys.preQuestSingle] = {31175},
        },
        [31179] = { -- The Scent of Blood
            [questKeys.preQuestGroup] = {31176,31177,31178},
        },
        [31181] = { -- Fresh Pots
            [questKeys.objectives] = {nil,{{440001}}},
            [questKeys.preQuestSingle] = {31265},
            [questKeys.requiredSourceItems] = {85230},
        },
        [31182] = { -- You Otter Know
            [questKeys.objectives] = {{{63376,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31265},
        },
        [31183] = { -- Meet the Cap'n
            [questKeys.preQuestGroup] = {31181,31182},
        },
        [31184] = { -- Old Age and Treachery
            [questKeys.preQuestSingle] = {31183},
        },
        [31185] = { -- Walking Dog
            [questKeys.objectives] = {{{63879,nil,Questie.ICON_TYPE_EVENT},{63880,nil,Questie.ICON_TYPE_EVENT},{63881,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31183},
        },
        [31186] = { -- Dog Food
            [questKeys.finishedBy] = {{63955,63277}},
            [questKeys.objectives] = {{{63369}}},
            [questKeys.preQuestSingle] = {31183},
        },
        [31187] = { -- On the Crab
            [questKeys.objectives] = {nil,{{213508}}},
            [questKeys.preQuestSingle] = {31183},
        },
        [31188] = { -- Shark Week
            [questKeys.preQuestSingle] = {31183},
            [questKeys.requiredSourceItems] = {85998},
        },
        [31189] = { -- Reeltime Strategy
            [questKeys.objectives] = {{{64259,nil,Questie.ICON_TYPE_TALK},{64270}}},
            [questKeys.preQuestGroup] = {31184,31187,31188},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Reel in the fishing rod"),0,{{"object",213744},{"object",213746},{"object",213752},{"object",213753}}}},
        },
        [31190] = { -- The Mariner's Revenge
            [questKeys.preQuestSingle] = {31189},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Jump in"),0,{{"monster",64350}}}},
            [questKeys.objectives] = {{{63330},{63330},{63330},{63330}}},
        },
        [31194] = { -- Slitherscale Suppression
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31196] = { -- Sra'vess Wetwork
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31197] = { -- The Bigger They Come...
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31198] = { -- A Morale Victory
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31199] = { -- Destroy the Siege Weapons!
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31200] = { -- Fumigation
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31201] = { -- Friends, Not Food!
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31203] = { -- Target of Opportunity: Sra'thik Swarmlord
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31204] = { -- Target of Opportunity: Sra'thik Hivelord
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31207] = { -- The Arena of Annihilation
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{64280,64281},64280}}},
        },
        [31208] = { -- Venomous Intent
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000}, -- TODO: These actually have some sort of pre-quest
        },
        [31209] = { -- Dark Wings, Dark Things
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000}, -- TODO: These actually have some sort of pre-quest
        },
        [31210] = { -- A Shade of Dread
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000}, -- TODO: These actually have some sort of pre-quest
        },
        [31211] = { -- The Poisoned Mind
            [questKeys.preQuestSingle] = {31018},
        },
        [31216] = { -- Dark Skies
            [questKeys.preQuestSingle] = {31018},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31228] = { -- Prophet Khar'zul
            [questKeys.objectives] = {{{65855,nil,Questie.ICON_TYPE_TALK},{61541}},nil,nil,nil,{{{64631,64639,64643,64642},64642}}}
        },
        [31230] = { -- Welcome to Dawn's Blossom
            [questKeys.objectives] = {{{59160,nil,Questie.ICON_TYPE_TALK},{55809,nil,Questie.ICON_TYPE_TALK},{59173,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {29922,30015},
        },
        [31231] = { -- Dreadspinner Extermination
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31109,31111,31267}, -- exclusivity for honored The Klaxxi
        },
        [31232] = { -- An Ancient Empire
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31270,31496,31507}, -- exclusivity for honored The Klaxxi
        },
        [31233] = { -- Sap Tapping
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31269,31502,31508}, -- exclusivity for honored The Klaxxi
        },
        [31234] = { -- Putting An Eye Out
            [questKeys.preQuestSingle] = {31606},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31271,31503,31509}, -- exclusivity for honored The Klaxxi
        },
        [31235] = { -- Nope Nope Nope
            [questKeys.objectives] = {{{62077,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31268,31487,31505}, -- exclusivity for honored The Klaxxi
        },
        [31237] = { -- Debugging the Terrace
            [questKeys.preQuestSingle] = {31439},
        },
        [31238] = { -- Brain Food
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.exclusiveTo] = {31024,31494,31506}, -- exclusivity for honored The Klaxxi
        },
        [31239] = { -- What's in a Name Name?
            [questKeys.preQuestSingle] = {29941},
        },
        [31240] = { -- Guo-Lai Infestation -- Lake Peace to Ruins Peace
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.exclusiveTo] = {31244,31245,31246,31247,31248,31294,31295,31296},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284}, -- Whitepetal Lake Peace
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31241] = { -- Wicked Wikkets
            [questKeys.preQuestSingle] = {29879},
        },
        [31242] = { -- Mistfall Village -- Pagoda to Mistfall Peace
            [questKeys.startedBy] = {{58408}},
            [questKeys.exclusiveTo] = {30281,30282,30283,30292,30293,31131,31243},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
        },
        [31243] = { -- Attack on Mistfall Village -- Pagoda to Mistfall Attack
            [questKeys.startedBy] = {{58408}},
            [questKeys.exclusiveTo] = {30281,30282,30283,30292,30293,31131,31242},
            [questKeys.preQuestGroup] = {30307,30308,30312,31754,31760},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31244] = { -- Guo-Lai Encampment -- Lake Peace to Ruins Attack
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.exclusiveTo] = {31240,31245,31246,31247,31248,31294,31295,31296},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284}, -- Whitepetal Lake Peace
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31245] = { -- Mistfall Village -- Lake Peace to Mistfall Peace
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.exclusiveTo] = {31240,31244,31246,31247},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284}, -- Whitepetal Lake Peace
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31246] = { -- Attack on Mistfall Village -- Lake Peace to Mistfall Attack
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{58911}},
            [questKeys.exclusiveTo] = {31240,31244,31245,31247},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284}, -- Whitepetal Lake Peace
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31247] = { -- Setting Sun Garrison -- Lake Peace to Garrison
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{58919}},
            [questKeys.exclusiveTo] = {31240,31244,31245,31246},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284}, -- Whitepetal Lake Peace
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31248] = { -- The Ruins of Guo-Lai -- Lake Attack to Ruins Peace
            [questKeys.startedBy] = {{58408}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.exclusiveTo] = {31240,31244,31249,31294,31295,31296,31297},
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31249] = { -- Mistfall Village -- Lake Attack to Mistfall Peace
            [questKeys.startedBy] = {{58408}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.exclusiveTo] = {31248,31297},
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31250] = { -- Setting Sun Garrison -- Mistfall Attack to Garrison lead out
            [questKeys.startedBy] = {{59337}},
            [questKeys.preQuestSingle] = {30288}, -- needs daily module
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31296},
        },
        [31251] = { -- Best Meals Anywhere!
            [questKeys.preQuestSingle] = {30515},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31252] = { -- Back to Westwind Rest
            [questKeys.preQuestGroup] = {30571,30581},
        },
        [31253] = { -- Back to Eastwind Rest
            [questKeys.preQuestGroup] = {30571,30581},
        },
        [31254] = { -- The Road to Kun-Lai [Alliance]
            [questKeys.objectives] = {{{62738,nil,Questie.ICON_TYPE_TALK},{63367,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31255] = { -- The Road to Kun-Lai [Horde]
            [questKeys.objectives] = {{{62738,nil,Questie.ICON_TYPE_TALK},{63367,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31256] = { -- Round 'Em Up
            [questKeys.preQuestSingle] = {30515},
            [questKeys.objectives] = {{{59611,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Round up a yak"),0,{{"monster",59610}}}},
        },
        [31261] = { -- Captain Jack's Dead
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31265] = { -- Mazu's Breath
            [questKeys.triggerEnd] = {"Drink the Potion of Mazu's Breath", {[zoneIDs.DREAD_WASTES] = {{54.79,72.15}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {31066},
        },
        [31266] = { -- Mogu Incursions
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,42000},
        },
        [31267] = { -- Mistblade Destruction
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31109,31111,31231}, -- exclusivity for honored The Klaxxi
        },
        [31268] = { -- A Little Brain Work
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31235,31487,31505}, -- exclusivity for honored The Klaxxi
        },
        [31269] = { -- The Scale-Lord
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31233,31502,31508}, -- exclusivity for honored The Klaxxi
        },
        [31270] = { -- The Fight Against Fear
            [questKeys.preQuestSingle] = {31026},
            [questKeys.exclusiveTo] = {31232,31496,31507}, -- exclusivity for honored The Klaxxi
        },
        [31271] = { -- Bad Genes
            [questKeys.preQuestSingle] = {31606},
            [questKeys.exclusiveTo] = {31234,31503,31509}, -- exclusivity for honored The Klaxxi
        },
        [31272] = { -- Infection
            [questKeys.preQuestSingle] = {31439},
        },
        [31279] = { -- Everything I Know About Cooking
            [questKeys.requiredLevel] = 86,
            [questKeys.exclusiveTo] = {31486},
        },
        [31281] = { -- So You Want to Be a Chef...
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Learn to make Sliced Peaches"),0,{{"monster",64231}}}},
        },
        [31285] = { -- The Spring Drifter
            [questKeys.objectives] = {{{63517,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [31288] = { -- Research Project: The Mogu Dynasties
            [questKeys.exclusiveTo] = {31291},
            [questKeys.objectives] = {nil,{{440006}}},
        },
        [31289] = { -- Research Project: The Pandaren Empire
            [questKeys.objectives] = {nil,{{440007}}},
        },
        [31291] = { -- Uncovering the Past
            [questKeys.exclusiveTo] = {31288},
        },
        [31293] = { -- Mogu Make Poor House Guests
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.exclusiveTo] = {30296,30297,31250,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [31294] = { -- The Ruins of Guo-Lai -- Mistfall Peace to Ruins Peace lead out
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.preQuestSingle] = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263}, -- needs daily module
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30385,31240,31244,31248,31295,31296},
        },
        [31295] = { -- Mogu within the Ruins of Guo-Lai -- Mistfall Peace to Ruins Attack lead out
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestSingle] = {30190,30191,30192,30193,30194,30195,30196,30231,30232,30237,30238,30263}, -- needs daily module
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30385,31240,31244,31248,31294,31296},
        },
        [31296] = { -- The Ruins of Guo-Lai -- Mistfall Attack to Ruins Peace lead out
            [questKeys.startedBy] = {{59337}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.preQuestSingle] = {30288}, -- needs daily module
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31240,31244,31248,31250,31294,31295},
        },
        [31297] = { -- Setting Sun Garrison -- Lake Attack to Garrison
            [questKeys.startedBy] = {{59337}},
            [questKeys.finishedBy] = {{58919}},
            [questKeys.exclusiveTo] = {31248,31249},
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31302] = { -- Ready For Greatness
            [questKeys.preQuestSingle] = {31281},
            [questKeys.requiredSkill] = {profKeys.COOKING,500},
        },
        [31303] = { -- The Seal is Broken
            [questKeys.preQuestSingle] = {30485,31362},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mishi"),0,{{"monster",64244}}}},
            [questKeys.objectives] = {{{64269,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31308] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
        },
        [31309] = { -- On The Mend
            [questKeys.objectives] = {{{6749,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31312] = { -- The Old Map
            [questKeys.nextQuestInChain] = 31313,
            [questKeys.requiredMinRep] = {1272,42000}, -- Tillers

                -- requires exalted with Tillers and best friend with farmers but Questie only supports one faction rep currently
                 -- Tillers
                --{1273,42000}, -- Jogu
                --{1275,42000}, -- Ella
                --{1276,42000}, -- Old Hillpaw
                --{1277,42000}, -- Chee Chee
                --{1278,42000}, -- Sho
                --{1279,42000}, -- Haohan
                --{1280,42000}, -- Tina
                --{1281,42000}, -- Gina
                --{1282,42000}, -- Fish
                --{1283,42000} -- Farmer Fung
            --},
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
        [31319] = { -- Emergency Response
            [questKeys.objectives] = {{{64491,nil,Questie.ICON_TYPE_INTERACT},{64493,nil,Questie.ICON_TYPE_INTERACT},{64494,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31303},
        },
        [31320] = { -- Buy A Fish A Drink?
            [questKeys.requiredMinRep] = {1273,8400}, -- Aquaintance level with Jogu
        },
        [31321] = { -- Buy A Fish A Round?
            [questKeys.requiredMinRep] = {1273,16800}, -- Buddy level with Jogu
        },
        [31322] = { -- Buy A Fish A Keg?
            [questKeys.requiredMinRep] = {1273,25200}, -- Friend level with Jogu
        },
        [31323] = { -- Buy A Fish A Brewery?
            [questKeys.requiredMinRep] = {1273,36000}, -- within 6000 rep of Best Friend (wowhead comment)
        },
        [31325] = { -- A Very Nice Necklace
            [questKeys.requiredMinRep] = {1280,8400}, -- Tina at Acquaintance level (8400-16800)
        },
        [31326] = { -- Tina's Tasteful Tiara
            [questKeys.requiredMinRep] = {1280,16800}, -- Tina at Buddy level (16800-25200)
        },
        [31327] = { -- Trouble Brewing
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {30085},
        },
        [31328] = { -- An Exquisite Earring
            [questKeys.requiredMinRep] = {1280,25200}, -- Tina at Friend level or above (25200+)
        },
        [31329] = { -- A Beautiful Brooch
            [questKeys.requiredMinRep] = {1280,33600}, -- Tina at Good Friend level or above (33600+)
        },
        [31338] = { -- Lost Sheepie
            [questKeys.requiredMinRep] = {1277,16800}, -- Buddy level with Chee Chee
        },
        [31339] = { -- Lost Sheepie... Again
            [questKeys.requiredMinRep] = {1277,25200}, -- Friend level with Chee Chee
        },
        [31340] = { -- Oh Sheepie...
            [questKeys.requiredMinRep] = {1277,33600}, -- Good Friends level with Chee Chee
        },
        [31354] = { -- Mazu's Bounty
            [questKeys.preQuestSingle] = {31190},
        },
        [31355] = { -- Restoring Jade's Purity
            [questKeys.objectives] = {{{56448},{56732},{56843,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31362] = { -- Last Piece of the Puzzle
            [questKeys.preQuestGroup] = {30565,30568},
            [questKeys.objectives] = {nil,{{213652}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mishi"),0,{{"monster",64475}}}},
        },
        [31367] = { -- The Lorewalkers
            [questKeys.breadcrumbForQuestId] = 31015,
            [questKeys.exclusiveTo] = {31016,31368},
            [questKeys.objectives] = {{{65716,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31368] = { -- The Lorewalkers
            [questKeys.breadcrumbForQuestId] = 31015,
            [questKeys.exclusiveTo] = {31016,31367},
            [questKeys.objectives] = {{{65716,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31372] = { -- The Tillers
            [questKeys.breadcrumbForQuestId] = 30252,
        },
        [31373] = { -- The Order of the Cloud Serpent
            [questKeys.preQuestSingle] = {31782}, -- not entirely sure
        },
        [31374] = { -- The Tillers
            [questKeys.breadcrumbForQuestId] = 30252,
        },
        [31375] = { -- The Order of the Cloud Serpent
            [questKeys.preQuestSingle] = {31782}, -- not entirely sure
        },
        [31376] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.preQuestSingle] = {31511,31512,31782},
            [questKeys.exclusiveTo] = {31378,31380,31382,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31377] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.preQuestSingle] = {31511,31512,31782},
            [questKeys.exclusiveTo] = {31379,31381,31383,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31378] = { -- Challenge At The Temple of the Red Crane
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31376,31380,31382,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31379] = { -- Challenge At The Temple of the Red Crane
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31377,31381,31383,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31380] = { -- Trial At The Temple of the White Tiger
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31376,31378,31382,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31381] = { -- Trial At The Temple of the White Tiger
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31377,31379,31383,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31382] = { -- Defense At Niuzao Temple
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31376,31378,31380,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31383] = { -- Defense At Niuzao Temple
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31377,31379,31381,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31386] = { -- The Shado-Pan Offensive
            [questKeys.exclusiveTo] = {31388,30768,31695},
        },
        [31388] = { -- The Shado-Pan Offensive
            [questKeys.exclusiveTo] = {31386,30768,31695},
        },
        [31390] = { -- The Klaxxi
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31391,31656,31847,31886,31895},
        },
        [31391] = { -- The Klaxxi
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31656,31847,31886,31895},
        },
        [31392] = { -- Temple of the White Tiger [Alliance]
            [questKeys.breadcrumbForQuestId] = 31394,
            [questKeys.exclusiveTo] = {31394},
        },
        [31393] = { -- Temple of the White Tiger
            [questKeys.startedBy] = {{55809,60289,63751,64448,64521}},
            [questKeys.breadcrumbForQuestId] = 31395,
        },
        [31394] = { -- A Celestial Experience [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31392},
            [questKeys.objectives] = {{{64528,nil,Questie.ICON_TYPE_TALK},{64656},{64684},{64744}}},
        },
        [31395] = { -- A Celestial Experience [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31393},
            [questKeys.objectives] = {{{64528,nil,Questie.ICON_TYPE_TALK},{64656},{64684},{64744}}},
        },
        [31398] = { -- Falling to Pieces
            [questKeys.preQuestSingle] = {31091},
        },
        [31439] = { -- Dropping Our Signal
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31450] = { -- A New Fate
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{56013,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [31451] = { -- The Missing Merchant [Horde]
            [questKeys.preQuestGroup] = {30655,30656,30661},
            [questKeys.breadcrumbForQuestId] = 30467,
        },
        [31452] = { -- The Missing Merchant [Alliance]
            [questKeys.preQuestGroup] = {30650,30651,30660},
            [questKeys.breadcrumbForQuestId] = 30467,
        },
        [31453] = { -- The Shado-Pan [Horde]
            [questKeys.preQuestGroup] = {30655,30656,30661},
            [questKeys.breadcrumbForQuestId] = 30665,
        },
        [31454] = { -- A Legend in the Making
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31488,31489},
            [questKeys.objectives] = {{{64616,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31455] = { -- The Shado-Pan [Alliance]
            [questKeys.preQuestGroup] = {30650,30651,30660},
            [questKeys.breadcrumbForQuestId] = 30665,
        },
        [31456] = { -- Muskpaw Ranch [Alliance]
            [questKeys.preQuestGroup] = {30650,30651,30660},
            [questKeys.breadcrumbForQuestId] = 30488,
        },
        [31457] = { -- Muskpaw Ranch [Horde]
            [questKeys.preQuestGroup] = {30655,30656,30661},
            [questKeys.breadcrumbForQuestId] = 30488,
        },
        [31458] = { -- Damage Control
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31459] = { -- Cho's Missive [Horde]
            [questKeys.breadcrumbForQuestId] = 30999,
            [questKeys.preQuestGroup] = {30655,30656,30661},
        },
        [31460] = { -- Cho's Missive [Alliance]
            [questKeys.breadcrumbForQuestId] = 30999,
            [questKeys.preQuestGroup] = {30650,30651,30660},
        },
        [31465] = { -- Extracting Answers
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31467] = { -- Strong as a Tiger
            [questKeys.objectives] = {nil,nil,{{74642}},nil,nil,{{104298}}},
        },
        [31468] = { -- Trial of the Black Prince
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {31454},
        },
        [31471] = { -- Agile as a Tiger
            [questKeys.objectives] = {nil,nil,{{74643}},nil,nil,{{104301}}},
        },
        [31473] = { -- The Strength of One's Foes
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {31454},
        },
        [31474] = { -- The Soup of Contemplation
            [questKeys.objectives] = {nil,nil,{{74644}},nil,nil,{{104304}}},
        },
        [31476] = { -- The Spirit of Cooking
            [questKeys.objectives] = {nil,nil,{{74654}},nil,nil,{{104307}}},
        },
        [31477] = { -- Endurance
            [questKeys.objectives] = {nil,nil,{{74654}},nil,nil,{{104310}}},
        },
        [31480] = { -- Have a Drink
            [questKeys.objectives] = {nil,nil,{{75026}},nil,nil,{{124052}}},
        },
        [31486] = { -- Everything I Know About Cooking
            [questKeys.requiredLevel] = 86,
            [questKeys.exclusiveTo] = {31279},
        },
        [31487] = { -- Sonic Disruption
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31235,31268,31505}, -- exclusivity for honored The Klaxxi
        },
        [31488] = { -- Stranger in a Strange Land
            [questKeys.startedBy] = {{62871,63218,64047,64144,64457,66225,66409,66415}},
            [questKeys.breadcrumbForQuestId] = 31454,
        },
        [31489] = { -- Stranger in a Strange Land
            [questKeys.breadcrumbForQuestId] = 31454,
        },
        [31490] = { -- Rank and File
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58632,58676,58683,58684,58685,58756,58898,58998,59150,59175,59191,59240,59241,59293,59303,59372,59373},58632}}}
        },
        [31492] = { -- The Torch of Strength
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31517},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31494] = { -- Free From Her Clutches
            [questKeys.objectives] ={nil,{{214292}}},
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.exclusiveTo] = {31024,31238,31506}, -- exclusivity for honored The Klaxxi
        },
        [31495] = { -- Rank and File
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58632,58676,58683,58684,58685,58756,58898,58998,59150,59175,59191,59240,59241,59293,59303,59372,59373},58632}}}
        },
        [31496] = { -- Sampling the Empire's Finest
            [questKeys.preQuestSingle] = {31026},
            [questKeys.exclusiveTo] = {31232,31270,31507}, -- exclusivity for honored The Klaxxi
        },
        [31502] = { -- Wing Clip
            [questKeys.preQuestSingle] = {31606},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31233,31269,31508}, -- exclusivity for honored The Klaxxi
        },
        [31503] = { -- Shortcut to Ruin
            [questKeys.preQuestSingle] = {31606},
            [questKeys.exclusiveTo] = {31234,31271,31509}, -- exclusivity for honored The Klaxxi
        },
        [31504] = { -- Ordnance Disposal
            [questKeys.preQuestSingle] = {31439},
        },
        [31505] = { -- Vess-Guard Duty
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31235,31268,31487}, -- exclusivity for honored The Klaxxi
        },
        [31506] = { -- Shackles of Manipulation
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.exclusiveTo] = {31024,31238,31494}, -- exclusivity for honored The Klaxxi
        },
        [31507] = { -- Meltdown
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31232,31270,31496}, -- exclusivity for honored The Klaxxi
        },
        [31508] = { -- Specimen Request
            [questKeys.preQuestSingle] = {31606},
            [questKeys.exclusiveTo] = {31233,31269,31502}, -- exclusivity for honored The Klaxxi
        },
        [31509] = { -- Fear Takes Root
            [questKeys.preQuestSingle] = {31606},
            [questKeys.objectives] = {nil,{{214543}}},
            [questKeys.exclusiveTo] = {31234,31271,31503}, -- exclusivity for honored The Klaxxi
        },
        [31510] = { -- Quiet Now
            [questKeys.preQuestSingle] = {31439},
        },
        [31511] = { -- A Witness to History [Horde]
            [questKeys.objectives] = {{{64853,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31512] = { -- A Witness to History [Alliance]]
            [questKeys.objectives] = {{{64848,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31514] = { -- Unto Dust Thou Shalt Return
            [questKeys.objectives] = {{{3977,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31516] = { -- Unto Dust Thou Shalt Return
            [questKeys.objectives] = {{{3977,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31517] = { -- Contending With Bullies
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31492},
        },
        [31519] = {-- A Worthy Challenge: Yan-zhu the Uncasked
            [questKeys.exclusiveTo] = {31520,31522,31523,31524,31525,31526,31527,31528},
        },
        [31520] = {-- A Worthy Challenge: Sha of Doubt
            [questKeys.exclusiveTo] = {31519,31522,31523,31524,31525,31526,31527,31528},
        },
        [31521] = { -- To Be a Master
            [questKeys.requiredSkill] = {profKeys.COOKING,600},
            [questKeys.preQuestGroup] = {31311,31470,31472,31475,31478,31479},
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
        [31529] = { -- Mission: Culling The Vermin
            [questKeys.requiredMinRep] = {1278,12600}, -- 4200 into Aquaintance with Sho
        },
        --[31530] = { -- Mission: The Hozen Dozen -- Don't think this made it to live so blacklisted
            --[questKeys.requiredMinRep] = {1278,} --
       -- },
        [31531] = { -- Mission: Aerial Threat
            [questKeys.requiredMinRep] = {1278,29400}, -- 4200 into Friend with Sho
        },
        [31532] = { -- Mission: Predator of the Cliffs
            [questKeys.requiredMinRep] = {1278,37800}, -- 4200 into Good Friend with Sho
        },
        [31534] = { -- The Beginner's Brew
            [questKeys.requiredMinRep] = {1275,16800}, -- Buddy level with Ella
        },
        [31535] = { -- Replenishing the Pantry
            [questKeys.preQuestSingle] = {31536},
        },
        [31536] = { -- Preserving Freshness
            [questKeys.preQuestGroup] = {31311,31470,31472,31475,31478,31479},
        },
        [31537] = { -- Ella's Taste Test
            [questKeys.requiredMinRep] = {1275,25200}, -- Friend level with Ella
            [questKeys.objectives] = {{{58710,nil,Questie.ICON_TYPE_INTERACT},{58717,nil,Questie.ICON_TYPE_INTERACT},{58646,nil,Questie.ICON_TYPE_INTERACT},{64597,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31538] = { -- A Worthy Brew
            [questKeys.requiredMinRep] = {1275,33600}, -- Good friends level with Ella
        },
        [31539] = { -- A Thing of Beauty
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,525},
            [questKeys.exclusiveTo] = {31540,31541,31542,31543,31544},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [31540] = { -- Staves for Tian Monastery
            [questKeys.startedBy] = {{56065}},
            [questKeys.requiredLevel] = 85,
            [questKeys.questLevel] = 90,
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,525},
            [questKeys.zoneOrSort] = 5931,
            [questKeys.exclusiveTo] = {31539,31541,31542,31543,31544},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [31541] = { -- Set in Jade
            [questKeys.startedBy] = {{56063}},
            [questKeys.requiredLevel] = 85,
            [questKeys.questLevel] = 90,
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,525},
            [questKeys.zoneOrSort] = 5931,
            [questKeys.exclusiveTo] = {31539,31540,31542,31543,31544},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [31542] = { -- Incarnadine Ink
            [questKeys.startedBy] = {{56064}},
            [questKeys.requiredLevel] = 85,
            [questKeys.questLevel] = 90,
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,525},
            [questKeys.zoneOrSort] = 5931,
            [questKeys.exclusiveTo] = {31539,31540,31541,31543,31544},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [31543] = { -- Portrait of a Lady
            [questKeys.startedBy] = {{56064}},
            [questKeys.requiredLevel] = 85,
            [questKeys.questLevel] = 90,
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,525},
            [questKeys.zoneOrSort] = 5931,
            [questKeys.exclusiveTo] = {31539,31540,31541,31542,31544},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [31544] = { -- A Tribute to the Dead
            [questKeys.startedBy] = {{56063}},
            [questKeys.requiredLevel] = 85,
            [questKeys.questLevel] = 90,
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,525},
            [questKeys.zoneOrSort] = 5931,
            [questKeys.exclusiveTo] = {31539,31540,31541,31542,31543},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [31548] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63075}},
            [questKeys.requiredSpell] = 119467,
        },
        [31549] = { -- On The Mend
            [questKeys.objectives] = {{{9980,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31551] = { -- Got one!
            [questKeys.startedBy] = {{63075}},
        },
        [31552] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63070}},
            [questKeys.requiredSpell] = 119467,
        },
        [31553] = { -- On The Mend
            [questKeys.startedBy] = {{63070}},
            [questKeys.objectives] = {{{10051,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31556] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredSpell] = 119467,
        },
        [31568] = { -- On The Mend
            [questKeys.startedBy] = {{63077}},
            [questKeys.objectives] = {{{17485,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31569] = { -- Got one!
            [questKeys.startedBy] = {{63077}},
        },
        [31571] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
        },
        [31572] = { -- On The Mend
            [questKeys.startedBy] = {{63061}},
            [questKeys.objectives] = {{{9987,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31573] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredSpell] = 119467,
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
            [questKeys.requiredSpell] = 119467,
        },
        [31577] = { -- On The Mend
            [questKeys.startedBy] = {{63073}},
            [questKeys.objectives] = {{{10055,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31578] = { -- Got one!
            [questKeys.startedBy] = {{63073}},
        },
        [31579] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
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
            [questKeys.requiredSpell] = 119467,
        },
        [31583] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.objectives] = {{{10085,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31585] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
        },
        [31586] = { -- On The Mend
            [questKeys.startedBy] = {{63086}},
            [questKeys.objectives] = {{{45789,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31587] = { -- Got one!
            [questKeys.startedBy] = {{63086}},
        },
        [31588] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
        },
        [31589] = { -- On The Mend
            [questKeys.objectives] = {{{47764,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31591] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
        },
        [31592] = { -- On The Mend
            [questKeys.objectives] = {{{11069,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31598] = { -- Kypa'rak's Core
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31599] = { -- The Matriarch's Maw
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31605] = { -- The Zan'thik Dig
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,3000},
            [questKeys.preQuestSingle] = {31026},
        },
        [31606] = { -- The Dissector Wakens
            [questKeys.objectives] = {{{67091}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,3000},
        },
        [31656] = { -- The Threat in the South
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31391,31847,31886,31895},
        },
        [31660] = { -- Not Fit to Swarm
            [questKeys.preQuestSingle] = {31006},
        },
        [31661] = { -- A Source of Terrifying Power
            [questKeys.preQuestSingle] = {31006},
        },
        [31669] = { -- The Cabbage Test
            [questKeys.exclusiveTo] = {31670,31671,31672,31673,31674,31675,31941,31942,31943},
        },
        [31670] = { -- That Dangling Carrot
            [questKeys.exclusiveTo] = {31669,31671,31672,31673,31674,31675,31941,31942,31943},
        },
        [31671] = { -- Why Not Scallions?
            [questKeys.exclusiveTo] = {31669,31670,31672,31673,31674,31675,31941,31942,31943},
        },
        [31672] = { -- A Pumpkin-y Perfume
            [questKeys.exclusiveTo] = {31669,31670,31671,31673,31674,31675,31941,31942,31943},
            [questKeys.requiredSourceItems] = {80592},
        },
        [31673] = { -- Red Blossom Leeks, You Make the Croc-in' World Go Down
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31674,31675,31941,31942,31943},
        },
        [31674] = { -- The Pink Turnip Challenge
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31675,31941,31942,31943},
        },
        [31675] = { -- The White Turnip Treatment
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31941,31942,31943},
        },
        [31676] = { -- Ancient Vengeance
            [questKeys.preQuestSingle] = {31004},
        },
        [31677] = { -- The Warlord's Ashes
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31679] = { -- Extending Our Coverage
            [questKeys.exclusiveTo] = {31087},
        },
        [31680] = { -- Crime and Punishment
            [questKeys.exclusiveTo] = {31088},
        },
        [31681] = { -- Better With Age
            [questKeys.exclusiveTo] = {31090},
            [questKeys.preQuestSingle] = {31087},
        },
        [31682] = { -- By the Sea, Nevermore
            [questKeys.objectives] = {nil,{{212294,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31680,31681},
            [questKeys.exclusiveTo] = {31089},
        },
        [31687] = { -- Thinning the Sik'thik
            [questKeys.preQuestSingle] = {31065},
        },
        [31688] = { -- The Search for Restless Leng
            [questKeys.preQuestSingle] = {31065},
            [questKeys.objectives] = {nil,{{214734},{214734}}},
        },
        [31689] = { -- The Dreadsworn
            [questKeys.preQuestSingle] = {31661},
        },
        [31693] = { -- Julia Stevens
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{64330,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31695] = { -- Beyond the Wall
            [questKeys.exclusiveTo] = {31386,31388,30768},
        },
        [31698] = { -- Thinning The Pack
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31699] = { -- Sprite Fright
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31700] = { -- The Shoe Is On The Other Foot
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31701] = { -- Dark Huntress
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31702] = { -- On The Prowl
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31703] = { -- Madcap Mayhem
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31704] = { -- Pooped
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31705] = { -- Needle Me Not
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31706] = { -- Weeping Widows
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31707] = { -- A Tangled Web
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31708] = { -- Serpent's Scale
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31709] = { -- Lingering Doubt
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31711] = { -- The Seed of Doubt
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31712] = { -- Monkey Mischief
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31713] = { -- The Big Brew-haha
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31714] = { -- Saving the Serpents
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31715] = { -- The Big Kah-Oona
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31717] = { -- The Trainer's Challenge: Ace Longpaw
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31718] = { -- The Trainer's Challenge: Big Bao
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31719] = { -- The Trainer's Challenge: Ningna Darkwheel
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31720] = { -- The Trainer's Challenge: Suchi the Sweet
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31721] = { -- The Trainer's Challenge: Qua-Ro Whitebrow
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
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
        [31727] = { -- Gambling Problem
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,9000},
        },
        [31728] = { -- Bill Buckler
            [questKeys.objectives] = {{{65656,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31729] = { -- Steven Lisbane
            [questKeys.objectives] = {{{63194,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31730] = { -- A Not So Friendly Request
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,9000},
            [questKeys.breadcrumbForQuestId] = 31067,
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
        [31739] = { -- Priorities!
            [questKeys.preQuestGroup] = {31736,31737},
            [questKeys.objectives] = {nil,{{215133}}},
        },
        [31741] = { -- Twinspire Keep
            [questKeys.preQuestGroup] = {29552,31738,31740},
        },
        [31742] = { -- Fractured Forces
            [questKeys.preQuestGroup] = {29552,31738,31740},
        },
        [31743] = { -- Smoke Before Fire
            [questKeys.preQuestGroup] = {29552,31738,31740},
            [questKeys.objectives] = {nil,{{215275,nil,Questie.ICON_TYPE_EVENT}},nil,nil,{{{66279},66279,nil,Questie.ICON_TYPE_EVENT},{{66277},66277,nil,Questie.ICON_TYPE_EVENT},{{66278},66278,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31744] = { -- Unfair Trade
            [questKeys.preQuestGroup] = {29552,31738,31740},
            [questKeys.objectives] = {{{66366,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the eyes"),0,{{"monster",66367}}}},
        },
        [31745] = { -- Onward and Inward
            [questKeys.objectives] = {{{67067,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [31754] = { -- Cannonfire
            [questKeys.startedBy] = {{58471}},
            [questKeys.objectives] = {{{65762,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31756,31758},
        },
        [31755] = { -- Acts of Cruelty
            [questKeys.startedBy] = {{58468}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {30312,30320},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{65817,65818,65804},65804,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSpell] = 115913,
        },
        [31756] = { -- High Chance of Rain
            [questKeys.startedBy] = {{58471}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31754,31758},
            [questKeys.requiredSpell] = 115913,
        },
        [31757] = { -- Unleashed Spirits
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {30308,30309,30310},
            [questKeys.requiredSpell] = 115913,
        },
        [31758] = { -- Laosy Scouting
            [questKeys.startedBy] = {{58471}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31754,31756},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredSpell] = 115913,
        },
        [31760] = { -- Striking First
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31762},
            [questKeys.requiredSpell] = 115913,
        },
        [31762] = { -- Crumbling Behemoth
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31760},
            [questKeys.requiredSpell] = 115913,
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
            [questKeys.finishedBy] = {{55403}},
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
            [questKeys.finishedBy] = {nil,{215844}},
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
        [31782] = { -- Overthrone
            [questKeys.preQuestSingle] = {32030},
        },
        [31784] = { -- Onyx To Goodness
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = 0,
            [questKeys.requiredMinRep] = {},
        },
        [31808] = { -- Rampage Against the Machine
            [questKeys.preQuestGroup] = {31092,31359,31398},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
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
        [31833] = { -- Continue Your Training: Master Woo
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbs] = {31855},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66254}}}},
        },
        [31834] = { -- Begin Your Training: Master Cheng
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.zoneOrSort] = zoneIDs.PEAK_OF_SERENITY,
            [questKeys.breadcrumbs] = {31856},
        },
        [31835] = { -- Continue Your Training: Master Kistane
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66253}}}},
            [questKeys.breadcrumbs] = {31857},
        },
        [31836] = { -- Continue Your Training: Master Yoon
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66255}}}},
            [questKeys.breadcrumbs] = {31858},
        },
        [31837] = { -- Continue Your Training: Master Cheng
            [questKeys.requiredClasses] = classIDs.MONK,
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.breadcrumbs] = {31859},
        },
        [31838] = { -- Continue Your Training: Master Tsang
            [questKeys.requiredClasses] = classIDs.MONK,
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.breadcrumbs] = {31860},
        },
        [31839] = { -- Continue Your Training: Master Hsu
            [questKeys.requiredClasses] = classIDs.MONK,
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.breadcrumbs] = {31861},
        },
        [31840] = { -- Practice Makes Perfect: Master Cheng
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31834},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31841,31842,31843,31844,31845,31846},
            [questKeys.requiredMaxLevel] = 29,
        },
        [31841] = { -- Practice Makes Perfect: Master Woo
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31833},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66254}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31842,31843,31844,31845,31846},
            [questKeys.requiredMaxLevel] = 39,
        },
        [31842] = { -- Practice Makes Perfect: Master Kistane
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31835},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66253}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31843,31844,31845,31846},
            [questKeys.requiredMaxLevel] = 49,
        },
        [31843] = { -- Practice Makes Perfect: Master Yoon
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31836},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66255}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31844,31845,31846},
            [questKeys.requiredMaxLevel] = 59,
        },
        [31844] = { -- Practice Makes Perfect: Master Cheng
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31837},
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31843,31845,31846},
            [questKeys.requiredMaxLevel] = 69,
        },
        [31845] = { -- Practice Makes Perfect: Master Tsang
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31838},
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31843,31844,31846},
            [questKeys.requiredMaxLevel] = 79,
        },
        [31846] = { -- Practice Makes Perfect: Master Hsu
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31839},
            --[questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31843,31844,31845},
            [questKeys.requiredMaxLevel] = 89,
        },
        [31847] = { -- Better Dead then Dread
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31391,31656,31886,31895},
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
        [31855] = { -- The Peak of Serenity - Continue Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31833,
        },
        [31856] = { -- The Peak of Serenity - Begin Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31834,
        },
        [31857] = { -- The Peak of Serenity - Continue Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31835,
        },
        [31858] = { -- The Peak of Serenity - Continue Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31836,
        },
        [31859] = { -- The Peak of Serenity - Continue Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31837,
        },
        [31860] = { -- The Peak of Serenity - Continue Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31838,
        },
        [31861] = { -- The Peak of Serenity - Continue Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31839,
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
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,1},
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
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,1},
        },
        [31886] = { -- Dread Space
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31391,31656,31847,31895},
        },
        [31889] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE},{66436,nil,Questie.ICON_TYPE_PET_BATTLE},{66452,nil,Questie.ICON_TYPE_PET_BATTLE},{66442,nil,Questie.ICON_TYPE_PET_BATTLE},{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31917},
        },
        [31891] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE},{66436,nil,Questie.ICON_TYPE_PET_BATTLE},{66452,nil,Questie.ICON_TYPE_PET_BATTLE},{66442,nil,Questie.ICON_TYPE_PET_BATTLE},{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31918},
        },
        [31894] = { -- A Delicate Balance
            [questKeys.preQuestSingle] = {30784},
        },
        [31895] = { -- Better Off Dread
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31391,31656,31847,31886},
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
        [31936] = { -- The "Jinyu Princess" Irrigation System
            [questKeys.preQuestSingle] = {30516},
        },
        [31937] = { -- "Thunder King" Pest Repellers
            [questKeys.preQuestSingle] = {30524},
        },
        [31938] = { -- The "Earth-Slasher" Master Plow
            [questKeys.preQuestSingle] = {30529},
        },
        [31941] = { -- Squash Those Foul Odors
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31675,31942,31943},
        },
        [31942] = { -- It's Melon Time
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31675,31941,31943},
        },
        [31943] = { -- Which Berries? Witchberries.
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31675,31941,31942},
        },
        [31944] = { -- Complete Your Training: The Final Test
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbs] = {31989},
        },
        [31945] = { -- Learn and Grow VI: Gina's Vote
            [questKeys.requiredSourceItems] = {80591},
        },
        [31946] = { -- Mung-Mung's Vote III: The Great Carrot Caper
            [questKeys.preQuestSingle] = {30259},
        },
        [31947] = { -- Farmer Fung's Vote III: Crazy For Cabbage
            [questKeys.preQuestSingle] = {30518},
            [questKeys.objectives] = {{{59990,nil,Questie.ICON_TYPE_INTERACT},{58566,nil,Questie.ICON_TYPE_INTERACT}},nil,{{74840}}},
        },
        [31949] = { -- Nana's Vote III: Witchberry Julep
            [questKeys.preQuestSingle] = {31948},
        },
        [31951] = { -- Grand Master Aki
            [questKeys.startedBy] = {{66741}},
            [questKeys.preQuestSingle] = {31930,31952},
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
        [31959] = { -- The Empress' Gambit
            [questKeys.preQuestGroup] = {
                31004, -- Kil'ruk the Wind-Reaver
                31085, -- Iyyokuk the Lucid
                31010, -- Malik the Unscathed
                31018, -- Xaril the Poisoned Mind
                31026, -- Korven the Prime
                31179, -- Skeer the Bloodseeker
                31354, -- Ka'roz the Locust
                31439, -- Hisek the Swarmkeeper
                31606, -- Rik'kal the Dissector
                31682, -- Kaz'tik the Manipulator
            },
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,42000},
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
        [31989] = { -- The Peak of Serenity - Complete Your Training
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbForQuestId] = 31944,
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
            [questKeys.objectives] = {nil,{{440004}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [32017] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{63996}},
            [questKeys.objectives] = {nil,{{440004}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [32018] = { -- His Name Was... Stormstout
            [questKeys.exclusiveTo] = {32019},
            [questKeys.breadcrumbForQuestId] = 29907,
        },
        [32019] = { -- They Call Him... Stormstout
            [questKeys.exclusiveTo] = {32018},
            [questKeys.breadcrumbForQuestId] = 29907,
            [questKeys.preQuestSingle] = {30495},
        },
        [32030] = { -- Once in a Hundred Lifetimes
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31066,31086,31398,31354},
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
        [32317] = { -- Seeking the Soulstones
            [questKeys.objectives] = {nil,nil,{{92494},{92495},{92496},{92497}}},
        },
        [32428] = { -- Pandaren Spirit Tamer
            [questKeys.preQuestSingle] = {31951},
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
        [32805] = { -- Celestial Blessings
            [questKeys.objectives] = {{{61093,nil,Questie.ICON_TYPE_TALK},{59653,nil,Questie.ICON_TYPE_TALK},{64528,nil,Questie.ICON_TYPE_TALK},{71954,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{61093,59653,64528,71954},61093,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32863] = { -- What We've Been Training For
            [questKeys.objectives] = {{{110001}}},
        },
        [32868] = { -- Beasts of Fable Book II
            [questKeys.objectives] = {{{68560,nil,Questie.ICON_TYPE_PET_BATTLE},{68561,nil,Questie.ICON_TYPE_PET_BATTLE},{68566,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32869] = { -- Beasts of Fable Book III
            [questKeys.objectives] = {{{68558,nil,Questie.ICON_TYPE_PET_BATTLE},{68559,nil,Questie.ICON_TYPE_PET_BATTLE},{68562,nil,Questie.ICON_TYPE_PET_BATTLE}}},
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
        [92336] = { -- Potion Master
            [questKeys.name] = "Potion Master",
            [questKeys.startedBy] = {{3347,5499}},
            [questKeys.finishedBy] = {{3347,5499}}, -- might need more
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
            [questKeys.requiredSpell] = -28675, -- ok this is a clusterfuck, we need logic change for this field
            [questKeys.objectivesText] = {"Bring a large supply of potions to an alchemy trainer in any capital city."},
            [questKeys.objectives] = {nil,nil,{{76097},{76098},{93351}}},
            [questKeys.exclusiveTo] = {92237,92238},
            [questKeys.zoneOrSort] = -181,
        },
        [92337] = { -- Elixir Master
            [questKeys.name] = "Elixir Master",
            [questKeys.startedBy] = {{3347,5499}},
            [questKeys.finishedBy] = {{3347,5499}}, -- might need more
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
            [questKeys.requiredSpell] = -28677, -- ok this is a clusterfuck, we need logic change for this field
            [questKeys.objectivesText] = {"Bring a variety of flasks to an alchemy trainer in any capital city."},
            [questKeys.objectives] = {nil,nil,{{76088},{76087},{76085},{76084}}},
            [questKeys.exclusiveTo] = {92236,92238},
            [questKeys.zoneOrSort] = -181,
        },
        [92338] = { -- Transmutation Master
            [questKeys.name] = "Transmutation Master",
            [questKeys.startedBy] = {{3347,5499}},
            [questKeys.finishedBy] = {{3347,5499}}, -- might need more
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
            [questKeys.requiredSpell] = -28672, -- ok this is a clusterfuck, we need logic change for this field
            [questKeys.objectivesText] = {"Bring the requested materials to an alchemy trainer in any capital city."},
            [questKeys.objectives] = {nil,nil,{{72104}}},
            [questKeys.exclusiveTo] = {92236,92237},
            [questKeys.zoneOrSort] = -181,
        },
    }
end

function MopQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys

    local questFixesHorde = {
        [30376] = { -- Hope Springs Eternal
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30174,30273}, -- From wowhead this has complicated requirements. It is not only 30273 as DB indicates (confirmed in game). At this point I had also completed all of the Four Winds quest hubs and most of Krasarang working east to west
            [questKeys.exclusiveTo] = {30241},
        },
        [31695] = { -- Beyond The Wall
            [questKeys.preQuestGroup] = {30655,30656,30661},
        },
    }


    local questFixesAlliance = {
        [30376] = { -- Hope Springs Eternal
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30359,30273}, -- From wowhead this has complicated requirements. It is not only 30273 as DB indicates (confirmed in game). At this point I had also completed all of the Four Winds quest hubs and most of Krasarang working east to west
            [questKeys.exclusiveTo] = {30360},
        },
        [31695] = { -- Beyond The Wall
            [questKeys.preQuestGroup] = {30650,30651,30660},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
