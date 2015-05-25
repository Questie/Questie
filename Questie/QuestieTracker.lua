local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

QuestieTracker = CreateFrame("Frame", "QuestieTracker", UIParent, "ActionButtonTemplate")

function QuestieTracker:OnEvent() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	QuestieTracker[event](QuestieTracker, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to Questie:event methods
end

QuestieTracker.hasCleared = false
QuestieTracker.lastUpdate = 0;

function QuestieTracker_OnUpdate()
	
	if QuestieTracker.frame:GetTop() > GetScreenHeight() or QuestieTracker.frame:GetLeft() > GetScreenWidth() then
		if QuestieTracker.frame:GetTop() > GetScreenHeight() then
			QuestieTrackerVariables["position"]["yOfs"] = GetScreenHeight() - QuestieTracker.frame:GetHeight();
		end
		if QuestieTracker.frame:GetLeft() > GetScreenWidth() then
			QuestieTrackerVariables["position"]["xOfs"] = GetScreenWidth() - QuestieTracker.frame:GetWidth();
		end
		
		QuestieTracker.frame:SetPoint(QuestieTrackerVariables["position"]["point"], QuestieTrackerVariables["position"]["relativeTo"], QuestieTrackerVariables["position"]["relativePoint"],
			QuestieTrackerVariables["position"]["xOfs"], QuestieTrackerVariables["position"]["yOfs"]);
	end
	--ChatFrame3:Clear();
	--for k,v in pairs(QuestieTrackedQuests) do
	--	if type(v) == "table"  then
	--		local nam = "NILLWTF";
	--		local extr = " [N]";
	--		if v['rend'] then
	--			extr = " [Y]";
	--		end
	--		if QuestieHashMap[k] then
	--			nam = QuestieHashMap[k]['name'];
	--		end
	--		ChatFrame3:AddMessage(k .. ": " .. nam .. extr);
	--	end
	--end
	--ChatFrame4:Clear();
	--for k,v in pairs(QuestieHandledQuests) do
	--	ChatFrame4:AddMessage(k .. ": " .. QuestieHashMap[k]['name']);
	--end
	if(EQL3_QuestWatchFrame) then
		EQL3_QuestWatchFrame:Hide();
	end
	if GetTime() - QuestieTracker.lastUpdate >= 1 then
		QuestieTracker:fillTrackingFrame()
		QuestieTracker.lastUpdate = GetTime()
	end
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


-- begin ui code

function QuestieTracker:updateTrackingFrameSize()
	local lastButton = QuestieTracker.questButtons[QuestieTracker.highestIndex];
	--/script DEFAULT_CHAT_FRAME:AddMessage(QuestieTracker.frame:GetTop());
	--/script DEFAULT_CHAT_FRAME:AddMessage(QuestieTracker.questButtons[QuestieTracker.highestIndex]:GetTop());
	if lastButton == nil then return; end
	
	local lbt = lastButton:GetBottom();
	local tt = QuestieTracker.frame:GetTop();
	
	-- yeah apparently this happens
	if tt == nil then tt = 0; end
	if lbt == nil then lbt = 0; end
	-- wtf wow
	
	local totalSize = tt - lbt;
	QuestieTracker.frame:SetHeight(totalSize);
end

function QuestieTracker:getRGBForObjective_old(objective)
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
			if part < 0 then part = 0; end
			part = part * 2;
			return 1.0-part, float*2, 0;
		end
	end
	return 0.2, 1, 0.2;
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
			
			if not have or not need then
				return 0.8, 0.8, 0.8;
			end

			local float = have / need;
			return 0.8-float/2, 0.8+float/3, 0.8-float/2;
		end
	end
	return 0.3, 1, 0.3;
end

function QuestieTracker:clearTrackingFrame()
	--[[for i=1, 8 do
		getglobal("QuestieTrackerButton"..i):Hide();
		for j=1,20 do
			getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):Hide();
		end
	end]]--
end

QuestieTracker.questButtons = {};

