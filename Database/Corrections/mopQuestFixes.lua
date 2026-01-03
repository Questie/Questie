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
QuestieCorrections.spellObjectiveFirst[14007] = true
QuestieCorrections.spellObjectiveFirst[14008] = true
QuestieCorrections.spellObjectiveFirst[14010] = true
QuestieCorrections.spellObjectiveFirst[14011] = true
QuestieCorrections.spellObjectiveFirst[14012] = true
QuestieCorrections.spellObjectiveFirst[14013] = true
QuestieCorrections.spellObjectiveFirst[14266] = true
QuestieCorrections.spellObjectiveFirst[14272] = true
QuestieCorrections.spellObjectiveFirst[14274] = true
QuestieCorrections.spellObjectiveFirst[14276] = true
QuestieCorrections.spellObjectiveFirst[14279] = true
QuestieCorrections.spellObjectiveFirst[14281] = true
QuestieCorrections.spellObjectiveFirst[14283] = true
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
QuestieCorrections.killCreditObjectiveFirst[30527] = true
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
QuestieCorrections.killCreditObjectiveFirst[31945] = true
QuestieCorrections.killCreditObjectiveFirst[31946] = true
QuestieCorrections.killCreditObjectiveFirst[31947] = true
QuestieCorrections.killCreditObjectiveFirst[31949] = true
QuestieCorrections.killCreditObjectiveFirst[32247] = true
QuestieCorrections.killCreditObjectiveFirst[32250] = true
QuestieCorrections.killCreditObjectiveFirst[32282] = true
QuestieCorrections.objectObjectiveFirst[32333] = true
QuestieCorrections.killCreditObjectiveFirst[32551] = true
QuestieCorrections.killCreditObjectiveFirst[32643] = true
QuestieCorrections.killCreditObjectiveFirst[32646] = true
QuestieCorrections.killCreditObjectiveFirst[32648] = true
QuestieCorrections.killCreditObjectiveFirst[32650] = true
QuestieCorrections.killCreditObjectiveFirst[32657] = true
QuestieCorrections.killCreditObjectiveFirst[32659] = true
QuestieCorrections.killCreditObjectiveFirst[32943] = true
QuestieCorrections.killCreditObjectiveFirst[32945] = true

function MopQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local profKeys = QuestieProfessions.professionKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local sortKeys = QuestieDB.sortKeys
    local specialFlags = QuestieDB.specialFlags
    local questFlags = QuestieDB.questFlags

    ---@format disable
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
        [6983] = { -- You're a Mean One...
            [questKeys.objectives] = {nil,nil,{{17662}},nil,{{{15664},15664,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [7043] = { -- You're a Mean One...
            [questKeys.objectives] = {nil,nil,{{17662}},nil,{{{15664},15664,nil,Questie.ICON_TYPE_INTERACT}}},
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
        [8788] = {
            [questKeys.requiredClasses] = classIDs.PRIEST + classIDs.WARLOCK + classIDs.MAGE + classIDs.SHAMAN + classIDs.DRUID + classIDs.MONK,
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
        [10277] = { -- The Caverns of Time
            [questKeys.triggerEnd] = {"Caverns of Time Explained", {[zoneIDs.CAVERNS_OF_TIME]={{44.31,38.73}}}},
        },
        [12515] = { -- Nice Hat...
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.NIGHT_ELF + raceIDs.DRAENEI + raceIDs.TROLL + raceIDs.TAUREN + raceIDs.UNDEAD + raceIDs.BLOOD_ELF + raceIDs.GOBLIN + raceIDs.WORGEN + raceIDs.PANDAREN,
        },
        [13408] = { -- Hellfire Fortifications
            [questKeys.requiredClasses] = 2015, -- all classes except DK
        },
        [13409] = { -- Hellfire Fortifications
            [questKeys.requiredClasses] = 2015, -- all classes except DK
        },
        [14007] = { -- Steady Shot
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14008] = { -- Frost Nova
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{5143}}},
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14009] = { -- Learning the Word
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{589}}},
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14010] = { -- Eviscerate
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14011] = { -- Primal Strike
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14012] = { -- Corruption
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{172}}},
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14013] = { -- Charge
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {},
        },
        [14266] = { -- Charge
            [questKeys.extraObjectives] = {},
        },
        [14272] = { -- Eviscerate
            [questKeys.extraObjectives] = {},
        },
        [14274] = { -- Corruption
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{172}}},
            [questKeys.extraObjectives] = {},
        },
        [14276] = { -- Steady Shot
            [questKeys.extraObjectives] = {},
        },
        [14279] = { -- Learning the Word
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{589}}},
            [questKeys.extraObjectives] = {},
        },
        [14281] = { -- Frost Nova
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{122}}},
            [questKeys.extraObjectives] = {},
        },
        [14283] = { -- Moonfire
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{8921}}},
            [questKeys.extraObjectives] = {},
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
        [25047] = { -- Broken Panther Figurine
            [questKeys.requiredClasses] = classIDs.HUNTER + classIDs.ROGUE + classIDs.SHAMAN + classIDs.DRUID + classIDs.MONK,
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
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
        [28414] = { -- Fourth and Goal
            [questKeys.requiredRaces] = raceIDs.GOBLIN,
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
        [28732] = { -- This Can Only Mean One Thing...
            [questKeys.objectives] = {{{49456,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [28756] = { -- Aberrations of Bone
            [questKeys.objectives] = {{{59153}}},
            [questKeys.zoneOrSort] = zoneIDs.SCHOLOMANCE_MOP,
        },
        [28775] = { -- Broken Serpent Figurine
            [questKeys.requiredClasses] = classIDs.PALADIN + classIDs.PRIEST + classIDs.SHAMAN + classIDs.MAGE + classIDs.WARLOCK + classIDs.DRUID + classIDs.MONK,
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [28776] = { -- Broken Earthen Figurine
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.DEATH_KNIGHT + classIDs.DRUID + classIDs.MONK,
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [28777] = { -- Broken Owl Figurine
            [questKeys.requiredClasses] = classIDs.PALADIN + classIDs.PRIEST + classIDs.SHAMAN + classIDs.DRUID + classIDs.MONK,
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [28778] = { -- Broken Boar Figurine
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.DEATH_KNIGHT,
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING,475},
        },
        [28798] = { -- Waters of Elune
            [questKeys.requiredSkill] = {},
        },
        [28799] = { -- Might of the Earthen
            [questKeys.requiredSkill] = {},
        },
        [28800] = { -- Whispers of the Djinn
            [questKeys.requiredSkill] = {},
        },
        [28801] = { -- Tol'vir Heiroglyphics
            [questKeys.requiredSkill] = {},
        },
        [28802] = { -- Map of the Architects
            [questKeys.requiredSkill] = {},
        },
        [28803] = { -- Vengeance of the Wildhammer
            [questKeys.requiredSkill] = {},
        },
        [28804] = { -- Dark Iron Contingency Plan
            [questKeys.requiredSkill] = {},
        },
        [29261] = { -- Zul'Aman Voodoo
            [questKeys.requiredSkill] = {},
        },
        [29262] = { -- Zul'Gurub Voodoo
            [questKeys.requiredSkill] = {},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{55490,55201},55490,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29871},
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
            [questKeys.preQuestGroup] = {29578,29579,29580}, -- 29585 is not needed
            [questKeys.preQuestSingle] = {},
        },
        [29587] = { -- Unbound
            [questKeys.objectives] = {nil,nil,nil,nil,{{{54990,61472},54990,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29611] = { -- The Art of War
            [questKeys.objectives] = {{{54870,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {25951,29612},
        },
        [29612] = { -- The Art of War
            [questKeys.objectives] = {{{54870,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.exclusiveTo] = {29611},
            [questKeys.preQuestSingle] = {25951},
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
            [questKeys.preQuestGroup] = {29624,29628,29629,29630,29637},
            [questKeys.exclusiveTo] = {29646,29647},
        },
        [29646] = { -- Flying Colors
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29624,29628,29629,29630,29637},
            [questKeys.exclusiveTo] = {29639,29647},
        },
        [29647] = { -- Flying Colors
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29624,29628,29629,29630,29637},
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
        [29727] = { -- SI:7 Report: Take No Prisoners
            [questKeys.preQuestSingle] = {29726},
            [questKeys.objectives] = {{{55408,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use it"),0,{{"object",209621}}}},
        },
        [29730] = { -- Scouting Report: Hostile Natives
            [questKeys.objectives] = {{{55378,nil,Questie.ICON_TYPE_EVENT},{55381,nil,Questie.ICON_TYPE_TALK}},{{209615}}},
            [questKeys.preQuestSingle] = {29971},
        },
        [29731] = { -- Scouting Report: On the Right Track
            [questKeys.preQuestSingle] = {29730},
            [questKeys.objectives] = {{{55770,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.objectives] = {{{55288},{55471,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.preQuestSingle] = {29750},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{39.42,13.13},{40.36,12.34},{41.11,10.94},{37.92,8.02},{38.84,10}}},Questie.ICON_TYPE_EVENT,l10n("Smash the Spirit Bottles")}},
        },
        [29754] = { -- To Bridge Earth and Sky
            [questKeys.finishedBy] = {{110006}},
            [questKeys.objectives] = {{{55892,nil,Questie.ICON_TYPE_EVENT}}},
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
        -- [29804] = { -- Seein' Red -- check if it also needs 27943
        [29815] = { -- Forensic Science
            [questKeys.objectives] = {nil,nil,{{74621}}},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Speak to Kiryn"),0,{{"monster",55688}}}},
        },
        [29824] = { -- Scouting Report: Like Jinyu in a Barrel
            [questKeys.preQuestSingle] = {29823},
            [questKeys.objectives] = {{{55667,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use it"),0,{{"object",209621}}}},
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
            [questKeys.preQuestSingle] = {30086,30087},
            [questKeys.breadcrumbForQuestId] = 29577,
        },
        [29872] = { -- Lin Tenderpaw
            [questKeys.preQuestSingle] = {30086,30087},
            [questKeys.breadcrumbForQuestId] = 29981,
        },
        [29873] = { -- Ken-Ken
            [questKeys.breadcrumbForQuestId] = 30079,
            [questKeys.preQuestSingle] = {30086,30087},
        },
        [29874] = { -- Kang Bramblestaff [Alliance]
            [questKeys.preQuestSingle] = {30086,30087},
        },
        [29875] = { -- Kang Bramblestaff [Horde]
            [questKeys.preQuestSingle] = {30086,30087},
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
            [questKeys.breadcrumbs] = {32018,32019},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56344,56343},56343,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56572,56571},56571,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.preQuestSingle] = {29723},
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
            [questKeys.preQuestSingle] = {29930},
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
            [questKeys.preQuestGroup] = {29937},
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
            [questKeys.objectives] = {{{56538,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29948] = { -- Thieves to the Core
            [questKeys.preQuestSingle] = {29944},
        },
        [29949] = { -- Legacy
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29946,29947,29948},
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
            [questKeys.objectives] = {nil,{{212404,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29967] = { -- Boom Goes the Doonamite!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{56603,56624,56639,56644,56645},56603}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Rivett"),0,{{"monster",56525}}}},
        },
        [29968] = { -- Green-ish Energy
            [questKeys.preQuestSingle] = {29824},
        },
        [29971] = { -- The Scouts Return
            [questKeys.preQuestGroup] = {29939,29942,31239}, -- could also need 29933
        },
        [29981] = { -- Stemming the Swarm
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29872},
        },
        [29982] = { -- Evacuation Orders
            [questKeys.objectives] = {{{57120,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{57122,57121},57121,nil,Questie.ICON_TYPE_TALK},{{57124,57123},57123,nil,Questie.ICON_TYPE_TALK},{{57127,57126},57126,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29983] = { -- The Hidden Master
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29981,29982},
        },
        [29984] = { -- Unyielding Fists: Trial of Bamboo
            [questKeys.objectives] = {{{56797,nil,Questie.ICON_TYPE_INTERACT}}},
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
            [questKeys.objectives] = {{{56800,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29985,29986,29992},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Master Bruised Paw"),0,{{"monster",56714}}}},
        },
        [29989] = { -- Unyielding Fists: Trial of Stone
            [questKeys.objectives] = {{{56801,nil,Questie.ICON_TYPE_INTERACT}}},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take a ride to Dawn's Blossom"),0,{{"monster",60952}}}},
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
            [questKeys.preQuestGroup] = {30029,30030,30031},
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
            [questKeys.preQuestGroup] = {29951,29952},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{57306,57307,57308},57306,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Gai Lan"),0,{{"monster",57385}}}},
        },
        [30053] = { -- Hop Hunting
            [questKeys.preQuestSingle] = {30046},
            [questKeys.objectives] = {{{62377,nil,Questie.ICON_TYPE_TALK},{57385,nil,Questie.ICON_TYPE_TALK},{62385,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.finishedBy] = {{110012}},
        },
        [30054] = { -- Enough is Ookin' Enough
            [questKeys.preQuestSingle] = {30046},
        },
        [30055] = { -- Stormstout's Hops
            [questKeys.startedBy] = {{56133}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30047,30050,30052,30053,30054,30057,30172},
        },
        [30056] = { -- The Farmer's Daughter
            [questKeys.preQuestSingle] = {30046},
        },
        [30057] = { -- Seeing Orange
            [questKeys.objectives] = {{{62385,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30065] = { -- Arrows of Fortune
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30066] = { -- Hidden Power
            [questKeys.objectives] = {nil,nil,nil,nil,{{{57316,57326,57400},57316,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30067] = { -- The Shadow of Doubt
            [questKeys.exclusiveTo] = {30068},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30068] = { -- Flames of the Void
            [questKeys.exclusiveTo] = {30067},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",57871}}}},
        },
        [30069] = { -- No Plan Survives Contact with the Enemy
            [questKeys.preQuestSingle] = {31733},
        },
        [30070] = { -- The Fall of Ga'trul
            [questKeys.preQuestGroup] = {31741,31742,31743,31744},
        },
        [30072] = { -- Where Silk Comes From
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {32035}, -- ingame bug
        },
        [30073] = { -- The Emperor
            [questKeys.preQuestSingle] = {30055}, -- there are more!!!!
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
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),0,{{"monster",56133}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Mudmug"),1,{{"monster",58027}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Li Li"),2,{{"monster",58028}}},
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chen"),3,{{"monster",58029}}},
            },
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
            [questKeys.exclusiveTo] = {30079,29981,29577,30087}, -- need to find followups for Kang Bramblestaff quests 29874A/29875H
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
            [questKeys.preQuestSingle] = {},
            [questKeys.exclusiveTo] = {30179},
        },
        [30123] = { -- Skitterer Stew
            [questKeys.preQuestSingle] = {30179},
        },
        [30124] = { -- Blind Them!
            [questKeys.preQuestSingle] = {30179},
        },
        [30127] = { -- Threat from Dojan
            [questKeys.preQuestGroup] = {30123,30124},
            [questKeys.nextQuestInChain] = 0,
        },
        [30128] = { -- The Pools of Youth
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Na Lek"),0,{{"monster",55597}}}},
        },
        [30129] = { -- The Mogu Agenda
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30123,30124},
        },
        [30130] = { -- Herbal Remedies
            [questKeys.preQuestGroup] = {30123,30124},
        },
        [30131] = { -- Life
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30127,30128,30130},
            [questKeys.objectives] = {{{58113,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30133] = { -- Into the Wilds
            [questKeys.preQuestSingle] = {30090},
            [questKeys.objectives] = {{{59151,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredSourceItems] = {79825},
        },
        [30134] = { -- Wild Things
            [questKeys.breadcrumbs] = {31373,31375,32461},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,7}},
        },
        [30135] = { -- Beating the Odds
            [questKeys.nextQuestInChain] = 30136,
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,8}},
        },
        [30136] = { -- Empty Nests
            [questKeys.preQuestSingle] = {30134},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58243,58244,58220},58244,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{63.33,31.46},{63.87,30.06},{64.28,29.03},{64.87,26.46},{65.32,26.38},{64.9,28.9},{65.15,30.07},{65.62,30.2},{65.68,30.67},{65.78,31.25}}}, Questie.ICON_TYPE_EVENT, l10n("Return the hatchlings to the nests")}},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,8}},
        },
        [30137] = { -- Egg Collection
            [questKeys.preQuestSingle] = {30134},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,8}},
        },
        [30138] = { -- Choosing the One
            [questKeys.preQuestGroup] = {30135,30136,30137},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,7}},
        },
        [30139] = { -- The Rider's Journey
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30140,30141},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,7}},
        },
        [30140] = { -- The Rider's Journey
            [questKeys.startedBy] = {},
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30139,30141},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,7}},
        },
        [30141] = { -- The Rider's Journey
            [questKeys.startedBy] = {},
            [questKeys.preQuestSingle] = {30138},
            [questKeys.exclusiveTo] = {30139,30140},
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,7}},
        },
        [30142] = { -- It's A...
            [questKeys.preQuestSingle] = {30139,30140,30141},
            [questKeys.nextQuestInChain] = 30143,
            [questKeys.reputationReward] = {{factionIDs.ORDER_OF_THE_CLOUD_SERPENT,14}},
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
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30147] = { -- Fragments of the Past
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30148] = { -- Just a Flesh Wound
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
            [questKeys.objectives] = {{{58416,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {72985,72986},
        },
        [30149] = { -- A Feast for the Senses
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30150] = { -- Sweet as Honey
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30151] = { -- Catch!
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30152] = { -- The Sky Race
            [questKeys.preQuestGroup] = {30142,30187}, -- need to check if 30187 is good
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the event"), 0, {{"monster", 58420}}}},
            [questKeys.objectives] = {{{58438,nil,Questie.ICON_TYPE_EVENT},{58530}}},
        },
        [30154] = { -- The Easiest Way To A Serpent's Heart
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30155] = { -- Restoring the Balance
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30156] = { -- Feeding Time
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
            [questKeys.requiredSourceItems] = {79027,79028},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58348,58349,58350},58348,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30157] = { -- Emptier Nests
            [questKeys.preQuestSingle] = {30142},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58243,58244,58220},58244,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_JADE_FOREST] = {{63.33,31.46},{63.87,30.06},{64.28,29.03},{64.87,26.46},{65.32,26.38},{64.9,28.9},{65.15,30.07},{65.62,30.2},{65.68,30.67},{65.78,31.25}}}, Questie.ICON_TYPE_EVENT, l10n("Return the hatchlings to the nests")}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30158] = { -- Disarming the Enemy
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [30159] = { -- Preservation
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [30160] = { -- A Ruby Shard for Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.ELLA,23}},
        },
        [30163] = { -- For the Tribe
            [questKeys.preQuestSingle] = {30132},
            [questKeys.objectives] = {{{58608,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30164] = { -- The Stoneplow Convoy [Horde]
            [questKeys.preQuestGroup] = {30229,30230,30163},
            [questKeys.objectives] = {{{58955,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30172] = { -- Barreling Along
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Lead Mudmug back to Halfhill", {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{55.92,49.33}}}},
        },
        [30174] = { -- For Family
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30164,30175},
            [questKeys.objectives] = {{{58224}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kor Bloodtusk"),0,{{"monster",58670}}}},
        },
        [30175] = { -- The Mantid [Horde]
            [questKeys.preQuestGroup] = {30229,30230,30163},
        },
        [30178] = { -- Into the Wilds
            [questKeys.preQuestSingle] = {30090},
            [questKeys.objectives] = {{{59151,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredSourceItems] = {79825},
        },
        [30179] = { -- Poisoned! [Horde]
            [questKeys.preQuestSingle] = {},
        },
        [30184] = { -- Mushan Mastery: Darkhide
            [questKeys.preQuestSingle] = {30181},
        },
        [30185] = { -- Tortoise Mastery
            [questKeys.preQuestGroup] = {30182,30184},
        },
        [30186] = { -- Parental Mastery
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_TALK,l10n("Talk to Hemet"),0,{{"monster",58461}}},
                {{[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{21.9,74.18}}},Questie.ICON_TYPE_EVENT,l10n("Enter the underwater cave")},
            },
        },
        [30187] = { -- Flight Training: In Due Course
            [questKeys.objectives] = {{{58438,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",58440},{"monster",58441},{"monster",58442}}}},
        },
        [30188] = { -- Riding the Skies (Jade Cloud Serpent)
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,42000},
            [questKeys.preQuestGroup] = {30140,30187},
            [questKeys.exclusiveTo] = {31810,31811},
        },
        [30189] = { -- A Lovely Apple for Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.ELLA,23}},
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
            [questKeys.exclusiveTo] = {30192,30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
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
            [questKeys.exclusiveTo] = {30191,30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
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
            [questKeys.exclusiveTo] = {30232,30235,30236,30239,30263,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
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
            [questKeys.exclusiveTo] = {30235,30236,30238,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30200] = { -- In Ashen Webs
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30204] = { -- That's Not a Rock!
            [questKeys.startedBy] = {{58504}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30205] = { -- Runelocked
            [questKeys.startedBy] = {{63266}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30206] = { -- Runes in the Ruins
            [questKeys.startedBy] = {{63266}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30225] = { -- The Ashweb Matriarch
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs. offered after 30200+30228.
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
            [questKeys.exclusiveTo] = {30228},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30227] = { -- Wulon, the Granite Sentinel
            [questKeys.startedBy] = {{58503}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
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
            [questKeys.exclusiveTo] = {30226},
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
        },
        [30232] = { -- Ruffling Some Feathers
            [questKeys.startedBy] = {{58818}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30194,30263,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
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
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
            [questKeys.preQuestGroup] = {31245}, -- only shown if mistfall is 3rd hub
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30236,30239,30385,31294,31295,30237}, -- cant be an option if we have 30237 as daily in this hub
        },
        [30236] = { -- Aetha
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.objectives] = {{{244975}}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
            [questKeys.preQuestGroup] = {31245}, -- only shown if mistfall is 3rd hub
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {30235,30239,30385,31294,31295,30237}, -- cant be an option if we have 30237 as daily in this hub
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
            [questKeys.exclusiveTo] = {30196,30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30239] = { -- Lao-Fe the Slavebinder
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.objectives] = {{{246479}}},
            [questKeys.exclusiveTo] = {30235,30236,30385,31294,31295},
            [questKeys.preQuestGroup] = {31245,30237}, -- only shown if mistfall is 3rd hub
            [questKeys.preQuestSingle] = {},
        },
        [30240] = { -- Survival Ring: Flame
            [questKeys.startedBy] = {{59340}},
            [questKeys.finishedBy] = {{58743}},
            [questKeys.exclusiveTo] = {30242},
            [questKeys.preQuestSingle] = {30385, -- Setting Sun Garrison from 59338 Mistfall Peace
                                          31247, -- Setting Sun Garrison from 59343 Lake Peace
                                          31250, -- Setting Sun Garrison from 58408 Lake Attack
                                          31297, -- Setting Sun Garrison from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58967,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30241] = { -- Warn Stoneplow [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30174,30273},
            [questKeys.exclusiveTo] = {30376},
        },
        [30242] = { -- Survival Ring: Blades
            [questKeys.startedBy] = {{59340}},
            [questKeys.finishedBy] = {{58743}},
            [questKeys.exclusiveTo] = {30240},
            [questKeys.preQuestSingle] = {30385, -- Setting Sun Garrison from 59338 Mistfall Peace
                                          31247, -- Setting Sun Garrison from 59343 Lake Peace
                                          31250, -- Setting Sun Garrison from 58408 Lake Attack
                                          31297, -- Setting Sun Garrison from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{64895,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30243] = { -- Mantid Under Fire
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30245,30246,30266,30444}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Mount up"),0,{{"monster",64369}}}},
        },
        [30244] = { -- Along the Serpent's Spine
            [questKeys.startedBy] = {{58920}},
            [questKeys.finishedBy] = {{58920}},
            [questKeys.preQuestSingle] = {30243},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63974,63976},63974}}},
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
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,22}},
        },
        [30254] = { -- Learn and Grow II: Tilling and Planting
            [questKeys.preQuestSingle] = {30535},
            [questKeys.objectives] = {{{59985,nil,Questie.ICON_TYPE_INTERACT},{59990,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30255] = { -- Learn and Grow III: Tending Crops
            [questKeys.objectives] = {{{59987,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30256] = { -- Learn and Grow IV: Harvesting
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,24}},
        },
        [30257] = { -- Learn and Grow V: Halfhill Market
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,25},{factionIDs.GINA_MUDCLAW,19}},
        },
        [30258] = { -- Mung-Mung's Vote I: A Hozen's Problem
            [questKeys.preQuestSingle] = {31945}, -- Gina chain required for Mung Mung
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,14600}, -- available at 5600/12000 honored with Tillers
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,15}},
        },
        [30259] = { -- Mung-Mung's Vote II: Rotten to the Core
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,15}},
        },
        [30260] = { -- Growing the Farm I: The Weeds
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,9000},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30261] = { -- Roll Club: Serpent's Spine
            [questKeys.preQuestGroup] = {30306,30642,30240},
            [questKeys.exclusiveTo] = {30264},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.objectives] = {{{58704,nil,Questie.ICON_TYPE_TALK},{64897}}},
        },
        [30263] = { -- Clearing in the Forest
            [questKeys.startedBy] = {{59338}},
            [questKeys.preQuestSingle] = {31242, -- Mistfall Village from 58408 Pagoda
                                          31245, -- Mistfall Village from 59343 Lake Peace
                                          31249, -- Mistfall Village from 58408 Lake Attack
                                          },
            [questKeys.exclusiveTo] = {30194,30232,30235,30236,30239,30385,31294,31295}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30264] = { -- Enemy at the Gates
            [questKeys.startedBy] = {{58919}},
            [questKeys.exclusiveTo] = {30261},
            [questKeys.preQuestGroup] = {30306,30642,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.objectives] = {{{65336,nil,Questie.ICON_TYPE_MOUNT_UP},{63972},{64274},{64275}}},
        },
        [30265] = { -- Sparkle in the Eye
            [questKeys.startedBy] = {{59343}},
            [questKeys.preQuestSingle] = {31131},
            [questKeys.exclusiveTo] = {30291,30338},
        },
        [30266] = { -- Bloodied Skies
            [questKeys.startedBy] = {{59340}},
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30243,30244,30245,30444}, -- the other 2 groups of 2 quests in this hub stage
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use it"),0,{{"monster",64336}}}},
        },
        [30268] = { -- The Murksweats
            [questKeys.preQuestSingle] = {30269},
        },
        [30269] = { -- Unsafe Passage
            [questKeys.preQuestSingle] = {30133,30178},
            [questKeys.triggerEnd] = {"Accompany Koro to Crane Wing Refuge", {[zoneIDs.KRASARANG_WILDS] = {{43.86,36.77}}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Koro Mistwalker"),0,{{"monster",58547},{"monster",58978}}}},
            [questKeys.objectives] = {},
        },
        [30270] = { -- Blinding the Riverblades
            [questKeys.preQuestSingle] = {30269},
        },
        [30271] = { -- Sha Can Awe
            [questKeys.preQuestGroup] = {30268,30270,30694},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58968,58969,59297},59297,nil,Questie.ICON_TYPE_EVENT},},},
        },
        [30272] = { -- Striking the Rain
            [questKeys.preQuestGroup] = {30268,30270,30694},
        },
        [30273] = { -- In the House of the Red Crane
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30271,30272,30695},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Chi-Ji"),0,{{"monster",59653}}}},
        },
        [30274] = { -- The Arcanic Oubliette
            [questKeys.startedBy] = {{110013}},
        },
        [30277] = { -- The Crumbling Hall
            [questKeys.startedBy] = {{58503,59332}},
            [questKeys.finishedBy] = {{58503,59332}},
            [questKeys.objectives] = {nil,{{214477}},{{87790}}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestGroup] = {30642},
            --[questKeys.preQuestSingle] = {test}, -- offered after 30200+30228. 30298+30299.
            [questKeys.exclusiveTo] = {30280},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Deactivate Spirit Wall"),1,{{"object",214475},{"object",214476}}}},
        },
        [30280] = { -- The Thunder Below
            [questKeys.startedBy] = {{58503,59332}},
            [questKeys.finishedBy] = {{58503,59332}},
            --[questKeys.objectives] = {{{64965}}}, -- TO DO: check ID and Milau needs spawn anyway
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestGroup] = {30642},
            --[questKeys.preQuestSingle] = {31240,31244,31248,31294,31295,31296},
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
            [questKeys.exclusiveTo] = {30286,30296,30297,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30286] = { -- Backed Into a Corner
            [questKeys.startedBy] = {{59337}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.objectives] = {nil,nil,nil,nil,{{{64187,63949},63949,nil,Questie.ICON_TYPE_INTERACT}}}, -- both IDs need spawns
            [questKeys.exclusiveTo] = {30285,30296,30297,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30287] = { -- Mogu Make Poor House Guests
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.exclusiveTo] = {30289,30296,30297,31293,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30288] = { -- My Town, It's On Fire Again
            [questKeys.startedBy] = {{59336}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.requiredSourceItems] = {85950},
            [questKeys.objectives] = {{{63943,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {30296,30297,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30289] = { -- Freeing Mind and Body
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.objectives] = {{{64200,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {30287,30290,30296,30297,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [30290] = { -- Stonebound Killers
            [questKeys.startedBy] = {{58911}},
            [questKeys.preQuestSingle] = {31243, -- Attack on Mistfall Village from 58408 Pagoda
                                          31246, -- Attack on Mistfall Village from 59343 Lake Peace
                                          },
            [questKeys.objectives] = {nil,nil,nil,nil,{{{64186,63950},63950}}},
            [questKeys.exclusiveTo] = {30289,30296,30297,31293,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
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
            [questKeys.objectives] = {{{63219,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30296] = { -- Gaohun the Soul-Severer
            [questKeys.startedBy] = {{58911}},
            [questKeys.finishedBy] = {{58911}},
            [questKeys.objectives] = {{{245153}}},
            [questKeys.exclusiveTo] = {30297,31297,31296},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30297] = { -- Baolai the Immolator
            [questKeys.startedBy] = {{58911}},
            [questKeys.finishedBy] = {{58911}},
            [questKeys.objectives] = {{{245163}}},
            [questKeys.exclusiveTo] = {30296,31297,31296},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30298] = { -- Painting the Ruins Red
            [questKeys.startedBy] = {{59332}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63610,63611,63641},63610}}}, -- TO DO: check this
        },
        [30299] = { -- No Stone Unturned
            [questKeys.startedBy] = {{59334}},
            [questKeys.finishedBy] = {{59334}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30305},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63333,63447,63556,63674},63333}}}, -- TO DO: check this. 63333,63447 have no spawns atm
        },
        [30300] = { -- The Key to Success
            [questKeys.startedBy] = {{59334}},
            [questKeys.finishedBy] = {{59334}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30481},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,{{85582}},nil,{{{63640,63651,63652,63653,63654,63655,63656,63657},63640,nil,Questie.ICON_TYPE_EVENT}}}, -- 63651,63655 -> 63657 are the NPCs after you rescue them
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",213289}}}},
            [questKeys.reputationReward] = {{factionIDs.GOLDEN_LOTUS,33}},
        },
        [30301] = { -- Offering a Warm Welcome
            [questKeys.startedBy] = {{59332}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,{{210680,nil,Questie.ICON_TYPE_INTERACT}}}, -- not visible, use INTERACT icon
        },
        [30302] = { -- The Imperion Threat
            [questKeys.startedBy] = {{59332}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestGroup] = {30298,30301,30305,30481}, -- was available after only 30298 30299
            [questKeys.objectives] = {nil,nil,nil,nil,{{{246031,246032},246031}}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30304] = { -- Hard as a Rock
            [questKeys.startedBy] = {{58504}},
            [questKeys.preQuestSingle] = {31240, -- Guo-Lai Infestation from 59343 Lake Peace
                                          31248, -- The Ruins of Guo-Lai from 58408 Lake Attack
                                          31294, -- The Ruins of Guo-Lai from 59338 Mistfall Peace
                                          31296, -- The Ruins of Guo-Lai from 59337 Mistfall Attack
                                          },
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [30305] = { -- He Knows What He's Doing
            [questKeys.startedBy] = {{59333}},
            [questKeys.finishedBy] = {{59333}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30299},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            --[questKeys.objectives] = {}, -- TO DO: need to check this
        },
        [30306] = { -- The Battle Ring
            [questKeys.startedBy] = {{58919}},
            [questKeys.finishedBy] = {{58962}},
            [questKeys.preQuestSingle] = {30385, -- Setting Sun Garrison from 59338 Mistfall Peace
                                          31247, -- Setting Sun Garrison from 59343 Lake Peace
                                          31250, -- Setting Sun Garrison from 58408 Lake Attack
                                          31297, -- Setting Sun Garrison from 59337 Mistfall Attack
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
            [questKeys.preQuestSingle] = {30257},
            [questKeys.objectives] = {{{59574,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Borrow a kite"),0,{{"monster",60231}}}},
            [questKeys.exclusiveTo] = {30318,30319,30321,30322},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.FARMER_FUNG,11}},
        },
        [30318] = { -- Chasing the Chicken
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30317,30319,30321,30322},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.OLD_HILLPAW,19}},
        },
        [30319] = { -- Pest Problems
            [questKeys.startedBy] = {{57402}},
            [questKeys.preQuestSingle] = {30257},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Wika-Wika"),0,{{"monster",59532}}}},
            [questKeys.exclusiveTo] = {30317,30318,30321,30322},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.HAOHAN_MUDCLAW,20}},
        },
        [30320] = { -- Free Spirits
            [questKeys.startedBy] = {{58468}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {30312,31755},
            [questKeys.objectives] = {{{59231,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Phase into the Spirit Void"),0,{{"monster",59219}}}},
            [questKeys.requiredSpell] = 115913,
        },
        [30321] = { -- Weed War II
            [questKeys.preQuestSingle] = {30257},
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,9000},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",57385}}}},
            [questKeys.exclusiveTo] = {30317,30318,30319,30322},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.JOGU_THE_DRUNK,11}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{57306,57307,57308},57306,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30322] = { -- Money Matters
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30317,30318,30319,30321},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.GINA_MUDCLAW,18}},
            [questKeys.objectives] = {nil,nil,{{80213,nil,Questie.ICON_TYPE_TALK},{80214,nil,Questie.ICON_TYPE_TALK},{80215,nil,Questie.ICON_TYPE_TALK},{80216,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30323] = { -- They Don't Even Wear Them
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30324,30325,30326,30327},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.TINA_MUDCLAW,11}},
        },
        [30324] = { -- Not in Chee-Chee's Backyard
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30323,30325,30326,30327},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.CHEE_CHEE,11}},
        },
        [30325] = { -- Where it Counts
            [questKeys.preQuestSingle] = {30257},
            [questKeys.objectives] = {{{59123}},{{210890},{210955}}},
            [questKeys.exclusiveTo] = {30323,30324,30326,30327},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.SHO,11}},
        },
        [30326] = { -- The Kunzen Legend-Chief
            [questKeys.startedBy] = {{58705}},
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30323,30324,30325,30327},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.FISH_FELLREED,11}},
        },
        [30327] = { -- You Have to Burn the Ropes
            [questKeys.preQuestSingle] = {30257},
            [questKeys.objectives] = {nil,{{210760}}},
            [questKeys.exclusiveTo] = {30323,30324,30325,30326},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.ELLA,11}},
        },
        [30328] = { -- The Thousand-Year Dumpling
            [questKeys.preQuestGroup] = {30257,31279},
            [questKeys.exclusiveTo] = {30329,30330,30331,30332},
        },
        [30329] = { -- Cindergut Peppers
            [questKeys.preQuestGroup] = {30257,31279},
            [questKeys.exclusiveTo] = {30328,30330,30331,30332},
        },
        [30330] = { -- The Truffle Shuffle
            [questKeys.preQuestGroup] = {30257,31279},
            [questKeys.exclusiveTo] = {30328,30329,30331,30332},
            [questKeys.objectives] = {{{59168,nil,Questie.ICON_TYPE_EVENT}},nil,{{79833}}},
        },
        [30331] = { -- The Mile-High Grub
            [questKeys.preQuestGroup] = {30257,31279},
            [questKeys.exclusiveTo] = {30328,30329,30330,30332},
        },
        [30332] = { -- Fatty Goatsteak
            [questKeys.preQuestGroup] = {30257,31279},
            [questKeys.exclusiveTo] = {30328,30329,30330,30331},
        },
        [30333] = { -- The Lesser of Two Evils
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30334,30335,30336,30337},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,16}},
        },
        [30334] = { -- Stealing is Bad... Re-Stealing is OK
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30335,30336,30337},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,16}},
        },
        [30335] = { -- Stalling the Ravage
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30334,30336,30337},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,16}},
        },
        [30336] = { -- The Kunzen Hunter-Chief
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30334,30335,30337},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,16}},
        },
        [30337] = { -- Simian Sabotage
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30333,30334,30335,30336},
            [questKeys.objectives] = {{{59276,nil,Questie.ICON_TYPE_INTERACT},{59278,nil,Questie.ICON_TYPE_INTERACT},{59279,nil,Questie.ICON_TYPE_INTERACT},{59280,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,16}},
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
        [30346] = { -- Where are the Pools
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30344,30350,30384},
        },
        [30347] = { -- The Pools of Youth
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Na Lek"),0,{{"monster",55597}}}},
        },
        [30348] = { -- Immortality?
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30346,30347,30349,30351},
            [questKeys.objectives] = {{{58745,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30349] = { -- Threat from Dojan
            [questKeys.preQuestGroup] = {30344,30350,30384},
        },
        [30350] = { -- Squirmy Delight
            [questKeys.preQuestSingle] = {30274},
        },
        [30351] = { -- Lotus Tea
            [questKeys.preQuestGroup] = {30344,30350,30384},
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
            [questKeys.objectives] = {{{58224}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Lyalia"),0,{{"monster",58976}}}},
        },
        [30360] = { -- Warn Stoneplow [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30273,30445},
            [questKeys.exclusiveTo] = {30376},
        },
        [30361] = { -- The Mantid [Alliance]
            [questKeys.preQuestGroup] = {30354,30355,30356},
        },
        [30363] = { -- Going on the Offensive
            [questKeys.preQuestSingle] = {30348},
            [questKeys.exclusiveTo] = {30465},
        },
        [30379] = { -- A Ruby Shard for Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.GINA_MUDCLAW,23}},
        },
        [30380] = { -- A Lovely Apple for Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.GINA_MUDCLAW,23}},
        },
        [30381] = { -- A Jade Cat for Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.ELLA,22}},
        },
        [30382] = { -- A Blue Feather for Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.ELLA,23}},
        },
        [30383] = { -- A Marsh Lily for Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.ELLA,23}},
        },
        [30384] = { -- Blind Them!
            [questKeys.preQuestSingle] = {30274},
        },
        [30385] = { -- Setting Sun Garrison -- Mistfall Peace to Garrison lead out
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{58919}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31245,31249,31294,31295}, -- 31245,31249 to not show this one if mistfall is 3rd hub
        },
        [30386] = { -- A Dish for Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1275,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.ELLA,17}},
        },
        [30387] = { -- A Jade Cat for Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.GINA_MUDCLAW,23}},
        },
        [30388] = { -- A Blue Feather for Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.GINA_MUDCLAW,23}},
        },
        [30389] = { -- A Marsh Lily for Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.GINA_MUDCLAW,22}},
        },
        [30390] = { -- A Dish for Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1281,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.GINA_MUDCLAW,17}},
        },
        [30391] = { -- A Ruby Shard for Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.OLD_HILLPAW,23}},
        },
        [30392] = { -- A Lovely Apple for Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.OLD_HILLPAW,23}},
        },
        [30393] = { -- A Jade Cat for Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.OLD_HILLPAW,23}},
        },
        [30394] = { -- A Blue Feather for Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.OLD_HILLPAW,22}},
        },
        [30395] = { -- A Marsh Lily for Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.OLD_HILLPAW,23}},
        },
        [30396] = { -- A Dish for Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1276,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.OLD_HILLPAW,17}},
        },
        [30397] = { -- A Ruby Shard for Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,23}},
        },
        [30398] = { -- A Lovely Apple for Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,23}},
        },
        [30399] = { -- A Jade Cat for Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,23}},
        },
        [30400] = { -- A Blue Feather for Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,22}},
        },
        [30401] = { -- A Marsh Lily for Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,23}},
        },
        [30402] = { -- A Dish for Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1277,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,17}},
        },
        [30403] = { -- A Ruby Shard for Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.SHO,23}},
        },
        [30404] = { -- A Lovely Apple for Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.SHO,22}},
        },
        [30405] = { -- A Jade Cat for Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.SHO,23}},
        },
        [30406] = { -- A Blue Feather for Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.SHO,23}},
        },
        [30407] = { -- A Marsh Lily for Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.SHO,23}},
        },
        [30408] = { -- A Dish for Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1278,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.SHO,17}},
        },
        [30409] = { -- A Ruby Shard for Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.HAOHAN_MUDCLAW,22}},
        },
        [30410] = { -- A Lovely Apple for Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.HAOHAN_MUDCLAW,23}},
        },
        [30411] = { -- A Jade Cat for Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.HAOHAN_MUDCLAW,23}},
        },
        [30412] = { -- A Blue Feather for Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.HAOHAN_MUDCLAW,23}},
        },
        [30413] = { -- A Marsh Lily for Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.HAOHAN_MUDCLAW,23}},
        },
        [30414] = { -- A Dish for Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1279,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.HAOHAN_MUDCLAW,17}},
        },
        [30416] = { -- A Ruby Shard for Farmer Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FARMER_FUNG,23}},
        },
        [30417] = { -- A Lovely Apple for Farmer Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FARMER_FUNG,23}},
        },
        [30418] = { -- A Jade Cat for Farmer Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FARMER_FUNG,23}},
        },
        [30419] = { -- A Blue Feather for Farmer Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FARMER_FUNG,23}},
        },
        [30420] = { -- A Marsh Lily for Farmer Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FARMER_FUNG,22}},
        },
        [30421] = { -- A Dish for Farmer Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1283,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FARMER_FUNG,17}},
        },
        [30422] = { -- A Ruby Shard for Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FISH_FELLREED,23}},
        },
        [30423] = { -- A Lovely Apple for Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FISH_FELLREED,23}},
        },
        [30424] = { -- A Jade Cat for Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FISH_FELLREED,22}},
        },
        [30425] = { -- A Blue Feather for Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FISH_FELLREED,23}},
        },
        [30426] = { -- A Marsh Lily for Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FISH_FELLREED,23}},
        },
        [30427] = { -- A Dish for Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1282,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.FISH_FELLREED,17}},
        },
        [30428] = { -- A Ruby Shard for Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,22}},
        },
        [30429] = { -- A Lovely Apple for Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,23}},
        },
        [30430] = { -- A Jade Cat for Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,23}},
        },
        [30431] = { -- A Blue Feather for Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,23}},
        },
        [30432] = { -- A Marsh Lily for Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,23}},
        },
        [30433] = { -- A Dish for Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1280,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,17}},
        },
        [30434] = { -- A Ruby Shard for Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,23}},
        },
        [30435] = { -- A Lovely Apple for Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,22}},
        },
        [30436] = { -- A Jade Cat for Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,23}},
        },
        [30437] = { -- A Blue Feather for Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,23}},
        },
        [30438] = { -- A Marsh Lily for Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,23}},
        },
        [30439] = { -- A Dish for Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMaxRep] = {1273,42000}, -- Not available at Best Friend
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,17}},
        },
        [30444] = { -- No Reprieve
            [questKeys.startedBy] = {{58919}},
            [questKeys.preQuestGroup] = {30306,30240},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {30243,30244,30246,30266}, -- the other 2 groups of 2 quests in this hub stage
        },
        [30445] = { -- The Waters of Youth
            [questKeys.objectives] = {{{58970,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30449] = { -- Darkmoon Crane Deck
            [questKeys.startedBy] = {nil,nil,{79325}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30450] = { -- Darkmoon Ox Deck
            [questKeys.startedBy] = {nil,nil,{79324}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30451] = { -- Darkmoon Serpent Deck
            [questKeys.startedBy] = {nil,nil,{79326}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [30452] = { -- Darkmoon Tiger Deck
            [questKeys.startedBy] = {nil,nil,{79323}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
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
        },
        [30467] = { -- My Son...
            [questKeys.breadcrumbs] = {31451,31452},
        },
        [30470] = { -- A Gift For Tina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30471,30472,30473,30474,30475,30476,30477,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.TINA_MUDCLAW,10}},
        },
        [30471] = { -- A Gift For Chee Chee
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30472,30473,30474,30475,30476,30477,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.CHEE_CHEE,10}},
        },
        [30472] = { -- A Gift For Sho
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30473,30474,30475,30476,30477,30478,30479},
            [questKeys.objectives] = {nil,{{210873,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.SHO,10}},
        },
        [30473] = { -- A Gift For Fish
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30474,30475,30476,30477,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.FISH_FELLREED,10}},
        },
        [30474] = { -- A Gift For Ella
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30475,30476,30477,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.ELLA,10}},
        },
        [30475] = { -- A Gift For Fung
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30476,30477,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.FARMER_FUNG,10}},
            [questKeys.requiredSourceItems] = {80232},
            [questKeys.objectives] = {nil,nil,{{80233,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30476] = { -- A Gift For Old Hillpaw
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30477,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.OLD_HILLPAW,10}},
        },
        [30477] = { -- A Gift For Haohan
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30476,30478,30479},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.HAOHAN_MUDCLAW,10}},
        },
        [30478] = { -- A Gift For Jogu
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30476,30477,30479},
            [questKeys.requiredSourceItems] = {80234,80235},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.JOGU_THE_DRUNK,10}},
            [questKeys.objectives] = {nil,nil,{{80236,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30479] = { -- A Gift For Gina
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {30470,30471,30472,30473,30474,30475,30476,30477,30478},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,4},{factionIDs.GINA_MUDCLAW,10}},
        },
        [30480] = { -- The Ritual
            [questKeys.preQuestGroup] = {30468,30496,30967},
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{60973,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{61655,61656},61655,nil,Questie.ICON_TYPE_EVENT},{{61530},61530}}},
        },
        [30481] = { -- Carved in Stone
            [questKeys.startedBy] = {{59333}},
            [questKeys.finishedBy] = {{59333}},
            [questKeys.preQuestSingle] = {31244, -- Guo-Lai Encampment from 59343 Lake Peace
                                          31295, -- Mogu within the Ruins of Guo-Lai 59338 from Mistfall Peace
                                          },
            [questKeys.exclusiveTo] = {30300},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {nil,nil,{{85278}}},
        },
        [30482] = { -- The Soul-Gatherer
            [questKeys.startedBy] = {{58470}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31136,31248,31249,31250},
        },
        [30484] = { -- Gauging Our Progress
            [questKeys.objectives] = {nil,nil,{{80013,nil,Questie.ICON_TYPE_TALK},{80014,nil,Questie.ICON_TYPE_TALK},{80015,nil,Questie.ICON_TYPE_TALK},{80061,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.breadcrumbs] = {30499},
            [questKeys.preQuestSingle] = {30000},
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
        [30490] = { -- Yakity Yak
            [questKeys.startedBy] = {{110017}},
            [questKeys.preQuestSingle] = {30488},
            [questKeys.exclusiveTo] = {30587},
        },
        [30491] = { -- At the Yak Wash
            [questKeys.extraObjectives] = {{{[zoneIDs.KUN_LAI_SUMMIT] = {{71.32,69.2}}},Questie.ICON_TYPE_EVENT,l10n("Bring the yaks here")}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59662,61874,59319},59319,nil,Questie.ICON_TYPE_MOUNT_UP}}},
        },
        [30492] = { -- Back in Yak
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30491,30587},
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Bring Yak Herd to Lucky Eightcoins", {[zoneIDs.KUN_LAI_SUMMIT] = {{65.38,61.45}}}},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Borrow a kite"),0,{{"monster",59727}}}},
        },
        [30499] = { -- Get Back Here! (Horde)
            [questKeys.preQuestSingle] = {30000},
            [questKeys.breadcrumbForQuestId] = 30484,
        },
        [30502] = { -- Jaded Heart
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59434,59454},59454}}},
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
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,9000},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30517] = { -- Farmer Fung's Vote I: Yak Attack
            [questKeys.preQuestSingle] = {31946}, -- Mung Mung chain required for Farmer Fung
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,25200}, -- Tillers 4200 into Revered (wowhead)
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,5},{factionIDs.FARMER_FUNG,8}},
        },
        [30518] = { -- Farmer Fung's Vote II: On the Loose
            [questKeys.extraObjectives] = {{{[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{50.44,34.33}}},Questie.ICON_TYPE_EVENT,l10n("Bring the yaks here")}},
            [questKeys.objectives] = {{{59491,nil,Questie.ICON_TYPE_MOUNT_UP}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,5},{factionIDs.FARMER_FUNG,21}},
        },
        [30519] = { -- Nana's Vote I: Nana's Secret Recipe
            [questKeys.preQuestSingle] = {31947}, -- Farmer Fung chain required for Nana
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,29400}, -- Tillers 8400 into Revered (wowhead)
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,15}},
        },
        [30521] = { -- Haohan's Vote I: Bungalow Break-In
            [questKeys.preQuestSingle] = {31949}, -- Nana chain required for Haohan
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,37800}, -- Tillers 16800 into Revered (wowhead)
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,12},{factionIDs.HAOHAN_MUDCLAW,11}},
        },
        [30522] = { -- Haohan's Vote II: The Real Culprits
            [questKeys.objectives] = {{{59505,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,12}},
        },
        [30523] = { -- Growing the Farm II: The Broken Wagon
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,21000}, -- Tillers at Revered (wowhead)
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30524] = { -- Growing the Farm II: Knock on Wood
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30525] = { -- Haohan's Vote III: Pure Poison
            [questKeys.preQuestSingle] = {30522},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,12}},
        },
        [30526] = { -- Lost and Lonely
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,33600}, -- Tillers 12600 into Revered (wowpedia)
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
        },
        [30527] = { -- Haohan's Vote IV: Melons For Felons
            [questKeys.objectives] = {nil,nil,{{74848}},nil,{{{66123,66128,66129},66129,nil,Questie.ICON_TYPE_INTERACT},{{58563},58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30525},
            [questKeys.requiredSourceItems] = {89329,89849},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,12}},
        },
        [30528] = { -- Haohan's Vote V: Chief Yip-Yip
            [questKeys.preQuestSingle] = {30527},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,8}},
        },
        [30529] = { -- Growing the Farm III: The Mossy Boulder
            [questKeys.preQuestSingle] = {30528},
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,42000}, -- Tillers at Exalted
        },
        [30534] = { -- A Second Hand
            [questKeys.preQuestSingle] = {30529},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{57298,57402,58647,58705,58706,58707,58708,58709,58710,58761},57298,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30535] = { -- Learn and Grow I: Seeds
            [questKeys.preQuestSingle] = {30252},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,7}},
            [questKeys.objectives] = {nil,nil,{{80295,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30565] = { -- An Unexpected Advantage
            [questKeys.preQuestSingle] = {30000},
        },
        [30568] = { -- Helping the Cause
            [questKeys.preQuestSingle] = {30000},
            [questKeys.objectives] = {{{59572},{59562},{59609,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.objectives] = {{{59577,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30575] = { -- Round 'Em Up
            [questKeys.preQuestSingle] = {30514},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59610,59611},59610,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.KUN_LAI_SUMMIT] = {{54.26,84.01}}},Questie.ICON_TYPE_EVENT,l10n("Bring the yaks here")}},
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
        [30587] = { -- Yakity Yak
            [questKeys.startedBy] = {{110017}},
            [questKeys.preQuestSingle] = {30488},
            [questKeys.exclusiveTo] = {30490},
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
        [30592] = { -- The Burlap Trail: To Burlap Waystation
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Escort grummles to the Burlap Waystation", {[zoneIDs.KUN_LAI_SUMMIT] = {{52.95,66.57}}}},
        },
        [30593] = { -- Deanimate the Reanimated
            [questKeys.preQuestSingle] = {30514},
        },
        [30594] = { -- Deanimate the Reanimated
            [questKeys.preQuestSingle] = {30515},
        },
        [30595] = { -- Profiting off of the Past
            [questKeys.preQuestSingle] = {30514,30515},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60382,59818},59818,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30602] = { -- The Rabbitsfoot
            [questKeys.startedBy] = {{59701,59703}},
            [questKeys.objectives] = {{{59806,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30603] = { -- The Broketooth Ravage
            [questKeys.startedBy] = {{59452,59806}},
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
            [questKeys.objectives] = {{{59421,nil,Questie.ICON_TYPE_EVENT}},nil,{{80535}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Unlock the Ball and Chain"),0,{{"object",211365}}}},
        },
        [30608] = { -- The Snackrifice
            [questKeys.preQuestSingle] = {30605},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60027,60012},60012,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211307}}}},
        },
        [30610] = { -- Grummle! Grummle! Grummle!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30607,30608},
            [questKeys.objectives] = {nil,{{211686}}},
        },
        [30611] = { -- Unleash The Yeti!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30607,30608},
        },
        [30612] = { -- The Leader Hozen
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30610,30611},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59419,60217},59419,nil,Questie.ICON_TYPE_EVENT},{{60188,60598},60188}}},
        },
        [30613] = { -- Armored Carp
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30617] = { -- Roadside Assistance
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30614,30616,30808},
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
            [questKeys.finishedBy] = {{110016}},
            [questKeys.preQuestSingle] = {30241,30360,30376}, -- any of the (mandatory) breadcrumbs that trigger the mantid invasion phase in western four winds
            [questKeys.objectives] = {{{59874}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Use Ken-Ken's Mask on Ik'thik Wing Commander"),0,{{"monster",56723}}}},
        },
        [30624] = { -- It Does You No Good Inside The Keg
            [questKeys.finishedBy] = {{110016}},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Miss Fanny"),0,{{"monster",59857}}}},
        },
        [30631] = { -- The Shrine of Seven Stars
            [questKeys.startedBy] = {{58468}},
            [questKeys.finishedBy] = {{58468,64031}},
            [questKeys.preQuestSingle] = {31512},
            [questKeys.objectives] = {{{59908,nil,Questie.ICON_TYPE_TALK},{59961,nil,Questie.ICON_TYPE_TALK},{64149,nil,Questie.ICON_TYPE_TALK},{64029,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30632] = { -- The Ruins of Guo-Lai
            [questKeys.startedBy] = {{58408}},
            [questKeys.requiredSpell] = 115913,
            [questKeys.breadcrumbs] = {31384,31385},
        },
        [30633] = { -- Out with the Scouts
            [questKeys.startedBy] = {{58465}},
            [questKeys.objectives] = {{{59914}}},
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
            [questKeys.preQuestSingle] = {30638},
            [questKeys.startedBy] = {{58408,59332,59340}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.objectives] = {{{64647,nil,Questie.ICON_TYPE_TALK},{64663,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30640] = { -- Battle Spear of the Thunder King
            [questKeys.preQuestSingle] = {30639},
            [questKeys.startedBy] = {{59905}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
        },
        [30641] = { -- Battle Helm of the Thunder King
            [questKeys.startedBy] = {{59905}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.preQuestSingle] = {30640},
            [questKeys.objectives] = {{{64889,nil,Questie.ICON_TYPE_TALK}},nil,{{80222}}},
        },
        [30642] = { -- Battle Axe of the Thunder King
            [questKeys.startedBy] = {{59905}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,21000},
            [questKeys.preQuestSingle] = {30641},
            [questKeys.objectives] = {{{60376,nil,Questie.ICON_TYPE_EVENT}},nil,{{80807}}},
        },
        [30643] = { -- The Mogu's Message
            [questKeys.startedBy] = {{58408,59332,59340}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,42000},
            [questKeys.preQuestSingle] = {30642},
        },
        [30644] = { -- What Comes to Pass
            [questKeys.startedBy] = {{59905}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,42000},
            [questKeys.preQuestSingle] = {30643},
        },
        [30645] = { -- The Might of Three
            [questKeys.startedBy] = {{58468}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,42000},
            [questKeys.preQuestSingle] = {30644},
        },
        [30646] = { -- The Final Power
            [questKeys.startedBy] = {{59906}},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,42000},
        },
        [30648] = { -- Moving On
            [questKeys.finishedBy] = {{110007}},
            [questKeys.objectives] = {{{59899,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {30504,31319}, -- became available after 30504/31319 only
        },
        [30649] = { -- The Shrine of Two Moons
            [questKeys.startedBy] = {{58468}},
            [questKeys.finishedBy] = {{58468,64007}},
            [questKeys.objectives] = {{{59908,nil,Questie.ICON_TYPE_TALK},{59959,nil,Questie.ICON_TYPE_TALK},{62996,nil,Questie.ICON_TYPE_TALK},{63996,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31511},
        },
        [30650] = { -- Pandaren Prisoners [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31252,30619},
            [questKeys.objectives] = {{{60038,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30651] = { -- Barrels of Fun [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31252,30619},
            [questKeys.requiredSourceItems] = {80528},
            [questKeys.objectives] = {{{60096,nil,Questie.ICON_TYPE_INTERACT},{60098,nil,Questie.ICON_TYPE_INTERACT},{60099,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30652] = { -- In Tents Channeling [Alliance]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31252,30619},
        },
        [30653] = { -- It Does You No Good Inside The Keg
            [questKeys.preQuestSingle] = {30241,30376}, -- any of the (mandatory) breadcrumbs that trigger the mantid invasion phase in western four winds
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59844,59845},59844,nil,Questie.ICON_TYPE_EVENT},{{59846,59847,59848},59846,nil,Questie.ICON_TYPE_EVENT},{{59829,59830,59831},59829,nil,Questie.ICON_TYPE_EVENT},{{59851,59853},59851,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30655] = { -- Pandaren Prisoners [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31253,30620},
            [questKeys.objectives] = {{{60038,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30656] = { -- Barrels of Fun [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31253,30620},
            [questKeys.requiredSourceItems] = {80528},
            [questKeys.objectives] = {{{60096,nil,Questie.ICON_TYPE_INTERACT},{60098,nil,Questie.ICON_TYPE_INTERACT},{60099,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30657] = { -- In Tents Channeling [Horde]
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31253,30620},
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
            [questKeys.startedBy] = {{59441}},
            [questKeys.exclusiveTo] = {30660},
            [questKeys.preQuestSingle] = {30652},
        },
        [30663] = { -- The Ordo Warbringer
            [questKeys.startedBy] = {{59442}},
            [questKeys.exclusiveTo] = {30661},
            [questKeys.preQuestSingle] = {30657},
        },
        [30665] = { -- The Defense of Shado-Pan Fallback
            [questKeys.preQuestGroup] = {30457,30459,30460},
            [questKeys.breadcrumbs] = {31453,31455},
        },
        [30670] = { -- Turnabout
            [questKeys.preQuestSingle] = {30457},
        },
        [30672] = { -- Balance
            [questKeys.preQuestSingle] = {30671},
        },
        [30674] = { -- Balance Without Violence
            [questKeys.startedBy] = {{110014}},
            [questKeys.finishedBy] = {{110015}},
            [questKeys.preQuestSingle] = {30671},
            [questKeys.objectives] = {{{60367,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30675] = { -- Buried Hozen Treasure
            [questKeys.finishedBy] = {{110015}},
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
            [questKeys.preQuestGroup] = {30268,30270,30694},
        },
        [30698] = { -- Scavenger Hunt
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Use the raft"),0,{{"object",211596}}}},
        },
        [30700] = { -- Snapclaw
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30701] = { -- Viseclaw Soup
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30715] = { -- A Line Unbroken
            [questKeys.preQuestSingle] = {30699},
            [questKeys.objectives] = {{{61808,nil,Questie.ICON_TYPE_INTERACT},{61806,nil,Questie.ICON_TYPE_INTERACT},{61810,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [30716] = { -- Chasing Hope
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.objectives] = {{{60487,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30717] = { -- Gifts of the Great Crane
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
        },
        [30718] = { -- Students of Chi-Ji
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
        },
        [30724] = { -- To the Wall!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30715,30723},
            [questKeys.objectives] = {{{61512,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30725] = { -- Ellia Ravenmane
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30726] = { -- Minh Do-Tan
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30727] = { -- Ellia Ravenmane: Rematch
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30728] = { -- Fat Long-Fat
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30729] = { -- Julia Bates
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30730] = { -- Dextrous Izissha
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30731] = { -- Kuo-Na Quillpaw
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30732,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30732] = { -- Ellia Ravenmane: Revenge
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30733,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30733] = { -- Tukka-Tuk
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30734,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30734] = { -- Huck Wheelbarrow
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30735,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30735] = { -- Mindel Sunspeaker
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30736,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30736] = { -- Yan Quillpaw
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30737,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30737] = { -- Fat Long-Fat: Rematch
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30738,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30738] = { -- Thelonius
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30739,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30739] = { -- Ellia Ravenmane: Redemption
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30740},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30740] = { -- Champion of Chi-Ji
            [questKeys.preQuestGroup] = {30716,30717,30718}, -- this is available without 31511/31512
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
        [30746] = { -- A Fair Trade
            [questKeys.preQuestSingle] = {30744,30825},
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
            [questKeys.exclusiveTo] = {31386,31388,31695}, -- this might be exclusive to 31695, but not viceversa
            [questKeys.breadcrumbForQuestId] = 30814,
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
            [questKeys.preQuestGroup] = {30769,30770,30771},
        },
        [30773] = { -- Pitching In
            [questKeys.objectives] = {{{60705,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30769,30770,30771},
        },
        [30774] = { -- Ranger Rescue
            [questKeys.preQuestGroup] = {30769,30770,30771},
            [questKeys.requiredSourceItems] = {81178},
            [questKeys.objectives] = {{{60730,nil,Questie.ICON_TYPE_EVENT},{60899,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211511}}}},
        },
        [30775] = { -- The Exile
            [questKeys.preQuestGroup] = {30769,30770,30771},
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
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31894},
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
            [questKeys.objectives] = {nil,{{211968}},{{82764}}},
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
            [questKeys.breadcrumbs] = {30768,31386,31388},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Cho"),0,{{"monster",60795}}}},
        },
        [30834] = { -- Father and Child Reunion
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {30467},
            [questKeys.triggerEnd] = {"Reunite Wu-Peng and Merchant Shi", {[zoneIDs.KUN_LAI_SUMMIT] = {{74.92,88.72}}}},
        },
        [30879] = { -- Round 1: Brewmaster Chani
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30880},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30880] = { -- Round 1: The Streetfighter
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30879},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30881] = { -- Round 2: Clever Ashyo & Ken-Ken
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30882] = { -- Round 2: Kang Bramblestaff
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30883] = { -- Round 3: The Wrestler
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30884] = { -- Behind the Battlefront
            [questKeys.breadcrumbs] = {30785},
        },
        [30885] = { -- Round 3: Master Boom Boom
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30888] = { -- Breach in the Defenses
            [questKeys.preQuestSingle] = {30887},
        },
        [30889] = { -- Trap Setting
            [questKeys.objectives] = {{{61426,nil,Questie.ICON_TYPE_OBJECT}}},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Man a Dragon Launcher"),0,{{"monster",61746},{"monster",62024}}}},
        },
        [30902] = { -- Round 4: Master Windfur
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [30907] = { -- Round 4: The P.U.G
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
            [questKeys.objectives] = {{{62562,nil,Questie.ICON_TYPE_EVENT},{62534,nil,Questie.ICON_TYPE_EVENT},{62307}}},
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
            [questKeys.preQuestGroup] = {30921,30923},
        },
        [30930] = { -- Pick a Yak
            [questKeys.objectives] = {{{61635,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30929},
        },
        [30931] = { -- My Father's Crossbow
            [questKeys.preQuestGroup] = {30921,30923},
        },
        [30932] = { -- Father's Footsteps
            [questKeys.preQuestSingle] = {30931},
            [questKeys.objectives] = {{{61685,nil,Questie.ICON_TYPE_INTERACT},{61683,nil,Questie.ICON_TYPE_TALK}},{{211836},{211837}}},
        },
        [30933] = { -- Seeking Father
            [questKeys.preQuestSingle] = {30932},
            [questKeys.objectives] = {{{61694,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31039,31040,31041,31042,31043,31044,31045,31046,31047,31048,31049,31061,31062,31105,31106, -- Omnia dailies
                                       31113,31114,31116,31117,31118,31119,31120, -- Blackguard dailies
            },
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61417,61554,61381},61381,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30945] = { -- What's Yours Is Mine
            [questKeys.preQuestSingle] = {30935},
        },
        [30946] = { -- Revelations
            [questKeys.objectives] = {{{62629,nil,Questie.ICON_TYPE_TALK}}},
        },
        [30952] = { -- The Unending Siege
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {30956},
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
            [questKeys.exclusiveTo] = {30952},
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Use the cannon"),0,{{"monster",62747}}}},
        },
        [30981] = { -- Taoshi and Korvexxis
            [questKeys.preQuestSingle] = {31065},
        },
        [30982] = { -- Animal Control
            [questKeys.preQuestSingle] = {},
        },
        [30984] = { -- No Orc Left Behind
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61680,61780,61790},61680,nil,Questie.ICON_TYPE_EVENT}}},
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
            [questKeys.objectives] = {{{61819,nil,Questie.ICON_TYPE_TALK},{63603,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Ban"),2,{{"monster",61819}}}},
        },
        [30994] = { -- Lao-Chin's Gambit
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30750,30751},
        },
        [30995] = { -- No Man Left Behind
            [questKeys.objectives] = {nil,nil,nil,nil,{{{61788,61780,61790},61788,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",211883}}}},
        },
        [30999] = { -- Path Less Traveled
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {31459,31460},
        },
        [31000] = { -- Dread Space
            [questKeys.breadcrumbForQuestId] = 31001, -- check if it has any prequests
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
            [questKeys.objectives] = {{{62538,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31007] = { -- The Dread Clutches
            [questKeys.preQuestSingle] = {31006},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62538}}}},
        },
        [31008] = { -- Amber Arms
            [questKeys.preQuestSingle] = {31006},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62538}}}},
        },
        [31009] = { -- Dead Zone
            [questKeys.finishedBy] = {{110008}},
            [questKeys.objectives] = {nil,{{212524}}},
            [questKeys.preQuestSingle] = {31006},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Talk to Kil'ruk"),0,{{"monster",62538}}}},
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
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,28}},
        },
        [31016] = { -- The Lorewalkers
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.breadcrumbForQuestId] = 31015,
            [questKeys.exclusiveTo] = {31367,31368},
        },
        [31018] = { -- Beneath the Heart of Fear
            [questKeys.preQuestSingle] = {31066},
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
            [questKeys.preQuestGroup] = {31092,31359},
            [questKeys.exclusiveTo] = {31238,31494,31506}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31030] = { -- Into the Monastery
            [questKeys.exclusiveTo] = {31031},
            [questKeys.breadcrumbForQuestId] = 30757,
        },
        [31031] = { -- Into the Monastery
            [questKeys.preQuestSingle] = {30752},
            [questKeys.exclusiveTo] = {31030},
            [questKeys.breadcrumbForQuestId] = 30757,
            [questKeys.zoneOrSort] = zoneIDs.SHADO_PAN_MONASTERY,
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
            [questKeys.objectives] = {{{62380,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{62781,62834},62781}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,9000},
            [questKeys.exclusiveTo] = {31113,31114,31116,31117,31118,31119,31120, -- Blackguard dailies
                                       31196,31197,31198,31199,31200,31201,31203,31204, -- Wu Kao dailies
            },
        },
        [31039] = { -- The Mogu Menace
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31040] = { -- Spiteful Sprites
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31041] = { -- Egg Rescue!
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31042] = { -- Onyx Hearts
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31043] = { -- Dark Arts
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31044] = { -- Bronze Claws
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31045] = { -- Illusions Of The Past
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31046] = { -- Little Hatchlings
            [questKeys.objectives] = {{{62567,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",213571}}}}, -- there are way more object ids, but 1 should be enough
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31047] = { -- Born Free -- i saw this quest being offered early. last order 31042 31105 31043 31047. turn in 31047 first, see what happens
            [questKeys.objectives] = {{{62539,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31048] = { -- Grave Consequences
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Release Ancestors"),0,{{"object",212324}}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31049] = { -- In Sprite Of Everything
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31039,31040,31041,31046}, -- order 31039 31046 31041 31040 autoaccepted after last. turn in 31040 first
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31055] = { -- Between a Saurok and a Hard Place
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31058] = { -- The Funky Monkey Brew
            [questKeys.zoneOrSort] = zoneIDs.UNGA_INGOO,
        },
        [31061] = { -- Riding the Storm
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31042,31043,31047,31105}, -- might not need all
            [questKeys.objectives] = {nil,nil,nil,nil,{{{62311,62584,62585,62586},62311}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31062] = { -- When The Dead Speak
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31044,31045,31048,31106}, -- might not need all, turned 31106 last. turn others last
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
            [questKeys.preQuestSingle] = {31068},
        },
        [31073] = { -- Bound With Wood
            [questKeys.preQuestGroup] = {31069,31070},
        },
        [31074] = { -- Wood and Shade
            [questKeys.objectives] = {nil,{{212643,nil,Questie.ICON_TYPE_EVENT},{212642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31072},
        },
        [31075] = { -- Sunset Kings
            [questKeys.preQuestGroup] = {31071,31073,31074,31078},
        },
        [31076] = { -- Fate of the Stormstouts
            [questKeys.objectives] = {{{62666,nil,Questie.ICON_TYPE_TALK},{62667,nil,Questie.ICON_TYPE_TALK},{62845,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {31068},
            [questKeys.exclusiveTo] = {29907,31129},
        },
        [31077] = { -- Evie Stormstout
            [questKeys.finishedBy] = {{67138}},
            [questKeys.objectives] = {{{67138,nil,Questie.ICON_TYPE_EVENT}},{{440002,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31076,31129},
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
            [questKeys.extraObjectives] = {{{[zoneIDs.DREAD_WASTES] = {{36.86,17.44}}},Questie.ICON_TYPE_EVENT,l10n("Bring the Motherseeds here")}},
            [questKeys.objectives] = {{{62601,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31075},
        },
        [31083] = { -- Promises of Gold
            [questKeys.startedBy] = {{62767}},
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
            [questKeys.exclusiveTo] = {31441,31679},
        },
        [31088] = { -- Crime and Punishment
            [questKeys.preQuestSingle] = {31087},
            [questKeys.exclusiveTo] = {31680},
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
        [31093] = { -- Hozen in the Mist
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31094] = { -- Fish Tales
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31095] = { -- The Dark Heart of the Mogu
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31096] = { -- What is Worth Fighting For
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31097] = { -- Heart of the Mantid Swarm
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31100] = { -- The Song of the Yaungol
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31102] = { -- The Seven Burdens of Shaohao
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31103] = { -- The Ballad of Liu Lang
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,29}},
        },
        [31104] = { -- The Challenger's Ring: Yalia Sagewhisper
            [questKeys.objectives] = {{{62303,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{62850,62825},62825}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,21000},
            [questKeys.exclusiveTo] = {31113,31114,31116,31117,31118,31119,31120, -- Blackguard dailies
                                       31196,31197,31198,31199,31200,31201,31203,31204, -- Wu Kao dailies
            },
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
            [questKeys.startedBy] = {{62538,66800}},
            [questKeys.finishedBy] = {{62538,66800}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31111,31231,31267}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31111] = { -- Eradicating the Zan'thik
            [questKeys.startedBy] = {{62538,66800}},
            [questKeys.finishedBy] = {{62538,66800}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31109,31231,31267}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31113] = { -- Assault Fire Camp Gai-Cho
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31114] = { -- Assault Deadtalker's Plateau
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31116] = { -- Spirit Dust
            [questKeys.exclusiveTo] = {31118},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredSourceItems] = {84727},
            [questKeys.objectives] = {nil,{{212779}}},
        },
        [31117] = { -- Uruk!
            [questKeys.exclusiveTo] = {31120},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestGroup] = {31114,31116}, -- 31116 was last before being offered 31117. turn in 31116 1st next time
        },
        [31118] = { -- The Deadtalker Cipher
            [questKeys.exclusiveTo] = {31116},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31119] = { -- The Enemy of My Enemy... Is Still My Enemy!
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredSourceItems] = {84762},
        },
        [31120] = { -- Cheng Bo!
            [questKeys.exclusiveTo] = {31117},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestGroup] = {31113,31114,31119}, -- this one doesn't actually need 31116
        },
        [31121] = { -- Stay a While, and Listen
            [questKeys.objectives] = {nil,{{212900}}},
        },
        [31127] = { -- The Challenger's Ring: Chao the Voice
            [questKeys.objectives] = {{{62550,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{63128,63125},63128}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,9000},
            [questKeys.exclusiveTo] = {31039,31040,31041,31042,31043,31044,31045,31046,31047,31048,31049,31061,31062,31105,31106, -- Omnia dailies
                                       31196,31197,31198,31199,31200,31201,31203,31204, -- Wu Kao dailies
            },
        },
        [31128] = { -- The Challenger's Ring: Lao-Chin the Iron Belly
            [questKeys.objectives] = {{{62978,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{63136,63135},63136}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,21000},
            [questKeys.exclusiveTo] = {31039,31040,31041,31042,31043,31044,31045,31046,31047,31048,31049,31061,31062,31105,31106, -- Omnia dailies
                                       31196,31197,31198,31199,31200,31201,31203,31204, -- Wu Kao dailies
            },
        },
        [31129] = { -- Fate of the Stormstouts
            [questKeys.objectives] = {{{62666,nil,Questie.ICON_TYPE_TALK},{62667,nil,Questie.ICON_TYPE_TALK},{62845,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestGroup] = {29907,31068},
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
            [questKeys.exclusiveTo] = {30482,31248,31249,31250},
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
            [questKeys.objectives] = {},
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
            [questKeys.preQuestSingle] = {31066},
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
            [questKeys.breadcrumbs] = {31727},
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
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
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
            [questKeys.objectives] = {nil,{{213304},{213305},{213303},{213306}}},
        },
        [31199] = { -- Destroy the Siege Weapons!
            [questKeys.objectives] = {nil,{{213307},{213308},{213310},{213311}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31200] = { -- Fumigation
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{63706,nil,Questie.ICON_TYPE_EVENT},{63708,nil,Questie.ICON_TYPE_EVENT},{63711,nil,Questie.ICON_TYPE_EVENT},{63713,nil,Questie.ICON_TYPE_EVENT},{63714,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31201] = { -- Friends, Not Food!
            [questKeys.objectives] = {{{64461,nil,Questie.ICON_TYPE_TALK},{64460,nil,Questie.ICON_TYPE_TALK},{64459,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31203] = { -- Target of Opportunity: Sra'thik Swarmlord
            [questKeys.exclusiveTo] = {31204}, -- check if it's direct followup of 31197
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31204] = { -- Target of Opportunity: Sra'thik Hivelord
            [questKeys.exclusiveTo] = {31203},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31207] = { -- The Arena of Annihilation
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{64280,64281,63316},64280}}},
        },
        [31208] = { -- Venomous Intent
            [questKeys.preQuestSingle] = {31018},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31209] = { -- Dark Wings, Dark Things
            [questKeys.preQuestSingle] = {31018},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31210] = { -- A Shade of Dread
            [questKeys.preQuestSingle] = {31018},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31211] = { -- The Poisoned Mind
            [questKeys.preQuestGroup] = {31208,31209,31210},
            [questKeys.objectives] = {{{62151,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{63615,63635,63636,65455,63613},63613},{{63637,65513,63625},63625}}},
        },
        [31216] = { -- Dark Skies
            [questKeys.objectives] = {{{62151,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{63615,63635,63636,65455,63613},63613},{{63637,65513,63625},63625}}},
            [questKeys.preQuestSingle] = {31211}, -- being offered only when the NPC reaches the quest hub during quest 31211
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31808}, -- need to see if it has any of the dailies as prequest
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31220] = { -- The Challenger's Ring: Hawkmaster Nurong
            [questKeys.objectives] = {{{63618,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{64470,64474},64474}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,9000},
            [questKeys.exclusiveTo] = {31039,31040,31041,31042,31043,31044,31045,31046,31047,31048,31049,31061,31062,31105,31106, -- Omnia dailies
                                       31113,31114,31116,31117,31118,31119,31120, -- Blackguard dailies
            },
        },
        [31221] = { -- The Challenger's Ring: Tenwu of the Red Smoke
            [questKeys.objectives] = {{{63616,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{64471,64473},64473}}},
            [questKeys.requiredMinRep] = {factionIDs.SHADO_PAN,21000},
            [questKeys.exclusiveTo] = {31039,31040,31041,31042,31043,31044,31045,31046,31047,31048,31049,31061,31062,31105,31106, -- Omnia dailies
                                       31113,31114,31116,31117,31118,31119,31120, -- Blackguard dailies
            },
        },
        [31228] = { -- Prophet Khar'zul
            [questKeys.objectives] = {{{65855,nil,Questie.ICON_TYPE_TALK},{61541}},nil,nil,nil,{{{64631,64639,64643,64642},64642}}},
        },
        [31230] = { -- Welcome to Dawn's Blossom
            [questKeys.objectives] = {{{59160,nil,Questie.ICON_TYPE_TALK},{55809,nil,Questie.ICON_TYPE_TALK},{59173,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {29922,30015},
        },
        [31231] = { -- Dreadspinner Extermination
            [questKeys.startedBy] = {{62538,66800}},
            [questKeys.finishedBy] = {{62538,66800}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31109,31111,31267}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31232] = { -- An Ancient Empire
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31270,31496,31507}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31233] = { -- Sap Tapping
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31269,31502,31508}, -- exclusivity for honored The Klaxxi
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Amber Tap"),0,{{"monster",63740}}}},
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31234] = { -- Putting An Eye Out
            [questKeys.preQuestSingle] = {31606},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31271,31503,31509}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31235] = { -- Nope Nope Nope
            [questKeys.startedBy] = {{62538,66800}},
            [questKeys.finishedBy] = {{62538,66800}},
            [questKeys.objectives] = {{{62077,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31268,31487,31505}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31237] = { -- Debugging the Terrace
            [questKeys.preQuestGroup] = {31458,31465},
            [questKeys.exclusiveTo] = {31272,31504,31510}, -- exclusivity for revered The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31238] = { -- Brain Food
            [questKeys.preQuestGroup] = {31092,31359},
            [questKeys.exclusiveTo] = {31024,31494,31506}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31239] = { -- What's in a Name Name?
            [questKeys.preQuestSingle] = {29941},
        },
        [31240] = { -- Guo-Lai Infestation -- Lake Peace to Ruins Peace
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.exclusiveTo] = {31244,31245,31246,31247},
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
            [questKeys.exclusiveTo] = {31240,31245,31246,31247},
            [questKeys.preQuestGroup] = {30313,30265,30340,30284}, -- Whitepetal Lake Peace
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31245] = { -- Mistfall Village -- Lake Peace to Mistfall Peace
            [questKeys.startedBy] = {{59343}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.exclusiveTo] = {31240,31244,31246,31247,31249}, -- funny stuff might happen because 31249 is here
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
            [questKeys.exclusiveTo] = {31249,31250},
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [31249] = { -- Mistfall Village -- Lake Attack to Mistfall Peace
            [questKeys.startedBy] = {{58408}},
            [questKeys.finishedBy] = {{59338}},
            [questKeys.exclusiveTo] = {31248,31250,31245}, -- funny stuff might happen because 31245 is here
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
        },
        [31250] = { -- Setting Sun Garrison -- Lake Attack to Garrison lead out
            [questKeys.startedBy] = {{58408}},
            [questKeys.preQuestGroup] = {-30281,-30282,-30283,30292},
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31248,31249},
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
            [questKeys.nextQuestInChain] = 0,
        },
        [31255] = { -- The Road to Kun-Lai [Horde]
            [questKeys.objectives] = {{{62738,nil,Questie.ICON_TYPE_TALK},{63367,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.nextQuestInChain] = 0,
        },
        [31256] = { -- Round 'Em Up
            [questKeys.preQuestSingle] = {30515},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{59610,59611},59610,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.KUN_LAI_SUMMIT] = {{62.17,79.93}}},Questie.ICON_TYPE_EVENT,l10n("Bring the yaks here")}},
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
            [questKeys.startedBy] = {{62538,66800}},
            [questKeys.finishedBy] = {{62538,66800}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31109,31111,31231}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31268] = { -- A Little Brain Work
            [questKeys.preQuestGroup] = {31092,31359},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31235,31487,31505}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31269] = { -- The Scale-Lord
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31233,31502,31508}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31270] = { -- The Fight Against Fear
            [questKeys.preQuestSingle] = {31026},
            [questKeys.exclusiveTo] = {31232,31496,31507}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31271] = { -- Bad Genes
            [questKeys.preQuestSingle] = {31606},
            [questKeys.exclusiveTo] = {31234,31503,31509}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31272] = { -- Infection
            [questKeys.preQuestGroup] = {31458,31465},
            [questKeys.exclusiveTo] = {31237,31504,31510}, -- exclusivity for revered The Klaxxi
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{63725,63726,63729,65118},63725}}}, -- 63833 63827
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31277] = { -- Surprise Attack!
            [questKeys.objectives] = {{{63908,nil,Questie.ICON_TYPE_TALK},{63920}}},
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
            [questKeys.exclusiveTo] = {30287,30290,30296,30297,31297,31296}, -- not visible once the final quest in hub is picked up or lead outs
        },
        [31294] = { -- The Ruins of Guo-Lai -- Mistfall Peace to Ruins Peace lead out
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31245,31249,30385,31295,31296}, -- 31245,31249 to not show this one if mistfall is 3rd hub
        },
        [31295] = { -- Mogu within the Ruins of Guo-Lai -- Mistfall Peace to Ruins Attack lead out
            [questKeys.startedBy] = {{59338}},
            [questKeys.finishedBy] = {{59332}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31245,31249,30385,31294,31296}, -- 31245,31249 to not show this one if mistfall is 3rd hub
        },
        [31296] = { -- The Ruins of Guo-Lai -- Mistfall Attack to Ruins Peace lead out
            [questKeys.startedBy] = {{59337}},
            [questKeys.finishedBy] = {{58503}},
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
            [questKeys.requiredMinRep] = {factionIDs.GOLDEN_LOTUS,9000},
            [questKeys.exclusiveTo] = {31246,31297,31294,31295}, -- 31246 to not show this one if mistfall is 3rd hub
        },
        [31297] = { -- Setting Sun Garrison -- Mistfall Attack to Garrison lead out
            [questKeys.startedBy] = {{59337}},
            [questKeys.finishedBy] = {{58919}},
            [questKeys.exclusiveTo] = {31296,31246}, -- 31246 to not show this one if mistfall is 3rd hub
            [questKeys.preQuestSingle] = {}, -- handled in questHubs
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
            [questKeys.exclusiveTo] = {31548,31552,31556,31582,31591},
        },
        [31309] = { -- On The Mend
            [questKeys.preQuestSingle] = {31308,31548,31552,31556,31582,31591},
            [questKeys.objectives] = {{{6749,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31549,31553,31568,31583,31592},
            [questKeys.requiredSpell] = 119467,
        },
        [31312] = { -- The Old Map
            [questKeys.nextQuestInChain] = 31313,
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,42000}, -- Tillers. we check for NPCs exalted via achievement
        },
        [31313] = { -- Just A Folk Story
            [questKeys.preQuestSingle] = {31312},
            [questKeys.nextQuestInChain] = 31314,
            [questKeys.objectives] = {{{64312,nil,Questie.ICON_TYPE_TALK},{64315,nil,Questie.ICON_TYPE_TALK},{64313,nil,Questie.ICON_TYPE_TALK},{64327,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31314] = { -- Old Man Thistle's Treasure
            [questKeys.preQuestSingle] = {31313},
            [questKeys.nextQuestInChain] = 31315,
            [questKeys.objectives] = {{{64328,nil,Questie.ICON_TYPE_EVENT}},{{213767}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Clear the rocks"),0,{{"object",211305}}}},
        },
        [31315] = { -- The Heartland Legacy
            [questKeys.preQuestSingle] = {31314},
        },
        [31316] = { -- Julia, The Pet Tamer
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{64330,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {},
        },
        [31319] = { -- Emergency Response
            [questKeys.objectives] = {{{64491,nil,Questie.ICON_TYPE_INTERACT},{64493,nil,Questie.ICON_TYPE_INTERACT},{64494,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31303},
        },
        [31320] = { -- Buy A Fish A Drink?
            [questKeys.requiredMinRep] = {1273,8400}, -- Aquaintance level with Jogu
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,8}},
        },
        [31321] = { -- Buy A Fish A Round?
            [questKeys.requiredMinRep] = {1273,16800}, -- Buddy level with Jogu
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,19}},
        },
        [31322] = { -- Buy A Fish A Keg?
            [questKeys.requiredMinRep] = {1273,25200}, -- Friend level with Jogu
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,35}},
        },
        [31323] = { -- Buy A Fish A Brewery?
            [questKeys.requiredMinRep] = {1273,36000}, -- within 6000 rep of Best Friend (wowhead comment)
            [questKeys.reputationReward] = {{factionIDs.JOGU_THE_DRUNK,26}},
        },
        [31325] = { -- A Very Nice Necklace
            [questKeys.requiredMinRep] = {1280,8400}, -- Tina at Acquaintance level (8400-16800)
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,34}},
        },
        [31326] = { -- Tina's Tasteful Tiara
            [questKeys.requiredMinRep] = {1280,16800}, -- Tina at Buddy level (16800-25200)
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,34}},
        },
        [31327] = { -- Trouble Brewing
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {30085},
        },
        [31328] = { -- An Exquisite Earring
            [questKeys.requiredMinRep] = {1280,25200}, -- Tina at Friend level or above (25200+)
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,34}},
        },
        [31329] = { -- A Beautiful Brooch
            [questKeys.requiredMinRep] = {1280,33600}, -- Tina at Good Friend level or above (33600+)
            [questKeys.reputationReward] = {{factionIDs.TINA_MUDCLAW,34}},
        },
        [31332] = { -- Lesson 1: Sliced Peaches
            [questKeys.preQuestSingle] = {31521},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,0},
            [questKeys.requiredMaxRep] = {factionIDs.NOMI,8400},
        },
        [31333] = { -- Lesson 2: Instant Noodles
            [questKeys.preQuestSingle] = {31521},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,8400},
            [questKeys.requiredMaxRep] = {factionIDs.NOMI,16800},
        },
        [31334] = { -- Lesson 3: Toasted Fish Jerky
            [questKeys.preQuestSingle] = {31521},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,16800},
            [questKeys.requiredMaxRep] = {factionIDs.NOMI,25200},
        },
        [31335] = { -- Lesson 4: Dried Needle Mushrooms
            [questKeys.preQuestSingle] = {31521},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,25200},
            [questKeys.requiredMaxRep] = {factionIDs.NOMI,33600},
        },
        [31336] = { -- Lesson 5: Pounded Rice Cake
            [questKeys.preQuestSingle] = {31521},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,33600},
            [questKeys.requiredMaxRep] = {factionIDs.NOMI,42000},
        },
        [31337] = { -- A Token of Appreciation
            [questKeys.preQuestSingle] = {31820},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,42000},
        },
        [31338] = { -- Lost Sheepie
            [questKeys.requiredMinRep] = {1277,16800}, -- Buddy level with Chee Chee
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,34}},
        },
        [31339] = { -- Lost Sheepie... Again
            [questKeys.requiredMinRep] = {1277,25200}, -- Friend level with Chee Chee
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,34}},
        },
        [31340] = { -- Oh Sheepie...
            [questKeys.requiredMinRep] = {1277,33600}, -- Good Friends level with Chee Chee
            [questKeys.objectives] = {{{64391,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,34}},
        },
        [31341] = { -- A Wolf In Sheep's Clothing
            [questKeys.requiredMinRep] = {1277,33600}, -- Good Friends level with Chee Chee
            [questKeys.reputationReward] = {{factionIDs.CHEE_CHEE,34}},
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
        [31363] = { -- Lighting the Way
            [questKeys.objectives] = {nil,{{211129}}},
        },
        [31367] = { -- The Lorewalkers
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.breadcrumbForQuestId] = 31015,
            [questKeys.exclusiveTo] = {31016,31368},
            [questKeys.objectives] = {{{65716,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,27}},
        },
        [31368] = { -- The Lorewalkers
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.breadcrumbForQuestId] = 31015,
            [questKeys.exclusiveTo] = {31016,31367},
            [questKeys.objectives] = {{{65716,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.THE_LOREWALKERS,27}},
        },
        [31369] = { -- The Anglers
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.requiredSkill] = {profKeys.FISHING,1},
            [questKeys.exclusiveTo] = {31371},
        },
        [31370] = { -- The Anglers
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.requiredSkill] = {profKeys.FISHING,1},
            [questKeys.exclusiveTo] = {31371},
        },
        [31372] = { -- The Tillers
            [questKeys.preQuestGroup] = {31001,30637}, -- double check if it actually needs 31001
            [questKeys.breadcrumbForQuestId] = 30252,
            [questKeys.nextQuestInChain] = 30252,
        },
        [31373] = { -- The Order of the Cloud Serpent
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.breadcrumbForQuestId] = 30134,
            [questKeys.exclusiveTo] = {32461},
        },
        [31374] = { -- The Tillers
            [questKeys.preQuestGroup] = {31001,30637}, -- double check if it actually needs 31001
            [questKeys.breadcrumbForQuestId] = 30252,
            [questKeys.nextQuestInChain] = 30252,
        },
        [31375] = { -- The Order of the Cloud Serpent
            [questKeys.preQuestGroup] = {31001,30637}, -- 100% 31001,30637 if another quest is needed, add to this one
            [questKeys.breadcrumbForQuestId] = 30134,
            [questKeys.exclusiveTo] = {32461},
        },
        [31376] = { -- Attack At The Temple of the Jade Serpent
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31378,31380,31382,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31377] = { -- Attack At The Temple of the Jade Serpent
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31379,31381,31383,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31378] = { -- Challenge At The Temple of the Red Crane
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31376,31380,31382,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31379] = { -- Challenge At The Temple of the Red Crane
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31377,31381,31383,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31380] = { -- Trial At The Temple of the White Tiger
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31376,31378,31382,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31381] = { -- Trial At The Temple of the White Tiger
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31377,31379,31383,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31382] = { -- Defense At Niuzao Temple
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31376,31378,31380,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31383] = { -- Defense At Niuzao Temple
            --[questKeys.preQuestSingle] = {31511,31512}, -- this is available without 31511/31512
            [questKeys.exclusiveTo] = {31377,31379,31381,30725,30726,30727,30728,30729,30730,30731,30732,30733,30734,30735,30736,30737,30738,30739,30740},
        },
        [31384] = { -- The Golden Lotus
            [questKeys.finishedBy] = {{58408}},
            [questKeys.breadcrumbForQuestId] = 30632,
        },
        [31385] = { -- The Golden Lotus
            [questKeys.finishedBy] = {{58408}},
            [questKeys.breadcrumbForQuestId] = 30632,
        },
        [31386] = { -- The Shado-Pan Offensive
            [questKeys.exclusiveTo] = {31388,31695},
            [questKeys.breadcrumbForQuestId] = 30814,
        },
        [31388] = { -- The Shado-Pan Offensive
            [questKeys.exclusiveTo] = {31386,31695},
            [questKeys.breadcrumbForQuestId] = 30814,
        },
        [31390] = { -- The Klaxxi
            -- [questKeys.preQuestSingle] = {}, -- available on char where i only did dungeon quests + the intro quest to pandaria
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31391,31656,31847,31886,31895},
        },
        [31391] = { -- The Klaxxi
            -- [questKeys.preQuestSingle] = {}, -- available on char where i only did dungeon quests + the intro quest to pandaria
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31656,31847,31886,31895},
        },
        [31392] = { -- Temple of the White Tiger [Alliance]
            [questKeys.startedBy] = {{55809,60289,63754,64448,64521,66247}},
            [questKeys.breadcrumbForQuestId] = 31394,
        },
        [31393] = { -- Temple of the White Tiger [Horde]
            [questKeys.startedBy] = {{55809,60289,63751,64448,64521,66247}},
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
            [questKeys.preQuestSingle] = {31066},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
            [questKeys.objectives] = {{{64645,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31450] = { -- A New Fate
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{56013,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE + raceIDs.PANDAREN_HORDE + raceIDs.PANDAREN,
        },
        [31451] = { -- The Missing Merchant [Horde]
            [questKeys.preQuestGroup] = {30655,30656,30661},
            [questKeys.breadcrumbForQuestId] = 30467,
            [questKeys.nextQuestInChain] = 30467,
        },
        [31452] = { -- The Missing Merchant [Alliance]
            [questKeys.preQuestGroup] = {30650,30651,30660},
            [questKeys.breadcrumbForQuestId] = 30467,
            [questKeys.nextQuestInChain] = 30467,
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
            [questKeys.preQuestSingle] = {30660,30062},
            [questKeys.breadcrumbForQuestId] = 30488,
        },
        [31457] = { -- Muskpaw Ranch [Horde]
            [questKeys.preQuestSingle] = {30661,30663},
            [questKeys.breadcrumbForQuestId] = 30488,
        },
        [31458] = { -- Damage Control
            [questKeys.preQuestSingle] = {31441},
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
            [questKeys.preQuestSingle] = {31441},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
        },
        [31467] = { -- Strong as a Tiger
            [questKeys.objectives] = {nil,nil,{{74642}},nil,nil,{{104298}}},
        },
        [31468] = { -- Trial of the Black Prince
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {31454},
            [questKeys.exclusiveTo] = {30118},
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
        [31481] = { -- Fear Itself
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestGroup] = {31468,31473},
            [questKeys.exclusiveTo] = {91786},
        },
        [31482] = { -- Breath of the Black Prince
            [questKeys.startedBy] = {{64616}},
            [questKeys.finishedBy] = {{64616,64822}},
            [questKeys.preQuestSingle] = {31481,91786},
            [questKeys.nextQuestInChain] = 31483,
            [questKeys.objectives] = {{{66586,nil,Questie.ICON_TYPE_EVENT},{64822,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31483] = { -- Incoming...
            [questKeys.startedBy] = {{64616,64822}},
            [questKeys.preQuestSingle] = {31482}, -- need to see when it stop being offered if you don't take it
            [questKeys.objectives] = {{{64681,nil,Questie.ICON_TYPE_EVENT},{64822,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31486] = { -- Everything I Know About Cooking
            [questKeys.requiredLevel] = 86,
            [questKeys.exclusiveTo] = {31279},
        },
        [31487] = { -- Sonic Disruption
            [questKeys.preQuestGroup] = {31092,31359},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31235,31268,31505}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31488] = { -- Stranger in a Strange Land
            [questKeys.startedBy] = {{62871,63218,64047,64144,64457,65908,66225,66409,66415}},
            [questKeys.breadcrumbForQuestId] = 31454,
            [questKeys.exclusiveTo] = {30118,31489},
        },
        [31489] = { -- Stranger in a Strange Land
            [questKeys.preQuestSingle] = {30118},
            [questKeys.breadcrumbForQuestId] = 31454,
            [questKeys.exclusiveTo] = {31488},
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [31490] = { -- Rank and File
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58632,58676,58683,58684,58685,58756,58898,58998,59150,59175,59191,59240,59241,59293,59303,59372,59373},58632}}},
        },
        [31492] = { -- The Torch of Strength
            [questKeys.preQuestSingle] = {31511,31512},
            [questKeys.exclusiveTo] = {31517},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,{{214628}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Grab another torch"),0,{{"monster",60981}}}},
        },
        [31494] = { -- Free From Her Clutches
            [questKeys.objectives] ={nil,{{214292}}},
            [questKeys.preQuestGroup] = {31092,31359},
            [questKeys.exclusiveTo] = {31024,31238,31506}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31495] = { -- Rank and File
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58632,58676,58683,58684,58685,58756,58898,58998,59150,59175,59191,59240,59241,59293,59303,59372,59373},58632}}},
        },
        [31496] = { -- Sampling the Empire's Finest
            [questKeys.preQuestSingle] = {31026},
            [questKeys.exclusiveTo] = {31232,31270,31507}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31502] = { -- Wing Clip
            [questKeys.preQuestSingle] = {31606},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31233,31269,31508}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31503] = { -- Shortcut to Ruin
            [questKeys.preQuestSingle] = {31606},
            [questKeys.exclusiveTo] = {31234,31271,31509}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31504] = { -- Ordnance Disposal
            [questKeys.preQuestGroup] = {31458,31465},
            [questKeys.exclusiveTo] = {31237,31272,31510}, -- exclusivity for revered The Klaxxi
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31505] = { -- Vess-Guard Duty
            [questKeys.startedBy] = {{62538,66800}},
            [questKeys.finishedBy] = {{62538,66800}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31235,31268,31487}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31506] = { -- Shackles of Manipulation
            [questKeys.preQuestGroup] = {31092,31359},
            [questKeys.exclusiveTo] = {31024,31238,31494}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31507] = { -- Meltdown
            [questKeys.preQuestSingle] = {31026},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31232,31270,31496}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31508] = { -- Specimen Request
            [questKeys.preQuestSingle] = {31606},
            [questKeys.exclusiveTo] = {31233,31269,31502}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31509] = { -- Fear Takes Root
            [questKeys.preQuestSingle] = {31606},
            [questKeys.objectives] = {nil,{{214543}}},
            [questKeys.exclusiveTo] = {31234,31271,31503}, -- exclusivity for honored The Klaxxi
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31510] = { -- Quiet Now
            [questKeys.preQuestGroup] = {31458,31465},
            [questKeys.exclusiveTo] = {31237,31272,31504}, -- exclusivity for revered The Klaxxi
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the crystal"),0,{{"object",214455}}}},
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31511] = { -- A Witness to History [Horde]
            [questKeys.finishedBy] = {{59905,62996}},
            [questKeys.objectives] = {{{64853,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31512},
        },
        [31512] = { -- A Witness to History [Alliance]]
            [questKeys.finishedBy] = {{59905,64149}},
            [questKeys.objectives] = {{{64848,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31511},
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
            [questKeys.zoneOrSort] = zoneIDs.THE_HALFHILL_MARKET,
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
            [questKeys.objectives] = {{{59150}}},
        },
        [31528] = {-- A Worthy Challenge: Darkmaster Gandling
            [questKeys.exclusiveTo] = {31519,31520,31522,31523,31524,31525,31526,31527},
        },
        [31529] = { -- Mission: Culling The Vermin
            [questKeys.requiredMinRep] = {1278,12600}, -- 4200 into Aquaintance with Sho
            [questKeys.reputationReward] = {{factionIDs.SHO,34}},
        },
        --[31530] = { -- Mission: The Hozen Dozen -- Don't think this made it to live so blacklisted
            --[questKeys.requiredMinRep] = {1278,} --
       -- },
        [31531] = { -- Mission: Aerial Threat
            [questKeys.requiredMinRep] = {1278,29400}, -- 4200 into Friend with Sho
            [questKeys.reputationReward] = {{factionIDs.SHO,34}},
        },
        [31532] = { -- Mission: Predator of the Cliffs
            [questKeys.requiredMinRep] = {1278,37800}, -- 4200 into Good Friend with Sho
            [questKeys.reputationReward] = {{factionIDs.SHO,34}},
        },
        [31534] = { -- The Beginner's Brew
            [questKeys.requiredMinRep] = {1275,16800}, -- Buddy level with Ella
            [questKeys.reputationReward] = {{factionIDs.ELLA,35}},
            [questKeys.objectives] = {nil,nil,{{87554,nil,Questie.ICON_TYPE_TALK},{87555,nil,Questie.ICON_TYPE_TALK},{87556,nil,Questie.ICON_TYPE_TALK},{87553,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31535] = { -- Replenishing the Pantry
            [questKeys.preQuestSingle] = {31536},
        },
        [31536] = { -- Preserving Freshness
            [questKeys.preQuestGroup] = {31467,31471,31474,31476,31477,31480},
        },
        [31537] = { -- Ella's Taste Test
            [questKeys.requiredMinRep] = {1275,25200}, -- Friend level with Ella
            [questKeys.objectives] = {{{58710,nil,Questie.ICON_TYPE_INTERACT},{58717,nil,Questie.ICON_TYPE_INTERACT},{58646,nil,Questie.ICON_TYPE_INTERACT},{64597,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.ELLA,35}},
        },
        [31538] = { -- A Worthy Brew
            [questKeys.requiredMinRep] = {1275,33600}, -- Good friends level with Ella
            [questKeys.objectives] = {{{64946,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.ELLA,35}},
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
            [questKeys.requiredSourceItems] = {87821},
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
            [questKeys.exclusiveTo] = {31308,31552,31556,31582,31591},
        },
        [31549] = { -- On The Mend
            [questKeys.startedBy] = {{63075}},
            [questKeys.preQuestSingle] = {31308,31548,31552,31556,31582,31591},
            [questKeys.objectives] = {{{9980,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31309,31553,31568,31583,31592},
            [questKeys.requiredSpell] = 119467,
        },
        [31550] = { -- Got one!
            [questKeys.preQuestSingle] = {31785,31821,31822,31825,31826,31832},
            [questKeys.exclusiveTo] = {31551,31555,31569,31584,31593},
            [questKeys.requiredSpell] = 119467,
        },
        [31551] = { -- Got one!
            [questKeys.startedBy] = {{63075}},
            [questKeys.preQuestSingle] = {31785,31821,31822,31825,31826,31832},
            [questKeys.exclusiveTo] = {31550,31555,31569,31584,31593},
            [questKeys.requiredSpell] = 119467,
        },
        [31552] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63070}},
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31308,31548,31556,31582,31591},
        },
        [31553] = { -- On The Mend
            [questKeys.startedBy] = {{63070}},
            [questKeys.preQuestSingle] = {31308,31548,31552,31556,31582,31591},
            [questKeys.objectives] = {{{10051,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31309,31549,31568,31583,31592},
            [questKeys.requiredSpell] = 119467,
        },
        [31555] = { -- Got one!
            [questKeys.preQuestSingle] = {31785,31821,31822,31825,31826,31832},
            [questKeys.exclusiveTo] = {31550,31551,31569,31584,31593},
            [questKeys.requiredSpell] = 119467,
        },
        [31556] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31308,31548,31552,31582,31591},
        },
        [31568] = { -- On The Mend
            [questKeys.startedBy] = {{63077}},
            [questKeys.preQuestSingle] = {31308,31548,31552,31556,31582,31591},
            [questKeys.objectives] = {{{17485,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31309,31549,31553,31583,31592},
            [questKeys.requiredSpell] = 119467,
        },
        [31569] = { -- Got one!
            [questKeys.startedBy] = {{63077}},
            [questKeys.preQuestSingle] = {31785,31821,31822,31825,31826,31832},
            [questKeys.exclusiveTo] = {31550,31551,31555,31584,31593},
            [questKeys.requiredSpell] = 119467,
        },
        [31570] = { -- Got one!
            [questKeys.preQuestSingle] = {31823,31824,31827,31828,31830,31831},
            [questKeys.exclusiveTo] = {31575,31578,31581,31587,31590},
            [questKeys.requiredSpell] = 119467,
        },
        [31571] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31573,31576,31579,31585,31588},
        },
        [31572] = { -- On The Mend
            [questKeys.startedBy] = {{63061}},
            [questKeys.preQuestSingle] = {31571,31573,31576,31579,31585,31588},
            [questKeys.objectives] = {{{9987,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31574,31577,31580,31586,31589},
            [questKeys.requiredSpell] = 119467,
        },
        [31573] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31571,31576,31579,31585,31588},
        },
        [31574] = { -- On The Mend
            [questKeys.startedBy] = {{63067}},
            [questKeys.preQuestSingle] = {31571,31573,31576,31579,31585,31588},
            [questKeys.objectives] = {{{10050,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31572,31577,31580,31586,31589},
            [questKeys.requiredSpell] = 119467,
        },
        [31575] = { -- Got one!
            [questKeys.startedBy] = {{63067}},
            [questKeys.preQuestSingle] = {31823,31824,31827,31828,31830,31831},
            [questKeys.exclusiveTo] = {31570,31578,31581,31587,31590},
            [questKeys.requiredSpell] = 119467,
        },
        [31576] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31571,31573,31579,31585,31588},
        },
        [31577] = { -- On The Mend
            [questKeys.startedBy] = {{63073}},
            [questKeys.preQuestSingle] = {31571,31573,31576,31579,31585,31588},
            [questKeys.objectives] = {{{10055,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31572,31574,31580,31586,31589},
            [questKeys.requiredSpell] = 119467,
        },
        [31578] = { -- Got one!
            [questKeys.startedBy] = {{63073}},
            [questKeys.preQuestSingle] = {31823,31824,31827,31828,31830,31831},
            [questKeys.exclusiveTo] = {31570,31575,31581,31587,31590},
            [questKeys.requiredSpell] = 119467,
        },
        [31579] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31571,31573,31576,31585,31588},
        },
        [31580] = { -- On The Mend
            [questKeys.startedBy] = {{63080}},
            [questKeys.preQuestSingle] = {31571,31573,31576,31579,31585,31588},
            [questKeys.objectives] = {{{16185,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31572,31574,31577,31586,31589},
            [questKeys.requiredSpell] = 119467,
        },
        [31581] = { -- Got one!
            [questKeys.startedBy] = {{63080}},
            [questKeys.preQuestSingle] = {31823,31824,31827,31828,31830,31831},
            [questKeys.exclusiveTo] = {31570,31575,31578,31587,31590},
            [questKeys.requiredSpell] = 119467,
        },
        [31582] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31308,31548,31552,31556,31591},
        },
        [31583] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.preQuestSingle] = {31308,31548,31552,31556,31582,31591},
            [questKeys.objectives] = {{{10085,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31309,31549,31553,31568,31592},
            [questKeys.requiredSpell] = 119467,
        },
        [31584] = { -- Got one!
            [questKeys.preQuestSingle] = {31785,31821,31822,31825,31826,31832},
            [questKeys.exclusiveTo] = {31550,31551,31555,31569,31593},
            [questKeys.requiredSpell] = 119467,
        },
        [31585] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31571,31573,31576,31579,31588},
        },
        [31586] = { -- On The Mend
            [questKeys.startedBy] = {{63086}},
            [questKeys.preQuestSingle] = {31571,31573,31576,31579,31585,31588},
            [questKeys.objectives] = {{{45789,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31572,31574,31577,31580,31589},
            [questKeys.requiredSpell] = 119467,
        },
        [31587] = { -- Got one!
            [questKeys.startedBy] = {{63086}},
            [questKeys.preQuestSingle] = {31823,31824,31827,31828,31830,31831},
            [questKeys.exclusiveTo] = {31570,31575,31578,31581,31590},
            [questKeys.requiredSpell] = 119467,
        },
        [31588] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31571,31573,31576,31579,31585},
        },
        [31589] = { -- On The Mend
            [questKeys.preQuestSingle] = {31571,31573,31576,31579,31585,31588},
            [questKeys.objectives] = {{{47764,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31572,31574,31577,31580,31586},
            [questKeys.requiredSpell] = 119467,
        },
        [31590] = { -- Got one!
            [questKeys.preQuestSingle] = {31823,31824,31827,31828,31830,31831},
            [questKeys.exclusiveTo] = {31570,31575,31578,31581,31587},
            [questKeys.requiredSpell] = 119467,
        },
        [31591] = { -- Learning the Ropes
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31308,31548,31552,31556,31582},
        },
        [31592] = { -- On The Mend
            [questKeys.preQuestSingle] = {31308,31548,31552,31556,31582,31591},
            [questKeys.objectives] = {{{11069,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {31309,31549,31553,31568,31583},
            [questKeys.requiredSpell] = 119467,
        },
        [31593] = { -- Got one!
            [questKeys.preQuestSingle] = {31785,31821,31822,31825,31826,31832},
            [questKeys.exclusiveTo] = {31550,31551,31555,31569,31584},
            [questKeys.requiredSpell] = 119467,
        },
        [31598] = { -- Kypa'rak's Core
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = { -- exclusivity for hidden daily The Klaxxi
                                      31024,31267,31268,31269,31270,31271,31272, -- Lake
                                      31231,31232,31233,31234,31235,31237,31238, -- Terrace
                                      31109,31487,31494,31496,31502,31503,31504, -- Clutches
            },
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31599] = { -- The Matriarch's Maw
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = { -- exclusivity for hidden daily The Klaxxi
                                      31024,31267,31268,31269,31270,31271,31272, -- Lake
                                      31231,31232,31233,31234,31235,31237,31238, -- Terrace
                                      31111,31505,31506,31507,31508,31509,31510, -- Zan'vess
            },
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31603] = { -- Seeds of Fear
            [questKeys.preQuestSingle] = {31108},
            [questKeys.objectivesText] = {},
        },
        [31605] = { -- The Zan'thik Dig
            [questKeys.finishedBy] = {{63072,65253,67091}},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,9000},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.exclusiveTo] = {31606}, -- no longer available once you turn in 31606
        },
        [31606] = { -- The Dissector Wakens
            [questKeys.objectives] = {{{67091}}},
            [questKeys.preQuestSingle] = {31066},
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,3000}, -- friendly 100%
        },
        [31612] = { -- Shadow of the Empire
            [questKeys.objectives] = {nil,nil,nil,nil,{{{62538,66800},66800,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31613] = { -- Volatile Greenstone Brew
            [questKeys.zoneOrSort] = zoneIDs.GREENSTONE_VILLAGE,
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
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31670,31671,31672,31673,31674,31675,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {79102,80809},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31670] = { -- That Dangling Carrot
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31671,31672,31673,31674,31675,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {80590,84782},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31671] = { -- Why Not Scallions?
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31672,31673,31674,31675,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {80591,84783},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31672] = { -- A Pumpkin-y Perfume
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31673,31674,31675,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {80592,85153},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31673] = { -- Red Blossom Leeks, You Make the Croc-in' World Go Down
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31674,31675,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {80593,85158},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31674] = { -- The Pink Turnip Challenge
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31675,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {80594,85162},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31675] = { -- The White Turnip Treatment
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31941,31942,31943,32682},
            [questKeys.requiredSourceItems] = {80595,85163},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31676] = { -- Ancient Vengeance
            [questKeys.preQuestSingle] = {31004},
        },
        [31677] = { -- The Warlord's Ashes
            [questKeys.preQuestSingle] = {31066},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = { -- exclusivity for hidden daily The Klaxxi
                                      31024,31267,31268,31269,31270,31271,31272, -- Lake
                                      31109,31487,31494,31496,31502,31503,31504, -- Clutches
                                      31111,31505,31506,31507,31508,31509,31510, -- Zan'vess
            },
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31679] = { -- Extending Our Coverage
            [questKeys.startedBy] = {{65541}},
            [questKeys.preQuestGroup] = {31066,31441},
            [questKeys.exclusiveTo] = {31087},
        },
        [31680] = { -- Crime and Punishment
            [questKeys.exclusiveTo] = {31088},
            [questKeys.preQuestSingle] = {31679},
        },
        [31681] = { -- Better With Age
            [questKeys.exclusiveTo] = {31090},
            [questKeys.preQuestSingle] = {31679},
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
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{64330,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31695] = { -- Beyond the Wall
            [questKeys.exclusiveTo] = {30768,31386,31388}, -- might not be available at some point later in townlong progression. need to find out
            [questKeys.nextQuestInChain] = 0,
        },
        [31698] = { -- Thinning The Pack
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31699] = { -- Sprite Fright
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31700] = { -- The Shoe Is On The Other Foot
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31701] = { -- Dark Huntress
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31702] = { -- On The Prowl
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31703] = { -- Madcap Mayhem
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31704] = { -- Pooped
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31705] = { -- Needle Me Not
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31706] = { -- Weeping Widows
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31707] = { -- A Tangled Web
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31708] = { -- Serpent's Scale
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31709] = { -- Lingering Doubt
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31710] = { -- Tiny Treats
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31711] = { -- The Seed of Doubt
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31712] = { -- Monkey Mischief
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31713] = { -- The Big Brew-haha
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31714] = { -- Saving the Serpents
            [questKeys.preQuestSingle] = {30142},
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31715] = { -- The Big Kah-Oona
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31716] = { -- Pooped
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,9000},
        },
        [31717] = { -- The Trainer's Challenge: Ace Longpaw
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31718] = { -- The Trainer's Challenge: Big Bao
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31719] = { -- The Trainer's Challenge: Ningna Darkwheel
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31720] = { -- The Trainer's Challenge: Suchi the Sweet
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31721] = { -- The Trainer's Challenge: Qua-Ro Whitebrow
            [questKeys.preQuestSingle] = {30142},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,21000},
        },
        [31724] = { -- Old MacDonald
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{65648,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31725] = { -- Lindsay
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{65651,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31726] = { -- Eric Davidson
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{65655,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31727] = { -- Gambling Problem
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,9000},
            [questKeys.preQuestGroup] = {31026,31359,31092,31398},
            [questKeys.breadcrumbForQuestId] = 31181,
        },
        [31728] = { -- Bill Buckler
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{65656,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31729] = { -- Steven Lisbane
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{63194,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31730] = { -- A Not So Friendly Request
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,9000},
            [questKeys.breadcrumbForQuestId] = 31067,
            [questKeys.preQuestGroup] = {31026,31359,31092,31398},
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
            [questKeys.objectives] = {nil,{{215390},{215390}},nil,nil,{{{66396,66406},66396,nil,Questie.ICON_TYPE_EVENT}}},
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
        [31752] = { -- Blingtron 4000
            [questKeys.requiredSkill] = {},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{65817,65818,65804},65804,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSpell] = 115913,
        },
        [31756] = { -- High Chance of Rain
            [questKeys.startedBy] = {{58471}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31754,31758},
            [questKeys.requiredSpell] = 115913,
            [questKeys.objectives] = {nil,{{214895},{214899},{214900},{214901}}},
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
            [questKeys.objectives] = {{{65868,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",214948}}}},
        },
        [31760] = { -- Striking First
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31762},
            [questKeys.requiredSpell] = 115913,
            [questKeys.objectives] = {{{65962,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31762] = { -- Crumbling Behemoth
            [questKeys.startedBy] = {{58465}},
            [questKeys.preQuestSingle] = {30638},
            [questKeys.exclusiveTo] = {31760},
            [questKeys.requiredSpell] = 115913,
        },
        [31765] = { -- Paint it Red!
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Get in a cannon"),0,{{"monster",66674},{"monster",66676},{"monster",66677}}}},
        },
        [31766] = { -- Touching Ground
            [questKeys.objectives] = {nil,{{215689}}},
        },
        [31768] = { -- Fire Is Always the Answer
            [questKeys.objectives] = {{{66308,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31766},
        },
        [31769] = { -- The Final Blow!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31767,31768},
            [questKeys.objectives] = {{{66554,nil,Questie.ICON_TYPE_EVENT},{66555,nil,Questie.ICON_TYPE_EVENT},{66556,nil,Questie.ICON_TYPE_EVENT},{66283,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Blow up the explosives"),0,{{"object",215650}}}},
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
            [questKeys.preQuestGroup] = {29694,31770,31771,31773}, -- check if it also needs Priorities! 31772/31978
        },
        [31775] = { -- Assault on the Airstrip
            [questKeys.preQuestSingle] = {29804},
        },
        [31776] = { -- Strongarm Tactics
            [questKeys.preQuestSingle] = {29804},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{65882,65883},65882},{{65883},65883},{{65880},65880},{{65881},65881}}},
        },
        [31777] = { -- Choppertunity
            [questKeys.requiredSourceItems] = {89163},
            [questKeys.preQuestSingle] = {29804},
        },
        [31778] = { -- Unreliable Allies
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67090,65974},65974,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {29804},
        },
        [31779] = { -- The Darkness Within
            [questKeys.finishedBy] = {nil,{215844}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31775,31776,31777,31778},
        },
        [31780] = { -- Old MacDonald
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65648,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31781] = { -- Lindsay
            [questKeys.requiredSpell] = 119467,
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
            [questKeys.requiredMaxRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,42000},
        },
        [31785] = { -- Level Up!
            [questKeys.preQuestSingle] = {31309,31549,31553,31568,31583,31592},
            [questKeys.exclusiveTo] = {31821,31822,31825,31826,31832},
            [questKeys.requiredSpell] = 119467,
        },
        [31808] = { -- Rampage Against the Machine
            [questKeys.preQuestGroup] = {31092,31359,31238}, -- 31024 31238 31494 31506 exclusives
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,21000},
            [questKeys.exclusiveTo] = {31216},
            [questKeys.objectives] = {{{63765,nil,Questie.ICON_TYPE_MOUNT_UP}},nil,nil,nil,{{{67030,67033,67035,67036,67037,67039,67034},67034}}},
            [questKeys.reputationReward] = {{factionIDs.THE_KLAXXI,30}},
        },
        [31810] = { -- Riding the Skies (Azure Cloud Serpent)
            [questKeys.startedBy] = {}, -- hiding 2 of the 3 due to blizzard returning true to all versions
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,42000},
            [questKeys.preQuestGroup] = {30139,30187},
            [questKeys.exclusiveTo] = {30188,31811},
        },
        [31811] = { -- Riding the Skies (Golden Cloud Serpent)
            [questKeys.startedBy] = {}, -- hiding 2 of the 3 due to blizzard returning true to all versions
            [questKeys.requiredMinRep] = {factionIDs.ORDER_OF_THE_CLOUD_SERPENT,42000},
            [questKeys.preQuestGroup] = {30141,30187},
            [questKeys.exclusiveTo] = {30188,31810},
        },
        [31812] = { -- Zunta, The Pet Tamer
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66126,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {},
        },
        [31813] = { -- Dagra the Fierce
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66135,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31814] = { -- Analynn
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66136,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31815] = { -- Zonya the Sadist
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66137,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31817] = { -- Merda Stronghoof
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66372,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31818] = { -- Zunta
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66126,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31819] = { -- Dagra the Fierce
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66135,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31820] = { -- A Present for Teacher
            [questKeys.preQuestSingle] = {31521},
            [questKeys.requiredMinRep] = {factionIDs.NOMI,42000},
        },
        [31821] = { -- Level Up!
            [questKeys.preQuestSingle] = {31309,31549,31553,31568,31583,31592},
            [questKeys.exclusiveTo] = {31785,31822,31825,31826,31832},
            [questKeys.requiredSpell] = 119467,
        },
        [31822] = { -- Level Up!
            [questKeys.preQuestSingle] = {31309,31549,31553,31568,31583,31592},
            [questKeys.exclusiveTo] = {31785,31821,31825,31826,31832},
            [questKeys.requiredSpell] = 119467,
        },
        [31823] = { -- Level Up!
            [questKeys.preQuestSingle] = {31572,31574,31577,31580,31586,31589},
            [questKeys.exclusiveTo] = {31824,31827,31828,31830,31831},
            [questKeys.requiredSpell] = 119467,
        },
        [31824] = { -- Level Up!
            [questKeys.startedBy] = {{63080}},
            [questKeys.preQuestSingle] = {31572,31574,31577,31580,31586,31589},
            [questKeys.exclusiveTo] = {31823,31827,31828,31830,31831},
            [questKeys.requiredSpell] = 119467,
        },
        [31825] = { -- Level Up!
            [questKeys.preQuestSingle] = {31309,31549,31553,31568,31583,31592},
            [questKeys.exclusiveTo] = {31785,31821,31822,31826,31832},
            [questKeys.requiredSpell] = 119467,
        },
        [31826] = { -- Level Up!
            [questKeys.startedBy] = {{63070}},
            [questKeys.preQuestSingle] = {31309,31549,31553,31568,31583,31592},
            [questKeys.exclusiveTo] = {31785,31821,31822,31825,31832},
            [questKeys.requiredSpell] = 119467,
        },
        [31827] = { -- Level Up!
            [questKeys.preQuestSingle] = {31572,31574,31577,31580,31586,31589},
            [questKeys.exclusiveTo] = {31823,31824,31828,31830,31831},
            [questKeys.requiredSpell] = 119467,
        },
        [31828] = { -- Level Up!
            [questKeys.preQuestSingle] = {31572,31574,31577,31580,31586,31589},
            [questKeys.exclusiveTo] = {31823,31824,31827,31830,31831},
            [questKeys.requiredSpell] = 119467,
        },
        [31830] = { -- Level Up!
            [questKeys.preQuestSingle] = {31572,31574,31577,31580,31586,31589},
            [questKeys.exclusiveTo] = {31823,31824,31827,31828,31831},
            [questKeys.requiredSpell] = 119467,
        },
        [31831] = { -- Level Up!
            [questKeys.startedBy] = {{63067}},
            [questKeys.preQuestSingle] = {31572,31574,31577,31580,31586,31589},
            [questKeys.exclusiveTo] = {31823,31824,31827,31828,31830},
            [questKeys.requiredSpell] = 119467,
        },
        [31832] = { -- Level Up!
            [questKeys.preQuestSingle] = {31309,31549,31553,31568,31583,31592},
            [questKeys.exclusiveTo] = {31785,31821,31822,31825,31826},
            [questKeys.requiredSpell] = 119467,
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
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66256}}}},
            [questKeys.breadcrumbs] = {31859},
        },
        [31838] = { -- Continue Your Training: Master Tsang
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66257}}}},
            [questKeys.breadcrumbs] = {31860},
        },
        [31839] = { -- Continue Your Training: Master Hsu
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66207}}}},
            [questKeys.breadcrumbs] = {31861},
        },
        [31840] = { -- Practice Makes Perfect: Master Cheng
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31834},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66258}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31841,31842,31843,31844,31845,31846},
        },
        [31841] = { -- Practice Makes Perfect: Master Woo
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31833},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66254}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31842,31843,31844,31845,31846},
        },
        [31842] = { -- Practice Makes Perfect: Master Kistane
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31835},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66253}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31843,31844,31845,31846},
        },
        [31843] = { -- Practice Makes Perfect: Master Yoon
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31836},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66255}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31844,31845,31846},
        },
        [31844] = { -- Practice Makes Perfect: Master Cheng
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31837},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66256}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31843,31845,31846},
        },
        [31845] = { -- Practice Makes Perfect: Master Tsang
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31838},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66257}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31843,31844,31846},
        },
        [31846] = { -- Practice Makes Perfect: Master Hsu
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.preQuestSingle] = {31839},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66207}}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {31840,31841,31842,31843,31844,31845},
        },
        [31847] = { -- Better Dead than Dread
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31391,31656,31886,31895},
        },
        [31850] = { -- Eric Davidson
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65655,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31851] = { -- Bill Buckler
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65656,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31852] = { -- Steven Lisbane
            [questKeys.requiredSpell] = 119467,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{63194,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31853] = { -- All Aboard!
            [questKeys.objectives] = {},
        },
        [31854] = { -- Analynn
            [questKeys.requiredSpell] = 119467,
            [questKeys.questFlags] = questFlags.DAILY,
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
            [questKeys.requiredSpell] = 119467,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66137,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31870] = { -- Cassandra Kaboom
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66422,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31871] = { -- Traitor Gluk
            [questKeys.requiredSpell] = 119467,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31872] = { -- Merda Stronghoof
            [questKeys.requiredSpell] = 119467,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66372,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31876] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,1},
        },
        [31877] = { -- The Inkmasters of the Arboretum
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
        [31886] = { -- Dread Space
            [questKeys.breadcrumbForQuestId] = 31001, -- check if it has any prequests
            [questKeys.exclusiveTo] = {31000,31390,31391,31656,31847,31895},
        },
        [31889] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE},{66436,nil,Questie.ICON_TYPE_PET_BATTLE},{66452,nil,Questie.ICON_TYPE_PET_BATTLE},{66442,nil,Questie.ICON_TYPE_PET_BATTLE},{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31728},
            [questKeys.nextQuestInChain] = 0,
        },
        [31891] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66352,nil,Questie.ICON_TYPE_PET_BATTLE},{66436,nil,Questie.ICON_TYPE_PET_BATTLE},{66452,nil,Questie.ICON_TYPE_PET_BATTLE},{66442,nil,Questie.ICON_TYPE_PET_BATTLE},{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31870},
            [questKeys.nextQuestInChain] = 0,
        },
        [31894] = { -- A Delicate Balance
            [questKeys.preQuestSingle] = {30784},
            [questKeys.breadcrumbForQuestId] = 30786,
        },
        [31895] = { -- Better Off Dread
            [questKeys.preQuestGroup] = {30926,30927,30928},
            [questKeys.breadcrumbForQuestId] = 31001,
            [questKeys.exclusiveTo] = {31000,31390,31391,31656,31847,31886},
        },
        [31897] = { -- Grand Master Trixxy
            [questKeys.preQuestSingle] = {31889,31891},
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66466,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31902] = { -- Battle Pet Tamers: Eastern Kingdoms
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66478,nil,Questie.ICON_TYPE_PET_BATTLE},{66512,nil,Questie.ICON_TYPE_PET_BATTLE},{66515,nil,Questie.ICON_TYPE_PET_BATTLE},{66518,nil,Questie.ICON_TYPE_PET_BATTLE},{66520,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31728},
            [questKeys.nextQuestInChain] = 0,
        },
        [31903] = { -- Battle Pet Tamers: Eastern Kingdoms
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66478,nil,Questie.ICON_TYPE_PET_BATTLE},{66512,nil,Questie.ICON_TYPE_PET_BATTLE},{66515,nil,Questie.ICON_TYPE_PET_BATTLE},{66518,nil,Questie.ICON_TYPE_PET_BATTLE},{66520,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31870},
            [questKeys.nextQuestInChain] = 0,
        },
        [31904] = { -- Cassandra Kaboom
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66422,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31905] = { -- Grazzle the Great
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66436,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31906] = { -- Kela Grimtotem
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66452,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31907] = { -- Zoltan
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66442,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31908] = { -- Elena Flutterfly
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66412,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31909] = { -- Grand Master Trixxy
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66466,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31897},
        },
        [31910] = { -- David Kosse
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66478,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31911] = { -- Deiza Plaguehorn
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66512,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31912] = { -- Kortas Darkhammer
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66515,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31913] = { -- Everessa
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66518,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31914] = { -- Durin Darkhammer
            [questKeys.requiredSpell] = 119467,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{66520,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31915] = { -- Grand Master Lydia Accoste
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66522,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31902,31903},
        },
        [31916] = { -- Grand Master Lydia Accoste
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66522,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31915},
        },
        [31917] = { -- A Tamer's Homecoming
            [questKeys.requiredSpell] = 119467,
        },
        [31918] = { -- A Tamer's Homecoming
            [questKeys.requiredSpell] = 119467,
        },
        [31919] = { -- Battle Pet Tamers: Outland
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31897,31915},
            [questKeys.objectives] = {{{66550,nil,Questie.ICON_TYPE_PET_BATTLE},{66551,nil,Questie.ICON_TYPE_PET_BATTLE},{66552,nil,Questie.ICON_TYPE_PET_BATTLE},{66553,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.nextQuestInChain] = 0,
        },
        [31920] = { -- Grand Master Antari
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66557,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31921] = { -- Battle Pet Tamers: Outland
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31897,31915},
            [questKeys.objectives] = {{{66550,nil,Questie.ICON_TYPE_PET_BATTLE},{66551,nil,Questie.ICON_TYPE_PET_BATTLE},{66552,nil,Questie.ICON_TYPE_PET_BATTLE},{66553,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.nextQuestInChain] = 0,
        },
        [31922] = { -- Nicki Tinytech
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66550,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31923] = { -- Ras'an
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66551,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31924] = { -- Narrok
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66552,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31925] = { -- Morulu The Elder
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66553,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31926] = { -- Grand Master Antari
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66557,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31927] = { -- Battle Pet Tamers: Northrend
            [questKeys.preQuestSingle] = {31920},
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.objectives] = {{{66635,nil,Questie.ICON_TYPE_PET_BATTLE},{66636,nil,Questie.ICON_TYPE_PET_BATTLE},{66638,nil,Questie.ICON_TYPE_PET_BATTLE},{66639,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31928] = { -- Grand Master Payne
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66675,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31929] = { -- Battle Pet Tamers: Northrend
            [questKeys.preQuestSingle] = {31920},
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.objectives] = {{{66635,nil,Questie.ICON_TYPE_PET_BATTLE},{66636,nil,Questie.ICON_TYPE_PET_BATTLE},{66638,nil,Questie.ICON_TYPE_PET_BATTLE},{66639,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31930] = { -- Battle Pet Tamers: Pandaria
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31970},
            [questKeys.nextQuestInChain] = 0,
            [questKeys.objectives] = {{{66730,nil,Questie.ICON_TYPE_PET_BATTLE},{66734,nil,Questie.ICON_TYPE_PET_BATTLE},{66733,nil,Questie.ICON_TYPE_PET_BATTLE},{66738,nil,Questie.ICON_TYPE_PET_BATTLE},{66918,nil,Questie.ICON_TYPE_PET_BATTLE},{66739,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31931] = { -- Beegle Blastfuse
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66635,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31932] = { -- Nearly Headless Jacob
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66636,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31933] = { -- Okrut Dragonwaste
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66638,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31934] = { -- Gutretch
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66639,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31935] = { -- Grand Master Payne
            [questKeys.requiredSpell] = 119467,
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
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31675,31942,31943,32682},
            [questKeys.requiredSourceItems] = {89328,89848},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31942] = { -- It's Melon Time
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31675,31941,31943,32682},
            [questKeys.requiredSourceItems] = {89329,89849},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31943] = { -- Which Berries? Witchberries.
            [questKeys.preQuestSingle] = {30257},
            [questKeys.exclusiveTo] = {31669,31670,31671,31672,31673,31674,31675,31941,31942,32682},
            [questKeys.requiredSourceItems] = {89326,89847},
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,6}},
        },
        [31944] = { -- Complete Your Training: The Final Test
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.breadcrumbs] = {31989},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",66744}}}},
        },
        [31945] = { -- Learn and Grow VI: Gina's Vote
            [questKeys.objectives] = {nil,nil,{{74843}},nil,{{{63160,63164,63165},63165,nil,Questie.ICON_TYPE_INTERACT},{{58563},58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {80591,84783},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,10},{factionIDs.GINA_MUDCLAW,26}},
        },
        [31946] = { -- Mung-Mung's Vote III: The Great Carrot Caper
            [questKeys.objectives] = {nil,nil,{{74841}},nil,{{{63154,63156,63158},63154,nil,Questie.ICON_TYPE_INTERACT},{{58563},58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30259},
            [questKeys.requiredSourceItems] = {80590,84782},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,15}},
        },
        [31947] = { -- Farmer Fung's Vote III: Crazy For Cabbage
            [questKeys.objectives] = {nil,nil,{{74840}},nil,{{{58567,63157,60113},58567,nil,Questie.ICON_TYPE_INTERACT},{{58563},58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {30518},
            [questKeys.requiredSourceItems] = {79102,80809},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,5},{factionIDs.FARMER_FUNG,21}},
        },
        [31948] = { -- Nana's Vote II: The Sacred Springs
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,15}},
        },
        [31949] = { -- Nana's Vote III: Witchberry Julep
            [questKeys.objectives] = {nil,nil,{{74846}},nil,{{{66080,66084,66085},66085,nil,Questie.ICON_TYPE_INTERACT},{{58563},58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {31948},
            [questKeys.requiredSourceItems] = {89326,89847},
            [questKeys.reputationReward] = {{factionIDs.THE_TILLERS,15}},
        },
        [31951] = { -- Grand Master Aki
            [questKeys.startedBy] = {{66741}},
            [questKeys.preQuestSingle] = {31930,31952},
            [questKeys.objectives] = {{{66741,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31952] = { -- Battle Pet Tamers: Pandaria
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.preQuestSingle] = {31970},
            [questKeys.objectives] = {{{66730,nil,Questie.ICON_TYPE_PET_BATTLE},{66734,nil,Questie.ICON_TYPE_PET_BATTLE},{66733,nil,Questie.ICON_TYPE_PET_BATTLE},{66738,nil,Questie.ICON_TYPE_PET_BATTLE},{66918,nil,Questie.ICON_TYPE_PET_BATTLE},{66739,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31953] = { -- Grand Master Hyuna
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66730,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31954] = { -- Grand Master Mo'ruk
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66733,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31955] = { -- Grand Master Nishi
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66734,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31956] = { -- Grand Master Yon
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66738,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31957] = { -- Grand Master Shu
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66739,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31958] = { -- Grand Master Aki
            [questKeys.preQuestSingle] = {31951},
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66741,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31959] = { -- The Empress' Gambit
            [questKeys.finishedBy] = {{110011}},
            [questKeys.preQuestGroup] = {
                31004, -- Kil'ruk the Wind-Reaver
                31086, -- Iyyokuk the Lucid
                31066, -- Malik the Unscathed
                31211, -- Xaril the Poisoned Mind
                31026, -- Korven the Prime
                31179, -- Skeer the Bloodseeker
                31354, -- Ka'roz the Locust
                31441, -- Hisek the Swarmkeeper
                31606, -- Rik'kal the Dissector
                31359,31092,31398, -- Kaz'tik the Manipulator
            },
            [questKeys.requiredMinRep] = {factionIDs.THE_KLAXXI,42000},
            [questKeys.objectives] = {{{66776,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31966] = { -- Battle Pet Tamers: Cataclysm
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31928},
            [questKeys.nextQuestInChain] = 0,
            [questKeys.objectives] = {{{66819,nil,Questie.ICON_TYPE_PET_BATTLE},{66815,nil,Questie.ICON_TYPE_PET_BATTLE},{66822,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31967] = { -- Battle Pet Tamers: Cataclysm
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31928},
            [questKeys.nextQuestInChain] = 0,
            [questKeys.objectives] = {{{66819,nil,Questie.ICON_TYPE_PET_BATTLE},{66815,nil,Questie.ICON_TYPE_PET_BATTLE},{66822,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31970] = { -- Grand Master Obalis
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31966,31967},
            [questKeys.objectives] = {{{66824,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31971] = { -- Grand Master Obalis
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31970},
            [questKeys.objectives] = {{{66824,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31972] = { -- Brok
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66819,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31973] = { -- Bordin Steadyfist
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66815,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31974] = { -- Goz Banefury
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{66822,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31975] = { -- The Returning Champion
            [questKeys.startedBy] = {{66466}},
            [questKeys.preQuestSingle] = {31897,31915},
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.exclusiveTo] = {31976},
        },
        [31976] = { -- The Returning Champion
            [questKeys.preQuestSingle] = {31897,31915},
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
            [questKeys.exclusiveTo] = {31975},
        },
        [31977] = { -- The Returning Champion
            [questKeys.preQuestSingle] = {31897,31915},
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
        },
        [31978] = { -- Priorities!
            [questKeys.objectives] = {nil,{{215695}}},
            [questKeys.preQuestSingle] = {31769},
            [questKeys.exclusiveTo] = {31772},
        },
        [31980] = { -- The Returning Champion
            [questKeys.preQuestSingle] = {31897,31915},
            [questKeys.requiredSpell] = 119467,
            [questKeys.nextQuestInChain] = 0,
        },
        [31981] = { -- Exceeding Expectations
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31920},
            [questKeys.nextQuestInChain] = 0,
        },
        [31982] = { -- Exceeding Expectations
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31920},
            [questKeys.nextQuestInChain] = 0,
        },
        [31983] = { -- A Brief Reprieve
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31928},
            [questKeys.nextQuestInChain] = 0,
        },
        [31984] = { -- A Brief Reprieve
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31928},
            [questKeys.nextQuestInChain] = 0,
        },
        [31985] = { -- The Triumphant Return
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31970},
            [questKeys.nextQuestInChain] = 0,
        },
        [31986] = { -- The Triumphant Return
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31970},
            [questKeys.nextQuestInChain] = 0,
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
            [questKeys.requiredSpell] = 119467,
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
            [questKeys.objectives] = {{{59150}}},
        },
        [32007] = {-- A Worthy Challenge: Darkmaster Gandling
            [questKeys.exclusiveTo] = {31998,32000,32001,32002,32003,32004,32005,32006},
        },
        [32008] = { -- Audrey Burnhep
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31785,31821,31822,31825,31826,31832}, -- not available once you turn any of these in
        },
        [32009] = { -- Varzok
            [questKeys.requiredSpell] = 119467,
            [questKeys.exclusiveTo] = {31823,31824,31827,31828,31830,31831}, -- not available once you turn any of these in
        },
        [32016] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{64029}},
            [questKeys.objectives] = {nil,{{440004}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- repeatable until you get max charms
            [questKeys.objectivesText] = {"Collect 50 Lesser Charms of Good Fortune."},
        },
        [32017] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{63996}},
            [questKeys.objectives] = {nil,{{440004}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE, -- repeatable until you get max charms
            [questKeys.objectivesText] = {"Collect 50 Lesser Charms of Good Fortune."},
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
            [questKeys.startedBy] = {{62667,63349}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {31066,31092,31359,31398,31354},
        },
        [32035] = { -- Got Silk?
            [questKeys.exclusiveTo] = {30072},
        },
        [32038] = { -- Stag Mastery
            [questKeys.preQuestSingle] = {30181},
        },
        [32108] = { -- Domination Point
            [questKeys.reputationReward] = {{factionIDs.HUOJIN_PANDAREN,5},{factionIDs.DOMINANCE_OFFENSIVE,7}},
        },
        [32109] = { -- Lion's Landing
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,3},{factionIDs.OPERATION_SHIELDWALL,7}},
        },
        [32115] = { -- Shackles of the Past
            [questKeys.preQuestSingle] = {32109}, -- TO DO add spawns to cave map
            [questKeys.exclusiveTo] = {32119},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32116] = { -- Priorities, People!
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32115,32119,32121,32122,32346,32347},
        },
        [32118] = { -- Taking Advantage
            [questKeys.breadcrumbs] = {32449},
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32120,32342,32343,32344,32345,32348},
        },
        [32119] = { -- It Is A Mystery
            [questKeys.preQuestSingle] = {32109}, -- TO DO add spawns to cave map
            [questKeys.exclusiveTo] = {32115},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32120] = { -- Legacy of Ogudei
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32121] = { -- The Spirit Trap
            [questKeys.preQuestSingle] = {32109}, -- TO DO add spawns to cave map
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32122] = { -- Ogudei's Lieutenants
            [questKeys.preQuestSingle] = {32109}, -- TO DO add spawns to cave map
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12}},
        },
        [32123] = { -- Death on Two Legs
            [questKeys.preQuestSingle] = {32108},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67425,67689,67905,67913,69029,67354},67354}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32126] = { -- Tear It Up
            [questKeys.preQuestSingle] = {32108},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67639,67969},67639,nil,Questie.ICON_TYPE_OBJECT}}},
        },
        [32127] = { -- All Dead, All Dead
            [questKeys.preQuestGroup] = {32126,32235},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32128] = { -- Another One Bites the Dust
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {32126,32235},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
            [questKeys.objectives] = {nil,{{216232},{216231}}},
        },
        [32130] = { -- Good Luck, Have Fun
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32131] = { -- We Require More Minerals!
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill them near stone blocks"),0,{{"monster",67449}}}},
            [questKeys.exclusiveTo] = {32134},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32132] = { -- Worker Harassment
            [questKeys.preQuestSingle] = {32108},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32133] = { -- Sentry Wards
            [questKeys.preQuestSingle] = {32108},
            [questKeys.objectives] = {{{67744,nil,Questie.ICON_TYPE_OBJECT},{67742,nil,Questie.ICON_TYPE_OBJECT},{67743,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32134] = { -- Hard Counter
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32131},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32135] = { -- Hero Killer
            [questKeys.preQuestSingle] = {32108},
            [questKeys.breadcrumbs] = {32450},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32136] = { -- Work Order: Fuel
            [questKeys.preQuestSingle] = {32108},
            [questKeys.nextQuestInChain] = 32137,
            [questKeys.exclusiveTo] = {32138,32140},
        },
        [32137] = { -- Runnin' On Empty
            [questKeys.preQuestGroup] = {32108,32136},
            [questKeys.exclusiveTo] = {32141,32236,32139,32238},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32138] = { -- Work Order: Lumber
            [questKeys.preQuestSingle] = {32108},
            [questKeys.nextQuestInChain] = 32139,
            [questKeys.exclusiveTo] = {32136,32140},
        },
        [32139] = { -- Stacked!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {32108,32138},
            [questKeys.objectives] = {nil,{{216177}}},
            [questKeys.exclusiveTo] = {32137,32237,32141,32236},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32140] = { -- Work Order: Fuel
            [questKeys.preQuestSingle] = {32108},
            [questKeys.nextQuestInChain] = 32141,
            [questKeys.exclusiveTo] = {32136,32138},
        },
        [32141] = { -- Power Metal
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {32108,32140},
            [questKeys.exclusiveTo] = {32137,32237,32139,32238},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32142] = { -- We Will Rock You
            [questKeys.preQuestSingle] = {32109},
            [questKeys.breadcrumbs] = {32451},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32143] = { -- A Kind of Magic
            [questKeys.preQuestSingle] = {32109},
            [questKeys.objectives] = {{{67544,nil,Questie.ICON_TYPE_INTERACT},{67546,nil,Questie.ICON_TYPE_INTERACT},{67547,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32144] = { -- Under Pressure
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32145] = { -- Don't Lose Your Head
            [questKeys.preQuestSingle] = {32143},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12}},
        },
        [32146] = { -- Hammer to Fall
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32148] = { -- Attack! Move!
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32149] = { -- Resource Gathering
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32150] = { -- Supply Block
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32151] = { -- Tower Defense
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32152},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill them near stone blocks"),0,{{"monster",67449}}}},
        },
        [32152] = { -- Siege Damage
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32151},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
            [questKeys.objectives] = {nil,nil,{{92493}},nil,{{{67671},67671}}},
        },
        [32153] = { -- Hero Killer
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12}},
        },
        [32154] = { -- Burn Out!
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32155},
            [questKeys.objectives] = {nil,{{216743},{216744},{216745}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32155] = { -- Necessary Breaks
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32154},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32156] = { -- It's Only Right
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32157] = { -- The Only Good Goblin...
            [questKeys.preQuestSingle] = {32109},
            [questKeys.breadcrumbs] = {32452},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67281,67283,67563,67564,67637,67638,67869,67870,67871,67873},67873}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32158] = { -- Two Step Program
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32433},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12}},
        },
        [32159] = { -- Circle of Life
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32446},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32161] = { -- Beastmaster's Hunt: The Crane
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32162] = { -- Beastmaster's Hunt: The Tiger
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32163] = { -- Beastmaster's Hunt: The Crab
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32164] = { -- Beastmaster's Hunt: The Crane
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32165] = { -- Beastmaster's Hunt: The Tiger
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32166] = { -- Beastmaster's Hunt: The Crab
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32167] = { -- Ancient's Fall
            [questKeys.startedBy] = {{67436}},
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31}},
            [questKeys.exclusiveTo] = {32168,32169},
        },
        [32168] = { -- End of an Elder
            [questKeys.startedBy] = {{67438}},
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31}},
            [questKeys.exclusiveTo] = {32167,32169},
        },
        [32169] = { -- A Colossal Victory
            [questKeys.startedBy] = {{67439}},
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31}},
            [questKeys.exclusiveTo] = {32167,32168},
        },
        [32170] = { -- Ancient's Fall
            [questKeys.startedBy] = {{67555}},
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
            [questKeys.exclusiveTo] = {32171,32172},
        },
        [32171] = { -- End of an Elder
            [questKeys.startedBy] = {{67556}},
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
            [questKeys.exclusiveTo] = {32170,32172},
        },
        [32172] = { -- A Colossal Victory
            [questKeys.startedBy] = {{67557}},
            [questKeys.preQuestSingle] = {32109},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
            [questKeys.exclusiveTo] = {32170,32171},
        },
        [32175] = { -- Darkmoon Pet Battle!
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{67370,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32181] = { -- Beastmaster's Quarry: The Crane
            [questKeys.preQuestSingle] = {32161},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32182] = { -- Beastmaster's Quarry: The Tiger
            [questKeys.preQuestSingle] = {32162},
            [questKeys.questFlags] = questFlags.DAILY,
            -- [questKeys.startedBy] = {{67498}}, -- need to see if also by 67438 north of the horde base
        },
        [32183] = { -- Beastmaster's Quarry: The Crab
            [questKeys.preQuestSingle] = {32163},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32184] = { -- Beastmaster's Quarry: The Crane
            [questKeys.preQuestSingle] = {32164},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32185] = { -- Beastmaster's Quarry: The Tiger
            [questKeys.preQuestSingle] = {32165},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.startedBy] = {{67438,67498}},
        },
        [32186] = { -- Beastmaster's Quarry: The Crab
            [questKeys.preQuestSingle] = {32166},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32189] = { -- A Shabby New Face
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,21000},
        },
        [32190] = { -- To Mogujia
            [questKeys.preQuestSingle] = {32372},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,11850},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
            [questKeys.objectives] = {{{67581,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Mogujia"),0,{{"monster",68681}}}},
        },
        [32191] = { -- Ancient Guardians
            [questKeys.preQuestSingle] = {32190},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,11850},
        },
        [32192] = { -- Bloodlines
            [questKeys.preQuestSingle] = {32190},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,11850},
            [questKeys.objectives] = {{{67587}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the ones near Blood Elves in fire pillars"),0,{{"monster",67587}}}},
        },
        [32193] = { -- To Mogujia
            [questKeys.preQuestSingle] = {32362},
            [questKeys.objectives] = {{{67682,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,15800},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Mogujia"),0,{{"monster",68741}}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32194] = { -- Bad Blood
            [questKeys.preQuestSingle] = {32193},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,15800},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32197] = { -- Mystery Meatloaf
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32199},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32198] = { -- One Magical, Flying Kingdom's Trash...
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,21000},
            [questKeys.preQuestSingle] = {32189},
        },
        [32199] = { -- Krasarang Steampot
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32197},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32200] = { -- Dangers of Za'Tual
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.breadcrumbs] = {32733},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32201] = { -- Grave Circumstances
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.breadcrumbs] = {32728},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32204] = { -- The Skumblade Threat
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.breadcrumbs] = {32730},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32206] = { -- This Just Won't Do
            [questKeys.preQuestSingle] = {32259},
        },
        [32207] = { -- Saur Loser
            [questKeys.preQuestSingle] = {32259},
        },
        [32208] = { -- Maximum Capacitor
            [questKeys.objectives] = {{{69316,nil,Questie.ICON_TYPE_OBJECT},{69319,nil,Questie.ICON_TYPE_OBJECT},{69320,nil,Questie.ICON_TYPE_OBJECT},{69326}}},
        },
        [32209] = { -- Save Our Scouts!
            [questKeys.objectives] = {{{69357,nil,Questie.ICON_TYPE_INTERACT},{69356,nil,Questie.ICON_TYPE_INTERACT},{69355,nil,Questie.ICON_TYPE_INTERACT},{69326}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32212] = { -- The Assault on Zeb'tula
            [questKeys.startedBy] = {{67990}},
            [questKeys.objectives] = {{{67990,nil,Questie.ICON_TYPE_TALK},{69775}}},
            [questKeys.preQuestSingle] = {32680},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,12}},
        },
        [32213] = { -- Old Enemies
            [questKeys.preQuestSingle] = {32258},
        },
        [32214] = { -- Bilgewater Infiltrators
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32221},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32215] = { -- Heinous Sacrifice
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {nil,{{218797},{218798},{218801}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32216] = { -- Pterrible Ptorment
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Arcweaver"),0,{{"monster",69224}}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
            [questKeys.objectives] = {{{69263,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32217] = { -- Dark Offerings
            [questKeys.objectives] = {nil,{{216991}}},
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32218] = { -- Ashes of the Enemy
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{69331,69337},69337,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32219] = { -- Stone Cold
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32220] = { -- Soul Surrender
            [questKeys.objectives] = {nil,nil,nil,nil,{{{69265,69267,69305,69444,69426},69426,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",217768}}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
        },
        [32221] = { -- Storming the Beach
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32214},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67354,67425,67689,67905,69029,67971},67971}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32222] = { -- Wanted: Chief Engineer Cogwrench
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32223},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32223] = { -- Wanted: Lieutenant Ethan Jacobson
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32222},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32224] = { -- Rise No More!
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32225] = { -- The Call of Thunder
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {{{69369,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Shan'ze Thundercallers"),0,{{"monster",71511}}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32226] = { -- Into the Crypts
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon Gura"),0,{{"object",218081}}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32227] = { -- Preventing a Future Threat
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {{{69128,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
            [questKeys.objectivesText] = {"Frighten 12 Hatchling Skyscreamers by running near them."},
        },
        [32228] = { -- The Shuddering Moor
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32230] = { -- The Zandalari Colossus
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32232] = { -- What's Inside Counts
            [questKeys.preQuestSingle] = {32259},
        },
        [32233] = { -- Very Disarming
            [questKeys.preQuestSingle] = {32259},
        },
        [32234] = { -- Knowledge Is Power
            [questKeys.preQuestSingle] = {32259},
        },
        [32235] = { -- Flash! Aaaaaahhhh!
            [questKeys.preQuestSingle] = {32108},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32236] = { -- Bug Off!
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {32136,32137,32237,32138,32139,32238},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32237] = { -- Precious Resource
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {32141,32236,32138,32139,32140,32238},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32238] = { -- Universal Remote-Explode
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.exclusiveTo] = {32136,32137,32237,32140,32141,32236},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32299] = { -- Just Some Light Clean-Up Work
            [questKeys.objectives] = {{{69251}}},
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32242] = { -- Buried Secrets
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,3950},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32243] = { -- The Source of Korune Power
            [questKeys.preQuestSingle] = {32193},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,15800},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32244] = { -- The Korune
            [questKeys.preQuestSingle] = {32190},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,11850},
        },
        [32246] = { -- Meet the Scout
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,3},{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32247] = { -- A King Among Men
            [questKeys.preQuestSingle] = {32246},
            [questKeys.objectives] = {{{68331,nil,Questie.ICON_TYPE_EVENT},{68312,nil,Questie.ICON_TYPE_EVENT}},nil,nil,nil,{{{68332,68333,68334},68332}}},
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,3},{factionIDs.OPERATION_SHIELDWALL,12}},
        },
        [32248] = { -- A Little Patience
            [questKeys.preQuestSingle] = {32109},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32249] = { -- Meet the Scout
            [questKeys.reputationReward] = {{factionIDs.HUOJIN_PANDAREN,1},{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32250] = { -- The Might of the Warchief
            [questKeys.objectives] = {{{67927,nil,Questie.ICON_TYPE_EVENT},{67926,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{67900,67901,67902},67900}}},
            [questKeys.preQuestSingle] = {32249},
            [questKeys.reputationReward] = {{factionIDs.HUOJIN_PANDAREN,5},{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32251] = { -- Dagger in the Dark
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {32108},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32252] = { -- Harbingers of the Loa
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32254] = { -- Manipulating the Saurok
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {{{69293,nil,Questie.ICON_TYPE_TALK},{69309,nil,Questie.ICON_TYPE_TALK},{69310,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32255] = { -- De-Constructed
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {{{69287,nil,Questie.ICON_TYPE_OBJECT},{69288,nil,Questie.ICON_TYPE_OBJECT},{69290,nil,Questie.ICON_TYPE_OBJECT},{69289,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32256] = { -- Rise Of An Empire
            [questKeys.preQuestSingle] = {32251},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Shrine"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{67840,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,3950},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32257] = { -- Voice of the Gods
            [questKeys.objectives] = {{{67833,nil,Questie.ICON_TYPE_INTERACT}},nil,{{92425}}},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,3950},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32258] = { -- Horde Quest Choice: PvP
            [questKeys.startedBy] = {{70567}},
            [questKeys.finishedBy] = {{70567}},
            [questKeys.reputationReward] = {},
            [questKeys.preQuestSingle] = {32212},
            [questKeys.exclusiveTo] = {32259},
        },
        [32259] = { -- Horde Quest Choice: PvE
            [questKeys.startedBy] = {{70567}},
            [questKeys.finishedBy] = {{70567}},
            [questKeys.reputationReward] = {},
            [questKeys.preQuestSingle] = {32212},
            [questKeys.exclusiveTo] = {32258},
        },
        [32260] = { -- Alliance Quest Choice: PvE
            [questKeys.startedBy] = {{70561}},
            [questKeys.finishedBy] = {{70561}},
            [questKeys.reputationReward] = {},
            [questKeys.preQuestSingle] = {32644},
            [questKeys.exclusiveTo] = {32261},
        },
        [32261] = { -- Alliance Quest Choice: PvP
            [questKeys.startedBy] = {{70561}},
            [questKeys.finishedBy] = {{70561}},
            [questKeys.reputationReward] = {},
            [questKeys.preQuestSingle] = {32644},
            [questKeys.exclusiveTo] = {32260},
        },
        [32262] = { -- Captive Audience
            [questKeys.preQuestSingle] = {32258},
        },
        [32264] = { -- Spellbound
            [questKeys.preQuestSingle] = {32258},
        },
        [32265] = { -- Charged Moganite
            [questKeys.preQuestSingle] = {32258},
        },
        [32266] = { -- Mana Manifestations
            [questKeys.preQuestSingle] = {32258},
        },
        [32268] = { -- Tactical Mana Bombs
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.preQuestSingle] = {32258},
        },
        [32269] = { -- Breaking Down the Defenses
            [questKeys.preQuestSingle] = {32258},
        },
        [32274] = { -- The Residents of Ihgaluk
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32275] = { -- Surgical Death
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{69379,69397,69412,69780,70377,70509,69065},69065},{{69171},69171},{{69254,69255,69256,69225},69225}}},
        },
        [32276] = { -- Tear Down This Wall!
            [questKeys.preQuestSingle] = {32212},
            [questKeys.objectives] = {{{67990,nil,Questie.ICON_TYPE_TALK},{69755}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,12}},
        },
        [32277] = { -- To the Skies!
            [questKeys.finishedBy] = {{67990}},
            [questKeys.objectives] = {{{67990,nil,Questie.ICON_TYPE_TALK},{69923}}},
            [questKeys.preQuestSingle] = {32276},
        },
        [32278] = { -- Decisive Action
            [questKeys.preQuestSingle] = {32277},
        },
        [32279] = { -- The Fall of Shan Bu
            [questKeys.preQuestSingle] = {32278},
        },
        [32282] = { -- Compy Stomp
            [questKeys.preQuestSingle] = {32259},
        },
        [32283] = { -- Loa-saur
            [questKeys.preQuestSingle] = {32259},
        },
        [32284] = { -- Someone You Should See
            [questKeys.preQuestSingle] = {32257},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,7900},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Binan Village"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{67866,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32285] = { -- The Sleepless Legion
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32287] = { -- Enemies Beneath the Tower
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32288] = { -- Bolstering the Defenses
            [questKeys.preQuestSingle] = {32258},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32292] = { -- Forge Ahead!
            [questKeys.preQuestSingle] = {32208,32209},
        },
        [32293] = { -- Among the Bones
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259}, -- further handled in questHubs
            [questKeys.exclusiveTo] = {32561,32562},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,31}},
        },
        [32294] = { -- Raining Bones
            [questKeys.preQuestSingle] = {32259},
        },
        [32296] = { -- Treasures of the Thunder King
            [questKeys.finishedBy] = {{70316,70320}},
            [questKeys.preQuestSingle] = {32680,32681},
            [questKeys.objectives] = {{{70316,nil,Questie.ICON_TYPE_TALK},{70321,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32297] = { -- Direhorn or Devilsaur
            [questKeys.preQuestSingle] = {32259},
        },
        [32298] = { -- Dino Might
            [questKeys.preQuestSingle] = {32259},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredSourceItems] = {93668},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58071,67576,69183,69207},67576,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32300] = { -- Disarming Irony
            [questKeys.preQuestSingle] = {32258},
        },
        [32301] = { -- Old Enemies
            [questKeys.preQuestSingle] = {32261},
        },
        [32302] = { -- Desconstruction
            [questKeys.preQuestSingle] = {32258},
        },
        [32303] = { -- Made for War
            [questKeys.preQuestSingle] = {32258},
        },
        [32304] = { -- High Recognition
            [questKeys.preQuestSingle] = {32258},
        },
        [32305] = { -- Overpowered
            [questKeys.preQuestSingle] = {32258},
        },
        [32315] = { -- Anduin's Plea
            [questKeys.preQuestGroup] = {32194,32243},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,19750},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Shrine"),0,{{"monster",68741}}}},
            [questKeys.objectives] = {{{67948,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
        },
        [32316] = { -- Heart Of The Alliance
            [questKeys.preQuestSingle] = {32315},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,19750},
            [questKeys.objectives] = {{{68006,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,7}},
        },
        [32317] = { -- Seeking the Soulstones
            [questKeys.objectives] = {nil,nil,{{92494},{92495},{92496},{92497}}},
        },
        [32318] = { -- Regeneration Takes Time
            [questKeys.preQuestSingle] = {32284},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,7900},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [32319] = { -- Find Thrall!
            [questKeys.preQuestSingle] = {32318},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,7900},
            [questKeys.reputationReward] = {{factionIDs.DARKSPEAR_TROLLS,5},{factionIDs.DOMINANCE_OFFENSIVE,31}},
            [questKeys.objectives] = {{{68023,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32320] = { -- The Horde Is Family
            [questKeys.preQuestSingle] = {32319},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,7900},
            [questKeys.reputationReward] = {{factionIDs.DARKSPEAR_TROLLS,5},{factionIDs.DOMINANCE_OFFENSIVE,6}},
        },
        [32321] = { -- The Monkey King
            [questKeys.preQuestSingle] = {32355},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,35500},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
            [questKeys.objectives] = {{{68004,nil,Questie.ICON_TYPE_TALK},{68150,nil,Questie.ICON_TYPE_EVENT},{68005}}},
        },
        [32326] = { -- Insertion
            [questKeys.preQuestSingle] = {32392},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,35500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
            [questKeys.objectives] = {nil,{{216710}}},
        },
        [32327] = { -- The Darnassus Mission
            [questKeys.preQuestSingle] = {32326},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,35500},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Start the event"),0,{{"monster",68077}}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,15},{factionIDs.HORDE,6}},
            [questKeys.objectives] = {{{68076,nil,Questie.ICON_TYPE_EVENT}},{{216347}}},
        },
        [32328] = { -- Victorious Return
            [questKeys.preQuestSingle] = {32327},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,35500},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Go through the portal"),0,{{"monster",68582}}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,15}},
        },
        [32329] = { -- Get My Results!
            [questKeys.objectives] = {nil,{{215126}}},
            [questKeys.preQuestSingle] = {32352},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,23700},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.SILVERMOON_CITY,31}},
        },
        [32330] = { -- What's in the Box?
            [questKeys.startedBy] = {{16802}},
            [questKeys.preQuestSingle] = {32329},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,23700},
            [questKeys.objectives] = {{{68430,nil,Questie.ICON_TYPE_EVENT},{68086,nil,Questie.ICON_TYPE_TALK},{68085,nil,Questie.ICON_TYPE_TALK},{68259}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the box"),0,{{"object",216484}}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,7},{factionIDs.SILVERMOON_CITY,7}},
        },
        [32331] = { -- The Kirin Tor
            [questKeys.preQuestGroup] = {32383,32397},
            [questKeys.objectives] = {nil,{{216420}}},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,11850},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
        },
        [32332] = { -- The First Riddle: Mercy
            [questKeys.preQuestSingle] = {32321},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,35500},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the amber"),0,{{"object",216360}}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [32333] = { -- The Second Riddle: Fellowship
            [questKeys.preQuestSingle] = {32321},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,35500},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [32334] = { -- The Third Riddle: Strength
            [questKeys.preQuestSingle] = {32321},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,35500},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [32335] = { -- The Greatest Prank
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {32332,32333,32334},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,35500},
            [questKeys.objectives] = {{{68538,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32336] = { -- The Handle
            [questKeys.preQuestSingle] = {32335},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,39500},
        },
        [32337] = { -- The Head
            [questKeys.preQuestSingle] = {32335},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,39500},
            [questKeys.objectives] = {{{68554,nil,Questie.ICON_TYPE_TALK}},nil,{{92560}}},
        },
        [32338] = { -- The Harmonic Ointment
            [questKeys.preQuestSingle] = {32335},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,39500},
        },
        [32341] = { -- Demonstrate Your Power
            [questKeys.objectives] = {nil,nil,nil,nil,{{{68175,68176,68204,68205,68206},68206}}},
        },
        [32342] = { -- The Spirit Trap
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32343] = { -- Ogudei's Lieutenants
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32344] = { -- It Is A Mystery
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32345},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32345] = { -- We're Not Monsters!
            [questKeys.preQuestSingle] = {32108},
            [questKeys.exclusiveTo] = {32344},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32346] = { -- Oi Ain't Afraid o' No Ghosts!
            [questKeys.preQuestSingle] = {32109}, -- TO DO add spawns to cave map
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32347] = { -- Eviction Notice
            [questKeys.preQuestSingle] = {32109}, -- TO DO add spawns to cave map
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32348] = { -- Kick 'em While They're Down
            [questKeys.preQuestSingle] = {32108},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32351] = { -- Echoes of Thunder
            [questKeys.preQuestSingle] = {32384},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,19750},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Shrine"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{68287,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31}},
        },
        [32352] = { -- A Gathering Storm
            [questKeys.preQuestSingle] = {32351},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,19750},
            [questKeys.objectives] = {{{68284,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,7},{factionIDs.HUOJIN_PANDAREN,27}},
        },
        [32355] = { -- The Harmonic Mallet
            [questKeys.preQuestSingle] = {32423},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,35500},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Valley of Emperors"),0,{{"monster",68741}}}},
            [questKeys.objectives] = {{{68004,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,33}},
        },
        [32362] = { -- The Fate of Dalaran
            [questKeys.preQuestSingle] = {32331},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,11850},
            [questKeys.objectives] = {{{68108,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,6},{factionIDs.OPERATION_SHIELDWALL,7}},
        },
        [32363] = { -- The Kun-Lai Expedition
            [questKeys.preQuestSingle] = {32330},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,27650},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Garrosh'ar Advance"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{68287,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32368] = { -- Memory Wine
            [questKeys.preQuestSingle] = {32448},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,27650},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
            [questKeys.objectives] = {{{68362,nil,Questie.ICON_TYPE_EVENT},{68357,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,7}},
        },
        [32370] = { -- The Kun-Lai Expedition
            [questKeys.preQuestSingle] = {32316},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,23700},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Grummle Bazaar"),0,{{"monster",68741}}}},
            [questKeys.objectives] = {{{68375,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32371] = { -- Memory Wine
            [questKeys.preQuestSingle] = {32377},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,23700},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32372] = { -- De-Subjugation
            [questKeys.preQuestSingle] = {32320},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,7900},
            [questKeys.reputationReward] = {{factionIDs.DARKSPEAR_TROLLS,7},{factionIDs.DOMINANCE_OFFENSIVE,32}},
        },
        [32373] = { -- The Measure of a Leader
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {31483},
            [questKeys.objectives] = {{{64616,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32374] = { -- The Prince's Pursuit
            [questKeys.startedBy] = {{64616}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.preQuestSingle] = {32373},
        },
        [32376] = { -- To the Valley!
            [questKeys.preQuestGroup] = {32191,32192,32244},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,15800},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Valley of Emperors"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{68370,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,4}},
        },
        [32377] = { -- A Kor'kron In Our Midst
            [questKeys.preQuestSingle] = {32370},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,23700},
            [questKeys.requiredSourceItems] = {92763,92764,92765},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32378] = { -- Clearing a Path
            [questKeys.preQuestSingle] = {32376},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,15800},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31}},
        },
        [32379] = { -- Legacy of the Korune
            [questKeys.preQuestSingle] = {32376},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,15800},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31}},
        },
        [32380] = { -- The Best Around
            [questKeys.preQuestSingle] = {32248},
            [questKeys.objectives] = {{{68952,nil,Questie.ICON_TYPE_EVENT},{68526,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,3950},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32381] = { -- To Catch A Spy
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Grab the drinks"),0,{{"monster",68526}}}},
            [questKeys.objectives] = {{{68537,nil,Questie.ICON_TYPE_TALK},{68540,nil,Questie.ICON_TYPE_TALK},{68539,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,3950},
            [questKeys.requiredSourceItems] = {92975,92976,92977},
            [questKeys.nextQuestInChain] = 32426,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32382] = { -- He's In Deep
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Fire Camp Bataar"),0,{{"monster",68741}}}},
            [questKeys.preQuestSingle] = {32381},
            [questKeys.objectives] = {{{68417,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,7900},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32383] = { -- Bugging Out
            [questKeys.preQuestSingle] = {32382},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,7900},
            [questKeys.objectives] = {{{68913,nil,Questie.ICON_TYPE_OBJECT},{68913,nil,Questie.ICON_TYPE_OBJECT},{68913,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32384] = { -- Trapping the Leader
            [questKeys.preQuestGroup] = {32378,32379},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,15800},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32388] = { -- A Change of Command
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestGroup] = {32374,32474},
        },
        [32389] = { -- The Lion Roars
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestGroup] = {32374,32474},
        },
        [32390] = { -- Call of the Packmaster
            [questKeys.preQuestGroup] = {32388,32389},
            [questKeys.startedBy] = {{64616}},
            [questKeys.objectives] = {{{64616,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32391] = { -- The Ruins of Korune
            [questKeys.preQuestSingle] = {32368},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,31650},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Ruins of Korune"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{68337,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,1}},
        },
        [32392] = { -- The Divine Bell
            [questKeys.finishedBy] = {{68337}},
            [questKeys.preQuestSingle] = {32391},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,31650},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,7},{factionIDs.HORDE,6}},
        },
        [32393] = { -- The Ruins of Korune
            [questKeys.preQuestSingle] = {32371},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,27650},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to the Ruins of Korune"),0,{{"monster",68741}}}},
            [questKeys.objectives] = {{{67734,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
        },
        [32394] = { -- The Divine Bell
            [questKeys.preQuestSingle] = {32393},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,27650},
            [questKeys.finishedBy] = {{67951}},
            [questKeys.objectives] = {{{68504}},{{216678}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,7}},
        },
        [32397] = { -- He Won't Even Miss It
            [questKeys.preQuestSingle] = {32382},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,7900},
            [questKeys.objectives] = {{{68413,nil,Questie.ICON_TYPE_INTERACT}},nil,{{92804}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32398] = { -- The Bell Speaks
            [questKeys.preQuestSingle] = {32412},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,42000},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Emperor's Reach"),0,{{"monster",68681}}}},
            [questKeys.objectives] = {{{67844,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32399] = { -- Breath of Darkest Shadow
            [questKeys.preQuestSingle] = {32398},
            [questKeys.objectives] = {{{68225},{68987,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,42000},
        },
        [32400] = { -- The Bell Speaks
            [questKeys.preQuestGroup] = {32336,32337,32338},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,42000},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Fly to Emperor's Reach"),0,{{"monster",68741}}}},
            [questKeys.objectives] = {{{68939,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32401] = { -- Breath of Darkest Shadow
            [questKeys.preQuestSingle] = {32400},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,42000},
            [questKeys.objectives] = {{{68936}},{{216721}}},
        },
        [32402] = { -- The Situation In Dalaran
            [questKeys.preQuestSingle] = {32328},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.objectives] = {{{67785,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,33}},
        },
        [32403] = { -- It Starts in the Sewers
            [questKeys.preQuestSingle] = {32402},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.objectives] = {{{68695,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32404] = { -- Violence in the Arena
            [questKeys.preQuestSingle] = {32403},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32405] = { -- Hand of the Silver Covenant
            [questKeys.preQuestSingle] = {32404},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32406] = { -- A Tactical Assault
            [questKeys.preQuestSingle] = {32405},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32408] = { -- The Silver Covenant's Stronghold
            [questKeys.preQuestSingle] = {32406},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32409] = { -- The Kirin Tor's True Colors
            [questKeys.preQuestSingle] = {32406},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32410] = { -- Krasus' Landing
            [questKeys.preQuestSingle] = {32406},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.objectives] = {{{68728,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32411] = { -- The Remaining Sunreavers
            [questKeys.preQuestGroup] = {32408,32409,32410},
            [questKeys.objectives] = {{{68711,nil,Questie.ICON_TYPE_INTERACT},{68714,nil,Questie.ICON_TYPE_INTERACT},{68715,nil,Questie.ICON_TYPE_INTERACT},{68716,nil,Questie.ICON_TYPE_INTERACT},{68717,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,5},{factionIDs.HORDE,5}},
        },
        [32412] = { -- One Last Grasp
            [questKeys.preQuestSingle] = {32411},
            [questKeys.objectives] = {{{68632},{68635,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Go through the portal"),0,{{"monster",68636}}}},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,6},{factionIDs.HORDE,7}},
        },
        [32413] = { -- A Return to Krasarang
            [questKeys.preQuestSingle] = {32412},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,39500},
            [questKeys.exclusiveTo] = {32398},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,31},{factionIDs.HORDE,5}},
        },
        [32414] = { -- Darnassus Attacked?
            [questKeys.preQuestSingle] = {32394},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {{{67848,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,33}},
        },
        [32416] = { -- Jaina's Resolution
            [questKeys.preQuestSingle] = {32460},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {nil,{{216720}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,33}},
        },
        [32417] = { -- Sewer Cleaning
            [questKeys.preQuestSingle] = {32416},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{68756,68757,68758,68647},68647}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31},{factionIDs.ALLIANCE,5}},
        },
        [32418] = { -- Unfair Trade
            [questKeys.preQuestSingle] = {32416},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31},{factionIDs.ALLIANCE,5}},
        },
        [32419] = { -- Nowhere to Hide
            [questKeys.preQuestSingle] = {32416},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{68051,68760,68761,68050},68050}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31},{factionIDs.ALLIANCE,5}},
        },
        [32420] = { -- Cashing Out
            [questKeys.preQuestSingle] = {32416},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12},{factionIDs.ALLIANCE,5}},
        },
        [32421] = { -- Nowhere to Run
            [questKeys.preQuestSingle] = {32416},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {{{68762,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12},{factionIDs.ALLIANCE,5}},
        },
        [32423] = { -- What Had To Be Done
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {32417,32418,32419,32420,32421},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {{{68687,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,6},{factionIDs.ALLIANCE,6}},
        },
        [32426] = { -- Stirred, Not Shaken
            [questKeys.preQuestSingle] = {32381},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,3950},
            [questKeys.nextQuestInChain] = 32382,
            [questKeys.requiredSourceItems] = {92978},
            [questKeys.objectives] = {{{68531,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,15}},
        },
        [32427] = { -- The Measure of a Leader
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {31483},
            [questKeys.objectives] = {{{64616,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32428] = { -- Pandaren Spirit Tamer
            [questKeys.requiredSpell] = 119467,
            [questKeys.preQuestSingle] = {31951},
            [questKeys.objectives] = {{{68463,nil,Questie.ICON_TYPE_PET_BATTLE},{68465,nil,Questie.ICON_TYPE_PET_BATTLE},{68464,nil,Questie.ICON_TYPE_PET_BATTLE},{68462,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32429] = { -- The Prince's Pursuit
            [questKeys.startedBy] = {{64616}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.preQuestSingle] = {32427},
        },
        [32430] = { -- A Change of Command
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestGroup] = {32429,32476},
        },
        [32431] = { -- Glory to the Horde
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestGroup] = {32429,32476},
        },
        [32432] = { -- The Soul of the Horde
            [questKeys.preQuestGroup] = {32430,32431},
            [questKeys.startedBy] = {{64616}},
            [questKeys.objectives] = {{{64616,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32433] = { -- Undermining the Under Miner
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32158},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,12}},
        },
        [32434] = { -- Burning Pandaren Spirit
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68463,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32435] = { -- Second Place
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [32436] = { -- Third Place
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [32439] = { -- Flowing Pandaren Spirit
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68462,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32440] = { -- Whispering Pandaren Spirit
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68464,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32441] = { -- Thundering Pandaren Spirit
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68465,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32446] = { -- Dis-Assembly Required
            [questKeys.preQuestSingle] = {32109},
            [questKeys.exclusiveTo] = {32159},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,4}},
        },
        [32448] = { -- Ties with the Past
            [questKeys.preQuestSingle] = {32363},
            [questKeys.requiredMinRep] = {factionIDs.DOMINANCE_OFFENSIVE,27650},
            [questKeys.reputationReward] = {{factionIDs.DOMINANCE_OFFENSIVE,12}},
        },
        [32449] = { -- The Ruins of Ogudei
            [questKeys.preQuestSingle] = {32108},
            [questKeys.breadcrumbForQuestId] = 32118,
        },
        [32450] = { -- The Time Is Now!
            [questKeys.preQuestSingle] = {32108},
            [questKeys.breadcrumbForQuestId] = 32135,
        },
        [32451] = { -- Send A Message
            [questKeys.preQuestSingle] = {32109},
            [questKeys.breadcrumbForQuestId] = 32142,
        },
        [32452] = { -- And Then There Were Goblins
            [questKeys.preQuestSingle] = {32109},
            [questKeys.breadcrumbForQuestId] = 32157,
        },
        [32455] = { -- The Silence
            [questKeys.preQuestSingle] = {32401},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,42000},
            [questKeys.objectives] = {{{68928,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [32457] = { -- The Thunder King
            [questKeys.startedBy] = {{64616}},
            [questKeys.finishedBy] = {{64616,69782}},
            [questKeys.preQuestSingle] = {32390,32432},
            [questKeys.nextQuestInChain] = 32590,
            [questKeys.breadcrumbForQuestId] = 32590,
        },
        [32460] = { -- Tracking the Thieves
            [questKeys.preQuestSingle] = {32414},
            [questKeys.requiredMinRep] = {factionIDs.OPERATION_SHIELDWALL,29900},
            [questKeys.objectives] = {nil,{{216720}}},
            [questKeys.reputationReward] = {{factionIDs.OPERATION_SHIELDWALL,31}},
        },
        [32461] = { -- The Order of the Cloud Serpent
            [questKeys.breadcrumbForQuestId] = 30134,
            [questKeys.exclusiveTo] = {31373,31375},
        },
        [32474] = { -- A Test of Valor
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {32373},
            [questKeys.objectivesText] = {"Gain the \"A Test of Valor\" Achievement by earning a total of 1600 Valor Points."},
        },
        [32476] = { -- A Test of Valor
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {32427},
            [questKeys.objectivesText] = {"Gain the \"A Test of Valor\" Achievement by earning a total of 1600 Valor Points."},
        },
        [32485] = { -- Bolstering the Defenses
            [questKeys.preQuestSingle] = {32261},
        },
        [32489] = { -- The Creeping Carpet of Ihgaluk
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32491] = { -- Left To Rot
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32493] = { -- They All Fall Down
            [questKeys.preQuestSingle] = {32259},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32494] = { -- Power Play
            [questKeys.preQuestSingle] = {32259},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32495] = { -- The Bloodletter
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32505] = { -- The Crumbled Chamberlain
            [questKeys.preQuestSingle] = {32680,32681},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.objectives] = {nil,nil,{{93795},{93793},{93794},{93796}}},
        },
        [32506] = { -- A Wing to Fly On
            [questKeys.preQuestSingle] = {32259},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32507] = { -- Skin of the Saurok
            [questKeys.finishedBy] = {{110018}},
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
        },
        [32517] = { -- The Conquest of Stone
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.objectives] = {{{69238,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Disrupt the Ancient Stone Conqueror ritual"),0,{{"monster",69903}}}},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT, 4}},
        },
        [32523] = { -- The Beast Pens
            [questKeys.preQuestSingle] = {32259},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32524] = { -- The Beating of Troll Drums
            [questKeys.preQuestSingle] = {32259},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32525] = { -- Ashes of the Enemy
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{69331,69337},69337,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32526] = { -- Soul Surrender
            [questKeys.objectives] = {nil,nil,nil,nil,{{{69265,69267,69305,69444,69426},69426,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Open the cage"),0,{{"object",217768}}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
        },
        [32527] = { -- Grave Circumstances
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
            [questKeys.breadcrumbs] = {32731},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
        },
        [32528] = { -- Into the Crypts
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon Gura"),0,{{"object",218081}}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32529] = { -- The Call of Thunder
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.objectives] = {{{69369,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Shan'ze Thundercallers"),0,{{"monster",71511}}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32530] = { -- The Bloodletter
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32531] = { -- The Conquest of Stone
            [questKeys.objectives] = {{{69238,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Disrupt the Ancient Stone Conqueror ritual"),0,{{"monster",69903}}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
        },
        [32532] = { -- Rise No More!
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32533] = { -- Stone Cold
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32535] = { -- The Skumblade Threat
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.breadcrumbs] = {32732},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32536] = { -- Manipulating the Saurok
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.objectives] = {{{69682,nil,Questie.ICON_TYPE_TALK},{69684,nil,Questie.ICON_TYPE_TALK},{69686,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32537] = { -- De-Constructed
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.objectives] = {{{69693,nil,Questie.ICON_TYPE_OBJECT},{69688,nil,Questie.ICON_TYPE_OBJECT},{69695,nil,Questie.ICON_TYPE_OBJECT},{69697,nil,Questie.ICON_TYPE_OBJECT}}},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32538] = { -- Heinous Sacrifice
            [questKeys.objectives] = {nil,{{218797},{218798},{218801}}},
            [questKeys.questFlags] = questFlags.DAILY,
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
        },
        [32539] = { -- Dark Offerings
            [questKeys.objectives] = {nil,{{216991}}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
        },
        [32540] = { -- Harbingers of the Loa
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32541] = { -- Preventing a Future Threat
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.objectives] = {{{69128,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
            [questKeys.objectivesText] = {"Frighten 12 Hatchling Skyscreamers by running near them."},
        },
        [32542] = { -- Surgical Strike
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{69379,69397,69412,69780,70377,70509,69065},69065},{{69171},69171},{{69254,69255,69256,69225},69225}}},
        },
        [32543] = { -- Dangers of Za'Tual
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.breadcrumbs] = {32733},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
        },
        [32544] = { -- Pterrible Ptorment
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_SLAY,l10n("Kill the Arcweaver"),0,{{"monster",69224}}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
            [questKeys.objectives] = {{{69263,nil,Questie.ICON_TYPE_EVENT}}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
        },
        [32545] = { -- The Residents of Ihgaluk
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE, 4}},
        },
        [32546] = { -- Just Some Light Clean-Up Work
            [questKeys.objectives] = {{{69251}}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32547] = { -- The Creeping Carpet of Ihgaluk
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32548] = { -- Left To Rot
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32549] = { -- Skin of the Saurok
            [questKeys.finishedBy] = {{110018}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
        },
        [32550] = { -- Saur Loser
            [questKeys.preQuestSingle] = {32260},
        },
        [32551] = { -- Compy Stomp
            [questKeys.preQuestSingle] = {32260},
        },
        [32552] = { -- Loa-saur
            [questKeys.preQuestSingle] = {32260},
        },
        [32553] = { -- Direhorn vs Devilsaur
            [questKeys.preQuestSingle] = {32260},
        },
        [32554] = { -- Dino Might
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.requiredSourceItems] = {93668},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{58071,67576,69180,69183,69207},67576,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32555] = { -- Centuries in Sentries
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32556] = { -- The More You Know
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32557] = { -- Out of Enemy Hands
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32558] = { -- All In the Family
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32559] = { -- Even Giants Fall
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32560] = { -- Keep It Secret
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32561] = { -- Competing Magic
            [questKeys.startedBy] = {{67660,67989,67990,70520}},
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, changed in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.exclusiveTo] = {32293,32562},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,31}},
        },
        [32562] = { -- Imposing Threat
            [questKeys.startedBy] = {{67660,67989,67990,70520}},
            -- [questKeys.preQuestSingle] = {32680}, -- stage 1, changed in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.exclusiveTo] = {32293,32561},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,31}},
        },
        [32564] = { -- Zandalari on the Rise
            [questKeys.preQuestSingle] = {32259},
        },
        [32567] = { -- The Beast Pens
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32568] = { -- No Time To Rest
            [questKeys.preQuestSingle] = {32260},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32571] = { -- A Wing to Fly On
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32572] = { -- The Sleepless Legion
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32573] = { -- Enemies Beneath the Tower
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32574] = { -- The Shuddering Moor
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32575] = { -- The Zandalari Colossus
            [questKeys.preQuestSingle] = {32260},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32576] = { -- Competing Magic
            [questKeys.startedBy] = {{67992,67996,67997,70517}},
            [questKeys.preQuestSingle] = {32681}, -- further handled in questHubs
            [questKeys.exclusiveTo] = {32577,32578},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,31}},
        },
        [32577] = { -- Imposing Threat
            [questKeys.startedBy] = {{67992,67996,67997,70517}},
            [questKeys.preQuestSingle] = {32681}, -- further handled in questHubs
            [questKeys.exclusiveTo] = {32576,32578},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,31}},
        },
        [32578] = { -- Among the Bones
            [questKeys.preQuestSingle] = {32681}, -- further handled in questHubs
            [questKeys.exclusiveTo] = {32576,32577},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,31}},
        },
        [32579] = { -- Competing Magic
            [questKeys.preQuestSingle] = {32681},
        },
        [32580] = { -- Encroaching Force
            [questKeys.preQuestSingle] = {32681},
        },
        [32581] = { -- Imposing Threat
            [questKeys.preQuestSingle] = {32644},
        },
        [32582] = { -- Raining Bones
            [questKeys.preQuestSingle] = {32260},
        },
        [32583] = { -- Zandalari on the Rise
            [questKeys.preQuestSingle] = {32260},
        },
        [32584] = { -- Encroaching Force
            [questKeys.preQuestSingle] = {32681},
        },
        [32585] = { -- Encroaching Force
            [questKeys.preQuestSingle] = {32681},
        },
        [32586] = { -- Maximum Capacitor
            [questKeys.objectives] = {{{69316,nil,Questie.ICON_TYPE_OBJECT},{69319,nil,Questie.ICON_TYPE_OBJECT},{69320,nil,Questie.ICON_TYPE_OBJECT},{69326}}},
        },
        [32587] = { -- Forge Ahead!
            [questKeys.preQuestSingle] = {32586,32588},
        },
        [32588] = { -- On Her Magic-ey Secret Service
            [questKeys.objectives] = {{{69751,nil,Questie.ICON_TYPE_INTERACT},{69752,nil,Questie.ICON_TYPE_INTERACT},{69754,nil,Questie.ICON_TYPE_INTERACT},{69326}}},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32589] = { -- Life Blood
            [questKeys.preQuestSingle] = {32680}, -- wowhead comments say available without progressing IoT
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,8}},
            [questKeys.requiredMinRep] = {factionIDs.SUNREAVER_ONSLAUGHT,42000},
        },
        [32590] = { -- Meet Me Upstairs
            [questKeys.startedBy] = {{64616}},
            [questKeys.preQuestSingle] = {32390,32432},
            [questKeys.breadcrumbs] = {32457},
        },
        [32591] = { -- Secrets of the First Empire
            [questKeys.startedBy] = {{69782}},
            [questKeys.preQuestSingle] = {32457,32590},
            [questKeys.reputationReward] = {{factionIDs.THE_BLACK_PRINCE,5}},
        },
        [32592] = { -- I Need a Champion
            [questKeys.startedBy] = {{69782}},
            [questKeys.preQuestSingle] = {32457,32590},
        },
        [32593] = { -- The Thunder Forge
            [questKeys.startedBy] = {{69782}},
            [questKeys.objectives] = {{{70093},{70438,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestGroup] = {32591,32592},
        },
        [32599] = { -- Securing A Future
            [questKeys.preQuestSingle] = {32681}, -- wowhead comments say available without progressing IoT
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,8}},
            [questKeys.requiredMinRep] = {factionIDs.KIRIN_TOR_OFFENSIVE,42000},
        },
        [32603] = { -- Beasts of Fable
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68555,nil,Questie.ICON_TYPE_PET_BATTLE},{68558,nil,Questie.ICON_TYPE_PET_BATTLE},{68559,nil,Questie.ICON_TYPE_PET_BATTLE},{68560,nil,Questie.ICON_TYPE_PET_BATTLE},{68561,nil,Questie.ICON_TYPE_PET_BATTLE},{68562,nil,Questie.ICON_TYPE_PET_BATTLE},{68563,nil,Questie.ICON_TYPE_PET_BATTLE},{68564,nil,Questie.ICON_TYPE_PET_BATTLE},{68565,nil,Questie.ICON_TYPE_PET_BATTLE},{68566,nil,Questie.ICON_TYPE_PET_BATTLE}}},
            [questKeys.preQuestSingle] = {31951},
        },
        [32604] = { -- Beasts of Fable Book I
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68555,nil,Questie.ICON_TYPE_PET_BATTLE},{68563,nil,Questie.ICON_TYPE_PET_BATTLE},{68564,nil,Questie.ICON_TYPE_PET_BATTLE},{68565,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32605] = { -- Subtle Encouragement
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67760,69210,69226,69227,69228,69229,69338,69348,69387,69403,70347,70348,},67760,nil,Questie.ICON_TYPE_INTERACT}}},
            -- [questKeys.preQuestSingle] = {32680}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32606] = { -- Subtle Encouragement
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{67760,69210,69226,69227,69228,69229,69338,69348,69387,69403,70347,70348,},67760,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32607] = { -- Extended Shore Leave
            [questKeys.preQuestGroup] = {32655,32587},
        },
        [32608] = { -- Raiding the Vault
            [questKeys.preQuestGroup] = {32655,32587},
        },
        [32616] = { -- A Large Pile of Giant Dinosaur Bones
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [32617] = { -- A Mountain of Giant Dinosaur Bones
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [32618] = { -- Learn To Ride
            [questKeys.requiredLevel] = 20,
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [32627] = { -- Charged Moganite
            [questKeys.preQuestSingle] = {32261},
        },
        [32628] = { -- Tactical Mana Bombs
            [questKeys.preQuestSingle] = {32261},
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32631] = { -- High Recognition
            [questKeys.preQuestSingle] = {32261},
        },
        [32632] = { -- Made for War
            [questKeys.preQuestSingle] = {32261},
        },
        [32633] = { -- Spellbound
            [questKeys.preQuestSingle] = {32261},
        },
        [32634] = { -- Breaking Down the Defenses
            [questKeys.preQuestSingle] = {32261},
        },
        [32635] = { -- Enough with the Bombs!
            [questKeys.preQuestSingle] = {32261},
        },
        [32636] = { -- Captive Audience
            [questKeys.preQuestSingle] = {32261},
        },
        [32637] = { -- Overpowered
            [questKeys.preQuestSingle] = {32261},
        },
        [32638] = { -- Mana Scavengers
            [questKeys.preQuestSingle] = {32261},
        },
        [32639] = { -- Deconstruction
            [questKeys.preQuestSingle] = {32261},
        },
        [32640] = { -- Champions of the Thunder King
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.preQuestSingle] = {32708},
            [questKeys.reputationReward] = {{factionIDs.SHADO_PAN_ASSAULT,12}},
        },
        [32641] = { -- Champions of the Thunder King
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.preQuestSingle] = {32708},
            [questKeys.reputationReward] = {{factionIDs.SHADO_PAN_ASSAULT,12}},
        },
        [32642] = { -- Work Order: Dominance Offensive I
            [questKeys.preQuestGroup] = {32108,32682},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {80593,85158},
            [questKeys.nextQuestInChain] = 0,
        },
        [32643] = { -- Work Order: Dominance Offensive II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74844}},nil,{{{63223,63228,63229},63223,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32644] = { -- The Assault on Shaol'mara
            [questKeys.startedBy] = {{67992}},
            [questKeys.objectives] = {{{67992,nil,Questie.ICON_TYPE_TALK},{70345,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {32681},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,12}},
        },
        [32645] = { -- Work Order: Operation: Shieldwall I
            [questKeys.preQuestGroup] = {32109,32682},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {89326,89847},
            [questKeys.nextQuestInChain] = 0,
        },
        [32646] = { -- Work Order: Operation: Shieldwall II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74846}},nil,{{{66080,66084,66085},66080,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32647] = { -- Work Order: Golden Lotus I
            [questKeys.preQuestGroup] = {30638,32682},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {80595,85163},
            [questKeys.nextQuestInChain] = 0,
        },
        [32648] = { -- Work Order: Golden Lotus II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74850}},nil,{{{63260,63264,63265},63260,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32649] = { -- Work Order: Shado-Pan I
            [questKeys.preQuestGroup] = {32682}, -- TODO - double check on the other quest
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {79102,80809},
            [questKeys.nextQuestInChain] = 0,
        },
        [32650] = { -- Work Order: Shado-Pan II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74840}},nil,{{{58567,60113,63157},58567,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32652] = { -- To the Skies!
            [questKeys.finishedBy] = {{67992}},
            [questKeys.objectives] = {{{67992,nil,Questie.ICON_TYPE_TALK},{69923}}},
            [questKeys.preQuestSingle] = {32654}, -- TODO - double check
        },
        [32653] = { -- Work Order: The August Celestials I
            [questKeys.preQuestGroup] = {32682}, -- TODO - double check on the other quest
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {89329,89849},
            [questKeys.nextQuestInChain] = 0,
        },
        [32654] = { -- Tear Down This Wall!
            [questKeys.preQuestSingle] = {32644},
            [questKeys.objectives] = {{{67992,nil,Questie.ICON_TYPE_TALK},{69755}}},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,12}},
        },
        [32655] = { -- A Bold Idea
            [questKeys.preQuestSingle] = {32652}, -- TODO - double check
        },
        [32656] = { -- The Fall of Shan Bu
            [questKeys.preQuestSingle] = {32655}, -- TODO - double check
        },
        [32657] = { -- Work Order: The August Celestials II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74848}},nil,{{{66123,66128,66129},66123,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32658] = { -- Work Order: The Klaxxi I
            [questKeys.preQuestGroup] = {31066,32682},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {80592,85153},
            [questKeys.nextQuestInChain] = 0,
        },
        [32659] = { -- Work Order: The Klaxxi II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74842}},nil,{{{63180,63184,63185},63180,nil,Questie.ICON_TYPE_INTERACT}}},
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
        [32676] = { -- Extended Shore Leave
            [questKeys.preQuestGroup] = {32278,32292},
        },
        [32677] = { -- Raiding the Vault
            [questKeys.preQuestGroup] = {32278,32292},
        },
        [32678] = { -- Thunder Calls
            [questKeys.nextQuestInChain] = 0,
        },
        [32679] = { -- Thunder Calls
            [questKeys.nextQuestInChain] = 32681,
            [questKeys.breadcrumbForQuestId] = 32681,
        },
        [32680] = { -- The Storm Gathers
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{70358,nil,Questie.ICON_TYPE_TALK},{70365,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [32681] = { -- The Storm Gathers
            [questKeys.finishedBy] = {{67992}},
            [questKeys.breadcrumbs] = {32679},
            [questKeys.objectives] = {{{70360,nil,Questie.ICON_TYPE_TALK},{70364,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [32682] = { -- Inherit the Earth
            [questKeys.requiredMinRep] = {factionIDs.THE_TILLERS,42000}, -- Tillers at Exalted
            [questKeys.preQuestSingle] = {30529},
            [questKeys.objectives] = {{{58646,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32683] = { -- So You Want to Be a Blacksmith...
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,1},
            [questKeys.requiredSpell] = -110396, -- BANDAID FIX. This is actually available up to 499 skill included. At 500 it's not. Can't do that so we do this.
        },
        [32706] = { -- Allies in the Shadows
            [questKeys.startedBy] = {{67992}},
            [questKeys.preQuestSingle] = {32681},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR_OFFENSIVE,4}},
        },
        [32707] = { -- Secrets in the Isle of Thunder
            [questKeys.preQuestSingle] = {32706,32709},
            [questKeys.reputationReward] = {{factionIDs.SHADO_PAN_ASSAULT,31}},
        },
        [32708] = { -- Setting the Trap
            [questKeys.preQuestSingle] = {32707},
            [questKeys.objectives] = {{{70203,nil,Questie.ICON_TYPE_OBJECT},{69341}}},
            [questKeys.reputationReward] = {{factionIDs.SHADO_PAN_ASSAULT,12}},
        },
        [32709] = { -- Allies in the Shadows
            [questKeys.startedBy] = {{67990}},
            [questKeys.preQuestSingle] = {32680},
            [questKeys.reputationReward] = {{factionIDs.SUNREAVER_ONSLAUGHT,4}},
        },
        [32718] = { -- Mogu Runes of Fate
            [questKeys.startedBy] = {{63996}},
            [questKeys.objectives] = {nil,{{440004}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.objectivesText] = {"Collect 50 Lesser Charms of Good Fortune."},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
        },
        [32719] = { -- Mogu Runes of Fate
            [questKeys.startedBy] = {{64029}},
            [questKeys.objectives] = {nil,{{440004}}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.objectivesText] = {"Collect 50 Lesser Charms of Good Fortune."},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
        },
        [32726] = { -- So You Want to Be a Blacksmith...
            [questKeys.requiredSkill] = {profKeys.BLACKSMITHING,1},
            [questKeys.requiredSpell] = -110396, -- BANDAID FIX. This is actually available up to 499 skill included. At 500 it's not. Can't do that so we do this.
        },
        [32728] = { -- The Court of Bones
            -- [questKeys.preQuestSingle] = {32680}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.breadcrumbForQuestId] = 32201,
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32729] = { -- Za'Tual
            [questKeys.startedBy] = {{67990}},
            -- [questKeys.preQuestSingle] = {32680}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.breadcrumbForQuestId] = 32200,
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32730] = { -- Ihgaluk Crag
            -- [questKeys.preQuestSingle] = {32680}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32259},
            [questKeys.breadcrumbForQuestId] = 32204,
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32731] = { -- The Court of Bones
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.breadcrumbForQuestId] = 32527,
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32732] = { -- Ihgaluk Crag
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.breadcrumbForQuestId] = 32535,
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32733] = { -- Za'Tual
            [questKeys.startedBy] = {{67992}},
            -- [questKeys.preQuestSingle] = {32681}, stage 1, replaced in stage 2
            [questKeys.preQuestSingle] = {32260},
            [questKeys.breadcrumbForQuestId] = 32543,
            [questKeys.questFlags] = questFlags.DAILY,
        },
        [32805] = { -- Celestial Blessings
            [questKeys.objectives] = {{{61093,nil,Questie.ICON_TYPE_TALK},{59653,nil,Questie.ICON_TYPE_TALK},{64528,nil,Questie.ICON_TYPE_TALK},{71954,nil,Questie.ICON_TYPE_TALK}},nil,nil,nil,{{{61093,59653,64528,71954},61093,nil,Questie.ICON_TYPE_TALK}}},
        },
        [32863] = { -- What We've Been Training For
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{110001}}},
        },
        [32868] = { -- Beasts of Fable Book II
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68560,nil,Questie.ICON_TYPE_PET_BATTLE},{68561,nil,Questie.ICON_TYPE_PET_BATTLE},{68566,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32869] = { -- Beasts of Fable Book III
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{68558,nil,Questie.ICON_TYPE_PET_BATTLE},{68559,nil,Questie.ICON_TYPE_PET_BATTLE},{68562,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [32942] = { -- Work Order: Sunreaver Onslaught I
            [questKeys.preQuestGroup] = {32680,32682},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {80591,84783},
            [questKeys.nextQuestInChain] = 0,
        },
        [32943] = { -- Work Order: Sunreaver Onslaught II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74843}},nil,{{{63160,63164,63165},63160,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [32944] = { -- Work Order: Kirin Tor Offensive I
            [questKeys.preQuestGroup] = {32681,32682},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {{{58563,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {80590,84782},
            [questKeys.nextQuestInChain] = 0,
        },
        [32945] = { -- Work Order: Kirin Tor Offensive II
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.objectives] = {nil,nil,{{74841}},nil,{{{63154,63156,63158},63154,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [33136] = { -- The Rainy Day is Here
            [questKeys.preQuestSingle] = {33137},
        },
        [33137] = { -- The Celestial Tournament
            [questKeys.requiredSpell] = 119467,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.objectives] = {{{73082,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [33222] = { -- Little Tommy Newcomer
            [questKeys.requiredSpell] = 119467,
            [questKeys.objectives] = {{{73626,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [33252] = { -- A Winter Veil Gift
            [questKeys.startedBy] = {nil,{187236}},
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
        [33354] = { -- Den Mother's Demise
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
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
        [91701] = { -- A Celestial Challenge: Darkmaster Gandling
            [questKeys.name] = "A Celestial Challenge: Darkmaster Gandling",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Scholomance Dungeon on Celestial Difficulty."},
            [questKeys.objectives] = {{{66958}}},
            [questKeys.exclusiveTo] = {91703,91705,91707,91709,91711,91713,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SCHOLOMANCE_MOP,
        },
        [91702] = { -- A Celestial Challenge: Darkmaster Gandling
            [questKeys.name] = "A Celestial Challenge: Darkmaster Gandling",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Scholomance Dungeon on Celestial Difficulty."},
            [questKeys.objectives] = {{{66958}}},
            [questKeys.exclusiveTo] = {91704,91706,91708,91710,91712,91714,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SCHOLOMANCE_MOP,
        },
        [91703] = { -- A Celestial Challenge: Flameweaver Koegler
            [questKeys.name] = "A Celestial Challenge: Flameweaver Koegler",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Scarlet Halls Dungeon on Celestial Difficulty."},
            [questKeys.objectives] = {{{59150}}},
            [questKeys.exclusiveTo] = {91701,91705,91707,91709,91711,91713,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SCARLET_HALLS,
        },
        [91704] = { -- A Celestial Challenge: Flameweaver Koegler
            [questKeys.name] = "A Celestial Challenge: Flameweaver Koegler",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Scarlet Halls Dungeon on Celestial Difficulty."},
            [questKeys.objectives] = {{{59150}}},
            [questKeys.exclusiveTo] = {91702,91706,91708,91710,91712,91714,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SCARLET_HALLS,
        },
        [91705] = { -- A Celestial Challenge: Durand
            [questKeys.name] = "A Celestial Challenge: Durand",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Scarlet Monastery on Celestial Difficulty."},
            [questKeys.objectives] = {{{60040}}},
            [questKeys.exclusiveTo] = {91701,91703,91707,91709,91711,91713,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SCARLET_MONASTERY_MOP,
        },
        [91706] = { -- A Celestial Challenge: Durand
            [questKeys.name] = "A Celestial Challenge: Durand",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Scarlet Monastery on Celestial Difficulty."},
            [questKeys.objectives] = {{{60040}}},
            [questKeys.exclusiveTo] = {91702,91704,91708,91710,91712,91714,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SCARLET_MONASTERY_MOP,
        },
        [91707] = { -- A Celestial Challenge: Wing Leader Ner'onok
            [questKeys.name] = "A Celestial Challenge: Wing Leader Ner'onok",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Siege of Niuzao Temple on Celestial Difficulty."},
            [questKeys.objectives] = {{{62205}}},
            [questKeys.exclusiveTo] = {91701,91703,91705,91709,91711,91713,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SIEGE_OF_NIUZAO_TEMPLE,
        },
        [91708] = { -- A Celestial Challenge: Wing Leader Ner'onok
            [questKeys.name] = "A Celestial Challenge: Wing Leader Ner'onok",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Siege of Niuzao Temple on Celestial Difficulty."},
            [questKeys.objectives] = {{{62205}}},
            [questKeys.exclusiveTo] = {91702,91704,91706,91710,91712,91714,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SIEGE_OF_NIUZAO_TEMPLE,
        },
        [91709] = { -- A Celestial Challenge: Raigonn
            [questKeys.name] = "A Celestial Challenge: Raigonn",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Gate of the Setting Sun on Celestial Difficulty."},
            [questKeys.objectives] = {{{56877}}},
            [questKeys.exclusiveTo] = {91701,91703,91705,91707,91711,91713,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.GATE_OF_THE_SETTING_SUN,
        },
        [91710] = { -- A Celestial Challenge: Raigonn
            [questKeys.name] = "A Celestial Challenge: Raigonn",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Gate of the Setting Sun on Celestial Difficulty."},
            [questKeys.objectives] = {{{56877}}},
            [questKeys.exclusiveTo] = {91702,91704,91706,91708,91712,91714,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.GATE_OF_THE_SETTING_SUN,
        },
        [91711] = { -- A Celestial Challenge: Xin the Weaponmaster
            [questKeys.name] = "A Celestial Challenge: Xin the Weaponmaster",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Mogu'shan Palace on Celestial Difficulty."},
            [questKeys.objectives] = {{{61398}}},
            [questKeys.exclusiveTo] = {91701,91703,91705,91707,91709,91713,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.MOGUSHAN_PALACE,
        },
        [91712] = { -- A Celestial Challenge: Xin the Weaponmaster
            [questKeys.name] = "A Celestial Challenge: Xin the Weaponmaster",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Mogu'shan Palace on Celestial Difficulty."},
            [questKeys.objectives] = {{{61398}}},
            [questKeys.exclusiveTo] = {91702,91704,91706,91708,91710,91714,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.MOGUSHAN_PALACE,
        },
        [91713] = { -- A Celestial Challenge: Sha of Hatred
            [questKeys.name] = "A Celestial Challenge: Sha of Hatred",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Shado-Pan Monastery on Celestial Difficulty."},
            [questKeys.objectives] = {{{56884}}},
            [questKeys.exclusiveTo] = {91701,91703,91705,91707,91709,91711,91715,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SHADO_PAN_MONASTERY,
        },
        [91714] = { -- A Celestial Challenge: Sha of Hatred
            [questKeys.name] = "A Celestial Challenge: Sha of Hatred",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Shado-Pan Monastery on Celestial Difficulty."},
            [questKeys.objectives] = {{{56884}}},
            [questKeys.exclusiveTo] = {91702,91704,91706,91708,91710,91712,91716,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.SHADO_PAN_MONASTERY,
        },
        [91715] = { -- A Celestial Challenge: Yan-zhu the Uncasked
            [questKeys.name] = "A Celestial Challenge: Yan-zhu the Uncasked",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Stormstout Brewery on Celestial Difficulty."},
            [questKeys.objectives] = {{{59479}}},
            [questKeys.exclusiveTo] = {91701,91703,91705,91707,91709,91711,91713,91717},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.STORMSTOUT_BREWERY,
        },
        [91716] = { -- A Celestial Challenge: Yan-zhu the Uncasked
            [questKeys.name] = "A Celestial Challenge: Yan-zhu the Uncasked",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Stormstout Brewery on Celestial Difficulty."},
            [questKeys.objectives] = {{{59479}}},
            [questKeys.exclusiveTo] = {91702,91704,91706,91708,91710,91712,91714,91718},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.STORMSTOUT_BREWERY,
        },
        [91717] = { -- A Celestial Challenge: Sha of Doubt
            [questKeys.name] = "A Celestial Challenge: Sha of Doubt",
            [questKeys.startedBy] = {{63994}},
            [questKeys.finishedBy] = {{63994}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Temple of the Jade Serpent on Celestial Difficulty."},
            [questKeys.objectives] = {{{56439}}},
            [questKeys.exclusiveTo] = {91701,91703,91705,91707,91709,91711,91713,91715},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.TEMPLE_OF_THE_JADE_SERPENT,
        },
        [91718] = { -- A Celestial Challenge: Sha of Doubt
            [questKeys.name] = "A Celestial Challenge: Sha of Doubt",
            [questKeys.startedBy] = {{64028}},
            [questKeys.finishedBy] = {{64028}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Complete the Temple of the Jade Serpent on Celestial Difficulty."},
            [questKeys.objectives] = {{{56439}}},
            [questKeys.exclusiveTo] = {91702,91704,91706,91708,91710,91712,91714,91716},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.zoneOrSort] = zoneIDs.TEMPLE_OF_THE_JADE_SERPENT,
        },
        [91786] = { -- When in Doubt
            [questKeys.name] = "When in Doubt",
            [questKeys.startedBy] = {{64616}},
            [questKeys.finishedBy] = {{64616}},
            [questKeys.requiredLevel] = 90,
            [questKeys.questLevel] = 90,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {"Defeat the Sha of Doubt on Celestial Difficulty in the Temple of the Jade Serpent and acquire the Chimera of Doubt."},
            [questKeys.objectives] = {nil,nil,{{248204}}},
            [questKeys.zoneOrSort] = sortKeys.LEGENDARY,
            [questKeys.preQuestGroup] = {31468,31473},
            [questKeys.reputationReward] = {{1359,5}},
            [questKeys.exclusiveTo] = {31481},
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
            [questKeys.exclusiveTo] = {10897,10899,10902,29067,29481,29482,92337,92338},
            [questKeys.zoneOrSort] = sortKeys.ALCHEMY,
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
            [questKeys.exclusiveTo] = {10897,10899,10902,29067,29481,29482,92336,92338},
            [questKeys.zoneOrSort] = sortKeys.ALCHEMY,
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
            [questKeys.exclusiveTo] = {10897,10899,10902,29067,29481,29482,92336,92337},
            [questKeys.zoneOrSort] = sortKeys.ALCHEMY,
        },
    }
end

function MopQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys

    ---@format disable
    local questFixesHorde = {
        [30376] = { -- Hope Springs Eternal
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30174,30273},
            [questKeys.exclusiveTo] = {30241},
        },
        [30632] = { -- The Ruins of Guo-Lai
            [questKeys.preQuestGroup] = {31511,30649},
        },
        [31695] = { -- Beyond The Wall
            [questKeys.preQuestGroup] = {30655,30656,30661},
        },
        [32428] = { -- Pandaren Spirit Tamer
            [questKeys.startedBy] = {{64582}},
            [questKeys.finishedBy] = {{64582}},
        },
        [32603] = { -- Beasts of Fable
            [questKeys.startedBy] = {{64582}},
            [questKeys.finishedBy] = {{64582}},
        },
        [32604] = { -- Beasts of Fable Book I
            [questKeys.startedBy] = {{64582}},
            [questKeys.finishedBy] = {{64582}},
        },
        [32863] = { -- What We've Been Training For
            [questKeys.startedBy] = {{63626,64582}},
            [questKeys.finishedBy] = {{63626,64582}},
        },
        [32868] = { -- Beasts of Fable Book II
            [questKeys.startedBy] = {{64582}},
            [questKeys.finishedBy] = {{64582}},
        },
        [32869] = { -- Beasts of Fable Book III
            [questKeys.startedBy] = {{64582}},
            [questKeys.finishedBy] = {{64582}},
        },
    }

    ---@format disable
    local questFixesAlliance = {
        [30376] = { -- Hope Springs Eternal
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {30273,30445},
            [questKeys.exclusiveTo] = {30360},
        },
        [30632] = { -- The Ruins of Guo-Lai
            [questKeys.preQuestGroup] = {31512,30631},
        },
        [31695] = { -- Beyond The Wall
            [questKeys.preQuestGroup] = {30650,30651,30660},
        },
        [32428] = { -- Pandaren Spirit Tamer
            [questKeys.startedBy] = {{64572}},
            [questKeys.finishedBy] = {{64572}},
        },
        [32603] = { -- Beasts of Fable
            [questKeys.startedBy] = {{64572}},
            [questKeys.finishedBy] = {{64572}},
        },
        [32604] = { -- Beasts of Fable Book I
            [questKeys.startedBy] = {{64572}},
            [questKeys.finishedBy] = {{64572}},
        },
        [32863] = { -- What We've Been Training For
            [questKeys.startedBy] = {{63596,64572}},
            [questKeys.finishedBy] = {{63596,64572}},
        },
        [32868] = { -- Beasts of Fable Book II
            [questKeys.startedBy] = {{64572}},
            [questKeys.finishedBy] = {{64572}},
        },
        [32869] = { -- Beasts of Fable Book III
            [questKeys.startedBy] = {{64572}},
            [questKeys.finishedBy] = {{64572}},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
