local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

QuestieTracker = CreateFrame("Frame", "QuestieTracker", UIParent, "ActionButtonTemplate")

function QuestieTracker:OnEvent() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	QuestieTracker[event](QuestieTracker, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to Questie:event methods
end
QuestieTracker:SetScript("OnEvent", QuestieTracker.OnEvent)
QuestieTracker:RegisterEvent("PLAYER_LOGIN")
QuestieTracker:RegisterEvent("ADDON_LOADED")

local _QuestWatch_Update = QuestWatch_Update;
local _RemoveQuestWatch = RemoveQuestWatch;
local _IsQuestWatched = IsQuestWatched;
local _GetNumQuestWatches = GetNumQuestWatches;
local _AddQuestWatch = AddQuestWatch;
local _GetQuestIndexForWatch = GetQuestIndexForWatch;
local _QuestLogTitleButton_OnClick = QuestLogTitleButton_OnClick;

local function trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1");
end

function QuestieTracker:addQuestToTracker(questName, desc, typ, done, level, isComplete) -- should probably get a table of parameters
	if(type(QuestieCurrentQuests[questName]) ~= "table") then
		QuestieCurrentQuests[questName] = {};
	end
	if(type(QuestieCurrentQuests[questName].tracked) ~= "table") then
		QuestieCurrentQuests[questName]["tracked"] = {};
	end
	QuestieCurrentQuests[questName]["tracked"][desc] = true
	QuestieCurrentQuests[questName]["tracked"]["level"] = level
	QuestieCurrentQuests[questName]["tracked"]["isComplete"] = isComplete
end 

function QuestieTracker:removeQuestFromTracker(questName)
	QuestieCurrentQuests[questName]["tracked"] = nil
end

function QuestLogTitleButton_OnClick(button)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() ) then
			if(ChatFrameEditBox:IsVisible()) then
				ChatFrameEditBox:Insert(this:GetText());
			end
			-- add/remove quest to/from tracking
			QuestieTracker:setQuestInfo(Questie:findIdByName(trim(this:GetText())));
		end
		QuestLog_SetSelection(this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame))
		QuestLog_Update();
	end
	--_QuestLogTitleButton_OnClick(button)
	--QuestWatchFrame:Hide()
	this = QuestieTracker;
	this:fillTrackingFrame();
end

function Questie:findIdByName(name)
	for i=1,20 do
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if(name == questName) then
			return i;
		end	
	end
end

function QuestieTracker:isTracked(quest)
	if(type(quest) == "string") then
		if(QuestieCurrentQuests[quest] and QuestieCurrentQuests[quest]["tracked"] ~= nil) then
			return true;
		end	
	else
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(quest);
		if(QuestieCurrentQuests[questName]["tracked"] ~= nil) then
			return true;
		end	
	end
	return false;
end

function QuestieTracker:setQuestInfo(id)
	local questInfo = {};
	local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(id);
	SelectQuestLogEntry(id);
	
	if(QuestieTracker:isTracked(questName)) then
		QuestieTracker:removeQuestFromTracker(questName);
		return;
	end
	
	for i=1, GetNumQuestLeaderBoards() do
		local desc, typ, done = GetQuestLogLeaderBoard(i);
		QuestieTracker:addQuestToTracker(questName, desc, typ, done, level, isComplete)
	end
end

function QuestieTracker:PLAYER_LOGIN()
	this:createTrackingFrame();
	this:createTrackingButtons();
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("PLAYER_LOGOUT");
end

-- OBVIOUSLY NEEDS A MORE EFFECTIVE SYSTEM! In general, adding/removing notes and updating the visible elements needs to be handled better
-- it takes no strain on performance, but is still done terribly
function QuestieTracker:QUEST_LOG_UPDATE()
	for id=1, GetNumQuestLogEntries() do
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(id);
		if( this:isTracked(questName) ) then
			SelectQuestLogEntry(id);
			for i=1, GetNumQuestLeaderBoards() do
				local desc, typ, done = GetQuestLogLeaderBoard(i);
				this:addQuestToTracker(questName, desc, typ, done, level, isComplete)
			end
		end
	end
end

function QuestieTracker:ADDON_LOADED()
	if not ( QuestieTrackerVariables ) then
		QuestieTrackerVariables = {};
		QuestieTrackerVariables["position"] = {
			point = "CENTER",
			relativeTo = "UIParent",
			relativePoint = "CENTER",
			xOfs = 300,
			yOfs = 300,
		};
	end
end

function QuestieTracker:updateTrackingFrameSize()
	local frameHeight = 20;
	for i=1,8 do
		local button = getglobal("QuestieTrackerButton"..i);
		button:SetParent(this.frame);
		button:SetWidth(240);
		button:SetHeight(20);
		
		if(i == 1) then
			button:SetPoint("TOPLEFT", this.frame, "TOPLEFT", 5, -15);
			local height = 20;
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 12;
				end
			end
			button:SetHeight(height);
		else
			button:SetPoint("TOPLEFT", "QuestieTrackerButton"..i-1, "BOTTOMLEFT", 0, -5);
			local height = 20;
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 12;
				end
			end
			button:SetHeight(height);
		end
		frameHeight = frameHeight + button:GetHeight();
		this.frame.buttons[i] = button;
	end
	this.frame:SetHeight(frameHeight+40);
end

function QuestieTracker:clearTrackingFrame()
	for i=1, 8 do
		getglobal("QuestieTrackerButton"..i):Hide();
	end