function QuestieTracker:createOrGetTrackingButton(index)
	if QuestieTracker.questButtons[index] == nil then
		local parent;
		local parentString; -- fucking wow api
		if index == 1 then
			parent = QuestieTracker.frame;
		else
			parent = QuestieTracker.questButtons[index-1]; -- this allows easy dynamic positioning
		end

		--parent = UIParent;
		--parent = QuestieTracker.frame;
		local btn = CreateFrame("Button", "QuestieTrackerButtonNew"..index, QuestieTracker.frame);
		btn.objectives = {};
		btn:SetWidth(240);
		btn:SetHeight(14);
		btn:EnableMouse(true);
		btn:SetMovable(true);
		btn:SetScript("OnDragStart", QuestieTracker.frame.StartMoving)
		btn:SetScript("OnDragStop", QuestieTracker.frame.StopMovingOrSizing)
		--btn.clicked = false;
		btn:SetScript("OnMouseDown", function()
			btn.dragstartx, btn.dragstarty = GetCursorPosition();
			QuestieTracker.frame:StartMoving();
		end);
		btn:SetScript("OnMouseUp", function()
			local dragstopx, dragstopy = GetCursorPosition();
			if (btn.dragstartx == dragstopx and btn.dragstarty == dragstopy) then
				btn:click();
			end
			QuestieTracker.frame:StopMovingOrSizing();
			QuestieTracker.frame:SetUserPlaced(false);
			--can't call saveFramePosition because it RANDOMLY THROWS WOW ERRORS (WTF?)
			QuestieTracker:saveFramePosition()
			--btn.clicked = false;
		end);
		btn.dragstartx = 0;
		btn.dragstarty = 0;
		btn:SetScript("OnEnter", function() 
			QuestieTracker.frame.texture:SetAlpha(0.3);
		end);
		btn:SetScript("OnLeave", function() 
			QuestieTracker.frame.texture:SetAlpha(0.0);
		end);
		btn:RegisterForClicks("RightButtonDown","LeftButtonUp", "LeftClick");
		btn.click = function()
			SetArrowObjective(btn.hash);
			--DEFAULT_CHAT_FRAME:AddMessage("Clicked " .. btn.quest:GetText());
		end
		btn:SetScript("OnClick", function() 
			if arg1 == "LeftButton" then 
				--btn:click();
				--btn.clicked = true;
			end
		end);
		--button:SetPoint("CENTER", UIParent, 0, -5);
		--button:SetPoint("BOTTOMLEFT", parent, 10, -10);
		if index == 1 then
			btn:SetPoint("TOPLEFT", parent, "TOPLEFT",  0, 0);
		else
			btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT",  0, 0);
		end
		
		--button.prevoffset = parent.prevoffset + button:GetHeight(); -- there is a way to do this automatically but WOW IS BEING RETARDED AND I'M NOT GIVING UP RAGE RAGE RAGE
		local quest = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		quest:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, 0)
		btn.quest = quest;
		
		local level = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal") --/script QuestieTracker.questButtons[3]:SetHeight(20);
		level:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
		btn.level = level;
		
		QuestieTracker.questButtons[index] = btn;
		--button:Show();
		--btn.Hide = function() DEFAULT_CHAT_FRAME:AddMessage("Attempt hide!"); end
		--table.insert(QuestieTracker.questButtons, btn); -- because of how the code works this will always match index and doing it this way has the benifit of making it sortable
	end
	return QuestieTracker.questButtons[index];
end

QuestieTracker.highestIndex = 0;

function QuestieTracker:GetDifficultyColor(level)
	if level == nil then return "FFFFFFFF"; end
	local levelDiff = level - UnitLevel("player");
	if ( levelDiff >= 5 ) then
		return "FFFF1A1A";
	elseif ( levelDiff >= 3 ) then
		return "FFFF8040";
	elseif ( levelDiff >= -2 ) then
		return "FFFFFF00";
	elseif ( -levelDiff <= GetQuestGreenRange() ) then
		return "FF40C040";
	else
		return "FFC0C0C0";
	end
