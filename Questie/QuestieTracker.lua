local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

QuestieTracker = CreateFrame("Frame", "QuestieTracker", UIParent, "ActionButtonTemplate")

function QuestieTracker:OnEvent() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	QuestieTracker[event](QuestieTracker, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to Questie:event methods
end
QuestieTracker:SetScript("OnEvent", QuestieTracker.OnEvent)

local _QuestWatch_Update = QuestWatch_Update;
local _RemoveQuestWatch = RemoveQuestWatch;
local _IsQuestWatched = IsQuestWatched;
local _GetNumQuestWatches = GetNumQuestWatches;
local _AddQuestWatch = AddQuestWatch;
local _GetQuestIndexForWatch = GetQuestIndexForWatch;
local _QuestLogTitleButton_OnClick = QuestLogTitleButton_OnClick;

function QuestieTracker:test()
	for k,v in pairs(currentQuests["Buzzbox 411"]) do
		if(k == "tracked") then
			for ke,va in pairs(v) do
				log(ke)
			end
		end
	end
end


function QuestieTracker:addQuestToTracker(questName, desc, typ, done, level, isComplete)
	if(type(currentQuests[questName]) ~= "table") then
		currentQuests[questName] = {};
	end
	if(type(currentQuests[questName].tracked) ~= "table") then
		currentQuests[questName]["tracked"] = {};
	end
	currentQuests[questName]["tracked"][desc] = true
	currentQuests[questName]["tracked"]["level"] = level
	currentQuests[questName]["tracked"]["isComplete"] = isComplete
end 

function QuestieTracker:removeQuestFromTracker(questName)
	currentQuests[questName]["tracked"] = nil
end

function QuestLogTitleButton_OnClick(button)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() ) then
			if(ChatFrameEditBox:IsVisible()) then
				ChatFrameEditBox:Insert(this:GetText());
			end
			-- add quest to tracking
			QuestieTracker:setQuestInfo(this:GetID())
		end
		QuestLog_SetSelection(this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame))
		QuestLog_Update();
	end
	--_QuestLogTitleButton_OnClick(button)
	--QuestWatchFrame:Hide()
end

function QuestieTracker:isTracked(quest)
	if(type(quest) == "string") then
		if(currentQuests[quest]["tracked"] ~= nil) then
			return true;
		end	
	else
		local questName, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(quest);
		if(currentQuests[quest]["tracked"] ~= nil) then
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

--[[function QuestWatch_Update()
	log("test")
end]]

--[[function EQL3_GetQuestIndexForWatch(id)
	local numEntries = GetNumQuestLogEntries();
	local questLogTitleText, level;
	local questLogHeader, isHeader, tempId;
	local questFound = false;
	local temp, currentHeader=nil;
	
	
	for i=1, numEntries, 1 do
		questLogTitleText, level, _, isHeader, _ = GetQuestLogTitle(i);
		if (isHeader) then
			currentHeader = questLogTitleText;
		else
			temp = currentHeader..","..level..","..questLogTitleText;
			if ( temp == QuestlogOptions[EQL3_Player].QuestWatches[id] ) then
				return i;
			end
		end
	end
	return 0;
end]]

--[[function GetQuestHeaderForWatch(questIndex)
	if(QuestlogOptions[EQL3_Player].QuestWatches[questIndex]) then
		local numEntries = GetNumQuestLogEntries();
		local questLogHeader, isCollapsed;
		local s = QuestlogOptions[EQL3_Player].QuestWatches[questIndex];
		local temp=nil;
		for w in string.gfind(s, "[^,]+") do
			if(temp == nil) then
				temp = w;
				break;
			end
		end
		for i=1, numEntries, 1 do
			questLogHeader, _, _, _, isCollapsed = GetQuestLogTitle(i);
			if(questLogHeader == temp) then
				return questLogHeader, isCollapsed;
			end
		end
		return temp, true;
	end
	return "", false;
end]]


