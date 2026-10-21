---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type CommsVisibility
local CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptionsEngine.tabs.tracker = { ... }

local SharedMedia = LibStub("LibSharedMedia-3.0")
local IsAddOnLoaded = QuestieCompat.IsAddOnLoaded

local _GetShortcuts
local _GetObjectiveColors
local _GetObjectiveSortOptions
local _GetGrowthDirections

---Toggle tracker visibility based on a condition
---@param shouldHide boolean Whether to hide (true) or show (false) the tracker
---@param conditionFn fun(): boolean Function that returns true if the condition is met
local function toggleTrackerVisibility(shouldHide, conditionFn)
    local baseFrame = TrackerBaseFrame.baseFrame
    if baseFrame and conditionFn() then
        if shouldHide then
            QuestieTracker:Hide()
        else
            QuestieTracker:Show()
        end
    end
end

local function startFadeTicker()
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
                local c = Questie.db.profile.trackerBackdropColor
                TrackerBaseFrame.baseFrame:SetBackdropColor(c.r, c.g, c.b, fadeTickerValue)

                if Questie.db.profile.trackerBorderEnabled then
                    TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, fadeTickerValue)
                end
            end
        end
    end)
end

local debounceTimer

local function debounceFadeTicker()
    if debounceTimer then
        debounceTimer:Cancel()
    end

    debounceTimer = C_Timer.NewTimer(1, function()
        startFadeTicker()
    end)
end

