-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.tracker = { ... }

local _GetShortcuts
local trackerOptions = {}

local SharedMedia = LibStub("LibSharedMedia-3.0")

function QuestieOptions.tabs.tracker:Initialize()
    trackerOptions = {
        name = function() return l10n('Tracker') end,
        type = "group",
        order = 3,
        args = {
            header = {
                type = "header",
                order = 1,
                name = function() return l10n('Tracker Options') end,
            },
            enableQuestieTracker = {
                type = "toggle",
                order = 2,
                width = 1.5,
                name = function() return l10n('Enable Tracker') end,
                desc = function() return l10n("Enabling the Tracker will replace the default Blizzard Quest Tracker with the Questie Tracker.\n\nNOTE: Changing this setting will reload the UI.") end,
                disabled = function() return InCombatLockdown() end,
                get = function() return Questie.db.profile.trackerEnabled end,
                set = function()
                    if Questie.db.profile.trackerEnabled then
                        QuestieTracker:Disable()
                    else
                        QuestieTracker:Enable()
                    end
                end
            },
            Space_X = QuestieOptionsUtils:HorizontalSpacer(3, 0.1),
            resetTrackerLocation = {
                type = "execute",
                order = 4,
                width = 0.8,
                name = function() return l10n('Reset Tracker') end,
                desc = function() return l10n("If the Questie Tracker is stuck offscreen or lost, you can reset it's location to the center of the screen with this button.") end,
                disabled = function() return not Questie.db.profile.trackerEnabled or InCombatLockdown() end,
                func = function()
                    QuestieTracker:ResetLocation()
                    QuestieTracker:Update()
                end
            },
            Spacer_S = QuestieOptionsUtils:Spacer(5),
            group_quests = {
                type = "group",
                order = 6,
                inline = true,
                width = 0.5,
                name = function()
                    if Questie.IsWotlk then
                        return l10n("Quest and Achievement Options")
                    else
                        return l10n('Quest Options')
                    end
                end,
                disabled = function() return not Questie.db.profile.trackerEnabled end,
                args = {
                    autoTrackQuests = {
                        type = "toggle",
                        order = 1,
                        width = 1.5,
                        name = function() return l10n('Auto Track Quests') end,
                        desc = function() return l10n("This is the same as 'Enable Automatic Quest Tracking' in the Blizzard Interface Options. When enabled, the Questie Tracker will automatically track all Quests in your Quest Log. Disabling this option will untrack all Quests. You will have to manually select which Quests to track.\n\nNOTE: 'Show Complete Quests' is disabled while this option is not being used.") end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.autoTrackQuests end,
                        set = function(_, value)
                            Questie.db.profile.autoTrackQuests = value
                            if value then
                                Questie.db.char.TrackedQuests = {}
                            else
                                Questie.db.char.AutoUntrackedQuests = {}
                            end

                            -- Update Quest Log and mark tracked Quests
                            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
                            if questLogFrame:IsShown() then
                                QuestLog_Update()
                            end

                            QuestieTracker:Update()
                        end
                    },
                    showQuestLevels = {
                        type = "toggle",
                        order = 2,
                        width = 1.5,
                        name = function() return l10n('Show Quest Level') end,
                        desc = function() return l10n('When this is checked, the Quest Level Tags for Quest Titles will show in the Questie Tracker.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerShowQuestLevel end,
                        set = function(_, value)
                            Questie.db.profile.trackerShowQuestLevel = value
                            QuestieTracker:Update()
                        end
                    },
                    showQuestTimer = {
                        type = "toggle",
                        order = 3,
                        width = 1.5,
                        name = function() return l10n('Show Blizzard Timer') end,
                        desc = function() return l10n('When this is checked, the default Blizzard Timer Frame for Quests will be shown instead of being embedded inside the Questie Tracker.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.showBlizzardQuestTimer end,
                        set = function(_, value)
                            Questie.db.profile.showBlizzardQuestTimer = value

                            if value == true then
                                TrackerQuestTimers:ShowBlizzardTimer()
                            else
                                TrackerQuestTimers:HideBlizzardTimer()
                            end

                            QuestieTracker:Update()
                        end
                    },
                    listAchievementsFirst = {
                        type = "toggle",
                        order = 4,
                        width = 1.5,
                        name = function() return l10n("List Achievements First") end,
                        desc = function() return l10n("When this is checked, the Questie Tracker will list Achievements first then Quests.") end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        hidden = function() return not Questie.IsWotlk end,
                        get = function() return Questie.db.profile.listAchievementsFirst end,
                        set = function(_, value)
                            Questie.db.profile.listAchievementsFirst = value
                            QuestieTracker:Update()
                        end
                    },
                    Spacer_Dropdowns = QuestieOptionsUtils:Spacer(5),
                    openQuestLog = {
                        type = "select",
                        order = 7,
                        values = _GetShortcuts(),
                        style = 'dropdown',
                        name = function()
                            if Questie.IsWotlk then
                                return l10n('Show Quest / Achievement')
                            else
                                return l10n('Show in Quest Log')
                            end
                        end,
                        desc = function()
                            if Questie.IsWotlk then
                                return l10n('This shortcut will open the Quest Log with the clicked Quest selected or open Achievements with the clicked Achievement selected.')
                            else
                                return l10n('This shortcut will open the Quest Log with the clicked Quest selected.')
                            end
                        end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerbindOpenQuestLog end,
                        set = function(_, key)
                            Questie.db.profile.trackerbindOpenQuestLog = key
                        end
                    },
                    Space_Y = QuestieOptionsUtils:HorizontalSpacer(7.1, 0.1),
                    untrackQuest = {
                        type = "select",
                        order = 8,
                        values = _GetShortcuts(),
                        style = 'dropdown',
                        name = function()
                            if Questie.IsWotlk then
                                return l10n('Untrack / Link')
                            else
                                return l10n('Untrack / Link Quest')
                            end
                        end,
                        desc = function()
                            if Questie.IsWotlk then
                                return l10n('This shortcut removes a Quest or an Achievement from the Questie Tracker when the chat input box is NOT visible, otherwise this will link a Quest or an Achievement to chat.')
                            else
                                return l10n('This shortcut removes a Quest from the Questie Tracker when the chat input box is NOT visible, otherwise this will link a Quest to chat.')
                            end
                        end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerbindUntrack end,
                        set = function(_, key)
                            Questie.db.profile.trackerbindUntrack = key
                        end
                    },
                    Spacer_Sliders = QuestieOptionsUtils:Spacer(9),
                    questPadding = {
                        type = "range",
                        order = 10,
                        name = function() return l10n('Padding Between Quests') end,
                        desc = function() return l10n('The amount of padding between Quests in the Questie Tracker.\n\nNOTE: Changing this setting while in Sizer Manual Mode will reset the Sizer back to Auto Mode') end,
                        width = 3,
                        min = 2,
                        max = 15,
                        step = 1,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerQuestPadding end,
                        set = function(_, value)
                            Questie.db.profile.trackerQuestPadding = value
                            local trackerHeightByManual = Questie.db.profile.TrackerHeight
                            if IsMouseButtonDown("LeftButton") and trackerHeightByManual == 0 then
                                QuestieTracker:Update()
                            elseif IsMouseButtonDown("LeftButton") and trackerHeightByManual > 0 then
                                Questie.db.profile.TrackerWidth = 0
                                Questie.db.profile.TrackerHeight = 0
                                QuestieTracker:Update()
                            end
                        end
                    },
                    group_tracker = {
                        type = "group",
                        order = 11,
                        inline = true,
                        width = 0.5,
                        name = function() return l10n('Objectives'); end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        args = {
                            showCompleteQuests = {
                                type = "toggle",
                                order = 1,
                                width = 1.5,
                                name = function() return l10n('Show Completed Quests') end,
                                desc = function() return l10n("When this is checked, completed Quests will show in the Questie Tracker.\n\nNOTE: This setting only works when 'Auto Track Quests' is enabled.") end,
                                disabled = function() return (not Questie.db.profile.trackerEnabled) or (not Questie.db.profile.autoTrackQuests) end,
                                get = function() return Questie.db.profile.trackerShowCompleteQuests end,
                                set = function(_, value)
                                    Questie.db.profile.trackerShowCompleteQuests = value
                                    QuestieTracker:Update()
                                end
                            },
                            collapseCompletedQuests = {
                                type = "toggle",
                                order = 2,
                                width = 1.5,
                                name = function() return l10n('Auto Minimize Completed Quests') end,
                                desc = function() return l10n('When this is checked, completed Quests will automatically minimize.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.collapseCompletedQuests end,
                                set = function(_, value)
                                    Questie.db.profile.collapseCompletedQuests = value
                                    if Questie.db.profile.collapseCompletedQuests == false then
                                        Questie.db.char.collapsedQuests = {}
                                    end
                                    QuestieTracker:Update()
                                end
                            },
                            hideCompletedQuestObjectives = {
                                type = "toggle",
                                order = 3,
                                width = 1.5,
                                name = function() return l10n('Hide Completed Quest Objectives') end,
                                desc = function() return l10n('When this is checked, completed Quest Objectives will automatically be removed from the Questie Tracker.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.hideCompletedQuestObjectives end,
                                set = function(_, value)
                                    Questie.db.profile.hideCompletedQuestObjectives = value
                                    QuestieTracker:Update()
                                end
                            },
                            hideCompletedAchieveObjectives = {
                                type = "toggle",
                                order = 4,
                                width = 1.5,
                                name = function() return l10n('Hide Completed Achieve Objectives') end,
                                desc = function() return l10n('When this is checked, completed Achievement Objectives will automatically be removed from the Questie Tracker.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                hidden = function() return not Questie.IsWotlk end,
                                get = function() return Questie.db.profile.hideCompletedAchieveObjectives end,
                                set = function(_, value)
                                    Questie.db.profile.hideCompletedAchieveObjectives = value
                                    QuestieTracker:Update()
                                end
                            },
                            Spacer_X = QuestieOptionsUtils:Spacer(5),
                            colorObjectives = {
                                type = "select",
                                order = 6,
                                values = function()
                                    return {
                                        ['white'] = l10n('White'),
                                        ['whiteToGreen'] = l10n('White to Green'),
                                        ['whiteAndGreen'] = l10n('White and Green'),
                                        ['redToGreen'] = l10n('Red to Green'),
                                        ['minimal'] = l10n('Minimalistic')
                                    }
                                end,
                                style = 'dropdown',
                                name = function() return l10n('Objective Color') end,
                                desc = function() return l10n('Change the color of Objectives in the Questie Tracker by how complete they are.\n\nNOTE: The Minimalistic option will not display the "Blizzard Completion Text" and just label the Quest as either "Quest Complete!" or "Quest Failed!".') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerColorObjectives end,
                                set = function(_, key)
                                    Questie.db.profile.trackerColorObjectives = key
                                    QuestieTracker:Update()
                                end
                            },
                            Space_Y = QuestieOptionsUtils:HorizontalSpacer(7, 0.1),
                            hideBlizzardCompletionText = {
                                type = "toggle",
                                order = 8,
                                width = 1.5,
                                name = function() return l10n('Hide Blizzard Completion Text') end,
                                desc = function() return l10n('When this is checked, Blizzard Completion Text will be hidden for completed Quests and instead show the old Questie tags: "Quest Complete!" or "Quest Failed!"') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled or Questie.db.profile.trackerColorObjectives == "minimal" end,
                                get = function() return Questie.db.profile.hideBlizzardCompletionText end,
                                set = function(_, value)
                                    Questie.db.profile.hideBlizzardCompletionText = value
                                    if Questie.db.profile.hideBlizzardCompletionText == false then
                                        Questie.db.char.collapsedQuests = {}
                                    end
                                    QuestieTracker:Update()
                                end
                            },
                            Spacer_Z = QuestieOptionsUtils:Spacer(9),
                            sortObjectives = {
                                type = "select",
                                order = 10,
                                values = function()
                                    return {
                                        ['byComplete'] = l10n('By %% Complete'),
                                        ['byCompleteReversed'] = l10n('By %% Complete (Reversed)'),
                                        ['byLevel'] = l10n('By Level'),
                                        ['byLevelReversed'] = l10n('By Level (Reversed)'),
                                        ['byProximity'] = l10n('By Proximity'),
                                        ['byProximityReversed'] = l10n('By Proximity (Reversed)'),
                                        ['byZone'] = l10n('By Zone'),
                                        ['byZonePlayerProximity'] = l10n('By Zone Prox'),
                                        ['byZonePlayerProximityReversed'] = l10n('By Zone Prox (Reversed)'),
                                    }
                                end,
                                style = 'dropdown',
                                name = function() return l10n('Objective Sorting') end,
                                desc = function() return l10n('How Objectives are sorted in the Questie Tracker.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerSortObjectives end,
                                set = function(_, key)
                                    Questie.db.profile.trackerSortObjectives = key
                                    QuestieTracker:Update()
                                end
                            },
                        },
                    },
                }
            },
            group_tracker = {
                type = "group",
                order = 7,
                inline = true,
                width = 0.5,
                name = function() return l10n('Tracker Window Options'); end,
                disabled = function() return not Questie.db.profile.trackerEnabled end,
                args = {
                    minimizeInCombat = {
                        type = "toggle",
                        order = 1,
                        width = 1.5,
                        name = function() return l10n('Minimize In Combat') end,
                        desc = function() return l10n('When this is checked, the Questie Tracker will automatically be minimized while entering combat.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.hideTrackerInCombat end,
                        set = function(_, value)
                            Questie.db.profile.hideTrackerInCombat = value
                        end
                    },
                    minimizeInDungeons = {
                        type = "toggle",
                        order = 2,
                        width = 1.5,
                        name = function() return l10n('Minimize In Dungeons') end,
                        desc = function() return l10n('When this is checked, the Questie Tracker will automatically be minimized when entering a dungeon.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.hideTrackerInDungeons end,
                        set = function(_, value)
                            Questie.db.profile.hideTrackerInDungeons = value
                            if value and IsInInstance() then
                                QuestieTracker:Collapse()
                            else
                                QuestieTracker:Expand()
                            end
                        end
                    },
                    fadeMinMaxButtons = {
                        type = "toggle",
                        order = 3,
                        width = 1.5,
                        name = function() return l10n('Fade Min/Max Buttons') end,
                        desc = function() return l10n('When this is checked, the Minimize and Maximize Buttons will fade and become transparent when not in use.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFadeMinMaxButtons end,
                        set = function(_, value)
                            Questie.db.profile.trackerFadeMinMaxButtons = value
                            if value == true then
                                local fadeTicker
                                local fadeTickerValue = 1
                                fadeTicker = C_Timer.NewTicker(0.02, function()
                                    if fadeTickerValue <= 1 then
                                        fadeTickerValue = fadeTickerValue - 0.05

                                        if fadeTickerValue < 0 then
                                            fadeTickerValue = 0
                                            fadeTicker:Cancel()
                                        end

                                        if (Questie.db.char.isTrackerExpanded) then
                                            TrackerLinePool.SetAllExpandQuestAlpha(fadeTickerValue)
                                        end
                                    else
                                        fadeTickerValue:Cancel()
                                        TrackerLinePool.SetAllExpandQuestAlpha(0)
                                    end
                                end)
                            else
                                TrackerLinePool.SetAllExpandQuestAlpha(1)
                            end
                            QuestieTracker:Update()
                        end
                    },
                    fadeQuestItemButtons = {
                        type = "toggle",
                        order = 4,
                        width = 1.5,
                        name = function() return l10n('Fade Quest Item Buttons') end,
                        desc = function() return l10n('When this is checked, the Quest Item Buttons will fade and become transparent when not in use.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFadeQuestItemButtons end,
                        set = function(_, value)
                            Questie.db.profile.trackerFadeQuestItemButtons = value
                            if value == true then
                                local fadeTicker
                                local fadeTickerValue = 1
                                fadeTicker = C_Timer.NewTicker(0.02, function()
                                    if fadeTickerValue <= 1 then
                                        fadeTickerValue = fadeTickerValue - 0.05

                                        if fadeTickerValue < 0 then
                                            fadeTickerValue = 0
                                            fadeTicker:Cancel()
                                        end

                                        if (Questie.db.char.isTrackerExpanded) then
                                            TrackerLinePool.SetAllItemButtonAlpha(fadeTickerValue)
                                        end
                                    else
                                        fadeTickerValue:Cancel()
                                        TrackerLinePool.SetAllItemButtonAlpha(0)
                                    end
                                end)
                            else
                                TrackerLinePool.SetAllItemButtonAlpha(1)
                            end
                            QuestieTracker:Update()
                        end
                    },
                    hideSizer = {
                        type = "toggle",
                        order = 5,
                        width = 1.5,
                        name = function() return l10n("Hide Tracker Sizer") end,
                        desc = function() return l10n("When this is checked, the Questie Tracker Sizer that appears in the bottom or top right hand corner will be hidden.") end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.sizerHidden end,
                        set = function(_, value)
                            Questie.db.profile.sizerHidden = value
                            QuestieTracker:UpdateFormatting()
                        end
                    },
                    lockTracker = {
                        type = "toggle",
                        order = 6,
                        width = 1.5,
                        name = function() return l10n("Lock Tracker") end,
                        desc = function() return l10n("When this is checked, the Questie Tracker is locked and you need to hold CTRL when you want to move it.") end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerLocked end,
                        set = function(_, value)
                            Questie.db.profile.trackerLocked = value
                            TrackerBaseFrame:Update()
                        end
                    },
                    stickyDurabilityFrame = {
                        type = "toggle",
                        order = 7,
                        width = 1.5,
                        name = function() return l10n('Sticky Durability Frame') end,
                        desc = function() return l10n('When this is checked, the durability frame will be placed on the left or right side of the Questie Tracker depending on where the Tracker is placed on your screen.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.stickyDurabilityFrame end,
                        set = function(_, value)
                            Questie.db.profile.stickyDurabilityFrame = value
                            if value == false then
                                QuestieTracker:ResetDurabilityFrame()
                            end
                            QuestieTracker:Update()
                        end
                    },
                    stickyVoiceOverFrame = {
                        type = "toggle",
                        order = 8,
                        width = 1.5,
                        name = function() return l10n("Sticky VoiceOver Frame") end,
                        desc = function() return l10n("When this is checked, the VoiceOver talking head / sound queue frame will be placed on the left or right side of the Questie Tracker depending on where the Tracker is placed on your screen.") end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        hidden = function() return not (IsAddOnLoaded("AI_VoiceOver") and IsAddOnLoaded("AI_VoiceOverData_Vanilla")) end,
                        get = function() return Questie.db.profile.stickyVoiceOverFrame end,
                        set = function(_, value)
                            Questie.db.profile.stickyVoiceOverFrame = value
                            if value == false then
                                QuestieTracker:ResetVoiceOverFrame()
                            end
                            QuestieTracker:Update()
                        end
                    },
                    Spacer_Dropdowns = QuestieOptionsUtils:Spacer(9),
                    setTomTom = {
                        type = "select",
                        order = 10,
                        values = _GetShortcuts(),
                        style = 'dropdown',
                        name = function() return l10n('Set |cFF54e33bTomTom|r Target') end,
                        desc = function()
                            if Questie.IsWotlk then
                                return l10n('This shortcut will set the TomTom arrow to point to either an NPC or the first incomplete Quest Objective (if location data is available).\n\nNOTE: This will not work with Achievements.')
                            else
                                return l10n('This shortcut will set the TomTom arrow to point to either an NPC or the first incomplete Quest Objective (if location data is available).')
                            end
                        end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        hidden = function() return not IsAddOnLoaded("TomTom") end,
                        get = function() return Questie.db.profile.trackerbindSetTomTom end,
                        set = function(_, key)
                            Questie.db.profile.trackerbindSetTomTom = key
                        end
                    },
                    trackerSetpoint = {
                        type = "select",
                        order = 11,
                        values = function()
                            return {
                                ["TOPLEFT"] = l10n('Down & Right'),
                                ["BOTTOMLEFT"] = l10n('Up & Right'),
                                ["TOPRIGHT"] = l10n('Down & Left'),
                                ["BOTTOMRIGHT"] = l10n('Up & Left'),
                            }
                        end,
                        style = 'dropdown',
                        name = function() return l10n('Tracker Growth Direction') end,
                        desc = function()
                            return l10n("This determines the direction in which the Questie Tracker grows when you add or remove Quests. For example, if you use the 'Up & Right' option then the ideal place for the Tracker should be in the lower left-hand corner of your screen. This allows the 'Sizer Mode: Auto' to push the Tracker Height and Width 'Up & Right' so the Tracker doesn't inadvertently cover up elements of your UI.")
                        end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerSetpoint end,
                        set = function(_, key)
                            Questie.db.profile.trackerSetpoint = key
                            QuestieTracker:ResetLocation()
                            QuestieTracker:Update()
                        end
                    },
                    Spacer_Sliders = QuestieOptionsUtils:Spacer(12),
                    trackerHeightRatio = {
                        type = "range",
                        order = 13,
                        name = function() return l10n('Tracker Height Ratio') end,
                        desc = function() return l10n('The height of the Questie Tracker based on percentage of usable screen height. A setting of 100 percent would make the Tracker fill the players entire screen height.\n\nNOTE: This setting only applies while in Sizer Mode: Auto') end,
                        width = 3,
                        min = 20,
                        max = 100,
                        step = 1,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerHeightRatio * 100 end,
                        set = function(_, value)
                            Questie.db.profile.trackerHeightRatio = value / 100
                            if IsMouseButtonDown("LeftButton") and Questie.db.profile.TrackerHeight == 0 then
                                TrackerBaseFrame.isSizing = true
                                Questie.db.profile.trackerBackdropEnabled = true
                                Questie.db.profile.trackerBorderEnabled = true
                                Questie.db.profile.trackerBackdropFader = false
                                QuestieTracker:UpdateFormatting()
                            else
                                TrackerBaseFrame.isSizing = false
                                Questie.db.profile.trackerBackdropEnabled = Questie.db.profile.currentBackdropEnabled
                                Questie.db.profile.trackerBorderEnabled = Questie.db.profile.currentBorderEnabled
                                Questie.db.profile.trackerBackdropFader = Questie.db.profile.currentBackdropFader
                                QuestieTracker:UpdateFormatting()
                            end
                        end
                    },
                    group_header = {
                        type = "group",
                        order = 14,
                        inline = true,
                        width = 0.5,
                        name = function() return l10n('Tracker Header') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        args = {
                            enableHeader = {
                                type = "toggle",
                                order = 1,
                                width = 1.5,
                                name = function() return l10n("Enable Tracker Header") end,
                                desc = function() return l10n("When this is enabled the Tracker Header with the number of active quests and the Questie Icon will be permanently visible.\n\nWhen this is disabled the Questie Icon will fade in while your mouse is over the Tracker.") end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerHeaderEnabled end,
                                set = function(_, value)
                                    Questie.db.profile.trackerHeaderEnabled = value
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                            moveHeaderToBottom = {
                                type = "toggle",
                                order = 2,
                                width = 1.5,
                                name = function() return l10n("Show Tracker Header At The Bottom") end,
                                desc = function() return l10n("When this is enabled the Tracker Header and/or the Questie Icon will be moved to the bottom of the Questie Tracker and the sizer to the top.") end,
                                disabled = function() return (not Questie.db.profile.trackerEnabled) end,
                                get = function() return Questie.db.profile.moveHeaderToBottom end,
                                set = function(_, value)
                                    Questie.db.profile.moveHeaderToBottom = value
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                            alwaysShowTracker = {
                                type = "toggle",
                                order = 3,
                                width = 1.5,
                                name = function() return l10n("Show Header For Empty Tracker") end,
                                desc = function() return l10n("When this is enabled the Tracker Header will be visible even when no quests are being tracked versus the Tracker being hidden completely.") end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.alwaysShowTracker end,
                                set = function(_, value)
                                    Questie.db.profile.alwaysShowTracker = value
                                    if (Questie.db.profile.alwaysShowTracker == true) and (Questie.db.char.isTrackerExpanded == false) then
                                        Questie.db.char.isTrackerExpanded = true
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                        },
                    },
                    group_background = {
                        type = "group",
                        order = 15,
                        inline = true,
                        width = 0.5,
                        name = function() return l10n('Tracker Background') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        args = {
                            enableBackground = {
                                type = "toggle",
                                order = 1,
                                width = 1.5,
                                name = function() return l10n('Enable Background') end,
                                desc = function() return l10n('When this is checked, the Questie Tracker Background becomes visible.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerBackdropEnabled end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBackdropEnabled = value
                                    Questie.db.profile.currentBackdropEnabled = value

                                    if value == true and not Questie.db.profile.trackerBackdropFader then
                                        TrackerBaseFrame.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.profile.trackerBackdropAlpha)
                                    else
                                        TrackerBaseFrame.baseFrame:SetBackdropColor(0, 0, 0, 0)
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                            enableBorder = {
                                type = "toggle",
                                order = 2,
                                width = 1.5,
                                name = function() return l10n('Enable Border') end,
                                desc = function() return l10n('When this is checked, the Questie Tracker Border becomes visible.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled or not Questie.db.profile.trackerBackdropEnabled end,
                                get = function() return Questie.db.profile.trackerBorderEnabled end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBorderEnabled = value
                                    Questie.db.profile.currentBorderEnabled = value

                                    if value == true and not Questie.db.profile.trackerBackdropFader then
                                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.profile.trackerBackdropAlpha)
                                    else
                                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                            fadeTrackerBackdrop = {
                                type = "toggle",
                                order = 3,
                                width = 1.5,
                                name = function() return l10n('Fade Background') end,
                                desc = function() return l10n('When this is checked, the Questie Tracker Backdrop and Border (if enabled) will fade and become transparent when not in use.') end,
                                disabled = function() return not Questie.db.profile.trackerEnabled or not Questie.db.profile.trackerBackdropEnabled end,
                                get = function() return Questie.db.profile.trackerBackdropFader end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBackdropFader = value
                                    Questie.db.profile.currentBackdropFader = value

                                    if value == true then
                                        local fadeTicker
                                        local fadeTickerValue = 1
                                        fadeTicker = C_Timer.NewTicker(0.02, function()
                                            if fadeTickerValue <= 1 then
                                                fadeTickerValue = fadeTickerValue - 0.05

                                                if fadeTickerValue < 0 then
                                                    fadeTickerValue = 0
                                                    fadeTicker:Cancel()
                                                end

                                                if Questie.db.char.isTrackerExpanded then
                                                    TrackerBaseFrame.baseFrame:SetBackdropColor(0, 0, 0, fadeTickerValue)

                                                    if Questie.db.profile.trackerBorderEnabled then
                                                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, fadeTickerValue)
                                                    end
                                                end
                                            else
                                                fadeTickerValue:Cancel()
                                            end
                                        end)
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                            questBackdropAlpha = {
                                type = "range",
                                order = 4,
                                name = function() return l10n('Tracker Backdrop Alpha') end,
                                desc = function() return l10n('The alpha level of the Questie Trackers backdrop. A setting of 100 percent is fully visible.') end,
                                width = 3,
                                min = 0,
                                max = 100,
                                step = 5,
                                disabled = function() return not Questie.db.profile.trackerBackdropEnabled or not Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerBackdropAlpha * 100 end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBackdropAlpha = value / 100
                                    QuestieTracker:UpdateFormatting()
                                end
                            },
                        },
                    },
                }
            },
            group_fonts = {
                type = "group",
                order = 8,
                inline = true,
                width = 0.5,
                name = function() return l10n('Font Options'); end,
                disabled = function() return not Questie.db.profile.trackerEnabled end,
                args = {
                    fontSizeHeader = {
                        type = "range",
                        order = 1,
                        name = function() return l10n("Font Size for Active Quests Header") end,
                        desc = function() return l10n("The font size used for the Active Quests Header.") end,
                        width = "double",
                        min = 8,
                        max = 26,
                        step = 1,
                        disabled = function() return not Questie.db.profile.trackerEnabled or not Questie.db.profile.trackerHeaderEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeHeader end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeHeader = value
                            QuestieTracker:Update()
                        end
                    },
                    fontHeader = {
                        type = "select",
                        dialogControl = 'LSM30_Font',
                        order = 2,
                        values = SharedMedia:HashTable("font"),
                        style = 'dropdown',
                        name = function() return l10n("Font for Active Quests Header") end,
                        desc = function() return l10n("The font used for the Active Quests Header.") end,
                        disabled = function() return not Questie.db.profile.trackerEnabled or not Questie.db.profile.trackerHeaderEnabled end,
                        get = function() return Questie.db.profile.trackerFontHeader or "Friz Quadrata TT" end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontHeader = value
                            QuestieTracker:Update()
                        end
                    },
                    fontSizeZone = {
                        type = "range",
                        order = 3,
                        name = function() return l10n('Font Size for Zone Names') end,
                        desc = function() return l10n('The font size used for zone names.') end,
                        width = "double",
                        min = 8,
                        max = 26,
                        step = 1,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeZone end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeZone = value
                            QuestieTracker:Update()
                        end
                    },
                    fontZone = {
                        type = "select",
                        dialogControl = 'LSM30_Font',
                        order = 4,
                        values = SharedMedia:HashTable("font"),
                        style = 'dropdown',
                        name = function() return l10n('Font for Zone Names') end,
                        desc = function() return l10n('The font used for zone names.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontZone or "Friz Quadrata TT" end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontZone = value
                            QuestieTracker:Update()
                        end
                    },
                    fontSizeQuest = {
                        type = "range",
                        order = 5,
                        name = function() return l10n('Font Size for Quest Titles') end,
                        desc = function() return l10n("The font size used for Quest Titles.\n\nNOTE: Objective font size will auto adjust to less than or equal to Quest font size. This is necessary to avoid any text collisions and formatting abnormalities.") end,
                        width = "double",
                        min = 8,
                        max = 26,
                        step = 1,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeQuest end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeQuest = value
                            if Questie.db.profile.trackerFontSizeObjective > value then
                                Questie.db.profile.trackerFontSizeObjective = value
                            end
                            QuestieTracker:Update()
                        end
                    },
                    fontQuest = {
                        type = "select",
                        dialogControl = 'LSM30_Font',
                        order = 6,
                        values = SharedMedia:HashTable("font"),
                        style = 'dropdown',
                        name = function() return l10n('Font for Quest Titles') end,
                        desc = function() return l10n('The font used for Quest Titles.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontQuest or "Friz Quadrata TT" end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontQuest = value
                            QuestieTracker:Update()
                        end
                    },
                    fontSizeObjective = {
                        type = "range",
                        order = 7,
                        name = function() return l10n('Font Size for Objectives') end,
                        desc = function() return l10n("The font size used for Objectives.\n\nNOTE: Objective font size will auto adjust to less than or equal to Quest font size. This is necessary to avoid any text collisions and formatting abnormalities.") end,
                        width = "double",
                        min = 8,
                        max = 26,
                        step = 1,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeObjective end,
                        set = function(_, value)
                            if Questie.db.profile.trackerFontSizeQuest < value then
                                Questie.db.profile.trackerFontSizeObjective = Questie.db.profile.trackerFontSizeQuest
                            else
                                Questie.db.profile.trackerFontSizeObjective = value
                            end
                            QuestieTracker:Update()
                        end
                    },
                    fontObjective = {
                        type = "select",
                        dialogControl = 'LSM30_Font',
                        order = 8,
                        values = SharedMedia:HashTable("font"),
                        style = 'dropdown',
                        name = function() return l10n('Font for Objectives') end,
                        desc = function() return l10n('The font used for Objectives.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontObjective or "Friz Quadrata TT" end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontObjective = value
                            QuestieTracker:Update()
                        end
                    },
                    fontOutline = {
                        type = "select",
                        dialogControl = 'LSM30_Font',
                        order = 9,
                        width = 1.5,
                        values = {
                            ["None"] = "",
                            ["Outline"] = "OUTLINE",
                            ["Monochrome"] = "MONOCHROME"
                        },
                        style = 'dropdown',
                        name = function() return l10n('Outline for Zones, Titles, and Objectives') end,
                        desc = function() return l10n('The outline used for Quest Zones, Titles, and Objectives in the Questie Tracker.') end,
                        disabled = function() return not Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontOutline end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontOutline = value
                            QuestieTracker:Update()
                        end
                    },
                }
            },
        }
    }

    return trackerOptions
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
