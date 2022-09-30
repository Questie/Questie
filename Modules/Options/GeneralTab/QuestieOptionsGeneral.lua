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
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.general = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetShortcuts

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
                    seperatingHeader1 = {
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
                        desc = function() return l10n('When this is enabled, the locations of available quest will be shown on the map/minimap.'); end,
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
                        desc = function() return l10n('When this is enabled, the locations of repeatable quest will be shown on the map/minimap.'); end,
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
                        desc = function() return l10n('When this is enabled, the locations of events quest will be shown on the map/minimap.'); end,
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
                        desc = function() return l10n('When this is enabled, the locations of dungeon quest will be shown on the map/minimap.'); end,
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
                        desc = function() return l10n('When this is enabled, the locations of raid quest will be shown on the map/minimap.'); end,
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
                        desc = function() return l10n('When this is enabled, the locations of PvP quest will be shown on the map/minimap.'); end,
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
                        name = function() return l10n('Enable AQ War Effort Quest Icons'); end,
                        desc = function() return l10n('When this is enabled, the locations of the AQ War Effort quest will be shown on the map/minimap.'); end,
                        width = 1.5,
                        disabled = function() return (not Questie.db.char.enabled); end,
                        get = function(info) return Questie.db.char.showAQWarEffortQuests end,
                        set = function (info, value)
                            Questie.db.char.showAQWarEffortQuests = value
                            QuestieQuest:ToggleNotes(value)
                            QuestieQuest:SmoothReset()
                        end,
                    },
                },
            },
            Spacer_A1 = QuestieOptionsUtils:Spacer(2.1, (not Questie.IsWotlk)),
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
            Spacer_A = QuestieOptionsUtils:Spacer(2.9, (not Questie.IsWotlk)),
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
                desc = function() return l10n('Enable or disable Questie auto-complete quests.'); end,
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
