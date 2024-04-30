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

QuestieCorrections.objectObjectiveFirst[24817] = true
QuestieCorrections.objectObjectiveFirst[25371] = true
QuestieCorrections.killCreditObjectiveFirst[26621] = true
QuestieCorrections.killCreditObjectiveFirst[26875] = true

function CataQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceKeys = QuestieDB.raceKeys
    local profKeys = QuestieProfessions.professionKeys
    local zoneIDs = ZoneDB.zoneIDs
    local specialFlags = QuestieDB.specialFlags

    return {
        [487] = { -- The Road to Darnassus
            [questKeys.preQuestSingle] = {2561},
        },
        [578] = { -- The Stone of the Tides
            [questKeys.childQuests] = {579},
        },
        [579] = { -- Stormwind Library
            [questKeys.parentQuest] = 578,
        },
        [869] = { -- To Track a Thief
            [questKeys.triggerEnd] = {"Source of Tracks Discovered", {[zoneIDs.THE_BARRENS]={{63.5,61.5}}}},
        },
        [919] = { -- Timberling Sprouts
            [questKeys.preQuestSingle] = {997},
        },
        [930] = { -- The Glowing Fruit
            [questKeys.preQuestSingle] = {},
        },
        [932] = { -- Twisted Hatred
            [questKeys.preQuestSingle] = {489},
        },
        [933] = { -- Teldrassil: The Coming Dawn
            [questKeys.preQuestSingle] = {7383},
        },
        [935] = { -- The Waters of Teldrassil
            [questKeys.preQuestSingle] = {14005},
        },
        [938] = { -- Mist
            [questKeys.triggerEnd] = {"Lead Mist safely to Sentinel Arynia Cloudsbreak", {[zoneIDs.TELDRASSIL]={{39.5,29.86}}}},
        },
        [997] = { -- Denalan's Earth
            [questKeys.preQuestSingle] = {486},
        },
        [2438] = { -- The Emerald Dreamcatcher
            [questKeys.specialFlags] = 0,
        },
        [2499] = { -- Oakenscowl
            [questKeys.preQuestSingle] = {923},
        },
        [2518] = { -- Tears of the Moon
            [questKeys.preQuestSingle] = {},
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
        [9616] = { -- Bandits!
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [9626] = { -- Meeting the Warchief
            [questKeys.finishedBy] = {{39605}},
        },
        [9813] = { -- Meeting the Warchief
            [questKeys.finishedBy] = {{39605}},
        },
        [10068] = { -- Frost Nova
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{5143}}},
        },
        [10069] = { -- Ways of the Light
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{20154}}},
        },
        [10070] = { -- Steady Shot
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{56641}}},
        },
        [10071] = { -- Evisceration
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{2098}}},
        },
        [10072] = { -- Healing the Wounded
            [questKeys.objectives] = {{{44857}},nil,nil,nil,nil,{{2061}}},
        },
        [10073] = { -- Corruption
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{348}}},
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
            [questKeys.startedBy] = {{32863},nil,{44979}}
        },
        [13507] = { -- Denying Manpower
            [questKeys.preQuestSingle] = {13505},
        },
        [13509] = { -- War Supplies
            [questKeys.preQuestSingle] = {13504},
        },
        [13512] = { -- Strategic Strikes
            [questKeys.preQuestSingle] = {13507},
        },
        [13513] = { -- On the Brink
            [questKeys.preQuestSingle] = {13507},
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
        [13529] = { -- The Corruption's Source
            [questKeys.preQuestSingle] = {13528},
        },
        [13537] = { -- A Taste for Grouper
            [questKeys.requiredSkill] = {profKeys.FISHING, 1},
        },
        [13560] = { -- An Ocean Not So Deep
            [questKeys.preQuestGroup] = {13566,13569},
        },
        [13562] = { -- The Final Flame of Bashal'Aran
            [questKeys.objectives] = {nil,{{194179}}},
            [questKeys.preQuestSingle] = {13554},
        },
        [13563] = { -- A Love Eternal
            [questKeys.preQuestSingle] = {13554},
        },
        [13564] = { -- A Lost Companion
            [questKeys.triggerEnd] = {"Locate Grimclaw", {[zoneIDs.DARKSHORE]={{43,39}}}},
            [questKeys.preQuestSingle] = {13554},
        },
        [13565] = { -- Twice Removed
            [questKeys.preQuestSingle] = {13564},
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
            [questKeys.objectives] = {nil,nil,nil,nil,{{{33131,33132,33133},33131,"Receive the blessing of a great animal spirit."}}},
            [questKeys.childQuests] = {13567,13568,13597},
        },
        [13570] = { -- Remembrance of Auberdine
            [questKeys.preQuestSingle] = {13591},
        },
        [13589] = { -- The Shatterspear Invaders
            [questKeys.preQuestSingle] = {13569},
        },
        [13590] = { -- The Front Line
            [questKeys.preQuestSingle] = {13512},
        },
        [13591] = { -- Disturbing Connections
            [questKeys.startedBy] = {{33178},nil,{46318}},
            [questKeys.preQuestSingle] = {13590},
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
            [questKeys.preQuestGroup] = {13519,13591},
        },
        [13639] = { -- Resupplying the Excavation
            [questKeys.triggerEnd] = {"Find Huldar, Miran, and Saean", {[zoneIDs.LOCH_MODAN]={{55.6,68.5}}}},
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
        [13831] = { -- A Troubling Prescription
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [13660] = { -- Explorers' League Document (5 of 6)
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
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
        [13881] = { -- Consumed
            [questKeys.triggerEnd] = {"Watering Hole Investigated", {[zoneIDs.DARKSHORE]={{45,79.1}}}},
        },
        [13945] = { -- Resident Danger
            [questKeys.preQuestSingle] = {476},
        },
        [13946] = { -- Nature's Reprisal
            [questKeys.preQuestSingle] = {489},
        },
        [13961] = { -- Drag it Out of Them
            [questKeys.triggerEnd] = {"Razormane Prisoner Delivered", {[zoneIDs.THE_BARRENS]={{56.4,40.3}}}},
        },
        [14008] = { -- Frost Nova
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{5143}}},
        },
        [14009] = { -- Flash Heal
            [questKeys.objectives] = {{{48305}},nil,nil,nil,nil,{{2061}}},
        },
        [14011] = { -- Primal Strike
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{73899}}},
        },
        [14012] = { -- Corruption
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{348}}},
        },
        [14013] = { -- Charge
            [questKeys.objectives] = {{{48304}},nil,nil,nil,nil,{{100}}},
        },
        [14019] = { -- Monkey Business
            [questKeys.objectives] = {{{34699}}},
            [questKeys.preQuestSingle] = {14001},
        },
        [14021] = { -- Miner Troubles
            [questKeys.triggerEnd] = {"Kaja'mite Ore mining a success!", {[zoneIDs.THE_LOST_ISLES]={{31.9,73.6}}}},
        },
        [14066] = { -- Investigate the Wreckage
            [questKeys.triggerEnd] = {"Caravan Scene Searched", {[zoneIDs.THE_BARRENS]={{59.2,67.5}}}},
        },
        [14071] = { -- Rolling with my Homies
            [questKeys.objectives] = {{{48323},{34890},{34892},{34954}}},
            [questKeys.childQuests] = {28606},
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
        },
        [14109] = { -- The New You
            [questKeys.requiredSourceItems] = {47044},
            [questKeys.exclusiveTo] = {14110},
        },
        [14110] = { -- The New You
            [questKeys.requiredSourceItems] = {47044},
            [questKeys.exclusiveTo] = {14109},
        },
        [14113] = { -- Life of the Party
            [questKeys.preQuestSingle] = {14109},
        },
        [14121] = { -- Robbing Hoods
            [questKeys.childQuests] = {28607},
        },
        [14122] = { -- The Great Bank Heist
            [questKeys.startedBy] = {{34668}},
        },
        [14125] = { -- 447
            [questKeys.startedBy] = {{34668}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14121,14122,14123,14124},
        },
        [14153] = { -- Life of the Party
            [questKeys.preQuestSingle] = {14110},
        },
        [14154] = { -- By the Skin of His Teeth
            [questKeys.triggerEnd] = {"Survive while holding back the worgen for 2 minutes", {[zoneIDs.GILNEAS_CITY]={{55.1,62.7}}}},
        },
        [14165] = { -- Stone Cold
            [questKeys.triggerEnd] = {"Stonified Miner Delivered", {[zoneIDs.AZSHARA]={{59.9,40.2}}}},
        },
        [14204] = { -- From the Shadows
            [questKeys.startedBy] = {{35378}},
        },
        [14212] = { -- Sacrifices
            [questKeys.objectives] = {{{35229}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Mount Crowley's Horse"), 0, {{"monster", 44427}}}},
        },
        [14218] = { -- By Blood and Ash
            [questKeys.startedBy] = {{35618}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Hop in a cannon"), 0, {{"monster", 35317}}}},
        },
        [14222] = { -- Last Stand
            [questKeys.startedBy] = {{35566}},
        },
        [14233] = { -- Orcs Can Write?
            [questKeys.exclusiveTo] = {},
        },
        [14234] = { -- The Enemy of My Enemy
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14031,14233},
        },
        [14244] = { -- Up, Up & Away!
            [questKeys.objectives] = {nil,{{196439}}},
        },
        [14266] = { -- Charge
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{100}}},
        },
        [14245] = { -- It's a Town-In-A-Box
            [questKeys.objectives] = {nil,{{201938}}},
        },
        [14248] = { -- Help Wanted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14014,14019,14473}
        },
        [14274] = { -- Corruption
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{348}}},
        },
        [14276] = { -- Steady Shot
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{56641}}},
        },
        [14279] = { -- Flash Heal
            [questKeys.objectives] = {{{47091}},nil,nil,nil,nil,{{2061}}},
        },
        [14281] = { -- Frost Nova
            [questKeys.objectives] = {{{35118}},nil,nil,nil,nil,{{5143}}},
        },
        [14283] = { -- Moonfire
            [questKeys.objectives] = {{{47091}},nil,nil,nil,nil,{{774}}},
        },
        [14348] = { -- You Can't Take 'Em Alone
            [questKeys.objectives] = {{{36231}}},
            [questKeys.requiredSourceItems] = {49202},
        },
        [14366] = { -- Holding Steady
            [questKeys.preQuestGroup] = {14347,14348},
        },
        [14369] = { -- Unleash the Beast
            [questKeys.objectives] = {nil,nil,nil,nil,{{{36236,36396,36810},36236}}},
        },
        [14382] = { -- Two By Sea
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the catapult to board the ship"), 0, {{"monster", 36283}}}},
        },
        [14386] = { -- Leader of the Pack
            [questKeys.preQuestGroup] = {14368,14369,14382},
        },
        [14389] = { -- Wasn't It Obvious?
            [questKeys.triggerEnd] = {"Find Anara, and hopefully, Azuregos", {[zoneIDs.AZSHARA]={{27.7,40.4}}}},
        },
        [14395] = { -- Gasping for Breath
            [questKeys.objectives] = {{{36440}}},
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
        [14412] = { -- Washed Up
            [questKeys.preQuestSingle] = {14403},
        },
        [14416] = { -- The Hungry Ettin
            [questKeys.objectives] = {{{36540, nil, Questie.ICON_TYPE_INTERACT}}},
        },
        [14463] = { -- Horses for Duskhaven
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14401,14404,14412,14416},
            [questKeys.exclusiveTo] = {14402,14405},
        },
        [14400] = { -- I Can't Wear This
            [questKeys.exclusiveTo] = {},
        },
        [14473] = { -- It's Our Problem Now
            [questKeys.preQuestSingle] = {14001},
        },
        [14482] = { -- Call of Duty
            [questKeys.extraObjectives] = {{{[zoneIDs.STORMWIND_CITY]={{18.3,25.5}}}, Questie.ICON_TYPE_EVENT, l10n("Wait for the Mercenary Ship to arrive")}},
        },
        [24438] = { -- Exodus
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Board the carriage"), 0, {{"monster", 44928}}}},
        },
        [24452] = { -- Profitability Scouting
            [questKeys.triggerEnd] = {"Heart of Arkkoroc identified", {[zoneIDs.AZSHARA]={{32.4,50.4}}}},
        },
        [24502] = { -- Necessary Roughness
            [questKeys.objectives] = {{{48526},{37114}}},
        },
        [24526] = { -- Filling Up the Spellbook
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{5143}}},
        },
        [24528] = { -- The Power of the Light
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{20154}}},
        },
        [24530] = { -- Oh, A Hunter's Life For Me
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{56641}}},
        },
        [24531] = { -- Getting Battle-Ready
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{100}}},
        },
        [24532] = { -- Evisceratin' the Enemy
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{2098}}},
        },
        [24533] = { -- Words of Power
            [questKeys.objectives] = {{{44405}},nil,nil,nil,nil,{{2061}}},
        },
        [24575] = { -- Liberation Day
            [questKeys.requiredSourceItems] = {49881},
        },
        [24612] = { -- A Gift for the Emissary of Orgrimmar
            [questKeys.finishedBy] = {{39605}},
        },
        [24618] = { -- Claim the Battle Scar
            [questKeys.triggerEnd] = {"Battlescar Flag Scouted", {[zoneIDs.THE_BARRENS]={{45.2,69.4}}}},
        },
        [24628] = { -- Preparations
            [questKeys.preQuestSingle] = {24617},
        },
        [24640] = { -- The Arts of a Warrior
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{100}}},
        },
        [24671] = { -- Cluster Cluck
            [questKeys.objectives] = {{{38111}}},
            [questKeys.preQuestSingle] = {},
        },
        [24677] = { -- Flank the Forsaken
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Lord Hewell for a horse"), 0, {{"monster", 38764}}}},
        },
        [24679] = { -- Patriarch's Blessing
            [questKeys.objectives] = {nil,{{201964}}},
        },
        [24681] = { -- They Have Allies, But So Do We
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Hop in a Glaive Thrower"), 0, {{"monster", 38150}}}},
        },
        [24752] = { -- The Arts of a Mage
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{5143}}},
        },
        [24766] = { -- The Arts of a Druid
            [questKeys.objectives] = {{{47057}},nil,nil,nil,nil,{{774}}},
        },
        [24772] = { -- The Arts of a Rogue
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{2098}}},
        },
        [24778] = { -- The Arts of a Hunter
            [questKeys.objectives] = {{{38038}},nil,nil,nil,nil,{{56641}}},
        },
        [24784] = { -- Learnin' tha Word
            [questKeys.objectives] = {{{47057}},nil,nil,nil,nil,{{2061}}},
        },
        [24817] = { -- A Goblin in Shark's Clothing
            [questKeys.objectives] = {{{36682}},{{202108}}},
        },
        [24864] = { -- Irresistible Pool Pony
            [questKeys.objectives] = {nil,nil,nil,nil,{{{38412,44578,44579,44580},38412,"Naga Hatchling lured"}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24858,24859},
        },
        [24901] = { -- Town-In-A-Box: Under Attack
            [questKeys.objectives] = {{{38526}}},
        },
        [24902] = { -- The Hunt For Sylvanas
            [questKeys.triggerEnd] = {"Hunt for Sylvanas", {[zoneIDs.GILNEAS_CITY]={{44.9,52.3}}}},
        },
        [24904] = { -- The Battle for Gilneas City
            [questKeys.objectives] = {{{38469}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Krennan Aranas to join the battle"), 0, {{"monster", 38553}}}},
        },
        [24920] = { -- Slowing the Inevitable
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Hop on the Captured Riding Bat"), 0, {{"monster", 38615}}}},
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
        },
        [24945] = { -- Three Little Pygmies
            [questKeys.preQuestSingle] = {24940},
        },
        [24952] = { -- Rocket Boot Boost
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24942,24945,24946},
        },
        [24958] = { -- Volcanoth!
            [questKeys.objectives] = {{{38855}}},
        },
        [24960] = { -- The Wakening
            [questKeys.preQuestSingle] = {28608},
        },
        [24964] = { -- The Thrill of the Hunt
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{56641}}},
        },
        [24966] = { -- Of Light and Shadows
            [questKeys.objectives] = {{{44795}},nil,nil,nil,nil,{{2061}}},
        },
        [24967] = { -- Stab!
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{2098}}},
        },
        [24968] = { -- Dark Deeds
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{348}}},
        },
        [24969] = { -- Charging into Battle
            [questKeys.objectives] = {{{44794}},nil,nil,nil,nil,{{100}}},
        },
        [25081] = { -- Claim the Battlescar
            [questKeys.triggerEnd] = {"Battlescar Flag Scouted", {[zoneIDs.THE_BARRENS]={{45.2,69.4}}}},
        },
        [25105] = { -- Nibbler!  No!
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25122] = { -- Morale Boost
            [questKeys.requiredSourceItems] = {52484},
        },
        [25123] = { -- Throw It On the Ground!
            [questKeys.objectives] = {{{39194}}},
            [questKeys.requiredSourceItems] = {52481},
        },
        [25139] = { -- Steady Shot
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{56641}}},
        },
        [25143] = { -- Primal Strike
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{73899}}},
        },
        [25145] = { -- Corruption
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{348}}},
        },
        [25147] = { -- Charge
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{100}}},
        },
        [25149] = { -- Frost Nova
            [questKeys.objectives] = {{{44820}},nil,nil,nil,nil,{{5143}}},
        },
        [25154] = { -- A Present for Lila
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25155] = { -- Ogrezonians in the Mood
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25156] = { -- Elemental Goo
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25157] = { -- The Latest Fashion!
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25158] = { -- Nibbler!  No!
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25159] = { -- The Latest Fashion!
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25160] = { -- A Present for Lila
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25161] = { -- Ogrezonians in the Mood
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25162] = { -- Elemental Goo
            [questKeys.requiredSkill] = {profKeys.JEWELCRAFTING, 475}
        },
        [25202] = { -- The Fastest Way to His Heart
            [questKeys.preQuestSingle] = {25213},
            [questKeys.exclusiveTo] = {25243},
        },
        [25203] = { -- What Kind of Name is Chip, Anyway?
            [questKeys.exclusiveTo] = {25244},
        },
        [25204] = { -- Release the Valves
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25200,25201},
        },
        [25207] = { -- Good-bye, Sweet Oil
            [questKeys.objectives] = {nil,{{205061}}},
        },
        [25213] = { -- The Slave Pits
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25203,25207},
        },
        [25215] = { -- A Distracting Scent
            [questKeys.preQuestSingle] = {25222},
        },
        [25216] = { -- The Great Sambino
            [questKeys.preQuestSingle] = {25222},
        },
        [25217] = { -- Totem Modification
            [questKeys.requiredSourceItems] = {53052,54214,54216,54217},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHIMMERING_EXPANSE]={{40.4,34.2}}}, Questie.ICON_TYPE_EVENT, l10n("Place a totem on the ground and defend it")}},
        },
        [25219] = { -- Don't be Shellfish
            [questKeys.preQuestSingle] = {25222},
        },
        [25220] = { -- Slippery Threat
            [questKeys.preQuestSingle] = {25222},
        },
        [25243] = { -- She Loves Me, She Loves Me NOT!
            [questKeys.exclusiveTo] = {25202},
        },
        [25244] = { -- What Kind of Name is Candy, Anyway?
            [questKeys.preQuestSingle] = {25243},
            [questKeys.exclusiveTo] = {25203},
        },
        [25266] = { -- Warchief's Emissary
            [questKeys.finishedBy] = {{39609}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Sassy Hardwrench"), 0, {{"monster", 38387}}}},
        },
        [25267] = { -- Message for Garrosh
            [questKeys.startedBy] = {{39609}},
            [questKeys.finishedBy] = {{39605}},
        },
        [25275] = { -- Report to the Labor Captain
            [questKeys.startedBy] = {{39605}},
        },
        [25316] = { -- As Hyjal Burns
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Hop on Aronus"), 0, {{"monster", 39140}}}},
        },
        [25325] = { -- Through the Dream
            [questKeys.triggerEnd] = {"Arch Druid Fandral Staghelm delivered", {[zoneIDs.MOUNT_HYJAL]={{55,28.9}}}},
        },
        [25354] = { -- Sweeping the Shelf
            [questKeys.requiredRaces] = raceKeys.ALL_HORDE,
        },
        [25371] = { -- The Abyssal Ride
            [questKeys.objectives] = {{{39996}},{{202766}}},
        },
        [25419] = { -- Lady La-La's Medallion
            [questKeys.requiredSourceItems] = {55188},
        },
        [25442] = { -- A Pearl of Wisdom
            [questKeys.startedBy] = {{40510},nil,{54614}},
            [questKeys.exclusiveTo] = {25890},
        },
        [25464] = { -- The Return of Baron Geddon
            [questKeys.objectives] = {{{40147}}},
        },
        [25473] = { -- Kaja'Cola
            [questKeys.startedBy] = {{34872}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14075,14069},
        },
        [25477] = { -- Better Late Than Dead
            [questKeys.objectives] = {{{40223}}},
        },
        [25577] = { -- Crushing the Cores
            [questKeys.requiredSourceItems] = {55123},
        },
        [25593] = { -- Shelled Salvation
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39729,41203,41219,42404},39729,"Shell Survivors rescued"}}},
            [questKeys.requiredSourceItems] = {55141},
        },
        [25602] = { -- Can't Start a Fire Without a Spark
            [questKeys.preQuestSingle] = {25598},
        },
        [25617] = { -- Into the Maw!
            [questKeys.exclusiveTo] = {25624},
        },
        [25618] = { -- Into the Maw!
            [questKeys.exclusiveTo] = {25623},
        },
        [25621] = { -- Field Test: Gnomecorder
            [questKeys.triggerEnd] = {"Gnomecorder Tested", {[zoneIDs.STONETALON_MOUNTAINS]={{73.2,46.6}}}},
        },
        [25623] = { -- Into the Maw!
            [questKeys.exclusiveTo] = {25618},
        },
        [25624] = { -- Into the Maw!
            [questKeys.exclusiveTo] = {25617},
        },
        [25651] = { -- Oh, the Insanity!
            [questKeys.requiredSourceItems] = {55185},
        },
        [25715] = { -- A Closer Look
            [questKeys.triggerEnd] = {"Scout the ships on the Shattershore", {[zoneIDs.BLASTED_LANDS]={{69,32.7}}}},
        },
        [27517] = { -- Be Prepared
            [questKeys.objectives] = {nil,nil,{{61321}}},
        },
        [25830] = { -- The Last Living Lorekeeper
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25520,25611,25807},
        },
        [25883] = { -- How Disarming
            [questKeys.preQuestSingle] = {25887},
        },
        [25887] = { -- Wake of Destruction
            [questKeys.objectives] = {{{41481}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Subdue a Famished Great Shark"), 0, {{"monster", 41997},{"monster", 41998}}}},
        },
        [25890] = { -- Nespirah
            [questKeys.triggerEnd] = {"Find a way to communicate with Nespirah", {[zoneIDs.SHIMMERING_EXPANSE]={{52.5,54.1}}}},
            [questKeys.preQuestSingle] = {25440},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take the Swift Seahorse to Nespirah."), 0, {{"monster", 40851}}}},
        },
        [25900] = { -- Making Contact
            [questKeys.objectives] = {{{41531}}},
        },
        [25909] = { -- Capture the Crab
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25907,25908},
        },
        [25924] = { -- Call of Duty
            [questKeys.extraObjectives] = {{{[zoneIDs.DUROTAR]={{57.8,10.4}}}, Questie.ICON_TYPE_EVENT, l10n("Wait for the Mercenary Ship to arrive")}},
        },
        [25930] = { -- Ascending the Vale
            [questKeys.triggerEnd] = {"Ascend the Charred Vale", {[zoneIDs.STONETALON_MOUNTAINS]={{31.3,73.2}}}},
        },
        [25942] = { -- Buy Us Some Time
            [questKeys.preQuestSingle] = {25941},
        },
        [25943] = { -- Traveling on Our Stomachs
            [questKeys.preQuestSingle] = {25941},
        },
        [25946] = { -- Helm's Deep
            [questKeys.preQuestSingle] = {25405},
            [questKeys.exclusiveTo] = {},
        },
        [25948] = { -- Bring It On!
            [questKeys.preQuestGroup] = {25944,25947},
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
            [questKeys.preQuestGroup] = {25968,25970,25971},
        },
        [25974] = { -- Sira'kess Slaying
            [questKeys.preQuestSingle] = {26092},
        },
        [25976] = { -- Treasure Reclamation
            [questKeys.preQuestSingle] = {26092},
        },
        [25980] = { -- A Standard Day for Azrajar
            [questKeys.objectives] = {{{41590}}},
            [questKeys.preQuestSingle] = {26092},
        },
        [25982] = { -- Those Aren't Masks
            [questKeys.preQuestSingle] = {26092},
        },
        [25987] = { -- Put It On
            [questKeys.triggerEnd] = {"Merciless One worn",{[zoneIDs.ABYSSAL_DEPTHS]={{51.5,60.8}}}},
        },
        [25988] = { -- Put It On
            [questKeys.triggerEnd] = {"Merciless One worn",{[zoneIDs.ABYSSAL_DEPTHS]={{51.5,60.8}}}},
        },
        [26000] = { -- Spelunking
            [questKeys.preQuestSingle] = {25794},
        },
        [26007] = { -- Debriefing
            [questKeys.preQuestSingle] = {26000},
        },
        [26008] = { -- Decompression
            [questKeys.preQuestSingle] = {25887},
        },
        [26040] = { -- What? What? In My Gut...?
            [questKeys.preQuestSingle] = {25887},
        },
        [26056] = { -- The Wavespeaker
            [questKeys.exclusiveTo] = {26057,26065},
            [questKeys.nextQuestInChain] = 26065,
        },
        [26057] = { -- The Wavespeaker
            [questKeys.exclusiveTo] = {26056,26065},
            [questKeys.nextQuestInChain] = 26065,
        },
        [26065] = { -- Free Wil'hai
            [questKeys.preQuestSingle] = {},
        },
        [26072] = { -- Into the Totem
            [questKeys.objectives] = {{{42051}}},
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
        },
        [26092] = { -- Orako's Report
            [questKeys.preQuestGroup] = {26088,26089},
        },
        [26105] = { -- Claim Korthun's End
            [questKeys.startedBy] = {{42115}},
        },
        [26106] = { -- Fuel-ology 101
            [questKeys.requiredSourceItems] = {56819,56820},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Bring three Hammerhead Oil and two Remora Oil to Engineer Hexascrub."), 0, {{"monster", 41666}}}},
        },
        [26122] = { -- Environmental Awareness
            [questKeys.preQuestSingle] = {26221},
        },
        [26124] = { -- Secure Seabrush
            [questKeys.exclusiveTo] = {26125},
        },
        [26125] = { -- Secure Seabrush
            [questKeys.exclusiveTo] = {26124},
        },
        [26126] = { -- The Perfect Fuel
            [questKeys.requiredSourceItems] = {56819,56820},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Bring three Hammerhead Oil and two Remora Oil to Fiasco Sizzlegrin."), 0, {{"monster", 41666}}}},
        },
        [26133] = { -- Fiends from the Netherworld
            [questKeys.preQuestSingle] = {26111},
        },
        [26154] = { -- Twilight Extermination
            [questKeys.objectives] = {{{47969},{42285}},nil,nil,nil,{{{42281,42280},42280}}},
        },
        [26182] = { -- Back to the Tenebrous Cavern
            [questKeys.preQuestSingle] = {26143},
        },
        [26194] = { -- Defending the Rift
            [questKeys.preQuestSingle] = {26182},
        },
        [26198] = { -- The Arts of a Mage
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{5143}}},
        },
        [26200] = { -- The Arts of a Priest
            [questKeys.objectives] = {{{42501}},nil,nil,nil,nil,{{2061}}},
        },
        [26201] = { -- The Power of a Warlock
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{348}}},
        },
        [26204] = { -- The Arts of a Warrior
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{100}}},
        },
        [26207] = { -- The Arts of a Rogue
            [questKeys.objectives] = {{{44171}},nil,nil,nil,nil,{{2098}}},
        },
        [26229] = { -- "I TAKE Candle!"
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26230] = { -- Feast or Famine
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
        },
        [26258] = { -- Deathwing's Fall
            [questKeys.triggerEnd] = {"Deathwing's Fall reached", {[zoneIDs.DEEPHOLM]={{61.3,57.5}}}},
        },
        [26293] = { -- Machines of War
            [questKeys.startedBy] = {{39605}},
        },
        [26294] = { -- Weapons of Mass Dysfunction
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{42673},{42671}}},
        },
        [26311] = { -- Unfamiliar Waters
            [questKeys.preQuestSingle] = {26294},
        },
        [26324] = { -- Where Is My Warfleet?
            [questKeys.startedBy] = {{39605}},
        },
        [26335] = { -- Ready the Navy
            [questKeys.preQuestSingle] = {26324},
        },
        [26337] = { -- Beating the Market
            [questKeys.objectives] = {{{42777}}},
        },
        [26358] = { -- Ready the Air Force
            [questKeys.preQuestSingle] = {26324},
        },
        [26374] = { -- Ready the Ground Troops
            [questKeys.objectives] = {{{42646}}},
        },
        [26377] = { -- Unsolid Ground
            [questKeys.requiredSourceItems] = {58500,58783},
        },
        [26397] = { -- Walk With The Earth Mother
            [questKeys.finishedBy] = {{39605}},
        },
        [26398] = { -- Walk With The Earth Mother
            [questKeys.startedBy] = {{36648}},
            [questKeys.finishedBy] = {{39605}},
        },
        [26440] = { -- Clingy
            [questKeys.triggerEnd] = {"Pebble brought to crystal formation",{[zoneIDs.DEEPHOLM]={{29,45}}}},
            [questKeys.objectives] = {},
        },
        [26512] = { -- Tuning the Gnomecorder
            [questKeys.triggerEnd] = {"Test the Gnomecorder at the Lakeshire Graveyard", {[zoneIDs.REDRIDGE_MOUNTAINS]={{32.3,39.5}}}},
        },
        [26538] = { -- Emergency Aid
            [questKeys.objectives] = {{{43191}}},
        },
        [26549] = { -- Madness
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Negotiations Concluded",{[zoneIDs.TWILIGHT_HIGHLANDS]={{75.5,55.25}}}},
        },
        [26621] = { -- Insurrection
            [questKeys.objectives] = {{{43575},{43394}},nil,nil,nil,{{{43577,43578},43577,"Dragonmaw Civilian Armed"}}},
        },
        [26642] = { -- Preserving the Barrens
            [questKeys.exclusiveTo] = {28494},
        },
        [26656] = { -- Don't. Stop. Moving.
            [questKeys.triggerEnd] = {"Opalescent Guardians Escorted to safety", {[zoneIDs.DEEPHOLM]={{51,14.8}}}},
            [questKeys.objectives] = {{{42466},{43597}},nil,nil,nil,},
        },
        [26706] = { -- Endgame
            [questKeys.objectives] = {},
            [questKeys.triggerEnd] = {"Gunship destroyed",{[zoneIDs.GILNEAS]={{42.4,29.2}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Hop on a Hippogryph"), 0, {{"monster", 43747}}}},
        },
        [26711] = { -- Off to the Bank (female)
            [questKeys.exclusiveTo] = {26712},
        },
        [26712] = { -- Off to the Bank (male)
            [questKeys.exclusiveTo] = {26711},
        },
        [26750] = { -- At the Stonemother's Call
            [questKeys.preQuestSingle] = {26659},
        },
        [26798] = { -- The Warchief Will Be Pleased
            [questKeys.finishedBy] = {{39605}},
        },
        [26803] = { -- Missing Reports
            [questKeys.preQuestSingle] = {},
        },
        [26827] = { -- Rallying the Earthen Ring
            [questKeys.objectives] = {nil,nil,nil,nil,{{{43836,44633,44634,44642,44644,44646,44647},44642,"Earthen Ring rallied"}}},
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
        [26840] = { -- Return to the Highlands
            [questKeys.startedBy] = {{39605}},
        },
        [26904] = { -- Corruption
            [questKeys.objectives] = {{{44389}},nil,nil,nil,nil,{{348}}},
        },
        [26913] = { -- Charging into Battle
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{100}}},
        },
        [26914] = { -- Corruption
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{348}}},
        },
        [26915] = { -- The Deepest Cut
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{2098}}},
        },
        [26916] = { -- Mastering the Arcane
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{5143}}},
        },
        [26917] = { -- The Hunter's Path
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{56641}}},
        },
        [26918] = { -- The Power of the Light
            [questKeys.objectives] = {{{44548}},nil,nil,nil,nil,{{20154}}},
        },
        [26919] = { -- Healing the Wounded
            [questKeys.objectives] = {{{44564}},nil,nil,nil,nil,{{2061}}},
        },
        [26930] = { -- After the Crusade
            [questKeys.triggerEnd] = {"Scarlet Crusade camp scouted", {[zoneIDs.WESTERN_PLAGUELANDS]={{40.6,52.6}}}},
        },
        [26940] = { -- Frost Nova
            [questKeys.startedBy] = {{43006}},
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{5143}}},
        },
        [26945] = { -- Learning New Techniques
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{100}}},
        },
        [26947] = { -- A Woodsman's Training
            [questKeys.objectives] = {{{44614}},nil,nil,nil,nil,{{56641}}},
        },
        [26948] = { -- Rejuvenating Touch
            [questKeys.objectives] = {{{44617}},nil,nil,nil,nil,{{774}}},
        },
        [26949] = { -- Healing for the Wounded
            [questKeys.objectives] = {{{44617}},nil,nil,nil,nil,{{2061}}},
        },
        [26958] = { -- Your First Lesson
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{100}}},
        },
        [26963] = { -- Steadying Your Shot
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{56641}}},
        },
        [26966] = { -- The Light's Power
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{20154}}},
        },
        [26968] = { -- Frost Nova
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{5143}}},
        },
        [26969] = { -- Primal Strike
            [questKeys.objectives] = {{{44703}},nil,nil,nil,nil,{{73899}}},
        },
        [26970] = { -- Aiding the Injured
            [questKeys.objectives] = {{{16971}},nil,nil,nil,nil,{{2061}}},
        },
        [26975] = { -- Rallying the Fleet
            [questKeys.triggerEnd] = {"Prince Anduin Escorted to Graves", {[zoneIDs.STORMWIND_CITY]={{33.5,40.9}}}},
        },
        [27007] = { -- Silvermarsh Rendezvous
            [questKeys.triggerEnd] = {"Upper Silvermarsh reached", {[zoneIDs.DEEPHOLM]={{72.3,62.3}}}},
        },
        [27010] = { -- Quicksilver Submersion
            [questKeys.requiredSourceItems] = {60809},
        },
        [27020] = { -- The First Lesson
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{100}}},
        },
        [27021] = { -- The Hunter's Path
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{56641}}},
        },
        [27023] = { -- The Way of the Sunwalkers
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{20154}}},
        },
        [27027] = { -- Primal Strike
            [questKeys.objectives] = {{{44848}},nil,nil,nil,nil,{{73899}}},
        },
        [27044] = { -- Peasant Problems
            [questKeys.requiredRaces] = raceKeys.ALL_ALLIANCE,
            [questKeys.triggerEnd] = {"Anduin Escorted to Farmer Wollerton", {[zoneIDs.STORMWIND_CITY]={{52.1,6.5}}}},
        },
        [27066] = { -- Healing in a Flash
            [questKeys.objectives] = {{{45199}},nil,nil,nil,nil,{{2061}}},
        },
        [27067] = { -- Rejuvenating Touch
            [questKeys.objectives] = {{{45199}},nil,nil,nil,nil,{{774}}},
        },
        [27091] = { -- Charge!
            [questKeys.objectives] = {{{44937}},nil,nil,nil,nil,{{100}}},
        },
        [27509] = { -- Breach in the Defenses
            [questKeys.objectives] = {nil,{{205486,"Twilight Portal destroyed"}}},
        },
        [27123] = { -- Deepholm, Realm of Earth
            [questKeys.exclusiveTo] = {26244,26245,26246},
        },
        [27139] = { -- Hobart Needs You
            [questKeys.exclusiveTo] = {24671},
        },
        [27141] = { -- Exploding Through
            [questKeys.preQuestSingle] = {},
        },
        [27152] = { -- Unusual Behavior... Even For Gnolls
            [questKeys.triggerEnd] = {"Gnoll camp investigated", {[zoneIDs.WESTERN_PLAGUELANDS]={{57.5,35.6}}}},
        },
        [27176] = { -- A Strange Disc
            [questKeys.requiredSourceItems] = {60865},
        },
        [27203] = { -- The Maelstrom
            [questKeys.preQuestSingle] = {},
        },
        [27299] = { -- Torn Ground
            [questKeys.preQuestSingle] = {},
        },
        [27301] = { -- Unbroken
            [questKeys.preQuestSingle] = {27300},
        },
        [27302] = { -- Simple Solutions
            [questKeys.preQuestSingle] = {27299},
        },
        [27341] = { -- Scouting the Shore
            [questKeys.triggerEnd] = {"Beach Head Control Point Scouted", {[zoneIDs.TWILIGHT_HIGHLANDS]={{77.5,65.2}}}},
        },
        [27349] = { -- Break in Communications: Dreadwatch Outpost
            [questKeys.triggerEnd] = {"Investigate Dreadwatch Outpost", {[zoneIDs.RUINS_OF_GILNEAS]={{53,32.6}}}},
        },
        [27376] = { -- The Maw of Iso'rath
            [questKeys.preQuestSingle] = {27303},
        },
        [27379] = { -- The Terrors of Iso'rath
            [questKeys.objectives] = {{{48739},{48790},{48794},{48796}}},
        },
        [27398] = { -- The Battle Is Won, The War Goes On
            [questKeys.exclusiveTo] = {27203,27443,27727},
        },
        [27399] = { -- The Battle Is Won, The War Goes On
            [questKeys.exclusiveTo] = {27203,27442,27722},
        },
        [27442] = { -- The War Has Many Fronts
            [questKeys.exclusiveTo] = {27203,27399,27722},
        },
        [27443] = { -- The War Has Many Fronts
            [questKeys.exclusiveTo] = {27203,27398,27727},
        },
        [27490] = { -- SI:7 Drop
            [questKeys.objectives] = {{{45904},{45877}}},
        },
        [27491] = { -- Kor'kron Drop
            [questKeys.objectives] = {{{45947},{45877}}},
        },
        [27501] = { -- Four Heads are Better than None
            [questKeys.preQuestSingle] = {27590},
        },
        [27506] = { -- Life from Death
            [questKeys.preQuestSingle] = {27504},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{45788,45746},45788,"Dragonkin corpse reclaimed"}}},
        },
        [27583] = {
            [questKeys.preQuestSingle] = {26840},
        },
        [27586] = { -- Shells on the Sea Shore
            [questKeys.preQuestSingle] = {27583},
        },
        [27588] = { -- Signal the Attack
            [questKeys.triggerEnd] = {"Signal the Attack", {[zoneIDs.TWILIGHT_HIGHLANDS]={{42.2,68.8}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {27494},
        },
        [27590] = { -- Signal the Attack
            [questKeys.triggerEnd] = {"Signal the Attack", {[zoneIDs.TWILIGHT_HIGHLANDS]={{40.56,62.09}}}},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {27495},
        },
        [27606] = { -- Blast Him!
            [questKeys.preQuestGroup] = {27584,27586},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Heth'Jatari Conch"), 0, {{"object", 205831}}}},
        },
        [27610] = { -- Scouting the Shore
            [questKeys.triggerEnd] = {"Beach Head Control Point Scouted", {[zoneIDs.TWILIGHT_HIGHLANDS]={{77.5,65.2}}}},
        },
        [27622] = { -- Mo' Better Shredder
            [questKeys.objectives] = {{{46100},{46098}}},
            [questKeys.preQuestSingle] = {27611},
        },
        [27668] = { -- Pay Attention!
            [questKeys.preQuestSingle] = {25944},
            [questKeys.exclusiveTo] = {25946},
        },
        [27674] = { -- To the Surface
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Torben Zapblast."), 0, {{"monster", 46293}}}},
        },
        [27689] = { -- Distract Them for Me
            [questKeys.preQuestSingle] = {27655},
            [questKeys.exclusiveTo] = {},
        },
        [27690] = { -- Narkrall, the Drake-Tamer
            [questKeys.preQuestSingle] = {27606},
        },
        [27696] = { -- The Elementium Axe
            [questKeys.preQuestSingle] = {27689},
            [questKeys.exclusiveTo] = {},
        },
        [27703] = { -- Coup de Grace
            [questKeys.preQuestSingle] = {27701},
        },
        [27704] = { -- Legends of the Sunken Temple
            [questKeys.triggerEnd] = {"Hall of Masks found", {[zoneIDs.THE_TEMPLE_OF_ATAL_HAKKAR]={{74,44.4}}}},
        },
        [27711] = { -- Back to the Elementium Depths
            [questKeys.preQuestSingle] = {27719},
            [questKeys.exclusiveTo] = {},
        },
        [27712] = { -- Back to the Elementium Depths
            [questKeys.preQuestSingle] = {27798},
            [questKeys.exclusiveTo] = {},
        },
        [27721] = { -- Warchief's Command: Mount Hyjal!
            [questKeys.objectives] = {{{15188, nil, Questie.ICON_TYPE_TALK}}},
        },
        [27722] = { -- Warchief's Command: Deepholm!
            [questKeys.exclusiveTo] = {27203,27399,27442},
        },
        [27724] = { -- Hero's Call: Vashj'ir!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [27726] = { -- Hero's Call: Mount Hyjal!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [27727] = { -- Hero's Call: Deepholm!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
            [questKeys.exclusiveTo] = {27203,27398,27443},
        },
        [27729] = { -- Once More, With Eeling
            [questKeys.preQuestSingle] = {14482,25924},
        },
        [27742] = { -- A Little on the Side
            [questKeys.preQuestSingle] = {28885},
        },
        [27743] = { -- While We're Here
            [questKeys.preQuestSingle] = {28885},
        },
        [27744] = { -- Rune Ruination
            [questKeys.exclusiveTo] = {},
            [questKeys.preQuestSingle] = {27711,27712},
        },
        [27745] = { -- A Fiery Reunion
            [questKeys.objectives] = {nil,{{301087}},{{62394}}},
            [questKeys.preQuestSingle] = {27744},
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
        [27755] = { -- The Curse of the Tombs
            [questKeys.preQuestSingle] = {28501},
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
        [27783] = { -- Garona Needs You
            [questKeys.preQuestSingle] = {27745},
            [questKeys.exclusiveTo] = {27786},
        },
        [27485] = { -- Warm Welcome
            [questKeys.preQuestSingle] = {27380},
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
        [27922] = { -- Traitors!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Hide behind Neferset Frond"), 0, {{"object", 206579}}}},
        },
        [27929] = { -- Drag 'em Down
            [questKeys.preQuestSingle] = {27690},
        },
        [27945] = { -- Paint it Black
            [questKeys.preQuestSingle] = {27690},
        },
        [27947] = { -- A Vision of Twilight
            [questKeys.preQuestSingle] = {27690},
        },
        [27950] = { -- Gobbles!
            [questKeys.objectives] = {{{47191}}},
        },
        [27969] = { -- Make Yourself Useful
            [questKeys.objectives] = {{{47292}}},
        },
        [27990] = { -- Battlezone
            [questKeys.objectives] = {{{47385},{47940}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Man the Siege Tank"), 0, {{"monster", 47732}}}},
        },
        [27993] = { -- Take it to 'Em!
            [questKeys.triggerEnd] = {"Khartut's Tomb Investigated",{[zoneIDs.ULDUM]={{64.6,28.6}}}},
            [questKeys.preQuestSingle] = {28112},
            [questKeys.exclusiveTo] = {27141},
        },
        [27955] = { -- Eye Spy
            [questKeys.objectives] = {{{47274}}},
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
        [28094] = { -- Paving the Way
            [questKeys.preQuestSingle] = {28097},
        },
        [28134] = { -- Impending Retribution
            [questKeys.objectives] = {{{46603},{47715},{47930}}}
        },
        [28145] = { -- Venomblood Antidote
            [questKeys.objectives] = {{{45859}}},
        },
        [28170] = { -- Night Terrors
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Uchek"), 0, {{"monster", 47826}}}},
        },
        [28191] = { -- A Fitting End
            [questKeys.preQuestSingle] = {28171},
        },
        [28247] = { -- Last of Her Kind
            [questKeys.objectives] = {{{47929,"Obsidia defeated"}}},
        },
        [28250] = { -- Thieving Little Pluckers
            [questKeys.objectives] = {nil,nil,nil,nil,{{{48040,48041,48043},48040,"Thieving plucker smashed"}}},
            [questKeys.preQuestSingle] = {28112},
        },
        [28351] = { -- Unlimited Potential
            [questKeys.objectives] = {{{51217}}},
        },
        [28352] = { -- Camelraderie
            [questKeys.objectives] = {{{51193}}},
        },
        [28376] = { -- Myzerian's Head
            [questKeys.startedBy] = {{48428},nil,{63700}},
        },
        [28403] = { -- Bad Datas
            [questKeys.triggerEnd] = {"Titan Data Uploaded",{[zoneIDs.ULDUM]={{36.18,23.25}}}},
            [questKeys.objectives] = {},
        },
        [28486] = { -- Salhet's Gambit
            [questKeys.triggerEnd] = {"Higher ground secured", {[zoneIDs.ULDUM]={{54.,71.1}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Ranmkahen Ranger Captain"), 0, {{"monster", 49244}}}},
        },
        [28501] = { -- The Defense of Nahom
            [questKeys.objectives] = {{{49228}}},
        },
        [28558] = { -- Hero's Call: Uldum!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [28584] = { -- Quality Construction
            [questKeys.preQuestSingle] = {28583},
        },
        [28586] = { -- Pool Pony Rescue
            [questKeys.preQuestSingle] = {28583},
        },
        [28592] = { -- Parting Packages
            [questKeys.preQuestSingle] = {28591},
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
        [28622] = { -- Three if by Air
            [questKeys.objectives] = {{{49211},{49215},{49216}}},
        },
        [28635] = { -- A Haunting in Hillsbrad
            [questKeys.triggerEnd] = {"Search Dun Garok for Evidence of a Haunting", {[zoneIDs.HILLSBRAD_FOOTHILLS]={{61.9,84.5}}}},
        },
        [28708] = { -- Hero's Call: Outland!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [28709] = { -- Hero's Call: Borean Tundra!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [28716] = { -- Hero's Call: Twilight Highlands!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [28717] = { -- Warchief's Command: Twilight Highlands!
            [questKeys.finishedBy] = {{39605}},
        },
        [28732] = { --This Can Only Mean One Thing...
            [questKeys.triggerEnd] = {"Arrive at Blackrock Caverns", {[zoneIDs.BLACKROCK_CAVERNS]={{33,66.4}}}},
            [questKeys.objectives] = {{{49456}},nil,nil,nil,},
        },
        [28734] = { -- A Favor for Melithar
            [questKeys.exclusiveTo] = {28715},
            [questKeys.nextQuestInChain] = 28715,
        },
        [28805] = { -- The Eye of the Storm
            [questKeys.objectives] = {nil,{{197196}}},
        },
        [28228] = { -- Rejoining the Forest
            [questKeys.triggerEnd] = {"Protector brought to hill", {[zoneIDs.FELWOOD]={{48.7,25.2}}}},
        },
        [28849] = { -- Twilight Skies
            [questKeys.preQuestGroup] = {26337,26372,26374},
        },
        [28870] = { -- Return to the Lost City
            [questKeys.preQuestSingle] = {28520},
        },
        [28871] = { -- Crushing the Wildhammer
            [questKeys.preQuestSingle] = {28133},
        },
        [28872] = { -- Total War
            [questKeys.objectives] = {nil,{{206195}}},
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
        [28909] = { -- Sauranok Will Point the Way
            [questKeys.startedBy] = {{39605}},
            [questKeys.preQuestSingle] = {26294},
            [questKeys.exclusiveTo] = {26311},
        },
        [29102] = { -- To Fort Livingston
            [questKeys.triggerEnd] = {"Head to Fort Livingston in Northern Stranglethorn Vale.", {[zoneIDs.STRANGLETHORN_VALE]={{52.8,67.2}}}},
        },
        [29156] = { -- The Troll Incursion
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [29220] = { -- To Bambala
            [questKeys.triggerEnd] = {"Head to Bambala in Northern Stranglethorn Vale.", {[zoneIDs.STRANGLETHORN_VALE]={{64.6,40.4}}}},
        },
        [29326] = { -- The Nordrassil Summit
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 29335,
        },
        [29327] = { -- Elemental Bonds: Doubt
            [questKeys.nextQuestInChain] = 29336,
        },
        [29328] = { -- Elemental Bonds: Desire
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
        [29387] = { -- Guardians of Hyjal: Firelands Invasion!
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [29391] = { -- Guardians of Hyjal: Call of the Ancients
            [questKeys.startedBy] = {nil,{206111,206294,207320,207321,207322,281339}},
        },
        [29392] = { -- Missing Heirlooms
            [questKeys.triggerEnd] = {"Search the courier's cabin", {[zoneIDs.STORMWIND_CITY]={{41.4,72.5}}}},
        },
        [29415] = { -- Missing Heirlooms
            [questKeys.triggerEnd] = {"Search the courier's cabin", {[zoneIDs.DUROTAR]={{60,46.1}}}},
        },
        [29439] = { -- The Call of the World-Shaman
            [questKeys.exclusiveTo] = {29326},
            [questKeys.nextQuestInChain] = 29326,
        },
        [29440] = { -- The Call of the World-Shaman
            [questKeys.exclusiveTo] = {29326},
            [questKeys.nextQuestInChain] = 29326,
        },
        [29475] = { -- Goblin Engineering
            [questKeys.startedBy] = {{5174,5518,8126,8738,11017,11031,16667,16726,29513,52636,52651}},
            [questKeys.finishedBy] = {{5174,5518,11017,11031,16667,16726,29513,52636,52651}},
            [questKeys.exclusiveTo] = {3639,3641,3643,29477},
        },
        [29477] = { -- Gnomish Engineering
            [questKeys.startedBy] = {{5174,5518,7406,7944,11017,11031,16667,16726,29514,52636,52651}},
            [questKeys.finishedBy] = {{5174,5518,7944,11017,11031,16667,16726,29514,52636,52651}},
            [questKeys.exclusiveTo] = {3639,3641,3643,29475},
        },
        [29481] = { -- Elixir Master
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29482] = { -- Transmutation Master
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29536] = { -- Heart of Rage
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.THE_BLOOD_FURNACE]={{64.9,41.5}}}},
        },
        [29539] = { -- Heart of Rage
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.THE_BLOOD_FURNACE]={{64.9,41.5}}}},
        },
    }
end

function CataQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys

    local questFixesHorde = {
        [29481] = { -- Elixir Master
            [questKeys.startedBy] = {{3347}}
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{3347}}
        },
    }

    local questFixesAlliance = {
        [29481] = { -- Elixir Master
            [questKeys.startedBy] = {{5499}}
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{5499}}
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
