DEBUG_LEVEL = 0;--0 Low info --1 Medium info --2 very spammy

Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate")

__QuestRewardCompleteButton_OnClick=nil;
__QuestAbandonOnAccept=nil;
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
		["minShowLevel"] = 10,
		["showMapAids"] = true,
		["showProfessionQuests"] = false,
		["showTrackerHeader"] = false,
		["trackerEnabled"] = true,
		["trackerList"] = false,
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
		QuestieConfig.minShowLevel = 10;
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
end

QuestieCompat_GetQuestLogTitle = GetQuestLogTitle;
function GetQuestLogTitle(index)
	return QuestieCompat_GetQuestLogTitle(index);
end

function Questie:OnLoad()
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("ZONE_CHANGED"); -- this actually is needed
	this:RegisterEvent("UI_INFO_MESSAGE");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("QUEST_ITEM_UPDATE");
	this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	Questie:SetupDefaults();
	Questie:CheckDefaults();
	__QuestRewardCompleteButton_OnClick = QuestRewardCompleteButton_OnClick;
	__QuestAbandonOnAccept = StaticPopupDialogs["ABANDON_QUEST"].OnAccept;
	StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function()
		local hash = Questie:GetHashFromName(GetAbandonQuestName());
		QuestieSeenQuests[hash] = -1;
		QuestieTrackedQuests[hash] = nil;
		Questie:AddEvent("CHECKLOG", 0.135);
		__QuestAbandonOnAccept();
		if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
			TomTomCrazyArrow:Hide()
		end
	end
	QuestRewardCompleteButton_OnClick = function()
		if not ( QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
			local qName = GetTitleText(); -- lol
			-- TODO: Investigte getting quest by hash rather than by name for more accurate look up for
			-- quests with more than one step to help with database issues.
			local hash = Questie:GetHashFromName(qName); -- this is a bad idea. A VERY bad idea.
			QuestieCompletedQuestMessages[qName] = 1;
			Questie:AddEvent("CHECKLOG", 0.135);
			if(not QuestieSeenQuests[hash]) or (QuestieSeenQuests[hash] == -1)then
				Questie:debug_Print("Adding quest to seen quests:", qName, hash," setting as 1 = complete");
				QuestieSeenQuests[hash] = 1;
				if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
					TomTomCrazyArrow:Hide()
				end
			else
				Questie:debug_Print("Adding quest to seen quests:", qName, hash," setting as 1 = complete");
				QuestieSeenQuests[hash] = 1;
				if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
					TomTomCrazyArrow:Hide()
				end
			end
		end
		__QuestRewardCompleteButton_OnClick();
	end
	Questie:NOTES_LOADED();
	SlashCmdList["QUESTIE"] = Questie_SlashHandler;
	SLASH_QUESTIE1 = "/questie";
-- Dyaxler: Modify Worldmap in case user doesn't have Cartographer or MetaMap loaded otherwise the Worldmap will be full screen and user can't finish quests or see chat output.
	if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then
		return
	elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
		UIPanelWindows["WorldMapFrame"] =	{ area = "center",	pushable = 0 }
		WorldMapFrame:SetFrameStrata("FULLSCREEN")
		WorldMapFrame:SetScript("OnKeyDown", nil)
		WorldMapFrame:RegisterForDrag("LeftButton")
		WorldMapFrame:EnableMouse(true)
		WorldMapFrame:SetMovable(true)
		WorldMapFrame:SetScale(.8)
		WorldMapTooltip:SetScale(1)
		WorldMapFrame:SetWidth(1024)
		WorldMapFrame:SetHeight(768)
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
		BlackoutWorld:Hide()
		WorldMapFrame:SetScript("OnDragStart", function()
			this:SetWidth(1024)
			this:SetHeight(768)
			this:StartMoving()
		end)
		WorldMapFrame:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()
			this:SetWidth(1024)
			this:SetHeight(768)
			local x,y = this:GetCenter()
			local z = UIParent:GetEffectiveScale() / 2 / this:GetScale()
			x = x - GetScreenWidth() * z
			y = y - GetScreenHeight() * z
			this:ClearAllPoints()
			this:SetPoint("CENTER", "UIParent", "CENTER", x, y)
		end)
		WorldMapFrame:SetScript("OnShow", function()
			local continent = GetCurrentMapContinent();
			local zone = GetCurrentMapZone();
			SetMapZoom(continent, zone);
			SetMapToCurrentZone();
		end)
	end
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
	elseif(event == "VARIABLES_LOADED") then
		Questie:debug_Print("VARIABLES_LOADED");
		if(not QuestieSeenQuests) then
			QuestieSeenQuests = {};
		end
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
	elseif(event == "CHAT_MSG_SYSTEM") then
	end
end

function findFirst(haystack, needle)
    local i=string.find(haystack, " ")
    if i==nil then return nil else return i-1 end
end

