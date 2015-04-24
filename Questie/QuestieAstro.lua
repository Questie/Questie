
DEBUG_LEVEL = 1;--0 Low info --1 Medium info --2 very spammy
Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate")


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

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("Questie v1.1BETA loaded");
	end
	Questie:NOTES_LOADED();

	SlashCmdList["QUESTIE"] = Questie_SlashHandler;
	SLASH_QUESTIE1 = "/questie";
end

Active = true;
function Questie:Toggle()
	if(Active == true) then
		Active = false;
		MapNotes = {};
		Questie:RedrawNotes();
		LastQuestLogHashes = nil;
		LastCount = 0;
		DEFAULT_CHAT_FRAME:AddMessage("Questie notes removed!");
	else
		Active = true;
		LastQuestLogHashes = nil;
		LastCount = 0;		
		Questie:CheckQuestLog();
		Questie:RedrawNotes();
		DEFAULT_CHAT_FRAME:AddMessage("Questie notes Active!");
	end
end

function Questie:OnUpdate(elapsed)
	Astrolabe:OnUpdate(nil, elapsed);
	Questie:NOTES_ON_UPDATE(elapsed);
end

function Questie:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
	if(event =="ADDON_LOADED" and arg1 == "Questie") then

	elseif(event == "QUEST_LOG_UPDATE") then
		if(Active == true) then
			Questie:debug_Print("QUEST_LOG_UPDATE");
			Questie:CheckQuestLog();
			Questie:UpdateQuests();
		end
	elseif(event == "VARIABLES_LOADED") then
		Questie:debug_Print("VARIABLES_LOADED");
	elseif(event == "PLAYER_LOGIN") then
		Questie:CheckQuestLog();
		for i=0, 20 do
			Questie:UpdateQuests();
		end

		local f = GameTooltip:GetScript("OnShow");

		if(f ~= nil) then
			--Proper tooltip hook!
			local Blizz_GameTooltip_Show = GameTooltip.Show
			GameTooltip.Show = function(self)
				Questie:Tooltip(self);
				Blizz_GameTooltip_Show(self)
			end
		else
			Questie:hookTooltip();
		end
	end
end

function Questie_SlashHandler(msg)

	if (msg=="show" or msg=="hide") then msg = ""; end
	if (not msg or msg=="") then
		--Base command
		DEFAULT_CHAT_FRAME:AddMessage("SlashCommand Used - No help implemented yet\n Goto: http://github.com/AeroScripts/QuestieDev/ for help");--Use internal print instead.
	end

	if(msg == "test") then --Tests the questie notes part
		DEFAULT_CHAT_FRAME:AddMessage("Adding icons zones");
		for i = 1, 1 do
			Questie:AddNoteToMap(1, 15, 0.5, 0.5,"complete", tostring(i));
			--Questie:AddNoteToMap(2, 12, 0.8, 0.8,"Loot", "2");
			--Questie:AddNoteToMap(2, 12, 0.9, 0.9,"Object", "3");
			--Questie:AddNoteToMap(2, 12, 0.4, 0.9,"Slay", "4");
		end
		Questie:RedrawNotes();
	end

	if(msg == "getpos") then
		local c,z,x,y = Astrolabe:GetCurrentPlayerPosition();
		if(IsAddOnLoaded("URLCopy"))then
			Questie:debug_Print(URLCopy_Link(x..","..y));
		else
			Questie:debug_Print(x..","..y);
		end
	end

	if(msg == "c") then
		if(GameTooltip.Show) then
			Questie:debug_Print("Something has hooked the tooltip, we hook show!");
			--Questie:hookTooltip();
			--local _GameTooltipOnShow = GameTooltip.Show -- APPARENTLY this is always null, and doesnt need to be called for things to function correctly...?
			GameTooltip.OldShow = GameTooltip.Show
			Questie:debug_Print(tostring(GameTooltip.Show));
			GameTooltip:SetScript("OnShow", function()
				
				this:OldShow();
				Questie:Tooltip();
				GameTooltip:Show();
			end)
		else
			Questie:debug_Print("Nothing seems to have hooked show we set it to our own.");
			Questie:hookTooltip();
		end
	end

	if(msg == "u") then
		local t = GetTime();
		for k, v in pairs(Questie:AstroGetAllCurrentQuestHashes()) do
			Questie:debug_Print("Updating", v["hash"])
			Questie:UpdateQuestNotes(v["hash"]);
		end
		Questie:debug_Print("Updated all quests: Time:", GetTime()- t);
		Questie:RedrawNotes();
		--Questie:AddQuestToMap(2743610414);
		--Questie:AddQuestToMap(3270662498);
	end

	if(msg == "q") then
		local t = GetTime();
		for k, v in pairs(Questie:AstroGetAllCurrentQuestHashes()) do
			Questie:AddQuestToMap(v["hash"]);
		end
		Questie:debug_Print("Added quests: Time:", GetTime()- t);
		Questie:RedrawNotes();
		--Questie:AddQuestToMap(2743610414);
		--Questie:AddQuestToMap(3270662498);
	end

	if(msg == "h") then
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
	end

	if(msg =="ast") then -- Don't want to remove this... good for reference
		--/script Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,,1,"Ashenvale",100,100);

		local f = CreateFrame("Button",nil,WorldMapFrame)
		f.YoMamma = "Hashisbest";
		f:SetFrameStrata("DIALOG")
		f:SetWidth(16)  -- Set These to whatever height/width is needed 
		f:SetHeight(16) -- for your Texture

		local t = f:CreateTexture(nil,"BACKGROUND")
		t:SetTexture("Interface\\AddOns\\Questie\\Icons\\complete")
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
	end


	if(msg == "glowtest") then
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

