---@type QuestieFrameNew
local QuestieFrameNew = QuestieLoader:ImportModule("QuestieFrameNew");
QuestieFrameNew.utils = {}
--QuestieLoader:ImportModule("QuestieFrameNew").utils.zoneList
--QuestieLoader:ImportModule("QuestieFrameNew").utils:GenerateCloseZones()
QuestieFrameNew.utils.zoneList = {
  [1443] = {
    [1443] = true,
    [1412] = true,
    [1444] = true,
    [1413] = true,
    [1442] = true,
    [1456] = true,
    [1414] = true,
    [1464] = true,
  },
  [1447] = {
    [1464] = true,
    [1447] = true,
    [1454] = true,
    [1448] = true,
    [1452] = true,
    [1414] = true,
    [1439] = true,
    [1440] = true,
  },
  [1451] = {
    [1464] = true,
    [1451] = true,
    [1441] = true,
    [1414] = true,
    [1449] = true,
    [1446] = true,
    [1444] = true,
  },
  [1455] = {
    [1455] = true,
    [1426] = true,
    [1463] = true,
    [1437] = true,
  },
  [1459] = {
    [1459] = true,
  },
  [1463] = {
    [1417] = true,
    [1418] = true,
    [1419] = true,
    [1420] = true,
    [1421] = true,
    [1453] = true,
    [1423] = true,
    [1455] = true,
    [1425] = true,
    [1426] = true,
    [1458] = true,
    [1428] = true,
    [1429] = true,
    [1430] = true,
    [1431] = true,
    [1463] = true,
    [1433] = true,
    [1434] = true,
    [1435] = true,
    [1436] = true,
    [1437] = true,
    [1427] = true,
    [1424] = true,
    [1422] = true,
    [1415] = true,
    [1416] = true,
    [1432] = true,
  },
  [1412] = {
    [1456] = true,
    [1445] = true,
    [1464] = true,
    [1412] = true,
    [1413] = true,
    [1411] = true,
    [1442] = true,
    [1414] = true,
    [1443] = true,
    [1444] = true,
  },
  [1416] = {
    [1422] = true,
    [1415] = true,
    [1416] = true,
    [1420] = true,
    [1424] = true,
    [1458] = true,
    [1417] = true,
    [1421] = true,
    [1425] = true,
    [1463] = true,
  },
  [1420] = {
    [1422] = true,
    [1416] = true,
    [1420] = true,
    [1415] = true,
    [1421] = true,
    [1458] = true,
    [1463] = true,
  },
  [1424] = {
    [1416] = true,
    [1421] = true,
    [1424] = true,
    [1463] = true,
    [1425] = true,
    [1417] = true,
  },
  [1428] = {
    [1429] = true,
    [1433] = true,
    [1415] = true,
    [1427] = true,
    [1426] = true,
    [1463] = true,
    [1418] = true,
    [1428] = true,
  },
  [1432] = {
    [1426] = true,
    [1437] = true,
    [1427] = true,
    [1463] = true,
    [1418] = true,
    [1432] = true,
  },
  [1436] = {
    [1436] = true,
    [1434] = true,
    [1431] = true,
    [1463] = true,
    [1415] = true,
    [1429] = true,
  },
  [1440] = {
    [1452] = true,
    [1411] = true,
    [1464] = true,
    [1442] = true,
    [1454] = true,
    [1413] = true,
    [1447] = true,
    [1440] = true,
    [1414] = true,
    [1448] = true,
    [1439] = true,
  },
  [1444] = {
    [1441] = true,
    [1445] = true,
    [1464] = true,
    [1412] = true,
    [1446] = true,
    [1413] = true,
    [1451] = true,
    [1414] = true,
    [1444] = true,
    [1449] = true,
    [1443] = true,
  },
  [1448] = {
    [1464] = true,
    [1447] = true,
    [1450] = true,
    [1448] = true,
    [1452] = true,
    [1414] = true,
    [1439] = true,
    [1440] = true,
  },
  [1452] = {
    [1452] = true,
    [1464] = true,
    [1438] = true,
    [1450] = true,
    [1439] = true,
    [1447] = true,
    [1440] = true,
    [1414] = true,
    [1448] = true,
  },
  [1456] = {
    [1443] = true,
    [1456] = true,
    [1412] = true,
    [1413] = true,
  },
  [1460] = {
    [1460] = true,
  },
  [1464] = {
    [1448] = true,
    [1449] = true,
    [1450] = true,
    [1451] = true,
    [1452] = true,
    [1454] = true,
    [1456] = true,
    [1457] = true,
    [947] = true,
    [1464] = true,
    [1445] = true,
    [1411] = true,
    [1412] = true,
    [1438] = true,
    [1439] = true,
    [1440] = true,
    [1441] = true,
    [1442] = true,
    [1443] = true,
    [1413] = true,
    [1414] = true,
    [1446] = true,
    [1447] = true,
    [1444] = true,
  },
  [1413] = {
    [1456] = true,
    [1445] = true,
    [1464] = true,
    [1412] = true,
    [1411] = true,
    [1454] = true,
    [1413] = true,
    [1442] = true,
    [1414] = true,
    [1440] = true,
    [1444] = true,
    [1443] = true,
    [1441] = true,
  },
  [1417] = {
    [1415] = true,
    [1416] = true,
    [1437] = true,
    [1424] = true,
    [1463] = true,
    [1425] = true,
    [1417] = true,
  },
  [1421] = {
    [1422] = true,
    [1415] = true,
    [1416] = true,
    [1420] = true,
    [1424] = true,
    [1463] = true,
    [1458] = true,
    [1421] = true,
  },
  [1425] = {
    [1422] = true,
    [1423] = true,
    [1416] = true,
    [1415] = true,
    [1424] = true,
    [1463] = true,
    [1425] = true,
    [1417] = true,
  },
  [1429] = {
    [1415] = true,
    [1453] = true,
    [1431] = true,
    [1428] = true,
    [1436] = true,
    [1433] = true,
    [1429] = true,
    [1463] = true,
    [1430] = true,
  },
  [1433] = {
    [1429] = true,
    [1433] = true,
    [1430] = true,
    [1435] = true,
    [1431] = true,
    [1463] = true,
    [1415] = true,
    [1428] = true,
  },
  [1437] = {
    [1415] = true,
    [1426] = true,
    [1437] = true,
    [1455] = true,
    [1417] = true,
    [1463] = true,
    [1432] = true,
  },
  [1441] = {
    [1441] = true,
    [1445] = true,
    [1449] = true,
    [1446] = true,
    [1413] = true,
    [1451] = true,
    [1444] = true,
    [1464] = true,
    [1414] = true,
  },
  [1445] = {
    [1464] = true,
    [1412] = true,
    [1444] = true,
    [1413] = true,
    [1445] = true,
    [1414] = true,
    [1441] = true,
  },
  [1449] = {
    [1464] = true,
    [1451] = true,
    [1441] = true,
    [1414] = true,
    [1449] = true,
    [1446] = true,
    [1444] = true,
  },
  [1453] = {
    [1429] = true,
    [1453] = true,
  },
  [1457] = {
    [1457] = true,
    [1438] = true,
  },
  [1461] = {
    [1461] = true,
  },
  [1414] = {
    [1448] = true,
    [1449] = true,
    [1450] = true,
    [1451] = true,
    [1452] = true,
    [1454] = true,
    [1456] = true,
    [1457] = true,
    [947] = true,
    [1464] = true,
    [1445] = true,
    [1411] = true,
    [1412] = true,
    [1438] = true,
    [1439] = true,
    [1440] = true,
    [1441] = true,
    [1442] = true,
    [1443] = true,
    [1413] = true,
    [1414] = true,
    [1446] = true,
    [1447] = true,
    [1444] = true,
  },
  [1418] = {
    [1426] = true,
    [1427] = true,
    [1428] = true,
    [1463] = true,
    [1418] = true,
    [1432] = true,
  },
  [1422] = {
    [1422] = true,
    [1415] = true,
    [1423] = true,
    [1416] = true,
    [1420] = true,
    [1458] = true,
    [1421] = true,
    [1425] = true,
    [1463] = true,
  },
  [1426] = {
    [1437] = true,
    [1426] = true,
    [1415] = true,
    [1427] = true,
    [1428] = true,
    [1432] = true,
    [1455] = true,
    [1463] = true,
    [1418] = true,
  },
  [1430] = {
    [1429] = true,
    [1433] = true,
    [1430] = true,
    [1434] = true,
    [1431] = true,
    [1435] = true,
    [1419] = true,
    [1415] = true,
  },
  [1434] = {
    [1436] = true,
    [1419] = true,
    [1430] = true,
    [1434] = true,
    [1431] = true,
    [1463] = true,
    [1415] = true,
  },
  [1438] = {
    [1457] = true,
    [1452] = true,
    [1414] = true,
    [1438] = true,
    [1464] = true,
  },
  [1442] = {
    [1464] = true,
    [1440] = true,
    [1413] = true,
    [1442] = true,
    [1414] = true,
    [1443] = true,
    [1412] = true,
  },
  [1446] = {
    [1464] = true,
    [1451] = true,
    [1441] = true,
    [1414] = true,
    [1449] = true,
    [1446] = true,
    [1444] = true,
  },
  [1450] = {
    [1464] = true,
    [1448] = true,
    [1452] = true,
    [1439] = true,
    [1450] = true,
  },
  [1454] = {
    [1454] = true,
    [1413] = true,
    [1440] = true,
    [1411] = true,
    [1447] = true,
  },
  [1458] = {
    [1422] = true,
    [1416] = true,
    [1420] = true,
    [1421] = true,
    [1458] = true,
  },
  [1411] = {
    [1464] = true,
    [1412] = true,
    [1413] = true,
    [1454] = true,
    [1414] = true,
    [1411] = true,
    [1440] = true,
  },
  [1415] = {
    [1417] = true,
    [1418] = true,
    [1419] = true,
    [1420] = true,
    [1421] = true,
    [1453] = true,
    [1423] = true,
    [1455] = true,
    [1425] = true,
    [1426] = true,
    [1458] = true,
    [1428] = true,
    [1429] = true,
    [1430] = true,
    [1431] = true,
    [1463] = true,
    [1433] = true,
    [1434] = true,
    [1435] = true,
    [1436] = true,
    [1437] = true,
    [1427] = true,
    [1424] = true,
    [1422] = true,
    [1415] = true,
    [1416] = true,
    [1432] = true,
  },
  [1419] = {
    [1415] = true,
    [1419] = true,
    [1430] = true,
    [1434] = true,
    [1431] = true,
    [1463] = true,
    [1435] = true,
  },
  [1423] = {
    [1422] = true,
    [1423] = true,
    [1463] = true,
    [1425] = true,
    [1415] = true,
  },
  [1427] = {
    [1415] = true,
    [1426] = true,
    [1427] = true,
    [1428] = true,
    [1463] = true,
    [1418] = true,
    [1432] = true,
  },
  [1431] = {
    [1436] = true,
    [1433] = true,
    [1430] = true,
    [1434] = true,
    [1431] = true,
    [1419] = true,
    [1415] = true,
    [1429] = true,
  },
  [1435] = {
    [1419] = true,
    [1435] = true,
    [1430] = true,
    [1433] = true,
  },
  [1439] = {
    [1464] = true,
    [1447] = true,
    [1450] = true,
    [1448] = true,
    [1452] = true,
    [1414] = true,
    [1439] = true,
    [1440] = true,
  },
  [947] = {
    [1443] = true,
    [1447] = true,
    [1451] = true,
    [1455] = true,
    [1459] = true,
    [1463] = true,
    [1412] = true,
    [1416] = true,
    [1420] = true,
    [1424] = true,
    [1428] = true,
    [1432] = true,
    [1436] = true,
    [1440] = true,
    [1444] = true,
    [1448] = true,
    [1452] = true,
    [1456] = true,
    [1460] = true,
    [1464] = true,
    [1413] = true,
    [1417] = true,
    [1421] = true,
    [1425] = true,
    [1429] = true,
    [1433] = true,
    [1437] = true,
    [1441] = true,
    [1445] = true,
    [1449] = true,
    [1453] = true,
    [1457] = true,
    [1461] = true,
    [1414] = true,
    [1418] = true,
    [1422] = true,
    [1426] = true,
    [1430] = true,
    [1434] = true,
    [1438] = true,
    [1442] = true,
    [1446] = true,
    [1450] = true,
    [1454] = true,
    [1458] = true,
    [1411] = true,
    [1415] = true,
    [1419] = true,
    [1423] = true,
    [1427] = true,
    [1431] = true,
    [1435] = true,
    [1439] = true,
    [947] = true,
  },
}

