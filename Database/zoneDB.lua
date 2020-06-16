---@class ZoneDB
local ZoneDB = QuestieLoader:CreateModule("ZoneDB")

--- forward declaration
local _GenerateUiMapIdToAreaIdTable, _GenerateParentZoneToStartingZoneTable

local areaIdToUiMapId = {}
local uiMapIdToAreaId = {} -- Generated

local dungeons = {}
local dungeonLocations = {}

local dungeonParentZones = {}
local subZoneToParentZone = {}
local parentZoneToSubZone = {} -- Generated


function ZoneDB:Initialize()
    _GenerateUiMapIdToAreaIdTable()
    _GenerateParentZoneToStartingZoneTable()
end

_GenerateUiMapIdToAreaIdTable = function ()
    for areaId, uiMapId in pairs(areaIdToUiMapId) do
        uiMapIdToAreaId[uiMapId] = areaId
    end
end

_GenerateParentZoneToStartingZoneTable = function ()
    for startingZone, parentZone in pairs(subZoneToParentZone) do
        parentZoneToSubZone[parentZone] = startingZone
    end
end

function ZoneDB:GetUiMapIdByAreaId(areaId)
    local uiMapId = 947 -- Default to Azeroth
    if areaIdToUiMapId[areaId] ~= nil then
        uiMapId = areaIdToUiMapId[areaId]
    end
    return uiMapId
end

function ZoneDB:GetAreaIdByUiMapId(uiMapId)
    local areaId = 1 -- Default to Dun Morogh
    if uiMapIdToAreaId[uiMapId] ~= nil then
        areaId = uiMapIdToAreaId[uiMapId]
    end
    return areaId
end

function ZoneDB:GetDungeonLocation(areaId)
    return dungeonLocations[areaId]
end

function ZoneDB:GetAlternativeZoneId(areaId)
    local entry = dungeons[areaId]
    if entry then
        return entry[2]
    end

    entry = parentZoneToSubZone[areaId]
    if entry then
        return entry
    end

    return nil
end

function ZoneDB:GetParentZoneId(areaId)
    local entry = dungeonParentZones[areaId]
    if entry then
        return entry
    end

    entry = subZoneToParentZone[areaId]
    if entry then
        return entry
    end

    return nil
end

--- This table maps the areaId (used in the DB for example) to
--- the UiMapId of each zone.
--- The UiMapId identifies a map which can be displayed ingame on the worldmap.
--- Dungeons don't have a UiMapId!
--- https://wow.gamepedia.com/UiMapID/Classic
areaIdToUiMapId = {
    [0] = 947,
    [1] = 1426,
    [3] = 1418,
    [4] = 1419,
    [8] = 1435,
    [10] = 1431,
    [11] = 1437,
    [12] = 1429,
    [14] = 1411,
    [15] = 1445,
    [16] = 1447,
    [17] = 1413,
    [28] = 1422,
    [33] = 1434,
    [36] = 1416,
    [38] = 1432,
    [40] = 1436,
    [41] = 1430,
    [44] = 1433,
    [45] = 1417,
    [46] = 1428,
    [47] = 1425,
    [51] = 1427,
    [85] = 1420,
    [130] = 1421,
    [139] = 1423,
    [141] = 1438,
    [148] = 1439,
    [215] = 1412,
    [267] = 1424,
    [331] = 1440,
    [357] = 1444,
    [361] = 1448,
    [400] = 1441,
    [405] = 1443,
    [406] = 1442,
    [440] = 1446,
    [490] = 1449,
    [493] = 1450,
    [618] = 1452,
    [1377] = 1451,
    [1497] = 1458,
    [1519] = 1453,
    [1537] = 1455,
    [1637] = 1454,
    [1638] = 1456,
    [1657] = 1457,
    [2597] = 1459,
    [3277] = 1460,
    [3358] = 1461,
}

-- [AreaID] = {"name", alternative AreaId (a sub zone), parentId}
dungeons = {
    [209] = {"Shadowfang Keep", 236, 130},
    [491] = {"Razorfen Kraul", 1717, 17},
    [717] = {"The Stockades", nil, 1519},
    [718] = {"Wailing Caverns", nil, 17},
    [719] = {"Blackfathom Deeps", 2797, 331},
    [721] = {"Gnomeregan", 133, 1},
    [722] = {"Razorfen Downs", 1316, 17},
    [796] = {"Scarlet Monastery", nil, 85},
    [1176] = {"Zul'Farrak", 978, 440},
    [1337] = {"Uldaman", 1517, 3},
    [1477] = {"The Temple of Atal'Hakkar", 1417, 8},
    [1581] = {"The Deadmines", nil, 40},
    [1583] = {"Blackrock Spire", nil, 51},
    [1584] = {"Blackrock Depths", nil, 51},
    [2017] = {"Stratholme", 2279, 139},
    [2057] = {"Scholomance", nil, 28},
    [2100] = {"Maraudon", nil, 405},
    [2437] = {"Ragefire Chasm", nil, 1637},
    [2557] = {"Dire Maul", 2577, 357},
}

dungeonLocations = {
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
    [1583] = {{51, 34.8, 84.8}, {46, 29.5, 38.2}},
    [1584] = {{51, 34.8, 84.8}, {46, 29.5, 38.2}},
    [1585] = {{51, 34.8, 84.8}, {46, 29.5, 38.2}},
    [1977] = {{33, 50.6, 17.6}},
    [2017] = {{139, 30.9, 17}},
    [2057] = {{28, 69.8, 73.6}},
    [2100] = {{405, 29.5, 62.5}},
    [2159] = {{15, 52.4, 76.4}},
    [2257] = {{1519, 60.3, 12.5}, {1537, 72.8, 50.3}},
    [2437] = {{1637, 51.7, 49.8}},
    [2557] = {{357, 59.2, 45.1}},
    [2597] = {{36, 66.6, 51.3},},
    [2677] = {{51, 34.8, 84.8}, {46, 29.5, 38.2}},
    [2717] = {{51, 34.8, 84.8}, {46, 29.5, 38.2}},
    [2917] = {{1637, 40.4, 68.3}},
    [2918] = {{1519, 72.7, 54}},
    [3428] = {{1377, 29, 95}},
    [3429] = {{1377, 29, 95}},
    [3456] = {{139, 39.9, 25.8}},
    [7307] = {{51, 34.8, 84.8}, {46, 29.5, 38.2}},
}

dungeonParentZones = {
    [236] = 209,
    [1717] = 491,
    [2797] = 719,
    [133] = 721,
    [1316] = 722,
    [978] = 1176,
    [1517] = 1337,
    [1417] = 1477,
    [2279] = 2017,
    [2577] = 2557,
}

subZoneToParentZone = {
    [2839] = 2597,
    [35] = 33,
    [1116] = 357,
    [702] = 141,
    [1769] = 361,
    -- starting zones
    [9] = 12,
    [132] = 1,
    [154] = 85,
    [188] = 131,
    [220] = 215,
    [363] = 14,
}

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
}

-- Different source of zoneIds
-- https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-emulator-servers/60411-zone-ids.html
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
    [7307] = 'Upper Blackrock Spire',
}

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
