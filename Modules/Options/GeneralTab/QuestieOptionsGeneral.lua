-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");

QuestieOptions.tabs.general = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetShortcuts

function QuestieOptions.tabs.general:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('GENERAL_TAB'); end,
        type = "group",
        order = 10,
        args = {
            questie_header = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('GENERAL_OPTIONS_HEADER'); end,
            },
            enabled = {
                type = "toggle",
                order = 1.1,
                name = function() return QuestieLocale:GetUIString('ENABLE_ICONS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_ICONS_DESC'); end,
                width = "full",
                get = function () return Questie.db.char.enabled; end,
                set = function (info, value)
                    Questie.db.char.enabled = value
                    QuestieQuest:ToggleNotes(value);
                end,
            },
            iconTypes = {
                type = "group",
                order = 1.2,
                inline = true,
                name = function() return QuestieLocale:GetUIString('ICON_TYPE_HEADER'); end,
                args = {
                    enableMapToggle = {
                        type = "toggle",
                        order = 1,
                        name = function() return QuestieLocale:GetUIString('ENABLE_MAP_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableMapIcons; end,
                        set = function (info, value)
                            Questie.db.global.enableMapIcons = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    enableMiniMapToggle = {
                        type = "toggle",
                        order = 2,
                        name = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableMiniMapIcons; end,
                        set = function (info, value)
                            Questie.db.global.enableMiniMapIcons = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    hideUnexploredMapIconsToggle = {
                        type = "toggle",
                        order = 3,
                        name = function() return QuestieLocale:GetUIString('HIDE_UNEXPLORED_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('HIDE_UNEXPLORED_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function() return Questie.db.char.hideUnexploredMapIcons; end,
                        set = function(info, value)
                            Questie.db.char.hideUnexploredMapIcons = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    seperatingHeader1 = {
                        type = "header",
                        order = 4,
                        name = "",
                    },
                    enableObjectivesToggle = {
                        type = "toggle",
                        order = 5,
                        name = function() return QuestieLocale:GetUIString('ENABLE_OBJECTIVES'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_OBJECTIVES_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableObjectives; end,
                        set = function (info, value)
                            Questie.db.global.enableObjectives = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    enableTurninsToggle = {
                        type = "toggle",
                        order = 6,
                        name = function() return QuestieLocale:GetUIString('ENABLE_TURNINS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_TURNINS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableTurnins; end,
                        set = function (info, value)
                            Questie.db.global.enableTurnins = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    enableAvailableToggle = {
                        type = "toggle",
                        order = 7,
                        name = function() return QuestieLocale:GetUIString('ENABLE_AVAILABLE'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_AVAILABLE_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableAvailable; end,
                        set = function (info, value)
                            Questie.db.global.enableAvailable = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showRepeatableQuests = {
                        type = "toggle",
                        order = 8,
                        name = function() return QuestieLocale:GetUIString('ENABLE_REPEATABLE_QUEST_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_REPEATABLE_QUEST_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showRepeatableQuests end,
                        set = function (info, value)
                            Questie.db.char.showRepeatableQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showEventQuests = {
                        type = "toggle",
                        order = 9,
                        name = function() return QuestieLocale:GetUIString('ENABLE_EVENT_QUEST_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_EVENT_QUEST_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showEventQuests end,
                        set = function (info, value)
                            Questie.db.char.showEventQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showDungeonQuests = {
                        type = "toggle",
                        order = 10,
                        name = function() return QuestieLocale:GetUIString('ENABLE_DUNGEON_QUEST_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_DUNGEON_QUEST_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showDungeonQuests end,
                        set = function (info, value)
                            Questie.db.char.showDungeonQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showRaidQuests = {
                        type = "toggle",
                        order = 10,
                        name = function() return QuestieLocale:GetUIString('ENABLE_DUNGEON_RAID_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_DUNGEON_RAID_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showRaidQuests end,
                        set = function (info, value)
                            Questie.db.char.showRaidQuests = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    showPvPQuests = {
                        type = "toggle",
                        order = 11,
                        name = function() return QuestieLocale:GetUIString('ENABLE_PVP_QUEST_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_PVP_QUEST_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showPvPQuests end,
                        set = function (info, value)
                            Questie.db.char.showPvPQuests = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    showAQWarEffortQuests = {
                        type = "toggle",
                        order = 12,
                        name = function() return QuestieLocale:GetUIString('ENABLE_AQ_QUEST_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_AQ_QUEST_ICONS_DESC'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showAQWarEffortQuests end,
                        set = function (info, value)
                            Questie.db.char.showAQWarEffortQuests = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                },
            },
            Spacer_A = QuestieOptionsUtils:Spacer(1.22),
            minimapButtonEnabled = {
                type = "toggle",
                order = 1.3,
                name = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_BUTTON'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_BUTTON_DESC'); end,
                width = 1.5,
                get = function () return not Questie.db.profile.minimap.hide; end,
                set = function (info, value)
                    Questie.db.profile.minimap.hide = not value;

                    if value then
                        Questie.minimapConfigIcon:Show("Questie");
                    else
                        Questie.minimapConfigIcon:Hide("Questie");
                    end
                end,
            },
            instantQuest = {
                type = "toggle",
                order = 1.4,
                name = function() return QuestieLocale:GetUIString('ENABLE_INSTANT'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_INSTANT_DESC'); end,
                width = 1.5,
                get = function () if GetCVar("instantQuestText") == '1' then return true; else return false; end; end,
                set = function (info, value)
                    if value then
                        SetCVar("instantQuestText", 1);
                    else
                        SetCVar("instantQuestText", 0);
                    end
                end,
            },
            enableTooltipsToggle = {
                type = "toggle",
                order = 1.5,
                name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.global.enableTooltips; end,
                set = function (info, value)
                    Questie.db.global.enableTooltips = value
                end,
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.6,
                name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL_DESC'); end,
                width = 1.5,
                disabled = function() return not Questie.db.global.enableTooltips; end,
                get = function() return Questie.db.global.enableTooltipsQuestLevel; end,
                set = function (info, value)
                    Questie.db.global.enableTooltipsQuestLevel = value
                    if value and not Questie.db.global.trackerShowQuestLevel then
                        Questie.db.global.trackerShowQuestLevel = true
                        QuestieTracker:Update()
                    end
                end
            },
            autoaccept = {
                type = "toggle",
                order = 1.7,
                name = function() return QuestieLocale:GetUIString('ENABLE_AUTO_ACCEPT_QUESTS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_AUTO_ACCEPT_QUESTS_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.char.autoaccept; end,
                set = function (info, value)
                    Questie.db.char.autoaccept = value
                    Questie:Debug(DEBUG_DEVELOP, "Auto Accept toggled to:", value)
                end,
            },
            autocomplete = {
                type = "toggle",
                order = 1.8,
                name = function() return QuestieLocale:GetUIString('ENABLE_AUTO_COMPLETE'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_AUTO_COMPLETE_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.char.autocomplete; end,
                set = function (info, value)
                    Questie.db.char.autocomplete = value
                    Questie:Debug(DEBUG_DEVELOP, "Auto Complete toggled to:", value)
                end,
            },
            autoModifier = {
                type = "select",
                order = 1.9,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('AUTO_MODIFIER') end,
                desc = function() return QuestieLocale:GetUIString('AUTO_MODIFIER_DESC'); end,
                disabled = function() return (not Questie.db.char.autocomplete) and (not Questie.db.char.autoaccept) end,
                get = function() return Questie.db.char.autoModifier; end,
                set = function(input, key)
                    Questie.db.char.autoModifier = key
                end,
            },
            Spacer_H = QuestieOptionsUtils:HorizontalSpacer(1.91, 0.5),
            acceptTrivial = {
                type = "toggle",
                order = 1.92,
                name = function() return QuestieLocale:GetUIString('ENABLE_ACCEPT_TRIVIAL'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_ACCEPT_TRIVIAL_DESC'); end,
                disabled = function() return (not Questie.db.char.autoaccept) end,
                width = 1.5,
                get = function () return Questie.db.char.acceptTrivial; end,
                set = function (info, value)
                    Questie.db.char.acceptTrivial = value
                end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(1.93),
            shareQuestsNearby = {
                type = "toggle",
                order = 1.94,
                name = function() return QuestieLocale:GetUIString('ENABLE_YELL'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_YELL_DESC'); end,
                disabled = function() return false end,
                width = 2,
                get = function () return not Questie.db.global.disableYellComms end,
                set = function (info, value)
                    Questie.db.global.disableYellComms = not value
                    if not value then
                        QuestieLoader:ImportModule("QuestieComms"):RemoveAllRemotePlayers()
                    end
                end,
            },
            --Spacer_C = QuestieOptionsUtils:Spacer(1.99),
            quest_options = {
                type = "header",
                order = 2,
                name = function() return QuestieLocale:GetUIString('LEVEL_HEADER'); end,
            },
            gray = {
                type = "toggle",
                order = 2.2,
                name = function() return QuestieLocale:GetUIString('ENABLE_LOWLEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_LOWLEVEL_DESC'); end,
                width = "full",
                get = function () return Questie.db.char.lowlevel; end,
                set = function (info, value)
                    Questie.db.char.lowlevel = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('DEBUG_LOWLEVEL'), value)
                end,
            },
            manualMinLevelOffset = {
                type = "toggle",
                order = 2.3,
                name = function() return QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET_DESC'); end,
                width = 1.5,
                disabled = function() return Questie.db.char.lowlevel or Questie.db.char.absoluteLevelOffset; end,
                get = function () return Questie.db.char.manualMinLevelOffset; end,
                set = function (info, value)
                    Questie.db.char.manualMinLevelOffset = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET'), value)
                end,
            },
            absoluteLevelOffset = {
                type = "toggle",
                order = 2.4,
                name = function() return QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET_ABSOLUTE'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET_ABSOLUTE_DESC'); end,
                width = 1.5,
                disabled = function() return Questie.db.char.lowlevel or Questie.db.char.manualMinLevelOffset; end,
                get = function () return Questie.db.char.absoluteLevelOffset; end,
                set = function (info, value)
                    Questie.db.char.absoluteLevelOffset = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET_ABSOLUTE'), value)
                end,
            },
            minLevelFilter = {
                type = "range",
                order = 2.5,
                name = function()
                    if Questie.db.char.absoluteLevelOffset then 
                        return QuestieLocale:GetUIString('LEVEL_FROM');
                    else
                        return QuestieLocale:GetUIString('LOWLEVEL_BELOW'); 
                    end
                end,
                desc = function()
                    if Questie.db.char.absoluteLevelOffset then
                        return QuestieLocale:GetUIString('LEVEL_FROM_DESC');
                    else
                        return QuestieLocale:GetUIString('LOWLEVEL_BELOW_DESC', optionsDefaults.char.minLevelFilter);
                    end
                end,
                width = "normal",
                min = 0,
                max = 60,
                step = 1,
                disabled = function() return (not Questie.db.char.manualMinLevelOffset) and (not Questie.db.char.absoluteLevelOffset); end,
                get = function() return Questie.db.char.minLevelFilter; end,
                set = function (info, value)
                    Questie.db.char.minLevelFilter = value;
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, QuestieLocale:GetUIString('DEBUG_MINLEVEL', value))
                end,
            },
            maxLevelFilter = {
                type = "range",
                order = 2.6,
                name = function()
                    return QuestieLocale:GetUIString('LEVEL_TO');
                end,
                desc = function()
                    return QuestieLocale:GetUIString('LEVEL_TO_DESC');
                end,
                width = "normal",
                min = 0,
                max = 60,
                step = 1,
                disabled = function() return (not Questie.db.char.absoluteLevelOffset); end,
                get = function(info) return Questie.db.char.maxLevelFilter; end,
                set = function (info, value)
                    Questie.db.char.maxLevelFilter = value;
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, QuestieLocale:GetUIString('DEBUG_MAXLEVEL', value))
                end,
            },
            clusterLevelHotzone = {
                type = "range",
                order = 2.7,
                name = function() return QuestieLocale:GetUIString('CLUSTER'); end,
                desc = function() return QuestieLocale:GetUIString('CLUSTER_DESC'); end,
                width = "double",
                min = 1,
                max = 300,
                step = 1,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieOptions.ClusterRedraw, QuestieLocale:GetUIString('DEBUG_CLUSTER', value))
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
        },
    }
end

_GetShortcuts = function()
    return {
        ['shift'] = QuestieLocale:GetUIString('SHIFT_MODIFIER'),
        ['ctrl'] = QuestieLocale:GetUIString('CTRL_MODIFIER'),
        ['alt'] = QuestieLocale:GetUIString('ALT_MODIFIER'),
        ['disabled'] = QuestieLocale:GetUIString('DISABLED'),
    }
end
