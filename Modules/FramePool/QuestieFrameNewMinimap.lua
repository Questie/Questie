---@class QuestieFrameNewMinimap
local QuestieFrameNewMinimap = QuestieLoader:CreateModule("QuestieFrameNewMinimap");
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

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

--[x
QuestieFrameNewMinimap.allMinimapIcons = {}


function QuestieFrameNewMinimap:ProcessShownMinimapIcons()
  ---@param minimapFrame IconFrame
  for minimapFrame, data in pairs(HBDPins.activeMinimapPins or {}) do
      if (minimapFrame.FadeLogic and minimapFrame.minimapFrame) then
          minimapFrame:FadeLogic()
      end
  end
end
QuestieFrameNewMinimap.fadeLogicTimerShown = C_Timer.NewTicker(0.3, QuestieFrameNewMinimap.ProcessShownMinimapIcons);

----------------
---Pools
----------------

local texturePool = CreateTexturePool(Minimap);
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

-------------------------------------------------------------------------------------------
-- WorldMap data provider
local frameId = 0;
--Used in my fadelogic.
local fadeOverDistance = 10;
-- setup pin pool
--AcquirePin runs framepool:Acquire which runs this function
QuestieFrameNewMinimap.iconPool = CreateFramePool("BUTTON");
QuestieFrameNewMinimap.iconPool.parent = Minimap
QuestieFrameNewMinimap.iconPool.creationFunc = function(framePool)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNewMinimap] Creating frame from pool");
    local frame = CreateFrame(framePool.frameType, nil, framePool.parent)
    frame:SetSize(16,16);
    frame.frameId = frameId;
    frame.minimapFrame = true;

    --- Data members
    frame.questData = {}
    frame.textures = {}
    frame.index = -1;

    frame.position = {}
    frame.position.centerX = -1;
    frame.position.centerY = -1;
    frame.position.x = -1;
    frame.position.y = -1;
    frame.position.UIMapId = -1;

    ---Functions
    frame:RegisterForClicks("RightButtonUp", "LeftButtonUp");
    frame:SetScript("OnClick", QuestieFrameNewMinimap.OnClick);
    frame:SetScript("OnEnter", QuestieFrameNewMinimap.OnMouseEnter);
    frame:SetScript("OnLeave", QuestieFrameNewMinimap.OnMouseLeave);

    --Fade logic 
    function frame:FadeLogic()
      Questie:Print(self.minimapFrame, self.position.x, self.position.y, self.textures, self.position.UIMapId, HBD, HBD.GetPlayerWorldPosition, QuestieLib, QuestieLib.Euclid)
        if self.minimapFrame and self.position.x and self.position.y and self.textures and self.position.UIMapId and HBD and HBD.GetPlayerWorldPosition and QuestieLib and QuestieLib.Euclid then
            local playerX, playerY, playerInstanceID = HBD:GetPlayerWorldPosition()
            if(playerX and playerY) then
                local x, y, instance = HBD:GetWorldCoordinatesFromZone(self.position.x, self.position.y, self.position.UIMapId);
                if(x and y) then
                    local distance = QuestieLib:Euclid(playerX, playerY, x, y);

                    --Very small value before, hard to work with.
                    distance = distance / 10

                    local normalizedValue = 1 / fadeOverDistance; --Opacity / Distance to fade over

                    if(distance > Questie.db.global.fadeLevel) then
                        local fadeAmount = 1 - (math.min(10, (distance-Questie.db.global.fadeLevel)) * normalizedValue);
                        for textureIndex, texture in pairs(self.textures) do
                          if(texture.SetVertexColor) then --We might have fake textures...
                            texture:SetVertexColor(texture.r, texture.g, texture.b, fadeAmount)
                            if texture.glowTexture then
                                texture.glowTexture:SetVertexColor(texture.glowTexture.r,texture.glowTexture.g,texture.glowTexture.b, fadeAmount)
                            end
                          end
                        end
                    elseif (distance < Questie.db.global.fadeOverPlayerDistance) and Questie.db.global.fadeOverPlayer then
                        local fadeAmount = QuestieLib:Remap(distance, 0, Questie.db.global.fadeOverPlayerDistance, Questie.db.global.fadeOverPlayerLevel, 1);
                        -- local fadeAmount = math.max(fadeAmount, 0.5);
                        if fadeAmount > Questie.db.global.iconFadeLevel then
                            fadeAmount = Questie.db.global.iconFadeLevel
                        end
                        for textureIndex, texture in pairs(self.textures) do
                          if(texture.SetVertexColor) then --We might have fake textures...
                            texture:SetVertexColor(texture.r, texture.g, texture.b, fadeAmount)
                            if texture.glowTexture then
                                texture.glowTexture:SetVertexColor(texture.glowTexture.r,texture.glowTexture.g,texture.glowTexture.b, fadeAmount)
                            end
                          end
                        end
                    else
                        for textureIndex, texture in pairs(self.textures) do
                          if(texture.SetVertexColor) then --We might have fake textures...
                            texture:SetVertexColor(texture.r, texture.g, texture.b, 1)
                            if texture.glowTexture then
                                texture.glowTexture:SetVertexColor(texture.glowTexture.r,texture.glowTexture.g,texture.glowTexture.b, 1)
                            end
                          end
                        end
                    end
                end
            else
              for textureIndex, texture in pairs(self.textures) do
                if(texture.SetVertexColor) then --We might have fake textures...
                  texture:SetVertexColor(texture.r, texture.g, texture.b, 1)
                  if texture.glowTexture then
                      texture.glowTexture:SetVertexColor(texture.glowTexture.r,texture.glowTexture.g,texture.glowTexture.b, 1)
                  end
                end
              end
            end
        end
    end

    frameId = frameId + 1;
    return frame