local HBD = LibStub("HereBeDragonsQuestie-2.0")
--[[
non functioning... i suck at trigometry
local function calculateClosestCoords(oUIMapId, dUIMapId)
  local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(0.5, 0.5,oUIMapId)
  local x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, dUIMapId);
  local angle = HBD:GetWorldVector(instanceID, x, y, x2, y2)

  local a = math.cos(angle);
  local b = math.sin(angle);

  local t = {}
  table.insert(t, (1 - 0.5)/a);
  table.insert(t, (1 - 0.5)/b);
  table.insert(t, -0.5/a);
  table.insert(t, -0.5/b);

  local smallest = 9999999999;
  for _, val in pairs(t) do
    if(val >= 0) then
      if(val < smallest) then
        smallest = val;
      end
    end
  end

  local intX = 0.5+(smallest*a);
  local intY = 0.5+(smallest*b);
  return 1-intX, 1-intY;
end]]--

local function closeZone(UIMapId, UIMapId2)
  local coordsCheck = {}
  --This creates a grid
  for x=0, 1, 0.1 do
    for y=0, 1, 0.1 do
      table.insert(coordsCheck, {x, y});
    end
  end
  --[[--This creates a box
  for x=0, 1, 0.1 do
    if(x == 0 or x == 1) then
      for y=0, 1, 0.1 do
        table.insert(coordsCheck, {x, y});
      end
    else
      table.insert(coordsCheck, {x, 0});
      table.insert(coordsCheck, {x, 1});
    end
  end
  ]]--

  for _, dData in pairs(coordsCheck) do
    local x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(dData[1], dData[2], UIMapId2);
    local inX, inY = HBD:GetZoneCoordinatesFromWorld(x2, y2, UIMapId);
    if(inX and inY) then
      return true;
    end
  end
  return nil;
