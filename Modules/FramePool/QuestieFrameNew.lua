
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local zoneCache = {}


local typeLookup = {}
typeLookup["available"] = {};
function typeLookup.available:GetIcon(questId)
  local questObject = QuestieDB:GetQuest(questId);
  if(questObject) then
    if questObject.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        return ICON_TYPE_AVAILABLE_GRAY
    elseif questObject.Repeatable then
        return ICON_TYPE_REPEATABLE
    elseif(questObject:IsTrivial()) then
        return ICON_TYPE_AVAILABLE_GRAY
    else
        return ICON_TYPE_AVAILABLE
    end
  end
  return ICON_TYPE_AVAILABLE;
end
function typeLookup.available:GetIconScale()
  return Questie.db.global.availableScale or 1.3;
end
function typeLookup.available:GetDrawLayer()
  return 1;
end

typeLookup["complete"] = {};
function typeLookup.complete:GetIcon()
  return ICON_TYPE_COMPLETE;
end
function typeLookup.complete:GetIconScale()
  return Questie.db.global.availableScale or 1.3;
end
function typeLookup.complete:GetDrawLayer()
  return 2;
end

typeLookup["event"] = {};
function typeLookup.event:GetIcon()
  return ICON_TYPE_EVENT;
end
function typeLookup.event:GetIconScale()
  return Questie.db.global.eventScale or 1.3;
end
function typeLookup.event:GetDrawLayer()
  return 0;
end

typeLookup["item"] = {};
function typeLookup.item:GetIcon()
  return ICON_TYPE_LOOT;
end
function typeLookup.item:GetIconScale()
  return Questie.db.global.lootScale or 1.3;
end
function typeLookup.item:GetDrawLayer()
  return 0;
end

typeLookup["monster"] = {};
function typeLookup.monster:GetIcon()
  return ICON_TYPE_SLAY;
end
function typeLookup.monster:GetIconScale()
  return Questie.db.global.monsterScale or 1.3;
end
function typeLookup.monster:GetDrawLayer()
  return 0;
end

typeLookup["object"] = {};
function typeLookup.object:GetIcon()
  return ICON_TYPE_OBJECT;
end
function typeLookup.object:GetIconScale()
  return Questie.db.global.objectScale or 1.3;
end
function typeLookup.object:GetDrawLayer()
  return 0;
end


local texturePool = CreateTexturePool(WorldMapFrame:GetCanvas());
texturePool.creationFunc = function(texPool)
  local texture = texPool.parent:CreateTexture(nil, "OVERLAY", nil, 0);
  texture.OLDSetVertexColor = texture.SetVertexColor;
  function texture:SetVertexColor(r, g, b, a)
      self:OLDSetVertexColor(r,g,b,a);
      --We save the colors to the texture object, this way we don't need to use GetVertexColor
      self.r = r or 1;
      self.g = g or 1;
      self.b = b or 1;
      self.a = a or 1;
  end
  texture:SetTexture(136235); --Samwise is our god.
  --We save the colors to the texture object, this way we don't need to use GetVertexColor
  texture:SetVertexColor(1,1,1,1);
  texture:SetTexelSnappingBias(0)
  texture:SetSnapToPixelGrid(false)

  return texture
end

texturePool.resetterFunc = function(texPool, texture)
  texture:SetTexture(136235)
  texture:SetVertexColor(1,1,1,1);
  TexturePool_HideAndClearAnchors(texPool, texture)
end