end

local function RGBToHex(r, g, b)
	--r = r <= 255 and r >= 0 and r or 0
	--g = g <= 255 and g >= 0 and g or 0
	--b = b <= 255 and b >= 0 and b or 0
	if r > 255 then r = 255; end
	if g > 255 then g = 255; end
	if b > 255 then b = 255; end;
	return string.format("%02x%02x%02x", r, g, b)
end

local function fRGBToHex(r, g, b)
	return RGBToHex(r*254, g*254, b*254);
end

function QuestieTracker:AddObjectiveToButton(button, objective, index)
	local objt;
	if button.objectives[index] == nil then
		--button:SetHeight(button:GetHeight() + 11);
		objt = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	else
		objt = button.objectives[index];
	end
	 --/script QuestieTracker.questButtons[3]:SetHeight(20);
	objt:SetPoint("TOPLEFT", button, "TOPLEFT", 20, -(index * 11+1))
	
	local r, g, b = QuestieTracker:getRGBForObjective(objective["desc"]);
	local clr = fRGBToHex(r, g, b);
	--local clr = "DDDDDD";
	
	objt:SetText("|cFF"..clr..objective["desc"].."|r");

	button.objectives[index] = objt;
	
	--btn.objectives 

end

-- TODO move this into Questie: namespace
function QuestieTracker:GetFinisherLocation(typ, name)
	local C, Z, X, Y;
	
	if typ == "monster" then
		local npc = QuestieMonsters[name];
		if npc == nil then
			npc = QuestieAdditionalStartFinishLookup[name];
			if not (npc == nil) then
				C, Z, X, Y = npc[1], npc[2], npc[3], npc[4];
			else
			end
		else
			local loc = npc['locations'][1];
			mapid = loc[1];
			x = loc[2];
			y = loc[3];
			C, Z, X, Y = QuestieZoneIDLookup[mapid][4], QuestieZoneIDLookup[mapid][5], x, y
		end
	elseif typ == "object" then
		local obj = QuestieObjects[name];
		if not (obj == nil) then
			local loc = obj['locations'][1];
			mapid = loc[1];
			x = loc[2];
			y = loc[3];
			C, Z, X, Y = QuestieZoneIDLookup[mapid][4], QuestieZoneIDLookup[mapid][5], x, y
		else
			local npc = QuestieMonsters[name];
			if npc == nil then
				npc = QuestieAdditionalStartFinishLookup[name];
				if not (npc == nil) then
					C, Z, X, Y = npc[1], npc[2], npc[3], npc[4];
				else
				end
			else
				local loc = npc['locations'][1];
				mapid = loc[1];
				x = loc[2];
				y = loc[3];
				C, Z, X, Y = QuestieZoneIDLookup[mapid][4], QuestieZoneIDLookup[mapid][5], x, y
			end
		end
	end
	
	return C, Z, X, Y;
end

