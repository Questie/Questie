
DEBUG_LEVEL = 1;--0 Low info --1 Medium info --2 very spammy
Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate")


__QuestRewardCompleteButton_OnClick=nil;
__QuestAbandonOnAccept=nil;

local QuestieQuestHashCache = {}


if not QuestieConfig.showLowLevel then
	QuestieConfig.showLowLevel = false;
end

if not QuestieConfig.showProfessionQuests then
	QuestieConfig.showProfessionQuests = false;
end

function Questie:OnLoad()

	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("ZONE_CHANGED"); -- this actually is needed
	this:RegisterEvent("UI_INFO_MESSAGE");
	this:RegisterEvent("CHAT_MSG_SYSTEM");

	this:RegisterEvent("QUEST_ITEM_UPDATE");
	this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");

	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	this:RegisterEvent("PLAYER_LOGIN")
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("CHAT_MSG_SYSTEM");

	__QuestRewardCompleteButton_OnClick = QuestRewardCompleteButton_OnClick;
	__QuestAbandonOnAccept = StaticPopupDialogs["ABANDON_QUEST"].OnAccept;

	StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function()
		local hash = Questie:GetHashFromName(GetAbandonQuestName());
		QuestieSeenQuests[hash] = nil;
		Questie:AddEvent("CHECKLOG", 0.135);
		__QuestAbandonOnAccept();
	end
	QuestRewardCompleteButton_OnClick = function()
		if not ( QuestFrameRewardPanel.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
			local qName = GetTitleText(); -- lol
			local hash = Questie:GetHashFromName(qName); -- this is a bad idea. A VERY bad idea.
			QuestieCompletedQuestMessages[qName] = 1;
			Questie:AddEvent("CHECKLOG", 0.135);
			if(not QuestieSeenQuests[hash]) then
				Questie:debug_Print("Adding quest to seen quests:", qName, hash," setting as 1 = complete");
				QuestieSeenQuests[hash] = 1;
			else
				Questie:debug_Print("Adding quest to seen quests:", qName, hash," setting as 1 = complete");
				QuestieSeenQuests[hash] = 1;
			end
		end
		__QuestRewardCompleteButton_OnClick();
	end

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("Questie v2.0.10 BETA loaded");
	end
	Questie:NOTES_LOADED();

	SlashCmdList["QUESTIE"] = Questie_SlashHandler;
	SLASH_QUESTIE1 = "/questie";
end

Active = true;
function Questie:Toggle()
	if(Active == true) then
		Active = false;
		QuestieMapNotes = {};
		QuestieAvailableMapNotes = {};
		Questie:RedrawNotes();
		LastQuestLogHashes = nil;
		LastCount = 0;
	--DEFAULT_CHAT_FRAME:AddMessage("Questie notes removed!");
	else
		Active = true;
		LastQuestLogHashes = nil;
		LastCount = 0;
		Questie:CheckQuestLog();
		Questie:SetAvailableQuests()
		Questie:RedrawNotes();
	--DEFAULT_CHAT_FRAME:AddMessage("Questie notes Active!");
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
			--Questie:debug_Print("[OnEvent] "..event);
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

		--This is an ugly fix... Don't know why the list isn't populated correctly...
		Questie:AddEvent("UPDATE", 1.15); 

		--for k, v in pairs(QuestieSeenQuests) do
		--	if(v == true or v == false) then
		--		v = 0;
		--		Questie:debug_Print("Old quest format found, set to 0");
		--	end
		--end

		local f = GameTooltip:GetScript("OnShow");

		if(f ~= nil) then
			--Proper tooltip hook!
			local Blizz_GameTooltip_Show = GameTooltip.Show
			GameTooltip.Show = function(self)
				Questie:Tooltip(self);
				Blizz_GameTooltip_Show(self)
			end

			--local Blizz_GameTooltip_SetBagItem = GameTooltip.SetBagItem
			--GameTooltip.SetBagItem = function(self, bag, slot)
			--	Blizz_GameTooltip_SetBagItem(self, bag, slot)

			--	Questie:Tooltip(self, true, bag, slot);
			--end

			local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem
			GameTooltip.SetLootItem = function(self, slot)
				Bliz_GameTooltip_SetLootItem(self, slot)

				Questie:Tooltip(self, true);
			end
		else
			Questie:hookTooltip();
		end
	elseif(event == "CHAT_MSG_SYSTEM") then
	--if(string.find(arg1, " completed.")) then
	--	local qName = string.sub(arg1, 0, -string.len("  completed."));
	--	DEFAULT_CHAT_FRAME:AddMessage("Quest Completed: '"..qName.."'");
	--	--Questie:debug_Print("Quest Completed:", qName);
	--
	--end
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
	QuestieSeenQuests[questhash] = 1;
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
					local FUCKLUACOUNTWTF = 0;
					for kk,vv in pairs(v) do
						FUCKLUACOUNTWTF = FUCKLUACOUNTWTF + 1;
					end
					
					if FUCKLUACOUNTWTF == 1 then
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
	["lowlevel"] = function()
		QuestieConfig.showLowLevel = not QuestieConfig.showLowLevel;
		if QuestieConfig.showLowLevel then
			DEFAULT_CHAT_FRAME:AddMessage("Low level quests will now be shown");
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("Low level quests will now be hidden");
			Questie:Toggle();
			Questie:Toggle();
		end
	end,
	["minlevel"] = function(args)
		if args then
			local val = tonumber(args);
			QuestieConfig.minShowLevel = val;
			Questie:Toggle();
			Questie:Toggle();
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid number supplied!");
		end
	
	end,
	["professions"] = function()
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
	["help"] = function()
		DEFAULT_CHAT_FRAME:AddMessage("Questie SlashCommand Help Menu");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie lowlevel -- Toggles low level quest display");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie professions -- Toggles profession quests display");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie getpos -- Prints the player's map coordinates");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie complete <quest name> -- Manually complete quests");
		DEFAULT_CHAT_FRAME:AddMessage("  /questie minlevel <number> -- change available quest minimum calculation number (level - <number>). default is 12 as of 2.0.13, 6 in 2.0.12 or earlier");
	end,
	["test"] = function()
		DEFAULT_CHAT_FRAME:AddMessage("Adding icons zones");
		for i = 1, 1 do
			Questie:AddNoteToMap(1, 15, 0.5, 0.5,"complete", tostring(i));
		--Questie:AddNoteToMap(2, 12, 0.8, 0.8,"Loot", "2");
		--Questie:AddNoteToMap(2, 12, 0.9, 0.9,"Object", "3");
		--Questie:AddNoteToMap(2, 12, 0.4, 0.9,"Slay", "4");
		end
		Questie:RedrawNotes();
	end,
	["getpos"] = function()
		local c,z,x,y = Astrolabe:GetCurrentPlayerPosition();
		x = math.floor(x * 1000);
		y = math.floor(y * 1000);
		x = x / 10;
		y = y / 10;
		
		if(IsAddOnLoaded("URLCopy"))then
			DEFAULT_CHAT_FRAME:AddMessage("Player position: " .. URLCopy_Link(x..","..y));
		else
			DEFAULT_CHAT_FRAME:AddMessage("Player position: " .. x..","..y);
		end
	end,
	["c"] = function()
		Questie:SetAvailableQuests();
	end,
	["u"] = function()
		local t = GetTime();
		for k, v in pairs(Questie:AstroGetAllCurrentQuestHashes()) do
			Questie:debug_Print("Updating", v["hash"])
			Questie:UpdateQuestNotes(v["hash"]);
		end
		Questie:debug_Print("Updated all quests: Time:", GetTime()- t);
		Questie:RedrawNotes();
	end,
	["q"] = function()
		local t = GetTime();
		for k, v in pairs(Questie:AstroGetAllCurrentQuestHashes()) do
			Questie:AddQuestToMap(v["hash"]);
		end
		Questie:debug_Print("Added quests: Time:", GetTime()- t);
		Questie:RedrawNotes();
	end,
	["h"] = function()
		testbutton = CreateFrame("Button", "testets", UIParent,"UIPanelButtonTemplate");
		testbutton:SetWidth(80);
		testbutton:SetHeight(50);
		testbutton:SetText("asdf");
		testbutton:SetPoint("CENTER",0,0);
		testbutton:Show();
		DropDownTest = CreateFrame("Frame", "QuestieDropDown", UIParent, "UIDropDownMenuTemplate");
		DropDownTest:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		UIDropDownMenu_SetWidth(130, DropDownTest);
		UIDropDownMenu_Initialize(DropDownTest, DropDown_OnLoad, "MENU");
		DropDownTest:Show();
		testbutton:SetScript("OnClick", function()
			DEFAULT_CHAT_FRAME:AddMessage("Click");
			ToggleDropDownMenu(nil,nil,DropDownTest,"testets",3,-3);
		end)
	end,
	["getzoneid"] = function()
		Questie:debug_Print(GetCurrentMapContinent(), GetCurrentMapZone());
	end,
	["ast"] = function()

		local f = CreateFrame("Button",nil,WorldMapFrame)
		f.YoMamma = "Hashisbest";
		f:SetFrameStrata("DIALOG")
		f:SetWidth(16)  -- Set These to whatever height/width is needed
		f:SetHeight(16) -- for your Texture

		local t = f:CreateTexture(nil,"BACKGROUND")
		t:SetTexture("Interface\\AddOns\\!Questie\\Icons\\complete")
		t:SetAllPoints(f)
		f.texture = t
		f:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR");
			GameTooltip:AddLine("ICON! "..this.YoMamma);
			GameTooltip:Show();
		end ); --Script Toolip
		f:SetScript("OnLeave", function() if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip

		f:SetPoint("TOPLEFT",0,0)
		f:Show()

		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
		x, y = Astrolabe:TranslateWorldMapPosition(2,12,0.8, 0.8, 2, 0);
		x, y = Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,f,2,nil,x, y);
		if(x and y) then
			DEFAULT_CHAT_FRAME:AddMessage("Added note to Ashenvale "..x.." : "..y);
		else
			DEFAULT_CHAT_FRAME:AddMessage("Failed");
		end
	
	end,
	["glowtest"] = function()
		Questie:debug_Print("GlowTest");
		local w, h = WorldMapFrame:GetWidth(), WorldMapFrame:GetHeight()
		--Setup variables in WorldMapFrame
		--local map_overlay = CreateFrame("Frame","Map_Overlay",UIParent);
		--map_overlay:SetPoint("TOPLEFT",0,0);
		--map_overlay:SetFrameLevel(9);
		--map_overlay:SetWidth(w);
		--map_overlay:SetHeight(h);
		--map_overlay:Show();

		--This calulates a good glow size
		x, y =  GetPlayerMapPosition("player");
		c, z = GetCurrentMapContinent(), GetCurrentMapZone();


		local _, x_size, y_size = Astrolabe:ComputeDistance(c, z, 0.25, 0.25, c, z, 0.75, 0.75)
		--f:SetFrameLevel(8);
		x_size = 200 / x_size * w;
		y_size = 200 / y_size * h;

		local c = Icon("abc");
		local d = Icon("cba");
		d:SetPoint("CENTER",16,0);
		d:Show();

	--We Create a new frame and add the glowtexture to it.
	--local glow = CreateFrame("Button",nil,WorldMapFrame);
	--local tex = Questie:CreateGlowTexture(glow);
	--glow:SetFrameLevel(9);
	--glow:SetWidth(x_size);
	--glow:SetHeight(y_size);
	--glow:SetPoint("CENTER",0,0);
	--glow:Show();

	--local g = Questie:CreateGlowFrame()
	--g:SetPoint("CENTER",0,0);
	--g:Show();

	--local ra = Questie:CreateGlowNote("abc");
	--ra:SetPoint("CENTER",0,0)
	--ra:Show()
	--xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,ra,c ,z ,0.5, 0.5);
	--ra = Questie:CreateGlowNote("abc");
	--ra:SetPoint("CENTER",0,0)
	--ra:Show()
	--xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,ra,c ,z ,0.54, 0.5);
	--ra = Questie:CreateGlowNote("abc");
	--ra:SetPoint("CENTER",0,0)
	--ra:Show()
	--xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,ra,c ,z ,0.5, 0.54);
	--Questie:debug_Print(xx,yy);
	end
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


