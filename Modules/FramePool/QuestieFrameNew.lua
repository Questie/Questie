
---@class QuestieFrameNew
local QuestieFrameNew = QuestieLoader:CreateModule("QuestieFrameNew");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestieFrameNewMinimap
local QuestieFrameNewMinimap = QuestieLoader:ImportModule("QuestieFrameNewMinimap");

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local enumerator = 0; -- DO EDIT.
QuestieFrameNew.stringEnum = setmetatable({}, {
  __index = function(stringEnum, key)
     local rawValue = rawget(stringEnum, key)
     if not rawValue then
        DEFAULT_CHAT_FRAME:AddMessage("stringEnum settings enum:"..key.. " enumID:".. enumerator);
        rawset(stringEnum, key, enumerator);
        rawset(stringEnum, enumerator, key);
        enumerator = enumerator + 1;
        return rawget(stringEnum, key)
     else
        return rawValue
     end
  end
})


local typeLookup = {}
typeLookup[QuestieFrameNew.stringEnum["available"]] = {};
typeLookup[QuestieFrameNew.stringEnum["available"]].GetIcon = function(questId)
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
typeLookup[QuestieFrameNew.stringEnum["available"]].GetIconScale = function()
  return Questie.db.global.availableScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["available"]].GetDrawLayer = function()
  return 1;
end
typeLookup[QuestieFrameNew.stringEnum["available"]].GetPixelDistance = function()
  return 3;
end

typeLookup[QuestieFrameNew.stringEnum["complete"]] = {};
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetIcon = function()
  return ICON_TYPE_COMPLETE;
end
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetIconScale = function()
  return Questie.db.global.availableScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetDrawLayer = function()
  return 2;
end
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetPixelDistance = function()
  return 6;
end

typeLookup[QuestieFrameNew.stringEnum["event"]] = {};
typeLookup[QuestieFrameNew.stringEnum["event"]].GetIcon = function()
  return ICON_TYPE_EVENT;
end
typeLookup[QuestieFrameNew.stringEnum["event"]].GetIconScale = function()
  return Questie.db.global.eventScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["event"]].GetDrawLayer = function()
  return 0;
end
typeLookup[QuestieFrameNew.stringEnum["event"]].GetPixelDistance = function()
  return 8;
end

typeLookup[QuestieFrameNew.stringEnum["item"]] = {};
typeLookup[QuestieFrameNew.stringEnum["item"]].GetIcon = function()
  return ICON_TYPE_LOOT;
end
typeLookup[QuestieFrameNew.stringEnum["item"]].GetIconScale = function()
  return Questie.db.global.lootScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["item"]].GetDrawLayer = function()
  return 0;
end
typeLookup[QuestieFrameNew.stringEnum["item"]].GetPixelDistance = function()
  return 4;
end

typeLookup[QuestieFrameNew.stringEnum["monster"]] = {};
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetIcon = function()
  return ICON_TYPE_SLAY;
end
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetIconScale = function()
  return Questie.db.global.monsterScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetDrawLayer = function()
  return 0;
end
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetPixelDistance = function()
  return 8;
end

typeLookup[QuestieFrameNew.stringEnum["object"]] = {};
typeLookup[QuestieFrameNew.stringEnum["object"]].GetIcon = function()
  return ICON_TYPE_OBJECT;
end
typeLookup[QuestieFrameNew.stringEnum["object"]].GetIconScale = function()
  return Questie.db.global.objectScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["object"]].GetDrawLayer = function()
  return 0;
end
typeLookup[QuestieFrameNew.stringEnum["object"]].GetPixelDistance = function()
  return 8;
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
  texture.textureData = nil;
  texture:SetTexture(136235)
  texture:SetVertexColor(1,1,1,1);
  TexturePool_HideAndClearAnchors(texPool, texture)
end