function QuestieTracker:fillTrackingFrame()
	local index = 1;
	local sortedByDistance = {};
	local distanceControlTable = {};
	local C,Z,X,Y = Astrolabe:GetCurrentPlayerPosition() -- continent, zone, x, y
	
	local distanceNotes = {};
	local objc = 0;
	for hash,quest in pairs(QuestieHandledQuests) do
		if QuestieTrackedQuests[hash] and QuestieHashMap[hash] then
			objc = 0;
			if QuestieTrackedQuests[hash]["isComplete"] then
				
			else
				for name,notes in pairs(quest.objectives.objectives) do
					for k,v in pairs(notes) do
						if not v.done then 
							local continent, zone, xNote, yNote = QuestieZoneIDLookup[v.mapid][4], QuestieZoneIDLookup[v.mapid][5], v.x, v.y
							if continent and zone and xNote and yNote then
								local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, continent, zone, xNote, yNote )
								if dist and xDelta and yDelta then
									local info = {
										["dist"] = dist,
										["hash"] = hash,
										["xDelta"] = xDelta,
										["yDelta"] = yDelta,
										["c"] = continent,
										["z"] = zone,
										["x"] = xNote,
										["y"] = yNote,
									}
									objc = objc + 1;
									table.insert(distanceNotes, info);
								end
							end
						end
					end
				end
			end
			if objc == 0 then
				local continent, zone, xNote, yNote = QuestieTracker:GetFinisherLocation(QuestieHashMap[hash]['finishedType'], QuestieHashMap[hash]['finishedBy']);
				if continent and zone and xNote and yNote then
					local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, continent, zone, xNote, yNote );
					if dist and xDelta and yDelta  then
						local info = {
							["dist"] = dist,
							["hash"] = hash,
							["xDelta"] = xDelta,
							["yDelta"] = yDelta,
							["c"] = continent,
							["z"] = zone,
							["x"] = xNote,
							["y"] = yNote,
						}
						table.insert(distanceNotes, info);
					end
				end
			end
		end
	end
	
	
	sort(distanceNotes, function (a, b)
		return a["dist"] < b["dist"]
	end)
	
	
	-- not sure what this bit is for
	for k,v in pairs(distanceNotes) do
		if not distanceControlTable[v["hash"]] then
			distanceControlTable[v["hash"]] = true
			table.insert(sortedByDistance, v);
		end
	end
	-- but it exists so...
	
	for k,v in pairs(QuestieTrackedQuests) do
		if type(v) == "table" then v['rend'] = false; end
	end
	
	
	for i,v in pairs(sortedByDistance) do
		local hash = v["hash"];
		local quest = QuestieTrackedQuests[hash];
		quest['rend'] = true;
		local button = QuestieTracker:createOrGetTrackingButton(index);
		button.hash = hash;
		local colorString = "|c" .. QuestieTracker:GetDifficultyColor(quest["level"]);
				
		local titleData = colorString;
		

		if QuestieConfig['AlwaysShowLevel'] then
			titleData = titleData .. "[" .. quest["level"] .. "] " ;
		end
		titleData = titleData .. quest["questName"];
		if QuestieConfig['AlwaysShowDistance'] then
			titleData = titleData .. " ("..math.floor(v["dist"]).." Yd)";
		end
		
		titleData = titleData  .. "|r";
		
		button.quest:SetText(titleData);
		--button.level:SetText(colorString .. "[".. quest["level"] .."]|r");
			
		local obj = 1;
		
		v["title"] = colorString .. "[" .. quest["level"] .. "] " .. quest["questName"] .. "|r";
		quest["arrowPoint"] = v
		
		if quest["isComplete"] or quest["leaderboards"] == 0 then
			QuestieTracker:AddObjectiveToButton(button, {['desc']="Run to the end"}, obj);
			obj = 2;
		else
			while true do
				local beefcake = quest["objective" .. obj];
				if beefcake == nil then break; end
				QuestieTracker:AddObjectiveToButton(button, beefcake, obj);
				obj = obj + 1;
			end
		end
		
		button.currentObjectiveCount = obj - 1;
		
		local heightLoss = 0;

		while true do
			if button.objectives[obj] == nil then break; end
			button.objectives[obj]:SetText(""); --hecks
			heightLoss = heightLoss + 11;
			obj = obj + 1;
		end
		
		--button:SetHeight(button:GetHeight() - heightLoss);
		button:SetHeight(14 + (button.currentObjectiveCount * 11));
			
		button:Show();
			
		index = index + 1;
	end
	
	QuestieTracker.highestIndex = index - 1;
	
	while true do
		local d = QuestieTracker.questButtons[index];
		if d == nil then break end;
		d:Hide();
		index = index + 1;
	end
	
	QuestieTracker:updateTrackingFrameSize();
	
	QuestieTracker.frame:Show();
		
end