local function AcquireTextures(frame)

    --Different settings depending on noteType
    local globalScale = 0.7
    local objectiveColor = false
    local alpha = 1;

    globalScale = Questie.db.global.globalScale;
    objectiveColor = Questie.db.global.questObjectiveColors;
    alpha = 1;

    --[[
        local colors = {1, 1, 1}

        if self.data.IconColor ~= nil and objectiveColor then
            colors = self.data.IconColor
        end
        self.texture:SetVertexColor(colors[1], colors[2], colors[3], alpha);
    ]]--

    --if self.data.IconScale then
    --    local scale = 16 * ((self.data:GetIconScale() or 1)*(globalScale or 0.7));
    --    self:SetWidth(scale)
    --    self:SetHeight(scale)
    --else
    --    self:SetWidth(16)
    --    self:SetHeight(16)
    --end
    local count = 0;
    for pinType, questId in pairs(frame.questData) do
      count = count + 1;
    end

    local iconIndex = 0;

    local gotObjectives = false;
    for pinType, typeData in pairs(frame.questData) do
      --Here we fetch the texture for each used pinType
      local textures = {}
      for index, questData in pairs(typeData) do
        textures[typeLookup[pinType]:GetIcon(questData.questId)] = true;
      end

      --Here we draw all the textures that exist on the icon.
      for texture, _ in pairs(textures) do
          --- Textures
        local newTexture = texturePool:Acquire();

        newTexture:SetTexture(texture);
        newTexture:SetParent(frame);
        newTexture:SetDrawLayer("OVERLAY", typeLookup[pinType]:GetDrawLayer())
        newTexture:SetPoint("CENTER", frame, "CENTER", ((count * (16/2))*-1)+(count * (16/2))*iconIndex, 0);
        --DEFAULT_CHAT_FRAME:AddMessage(((count * (16/2))*-1)+(count * (16/2))*iconIndex);
        newTexture:SetSize((16 * typeLookup[pinType]:GetIconScale())*globalScale, (16 * typeLookup[pinType]:GetIconScale())*globalScale)
        newTexture:Show();

        if(pinType ~= "available" and pinType ~= "complete") then
          local glowt = texturePool:Acquire();
          glowt:SetTexture(ICON_TYPE_GLOW)
          glowt:SetDrawLayer("OVERLAY", -1)
          glowt:SetParent(frame);
          glowt:SetPoint("CENTER", frame, "CENTER", ((count * (18/2))*-1)+(count * (18/2))*iconIndex, 0);
          glowt:SetSize((18 * typeLookup[pinType]:GetIconScale())*globalScale, (18 * typeLookup[pinType]:GetIconScale())*globalScale)
          glowt:Show();

          frame.glowTexture = glowt
        end

        iconIndex = iconIndex +1;
        ---@class IconTexture
        table.insert(frame.textures, newTexture);
      end
    end

end

local function ReleaseTextures(frame)
  if(frame.glowTexture) then
    texturePool:Release(frame.glowTexture);
    frame.glowTexture = nil;
  end
  if(frame.texture) then
    texturePool:Release(frame.texture);
    frame.texture = nil;
  end
  if(frame.textures) then
    for index, tex in pairs(frame.textures) do
      texturePool:Release(tex);
    end
    frame.textures = {};
  end
end



local iconPool = CreateFramePool("BUTTON");
local worldmapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)
local worldmapProviderPin  = CreateFromMixins(MapCanvasPinMixin)

-------------------------------------------------------------------------------------------
-- WorldMap data provider
local frameId = 0;
-- setup pin pool
--AcquirePin runs framepool:Acquire which runs this function
iconPool.parent = WorldMapFrame:GetCanvas()
iconPool.creationFunc = function(framePool)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] Creating frame from pool");
    local frame = CreateFrame(framePool.frameType, nil, framePool.parent)
    frame:SetSize(16,16);
    frame.frameId = frameId;

    --- Data members
    frame.questData = {}
    frame.textures = {}

    ---Functions



    frameId = frameId + 1;
    return Mixin(frame, worldmapProviderPin)
end

iconPool.resetterFunc = function(pinPool, pin)
    FramePool_HideAndClearAnchors(pinPool, pin)
    pin:OnReleased()

    pin.pinTemplate = nil
    pin.owningMap = nil
end

-- register pin pool with the world map
WorldMapFrame.pinPools["PinsTemplateQuestie"] = iconPool

-- provider base API
function worldmapProvider:RemoveAllData()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] RemoveAllData");
  self:GetMap():RemoveAllPinsByTemplate("PinsTemplateQuestie")
end

function worldmapProvider:RemovePinByIcon(icon)
  for pin in self:GetMap():EnumeratePinsByTemplate("PinsTemplateQuestie") do
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew]", pin);
    --self:GetMap():RemovePin(pin)
  end
end

