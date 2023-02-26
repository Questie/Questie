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
---@type LinePool
local LinePool = QuestieLoader:ImportModule("LinePool")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.tracker = { ... }

local _GetShortcuts

local SharedMedia = LibStub("LibSharedMedia-3.0")

function QuestieOptions.tabs.tracker:Initialize()
    local fontTable = SharedMedia:HashTable("font")
    local outlineTable = {}
    outlineTable["None"] = "NONE"
    outlineTable["Outline"] = "OUTLINE"
    outlineTable["Monochrome"] = "MONOCHROME"
    return {
        name = function() return l10n('Tracker'); end,
        type = "group",
        order = 13,
        args = {
            header = {
                type = "header",
                order = 1,
                name = function() return l10n('Questie Tracker Options'); end,
            },
            autoTrackQuests = {
                type = "toggle",
                order = 1.1,
                width = 1.5,
                name = function() return l10n('Auto Track Quests'); end,
                desc = function() return l10n("This is the same as 'Enable automatic quest tracking' in interface options. When enabled, the Questie Tracker will automatically track all quests in your log. Disabling this option will untrack all quests. You will have to manually select which quests to track.\n\nNOTE: 'Show Complete Quests' is disabled while this option is not being used."); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.autoTrackQuests; end,
                set = function(_, value)
                    Questie.db.global.autoTrackQuests = value
                    if value then
                        Questie.db.char.TrackedQuests = {}
                    else
                        Questie.db.char.AutoUntrackedQuests = {}
                    end
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            showCompleteQuests = {
                type = "toggle",
                order = 1.2,
                width = 1.5,
                name = function() return l10n('Show Complete Quests'); end,
                desc = function() return l10n("When this is checked, completed quests will show in the Questie Tracker.\n\nNOTE: This setting is only works when 'Auto Track Quests' is enabled."); end,
                disabled = function() return (not Questie.db.global.trackerEnabled) or (not Questie.db.global.autoTrackQuests); end,
                get = function() return Questie.db.global.trackerShowCompleteQuests; end,
                set = function(_, value)
                    Questie.db.global.trackerShowCompleteQuests = value
                    QuestieTracker:Update()
                end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.3,
                width = 1.5,
                name = function() return l10n('Show Quest Level'); end,
                desc = function() return l10n('When this is checked, the Quest Level Tags for Quest Titles will show in the Questie Tracker.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerShowQuestLevel; end,
                set = function(_, value)
                    Questie.db.global.trackerShowQuestLevel = value
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            collapseCompletedQuests = {
                type = "toggle",
                order = 1.4,
                width = 1.5,
                name = function() return l10n('Auto Minimize Completed Quests'); end,
                desc = function() return l10n('When this is checked, completed quests will automatically minimize.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.collapseCompletedQuests; end,
                set = function(_, value)
                    Questie.db.global.collapseCompletedQuests = value
                    if Questie.db.global.collapseCompletedQuests == false then
                        Questie.db.char.collapsedQuests = {}
                    end
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            hideCompletedQuestObjectives = {
                type = "toggle",
                order = 1.5,
                width = 1.5,
                name = function() return l10n('Hide Completed Quest Objectives'); end,
                desc = function() return l10n('When this is checked, completed quest/achievement objectives will automatically be removed from the tracker.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hideCompletedQuestObjectives; end,
                set = function(_, value)
                    Questie.db.global.hideCompletedQuestObjectives = value
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            hideCompletedAchieveObjectives = {
                type = "toggle",
                order = 1.6,
                width = 1.5,
                name = function() return l10n('Hide Completed Achieve Objectives'); end,
                desc = function() return l10n('When this is checked, completed quest/achievement objectives will automatically be removed from the tracker.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hideCompletedAchieveObjectives; end,
                set = function(_, value)
                    Questie.db.global.hideCompletedAchieveObjectives = value
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            showQuestTimer = {
                type = "toggle",
                order = 1.7,
                width = 1.5,
                name = function() return l10n('Show Blizzard Timer'); end,
                desc = function() return l10n('When this is checked, the default Blizzard Timer Frame for quests will be shown instead of being embedded inside the tracker.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return (
                        Questie.db.global.showBlizzardQuestTimer or (not Questie.db.global.trackerEnabled));
                end,
                set = function(_, value)
                    Questie.db.global.showBlizzardQuestTimer = value
                    QuestieTracker:Update()
                end
            },
            enableTrackerHooks = {
                type = "toggle",
                order = 1.8,
                width = 1.5,
                name = function() return l10n('Enable Tracker Hooks'); end,
                desc = function() return l10n('Enable hooking the Blizzard quest tracker. This is required for some features of the Questie tracker, and to integrate with other addons. If you are having issues with quest tracking you may need to disable this (requires /reload).'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hookTracking; end,
                set = function(_, value)
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
                order = 1.9,
                width = 1.5,
                name = function() return l10n('Enable Active Quests Header'); end,
                desc = function() return l10n('When this is checked, the Active Quests Header will become visible and the total number of quests you have in your log will be shown.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerHeaderEnabled; end,
                set = function(_, value)
                    Questie.db.global.trackerHeaderEnabled = value
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            autoMoveHeader = {
                type = "toggle",
                order = 2.0,
                width = 1.5,
                name = function() return l10n('Auto Move Active Quests Header'); end,
                desc = function() return l10n("When this is checked, the Active Quests Header will automatically move to the top or bottom of the Questie Tracker depending on which 'Tracker Grows' setting is used.\n\nNOTE: This setting only works while the 'Tracker Grows' setting is set to 'Up & Right' or 'Up & Left'."); end,
                disabled = function() return (not Questie.db.global.trackerEnabled) or
                    (not Questie.db.global.trackerHeaderEnabled) or
                    Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "TOPLEFT" or
                    Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "TOPRIGHT";
                end,
                get = function() return Questie.db.global.autoMoveHeader; end,
                set = function(_, value)
                    Questie.db.global.autoMoveHeader = value
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            stickyDurabilityFrame = {
                type = "toggle",
                order = 2.1,
                width = 1.5,
                name = function() return l10n('Sticky Durability Frame'); end,
                desc = function() return l10n('When this is checked, the durability frame will be placed on the left or right side of the Tracker depending on where the Tracker is placed on your screen.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return (Questie.db.global.stickyDurabilityFrame and Questie.db.global.trackerEnabled); end,
                set = function(_, value)
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
                order = 2.2,
                width = 1.5,
                name = function() return l10n('Minimize In Combat'); end,
                desc = function() return l10n('When this is checked, the Tracker will automatically be minimized while entering combat.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hideTrackerInCombat; end,
                set = function(_, value)
                    Questie.db.global.hideTrackerInCombat = value
                end
            },
            minimizeInDungeons = {
                type = "toggle",
                order = 2.3,
                width = 1.5,
                name = function() return l10n('Minimize In Dungeons'); end,
                desc = function() return l10n('When this is checked, the Tracker will automatically be minimized when entering a dungeon.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.hideTrackerInDungeons; end,
                set = function(_, value)
                    Questie.db.global.hideTrackerInDungeons = value
                    if value and IsInInstance() then
                        QuestieTracker:Collapse()
                    else
                        QuestieTracker:Expand()
                    end
                end
            },
            fadeMinMaxButtons = {
                type = "toggle",
                order = 2.4,
                width = 1.5,
                name = function() return l10n('Fade Min/Max Buttons'); end,
                desc = function() return l10n('When this is checked, the Minimize and Maximize Buttons will fade and become transparent when not in use.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFadeMinMaxButtons; end,
                set = function(_, value)
                    Questie.db.global.trackerFadeMinMaxButtons = value
                    if value == true then
                        QuestieTracker.FadeMMBTickerValue = 1
                        QuestieTracker.FadeMMBTicker = C_Timer.NewTicker(0.02, function()

                            if QuestieTracker.FadeMMBTickerValue > 1 then
                                QuestieTracker.FadeMMBTickerValue = QuestieTracker.FadeMMBTickerValue - 0.02
                                if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                                    LinePool.SetAllExpandQuestAlpha(QuestieTracker.FadeMMBTickerValue * 3.3)
                                end

                            else
                                QuestieTracker.FadeMMBTicker:Cancel()
                                QuestieTracker.FadeMMBTicker = nil
                            end
                        end)
                    else
                        LinePool.SetAllExpandQuestAlpha(1)
                    end
                    QuestieTracker:Update()
                end
            },
            fadeQuestItemButtons = {
                type = "toggle",
                order = 2.5,
                width = 1.5,
                name = function() return l10n('Fade Quest Item Buttons'); end,
                desc = function() return l10n('When this is checked, the Quest Item Buttons will fade and become transparent when not in use.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFadeQuestItemButtons; end,
                set = function(_, value)
                    Questie.db.global.trackerFadeQuestItemButtons = value
                    if value == true then
                        QuestieTracker.FadeQIBTickerValue = 1
                        QuestieTracker.FadeQIBTicker = C_Timer.NewTicker(0.02, function()

                            if QuestieTracker.FadeQIBTickerValue > 1 then
                                QuestieTracker.FadeQIBTickerValue = QuestieTracker.FadeQIBTickerValue - 0.02

                                if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                                    LinePool.SetAllItemButtonAlpha(QuestieTracker.FadeQIBTickerValue * 3.3)
                                end

                            else
                                QuestieTracker.FadeQIBTicker:Cancel()
                                QuestieTracker.FadeQIBTicker = nil
                            end
                        end)
                    else
                        LinePool.SetAllItemButtonAlpha(1)
                    end
                    QuestieTracker:Update()
                end
            },
            enableBackground = {
                type = "toggle",
                order = 2.6,
                width = 1.5,
                name = function() return l10n('Enable Background'); end,
                desc = function() return l10n('When this is checked, the Questie Tracker Background becomes visible.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerBackdropEnabled; end,
                set = function(_, value)
                    Questie.db.global.trackerBackdropEnabled = value
                    QuestieTracker:Update()
                end
            },
            enableBorder = {
                type = "toggle",
                order = 2.7,
                width = 1.5,
                name = function() return l10n('Enable Border'); end,
                desc = function() return l10n('When this is checked, the Questie Tracker Border becomes visible.'); end,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or
                        not Questie.db.global.trackerEnabled;
                end,
                get = function() return Questie.db.global.trackerBorderEnabled; end,
                set = function(_, value)
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
                order = 2.8,
                width = 1.5,
                name = function() return l10n('Fade Background'); end,
                desc = function() return l10n('When this is checked, the Questie Tracker Backdrop and Border (if enabled) will fade and become transparent when not in use.'); end,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or
                        not Questie.db.global.trackerEnabled;
                end,
                get = function() return Questie.db.global.trackerBackdropFader; end,
                set = function(_, value)
                    Questie.db.global.trackerBackdropFader = value
                    if value == true then
                        QuestieTracker.FadeBGTickerValue = 1
                        QuestieTracker.FadeBGTicker = C_Timer.NewTicker(0.02, function()

                            if QuestieTracker.FadeBGTickerValue > 1 then
                                QuestieTracker.FadeBGTickerValue = QuestieTracker.FadeBGTickerValue - 0.02

                                if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and
                                    Questie.db.global.trackerBackdropFader then
                                    _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0,
                                        math.min(Questie.db.global.trackerBackdropAlpha,
                                            QuestieTracker.FadeBGTickerValue * 3.3))
                                    if Questie.db.global.trackerBorderEnabled then
                                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1,
                                            math.min(Questie.db.global.trackerBackdropAlpha,
                                                QuestieTracker.FadeBGTickerValue * 3.3))
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
            hideSizer = {
                type = "toggle",
                order = 2.9,
                width = 1.5,
                name = function() return l10n("Hide Tracker Sizer"); end,
                desc = function() return l10n("When this is the checked, the Questie Tracker Sizer that appears in the bottom right hand corner will be hidden."); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.sizerHidden; end,
                set = function(_, value)
                    Questie.db.global.sizerHidden = value
                    QuestieTracker:Update()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },
            lockTracker = {
                type = "toggle",
                order = 3.0,
                width = 1.5,
                name = function() return l10n("Lock Tracker"); end,
                desc = function() return l10n("When this is the checked, the Tracker is locked and you need to hold CTRL when you want to move it."); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerLocked; end,
                set = function(_, value)
                    Questie.db.global.trackerLocked = value
                    TrackerBaseFrame.Update()
                end
            },

            Spacer_B = QuestieOptionsUtils:Spacer(3.1),

            enableQuestieTracker = {
                type = "execute",
                order = 3.2,
                width = 1.0,
                name = function()
                    local buttonName
                    if Questie.db.global.trackerEnabled then
                        buttonName = l10n('Disable The Tracker')
                    elseif (not Questie.db.global.trackerEnabled) then
                        buttonName = l10n('Enable The Tracker')
                    end
                    return buttonName
                end,
                desc = function()
                    local description
                    if Questie.db.global.trackerEnabled then
                        description = l10n('Disabling the Tracker will replace the Questie Tracker with the default Blizzard Quest Tracker.')
                    elseif (not Questie.db.global.trackerEnabled) then
                        description = l10n('Enabling the Tracker will replace the default Blizzard Quest Tracker with the Questie Tracker.')
                    end
                    return description
                end,
                func = function()
                    if Questie.db.global.trackerEnabled then
                        QuestieTracker:Disable()
                        Questie.db.global.trackerEnabled = false
                    else
                        QuestieTracker:Enable()
                        Questie.db.global.trackerEnabled = true
                    end
                end
            },

            Space_X = QuestieOptionsUtils:HorizontalSpacer(3.3, 0.1),

            resetTrackerLocation = {
                type = "execute",
                order = 3.4,
                width = 1.0,
                name = function() return l10n('Reset Tracker Position'); end,
                desc = function() return l10n("If the Questie tracker is stuck offscreen or lost, you can reset it's location to the center of the screen with this button (may require /reload)."); end,
                disabled = function() return not Questie.db.global.trackerEnabled or InCombatLockdown(); end,
                func = function()
                    QuestieTracker:ResetLocation()
                    QuestieTracker:Update()
                end
            },

            Space_Y = QuestieOptionsUtils:HorizontalSpacer(3.5, 0.1),

            globalTrackerLocation = {
                type = "execute",
                order = 3.6,
                width = 1.0,
                name = function() local buttonName
                    if Questie.db.global.globalTrackerLocation then buttonName = l10n('Save Tracker Per Char') elseif not
                        Questie.db.global.globalTrackerLocation then buttonName = l10n('Save Tracker Global') end
                    return buttonName;
                end,
                desc = function() local buttonName
                    if Questie.db.global.globalTrackerLocation then buttonName = l10n("You are currently saving the Questie Tracker Location and Size Per Character. This allows you to cusomize each character's tracker location.\n\nNOTE: Upon enabling Per Character, the Tracker will be reset to the center of your screen. Move the Tracker to your desired location and set the size. When you are ready, type '/reload' to finalize your settings.") elseif not
                        Questie.db.global.globalTrackerLocation then buttonName = l10n("You are currently saving the  Questie Tracker Location and Size Globally. This allows you to have one setting for all characters.\n\nNOTE: Upon enabling Global, the Tracker will be reset to the center of your screen. Move the Tracker to your desired location and set the size. When you are ready, type '/reload' to finalize your settings.") end
                    return buttonName;
                end,
                disabled = function() return not Questie.db.global.trackerEnabled or InCombatLockdown(); end,
                func = function()
                    if Questie.db.global.globalTrackerLocation then
                        Questie.db.global.questieTLoc = "global"
                        Questie.db.global.globalTrackerLocation = false
                    else
                        Questie.db.global.questieTLoc = "char"
                        Questie.db.global.globalTrackerLocation = true
                    end
                    QuestieTracker:ResetLocation()
                end
            },

            Spacer_S = QuestieOptionsUtils:Spacer(3.7),

            colorObjectives = {
                type = "select",
                order = 3.8,
                values = function() return {
                        ['white'] = l10n('White'),
                        ['whiteToGreen'] = l10n('White to Green'),
                        ['whiteAndGreen'] = l10n('White and Green'),
                        ['redToGreen'] = l10n('Red to Green')
                    }
                end,
                style = 'dropdown',
                name = function() return l10n('Objective Color'); end,
                desc = function() return l10n('Change the color of objectives in the tracker by how complete they are.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerColorObjectives; end,
                set = function(_, key)
                    Questie.db.global.trackerColorObjectives = key
                    QuestieTracker:Update()
                end
            },
            sortObjectives = {
                type = "select",
                order = 3.9,
                values = function() return {
                        ['byComplete'] = l10n('By %% Completed'),
                        ['byLevel'] = l10n('By Level'),
                        ['byLevelReversed'] = l10n('By Level (Reversed)'),
                        ['byProximity'] = l10n('By Proximity'),
                        ['byZone'] = l10n('By Zone'),
                        ['none'] = l10n("Don't Sort"),
                    }
                end,
                style = 'dropdown',
                name = function() return l10n('Objective Sorting'); end,
                desc = function() return l10n('How objectives are sorted in the tracker.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerSortObjectives; end,
                set = function(_, key)
                    Questie.db.global.trackerSortObjectives = key
                    QuestieTracker:Update()
                end
            },
            setTomTom = {
                type = "select",
                order = 4.0,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Set |cFF54e33bTomTom|r Target'); end,
                desc = function() return l10n('The tracker shortcut to open TomTom'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindSetTomTom; end,
                set = function(_, key)
                    Questie.db.global.trackerbindSetTomTom = key
                end
            },
            openQuestLog = {
                type = "select",
                order = 4.1,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Show in Quest Log'); end,
                desc = function() return l10n('The tracker shortcut to show the quest in the quest log.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindOpenQuestLog; end,
                set = function(_, key)
                    Questie.db.global.trackerbindOpenQuestLog = key
                end
            },
            untrackQuest = {
                type = "select",
                order = 4.2,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Untrack/Link Quest'); end,
                desc = function() return l10n('Removes a quest from the Tracker when the chat input box is not visible, otherwise this will link a quest to chat.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerbindUntrack; end,
                set = function(_, key)
                    Questie.db.global.trackerbindUntrack = key
                end
            },
            trackerSetpoint = {
                type = "select",
                order = 4.3,
                values = function() return {
                        ["TOPLEFT"] = l10n('Down & Right'),
                        ["BOTTOMLEFT"] = l10n('Up & Right'),
                        ["TOPRIGHT"] = l10n('Down & Left'),
                        ["BOTTOMRIGHT"] = l10n('Up & Left'),
                    }
                end,
                style = 'dropdown',
                name = function() return l10n('Tracker Grows'); end,
                desc = function() return l10n("This determines the direction in which the tracker grows when you add or remove quests. This will also move the Active Quests Header to either the top of the Questie Tracker (when using either the 'Down & Right' or the 'Down & Left' setting) or the bottom of the Questie Tracker (when using the either the 'Up & Right' or the 'Down & Right' setting). \n\nNOTE: You can override the Active Quests Header movement behavior by disabling the 'Auto Move Header' option in Questie Tracker Options to force the Active Quests Header to remain at the top of the Questie Tracker."); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db[Questie.db.global.questieTLoc].trackerSetpoint; end,
                set = function(_, key)
                    Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = key
                    QuestieTracker:ResetLocation()
                    QuestieTracker:MoveDurabilityFrame()
                    C_Timer.After(0.1, function()
                        QuestieTracker:Update()
                    end)
                end
            },

            Spacer_G = QuestieOptionsUtils:Spacer(4.4),

            fontSizeHeader = {
                type = "range",
                order = 4.5,
                name = function() return l10n('Font Size for Active Quests'); end,
                desc = function() return l10n('The font size Active Quests uses.'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled or
                        not Questie.db.global.trackerHeaderEnabled;
                end,
                get = function() return Questie.db.global.trackerFontSizeHeader; end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeHeader = value
                    QuestieTracker:Update()
                end
            },
            fontHeader = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 4.6,
                values = fontTable,
                style = 'dropdown',
                name = function() return l10n('Font for Active Quests'); end,
                desc = function() return l10n('The font Active Quests uses.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled or
                        not Questie.db.global.trackerHeaderEnabled;
                end,
                get = function() return Questie.db.global.trackerFontHeader or "Friz Quadrata TT"; end,
                set = function(_, value)
                    Questie.db.global.trackerFontHeader = value
                    QuestieTracker:Update()
                end
            },
            fontSizeZone = {
                type = "range",
                order = 4.7,
                name = function() return l10n('Font Size for Zone Names'); end,
                desc = function() return l10n('The font size used for zone names.'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled or
                        Questie.db.global.trackerSortObjectives ~= "byZone";
                end,
                get = function() return Questie.db.global.trackerFontSizeZone; end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeZone = value
                    QuestieTracker:Update()
                end
            },
            fontZone = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 4.8,
                values = fontTable,
                style = 'dropdown',
                name = function() return l10n('Font for Zone Names'); end,
                desc = function() return l10n('The font used for zone names.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled or
                        Questie.db.global.trackerSortObjectives ~= "byZone";
                end,
                get = function() return Questie.db.global.trackerFontZone or "Friz Quadrata TT"; end,
                set = function(_, value)
                    Questie.db.global.trackerFontZone = value
                    QuestieTracker:Update()
                end
            },
            fontSizeQuest = {
                type = "range",
                order = 4.9,
                name = function() return l10n('Font Size for Quest Titles'); end,
                desc = function() return l10n('The font size used for quest titles.'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeQuest; end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeQuest = value
                    QuestieTracker:Update()
                end
            },
            fontQuest = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 5.0,
                values = fontTable,
                style = 'dropdown',
                name = function() return l10n('Font for Quest Titles'); end,
                desc = function() return l10n('The font used for quest titles.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontQuest or "Friz Quadrata TT"; end,
                set = function(_, value)
                    Questie.db.global.trackerFontQuest = value
                    QuestieTracker:Update()
                end
            },
            fontSizeObjective = {
                type = "range",
                order = 5.1,
                name = function() return l10n('Font Size for Objectives'); end,
                desc = function() return l10n('The font size used for objectives.'); end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontSizeObjective; end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeObjective = value
                    QuestieTracker:Update()
                end
            },
            fontObjective = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 5.2,
                values = fontTable,
                style = 'dropdown',
                name = function() return l10n('Font for Objectives'); end,
                desc = function() return l10n('The font used for objectives.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontObjective or "Friz Quadrata TT"; end,
                set = function(_, value)
                    Questie.db.global.trackerFontObjective = value
                    QuestieTracker:Update()
                end
            },
            questPadding = {
                type = "range",
                order = 5.3,
                name = function() return l10n('Padding Between Quests'); end,
                desc = function() return l10n('The amount of padding between quests in the tracker.'); end,
                width = "double",
                min = 2,
                max = 16,
                step = 1,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerQuestPadding; end,
                set = function(_, value)
                    Questie.db.global.trackerQuestPadding = value
                    QuestieTracker:Update()
                end
            },
            fontOutline = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 5.4,
                values = outlineTable,
                style = 'dropdown',
                name = function() return l10n('Outline for Zones, Titles, and Objectives'); end,
                desc = function() return l10n('The outline used for Quest Zones, Titles, and Objectives in Tracker.'); end,
                disabled = function() return not Questie.db.global.trackerEnabled; end,
                get = function() return Questie.db.global.trackerFontOutline; end,
                set = function(_, value)
                    Questie.db.global.trackerFontOutline = value
                    QuestieTracker:Update()
                end
            },
            questBackdropAlpha = {
                type = "range",
                order = 5.5,
                name = function() return l10n('Tracker Backdrop Alpha'); end,
                desc = function() return l10n('The alpha level of the tracker backdrop'); end,
                width = "double",
                min = 0,
                max = 100,
                step = 5,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or
                        not Questie.db.global.trackerEnabled;
                end,
                get = function() return Questie.db.global.trackerBackdropAlpha * 100; end,
                set = function(_, value)
                    Questie.db.global.trackerBackdropAlpha = value / 100
                    QuestieTracker:Update()
                end
            },
        }
    }
end

_GetShortcuts = function()
    return {
        ['left'] = l10n('Left Click'),
        ['right'] = l10n('Right Click'),
        ['shiftleft'] = l10n('Shift') .. " + " .. l10n('Left Click'),
        ['shiftright'] = l10n('Shift') .. " + " .. l10n('Right Click'),
        ['ctrlleft'] = l10n('Control') .. " + " .. l10n('Left Click'),
        ['ctrlright'] = l10n('Control') .. " + " .. l10n('Right Click'),
        ['altleft'] = l10n('Alt') .. " + " .. l10n('Left Click'),
        ['altright'] = l10n('Alt') .. " + " .. l10n('Right Click'),
        ['disabled'] = l10n('Disabled'),
    }
end