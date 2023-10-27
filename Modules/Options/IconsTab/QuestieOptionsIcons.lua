---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
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

QuestieOptions.tabs.icons = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetIconTypes
local _GetIconTypesSort
local iconsHidden = true

function QuestieOptions.tabs.icons:Initialize()
    return {
        name = function() return l10n('Icons'); end,
        type = "group",
        order = 12,
        args = {
            icon_options = {
                type = "header",
                order = 1,
                width = "normal",
                name = function() return l10n('Icon Options'); end,
            },
            show_icons = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Enable Icons'); end,
                desc = function() return l10n('Enable or disable Questie icons.'); end,
                width = 1.9,
                get = function() return Questie.db.profile.enabled; end,
                set = function(info, value)
                    Questie.db.profile.enabled = value
                    QuestieQuest:ToggleNotes(value);
                end,
            },
            townfolkOptions = {
                type = "execute",
                order = 1.2,
                name = function() return l10n('Config Tracking Icons'); end,
                desc = function() return l10n('Allows to select which the tracking icons (like Mailbox, Repair-NPCs) to show on the map and minimap.'); end,
                width = 1.4,
                func = function(info, value)
                    QuestieMenu:Show()
                end,
            },
            hideMapIconsForUntrackedToggle = {
                type = "toggle",
                order = 1.3,
                name = function() return l10n('Hide icons of untracked quests'); end,
                desc = function() return l10n('Hide icons for quests that are not tracked.'); end,
                width = 3.3,
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
            showCustomQuestFrameIcons = {
                type = "toggle",
                order = 1.4,
                name = function() return l10n('Show custom quest frame icons'); end,
                desc = function() return l10n('Use custom Questie icons for NPC dialogs, reflecting the status and type of each quest.'); end,
                width = 1.9,
                get = function() return Questie.db.profile.enableQuestFrameIcons; end,
                set = function(info, value)
                    Questie.db.profile.enableQuestFrameIcons = value
                end,
            },
            clusterLevelHotzone = {
                type = "range",
                order = 1.5,
                name = function() return l10n('Objective icon cluster amount'); end,
                desc = function() return l10n('How much objective icons should cluster.'); end,
                width = 1.4,
                disabled = function() return (not Questie.db.profile.enabled); end,
                min = 1,
                max = 300,
                step = 1,
                get = function(info) return QuestieOptions:GetProfileValue(info); end,
                set = function(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieOptions.ClusterRedraw, l10n('Setting clustering value, clusterLevelHotzone set to %s : Redrawing!', value))
                    QuestieOptions:SetProfileValue(info, value)
                end,
            },
            icon_toggles_group = {
                type = "group",
                order = 2,
                inline = true,
                width = 0.5,
                name = function() return l10n('Show icons for...'); end,
                disabled = function() return not Questie.db.profile.enabled end,
                args = {
                    showNormalQuests = {
                        type = "toggle",
                        order = 2.1,
                        name = function() return l10n('Available Normal Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of available quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableAvailable; end,
                        set = function(info, value)
                            Questie.db.profile.enableAvailable = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showEventQuests = {
                        type = "toggle",
                        order = 2.2,
                        name = function() return l10n('Available Event Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of active event quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showEventQuests end,
                        set = function(info, value)
                            Questie.db.profile.showEventQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showRepeatableQuests = {
                        type = "toggle",
                        order = 2.3,
                        name = function() return l10n('Available Repeatable Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of repeatable quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showRepeatableQuests end,
                        set = function(info, value)
                            Questie.db.profile.showRepeatableQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showPvPQuests = {
                        type = "toggle",
                        order = 2.4,
                        name = function() return l10n('Available PvP Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of PvP quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showPvPQuests end,
                        set = function(info, value)
                            Questie.db.profile.showPvPQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showDungeonQuests = {
                        type = "toggle",
                        order = 2.5,
                        name = function() return l10n('Available Dungeon Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of dungeon quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showDungeonQuests end,
                        set = function(info, value)
                            Questie.db.profile.showDungeonQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showRaidQuests = {
                        type = "toggle",
                        order = 2.6,
                        name = function() return l10n('Available Raid Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of raid quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showRaidQuests end,
                        set = function(info, value)
                            Questie.db.profile.showRaidQuests = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showCompleteQuests = {
                        type = "toggle",
                        order = 2.7,
                        name = function() return l10n('Completed Quests'); end,
                        desc = function() return l10n('When this is enabled, the quest turn-in locations will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableTurnins; end,
                        set = function(info, value)
                            Questie.db.profile.enableTurnins = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showObjectivesToggle = {
                        type = "toggle",
                        order = 2.8,
                        name = function() return l10n('Objectives'); end,
                        desc = function() return l10n('When this is enabled, quest objective icons will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function() return Questie.db.profile.enableObjectives; end,
                        set = function(info, value)
                            Questie.db.profile.enableObjectives = value
                            QuestieQuest:ToggleNotes(value)
                        end,
                    },
                    showAQWarEffortQuests = {
                        type = "toggle",
                        order = 2.9,
                        hidden = (not Questie.IsClassic),
                        name = function() return l10n('Available AQ War Effort Quests'); end,
                        desc = function() return l10n('When this is enabled, the locations of the AQ War Effort quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.showAQWarEffortQuests end,
                        set = function(info, value)
                            Questie.db.profile.showAQWarEffortQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                },
            },
            map_settings_group = {
                type = "group",
                order = 3,
                inline = true,
                width = 0.5,
                name = function() return l10n('Map Icons'); end,
                args = {
                    enableMapToggle = {
                        type = "toggle",
                        order = 3.1,
                        name = function() return l10n('Enable Map Icons'); end,
                        desc = function() return l10n('Show/hide all icons from the main map.'); end,
                        width = 1.5,
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
                        name = function() return l10n('Map Icons Glow'); end,
                        desc = function() return l10n('Draw a glow texture behind map icons, colored unique to each quest.'); end,
                        width = 1.5,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieFramePool:UpdateGlowConfig(false, value)
                        end,
                    },
                    questObjectiveColors = {
                        type = "toggle",
                        order = 3.3,
                        name = function() return l10n('Unique Map Icon Colors'); end,
                        desc = function() return l10n('Show map icons with colors that are randomly generated based on quest ID.'); end,
                        width = 1.5,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieFramePool:UpdateColorConfig(false, value)
                        end,
                    },
                    hideUnexploredMapIconsToggle = {
                        type = "toggle",
                        order = 3.4,
                        name = function() return l10n('Hide Icons in Unexplored Areas'); end,
                        desc = function() return l10n('Hide icons in unexplored map regions.'); end,
                        width = 1.5,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons)); end,
                        get = function() return Questie.db.profile.hideUnexploredMapIcons; end,
                        set = function(info, value)
                            Questie.db.profile.hideUnexploredMapIcons = value
                            QuestieQuest:ToggleNotes(not value)
                        end,
                    },
                },
            },
            minimap_settings_group = {
                type = "group",
                order = 4,
                inline = true,
                width = 0.5,
                name = function() return l10n('Minimap Icons'); end,
                disabled = function() return not Questie.db.profile.enabled end,
                args = {
                    enableMiniMapToggle = {
                        type = "toggle",
                        order = 4.1,
                        name = function() return l10n('Enable Minimap Icons'); end,
                        desc = function() return l10n('Show/hide all icons from the minimap.'); end,
                        width = 1.5,
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
                        name = function() return l10n('Minimap Icons Glow'); end,
                        desc = function() return l10n('Draw a glow texture behind minimap icons, colored unique to each quest.'); end,
                        width = 1.5,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieFramePool:UpdateGlowConfig(true, value)
                        end,
                    },
                    questMinimapObjectiveColors = {
                        type = "toggle",
                        order = 4.3,
                        name = function() return l10n('Unique Map Icon Colors'); end,
                        desc = function() return l10n('Show map icons with colors that are randomly generated based on quest ID.'); end,
                        width = 1.5,
                        disabled = function() return ((not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons)); end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieFramePool:UpdateColorConfig(true, value)
                        end,
                    },
                    fadeLevel = {
                        type = "range",
                        order = 4.4,
                        name = function() return l10n('Minimap Icon Fade Distance'); end,
                        desc = function() return l10n('How much objective icons should fade depending on distance. ( Default: %s )', optionsDefaults.profile.fadeLevel); end,
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
                        name = function() return l10n('Fade Icons over Player'); end,
                        desc = function() return l10n('Fades icons on the minimap when your player walks near them.'); end,
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
                        name = function() return l10n('Fade over Player Distance'); end,
                        desc = function() return l10n('How far from player should icons start to fade. ( Default: %s )', optionsDefaults.profile.fadeOverPlayerDistance); end,
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
                        name = function() return l10n('Fade over Player Amount'); end,
                        desc = function() return l10n('How much should the icons around the player fade. ( Default: %s )', optionsDefaults.profile.fadeOverPlayerLevel); end,
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
                name = function() return l10n('Icon Scales'); end,
                disabled = function() return not Questie.db.profile.enabled end,
                args = {
                    globalScale = {
                        type = "range",
                        order = 5.1,
                        name = function() return l10n('Map Icons'); end,
                        desc = function() return l10n('How large the map Icons are. ( Default: %s )', optionsDefaults.profile.globalScale); end,
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
                        name = function() return l10n('Minimap Icons'); end,
                        desc = function() return l10n('How large the minimap icons are. ( Default: %s )', optionsDefaults.profile.globalMiniMapScale); end,
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
                        name = function() return l10n('Quest Icons'); end,
                        desc = function() return l10n('How large the available/complete icons are. Affects both map and minimap icons. ( Default: %s )', optionsDefaults.profile.availableScale); end,
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
                        name = function() return l10n('Loot Objectives'); end,
                        desc = function() return l10n('How large the loot icons are.  ( Default: %s )', optionsDefaults.profile.lootScale); end,
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
                        name = function() return l10n('Slay Objectives'); end,
                        desc = function() return l10n('How large the slay icons are.  ( Default: %s )', optionsDefaults.profile.monsterScale); end,
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
                        name = function() return l10n('Event Objectives'); end,
                        desc = function() return l10n('How large the event icons are.  ( Default: %s )', optionsDefaults.profile.eventScale); end,
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
                        name = function() return l10n('Object Objectives'); end,
                        desc = function() return l10n('How large the object icons are.  ( Default: %s )', optionsDefaults.profile.objectScale); end,
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
                hidden = function() return (iconsHidden); end,
                inline = true,
                name = "Icon Overrides",
                args = {
                    usePfQuestIcons = {
                        type = "toggle",
                        order = 16.1,
                        name = function() return l10n('Toggle pfQuest/ClassicCodex icon style'); end,
                        desc = function()
                            return l10n('Toggles between Questie icon style and pfQuest/ClassicCodex icon style.\n\nToggling affects the following settings:\n\n- Objective icons\n- ')
                                .. l10n('Always Glow Behind Map Icons') .. '\n- '
                                .. l10n('Different Map Icon Color for Each Quest') .. '\n- '
                                .. l10n('Always Glow Behind Minimap Icons') .. '\n- '
                                .. l10n('Different Minimap Icon Color for Each Quest') .. '\n- '
                                .. l10n('Objective icon cluster amount');
                        end,
                        width = 3,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        get = function(info) return Questie.db.profile.usePfQuestIcons end,
                        set = QuestieOptionsUtils.SetPfQuestIcons,
                    },
                    overrideObjectivesHeader = {
                        type = "header",
                        order = 16.5,
                        name = function() return l10n('Objectives') end,
                    },
                    iconTypeSlay = {
                        type = "select",
                        order = 17,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Slay objectives') end,
                        desc = function() return l10n('The icon that is displayed for quest objectives where you need to kill an NPC'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_SLAY) or "slay"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_SLAY = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeLoot = {
                        type = "select",
                        order = 18,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Loot objectives') end,
                        desc = function() return l10n('The icon that is displayed for quest objectives where you need to loot an item'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_LOOT) or "loot"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_LOOT = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeObject = {
                        type = "select",
                        order = 19,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Object objectives') end,
                        desc = function() return l10n('The icon that is displayed for quest objectives where you need to interact with an object'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_OBJECT) or "object"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_OBJECT = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeEvent = {
                        type = "select",
                        order = 20,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Event objectives') end,
                        desc = function() return l10n('The icon that is displayed for quest objectives where you need to do something in a certain area, like exploring it or casting a spell there'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENT) or "event"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_EVENT = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeTalk = {
                        type = "select",
                        order = 21,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Talk objectives') end,
                        desc = function() return l10n('The icon that is displayed for quest objectives where you need to talk to an NPC'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_TALK) or "talk"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_TALK = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    overrideNormalQuestsHeader = {
                        type = "header",
                        order = 22,
                        name = function() return l10n('Normal Quests') end,
                    },
                    iconTypeAvailable = {
                        type = "select",
                        order = 23,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Available quests') end,
                        desc = function() return l10n('The icon that is displayed for available quests'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_AVAILABLE) or "available"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_AVAILABLE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeComplete = {
                        type = "select",
                        order = 25,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Complete quests') end,
                        desc = function() return l10n('The icon that is displayed for completed quests that can be handed in'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_COMPLETE) or "complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeAvailableGray = {
                        type = "select",
                        order = 26,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Unavailable and trivial quests') end,
                        desc = function() return l10n('The icon that is displayed for quests that require additional conditions to be met before they can be accepted, or are so low level they don\'t reward experience'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_AVAILABLE_GRAY) or "available_gray"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_AVAILABLE_GRAY = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    overrideRepeatableQuestsHeader = {
                        type = "header",
                        order = 27,
                        name = function() return l10n('Repeatable Quests') end,
                    },
                    iconTypeRepeatable = {
                        type = "select",
                        order = 28,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Available repeatable quests') end,
                        desc = function() return l10n('The icon that is displayed for available repeatable quests like dailies'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_REPEATABLE) or "repeatable"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_REPEATABLE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeRepeatableComplete = {
                        type = "select",
                        order = 29,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Complete repeatable quests') end,
                        desc = function() return l10n('The icon that is displayed for repeatable quests that can be handed in'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_REPEATABLE_COMPLETE) or "repeatable_complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_REPEATABLE_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    overrideEventQuestsHeader = {
                        type = "header",
                        order = 30,
                        name = function() return l10n('Event Quests') end,
                    },
                    iconTypeEventQuest = {
                        type = "select",
                        order = 31,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Available event quests') end,
                        desc = function() return l10n('The icon that is displayed for available event quests during holidays'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENTQUEST) or "eventquest"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_EVENTQUEST = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypeEventQuestComplete = {
                        type = "select",
                        order = 32,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Complete event quests') end,
                        desc = function() return l10n('The icon that is displayed for event quests that can be handed in'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_EVENTQUEST_COMPLETE) or "eventquest_complete"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_EVENTQUEST_COMPLETE = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    overridePVPQuestsHeader = {
                        type = "header",
                        order = 33,
                        name = function() return l10n('PVP Quests') end,
                    },
                    iconTypePVPQuest = {
                        type = "select",
                        order = 34,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Available PvP quests') end,
                        desc = function() return l10n('The icon that is displayed for available PvP quests'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_PVPQUEST) or "pvpquest"; end,
                        disabled = function() return (not Questie.db.profile.enabled); end,
                        set = function(input, key)
                            Questie.db.profile.ICON_PVPQUEST = Questie.icons[key]
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    iconTypePVPQuestComplete = {
                        type = "select",
                        order = 35,
                        values = _GetIconTypes(),
                        sorting = _GetIconTypesSort(),
                        style = 'dropdown',
                        width = 1.03,
                        name = function() return l10n('Complete PvP quests') end,
                        desc = function() return l10n('The icon that is displayed for PvP quests that can be handed in'); end,
                        get = function() return Questie:GetIconNameFromPath(Questie.db.profile.ICON_PVPQUEST_COMPLETE) or "pvpquest_complete"; end,
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