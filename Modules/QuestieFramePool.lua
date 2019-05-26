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
	if f ~= nil and f.hidden and f._show ~= nil and f._hide ~= nil then -- restore state to normal (toggle questie)
	  icon.hidden = false
	  icon.Show = icon._show;
	  icon.Hide = icon._hide;
	end
	if f.IsShowing ~= nil and f:IsShowing() then
	  f:Hide();
	end
	f.loaded = true;
	f.shouldBeShowing = false;
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
	f:EnableMouse(true)--f:EnableMouse()
	--f.mouseIsOver = false;
	--f:SetScript("OnUpdate", function() 
	--  local mo = MouseIsOver(self); -- function exists in classic but crashes the game
	--  if mo and (not f.mouseIsOver) then
	--    f.mouseIsOver = true
	--	_QuestieFramePool:Questie_Tooltip(self)
	--  elseif (not mo) and f.mouseIsOver then
	--    f.mouseIsOver = false
	--	if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end
	--  end
	--end)
	
	--f:SetScript('OnEnter', function() Questie:Print("Enter") end)
	--f:SetScript('OnLeave', function() Questie:Print("Leave") end)

  f:SetScript("OnEnter", function(self) _QuestieFramePool:Questie_Tooltip(self) end); --Script Toolip
  f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
  f:SetScript("OnClick", function(self) 
    --_QuestieFramePool:Questie_Click(self) 
	if self and self.data and self.data.UiMapID and WorldMapFrame and WorldMapFrame:IsShown() and self.data.UiMapID ~= WorldMapFrame:GetMapID() then
	  WorldMapFrame:SetMapID(self.data.UiMapID);
	end
  end);
  --f.Unload = function(frame) _QuestieFramePool:UnloadFrame(frame) end;
  function f:Unload()
	  --We are reseting the frames, making sure that no data is wrong.
	  HBDPins:RemoveMinimapIcon(Questie, self);
	  HBDPins:RemoveWorldMapIcon(Questie, self);
	  if(self.texture) then
		  self.texture:SetVertexColor(1,1,1,1);
	  end
	  self.miniMapIcon = nil;
	  self:Hide();
	  self.data = nil; -- Just to be safe
	  self.loaded = nil;
	  table.insert(unusedframes, self)
  end
  f.data = {}
  f:Hide()
	table.insert(allframes, f)
	return f
end

function QuestieFramePool:euclid(x, y, i, e)
  local xd = math.abs(x-i);
  local yd = math.abs(y-e);
  return math.sqrt(xd*xd+yd*yd);
end

