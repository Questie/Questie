DEBUG_LEVEL = 0;--0 Low info --1 Medium info --2 very spammy

Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate")

__QuestRewardCompleteButton_OnClick=nil;
__QuestAbandonOnAccept=nil;
__QuestAbandonWithItemsOnAccept=nil;
local QuestieQuestHashCache = {}

-- Setup Characters Default Profile
function Questie:SetupDefaults()
	if not QuestieConfig then QuestieConfig = {
		["alwaysShowDistance"] = false,
		["alwaysShowLevel"] = true,
		["alwaysShowQuests"] = true,
		["arrowEnabled"] = true,
		["boldColors"] = false,
		["maxLevelFilter"] = false,
		["maxShowLevel"] = 3,
		["minLevelFilter"] = false,
		["minShowLevel"] = 5,
		["showMapAids"] = true,
		["showProfessionQuests"] = false,
		["showTrackerHeader"] = false,
		["trackerEnabled"] = true,
		["trackerList"] = false,
		["resizeWorldmap"] = false,
	}
	end
	if not QuestieTrackerVariables then QuestieTrackerVariables = {
		["position"] = {
			["relativeTo"] = "UIParent",
			["point"] = "LEFT",
			["relativePoint"] = "LEFT",
			["yOfs"] = 0,
			["xOfs"] = 0,
		},
	}
	end
end

function Questie:CheckDefaults()
	if not QuestieConfig.alwaysShowDistance then
		QuestieConfig.alwaysShowDistance = false;
	end
	if not QuestieConfig.alwaysShowLevel then
		QuestieConfig.alwaysShowLevel = true;
	end
	if not QuestieConfig.alwaysShowQuests then
		QuestieConfig.alwaysShowQuests = true;
	end
	if not QuestieConfig.arrowEnabled then
		QuestieConfig.arrowEnabled = true;
	end
	if not QuestieConfig.boldColors then
		QuestieConfig.boldColors = false;
	end
	if not QuestieConfig.maxLevelFilter then
		QuestieConfig.maxLevelFilter = false;
	end
	if not QuestieConfig.maxShowLevel then
		QuestieConfig.maxShowLevel = false;
		QuestieConfig.maxShowLevel = 3;
	end
	if not QuestieConfig.minLevelFilter then
		QuestieConfig.minLevelFilter = false;
	end
	if not QuestieConfig.minShowLevel then
		QuestieConfig.minShowLevel = false;
		QuestieConfig.minShowLevel = 5;
	end
	if not QuestieConfig.showMapAids then
		QuestieConfig.showMapAids = true;
	end
	if not QuestieConfig.showProfessionQuests then
		QuestieConfig.showProfessionQuests = false;
	end
	if not QuestieConfig.showTrackerHeader then
		QuestieConfig.showTrackerHeader = false;
	end
	if not QuestieConfig.trackerEnabled then
		QuestieConfig.trackerEnabled = true;
	end
	if not QuestieConfig.trackerList then
		QuestieConfig.trackerList = false;
	end
	if not QuestieConfig.resizeWorldmap then
		QuestieConfig.resizeWorldmap = false;
	end
end

QuestieCompat_GetQuestLogTitle = GetQuestLogTitle;
function GetQuestLogTitle(index)
	return QuestieCompat_GetQuestLogTitle(index);
end

function Questie:BlockTranslations()
	if (IsAddOnLoaded("RuWoW") or IsAddOnLoaded("ProffBot")) or (IsAddOnLoaded("ruRU")) then
		QUEST_MONSTERS_KILLED = "%s slain: %d/%d"; -- Lists the monsters killed for the selected quest
		ERR_QUEST_ADD_KILL_SII = "%s slain: %d/%d"; -- %s is the monster name
	end
end

