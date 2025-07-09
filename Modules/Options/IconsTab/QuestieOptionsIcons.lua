---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu");
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

QuestieOptions.tabs.icons = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetIconTypes
local _GetIconTypesSort
local _GetIconThemes
local _GetIconThemesSort

function QuestieOptions.tabs.icons:Initialize()
    return {
        name = function() return l10n("Icons"); end,
        type = "group",
        order = 2,
        args = {
            icon_options = {
                type = "header",
                order = 1,
                width = "normal",
                name = function() return l10n("Icon Options"); end,
            },
            iconsSpacer = {
                type = "description",
                order = 1.01,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.06,
                width = 0.06,
                func = function() end,
            },
            show_icons = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n("Enable Icons"); end,
                desc = function() return l10n("Shows or hides the icons that Questie draws on the world map and minimap."); end,
                descStyle = "inline",
                width = 1.595,
                get = function() return Questie.db.profile.enabled; end,
                set = function(info, value)
                    Questie.db.profile.enabled = value
                    QuestieQuest:ToggleNotes(value);
                end,
            },
            themeSpacer = {
                type = "description",
                order = 1.11,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.3,
                width = 0.3,
                func = function() end,
            },
            iconThemePicker = {
                type = "select",
                order = 1.2,
                values = _GetIconThemes,
                sorting = _GetIconThemesSort(),
                style = "dropdown",
                width = 1,
                disabled = function() return (not Questie.db.profile.enabled); end,
                name = function() return l10n("Objective Icon Theme") end,
                desc = function() return l10n("Change between themes for objective icons."); end,
                get = function() return Questie.db.profile.iconTheme; end,
                set = function(info, value) QuestieOptionsUtils.ExecuteTheme(info, value) end,
            },
            themeSpacerPost = {
                type = "description",
                order = 1.21,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.35,
                width = 0.35,
                func = function() end,
            },
            untrackedSpacer = {
                type = "description",
                order = 1.22,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.06,
                width = 0.06,
                func = function() end,
            },
            hideMapIconsForUntrackedToggle = {
                type = "toggle",
                order = 1.3,
                name = function() return l10n("Hide icons of untracked quests"); end,
                desc = function() return l10n("Hide icons for quests that are not tracked."); end,
                width = 1.6,
                disabled = function() return (not Questie.db.profile.enabled); end,
                get = function() return Questie.db.profile.hideUntrackedQuestsMapIcons; end,
                set = function(info, value)
                    Questie.db.profile.hideUntrackedQuestsMapIcons = value
                    QuestieQuest:ToggleNotes(not value)

                    -- Hides tooltips for untracked quests
                    if value == true then
                        for questId, quest in pairs(QuestiePlayer.currentQuestlog) do
                            if not QuestieQuest:ShouldShowQuestNotes(quest.Id) then
                                QuestieTooltips:RemoveQuest(quest.Id)
                            end
                        end
                    end

                    -- Readds tooltips from all missing quests
                    if value == false then
                        for questId, quest in pairs(QuestiePlayer.currentQuestlog) do
                            QuestieQuest:PopulateObjectiveNotes(quest)
                        end
                    end
                end,
            },
            icon_toggles_group = {
                type = "group",
                order = 2,
                inline = true,
                width = 0.5,
                name = function() return l10n("Show icons for..."); end,
                disabled = function() return not Questie.db.profile.enabled end,
                args = {
                    quest_options = {
                        type = "header",
                        order = 2,
                        width = "normal",
                        name = function() return l10n("Quests"); end,
                    },
                    showNormalQuests = {
                        type = "toggle",
                        order = 2.01,
                        name = function() return l10n("Available Normal Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of available quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableAvailable; end,
                        set = function(info, value)
                            Questie.db.profile.enableAvailable = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showItemQuests = {
                        type = "toggle",
                        order = 2.011,
                        name = function() return l10n("Available Quests from Items"); end,
                        desc = function() return l10n("When this is enabled, the locations of item drops that start quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableAvailableItems; end,
                        set = function(info, value)
                            Questie.db.profile.enableAvailableItems = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showEventQuests = {
                        type = "toggle",
                        order = 2.02,
                        name = function() return l10n("Available Event Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of active event quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showEventQuests end,
                        set = function(info, value)
                            Questie.db.profile.showEventQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showRepeatableQuests = {
                        type = "toggle",
                        order = 2.03,
                        name = function() return l10n("Available Repeatable Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of repeatable quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showRepeatableQuests end,
                        set = function(info, value)
                            Questie.db.profile.showRepeatableQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showPvPQuests = {
                        type = "toggle",
                        order = 2.04,
                        name = function() return l10n("Available PvP Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of PvP quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showPvPQuests end,
                        set = function(info, value)
                            Questie.db.profile.showPvPQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showDungeonQuests = {
                        type = "toggle",
                        order = 2.05,
                        name = function() return l10n("Available Dungeon Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of dungeon quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showDungeonQuests end,
                        set = function(info, value)
                            Questie.db.profile.showDungeonQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showRaidQuests = {
                        type = "toggle",
                        order = 2.06,
                        name = function() return l10n("Available Raid Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of raid quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showRaidQuests end,
                        set = function(info, value)
                            Questie.db.profile.showRaidQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showCompleteQuests = {
                        type = "toggle",
                        order = 2.07,
                        name = function() return l10n("Completed Quests"); end,
                        desc = function() return l10n("When this is enabled, the quest turn-in locations will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableTurnins; end,
                        set = function(info, value)
                            Questie.db.profile.enableTurnins = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    showObjectivesToggle = {
                        type = "toggle",
                        order = 2.08,
                        name = function() return l10n("Objectives"); end,
                        desc = function() return l10n("When this is enabled, quest objective icons will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableObjectives; end,
                        set = function(info, value)
                            Questie.db.profile.enableObjectives = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieOptionsUtils.DetermineTheme()
                        end,
                    },
                    showAQWarEffortQuests = {
                        type = "toggle",
                        order = 2.09,
                        hidden = (not Questie.IsClassic),
                        name = function() return l10n("Available AQ War Effort Quests"); end,
                        desc = function() return l10n("When this is enabled, the locations of the AQ War Effort quests will be shown on the map/minimap."); end,
                        width = 1.595,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showAQWarEffortQuests end,
                        set = function(info, value)
                            Questie.db.profile.showAQWarEffortQuests = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    sod_rune_options = {
                        type = "header",
                        order = 2.091,
                        width = "normal",
                        hidden = (not Questie.IsSoD),
                        name = function() return l10n("Season of Discovery Runes"); end,
                    },
                    showSoDRunes = {
                        type = "toggle",
                        order = 2.092,
                        hidden = (not Questie.IsSoD),
                        name = function() return l10n("Show Runes"); end,
                        desc = function() return l10n("When this is enabled, the locations of Season of Discovery Runes and Rune quests will be shown on the map/minimap."); end,
                        width = "full",
                        disabled = function()
                            return (not Questie.db.profile.enabled);
                            end,
                        get = function(info) return Questie.db.profile.showSoDRunes end,
                        set = function(info, value)
                            Questie.db.profile.showSoDRunes = value
                            QuestieQuest.ToggleAvailableQuests(value)
                        end,
                    },
                    sodRuneSelection = {
                        type = "group",
                        order = 2.093,
                        name = "",
                        hidden = (not Questie.IsSoD),
                        disabled = function() return not Questie.db.profile.showSoDRunes end,
                        args = {
                            phase1 = {
                                type = "toggle",
                                name = l10n("Phase 1"),
                                get = function() return Questie.db.profile.showRunesOfPhase.phase1; end,
                                set = function(info, value)
                                    Questie.db.profile.showRunesOfPhase.phase1 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                            phase2 = {
                                type = "toggle",
                                name = l10n("Phase 2"),
                                get = function() return Questie.db.profile.showRunesOfPhase.phase2; end,
                                set = function(info, value)
                                    Questie.db.profile.showRunesOfPhase.phase2 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                            phase3 = {
                                type = "toggle",
                                name = l10n("Phase 3"),
                                get = function() return Questie.db.profile.showRunesOfPhase.phase3; end,
                                set = function(info, value)
                                    Questie.db.profile.showRunesOfPhase.phase3 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                            phase4 = {
                                type = "toggle",
                                name = l10n("Phase 4"),
                                get = function() return Questie.db.profile.showRunesOfPhase.phase4; end,
                                set = function(info, value)
                                    Questie.db.profile.showRunesOfPhase.phase4 = value
                                    QuestieQuest.ToggleAvailableQuests(value)
                                end,
                            },
                        },
                    },
                    townsfolk_options = {
                        type = "header",
                        order = 2.10,
                        width = "normal",
                        name = function() return l10n("Other Icons"); end,
                    },
                    townsfolkSpacer1 = {
                        type = "description",
                        order = 2.11,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.32,
                        width = 0.32,
                        func = function() end,
                    },
                    townsfolkOptions = {
                        type = "execute",
                        order = 2.12,
                        name = function() return l10n("Townsfolk"); end,
                        desc = function() return l10n("Allows to select which tracking icons (like Mailbox, Repair-NPCs) to show on the map and minimap."); end,
                        width = 0.8,
                        disabled = false,
                        func = function(info, value)
                            QuestieMenu:ShowTownsfolk(1)
                        end
                    },
                    professionOptions = {
                        type = "execute",
                        order = 2.13,
                        name = function() return l10n("Profession Trainers"); end,
                        desc = function() return l10n("Allows to select which profession trainers to show on the map and minimap."); end,
                        width = 0.95,
                        disabled = false,
                        func = function(info, value)
                            QuestieMenu:ShowProfessions(1)
                        end
                    },
                    vendorOptions = {
                        type = "execute",
                        order = 2.14,
                        name = function() return l10n("Vendors"); end,
                        desc = function() return l10n("Allows to select which vendors to show on the map and minimap."); end,
                        width = 0.8,
                        disabled = false,
                        func = function(info, value)
                            QuestieMenu:ShowVendors(1)
                        end
                    },
                },
            },
            map_settings_group = {
                type = "group",
                order = 3,
                inline = true,
                width = 0.5,
                name = function() return l10n("Map Options"); end,
                args = {
                    enableMapToggle = {
                        type = "toggle",
                        order = 3.1,
                        name = function() return l10n("Enable Map Icons"); end,
                        desc = function() return l10n("Show/hide all icons from the main map."); end,
                        descStyle = "inline",
                        width = 3.1,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableMapIcons; end,
                        set = function(info, value)
                            Questie.db.profile.enableMapIcons = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    alwaysGlowMap = {
                        type = "toggle",
                        order = 3.2,
                        name = function() return l10n("Map Icons Glow"); end,
                        desc = function() return l10n("Draw a glow texture behind map icons, colored unique to each quest."); end,
                        width = 1.595,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateGlowConfig(false, value)
                        end,
                    },
                    questObjectiveColors = {
                        type = "toggle",
                        order = 3.3,
                        name = function() return l10n("Unique Map Icon Colors"); end,
                        desc = function() return l10n("Show map icons with colors that are randomly generated based on quest ID."); end,
                        width = 1.595,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateColorConfig(false, value)
                        end,
                    },
                    hideUnexploredMapIconsToggle = {
                        type = "toggle",
                        order = 3.4,
                        name = function() return l10n("Hide Icons in Unexplored Areas"); end,
                        desc = function() return l10n("Hide icons in unexplored map regions."); end,
                        width = 1.595,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function() return Questie.db.profile.hideUnexploredMapIcons; end,
                        set = function(info, value)
                            Questie.db.profile.hideUnexploredMapIcons = value
                            QuestieQuest:ToggleNotes(not value)
                        end,
                    },
                    hideIconsOnContinents = {
                        type = "toggle",
                        order = 3.5,
                        name = function() return l10n("Hide Icons on Continent Map"); end,
                        desc = function() return l10n("Hide icons on the continent map, when not viewing a specific zone."); end,
                        width = 1.595,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function() return Questie.db.profile.hideIconsOnContinents; end,
                        set = function(info, value)
                            Questie.db.profile.hideIconsOnContinents = value
                            QuestieQuest:SmoothReset()
                        end,
                    },
                },
            },
            minimap_settings_group = {
                type = "group",
                order = 4,
                inline = true,
                width = 0.5,
                name = function() return l10n("Minimap Options"); end,
                disabled = function() return not Questie.db.profile.enabled end,
                args = {
                    enableMiniMapToggle = {
                        type = "toggle",
                        order = 4.1,
                        name = function() return l10n("Enable Minimap Icons"); end,
                        desc = function() return l10n("Show/hide all icons from the minimap."); end,
                        descStyle = "inline",
                        width = 3.1,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableMiniMapIcons; end,
                        set = function(info, value)
                            Questie.db.profile.enableMiniMapIcons = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    alwaysGlowMinimap = {
                        type = "toggle",
                        order = 4.2,
                        name = function() return l10n("Minimap Icons Glow"); end,
                        desc = function() return l10n("Draw a glow texture behind minimap icons, colored unique to each quest."); end,
                        width = 1.595,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateGlowConfig(true, value)
                        end,
                    },
                    questMinimapObjectiveColors = {
                        type = "toggle",
                        order = 4.3,
                        name = function() return l10n("Unique Minimap Icon Colors"); end,
                        desc = function() return l10n("Show minimap icons with colors that are randomly generated based on quest ID."); end,
                        width = 1.595,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieOptionsUtils.DetermineTheme()
                            QuestieFramePool:UpdateColorConfig(true, value)
                        end,
                    },
                    fadeLevel = {
                        type = "range",
                        order = 4.4,
                        name = function() return l10n("Minimap Icon Fade Distance"); end,
                        desc = function() return l10n("How much objective icons should fade depending on distance.\n(Default: %s)", optionsDefaults.profile.fadeLevel); end,
                        width = 3.1,
                        min = 10,
                        max = 100,
                        step = 1,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    fadeOverPlayer = {
                        type = "toggle",
                        order = 4.5,
                        name = function() return l10n("Fade Icons over Player"); end,
                        desc = function() return l10n("Fades icons on the minimap when your player walks near them."); end,
                        width = "full",
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    fadeOverPlayerDistance = {
                        type = "range",
                        order = 4.6,
                        name = function() return l10n("Fade over Player Distance"); end,
                        desc = function() return l10n("How far from player should icons start to fade.\n(Default: %s)", optionsDefaults.profile.fadeOverPlayerDistance); end,
                        width = 1.55,
                        min = 0,
                        max = 20,
                        step = 0.5,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons) or (not Questie.db.profile.fadeOverPlayer)); end,
                        --disabled = function() return (not Questie.db.profile.fadeOverPlayer); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    fadeOverPlayerLevel = {
                        type = "range",
                        order = 4.7,
                        name = function() return l10n("Fade over Player Amount"); end,
                        desc = function() return l10n("How much should the icons around the player fade.\n(Default: %s)", optionsDefaults.profile.fadeOverPlayerLevel); end,
                        width = 1.55,
                        min = 0.1,
                        max = 1,
                        step = 0.1,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons) or (not Questie.db.profile.fadeOverPlayer)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                },
            },
            icon_scales_group = {
                type = "group",
                order = 5,
                inline = true,
                width = 0.5,
                name = function() return l10n("Icon Scales"); end,
                disabled = function() return not Questie.db.profile.enabled end,
                args = {
                    globalScale = {
                        type = "range",
                        order = 5.1,
                        name = function() return l10n("Map Icons"); end,
                        desc = function() return l10n("How large the map icons are.\n(Default: %s)", optionsDefaults.profile.globalScale); end,
                        width = 1.55,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    globalMiniMapScale = {
                        type = "range",
                        order = 5.2,
                        name = function() return l10n("Minimap Icons"); end,
                        desc = function() return l10n("How large the minimap icons are.\n(Default: %s)", optionsDefaults.profile.globalMiniMapScale); end,
                        width = 1.55,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    spacer_scale = QuestieOptionsUtils:Spacer(5.3),
                    availableScale = {
                        type = "range",
                        order = 5.4,
                        name = function() return l10n("Quest Icons"); end,
                        desc = function() return l10n("How large the available/complete icons are. Affects both map and minimap icons.\n(Default: %s)", optionsDefaults.profile.availableScale); end,
                        width = 3.1,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    lootScale = {
                        type = "range",
                        order = 5.5,
                        name = function() return l10n("Loot objectives"); end,
                        desc = function() return l10n("How large the loot icons are.\n(Default: %s)", optionsDefaults.profile.lootScale); end,
                        width = 1.55,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    monsterScale = {
                        type = "range",
                        order = 5.6,
                        name = function() return l10n("Slay objectives"); end,
                        desc = function() return l10n("How large the slay icons are.\n(Default: %s)", optionsDefaults.profile.monsterScale); end,
                        width = 1.55,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    eventScale = {
                        type = "range",
                        order = 5.7,
                        name = function() return l10n("Event objectives"); end,
                        desc = function() return l10n("How large the event icons are.\n(Default: %s)", optionsDefaults.profile.eventScale); end,
                        width = 1.55,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    objectScale = {
                        type = "range",
                        order = 5.8,
                        name = function() return l10n("Object objectives"); end,
                        desc = function() return l10n("How large the object icons are.\n(Default: %s)", optionsDefaults.profile.objectScale); end,
                        width = 1.55,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieMap:RescaleIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                },
            },
            iconOverrides = {
                type = "group",
                order = 16,
                inline = true,
                name = function() return l10n("Icon Overrides") end,
                args = {
                    --usePfQuestIcons = {
                    --    type = "toggle",
                    --    order = 16.1,
                    --    name = function() return l10n("Toggle pfQuest/ClassicCodex icon style"); end,
                    --    desc = function()
                    --        return l10n("Toggles between Questie icon style and pfQuest/ClassicCodex icon style.\n\nToggling affects the following settings:\n\n- Objective icons\n- ")
                    --            .. l10n("Map Icons Glow") .. "\n- "
                    --            .. l10n("Unique Map Icon Colors") .. "\n- "
                    --            .. l10n("Minimap Icons Glow") .. "\n- "
                    --            .. l10n("Unique Minimap Icon Colors") .. "\n- "
                    --            .. l10n("Objective icon cluster amount");
                    --    end,
                    --    width = 3,
                    --    disabled = function() return (not Questie.db.profile.enabled); end,
                    --    get = function(info) return Questie.db.profile.usePfQuestIcons end,
                    --    set = QuestieOptionsUtils.SetPfQuestIcons,
                    --},
                    overrideObjectivesHeader = {
                        type = "header",
                        order = 16.5,
                        name = function() return l10n("Objectives") end,
                    },
                    objectiveSpacer1 = {
                        type = "description",
                        order = 16.9,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeSlay = {
                        type = "select",
                        order = 17,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Slay objectives") end,
                        desc = function() return l10n("The icon that is displayed for quest objectives where you need to kill an NPC"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_SLAY) or "slay"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_SLAY = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    objectiveSpacer2 = {
                        type = "description",
                        order = 17.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeLoot = {
                        type = "select",
                        order = 18,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Loot objectives") end,
                        desc = function() return l10n("The icon that is displayed for quest objectives where you need to loot an item"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_LOOT) or "loot"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_LOOT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    objectiveSpacer3 = {
                        type = "description",
                        order = 18.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeObject = {
                        type = "select",
                        order = 19,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Object objectives") end,
                        desc = function() return l10n("The icon that is displayed for quest objectives where you need to interact with an object"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_OBJECT) or "object"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_OBJECT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeLineBreak = QuestieOptionsUtils:Spacer(19.3,nil,"minimal"),
                    objectiveSpacer4 = {
                        type = "description",
                        order = 19.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeEvent = {
                        type = "select",
                        order = 20,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Event objectives") end,
                        desc = function() return l10n("The icon that is displayed for quest objectives where you need to do something in a certain area, like exploring it or casting a spell there"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENT) or "event"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_EVENT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    objectiveSpacer5 = {
                        type = "description",
                        order = 20.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeTalk = {
                        type = "select",
                        order = 21,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Talk objectives") end,
                        desc = function() return l10n("The icon that is displayed for quest objectives where you need to talk to an NPC"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_TALK) or "talk"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_TALK = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    objectiveSpacer6 = {
                        type = "description",
                        order = 21.1,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeInteract = {
                        type = "select",
                        order = 21.2,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Interact objectives") end,
                        desc = function() return l10n("The icon that is displayed for quest objectives where you need to use an item or interact with an NPC"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_INTERACT) or "interact"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_INTERACT = Questie.icons[key]
                            QuestieOptionsUtils.DetermineTheme()
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    overrideNormalQuestsHeader = {
                        type = "header",
                        order = 22,
                        name = function() return l10n("Quests") end,
                    },
                    questSpacer1 = {
                        type = "description",
                        order = 22.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeAvailable = {
                        type = "select",
                        order = 23,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Available quests") end,
                        desc = function() return l10n("The icon that is displayed for available quests"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_AVAILABLE) or "available"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_AVAILABLE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    questSpacer2 = {
                        type = "description",
                        order = 23.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeComplete = {
                        type = "select",
                        order = 25,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Complete quests") end,
                        desc = function() return l10n("The icon that is displayed for completed quests that can be handed in"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_COMPLETE) or "complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    questSpacer3 = {
                        type = "description",
                        order = 25.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeAvailableGray = {
                        type = "select",
                        order = 26,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 0.796,
                        name = function() return l10n("Unavailable and trivial quests") end,
                        desc = function() return l10n("The icon that is displayed for quests that require additional conditions to be met before they can be accepted, or are so low level they don't reward experience"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_AVAILABLE_GRAY) or "available_gray"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_AVAILABLE_GRAY = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    repeatable_spacer = QuestieOptionsUtils:Spacer(27,nil,"minimal"),
                    repeatableSpacer1 = {
                        type = "description",
                        order = 27.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeRepeatable = {
                        type = "select",
                        order = 28,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 1.295,
                        name = function() return l10n("Available repeatable quests") end,
                        desc = function() return l10n("The icon that is displayed for available repeatable quests like dailies"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_REPEATABLE) or "repeatable"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_REPEATABLE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    repeatableSpacer2 = {
                        type = "description",
                        order = 28.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeRepeatableComplete = {
                        type = "select",
                        order = 29,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 1.295,
                        name = function() return l10n("Complete repeatable quests") end,
                        desc = function() return l10n("The icon that is displayed for repeatable quests that can be handed in"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_REPEATABLE_COMPLETE) or "complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_REPEATABLE_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    event_spacer = QuestieOptionsUtils:Spacer(30,nil,"minimal"),
                    eventSpacer1 = {
                        type = "description",
                        order = 30.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeEventQuest = {
                        type = "select",
                        order = 31,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 1.295,
                        name = function() return l10n("Available event quests") end,
                        desc = function() return l10n("The icon that is displayed for available event quests during holidays"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENTQUEST) or "eventquest"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_EVENTQUEST = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    eventSpacer2 = {
                        type = "description",
                        order = 31.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypeEventQuestComplete = {
                        type = "select",
                        order = 32,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 1.295,
                        name = function() return l10n("Complete event quests") end,
                        desc = function() return l10n("The icon that is displayed for event quests that can be handed in"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENTQUEST_COMPLETE) or "complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_EVENTQUEST_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    pvp_spacer = QuestieOptionsUtils:Spacer(33,nil,"minimal"),
                    pvpSpacer1 = {
                        type = "description",
                        order = 33.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypePVPQuest = {
                        type = "select",
                        order = 34,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 1.295,
                        name = function() return l10n("Available PvP quests") end,
                        desc = function() return l10n("The icon that is displayed for available PvP quests"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_PVPQUEST) or "pvpquest"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_PVPQUEST = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    pvpSpacer2 = {
                        type = "description",
                        order = 34.5,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.2,
                        width = 0.2,
                        func = function() end,
                    },
                    iconTypePVPQuestComplete = {
                        type = "select",
                        order = 35,
                        values = _GetIconTypes,
                        sorting = _GetIconTypesSort(),
                        style = "dropdown",
                        width = 1.295,
                        name = function() return l10n("Complete PvP quests") end,
                        desc = function() return l10n("The icon that is displayed for PvP quests that can be handed in"); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_PVPQUEST_COMPLETE) or "complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
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
        ["slay"] = "|T" .. Questie.icons["slay"] .. ":0|t Slay",
        ["loot"] = "|T" .. Questie.icons["loot"] .. ":0|t Loot",
        ["node"] = "|T" .. Questie.icons["node"] .. ":0|t pfQuest/Codex node",
        ["player"] = "|T" .. Questie.icons["player"] .. ":0|t Party marker",
        ["event"] = "|T" .. Questie.icons["event"] .. ":0|t Event",
        ["object"] = "|T" .. Questie.icons["object"] .. ":0|t Object",
        ["talk"] = "|T" .. Questie.icons["talk"] .. ":0|t Talk",
        ["interact"] = "|T" .. Questie.icons["interact"] .. ":0|t Interact",
        ["available"] = "|T" .. Questie.icons["available"] .. ":0|t Available",
        ["available_gray"] = "|T" .. Questie.icons["available_gray"] .. ":0|t Available gray",
        ["complete"] = "|T" .. Questie.icons["complete"] .. ":0|t Complete",
        ["incomplete"] = "|T" .. Questie.icons["incomplete"] .. ":0|t Incomplete",
        ["repeatable"] = "|T" .. Questie.icons["repeatable"] .. ":0|t Repeatable",
        ["repeatable_complete"] = "|T" .. Questie.icons["repeatable_complete"] .. ":0|t Repeatable Complete",
        ["eventquest"] = "|T" .. Questie.icons["eventquest"] .. ":0|t Event Quest",
        ["eventquest_complete"] = "|T" .. Questie.icons["eventquest_complete"] .. ":0|t Event Quest Complete",
        ["pvpquest"] = "|T" .. Questie.icons["pvpquest"] .. ":0|t PvP Quest",
        ["pvpquest_complete"] = "|T" .. Questie.icons["pvpquest_complete"] .. ":0|t PvP Quest Complete",
        ["fav"] = "|T" .. Questie.icons["fav"] .. ":0|t Favourite",
        ["hand"] = "|T" .. Questie.icons["hand"] .. ":0|t Hand",
        ["faction_alliance"] = "|T" .. Questie.icons["faction_alliance"] .. ":0|t Alliance",
        ["faction_horde"] = "|T" .. Questie.icons["faction_horde"] .. ":0|t Horde",
        ["loot_mono"] = "|T" .. Questie.icons["loot_mono"] .. ":0|t Loot mono",
        ["node_cut"] = "|T" .. Questie.icons["node_cut"] .. ":0|t pfQuest/Codex node cut center",
        ["object_mono"] = "|T" .. Questie.icons["object_mono"] .. ":0|t Object mono",
        ["route"] = "|T" .. Questie.icons["route"] .. ":0|t Route waypoint",
        ["slay_mono"] = "|T" .. Questie.icons["slay_mono"] .. ":0|t Slay mono",
        ["startend"] = "|T" .. Questie.icons["startend"] .. ":0|t Start and end",
        ["startendstart"] = "|T" .. Questie.icons["startendstart"] .. ":0|t Start and unfinished",
        ["tracker_clean"] = "|T" .. Questie.icons["tracker_clean"] .. ":0|t Clean",
        ["tracker_close"] = "|T" .. Questie.icons["tracker_close"] .. ":0|t Close",
        ["tracker_database"] = "|T" .. Questie.icons["tracker_database"] .. ":0|t Pin",
        ["tracker_giver"] = "|T" .. Questie.icons["tracker_giver"] .. ":0|t Available white",
        ["tracker_quests"] = "|T" .. Questie.icons["tracker_quests"] .. ":0|t Book",
        ["tracker_search"] = "|T" .. Questie.icons["tracker_search"] .. ":0|t Search",
        ["tracker_settings"] = "|T" .. Questie.icons["tracker_settings"] .. ":0|t Settings",
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

function QuestieOptionsUtils.SetPfQuestIcons(info, value)
    Questie.db.profile.usePfQuestIcons = value
    if value then
        Questie.db.profile.ICON_SLAY = Questie.icons["node"]
        Questie.db.profile.ICON_LOOT = Questie.icons["node"]
        Questie.db.profile.ICON_EVENT = Questie.icons["node"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["node"]
        Questie.db.profile.ICON_TALK = Questie.icons["node"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["node"]
        -- TODO remove these setting changes once we have a style selection window/frame
        Questie.db.profile.questObjectiveColors = true
        Questie.db.profile.alwaysGlowMap = false
        Questie.db.profile.questMinimapObjectiveColors = true
        Questie.db.profile.alwaysGlowMinimap = false
        Questie.db.profile.clusterLevelHotzone = 1
    else
        Questie.db.profile.ICON_SLAY = Questie.icons["slay"]
        Questie.db.profile.ICON_LOOT = Questie.icons["loot"]
        Questie.db.profile.ICON_EVENT = Questie.icons["event"]
        Questie.db.profile.ICON_OBJECT = Questie.icons["object"]
        Questie.db.profile.ICON_TALK = Questie.icons["talk"]
        Questie.db.profile.ICON_INTERACT = Questie.icons["interact"]
        -- TODO remove these setting changes once we have a style selection window/frame
        Questie.db.profile.questObjectiveColors = false
        Questie.db.profile.alwaysGlowMap = true
        Questie.db.profile.questMinimapObjectiveColors = false
        Questie.db.profile.alwaysGlowMinimap = false
        Questie.db.profile.clusterLevelHotzone = 50
    end
    Questie:SetIcons()
    QuestieQuest:SmoothReset()
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
            Questie.db.profile.clusterLevelHotzone == 1)
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
            Questie.db.profile.clusterLevelHotzone == optionsDefaults.profile.clusterLevelHotzone)
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
        if GetCVar("questPOI") then -- if wotlk objectives available
            SetCVar("questPOI", "0") -- disable them
        end
        if WorldMapQuestShowObjectives then -- if wotlk blizzard objectives button exists
            WorldMapQuestShowObjectives:SetChecked(false) -- uncheck it
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
        Questie.db.profile.clusterLevelHotzone = optionsDefaults.profile.clusterLevelHotzone
    elseif value == "pfquest" then
        if GetCVar("questPOI") then -- if wotlk objectives available
            SetCVar("questPOI", "0") -- disable them
        end
        if WorldMapQuestShowObjectives then -- if wotlk blizzard objectives button exists
            WorldMapQuestShowObjectives:SetChecked(false) -- uncheck it
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
        Questie.db.profile.clusterLevelHotzone = 1
    elseif value == "blizzard" then
        if GetCVar("questPOI") then -- if wotlk objectives available
            SetCVar("questPOI", "1") -- enable them
        end
        if WorldMapQuestShowObjectives then -- if wotlk blizzard objectives button exists
            WorldMapQuestShowObjectives:SetChecked(false) -- check it
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
        Questie.db.profile.clusterLevelHotzone = optionsDefaults.profile.clusterLevelHotzone
    elseif value == "custom" then
        return
    end
    Questie:SetIcons()
    QuestieQuest:SmoothReset()
end
