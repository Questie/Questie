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
        [31377] = { -- Attack At The Temple of the Jade Serpent
            [questKeys.exclusiveTo] = {31379,31381,31383},
        },
        [31379] = { -- Challenge At The Temple of the Red Crane
            [questKeys.exclusiveTo] = {31377,31381,31383},
        },
        [31381] = { -- Trial At The Temple of the White Tiger
            [questKeys.exclusiveTo] = {31377,31379,31383},
        },
        [31383] = { -- Defense At Niuzao Temple
            [questKeys.exclusiveTo] = {31377,31379,31381},
        },
        [31384] = { -- The Golden Lotus
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31392] = { -- Temple of the White Tiger
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [31393] = { -- Temple of the White Tiger
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [31450] = { -- A New Fate
            [questKeys.requiredLevel] = 5,
            [questKeys.requiredRaces] = raceIDs.PANDAREN,
            [questKeys.preQuestSingle] = {29800},
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
        [31876] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
        },
        [31877] = { -- The Inkmasters of the Arboretum
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION, 1},
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
    }
end
