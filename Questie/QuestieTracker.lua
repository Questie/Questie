local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

QuestieTracker = CreateFrame("Frame", "QuestieTracker", UIParent, "ActionButtonTemplate")

function QuestieTracker:OnEvent() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	QuestieTracker[event](QuestieTracker, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to Questie:event methods
end

function QuestieTracker_OnUpdate()
	if(EQL3_QuestWatchFrame) then
		EQL3_QuestWatchFrame:Hide();
	end
	QuestWatchFrame:Hide()
end

QuestieTracker:SetScript("OnEvent", QuestieTracker.OnEvent)
QuestieTracker:SetScript("OnUpdate", QuestieTracker_OnUpdate)
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



function QuestieTracker:addQuestToTracker(hash, logId)
	local startTime = GetTime()
	
	if(type(QuestieTrackedQuests[hash]) ~= "table") then
		QuestieTrackedQuests[hash] = {};
	end
	
	if not logId then
		logId = Questie:GetQuestIdFromHash(hash)
	end	

	local startId = GetQuestLogSelection();	
	SelectQuestLogEntry(logId);
	local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(logId);
	QuestieTrackedQuests[hash]["questName"] = questName
	QuestieTrackedQuests[hash]["level"] = level
	QuestieTrackedQuests[hash]["isComplete"] = isComplete
	for i=1, GetNumQuestLeaderBoards() do
		local desc, type, done = GetQuestLogLeaderBoard(i);
		QuestieTrackedQuests[hash]["objective"..i] = {
			["desc"] = desc,
			["type"] = type,
			["done"] = done,
			["notes"] = {},
		}
	end
	-- fallback for running quests
	if GetNumQuestLeaderBoards() == 0 then
		QuestieTrackedQuests[hash]["objective1"] = {
			["desc"] = "Run to the end",
			["type"] = type,
			["done"] = true,
			["notes"] = {},
		}
	end
	SelectQuestLogEntry(startId);
	Questie:debug_Print("Added QuestInfo to Tracker - Time: " .. (GetTime()-startTime)*1000 .. "ms");
end

function QuestieTracker:updateFrameOnTracker(hash, logId)
	local startTime = GetTime()	
	if(type(QuestieTrackedQuests[hash]) ~= "table") then
		QuestieTracker:addQuestToTracker(hash, logId)
		return
	end
	
	if not logId then
		logId = Questie:GetQuestIdFromHash(hash)
	end
	
	local startid = GetQuestLogSelection();
	SelectQuestLogEntry(logId);
	local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(logId);
	QuestieTrackedQuests[hash]["isComplete"] = isComplete
	for i=1, GetNumQuestLeaderBoards() do
		local desc, type, done = GetQuestLogLeaderBoard(i);
		QuestieTrackedQuests[hash]["objective"..i]["desc"] = desc
		QuestieTrackedQuests[hash]["objective"..i]["done"] = done
	end
	
	SelectQuestLogEntry(startid);
	Questie:debug_Print("TrackerInfo collected - Time: " .. (GetTime()-startTime)*1000 .. "ms");
	
end

function QuestieTracker:removeQuestFromTracker(hash)
	if QuestieTrackedQuests[hash] then
		QuestieTrackedQuests[hash] = nil
		QuestieTrackedQuests[hash] = false
	end
	QuestieTracker:fillTrackingFrame()
end

function QuestLogTitleButton_OnClick(button)
	if(EQL3_Player) then -- could also hook EQL3_AddQuestWatch(index) I guess
		if ( IsShiftKeyDown() ) then
			if(ChatFrameEditBox:IsVisible()) then
				ChatFrameEditBox:Insert(this:GetText());
			else
				QuestieTracker:setQuestInfo(this:GetID());
			end
	end
	_QuestLogTitleButton_OnClick(button);
	EQL3_QuestWatchFrame:Hide();
	else
		if ( button == "LeftButton" ) then
			if ( IsShiftKeyDown() ) then
				if(ChatFrameEditBox:IsVisible()) then
					ChatFrameEditBox:Insert(this:GetText());
				else
					-- add/remove quest to/from tracking
					QuestieTracker:setQuestInfo(this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame));
				end
			end
			QuestLog_SetSelection(this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame))
			QuestLog_Update();
		end
	end

	QuestWatchFrame:Hide()
	QuestieTracker:fillTrackingFrame();
