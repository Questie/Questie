
---@class QuestieDBZone
local QuestieDBZone = QuestieLoader:CreateModule("QuestieDBZone");

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local HBDMigrate = LibStub("HereBeDragonsQuestie-Migrate")


--Use these to convert your MapIds!
local zoneDataAreaIDToMapID = {} --Databaseareaids (Vanilla) to MapID(This is not UiMapID!)
local uiMapIDToAreaID = {} --You should really never need the MapIDs, but you can convert back using all 3 variables.
ZoneDataAreaIDToUiMapID = {}

function QuestieDBZone:GetAreaIdByUIMapID(uiMapId)
    local areaId = 0
    if uiMapIDToAreaID[uiMapId] ~= nil then
        areaId = uiMapIDToAreaID[uiMapId]
    end
    return areaId
end

local zoneLookupHack = {
    ["Barrens"] = "The Barrens",
    ["Alterac"] = "Alterac Mountains",
    ["Arathi"] = "Arathi Highlands",
    ["BlastedLands"] = "Blasted Lands",
    ["Tirisfal"] = "Tirisfal Glades",
    ["Silverpine"] = "Silverpine Forest",
    ["ArathiBasin"] = "Arathi Basin",
    ["WarsongGulch"] = "Warsong Gulch",
    ["AlteracValley"] = "Alterac Valley",
    ["Darnassis"] = "Darnassus", -- lol what
    ["ThunderBluff"] = "Thunder Bluff",
    ["Ogrimmar"] = "Orgrimmar", -- lol what
    ["Stormwind"] = "Stormwind City",
    ["EasternPlaguelands"] = "Eastern Plaguelands",
    ["WesternPlaguelands"] = "Western Plaguelands",
    ["Hilsbrad"] = "Hillsbrad Foothills",
    ["Hinterlands"] = "The Hinterlands",
    ["DunMorogh"] = "Dun Morogh",
    ["SearingGorge"] = "Searing Gorge",
    ["BurningSteppes"] = "Burning Steppes",
    ["Elwynn"] = "Elwynn Forest",
    ["DeadwindPass"] = "Deadwind Pass",
    ["LochModan"] = "Loch Modan",
    ["Redridge"] = "Redridge Mountains",
    ["Stranglethorn"] = "Stranglethorn Vale",
    ["SwampOfSorrows"] = "Swamp of Sorrows",
    ["ThousandNeedles"] = "Thousand Needles",
    ["Dustwallow"] = "Dustwallow Marsh",
    ["Aszhara"] = "Azshara", -- lol what
    ["UngoroCrater"] = "Un'Goro Crater",
    ["StonetalonMountains"] = "Stonetalon Mountains"
}
local zoneDataClassicBetaHack = {
    ["Azeroth"] = {947,0},
    ["Durotar"] = {1411,1414},
    ["Mulgore"] = {1412,1414},
    ["The Barrens"] = {1413,1414},
    ["Kalimdor"] = {1414,947},
    ["Eastern Kingdoms"] = {1415,947},
    ["Alterac Mountains"] = {1416,1415},
    ["Arathi Highlands"] = {1417,1415},
    ["Badlands"] = {1418,1415},
    ["Blasted Lands"] = {1419,1415},
    ["Tirisfal Glades"] = {1420,1415},
    ["Silverpine Forest"] = {1421,1415},
    ["Western Plaguelands"] = {1422,1415},
    ["Eastern Plaguelands"] = {1423,1415},
    ["Hillsbrad Foothills"] = {1424,1415},
    ["The Hinterlands"] = {1425,1415},
    ["Dun Morogh"] = {1426,1415},
    ["Searing Gorge"] = {1427,1415},
    ["Burning Steppes"] = {1428,1415},
    ["Elwynn Forest"] = {1429,1415},
    ["Deadwind Pass"] = {1430,1415},
    ["Duskwood"] = {1431,1415},
    ["Loch Modan"] = {1432,1415},
    ["Redridge Mountains"] = {1433,1415},
    ["Stranglethorn Vale"] = {1434,1415},
    ["Swamp of Sorrows"] = {1435,1415},
    ["Westfall"] = {1436,1415},
    ["Wetlands"] = {1437,1415},
    ["Teldrassil"] = {1438,1414},
    ["Darkshore"] = {1439,1414},
    ["Ashenvale"] = {1440,1414},
    ["Thousand Needles"] = {1441,1414},
    ["Stonetalon Mountains"] = {1442,1414},
    ["Desolace"] = {1443,1414},
    ["Feralas"] = {1444,1414},
    ["Dustwallow Marsh"] = {1445,1414},
    ["Tanaris"] = {1446,1414},
    ["Azshara"] = {1447,1414},
    ["Felwood"] = {1448,1414},
    ["Un'Goro Crater"] = {1449,1414},
    ["Moonglade"] = {1450,1414},
    ["Silithus"] = {1451,1414},
    ["Winterspring"] = {1452,1414},
    ["Stormwind City"] = {1453,1415},
    ["Orgrimmar"] = {1454,1414},
    ["Ironforge"] = {1455,1415},
    ["Thunder Bluff"] = {1456,1414},
    ["Darnassus"] = {1457,1414},
    ["Undercity"] = {1458,1415},
    ["Alterac Valley"] = {1459,947},
    ["Warsong Gulch"] = {1460,947},
    ["Arathi Basin"] = {1461,947},
    --["Eastern Kingdoms"] = {1463,0},
    --["Kalimdor"] = {1464,0}
}


