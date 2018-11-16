
Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")

local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()
local AceGUI = LibStub("AceGUI-3.0")
local HBD = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

debug = false
send = true

-- get option value
local function GetGlobalOptionLocal(info)
	return Questie.db.global[info[#info]]
end


-- set option value
local function SetGlobalOptionLocal(info, value)
	if debug and Questie.db.global[info[#info]] ~= value then
		Questie:Printf("DEBUG: global option %s changed from '%s' to '%s'", info[#info], tostring(Questie.db.global[info[#info]]), tostring(value))
	end

	Questie.db.global[info[#info]] = value
end


local function getPlayerContinent()
    local mapID = C_Map.GetBestMapForUnit("player")
    if(mapID) then
        local info = C_Map.GetMapInfo(mapID)
        if(info) then
            while(info['mapType'] and info['mapType'] > 2) do
                info = C_Map.GetMapInfo(info['parentMapID'])
            end
            if(info['mapType'] == 2) then
                return info['mapID']
            end
        end
    end
end

local function getPlayerZone()
	return C_Map.GetBestMapForUnit("player");
end

local function getWorldMapZone()
	return WorldMapFrame:GetMapID();
end

function Questie:OnUpdate()

end

function Questie:SlashTest(input)
	Questie:Print("SlashTest!");
end

function Questie:MySlashProcessorFunc(input)
	--Questie:Print(ChatFrame1, "Hello, World!")
	--SetMessage("test", "test")
		Questie:Print("MySlashProcessorFunc!");

  -- Process the slash command ('input' contains whatever follows the slash command)

end

function Questie:OnEnable()
    -- Called when the addon is enabled
end

function Questie:OnDisable()
    -- Called when the addon is disabled
end


--[[local options = {
    name = "Trade Shout",
    handler = Questie,
    type = "group",
	childGroups = "tab",
    args = {
		general_tab = {
			name = "Messages",
			type = "group",
			order = 10,
			args = {
				enabled = {
					type = "toggle",
					order = 11,
					name = "Enable Questie",
					desc = "Enable or disable addon functionality.",
					width = 200,
					get =	function ()
								return Questie.db.realm.enabled
							end,
					set =	function (info, value)
								Questie.db.realm.enabled = value
								Questie:SetTimer()
							end,
				},
				TSM = {
					type = "toggle",
					order = 11,
					name = "Enable TSM resolve",
					desc = "Enable replacement of %(80% dbmarket) with gold using TSM",
					width = 200,
					get =	function ()
								return Questie.db.char.tsmenabled
							end,
					set =	function (info, value)
								Questie.db.char.tsmenabled = value
							end,
				},
				description = {
					type = "description",
					order = 12,
					fontSize = "medium",
					name = "This addon spams tradechat with preset messages",
				},
				debug_options = {
					type = "header",
					order = 13,
					name = "Messages",
				},
				message = {
					type = "input",
					order = 14,
					name = "Message to announce, one per line",
					desc = "Type the message to announce, every line will be announced.",
					multiline = 7,
					width = "full",
					get = GetGlobalOptionLocal,
					set = SetMessage,
				},
				channel = {
					type = "input",
					order = 15,
					name = "Channel number",
					desc = "What channel should be posted to.",
					width = "normal",
					get = GetGlobalOptionLocal,
					set = SetGlobalOptionLocal,
				},
				timer = {
					type = "range",
					order = 16,
					name = "Announce interval, seconds",
					desc = "How often announce your message to channel.",
					min = 30,
					max = 1800,
					step = 1,
					get = GetGlobalOptionLocal,
					set = SetGlobalOptionLocal,
				},
				test = {
					type = "execute",
					order = 16,
					name = "Test Message",
					desc = "Print next message in say.",
					func = function() Questie:Print(Questie:GetNextMessage()) end,
				},
			},
		}
	}
}]]--


glooobball = ""

function Questie:OnInitialize()
	Questie:RegisterChatCommand("questieclassic", "MySlashProcessorFunc")
	Questie:RegisterChatCommand("test", "SlashTest")
	Questie:RegisterChatCommand("qc", "MySlashProcessorFunc")
	self.db = LibStub("AceDB-3.0"):New("QuestieDB", defaults, true)


	x, y, z = HBD:GetPlayerWorldPosition();
	Questie:Print("XYZ:", x, y, z, "Zone: "..getPlayerZone(), "Cont: "..getPlayerContinent());
	--Questie:Print(HBD:GetWorldCoordinatesFromAzerothWorldMap(x, y, ));
	mapX, mapY = HBD:GetAzerothWorldMapCoordinatesFromWorld(x, y, 0);
	Questie:Print(mapX, mapY);
	glooobball = C_Map.GetMapInfo(1)
	--glooobball = HBD:GetAllMapIDs()
	Questie:Print(HBD:GetAllMapIDs())
	Questie:Print(GetWorldContinentFromZone(getPlayerZone()))

	Note = QuestieFrame:GetFrame();
	--THIS WILL BE MOVED!!!
	Note.data.QuestID = 1337
	--Note.data.data..NoteType = NoteType --MiniMapNote or WorldMapNote, Will be moved!
	--Note.data.IconType = type;
	--Note.data.questHash = questHash;
	--Note.data.objectiveid = objectiveid;
		HBDPins:AddMinimapIconWorld(Questie, Note, 0, x, y, true)

	--Questie.db.QuestieFrame = AceGUI:Create("Frame")
	--Questie.db.global.lastmessage = 0
	--LibStub("AceConfig-3.0"):RegisterOptionsTable("Questie", options)
	--radeShoutFrame = LibStub("AceConfigDialog-3.0"):Open("Questie", Questie.db.QuestieFrame)


	--QuestieFrame:SetTitle("Example frame")
	--QuestieFrame:SetStatusText("AceGUI-3.0 Example Container frame")
	--QuestieFrame:SetCallback("OnClose", function() QuestieFrame:Hide() end)
	--QuestieFrame:SetLayout(options)

	--self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Questie", "Trade Shout");

  -- Code that you want to run when the addon is first loaded goes here.
  --Questie:Print("Hello, world!")
  --self:RegisterChatCommand("Questie", "ChatCommand")
end
