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

function MopQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local profKeys = QuestieProfessions.professionKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local specialFlags = QuestieDB.specialFlags

    return {
        [29406] = { -- The Lesson of the Sandy Fist
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29408] = { -- The Lesson of the Burning Scroll
            [questKeys.objectives] = {{{53566,nil,Questie.ICON_TYPE_EVENT}},{{210986}}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29409] = { -- The Disciple's Challenge
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29410] = { -- Aysa of the Tushui
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29414] = { -- The Way of the Tushui
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{59642,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29417] = { -- The Way of the Huojin
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29418] = { -- Kindling the Fire
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29419] = { -- The Missing Driver
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{54855,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29420] = { -- The Spirit's Guardian
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29421] = { -- Only the Worthy Shall Pass
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29422] = { -- Huo, the Spirit of Fire
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{57779,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29423] = { -- The Passion of Shen-zin Su
            [questKeys.requiredLevel] = 3,
            [questKeys.startedBy] = {{54787,54135}},
            [questKeys.preQuestSingle] = {29422},
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{54786,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29424] = { -- Items of Utmost Importance
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29521] = { -- The Singing Pools
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29522] = { -- Ji of the Huojin
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29523] = { -- Fanning the Flames
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Wind Stone"),0,{{"object",210122}}}},
        },
        [29524] = { -- The Lesson of Stifled Pride
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29611] = { -- The Art of War
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{54870,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29612] = { -- The Art of War
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{54870,nil,Questie.ICON_TYPE_TALK}}},
        },
        [29661] = { -- The Lesson of Dry Fur
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209608}}},
        },
        [29662] = { -- Stronger Than Reeds
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29663] = { -- The Lesson of the Balanced Rock
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{55019,65468},55019}}},
        },
        [29664] = { -- The Challenger's Fires
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209369},{209801},{209802},{209803}}},
            [questKeys.requiredSourceItems] = {75000},
        },
        [29665] = { -- From Bad to Worse
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
        },
        [29666] = { -- The Sting of Learning
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29676] = { -- Finding an Old Friend
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29661,29662,29663},
        },
        [29677] = { -- The Sun Pearl
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29678] = { -- Shu, the Spirit of Water
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29666,29677},
            [questKeys.finishedBy] = {{110000}},
            [questKeys.objectives] = {{{57476,nil,Questie.ICON_TYPE_EVENT},{55205,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29679] = { -- A New Friend
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{60488,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29680] = { -- The Source of Our Livelihood
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57710}}}},
        },
        [29768] = { -- Missing Mallet
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29769,29770},
            [questKeys.preQuestSingle] = {},
        },
        [29769] = { -- Rascals
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29680},
        },
        [29770] = { -- Still Good!
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29680},
        },
        [29771] = { -- Stronger Than Wood
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29769,29770},
        },
        [29772] = { -- Raucous Rousing
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209626}}},
        },
        [29774] = { -- Not In the Face!
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29771,29772},
            [questKeys.objectives] = {{{55556,nil,Questie.ICON_TYPE_TALK},{60916,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29775] = { -- The Spirit and Body of Shen-zin Su
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",59497}}}},
            [questKeys.preQuestSingle] = {29774},
        },
        [29776] = { -- Morning Breeze Village
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29775},
        },
        [29777] = { -- Tools of the Enemy
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29776},
        },
        [29778] = { -- Rewritten Wisdoms
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29775},
            [questKeys.objectives] = {nil,{{209656}}},
        },
        [29779] = { -- The Direct Solution
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.finishedBy] = {{55583,65558}},
        },
        [29780] = { -- Do No Evil
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.finishedBy] = {{55583,65558}},
        },
        [29781] = { -- Monkey Advisory Warning
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.finishedBy] = {{55583,65558}},
        },
        [29782] = { -- Stronger Than Bone
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29783},
        },
        [29783] = { -- Stronger Than Stone
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29784] = { -- Balanced Perspective
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29779,29780,29781},
            [questKeys.startedBy] = {{55583,65558}},
        },
        [29785] = { -- Dafeng, the Spirit of Air
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29782,29784},
            [questKeys.objectives] = {{{55592,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29786] = { -- Battle for the Skies
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29787] = { -- Worthy of Passing
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29788] = { -- Unwelcome Nature
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29789] = { -- Small, But Significant
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29790] = { -- Passing Wisdom
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29788,29789},
            [questKeys.objectives] = {{{56686,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29791] = { -- The Suffering of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{55918,nil,Questie.ICON_TYPE_MOUNT_UP},{55939}}},
        },
        [29792] = { -- Bidden to Greatness
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29791},
            [questKeys.objectives] = {nil,{{210965},{210964}}},
        },
        [29793] = { -- Evil from the Seas
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {30589},
        },
        [29794] = { -- None Left Behind
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
            [questKeys.objectives] = {{{55999,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29795] = { -- Stocking Stalks
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29792},
        },
        [29796] = { -- Urgent News
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29793,30590},
        },
        [29797] = { -- Medical Supplies
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
        },
        [29798] = { -- An Ancient Evil
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29665,29794,29797},
        },
        [29799] = { -- The Healing of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {30767},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60770,60834,60877,60878},60770,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29800] = { -- New Allies
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29799},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57741}}}},
        },
        [29815] = { -- Forensic Science
            [questKeys.objectives] = {nil,nil,{{74621,nil,Questie.ICON_TYPE_OBJECT}}},
        },
        [30027] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {73209},
        },
        [30033] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {76390,76392},
        },
        [30034] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {73211},
        },
        [30035] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {73207,76393},
        },
        [30036] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {73208,73212},
        },
        [30037] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {73213,76391},
        },
        [30038] = { -- The Lesson of the Iron Bough
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredSourceItems] = {73210},
        },
        [30039] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.MONK,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30040] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.MAGE,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30041] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.HUNTER,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30042] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30043] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.ROGUE,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30044] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30045] = { -- Much to Learn
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.startedBy] = {nil,{210051}},
        },
        [30135] = { -- Beating the Odds
            [questKeys.preQuestSingle] = {30134},
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
        [30144] = { -- Flight Training: Ring Round-Up
            [questKeys.preQuestSingle] = {30143},
        },
        [30145] = { -- Flight Training: Full Speed Ahead
            [questKeys.preQuestSingle] = {30144},
        },
        [30187] = { -- Flight Training: In Due Course
            [questKeys.preQuestSingle] = {30145},
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
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29795,30591},
        },
        [30590] = { -- Handle With Care
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {30589},
        },
        [30591] = { -- Preying on the Predators
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29792},
        },
        [30617] = { -- Roadside Assistance
            [questKeys.preQuestSingle] = {30616},
        },
        [30767] = { -- Risking It All
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29798},
            [questKeys.objectives] = {{{60727,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30881] = { -- Round 2: Clever Ashyo & Ken-Ken
            [questKeys.preQuestSingle] = {30879},
        },
        [30882] = { -- Round 2: Kang Bramblestaff
            [questKeys.preQuestSingle] = {30880},
        },
        [30883] = { -- Round 3: The Wrestler
            [questKeys.preQuestSingle] = {30879},
        },
        [30885] = { -- Round 3: Master Boom Boom
            [questKeys.preQuestSingle] = {30882},
        },
        [30902] = { -- Round 4: Master Windfur
            [questKeys.preQuestSingle] = {30885},
        },
        [30907] = { -- Round 4: The P.U.G.
            [questKeys.preQuestSingle] = {30883},
        },
        [30987] = { -- Joining the Alliance
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {31450},
        },
        [30988] = { -- The Alliance Way
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {30987},
            [questKeys.startedBy] = {{29611}},
            [questKeys.finishedBy] = {{61796}},
        },
        [30989] = { -- An Old Pit Fighter
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {30988},
            [questKeys.objectives] = {{{61796,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31012] = { -- Joining the Horde
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31450},
        },
        [31013] = { -- The Horde Way
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31012},
            [questKeys.startedBy] = {{39605}},
        },
        [31014] = { -- Hellscream's Gift
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31013},
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{62209,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31169] = { -- The Art of the Monk
            [questKeys.requiredClasses] = classIDs.MONK,
        },
        [31288] = { -- Research Project: The Mogu Dynasties
            [questKeys.exclusiveTo] = {31289},
        },
        [31289] = { -- Uncovering the Past
            [questKeys.exclusiveTo] = {31288},
        },
        [31313] = { -- Just A Folk Stor
            [questKeys.preQuestSingle] = {31312},
        },
        [31314] = { -- Old Man Thistle's Treasure
            [questKeys.preQuestSingle] = {31313},
        },
        [31315] = { -- The Heartland Legacy
            [questKeys.preQuestSingle] = {31314},
        },
        [31367] = { -- The Lorewalkers
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31368] = { -- The Lorewalkers
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31369] = { -- The Anglers
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31370] = { -- The Anglers
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31372] = { -- The Tillers
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31373] = { -- The Order of the Cloud Serpent
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31374] = { -- The Tillers
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31375] = { -- The Order of the Cloud Serpent
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31376] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31378,31380,31382},
        },
        [31377] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {31379,31381,31383},
        },
        [31378] = { -- Challenge At The Temple of the Red Crane
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31376,31380,31382},
        },
        [31379] = { -- Challenge At The Temple of the Red Crane
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {31377,31381,31383},
        },
        [31380] = { -- Trial At The Temple of the White Tiger
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31376,31378,31382},
        },
        [31381] = { -- Trial At The Temple of the White Tiger
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {31377,31379,31383},
        },
        [31382] = { -- Defense At Niuzao Temple
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31376,31378,31380},
        },
        [31383] = { -- Defense At Niuzao Temple
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {31377,31379,31381},
        },
        [31384] = { -- The Golden Lotus
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31385] = { -- The Golden Lotus
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31386] = { -- The Shado-Pan Offensive
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31387] = { -- Understanding The Shado-Pan
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31388] = { -- The Shado-Pan Offensive
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31389] = { -- Understanding The Shado-Pan
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31390] = { -- The Klaxxi
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31391] = { -- The Klaxxi
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31392] = { -- Temple of the White Tiger
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31393] = { -- Temple of the White Tiger
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31394] = { -- A Celestial Experience
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31395] = { -- A Celestial Experience
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31450] = { -- A New Fate
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29800},
            [questKeys.objectives] = {{{56013,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31486] = { -- Everything I Know About Cooking
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
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
        [31308] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31309] = { -- On The Mend
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31308},
            [questKeys.objectives] = {{{6749,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31316] = { -- Julia, The Pet Tamer
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{64330,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31548] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63075}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31549] = { -- On The Mend
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31548},
            [questKeys.objectives] = {{{9980,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31550] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31785},
        },
        [31551] = { -- Got one!
            [questKeys.startedBy] = {{63075}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31822},
        },
        [31552] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63070}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31553] = { -- On The Mend
            [questKeys.startedBy] = {{63070}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31552},
            [questKeys.objectives] = {{{10051,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31555] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31826},
        },
        [31556] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31568] = { -- On The Mend
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31556},
            [questKeys.objectives] = {{{17485,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31569] = { -- Got one!
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31825},
        },
        [31570] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31830},
        },
        [31571] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31572] = { -- On The Mend
            [questKeys.startedBy] = {{63061}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31571},
            [questKeys.objectives] = {{{9987,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31573] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31574] = { -- On The Mend
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31573},
            [questKeys.objectives] = {{{10050,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31575] = { -- Got one!
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31831},
        },
        [31576] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31577] = { -- On The Mend
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31576},
            [questKeys.objectives] = {{{10055,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31578] = { -- Got one!
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31823},
        },
        [31579] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31580] = { -- On The Mend
            [questKeys.startedBy] = {{63080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31579},
            [questKeys.objectives] = {{{16185,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31581] = { -- Got one!
            [questKeys.startedBy] = {{63080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31824},
        },
        [31582] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31583] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31582},
            [questKeys.objectives] = {{{10085,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31584] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31832},
        },
        [31585] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31586] = { -- On The Mend
            [questKeys.startedBy] = {{63086}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31585},
            [questKeys.objectives] = {{{45789,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31587] = { -- Got one!
            [questKeys.startedBy] = {{63086}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31828},
        },
        [31588] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31589] = { -- On The Mend
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31588},
            [questKeys.objectives] = {{{47764,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31590] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31827},
        },
        [31591] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31592] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31591},
            [questKeys.objectives] = {{{11069,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31593] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31821},
        },
        [31777] = { -- Choppertunity
            [questKeys.requiredSourceItems] = {89163},
        },
        [31785] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31309},
        },
        [31812] = { -- Zunta, The Pet Tamer
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66126,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31821] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31592},
        },
        [31822] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31549},
        },
        [31823] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31577},
        },
        [31824] = { -- Level Up!
            [questKeys.startedBy] = {{63080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31580},
        },
        [31825] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31568},
        },
        [31826] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31553},
        },
        [31827] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31589},
        },
        [31828] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31586},
        },
        [31830] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31572},
        },
        [31831] = { -- Level Up!
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31574},
        },
        [31832] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31583},
        },
        [31876] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [31877] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [32008] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [32009] = { -- Varzok
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [32016] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{64029}},
        },
        [32017] = { -- Elder Charms of Good Fortune
            [questKeys.startedBy] = {{63996}},
        },
        [32807] = { -- The Warchief and the Darkness
            [questKeys.preQuestSingle] = {32806},
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
