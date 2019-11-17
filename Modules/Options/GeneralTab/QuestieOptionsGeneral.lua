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
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");

QuestieOptions.tabs.general = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.general:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('OPTIONS_TAB'); end,
        type = "group",
        order = 10,
        args = {
            questie_header = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('QUESTIE_HEADER'); end,
            },
            enabled = {
                type = "toggle",
                order = 3,
                name = function() return QuestieLocale:GetUIString('ENABLE_QUESTIE'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_QUESTIE_DESC'); end,
                width = "full",
                get = function () return Questie.db.char.enabled; end,
                set = function (info, value)
                    QuestieQuest:ToggleNotes(value);
                    Questie.db.char.enabled = value
                end,
            },
            iconTypes = {
                type = "group",
                order = 4,
                inline = true,
                name = function() return QuestieLocale:GetUIString('ICON_TYPE_HEADER'); end,
                args = {
                    --[[enableMinimalisticIcons = {
                        type = "toggle",
                        order = 0.9,
                        name = function() return "(VERY VERY WORK IN PROGRESS!!!)"..QuestieLocale:GetUIString('ENABLE_MAP_ICONS_MINIMALISTIC'); end,
                        desc = function() return "(VERY VERY WORK IN PROGRESS!!!)"..QuestieLocale:GetUIString('ENABLE_MAP_ICONS_DESC_MINIMALISTIC'); end,
                        width = "full",
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.char.enableMinimalisticIcons; end,
                        set = function (info, value)
                            Questie.db.char.enableMinimalisticIcons = value
                            QuestieFramePool:SetIcons();
                            QuestieQuest:SmoothReset();
                        end,
                    },]]--
                    enableMapToggle = {
                        type = "toggle",
                        order = 1,
                        name = function() return QuestieLocale:GetUIString('ENABLE_MAP_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_MAP_ICONS_DESC'); end,
                        width = "full",
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableMapIcons; end,
                        set = function (info, value)
                            Questie.db.global.enableMapIcons = value
                            QuestieQuest:UpdateHiddenNotes();
                        end,
                    },
                    enableMiniMapToggle = {
                        type = "toggle",
                        order = 2,
                        name = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_MINIMAP_ICONS_DESC'); end,
                        width = "full",
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableMiniMapIcons; end,
                        set = function (info, value)
                            Questie.db.global.enableMiniMapIcons = value
                            QuestieQuest:UpdateHiddenNotes();
                        end,
                    },
                    hideUnexploredMapIconsToggle = {
                        type = "toggle",
                        order = 3,
                        name = function() return QuestieLocale:GetUIString('HIDE_UNEXPLORED_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('HIDE_UNEXPLORED_ICONS_DESC'); end,
                        width = "full",
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function() return Questie.db.global.hideUnexploredMapIcons; end,
                        set = function(info, value)
                            Questie.db.global.hideUnexploredMapIcons = value
                            QuestieQuest:Reset();
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
                            QuestieQuest:UpdateHiddenNotes();
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
                            QuestieQuest:UpdateHiddenNotes();
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
                            QuestieQuest:UpdateHiddenNotes();
                        end,
                    },
                    showRepeatableQuests = {
                        type = "toggle",
                        order = 8,
                        name = function() return QuestieLocale:GetUIString('ENABLE_REPEATABLE_QUEST_ICONS'); end,
                        desc = function() return QuestieLocale:GetUIString('ENABLE_REPEATABLE_QUEST_ICONS_DESC'); end,
                        width = 1.5,
                        get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetGlobalOptionValue(info, value)
                            QuestieQuest:Reset();
                        end,
                    },
                },
            },
            iconEnabled = {
                type = "toggle",
                order = 5,
                name = function() return QuestieLocale:GetUIString('ENABLE_ICON'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_ICON_DESC'); end,
                width = 1.5,
                get = function () return not Questie.db.profile.minimap.hide; end,
                set = function (info, value)
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
                order = 7,
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
                order = 8,
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
                order = 8.1,
                name = function() return QuestieLocale:GetUIString('ENABLE_AUTO_ACCEPT_QUESTS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_AUTO_ACCEPT_QUESTS_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.char.autoaccept; end,
                set = function (info, value)
                    Questie.db.char.autoaccept = value
                    Questie:debug(DEBUG_DEVELOP, "Auto Accept toggled to:", value)
                end,
            },
            autocomplete = {
                type = "toggle",
                order = 8.1,
                name = function() return QuestieLocale:GetUIString('ENABLE_AUTO_COMPLETE'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_AUTO_COMPLETE_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.char.autocomplete; end,
                set = function (info, value)
                    Questie.db.char.autocomplete = value
                    Questie:debug(DEBUG_DEVELOP, "Auto Complete toggled to:", value)
                end,
            },
            --Spacer_A = _QuestieOptions:Spacer(9),
            quest_options = {
                type = "header",
                order = 9,
                name = function() return QuestieLocale:GetUIString('LEVEL_HEADER'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(9),
            gray = {
                type = "toggle",
                order = 10,
                name = function() return QuestieLocale:GetUIString('ENABLE_LOWLEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_LOWLEVEL_DESC'); end,
                width = 200,
                get = function () return Questie.db.char.lowlevel; end,
                set = function (info, value)
                    Questie.db.char.lowlevel = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('DEBUG_LOWLEVEL'), value)
                end,
            },
            manualMinLevelOffset = {
                type = "toggle",
                order = 10.9,
                name = function() return QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET_DESC'); end,
                width = 200,
                disabled = function() return Questie.db.char.lowlevel; end,
                get = function () return Questie.db.char.manualMinLevelOffset; end,
                set = function (info, value)
                    Questie.db.char.manualMinLevelOffset = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('ENABLE_MANUAL_OFFSET'), value)
                end,
            },
            minLevelFilter = {
                type = "range",
                order = 11,
                name = function() return QuestieLocale:GetUIString('LOWLEVEL_BELOW'); end,
                desc = function() return QuestieLocale:GetUIString('LOWLEVEL_BELOW_DESC', optionsDefaults.global.minLevelFilter); end,
                width = "normal",
                min = 0,
                max = QuestiePlayer:GetPlayerLevel() - 1,
                step = 1,
                disabled = function()
                    if(Questie.db.char.manualMinLevelOffset and not Questie.db.char.lowlevel) then
                        return false;
                    else
                        return true;
                    end
                end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, QuestieLocale:GetUIString('DEBUG_MINLEVEL', value))
                end,
            },
            maxLevelFilter = {
                type = "range",
                order = 12,
                name = function() return QuestieLocale:GetUIString('LOWLEVEL_ABOVE'); end,
                desc = function() return QuestieLocale:GetUIString('LOWLEVEL_ABOVE_DESC', optionsDefaults.global.maxLevelFilter); end,
                width = "normal",
                min = 0,
                max = 60,
                step = 1,
                disabled = function() return QuestiePlayer:GetPlayerLevel() == 60; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, QuestieLocale:GetUIString('DEBUG_MAXLEVEL', value))
                end,
            },
            clusterLevelHotzone = {
                type = "range",
                order = 13,
                name = function() return QuestieLocale:GetUIString('CLUSTER'); end,
                desc = function() return QuestieLocale:GetUIString('CLUSTER_DESC'); end,
                width = "double",
                min = 1,
                max = 300,
                step = 1,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QUESTIE_CLUSTER_DISTANCE = value;
                    QuestieOptionsUtils:Delay(0.5, QuestieOptions.ClusterRedraw, QuestieLocale:GetUIString('DEBUG_CLUSTER', value))
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
        },
    }
end