function Questie:OnLoad()
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("QUEST_PROGRESS");
	this:RegisterEvent("ZONE_CHANGED"); -- this actually is needed
	this:RegisterEvent("UI_INFO_MESSAGE");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("QUEST_ITEM_UPDATE");
	this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("CHAT_MSG_LOOT");
	Questie:SetupDefaults();
	Questie:CheckDefaults();
	__QuestAbandonOnAccept = StaticPopupDialogs["ABANDON_QUEST"].OnAccept;
	StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function()
		local hash = Questie:GetHashFromName(GetAbandonQuestName());
		--DEFAULT_CHAT_FRAME:AddMessage("[QuestAbandonOnAccept] Hash number: "..hash);
		QuestieSeenQuests[hash] = -1;
		QuestieTrackedQuests[hash] = nil;
		Questie:AddEvent("CHECKLOG", 0.135);
		__QuestAbandonOnAccept();
		if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
			TomTomCrazyArrow:Hide()
		end
	end
	__QuestAbandonWithItemsOnAccept = StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept;
	StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept = function()
		local hash = Questie:GetHashFromName(GetAbandonQuestName());
		--DEFAULT_CHAT_FRAME:AddMessage("[QuestAbandonWithItemsOnAccept] Hash number: "..hash);
		QuestieSeenQuests[hash] = -1;
		QuestieTrackedQuests[hash] = nil;
		Questie:AddEvent("CHECKLOG", 0.135);
		__QuestAbandonWithItemsOnAccept();
		if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
			TomTomCrazyArrow:Hide()
		end
	end
	__QuestRewardCompleteButton_OnClick = QuestRewardCompleteButton_OnClick;
	QuestRewardCompleteButton_OnClick = function()
		if not ( QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
			if IsAddOnLoaded("EQL3") then
				local questTitle = GetTitleText();
				local _, _, level, qName = string.find(questTitle, "%[(.+)%] (.+)")
				--DEFAULT_CHAT_FRAME:AddMessage("[QuestRewardCompleteButton_OnClick] Level: "..level.." | Title: "..questTitle.." | String.Find: "..qName);
				local hash = Questie:GetHashFromName(qName);
				QuestieCompletedQuestMessages[qName] = 1;
				if(not QuestieSeenQuests[hash]) or (QuestieSeenQuests[hash] == 0) or (QuestieSeenQuests[hash] == -1) then
					--DEFAULT_CHAT_FRAME:AddMessage("[QuestRewardCompleteButton_OnClick]Adding quest to seen quests:"..qName.." , "..hash.." setting as 1 = complete");
					Questie:finishAndRecurse(hash)
					QuestieTrackedQuests[hash] = nil;
					Questie:AddEvent("CHECKLOG", 0.135);
					if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
						TomTomCrazyArrow:Hide()
					end
				else
					DEFAULT_CHAT_FRAME:AddMessage("WARNING: No quest could be found to complete! Please submit a bug for this questname/hash: "..qName.."/"..hash);
				end
			elseif (not IsAddOnLoaded("EQL3")) then
				local qName = GetTitleText();
				local hash = Questie:GetHashFromName(qName);
				QuestieCompletedQuestMessages[qName] = 1;
				if(not QuestieSeenQuests[hash]) or (QuestieSeenQuests[hash] == 0) or (QuestieSeenQuests[hash] == -1) then
					--DEFAULT_CHAT_FRAME:AddMessage("[QuestRewardCompleteButton_OnClick]Adding quest to seen quests:"..qName.." , "..hash.." setting as 1 = complete");
					Questie:finishAndRecurse(hash)
					QuestieTrackedQuests[hash] = nil;
					Questie:AddEvent("CHECKLOG", 0.135);
					if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
						TomTomCrazyArrow:Hide()
					end
				else
					DEFAULT_CHAT_FRAME:AddMessage("WARNING: No quest could be found to complete! Please submit a bug for this questname/hash: "..qName.."/"..hash);
				end
			end
		end
		__QuestRewardCompleteButton_OnClick();
	end
	Questie:NOTES_LOADED();
	SlashCmdList["QUESTIE"] = Questie_SlashHandler;
	SLASH_QUESTIE1 = "/questie";
end

Active = true;
function Questie:Toggle()
	if (QuestieConfig.showMapAids == true) or (QuestieConfig.alwaysShowQuests == true) or ((QuestieConfig.showMapAids == true) and (QuestieConfig.alwaysShowQuests == false)) then
		if(Active == true) then
			Active = false;
			QuestieMapNotes = {};
			QuestieAvailableMapNotes = {};
			Questie:RedrawNotes();
			LastQuestLogHashes = nil;
			LastCount = 0;
		else
			Active = true;
			LastQuestLogHashes = nil;
			LastCount = 0;
			Questie:CheckQuestLog();
			Questie:SetAvailableQuests()
			Questie:RedrawNotes();
		end
	else
		QuestieMapNotes = {};
		QuestieAvailableMapNotes = {};
		Questie:RedrawNotes();
		LastQuestLogHashes = nil;
		LastCount = 0;
	end
end

QUESTIE_EVENTQUEUE = {};
function Questie:OnUpdate(elapsed)
	Astrolabe:OnUpdate(nil, elapsed);
	Questie:NOTES_ON_UPDATE(elapsed);
	if(table.getn(QUESTIE_EVENTQUEUE) > 0) then
		for k, v in pairs(QUESTIE_EVENTQUEUE) do
			if(v.EVENT == "UPDATE" and GetTime()- v.TIME > v.DELAY) then
				while(true) do
					local d = Questie:UpdateQuests();
					if(not d) then
						table.remove(QUESTIE_EVENTQUEUE, 1);
						break;
					end
				end
				Astrolabe.ForceNextUpdate = true;
			elseif(v.EVENT == "CHECKLOG" and GetTime() - v.TIME > v.DELAY) then
				--DEFAULT_CHAT_FRAME:AddMessage("[OnUpdate] Event = CHECKLOG");
				Questie:CheckQuestLog();
				table.remove(QUESTIE_EVENTQUEUE, 1);
				break;
			end
		end
	end
end

QuestieCompletedQuestMessages = {};
-- 1 means WE KNOW it's complete
-- 0 means We've seen it and it's probably in the questlog
-- -1 means we know its abandonnd
--Had to add a delay(Even if it's small)
function Questie:AddEvent(EVENT, DELAY)
	local evnt = {};
	evnt.EVENT = EVENT;
	evnt.TIME = GetTime();
	evnt.DELAY = DELAY;
	table.insert(QUESTIE_EVENTQUEUE, evnt);
end

QUESTIE_LAST_UPDATE = GetTime();
QUESTIE_LAST_CHECKLOG = GetTime();

function Questie:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
	if(event =="ADDON_LOADED" and arg1 == "Questie") then
	elseif(event == "QUEST_LOG_UPDATE" or event == "QUEST_ITEM_UPDATE") then
		if(Active == true) then
			if(GetTime() - QUESTIE_LAST_CHECKLOG > 0.1) then
				Questie:AddEvent("CHECKLOG", 0.135);
				QUESTIE_LAST_CHECKLOG = GetTime();
			else
				Questie:debug_Print("[QuestieEvent] ",event, "Spam Protection: Last checklog was:",GetTime() - QUESTIE_LAST_CHECKLOG, "ago skipping!");
				QUESTIE_LAST_CHECKLOG = GetTime();
			end
			if(GetTime() - QUESTIE_LAST_UPDATE > 0.1) then
				Questie:AddEvent("UPDATE", 0.15);--On my fast PC this seems like a good number
				QUESTIE_LAST_UPDATE = GetTime();
			else
				Questie:debug_Print("[QuestieEvent] ",event, "Spam Protection: Last update was:",GetTime() - QUESTIE_LAST_UPDATE, "ago skipping!");
				QUESTIE_LAST_UPDATE = GetTime();
			end
		end
		Questie:BlockTranslations();
	elseif(event == "QUEST_PROGRESS") then
		if (IsAddOnLoaded("EQL3") and (QuestlogOptions[EQL3_Player].AutoCompleteQuests == 1) and (GetNumQuestChoices() == 0)) then
			if (IsQuestCompletable()) then
				local questTitle = GetTitleText();
				local _, _, level, qName = string.find(questTitle, "%[(.+)%] (.+)")
				--DEFAULT_CHAT_FRAME:AddMessage("[QuestRewardCompleteButton_OnClick] Level: "..level.." | Title: "..questTitle.." | String.Find: "..qName);
				local hash = Questie:GetHashFromName(qName);
				QuestieCompletedQuestMessages[qName] = 1;
				if(not QuestieSeenQuests[hash]) or (QuestieSeenQuests[hash] == 0) or (QuestieSeenQuests[hash] == -1) then
					--DEFAULT_CHAT_FRAME:AddMessage("[QuestRewardCompleteButton_OnClick]Adding quest to seen quests:"..qName.." , "..hash.." setting as 1 = complete");
					Questie:finishAndRecurse(hash)
					QuestieTrackedQuests[hash] = nil;
					Questie:AddEvent("CHECKLOG", 0.135);
					if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
						TomTomCrazyArrow:Hide()
					end
				else
					DEFAULT_CHAT_FRAME:AddMessage("WARNING: No quest could be found to complete! Please submit a bug for this questname/hash: "..qName.."/"..hash);
				end
				CompleteQuest();
			end
		end
	elseif(event == "VARIABLES_LOADED") then
		Questie:debug_Print("VARIABLES_LOADED");
		if(not QuestieSeenQuests) then
			QuestieSeenQuests = {};
		end
		Questie:BlockTranslations();
	elseif(event == "PLAYER_LOGIN") then
		Questie:CheckQuestLog();
		Questie:AddEvent("UPDATE", 1.15);
		local f = GameTooltip:GetScript("OnShow");
		if(f ~= nil) then
			--Proper tooltip hook!
			local Blizz_GameTooltip_Show = GameTooltip.Show
			GameTooltip.Show = function(self)
				Questie:Tooltip(self);
				Blizz_GameTooltip_Show(self)
			end
			local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem
			GameTooltip.SetLootItem = function(self, slot)
				Bliz_GameTooltip_SetLootItem(self, slot)
				Questie:Tooltip(self, true);
			end
		else
			Questie:hookTooltip();
		end
	elseif(event == "CHAT_MSG_LOOT") then
		local _, _, msg, item = string.find(arg1, "(You receive loot%:) (.+)");
		if msg then
			Questie:CheckQuestLog();
		end
	end
end

function findFirst(haystack, needle)
    local i=string.find(haystack, " ")
    if i==nil then return nil else return i-1 end
end

function Questie:finishAndRecurse(questhash)
	local req = QuestieHashMap[questhash]['rq'];
	if req then
		Questie:finishAndRecurse(req);
		QuestieTrackedQuests[req] = nil;
		--DEFAULT_CHAT_FRAME:AddMessage("Requirement: "..req);
	end
	-- I discovered a nasty little 'silent' bug where the Manual Complete functions would set
	-- a quest as complete when it's actually in the players quest log. This check resets the
	-- players quest back to tracked status (== 0) and prevents quests in a chain from being
	-- marked complete when a player is on a certain step.
	if ((QuestieTrackedQuests[questhash] == false) or (QuestieTrackedQuests[questhash] == table)) then
		QuestieSeenQuests[questhash] = 0;
	elseif (QuestieSeenQuests[questhash] == nil) then
		QuestieSeenQuests[questhash] = 1;
	end
end

_QuestieCompleteQuestSelectingOption = false;
_QuestieCompleteQuestSelectingOption_QuestName = nil;

QuestieFastSlash = {
	-- The "complete" command is no longer needed since the Shift+Click via the Worldmap is now
	-- working 100%. Keeping this around just in case...
	--[[["complete"] = function(args)
		--DEFAULT_CHAT_FRAME:AddMessage("   " .. findFirst("This is how it works", " "));
		--DEFAULT_CHAT_FRAME:AddMessage("   " .. args);
		if _QuestieCompleteQuestSelectingOption then
			for k,v in pairs(QuestieLevLookup) do
				if strlower(k) == strlower(_QuestieCompleteQuestSelectingOption_QuestName) then
					if table.getn(v) == 1 then
						for kk,vv in pairs(v) do
							Questie:finishAndRecurse(vv[2]);
						end
					else
						local index = 0;
						for kk,vv in pairs(v) do
							if index == tonumber(args) then
								Questie:finishAndRecurse(vv[2]);
							end
							index = index + 1;
						end
						_QuestieCompleteQuestSelectingOption = false;
					end
					return;
				end
			end
		else
			for k,v in pairs(QuestieLevLookup) do
				if strlower(k) == strlower(args) then
					DEFAULT_CHAT_FRAME:AddMessage(" " .. table.getn(v));
					local questchain = 0;
					for kk,vv in pairs(v) do
						questchain = questchain + 1;
					end
					if questchain == 1 then
						for kk,vv in pairs(v) do
							Questie:finishAndRecurse(vv[2]);
						end
					else
						local index = 0;
						DEFAULT_CHAT_FRAME:AddMessage(" |cFFFF2222There are multiple quests matching the name \"" .. args .. "\"|r");
						DEFAULT_CHAT_FRAME:AddMessage("   |cFFFFFF00Run /questie complete |cFF00FF00<number>|r|cFFFFFF00 to finish the process|r");
						for kk,vv in pairs(v) do
							DEFAULT_CHAT_FRAME:AddMessage("      |cFF00FF00" .. index .. "|r: " .. kk);
							index = index + 1;
						end
						_QuestieCompleteQuestSelectingOption_QuestName = args;
						_QuestieCompleteQuestSelectingOption = true;
					end
					return;
				end
			end
			DEFAULT_CHAT_FRAME:AddMessage(" |cFFFF2222No quest matches the name \"" .. args .. "\"!|r");
		end
	end,]]--
	["color"] = function()
	-- Default: False
		QuestieConfig.boldColors = not QuestieConfig.boldColors;
		if QuestieConfig.boldColors then
			DEFAULT_CHAT_FRAME:AddMessage("QuestTracker Alternate Colors enabled");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("QuestTracker Alternate Colors disabled");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["listdirection"] = function()
	-- Default: False
		if (QuestieConfig.trackerList == false) then
			StaticPopupDialogs["BOTTOM_UP"] = {
				text = "|cFFFFFF00You are about to change the way quests are listed in the QuestTracker. They will grow from bottom --> up and sorted by distance from top --> down.|n|nYour UI will be automatically reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
				button1 = TEXT(YES),
				button2 = TEXT(NO),
				OnAccept = function()
					QuestieConfig.trackerList = true
					QuestieTrackerVariables = {};
					QuestieTrackerVariables["position"] = {
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["relativeTo"] = "UIParent",
						["yOfs"] = 0,
						["xOfs"] = 0,
					};
					ReloadUI()
				end,
				timeout = 120,
				exclusive = 1,
				hideOnEscape = 1
			}
			StaticPopup_Show ("BOTTOM_UP")
		elseif (QuestieConfig.trackerList == true) then
			StaticPopupDialogs["TOP_DOWN"] = {
				text = "|cFFFFFF00You are about to change the tracker back to it's default state. Quests will grow from top --> down and also sorted by distance from top --> down in the QuestTracker.|n|nYour UI will be reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
				button1 = TEXT(YES),
				button2 = TEXT(NO),
				OnAccept = function()
					QuestieConfig.trackerList = false
					QuestieTrackerVariables = {};
					QuestieTrackerVariables["position"] = {
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["relativeTo"] = "UIParent",
						["yOfs"] = 0,
						["xOfs"] = 0,
					};
					ReloadUI()
				end,
				timeout = 60,
				exclusive = 1,
				hideOnEscape = 1
			}
			StaticPopup_Show ("TOP_DOWN")
		end
	end,
	["showquests"] = function()
	-- Default: True
		QuestieConfig.alwaysShowQuests = not QuestieConfig.alwaysShowQuests;
		if QuestieConfig.alwaysShowQuests then
			DEFAULT_CHAT_FRAME:AddMessage("Quests and Objectives: Always show.");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Quests and Objectives: Show only when tracking.");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["mapnotes"] = function()
	-- Default: True
		QuestieConfig.showMapAids = not QuestieConfig.showMapAids;
		if QuestieConfig.showMapAids then
			DEFAULT_CHAT_FRAME:AddMessage("Questie notes Active!");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Questie notes removed!");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["arrow"] = function()
	-- Default: True
		QuestieConfig.arrowEnabled = not QuestieConfig.arrowEnabled;
		if QuestieConfig.arrowEnabled then
			DEFAULT_CHAT_FRAME:AddMessage("Quest Arrow will now be shown");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Quest Arrow will now be hidden");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["tracker"] = function()
	-- Default: True
		QuestieConfig.trackerEnabled = not QuestieConfig.trackerEnabled;
		if QuestieConfig.trackerEnabled then
			DEFAULT_CHAT_FRAME:AddMessage("Quest Tracker will now be shown");
			QuestieTracker:Show();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Quest Tracker will now be hidden");
			QuestieTracker:Hide()
			QuestieTracker.frame:Hide()
		end
	end,
	["header"] = function()
	-- Default: False
		if (QuestieConfig.trackerList == false) and (QuestieConfig.showTrackerHeader == false) then
			StaticPopupDialogs["TRACKER_HEADER_F"] = {
				text = "|cFFFFFF00Due to the way the QuestTracker frame is rendered, your UI will automatically be reloaded.|n|nAre you sure you want to continue?|r",
				button1 = TEXT(YES),
				button2 = TEXT(NO),
				OnAccept = function()
					QuestieConfig.showTrackerHeader = true;
					ReloadUI()
				end,
				timeout = 60,
				exclusive = 1,
				hideOnEscape = 1
			}
			StaticPopup_Show ("TRACKER_HEADER_F")
		end
		if (QuestieConfig.trackerList == false) and (QuestieConfig.showTrackerHeader == true) then
			StaticPopupDialogs["TRACKER_HEADER_T"] = {
				text = "|cFFFFFF00Due to the way the QuestTracker frame is rendered, your UI will automatically be reloaded.|n|nAre you sure you want to continue?|r",
				button1 = TEXT(YES),
				button2 = TEXT(NO),
				OnAccept = function()
					QuestieConfig.showTrackerHeader = false;
					ReloadUI()
				end,
				timeout = 60,
				exclusive = 1,
				hideOnEscape = 1
			}
			StaticPopup_Show ("TRACKER_HEADER_T")
		end
		if (QuestieConfig.trackerList == true) then
			QuestieConfig.showTrackerHeader = not QuestieConfig.showTrackerHeader;
			if QuestieConfig.showTrackerHeader then
				DEFAULT_CHAT_FRAME:AddMessage("Quest Tracker Header will now be shown");
				QuestieTrackerHeader:Show();
			else
				DEFAULT_CHAT_FRAME:AddMessage("Quest Tracker Header will now be hidden");
				QuestieTrackerHeader:Hide();
			end
		end
	end,
	["minlevel"] = function()
	-- Default: False
		QuestieConfig.minLevelFilter = not QuestieConfig.minLevelFilter;
		if QuestieConfig.minLevelFilter then
			DEFAULT_CHAT_FRAME:AddMessage("Min-level filter on");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Min-level filter off");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["maxlevel"] = function()
	-- Default: False
		QuestieConfig.maxLevelFilter = not QuestieConfig.maxLevelFilter;
		if QuestieConfig.maxLevelFilter then
			DEFAULT_CHAT_FRAME:AddMessage("Max-level filter on");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Max-level filter off");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["setminlevel"] = function(args)
	-- Default: 5 levels below current level - which is the Blizzard default
		if args then
			local val = tonumber(args);
			QuestieConfig.minShowLevel = val;
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid number supplied!");
		end
	end,
	["setmaxlevel"] = function(args)
	-- Default: Quest will not appear until current level is 3 levels above Blizzards suggested level
		if args then
			local val = tonumber(args);
			QuestieConfig.maxShowLevel = val;
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid number supplied!");
		end
	end,
	["professions"] = function()
	-- Default: False
		QuestieConfig.showProfessionQuests = not QuestieConfig.showProfessionQuests;
		if QuestieConfig.showProfessionQuests then
			DEFAULT_CHAT_FRAME:AddMessage("Profession quests will now be shown");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Profession quests will now be hidden");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["resizemap"] = function()
	-- Default: False
		QuestieConfig.resizeWorldmap = not QuestieConfig.resizeWorldmap;
		if QuestieConfig.resizeWorldmap then
			ReloadUI()
		else
			ReloadUI()
		end
	end,
	["clearconfig"] = function()
	-- Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
		StaticPopupDialogs["CLEAR_CONFIG"] = {
			text = "|cFFFFFF00You are about to clear your characters settings. This will NOT delete your quest database but it will clean it up a little. This will reset abandonded quests, and remove any finished or stale quest entries in the QuestTracker database. Your UI will be reloaded automatically to finalize the new settings.|n|nAre you sure you want to continue?|r",
			button1 = TEXT(YES),
			button2 = TEXT(NO),
			OnAccept = function()
				-- Clears config
				QuestieConfig = {}
				-- Setup default settings
				QuestieConfig = {
					["alwaysShowDistance"] = false,
					["alwaysShowLevel"] = true,
					["alwaysShowQuests"] = true,
					["arrowEnabled"] = true,
					["boldColors"] = false,
					["maxLevelFilter"] = false,
					["maxShowLevel"] = 3,
					["minLevelFilter"] = false,
					["minShowLevel"] = 5,
					["showMapAids"] = true,
					["showProfessionQuests"] = false,
					["showTrackerHeader"] = false,
					["trackerEnabled"] = true,
					["trackerList"] = false,
					["resizeWorldmap"] = false,
				}
				-- Clears tracker settings
				QuestieTrackerVariables = {}
				-- Setup default settings and repositions the QuestTracker against the left side of the screen.
				QuestieTrackerVariables = {
					["position"] = {
						["relativeTo"] = "UIParent",
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["yOfs"] = 0,
						["xOfs"] = 0,
					},
				}
				-- The following will clean up the Quest Database removing stale/invalid entries.
				-- The (== 0 in QuestieSeenQuests) flag usually means a quest has been picked up and the (== -1
				-- in QuestieSeenQuests) flag means the quest has been abandonded. Once we remove these flags
				-- Questie will readd the quests based on what is in your log. A refresh of sorts without
				-- touching or resetting your finished quests. When the quest log is crawled, Questie will
				-- check any prerequired quests and flag all those as complete upto the quest in your chain
				-- that you're currently on.
				local index = 0
				for i,v in pairs(QuestieSeenQuests) do
					if (v == 0) or (v == -1) then
						QuestieSeenQuests[i] = nil
					end
					index = index + 1
				end
				-- This wipes the QuestTracker database and forces a refresh of all tracked data.
				QuestieTrackedQuests = {}
				ReloadUI()
			end,
			timeout = 60,
			exclusive = 1,
			hideOnEscape = 1
		}
		StaticPopup_Show ("CLEAR_CONFIG")
	end,
	["NUKE"] = function()
	-- Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
		StaticPopupDialogs["NUKE_CONFIG"] = {
			text = "|cFFFFFF00You are about to compleatly wipe your characters saved variables. This includes all quests you've completed, settings and preferences, and QuestTracker location.|n|nAre you sure you want to continue?|r",
			button1 = TEXT(YES),
			button2 = TEXT(NO),
			OnAccept = function()
				-- Clears all quests
				QuestieSeenQuests = {}
				-- Clears all tracked quests
				QuestieTrackedQuests = {}
				-- Clears config
				QuestieConfig = {}
				-- Setup default settings
				QuestieConfig = {
					["alwaysShowDistance"] = false,
					["alwaysShowLevel"] = true,
					["alwaysShowQuests"] = true,
					["arrowEnabled"] = true,
					["boldColors"] = false,
					["maxLevelFilter"] = false,
					["maxShowLevel"] = 3,
					["minLevelFilter"] = false,
					["minShowLevel"] = 5,
					["showMapAids"] = true,
					["showProfessionQuests"] = false,
					["showTrackerHeader"] = false,
					["trackerEnabled"] = true,
					["trackerList"] = false,
					["resizeWorldmap"] = false,
				}
				-- Clears tracker settings
				QuestieTrackerVariables = {}
				QuestieTrackerVariables = {
					["position"] = {
						["relativeTo"] = "UIParent",
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["yOfs"] = 0,
						["xOfs"] = 0,
					},
				}
				ReloadUI()
			end,
			timeout = 60,
			exclusive = 1,
			hideOnEscape = 1
		}
		StaticPopup_Show ("NUKE_CONFIG")
	end,
	["cleartracker"] = function()
	-- Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
		StaticPopupDialogs["CLEAR_TRACKER"] = {
			text = "|cFFFFFF00You are about to reset your QuestTracker. This will only reset it's saved location and place it in the center of your screen. Your UI will be reloaded automatically.|n|nAre you sure you want to continue?|r",
			button1 = TEXT(YES),
			button2 = TEXT(NO),
			OnAccept = function()
				-- Clears tracker settings
				QuestieTrackerVariables = {}
				-- Setup default settings and repositions the QuestTracker against the left side of the screen.
				QuestieTrackerVariables = {
					["position"] = {
						["relativeTo"] = "UIParent",
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["yOfs"] = 0,
						["xOfs"] = 0,
					},
				}
				ReloadUI()
			end,
			timeout = 60,
			exclusive = 1,
			hideOnEscape = 1
		}
		StaticPopup_Show ("CLEAR_TRACKER")
	end,
	["settings"] = function()
		QuestieTracker:CurrentUserToggles()
	end,
	["help"] = function()
		DEFAULT_CHAT_FRAME:AddMessage("Questie SlashCommand Help Menu:", 1, 0.75, 0);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie arrow |r-- |c0000ffc0(toggle)|r QuestArrow", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie clearconfig |r-- Resets Questie settings. It does NOT delete your quest data.", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie cleartracker |r-- Relocates the QuestTracker to the center of your screen.", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie color |r-- Select from two different color schemes", 0.75, 0.75, 0.75);
		--DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie complete|r |c0000ffc0<quest name>|r -- Manually complete quests", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie header |r-- |c0000ffc0(toggle)|r QuestTracker log counter", 0.75, 0.75, 0.75);
		--DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie getpos |r-- Prints the player's map coordinates", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie listdirection |r-- Lists quests Top-->Down or Bottom-->Up", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mapnotes |r-- |c0000ffc0(toggle)|r World/Minimap icons", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie maxlevel |r-- |c0000ffc0(toggle)|r Max-Level Filter", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie minlevel |r-- |c0000ffc0(toggle)|r Min-Level Filter", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie NUKE |r-- Resets ALL Questie data and settings", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie professions |r-- |c0000ffc0(toggle)|r Profession quests", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setmaxlevel |r|c0000ffc0<number>|r -- Hides quests until <X> levels above players level (default=3)", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setminlevel |r|c0000ffc0<number>|r -- Hides quests <X> levels below players level (default=5)", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie settings |r-- Displays your current toggles and settings.", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie showquests |r-- |c0000ffc0(toggle)|r Always show quests and objectives", 0.75, 0.75, 0.75);
		DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tracker |r-- |c0000ffc0(toggle)|r QuestTracker", 0.75, 0.75, 0.75);
		if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then
			return
		elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
			DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie resizemap |r-- |c0000ffc0(toggle)|r Resize Worldmap", 0.75, 0.75, 0.75);
		end
	end,
};