_QuestieFramePool.lastTooltipShowHack = GetTime()
function _QuestieFramePool:Questie_Tooltip(self)
  if GetTime() - _QuestieFramePool.lastTooltipShowHack < 0.05 and GameTooltip:IsShown() then
    return
  end
  _QuestieFramePool.lastTooltipShowHack = GetTime()
  local Tooltip = GameTooltip;
  Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)

  local maxDistCluster = 1
  local mid = WorldMapFrame:GetMapID();
  if mid == 947 then -- world
    maxDistCluster = 8
  elseif mid == 1415 or mid == 1414 then -- kalimdor/ek
    maxDistCluster = 4
  end
  if not WorldMapFrame:IsShown() then -- this should check if its a minimap note or map note instead, some map addons dont use WorldMapFrame
    maxDistCluster = 0.5
  end
  
  local already = {}; -- per quest
  local alreadyUnique = {}; -- per objective
  
  if self.data.tooltip == nil then return; end
  
  local headers = {};
  local footers = {};
  local contents = {};
  
  -- TODO: change how the logic works, so this can be nil
  if self.data.ObjectiveIndex == nil then -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an integer here for duplicate checks
    self.data.ObjectiveIndex = 0
  end
  
  --for k,v in pairs(self.data.tooltip) do
	--Tooltip:AddLine(v);
  --end

  --iterate and add non-objective notes
    local npcOrder = {};
	for questId, framelist in pairs(qQuestIdFrames) do
	 for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
		local icon = _G[frameName];
		if icon ~= nil and icon.data ~= nil and icon.data.x ~= nil and icon.data.AreaID == self.data.AreaID then
		  local dist = QuestieFramePool:euclid(icon.data.x, icon.data.y, self.data.x, self.data.y);
		  if dist < maxDistCluster and icon.data.tooltip ~= nil then
			local key = table.concat(icon.data.tooltip);
			if already[key] == nil then
			  if alreadyUnique[icon.data.Id] == nil then
				alreadyUnique[icon.data.Id] = {};
			  end
			  -- TODO: change how the logic works, so this can be nil
			  if icon.data.ObjectiveIndex == nil then -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an integer here for duplicate checks
				icon.data.ObjectiveIndex = 0
			  end
			  if (not icon.data.IsObjectiveNote) and alreadyUnique[icon.data.Id][icon.data.ObjectiveIndex] == nil then
				alreadyUnique[icon.data.Id][icon.data.ObjectiveIndex] = true
				already[key] = true
				if icon.data.tooltip ~= nil and icon.data.tooltip[2] ~= nil then
				  if npcOrder[icon.data.tooltip[2]] == nil then
				    npcOrder[icon.data.tooltip[2]] = {};
				  end
				  local dat = {};
				  dat.title = icon.data.tooltip[1];
				  if icon.data.Icon == ICON_TYPE_COMPLETE then
				    dat.type = "(Complete)";
				  else
				    dat.type = "(Available)";
				  end
				  table.insert(npcOrder[icon.data.tooltip[2]], dat);
				end
				--for k,v in pairs(icon.data.tooltip) do
				--  Tooltip:AddLine(v);
				--end
			  end
			end
		  end
		end
	  end
	end
	
	for k,v in pairs(npcOrder) do -- this logic really needs to be improved
	  Tooltip:AddLine(k);
	  for k2,v2 in pairs(v) do
	    if v2.title ~= nil then 
	      Tooltip:AddDoubleLine("   " .. v2.title, v2.type);
		end
	  end
	  
	end
  
    -- iterate frames and add nearby to the tooltip also. TODO: Add all nearby to a table and sort by type
	for questId, framelist in pairs(qQuestIdFrames) do
	 for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
	    local icon = _G[frameName];
		if icon ~= nil and icon.data ~= nil and icon.data.x ~= nil and icon.data.AreaID == self.data.AreaID then
		  local dist = QuestieFramePool:euclid(icon.data.x, icon.data.y, self.data.x, self.data.y);
		  if dist < maxDistCluster and icon.data.tooltip ~= nil then
			local key = table.concat(icon.data.tooltip);
			if already[key] == nil then
			  already[key] = true
			  if alreadyUnique[icon.data.Id] == nil then
			    alreadyUnique[icon.data.Id] = {};
			  end
			  -- TODO: change how the logic works, so this can be nil
			  if icon.data.ObjectiveIndex == nil then -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an integer here for duplicate checks
				icon.data.ObjectiveIndex = 0
			  end
			  if icon.data.IsObjectiveNote and alreadyUnique[icon.data.Id][icon.data.ObjectiveIndex] == nil then
				
			    alreadyUnique[icon.data.Id][icon.data.ObjectiveIndex] = true
			    --if icon.data.Icon == ICON_TYPE_LOOT then -- logic needs to be improved
			    --  table.insert(headers, icon.data.tooltip[1]);
			    --end
			    table.insert(contents, icon.data.tooltip[3]);
			    table.insert(contents, icon.data.tooltip[2]);
			  end
			  --table.insert(footers, icon.data.tooltip[3]);
			  --for k,v in pairs(icon.data.tooltip) do
				--Tooltip:AddLine(v);
			  --end
			end
		  end
		end
	  end
	end
	
	local maxLines = 4;
	already = {}; -- is there a table.clear that is faster?
	for k,v in pairs(headers) do
	  if already[v] == nil and maxLines > 0 then
	    Tooltip:AddLine(v);
		already[v] = true
		maxLines = maxLines - 1
	  end
	end
	already = {};
	maxLines = 20;
	for k,v in pairs(contents) do
	  if already[v] == nil and maxLines > 0 then
	    Tooltip:AddLine(v);
		already[v] = true
		maxLines = maxLines - 1
	  end
	end
	already = {}; 
	maxLines = 20;
	for k,v in pairs(footers) do
	  if already[v] == nil and maxLines > 0 then
	    Tooltip:AddLine(v);
		already[v] = true
		maxLines = maxLines - 1
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

  
  
  --if GameTooltipTextLeft1 ~= nil and GameTooltipTextLeft1.SetScale ~= nil then
    --GameTooltipTextLeft1:SetScale(0.89)
  --end
  --if GameTooltipTextRight1 ~= nil and GameTooltipTextRight1.SetScale ~= nil then
    --GameTooltipTextRight1:SetScale(0.89)
  --end
  Tooltip:Show();
  -- this might be bad? Without it, the line never resets to its proper size
  --if Tooltip._hide == nil then
	--  Tooltip._hide = Hide
	--  Tooltip.Hide = function()
	--	if GameTooltipTextLeft1 ~= nil and GameTooltipTextLeft1.SetScale ~= nil then
	--	  GameTooltipTextLeft1:SetScale(1)
	--	end
	--	if GameTooltipTextRight1 ~= nil and GameTooltipTextRight1.SetScale ~= nil then
	--	  GameTooltipTextRight1:SetScale(1)
	--	end
	--	Tooltip.Hide = Tooltip._hide;
	--	Tooltip._hide = nil;
	--	Tooltip:Hide();
	--  end
  --end
end

function _QuestieFramePool:Questie_Click(self)
  Questie:Print("Click!");
  --TODO Logic for click!
  -- Preferably call something outside, keep it "abstract" here
end