local zoneDataClassic = { --AreaTable IDs --Aka AreaID
    [1] = 'Dun Morogh',
    [3] = 'Badlands',
    [4] = 'Blasted Lands',
    [8] = 'Swamp of Sorrows',
    [10] = 'Duskwood',
    [11] = 'Wetlands',
    [12] = 'Elwynn Forest',
    [14] = 'Durotar',
    [15] = 'Dustwallow Marsh',
    [16] = 'Azshara',
    [17] = 'The Barrens',
    [28] = 'Western Plaguelands',
    [33] = 'Stranglethorn Vale',
    [36] = 'Alterac Mountains',
    [38] = 'Loch Modan',
    [40] = 'Westfall',
    [41] = 'Deadwind Pass',
    [44] = 'Redridge Mountains',
    [45] = 'Arathi Highlands',
    [46] = 'Burning Steppes',
    [47] = 'The Hinterlands',
    [51] = 'Searing Gorge',
    [85] = 'Tirisfal Glades',
    [130] = 'Silverpine Forest',
    [139] = 'Eastern Plaguelands',
    [141] = 'Teldrassil',
    [148] = 'Darkshore',
    [209] = 'Shadowfang Keep',
    [215] = 'Mulgore',
    [267] = 'Hillsbrad Foothills',
    [331] = 'Ashenvale',
    [357] = 'Feralas',
    [361] = 'Felwood',
    [400] = 'Thousand Needles',
    [405] = 'Desolace',
    [406] = 'Stonetalon Mountains',
    [440] = 'Tanaris',
    [490] = 'Un\'Goro Crater',
    [491] = 'Razorfen Kraul',
    [493] = 'Moonglade',
    [618] = 'Winterspring',
    [717] = 'The Stockade',
    [718] = 'Wailing Caverns',
    [719] = 'Blackfathom Deeps',
    [721] = 'Gnomeregan',
    [722] = 'Razorfen Downs',
    [796] = 'Scarlet Monastery',
    [1176] = 'Zul\'Farrak',
    [1337] = 'Uldaman',
    [1377] = 'Silithus',
    [1417] = 'The Temple of Atal\'Hakkar',
    [1477] = 'The Temple of Atal\'Hakkar',
    [1497] = 'Undercity',
    [1519] = 'Stormwind City',
    [1537] = 'Ironforge',
    [1581] = 'The Deadmines',
    [1583] = 'Lower Blackrock Spire',
    [1584] = 'Blackrock Depths',
    [1585] = 'Blackrock Depths',
    [1637] = 'Orgrimmar',
    [1638] = 'Thunder Bluff',
    [1657] = 'Darnassus',
    [1977] = 'Zul\'Gurub',
    [2017] = 'Stratholme',
    [2057] = 'Scholomance',
    [2100] = 'Maraudon',
    [2159] = 'Onyxia\'s Lair',
    [2257] = 'Deeprun Tram',
    [2437] = 'Ragefire Chasm',
    [2557] = 'Dire Maul',
    [2597] = 'Alterac Valley',
    [2677] = 'Blackwing Lair',
    [2717] = 'Molten Core',
    [2917] = 'Hall of Legends',
    [2918] = 'Champions\' Hall',
    [3277] = 'Warsong Gulch',
    [3358] = 'Arathi Basin',
    [3428] = 'Ahn\'Qiraj',
    [3429] = 'Ruins of Ahn\'Qiraj',
    [3456] = 'Naxxramas',
    [7307] = 'Upper Blacrock Spire',
}

-- [AreaID] = {"name", alternative AreaId (a sub zone)}
local dungeons = {
    [209] = {"Shadowfang Keep", 236},
    [491] = {"Razorfen Kraul", 1717},
    [717] = {"The Stockades", nil},
    [718] = {"Wailing Caverns", nil},
    [719] = {"Blackfathom Deeps", 2797},
    [721] = {"Gnomeregan", 133},
    [722] = {"Razorfen Downs", 1316},
    [796] = {"Scarlet Monastery", nil},
    [1176] = {"Zul'Farrak", 978},
    [1337] = {"Uldaman", 1517},
    [1477] = {"The Temple of Atal'Hakkar", nil},
    [1581] = {"The Deadmines", nil},
    [1583] = {"Blackrock Spire", nil},
    [1584] = {"Blackrock Depths", nil},
    [2017] = {"Stratholme", 2279},
    [2057] = {"Scholomance", nil},
    [2100] = {"Maraudon", nil},
    [2437] = {"Ragefire Chasm", nil},
    [2557] = {"Dire Maul", 2577},
}

function QuestieDBZone:GetDungeonAlternative(areaId)
    local entry = dungeons[areaId]
    if entry then
        return entry[2]
    end

    return nil
end