function QuestieTracker:fillTrackingFrame_Old()
	local t = GetTime();
	QuestieTracker:clearTrackingFrame();
	local sortedByDistance = {};
	local distanceControlTable = {};
	local C,Z,X,Y = Astrolabe:GetCurrentPlayerPosition() -- continent, zone, x, y
	
	local distanceNotes = {};
	
	-- iterate 3 times
	-- first go by through notes in the current zone 
	-- if quest tracker frame isn't fully filled (index 8), go through other zones
	-- as a backup, add quests that don't have any notes by going through QuestieTrackedQuests+Questlog
	
	for hash,quest in pairs(QuestieHandledQuests) do
		if QuestieTrackedQuests[hash] then
			for name,notes in pairs(quest.objectives.objectives) do
				for k,v in pairs(notes) do
					local continent, zone, xNote, yNote = QuestieZoneIDLookup[v.mapid][4], QuestieZoneIDLookup[v.mapid][5], v.x, v.y
						local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, continent, zone, xNote, yNote )
						local info = {
							["dist"] = dist,
							["hash"] = hash,
							["xDelta"] = xDelta,
							["yDelta"] = yDelta,
							["c"] = continent,
							["z"] = zone,
							["x"] = xNote,
							["y"] = yNote,
						}
						table.insert(distanceNotes, info);
				end
			end
		end
	end
	sort(distanceNotes, function (a, b)
		return a["dist"] < b["dist"]
	end)
	
	for k,v in pairs(distanceNotes) do
		if not distanceControlTable[v["hash"]] then
			distanceControlTable[v["hash"]] = true
			table.insert(sortedByDistance, v);
		end
	end
	
	for i,v in pairs(sortedByDistance) do
		local quest = QuestieTrackedQuests[v["hash"]]
		local frame = getglobal("QuestieTrackerButton"..i);
		if not frame then break end
		
		frame:Show();
			
		local formatUnits = "yds"
		local dist = tonumber(string.format("%.0f" , v["dist"]))
		
		-- Arrow data
		v["title"] = "[" .. quest["level"] .. "] " .. quest["questName"]
		quest["arrowPoint"] = v
		frame["hash"] = v["hash"]
		
		getglobal("QuestieTrackerButton"..i.."HeaderText"):SetText("[" .. quest["level"] .. "] " .. quest["questName"] .. " (" .. dist .. " " .. formatUnits .. ")");
		for j=1,20 do
			local objectiveLine = getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j)
			local objectiveTable = quest["objective"..j]
			if not objectiveLine or not objectiveTable then break end
			
			objectiveLine:SetText(objectiveTable["desc"]);
			objectiveLine:SetTextColor(QuestieTracker:getRGBForObjective(objectiveTable["desc"]));
			objectiveLine:Show();
		end
	end
	
	QuestieTracker:updateTrackingFrameSize();
	--Questie:debug_Print("TrackerFrame filled: Time:", tostring((GetTime()-t)*1000).."ms");
end



function QuestieTracker:createTrackingButtons() -- no longer needed but keeping the method stub

end

function QuestieTracker:createTrackingFrame()
	QuestieTracker.frame = CreateFrame("Frame", "QuestieTrackerFrame", UIParent);
	QuestieTracker.frame:SetWidth(250);
	QuestieTracker.frame:SetHeight(400);
	QuestieTracker.frame:SetPoint(QuestieTrackerVariables["position"]["point"], QuestieTrackerVariables["position"]["relativeTo"], QuestieTrackerVariables["position"]["relativePoint"],
		QuestieTrackerVariables["position"]["xOfs"], QuestieTrackerVariables["position"]["yOfs"]);
	--QuestieTracker.frame:SetAlpha(0.2)
	QuestieTracker.frame.texture = QuestieTracker.frame:CreateTexture(nil, "BACKGROUND");
	
	--this.frame.texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
	QuestieTracker.frame.texture:SetTexture(0,0,0); -- black
	QuestieTracker.frame.texture:SetAlpha(0.0);
	QuestieTracker.frame.texture:SetAllPoints(QuestieTracker.frame);
	QuestieTracker.frame:Show();

	--this.frame:RegisterForDrag("LeftButton");
	QuestieTracker.frame:EnableMouse(true);
	QuestieTracker.frame:SetMovable(true);
	QuestieTracker.frame.prevoffset = 0;
	QuestieTracker.frame:SetScript("OnMouseDown", function()
		this:StartMoving();
	end);
	QuestieTracker.frame:SetScript("OnMouseUp", function()
		this:StopMovingOrSizing();
		this:SetUserPlaced(false);
		--can't call saveFramePosition because it RANDOMLY THROWS WOW ERRORS (WTF?)
		QuestieTracker:saveFramePosition()
	end);
