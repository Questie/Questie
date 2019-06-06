
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

local _optionsTimer = nil;

function Questie:OnUpdate()

end

function Questie:OnEnable()
    -- Called when the addon is enabled
end

function Questie:OnDisable()
    -- Called when the addon is disabled
end


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

function _QuestieOptions:Spacer(o)
	return {
		type = "description",
		order = o,
		name = " ",
		fontSize = "large",
	}
end

function _QuestieOptions:OpenConfigWindow()
	PlaySound(882)
	LibStub("AceConfigDialog-3.0"):Open("Questie")
end

_QuestieOptions.defaults = {
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
	  fadeOverPlayerLevel = 0.5,
	  fadeOverPlayerDistance = 0.2,
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
					order = 1,
					name = "Enable Questie",
					desc = "Enable or disable addon functionality.",
					width = "full",
					get =	function ()
								return Questie.db.char.enabled
							end,
					set =	function (info, value)
								QuestieQuest:ToggleNotes();
								Questie.db.char.enabled = value						
							end,
				},
				iconEnabled = {
					type = "toggle",
					order = 2,
					name = "Enable Questie Minimap Icon",
					desc = "Enable or disable the minimap icon. You can still access the options menu with /questie",
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
				Spacer_A = _QuestieOptions:Spacer(3),
				quest_options = {
					type = "header",
					order = 10,
					name = "Quest Options",
				},
				Spacer_B = _QuestieOptions:Spacer(11),
				gray = {
					type = "toggle",
					order = 12,
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
					order = 13,
					name = "< Show below level",
					desc = "How many levels below your character to show. ( Default: ".. _QuestieOptions.defaults.global.minLevelFilter .." )",
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
					order = 13,
					name = "Show above level >",
					desc = "How many levels above your character to show. ( Default: ".. _QuestieOptions.defaults.global.maxLevelFilter .." )",
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
                  order = 14,
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
				

			--[[	arrow_options = {
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
				}, ]]
			},
		},

		minimap_tab = {
			name = "Minimap Options",
			type = "group",
			order = 11,
			args = {
				minimap_options = {
                    type = "header",
                    order = 1,
                    name = "Mini-Map Note Options",
				},
				Spacer_A = _QuestieOptions:Spacer(2),
                objectiveMiniMapScale = {
                    type = "range",
                    order = 3,
                    name = "Scale for Mini-Map objective icons",
                    desc = "How large the Mini-Map objective icons are. ( Default: ".. _QuestieOptions.defaults.global.objectiveMiniMapScale  .." )",
                    width = "double",
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
                    order = 4,
                    name = "Scale for Mini-Map available and complete icons",
                    desc = "How large the Mini-Map available and complete icons are. ( Default: ".. _QuestieOptions.defaults.global.availableMiniMapScale  .." )",
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:rescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
				},
				Spacer_B = _QuestieOptions:Spacer(9),
				fade_options = {
					type = "header",
					order = 10,
					name = "Mini-Map Note Fading",
				},
				Spacer_C = _QuestieOptions:Spacer(11),
				fadeLevel = {
					type = "range",
					order = 12,
					name = "Fade objective distance",
					desc = "How much objective icons should fade depending on distance. ( Default: ".. _QuestieOptions.defaults.global.fadeLevel  .." )",
					width = "double",
					min = 0.01,
					max = 5,
					step = 0.01,
					get = GetGlobalOptionLocal,
					set = function (info, value)
						  SetGlobalOptionLocal(info, value)
						  end,
				},
				Spacer_D = _QuestieOptions:Spacer(13),
				fadeOverPlayer = {
					type = "toggle",
					order = 14,
					name = "Fade Icons over Player",
					desc = "Fades icons on the minimap when your player walks near them.",
					width = "full",
					get = GetGlobalOptionLocal,
					set = function (info, value)
						SetGlobalOptionLocal(info, value)
						end,
				},
				fadeOverPlayerDistance = {
					type = "range",
					order = 15,
					name = "Fade over Player Distance",
					desc = "How far from player should icons start to fade. ( Default: ".. _QuestieOptions.defaults.global.fadeOverPlayerDistance  .." )",
					width = "double",
					min = 0.1,
					max = 0.5,
					step = 0.01,
					get = GetGlobalOptionLocal,
					set = function (info, value)
						SetGlobalOptionLocal(info, value)
					end,
				},
				fadeOverPlayerLevel = {
					type = "range",
					order = 16,
					name = "Fade over Player Amount",
					desc = "How much should the icons around the player fade. ( Default: ".. _QuestieOptions.defaults.global.fadeOverPlayerLevel  .." )",
					width = "double",
					min = 0.1,
					max = 1,
					step = 0.1,
					get = GetGlobalOptionLocal,
					set = function (info, value)
						SetGlobalOptionLocal(info, value)
					end,
				},
			},
		},

		map_tab = {
			name = "Map Options",
			type = "group",
			order = 13,
			args = {
				map_options = {
					type = "header",
					order = 1,
					name = "Map Note Options",
				},
				Spacer_A = _QuestieOptions:Spacer(2),
				objectiveScale = {
					type = "range",
					order = 3,
					name = "Scale for objective icons",
					desc = "How large the kill and collect objective icons are.  ( Default: ".. _QuestieOptions.defaults.global.objectiveScale  .." )",
					width = "double",
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
					order = 4,
                    name = "Scale for available and complete icons",
					desc = "How large the available and complete icons are. ( Default: ".. _QuestieOptions.defaults.global.availableScale  .." )",
					width = "double",
					min = 0.01,
					max = 4,
					step = 0.01,
					get = GetGlobalOptionLocal,
					set = function (info, value)
                                QuestieMap:rescaleIcons()
								SetGlobalOptionLocal(info, value)
                            end,
				},
			},
		},


		nameplate_tab = {
			name = "Nameplate Options",
			type = "group",
			order = 14,
			args = {
                nameplate_options = {
                    type = "header",
                    order = 1,
                    name = "Nameplate Icon Options",
				},
				Spacer_A = _QuestieOptions:Spacer(2),
				nameplateEnabled = {
					type = "toggle",
					order = 3,
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
				Spacer_B = _QuestieOptions:Spacer(4),
                nameplateX = {
                    type = "range",
                    order = 5,
                    name = "Icon Position X",
                    desc = "Where on the X axis the nameplate icon should be. ( Default: ".. _QuestieOptions.defaults.global.nameplateX  .." )",
                    width = "normal",
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
                    order = 5,
                    name = "Icon Position Y",
                    desc = "Where on the Y axis the nameplate icon should be. ( Default: ".. _QuestieOptions.defaults.global.nameplateY  .." )",
                    width = "normal",
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
					order = 6,
					name = "Nameplate Icon Scale",
					desc = "Scale the size of the quest icons on creature nameplates. ( Default: ".. _QuestieOptions.defaults.global.nameplateScale  .." )",
					width = "double",
					min = 0.01,
					max = 4,
					step = 0.01,
					get = GetGlobalOptionLocal,
                    set = function (info, value)
								SetGlobalOptionLocal(info, value)
								QuestieNameplate:redrawIcons()
                            end,

				},
				Spacer_C = _QuestieOptions:Spacer(7),
				nameplateReset = {
					type = "execute",
					order = 8,
					name = "Reset Nameplates",
					desc = "Reset to Default Nameplate Positions and Scale",
					func = function (info, value)
						Questie.db.global.nameplateX = _QuestieOptions.defaults.global.nameplateX;
						Questie.db.global.nameplateY = _QuestieOptions.defaults.global.nameplateY;
						Questie.db.global.nameplateScale = _QuestieOptions.defaults.global.nameplateScale;
						QuestieNameplate:redrawIcons();
					end,
				},

			},
		},
		Advanced_tab = {
			name = "Advanced",
			type = "group",
			order = 15,
			args = {
				map_options = {
					type = "header",
					order = 1,
					name = "Developer Options",
				},
				debugEnabled = {
					type = "toggle",
					order = 4,
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
					order = 5,
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


				Spacer_A = _QuestieOptions:Spacer(10),
				reset_header = {
					type = "header",
					order = 11,
					name = "Reset Questie",
				},
				Spacer_B = _QuestieOptions:Spacer(12),
				github_text = {
					type = "description",
					order = 13,
					name = "Hitting this button will reset all of the questie configuration settings back to their default values.",
					fontSize = "medium",
				},
				questieReset = {
					type = "execute",
					order = 14,
					name = "Reset Questie",
					desc = "Reset Questie to the default values for all settings.",
					func = function (info, value)
						-- update all values to default
						Questie.db.global.maxLevelFilter  = _QuestieOptions.defaults.global.maxLevelFilter ;
						Questie.db.global.minLevelFilter = _QuestieOptions.defaults.global.minLevelFilter;
						Questie.db.global.clusterLevel = _QuestieOptions.defaults.global.clusterLevel;
						Questie.db.global.availableScale = _QuestieOptions.defaults.global.availableScale;
						Questie.db.global.objectiveScale = _QuestieOptions.defaults.global.objectiveScale;
						Questie.db.global.availableMiniMapScale = _QuestieOptions.defaults.global.availableMiniMapScale;
						Questie.db.global.objectiveMiniMapScale = _QuestieOptions.defaults.global.objectiveMiniMapScale;
						Questie.db.global.fadeLevel = _QuestieOptions.defaults.global.fadeLevel;
						Questie.db.global.fadeOverPlayer = _QuestieOptions.defaults.global.fadeOverPlayer;
						Questie.db.global.fadeOverPlayerLevel = _QuestieOptions.defaults.global.fadeOverPlayerLevel;
						Questie.db.global.fadeOverPlayerDistance = _QuestieOptions.defaults.global.fadeOverPlayerDistance;
						Questie.db.global.debugEnabled = _QuestieOptions.defaults.global.debugEnabled;
						Questie.db.global.debugLevel = _QuestieOptions.defaults.global.debugLevel;
						Questie.db.global.nameplateX = _QuestieOptions.defaults.global.nameplateX;
						Questie.db.global.nameplateY = _QuestieOptions.defaults.global.nameplateY;
						Questie.db.global.nameplateScale = _QuestieOptions.defaults.global.nameplateScale;
						Questie.db.global.nameplateEnabled = _QuestieOptions.defaults.global.nameplateEnabled;


						-- only toggle questie if it's off (must be called before resetting the value)
						if not Questie.db.char.enabled then
							QuestieQuest:ToggleNotes();
						end


						Questie.db.char.enabled = _QuestieOptions.defaults.char.enabled;
						Questie.db.char.lowlevel = _QuestieOptions.defaults.char.lowlevel;
						
						Questie.db.profile.minimap.hide = _QuestieOptions.defaults.profile.minimap.hide;
						
						-- update minimap icon to default
						if not Questie.db.profile.minimap.hide then
							Questie.minimapConfigIcon:Show("MinimapIcon");
						else
							Questie.minimapConfigIcon:Hide("MinimapIcon");
						end


						_QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, "minLevelFilter and maxLevelFilter reset to defaults");

						QuestieNameplate:redrawIcons();
						QuestieMap:rescaleIcons()
					end,
				},


				Spacer_C = _QuestieOptions:Spacer(20),
				github_text = {
					type = "description",
					order = 21,
					name = [[Questie is under active development for World of Warcraft: Classic. Please check GitHub for the latest alpha builds or to report issues. Or join us on our discord! (( https://github.com/AeroScripts/QuestieDev/ ))]],
					fontSize = "medium",
				},

			},
		}
	}
}


local minimapIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MinimapIcon", {
	type = "data source",
	text = "Questie",
	icon = ICON_TYPE_COMPLETE,
	OnClick = function (self, button) 
		if button == "LeftButton" then
			_QuestieOptions.OpenConfigWindow()
			return;
		elseif button == "RightButton" then
			if IsControlKeyDown() then
				Questie.db.profile.minimap.hide = true;
				Questie.minimapConfigIcon:Hide("MinimapIcon");
				return;
			end
		end
	end,
	OnTooltipShow = function (tooltip)
		tooltip:AddLine("Questie", 1, 1, 1);
		tooltip:AddLine ("|cFFCFCFCFLeft Click|r: Open Options")
		tooltip:AddLine ("|cFFCFCFCFCtrl + Right Click|r: Hide Minimap Icon")
	end,

});


glooobball = ""
Note = nil
function Questie:OnInitialize()

    --If we actually want the settings to save, uncomment this line and comment next one!
    self.db = LibStub("AceDB-3.0"):New("QuestieConfig", _QuestieOptions.defaults, true)
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
    Questie:RegisterEvent("MODIFIER_STATE_CHANGED", QuestieEventHandler.MODIFIER_STATE_CHANGED);

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

function Questie:MySlashProcessorFunc(input)
	--Questie:Print(ChatFrame1, "Hello, World!")
	--SetMessage("test", "test")

	_QuestieOptions.OpenConfigWindow()

  -- Process the slash command ('input' contains whatever follows the slash command)

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
