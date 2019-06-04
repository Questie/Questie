
Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
_Questie = {...}

local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()
local AceGUI = LibStub("AceGUI-3.0")
HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")
HBDMigrate = LibStub("HereBeDragons-Migrate")

DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"

-- to avoid opening multiple copies of the config window
local configWindowOpen = false;

-- get option value
local function GetGlobalOptionLocal(info)
	return Questie.db.global[info[#info]]
end


-- set option value
local function SetGlobalOptionLocal(info, value)
	if debug and Questie.db.global[info[#info]] ~= value then
		Questie:Debug(DEBUG_SPAM, "DEBUG: global option "..info[#info].." changed from '"..tostring(Questie.db.global[info[#info]]).."' to '"..tostring(value).."'")
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
	if not configWindowOpen then
		if(not QuestieFrameOpt) then
			QuestieFrameOpt = AceGUI:Create("Frame")
		end
		QuestieFrame2 = LibStub("AceConfigDialog-3.0"):Open("Questie", QuestieFrameOpt)
		configWindowOpen = true;
	end


  -- Process the slash command ('input' contains whatever follows the slash command)

end

function Questie:OnEnable()
    -- Called when the addon is enabled
end

function Questie:OnDisable()
    -- Called when the addon is disabled
end


local _optionsTimer = nil;


local _QuestieOptions = {...}

function _QuestieOptions:AvailableQuestRedraw()
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()
end

function _QuestieOptions:ClusterRedraw()
    --Redraw clusters here
end

function _QuestieOptions:Delay(time, func, message)
    if(_optionsTimer) then
        Questie:CancelTimer(_optionsTimer)
        _optionsTimer = nil;
    end
    _optionsTimer = Questie:ScheduleTimer(function()
        func()
        Questie:Debug(DEBUG_DEVELOP, message)
    end, time)
end

local options = {
    name = "Questie",
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
					name = "Enable Questie",
					desc = "Enable or disable addon functionality.",
					width = "full",
					get =	function ()
								return Questie.db.char.enabled
							end,
					set =	function (info, value)
								Questie.db.char.enabled = value
							end,
				},
				iconEnabled = {
					type = "toggle",
					order = 12,
					name = "Enable Questie Minimap Icon",
					desc = "Enable or disable the minimap icon",
					width = "full",
					get =	function ()
								return not Questie.db.profile.minimap.hide;
							end,
					set =	function (info, value)
								Questie.db.profile.minimap.hide = not value;

								if value then
									Questie.minimapConfigIcon:Show("MinimapIcon");
								else
									Questie.minimapConfigIcon:Hide("MinimapIcon");
								end
							end,
				},
				--[[quest_options = {
					type = "header",
					order = 13,
					name = "Quest Options",
				},]]--
				debug_options = {
					type = "header",
					order = 15,
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
					name = "Show All Quests below range (Low level quests)",
					desc = "Enable or disable showing of showing low level quests on the map.",
					width = 200,
					get =	function ()
                                return Questie.db.char.lowlevel
							end,
					set =	function (info, value)
                                Questie.db.char.lowlevel = value
                                _QuestieOptions.AvailableQuestRedraw();
                                Questie:debug(DEBUG_DEVELOP, "Gray Quests toggled to:", value)
							end,
				},
				minLevelFilter = {
					type = "range",
					order = 17,
					name = "< Show below level",
					desc = "How many levels below your character to show.",
					width = "normal",
					min = 1,
					max = 10,
					step = 1,
					get = GetGlobalOptionLocal,
					set = function (info, value)
								SetGlobalOptionLocal(info, value)
                                _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, "minLevelFilter set to "..value)
							end,
				},
				maxLevelFilter = {
					type = "range",
					order = 17,
					name = "Show above level >",
					desc = "How many levels above your character to show.",
					width = "normal",
					min = 1,
					max = 10,
					step = 1,
					get = GetGlobalOptionLocal,
					set = function (info, value)
								SetGlobalOptionLocal(info, value)
                                _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, "maxLevelFilter set to "..value)
                            end,
				},
                clusterLevel = {
                  type = "range",
                  order = 18,
                  name = "Objective icon cluster amount  (Not yet implemented)",
                  desc = "How much objective icons should cluster.",
                  width = "double",
                  min = 0.02,
                  max = 5,
                  step = 0.01,
                  get = GetGlobalOptionLocal,
                  set = function (info, value)
                        _QuestieOptions:Delay(0.5, _QuestieOptions.ClusterRedraw, "NYI Setting clustering value, clusterLevel set to "..value.." : Redrawing!")
                        QUESTIE_NOTES_CLUSTERMUL_HACK = value;
                        SetGlobalOptionLocal(info, value)
                        end,
                },
				fadeLevel = {
				  type = "range",
				  order = 19,
				  name = "Fade objective distance",
				  desc = "How much objective icons should fade depending on distance.",
				  width = "double",
				  min = 0.01,
				  max = 5,
				  step = 0.01,
				  get = GetGlobalOptionLocal,
				  set = function (info, value)
						SetGlobalOptionLocal(info, value)
						end,
				},
				fadeOverPlayer = {
					type = "toggle",
					order = 20,
					name = "Fade Icons over Player",
					desc = "Fades icons on the minimap when your player walks near them.",
					width = "full",
					get = GetGlobalOptionLocal,
					set = function (info, value)
						  SetGlobalOptionLocal(info, value)
						  end,
				},
				arrow_options = {
					type = "header",
					order = 21,
					name = "Arrow Options",
				},
				test = {
					type = "execute",
					order = 22,
					name = "Test Message",
					desc = "Click this",
					func = function() Questie:Print("Why did you click this?") end,
				},
			},
		},

		icon_tab = {
			name = "Icon/Note Options",
			type = "group",
			order = 11,
			args = {
				map_options = {
					type = "header",
					order = 1,
					name = "Map Note Options",
				},
				objectiveScale = {
					type = "range",
					order = 2,
					name = "Scale for objective icons",
					desc = "How large the objective icons are",
					width = "full",
                    min = 0.01,
					max = 4,
					step = 0.01,
					get = GetGlobalOptionLocal,
					set = function (info, value)
                                QuestieMap:rescaleIcons()
								SetGlobalOptionLocal(info, value)
							end,
				},
				availableScale = {
					type = "range",
					order = 3,
                    name = "Scale for available and complete icons",
					desc = "How large the available and complete icons are",
					width = "full",
					min = 0.01,
					max = 4,
					step = 0.01,
					get = GetGlobalOptionLocal,
					set = function (info, value)
                                QuestieMap:rescaleIcons()
								SetGlobalOptionLocal(info, value)
                            end,
				},
                minimap_options = {
                    type = "header",
                    order = 4,
                    name = "Mini-Map Note Options",
                },
                objectiveMiniMapScale = {
                    type = "range",
                    order = 5,
                    name = "Scale for Mini-Map objective icons",
                    desc = "How large the Mini-Map objective icons are",
                    width = "full",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                availableMiniMapScale = {
                    type = "range",
                    order = 6,
                    name = "Scale for Mini-Map available and complete icons",
                    desc = "How large the Mini-Map available and complete icons are",
                    width = "full",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplate_options = {
                    type = "header",
                    order = 7,
                    name = "Nameplate Icon Options",
				},
				nameplateEnabled = {
					type = "toggle",
					order = 8,
					name = "Enable Nameplate Quest Objectives",
					desc = "Enable or disable the quest objective icons over creature nameplates.",
					width = "full",
					get = GetGlobalOptionLocal,
                    set = function (info, value)
								SetGlobalOptionLocal(info, value)

								-- on false, hide current nameplates
								if not value then
									QuestieNameplate:HideCurrentFrames();
								end
                            end,
				},
                nameplateX = {
                    type = "range",
                    order = 9,
                    name = "X position for the nameplate icons",
                    desc = "Where on the X axis the nameplate icon should be",
                    width = "full",
                    min = -200,
                    max = 200,
                    step = 1,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateY = {
                    type = "range",
                    order = 10,
                    name = "Y position for the nameplate icons",
                    desc = "Where on the Y axis the nameplate icon should be",
                    width = "full",
                    min = -200,
                    max = 200,
                    step = 1,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
				},
				nameplateScale = {
					type = "range",
					order = 11,
					name = "Nameplate Icon Scale",
					desc = "Scale the size of the quest icons on creature nameplates",
					width = "full",
					min = 0.01,
					max = 4,
					step = 0.01,
					get = GetGlobalOptionLocal,
                    set = function (info, value)
								SetGlobalOptionLocal(info, value)
								QuestieNameplate:redrawIcons()
                            end,

				},
				nameplateReset = {
					type = "execute",
					order = 12,
					name = "Reset Nameplates",
					desc = "Reset to Default Nameplate Positions",
					func = function (info, value)
						Questie.db.global.nameplateX = -17;
						Questie.db.global.nameplateY = -7;
						Questie.db.global.nameplateScale = 1;
						QuestieNameplate:redrawIcons();
					end,
				},

			},
		},
		Advanced_tab = {
			name = "Advanced",
			type = "group",
			order = 12,
			args = {
				map_options = {
					type = "header",
					order = 1,
					name = "Developer Options",
				},
				debugEnabled = {
					type = "toggle",
					order = 2,
					name = "Enable debug",
					desc = "Enable or disable debug functionality.",
					width = "full",
					get =	function ()
								return Questie.db.global.debugEnabled
							end,
					set =	function (info, value)
								Questie.db.global.debugEnabled = value
							end,
				},
				debugLevel = {
					type = "range",
					order = 3,
					name = "Debug level to print",
					desc = "What debug level to print at : \nDEBUG_CRITICAL = 1\nDEBUG_ELEVATED = 2\nDEBUG_INFO = 3\nDEBUG_DEVELOP = 4\nDEBUG_SPAM = 5",
					width = "normal",
					min = 1,
					max = 5,
					step = 1,
					get = GetGlobalOptionLocal,
					set = function (info, value)
								SetGlobalOptionLocal(info, value)
							end,
				},

			},
		}
	}
}

local defaults = {
  global = {
    maxLevelFilter = 7,
    minLevelFilter = 5, --Raised the default to allow more quests to be shown
    clusterLevel = 1,
    availableScale = 1,
    objectiveScale = 0.7,
    availableMiniMapScale = 0.75,
    objectiveMiniMapScale = 0.75,
	fadeLevel = 1.5,
	fadeOverPlayer = true,
	debugEnabled = false,
	debugLevel = 4,
    nameplateX = -17,
    nameplateY = -7,
	nameplateScale = 1,
	nameplateEnabled = true,
  },
	char = {
		complete = {},
		enabled = true,
        lowlevel = false,
		--autoaccept = false,
		--autocomplete = false
	},
	profile = {
		minimap = {
			hide = false,
		},
	},
}


local minimapIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MinimapIcon", {
	type = "data source",
	text = "Questie",
	icon = ICON_TYPE_COMPLETE,
	OnClick = function () Questie.ToggleMinimapConfigIcon() end,

});


glooobball = ""
Note = nil
function Questie:OnInitialize()

    --If we actually want the settings to save, uncomment this line and comment next one!
    self.db = LibStub("AceDB-3.0"):New("QuestieConfig", defaults, true)
    --self.db = LibStub("AceDB-3.0"):New("QuestieClassicDB", defaults, true)

    Questie:Debug(DEBUG_CRITICAL, "Questie addon loaded")
    Questie:RegisterEvent("PLAYER_ENTERING_WORLD", QuestieEventHandler.PLAYER_ENTERING_WORLD)
    --Accepted Events
    Questie:RegisterEvent("QUEST_ACCEPTED", QuestieEventHandler.QUEST_ACCEPTED)
    Questie:RegisterEvent("QUEST_WATCH_UPDATE", QuestieEventHandler.QUEST_WATCH_UPDATE);
    Questie:RegisterEvent("QUEST_TURNED_IN", QuestieEventHandler.QUEST_TURNED_IN)
    Questie:RegisterEvent("QUEST_REMOVED", QuestieEventHandler.QUEST_REMOVED)
    Questie:RegisterEvent("PLAYER_LEVEL_UP", QuestieEventHandler.PLAYER_LEVEL_UP);
    Questie:RegisterEvent("QUEST_LOG_UPDATE", QuestieEventHandler.QUEST_LOG_UPDATE);

    --TODO: QUEST_QUERY_COMPLETE Will get all quests the character has finished, need to be implemented!


    -- Nameplate Quest ! for mobs to kill
    Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated);
    Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed);

    --Old stuff that has been tried, remove in cleanup
    --Hook the questcomplete button
    --QuestFrameCompleteQuestButton:HookScript("OnClick", CUSTOM_QUEST_COMPLETE)
    --Questie:RegisterEvent("QUEST_COMPLETE", QUEST_COMPLETE)
    --Questie:RegisterEvent("QUEST_FINISHED", QUEST_FINISHED)
    --?? What does this do?


    -- not in classic Questie:RegisterEvent("QUEST_LOG_CRITERIA_UPDATE", QUEST_LOG_CRITERIA_UPDATE)


    Questie:RegisterChatCommand("questieclassic", "MySlashProcessorFunc")
    Questie:RegisterChatCommand("test", "SlashTest")
    Questie:RegisterChatCommand("questie", "MySlashProcessorFunc")



    LibStub("AceConfig-3.0"):RegisterOptionsTable("Questie", options)



    --QuestieFrame:SetTitle("Example frame")
    --QuestieFrame:SetStatusText("AceGUI-3.0 Example Container frame")
    --QuestieFrame:SetCallback("OnClose", function() QuestieFrame:Hide() end)
    --QuestieFrame:SetLayout(options)
    --WILL ERROR; Run with reloadui!
    --x, y, z = HBD:GetPlayerWorldPosition();
    --Questie:Print("XYZ:", x, y, z, "Zone: "..getPlayerZone(), "Cont: "..getPlayerContinent());
    --Questie:Print(HBD:GetWorldCoordinatesFromAzerothWorldMap(x, y, ));
    --mapX, mapY = HBD:GetAzerothWorldMapCoordinatesFromWorld(x, y, 0);
    --Questie:Print(mapX, mapY);
    --glooobball = C_Map.GetMapInfo(1)
    --glooobball = HBD:GetAllMapIDs()
    --Questie:Print(HBD:GetAllMapIDs())
    --Questie:Print(GetWorldContinentFromZone(getPlayerZone()))
    --Questie.db.global.lastmessage = 0

    self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Questie", "Questie");

    -- Code that you want to run when the addon is first loaded goes here.
    --Questie:Print("Hello, world!")
    --self:RegisterChatCommand("Questie", "ChatCommand")

    --Initialize the DB settings.
    Questie:debug(DEBUG_DEVELOP, "Setting clustering value to:", Questie.db.global.clusterLevel)
	QUESTIE_NOTES_CLUSTERMUL_HACK = Questie.db.global.clusterLevel;


    -- Creating the minimap config icon
	Questie.minimapConfigIcon = LibStub("LibDBIcon-1.0");
	Questie.minimapConfigIcon:Register("MinimapIcon", minimapIconLDB, Questie.db.profile.minimap);