QuestieFrameNew.iconPool = CreateFramePool("BUTTON");
QuestieFrameNew.worldmapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)
QuestieFrameNew.worldmapProviderPin  = CreateFromMixins(MapCanvasPinMixin)

-------------------------------------------------------------------------------------------
-- WorldMap data provider
local frameId = 0;
-- setup pin pool
--AcquirePin runs framepool:Acquire which runs this function
QuestieFrameNew.iconPool.parent = WorldMapFrame:GetCanvas()
QuestieFrameNew.iconPool.creationFunc = function(framePool)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] Creating frame from pool");
    local frame = CreateFrame(framePool.frameType, nil, framePool.parent)
    frame:SetSize(16,16);
    frame.frameId = frameId;

    --- Data members
    frame.questData = {}
    frame.textures = {}

    ---Functions



    frameId = frameId + 1;
    return Mixin(frame, QuestieFrameNew.worldmapProviderPin)
end

QuestieFrameNew.iconPool.resetterFunc = function(pinPool, pin)
    FramePool_HideAndClearAnchors(pinPool, pin)
    pin:OnReleased()

    pin.pinTemplate = nil
    pin.owningMap = nil
end

-- register pin pool with the world map
WorldMapFrame.pinPools["PinsTemplateQuestie"] = QuestieFrameNew.iconPool

-- provider base API
function QuestieFrameNew.worldmapProvider:RemoveAllData()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] RemoveAllData");
  self:GetMap():RemoveAllPinsByTemplate("PinsTemplateQuestie")
end

function QuestieFrameNew.worldmapProvider:RemovePinByIcon(icon)
  for pin in self:GetMap():EnumeratePinsByTemplate("PinsTemplateQuestie") do
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew]", pin);
    --self:GetMap():RemovePin(pin)
  end
end

---@type table<integer, table> @UiMapId and note Info
local zoneCache = {}