end

QuestieFrameNewMinimap.iconPool.resetterFunc = function(pinPool, pin)
    FramePool_HideAndClearAnchors(pinPool, pin)
    pin.questData = {}
    --release the textures.
    if(pin.textures) then
      for index, tex in pairs(pin.textures) do
        if(tex.glowTexture) then
          texturePool:Release(tex.glowTexture);
          tex.glowTexture = nil;
        end
        texturePool:Release(tex);
      end
    end
    pin.textures = {};
    pin.index = -1;
    pin.position = {}

end


function QuestieFrameNewMinimap:RefreshAllData(iconListData)
  Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNewMinimap]", "RefreshAllData");
  local precision = 500;
  ---@type table<number, IconMinimap>
  local iconsToAdd = {}
  for iconIndex, data in pairs(iconListData) do
    local questData, centerX, centerY, x, y, UIMapId = unpack(data);
    local index = math.floor(centerX*precision) * (precision/100) + math.floor(centerY*precision)

    if(not QuestieFrameNewMinimap.allMinimapIcons[index]) then
      Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNewMinimap]", "Adding icon:", index, x, y);
      ---@class miniDataObject
      local miniDataObject = {}
      miniDataObject.questData = questData;
      miniDataObject.centerX = centerX;
      miniDataObject.centerY = centerY;
      miniDataObject.x = x;
      miniDataObject.y = y;
      miniDataObject.UIMapId = UIMapId;
      miniDataObject.newIcon = true;
      miniDataObject.index = index;
      iconsToAdd[index] = miniDataObject;
    else
      Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNewMinimap]", "Existing icon:",index, x, y);
      iconsToAdd[index] = QuestieFrameNewMinimap.allMinimapIcons[index];
      QuestieFrameNewMinimap.allMinimapIcons[index] = nil;
    end
  end
  --Icons that should be removed.
  ---@param frame IconMinimap
  for iconIndex, frame in pairs(QuestieFrameNewMinimap.allMinimapIcons) do
    Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNewMinimap]", "Removing icon:", frame.index);
    HBDPins:RemoveMinimapIcon(Questie, frame);
    QuestieFrameNewMinimap.iconPool:Release(frame);
    QuestieFrameNewMinimap.allMinimapIcons[iconIndex] = nil;
  end
  --Add the new icons to the minimap
  ---@param frame IconMinimap|miniDataObject
  for iconIndex, frame in pairs(iconsToAdd) do
    if(frame.newIcon) then
      --In here its a miniDataObject not a IconMinimap
      --The reason for this is because we want to acquire the pins AFTER we destroyed the previous ones
      --This lowers the amount of frames in use.
      local newFrame = QuestieFrameNewMinimap:AcquirePin(frame.questData, frame.centerX, frame.centerY, frame.x, frame.y, frame.UIMapId);
      Questie:Debug(DEBUG_ELEVATED, "[QuestieFrameNewMinimap]", "Spawning icon:", frame.index, frame.position.x, frame.position.y, frame.position.UIMapId);
      HBDPins:AddMinimapIconMap(Questie, newFrame, newFrame.position.UIMapId, newFrame.position.x, newFrame.position.y, true, true);
      --newFrame:Show();
      --None of these should actually need to be set... but it would break hard if it was left so lets be safe.
      frame.newFrame = nil;
      newFrame.newIcon = nil;
      QuestieFrameNewMinimap.allMinimapIcons[iconIndex] = newFrame;
    end
  end
end

---@param questData table
---@param centerX number
---@param centerY number
---@param x number
---@param y number
---@param UIMapId number
---@return IconMinimap
function QuestieFrameNewMinimap:AcquirePin(questData, centerX, centerY, x, y, UIMapId)
  ---@class IconMinimap
  local frame = QuestieFrameNewMinimap.iconPool:Acquire();
  frame.questData = questData;
  frame.position.centerX = centerX;
  frame.position.centerY = centerY;
  frame.position.x = x;
  frame.position.y = y;
  frame.position.UIMapId = UIMapId;

  --TODO: Set texture here all this is temporary
  local newTexture = texturePool:Acquire()
  --newTexture.textureData = textureData;

  --newTexture:SetTexture(typeLookup[textureData.pinTypeId].GetIcon(textureData.questId));
  newTexture:SetParent(frame);
  newTexture:SetPoint("CENTER", frame, "CENTER", 0, 0);
  --if(Questie.db.global.questObjectiveColors) then
  --  newTexture:SetVertexColor(unpack(textureData.color));
  --end
  newTexture:SetSize(16,16);
  --newTexture:SetSize((16 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale, (16 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale)

  --[[if(textureData.pinTypeId ~= QuestieFrameNew.stringEnum["available"] and textureData.pinTypeId ~= QuestieFrameNew.stringEnum["complete"] and Questie.db.global.alwaysGlowMap) then
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
  end]]--
  newTexture:Show();

  table.insert(frame.textures, newTexture);

  return frame;
end


function QuestieFrameNewMinimap:OnMouseEnter()

end

function QuestieFrameNewMinimap:OnMouseLeave()

end

function QuestieFrameNewMinimap:OnClick(button)

end