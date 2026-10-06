-- Contains library functions that do not have a logical place.
---@type Map
---@param utils table
---@param FramePool table*
---@param PinMixin table
local Map = QuestieLoader:ImportModule("Map")

Map.PinMixin = CreateFromMixins(MapCanvasPinMixin)

function Map.PinMixin:OnLoad()
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

function Map.PinMixin:OnAcquired(frameLevel) -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
    -- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
    --print("Pin Acquired args:", select("#", ...))
    --local typeMixin = select(1, ...)
    --if(not typeMixin) then
    --    self.PinMixin = Mixin(self, typeMixin)
    --    self.PinMixin:Initialize();
    --else
    --    self:Release();
    --end
    --self:SetPosition(0.5, 0.5)
    --Questie:Debug(DEBUG_DEVELOP, "BlobFrame", self)
    --self:SetFrameLevel(frameLevel)
    --self:ApplyFrameLevel()
    --self:Show()
end

function Map.PinMixin:OnReleased()
    --print("OnPinRelease")
    -- Override in your mixin, called when this pin is being released by a data provider and is no longer on the map
    --if(self.PinMixing) then
    --    self.PinMixin:UnInitialize();
    --    self.PinMixin = nil
    --end
    self:Hide()
    self:SetParent(UIParent)
    self:ClearAllPoints()
end

function Map.PinMixin:OnClick(button)
	-- Override in your mixin, called when this pin is clicked
    --Make the polygon click-through
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

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function Map.PinMixin:OnMouseEnter()
    -- Override in your mixin, called when the mouse enters this pin
    --local _, _, _, xOfs, yOfs = self:GetPoint(1)
    --local w, h = self:GetSize()
    --local getEffectiveScale = self:GetEffectiveScale()

    --print("X", xOfs, "Y", yOfs)
    --print("W", w, "(",(w*getEffectiveScale), ")", "H", h, "(",(h*getEffectiveScale), ")")
    --local left, bottom, width, height = self:GetRect()
    --width = width * getEffectiveScale
    --height = height * getEffectiveScale
    --local bo = self:GetBottom();
    --local to = self:GetTop();
    --local le = self:GetLeft();
    --local ri = self:GetRight();
    --print("L", left * getEffectiveScale, "B", bottom * getEffectiveScale)
    --print("R", (left + width) * getEffectiveScale, "T", (bottom - height) * getEffectiveScale)
    --print(bo*getEffectiveScale, to*getEffectiveScale, le*getEffectiveScale, ri*getEffectiveScale)

    --globalt = self.data
    local count = 0
    for giverId, questIds in pairs(self.object.data.giverIds) do
        local nName = QuestieDB.QueryNPCSingle(giverId, "name")
        print("GiverID: ", nName, "("..tostring(giverId)..")")
        for questId, _ in pairs(questIds) do
            local qName = QuestieDB.QueryQuestSingle(questId, "name")
            print("    ", qName, "("..tostring(questId)..")")
        end
        count = count + 1
    end
    print("Total Givers:", count)
    if(self.subNotes) then
        print("Total subnotes:", #self.subNotes)
    end
    if(self.object.OnMouseEnter) then
        self.object.OnMouseEnter()
    end
    --local x, y = self:GetCenter()
    --local getEffectiveScale = self:GetEffectiveScale()
    --print("X", x*getEffectiveScale, "Y", y*getEffectiveScale)
    --print("W", width * getEffectiveScale, "H", height * getEffectiveScale)
end

function Map.PinMixin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
end

function Map.PinMixin:OnMouseDown()
	-- Override in your mixin, called when the mouse is pressed on this pin
    if(IsMouseButtonDown("LeftButton")) then
        WorldMapFrame.ScrollContainer:OnMouseDown("LeftButton")
    end	
end

function Map.PinMixin:OnMouseUp()
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

function Map.PinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function Map.PinMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function Map.PinMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end