end

---A+ programming!!!!!!!!
local function distanceBetweenZones(UIMapId, UIMapId2)
  local coordsCheck = {}
  --This creates a grid
  for x=0, 1, 0.1 do
    for y=0, 1, 0.1 do
      table.insert(coordsCheck, {x, y});
    end
  end
  --[[--This creates a box
  for x=0, 1, 0.1 do
    if(x == 0 or x == 1) then
      for y=0, 1, 0.1 do
        table.insert(coordsCheck, {x, y});
      end
    else
      table.insert(coordsCheck, {x, 0});
      table.insert(coordsCheck, {x, 1});
    end
  end
  ]]--

  local smallestDistance = 99999999;
  --GetWorldDistance(instanceID, oX, oY, dX, dY)
  for _, oData in pairs(coordsCheck) do
    local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(oData[1], oData[2], UIMapId)
    for _, dData in pairs(coordsCheck) do
      local x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(dData[1], dData[2], UIMapId2);
      local distance = HBD:GetWorldDistance(instanceID, x, y, x2, y2);
      if(smallestDistance > distance) then
        smallestDistance = distance;
      end
    end
  end
  Questie:Print("---> oMap: ", C_Map.GetMapInfo(UIMapId).name, "dMap: ", C_Map.GetMapInfo(UIMapId2).name);
  Questie:Print("-> distance:", smallestDistance);

  return smallestDistance;
