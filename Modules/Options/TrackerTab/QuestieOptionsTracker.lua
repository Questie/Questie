QuestieOptions.tabs.tracker = {...}


function QuestieOptions.tabs.tracker:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('TRACKER_TAB'); end,
        type = "group",
        order = 13.5,
        args = {
            header = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('TRACKER_HEAD'); end,
            },
            questieTrackerEnabled = {
                type = "toggle",
                order = 2,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLED'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLED_DESC'); end,
                get = function() return Questie.db.global.trackerEnabled; end,
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
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK_DESC'); end,
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
            Spacer_F3 = QuestieOptionsUtils:Spacer(3.5, 0.001),
            hookBaseTracker = {
                type = "toggle",
                order = 4,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS_DESC'); end,
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
                order = 5,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE_DESC'); end,
                get = function() return Questie.db.global.trackerShowCompleteQuests; end,
                set = function (info, value)
                    Questie.db.global.trackerShowCompleteQuests = value
                    QuestieTracker:Update()
                end
            },
            Spacer_F4 = QuestieOptionsUtils:Spacer(5.5, 0.001),
            showQuestLevels = {
                type = "toggle",
                order = 6,
                width = 1.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL_DESC'); end,
                get = function() return Questie.db.global.trackerShowQuestLevel; end,
                set = function (info, value)
                    Questie.db.global.trackerShowQuestLevel = value
                    QuestieTracker:Update()
                end
            },
            Spacer_Q = QuestieOptionsUtils:Spacer(6.1,5),
            --[[colorObjectives = {
                type = "toggle",
                order = 6,
                width = "full",
                name = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES_DESC'); end,
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
                name = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_COLOR_OBJECTIVES_DESC'); end,
                get = function() return Questie.db.global.trackerColorObjectives; end,
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
                name = function() return QuestieLocale:GetUIString('TRACKER_SORT_OBJECTIVES'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SORT_OBJECTIVES_DESC'); end,
                get = function() return Questie.db.global.trackerSortObjectives; end,
                set = function(input, key)
                    Questie.db.global.trackerSortObjectives = key
                    QuestieTracker:Update()
                end,
            },
            Spacer_F2 = QuestieOptionsUtils:Spacer(9.1, 0.001),
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
                name = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM') .. QuestieLocale:GetUIString('TRACKER_SHORTCUT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM_DESC'); end,
                get = function() return Questie.db.global.trackerbindSetTomTom; end,
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
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG') .. QuestieLocale:GetUIString('TRACKER_SHORTCUT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG_DESC'); end,
                get = function() return Questie.db.global.trackerbindOpenQuestLog; end,
                set = function(input, key)
                    Questie.db.global.trackerbindOpenQuestLog = key
                end,
            },
            Spacer_F = QuestieOptionsUtils:Spacer(9.4, 5),

            fontSizeHeader = {
                type = "range",
                order = 10,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER_DESC'); end,
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
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_LINE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_LINE_DESC'); end,
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
                name = function() return QuestieLocale:GetUIString('TRACKER_QUEST_PADDING'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_QUEST_PADDING_DESC'); end,
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
            Spacer_B = QuestieOptionsUtils:Spacer(98, 5),
            resetTrackerLocation = {
                type = "execute",
                order = 99,
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