function Questie_SlashHandler(msgbase)
	local space = findFirst(msgbase, " ");
	local msg, args;
	if not space or space == 1 then
		msg = msgbase;
	else
		msg = string.sub(msgbase, 1, space);
		args = string.sub(msgbase, space+2);
	end
	if QuestieFastSlash[msg] ~= nil then
		QuestieFastSlash[msg](args);
	else
		if (not msg or msg=="") then
			QuestieFastSlash["help"]();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Unknown operation: " .. msg .. " try /questie help");
		end
	end
end

function Questie:hookTooltip()
	local _GameTooltipOnShow = GameTooltip:GetScript("OnShow") -- APPARENTLY this is always null, and doesnt need to be called for things to function correctly...?
	GameTooltip:SetScript("OnShow", function(self, arg)
		Questie:Tooltip(self);
		this:Show();
	end)
end

Questie_LastTooltip = GetTime();
QUESTIE_DEBUG_TOOLTIP = nil;
function Questie:Tooltip(this, forceShow, bag, slot)
	local monster = UnitName("mouseover")
	local objective = GameTooltipTextLeft1:GetText();
	if monster and GetTime() - Questie_LastTooltip > 0.1 then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if (obj) then --- bad habit I know...
				for name,m in pairs(obj) do
					if m[1] and (m[1]['type'] == "monster" or m[1]['type'] == "slay") then
						if (monster .. " slain") == name or monster == name or monster == string.find(monster, string.len(monster)-6) then
							local logid = Questie:GetQuestIdFromHash(k);
							if logid then
								SelectQuestLogEntry(logid);
								local desc, typ, done = GetQuestLogLeaderBoard(m[1]['objectiveid']);
								local indx = findLast(desc, ":");
								local countstr = string.sub(desc, indx+2);
								GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
								GameTooltip:AddLine("   " .. monster .. ": " .. countstr, 1, 1, 0.2)
							end
						end
					elseif m[1] and (m[1]['type'] == "item" or m[1]['type'] == "loot") then --Added Loot here? should it be here?
						local monroot = QuestieMonsters[monster];
						if monroot then
							local mondat = monroot['drops'];
							if mondat and mondat[name] then
								if mondat[name] then
									local logid = Questie:GetQuestIdFromHash(k);
									if logid then
										SelectQuestLogEntry(logid);
										local desc, typ, done = GetQuestLogLeaderBoard(m[1]['objectiveid']);
										local indx = findLast(desc, ":");
										local countstr = string.sub(desc, indx+2);
										GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
										GameTooltip:AddLine("   " .. name .. ": " .. countstr, 1, 1, 0.2)
									end
								end
							else
								--Use the cache not to run unessecary objectives
								local p = nil;
								for dropper, value in pairs(QuestieCachedMonstersAndObjects[k]) do
									if(string.find(dropper, monster)) then
										local logid = Questie:GetQuestIdFromHash(k);
										if logid then
											SelectQuestLogEntry(logid);
											local count =  GetNumQuestLeaderBoards();
											for obj = 1, count do
												local desc, typ, done = GetQuestLogLeaderBoard(obj);
												local indx = findLast(desc, ":");
												local countstr = string.sub(desc, indx+2);
												local namestr = string.sub(desc, 1, indx-1);
												if(string.find(name, monster) and QuestieItems[namestr] and QuestieItems[namestr]['drop']) then -- Added Find to fix zapped giants (THIS IS NOT TESTED IF YOU FIND ERRORS REPORT!)
													for dropperr, id in pairs(QuestieItems[namestr]['drop']) do
														if(name == dropperr or (string.find(name, dropperr) and name == dropperr) and not p) then-- Added Find to fix zapped giants (THIS IS NOT TESTED IF YOU FIND ERRORS REPORT!)
															GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
															GameTooltip:AddLine("   " .. namestr .. ": " .. countstr, 1, 1, 0.2)
															p = true;
															break;
														end
													end
												end
											end
										end
									end
									if(p)then
										break;
									end
								end
							end
						end
					end
			end
			end
		end
	elseif objective and GetTime() - Questie_LastTooltip > 0.05 then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if ( obj ) then
				for name,m in pairs(obj) do
					if (m[1] and m[1]['type'] == "object") then
						local i, j = string.gfind(name, objective);
						if(i and j and QuestieObjects[m["name"]]) then
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							GameTooltip:AddLine("   " .. name, 1, 1, 0.2)
						end
					elseif (m[1] and (m[1]['type'] == "item" or m[1]['type'] == "loot") and name == objective) then
						if(QuestieItems[objective]) then
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							local logid = Questie:GetQuestIdFromHash(k);
							SelectQuestLogEntry(logid);
							local desc, typ, done = GetQuestLogLeaderBoard(m[1]['objectiveid']);
							local indx = findLast(desc, ":");
							local countstr = string.sub(desc, indx+2);
							GameTooltip:AddLine("   " .. name .. ": " .. countstr, 1, 1, 0.2)
						end
					end
				end
			end
		end
	end
	if(QUESTIE_DEBUG_TOOLTIP) then
		GameTooltip:AddLine("--Questie hook--")
	end
	if(forceShow) then
		GameTooltip:Show();
	end
	Questie_LastTooltip = GetTime();
