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

-- Different source of zoneIds
-- These are not in use anymore but are quite helpful when fixing the database
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