end


function QuestieFrameNew.utils:GenerateCloseZones()
  if(QuestieFrameNew.utils.zoneList) then
    DEFAULT_CHAT_FRAME:AddMessage("Zonelist already exists");
    return;
  end
  QuestieFrameNew.utils.zoneList = {}
  local WORLD_MAP_ID = 947;
  local Kalimdor = 1414;
  local EK = 1415;

  for UIMapId, zoneData in pairs(HBD.mapData) do
    if(not QuestieFrameNew.utils.zoneList[UIMapId]) then
      QuestieFrameNew.utils.zoneList[UIMapId] = {}
    end

    --Calculate close zones.
    for UIMapId2, zoneData2 in pairs(HBD.mapData) do
      if(UIMapId == WORLD_MAP_ID) then
        QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
      else
        if(zoneData.instance == zoneData2.instance) then
          --We already check the instance.. but i love reduntant code so why not.
          if((UIMapId == Kalimdor and UIMapId2 ~= EK) or (UIMapId == EK and UIMapId2 ~= Kalimdor)) then
            QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
          else

            --[[
            --https://math.stackexchange.com/questions/625266/find-collision-point-between-vector-and-fencing-rectangle
              local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(0.5, 0.5,UIMapId)
              local x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, UIMapId2);
              local angle = HBD:GetWorldVector(instanceID, x, y, x2, y2)

              local a = math.cos(angle);
              local b = math.sin(angle);

              local t = {}
              table.insert(t, (1 - 0.5)/a);
              table.insert(t, (1 - 0.5)/b);
              table.insert(t, -0.5/a);
              table.insert(t, -0.5/b);

              local smallest = 9999999999;
              for _, val in pairs(t) do
                if(val >= 0) then
                  if(val < smallest) then
                    smallest = val;
                  end
                end
              end

              local intX = 0.5+(smallest*a);
              local intY = 0.5+(smallest*b);

              x, y, instanceID = HBD:GetWorldCoordinatesFromZone(intX, intY, UIMapId)
              x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, UIMapId2);
              local distance = HBD:GetWorldDistance(instanceID, x, y, x2, y2);
              Questie:Print("---> oMap: ", C_Map.GetMapInfo(UIMapId).name, "dMap: ", C_Map.GetMapInfo(UIMapId2).name);
              Questie:Print("-> X:", intX, " Y:", intY, " angle:", angle, " distance:", distance);
              return intX, intY, distance
            ]]--
            

            --local distance = distanceBetweenZones(UIMapId, UIMapId2);
            --if(distance < 200) then
            --  QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
            --end
            if(closeZone(UIMapId, UIMapId2)) then
              QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
            end
          end
        end
      end
    end
  end
  Questie.db.global.zoneList = QuestieFrameNew.utils.zoneList;
end


function QuestieFrameNew.utils:RecursiveDirty(dirtyTable, UIMapId)
  if(dirtyTable and UIMapId) then
    local mapId = UIMapId;
    dirtyTable[mapId] = true;
    --Loop up in the tree
    --Could use while, but safer to do a for loop.
    for i=0, 20 do
        local parent = HBD.mapData[mapId].parent;
        dirtyTable[parent] = true;
        if(QuestieZoneToParentTable[mapId]) then
          dirtyTable[QuestieZoneToParentTable[mapId]] = true;
        end
        mapId = parent;
        if(parent == 0) then
            break;
        end
    end
    if(not QuestieFrameNew.utils.zoneList) then
      QuestieFrameNew.utils:GenerateCloseZones();
    end
    for zoneId, _ in pairs(QuestieFrameNew.utils.zoneList[UIMapId]) do
      dirtyTable[zoneId] = true;
    end
  end
end