--[[  Function Hooks ]]--
--Proper tooltip hook!
--local Blizz_GameTooltip_Show = GameTooltip.Show
--GameTooltip.Show = function(self)
--	Questie:Tooltip(self);
--	Blizz_GameTooltip_Show(self)
--end



function Questie:hookTooltip()
	local _GameTooltipOnShow = GameTooltip:GetScript("OnShow") -- APPARENTLY this is always null, and doesnt need to be called for things to function correctly...?
	GameTooltip:SetScript("OnShow", function(self, arg)
		Questie:Tooltip(self);
		this:Show();
	end)

end



Questie_LastTooltip = GetTime(); --Ugly fix to stop tooltip spam....
QUESTIE_DEBUG_TOOLTIP = nil; --Set to nil to disable.
function Questie:Tooltip(this, forceShow, bag, slot) -- this function is making me cry

	local monster = UnitName("mouseover")
	local objective = GameTooltipTextLeft1:GetText();
	--Questie:debug_Print(tostring(forceShow), tostring(monster), tostring(objective));
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
						--NOT DONE
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
					--NOT DONE
			end
			end
		end
	elseif objective and GetTime() - Questie_LastTooltip > 0.05 then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if ( obj ) then
				for name,m in pairs(obj) do
					--NOT DONE
					if (m[1] and m[1]['type'] == "object") then
						local i, j = string.gfind(name, objective);
						if(i and j and QuestieObjects[m["name"]]) then
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							GameTooltip:AddLine("   " .. name, 1, 1, 0.2)
						end
						--NOT DONE
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
--[[







			OLD CODE BELOW!







]]--






_GetQuestLogQuestText = GetQuestLogQuestText;
function GetQuestLogQuestText()
	Questie.needsUpdate = true;
	return _GetQuestLogQuestText(); -- why was this return removed?
end

function getCurrentMapID()

	--Commented this out to prevent stack overflow (because if an endless loop) it's not even used here //Logon
	--local fx, fy = Questie:getPlayerPos(); -- this: does not work here??

	local file = GetMapInfo()

	if file == nil then -- thanks optim for finding a null bug here
		return -1
	end

	local zid = QuestieZones[file];
	if zid == nil then
		--DEFAULT_CHAT_FRAME:AddMessage("ERROR: We are in unknown zone " .. file, 0.95, 0.2, 0.2);
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
	if questLookup then -- cant... stop... doingthis....
		--log("QN " .. name .. " is NULL", 1);
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

	-- hash lookup did not contain qust name!! LOG THIS!!!
	if name == nil then
		--DEFAULT_CHAT_FRAME:AddMessage("QuestieError: Attempt to hash a nill quest?"); -- too lazy to look up proper log function. yeah. super lazy.
		return -1;
	end
	--DEFAULT_CHAT_FRAME:AddMessage("FALLING BACK TO LEGACY");
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