---@param fromOnShow boolean @Default blizzard, returns true if the map opens
---@param customMapId integer @UIMapId that wants to be forced, Optional
function QuestieFrameNew.worldmapProvider:RefreshAllData(fromOnShow, customMapId)
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] RefreshAllData : ", fromOnShow);
  local mapId = customMapId or self:GetMap():GetMapID()
  self:RemoveAllData()

  --Map icons are disabled.
  --if(not Questie.db.global.enableMapIcons) then return; end

  local enableAvailable = Questie.db.global.enableAvailable;
  local enableTurnins = Questie.db.global.enableTurnins;
  local enableObjectives = Questie.db.global.enableObjectives;

  --This will make it rerun the hotzones if needed.
  local dirty = false;

  --temporary should be moved.
  if(not QuestieFrameNew.utils.zoneList) then
    QuestieFrameNew.utils:GenerateCloseZones();
  end

  local closeZones = QuestieFrameNew.utils.zoneList[mapId];

  local allPins = {};

  --We only want to reset it once
  local availableCacheReset = false;
  local completeCacheReset = false;
  local objectiveCacheReset = false;

  if(not zoneCache[mapId]) then
    zoneCache[mapId] = {}
    zoneCache[mapId].availableCache = {}
    zoneCache[mapId].availableCacheDirty = false

    zoneCache[mapId].completeCache = {}
    zoneCache[mapId].completeCacheDirty = false

    zoneCache[mapId].objectiveCache = {}
    zoneCache[mapId].objectiveCacheDirty = false
  end

  --A generic function to check if anything related to the object is dirty.
  local function checkDirty(dirtyObject, mapId)
    if(dirtyObject[mapId]) then
      return true;
    else
      for UIMapId, _ in pairs(closeZones or {}) do
        if(dirtyObject[UIMapId]) then
          return true;
        end
      end
    end
    return false;
  end

  --Available quests
  if (enableAvailable) then
    for questId, _ in pairs(QuestieQuest.availableQuests) do
      local quest = QuestieDB:GetQuest(questId);
      if(checkDirty(quest.starterDirty, mapId)) then
        --Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "Starter dirty", questId);
        --Map is dirty we reset the cache
        if(not availableCacheReset) then
          zoneCache[mapId].availableCache = {}
          availableCacheReset = true;
        end
        for index, position in pairs(quest.starterLocations) do
          if(closeZones[position.UIMapId]) then
            local x, y = HBD:TranslateZoneCoordinates(position.x/100, position.y/100, position.UIMapId, mapId);
            if(x and y) then
              table.insert(zoneCache[mapId].availableCache, position)
              zoneCache[mapId].availableCacheDirty = true;
            end
          end
        end
        dirty = true;
        quest.starterDirty[mapId] = false;
      end
    end
  end

  for questId, questData in pairs(QuestiePlayer.currentQuestlog) do
    --Questie:Print("--Adding quest -> ", questId)
    local quest = questData;
    if(type(questData) == "number") then
      quest = QuestieDB:GetQuest(questId);
    end

    --Complete quests
    if (enableTurnins) then
        if(quest.finisherLocations and checkDirty(quest.finisherDirty, mapId)) then
          --Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "Finisher dirty", questId);
          if(not completeCacheReset) then
            zoneCache[mapId].completeCache = {}
            completeCacheReset = true;
          end
          for index, position in pairs(quest.finisherLocations) do
            if(closeZones[position.UIMapId]) then
              local x, y = HBD:TranslateZoneCoordinates(position.x/100, position.y/100, position.UIMapId, mapId);
              if(x and y) then
                table.insert(zoneCache[mapId].completeCache, position)
                zoneCache[mapId].completeCacheDirty = true
              end
            end
          end
          dirty = true;
          quest.finisherDirty[mapId] = false;
        end
    end

    --Objectives
    if(enableObjectives) then
      if(quest.objectiveIcons and checkDirty(quest.objectiveDirty, mapId)) then
        --Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "Objective dirty", questId);
        if(not objectiveCacheReset) then
          zoneCache[mapId].objectiveCache = {}
          objectiveCacheReset = true;
        end
        for objectiveIndex, spawnData in pairs(quest.objectiveIcons) do
          --Questie:Print("---->", objectiveIndex)
          for index, spawn in pairs(spawnData) do
            if(closeZones[spawn.UIMapId]) then
              local x, y = HBD:TranslateZoneCoordinates(spawn.x/100, spawn.y/100, spawn.UIMapId, mapId);
              if(x and y) then
                --Questie:Print("------->ADDED PIN:", x,y);
                table.insert(zoneCache[mapId].objectiveCache, spawn)
                zoneCache[mapId].objectiveCacheDirty = true
              end
            end
          end
        end
        dirty = true;
        quest.objectiveDirty[mapId] = false;
      end
    end
  end

  Questie:Print("--------------------------------------------------------------------")
  Questie:Debug(DEBUG_ELEVATED, "Drawing icons, current size of icon list:", #zoneCache[mapId].objectiveCache+#zoneCache[mapId].completeCache+#zoneCache[mapId].availableCache);
  if(dirty or not zoneCache[mapId].hotzones) then
    zoneCache[mapId].hotzones = {}
    if(zoneCache[mapId].objectiveCacheDirty) then
      Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "objectiveCache dirty recalculating hotzones");
      zoneCache[mapId].objectiveCache = QuestieMap.utils:CalcHotzones(zoneCache[mapId].objectiveCache, 70, #zoneCache[mapId].objectiveCache);
      zoneCache[mapId].objectiveCacheDirty = false;
    end

    if(zoneCache[mapId].completeCacheDirty) then
      Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "completeCache dirty recalculating hotzones");
      zoneCache[mapId].completeCache = QuestieMap.utils:CalcHotzones(zoneCache[mapId].completeCache, 10, #zoneCache[mapId].completeCache);
      zoneCache[mapId].completeCacheDirty = false;
    end

    if(zoneCache[mapId].availableCacheDirty) then
      Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "availableCache dirty recalculating hotzones");
      zoneCache[mapId].availableCache = QuestieMap.utils:CalcHotzones(zoneCache[mapId].availableCache, 15, #zoneCache[mapId].availableCache);
      zoneCache[mapId].availableCacheDirty = false;
    end
    for _, positions in pairs(zoneCache[mapId].objectiveCache) do
      table.insert(zoneCache[mapId].hotzones, positions);
    end
    for _, positions in pairs(zoneCache[mapId].completeCache) do
      table.insert(zoneCache[mapId].hotzones, positions);
    end
    for _, positions in pairs(zoneCache[mapId].availableCache) do
      table.insert(zoneCache[mapId].hotzones, positions);
    end
  end

  Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNew]", "Number of hotzones", #zoneCache[mapId].hotzones);
  local minimapData = {};
  --If hotzones are set we set it to that or the zoneCache if hotzones is nil
  local playerUIMapId = C_Map.GetBestMapForUnit("player");
  for _, positions in pairs(zoneCache[mapId].hotzones) do
    local center = QuestieMap.utils:CenterPoint(positions)

    ---@type table<string, table<string, table>
    local questData = {}
    for _, positionData in pairs(positions) do
      --Questie:Print(positionData.pinType, positionData)
      if(not questData[positionData.pinType] ) then
        questData[positionData.pinType] = {}
      end
      table.insert(questData[positionData.pinType], positionData);
    end

    local x, y = HBD:TranslateZoneCoordinates(center.x/100, center.y/100, positions[1].UIMapId, mapId);

    if(x and y) then
      --We only every want to update minimap stuff its relating to our current zone.
      if(playerUIMapId == mapId) then
        table.insert(minimapData, {questData, center.x, center.y, x, y, positions[1].UIMapId});
      end

      Questie:Print(x, y, center.x/100, center.y/100, positions[1].UIMapId, mapId);
      --Hide unexplored logic
      if(WorldMapFrame:IsShown()) then
        if(not Questie.db.global.hideUnexploredMapIcons or (QuestieMap.utils:IsExplored(mapId, x, y) and Questie.db.global.hideUnexploredMapIcons)) then
          self:GetMap():AcquirePin("PinsTemplateQuestie", "NotUsed", questData, x, y, positions[1].UIMapId);--data.frameLevelType)
        end
      end
    end
  end

  --We only want to refresh it when the mapId corresponds.
  if(playerUIMapId == mapId) then
    --Refresh the minimap
    QuestieFrameNewMinimap:RefreshAllData(minimapData);
  end
