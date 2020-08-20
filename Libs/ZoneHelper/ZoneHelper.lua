-- ZoneHelper is taken from Butter Quest Tracker by Nick Woodward (a.k.a. Stormie25)
-- Licensed under the MIT License
-- https://github.com/butter-cookie-kitkat/ButterQuestTracker

local AceEvent = LibStub:GetLibrary("AceEvent-3.0");
local helper = LibStub:NewLibrary("ZoneHelper-1.0", 1);
if not helper then return end

local zoneIDToUiMapID = {};

local listeners = {};
local previousSubZone = GetMinimapZoneText();
local previousZone = GetRealZoneText();
local function updateListeners()
    local subZone = GetMinimapZoneText();
    local zone = GetRealZoneText();

    if previousSubZone == subZone and previousZone == zone then return end

    for _, listener in ipairs(listeners) do
        listener({
            previousSubZone = previousSubZone,
            previousZone = previousZone,
            subZone = subZone,
            zone = zone
        });
    end

    previousSubZone = subZone;
    previousZone = zone;
end

function helper:OnZoneChanged(listener)
    tinsert(listeners, listener);
end

-- TODO: Remove this code once Questie adds UiMapIDs to their objects. :(
function helper:GetUIMapID(zoneID)
    return zoneIDToUiMapID[zoneID];
end

AceEvent.RegisterEvent(helper, "ZONE_CHANGED", updateListeners);
AceEvent.RegisterEvent(helper, "ZONE_CHANGED_INDOORS", updateListeners);
AceEvent.RegisterEvent(helper, "ZONE_CHANGED_NEW_AREA", updateListeners);

zoneIDToUiMapID = {
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
    [3358] = 1461
};
