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
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{59642,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29417] = { -- The Way of the Huojin
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29418] = { -- Kindling the Fire
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29419] = { -- The Missing Driver
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{54855,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29420] = { -- The Spirit's Guardian
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29421] = { -- Only the Worthy Shall Pass
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29422] = { -- Huo, the Spirit of Fire
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{57779,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29423] = { -- The Passion of Shen-zin Su
            [questKeys.startedBy] = {{54787,54135}},
            [questKeys.preQuestSingle] = {29422},
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{54786,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29424] = { -- Items of Utmost Importance
            [questKeys.requiredLevel] = 1, ---??
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29521] = { -- The Singing Pools
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29522] = { -- Ji of the Huojin
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29523] = { -- Fanning the Flames
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Use the Wind Stone"),0,{{"object",210122}}}},
        },
        [29524] = { -- The Lesson of Stifled Pride
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29661] = { -- The Lesson of Dry Fur
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209608}}},
        },
        [29662] = { -- Stronger Than Reeds
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29663] = { -- The Lesson of the Balanced Rock
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{55019,65468},55019}}},
        },
        [29664] = { -- The Challenger's Fires
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209369},{209801},{209802},{209803}}},
            [questKeys.requiredSourceItems] = {75000},
        },
        [29665] = { -- From Bad to Worse
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
        },
        [29666] = { -- The Sting of Learning
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29676] = { -- Finding an Old Friend
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29661,29662,29663},
        },
        [29677] = { -- The Sun Pearl
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29678] = { -- Shu, the Spirit of Water
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29666,29677},
            [questKeys.finishedBy] = {{110000}},
            [questKeys.objectives] = {{{57476,nil,Questie.ICON_TYPE_EVENT},{55205,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29679] = { -- A New Friend
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{60488,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29680] = { -- The Source of Our Livelihood
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57710}}}},
        },
        [29768] = { -- Missing Mallet
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29769,29770},
            [questKeys.preQuestSingle] = {},
        },
        [29769] = { -- Rascals
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29680},
        },
        [29770] = { -- Still Good!
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29680},
        },
        [29771] = { -- Stronger Than Wood
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29769,29770},
        },
        [29772] = { -- Raucous Rousing
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {nil,{{209626}}}, -- "unk name", it's actually "Break Gong"
        },
        [29774] = { -- Not In the Face!
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29771,29772},
            [questKeys.objectives] = {{{55556,nil,Questie.ICON_TYPE_TALK},{60916,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29775] = { -- The Spirit and Body of Shen-zin Su
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",59497}}}},
            [questKeys.preQuestSingle] = {29774},
        },
        [29776] = { -- Morning Breeze Village
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29775},
        },
        [29777] = { -- Tools of the Enemy
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29776},
        },
        [29778] = { -- Rewritten Wisdoms
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29775},
            [questKeys.objectives] = {nil,{{209656}}}, -- "unk name", it's actually "Defaced Scroll of Wisdom"
        },
        [29779] = { -- The Direct Solution
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.finishedBy] = {{55583,65558}},
        },
        [29780] = { -- Do No Evil
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.finishedBy] = {{55583,65558}},
        },
        [29781] = { -- Monkey Advisory Warning
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29777,29778,29783},
            [questKeys.finishedBy] = {{55583,65558}},
        },
        [29782] = { -- Stronger Than Bone
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29783},
        },
        [29783] = { -- Stronger Than Stone
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29784] = { -- Balanced Perspective
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29779,29780,29781},
            [questKeys.startedBy] = {{55583,65558}},
        },
        [29785] = { -- Dafeng, the Spirit of Air
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29782,29784},
            [questKeys.objectives] = {{{55592,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29786] = { -- Battle for the Skies
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29787] = { -- Worthy of Passing
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29788] = { -- Unwelcome Nature
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29789] = { -- Small, But Significant
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
        },
        [29790] = { -- Passing Wisdom
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {29788,29789},
            [questKeys.objectives] = {{{56686,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29791] = { -- The Suffering of Shen-zin Su
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.objectives] = {{{55918,nil,Questie.ICON_TYPE_MOUNT_UP},{55939}}},
        },
        [29792] = { -- Bidden to Greatness
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29791},
            [questKeys.objectives] = {nil,{{210965},{210964}}},
        },
        [29793] = { -- Evil from the Seas
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {30589},
        },
        [29794] = { -- None Left Behind
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
            [questKeys.objectives] = {{{55999,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [29795] = { -- Stocking Stalks
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29792},
        },
        [29796] = { -- Urgent News
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29793,30590},
        },
        [29797] = { -- Medical Supplies
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29796},
        },
        [29798] = { -- An Ancient Evil
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29665,29794,29797},
        },
        [29799] = { -- The Healing of Shen-zin Su
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {30767},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{60770,60834,60877,60878},60770,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [29800] = { -- New Allies
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29799},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take a ride"),0,{{"monster",57741}}}},
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
        [30589] = { -- Wrecking the Wreck
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestGroup] = {29795,30591},
        },
        [30590] = { -- Handle With Care
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {30589},
        },
        [30591] = { -- Preying on the Predators
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29792},
        },
        [30767] = { -- Risking It All
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29798},
            [questKeys.objectives] = {{{60727,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [30987] = { -- Joining the Alliance
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {31450},
        },
        [30988] = { -- The Alliance Way
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {30987},
            [questKeys.startedBy] = {{29611}},
            [questKeys.finishedBy] = {{61796}},
        },
        [30989] = { -- An Old Pit Fighter
            [questKeys.requiredRaces] = raceIDs.PANDAREN_ALLIANCE,
            [questKeys.preQuestSingle] = {30988},
            [questKeys.objectives] = {{{61796,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [31012] = { -- Joining the Horde
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31450},
        },
        [31013] = { -- The Horde Way
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31012},
            [questKeys.startedBy] = {{39605}},
        },
        [31014] = { -- Hellscream's Gift
            [questKeys.requiredRaces] = raceIDs.PANDAREN_HORDE,
            [questKeys.preQuestSingle] = {31013},
            [questKeys.finishedBy] = {{39605}},
            [questKeys.objectives] = {{{62209,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [31450] = { -- A New Fate
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29800},
            [questKeys.objectives] = {{{56013,nil,Questie.ICON_TYPE_TALK}}},
        },
    }
end
