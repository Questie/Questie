---@class QuestieCoords
local QuestieCoords = QuestieLoader:CreateModule("QuestieCoords");

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local posX = 0;
local posY = 0;

QuestieCoords.updateInterval = 0.5;
-- Placing the functions locally to save time when spamming the updateInterval
local GetBestMapForUnit = C_Map.GetBestMapForUnit;
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition;
local GetCursorPosition = GetCursorPosition;

local GetMinimapZoneText = GetMinimapZoneText;
local IsInInstance = IsInInstance;
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
    if not ((Questie.db.global.mapCoordinatesEnabled and WorldMapFrame:IsVisible()) or (Questie.db.global.minimapCoordinatesEnabled and Minimap:IsVisible())) then
        return -- no need to write coords
    end
    local isInInstance, instanceType = IsInInstance()

    if isInInstance and "pvp" ~= instanceType then
        return -- dont write coords in raids
    end

    local position = QuestieCoords.GetPlayerMapPosition()
    if (not position) then
        return
    end

    if position.x ~= 0 and position.y ~= 0 and (position.x ~= QuestieCoords._lastX or position.y ~= QuestieCoords._lastY) then
        QuestieCoords._lastX = position.x
        QuestieCoords._lastY = position.y

        posX = position.x * 100;
        posY = position.y * 100;

        -- if minimap
        if Questie.db.global.minimapCoordinatesEnabled and Minimap:IsVisible() then
            MinimapZoneText:SetText(format("(%d, %d) ", posX, posY) .. GetMinimapZoneText());
        end
    end
    -- if main map
    if Questie.db.global.mapCoordinatesEnabled and WorldMapFrame:IsVisible() then
        -- get cursor position
        local curX, curY = GetCursorPosition();

        local canvas = WorldMapFrame:GetCanvas()

        local scale = canvas:GetEffectiveScale();
        curX = curX / scale;
        curY = curY / scale;

        local width = canvas:GetWidth();
        local height = canvas:GetHeight();
        local left = canvas:GetLeft();
        local top = canvas:GetTop();

        curX = (curX - left) / width * 100;
        curY = (top - curY) / height * 100;
        local precision = "%.".. Questie.db.global.mapCoordinatePrecision .."f";

        local worldmapCoordsText = "Cursor: "..format(precision.. " X, ".. precision .." Y  ", curX, curY);

        worldmapCoordsText = worldmapCoordsText.."|  Player: "..format(precision.. " X , ".. precision .." Y", posX, posY);
        -- Add text to world map
        GetMapTitleText():SetText(worldmapCoordsText)
    end
end

---@return table<{x: number, y: number}>, number | nil
function QuestieCoords.GetPlayerMapPosition()
    local mapID = GetBestMapForUnit("player")
    if (not mapID) then
        return nil, nil
    end

    return GetPlayerMapPosition(mapID, "player"), mapID
end

function QuestieCoords:Initialize()

    -- Do not fight with Coordinates addon
    if IsAddOnLoaded("Coordinates") and ((Questie.db.global.minimapCoordinatesEnabled) or (Questie.db.global.mapCoordinatesEnabled)) then
        Questie:Print("|cFFFF0000", l10n("WARNING!"), "|r", l10n("Coordinates addon is enabled and will cause buggy behavior. Disabling global map and mini map coordinates. These can be re-enabled in settings"))
        Questie.db.global.minimapCoordinatesEnabled = false
        Questie.db.global.mapCoordinatesEnabled = false
    end

    C_Timer.NewTicker(QuestieCoords.updateInterval, QuestieCoords.Update)
end

function QuestieCoords:Update()
    if (Questie.db.global.minimapCoordinatesEnabled) or (Questie.db.global.mapCoordinatesEnabled) then
        QuestieCoords.WriteCoords();
    end
end

function QuestieCoords:ResetMinimapText()
    MinimapZoneText:SetText(GetMinimapZoneText());
end

function QuestieCoords:ResetMapText()
    GetMapTitleText():SetText(WORLD_MAP);
end
