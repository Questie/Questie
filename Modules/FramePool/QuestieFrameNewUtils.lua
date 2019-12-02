---@type QuestieFrameNew
local QuestieFrameNew = QuestieLoader:ImportModule("QuestieFrameNew");
QuestieFrameNew.utils = {}

QuestieFrameNew.utils.zoneList = nil

local HBD = LibStub("HereBeDragonsQuestie-2.0")
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
          if(UIMapId == Kalimdor or UIMapId == EK) then
            QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
          else
            local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, UIMapId)
            local x2, y2, instanceID2 = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, UIMapId2);
            local distance = HBD:GetWorldDistance(instanceID, x, y, x2, y2);
            if(distance < 1000) then
              QuestieFrameNew.utils.zoneList[UIMapId][UIMapId2] = true;
            end
          end
        end
      end
    end
  end
end