QuestieOptions = {...};
local _QuestieOptions = {...};
_QuestieOptions.configFrame = nil;

local AceGUI = LibStub("AceGUI-3.0")

-- Initialize lookup tables for localization
LangItemLookup = LangItemLookup[GetLocale()] or {};
LangNameLookup = LangNameLookup[GetLocale()] or {};
LangQuestLookup = LangQuestLookup[GetLocale()] or {};
LangObjectIdLookup = LangObjectLookup[GetLocale()] or {}; -- This table is String -> ID
LangObjectLookup = {} -- This table is ID -> String
--Create the ID -> String table!
for k,v in pairs(LangObjectIdLookup) do
    LangObjectLookup[v]=k
end
-- Create the english String -> ID table.
if(GetLocale() == "enUS" or GetLocale() == "enGB") then
    for id, data in pairs(QuestieDB.objectData) do
        LangObjectIdLookup[data[1]] = id;
    end
end

-- Global Functions --

function QuestieOptions:Initialize()
    LibStub("AceConfigQuestie-3.0"):RegisterOptionsTable("Questie", QuestieOptions:GetOptionsGUI())
    Questie.configFrame = LibStub("AceConfigDialogQuestie-3.0"):AddToBlizOptions("Questie", "Questie");
end

-- Generic function to hide the config frame.
function QuestieOptions:HideFrame()
  if _QuestieOptions.configFrame and _QuestieOptions.configFrame:IsShown() then
    _QuestieOptions.configFrame:Hide();
  end
end

-- Open the configuration window
function QuestieOptions:OpenConfigWindow()

    if not _QuestieOptions.configFrame then
        _QuestieOptions.configFrame = AceGUI:Create("Frame");
        _QuestieOptions.configFrame:Hide();

        _G["QuestieConfigFrame"] = _QuestieOptions.configFrame.frame;
        table.insert(UISpecialFrames, "QuestieConfigFrame");
    end

    if not _QuestieOptions.configFrame:IsShown() then
        PlaySound(882);
        LibStub("AceConfigDialogQuestie-3.0"):Open("Questie", _QuestieOptions.configFrame)
    else
        _QuestieOptions.configFrame:Hide();
    end
end

-- Passes reference, maybe we should copy
function QuestieOptions:GetDefaults()
  return _QuestieOptions.defaults;
end

-- Passes reference, maybe we should copy
function QuestieOptions:GetMinimapIconLDB()
  return _QuestieOptions.minimapIconLDB;
end

-- Passes reference, maybe we should copy
function QuestieOptions:GetOptionsGUI()
  return _QuestieOptions.optionsGUI;
end

-- Passes reference, maybe we should copy
function QuestieOptions:GetConfigFrame()
  return _QuestieOptions.configFrame;
end

-- Local Functions --

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


function _QuestieOptions:AvailableQuestRedraw()
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()
end

function _QuestieOptions:ClusterRedraw()
    --Redraw clusters here
end

local _optionsTimer = nil;
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

function _QuestieOptions:Spacer(o, height)
    return {
        type = "description",
        order = o,
        name = " ",
        fontSize = "large",
        fontHeight = height
    }
end

-- Configuration variables --

_QuestieOptions.defaults = {
    global = {
      maxLevelFilter = 7,
      minLevelFilter = 5, --Raised the default to allow more quests to be shown
      clusterLevel = 1,
      availableScale = 1.3,
      eventScale = 1.35,
      lootScale = 1,
      monsterScale = 1,
      objectScale = 1,
      globalScale = 0.7,
      globalMiniMapScale = 0.7,
      fadeLevel = 1.5,
      fadeOverPlayer = true,
      fadeOverPlayerLevel = 0.5,
      fadeOverPlayerDistance = 0.2,
      debugEnabled = false,
      debugEnabledPrint = false,
      debugLevel = 4,
      nameplateX = -17,
      nameplateY = -7,
      nameplateScale = 1,
      nameplateEnabled = true,
      minimapCoordinatesEnabled = false,
      mapCoordinatesEnabled = true,
      mapCoordinatePrecision = 1,
      mapShowHideEnabled = true,
      nameplateTargetFrameEnabled = false,
      nameplateTargetFrameX = -30,
      nameplateTargetFrameY = 25,
      nameplateTargetFrameScale = 1.7,
      questieLocale = 'enUS',
      questieLocaleDiff = false,
      alwaysGlowMap = true,
      alwaysGlowMinimap = false,
      questObjectiveColors = false,
      questMinimapObjectiveColors = false,
      enableObjectives = true,
      enableTurnins = true,
      enableAvailable = true,
      enableTooltips = true,
      enableTooltipsQuestLevel = true,
      enableMapIcons = true,
      enableMiniMapIcons = true,
      trackerFontSizeHeader = 13,
      trackerFontSizeLine = 11,
      hookTracking = true,
      trackerEnabled = true,
      trackerShowQuestLevel = true,
      trackerColorObjectives = 'white',
      trackerQuestPadding = 2,
      trackerSortObjectives = 'byComplete',
      trackerbindOpenQuestLog = 'shiftleft',
      trackerbindSetTomTom = 'ctrlleft',
      iconFadeLevel = 0.3,
      trackerLocked = true,
    },
      char = {
          complete = {},
          hidden = {},
          enabled = true,
          lowlevel = false,
          journey = {},
          searchType = 1,
          --autoaccept = false,
          --autocomplete = false
      },
      profile = {
          minimap = {
              hide = false,
          },
      },
}


