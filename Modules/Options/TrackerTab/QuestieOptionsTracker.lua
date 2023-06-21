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
        order = 13,
        args = {
            header = {
                type = "header",
                order = 1,
                name = function() return l10n('Tracker Options') end,
            },
            autoTrackQuests = {
                type = "toggle",
                order = 1.1,
                width = 1.5,
                name = function() return l10n('Auto Track Quests') end,
                desc = function() return l10n("This is the same as 'Enable Automatic Quest Tracking' in the Blizzard Interface Options. When enabled, the Questie Tracker will automatically track all Quests in your Quest Log. Disabling this option will untrack all Quests. You will have to manually select which Quests to track.\n\nNOTE: 'Show Complete Quests' is disabled while this option is not being used.") end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.autoTrackQuests end,
                set = function(_, value)
                    Questie.db.global.autoTrackQuests = value
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
            showCompleteQuests = {
                type = "toggle",
                order = 1.2,
                width = 1.5,
                name = function() return l10n('Show Completed Quests') end,
                desc = function() return l10n("When this is checked, completed Quests will show in the Questie Tracker.\n\nNOTE: This setting only works when 'Auto Track Quests' is enabled.") end,
                disabled = function() return (not Questie.db.char.trackerEnabled) or (not Questie.db.global.autoTrackQuests) end,
                get = function() return Questie.db.global.trackerShowCompleteQuests end,
                set = function(_, value)
                    Questie.db.global.trackerShowCompleteQuests = value
                    QuestieTracker:Update()
                end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.3,
                width = 1.5,
                name = function() return l10n('Show Quest Level') end,
                desc = function() return l10n('When this is checked, the Quest Level Tags for Quest Titles will show in the Questie Tracker.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerShowQuestLevel end,
                set = function(_, value)
                    Questie.db.global.trackerShowQuestLevel = value
                    QuestieTracker:Update()
                end
            },
            collapseCompletedQuests = {
                type = "toggle",
                order = 1.4,
                width = 1.5,
                name = function() return l10n('Auto Minimize Completed Quests') end,
                desc = function() return l10n('When this is checked, completed Quests will automatically minimize.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.collapseCompletedQuests end,
                set = function(_, value)
                    Questie.db.global.collapseCompletedQuests = value
                    if Questie.db.global.collapseCompletedQuests == false then
                        Questie.db.char.collapsedQuests = {}
                    end
                    QuestieTracker:Update()
                end
            },
            hideCompletedQuestObjectives = {
                type = "toggle",
                order = 1.5,
                width = 1.5,
                name = function() return l10n('Hide Completed Quest Objectives') end,
                desc = function() return l10n('When this is checked, completed Quest Objectives will automatically be removed from the Questie Tracker.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.hideCompletedQuestObjectives end,
                set = function(_, value)
                    Questie.db.global.hideCompletedQuestObjectives = value
                    QuestieTracker:Update()
                end
            },
            -- hideCompletedAchieveObjectives: order = 1.6 | Check WotLK section below
            showQuestTimer = {
                type = "toggle",
                order = 1.7,
                width = 1.5,
                name = function() return l10n('Show Blizzard Timer') end,
                desc = function() return l10n('When this is checked, the default Blizzard Timer Frame for Quests will be shown instead of being embedded inside the Questie Tracker.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.showBlizzardQuestTimer end,
                set = function(_, value)
                    Questie.db.global.showBlizzardQuestTimer = value

                    if value == true then
                        TrackerQuestTimers:ShowBlizzardTimer()
                    else
                        TrackerQuestTimers:HideBlizzardTimer()
                    end

                    QuestieTracker:Update()
                end
            },
            enableHeader = {
                type = "toggle",
                order = 1.9,
                width = 1.5,
                name = function() return l10n("Enable Active Quests Header") end,
                desc = function() return l10n("When this is checked, the Active Quests Header will become visible and the total number of Quests you have in your Quest Log will be shown.\n\nNOTE: When this is disabled, the Questie Icon will fade in while your mouse is over the Tracker.") end,
                disabled = function() return not Questie.db.char.trackerEnabled or Questie.db.global.alwaysShowTracker end,
                get = function() return Questie.db.global.trackerHeaderEnabled end,
                set = function(_, value)
                    Questie.db.global.trackerHeaderEnabled = value

                    if Questie.db.global.alwaysShowTracker == false then
                        Questie.db.global.currentHeaderEnabledSetting = value
                    end

                    QuestieTracker:UpdateFormatting()
                end
            },
            autoMoveHeader = {
                type = "toggle",
                order = 2.0,
                width = 1.5,
                name = function() return l10n('Auto Move Active Quests Header') end,
                desc = function() return l10n("When this is checked, the Active Quests Header will automatically move to the bottom of the Questie Tracker.\n\nNOTE: This setting only works while the 'Tracker Growth Direction' setting is set to 'Up & Right' or 'Up & Left'.") end,
                disabled = function()
                    return (not Questie.db.char.trackerEnabled)
                        or (not Questie.db.global.trackerHeaderEnabled)
                        or Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "TOPLEFT"
                        or Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "TOPRIGHT"
                end,
                get = function() return Questie.db.global.autoMoveHeader end,
                set = function(_, value)
                    Questie.db.global.autoMoveHeader = value
                    QuestieTracker:UpdateFormatting()
                end
            },
            stickyDurabilityFrame = {
                type = "toggle",
                order = 2.1,
                width = 1.5,
                name = function() return l10n('Sticky Durability Frame') end,
                desc = function() return l10n('When this is checked, the durability frame will be placed on the left or right side of the Questie Tracker depending on where the Tracker is placed on your screen.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.stickyDurabilityFrame end,
                set = function(_, value)
                    Questie.db.global.stickyDurabilityFrame = value
                    if value == false then
                        QuestieTracker:ResetDurabilityFrame()
                    end
                    QuestieTracker:Update()
                end
            },
            minimizeInCombat = {
                type = "toggle",
                order = 2.2,
                width = 1.5,
                name = function() return l10n('Minimize In Combat') end,
                desc = function() return l10n('When this is checked, the Questie Tracker will automatically be minimized while entering combat.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.hideTrackerInCombat end,
                set = function(_, value)
                    Questie.db.global.hideTrackerInCombat = value
                end
            },
            minimizeInDungeons = {
                type = "toggle",
                order = 2.3,
                width = 1.5,
                name = function() return l10n('Minimize In Dungeons') end,
                desc = function() return l10n('When this is checked, the Questie Tracker will automatically be minimized when entering a dungeon.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.hideTrackerInDungeons end,
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
                name = function() return l10n('Fade Min/Max Buttons') end,
                desc = function() return l10n('When this is checked, the Minimize and Maximize Buttons will fade and become transparent when not in use.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFadeMinMaxButtons end,
                set = function(_, value)
                    Questie.db.global.trackerFadeMinMaxButtons = value
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
                order = 2.5,
                width = 1.5,
                name = function() return l10n('Fade Quest Item Buttons') end,
                desc = function() return l10n('When this is checked, the Quest Item Buttons will fade and become transparent when not in use.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFadeQuestItemButtons end,
                set = function(_, value)
                    Questie.db.global.trackerFadeQuestItemButtons = value
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
            enableBackground = {
                type = "toggle",
                order = 2.6,
                width = 1.5,
                name = function() return l10n('Enable Background') end,
                desc = function() return l10n('When this is checked, the Questie Tracker Background becomes visible.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerBackdropEnabled end,
                set = function(_, value)
                    Questie.db.global.trackerBackdropEnabled = value
                    Questie.db.global.currentBackdropEnabled = value

                    if value == true and not Questie.db.global.trackerBackdropFader then
                        TrackerBaseFrame.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                    else
                        TrackerBaseFrame.baseFrame:SetBackdropColor(0, 0, 0, 0)
                    end
                    QuestieTracker:UpdateFormatting()
                end
            },
            enableBorder = {
                type = "toggle",
                order = 2.7,
                width = 1.5,
                name = function() return l10n('Enable Border') end,
                desc = function() return l10n('When this is checked, the Questie Tracker Border becomes visible.') end,
                disabled = function() return not Questie.db.char.trackerEnabled or not Questie.db.global.trackerBackdropEnabled end,
                get = function() return Questie.db.global.trackerBorderEnabled end,
                set = function(_, value)
                    Questie.db.global.trackerBorderEnabled = value
                    Questie.db.global.currentBorderEnabled = value

                    if value == true and not Questie.db.global.trackerBackdropFader then
                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
                    else
                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
                    end
                    QuestieTracker:UpdateFormatting()
                end
            },
            fadeTrackerBackdrop = {
                type = "toggle",
                order = 2.8,
                width = 1.5,
                name = function() return l10n('Fade Background') end,
                desc = function() return l10n('When this is checked, the Questie Tracker Backdrop and Border (if enabled) will fade and become transparent when not in use.') end,
                disabled = function() return not Questie.db.char.trackerEnabled or not Questie.db.global.trackerBackdropEnabled end,
                get = function() return Questie.db.global.trackerBackdropFader end,
                set = function(_, value)
                    Questie.db.global.trackerBackdropFader = value
                    Questie.db.global.currentBackdropFader = value

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

                                    if Questie.db.global.trackerBorderEnabled then
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
            hideSizer = {
                type = "toggle",
                order = 2.9,
                width = 1.5,
                name = function() return l10n("Hide Tracker Sizer") end,
                desc = function() return l10n("When this is checked, the Questie Tracker Sizer that appears in the bottom or top right hand corner will be hidden.") end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.sizerHidden end,
                set = function(_, value)
                    Questie.db.global.sizerHidden = value
                    QuestieTracker:UpdateFormatting()
                end
            },
            alwaysShowTracker = {
                type = "toggle",
                order = 2.92,
                width = 1.5,
                name = function() return l10n("Always Show Tracker") end,
                desc = function() return l10n("When this is checked, the Questie Trackers 'Active Quests Header' will always be visible when nothing is being tracked versus being hidden completely.\n\nNOTE: If the 'Active Quests Header' is in a disabled state, enabling this option will toggle it on when nothing is being tracked then toggle back off when you track something.") end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.alwaysShowTracker end,
                set = function(_, value)
                    Questie.db.global.alwaysShowTracker = value
                    if Questie.db.global.alwaysShowTracker == true then
                        if Questie.db.char.isTrackerExpanded == false then
                            Questie.db.char.isTrackerExpanded = true
                        end

                        if (not QuestieTracker:HasQuest()) then
                            Questie.db.global.trackerHeaderEnabled = true
                        else
                            Questie.db.global.trackerHeaderEnabled = Questie.db.global.currentHeaderEnabledSetting
                        end
                    else
                        Questie.db.global.trackerHeaderEnabled = Questie.db.global.currentHeaderEnabledSetting
                    end

                    QuestieTracker:UpdateFormatting()
                end
            },
            -- listAchievementsFirst: order = 2.94 | Check WotLK section below
            -- stickyVoiceOverFrame: order = 2.96 | Check Tracker Integrations section below
            lockTracker = {
                type = "toggle",
                order = 3.0,
                width = 1.5,
                name = function() return l10n("Lock Tracker") end,
                desc = function() return l10n("When this is checked, the Questie Tracker is locked and you need to hold CTRL when you want to move it.") end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerLocked end,
                set = function(_, value)
                    Questie.db.global.trackerLocked = value
                    TrackerBaseFrame:Update()
                end
            },
            Spacer_B = QuestieOptionsUtils:Spacer(3.1),
            enableQuestieTracker = {
                type = "execute",
                order = 3.2,
                width = 0.8,
                name = function()
                    local buttonName
                    if Questie.db.char.trackerEnabled then
                        buttonName = l10n('Disable Tracker')
                    elseif (not Questie.db.char.trackerEnabled) then
                        buttonName = l10n('Enable Tracker')
                    end
                    return buttonName
                end,
                desc = function()
                    local description
                    if Questie.db.char.trackerEnabled then
                        description = l10n('Disabling the Tracker will replace the Questie Tracker with the default Blizzard Quest Tracker.\n\nNOTE: This setting is saved Per Character and will reload the UI.')
                    elseif (not Questie.db.char.trackerEnabled) then
                        description = l10n('Enabling the Tracker will replace the default Blizzard Quest Tracker with the Questie Tracker.\n\nNOTE: This setting is saved Per Character and will reload the UI.')
                    end
                    return description
                end,
                disabled = function() return InCombatLockdown() end,
                func = function()
                    if Questie.db.char.trackerEnabled then
                        QuestieTracker:Disable()
                    else
                        QuestieTracker:Enable()
                    end
                end
            },
            Space_X = QuestieOptionsUtils:HorizontalSpacer(3.3, 0.1),
            resetTrackerLocation = {
                type = "execute",
                order = 3.4,
                width = 0.8,
                name = function() return l10n('Reset Tracker') end,
                desc = function() return l10n("If the Questie Tracker is stuck offscreen or lost, you can reset it's location to the center of the screen with this button.") end,
                disabled = function() return not Questie.db.char.trackerEnabled or InCombatLockdown() end,
                func = function()
                    QuestieTracker:ResetLocation()
                    QuestieTracker:Update()
                end
            },
            Space_Y = QuestieOptionsUtils:HorizontalSpacer(3.5, 0.1),
            globalTrackerLocation = {
                type = "execute",
                order = 3.6,
                width = 1.2,
                name = function()
                    local buttonName
                    if Questie.db.global.globalTrackerLocation then
                        buttonName = l10n('Save Tracker (Character)')
                    elseif not
                        Questie.db.global.globalTrackerLocation then
                        buttonName = l10n('Save Tracker (Global)')
                    end
                    return buttonName
                end,
                desc = function()
                    local buttonName
                    if Questie.db.global.globalTrackerLocation then
                        buttonName = l10n("The Questie Trackers Location and Set Point is currently being saved Per Character. This allows you to cusomize each character's Tracker location.\n\nNOTE: Upon enabling Per Character, the Questie Tracker will be reset to the center of your screen. Move the Tracker to your desired location and set the size. When you are ready, type '/reload' to finalize your settings.")
                    elseif not
                        Questie.db.global.globalTrackerLocation then
                        buttonName = l10n("The Questie Trackers Location and Set Point is currently being saved Globally. This allows you to have one setting for all characters.\n\nNOTE: Upon enabling Global, the Questie Tracker will be reset to the center of your screen. Move the Tracker to your desired location and set the size. When you are ready, type '/reload' to finalize your settings.")
                    end
                    return buttonName
                end,
                disabled = function() return not Questie.db.char.trackerEnabled or InCombatLockdown() end,
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
                values = function()
                    return {
                        ['white'] = l10n('White'),
                        ['whiteToGreen'] = l10n('White to Green'),
                        ['whiteAndGreen'] = l10n('White and Green'),
                        ['redToGreen'] = l10n('Red to Green')
                    }
                end,
                style = 'dropdown',
                name = function() return l10n('Objective Color') end,
                desc = function() return l10n('Change the color of Objectives in the Questie Tracker by how complete they are.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerColorObjectives end,
                set = function(_, key)
                    Questie.db.global.trackerColorObjectives = key
                    QuestieTracker:Update()
                end
            },
            sortObjectives = {
                type = "select",
                order = 3.9,
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
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerSortObjectives end,
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
                name = function() return l10n('Set |cFF54e33bTomTom|r Target') end,
                desc = function() return l10n('This shortcut will set the TomTom arrow to point to either an NPC or the first incomplete Quest Objective (if location data is available).') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerbindSetTomTom end,
                set = function(_, key)
                    Questie.db.global.trackerbindSetTomTom = key
                end
            },
            openQuestLog = {
                type = "select",
                order = 4.1,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Show in Quest Log') end,
                desc = function() return l10n('This shortcut will open the Quest Log with the clicked Quest selected.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerbindOpenQuestLog end,
                set = function(_, key)
                    Questie.db.global.trackerbindOpenQuestLog = key
                end
            },
            untrackQuest = {
                type = "select",
                order = 4.2,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Untrack / Link Quest') end,
                desc = function() return l10n('This shortcut removes a Quest from the Questie Tracker when the chat input box is NOT visible, otherwise this will link a Quest to chat.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerbindUntrack end,
                set = function(_, key)
                    Questie.db.global.trackerbindUntrack = key
                end
            },
            trackerSetpoint = {
                type = "select",
                order = 4.3,
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
                    return l10n(
                        "This determines the direction in which the Questie Tracker grows when you add or remove Quests. For example, if you use the 'Up & Right' option then the ideal place for the Tracker should be in the lower left-hand corner of your screen. This allows the 'Sizer Mode: Auto' to push the Tracker Height and Width 'Up & Right' so the Tracker doesn't inadvertently cover up elements of your UI.\n\nNOTE: This will also move the Active Quests Header (if enabled) to the bottom of the Questie Tracker when using the options 'Up & Right' or the 'Up & Left' setting. You can override this behavior by disabling the 'Auto Move Active Quests Header' option to force the Active Quests Header to remain at the top of the Questie Tracker. The 'Auto Move Active Quests Header' option is disabled when the options 'Down & Right' or 'Down & Left' are used.")
                end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db[Questie.db.global.questieTLoc].trackerSetpoint end,
                set = function(_, key)
                    Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = key
                    QuestieTracker:ResetLocation()
                    QuestieTracker:Update()
                end
            },
            Spacer_G = QuestieOptionsUtils:Spacer(4.4),
            fontSizeHeader = {
                type = "range",
                order = 4.5,
                name = function() return l10n("Font Size for Active Quests Header") end,
                desc = function() return l10n("The font size used for the Active Quests Header.") end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.char.trackerEnabled or not Questie.db.global.trackerHeaderEnabled end,
                get = function() return Questie.db.global.trackerFontSizeHeader end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeHeader = value
                    QuestieTracker:Update()
                end
            },
            fontHeader = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 4.6,
                values = SharedMedia:HashTable("font"),
                style = 'dropdown',
                name = function() return l10n("Font for Active Quests Header") end,
                desc = function() return l10n("The font used for the Active Quests Header.") end,
                disabled = function() return not Questie.db.char.trackerEnabled or not Questie.db.global.trackerHeaderEnabled end,
                get = function() return Questie.db.global.trackerFontHeader or "Friz Quadrata TT" end,
                set = function(_, value)
                    Questie.db.global.trackerFontHeader = value
                    QuestieTracker:Update()
                end
            },
            fontSizeZone = {
                type = "range",
                order = 4.7,
                name = function() return l10n('Font Size for Zone Names') end,
                desc = function() return l10n('The font size used for zone names.') end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontSizeZone end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeZone = value
                    QuestieTracker:Update()
                end
            },
            fontZone = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 4.8,
                values = SharedMedia:HashTable("font"),
                style = 'dropdown',
                name = function() return l10n('Font for Zone Names') end,
                desc = function() return l10n('The font used for zone names.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontZone or "Friz Quadrata TT" end,
                set = function(_, value)
                    Questie.db.global.trackerFontZone = value
                    QuestieTracker:Update()
                end
            },
            fontSizeQuest = {
                type = "range",
                order = 4.9,
                name = function() return l10n('Font Size for Quest Titles') end,
                desc = function() return l10n("The font size used for Quest Titles.\n\nNOTE: Objective font size will auto adjust to less than or equal to Quest font size. This is necessary to avoid any text collisions and formatting abnormalities.") end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontSizeQuest end,
                set = function(_, value)
                    Questie.db.global.trackerFontSizeQuest = value
                    if Questie.db.global.trackerFontSizeObjective > value then
                        Questie.db.global.trackerFontSizeObjective = value
                    end
                    QuestieTracker:Update()
                end
            },
            fontQuest = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 5.0,
                values = SharedMedia:HashTable("font"),
                style = 'dropdown',
                name = function() return l10n('Font for Quest Titles') end,
                desc = function() return l10n('The font used for Quest Titles.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontQuest or "Friz Quadrata TT" end,
                set = function(_, value)
                    Questie.db.global.trackerFontQuest = value
                    QuestieTracker:Update()
                end
            },
            fontSizeObjective = {
                type = "range",
                order = 5.1,
                name = function() return l10n('Font Size for Objectives') end,
                desc = function() return l10n("The font size used for Objectives.\n\nNOTE: Objective font size will auto adjust to less than or equal to Quest font size. This is necessary to avoid any text collisions and formatting abnormalities.") end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontSizeObjective end,
                set = function(_, value)
                    if Questie.db.global.trackerFontSizeQuest < value then
                        Questie.db.global.trackerFontSizeObjective = Questie.db.global.trackerFontSizeQuest
                    else
                        Questie.db.global.trackerFontSizeObjective = value
                    end
                    QuestieTracker:Update()
                end
            },
            fontObjective = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 5.2,
                values = SharedMedia:HashTable("font"),
                style = 'dropdown',
                name = function() return l10n('Font for Objectives') end,
                desc = function() return l10n('The font used for Objectives.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontObjective or "Friz Quadrata TT" end,
                set = function(_, value)
                    Questie.db.global.trackerFontObjective = value
                    QuestieTracker:Update()
                end
            },
            questPadding = {
                type = "range",
                order = 5.3,
                name = function() return l10n('Padding Between Quests') end,
                desc = function() return l10n('The amount of padding between Quests in the Questie Tracker.\n\nNOTE: Changing this setting while in Sizer Manual Mode will reset the Sizer back to Auto Mode') end,
                width = "double",
                min = 2,
                max = 16,
                step = 1,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerQuestPadding end,
                set = function(_, value)
                    Questie.db.global.trackerQuestPadding = value
                    local trackerHeightByManual = Questie.db[Questie.db.global.questieTLoc].TrackerHeight
                    if IsMouseButtonDown("LeftButton") and trackerHeightByManual == 0 then
                        QuestieTracker:Update()
                    elseif IsMouseButtonDown("LeftButton") and trackerHeightByManual > 0 then
                        Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
                        Questie.db[Questie.db.global.questieTLoc].TrackerHeight = 0
                        QuestieTracker:Update()
                    end
                end
            },
            fontOutline = {
                type = "select",
                dialogControl = 'LSM30_Font',
                order = 5.4,
                values = {
                    ["None"] = "",
                    ["Outline"] = "OUTLINE",
                    ["Monochrome"] = "MONOCHROME"
                },
                style = 'dropdown',
                name = function() return l10n('Outline for Zones, Titles, and Objectives') end,
                desc = function() return l10n('The outline used for Quest Zones, Titles, and Objectives in the Questie Tracker.') end,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerFontOutline end,
                set = function(_, value)
                    Questie.db.global.trackerFontOutline = value
                    QuestieTracker:Update()
                end
            },
            questBackdropAlpha = {
                type = "range",
                order = 5.5,
                name = function() return l10n('Tracker Backdrop Alpha') end,
                desc = function() return l10n('The alpha level of the Questie Trackers backdrop. A setting of 100 percent is fully visible.') end,
                width = "double",
                min = 0,
                max = 100,
                step = 5,
                disabled = function() return not Questie.db.global.trackerBackdropEnabled or not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerBackdropAlpha * 100 end,
                set = function(_, value)
                    Questie.db.global.trackerBackdropAlpha = value / 100
                    QuestieTracker:UpdateFormatting()
                end
            },
            trackerHeightRatio = {
                type = "range",
                order = 5.6,
                name = function() return l10n('Tracker Height Ratio') end,
                desc = function() return l10n('The height of the Questie Tracker based on percentage of usable screen height. A setting of 100 percent would make the Tracker fill the players entire screen height.\n\nNOTE: This setting only applies while in Sizer Mode: Auto') end,
                width = "double",
                min = 20,
                max = 100,
                step = 1,
                disabled = function() return not Questie.db.char.trackerEnabled end,
                get = function() return Questie.db.global.trackerHeightRatio * 100 end,
                set = function(_, value)
                    Questie.db.global.trackerHeightRatio = value / 100
                    if IsMouseButtonDown("LeftButton") and Questie.db[Questie.db.global.questieTLoc].TrackerHeight == 0 then
                        TrackerBaseFrame.isSizing = true
                        Questie.db.global.trackerBackdropEnabled = true
                        Questie.db.global.trackerBorderEnabled = true
                        Questie.db.global.trackerBackdropFader = false
                        QuestieTracker:UpdateFormatting()
                    else
                        TrackerBaseFrame.isSizing = false
                        Questie.db.global.trackerBackdropEnabled = Questie.db.global.currentBackdropEnabled
                        Questie.db.global.trackerBorderEnabled = Questie.db.global.currentBorderEnabled
                        Questie.db.global.trackerBackdropFader = Questie.db.global.currentBackdropFader
                        QuestieTracker:UpdateFormatting()
                    end
                end
            },
        }
    }

    if Questie.IsWotlk then
        -- These "over-write" the above options with Wrath of the Lich King specific language or options that are only found in Wrath.
        trackerOptions.args.hideCompletedAchieveObjectives = {
            type = "toggle",
            order = 1.6,
            width = 1.5,
            name = function() return l10n('Hide Completed Achieve Objectives') end,
            desc = function() return l10n('When this is checked, completed Achievement Objectives will automatically be removed from the Questie Tracker.') end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.global.hideCompletedAchieveObjectives end,
            set = function(_, value)
                Questie.db.global.hideCompletedAchieveObjectives = value
                QuestieTracker:Update()
            end
        }
        trackerOptions.args.listAchievementsFirst = {
            type = "toggle",
            order = 2.94,
            width = 1.5,
            name = function() return l10n("List Achievements First") end,
            desc = function() return l10n("When this is checked, the Questie Tracker will list Achievements first then Quests.") end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.char.listAchievementsFirst end,
            set = function(_, value)
                Questie.db.char.listAchievementsFirst = value
                QuestieTracker:Update()
            end
        }
        trackerOptions.args.sortObjectives = {
            type = "select",
            order = 3.9,
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
            desc = function() return l10n('How Objectives are sorted in the Questie Tracker.\n\nNOTE: This will not sort Achievements.') end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.global.trackerSortObjectives end,
            set = function(_, key)
                Questie.db.global.trackerSortObjectives = key
                QuestieTracker:Update()
            end
        }
        trackerOptions.args.setTomTom = {
            type = "select",
            order = 4.0,
            values = _GetShortcuts(),
            style = 'dropdown',
            name = function() return l10n('Set |cFF54e33bTomTom|r Target') end,
            desc = function() return l10n('This shortcut will set the TomTom arrow to point to either an NPC or the first incomplete Quest Objective (if location data is available).\n\nNOTE: This will not work with Achievements.') end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.global.trackerbindSetTomTom end,
            set = function(_, key)
                Questie.db.global.trackerbindSetTomTom = key
            end
        }
        trackerOptions.args.openQuestLog = {
            type = "select",
            order = 4.1,
            values = _GetShortcuts(),
            style = 'dropdown',
            name = function() return l10n('Show Quest / Achievement') end,
            desc = function() return l10n('This shortcut will open the Quest Log with the clicked Quest selected or open Achievements with the clicked Achievement selected.') end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.global.trackerbindOpenQuestLog end,
            set = function(_, key)
                Questie.db.global.trackerbindOpenQuestLog = key
            end
        }
        trackerOptions.args.untrackQuest = {
            type = "select",
            order = 4.2,
            values = _GetShortcuts(),
            style = 'dropdown',
            name = function() return l10n('Untrack / Link') end,
            desc = function() return l10n('This shortcut removes a Quest or an Achievement from the Questie Tracker when the chat input box is NOT visible, otherwise this will link a Quest or an Achievement to chat.') end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.global.trackerbindUntrack end,
            set = function(_, key)
                Questie.db.global.trackerbindUntrack = key
            end
        }
    end

    -- Questie Tracker Integrations Options
    local VoiceOver = (IsAddOnLoaded("AI_VoiceOver") and IsAddOnLoaded("AI_VoiceOverData_Vanilla"))
    --local TomTom = IsAddOnLoaded("TomTom")

    if VoiceOver then
        trackerOptions.args.stickyVoiceOverFrame = {
            type = "toggle",
            order = 2.96,
            width = 1.5,
            name = function() return l10n("Sticky VoiceOver Frame") end,
            desc = function() return l10n("When this is checked, the VoiceOver talking head / sound queue frame will be placed on the left or right side of the Questie Tracker depending on where the Tracker is placed on your screen.") end,
            disabled = function() return not Questie.db.char.trackerEnabled end,
            get = function() return Questie.db.char.stickyVoiceOverFrame end,
            set = function(_, value)
                Questie.db.char.stickyVoiceOverFrame = value
                if value == false then
                    QuestieTracker:ResetVoiceOverFrame()
                end
                QuestieTracker:Update()
            end
        }
    end

    --if TomTom then
    --trackerOptions.args.%optionname% = {
    --}
    --end

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
