---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

QuestieOptionsEngine.tabs.icons = { ... }

local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetIconTypes
local _GetIconTypesSort
local _GetIconThemes
local _GetIconThemesSort

local function _IsEnabled()
    return Questie.db.profile.enabled
end

local function _IsMapEnabled()
    return Questie.db.profile.enabled and Questie.db.profile.enableMapIcons
end

local function _IsMinimapEnabled()
    return Questie.db.profile.enabled and Questie.db.profile.enableMiniMapIcons
end

function QuestieOptionsEngine.tabs.icons:Initialize()
    return {
        title = "Icons",
        subtitle = "Icon Settings",
        order = 1,
        icon = 132328,
        items = {
            icon_options_group = {
                type = "container",
                order = 1,
                title = "Icon Options",
                items = {
                    show_icons = {
                        type = "checkbox",
                        order = 1.1,
                        title = "Enable Icons",
                        description = "Shows or hides the icons that Questie draws on the world map and minimap.",
                        width = 0.6,
                        get = function() return Questie.db.profile.enabled end,
                        set = function(_, value)
                            Questie.db.profile.enabled = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    iconThemePicker = {
                        type = "dropdown",
                        order = 1.2,
                        title = "Objective Icon Theme",
                        tooltip = "Change between themes for objective icons.",
                        width = 0.39,
                        options = _GetIconThemes,
                        sortOrder = _GetIconThemesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.iconTheme end,
                        set = function(key)
                            QuestieOptionsUtils.ExecuteTheme(nil, key)
                        end,
                    },
                    hideMapIconsForUntrackedToggle = {
                        type = "checkbox",
                        order = 1.3,
                        title = "Hide icons of untracked quests",
                        tooltip = "Hide icons for quests that are not tracked.",
                        width = "full",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.hideUntrackedQuestsMapIcons end,
                        set = function(_, value)
                            Questie.db.profile.hideUntrackedQuestsMapIcons = value
                            ThreadLib.ThreadInstant(function()
                                if value then
                                    QuestieQuest:HideQuestIcons()
                                else
                                    QuestieQuest:ShowQuestIcons()
                                end
                                if value == true then
                                    for _, quest in pairs(QuestiePlayer.currentQuestlog) do
                                        if not QuestieQuest:ShouldShowQuestNotes(quest.Id) then
                                            QuestieTooltips:RemoveQuest(quest.Id)
                                        end
                                    end
                                else
                                    for _, quest in pairs(QuestiePlayer.currentQuestlog) do
                                        QuestieQuest:PopulateObjectiveNotes(quest)
                                    end
                                end
                            end)
                        end,
                    },
                },
            },
            icon_toggles_group = {
                type = "container",
                order = 2,
                title = "Show icons for...",
                enabled = _IsEnabled,
                items = {
                    quest_options = {
                        type = "divider",
                        order = 1,
                        title = "Quests",
                        width = "full",
                    },
                    showNormalQuests = {
                        type = "checkbox",
                        order = 2.01,
                        title = "Available Normal Quests",
                        tooltip = "If checked, the locations of available quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.enableAvailable end,
                        set = function(_, value)
                            Questie.db.profile.enableAvailable = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showItemQuests = {
                        type = "checkbox",
                        order = 2.02,
                        title = "Available Quests from Items",
                        tooltip = "If checked, the locations of item drops that start quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.enableAvailableItems end,
                        set = function(_, value)
                            Questie.db.profile.enableAvailableItems = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showEventQuests = {
                        type = "checkbox",
                        order = 2.03,
                        title = "Available Event Quests",
                        tooltip = "If checked, the locations of active event quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showEventQuests end,
                        set = function(_, value)
                            Questie.db.profile.showEventQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showRepeatableQuests = {
                        type = "checkbox",
                        order = 2.04,
                        title = "Available Repeatable Quests",
                        tooltip = "If checked, the locations of repeatable quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showRepeatableQuests end,
                        set = function(_, value)
                            Questie.db.profile.showRepeatableQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showPvPQuests = {
                        type = "checkbox",
                        order = 2.05,
                        title = "Available PvP Quests",
                        tooltip = "If checked, the locations of PvP quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showPvPQuests end,
                        set = function(_, value)
                            Questie.db.profile.showPvPQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showDungeonQuests = {
                        type = "checkbox",
                        order = 2.06,
                        title = "Available Dungeon Quests",
                        tooltip = "If checked, the locations of dungeon quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showDungeonQuests end,
                        set = function(_, value)
                            Questie.db.profile.showDungeonQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showRaidQuests = {
                        type = "checkbox",
                        order = 2.07,
                        title = "Available Raid Quests",
                        tooltip = "If checked, the locations of raid quests will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showRaidQuests end,
                        set = function(_, value)
                            Questie.db.profile.showRaidQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showCompleteQuests = {
                        type = "checkbox",
                        order = 2.08,
                        title = "Completed Quests",
                        tooltip = "If checked, the quest turn-in locations will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.enableTurnins end,
                        set = function(_, value)
                            Questie.db.profile.enableTurnins = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showObjectivesToggle = {
                        type = "checkbox",
                        order = 2.09,
                        title = "Objectives",
                        tooltip = "If checked, quest objective icons will be shown on the map/minimap.",
                        width = "half",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.enableObjectives end,
                        set = function(_, value)
                            Questie.db.profile.enableObjectives = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieOptionsUtils.DetermineTheme()
                        end,
                    },
                    showAQWarEffortQuests = {
                        type = "checkbox",
                        order = 2.10,
                        title = "Available AQ War Effort Quests",
                        tooltip = "If checked, the locations of the AQ War Effort quests will be shown on the map/minimap.",
                        width = "half",
                        visible = Questie.IsClassic,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showAQWarEffortQuests end,
                        set = function(_, value)
                            Questie.db.profile.showAQWarEffortQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    sod_rune_options = {
                        type = "divider",
                        order = 2.20,
                        title = "Season of Discovery Runes",
                        width = "full",
                        visible = false,
                    },
                    showSoDRunes = {
                        type = "checkbox",
                        order = 2.21,
                        title = "Show Runes",
                        tooltip = "If checked, the locations of Season of Discovery Runes and Rune quests will be shown on the map/minimap.",
                        width = "full",
                        visible = Questie.IsSoD,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.showSoDRunes end,
                        set = function(_, value)
                            Questie.db.profile.showSoDRunes = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    sodRuneSelection = {
                        type = "container",
                        order = 2.22,
                        title = "",
                        visible = false,
                        enabled = function() return _IsEnabled() and Questie.db.profile.showSoDRunes end,
                        items = {
                            phase1 = {
                                type = "checkbox",
                                order = 1,
                                title = "Phase 1",
                                width = "quarter",
                                enabled = function() return _IsEnabled() and Questie.db.profile.showSoDRunes end,
                                get = function() return Questie.db.profile.showRunesOfPhase.phase1 end,
                                set = function(_, value)
                                    Questie.db.profile.showRunesOfPhase.phase1 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                            phase2 = {
                                type = "checkbox",
                                order = 2,
                                title = "Phase 2",
                                width = "quarter",
                                enabled = function() return _IsEnabled() and Questie.db.profile.showSoDRunes end,
                                get = function() return Questie.db.profile.showRunesOfPhase.phase2 end,
                                set = function(_, value)
                                    Questie.db.profile.showRunesOfPhase.phase2 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                            phase3 = {
                                type = "checkbox",
                                order = 3,
                                title = "Phase 3",
                                width = "quarter",
                                enabled = function() return _IsEnabled() and Questie.db.profile.showSoDRunes end,
                                get = function() return Questie.db.profile.showRunesOfPhase.phase3 end,
                                set = function(_, value)
                                    Questie.db.profile.showRunesOfPhase.phase3 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                            phase4 = {
                                type = "checkbox",
                                order = 4,
                                title = "Phase 4",
                                width = "quarter",
                                enabled = function() return _IsEnabled() and Questie.db.profile.showSoDRunes end,
                                get = function() return Questie.db.profile.showRunesOfPhase.phase4 end,
                                set = function(_, value)
                                    Questie.db.profile.showRunesOfPhase.phase4 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                        },
                    },
                    townsfolk_options = {
                        type = "divider",
                        order = 2.30,
                        title = "Other Icons",
                        width = "full",
                    },
                    townsfolkOptions = {
                        type = "button",
                        order = 2.31,
                        title = "Townsfolk",
                        btnLabel = "Townsfolk",
                        tooltip = "Allows to select which tracking icons (like Mailbox, Repair-NPCs) to show on the map and minimap.",
                        width = "third",
                        align = "CENTER",
                        enabled = _IsEnabled,
                        func = function()
                            QuestieMenu:ShowTownsfolk(1)
                        end,
                    },
                    professionOptions = {
                        type = "button",
                        order = 2.32,
                        title = "Profession Trainers",
                        btnLabel = "Profession Trainers",
                        tooltip = "Allows to select which profession trainers to show on the map and minimap.",
                        width = "third",
                        align = "CENTER",
                        enabled = _IsEnabled,
                        func = function()
                            QuestieMenu:ShowProfessions(1)
                        end,
                    },
                    vendorOptions = {
                        type = "button",
                        order = 2.33,
                        title = "Vendors",
                        btnLabel = "Vendors",
                        tooltip = "Allows to select which vendors to show on the map and minimap.",
                        width = "third",
                        align = "CENTER",
                        enabled = _IsEnabled,
                        func = function()
                            QuestieMenu:ShowVendors(1)
                        end,
                    },
                },
            },
            map_settings_group = {
                type = "container",
                order = 3,
                title = "Map Options",
                enabled = _IsEnabled,
                items = {
                    enableMapToggle = {
                        type = "checkbox",
                        order = 3.1,
                        title = "Enable Map Icons",
                        description = "Show/hide all icons from the main map.",
                        width = "full",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.enableMapIcons end,
                        set = function(_, value)
                            Questie.db.profile.enableMapIcons = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    alwaysGlowMap = {
                        type = "checkbox",
                        order = 3.2,
                        title = "Map Icons Glow",
                        tooltip = "Draw a glow texture behind map icons, colored unique to each quest.",
                        width = "half",
                        enabled = _IsMapEnabled,
                        get = function() return Questie.db.profile.alwaysGlowMap end,
                        set = function(_, value)
                            Questie.db.profile.alwaysGlowMap = value
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateGlowConfig(false, value)
                        end,
                    },
                    questObjectiveColors = {
                        type = "checkbox",
                        order = 3.3,
                        title = "Unique Map Icon Colors",
                        tooltip = "Show map icons with colors that are randomly generated based on quest ID.",
                        width = "half",
                        enabled = _IsMapEnabled,
                        get = function() return Questie.db.profile.questObjectiveColors end,
                        set = function(_, value)
                            Questie.db.profile.questObjectiveColors = value
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateColorConfig(false, value)
                        end,
                    },
                    hideUnexploredMapIconsToggle = {
                        type = "checkbox",
                        order = 3.4,
                        title = "Hide Icons in Unexplored Areas",
                        tooltip = "Hide icons in unexplored map regions.",
                        width = "half",
                        enabled = _IsMapEnabled,
                        get = function() return Questie.db.profile.hideUnexploredMapIcons end,
                        set = function(_, value)
                            Questie.db.profile.hideUnexploredMapIcons = value
                            QuestieQuest:ToggleNotes(not value)
                        end,
                    },
                    hideIconsOnContinents = {
                        type = "checkbox",
                        order = 3.5,
                        title = "Hide Icons on Continent Map",
                        tooltip = "Hide icons on the continent map, when not viewing a specific zone.",
                        width = "half",
                        enabled = _IsMapEnabled,
                        get = function() return Questie.db.profile.hideIconsOnContinents end,
                        set = function(_, value)
                            Questie.db.profile.hideIconsOnContinents = value
                            QuestieQuest:SmoothReset()
                        end,
                    },
                },
            },
            minimap_settings_group = {
                type = "container",
                order = 4,
                title = "Minimap Options",
                enabled = _IsEnabled,
                items = {
                    enableMiniMapToggle = {
                        type = "checkbox",
                        order = 4.1,
                        title = "Enable Minimap Icons",
                        description = "Show/hide all icons from the minimap.",
                        width = "full",
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.enableMiniMapIcons end,
                        set = function(_, value)
                            Questie.db.profile.enableMiniMapIcons = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    alwaysGlowMinimap = {
                        type = "checkbox",
                        order = 4.2,
                        title = "Minimap Icons Glow",
                        tooltip = "Draw a glow texture behind minimap icons, colored unique to each quest.",
                        width = "half",
                        enabled = _IsMinimapEnabled,
                        get = function() return Questie.db.profile.alwaysGlowMinimap end,
                        set = function(_, value)
                            Questie.db.profile.alwaysGlowMinimap = value
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateGlowConfig(true, value)
                        end,
                    },
                    questMinimapObjectiveColors = {
                        type = "checkbox",
                        order = 4.3,
                        title = "Unique Minimap Icon Colors",
                        tooltip = "Show minimap icons with colors that are randomly generated based on quest ID.",
                        width = "half",
                        enabled = _IsMinimapEnabled,
                        get = function() return Questie.db.profile.questMinimapObjectiveColors end,
                        set = function(_, value)
                            Questie.db.profile.questMinimapObjectiveColors = value
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateColorConfig(true, value)
                        end,
                    },
                    fadeLevel = {
                        type = "slider",
                        order = 4.4,
                        title = "Minimap Icon Fade Distance",
                        tooltip = { "How much objective icons should fade depending on distance.\n(Default: %s)", optionsDefaults.profile.fadeLevel },
                        width = "full",
                        min = 10,
                        max = 100,
                        step = 1,
                        enabled = _IsMinimapEnabled,
                        get = function() return Questie.db.profile.fadeLevel end,
                        set = function(_, value)
                            Questie.db.profile.fadeLevel = value
                        end,
                    },
                    fadeOverPlayer = {
                        type = "checkbox",
                        order = 4.5,
                        title = "Fade Icons over Player",
                        tooltip = "Fades icons on the minimap when your player walks near them.",
                        width = "full",
                        enabled = _IsMinimapEnabled,
                        get = function() return Questie.db.profile.fadeOverPlayer end,
                        set = function(_, value)
                            Questie.db.profile.fadeOverPlayer = value
                        end,
                    },
                    fadeOverPlayerDistance = {
                        type = "slider",
                        order = 4.6,
                        title = "Fade over Player Distance",
                        tooltip = { "How far from player should icons start to fade.\n(Default: %s)", optionsDefaults.profile.fadeOverPlayerDistance },
                        width = "half",
                        min = 0,
                        max = 20,
                        step = 0.5,
                        enabled = function() return _IsMinimapEnabled() and Questie.db.profile.fadeOverPlayer end,
                        get = function() return Questie.db.profile.fadeOverPlayerDistance end,
                        set = function(_, value)
                            Questie.db.profile.fadeOverPlayerDistance = value
                        end,
                    },
                    fadeOverPlayerLevel = {
                        type = "slider",
                        order = 4.7,
                        title = "Fade over Player Amount",
                        tooltip = { "How much should the icons around the player fade.\n(Default: %s)", optionsDefaults.profile.fadeOverPlayerLevel },
                        width = "half",
                        min = 0.1,
                        max = 1,
                        step = 0.1,
                        enabled = function() return _IsMinimapEnabled() and Questie.db.profile.fadeOverPlayer end,
                        get = function() return Questie.db.profile.fadeOverPlayerLevel end,
                        set = function(_, value)
                            Questie.db.profile.fadeOverPlayerLevel = value
                        end,
                    },
                },
            },
            icon_scales_group = {
                type = "container",
                order = 5,
                title = "Icon Scales",
                enabled = _IsEnabled,
                items = {
                    globalScale = {
                        type = "slider",
                        order = 5.1,
                        title = "Map Icons",
                        tooltip = { "How large the map icons are.\n(Default: %s)", optionsDefaults.profile.globalScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.globalScale end,
                        set = function(_, value)
                            Questie.db.profile.globalScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                    globalMiniMapScale = {
                        type = "slider",
                        order = 5.2,
                        title = "Minimap Icons",
                        tooltip = { "How large the minimap icons are.\n(Default: %s)", optionsDefaults.profile.globalMiniMapScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.globalMiniMapScale end,
                        set = function(_, value)
                            Questie.db.profile.globalMiniMapScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                    globalTownsfolkScale = {
                        type = "slider",
                        order = 5.3,
                        title = "Townsfolk Icons",
                        tooltip = { "How large the townsfolk map icons are.\n(Default: %s)", optionsDefaults.profile.globalTownsfolkScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.globalTownsfolkScale end,
                        set = function(_, value)
                            Questie.db.profile.globalTownsfolkScale = value
                            QuestieMap:RescaleTownsfolkIcons()
                        end,
                    },
                    globalMiniMapTownsfolkScale = {
                        type = "slider",
                        order = 5.4,
                        title = "Minimap Townsfolk Icons",
                        tooltip = { "How large the townsfolk minimap icons are.\n(Default: %s)", optionsDefaults.profile.globalMiniMapTownsfolkScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.globalMiniMapTownsfolkScale end,
                        set = function(_, value)
                            Questie.db.profile.globalMiniMapTownsfolkScale = value
                            QuestieMap:RescaleTownsfolkIcons()
                        end,
                    },
                    availableScale = {
                        type = "slider",
                        order = 5.5,
                        title = "Quest Icons",
                        tooltip = { "How large the available/complete icons are. Affects both map and minimap icons.\n(Default: %s)", optionsDefaults.profile.availableScale },
                        width = "full",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.availableScale end,
                        set = function(_, value)
                            Questie.db.profile.availableScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                    lootScale = {
                        type = "slider",
                        order = 5.6,
                        title = "Loot objectives",
                        tooltip = { "How large the loot icons are.\n(Default: %s)", optionsDefaults.profile.lootScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.lootScale end,
                        set = function(_, value)
                            Questie.db.profile.lootScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                    monsterScale = {
                        type = "slider",
                        order = 5.7,
                        title = "Slay objectives",
                        tooltip = { "How large the slay icons are.\n(Default: %s)", optionsDefaults.profile.monsterScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.monsterScale end,
                        set = function(_, value)
                            Questie.db.profile.monsterScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                    eventScale = {
                        type = "slider",
                        order = 5.8,
                        title = "Event objectives",
                        tooltip = { "How large the event icons are.\n(Default: %s)", optionsDefaults.profile.eventScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.eventScale end,
                        set = function(_, value)
                            Questie.db.profile.eventScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                    objectScale = {
                        type = "slider",
                        order = 5.9,
                        title = "Object objectives",
                        tooltip = { "How large the object icons are.\n(Default: %s)", optionsDefaults.profile.objectScale },
                        width = "half",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = _IsEnabled,
                        get = function() return Questie.db.profile.objectScale end,
                        set = function(_, value)
                            Questie.db.profile.objectScale = value
                            QuestieMap:RescaleIcons()
                        end,
                    },
                },
            },
            icon_overrides_group = {
                type = "container",
                order = 6,
                title = "Icon Overrides",
                enabled = _IsEnabled,
                items = {
                    overrideObjectivesHeader = {
                        type = "divider",
                        order = 1,
                        title = "Objectives",
                        width = "full",
                    },
                    iconTypeSlay = {
                        type = "dropdown",
                        order = 2,
                        title = "Slay objectives",
                        tooltip = "The icon that is displayed for quest objectives where you need to kill an NPC",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_SLAY) or "slay" end,
                        set = function(key)
                            Questie.db.profile.ICON_SLAY = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeLoot = {
                        type = "dropdown",
                        order = 3,
                        title = "Loot objectives",
                        tooltip = "The icon that is displayed for quest objectives where you need to loot an item",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_LOOT) or "loot" end,
                        set = function(key)
                            Questie.db.profile.ICON_LOOT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeObject = {
                        type = "dropdown",
                        order = 4,
                        title = "Object objectives",
                        tooltip = "The icon that is displayed for quest objectives where you need to interact with an object",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_OBJECT) or "object" end,
                        set = function(key)
                            Questie.db.profile.ICON_OBJECT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeEvent = {
                        type = "dropdown",
                        order = 5,
                        title = "Event objectives",
                        tooltip = "The icon that is displayed for quest objectives where you need to do something in a certain area, like exploring it or casting a spell there",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENT) or "event" end,
                        set = function(key)
                            Questie.db.profile.ICON_EVENT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeTalk = {
                        type = "dropdown",
                        order = 6,
                        title = "Talk objectives",
                        tooltip = "The icon that is displayed for quest objectives where you need to talk to an NPC",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_TALK) or "talk" end,
                        set = function(key)
                            Questie.db.profile.ICON_TALK = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeInteract = {
                        type = "dropdown",
                        order = 7,
                        title = "Interact objectives",
                        tooltip = "The icon that is displayed for quest objectives where you need to use an item or interact with an NPC",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_INTERACT) or "interact" end,
                        set = function(key)
                            Questie.db.profile.ICON_INTERACT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    overrideNormalQuestsHeader = {
                        type = "divider",
                        order = 8,
                        title = "Quests",
                        width = "full",
                    },
                    iconTypeAvailable = {
                        type = "dropdown",
                        order = 9,
                        title = "Available quests",
                        tooltip = "The icon that is displayed for available quests",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_AVAILABLE) or "available" end,
                        set = function(key)
                            Questie.db.profile.ICON_AVAILABLE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeComplete = {
                        type = "dropdown",
                        order = 10,
                        title = "Complete quests",
                        tooltip = "The icon that is displayed for completed quests that can be handed in",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_COMPLETE) or "complete" end,
                        set = function(key)
                            Questie.db.profile.ICON_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeAvailableGray = {
                        type = "dropdown",
                        order = 11,
                        title = "Unavailable and trivial quests",
                        tooltip = "The icon that is displayed for quests that require additional conditions to be met before they can be accepted, or are so low level they don't reward experience",
                        width = "third",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_AVAILABLE_GRAY) or "available_gray" end,
                        set = function(key)
                            Questie.db.profile.ICON_AVAILABLE_GRAY = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeRepeatable = {
                        type = "dropdown",
                        order = 12,
                        title = "Available repeatable quests",
                        tooltip = "The icon that is displayed for available repeatable quests like dailies",
                        width = "half",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_REPEATABLE) or "repeatable" end,
                        set = function(key)
                            Questie.db.profile.ICON_REPEATABLE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeRepeatableComplete = {
                        type = "dropdown",
                        order = 13,
                        title = "Complete repeatable quests",
                        tooltip = "The icon that is displayed for repeatable quests that can be handed in",
                        width = "half",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_REPEATABLE_COMPLETE) or "repeatable_complete" end,
                        set = function(key)
                            Questie.db.profile.ICON_REPEATABLE_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeEventQuest = {
                        type = "dropdown",
                        order = 14,
                        title = "Available event quests",
                        tooltip = "The icon that is displayed for available event quests during holidays",
                        width = "half",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENTQUEST) or "eventquest" end,
                        set = function(key)
                            Questie.db.profile.ICON_EVENTQUEST = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeEventQuestComplete = {
                        type = "dropdown",
                        order = 15,
                        title = "Complete event quests",
                        tooltip = "The icon that is displayed for event quests that can be handed in",
                        width = "half",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENTQUEST_COMPLETE) or "eventquest_complete" end,
                        set = function(key)
                            Questie.db.profile.ICON_EVENTQUEST_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypePVPQuest = {
                        type = "dropdown",
                        order = 16,
                        title = "Available PvP quests",
                        tooltip = "The icon that is displayed for available PvP quests",
                        width = "half",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_PVPQUEST) or "pvpquest" end,
                        set = function(key)
                            Questie.db.profile.ICON_PVPQUEST = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypePVPQuestComplete = {
                        type = "dropdown",
                        order = 17,
                        title = "Complete PvP quests",
                        tooltip = "The icon that is displayed for PvP quests that can be handed in",
                        width = "half",
                        options = _GetIconTypes,
                        sortOrder = _GetIconTypesSort,
                        enabled = _IsEnabled,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_PVPQUEST_COMPLETE) or "pvpquest_complete" end,
                        set = function(key)
                            Questie.db.profile.ICON_PVPQUEST_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                },
            },
        },
    }
end

_GetIconTypes = function()
    return {
        ["slay"] = "|T" .. Questie.icons["slay"] .. ":0|t " .. l10n("Slay"),
        ["loot"] = "|T" .. Questie.icons["loot"] .. ":0|t " .. l10n("Loot"),
        ["node"] = "|T" .. Questie.icons["node"] .. ":0|t " .. l10n("pfQuest/Codex node"),
        ["player"] = "|T" .. Questie.icons["player"] .. ":0|t " .. l10n("Party marker"),
        ["event"] = "|T" .. Questie.icons["event"] .. ":0|t " .. l10n("Event"),
        ["object"] = "|T" .. Questie.icons["object"] .. ":0|t " .. l10n("Object"),
        ["talk"] = "|T" .. Questie.icons["talk"] .. ":0|t " .. l10n("Talk"),
        ["interact"] = "|T" .. Questie.icons["interact"] .. ":0|t " .. l10n("Interact"),
        ["available"] = "|T" .. Questie.icons["available"] .. ":0|t " .. l10n("Available"),
        ["available_gray"] = "|T" .. Questie.icons["available_gray"] .. ":0|t " .. l10n("Available gray"),
        ["complete"] = "|T" .. Questie.icons["complete"] .. ":0|t " .. l10n("Complete"),
        ["incomplete"] = "|T" .. Questie.icons["incomplete"] .. ":0|t " .. l10n("Incomplete"),
        ["repeatable"] = "|T" .. Questie.icons["repeatable"] .. ":0|t " .. l10n("Repeatable"),
        ["repeatable_complete"] = "|T" .. Questie.icons["repeatable_complete"] .. ":0|t " .. l10n("Repeatable Complete"),
        ["eventquest"] = "|T" .. Questie.icons["eventquest"] .. ":0|t " .. l10n("Event Quest"),
        ["eventquest_complete"] = "|T" .. Questie.icons["eventquest_complete"] .. ":0|t " .. l10n("Event Quest Complete"),
        ["pvpquest"] = "|T" .. Questie.icons["pvpquest"] .. ":0|t " .. l10n("PvP Quest"),
        ["pvpquest_complete"] = "|T" .. Questie.icons["pvpquest_complete"] .. ":0|t " .. l10n("PvP Quest Complete"),
        ["fav"] = "|T" .. Questie.icons["fav"] .. ":0|t " .. l10n("Favourite"),
        ["hand"] = "|T" .. Questie.icons["hand"] .. ":0|t " .. l10n("Hand"),
        ["faction_alliance"] = "|T" .. Questie.icons["faction_alliance"] .. ":0|t " .. l10n("Alliance"),
        ["faction_horde"] = "|T" .. Questie.icons["faction_horde"] .. ":0|t " .. l10n("Horde"),
        ["loot_mono"] = "|T" .. Questie.icons["loot_mono"] .. ":0|t " .. l10n("Loot mono"),
        ["node_cut"] = "|T" .. Questie.icons["node_cut"] .. ":0|t " .. l10n("pfQuest/Codex node cut center"),
        ["object_mono"] = "|T" .. Questie.icons["object_mono"] .. ":0|t " .. l10n("Object mono"),
        ["route"] = "|T" .. Questie.icons["route"] .. ":0|t " .. l10n("Route waypoint"),
        ["slay_mono"] = "|T" .. Questie.icons["slay_mono"] .. ":0|t " .. l10n("Slay mono"),
        ["startend"] = "|T" .. Questie.icons["startend"] .. ":0|t " .. l10n("Start and end"),
        ["startendstart"] = "|T" .. Questie.icons["startendstart"] .. ":0|t " .. l10n("Start and unfinished"),
        ["tracker_clean"] = "|T" .. Questie.icons["tracker_clean"] .. ":0|t " .. l10n("Clean"),
        ["tracker_close"] = "|T" .. Questie.icons["tracker_close"] .. ":0|t " .. CLOSE,
        ["tracker_database"] = "|T" .. Questie.icons["tracker_database"] .. ":0|t " .. l10n("Pin"),
        ["tracker_giver"] = "|T" .. Questie.icons["tracker_giver"] .. ":0|t " .. l10n("Available white"),
        ["tracker_quests"] = "|T" .. Questie.icons["tracker_quests"] .. ":0|t " .. l10n("Book"),
        ["tracker_search"] = "|T" .. Questie.icons["tracker_search"] .. ":0|t " .. l10n("Search"),
        ["tracker_settings"] = "|T" .. Questie.icons["tracker_settings"] .. ":0|t " .. SETTINGS,
    }
end

_GetIconTypesSort = function()
    return {
        "slay",
        "slay_mono",
        "loot",
        "loot_mono",
        "object",
        "object_mono",
        "event",
        "talk",
        "interact",
        "available",
        "available_gray",
        "incomplete",
        "complete",
        "repeatable",
        "repeatable_complete",
        "eventquest",
        "eventquest_complete",
        "pvpquest",
        "pvpquest_complete",
        "startend",
        "startendstart",
        "node",
        "node_cut",
        "route",
        "player",
        "fav",
        "hand",
        "faction_alliance",
        "faction_horde",
        "tracker_clean",
        "tracker_close",
        "tracker_database",
        "tracker_giver",
        "tracker_quests",
        "tracker_search",
        "tracker_settings",
    }
end

_GetIconThemes = function()
    if Expansions.Current >= Expansions.Wotlk then
        return {
            ["questie"] = "|T" .. Questie.icons["slay"] .. ":14|t Questie",
            ["blizzard"] = "|TInterface/buttons/adventureguidemicrobuttonalert.blp:20:20:0:0:32:32:2:28:2:28|t Blizzard",
            ["pfquest"] = "|T" .. Questie.icons["node"] .. ":14|t pfQuest",
            ["custom"] = "|T" .. Questie.icons["object"] .. ":16|t " .. l10n("Custom"),
        }
    else
        return {
            ["questie"] = "|T" .. Questie.icons["complete"] .. ":14|t Questie",
            ["pfquest"] = "|T" .. Questie.icons["node"] .. ":14|t pfQuest",
            ["custom"] = "|T" .. Questie.icons["object"] .. ":16|t " .. l10n("Custom"),
        }
    end
end

_GetIconThemesSort = function()
    if Expansions.Current >= Expansions.Wotlk then
        return {
            "questie",
            "blizzard",
            "pfquest",
            "custom",
        }
    else
        return {
            "questie",
            "pfquest",
            "custom",
        }
    end
end

function QuestieOptionsUtils.SetPfQuestIcons(info, value)
    Questie.db.profile.usePfQuestIcons = value
    if value then
        Questie.db.profile.ICON_SLAY = Questie.icons["node"]
        Questie.db.profile.ICON_LOOT = Questie.icons["node"]
        Questie.db.profile.ICON_EVENT = Questie.icons["node"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["node"]
        Questie.db.profile.ICON_TALK = Questie.icons["node"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["node"]
        Questie.db.profile.questObjectiveColors = true
        Questie.db.profile.alwaysGlowMap = false
        Questie.db.profile.questMinimapObjectiveColors = true
        Questie.db.profile.alwaysGlowMinimap = false
        Questie.db.profile.objectiveFilterDistance = 0
    else
        Questie.db.profile.ICON_SLAY = Questie.icons["slay"]
        Questie.db.profile.ICON_LOOT = Questie.icons["loot"]
        Questie.db.profile.ICON_EVENT = Questie.icons["event"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["object"]
        Questie.db.profile.ICON_TALK = Questie.icons["talk"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["interact"]
        Questie.db.profile.questObjectiveColors = false
        Questie.db.profile.alwaysGlowMap = true
        Questie.db.profile.questMinimapObjectiveColors = false
        Questie.db.profile.alwaysGlowMinimap = false
        Questie.db.profile.objectiveFilterDistance = optionsDefaults.profile.objectiveFilterDistance
    end
    Questie:SetIcons()
    QuestieQuest:SmoothReset()
end

function QuestieOptionsUtils.DetermineTheme()
    if (GetCVar("questPOI") == "1" and Questie.db.profile.enableObjectives == false) then
        Questie.db.profile.iconTheme = "blizzard"
    else
        if (Questie.db.profile.enableObjectives == true and
                Questie.db.profile.ICON_SLAY == Questie.icons["node"] and
                Questie.db.profile.ICON_LOOT == Questie.icons["node"] and
                Questie.db.profile.ICON_EVENT == Questie.icons["node"] and
                Questie.db.profile.ICON_OBJECT == Questie.icons["node"] and
                Questie.db.profile.ICON_TALK == Questie.icons["node"] and
                Questie.db.profile.ICON_INTERACT == Questie.icons["node"] and
                Questie.db.profile.questObjectiveColors == true and
                Questie.db.profile.alwaysGlowMap == false and
                Questie.db.profile.questMinimapObjectiveColors == true and
                Questie.db.profile.alwaysGlowMinimap == false and
                Questie.db.profile.objectiveFilterDistance == 2)
        then
            Questie.db.profile.iconTheme = "pfquest"
        elseif (Questie.db.profile.enableObjectives == true and
                Questie.db.profile.ICON_SLAY == Questie.icons["slay"] and
                Questie.db.profile.ICON_LOOT == Questie.icons["loot"] and
                Questie.db.profile.ICON_EVENT == Questie.icons["event"] and
                Questie.db.profile.ICON_OBJECT == Questie.icons["object"] and
                Questie.db.profile.ICON_TALK == Questie.icons["talk"] and
                Questie.db.profile.ICON_INTERACT == Questie.icons["interact"] and
                Questie.db.profile.questObjectiveColors == optionsDefaults.profile.questObjectiveColors and
                Questie.db.profile.alwaysGlowMap == optionsDefaults.profile.alwaysGlowMap and
                Questie.db.profile.questMinimapObjectiveColors == optionsDefaults.profile.questMinimapObjectiveColors and
                Questie.db.profile.alwaysGlowMinimap == optionsDefaults.profile.alwaysGlowMinimap and
                Questie.db.profile.objectiveFilterDistance == optionsDefaults.profile.objectiveFilterDistance)
        then
            Questie.db.profile.iconTheme = "questie"
        else
            Questie.db.profile.iconTheme = "custom"
        end
    end
end

function QuestieOptionsUtils.ExecuteTheme(info, value)
    Questie.db.profile.iconTheme = value
    if value == "questie" then
        if GetCVar("questPOI") then
            SetCVar("questPOI", "0")
        end
        if WorldMapQuestShowObjectives then
            WorldMapQuestShowObjectives:SetChecked(false)
        end
        Questie.db.profile.enableObjectives = true
        Questie.db.profile.ICON_SLAY = Questie.icons["slay"]
        Questie.db.profile.ICON_LOOT = Questie.icons["loot"]
        Questie.db.profile.ICON_EVENT = Questie.icons["event"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["object"]
        Questie.db.profile.ICON_TALK = Questie.icons["talk"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["interact"]
        Questie.db.profile.questObjectiveColors = optionsDefaults.profile.questObjectiveColors
        Questie.db.profile.alwaysGlowMap = optionsDefaults.profile.alwaysGlowMap
        Questie.db.profile.questMinimapObjectiveColors = optionsDefaults.profile.questMinimapObjectiveColors
        Questie.db.profile.alwaysGlowMinimap = optionsDefaults.profile.alwaysGlowMinimap
        Questie.db.profile.objectiveFilterDistance = optionsDefaults.profile.objectiveFilterDistance
    elseif value == "pfquest" then
        if GetCVar("questPOI") then
            SetCVar("questPOI", "0")
        end
        if WorldMapQuestShowObjectives then
            WorldMapQuestShowObjectives:SetChecked(false)
        end
        Questie.db.profile.enableObjectives = true
        Questie.db.profile.ICON_SLAY = Questie.icons["node"]
        Questie.db.profile.ICON_LOOT = Questie.icons["node"]
        Questie.db.profile.ICON_EVENT = Questie.icons["node"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["node"]
        Questie.db.profile.ICON_TALK = Questie.icons["node"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["node"]
        Questie.db.profile.questObjectiveColors = true
        Questie.db.profile.alwaysGlowMap = false
        Questie.db.profile.questMinimapObjectiveColors = true
        Questie.db.profile.alwaysGlowMinimap = false
        Questie.db.profile.objectiveFilterDistance = 2
    elseif value == "blizzard" then
        if GetCVar("questPOI") then
            SetCVar("questPOI", "1")
        end
        if WorldMapQuestShowObjectives then
            WorldMapQuestShowObjectives:SetChecked(false)
        end
        Questie.db.profile.enableObjectives = false
        Questie.db.profile.ICON_SLAY = Questie.icons["slay"]
        Questie.db.profile.ICON_LOOT = Questie.icons["loot"]
        Questie.db.profile.ICON_EVENT = Questie.icons["event"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["object"]
        Questie.db.profile.ICON_TALK = Questie.icons["talk"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["interact"]
        Questie.db.profile.questObjectiveColors = optionsDefaults.profile.questObjectiveColors
        Questie.db.profile.alwaysGlowMap = optionsDefaults.profile.alwaysGlowMap
        Questie.db.profile.questMinimapObjectiveColors = optionsDefaults.profile.questMinimapObjectiveColors
        Questie.db.profile.alwaysGlowMinimap = optionsDefaults.profile.alwaysGlowMinimap
        Questie.db.profile.objectiveFilterDistance = optionsDefaults.profile.objectiveFilterDistance
    elseif value == "custom" then
        return
    end
    Questie:SetIcons()
    QuestieQuest:SmoothReset()
end