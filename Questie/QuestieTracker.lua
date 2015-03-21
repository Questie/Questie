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
		if(QuestieCurrentQuests[quest]["tracked"] ~= nil) then
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
end

function QuestieTracker:ADDON_LOADED()
	if not ( QuestieTrackerFrameVariables ) then
		QuestieTrackerFrameVariables = {};
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
	local i = 1;
	for ke,va in pairs(QuestieCurrentQuests) do
		for k,v in pairs(va) do
			if(k == "tracked") then
				getglobal("QuestieTrackerButton"..i):Show();
				local j = 1;
				for key,val in pairs(v) do
					if (key == "level") then
						getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("[" .. val .. "] " .. ke);
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
		getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("QuestName");
		frameHeight = frameHeight + button:GetHeight();
		this.frame.buttons[i] = button;
	end
	this.frame:SetHeight(frameHeight+40);
	
	this:fillTrackingFrame();
end

function QuestieTracker:createTrackingFrame()
	this.frame = CreateFrame("Frame", "QuestieTrackerFrame", UIParent);
	this.frame:SetWidth(250);
	this.frame:SetHeight(400);
	if ( QuestieTrackerFrameVariables["position"] ) then
		this.frame:SetPoint(QuestieTrackerFrameVariables["position"]["point"], QuestieTrackerFrameVariables["position"]["relativeTo"],
		QuestieTrackerFrameVariables["position"]["relativePoint"], QuestieTrackerFrameVariables["position"]["xOfs"], QuestieTrackerFrameVariables["position"]["yOfs"]);
	else
		this.frame:SetPoint("CENTER", 300, 300);
	end
	this.frame:SetAlpha(0.5)
	this.frame.texture = this.frame:CreateTexture(nil, "BACKGROUND");
	this.frame.texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
	this.frame.texture:SetAllPoints(this.frame);
	this.frame:Show();
	
	this.frame:RegisterForDrag("LeftButton");
	this.frame:EnableMouse(true);
	this.frame:SetMovable(true);
	this.frame:SetScript("OnDragStart", function()
		this:StartMoving();
	end);
	this.frame:SetScript("OnDragStop", function()
		this:StopMovingOrSizing();
		QuestieTracker.frame:SetUserPlaced(false);
		QuestieTrackerFrameVariables["position"] = {};
		local point, relativeTo, relativePoint, xOfs, yOfs = QuestieTracker.frame:GetPoint();
		QuestieTrackerFrameVariables["position"]["point"] = point;
		QuestieTrackerFrameVariables["position"]["relativeTo"] = relativeTo;
		QuestieTrackerFrameVariables["position"]["relativePoint"] = relativePoint;
		QuestieTrackerFrameVariables["position"]["xOfs"] = xOfs;
		QuestieTrackerFrameVariables["position"]["yOfs"] = yOfs;
	end);
end


