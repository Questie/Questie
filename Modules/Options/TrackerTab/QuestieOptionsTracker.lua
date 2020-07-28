-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private
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
            autoTrackQuests = {
                type = "toggle",
                order = 1.1,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_AUTOTRACK_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.autoTrackQuests; end,
                set = function (info, value)
                    Questie.db.global.autoTrackQuests = value
                    if value then
                        SetCVar("autoQuestWatch", "1")
                        Questie.db.char.TrackedQuests = {}

                    else
                        SetCVar("autoQuestWatch", "0")
                        Questie.db.char.AutoUntrackedQuests = {}
                    end
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            showCompleteQuests = {
                type = "toggle",
                order = 1.2,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_COMPLETE_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerShowCompleteQuests; end,
                set = function (info, value)
                    Questie.db.global.trackerShowCompleteQuests = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            collapseCompletedQuests = {
                type = "toggle",
                order = 1.3,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_COLLAPSE_COMPLETED'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_COLLAPSE_COMPLETED_DESC'); end,
                get = function() return Questie.db.global.collapseCompletedQuests; end,
                set = function (info, value)
                    Questie.db.global.collapseCompletedQuests = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.4,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUEST_LEVEL_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerShowQuestLevel; end,
                set = function (info, value)
                    Questie.db.global.trackerShowQuestLevel = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            showQuestTimer = {
                type = "toggle",
                order = 1.5,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_BLIZZARD_QUEST_TIMER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_BLIZZARD_QUEST_TIMER_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return (Questie.db.global.showBlizzardQuestTimer or (not Questie.db.global.trackerEnabled)); end,
                set = function (info, value)
                    Questie.db.global.showBlizzardQuestTimer = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            enableTrackerHooks = {
                type = "toggle",
                order = 1.6,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_HOOKS_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hookTracking; end,
                set = function (info, value)
                    Questie.db.global.hookTracking = value
                    if value == true then
                        -- may not have been initialized yet
                        QuestieTracker:HookBaseTracker()
                    else
                        QuestieTracker:Unhook()
                    end
                    QuestieTracker:Update()
                end
            },
            enableHeader = {
                type = "toggle",
                order = 1.7,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_HEADER_ENABLED'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_HEADER_ENABLED_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerHeaderEnabled; end,
                set = function (info, value)
                    Questie.db.global.trackerHeaderEnabled = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            autoMoveHeader = {
                type = "toggle",
                order = 1.8,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_AUTO_MOVE_HEADER_ENABLED'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_AUTO_MOVE_HEADER_ENABLED_DESC'); end,
                disabled = function() return not Questie.db.global.trackerHeaderEnabled or not Questie.db.global.trackerEnabled or Questie.db[Questie.db.global.questieTLoc].trackerSetpoint ~= "AUTO"; end,
                get = function() return Questie.db.global.trackerHeaderAutoMove; end,
                set = function (info, value)
                    Questie.db.global.trackerHeaderAutoMove = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            stickyDurabilityFrame = {
                type = "toggle",
                order = 1.9,
                width = 1.0,
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
            minimizeInCombat = {
                type = "toggle",
                order = 2.0,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_HIDE_IN_COMBAT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_HIDE_IN_COMBAT_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hideTrackerInCombat; end,
                set = function (info, value)
                    Questie.db.global.hideTrackerInCombat = value
                end
            },
            fadeMinMaxButtons = {
                type = "toggle",
                order = 2.1,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_FADE_MINMAX_BUTTONS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FADE_MINMAX_BUTTONS_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFadeMinMaxButtons; end,
                set = function (info, value)
                    Questie.db.global.trackerFadeMinMaxButtons = value
                    if value == true then
                        QuestieTracker.FadeMMBTickerValue = 1
                        QuestieTracker.FadeMMBTicker = C_Timer.NewTicker(0.02, function()

                            if QuestieTracker.FadeMMBTickerValue > 0 then
                                QuestieTracker.FadeMMBTickerValue = QuestieTracker.FadeMMBTickerValue - 0.02

                                if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                                    for i=1, _QuestieTracker.highestIndex do
                                        _QuestieTracker.LineFrames[i].expandQuest:SetAlpha(QuestieTracker.FadeMMBTickerValue*3.3)
                                    end
                                end

                            else
                                QuestieTracker.FadeMMBTicker:Cancel()
                                QuestieTracker.FadeMMBTicker = nil
                            end
                        end)
                    else
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandQuest:SetAlpha(1)
                        end
                    end
                    QuestieTracker:Update()
                end
            },
            fadeQuestItemButtons = {
                type = "toggle",
                order = 2.2,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_FADE_QUEST_ITEM_BUTTONS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FADE_QUEST_ITEM_BUTTONS_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFadeQuestItemButtons; end,
                set = function (info, value)
                    Questie.db.global.trackerFadeQuestItemButtons = value
                    if value == true then
                        QuestieTracker.FadeQIBTickerValue = 1
                        QuestieTracker.FadeQIBTicker = C_Timer.NewTicker(0.02, function()

                            if QuestieTracker.FadeQIBTickerValue > 0 then
                                QuestieTracker.FadeQIBTickerValue = QuestieTracker.FadeQIBTickerValue - 0.02

                                if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                                    for i=1, _QuestieTracker.highestIndex do
                                        if _QuestieTracker.LineFrames[i].button then
                                            _QuestieTracker.LineFrames[i].button:SetAlpha(QuestieTracker.FadeQIBTickerValue*3.3)
                                        end
                                    end
                                end

                            else
                                QuestieTracker.FadeQIBTicker:Cancel()
                                QuestieTracker.FadeQIBTicker = nil
                            end
                        end)
                    else
                        for i=1, _QuestieTracker.highestIndex do
                            if _QuestieTracker.LineFrames[i].button then
                                _QuestieTracker.LineFrames[i].button:SetAlpha(1)
                            end
                        end
                    end
                    QuestieTracker:Update()
                end
            },
            enableBackground = {
                type = "toggle",
                order = 2.3,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_BACKGROUND'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_BACKGROUND_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerBackdropEnabled; end,
                set = function (info, value)
                    Questie.db.global.trackerBackdropEnabled = value
                    QuestieTracker:Update()
                end
            },
            enableBorder = {
                type = "toggle",
                order = 2.4,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_BORDER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_ENABLE_BORDER_DESC'); end,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerBorderEnabled; end,
                set = function (info, value)
                    Questie.db.global.trackerBorderEnabled = value
                    if value == true and not Questie.db.global.trackerBackdropFader then
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 1)
                    else
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
                    end
                    QuestieTracker:Update()
                end
            },
            fadeTrackerBackdrop = {
                type = "toggle",
                order = 2.5,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_FADE_BACKDROP'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FADE_BACKDROP_DESC'); end,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerBackdropFader; end,
                set = function (info, value)
                    Questie.db.global.trackerBackdropFader = value
                    if value == true then
                        QuestieTracker.FadeBGTickerValue = 1
                        QuestieTracker.FadeBGTicker = C_Timer.NewTicker(0.02, function()

                            if QuestieTracker.FadeBGTickerValue > 0 then
                                QuestieTracker.FadeBGTickerValue = QuestieTracker.FadeBGTickerValue - 0.02

                                if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                                    _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, QuestieTracker.FadeBGTickerValue*3.3))
                                    if Questie.db.global.trackerBorderEnabled then
                                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, QuestieTracker.FadeBGTickerValue*3.3))
                                    end
                                end

                            else
                                QuestieTracker.FadeBGTicker:Cancel()
                                QuestieTracker.FadeBGTicker = nil
                            end
                        end)
                    end
                    QuestieTracker:Update()
                end
            },

            Spacer_S = QuestieOptionsUtils:Spacer(2.6),

            colorObjectives = {
                type = "select",
                order = 2.7,
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
                end
            },
            sortObjectives = {
                type = "select",
                order = 2.8,
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
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                    for i = 1, _QuestieTracker.highestIndex do
                        if _QuestieTracker.LineFrames[i] then
                            _QuestieTracker.LineFrames[i].expandQuest:SetFrameStrata("MEDIUM")
                        end
                    end
                end
            },
            setTomTom = {
                type = "select",
                order = 2.9,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SET_TOMTOM_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindSetTomTom; end,
                set = function(input, key)
                    Questie.db.global.trackerbindSetTomTom = key
                end
            },
            openQuestLog = {
                type = "select",
                order = 3.0,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindOpenQuestLog; end,
                set = function(input, key)
                    Questie.db.global.trackerbindOpenQuestLog = key
                end
            },
            untrackQuest = {
                type = "select",
                order = 3.1,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_UNTRACK_LINK'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_UNTRACK_LINK_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindUntrack; end,
                set = function(input, key)
                    Questie.db.global.trackerbindUntrack = key
                end
            },
            trackerSetpoint = {
                type = "select",
                order = 3.2,
                values = function() return {
                    ["AUTO"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_AUTO'),
                    ["TOPLEFT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_TOPLEFT'),
                    ["TOPRIGHT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_TOPRIGHT'),
                    ["BOTTOMLEFT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_BOTTOMLEFT'),
                    ["BOTTOMRIGHT"] = QuestieLocale:GetUIString('TRACKER_SETPOINT_BOTTOMRIGHT'),
                } end,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_SETPOINT'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_SETPOINT_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db[Questie.db.global.questieTLoc].trackerSetpoint; end,
                set = function(input, key)
                    Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = key
                    QuestieTracker:ResetLocation()
                    QuestieTracker:MoveDurabilityFrame()
                end
            },

            Spacer_G = QuestieOptionsUtils:Spacer(3.3),

            fontSizeHeader = {
                type = "range",
                order = 3.4,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_HEADER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_HEADER_DESC'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled or not Questie.db.global.trackerHeaderEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeHeader; end,
                set = function (info, value)
                    Questie.db.global.trackerFontSizeHeader = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            fontHeader = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 3.45,
                values = AceGUIWidgetLSMlists.font,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_HEADER_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled or not Questie.db.global.trackerHeaderEnabled; end,
                get = function() return Questie.db.global.trackerFontHeader or "Friz Quadrata TT"; end,
                set = function(info, value)
                    Questie.db.global.trackerFontHeader = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },

            fontSizeZone = {
                type = "range",
                order = 3.5,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_ZONE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_ZONE_DESC'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,


                disabled = function() return not Questie.db.global.trackerEnabled or Questie.db.global.trackerSortObjectives ~= "byZone"; end,
                get = function() return Questie.db.global.trackerFontSizeZone; end,
                set = function (info, value)
                    Questie.db.global.trackerFontSizeZone = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            fontZone = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 3.55,
                values = AceGUIWidgetLSMlists.font,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_ZONE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_ZONE_DESC'); end,


                disabled = function() return not Questie.db.global.trackerEnabled or Questie.db.global.trackerSortObjectives ~= "byZone"; end,
                get = function() return Questie.db.global.trackerFontZone or "Friz Quadrata TT"; end,
                set = function(info, value)
                    Questie.db.global.trackerFontZone = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },

            fontSizeQuest = {
                type = "range",
                order = 3.6,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_QUESTS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_QUESTS_DESC'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeQuest; end,
                set = function (info, value)
                    Questie.db.global.trackerFontSizeQuest = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            fontQuest = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 3.65,
                values = AceGUIWidgetLSMlists.font,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_QUESTS'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_QUESTS_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontQuest or "Friz Quadrata TT"; end,
                set = function(info, value)
                    Questie.db.global.trackerFontQuest = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },

            fontSizeObjective = {
                type = "range",
                order = 3.7,
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_OBJECTIVE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_SIZE_OBJECTIVE_DESC'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeObjective; end,
                set = function (info, value)
                    Questie.db.global.trackerFontSizeObjective = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            fontObjective = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 3.75,
                values = AceGUIWidgetLSMlists.font,
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('TRACKER_FONT_OBJECTIVE'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_FONT_OBJECTIVE_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontObjective or "Friz Quadrata TT"; end,
                set = function(info, value)
                    Questie.db.global.trackerFontObjective = value
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },

            questPadding = {
                type = "range",
                order = 3.8,
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
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end
            },
            questBackdropAlpha = {
                type = "range",
                order = 3.9,
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
                end
            },

            Spacer_B = QuestieOptionsUtils:Spacer(4.0),

            enableQuestieTracker = {
                type = "execute",
                order = 4.1,
                width = 1.0,
                name = function() local buttonName if Questie.db.global.trackerEnabled then buttonName = QuestieLocale:GetUIString('TRACKER_DISABLED') elseif not Questie.db.global.trackerEnabled then buttonName = QuestieLocale:GetUIString('TRACKER_ENABLED') end return buttonName; end,
                desc = function() local buttonName if Questie.db.global.trackerEnabled then buttonName = QuestieLocale:GetUIString('TRACKER_DISABLED_DESC') elseif not Questie.db.global.trackerEnabled then buttonName = QuestieLocale:GetUIString('TRACKER_ENABLED_DESC') end return buttonName; end,
                disabled = function() return false; end,
                func = function ()
                    if Questie.db.global.trackerEnabled then
                        QuestieTracker:Disable()
                        Questie.db.global.trackerEnabled = false
                    else
                        QuestieTracker:Enable()
                        Questie.db.global.trackerEnabled = true
                    end

                end
            },

            Space_X = QuestieOptionsUtils:HorizontalSpacer(4.2, 0.1),

            resetTrackerLocation = {
                type = "execute",
                order = 4.3,
                width = 1.0,
                name = function() return QuestieLocale:GetUIString('TRACKER_RESET_LOCATION'); end,
                desc = function() return QuestieLocale:GetUIString('TRACKER_RESET_LOCATION_DESC'); end,
                disabled = function() return not Questie.db.global.trackerEnabled or InCombatLockdown(); end,
                func = function (info, value)
                    QuestieTracker:ResetLocation()
                end
            },

            Space_Y = QuestieOptionsUtils:HorizontalSpacer(4.4, 0.1),

            globalTrackerLocation = {
                type = "execute",
                order = 4.5,
                width = 1.0,
                name = function() local buttonName if Questie.db.global.globalTrackerLocation then buttonName = QuestieLocale:GetUIString('TRACKER_ENABLE_CHAR_TRACKERLOCATION') elseif not Questie.db.global.globalTrackerLocation then buttonName = QuestieLocale:GetUIString('TRACKER_ENABLE_GLOBAL_TRACKERLOCATION') end return buttonName; end,
                desc = function() local buttonName if Questie.db.global.globalTrackerLocation then buttonName = QuestieLocale:GetUIString('TRACKER_ENABLE_CHAR_TRACKERLOCATION_DESC') elseif not Questie.db.global.globalTrackerLocation then buttonName = QuestieLocale:GetUIString('TRACKER_ENABLE_GLOBAL_TRACKERLOCATION_DESC') end return buttonName; end,
                disabled = function() return not Questie.db.global.trackerEnabled or InCombatLockdown(); end,
                func = function (info, value)
                    if Questie.db.global.globalTrackerLocation then
                        Questie.db.global.questieTLoc = "global"
                        Questie.db.global.globalTrackerLocation = false
                    else
                        Questie.db.global.questieTLoc = "char"
                        Questie.db.global.globalTrackerLocation = true
                    end
                    QuestieTracker:ResetLocation()
                end
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