function worldmapProvider:RefreshAllData(fromOnShow)
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] RefreshAllData : ", fromOnShow);
  local mapId = self:GetMap():GetMapID()
  self:RemoveAllData()

  local allPins = {};


  for questId, _ in pairs(QuestieQuest.availableQuests) do
    local quest = QuestieDB:GetQuest(questId);
    for index, position in pairs(quest.starterLocations) do
      local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(position.x/100, position.y/100, position.UIMapId)
        
      if(x and y and HBD.mapData[position.UIMapId] and HBD.mapData[position.UIMapId].instance == instanceID) then
        table.insert(allPins, position);
      end
    end
  end

  for questId, questData in pairs(QuestiePlayer.currentQuestlog) do
    Questie:Print(questId)
    local quest = QuestieDB:GetQuest(questId);
    for objectiveIndex, spawnData in pairs(quest.objectiveIcons or {}) do
      Questie:Print("---->", objectiveIndex)
      for index, spawn in pairs(spawnData) do
        for k, v in pairs(spawn) do
          Questie:Print("->>", k, v)
        end
        Questie:Print("Testprint", spawn.x, spawn.y, spawn)
        local x, y, instanceID = 0;
        if(spawn.x > 100 or spawn.y > 100) then
          x, y, instanceID = HBD:GetZoneCoordinatesFromWorld(spawn.x, spawn.y, spawn.UIMapId)
          spawn.x = x;
          spawn.y = y;
        end
        if(x and y and HBD.mapData[spawn.UIMapId] and HBD.mapData[spawn.UIMapId].instance == instanceID) then
          Questie:Print("------->ADDED PIN:", x,y);
          --table.insert(allPins, spawn);
        end
      end
    end
  end
  Questie:Print("--------------------------------------------------------------------")
  local hotzones = QuestieMap.utils:CalcHotzones(allPins, 70);

  for _, positions in pairs(hotzones) do
      local center = QuestieMap.utils:CenterPoint(positions)

      local questData = {}
      for _, positionData in pairs(positions) do
        --Questie:Print(positionData.pinType, positionData)
        if(not questData[positionData.pinType] ) then
          questData[positionData.pinType] = {}
        end
        table.insert(questData[positionData.pinType], positionData);
      end

      
      
      if(center.x > 1 and center.y > 1) then
        center.x = center.x/100;
        center.y = center.y/100;
      end
      
      local instanceID = -1;
      local x, y, instanceID = HBD:GetWorldCoordinatesFromZone(center.x, center.y, positions[1].UIMapId)
      
      x, y = HBD:GetZoneCoordinatesFromWorld(x, y, mapId);
      
      if(x and y and HBD.mapData[mapId] and HBD.mapData[mapId].instance == instanceID) then
      Questie:Print(x, y, instanceID, center.x, center.y, positions[1].UIMapId);
        self:GetMap():AcquirePin("PinsTemplateQuestie", "NotUsed", questData, x, y);--data.frameLevelType)
      end
  end

  --self:GetMap():AcquirePin("PinsTemplateQuestie", "objective", {}, 0.5, 0.5);--data.frameLevelType)
end

--  map pin base API
function worldmapProviderPin:OnLoad()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnLoad");
  self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
  self:SetScalingLimits(1, 1.0, 1.2)
end

function worldmapProviderPin:OnAcquired(pinType, questData, x, y, frameLevelType)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnAcquired", pinType, x, y, questData);
    self:UseFrameLevelType(frameLevelType or "PIN_FRAME_LEVEL_AREA_POI")
    self:SetPosition(x, y)
    self.questData = questData;
    self.pinType = pinType;

    AcquireTextures(self);

    self:Show();
end

function worldmapProviderPin:OnReleased()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnReleased");
  self.questData = {};
  ReleaseTextures(self);
  if self.icon then
      --self.icon:Hide()
      --self.icon:SetParent(UIParent)
      --self.icon:ClearAllPoints()
      --self.icon = nil
  end
end

function worldmapProviderPin:OnClick(button)
  -- Override in your mixin, called when this pin is clicked
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnClick", button);
end
function worldmapProviderPin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseEnter", self.questData[1].Id, self.questData[1].name);
  
end
function worldmapProviderPin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseLeave", self);
end

-- register with the world map
WorldMapFrame:AddDataProvider(worldmapProvider)
