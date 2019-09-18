QuestieCoords = {};
local posX = 0;
local posY = 0;

QuestieCoords.updateInterval = 0.3;
-- Placing the functions locally to save time when spamming the updateInterval
local GetBestMapForUnit = C_Map.GetBestMapForUnit;
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition;
local GetCursorPosition = GetCursorPosition;

local GetMinimapZoneText = GetMinimapZoneText;
local format = format;



local function GetMapTitleText()

    local regions = {WorldMapFrame.BorderFrame:GetRegions()}
    for i = 1, #regions do
        if (regions[i].SetText) then
            return regions[i]
        end
    end
end

function QuestieCoords:WriteCoords()
    local mapID;
    local position;

    -- Player position
    mapID = GetBestMapForUnit("player");

    if mapID then
        position = GetPlayerMapPosition(mapID, "player");
        if position and position.x ~= 0 and position.y ~= 0  then
          posX = position.x * 100;
          posY = position.y * 100;

          -- if minimap
          if Questie.db.global.minimapCoordinatesEnabled and Minimap:IsVisible() then
              MinimapZoneText:SetText(
                          format("(%d, %d) ", posX, posY) .. GetMinimapZoneText()
                      );
          end

          -- if main map
          if Questie.db.global.mapCoordinatesEnabled and WorldMapFrame:IsVisible() then
              -- get cursor position
              local curX, curY = GetCursorPosition();

              local scale = WorldMapFrame:GetCanvas():GetEffectiveScale();
              curX = curX / scale;
              curY = curY / scale;

              local width = WorldMapFrame:GetCanvas():GetWidth();
              local height = WorldMapFrame:GetCanvas():GetHeight();
              local left = WorldMapFrame:GetCanvas():GetLeft();
              local top = WorldMapFrame:GetCanvas():GetTop();

              curX = (curX - left) / width * 100;
              curY = (top - curY) / height * 100;
              local precision = "%.".. Questie.db.global.mapCoordinatePrecision .."f";

              local worldmapCoordsText = "Cursor: "..format(precision.. " X, ".. precision .." Y  ", curX, curY);

              worldmapCoordsText = worldmapCoordsText.."|  Player: "..format(precision.. " X , ".. precision .." Y", posX, posY);
              -- Add text to world map
              GetMapTitleText():SetText(worldmapCoordsText)
          end
        end
    end
end

function QuestieCoords:Initialize()
    --QuestieCoords.coordFrame = CreateFrame("Frame");
    --QuestieCoords.coordFrame:SetScript("OnUpdate", QuestieCoords.Update);
    C_Timer.NewTicker(QuestieCoords.updateInterval, QuestieCoords.Update)
end

function QuestieCoords:Update(elapsed)
    if (Questie.db.global.minimapCoordinatesEnabled) or
        (Questie.db.global.mapCoordinatesEnabled) then

        --totalTime = totalTime + elapsed;
        --if(totalTime > QuestieCoords.updateInterval) then
        --    totalTime = 0;
            QuestieCoords.WriteCoords();
        --end
    end
end

function QuestieCoords:ResetMinimapText()
    MinimapZoneText:SetText(GetMinimapZoneText());
end

function QuestieCoords:ResetMapText()
    GetMapTitleText():SetText(WORLD_MAP);
end