end

function Questie:ToggleMinimapConfigIcon()
    if configWindowOpen then
		LibStub("AceConfigDialog-3.0"):Close("Questie");
	else
		LibStub("AceConfigDialog-3.0"):Open("Questie");
	end

	configWindowOpen = not configWindowOpen;

end


function Questie:Error(...)
    Questie:Print("|cffff0000[ERROR]|r", ...)
end

function Questie:error(...)
    Questie:Error(...)
end

--debuglevel = 5 --1 Critical, 2 ELEVATED, 3 Info, 4, Develop, 5 SPAM THAT SHIT YO
--DEBUG_CRITICAL = "1DEBUG"
--DEBUG_ELEVATED = "2DEBUG"
--DEBUG_INFO = "3DEBUG"
--DEBUG_DEVELOP = "4DEBUG"
--DEBUG_SPAM = "5DEBUG"

function Questie:Debug(...)
    -- using a separate var here TEMPORARILY to make it easier for people to disable
    -- /run QuestieConfig.enableDebug = false;
    --if not QuestieConfig.enableDebug then return; end
    if(Questie.db.global.debugEnabled) then
        if(Questie.db.global.debugLevel < 5 and select(1, ...) == DEBUG_SPAM)then return; end
        if(Questie.db.global.debugLevel < 4 and select(1, ...) == DEBUG_DEVELOP)then return; end
        if(Questie.db.global.debugLevel < 3 and select(1, ...) == DEBUG_INFO)then return; end
        if(Questie.db.global.debugLevel < 2 and select(1, ...) == DEBUG_ELEVATED)then return; end
        if(Questie.db.global.debugLevel < 1 and select(1, ...) == DEBUG_CRITICAL)then return; end
        Questie:Print(...)
    end
end

function Questie:debug(...)
    Questie:Debug(...)
end