end

function QuestLogTitleButton_OnClick(button)
	if(EQL3_Player) then -- could also hook EQL3_AddQuestWatch(index) I guess
		if ( IsShiftKeyDown() ) then
			if not ChatFrameEditBox:IsVisible() then
				QuestieTracker:setQuestInfo(this:GetID() + FauxScrollFrame_GetOffset(EQL3_QuestLogListScrollFrame));
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

-- end ui code















-- begin logic code

local function trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1");
end

function QuestieTracker:addQuestToTracker(hash, logId, level) -- never used???
	local startTime = GetTime()
	
	if(type(QuestieTrackedQuests[hash]) ~= "table") then
		QuestieTrackedQuests[hash] = {};
	end
	
	if not logId then
		logId = Questie:GetQuestIdFromHash(hash)
	end
	
	if logId == nil then
		Questie:debug_Print("TrackerError! LogId still nil after GetQuestIdFromHash ", hash);
		return;
	end

	local questName, level, questTag, isHeader, isCollapsed, isComplete = QuestieCompat_GetQuestLogTitle(logId);
	QuestieTrackedQuests[hash]["questName"] = questName
	QuestieTrackedQuests[hash]["level"] = level
	QuestieTrackedQuests[hash]["isComplete"] = isComplete
	QuestieTrackedQuests[hash]["leaderboards"] = GetNumQuestLeaderBoards(logId);
	for i=1, GetNumQuestLeaderBoards(logId) do
		local desc, type, done = GetQuestLogLeaderBoard(i, logId);
		QuestieTrackedQuests[hash]["objective"..i] = {
			["desc"] = desc,
			["type"] = type,
			["done"] = done,
			["notes"] = {},
		}
	end
	-- fallback for running quests
	if GetNumQuestLeaderBoards() == 0 or isComplete then
		QuestieTrackedQuests[hash]["objective1"] = {
			["desc"] = "Run to the end",
			["type"] = type,
			["done"] = true,
			["notes"] = {},
		}
	end

	Questie:debug_Print("Added QuestInfo to Tracker - Time: " .. (GetTime()-startTime)*1000 .. "ms");
	QuestieTracker:fillTrackingFrame()
	Questie:RedrawNotes();
end

function QuestieTracker:updateFrameOnTracker(hash, logId, level)
	
	if AUTO_QUEST_WATCH == "1" and QuestieTrackedQuests[hash] == nil then
		QuestieTracker:addQuestToTracker(hash, logId, level);
	end
	
	local startTime = GetTime()	
	
	
	if not logId then
		logId = Questie:GetQuestIdFromHash(hash)
	end
	
	if QuestieTrackedQuests[hash] == false then
		return
	end
	
	local questName, level, questTag, isHeader, isCollapsed, isComplete = QuestieCompat_GetQuestLogTitle(logId);

	if not QuestieTrackedQuests[hash] then
		QuestieTrackedQuests[hash] = {};
	end
	
	QuestieTrackedQuests[hash]["questName"] = questName;
	QuestieTrackedQuests[hash]["isComplete"] = isComplete;
	QuestieTrackedQuests[hash]["level"] = level;
	QuestieTrackedQuests[hash]["leaderboards"] = GetNumQuestLeaderBoards(logId);
	local uggo = 0;
	for i=1, GetNumQuestLeaderBoards(logId) do
		local desc, type, done = GetQuestLogLeaderBoard(i, logId);
		if not QuestieTrackedQuests[hash]["objective"..i] then
			QuestieTrackedQuests[hash]["objective"..i] = {};
		end
		QuestieTrackedQuests[hash]["objective"..i]["desc"] = desc
		QuestieTrackedQuests[hash]["objective"..i]["done"] = done
		uggo = i;
	end
	
	uggo = uggo - 1;
	
	--[[ what the fuck was this shit even good for except deleting objectives we need?
	while true do
		if QuestieTrackedQuests[hash]["objective"..uggo] == nil then break; end;
		DEFAULT_CHAT_FRAME:AddMessage("deleting objective "..QuestieTrackedQuests[hash]["objective"..uggo]["desc"])
		QuestieTrackedQuests[hash]["objective"..uggo] = nil;
		uggo = uggo + 1;
	end]]
	
	QuestieTracker:fillTrackingFrame()
	--Questie:debug_Print("TrackerInfo collected - Time: " .. (GetTime()-startTime)*1000 .. "ms");
