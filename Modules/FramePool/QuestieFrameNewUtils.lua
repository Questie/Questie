---@type QuestieFrameNew
local QuestieFrameNew = QuestieLoader:ImportModule("QuestieFrameNew");
QuestieFrameNew.utils = {}
--QuestieLoader:ImportModule("QuestieFrameNew").utils.zoneList
--QuestieLoader:ImportModule("QuestieFrameNew").utils:GenerateCloseZones()
QuestieFrameNew.utils.zoneList = nil

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


---A+ programming!!!!!!!!
local function distanceBetweenZones(UIMapId, UIMapId2)
  local coordsCheck = {}
  --[[
  --This creates a grid
  for x=0, 1, 0.1 do
    for y=0, 1, 0.1 do
      table.insert(coordsCheck, {x, y});
    end
  end
  ]]--
  --This creates a box
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
            

            local distance = distanceBetweenZones(UIMapId, UIMapId2);
            if(distance < 200) then
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