end

function QuestieTracker:findLogIdByName(name)
	for i=1,GetNumQuestLogEntries() do
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if(name == questName) then
			return i;
		end
	end
end

function QuestieTracker:isTracked(quest)
	if(type(quest) == "string") then
		local hash = Questie:GetHashFromName(quest)
		if(QuestieTrackedQuests[hash] and QuestieTrackedQuests[hash] ~= false) then
			return true;
		end
	else
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(quest);
		local hash = Questie:GetHashFromName(questName)
		if(QuestieTrackedQuests[hash] and QuestieTrackedQuests[hash] ~= false) then
			return true;
		end
	end
	return false;
end

function QuestieTracker:setQuestInfo(id)
	local questInfo = {};
	local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(id);
	local hash = Questie:GetHashFromName(questName)

	if(QuestieTracker:isTracked(questName)) then
		QuestieTracker:removeQuestFromTracker(hash);
		return;
	end
	QuestieTracker:addQuestToTracker(hash)
end

function QuestieTracker:PLAYER_LOGIN()
	QuestieTracker:createTrackingFrame();
	QuestieTracker:createTrackingButtons();
	QuestieTracker:RegisterEvent("QUEST_LOG_UPDATE");
	QuestieTracker:RegisterEvent("PLAYER_LOGOUT");

	QuestieTracker:syncEQL3();
end

function QuestieTracker:syncEQL3()
	if(EQL3_Player) then
		for id=1, GetNumQuestLogEntries() do
			local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(id);
			if ( not isHeader and EQL3_IsQuestWatched(id) and not QuestieTracker:isTracked(questName) ) then
				for i=1, GetNumQuestLeaderBoards() do
					local desc, typ, done = GetQuestLogLeaderBoard(i);
					QuestieTracker:addQuestToTracker(Questie:GetHashFromName(questName), id);
				end
			elseif( not isHeader and not EQL3_IsQuestWatched(id) and QuestieTracker:isTracked(questName) ) then
				QuestieTracker:removeQuestFromTracker(Questie:GetHashFromName(questName));
			end
		end
	end
end

function QuestieTracker:QUEST_LOG_UPDATE()
	--local startid = GetQuestLogSelection();
	for id=1, GetNumQuestLogEntries() do
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(id);
		local hash = Questie:GetHashFromName(questName)
		
		if ( AUTO_QUEST_WATCH == "1" and QuestieTrackedQuests[hash] == nil and not isHeader) then
			QuestieTracker:setQuestInfo(id);
		end

		if( QuestieTracker:isTracked(questName) ) then
			QuestieTracker:updateFrameOnTracker(hash, id)
		end
	end
	--SelectQuestLogEntry(startid);
	this:fillTrackingFrame()
end

function QuestieTracker:ADDON_LOADED()
	if not ( QuestieTrackerVariables ) then
		QuestieTrackerVariables = {};
		QuestieTrackerVariables["position"] = {
			point = "CENTER",
			relativeTo = "UIParent",
			relativePoint = "CENTER",
			xOfs = 0,
			yOfs = 0,
		};
	end
	
	if not QuestieTrackedQuests then
		QuestieTrackedQuests = {}
	end
end

function QuestieTracker:updateTrackingFrameSize()
	local frameHeight = 0;
	local shown = 0;
	for i=1,8 do
		local button = getglobal("QuestieTrackerButton"..i);
		if button:IsShown() then
			button:SetParent(QuestieTracker.frame);
			button:SetWidth(240);
			local height = 20;
			button:SetHeight(20);
			shown = shown + 1;
			if(i == 1) then
				button:SetPoint("TOPLEFT", QuestieTracker.frame, "TOPLEFT", 5, -5);
			else
				button:SetPoint("TOPLEFT", "QuestieTrackerButton"..i-1, "BOTTOMLEFT", 0, -5);
			end
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 12;
				end
			end
			button:SetHeight(height);
			frameHeight = frameHeight + height;
		end
		QuestieTracker.frame.buttons[i] = button;
	end
	if shown == 0 then
		QuestieTracker.frame:Hide();
	else
		QuestieTracker.frame:SetHeight(frameHeight+shown*5 + 5);
		QuestieTracker.frame:Show();
	end