end

function QuestieTracker:removeQuestFromTracker(hash)
	--DEFAULT_CHAT_FRAME:AddMessage("REMOVEQUESTFROMTRACKER");
	if QuestieTrackedQuests[hash] then
		QuestieTrackedQuests[hash] = nil
		QuestieTrackedQuests[hash] = false
	end
	QuestieTracker:fillTrackingFrame()
	Questie:RedrawNotes();
end


function QuestieTracker:findLogIdByName(name)
	for i=1,GetNumQuestLogEntries() do
		local questName, level, questTag, isHeader, isCollapsed, isComplete = QuestieCompat_GetQuestLogTitle(i);
		if(name == questName) then
			return i;
		end
	end
end

function QuestieTracker:isTracked(quest) -- everything about this function is bad because of GetHashFromName
	if quest == nil then return false; end
	if(type(quest) == "string") then
		local hash = Questie:GetHashFromName(quest)
		if(QuestieTrackedQuests[hash] and QuestieTrackedQuests[hash] ~= false) then
			return true;
		end
	else
		local questName, level, questTag, isHeader, isCollapsed, isComplete = QuestieCompat_GetQuestLogTitle(quest);
		local hash = Questie:GetHashFromName(questName)
		if(QuestieTrackedQuests[hash] and QuestieTrackedQuests[hash] ~= false) then
			return true;
		end
	end
	return false;
end

function QuestieTracker:setQuestInfo(id)
	local questInfo = {};
	local questName, level, questTag, isHeader, isCollapsed, isComplete = QuestieCompat_GetQuestLogTitle(id);
	
	if not isHeader and not isCollapsed then
		local hash = Questie:GetHashFromName(questName)

		if(QuestieTracker:isTracked(questName)) then
			QuestieTracker:removeQuestFromTracker(hash);
			return;
		end
		QuestieTracker:addQuestToTracker(hash, id, level);
	end
end

function QuestieTracker:PLAYER_LOGIN()
	QuestieTracker:createTrackingFrame();
	--QuestieTracker:createTrackingButtons();
	QuestieTracker:RegisterEvent("PLAYER_LOGOUT");

	QuestieTracker:syncEQL3();
end

function QuestieTracker:syncEQL3()
	if(EQL3_Player) then
		for id=1, GetNumQuestLogEntries() do
			local questName, level, questTag, isHeader, isCollapsed, isComplete = QuestieCompat_GetQuestLogTitle(id);
			if ( not isHeader and EQL3_IsQuestWatched(id) and not QuestieTracker:isTracked(questName) ) then
				QuestieTracker:addQuestToTracker(Questie:GetHashFromName(questName), id, level);
			elseif( not isHeader and not EQL3_IsQuestWatched(id) and QuestieTracker:isTracked(questName) ) then
				QuestieTracker:removeQuestFromTracker(Questie:GetHashFromName(questName));
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
			xOfs = 0,
			yOfs = 0,
		};
	end
	
	if not QuestieTrackedQuests then 
		QuestieTrackedQuests = {}
	end
	
	-- bye vanilla tracker
	QuestWatchFrame:Hide()
	QuestWatchFrame.Show = function () end;
	
end

-- end logic code