end

function Questie:LinkToID(link)
	if link then
		local _, _, id = string.find(link, "(%d+):")
		return tonumber(id)
	end
end

lastShow = GetTime();
QWERT = nil;

--[[ OLD CODE BELOW! ]]--

_GetQuestLogQuestText = GetQuestLogQuestText;
function GetQuestLogQuestText()
	Questie.needsUpdate = true;
	return _GetQuestLogQuestText(); -- why was this return removed?
end

function getCurrentMapID()
	local file = GetMapInfo()
	if file == nil then -- thanks optim for finding a null bug here
		return -1
	end
	local zid = QuestieZones[file];
	if zid == nil then
		return -1
	else
		return zid[1];
	end
end

function Questie:getQuestHash(name, level, objectiveText)
	local hashLevel = level or "hashLevel"
	local hashText = objectiveText or "hashText"
	if QuestieQuestHashCache[name..hashLevel..hashText] then
		return QuestieQuestHashCache[name..hashLevel..hashText]
	end
	local questLookup = QuestieLevLookup[name];
	local hasOthers = false;
	if questLookup then
		local count = 0;
		local retval = 0;
		local bestDistance = 4294967295; -- some high number (0xFFFFFFFF)
		local race = UnitRace("Player");
		for k,v in pairs(questLookup) do
			local rr = v[1];
			if checkRequirements(null, race, null, rr) or true then
				if count == 1 then
					hasOthers = true;
				end
				if k == objectiveText then
					QuestieQuestHashCache[name..hashLevel..hashText] = v[2];
					return v[2],hasOthers; -- exact match
				end
				local dist = 4294967294;
				if not (objectiveText == nil) then
					dist = Questie:levenshtein(objectiveText, k);
				end
				if dist < bestDistance then
					bestDistance = dist;
					retval = v[2];
				end
			else
			end
			count = count + 1;
		end
		if not (retval == 0) then
			QuestieQuestHashCache[name..hashLevel..hashText] = retval;
			return retval, hasOthers; -- nearest match
		end
	end
	if name == nil then
		return -1;
	end
	local hash = Questie:mixString(0, name);
	if not (level == nil) then
		hash = Questie:mixInt(hash, level);
		QuestieQuestHashCache[name..hashLevel..hashText] = hash;
	end
	if not (objectiveText == nil) then
		hash = Questie:mixString(hash, objectiveText);
		QuestieQuestHashCache[name..hashLevel..hashText] = hash;
	end
	QuestieQuestHashCache[name..hashLevel..hashText] = hash;
	return hash, false;
end

function Questie:mixString(mix, str)
	return Questie:mixInt(mix, Questie:HashString(str));
end

function Questie:HashString(text) -- Computes an Adler-32 checksum. (Thanks QuestHelper)
	local a, b = 1, 0
	for i=1,string.len(text) do
		a = Questie:modulo((a+string.byte(text,i)), 65521)
		b = Questie:modulo((b+a), 65521)
	end
	return b*65536+a
end

function Questie:modulo(val, by) -- lua5 doesnt support mod math via the % operator :(
	return val - math.floor(val/by)*by
end

function Questie:mixInt(hash, addval)
	return bit.lshift(hash, 6) + addval;
end

-- Returns the Levenshtein distance between the two given strings
-- credit to https://gist.github.com/Badgerati/3261142
function Questie:levenshtein(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0
	-- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	-- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
	-- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (string.byte(str1,i) == string.byte(str2,j)) then
				cost = 0
			else
				cost = 1
			end
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	-- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end

function findLast(haystack, needle)
	local i=string.gfind(haystack, ".*"..needle.."()")()
	if i==nil then return nil else return i-1 end
end