end

function QuestieTracker:getRGBForObjective(objective)
	if not (type(objective) == "function") then -- seriously wtf
		local lastIndex = findLast(objective, ":");
		if not (lastIndex == nil) then -- I seriously CANT shake this habit
			local progress = string.sub(objective, lastIndex+2);

			-- There HAS to be a better way of doing this
			local slash = findLast(progress, "/");
			local have = tonumber(string.sub(progress, 0, slash-1))
			local need = tonumber(string.sub(progress, slash+1))

			local float = have / need;
			local part = float-0.5;
			if part < 0 then part = 0; end -- derp
			part = part * 2;
			return 1.0-part, float*2, 0;
		end
	end
	return 0.2, 1, 0.2;
end


function QuestieTracker:clearTrackingFrame()
	for i=1, 8 do
		getglobal("QuestieTrackerButton"..i):Hide();
		for j=1,20 do
			getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):Hide();
		end
	end
end

function QuestieTracker:fillTrackingFrame()
	local t = GetTime();
	-- currently if there aren't any notes, it doesn't add the quest to the tracker
	-- eventually, that should be changed, but since we are lacking distance and such, there needs to be some kind of workaround!
	-- like creating dummy notes on SetQuestInfo() probably?
	QuestieTracker:clearTrackingFrame();
	local sortedByDistance = {};
	local distanceControlTable = {};

	--Start of sorting, got sidetracked.
	--[[local C,Z,X,Y = Astrolabe:GetCurrentPlayerPosition();
	for hash, quest in pairs(QuestieTrackedQuests) do
		local info = QuestieHandledQuests[hash];
		local closestIndex = -1;
		local closestDistance = 100000000;
		for k, v in pairs(info['objectives']['objectives']) do
			Astrolabe:ComputeDistance()
		end
		info.questHash = hash;
		table.insert(sortedByDistance, info);
	end]]--
	
	local i = 1;
	-- sort notes by distance before using this
	for hash,quest in pairs(QuestieTrackedQuests) do
		local handledQuests = QuestieHandledQuests[hash]
		local frame = getglobal("QuestieTrackerButton"..i);
		if not frame then break end
		if quest ~= false then
			frame:Show();
			
			quest["formatDistance"] = "0"
			quest["formatUnits"] = "m"
			getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("[" .. quest["level"] .. "] " .. quest["questName"] .. " (" .. quest["formatDistance"] .. " " .. quest["formatUnits"] .. ")");
			for j=1,20 do
				local objectiveLine = getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j)
				local objectiveTable = quest["objective"..j]
				if not objectiveLine or not objectiveTable then break end
				
				objectiveLine:SetText(objectiveTable["desc"]);
				objectiveLine:SetTextColor(QuestieTracker:getRGBForObjective(objectiveTable["desc"]));
				objectiveLine:Show();
			end
			i = i + 1
		end
	end

	--[[local i = 1;
	for index,quest in pairs(sortedByDistance) do
		for k,v in pairs(quest) do
			if(k == "tracked") then
				local frame = getglobal("QuestieTrackerButton"..i);
				if not frame then break; end
				frame:Show();
				local j = 1;
				for key,val in pairs(v) do
					if (key == "level") then
						getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("[" .. val .. "] " .. quest["questName"] .. " (" .. quest["formatDistance"] .. " " .. quest["formatUnits"] .. ")");
						frame.dist = quest["distance"]
						frame.title = quest["questName"]
						frame.point = {
							x = quest["x"],
							y = quest["y"],
							zoneID = BADCODE_ZONEID
						}

					elseif (key == "isComplete") then

					else
						getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):SetText(val);
						getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):SetTextColor(QuestieTracker:getRGBForObjective(val));
						getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):Show();
						j = j + 1;
					end
				end
				i = i + 1;
			end
		end
	end]]
	QuestieTracker:updateTrackingFrameSize();
	--Questie:debug_Print("TrackerFrame filled: Time:", tostring((GetTime()-t)*1000).."ms");
