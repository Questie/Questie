---@type QuestieFrameNew
local QuestieFrameNew = QuestieLoader:ImportModule("QuestieFrameNew");
QuestieFrameNew.utils = {}
--QuestieLoader:ImportModule("QuestieFrameNew").utils.zoneList
--QuestieLoader:ImportModule("QuestieFrameNew").utils:GenerateCloseZones()
QuestieFrameNew.utils.zoneList = nil

local HBD = LibStub("HereBeDragonsQuestie-2.0")
function QuestieFrameNew.utils:GenerateCloseZones()
  QuestieFrameNew.utils.zoneList = {}
  local WORLD_MAP_ID = 947;
  local Kalimdor = 1414;
  local EK = 1415;
  local coordsCheck = {}
  table.insert(coordsCheck, {0, 0});
  table.insert(coordsCheck, {0.5, 0});
  table.insert(coordsCheck, {1, 0.5});
  table.insert(coordsCheck, {0.5, 0.5});
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
          if(UIMapId == Kalimdor or UIMapId == EK) then
            QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
          else

            local found = nil;
            --GetWorldDistance(instanceID, oX, oY, dX, dY)
            for _, oData in pairs(coordsCheck) do
              local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(oData[1], oData[2], UIMapId)
              for _, dData in pairs(coordsCheck) do
                local x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(dData[1], dData[2], UIMapId2);
                local distance = HBD:GetWorldDistance(instanceID, x, y, x2, y2);
                if(distance < 2000) then
                  QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
                  found = true;
                  break;
                end
              end
              if(found) then
                break;
              end
            end
          end
        end
      end
    end
  end
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