_QuestieOptions.optionsGUI = {
    name = "Questie",
    handler = Questie,
    type = "group",
    childGroups = "tab",
    args = {
        general_tab = {
            name = function() return QuestieLocale:GetUIString('OPTIONS_TAB') end,
            type = "group",
            order = 10,
            args = {
                questie_header = {
                    type = "header",
                    order = 1,
                    name = function() return QuestieLocale:GetUIString('QUESTIE_HEADER') end,
                },
                enabled = {
                    type = "toggle",
                    order = 3,
                    name = function() return QuestieLocale:GetUIString('ENABLE_QUESTIE') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_QUESTIE_DESC') end,
                    width = "full",
                    get =    function ()
                                return Questie.db.char.enabled
                            end,
                    set =    function (info, value)
                                QuestieQuest:ToggleNotes(value);
                                Questie.db.char.enabled = value
                            end,
                },
                iconTypes = {
                    type = "group",
                    order = 4,
                    inline = true,
                    name = function() return QuestieLocale:GetUIString('ICON_TYPE_HEADER') end,
                    args = {
                        enableMapToggle = {
                            type = "toggle",
                            order = 1,
                            name = function() return QuestieLocale:GetUIString('ENABLE_MAP_ICONS') end,
                            desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_ICONS_DESC') end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableMapIcons;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableMapIcons = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        enableMiniMapToggle = {
                            type = "toggle",
                            order = 2,
                            name = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_ICONS') end,
                            desc = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_ICONS_DESC') end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableMiniMapIcons;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableMiniMapIcons = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        seperatingHeader = {
                            type = "header",
                            order = 3,
                            name = "",
                        },
                        enableObjectivesToggle = {
                            type = "toggle",
                            order = 4,
                            name = function() return QuestieLocale:GetUIString('ENABLE_OBJECTIVES') end,
                            desc = function() return QuestieLocale:GetUIString('ENABLE_OBJECTIVES_DESC') end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableObjectives;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableObjectives = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        enableTurninsToggle = {
                            type = "toggle",
                            order = 5,
                            name = function() return QuestieLocale:GetUIString('ENABLE_TURNINS') end,
                            desc = function() return QuestieLocale:GetUIString('ENABLE_TURNINS_DESC') end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableTurnins;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableTurnins = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                        enableAvailableToggle = {
                            type = "toggle",
                            order = 6,
                            name = function() return QuestieLocale:GetUIString('ENABLE_AVAILABLE') end,
                            desc = function() return QuestieLocale:GetUIString('ENABLE_AVAILABLE_DESC') end,
                            width = "full",
                            disabled = function() return (not Questie.db.char.enabled) end,
                            get =    function ()
                                        return Questie.db.global.enableAvailable;
                                    end,
                            set =    function (info, value)
                                        Questie.db.global.enableAvailable = value
                                        QuestieQuest:UpdateHiddenNotes();
                                    end,
                        },
                    },
                },
                iconEnabled = {
                    type = "toggle",
                    order = 5,
                    name = function() return QuestieLocale:GetUIString('ENABLE_ICON') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_ICON_DESC') end,
                    width = "full",
                    get =    function ()
                                return not Questie.db.profile.minimap.hide;
                            end,
                    set =    function (info, value)
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
                    order = 6,
                    name = function() return QuestieLocale:GetUIString('ENABLE_INSTANT') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_INSTANT_DESC') end,
                    width = "full",
                    get =    function ()
                                if GetCVar("instantQuestText") == '1' then return true else return false end;
                            end,
                    set =    function (info, value)
                                if value then
                                    SetCVar("instantQuestText", 1);
                                else
                                    SetCVar("instantQuestText", 0);
                                end
                            end,
                },
                enableTooltipsToggle = {
                    type = "toggle",
                    order = 7,
                    name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_DESC') end,
                    width = "full",
                    get =    function ()
                                return Questie.db.global.enableTooltips;
                            end,
                    set =    function (info, value)
                                Questie.db.global.enableTooltips = value
                            end,
                },
                showQuestLevels = {
                    type = "toggle",
                    order = 8,
                    name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL_DESC') end,
                    width = "full",
                    get = function() return Questie.db.global.enableTooltipsQuestLevel end,
                    set = function (info, value)
                        Questie.db.global.enableTooltipsQuestLevel = value
                        if value and not Questie.db.global.trackerShowQuestLevel then
                            Questie.db.global.trackerShowQuestLevel = true
                            QuestieTracker:Update()
                        end
                    end
                },
                --Spacer_A = _QuestieOptions:Spacer(9),
                quest_options = {
                    type = "header",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('LEVEL_HEADER') end,
                },
                Spacer_B = _QuestieOptions:Spacer(9),
                gray = {
                    type = "toggle",
                    order = 10,
                    name = function() return QuestieLocale:GetUIString('ENABLE_LOWLEVEL') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_LOWLEVEL_DESC') end,
                    width = 200,
                    get =    function ()
                                return Questie.db.char.lowlevel
                            end,
                    set =    function (info, value)
                                Questie.db.char.lowlevel = value
                                _QuestieOptions.AvailableQuestRedraw();
                                Questie:debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('DEBUG_LOWLEVEL'), value)
                            end,
                },
                minLevelFilter = {
                    type = "range",
                    order = 11,
                    name = function() return QuestieLocale:GetUIString('LOWLEVEL_BELOW') end,
                    desc = function() return QuestieLocale:GetUIString('LOWLEVEL_BELOW_DESC', _QuestieOptions.defaults.global.minLevelFilter) end,
                    width = "normal",
                    min = 1,
                    max = 10,
                    step = 1,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, QuestieLocale:GetUIString('DEBUG_MINLEVEL', value))
                            end,
                },
                maxLevelFilter = {
                    type = "range",
                    order = 12,
                    name = function() return QuestieLocale:GetUIString('LOWLEVEL_ABOVE') end,
                    desc = function() return QuestieLocale:GetUIString('LOWLEVEL_ABOVE_DESC', _QuestieOptions.defaults.global.maxLevelFilter) end,
                    width = "normal",
                    min = 1,
                    max = 10,
                    step = 1,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, QuestieLocale:GetUIString('DEBUG_MAXLEVEL', value))
                            end,
                },
                clusterLevel = {
                  type = "range",
                  order = 13,
                  name = function() return QuestieLocale:GetUIString('CLUSTER') end,
                  desc = function() return QuestieLocale:GetUIString('CLUSTER_DESC') end,
                  width = "double",
                  min = 0.02,
                  max = 5,
                  step = 0.01,
                  get = GetGlobalOptionLocal,
                  set = function (info, value)
                        _QuestieOptions:Delay(0.5, _QuestieOptions.ClusterRedraw, QuestieLocale:GetUIString('DEBUG_CLUSTER', value))
                        QUESTIE_NOTES_CLUSTERMUL_HACK = value;
                        SetGlobalOptionLocal(info, value)
                        end,
                },
            },
        },

        minimap_tab = {
            name = function() return QuestieLocale:GetUIString('MINIMAP_TAB') end,
            type = "group",
            order = 11,
            args = {
                minimap_options = {
                    type = "header",
                    order = 1,
                    name = function() return QuestieLocale:GetUIString('MINIMAP_HEADER') end,
                },
                alwaysGlowMinimap = {
                    type = "toggle",
                    order = 1.7,
                    name = function() return QuestieLocale:GetUIString('MINIMAP_ALWAYS_GLOW_TOGGLE') end,
                    desc = function() return QuestieLocale:GetUIString('MINIMAP_ALWAYS_GLOW_TOGGLE_DESC') end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        QuestieFramePool:UpdateGlowConfig(true, value)
                    end,
                },
                questMinimapObjectiveColors = {
                    type = "toggle",
                    order = 1.8,
                    name = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS') end,
                    desc = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS_DESC') end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        QuestieFramePool:UpdateColorConfig(true, value)
                    end,
                },
                Spacer_A = _QuestieOptions:Spacer(2),
                globalMiniMapScale = {
                    type = "range",
                    order = 3,
                    name = function() return QuestieLocale:GetUIString('MINIMAP_GLOBAL_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('MINIMAP_GLOBAL_SCALE_DESC', _QuestieOptions.defaults.global.globalMiniMapScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                fadeLevel = {
                    type = "range",
                    order = 12,
                    name = function() return QuestieLocale:GetUIString('MINIMAP_FADING') end,
                    desc = function() return QuestieLocale:GetUIString('MINIMAP_FADING_DESC', _QuestieOptions.defaults.global.fadeLevel) end,
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
                    name = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER') end,
                    desc = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_DESC') end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        end,
                },
                fadeOverPlayerDistance = {
                    type = "range",
                    order = 15,
                    name = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_DIST') end,
                    desc = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_DIST_DESC', _QuestieOptions.defaults.global.fadeOverPlayerDistance) end,
                    width = "double",
                    min = 0.1,
                    max = 0.5,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    disabled = function() return (not Questie.db.global.fadeOverPlayer) end,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                    end,
                },
                fadeOverPlayerLevel = {
                    type = "range",
                    order = 16,
                    name = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_LEVEL') end,
                    desc = function() return QuestieLocale:GetUIString('MINIMAP_FADE_PLAYER_LEVEL_DESC', _QuestieOptions.defaults.global.fadeOverPlayerLevel) end,
                    width = "double",
                    min = 0.1,
                    max = 1,
                    step = 0.1,
                    disabled = function() return (not Questie.db.global.fadeOverPlayer) end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                    end,
                },
                Spacer_E = _QuestieOptions:Spacer(20),
                fade_options = {
                    type = "header",
                    order = 21,
                    name = function() return QuestieLocale:GetUIString('MINMAP_COORDS') end,
                },
                Spacer_F = _QuestieOptions:Spacer(22),
                minimapCoordinatesEnabled = {
                    type = "toggle",
                    order = 23,
                    name = function() return QuestieLocale:GetUIString('ENABLE_COORDS') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_COORDS_DESC') end,
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
            name = function() return QuestieLocale:GetUIString('MAP_TAB') end,
            type = "group",
            order = 13,
            args = {
                map_options = {
                    type = "header",
                    order = 1,
                    name = function() return QuestieLocale:GetUIString('MAP_TAB') end,
                },
                mapShowHideEnabled = {
                    type = "toggle",
                    order = 3,
                    name = function() return QuestieLocale:GetUIString('ENABLE_MAP_BUTTON') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_BUTTON_DESC') end,
                    width = "full",
                    get =    GetGlobalOptionLocal,
                    set =    function (info, value)
                                SetGlobalOptionLocal(info, value)

                                if value then
                                    Questie_Toggle:Show();
                                else
                                    Questie_Toggle:Hide();
                                end
                            end,
                },
                alwaysGlowMap = {
                    type = "toggle",
                    order = 3.1,
                    name = function() return QuestieLocale:GetUIString('MAP_ALWAYS_GLOW_TOGGLE') end,
                    desc = function() return QuestieLocale:GetUIString('MAP_ALWAYS_GLOW_TOGGLE_DESC') end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        QuestieFramePool:UpdateGlowConfig(false, value)
                    end,
                },
                questObjectiveColors = {
                    type = "toggle",
                    order = 3.1,
                    name = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS') end,
                    desc = function() return QuestieLocale:GetUIString('MAP_QUEST_COLORS_DESC') end,
                    width = "full",
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                        SetGlobalOptionLocal(info, value)
                        QuestieFramePool:UpdateColorConfig(false, value)
                    end,
                },
                Spacer_A = _QuestieOptions:Spacer(6),
                mapnote_options = {
                    type = "header",
                    order = 7,
                    name = function() return QuestieLocale:GetUIString('MAP_NOTES') end,
                },
                Spacer_B = _QuestieOptions:Spacer(8),
                globalScale = {
                    type = "range",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('MAP_GLOBAL_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('MAP_GLOBAL_SCALE_DESC', _QuestieOptions.defaults.global.globalScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                availableScale = {
                    type = "range",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('AVAILABLE_ICON_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('AVAILABLE_ICON_SCALE_DESC', _QuestieOptions.defaults.global.availableScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                eventScale = {
                    type = "range",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('EVENT_ICON_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('EVENT_ICON_SCALE_DESC', _QuestieOptions.defaults.global.eventScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                lootScale = {
                    type = "range",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('LOOT_ICON_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('LOOT_ICON_SCALE_DESC', _QuestieOptions.defaults.global.lootScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                monsterScale = {
                    type = "range",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('MONSTER_ICON_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('MONSTER_ICON_SCALE_DESC', _QuestieOptions.defaults.global.monsterScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                objectScale = {
                    type = "range",
                    order = 9,
                    name = function() return QuestieLocale:GetUIString('OBJECT_ICON_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('OBJECT_ICON_SCALE_DESC', _QuestieOptions.defaults.global.objectScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieMap:RescaleIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                Spacer_C = _QuestieOptions:Spacer(20),
                fade_options = {
                    type = "header",
                    order = 21,
                    name = function() return QuestieLocale:GetUIString('MAP_COORDS') end,
                },
                Spacer_D = _QuestieOptions:Spacer(22),
                mapCoordinatesEnabled = {
                    type = "toggle",
                    order = 23,
                    name = function() return QuestieLocale:GetUIString('ENABLE_MAP_COORDS') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_COORDS_DESC') end,
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
                    name = function() return QuestieLocale:GetUIString('MAP_COORDS_PRECISION') end,
                    desc = function() return QuestieLocale:GetUIString('MAP_COORDS_PRECISION_DESC', _QuestieOptions.defaults.global.mapCoordinatePrecision) end,
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
        
        tracker_tab = {
            name = function() return QuestieLocale:GetUIString('TRACKER_TAB') end,
            type = "group",
            order = 13.5,
            args = {
                header = {
                    type = "header",
                    order = 1,
                    name = function() return QuestieLocale:GetUIString('TRACKER_HEAD') end,
                },
                questieTrackerEnabled = {
                    type = "toggle",
                    order = 2,
                    width = 1.5,
                    name = function() return QuestieLocale:GetUIString('TRACKER_ENABLED') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLED_DESC') end,
                    get = function() return Questie.db.global.trackerEnabled end,
                    set = function (info, value)
                        Questie.db.global.trackerEnabled = value
                        if value then
                            -- may not have been initialized yet
                            if Questie.db.global.hookTracking then
                                QuestieTracker:HookBaseTracker()
                            end
                            QuestieTracker:Initialize()
                        elseif Questie.db.global.hookTracking then
                            QuestieTracker:Unhook()
                        end
                        QuestieTracker:Update()
                    end
                },
                autoQuestTracking = {
                    type = "toggle",
                    order = 3,
                    width = 1.5,
                    name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK_DESC') end,
                    get = function() return GetCVar("autoQuestWatch") == "1" end,
                    set = function (info, value)
                        if value then
                            SetCVar("autoQuestWatch", "1")
                        else
                            SetCVar("autoQuestWatch", "0")
                        end
                        QuestieTracker:Update()
                    end
                },
                Spacer_F3 = _QuestieOptions:Spacer(3.5, 0.001),
                hookBaseTracker = {
                    type = "toggle",
                    order = 4,
                    width = 1.5,
                    name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS_DESC') end,
                    get = function() return Questie.db.global.hookTracking end,
                    set = function (info, value)
                        Questie.db.global.hookTracking = value
                        if value then
                            -- may not have been initialized yet
                            QuestieTracker:HookBaseTracker()
                        else
                            QuestieTracker:Unhook()
                        end
                        QuestieTracker:Update()
                    end
                },
                showCompleteQuests = {
                    type = "toggle",
                    order = 5,
                    width = 1.5,
                    name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE_DESC') end,
                    get = function() return Questie.db.global.trackerShowCompleteQuests end,
                    set = function (info, value)
                        Questie.db.global.trackerShowCompleteQuests = value
                        QuestieTracker:Update()
                    end
                },
                Spacer_F4 = _QuestieOptions:Spacer(5.5, 0.001),
                showQuestLevels = {
                    type = "toggle",
                    order = 6,
                    width = 1.5,
                    name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL_DESC') end,
                    get = function() return Questie.db.global.trackerShowQuestLevel end,
                    set = function (info, value)
                        Questie.db.global.trackerShowQuestLevel = value
                        QuestieTracker:Update()
                    end
                },
                Spacer_Q = _QuestieOptions:Spacer(6.1,5),
                --[[colorObjectives = {
                    type = "toggle",
                    order = 6,
                    width = "full",
                    name = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES_DESC') end,
                    get = function() return Questie.db.global.trackerColorObjectives end,
                    set = function (info, value)
                        Questie.db.global.trackerColorObjectives = value
                        QuestieTracker:_ResetLinesForFontChange()
                        QuestieTracker:Update()
                    end
                },]]--
                colorObjectives = {
                    type = "select",
                    order = 8,
                    values = function() return {
                        ['white'] = QuestieLocale:GetUIString('TRACKER_COLOR_WHITE'),
                        ['whiteToGreen'] = QuestieLocale:GetUIString('TRACKER_COLOR_WHITE_TO_GREEN'),
                        ['redToGreen'] = QuestieLocale:GetUIString('TRACKER_COLOR_RED_TO_GREEN'),
                    } end,
                    style = 'dropdown',
                    name = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES_DESC') end,
                    get = function() return Questie.db.global.trackerColorObjectives end,
                    set = function(input, key)
                        Questie.db.global.trackerColorObjectives = key
                        QuestieTracker:Update()
                    end,
                },
                sortObjectives = {
                    type = "select",
                    order = 9,
                    values = function() return {
                        ['byComplete'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_COMPLETE'),
                        ['byLevel'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_LEVEL'),
                        ['byLevelReversed'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_LEVEL_REVERSED'),
                        ['none'] = QuestieLocale:GetUIString('TRACKER_DONT_SORT'),
                    } end,
                    style = 'dropdown',
                    name = function() return QuestieLocale:GetUIString('TRACKER_SORT_OBJECTIVES') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_SORT_OBJECTIVES_DESC') end,
                    get = function() return Questie.db.global.trackerSortObjectives end,
                    set = function(input, key)
                        Questie.db.global.trackerSortObjectives = key
                        QuestieTracker:Update()
                    end,
                },
                Spacer_F2 = _QuestieOptions:Spacer(9.1, 0.001),
                setTomTom = {
                    type = "select",
                    order = 9.2,
                    values = function() return {
                        ['left'] = QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['right'] = QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['shiftleft'] = QuestieLocale:GetUIString('TRACKER_SHIFT') .. QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['shiftright'] = QuestieLocale:GetUIString('TRACKER_SHIFT') .. QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['ctrlleft'] = QuestieLocale:GetUIString('TRACKER_CTRL') .. QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['ctrlright'] = QuestieLocale:GetUIString('TRACKER_CTRL') .. QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['altleft'] = QuestieLocale:GetUIString('TRACKER_ALT') .. QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['altright'] = QuestieLocale:GetUIString('TRACKER_ALT') .. QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['disabled'] = QuestieLocale:GetUIString('TRACKER_DISABLED'),
                    } end,
                    style = 'dropdown',
                    name = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM') .. QuestieLocale:GetUIString('TRACKER_SHORTCUT') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM_DESC') end,
                    get = function() return Questie.db.global.trackerbindSetTomTom end,
                    set = function(input, key)
                        Questie.db.global.trackerbindSetTomTom = key
                    end,
                },
                openQuestLog = {
                    type = "select",
                    order = 9.3,
                    values = function() return {
                        ['left'] = QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['right'] = QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['shiftleft'] = QuestieLocale:GetUIString('TRACKER_SHIFT') .. QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['shiftright'] = QuestieLocale:GetUIString('TRACKER_SHIFT') .. QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['ctrlleft'] = QuestieLocale:GetUIString('TRACKER_CTRL') .. QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['ctrlright'] = QuestieLocale:GetUIString('TRACKER_CTRL') .. QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['altleft'] = QuestieLocale:GetUIString('TRACKER_ALT') .. QuestieLocale:GetUIString('TRACKER_LEFT_CLICK'),
                        ['altright'] = QuestieLocale:GetUIString('TRACKER_ALT') .. QuestieLocale:GetUIString('TRACKER_RIGHT_CLICK'),
                        ['disabled'] = QuestieLocale:GetUIString('TRACKER_DISABLED'),
                    } end,
                    style = 'dropdown',
                    name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG') .. QuestieLocale:GetUIString('TRACKER_SHORTCUT') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG_DESC') end,
                    get = function() return Questie.db.global.trackerbindOpenQuestLog end,
                    set = function(input, key)
                        Questie.db.global.trackerbindOpenQuestLog = key
                    end,
                },
                Spacer_F = _QuestieOptions:Spacer(9.4, 5),
                
                fontSizeHeader = {
                    type = "range",
                    order = 10,
                    name = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER_DESC') end,
                    width = "double",
                    min = 2,
                    max = 36,
                    step = 0.5,
                    get = function() return Questie.db.global.trackerFontSizeHeader; end,
                    set = function (info, value)
                        Questie.db.global.trackerFontSizeHeader = value
                        QuestieTracker:_ResetLinesForFontChange()
                        QuestieTracker:Update()
                    end,
                },
                fontSizeLine = {
                    type = "range",
                    order = 11,
                    name = function() return QuestieLocale:GetUIString('TRACKER_FONT_LINE') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_LINE_DESC') end,
                    width = "double",
                    min = 2,
                    max = 36,
                    step = 0.5,
                    get = function() return Questie.db.global.trackerFontSizeLine; end,
                    set = function (info, value)
                        Questie.db.global.trackerFontSizeLine = value
                        QuestieTracker:_ResetLinesForFontChange()
                        QuestieTracker:Update()
                    end,
                },
                questPadding = {
                    type = "range",
                    order = 12,
                    name = function() return QuestieLocale:GetUIString('TRACKER_QUEST_PADDING') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_QUEST_PADDING_DESC') end,
                    width = "double",
                    min = 0,
                    max = 24,
                    step = 1,
                    get = function() return Questie.db.global.trackerQuestPadding; end,
                    set = function (info, value)
                        Questie.db.global.trackerQuestPadding = value
                        QuestieTracker:Update()
                    end,
                },
                Spacer_B = _QuestieOptions:Spacer(98, 5),
                resetTrackerLocation = {
                    type = "execute",
                    order = 99,
                    name = function() return QuestieLocale:GetUIString('TRACKER_RESET_LOCATION') end,
                    desc = function() return QuestieLocale:GetUIString('TRACKER_RESET_LOCATION_DESC') end,
                    disabled = function() return false end,
                    func = function (info, value)
                        QuestieTracker:ResetLocation()
                    end,
                }
            }
        },

        nameplate_tab = {
            name = function() return QuestieLocale:GetUIString('NAMEPLATE_TAB') end,
            type = "group",
            order = 14,
            args = {
                nameplate_options = {
                    type = "header",
                    order = 1,
                    name = function() return QuestieLocale:GetUIString('NAMEPLATE_HEAD') end,
                },
                nameplateEnabled = {
                    type = "toggle",
                    order = 3,
                    name = function() return QuestieLocale:GetUIString('NAMEPLATE_TOGGLE') end,
                    desc = function() return QuestieLocale:GetUIString('NAMEPLATE_TOGGLE_DESC') end,
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
                Spacer_A = _QuestieOptions:Spacer(4),
                nameplateX = {
                    type = "range",
                    order = 5,
                    name = function() return QuestieLocale:GetUIString('NAMEPLATE_X') end,
                    desc = function() return QuestieLocale:GetUIString('NAMEPLATE_X_DESC', _QuestieOptions.defaults.global.nameplateX ) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:RedrawIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateY = {
                    type = "range",
                    order = 5,
                    name = function() return QuestieLocale:GetUIString('NAMEPLATE_Y') end,
                    desc = function() return QuestieLocale:GetUIString('NAMEPLATE_Y_DESC', _QuestieOptions.defaults.global.nameplateY) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:RedrawIcons()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateScale = {
                    type = "range",
                    order = 6,
                    name = function() return QuestieLocale:GetUIString('NAMEPLATE_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('NAMEPLATE_SCALE_DESC', _QuestieOptions.defaults.global.nameplateScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                QuestieNameplate:RedrawIcons()
                            end,

                },
                Spacer_B = _QuestieOptions:Spacer(7),
                nameplateReset = {
                    type = "execute",
                    order = 8,
                    name = function() return QuestieLocale:GetUIString('NAMEPLATE_RESET_BTN') end,
                    desc = function() return QuestieLocale:GetUIString('NAMEPLATE_RESET_BTN_DESC') end,
                    disabled = function() return not Questie.db.global.nameplateEnabled end,
                    func = function (info, value)
                        Questie.db.global.nameplateX = _QuestieOptions.defaults.global.nameplateX;
                        Questie.db.global.nameplateY = _QuestieOptions.defaults.global.nameplateY;
                        Questie.db.global.nameplateScale = _QuestieOptions.defaults.global.nameplateScale;
                        QuestieNameplate:RedrawIcons();
                    end,
                },
                Spacer_C = _QuestieOptions:Spacer(9),
                targetframe_header = {
                    type = "header",
                    order = 20,
                    name = function() return QuestieLocale:GetUIString('TARGET_HEAD') end,
                },
                Spacer_D = _QuestieOptions:Spacer(21),
                nameplateTargetFrameEnabled = {
                    type = "toggle",
                    order = 22,
                    name = function() return QuestieLocale:GetUIString('TARGET_TOGGLE') end,
                    desc = function() return QuestieLocale:GetUIString('TARGET_TOGGLE_DESC') end,
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
                Spacer_E = _QuestieOptions:Spacer(23),
                nameplateTargetFrameX  = {
                    type = "range",
                    order = 24,
                    name = function() return QuestieLocale:GetUIString('TARGET_X') end,
                    desc = function() return QuestieLocale:GetUIString('TARGET_X_DESC', _QuestieOptions.defaults.global.nameplateTargetFrameX) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:RedrawFrameIcon()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateTargetFrameY  = {
                    type = "range",
                    order = 24,
                    name = function() return QuestieLocale:GetUIString('TARGET_Y') end,
                    desc = function() return QuestieLocale:GetUIString('TARGET_Y_DESC', _QuestieOptions.defaults.global.nameplateTargetFrameY) end,
                    width = "normal",
                    min = -200,
                    max = 200,
                    step = 1,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                QuestieNameplate:RedrawFrameIcon()
                                SetGlobalOptionLocal(info, value)
                            end,
                },
                nameplateTargetFrameScale  = {
                    type = "range",
                    order = 25,
                    name = function() return QuestieLocale:GetUIString('TARGET_SCALE') end,
                    desc = function() return QuestieLocale:GetUIString('TARGET_SCALE_DESC', _QuestieOptions.defaults.global.nameplateTargetFrameScale) end,
                    width = "double",
                    min = 0.01,
                    max = 4,
                    step = 0.01,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    get = GetGlobalOptionLocal,
                    set = function (info, value)
                                SetGlobalOptionLocal(info, value)
                                QuestieNameplate:RedrawFrameIcon()
                            end,

                },
                Spacer_F = _QuestieOptions:Spacer(26),
                targetFrameReset = {
                    type = "execute",
                    order = 27,
                    name = function() return QuestieLocale:GetUIString('TARGET_RESET_BTN') end,
                    desc = function() return QuestieLocale:GetUIString('TARGET_RESET_BTN_DESC') end,
                    disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled end,
                    func = function (info, value)
                        Questie.db.global.nameplateTargetFrameX = _QuestieOptions.defaults.global.nameplateTargetFrameX;
                        Questie.db.global.nameplateTargetFrameY = _QuestieOptions.defaults.global.nameplateTargetFrameY;
                        Questie.db.global.nameplateTargetFrameScale = _QuestieOptions.defaults.global.nameplateTargetFrameScale;
                        QuestieNameplate:RedrawFrameIcon();
                    end,
                },
            },
        },

        Advanced_tab = {
            name = function() return QuestieLocale:GetUIString('ADV_TAB') end,
            type = "group",
            order = 15,
            args = {
                map_options = {
                    type = "header",
                    order = 1,
                    name = function() return QuestieLocale:GetUIString('DEV_OPTIONS') end,
                },
                debugEnabled = {
                    type = "toggle",
                    order = 4,
                    name = function() return QuestieLocale:GetUIString('ENABLE_DEBUG') end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_DEBUG_DESC') end,
                    width = "full",
                    get =    function ()
                                return Questie.db.global.debugEnabled
                            end,
                    set =    function (info, value)
                                Questie.db.global.debugEnabled = value
                            end,
                },
                debugLevel = {
                    type = "range",
                    order = 5,
                    name = function() return QuestieLocale:GetUIString('DEBUG_LEVEL') end,
                    desc = function() return QuestieLocale:GetUIString('DEBUG_LEVEL_DESC', "\nDEBUG_CRITICAL = 1\nDEBUG_ELEVATED = 2\nDEBUG_INFO = 3\nDEBUG_DEVELOP = 4\nDEBUG_SPAM = 5") end,
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
                debugEnabledPrint = {
                    type = "toggle",
                    order = 6,
                    name = function() return QuestieLocale:GetUIString('ENABLE_DEBUG').."-PRINT" end,
                    desc = function() return QuestieLocale:GetUIString('ENABLE_DEBUG_DESC').."-PRINT" end,
                    width = "full",
                    get =    function ()
                                return Questie.db.global.debugEnabledPrint
                            end,
                    set =    function (info, value)
                                Questie.db.global.debugEnabledPrint = value
                            end,
                },

                Spacer_A = _QuestieOptions:Spacer(10),
                locale_header = {
                    type = "header",
                    order = 11,
                    name = function() return QuestieLocale:GetUIString('LOCALE') end,
                },
                Spacer_B = _QuestieOptions:Spacer(12),
                locale_dropdown = {
                    type = "select",
                    order = 13,
                    values = {
                        ['enUS'] = 'English',
                        ['esES'] = 'Español',
                        ['ptBR'] = 'Português',
                        ['frFR'] = 'Français',
                        ['deDE'] = 'Deutsch',
                        ['ruRU'] = 'русский',
                        ['zhCN'] = '简体中文',
                        ['zhTW'] = '正體中文',
                        ['koKR'] = '한국어',
                    },
                    style = 'dropdown',
                    name = function() return QuestieLocale:GetUIString('LOCALE_DROP') end,
                    get = function() return QuestieLocale:GetUILocale(); end,
                    set = function(input, lang)
                        QuestieLocale:SetUILocale(lang);
                        Questie.db.global.questieLocale = lang;
                        Questie.db.global.questieLocaleDiff = true;
                    end,
                },
                Spacer_C = _QuestieOptions:Spacer(20),
                reset_header = {
                    type = "header",
                    order = 21,
                    name = function() return QuestieLocale:GetUIString('RESET_QUESTIE') end,
                },
                Spacer_D = _QuestieOptions:Spacer(22),
                reset_text = {
                    type = "description",
                    order = 23,
                    name = function() return QuestieLocale:GetUIString('RESET_QUESTIE_DESC') end,
                    fontSize = "medium",
                },
                questieReset = {
                    type = "execute",
                    order = 24,
                    name = function() return QuestieLocale:GetUIString('RESET_QUESTIE_BTN') end,
                    desc = function() return QuestieLocale:GetUIString('RESET_QUESTIE_BTN_DESC') end,
                    func = function (info, value)
                        -- update all values to default
                        for k,v in pairs(_QuestieOptions.defaults.global) do
                           Questie.db.global[k] = v
                        end

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

                        -- Reset the show/hide on map
                        if Questie.db.global.mapShowHideEnabled then
                            Questie_Toggle:Show();
                        else
                            Questie_Toggle:Hide();
                        end

                        _QuestieOptions:Delay(0.3, _QuestieOptions.AvailableQuestRedraw, "minLevelFilter and maxLevelFilter reset to defaults");

                        QuestieNameplate:RedrawIcons();
                        QuestieMap:RescaleIcons();

                    end,
                },
                Spacer_E = _QuestieOptions:Spacer(30),
                github_text = {
                    type = "description",
                    order = 31,
                    name = function() return Questie:Colorize(QuestieLocale:GetUIString('QUESTIE_DEV_MESSAGE'), 'purple') end,
                    fontSize = "medium",
                },

            },
        }
    }
}


_QuestieOptions.minimapIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MinimapIcon", {
    type = "data source",
    text = "Questie",
    icon = ICON_TYPE_COMPLETE,

    OnClick = function (self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                QuestieQuest:ToggleNotes();

                -- CLose config window if it's open to avoid desyncing the Checkbox
                QuestieOptions:HideFrame();
                return;
            elseif IsControlKeyDown() then
                QuestieQuest:SmoothReset()
                return
            end

            QuestieOptions:OpenConfigWindow()

            if QuestieJourney:IsShown() then
                QuestieJourney.ToggleJourneyWindow();
            end
            return;

        elseif button == "RightButton" then
            if not IsModifierKeyDown() then
                -- CLose config window if it's open to avoid desyncing the Checkbox
                QuestieOptions:HideFrame();

                QuestieJourney.ToggleJourneyWindow();
                return;
            elseif IsControlKeyDown() then
                Questie.db.profile.minimap.hide = true;
                Questie.minimapConfigIcon:Hide("MinimapIcon");
                return;
            end
        end
    end,

    OnTooltipShow = function (tooltip)
        tooltip:AddLine("Questie", 1, 1, 1);
        tooltip:AddLine (Questie:Colorize(QuestieLocale:GetUIString('ICON_LEFT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_TOGGLE'));
        tooltip:AddLine (Questie:Colorize(QuestieLocale:GetUIString('ICON_SHIFTLEFT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_TOGGLE_QUESTIE'));
        tooltip:AddLine (Questie:Colorize(QuestieLocale:GetUIString('ICON_RIGHT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_JOURNEY'));
        tooltip:AddLine (Questie:Colorize(QuestieLocale:GetUIString('ICON_CTRLRIGHT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_HIDE'));
        tooltip:AddLine (Questie:Colorize(QuestieLocale:GetUIString('ICON_CTRLLEFT_CLICK'),   'gray') .. ": ".. QuestieLocale:GetUIString('ICON_RELOAD'));
    end,
});