--Exported IDs from Classic DEMO
local zoneDataClassicDemo = {--AreaName, Continent, AreaID, mapID (Yes it is actually misspelled in the datafiles...)
    {"Durotar", 1,14,4},
    {"Mulgore", 1,215,9},
    {"Barrens", 1,17,11},
    {"Kalimdor", 1,0,13},
    {"Azeroth", 0,0,14},
    {"Alterac", 0,36,15},
    {"Arathi", 0,45,16},
    {"Badlands", 0,3,17},
    {"BlastedLands", 0,4,19},
    {"Tirisfal", 0,85,20},
    {"Silverpine", 0,130,21},
    {"WesternPlaguelands", 0,28,22},
    {"EasternPlaguelands", 0,139,23},
    {"Hilsbrad", 0,267,24},
    {"Hinterlands", 0,47,26},
    {"DunMorogh", 0,1,27},
    {"SearingGorge", 0,51,28},
    {"BurningSteppes", 0,46,29},
    {"Elwynn", 0,12,30},
    {"DeadwindPass", 0,41,32},
    {"Duskwood", 0,10,34},
    {"LochModan", 0,38,35},
    {"Redridge", 0,44,36},
    {"Stranglethorn", 0,33,37},
    {"SwampOfSorrows", 0,8,38},
    {"Westfall", 0,40,39},
    {"Wetlands", 0,11,40},
    {"Teldrassil", 1,141,41},
    {"Darkshore", 1,148,42},
    {"Ashenvale", 1,331,43},
    {"ThousandNeedles", 1,400,61},
    {"StonetalonMountains", 1,406,81},
    {"Desolace", 1,405,101},
    {"Feralas", 1,357,121},
    {"Dustwallow", 1,15,141},
    {"Tanaris", 1,440,161},
    {"Aszhara", 1,16,181},
    {"Felwood", 1,361,182},
    {"UngoroCrater", 1,490,201},
    {"Moonglade", 1,493,241},
    {"Silithus", 1,1377,261},
    {"Winterspring", 1,618,281},
    {"Stormwind", 0,1519,301},
    {"Ogrimmar", 1,1637,321},
    {"Ironforge", 0,1537,341},
    {"ThunderBluff", 1,1638,362},
    {"Darnassis", 1,1657,381},
    {"Undercity", 0,1497,382},
    {"AlteracValley", 30,2597,401},
    {"WarsongGulch", 489,3277,443},
    {"ArathiBasin", 529,3358,461}
}

