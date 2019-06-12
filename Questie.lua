
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

_QuestieOptions.configFrame = nil;
function _QuestieOptions:OpenConfigWindow()
	PlaySound(882);

	if not _QuestieOptions.configFrame then
		_QuestieOptions.configFrame = AceGUI:Create("Frame");
	end

	LibStub("AceConfigDialog-3.0"):Open("Questie", _QuestieOptions.configFrame)
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
	  minimapCoordinatesEnabled = true,
	  mapCoordinatesEnabled = true,
	  mapCoordinatePrecision = 1,
	  nameplateTargetFrameEnabled = false,
	  nameplateTargetFrameX = -25,
	  nameplateTargetFrameY = 25,
	  nameplateTargetFrameScale = 1.7,
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
				questie_header = {
					type = "header",
					order = 1,
					name = "Questie Options",
				},
				enabled = {
					type = "toggle",
					order = 3,
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
					order = 4,
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
				instantQuest = {
					type = "toggle",
					order = 5,
					name = "Enable Instant Quest Text",
					desc = "Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface",
					width = "full",
					get =	function ()
								if GetCVar("instantQuestText") == '1' then return true else return false end;
							end,
					set =	function (info, value)
								if value then
									SetCVar("instantQuestText", 1);
								else
									SetCVar("instantQuestText", 0);
								end
							end,
				},
				Spacer_A = _QuestieOptions:Spacer(9),
				quest_options = {
					type = "header",
					order = 10,
					name = "Quest Level Options",
				},
				Spacer_B = _QuestieOptions:Spacer(11),
				gray = {
					type = "toggle",
					order = 12,
					name = "Show All Quests below range (Low level quests)",
					desc = "Enable or disable showing of showing low level quests on the map.",
					width = 200,
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
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
				  disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return (not Questie.db.char.enabled) and (not Questie.db.global.fadeOverPlayer) end,
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
					disabled = function() return (not Questie.db.char.enabled) and (not Questie.db.global.fadeOverPlayer) end,
					get = GetGlobalOptionLocal,
					set = function (info, value)
						SetGlobalOptionLocal(info, value)
					end,
				},
				Spacer_E = _QuestieOptions:Spacer(20),
				fade_options = {
					type = "header",
					order = 21,
					name = "Mini-Map Coordinates",
				},
				Spacer_F = _QuestieOptions:Spacer(22),
				minimapCoordinatesEnabled = {
					type = "toggle",
					order = 23,
					name = "Player Coordinates on Minimap",
					desc = "Place the Player's coordinates on the Minimap title.",
					width = "full",
					get = GetGlobalOptionLocal,
					set = function (info, value)
						SetGlobalOptionLocal(info, value)

						if not value then
							QuestieCoords.ResetMinimapText();
						end
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
					disabled = function() return not Questie.db.char.enabled end,
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
					disabled = function() return not Questie.db.char.enabled end,
					get = GetGlobalOptionLocal,
					set = function (info, value)
                                QuestieMap:rescaleIcons()
								SetGlobalOptionLocal(info, value)
                            end,
				},
				Spacer_B = _QuestieOptions:Spacer(20),
				fade_options = {
					type = "header",
					order = 21,
					name = "Map and Cursor Coordinates",
				},
				Spacer_C = _QuestieOptions:Spacer(22),
				mapCoordinatesEnabled = {
					type = "toggle",
					order = 23,
					name = "Player and Cursor Coordinates",
					desc = "Place the Player's coordinates and Cursor's coordinates on the Map's title.",
					width = "full",
					get = GetGlobalOptionLocal,
					set = function (info, value)
						SetGlobalOptionLocal(info, value)

						if not value then
							QuestieCoords.ResetMapText();
						end
					end,
				},
				mapCoordinatePrecision = {
					type = "range",
					order = 24,
                    name = "Map Coordinates Decimal Precision",
					desc = "How many decimals to include in the precision on the Map for Player and Cursor coordinates. ( Default: ".. _QuestieOptions.defaults.global.mapCoordinatePrecision  .." )",
					width = "double",
					min = 1,
					max = 5,
					step = 1,
					disabled = function() return not Questie.db.global.mapCoordinatesEnabled end,
					get = GetGlobalOptionLocal,
					set = function (info, value)
								SetGlobalOptionLocal(info, value)
                            end,
				}
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
					disabled = function() return not Questie.db.global.nameplateEnabled end,
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
					disabled = function() return not Questie.db.global.nameplateEnabled end,
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
					disabled = function() return not Questie.db.global.nameplateEnabled end,
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
					disabled = function() return not Questie.db.global.nameplateEnabled end,
					func = function (info, value)
						Questie.db.global.nameplateX = _QuestieOptions.defaults.global.nameplateX;
						Questie.db.global.nameplateY = _QuestieOptions.defaults.global.nameplateY;
						Questie.db.global.nameplateScale = _QuestieOptions.defaults.global.nameplateScale;
						QuestieNameplate:redrawIcons();
					end,
				},
				Spacer_D = _QuestieOptions:Spacer(9),
				targetframe_header = {
					type = "header",
                    order = 20,
                    name = "Target Frame Icon Options",
				},
				Spacer_E = _QuestieOptions:Spacer(21),
				nameplateTargetFrameEnabled = {
					type = "toggle",
					order = 22,
					name = "Enable Target Frame Quest Objectives",
					desc = "Enable or disable the quest objective icons over creature target frame.",
					width = "full",
					get = GetGlobalOptionLocal,
                    set = function (info, value)
								SetGlobalOptionLocal(info, value)

								-- on false, hide current nameplates
								if not value then
									QuestieNameplate:HideCurrentTargetFrame();
								else
									QuestieNameplate:DrawTargetFrame();
								end
                            end,
				},
				Spacer_F = _QuestieOptions:Spacer(23),
                nameplateTargetFrameX  = {
                    type = "range",
                    order = 24,
                    name = "Icon Position X",
                    desc = "Where on the X axis the target frame icon should be. ( Default: ".. _QuestieOptions.defaults.global.nameplateTargetFrameX   .." )",
                    width = "normal",
                    min = -200,
                    max = 200,
					step = 1,
					disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:redrawFrameIcon()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateTargetFrameY  = {
                    type = "range",
                    order = 24,
                    name = "Icon Position Y",
                    desc = "Where on the Y axis the target frame icon should be. ( Default: ".. _QuestieOptions.defaults.global.nameplateTargetFrameY   .." )",
                    width = "normal",
                    min = -200,
                    max = 200,
					step = 1,
					disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
								QuestieNameplate:redrawFrameIcon()
                                SetGlobalOptionLocal(info, value)
                            end,
				},
				nameplateTargetFrameScale  = {
					type = "range",
					order = 25,
					name = "Nameplate Icon Scale",
					desc = "Scale the size of the quest icons on creature target frame. ( Default: ".. _QuestieOptions.defaults.global.nameplateTargetFrameScale   .." )",
					width = "double",
					min = 0.01,
					max = 4,
					step = 0.01,
					disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
					get = GetGlobalOptionLocal,
                    set = function (info, value)
								SetGlobalOptionLocal(info, value)
								QuestieNameplate:redrawFrameIcon()
                            end,

				},
				Spacer_G = _QuestieOptions:Spacer(26),
				targetFrameReset = {
					type = "execute",
					order = 27,
					name = "Reset Target Frame",
					desc = "Reset to Default Target Frame Positions and Scale",
					disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
					func = function (info, value)
						Questie.db.global.nameplateTargetFrameX = _QuestieOptions.defaults.global.nameplateTargetFrameX;
						Questie.db.global.nameplateTargetFrameY = _QuestieOptions.defaults.global.nameplateTargetFrameY;
						Questie.db.global.nameplateTargetFrameScale = _QuestieOptions.defaults.global.nameplateTargetFrameScale;
						QuestieNameplate:redrawFrameIcon();
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
					disabled = function() return not Questie.db.global.debugEnabled end,
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
				reset_text = {
					type = "description",
					order = 13,
					name = "Hitting this button will reset all of the Questie configuration settings back to their default values.",
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
						Questie.db.global.minimapCoordinatesEnabled = _QuestieOptions.defaults.global.minimapCoordinatesEnabled;
						Questie.db.global.mapCoordinatesEnabled = _QuestieOptions.defaults.global.mapCoordinatesEnabled;
						Questie.db.global.mapCoordinatePrecision = _QuestieOptions.defaults.global.mapCoordinatePrecision;
						Questie.db.global.nameplateTargetFrameEnabled = _QuestieOptions.defaults.global.nameplateTargetFrameEnabled;
						Questie.db.global.nameplateTargetFrameX = _QuestieOptions.defaults.global.nameplateTargetFrameX;
						Questie.db.global.nameplateTargetFrameY = _QuestieOptions.defaults.global.nameplateTargetFrameY;
						Questie.db.global.nameplateTargetFrameScale = _QuestieOptions.defaults.global.nameplateTargetFrameScale;


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

						-- update map / minimap coordinates reset
						if not Questie.db.global.minimapCoordinatesEnabled then
							QuestieCoords.ResetMinimapText();
						end

						if not Questie.db.global.mapCoordinatesEnabled then
							QuestieCoords.ResetMapText();
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
					name = "|cffb900ffQuestie is under active development for World of Warcraft: Classic. Please check GitHub for the latest alpha builds or to report issues. Or join us on our discord! (( https://github.com/AeroScripts/QuestieDev/ ))",
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

    self.db = LibStub("AceDB-3.0"):New("QuestieConfig", _QuestieOptions.defaults, true)

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

    -- Nameplate / Tar5get Frame Objective Events
    Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated);
	Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed);
	Questie:RegisterEvent("PLAYER_TARGET_CHANGED", QuestieNameplate.DrawTargetFrame);
	
	-- Initialize Coordinates
	QuestieCoords.Initialize();



    Questie:RegisterChatCommand("questieclassic", "MySlashProcessorFunc")
    Questie:RegisterChatCommand("questie", "MySlashProcessorFunc")

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Questie", options)
	self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Questie", "Questie");

    --Initialize the DB settings.
    Questie:debug(DEBUG_DEVELOP, "Setting clustering value to:", Questie.db.global.clusterLevel)
	QUESTIE_NOTES_CLUSTERMUL_HACK = Questie.db.global.clusterLevel;


    -- Creating the minimap config icon
	Questie.minimapConfigIcon = LibStub("LibDBIcon-1.0");
	Questie.minimapConfigIcon:Register("MinimapIcon", minimapIconLDB, Questie.db.profile.minimap);

end

function Questie:MySlashProcessorFunc(input)

	if input == "" or not input then
		_QuestieOptions.OpenConfigWindow()
		return ;
	end


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
