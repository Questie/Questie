QuestieFramePool = {...} -- GLobal Functions
local _QuestieFramePool = {...} --Local Functions
qNumberOfFrames = 0

local unusedframes = {}

local allframes = {}

--TODO: Add all types
ICON_TYPE_AVAILABLE = "Interface\\Addons\\QuestieDev-QuestieClassic\\Icons\\available.blp"
ICON_TYPE_SLAY = "Interface\\Addons\\QuestieDev-QuestieClassic\\Icons\\slay.blp"
ICON_TYPE_COMPLETE = "Interface\\Addons\\QuestieDev-QuestieClassic\\Icons\\complete.blp"
ICON_TYPE_ITEM = "Interface\\Addons\\QuestieDev-QuestieClassic\\Icons\\item.blp"
ICON_TYPE_LOOT = "Interface\\Addons\\QuestieDev-QuestieClassic\\Icons\\loot.blp"
ICON_TYPE_EVENT = "Interface\\Addons\\QuestieDev-QuestieClassic\\Icons\\event.blp"

-- Global Functions --
function QuestieFramePool:GetFrame()
	local f = tremove(unusedframes)
	if not f then
  	f = _QuestieFramePool:QuestieCreateFrame()
	end
	f.loaded = true;
	return f
end

--for i, frame in ipairs(allframes) do
--	if(frame.loaded == nil)then
--		return frame
--	end
--end

function QuestieFramePool:UnloadAll()

	Questie:Debug(DEBUG_DEVELOP, "[QuestieFramePool] Unloading all frames, count:", #allframes)
  for i, frame in ipairs(allframes) do
    --_QuestieFramePool:UnloadFrame(frame);
	frame:Unload()
  end
	qQuestIdFrames = {}
end


-- Local Functions --

--[[Use FRAME.Unload(FRAME) on frame object to unload!
function _QuestieFramePool:UnloadFrame(frame)
	--We are reseting the frames, making sure that no data is wrong.
  HBDPins:RemoveMinimapIcon(Questie, frame);
  HBDPins:RemoveWorldMapIcon(Questie, frame);
  frame.data = nil; -- Just to be safe
  frame.loaded = nil;
	table.insert(unusedframes, frame)
end]]--

function _QuestieFramePool:QuestieCreateFrame()
	qNumberOfFrames = qNumberOfFrames + 1
	local f = CreateFrame("Button","QuestieFrame"..qNumberOfFrames,nil)
	if(qNumberOfFrames > 5000) then
		Questie:Debug(DEBUG_CRITICAL, "[QuestieFramePool] Over 5000 frames... maybe there is a leak?", qNumberOfFrames)
	end
  f:SetFrameStrata("TOOLTIP");
	f:SetWidth(16) -- Set these to whatever height/width is needed
	f:SetHeight(16) -- for your Texture
	local t = f:CreateTexture(nil,"TOOLTIP")
	--t:SetTexture("Interface\\Icons\\INV_Misc_Eye_02.blp")
	--t:SetTexture("Interface\\Addons\\!Questie\\Icons\\available.blp")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetAllPoints(f)
	f.texture = t;
	f:SetPoint("CENTER",0,0)
	f:EnableMouse()
	--f:SetScript('OnEnter', function() Questie:Print("Enter") end)
	--f:SetScript('OnLeave', function() Questie:Print("Leave") end)

  f:SetScript("OnEnter", function(self) _QuestieFramePool:Questie_Tooltip(self) end); --Script Toolip
  f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
  f:SetScript("OnClick", function(self) _QuestieFramePool:Questie_Click(self) end);
  --f.Unload = function(frame) _QuestieFramePool:UnloadFrame(frame) end;
  function f:Unload()
	  --We are reseting the frames, making sure that no data is wrong.
	  HBDPins:RemoveMinimapIcon(Questie, self);
	  HBDPins:RemoveWorldMapIcon(Questie, self);
	  self.data = nil; -- Just to be safe
	  self.loaded = nil;
	  table.insert(unusedframes, self)
  end
  f.data = {}
  f:Hide()
	table.insert(allframes, f)
	return f
end

function _QuestieFramePool:euclid(x, y, i, e)
  local xd = math.abs(x-i);
  local yd = math.abs(y-e);
  return math.sqrt(xd*xd+yd*yd);
end

function _QuestieFramePool:Questie_Tooltip(self)
  local Tooltip = GameTooltip;
  Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

  for k,v in pairs(self.data.tooltip) do
	Tooltip:AddLine(v);
  end
  local maxDistCluster = 2
  local mid = WorldMapFrame:GetMapID();
  if mid == 947 then -- world
    maxDistCluster = 16
  elseif mid == 1415 or mid == 1414 then -- kalimdor/ek
    maxDistCluster = 8
  end
  local already = {};
  if self.data.tooltip == nil then return; end
  already[table.concat(self.data.tooltip)] = true
  -- iterate frames and add nearby to the tooltip also. TODO: Add all nearby to a table and sort by type
	for questId, framelist in pairs(qQuestIdFrames) do
	 for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
	    local icon = _G[frameName];
		if icon.data.x ~= nil and icon.data.AreaID == self.data.AreaID then
		  local dist = _QuestieFramePool:euclid(icon.data.x, icon.data.y, self.data.x, self.data.y);
		  if dist < maxDistCluster and icon.data.tooltip ~= nil then
			local key = table.concat(icon.data.tooltip);
			if already[key] == nil then
			  already[key] = true
			  for k,v in pairs(icon.data.tooltip) do
				Tooltip:AddLine(v);
			  end
			end
		  end
		end
	  end
	end
  
  
--	if(self.data.QuestData) then
--	  --TODO Logic for tooltip!
--	  Tooltip:AddLine("["..self.data.QuestData.Level.."] "..self.data.QuestData.Name);
--	  if(self.data.Starter.Type == "NPC") then
--	    Tooltip:AddLine("Started by: "..self.data.Starter.Name);
--	    -- Preferably call something outside, keep it "abstract" here
--	  end
--	elseif(self.data.NpcData) then
--		Tooltip:AddLine(self.data.NpcData.Name)
--	end


  Tooltip:SetFrameStrata("TOOLTIP");
  QuestieTooltips.lastTooltipTime = GetTime() -- hack for object tooltips
  Tooltip:Show();
end

function _QuestieFramePool:Questie_Click(self)
  Questie:Print("Click!");
  --TODO Logic for click!
  -- Preferably call something outside, keep it "abstract" here
end