end

function QuestieTracker:fillTrackingFrame()

	this:clearTrackingFrame();
	local sortedByDistance = {};
	local distanceControlTable = {};
	-- sort notes by distance before using this
	for k,v in (currentNotes) do
		--log(v["questName"] .. "  " .. v["distance"])
		if(QuestieCurrentQuests[v["questName"]] and QuestieCurrentQuests[v["questName"]]["tracked"] and v["icon"] ~= "Available") then
			if not (distanceControlTable[v["questName"]]) then
			distanceControlTable[v["questName"]] = true; 
			QuestieCurrentQuests[v["questName"]]["questName"] = v["questName"];
			QuestieCurrentQuests[v["questName"]]["formatDistance"] = v["formatDistance"];
			QuestieCurrentQuests[v["questName"]]["formatUnits"] = v["formatUnits"];
			table.insert(sortedByDistance, QuestieCurrentQuests[v["questName"]]);
			end
		end
	end
	
	local i = 1;
	for index,quest in pairs(sortedByDistance) do
		for k,v in pairs(quest) do
			if(k == "tracked") then
				getglobal("QuestieTrackerButton"..i):Show();
				local j = 1;
				for key,val in pairs(v) do
					if (key == "level") then
						getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("[" .. val .. "] " .. quest["questName"] .. " (" .. quest["formatDistance"] .. " " .. quest["formatUnits"] .. ")");
					elseif (key == "isComplete") then
					
					else
						getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):SetText(key);
						getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):Show();
						j = j + 1;
					end
				end
				i = i + 1;
			end
		end
	end
	this:updateTrackingFrameSize();
end

function QuestieTracker:createTrackingButtons()
	this.frame.buttons = {};
	local frameHeight = 20;
	for i=1,8 do
		local button = CreateFrame("Button", "QuestieTrackerButton"..i, this.frame, "QuestieTrackerButtonTemplate");
		button:SetParent(this.frame);
		button:SetWidth(240);
		button:SetHeight(8);
	
		if(i == 1) then
			button:SetPoint("TOPLEFT", this.frame, "TOPLEFT", 5, -15);
			local height = 8;
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 8;
				end
			end
			button:SetHeight(height);
		else
			button:SetPoint("TOPLEFT", "QuestieTrackerButton"..i-1, "BOTTOMLEFT", 0, -5);
			local height = 8;
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 8;
				end
			end
			button:SetHeight(height);
		end
		getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("QuestName");
		frameHeight = frameHeight + button:GetHeight();
		this.frame.buttons[i] = button;
	end
	this.frame:SetHeight(frameHeight+40);
	
	this:fillTrackingFrame();
end

function QuestieTracker:saveFramePosition()
	local frame = getglobal("QuestieTrackerFrame");
	local point, _, relativePoint, xOfs, yOfs = frame:GetPoint();
	-- receiving relativeTo causes wow to crash sometimes
	-- but the values are ALWAYS TOPLEFT, UIParent, TOPLEFT anyway
	QuestieTrackerVariables["position"] = {
		["point"] = point,
		["relativePoint"] = relativePoint,
		["relativeTo"] = "UIParent",
		["yOfs"] = yOfs,
		["xOfs"] = xOfs,
	};
end

function QuestieTracker:createTrackingFrame()
	this.frame = CreateFrame("Frame", "QuestieTrackerFrame", nil);
	this.frame:SetWidth(250);
	this.frame:SetHeight(400);
	this.frame:SetPoint(QuestieTrackerVariables["position"]["point"], QuestieTrackerVariables["position"]["relativeTo"], QuestieTrackerVariables["position"]["relativePoint"],
		QuestieTrackerVariables["position"]["xOfs"], QuestieTrackerVariables["position"]["yOfs"]);
	this.frame:SetAlpha(0.5)
	this.frame.texture = this.frame:CreateTexture(nil, "BACKGROUND");
	this.frame.texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
	this.frame.texture:SetAllPoints(this.frame);
	this.frame:Show();
	
	--this.frame:RegisterForDrag("LeftButton");
	this.frame:EnableMouse(true);
	this.frame:SetMovable(true);
	this.frame:SetScript("OnMouseDown", function()
		this:StartMoving();
	end);
	this.frame:SetScript("OnMouseUp", function()
		this:StopMovingOrSizing();
		this:SetUserPlaced(false);
		--can't call saveFramePosition because it RANDOMLY THROWS WOW ERRORS (WTF?)
		QuestieTracker:saveFramePosition()
	end);
end

--[[
Astrolabe/TomTom
local function getContPosition( zoneData, z, x, y )
	if ( z ~= 0 ) then
		zoneData = zoneData[z];
		x = x * zoneData.width + zoneData.xOffset;
		y = y * zoneData.height + zoneData.yOffset;
	else
		x = x * zoneData.width;
		y = y * zoneData.height;
	end
	return x, y;
end

local square_half = math.sqrt(0.5)
local rad_135 = math.rad(135)

local function rotateArrow(self)
	if self.disabled then return end

	local angle = Astrolabe:GetDirectionToIcon(self)
	if not angle then return self:Hide() end
	angle = angle + rad_135

	if GetCVar("rotateMinimap") == "1" then
		--local cring = MiniMapCompassRing:GetFacing()
        local cring = GetPlayerFacing()
		angle = angle - cring
	end

	local sin,cos = math.sin(angle) * square_half, math.cos(angle) * square_half
	self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
end
]]