function QuestieOptionsEngine.tabs.tracker:Initialize()
    return {
        title = "Tracker",
        subtitle = "Tracker Settings",
        order = 2,
        icon = 132212,
        items = {
            enableQuestieTracker = {
                type = "checkbox",
                order = 1,
                title = "Enable Tracker",
                tooltip = "Enabling the Tracker will replace the default Blizzard Quest Tracker with the Questie Tracker.\n\nNOTE: Changing this setting will reload the UI.",
                width = "half",
                enabled = function() return not InCombatLockdown() end,
                get = function() return Questie.db.profile.trackerEnabled end,
                set = function(_, val)
                    if val then
                        QuestieTracker:Enable()
                    else
                        QuestieTracker:Disable()
                    end
                end,
            },
            resetTrackerLocation = {
                type = "button",
                order = 2,
                title = "Reset Tracker",
                btnLabel = "Reset Tracker",
                tooltip = "If the Questie Tracker is stuck offscreen or lost, you can reset it's location to the center of the screen with this button.",
                width = "half",
                align = "LEFT",
                enabled = function() return Questie.db.profile.trackerEnabled and not InCombatLockdown() end,
                func = function()
                    QuestieTracker:ResetLocation()
                    QuestieTracker:Update()
                end,
            },
            group_quests = {
                type = "container",
                order = 3,
                title = Expansions.Current >= Expansions.Wotlk and "Quest and Achievement Options" or "Quest Options",
                enabled = function() return Questie.db.profile.trackerEnabled end,
                items = {
                    autoTrackQuests = {
                        type = "checkbox",
                        order = 1,
                        title = "Auto Track Quests",
                        tooltip = "This is the same as \"Enable Automatic Quest Tracking\" in the Blizzard Interface Options. If checked, the Questie Tracker will automatically track all Quests in your Quest Log. Disabling this option will untrack all Quests. You will have to manually select which Quests to track.\n\nNOTE: \"Show Complete Quests\" is disabled while this option is not being used.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.autoTrackQuests end,
                        set = function(_, value)
                            Questie.db.profile.autoTrackQuests = value
                            if value then
                                Questie.db.char.TrackedQuests = {}
                            else
                                Questie.db.char.AutoUntrackedQuests = {}
                            end
                            CommsVisibility:ScheduleSnapshot("AUTO_TRACK_QUESTS")

                            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
                            if questLogFrame and questLogFrame:IsShown() then
                                QuestieCompat.QuestLog_Update()
                            end

                            QuestieTracker:Update()
                        end,
                    },
                    showQuestLevels = {
                        type = "checkbox",
                        order = 2,
                        title = "Show Quest Level",
                        tooltip = "If checked, the Quest Level Tags for Quest Titles will show in the Questie Tracker.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerShowQuestLevel end,
                        set = function(_, value)
                            Questie.db.profile.trackerShowQuestLevel = value
                            QuestieTracker:Update()
                        end,
                    },
                    showQuestTimer = {
                        type = "checkbox",
                        order = 3,
                        title = "Show Blizzard Timer",
                        tooltip = "If checked, the default Blizzard Timer Frame for Quests will be shown instead of being embedded inside the Questie Tracker.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.showBlizzardQuestTimer end,
                        set = function(_, value)
                            Questie.db.profile.showBlizzardQuestTimer = value

                            if value == true then
                                TrackerQuestTimers:ShowBlizzardTimer()
                            else
                                TrackerQuestTimers:HideBlizzardTimer()
                            end

                            QuestieTracker:Update()
                        end,
                    },
                    listAchievementsFirst = {
                        type = "checkbox",
                        order = 4,
                        title = "List Achievements First",
                        tooltip = "If checked, the Questie Tracker will list Achievements first then Quests.",
                        width = "half",
                        visible = Expansions.Current >= Expansions.Wotlk,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.listAchievementsFirst end,
                        set = function(_, value)
                            Questie.db.profile.listAchievementsFirst = value
                            QuestieTracker:Update()
                        end,
                    },
                    openQuestLog = {
                        type = "dropdown",
                        order = 5,
                        title = Expansions.Current >= Expansions.Wotlk and "Show Quest / Achievement" or "Show in Quest Log",
                        tooltip = Expansions.Current >= Expansions.Wotlk and "This shortcut will open the Quest Log with the clicked Quest selected or open Achievements with the clicked Achievement selected." or "This shortcut will open the Quest Log with the clicked Quest selected.",
                        width = "half",
                        options = _GetShortcuts,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerbindOpenQuestLog end,
                        set = function(key)
                            Questie.db.profile.trackerbindOpenQuestLog = key
                        end,
                    },
                    untrackQuest = {
                        type = "dropdown",
                        order = 6,
                        title = Expansions.Current >= Expansions.Wotlk and "Untrack / Link" or "Untrack / Link Quest",
                        tooltip = Expansions.Current >= Expansions.Wotlk and "This shortcut removes a Quest or an Achievement from the Questie Tracker when the chat input box is NOT visible, otherwise this will link a Quest or an Achievement to chat." or "This shortcut removes a Quest from the Questie Tracker when the chat input box is NOT visible, otherwise this will link a Quest to chat.",
                        width = "half",
                        options = _GetShortcuts,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerbindUntrack end,
                        set = function(key)
                            Questie.db.profile.trackerbindUntrack = key
                        end,
                    },
                    questPadding = {
                        type = "slider",
                        order = 7,
                        title = "Padding Between Quests",
                        tooltip = "The amount of padding between Quests in the Questie Tracker.\n\nNOTE: Changing this setting while in Sizer Manual Mode will reset the Sizer back to Auto Mode",
                        width = "full",
                        min = 2,
                        max = 15,
                        step = 1,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
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
                        end,
                    },
                    group_objectives = {
                        type = "container",
                        order = 8,
                        title = "Objectives",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        items = {
                            showCompleteQuests = {
                                type = "checkbox",
                                order = 1,
                                title = "Show Completed Quests",
                                tooltip = "If checked, completed Quests will show in the Questie Tracker.\n\nNOTE: This setting only works when \"Auto Track Quests\" is enabled.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled and Questie.db.profile.autoTrackQuests end,
                                get = function() return Questie.db.profile.trackerShowCompleteQuests end,
                                set = function(_, value)
                                    Questie.db.profile.trackerShowCompleteQuests = value
                                    QuestieTracker:Update()
                                end,
                            },
                            collapseCompletedQuests = {
                                type = "checkbox",
                                order = 2,
                                title = "Auto Minimize Completed Quests",
                                tooltip = "If checked, completed Quests will automatically minimize.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.collapseCompletedQuests end,
                                set = function(_, value)
                                    Questie.db.profile.collapseCompletedQuests = value
                                    if Questie.db.profile.collapseCompletedQuests == false then
                                        Questie.db.char.collapsedQuests = {}
                                    end
                                    QuestieTracker:Update()
                                end,
                            },
                            hideCompletedQuestObjectives = {
                                type = "checkbox",
                                order = 3,
                                title = "Hide Completed Quest Objectives",
                                tooltip = "If checked, completed Quest Objectives will automatically be removed from the Questie Tracker.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.hideCompletedQuestObjectives end,
                                set = function(_, value)
                                    Questie.db.profile.hideCompletedQuestObjectives = value
                                    QuestieTracker:Update()
                                end,
                            },
                            hideCompletedAchieveObjectives = {
                                type = "checkbox",
                                order = 4,
                                title = "Hide Completed Achieve Objectives",
                                tooltip = "If checked, completed Achievement Objectives will automatically be removed from the Questie Tracker.",
                                width = "half",
                                visible = Expansions.Current >= Expansions.Wotlk,
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.hideCompletedAchieveObjectives end,
                                set = function(_, value)
                                    Questie.db.profile.hideCompletedAchieveObjectives = value
                                    QuestieTracker:Update()
                                end,
                            },
                            colorObjectives = {
                                type = "dropdown",
                                order = 5,
                                title = "Objective Color",
                                tooltip = "Change the color of Objectives in the Questie Tracker by how complete they are.\n\nNOTE: The Minimalistic option will not display the \"Blizzard Completion Text\" and just label the Quest as either \"Quest Complete!\" or \"Quest Failed!\".",
                                width = "half",
                                options = _GetObjectiveColors,
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerColorObjectives end,
                                set = function(key)
                                    Questie.db.profile.trackerColorObjectives = key
                                    QuestieTracker:Update()
                                end,
                            },
                            hideBlizzardCompletionText = {
                                type = "checkbox",
                                order = 6,
                                title = "Hide Blizzard Completion Text",
                                tooltip = "If checked, Blizzard Completion Text will be hidden for completed Quests and instead show the old Questie tags: \"Quest Complete!\" or \"Quest Failed!\"",
                                width = "half",
                                enabled = function()
                                    return Questie.db.profile.trackerEnabled and Questie.db.profile.trackerColorObjectives ~= "minimal"
                                end,
                                get = function() return Questie.db.profile.hideBlizzardCompletionText end,
                                set = function(_, value)
                                    Questie.db.profile.hideBlizzardCompletionText = value
                                    if Questie.db.profile.hideBlizzardCompletionText == false then
                                        Questie.db.char.collapsedQuests = {}
                                    end
                                    QuestieTracker:Update()
                                end,
                            },
                            sortObjectives = {
                                type = "dropdown",
                                order = 7,
                                title = "Objective Sorting",
                                tooltip = "How Objectives are sorted in the Questie Tracker.",
                                width = "full",
                                options = _GetObjectiveSortOptions,
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerSortObjectives end,
                                set = function(key)
                                    Questie.db.profile.trackerSortObjectives = key
                                    QuestieTracker:Update()
                                end,
                            },
                        },
                    },
                },
            },
            group_tracker_window = {
                type = "container",
                order = 4,
                title = "Tracker Window Options",
                enabled = function() return Questie.db.profile.trackerEnabled end,
                items = {
                    minimizeInCombat = {
                        type = "checkbox",
                        order = 1,
                        title = "Minimize In Combat",
                        tooltip = "If checked, the Questie Tracker will automatically be minimized while entering combat.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.minimizeTrackerInCombat end,
                        set = function(_, value)
                            Questie.db.profile.minimizeTrackerInCombat = value
                            if value then
                                Questie.db.profile.hideTrackerInCombat = false
                                QuestieTracker.OnHideInCombatChanged(false)
                            end
                            QuestieTracker.OnMinimizeInCombatChanged(value)
                        end,
                    },
                    minimizeInInstances = {
                        type = "checkbox",
                        order = 2,
                        title = "Minimize In Instances",
                        tooltip = "If checked, the Questie Tracker will automatically be minimized when entering a dungeon, raid, or battleground.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.minimizeTrackerInInstances end,
                        set = function(_, value)
                            Questie.db.profile.minimizeTrackerInInstances = value
                            if value then
                                Questie.db.profile.hideTrackerInInstances = false
                                QuestieTracker.OnHideInInstancesChanged(false)
                            end
                            QuestieTracker.OnMinimizeInInstancesChanged(value)
                        end,
                    },
                    hideInCombat = {
                        type = "checkbox",
                        order = 3,
                        title = "Hide In Combat",
                        tooltip = "If checked, the Questie Tracker will automatically be hidden when entering combat.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.hideTrackerInCombat end,
                        set = function(_, value)
                            Questie.db.profile.hideTrackerInCombat = value
                            if value then
                                Questie.db.profile.minimizeTrackerInCombat = false
                                QuestieTracker.OnMinimizeInCombatChanged(false)
                            end
                            QuestieTracker.OnHideInCombatChanged(value)
                        end,
                    },
                    hideInInstances = {
                        type = "checkbox",
                        order = 4,
                        title = "Hide In Instances",
                        tooltip = "If checked, the Questie Tracker will automatically be hidden when entering a dungeon, raid, or battleground.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.hideTrackerInInstances end,
                        set = function(_, value)
                            Questie.db.profile.hideTrackerInInstances = value
                            if value then
                                Questie.db.profile.minimizeTrackerInInstances = false
                                QuestieTracker.OnMinimizeInInstancesChanged(false)
                            end
                            QuestieTracker.OnHideInInstancesChanged(value)
                        end,
                    },
                    hideInPetBattles = {
                        type = "checkbox",
                        order = 5,
                        title = "Hide In Pet Battles",
                        tooltip = "If checked, the Questie Tracker will automatically be hidden when entering a pet battle.",
                        width = "half",
                        visible = Expansions.Current >= Expansions.MoP,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.hideTrackerInPetBattles end,
                        set = function(_, value)
                            Questie.db.profile.hideTrackerInPetBattles = value
                            toggleTrackerVisibility(value, function()
                                return (C_PetBattles and C_PetBattles.IsInBattle and C_PetBattles.IsInBattle()) or false
                            end)
                        end,
                    },
                    fadeMinMaxButtons = {
                        type = "checkbox",
                        order = 6,
                        title = "Fade Min/Max Buttons",
                        tooltip = "If checked, the Minimize and Maximize Buttons will fade and become transparent when not in use.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
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

                                        if Questie.db.char.isTrackerExpanded then
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
                        end,
                    },
                    fadeQuestItemButtons = {
                        type = "checkbox",
                        order = 7,
                        title = "Fade Quest Item Buttons",
                        tooltip = "If checked, the Quest Item Buttons will fade and become transparent when not in use.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
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

                                        if Questie.db.char.isTrackerExpanded then
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
                        end,
                    },
                    disableHoverFade = {
                        type = "checkbox",
                        order = 8,
                        title = "Disable Quest Hover Fade",
                        tooltip = "If checked, the other quests in the tracker will stay fully opaque while hovering a quest.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerDisableHoverFade end,
                        set = function(_, value)
                            Questie.db.profile.trackerDisableHoverFade = value
                        end,
                    },
                    hideSizer = {
                        type = "checkbox",
                        order = 9,
                        title = "Hide Tracker Sizer",
                        tooltip = "If checked, the Questie Tracker Sizer that appears in the bottom or top right hand corner will be hidden.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.sizerHidden end,
                        set = function(_, value)
                            Questie.db.profile.sizerHidden = value
                            QuestieTracker:UpdateFormatting()
                        end,
                    },
                    lockTracker = {
                        type = "checkbox",
                        order = 10,
                        title = "Lock Tracker",
                        tooltip = "If checked, the Questie Tracker is locked and you need to hold CTRL when you want to move it.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerLocked end,
                        set = function(_, value)
                            Questie.db.profile.trackerLocked = value
                            TrackerBaseFrame:Update()
                        end,
                    },
                    stickyDurabilityFrame = {
                        type = "checkbox",
                        order = 11,
                        title = "Sticky Durability Frame",
                        tooltip = "If checked, the durability frame will be placed on the left or right side of the Questie Tracker depending on where the Tracker is placed on your screen.",
                        width = "half",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.stickyDurabilityFrame end,
                        set = function(_, value)
                            Questie.db.profile.stickyDurabilityFrame = value
                            if value == false then
                                QuestieTracker:ResetDurabilityFrame()
                            end
                            QuestieTracker:Update()
                        end,
                    },
                    stickyVoiceOverFrame = {
                        type = "checkbox",
                        order = 12,
                        title = "Sticky VoiceOver Frame",
                        tooltip = "If checked, the VoiceOver talking head / sound queue frame will be placed on the left or right side of the Questie Tracker depending on where the Tracker is placed on your screen.",
                        width = "half",
                        visible = function()
                            return (IsAddOnLoaded("AI_VoiceOver") and IsAddOnLoaded("AI_VoiceOverData_Vanilla"))
                        end,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.stickyVoiceOverFrame end,
                        set = function(_, value)
                            Questie.db.profile.stickyVoiceOverFrame = value
                            if value == false then
                                QuestieTracker:ResetVoiceOverFrame()
                            end
                            QuestieTracker:Update()
                        end,
                    },
                    setTomTom = {
                        type = "dropdown",
                        order = 13,
                        title = "Set |cFF54e33bTomTom|r Target",
                        tooltip = Expansions.Current >= Expansions.Wotlk
                            and "This shortcut will set the TomTom arrow to point to either an NPC or the first incomplete Quest Objective (if location data is available).\n\nNOTE: This will not work with Achievements."
                            or "This shortcut will set the TomTom arrow to point to either an NPC or the first incomplete Quest Objective (if location data is available).",
                        width = "half",
                        options = _GetShortcuts,
                        visible = function() return IsAddOnLoaded("TomTom") end,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerbindSetTomTom end,
                        set = function(key)
                            Questie.db.profile.trackerbindSetTomTom = key
                        end,
                    },
                    trackerSetpoint = {
                        type = "dropdown",
                        order = 14,
                        title = "Tracker Growth Direction",
                        tooltip = "This determines the direction in which the Questie Tracker grows when you add or remove Quests. For example, if you use the \"Up & Right\" option then the ideal place for the Tracker should be in the lower left-hand corner of your screen. This allows the \"Sizer Mode: Auto\" to push the Tracker Height and Width \"Up & Right\" so the Tracker doesn't inadvertently cover up elements of your UI.",
                        width = "half",
                        options = _GetGrowthDirections,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerSetpoint end,
                        set = function(key)
                            Questie.db.profile.trackerSetpoint = key
                            QuestieTracker:ResetLocation()
                            QuestieTracker:Update()
                        end,
                    },
                    trackerHeightRatio = {
                        type = "slider",
                        order = 15,
                        title = "Tracker Height Ratio",
                        tooltip = "The height of the Questie Tracker based on percentage of usable screen height. A setting of 100 percent would make the Tracker fill the players entire screen height.\n\nNOTE: This setting only applies while in Sizer Mode: Auto",
                        width = "half",
                        min = 20,
                        max = 100,
                        step = 1,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
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
                        end,
                    },
                    trackerWidthRatio = {
                        type = "slider",
                        order = 16,
                        title = "Tracker Width Ratio",
                        tooltip = "The width of the Questie Tracker based on percentage of usable screen width. A setting of 100 percent would make the Tracker fill the players entire screen width.\n\nNOTE: This setting only applies while in Sizer Mode: Auto",
                        width = "half",
                        min = 15,
                        max = 100,
                        step = 1,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerWidthRatio * 100 end,
                        set = function(_, value)
                            Questie.db.profile.trackerWidthRatio = value / 100
                            if IsMouseButtonDown("LeftButton") and Questie.db.profile.TrackerWidth == 0 then
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
                        end,
                    },
                    group_header = {
                        type = "container",
                        order = 17,
                        title = "Tracker Header",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        items = {
                            enableHeader = {
                                type = "checkbox",
                                order = 1,
                                title = "Enable Tracker Header",
                                tooltip = "If checked, the Tracker Header with the number of active quests and the Questie Icon will be permanently visible.\n\nWhen this is disabled the Questie Icon will fade in while your mouse is over the Tracker.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerHeaderEnabled end,
                                set = function(_, value)
                                    Questie.db.profile.trackerHeaderEnabled = value
                                    QuestieTracker:UpdateFormatting()
                                end,
                            },
                            moveHeaderToBottom = {
                                type = "checkbox",
                                order = 2,
                                title = "Show Tracker Header At The Bottom",
                                tooltip = "If checked, the Tracker Header and/or the Questie Icon will be moved to the bottom of the Questie Tracker and the sizer to the top.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.moveHeaderToBottom end,
                                set = function(_, value)
                                    Questie.db.profile.moveHeaderToBottom = value
                                    QuestieTracker:UpdateFormatting()
                                end,
                            },
                            alwaysShowTracker = {
                                type = "checkbox",
                                order = 3,
                                title = "Show Header For Empty Tracker",
                                tooltip = "If checked, the Tracker Header will be visible even when no quests are being tracked versus the Tracker being hidden completely.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.alwaysShowTracker end,
                                set = function(_, value)
                                    Questie.db.profile.alwaysShowTracker = value
                                    if (Questie.db.profile.alwaysShowTracker == true) and (Questie.db.char.isTrackerExpanded == false) then
                                        Questie.db.char.isTrackerExpanded = true
                                        QuestieTracker:Update()
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end,
                            },
                        },
                    },
                    group_background = {
                        type = "container",
                        order = 18,
                        title = "Tracker Background",
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        items = {
                            enableBackground = {
                                type = "checkbox",
                                order = 1,
                                title = "Enable Background",
                                tooltip = "If checked, the Questie Tracker Background becomes visible.",
                                width = "half",
                                enabled = function() return Questie.db.profile.trackerEnabled end,
                                get = function() return Questie.db.profile.trackerBackdropEnabled end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBackdropEnabled = value
                                    Questie.db.profile.currentBackdropEnabled = value

                                    if value == true and not Questie.db.profile.trackerBackdropFader then
                                        local c = Questie.db.profile.trackerBackdropColor
                                        TrackerBaseFrame.baseFrame:SetBackdropColor(c.r, c.g, c.b, c.a)
                                    else
                                        TrackerBaseFrame.baseFrame:SetBackdropColor(0, 0, 0, 0)
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end,
                            },
                            enableBorder = {
                                type = "checkbox",
                                order = 2,
                                title = "Enable Border",
                                tooltip = "If checked, the Questie Tracker Border becomes visible.",
                                width = "half",
                                enabled = function()
                                    return Questie.db.profile.trackerEnabled and Questie.db.profile.trackerBackdropEnabled
                                end,
                                get = function() return Questie.db.profile.trackerBorderEnabled end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBorderEnabled = value
                                    Questie.db.profile.currentBorderEnabled = value

                                    if value == true and not Questie.db.profile.trackerBackdropFader then
                                        local c = Questie.db.profile.trackerBackdropColor
                                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, c.a)
                                    else
                                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end,
                            },
                            fadeTrackerBackdrop = {
                                type = "checkbox",
                                order = 3,
                                title = "Fade Background",
                                tooltip = "If checked, the Questie Tracker background and border (if enabled) will fade and become transparent when not in use.",
                                width = "half",
                                enabled = function()
                                    return Questie.db.profile.trackerEnabled and Questie.db.profile.trackerBackdropEnabled
                                end,
                                get = function() return Questie.db.profile.trackerBackdropFader end,
                                set = function(_, value)
                                    Questie.db.profile.trackerBackdropFader = value
                                    Questie.db.profile.currentBackdropFader = value

                                    if value == true then
                                        startFadeTicker()
                                    end
                                    QuestieTracker:UpdateFormatting()
                                end,
                            },
                            trackerBackdropColor = {
                                type = "colorPicker",
                                order = 4,
                                title = "Background Color",
                                tooltip = "Choose the color for the Questie Tracker background.",
                                width = "half",
                                hasOpacity = true,
                                enabled = function()
                                    return Questie.db.profile.trackerEnabled and Questie.db.profile.trackerBackdropEnabled
                                end,
                                get = function()
                                    local c = Questie.db.profile.trackerBackdropColor
                                    return c.r, c.g, c.b, c.a
                                end,
                                set = function(r, g, b, a)
                                    Questie.db.profile.trackerBackdropColor = { r = r, g = g, b = b, a = a }
                                    if Questie.db.profile.trackerBackdropEnabled then
                                        TrackerBaseFrame.baseFrame:SetBackdropColor(r, g, b, a)
                                    end

                                    if Questie.db.profile.trackerBorderEnabled then
                                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, a)
                                    end

                                    if Questie.db.profile.trackerBackdropFader then
                                        debounceFadeTicker()
                                    end
                                end,
                            },
                        },
                    },
                },
            },
            group_fonts = {
                type = "container",
                order = 5,
                title = "Font Options",
                enabled = function() return Questie.db.profile.trackerEnabled end,
                items = {
                    fontSizeHeader = {
                        type = "slider",
                        order = 1,
                        title = "Font Size for Active Quests Header",
                        tooltip = "The font size used for the Active Quests Header.",
                        width = "half",
                        min = 8,
                        max = 26,
                        step = 1,
                        enabled = function()
                            return Questie.db.profile.trackerEnabled and Questie.db.profile.trackerHeaderEnabled
                        end,
                        get = function() return Questie.db.profile.trackerFontSizeHeader end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeHeader = value
                            QuestieTracker:Update()
                        end,
                    },
                    fontHeader = {
                        type = "fontDropdown",
                        order = 2,
                        title = "Font for Active Quests Header",
                        tooltip = "The font used for the Active Quests Header.",
                        width = "half",
                        fonts = SharedMedia:HashTable("font"),
                        enabled = function()
                            return Questie.db.profile.trackerEnabled and Questie.db.profile.trackerHeaderEnabled
                        end,
                        get = function() return Questie.db.profile.trackerFontHeader or "Friz Quadrata TT" end,
                        set = function(val)
                            Questie.db.profile.trackerFontHeader = val
                            QuestieTracker:Update()
                        end,
                    },
                    fontSizeZone = {
                        type = "slider",
                        order = 3,
                        title = "Font Size for Zone Names",
                        tooltip = "The font size used for zone names.",
                        width = "half",
                        min = 8,
                        max = 26,
                        step = 1,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeZone end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeZone = value
                            QuestieTracker:Update()
                        end,
                    },
                    fontZone = {
                        type = "fontDropdown",
                        order = 4,
                        title = "Font for Zone Names",
                        tooltip = "The font used for zone names.",
                        width = "half",
                        fonts = SharedMedia:HashTable("font"),
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontZone or "Friz Quadrata TT" end,
                        set = function(val)
                            Questie.db.profile.trackerFontZone = val
                            QuestieTracker:Update()
                        end,
                    },
                    fontSizeQuest = {
                        type = "slider",
                        order = 5,
                        title = "Font Size for Quest Titles",
                        tooltip = "The font size used for Quest Titles.\n\nNOTE: Objective font size will auto adjust to less than or equal to Quest font size. This is necessary to avoid any text collisions and formatting abnormalities.",
                        width = "half",
                        min = 8,
                        max = 26,
                        step = 1,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeQuest end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeQuest = value
                            QuestieTracker:Update()
                        end,
                    },
                    fontQuest = {
                        type = "fontDropdown",
                        order = 6,
                        title = "Font for Quest Titles",
                        tooltip = "The font used for Quest Titles.",
                        width = "half",
                        fonts = SharedMedia:HashTable("font"),
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontQuest or "Friz Quadrata TT" end,
                        set = function(val)
                            Questie.db.profile.trackerFontQuest = val
                            QuestieTracker:Update()
                        end,
                    },
                    fontSizeObjective = {
                        type = "slider",
                        order = 7,
                        title = "Font Size for Objectives",
                        tooltip = "The font size used for Objectives.\n\nNOTE: Objective font size will auto adjust to less than or equal to Quest font size. This is necessary to avoid any text collisions and formatting abnormalities.",
                        width = "half",
                        min = 8,
                        max = 26,
                        step = 1,
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontSizeObjective end,
                        set = function(_, value)
                            Questie.db.profile.trackerFontSizeObjective = value
                            QuestieTracker:Update()
                        end,
                    },
                    fontObjective = {
                        type = "fontDropdown",
                        order = 8,
                        title = "Font for Objectives",
                        tooltip = "The font used for Objectives.",
                        width = "half",
                        fonts = SharedMedia:HashTable("font"),
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontObjective or "Friz Quadrata TT" end,
                        set = function(val)
                            Questie.db.profile.trackerFontObjective = val
                            QuestieTracker:Update()
                        end,
                    },
                    fontOutline = {
                        type = "dropdown",
                        order = 9,
                        title = "Outline for Zones, Titles, and Objectives",
                        tooltip = "The outline used for Quest Zones, Titles, and Objectives in the Questie Tracker.",
                        width = "half",
                        options = {
                            [""] = NONE,
                            ["OUTLINE"] = SELF_HIGHLIGHT_MODE_OUTLINE,
                        },
                        enabled = function() return Questie.db.profile.trackerEnabled end,
                        get = function() return Questie.db.profile.trackerFontOutline end,
                        set = function(val)
                            Questie.db.profile.trackerFontOutline = val
                            QuestieTracker:Update()
                        end,
                    },
                },
            },
        },
    }