end

function QuestieTracker:createTrackingButtons()
	local t = GetTime();
	QuestieTracker.frame.buttons = {};
	local frameHeight = 20;
	for i=1,8 do
		local button = CreateFrame("Button", "QuestieTrackerButton"..i, QuestieTracker.frame, "QuestieTrackerButtonTemplate");
		button:SetParent(QuestieTracker.frame);
		button:SetWidth(240);
		button:SetHeight(12);

		button:RegisterForClicks("RightButtonDown","LeftButtonUp", "LeftClick");

		button.arrowshown = false;

		button:SetScript("OnClick", function() if arg1 == "RightButton" then
			local x, y = GetCursorPosition();
			local at = "Open Arrow";
			if button.arrowshown then
				at = "Close Arrow";
			end
			createPrettyMenu({
				["Untrack"] = {
					['click'] = function() QuestieTrackedQuests[button.title]["tracked"] = false; end
				},
				[at] = {
					['click'] = function() button.arrowshown = not button.arrowshown;SetCrazyArrow(button.point, button.dist, button.title) end
				},
				["< Developer"] = {
					['clock'] = nil,
					['submenu'] = {
						['Print Metadata'] = {
							['click'] = function() end
						},
						['Print Objectives'] = {
							['click'] = function() end
						}
					}
				},
				["Close"]=
				{
					['click'] = function() end
				}
			}, button:GetLeft()-160, y - button:GetHeight() / 2, QuestieTracker.frame);

		end end);

		if(i == 1) then
			button:SetPoint("TOPLEFT", QuestieTracker.frame, "TOPLEFT", 5, -15);
			local height = 12;
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 12;
				end
			end
			button:SetHeight(height);
		else
			button:SetPoint("TOPLEFT", "QuestieTrackerButton"..i-1, "BOTTOMLEFT", 0, -5);
			local height = 12;
			for j=1,8 do
				if( getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):IsShown() ) then
					height = height + 12;
				end
			end
			button:SetHeight(height);
		end
		getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("QuestName");
		frameHeight = frameHeight + button:GetHeight();
		QuestieTracker.frame.buttons[i] = button;
	end
	QuestieTracker.frame:SetHeight(frameHeight+40);

	Questie:debug_Print("Created Tracker frames: Time:", tostring((GetTime()-t)*1000).."ms")
	QuestieTracker:fillTrackingFrame();
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
	QuestieTracker.frame = CreateFrame("Frame", "QuestieTrackerFrame", UIParent);
	QuestieTracker.frame:SetWidth(250);
	QuestieTracker.frame:SetHeight(400);
	QuestieTracker.frame:SetPoint(QuestieTrackerVariables["position"]["point"], QuestieTrackerVariables["position"]["relativeTo"], QuestieTrackerVariables["position"]["relativePoint"],
		QuestieTrackerVariables["position"]["xOfs"], QuestieTrackerVariables["position"]["yOfs"]);
	QuestieTracker.frame:SetAlpha(0.2)
	QuestieTracker.frame.texture = QuestieTracker.frame:CreateTexture(nil, "BACKGROUND");
	--this.frame.texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
	QuestieTracker.frame.texture:SetTexture(0,0,0); -- black
	QuestieTracker.frame.texture:SetAllPoints(QuestieTracker.frame);
	QuestieTracker.frame:Show();

	--this.frame:RegisterForDrag("LeftButton");
	QuestieTracker.frame:EnableMouse(true);
	QuestieTracker.frame:SetMovable(true);
	QuestieTracker.frame:SetScript("OnMouseDown", function()
		this:StartMoving();
	end);
	QuestieTracker.frame:SetScript("OnMouseUp", function()
		QuestieTracker:StopMovingOrSizing();
		this:SetUserPlaced(false);
		--can't call saveFramePosition because it RANDOMLY THROWS WOW ERRORS (WTF?)
		QuestieTracker:saveFramePosition()
	end);
end
