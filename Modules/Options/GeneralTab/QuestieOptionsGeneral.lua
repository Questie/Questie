-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu");
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type Sounds
local Sounds = QuestieLoader:ImportModule("Sounds");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.general = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetShortcuts
local _GetIconTypes
local _GetIconTypesSort
local _GetQuestSoundChoices
local _GetQuestSoundChoicesSort
local _GetObjectiveSoundChoices
local _GetObjectiveSoundChoicesSort

local iconsHidden = true

function QuestieOptions.tabs.general:Initialize()
    return {
        name = function() return l10n('General'); end,
        type = "group",
        order = 10,
        args = {
            questie_header = {
                type = "header",
                order = 1,
                name = function() return l10n('General Options'); end,
            },
            enabled = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Enable Icons'); end,
                desc = function() return l10n('Enable or disable Questie icons.'); end,
                width = 1.5,
                get = function () return Questie.db.char.enabled; end,
                set = function (info, value)
                    Questie.db.char.enabled = value
                    QuestieQuest:ToggleNotes(value);
                end,
            },
            townfolkOptions = {
                type = "execute",
                order = 1.2,
                name = function() return l10n('Config Tracking Icons'); end,
                desc = function() return l10n('Allows to select which the tracking icons (like Mailbox, Repair-NPCs) to show on the map and minimap.'); end,
                width = 1.5,
                func = function (info, value)
                    QuestieMenu:Show()
                end,
            },
            iconTypes = {
                type = "group",
                order = 2,
                inline = true,
                name = function() return l10n('Icon Types'); end,
                args = {
                    enableMapToggle = {
                        type = "toggle",
                        order = 1,
                        name = function() return l10n('Enable Map Icons'); end,
                        desc = function() return l10n('Show/hide all icons from the main map.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableMapIcons; end,
                        set = function (info, value)
                            Questie.db.global.enableMapIcons = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    enableMiniMapToggle = {
                        type = "toggle",
                        order = 2,
                        name = function() return l10n('Enable Minimap Icons'); end,
                        desc = function() return l10n('Show/hide all icons from the minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableMiniMapIcons; end,
                        set = function (info, value)
                            Questie.db.global.enableMiniMapIcons = value
                            QuestieQuest:ToggleNotes(value);
                        end,
                    },
                    hideUnexploredMapIconsToggle = {
                        type = "toggle",
                        order = 3,
                        name = function() return l10n('Hide unexplored area Icons'); end,
                        desc = function() return l10n('Hide icons in unexplored areas.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function() return Questie.db.char.hideUnexploredMapIcons; end,
                        set = function(info, value)
                            Questie.db.char.hideUnexploredMapIcons = value
                            QuestieQuest:ToggleNotes(not value);
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    hideMapIconsForUntrackedToggle = {
                        type = "toggle",
                        order = 4,
                        name = function() return l10n('Hide icons of untracked quests'); end,
                        desc = function() return l10n('Hide icons for quests that are not tracked.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function() return Questie.db.char.hideUntrackedQuestsMapIcons; end,
                        set = function(info, value)
                            Questie.db.char.hideUntrackedQuestsMapIcons = value
                            QuestieQuest:ToggleNotes(not value);
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showCustomQuestFrameIcons = {
                        type = "toggle",
                        order = 4.5,
                        name = function() return l10n('Show custom quest frame icons'); end,
                        desc = function() return l10n('Use custom Questie icons for NPC dialogs, reflecting the status and type of each quest.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function() return Questie.db.char.enableQuestFrameIcons; end,
                        set = function(info, value)
                            Questie.db.char.enableQuestFrameIcons = value
                        end,
                    },
                    separatingHeader1 = {
                        type = "header",
                        order = 5,
                        name = "",
                    },
                    enableObjectivesToggle = {
                        type = "toggle",
                        order = 6,
                        name = function() return l10n('Enable Objective Icons'); end,
                        desc = function() return l10n('When this is enabled, quest objective icons will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableObjectives; end,
                        set = function (info, value)
                            Questie.db.global.enableObjectives = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    enableTurninsToggle = {
                        type = "toggle",
                        order = 7,
                        name = function() return l10n('Enable Completed Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the quest turn-in locations will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableTurnins; end,
                        set = function (info, value)
                            Questie.db.global.enableTurnins = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    enableAvailableToggle = {
                        type = "toggle",
                        order = 8,
                        name = function() return l10n('Enable Available Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of available quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function () return Questie.db.global.enableAvailable; end,
                        set = function (info, value)
                            Questie.db.global.enableAvailable = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showRepeatableQuests = {
                        type = "toggle",
                        order = 9,
                        name = function() return l10n('Enable Repeatable Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of repeatable quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showRepeatableQuests end,
                        set = function (info, value)
                            Questie.db.char.showRepeatableQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showEventQuests = {
                        type = "toggle",
                        order = 10,
                        name = function() return l10n('Enable Event Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of active event quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showEventQuests end,
                        set = function (info, value)
                            Questie.db.char.showEventQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showDungeonQuests = {
                        type = "toggle",
                        order = 11,
                        name = function() return l10n('Enable Dungeon Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of dungeon quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showDungeonQuests end,
                        set = function (info, value)
                            Questie.db.char.showDungeonQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showRaidQuests = {
                        type = "toggle",
                        order = 12,
                        name = function() return l10n('Enable Raid Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of raid quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showRaidQuests end,
                        set = function (info, value)
                            Questie.db.char.showRaidQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showPvPQuests = {
                        type = "toggle",
                        order = 13,
                        name = function() return l10n('Enable PvP Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of PvP quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showPvPQuests end,
                        set = function (info, value)
                            Questie.db.char.showPvPQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    showAQWarEffortQuests = {
                        type = "toggle",
                        order = 14,
                        hidden = (not Questie.IsEra),
                        name = function() return l10n('Enable AQ War Effort Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of the AQ War Effort quests will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showAQWarEffortQuests end,
                        set = function (info, value)
                            Questie.db.char.showAQWarEffortQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                    usePfQuestIcons = {
                        type = "toggle",
                        order = 14,
                        name = function() return l10n('Toggle pfQuest/ClassicCodex icon style'); end,
                        desc = function() return l10n('Toggles between Questie icon style and pfQuest/ClassicCodex icon style.\n\nToggling affects the following settings:\n\n- Objective icons\n- ')
                                                 ..l10n('Always Glow Behind Map Icons')..'\n- '
                                                 ..l10n('Different Map Icon Color for Each Quest')..'\n- '
                                                 ..l10n('Always Glow Behind Minimap Icons')..'\n- '
                                                 ..l10n('Different Minimap Icon Color for Each Quest')..'\n- '
                                                 ..l10n('Objective icon cluster amount');
                        end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.global.usePfQuestIcons end,
                        set = function(info, value)
                            Questie.db.global.usePfQuestIcons = value
                            if value then
                                Questie.db.global.ICON_SLAY = Questie.icons["node"]
                                Questie.db.global.ICON_LOOT = Questie.icons["node"]
                                Questie.db.global.ICON_EVENT = Questie.icons["node"]
                                Questie.db.global.ICON_OBJECT = Questie.icons["node"]
                                Questie.db.global.ICON_TALK = Questie.icons["node"]
                                -- TODO remove these setting changes once we have a style selection window/frame
                                Questie.db.global.questObjectiveColors = true
                                Questie.db.global.alwaysGlowMap = false
                                Questie.db.global.questMinimapObjectiveColors = true
                                Questie.db.global.alwaysGlowMinimap = false
                                Questie.db.global.clusterLevelHotzone = 1
                            else
                                Questie.db.global.ICON_SLAY = Questie.icons["slay"]
                                Questie.db.global.ICON_LOOT = Questie.icons["loot"]
                                Questie.db.global.ICON_EVENT = Questie.icons["event"]
                                Questie.db.global.ICON_OBJECT = Questie.icons["object"]
                                Questie.db.global.ICON_TALK = Questie.icons["talk"]
                                -- TODO remove these setting changes once we have a style selection window/frame
                                Questie.db.global.questObjectiveColors = false
                                Questie.db.global.alwaysGlowMap = true
                                Questie.db.global.questMinimapObjectiveColors = false
                                Questie.db.global.alwaysGlowMinimap = false
                                Questie.db.global.clusterLevelHotzone = 50
                            end
                            Questie:SetIcons()
                            QuestieQuest:SmoothReset()
                        end
                    },
                    separatingHeader2 = {
                        type = "header",
                        order = 15,
                        name = "",
                    },
                    iconOverrideButton = {
                        type = "execute",
                        order = 15.5,
                        name = function() return l10n('Icon Overrides (show/hide)'); end,
                        width = 1.2,
                        func = function (info, value)
                            iconsHidden = not iconsHidden
                        end,
                    },
                    iconOverrides = {
                        type = "group",
                        order = 16,
                        hidden = function() return (iconsHidden); end;
                        inline = true,
                        name = " ",
                        args = {
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
                                name = function() return l10n('Slay objectives') end,
                                desc = function() return l10n('The icon that is displayed for quest objectives where you need to kill an NPC'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_SLAY) or "slay"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_SLAY = Questie.icons[key]
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
                                name = function() return l10n('Loot objectives') end,
                                desc = function() return l10n('The icon that is displayed for quest objectives where you need to loot an item'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_LOOT) or "loot"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_LOOT = Questie.icons[key]
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
                                name = function() return l10n('Object objectives') end,
                                desc = function() return l10n('The icon that is displayed for quest objectives where you need to interact with an object'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_OBJECT) or "object"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_OBJECT = Questie.icons[key]
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
                                name = function() return l10n('Event objectives') end,
                                desc = function() return l10n('The icon that is displayed for quest objectives where you need to do something in a certain area, like exploring it or casting a spell there'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_EVENT) or "event"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_EVENT = Questie.icons[key]
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
                                name = function() return l10n('Talk objectives') end,
                                desc = function() return l10n('The icon that is displayed for quest objectives where you need to talk to an NPC'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_TALK) or "talk"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_TALK = Questie.icons[key]
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
                                name = function() return l10n('Available quests') end,
                                desc = function() return l10n('The icon that is displayed for available quests'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_AVAILABLE) or "available"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_AVAILABLE = Questie.icons[key]
                                    Questie:SetIcons()
                                    QuestieQuest:SmoothReset()
                                end,
                            },
                            iconTypeAvailableGray = {
                                type = "select",
                                order = 25,
                                values = _GetIconTypes(),
                                sorting = _GetIconTypesSort(),
                                style = 'dropdown',
                                name = function() return l10n('Unavailable and trivial quests') end,
                                desc = function() return l10n('The icon that is displayed for quests that require additional conditions to be met before they can be accepted, or are so low level they don\'t reward experience'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_AVAILABLE_GRAY) or "available_gray"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_AVAILABLE_GRAY = Questie.icons[key]
                                    Questie:SetIcons()
                                    QuestieQuest:SmoothReset()
                                end,
                            },
                            iconTypeComplete = {
                                type = "select",
                                order = 26,
                                values = _GetIconTypes(),
                                sorting = _GetIconTypesSort(),
                                style = 'dropdown',
                                name = function() return l10n('Complete quests') end,
                                desc = function() return l10n('The icon that is displayed for completed quests that can be handed in'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_COMPLETE) or "complete"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_COMPLETE = Questie.icons[key]
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
                                name = function() return l10n('Available repeatable quests') end,
                                desc = function() return l10n('The icon that is displayed for available repeatable quests like dailies'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_REPEATABLE) or "repeatable"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_REPEATABLE = Questie.icons[key]
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
                                name = function() return l10n('Complete repeatable quests') end,
                                desc = function() return l10n('The icon that is displayed for repeatable quests that can be handed in'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_REPEATABLE_COMPLETE) or "repeatable_complete"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_REPEATABLE_COMPLETE = Questie.icons[key]
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
                                name = function() return l10n('Available event quests') end,
                                desc = function() return l10n('The icon that is displayed for available event quests during holidays'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_EVENTQUEST) or "eventquest"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_EVENTQUEST = Questie.icons[key]
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
                                name = function() return l10n('Complete event quests') end,
                                desc = function() return l10n('The icon that is displayed for event quests that can be handed in'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_EVENTQUEST_COMPLETE) or "eventquest_complete"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_EVENTQUEST_COMPLETE = Questie.icons[key]
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
                                name = function() return l10n('Available PvP quests') end,
                                desc = function() return l10n('The icon that is displayed for available PvP quests'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_PVPQUEST) or "pvpquest"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_PVPQUEST = Questie.icons[key]
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
                                name = function() return l10n('Complete PvP quests') end,
                                desc = function() return l10n('The icon that is displayed for PvP quests that can be handed in'); end,
                                get = function() return Questie:GetIconNameFromPath(Questie.db.global.ICON_PVPQUEST_COMPLETE) or "pvpquest_complete"; end,
                                disabled = function() return (not Questie.db.char.enabled); end,
                                set = function(input, key)
                                    Questie.db.global.ICON_PVPQUEST_COMPLETE = Questie.icons[key]
                                    Questie:SetIcons()
                                    QuestieQuest:SmoothReset()
                                end,
                            },
                        },
                    },
                },
            },
            Spacer_A1 = QuestieOptionsUtils:Spacer(2.1),
            isleOfQuelDanasPhase = {
                type = "select",
                order = 2.5,
                width = 1.5,
                hidden = (not Questie.IsTBC),
                values = IsleOfQuelDanas.localizedPhaseNames,
                style = 'dropdown',
                name = function() return l10n("Isle of Quel'Danas Phase") end,
                desc = function() return l10n("Select the phase fitting your realm progress on the Isle of Quel'Danas"); end,
                disabled = function() return (not Questie.IsWotlk) end,
                get = function() return Questie.db.global.isleOfQuelDanasPhase; end,
                set = function(_, key)
                    Questie.db.global.isleOfQuelDanasPhase = key
                    QuestieQuest:SmoothReset()
                end,
            },
            isleOfQuelDanasPhaseReminder = {
                type = "toggle",
                order = 2.6,
                hidden = (not Questie.IsTBC),
                name = function() return l10n('Disable Phase reminder'); end,
                desc = function() return l10n("Enable or disable the reminder on login to set the Isle of Quel'Danas phase"); end,
                disabled = function() return (not Questie.IsWotlk) end,
                width = 1,
                get = function () return Questie.db.global.isIsleOfQuelDanasPhaseReminderDisabled; end,
                set = function (_, value)
                    Questie.db.global.isIsleOfQuelDanasPhaseReminderDisabled = value
                end,
            },
            Spacer_A = QuestieOptionsUtils:Spacer(2.9, (not Questie.IsTBC)),
            SoundTopSpacer = {
                type = "header",
                order = 2.10,
                name = function() return l10n('Sounds'); end,
            },
            questCompleteSound = {
                type = "toggle",
                order = 2.11,
                name = function() return l10n('Quest completed'); end,
                desc = function() return l10n('Play a short sound when completing a quest when it is ready to turn in.'); end,
                width = 1.2,
                get = function () return Questie.db.char.soundOnQuestComplete; end,
                set = function (_, value)
                    Questie.db.char.soundOnQuestComplete = value
                end,
            },
            questCompleteSoundButton = {
                type = "execute",
                order = 2.12,
                name = "",
                width = 0.5,
                image = function ()
                    return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                end,
                func = function ()
                    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.char.questCompleteSoundChoiceName), "Master")
                end
            },
            questCompleteSoundChoice = {
                type = "select",
                order = 2.13,
                values = _GetQuestSoundChoices(),
                sorting = _GetQuestSoundChoicesSort(),
                style = 'dropdown',
                name = function() return l10n('Quest Complete Sound Selection') end,
                desc = function() return l10n('The sound you hear when a quest is completed'); end,
                get = function() return Questie.db.char.questCompleteSoundChoiceName or "None"; end,
                disabled = function() return (not Questie.db.char.soundOnQuestComplete); end,
                set = function(_, value)
                    Questie.db.char.questCompleteSoundChoiceName = value
                end,
            },
            soundLineBreak = {
                type = "description",
                name = " ",
                width = 0.1,
                order = 2.135,
            },
            objectiveCompleteSound = {
                type = "toggle",
                order = 2.14,
                name = function() return l10n('Quest objective completed'); end,
                desc = function() return l10n('Play a short sound when completing a quest objective.'); end,
                width = 1.2,
                get = function () return Questie.db.char.soundOnObjectiveComplete; end,
                set = function (_, value)
                    Questie.db.char.soundOnObjectiveComplete = value
                end,
            },
            objectiveCompleteSoundButton = {
                type = "execute",
                order = 2.15,
                name = "",
                width = 0.5,
                image = function ()
                    return "Interface\\OptionsFrame\\VoiceChat-Play", 15, 15
                end,
                func = function ()
                    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.char.objectiveCompleteSoundChoiceName), "Master")
                end
            },
            objectiveCompleteSoundChoice = {
                type = "select",
                order = 2.16,
                values = _GetObjectiveSoundChoices(),
                sorting = _GetObjectiveSoundChoicesSort(),
                style = 'dropdown',
                name = function() return l10n('Objective Complete Sound Selection') end,
                desc = function() return l10n('The sound you hear when an objective is completed'); end,
                get = function() return  Questie.db.char.objectiveCompleteSoundChoiceName; end,
                disabled = function() return (not Questie.db.char.soundOnObjectiveComplete); end,
                set = function(input, value)
                    Questie.db.char.objectiveCompleteSoundChoiceName = value
                end,
            },
            SoundBottomSpacer = {
                type = "header",
                order = 2.17,
                name = "",
            },
            minimapButtonEnabled = {
                type = "toggle",
                order = 3,
                name = function() return l10n('Enable Minimap Button'); end,
                desc = function() return l10n('Enable or disable the Questie minimap button. You can still access the options menu with /questie.'); end,
                width = 1.5,
                get = function () return not Questie.db.profile.minimap.hide; end,
                set = function (info, value)
                    Questie.db.profile.minimap.hide = not value;

                    if value then
                        Questie.minimapConfigIcon:Show("Questie");
                    else
                        Questie.minimapConfigIcon:Hide("Questie");
                    end
                end,
            },
            instantQuest = {
                type = "toggle",
                order = 4,
                name = function() return l10n('Enable Instant Quest Text'); end,
                desc = function() return l10n('Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface.'); end,
                width = 1.5,
                get = function () if GetCVar("instantQuestText") == '1' then return true; else return false; end; end,
                set = function (info, value)
                    if value then
                        SetCVar("instantQuestText", 1);
                    else
                        SetCVar("instantQuestText", 0);
                    end
                end,
            },
            autoaccept = {
                type = "toggle",
                order = 5,
                name = function() return l10n('Auto Accept Quests'); end,
                desc = function() return l10n('Enable or disable Questie auto-accepting quests.'); end,
                width = 1.5,
                get = function () return Questie.db.char.autoaccept; end,
                set = function (info, value)
                    Questie.db.char.autoaccept = value
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Accept toggled to:", value)
                end,
            },
            autocomplete = {
                type = "toggle",
                order = 6,
                name = function() return l10n('Auto Complete'); end,
                desc = function() return l10n('Enable or disable Questie auto-completing quests.'); end,
                width = 1.5,
                get = function () return Questie.db.char.autocomplete; end,
                set = function (info, value)
                    Questie.db.char.autocomplete = value
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Auto Complete toggled to:", value)
                end,
            },
            autoModifier = {
                type = "select",
                order = 7,
                values = _GetShortcuts(),
                style = 'dropdown',
                name = function() return l10n('Auto Modifier') end,
                desc = function() return l10n('The modifier to NOT auto-accept/-complete quests when either option is enabled and you interact with a quest NPC.'); end,
                disabled = function() return (not Questie.db.char.autocomplete) and (not Questie.db.char.autoaccept) end,
                get = function() return Questie.db.char.autoModifier; end,
                set = function(input, key)
                    Questie.db.char.autoModifier = key
                end,
            },
            Spacer_H = QuestieOptionsUtils:HorizontalSpacer(1.71, 0.5),
            acceptTrivial = {
                type = "toggle",
                order = 8,
                name = function() return l10n('Accept trivial (low level) quests'); end,
                desc = function() return l10n('When this is enabled trivial (gray) quests will be auto accepted as well.'); end,
                disabled = function() return (not Questie.db.char.autoaccept) end,
                width = 1.5,
                get = function () return Questie.db.char.acceptTrivial; end,
                set = function (info, value)
                    Questie.db.char.acceptTrivial = value
                end,
            },
            --Spacer_B = QuestieOptionsUtils:Spacer(1.73),
            quest_options = {
                type = "header",
                order = 12,
                name = function() return l10n('Quest Level Options'); end,
            },
            gray = {
                type = "toggle",
                order = 13,
                name = function() return l10n('Show All Quests below range (Low level quests)'); end,
                desc = function() return l10n('Enable or disable showing of showing low level quests on the map.'); end,
                width = "full",
                get = function () return Questie.db.char.lowlevel; end,
                set = function (info, value)
                    Questie.db.char.lowlevel = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(Questie.DEBUG_DEVELOP, "Gray Quests toggled to:", value)
                end,
            },
            manualMinLevelOffset = {
                type = "toggle",
                order = 14,
                name = function() return l10n('Enable manual minimum level offset'); end,
                desc = function() return l10n('Enable manual minimum level offset instead of the automatic GetQuestGreenLevel function.'); end,
                width = 1.5,
                disabled = function() return Questie.db.char.lowlevel or Questie.db.char.absoluteLevelOffset; end,
                get = function () return Questie.db.char.manualMinLevelOffset; end,
                set = function (info, value)
                    Questie.db.char.manualMinLevelOffset = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(Questie.DEBUG_DEVELOP, l10n('Enable manual minimum level offset'), value)
                end,
            },
            absoluteLevelOffset = {
                type = "toggle",
                order = 15,
                name = function() return l10n('Enable absolute level range'); end,
                desc = function() return l10n('Change the level offset to absolute level values.'); end,
                width = 1.5,
                disabled = function() return Questie.db.char.lowlevel or Questie.db.char.manualMinLevelOffset; end,
                get = function () return Questie.db.char.absoluteLevelOffset; end,
                set = function (info, value)
                    Questie.db.char.absoluteLevelOffset = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(Questie.DEBUG_DEVELOP, l10n('Enable absolute level range'), value)
                end,
            },
            minLevelFilter = {
                type = "range",
                order = 16,
                name = function()
                    if Questie.db.char.absoluteLevelOffset then
                        return l10n('Level from');
                    else
                        return l10n('< Show below level');
                    end
                end,
                desc = function()
                    if Questie.db.char.absoluteLevelOffset then
                        return l10n('Minimum quest level to show.');
                    else
                        return l10n('How many levels below your character to show. ( Default: %s )', optionsDefaults.char.minLevelFilter);
                    end
                end,
                width = "normal",
                min = 0,
                max = 60 + 10 * GetExpansionLevel(),
                step = 1,
                disabled = function() return (not Questie.db.char.manualMinLevelOffset) and (not Questie.db.char.absoluteLevelOffset); end,
                get = function() return Questie.db.char.minLevelFilter; end,
                set = function (info, value)
                    Questie.db.char.minLevelFilter = value;
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw,"minLevelFilter set to " .. value)
                end,
            },
            maxLevelFilter = {
                type = "range",
                order = 17,
                name = function()
                    return l10n('Level to');
                end,
                desc = function()
                    return l10n('Maximum quest level to show.');
                end,
                width = "normal",
                min = 0,
                max = 60 + 10 * GetExpansionLevel(),
                step = 1,
                disabled = function() return (not Questie.db.char.absoluteLevelOffset); end,
                get = function(info) return Questie.db.char.maxLevelFilter; end,
                set = function (info, value)
                    Questie.db.char.maxLevelFilter = value;
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, "maxLevelFilter set to " .. value)
                end,
            },
            clusterLevelHotzone = {
                type = "range",
                order = 18,
                name = function() return l10n('Objective icon cluster amount'); end,
                desc = function() return l10n('How much objective icons should cluster.'); end,
                width = "double",
                min = 1,
                max = 300,
                step = 1,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieOptions.ClusterRedraw, l10n('Setting clustering value, clusterLevelHotzone set to %s : Redrawing!', value))
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
        },
    }
end

_GetShortcuts = function()
    return {
        ['shift'] = l10n('Shift'),
        ['ctrl'] = l10n('Control'),
        ['alt'] = l10n('Alt'),
        ['disabled'] = l10n('Disabled'),
    }
end

_GetIconTypes = function()
    return {
        ["slay"] = "|T"..Questie.icons["slay"]..":0|t Slay",
        ["loot"] = "|T"..Questie.icons["loot"]..":0|t Loot",
        ["node"] = "|T"..Questie.icons["node"]..":0|t pfQuest/Codex node",
        ["player"] = "|T"..Questie.icons["player"]..":0|t Party marker",
        ["event"] = "|T"..Questie.icons["event"]..":0|t Event",
        ["object"] = "|T"..Questie.icons["object"]..":0|t Object",
        ["talk"] = "|T"..Questie.icons["talk"]..":0|t Talk",
        ["available"] = "|T"..Questie.icons["available"]..":0|t Available",
        ["available_gray"] = "|T"..Questie.icons["available_gray"]..":0|t Available gray",
        ["complete"] = "|T"..Questie.icons["complete"]..":0|t Complete",
        ["incomplete"] = "|T"..Questie.icons["incomplete"]..":0|t Incomplete",
        ["repeatable"] = "|T"..Questie.icons["repeatable"]..":0|t Repeatable",
        ["repeatable_complete"] = "|T"..Questie.icons["repeatable_complete"]..":0|t Repeatable Complete",
        ["eventquest"] = "|T"..Questie.icons["eventquest"]..":0|t Event Quest",
        ["eventquest_complete"] = "|T"..Questie.icons["eventquest_complete"]..":0|t Event Quest Complete",
        ["pvpquest"] = "|T"..Questie.icons["pvpquest"]..":0|t PvP Quest",
        ["pvpquest_complete"] = "|T"..Questie.icons["pvpquest_complete"]..":0|t PvP Quest Complete",
        ["fav"] = "|T"..Questie.icons["fav"]..":0|t Favourite",
        ["faction_alliance"] = "|T"..Questie.icons["faction_alliance"]..":0|t Alliance",
        ["faction_horde"] = "|T"..Questie.icons["faction_horde"]..":0|t Horde",
        ["loot_mono"] = "|T"..Questie.icons["loot_mono"]..":0|t Loot mono",
        ["node_cut"] = "|T"..Questie.icons["node_cut"]..":0|t pfQuest/Codex node cut center",
        ["object_mono"] = "|T"..Questie.icons["object_mono"]..":0|t Object mono",
        ["route"] = "|T"..Questie.icons["route"]..":0|t Route waypoint",
        ["slay_mono"] = "|T"..Questie.icons["slay_mono"]..":0|t Slay mono",
        ["startend"] = "|T"..Questie.icons["startend"]..":0|t Start and end",
        ["startendstart"] = "|T"..Questie.icons["startendstart"]..":0|t Start and unfinished",
        ["tracker_clean"] = "|T"..Questie.icons["tracker_clean"]..":0|t Clean",
        ["tracker_close"] = "|T"..Questie.icons["tracker_close"]..":0|t Close",
        ["tracker_database"] = "|T"..Questie.icons["tracker_database"]..":0|t Pin",
        ["tracker_giver"] = "|T"..Questie.icons["tracker_giver"]..":0|t Available white",
        ["tracker_quests"] = "|T"..Questie.icons["tracker_quests"]..":0|t Book",
        ["tracker_search"] = "|T"..Questie.icons["tracker_search"]..":0|t Search",
        ["tracker_settings"] = "|T"..Questie.icons["tracker_settings"]..":0|t Settings",
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

_GetQuestSoundChoices = function()
    return {
        ["QuestDefault"]               = "Default",
        ["Troll Male"]                 = "Troll Male",
        ["Troll Female"]               = "Troll Female",
        ["Tauren Male"]                = "Tauren Male",
        ["Tauren Female"]              = "Tauren Female",
        ["Undead Male"]                = "Undead Male",
        ["Undead Female"]              = "Undead Female",
        ["Orc Male"]                   = "Orc Male",
        ["Orc Female"]                 = "Orc Female",
        ["Night Elf Female"]            = "Night Elf Female",
        ["Night Elf Male"]              = "Night Elf Male",
        ["Human Female"]               = "Human Female",
        ["Human Male"]                 = "Human Male",
        ["Gnome Male"]                 = "Gnome Male",
        ["Gnome Female"]               = "Gnome Female",
        ["Dwarf Male"]                 = "Dwarf Male",
        ["Dwarf Female"]               = "Dwarf Female",
        ["Draenei Male"]               = "Draenei Male",
        ["Draenei Female"]             = "Draenei Female",
        ["Blood Elf Female"]            = "Blood Elf Female",
        ["Blood Elf Male"]              = "Blood Elf Male",
    }
end


_GetQuestSoundChoicesSort = function()
    return {
        "QuestDefault",
        "Troll Male",
        "Troll Female",
        "Tauren Male",
        "Tauren Female",
        "Undead Male",
        "Undead Female",
        "Orc Male",
        "Orc Female",
        "Night Elf Female",
        "Night Elf Male",
        "Human Female",
        "Human Male",
        "Gnome Male",
        "Gnome Female",
        "Dwarf Male",
        "Dwarf Female",
        "Draenei Male",
        "Draenei Female",
        "Blood Elf Female",
        "Blood Elf Male",
    }
end

_GetObjectiveSoundChoices = function()
    return {
        ["ObjectiveDefault"]   = "Default",
        ["Map Ping"]           = "Map Ping",
        ["Window Close"]       = "Window Close",
        ["Window Open"]        = "Window Open",
        ["Boat Docked"]        = "Boat Docked",
        ["Bell Toll Alliance"] = "Bell Toll Alliance",
        ["Bell Toll Horde"]    = "Bell Toll Horde",
        ["Explosion"]          = "Explosion",
        ["Shing!"]             = "Shing!",
        ["Wham!"]              = "Wham!",
        ["Simon Chime"]        = "Simon Chime",
        ["War Drums"]          = "War Drums",
        ["Humm"]               = "Humm",
        ["Short Circuit"]      = "Short Circuit",
    }
end

_GetObjectiveSoundChoicesSort = function()
    return {
        "ObjectiveDefault",
        "Map Ping",
        "Window Close",
        "Window Open",
        "Boat Docked",
        "Bell Toll Alliance",
        "Bell Toll Horde",
        "Explosion",
        "Shing!",
        "Wham!",
        "Simon Chime",
        "War Drums",
        "Humm",
        "Short Circuit",
    }
end
