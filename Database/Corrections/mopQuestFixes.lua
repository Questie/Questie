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
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{53566,nil,Questie.ICON_TYPE_EVENT}},{{210986}}},
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
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{59642,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
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
            [questKeys.requiredLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
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
            [questKeys.startedBy] = {{54787,54135}},
            [questKeys.requiredLevel] = 3,
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
            [questKeys.finishedBy] = {{110000}},
            [questKeys.requiredLevel] = 3,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29666,29677},
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
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29769,29770},
        },
        [29769] = { -- Rascals
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
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
        },
        [29776] = { -- Morning Breeze Village
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29775},
        },
        [29777] = { -- Tools of the Enemy
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29778] = { -- Rewritten Wisdoms
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209656}}},
            [questKeys.preQuestSingle] = {29775},
        },
        [29779] = { -- The Direct Solution
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
        },
        [29780] = { -- Do No Evil
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
        },
        [29781] = { -- Monkey Advisory Warning
            [questKeys.finishedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.nextQuestInChain] = 29784,
        },
        [29782] = { -- Stronger Than Bone
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29783},
            [questKeys.nextQuestInChain] = 29785,
        },
        [29783] = { -- Stronger Than Stone
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29784] = { -- Balanced Perspective
            [questKeys.startedBy] = {{55583,65558}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29779,29780,29781},
        },
        [29785] = { -- Dafeng, the Spirit of Air
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{55592,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29782,29784},
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
            [questKeys.objectives] = {{{56686,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29788,29789},
        },
        [29791] = { -- The Suffering of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{55918,nil,Questie.ICON_TYPE_MOUNT_UP},{55939}}},
        },
        [29792] = { -- Bidden to Greatness
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
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
            [questKeys.objectives] = {{{55999,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {29796},
            [questKeys.nextQuestInChain] = 29798,
        },
        [29795] = { -- Stocking Stalks
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29792},
        },
        [29796] = { -- Urgent News
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29793,30590},
            [questKeys.nextQuestInChain] = 29797,
        },
        [29797] = { -- Medical Supplies
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
            [questKeys.nextQuestInChain] = 29798,
        },
        [29798] = { -- An Ancient Evil
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29665,29794,29797},
        },
        [29799] = { -- The Healing of Shen-zin Su
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60770,60834,60877,60878},60770,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 29800,
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
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.MONK,
        },
        [30040] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [30041] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.HUNTER,
        },
        [30042] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.PRIEST,
        },
        [30043] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [30044] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
        },
        [30045] = { -- Much to Learn
            [questKeys.startedBy] = {nil,{210051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
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
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29795,30591},
        },
        [30590] = { -- Handle With Care
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [30591] = { -- Preying on the Predators
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [30767] = { -- Risking It All
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{60727,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30987] = { -- Joining the Alliance
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {31450},
            [questKeys.nextQuestInChain] = 30988,
        },
        [30988] = { -- The Alliance Way
            [questKeys.startedBy] = {{29611}},
            [questKeys.finishedBy] = {{61796}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {30987},
        },
        [30989] = { -- An Old Pit Fighter
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.objectives] = {{{61796,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31012] = { -- Joining the Horde
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31450},
        },
        [31013] = { -- The Horde Way
            [questKeys.startedBy] = {{39605}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.nextQuestInChain] = 31014,
        },
        [31014] = { -- Hellscream's Gift
            [questKeys.finishedBy] = {{39605}},
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.objectives] = {{{62209,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestSingle] = {31013},
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
            [questKeys.objectives] = {{{9980,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31550] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31551] = { -- Got one!
            [questKeys.startedBy] = {{63075}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31552] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63070}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31553] = { -- On The Mend
            [questKeys.startedBy] = {{63070}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{10051,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31555] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31556] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31568] = { -- On The Mend
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{17485,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31569] = { -- Got one!
            [questKeys.startedBy] = {{63077}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31570] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31571] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31572] = { -- On The Mend
            [questKeys.startedBy] = {{63061}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{9987,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31573] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31574] = { -- On The Mend
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{10050,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31575] = { -- Got one!
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31576] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31577] = { -- On The Mend
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{10055,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31578] = { -- Got one!
            [questKeys.startedBy] = {{63073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31579] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31580] = { -- On The Mend
            [questKeys.startedBy] = {{63080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{16185,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31581] = { -- Got one!
            [questKeys.startedBy] = {{63080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31582] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31583] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{10085,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31584] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31585] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31586] = { -- On The Mend
            [questKeys.startedBy] = {{63086}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{45789,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31587] = { -- Got one!
            [questKeys.startedBy] = {{63086}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31588] = { -- Learning the Ropes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31589] = { -- On The Mend
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{47764,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31590] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31591] = { -- Learning the Ropes
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31592] = { -- On The Mend
            [questKeys.startedBy] = {{63083}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{11069,nil,Questie.ICON_TYPE_TALK}}},
        },
        [31593] = { -- Got one!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31777] = { -- Choppertunity
            [questKeys.requiredSourceItems] = {89163},
        },
        [31785] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31812] = { -- Zunta, The Pet Tamer
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{66126,nil,Questie.ICON_TYPE_PET_BATTLE}}},
        },
        [31821] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31822] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31823] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31824] = { -- Level Up!
            [questKeys.startedBy] = {{63080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31825] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31826] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31827] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31828] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31830] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31831] = { -- Level Up!
            [questKeys.startedBy] = {{63067}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31832] = { -- Level Up!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31876] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [31878] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
        },
        [31879] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
        },
        [31880] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
        },
        [31881] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
        },
        [31877] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [31889] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31917},
        },
        [31891] = { -- Battle Pet Tamers: Kalimdor
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31918},
        },
        [31917] = { -- A Tamer's Homecoming
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31918] = { -- A Tamer's Homecoming
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31975] = { -- The Returning Champion
            [questKeys.startedBy] = {{66466}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31897},
        },
        [31976] = { -- The Returning Champion
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31897},
        },
        [31977] = { -- The Returning Champion
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31897},
        },
        [31980] = { -- The Returning Champion
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31897},
        },
        [31981] = { -- Exceeding Expectations
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31920},
        },
        [31982] = { -- Exceeding Expectations
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31920},
        },
        [31983] = { -- A Brief Reprieve
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31928},
        },
        [31984] = { -- A Brief Reprieve
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31928},
        },
        [31985] = { -- The Triumphant Return
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {31970},
        },
        [31986] = { -- The Triumphant Return
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {31970},
        },
        [31990] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
        },
        [32008] = { -- Audrey Burnhep
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {31316},
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