end

_GetShortcuts = function()
    return {
        ["left"] = l10n("Left Click"),
        ["right"] = l10n("Right Click"),
        ["shiftleft"] = l10n("Shift") .. " + " .. l10n("Left Click"),
        ["shiftright"] = l10n("Shift") .. " + " .. l10n("Right Click"),
        ["ctrlleft"] = l10n("Control") .. " + " .. l10n("Left Click"),
        ["ctrlright"] = l10n("Control") .. " + " .. l10n("Right Click"),
        ["altleft"] = l10n("Alt") .. " + " .. l10n("Left Click"),
        ["altright"] = l10n("Alt") .. " + " .. l10n("Right Click"),
        ["disabled"] = l10n("Disabled"),
    }
end

_GetObjectiveColors = function()
    return {
        ["white"] = l10n("White"),
        ["whiteToGreen"] = l10n("White to Green"),
        ["whiteAndGreen"] = l10n("White and Green"),
        ["redToGreen"] = l10n("Red to Green"),
        ["minimal"] = l10n("Minimalistic"),
    }
end

_GetObjectiveSortOptions = function()
    return {
        ["byComplete"] = l10n("By %% Complete"),
        ["byCompleteReversed"] = l10n("By %% Complete (Reversed)"),
        ["byLevel"] = l10n("By Level"),
        ["byLevelReversed"] = l10n("By Level (Reversed)"),
        ["byProximity"] = l10n("By Proximity"),
        ["byProximityReversed"] = l10n("By Proximity (Reversed)"),
        ["byZone"] = l10n("By Zone"),
        ["byZonePlayerProximity"] = l10n("By Zone Prox"),
        ["byZonePlayerProximityReversed"] = l10n("By Zone Prox (Reversed)"),
    }
end

_GetGrowthDirections = function()
    return {
        ["TOPLEFT"] = l10n("Down & Right"),
        ["BOTTOMLEFT"] = l10n("Up & Right"),
        ["TOPRIGHT"] = l10n("Down & Left"),
        ["BOTTOMRIGHT"] = l10n("Up & Left"),
    }
end