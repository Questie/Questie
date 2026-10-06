-- Contains library functions that do not have a logical place.
---@type WaypointMap
---@param utils table
---@param FramePool table
---@param PinMixin table
local WaypointMap = QuestieLoader:ImportModule("WaypointMap")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

WaypointMap.PinMixin = CreateFromMixins(MapCanvasPinMixin)

function WaypointMap.PinMixin:OnLoad()
	-- Override in your mixin, called when this pin is created
    self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
    --[[
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_EXPLORATION");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GARRISON_PLOT");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FOG_OF_WAR");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO_BLOB");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG", 4);
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DIG_SITE");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FLIGHT_POINT");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_INVASION");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_PET_TAMER");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SELECTABLE_GRAVEYARD");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GOSSIP");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_LINK");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CONTRIBUTION_COLLECTOR");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 200);
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_STORY_LINE");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST_PING");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST", C_QuestLog.GetMaxNumQuests());
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CORPSE");
        pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI_BANNER");
    ]]--
end

function WaypointMap.PinMixin:DrawLine(UiMapID, sX, sY, eX, eY, Linedata, maskTextures)
    -- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
    local lineData = Linedata or {}
    local dx,dy = eX - sX, eY - sY;
    -- Normalize direction if necessary
    if (dx < 0) then
        dx,dy = -dx,-dy;
    end
    local cx,cy = (sX + eX) / 2, (sY + eY) / 2;
    local width, height = WorldMapFrame:GetCanvas():GetSize();
    local minX = math.min(sX, eX);
    local minY = math.min(sY, eY);
    local framePosX, framePosY = minX*width, minY*height
    self:ClearAllPoints()
    --self:SetParent(WorldMapFrame:GetCanvas())
    --self:SetPosition(minX+(windowX/2), minY+(windowY/2))
    --self:SetPosition(cx, cy)
    if(not self.minimapPin) then
        --pcall(self.SetPosition, self, cx, cy);
        self:SetPosition(cx, cy)
    end
    
    self:SetSize(dx*width, dy*height)

    self.lineTexture = self.lineTexture or WaypointMap.LinePool:Acquire();
    self.lineTexture:ClearAllPoints()
    self.lineTexture:SetParent(self)
    local startX = sX * width
    local startY = sY * height -- We do by / -100 due to using the top left point
    local endX = eX * width
    local endY = eY * height

    --Due to thickness being used in linemixin we instead just use defaultThickness
    self.lineTexture.defaultThickness = lineData.thickness or 5;
    self.lineTexture.color = {r=lineData.r or 1, g=lineData.g or 1, b=lineData.b or 1, a=lineData.a or 0.6}
    if(maskTextures) then
        for _, maskTexture in pairs(maskTextures) do
            self.lineTexture:AddMaskTexture(maskTexture)
        end
        self.lineTexture.maskTextures = maskTextures
    end
    self.lineTexture:SetVertexColor(self.lineTexture.color.r, self.lineTexture.color.g, self.lineTexture.color.b, self.lineTexture.color.a)
    self.lineTexture:SetStartPoint(startX-framePosX, -(startY-framePosY))
    self.lineTexture:SetEndPoint(endX-framePosX, -(endY-framePosY))
    self.lineTexture:SetThickness(self.lineTexture.defaultThickness);
    self.lineTexture:SetPoint("CENTER", endX-framePosX, -(endY-framePosY))
    --Minimap Stuff
    local fWidth, fHeight = self:GetSize();

    local x1, y1= HBD:GetWorldCoordinatesFromZone(0, 0, UiMapID)
    local x2, y2 = HBD:GetWorldCoordinatesFromZone(1, 1, UiMapID)
    local mapWidth = x1 - x2;


    local mSizeX, mSizeY = Minimap:GetSize()
    self.minimapScale = {}

    local worldWidth = dx * mapWidth
    local numberOfMinimaps = worldWidth/(466 + 2/3)
    local frameWidth = numberOfMinimaps*mSizeX
    self.minimapScale["outdoor"] =  frameWidth/fWidth

    numberOfMinimaps = worldWidth/300
    frameWidth = numberOfMinimaps*mSizeX
    self.minimapScale["indoor"] =  frameWidth/fWidth
    --end Minimap stuff

    --self.self.lineTexture = self.lineTexture
    
    self.lineTexture:redraw()
    self.lineTexture:Show();
end

function WaypointMap.PinMixin:OnAcquired() -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
   
end

function WaypointMap.PinMixin:OnReleased()
    --print("OnPinRelease")
    -- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
    self:Hide()
    self:SetParent(UIParent)
    self:ClearAllPoints()
end

function WaypointMap.PinMixin:OnClick(button)
	-- Override in your mixin, called when this pin is clicked
    if WorldMapFrame and WorldMapFrame:IsShown() then
        if button == "RightButton" then
            local currentMapParent = WorldMapFrame:GetMapID()
            if currentMapParent then
                local mapInfo = C_Map.GetMapInfo(currentMapParent)
                currentMapParent = mapInfo.parentMapID

                if currentMapParent and currentMapParent > 0 then
                    WorldMapFrame:SetMapID(currentMapParent)
                end
            end
        end
    end
end

function WaypointMap.PinMixin:OnMouseEnter()
    -- Override in your mixin, called when the mouse enters this pin
end

function WaypointMap.PinMixin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
end

--- OVERRIDE FUNCTIONS, You can override these but might have to implement some of the features yourself 
-- i.e click through, pan etc
function WaypointMap.PinMixin:OnMouseDown()
	-- Override in your mixin, called when the mouse is pressed on this pin
    if(IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseDown("LeftButton")
    end
end

function WaypointMap.PinMixin:OnMouseUp()
	-- Override in your mixin, called when the mouse is released
    local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetCursorPosition();
	local isLeftClick = WorldMapFrame.ScrollContainer:WouldCursorPositionBeClick("LeftButton", cursorX, cursorY);
    if(not IsMouseButtonDown("LeftButton") and not isLeftClick) then
        WorldMapFrame.ScrollContainer:OnMouseUp("LeftButton")
    elseif(isLeftClick) then
        local mapId = WorldMapFrame:GetMapID()
        WorldMapFrame.ScrollContainer:OnMouseUp("LeftButton")
        if(mapId == WorldMapFrame:GetMapID()) then
            print(cursorX, cursorY, isLeftClick)
            print("Click")
        end
    end
end

function WaypointMap.PinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function WaypointMap.PinMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function WaypointMap.PinMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end