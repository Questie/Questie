

local HBD = LibStub("HereBeDragonsQuestie-2.0")


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
  --We save the colors to the texture object, this way we don't need to use GetVertexColor
  texture:SetVertexColor(1,1,1,1);
  texture:SetTexelSnappingBias(0)
  texture:SetSnapToPixelGrid(false)

  return texture
end

texturePool.resetterFunc = function(texPool, texture)
  TexturePool_HideAndClearAnchors(texPool, texture)
  texture:SetVertexColor(1,1,1,1);
end


local function AcquireTextures(frame)

  --- Textures
  local newTexture = texturePool:Acquire();

  newTexture:SetTexture(ICON_TYPE_SLAY)
  newTexture:SetParent(frame);
  newTexture:SetPoint("CENTER", frame, "CENTER", -8, -8);
  newTexture:SetSize(16, 16)
  newTexture:Show();

  ---@class IconTexture
  frame.texture = newTexture;


  local glowt = texturePool:Acquire();
  glowt:SetTexture(ICON_TYPE_GLOW)
  glowt:SetDrawLayer("OVERLAY", -1)
  glowt:SetParent(frame);
  glowt:SetPoint("CENTER", frame, "CENTER", -9, -9);
  glowt:SetSize(18, 18)
  glowt:Show();

  frame.glowTexture = glowt

end

local function ReleaseTextures(frame)
  if(frame.glowTexture) then
    texturePool:Release(frame.glowTexture);
  end
  if(frame.texture) then
    texturePool:Release(frame.texture);
  end
end



local iconPool = CreateFramePool("FRAME");
local worldmapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)
local worldmapProviderPin  = CreateFromMixins(MapCanvasPinMixin)

-------------------------------------------------------------------------------------------
-- WorldMap data provider
local frameId = 0;
-- setup pin pool
--AcquirePin runs framepool:Acquire which runs this function
iconPool.parent = WorldMapFrame:GetCanvas()
iconPool.creationFunc = function(framePool)
    local frame = CreateFrame(framePool.frameType, nil, framePool.parent)

    --- Data members
    frame.questData = {}
    frame.frameId = frameId;

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
  --1438
  local xCoord, yCoord, instanceID = HBD:GetWorldCoordinatesFromZone(0.1, 0.1, 1438)
  local x, y = HBD:GetZoneCoordinatesFromWorld(xCoord, yCoord, 1438)
  self:GetMap():AcquirePin("PinsTemplateQuestie", "tets", x, y);--data.frameLevelType)
end

--  map pin base API
function worldmapProviderPin:OnLoad()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnLoad");
  self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
  self:SetScalingLimits(1, 1.0, 1.2)
end

function worldmapProviderPin:OnAcquired(icon, x, y, frameLevelType)
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnAcquired", icon, x, y);
  self:UseFrameLevelType(frameLevelType or "PIN_FRAME_LEVEL_AREA_POI")
  self:SetPosition(x, y)

  AcquireTextures(self);

  --self.icon = icon
  --icon:SetParent(self)
  --icon:ClearAllPoints()
  --icon:SetPoint("CENTER", self, "CENTER")
  --icon:Show()
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
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseEnter", self);
end
function worldmapProviderPin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseLeave", self);
end

-- register with the world map
WorldMapFrame:AddDataProvider(worldmapProvider)
