QuestieFrame = {...} -- GLobal Functions
local _QuestieFrame = {...} --Local Functions
local NumberOfFrames = 0
local allframes = {}



-- Global Functions --

function QuestieFrame:GetFrame()
	for i, frame in ipairs(allframes) do

	end
  local Note = _QuestieFrame:QuestieCreateFrame()
	return Note
end

-- Local Functions --

function _QuestieFrame:QuestieCreateFrame()
	NumberOfFrames = NumberOfFrames + 1
	local f = CreateFrame("Button","QuestieFrame"..NumberOfFrames,nil)
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

	table.insert(allframes, f)
	return f
end


function _QuestieFrame:Questie_Tooltip(self)
  local Tooltip = GameTooltip;
  Questie:Print(self.data.QuestID)
  Questie:Print(self)
  Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

  --TODO Logic for tooltip!
  Tooltip:AddLine("Tooltip!");
  -- Preferably call something outside, keep it "abstract" here


  Tooltip:SetFrameStrata("TOOLTIP");
  Tooltip:Show();
end

function _QuestieFrame:Questie_Click(self)
  Questie:Print("Click!");
  --TODO Logic for click!
  -- Preferably call something outside, keep it "abstract" here
end