function Questie:Tooltip(this)
	--DEFAULT_CHAT_FRAME:AddMessage("HEJ");
	local monster = UnitName("mouseover")
	local objective = GameTooltipTextLeft1:GetText();
	if monster then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if (obj) then --- bad habit I know...
				for name,m in pairs(obj) do
					if m[1]['type'] == "monster" or m[1]['type'] == "slay" then
						if (monster .. " slain") == name or monster == name or monster == string.find(monster, string.len(monster)-6) then
							local logid = Questie:GetQuestIdFromHash(k);
		  					SelectQuestLogEntry(logid);
		  					local desc, typ, done = GetQuestLogLeaderBoard(m[1]['objectiveid']);
		  					local indx = findLast(desc, ":");
							local countstr = string.sub(desc, indx+2);
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							GameTooltip:AddLine("   " .. monster .. ": " .. countstr, 1, 1, 0.2)
						end
				--NOT DONE
					elseif m[1]['type'] == "item" or m[1]['type'] == "loot" then --Added Loot here? should it be here?
						local monroot = QuestieMonsters[monster];
						if monroot then
							local mondat = monroot['drops'];
							if not (mondat == nil) then
								if mondat[name] then
									local logid = Questie:GetQuestIdFromHash(k);
				  					SelectQuestLogEntry(logid);
				  					local desc, typ, done = GetQuestLogLeaderBoard(m[1]['objectiveid']);
				  					local indx = findLast(desc, ":");
									local countstr = string.sub(desc, indx+2);
									GameTooltip:AddLine(k, 0.2, 1, 0.3)
									GameTooltip:AddLine("   " .. name .. ": " .. countstr, 1, 1, 0.2)
								end
							end
						end
					end
				--NOT DONE
				end
			end
		end
	elseif objective then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if ( obj ) then
				for name,m in pairs(obj) do
					Questie:debug_Print(name, objective);
					--NOT DONE
					if (m[1]['type'] == "object") then
						local i, j = string.gfind(name, objective);
						if(i and j and QuestieObjects[m["name"]]) then
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							GameTooltip:AddLine("   " .. name, 1, 1, 0.2)
						end
					--NOT DONE
					elseif ((m[1]['type'] == "item" or m[1]['type'] == "loot") and name == objective) then
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
	GameTooltip:AddLine("DEBUG TOOLTIP IS WORKING");
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

	
	local questLookup = QuestieLevLookup[name];
	if not (questLookup == nil) then -- cant... stop... doingthis....
		--log("QN " .. name .. " is NULL", 1);
		local count = 0;
		local retval = 0;
		local bestDistance = 4294967295; -- some high number (0xFFFFFFFF)
		for k,v in pairs(questLookup) do
			if k == objectiveText then
				return v; -- exact match
			end
			local dist = Questie:levenshtein(objectiveText, k);
			if dist < bestDistance then
				bestDistance = dist;
				retval = v;
			end
			count = count + 1;
		end
		if not (retval == 0) then
			return retval; -- nearest match
		end
	end
	
	-- hash lookup did not contain qust name!! LOG THIS!!!
	local hash = Questie:mixString(0, name);
	hash = Questie:mixInt(hash, level);
	hash = Questie:mixString(hash, objectiveText);
	return hash;
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