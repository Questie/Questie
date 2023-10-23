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
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type WorldMapButton
local WorldMapButton = QuestieLoader:ImportModule("WorldMapButton")
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");

QuestieOptions.tabs.general = { ... }
local optionsDefaults = QuestieOptionsDefaults:Load()

local _GetIconTypes
local _GetIconTypesSort

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
            Spacer_A1 = QuestieOptionsUtils:Spacer(2.1),
            isleOfQuelDanasPhase = {
                type = "select",
                order = 2.5,
                width = 1.5,
                --hidden = (not Questie.IsTBC),
                values = IsleOfQuelDanas.localizedPhaseNames,
                style = 'dropdown',
                name = function() return l10n("Isle of Quel'Danas Phase") end,
                desc = function() return l10n("Select the phase fitting your realm progress on the Isle of Quel'Danas"); end,
                disabled = function() return (not Questie.IsWotlk) end,
                get = function() return Questie.db.profile.isleOfQuelDanasPhase; end,
                set = function(_, key)
                    Questie.db.profile.isleOfQuelDanasPhase = key
                    QuestieQuest:SmoothReset()
                end,
            },
            isleOfQuelDanasPhaseReminder = {
                type = "toggle",
                order = 2.6,
                --hidden = (not Questie.IsTBC),
                name = function() return l10n('Disable Phase reminder'); end,
                desc = function() return l10n("Enable or disable the reminder on login to set the Isle of Quel'Danas phase"); end,
                disabled = function() return (not Questie.IsWotlk) end,
                width = 1,
                get = function() return Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled; end,
                set = function(_, value)
                    Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled = value
                end,
            },
            Spacer_A = QuestieOptionsUtils:Spacer(2.9),
            --Spacer_A = QuestieOptionsUtils:Spacer(2.9, (not Questie.IsTBC)),
            instantQuest = {
                type = "toggle",
                order = 4,
                name = function() return l10n('Enable Instant Quest Text'); end,
                desc = function() return l10n('Toggles the default Instant Quest Text option. This is just a shortcut for the WoW option in Interface.'); end,
                width = 1.5,
                get = function()
                    if GetCVar("instantQuestText") == '1' then
                        return true;
                    else
                        return false;
                    end
                end,
                set = function(info, value)
                    if value then
                        SetCVar("instantQuestText", 1);
                    else
                        SetCVar("instantQuestText", 0);
                    end
                end,
            },
            map_options_group = {
                type = "group",
                order = 5,
                inline = true,
                name = function() return l10n('Map Options'); end,
                args = {
                    mapShowHideEnabled = {
                        type = "toggle",
                        order = 5.1,
                        name = function() return l10n('Show Questie Map Button'); end,
                        desc = function() return l10n('Enable or disable the Show/Hide Questie Button on Map (May fix some Map Addon interactions).'); end,
                        width = 3.3,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            WorldMapButton.Toggle(value)
                        end,
                    },
                    mapCoordinatesEnabled = {
                        type = "toggle",
                        order = 5.2,
                        name = function() return l10n('Show Map Coordinates'); end,
                        desc = function() return l10n("Place the Player's coordinates and Cursor's coordinates on the Map's title."); end,
                        width = 1.7,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            if not value then
                                QuestieCoords.ResetMapText();
                            end
                        end,
                    },
                    mapCoordinatePrecision = {
                        type = "range",
                        order = 5.3,
                        name = function() return l10n('Map Coordinates Decimal Precision'); end,
                        desc = function() return l10n('How many decimals to include in the precision on the Map for Player and Cursor coordinates. ( Default: %s )', optionsDefaults.profile.mapCoordinatePrecision); end,
                        width = 1.4,
                        min = 1,
                        max = 5,
                        step = 1,
                        disabled = function() return not Questie.db.profile.mapCoordinatesEnabled end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    }
                },
            },
            minimap_options_group = {
                type = "group",
                order = 6,
                inline = true,
                name = function() return l10n('Minimap Options'); end,
                args = {
                    minimapButtonEnabled = {
                        type = "toggle",
                        order = 6.1,
                        name = function() return l10n('Enable Minimap Button'); end,
                        desc = function() return l10n('Enable or disable the Questie minimap button. You can still access the options menu with /questie.'); end,
                        width = 1.5,
                        get = function() return not Questie.db.profile.minimap.hide; end,
                        set = function(info, value)
                            Questie.db.profile.minimap.hide = not value;

                            if value then
                                Questie.minimapConfigIcon:Show("Questie");
                            else
                                Questie.minimapConfigIcon:Hide("Questie");
                            end
                        end,
                    },
                    minimapCoordinatesEnabled = {
                        type = "toggle",
                        order = 6.2,
                        name = function() return l10n('Show Minimap Coordinates'); end,
                        desc = function() return l10n("Place the Player's coordinates on the Minimap title."); end,
                        width = "full",
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            if not value then
                                QuestieCoords:ResetMinimapText();
                            end
                        end,
                    },
                },
            },
            tooltip_options_group = {
                type = "group",
                order = 7,
                inline = true,
                name = function() return l10n('Tooltip Options'); end,
                args = {
                    enableTooltipsToggle = {
                        type = "toggle",
                        order = 7.1,
                        name = function() return l10n('Enable World Tooltips'); end,
                        desc = function() return l10n('When this is enabled, quest info will be added to relevant mob/item tooltips.'); end,
                        width = 1.5,
                        get = function () return Questie.db.profile.enableTooltips; end,
                        set = function (_, value) Questie.db.profile.enableTooltips = value end
                    },
                    questsInNpcTooltip = {
                        type = "toggle",
                        order = 7.2,
                        name = function() return l10n('Show quests in NPC tooltips'); end,
                        desc = function() return l10n('Show quests (available/complete) in the NPC tooltips.'); end,
                        width = 1.5,
                        disabled = function() return not Questie.db.profile.enableTooltips; end,
                        get = function () return Questie.db.profile.showQuestsInNpcTooltip; end,
                        set = function (_, value) Questie.db.profile.showQuestsInNpcTooltip = value end
                    },
                    showQuestLevels = {
                        type = "toggle",
                        order = 7.3,
                        name = function() return l10n('Show quest level in tooltips'); end,
                        desc = function() return l10n('When this is checked, the level of quests will show in the tooltips.'); end,
                        width = 1.5,
                        get = function() return Questie.db.profile.enableTooltipsQuestLevel; end,
                        set = function (_, value)
                            Questie.db.profile.enableTooltipsQuestLevel = value
                            if value and not Questie.db.profile.trackerShowQuestLevel then
                                Questie.db.profile.trackerShowQuestLevel = true
                                QuestieTracker:Update()
                            end
                        end
                    },
                    questXpAtMaxLevel = {
                        type = "toggle",
                        order = 7.4,
                        name = function() return l10n('Show quest XP at max level'); end,
                        desc = function() return l10n('Shows the quest XP values on quests even at max level.'); end,
                        width = 1.5,
                        get = function () return Questie.db.profile.showQuestXpAtMaxLevel; end,
                        set = function (_, value) Questie.db.profile.showQuestXpAtMaxLevel = value end
                    },
                    partyOnlyToggle = {
                        type = "toggle",
                        order = 7.5,
                        name = function() return l10n('Only show party members'); end,
                        desc = function() return l10n('When this is enabled, shared quest info will only show players in your party.'); end,
                        width = 1.5,
                        get = function () return Questie.db.profile.onlyPartyShared; end,
                        set = function (_, value) Questie.db.profile.onlyPartyShared = value end
                    },
                },
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
                get = function() return Questie.db.profile.lowlevel; end,
                set = function(info, value)
                    Questie.db.profile.lowlevel = value
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
                disabled = function() return Questie.db.profile.lowlevel or Questie.db.profile.absoluteLevelOffset; end,
                get = function() return Questie.db.profile.manualMinLevelOffset; end,
                set = function(info, value)
                    Questie.db.profile.manualMinLevelOffset = value
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
                disabled = function() return Questie.db.profile.lowlevel or Questie.db.profile.manualMinLevelOffset; end,
                get = function() return Questie.db.profile.absoluteLevelOffset; end,
                set = function(info, value)
                    Questie.db.profile.absoluteLevelOffset = value
                    QuestieOptions.AvailableQuestRedraw();
                    Questie:Debug(Questie.DEBUG_DEVELOP, l10n('Enable absolute level range'), value)
                end,
            },
            minLevelFilter = {
                type = "range",
                order = 16,
                name = function()
                    if Questie.db.profile.absoluteLevelOffset then
                        return l10n('Level from');
                    else
                        return l10n('< Show below level');
                    end
                end,
                desc = function()
                    if Questie.db.profile.absoluteLevelOffset then
                        return l10n('Minimum quest level to show.');
                    else
                        return l10n('How many levels below your character to show. ( Default: %s )', optionsDefaults.profile.minLevelFilter);
                    end
                end,
                width = "normal",
                min = 0,
                max = 60 + 10 * GetExpansionLevel(),
                step = 1,
                disabled = function() return (not Questie.db.profile.manualMinLevelOffset) and (not Questie.db.profile.absoluteLevelOffset); end,
                get = function() return Questie.db.profile.minLevelFilter; end,
                set = function(info, value)
                    Questie.db.profile.minLevelFilter = value;
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, "minLevelFilter set to " .. value)
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
                disabled = function() return (not Questie.db.profile.absoluteLevelOffset); end,
                get = function(info) return Questie.db.profile.maxLevelFilter; end,
                set = function(info, value)
                    Questie.db.profile.maxLevelFilter = value;
                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, "maxLevelFilter set to " .. value)
                end,
            },
        },
    }
end