QuestieFrame = {...} -- GLobal Functions
local _QuestieFrame = {...} --Local Functions
local NumberOfFrames = 0
local allframes = {}



-- Global Functions --
function QuestieFrame:GetFrame()
	for i, frame in ipairs(allframes) do
    if(frame.loaded == nil)then
      frame.loaded = true;
      return frame
    end
	end
  local Note = _QuestieFrame:QuestieCreateFrame()
  Note.loaded = true;
	return Note
end




-- Local Functions --

function _QuestieFrame:UnloadAll()
  for i, frame in ipairs(allframes) do
    QuestieFrame:UnloadFrame(frame);
  end
end

--Use FRAME.Unload(FRAME) on frame object to unload!
function _QuestieFrame:UnloadFrame(frame)
  HBDPins:RemoveMinimapIcon(Questie, frame);
  HBDPins:RemoveWorldMapIcon(Questie, frame);
  frame.data.QuestID = nil; -- Just to be safe
  frame.loaded = nil;
end

function _QuestieFrame:QuestieCreateFrame()
	NumberOfFrames = NumberOfFrames + 1
	local f = CreateFrame("Button","QuestieFrame"..NumberOfFrames,nil)
  f:SetFrameStrata("TOOLTIP");
	f:SetWidth(16) -- Set these to whatever height/width is needed
	f:SetHeight(16) -- for your Texture
	local t = f:CreateTexture(nil,"TOOLTIP")
	--t:SetTexture("Interface\\Icons\\INV_Misc_Eye_02.blp")
	t:SetTexture("Interface\\Addons\\QuestieClassic\\Icons\\available.blp")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetAllPoints(f)
	f:SetPoint("CENTER",0,0)
	f:EnableMouse()
	--f:SetScript('OnEnter', function() Questie:Print("Enter") end)
	--f:SetScript('OnLeave', function() Questie:Print("Leave") end)

  f:SetScript("OnEnter", function(self) _QuestieFrame:Questie_Tooltip(self) end); --Script Toolip
  f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
  f:SetScript("OnClick", function(self) _QuestieFrame:Questie_Click(self) end);
  f.Unload = function(frame) _QuestieFrame:UnloadFrame(frame) end;
  f.data = {}
	table.insert(allframes, f)
  f:Hide();
	return f
end


function _QuestieFrame:Questie_Tooltip(self)
  local Tooltip = GameTooltip;
  Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

  --TODO Logic for tooltip!
  Tooltip:AddLine("Tooltip!");
  Tooltip:AddLine(self.data.QuestID);
  -- Preferably call something outside, keep it "abstract" here


  Tooltip:SetFrameStrata("TOOLTIP");
  Tooltip:Show();
end

function _QuestieFrame:Questie_Click(self)
  Questie:Print("Click!");
  --TODO Logic for click!
  -- Preferably call something outside, keep it "abstract" here
end
