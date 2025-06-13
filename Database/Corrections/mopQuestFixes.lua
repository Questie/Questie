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

QuestieCorrections.killCreditObjectiveFirst[29555] = true

function MopQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local profKeys = QuestieProfessions.professionKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local specialFlags = QuestieDB.specialFlags

    return {
        [13408] = { -- Hellfire Fortifications
            [questKeys.requiredClasses] = 2015, -- all classes except DK
        },
        [13409] = { -- Hellfire Fortifications
            [questKeys.requiredClasses] = 2015, -- all classes except DK
        },
        [29406] = { -- The Lesson of the Sandy Fist
            [questKeys.requiredLevel] = 1,
        },
        [29408] = { -- The Lesson of the Burning Scroll
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {{{53566,nil,Questie.ICON_TYPE_EVENT}},{{210986}}},
        },
        [29409] = { -- The Disciple's Challenge
            [questKeys.requiredLevel] = 1,
        },
        [29410] = { -- Aysa of the Tushui
            [questKeys.requiredLevel] = 1,
        },
        [29414] = { -- The Way of the Tushui
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {{{59642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
        },
        [29417] = { -- The Way of the Huojin
            [questKeys.requiredLevel] = 2,
        },
        [29418] = { -- Kindling the Fire
            [questKeys.requiredLevel] = 2,
        },
        [29419] = { -- The Missing Driver
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {{{54855,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29420] = { -- The Spirit's Guardian
            [questKeys.requiredLevel] = 2,
            [questKeys.preQuestSingle] = {},
        },
        [29421] = { -- Only the Worthy Shall Pass
            [questKeys.requiredLevel] = 2,
        },
        [29422] = { -- Huo, the Spirit of Fire
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {{{57779,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29423] = { -- The Passion of Shen-zin Su
            [questKeys.startedBy] = {{54787,54135}},
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {{{54786,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29424] = { -- Items of Utmost Importance
            [questKeys.requiredLevel] = 1,
        },
        [29521] = { -- The Singing Pools
            [questKeys.requiredLevel] = 3,
        },
        [29522] = { -- Ji of the Huojin
            [questKeys.requiredLevel] = 1,
        },
        [29523] = { -- Fanning the Flames
            [questKeys.requiredLevel] = 2,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Wind Stone"),0,{{"object",210122}}}},
        },
        [29524] = { -- The Lesson of Stifled Pride
            [questKeys.requiredLevel] = 1,
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
        },
        [29663] = { -- The Lesson of the Balanced Rock
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{55019,65468},55019}}},
        },
        [29664] = { -- The Challenger's Fires
            [questKeys.requiredLevel] = 2,
            [questKeys.objectives] = {nil,{{209369},{209801},{209802},{209803}}},
            [questKeys.requiredSourceItems] = {75000},
        },
        [29665] = { -- From Bad to Worse
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29796},
        },
        [29666] = { -- The Sting of Learning
            [questKeys.requiredLevel] = 3,
        },
        [29676] = { -- Finding an Old Friend
            [questKeys.requiredLevel] = 3,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29661,29662,29663},
        },
        [29677] = { -- The Sun Pearl
            [questKeys.requiredLevel] = 3,
        },
        [29678] = { -- Shu, the Spirit of Water
            [questKeys.finishedBy] = {{110000}},
            [questKeys.requiredLevel] = 3,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29666,29677},
            [questKeys.objectives] = {{{57476,nil,Questie.ICON_TYPE_EVENT},{55205,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29679] = { -- A New Friend
            [questKeys.requiredLevel] = 3,
            [questKeys.objectives] = {{{60488,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29680] = { -- The Source of Our Livelihood
            [questKeys.requiredLevel] = 3,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57710}}}},
        },
        [29744] = { -- Some "Pupil of Nature"
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbForQuestId] = 29745,
        },
        [29745] = { -- The Sprites' Plight
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {29744},
        },
        [29768] = { -- Missing Mallet
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29769,29770},
        },
        [29769] = { -- Rascals
            [questKeys.requiredLevel] = 4,
        },
        [29770] = { -- Still Good!
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29680},
        },
        [29771] = { -- Stronger Than Wood
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestGroup] = {29769,29770},
        },
        [29772] = { -- Raucous Rousing
            [questKeys.requiredLevel] = 4,
            [questKeys.objectives] = {nil,{{209626}}},
        },
        [29774] = { -- Not In the Face!
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29771,29772},
            [questKeys.objectives] = {{{55556,nil,Questie.ICON_TYPE_TALK},{60916,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29775] = { -- The Spirit and Body of Shen-zin Su
            [questKeys.requiredLevel] = 4,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",59497}}}},
        },
        [29776] = { -- Morning Breeze Village
            [questKeys.requiredLevel] = 4,
            [questKeys.preQuestSingle] = {29775},
        },
        [29777] = { -- Tools of the Enemy
            [questKeys.requiredLevel] = 5,
        },
        [29778] = { -- Rewritten Wisdoms
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {nil,{{209656}}},
            [questKeys.preQuestSingle] = {29775},
        },
        [29779] = { -- The Direct Solution
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
        },
        [29780] = { -- Do No Evil
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
        },
        [29781] = { -- Monkey Advisory Warning
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
        },
        [29782] = { -- Stronger Than Bone
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29783},
            [questKeys.nextQuestInChain] = 29785,
        },
        [29783] = { -- Stronger Than Stone
            [questKeys.requiredLevel] = 5,
        },
        [29784] = { -- Balanced Perspective
            [questKeys.startedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29779,29780,29781},
        },
        [29785] = { -- Dafeng, the Spirit of Air
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{55592,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29782,29784},
        },
        [29786] = { -- Battle for the Skies
            [questKeys.requiredLevel] = 5,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Firework Launcher"),0,{{"monster",64507}}}},
        },
        [29787] = { -- Worthy of Passing
            [questKeys.requiredLevel] = 5,
        },
        [29788] = { -- Unwelcome Nature
            [questKeys.requiredLevel] = 5,
        },
        [29789] = { -- Small, But Significant
            [questKeys.requiredLevel] = 5,
        },
        [29790] = { -- Passing Wisdom
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{56686,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29788,29789},
        },
        [29791] = { -- The Suffering of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{55918,nil,Questie.ICON_TYPE_MOUNT_UP},{55939}}},
        },
        [29792] = { -- Bidden to Greatness
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {nil,{{210965,nil,Questie.ICON_TYPE_EVENT},{210964,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29793] = { -- Evil from the Seas
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {30589},
        },
        [29794] = { -- None Left Behind
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{55999,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {29796},
            [questKeys.nextQuestInChain] = 29798,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_EVENT,l10n("Bring the Injured Sailor to Delora Lionheart"),0,{{"monster",55944}}}},
        },
        [29795] = { -- Stocking Stalks
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29792},
        },
        [29796] = { -- Urgent News
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29793,30590},
            [questKeys.nextQuestInChain] = 29797,
        },
        [29797] = { -- Medical Supplies
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29796},
            [questKeys.nextQuestInChain] = 29798,
        },
        [29798] = { -- An Ancient Evil
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29665,29794,29797},
        },
        [29799] = { -- The Healing of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60770,60834,60877,60878},60770,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29800,
        },
        [29800] = { -- New Allies
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {29799},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57741}}}},
        },
        [29815] = { -- Forensic Science
            [questKeys.objectives] = {nil,nil,{{74621,nil,Questie.ICON_TYPE_OBJECT}}},
        },
        [30027] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73209},
        },
        [30033] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {76390,76392},
        },
        [30034] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73211},
        },
        [30035] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73207,76393},
        },
        [30036] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73208,73212},
        },
        [30037] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73213,76391},
        },
        [30038] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredSourceItems] = {73210},
        },
        [30039] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.MONK,
        },
        [30040] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [30041] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.HUNTER,
        },
        [30042] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.PRIEST,
        },
        [30043] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [30044] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
        },
        [30045] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
        },
        [30069] = { -- No Plan Survives Contact with the Enemy
            [questKeys.preQuestSingle] = {31733},
        },
        [30070] = { -- The Fall of Ga'trul
            [questKeys.preQuestGroup] = {31741,31742,31743,31744},
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
        [30188] = { -- Riding the Skies (Jade Cloud Serpent)
            [questKeys.preQuestGroup] = {30140,30187},
        },
        [31810] = { -- Riding the Skies (Azure Cloud Serpent)
            [questKeys.preQuestGroup] = {30139,30187},
        },
        [31811] = { -- Riding the Skies (Golden Cloud Serpent)
            [questKeys.preQuestGroup] = {30141,30187},
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
        [30589] = { -- Wrecking the Wreck
            [questKeys.requiredLevel] = 5,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29795,30591},
        },
        [30590] = { -- Handle With Care
            [questKeys.requiredLevel] = 5,
        },
        [30591] = { -- Preying on the Predators
            [questKeys.requiredLevel] = 5,
        },
        [30767] = { -- Risking It All
            [questKeys.requiredLevel] = 5,
            [questKeys.objectives] = {{{60727,nil,Questie.ICON_TYPE_EVENT}}},
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
        [31169] = { -- The Art of the Monk
            [questKeys.requiredClasses] = classIDs.MONK,
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
        },
        [31488] = { -- Stranger in a Strange Land
            [questKeys.startedBy] = {{62871,64047,64144,66225,66409,66415}},
        },
        [31519] = {-- A Worthy Challenge: Yan-zhu the Uncasked
            [questKeys.exclusiveTo] = {31520,31522,31523,31524,31525,31526,31527,31528},
        },
        [31520] = {-- A Worthy Challenge: Sha of Doubt
            [questKeys.exclusiveTo] = {31519,31522,31523,31524,31525,31526,31527,31528},
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
        [31777] = { -- Choppertunity
            [questKeys.requiredSourceItems] = {89163},
        },
        [31780] = { -- Old MacDonald
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65648,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31781] = { -- Lindsay
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{65651,nil,Questie.ICON_TYPE_PET_BATTLE}}},
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
        [32008] = { -- Audrey Burnhep
            [questKeys.exclusiveTo] = {31316},
        },
        [32016] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{64029}},
        },
        [32017] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{63996}},
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
    }
end