Questie2ZoneTable = {
    ["WorldMap"] = {1337, 1337, 0, 08}, --
    ["Azeroth"] = {-1, -1, -1, 2, 0}, --
    ["Kalimdor"] = {-1, -1, -1, 1, 0}, --
    ["The Hinterlands"] = {42, 2, 24, 2, 20}, -- -- I found the code questhelper used, didnt do enough searching D:
    ["Moonglade"] = {20, 1, 12, 1, 10}, --
    ["Thousand Needles"] = {14, 1, 21, 1, 18}, --
    ["Winterspring"] = {19, 1, 24, 1, 21}, --
    ["Bloodmyst Isle"] = {9, 1, 4, -1, -1},--
    ["Terokkar Forest"] = {55, 3, 7, -1, -1},--
    ["Arathi Highlands"] = {39, 2, 2, 2, 2},--
    ["Eversong Woods"] = {41, 2, 11, -1, -1}, --
    ["Dustwallow Marsh"] = {10, 1, 9, 1, 7},--
    ["Badlands"] = {27, 2, 3, 2, 3}, --
    ["Darkshore"] = {16, 1, 5, 1, 3},--
    ["Orgrimmar"] = {1, 1, 14, 1, 12},--
    ["Blades Edge Mountains"] = {54, 3, 1, -1, -1},
    ["Undercity"] = {45, 2, 26, 2, 22},
    ["Desolace"] = {4, 1, 7, 1, 5},
    ["Netherstorm"] = {59, 3, 4, -1, -1},
    ["Barrens"] = {11, 1, 19, 1, 17},
    ["Tanaris"] = {8, 1, 17, 1, 15},
    ["Stormwind"] = {36, 2, 21, 2, 17},--
    ["Zangarmarsh"] = {57, 3, 8, -1, -1},
    ["Durotar"] = {7, 1, 8, 1, 6},--
    ["Hellfire"] = {56, 3, 2, -1, -1},
    ["Silithus"] = {5, 1, 15, 1, 13},
    ["Shattrath City"] = {60, 3, 6, -1, -1},
    ["Shadowmoon Valley"] = {53, 3, 5, -1, -1},
    ["Swamp of Sorrows"] = {46, 2, 23, 2, 19},
    ["Silvermoon City"] = {52, 2, 19, -1, -1},
    ["Darnassus"] = {21, 1, 6, 1, 4},
    ["Azuremyst Isle"] = {3, 1, 3, -1, -1},
    ["Elwynn Forest"] = {37, 2, 10, 2, 10},--
    ["Stranglethorn Vale"] = {38, 2, 22, 2, 18},
    ["Eastern Plaguelands"] = {34, 2, 9, 2, 9},
    ["Duskwood"] = {31, 2, 8, 2, 8},
    ["Western Plaguelands"] = {50, 2, 27, 2, 23},
    ["Westfall"] = {49, 2, 28, 2, 24},
    ["Ashenvale"] = {2, 1, 1, 1, 1},
    ["Teldrassil"] = {24, 1, 18, 1, 16},
    ["Redridge Mountains"] = {30, 2, 17, 2, 14},
    ["Un\'Goro Crater"] = {18, 1, 23, 1, 20},
    ["Mulgore"] = {22, 1, 13, 1, 11},
    ["Ironforge"] = {25, 2, 14, 2, 12},
    ["Felwood"] = {13, 1, 10, 1, 8},
    ["Hillsbrad Foothills"] = {48, 2, 13, 2, 11},
    ["Deadwind Pass"] = {47, 2, 6, 2, 6},
    ["Burning Steppes"] = {40, 2, 5, 2, 5},
    ["Ghostlands"] = {44, 2, 12, -1, -1},
    ["Tirisfal Glades"] = {43, 2, 25, 2, 21},
    ["The Exodar"] = {12, 1, 20, -1, -1},
    ["Wetlands"] = {51, 2, 29, 2, 25},
    ["Searing Gorge"] = {32, 2, 18, 2, 15},
    ["Blasted Lands"] = {33, 2, 4, 2, 4},
    ["Silverpine Forest"] = {35, 2, 20, 2, 16},
    ["Loch Modan"] = {29, 2, 16, 2, 13},
    ["Feralas"] = {17, 1, 11, 1, 9},
    ["Dun Morogh"] = {28, 2, 7, 2, 7},
    ["Alterac Mountains"] = {26, 2, 1, 2, 1},
    ["Thunder Bluff"] = {23, 1, 22, 1, 19},
    ["Aszhara"] = {15, 1, 2, 1, 2},
    ["Stonetalon Mountains"] = {6, 1, 16, 1, 14},
    ["Nagrand"] = {58, 3, 3, -1, -1},
    ["Kalimdor"] = {61, 1, 0, 1, 0},
    ["Azeroth"] = {62, 2, 0, 2, 0},
    ["Expansion01"] = {63, 3, 0, -1, -1},
    ["Sunwell"] = {64, 2, 15, -1, -1} -- code copied from questhelper (this is actually the only code that was directly copied, the database was put through JavaRefactorProject
}

Questie2ZoneTableInverse = {};
QuestieZoneToParentTable = {}; -- is there an api function we can use for this?

for _,v in pairs(zoneDataClassicBetaHack) do
    QuestieZoneToParentTable[v[1]] = v[2]
end

-- fix cities
QuestieZoneToParentTable[zoneDataClassicBetaHack["Thunder Bluff"][1]] = zoneDataClassicBetaHack["Mulgore"][1]
QuestieZoneToParentTable[zoneDataClassicBetaHack["Undercity"][1]] = zoneDataClassicBetaHack["Tirisfal Glades"][1]
QuestieZoneToParentTable[zoneDataClassicBetaHack["Orgrimmar"][1]] = zoneDataClassicBetaHack["Durotar"][1]

QuestieZoneToParentTable[zoneDataClassicBetaHack["Stormwind City"][1]] = zoneDataClassicBetaHack["Elwynn Forest"][1]
QuestieZoneToParentTable[zoneDataClassicBetaHack["Ironforge"][1]] = zoneDataClassicBetaHack["Dun Morogh"][1]
QuestieZoneToParentTable[zoneDataClassicBetaHack["Darnassus"][1]] = zoneDataClassicBetaHack["Teldrassil"][1]


for k,v in pairs(Questie2ZoneTable) do

  if zoneLookupHack[k] then
    Questie2ZoneTableInverse[v[1]] = zoneLookupHack[k];
  else
    Questie2ZoneTableInverse[v[1]] = k;
  end
  Questie2ZoneTableInverse[v[1]] = zoneDataClassicBetaHack[Questie2ZoneTableInverse[v[1]]]
  if Questie2ZoneTableInverse[v[1]] == nil then
    -- probably a tbc zone
  else
    Questie2ZoneTableInverse[v[1]] = Questie2ZoneTableInverse[v[1]][1];
  end
end

local zoneLevelList = {{1, 1, 10},
                 {3, 35, 45},
                 {4, 45, 55},
                 {8, 35, 45},
                 {10, 18, 30},
                 {11, 20, 30},
                 {12, 1, 10},
                 {14, 1, 10},
                 {15, 35, 45},
                 {16, 45, 55},
                 {17, 10, 25},
                 {28, 51, 58},
                 {33, 30, 45},
                 {36, 30, 40},
                 {38, 10, 20},
                 {40, 10, 20},
                 {41, 55, 60},
                 {44, 15, 25},
                 {45, 30, 40},
                 {46, 50, 58},
                 {47, 40, 50},
                 {51, 45, 50},
                 {85, 1, 10},
                 {130, 10, 20},
                 {139, 53, 60},
                 {141, 1, 10},
                 {148, 10, 20},
                 {215, 1, 10},
                 {267, 20, 30},
                 {331, 18, 30},
                 {357, 40, 50},
                 {361, 48, 55},
                 {400, 25, 35},
                 {405, 30, 40},
                 {406, 15, 27},
                 {440, 40, 50},
                 {490, 48, 55},
                 {493, 55, 60},
                 {618, 53, 60},
                 {1377, 55, 60},
                 {1497, 1, 60},
                 {1519, 1, 60},
                 {1537, 1, 60},
                 {1637, 1, 60},
                 {1638, 1, 60},
                 {1657, 1, 60}}

--Locations for instances in the world.
instanceData = {
    [209] = {{130, 45, 68.7}},
    [491] = {{17, 42.3, 89.9}},
    [717] = {{1519, 40.5, 55.9}},
    [718] = {{17, 46, 36.5}},
    [719] = {{331, 14.1, 14.4}},
    [721] = {{1, 24.4, 39.8}},
    [722] = {{17, 50.8, 92.8}},
    [796] = {{85, 83, 34}},
    [1176] = {{440, 38.7, 20.1}},
    [1337] = {{3, 44.4, 12.2}, {3, 65.2, 43.5}},
    [1417] = {{8, 69.4, 56.8}},
    [1477] = {{8, 69.4, 56.8}},
    [1581] = {{40, 42.5, 71.1}},
    [1583] = {{51, 34.8, 84.8}, {46, 31.7, 50.4}},
    [1584] = {{51, 34.8, 84.8}, {46, 31.7, 50.4}},
    [1585] = {{51, 34.8, 84.8}, {46, 31.7, 50.4}},
    [1977] = {{33, 50.6, 17.6}},
    [2017] = {{139, 30.9, 17}},
    [2057] = {{28, 69.8, 73.6}},
    [2100] = {{405, 29.5, 62.5}},
    [2159] = {{15, 52.4, 76.4}},
    [2257] = {{1519, 60.3, 12.5}, {1537, 72.8, 50.3}},
    [2437] = {{1637, 51.7, 49.8}},
    [2557] = {{357, 59.2, 45.1}},
    [2677] = {{51, 34.8, 84.8}, {46, 31.7, 50.4}},
    [2717] = {{51, 34.8, 84.8}, {46, 31.7, 50.4}},
    [2917] = {{1637, 40.4, 68.3}},
    [2918] = {{1519, 72.7, 54}},
    [3428] = {{1377, 29, 95}},
    [3429] = {{1377, 29, 95}},
    [3456] = {{139, 39.9, 25.8}},
    [7307] = {{51, 34.8, 84.8}, {46, 31.7, 50.4}},
}



function QuestieDBZone:ZoneCreateConversion()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieDBZone] Converting ZoneIds")
    for index, Data in ipairs(zoneDataClassicDemo) do
        local buildNr = select(4, GetBuildInfo())
        local UiMapID = nil
        if(buildNr > 80000) then
            UiMapID = HBDMigrate:GetUIMapIDFromMapAreaId(Data[4])
        else
            local zn = Data[1];
            if zoneLookupHack[zn] then
                zn = zoneLookupHack[zn];
            end
            UiMapID = zoneDataClassicBetaHack[zn];
            if UiMapID == nil then
                DEFAULT_CHAT_FRAME:AddMessage("Data not found for " .. zn);--Questie:Error("Data not found for" , zn);
            else
                UiMapID = UiMapID[1]
            end
        end

        if(UiMapID == nil) then
            Questie:Debug(DEBUG_CRITICAL, "Map convertion failed! : ", "DataName("..tostring(Data[1])..")","UiMapID("..tostring(UiMapID)..")", "AreaID("..tostring(Data[3])..")", "MapID("..tostring(Data[4])..")")
        elseif(UiMapID ~= nil) then
            zoneDataAreaIDToMapID[Data[3]] = Data[4]
            ZoneDataAreaIDToUiMapID[Data[3]] = UiMapID
            uiMapIDToAreaID[UiMapID] = Data[3]
            --Questie:Debug(DEBUG_SPAM, "[QuestieDBZone]", Data[1], Data[3], Data[4], UiMapID)
        end
    end
