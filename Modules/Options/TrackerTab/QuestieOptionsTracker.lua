-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")

QuestieOptions.tabs.tracker = {...}

local _GetShortcuts

function QuestieOptions.tabs.tracker:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('TRACKER_TAB'); end,
        type = "group",
        order = 13,
        args = {
            header = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('TRACKER_OPTIONSHEADER'); end,
            },
            questieTrackerEnabled = {
                type = "toggle",
                order = 1.1,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLED'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLED_DESC'); end,
                get = function() return Questie.db.global.trackerEnabled; end,
                set = function (info, value)
                    QuestieTracker:Toggle(value)
                end
            },
            autoQuestTracking = {
                type = "toggle",
                order = 1.2,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return GetCVar("autoQuestWatch") == "1"; end,
                set = function (info, value)
                    if value then
                        SetCVar("autoQuestWatch", "1")
                    else
                        SetCVar("autoQuestWatch", "0")
                    end
                    QuestieTracker:Update()
                end
            },
            hookBaseTracker = {
                type = "toggle",
                order = 1.3,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hookTracking; end,
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
                order = 1.4,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerShowCompleteQuests; end,
                set = function (info, value)
                    Questie.db.global.trackerShowCompleteQuests = value
                    QuestieTracker:Update()
                end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.5,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerShowQuestLevel; end,
                set = function (info, value)
                    Questie.db.global.trackerShowQuestLevel = value
                    QuestieTracker:Update()
                end
            },
            showBlizzardQuestTimer = {
                type = "toggle",
                order = 1.6,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_BLIZZARD_QUEST_TIMER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_BLIZZARD_QUEST_TIMER_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return (Questie.db.global.showBlizzardQuestTimer or (not Questie.db.global.trackerEnabled)); end,
                set = function (info, value)
                    Questie.db.global.showBlizzardQuestTimer = value
                    if value then
                        QuestieQuestTimers:ShowBlizzardTimer()
                    else
                        QuestieQuestTimers:HideBlizzardTimer()
                    end
                end
            },
            stickyDurabilityFrame = {
                type = "toggle",
                order = 1.7,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_STICKY_DURABILITY_FRAME'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_STICKY_DURABILITY_FRAME_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return (Questie.db.global.stickyDurabilityFrame and Questie.db.global.trackerEnabled); end,
                set = function (info, value)
                    Questie.db.global.stickyDurabilityFrame = value
                    if value then
                        QuestieTracker:MoveDurabilityFrame()
                    else
                        QuestieTracker:ResetDurabilityFrame()
                    end
                end
            },
            hideTrackerInCombat = {
                type = "toggle",
                order = 1.8,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_HIDE_IN_COMBAT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_HIDE_IN_COMBAT_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hideTrackerInCombat; end,
                set = function (info, value)
                    Questie.db.global.hideTrackerInCombat = value
                end
            },
            showTrackerBackdrop = {
                type = "toggle",
                order = 1.9,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_BACKDROP'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_BACKDROP_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerBackdropEnabled; end,
                set = function (info, value)
                    Questie.db.global.trackerBackdropEnabled = value
					QuestieTracker:Update()
                end
            },
            Spacer_S = QuestieOptionsUtils:Spacer(2.0),
            --[[colorObjectives = {
                type = "toggle",
                order = 6,
                width = "full",
                name = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES_DESC'); end,
                get = function() return Questie.db.global.trackerColorObjectives end,
                set = function (info, value)
                    Questie.db.global.trackerColorObjectives = value
                    QuestieTracker:ResetLinesForFontChange()
                    QuestieTracker:Update()
                end
            },]]--
            colorObjectives = {
                type = "select",
                order = 2.1,
                values = function() return {
                    ['white'] = QuestieLocale:GetUIString('TRACKER_COLOR_WHITE'),
                    ['whiteToGreen'] = QuestieLocale:GetUIString('TRACKER_COLOR_WHITE_TO_GREEN'),
                    ['whiteAndGreen'] = QuestieLocale:GetUIString('TRACKER_COLOR_WHITE_AND_GREEN'),
                    ['redToGreen'] = QuestieLocale:GetUIString('TRACKER_COLOR_RED_TO_GREEN')
                } end,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerColorObjectives; end,
                set = function(input, key)
                    Questie.db.global.trackerColorObjectives = key
                    QuestieTracker:Update()
                end,
            },
            sortObjectives = {
                type = "select",
                order = 2.2,
                values = function() return {
                    ['byComplete'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_COMPLETE'),
                    ['byLevel'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_LEVEL'),
                    ['byLevelReversed'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_LEVEL_REVERSED'),
                    ['byProximity'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_PROXIMITY'),
					['byZone'] = QuestieLocale:GetUIString('TRACKER_SORT_BY_ZONE'),
                    ['none'] = QuestieLocale:GetUIString('TRACKER_DONT_SORT'),
                } end,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SORT_OBJECTIVES'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SORT_OBJECTIVES_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerSortObjectives; end,
                set = function(input, key)
                    Questie.db.global.trackerSortObjectives = key
                    QuestieTracker:Update()
                end,
            },
            setTomTom = {
                type = "select",
                order = 2.3,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM') .. QuestieLocale:GetUIString('SHORTCUT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindSetTomTom; end,
                set = function(input, key)
                    Questie.db.global.trackerbindSetTomTom = key
                end,
            },
            openQuestLog = {
                type = "select",
                order = 2.4,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG') .. QuestieLocale:GetUIString('SHORTCUT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindOpenQuestLog; end,
                set = function(input, key)
                    Questie.db.global.trackerbindOpenQuestLog = key
                end,
            },
            untrackQuest = {
                type = "select",
                order = 2.5,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_UNTRACK') .. QuestieLocale:GetUIString('SHORTCUT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_UNTRACK_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindUntrack; end,
                set = function(input, key)
                    Questie.db.global.trackerbindUntrack = key
                end,
            },
            trackerSetpoint = {
                type = "select",
                order = 2.6,
                values = function() return {
                    ["TOPLEFT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_TOPLEFT'),
                    ["TOPRIGHT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_TOPRIGHT'),
                    ["BOTTOMLEFT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_BOTTOMLEFT'),
					["BOTTOMRIGHT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_BOTTOMRIGHT'),
                } end,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SETPOINT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SETPOINT_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerSetpoint; end,
                set = function(input, key)
                    Questie.db.global.trackerSetpoint = key
					QuestieTracker:ResetLocation()
                end,
            },
            Spacer_G = QuestieOptionsUtils:Spacer(2.7),

            fontSizeHeader = {
                type = "range",
                order = 2.8,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_HEADER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_HEADER_DESC'); end,
                width = "double",
                min = 10,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeHeader; end,
                set = function (info, value)
                    Questie.db.global.trackerFontSizeHeader = value
                    QuestieTracker:ResetLinesForFontChange()
                    QuestieTracker:Update()
                end,
            },
            fontHeader = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 2.85,
                values = AceGUIWidgetLSMlists.font,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontHeader or "Friz Quadrata TT"; end,
                set = function(info, value)
                    Questie.db.global.trackerFontHeader = value
                    QuestieTracker:ResetLinesForFontChange()
                    QuestieTracker:Update()
                end,
            },
            fontSizeLine = {
                type = "range",
                order = 2.9,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_LINE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_LINE_DESC'); end,
                width = "double",
                min = 9,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeLine; end,
                set = function (info, value)
                    Questie.db.global.trackerFontSizeLine = value
                    QuestieTracker:ResetLinesForFontChange()
                    QuestieTracker:Update()
                end,
            },
            fontLine = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 2.95,
                values = AceGUIWidgetLSMlists.font,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_LINE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_LINE_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontLine or "Friz Quadrata TT"; end,
                set = function(info, value)
                    Questie.db.global.trackerFontLine = value
                    QuestieTracker:ResetLinesForFontChange()
                    QuestieTracker:Update()
                end,
            },
            questPadding = {
                type = "range",
                order = 3.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_QUEST_PADDING'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_QUEST_PADDING_DESC'); end,
                width = "double",
                min = 2,
                max = 16,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerQuestPadding; end,
                set = function (info, value)
                    Questie.db.global.trackerQuestPadding = value
                    QuestieTracker:Update()
                end,
            },
            questBackdropAlpha = {
                type = "range",
                order = 3.1,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_BACKGROUND_ALPHA'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_BACKGROUND_ALPHA_DESC'); end,
                width = "double",
                min = 0,
                max = 100,
                step = 5,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerBackdropAlpha*100; end,
                set = function (info, value)
                    Questie.db.global.trackerBackdropAlpha = value/100
                    QuestieTracker:Update()
                end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(3.2),
            resetTrackerLocation = {
                type = "execute",
                order = 3.3,
                name = function() return QuestieLocale:GetUIString('TRACKER_RESET_LOCATION'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_RESET_LOCATION_DESC'); end,
                disabled = function() return false; end,
                func = function (info, value)
                    QuestieTracker:ResetLocation()
                end,
            }
        }
    }
end

_GetShortcuts = function()
    return {
        ['left'] = QuestieLocale:GetUIString('LEFT_CLICK'),
        ['right'] = QuestieLocale:GetUIString('RIGHT_CLICK'),
        ['shiftleft'] = QuestieLocale:GetUIString('SHIFT_MODIFIER') .. " + " .. QuestieLocale:GetUIString('LEFT_CLICK'),
        ['shiftright'] = QuestieLocale:GetUIString('SHIFT_MODIFIER') .. " + " .. QuestieLocale:GetUIString('RIGHT_CLICK'),
        ['ctrlleft'] = QuestieLocale:GetUIString('CTRL_MODIFIER') .. " + " .. QuestieLocale:GetUIString('LEFT_CLICK'),
        ['ctrlright'] = QuestieLocale:GetUIString('CTRL_MODIFIER') .. " + " .. QuestieLocale:GetUIString('RIGHT_CLICK'),
        ['altleft'] = QuestieLocale:GetUIString('ALT_MODIFIER') .. " + " .. QuestieLocale:GetUIString('LEFT_CLICK'),
        ['altright'] = QuestieLocale:GetUIString('ALT_MODIFIER') .. " + " .. QuestieLocale:GetUIString('RIGHT_CLICK'),
        ['disabled'] = QuestieLocale:GetUIString('DISABLED'),
    }
end