end


local function AcquireTextures(frame)

    --Different settings depending on noteType
    local globalScale = Questie.db.global.globalScale or 0.7

    local mapId = WorldMapFrame:GetMapID()

    local frameWidthPixels = 0;

    --We want to scale depending on zoom level.
    local frameScaling = 1;
    if(mapId == 947) then --Azeroth
        frameScaling = 0.85
    elseif(mapId == 1414 or mapId == 1415) then -- EK and Kalimdor
        frameScaling = 0.9
    end

    --Count the number of pins to place them in the correct place.
    -- not used
    local count = 0;

    --Number of drawn textures
    local totalTextures = 0;

    for rawPinType, typeData in pairs(frame.questData) do
      --Here we fetch the texture for each used pinType
      ---@type table<QuestId, table<ObjectiveIndex, TextureData>>
      local textures = {}
      for index, questData in pairs(typeData) do
        --Fetch the color used for the objective.
        ---@class TextureData
        local textureData = {}

        --Populate data for the texture
        textureData.position = {}
        textureData.position.x = questData.x;
        textureData.position.y = questData.y;

        Questie:Print(questData.x/100, questData.y/100, " : ", frame.position.x, frame.position.y, questData.UIMapId, frame.position.UIMapId)
        ---@type integer
        textureData.pinTypeId = QuestieFrameNew.stringEnum[rawPinType];
        ---@type QuestId
        textureData.questId = questData.questId;
        ---@type integer
        textureData.textureId = QuestieFrameNew.stringEnum[typeLookup[textureData.pinTypeId]:GetIcon(questData.questId)];


        if(questData.objectiveIndex) then
          --Fetch the generated color
          local quest = QuestieDB:GetQuest(questData.questId);
          if(quest and quest.Objectives and quest.Objectives[questData.objectiveIndex].Color) then
            textureData.color = quest.Objectives[questData.objectiveIndex].Color;
          else
            textureData.color = {1, 1, 1, 1};
          end

          --We do this because tooltip needs this data to generate.
          ---@type ObjectiveIndex
          textureData.objectiveIndex = questData.objectiveIndex;
        end

        if(questData.targetType) then
          ---@type string
          textureData.targetType = questData.targetType;
        end
        if(questData.targetId) then
          ---@type integer
          textureData.targetId = questData.targetId;
        end
        local targetTypeIdTexture = textureData.targetType..":"..textureData.targetId..":"..textureData.textureId;
        if(not textures[targetTypeIdTexture]) then
          textures[targetTypeIdTexture] = {};
        end
        if(not textures[targetTypeIdTexture][textureData.questId]) then
          textures[targetTypeIdTexture][textureData.questId] = {}
        end
        if(questData.objectiveIndex) then
          textures[targetTypeIdTexture][textureData.questId][questData.objectiveIndex] = textureData;
        else
          textures[targetTypeIdTexture][textureData.questId][0] = textureData;
        end
      end
      --Here we draw all the textures that exist on the icon.
      for targetTypeIdTexture, questList in pairs(textures) do
        local textureExists = false;
        ---@param questDataList table<ObjectiveIndex, TextureData>
        for questId, questDataList in pairs(questList) do
          ---@param textureData TextureData
          for objectiveIndex, textureData in pairs(questDataList) do
            --[[setmetatable(texturePool:Acquire(), {
              __index = function(textureTable, key)
                local rawData = rawget(textureTable, key);
                if key == "textureData" and rawData then
                    return QuestieSerializer:Deserialize(rawData);
                else
                    return rawData
                end
              end,
              __newindex = function(textureTable, key, value)
                if(key == "textureData") then
                  rawset(textureTable, key, QuestieSerializer:Serialize(value))
                else
                  rawset(textureTable, key, value)
                end
              end
            })]]--
            --- Textures
            --We want the textureData to be Serialized to save space.
            ---@class IconTextureNew
            local newTexture = nil;
            if(not textureExists) then
              newTexture = texturePool:Acquire()
              newTexture.textureData = textureData;



              newTexture:SetTexture(typeLookup[textureData.pinTypeId].GetIcon(textureData.questId));
              newTexture:SetParent(frame);
              --newTexture:SetPoint("CENTER", frame, "CENTER", iconPos, 0);
              if(Questie.db.global.questObjectiveColors) then
                newTexture:SetVertexColor(unpack(textureData.color));
              end
              newTexture:SetSize((16 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale, (16 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale)
              --newTexture:Show();
              frameWidthPixels = frameWidthPixels + typeLookup[textureData.pinTypeId]:GetPixelDistance();

              if(textureData.pinTypeId ~= QuestieFrameNew.stringEnum["available"] and textureData.pinTypeId ~= QuestieFrameNew.stringEnum["complete"] and Questie.db.global.alwaysGlowMap) then
                local glowt = texturePool:Acquire();
                glowt:SetTexture(ICON_TYPE_GLOW)
                glowt:SetVertexColor(unpack(textureData.color));
                glowt:SetDrawLayer("OVERLAY", -1)
                glowt:SetParent(frame);
                --glowt:SetPoint("CENTER", frame, "CENTER", glowPos, 0);
                glowt:SetSize((18  *globalScale), (18 * globalScale));
                --glowt:Show();

                ---@type IconTextureNew
                newTexture.glowTexture = glowt
              end
              totalTextures = totalTextures + 1;
              textureExists = true;
            else
              newTexture = {}
              textureData.fakeTexture = true;
              newTexture.textureData = textureData;
            end

            table.insert(frame.textures, newTexture);
          end
        end
      end
    end

    local function compare(a,b)
        Questie:Print(a.textureData.position.x, b.textureData.position.x, a.textureData.position.x < b.textureData.position.x)
        return a.textureData.position.x < b.textureData.position.x
    end
    table.sort(frame.textures, compare)

    local coordsToPixelsY = (WorldMapFrame:GetCanvas():GetHeight()*WorldMapFrame:GetCanvas():GetEffectiveScale());
    local drawnTextures = 0;
    for _, texture in ipairs(frame.textures) do
      if(not texture.textureData.fakeTexture) then
        local iconPos = 0
        local glowPos = 0;
        if(totalTextures > 1) then
          iconPos = ((count * (16/2))*-1)+(count * (16/2))*drawnTextures;
          iconPos = (((typeLookup[texture.textureData.pinTypeId]:GetPixelDistance()*1)*totalTextures)/totalTextures)+(typeLookup[texture.textureData.pinTypeId]:GetPixelDistance()*drawnTextures);
          glowPos = (((count * (16/2))*-1)+(count * (16/2))*drawnTextures);
          glowPos = 16*drawnTextures;
        else
          iconPos = 0;
          glowPos = 0;
        end

        if(texture.glowTexture) then
          texture.glowTexture:SetDrawLayer("OVERLAY", (totalTextures*-1)+(1*drawnTextures))
          texture.glowTexture:SetPoint("CENTER", texture, "CENTER", 0, 0);
          texture.glowTexture:Show();
        end

        --To make them not seem so similar we use their respective Y pos to move them.
        --local xDiff = frame.position.x-texture.textureData.position.x/100;
        local yDiff = frame.position.y-texture.textureData.position.y/100;
        if(mapId ~= frame.position.UIMapId) then
          local x, y = HBD:TranslateZoneCoordinates(texture.textureData.position.x/100, texture.textureData.position.y/100, frame.position.UIMapId, mapId)
          --xDiff = frame.position.x-x;
          yDiff = frame.position.y-y;
        end
        if(QuestieFrameNew.stringEnum["available"] ~= texture.textureData.pinTypeId) then
          yDiff = 0;
        end

        texture:SetDrawLayer("OVERLAY", typeLookup[texture.textureData.pinTypeId]:GetDrawLayer()+drawnTextures);
        texture:SetPoint("CENTER", frame, "CENTER", iconPos, yDiff*coordsToPixelsY);
        texture:Show();
        drawnTextures = drawnTextures + 1;
      end
    end

    --Increase the width to match the number of icons.
    frame:SetWidth(math.max(16, frameWidthPixels));
    frame:SetScale(frameScaling);

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
      if(tex.glowTexture) then
        texturePool:Release(tex.glowTexture);
        tex.glowTexture = nil;
      end
      texturePool:Release(tex);
    end
    frame.textures = {};
  end
end


--  map pin base API
function QuestieFrameNew.worldmapProviderPin:OnLoad()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnLoad");
  self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
  self:SetScalingLimits(1, 1.0, 1.2)
end

function QuestieFrameNew.worldmapProviderPin:OnAcquired(pinType, questData, x, y, UIMapIdd, frameLevelType)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnAcquired", pinType, x, y, questData);
    self:UseFrameLevelType(frameLevelType or "PIN_FRAME_LEVEL_AREA_POI")
    self:SetPosition(x, y)
    self.questData = questData;
    self.pinType = pinType; --not used or correct
    self.position = {x=x, y=y, z=nil, UIMapId=UIMapIdd}; --Insert heightmap

    AcquireTextures(self);

    self:Show();
end

function QuestieFrameNew.worldmapProviderPin:OnReleased()
  --Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnReleased");
  self.questData = {};
  self.pinType = "";
  self.poisition = nil;
  --Reset the width incase we've previously been a combined icon.
  self:SetWidth(16);
  ReleaseTextures(self);
end

function QuestieFrameNew.worldmapProviderPin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
    Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnClick", button);
    --_QuestieFramePool:Questie_Click(self)
    if self and self.position.UIMapId and WorldMapFrame and WorldMapFrame:IsShown() then
      if button == "RightButton" then
          local currentMapParent = WorldMapFrame:GetMapID()
          if currentMapParent then
              currentMapParent = QuestieZoneToParentTable[currentMapParent];
              if currentMapParent and type(currentMapParent) == "number" and currentMapParent > 0 then
                  WorldMapFrame:SetMapID(currentMapParent)
              end
          end
      else
          if self.position.UIMapId ~= WorldMapFrame:GetMapID() then
              WorldMapFrame:SetMapID(self.position.UIMapId);
          end
      end
  end
  --TODO: Fix tomtom integration
  --[[if self and self.data and self.position.UIMapId and IsControlKeyDown() and TomTom and TomTom.AddWaypoint then
      -- tomtom integration (needs more work, will come with tracker
      if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
          TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
      end
      Questie.db.char._tom_waypoint = TomTom:AddWaypoint(self.position.UIMapId, self.x/100, self.y/100, {title = self.data.Name, crazy = true})
  elseif self.miniMapIcon then
      local _, _, _, x, y = self:GetPoint()
      Minimap:PingLocation(x, y)
  end]]--
end

---@param textureData TextureData
---@return string
local function GetName(textureData)
  if(textureData and textureData.targetId) then
    if(textureData.targetType == "monster") then
      return QuestieDB:GetNPC(textureData.targetId).name;
    elseif(textureData.targetType == "item") then
      return QuestieDB:GetItem(textureData.targetId).name;
    elseif(textureData.targetType == "object") then
      return QuestieDB:GetObject(textureData.targetId).name;
    elseif(textureData.targetType == "event") then
      return QuestieDB:GetQuest(textureData.questId).Objectives[textureData.objectiveIndex].Description or "Event Trigger";
    end
  end
  return "TYPE NOT IMPLEMENTED?";
end

function QuestieFrameNew.worldmapProviderPin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
  --Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseEnter", self.questData[1].Id, self.questData[1].name);


  local tooltips = {};
  ---@param texture IconTextureNew
  for _, texture in pairs(self.textures) do
    ---@type TextureData
    local textureData = texture.textureData;
    if(QuestieFrameNew.stringEnum["available"] == textureData.pinTypeId) then
      local name = GetName(textureData);
      if(not tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]]) then
        tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]] = {}
      end
      if(not tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]][name]) then
        tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]][name] = {}
      end
      ---@type AvailableTooltip
      local tooltipData = GetAvailableOrCompleteTooltip(textureData);
      table.insert(tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]][name], tooltipData);
    end
  end

  --[[for rawPinType, typeData in pairs(self.questData) do
    if(not tooltips[rawPinType]) then
      tooltips[rawPinType] = {}
    end
    if(rawPinType == "available" or rawPinType == "complete") then
      for index, questData in pairs(typeData) do
        local name = questData:GetName();
        if(not tooltips[rawPinType][name]) then
          tooltips[rawPinType][name] = {}
        end
        ---@type AvailableTooltip
        local tooltipData = GetAvailableOrCompleteTooltip(questData);
        table.insert(tooltips[rawPinType][name], GetAvailableOrCompleteTooltip(questData));
      end
    end
  end]]--

  local Tooltip = GameTooltip;
  Tooltip._owner = self;
  Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)
  function Tooltip:_Rebuild()
    local firstLine = true;
    local xpString = QuestieLocale:GetUIString('XP');
    local shift = IsShiftKeyDown()
    -- Print Available quests into the tooltip
    for name, tooltipData in pairs(tooltips["available"] or {}) do
      if(firstLine and not shift) then
          self:AddDoubleLine(name, "("..QuestieLocale:GetUIString('ICON_SHIFT_HOLD')..")", 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
          firstLine = false;
      elseif(firstLine and shift) then
          self:AddLine(name, 0.2, 1, 0.2);
          firstLine = false;
      else
          self:AddLine(name, 0.2, 1, 0.2);
      end
      ---@param questInfo AvailableTooltip
      for _, questInfo in pairs(tooltipData) do
        if questInfo.title ~= nil then
            local quest = QuestieDB:GetQuest(questInfo.questId)
            if(quest and shift) then
                local rewardString = ""
                local rewardXP = GetQuestLogRewardXP(questInfo.questId)
                if rewardXP > 0 then -- Quest rewards XP
                    rewardString = QuestieLib:PrintDifficultyColor(quest.level, "(".. rewardXP .. xpString .. ") ")
                end

                local moneyReward = GetQuestLogRewardMoney(questInfo.questId)
                if moneyReward > 0 then -- Quest rewards money
                    rewardString = rewardString .. Questie:Colorize("("..GetCoinTextureString(moneyReward)..") ", "white")
                end
                self:AddDoubleLine("   " .. questInfo.title, rewardString .. questInfo.type, 1, 1, 1, 1, 1, 0);
            else
                self:AddDoubleLine("   " .. questInfo.title, questInfo.type, 1, 1, 1, 1, 1, 0);
            end
        end
        if questInfo.description and shift then
            local dataType = type(questInfo.description)
            if dataType == "table" then
                for _, line in pairs(questInfo.description) do
                    self:AddLine("      " .. line, 0.86, 0.86, 0.86);
                end
            elseif dataType == "string" then
                self:AddLine("      " .. questInfo.description, 0.86, 0.86, 0.86);
            end
        end
      end
    end
    self:Show();
  end
  Tooltip:_Rebuild();

end

--Available / Complete
--local loc = {}
--loc.x = x;
--loc.y = y;
--loc.UIMapId = ZoneDataAreaIDToUiMapID[zone];
--loc.pinType = "available" / "complete";
--loc.questId = quest.Id;
--loc.targetType = "monster" / "object"
--loc.targetId = finisher.id;

---@param textureData TextureData
function GetAvailableOrCompleteTooltip(textureData)
  ---@class AvailableTooltip
  local tip = {};
  local quest = QuestieDB:GetQuest(textureData.questId);
  if(quest) then

    if textureData.pinTypeId == QuestieFrameNew.stringEnum["complete"] then
        tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_COMPLETE");
    else
        local questType, questTag = GetQuestTagInfo(textureData.questId);
        if(quest.Repeatable) then
            tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_REPEATABLE");--"(Repeatable)"; --
        elseif(questType == 81 or questType == 83 or questType == 62 or questType == 41 or questType == 1) then
            -- Dungeon or Legendary or Raid or PvP or Group(Elite)
            tip.type = "("..questTag..")";
        elseif(QuestieEvent and QuestieEvent.activeQuests[quest.Id]) then
            tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_EVENT");--"(Event)";--QuestieLocale:GetUIString("TOOLTIP_QUEST_AVAILABLE");
        else
            tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_AVAILABLE");
        end
    end
    tip.type = QuestieFrameNew.stringEnum[textureData.pinTypeId];
    tip.title = quest:GetColoredQuestName(true)
    tip.description = quest.Description
    tip.questId = quest.Id;
  end

  return tip;
end

function QuestieFrameNew.worldmapProviderPin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseLeave", self);
  if WorldMapTooltip then
      WorldMapTooltip:Hide()
      WorldMapTooltip._rebuild = nil
  end
  if GameTooltip then
      GameTooltip:Hide()
      GameTooltip._Rebuild = nil
  end
end

-- register with the world map
WorldMapFrame:AddDataProvider(QuestieFrameNew.worldmapProvider)