end


--Everything below is probably junk! But keep it for the time being.


--[[
zoneDataRetailToClassic = { } --Get generated [Retail] = Classic
zoneDataClassicToRetail = { } --Get generated [Classic] = Retail

--Got it from https://wow.gamepedia.com/UiMapID use excel to sort.

zoneDataRetail = { --Name, Type (Zone, Dungeon, Orphan, Micro), Parent
    [1] = {"Durotar", "Zone", "Kalimdor"},
    [7] = {"Mulgore", "Zone", "Kalimdor"},
    [10] = {"Northern Barrens", "Zone", "Kalimdor"},
    [12] = {"Kalimdor", "Continent", "Azeroth"},
    [13] = {"Eastern Kingdoms", "Continent", "Azeroth"},
    [14] = {"Arathi Highlands", "Zone", "Eastern Kingdoms"},
    [15] = {"Badlands", "Zone", "Eastern Kingdoms"},
    [17] = {"Blasted Lands", "Zone", "Eastern Kingdoms"},
    [18] = {"Tirisfal Glades", "Zone", "Eastern Kingdoms"},
    [21] = {"Silverpine Forest", "Zone", "Eastern Kingdoms"},
    [22] = {"Western Plaguelands", "Zone", "Eastern Kingdoms"},
    [23] = {"Eastern Plaguelands", "Zone", "Eastern Kingdoms"},
    [25] = {"Hillsbrad Foothills", "Zone", "Eastern Kingdoms"},
    [26] = {"The Hinterlands", "Zone", "Eastern Kingdoms"},
    [27] = {"Dun Morogh", "Zone", "Eastern Kingdoms"},
    [32] = {"Searing Gorge", "Zone", "Eastern Kingdoms"},
    [36] = {"Burning Steppes", "Zone", "Eastern Kingdoms"},
    [37] = {"Elwynn Forest", "Zone", "Eastern Kingdoms"},
    [42] = {"Deadwind Pass", "Zone", "Eastern Kingdoms"},
    [47] = {"Duskwood", "Zone", "Eastern Kingdoms"},
    [48] = {"Loch Modan", "Zone", "Eastern Kingdoms"},
    [49] = {"Redridge Mountains", "Zone", "Eastern Kingdoms"},
    [51] = {"Swamp of Sorrows", "Zone", "Eastern Kingdoms"},
    [52] = {"Westfall", "Zone", "Eastern Kingdoms"},
    [56] = {"Wetlands", "Zone", "Eastern Kingdoms"},
    [57] = {"Teldrassil", "Zone", "Kalimdor"},
    [62] = {"Darkshore", "Zone", "Kalimdor"},
    [63] = {"Ashenvale", "Zone", "Kalimdor"},
    [64] = {"Thousand Needles", "Zone", "Kalimdor"},
    [65] = {"Stonetalon Mountains", "Zone", "Kalimdor"},
    [66] = {"Desolace", "Zone", "Kalimdor"},
    [69] = {"Feralas", "Zone", "Kalimdor"},
    [70] = {"Dustwallow Marsh", "Zone", "Kalimdor"},
    [71] = {"Tanaris", "Zone", "Kalimdor"},
    [76] = {"Azshara", "Zone", "Kalimdor"},
    [77] = {"Felwood", "Zone", "Kalimdor"},
    [78] = {"Un'Goro Crater", "Zone", "Kalimdor"},
    [80] = {"Moonglade", "Zone", "Kalimdor"},
    [81] = {"Silithus", "Zone", "Kalimdor"},
    [83] = {"Winterspring", "Zone", "Kalimdor"},
    [84] = {"Stormwind City", "Zone", "Eastern Kingdoms"},
    [87] = {"Ironforge", "Zone", "Eastern Kingdoms"},
    [88] = {"Thunder Bluff", "Zone", "Kalimdor"},
    [89] = {"Darnassus", "Zone", "Kalimdor"},
    [90] = {"Undercity", "Zone", "Eastern Kingdoms"},
    [94] = {"Eversong Woods", "Zone", "Eastern Kingdoms"},
    [95] = {"Ghostlands", "Zone", "Eastern Kingdoms"},
    [97] = {"Azuremyst Isle", "Zone", "Kalimdor"},
    [103] = {"The Exodar", "Zone", "Kalimdor"},
    [106] = {"Bloodmyst Isle", "Zone", "Kalimdor"},
    [110] = {"Silvermoon City", "Zone", "Eastern Kingdoms"},
    [113] = {"Northrend", "Continent", "Azeroth"},
    [122] = {"Isle of Quel'Danas", "Zone", "Eastern Kingdoms"},
    [179] = {"Gilneas", "Zone", "Eastern Kingdoms"},
    [198] = {"Mount Hyjal", "Zone", "Kalimdor"},
    [199] = {"Southern Barrens", "Zone", "Kalimdor"},
    [203] = {"Vashj'ir", "Zone", "Eastern Kingdoms"},
    [217] = {"Ruins of Gilneas", "Zone", "Eastern Kingdoms"},
    [224] = {"Stranglethorn Vale", "Zone", "Eastern Kingdoms"},
    [241] = {"Twilight Highlands", "Zone", "Eastern Kingdoms"},
    [244] = {"Tol Barad", "Zone", "Eastern Kingdoms"},
    [245] = {"Tol Barad Peninsula", "Zone", "Eastern Kingdoms"},
    [249] = {"Uldum", "Zone", "Kalimdor"},
    [424] = {"Pandaria", "Continent", "Azeroth"},
    [619] = {"Broken Isles", "Continent", "Azeroth"},
    [775] = {"The Exodar", "Zone", "Kalimdor"},
    [875] = {"Zandalar", "Continent", "Azeroth"},
    [876] = {"Kul Tiras", "Continent", "Azeroth"},
    [948] = {"The Maelstrom", "Continent", "Azeroth"},
    [218] = {"Ruins of Gilneas City", "Orphan", "Eastern Kingdoms"},
    [327] = {"Ahn'Qiraj: The Fallen Kingdom", "Orphan", "Kalimdor"},
    [378] = {"The Wandering Isle", "Orphan", "Azeroth"},
    [407] = {"Darkmoon Island", "Orphan", "Azeroth"},
    [524] = {"Battle on the High Seas", "Orphan", "Kalimdor"},
    [773] = {"Tol Barad", "Orphan", "Eastern Kingdoms"},
    [776] = {"Azuremyst Isle", "Orphan", "Kalimdor"},
    [824] = {"Islands", "Orphan", "Azeroth"},
    [906] = {"Arathi Highlands", "Orphan", "Eastern Kingdoms"},
    [907] = {"Seething Shore", "Orphan", "Kalimdor"},
    [908] = {"Ruins of Lordaeron", "Orphan", "Eastern Kingdoms"},
    [938] = {"Gilneas Island", "Orphan", "Azeroth"},
    [939] = {"Tropical Isle 8.0", "Orphan", "Azeroth"},
    [943] = {"Arathi Highlands", "Orphan", "Eastern Kingdoms"},
    [981] = {"Un'gol Ruins", "Orphan", "Azeroth"},
    [1012] = {"Stormwind City", "Orphan", "Eastern Kingdoms"},
    [1013] = {"The Stockade", "Orphan", "Eastern Kingdoms"},
    [1044] = {"Arathi Highlands", "Orphan", "Eastern Kingdoms"},
    [1156] = {"The Great Sea", "Orphan", "Azeroth"},
    [1157] = {"The Great Sea", "Orphan", "Azeroth"}
}






Map = {} --Retail, TODO this needs to be replaced with correct maps for classic, such as the MapID for "The Barrens" for example, currently only use unmodified zones.
Map[0] = {}
Map[1] = {}
--Eastern Kindoms
    Map[0][14] = "Eastern Kingdoms"
    Map[0][614] = "Abyssal Depths"
    Map[0][16] = "Arathi Highlands"
    Map[0][17] = "Badlands"
    Map[0][19] = "Blasted Lands"
    Map[0][29] = "Burning Steppes"
    Map[0][866] = "Coldridge Valley"
    Map[0][32] = "Deadwind Pass"
    Map[0][892] = "Deathknell"
    Map[0][27] = "Dun Morogh"
    Map[0][34] = "Duskwood"
    Map[0][23] = "Eastern Plaguelands"
    Map[0][30] = "Elwynn Forest"
    Map[0][462] = "Eversong Woods"
    Map[0][463] = "Ghostlands"
    Map[0][545] = "Gilneas"
    Map[0][611] = "Gilneas City"
    Map[0][24] = "Hillsbrad Foothills"
    Map[0][341] = "Ironforge"
    Map[0][499] = "Isle of Quel'Danas"
    Map[0][610] = "Kelp'thar Forest"
    Map[0][35] = "Loch Modan"
    Map[0][895] = "New Tinkertown"
    Map[0][37] = "Northern Stranglethorn"
    Map[0][864] = "Northshire"
    Map[0][36] = "Redridge Mountains"
    Map[0][684] = "Ruins of Gilneas"
    Map[0][685] = "Ruins of Gilneas City"
    Map[0][28] = "Searing Gorge"
    Map[0][615] = "Shimmering Expanse"
    Map[0][480] = "Silvermoon City"
    Map[0][21] = "Silverpine Forest"
    Map[0][301] = "Stormwind City"
    Map[0][689] = "Stranglethorn Vale"
    Map[0][893] = "Sunstrider Isle"
    Map[0][38] = "Swamp of Sorrows"
    Map[0][673] = "The Cape of Stranglethorn"
    Map[0][26] = "The Hinterlands"
    Map[0][502] = "The Scarlet Enclave"
    Map[0][20] = "Tirisfal Glades"
    Map[0][708] = "Tol Barad"
    Map[0][709] = "Tol Barad Peninsula"
    Map[0][700] = "Twilight Highlands"
    Map[0][382] = "Undercity"
    Map[0][613] = "Vashj'ir"
    Map[0][22] = "Western Plaguelands"
    Map[0][39] = "Westfall"
    Map[0][40] = "Wetlands"

--Kalimdor
    Map[1][13] = "Kalimdor"
    Map[1][772] = "Ahn'Qiraj: The Fallen Kingdom"
    Map[1][894] = "Ammen Vale"
    Map[1][43] = "Ashenvale"
    Map[1][181] = "Azshara"
    Map[1][464] = "Azuremyst Isle"
    Map[1][476] = "Bloodmyst Isle"
    Map[1][890] = "Camp Narache"
    Map[1][42] = "Darkshore"
    Map[1][381] = "Darnassus"
    Map[1][101] = "Desolace"
    Map[1][4] = "Durotar"
    Map[1][141] = "Dustwallow Marsh"
    Map[1][891] = "Echo Isles"
    Map[1][182] = "Felwood"
    Map[1][121] = "Feralas"
    Map[1][795] = "Molten Front"
    Map[1][241] = "Moonglade"
    Map[1][606] = "Mount Hyjal"
    Map[1][9] = "Mulgore"
    Map[1][11] = "Northern Barrens"
    Map[1][321] = "Orgrimmar"
    Map[1][888] = "Shadowglen"
    Map[1][261] = "Silithus"
    Map[1][607] = "Southern Barrens"
    Map[1][81] = "Stonetalon Mountains"
    Map[1][161] = "Tanaris"
    Map[1][41] = "Teldrassil"
    Map[1][471] = "The Exodar"
    Map[1][61] = "Thousand Needles"
    Map[1][362] = "Thunder Bluff"
    Map[1][720] = "Uldum"
    Map[1][201] = "Un\'Goro Crater"
    Map[1][889] = "Valley of Trials"
    Map[1][281] = "Winterspring"

--Old Questie data (Vanilla map ids)
QuestieZones = {
    ["WorldMap"] = {1337, 1337, 0, 08}, --
    ["Azeroth"] = {-1, -1, -1, 2, 0}, --
    ["Kalimdor"] = {-1, -1, -1, 1, 0}, --
    ["The Hinterlands"] = {42, 2, 24, 2, 20}, -- -- I found the code questhelper used, didnt do enough searching D:
    ["Moonglade"] = {20, 1, 12, 1, 10}, --
    ["Thousand Needles"] = {14, 1, 21, 1, 18}, --
    ["Winterspring"] = {19, 1, 24, 1, 21}, --
    ["Bloodmyst Isle"] = {9, 1, 4, -1, -1},--
    ["Terokkar Forest"] = {55, 3, 7, -1, -1},--
    ["Arathi Highlands"] = {39, 2, 2, 2, 2},--
    ["Eversong Woods"] = {41, 2, 11, -1, -1}, --
    ["Dustwallow Marsh"] = {10, 1, 9, 1, 7},--
    ["Badlands"] = {27, 2, 3, 2, 3}, --
    ["Darkshore"] = {16, 1, 5, 1, 3},--
    ["Orgrimmar"] = {1, 1, 14, 1, 12},--
    ["Blades Edge Mountains"] = {54, 3, 1, -1, -1},
    ["Undercity"] = {45, 2, 26, 2, 22},
    ["Desolace"] = {4, 1, 7, 1, 5},
    ["Netherstorm"] = {59, 3, 4, -1, -1},
    ["Barrens"] = {11, 1, 19, 1, 17},
    ["Tanaris"] = {8, 1, 17, 1, 15},
    ["Stormwind"] = {36, 2, 21, 2, 17},--
    ["Zangarmarsh"] = {57, 3, 8, -1, -1},
    ["Durotar"] = {7, 1, 8, 1, 6},--
    ["Hellfire"] = {56, 3, 2, -1, -1},
    ["Silithus"] = {5, 1, 15, 1, 13},
    ["Shattrath City"] = {60, 3, 6, -1, -1},
    ["Shadowmoon Valley"] = {53, 3, 5, -1, -1},
    ["Swamp of Sorrows"] = {46, 2, 23, 2, 19},
    ["Silvermoon City"] = {52, 2, 19, -1, -1},
    ["Darnassus"] = {21, 1, 6, 1, 4},
    ["Azuremyst Isle"] = {3, 1, 3, -1, -1},
    ["Elwynn Forest"] = {37, 2, 10, 2, 10},--
    ["Stranglethorn Vale"] = {38, 2, 22, 2, 18},
    ["Eastern Plaguelands"] = {34, 2, 9, 2, 9},
    ["Duskwood"] = {31, 2, 8, 2, 8},
    ["Western Plaguelands"] = {50, 2, 27, 2, 23},
    ["Westfall"] = {49, 2, 28, 2, 24},
    ["Ashenvale"] = {2, 1, 1, 1, 1},
    ["Teldrassil"] = {24, 1, 18, 1, 16},
    ["Redridge Mountains"] = {30, 2, 17, 2, 14},
    ["Un\'Goro Crater"] = {18, 1, 23, 1, 20},
    ["Mulgore"] = {22, 1, 13, 1, 11},
    ["Ironforge"] = {25, 2, 14, 2, 12},
    ["Felwood"] = {13, 1, 10, 1, 8},
    ["Hillsbrad Foothills"] = {48, 2, 13, 2, 11},
    ["Deadwind Pass"] = {47, 2, 6, 2, 6},
    ["Burning Steppes"] = {40, 2, 5, 2, 5},
    ["Ghostlands"] = {44, 2, 12, -1, -1},
    ["Tirisfal Glades"] = {43, 2, 25, 2, 21},
    ["The Exodar"] = {12, 1, 20, -1, -1},
    ["Wetlands"] = {51, 2, 29, 2, 25},
    ["Searing Gorge"] = {32, 2, 18, 2, 15},
    ["Blasted Lands"] = {33, 2, 4, 2, 4},
    ["Silverpine Forest"] = {35, 2, 20, 2, 16},
    ["Loch Modan"] = {29, 2, 16, 2, 13},
    ["Feralas"] = {17, 1, 11, 1, 9},
    ["Dun Morogh"] = {28, 2, 7, 2, 7},
    ["Alterac Mountains"] = {26, 2, 1, 2, 1},
    ["Thunder Bluff"] = {23, 1, 22, 1, 19},
    ["Aszhara"] = {15, 1, 2, 1, 2},
    ["Stonetalon Mountains"] = {6, 1, 16, 1, 14},
    ["Nagrand"] = {58, 3, 3, -1, -1},
    ["Kalimdor"] = {61, 1, 0, 1, 0},
    ["Azeroth"] = {62, 2, 0, 2, 0},
    ["Expansion01"] = {63, 3, 0, -1, -1},
    ["Sunwell"] = {64, 2, 15, -1, -1} -- code copied from questhelper (this is actually the only code that was directly copied, the database was put through JavaRefactorProject
}
]]--
