
Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
_Questie = {...}
--Questie.db.realm
--Questie.db.char

local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()
local AceGUI = LibStub("AceGUI-3.0")
HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")

debug = true

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


local options = {
    name = "Questie Classic",
    handler = Questie,
    type = "group",
	childGroups = "tab",
    args = {
		general_tab = {
			name = "Options",
			type = "group",
			order = 10,
			args = {
				enabled = {
					type = "toggle",
					order = 11,
					name = "Enable Questie Classic",
					desc = "Enable or disable addon functionality.",
					get =	function ()
								return Questie.db.char.enabled
							end,
					set =	function (info, value)
								Questie.db.char.enabled = value
							end,
				},
				description = {
					type = "description",
					order = 12,
					fontSize = "medium",
					name = "Test text",
				},
				debug_options = {
					type = "header",
					order = 13,
					name = "Note Options",
				},
				--[[message = {
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
				},]]--
				gray = {
					type = "toggle",
					order = 16,
					name = "Show Gray Quests (Low level quests)",
					desc = "Enable or disable showing of gray quests on the map.",
					width = 200,
					get =	function ()
								return Questie.db.char.lowlevel
							end,
					set =	function (info, value)
								QuestieDBQuest:CalculateAvailableQuests()
								Questie.db.char.lowlevel = value
							end,
				},
				minLevelFilter = {
					type = "range",
					order = 17,
					name = "< Show below level",
					desc = "How many levels below your character to show.",
					width = "HALF",
					min = 1,
					max = 10,
					step = 1,
					get = GetGlobalOptionLocal,
					set = function (info, value)
								QuestieDBQuest:CalculateAvailableQuests()
								SetGlobalOptionLocal(info, value)
							end,
				},
				maxLevelFilter = {
					type = "range",
					order = 17,
					name = "Show above level >",
					desc = "How many levels above your character to show.",
					width = "HALF",
					min = 1,
					max = 10,
					step = 1,
					get = GetGlobalOptionLocal,
					set = function (info, value)
								QuestieDBQuest:CalculateAvailableQuests()
								SetGlobalOptionLocal(info, value)
							end,
				},
				arrow_options = {
					type = "header",
					order = 18,
					name = "Arrow Options",
				},
				test = {
					type = "execute",
					order = 18,
					name = "Test Message",
					desc = "Print next message in say.",
					func = function() Questie:Print(Questie:GetNextMessage()) end,
				},
			},
		}
	}
}

local defaults = {
  global = {
    maxLevelFilter = 7,
		minLevelFilter = 4
  },
	char = {
		enabled = true
	}
}

glooobball = ""
Note = nil
function Questie:OnInitialize()
	Questie:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
	Questie:RegisterChatCommand("questieclassic", "MySlashProcessorFunc")
	Questie:RegisterChatCommand("test", "SlashTest")
	Questie:RegisterChatCommand("qc", "MySlashProcessorFunc")
	self.db = LibStub("AceDB-3.0"):New("QuestieClassicDB", defaults, true)


	--WILL ERROR; Run with reloadui!
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
	--HBDPins:AddMinimapIconWorld(Questie, Note, 0, x, y, true)
	HBDPins:AddWorldMapIconWorld(Questie, Note, 0, x, y, HBD_PINS_WORLDMAP_SHOW_WORLD)

	QuestieFrame = AceGUI:Create("Frame")
	--Questie.db.global.lastmessage = 0
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Questie", options)
	QuestieFrame2 = LibStub("AceConfigDialog-3.0"):Open("Questie", QuestieFrame)


	--QuestieFrame:SetTitle("Example frame")
	--QuestieFrame:SetStatusText("AceGUI-3.0 Example Container frame")
	--QuestieFrame:SetCallback("OnClose", function() QuestieFrame:Hide() end)
	--QuestieFrame:SetLayout(options)

	self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Questie", "Questie Classic");

  -- Code that you want to run when the addon is first loaded goes here.
  --Questie:Print("Hello, world!")
  --self:RegisterChatCommand("Questie", "ChatCommand")


end

function PLAYER_ENTERING_WORLD()
	QuestieDB:Initialize()
	QuestieQuest:CalculateAvailableQuests()
end


function Questie:Debug(...)
	if(debug) then
		Questie:Print("DEBUG:", ...)
	end
end

function Questie:debug(...)
	Questie:Debug(...)
end