function Questie:finishAndRecurse(questhash)
	DEFAULT_CHAT_FRAME:AddMessage("Completing quest |cFF00FF00\"" .. QuestieHashMap[questhash]['name'] .. "\"|r and parent quests");
	local req = QuestieHashMap[questhash]['rq'];
	if req then
		Questie:finishAndRecurse(req);
	end
	if (QuestieTrackedQuests[questhash] == nil) then
		QuestieSeenQuests[questhash] = 1;
	-- I discovered a nasty little 'silent' bug where the Manual Complete functions would set
	-- a quest as complete when it's actually in the players quest log. This check resets the
	-- players quest back to tracked status (== 0) and prevents quests in a chain from being
	-- marked complete when a player is on a certain step.
	elseif ((QuestieTrackedQuests[questhash] == false) or (QuestieTrackedQuests[questhash] == table)) then
		QuestieSeenQuests[questhash] = 0;
	end
end

_QuestieCompleteQuestSelectingOption = false;
_QuestieCompleteQuestSelectingOption_QuestName = nil;

QuestieFastSlash = {
	["complete"] = function(args)
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
	end,
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
	-- Default: 10 levels below current level
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
	-- Default: Quest will not appear until current level is 3 levels above suggested level
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
					["minShowLevel"] = 10,
					["showMapAids"] = true,
					["showProfessionQuests"] = false,
					["showTrackerHeader"] = false,
					["trackerEnabled"] = true,
					["trackerList"] = false,
				}
				-- Clears tracker settings
				QuestieTrackerVariables = {}
				-- Setup default settings and repositions the QuestTracker against the left side of the screen.
				QuestieTrackerVariables = {
					["position"] = {
						["relativeTo"] = "UIParent",
						["point"] = "LEFT",
						["relativePoint"] = "LEFT",
						["yOfs"] = 0,
						["xOfs"] = 0,
					},
				}
				-- If quests are being tracked then they are usually in the
				-- players quest log.
				if QuestieTrackedQuests[hash] then
					-- This flag means a quest has been picked up (== 0)
					if (QuestieSeenQuests[hash] == 0) then
						-- Removes quest entry from the QuestTracker database
						QuestieTrackedQuests[hash] = nil
						-- This re-adds and sets a flag to untrack quest for all
						-- active quests in the quest log.
						QuestieTrackedQuests[hash] = false
					end
				end
				-- This flag means a quest has been abandonded (== -1) and are currently being tracked
				-- then they don't need to be cleared from the database.
				if (QuestieSeenQuests[hash] == -1) and (QuestieTrackedQuests[hash]) then
					-- If it's in the players quest log (I.E. has been picked back up)
					-- then lets reset the '-1' flag by deleting the entry. Questie will
					-- see the quest in the log, if applicable, and reset it to '0'.
					QuestieSeenQuests[hash] = nil
					-- Removes quest entry from the QuestTracker database - Questie will
					-- see the quest in the log, if applicable, and set the flag to
					-- 'false' (untracked).
					QuestieTrackedQuests[hash] = false
				end
				-- If a quest is marked as complete(== 1)
				if (QuestieSeenQuests[hash] == 1) then
					-- Then it doesn't need to be in the QuestTracker database.
					-- Removes quest entry from the QuestTracker database.
					QuestieTrackedQuests[hash] = nil
				end
				-- This is for pure redundancy - If a quest is being tracked or not tracked
				-- then chances are it's in the players quest log. Reset the
				-- 'QuestieSeenQuests' flag to '0'. In case the database was previously in a
				-- bad state and the quest was somehow marked as 'complete' (== 1), this routine
				-- will reset it's status to what it's supposed to be set to.
				if ((QuestieTrackedQuests[hash] == false) or (QuestieTrackedQuests[hash] == table)) then
					QuestieSeenQuests[hash] = 0;
				end
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
				-- Clears config
				QuestieConfig = {}
				-- Clears tracker settings
				QuestieTrackerVariables = {}
				ReloadUI()
			end,
			timeout = 60,
			exclusive = 1,
			hideOnEscape = 1
		}
		StaticPopup_Show ("NUKE_CONFIG")
	end,
	["settings"] = function()
		QuestieTracker:CurrentUserToggles()
	end,
	["help"] = function()
		DEFAULT_CHAT_FRAME:AddMessage("Questie SlashCommand Help Menu:");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie arrow -- (on/off) Quest Arrow");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie clearconfig -- Resets your characters settings. It does NOT delete your quest data.");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie color -- Select from two different color schemes");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie complete <quest name> -- Manually complete quests");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie header -- (on/off) Quest Tracker Header");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie getpos -- Prints the player's map coordinates");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie listdirection -- Lists quests Top-->Down or Bottom-->Up");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie mapaids -- (on/off) World/Minimap icons");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie maxlevel -- (on/off) the Max-Level Filter");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie minlevel -- (on/off) the Min-Level Filter");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie NUKE -- Deletes ALL your settings and quests");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie professions -- (on/off) profession quests");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie setmaxlevel <number> -- Hides quests until <X> levels above players level (default=3)");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie setminlevel <number> -- Hides quests <X> levels below players level (default=10)");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie settings -- Displays your current toggles and settings.");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie showquests -- (on/off) Always show quests and objectives");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie tracker -- (on/off) Quest Tracker");
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